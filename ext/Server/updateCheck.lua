-- Code from https://gitlab.com/n4gi0s/vu-mapvote by N4gi0s
-- Modified for general use by GreatApo


-- Add current mod version
local s_LocalModVersion = "0.2.0" --temp fix, waiting for API to get version from mod.json

-- Project URL
local s_ProjectURL = "https://community.veniceunleashed.net/t/betteringameadmin-alpha/658"

-- Add check URL
local s_CheckURL = "https://raw.githubusercontent.com/FlashHit/BetterIngameAdmin/main/mod.json"
-- Check URL examples:
-- GitLab link to mod.json: https://gitlab.com/n4gi0s/vu-mapvote/-/raw/master/mod.json
-- GitHub link to mod.json: https://raw.githubusercontent.com/GramThanos/bf3-vu-day-night/main/day-night/mod.json
-- GitHub link to last release: https://api.github.com/repos/GramThanos/bf3-vu-day-night/releases/latest (release tag name should be formated as VERSION_NUMBER or vVERSION_NUMBER, eg. 0.2 or v0.2)

-- Show up-to-date message
local s_ShowUptodateMsg = true

-- Check last version code
function GetCurrentVersion()
	local s_Options = HttpOptions({}, 10)
	s_Options.verifyCertificate = false; --ignore cert for wine users
	local s_Res = Net:GetHTTP(s_CheckURL, s_Options)
	if s_Res.status ~= 200 then
		return nil
	end
	local s_Json = json.decode(s_Res.body)
	if s_Json.Version ~= nil then
		return s_Json.Version
	elseif s_Json.tag_name ~= nil then
		return s_Json.tag_name:gsub(" ", ""):gsub("^v", "")
	else
		return nil
	end
end

function CheckVersion()
	local s_CurrentVersion = GetCurrentVersion()

	if s_CurrentVersion == nil then
		print("Could not verify if this mod is out of date. You can check manually at " .. s_ProjectURL);
		return true
	elseif s_CurrentVersion ~= s_LocalModVersion then
		error("This mod seems to be out of date! Please visit " .. s_ProjectURL .. " ");
		return false
	elseif s_CurrentVersion == s_LocalModVersion and s_ShowUptodateMsg then
		print("This mod is up-to-date (version " .. s_CurrentVersion .. ")");
		return true
	end
end

return CheckVersion()
