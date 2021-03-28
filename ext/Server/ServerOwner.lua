class 'ServerOwner'

function ServerOwner:__init(p_GeneralSettings)
    self.m_GeneralSettings = p_GeneralSettings

	self.owner = nil
    self.loggedOwner = false
    
    self:RegisterCommands()
end

function ServerOwner:RegisterCommands()
	RCON:RegisterCommand('vars.serverOwner', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
		if not SQL:Open() then
			return
		end
		
		local query = [[
		  CREATE TABLE IF NOT EXISTS server_owner (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			text_value TEXT
		  )
		]]
		if not SQL:Query(query) then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end
		
		-- Fetch all rows from the table.
		results = SQL:Query('SELECT * FROM server_owner')

		if not results then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end
		
		-- Print the fetched rows.
		for _, row in pairs(results) do
			self.owner = row["text_value"]
		end
		SQL:Close()
		if self.owner ~= nil then
			if self.loggedOwner == false then
				print("GET SERVER OWNER: " .. self.owner)
				self.loggedOwner = true
			end
			return {'OK', self.owner}
		else
			if self.loggedOwner == false then
				print("GET SERVER OWNER: CAUTION NO SERVER OWNER SET! PLEASE JOIN YOUR SERVER!")
			end
			return {'OK', 'OwnerNotSet'}
		end
	end)
end

function ServerOwner:IsOwner(p_PlayerName)
    if self.owner == p_PlayerName then
        return true
    else
        return false
    end
end

function ServerOwner:OnAuthenticated(player)
	if self.owner == nil then
		self.owner = player.name
		if not SQL:Open() then
			return
		end
		local query = [[DROP TABLE IF EXISTS server_owner]]
		if not SQL:Query(query) then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end
		query = [[
		  CREATE TABLE IF NOT EXISTS server_owner (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			text_value TEXT
		  )
		]]
		if not SQL:Query(query) then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end
		query = 'INSERT INTO server_owner (text_value) VALUES (?)'
		if not SQL:Query(query, self.owner) then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end
		
		-- Fetch all rows from the table.
		results = SQL:Query('SELECT * FROM server_owner')

		if not results then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end

		SQL:Close()
		NetEvents:SendTo('ServerOwnerRights', player)
		NetEvents:SendTo('QuickServerSetup', player)
        print("ADMIN - SERVER OWNER SET - Player " .. player.name .. " is now server owner.")
        self.m_GeneralSettings:SetOwner(player.name)
	elseif player.name == self.owner then
		NetEvents:SendTo('ServerOwnerRights', player)
		print("ADMIN - SERVER OWNER JOINED - Owner " .. player.name .. " has joined the server.")
    end
end

return ServerOwner