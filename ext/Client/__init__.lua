class 'BetterIngameAdmin'

require('LoadingScreen')
require('Voting')
require('Assist')
require('Mute')
require('Admin')
require('ZoomLevel')
require('Ping')
require('MinimapConfig')
require('Scoreboard')
require('Squad')
require('ChatLagFix')

function BetterIngameAdmin:__init()
    print("Initializing BetterIngameAdmin")
    self:RegisterEvents()

	self.m_LoadingScreen = LoadingScreen()
	self.m_Voting = Voting()
	self.m_Assist = Assist()
	self.m_Mute = Mute()
	self.m_Admin = Admin()
	self.m_ZoomLevel = ZoomLevel()
	self.m_Ping = Ping()
	self.m_MinimapConfig = MinimapConfig()
	self.m_Scoreboard = Scoreboard()
	self.m_Squad = Squad()
	self.m_ChatLagFix = ChatLagFix()
end

function BetterIngameAdmin:RegisterEvents()
	Events:Subscribe('Extension:Loaded', self, self.OnExtensionLoaded) 

	NetEvents:Subscribe('PopupResponse', self, self.OnPopupResponse)

	NetEvents:Subscribe('RefreshModSettings', self, self.OnRefreshModSettings)
	
	Hooks:Install('UI:InputConceptEvent', 1, self, self.OnUIInputConceptEvent)
	Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
	Events:Subscribe('Soldier:HealthAction', self, self.OnSoldierHealthAction)
	Hooks:Install('UI:PushScreen', 1, self, self.OnUIPushScreen)
	NetEvents:Subscribe('Player:Ping', self, self.OnPlayerPing)
	
	Events:Subscribe('Level:LoadingInfo', self, self.OnLevelLoadingInfo)
	
	Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
	
	-- debug event to see if things work correct
	Events:Subscribe('WebUI:PrintThis', function(arg)
		print(arg)
	end)
	
	-- TODOS		
		-- level loaded event for voteCount reset
		-- Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
end

-- WebUI Init
function BetterIngameAdmin:OnExtensionLoaded()
	WebUI:Init()
	self.m_LoadingScreen:OnExtensionLoaded()
end

-- PopupResponse
function BetterIngameAdmin:OnPopupResponse(message)
    WebUI:ExecuteJS(string.format("showPopupResponse(%s)", json.encode(message)))
end

function BetterIngameAdmin:OnRefreshModSettings(args)
	self.m_Scoreboard:ShowEnemyCorpses(args[1])
	self.m_Voting:SetSettings(args[2], args[3], args[4], args[5])
	self.m_Assist:SetEnableAssistFunction(args[6])
	self.m_LoadingScreen:SetLoadingScreenInfo(args[7])
	
	WebUI:ExecuteJS(string.format("refreshModSettings(%s)", json.encode(args)))
end

function BetterIngameAdmin:OnUIInputConceptEvent(hook, eventType, action)
	self.m_Scoreboard:OnUIInputConceptEvent(hook, eventType, action)
end

function BetterIngameAdmin:OnEngineUpdate(deltaTime, simulationDeltaTime)
	self.m_Voting:OnEngineUpdate(deltaTime, simulationDeltaTime)
	self.m_Scoreboard:OnEngineUpdate(deltaTime, simulationDeltaTime)
	self.m_MinimapConfig:OnEngineUpdate(deltaTime, simulationDeltaTime)
end

function BetterIngameAdmin:OnSoldierHealthAction(soldier, action)
	self.m_Scoreboard:OnSoldierHealthAction(soldier, action)
end

function BetterIngameAdmin:OnUIPushScreen(hook, screen, graphPriority, parentGraph)
   self.m_Scoreboard:OnUIPushScreen(hook, screen, graphPriority, parentGraph)
end

function BetterIngameAdmin:OnPlayerPing(pingTable)
	self.m_Scoreboard:OnPlayerPing(pingTable)
	self.m_Ping:UpdateLocalPlayerPing(pingTable)
end

function BetterIngameAdmin:OnLevelLoadingInfo(screenInfo)
	self.m_LoadingScreen:OnLevelLoadingInfo(screenInfo)
	self.m_MinimapConfig:OnLevelLoadingInfo(screenInfo)
	self.m_Scoreboard:OnLevelLoadingInfo(screenInfo)
end

function BetterIngameAdmin:OnLevelDestroy()
	self.m_ZoomLevel:OnLevelDestroy()
	self.m_Scoreboard:OnLevelDestroy()
	self.m_LoadingScreen:OnLevelDestroy()
end

g_BetterIngameAdmin = BetterIngameAdmin()