class 'LoadingScreen'

function LoadingScreen:__init()
	self.m_BannerUrl = "fb://UI/Static/ServerBanner/BFServerBanner"
	self.m_ServerName = nil
	self.m_ServerDescription = nil
	self:RegisterCommands()
end

function LoadingScreen:RegisterCommands()
	RCON:RegisterCommand("vars.bannerUrl", RemoteCommandFlag.None, function(p_Command, p_Args, p_LoggedIn)
		if p_Args ~= nil then
			if p_Args[1] == "" then
				self.m_BannerUrl = "fb://UI/Static/ServerBanner/BFServerBanner"
				NetEvents:Broadcast('Info', {self.m_ServerName, self.m_ServerDescription, self.m_BannerUrl})
				print("SET BANNER: Default")
				return {'OK', self.m_BannerUrl}
			elseif p_Args[1] ~= nil then
				self.m_BannerUrl = p_Args[1]
				NetEvents:Broadcast('Info', {self.m_ServerName, self.m_ServerDescription, self.m_BannerUrl})
				print("SET BANNER: " .. p_Args[1])
				return {'OK', p_Args[1]}
			else
				print("GET BANNER: " .. self.m_BannerUrl)
				return {'OK', self.m_BannerUrl}
			end
		else
			print("GET BANNER: " .. self.m_BannerUrl)
			return {'OK', self.m_BannerUrl}
		end
	end)
end

function LoadingScreen:OnLevelDestroy()
	local s_Args = RCON:SendCommand('vars.serverName')
	self.m_ServerName = s_Args[2]
	s_Args = RCON:SendCommand('vars.serverDescription')
	self.m_ServerDescription = s_Args[2]
	NetEvents:Broadcast('Info', {self.m_ServerName, self.m_ServerDescription, self.m_BannerUrl})
end

function LoadingScreen:OnAuthenticated(p_Player)
	NetEvents:SendTo('Info', p_Player, {self.m_ServerName, self.m_ServerDescription, self.m_BannerUrl})
end

function LoadingScreen:OnLevelLoaded(levelName, gameMode, round, roundsPerMap)
	local s_Args = RCON:SendCommand('vars.serverName')
	self.m_ServerName = s_Args[2]
	s_Args = RCON:SendCommand('vars.serverDescription')
	self.m_ServerDescription = s_Args[2]
end

if g_LoadingScreen == nil then
	g_LoadingScreen = LoadingScreen()
end

return g_LoadingScreen
