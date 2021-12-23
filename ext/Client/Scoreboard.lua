---@class Scoreboard
Scoreboard = class 'Scoreboard'

function Scoreboard:__init()
	self.m_ShowEnemyCorpses = true

	self.m_Active = false
	-- Client Setting
	self.m_ToggleScoreboard = false

	self.m_IgnoreReleaseTab = false
	self.m_DontUpdate = false
	self.m_UpdateScoreboardInterval = 2 -- Add to Admin Settings
	self.m_CumulatedTimeForScoreboard = 0
	self.m_BlockTab = false
	self.m_IsEndOfRound = false
	self.m_LastScreenName = ""
	self.m_PingTable = {}

	self.m_ServerInfo = nil

	self.m_IsSpectator = false

	Events:Subscribe('WebUI:HoldScoreboard', self, self.OnWebUIHoldScoreboard)
	Events:Subscribe('WebUI:ClickScoreboard', self, self.OnWebUIClickScoreboard)
	Events:Subscribe('WebUI:IgnoreReleaseTab', self, self.OnWebUIIgnoreReleaseTab)
	Events:Subscribe('WebUI:ActiveFalse', self, self.OnWebUIActiveFalse)

	NetEvents:Subscribe('ServerInfo', self, self.OnServerInfo)
	Events:Subscribe('WebUI:GetPlayerCount', self, self.OnGetPlayerCount)
end

function Scoreboard:ShowEnemyCorpses(p_Enabled)
	self.m_ShowEnemyCorpses = p_Enabled
end

function Scoreboard:OnUIInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	if p_Action ~= UIInputAction.UIInputAction_Tab then
		return
	end
	local s_Player = PlayerManager:GetLocalPlayer()
	if s_Player == nil or self.m_IsSpectator == true then
		return
	end
	if self.m_BlockTab == false then
		if p_EventType == UIInputActionEventType.UIInputActionEventType_Pressed then
			if self.m_Active == false then
				self.m_Active = true
				self:UpdateUI(s_Player)
			elseif self.m_Active == true then
				self.m_Active = false
				self.m_DontUpdate = false
				s_Player:EnableInput(11, true)
				WebUI:ExecuteJS(string.format("clearScoreboardBody()"))
			end
		elseif self.m_ToggleScoreboard == false then
			if self.m_IgnoreReleaseTab == false then
				self.m_Active = false
				self.m_DontUpdate = false
				s_Player:EnableInput(11, true)
				WebUI:ExecuteJS(string.format("clearScoreboardBody()"))
			else
				self.m_IgnoreReleaseTab = false
			end
		end
	end
	p_HookCtx:Pass(UIInputAction.UIInputAction_None, p_EventType)
end

function Scoreboard:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	if self.m_Active == false then
		return
	end
	if self.m_UpdateScoreboardInterval < self.m_CumulatedTimeForScoreboard and self.m_DontUpdate == false then
		local s_Player = PlayerManager:GetLocalPlayer()
		if s_Player ~= nil then
			self:UpdateUI(s_Player)
		end
		self.m_CumulatedTimeForScoreboard = 0
	else
		self.m_CumulatedTimeForScoreboard = self.m_CumulatedTimeForScoreboard + p_DeltaTime
	end
	if InputManager:WentMouseButtonDown(InputDeviceMouseButtons.IDB_Button_1) then
		if self.m_ToggleScoreboard == false then
			self.m_IgnoreReleaseTab = true
		end
		self.m_DontUpdate = true
		WebUI:ExecuteJS("showTabsAndEnableMouse()")
		local s_LocalPlayer = PlayerManager:GetLocalPlayer()
		if s_LocalPlayer ~= nil then
			s_LocalPlayer:EnableInput(11, false)
		end
	end
end

function Scoreboard:UpdateUI(p_Player)
	local s_GameMode = SharedUtils:GetCurrentGameMode()
	local s_Size = 16
	local s_UsTickets = " "
	local s_RuTickets = " "
	local s_CharlieTickets = " "
	local s_DeltaTickets = " "
	local s_Team1
	local s_Team2
	local s_Team3
	local s_Team4
	local s_Tickets1
	local s_Tickets2
	local s_Tickets3
	local s_Tickets4
	local s_PlayerListTeam1
	local s_PlayerListTeam2
	local s_PlayerListTeam3
	local s_PlayerListTeam4
	if s_GameMode:match("Conquest") or s_GameMode:match("Superiority") or s_GameMode == "Domination0" or s_GameMode == "Scavenger0" then
		s_UsTickets, s_RuTickets = self:GetTicketCounterTickets()
	elseif s_GameMode:match("Rush") then
		s_UsTickets, s_RuTickets = self:GetLifeCounterTickets()
	elseif s_GameMode:match("TeamDeathMatch") or s_GameMode == "SquadDeathMatch0" then
		s_UsTickets, s_RuTickets, s_CharlieTickets, s_DeltaTickets = self:GetKillCounterTickets()
	-- elseif gameMode == "CaptureTheFlag0" or gameMode == "GunMaster0" then
	end
	if s_GameMode ~= "SquadDeathMatch0" then
		s_Size = 16
		if p_Player.teamId == TeamId.Team1 then
			s_Team1 = "US"
			s_Team2 = "RU"
			s_Tickets1 = tostring(s_UsTickets)
			s_Tickets2 = tostring(s_RuTickets)
			s_PlayerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			s_PlayerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
		else
			s_Team1 = "RU"
			s_Team2 = "US"
			s_Tickets1 = tostring(s_RuTickets)
			s_Tickets2 = tostring(s_UsTickets)
			s_PlayerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			s_PlayerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
		end
	else
		s_Size = 8
		if p_Player.teamId == TeamId.Team1 then
			s_Team1 = "Alpha"
			s_Team2 = "Bravo"
			s_Team3 = "Charlie"
			s_Team4 = "Delta"
			s_Tickets1 = tostring(s_UsTickets)
			s_Tickets2 = tostring(s_RuTickets)
			s_Tickets3 = tostring(s_CharlieTickets)
			s_Tickets4 = tostring(s_DeltaTickets)
			s_PlayerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			s_PlayerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			s_PlayerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			s_PlayerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		elseif p_Player.teamId == TeamId.Team2 then
			s_Team2 = "Alpha"
			s_Team1 = "Bravo"
			s_Team3 = "Charlie"
			s_Team4 = "Delta"
			s_Tickets2 = tostring(s_UsTickets)
			s_Tickets1 = tostring(s_RuTickets)
			s_Tickets3 = tostring(s_CharlieTickets)
			s_Tickets4 = tostring(s_DeltaTickets)
			s_PlayerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			s_PlayerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			s_PlayerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			s_PlayerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		elseif p_Player.teamId == TeamId.Team3 then
			s_Team2 = "Alpha"
			s_Team3 = "Bravo"
			s_Team1 = "Charlie"
			s_Team4 = "Delta"
			s_Tickets2 = tostring(s_UsTickets)
			s_Tickets3 = tostring(s_RuTickets)
			s_Tickets1 = tostring(s_CharlieTickets)
			s_Tickets4 = tostring(s_DeltaTickets)
			s_PlayerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			s_PlayerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			s_PlayerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			s_PlayerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		elseif p_Player.teamId == TeamId.Team4 then
			s_Team2 = "Alpha"
			s_Team3 = "Bravo"
			s_Team4 = "Charlie"
			s_Team1 = "Delta"
			s_Tickets2 = tostring(s_UsTickets)
			s_Tickets3 = tostring(s_RuTickets)
			s_Tickets4 = tostring(s_CharlieTickets)
			s_Tickets1 = tostring(s_DeltaTickets)
			s_PlayerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			s_PlayerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			s_PlayerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			s_PlayerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		end
	end
	local s_ScoreboardHeader = {s_Team1, s_Tickets1, s_Team2, s_Tickets2, p_Player.name, p_Player.squadId, p_Player.isSquadLeader, p_Player.isSquadPrivate}
	WebUI:ExecuteJS(string.format("updateScoreboardHeader(%s)", json.encode(s_ScoreboardHeader)))

	if s_GameMode == "SquadDeathMatch0" then
		local s_ScoreboardHeader2 = {s_Team3, s_Tickets3, s_Team4, s_Tickets4}
		WebUI:ExecuteJS(string.format("updateScoreboardHeader2(%s)", json.encode(s_ScoreboardHeader2)))
	end

	table.sort(s_PlayerListTeam1, function(a, b)
		return a.score > b.score
	end)

	table.sort(s_PlayerListTeam2, function(a, b)
		return a.score > b.score
	end)

	for index,player in pairs(s_PlayerListTeam1) do
		local s_Kit = "ID_M_DEAD"
		if player.customization ~= nil then
			s_Kit = CharacterCustomizationAsset(player.customization).labelSid
		end
		local s_Ping = "–"
		if self.m_PingTable[player.name] ~= nil and self.m_PingTable[player.name] >= 0 and self.m_PingTable[player.name] < 999 then
			s_Ping = self.m_PingTable[player.name]
		end
		local s_SendThis1 = {index, player.name, player.kills, player.deaths, player.score, player.squadId, player.alive, s_Kit, s_Ping, player.isSquadPrivate}
		WebUI:ExecuteJS(string.format("updateScoreboardBody1(%s)", json.encode(s_SendThis1)))
	end

	for index,player in pairs(s_PlayerListTeam2) do
		local s_Ping = "–"
		if self.m_PingTable[player.name] ~= nil and self.m_PingTable[player.name] >= 0 and self.m_PingTable[player.name] < 999 then
			s_Ping = self.m_PingTable[player.name]
		end
		local s_SendThis2 = {}
		if self.m_ShowEnemyCorpses == true then
			s_SendThis2 = {index, player.name, player.kills, player.deaths, player.score, player.alive, s_Ping}
		else
			s_SendThis2 = {index, player.name, player.kills, player.deaths, player.score, true, s_Ping}
		end
		WebUI:ExecuteJS(string.format("updateScoreboardBody2(%s)", json.encode(s_SendThis2)))
	end

	WebUI:ExecuteJS(string.format("updateScoreboardBody3(%s)", json.encode(s_Size)))

	if s_GameMode == "SquadDeathMatch0" then
		table.sort(s_PlayerListTeam3, function(a, b)
			return a.score > b.score
		end)

		table.sort(s_PlayerListTeam4, function(a, b)
			return a.score > b.score
		end)

		for index,player in pairs(s_PlayerListTeam3) do
			local s_Ping = "–"
			if self.m_PingTable[player.name] ~= nil and self.m_PingTable[player.name] >= 0 and self.m_PingTable[player.name] < 999 then
				s_Ping = self.m_PingTable[player.name]
			end
			local s_SendThis3 = {}
			if self.m_ShowEnemyCorpses == true then
				s_SendThis3 = {index, player.name, player.kills, player.deaths, player.score, player.alive, s_Ping}
			else
				s_SendThis3 = {index, player.name, player.kills, player.deaths, player.score, true, s_Ping}
			end
			WebUI:ExecuteJS(string.format("updateScoreboardBody4(%s)", json.encode(s_SendThis3)))
		end

		for index,player in pairs(s_PlayerListTeam4) do
			local s_Ping = "–"
			if self.m_PingTable[player.name] ~= nil and self.m_PingTable[player.name] >= 0 and self.m_PingTable[player.name] < 999 then
				s_Ping = self.m_PingTable[player.name]
			end
			local s_SendThis4 = {}
			if self.m_ShowEnemyCorpses == true then
				s_SendThis4 = {index, player.name, player.kills, player.deaths, player.score, player.alive, s_Ping}
			else
				s_SendThis4 = {index, player.name, player.kills, player.deaths, player.score, true, s_Ping}
			end
			WebUI:ExecuteJS(string.format("updateScoreboardBody5(%s)", json.encode(s_SendThis4)))
		end

		WebUI:ExecuteJS("updateScoreboardBody6()")
	end
end

function Scoreboard:GetTicketCounterTickets()
	local s_ClientTicketCounterIterator = EntityManager:GetIterator('ClientTicketCounterEntity')
	local s_TicketCounterEntity = s_ClientTicketCounterIterator:Next()
	local s_UsTickets = " "
	local s_RuTickets = " "
	while s_TicketCounterEntity ~= nil do
		if TicketCounterEntity(s_TicketCounterEntity).team == TeamId.Team1 then
			s_UsTickets = TicketCounterEntity(s_TicketCounterEntity).ticketCount
		else
			s_RuTickets = TicketCounterEntity(s_TicketCounterEntity).ticketCount
		end
		s_TicketCounterEntity = s_ClientTicketCounterIterator:Next()
	end
	return s_UsTickets, s_RuTickets
end

function Scoreboard:GetLifeCounterTickets()
	local s_LifeCounterEntityIterator = EntityManager:GetIterator('ClientLifeCounterEntity')
	local s_LifeCounterEntity = s_LifeCounterEntityIterator:Next()
	local s_UsTickets = " "
	local s_RuTickets = " "
	while s_LifeCounterEntity ~= nil do
		if LifeCounterEntityData(s_LifeCounterEntity.data).teamId == TeamId.Team1 then
			s_UsTickets = LifeCounterEntity(s_LifeCounterEntity).lifeCounter
		elseif LifeCounterEntityData(s_LifeCounterEntity.data).teamId == TeamId.Team2 then
			s_RuTickets = LifeCounterEntity(s_LifeCounterEntity).lifeCounter
		end
		s_LifeCounterEntity = s_LifeCounterEntityIterator:Next()
	end
	return s_UsTickets, s_RuTickets
end

function Scoreboard:GetKillCounterTickets()
	local s_KillCounterEntityIterator = EntityManager:GetIterator('ClientKillCounterEntity')
	local s_KillCounterEntity = s_KillCounterEntityIterator:Next()
	local s_AlphaTickets = " "
	local s_BravoTickets = " "
	local s_CharlieTickets = " "
	local s_DeltaTickets = " "
	while s_KillCounterEntity ~= nil do
		if KillCounterEntityData(s_KillCounterEntity.data).teamId == TeamId.Team1 then
			s_AlphaTickets = KillCounterEntity(s_KillCounterEntity).killCount
		elseif KillCounterEntityData(s_KillCounterEntity.data).teamId == TeamId.Team2 then
			s_BravoTickets = KillCounterEntity(s_KillCounterEntity).killCount
		elseif KillCounterEntityData(s_KillCounterEntity.data).teamId == TeamId.Team3 then
			s_CharlieTickets = KillCounterEntity(s_KillCounterEntity).killCount
		elseif KillCounterEntityData(s_KillCounterEntity.data).teamId == TeamId.Team4 then
			s_DeltaTickets = KillCounterEntity(s_KillCounterEntity).killCount
		end
		s_KillCounterEntity = s_KillCounterEntityIterator:Next()
	end
	return s_AlphaTickets, s_BravoTickets, s_CharlieTickets, s_DeltaTickets
end

function Scoreboard:OnWebUIHoldScoreboard()
	self.m_ToggleScoreboard = false
end

function Scoreboard:OnWebUIClickScoreboard()
	self.m_ToggleScoreboard = true
end

function Scoreboard:OnWebUIIgnoreReleaseTab()
	if self.m_ToggleScoreboard == false then
		self.m_IgnoreReleaseTab = true
	end
end

function Scoreboard:OnWebUIActiveFalse()
	if self.m_Active == true then
		local s_Player = PlayerManager:GetLocalPlayer()
		if s_Player ~= nil then
			s_Player:EnableInput(11, true)
		end
		self.m_Active = false
	end
end

function Scoreboard:OnSoldierHealthAction(p_Soldier, p_Action)
	if p_Action == HealthStateAction.OnRevive then
		local s_LocalPlayer = PlayerManager:GetLocalPlayer()
		if s_LocalPlayer.soldier ~= nil then
			if p_Soldier == s_LocalPlayer.soldier then
				self.m_Active = false
				self.m_DontUpdate = false
				s_LocalPlayer:EnableInput(11, true)
				WebUI:ExecuteJS("clearScoreboardBody()")
			end
		elseif s_LocalPlayer.corpse ~= nil then
			if p_Soldier == s_LocalPlayer.corpse then
				self.m_Active = false
				self.m_DontUpdate = false
				s_LocalPlayer:EnableInput(11, true)
				WebUI:ExecuteJS("clearScoreboardBody()")
			end
		end
	end
end

function Scoreboard:OnUIPushScreen(p_HookCtx, p_Screen, p_GraphPriority, p_ParentGraph)
	p_Screen = Asset(p_Screen)
	if p_Screen.name == 'UI/Flow/Screen/EORDetailsScoreboardScreen' then
		self.m_IsEndOfRound = true
	elseif p_Screen.name == 'UI/Flow/Screen/EmptyScreen' and self.m_IsEndOfRound == true then
		self.m_IsEndOfRound = false
	elseif self.m_IsEndOfRound == false and self.m_LastScreenName == "UI/Flow/Screen/IngameMenuMP" and self.m_IsSpectator == false then
		if p_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsScreen'
		or p_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoSquadsScreen'
		or p_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardFourSquadsScreen'
		or p_Screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsHUD16Screen' then
			local s_ScreenClone = UIScreenAsset(ResourceManager:SearchForDataContainer("UI/Flow/Screen/ScoreboardBackScreen"))
			s_ScreenClone:MakeWritable()
			local s_UiPageHeaderBinding = UIPageHeaderBinding(WidgetNode(s_ScreenClone.nodes[4]).dataBinding)
			s_UiPageHeaderBinding:MakeWritable()
			s_UiPageHeaderBinding.staticHeader = ""
			s_UiPageHeaderBinding.staticSubHeader = ""
			local s_Player = PlayerManager:GetLocalPlayer()
			self.m_Active = true
			self:UpdateUI(s_Player)
			self.m_DontUpdate = true
			WebUI:ExecuteJS(string.format("showTabsAndEnableMouse()"))
			p_HookCtx:Pass(s_ScreenClone, p_GraphPriority, p_ParentGraph)
		end
	end
	if p_Screen.name == 'UI/Flow/Screen/IngameMenuMP'
	or p_Screen.name == 'UI/Flow/Screen/SquadScreen'
	or p_Screen.name == 'UI/Flow/Screen/OptionsControlsScreen'
	or p_Screen.name == 'UI/Flow/Screen/OptionsGameplayScreen'
	or p_Screen.name == 'UI/Flow/Screen/OptionsAudioScreen'
	or p_Screen.name == 'UI/Flow/Screen/OptionsVideoScreen'
	or p_Screen.name == 'UI/Flow/Screen/OptionsKeyBindingScreen'
	or p_Screen.name:match('UI/Flow/Screen/Popups/') then
		self.m_BlockTab = true
		WebUI:ExecuteJS("closeSmart()")
	else
		self.m_BlockTab = false
	end
	self.m_LastScreenName = p_Screen.name
end

function Scoreboard:OnPlayerPing(p_PingTable)
	self.m_PingTable = p_PingTable
end

function Scoreboard:OnServerInfo(p_Args)
	self.m_ServerInfo = p_Args
	WebUI:ExecuteJS(string.format("getServerInfo(%s)", json.encode(p_Args)))
end

function Scoreboard:OnGetPlayerCount()
	local s_Count = {}
	s_Count[1] = PlayerManager:GetPlayerCount() - PlayerManager:GetSpectatorCount()
	s_Count[2] = PlayerManager:GetSpectatorCount()
	WebUI:ExecuteJS(string.format("getPlayerCount(%s)", json.encode(s_Count)))
end

function Scoreboard:OnLevelLoadingInfo(p_ScreenInfo)
	if p_ScreenInfo == "Initializing entities for autoloaded sublevels" then
		if SpectatorManager:GetSpectating() == true then
			self.m_IsSpectator = true
		end
	end
end

function Scoreboard:OnLevelDestroy()
	WebUI:ExecuteJS("closeSmart()")
end

function Scoreboard:GetToggleScoreboard()
	return self.m_ToggleScoreboard
end

function Scoreboard:SetIgnoreReleaseTab(p_Enable)
	self.m_IgnoreReleaseTab = p_Enable
end

if g_Scoreboard == nil then
	g_Scoreboard = Scoreboard()
end

return g_Scoreboard
