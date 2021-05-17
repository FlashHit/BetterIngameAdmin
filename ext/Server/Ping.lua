class 'Ping'

function Ping:__init()
	self.m_CumulatedTimeForPing = 0
end

function Ping:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	self.m_CumulatedTimeForPing = self.m_CumulatedTimeForPing + p_DeltaTime
	if self.m_CumulatedTimeForPing >= 5 then
		local s_PingTable = {}
		for i, l_Player in pairs(PlayerManager:GetPlayers()) do
			s_PingTable[l_Player.name] = l_Player.ping
			table.insert(s_PingTable, pingplayer)
		end
		self.m_CumulatedTimeForPing = 0
		NetEvents:Broadcast('Player:Ping', s_PingTable)
	end
end

if g_Ping == nil then
	g_Ping = Ping()
end

return g_Ping
