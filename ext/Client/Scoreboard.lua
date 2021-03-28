class 'Scoreboard'

function Scoreboard:__init()
    self.showEnemyCorpses = true

    self.active = false
    --  Client Setting
    self.toggleScoreboard = false

    self.ignoreReleaseTab = false
    self.dontUpdate = false
    self.updateScoreboardInterval = 2 -- Add to Admin Settings
    self.cumulatedTimeForScoreboard = 0
    self.blockTab = false
    self.isEndOfRound = false
    self.lastScreenName = ""
    self.pingTable = {}

    self.serverInfo = nil

    self.isSpectator = false

	Events:Subscribe('WebUI:HoldScoreboard', self, self.OnWebUIHoldScoreboard)
	Events:Subscribe('WebUI:ClickScoreboard', self, self.OnWebUIClickScoreboard)
	Events:Subscribe('WebUI:IgnoreReleaseTab', self, self.OnWebUIIgnoreReleaseTab)
    Events:Subscribe('WebUI:ActiveFalse', self, self.OnWebUIActiveFalse)
    
	NetEvents:Subscribe('ServerInfo', self, self.OnServerInfo)
	Events:Subscribe('WebUI:GetPlayerCount', self, self.OnGetPlayerCount)
end

function Scoreboard:ShowEnemyCorpses(p_Enabled)
	self.showEnemyCorpses = p_Enabled
end

function Scoreboard:OnUIInputConceptEvent(hook, eventType, action)
    if action ~= UIInputAction.UIInputAction_Tab then
       return 
    end
    local player = PlayerManager:GetLocalPlayer()
    if player == nil or self.isSpectator == true then
        return
    end
    if self.blockTab == false then
        if eventType == UIInputActionEventType.UIInputActionEventType_Pressed then
            if self.active == false then
                self.active = true
                self:UpdateUI(player)
            elseif self.active == true then
                self.active = false
                self.dontUpdate = false
                player:EnableInput(11, true)
                WebUI:ExecuteJS(string.format("clearScoreboardBody()"))
            end
        elseif self.toggleScoreboard == false then
            if self.ignoreReleaseTab == false then
                self.active = false
                self.dontUpdate = false
                player:EnableInput(11, true)
                WebUI:ExecuteJS(string.format("clearScoreboardBody()"))
            else
                self.ignoreReleaseTab = false
            end
        end
    end
    hook:Pass(UIInputAction.UIInputAction_None, eventType)
end

function Scoreboard:OnEngineUpdate(deltaTime, simulationDeltaTime)
    if self.active == false then
        return
    end
    if self.updateScoreboardInterval < self.cumulatedTimeForScoreboard and self.dontUpdate == false then
        local player = PlayerManager:GetLocalPlayer()
        if player ~= nil then
            self:UpdateUI(player)
        end
        self.cumulatedTimeForScoreboard = 0
    else
        self.cumulatedTimeForScoreboard = self.cumulatedTimeForScoreboard + deltaTime
    end
    if InputManager:WentMouseButtonDown(InputDeviceMouseButtons.IDB_Button_1) then
        if self.toggleScoreboard == false then
            self.ignoreReleaseTab = true
        end
        self.dontUpdate = true
        WebUI:ExecuteJS("showTabsAndEnableMouse()")
        local localPlayer = PlayerManager:GetLocalPlayer()
        if localPlayer ~= nil then
            localPlayer:EnableInput(11, false)
        end
    end
end

function Scoreboard:UpdateUI(player)
	local gameMode = SharedUtils:GetCurrentGameMode()
    local size = 16
    local usTickets = " "
    local ruTickets = " "
    local charlieTickets = " "
	local deltaTickets = " "
	local tickets1
	local tickets2
	local tickets3
	local tickets4
	local playerListTeam1
	local playerListTeam2
	local playerListTeam3
	local playerListTeam4
	if gameMode:match("Conquest") or gameMode:match("Superiority") or gameMode == "Domination0" or gameMode == "Scavenger0" then
        usTickets, ruTickets = self:GetTicketCounterTickets()
    elseif gameMode:match("Rush") then
        usTickets, ruTickets = self:GetLifeCounterTickets()	
	elseif gameMode:match("TeamDeathMatch") or gameMode == "SquadDeathMatch0" then
        usTickets, ruTickets, charlieTickets, deltaTickets = self:GetKillCounterTickets()		
	-- elseif gameMode == "CaptureTheFlag0" or gameMode == "GunMaster0" then
	end
	if gameMode ~= "SquadDeathMatch0" then
		size = 16
		if player.teamId == TeamId.Team1 then
			team1 = "US"
			team2 = "RU"
			tickets1 = tostring(usTickets)
			tickets2 = tostring(ruTickets)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
		else
			team1 = "RU"
			team2 = "US"
			tickets1 = tostring(ruTickets)
			tickets2 = tostring(usTickets)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
		end
	else
		size = 8
		if player.teamId == TeamId.Team1 then
			team1 = "Alpha"
			team2 = "Bravo"
			team3 = "Charlie"
			team4 = "Delta"
			tickets1 = tostring(usTickets)
			tickets2 = tostring(ruTickets)
			tickets3 = tostring(charlieTickets)
			tickets4 = tostring(deltaTickets)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			playerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		elseif player.teamId == TeamId.Team2 then
			team2 = "Alpha"
			team1 = "Bravo"
			team3 = "Charlie"
			team4 = "Delta"
			tickets2 = tostring(usTickets)
			tickets1 = tostring(ruTickets)
			tickets3 = tostring(charlieTickets)
			tickets4 = tostring(deltaTickets)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			playerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		elseif player.teamId == TeamId.Team3 then
			team2 = "Alpha"
			team3 = "Bravo"
			team1 = "Charlie"
			team4 = "Delta"
			tickets2 = tostring(usTickets)
			tickets3 = tostring(ruTickets)
			tickets1 = tostring(charlieTickets)
			tickets4 = tostring(deltaTickets)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			playerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		elseif player.teamId == TeamId.Team4 then
			team2 = "Alpha"
			team3 = "Bravo"
			team4 = "Charlie"
			team1 = "Delta"
			tickets2 = tostring(usTickets)
			tickets3 = tostring(ruTickets)
			tickets4 = tostring(charlieTickets)
			tickets1 = tostring(deltaTickets)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		end
	end
	local scoreboardHeader = {team1, tickets1, team2, tickets2, player.name, player.squadId, player.isSquadLeader, player.isSquadPrivate}
	WebUI:ExecuteJS(string.format("updateScoreboardHeader(%s)", json.encode(scoreboardHeader)))
	
	if gameMode == "SquadDeathMatch0" then
		local scoreboardHeader2 = {team3, tickets3, team4, tickets4}
		WebUI:ExecuteJS(string.format("updateScoreboardHeader2(%s)", json.encode(scoreboardHeader2)))
	end
	
	table.sort(playerListTeam1, function(a, b) 
		return a.score > b.score
	end)
	
	table.sort(playerListTeam2, function(a, b) 
		return a.score > b.score
	end)
	
	local playerListTeams = {playerListTeam1, playerListTeam2}
	
	for index,player in pairs(playerListTeam1) do
		local kit = "ID_M_DEAD"
		if player.customization ~= nil then
			kit = CharacterCustomizationAsset(player.customization).labelSid 
		end
		local ping = "–"
		if self.pingTable[player.name] ~= nil and self.pingTable[player.name] >= 0 and self.pingTable[player.name] < 999 then
			ping = self.pingTable[player.name]
		end
		local sendThis1 = {index, player.name, player.kills, player.deaths, player.score, player.squadId, player.alive, kit, ping, player.isSquadPrivate}
		WebUI:ExecuteJS(string.format("updateScoreboardBody1(%s)", json.encode(sendThis1)))
	end
	
	for index,player in pairs(playerListTeam2) do
		local ping = "–"
		if self.pingTable[player.name] ~= nil and self.pingTable[player.name] >= 0 and self.pingTable[player.name] < 999 then
			ping = self.pingTable[player.name]
		end
		local sendThis2 = {}
		if self.showEnemyCorpses == true then
			sendThis2 = {index, player.name, player.kills, player.deaths, player.score, player.alive, ping}
		else
			sendThis2 = {index, player.name, player.kills, player.deaths, player.score, true, ping}
		end
		WebUI:ExecuteJS(string.format("updateScoreboardBody2(%s)", json.encode(sendThis2)))
	end
	
	WebUI:ExecuteJS(string.format("updateScoreboardBody3(%s)", json.encode(size)))
	
	if gameMode == "SquadDeathMatch0" then
		table.sort(playerListTeam3, function(a, b) 
			return a.score > b.score
		end)
		
		table.sort(playerListTeam4, function(a, b) 
			return a.score > b.score
		end)
		local playerListTeams2 = {playerListTeam3, playerListTeam4}
	
		for index,player in pairs(playerListTeam3) do
			local ping = "–"
			if self.pingTable[player.name] ~= nil and self.pingTable[player.name] >= 0 and self.pingTable[player.name] < 999 then
				ping = self.pingTable[player.name]
			end
			local sendThis3 = {}
			if self.showEnemyCorpses == true then
				sendThis3 = {index, player.name, player.kills, player.deaths, player.score, player.alive, ping}
			else
				sendThis3 = {index, player.name, player.kills, player.deaths, player.score, true, ping}
			end
			WebUI:ExecuteJS(string.format("updateScoreboardBody4(%s)", json.encode(sendThis3)))
		end
		
		for index,player in pairs(playerListTeam4) do
			local ping = "–"
			if self.pingTable[player.name] ~= nil and self.pingTable[player.name] >= 0 and self.pingTable[player.name] < 999 then
				ping = self.pingTable[player.name]
			end
			local sendThis4 = {}
			if self.showEnemyCorpses == true then
				sendThis4 = {index, player.name, player.kills, player.deaths, player.score, player.alive, ping}
			else
				sendThis4 = {index, player.name, player.kills, player.deaths, player.score, true, ping}
			end
			WebUI:ExecuteJS(string.format("updateScoreboardBody5(%s)", json.encode(sendThis4)))
		end
		
		WebUI:ExecuteJS("updateScoreboardBody6()")
	end
end

function Scoreboard:GetTicketCounterTickets()
    local clientTicketCounterIterator = EntityManager:GetIterator('ClientTicketCounterEntity')
    local ticketCounterEntity = clientTicketCounterIterator:Next()
    local usTickets = " "
    local ruTickets = " "
    while ticketCounterEntity ~= nil do
        if TicketCounterEntity(ticketCounterEntity).team == TeamId.Team1 then
            usTickets = TicketCounterEntity(ticketCounterEntity).ticketCount
        else
            ruTickets = TicketCounterEntity(ticketCounterEntity).ticketCount
        end
        ticketCounterEntity = clientTicketCounterIterator:Next()
    end
    return usTickets, ruTickets
end

function Scoreboard:GetLifeCounterTickets()
    local lifeCounterEntityIterator = EntityManager:GetIterator('ClientLifeCounterEntity')
    local lifeCounterEntity = lifeCounterEntityIterator:Next()
    local usTickets = " "
    local ruTickets = " "
    while lifeCounterEntity ~= nil do
        if LifeCounterEntityData(lifeCounterEntity.data).teamId == TeamId.Team1 then
            usTickets = LifeCounterEntity(lifeCounterEntity).lifeCounter
        elseif LifeCounterEntityData(lifeCounterEntity.data).teamId == TeamId.Team2 then
            ruTickets = LifeCounterEntity(lifeCounterEntity).lifeCounter
        end
        lifeCounterEntity = lifeCounterEntityIterator:Next()
    end
    return usTickets, ruTickets
end

function Scoreboard:GetKillCounterTickets()
    local killCounterEntityIterator = EntityManager:GetIterator('ClientKillCounterEntity')
    local killCounterEntity = killCounterEntityIterator:Next()
    local alphaTickets = " "
    local bravoTickets = " "
    local charlieTickets = " "
    local deltaTickets = " "
    while killCounterEntity ~= nil do
        if KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team1 then
            alphaTickets = KillCounterEntity(killCounterEntity).killCount
        elseif KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team2 then
            bravoTickets = KillCounterEntity(killCounterEntity).killCount
        elseif KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team3 then
            charlieTickets = KillCounterEntity(killCounterEntity).killCount
        elseif KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team4 then
            deltaTickets = KillCounterEntity(killCounterEntity).killCount
        end
        killCounterEntity = killCounterEntityIterator:Next()
    end
    return alphaTickets, bravoTickets, charlieTickets, deltaTickets
end

function Scoreboard:OnWebUIHoldScoreboard()
	self.toggleScoreboard = false
end

function Scoreboard:OnWebUIClickScoreboard()
	self.toggleScoreboard = true
end

function Scoreboard:OnWebUIIgnoreReleaseTab()
	if self.toggleScoreboard == false then
		self.ignoreReleaseTab = true
	end
end

function Scoreboard:OnWebUIActiveFalse()
	if self.active == true then
		local player = PlayerManager:GetLocalPlayer()
		if player ~= nil then
			player:EnableInput(11, true)
		end
		self.active = false
	end
end

function Scoreboard:OnSoldierHealthAction(soldier, action)
	if action == HealthStateAction.OnRevive then
		local localPlayer = PlayerManager:GetLocalPlayer()
		if localPlayer.soldier ~= nil then
			if soldier == localPlayer.soldier then
				self.active = false
				self.dontUpdate = false
				localPlayer:EnableInput(11, true)
				WebUI:ExecuteJS("clearScoreboardBody()")
			end
		elseif localPlayer.corpse ~= nil then
			if soldier == localPlayer.corpse then
				self.active = false
				self.dontUpdate = false
				localPlayer:EnableInput(11, true)
				WebUI:ExecuteJS("clearScoreboardBody()")
			end
		end
	end
end

function Scoreboard:OnUIPushScreen(hook, screen, graphPriority, parentGraph)
    local screen = UIGraphAsset(screen)
    if screen.name == 'UI/Flow/Screen/EORDetailsScoreboardScreen' then
        self.isEndOfRound = true
    elseif screen.name == 'UI/Flow/Screen/EmptyScreen' and self.isEndOfRound == true then
        self.isEndOfRound = false
    elseif self.isEndOfRound == false and self.lastScreenName == "UI/Flow/Screen/IngameMenuMP" and self.isSpectator == false then
        if screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsScreen' 
        or screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoSquadsScreen' 
        or screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardFourSquadsScreen' 
        or screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD16Screen' then
            local screenClone = UIScreenAsset(ResourceManager:SearchForDataContainer("UI/Flow/Screen/ScoreboardBackScreen"))
            screenClone:MakeWritable()
            local uiPageHeaderBinding = UIPageHeaderBinding(WidgetNode(screenClone.nodes[4]).dataBinding)
            uiPageHeaderBinding:MakeWritable()
            uiPageHeaderBinding.staticHeader  = ""
            uiPageHeaderBinding.staticSubHeader = ""
            local player = PlayerManager:GetLocalPlayer()
            self.active = true
            self:UpdateUI(player)
            self.dontUpdate = true
            WebUI:ExecuteJS(string.format("showTabsAndEnableMouse()"))
            hook:Pass(screenClone, graphPriority, parentGraph)
        end
    end
    if screen.name == 'UI/Flow/Screen/IngameMenuMP' 
    or screen.name == 'UI/Flow/Screen/SquadScreen' 
    or screen.name == 'UI/Flow/Screen/OptionsControlsScreen'
    or screen.name == 'UI/Flow/Screen/OptionsGameplayScreen'
    or screen.name == 'UI/Flow/Screen/OptionsAudioScreen'
    or screen.name == 'UI/Flow/Screen/OptionsVideoScreen'
    or screen.name == 'UI/Flow/Screen/OptionsKeyBindingScreen'
    or screen.name:match('UI/Flow/Screen/Popups/') then
        self.blockTab = true
        WebUI:ExecuteJS("closeSmart()")
    else
        self.blockTab = false
    end
    self.lastScreenName = screen.name
end

function Scoreboard:OnPlayerPing(pingTable)
	self.pingTable = pingTable
end
 
function Scoreboard:OnServerInfo(p_Args)
	self.serverInfo = p_Args
	WebUI:ExecuteJS(string.format("getServerInfo(%s)", json.encode(p_Args)))
end

function Scoreboard:OnGetPlayerCount()
	local count = {}
	count[1] = PlayerManager:GetPlayerCount() - PlayerManager:GetSpectatorCount()
	count[2] = PlayerManager:GetSpectatorCount()
	WebUI:ExecuteJS(string.format("getPlayerCount(%s)", json.encode(count)))
end

function Scoreboard:OnLevelLoadingInfo(screenInfo)
	if screenInfo == "Initializing entities for autoloaded sublevels" then
		if SpectatorManager:GetSpectating() == true then
			self.isSpectator = true
		end
	end
end

function Scoreboard:OnLevelDestroy()
	WebUI:ExecuteJS("closeSmart()")
end

return Scoreboard