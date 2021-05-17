class 'Assist'

function Assist:__init()
	self.m_EnableAssistFunction = true

	-- Region Assist
	Events:Subscribe('WebUI:AssistEnemyTeam', self, self.OnWebUIAssistEnemyTeam)
	Events:Subscribe('WebUI:CancelAssistEnemyTeam', self, self.OnWebUICancelAssistEnemyTeam)
		-- missing: WebUI:CancelAssist after getting in Queue (Queue is also missing at this point)
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

if g_Assist == nil then
	g_Assist = Assist()
end

return g_Assist
