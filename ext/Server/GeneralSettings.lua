---@class GeneralSettings
GeneralSettings = class 'GeneralSettings'

function GeneralSettings:__init()
	self.m_ServerConfig = {}
end

function GeneralSettings:OnSaveServerSetupSettings(p_Args)
	RCON:SendCommand('vars.serverName', {p_Args[1]})
	self.m_ServerConfig[1] = p_Args[1]
	RCON:SendCommand('vars.serverDescription', {p_Args[2]})
	self.m_ServerConfig[2] = p_Args[2]
	RCON:SendCommand('vars.serverMessage', {p_Args[3]})
	self.m_ServerConfig[3] = p_Args[3]
	RCON:SendCommand('vars.gamePassword', {p_Args[4]})
	self.m_ServerConfig[4] = p_Args[4]
end

function GeneralSettings:PresetNormal()
	RCON:SendCommand('vars.friendlyFire', {"false"})
	self.m_ServerConfig[6] = "false"
	RCON:SendCommand('vars.idleTimeout', {"300"})
	self.m_ServerConfig[29] = "300"
	RCON:SendCommand('vars.autoBalance', {"true"})
	self.m_ServerConfig[5] = "true"
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	self.m_ServerConfig[24] = "5"
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	self.m_ServerConfig[28] = "3"
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"true"})
	self.m_ServerConfig[15] = "true"
	RCON:SendCommand('vars.regenerateHealth', {"true"})
	self.m_ServerConfig[14] = "true"
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"false"})
	self.m_ServerConfig[16] = "false"
	RCON:SendCommand('vars.minimap', {"true"})
	self.m_ServerConfig[8] = "true"
	RCON:SendCommand('vars.hud', {"true"})
	self.m_ServerConfig[9] = "true"
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	self.m_ServerConfig[11] = "true"
	RCON:SendCommand('vars.3dSpotting', {"true"})
	self.m_ServerConfig[10] = "true"
	RCON:SendCommand('vars.killCam', {"true"})
	self.m_ServerConfig[7] = "true"
	RCON:SendCommand('vars.3pCam', {"true"})
	self.m_ServerConfig[13] = "true"
	RCON:SendCommand('vars.nameTag', {"true"})
	self.m_ServerConfig[12] = "true"
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	self.m_ServerConfig[40] = "0"
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	self.m_ServerConfig[49] = "100"
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	self.m_ServerConfig[36] = "100"
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	self.m_ServerConfig[37] = "100"
	RCON:SendCommand('vars.soldierHealth', {"100"})
	self.m_ServerConfig[35] = "100"
	RCON:SendCommand('vars.bulletDamage', {"100"})
	self.m_ServerConfig[38] = "100"
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	self.m_ServerConfig[22] = "true"
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	self.m_ServerConfig[21] = "true"
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	self.m_ServerConfig[41] = "100"
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	self.m_ServerConfig[42] = "1.0"
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	self.m_ServerConfig[18] = "false"
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	self.m_ServerConfig[17] = "true"
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	self.m_ServerConfig[19] = "true"
	RCON:SendCommand('vu.SquadSize', {"4"})
	self.m_ServerConfig[43] = "4"
end

function GeneralSettings:PresetHardcore()
	RCON:SendCommand('vars.friendlyFire', {"true"})
	self.m_ServerConfig[6] = "true"
	RCON:SendCommand('vars.idleTimeout', {"300"})
	self.m_ServerConfig[29] = "300"
	RCON:SendCommand('vars.autoBalance', {"true"})
	self.m_ServerConfig[5] = "true"
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	self.m_ServerConfig[24] = "5"
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	self.m_ServerConfig[28] = "3"
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"true"})
	self.m_ServerConfig[15] = "true"
	RCON:SendCommand('vars.regenerateHealth', {"false"})
	self.m_ServerConfig[14] = "false"
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"true"})
	self.m_ServerConfig[16] = "true"
	RCON:SendCommand('vars.minimap', {"true"})
	self.m_ServerConfig[8] = "true"
	RCON:SendCommand('vars.hud', {"false"})
	self.m_ServerConfig[9] = "false"
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	self.m_ServerConfig[11] = "true"
	RCON:SendCommand('vars.3dSpotting', {"false"})
	self.m_ServerConfig[10] = "false"
	RCON:SendCommand('vars.killCam', {"false"})
	self.m_ServerConfig[7] = "false"
	RCON:SendCommand('vars.3pCam', {"false"})
	self.m_ServerConfig[13] = "false"
	RCON:SendCommand('vars.nameTag', {"false"})
	self.m_ServerConfig[12] = "false"
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	self.m_ServerConfig[40] = "0"
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	self.m_ServerConfig[49] = "100"
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	self.m_ServerConfig[36] = "100"
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	self.m_ServerConfig[37] = "100"
	RCON:SendCommand('vars.soldierHealth', {"60"})
	self.m_ServerConfig[35] = "60"
	RCON:SendCommand('vars.bulletDamage', {"100"})
	self.m_ServerConfig[38] = "100"
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	self.m_ServerConfig[22] = "true"
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	self.m_ServerConfig[21] = "true"
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	self.m_ServerConfig[41] = "100"
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	self.m_ServerConfig[42] = "1.0"
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	self.m_ServerConfig[18] = "false"
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	self.m_ServerConfig[17] = "true"
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	self.m_ServerConfig[19] = "true"
	RCON:SendCommand('vu.SquadSize', {"4"})
	self.m_ServerConfig[43] = "4"
end

function GeneralSettings:PresetInfantry()
	RCON:SendCommand('vars.friendlyFire', {"false"})
	self.m_ServerConfig[6] = "false"
	RCON:SendCommand('vars.idleTimeout', {"300"})
	self.m_ServerConfig[29] = "300"
	RCON:SendCommand('vars.autoBalance', {"true"})
	self.m_ServerConfig[5] = "true"
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	self.m_ServerConfig[24] = "5"
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	self.m_ServerConfig[28] = "3"
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"false"})
	self.m_ServerConfig[15] ="false"
	RCON:SendCommand('vars.regenerateHealth', {"true"})
	self.m_ServerConfig[14] = "true"
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"false"})
	self.m_ServerConfig[16] = "false"
	RCON:SendCommand('vars.minimap', {"true"})
	self.m_ServerConfig[8] = "true"
	RCON:SendCommand('vars.hud', {"true"})
	self.m_ServerConfig[9] = "true"
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	self.m_ServerConfig[11] = "true"
	RCON:SendCommand('vars.3dSpotting', {"true"})
	self.m_ServerConfig[10] = "true"
	RCON:SendCommand('vars.killCam', {"true"})
	self.m_ServerConfig[7] = "true"
	RCON:SendCommand('vars.3pCam', {"false"})
	self.m_ServerConfig[13] = "false"
	RCON:SendCommand('vars.nameTag', {"true"})
	self.m_ServerConfig[12] = "true"
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	self.m_ServerConfig[40] = "0"
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	self.m_ServerConfig[49] = "100"
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	self.m_ServerConfig[36] = "100"
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	self.m_ServerConfig[37] = "100"
	RCON:SendCommand('vars.soldierHealth', {"100"})
	self.m_ServerConfig[35] = "100"
	RCON:SendCommand('vars.bulletDamage', {"100"})
	self.m_ServerConfig[38] = "100"
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	self.m_ServerConfig[22] = "true"
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	self.m_ServerConfig[21] = "true"
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	self.m_ServerConfig[41] = "100"
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	self.m_ServerConfig[42] = "1.0"
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	self.m_ServerConfig[18] = "false"
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	self.m_ServerConfig[17] = "true"
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	self.m_ServerConfig[19] = "true"
	RCON:SendCommand('vu.SquadSize', {"4"})
	self.m_ServerConfig[43] = "4"
end

function GeneralSettings:PresetHardcoreNoMap()
	RCON:SendCommand('vars.friendlyFire', {"true"})
	self.m_ServerConfig[6] = "true"
	RCON:SendCommand('vars.idleTimeout', {"300"})
	self.m_ServerConfig[29] = "300"
	RCON:SendCommand('vars.autoBalance', {"true"})
	self.m_ServerConfig[5] = "true"
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	self.m_ServerConfig[24] = "5"
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	self.m_ServerConfig[28] = "3"
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"true"})
	self.m_ServerConfig[15] = "true"
	RCON:SendCommand('vars.regenerateHealth', {"false"})
	self.m_ServerConfig[14] = "false"
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"true"})
	self.m_ServerConfig[16] = "true"
	RCON:SendCommand('vars.minimap', {"false"})
	self.m_ServerConfig[8] = "false"
	RCON:SendCommand('vars.hud', {"false"})
	self.m_ServerConfig[9] = "false"
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	self.m_ServerConfig[11] = "true"
	RCON:SendCommand('vars.3dSpotting', {"false"})
	self.m_ServerConfig[10] = "false"
	RCON:SendCommand('vars.killCam', {"false"})
	self.m_ServerConfig[7] = "false"
	RCON:SendCommand('vars.3pCam', {"false"})
	self.m_ServerConfig[13] = "false"
	RCON:SendCommand('vars.nameTag', {"false"})
	self.m_ServerConfig[12] = "false"
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	self.m_ServerConfig[40] = "0"
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	self.m_ServerConfig[49] = "100"
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	self.m_ServerConfig[36] = "100"
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	self.m_ServerConfig[37] = "100"
	RCON:SendCommand('vars.soldierHealth', {"60"})
	self.m_ServerConfig[35] = "60"
	RCON:SendCommand('vars.bulletDamage', {"100"})
	self.m_ServerConfig[38] = "100"
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	self.m_ServerConfig[22] = "true"
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	self.m_ServerConfig[21] = "true"
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	self.m_ServerConfig[41] = "100"
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	self.m_ServerConfig[42] = "1.0"
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	self.m_ServerConfig[18] = "false"
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	self.m_ServerConfig[17] = "true"
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	self.m_ServerConfig[19] = "true"
	RCON:SendCommand('vu.SquadSize', {"4"})
	self.m_ServerConfig[43] = "4"
end

function GeneralSettings:PresetCustom(p_Args)
	RCON:SendCommand('vars.friendlyFire', {p_Args[2]})
	self.m_ServerConfig[6] = p_Args[2]
	RCON:SendCommand('vars.idleTimeout', {p_Args[3]})
	self.m_ServerConfig[29] = p_Args[3]
	RCON:SendCommand('vars.autoBalance', {p_Args[4]})
	self.m_ServerConfig[5] = p_Args[4]
	RCON:SendCommand('vars.teamKillCountForKick', {p_Args[5]})
	self.m_ServerConfig[24] = p_Args[5]
	RCON:SendCommand('vars.teamKillKickForBan', {p_Args[6]})
	self.m_ServerConfig[28] = p_Args[6]
	RCON:SendCommand('vars.vehicleSpawnAllowed', {p_Args[7]})
	self.m_ServerConfig[15] = p_Args[7]
	RCON:SendCommand('vars.regenerateHealth', {p_Args[8]})
	self.m_ServerConfig[14] = p_Args[8]
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {p_Args[9]})
	self.m_ServerConfig[16] = p_Args[9]
	RCON:SendCommand('vars.minimap', {p_Args[10]})
	self.m_ServerConfig[8] = p_Args[10]
	RCON:SendCommand('vars.hud', {p_Args[11]})
	self.m_ServerConfig[9] = p_Args[11]
	RCON:SendCommand('vars.miniMapSpotting', {p_Args[12]})
	self.m_ServerConfig[11] = p_Args[12]
	RCON:SendCommand('vars.3dSpotting', {p_Args[13]})
	self.m_ServerConfig[10] = p_Args[13]
	RCON:SendCommand('vars.killCam', {p_Args[14]})
	self.m_ServerConfig[7] = p_Args[14]
	RCON:SendCommand('vars.3pCam', {p_Args[15]})
	self.m_ServerConfig[13] = p_Args[15]
	RCON:SendCommand('vars.nameTag', {p_Args[16]})
	self.m_ServerConfig[12] = p_Args[16]
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {p_Args[17]})
	self.m_ServerConfig[40] = p_Args[17]
	RCON:SendCommand('vars.ctfRoundTimeModifier', {p_Args[18]})
	self.m_ServerConfig[49] = p_Args[18]
	RCON:SendCommand('vars.playerRespawnTime', {p_Args[19]})
	self.m_ServerConfig[36] = p_Args[19]
	RCON:SendCommand('vars.playerManDownTime', {p_Args[20]})
	self.m_ServerConfig[37] = p_Args[20]
	RCON:SendCommand('vars.soldierHealth', {p_Args[21]})
	self.m_ServerConfig[35] = p_Args[21]
	RCON:SendCommand('vars.bulletDamage', {p_Args[22]})
	self.m_ServerConfig[38] = p_Args[22]
	RCON:SendCommand('vu.ColorCorrectionEnabled', {p_Args[23]})
	self.m_ServerConfig[22] = p_Args[23]
	RCON:SendCommand('vu.SunFlareEnabled', {p_Args[24]})
	self.m_ServerConfig[21] = p_Args[24]
	RCON:SendCommand('vu.SuppressionMultiplier', {p_Args[25]})
	self.m_ServerConfig[41] = p_Args[25]
	RCON:SendCommand('vu.TimeScale', {p_Args[26]})
	self.m_ServerConfig[42] = p_Args[26]
	RCON:SendCommand('vu.DesertingAllowed', {p_Args[27]})
	self.m_ServerConfig[18] = p_Args[27]
	RCON:SendCommand('vu.DestructionEnabled', {p_Args[28]})
	self.m_ServerConfig[17] = p_Args[28]
	RCON:SendCommand('vu.VehicleDisablingEnabled', {p_Args[29]})
	self.m_ServerConfig[19] = p_Args[29]
	RCON:SendCommand('vu.SquadSize', {p_Args[30]})
	self.m_ServerConfig[43] = p_Args[30]
end

function GeneralSettings:OnBroadcastServerInfo()
	local s_Args = {}
	local s_Arg = RCON:SendCommand('vars.serverName')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.serverDescription')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.serverMessage')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.gamePassword')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.autoBalance')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.friendlyFire')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.killCam')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.minimap')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.hud')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.3dSpotting')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.miniMapSpotting')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.nameTag')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.3pCam')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.regenerateHealth')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.vehicleSpawnAllowed')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.onlySquadLeaderSpawn')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.DestructionEnabled')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.DesertingAllowed')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.VehicleDisablingEnabled')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.HighPerformanceReplication')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.SunFlareEnabled')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.ColorCorrectionEnabled')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.maxPlayers')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.teamKillCountForKick')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.teamKillValueForKick')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.teamKillValueIncrease')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.teamKillValueDecreasePerSecond')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.teamKillKickForBan')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.idleTimeout')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.idleBanRounds')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.roundStartPlayerCount')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.roundRestartPlayerCount')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.roundLockdownCountdown')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.vehicleSpawnDelay')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.soldierHealth')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.playerRespawnTime')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.playerManDownTime')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.bulletDamage')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.gameModeCounter')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.gunMasterWeaponsPreset')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.SuppressionMultiplier')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.TimeScale')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.SquadSize')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.ServerBanner')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.insert(s_Args, s_Arg[2])
	else
		table.insert(s_Args, " ")
	end


	s_Arg = RCON:SendCommand('mapList.list')
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
	s_Arg = nil
	s_Arg = RCON:SendCommand('mapList.getRounds')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('serverInfo')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		if s_Arg[9] == "2" then
			table.insert(s_Args, s_Arg[22])
		elseif s_Arg[9] == "4" then
			table.insert(s_Args, s_Arg[24])
		elseif s_Arg[9] == "0" then
			table.insert(s_Args, s_Arg[20])
		end
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.ctfRoundTimeModifier')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vu.FrequencyMode')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('modList.ListRunning')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg)
	else
		table.insert(s_Args, " ")
	end
	s_Arg = nil
	s_Arg = RCON:SendCommand('vars.serverOwner')
	if s_Arg ~= nil and s_Arg[2] ~= nil then
		table.remove(s_Arg, 1)
		table.insert(s_Args, s_Arg[1])
	else
		table.insert(s_Args, " ")
	end
	self.m_ServerConfig = s_Args
	NetEvents:Broadcast('ServerInfo', s_Args)
end

function GeneralSettings:OnAuthenticated(p_Player)
	NetEvents:SendTo('ServerInfo', p_Player, self.m_ServerConfig)
end

function GeneralSettings:SetOwner(p_PlayerName)
		self.m_ServerConfig[52] = p_PlayerName
end

function GeneralSettings:GetSquadSize()
	if self.m_ServerConfig[43] == nil then
		return 4
	else
		return tonumber(self.m_ServerConfig[43])
	end
end

function GeneralSettings:GetServerConfig()
	return self.m_ServerConfig
end

function GeneralSettings:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
	self:OnBroadcastServerInfo()
end

if g_GeneralSettings == nil then
	g_GeneralSettings = GeneralSettings()
end

return g_GeneralSettings
