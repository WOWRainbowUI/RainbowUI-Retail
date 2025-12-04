local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable

local LibAdvFlight = LibStub:GetLibrary("LibAdvFlight-1.1");

local function Print(...)
	local prefix = string.format("|cFFFFF569"..L["DragonRider"] .. "|r:");
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

local f = CreateFrame("Frame")
if LE_EXPANSION_LEVEL_CURRENT <= LE_EXPANSION_WAR_WITHIN then
	f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")

local buffedTargets = {}

local function GetCreatureIDFromGUID(guid)
	if not guid then return nil end
	local npcID = select(6, strsplit("-", guid))
	return tonumber(npcID)
end

local NPCGroups = {
	[238717] = "Demonfly", [238852] = "Demonfly", [238900] = "Demonfly", [244779] = "Demonfly",
	[238786] = "Darkglare", [244781] = "Darkglare",
	[238865] = "FelSpreader",
	[244780] = "Felbat", [238712] = "Felbat",
	[239089] = "Felbomber",
	[238713] = "Skyterror",
	[244782] = "EyeOfGreed", [239186] = "EyeOfGreed",
}

local TrackingSpellID = 1250230;
local killBuffDetected = false;
local KillCounter;

local lastCurrency
if C_CurrencyInfo.GetCurrencyInfo(3252) then
	lastCurrency = C_CurrencyInfo.GetCurrencyInfo(3252).quantity or 0;
end


f:SetScript("OnEvent", function(self, event, ...)
	if not DragonRider_DB then return end
	local SeasonID = PlayerGetTimerunningSeasonID()
	if not SeasonID then return end

	if DragonRider_DB and not DragonRider_DB.Timerunner then
		DragonRider_DB.Timerunner = {};
	end
	if DragonRider_DB and DragonRider_DB.Timerunner and SeasonID and not DragonRider_DB.Timerunner[SeasonID] then
		-- 1 == MoP Remix
		-- 2 == Legion Remix

		DragonRider_DB.Timerunner[SeasonID] = {}
	end
	if DragonRider_DB and DragonRider_DB.Timerunner and DragonRider_DB.Timerunner[SeasonID] and not KillCounter then
		KillCounter = DragonRider_DB.Timerunner[SeasonID];
	end

	if event == "CURRENCY_DISPLAY_UPDATE" then
		if DragonRider_DB and DragonRider_DB.Timerunner and DragonRider_DB.Timerunner[SeasonID] and not DragonRider_DB.Timerunner[SeasonID].Bronze then
			DragonRider_DB.Timerunner[SeasonID].Bronze = 0;
		end
		local currencyType, quantity, quantityChange, quantityGainSource, destroyReason = ...

		if currencyType == 3252 and quantityChange and quantityChange > 0 then
			if LibAdvFlight and LibAdvFlight.IsAdvFlying and LibAdvFlight.IsAdvFlying() then
				if quantityGainSource == Enum.CurrencySource.Spell then
					DragonRider_DB.Timerunner[SeasonID].Bronze = DragonRider_DB.Timerunner[SeasonID].Bronze + quantityChange

					--if DragonRider_DB.debug then --this is very spammy
					--	Print(string.format(
					--		"+%d Bronze (Total: %d)",
					--		quantityChange,
					--		DragonRider_DB.Timerunner[SeasonID].Bronze
					--	))
					--end
				end
			end
		end
	end

	local _, subevent, _, 
		  sourceGUID, _, _, _, 
		  destGUID, _, _, _, 
		  spellId
		= CombatLogGetCurrentEventInfo()

	if (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" or subevent == "SPELL_AURA_APPLIED_DOSE") then
		if spellId == TrackingSpellID then
			if sourceGUID == UnitGUID("player") then
				if destGUID then
					buffedTargets[destGUID] = GetTime();
					killBuffDetected = true;
				end
			end
		end
	end

	if subevent == "UNIT_DIED" and destGUID then
		if not KillCounter then return end
		local npcID = GetCreatureIDFromGUID(destGUID)
		--Print("NPC death:", npcID) -- will be spammy
		local groupKey = NPCGroups[npcID]
		if groupKey and killBuffDetected then
			KillCounter[groupKey] = (KillCounter[groupKey] or 0) + 1
			if DragonRider_DB.debug then
				Print("Tracked Kill: "..groupKey.." | Total: "..KillCounter[groupKey]);
			end
			
			buffedTargets[destGUID] = nil;
			C_Timer.After(1, function() killBuffDetected = false; end)
		end
	end
end)
