class 'ModSettings'

function ModSettings:__init()
	self.m_LoadedModSettings = false
	self.m_ShowEnemyCorpses = true
	self.m_VoteDuration = 30
	self.m_CooldownBetweenVotes = 0
	self.m_MaxVotingStartsPerPlayer = 3
	self.m_VotingParticipationNeeded = 50
	self.m_EnableAssistFunction = true
	self.m_ShowLoadingScreenInfo = true
end

function ModSettings:OnAuthenticated(p_Player)
	NetEvents:SendTo('RefreshModSettings', p_Player, {self.m_ShowEnemyCorpses, self.m_VoteDuration, self.m_CooldownBetweenVotes, self.m_MaxVotingStartsPerPlayer, self.m_VotingParticipationNeeded, self.m_EnableAssistFunction, self.m_ShowLoadingScreenInfo})
end

function ModSettings:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
	if self.m_LoadedModSettings == false then
		if not SQL:Open() then
			return
		end

		local s_Query = [[
		CREATE TABLE IF NOT EXISTS mod_settings (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			showEnemyCorpses BOOLEAN,
			voteDuration INTEGER,
			cooldownBetweenVotes INTEGER,
			maxVotingStartsPerPlayer INTEGER,
			votingParticipationNeeded INTEGER,
			enableAssistFunction BOOLEAN,
			showLoadingScreenInfo BOOLEAN
		)
		]]
		if not SQL:Query(s_Query) then
		print('Failed to execute query: ' .. SQL:Error())
		return
		end

		-- Fetch all rows from the table.
		local s_Results = SQL:Query('SELECT * FROM mod_settings')

		if not s_Results then
		print('Failed to execute query: ' .. SQL:Error())
		return
		end

		SQL:Close()

		if #s_Results == 0 then
			print("MODSETTINGS - LIST EMPTY - CREATING LIST")
			self:SQLSaveModSettings()
			return
		end
		if s_Results[1]["showEnemyCorpses"] == 1 then
			self.m_ShowEnemyCorpses = true
		else
			self.m_ShowEnemyCorpses = false
		end
		self.m_CooldownBetweenVotes = tonumber(s_Results[1]["cooldownBetweenVotes"])
		self.m_VotingParticipationNeeded = tonumber(s_Results[1]["votingParticipationNeeded"])
		self.m_VoteDuration = tonumber(s_Results[1]["voteDuration"])
		self.m_MaxVotingStartsPerPlayer = tonumber(s_Results[1]["maxVotingStartsPerPlayer"])
		if s_Results[1]["enableAssistFunction"] == 1 then
			self.m_EnableAssistFunction = true
		else
			self.m_EnableAssistFunction = false
		end
		if s_Results[1]["showLoadingScreenInfo"] == 0 then
			self.m_ShowLoadingScreenInfo = false
		else
			self.m_ShowLoadingScreenInfo = true
		end
		self.m_LoadedModSettings = true
	end

	local s_SyncedBFSettings = ResourceManager:GetSettings("SyncedBFSettings")
	if s_SyncedBFSettings ~= nil then
		s_SyncedBFSettings = SyncedBFSettings(s_SyncedBFSettings)
		if self.m_EnableAssistFunction == true then
			s_SyncedBFSettings.teamSwitchingAllowed = false
		else
			s_SyncedBFSettings.teamSwitchingAllowed = true
		end
	end
end

function ModSettings:ResetModSettings()
	self.m_ShowEnemyCorpses = true
	self.m_VoteDuration = 30
	self.m_CooldownBetweenVotes = 0
	self.m_MaxVotingStartsPerPlayer = 3
	self.m_VotingParticipationNeeded = 50
	self.m_EnableAssistFunction = true
	self.m_ShowLoadingScreenInfo = true
	NetEvents:Broadcast('RefreshModSettings', {self.m_ShowEnemyCorpses, self.m_VoteDuration, self.m_CooldownBetweenVotes, self.m_MaxVotingStartsPerPlayer, self.m_VotingParticipationNeeded, self.m_EnableAssistFunction, self.m_ShowLoadingScreenInfo})
end

function ModSettings:SetModSettings(args)
	self.m_ShowEnemyCorpses = args[1]
	self.m_VoteDuration = tonumber(args[2])
	self.m_CooldownBetweenVotes = tonumber(args[3])
	self.m_MaxVotingStartsPerPlayer = tonumber(args[4])
	self.m_VotingParticipationNeeded = tonumber(args[5])
	self.m_EnableAssistFunction = args[6]
	self.m_ShowLoadingScreenInfo = args[7]
	NetEvents:Broadcast('RefreshModSettings', {self.m_ShowEnemyCorpses, self.m_VoteDuration, self.m_CooldownBetweenVotes, self.m_MaxVotingStartsPerPlayer, self.m_VotingParticipationNeeded, self.m_EnableAssistFunction, self.m_ShowLoadingScreenInfo})
end

function ModSettings:SQLSaveModSettings()

	if not SQL:Open() then
		return
	end
	local s_Query = [[DROP TABLE IF EXISTS mod_settings]]
	if not SQL:Query(s_Query) then
		print('Failed to execute query: ' .. SQL:Error())
		return
	end
	s_Query = [[
		CREATE TABLE IF NOT EXISTS mod_settings (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			showEnemyCorpses BOOLEAN,
			voteDuration INTEGER,
			cooldownBetweenVotes INTEGER,
			maxVotingStartsPerPlayer INTEGER,
			votingParticipationNeeded INTEGER,
			enableAssistFunction BOOLEAN,
			showLoadingScreenInfo BOOLEAN
		)
	]]
	if not SQL:Query(s_Query) then
		print('Failed to execute query: ' .. SQL:Error())
		return
	end
	s_Query = 'INSERT INTO mod_settings (showEnemyCorpses, voteDuration, cooldownBetweenVotes, maxVotingStartsPerPlayer, votingParticipationNeeded, enableAssistFunction, showLoadingScreenInfo) VALUES (?, ?, ?, ?, ?, ?, ?)'
	if not SQL:Query(s_Query, self.m_ShowEnemyCorpses, self.m_VoteDuration, self.m_CooldownBetweenVotes, self.m_MaxVotingStartsPerPlayer, self.m_VotingParticipationNeeded, self.m_EnableAssistFunction, self.m_ShowLoadingScreenInfo) then
		print('Failed to execute query: ' .. SQL:Error())
		return
	end

	-- Fetch all rows from the table.
	local s_Results = SQL:Query('SELECT * FROM mod_settings')

	if not s_Results then
		print('Failed to execute query: ' .. SQL:Error())
		return
	end

	SQL:Close()
end

function ModSettings:GetEnableAssistFunction()
	return self.m_EnableAssistFunction
end

function ModSettings:GetVoteDuration()
	return self.m_VoteDuration
end

function ModSettings:GetVotingParticipationNeeded()
	return self.m_VotingParticipationNeeded
end

function ModSettings:GetCooldownBetweenVotes()
	return self.m_CooldownBetweenVotes
end

function ModSettings:GetMaxVotingStartsPerPlayer()
	return self.m_MaxVotingStartsPerPlayer
end

if g_ModSettings == nil then
	g_ModSettings = ModSettings()
end

return g_ModSettings
