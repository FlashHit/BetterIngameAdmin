---@class BetterIngameAdmin
BetterIngameAdmin = class 'BetterIngameAdmin'

---@type LoadingScreen
local m_LoadingScreen = require('LoadingScreen')
---@type Voting
local m_Voting = require('Voting')
---@type Assist
local m_Assist = require('Assist')
require('Mute')
require('Admin')
---@type ZoomLevel
local m_ZoomLevel = require('ZoomLevel')
---@type Ping
local m_Ping = require('Ping')
---@type MinimapConfig
local m_MinimapConfig = require('MinimapConfig')
---@type Scoreboard
local m_Scoreboard = require('Scoreboard')
require('Squad')
require('ChatLagFix')

function BetterIngameAdmin:__init()
	print("Initializing BetterIngameAdmin")
	self:RegisterEvents()
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
	Events:Subscribe('WebUI:PrintThis', function(p_Arg)
		print(p_Arg)
	end)

	-- TODOS
		-- level loaded event for voteCount reset
		-- Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
end

-- WebUI Init
function BetterIngameAdmin:OnExtensionLoaded()
	WebUI:Init()
	m_LoadingScreen:OnExtensionLoaded()
	m_Ping:OnExtensionLoaded()
	m_MinimapConfig:OnExtensionLoaded()
end

-- PopupResponse
function BetterIngameAdmin:OnPopupResponse(p_Message)
	WebUI:ExecuteJS(string.format("showPopupResponse(%s)", json.encode(p_Message)))
end

function BetterIngameAdmin:OnRefreshModSettings(p_Args)
	m_Scoreboard:ShowEnemyCorpses(p_Args[1])
	m_Voting:SetSettings(p_Args[2], p_Args[3], p_Args[4], p_Args[5])
	m_Assist:SetEnableAssistFunction(p_Args[6])
	m_LoadingScreen:SetLoadingScreenInfo(p_Args[7])

	WebUI:ExecuteJS(string.format("refreshModSettings(%s)", json.encode(p_Args)))
end

function BetterIngameAdmin:OnUIInputConceptEvent(p_HookCtx, p_EventType, p_Action)
	m_Scoreboard:OnUIInputConceptEvent(p_HookCtx, p_EventType, p_Action)
end

function BetterIngameAdmin:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_Voting:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_Scoreboard:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_MinimapConfig:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
end

function BetterIngameAdmin:OnSoldierHealthAction(p_Soldier, p_Action)
	m_Scoreboard:OnSoldierHealthAction(p_Soldier, p_Action)
end

function BetterIngameAdmin:OnUIPushScreen(p_HookCtx, p_Screen, p_GraphPriority, p_ParentGraph)
	m_Scoreboard:OnUIPushScreen(p_HookCtx, p_Screen, p_GraphPriority, p_ParentGraph)
end

function BetterIngameAdmin:OnPlayerPing(p_PingTable)
	m_Scoreboard:OnPlayerPing(p_PingTable)
	m_Ping:UpdateLocalPlayerPing(p_PingTable)
end

function BetterIngameAdmin:OnLevelLoadingInfo(p_ScreenInfo)
	m_LoadingScreen:OnLevelLoadingInfo(p_ScreenInfo)
	m_MinimapConfig:OnLevelLoadingInfo(p_ScreenInfo)
	m_Scoreboard:OnLevelLoadingInfo(p_ScreenInfo)
end

function BetterIngameAdmin:OnLevelDestroy()
	m_ZoomLevel:OnLevelDestroy()
	m_Scoreboard:OnLevelDestroy()
	m_LoadingScreen:OnLevelDestroy()
end

BetterIngameAdmin()
