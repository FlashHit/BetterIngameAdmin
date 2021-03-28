class 'GeneralSettings'

function GeneralSettings:__init()
    self.serverConfig = {}
end

function GeneralSettings:OnSaveServerSetupSettings(args)
	RCON:SendCommand('vars.serverName', {args[1]})
	self.serverConfig[1] = args[1]
	RCON:SendCommand('vars.serverDescription', {args[2]})
	self.serverConfig[2] = args[2]
	RCON:SendCommand('vars.serverMessage', {args[3]})
	self.serverConfig[3] = args[3]
	RCON:SendCommand('vars.gamePassword', {args[4]})
    self.serverConfig[4] = args[4]
end

function GeneralSettings:PresetNormal()
	RCON:SendCommand('vars.friendlyFire', {"false"})
	self.serverConfig[6] = "false"
	RCON:SendCommand('vars.idleTimeout', {"300"})
	self.serverConfig[29] = "300"
	RCON:SendCommand('vars.autoBalance', {"true"})
	self.serverConfig[5] = "true"
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	self.serverConfig[24] = "5"
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	self.serverConfig[28] = "3"
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"true"})
	self.serverConfig[15] = "true"
	RCON:SendCommand('vars.regenerateHealth', {"true"})
	self.serverConfig[14] = "true"
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"false"})
	self.serverConfig[16] = "false"
	RCON:SendCommand('vars.minimap', {"true"})
	self.serverConfig[8] = "true"
	RCON:SendCommand('vars.hud', {"true"})
	self.serverConfig[9] = "true"
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	self.serverConfig[11] = "true"
	RCON:SendCommand('vars.3dSpotting', {"true"})
	self.serverConfig[10] = "true"
	RCON:SendCommand('vars.killCam', {"true"})
	self.serverConfig[7] = "true"
	RCON:SendCommand('vars.3pCam', {"true"})
	self.serverConfig[13] = "true"
	RCON:SendCommand('vars.nameTag', {"true"})
	self.serverConfig[12] = "true"
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	self.serverConfig[40] = "0"
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	self.serverConfig[49] = "100"
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	self.serverConfig[36] = "100"
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	self.serverConfig[37] = "100"
	RCON:SendCommand('vars.soldierHealth', {"100"})
	self.serverConfig[35] = "100"
	RCON:SendCommand('vars.bulletDamage', {"100"})
	self.serverConfig[38] = "100"
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	self.serverConfig[22] = "true"
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	self.serverConfig[21] = "true"
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	self.serverConfig[41] = "100"
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	self.serverConfig[42] = "1.0"
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	self.serverConfig[18] = "false"
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	self.serverConfig[17] = "true"
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	self.serverConfig[19] = "true"
	RCON:SendCommand('vu.SquadSize', {"4"})
	self.serverConfig[43] = "4"
end

function GeneralSettings:PresetHardcore()
	RCON:SendCommand('vars.friendlyFire', {"true"})
	self.serverConfig[6] = "true"
	RCON:SendCommand('vars.idleTimeout', {"300"})
	self.serverConfig[29] = "300"
	RCON:SendCommand('vars.autoBalance', {"true"})
	self.serverConfig[5] = "true"
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	self.serverConfig[24] = "5"
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	self.serverConfig[28] = "3"
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"true"})
	self.serverConfig[15] = "true" 
	RCON:SendCommand('vars.regenerateHealth', {"false"})
	self.serverConfig[14] = "false"
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"true"})
	self.serverConfig[16] = "true"
	RCON:SendCommand('vars.minimap', {"true"})
	self.serverConfig[8] = "true"
	RCON:SendCommand('vars.hud', {"false"})
	self.serverConfig[9] = "false"
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	self.serverConfig[11] = "true"
	RCON:SendCommand('vars.3dSpotting', {"false"})
	self.serverConfig[10] = "false"
	RCON:SendCommand('vars.killCam', {"false"})
	self.serverConfig[7] = "false"
	RCON:SendCommand('vars.3pCam', {"false"})
	self.serverConfig[13] = "false"
	RCON:SendCommand('vars.nameTag', {"false"})
	self.serverConfig[12] = "false"
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	self.serverConfig[40] = "0"
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	self.serverConfig[49] = "100"
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	self.serverConfig[36] = "100"
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	self.serverConfig[37] = "100"
	RCON:SendCommand('vars.soldierHealth', {"60"})
	self.serverConfig[35] = "60"
	RCON:SendCommand('vars.bulletDamage', {"100"})
	self.serverConfig[38] = "100"
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	self.serverConfig[22] = "true"
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	self.serverConfig[21] = "true"
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	self.serverConfig[41] = "100"
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	self.serverConfig[42] = "1.0"
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	self.serverConfig[18] = "false"
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	self.serverConfig[17] = "true"
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	self.serverConfig[19] = "true"
	RCON:SendCommand('vu.SquadSize', {"4"})
	self.serverConfig[43] = "4"
end

function GeneralSettings:PresetInfantry()
	RCON:SendCommand('vars.friendlyFire', {"false"})
	self.serverConfig[6] = "false"
	RCON:SendCommand('vars.idleTimeout', {"300"})
	self.serverConfig[29] = "300"
	RCON:SendCommand('vars.autoBalance', {"true"})
	self.serverConfig[5] = "true"
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	self.serverConfig[24] = "5"
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	self.serverConfig[28] = "3"
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"false"})
	self.serverConfig[15] ="false"
	RCON:SendCommand('vars.regenerateHealth', {"true"})
	self.serverConfig[14] = "true"
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"false"})
	self.serverConfig[16] = "false"
	RCON:SendCommand('vars.minimap', {"true"})
	self.serverConfig[8] = "true"
	RCON:SendCommand('vars.hud', {"true"})
	self.serverConfig[9] = "true"
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	self.serverConfig[11] = "true"
	RCON:SendCommand('vars.3dSpotting', {"true"})
	self.serverConfig[10] = "true"
	RCON:SendCommand('vars.killCam', {"true"})
	self.serverConfig[7] = "true"
	RCON:SendCommand('vars.3pCam', {"false"})
	self.serverConfig[13] = "false"
	RCON:SendCommand('vars.nameTag', {"true"})
	self.serverConfig[12] = "true"
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	self.serverConfig[40] = "0"
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	self.serverConfig[49] = "100"
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	self.serverConfig[36] = "100"
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	self.serverConfig[37] = "100"
	RCON:SendCommand('vars.soldierHealth', {"100"})
	self.serverConfig[35] = "100"
	RCON:SendCommand('vars.bulletDamage', {"100"})
	self.serverConfig[38] = "100"
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	self.serverConfig[22] = "true"
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	self.serverConfig[21] = "true"
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	self.serverConfig[41] = "100"
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	self.serverConfig[42] = "1.0"
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	self.serverConfig[18] = "false"
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	self.serverConfig[17] = "true"
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	self.serverConfig[19] = "true"
	RCON:SendCommand('vu.SquadSize', {"4"})
	self.serverConfig[43] = "4"
end

function GeneralSettings:PresetHardcoreNoMap()
	RCON:SendCommand('vars.friendlyFire', {"true"})
	self.serverConfig[6] = "true"
	RCON:SendCommand('vars.idleTimeout', {"300"})
	self.serverConfig[29] = "300"
	RCON:SendCommand('vars.autoBalance', {"true"})
	self.serverConfig[5] = "true"
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	self.serverConfig[24] = "5"
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	self.serverConfig[28] = "3"
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"true"})
	self.serverConfig[15] = "true"
	RCON:SendCommand('vars.regenerateHealth', {"false"})
	self.serverConfig[14] = "false"
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"true"})
	self.serverConfig[16] = "true"
	RCON:SendCommand('vars.minimap', {"false"})
	self.serverConfig[8] = "false"
	RCON:SendCommand('vars.hud', {"false"})
	self.serverConfig[9] = "false"
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	self.serverConfig[11] = "true"
	RCON:SendCommand('vars.3dSpotting', {"false"})
	self.serverConfig[10] = "false"
	RCON:SendCommand('vars.killCam', {"false"})
	self.serverConfig[7] = "false"
	RCON:SendCommand('vars.3pCam', {"false"})
	self.serverConfig[13] = "false"
	RCON:SendCommand('vars.nameTag', {"false"})
	self.serverConfig[12] = "false"
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	self.serverConfig[40] = "0"
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	self.serverConfig[49] = "100"
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	self.serverConfig[36] = "100"
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	self.serverConfig[37] = "100"
	RCON:SendCommand('vars.soldierHealth', {"60"})
	self.serverConfig[35] = "60"
	RCON:SendCommand('vars.bulletDamage', {"100"})
	self.serverConfig[38] = "100"
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	self.serverConfig[22] = "true"
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	self.serverConfig[21] = "true"
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	self.serverConfig[41] = "100"
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	self.serverConfig[42] = "1.0"
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	self.serverConfig[18] = "false"
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	self.serverConfig[17] = "true"
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	self.serverConfig[19] = "true"
	RCON:SendCommand('vu.SquadSize', {"4"})
	self.serverConfig[43] = "4"
end

function GeneralSettings:PresetCustom(args)
	RCON:SendCommand('vars.friendlyFire', {args[2]})
	self.serverConfig[6] = args[2]
	RCON:SendCommand('vars.idleTimeout', {args[3]})
	self.serverConfig[29] = args[3]
	RCON:SendCommand('vars.autoBalance', {args[4]})
	self.serverConfig[5] = args[4]
	RCON:SendCommand('vars.teamKillCountForKick', {args[5]})
	self.serverConfig[24] = args[5]
	RCON:SendCommand('vars.teamKillKickForBan', {args[6]})
	self.serverConfig[28] = args[6]
	RCON:SendCommand('vars.vehicleSpawnAllowed', {args[7]})
	self.serverConfig[15] = args[7]
	RCON:SendCommand('vars.regenerateHealth', {args[8]})
	self.serverConfig[14] = args[8]
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {args[9]})
	self.serverConfig[16] = args[9]
	RCON:SendCommand('vars.minimap', {args[10]})
	self.serverConfig[8] = args[10]
	RCON:SendCommand('vars.hud', {args[11]})
	self.serverConfig[9] = args[11]
	RCON:SendCommand('vars.miniMapSpotting', {args[12]})
	self.serverConfig[11] = args[12]
	RCON:SendCommand('vars.3dSpotting', {args[13]})
	self.serverConfig[10] = args[13]
	RCON:SendCommand('vars.killCam', {args[14]})
	self.serverConfig[7] = args[14]
	RCON:SendCommand('vars.3pCam', {args[15]})
	self.serverConfig[13] = args[15]
	RCON:SendCommand('vars.nameTag', {args[16]})
	self.serverConfig[12] = args[16]
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {args[17]})
	self.serverConfig[40] = args[17]
	RCON:SendCommand('vars.ctfRoundTimeModifier', {args[18]})
	self.serverConfig[49] = args[18]
	RCON:SendCommand('vars.playerRespawnTime', {args[19]})
	self.serverConfig[36] = args[19]
	RCON:SendCommand('vars.playerManDownTime', {args[20]})
	self.serverConfig[37] = args[20]
	RCON:SendCommand('vars.soldierHealth', {args[21]})
	self.serverConfig[35] = args[21]
	RCON:SendCommand('vars.bulletDamage', {args[22]})
	self.serverConfig[38] = args[22]
	RCON:SendCommand('vu.ColorCorrectionEnabled', {args[23]})
	self.serverConfig[22] = args[23]
	RCON:SendCommand('vu.SunFlareEnabled', {args[24]})
	self.serverConfig[21] = args[24]
	RCON:SendCommand('vu.SuppressionMultiplier', {args[25]})
	self.serverConfig[41] = args[25]
	RCON:SendCommand('vu.TimeScale', {args[26]})
	self.serverConfig[42] = args[26]
	RCON:SendCommand('vu.DesertingAllowed', {args[27]})
	self.serverConfig[18] = args[27]
	RCON:SendCommand('vu.DestructionEnabled', {args[28]})
	self.serverConfig[17] = args[28]
	RCON:SendCommand('vu.VehicleDisablingEnabled', {args[29]})
	self.serverConfig[19] = args[29]
	RCON:SendCommand('vu.SquadSize', {args[30]})
	self.serverConfig[43] = args[30]
end

function GeneralSettings:OnBroadcastServerInfo()
    local args = {}
    local arg = RCON:SendCommand('vars.serverName')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.serverDescription')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.serverMessage')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.gamePassword')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.autoBalance')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.friendlyFire')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.killCam')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.minimap')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.hud')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.3dSpotting')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.miniMapSpotting')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.nameTag')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.3pCam')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.regenerateHealth')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.vehicleSpawnAllowed')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.onlySquadLeaderSpawn')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.DestructionEnabled')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.DesertingAllowed')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.VehicleDisablingEnabled')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.HighPerformanceReplication')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.SunFlareEnabled')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.ColorCorrectionEnabled')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.maxPlayers')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.teamKillCountForKick')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.teamKillValueForKick')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.teamKillValueIncrease')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.teamKillValueDecreasePerSecond')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.teamKillKickForBan')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.idleTimeout')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.idleBanRounds')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.roundStartPlayerCount')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.roundRestartPlayerCount')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.roundLockdownCountdown')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.vehicleSpawnDelay')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.soldierHealth')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.playerRespawnTime')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.playerManDownTime')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.bulletDamage')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.gameModeCounter')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.gunMasterWeaponsPreset')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.SuppressionMultiplier')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.TimeScale')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.SquadSize')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.ServerBanner')
    if arg ~= nil and arg[2] ~= nil then
        table.insert(args, arg[2])
    else
        table.insert(args, " ")
    end
    
    
    arg = RCON:SendCommand('mapList.list')
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
    arg = nil
    arg = RCON:SendCommand('mapList.getRounds')
    if arg ~= nil and arg[2] ~= nil then
        table.remove(arg, 1)
        table.insert(args, arg)
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('serverInfo')
    if arg ~= nil and arg[2] ~= nil then
        if arg[9] == "2" then
            table.insert(args, arg[22])
        elseif arg[9] == "4" then
            table.insert(args, arg[24])
        elseif arg[9] == "0" then
            table.insert(args, arg[20])
        end
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.ctfRoundTimeModifier')
    if arg ~= nil and arg[2] ~= nil then
        table.remove(arg, 1)
        table.insert(args, arg)
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vu.FrequencyMode')
    if arg ~= nil and arg[2] ~= nil then
        table.remove(arg, 1)
        table.insert(args, arg)
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('modList.ListRunning')
    if arg ~= nil and arg[2] ~= nil then
        table.remove(arg, 1)
        table.insert(args, arg)
    else
        table.insert(args, " ")
    end
    arg = nil
    arg = RCON:SendCommand('vars.serverOwner')
    if arg ~= nil and arg[2] ~= nil then
        table.remove(arg, 1)
        table.insert(args, arg[1])
    else
        table.insert(args, " ")
    end
    self.serverConfig = args
    NetEvents:Broadcast('ServerInfo', args)
end

function GeneralSettings:OnAuthenticated(p_Player)
	NetEvents:SendTo('ServerInfo', p_Player, self.serverConfig)
end

function GeneralSettings:SetOwner(p_PlayerName)
		self.serverConfig[52] = p_PlayerName
end

function GeneralSettings:OnLevelLoaded(levelName, gameMode, round, roundsPerMap)
	self:OnBroadcastServerInfo()
end

return GeneralSettings