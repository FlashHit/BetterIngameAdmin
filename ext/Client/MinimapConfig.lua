class 'MinimapConfig'

function MinimapConfig:__init()
	self.largeMap = false
	self.mapSizeTimer = false
    self.mapTimer = 0
    
	Events:Subscribe('WebUI:SmallMiniMapSize', self, self.OnWebUISmallMiniMapSize)
    Events:Subscribe('WebUI:LargeMiniMapSize', self, self.OnWebUILargeMiniMapSize)
    
    self.m_MiniMapResetCallback = ResourceManager:RegisterInstanceLoadHandler(Guid('E006FA38-6668-11E0-8215-820026059936'), Guid('7F2573C7-5712-C90F-7328-B82E3C732CE9'), self, self.OnMiniMapResetCallback)
end

function MinimapConfig:OnMiniMapResetCallback(p_Instance)
    p_Instance = LogicPrefabBlueprint(p_Instance)
    p_Instance:MakeWritable()
    for i = #p_Instance.eventConnections, 1, -1 do
        if EventSpec(p_Instance.eventConnections[i].targetEvent).id == 1529486671 then
            p_Instance.eventConnections:erase(i)
        end
    end
end

function MinimapConfig:OnWebUISmallMiniMapSize()
	self.largeMap = false
end
function MinimapConfig:OnWebUILargeMiniMapSize()
	self.largeMap = true
end

function MinimapConfig:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
    if self.mapSizeTimer == true then
		self.mapTimer = self.mapTimer + p_DeltaTime
		if self.mapTimer >= 0.1 then
			local clientUIGraphEntityIterator = EntityManager:GetIterator("ClientUIGraphEntity")
			
			local clientUIGraphEntity = clientUIGraphEntityIterator:Next()
			while clientUIGraphEntity do
				if clientUIGraphEntity.data.instanceGuid == Guid('02395EB3-5C41-4396-AC7E-A14FAA85757C') or clientUIGraphEntity.data.instanceGuid == Guid('339168C6-FDEC-4EB2-8DAF-D42BDDDDD0A9') or clientUIGraphEntity.data.instanceGuid == Guid('984185F4-1B3F-4E61-8B1C-54F1C53898DC') or clientUIGraphEntity.data.instanceGuid == Guid('6D64CD68-CD5D-463D-8184-FF7A2D031F64') then
					clientUIGraphEntity = Entity(clientUIGraphEntity)
					self.mapSizeTimer = false
					self.mapTimer = 0
					clientUIGraphEntity:FireEvent('MapSize')
					return
				end
				clientUIGraphEntity = clientUIGraphEntityIterator:Next()
			end
		end
    end
end

function MinimapConfig:OnLevelLoadingInfo(p_ScreenInfo)
    if p_ScreenInfo == "Initializing entities for autoloaded sublevels" then
		local clientUIGraphEntityIterator = EntityManager:GetIterator("ClientUIGraphEntity")
	
		local clientUIGraphEntity = clientUIGraphEntityIterator:Next()
		while clientUIGraphEntity do
			if clientUIGraphEntity.data.instanceGuid == Guid('02395EB3-5C41-4396-AC7E-A14FAA85757C') or clientUIGraphEntity.data.instanceGuid == Guid('339168C6-FDEC-4EB2-8DAF-D42BDDDDD0A9') or clientUIGraphEntity.data.instanceGuid == Guid('984185F4-1B3F-4E61-8B1C-54F1C53898DC') or clientUIGraphEntity.data.instanceGuid == Guid('6D64CD68-CD5D-463D-8184-FF7A2D031F64') then
				clientUIGraphEntity = Entity(clientUIGraphEntity)
				clientUIGraphEntity:RegisterEventCallback(self, self.OnMinimapInitializing)
				return
			end
			clientUIGraphEntity = clientUIGraphEntityIterator:Next()
		end
	end
end

function MinimapConfig:OnMinimapInitializing(ent, entityEvent)
	if self.largeMap == false then
		return
	end
	if entityEvent.eventId == -1711446775 then -- "Initialized"
		self.mapSizeTimer = true
	end
end

return MinimapConfig