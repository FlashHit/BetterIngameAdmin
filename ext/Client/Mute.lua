class 'Mute'

function Mute:__init()
	self.m_MutedPlayers = {}
	self.m_MutedChannels = {}

	Events:Subscribe('WebUI:MutePlayer', self, self.OnWebUIMutePlayer)
	Events:Subscribe('WebUI:UnmutePlayer', self, self.OnWebUIUnmutePlayer)
	Events:Subscribe('WebUI:ChatChannels', self, self.OnWebUIChatChannels)
	Hooks:Install('ClientChatManager:IncomingMessage', 1, self, self.OnCreateChatMessage)

end

function Mute:OnWebUIMutePlayer(p_PlayerName)
	local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)
	local s_PlayerAlreadyMuted = false
	for _, l_MutedPlayer in pairs(self.m_MutedPlayers) do
		if l_MutedPlayer == s_Player.id then
			s_PlayerAlreadyMuted = true
			return
		end
	end
	if s_PlayerAlreadyMuted == false then
		table.insert(self.m_MutedPlayers, s_Player.id)
		WebUI:ExecuteJS(string.format("successPlayerMuted()"))
	else
		WebUI:ExecuteJS(string.format("errorPlayerAlreadyMuted()"))
	end
end

function Mute:OnWebUIUnmutePlayer(p_PlayerName)
	local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)
	local s_PlayerAlreadyMuted = false
	for i, l_MutedPlayer in pairs(self.m_MutedPlayers) do
		if l_MutedPlayer == s_Player.id then
			s_PlayerAlreadyMuted = true
			table.remove(self.m_MutedPlayers, i)
			return
		end
	end
	if s_PlayerAlreadyMuted == true then
		WebUI:ExecuteJS(string.format("successPlayerUnmuted()"))
	else
		WebUI:ExecuteJS(string.format("errorPlayerWasNotMuted()"))
	end
end

function Mute:OnWebUIChatChannels(p_ChatChannels)
	self.m_MutedChannels = {}
	if p_ChatChannels ~= nil then
		p_ChatChannels = json.decode(p_ChatChannels)
		for i, l_Channel in pairs(p_ChatChannels) do
			table.insert(self.m_MutedChannels, tonumber(l_Channel))
		end
	end
end

function Mute:OnCreateChatMessage(p_HookCtx, p_Message, p_PlayerId, p_RecipientMask, p_ChannelId, p_IsSenderDead)
	for _, l_MutedPlayer in pairs(self.m_MutedPlayers) do
		if l_MutedPlayer == p_PlayerId then
			p_HookCtx:Return()
		end
	end
	for _, l_MutedChannel in pairs(self.m_MutedChannels) do
		if l_MutedChannel == p_ChannelId then
			p_HookCtx:Return()
		end
	end
end

if g_Mute == nil then
	g_Mute = Mute()
end

return g_Mute
