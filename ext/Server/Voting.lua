class 'Voting'

function Voting:__init(p_GameAdmin, p_ModSettings)
    self.m_GameAdmin = p_GameAdmin
    self.m_ModSettings = p_ModSettings

    self.voteInProgress = false
	self.typeOfVote = ""
	self.playersVotedYes = {}
	self.playersVotedNo = {}
	self.playersVotedYesCount = 0
	self.playersVotedNoCount = 0
	self.playerToVote = nil
	self.playerToVoteAccountGuid = nil
	self.playerStartedVoteCounter = {}
		
	self.cumulatedTime = 0
	
	self.cooldownIsRunning = false
	self.cumulatedCooldownTime = 0
    
	-- use reservedSlotsList for admin protection as soon as this get implemented
    NetEvents:Subscribe('VotekickPlayer', self, self.OnVotekickPlayer)
    NetEvents:Subscribe('VotebanPlayer', self, self.OnVotebanPlayer)
	NetEvents:Subscribe('Surrender', self, self.OnSurrender)
	NetEvents:Subscribe('CheckVoteYes', self, self.OnCheckVoteYes)
	NetEvents:Subscribe('CheckVoteNo', self, self.OnCheckVoteNo)
end

function Voting:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	if self.voteInProgress == true then
		self.cumulatedTime = self.cumulatedTime + p_DeltaTime
		if self.cumulatedTime >= self.m_ModSettings.voteDuration + 1 then
			self:EndVote()
		end
	end
	if self.cooldownIsRunning == true then
		self.cumulatedCooldownTime = self.cumulatedCooldownTime + p_DeltaTime
		if self.m_ModSettings.cooldownBetweenVotes <= self.cumulatedCooldownTime then
			self.cumulatedCooldownTime = 0
			self.cooldownIsRunning = false
		end
    end
end

function Voting:EndVote()
	if self.playersVotedYesCount > self.playersVotedNoCount and self.playersVotedYesCount >= 4 then
		if (self.playersVotedYesCount + self.playersVotedNoCount) >= (TeamSquadManager:GetTeamPlayerCount(TeamId.Team1) * self.votingParticipationNeeded / 100) and self.typeOfVote == "surrenderUS" then
			args = {"2"}
			RCON:SendCommand('mapList.endround', args)
			print("VOTE SURRENDER: Success - The US team surrenders. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
		elseif (self.playersVotedYesCount + self.playersVotedNoCount) >= (TeamSquadManager:GetTeamPlayerCount(TeamId.Team2) * self.votingParticipationNeeded / 100) and self.typeOfVote == "surrenderRU" then
			args = {"1"}
			RCON:SendCommand('mapList.endround', args)
			print("VOTE SURRENDER: Success - The RU team surrenders. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
		elseif (self.playersVotedYesCount + self.playersVotedNoCount) >= (PlayerManager:GetPlayerCount()  * self.votingParticipationNeeded / 100) then
			if (self.typeOfVote == "votekick" or self.typeOfVote == "voteban") and self.playerToVote ~= nil then
				local votedPlayer = PlayerManager:GetPlayerByName(self.playerToVote)
				if self.typeOfVote == "votekick" and votedPlayer ~= nil then
					votedPlayer:Kick("Votekick")
					print("VOTEKICK: Success - The Player " .. self.playerToVote .. " got kicked. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
				elseif self.typeOfVote == "voteban" then
					RCON:SendCommand('banList.add', {"guid", tostring(self.playerToVoteAccountGuid), "seconds", "86400", "Voteban: 24 hours"})
					print("VOTEBAN: Success - The Player " .. self.playerToVote .. " got banned for 24 hours. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
				end
			end
		else
			if self.typeOfVote == "votekick" then
				print("VOTEKICK: Failed - Not enough players voted. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
			elseif self.typeOfVote == "voteban" then
				print("VOTEBAN: Failed - Not enough players voted. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
			elseif self.typeOfVote == "surrenderRU" then
				print("VOTE SURRENDER RU: Failed - Not enough players voted. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
			elseif self.typeOfVote == "surrenderUS" then
				print("VOTE SURRENDER US: Failed - Not enough players voted. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
			end
		end
	else
		if self.typeOfVote == "votekick" then
			print("VOTEKICK: Failed - Not enough players voted with yes. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
		elseif self.typeOfVote == "voteban" then
			print("VOTEBAN: Failed - Not enough players voted with yes. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
		elseif self.typeOfVote == "surrenderRU" then
			print("VOTE SURRENDER RU: Failed - Not enough players voted with yes. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
		elseif self.typeOfVote == "surrenderUS" then
			print("VOTE SURRENDER US: Failed - Not enough players voted with yes. RESULT - YES: " .. self.playersVotedYesCount .. " Players | NO: " .. self.playersVotedNoCount .. " Players.")
		end
	end
	self.playersVotedYesCount = 0
	self.playersVotedNoCount = 0
	self.playersVotedYes = {}
	self.playersVotedNo = {}
	self.playerToVote = nil
	self.playerToVoteAccountGuid = nil
	self.voteInProgress = false
	self.cumulatedTime = 0
	self.typeOfVote = ""
	self.cooldownIsRunning = true
end

function Voting:OnVotekickPlayer(player, votekickPlayer)
	if self.cooldownIsRunning == true then
		local args = {}
		args[1] = "Cooldown is running."
		args[2] = "Please wait ".. math.floor(self.cooldownBetweenVotes - self.cumulatedCooldownTime)  .." seconds and try again."
		NetEvents:SendTo('PopupResponse', player, args)
		return
	end	
	if self.voteInProgress == false then
		self.playerToVote = nil
		if PlayerManager:GetPlayerByName(votekickPlayer) ~= nil then
			self.playerToVote = PlayerManager:GetPlayerByName(votekickPlayer).name 
			if self.m_GameAdmin:CanKickPlayers(self.playerToVote) then
				-- That guy is admin and can Kick. So he is protected.
				local args = {}
				args[1] = "This player is protected."
				args[2] = "The player ".. votekickPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', player, args)
				print("VOTEKICK: Protection - Player " .. player.name .. " tried to votekick Admin " .. votekickPlayer)
				return
			elseif self.owner == self.playerToVote then
				-- That guy is the server owner. So he is protected.
				local args = {}
				args[1] = "This player is protected."
				args[2] = "The player ".. votekickPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', player, args)
				print("VOTEKICK: Protection - Player " .. player.name .. " tried to votekick Owner " .. votekickPlayer)
				return
			end
			if self.playerStartedVoteCounter[player.name] == nil then
				self.playerStartedVoteCounter[player.name] = 0
			end
			if self.playerStartedVoteCounter[player.name] < self.m_ModSettings.maxVotingStartsPerPlayer then
				self.playerStartedVoteCounter[player.name] = self.playerStartedVoteCounter[player.name] + 1
				NetEvents:Broadcast('Start:VotekickPlayer', votekickPlayer)
				table.insert(self.playersVotedYes, player.name)
				self.playersVotedYesCount = self.playersVotedYesCount + 1
				self.voteInProgress = true
				self.typeOfVote = "votekick"
				ChatManager:SendMessage(player.name .. " started a votekick on " .. self.playerToVote)
				print("VOTEKICK: Started - Player " .. player.name .. " started votekick on Player " .. votekickPlayer)
				if self.playerStartedVoteCounter[player.name] == self.m_ModSettings.maxVotingStartsPerPlayer then	
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

function Voting:OnVotebanPlayer(player, votebanPlayer)
	if self.cooldownIsRunning == true then
		local args = {}
		args[1] = "Cooldown is running."
		args[2] = "Please wait ".. self.cooldownBetweenVotes - self.cumulatedCooldownTime  .." seconds and try again."
		NetEvents:SendTo('PopupResponse', player, args)
		return
	end	
	if self.voteInProgress == false then
		if PlayerManager:GetPlayerByName(votebanPlayer) ~= nil then
			self.playerToVote = PlayerManager:GetPlayerByName(votebanPlayer).name
			self.playerToVoteAccountGuid = PlayerManager:GetPlayerByName(votebanPlayer).accountGuid
			if self.m_GameAdmin:CanKickPlayers(self.playerToVote) then
				-- That guy is admin and can Kick. So he is protected.
				local args = {}
				args[1] = "This player is protected."
				args[2] = "The player ".. votebanPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', player, args)
				print("VOTEBAN: Protection - Player " .. player.name .. " tried to voteban Admin " .. votebanPlayer)
				return
			elseif self.owner == self.playerToVote then
				-- That guy is the server owner. So he is protected.
				local args = {}
				args[1] = "This player is protected."
				args[2] = "The player ".. votebanPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', player, args)
				print("VOTEBAN: Protection - Player " .. player.name .. " tried to voteban Owner " .. votebanPlayer)
				return
			end
			if self.playerStartedVoteCounter[player.name] == nil then
				self.playerStartedVoteCounter[player.name] = 0
			end
			if self.playerStartedVoteCounter[player.name] < self.m_ModSettings.maxVotingStartsPerPlayer then
				self.playerStartedVoteCounter[player.name] = self.playerStartedVoteCounter[player.name] + 1
				NetEvents:Broadcast('Start:VotebanPlayer', votebanPlayer)
				table.insert(self.playersVotedYes, player.name)
				self.playersVotedYesCount = self.playersVotedYesCount + 1
				self.voteInProgress = true
				self.typeOfVote = "voteban"
				ChatManager:SendMessage(player.name .. " started a voteban on " .. self.playerToVote)
				print("VOTEBAN: Started - Player " .. player.name .. " started voteban on Player " .. votebanPlayer)
				if self.playerStartedVoteCounter[player.name] == self.m_ModSettings.maxVotingStartsPerPlayer then	
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

function Voting:OnSurrender(player)
	if self.cooldownIsRunning == true then
		local args = {}
		args[1] = "Cooldown is running."
		args[2] = "Please wait ".. self.cooldownBetweenVotes - self.cumulatedCooldownTime  .." seconds and try again."
		NetEvents:SendTo('PopupResponse', player, args)
		return
	end	
	if self.voteInProgress == false then
		if player.teamId == TeamId.Team1 then
			self.typeOfVote = "surrenderUS"
		else
			self.typeOfVote = "surrenderRU"
		end
		if self.playerStartedVoteCounter[player.name] == nil then
			self.playerStartedVoteCounter[player.name] = 0
		end
		if self.playerStartedVoteCounter[player.name] < self.m_ModSettings.maxVotingStartsPerPlayer then
			NetEvents:Broadcast('Start:Surrender', self.typeOfVote)
			table.insert(self.playersVotedYes, player.name)
			self.playersVotedYesCount = self.playersVotedYesCount + 1
			self.voteInProgress = true
			ChatManager:SendMessage(player.name .. " started a surrender voting")
			print("VOTE SURRENDER: Started - Player " .. player.name .. " started a surrender voting for the team " .. player.teamId)
			if self.playerStartedVoteCounter[player.name] == self.m_ModSettings.maxVotingStartsPerPlayer then	
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

function Voting:OnCheckVoteYes(player)
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

function Voting:OnCheckVoteNo(player)
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

function Voting:OnLevelDestroy()
	self.playerStartedVoteCounter = {}
end

return Voting