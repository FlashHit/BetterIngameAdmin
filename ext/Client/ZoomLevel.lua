class 'ZoomLevel'

function ZoomLevel:__init()
    -- Client Settings
    self.defaultBase = nil -- this one is broken
    self.x10_0xZoom = nil
    self.x10xENVG = nil
    self.x12_0xZoom = nil
    self.x1xENVG = nil
    self.x20xENVG_COOP = nil
    self.x20xZoom = nil
    self.x2_0xZoom = nil
    self.x3_4xZoom = nil
    self.x4_0xZoom = nil
    self.x6_0xZoom = nil
    self.x6xENVG = nil
    self.x7_0xZoom = nil
    self.x8_0xZoom = nil
    self.defaultATSights = nil
    self.fast_2_0xZoom = nil
    self.fastIronSights = nil
    self.defaultIronSights = nil
    
    self.x10_0xZoomFieldOfView = nil
    self.x10_0xZoomLookSpeedMultiplier = nil
    self.x10xENVGFieldOfView = nil
    self.x10xENVGLookSpeedMultiplier = nil
    self.x12_0xZoomFieldOfView = nil
    self.x12_0xZoomLookSpeedMultiplier = nil
    self.x1xENVGFieldOfView = nil
    self.x1xENVGLookSpeedMultiplier = nil
    self.x20xENVG_COOPFieldOfView = nil
    self.x20xENVG_COOPLookSpeedMultiplier = nil
    self.x20xZoomFieldOfView = nil
    self.x20xZoomLookSpeedMultiplier = nil
    self.x2_0xZoomFieldOfView = nil
    self.x2_0xZoomLookSpeedMultiplier = nil
    self.x3_4xZoomFieldOfView = nil
    self.x3_4xZoomLookSpeedMultiplier = nil
    self.x4_0xZoomFieldOfView = nil
    self.x4_0xZoomLookSpeedMultiplier = nil
    self.x6_0xZoomFieldOfView = nil
    self.x6_0xZoomLookSpeedMultiplier = nil
    self.x6xENVGFieldOfView = nil
    self.x6xENVGLookSpeedMultiplier = nil
    self.x7_0xZoomFieldOfView = nil
    self.x7_0xZoomLookSpeedMultiplier = nil
    self.x8_0xZoomFieldOfView = nil
    self.x8_0xZoomLookSpeedMultiplier = nil
    self.defaultATSightsFieldOfView = nil
    self.defaultATSightsLookSpeedMultiplier = nil
    self.fast_2_0xZoomFieldOfView = nil
    self.fast_2_0xZoomLookSpeedMultiplier = nil
    self.fastIronSightsFieldOfView = nil
    self.fastIronSightsLookSpeedMultiplier = nil
    self.defaultIronSightsFieldOfView = nil
    self.defaultIronSightsLookSpeedMultiplier = nil

	Events:Subscribe('WebUI:GetMouseSensitivity', self, self.OnWebUIGetMouseSensitivity)
	Events:Subscribe('WebUI:SetMouseSensitivity', self, self.OnWebUISetMouseSensitivity)
	Events:Subscribe('WebUI:GetMouseSensitivityMultipliers', self, self.OnWebUIGetMouseSensitivityMultipliers)
	Events:Subscribe('WebUI:SetMouseSensitivityMultipliers', self, self.OnWebUISetMouseSensitivityMultipliers)
	Events:Subscribe('WebUI:ResetMouseSensitivityMultipliers', self, self.OnWebUIResetMouseSensitivityMultipliers)
	Events:Subscribe('WebUI:GetFieldOfView', self, self.OnWebUIGetFieldOfView)
	Events:Subscribe('WebUI:SetFieldOfView', self, self.OnWebUISetFieldOfView)
    Events:Subscribe('WebUI:ResetFieldOfView', self, self.OnWebUIResetFieldOfView)
    
	self:RegisterResourceManagerCallbacks()
end

-- Region MouseSensitivity and Field Of View
function ZoomLevel:OnWebUIGetMouseSensitivity()
	if self.toggleScoreboard == false then
		self.ignoreReleaseTab = true
	end
	local mouseSensitivity = InputManager:GetMouseSensitivity()
	WebUI:ExecuteJS(string.format("getMouseSensitivity(%s)", json.encode(mouseSensitivity)))
end

function ZoomLevel:OnWebUISetMouseSensitivity(mouseSensitivity)
	InputManager:SetMouseSensitivity(tonumber(mouseSensitivity))
end

function ZoomLevel:OnWebUIGetMouseSensitivityMultipliers()
	if self.toggleScoreboard == false then
		self.ignoreReleaseTab = true
	end
	local args = {	self.defaultIronSights.lookSpeedMultiplier,
					self.x2_0xZoom.lookSpeedMultiplier,
					self.x3_4xZoom.lookSpeedMultiplier,
					self.x4_0xZoom.lookSpeedMultiplier,
					self.x6_0xZoom.lookSpeedMultiplier,
					self.x7_0xZoom.lookSpeedMultiplier,
					self.x8_0xZoom.lookSpeedMultiplier,
					self.x10_0xZoom.lookSpeedMultiplier,
					self.x12_0xZoom.lookSpeedMultiplier,
					self.x20xZoom.lookSpeedMultiplier
				 }
	WebUI:ExecuteJS(string.format("getMouseSensitivityMultipliers(%s)", json.encode(args)))
end

function ZoomLevel:OnWebUISetMouseSensitivityMultipliers(args)
	args = json.decode(args)
	self.defaultIronSights.lookSpeedMultiplier = tonumber(args[1]) -- kobra rds and none and igla
	self.fastIronSights.lookSpeedMultiplier = tonumber(args[1]) -- pistols and small weapons like F2000, pdws and shotguns
	self.fast_2_0xZoom.lookSpeedMultiplier = tonumber(args[2]) -- holo of smaller weapons like F2000, pdws and shotguns
	self.defaultATSights.lookSpeedMultiplier = tonumber(args[1]) -- stinger and javelin only
	self.x1xENVG.lookSpeedMultiplier = tonumber(args[1]) -- IRNV scope
	self.x2_0xZoom.lookSpeedMultiplier = tonumber(args[2]) -- holo, pkas
	self.x3_4xZoom.lookSpeedMultiplier = tonumber(args[3]) -- pka, m145 3.4
	self.x4_0xZoom.lookSpeedMultiplier = tonumber(args[4]) -- acog, pso 4.0
	self.x6_0xZoom.lookSpeedMultiplier = tonumber(args[5]) -- Rifle Scope 6.0
	self.x6xENVG.lookSpeedMultiplier = tonumber(args[5]) -- SVD SinglePlayer -- better just remove
	self.x7_0xZoom.lookSpeedMultiplier = tonumber(args[6]) -- PKS-07
	self.x8_0xZoom.lookSpeedMultiplier = tonumber(args[7]) -- Rifle Scope 8.0
	self.x10_0xZoom.lookSpeedMultiplier = tonumber(args[8]) -- Ballistic Scope 12.0 -- small weapons like F2000 --wtf its actually 10x haha
	self.x10xENVG.lookSpeedMultiplier = tonumber(args[8]) -- SP M40 and M82
	self.x12_0xZoom.lookSpeedMultiplier = tonumber(args[9]) -- Ballistic Scope 12.0
	self.x20xZoom.lookSpeedMultiplier = tonumber(args[10]) -- Ballistic Scope 20.0 only L96
	self.x20xENVG_COOP.lookSpeedMultiplier = tonumber(args[10]) -- mk11 coop
end

function ZoomLevel:OnWebUIResetMouseSensitivityMultipliers()
	self.defaultIronSights.lookSpeedMultiplier = 0.5 -- 1
	self.fastIronSights.lookSpeedMultiplier = 0.5 -- 1
	self.fast_2_0xZoom.lookSpeedMultiplier = 0.3199999 -- 3
	self.defaultATSights.lookSpeedMultiplier = 0.5 -- 1
	self.x1xENVG.lookSpeedMultiplier = 0.5 -- 1
	self.x2_0xZoom.lookSpeedMultiplier = 0.3199999 -- 3
	self.x3_4xZoom.lookSpeedMultiplier = 0.36 -- 2
	self.x4_0xZoom.lookSpeedMultiplier = 0.31 -- 4
	self.x6_0xZoom.lookSpeedMultiplier = 0.2099999 -- 5
	self.x6xENVG.lookSpeedMultiplier = 0.2099999 -- 5
	self.x7_0xZoom.lookSpeedMultiplier = 0.2099999 -- 5
	self.x8_0xZoom.lookSpeedMultiplier = 0.1599999 -- 6
	self.x10_0xZoom.lookSpeedMultiplier = 0.1299999 -- 7
	self.x10xENVG.lookSpeedMultiplier = 0.1299999 -- 7
	self.x12_0xZoom.lookSpeedMultiplier = 0.1099999 -- 8
	self.x20xZoom.lookSpeedMultiplier = 0.0799999 -- 9
	self.x20xENVG_COOP.lookSpeedMultiplier = 0.0799999 -- 9

	self:OnWebUIGetMouseSensitivityMultipliers()
end

function ZoomLevel:OnWebUIGetFieldOfView()
	if self.toggleScoreboard == false then
		self.ignoreReleaseTab = true
	end
	local args = {	VDEGtoHDEG(self.defaultBase.fieldOfView),
					VDEGtoHDEG(self.defaultIronSights.fieldOfView),
					VDEGtoHDEG(self.x2_0xZoom.fieldOfView),
					VDEGtoHDEG(self.x3_4xZoom.fieldOfView),
					VDEGtoHDEG(self.x4_0xZoom.fieldOfView),
					VDEGtoHDEG(self.x6_0xZoom.fieldOfView),
					VDEGtoHDEG(self.x7_0xZoom.fieldOfView),
					VDEGtoHDEG(self.x8_0xZoom.fieldOfView),
					VDEGtoHDEG(self.x10_0xZoom.fieldOfView),
					VDEGtoHDEG(self.x12_0xZoom.fieldOfView),
					VDEGtoHDEG(self.x20xZoom.fieldOfView)
				 }
	WebUI:ExecuteJS(string.format("getFieldOfView(%s)", json.encode(args)))
end

function ZoomLevel:OnWebUISetFieldOfView(args)
	args = json.decode(args)
	self.defaultBase.fieldOfView = HDEGtoVDEG(tonumber(args[1]))
	self.defaultIronSights.fieldOfView = HDEGtoVDEG(tonumber(args[2])) -- kobra rds and none and igla
	self.fastIronSights.fieldOfView = HDEGtoVDEG(tonumber(args[2])) -- pistols and small weapons like F2000, pdws and shotguns
	self.fast_2_0xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[3])) -- holo of smaller weapons like F2000, pdws and shotguns
	self.defaultATSights.fieldOfView = HDEGtoVDEG(tonumber(args[2])) -- stinger and javelin only
	self.x1xENVG.fieldOfView = HDEGtoVDEG(tonumber(args[2])) -- IRNV scope
	self.x2_0xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[3])) -- holo, pkas
	self.x3_4xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[4])) -- pka, m145 3.4
	self.x4_0xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[5])) -- acog, pso 4.0
	self.x6_0xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[6])) -- Rifle Scope 6.0
	self.x6xENVG.fieldOfView = HDEGtoVDEG(tonumber(args[6])) -- SVD SinglePlayer -- better just remove
	self.x7_0xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[7])) -- PKS-07
	self.x8_0xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[8])) -- Rifle Scope 8.0
	self.x10_0xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[9])) -- Ballistic Scope 12.0 -- small weapons like F2000 --wtf its actually 10x haha
	self.x10xENVG.fieldOfView = HDEGtoVDEG(tonumber(args[9])) -- SP M40 and M82
	self.x12_0xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[10])) -- Ballistic Scope 12.0
	self.x20xZoom.fieldOfView = HDEGtoVDEG(tonumber(args[11])) -- Ballistic Scope 20.0 only L96
	self.x20xENVG_COOP.fieldOfView = HDEGtoVDEG(tonumber(args[11])) -- mk11 coop
end

function ZoomLevel:OnWebUIResetFieldOfView()
	self.defaultBase.fieldOfView = 55 -- 1
	self.defaultIronSights.fieldOfView = 40 -- 1
	self.fastIronSights.fieldOfView = 40 -- 1
	self.fast_2_0xZoom.fieldOfView = 32 -- 3
	self.defaultATSights.fieldOfView = 40 -- 1
	self.x1xENVG.fieldOfView = 40 -- 1
	self.x2_0xZoom.fieldOfView = 32 -- 3
	self.x3_4xZoom.fieldOfView = 20 -- 2
	self.x4_0xZoom.fieldOfView = 17.2 -- 4
	self.x6_0xZoom.fieldOfView = 11.6 -- 5
	self.x6xENVG.fieldOfView = 11.6 -- 5
	self.x7_0xZoom.fieldOfView = 9.899999 -- 5
	self.x8_0xZoom.fieldOfView = 8.699999 -- 6
	self.x10_0xZoom.fieldOfView = 7 -- 7
	self.x10xENVG.fieldOfView = 7 -- 7
	self.x12_0xZoom.fieldOfView = 5.8 -- 8
	self.x20xZoom.fieldOfView = 3.5 -- 9
	self.x20xENVG_COOP.fieldOfView = 3.5 -- 9

	self:OnWebUIGetFieldOfView()
end

function VDEGtoHDEG(arg)
	local fourthree = 4 / 3
	local vfovRad = tonumber(arg) *math.pi /180
	local hfovRad = math.atan(math.tan(vfovRad/2)*fourthree)*2
	local endFov = hfovRad / math.pi *180
	return endFov
end

function HDEGtoVDEG(arg)
	local fourthree = 4 / 3
	local vfovRad = tonumber(arg) *math.pi /180
	local hfovRad = math.atan(math.tan(vfovRad/2)/fourthree)*2
	local endFov = hfovRad / math.pi *180
	return endFov
end

function ZoomLevel:RegisterResourceManagerCallbacks()
    ResourceManager:RegisterInstanceLoadHandler(Guid("895050F3-B0D1-4F83-A57B-CCFA3EB0B31D", "D"), Guid("5C006FDF-FA1D-4E29-8E21-2ECAB83AC01C", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.defaultIronSights = instance
        if self.defaultIronSightsFieldOfView ~= nil then
            self.defaultIronSights.fieldOfView = self.defaultIronSightsFieldOfView
        end
        if self.defaultIronSightsLookSpeedMultiplier ~= nil then
            self.defaultIronSights.lookSpeedMultiplier = self.defaultIronSightsLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("FFEAFC24-9812-44BF-AD98-EBC06193739C", "D"), Guid("50887762-21DF-42F5-9740-ECDBCEECC3B4", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.fastIronSights = instance
        if self.fastIronSightsFieldOfView ~= nil then
            self.fastIronSights.fieldOfView = self.fastIronSightsFieldOfView
        end
        if self.fastIronSightsLookSpeedMultiplier ~= nil then
            self.fastIronSights.lookSpeedMultiplier = self.fastIronSightsLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("DF98AF9C-A315-4B68-BD63-31DFAA5FABCF", "D"), Guid("83D88E7E-D266-430A-8664-CA15AFFA0D66", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.fast_2_0xZoom = instance
        if self.fast_2_0xZoomFieldOfView ~= nil then
            self.fast_2_0xZoom.fieldOfView = self.fast_2_0xZoomFieldOfView
        end
        if self.fast_2_0xZoomLookSpeedMultiplier ~= nil then
            self.fast_2_0xZoom.lookSpeedMultiplier = self.fast_2_0xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("A211D3C5-2DA2-4A60-8A49-5F4D90D32CCB", "D"), Guid("A83312DC-829D-4B36-9A9B-F0140876E14A", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.defaultATSights = instance
        if self.defaultATSightsFieldOfView ~= nil then
            self.defaultATSights.fieldOfView = self.defaultATSightsFieldOfView
        end
        if self.defaultATSightsLookSpeedMultiplier ~= nil then
            self.defaultATSights.lookSpeedMultiplier = self.defaultATSightsLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("725A64F5-4A69-4F67-A933-89E43BB1E641", "D"), Guid("C6913617-8845-4A35-9146-38F2A988EC03", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x8_0xZoom = instance
        if self.x8_0xZoomFieldOfView ~= nil then
            self.x8_0xZoom.fieldOfView = self.x8_0xZoomFieldOfView
        end
        if self.x8_0xZoomLookSpeedMultiplier ~= nil then
            self.x8_0xZoom.lookSpeedMultiplier = self.x8_0xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("D6C590F7-9AFE-4B45-BA23-5D187678C42C", "D"), Guid("BC4F88FE-DC56-4EDB-B2C6-9ABAFD993A88", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x7_0xZoom = instance
        if self.x7_0xZoomFieldOfView ~= nil then
            self.x7_0xZoom.fieldOfView = self.x7_0xZoomFieldOfView
        end
        if self.x7_0xZoomLookSpeedMultiplier ~= nil then
            self.x7_0xZoom.lookSpeedMultiplier = self.x7_0xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("8815B047-AEB1-4BCB-9A25-0128D948B3EE", "D"), Guid("6A83DD0E-1CA3-47DF-A829-F0EFEFF228F1", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x6xENVG = instance
        if self.x6xENVGFieldOfView ~= nil then
            self.x6xENVG.fieldOfView = self.x6xENVGFieldOfView
        end
        if self.x6xENVGLookSpeedMultiplier ~= nil then
            self.x6xENVG.lookSpeedMultiplier = self.x6xENVGLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("1EDCC582-8B61-44DC-876C-C2DBB03FF74B", "D"), Guid("531FFD11-A7A9-4175-9049-7ADA2333931D", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x6_0xZoom = instance
        if self.x6_0xZoomFieldOfView ~= nil then
            self.x6_0xZoom.fieldOfView = self.x6_0xZoomFieldOfView
        end
        if self.x6_0xZoomLookSpeedMultiplier ~= nil then
            self.x6_0xZoom.lookSpeedMultiplier = self.x6_0xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("7F25A028-ED1A-4B4E-A291-8A8E8B3A9159", "D"), Guid("BF74D9F8-E11C-4075-BDDB-AAC3F27C608D", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x4_0xZoom = instance
        if self.x4_0xZoomFieldOfView ~= nil then
            self.x4_0xZoom.fieldOfView = self.x4_0xZoomFieldOfView
        end
        if self.x4_0xZoomLookSpeedMultiplier ~= nil then
            self.x4_0xZoom.lookSpeedMultiplier = self.x4_0xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("6E7D36F2-7BAC-4E20-A8D7-8ABF9F7FC6D2", "D"), Guid("E7AA2666-EE70-4B9F-A918-7686E7932DAF", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x3_4xZoom = instance
        if self.x3_4xZoomFieldOfView ~= nil then
            self.x3_4xZoom.fieldOfView = self.x3_4xZoomFieldOfView
        end
        if self.x3_4xZoomLookSpeedMultiplier ~= nil then
            self.x3_4xZoom.lookSpeedMultiplier = self.x3_4xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("3D6A5B06-8046-47E8-8EE6-348E878E5DF5", "D"), Guid("B06E9839-DA28-42E6-86C4-42D1F8E3AADB", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x2_0xZoom = instance
        if self.x2_0xZoomFieldOfView ~= nil then
            self.x2_0xZoom.fieldOfView = self.x2_0xZoomFieldOfView
        end
        if self.x2_0xZoomLookSpeedMultiplier ~= nil then
            self.x2_0xZoom.lookSpeedMultiplier = self.x2_0xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("609CC1AC-4B36-4197-B1C1-2357E57CEBAF", "D"), Guid("34C9BF53-1E0C-42D3-9EC1-696421E8A420", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x20xZoom = instance
        if self.x20xZoomFieldOfView ~= nil then
            self.x20xZoom.fieldOfView = self.x20xZoomFieldOfView
        end
        if self.x20xZoomLookSpeedMultiplier ~= nil then
            self.x20xZoom.lookSpeedMultiplier = self.x20xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("401211FA-7E01-4019-BA4A-247406AD4776", "D"), Guid("9C462DC8-87D6-41B0-A4EF-9111E8D960B0", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x20xENVG_COOP = instance
        if self.x20xENVG_COOPFieldOfView ~= nil then
            self.x20xENVG_COOP.fieldOfView = self.x20xENVG_COOPFieldOfView
        end
        if self.x20xENVG_COOPLookSpeedMultiplier ~= nil then
            self.x20xENVG_COOP.lookSpeedMultiplier = self.x20xENVG_COOPLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("C28310FD-2731-44A3-9B56-A048B3227EA6", "D"), Guid("242DAE61-CC3D-428A-8AC5-324FA95EBE7B", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x1xENVG = instance
        if self.x1xENVGFieldOfView ~= nil then
            self.x1xENVG.fieldOfView = self.x1xENVGFieldOfView
        end
        if self.x1xENVGLookSpeedMultiplier ~= nil then
            self.x1xENVG.lookSpeedMultiplier = self.x1xENVGLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("72AFA964-EFE0-4203-83E2-88052DD7ECBA", "D"), Guid("B6B46C0F-92B8-4F9F-9429-595261801A14", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x12_0xZoom = instance
        if self.x12_0xZoomFieldOfView ~= nil then
            self.x12_0xZoom.fieldOfView = self.x12_0xZoomFieldOfView
        end
        if self.x12_0xZoomLookSpeedMultiplier ~= nil then
            self.x12_0xZoom.lookSpeedMultiplier = self.x12_0xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("D8CE5A90-5A74-4726-9D3C-B879996246E1", "D"), Guid("E754B4D6-BAD4-4FEE-9E00-8F9C4904975E", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x10xENVG = instance
        if self.x10xENVGFieldOfView ~= nil then
            self.x10xENVG.fieldOfView = self.x10xENVGFieldOfView
        end
        if self.x10xENVGLookSpeedMultiplier ~= nil then
            self.x10xENVG.lookSpeedMultiplier = self.x10xENVGLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("F412EBAD-2551-4832-93A0-B9E1A412FB5D", "D"), Guid("E068484D-EE7F-4199-992A-59772D8B7D4B", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.x10_0xZoom = instance
        if self.x10_0xZoomFieldOfView ~= nil then
            self.x10_0xZoom.fieldOfView = self.x10_0xZoomFieldOfView
        end
        if self.x10_0xZoomLookSpeedMultiplier ~= nil then
            self.x10_0xZoom.lookSpeedMultiplier = self.x10_0xZoomLookSpeedMultiplier
        end
    end)
    ResourceManager:RegisterInstanceLoadHandler(Guid("FDAAAC18-0AC9-4E17-A723-4EC293FB0813", "D"), Guid("B2D0DC9F-B2A0-4B50-8BA5-A56B7AF1E44B", "D"), function(instance)
        instance = ZoomLevelData(instance)
        instance:MakeWritable()
        self.defaultBase = instance -- use ClientUtils:SetFieldOfView() when available
    end)
end

function ZoomLevel:OnLevelDestroy()
    if self.x10_0xZoom ~= nil then
		self.x10_0xZoomFieldOfView = self.x10_0xZoom.fieldOfView
		self.x10_0xZoomLookSpeedMultiplier = self.x10_0xZoom.lookSpeedMultiplier
	end
	if self.x10xENVG ~= nil then
		self.x10xENVGFieldOfView = self.x10xENVG.fieldOfView
		self.x10xENVGLookSpeedMultiplier = self.x10xENVG.lookSpeedMultiplier
	end
	if self.x12_0xZoom ~= nil then
		self.x12_0xZoomFieldOfView = self.x12_0xZoom.fieldOfView
		self.x12_0xZoomLookSpeedMultiplier = self.x12_0xZoom.lookSpeedMultiplier
	end
	if self.x1xENVG ~= nil then
		self.x1xENVGFieldOfView = self.x1xENVG.fieldOfView
		self.x1xENVGLookSpeedMultiplier = self.x1xENVG.lookSpeedMultiplier
	end
	if self.x20xENVG_COOP ~= nil then
		self.x20xENVG_COOPFieldOfView = self.x20xENVG_COOP.fieldOfView
		self.x20xENVG_COOPLookSpeedMultiplier = self.x20xENVG_COOP.lookSpeedMultiplier
	end
	if self.x20xZoom ~= nil then
		self.x20xZoomFieldOfView = self.x20xZoom.fieldOfView
		self.x20xZoomLookSpeedMultiplier = self.x20xZoom.lookSpeedMultiplier
	end
	if self.x2_0xZoom ~= nil then
		self.x2_0xZoomFieldOfView = self.x2_0xZoom.fieldOfView
		self.x2_0xZoomLookSpeedMultiplier = self.x2_0xZoom.lookSpeedMultiplier
	end
	if self.x3_4xZoom ~= nil then
		self.x3_4xZoomFieldOfView = self.x3_4xZoom.fieldOfView
		self.x3_4xZoomLookSpeedMultiplier = self.x3_4xZoom.lookSpeedMultiplier
	end
	if self.x4_0xZoom ~= nil then
		self.x4_0xZoomFieldOfView = self.x4_0xZoom.fieldOfView
		self.x4_0xZoomLookSpeedMultiplier = self.x4_0xZoom.lookSpeedMultiplier
	end
	if self.x6_0xZoom ~= nil then
		self.x6_0xZoomFieldOfView = self.x6_0xZoom.fieldOfView
		self.x6_0xZoomLookSpeedMultiplier = self.x6_0xZoom.lookSpeedMultiplier
	end
	if self.x6xENVG ~= nil then
		self.x6xENVGFieldOfView = self.x6xENVG.fieldOfView
		self.x6xENVGLookSpeedMultiplier = self.x6xENVG.lookSpeedMultiplier
	end
	if self.x7_0xZoom ~= nil then
		self.x7_0xZoomFieldOfView = self.x7_0xZoom.fieldOfView
		self.x7_0xZoomLookSpeedMultiplier = self.x7_0xZoom.lookSpeedMultiplier
	end
	if self.x8_0xZoom ~= nil then
		self.x8_0xZoomFieldOfView = self.x8_0xZoom.fieldOfView
		self.x8_0xZoomLookSpeedMultiplier = self.x8_0xZoom.lookSpeedMultiplier
	end
	if self.defaultATSights ~= nil then
		self.defaultATSightsFieldOfView = self.defaultATSights.fieldOfView
		self.defaultATSightsLookSpeedMultiplier = self.defaultATSights.lookSpeedMultiplier
	end
	if self.fast_2_0xZoom ~= nil then
		self.fast_2_0xZoomFieldOfView = self.fast_2_0xZoom.fieldOfView
		self.fast_2_0xZoomLookSpeedMultiplier = self.fast_2_0xZoom.lookSpeedMultiplier
	end
	if self.fastIronSights ~= nil then
		self.fastIronSightsFieldOfView = self.fastIronSights.fieldOfView
		self.fastIronSightsLookSpeedMultiplier = self.fastIronSights.lookSpeedMultiplier
	end
	if self.defaultIronSights ~= nil then
		self.defaultIronSightsFieldOfView = self.defaultIronSights.fieldOfView
		self.defaultIronSightsLookSpeedMultiplier = self.defaultIronSights.lookSpeedMultiplier
	end
	
	self.defaultBase = nil -- this one is broken
	self.x10_0xZoom = nil
	self.x10xENVG = nil
	self.x12_0xZoom = nil
	self.x1xENVG = nil
	self.x20xENVG_COOP = nil
	self.x20xZoom = nil
	self.x2_0xZoom = nil
	self.x3_4xZoom = nil
	self.x4_0xZoom = nil
	self.x6_0xZoom = nil
	self.x6xENVG = nil
	self.x7_0xZoom = nil
	self.x8_0xZoom = nil
	self.defaultATSights = nil
	self.fast_2_0xZoom = nil
	self.fastIronSights = nil
	self.defaultIronSights = nil
end

return ZoomLevel