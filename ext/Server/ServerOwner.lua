---@class ServerOwner
ServerOwner = class 'ServerOwner'

---@type GeneralSettings
local m_GeneralSettings = require('GeneralSettings')

function ServerOwner:__init()
	self.m_Owner = nil
	self.m_LoggedOwner = false

	self:RegisterCommands()
end

function ServerOwner:RegisterCommands()
	RCON:RegisterCommand('vars.serverOwner', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
		if not SQL:Open() then
			return
		end

		local s_Query = [[
			CREATE TABLE IF NOT EXISTS server_owner (
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				text_value TEXT
			)
		]]
		if not SQL:Query(s_Query) then
			print('Failed to execute query: ' .. SQL:Error())
			return
		end

		-- Fetch all rows from the table.
		local s_Results = SQL:Query('SELECT * FROM server_owner')

		if not s_Results then
			print('Failed to execute query: ' .. SQL:Error())
			return
		end

		-- Print the fetched rows.
		for _, l_Row in pairs(s_Results) do
			self.m_Owner = l_Row["text_value"]
		end
		SQL:Close()
		if self.m_Owner ~= nil then
			if self.m_LoggedOwner == false then
				print("GET SERVER OWNER: " .. self.m_Owner)
				self.m_LoggedOwner = true
			end
			return {'OK', self.m_Owner}
		else
			if self.m_LoggedOwner == false then
				print("GET SERVER OWNER: CAUTION NO SERVER OWNER SET! PLEASE JOIN YOUR SERVER!")
			end
			return {'OK', 'OwnerNotSet'}
		end
	end)
end

function ServerOwner:IsOwner(p_PlayerName)
	if self.m_Owner == p_PlayerName then
		return true
	else
		return false
	end
end

function ServerOwner:OnAuthenticated(p_Player)
	if self.m_Owner == nil then
		self.m_Owner = p_Player.name
		if not SQL:Open() then
			return
		end
		local s_Query = [[DROP TABLE IF EXISTS server_owner]]
		if not SQL:Query(s_Query) then
			print('Failed to execute query: ' .. SQL:Error())
			return
		end
		s_Query = [[
			CREATE TABLE IF NOT EXISTS server_owner (
				id INTEGER PRIMARY KEY AUTOINCREMENT,
				text_value TEXT
			)
		]]
		if not SQL:Query(s_Query) then
			print('Failed to execute query: ' .. SQL:Error())
			return
		end
		s_Query = 'INSERT INTO server_owner (text_value) VALUES (?)'
		if not SQL:Query(s_Query, self.m_Owner) then
			print('Failed to execute query: ' .. SQL:Error())
			return
		end

		-- Fetch all rows from the table.
		local s_Results = SQL:Query('SELECT * FROM server_owner')

		if not s_Results then
			print('Failed to execute query: ' .. SQL:Error())
			return
		end

		SQL:Close()
		NetEvents:SendTo('ServerOwnerRights', p_Player)
		NetEvents:SendTo('QuickServerSetup', p_Player)
		print("ADMIN - SERVER OWNER SET - Player " .. p_Player.name .. " is now server owner.")
		m_GeneralSettings:SetOwner(p_Player.name)
	elseif p_Player.name == self.m_Owner then
		NetEvents:SendTo('ServerOwnerRights', p_Player)
		print("ADMIN - SERVER OWNER JOINED - Owner " .. p_Player.name .. " has joined the server.")
	end
end

return ServerOwner()
