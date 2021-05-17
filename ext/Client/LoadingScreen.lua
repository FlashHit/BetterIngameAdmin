class 'LoadingScreen'

function LoadingScreen:__init()
	self.m_ShowLoadingScreenInfo = true

	NetEvents:Subscribe('Info', self, self.OnInfo) -- Todo: Rename to ServerBannerInfo or LoadingScreenInfo
end

function LoadingScreen:OnExtensionLoaded()
	if self.m_ShowLoadingScreenInfo == false then
		WebUI:ExecuteJS("hideLoadingScreen()")
	end
end

function LoadingScreen:OnLevelLoadingInfo(p_ScreenInfo)
	if p_ScreenInfo == "Initializing entities for autoloaded sublevels" then
		WebUI:ExecuteJS("hideLoadingScreen()")
	end
end

function LoadingScreen:OnInfo(p_Args)
	WebUI:ExecuteJS(string.format("info(%s)", json.encode(p_Args)))
	if self.m_ShowLoadingScreenInfo == false then
		WebUI:ExecuteJS("hideLoadingScreen()")
	end
end

function LoadingScreen:OnLevelDestroy()
	if self.m_ShowLoadingScreenInfo == true then
		WebUI:ExecuteJS("showLoadingScreen()")
	end
end

function LoadingScreen:SetLoadingScreenInfo(p_ShowLoadingScreenInfo)
	self.m_ShowLoadingScreenInfo = p_ShowLoadingScreenInfo
end

if g_LoadingScreen == nil then
	g_LoadingScreen = LoadingScreen()
end

return g_LoadingScreen
