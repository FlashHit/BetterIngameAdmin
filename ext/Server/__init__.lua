class 'BetterIngameAdmin'

require('Admin')
require('Assist')
require('GameAdmin')
require('GeneralSettings')
require('LoadingScreen')
require('ModSettings')
require('Ping')
require('ServerOwner')
require('Squad')
require('Voting')

function BetterIngameAdmin:__init()

	self.isLatestVersion = require 'updateCheck'
    print("Initializing BetterIngameAdmin")
	self:RegisterEvents()
	
	self.m_GameAdmin = GameAdmin()
	self.m_GeneralSettings = GeneralSettings()
	self.m_LoadingScreen = LoadingScreen()
	self.m_ModSettings = ModSettings()
	self.m_Assist = Assist(self.m_ModSettings)
	self.m_Ping = Ping()
	self.m_Voting = Voting(self.m_GameAdmin, self.m_ModSettings)
	self.m_ServerOwner = ServerOwner(self.m_GeneralSettings)
	self.m_Squad = Squad(self.m_GeneralSettings)
	self.m_Admin = Admin(self.m_ModSettings, self.m_GameAdmin, self.m_GeneralSettings, self.m_ServerOwner)
end

function BetterIngameAdmin:RegisterEvents()
    Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
	Events:Subscribe('Player:Left', self, self.OnPlayerLeft)
	Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
	Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
    Events:Subscribe('Player:Authenticated', self, self.OnAuthenticated)
end

function BetterIngameAdmin:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	self.m_Voting:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	self.m_Ping:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
end

function BetterIngameAdmin:OnPlayerLeft(p_Player)
	self.m_Assist:OnPlayerLeft(p_Player)
end

function BetterIngameAdmin:OnLevelLoaded(levelName, gameMode, round, roundsPerMap)
	self.m_GeneralSettings:OnLevelLoaded(levelName, gameMode, round, roundsPerMap)
	self.m_ModSettings:OnLevelLoaded(levelName, gameMode, round, roundsPerMap)
	self.m_LoadingScreen:OnLevelLoaded(levelName, gameMode, round, roundsPerMap)
end

function BetterIngameAdmin:OnLevelDestroy()
	self.m_Voting:OnLevelDestroy()
	self.m_LoadingScreen:OnLevelDestroy()
end

function BetterIngameAdmin:OnAuthenticated(player)
	self.m_ServerOwner:OnAuthenticated(player)
	self.m_ModSettings:OnAuthenticated(player)
	self.m_Assist:OnAuthenticated(player)
	self.m_LoadingScreen:OnAuthenticated(player)
	self.m_GameAdmin:OnAuthenticated(player)
	self.m_GeneralSettings:OnAuthenticated(player)
end

g_BetterIngameAdmin = BetterIngameAdmin()