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
	self.playerStartedVoteCounter = {}
		
	self.cumulatedTime = 0
	self.secondsToVote = 30
	-- Endregion
	
	-- Region AdminList
	self.adminList = {}
	-- Endregion
	
	-- Region Assist
	self.queueAssistList1 = {}
	self.queueAssistList2 = {}
	self.queueAssistList3 = {}
	self.queueAssistList4 = {}
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
	
	-- Region Admin gameAdmin Events Dispatch/ Subscribe
	Events:Subscribe('GameAdmin:Player', self, self.OnGameAdminPlayer)
	Events:Subscribe('GameAdmin:Clear', self, self.OnGameAdminClear)
	-- Endregion
	
	-- Region Admin actions for players
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
	-- Endregion
	
	
	-- Region Player Assist enemy team
	NetEvents:Subscribe('AssistEnemyTeam', self, self.OnAssistEnemyTeam)
	NetEvents:Subscribe('CancelAssistEnemyTeam', self, self.OnCancelAssistEnemyTeam)
	
	-- self:OnQueueAssistEnemyTeam(player)
	Events:Subscribe('Player:Left', self, self.OnPlayerLeft)
	-- self:CheckQueueAssist()
	-- self:AssistTarget(player, isInQueueList)
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
	--self:OnGetMapRotation()
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
		-- and check the assist queue
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
	-- use reservedSlotsList for admin protection as soon as this get implemented
function BetterIngameAdmin:OnVotekickPlayer(player, votekickPlayer)
	if self.voteInProgress == false then
		self.playerToVote = PlayerManager:GetPlayerByName(votekickPlayer)
		if self.playerToVote ~= nil then
			if self.adminList[self.playerToVote.name] ~= nil and self.adminList[self.playerToVote.name].canKick ~= nil then
				-- That guy is admin and can Kick. So he is protected.
				local args = {}
				args[1] = "This player is protected."
				args[2] = "The player ".. votekickPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', player, args)
				return
			elseif self.owner == self.playerToVote.name then
				-- That guy is the server owner. So he is protected.
				local args = {}
				args[1] = "This player is protected."
				args[2] = "The player ".. votekickPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', player, args)
				return
			end
			if self.playerStartedVoteCounter[player.name] == nil then
				self.playerStartedVoteCounter[player.name] = 1
				NetEvents:Broadcast('Start:VotekickPlayer', votekickPlayer)
				table.insert(self.playersVotedYes, player.name)
				self.playersVotedYesCount = self.playersVotedYesCount + 1
				self.voteInProgress = true
				self.typeOfVote = "votekick"
				return
			end
			if self.playerStartedVoteCounter[player.name] < 3 then
				self.playerStartedVoteCounter[player.name] = self.playerStartedVoteCounter[player.name] + 1
				NetEvents:Broadcast('Start:VotekickPlayer', votekickPlayer)
				table.insert(self.playersVotedYes, player.name)
				self.playersVotedYesCount = self.playersVotedYesCount + 1
				self.voteInProgress = true
				self.typeOfVote = "votekick"
				if self.playerStartedVoteCounter[player.name] == 3 then	
					NetEvents:SendTo('HideVoteButtons', player)
				end
			else
				local args = {}
				args[1] = "Votelimit reached."
				args[2] = "You reached the maximum amount of votes for this round."
				NetEvents:SendTo('PopupResponse', player, args)
			end
		end
	else
		local args = {}
		args[1] = "Vote in progress."
		args[2] = "Please wait until the current voting is over and try again."
		NetEvents:SendTo('PopupResponse', player, args)
	end
end

function BetterIngameAdmin:OnVotebanPlayer(player, votebanPlayer)
	if self.voteInProgress == false then
		self.playerToVote = PlayerManager:GetPlayerByName(votebanPlayer)
		if self.playerToVote ~= nil then
			if self.adminList[self.playerToVote.name] ~= nil and self.adminList[self.playerToVote.name].canKick ~= nil then
				-- That guy is admin and can Kick. So he is protected.
				local args = {}
				args[1] = "This player is protected."
				args[2] = "The player ".. votebanPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', player, args)
				return
			elseif self.owner == self.playerToVote.name then
				-- That guy is the server owner. So he is protected.
				local args = {}
				args[1] = "This player is protected."
				args[2] = "The player ".. votebanPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', player, args)
				return
			end
			if self.playerStartedVoteCounter[player.name] == nil then
				self.playerStartedVoteCounter[player.name] = 1
				NetEvents:Broadcast('Start:VotebanPlayer', votebanPlayer)
				table.insert(self.playersVotedYes, player.name)
				self.playersVotedYesCount = self.playersVotedYesCount + 1
				self.voteInProgress = true
				self.typeOfVote = "voteban"
				return
			end
			if self.playerStartedVoteCounter[player.name] < 3 then
				self.playerStartedVoteCounter[player.name] = self.playerStartedVoteCounter[player.name] + 1
				NetEvents:Broadcast('Start:VotebanPlayer', votebanPlayer)
				table.insert(self.playersVotedYes, player.name)
				self.playersVotedYesCount = self.playersVotedYesCount + 1
				self.voteInProgress = true
				self.typeOfVote = "voteban"
				if self.playerStartedVoteCounter[player.name] == 3 then	
					NetEvents:SendTo('HideVoteButtons', player)
				end
			else
				local args = {}
				args[1] = "Votelimit reached."
				args[2] = "You reached the maximum amount of votes for this round."
				NetEvents:SendTo('PopupResponse', player, args)
			end
		end
	else
		local args = {}
		args[1] = "Vote in progress."
		args[2] = "Please wait until the current voting is over and try again."
		NetEvents:SendTo('PopupResponse', player, args)
	end
end

function BetterIngameAdmin:OnSurrender(player)
	if self.voteInProgress == false then
		if player.teamId == TeamId.Team1 then
			self.typeOfVote = "surrenderUS"
		else
			self.typeOfVote = "surrenderRU"
		end
		if self.playerStartedVoteCounter[player.name] == nil then
			NetEvents:Broadcast('Start:Surrender', self.typeOfVote)
			table.insert(self.playersVotedYes, player.name)
			self.playersVotedYesCount = self.playersVotedYesCount + 1
			self.voteInProgress = true
		end
		if self.playerStartedVoteCounter[player.name] < 3 then
			NetEvents:Broadcast('Start:Surrender', self.typeOfVote)
			table.insert(self.playersVotedYes, player.name)
			self.playersVotedYesCount = self.playersVotedYesCount + 1
			self.voteInProgress = true
			if self.playerStartedVoteCounter[player.name] == 3 then	
				NetEvents:SendTo('HideVoteButtons', player)
			end
		else
			local args = {}
			args[1] = "Votelimit reached."
			args[2] = "You reached the maximum amount of votes for this round."
			NetEvents:SendTo('PopupResponse', player, args)
		end
	else
		local args = {}
		args[1] = "Vote in progress."
		args[2] = "Please wait until the current voting is over and try again."
		NetEvents:SendTo('PopupResponse', player, args)
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

-- Region Admin gameAdmin Events Dispatch/ Subscribe
function BetterIngameAdmin:OnGameAdminPlayer(playerName, abilitities)
	self.adminList[playerName] = abilitities
	local player = PlayerManager:GetPlayerByName(playerName)
	if player ~= nil then
		NetEvents:SendTo('AdminPlayer', player, abilitities)
	end
end

function BetterIngameAdmin:OnGameAdminClear()
	for adminName,abilitities in pairs(self.adminList) do
		local admin = PlayerManager:GetPlayerByName(adminName)
		if admin ~= nil then
			NetEvents:SendTo('AdminPlayer', player)
		end
	end
	self.adminList = {}
end
-- Endregion

-- Region Admin actions for players
function BetterIngameAdmin:OnMovePlayer(player, args)
	local messages = {}
	if (self.adminList[player.name] == nil or self.adminList[player.name].canMovePlayers == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	RCON:SendCommand('admin.movePlayer', {t_Player.name, args[2], args[3], "true"})
	RCON:SendCommand('squad.private', {tostring(t_Player.teamId), tostring(t_Player.squadId), "false"})
	if args[4] ~= nil and args[4] ~= "" then
		messages = {}
		messages[1] = "Moved by admin."
		messages[2] = "You got moved by an admin. Reason: ".. args[4]
		NetEvents:SendTo('PopupResponse', targetPlayer, messages)
	else
		-- send confirm to player and message to target
		messages[1] = "Moved by admin."
		messages[2] = "You got moved by an admin."
		NetEvents:SendTo('PopupResponse', targetPlayer, messages)
		messages = {}
		messages[1] = "Move confirmed."
		messages[2] = "You moved the player ".. targetPlayer.name .." successfully."
		NetEvents:SendTo('PopupResponse', player, messages)
	end
end

function BetterIngameAdmin:OnKillPlayer(player, args)
	local messages = {}
	if (self.adminList[player.name] == nil or self.adminList[player.name].canKillPlayers == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	if targetPlayer.alive == true then
		RCON:SendCommand('admin.killPlayer', {targetPlayer.name})
		RCON:SendCommand('admin.say', {"Reason for kill: "..args[2], "player", targetPlayer.name})
	elseif player.corpse ~= nil and player.corpse.isDead == false then
		targetPlayer.corpse:ForceDead()
		RCON:SendCommand('admin.say', {"Reason for kill: "..args[2], "player", targetPlayer.name})
	else
		-- TargetPlayer aready dead.
		messages[1] = "Error."
		messages[2] = "The player".. targetPlayer.name .." is already dead."
		NetEvents:SendTo('PopupResponse', player, messages)
	end
end

function BetterIngameAdmin:OnKickPlayer(player, args)
	local messages = {}
	if (self.adminList[player.name] == nil or self.adminList[player.name].canKickPlayers == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	if args[2]~= nil and args[2] ~= "" then
		targetPlayer:Kick(""..args[2].." (".. player.name..")")
	else
		targetPlayer:Kick("Kicked by ".. player.name.."")
	end
	messages = {}
	messages[1] = "Kick confirmed."
	messages[2] = "You kicked the player ".. targetPlayer.name .." successfully."
	NetEvents:SendTo('PopupResponse', player, messages)
end

function BetterIngameAdmin:OnTBanPlayer(player, args)
	local messages = {}
	if (self.adminList[player.name] == nil or self.adminList[player.name].canTemporaryBanPlayers == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	if args[3]~= nil and args[3] ~= "" then
		targetPlayer:BanTemporarily(args[2]*60, ""..args[3].." (".. player.name..") "..args[2].." minutes")
	else
		targetPlayer:BanTemporarily(args[2]*60, "Temporarily banned by ".. player.name.." for "..args[2].." minutes")
	end
	messages = {}
	messages[1] = "Ban confirmed."
	messages[2] = "You banned the player ".. targetPlayer.name .." successfully for ".. args[2] .." minutes."
	NetEvents:SendTo('PopupResponse', player, messages)
end

function BetterIngameAdmin:OnBanPlayer(player, args)
	local messages = {}
	if (self.adminList[player.name] == nil or self.adminList[player.name].canPermanentlyBanPlayers == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	local targetPlayer = PlayerManager:GetPlayerByName(args[1])
	if targetPlayer == nil then
		-- Player not found.
		messages = {}
		messages[1] = "Error."
		messages[2] = "Sorry, we couldn't find the player."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	if args[2]~= nil and args[2] ~= "" then
		targetPlayer:Ban(""..args[2].." (".. player.name..")")
	else
		targetPlayer:Ban("Banned by ".. player.name.."")
	end
	messages = {}
	messages[1] = "Ban confirmed."
	messages[2] = "You banned the player ".. targetPlayer.name .." successfully."
	NetEvents:SendTo('PopupResponse', player, messages)
end

function BetterIngameAdmin:OnDeleteAdminRights(player, args)
	local messages = {}
	if (self.adminList[player.name] == nil or self.adminList[player.name].canEditGameAdminList == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	RCON:SendCommand('gameAdmin.remove', args)
end

function BetterIngameAdmin:OnDeleteAndSaveAdminRights(player, args)
	local messages = {}
	if (self.adminList[player.name] == nil or self.adminList[player.name].canEditGameAdminList == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	RCON:SendCommand('gameAdmin.remove', args)
	RCON:SendCommand('gameAdmin.save')
end

function BetterIngameAdmin:OnUpdateAdminRights(player, args)
	local messages = {}
	if (self.adminList[player.name] == nil or self.adminList[player.name].canEditGameAdminList == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	RCON:SendCommand('gameAdmin.add', args)
end

function BetterIngameAdmin:OnUpdateAndSaveAdminRights(player, args)
	local messages = {}
	if (self.adminList[player.name] == nil or self.adminList[player.name].canEditGameAdminList == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		messages[1] = "Error."
		messages[2] = "Sorry, you are no admin or at least don't have the required abilitities to do this action."
		NetEvents:SendTo('PopupResponse', player, messages)
		return
	end
	RCON:SendCommand('gameAdmin.add', args)
	RCON:SendCommand('gameAdmin.save')
end

function BetterIngameAdmin:OnGetAdminRightsOfPlayer(player, playerName)
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
	NetEvents:SendTo('AdminRightsOfPlayer', player, self.adminList[targetPlayer.name])
end
-- Endregion

-- Region Player Assist enemy team
function BetterIngameAdmin:OnAssistEnemyTeam(player)
	self:AssistTarget(player, 0)
end

function BetterIngameAdmin:OnQueueAssistEnemyTeam(player)
	local messages = {}
	messages[1] = "Assist Queue."
	messages[2] = "Sorry, we couldn't switch you. We will switch you when it is possible. You are now in the Assist Queue."
	NetEvents:SendTo('PopupResponse', player, messages)
	
	if player.teamId == TeamId.Team1 then
		table.insert(self.queueAssistList1, player.name)
	elseif player.teamId == TeamId.Team2 then
		table.insert(self.queueAssistList2, player.name)
	elseif player.teamId == TeamId.Team3 then
		table.insert(self.queueAssistList3, player.name)
	else
		table.insert(self.queueAssistList4, player.name)
	end
end

function BetterIngameAdmin:OnPlayerLeft(player)
	self:CheckQueueAssist()
end

function BetterIngameAdmin:CheckQueueAssist()
	::continue1::
	if self.queueAssistList1[1] ~= nil then
		local player = PlayerManager:GetPlayerByName(self.queueAssistList1[1])
		if player == nil then
			table.remove(self.queueAssistList1, 1)
			goto continue1
		end
		self:AssistTarget(player, 1)
	end
	::continue2::
	if self.queueAssistList2[1] ~= nil then
		local player = PlayerManager:GetPlayerByName(self.queueAssistList2[1])
		if player == nil then
			table.remove(self.queueAssistList2, 1)
			goto continue2
		end
		self:AssistTarget(player, 2)
	end
	::continue3::
	if self.queueAssistList3[1] ~= nil then
		local player = PlayerManager:GetPlayerByName(self.queueAssistList3[1])
		if player == nil then
			table.remove(self.queueAssistList3, 1)
			goto continue3
		end
		self:AssistTarget(player, 3)
	end
	::continue4::
	if self.queueAssistList4[1] ~= nil then
		local player = PlayerManager:GetPlayerByName(self.queueAssistList4[1])
		if player == nil then
			table.remove(self.queueAssistList4, 1)
			goto continue4
		end
		self:AssistTarget(player, 4)
	end
end

function BetterIngameAdmin:AssistTarget(player, isInQueueList)
	local currentTeamCount = 0
	local enemyTeamCount = 0
	local currentTeamTickets = 0
	local enemyTeamTickets = 0
	local enemyTeam1Count = 0
	local enemyTeam2Count = 0
	local enemyTeam3Count = 0
	local enemyTeam1Tickets = 0
	local enemyTeam2Tickets = 0
	local enemyTeam3Tickets = 0
	local currentTeam = 0
	local enemyTeam1 = 0
	local enemyTeam2 = 0
	local enemyTeam3 = 0
	local gameMode = SharedUtils:GetCurrentGameMode()
	if gameMode ~= "SquadDeathMatch0" then		
		if player.teamId == TeamId.Team1 then
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeamTickets = TicketManager:GetTicketCount(TeamId.Team2)
		else
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeamTickets = TicketManager:GetTicketCount(TeamId.Team1)
		end
		if currentTeamCount > (enemyTeamCount + 1) or (currentTeamTickets >= enemyTeamTickets and currentTeamCount > (enemyTeamCount - 2)) then
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			if player.teamId == TeamId.Team1 then
				player.teamId = TeamId.Team2
			else
				player.teamId = TeamId.Team1
			end
			if isInQueueList == 1 then
				table.remove(self.queueAssistList1, 1)
			elseif isInQueueList == 2 then
				table.remove(self.queueAssistList2, 1)
			end
			local messages = {}
			messages[1] = "Assist Enemy Team."
			messages[2] = "You have been switched due to your assist request."
			NetEvents:SendTo('PopupResponse', player, messages)
		else
			if isInQueueList == 0 then
				self:QuickSwitch(player)
			end
		end
	else
		if player.teamId == TeamId.Team1 then
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			enemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team3)
			enemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team4)
			currentTeam = TeamId.Team1
			enemyTeam1 = TeamId.Team2
			enemyTeam2 = TeamId.Team3
			enemyTeam3 = TeamId.Team4
		elseif player.teamId == TeamId.Team2 then
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			enemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team3)
			enemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team4)
			currentTeam = TeamId.Team2
			enemyTeam1 = TeamId.Team1
			enemyTeam2 = TeamId.Team3
			enemyTeam3 = TeamId.Team4
		elseif player.teamId == TeamId.Team3 then
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			enemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team3)
			enemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team4)
			currentTeam = TeamId.Team3
			enemyTeam1 = TeamId.Team1
			enemyTeam2 = TeamId.Team2
			enemyTeam3 = TeamId.Team4
		else
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			enemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team4)
			enemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team3)
			currentTeam = TeamId.Team4
			enemyTeam1 = TeamId.Team1
			enemyTeam2 = TeamId.Team2
			enemyTeam3 = TeamId.Team3
		end
		if currentTeamCount > (enemyTeam1Count + 1) or (currentTeamTickets >= enemyTeam1Tickets and currentTeamCount > (enemyTeam1Count - 2)) then
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			player.teamId = enemyTeam1
			if isInQueueList == 1 then
				table.remove(self.queueAssistList1, 1)
			elseif isInQueueList == 2 then
				table.remove(self.queueAssistList2, 1)
			elseif isInQueueList == 3 then
				table.remove(self.queueAssistList3, 1)
			elseif isInQueueList == 4 then
				table.remove(self.queueAssistList4, 1)
			end
			local messages = {}
			messages[1] = "Assist Enemy Team."
			messages[2] = "You have been switched due to your assist request."
			NetEvents:SendTo('PopupResponse', player, messages)
		elseif currentTeamCount > (enemyTeam2Count + 1) or (currentTeamTickets >= enemyTeam2Tickets and currentTeamCount > (enemyTeam2Count - 2)) then
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			player.teamId = enemyTeam2
			if isInQueueList == 1 then
				table.remove(self.queueAssistList1, 1)
			elseif isInQueueList == 2 then
				table.remove(self.queueAssistList2, 1)
			elseif isInQueueList == 3 then
				table.remove(self.queueAssistList3, 1)
			elseif isInQueueList == 4 then
				table.remove(self.queueAssistList4, 1)
			end
			local messages = {}
			messages[1] = "Assist Enemy Team."
			messages[2] = "You have been switched due to your assist request."
			NetEvents:SendTo('PopupResponse', player, messages)
		elseif currentTeamCount > (enemyTeam3Count + 1) or (currentTeamTickets >= enemyTeam3Tickets and currentTeamCount > (enemyTeam3Count - 2)) then
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			player.teamId = enemyTeam3
			if isInQueueList == 1 then
				table.remove(self.queueAssistList1, 1)
			elseif isInQueueList == 2 then
				table.remove(self.queueAssistList2, 1)
			elseif isInQueueList == 3 then
				table.remove(self.queueAssistList3, 1)
			elseif isInQueueList == 4 then
				table.remove(self.queueAssistList4, 1)
			end
			local messages = {}
			messages[1] = "Assist Enemy Team."
			messages[2] = "You have been switched due to your assist request."
			NetEvents:SendTo('PopupResponse', player, messages)
		else
			if isInQueueList == 0 then
				self:QuickSwitch(player)
			end
		end
	end
end

function BetterIngameAdmin:QuickSwitch(player)
	local playerTeamId = player.teamId
	local listPlayer = nil
	if player.teamId == TeamId.Team1 then
		::continue2::
		if self.queueAssistList2[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList2[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList2, 1)
				goto continue2
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team1
			player.teamId = TeamId.Team2
			table.remove(self.queueAssistList2, 1)
		end
		::continue3::
		if self.queueAssistList3[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList3[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList3, 1)
				goto continue3
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team1
			player.teamId = TeamId.Team3
			table.remove(self.queueAssistList3, 1)
		end
		::continue4::
		if self.queueAssistList4[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList4[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList4, 1)
				goto continue4
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team1
			player.teamId = TeamId.Team4
			table.remove(self.queueAssistList4, 1)
		end
	elseif player.teamId == TeamId.Team2 then
		::continue1::
		if self.queueAssistList1[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList1[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList1, 1)
				goto continue1
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team2
			player.teamId = TeamId.Team1
			table.remove(self.queueAssistList1, 1)
		end
		::continue3::
		if self.queueAssistList3[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList3[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList3, 1)
				goto continue3
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team2
			player.teamId = TeamId.Team3
			table.remove(self.queueAssistList3, 1)
		end
		::continue4::
		if self.queueAssistList4[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList4[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList4, 1)
				goto continue4
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team2
			player.teamId = TeamId.Team4
			table.remove(self.queueAssistList4, 1)
		end
	elseif player.teamId == TeamId.Team3 then
		::continue1::
		if self.queueAssistList1[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList1[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList1, 1)
				goto continue1
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team3
			player.teamId = TeamId.Team1
			table.remove(self.queueAssistList1, 1)
		end
		::continue2::
		if self.queueAssistList2[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList2[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList2, 1)
				goto continue2
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team3
			player.teamId = TeamId.Team2
			table.remove(self.queueAssistList2, 1)
		end
		::continue4::
		if self.queueAssistList4[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList4[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList4, 1)
				goto continue4
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team3
			player.teamId = TeamId.Team4
			table.remove(self.queueAssistList4, 1)
		end
	else
		::continue1::
		if self.queueAssistList1[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList1[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList1, 1)
				goto continue1
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team4
			player.teamId = TeamId.Team1
			table.remove(self.queueAssistList1, 1)
		end
		::continue2::
		if self.queueAssistList2[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList2[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList2, 1)
				goto continue2
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team4
			player.teamId = TeamId.Team2
			table.remove(self.queueAssistList2, 1)
		end
		::continue3::
		if self.queueAssistList3[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList3[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList3, 1)
				goto continue3
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team4
			player.teamId = TeamId.Team3
			table.remove(self.queueAssistList3, 1)
		end
	end
	if playerTeamId == player.teamId then
		self:OnQueueAssistEnemyTeam(player)
	else
		local messages = {}
		messages[1] = "Assist Enemy Team."
		messages[2] = "You have been switched due to your assist request."
		NetEvents:SendTo('PopupResponse', player, messages)
		messages = {}
		messages[1] = "Assist Enemy Team."
		messages[2] = "You have been switched due to your assist request."
		NetEvents:SendTo('PopupResponse', listPlayer, messages)	
	end
end

function BetterIngameAdmin:OnCancelAssistEnemyTeam(player)
	if player.teamId == 1 then
		for i,listPlayerName in pairs(self.queueAssistList1) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList1, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList2) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList2, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList3) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList3, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList4) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList4, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		-- Error you are in no queue
	elseif player.teamId == 2 then
		for i,listPlayerName in pairs(self.queueAssistList2) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList2, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList1) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList1, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList3) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList3, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList4) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList4, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		-- Error you are in no queue
	elseif player.teamId == 3 then
		for i,listPlayerName in pairs(self.queueAssistList3) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList3, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList1) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList1, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList2) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList2, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList4) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList4, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		-- Error you are in no queue
	elseif player.teamId == 4 then
		for i,listPlayerName in pairs(self.queueAssistList4) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList4, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList1) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList1, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList2) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList2, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList3) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList3, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				return
			end
		end
		-- Error you are in no queue
	end
end
-- Endregion

-- Region Squad stuff
function BetterIngameAdmin:OnLeaveSquad(player)
	player.squadId = SquadId.SquadNone
	local messages = {}
	messages[1] = "Left Squad."
	messages[2] = "You left the squad."
	NetEvents:SendTo('PopupResponse', player, messages)
end

function BetterIngameAdmin:OnCreateSquad(player)
	for i=1,32 do
		if TeamSquadManager:GetSquadPlayerCount(player.teamId, i) == 0 then
			player.squadId = i
			RCON:SendCommand('squad.private', {tostring(player.teamId), tostring(player.squadId), "false"})
			local messages = {}
			messages[1] = "Create Squad."
			messages[2] = "You created a squad with the ID: ".. player.squadId .."."
			NetEvents:SendTo('PopupResponse', player, messages)
			return
		end
	end
end

function BetterIngameAdmin:OnJoinSquad(player, playerName)
	local messages = {}
	local targetPlayer = PlayerManager:GetPlayerByName(playerName)
	if targetPlayer ~= nil then
		if player.teamId == targetPlayer.teamId and targetPlayer.isSquadPrivate == false and tonumber(self.serverConfig[43]) > TeamSquadManager:GetSquadPlayerCount(targetPlayer.teamId, targetPlayer.squadId) then
			player.squadId = targetPlayer.squadId
			messages = {}
			messages[1] = "Squad Joined."
			messages[2] = "You joined the squad with the ID: ".. player.squadId .."."
			NetEvents:SendTo('PopupResponse', player, messages)
		else
			messages = {}
			messages[1] = "Error."
			messages[2] = "You couldn't join the squad with the ID: ".. player.squadId ..". Maybe the squad is full or private."
			NetEvents:SendTo('PopupResponse', player, messages)
		end
	end
end

function BetterIngameAdmin:OnPrivateSquad(player)
	local messages = {}
	if player.isSquadPrivate == false and player.isSquadLeader == true then
		RCON:SendCommand('squad.private', {tostring(player.teamId), tostring(player.squadId), "true"})
		messages = {}
		messages[1] = "Squad private."
		messages[2] = "Your squad with the ID: ".. player.squadId .." is now private."
		NetEvents:SendTo('PopupResponse', player, messages)
	else
		RCON:SendCommand('squad.private', {tostring(player.teamId), tostring(player.squadId), "false"})
		messages = {}
		messages[1] = "Squad not private."
		messages[2] = "Your squad with the ID: ".. player.squadId .." is now NOT private."
		NetEvents:SendTo('PopupResponse', player, messages)
	end
end

function BetterIngameAdmin:OnKickFromSquad(player, playerName)
	local targetPlayer = PlayerManager:GetPlayerByName(playerName)
	if targetPlayer ~= nil and player.isSquadLeader == true then
		targetPlayer.squadId = SquadId.SquadNone
		local messages = {}
		messages[1] = "Player kicked from Squad."
		messages[2] = "You kicked the player ".. targetPlayer.name .." from your squad."
		NetEvents:SendTo('PopupResponse', player, messages)
	end
end

function BetterIngameAdmin:OnMakeSquadLeader(player, playerName)
	local targetPlayer = PlayerManager:GetPlayerByName(playerName)
	if targetPlayer ~= nil and player.isSquadLeader == true then
		RCON:SendCommand('squad.leader', {tostring(targetPlayer.teamId), tostring(targetPlayer.squadId), playerName})
		local messages = {}
		messages[1] = "Player is now Squad Leader."
		messages[2] = "You promoted the player ".. targetPlayer.name .." to your squad leader and demoted yourself to a normal squad member."
		NetEvents:SendTo('PopupResponse', player, messages)
	end
end
-- Endregion

-- Region Admin Map Rotation
function BetterIngameAdmin:OnGetMapRotation()
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

function BetterIngameAdmin:OnSetNextMap(player, mapIndex)
	if (self.adminList[player.name] == nil or self.adminList[player.name].canUseMapFunctions == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		return
	end
	mapIndex = tonumber(mapIndex) - 1
	RCON:SendCommand('mapList.setNextMapIndex', {tostring(mapIndex)})
	self:OnGetMapRotation()
end

function BetterIngameAdmin:OnRunNextRound(player)
	if (self.adminList[player.name] == nil or self.adminList[player.name].canUseMapFunctions == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		return
	end
	RCON:SendCommand('mapList.runNextRound')
end

function BetterIngameAdmin:OnRestartRound(player)
	if (self.adminList[player.name] == nil or self.adminList[player.name].canUseMapFunctions == nil ) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		return
	end
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
	if (self.adminList[player.name] == nil or self.adminList[player.name].canAlterServerSettings == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		return
	end
	RCON:SendCommand('vars.serverName', {args[1]})
	self.serverConfig[1] = args[1]
	RCON:SendCommand('vars.serverDescription', {args[2]})
	self.serverConfig[2] = args[2]
	RCON:SendCommand('vars.serverMessage', {args[3]})
	self.serverConfig[3] = args[3]
	RCON:SendCommand('vars.gamePassword', {args[4]})
	self.serverConfig[4] = args[4]
end
-- Endregion

-- Region Manage Presets
function BetterIngameAdmin:OnManagePresets(player, args)
	if (self.adminList[player.name] == nil or self.adminList[player.name].canAlterServerSettings == nil) and self.owner ~= player.name then
		-- That guy is no admin or doesn't have that ability. That guy is also not the server owner.
		return
	end
	if args[1] == "normal" then
		self:PresetNormal()
	elseif args[1] == "hardcore" then
		self:PresetHardcore()
	elseif args[1] == "infantry" then
		self:PresetInfantry()
	elseif args[1] == "hardcoreNoMap" then
		self:PresetHardcoreNoMap()
	elseif args[1] == "custom" then
		self:PresetCustom(args)
	end
	NetEvents:Broadcast('ServerInfo', self.serverConfig)
	local messages = {}
	messages[1] = "Changed server settings."
	messages[2] = "You successfully changed the server settings."
	NetEvents:SendTo('PopupResponse', player, messages)
end
function BetterIngameAdmin:PresetNormal()
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
function BetterIngameAdmin:PresetHardcore()
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
function BetterIngameAdmin:PresetInfantry()
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
function BetterIngameAdmin:PresetHardcoreNoMap()
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
function BetterIngameAdmin:PresetCustom(args)
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
	self.playerStartedVoteCounter = {}
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
		NetEvents:SendTo('ServerOwnerRights', player)
		NetEvents:SendTo('QuickServerSetup', player)
	elseif player.name == self.owner then
		NetEvents:SendTo('ServerOwnerRights', player)
	end
	
	NetEvents:SendTo('Info', player, {self.serverName, self.serverDescription, self.bannerUrl})
	
	if self.adminList[player.name] ~= nil then
		NetEvents:SendTo('AdminPlayer', player, self.adminList[player.name])
	end
	
	NetEvents:SendTo('ServerInfo', player, self.serverConfig)
	
	self:CheckQueueAssist()
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
--[[
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
end]]
-- Endregion
g_BetterIngameAdmin = BetterIngameAdmin()
