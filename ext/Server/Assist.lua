class 'Assist'

local m_ModSettings = require('ModSettings')

function Assist:__init()
	self.m_QueueAssistList1 = {}
	self.m_QueueAssistList2 = {}
	self.m_QueueAssistList3 = {}
	self.m_QueueAssistList4 = {}

	-- Region Player Assist enemy team
	NetEvents:Subscribe('AssistEnemyTeam', self, self.OnAssistEnemyTeam)
	NetEvents:Subscribe('CancelAssistEnemyTeam', self, self.OnCancelAssistEnemyTeam)

	-- self:OnQueueAssistEnemyTeam(player)
	-- self:CheckQueueAssist()
	-- self:AssistTarget(player, isInQueueList)
	-- Endregion
end

function Assist:OnAuthenticated(p_Player)
	if m_ModSettings:GetEnableAssistFunction() then
		self:CheckQueueAssist()
	end
end

function Assist:OnAssistEnemyTeam(p_Player)
	--print("ASSIST - Player " .. player.name .. " want to assist the enemy team.")
	if m_ModSettings:GetEnableAssistFunction() then
		self:AssistTarget(p_Player, 0)
	else
		local s_Messages = {}
		s_Messages[1] = "Assist Deactivated."
		s_Messages[2] = "Sorry, we couldn't switch you. The assist function is currently deactivated."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
	end
end

function Assist:OnQueueAssistEnemyTeam(p_Player)
	local s_Messages = {}
	s_Messages[1] = "Assist Queue."
	s_Messages[2] = "Sorry, we couldn't switch you. We will switch you when it is possible. You are now in the Assist Queue."
	NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
	print("ASSIST - QUEUE - Player " .. p_Player.name .. " is now in the assist queue.")

	if p_Player.teamId == TeamId.Team1 then
		table.insert(self.m_QueueAssistList1, p_Player.name)
	elseif p_Player.teamId == TeamId.Team2 then
		table.insert(self.m_QueueAssistList2, p_Player.name)
	elseif p_Player.teamId == TeamId.Team3 then
		table.insert(self.m_QueueAssistList3, p_Player.name)
	else
		table.insert(self.m_QueueAssistList4, p_Player.name)
	end
end

function Assist:OnPlayerLeft(p_Player)
	if m_ModSettings:GetEnableAssistFunction() then
		self:CheckQueueAssist()
	end
end

function Assist:CheckQueueAssist()
	::continue1::
	if self.m_QueueAssistList1[1] ~= nil then
		local s_Player = PlayerManager:GetPlayerByName(self.m_QueueAssistList1[1])
		if s_Player == nil then
			table.remove(self.m_QueueAssistList1, 1)
			goto continue1
		end
		self:AssistTarget(s_Player, 1)
	end
	::continue2::
	if self.m_QueueAssistList2[1] ~= nil then
		local s_Player = PlayerManager:GetPlayerByName(self.m_QueueAssistList2[1])
		if s_Player == nil then
			table.remove(self.m_QueueAssistList2, 1)
			goto continue2
		end
		self:AssistTarget(s_Player, 2)
	end
	::continue3::
	if self.m_QueueAssistList3[1] ~= nil then
		local s_Player = PlayerManager:GetPlayerByName(self.m_QueueAssistList3[1])
		if s_Player == nil then
			table.remove(self.m_QueueAssistList3, 1)
			goto continue3
		end
		self:AssistTarget(s_Player, 3)
	end
	::continue4::
	if self.m_QueueAssistList4[1] ~= nil then
		local s_Player = PlayerManager:GetPlayerByName(self.m_QueueAssistList4[1])
		if s_Player == nil then
			table.remove(self.m_QueueAssistList4, 1)
			goto continue4
		end
		self:AssistTarget(s_Player, 4)
	end
end

function Assist:AssistTarget(p_Player, p_IsInQueueList)
	local s_CurrentTeamCount = 0
	local s_EnemyTeamCount = 0
	local s_CurrentTeamTickets = 0
	local s_EnemyTeamTickets = 0
	local s_EnemyTeam1Count = 0
	local s_EnemyTeam2Count = 0
	local s_EnemyTeam3Count = 0
	local s_EnemyTeam1Tickets = 0
	local s_EnemyTeam2Tickets = 0
	local s_EnemyTeam3Tickets = 0
	local s_CurrentTeam = 0
	local s_EnemyTeam1 = 0
	local s_EnemyTeam2 = 0
	local s_EnemyTeam3 = 0
	local s_GameMode = SharedUtils:GetCurrentGameMode()
	if s_GameMode ~= "SquadDeathMatch0" then
		if p_Player.teamId == TeamId.Team1 then
			s_CurrentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			s_EnemyTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			s_CurrentTeamTickets = TicketManager:GetTicketCount(TeamId.Team1)
			s_EnemyTeamTickets = TicketManager:GetTicketCount(TeamId.Team2)
		else
			s_CurrentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			s_EnemyTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			s_CurrentTeamTickets = TicketManager:GetTicketCount(TeamId.Team2)
			s_EnemyTeamTickets = TicketManager:GetTicketCount(TeamId.Team1)
		end
		if s_CurrentTeamCount > (s_EnemyTeamCount + 1) or (s_CurrentTeamTickets >= s_EnemyTeamTickets and s_CurrentTeamCount > (s_EnemyTeamCount - 2)) then
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			if p_Player.teamId == TeamId.Team1 then
				p_Player.teamId = TeamId.Team2
			else
				p_Player.teamId = TeamId.Team1
			end
			if p_IsInQueueList == 1 then
				table.remove(self.m_QueueAssistList1, 1)
			elseif p_IsInQueueList == 2 then
				table.remove(self.m_QueueAssistList2, 1)
			end
			local s_Messages = {}
			s_Messages[1] = "Assist Enemy Team."
			s_Messages[2] = "You have been switched because of your assist request."
			NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
			print("ASSIST - MOVE - Player " .. p_Player.name .. " is now helping the enemy team " .. p_Player.teamId .. ".")
		else
			if p_IsInQueueList == 0 then
				self:QuickSwitch(p_Player)
			end
		end
	else
		if p_Player.teamId == TeamId.Team1 then
			s_CurrentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			s_EnemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			s_EnemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			s_EnemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			s_CurrentTeamTickets = TicketManager:GetTicketCount(TeamId.Team1)
			s_EnemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team2)
			s_EnemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team3)
			s_EnemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team4)
			s_CurrentTeam = TeamId.Team1
			s_EnemyTeam1 = TeamId.Team2
			s_EnemyTeam2 = TeamId.Team3
			s_EnemyTeam3 = TeamId.Team4
		elseif p_Player.teamId == TeamId.Team2 then
			s_CurrentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			s_EnemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			s_EnemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			s_EnemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			s_CurrentTeamTickets = TicketManager:GetTicketCount(TeamId.Team2)
			s_EnemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team1)
			s_EnemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team3)
			s_EnemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team4)
			s_CurrentTeam = TeamId.Team2
			s_EnemyTeam1 = TeamId.Team1
			s_EnemyTeam2 = TeamId.Team3
			s_EnemyTeam3 = TeamId.Team4
		elseif p_Player.teamId == TeamId.Team3 then
			s_CurrentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			s_EnemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			s_EnemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			s_EnemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			s_CurrentTeamTickets = TicketManager:GetTicketCount(TeamId.Team3)
			s_EnemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team1)
			s_EnemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team2)
			s_EnemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team4)
			s_CurrentTeam = TeamId.Team3
			s_EnemyTeam1 = TeamId.Team1
			s_EnemyTeam2 = TeamId.Team2
			s_EnemyTeam3 = TeamId.Team4
		else
			s_CurrentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			s_EnemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			s_EnemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			s_EnemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			s_CurrentTeamTickets = TicketManager:GetTicketCount(TeamId.Team4)
			s_EnemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team1)
			s_EnemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team2)
			s_EnemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team3)
			s_CurrentTeam = TeamId.Team4
			s_EnemyTeam1 = TeamId.Team1
			s_EnemyTeam2 = TeamId.Team2
			s_EnemyTeam3 = TeamId.Team3
		end
		if s_CurrentTeamCount > (s_EnemyTeam1Count + 1) or (s_CurrentTeamTickets >= s_EnemyTeam1Tickets and s_CurrentTeamCount > (s_EnemyTeam1Count - 2)) then
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			p_Player.teamId = s_EnemyTeam1
			if p_IsInQueueList == 1 then
				table.remove(self.m_QueueAssistList1, 1)
			elseif p_IsInQueueList == 2 then
				table.remove(self.m_QueueAssistList2, 1)
			elseif p_IsInQueueList == 3 then
				table.remove(self.m_QueueAssistList3, 1)
			elseif p_IsInQueueList == 4 then
				table.remove(self.m_QueueAssistList4, 1)
			end
			local s_Messages = {}
			s_Messages[1] = "Assist Enemy Team."
			s_Messages[2] = "You have been switched because of your assist request."
			NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
			print("ASSIST - MOVE - Player " .. p_Player.name .. " is now helping the enemy team " .. p_Player.teamId .. ".")
		elseif s_CurrentTeamCount > (s_EnemyTeam2Count + 1) or (s_CurrentTeamTickets >= s_EnemyTeam2Tickets and s_CurrentTeamCount > (s_EnemyTeam2Count - 2)) then
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			p_Player.teamId = s_EnemyTeam2
			if p_IsInQueueList == 1 then
				table.remove(self.m_QueueAssistList1, 1)
			elseif p_IsInQueueList == 2 then
				table.remove(self.m_QueueAssistList2, 1)
			elseif p_IsInQueueList == 3 then
				table.remove(self.m_QueueAssistList3, 1)
			elseif p_IsInQueueList == 4 then
				table.remove(self.m_QueueAssistList4, 1)
			end
			local s_Messages = {}
			s_Messages[1] = "Assist Enemy Team."
			s_Messages[2] = "You have been switched because of your assist request."
			NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
			print("ASSIST - MOVE - Player " .. p_Player.name .. " is now helping the enemy team " .. p_Player.teamId .. ".")
		elseif s_CurrentTeamCount > (s_EnemyTeam3Count + 1) or (s_CurrentTeamTickets >= s_EnemyTeam3Tickets and s_CurrentTeamCount > (s_EnemyTeam3Count - 2)) then
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			p_Player.teamId = s_EnemyTeam3
			if p_IsInQueueList == 1 then
				table.remove(self.m_QueueAssistList1, 1)
			elseif p_IsInQueueList == 2 then
				table.remove(self.m_QueueAssistList2, 1)
			elseif p_IsInQueueList == 3 then
				table.remove(self.m_QueueAssistList3, 1)
			elseif p_IsInQueueList == 4 then
				table.remove(self.m_QueueAssistList4, 1)
			end
			local s_Messages = {}
			s_Messages[1] = "Assist Enemy Team."
			s_Messages[2] = "You have been switched because of your assist request."
			NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
			print("ASSIST - MOVE - Player " .. p_Player.name .. " is now helping the enemy team " .. p_Player.teamId .. ".")
		else
			if p_IsInQueueList == 0 then
				self:QuickSwitch(p_Player)
			end
		end
	end
end

function Assist:QuickSwitch(p_Player)
	local s_PlayerTeamId = p_Player.teamId
	local s_ListPlayer = nil
	if p_Player.teamId == TeamId.Team1 then
		::continue12::
		if self.m_QueueAssistList2[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList2[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList2, 1)
				goto continue12
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team1
			p_Player.teamId = TeamId.Team2
			table.remove(self.m_QueueAssistList2, 1)
		end
		::continue13::
		if self.m_QueueAssistList3[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList3[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList3, 1)
				goto continue13
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team1
			p_Player.teamId = TeamId.Team3
			table.remove(self.m_QueueAssistList3, 1)
		end
		::continue14::
		if self.m_QueueAssistList4[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList4[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList4, 1)
				goto continue14
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team1
			p_Player.teamId = TeamId.Team4
			table.remove(self.m_QueueAssistList4, 1)
		end
	elseif p_Player.teamId == TeamId.Team2 then
		::continue21::
		if self.m_QueueAssistList1[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList1[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList1, 1)
				goto continue21
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team2
			p_Player.teamId = TeamId.Team1
			table.remove(self.m_QueueAssistList1, 1)
		end
		::continue23::
		if self.m_QueueAssistList3[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList3[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList3, 1)
				goto continue23
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team2
			p_Player.teamId = TeamId.Team3
			table.remove(self.m_QueueAssistList3, 1)
		end
		::continue24::
		if self.m_QueueAssistList4[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList4[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList4, 1)
				goto continue24
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team2
			p_Player.teamId = TeamId.Team4
			table.remove(self.m_QueueAssistList4, 1)
		end
	elseif p_Player.teamId == TeamId.Team3 then
		::continue31::
		if self.m_QueueAssistList1[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList1[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList1, 1)
				goto continue31
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team3
			p_Player.teamId = TeamId.Team1
			table.remove(self.m_QueueAssistList1, 1)
		end
		::continue32::
		if self.m_QueueAssistList2[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList2[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList2, 1)
				goto continue32
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team3
			p_Player.teamId = TeamId.Team2
			table.remove(self.m_QueueAssistList2, 1)
		end
		::continue34::
		if self.m_QueueAssistList4[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList4[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList4, 1)
				goto continue34
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team3
			p_Player.teamId = TeamId.Team4
			table.remove(self.m_QueueAssistList4, 1)
		end
	else
		::continue41::
		if self.m_QueueAssistList1[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList1[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList1, 1)
				goto continue41
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team4
			p_Player.teamId = TeamId.Team1
			table.remove(self.m_QueueAssistList1, 1)
		end
		::continue42::
		if self.m_QueueAssistList2[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList2[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList2, 1)
				goto continue42
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team4
			p_Player.teamId = TeamId.Team2
			table.remove(self.m_QueueAssistList2, 1)
		end
		::continue43::
		if self.m_QueueAssistList3[1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList3[1])
			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList3, 1)
				goto continue43
			end
			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end
			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end
			s_ListPlayer.teamId = TeamId.Team4
			p_Player.teamId = TeamId.Team3
			table.remove(self.m_QueueAssistList3, 1)
		end
	end
	if s_PlayerTeamId == p_Player.teamId then
		self:OnQueueAssistEnemyTeam(p_Player)
	else
		local s_Messages = {}
		s_Messages[1] = "Assist Enemy Team."
		s_Messages[2] = "You have been switched because of your assist request."
		NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
		print("ASSIST - MOVE - Player " .. p_Player.name .. " is now helping the enemy team " .. p_Player.teamId .. ".")
		s_Messages = {}
		s_Messages[1] = "Assist Enemy Team."
		s_Messages[2] = "You have been switched because of your assist request."
		NetEvents:SendTo('PopupResponse', s_ListPlayer, s_Messages)
		print("ASSIST - MOVE - Player " .. s_ListPlayer.name .. " is now helping the enemy team " .. s_ListPlayer.teamId .. ".")
	end
end

function Assist:OnCancelAssistEnemyTeam(p_Player)
	if p_Player.teamId == 1 then
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList1) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList1, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList2) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList2, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList3) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList3, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList4) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList4, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		-- Error you are in no queue
	elseif p_Player.teamId == 2 then
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList2) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList2, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList1) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList1, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList3) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList3, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList4) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList4, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		-- Error you are in no queue
	elseif p_Player.teamId == 3 then
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList3) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList3, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList1) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList1, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList2) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList2, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList4) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList4, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		-- Error you are in no queue
	elseif p_Player.teamId == 4 then
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList4) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList4, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList1) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList1, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList2) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList2, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i, l_ListPlayerName in pairs(self.m_QueueAssistList3) do
			if p_Player.name == l_ListPlayerName then
				table.remove(self.m_QueueAssistList3, i)
				local s_Messages = {}
				s_Messages[1] = "Assist Queue Cancelled."
				s_Messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		-- Error you are in no queue
		print("ASSIST - CANCEL Error - Player " .. p_Player.name .. " was in no assist queue.")
	end
end

if g_Assist == nil then
	g_Assist = Assist()
end

return g_Assist
