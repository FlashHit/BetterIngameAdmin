---@class Admin
Admin = class 'Admin'

---@type ModSettings
local m_ModSettings = require('ModSettings')
---@type GameAdmin
local m_GameAdmin = require('GameAdmin')
---@type GeneralSettings
local m_GeneralSettings = require('GeneralSettings')
---@type ServerOwner
local m_ServerOwner = require('ServerOwner')

function Admin:__init()
	-- actions for players
	NetEvents:Subscribe('MovePlayer', self, self.OnMovePlayer)
	NetEvents:Subscribe('KillPlayer', self, self.OnKillPlayer)
	NetEvents:Subscribe('KickPlayer', self, self.OnKickPlayer)
	NetEvents:Subscribe('TBanPlayer', self, self.OnTBanPlayer)
	NetEvents:Subscribe('BanPlayer', self, self.OnBanPlayer)
	NetEvents:Subscribe('DeleteAdminRights', self, self.OnDeleteAdminRights)
	NetEvents:Subscribe('DeleteAndSaveAdminRights', self, self.OnDeleteAndSaveAdminRights)
	NetEvents:Subscribe('UpdateAdminRights', self, self.OnUpdateAdminRights)
	NetEvents:Subscribe('UpdateAndSaveAdminRights', self, self.OnUpdateAndSaveAdminRights)
	NetEvents:Subscribe('GetAdminRightsOfPlayer', self, self.OnGetAdminRightsOfPlayer)

	-- Map Rotation
	NetEvents:Subscribe('SetNextMap', self, self.OnSetNextMap)
	NetEvents:Subscribe('RunNextRound', self, self.OnRunNextRound)
	NetEvents:Subscribe('RestartRound', self, self.OnRestartRound)

	-- Server Setup
	NetEvents:Subscribe('GetServerSetupSettings', self, self.OnGetServerSetupSettings)
	NetEvents:Subscribe('SaveServerSetupSettings', self, self.OnSaveServerSetupSettings)

	-- Manage Presets
	NetEvents:Subscribe('ManagePresets', self, self.OnManagePresets)

	-- Manage ModSettings
	NetEvents:Subscribe('ResetModSettings', self, self.OnResetModSettings)
	NetEvents:Subscribe('ResetAndSaveModSettings', self, self.OnResetAndSaveModSettings)
	NetEvents:Subscribe('ApplyModSettings', self, self.OnApplyModSettings)
	NetEvents:Subscribe('SaveModSettings', self, self.OnSaveModSettings)
end

-- actions for players
function Admin:OnMovePlayer(p_Player, p_Args)
	local s_Messages = {}

	if not m_GameAdmin:CanMovePlayers(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN MOVE - Error Player " .. p_Player.name .. " is no admin")
		return
	end

	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Args[1])

	if s_TargetPlayer == nil then
		-- Player not found.
		s_Messages = {}
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN MOVE - Error Admin " .. p_Player.name .. " tried to move Player " .. p_Args[1] .. " but we couldn't find him.")
		return
	end

	RCON:SendCommand('admin.movePlayer', {s_TargetPlayer.name, p_Args[2], p_Args[3], "true"})
	RCON:SendCommand('squad.private', {tostring(s_TargetPlayer.teamId), tostring(s_TargetPlayer.squadId), "false"})

	if p_Args[4] ~= nil and p_Args[4] ~= "" then
		s_Messages = {}
		s_Messages[1] = "Moved by admin."
		s_Messages[2] = "You got moved by an admin. Reason: ".. p_Args[4]
		NetEvents:SendTo('PopupResponse', s_TargetPlayer, s_Messages)
		s_Messages = {}
		s_Messages[1] = "Move confirmed."
		s_Messages[2] = "You moved the player ".. s_TargetPlayer.name .." successfully for Reason: ".. p_Args[4]
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN MOVE - Admin " .. p_Player.name .. " moved Player " .. s_TargetPlayer.name .. " to the team " .. p_Args[2] .. " and the squad " .. p_Args[3] .. ". Reason: " .. p_Args[4])
	else
		-- send confirm to player and message to target
		s_Messages = {}
		s_Messages[1] = "Moved by admin."
		s_Messages[2] = "You got moved by an admin."
		NetEvents:SendTo('PopupResponse', s_TargetPlayer, s_Messages)
		s_Messages = {}
		s_Messages[1] = "Move confirmed."
		s_Messages[2] = "You moved the player ".. s_TargetPlayer.name .." successfully."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN MOVE - Admin " .. p_Player.name .. " moved Player " .. s_TargetPlayer.name .. " to the team " .. p_Args[2] .. " and the squad " .. p_Args[3] .. ".")
	end
end

function Admin:OnKillPlayer(p_Player, p_Args)
	local s_Messages = {}

	if not m_GameAdmin:CanKillPlayers(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN KILL - Error Player " .. p_Player.name .. " is no admin")
		return
	end

	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Args[1])

	if s_TargetPlayer == nil then
		-- Player not found.
		s_Messages = {}
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN KILL - Error Admin " .. p_Player.name .. " tried to kill Player " .. p_Args[1] .. " but we couldn't find him.")
		return
	end

	if s_TargetPlayer.alive == true then
		RCON:SendCommand('admin.killPlayer', {s_TargetPlayer.name})
		if p_Args[2] ~= nil then
			RCON:SendCommand('admin.say', {"Reason for kill: "..p_Args[2], "player", s_TargetPlayer.name})
			print("ADMIN KILL - Admin " .. p_Player.name .. " killed Player " .. s_TargetPlayer.name .. ". Reason: " .. p_Args[2])
		else
			print("ADMIN KILL - Admin " .. p_Player.name .. " killed Player " .. s_TargetPlayer.name .. ".")
		end
	elseif p_Player.corpse ~= nil and p_Player.corpse.isDead == false then
		s_TargetPlayer.corpse:ForceDead()
		if p_Args[2] ~= nil and p_Args[2] ~= "" then
			RCON:SendCommand('admin.say', {"Reason for kill: "..p_Args[2], "player", s_TargetPlayer.name})
			print("ADMIN KILL - Admin " .. p_Player.name .. " killed Player " .. s_TargetPlayer.name .. ". Reason: " .. p_Args[2])
		else
			print("ADMIN KILL - Admin " .. p_Player.name .. " killed Player " .. s_TargetPlayer.name .. ".")
		end
	else
		-- TargetPlayer aready dead.
		s_Messages[1] = "Error."
		s_Messages[2] = "The player ".. s_TargetPlayer.name .." is already dead."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN KILL - Error Admin " .. p_Player.name .. " tried to kill Player " .. s_TargetPlayer.name .. " but he is already dead.")
	end
end

function Admin:OnKickPlayer(p_Player, p_Args)
	local s_Messages = {}

	if not m_GameAdmin:CanKickPlayers(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN KICK - Error Player " .. p_Player.name .. " is no admin")
		return
	elseif m_GameAdmin:IsAdmin(p_Args[1]) or m_ServerOwner:IsOwner(p_Args[1]) then
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, that player is protected."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN KICK - Error Player " .. p_Args[1] .. " is protected")
		return
	end

	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Args[1])

	if s_TargetPlayer == nil then
		-- Player not found.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN KICK - Error Admin " .. p_Player.name .. " tried to kick Player " .. p_Args[1] .. " but we couldn't find him.")
		return
	end

	if p_Args[2]~= nil and p_Args[2] ~= "" then
		print("ADMIN KICK - Admin " .. p_Player.name .. " kicked Player " .. s_TargetPlayer.name .. ". Reason: " .. p_Args[2])
		s_TargetPlayer:Kick(""..p_Args[2].." (".. p_Player.name..")")
	else
		print("ADMIN KICK - Admin " .. p_Player.name .. " kicked Player " .. s_TargetPlayer.name .. ".")
		s_TargetPlayer:Kick("Kicked by ".. p_Player.name.."")
	end

	s_Messages[1] = "Kick confirmed."
	s_Messages[2] = "You kicked the player ".. s_TargetPlayer.name .." successfully."
	NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
end

function Admin:OnTBanPlayer(p_Player, p_Args)
	local s_Messages = {}

	if not m_GameAdmin:CanTemporaryBanPlayers(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN TBAN - Error Player " .. p_Player.name .. " is no admin")
		return
	elseif m_GameAdmin:IsAdmin(p_Args[1]) or m_ServerOwner:IsOwner(p_Args[1]) then
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, that player is protected."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN TBAN - Error Player " .. p_Args[1] .. " is protected")
		return
	end

	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Args[1])

	if s_TargetPlayer == nil then
		-- Player not found.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN TBAN - Error Admin " .. p_Player.name .. " tried to temp. ban Player " .. p_Args[1] .. " but we couldn't find him.")
		return
	end

	if p_Args[2] == nil then
		p_Args[2] = 60
	end

	if p_Args[3]~= nil and p_Args[3] ~= "" then
		print("ADMIN TBAN - Admin " .. p_Player.name .. " temp. banned Player " .. s_TargetPlayer.name .. "for " .. p_Args[2] .. " minutes. Reason: " .. p_Args[3])
		s_TargetPlayer:BanTemporarily(p_Args[2]*60, ""..p_Args[3].." (".. p_Player.name..") "..p_Args[2].." minutes")
	else
		print("ADMIN TBAN - Admin " .. p_Player.name .. " temp. banned Player " .. s_TargetPlayer.name .. "for " .. p_Args[2] .. " minutes.")
		s_TargetPlayer:BanTemporarily(p_Args[2]*60, "Temporarily banned by ".. p_Player.name.." for "..p_Args[2].." minutes")
	end

	s_Messages[1] = "Ban confirmed."
	s_Messages[2] = "You banned the player ".. s_TargetPlayer.name .." successfully for ".. p_Args[2] .." minutes."
	NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
end

function Admin:OnBanPlayer(p_Player, p_Args)
	local s_Messages = {}

	if not m_GameAdmin:CanPermanentlyBanPlayers(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN BAN - Error Player " .. p_Player.name .. " is no admin")
		return
	elseif m_GameAdmin:IsAdmin(p_Args[1]) or m_ServerOwner:IsOwner(p_Args[1]) then
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, that player is protected."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN BAN - Error Player " .. p_Args[1] .. " is protected")
		return
	end

	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_Args[1])

	if s_TargetPlayer == nil then
		-- Player not found.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN BAN - Error Admin " .. p_Player.name .. " tried to ban Player " .. p_Args[1] .. " but we couldn't find him.")
		return
	end

	if p_Args[2]~= nil and p_Args[2] ~= "" then
		print("ADMIN BAN - Admin " .. p_Player.name .. " banned Player " .. s_TargetPlayer.name .. ". Reason: " .. p_Args[2])
		s_TargetPlayer:Ban(""..p_Args[2].." (".. p_Player.name..")")
	else
		print("ADMIN BAN - Admin " .. p_Player.name .. " banned Player " .. s_TargetPlayer.name .. ".")
		s_TargetPlayer:Ban("Banned by ".. p_Player.name.."")
	end

	s_Messages[1] = "Ban confirmed."
	s_Messages[2] = "You banned the player ".. s_TargetPlayer.name .." successfully."
	NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
end

function Admin:OnDeleteAdminRights(p_Player, p_Args)
	local s_Messages = {}

	if not m_GameAdmin:CanEditGameAdminList(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN - ADMIN RIGHTS - DELETE - Error Player " .. p_Player.name .. " is no admin")
		return
	end

	RCON:SendCommand('gameAdmin.remove', p_Args)
end

function Admin:OnDeleteAndSaveAdminRights(p_Player, p_Args)
	local s_Messages = {}

	if not m_GameAdmin:CanEditGameAdminList(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN - ADMIN RIGHTS - DELETE AND SAVE - Error Player " .. p_Player.name .. " is no admin")
		return
	end

	RCON:SendCommand('gameAdmin.remove', p_Args)
	RCON:SendCommand('gameAdmin.save')
end

function Admin:OnUpdateAdminRights(p_Player, p_Args)
	local s_Messages = {}

	if not m_GameAdmin:CanEditGameAdminList(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN - ADMIN RIGHTS - ADD/ UPDATE - Error Player " .. p_Player.name .. " is no admin")
		return
	end

	RCON:SendCommand('gameAdmin.add', p_Args)
end

function Admin:OnUpdateAndSaveAdminRights(p_Player, p_Args)
	local s_Messages = {}

	if not m_GameAdmin:CanEditGameAdminList(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ADMIN - ADMIN RIGHTS - ADD/ UPDATE AND SAVE - Error Player " .. p_Player.name .. " is no admin")
		return
	end

	RCON:SendCommand('gameAdmin.add', p_Args)
	RCON:SendCommand('gameAdmin.save')
end

function Admin:OnGetAdminRightsOfPlayer(p_Player, p_PlayerName)
	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_PlayerName)

	if s_TargetPlayer == nil then
		-- That player left.
		local s_Messages = {}
		s_Messages[1] = "Error."
		s_Messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		return
	end

	local s_AdminRightsOfPlayer = m_GameAdmin:GetAdminRightsOfPlayer(s_TargetPlayer.name)
	NetEvents:SendTo('AdminRightsOfPlayer', p_Player, s_AdminRightsOfPlayer)
end

-- Map Rotation
function Admin:OnGetMapRotation()
	local s_Args = {}
	local s_Arg = RCON:SendCommand('mapList.list')

	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end

	s_Arg = nil
	s_Arg = RCON:SendCommand('mapList.getMapIndices')

	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end

	NetEvents:Broadcast('MapRotation', s_Args)
end

function Admin:OnSetNextMap(p_Player, p_MapIndex)
	if not m_GameAdmin:CanUseMapFunctions(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - SET NEXT MAP - Error - Player " .. p_Player.name .. " is no admin.")
		return
	end

	p_MapIndex = tonumber(p_MapIndex) - 1
	RCON:SendCommand('mapList.setNextMapIndex', {tostring(p_MapIndex)})
	print("ADMIN - SET NEXT MAP - Admin " .. p_Player.name .. " has changed the next map index to " .. tostring(p_MapIndex) .. ".")
	self:OnGetMapRotation()
end

function Admin:OnRunNextRound(p_Player)
	if not m_GameAdmin:CanUseMapFunctions(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - RUN NEXT ROUND - Error - Player " .. p_Player.name .. " is no admin.")
		return
	end

	RCON:SendCommand('mapList.runNextRound')
	print("ADMIN - RUN NEXT ROUND - Player " .. p_Player.name .. " ran the next round.")
end

function Admin:OnRestartRound(p_Player)
	if not m_GameAdmin:CanUseMapFunctions(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - RESTART ROUND - Error - Player " .. p_Player.name .. " is no admin.")
		return
	end

	RCON:SendCommand('mapList.restartRound')
	print("ADMIN - RESTART ROUND - Player " .. p_Player.name .. " restarted the round.")
end

-- Server Setup
function Admin:OnGetServerSetupSettings(p_Player)
	local s_Args = {}
	local s_Arg = RCON:SendCommand('vars.serverName')

	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end

	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.serverDescription')

	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end

	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.serverMessage')

	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end

	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.gamePassword')

	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end

	-- ToDo: Add preset, maprotation and overwritePresetOnStart
	NetEvents:SendTo('ServerSetupSettings', p_Player, s_Args)
end

function Admin:OnSaveServerSetupSettings(p_Player, p_Args)
	if not m_GameAdmin:CanAlterServerSettings(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - SAVE SERVER SETUP SETTINGS - Error - Player " .. p_Player.name .. " is no admin.")
		return
	end

	m_GeneralSettings:OnSaveServerSetupSettings(p_Args)
	print("ADMIN - SAVE SERVER SETUP SETTINGS - Player " .. p_Player.name .. " updated the server name: " .. p_Args[1] .. ", server description: " .. p_Args[2] .. ", server message: " .. p_Args[3] .. ", and game password: " .. p_Args[4] .. ".")
end

-- Manage Presets
function Admin:OnManagePresets(p_Player, p_Args)
	if not m_GameAdmin:CanAlterServerSettings(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - MANAGE PRESETS - Error - Player " .. p_Player.name .. " is no admin.")
		return
	end

	if p_Args[1] == "normal" then
		m_GeneralSettings:PresetNormal()
		print("ADMIN - MANAGE PRESETS - Player " .. p_Player.name .. " changed the presets to: NORMAL.")
	elseif p_Args[1] == "hardcore" then
		m_GeneralSettings:PresetHardcore()
		print("ADMIN - MANAGE PRESETS - Player " .. p_Player.name .. " changed the presets to: HARDCORE.")
	elseif p_Args[1] == "infantry" then
		m_GeneralSettings:PresetInfantry()
		print("ADMIN - MANAGE PRESETS - Player " .. p_Player.name .. " changed the presets to: INFANTRY.")
	elseif p_Args[1] == "hardcoreNoMap" then
		m_GeneralSettings:PresetHardcoreNoMap()
		print("ADMIN - MANAGE PRESETS - Player " .. p_Player.name .. " changed the presets to: HARDCORE NO MAP.")
	elseif p_Args[1] == "custom" then
		m_GeneralSettings:PresetCustom(p_Args)
		print("ADMIN - MANAGE PRESETS - Player " .. p_Player.name .. " changed the presets to: CUSTOM.")
	end

	NetEvents:Broadcast('ServerInfo', m_GeneralSettings:GetServerConfig())
	local s_Messages = {}
	s_Messages[1] = "Changed server settings."
	s_Messages[2] = "You successfully changed the server settings."
	NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
end

-- Manage ModSettings
function Admin:OnResetModSettings(p_Player)
	if not m_GameAdmin:CanAlterServerSettings(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("MODSETTINGS - Reset - Error - Player " .. p_Player.name .. " is no admin.")
		return
	end

	m_ModSettings:ResetModSettings()
	print("MODSETTINGS - Reset - Admin " .. p_Player.name .. " has updated the mod settings.")

	local s_Message = {}
	s_Message[1] = "Mod Settings reset."
	s_Message[2] = "The mod settings have been resetted."
	NetEvents:SendTo('PopupResponse', p_Player, s_Message)
end

function Admin:OnResetAndSaveModSettings(p_Player)
	if not m_GameAdmin:CanAlterServerSettings(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("MODSETTINGS - Reset & Save - Error - Player " .. p_Player.name .. " is no admin.")
		return
	end

	m_ModSettings:ResetModSettings()
	print("MODSETTINGS - Reset & Save - Admin " .. p_Player.name .. " has updated the mod settings.")

	m_ModSettings:SQLSaveModSettings()

	local s_Message = {}
	s_Message[1] = "Mod Settings resetted & saved."
	s_Message[2] = "The mod settings have been resetted and saved."
	NetEvents:SendTo('PopupResponse', p_Player, s_Message)
end

function Admin:OnApplyModSettings(p_Player, p_Args)
	if not m_GameAdmin:CanAlterServerSettings(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("MODSETTINGS - Apply - Error - Player " .. p_Player.name .. " is no admin.")
		return
	end

	m_ModSettings:SetModSettings(p_Args)
	print("MODSETTINGS - Apply - Admin " .. p_Player.name .. " has updated the mod settings.")

	local s_Message = {}
	s_Message[1] = "Mod Settings applied."
	s_Message[2] = "The mod settings have been applied."
	NetEvents:SendTo('PopupResponse', p_Player, s_Message)
end

function Admin:OnSaveModSettings(p_Player, p_Args)
	if not m_GameAdmin:CanAlterServerSettings(p_Player.name) and not m_ServerOwner:IsOwner(p_Player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("MODSETTINGS - Save - Error - Player " .. p_Player.name .. " is no admin.")
		return
	end

	m_ModSettings:SetModSettings(p_Args)
	print("MODSETTINGS - Save - Admin " .. p_Player.name .. " has updated the mod settings.")

	m_ModSettings:SQLSaveModSettings()

	local s_Message = {}
	s_Message[1] = "Mod Settings applied & saved."
	s_Message[2] = "The mod settings have been applied and saved."
	NetEvents:SendTo('PopupResponse', p_Player, s_Message)
end

return Admin()
