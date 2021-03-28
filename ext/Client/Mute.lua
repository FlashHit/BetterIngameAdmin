class 'Mute'

function Mute:__init()
    self.mutedPlayers = {}
    self.mutedChannels = {}

	Events:Subscribe('WebUI:MutePlayer', self, self.OnWebUIMutePlayer)
	Events:Subscribe('WebUI:UnmutePlayer', self, self.OnWebUIUnmutePlayer)
	Events:Subscribe('WebUI:ChatChannels', self, self.OnWebUIChatChannels)
	Hooks:Install('ClientChatManager:IncomingMessage', 1, self, self.OnCreateChatMessage)

end

function Mute:OnWebUIMutePlayer(playerName)
	local player = PlayerManager:GetPlayerByName(playerName)
	local playerAlreadyMuted = false
	for _,mutedPlayer in pairs(self.mutedPlayers) do
		if mutedPlayer == player.id then	
			playerAlreadyMuted = true
			return
		end
	end
	if playerAlreadyMuted == false then
		table.insert(self.mutedPlayers, player.id)
		WebUI:ExecuteJS(string.format("successPlayerMuted()"))
	else
		WebUI:ExecuteJS(string.format("errorPlayerAlreadyMuted()"))
	end
end

function Mute:OnWebUIUnmutePlayer(playerName)
	local player = PlayerManager:GetPlayerByName(playerName)
	local playerAlreadyMuted = false
	for i,mutedPlayer in pairs(self.mutedPlayers) do
		if mutedPlayer == player.id then	
			playerAlreadyMuted = true
			table.remove(self.mutedPlayers, i)
			return
		end
	end
	if playerAlreadyMuted == true then
		WebUI:ExecuteJS(string.format("successPlayerUnmuted()"))
	else
		WebUI:ExecuteJS(string.format("errorPlayerWasNotMuted()"))
	end
end

function Mute:OnWebUIChatChannels(chatChannels)
	self.mutedChannels = {}
	if chatChannels ~= nil then
		chatChannels = json.decode(chatChannels)
		for i,channel in pairs(chatChannels) do
			table.insert(self.mutedChannels, tonumber(channel))
		end
	end
end

function Mute:OnCreateChatMessage(hook, message, playerId, recipientMask, channelId, isSenderDead)
	for _,mutedPlayer in pairs(self.mutedPlayers) do
		if mutedPlayer == playerId then
			hook:Return()
		end
	end
	for _,mutedChannel in pairs(self.mutedChannels) do
		if mutedChannel == channelId then
			hook:Return()
		end
	end
end

return Mute