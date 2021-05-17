class 'BetterIngameAdmin'

require('Admin')
local m_Assist = require('Assist')
local m_GameAdmin = require('GameAdmin')
local m_GeneralSettings = require('GeneralSettings')
local m_LoadingScreen = require('LoadingScreen')
local m_ModSettings = require('ModSettings')
local m_Ping = require('Ping')
local m_ServerOwner = require('ServerOwner')
require('Squad')
local m_Voting = require('Voting')

function BetterIngameAdmin:__init()
	self.m_IsLatestVersion = require 'updateCheck'
	print("Initializing BetterIngameAdmin")
	self:RegisterEvents()
end

function BetterIngameAdmin:RegisterEvents()
	Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
	Events:Subscribe('Player:Left', self, self.OnPlayerLeft)
	Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
	Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
	Events:Subscribe('Player:Authenticated', self, self.OnAuthenticated)
end

function BetterIngameAdmin:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_Voting:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_Ping:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
end

function BetterIngameAdmin:OnPlayerLeft(p_Player)
	m_Assist:OnPlayerLeft(p_Player)
end

function BetterIngameAdmin:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
	m_GeneralSettings:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
	m_ModSettings:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
	m_LoadingScreen:OnLevelLoaded(p_LevelName, p_GameMode, p_Round, p_RoundsPerMap)
end

function BetterIngameAdmin:OnLevelDestroy()
	m_Voting:OnLevelDestroy()
	m_LoadingScreen:OnLevelDestroy()
end

function BetterIngameAdmin:OnAuthenticated(p_Player)
	m_ServerOwner:OnAuthenticated(p_Player)
	m_ModSettings:OnAuthenticated(p_Player)
	m_Assist:OnAuthenticated(p_Player)
	m_LoadingScreen:OnAuthenticated(p_Player)
	m_GameAdmin:OnAuthenticated(p_Player)
	m_GeneralSettings:OnAuthenticated(p_Player)
end

g_BetterIngameAdmin = BetterIngameAdmin()
