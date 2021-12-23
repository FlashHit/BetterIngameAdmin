---@class Assist
Assist = class 'Assist'

---@type ModSettings
local m_ModSettings = require('ModSettings')

function Assist:__init()
	self.m_QueueAssistList = {{}, {}, {}, {}}

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

	table.insert(self.m_QueueAssistList[p_Player.teamId], p_Player.name)
end

function Assist:OnPlayerLeft(p_Player)
	if m_ModSettings:GetEnableAssistFunction() then
		self:CheckQueueAssist()
	end
end

function Assist:CheckQueueAssist()
	for l_TeamId = 1, 4 do
		::continue::

		if self.m_QueueAssistList[l_TeamId][1] ~= nil then
			local s_Player = PlayerManager:GetPlayerByName(self.m_QueueAssistList[l_TeamId][1])

			if s_Player == nil then
				table.remove(self.m_QueueAssistList[l_TeamId], 1)
				goto continue
			end

			self:AssistTarget(s_Player, l_TeamId)
		end
	end
end

function Assist:AssistTarget(p_Player, p_IsInQueueList)
	local s_CurrentTeamCount = TeamSquadManager:GetTeamPlayerCount(p_Player.teamId)
	local s_CurrentTeamTickets = TicketManager:GetTicketCount(p_Player.teamId)
	local s_EnemyTeams = 2
	local s_CurrentGameMode = SharedUtils:GetCurrentGameMode()

	if s_CurrentGameMode ~= nil and s_CurrentGameMode == "SquadDeathMatch0" then
		s_EnemyTeams = 4
	end

	for l_TeamId = 1, s_EnemyTeams do
		local s_EnemyTeamCount = TeamSquadManager:GetTeamPlayerCount(l_TeamId)
		local s_EnemyTeamTickets = TicketManager:GetTicketCount(l_TeamId)

		local RCON_Response = RCON:SendCommand('vars.gameModeCounter')
		local s_GameModeCounter = tonumber(RCON_Response[2]) / 100

		if s_CurrentGameMode ~= nil then
			if s_CurrentGameMode == "RushLarge0" then
				if s_EnemyTeamTickets >= 751 then
					s_EnemyTeamTickets = s_EnemyTeamTickets - (924 * s_GameModeCounter)
				elseif s_CurrentTeamTickets >= 751 then
					s_CurrentTeamTickets = s_CurrentTeamTickets - (924 * s_GameModeCounter)
				end
			elseif s_CurrentGameMode == "SquadRush0" then
				if s_EnemyTeamTickets >= 201 then
					s_EnemyTeamTickets = s_EnemyTeamTickets - (979 * s_GameModeCounter)
				elseif s_CurrentTeamTickets >= 201 then
					s_CurrentTeamTickets = s_CurrentTeamTickets - (979 * s_GameModeCounter)
				end
			end
		end

		if l_TeamId ~= p_Player.teamId then
			if s_CurrentTeamCount > s_EnemyTeamCount or (s_CurrentTeamTickets >= s_EnemyTeamTickets and s_CurrentTeamCount > (s_EnemyTeamCount - 2)) then
				if p_Player.alive == true then
					RCON:SendCommand('admin.killPlayer', {p_Player.name})
				end

				p_Player.teamId = l_TeamId

				if p_IsInQueueList ~= 0 then
					table.remove(self.m_QueueAssistList[p_IsInQueueList], 1)
				end

				local s_Messages = {}
				s_Messages[1] = "Assist Enemy Team."
				s_Messages[2] = "You have been switched because of your assist request."
				NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
				print("ASSIST - MOVE - Player " .. p_Player.name .. " is now helping the enemy team " .. p_Player.teamId .. ".")
				return
			end
		end
	end

	if p_IsInQueueList == 0 then
		self:QuickSwitch(p_Player)
	end
end

function Assist:QuickSwitch(p_Player)
	local s_PlayerTeamId = p_Player.teamId
	local s_ListPlayer = nil

	for l_TeamId = 1, 4 do
		::__continue__::

		if l_TeamId ~= p_Player.teamId and self.m_QueueAssistList[l_TeamId][1] ~= nil then
			s_ListPlayer = PlayerManager:GetPlayerByName(self.m_QueueAssistList[l_TeamId][1])

			if s_ListPlayer == nil then
				table.remove(self.m_QueueAssistList[l_TeamId], 1)
				goto __continue__
			end

			if s_ListPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {s_ListPlayer.name})
			end

			if p_Player.alive == true then
				RCON:SendCommand('admin.killPlayer', {p_Player.name})
			end

			s_ListPlayer.teamId = TeamId.Team1
			p_Player.teamId = TeamId.Team2
			table.remove(self.m_QueueAssistList[l_TeamId], 1)
		end
	end

	-- If it didn't work then we do this
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
	for i, l_ListPlayerName in pairs(self.m_QueueAssistList[p_Player.teamId]) do
		if p_Player.name == l_ListPlayerName then
			table.remove(self.m_QueueAssistList[p_Player.teamId], i)
			local s_Messages = {}
			s_Messages[1] = "Assist Queue Cancelled."
			s_Messages[2] = "We removed you from the assist queue."
			NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
			print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
			return
		end
	end

	-- if he is not in the list for his team, then maybe he is stuck in some other queuelist :o
	-- so this shouldn't happen
	for l_TeamId = 1, 4 do
		if l_TeamId ~= p_Player.teamId then
			for i, l_ListPlayerName in pairs(self.m_QueueAssistList[l_TeamId]) do
				if p_Player.name == l_ListPlayerName then
					table.remove(self.m_QueueAssistList[l_TeamId], i)
					local s_Messages = {}
					s_Messages[1] = "Assist Queue Cancelled."
					s_Messages[2] = "We removed you from the assist queue."
					NetEvents:SendTo('PopupResponse', p_Player, s_Messages)
					print("ASSIST - CANCEL - Player " .. p_Player.name .. " cancelled the assist and was removed from the assist queue.")
					return
				end
			end
		end
	end

	-- Error you are in no queue
	print("ASSIST - CANCEL Error - Player " .. p_Player.name .. " was in no assist queue.")
end

return Assist()
