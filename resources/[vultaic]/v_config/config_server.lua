local function setting(name, fallback)
	local value = get("*" .. name)
	if value == nil or value == "" then
		return fallback
	end
	return tostring(value)
end

function getDatabaseConfig(databaseKind)
	return {
		host = setting("dbHost", "127.0.0.1"),
		port = tonumber(setting("dbPort", "3306")) or 3306,
		user = setting("dbUser", "vultaic"),
		password = setting("dbPassword", "vultaic_dev_password"),
		database = databaseKind == "toptimes"
			and setting("toptimesDatabase", "mta_toptimes")
			or setting("accountsDatabase", "v_accounts")
	}
end
