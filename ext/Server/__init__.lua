---@class BetterIngameAdmin
BetterIngameAdmin = class 'BetterIngameAdmin'

require('Admin')
---@type Assist
local m_Assist = require('Assist')
---@type GameAdmin
local m_GameAdmin = require('GameAdmin')
---@type GeneralSettings
local m_GeneralSettings = require('GeneralSettings')
---@type LoadingScreen
local m_LoadingScreen = require('LoadingScreen')
---@type ModSettings
local m_ModSettings = require('ModSettings')
---@type Ping
local m_Ping = require('Ping')
---@type ServerOwner
local m_ServerOwner = require('ServerOwner')
require('Squad')
---@type Voting
local m_Voting = require('Voting')

function BetterIngameAdmin:__init()
	Events:Subscribe('Extension:Loaded', self, self.OnExtensionLoaded)
end

function BetterIngameAdmin:OnExtensionLoaded()
	print("Initializing BetterIngameAdmin")
	self.m_HotReloadTimer = 0
	self.m_IsHotReload = self:GetIsHotReload()
	self:RegisterEvents()
end

function BetterIngameAdmin:RegisterEvents()
	Events:Subscribe('Engine:Init', self, self.OnEngineInit)
	Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
	Events:Subscribe('Player:Left', self, self.OnPlayerLeft)
	Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
	Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
	Events:Subscribe('Player:Authenticated', self, self.OnAuthenticated)
end

function BetterIngameAdmin:OnEngineInit()
	self.m_IsLatestVersion = require 'updateCheck'
end

function BetterIngameAdmin:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_Voting:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	m_Ping:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)

	if not self.m_IsHotReload then
		return
	end

	self.m_HotReloadTimer = self.m_HotReloadTimer + p_DeltaTime

	if self.m_HotReloadTimer > 1 then
		self.m_IsHotReload = false
		self.m_HotReloadTimer = 0
		self:OnLevelLoaded()
		local s_Players = PlayerManager:GetPlayers()

		if s_Players == nil or #s_Players == 0 then
			return
		end

		for _, l_Player in pairs(s_Players) do
			m_ServerOwner:OnAuthenticated(l_Player)
			m_GameAdmin:OnAuthenticated(l_Player)
		end
	end
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

function BetterIngameAdmin:GetIsHotReload()
	if #SharedUtils:GetContentPackages() == 0 then
		return false
	else
		return true
	end
end

BetterIngameAdmin()
