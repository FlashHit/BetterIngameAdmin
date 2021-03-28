class 'Ping'

function Ping:__init()
    self.showPing = false
    
	Events:Subscribe('WebUI:ShowPing', self, self.OnWebUIShowPing)
	Events:Subscribe('WebUI:HidePing', self, self.OnWebUIHidePing)
end

function Ping:OnWebUIShowPing()
	self.showPing = true
end

function Ping:OnWebUIHidePing()
	self.showPing = false
end

function Ping:UpdateLocalPlayerPing(p_PingTable)
    if self.showPing == true then
        local localPlayer = PlayerManager:GetLocalPlayer()
        if localPlayer ~= nil and p_PingTable[localPlayer.name] ~= nil and p_PingTable[localPlayer.name] < 999 then
            WebUI:ExecuteJS(string.format("updateLocalPlayerPing(%s)", json.encode(p_PingTable[localPlayer.name])))
        end
    end
end

return Ping