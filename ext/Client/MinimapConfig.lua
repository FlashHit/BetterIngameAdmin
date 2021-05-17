class 'MinimapConfig'

function MinimapConfig:__init()
	self.m_LargeMap = false
	self.m_MapSizeTimer = false
	self.m_MapTimer = 0

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
	self.m_LargeMap = false
end
function MinimapConfig:OnWebUILargeMiniMapSize()
	self.m_LargeMap = true
end

function MinimapConfig:OnEngineUpdate(p_DeltaTime, p_SimulationDeltaTime)
	if self.m_MapSizeTimer == true then
		self.m_MapTimer = self.m_MapTimer + p_DeltaTime
		if self.m_MapTimer >= 0.1 then
			local s_ClientUIGraphEntityIterator = EntityManager:GetIterator("ClientUIGraphEntity")

			local s_ClientUIGraphEntity = s_ClientUIGraphEntityIterator:Next()
			while s_ClientUIGraphEntity do
				if s_ClientUIGraphEntity.data.instanceGuid == Guid('02395EB3-5C41-4396-AC7E-A14FAA85757C') or s_ClientUIGraphEntity.data.instanceGuid == Guid('339168C6-FDEC-4EB2-8DAF-D42BDDDDD0A9') or s_ClientUIGraphEntity.data.instanceGuid == Guid('984185F4-1B3F-4E61-8B1C-54F1C53898DC') or s_ClientUIGraphEntity.data.instanceGuid == Guid('6D64CD68-CD5D-463D-8184-FF7A2D031F64') then
					s_ClientUIGraphEntity = Entity(s_ClientUIGraphEntity)
					self.m_MapSizeTimer = false
					self.m_MapTimer = 0
					s_ClientUIGraphEntity:FireEvent('MapSize')
					return
				end
				s_ClientUIGraphEntity = s_ClientUIGraphEntityIterator:Next()
			end
		end
	end
end

function MinimapConfig:OnLevelLoadingInfo(p_ScreenInfo)
	if p_ScreenInfo == "Initializing entities for autoloaded sublevels" then
		local s_ClientUIGraphEntityIterator = EntityManager:GetIterator("ClientUIGraphEntity")

		local s_ClientUIGraphEntity = s_ClientUIGraphEntityIterator:Next()
		while s_ClientUIGraphEntity do
			if s_ClientUIGraphEntity.data.instanceGuid == Guid('02395EB3-5C41-4396-AC7E-A14FAA85757C') or s_ClientUIGraphEntity.data.instanceGuid == Guid('339168C6-FDEC-4EB2-8DAF-D42BDDDDD0A9') or s_ClientUIGraphEntity.data.instanceGuid == Guid('984185F4-1B3F-4E61-8B1C-54F1C53898DC') or s_ClientUIGraphEntity.data.instanceGuid == Guid('6D64CD68-CD5D-463D-8184-FF7A2D031F64') then
				s_ClientUIGraphEntity = Entity(s_ClientUIGraphEntity)
				s_ClientUIGraphEntity:RegisterEventCallback(self, self.OnMinimapInitializing)
				return
			end
			s_ClientUIGraphEntity = s_ClientUIGraphEntityIterator:Next()
		end
	end
end

function MinimapConfig:OnMinimapInitializing(p_Entity, p_EntityEvent)
	if self.m_LargeMap == false then
		return
	end
	if p_EntityEvent.eventId == MathUtils:FNVHash("Initialized") then
		self.m_MapSizeTimer = true
	end
end

if g_MinimapConfig == nil then
	g_MinimapConfig = MinimapConfig()
end

return g_MinimapConfig
