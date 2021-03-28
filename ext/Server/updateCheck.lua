-- Code from https://gitlab.com/n4gi0s/vu-mapvote by N4gi0s
-- Modified for general use by GreatApo


-- Add current mod version
local localModVersion = "0.1.4" --temp fix, waiting for API to get version from mod.json

-- Project URL
local projectURL = "https://community.veniceunleashed.net/t/betteringameadmin-alpha/658"

-- Add check URL
local checkURL = "https://raw.githubusercontent.com/FlashHit/BetterIngameAdmin/main/mod.json"
-- Check URL examples:
-- GitLab link to mod.json: https://gitlab.com/n4gi0s/vu-mapvote/-/raw/master/mod.json
-- GitHub link to mod.json: https://raw.githubusercontent.com/GramThanos/bf3-vu-day-night/main/day-night/mod.json
-- GitHub link to last release: https://api.github.com/repos/GramThanos/bf3-vu-day-night/releases/latest (release tag name should be formated as VERSION_NUMBER or vVERSION_NUMBER, eg. 0.2 or v0.2)

-- Show up-to-date message
local showUptodateMsg = true

-- Check last version code
function getCurrentVersion()
	options = HttpOptions({}, 10)
	options.verifyCertificate = false; --ignore cert for wine users
	res = Net:GetHTTP(checkURL, options)
	if res.status ~= 200 then
		return nil
	end
	json = json.decode(res.body)
	if json.Version ~= nil then
		return json.Version
	elseif json.tag_name ~= nil then
		return json.tag_name:gsub(" ", ""):gsub("^v", "")
	else
		return nil
	end
end

function checkVersion()
	local currentVersion = getCurrentVersion()
	
	if currentVersion == nil then
		print("Could not verify if this mod is out of date. You can check manually at " .. projectURL);
		return true
    elseif currentVersion ~= localModVersion then
		error("This mod seems to be out of date! Please visit " .. projectURL .. " ");
		return false
    elseif currentVersion == localModVersion and showUptodateMsg then
		print("This mod is up-to-date (version " .. currentVersion .. ")");
		return true
	end
end

return checkVersion();
