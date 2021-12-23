---@class GameAdmin
GameAdmin = class 'GameAdmin'

function GameAdmin:__init()
	self.m_AdminList = {}

	Events:Subscribe('GameAdmin:Player', self, self.OnGameAdminPlayer)
	Events:Subscribe('GameAdmin:Clear', self, self.OnGameAdminClear)
end

function GameAdmin:OnGameAdminPlayer(p_PlayerName, p_Abilities)
	self.m_AdminList[p_PlayerName] = p_Abilities
	local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)
	if s_Player ~= nil then
		NetEvents:SendTo('AdminPlayer', s_Player, p_Abilities)
	end
end

function GameAdmin:OnGameAdminClear()
	for l_AdminName, l_Abilities in pairs(self.m_AdminList) do
		local s_Admin = PlayerManager:GetPlayerByName(l_AdminName)
		if s_Admin ~= nil then
			NetEvents:SendTo('AdminPlayer', s_Admin)
		end
	end
	self.m_AdminList = {}
end

function GameAdmin:OnAuthenticated(p_Player)
	if self:IsAdmin(p_Player.name) then
		NetEvents:SendTo('AdminPlayer', p_Player, self.m_AdminList[p_Player.name])
		print("ADMIN - ADMIN JOINED - Admin " .. p_Player.name .. " has joined the server.")
	end
end

function GameAdmin:IsAdmin(p_PlayerName)
	if self.m_AdminList[p_PlayerName] then
		return true
	else
		return false
	end
end

function GameAdmin:CanMovePlayers(p_PlayerName)
	if self.m_AdminList[p_PlayerName] and self.m_AdminList[p_PlayerName].canMovePlayers then
		return true
	else
		return false
	end
end

function GameAdmin:CanKillPlayers(p_PlayerName)
	if self.m_AdminList[p_PlayerName] and self.m_AdminList[p_PlayerName].canKillPlayers then
		return true
	else
		return false
	end
end

function GameAdmin:CanKickPlayers(p_PlayerName)
	if self.m_AdminList[p_PlayerName] and self.m_AdminList[p_PlayerName].canKickPlayers then
		return true
	else
		return false
	end
end

function GameAdmin:CanTemporaryBanPlayers(p_PlayerName)
	if self.m_AdminList[p_PlayerName] and self.m_AdminList[p_PlayerName].canTemporaryBanPlayers then
		return true
	else
		return false
	end
end

function GameAdmin:CanPermanentlyBanPlayers(p_PlayerName)
	if self.m_AdminList[p_PlayerName] and self.m_AdminList[p_PlayerName].canPermanentlyBanPlayers then
		return true
	else
		return false
	end
end

function GameAdmin:CanEditGameAdminList(p_PlayerName)
	if self.m_AdminList[p_PlayerName] and self.m_AdminList[p_PlayerName].canEditGameAdminList then
		return true
	else
		return false
	end
end

function GameAdmin:CanUseMapFunctions(p_PlayerName)
	if self.m_AdminList[p_PlayerName] and self.m_AdminList[p_PlayerName].canUseMapFunctions then
		return true
	else
		return false
	end
end

function GameAdmin:CanAlterServerSettings(p_PlayerName)
	if self.m_AdminList[p_PlayerName] and self.m_AdminList[p_PlayerName].canAlterServerSettings then
		return true
	else
		return false
	end
end

function GameAdmin:GetAdminRightsOfPlayer(p_PlayerName)
	return self.m_AdminList[p_PlayerName]
end

if g_GameAdmin == nil then
	g_GameAdmin = GameAdmin()
end

return g_GameAdmin
