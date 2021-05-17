class 'Voting'

local m_ModSettings = require('ModSettings')
local m_GameAdmin = require('GameAdmin')
local m_ServerOwner = require('ServerOwner')

function Voting:__init()
	self.m_VoteInProgress = false
	self.m_TypeOfVote = ""
	self.m_PlayersVotedYes = {}
	self.m_PlayersVotedNo = {}
	self.m_PlayersVotedYesCount = 0
	self.m_PlayersVotedNoCount = 0
	self.m_PlayerToVote = nil
	self.m_PlayerToVoteAccountGuid = nil
	self.m_PlayerStartedVoteCounter = {}

	self.m_CumulatedTime = 0

	self.m_CooldownIsRunning = false
	self.m_CumulatedCooldownTime = 0

	-- use reservedSlotsList for admin protection as soon as this get implemented
	NetEvents:Subscribe('VotekickPlayer', self, self.OnVotekickPlayer)
	NetEvents:Subscribe('VotebanPlayer', self, self.OnVotebanPlayer)
	NetEvents:Subscribe('Surrender', self, self.OnSurrender)
	NetEvents:Subscribe('CheckVoteYes', self, self.OnCheckVoteYes)
	NetEvents:Subscribe('CheckVoteNo', self, self.OnCheckVoteNo)
end

function Voting:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	if self.m_VoteInProgress == true then
		self.m_CumulatedTime = self.m_CumulatedTime + p_DeltaTime
		if self.m_CumulatedTime >= m_ModSettings:GetVoteDuration() + 1 then
			self:EndVote()
		end
	end
	if self.m_CooldownIsRunning == true then
		self.m_CumulatedCooldownTime = self.m_CumulatedCooldownTime + p_DeltaTime
		if m_ModSettings:GetCooldownBetweenVotes() <= self.m_CumulatedCooldownTime then
			self.m_CumulatedCooldownTime = 0
			self.m_CooldownIsRunning = false
		end
	end
end

function Voting:EndVote()
	if self.m_PlayersVotedYesCount > self.m_PlayersVotedNoCount and self.m_PlayersVotedYesCount >= 4 then
		if (self.m_PlayersVotedYesCount + self.m_PlayersVotedNoCount) >= (TeamSquadManager:GetTeamPlayerCount(TeamId.Team1) * self.m_VotingParticipationNeeded / 100) and self.m_TypeOfVote == "surrenderUS" then
			local s_Args = {"2"}
			RCON:SendCommand('mapList.endround', s_Args)
			print("VOTE SURRENDER: Success - The US team surrenders. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
		elseif (self.m_PlayersVotedYesCount + self.m_PlayersVotedNoCount) >= (TeamSquadManager:GetTeamPlayerCount(TeamId.Team2) * self.m_VotingParticipationNeeded / 100) and self.m_TypeOfVote == "surrenderRU" then
			local s_Args = {"1"}
			RCON:SendCommand('mapList.endround', s_Args)
			print("VOTE SURRENDER: Success - The RU team surrenders. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
		elseif (self.m_PlayersVotedYesCount + self.m_PlayersVotedNoCount) >= (PlayerManager:GetPlayerCount() * self.m_VotingParticipationNeeded / 100) then
			if (self.m_TypeOfVote == "votekick" or self.m_TypeOfVote == "voteban") and self.m_PlayerToVote ~= nil then
				local votedPlayer = PlayerManager:GetPlayerByName(self.m_PlayerToVote)
				if self.m_TypeOfVote == "votekick" and votedPlayer ~= nil then
					votedPlayer:Kick("Votekick")
					print("VOTEKICK: Success - The Player " .. self.m_PlayerToVote .. " got kicked. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
				elseif self.m_TypeOfVote == "voteban" then
					RCON:SendCommand('banList.add', {"guid", tostring(self.m_PlayerToVoteAccountGuid), "seconds", "86400", "Voteban: 24 hours"})
					print("VOTEBAN: Success - The Player " .. self.m_PlayerToVote .. " got banned for 24 hours. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
				end
			end
		else
			if self.m_TypeOfVote == "votekick" then
				print("VOTEKICK: Failed - Not enough players voted. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
			elseif self.m_TypeOfVote == "voteban" then
				print("VOTEBAN: Failed - Not enough players voted. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
			elseif self.m_TypeOfVote == "surrenderRU" then
				print("VOTE SURRENDER RU: Failed - Not enough players voted. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
			elseif self.m_TypeOfVote == "surrenderUS" then
				print("VOTE SURRENDER US: Failed - Not enough players voted. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
			end
		end
	else
		if self.m_TypeOfVote == "votekick" then
			print("VOTEKICK: Failed - Not enough players voted with yes. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
		elseif self.m_TypeOfVote == "voteban" then
			print("VOTEBAN: Failed - Not enough players voted with yes. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
		elseif self.m_TypeOfVote == "surrenderRU" then
			print("VOTE SURRENDER RU: Failed - Not enough players voted with yes. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
		elseif self.m_TypeOfVote == "surrenderUS" then
			print("VOTE SURRENDER US: Failed - Not enough players voted with yes. RESULT - YES: " .. self.m_PlayersVotedYesCount .. " Players | NO: " .. self.m_PlayersVotedNoCount .. " Players.")
		end
	end
	self.m_PlayersVotedYesCount = 0
	self.m_PlayersVotedNoCount = 0
	self.m_PlayersVotedYes = {}
	self.m_PlayersVotedNo = {}
	self.m_PlayerToVote = nil
	self.m_PlayerToVoteAccountGuid = nil
	self.m_VoteInProgress = false
	self.m_CumulatedTime = 0
	self.m_TypeOfVote = ""
	self.m_CooldownIsRunning = true
end

function Voting:OnVotekickPlayer(p_Player, p_VotekickPlayer)
	if self.m_CooldownIsRunning == true then
		local s_Args = {}
		s_Args[1] = "Cooldown is running."
		s_Args[2] = "Please wait ".. math.floor(self.m_CooldownBetweenVotes - self.m_CumulatedCooldownTime) .." seconds and try again."
		NetEvents:SendTo('PopupResponse', p_Player, s_Args)
		return
	end
	if self.m_VoteInProgress == false then
		self.m_PlayerToVote = nil
		if PlayerManager:GetPlayerByName(p_VotekickPlayer) ~= nil then
			self.m_PlayerToVote = PlayerManager:GetPlayerByName(p_VotekickPlayer).name
			if m_GameAdmin:CanKickPlayers(self.m_PlayerToVote) then
				-- That guy is admin and can Kick. So he is protected.
				local s_Args = {}
				s_Args[1] = "This player is protected."
				s_Args[2] = "The player ".. p_VotekickPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', p_Player, s_Args)
				print("VOTEKICK: Protection - Player " .. p_Player.name .. " tried to votekick Admin " .. p_VotekickPlayer)
				return
			elseif m_ServerOwner:IsOwner(self.m_PlayerToVote) then
				-- That guy is the server owner. So he is protected.
				local s_Args = {}
				s_Args[1] = "This player is protected."
				s_Args[2] = "The player ".. p_VotekickPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', p_Player, s_Args)
				print("VOTEKICK: Protection - Player " .. p_Player.name .. " tried to votekick Owner " .. p_VotekickPlayer)
				return
			end
			if self.m_PlayerStartedVoteCounter[p_Player.name] == nil then
				self.m_PlayerStartedVoteCounter[p_Player.name] = 0
			end
			if self.m_PlayerStartedVoteCounter[p_Player.name] < m_ModSettings:GetMaxVotingStartsPerPlayer() then
				self.m_PlayerStartedVoteCounter[p_Player.name] = self.m_PlayerStartedVoteCounter[p_Player.name] + 1
				NetEvents:Broadcast('Start:VotekickPlayer', p_VotekickPlayer)
				table.insert(self.m_PlayersVotedYes, p_Player.name)
				self.m_PlayersVotedYesCount = self.m_PlayersVotedYesCount + 1
				self.m_VoteInProgress = true
				self.m_TypeOfVote = "votekick"
				ChatManager:SendMessage(p_Player.name .. " started a votekick on " .. self.m_PlayerToVote)
				print("VOTEKICK: Started - Player " .. p_Player.name .. " started votekick on Player " .. p_VotekickPlayer)
				if self.m_PlayerStartedVoteCounter[p_Player.name] == m_ModSettings:GetMaxVotingStartsPerPlayer() then
					NetEvents:SendTo('HideVoteButtons', p_Player)
				end
			else
				local s_Args = {}
				s_Args[1] = "Votelimit reached."
				s_Args[2] = "You reached the maximum amount of votes for this round."
				NetEvents:SendTo('PopupResponse', p_Player, s_Args)
			end
		end
	else
		local s_Args = {}
		s_Args[1] = "Vote in progress."
		s_Args[2] = "Please wait until the current voting is over and try again."
		NetEvents:SendTo('PopupResponse', p_Player, s_Args)
	end
end

function Voting:OnVotebanPlayer(p_Player, p_VotebanPlayer)
	if self.m_CooldownIsRunning == true then
		local s_Args = {}
		s_Args[1] = "Cooldown is running."
		s_Args[2] = "Please wait ".. self.m_CooldownBetweenVotes - self.m_CumulatedCooldownTime .." seconds and try again."
		NetEvents:SendTo('PopupResponse', p_Player, s_Args)
		return
	end
	if self.m_VoteInProgress == false then
		if PlayerManager:GetPlayerByName(p_VotebanPlayer) ~= nil then
			self.m_PlayerToVote = PlayerManager:GetPlayerByName(p_VotebanPlayer).name
			self.m_PlayerToVoteAccountGuid = PlayerManager:GetPlayerByName(p_VotebanPlayer).accountGuid
			if m_GameAdmin:CanKickPlayers(self.m_PlayerToVote) then
				-- That guy is admin and can Kick. So he is protected.
				local s_Args = {}
				s_Args[1] = "This player is protected."
				s_Args[2] = "The player ".. p_VotebanPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', p_Player, s_Args)
				print("VOTEBAN: Protection - Player " .. p_Player.name .. " tried to voteban Admin " .. p_VotebanPlayer)
				return
			elseif m_ServerOwner:IsOwner(self.m_PlayerToVote) then
				-- That guy is the server owner. So he is protected.
				local s_Args = {}
				s_Args[1] = "This player is protected."
				s_Args[2] = "The player ".. p_VotebanPlayer .." is protected and can not be voted off."
				NetEvents:SendTo('PopupResponse', p_Player, s_Args)
				print("VOTEBAN: Protection - Player " .. p_Player.name .. " tried to voteban Owner " .. p_VotebanPlayer)
				return
			end
			if self.m_PlayerStartedVoteCounter[p_Player.name] == nil then
				self.m_PlayerStartedVoteCounter[p_Player.name] = 0
			end
			if self.m_PlayerStartedVoteCounter[p_Player.name] < m_ModSettings:GetMaxVotingStartsPerPlayer() then
				self.m_PlayerStartedVoteCounter[p_Player.name] = self.m_PlayerStartedVoteCounter[p_Player.name] + 1
				NetEvents:Broadcast('Start:VotebanPlayer', p_VotebanPlayer)
				table.insert(self.m_PlayersVotedYes, p_Player.name)
				self.m_PlayersVotedYesCount = self.m_PlayersVotedYesCount + 1
				self.m_VoteInProgress = true
				self.m_TypeOfVote = "voteban"
				ChatManager:SendMessage(p_Player.name .. " started a voteban on " .. self.m_PlayerToVote)
				print("VOTEBAN: Started - Player " .. p_Player.name .. " started voteban on Player " .. p_VotebanPlayer)
				if self.m_PlayerStartedVoteCounter[p_Player.name] == m_ModSettings:GetMaxVotingStartsPerPlayer() then
					NetEvents:SendTo('HideVoteButtons', p_Player)
				end
			else
				local s_Args = {}
				s_Args[1] = "Votelimit reached."
				s_Args[2] = "You reached the maximum amount of votes for this round."
				NetEvents:SendTo('PopupResponse', p_Player, s_Args)
			end
		end
	else
		local s_Args = {}
		s_Args[1] = "Vote in progress."
		s_Args[2] = "Please wait until the current voting is over and try again."
		NetEvents:SendTo('PopupResponse', p_Player, s_Args)
	end
end

function Voting:OnSurrender(p_Player)
	if self.m_CooldownIsRunning == true then
		local s_Args = {}
		s_Args[1] = "Cooldown is running."
		s_Args[2] = "Please wait ".. self.m_CooldownBetweenVotes - self.m_CumulatedCooldownTime .." seconds and try again."
		NetEvents:SendTo('PopupResponse', p_Player, s_Args)
		return
	end
	if self.m_VoteInProgress == false then
		if p_Player.teamId == TeamId.Team1 then
			self.m_TypeOfVote = "surrenderUS"
		else
			self.m_TypeOfVote = "surrenderRU"
		end
		if self.m_PlayerStartedVoteCounter[p_Player.name] == nil then
			self.m_PlayerStartedVoteCounter[p_Player.name] = 0
		end
		if self.m_PlayerStartedVoteCounter[p_Player.name] < m_ModSettings:GetMaxVotingStartsPerPlayer() then
			NetEvents:Broadcast('Start:Surrender', self.m_TypeOfVote)
			table.insert(self.m_PlayersVotedYes, p_Player.name)
			self.m_PlayersVotedYesCount = self.m_PlayersVotedYesCount + 1
			self.m_VoteInProgress = true
			ChatManager:SendMessage(p_Player.name .. " started a surrender voting")
			print("VOTE SURRENDER: Started - Player " .. p_Player.name .. " started a surrender voting for the team " .. p_Player.teamId)
			if self.m_PlayerStartedVoteCounter[p_Player.name] == m_ModSettings:GetMaxVotingStartsPerPlayer() then
				NetEvents:SendTo('HideVoteButtons', p_Player)
			end
		else
			local s_Args = {}
			s_Args[1] = "Votelimit reached."
			s_Args[2] = "You reached the maximum amount of votes for this round."
			NetEvents:SendTo('PopupResponse', p_Player, s_Args)
		end
	else
		local s_Args = {}
		s_Args[1] = "Vote in progress."
		s_Args[2] = "Please wait until the current voting is over and try again."
		NetEvents:SendTo('PopupResponse', p_Player, s_Args)
	end
end

function Voting:OnCheckVoteYes(p_Player)
	for i, l_PlayerName in pairs(self.m_PlayersVotedYes) do
		if l_PlayerName == p_Player.name then
			return
		end
	end
	for i, l_PlayerName in pairs(self.m_PlayersVotedNo) do
		if l_PlayerName == p_Player.name then
			table.remove(self.m_PlayersVotedNo, i)
			self.m_PlayersVotedNoCount = self.m_PlayersVotedNoCount - 1
			NetEvents:Broadcast('Remove:OneNoVote')
		end
	end
	table.insert(self.m_PlayersVotedYes, p_Player.name)
	self.m_PlayersVotedYesCount = self.m_PlayersVotedYesCount + 1
	NetEvents:Broadcast('Vote:Yes')
end

function Voting:OnCheckVoteNo(p_Player)
	for i, l_PlayerName in pairs(self.m_PlayersVotedNo) do
		if l_PlayerName == p_Player.name then
			return
		end
	end
	for i, l_PlayerName in pairs(self.m_PlayersVotedYes) do
		if l_PlayerName == p_Player.name then
			table.remove(self.m_PlayersVotedYes, i)
			self.m_PlayersVotedYesCount = self.m_PlayersVotedYesCount - 1
			NetEvents:Broadcast('Remove:OneYesVote')
		end
	end
	table.insert(self.m_PlayersVotedNo, p_Player.name)
	self.m_PlayersVotedNoCount = self.m_PlayersVotedNoCount + 1
	NetEvents:Broadcast('Vote:No')
end

function Voting:OnLevelDestroy()
	self.m_PlayerStartedVoteCounter = {}
end

if g_Voting == nil then
	g_Voting = Voting()
end

return g_Voting
