class 'Ping'

function Ping:__init()
	self.m_ShowPing = false

	Events:Subscribe('WebUI:ShowPing', self, self.OnWebUIShowPing)
	Events:Subscribe('WebUI:HidePing', self, self.OnWebUIHidePing)
end

function Ping:OnWebUIShowPing()
	self.m_ShowPing = true
end

function Ping:OnWebUIHidePing()
	self.m_ShowPing = false
end

function Ping:UpdateLocalPlayerPing(p_PingTable)
	if self.m_ShowPing == true then
		local s_LocalPlayer = PlayerManager:GetLocalPlayer()
		if s_LocalPlayer ~= nil and p_PingTable[s_LocalPlayer.name] ~= nil and p_PingTable[s_LocalPlayer.name] < 999 then
			WebUI:ExecuteJS(string.format("updateLocalPlayerPing(%s)", json.encode(p_PingTable[s_LocalPlayer.name])))
		end
	end
end

if g_Ping == nil then
	g_Ping = Ping()
end

return g_Ping
