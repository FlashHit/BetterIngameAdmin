---@class Assist
Assist = class 'Assist'

function Assist:__init()
	self.m_EnableAssistFunction = true

	-- Region Assist
	Events:Subscribe('WebUI:AssistEnemyTeam', self, self.OnWebUIAssistEnemyTeam)
	Events:Subscribe('WebUI:CancelAssistEnemyTeam', self, self.OnWebUICancelAssistEnemyTeam)
	-- Endregion
end

function Assist:OnWebUIAssistEnemyTeam()
	NetEvents:Send('AssistEnemyTeam')
end

function Assist:OnWebUICancelAssistEnemyTeam()
	NetEvents:Send('CancelAssistEnemyTeam')
end

function Assist:SetEnableAssistFunction(p_EnableAssistFunction)
	self.m_EnableAssistFunction = p_EnableAssistFunction
end

return Assist()
