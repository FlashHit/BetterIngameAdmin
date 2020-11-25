class 'BetterIngameAdmin'

function BetterIngameAdmin:__init()
    print("Initializing BetterIngameAdmin")
    self:RegisterVars()
    self:RegisterCommands()
    self:RegisterEvents()
end

function BetterIngameAdmin:RegisterVars()
	-- Region Vote stuff
    self.voteInProgress = false
	self.typeOfVote = ""
	self.playersVotedYes = {}
	self.playersVotedNo = {}
	self.playersVotedYesCount = 0
	self.playersVotedNoCount = 0
	self.playerToVote = nil
		
	self.cumulatedTime = 0
	self.secondsToVote = 30
	-- Endregion
	
	-- Region AdminList
	self.adminList = {"voteban_flash canMove canKill canKick canTban canBan canEditAdminRights"} --
	-- Endregion
	
	-- Region ServerBanner LoadingScreen
	self.bannerUrl = "fb://UI/Static/ServerBanner/BFServerBanner"
	self.serverName = nil
	self.serverDescription = nil
	-- Endregion
	
	-- Region save serverInfo for joining players
	self.serverConfig = {}
	-- Endregion
	
	-- Region ServerOwner
	self.owner = nil
	-- Endregion
	
	-- Region Ping for Scoreboard
	self.cumulatedTimeForPing = 0
	-- Endregion
end

function BetterIngameAdmin:RegisterCommands()
	-- Region GameAdmin
	RCON:RegisterCommand('gameAdmin.add', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
		if args ~= nil and args[1] ~= nil then
			for i,admin in pairs(self.adminList) do
				local parts = admin:split(' ')
				if args[1] == parts[1] then
					table.remove(self.adminList, i)
				end
			end
			if PlayerManager:GetPlayerByName(args[1]) ~= nil then
				NetEvents:SendTo('AdminPlayer', PlayerManager:GetPlayerByName(args[1]), args)
			end
			local insertThis = ""
			for i,canThis in pairs(args) do
				if i == 1 then
					insertThis = canThis
				else
					insertThis = insertThis .. " " .. canThis
				end
			end
			if args[2]~= nil then
				table.insert(self.adminList, insertThis)
				return {'OK', insertThis}
			end
			return {'InvalidArguments'}
		end
	end)
	RCON:RegisterCommand('gameAdmin.clear', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
		for i,admin in pairs(self.adminList) do
			local parts = admin:split(' ')
			for _,player in pairs(PlayerManager:GetPlayers()) do
				if player.name == parts[1] then
					NetEvents:SendTo('AdminPlayer', player, {player.name})
				end
			end
			table.remove(self.adminList, i)
		end
		self.adminList = {}
		return {'OK'}
	end)
	RCON:RegisterCommand('gameAdmin.list', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
		local insertThis = {'OK'}
		for i,admin in pairs(self.adminList) do
			table.insert(insertThis, admin)
		end
		return insertThis
	end)
	RCON:RegisterCommand('gameAdmin.remove', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
		if args ~= nil and args[1] ~= nil then
			if PlayerManager:GetPlayerByName(args[1]) ~= nil then
				NetEvents:SendTo('AdminPlayer', PlayerManager:GetPlayerByName(args[1]), args)
			end
			for i,admin in pairs(self.adminList) do
				local parts = admin:split(' ')
				if args[1] == parts[1] then
					table.remove(self.adminList, i)
					return {'OK'}
				end
			end
			return {'PlayerNotFound'}
		end
	end)
	RCON:RegisterCommand('gameAdmin.save', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
		if not SQL:Open() then
			return
		end
		local query = [[DROP TABLE IF EXISTS test_table]]
		if not SQL:Query(query) then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end
		query = [[
		  CREATE TABLE IF NOT EXISTS test_table (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			text_value TEXT
		  )
		]]
		if not SQL:Query(query) then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end
		query = 'INSERT INTO test_table (text_value) VALUES (?)'
		for _,admin in pairs(self.adminList) do
			if not SQL:Query(query, admin) then
			  print('Failed to execute query: ' .. SQL:Error())
			  return
			end
		end
		
		-- Fetch all rows from the table.
		results = SQL:Query('SELECT * FROM test_table')

		if not results then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end

		SQL:Close()
		return {'OK'}
	end)
	RCON:RegisterCommand('gameAdmin.load', RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
		if not SQL:Open() then
			return
		end
		
		local query = [[
		  CREATE TABLE IF NOT EXISTS test_table (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			text_value TEXT
		  )
		]]
		if not SQL:Query(query) then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end
		
		-- Fetch all rows from the table.
		results = SQL:Query('SELECT * FROM test_table')

		if not results then
		  print('Failed to execute query: ' .. SQL:Error())
		  return
		end

		self.adminList = {}
		-- Print the fetched rows.
		for _, row in pairs(results) do
			table.insert(self.adminList, row["text_value"])
			local parts = row:split(' ')
			for _,player in pairs(PlayerManager:GetPlayers()) do
				if player.name == parts[1] then
					NetEvents:SendTo('AdminPlayer', player, parts)
				end
			end
		end
		SQL:Close()
		return {'OK'}
	end)
	-- Endregion
	
	-- Region ServerBanner
	RCON:RegisterCommand("vars.bannerUrl", RemoteCommandFlag.RequiresLogin, function(command, args, loggedIn)
		if args ~= nil then
			if args[1] == "delete" then
				self.bannerUrl = "fb://UI/Static/ServerBanner/BFServerBanner"
				NetEvents:Broadcast('Info', {self.serverName, self.serverDescription, self.bannerUrl})
				return {'OK', self.bannerUrl}
			else
				self.bannerUrl = args[1]
				NetEvents:Broadcast('Info', {self.serverName, self.serverDescription, self.bannerUrl})
				return {'OK', args[1]}
			end
		else
			return {'OK', self.bannerUrl}
		end
	end)
	-- Endregion
	
	-- Region Server Owner
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
			return {'OK', self.owner}
		else
			return {'OK', 'OwnerNotSet'}
		end
	end)
	-- Endregion
end

function BetterIngameAdmin:RegisterEvents()
	-- Region Vote stuff
    NetEvents:Subscribe('VotekickPlayer', self, self.OnVotekickPlayer)
    NetEvents:Subscribe('VotebanPlayer', self, self.OnVotebanPlayer)
	NetEvents:Subscribe('Surrender', self, self.OnSurrender)
	NetEvents:Subscribe('CheckVoteYes', self, self.OnCheckVoteYes)
	NetEvents:Subscribe('CheckVoteNo', self, self.OnCheckVoteNo)
    Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
	-- self:EndVote()
	-- Endregion
	
	-- Region Admin actions for players
	NetEvents:Subscribe('MovePlayer', self, self.OnMovePlayer)
	NetEvents:Subscribe('KillPlayer', self, self.OnKillPlayer)
	NetEvents:Subscribe('KickPlayer', self, self.OnKickPlayer)
	NetEvents:Subscribe('TBanPlayer', self, self.OnTBanPlayer)
	NetEvents:Subscribe('BanPlayer', self, self.OnBanPlayer)
	NetEvents:Subscribe('UpdateAdminRights', self, self.OnUpdateAdminRights)
	NetEvents:Subscribe('GetAdminRightsOfPlayer', self, self.OnGetAdminRightsOfPlayer)
	-- Endregion
	
	
	-- Region Player Assist enemy team
	NetEvents:Subscribe('AssistEnemyTeam', self, self.OnAssistEnemyTeam) -- add support for SQDM or remove completely
	-- Endregion
	
	-- Region Squad stuff
	NetEvents:Subscribe('LeaveSquad', self, self.OnLeaveSquad)
	NetEvents:Subscribe('CreateSquad', self, self.OnCreateSquad)
	NetEvents:Subscribe('JoinSquad', self, self.OnJoinSquad)
		-- if player is SqLeader
	NetEvents:Subscribe('PrivateSquad', self, self.OnPrivateSquad)
	NetEvents:Subscribe('KickFromSquad', self, self.OnKickFromSquad)
	NetEvents:Subscribe('MakeSquadLeader', self, self.OnMakeSquadLeader)
	-- Endregion
	
	-- Region Admin Map Rotation
	NetEvents:Subscribe('GetMapRotation', self, self.OnGetMapRotation)
	NetEvents:Subscribe('SetNextMap', self, self.OnSetNextMap)
	NetEvents:Subscribe('RunNextRound', self, self.OnRunNextRound)
	NetEvents:Subscribe('RestartRound', self, self.OnRestartRound)
	-- Endregion
	
	-- Region Admin Server Setup
	NetEvents:Subscribe('GetServerSetupSettings', self, self.OnGetServerSetupSettings)
	NetEvents:Subscribe('SaveServerSetupSettings', self, self.OnSaveServerSetupSettings)
	-- Endregion
	
	-- Region Manage Presets
	NetEvents:Subscribe('ManagePresets', self, self.OnManagePresets)
	-- self:PresetNormal()
	-- self:PresetHardcore()
	-- self:PresetInfantry()
	-- self:PresetHardcoreNoMap()
	-- self:PresetCustom(args)
	-- Endregion
	
	-- Region ServerBanner on Loading Screen
		-- also Broadcast ServerSettings on every level loading
	Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
	-- self:OnBroadcastServerInfo()
	Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
	-- Endregion
	
	-- Region Send information to joining player (send serverInfo, send ServerBanner, if player is admin then send adminrights, 
		-- and check if we have an server owner)
    Events:Subscribe('Player:Authenticated', self, self.OnAuthenticated)
	-- Endregion
	
	
	-- Region get rid of this old unfinished adminpanel shit
		-- delete after implementing in new admin panel (server setup -> manage presets)
		NetEvents:Subscribe('ApplyGeneralSettings', self, self.OnApplyGeneralSettings)
	-- Endregion
end

-- Region String split method
	-- mostly for the adminList
function string:split(sep)
   local sep, fields = sep or " ", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end
-- Endregion

-- Region Vote stuff
function BetterIngameAdmin:OnVotekickPlayer(player, votekickPlayer)
	if self.voteInProgress == false then
		self.playerToVote = PlayerManager:GetPlayerByName(votekickPlayer)
		if self.playerToVote ~= nil then
			NetEvents:Broadcast('Start:VotekickPlayer', votekickPlayer)
			table.insert(self.playersVotedYes, player.name)
			self.playersVotedYesCount = self.playersVotedYesCount + 1
			self.voteInProgress = true
			self.typeOfVote = "votekick"
		end
	else
		NetEvents:SendTo('VoteInProgress', player)
	end
end

function BetterIngameAdmin:OnVotebanPlayer(player, votebanPlayer)
	if self.voteInProgress == false then
		self.playerToVote = PlayerManager:GetPlayerByName(votebanPlayer)
		if self.playerToVote ~= nil then
			NetEvents:Broadcast('Start:VotebanPlayer', votebanPlayer)
			table.insert(self.playersVotedYes, player.name)
			self.playersVotedYesCount = self.playersVotedYesCount + 1
			self.voteInProgress = true
			self.typeOfVote = "voteban"
		end
	else
		NetEvents:SendTo('VoteInProgress', player)
	end
end

function BetterIngameAdmin:OnSurrender(player)
	if self.voteInProgress == false then
		if player.teamId == TeamId.Team1 then
			self.typeOfVote = "surrenderUS"
		else
			self.typeOfVote = "surrenderRU"
		end
		NetEvents:Broadcast('Start:Surrender', self.typeOfVote)
		table.insert(self.playersVotedYes, player.name)
		self.playersVotedYesCount = self.playersVotedYesCount + 1
		self.voteInProgress = true
	else
		NetEvents:SendTo('VoteInProgress', player)
	end
end

function BetterIngameAdmin:OnCheckVoteYes(player)
	for i,playerName in pairs(self.playersVotedYes) do
		if playerName == player.name then
			return
		end
	end
	for i,playerName in pairs(self.playersVotedNo) do
		if playerName == player.name then
			table.remove(self.playersVotedNo, i)
			self.playersVotedNoCount = self.playersVotedNoCount - 1
			NetEvents:Broadcast('Remove:OneNoVote')
		end
	end
	table.insert(self.playersVotedYes, player.name)
	self.playersVotedYesCount = self.playersVotedYesCount + 1
	NetEvents:Broadcast('Vote:Yes')
end

function BetterIngameAdmin:OnCheckVoteNo(player)
	for i,playerName in pairs(self.playersVotedNo) do
		if playerName == player.name then
			return
		end
	end
	for i,playerName in pairs(self.playersVotedYes) do
		if playerName == player.name then
			table.remove(self.playersVotedYes, i)
			self.playersVotedYesCount = self.playersVotedYesCount - 1
			NetEvents:Broadcast('Remove:OneYesVote')
		end
	end
	table.insert(self.playersVotedNo, player.name)
	self.playersVotedNoCount = self.playersVotedNoCount + 1
	NetEvents:Broadcast('Vote:No')
end

function BetterIngameAdmin:OnEngineUpdate(deltaTime, simulationDeltaTime)
	if self.voteInProgress == true then
		self.cumulatedTime = self.cumulatedTime + deltaTime
		if self.cumulatedTime >= self.secondsToVote + 1 then
			self:EndVote()
		end
	end
	self.cumulatedTimeForPing = self.cumulatedTimeForPing + deltaTime
	if self.cumulatedTimeForPing >= 5 then
		local pingTable = {}
		for i,player in pairs(PlayerManager:GetPlayers()) do
			pingTable[player.name] = player.ping
			table.insert(pingTable, pingplayer)
		end
		self.cumulatedTimeForPing = 0
		NetEvents:Broadcast('Player:Ping', pingTable)
	end
end

function BetterIngameAdmin:EndVote()
	if self.playersVotedYesCount > self.playersVotedNoCount and (self.playersVotedYesCount + self.playersVotedNoCount) >= (PlayerManager:GetPlayerCount() / 2) then
		if self.typeOfVote == "votekick" or self.typeOfVote == "voteban" and playerToVote ~= nil and PlayerManager:GetPlayerByName(self.playerToVote.name) ~= nil then
			if self.typeOfVote == "votekick" then
				self.playerToVote:Kick("Votekick")
			elseif self.typeOfVote == "voteban" then
				self.playerToVote:BanTemporarily(86400, "Voteban: 24 hours") -- 24 hours
			end
		elseif self.typeOfVote == "surrenderUS" then
			args = {"2"}
			RCON:SendCommand('mapList.endround', args)
		elseif self.typeOfVote == "surrenderRU" then
			args = {"1"}
			RCON:SendCommand('mapList.endround', args)
		end
	end
	self.playersVotedYesCount = 0
	self.playersVotedNoCount = 0
	self.playersVotedYes = {}
	self.playersVotedNo = {}
	self.playerToVote = nil
	self.voteInProgress = false
	self.cumulatedTime = 0
	self.typeOfVote = ""
end
-- Endregion

-- Region Admin actions for players
function BetterIngameAdmin:OnMovePlayer(player, args)
	local t_Player = PlayerManager:GetPlayerByName(args[1])
	if t_Player ~= nil then
		RCON:SendCommand('admin.movePlayer', {t_Player.name, args[2], args[3], "true"})
		RCON:SendCommand('squad.private', {tostring(t_Player.teamId), tostring(t_Player.squadId), "false"})
		if args[4] ~= nil and args[4] ~= "" then
			RCON:SendCommand('admin.say', {"Reason for move: "..args[4], "player", t_Player.name})
			-- better send a net event to him
			-- NetEvents:SendTo('MovedByAdminMessage', t_Player, {args[4]})
		end
		-- send confirm to player and message to target
		-- NetEvents:SendTo('MovedByAdminMessage', t_Player, {"Admin decision"})
		-- NetEvents:SendTo('ConfirmMovedPlayer', player)
	else
		--send error to player
		-- NetEvents:SendTo('RejectMovedPlayer', player) -- Player not found
	end
end

function BetterIngameAdmin:OnKillPlayer(player, args)
	local t_Player = PlayerManager:GetPlayerByName(args[1])
	if t_Player ~= nil then
		if t_Player.alive == true then
			RCON:SendCommand('admin.killPlayer', {t_Player.name})
			RCON:SendCommand('admin.say', {"Reason for kill: "..args[2], "player", t_Player.name})
		elseif player.corpse ~= nil and player.corpse.isDead == false then
			t_Player.corpse:ForceDead()
			RCON:SendCommand('admin.say', {"Reason for kill: "..args[2], "player", t_Player.name})
		else
			-- send error to player
		end
	end
end

function BetterIngameAdmin:OnKickPlayer(player, args)
	local t_Player = PlayerManager:GetPlayerByName(args[1])
	if t_Player ~= nil then
		if args[2]~= nil and args[2] ~= "" then
			t_Player:Kick(""..args[2].." (".. player.name..")")
		else
			t_Player:Kick("Kicked by ".. player.name.."")
		end
	end
end

function BetterIngameAdmin:OnTBanPlayer(player, args)
	local t_Player = PlayerManager:GetPlayerByName(args[1])
	if t_Player ~= nil then
		if args[3]~= nil and args[3] ~= "" then
			t_Player:BanTemporarily(args[2]*60, ""..args[3].." (".. player.name..") "..args[2].." minutes")
		else
			t_Player:BanTemporarily(args[2]*60, "Temporarily banned by ".. player.name.." for "..args[2].." minutes")
		end
	end
end

function BetterIngameAdmin:OnBanPlayer(player, args)
	local t_Player = PlayerManager:GetPlayerByName(args[1])
	if t_Player ~= nil then
		if args[2]~= nil and args[2] ~= "" then
			t_Player:Ban(""..args[2].." (".. player.name..")")
		else
			t_Player:Ban("Banned by ".. player.name.."")
		end
		
	end
end

function BetterIngameAdmin:OnUpdateAdminRights(player, args)
	local t_Player = PlayerManager:GetPlayerByName(args[1])
	if t_Player ~= nil then
		for i,admin in pairs(self.adminList) do
			local parts = admin:split(' ')
			if t_Player.name == parts[1] then
				table.remove(self.adminList, i)
			end
		end
		NetEvents:SendTo('AdminPlayer', t_Player, args)
		local insertThis = ""
		for i,canThis in pairs(args) do
			if i == 1 then
				insertThis = canThis
			else
				insertThis = insertThis .. " " .. canThis
			end
		end
		if args[2]~= nil then
			table.insert(self.adminList, insertThis)
		end
	end
end

function BetterIngameAdmin:OnGetAdminRightsOfPlayer(player, playerName)
	local args = {}
	local found = false
	local targetPlayer = PlayerManager:GetPlayerByName(playerName)
	if targetPlayer ~= nil then
		for i,admin in pairs(self.adminList) do
			local parts = admin:split(' ')
			if targetPlayer.name == parts[1] then
				NetEvents:SendTo('AdminRightsOfPlayer', player, parts)
				found = true
			end
		end
		if found == false then
			NetEvents:SendTo('AdminRightsOfPlayer', player, {targetPlayer.name})
		end
	end
end
-- Endregion

-- Region Player Assist enemy team
function BetterIngameAdmin:OnAssistEnemyTeam(player)
	if player.alive == true then
		RCON:SendCommand('admin.killPlayer', {player.name})
	end
	if player.teamId == TeamId.Team1 then
		player.teamId = TeamId.Team2
	else
		player.teamId = TeamId.Team1
	end
end
-- Endregion

-- Region Squad stuff
function BetterIngameAdmin:OnLeaveSquad(player)
	player.squadId = SquadId.SquadNone
end

function BetterIngameAdmin:OnCreateSquad(player)
	for i=1,32 do
		if TeamSquadManager:GetSquadPlayerCount(player.teamId, i) == 0 then
			player.squadId = i
			RCON:SendCommand('squad.private', {tostring(player.teamId), tostring(player.squadId), "false"})
			return
		end
	end
end

function BetterIngameAdmin:OnJoinSquad(player, playerName)
	local targetPlayer = PlayerManager:GetPlayerByName(playerName)
	if targetPlayer ~= nil then
		if targetPlayer.isSquadPrivate == false and self.serverConfig[43] < TeamSquadManager:GetSquadPlayerCount(targetPlayer.teamId, targetPlayer.squadId) then
			player.squadId = targetPlayer.squadId
		else
			NetEvents:SendTo('ErrorJoiningSquad', player) -- Not Implemented yet
		end
	end
end

function BetterIngameAdmin:OnPrivateSquad(player)
	if player.isSquadPrivate == false then
		RCON:SendCommand('squad.private', {tostring(player.teamId), tostring(player.squadId), "true"})
	else
		RCON:SendCommand('squad.private', {tostring(player.teamId), tostring(player.squadId), "false"})
	end
end

function BetterIngameAdmin:OnKickFromSquad(player, playerName)
	local targetPlayer = PlayerManager:GetPlayerByName(playerName)
	if targetPlayer ~= nil then
		targetPlayer.squadId = SquadId.SquadNone
	end
end

function BetterIngameAdmin:OnMakeSquadLeader(player, playerName)
	local targetPlayer = PlayerManager:GetPlayerByName(playerName)
	if targetPlayer ~= nil then
		RCON:SendCommand('squad.leader', {tostring(targetPlayer.teamId), tostring(targetPlayer.squadId), playerName})
	end
end
-- Endregion

-- Region Admin Map Rotation
function BetterIngameAdmin:OnGetMapRotation(player)
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
	
	NetEvents:SendTo('MapRotation', player, args)
end

function BetterIngameAdmin:OnSetNextMap(player, mapIndex)
	mapIndex = tonumber(mapIndex) - 1
	RCON:SendCommand('mapList.setNextMapIndex', {tostring(mapIndex)})
	self:OnGetMapRotation(player)
	--TODO Broadcast update maplist
end

function BetterIngameAdmin:OnRunNextRound(player)
	RCON:SendCommand('mapList.runNextRound')
end

function BetterIngameAdmin:OnRestartRound(player)
	RCON:SendCommand('mapList.restartRound')
end
-- Enregion

-- Region Admin Server Setup
function BetterIngameAdmin:OnGetServerSetupSettings(player)
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

function BetterIngameAdmin:OnSaveServerSetupSettings(player, args)
	RCON:SendCommand('vars.serverName', {args[1]})
	RCON:SendCommand('vars.serverDescription', {args[2]})
	RCON:SendCommand('vars.serverMessage', {args[3]})
	RCON:SendCommand('vars.gamePassword', {args[4]})
end
-- Endregion

-- Region Manage Presets
function BetterIngameAdmin:OnManagePresets(player, args)
	if args[1] == "normal" then
		self:PresetNormal()
	elseif args[1] == "hardcore" then
		self:PresetHardcore()
	elseif args[1] == "infantry" then
		self:PresetInfantry()
	elseif args[1] == "hardcoreNoMap" then
		self:PresetHardcoreNoMap()
	elseif args[1] == "custom" then
		--self:PresetCustom(args)
	end
end
function BetterIngameAdmin:PresetNormal()
	RCON:SendCommand('vars.friendlyFire', {"false"})
	RCON:SendCommand('vars.idleTimeout', {"300"})
	RCON:SendCommand('vars.autoBalance', {"true"})
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"true"})
	RCON:SendCommand('vars.regenerateHealth', {"true"})
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"false"})
	RCON:SendCommand('vars.minimap', {"true"})
	RCON:SendCommand('vars.hud', {"true"})
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	RCON:SendCommand('vars.3dSpotting', {"true"})
	RCON:SendCommand('vars.killCam', {"true"})
	RCON:SendCommand('vars.3pCam', {"true"})
	RCON:SendCommand('vars.nameTag', {"true"})
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	RCON:SendCommand('vars.soldierHealth', {"100"})
	RCON:SendCommand('vars.bulletDamage', {"100"})
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	RCON:SendCommand('vu.SquadSize', {"4"})
end
function BetterIngameAdmin:PresetHardcore()
	RCON:SendCommand('vars.friendlyFire', {"true"})
	RCON:SendCommand('vars.idleTimeout', {"300"})
	RCON:SendCommand('vars.autoBalance', {"true"})
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"true"})
	RCON:SendCommand('vars.regenerateHealth', {"false"})
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"true"})
	RCON:SendCommand('vars.minimap', {"true"})
	RCON:SendCommand('vars.hud', {"false"})
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	RCON:SendCommand('vars.3dSpotting', {"false"})
	RCON:SendCommand('vars.killCam', {"false"})
	RCON:SendCommand('vars.3pCam', {"false"})
	RCON:SendCommand('vars.nameTag', {"false"})
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	RCON:SendCommand('vars.soldierHealth', {"60"})
	RCON:SendCommand('vars.bulletDamage', {"100"})
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	RCON:SendCommand('vu.SquadSize', {"4"})
end
function BetterIngameAdmin:PresetInfantry()
	RCON:SendCommand('vars.friendlyFire', {"false"})
	RCON:SendCommand('vars.idleTimeout', {"300"})
	RCON:SendCommand('vars.autoBalance', {"true"})
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"false"})
	RCON:SendCommand('vars.regenerateHealth', {"true"})
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"false"})
	RCON:SendCommand('vars.minimap', {"true"})
	RCON:SendCommand('vars.hud', {"true"})
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	RCON:SendCommand('vars.3dSpotting', {"true"})
	RCON:SendCommand('vars.killCam', {"true"})
	RCON:SendCommand('vars.3pCam', {"false"})
	RCON:SendCommand('vars.nameTag', {"true"})
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	RCON:SendCommand('vars.soldierHealth', {"100"})
	RCON:SendCommand('vars.bulletDamage', {"100"})
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	RCON:SendCommand('vu.SquadSize', {"4"})
end
function BetterIngameAdmin:PresetHardcoreNoMap()
	RCON:SendCommand('vars.friendlyFire', {"true"})
	RCON:SendCommand('vars.idleTimeout', {"300"})
	RCON:SendCommand('vars.autoBalance', {"true"})
	RCON:SendCommand('vars.teamKillCountForKick', {"5"})
	RCON:SendCommand('vars.teamKillKickForBan', {"3"})
	RCON:SendCommand('vars.vehicleSpawnAllowed', {"true"})
	RCON:SendCommand('vars.regenerateHealth', {"false"})
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {"true"})
	RCON:SendCommand('vars.minimap', {"false"})
	RCON:SendCommand('vars.hud', {"false"})
	RCON:SendCommand('vars.miniMapSpotting', {"true"})
	RCON:SendCommand('vars.3dSpotting', {"false"})
	RCON:SendCommand('vars.killCam', {"false"})
	RCON:SendCommand('vars.3pCam', {"false"})
	RCON:SendCommand('vars.nameTag', {"false"})
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {"0"})
	RCON:SendCommand('vars.ctfRoundTimeModifier', {"100"})
	RCON:SendCommand('vars.playerRespawnTime', {"100"})
	RCON:SendCommand('vars.playerManDownTime', {"100"})
	RCON:SendCommand('vars.soldierHealth', {"60"})
	RCON:SendCommand('vars.bulletDamage', {"100"})
	RCON:SendCommand('vu.ColorCorrectionEnabled', {"true"})
	RCON:SendCommand('vu.SunFlareEnabled', {"true"})
	RCON:SendCommand('vu.SuppressionMultiplier', {"100"})
	RCON:SendCommand('vu.TimeScale', {"1.0"})
	RCON:SendCommand('vu.DesertingAllowed', {"false"})
	RCON:SendCommand('vu.DestructionEnabled', {"true"})
	RCON:SendCommand('vu.VehicleDisablingEnabled', {"true"})
	RCON:SendCommand('vu.SquadSize', {"4"})
end
-- Endregion

-- Region ServerBanner on Loading Screen
		-- also Broadcast ServerSettings on every level loading
function BetterIngameAdmin:OnLevelLoaded(levelName, gameMode, round, roundsPerMap)
	local args = RCON:SendCommand('vars.serverName')
	self.serverName = args[2]
	args = RCON:SendCommand('vars.serverDescription')
	self.serverDescription = args[2]
	self:OnBroadcastServerInfo()
end

function BetterIngameAdmin:OnLevelDestroy()
	local args = RCON:SendCommand('vars.serverName')
	self.serverName = args[2]
	args = RCON:SendCommand('vars.serverDescription')
	self.serverDescription = args[2]
	NetEvents:Broadcast('Info', {self.serverName, self.serverDescription, self.bannerUrl})
end
-- Endregion

-- Region Send information to joining player (send serverInfo, send ServerBanner, if player is admin then send adminrights)
function BetterIngameAdmin:OnAuthenticated(player)
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
		NetEvents:SendTo('QuickServerSetup', player)
	end
	NetEvents:SendTo('Info', player, {self.serverName, self.serverDescription, self.bannerUrl})
	for i,admin in pairs(self.adminList) do
		local parts = admin:split(' ')
		if player.name == parts[1] then
			NetEvents:SendTo('AdminPlayer', player, parts)
		end
	end
	NetEvents:SendTo('ServerInfo', player, self.serverConfig)
end
-- Endregion


-- Region Broadcast ServerInfo
	-- gets called on OnLevelLoaded
function BetterIngameAdmin:OnBroadcastServerInfo()
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
		table.insert(args, arg)
	else
		table.insert(args, " ")
	end
	self.serverConfig = args
	NetEvents:Broadcast('ServerInfo', args)
end
-- Endregion

-- Region get rid of this old admin panel shit
function BetterIngameAdmin:OnApplyGeneralSettings(player, args)
	RCON:SendCommand('vars.serverName', {args[1]})
	RCON:SendCommand('vars.serverDescription', {args[2]})
	RCON:SendCommand('vars.serverMessage', {args[3]})
	RCON:SendCommand('vars.gamePassword', {args[4]})
	RCON:SendCommand('vars.autoBalance', {tostring(args[5])})
	RCON:SendCommand('vars.friendlyFire', {tostring(args[6])})
	RCON:SendCommand('vars.killCam', {tostring(args[7])})
	RCON:SendCommand('vars.minimap', {tostring(args[8])})
	RCON:SendCommand('vars.hud', {tostring(args[9])})
	RCON:SendCommand('vars.3dSpotting', {tostring(args[10])})
	RCON:SendCommand('vars.miniMapSpotting', {tostring(args[11])})
	RCON:SendCommand('vars.nameTag', {tostring(args[12])})
	RCON:SendCommand('vars.3pCam', {tostring(args[13])})
	RCON:SendCommand('vars.regenerateHealth', {tostring(args[14])})
	RCON:SendCommand('vars.vehicleSpawnAllowed', {tostring(args[15])})
	RCON:SendCommand('vars.onlySquadLeaderSpawn', {tostring(args[16])})
	RCON:SendCommand('vu.DestructionEnabled', {tostring(args[17])})
	RCON:SendCommand('vu.DesertingAllowed', {tostring(args[18])})
	RCON:SendCommand('vu.VehicleDisablingEnabled', {tostring(args[19])})
	RCON:SendCommand('vu.HighPerformanceReplication', {tostring(args[20])})
	RCON:SendCommand('vu.SunFlareEnabled', {tostring(args[21])})
	RCON:SendCommand('vu.ColorCorrectionEnabled', {tostring(args[22])})
	RCON:SendCommand('vars.maxPlayers', {args[23]})
	RCON:SendCommand('vars.teamKillCountForKick', {args[24]})
	RCON:SendCommand('vars.teamKillValueForKick', {args[25]})
	RCON:SendCommand('vars.teamKillValueIncrease', {args[26]})
	RCON:SendCommand('vars.teamKillValueDecreasePerSecond', {args[27]})
	RCON:SendCommand('vars.teamKillKickForBan', {args[28]})
	RCON:SendCommand('vars.idleTimeout', {args[29]})
	RCON:SendCommand('vars.idleBanRounds', {args[30]})
	RCON:SendCommand('vars.roundStartPlayerCount', {args[31]})
	RCON:SendCommand('vars.roundRestartPlayerCount', {args[32]})
	RCON:SendCommand('vars.roundLockdownCountdown', {args[33]})
	RCON:SendCommand('vars.vehicleSpawnDelay', {args[34]})
	RCON:SendCommand('vars.soldierHealth', {args[35]})
	RCON:SendCommand('vars.playerRespawnTime', {args[36]})
	RCON:SendCommand('vars.playerManDownTime', {args[37]})
	RCON:SendCommand('vars.bulletDamage', {args[38]})
	RCON:SendCommand('vars.gameModeCounter', {args[39]})
	RCON:SendCommand('vars.gunMasterWeaponsPreset', {args[40]})
	RCON:SendCommand('vu.SuppressionMultiplier', {args[41]})
	RCON:SendCommand('vu.TimeScale', {args[42]})
	RCON:SendCommand('vu.SquadSize', {args[43]})
	RCON:SendCommand('vu.ServerBanner', {args[44]})
end
-- Endregion
g_BetterIngameAdmin = BetterIngameAdmin()
