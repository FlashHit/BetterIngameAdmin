/* Region IsAdmin */
admin = false;
canMove = false;
canKill = false;
canKick = false;
canTban = false;
canBan = false;
canEditAdminRights = false;
canEditBanList = false;
canEditMapList = false;
canUseMapFunctions = false;
canAlterServerSettings = false;
canEditReservedSlotsList = false;
canEditTextChatModerationList = false;
canShutdownServer = false;
/* Endregion */

/* Region Mute */
playersMuted = [];
channelsMuted = [];
adminChannel = false;
allChannel = false;
teamChannel = false;
squadChannel = false;
/* Endregion */

/* Region Scoreboard Place */
place1 = 0;
place2 = 0;
place3 = 0;
place4 = 0;
/* Endregion */

/* Region SquadCount */
const squadCount = [];
maxSquadSize = 4;
/* Endregion */

/* Region Local Player */
localPlayer = "";
localPlayerSquad = 9999;
localPlayerIsSquadLeader = false;
localPlayerIsSquadPrivate = false;
localPing = 123
/* Endregion */

/* Region Client Settings */
toggleScoreboard = false;
showHideVotings = true;
isVoteInProgress = false;
showPing = false;
/* Endregion */

/* Region Admin actions for player */
teamIdToSwitch = "1";
teamNameToSwitch = "Team US";
squadIdToSwitch = "0";
squadNameToSwitch = "No Squad";
playerCanMove = false;
playerCanKill = false;
playerCanKick = false;
playerCanTban = false;
playerCanBan = false;
playerCanEditAdminRights = false;
playerCanEditBanList = false;
playerCanEditMapList = false;
playerCanUseMapFunctions = false;
playerCanAlterServerSettings = false;
playerCanEditReservedSlotsList = false;
playerCanEditTextChatModerationList = false;
playerCanShutdownServer = false;
/* Endregion */

/* Region presets */
varsPresetNormal = true;
varsPresetInfantry = true;
varsPresetHardcore = true;
varsPresetHardcoreNoMap = true;
/* Endregion */

/* Region PopUp (gets triggered on click on playerName on scoreboard */
function action(playerName ,squadId, isSquadPrivate)
{
	WebUI.Call('DispatchEvent', 'WebUI:IgnoreReleaseTab');
	document.getElementById("popup").style.display = "inline";
	if(playerName == localPlayer) {
		document.getElementById("popup").innerHTML = '<div id="titlepopup">Actions for yourself<div id="close" onclick="closepopup()"></div></div></div>';
		document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="surrender()">Surrender</div>';
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="assist()">Assist</div>';
		if(localPlayerIsSquadLeader == true) {
			document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="localSquad()">Squad</div>';
		}else if(localPlayerSquad != 0) {
			document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="leaveSquad()">Leave Squad</div>';
		}else{
			document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="createSquad()">Create Squad</div>';
		}
	}else{
		document.getElementById("popup").innerHTML += '<div id="titlepopup">Actions for the player: '+playerName+'<div id="close" onclick="closepopup()"></div></div></div>';
		document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="votekick(&apos;'+playerName+'&apos;)">Votekick</div>';
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="voteban(&apos;'+playerName+'&apos;)">Voteban</div>';
		if(playersMuted.includes(playerName)) {
			document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="unmute(&apos;'+playerName+'&apos;)">Unmute</div>';
		}else{		
			document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="mute(&apos;'+playerName+'&apos;)">Mute</div>';
		}
		if(squadId == localPlayerSquad && localPlayerIsSquadLeader == true) {
			document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="squad(&apos;'+playerName+'&apos;)">Squad</div>';
		}else if(squadId != localPlayerSquad && squadId != 0 && squadCount[squadId] < maxSquadSize && isSquadPrivate == false) {
			document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="joinSquad(&apos;'+playerName+'&apos;)">Join Squad</div>';
		}
		if(admin == true){
			document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="adminpopup(&apos;'+playerName+'&apos;)">Admin</div>';		
		}
	}
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}
/* Region AdminPopup (gets triggered in popup button "Admin")*/
function adminpopup(playerName) {
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Actions for the player: '+playerName+'<div id="close" onclick="closepopup()"></div></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
		if(canMove == true){
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="move(&apos;'+playerName+'&apos;)">Move</div>';
	}
	if(canKill == true){
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="kill(&apos;'+playerName+'&apos;)">Kill</div>';
	}	
	if(canKick == true){
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="kick(&apos;'+playerName+'&apos;)">Kick</div>';
	}
	if(canTban == true){
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="tban(&apos;'+playerName+'&apos;)">TBan</div>';
	}
	if(canBan == true){
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="ban(&apos;'+playerName+'&apos;)">Ban</div>';
	}
	if(canEditAdminRights == true) {
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="getAdminRightsOfPlayer(&apos;'+playerName+'&apos;)">Edit rights</div>';
	}
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}
/* Endregion */

/* Region Closepopup */
function closepopup() {
	document.getElementById("popup").style.display = "none";
	document.getElementById("popup").innerHTML = '';
}
/* Endregion */


/* Region vote stuff */
function votekick(playerName) {
	showHideVotings = true;
	WebUI.Call('DispatchEvent', 'WebUI:VotekickPlayer', playerName);
	closepopup();
	document.getElementById("voteyes").style.fontWeight = "900";
}
function voteban(playerName) {
	showHideVotings = true;
	WebUI.Call('DispatchEvent', 'WebUI:VotebanPlayer', playerName);
	closepopup();
	document.getElementById("voteyes").style.fontWeight = "900";
}
function startvotekick(playerName) 
{
	isVoteInProgress = true
	secondsLeft = 30;
	yesvotes = 1;
	novotes = 0;
	if(showHideVotings == true){ 
		document.getElementById("votepopup").style.display = "inline";
	}
	document.getElementById("votetitleleft").innerHTML = '<p>Votekick: '+playerName+'</p>';
	i = 1;
	width = document.getElementById("orangeRect").clientWidth;
	while(document.getElementById("votetitleleft").clientWidth >= width * 0.7) {
		length = playerName.length - i;
		document.getElementById("votetitleleft").innerHTML = '<p>Votekick: '+playerName.slice(0, length)+'...</p>';
		i = i + 1;
	}
	document.getElementById("votetitleleft").style.width = "80%";
	document.getElementById("votetitleright").innerHTML = '<p>'+secondsLeft+' sec</p>';
	document.getElementById("countyesvotes").innerHTML = ''+yesvotes+' Y';
	document.getElementById("countnovotes").innerHTML = ''+novotes+' N';
}
function startvoteban(playerName) 
{
	isVoteInProgress = true
	secondsLeft = 30;
	yesvotes = 1;
	novotes = 0;
	if(showHideVotings == true){ 
		document.getElementById("votepopup").style.display = "inline";
	}
	document.getElementById("votetitleleft").innerHTML = '<p>Voteban: '+playerName+'</p>';
	i = 1;
	while(document.getElementById("votetitleleft").clientWidth >= 200) {
		length = playerName.length - i;
		document.getElementById("votetitleleft").innerHTML = '<p>Voteban: '+playerName.slice(0, length)+'...</p>';
		i = i + 1;
	}
	document.getElementById("votetitleleft").style.width = "80%";
	document.getElementById("votetitleright").innerHTML = '<p>'+secondsLeft+' sec</p>';
	document.getElementById("countyesvotes").innerHTML = ''+yesvotes+' Y';
	document.getElementById("countnovotes").innerHTML = ''+novotes+' N';
}
function startsurrender() 
{
	isVoteInProgress = true
	secondsLeft = 30;
	yesvotes = 1;
	novotes = 0;
	if(showHideVotings == true){ 
		document.getElementById("votepopup").style.display = "inline";
	}
	document.getElementById("votetitleleft").style.width = "80%";
	document.getElementById("votetitleleft").innerHTML = '<p>Surrender</p>';
	document.getElementById("votetitleright").innerHTML = '<p>'+secondsLeft+' sec</p>';
	document.getElementById("countyesvotes").innerHTML = ''+yesvotes+' Y';
	document.getElementById("countnovotes").innerHTML = ''+novotes+' N';
}
function voteYes()
{
	yesvotes += 1;
	document.getElementById("countyesvotes").innerHTML = ''+yesvotes+' Y';
}
function voteNo()
{
	novotes += 1;
	document.getElementById("countnovotes").innerHTML = ''+novotes+' N';
}

function removeOneYesVote()
{
	yesvotes -= 1;
	document.getElementById("countyesvotes").innerHTML = ''+yesvotes+' Y';
}

function removeOneNoVote()
{
	novotes -= 1;
	document.getElementById("countnovotes").innerHTML = ''+novotes+' N';
}
function updateTimer()
{
	secondsLeft = secondsLeft - 1;
	document.getElementById("votetitleright").innerHTML = '<p>'+secondsLeft+' sec</p>';
	if(secondsLeft == 0) {
		isVoteInProgress = false
		document.getElementById("votepopup").style.display = "none";
		document.getElementById("voteyes").style.fontWeight = null;
		document.getElementById("voteno").style.fontWeight = null;
		document.getElementById("votetitleleft").style.width = null;
	}
}
function fontWeightYes() {
	document.getElementById("voteyes").style.fontWeight = "900";
	document.getElementById("voteno").style.fontWeight = null;
}
function fontWeightNo() {
	document.getElementById("voteno").style.fontWeight = "900";
	document.getElementById("voteyes").style.fontWeight = null;
}
function voteInProgress()
{
	//pop up that says: You can't start a vote because a vote is already in progress.
}
/* Endregion */

/* Region Player Mute */
function mute(playerName) {
	playersMuted.push(playerName); 
	WebUI.Call('DispatchEvent', 'WebUI:MutePlayer', playerName);
	closepopup();
}
function unmute(playerName) {
	if (playersMuted.indexOf(playerName) > -1) {
		playersMuted.splice(playersMuted.indexOf(playerName), 1);
	}
	WebUI.Call('DispatchEvent', 'WebUI:UnmutePlayer', playerName);
	closepopup();
}
/* Endregion */

/* Region Local Player Squad Actions */
function localSquad() {
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Actions for your squad<div id="close" onclick="closepopup()"></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
	document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="leaveSquad()">Leave Squad</div>';
	if(localPlayerIsSquadPrivate == true){
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="privateSquad()">Open Squad</div>';
		localPlayerIsSquadPrivate = false;
	}else{
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="privateSquad()">Close Squad</div>';
		localPlayerIsSquadPrivate = true;
	}
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}
function leaveSquad() {
	WebUI.Call('DispatchEvent', 'WebUI:LeaveSquad');
	closepopup();
}
function privateSquad() {
	WebUI.Call('DispatchEvent', 'WebUI:PrivateSquad');
	closepopup();
}
function createSquad() {
	WebUI.Call('DispatchEvent', 'WebUI:CreateSquad');
	closepopup();
}
/* Endregion */

/* Region Squad Action for other players */
function squad(playerName) {
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Squadactions for the player: '+playerName+'<div id="close" onclick="closepopup()"></div></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
	document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="kickSquad(&apos;'+playerName+'&apos;)">Kick from Squad</div>';
	document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="makeSquadLeader(&apos;'+playerName+'&apos;)">Promote to SQ Leader</div>';
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}
function joinSquad(playerName) {
	WebUI.Call('DispatchEvent', 'WebUI:JoinSquad', playerName);
	closepopup();
}
function kickSquad(playerName) {
	WebUI.Call('DispatchEvent', 'WebUI:KickFromSquad', playerName);
	closepopup();
}
function makeSquadLeader(playerName) {
	WebUI.Call('DispatchEvent', 'WebUI:MakeSquadLeader', playerName);
	closepopup();
}
/* Endregion */

/* Region OLD Delete this 
function clientSettings() {
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Settings<div id="close" onclick="closepopup()"></div></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
	if(canEditAdminRights == true) {
		document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="adminPanel()">Admin Panel</div>';
	}
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}
function adminPanel() {
	closepopup();
	clearScoreboardBody();
	WebUI.Call('DispatchEvent', 'WebUI:ActiveFalse');
	WebUI.Call('EnableMouse');
	WebUI.Call('EnableKeyboard');
	document.getElementById("adminpanelpopup").style.display = "inline";
	document.getElementById("adminpanelpopup").innerHTML = '<div id="adminpanelheader"><div id="generalSettings" onclick="generalSettingsBody()"><span>General Settings</span></div><div id="mapSettings" onclick="mapSettingsBody()"><span>Map Settings</span></div><div id="close" onclick="closeAdminPanelPopup()"></div></div><div id="adminpanelbody"></div>';
	
	document.getElementById("generalSettings").style.fontWeight = "900";
	
	document.getElementById("adminpanelbody").innerHTML = '<div id="generalsettingsElement"><label>Server Name</label><input id="serverName" type="textbox" placeholder="Enter a server name..." value="voteban_flash is testing">	</div>	<div id="generalsettingsElement"><label>Server Description</label><input id="serverDescription" type="textbox" placeholder="Enter a server description..." value="Welcome to the server">	</div>	<div id="generalsettingsElement"><label>Server Message</label><input id="serverMessage" type="textbox" placeholder="Enter a server Message..." value="Welcome to the server">	</div>	<div id="generalsettingsElement"><label>Game Password</label><input id="gamePassword" type="textbox" placeholder="Enter a password..." value="Admin123">	</div>	<div id="generalsettingsElement"><input id="autobalance" name="autobalance" type="checkbox"><label for="autobalance">Autobalance</label>	</div>	<div id="generalsettingsElement"><input id="friendlyFire" name="friendlyFire" type="checkbox"><label for="friendlyFire">Friendly Fire</label>	</div>	<div id="generalsettingsElement"><input id="killCam" name="killCam" type="checkbox"><label for="killCam">Kill Cam</label>	</div>	<div id="generalsettingsElement"><input id="miniMap" name="miniMap" type="checkbox"><label for="miniMap">Minimap</label>	</div>	<div id="generalsettingsElement"><input id="hud" name="hud" type="checkbox"><label for="hud">HUD</label>	</div>	<div id="generalsettingsElement"><input id="3dSpotting" name="3dSpotting" type="checkbox"><label for="3dSpotting">3D Spotting</label>	</div>	<div id="generalsettingsElement"><input id="minimapSpotting" name="minimapSpotting" type="checkbox"><label for="minimapSpotting">Minimap Spotting</label>	</div>	<div id="generalsettingsElement"><input id="nameTag" name="nameTag" type="checkbox"><label for="nameTag">Nametag</label>	</div>	<div id="generalsettingsElement"><input id="3rdPersonCam" name="3rdPersonCam" type="checkbox"><label for="3rdPersonCam">3rd Person Cam</label>	</div>	<div id="generalsettingsElement"><input id="regenerateHealth" name="regenerateHealth" type="checkbox"><label for="regenerateHealth">Regenerate Health</label>	</div>	<div id="generalsettingsElement"><input id="vehicleSpawn" name="vehicleSpawn" type="checkbox"><label for="vehicleSpawn">Vehicle Spawn</label>	</div>	<div id="generalsettingsElement"><input id="onlySquadLeaderSpawn" name="onlySquadLeaderSpawn" type="checkbox"><label for="onlySquadLeaderSpawn">Only Squad Leader Spawn</label>	</div>	<div id="generalsettingsElement"><input id="destruction" name="destruction" type="checkbox"><label for="destruction">Destruction</label>	</div>	<div id="generalsettingsElement"><input id="allowDeserting" name="allowDeserting" type="checkbox"><label for="allowDeserting">Allow Deserting</label>	</div>	<div id="generalsettingsElement"><input id="vehicleDisabling" name="vehicleDisabling" type="checkbox"><label for="vehicleDisabling">Vehicle Disabling</label>	</div>	<div id="generalsettingsElement"><input id="highPerfRepl" name="highPerfRepl" type="checkbox"><label for="highPerfRepl">high Perf. Repl.</label>	</div>	<div id="generalsettingsElement"><input id="sunFlare" name="sunFlare" type="checkbox"><label for="sunFlare">Sun Flare</label>	</div>	<div id="generalsettingsElement"><input id="colorCorrection" name="colorCorrection" type="checkbox"><label for="colorCorrection">Color Correction</label>	</div>	<p id="lineBreak"></p>	<div id="generalsettingsElement"><label>Max. Players</label><input id="maxPlayers" type="number" placeholder="8" value="8">	</div>	<div id="generalsettingsElement"><label>Team kill count for kick</label><input id="teamKillCountForKick" type="number" placeholder="5" value="5">	</div>	<div id="generalsettingsElement"><label>Team kill value for kick</label><input id="teamKillValueForKick" type="number" placeholder="4" value="4">	</div>	<div id="generalsettingsElement"><label>Team kill value increase</label><input id="teamKillValueIncrease" type="number" placeholder="1" value="1">	</div>	<div id="generalsettingsElement"><label>Team kill value decrease/s</label><input id="teamKillValueDecrease" type="number" placeholder="0" value="0">	</div>	<div id="generalsettingsElement"><label>Team kill kicks for ban</label><input id="teamKillKicksForBan" type="number" placeholder="0" value="0">	</div>';
	document.getElementById("adminpanelbody").innerHTML += '<div id="generalsettingsElement"><label>Idle Timeout (seconds)</label><input id="idleTimeout" type="number" placeholder="0" value="0"></div><div id="generalsettingsElement"><label>Idle Ban Rounds</label><input id="idleBanRounds" type="number" placeholder="0" value="0"></div><div id="generalsettingsElement"><label>Round Start Player Count</label><input id="roundStartPlayerCount" type="number" placeholder="8" value="8"></div><div id="generalsettingsElement"><label>Round Restart Player Count</label><input id="roundRestartPlayerCount" type="number" placeholder="4" value="4"></div><div id="generalsettingsElement"><label>Round Lockdown Countdown</label><input id="roundLockdownCountdown" type="number" placeholder="15" value="15"></div><div id="generalsettingsElement"><label>Vehicle Spawn Delay (%)</label><input id="vehicleSpawnDelay" type="number" placeholder="100" value="100">		</div>		<div id="generalsettingsElement"><label>Soldier Health (%)</label><input id="soldierHealth" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Player Respawn Time (%)</label><input id="playerRespawnTime" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Player Man Down Time (%)</label><input id="playerManDownTime" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Bullet Damage (%)</label><input id="bulletDamage" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Tickets (%)</label><input id="tickets" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Gunmaster Weapons Preset</label><input id="gunmasterWeaponsPreset" type="number" placeholder="0" value="0"></div><div id="generalsettingsElement"><label>Suppression Multiplier (%)</label><input id="suppressionMultiplier" type="number" placeholder="100" value="100">		</div>		<div id="generalsettingsElement"><label>Time Scale</label><input id="timeScale" type="number" placeholder="1.0" value="1.0">		</div>		<div id="generalsettingsElement"><label>Squad Size</label><input id="squadSize" type="number" placeholder="4" value="4"></div><div id="generalsettingsElement"><label>Server Banner URL</label><input id="serverBannerURL" type="textbox" placeholder="Enter the URL to your server banner..." value=""></div>';
	document.getElementById("adminpanelbody").innerHTML += '<p id="lineBreak"></p><div id="generalsettingsElement"><div id="popupelement" onclick="applyGeneralSettings()">Apply</div></div>';
	document.getElementById("adminpanelbody").innerHTML += '<div id="generalsettingsElement"><div id="popupelement" onclick="closeAdminPanelPopup()">Cancel</div></div>';
	
	WebUI.Call('DispatchEvent', 'WebUI:GetGeneralSettings');
}
function closeAdminPanelPopup() {
	WebUI.Call('ResetMouse');
	WebUI.Call('ResetKeyboard');
	document.getElementById("adminpanelpopup").style.display = null;
}
function generalSettingsBody() {
	document.getElementById("generalSettings").style.fontWeight = "900";
	document.getElementById("mapSettings").style.fontWeight = null;
	document.getElementById("adminpanelbody").innerHTML = '<div id="generalsettingsElement"><label>Server Name</label><input id="serverName" type="textbox" placeholder="Enter a server name..." value="voteban_flash is testing">	</div>	<div id="generalsettingsElement"><label>Server Description</label><input id="serverDescription" type="textbox" placeholder="Enter a server description..." value="Welcome to the server">	</div>	<div id="generalsettingsElement"><label>Server Message</label><input id="serverMessage" type="textbox" placeholder="Enter a server Message..." value="Welcome to the server">	</div>	<div id="generalsettingsElement"><label>Game Password</label><input id="gamePassword" type="textbox" placeholder="Enter a password..." value="Admin123">	</div>	<div id="generalsettingsElement"><input id="autobalance" name="autobalance" type="checkbox"><label for="autobalance">Autobalance</label>	</div>	<div id="generalsettingsElement"><input id="friendlyFire" name="friendlyFire" type="checkbox"><label for="friendlyFire">Friendly Fire</label>	</div>	<div id="generalsettingsElement"><input id="killCam" name="killCam" type="checkbox"><label for="killCam">Kill Cam</label>	</div>	<div id="generalsettingsElement"><input id="miniMap" name="miniMap" type="checkbox"><label for="miniMap">Minimap</label>	</div>	<div id="generalsettingsElement"><input id="hud" name="hud" type="checkbox"><label for="hud">HUD</label>	</div>	<div id="generalsettingsElement"><input id="3dSpotting" name="3dSpotting" type="checkbox"><label for="3dSpotting">3D Spotting</label>	</div>	<div id="generalsettingsElement"><input id="minimapSpotting" name="minimapSpotting" type="checkbox"><label for="minimapSpotting">Minimap Spotting</label>	</div>	<div id="generalsettingsElement"><input id="nameTag" name="nameTag" type="checkbox"><label for="nameTag">Nametag</label>	</div>	<div id="generalsettingsElement"><input id="3rdPersonCam" name="3rdPersonCam" type="checkbox"><label for="3rdPersonCam">3rd Person Cam</label>	</div>	<div id="generalsettingsElement"><input id="regenerateHealth" name="regenerateHealth" type="checkbox"><label for="regenerateHealth">Regenerate Health</label>	</div>	<div id="generalsettingsElement"><input id="vehicleSpawn" name="vehicleSpawn" type="checkbox"><label for="vehicleSpawn">Vehicle Spawn</label>	</div>	<div id="generalsettingsElement"><input id="onlySquadLeaderSpawn" name="onlySquadLeaderSpawn" type="checkbox"><label for="onlySquadLeaderSpawn">Only Squad Leader Spawn</label>	</div>	<div id="generalsettingsElement"><input id="destruction" name="destruction" type="checkbox"><label for="destruction">Destruction</label>	</div>	<div id="generalsettingsElement"><input id="allowDeserting" name="allowDeserting" type="checkbox"><label for="allowDeserting">Allow Deserting</label>	</div>	<div id="generalsettingsElement"><input id="vehicleDisabling" name="vehicleDisabling" type="checkbox"><label for="vehicleDisabling">Vehicle Disabling</label>	</div>	<div id="generalsettingsElement"><input id="highPerfRepl" name="highPerfRepl" type="checkbox"><label for="highPerfRepl">high Perf. Repl.</label>	</div>	<div id="generalsettingsElement"><input id="sunFlare" name="sunFlare" type="checkbox"><label for="sunFlare">Sun Flare</label>	</div>	<div id="generalsettingsElement"><input id="colorCorrection" name="colorCorrection" type="checkbox"><label for="colorCorrection">Color Correction</label>	</div>	<p id="lineBreak"></p>	<div id="generalsettingsElement"><label>Max. Players</label><input id="maxPlayers" type="number" placeholder="8" value="8">	</div>	<div id="generalsettingsElement"><label>Team kill count for kick</label><input id="teamKillCountForKick" type="number" placeholder="5" value="5">	</div>	<div id="generalsettingsElement"><label>Team kill value for kick</label><input id="teamKillValueForKick" type="number" placeholder="4" value="4">	</div>	<div id="generalsettingsElement"><label>Team kill value increase</label><input id="teamKillValueIncrease" type="number" placeholder="1" value="1">	</div>	<div id="generalsettingsElement"><label>Team kill value decrease/s</label><input id="teamKillValueDecrease" type="number" placeholder="0" value="0">	</div>	<div id="generalsettingsElement"><label>Team kill kicks for ban</label><input id="teamKillKicksForBan" type="number" placeholder="0" value="0">	</div>';
	document.getElementById("adminpanelbody").innerHTML += '<div id="generalsettingsElement"><label>Idle Timeout (seconds)</label><input id="idleTimeout" type="number" placeholder="0" value="0"></div><div id="generalsettingsElement"><label>Idle Ban Rounds</label><input id="idleBanRounds" type="number" placeholder="0" value="0"></div><div id="generalsettingsElement"><label>Round Start Player Count</label><input id="roundStartPlayerCount" type="number" placeholder="8" value="8"></div><div id="generalsettingsElement"><label>Round Restart Player Count</label><input id="roundRestartPlayerCount" type="number" placeholder="4" value="4"></div><div id="generalsettingsElement"><label>Round Lockdown Countdown</label><input id="roundLockdownCountdown" type="number" placeholder="15" value="15"></div><div id="generalsettingsElement"><label>Vehicle Spawn Delay (%)</label><input id="vehicleSpawnDelay" type="number" placeholder="100" value="100">		</div>		<div id="generalsettingsElement"><label>Soldier Health (%)</label><input id="soldierHealth" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Player Respawn Time (%)</label><input id="playerRespawnTime" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Player Man Down Time (%)</label><input id="playerManDownTime" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Bullet Damage (%)</label><input id="bulletDamage" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Tickets (%)</label><input id="tickets" type="number" placeholder="100" value="100"></div><div id="generalsettingsElement"><label>Gunmaster Weapons Preset</label><input id="gunmasterWeaponsPreset" type="number" placeholder="0" value="0"></div><div id="generalsettingsElement"><label>Suppression Multiplier (%)</label><input id="suppressionMultiplier" type="number" placeholder="100" value="100">		</div>		<div id="generalsettingsElement"><label>Time Scale</label><input id="timeScale" type="number" placeholder="1.0" value="1.0">		</div>		<div id="generalsettingsElement"><label>Squad Size</label><input id="squadSize" type="number" placeholder="4" value="4"></div><div id="generalsettingsElement"><label>Server Banner URL</label><input id="serverBannerURL" type="textbox" placeholder="Enter the URL to your server banner..." value=""></div>';
	document.getElementById("adminpanelbody").innerHTML += '<p id="lineBreak"></p><div id="generalsettingsElement"><div id="popupelement" onclick="applyGeneralSettings()">Apply</div></div>';
	document.getElementById("adminpanelbody").innerHTML += '<div id="generalsettingsElement"><div id="popupelement" onclick="closeAdminPanelPopup()">Cancel</div></div>';
	
	WebUI.Call('DispatchEvent', 'WebUI:GetGeneralSettings');
}
function mapSettingsBody() {
	document.getElementById("generalSettings").style.fontWeight = null;
	document.getElementById("mapSettings").style.fontWeight = "900";
	document.getElementById("adminpanelbody").innerHTML = '<div id="mapsettingsElement"><label>Maps:</label></div>';
	document.getElementById("adminpanelbody").innerHTML = '<div id="mapListField"></div>';
	
	WebUI.Call('DispatchEvent', 'WebUI:GetMapSettings');
}
function getGeneralSettings(args) {
	document.getElementById("serverName").value = args[0];
	document.getElementById("serverDescription").value = args[1];
	document.getElementById("serverMessage").value = args[2];
	document.getElementById("gamePassword").value = args[3];
	if(args[4] == "true"){
		document.getElementById("autobalance").checked = true;
	}else if(args[4] == "false"){
		document.getElementById("autobalance").checked = false;
	}
	if(args[5] == "true"){
		document.getElementById("friendlyFire").checked = true;
	}else if(args[5] == "false"){
		document.getElementById("friendlyFire").checked = false;
	}
	if(args[6] == "true"){
		document.getElementById("killCam").checked = true;
	}else if(args[6] == "false"){
		document.getElementById("killCam").checked = false;
	}
	if(args[7] == "true"){
		document.getElementById("miniMap").checked = true;
	}else if(args[7] == "false"){
		document.getElementById("miniMap").checked = false;
	}
	if(args[8] == "true"){
		document.getElementById("hud").checked = true;
	}else if(args[8] == "false"){
		document.getElementById("hud").checked = false;
	}
	if(args[9] == "true"){
		document.getElementById("3dSpotting").checked = true;
	}else if(args[9] == "false"){
		document.getElementById("3dSpotting").checked = false;
	}
	if(args[10] == "true"){
		document.getElementById("minimapSpotting").checked = true;
	}else if(args[10] == "false"){
		document.getElementById("minimapSpotting").checked = false;
	}
	if(args[11] == "true"){
		document.getElementById("nameTag").checked = true;
	}else if(args[11] == "false"){
		document.getElementById("nameTag").checked = false;
	}
	if(args[12] == "true"){
		document.getElementById("3rdPersonCam").checked = true;
	}else if(args[12] == "false"){
		document.getElementById("3rdPersonCam").checked = false;
	}
	if(args[13] == "true"){
		document.getElementById("regenerateHealth").checked = true;
	}else if(args[13] == "false"){
		document.getElementById("regenerateHealth").checked = false;
	}
	if(args[14] == "true"){
		document.getElementById("vehicleSpawn").checked = true;
	}else if(args[14] == "false"){
		document.getElementById("vehicleSpawn").checked = false;
	}
	if(args[15] == "true"){
		document.getElementById("onlySquadLeaderSpawn").checked = true;
	}else if(args[15] == "false"){
		document.getElementById("onlySquadLeaderSpawn").checked = false;
	}
	if(args[16] == "true"){
		document.getElementById("destruction").checked = true;
	}else if(args[16] == "false"){
		document.getElementById("destruction").checked = false;
	}
	if(args[17] == "true"){
		document.getElementById("allowDeserting").checked = true;
	}else if(args[17] == "false"){
		document.getElementById("allowDeserting").checked = false;
	}
	if(args[18] == "true"){
		document.getElementById("vehicleDisabling").checked = true;
	}else if(args[18] == "false"){
		document.getElementById("vehicleDisabling").checked = false;
	}
	if(args[19] == "true"){
		document.getElementById("highPerfRepl").checked = true;
	}else if(args[19] == "false"){
		document.getElementById("highPerfRepl").checked = false;
	}
	if(args[20] == "true"){
		document.getElementById("sunFlare").checked = true;
	}else if(args[20] == "false"){
		document.getElementById("sunFlare").checked = false;
	}
	if(args[21] == "true"){
		document.getElementById("colorCorrection").checked = true;
	}else if(args[21] == "false"){
		document.getElementById("colorCorrection").checked = false;
	}
	document.getElementById("maxPlayers").value = args[22];
	document.getElementById("teamKillCountForKick").value = args[23];
	document.getElementById("teamKillValueForKick").value = args[24];
	document.getElementById("teamKillValueIncrease").value = args[25];
	document.getElementById("teamKillValueDecrease").value = args[26];
	document.getElementById("teamKillKicksForBan").value = args[27];
	document.getElementById("idleTimeout").value = args[28];
	document.getElementById("idleBanRounds").value = args[29];
	document.getElementById("roundStartPlayerCount").value = args[30];
	document.getElementById("roundRestartPlayerCount").value = args[31];
	document.getElementById("roundLockdownCountdown").value = args[32];
	document.getElementById("vehicleSpawnDelay").value = args[33];
	document.getElementById("soldierHealth").value = args[34];
	document.getElementById("playerRespawnTime").value = args[35];
	document.getElementById("playerManDownTime").value = args[36];
	document.getElementById("bulletDamage").value = args[37];
	document.getElementById("tickets").value = args[38];
	document.getElementById("gunmasterWeaponsPreset").value = args[39];
	document.getElementById("suppressionMultiplier").value = args[40];
	document.getElementById("timeScale").value = args[41];
	document.getElementById("squadSize").value = args[42];
	maxSquadSize = args[42];
	document.getElementById("serverBannerURL").value = args[43];
}
function getMapSettings(args) {
	let o = 1;
	let n = 1;
	document.getElementById("mapListConfiguration").innerHTML = '';
	for(let i=2; i < (parseInt(args[0][0])*3)+2; i++){
		if(o == 1){
			document.getElementById("mapListField").innerHTML += '<div class="mapListFieldElement" id="mapListFieldElement'+i+'"></div>';
			document.getElementById("mapListFieldElement"+i).innerHTML += '<div class="mapListFieldElementMap" id="mapListFieldElement'+i+'map">'+args[0][i]+'</div>';
		}else if(o == 2){
			n = i - 1;
			document.getElementById("mapListFieldElement"+n).innerHTML += '<div class="mapListFieldElementGameMode" id="mapListFieldElement'+n+'gameMode">'+args[0][i]+'</div>';
		}else if(o == 3){
			n = i - 2;
			document.getElementById("mapListFieldElement"+n).innerHTML += '<div class="mapListFieldElementRounds" id="mapListFieldElement'+n+'rounds">'+args[0][i]+'</div>';
			o = 0;
		}
		o++;
	}
}

function applyGeneralSettings(){
	const args = [];
	args.push(document.getElementById("serverName").value);
	args.push(document.getElementById("serverDescription").value);
	args.push(document.getElementById("serverMessage").value);
	args.push(document.getElementById("gamePassword").value);
	args.push(document.getElementById("autobalance").checked);
	args.push(document.getElementById("friendlyFire").checked);
	args.push(document.getElementById("killCam").checked);
	args.push(document.getElementById("miniMap").checked);
	args.push(document.getElementById("hud").checked);
	args.push(document.getElementById("3dSpotting").checked);
	args.push(document.getElementById("minimapSpotting").checked);
	args.push(document.getElementById("nameTag").checked);
	args.push(document.getElementById("3rdPersonCam").checked);
	args.push(document.getElementById("regenerateHealth").checked);
	args.push(document.getElementById("vehicleSpawn").checked);
	args.push(document.getElementById("onlySquadLeaderSpawn").checked);
	args.push(document.getElementById("destruction").checked);
	args.push(document.getElementById("allowDeserting").checked);
	args.push(document.getElementById("vehicleDisabling").checked);
	args.push(document.getElementById("highPerfRepl").checked);
	args.push(document.getElementById("sunFlare").checked);
	args.push(document.getElementById("colorCorrection").checked);
	args.push(document.getElementById("maxPlayers").value);
	args.push(document.getElementById("teamKillCountForKick").value);
	args.push(document.getElementById("teamKillValueForKick").value);
	args.push(document.getElementById("teamKillValueIncrease").value);
	args.push(document.getElementById("teamKillValueDecrease").value);
	args.push(document.getElementById("teamKillKicksForBan").value);
	args.push(document.getElementById("idleTimeout").value);
	args.push(document.getElementById("idleBanRounds").value);
	args.push(document.getElementById("roundStartPlayerCount").value);
	args.push(document.getElementById("roundRestartPlayerCount").value);
	args.push(document.getElementById("roundLockdownCountdown").value);
	args.push(document.getElementById("vehicleSpawnDelay").value);
	args.push(document.getElementById("soldierHealth").value);
	args.push(document.getElementById("playerRespawnTime").value);
	args.push(document.getElementById("playerManDownTime").value);
	args.push(document.getElementById("bulletDamage").value);
	args.push(document.getElementById("tickets").value);
	args.push(document.getElementById("gunmasterWeaponsPreset").value);
	args.push(document.getElementById("suppressionMultiplier").value);
	args.push(document.getElementById("timeScale").value);
	args.push(document.getElementById("squadSize").value);
	args.push(document.getElementById("serverBannerURL").value);
	WebUI.Call('DispatchEvent', 'WebUI:ApplyGeneralSettings', JSON.stringify(args));
	closeAdminPanelPopup();
}*/
/* Endregion */

/* Region ServerInfo */
function getServerInfo(args) {
	varsPresetNormal = true;
	varsPresetInfantry = true;
	varsPresetHardcore = true;
	varsPresetHardcoreNoMap = true;
	
	document.getElementById("serverNameDescrContainerHeader").innerHTML = '<p>'+args[0]+'</p>';
	document.getElementById("serverNameDescrContainerBody").innerHTML = '<p>'+args[1]+'</p>';
	//document.getElementById("serverMessage").innerHTML = args[2];
	//document.getElementById("gamePassword").innerHTML = args[3];
	if(args[4] == "true"){
		document.getElementById("autobalance").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetAutobalance").innerHTML = 'Yes';
	}else if(args[4] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("autobalance").innerHTML = '<p>No</p>';
		document.getElementById("customPresetAutobalance").innerHTML = 'No';
	}
	if(args[5] == "true"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		document.getElementById("friendlyFire").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetFriendlyFire").innerHTML = 'Yes';
	}else if(args[5] == "false"){
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("friendlyFire").innerHTML = '<p>No</p>';
		document.getElementById("customPresetFriendlyFire").innerHTML = 'No';
	}
	if(args[6] == "true"){
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("killCam").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetKillCam").innerHTML = 'Yes';
	}else if(args[6] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		document.getElementById("killCam").innerHTML = '<p>No</p>';
		document.getElementById("customPresetKillCam").innerHTML = 'No';
	}
	if(args[7] == "true"){
		varsPresetHardcoreNoMap = false;
		document.getElementById("miniMap").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetMiniMap").innerHTML = 'Yes';
	}else if(args[7] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		document.getElementById("miniMap").innerHTML = '<p>No</p>';
		document.getElementById("customPresetMiniMap").innerHTML = 'No';
	}
	if(args[8] == "true"){
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("hud").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetHUD").innerHTML = 'Yes';
	}else if(args[8] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		document.getElementById("hud").innerHTML = '<p>No</p>';
		document.getElementById("customPresetHUD").innerHTML = 'No';
	}
	if(args[9] == "true"){
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("3dSpotting").innerHTML = '<p>Yes</p>';
		document.getElementById("customPreset3dSpotting").innerHTML = 'Yes';
	}else if(args[9] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		document.getElementById("3dSpotting").innerHTML = '<p>No</p>';
		document.getElementById("customPreset3dSpotting").innerHTML = 'No';
	}
	if(args[10] == "true"){
		document.getElementById("minimapSpotting").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetMinimapSpotting").innerHTML = 'Yes';
	}else if(args[10] == "false"){
		varsPresetHardcoreNoMap = false;
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		document.getElementById("minimapSpotting").innerHTML = '<p>No</p>';
		document.getElementById("customPresetMinimapSpotting").innerHTML = 'No>';
	}
	if(args[11] == "true"){
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("nameTag").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetNameTag").innerHTML = 'Yes';
	}else if(args[11] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		document.getElementById("nameTag").innerHTML = '<p>No</p>';
		document.getElementById("customPresetNameTag").innerHTML = 'No';
	}
	if(args[12] == "true"){
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("3rdPersonCam").innerHTML = '<p>Yes</p>';
		document.getElementById("customPreset3rdPersonCam").innerHTML = 'Yes';
	}else if(args[12] == "false"){
		varsPresetNormal = false;
		document.getElementById("3rdPersonCam").innerHTML = '<p>No</p>';
		document.getElementById("customPreset3rdPersonCam").innerHTML = 'No';
	}
	if(args[13] == "true"){
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("regenerateHealth").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetRegenerateHealth").innerHTML = 'Yes';
	}else if(args[13] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		document.getElementById("regenerateHealth").innerHTML = '<p>No</p>';
		document.getElementById("customPresetRegenerateHealth").innerHTML = 'No';
	}
	if(args[14] == "true"){
		varsPresetInfantry = false;
		document.getElementById("vehicleSpawn").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetVehicleSpawn").innerHTML = 'Yes';
	}else if(args[14] == "false"){
		varsPresetNormal = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("vehicleSpawn").innerHTML = '<p>No</p>';
		document.getElementById("customPresetVehicleSpawn").innerHTML = 'No';
	}
	if(args[15] == "true"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		document.getElementById("onlySquadLeaderSpawn").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetOnlySquadLeaderSpawn").innerHTML = 'Yes';
	}else if(args[15] == "false"){
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("onlySquadLeaderSpawn").innerHTML = '<p>No</p>';
		document.getElementById("customPresetOnlySquadLeaderSpawn").innerHTML = 'No';
	}
	/*
	if(args[19] == "true"){
		document.getElementById("highPerfRepl").innerHTML = '<p>Yes</p>';
	}else if(args[19] == "false"){
		document.getElementById("highPerfRepl").innerHTML = '<p>No</p>';
	}*/
	document.getElementById("maxPlayers").innerHTML = args[22];
	document.getElementById("maximumPlayers").innerHTML = '<p>'+args[22]+'</p>';
	if(args[23] != 5 || args[27] != 3 || args[35] != 100 || args[36] != 100 || args[37] != 100 || args[28] != 300 || args[48] != 100 || args[40] != 100 || args[41] != 1 ){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
	}
	if(args[34] != 60){
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
	}else if(args[34] != 100){
		varsPresetNormal = false;
		varsPresetInfantry = false;
	}
	document.getElementById("teamKillCountForKick").innerHTML = '<p>'+args[23]+'</p>';
	document.getElementById("customPresetTeamKillCountForKick").innerHTML = args[23];
	//document.getElementById("teamKillValueForKick").innerHTML = '<p>'+args[24]+'</p>';
	//document.getElementById("teamKillValueIncrease").innerHTML = '<p>'+args[25]+'</p>';
	//document.getElementById("teamKillValueDecrease").innerHTML = '<p>'+args[26]+'</p>';
	document.getElementById("teamKillKicksForBan").innerHTML = '<p>'+args[27]+'</p>';
	document.getElementById("customPresetTeamKillKicksForBan").innerHTML = args[27];
	document.getElementById("idleTimeout").innerHTML = '<p>'+args[28]+'</p>';
	document.getElementById("customPresetIdleTimeout").innerHTML = args[28];
	//document.getElementById("idleBanRounds").innerHTML = '<p>'+args[29]+'</p>';
	document.getElementById("roundStartPlayerCount").innerHTML = '<p>'+args[30]+'</p>';
	//document.getElementById("roundRestartPlayerCount").innerHTML = '<p>'+args[31]+'</p>';
	//document.getElementById("roundLockdownCountdown").innerHTML = '<p>'+args[32]+'</p>';
	//document.getElementById("vehicleSpawnDelay").innerHTML = '<p>'+args[33]+'</p>';
	document.getElementById("soldierHealth").innerHTML = '<p>'+args[34]+'</p>';
	document.getElementById("customPresetPlayerHealth").innerHTML = args[34];
	document.getElementById("playerRespawnTime").innerHTML = '<p>'+args[35]+'</p>';
	document.getElementById("customPresetPlayerRespawnTime").innerHTML = args[35];
	document.getElementById("playerManDownTime").innerHTML = '<p>'+args[36]+'</p>';
	document.getElementById("customPresetPlayerManDownTime").innerHTML = args[36];
	document.getElementById("bulletDamage").innerHTML = '<p>'+args[37]+'</p>';
	document.getElementById("customPresetBulletDamage").innerHTML = args[37];
	document.getElementById("tickets").innerHTML = '<p>'+args[38]+'</p>';
	if(args[39] == "0"){
		document.getElementById("gunmasterWeaponsPreset").innerHTML = '<p>Normal</p>';
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = 'Normal';
	}else if(args[39] != "0"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
	}
	if(args[39] == "1"){
		document.getElementById("gunmasterWeaponsPreset").innerHTML = '<p>Normal Reversed</p>';
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = 'Normal Reversed';
	}else if(args[39] == "2"){
		document.getElementById("gunmasterWeaponsPreset").innerHTML = '<p>Light Weight</p>';
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = 'Light Weight';
	}else if(args[39] == "3"){
		document.getElementById("gunmasterWeaponsPreset").innerHTML = '<p>Heavy Gear</p>';
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = 'Heavy Gear';
	}else if(args[39] == "4"){
		document.getElementById("gunmasterWeaponsPreset").innerHTML = '<p>Pistols Only</p>';
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = 'Pistols Only';
	}else if(args[39] == "5"){
		document.getElementById("gunmasterWeaponsPreset").innerHTML = '<p>Snipers Heaven</p>';
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = 'Snipers Heaven';
	}else if(args[39] == "6"){
		document.getElementById("gunmasterWeaponsPreset").innerHTML = '<p>US Arms Race</p>';
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = 'US Arms Race';
	}else if(args[39] == "7"){
		document.getElementById("gunmasterWeaponsPreset").innerHTML = '<p>RU Arms Race</p>';
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = '<p>RU Arms Race';
	}else if(args[39] == "8"){
		document.getElementById("gunmasterWeaponsPreset").innerHTML = '<p>EU Arms Race</p>';
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = 'EU Arms Race';
	} 
	//document.getElementById("serverBannerURL").innerHTML = '<p>'+args[43]+'</p>';
	let currentMapIndex = args[45][0]
	let nextMapIndex = args[45][1]
	document.getElementById("mapListConfiguration").innerHTML = '';
	let o = 1;
	let n = 1;
	let map = "UNDEFINED"
	let mapUrl = "UNDEFINED"
	for(let i=2; i < (parseInt(args[44][0])*3)+2; i++){
		if(o == 1){
			map = generateMapName(args[44][i])
			let k = (i + 1) / 3
			document.getElementById("mapListConfiguration").innerHTML += '<div class="mapListFieldElement" id="mapListFieldElement'+k+'"></div>';
			document.getElementById("mapListFieldElement"+k).innerHTML += '<div class="mapListFieldElementMap" id="mapListFieldElement'+k+'map">'+map+'</div>';
			
		}else if(o == 2){
			n = i - 1;
			let k = (n + 1) / 3
			let mode = generateModeName(args[44][i])
			document.getElementById("mapListFieldElement"+k).innerHTML += '<div class="mapListFieldElementGameMode" id="mapListFieldElement'+k+'gameMode">'+mode+'</div>';
			if(k - 1 == currentMapIndex && k - 1 == nextMapIndex){
				let map = generateMapName(args[44][n])
				document.getElementById('serverInfoMapBody').innerHTML = map;
				let mapUrl = generateMapUrl(args[44][n])
				document.getElementById('serverInfoMapImg').style.backgroundImage = 'url(fb://'+mapUrl+')';
				document.getElementById('serverInfoMapRotationBody').innerHTML = '<p id="checkModeName"><span class="textMove">'+mode+'</span></p>';
				document.getElementById('serverInfoModeBody').innerHTML = mode;
				let modeImgUrl = generateModeUrl(args[44][i])
				document.getElementById('serverInfoModeImg').style.backgroundImage = 'url(fb://'+modeImgUrl+')';
				document.getElementById('mapListFieldElement'+k+'gameMode').innerHTML = '<span style="vertical-align: top;">'+mode+'</span><img id="currentMap" src=""/><img style="margin-left: 0;" id="nextMap" src=""/>';
			}else if(k - 1 == currentMapIndex){
				let map = generateMapName(args[44][n])
				document.getElementById('serverInfoMapBody').innerHTML = map;
				let mapUrl = generateMapUrl(args[44][n])
				document.getElementById('serverInfoMapImg').style.backgroundImage = 'url(fb://'+mapUrl+')';
				document.getElementById('serverInfoMapRotationBody').innerHTML = '<p id="checkModeName"><span class="textMove">'+mode+'</span></p>';
				document.getElementById('serverInfoModeBody').innerHTML = mode;
				let modeImgUrl = generateModeUrl(args[44][i])
				document.getElementById('serverInfoModeImg').style.backgroundImage = 'url(fb://'+modeImgUrl+')';
				document.getElementById('mapListFieldElement'+k+'gameMode').innerHTML = '<span style="vertical-align: top;">'+mode+'</span><img id="currentMap" src=""/>';
			}else if(k - 1 == nextMapIndex){
				document.getElementById('mapListFieldElement'+k+'gameMode').innerHTML = '<span style="vertical-align: top;">'+mode+'</span><img id="nextMap" src=""/>';
			}
		}else if(o == 3){
			n = i - 2;
			let k = (n + 1) / 3
			//document.getElementById("mapListFieldElement"+k).innerHTML += '<div class="mapListFieldElementRounds" id="mapListFieldElement'+k+'rounds">'+args[44][i]+'</div>';
			o = 0;
		}
		o++;
	}
	document.getElementById("rounds").innerHTML = '<p>'+args[46][1]+'</p>';
	document.getElementById("region").innerHTML = args[47];
	document.getElementById("ctfRoundTimeModifier").innerHTML = '<p>'+args[48]+'</p>';
	document.getElementById("customPresetCtfRoundTimeModifier").innerHTML = args[48];
	if(args[21] == "true"){
		document.getElementById("colorCorrectionEnabled").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetBluetint").innerHTML = 'Yes';
	}else if(args[21] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("colorCorrectionEnabled").innerHTML = '<p>No</p>';
		document.getElementById("customPresetBluetint").innerHTML = 'No';
	}
	if(args[20] == "true"){
		document.getElementById("sunFlare").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetSunFlare").innerHTML = 'Yes';
	}else if(args[20] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("sunFlare").innerHTML = '<p>No</p>';
		document.getElementById("customPresetSunFlare").innerHTML = 'No';
	}
	document.getElementById("suppressionMultiplier").innerHTML = '<p>'+args[40]+'</p>';
	document.getElementById("customPresetSuppressionMultiplier").innerHTML = args[40];
	let timeScaling = args[41] * 100;
	document.getElementById("timeScale").innerHTML = '<p>'+timeScaling+'</p>';
	document.getElementById("customPresetTimeScale").innerHTML = timeScaling;
	if(args[17] == "true"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("desertingAllowed").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetAllowDeserting").innerHTML = 'Yes';
	}else if(args[17] == "false"){
		document.getElementById("desertingAllowed").innerHTML = '<p>No</p>';
		document.getElementById("customPresetAllowDeserting").innerHTML = 'No';
	}
	if(args[16] == "true"){
		document.getElementById("destructionEnabled").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetDestructionEnabled").innerHTML = 'Yes';
	}else if(args[16] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("destructionEnabled").innerHTML = '<p>No</p>';
		document.getElementById("customPresetDestructionEnabled").innerHTML = 'No';
	}
	if(args[18] == "true"){
		document.getElementById("vehicleDisablingEnabled").innerHTML = '<p>Yes</p>';
		document.getElementById("customPresetVehicleDisabling").innerHTML = 'Yes';
	}else if(args[18] == "false"){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
		document.getElementById("vehicleDisablingEnabled").innerHTML = '<p>No</p>';
		document.getElementById("customPresetVehicleDisabling").innerHTML = 'No';
	}
	if(args[49] == "regular"){
		document.getElementById("frequencyMode").innerHTML = '<p>30 Hz</p>';
	}else if(args[49] == "high60"){
		document.getElementById("frequencyMode").innerHTML = '<p>60 Hz</p>';
	}else if(args[49] == "high120"){
		document.getElementById("frequencyMode").innerHTML = '<p>120 Hz</p>';
	}
	document.getElementById("squadSize").innerHTML = '<p>'+args[42]+'</p>';
	document.getElementById("customPresetSquadSize").innerHTML = args[42];
	if(args[42] != 4){
		varsPresetNormal = false;
		varsPresetInfantry = false;
		varsPresetHardcore = false;
		varsPresetHardcoreNoMap = false;
	}
	document.getElementById("modListConfiguration").innerHTML = '';
	for(let i=0; i < args[50].length; i++){
		document.getElementById("modListConfiguration").innerHTML += '<div id="serverInfoConfigurationElement"><p>'+args[50][i]+'</p></div>';
		let k = i+1
		document.getElementById("serverInfoPlayersTopBody").innerHTML = 'Active: '+k;
	}
	if(varsPresetNormal == true){
		document.getElementById("serverInfoPresetConfigurationBody").innerHTML = 'Normal';
		document.getElementById("serverInfoPresetBody").innerHTML = 'Normal';
		document.getElementById("serverSetupCurrentPreset").innerHTML = 'Normal';
		document.getElementById("currentPresetInManagePresets").innerHTML = 'Normal';
		document.getElementById("presetNormal").style.display = 'block';
		document.getElementById("presetHardcore").style.display = 'none';
		document.getElementById("presetInfantry").style.display = 'none';
		document.getElementById("presetHardcoreNoMap").style.display = 'none';
		document.getElementById("presetCustom").style.display = 'none';
		
	}else if(varsPresetInfantry == true){
		document.getElementById("serverInfoPresetConfigurationBody").innerHTML = 'Infantry';
		document.getElementById("serverInfoPresetBody").innerHTML = 'Infantry';
		document.getElementById("serverSetupCurrentPreset").innerHTML = 'Infantry';
		document.getElementById("currentPresetInManagePresets").innerHTML = 'Infantry';
		document.getElementById("presetNormal").style.display = 'none';
		document.getElementById("presetHardcore").style.display = 'none';
		document.getElementById("presetInfantry").style.display = 'block';
		document.getElementById("presetHardcoreNoMap").style.display = 'none';
		document.getElementById("presetCustom").style.display = 'none';
	}else if(varsPresetHardcore == true){
		document.getElementById("serverInfoPresetConfigurationBody").innerHTML = 'Hardcore';
		document.getElementById("serverInfoPresetBody").innerHTML = 'Hardcore';
		document.getElementById("serverSetupCurrentPreset").innerHTML = 'Hardcore';
		document.getElementById("currentPresetInManagePresets").innerHTML = 'Hardcore';
		document.getElementById("presetNormal").style.display = 'none';
		document.getElementById("presetHardcore").style.display = 'block';
		document.getElementById("presetInfantry").style.display = 'none';
		document.getElementById("presetHardcoreNoMap").style.display = 'none';
		document.getElementById("presetCustom").style.display = 'none';
	}else if(varsPresetHardcoreNoMap == true){
		document.getElementById("serverInfoPresetConfigurationBody").innerHTML = 'Hardcore No Map';
		document.getElementById("serverInfoPresetBody").innerHTML = 'Hardcore No Map';
		document.getElementById("serverSetupCurrentPreset").innerHTML = 'Hardcore No Map';
		document.getElementById("currentPresetInManagePresets").innerHTML = 'Hardcore No Map';
		document.getElementById("presetNormal").style.display = 'none';
		document.getElementById("presetHardcore").style.display = 'none';
		document.getElementById("presetInfantry").style.display = 'none';
		document.getElementById("presetHardcoreNoMap").style.display = 'block';
		document.getElementById("presetCustom").style.display = 'none';
	}else{
		document.getElementById("serverInfoPresetConfigurationBody").innerHTML = 'Custom';
		document.getElementById("serverInfoPresetBody").innerHTML = 'Custom';
		document.getElementById("serverSetupCurrentPreset").innerHTML = 'Custom';
		document.getElementById("currentPresetInManagePresets").innerHTML = 'Custom';
		document.getElementById("presetNormal").style.display = 'none';
		document.getElementById("presetHardcore").style.display = 'none';
		document.getElementById("presetInfantry").style.display = 'none';
		document.getElementById("presetHardcoreNoMap").style.display = 'none';
		document.getElementById("presetCustom").style.display = 'block';
	}
	document.getElementById("serverInfoOwnerBody").innerHTML = args[51];
}
function generateModeUrl(mode){
	if(mode == "ConquestLarge0" || mode == "ConquestSmall0" || mode == "ConquestAssaultLarge0" || mode == "ConquestAssaultSmall0" || mode == "ConquestAssaultSmall1"){
		return "UI/Art/GameMode/gm_cq"
	}else if(mode == "RushLarge0"){
		return "UI/Art/GameMode/gm_Rush"
	}else if(mode == "SquadRush0"){
		return "UI/Art/GameMode/gm_sqRush"
	}else if(mode == "SquadDeathMatch0"){
		return "UI/Art/GameMode/gm_sdm"
	}else if(mode == "TeamDeathMatch0"){
		return "UI/Art/GameMode/gm_tdm"
	}else if(mode == "TeamDeathMatchC0"){
		return "UI/Art/GameMode/gm_tdmcq"
	}else if(mode == "Domination0"){
		return "UI/Art/GameMode/gm_dom"
	}else if(mode == "GunMaster0"){
		return "UI/Art/GameMode/gm_gm"
	}else if(mode == "TankSuperiority0"){
		return "UI/Art/GameMode/gm_ts"
	}else if(mode == "Scavenger0"){
		return "UI/Art/GameMode/gm_scv"
	}else if(mode == "CaptureTheFlag0"){
		return "UI/Art/GameMode/gm_ctf"
	}else if(mode == "AirSuperiority0"){
		return "UI/Art/GameMode/gm_as"
	}
}
function generateMapUrl(map){
	if(map == "MP_001"){
		return "UI/Art/Menu/LevelThumbs/MP01_thumb"
	}else if(map == "MP_003"){
		return "UI/Art/Menu/LevelThumbs/MP03_thumb"
	}else if(map == "MP_007"){
		return "UI/Art/Menu/LevelThumbs/MP07_thumb"
	}else if(map == "MP_011"){
		return "UI/Art/Menu/LevelThumbs/MP11_thumb"
	}else if(map == "MP_012"){
		return "UI/Art/Menu/LevelThumbs/MP12_thumb"
	}else if(map == "MP_013"){
		return "UI/Art/Menu/LevelThumbs/MP13_thumb"
	}else if(map == "MP_017"){
		return "UI/Art/Menu/LevelThumbs/MP17_thumb"
	}else if(map == "MP_018"){
		return "UI/Art/Menu/LevelThumbs/MP18_thumb"
	}else if(map == "MP_Subway"){
		return "UI/Art/Menu/LevelThumbs/MP15_thumb"
	}else if(map == "XP1_001"){
		return "UI/Art/Menu/LevelThumbs/XP01_thumb"
	}else if(map == "XP1_002"){
		return "UI/Art/Menu/LevelThumbs/XP02_thumb"
	}else if(map == "XP1_003"){
		return "UI/Art/Menu/LevelThumbs/XP03_thumb"
	}else if(map == "XP1_004"){
		return "UI/Art/Menu/LevelThumbs/XP04_thumb"
	}else if(map == "XP2_Factory"){
		return "UI/Art/Menu/LevelThumbs/Xp2_Factory_thumb"
	}else if(map == "XP2_Office"){
		return "UI/Art/Menu/LevelThumbs/Xp2_Office_thumb"
	}else if(map == "XP2_Palace"){
		return "UI/Art/Menu/LevelThumbs/Xp2_Palace_thumb"
	}else if(map == "XP2_Skybar"){
		return "UI/Art/Menu/LevelThumbs/Xp2_Skybar_thumb"
	}else if(map == "XP3_Desert"){
		return "UI/Art/Menu/LevelThumbs/Xp3_Desert_thumb"
	}else if(map == "XP3_Alborz"){
		return "UI/Art/Menu/LevelThumbs/Xp3_Alborz_thumb"
	}else if(map == "XP3_Shield"){
		return "UI/Art/Menu/LevelThumbs/Xp3_Shield_thumb"
	}else if(map == "XP3_Valley"){
		return "UI/Art/Menu/LevelThumbs/Xp3_Valley_thumb"
	}else if(map == "XP4_Quake"){
		return "UI/Art/Menu/LevelThumbs/XP4_Quake_thumb"
	}else if(map == "XP4_FD"){
		return "UI/Art/Menu/LevelThumbs/XP4_FD_thumb"
	}else if(map == "XP4_Parl"){
		return "UI/Art/Menu/LevelThumbs/XP4_Parl_thumb"
	}else if(map == "XP4_Rubble"){
		return "UI/Art/Menu/LevelThumbs/XP4_Rubble_thumb"
	}else if(map == "XP5_001"){
		return "UI/Art/Menu/LevelThumbs/Xp5_001_thumb"
	}else if(map == "XP5_002"){
		return "UI/Art/Menu/LevelThumbs/Xp5_002_thumb"
	}else if(map == "XP5_003"){
		return "UI/Art/Menu/LevelThumbs/Xp5_003_thumb"
	}else if(map == "XP5_004"){
		return "UI/Art/Menu/LevelThumbs/Xp5_004_thumb"
	}
}

function generateMapName(map){
	if(map == "MP_001"){
		return "Grand Bazaar"
	}else if(map == "MP_003"){
		return "Teheran Highway"
	}else if(map == "MP_007"){
		return "Caspian Border"
	}else if(map == "MP_011"){
		return "Seine Crossing"
	}else if(map == "MP_012"){
		return "Operation Firestorm"
	}else if(map == "MP_013"){
		return "Damavand Peak"
	}else if(map == "MP_017"){
		return "Noshahr Canals"
	}else if(map == "MP_018"){
		return "Kharg Island"
	}else if(map == "MP_Subway"){
		return "Operation Métro"
	}else if(map == "XP1_001"){
		return "Strike at Karkand"
	}else if(map == "XP1_002"){
		return "Gulf of Oman"
	}else if(map == "XP1_003"){
		return "Sharqi Peninsula"
	}else if(map == "XP1_004"){
		return "Wake Island"
	}else if(map == "XP2_Factory"){
		return "Scrapmetal"
	}else if(map == "XP2_Office"){
		return "Operation 925"
	}else if(map == "XP2_Palace"){
		return "Donya Fortress"
	}else if(map == "XP2_Skybar"){
		return "Ziba Tower"
	}else if(map == "XP3_Desert"){
		return "Bandar Desert"
	}else if(map == "XP3_Alborz"){
		return "Alborz Mountains"
	}else if(map == "XP3_Shield"){
		return "Armored Shield"
	}else if(map == "XP3_Valley"){
		return "Death Valley"
	}else if(map == "XP4_Quake"){
		return "Epicenter"
	}else if(map == "XP4_FD"){
		return "Markaz Monolith"
	}else if(map == "XP4_Parl"){
		return "Azadi Palace"
	}else if(map == "XP4_Rubble"){
		return "Talah Market"
	}else if(map == "XP5_001"){
		return "Operation Riverside"
	}else if(map == "XP5_002"){
		return "Nebandan Flats"
	}else if(map == "XP5_003"){
		return "Kiasar Railroad"
	}else if(map == "XP5_004"){
		return "Sabalan Pipeline"
	}
}

function generateModeName(mode){
	if(mode == "ConquestLarge0"){
		return "Conquest 64"
	}else if(mode == "ConquestSmall0"){
		return "Conquest"
	}else if(mode == "ConquestAssaultLarge0"){
		return "Conquest Assault 64"
	}else if(mode == "ConquestAssaultSmall0"){
		return "Conquest Assault"
	}else if(mode == "ConquestAssaultSmall1"){
		return "Conquest Assault: Day 2"
	}else if(mode == "RushLarge0"){
		return "Rush"
	}else if(mode == "SquadRush0"){
		return "Squad Rush"
	}else if(mode == "SquadDeathMatch0"){
		return "Squad Deathmatch"
	}else if(mode == "TeamDeathMatch0"){
		return "Team Deathmatch"
	}else if(mode == "TeamDeathMatchC0"){
		return "TDM Close Quarters"
	}else if(mode == "Domination0"){
		return "Conquest Domination"
	}else if(mode == "GunMaster0"){
		return "Gun Master"
	}else if(mode == "TankSuperiority0"){
		return "Tank Superiority"
	}else if(mode == "Scavenger0"){
		return "Scavenger"
	}else if(mode == "CaptureTheFlag0"){
		return "Capture the Flag"
	}else if(mode == "AirSuperiority0"){
		return "Air Superiority"
	}
}

function showMapRotation(){
	document.getElementById("serverInfoConfiguration").style.display = "none";
	document.getElementById("mapListConfiguration").style.display = "block";
	document.getElementById("modListConfiguration").style.display = "none";
	document.getElementById("serverInfoMapRotationBody").style.color = "#000";
	document.getElementById("serverInfoMapRotationBody").style.fontWeight = "900";
	document.getElementById("serverInfoMapRotationBody").style.background = "linear-gradient(#ffffff, #909090d1)";
	document.getElementById("serverInfoPresetConfigurationBody").style.color = null;
	document.getElementById("serverInfoPresetConfigurationBody").style.fontWeight = null;
	document.getElementById("serverInfoPresetConfigurationBody").style.background = null;
	document.getElementById("serverInfoPlayersTopBody").style.color = null;
	document.getElementById("serverInfoPlayersTopBody").style.background = null;
	document.getElementById("serverInfoPlayersTopBody").style.fontWeight = null;
	document.getElementById("currentMap").src = "fb://UI/Art/Menu/Icons/map_current";
	document.getElementById("nextMap").src = "fb://UI/Art/Menu/Icons/map_next";
}
function showServerInfoConfiguration(){
	document.getElementById("serverInfoConfiguration").style.display = "block";
	document.getElementById("mapListConfiguration").style.display = "none";
	document.getElementById("modListConfiguration").style.display = "none";
	document.getElementById("serverInfoPresetConfigurationBody").style.color = "#000";
	document.getElementById("serverInfoPresetConfigurationBody").style.background = "linear-gradient(#ffffff, #909090d1)";
	document.getElementById("serverInfoPresetConfigurationBody").style.fontWeight = "900";
	document.getElementById("serverInfoMapRotationBody").style.color = null;
	document.getElementById("serverInfoMapRotationBody").style.background = null;
	document.getElementById("serverInfoMapRotationBody").style.fontWeight = null;
	document.getElementById("serverInfoPlayersTopBody").style.color = null;
	document.getElementById("serverInfoPlayersTopBody").style.background = null;
	document.getElementById("serverInfoPlayersTopBody").style.fontWeight = null;
}
function showModList(){
	document.getElementById("serverInfoConfiguration").style.display = "none";
	document.getElementById("mapListConfiguration").style.display = "none";
	document.getElementById("modListConfiguration").style.display = "block";
	document.getElementById("serverInfoPresetConfigurationBody").style.color = null;
	document.getElementById("serverInfoPresetConfigurationBody").style.fontWeight = null;
	document.getElementById("serverInfoPresetConfigurationBody").style.background = null;
	document.getElementById("serverInfoMapRotationBody").style.color = null;
	document.getElementById("serverInfoMapRotationBody").style.fontWeight = null;
	document.getElementById("serverInfoMapRotationBody").style.background = null;
	document.getElementById("serverInfoPlayersTopBody").style.color = "#000";
	document.getElementById("serverInfoPlayersTopBody").style.background = "linear-gradient(#ffffff, #909090d1)";
	document.getElementById("serverInfoPlayersTopBody").style.fontWeight = "900";
}
/* Endregion */

/* Region Client Settings */
function showOrHidePing() {
	if(document.getElementById("showPing").innerHTML == "Yes") {
		document.getElementById("showPing").innerHTML = "No";
	}else{
		document.getElementById("showPing").innerHTML = "Yes";
	}
}
function showOrHideVotings() {
	if(document.getElementById("hideVotings").innerHTML == "No") {
		document.getElementById("hideVotings").innerHTML = "Yes";
	}else{
		document.getElementById("hideVotings").innerHTML = "No";
	}
}
function toggleHoldScoreboard() {
	if(document.getElementById("scoreboardMethod").innerHTML == "Click Tab") {
		document.getElementById("scoreboardMethod").innerHTML = "Hold Tab";
	}else{
		document.getElementById("scoreboardMethod").innerHTML = "Click Tab";
	}
}

function getMouseSensitivity(mouseSensitivity) {
	document.getElementById("actualMouseSensitivity").value = Number((mouseSensitivity).toFixed(7));
	WebUI.Call('EnableKeyboard');
}

function getMouseSensitivityMultipliers(args) {
	document.getElementById("ironSightsMultiplier").value = Number((args[0]).toFixed(4));
	document.getElementById("holoMultiplier").value = Number((args[1]).toFixed(4));
	document.getElementById("3xMultiplier").value = Number((args[2]).toFixed(4));
	document.getElementById("4xMultiplier").value = Number((args[3]).toFixed(4));
	document.getElementById("6xMultiplier").value = Number((args[4]).toFixed(4));
	document.getElementById("7xMultiplier").value = Number((args[5]).toFixed(4));
	document.getElementById("8xMultiplier").value = Number((args[6]).toFixed(4));
	document.getElementById("10xMultiplier").value = Number((args[7]).toFixed(4));
	document.getElementById("12xMultiplier").value = Number((args[8]).toFixed(4));
	document.getElementById("20xMultiplier").value = Number((args[9]).toFixed(4));
	WebUI.Call('EnableKeyboard');
}

function resetMouseSensitivityMultipliers() {
	WebUI.Call('DispatchEvent', 'WebUI:ResetMouseSensitivityMultipliers');
}

function saveMouseSensitivityMultipliers() {
	WebUI.Call('ResetKeyboard');
	const args = [];
	args.push(document.getElementById("ironSightsMultiplier").value);
	args.push(document.getElementById("holoMultiplier").value);
	args.push(document.getElementById("3xMultiplier").value);
	args.push(document.getElementById("4xMultiplier").value);
	args.push(document.getElementById("6xMultiplier").value);
	args.push(document.getElementById("7xMultiplier").value);
	args.push(document.getElementById("8xMultiplier").value);
	args.push(document.getElementById("10xMultiplier").value);
	args.push(document.getElementById("12xMultiplier").value);
	args.push(document.getElementById("20xMultiplier").value);
	WebUI.Call('DispatchEvent', 'WebUI:SetMouseSensitivityMultipliers', JSON.stringify(args));
	WebUI.Call('DispatchEvent', 'WebUI:SetMouseSensitivity', document.getElementById("actualMouseSensitivity").value);
	closeSmart();
}

function getFieldOfView(args) {
	document.getElementById("actualFov").value = Number((args[0]).toFixed(4));
	document.getElementById("ironSightsFov").value = Number((args[1]).toFixed(4));
	document.getElementById("holoFov").value = Number((args[2]).toFixed(4));
	document.getElementById("3xFov").value = Number((args[3]).toFixed(4));
	document.getElementById("4xFov").value = Number((args[4]).toFixed(4));
	document.getElementById("6xFov").value = Number((args[5]).toFixed(4));
	document.getElementById("7xFov").value = Number((args[6]).toFixed(4));
	document.getElementById("8xFov").value = Number((args[7]).toFixed(4));
	document.getElementById("10xFov").value = Number((args[8]).toFixed(4));
	document.getElementById("12xFov").value = Number((args[9]).toFixed(4));
	document.getElementById("20xFov").value = Number((args[10]).toFixed(4));
	WebUI.Call('EnableKeyboard');
}

function resetFieldOfView() {
	WebUI.Call('DispatchEvent', 'WebUI:ResetFieldOfView');
}

function saveFieldOfView() {
	WebUI.Call('ResetKeyboard');
	const args = [];
	if(document.getElementById("actualFov").value > 160){
		args.push(160);
	}else if(document.getElementById("actualFov").value < 60){
		args.push(60);
	}else{
		args.push(document.getElementById("actualFov").value);
	}
	if(document.getElementById("ironSightsFov").value > 160){
		args.push(160);
	}else if(document.getElementById("ironSightsFov").value < 51.774){
		args.push(51.774);
	}else{
		args.push(document.getElementById("ironSightsFov").value);
	}
	if(document.getElementById("holoFov").value > 51.774){
		args.push(51.774);
	}else if(document.getElementById("holoFov").value < 41.846){
		args.push(41.846);
	}else{
		args.push(document.getElementById("holoFov").value);
	}
	if(document.getElementById("3xFov").value > 41.846){
		args.push(41.846);
	}else if(document.getElementById("3xFov").value < 26.46){
		args.push(26.46);
	}else{
		args.push(document.getElementById("3xFov").value);
	}
	if(document.getElementById("4xFov").value > 26.46){
		args.push(26.46);
	}else if(document.getElementById("4xFov").value < 22.801){
		args.push(22.801);
	}else{
		args.push(document.getElementById("4xFov").value);
	}
	if(document.getElementById("6xFov").value > 22.801){
		args.push(22.801);
	}else if(document.getElementById("6xFov").value < 15.425){
		args.push(15.425);
	}else{
		args.push(document.getElementById("6xFov").value);
	}
	if(document.getElementById("7xFov").value > 15.425){
		args.push(15.425);
	}else if(document.getElementById("7xFov").value < 13.174){
		args.push(13.174);
	}else{
		args.push(document.getElementById("7xFov").value);
	}
	if(document.getElementById("8xFov").value > 13.174){
		args.push(13.174);
	}else if(document.getElementById("8xFov").value < 11.582){
		args.push(11.582);
	}else{
		args.push(document.getElementById("8xFov").value);
	}
	if(document.getElementById("10xFov").value > 11.582){
		args.push(11.582);
	}else if(document.getElementById("10xFov").value < 9.324){
		args.push(9.324);
	}else{
		args.push(document.getElementById("10xFov").value);
	}
	if(document.getElementById("12xFov").value > 9.324){
		args.push(9.324);
	}else if(document.getElementById("12xFov").value < 7.728){
		args.push(7.728);
	}else{
		args.push(document.getElementById("12xFov").value);
	}
	if(document.getElementById("20xFov").value > 7.728){
		args.push(7.728);
	}else if(document.getElementById("20xFov").value < 4.665){
		args.push(4.665);
	}else{
		args.push(document.getElementById("20xFov").value);
	}
	WebUI.Call('DispatchEvent', 'WebUI:SetFieldOfView', JSON.stringify(args));
	closeSmart();
}
/* Endregion */

/* Region another close action for whatever reason */
function keyboardResetAndClosepopup() {
	WebUI.Call('ResetKeyboard');
	closepopup();
}
/* Endregion */

/* Region Surrender (move to vote stuff)*/
function surrender()
{
	showHideVotings = true;
	WebUI.Call('DispatchEvent', 'WebUI:Surrender');
	closepopup();
	document.getElementById("voteyes").style.fontWeight = "900";
}
/* Endregion */

/* Region admin actions for player */
function move(playerName)
{
	WebUI.Call('DispatchEvent', 'WebUI:IgnoreReleaseTab');
	WebUI.Call('EnableKeyboard');
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Moving: '+playerName+'<div id="close" onclick="keyboardResetAndClosepopup()"></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
	document.getElementById("popupelements").innerHTML += '<div class="dropdown"><input onclick="teamDropdownOpen()" id="teamIdInput" type="textbox" name="1" value="Team US"></input><div class="dropDownButton" onclick="teamDropdownOpen()"></div><div id="teamNamesDropDown" class="dropdown-content"><p onclick="teamDropdownClose(&apos;1&apos;, &apos;Team US&apos;)">Team US</p><p onclick="teamDropdownClose(&apos;2&apos;, &apos;Team RU&apos;)">Team RU</p></div></div>';
	document.getElementById("popupelements").innerHTML += '<div class="dropdown"><input onclick="squadDropdownOpen()" id="squadIdInput" type="textbox" name="0" value="No Squad"></input><div class="dropDownButton" onclick="squadDropdownOpen()"></div><div id="squadNamesDropDown" class="dropdown-content"><p onclick="squadDropdownClose(&apos;0&apos;, &apos;No Squad&apos;)">No Squad</p><p onclick="squadDropdownClose(&apos;1&apos;, &apos;Squad Alpha&apos;)">Squad Alpha</p><p onclick="squadDropdownClose(&apos;2&apos;, &apos;Squad Bravo&apos;)">Squad Bravo</p><p onclick="squadDropdownClose(&apos;3&apos;, &apos;Squad Charlie&apos;)">Squad Charlie</p><p onclick="squadDropdownClose(&apos;4&apos;, &apos;Squad Delta&apos;)">Squad Delta</p><p onclick="squadDropdownClose(&apos;5&apos;, &apos;Squad Echo&apos;)">Squad Echo</p><p onclick="squadDropdownClose(&apos;6&apos;, &apos;Squad Foxtrot&apos;)">Squad Foxtrot</p><p onclick="squadDropdownClose(&apos;7&apos;, &apos;Squad Golf&apos;)">Squad Golf</p><p onclick="squadDropdownClose(&apos;8&apos;, &apos;Squad Hotel&apos;)">Squad Hotel</p><p onclick="squadDropdownClose(&apos;9&apos;, &apos;Squad India&apos;)">Squad India</p><p onclick="squadDropdownClose(&apos;10&apos;, &apos;Squad Juliet&apos;)">Squad Juliet</p><p onclick="squadDropdownClose(&apos;11&apos;, &apos;Squad Kilo&apos;)">Squad Kilo</p><p onclick="squadDropdownClose(&apos;12&apos;, &apos;Squad Lima&apos;)">Squad Lima</p><p onclick="squadDropdownClose(&apos;13&apos;, &apos;Squad Mike&apos;)">Squad Mike</p><p onclick="squadDropdownClose(&apos;14&apos;, &apos;Squad November&apos;)">Squad November</p><p onclick="squadDropdownClose(&apos;15&apos;, &apos;Squad Oscar&apos;)">Squad Oscar</p><p onclick="squadDropdownClose(&apos;16&apos;, &apos;Squad Papa&apos;)">Squad Papa</p><p onclick="squadDropdownClose(&apos;17&apos;, &apos;Squad Quebec&apos;)">Squad Quebec</p><p onclick="squadDropdownClose(&apos;18&apos;, &apos;Squad Romeo&apos;)">Squad Romeo</p><p onclick="squadDropdownClose(&apos;19&apos;, &apos;Squad Sierra&apos;)">Squad Sierra</p><p onclick="squadDropdownClose(&apos;20&apos;, &apos;Squad Tango&apos;)">Squad Tango</p><p onclick="squadDropdownClose(&apos;21&apos;, &apos;Squad Uniform&apos;)">Squad Uniform</p><p onclick="squadDropdownClose(&apos;22&apos;, &apos;Squad Victor&apos;)">Squad Victor</p><p onclick="squadDropdownClose(&apos;23&apos;, &apos;Squad Whiskey&apos;)">Squad Whiskey</p><p onclick="squadDropdownClose(&apos;24&apos;, &apos;Squad Xray&apos;)">Squad Xray</p><p onclick="squadDropdownClose(&apos;25&apos;, &apos;Squad Yankee&apos;)">Squad Yankee</p><p onclick="squadDropdownClose(&apos;26&apos;, &apos;Squad Zulu&apos;)">Squad Zulu</p><p onclick="squadDropdownClose(&apos;27&apos;, &apos;Squad Haggard&apos;)">Squad Haggard</p><p onclick="squadDropdownClose(&apos;28&apos;, &apos;Squad Sweetwater&apos;)">Squad Sweetwater</p><p onclick="squadDropdownClose(&apos;29&apos;, &apos;Squad Preston&apos;)">Squad Preston</p><p onclick="squadDropdownClose(&apos;30&apos;, &apos;Squad Redford&apos;)">Squad Redford</p><p onclick="squadDropdownClose(&apos;31&apos;, &apos;Squad Faith&apos;)">Squad Faith</p><p onclick="squadDropdownClose(&apos;32&apos;, &apos;Squad Celeste&apos;)">Squad Celeste</p></div></div>';
	document.getElementById("popupelements").innerHTML += '<div><input id="moveReason" type="textbox" placeholder="Reason: (Optional)"></input></div>';
	document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="moveNow(&apos;'+playerName+'&apos;)">Move</div>';
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}
function teamDropdownOpen(){
	document.getElementById("teamNamesDropDown").style.display = "block";
}
function teamDropdownClose(teamId, teamName) {
	teamIdToSwitch = teamId;
	teamNameToSwitch = teamName;
	document.getElementById("teamIdInput").name = teamId;
	document.getElementById("teamIdInput").value = teamName;
	document.getElementById("teamNamesDropDown").style.display = "none";
}
function squadDropdownOpen(){
	document.getElementById("squadNamesDropDown").style.display = "block";
}
function squadDropdownClose(squadId, squadName) {
	squadIdToSwitch = squadId;
	squadNameToSwitch = squadName;
	document.getElementById("squadIdInput").name = squadId;
	document.getElementById("squadIdInput").value = squadName;
	document.getElementById("squadNamesDropDown").style.display = "none";
}
function moveNow(playerName)
{
	WebUI.Call('ResetKeyboard');
	const moveArgs = [playerName, teamIdToSwitch, squadIdToSwitch, document.getElementById("moveReason").value];
	WebUI.Call('DispatchEvent', 'WebUI:MovePlayer', JSON.stringify(moveArgs));
	closepopup();
	teamIdToSwitch = "1";
	teamNameToSwitch = "Team US";
	squadIdToSwitch = "0";
	squadNameToSwitch = "No Squad";
}
function kill(playerName)
{
	WebUI.Call('DispatchEvent', 'WebUI:IgnoreReleaseTab');
	WebUI.Call('EnableKeyboard');
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Killing: '+playerName+'<div id="close" onclick="keyboardResetAndClosepopup()"></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
	document.getElementById("popupelements").innerHTML += '<div><input id="killReason" type="textbox" placeholder="Reason: (Optional)"></input></div>';
	document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="killNow(&apos;'+playerName+'&apos;)">Kill</div>';
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}

function killNow(playerName)
{
	WebUI.Call('ResetKeyboard');
	const killArgs = [playerName, document.getElementById("killReason").value];
	WebUI.Call('DispatchEvent', 'WebUI:KillPlayer', JSON.stringify(killArgs));
	closepopup();
}
function kick(playerName)
{
	WebUI.Call('DispatchEvent', 'WebUI:IgnoreReleaseTab');
	WebUI.Call('EnableKeyboard');
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Kicking: '+playerName+'<div id="close" onclick="keyboardResetAndClosepopup()"></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
	document.getElementById("popupelements").innerHTML += '<div><input id="kickReason" type="textbox" placeholder="Reason: (Optional)"></input></div>';
	document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="kickNow(&apos;'+playerName+'&apos;)">Kick</div>';
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}

function kickNow(playerName)
{
	WebUI.Call('ResetKeyboard');
	const kickArgs = [playerName, document.getElementById("kickReason").value];
	WebUI.Call('DispatchEvent', 'WebUI:KickPlayer', JSON.stringify(kickArgs));
	closepopup();
}

function tban(playerName)
{	
	WebUI.Call('DispatchEvent', 'WebUI:IgnoreReleaseTab');
	WebUI.Call('EnableKeyboard');
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Temp. Ban: '+playerName+'<div id="close" onclick="keyboardResetAndClosepopup()"></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
	document.getElementById("popupelements").innerHTML += '<div><input id="tbanDuration" type="textbox" placeholder="Time: (in minutes)"></input></div>';
	document.getElementById("popupelements").innerHTML += '<div><input id="tbanReason" type="textbox" placeholder="Reason: (Optional)"></input></div>';
	document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="tbanNow(&apos;'+playerName+'&apos;)">TBan</div>';
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}

function tbanNow(playerName)
{
	WebUI.Call('ResetKeyboard');
	const tbanArgs = [playerName, document.getElementById("tbanDuration").value, document.getElementById("tbanReason").value];
	WebUI.Call('DispatchEvent', 'WebUI:TBanPlayer', JSON.stringify(tbanArgs));
	closepopup();
}
function ban(playerName)
{
	WebUI.Call('DispatchEvent', 'WebUI:IgnoreReleaseTab');
	WebUI.Call('EnableKeyboard');
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Banning: '+playerName+'<div id="close" onclick="keyboardResetAndClosepopup()"></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"></div>';
	document.getElementById("popupelements").innerHTML += '<div><input id="banReason" type="textbox" placeholder="Reason: (Optional)"></input></div>';
	document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="banNow(&apos;'+playerName+'&apos;)">Ban</div>';
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}

function banNow(playerName)
{
	WebUI.Call('ResetKeyboard');
	const banArgs = [playerName, document.getElementById("banReason").value];
	WebUI.Call('DispatchEvent', 'WebUI:BanPlayer', JSON.stringify(banArgs));
	closepopup();
}
function getAdminRightsOfPlayer(playerName)
{
	WebUI.Call('DispatchEvent', 'WebUI:GetAdminRightsOfPlayer', playerName);
}
function getAdminRightsOfPlayerDone(args)
{
	args.forEach(setAdminRightsOfPlayer);
	adminrights(args[0]);
}

function setAdminRightsOfPlayer(canThis, index)
{		
	if(canThis == "canMove"){
		playerCanMove = true;
	}
	if(canThis == "canKill"){
		playerCanKill = true;
	}
	if(canThis == "canKick"){
		playerCanKick = true;
	}
	if(canThis == "canTban"){
		playerCanTban = true;
	}
	if(canThis == "canBan"){
		playerCanBan = true;
	}
	if(canThis == "canEditAdminRights"){
		playerCanEditAdminRights = true;
	}
	if(canThis == "canEditBanList"){
		playerCanEditBanList = true;
	}
	if(canThis == "canEditMapList"){
		playerCanEditMapList = true;
	}
	if(canThis == "canUseMapFunctions"){
		playerCanUseMapFunctions = true;
	}
	if(canThis == "canAlterServerSettings"){
		playerCanAlterServerSettings = true;
	}
	if(canThis == "canEditReservedSlotsList"){
		playerCanEditReservedSlotsList = true;
	}
	if(canThis == "canEditTextChatModerationList"){
		playerCanEditTextChatModerationList = true;
	}
	if(canThis == "canShutdownServer"){
		playerCanShutdownServer = true;
	}
}

function adminrights(playerName)
{
	document.getElementById("popup").innerHTML = '<div id="titlepopup">Edit Admin Rights: '+playerName+'<div id="close" onclick="closeEditAdminpopup()"></div></div>';
	document.getElementById("popup").innerHTML += '<div id="popupelements"><div id="checkBoxSwitches"></div></div>';
	if(playerCanMove == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canMove" id="pCanMove"><label for="pCanMove">Can Move</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canMove" id="pCanMove" checked><label for="pCanMove">Can Move</label>';
	}
	if(playerCanKill == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canKill" id="pCanKill"><label for="pCanKill">Can Kill</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canKill" id="pCanKill" checked><label for="pCanKill">Can Kill</label>';
	}
	if(playerCanKick == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canKick" id="pCanKick"><label for="pCanKick">Can Kick</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canKick" id="pCanKick" checked><label for="pCanKick">Can Kick</label>';
	}
	if(playerCanTban == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canTban" id="pCanTban"><label for="pCanTban">Can Tban</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canTban" id="pCanTban" checked><label for="pCanTban">Can Tban</label>';
	}
	if(playerCanBan == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canBan" id="pCanBan"><label for="pCanBan">Can Ban</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canBan" id="pCanBan" checked><label for="pCanBan">Can Ban</label>';
	}
	if(playerCanEditAdminRights == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditAdminRights" id="pCanEdit"><label for="pCanEdit">Can Edit Rights</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditAdminRights" id="pCanEdit" checked><label for="pCanEdit">Can Edit Rights</label>';
	}
	if(playerCanEditBanList == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditBanList" id="pCanEditBanList"><label for="pCanEditBanList">Can Edit Ban List</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditBanList" id="pCanEditBanList" checked><label for="pCanEditBanList">Can Edit Ban List</label>';
	}
	if(playerCanEditMapList == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditMapList" id="pCanEditMapList"><label for="pCanEditMapList">Can Edit Map List</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditMapList" id="pCanEditMapList" checked><label for="pCanEditMapList">Can Edit Map List</label>';
	}
	if(playerCanUseMapFunctions == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canUseMapFunctions" id="pCanUseMapFunctions"><label for="pCanUseMapFunctions">Can Use Map Functions</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canUseMapFunctions" id="pCanUseMapFunctions" checked><label for="pCanUseMapFunctions">Can Use Map Functions</label>';
	}
	if(playerCanAlterServerSettings == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canAlterServerSettings" id="pCanAlterServerSettings"><label for="pCanAlterServerSettings">Can Alter Server Settings</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canAlterServerSettings" id="pCanAlterServerSettings" checked><label for="pCanAlterServerSettings">Can Alter Server Settings</label>';
	}
	if(playerCanEditReservedSlotsList == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditReservedSlotsList" id="pCanEditReservedSlotsList"><label for="pCanEditReservedSlotsList">Can Edit Reserved Slot List</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditReservedSlotsList" id="pCanEditReservedSlotsList" checked><label for="pCanEditReservedSlotsList">Can Edit Reserved Slot List</label>';
	}
	if(playerCanEditTextChatModerationList == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditTextChatModerationList" id="pCanEditTextChatModerationList"><label for="pCanEditTextChatModerationList">Can Edit Text Chat Moderation List</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canEditTextChatModerationList" id="pCanEditTextChatModerationList" checked><label for="pCanEditTextChatModerationList">Can Edit Text Chat Moderation List</label>';
	}
	if(playerCanShutdownServer == false) {
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canShutdownServer" id="pCanShutdownServer"><label for="pCanShutdownServer">Can Shutdown Server</label>';
	}else{
		document.getElementById("checkBoxSwitches").innerHTML += '<input type="checkbox" name="editRightsInput" value="canShutdownServer" id="pCanShutdownServer" checked><label for="pCanShutdownServer">Can Shutdown Server</label>';
	}
	document.getElementById("popupelements").innerHTML += '<div id="popupelement" onclick="saveAdminRights(&apos;'+playerName+'&apos;)">Save</div>';
	if(document.getElementById("popupelements").offsetHeight > document.getElementById("popup").offsetHeight)
	{
		document.getElementById("popupelements").style.height = "100%";	
	}
}
function saveAdminRights(playerName)
{
	const checkboxes = document.querySelectorAll('input[name="editRightsInput"]');
	const num = checkboxes.length;
	const args = [playerName];
	for (let i=0; i < num; i++) {
		if (checkboxes[i].checked === true) {
			if(checkboxes[i].value == "canMove") {
				args.push("canMove");
			}else if(checkboxes[i].value == "canKill") {
				args.push("canKill");
			}else if(checkboxes[i].value == "canKick") {
				args.push("canKick");
			}else if(checkboxes[i].value == "canTban") {
				args.push("canTban");
			}else if(checkboxes[i].value == "canBan") {
				args.push("canBan");
			}else if(checkboxes[i].value == "canEditAdminRights") {
				args.push("canEditAdminRights");
			}else if(checkboxes[i].value == "canEditBanList") {
				args.push("canEditBanList");
			}else if(checkboxes[i].value == "canEditMapList") {
				args.push("canEditMapList");
			}else if(checkboxes[i].value == "canUseMapFunctions") {
				args.push("canUseMapFunctions");
			}else if(checkboxes[i].value == "canAlterServerSettings") {
				args.push("canAlterServerSettings");
			}else if(checkboxes[i].value == "canEditReservedSlotsList") {
				args.push("canEditReservedSlotsList");
			}else if(checkboxes[i].value == "canEditTextChatModerationList") {
				args.push("canEditTextChatModerationList");
			}else if(checkboxes[i].value == "canShutdownServer") {
				args.push("canShutdownServer");
			}
		}
	}
	WebUI.Call('DispatchEvent', 'WebUI:UpdateAdminRights', JSON.stringify(args));
	closeEditAdminpopup();
}

function closeEditAdminpopup()
{
	playerCanMove = false;
	playerCanKill = false;
	playerCanKick = false;
	playerCanTban = false;
	playerCanBan = false;
	playerCanEditAdminRights = false;
	playerCanEditBanList = false;
	playerCanEditMapList = false;
	playerCanUseMapFunctions = false;
	playerCanAlterServerSettings = false;
	playerCanEditReservedSlotsList = false;
	playerCanEditTextChatModerationList = false;
	playerCanShutdownServer = false;
	closepopup();
}
// for the target Player:
function getAdminRights(admins)
{
	admin = false;
	canMove = false;
	canKill = false;
	canKick = false;
	canTban = false;
	canBan = false;
	canEditAdminRights = false;
	canEditBanList = false;
	canEditMapList = false;
	canUseMapFunctions = false;
	canAlterServerSettings = false;
	canEditReservedSlotsList = false;
	canEditTextChatModerationList = false;
	canShutdownServer = false;
	localPlayer = admins[0];
	admins.forEach(setAdminRights);
}

function setAdminRights(canThis, index)
{		
	if(canThis == "canMove"){
		canMove = true;
		admin = true;
	}
	if(canThis == "canKill"){
		canKill = true;
		admin = true;
	}
	if(canThis == "canKick"){
		canKick = true;
		admin = true;
	}
	if(canThis == "canTban"){
		canTban = true;
		admin = true;
	}
	if(canThis == "canBan"){
		canBan = true;
		admin = true;
	}
	if(canThis == "canEditAdminRights"){
		canEditAdminRights = true;
		admin = true;
	}
	if(canThis == "canEditBanList"){
		canEditBanList = true;
		admin = true;
	}
	if(canThis == "canEditMapList"){
		canEditMapList = true;
		admin = true;
	}
	if(canThis == "canUseMapFunctions"){
		canUseMapFunctions = true;
		admin = true;
	}
	if(canThis == "canAlterServerSettings"){
		canAlterServerSettings = true;
		admin = true;
	}
	if(canThis == "canEditReservedSlotsList"){
		canEditReservedSlotsList = true;
		admin = true;
	}
	if(canThis == "canEditTextChatModerationList"){
		canEditTextChatModerationList = true;
		admin = true;
	}
	if(canThis == "canShutdownServer"){
		canShutdownServer = true;
		admin = true;
	}
}	
/* Endregion */

/* Region Assist */
function assist()
{
	WebUI.Call('DispatchEvent', 'WebUI:AssistEnemyTeam');
	closepopup();
}
/* Endregion */

/* Region Scoreboard */
function updateScoreboardHeader(scoreboardHeader)
{
	squadCount.length = 0
	place1 = 0;
	place2 = 0;
	document.getElementById("table1").innerHTML = '<tbody id="table1tbody"><tr id="firstrow"><th id="team1">US</th><th id="tickets1"></th><th id="killsHeader1">K</th><th id="deathsHeader1">D</th><th id="scoreHeader1">SCORE</th><th id="pingHeader1">PING</th></tr></tbody>';
	document.getElementById("table2").innerHTML = '<tbody id="table2tbody"><tr id="firstrow"><th id="team2">RU</th><th id="tickets2"></th><th id="killsHeader2">K</th><th id="deathsHeader2">D</th><th id="scoreHeader2">SCORE</th><th id="pingHeader2">PING</th></tr></tbody>';

	document.getElementById("team1").innerHTML = scoreboardHeader[0];
	document.getElementById("tickets1").innerHTML = scoreboardHeader[1];
	document.getElementById("team2").innerHTML = scoreboardHeader[2];
	document.getElementById("tickets2").innerHTML = scoreboardHeader[3];
	localPlayer = scoreboardHeader[4];
	localPlayerSquad = scoreboardHeader[5];
	localPlayerIsSquadLeader = scoreboardHeader[6];
	localPlayerIsSquadPrivate = scoreboardHeader[7];
}

function updateScoreboardHeader2(scoreboardHeader)
{
	place3 = 0;
	place4 = 0;
	document.getElementById("table3").style.display = "inline";
	document.getElementById("table4").style.display = "inline";
	document.getElementById("table3").innerHTML = '<tbody id="table3tbody"><tr id="firstrow"><th id="team3">US</th><th id="tickets3"></th><th id="killsHeader3">K</th><th id="deathsHeader3">D</th><th id="scoreHeader3">SCORE</th><th id="pingHeader3">PING</th></tr></tbody>';
	document.getElementById("table4").innerHTML = '<tbody id="table4tbody"><tr id="firstrow"><th id="team4">RU</th><th id="tickets4"></th><th id="killsHeader4">K</th><th id="deathsHeader4">D</th><th id="scoreHeader4">SCORE</th><th id="pingHeader4">PING</th></tr></tbody>';

	document.getElementById("team3").innerHTML = scoreboardHeader[0];
	document.getElementById("tickets3").innerHTML = scoreboardHeader[1];
	document.getElementById("team4").innerHTML = scoreboardHeader[2];
	document.getElementById("tickets4").innerHTML = scoreboardHeader[3];
}

function updateScoreboardBody1(sendThis1) 
{
	if(squadCount[sendThis1[5]] == null){
		squadCount[sendThis1[5]] = 1;
	}else{
		squadCount[sendThis1[5]] += 1;
	}
	place1 += 1;
	if(localPlayer == sendThis1[1]) {
		localPing = sendThis1[8];
		document.getElementById("showLocalPing").innerHTML = '<p>Ping: <span>'+localPing+' ms</span></p>';
		if(sendThis1[6] == true){
			document.getElementById("table1tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis1[1]+'&apos;, '+sendThis1[5]+', '+sendThis1[9]+')" id="localPlayerScoreboard" class="'+sendThis1[7]+'"><td id="place1">'+place1+'</td><td id="name1">'+sendThis1[1]+'</td><td id="kills1">'+sendThis1[2]+'</td><td id="deaths1">'+sendThis1[3]+'</td><td id="points1">'+sendThis1[4]+'</td><td id="ping1">'+sendThis1[8]+'</td></tr>';
		}else{
			document.getElementById("table1tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis1[1]+'&apos;, '+sendThis1[5]+', '+sendThis1[9]+')" id="localPlayerScoreboard" class="'+sendThis1[7]+' isDead"><td id="place1">'+place1+'</td><td id="name1">'+sendThis1[1]+'</td><td id="kills1">'+sendThis1[2]+'</td><td id="deaths1">'+sendThis1[3]+'</td><td id="points1">'+sendThis1[4]+'</td><td id="ping1">'+sendThis1[8]+'</td></tr>';
		}
	}else if(localPlayerSquad == sendThis1[5] && localPlayerSquad != 0) {
		if(sendThis1[6] == true){
			document.getElementById("table1tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis1[1]+'&apos;, '+sendThis1[5]+', '+sendThis1[9]+')" id="squadMates" class="'+sendThis1[7]+'"><td id="place1">'+place1+'</td><td id="name1">'+sendThis1[1]+'</td><td id="kills1">'+sendThis1[2]+'</td><td id="deaths1">'+sendThis1[3]+'</td><td id="points1">'+sendThis1[4]+'</td><td id="ping1">'+sendThis1[8]+'</td></tr>';
		}else{
			document.getElementById("table1tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis1[1]+'&apos;, '+sendThis1[5]+', '+sendThis1[9]+')" id="squadMates" class="'+sendThis1[7]+' isDead"><td id="place1">'+place1+'</td><td id="name1">'+sendThis1[1]+'</td><td id="kills1">'+sendThis1[2]+'</td><td id="deaths1">'+sendThis1[3]+'</td><td id="points1">'+sendThis1[4]+'</td><td id="ping1">'+sendThis1[8]+'</td></tr>';
		}
	}else{
		if(sendThis1[6] == true){
			document.getElementById("table1tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis1[1]+'&apos;, '+sendThis1[5]+', '+sendThis1[9]+')" class="squad'+sendThis1[5]+' '+sendThis1[7]+'" onmouseover="showWholeSquad(&apos;squad'+sendThis1[5]+'&apos;)" onmouseout="hideWholeSquad(&apos;squad'+sendThis1[5]+'&apos;)"><td id="place1">'+place1+'</td><td id="name1">'+sendThis1[1]+'</td><td id="kills1">'+sendThis1[2]+'</td><td id="deaths1">'+sendThis1[3]+'</td><td id="points1">'+sendThis1[4]+'</td><td id="ping1">'+sendThis1[8]+'</td></tr>';
		}else{
			document.getElementById("table1tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis1[1]+'&apos;, '+sendThis1[5]+', '+sendThis1[9]+')" class="squad'+sendThis1[5]+' '+sendThis1[7]+' isDead" onmouseover="showWholeSquad(&apos;squad'+sendThis1[5]+'&apos;)" onmouseout="hideWholeSquad(&apos;squad'+sendThis1[5]+'&apos;)"><td id="place1">'+place1+'</td><td id="name1">'+sendThis1[1]+'</td><td id="kills1">'+sendThis1[2]+'</td><td id="deaths1">'+sendThis1[3]+'</td><td id="points1">'+sendThis1[4]+'</td><td id="ping1">'+sendThis1[8]+'</td></tr>';
		}
	}
}
function updateScoreboardBody2(sendThis2) 
{
	place2 += 1;
	if(sendThis2[5] == true){
		document.getElementById("table2tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis2[1]+'&apos;, '+0+', '+true+')"><td id="place2">'+place2+'</td><td id="name2">'+sendThis2[1]+'</td><td id="kills2">'+sendThis2[2]+'</td><td id="deaths2">'+sendThis2[3]+'</td><td id="points2">'+sendThis2[4]+'</td><td id="ping2">'+sendThis2[6]+'</td></tr>';
	}else{
		document.getElementById("table2tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis2[1]+'&apos;, '+0+', '+true+')" class="isDead"><td id="place2">'+place2+'</td><td id="name2">'+sendThis2[1]+'</td><td id="kills2">'+sendThis2[2]+'</td><td id="deaths2">'+sendThis2[3]+'</td><td id="points2">'+sendThis2[4]+'</td><td id="ping2">'+sendThis2[6]+'</td></tr>';
	}
}
function updateScoreboardBody3(size) 
{
	while(size > place1)
	{
		document.getElementById("table1tbody").innerHTML += '<tr id="empty"><td id="place1"></td><td id="name1"></td><td id="kills1"></td><td id="deaths1"></td><td id="points1"></td><td id="ping1"></td></tr>';
		place1 += 1;
	}
	while(size > place2)
	{
		document.getElementById("table2tbody").innerHTML += '<tr id="empty"><td id="place2"></td><td id="name2"></td><td id="kills2"></td><td id="deaths2"></td><td id="points2"></td><td id="ping2"></td></tr>';
		place2 += 1;
	}
	document.getElementById("scoreboard").style.display = "inline";
	document.getElementById("tables").style.display = "inline";
	document.getElementById("table1").style.height = null;
	document.getElementById("table2").style.height = null;
	document.getElementById("table1").style.display = "inline";
	document.getElementById("table2").style.display = "inline";
}
function updateScoreboardBody4(sendThis3) 
{
	place3 += 1;
	if(sendThis3[5] == true){
		document.getElementById("table3tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis3[1]+'&apos;, '+0+')"><td id="place3">'+place3+'</td><td id="name3">'+sendThis3[1]+'</td><td id="kills3">'+sendThis3[2]+'</td><td id="deaths3">'+sendThis3[3]+'</td><td id="points3">'+sendThis3[4]+'</td><td id="ping3">'+sendThis3[5]+'</td></tr>';
	}else{
		document.getElementById("table3tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis3[1]+'&apos;, '+0+')" class="isDead"><td id="place3">'+place3+'</td><td id="name3">'+sendThis3[1]+'</td><td id="kills3">'+sendThis3[2]+'</td><td id="deaths3">'+sendThis3[3]+'</td><td id="points3">'+sendThis3[4]+'</td><td id="ping3">'+sendThis3[5]+'</td></tr>';
	}
}
function updateScoreboardBody5(sendThis4) 
{
	place4 += 1;
	if(sendThis4[5] == true){
		document.getElementById("table4tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis4[1]+'&apos;, '+0+')"><td id="place4">'+place4+'</td><td id="name4">'+sendThis4[1]+'</td><td id="kills4">'+sendThis4[2]+'</td><td id="deaths4">'+sendThis4[3]+'</td><td id="points4">'+sendThis4[4]+'</td><td id="ping4">'+sendThis4[5]+'</td></tr>';
	}else{
		document.getElementById("table4tbody").innerHTML += '<tr onmousedown="action(&apos;'+sendThis4[1]+'&apos;, '+0+')" class="isDead"><td id="place4">'+place4+'</td><td id="name4">'+sendThis4[1]+'</td><td id="kills4">'+sendThis4[2]+'</td><td id="deaths4">'+sendThis4[3]+'</td><td id="points4">'+sendThis4[4]+'</td><td id="ping4">'+sendThis4[5]+'</td></tr>';
	}
}
function updateScoreboardBody6() 
{
	while(8 > place3)
	{
		document.getElementById("table3tbody").innerHTML += '<tr id="empty"><td id="place3"></td><td id="name3"></td><td id="kills3"></td><td id="deaths3"></td><td id="points3"></td><td id="ping3"></td></tr>';
		place3 += 1;
	}
	while(8 > place4)
	{
		document.getElementById("table4tbody").innerHTML += '<tr id="empty"><td id="place4"></td><td id="name4"></td><td id="kills4"></td><td id="deaths4"></td><td id="points4"></td><td id="ping4"></td></tr>';
		place4 += 1;
	}
	document.getElementById("table1").style.height = null;
	document.getElementById("table2").style.height = null;
	document.getElementById("table3").style.height = null;
	document.getElementById("table4").style.height = null;
	let height = document.getElementById("table1").clientHeight * 0.558;
	document.getElementById("table1").style.height = height+'px';
	document.getElementById("table2").style.height = height+'px';
	document.getElementById("table3").style.height = height+'px';
	document.getElementById("table4").style.height = height+'px';
	document.getElementById("table3").style.display = "inline";
	document.getElementById("table4").style.display = "inline";
}
function clearScoreboardBody()
{
	document.getElementById("mapRotationTab").style.display = null;
	document.getElementById("mapRotationSettings").style.display = null;
	document.getElementById("serverSetupTab").style.display = null;
	document.getElementById("serverSetupSettings").style.display = null;
	document.getElementById("settingsTab").style.display = null;
	closepopup();
	WebUI.Call('ResetMouse');
	WebUI.Call('ResetKeyboard');
	document.getElementById("scoreboard").style.display = "none";
	showServerInfoConfiguration();
	showGeneralClientSettings()
	document.getElementById("tables").style.display = "none";
	document.getElementById("table1").style.display = "none";
	document.getElementById("table2").style.display = "none";
	document.getElementById("table3").style.display = "none";
	document.getElementById("table4").style.display = "none";
	document.getElementById("headertabs").style.display = "none";
	document.getElementById("overlay").style.backgroundColor =  null;
	document.getElementById("serverInfo").style.display = "none";
	document.getElementById("clientSettings").style.display = "none";
	document.getElementById("managePresetsSettings").style.display = "none";
	if ( document.getElementById("serverInfoTab").classList.contains('active') )
	{
		document.getElementById("serverInfoTab").classList.remove('active');
	}
	if ( document.getElementById("settingsTab").classList.contains('active') )
	{
		document.getElementById("settingsTab").classList.remove('active');
	}
	if ( document.getElementById("scoreboardTab").classList.contains('active') == false )
	{
		document.getElementById("scoreboardTab").classList.add('active');
	}
	place1 = 0;
	place2 = 0;
	place3 = 0;
	place4 = 0;
	document.getElementById("table1").innerHTML = '<tbody id="table1tbody"><tr id="firstrow"><th id="team1">US</th><th id="tickets1">50</th><th id="killsHeader1">K</th><th id="deathsHeader1">D</th><th id="scoreHeader1">SCORE</th><th id="pingHeader1">PING</th></tr></tbody>';
	document.getElementById("table2").innerHTML = '<tbody id="table2tbody"><tr id="firstrow"><th id="team2">RU</th><th id="tickets2">50</th><th id="killsHeader2">K</th><th id="deathsHeader2">D</th><th id="scoreHeader2">SCORE</th><th id="pingHeader2">PING</th></tr></tbody>';
}

function showWholeSquad(squad)
{
	if(squad != "squad0"){
		Array.prototype.forEach.call(document.getElementsByClassName(squad), function(element) {
			element.style.background = "linear-gradient(#327795, rgba(50, 119, 149, 0.63))";
		});
	}
}
function hideWholeSquad(squad)
{
	Array.prototype.forEach.call(document.getElementsByClassName(squad), function(element) {
		element.style.background = null;
	});	
}
/* Endregion */

/* Region RightClick on Scoreboard */
function closeSmart(){
	WebUI.Call('DispatchEvent', 'WebUI:ActiveFalse');
	clearScoreboardBody()
}
function showTabsAndEnableMouse()
{
	WebUI.Call('EnableMouse');
	document.getElementById("headertabs").style.display = "inline";
	document.getElementById("overlay").style.backgroundColor =  "rgba(11, 35, 51, 0.28)";
}
/* Endregion */

/* Region Click on Topbar */
	/* Show/ Hide ServerInfo, Scoreboard, Settings, (Map Rotation, Server Setup) */
function showServerInfo()
{
	WebUI.Call('ResetKeyboard');
	WebUI.Call('DispatchEvent', 'WebUI:GetPlayerCount');
	if ( document.getElementById("scoreboardTab").classList.contains('active') )
	{
		document.getElementById("scoreboardTab").classList.remove('active');
	}
	if ( document.getElementById("settingsTab").classList.contains('active') )
	{
		document.getElementById("settingsTab").classList.remove('active');
	}
	if ( document.getElementById("serverInfoTab").classList.contains('active') == false )
	{
		document.getElementById("serverInfoTab").classList.add('active');
	}
	document.getElementById("serverInfo").style.display = "inline";
	document.getElementById("tables").style.display = "none";
	document.getElementById("clientSettings").style.display = "none";
	document.getElementById("mapRotationSettings").style.display = null;
	document.getElementById("serverSetupSettings").style.display = null;
	document.getElementById("managePresetsSettings").style.display = "none";
	document.getElementById("serverInfoPlayerPingBody").innerHTML = localPing+' ms';
	width = document.getElementById("serverInfoMapRotationBody").clientWidth;
	if( document.getElementById("checkModeName").clientWidth >= width - 28) {
		if ( document.getElementById("serverInfoMapRotationBody").classList.contains('slide-left') == false )
		{
			document.getElementById("serverInfoMapRotationBody").classList.add('slide-left');
			document.getElementById("checkModeName").style.width = "inherit";
		}
	}else{
		if ( document.getElementById("serverInfoMapRotationBody").classList.contains('slide-left') == true )
		{
			document.getElementById("serverInfoMapRotationBody").classList.remove('slide-left');
		}
	}
	if ( document.getElementById("mapRotationTab").classList.contains('active') )
	{
		document.getElementById("mapRotationTab").classList.remove('active');
	}
	if ( document.getElementById("serverSetupTab").classList.contains('active') )
	{
		document.getElementById("serverSetupTab").classList.remove('active');
	}
	showServerInfoConfiguration()
}

function getPlayerCount(count){
	document.getElementById("playerCount").innerHTML = count;
}

function showScoreboard()
{
	WebUI.Call('ResetKeyboard');
	if ( document.getElementById("serverInfoTab").classList.contains('active') )
	{
		document.getElementById("serverInfoTab").classList.remove('active');
	}
	if ( document.getElementById("settingsTab").classList.contains('active') )
	{
		document.getElementById("settingsTab").classList.remove('active');
	}
	if ( document.getElementById("scoreboardTab").classList.contains('active') == false )
	{
		document.getElementById("scoreboardTab").classList.add('active');
	}
	if ( document.getElementById("mapRotationTab").classList.contains('active') )
	{
		document.getElementById("mapRotationTab").classList.remove('active');
	}
	if ( document.getElementById("serverSetupTab").classList.contains('active') )
	{
		document.getElementById("serverSetupTab").classList.remove('active');
	}
	document.getElementById("serverInfo").style.display = "none";
	document.getElementById("tables").style.display = "inline";
	document.getElementById("clientSettings").style.display = "none";
	document.getElementById("mapRotationSettings").style.display = null;
	document.getElementById("serverSetupSettings").style.display = null;
	document.getElementById("managePresetsSettings").style.display = "none";
}
function showClientSettings()
{
	if ( document.getElementById("serverInfoTab").classList.contains('active') )
	{
		document.getElementById("serverInfoTab").classList.remove('active');
	}
	if ( document.getElementById("settingsTab").classList.contains('active') == false )
	{
		document.getElementById("settingsTab").classList.add('active');
	}
	if ( document.getElementById("scoreboardTab").classList.contains('active') )
	{
		document.getElementById("scoreboardTab").classList.remove('active');
	}
	if ( document.getElementById("mapRotationTab").classList.contains('active') )
	{
		document.getElementById("mapRotationTab").classList.remove('active');
	}
	if ( document.getElementById("serverSetupTab").classList.contains('active') )
	{
		document.getElementById("serverSetupTab").classList.remove('active');
	}
	document.getElementById("serverInfo").style.display = "none";
	document.getElementById("tables").style.display = "none";
	document.getElementById("clientSettings").style.display = "inline";
	document.getElementById("mapRotationSettings").style.display = null;
	document.getElementById("settingsTab").style.display = null;
	document.getElementById("mapRotationTab").style.display = null;
	document.getElementById("serverSetupTab").style.display = null;
	document.getElementById("serverSetupSettings").style.display = null;
	document.getElementById("managePresetsSettings").style.display = "none";
	showGeneralClientSettings()
}
/* Endregion */

/* Region Client Settings */
function showGeneralClientSettings()
{
	WebUI.Call('ResetKeyboard');
	if ( document.getElementById("generalClientSettingsTab").classList.contains('active') == false )
	{
		document.getElementById("generalClientSettingsTab").classList.add('active');
	}
	if ( document.getElementById("mouseSensitivtyClientSettingsTab").classList.contains('active') )
	{
		document.getElementById("mouseSensitivtyClientSettingsTab").classList.remove('active');
	}
	if ( document.getElementById("fovClientSettingsTab").classList.contains('active') )
	{
		document.getElementById("fovClientSettingsTab").classList.remove('active');
	}
	if ( canAlterServerSettings == true || canEditMapList == true ) {
		document.getElementById("serverSetup").style.display = "block";
	}else{
		document.getElementById("serverSetup").style.display = null;
	}
	if ( canUseMapFunctions == true ) {
		document.getElementById("mapRotationSetup").style.display = "block";
	}else{
		document.getElementById("mapRotationSetup").style.display = null;
	}
	document.getElementById("generalClientSettings").style.display = "block";
	document.getElementById("mouseSensitivtyClientSettings").style.display = "none";
	document.getElementById("fovClientSettings").style.display = "none";
}
function showMouseSensitivtyClientSettings()
{
	WebUI.Call('DispatchEvent', 'WebUI:GetMouseSensitivity');
	WebUI.Call('DispatchEvent', 'WebUI:GetMouseSensitivityMultipliers');
	WebUI.Call('EnableKeyboard');
	if ( document.getElementById("generalClientSettingsTab").classList.contains('active') )
	{
		document.getElementById("generalClientSettingsTab").classList.remove('active');
	}
	if ( document.getElementById("mouseSensitivtyClientSettingsTab").classList.contains('active') == false )
	{
		document.getElementById("mouseSensitivtyClientSettingsTab").classList.add('active');
	}
	if ( document.getElementById("fovClientSettingsTab").classList.contains('active') )
	{
		document.getElementById("fovClientSettingsTab").classList.remove('active');
	}
	document.getElementById("generalClientSettings").style.display = "none";
	document.getElementById("mouseSensitivtyClientSettings").style.display = "block";
	document.getElementById("fovClientSettings").style.display = "none";
}
function showFovClientSettings()
{
	WebUI.Call('DispatchEvent', 'WebUI:GetFieldOfView');
	WebUI.Call('EnableKeyboard');
	if ( document.getElementById("generalClientSettingsTab").classList.contains('active') )
	{
		document.getElementById("generalClientSettingsTab").classList.remove('active');
	}
	if ( document.getElementById("mouseSensitivtyClientSettingsTab").classList.contains('active') )
	{
		document.getElementById("mouseSensitivtyClientSettingsTab").classList.remove('active');
	}
	if ( document.getElementById("fovClientSettingsTab").classList.contains('active') == false )
	{
		document.getElementById("fovClientSettingsTab").classList.add('active');
	}
	document.getElementById("generalClientSettings").style.display = "none";
	document.getElementById("mouseSensitivtyClientSettings").style.display = "none";
	document.getElementById("fovClientSettings").style.display = "block";
}
function minusMouseSens(multiplier, min, step) {
	var x = parseFloat(document.getElementById(multiplier).value) - step;
	x = Number((x).toFixed(4)); 
	if(x >= min){
		document.getElementById(multiplier).value = x;
	}else{
		document.getElementById(multiplier).value = min;
	}
}
function plusMouseSens(multiplier, max, step) {
	var x = parseFloat(document.getElementById(multiplier).value) + step;
	x = Number((x).toFixed(6)); 
	if(x <= max){
		document.getElementById(multiplier).value = x;
	}else{
		document.getElementById(multiplier).value = max;
	}
}
function minus(multiplier, min, step) {
	var x = parseFloat(document.getElementById(multiplier).value) - step;
	x = Number((x).toFixed(4)); 
	if(x >= min){
		document.getElementById(multiplier).value = x;
	}else{
		document.getElementById(multiplier).value = min;
	}
}
function plus(multiplier, max, step) {
	var x = parseFloat(document.getElementById(multiplier).value) + step;
	x = Number((x).toFixed(4)); 
	if(x <= max){
		document.getElementById(multiplier).value = x;
	}else{
		document.getElementById(multiplier).value = max;
	}
}
function onOff(id){
	if(document.getElementById(id).innerHTML == "On"){
		document.getElementById(id).innerHTML = "Off";
	}else{
		document.getElementById(id).innerHTML = "On";
	}
}
function applyGeneralClientSettings(){
	if(document.getElementById("scoreboardMethod").innerHTML == "Hold Tab"){
		WebUI.Call('DispatchEvent', 'WebUI:HoldScoreboard');
	}else{
		WebUI.Call('DispatchEvent', 'WebUI:ClickScoreboard');
	}
	if(document.getElementById("showPing").innerHTML == "No"){
		document.getElementById("showLocalPing").style.display = "none";
		WebUI.Call('DispatchEvent', 'WebUI:HidePing');
	}else{
		document.getElementById("showLocalPing").style.display = "inline";
		WebUI.Call('DispatchEvent', 'WebUI:ShowPing');
	}
	if(document.getElementById("hideVotings").innerHTML == "No"){
		showHideVotings = true;
		if(isVoteInProgress == true) {
			document.getElementById("votepopup").style.display = "inline";
		}
	}else{
		showHideVotings = false;
		document.getElementById("votepopup").style.display = "none";
	}
	channelsMuted = [];
	if(document.getElementById("adminChannel").innerHTML == "Off"){
		channelsMuted.push("4");
	}else{
		
	}
	if(document.getElementById("allChannel").innerHTML == "Off"){
		channelsMuted.push("0");
	}else{
		
	}
	if(document.getElementById("teamChannel").innerHTML == "Off"){
		channelsMuted.push("1");
	}else{
		
	}
	if(document.getElementById("squadChannel").innerHTML == "Off"){
		channelsMuted.push("2");
	}else{
		
	}
	WebUI.Call('DispatchEvent', 'WebUI:ChatChannels', JSON.stringify(channelsMuted));
	closeSmart();
}
function resetGeneralClientSettings() {
	document.getElementById("scoreboardMethod").innerHTML = "Hold Tab";
	WebUI.Call('DispatchEvent', 'WebUI:HoldScoreboard');
	
	document.getElementById("showPing").innerHTML = "No";
	document.getElementById("showLocalPing").style.display = "none";
	WebUI.Call('DispatchEvent', 'WebUI:HidePing');
	
	document.getElementById("hideVotings").innerHTML = "No";
	showHideVotings = true;
	if(isVoteInProgress == true) {
		document.getElementById("votepopup").style.display = "inline";
	}
	
	channelsMuted = [];
	document.getElementById("adminChannel").innerHTML = "On";
	document.getElementById("allChannel").innerHTML = "On";
	document.getElementById("teamChannel").innerHTML = "On";
	document.getElementById("squadChannel").innerHTML = "On";
	WebUI.Call('DispatchEvent', 'WebUI:ChatChannels', JSON.stringify(channelsMuted));
	
	closeSmart();
}
/* Endregion */

/* Region Update localPlayer ping */
function updateLocalPlayerPing(ping)
{
	localPing = ping
	document.getElementById("showLocalPing").innerHTML = '<p>Ping: <span>'+localPing+' ms</span></p>';
}
/* Endregion */

/* Region admin map rotation */
function mapRotationSetup() 
{
	if ( document.getElementById("serverInfoTab").classList.contains('active') )
	{
		document.getElementById("serverInfoTab").classList.remove('active');
	}
	if ( document.getElementById("scoreboardTab").classList.contains('active') )
	{
		document.getElementById("scoreboardTab").classList.remove('active');
	}
	if ( document.getElementById("settingsTab").classList.contains('active') )
	{
		document.getElementById("settingsTab").classList.remove('active');
	}
	if ( document.getElementById("mapRotationTab").classList.contains('active') == false )
	{
		document.getElementById("mapRotationTab").classList.add('active');
	}
	document.getElementById("settingsTab").style.display = "none";
	document.getElementById("mapRotationTab").style.display = "block";
	document.getElementById("serverInfo").style.display = "none";
	document.getElementById("tables").style.display = "none";
	document.getElementById("clientSettings").style.display = "none";
	document.getElementById("mapRotationSettings").style.display = "block";
	document.getElementById("managePresetsSettings").style.display = "none";
	WebUI.Call('DispatchEvent', 'WebUI:GetCurrentMapRotation');	
}

function getCurrentMapRotation(args){
	let currentMapIndex = args[1][0]
	let nextMapIndex = args[1][1]
	document.getElementById("mapRotationConfiguration").innerHTML = '';
	let o = 1;
	let n = 1;
	let map = "UNDEFINED"
	let mapUrl = "UNDEFINED"
	for(let i=2; i < (parseInt(args[0][0])*3)+2; i++){
		if(o == 1){
			map = generateMapName(args[0][i])
			let k = (i + 1) / 3
			document.getElementById("mapRotationConfiguration").innerHTML += '<div onclick="setNextMap('+k+')" class="mapRotationFieldElement" id="mapRotationFieldElement'+k+'"></div>';
			document.getElementById("mapRotationFieldElement"+k).innerHTML += '<div class="mapRotationFieldElementMap" id="mapRotationFieldElement'+k+'map">'+map+'</div>';
			
		}else if(o == 2){
			n = i - 1;
			let k = (n + 1) / 3
			let mode = generateModeName(args[0][i])
			document.getElementById("mapRotationFieldElement"+k).innerHTML += '<div class="mapRotationFieldElementGameMode" id="mapRotationFieldElement'+k+'gameMode">'+mode+'</div>';
			if(k - 1 == currentMapIndex && k - 1 == nextMapIndex){
				let map = generateMapName(args[0][n])
				document.getElementById('mapRotationCurrentMap').innerHTML = map+', '+mode;
				document.getElementById('mapRotationNextMap').innerHTML = map+', '+mode;
				document.getElementById('mapRotationFieldElement'+k+'gameMode').innerHTML = '<span style="vertical-align: top;">'+mode+'</span><img id="currentMap2" src="fb://UI/Art/Menu/Icons/map_current"/><img style="margin-left: 0;" id="nextMap2" src="fb://UI/Art/Menu/Icons/map_next"/>';
			}else if(k - 1 == currentMapIndex){
				let map = generateMapName(args[0][n])
				document.getElementById('mapRotationCurrentMap').innerHTML = map+', '+mode;
				document.getElementById('mapRotationFieldElement'+k+'gameMode').innerHTML = '<span style="vertical-align: top;">'+mode+'</span><img id="currentMap2" src="fb://UI/Art/Menu/Icons/map_current"/>';
			}else if(k - 1 == nextMapIndex){
				document.getElementById('mapRotationNextMap').innerHTML = map+', '+mode;
				document.getElementById('mapRotationFieldElement'+k+'gameMode').innerHTML = '<span style="vertical-align: top;">'+mode+'</span><img id="nextMap2" src="fb://UI/Art/Menu/Icons/map_next"/>';
			}
		}else if(o == 3){
			n = i - 2;
			let k = (n + 1) / 3
			//document.getElementById("mapRotationFieldElement"+k).innerHTML += '<div class="mapRotationFieldElementRounds" id="mapRotationFieldElement'+k+'rounds">'+args[44][i]+'</div>';
			o = 0;
		}
		o++;
	}
	document.getElementById("currentMap3").src = "fb://UI/Art/Menu/Icons/map_current";
	document.getElementById("nextMap3").src = "fb://UI/Art/Menu/Icons/map_next";
}
function setNextMap(mapIndex) {
	WebUI.Call('DispatchEvent', 'WebUI:SetNextMap', JSON.stringify(mapIndex));
}
function nextRound() {
	WebUI.Call('DispatchEvent', 'WebUI:RunNextRound');
}
function restart() {
	WebUI.Call('DispatchEvent', 'WebUI:RestartRound');
}
/* Endregion */

/* Region admin server setup (work in progress)*/
function serverSetup()
{
	WebUI.Call('EnableKeyboard');
	if ( document.getElementById("serverInfoTab").classList.contains('active') )
	{
		document.getElementById("serverInfoTab").classList.remove('active');
	}
	if ( document.getElementById("scoreboardTab").classList.contains('active') )
	{
		document.getElementById("scoreboardTab").classList.remove('active');
	}
	if ( document.getElementById("settingsTab").classList.contains('active') )
	{
		document.getElementById("settingsTab").classList.remove('active');
	}
	if ( document.getElementById("serverSetupTab").classList.contains('active') == false )
	{
		document.getElementById("serverSetupTab").classList.add('active');
	}
	document.getElementById("settingsTab").style.display = "none";
	document.getElementById("serverSetupTab").style.display = "block";
	document.getElementById("serverInfo").style.display = "none";
	document.getElementById("tables").style.display = "none";
	document.getElementById("clientSettings").style.display = "none";
	document.getElementById("serverSetupSettings").style.display = "block";
	document.getElementById("managePresetsSettings").style.display = "none";
	WebUI.Call('DispatchEvent', 'WebUI:GetServerSetupSettings');
}

function getServerSetupSettings(args)
{
	document.getElementById("serverSetupServerName").value = args[0];
	document.getElementById("serverSetupServerDescription").value = args[1];
	document.getElementById("serverSetupServerMessage").value = args[2];
	document.getElementById("serverSetupServerPassword").value = args[3];
}

function saveServerSetup()
{
	applyManagePresets()
	
	serverSetupArray = [];
	serverSetupArray.push(document.getElementById("serverSetupServerName").value);
	serverSetupArray.push(document.getElementById("serverSetupServerDescription").value);
	serverSetupArray.push(document.getElementById("serverSetupServerMessage").value);
	serverSetupArray.push(document.getElementById("serverSetupServerPassword").value);
	
	WebUI.Call('DispatchEvent', 'WebUI:SaveServerSetupSettings', JSON.stringify(serverSetupArray));
	closeSmart();
}
/* Endregion*/

/* Region Manage Presets*/
function managePresets()
{
	WebUI.Call('ResetKeyboard');
	/*if ( document.getElementById("serverInfoTab").classList.contains('active') )
	{
		document.getElementById("serverInfoTab").classList.remove('active');
	}
	if ( document.getElementById("scoreboardTab").classList.contains('active') )
	{
		document.getElementById("scoreboardTab").classList.remove('active');
	}
	if ( document.getElementById("settingsTab").classList.contains('active') )
	{
		document.getElementById("settingsTab").classList.remove('active');
	}
	if ( document.getElementById("serverSetupTab").classList.contains('active') )
	{
		document.getElementById("serverSetupTab").classList.remove('active');
	}
	if ( document.getElementById("managePresetsTab").classList.contains('active') == false )
	{
		document.getElementById("managePresetsTab").classList.add('active');
	}
	document.getElementById("settingsTab").style.display = "none";
	document.getElementById("serverSetupTab").style.display = "block";*/
	document.getElementById("serverInfo").style.display = "none";
	document.getElementById("tables").style.display = "none";
	document.getElementById("clientSettings").style.display = "none";
	document.getElementById("serverSetupSettings").style.display = "none";
	document.getElementById("managePresetsSettings").style.display = "block";
	WebUI.Call('DispatchEvent', 'WebUI:GetPresetsSettings');
}
function getPresetsSettings(args)
{
	/*document.getElementById("serverSetupServerName").value = args[0];
	document.getElementById("serverSetupServerDescription").value = args[1];
	document.getElementById("serverSetupServerMessage").value = args[2];
	document.getElementById("serverSetupServerPassword").value = args[3];*/
}

function applyManagePresets()
{
	applyManagePresetsArray = [];
	if(document.getElementById("currentPresetInManagePresets").innerHTML == "Normal")
	{
		applyManagePresetsArray.push("normal");
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Hardcore")
	{
		applyManagePresetsArray.push("hardcore");
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Infantry")
	{
		applyManagePresetsArray.push("infantry");
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Hardcore No Map")
	{
		applyManagePresetsArray.push("hardcoreNoMap");
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Custom")
	{
		applyManagePresetsArray.push("custom");
		if(document.getElementById("customPresetFriendlyFire").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		applyManagePresetsArray.push(document.getElementById("customPresetIdleTimeout").innerHTML);
		if(document.getElementById("customPresetAutobalance").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		applyManagePresetsArray.push(document.getElementById("customPresetTeamKillCountForKick").innerHTML);
		applyManagePresetsArray.push(document.getElementById("customPresetTeamKillKicksForBan").innerHTML);
		if(document.getElementById("customPresetVehicleSpawn").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetRegenerateHealth").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetOnlySquadLeaderSpawn").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetMiniMap").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetHUD").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetMinimapSpotting").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPreset3dSpotting").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetKillCam").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPreset3rdPersonCam").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetNameTag").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Normal"){
			applyManagePresetsArray.push("0");
		}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "EU Arms Race"){
			applyManagePresetsArray.push("8");
		}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "RU Arms Race"){
			applyManagePresetsArray.push("7");
		}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "US Arms Race"){
			applyManagePresetsArray.push("6");
		}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Snipers Heaven"){
			applyManagePresetsArray.push("5");
		}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Pistols Only"){
			applyManagePresetsArray.push("4");
		}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Heavy Gear"){
			applyManagePresetsArray.push("3");
		}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Light Weight"){
			applyManagePresetsArray.push("2");
		}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Normal Reversed"){
			applyManagePresetsArray.push("1");
		}
		applyManagePresetsArray.push(document.getElementById("customPresetCtfRoundTimeModifier").innerHTML);
		applyManagePresetsArray.push(document.getElementById("customPresetPlayerRespawnTime").innerHTML);
		applyManagePresetsArray.push(document.getElementById("customPresetPlayerManDownTime").innerHTML);
		applyManagePresetsArray.push(document.getElementById("customPresetPlayerHealth").innerHTML);
		applyManagePresetsArray.push(document.getElementById("customPresetBulletDamage").innerHTML);
		if(document.getElementById("customPresetBluetint").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetSunFlare").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		applyManagePresetsArray.push(document.getElementById("customPresetSuppressionMultiplier").innerHTML);
		let timeScaling = document.getElementById("customPresetTimeScale").innerHTML / 100
		applyManagePresetsArray.push(timeScaling);
		if(document.getElementById("customPresetAllowDeserting").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetDestructionEnabled").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		if(document.getElementById("customPresetVehicleDisabling").innerHTML == "Yes"){
			applyManagePresetsArray.push("true");
		}else{
			applyManagePresetsArray.push("false");
		}
		applyManagePresetsArray.push(document.getElementById("customPresetSquadSize").innerHTML);
	}
	WebUI.Call('DispatchEvent', 'WebUI:ApplyManagePresets', JSON.stringify(applyManagePresetsArray));
	closeSmart();
}

function minusPreset()
{
	if(document.getElementById("currentPresetInManagePresets").innerHTML == "Normal") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Custom";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Custom";
		document.getElementById("presetNormal").style.display = "none";
		document.getElementById("presetHardcore").style.display = "none";
		document.getElementById("presetInfantry").style.display = "none";
		document.getElementById("presetHardcoreNoMap").style.display = "none";
		document.getElementById("presetCustom").style.display = "block";
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Custom") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Hardcore No Map";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Hardcore No Map";
		document.getElementById("presetNormal").style.display = "none";
		document.getElementById("presetHardcore").style.display = "none";
		document.getElementById("presetInfantry").style.display = "none";
		document.getElementById("presetHardcoreNoMap").style.display = "block";
		document.getElementById("presetCustom").style.display = "none";
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Hardcore No Map") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Infantry";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Infantry";
		document.getElementById("presetNormal").style.display = "none";
		document.getElementById("presetHardcore").style.display = "none";
		document.getElementById("presetInfantry").style.display = "block";
		document.getElementById("presetHardcoreNoMap").style.display = "none";
		document.getElementById("presetCustom").style.display = "none";
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Infantry") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Hardcore";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Hardcore";
		document.getElementById("presetNormal").style.display = "none";
		document.getElementById("presetHardcore").style.display = "block";
		document.getElementById("presetInfantry").style.display = "none";
		document.getElementById("presetHardcoreNoMap").style.display = "none";
		document.getElementById("presetCustom").style.display = "none";
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Hardcore") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Normal";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Normal";
		document.getElementById("presetNormal").style.display = "block";
		document.getElementById("presetHardcore").style.display = "none";
		document.getElementById("presetInfantry").style.display = "none";
		document.getElementById("presetHardcoreNoMap").style.display = "none";
		document.getElementById("presetCustom").style.display = "none";
	}
}
function plusPreset()
{
	if(document.getElementById("currentPresetInManagePresets").innerHTML == "Normal") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Hardcore";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Hardcore";
		document.getElementById("presetNormal").style.display = "none";
		document.getElementById("presetHardcore").style.display = "block";
		document.getElementById("presetInfantry").style.display = "none";
		document.getElementById("presetHardcoreNoMap").style.display = "none";
		document.getElementById("presetCustom").style.display = "none";
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Hardcore") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Infantry";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Infantry";
		document.getElementById("presetNormal").style.display = "none";
		document.getElementById("presetHardcore").style.display = "none";
		document.getElementById("presetInfantry").style.display = "block";
		document.getElementById("presetHardcoreNoMap").style.display = "none";
		document.getElementById("presetCustom").style.display = "none";
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Infantry") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Hardcore No Map";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Hardcore No Map";
		document.getElementById("presetNormal").style.display = "none";
		document.getElementById("presetHardcore").style.display = "none";
		document.getElementById("presetInfantry").style.display = "none";
		document.getElementById("presetHardcoreNoMap").style.display = "block";
		document.getElementById("presetCustom").style.display = "none";
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Hardcore No Map") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Custom";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Custom";
		document.getElementById("presetNormal").style.display = "none";
		document.getElementById("presetHardcore").style.display = "none";
		document.getElementById("presetInfantry").style.display = "none";
		document.getElementById("presetHardcoreNoMap").style.display = "none";
		document.getElementById("presetCustom").style.display = "block";
	}else if(document.getElementById("currentPresetInManagePresets").innerHTML == "Custom") {
		document.getElementById("serverSetupCurrentPreset").innerHTML = "Normal";
		document.getElementById("currentPresetInManagePresets").innerHTML = "Normal";
		document.getElementById("presetNormal").style.display = "block";
		document.getElementById("presetHardcore").style.display = "none";
		document.getElementById("presetInfantry").style.display = "none";
		document.getElementById("presetHardcoreNoMap").style.display = "none";
		document.getElementById("presetCustom").style.display = "none";
	}
}

function yesNoPreset(arg)
{
	if(document.getElementById(arg).innerHTML == "No"){
		document.getElementById(arg).innerHTML = "Yes";
	}else{
		document.getElementById(arg).innerHTML = "No";
	}
}

function valuePresetMinus(arg) 
{
	if(arg == "customPresetIdleTimeout"){
		if(document.getElementById(arg).innerHTML == "300"){
		document.getElementById(arg).innerHTML = "200";
		}else if(document.getElementById(arg).innerHTML == "200"){
			document.getElementById(arg).innerHTML = "120";
		}else if(document.getElementById(arg).innerHTML == "120"){
			document.getElementById(arg).innerHTML = "900";
		}else if(document.getElementById(arg).innerHTML == "900"){
			document.getElementById(arg).innerHTML = "800";
		}else if(document.getElementById(arg).innerHTML == "800"){
			document.getElementById(arg).innerHTML = "700";
		}else if(document.getElementById(arg).innerHTML == "700"){
			document.getElementById(arg).innerHTML = "600";
		}else if(document.getElementById(arg).innerHTML == "600"){
			document.getElementById(arg).innerHTML = "500";
		}else if(document.getElementById(arg).innerHTML == "500"){
			document.getElementById(arg).innerHTML = "400";
		}else{
			document.getElementById(arg).innerHTML = "300";
		}
	}else if(arg == "customPresetCtfRoundTimeModifier" || arg == "customPresetPlayerHealth" || arg == "customPresetBulletDamage"){
		if(document.getElementById(arg).innerHTML == "100"){
			document.getElementById(arg).innerHTML = "90";
		}else if(document.getElementById(arg).innerHTML == "90"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "2";
		}else if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "1";
		}else if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "500";
		}else if(document.getElementById(arg).innerHTML == "500"){
			document.getElementById(arg).innerHTML = "400";
		}else if(document.getElementById(arg).innerHTML == "400"){
			document.getElementById(arg).innerHTML = "300";
		}else if(document.getElementById(arg).innerHTML == "300"){
			document.getElementById(arg).innerHTML = "200";
		}else{
			document.getElementById(arg).innerHTML = "100";
		}
	}else if(arg == "customPresetPlayerRespawnTime"){
		if(document.getElementById(arg).innerHTML == "100"){
			document.getElementById(arg).innerHTML = "90";
		}else if(document.getElementById(arg).innerHTML == "90"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "300";
		}else if(document.getElementById(arg).innerHTML == "300"){
			document.getElementById(arg).innerHTML = "200";
		}else{
			document.getElementById(arg).innerHTML = "100";
		}
	}else if(arg == "customPresetPlayerManDownTime" || arg == "customPresetSuppressionMultiplier"){
		if(document.getElementById(arg).innerHTML == "100"){
			document.getElementById(arg).innerHTML = "90";
		}else if(document.getElementById(arg).innerHTML == "90"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "2";
		}else if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "1";
		}else if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "300";
		}else if(document.getElementById(arg).innerHTML == "300"){
			document.getElementById(arg).innerHTML = "200";
		}else{
			document.getElementById(arg).innerHTML = "100";
		}
	}else if(arg == "customPresetTimeScale"){
		if(document.getElementById(arg).innerHTML == "100"){
			document.getElementById(arg).innerHTML = "90";
		}else if(document.getElementById(arg).innerHTML == "90"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "2";
		}else if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "1";
		}else if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "200";
		}else{
			document.getElementById(arg).innerHTML = "100";
		}
	}
}

function valuePresetPlus(arg) 
{
	if(arg == "customPresetIdleTimeout"){
		if(document.getElementById(arg).innerHTML == "300"){
		document.getElementById(arg).innerHTML = "400";
		}else if(document.getElementById(arg).innerHTML == "400"){
			document.getElementById(arg).innerHTML = "500";
		}else if(document.getElementById(arg).innerHTML == "500"){
			document.getElementById(arg).innerHTML = "600";
		}else if(document.getElementById(arg).innerHTML == "600"){
			document.getElementById(arg).innerHTML = "700";
		}else if(document.getElementById(arg).innerHTML == "700"){
			document.getElementById(arg).innerHTML = "800";
		}else if(document.getElementById(arg).innerHTML == "800"){
			document.getElementById(arg).innerHTML = "900";
		}else if(document.getElementById(arg).innerHTML == "900"){
			document.getElementById(arg).innerHTML = "120";
		}else if(document.getElementById(arg).innerHTML == "120"){
			document.getElementById(arg).innerHTML = "200";
		}else{
			document.getElementById(arg).innerHTML = "300";
		}
	}else if(arg == "customPresetCtfRoundTimeModifier" || arg == "customPresetPlayerHealth" || arg == "customPresetBulletDamage"){
		if(document.getElementById(arg).innerHTML == "100"){
			document.getElementById(arg).innerHTML = "200";
		}else if(document.getElementById(arg).innerHTML == "200"){
			document.getElementById(arg).innerHTML = "300";
		}else if(document.getElementById(arg).innerHTML == "300"){
			document.getElementById(arg).innerHTML = "400";
		}else if(document.getElementById(arg).innerHTML == "400"){
			document.getElementById(arg).innerHTML = "500";
		}else if(document.getElementById(arg).innerHTML == "500"){
			document.getElementById(arg).innerHTML = "1";
		}else if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "2";
		}else if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "90";
		}else{
			document.getElementById(arg).innerHTML = "100";
		}
	}else if(arg == "customPresetPlayerRespawnTime"){
		if(document.getElementById(arg).innerHTML == "100"){
			document.getElementById(arg).innerHTML = "200";
		}else if(document.getElementById(arg).innerHTML == "200"){
			document.getElementById(arg).innerHTML = "300";
		}else if(document.getElementById(arg).innerHTML == "300"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "90";
		}else{
			document.getElementById(arg).innerHTML = "100";
		}
	}else if(arg == "customPresetPlayerManDownTime" || arg == "customPresetSuppressionMultiplier"){
		if(document.getElementById(arg).innerHTML == "100"){
			document.getElementById(arg).innerHTML = "200";
		}else if(document.getElementById(arg).innerHTML == "200"){
			document.getElementById(arg).innerHTML = "300";
		}else if(document.getElementById(arg).innerHTML == "300"){
			document.getElementById(arg).innerHTML = "1";
		}else if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "2";
		}else if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "90";
		}else{
			document.getElementById(arg).innerHTML = "100";
		}
	}else if(arg == "customPresetTimeScale"){
		if(document.getElementById(arg).innerHTML == "100"){
			document.getElementById(arg).innerHTML = "200";
		}else if(document.getElementById(arg).innerHTML == "200"){
			document.getElementById(arg).innerHTML = "1";
		}else if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "2";
		}else if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "90";
		}else{
			document.getElementById(arg).innerHTML = "100";
		}
	}
}

function numberPresetMinus(arg)
{
	if(arg == "customPresetTeamKillCountForKick"){
		if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "15";
		}else if(document.getElementById(arg).innerHTML == "15"){
			document.getElementById(arg).innerHTML = "14";
		}else if(document.getElementById(arg).innerHTML == "14"){
			document.getElementById(arg).innerHTML = "13";
		}else if(document.getElementById(arg).innerHTML == "13"){
			document.getElementById(arg).innerHTML = "12";
		}else if(document.getElementById(arg).innerHTML == "12"){
			document.getElementById(arg).innerHTML = "11";
		}else if(document.getElementById(arg).innerHTML == "11"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "3";
		}else{
			document.getElementById(arg).innerHTML = "2";
		}
	}else if(arg == "customPresetTeamKillKicksForBan"){
		if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "99";
		}else if(document.getElementById(arg).innerHTML == "99"){
			document.getElementById(arg).innerHTML = "90";
		}else if(document.getElementById(arg).innerHTML == "90"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "2";
		}else{
			document.getElementById(arg).innerHTML = "1";
		}
	}else if(arg == "customPresetSquadSize"){
		if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "2";
		}else if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "1";
		}else if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "16";
		}else if(document.getElementById(arg).innerHTML == "16"){
			document.getElementById(arg).innerHTML = "15";
		}else if(document.getElementById(arg).innerHTML == "15"){
			document.getElementById(arg).innerHTML = "14";
		}else if(document.getElementById(arg).innerHTML == "14"){
			document.getElementById(arg).innerHTML = "13";
		}else if(document.getElementById(arg).innerHTML == "13"){
			document.getElementById(arg).innerHTML = "12";
		}else if(document.getElementById(arg).innerHTML == "12"){
			document.getElementById(arg).innerHTML = "11";
		}else if(document.getElementById(arg).innerHTML == "11"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "5";
		}else{
			document.getElementById(arg).innerHTML = "4";
		}
	}
}

function numberPresetPlus(arg)
{
	if(arg == "customPresetTeamKillCountForKick"){
		if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "11";
		}else if(document.getElementById(arg).innerHTML == "11"){
			document.getElementById(arg).innerHTML = "12";
		}else if(document.getElementById(arg).innerHTML == "12"){
			document.getElementById(arg).innerHTML = "13";
		}else if(document.getElementById(arg).innerHTML == "13"){
			document.getElementById(arg).innerHTML = "14";
		}else if(document.getElementById(arg).innerHTML == "14"){
			document.getElementById(arg).innerHTML = "15";
		}else{
			document.getElementById(arg).innerHTML = "2";
		}
	}else if(arg == "customPresetTeamKillKicksForBan"){
		if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "2";
		}else if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "3";
		}else if(document.getElementById(arg).innerHTML == "3"){
			document.getElementById(arg).innerHTML = "4";
		}else if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "20";
		}else if(document.getElementById(arg).innerHTML == "20"){
			document.getElementById(arg).innerHTML = "30";
		}else if(document.getElementById(arg).innerHTML == "30"){
			document.getElementById(arg).innerHTML = "40";
		}else if(document.getElementById(arg).innerHTML == "40"){
			document.getElementById(arg).innerHTML = "50";
		}else if(document.getElementById(arg).innerHTML == "50"){
			document.getElementById(arg).innerHTML = "60";
		}else if(document.getElementById(arg).innerHTML == "60"){
			document.getElementById(arg).innerHTML = "70";
		}else if(document.getElementById(arg).innerHTML == "70"){
			document.getElementById(arg).innerHTML = "80";
		}else if(document.getElementById(arg).innerHTML == "80"){
			document.getElementById(arg).innerHTML = "90";
		}else if(document.getElementById(arg).innerHTML == "90"){
			document.getElementById(arg).innerHTML = "99";
		}else{
			document.getElementById(arg).innerHTML = "1";
		}
	}else if(arg == "customPresetSquadSize"){
		if(document.getElementById(arg).innerHTML == "4"){
			document.getElementById(arg).innerHTML = "5";
		}else if(document.getElementById(arg).innerHTML == "5"){
			document.getElementById(arg).innerHTML = "6";
		}else if(document.getElementById(arg).innerHTML == "6"){
			document.getElementById(arg).innerHTML = "7";
		}else if(document.getElementById(arg).innerHTML == "7"){
			document.getElementById(arg).innerHTML = "8";
		}else if(document.getElementById(arg).innerHTML == "8"){
			document.getElementById(arg).innerHTML = "9";
		}else if(document.getElementById(arg).innerHTML == "9"){
			document.getElementById(arg).innerHTML = "10";
		}else if(document.getElementById(arg).innerHTML == "10"){
			document.getElementById(arg).innerHTML = "11";
		}else if(document.getElementById(arg).innerHTML == "11"){
			document.getElementById(arg).innerHTML = "12";
		}else if(document.getElementById(arg).innerHTML == "12"){
			document.getElementById(arg).innerHTML = "13";
		}else if(document.getElementById(arg).innerHTML == "13"){
			document.getElementById(arg).innerHTML = "14";
		}else if(document.getElementById(arg).innerHTML == "14"){
			document.getElementById(arg).innerHTML = "15";
		}else if(document.getElementById(arg).innerHTML == "15"){
			document.getElementById(arg).innerHTML = "16";
		}else if(document.getElementById(arg).innerHTML == "16"){
			document.getElementById(arg).innerHTML = "1";
		}else if(document.getElementById(arg).innerHTML == "1"){
			document.getElementById(arg).innerHTML = "2";
		}else if(document.getElementById(arg).innerHTML == "2"){
			document.getElementById(arg).innerHTML = "3";
		}else{
			document.getElementById(arg).innerHTML = "4";
		}
	}
}

function gunmasterWeaponsMinus()
{
	if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Normal"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "EU Arms Race";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "EU Arms Race"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "RU Arms Race";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "RU Arms Race"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "US Arms Race";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "US Arms Race"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Snipers Heaven";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Snipers Heaven"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Pistols Only";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Pistols Only"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Heavy Gear";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Heavy Gear"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Light Weight";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Light Weight"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Normal Reversed";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Normal Reversed"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Normal";
	} 
}

function gunmasterWeaponsPlus()
{
	if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Normal"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Normal Reversed";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Normal Reversed"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Light Weight";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Light Weight"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Heavy Gear";
	} else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Heavy Gear"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Pistols Only";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Pistols Only"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Snipers Heaven";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "Snipers Heaven"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "US Arms Race";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "US Arms Race"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "RU Arms Race";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "RU Arms Race"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "EU Arms Race";
	}else if(document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML == "EU Arms Race"){
		document.getElementById("customPresetGunmasterWeaponsPreset").innerHTML = "Normal";
	}
}
/* Endregion */

/* Region ServerBanner Loading Screen */
function info(args){
	document.getElementById("bannerHeader").innerHTML = '<p>'+args[0]+'</p>';
	document.getElementById("bannerDescription").innerHTML = '<p>'+args[1]+'</p>';
	if(args[2] != null) {
		document.getElementById("bannerImgSrc").style.backgroundImage = 'url("'+args[2]+'")';
		document.getElementById("serverInfoBannerImgSrc").src = args[2];
	}
}
function hideLoadingScreen()
{
	document.getElementById("banner").style.display = "none";
}

function showLoadingScreen()
{
	document.getElementById("banner").style.display = "inline";
}
/* Endregion */

/* Region ServerOwner Quick Server Setup */
function quickServerSetup()
{
	//document.getElementById("quickSetupPopup").style.display = "inline";
}
/* Endregion */
