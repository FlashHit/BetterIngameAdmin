class 'Admin'

function Admin:__init(p_ModSettings, p_GameAdmin, p_GeneralSettings, p_ServerOwner)
    self.m_ModSettings = p_ModSettings
    self.m_GameAdmin = p_GameAdmin
    self.m_GeneralSettings = p_GeneralSettings
    self.m_ServerOwner = p_ServerOwner

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
function Admin:OnMovePlayer(player, args)
	local messages = {}
	if not self.m_GameAdmin:CanMovePlayers(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN MOVE - Error Player " .. player.name .. " is no admin")
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN MOVE - Error Admin " .. player.name .. " tried to move Player " .. args[1] .. " but we couldn't find him.")
		return
	end
	RCON:SendCommand('admin.movePlayer', {targetPlayer.name, args[2], args[3], "true"})
	RCON:SendCommand('squad.private', {tostring(targetPlayer.teamId), tostring(targetPlayer.squadId), "false"})
	if args[4] ~= nil and args[4] ~= "" then
		messages = {}
		messages[1] = "Moved by admin."
		messages[2] = "You got moved by an admin. Reason: ".. args[4]
		NetEvents:SendTo('PopupResponse', targetPlayer, messages)
		messages = {}
		messages[1] = "Move confirmed."
		messages[2] = "You moved the player ".. targetPlayer.name .." successfully for Reason: ".. args[4]
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN MOVE - Admin " .. player.name .. " moved Player " .. targetPlayer.name .. " to the team " .. args[2] .. " and the squad " .. args[3] .. ". Reason: " .. args[4])
	else
		-- send confirm to player and message to target
		messages = {}
		messages[1] = "Moved by admin."
		messages[2] = "You got moved by an admin."
		NetEvents:SendTo('PopupResponse', targetPlayer, messages)
		messages = {}
		messages[1] = "Move confirmed."
		messages[2] = "You moved the player ".. targetPlayer.name .." successfully."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN MOVE - Admin " .. player.name .. " moved Player " .. targetPlayer.name .. " to the team " .. args[2] .. " and the squad " .. args[3] .. ".")
	end
end

function Admin:OnKillPlayer(player, args)
	local messages = {}
	if not self.m_GameAdmin:CanKillPlayers(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN KILL - Error Player " .. player.name .. " is no admin")
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN KILL - Error Admin " .. player.name .. " tried to kill Player " .. args[1] .. " but we couldn't find him.")
		return
	end
	if targetPlayer.alive == true then
		RCON:SendCommand('admin.killPlayer', {targetPlayer.name})
		if args[2] ~= nil then
			RCON:SendCommand('admin.say', {"Reason for kill: "..args[2], "player", targetPlayer.name})
			print("ADMIN KILL - Admin " .. player.name .. " killed Player " .. targetPlayer.name .. ". Reason: " .. args[2])
		else
			print("ADMIN KILL - Admin " .. player.name .. " killed Player " .. targetPlayer.name .. ".")
		end
	elseif player.corpse ~= nil and player.corpse.isDead == false then
		targetPlayer.corpse:ForceDead()
		if args[2] ~= nil and args[2] ~= "" then
			RCON:SendCommand('admin.say', {"Reason for kill: "..args[2], "player", targetPlayer.name})
			print("ADMIN KILL - Admin " .. player.name .. " killed Player " .. targetPlayer.name .. ". Reason: " .. args[2])
		else
			print("ADMIN KILL - Admin " .. player.name .. " killed Player " .. targetPlayer.name .. ".")
		end
	else
		-- TargetPlayer aready dead.
		messages[1] = "Error."
		messages[2] = "The player ".. targetPlayer.name .." is already dead."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN KILL - Error Admin " .. player.name .. " tried to kill Player " .. targetPlayer.name .. " but he is already dead.")
	end
end

function Admin:OnKickPlayer(player, args)
	local messages = {}
	if not self.m_GameAdmin:CanKickPlayers(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN KICK - Error Player " .. player.name .. " is no admin")
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN KICK - Error Admin " .. player.name .. " tried to kick Player " .. args[1] .. " but we couldn't find him.")
		return
	end
	if args[2]~= nil and args[2] ~= "" then
		print("ADMIN KICK - Admin " .. player.name .. " kicked Player " .. targetPlayer.name .. ". Reason: " .. args[2])
		targetPlayer:Kick(""..args[2].." (".. player.name..")")
	else
		print("ADMIN KICK - Admin " .. player.name .. " kicked Player " .. targetPlayer.name .. ".")
		targetPlayer:Kick("Kicked by ".. player.name.."")
	end
	messages = {}
	messages[1] = "Kick confirmed."
	messages[2] = "You kicked the player ".. targetPlayer.name .." successfully."
	NetEvents:SendTo('PopupResponse', player, messages)
end

function Admin:OnTBanPlayer(player, args)
	local messages = {}
	if not self.m_GameAdmin:CanTemporaryBanPlayers(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN TBAN - Error Player " .. player.name .. " is no admin")
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN TBAN - Error Admin " .. player.name .. " tried to temp. ban Player " .. args[1] .. " but we couldn't find him.")
		return
    end
    if args[2] == nil then
        args[2] = 60
    end
	if args[3]~= nil and args[3] ~= "" then
		print("ADMIN TBAN - Admin " .. player.name .. " temp. banned Player " .. targetPlayer.name .. "for " .. args[2] .. " minutes. Reason: " .. args[3])
		targetPlayer:BanTemporarily(args[2]*60, ""..args[3].." (".. player.name..") "..args[2].." minutes")
	else
		print("ADMIN TBAN - Admin " .. player.name .. " temp. banned Player " .. targetPlayer.name .. "for " .. args[2] .. " minutes.")
		targetPlayer:BanTemporarily(args[2]*60, "Temporarily banned by ".. player.name.." for "..args[2].." minutes")
	end
	messages = {}
	messages[1] = "Ban confirmed."
	messages[2] = "You banned the player ".. targetPlayer.name .." successfully for ".. args[2] .." minutes."
	NetEvents:SendTo('PopupResponse', player, messages)
end

function Admin:OnBanPlayer(player, args)
	local messages = {}
	if not self.m_GameAdmin:CanPermanentlyBanPlayers(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN BAN - Error Player " .. player.name .. " is no admin")
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN BAN - Error Admin " .. player.name .. " tried to ban Player " .. args[1] .. " but we couldn't find him.")
		return
	end
	if args[2]~= nil and args[2] ~= "" then
		print("ADMIN BAN - Admin " .. player.name .. " banned Player " .. targetPlayer.name .. ". Reason: " .. args[2])
		targetPlayer:Ban(""..args[2].." (".. player.name..")")
	else
		print("ADMIN BAN - Admin " .. player.name .. " banned Player " .. targetPlayer.name .. ".")
		targetPlayer:Ban("Banned by ".. player.name.."")
	end
	messages = {}
	messages[1] = "Ban confirmed."
	messages[2] = "You banned the player ".. targetPlayer.name .." successfully."
	NetEvents:SendTo('PopupResponse', player, messages)
end

function Admin:OnDeleteAdminRights(player, args)
	local messages = {}
	if not self.m_GameAdmin:CanEditGameAdminList(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN - ADMIN RIGHTS - DELETE - Error Player " .. player.name .. " is no admin")
		return
	end
	RCON:SendCommand('gameAdmin.remove', args)
end

function Admin:OnDeleteAndSaveAdminRights(player, args)
	local messages = {}
	if not self.m_GameAdmin:CanEditGameAdminList(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN - ADMIN RIGHTS - DELETE AND SAVE - Error Player " .. player.name .. " is no admin")
		return
	end
	RCON:SendCommand('gameAdmin.remove', args)
	RCON:SendCommand('gameAdmin.save')
end

function Admin:OnUpdateAdminRights(player, args)
	local messages = {}
	if not self.m_GameAdmin:CanEditGameAdminList(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN - ADMIN RIGHTS - ADD/ UPDATE - Error Player " .. player.name .. " is no admin")
		return
	end
    RCON:SendCommand('gameAdmin.add', args)
end

function Admin:OnUpdateAndSaveAdminRights(player, args)
	local messages = {}
	if not self.m_GameAdmin:CanEditGameAdminList(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ADMIN - ADMIN RIGHTS - ADD/ UPDATE AND SAVE - Error Player " .. player.name .. " is no admin")
		return
	end
	RCON:SendCommand('gameAdmin.add', args)
	RCON:SendCommand('gameAdmin.save')
end

function Admin:OnGetAdminRightsOfPlayer(player, playerName)
	local found = false
	local targetPlayer = PlayerManager:GetPlayerByName(playerName)
	if targetPlayer == nil then
		-- That player left.
		local messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	local s_AdminRightsOfPlayer = self.m_GameAdmin:GetAdminRightsOfPlayer(targetPlayer.name)
	NetEvents:SendTo('AdminRightsOfPlayer', player, s_AdminRightsOfPlayer)
end

-- Map Rotation
function Admin:OnGetMapRotation()
	local args = {}
	local arg = RCON:SendCommand('mapList.list')
	if arg ~= nil and arg[2] ~= nil then
		table.remove(arg, 1)
		table.insert(args, arg)
	else
		table.insert(args, " ")
	end
	arg = nil
	arg = RCON:SendCommand('mapList.getMapIndices')
	if arg ~= nil and arg[2] ~= nil then
		table.remove(arg, 1)
		table.insert(args, arg)
	else
		table.insert(args, " ")
	end
	
	NetEvents:Broadcast('MapRotation', args)
end

function Admin:OnSetNextMap(player, mapIndex)
	if not self.m_GameAdmin:CanUseMapFunctions(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - SET NEXT MAP - Error - Player " .. player.name .. " is no admin.")
		return
	end
	mapIndex = tonumber(mapIndex) - 1
	RCON:SendCommand('mapList.setNextMapIndex', {tostring(mapIndex)})
	print("ADMIN - SET NEXT MAP - Admin " .. player.name .. " has changed the next map index to " .. tostring(mapIndex) .. ".")
	self:OnGetMapRotation()
end

function Admin:OnRunNextRound(player)
	if not self.m_GameAdmin:CanUseMapFunctions(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - RUN NEXT ROUND - Error - Player " .. player.name .. " is no admin.")
		return
	end
	RCON:SendCommand('mapList.runNextRound')
	print("ADMIN - RUN NEXT ROUND - Player " .. player.name .. " ran the next round.")
end

function Admin:OnRestartRound(player)
	if not self.m_GameAdmin:CanUseMapFunctions(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - RESTART ROUND - Error - Player " .. player.name .. " is no admin.")
		return
	end
	RCON:SendCommand('mapList.restartRound')
	print("ADMIN - RESTART ROUND - Player " .. player.name .. " restarted the round.")
end

-- Server Setup
function Admin:OnGetServerSetupSettings(player)
	local args = {}
	local arg = RCON:SendCommand('vars.serverName')
	if arg ~= nil and arg[2] ~= nil then
		table.remove(arg, 1)
		table.insert(args, arg)
	else
		table.insert(args, " ")
	end
	arg = nil
	arg = RCON:SendCommand('vars.serverDescription')
	if arg ~= nil and arg[2] ~= nil then
		table.remove(arg, 1)
		table.insert(args, arg)
	else
		table.insert(args, " ")
	end
	arg = nil
	arg = RCON:SendCommand('vars.serverMessage')
	if arg ~= nil and arg[2] ~= nil then
		table.remove(arg, 1)
		table.insert(args, arg)
	else
		table.insert(args, " ")
	end
	arg = nil
	arg = RCON:SendCommand('vars.gamePassword')
	if arg ~= nil and arg[2] ~= nil then
		table.remove(arg, 1)
		table.insert(args, arg)
	else
		table.insert(args, " ")
	end
	-- ToDo: Add preset, maprotation and overwritePresetOnStart
	NetEvents:SendTo('ServerSetupSettings', player, args)
end

function Admin:OnSaveServerSetupSettings(player, args)
	if not self.m_GameAdmin:CanAlterServerSettings(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - SAVE SERVER SETUP SETTINGS - Error - Player " .. player.name .. " is no admin.")
		return
    end
    self.m_GeneralSettings:OnSaveServerSetupSettings(args)
	print("ADMIN - SAVE SERVER SETUP SETTINGS - Player " .. player.name .. " updated the server name: " .. args[1] .. ", server description: " .. args[2] .. ", server message: " .. args[3] .. ", and game password: " .. args[4] .. ".")
end

-- Manage Presets
function Admin:OnManagePresets(player, args)
	if not self.m_GameAdmin:CanAlterServerSettings(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("ADMIN - MANAGE PRESETS - Error - Player " .. player.name .. " is no admin.")
		return
	end
	if args[1] == "normal" then
		self.m_GeneralSettings:PresetNormal()
		print("ADMIN - MANAGE PRESETS - Player " .. player.name .. " changed the presets to: NORMAL.")
	elseif args[1] == "hardcore" then
		self.m_GeneralSettings:PresetHardcore()
		print("ADMIN - MANAGE PRESETS - Player " .. player.name .. " changed the presets to: HARDCORE.")
	elseif args[1] == "infantry" then
		self.m_GeneralSettings:PresetInfantry()
		print("ADMIN - MANAGE PRESETS - Player " .. player.name .. " changed the presets to: INFANTRY.")
	elseif args[1] == "hardcoreNoMap" then
		self.m_GeneralSettings:PresetHardcoreNoMap()
		print("ADMIN - MANAGE PRESETS - Player " .. player.name .. " changed the presets to: HARDCORE NO MAP.")
	elseif args[1] == "custom" then
		self.m_GeneralSettings:PresetCustom(args)
		print("ADMIN - MANAGE PRESETS - Player " .. player.name .. " changed the presets to: CUSTOM.")
	end
	NetEvents:Broadcast('ServerInfo', self.m_GeneralSettings.serverConfig)
	local messages = {}
	messages[1] = "Changed server settings."
	messages[2] = "You successfully changed the server settings."
	NetEvents:SendTo('PopupResponse', player, messages)
end

-- Manage ModSettings
function Admin:OnResetModSettings(player)
	if not self.m_GameAdmin:CanAlterServerSettings(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("MODSETTINGS - Reset - Error - Player " .. player.name .. " is no admin.")
		return
    end
    self.m_ModSettings:ResetModSettings()
	print("MODSETTINGS - Reset - Admin " .. player.name .. " has updated the mod settings.")
	
	local message = {}
	message[1] = "Mod Settings reset."
	message[2] = "The mod settings have been resetted."
	NetEvents:SendTo('PopupResponse', player, message)
end

function Admin:OnResetAndSaveModSettings(player)
	if not self.m_GameAdmin:CanAlterServerSettings(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("MODSETTINGS - Reset & Save - Error - Player " .. player.name .. " is no admin.")
		return
	end
    self.m_ModSettings:ResetModSettings()
	print("MODSETTINGS - Reset & Save - Admin " .. player.name .. " has updated the mod settings.")
	
	self.m_ModSettings:SQLSaveModSettings()
	
	local message = {}
	message[1] = "Mod Settings resetted & saved."
	message[2] = "The mod settings have been resetted and saved."
	NetEvents:SendTo('PopupResponse', player, message)
end

function Admin:OnApplyModSettings(player, args)
	if not self.m_GameAdmin:CanAlterServerSettings(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("MODSETTINGS - Apply - Error - Player " .. player.name .. " is no admin.")
		return
    end
    self.m_ModSettings:SetModSettings(args)
	print("MODSETTINGS - Apply - Admin " .. player.name .. " has updated the mod settings.")
	
	local message = {}
	message[1] = "Mod Settings applied."
	message[2] = "The mod settings have been applied."
	NetEvents:SendTo('PopupResponse', player, message)
end

function Admin:OnSaveModSettings(player, args)
	if not self.m_GameAdmin:CanAlterServerSettings(player.name) and not self.m_ServerOwner:IsOwner(player.name) then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		print("MODSETTINGS - Save - Error - Player " .. player.name .. " is no admin.")
		return
	end
	
    self.m_ModSettings:SetModSettings(args)
    print("MODSETTINGS - Save - Admin " .. player.name .. " has updated the mod settings.")
	
	self.m_ModSettings:SQLSaveModSettings()
	
	local message = {}
	message[1] = "Mod Settings applied & saved."
	message[2] = "The mod settings have been applied and saved."
	NetEvents:SendTo('PopupResponse', player, message)
end

return Admin