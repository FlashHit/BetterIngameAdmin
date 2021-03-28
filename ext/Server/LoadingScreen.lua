class 'LoadingScreen'

function LoadingScreen:__init()
	self.bannerUrl = "fb://UI/Static/ServerBanner/BFServerBanner"
	self.serverName = nil
    self.serverDescription = nil
    self:RegisterCommands()
end

function LoadingScreen:RegisterCommands()
	RCON:RegisterCommand("vars.bannerUrl", RemoteCommandFlag.None, function(command, args, loggedIn)
		if args ~= nil then
			if args[1] == "" then
				self.bannerUrl = "fb://UI/Static/ServerBanner/BFServerBanner"
				NetEvents:Broadcast('Info', {self.serverName, self.serverDescription, self.bannerUrl})
				print("SET BANNER: Default")
				return {'OK', self.bannerUrl}
			elseif args[1] ~= nil then
				self.bannerUrl = args[1]
				NetEvents:Broadcast('Info', {self.serverName, self.serverDescription, self.bannerUrl})
				print("SET BANNER: " .. args[1])
				return {'OK', args[1]}
			else
				print("GET BANNER: " .. self.bannerUrl)
				return {'OK', self.bannerUrl}
			end
		else
			print("GET BANNER: " .. self.bannerUrl)
			return {'OK', self.bannerUrl}
		end
	end)
end

function LoadingScreen:OnLevelDestroy()
	local args = RCON:SendCommand('vars.serverName')
	self.serverName = args[2]
	args = RCON:SendCommand('vars.serverDescription')
	self.serverDescription = args[2]
	NetEvents:Broadcast('Info', {self.serverName, self.serverDescription, self.bannerUrl})
end

function LoadingScreen:OnAuthenticated(p_Player)
	NetEvents:SendTo('Info', p_Player, {self.serverName, self.serverDescription, self.bannerUrl})
end

function LoadingScreen:OnLevelLoaded(levelName, gameMode, round, roundsPerMap)
	local args = RCON:SendCommand('vars.serverName')
	self.serverName = args[2]
	args = RCON:SendCommand('vars.serverDescription')
    self.serverDescription = args[2]
end

return LoadingScreen