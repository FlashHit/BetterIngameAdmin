---@class Admin
Admin = class 'Admin'

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

function Admin:OnWebUIMovePlayer(p_Args)
	NetEvents:Send('MovePlayer', json.decode(p_Args))
end
function Admin:OnWebUIKillPlayer(p_Args)
	NetEvents:Send('KillPlayer', json.decode(p_Args))
end
function Admin:OnWebUIKickPlayer(p_Args)
	NetEvents:Send('KickPlayer', json.decode(p_Args))
end
function Admin:OnWebUITBanPlayer(p_Args)
	NetEvents:Send('TBanPlayer', json.decode(p_Args))
end
function Admin:OnWebUIBanPlayer(p_Args)
	NetEvents:Send('BanPlayer', json.decode(p_Args))
end
function Admin:OnWebUIGetAdminRightsOfPlayer(p_GetAdminRightsOfPlayer)
	NetEvents:Send('GetAdminRightsOfPlayer', p_GetAdminRightsOfPlayer)
end
function Admin:OnAdminRightsOfPlayer(p_Args)
	WebUI:ExecuteJS(string.format("getAdminRightsOfPlayerDone(%s)", json.encode(p_Args)))
end
function Admin:OnWebUIDeleteAdminRights(p_Args)
	NetEvents:Send('DeleteAdminRights', json.decode(p_Args))
end
function Admin:OnWebUIDeleteAndSaveAdminRights(p_Args)
	NetEvents:Send('DeleteAndSaveAdminRights', json.decode(p_Args))
end
function Admin:OnWebUIUpdateAdminRights(p_Args)
	NetEvents:Send('UpdateAdminRights', json.decode(p_Args))
end
function Admin:OnWebUIUpdateAndSaveAdminRights(p_Args)
	NetEvents:Send('UpdateAndSaveAdminRights', json.decode(p_Args))
end

function Admin:OnMapRotation(p_Args)
	WebUI:ExecuteJS(string.format("getCurrentMapRotation(%s)", json.encode(p_Args)))
end
function Admin:OnSetNextMap(p_MapIndex)
	NetEvents:Send('SetNextMap', json.decode(p_MapIndex))
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

function Admin:OnServerSetupSettings(p_Args)
	WebUI:ExecuteJS(string.format("getServerSetupSettings(%s)", json.encode(p_Args)))
end

function Admin:OnWebUISaveServerSetupSettings(p_Args)
	NetEvents:Send('SaveServerSetupSettings', json.decode(p_Args))
end

-- Manage Presets
function Admin:OnWebUIApplyManagePresets(p_Args)
	NetEvents:Send('ManagePresets', json.decode(p_Args))
end

-- Manage ModSettings
function Admin:OnWebUIResetGeneralModSettings()
	NetEvents:Send('ResetModSettings')
end

function Admin:OnWebUIResetAndSaveGeneralModSettings()
	NetEvents:Send('ResetAndSaveModSettings')
end

function Admin:OnWebUIApplyGeneralModSettings(p_Args)
	NetEvents:Send('ApplyModSettings', json.decode(p_Args))
end

function Admin:OnWebUISaveGeneralModSettings(p_Args)
	NetEvents:Send('SaveModSettings', json.decode(p_Args))
end

-- Set Admin
function Admin:OnServerOwnerRights()
	WebUI:ExecuteJS("setOwnerRights()")
end

function Admin:OnAdminPlayer(p_Args)
	WebUI:ExecuteJS(string.format("getAdminRights(%s)", json.encode(p_Args)))
end

-- ServerOwner Quick Server Setup
function Admin:OnQuickServerSetup()
	WebUI:ExecuteJS(string.format("quickServerSetup()"))
end

if g_Admin == nil then
	g_Admin = Admin()
end

return g_Admin
