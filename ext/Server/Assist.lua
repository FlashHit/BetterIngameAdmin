class 'Assist'

function Assist:__init(p_ModSettings)
    self.m_ModSettings = p_ModSettings

	self.queueAssistList1 = {}
	self.queueAssistList2 = {}
	self.queueAssistList3 = {}
    self.queueAssistList4 = {}
    
    -- Region Player Assist enemy team
	NetEvents:Subscribe('AssistEnemyTeam', self, self.OnAssistEnemyTeam)
	NetEvents:Subscribe('CancelAssistEnemyTeam', self, self.OnCancelAssistEnemyTeam)
	
	-- self:OnQueueAssistEnemyTeam(player)
	-- self:CheckQueueAssist()
	-- self:AssistTarget(player, isInQueueList)
	-- Endregion
end

function Assist:OnAuthenticated(p_Player)
	if self.m_ModSettings.enableAssistFunction == true then
		self:CheckQueueAssist()
	end
end

function Assist:OnAssistEnemyTeam(player)
	--print("ASSIST - Player " .. player.name .. " want to assist the enemy team.")
	if self.m_ModSettings.enableAssistFunction == true then
		self:AssistTarget(player, 0)
	else
		local messages = {}
		messages[1] = "Assist Deactivated."
		messages[2] = "Sorry, we couldn't switch you. The assist function is currently deactivated."
		NetEvents:SendTo('PopupResponse', player, messages)
	end
end

function Assist:OnQueueAssistEnemyTeam(player)
	local messages = {}
	messages[1] = "Assist Queue."
	messages[2] = "Sorry, we couldn't switch you. We will switch you when it is possible. You are now in the Assist Queue."
	NetEvents:SendTo('PopupResponse', player, messages)
	print("ASSIST - QUEUE - Player " .. player.name .. " is now in the assist queue.")
	
	if player.teamId == TeamId.Team1 then
		table.insert(self.queueAssistList1, player.name)
	elseif player.teamId == TeamId.Team2 then
		table.insert(self.queueAssistList2, player.name)
	elseif player.teamId == TeamId.Team3 then
		table.insert(self.queueAssistList3, player.name)
	else
		table.insert(self.queueAssistList4, player.name)
	end
end

function Assist:OnPlayerLeft(p_Player)
	if self.m_ModSettings.enableAssistFunction == true then
		self:CheckQueueAssist()
	end
end

function Assist:CheckQueueAssist()
	::continue1::
	if self.queueAssistList1[1] ~= nil then
		local player = PlayerManager:GetPlayerByName(self.queueAssistList1[1])
		if player == nil then
			table.remove(self.queueAssistList1, 1)
			goto continue1
		end
		self:AssistTarget(player, 1)
	end
	::continue2::
	if self.queueAssistList2[1] ~= nil then
		local player = PlayerManager:GetPlayerByName(self.queueAssistList2[1])
		if player == nil then
			table.remove(self.queueAssistList2, 1)
			goto continue2
		end
		self:AssistTarget(player, 2)
	end
	::continue3::
	if self.queueAssistList3[1] ~= nil then
		local player = PlayerManager:GetPlayerByName(self.queueAssistList3[1])
		if player == nil then
			table.remove(self.queueAssistList3, 1)
			goto continue3
		end
		self:AssistTarget(player, 3)
	end
	::continue4::
	if self.queueAssistList4[1] ~= nil then
		local player = PlayerManager:GetPlayerByName(self.queueAssistList4[1])
		if player == nil then
			table.remove(self.queueAssistList4, 1)
			goto continue4
		end
		self:AssistTarget(player, 4)
	end
end

function Assist:AssistTarget(player, isInQueueList)
	local currentTeamCount = 0
	local enemyTeamCount = 0
	local currentTeamTickets = 0
	local enemyTeamTickets = 0
	local enemyTeam1Count = 0
	local enemyTeam2Count = 0
	local enemyTeam3Count = 0
	local enemyTeam1Tickets = 0
	local enemyTeam2Tickets = 0
	local enemyTeam3Tickets = 0
	local currentTeam = 0
	local enemyTeam1 = 0
	local enemyTeam2 = 0
	local enemyTeam3 = 0
	local gameMode = SharedUtils:GetCurrentGameMode()
	if gameMode ~= "SquadDeathMatch0" then		
		if player.teamId == TeamId.Team1 then
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeamTickets = TicketManager:GetTicketCount(TeamId.Team2)
		else
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeamTickets = TicketManager:GetTicketCount(TeamId.Team1)
		end
		if currentTeamCount > (enemyTeamCount + 1) or (currentTeamTickets >= enemyTeamTickets and currentTeamCount > (enemyTeamCount - 2)) then
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			if player.teamId == TeamId.Team1 then
				player.teamId = TeamId.Team2
			else
				player.teamId = TeamId.Team1
			end
			if isInQueueList == 1 then
				table.remove(self.queueAssistList1, 1)
			elseif isInQueueList == 2 then
				table.remove(self.queueAssistList2, 1)
			end
			local messages = {}
			messages[1] = "Assist Enemy Team."
			messages[2] = "You have been switched because of your assist request."
			NetEvents:SendTo('PopupResponse', player, messages)
			print("ASSIST - MOVE - Player " .. player.name .. " is now helping the enemy team " .. player.teamId .. ".")
		else
			if isInQueueList == 0 then
				self:QuickSwitch(player)
			end
		end
	else
		if player.teamId == TeamId.Team1 then
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			enemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team3)
			enemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team4)
			currentTeam = TeamId.Team1
			enemyTeam1 = TeamId.Team2
			enemyTeam2 = TeamId.Team3
			enemyTeam3 = TeamId.Team4
		elseif player.teamId == TeamId.Team2 then
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			enemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team3)
			enemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team4)
			currentTeam = TeamId.Team2
			enemyTeam1 = TeamId.Team1
			enemyTeam2 = TeamId.Team3
			enemyTeam3 = TeamId.Team4
		elseif player.teamId == TeamId.Team3 then
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			enemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team3)
			enemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team4)
			currentTeam = TeamId.Team3
			enemyTeam1 = TeamId.Team1
			enemyTeam2 = TeamId.Team2
			enemyTeam3 = TeamId.Team4
		else
			currentTeamCount = TeamSquadManager:GetTeamPlayerCount(TeamId.Team4)
			enemyTeam1Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team1)
			enemyTeam2Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team2)
			enemyTeam3Count = TeamSquadManager:GetTeamPlayerCount(TeamId.Team3)
			currentTeamTickets = TicketManager:GetTicketCount(TeamId.Team4)
			enemyTeam1Tickets = TicketManager:GetTicketCount(TeamId.Team1)
			enemyTeam2Tickets = TicketManager:GetTicketCount(TeamId.Team2)
			enemyTeam3Tickets = TicketManager:GetTicketCount(TeamId.Team3)
			currentTeam = TeamId.Team4
			enemyTeam1 = TeamId.Team1
			enemyTeam2 = TeamId.Team2
			enemyTeam3 = TeamId.Team3
		end
		if currentTeamCount > (enemyTeam1Count + 1) or (currentTeamTickets >= enemyTeam1Tickets and currentTeamCount > (enemyTeam1Count - 2)) then
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			player.teamId = enemyTeam1
			if isInQueueList == 1 then
				table.remove(self.queueAssistList1, 1)
			elseif isInQueueList == 2 then
				table.remove(self.queueAssistList2, 1)
			elseif isInQueueList == 3 then
				table.remove(self.queueAssistList3, 1)
			elseif isInQueueList == 4 then
				table.remove(self.queueAssistList4, 1)
			end
			local messages = {}
			messages[1] = "Assist Enemy Team."
			messages[2] = "You have been switched because of your assist request."
			NetEvents:SendTo('PopupResponse', player, messages)
			print("ASSIST - MOVE - Player " .. player.name .. " is now helping the enemy team " .. player.teamId .. ".")
		elseif currentTeamCount > (enemyTeam2Count + 1) or (currentTeamTickets >= enemyTeam2Tickets and currentTeamCount > (enemyTeam2Count - 2)) then
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			player.teamId = enemyTeam2
			if isInQueueList == 1 then
				table.remove(self.queueAssistList1, 1)
			elseif isInQueueList == 2 then
				table.remove(self.queueAssistList2, 1)
			elseif isInQueueList == 3 then
				table.remove(self.queueAssistList3, 1)
			elseif isInQueueList == 4 then
				table.remove(self.queueAssistList4, 1)
			end
			local messages = {}
			messages[1] = "Assist Enemy Team."
			messages[2] = "You have been switched because of your assist request."
			NetEvents:SendTo('PopupResponse', player, messages)
			print("ASSIST - MOVE - Player " .. player.name .. " is now helping the enemy team " .. player.teamId .. ".")
		elseif currentTeamCount > (enemyTeam3Count + 1) or (currentTeamTickets >= enemyTeam3Tickets and currentTeamCount > (enemyTeam3Count - 2)) then
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			player.teamId = enemyTeam3
			if isInQueueList == 1 then
				table.remove(self.queueAssistList1, 1)
			elseif isInQueueList == 2 then
				table.remove(self.queueAssistList2, 1)
			elseif isInQueueList == 3 then
				table.remove(self.queueAssistList3, 1)
			elseif isInQueueList == 4 then
				table.remove(self.queueAssistList4, 1)
			end
			local messages = {}
			messages[1] = "Assist Enemy Team."
			messages[2] = "You have been switched because of your assist request."
			NetEvents:SendTo('PopupResponse', player, messages)
			print("ASSIST - MOVE - Player " .. player.name .. " is now helping the enemy team " .. player.teamId .. ".")
		else
			if isInQueueList == 0 then
				self:QuickSwitch(player)
			end
		end
	end
end

function Assist:QuickSwitch(player)
	local playerTeamId = player.teamId
	local listPlayer = nil
	if player.teamId == TeamId.Team1 then
		::continue12::
		if self.queueAssistList2[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList2[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList2, 1)
				goto continue12
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team1
			player.teamId = TeamId.Team2
			table.remove(self.queueAssistList2, 1)
		end
		::continue13::
		if self.queueAssistList3[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList3[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList3, 1)
				goto continue13
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team1
			player.teamId = TeamId.Team3
			table.remove(self.queueAssistList3, 1)
		end
		::continue14::
		if self.queueAssistList4[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList4[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList4, 1)
				goto continue14
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team1
			player.teamId = TeamId.Team4
			table.remove(self.queueAssistList4, 1)
		end
	elseif player.teamId == TeamId.Team2 then
		::continue21::
		if self.queueAssistList1[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList1[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList1, 1)
				goto continue21
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team2
			player.teamId = TeamId.Team1
			table.remove(self.queueAssistList1, 1)
		end
		::continue23::
		if self.queueAssistList3[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList3[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList3, 1)
				goto continue23
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team2
			player.teamId = TeamId.Team3
			table.remove(self.queueAssistList3, 1)
		end
		::continue24::
		if self.queueAssistList4[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList4[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList4, 1)
				goto continue24
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team2
			player.teamId = TeamId.Team4
			table.remove(self.queueAssistList4, 1)
		end
	elseif player.teamId == TeamId.Team3 then
		::continue31::
		if self.queueAssistList1[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList1[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList1, 1)
				goto continue31
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team3
			player.teamId = TeamId.Team1
			table.remove(self.queueAssistList1, 1)
		end
		::continue32::
		if self.queueAssistList2[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList2[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList2, 1)
				goto continue32
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team3
			player.teamId = TeamId.Team2
			table.remove(self.queueAssistList2, 1)
		end
		::continue34::
		if self.queueAssistList4[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList4[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList4, 1)
				goto continue34
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team3
			player.teamId = TeamId.Team4
			table.remove(self.queueAssistList4, 1)
		end
	else
		::continue41::
		if self.queueAssistList1[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList1[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList1, 1)
				goto continue41
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team4
			player.teamId = TeamId.Team1
			table.remove(self.queueAssistList1, 1)
		end
		::continue42::
		if self.queueAssistList2[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList2[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList2, 1)
				goto continue42
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team4
			player.teamId = TeamId.Team2
			table.remove(self.queueAssistList2, 1)
		end
		::continue43::
		if self.queueAssistList3[1] ~= nil then
			listPlayer = PlayerManager:GetPlayerByName(self.queueAssistList3[1])
			if listPlayer == nil then
				table.remove(self.queueAssistList3, 1)
				goto continue43
			end
			if listPlayer.alive == true then
				RCON:SendCommand('admin.killPlayer', {listPlayer.name})
			end
			if player.alive == true then
				RCON:SendCommand('admin.killPlayer', {player.name})
			end
			listPlayer.teamId = TeamId.Team4
			player.teamId = TeamId.Team3
			table.remove(self.queueAssistList3, 1)
		end
	end
	if playerTeamId == player.teamId then
		self:OnQueueAssistEnemyTeam(player)
	else
		local messages = {}
		messages[1] = "Assist Enemy Team."
		messages[2] = "You have been switched because of your assist request."
		NetEvents:SendTo('PopupResponse', player, messages)
		print("ASSIST - MOVE - Player " .. player.name .. " is now helping the enemy team " .. player.teamId .. ".")
		messages = {}
		messages[1] = "Assist Enemy Team."
		messages[2] = "You have been switched because of your assist request."
		NetEvents:SendTo('PopupResponse', listPlayer, messages)	
		print("ASSIST - MOVE - Player " .. listPlayer.name .. " is now helping the enemy team " .. listPlayer.teamId .. ".")
	end
end

function Assist:OnCancelAssistEnemyTeam(player)
	if player.teamId == 1 then
		for i,listPlayerName in pairs(self.queueAssistList1) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList1, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList2) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList2, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList3) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList3, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList4) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList4, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		-- Error you are in no queue
	elseif player.teamId == 2 then
		for i,listPlayerName in pairs(self.queueAssistList2) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList2, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList1) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList1, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList3) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList3, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList4) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList4, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		-- Error you are in no queue
	elseif player.teamId == 3 then
		for i,listPlayerName in pairs(self.queueAssistList3) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList3, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList1) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList1, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList2) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList2, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList4) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList4, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		-- Error you are in no queue
	elseif player.teamId == 4 then
		for i,listPlayerName in pairs(self.queueAssistList4) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList4, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList1) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList1, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList2) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList2, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		for i,listPlayerName in pairs(self.queueAssistList3) do
			if player.name == listPlayerName then
				table.remove(self.queueAssistList3, i)
				local messages = {}
				messages[1] = "Assist Queue Cancelled."
				messages[2] = "We removed you from the assist queue."
				NetEvents:SendTo('PopupResponse', player, messages)
				print("ASSIST - CANCEL - Player " .. player.name .. " cancelled the assist and was removed from the assist queue.")
				return
			end
		end
		-- Error you are in no queue
		print("ASSIST - CANCEL Error - Player " .. player.name .. " was in no assist queue.")
	end
end

return Assist