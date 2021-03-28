class 'Admin'

function Admin:__init()
    -- Admin actions for players
	Events:Subscribe('WebUI:MovePlayer', self, self.OnWebUIMovePlayer)
	Events:Subscribe('WebUI:KillPlayer', self, self.OnWebUIKillPlayer)
	Events:Subscribe('WebUI:KickPlayer', self, self.OnWebUIKickPlayer)
	Events:Subscribe('WebUI:TBanPlayer', self, self.OnWebUITBanPlayer)
	Events:Subscribe('WebUI:BanPlayer', self, self.OnWebUIBanPlayer)
	Events:Subscribe('WebUI:GetAdminRightsOfPlayer', self, self.OnWebUIGetAdminRightsOfPlayer)
	NetEvents:Subscribe('AdminRightsOfPlayer', self, self.OnAdminRightsOfPlayer)
	Events:Subscribe('WebUI:DeleteAdminRights', self, self.OnWebUIDeleteAdminRights)
	Events:Subscribe('WebUI:DeleteAndSaveAdminRights', self, self.OnWebUIDeleteAndSaveAdminRights)
	Events:Subscribe('WebUI:UpdateAdminRights', self, self.OnWebUIUpdateAdminRights)
	Events:Subscribe('WebUI:UpdateAndSaveAdminRights', self, self.OnWebUIUpdateAndSaveAdminRights)
	
	-- Admin Map Rotation
	NetEvents:Subscribe('MapRotation', self, self.OnMapRotation)
	Events:Subscribe('WebUI:SetNextMap', self, self.OnSetNextMap)
	Events:Subscribe('WebUI:RunNextRound', self, self.OnWebUIRunNextRound)
	Events:Subscribe('WebUI:RestartRound', self, self.OnWebUIRestartRound)
	
	-- Admin Server Setup
	Events:Subscribe('WebUI:GetServerSetupSettings', self, self.OnWebUIGetServerSetupSettings)
	NetEvents:Subscribe('ServerSetupSettings', self, self.OnServerSetupSettings)
	Events:Subscribe('WebUI:SaveServerSetupSettings', self, self.OnWebUISaveServerSetupSettings)
	
	-- Manage Presets
	Events:Subscribe('WebUI:ApplyManagePresets', self, self.OnWebUIApplyManagePresets)
	
	-- Manage ModSettings
	Events:Subscribe('WebUI:ResetGeneralModSettings', self, self.OnWebUIResetGeneralModSettings)
	Events:Subscribe('WebUI:ResetAndSaveGeneralModSettings', self, self.OnWebUIResetAndSaveGeneralModSettings)
	Events:Subscribe('WebUI:ApplyGeneralModSettings', self, self.OnWebUIApplyGeneralModSettings)
	Events:Subscribe('WebUI:SaveGeneralModSettings', self, self.OnWebUISaveGeneralModSettings)

	-- Get Admin Rights
	NetEvents:Subscribe('ServerOwnerRights', self, self.OnServerOwnerRights)
    NetEvents:Subscribe('AdminPlayer', self, self.OnAdminPlayer)
    
	-- Server Owner Quick Server Setup
	NetEvents:Subscribe('QuickServerSetup', self, self.OnQuickServerSetup)
end

function Admin:OnWebUIMovePlayer(args)
	NetEvents:Send('MovePlayer', json.decode(args))
end
function Admin:OnWebUIKillPlayer(args)
	NetEvents:Send('KillPlayer', json.decode(args))
end
function Admin:OnWebUIKickPlayer(args)
	NetEvents:Send('KickPlayer', json.decode(args))
end
function Admin:OnWebUITBanPlayer(args)
	NetEvents:Send('TBanPlayer', json.decode(args))
end
function Admin:OnWebUIBanPlayer(args)
	NetEvents:Send('BanPlayer', json.decode(args))
end
function Admin:OnWebUIGetAdminRightsOfPlayer(getAdminRightsOfPlayer)
	NetEvents:Send('GetAdminRightsOfPlayer', getAdminRightsOfPlayer)
end
function Admin:OnAdminRightsOfPlayer(args)
	WebUI:ExecuteJS(string.format("getAdminRightsOfPlayerDone(%s)", json.encode(args)))
end
function Admin:OnWebUIDeleteAdminRights(args)
	NetEvents:Send('DeleteAdminRights', json.decode(args))
end
function Admin:OnWebUIDeleteAndSaveAdminRights(args)
	NetEvents:Send('DeleteAndSaveAdminRights', json.decode(args))
end
function Admin:OnWebUIUpdateAdminRights(args)
	NetEvents:Send('UpdateAdminRights', json.decode(args))
end
function Admin:OnWebUIUpdateAndSaveAdminRights(args)
	NetEvents:Send('UpdateAndSaveAdminRights', json.decode(args))
end

function Admin:OnMapRotation(args)
	WebUI:ExecuteJS(string.format("getCurrentMapRotation(%s)", json.encode(args)))
end
function Admin:OnSetNextMap(mapIndex)
	NetEvents:Send('SetNextMap', json.decode(mapIndex))
end
function Admin:OnWebUIRunNextRound()
	NetEvents:Send('RunNextRound')
end
function Admin:OnWebUIRestartRound()
	NetEvents:Send('RestartRound')
end

-- Admin ServerSetup
function Admin:OnWebUIGetServerSetupSettings()
	NetEvents:Send('GetServerSetupSettings')
end

function Admin:OnServerSetupSettings(args)
	WebUI:ExecuteJS(string.format("getServerSetupSettings(%s)", json.encode(args)))
end

function Admin:OnWebUISaveServerSetupSettings(args)
	NetEvents:Send('SaveServerSetupSettings', json.decode(args))
end

-- Manage Presets
function Admin:OnWebUIApplyManagePresets(args)
	NetEvents:Send('ManagePresets', json.decode(args))
end

-- Manage ModSettings
function Admin:OnWebUIResetGeneralModSettings()
	NetEvents:Send('ResetModSettings')
end

function Admin:OnWebUIResetAndSaveGeneralModSettings()
	NetEvents:Send('ResetAndSaveModSettings')
end

function Admin:OnWebUIApplyGeneralModSettings(args)
	NetEvents:Send('ApplyModSettings', json.decode(args))
end

function Admin:OnWebUISaveGeneralModSettings(args)
	NetEvents:Send('SaveModSettings', json.decode(args))
end

-- Set Admin
function Admin:OnServerOwnerRights()
	WebUI:ExecuteJS("setOwnerRights()")
end

function Admin:OnAdminPlayer(args)
	WebUI:ExecuteJS(string.format("getAdminRights(%s)", json.encode(args)))
end

-- ServerOwner Quick Server Setup
function Admin:OnQuickServerSetup()
	WebUI:ExecuteJS(string.format("quickServerSetup()"))
end

return Admin