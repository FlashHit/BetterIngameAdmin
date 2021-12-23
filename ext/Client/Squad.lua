---@class Squad
Squad = class 'Squad'

function Squad:__init()
	Events:Subscribe('WebUI:LeaveSquad', self, self.OnWebUILeaveSquad)
	Events:Subscribe('WebUI:CreateSquad', self, self.OnWebUICreateSquad)
	Events:Subscribe('WebUI:JoinSquad', self, self.OnWebUIJoinSquad)

	-- if you are the squad leader
	Events:Subscribe('WebUI:PrivateSquad', self, self.OnWebUIPrivateSquad)
	Events:Subscribe('WebUI:KickFromSquad', self, self.OnWebUIKickFromSquad)
	Events:Subscribe('WebUI:MakeSquadLeader', self, self.OnWebUIMakeSquadLeader)
end

function Squad:OnWebUILeaveSquad()
	NetEvents:Send('LeaveSquad')
end

function Squad:OnWebUICreateSquad()
	NetEvents:Send('CreateSquad')
end

function Squad:OnWebUIJoinSquad(p_PlayerName)
	NetEvents:Send('JoinSquad', p_PlayerName)
end

function Squad:OnWebUIPrivateSquad()
	NetEvents:Send('PrivateSquad')
end

function Squad:OnWebUIKickFromSquad(p_PlayerName)
	NetEvents:Send('KickFromSquad', p_PlayerName)
end

function Squad:OnWebUIMakeSquadLeader(p_PlayerName)
	NetEvents:Send('MakeSquadLeader', p_PlayerName)
end

return Squad()
