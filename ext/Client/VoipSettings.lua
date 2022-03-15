---@class VoipSettings
VoipSettings = class 'VoipSettings'

function VoipSettings:__init()
	Events:Subscribe("FromVoipMod:DefaultVoipVolume", self, self.OnDefaultVoipVolume)
	Events:Subscribe("FromVoipMod:PlayerVoipLevel", self, self.OnPlayerVoipLevel)
end

---@param p_Volume number
function VoipSettings:OnDefaultVoipVolume(p_Volume)
	WebUI:ExecuteJS(string.format("setDefaultVoipVolume(%s)", p_Volume))
end

---@param p_Level string
function VoipSettings:OnPlayerVoipLevel(p_Level)
	WebUI:ExecuteJS(string.format("setPlayerVoipLevel('%s')", p_Level))
end

return VoipSettings()
