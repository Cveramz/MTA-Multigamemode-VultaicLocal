[CmdletBinding()]
param(
    [string]$MtaServerRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$DatabaseHost = "127.0.0.1",
    [int]$DatabasePort = 3306,
    [string]$DatabaseUser = "vultaic",
    [string]$DatabasePassword = "vultaic_dev_password",
    [string]$AdminAccount = ""
)

$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot
$resourcesRoot = Join-Path $MtaServerRoot "mods\deathmatch\resources"
$configPath = Join-Path $MtaServerRoot "mods\deathmatch\mtaserver.conf"
$aclPath = Join-Path $MtaServerRoot "mods\deathmatch\acl.xml"
$backupRoot = Join-Path $MtaServerRoot "backups\vultaic-selfhosted"

foreach ($required in @($resourcesRoot, $configPath, $aclPath)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "MTA server file was not found: $required"
    }
}

$vultaicTarget = Join-Path $resourcesRoot "[vultaic]"
$syncTarget = Join-Path $resourcesRoot "[sync]"
$managerTarget = Join-Path $resourcesRoot "[managers]\mapmanager"
$managerBackup = Join-Path $backupRoot "native-mapmanager"
New-Item -ItemType Directory -Force -Path $vultaicTarget, $syncTarget, $backupRoot | Out-Null

if ((Test-Path -LiteralPath $managerTarget) -and -not (Test-Path -LiteralPath $managerBackup)) {
    Copy-Item -LiteralPath $managerTarget -Destination $managerBackup -Recurse
}
if (Test-Path -LiteralPath $managerTarget) {
    Remove-Item -LiteralPath $managerTarget -Recurse -Force
}
Copy-Item -LiteralPath (Join-Path $projectRoot "resources\[managers]\mapmanager") -Destination $managerTarget -Recurse

Get-ChildItem -LiteralPath (Join-Path $projectRoot "resources\[vultaic]") -Directory |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $vultaicTarget -Recurse -Force }
Get-ChildItem -LiteralPath (Join-Path $projectRoot "resources\[sync]") -Directory |
    ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination $syncTarget -Recurse -Force }

$dbMetaPath = Join-Path $vultaicTarget "v_config\meta.xml"
$dbMeta = Get-Content -LiteralPath $dbMetaPath -Raw
$dbMeta = $dbMeta -replace '(name="\*dbHost" value=")[^"]*', ('$1' + $DatabaseHost)
$dbMeta = $dbMeta -replace '(name="\*dbPort" value=")[^"]*', ('$1' + $DatabasePort)
$dbMeta = $dbMeta -replace '(name="\*dbUser" value=")[^"]*', ('$1' + $DatabaseUser)
$dbMeta = $dbMeta -replace '(name="\*dbPassword" value=")[^"]*', ('$1' + $DatabasePassword)
Set-Content -LiteralPath $dbMetaPath -Value $dbMeta -Encoding UTF8

$config = Get-Content -LiteralPath $configPath -Raw
$config = $config -replace '<servername>.*?</servername>', '<servername>Vultaic Multigamemode</servername>'
$config = $config -replace '\s*<resource src="mapmanager" startup="1" protected="0" />', ''
$config = $config -replace '\s*<resource src="play" startup="1" protected="0" />', ''
$startupResources = @(
    "core", "v_dm", "v_hdm", "v_os", "v_fdd", "v_race", "v_shooter",
    "v_shooter_jump", "v_hunter", "v_training_dm", "v_training_race", "v_garage"
)
foreach ($resourceName in $startupResources) {
    if ($config -notmatch ('<resource src="' + [regex]::Escape($resourceName) + '"')) {
        $entry = "    <resource src=`"$resourceName`" startup=`"1`" protected=`"0`" />`r`n"
        $config = $config -replace '</config>', ($entry + '</config>')
    }
}
Set-Content -LiteralPath $configPath -Value $config -Encoding UTF8

[xml]$acl = Get-Content -LiteralPath $aclPath -Raw
$loginGroup = $acl.acl.group | Where-Object name -eq "VultaicLogin"
if (-not $loginGroup) {
    $loginGroup = $acl.CreateElement("group")
    $loginGroup.SetAttribute("name", "VultaicLogin")
    $aclRef = $acl.CreateElement("acl")
    $aclRef.SetAttribute("name", "VultaicLogin")
    $resourceRef = $acl.CreateElement("object")
    $resourceRef.SetAttribute("name", "resource.v_login")
    [void]$loginGroup.AppendChild($aclRef)
    [void]$loginGroup.AppendChild($resourceRef)
    [void]$acl.acl.PrependChild($loginGroup)
}
$loginAcl = $acl.acl.acl | Where-Object name -eq "VultaicLogin"
if (-not $loginAcl) {
    $loginAcl = $acl.CreateElement("acl")
    $loginAcl.SetAttribute("name", "VultaicLogin")
    $right = $acl.CreateElement("right")
    $right.SetAttribute("name", "function.addAccount")
    $right.SetAttribute("access", "true")
    [void]$loginAcl.AppendChild($right)
    [void]$acl.acl.AppendChild($loginAcl)
}
if ($AdminAccount) {
    $adminGroup = $acl.acl.group | Where-Object name -eq "Admin"
    $adminObjectName = "user.$AdminAccount"
    if (-not ($adminGroup.object | Where-Object name -eq $adminObjectName)) {
        $adminObject = $acl.CreateElement("object")
        $adminObject.SetAttribute("name", $adminObjectName)
        [void]$adminGroup.AppendChild($adminObject)
    }
}
$acl.Save($aclPath)

Write-Host "Vultaic Self-Hosted installed in $MtaServerRoot"
Write-Host "Start Docker with: docker compose up -d"
Write-Host "Then start MTA Server.exe. Add maps under mods\deathmatch\resources\[maps]."

