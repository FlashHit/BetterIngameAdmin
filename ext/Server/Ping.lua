class 'Ping'

function Ping:__init()
	self.cumulatedTimeForPing = 0
end

function Ping:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	self.cumulatedTimeForPing = self.cumulatedTimeForPing + p_DeltaTime
	if self.cumulatedTimeForPing >= 5 then
		local pingTable = {}
		for i,player in pairs(PlayerManager:GetPlayers()) do
			pingTable[player.name] = player.ping
			table.insert(pingTable, pingplayer)
		end
		self.cumulatedTimeForPing = 0
		NetEvents:Broadcast('Player:Ping', pingTable)
	end
end

return Ping