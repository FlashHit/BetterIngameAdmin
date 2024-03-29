---@class LoadingScreen
LoadingScreen = class 'LoadingScreen'

function LoadingScreen:__init()
	self.m_ShowLoadingScreenInfo = true

	NetEvents:Subscribe('Info', self, self.OnInfo) -- Todo: Rename to ServerBannerInfo or LoadingScreenInfo
end

function LoadingScreen:OnExtensionLoaded()
	if self.m_ShowLoadingScreenInfo == false or self:GetIsHotReload() then
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

function LoadingScreen:GetIsHotReload()
	if SharedUtils:GetLevelName() == "Levels/Web_Loading/Web_Loading" then
		return false
	else
		return true
	end
end

return LoadingScreen()
