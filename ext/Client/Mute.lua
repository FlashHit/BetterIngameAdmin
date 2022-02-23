---@class Mute
Mute = class 'Mute'

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

	if s_Player == nil then
		local s_Message = {}
		s_Message[1] = "Didn\'t find player: " .. p_PlayerName
		s_Message[2] = "Please try again."
		WebUI:ExecuteJS(string.format("showPopupResponse(%s)", json.encode(s_Message)))
		return
	end

	local s_PlayerAlreadyMuted = false

	for _, l_MutedPlayer in pairs(self.m_MutedPlayers) do
		if l_MutedPlayer == s_Player.id then
			s_PlayerAlreadyMuted = true
			break
		end
	end

	if s_PlayerAlreadyMuted == false then
		table.insert(self.m_MutedPlayers, s_Player.id)
		local s_Message = {}
		s_Message[1] = "You muted " .. p_PlayerName .. " successfully!"
		s_Message[2] = "Now you won't see any messages from " .. p_PlayerName .. " anymore."
		WebUI:ExecuteJS(string.format("showPopupResponse(%s)", json.encode(s_Message)))
	else
		local s_Message = {}
		s_Message[1] = "You muted " .. p_PlayerName .. " already!"
		s_Message[2] = "You can't mute " .. p_PlayerName .. " twice."
		WebUI:ExecuteJS(string.format("showPopupResponse(%s)", json.encode(s_Message)))
	end
end

function Mute:OnWebUIUnmutePlayer(p_PlayerName)
	local s_Player = PlayerManager:GetPlayerByName(p_PlayerName)
	local s_PlayerAlreadyMuted = false

	for i, l_MutedPlayer in pairs(self.m_MutedPlayers) do
		if l_MutedPlayer == s_Player.id then
			s_PlayerAlreadyMuted = true
			table.remove(self.m_MutedPlayers, i)
			break
		end
	end

	if s_PlayerAlreadyMuted == true then
		local s_Message = {}
		s_Message[1] = "You unmuted " .. p_PlayerName .. "successfully!"
		s_Message[2] = "Now you will see all messages from " .. p_PlayerName .. " again."
		WebUI:ExecuteJS(string.format("showPopupResponse(%s)", json.encode(s_Message)))
	else
		local s_Message = {}
		s_Message[1] = "The player " .. p_PlayerName .. " was not muted!"
		s_Message[2] = "You can't unmute " .. p_PlayerName .. " as he was not muted."
		WebUI:ExecuteJS(string.format("showPopupResponse(%s)", json.encode(s_Message)))
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

return Mute()
