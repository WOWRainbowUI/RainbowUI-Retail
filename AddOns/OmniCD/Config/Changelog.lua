local _, NS = ...

local changelog = [=[
### v2.8.14
-   Update for Patch 11.1
-   Verify CD/R
-   Anchor attached extrabars individually for multiframe users
-   Hide NPC units in group unless in test mode
-   Retain inspect order by added time
-   Ignore inspect request from units already in queue
-   Update BM Hunter 4-pc set bonus CDR amount (March 3, 2025 hotfix)
-   Update Human Racial shared CD for healer spec (March 11, 2025 hotfix)
-   Fix Empowered Renew to benefit from Naaru/Apo (March 12, 2025 hotfix)
-   Fix sync request being made before collecting all unit info
-   Fix brief event-to-unit dissociation caused by delay
-   Fix units being flagged as NPC or offline in a raid
-   Fix anchoring when joining a raid during Edit Mode

### v2.8.13
-   Cata: PvP trinket, set bonus updated for Ruthless/Cataclysmic (season 10/11)
-   Fix shadowwlands zone for testmode

### v2.8.12
-   Fixed progressbar alpha
-   Fixed nil err
-   Hotfixes: Nov 26, 2024

### v2.8.10
-   Realm name removed from icons
-   Fixed Purifying Brew CD
-   Fixed interrupt bar icon and raid marker resetting
-   Fixed anchoring for Cell Raid frames
-   Fixed Adaptive Swarm, The Hunt spell icons
-   Fixed Crusade not showing

### v2.8.9
-   Patch 11.0.5 updates
]=]

if NS and NS[1] then
	local found
	NS[1].changelog = "|cff99cdff" .. changelog:gsub("#+%s+", "", 5):gsub("\n+###.*", ""):gsub("v[%d%.]+", function(ver)
		if not found and ver ~= NS[1].Version then
			found = true
			return "|cff808080" .. ver
		end
	end)
	return
end

if arg and arg[1] then
	if arg[1] == "latest" then
		local latestChangelog = changelog:gsub("\n+###%sv%d.*", "")
		print(latestChangelog)
	else
		print(changelog)
	end
end
