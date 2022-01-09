---@class Ping
Ping = class 'Ping'

function Ping:OnExtensionLoaded()
	self.m_ShowPing = false

	-- check if this vext version supports the SettingsManager
	if SettingsManager then
		local s_ModSetting = SettingsManager:GetSetting("ShowClientPing")

		-- declare the ModSetting if it is unknown
		if not s_ModSetting then
			local s_SettingOptions = SettingOptions()
			s_SettingOptions.displayName = "ShowClientPing"
			s_SettingOptions.showInUi = false
			s_ModSetting = SettingsManager:DeclareBool("ShowClientPing", false, s_SettingOptions)
			s_ModSetting.value = false
		end

		self.m_ShowPing = s_ModSetting.value

		if self.m_ShowPing then
			WebUI:ExecuteJS("showLocalPlayerPing()")
		end
	end

	Events:Subscribe('WebUI:ShowPing', self, self.OnWebUIShowPing)
	Events:Subscribe('WebUI:HidePing', self, self.OnWebUIHidePing)
end

function Ping:OnWebUIShowPing()
	WebUI:ExecuteJS("showLocalPlayerPing()")
	self.m_ShowPing = true

	if SettingsManager then
		local s_ModSetting = SettingsManager:GetSetting("ShowClientPing")
		s_ModSetting.value = true
	end
end

function Ping:OnWebUIHidePing()
	WebUI:ExecuteJS("hideLocalPlayerPing()")
	self.m_ShowPing = false

	if SettingsManager then
		local s_ModSetting = SettingsManager:GetSetting("ShowClientPing")
		s_ModSetting.value = false
	end
end

function Ping:UpdateLocalPlayerPing(p_PingTable)
	if self.m_ShowPing == true then
		local s_LocalPlayer = PlayerManager:GetLocalPlayer()

		if s_LocalPlayer ~= nil and p_PingTable[s_LocalPlayer.name] ~= nil and p_PingTable[s_LocalPlayer.name] < 999 then
			WebUI:ExecuteJS(string.format("updateLocalPlayerPing(%s)", json.encode(p_PingTable[s_LocalPlayer.name])))
		end
	end
end

return Ping()
