class 'Voting'

function Voting:__init()
	self.m_VoteInProgress = false
	self.m_CumulatedTime = 0
	self.m_Count = 1

	self.m_VoteDuration = 30
	self.m_CooldownBetweenVotes = 0
	self.m_MaxVotingStartsPerPlayer = 3
	self.m_VotingParticipationNeeded = 50

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
	if self.m_VoteInProgress == true then
		if InputManager:WentKeyDown(InputDeviceKeys.IDK_F8) then
			NetEvents:Send('CheckVoteYes')
			WebUI:ExecuteJS(string.format("fontWeightYes()"))
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_F9) then
			NetEvents:Send('CheckVoteNo')
			WebUI:ExecuteJS(string.format("fontWeightNo()"))
		end
		self.m_CumulatedTime = self.m_CumulatedTime + p_DeltaTime
		if self.m_CumulatedTime >= self.m_Count and self.m_Count <= self.m_VoteDuration + 1 then
			self.m_Count = self.m_Count + 1
			if self.m_Count >= self.m_VoteDuration + 1 then
				self.m_VoteInProgress = false
				self.m_CumulatedTime = 0
				self.m_Count = 1
			end
			WebUI:ExecuteJS(string.format("updateTimer()"))
		end
	end
end

function Voting:OnWebUIVotekickPlayer(p_PlayerName)
	NetEvents:Send('VotekickPlayer', p_PlayerName)
end

function Voting:OnWebUIVotebanPlayer(p_PlayerName)
	NetEvents:Send('VotebanPlayer', p_PlayerName)
end

function Voting:OnWebUISurrender()
	NetEvents:Send('Surrender')
end

function Voting:OnStartVotekickPlayer(p_VotekickPlayer)
	self.m_VoteInProgress = true
	local s_Args = {p_VotekickPlayer, self.m_VoteDuration}
	WebUI:ExecuteJS(string.format("startvotekick(%s)", json.encode(s_Args)))
end

function Voting:OnStartVotebanPlayer(p_VotebanPlayer)
	self.m_VoteInProgress = true
	local s_Args = {p_VotebanPlayer, self.m_VoteDuration}
	WebUI:ExecuteJS(string.format("startvoteban(%s)", json.encode(s_Args)))
end

function Voting:OnStartSurrender(p_TypeOfVote)
	self.m_VoteInProgress = true
	local s_Player = PlayerManager:GetLocalPlayer()
	if p_TypeOfVote == "surrenderUS" then
		if s_Player.teamId == TeamId.Team1 then
			WebUI:ExecuteJS("startsurrender()")
		end
	elseif p_TypeOfVote == "surrenderRU" then
		if s_Player.teamId == TeamId.Team2 then
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
	self.m_VoteDuration = p_VoteDuration
	self.m_CooldownBetweenVotes = p_CooldownBetweenVotes
	self.m_MaxVotingStartsPerPlayer = p_MaxVotingStartsPerPlayer
	self.m_VotingParticipationNeeded = P_VotingParticipationNeeded
end

if g_Voting == nil then
	g_Voting = Voting()
end

return g_Voting
