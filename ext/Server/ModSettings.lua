class 'ModSettings'

function ModSettings:__init()
	self.loadedModSettings = false
	self.showEnemyCorpses = true
	self.voteDuration = 30
	self.cooldownBetweenVotes = 0
	self.maxVotingStartsPerPlayer = 3
	self.votingParticipationNeeded = 50
	self.enableAssistFunction = true
    self.showLoadingScreenInfo = true
end

function ModSettings:OnAuthenticated(p_Player)
	NetEvents:SendTo('RefreshModSettings', p_Player, {self.showEnemyCorpses, self.voteDuration, self.cooldownBetweenVotes, self.maxVotingStartsPerPlayer, self.votingParticipationNeeded, self.enableAssistFunction, self.showLoadingScreenInfo})
end

function ModSettings:OnLevelLoaded(levelName, gameMode, round, roundsPerMap)
    if self.loadedModSettings == false then
        if not SQL:Open() then
            return
        end
        
        local query = [[
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
        if not SQL:Query(query) then
        print('Failed to execute query: ' .. SQL:Error())
        return
        end
        
        -- Fetch all rows from the table.
        results = SQL:Query('SELECT * FROM mod_settings')

        if not results then
        print('Failed to execute query: ' .. SQL:Error())
        return
        end
        
        SQL:Close()

        if #results == 0 then
            print("MODSETTINGS - LIST EMPTY - CREATING LIST")
            self:SQLSaveModSettings()
        end
        if results[1]["showEnemyCorpses"] == 1 then
            self.showEnemyCorpses = true
        else
            self.showEnemyCorpses = false
        end
        self.cooldownBetweenVotes = results[1]["cooldownBetweenVotes"]
        self.votingParticipationNeeded = results[1]["votingParticipationNeeded"]
        self.voteDuration = results[1]["voteDuration"]
        self.maxVotingStartsPerPlayer = results[1]["maxVotingStartsPerPlayer"]
        if results[1]["enableAssistFunction"] == 1 then
            self.enableAssistFunction = true
        else
            self.enableAssistFunction = false
        end
        if results[1]["showLoadingScreenInfo"] == 0 then
            self.showLoadingScreenInfo = false
        else
            self.showLoadingScreenInfo = true
        end
        self.loadedModSettings = true
    end

    local syncedBFSettings = ResourceManager:GetSettings("SyncedBFSettings")
    if syncedBFSettings ~= nil then
        syncedBFSettings = SyncedBFSettings(syncedBFSettings)
        if self.enableAssistFunction == true then
            syncedBFSettings.teamSwitchingAllowed = false
        else
            syncedBFSettings.teamSwitchingAllowed = true
        end
    end
end

function ModSettings:ResetModSettings()
	self.showEnemyCorpses = true
	self.voteDuration = 30
	self.cooldownBetweenVotes = 0
	self.maxVotingStartsPerPlayer = 3
	self.votingParticipationNeeded = 50
	self.enableAssistFunction = true
	self.showLoadingScreenInfo = true
    NetEvents:Broadcast('RefreshModSettings', {self.showEnemyCorpses, self.voteDuration, self.cooldownBetweenVotes, self.maxVotingStartsPerPlayer, self.votingParticipationNeeded, self.enableAssistFunction, self.showLoadingScreenInfo})
end

function ModSettings:SetModSettings(args)
	self.showEnemyCorpses = args[1]
	self.voteDuration = tonumber(args[2])
	self.cooldownBetweenVotes = tonumber(args[3])
	self.maxVotingStartsPerPlayer = tonumber(args[4])
	self.votingParticipationNeeded = tonumber(args[5])
	self.enableAssistFunction = args[6]
    self.showLoadingScreenInfo = args[7]
    NetEvents:Broadcast('RefreshModSettings', {self.showEnemyCorpses, self.voteDuration, self.cooldownBetweenVotes, self.maxVotingStartsPerPlayer, self.votingParticipationNeeded, self.enableAssistFunction, self.showLoadingScreenInfo})
end

function ModSettings:SQLSaveModSettings()
	
	if not SQL:Open() then
		return
	end
	local query = [[DROP TABLE IF EXISTS mod_settings]]
	if not SQL:Query(query) then
		print('Failed to execute query: ' .. SQL:Error())
		return
	end
	query = [[
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
	if not SQL:Query(query) then
	  print('Failed to execute query: ' .. SQL:Error())
	  return
	end
	query = 'INSERT INTO mod_settings (showEnemyCorpses, voteDuration, cooldownBetweenVotes, maxVotingStartsPerPlayer, votingParticipationNeeded, enableAssistFunction, showLoadingScreenInfo) VALUES (?, ?, ?, ?, ?, ?, ?)'
	if not SQL:Query(query, self.showEnemyCorpses, self.voteDuration, self.cooldownBetweenVotes, self.maxVotingStartsPerPlayer, self.votingParticipationNeeded, self.enableAssistFunction, self.showLoadingScreenInfo) then
		print('Failed to execute query: ' .. SQL:Error())
		return
	end
	
	-- Fetch all rows from the table.
	results = SQL:Query('SELECT * FROM mod_settings')
	
	if not results then
		print('Failed to execute query: ' .. SQL:Error())
		return
	end

	SQL:Close()
end

return ModSettings