local login = {}
login.isPlayerLoggedIn = {}
login.usedAccounts = {}
login.activeAttempts = {}

addEventHandler("onPlayerQuit", root,
function()
	local username = login.isPlayerLoggedIn[source] 
	if login.usedAccounts[username] then
		login.usedAccounts[username] = nil
	end
	if login.isPlayerLoggedIn[source] then
		login.isPlayerLoggedIn[source] = nil
	end
end)

function login.connectAPI(username, password, player)
	if not isElement(player) then
		return
	end
	local username, password = tostring(username), tostring(password)
	print("login.connectAPI: "..tostring(login.usedAccounts[username]))
	if login.isPlayerLoggedIn[player] then
		return triggerClientEvent(player, "notification:create", player, "Log in", "You are already logged in.")
	elseif login.activeAttempts[player] then
		return triggerClientEvent(player, "notification:create", player, "Log in", "Please wait some time before trying to logging again.")
	end
	if type(username) ~= "string" then
		return triggerClientEvent(player, "notification:create", player, "Log in", "Please enter your username.")
	end
	if #username <= 2 then
		return triggerClientEvent(player, "notification:create", player, "Log in", "Your username is too short.")
	end
	if login.usedAccounts[username] then
		return triggerClientEvent(player, "notification:create", player, "Log in", "This account is already being used.")
	end
	if type(password) ~= "string" then
		return triggerClientEvent(player, "notification:create", player, "Log in", "Please enter your password.")
	end
	if #password <= 2 then
		return triggerClientEvent(player, "notification:create", player, "Log in", "Your password is too short.")
	end

	-- The original project authenticated against a private Vultaic forum endpoint.
	-- For a self-hosted server we use MTA's native account store instead. During
	-- development, the first login with a new username creates that account.
	local account = getAccount(username)
	local created = false
	if not account then
		account = addAccount(username, password)
		created = account and true or false
	elseif not getAccount(username, password) then
		return triggerClientEvent(player, "notification:create", player, "Log in", "Wrong password")
	end
	if not account then
		return triggerClientEvent(player, "notification:create", player, "Log in", "Could not create the local account")
	end

	local connectID = tonumber(getAccountData(account, "vultaic.account_id"))
	if not connectID then
		connectID = tonumber(string.sub(md5(string.lower(username)), 1, 7), 16)
		setAccountData(account, "vultaic.account_id", connectID)
	end
	local response = {
		connect_id = connectID,
		username = username,
		password = password,
		active_donation = 0,
		moderator = false,
		super_moderator = false,
		community_manager = false,
		developer = false,
		manager = false
	}
	if login.assingUserdata(player, response) then
		local message = created and "Account created; logged in as " or "Successfully logged in as "
		triggerClientEvent(player, "notification:create", player, "Log in", message..username)
	end
end

function debugi(index, val)
	outputChatBox("[DEBUG] "..index..": "..tostring(val).." ["..type(val).."]")
end

function login.assingUserdata(player, data)
	if isElement(player) and type(data) == "table" then
		if not data.connect_id or not data.username then
			outputDebugString("Cannot assign userdata without an ID", 1)
			return false
		end
		if login.usedAccounts[data.username] then
			return false
		end
		setElementData(player, "userdata", data, false)
		triggerEvent("login:onPlayerLogin", player, data)
		triggerClientEvent(player, "login:onClientLogin", resourceRoot, data)
		login.isPlayerLoggedIn[player] = tostring(data.username)
		login.usedAccounts[tostring(data.username)] = player
		--
		--debugi("data.username", data.username)
		--debugi("login.usedAccounts index on "..data.username, login.usedAccounts[data.username])
		--
		return true
 	end
end

addEvent("login:onPlayerRequestLogin", true)
addEventHandler("login:onPlayerRequestLogin", root,
function(username, password)
	login.connectAPI(username, password, source)
end)

addEvent("login:onPlayerRequestPlayAsGuest", true)
addEventHandler("login:onPlayerRequestPlayAsGuest", root,
function()
	triggerEvent("login:onPlayerPlayAsGuest", source)
	triggerClientEvent(source, "login:onClientPlayAsGuest", resourceRoot)
end)

addEventHandler("onPlayerResourceStart", root,
function(startedResource)
	if startedResource == getThisResource() and not login.isPlayerLoggedIn[source] then
		triggerClientEvent(source, "login:forceShow", resourceRoot)
	end
end)

addEvent("login:onClientReady", true)
addEventHandler("login:onClientReady", root,
function()
	if client == source and not login.isPlayerLoggedIn[source] then
		triggerClientEvent(source, "login:forceShow", resourceRoot)
	end
end)

addEventHandler("onPlayerJoin", root,
function()
	local player = source
	for _, delay in ipairs({3000, 7000, 12000}) do
		setTimer(function()
			if isElement(player) and not login.isPlayerLoggedIn[player] then
				triggerClientEvent(player, "login:forceShow", resourceRoot)
			end
		end, delay, 1)
	end
end)

function getPlayerFromUsername(username)
	return username and login.usedAccounts[username] or nil
end
