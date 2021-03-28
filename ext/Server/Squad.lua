class 'Squad'

function Squad:__init(p_GeneralSettings)
    self.m_GeneralSettings = p_GeneralSettings

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
	local messages = {}
	messages[1] = "Left Squad."
	messages[2] = "You left the squad."
	NetEvents:SendTo('PopupResponse', p_Player, messages)
end

function Squad:OnCreateSquad(p_Player)
	for i=1,32 do
		if TeamSquadManager:GetSquadPlayerCount(p_Player.teamId, i) == 0 then
			p_Player.squadId = i
			RCON:SendCommand('squad.private', {tostring(p_Player.teamId), tostring(p_Player.squadId), "false"})
			local messages = {}
			messages[1] = "Create Squad."
			messages[2] = "You created a squad with the ID: ".. p_Player.squadId .."."
			NetEvents:SendTo('PopupResponse', p_Player, messages)
			return
		end
	end
end

function Squad:OnJoinSquad(p_Player, p_PlayerName)
	local messages = {}
	local targetPlayer = PlayerManager:GetPlayerByName(p_PlayerName)
	if targetPlayer ~= nil then
		if p_Player.teamId == targetPlayer.teamId and targetPlayer.isSquadPrivate == false and tonumber(self.m_GeneralSettings.serverConfig[43]) > TeamSquadManager:GetSquadPlayerCount(targetPlayer.teamId, targetPlayer.squadId) then
			p_Player.squadId = targetPlayer.squadId
			messages = {}
			messages[1] = "Squad Joined."
			messages[2] = "You joined the squad with the ID: ".. p_Player.squadId .."."
			NetEvents:SendTo('PopupResponse', p_Player, messages)
		else
			messages = {}
			messages[1] = "Error."
			messages[2] = "You couldn't join the squad with the ID: ".. p_Player.squadId ..". Maybe the squad is full or private."
			NetEvents:SendTo('PopupResponse', p_Player, messages)
		end
	end
end

function Squad:OnPrivateSquad(p_Player)
	local messages = {}
	if p_Player.isSquadPrivate == false and p_Player.isSquadLeader == true then
		RCON:SendCommand('squad.private', {tostring(p_Player.teamId), tostring(p_Player.squadId), "true"})
		messages = {}
		messages[1] = "Squad private."
		messages[2] = "Your squad with the ID: ".. p_Player.squadId .." is now private."
		NetEvents:SendTo('PopupResponse', p_Player, messages)
	else
		RCON:SendCommand('squad.private', {tostring(p_Player.teamId), tostring(p_Player.squadId), "false"})
		messages = {}
		messages[1] = "Squad not private."
		messages[2] = "Your squad with the ID: ".. p_Player.squadId .." is now NOT private."
		NetEvents:SendTo('PopupResponse', p_Player, messages)
	end
end

function Squad:OnKickFromSquad(p_Player, p_PlayerName)
	local targetPlayer = PlayerManager:GetPlayerByName(p_PlayerName)
	if targetPlayer ~= nil and p_Player.isSquadLeader == true then
		targetPlayer.squadId = SquadId.SquadNone
		local messages = {}
		messages[1] = "Player kicked from Squad."
		messages[2] = "You kicked the player ".. targetPlayer.name .." from your squad."
		NetEvents:SendTo('PopupResponse', p_Player, messages)
	end
end

function Squad:OnMakeSquadLeader(p_Player, p_PlayerName)
	local targetPlayer = PlayerManager:GetPlayerByName(p_PlayerName)
	if targetPlayer ~= nil and p_Player.isSquadLeader == true then
		RCON:SendCommand('squad.leader', {tostring(targetPlayer.teamId), tostring(targetPlayer.squadId), p_PlayerName})
		local messages = {}
		messages[1] = "Player is now Squad Leader."
		messages[2] = "You promoted the player ".. targetPlayer.name .." to your squad leader and demoted yourself to a normal squad member."
		NetEvents:SendTo('PopupResponse', p_Player, messages)
	end
end

return Squad