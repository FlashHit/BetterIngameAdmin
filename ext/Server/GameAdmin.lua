class 'GameAdmin'

function GameAdmin:__init()
    self.adminList = {}
    
	Events:Subscribe('GameAdmin:Player', self, self.OnGameAdminPlayer)
	Events:Subscribe('GameAdmin:Clear', self, self.OnGameAdminClear)
end

function GameAdmin:OnGameAdminPlayer(playerName, abilitities)
	self.adminList[playerName] = abilitities
	local player = PlayerManager:GetPlayerByName(playerName)
	if player ~= nil then
		NetEvents:SendTo('AdminPlayer', player, abilitities)
	end
end

function GameAdmin:OnGameAdminClear()
	for adminName,abilitities in pairs(self.adminList) do
		local admin = PlayerManager:GetPlayerByName(adminName)
		if admin ~= nil then
			NetEvents:SendTo('AdminPlayer', admin)
		end
	end
	self.adminList = {}
end

function GameAdmin:OnAuthenticated(p_Player)
	if self:IsAdmin(p_Player.name) then
		NetEvents:SendTo('AdminPlayer', p_Player, self.adminList[p_Player.name])
		print("ADMIN - ADMIN JOINED - Admin " .. p_Player.name .. " has joined the server.")
	end
end

function GameAdmin:IsAdmin(p_PlayerName)
    if self.adminList[p_PlayerName] then
        return true
    else
        return false
    end
end

function GameAdmin:CanMovePlayers(p_PlayerName)
    if self.adminList[p_PlayerName] and self.adminList[p_PlayerName].canMovePlayers then
        return true
    else
        return false
    end
end

function GameAdmin:CanKillPlayers(p_PlayerName)
    if self.adminList[p_PlayerName] and self.adminList[p_PlayerName].canKillPlayers then
        return true
    else
        return false
    end
end

function GameAdmin:CanKickPlayers(p_PlayerName)
    if self.adminList[p_PlayerName] and self.adminList[p_PlayerName].canKickPlayers then
        return true
    else
        return false
    end
end

function GameAdmin:CanTemporaryBanPlayers(p_PlayerName)
    if self.adminList[p_PlayerName] and self.adminList[p_PlayerName].canTemporaryBanPlayers then
        return true
    else
        return false
    end
end

function GameAdmin:CanPermanentlyBanPlayers(p_PlayerName)
    if self.adminList[p_PlayerName] and self.adminList[p_PlayerName].canPermanentlyBanPlayers then
        return true
    else
        return false
    end
end

function GameAdmin:CanEditGameAdminList(p_PlayerName)
    if self.adminList[p_PlayerName] and self.adminList[p_PlayerName].canEditGameAdminList then
        return true
    else
        return false
    end
end

function GameAdmin:CanUseMapFunctions(p_PlayerName)
    if self.adminList[p_PlayerName] and self.adminList[p_PlayerName].canUseMapFunctions then
        return true
    else
        return false
    end
end

function GameAdmin:CanAlterServerSettings(p_PlayerName)
    if self.adminList[p_PlayerName] and self.adminList[p_PlayerName].canAlterServerSettings then
        return true
    else
        return false
    end
end

function GameAdmin:GetAdminRightsOfPlayer(p_PlayerName)
    return self.adminList[p_PlayerName]
end

return GameAdmin