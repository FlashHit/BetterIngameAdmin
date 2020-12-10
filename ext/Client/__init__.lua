class 'BetterIngameAdmin'

function BetterIngameAdmin:__init()
    print("Initializing BetterIngameAdmin")
    self:RegisterVars()
    self:RegisterEvents()
	-- Region MouseSensitivity and Field Of View
	self:RegisterResourceManagerCallbacks()
	-- Endregion
end

function BetterIngameAdmin:RegisterVars()
	-- Region vote stuff
	self.voteInProgress = false
	self.cumulatedTime = 0
	self.count = 1
	self.secondsToVote = 30 -- Add to Admin Settings
	-- Endregion
	
	-- Region Todo: use local instead of self.
	self.usTickets = 0
	self.ruTickets = 0
	-- Endregion
	
	-- Region Assist
		-- use local if delete Assist function
	self.playerTeam1Count = 0
	self.playerTeam2Count = 0
	self.playerTeam3Count = 0
	self.playerTeam4Count = 0
	-- Endregion
	
	-- Region Local Ping
	self.showPing = false
	-- Endregion
	
	-- Region Scoreboard
	self.active = false
		-- Region Client Settings
	self.toggleScoreboard = false
		-- Endregion
	self.ignoreReleaseTab = false
	self.dontUpdate = false
	self.updateScoreboardInterval = 2 -- Add to Admin Settings
	self.cumulatedTimeForScoreboard = 0
	self.blockTab = false
	self.pingTable = {}
	-- Endregion
	
	-- Region Mute
		-- Client Settings
	self.mutedPlayers = {}
	self.mutedChannels = {}
	-- Endregion
	
	-- Region MouseSensitivity and Field Of View
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
	-- Endregion
	
	-- Region ServerInfo
	self.serverInfo = nil
	-- Endregion
end

function BetterIngameAdmin:RegisterEvents()
	-- Region WebUI Init
	Events:Subscribe('Extension:Loaded', self, self.OnExtensionLoaded) 
	-- Endregion
	
	-- Region PopupResponse
	NetEvents:Subscribe('PopupResponse', self, self.OnPopupResponse)
	-- Endregion
	
	-- Region vote stuff
	Events:Subscribe('WebUI:VotekickPlayer', self, self.OnWebUIVotekickPlayer)
	Events:Subscribe('WebUI:VotebanPlayer', self, self.OnWebUIVotebanPlayer)
	Events:Subscribe('WebUI:Surrender', self, self.OnWebUISurrender)
	NetEvents:Subscribe('Start:VotekickPlayer', self, self.OnStartVotekickPlayer)
	NetEvents:Subscribe('Start:VotebanPlayer', self, self.OnStartVotebanPlayer)
	NetEvents:Subscribe('Start:Surrender', self, self.OnStartSurrender)
	NetEvents:Subscribe('Remove:OneYesVote', self, self.OnRemoveOneYesVote)
	NetEvents:Subscribe('Remove:OneNoVote', self, self.OnRemoveOneNoVote)
	NetEvents:Subscribe('Vote:Yes', self, self.OnVoteYes)
	NetEvents:Subscribe('Vote:No', self, self.OnVoteNo)
		-- when trying to start a new vote but a vote is in progress, send him an error "A vote is already in progress"
		-- I think this one is missing in WebUI, so atm this does nothing
	NetEvents:Subscribe('VoteInProgress', self, self.OnVoteInProgress)
	-- Endregion
	
	-- Region Admin actions for players
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
		-- missing admin responses: "Successful action on player", "Action on player failed cuz left/ or not found)"
	-- Endregion
	
	-- Region Assist
	Events:Subscribe('WebUI:AssistEnemyTeam', self, self.OnWebUIAssistEnemyTeam)
	Events:Subscribe('WebUI:CancelAssistEnemyTeam', self, self.OnWebUICancelAssistEnemyTeam)
		-- missing: WebUI:CancelAssist after getting in Queue (Queue is also missing at this point)
	-- Endregion
	
	-- Region Squad stuff
	Events:Subscribe('WebUI:LeaveSquad', self, self.OnWebUILeaveSquad)
	Events:Subscribe('WebUI:CreateSquad', self, self.OnWebUICreateSquad)
	Events:Subscribe('WebUI:JoinSquad', self, self.OnWebUIJoinSquad)
		-- if you are the squad leader
	Events:Subscribe('WebUI:PrivateSquad', self, self.OnWebUIPrivateSquad)
	Events:Subscribe('WebUI:KickFromSquad', self, self.OnWebUIKickFromSquad)
	Events:Subscribe('WebUI:MakeSquadLeader', self, self.OnWebUIMakeSquadLeader)
	-- Endregion
	
	-- Region Admin Map Rotation
	NetEvents:Subscribe('MapRotation', self, self.OnMapRotation)
	Events:Subscribe('WebUI:SetNextMap', self, self.OnSetNextMap)
	Events:Subscribe('WebUI:RunNextRound', self, self.OnWebUIRunNextRound)
	Events:Subscribe('WebUI:RestartRound', self, self.OnWebUIRestartRound)
	-- Endregion
	
	-- Region Admin Server Setup
	Events:Subscribe('WebUI:GetServerSetupSettings', self, self.OnWebUIGetServerSetupSettings)
	NetEvents:Subscribe('ServerSetupSettings', self, self.OnServerSetupSettings)
	Events:Subscribe('WebUI:SaveServerSetupSettings', self, self.OnWebUISaveServerSetupSettings)
	-- Endregion
	
	-- Region Manage Presets
	Events:Subscribe('WebUI:ApplyManagePresets', self, self.OnWebUIApplyManagePresets)
	-- Endregion
	
	-- Region Local Ping
	Events:Subscribe('WebUI:ShowPing', self, self.OnWebUIShowPing)
	Events:Subscribe('WebUI:HidePing', self, self.OnWebUIHidePing)
	-- Endregion
	
	-- Region Mute
	Events:Subscribe('WebUI:MutePlayer', self, self.OnWebUIMutePlayer)
	Events:Subscribe('WebUI:UnmutePlayer', self, self.OnWebUIUnmutePlayer)
	Events:Subscribe('WebUI:ChatChannels', self, self.OnWebUIChatChannels)
	Hooks:Install('ClientChatManager:IncomingMessage', 1, self, self.OnCreateChatMessage)
	-- Endregion
	
	-- Region MouseSensitivity and Field Of View
	Events:Subscribe('WebUI:GetMouseSensitivity', self, self.OnWebUIGetMouseSensitivity)
	Events:Subscribe('WebUI:SetMouseSensitivity', self, self.OnWebUISetMouseSensitivity)
	Events:Subscribe('WebUI:GetMouseSensitivityMultipliers', self, self.OnWebUIGetMouseSensitivityMultipliers)
	Events:Subscribe('WebUI:SetMouseSensitivityMultipliers', self, self.OnWebUISetMouseSensitivityMultipliers)
	Events:Subscribe('WebUI:ResetMouseSensitivityMultipliers', self, self.OnWebUIResetMouseSensitivityMultipliers)
	Events:Subscribe('WebUI:GetFieldOfView', self, self.OnWebUIGetFieldOfView)
	Events:Subscribe('WebUI:SetFieldOfView', self, self.OnWebUISetFieldOfView)
	Events:Subscribe('WebUI:ResetFieldOfView', self, self.OnWebUIResetFieldOfView)
	-- Endregion
	
	-- Region Scoreboard
	Hooks:Install('UI:InputConceptEvent', 1, self, self.OnUIInputConceptEvent)
		-- also check Votingkeys
	Events:Subscribe('Engine:Update', self, self.OnEngineUpdate)
	-- self:UpdateUI()
	Events:Subscribe('WebUI:ToggleScoreboard', self, self.OnWebUIToggleScoreboard) -- remove this one
	Events:Subscribe('WebUI:HoldScoreboard', self, self.OnWebUIHoldScoreboard)
	Events:Subscribe('WebUI:ClickScoreboard', self, self.OnWebUIClickScoreboard)
	Events:Subscribe('WebUI:IgnoreReleaseTab', self, self.OnWebUIIgnoreReleaseTab)
	Events:Subscribe('WebUI:ActiveFalse', self, self.OnWebUIActiveFalse)
		-- Hide the scoreboard and reset the mouse when you get revived
		-- check if I need to reset keyboard too
	Events:Subscribe('Soldier:HealthAction', self, self.OnSoldierHealthAction)
	Hooks:Install('UI:PushScreen', 1, self, self.OnUIPushScreen)
	NetEvents:Subscribe('Player:Ping', self, self.OnPlayerPing)
	-- Endregion
	
	-- Region Get Admin Rights
	NetEvents:Subscribe('ServerOwnerRights', self, self.OnServerOwnerRights)
	NetEvents:Subscribe('AdminPlayer', self, self.OnAdminPlayer)
	-- Endregion
	
	-- Region ServerInfo
	NetEvents:Subscribe('ServerInfo', self, self.OnServerInfo)
	Events:Subscribe('WebUI:GetPlayerCount', self, self.OnGetPlayerCount)
	-- Endregion
	
	-- Region ServerBanner Loading Screen
	Events:Subscribe('Level:LoadingInfo', self, self.OnLevelLoadingInfo)
	NetEvents:Subscribe('Info', self, self.OnInfo) -- Todo: Rename to ServerBannerInfo or LoadingScreenInfo
	Events:Subscribe('Level:Destroy', self, self.OnLevelDestroy)
	-- Endregion
	
	-- Region Server Owner Quick Server Setup
	NetEvents:Subscribe('QuickServerSetup', self, self.OnQuickServerSetup)
	-- Endregion
	
	-- Region debug event to see if things work correct
	Events:Subscribe('WebUI:PrintThis', function(arg)
		print(arg)
	end)
	-- Endregion
	
	-- Region TODOS
		-- missing: WebUI:ShowHidePing when ClientUtils:GetPing() will be implemented; then update every 5 seconds via EngineUpdate
		
		-- level loaded event for fov and mouseSensitivity stuff and voteCount reset
		--Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded)
	-- Endregion
	
	-- Region things to delete from old unfinshed admin panel
	Events:Subscribe('WebUI:GetGeneralSettings', self, self.OnWebUIGetGeneralSettings) -- remove this one?
	NetEvents:Subscribe('GeneralSettings', self, self.OnGeneralSettings) -- remove this?
	Events:Subscribe('WebUI:ApplyGeneralSettings', self, self.OnApplyGeneralSettings) -- remove this one?
	Events:Subscribe('WebUI:GetMapSettings', self, self.OnWebUIGetMapSettings) -- remove
	NetEvents:Subscribe('MapSettings', self, self.OnMapSettings) -- remove
	Events:Subscribe('WebUI:ApplyMapSettings', self, self.OnApplyMapSettings) -- remove
	-- Endregion
end

-- Region WebUI Init
function BetterIngameAdmin:OnExtensionLoaded()
    WebUI:Init()
end
-- Endregion

-- Region PopupResponse
function BetterIngameAdmin:OnPopupResponse(message)
    WebUI:ExecuteJS(string.format("showPopupResponse(%s)", json.encode(message)))
end
-- Endregion

-- Region vote stuff
function BetterIngameAdmin:OnWebUIVotekickPlayer(playerName)
	NetEvents:Send('VotekickPlayer', playerName)
end

function BetterIngameAdmin:OnWebUIVotebanPlayer(playerName)
	NetEvents:Send('VotebanPlayer', playerName)
end

function BetterIngameAdmin:OnWebUISurrender()
	NetEvents:Send('Surrender')
end

function BetterIngameAdmin:OnStartVotekickPlayer(votekickPlayer)
	self.voteInProgress = true
	WebUI:ExecuteJS(string.format("startvotekick(%s)", json.encode(votekickPlayer)))
end

function BetterIngameAdmin:OnStartVotebanPlayer(votebanPlayer)
	self.voteInProgress = true
	WebUI:ExecuteJS(string.format("startvoteban(%s)", json.encode(votebanPlayer)))
end

function BetterIngameAdmin:OnStartSurrender(typeOfVote)
	self.voteInProgress = true
	local player = PlayerManager:GetLocalPlayer()
	if typeOfVote == "surrenderUS" then
		if player.teamId == TeamId.Team1 then
			WebUI:ExecuteJS(string.format("startsurrender()"))
		end
	elseif typeOfVote == "surrenderRU" then
		if player.teamId == TeamId.Team2 then
			WebUI:ExecuteJS(string.format("startsurrender()"))
		end
	end
end

function BetterIngameAdmin:OnRemoveOneYesVote()
	WebUI:ExecuteJS(string.format("removeOneYesVote()"))
end

function BetterIngameAdmin:OnRemoveOneNoVote()
	WebUI:ExecuteJS(string.format("removeOneNoVote()"))
end

function BetterIngameAdmin:OnVoteYes()
	WebUI:ExecuteJS(string.format("voteYes()"))
end

function BetterIngameAdmin:OnVoteNo()
	WebUI:ExecuteJS(string.format("voteNo()"))
end

function BetterIngameAdmin:OnVoteInProgress()
	WebUI:ExecuteJS(string.format("voteInProgress()"))
end
-- Endregion

-- Region Admin actions for players
function BetterIngameAdmin:OnWebUIMovePlayer(args)
	NetEvents:Send('MovePlayer', json.decode(args))
end

function BetterIngameAdmin:OnWebUIKillPlayer(args)
	NetEvents:Send('KillPlayer', json.decode(args))
end

function BetterIngameAdmin:OnWebUIKickPlayer(args)
	NetEvents:Send('KickPlayer', json.decode(args))
end

function BetterIngameAdmin:OnWebUITBanPlayer(args)
	NetEvents:Send('TBanPlayer', json.decode(args))
end

function BetterIngameAdmin:OnWebUIBanPlayer(args)
	NetEvents:Send('BanPlayer', json.decode(args))
end

function BetterIngameAdmin:OnWebUIGetAdminRightsOfPlayer(getAdminRightsOfPlayer)
	NetEvents:Send('GetAdminRightsOfPlayer', getAdminRightsOfPlayer)
end

function BetterIngameAdmin:OnAdminRightsOfPlayer(args)
	WebUI:ExecuteJS(string.format("getAdminRightsOfPlayerDone(%s)", json.encode(args)))
end

function BetterIngameAdmin:OnWebUIDeleteAdminRights(args)
	NetEvents:Send('DeleteAdminRights', json.decode(args))
end

function BetterIngameAdmin:OnWebUIDeleteAndSaveAdminRights(args)
	NetEvents:Send('DeleteAndSaveAdminRights', json.decode(args))
end

function BetterIngameAdmin:OnWebUIUpdateAdminRights(args)
	NetEvents:Send('UpdateAdminRights', json.decode(args))
end

function BetterIngameAdmin:OnWebUIUpdateAndSaveAdminRights(args)
	NetEvents:Send('UpdateAndSaveAdminRights', json.decode(args))
end
-- Endregion

-- Region Assist enemy team
function BetterIngameAdmin:OnWebUIAssistEnemyTeam()
	NetEvents:Send('AssistEnemyTeam')
end
function BetterIngameAdmin:OnWebUICancelAssistEnemyTeam()
	NetEvents:Send('CancelAssistEnemyTeam')
end
-- Endregion

-- Region Squad stuff
function BetterIngameAdmin:OnWebUILeaveSquad()
	NetEvents:Send('LeaveSquad')
end

function BetterIngameAdmin:OnWebUICreateSquad()
	NetEvents:Send('CreateSquad')
end

function BetterIngameAdmin:OnWebUIJoinSquad(playerName)
	NetEvents:Send('JoinSquad', playerName)
end

function BetterIngameAdmin:OnWebUIPrivateSquad()
	NetEvents:Send('PrivateSquad')
end

function BetterIngameAdmin:OnWebUIKickFromSquad(playerName)
	NetEvents:Send('KickFromSquad', playerName)
end

function BetterIngameAdmin:OnWebUIMakeSquadLeader(playerName)
	NetEvents:Send('MakeSquadLeader', playerName)
end
-- Endregion

-- Region Admin Map Rotation
function BetterIngameAdmin:OnMapRotation(args)
	WebUI:ExecuteJS(string.format("getCurrentMapRotation(%s)", json.encode(args)))
end

function BetterIngameAdmin:OnSetNextMap(mapIndex)
	NetEvents:Send('SetNextMap', json.decode(mapIndex))
end
function BetterIngameAdmin:OnWebUIRunNextRound()
	NetEvents:Send('RunNextRound')
end

function BetterIngameAdmin:OnWebUIRestartRound()
	NetEvents:Send('RestartRound')
end
-- Endregion

-- Region Admin ServerSetup
function BetterIngameAdmin:OnWebUIGetServerSetupSettings()
	NetEvents:Send('GetServerSetupSettings')
end

function BetterIngameAdmin:OnServerSetupSettings(args)
	WebUI:ExecuteJS(string.format("getServerSetupSettings(%s)", json.encode(args)))
end

function BetterIngameAdmin:OnWebUISaveServerSetupSettings(args)
	NetEvents:Send('SaveServerSetupSettings', json.decode(args))
end
-- Endregion

-- Region Manage Presets
function BetterIngameAdmin:OnWebUIApplyManagePresets(args)
	NetEvents:Send('ManagePresets', json.decode(args))
end
-- Endregion

-- Region Local Ping
function BetterIngameAdmin:OnWebUIShowPing()
	self.showPing = true
end

function BetterIngameAdmin:OnWebUIHidePing()
	self.showPing = false
end
-- Endregion

-- Region mute
function BetterIngameAdmin:OnWebUIMutePlayer(playerName)
	local player = PlayerManager:GetPlayerByName(playerName)
	local playerAlreadyMuted = false
	for _,mutedPlayer in pairs(self.mutedPlayers) do
		if mutedPlayer == player.id then	
			playerAlreadyMuted = true
			return
		end
	end
	if playerAlreadyMuted == false then
		table.insert(self.mutedPlayers, player.id)
		WebUI:ExecuteJS(string.format("successPlayerMuted()"))
	else
		WebUI:ExecuteJS(string.format("errorPlayerAlreadyMuted()"))
	end
end

function BetterIngameAdmin:OnWebUIUnmutePlayer(playerName)
	local player = PlayerManager:GetPlayerByName(playerName)
	local playerAlreadyMuted = false
	for i,mutedPlayer in pairs(self.mutedPlayers) do
		if mutedPlayer == player.id then	
			playerAlreadyMuted = true
			table.remove(self.mutedPlayers, i)
			return
		end
	end
	if playerAlreadyMuted == true then
		WebUI:ExecuteJS(string.format("successPlayerUnmuted()"))
	else
		WebUI:ExecuteJS(string.format("errorPlayerWasNotMuted()"))
	end
end

function BetterIngameAdmin:OnWebUIChatChannels(chatChannels)
	self.mutedChannels = {}
	if chatChannels ~= nil then
		chatChannels = json.decode(chatChannels)
		for i,channel in pairs(chatChannels) do
			table.insert(self.mutedChannels, tonumber(channel))
		end
	end
end

function BetterIngameAdmin:OnCreateChatMessage(hook, message, playerId, recipientMask, channelId, isSenderDead)
	for _,mutedPlayer in pairs(self.mutedPlayers) do
		if mutedPlayer == playerId then
			hook:Return()
		end
	end
	for _,mutedChannel in pairs(self.mutedChannels) do
		if mutedChannel == channelId then
			hook:Return()
		end
	end
end
-- Endregion

-- Region MouseSensitivity and Field Of View
function BetterIngameAdmin:OnWebUIGetMouseSensitivity()
	if self.toggleScoreboard == false then
		self.ignoreReleaseTab = true
	end
	local mouseSensitivity = InputManager:GetMouseSensitivity()
	WebUI:ExecuteJS(string.format("getMouseSensitivity(%s)", json.encode(mouseSensitivity)))
end

function BetterIngameAdmin:OnWebUISetMouseSensitivity(mouseSensitivity)
	InputManager:SetMouseSensitivity(tonumber(mouseSensitivity))
end

function BetterIngameAdmin:OnWebUIGetMouseSensitivityMultipliers()
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

function BetterIngameAdmin:OnWebUISetMouseSensitivityMultipliers(args)
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

function BetterIngameAdmin:OnWebUIResetMouseSensitivityMultipliers()
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

function BetterIngameAdmin:OnWebUIGetFieldOfView()
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

function BetterIngameAdmin:OnWebUISetFieldOfView(args)
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

function BetterIngameAdmin:OnWebUIResetFieldOfView()
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

function BetterIngameAdmin:RegisterResourceManagerCallbacks()
	ResourceManager:RegisterInstanceLoadHandler(Guid("895050F3-B0D1-4F83-A57B-CCFA3EB0B31D", "D"), Guid("5C006FDF-FA1D-4E29-8E21-2ECAB83AC01C", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.defaultIronSights = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("FFEAFC24-9812-44BF-AD98-EBC06193739C", "D"), Guid("50887762-21DF-42F5-9740-ECDBCEECC3B4", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.fastIronSights = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("DF98AF9C-A315-4B68-BD63-31DFAA5FABCF", "D"), Guid("83D88E7E-D266-430A-8664-CA15AFFA0D66", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.fast_2_0xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("A211D3C5-2DA2-4A60-8A49-5F4D90D32CCB", "D"), Guid("A83312DC-829D-4B36-9A9B-F0140876E14A", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.defaultATSights = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("725A64F5-4A69-4F67-A933-89E43BB1E641", "D"), Guid("C6913617-8845-4A35-9146-38F2A988EC03", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x8_0xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("D6C590F7-9AFE-4B45-BA23-5D187678C42C", "D"), Guid("BC4F88FE-DC56-4EDB-B2C6-9ABAFD993A88", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x7_0xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("8815B047-AEB1-4BCB-9A25-0128D948B3EE", "D"), Guid("6A83DD0E-1CA3-47DF-A829-F0EFEFF228F1", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x6xENVG = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("1EDCC582-8B61-44DC-876C-C2DBB03FF74B", "D"), Guid("531FFD11-A7A9-4175-9049-7ADA2333931D", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x6_0xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("7F25A028-ED1A-4B4E-A291-8A8E8B3A9159", "D"), Guid("BF74D9F8-E11C-4075-BDDB-AAC3F27C608D", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x4_0xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("6E7D36F2-7BAC-4E20-A8D7-8ABF9F7FC6D2", "D"), Guid("E7AA2666-EE70-4B9F-A918-7686E7932DAF", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x3_4xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("3D6A5B06-8046-47E8-8EE6-348E878E5DF5", "D"), Guid("B06E9839-DA28-42E6-86C4-42D1F8E3AADB", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x2_0xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("609CC1AC-4B36-4197-B1C1-2357E57CEBAF", "D"), Guid("34C9BF53-1E0C-42D3-9EC1-696421E8A420", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x20xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("401211FA-7E01-4019-BA4A-247406AD4776", "D"), Guid("9C462DC8-87D6-41B0-A4EF-9111E8D960B0", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x20xENVG_COOP = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("C28310FD-2731-44A3-9B56-A048B3227EA6", "D"), Guid("242DAE61-CC3D-428A-8AC5-324FA95EBE7B", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x1xENVG = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("72AFA964-EFE0-4203-83E2-88052DD7ECBA", "D"), Guid("B6B46C0F-92B8-4F9F-9429-595261801A14", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x12_0xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("D8CE5A90-5A74-4726-9D3C-B879996246E1", "D"), Guid("E754B4D6-BAD4-4FEE-9E00-8F9C4904975E", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x10xENVG = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("F412EBAD-2551-4832-93A0-B9E1A412FB5D", "D"), Guid("E068484D-EE7F-4199-992A-59772D8B7D4B", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.x10_0xZoom = instance
	end)
	ResourceManager:RegisterInstanceLoadHandler(Guid("FDAAAC18-0AC9-4E17-A723-4EC293FB0813", "D"), Guid("B2D0DC9F-B2A0-4B50-8BA5-A56B7AF1E44B", "D"), function(instance)
		instance = ZoomLevelData(instance)
		instance:MakeWritable()
		self.defaultBase = instance -- use ClientUtils:SetFieldOfView() when available
	end)
end
-- Endregion

-- Region Scoreboard
function BetterIngameAdmin:OnUIInputConceptEvent(hook, eventType, action)
	if action == UIInputAction.UIInputAction_Tab then
		local player = PlayerManager:GetLocalPlayer()
		if player ~= nil then
			if self.blockTab == false then
				if eventType == UIInputActionEventType.UIInputActionEventType_Pressed then
					if self.active == false then
						self.active = true
						self:UpdateUI(player)
					elseif self.active == true then
						self.active = false
						self.dontUpdate = false
						player:EnableInput(11, true)
						WebUI:ExecuteJS(string.format("clearScoreboardBody()"))
					end
				elseif self.toggleScoreboard == false then
					if self.ignoreReleaseTab == false then
						self.active = false
						self.dontUpdate = false
						player:EnableInput(11, true)
						WebUI:ExecuteJS(string.format("clearScoreboardBody()"))
					else
						self.ignoreReleaseTab = false
					end
				end
			end
			hook:Pass(UIInputAction.UIInputAction_None, eventType)
		end
	end
end

function BetterIngameAdmin:OnEngineUpdate(deltaTime, simulationDeltaTime)
	if self.voteInProgress == true then
		if InputManager:WentKeyDown(InputDeviceKeys.IDK_F8) then
			NetEvents:Send('CheckVoteYes')
			WebUI:ExecuteJS(string.format("fontWeightYes()"))
		elseif InputManager:WentKeyDown(InputDeviceKeys.IDK_F9) then
			NetEvents:Send('CheckVoteNo')
			WebUI:ExecuteJS(string.format("fontWeightNo()"))
		end
		self.cumulatedTime = self.cumulatedTime + deltaTime
		if self.cumulatedTime >= self.count and self.count <= self.secondsToVote + 1 then
			self.count = self.count + 1
			if self.count >= self.secondsToVote + 1 then
				self.voteInProgress = false
				self.cumulatedTime = 0
				self.count = 1
			end
			WebUI:ExecuteJS(string.format("updateTimer()"))
		end
	end
	if self.active == true then
		if self.updateScoreboardInterval < self.cumulatedTimeForScoreboard and self.dontUpdate == false then
			local player = PlayerManager:GetLocalPlayer()
			if player ~= nil then
				self:UpdateUI(player)
			end
			self.cumulatedTimeForScoreboard = 0
		else
			self.cumulatedTimeForScoreboard = self.cumulatedTimeForScoreboard + deltaTime
		end
		if InputManager:WentMouseButtonDown(InputDeviceMouseButtons.IDB_Button_1) then
			if self.toggleScoreboard == false then
				self.ignoreReleaseTab = true
			end
			self.dontUpdate = true
			WebUI:ExecuteJS(string.format("showTabsAndEnableMouse()"))
			local localPlayer = PlayerManager:GetLocalPlayer()
			if localPlayer ~= nil then
				localPlayer:EnableInput(11, false)
			end
		end
	end
end

function BetterIngameAdmin:UpdateUI(player)
	local gameMode = SharedUtils:GetCurrentGameMode()
	local size = 16
	if gameMode:match("Conquest") or gameMode:match("Superiority") or gameMode == "Domination0" or gameMode == "Scavenger0" then
		local clientTicketCounterIterator = EntityManager:GetIterator('ClientTicketCounterEntity')
		local ticketCounterEntity = clientTicketCounterIterator:Next()
		while ticketCounterEntity ~= nil do
			if TicketCounterEntity(ticketCounterEntity).team == TeamId.Team1 then
				self.usTickets = TicketCounterEntity(ticketCounterEntity).ticketCount
			else
				self.ruTickets = TicketCounterEntity(ticketCounterEntity).ticketCount
			end
			ticketCounterEntity = clientTicketCounterIterator:Next()
		end
	elseif gameMode:match("Rush") then
		local lifeCounterEntityIterator = EntityManager:GetIterator('ClientLifeCounterEntity')
		local lifeCounterEntity = lifeCounterEntityIterator:Next()
		while lifeCounterEntity ~= nil do
			if LifeCounterEntityData(lifeCounterEntity.data).teamId == TeamId.Team1 then
				self.usTickets = LifeCounterEntity(lifeCounterEntity).lifeCounter
			elseif LifeCounterEntityData(lifeCounterEntity.data).teamId == TeamId.Team2 then
				self.ruTickets = LifeCounterEntity(lifeCounterEntity).lifeCounter
			end
			lifeCounterEntity = lifeCounterEntityIterator:Next()
		end
	elseif gameMode:match("TeamDeathMatch") then
		local killCounterEntityIterator = EntityManager:GetIterator('ClientKillCounterEntity')
		local killCounterEntity = killCounterEntityIterator:Next()
		while killCounterEntity ~= nil do
			if KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team1 then
				self.usTickets = KillCounterEntity(killCounterEntity).killCount
			elseif KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team2 then
				self.ruTickets = KillCounterEntity(killCounterEntity).killCount
			end
			killCounterEntity = killCounterEntityIterator:Next()
		end
	elseif gameMode == "SquadDeathMatch0" then
		local killCounterEntityIterator = EntityManager:GetIterator('ClientKillCounterEntity')
		local killCounterEntity = killCounterEntityIterator:Next()
		while killCounterEntity ~= nil do
			if KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team1 then
				alphaTickets = KillCounterEntity(killCounterEntity).killCount
			elseif KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team2 then
				bravoTickets = KillCounterEntity(killCounterEntity).killCount
			elseif KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team3 then
				charlieTickets = KillCounterEntity(killCounterEntity).killCount
			elseif KillCounterEntityData(killCounterEntity.data).teamId == TeamId.Team4 then
				deltaTickets = KillCounterEntity(killCounterEntity).killCount
			end
			killCounterEntity = killCounterEntityIterator:Next()
		end
	elseif gameMode == "CaptureTheFlag0" or gameMode == "GunMaster0" then
		self.usTickets = " "
		self.ruTickets = " "
	end
	if gameMode ~= "SquadDeathMatch0" then
		size = 16
		if player.teamId == TeamId.Team1 then
			team1 = "US"
			team2 = "RU"
			tickets1 = tostring(self.usTickets)
			tickets2 = tostring(self.ruTickets)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
		else
			team1 = "RU"
			team2 = "US"
			tickets1 = tostring(self.ruTickets)
			tickets2 = tostring(self.usTickets)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
		end
	else
		size = 8
		if player.teamId == TeamId.Team1 then
			team1 = "Alpha"
			team2 = "Bravo"
			team3 = "Charlie"
			team4 = "Delta"
			tickets1 = tostring(alphaTickets)
			tickets2 = tostring(bravoTickets)
			tickets3 = tostring(charlieTickets)
			tickets4 = tostring(deltaTickets)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			playerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		elseif player.teamId == TeamId.Team2 then
			team2 = "Alpha"
			team1 = "Bravo"
			team3 = "Charlie"
			team4 = "Delta"
			tickets2 = tostring(alphaTickets)
			tickets1 = tostring(bravoTickets)
			tickets3 = tostring(charlieTickets)
			tickets4 = tostring(deltaTickets)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			playerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		elseif player.teamId == TeamId.Team3 then
			team2 = "Alpha"
			team3 = "Bravo"
			team1 = "Charlie"
			team4 = "Delta"
			tickets2 = tostring(alphaTickets)
			tickets3 = tostring(bravoTickets)
			tickets1 = tostring(charlieTickets)
			tickets4 = tostring(deltaTickets)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			playerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		elseif player.teamId == TeamId.Team4 then
			team2 = "Alpha"
			team3 = "Bravo"
			team4 = "Charlie"
			team1 = "Delta"
			tickets2 = tostring(alphaTickets)
			tickets3 = tostring(bravoTickets)
			tickets4 = tostring(charlieTickets)
			tickets1 = tostring(deltaTickets)
			playerListTeam2 = PlayerManager:GetPlayersByTeam(TeamId.Team1)
			playerListTeam3 = PlayerManager:GetPlayersByTeam(TeamId.Team2)
			playerListTeam4 = PlayerManager:GetPlayersByTeam(TeamId.Team3)
			playerListTeam1 = PlayerManager:GetPlayersByTeam(TeamId.Team4)
		end
	end
	local scoreboardHeader = {team1, tickets1, team2, tickets2, player.name, player.squadId, player.isSquadLeader, player.isSquadPrivate}
	WebUI:ExecuteJS(string.format("updateScoreboardHeader(%s)", json.encode(scoreboardHeader)))
	
	if gameMode == "SquadDeathMatch0" then
		local scoreboardHeader2 = {team3, tickets3, team4, tickets4}
		WebUI:ExecuteJS(string.format("updateScoreboardHeader2(%s)", json.encode(scoreboardHeader2)))
	end
	
	table.sort(playerListTeam1, function(a, b) 
		return a.score > b.score
	end)
	
	table.sort(playerListTeam2, function(a, b) 
		return a.score > b.score
	end)
	
	local playerListTeams = {playerListTeam1, playerListTeam2}
	
	for index,player in pairs(playerListTeam1) do
		self.playerTeam1Count = index
		local kit = "ID_M_DEAD"
		if player.customization ~= nil then
			kit = CharacterCustomizationAsset(player.customization).labelSid 
		end
		local ping = "–"
		if self.pingTable[player.name] ~= nil and self.pingTable[player.name] >= 0 and self.pingTable[player.name] < 999 then
			ping = self.pingTable[player.name]
		end
		local sendThis1 = {index, player.name, player.kills, player.deaths, player.score, player.squadId, player.alive, kit, ping, player.isSquadPrivate}
		WebUI:ExecuteJS(string.format("updateScoreboardBody1(%s)", json.encode(sendThis1)))
	end
	
	for index,player in pairs(playerListTeam2) do
		self.playerTeam2Count = index
		local ping = "–"
		if self.pingTable[player.name] ~= nil and self.pingTable[player.name] >= 0 and self.pingTable[player.name] < 999 then
			ping = self.pingTable[player.name]
		end
		local sendThis2 = {index, player.name, player.kills, player.deaths, player.score, player.alive, ping}
		WebUI:ExecuteJS(string.format("updateScoreboardBody2(%s)", json.encode(sendThis2)))
	end
	
	WebUI:ExecuteJS(string.format("updateScoreboardBody3(%s)", json.encode(size)))
	
	if gameMode == "SquadDeathMatch0" then
		table.sort(playerListTeam3, function(a, b) 
			return a.score > b.score
		end)
		
		table.sort(playerListTeam4, function(a, b) 
			return a.score > b.score
		end)
		local playerListTeams2 = {playerListTeam3, playerListTeam4}
	
		for index,player in pairs(playerListTeam3) do
			self.playerTeam3Count = index
			local ping = "–"
			if self.pingTable[player.name] ~= nil and self.pingTable[player.name] >= 0 and self.pingTable[player.name] < 999 then
				ping = self.pingTable[player.name]
			end
			local sendThis3 = {index, player.name, player.kills, player.deaths, player.score, player.alive, ping}
			WebUI:ExecuteJS(string.format("updateScoreboardBody4(%s)", json.encode(sendThis3)))
		end
		
		for index,player in pairs(playerListTeam4) do
			self.playerTeam4Count = index
			local ping = "–"
			if self.pingTable[player.name] ~= nil and self.pingTable[player.name] >= 0 and self.pingTable[player.name] < 999 then
				ping = self.pingTable[player.name]
			end
			local sendThis4 = {index, player.name, player.kills, player.deaths, player.score, player.alive, ping}
			WebUI:ExecuteJS(string.format("updateScoreboardBody5(%s)", json.encode(sendThis4)))
		end
		
		WebUI:ExecuteJS(string.format("updateScoreboardBody6()"))
	end
end

function BetterIngameAdmin:OnWebUIToggleScoreboard()
	if self.toggleScoreboard == true then
		self.toggleScoreboard = false
	else
		self.toggleScoreboard = true
	end
end

function BetterIngameAdmin:OnWebUIHoldScoreboard()
	self.toggleScoreboard = false
end

function BetterIngameAdmin:OnWebUIClickScoreboard()
	self.toggleScoreboard = true
end

function BetterIngameAdmin:OnWebUIIgnoreReleaseTab()
	if self.toggleScoreboard == false then
		self.ignoreReleaseTab = true
	end
end

function BetterIngameAdmin:OnWebUIActiveFalse()
	if self.active == true then
		local player = PlayerManager:GetLocalPlayer()
		if player ~= nil then
			player:EnableInput(11, true)
		end
		self.active = false
	end
end

function BetterIngameAdmin:OnSoldierHealthAction(soldier, action)
	if action == HealthStateAction.OnRevive then
		local localPlayer = PlayerManager:GetLocalPlayer()
		if soldier.player.name == localPlayer.name then
			self.active = false
			self.dontUpdate = false
			localPlayer:EnableInput(11, true)
			WebUI:ExecuteJS(string.format("clearScoreboardBody()"))
		end
	end
end

function BetterIngameAdmin:OnUIPushScreen(hook, screen, graphPriority, parentGraph)
    local screen = UIGraphAsset(screen)
	if screen.name == 'UI/Flow/Screen/Scoreboards/ScoreboardTwoTeamsScreen' then
		local screenClone = UIScreenAsset(ResourceManager:SearchForDataContainer("UI/Flow/Screen/ScoreboardBackScreen"))
		screenClone:MakeWritable()
		local uiPageHeaderBinding = UIPageHeaderBinding(WidgetNode(screenClone.nodes[4]).dataBinding)
		uiPageHeaderBinding:MakeWritable()
		uiPageHeaderBinding.staticHeader  = ""
		uiPageHeaderBinding.staticSubHeader = ""
		
		local player = PlayerManager:GetLocalPlayer()
		self.active = true
		self:UpdateUI(player)
		self.dontUpdate = true
		WebUI:ExecuteJS(string.format("showTabsAndEnableMouse()"))
		hook:Pass(screenClone, graphPriority, parentGraph)
	end
	if screen.name == 'UI/Flow/Screen/IngameMenuMP' 
	or screen.name == 'UI/Flow/Screen/SquadScreen' 
	or screen.name == 'UI/Flow/Screen/OptionsControlsScreen'
	or screen.name == 'UI/Flow/Screen/OptionsGameplayScreen'
	or screen.name == 'UI/Flow/Screen/OptionsAudioScreen'
	or screen.name == 'UI/Flow/Screen/OptionsVideoScreen'
	or screen.name == 'UI/Flow/Screen/OptionsKeyBindingScreen'
	or screen.name:match('UI/Flow/Screen/Popups/') then
		self.blockTab = true
		WebUI:ExecuteJS(string.format("closeSmart()"))
	else
		self.blockTab = false
	end
end
function BetterIngameAdmin:OnPlayerPing(pingTable)
	self.pingTable = pingTable
	if self.showPing == true then
		local localPlayer = PlayerManager:GetLocalPlayer()
		if localPlayer ~= nil and self.pingTable[localPlayer.name] ~= nil then
			WebUI:ExecuteJS(string.format("updateLocalPlayerPing(%s)", json.encode(self.pingTable[localPlayer.name])))
		end
	end
end
-- Endregion

-- Region Get Admin Rights
function BetterIngameAdmin:OnServerOwnerRights()
	WebUI:ExecuteJS(string.format("setOwnerRights()"))
end

function BetterIngameAdmin:OnAdminPlayer(args)
	WebUI:ExecuteJS(string.format("getAdminRights(%s)", json.encode(args)))
end
-- Endregion

-- Region ServerInfo
function BetterIngameAdmin:OnServerInfo(args)
	self.serverInfo = args
	WebUI:ExecuteJS(string.format("getServerInfo(%s)", json.encode(args)))
end

function BetterIngameAdmin:OnGetPlayerCount()
	local count = PlayerManager:GetPlayerCount()
	WebUI:ExecuteJS(string.format("getPlayerCount(%s)", json.encode(count)))
end
-- Endregion

-- Region ServerBanner Loading Screen
function BetterIngameAdmin:OnLevelLoadingInfo(screenInfo)
	if screenInfo == "Initializing entities for autoloaded sublevels" then
		WebUI:ExecuteJS(string.format("hideLoadingScreen()"))
	end
end

function BetterIngameAdmin:OnInfo(args)
	WebUI:ExecuteJS(string.format("info(%s)", json.encode(args)))
end

function BetterIngameAdmin:OnLevelDestroy()
	WebUI:ExecuteJS(string.format("closeSmart()"))
	WebUI:ExecuteJS(string.format("showLoadingScreen()"))
end
-- Endregion

-- Region ServerOwner Quick Server Setup
function BetterIngameAdmin:OnQuickServerSetup()
	WebUI:ExecuteJS(string.format("quickServerSetup()"))
end
-- Endregion

-- Region things to delete from old unfinshed admin panel
function BetterIngameAdmin:OnWebUIGetGeneralSettings()
	NetEvents:Send('GetGeneralSettings')
end

function BetterIngameAdmin:OnGeneralSettings(args)
	WebUI:ExecuteJS(string.format("getGeneralSettings(%s)", json.encode(args)))
end
function BetterIngameAdmin:OnApplyGeneralSettings(args)
	NetEvents:Send('ApplyGeneralSettings', json.decode(args))
end

function BetterIngameAdmin:OnWebUIGetMapSettings()
	NetEvents:Send('GetMapSettings')
end

function BetterIngameAdmin:OnMapSettings(args)
	WebUI:ExecuteJS(string.format("getMapSettings(%s)", json.encode(args)))
end

function BetterIngameAdmin:OnApplyMapSettings(args)
	NetEvents:Send('ApplyMapSettings', json.decode(args))
end
-- Endregion

g_BetterIngameAdmin = BetterIngameAdmin()
