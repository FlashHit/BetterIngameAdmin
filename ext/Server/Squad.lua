---@class Squad
Squad = class 'Squad'

local m_GeneralSettings = require('GeneralSettings')

function Squad:__init()
	NetEvents:Subscribe('LeaveSquad', self, self.OnLeaveSquad)
	NetEvents:Subscribe('CreateSquad', self, self.OnCreateSquad)
	NetEvents:Subscribe('JoinSquad', self, self.OnJoinSquad)
	-- if player is SqLeader
	NetEvents:Subscribe('PrivateSquad', self, self.OnPrivateSquad)
	NetEvents:Subscribe('KickFromSquad', self, self.OnKickFromSquad)
	NetEvents:Subscribe('MakeSquadLeader', self, self.OnMakeSquadLeader)
end

function Squad:OnLeaveSquad(p_Player)
	p_Player.squadId = SquadId.SquadNone
	local s_Messages = {}
	s_Messages[1] = "Left Squad."
	s_Messages[2] = "You left the squad."
	NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
end

function Squad:OnCreateSquad(p_Player)
	for i = 1, 32 do
		if TeamSquadManager:GetSquadPlayerCount(p_Player.teamId, i) == 0 then
			p_Player.squadId = i
			RCON:SendCommand('squad.private', {tostring(p_Player.teamId), tostring(p_Player.squadId), "false"})
			local s_Messages = {}
			s_Messages[1] = "Create Squad."
			s_Messages[2] = "You created a squad with the ID: ".. p_Player.squadId .."."
			NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
			return
		end
	end
end

function Squad:OnJoinSquad(p_Player, p_PlayerName)
	local s_Messages = {}
	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_PlayerName)
	if s_TargetPlayer ~= nil then
		if p_Player.teamId == s_TargetPlayer.teamId and s_TargetPlayer.isSquadPrivate == false and m_GeneralSettings:GetSquadSize() > TeamSquadManager:GetSquadPlayerCount(s_TargetPlayer.teamId, s_TargetPlayer.squadId) then
			p_Player.squadId = s_TargetPlayer.squadId
			s_Messages = {}
			s_Messages[1] = "Squad Joined."
			s_Messages[2] = "You joined the squad with the ID: ".. p_Player.squadId .."."
			NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		else
			s_Messages = {}
			s_Messages[1] = "Error."
			s_Messages[2] = "You couldn't join the squad with the ID: ".. p_Player.squadId ..". Maybe the squad is full or private."
			NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		end
	end
end

function Squad:OnPrivateSquad(p_Player)
	local s_Messages = {}
	if p_Player.isSquadPrivate == false and p_Player.isSquadLeader == true then
		RCON:SendCommand('squad.private', {tostring(p_Player.teamId), tostring(p_Player.squadId), "true"})
		s_Messages = {}
		s_Messages[1] = "Squad private."
		s_Messages[2] = "Your squad with the ID: ".. p_Player.squadId .." is now private."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
	else
		RCON:SendCommand('squad.private', {tostring(p_Player.teamId), tostring(p_Player.squadId), "false"})
		s_Messages = {}
		s_Messages[1] = "Squad not private."
		s_Messages[2] = "Your squad with the ID: ".. p_Player.squadId .." is now NOT private."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
	end
end

function Squad:OnKickFromSquad(p_Player, p_PlayerName)
	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_PlayerName)
	if s_TargetPlayer ~= nil and p_Player.isSquadLeader == true then
		s_TargetPlayer.squadId = SquadId.SquadNone
		local s_Messages = {}
		s_Messages[1] = "Player kicked from Squad."
		s_Messages[2] = "You kicked the player ".. s_TargetPlayer.name .." from your squad."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
	end
end

function Squad:OnMakeSquadLeader(p_Player, p_PlayerName)
	local s_TargetPlayer = PlayerManager:GetPlayerByName(p_PlayerName)
	if s_TargetPlayer ~= nil and p_Player.isSquadLeader == true then
		RCON:SendCommand('squad.leader', {tostring(s_TargetPlayer.teamId), tostring(s_TargetPlayer.squadId), p_PlayerName})
		local s_Messages = {}
		s_Messages[1] = "Player is now Squad Leader."
		s_Messages[2] = "You promoted the player ".. s_TargetPlayer.name .." to your squad leader and demoted yourself to a normal squad member."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
	end
end

if g_Squad == nil then
	g_Squad = Squad()
end

return g_Squad
