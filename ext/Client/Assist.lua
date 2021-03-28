class 'Assist'

function Assist:__init()
    self.enableAssistFunction = true
	
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
    self.enableAssistFunction = p_EnableAssistFunction
end

return Assist