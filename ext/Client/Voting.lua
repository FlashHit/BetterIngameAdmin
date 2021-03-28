class 'Voting'

function Voting:__init()
	self.voteInProgress = false
	self.cumulatedTime = 0
    self.count = 1
    
	self.voteDuration = 30
	self.cooldownBetweenVotes = 0
	self.maxVotingStartsPerPlayer = 3
    self.votingParticipationNeeded = 50
    
    Events:Subscribe('WebUI:VotekickPlayer', self, self.OnWebUIVotekickPlayer)
	Events:Subscribe('WebUI:VotebanPlayer', self, self.OnWebUIVotebanPlayer)
	Events:Subscribe('WebUI:Surrender', self, self.OnWebUISurrender)
	NetEvents:Subscribe('Start:VotekickPlayer', self, self.OnStartVotekickPlayer)
	NetEvents:Subscribe('Start:VotebanPlayer', self, self.OnStartVotebanPlayer)
	NetEvents:Subscribe('Start:Surrender', self, self.OnStartSurrender)
	NetEvents:Subscribe('Remove:OneYesVote', self, self.OnRemoveOneYesVote)
	NetEvents:Subscribe('Remove:OneNoVote', self, self.OnRemoveOneNoVote)
	NetEvents:Subscribe('Vote:Yes', self, self.OnVoteYes)
	NetEvents:Subscribe('Vote:No', self, self.OnVoteNo)
		-- when trying to start a new vote but a vote is in progress, send him an error "A vote is already in progress"
		-- I think this one is missing in WebUI, so atm this does nothing
	NetEvents:Subscribe('VoteInProgress', self, self.OnVoteInProgress)
end

function Voting:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
    if self.voteInProgress == true then
		if InputManager:WentKeyDown(InputDeviceKeys.IDK_F8) then
			NetEvents:Send('CheckVoteYes')
			WebUI:ExecuteJS(string.format("fontWeightYes()"))
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_F9) then
			NetEvents:Send('CheckVoteNo')
			WebUI:ExecuteJS(string.format("fontWeightNo()"))
		end
		self.cumulatedTime = self.cumulatedTime + p_DeltaTime
		if self.cumulatedTime >= self.count and self.count <= self.voteDuration + 1 then
			self.count = self.count + 1
			if self.count >= self.voteDuration + 1 then
				self.voteInProgress = false
				self.cumulatedTime = 0
				self.count = 1
			end
			WebUI:ExecuteJS(string.format("updateTimer()"))
		end
	end
end

function Voting:OnWebUIVotekickPlayer(playerName)
	NetEvents:Send('VotekickPlayer', playerName)
end

function Voting:OnWebUIVotebanPlayer(playerName)
	NetEvents:Send('VotebanPlayer', playerName)
end

function Voting:OnWebUISurrender()
	NetEvents:Send('Surrender')
end

function Voting:OnStartVotekickPlayer(votekickPlayer)
	self.voteInProgress = true
	local args = {votekickPlayer, self.voteDuration}
	WebUI:ExecuteJS(string.format("startvotekick(%s)", json.encode(args)))
end

function Voting:OnStartVotebanPlayer(votebanPlayer)
	self.voteInProgress = true
	local args = {votebanPlayer, self.voteDuration}
	WebUI:ExecuteJS(string.format("startvoteban(%s)", json.encode(args)))
end

function Voting:OnStartSurrender(typeOfVote)
	self.voteInProgress = true
	local player = PlayerManager:GetLocalPlayer()
	if typeOfVote == "surrenderUS" then
		if player.teamId == TeamId.Team1 then
			WebUI:ExecuteJS("startsurrender()")
		end
	elseif typeOfVote == "surrenderRU" then
		if player.teamId == TeamId.Team2 then
			WebUI:ExecuteJS("startsurrender()")
		end
	end
end

function Voting:OnRemoveOneYesVote()
	WebUI:ExecuteJS("removeOneYesVote()")
end

function Voting:OnRemoveOneNoVote()
	WebUI:ExecuteJS("removeOneNoVote()")
end

function Voting:OnVoteYes()
	WebUI:ExecuteJS(string.format("voteYes()"))
end

function Voting:OnVoteNo()
	WebUI:ExecuteJS(string.format("voteNo()"))
end

function Voting:OnVoteInProgress()
	WebUI:ExecuteJS(string.format("voteInProgress()"))
end

function Voting:SetSettings(p_VoteDuration, p_CooldownBetweenVotes, p_MaxVotingStartsPerPlayer, P_VotingParticipationNeeded)
	self.voteDuration = p_VoteDuration
	self.cooldownBetweenVotes = p_CooldownBetweenVotes
	self.maxVotingStartsPerPlayer = p_MaxVotingStartsPerPlayer
	self.votingParticipationNeeded = P_VotingParticipationNeeded
end

return Voting