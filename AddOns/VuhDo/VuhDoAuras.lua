local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local twipe = table.wipe;
local floor = math.floor;
local strfind = string.find;

local GetUnitAuras = C_UnitAuras and C_UnitAuras.GetUnitAuras;
local GetAuraDataByAuraInstanceID = C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID;
local IsAuraFilteredOutByInstanceID = C_UnitAuras and C_UnitAuras.IsAuraFilteredOutByInstanceID;
local GetAuraApplicationDisplayCount = C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount;
local GetAuraDispelTypeColor = C_UnitAuras and C_UnitAuras.GetAuraDispelTypeColor;
local GetTime = GetTime;
local issecretvalue = issecretvalue;
local next = next;

local VUHDO_CONFIG;
local VUHDO_AURA_GROUPS;
local VUHDO_DEFAULT_AURA_GROUPS;
local VUHDO_PANEL_SETUP;
local VUHDO_RAID;
local VUHDO_I18N_AURA_GROUP_NAMES;
local VUHDO_ACTIVE_HOTS;

local VUHDO_generateUUID;
local VUHDO_determineDebuff;
local VUHDO_updateHotPredicate;

VUHDO_UNIT_AURA_CACHE = VUHDO_UNIT_AURA_CACHE or { };
local VUHDO_UNIT_AURA_CACHE = VUHDO_UNIT_AURA_CACHE;

VUHDO_UNIT_AURA_SLOTS = VUHDO_UNIT_AURA_SLOTS or { };
local VUHDO_UNIT_AURA_SLOTS = VUHDO_UNIT_AURA_SLOTS;

VUHDO_UNIT_AURA_SLOT_INDEX = VUHDO_UNIT_AURA_SLOT_INDEX or { };
local VUHDO_UNIT_AURA_SLOT_INDEX = VUHDO_UNIT_AURA_SLOT_INDEX;

VUHDO_AURA_MIGRATION_VERSION = 1;
local VUHDO_AURA_MIGRATION_VERSION = VUHDO_AURA_MIGRATION_VERSION;

VUHDO_AURA_GROUP_COLOR_OFF = 1;
VUHDO_AURA_GROUP_COLOR_DISPEL = 2;
VUHDO_AURA_GROUP_COLOR_CUSTOM = 3;

local VUHDO_HOTS_RADIOVALUE_GROWTH = {
	[1] = "LEFT",
	[2] = "RIGHT",
	[3] = "LEFT",
	[4] = "RIGHT",
	[5] = "RIGHT",
	[6] = "LEFT",
	[7] = "RIGHT",
	[8] = "LEFT",
	[9] = "RIGHT",
	[10] = "RIGHT",
	[11] = "LEFT",
	[12] = "RIGHT",
	[13] = "RIGHT",
	[14] = "LEFT",
};

local VUHDO_HOTS_RADIOVALUE_WRAP = {
	[1] = "DOWN",
	[2] = "DOWN",
	[3] = "DOWN",
	[4] = "DOWN",
	[5] = "UP",
	[6] = "UP",
	[7] = "UP",
	[8] = "UP",
	[9] = "DOWN",
	[10] = "DOWN",
	[11] = "UP",
	[12] = "UP",
	[13] = "UP",
	[14] = "UP",
};

local VUHDO_POINT_TO_RADIOVALUE = {
	["TOPLEFT"] = 9,
	["TOPRIGHT"] = 17,
	["BOTTOMLEFT"] = 13,
	["BOTTOMRIGHT"] = 14,
};

local VUHDO_DEBUFF_OFFSET_TRANSLATION = {
	["TOPLEFT"] = {
		["x"] = 0,
		["y"] = 0,
	},
	["TOPRIGHT"] = {
		["x"] = 2,
		["y"] = 34,
	},
	["BOTTOMLEFT"] = {
		["x"] = -2,
		["y"] = -34,
	},
	["BOTTOMRIGHT"] = {
		["x"] = 2,
		["y"] = -34,
	},
};

local sEmpty = { };
local sAssignedAuras = { };
local sSlotsToClear = { };
local sSlotsToClearCount = 0;
local sFilteredAuras = { };

local sAuraDataPool;
local sSlotIndexPool;



--
local tCount;
function VUHDO_tableCount(aTable)

	tCount = 0;

	if aTable then
		for _ in pairs(aTable) do
			tCount = tCount + 1;
		end
	end

	return tCount;

end



--
function VUHDO_aurasInitLocalOverrides()

	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_AURA_GROUPS = VUHDO_CONFIG["AURA_GROUPS"];
	VUHDO_DEFAULT_AURA_GROUPS = _G["VUHDO_DEFAULT_AURA_GROUPS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_I18N_AURA_GROUP_NAMES = _G["VUHDO_I18N_AURA_GROUP_NAMES"];
	VUHDO_ACTIVE_HOTS = _G["VUHDO_ACTIVE_HOTS"];

	VUHDO_generateUUID = _G["VUHDO_generateUUID"];
	VUHDO_determineDebuff = _G["VUHDO_determineDebuff"];
	VUHDO_updateHotPredicate = _G["VUHDO_updateHotPredicate"];

	sAuraDataPool = VUHDO_createTablePool("AuraData", 500);
	sSlotIndexPool = VUHDO_createTablePool("SlotIndex", 200);

	VUHDO_initAuraGroupFilters();

	return;

end



--
local tFilter;
function VUHDO_initAuraGroupFilters()

	for _, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or sEmpty) do
		tFilter = tGroup["filter"];

		if tFilter then
			tGroup["isHarmful"] = strfind(tFilter, "HARMFUL") ~= nil;
		end
	end

	for _, tGroup in pairs(VUHDO_AURA_GROUPS or sEmpty) do
		tFilter = tGroup["filter"];

		if tFilter then
			tGroup["isHarmful"] = strfind(tFilter, "HARMFUL") ~= nil;
		end
	end

	return;

end



--
local tGroup;
function VUHDO_getAuraGroupRaw(aGroupId)

	if not aGroupId then
		return nil;
	end

	tGroup = VUHDO_AURA_GROUPS[aGroupId];

	if not tGroup then
		tGroup = VUHDO_DEFAULT_AURA_GROUPS[aGroupId];
	end

	return tGroup;

end



--
local tGroup;
local tIsBuiltIn;
function VUHDO_getAuraGroup(aGroupId)

	if not aGroupId then
		return nil;
	end

	tGroup = VUHDO_AURA_GROUPS[aGroupId];
	tIsBuiltIn = false;

	if not tGroup then
		tGroup = VUHDO_DEFAULT_AURA_GROUPS[aGroupId];
		tIsBuiltIn = tGroup ~= nil;
	end

	if not tGroup then
		return nil;
	end

	if tGroup["enabled"] == false then
		return nil;
	end

	if tIsBuiltIn and VUHDO_CONFIG["AURA_GROUP_DISABLED"] and VUHDO_CONFIG["AURA_GROUP_DISABLED"][aGroupId] then
		return nil;
	end

	if tGroup["playerClassRequired"] and tGroup["playerClassRequired"] ~= VUHDO_PLAYER_CLASS then
		return nil;
	end

	return tGroup;

end



--
function VUHDO_isBuiltInAuraGroup(aGroupId)

	if not aGroupId then
		return false;
	end

	return VUHDO_DEFAULT_AURA_GROUPS[aGroupId] ~= nil;

end



--
function VUHDO_generateAuraGroupId()

	return VUHDO_generateUUID("CUSTOM_", 12);

end



--
local tDisplayName;
local tGroup;
function VUHDO_getAuraGroupDisplayName(aGroupId)

	if not aGroupId then
		return "";
	end

	tGroup = VUHDO_AURA_GROUPS[aGroupId];

	if tGroup and tGroup["displayName"] then
		return tGroup["displayName"];
	end

	tDisplayName = VUHDO_I18N_AURA_GROUP_NAMES[aGroupId];

	if tDisplayName then
		return tDisplayName;
	end

	return aGroupId;

end



--
local tNewId;
local tSourceGroup;
local tNewGroup;
function VUHDO_cloneAuraGroup(aSourceGroupId, aNewDisplayName)

	tSourceGroup = VUHDO_getAuraGroup(aSourceGroupId);

	if not tSourceGroup then
		return nil;
	end

	tNewId = VUHDO_generateAuraGroupId();
	tNewGroup = VUHDO_deepCopyTable(tSourceGroup);
	tNewGroup["displayName"] = aNewDisplayName;

	tNewGroup["priority"] = VUHDO_getNextAuraGroupPriority();

	VUHDO_AURA_GROUPS[tNewId] = tNewGroup;

	return tNewId;

end



--
local tAllGroups;
function VUHDO_getAllAuraGroups()

	tAllGroups = { };

	for tGroupId, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or sEmpty) do
		if not tGroup["playerClassRequired"] or tGroup["playerClassRequired"] == VUHDO_PLAYER_CLASS then
			tAllGroups[tGroupId] = tGroup;
		end
	end

	for tGroupId, tGroup in pairs(VUHDO_AURA_GROUPS or sEmpty) do
		tAllGroups[tGroupId] = tGroup;
	end

	return tAllGroups;

end



--
local tMaxPriority;
local tPriority;
function VUHDO_getNextAuraGroupPriority()

	tAllGroups = VUHDO_getAllAuraGroups();

	tMaxPriority = 0;

	for _, tGroup in pairs(tAllGroups) do
		tPriority = tGroup["priority"] or 0;

		if tPriority > tMaxPriority then
			tMaxPriority = tPriority;
		end
	end

	return tMaxPriority + 1;

end



--
local tDuration;
function VUHDO_getAuraDuration(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId then
		return nil;
	end

	tDuration = GetAuraDuration(aUnit, anAuraInstanceId);

	return tDuration;

end



--
local tAuras;
function VUHDO_getFilteredAuras(aUnit, aFilter, aMaxCount, aSortRule, aSortDir)

	if not aUnit or not aFilter then
		return { };
	end

	tAuras = GetUnitAuras(aUnit, aFilter, aMaxCount or 40, aSortRule or 0, aSortDir or 0);

	return tAuras or { };

end



--
local tMatches;
function VUHDO_auraMatchesFilter(aUnit, anAuraInstanceId, aFilter)

	if not aUnit or not anAuraInstanceId or not aFilter then
		return false;
	end

	if anAuraInstanceId < 0 then
		return false;
	end

	tMatches = not IsAuraFilteredOutByInstanceID(aUnit, anAuraInstanceId, aFilter);

	return tMatches;

end



--
local tAuraData;
function VUHDO_getAuraDataByInstanceId(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId then
		return nil;
	end

	tAuraData = GetAuraDataByAuraInstanceID(aUnit, anAuraInstanceId);

	return tAuraData;

end



--
local tCountText;
function VUHDO_getAuraStackDisplay(aUnit, anAuraInstanceId, aMinCount, aMaxCount)

	if not aUnit or not anAuraInstanceId then
		return "";
	end

	tCountText = GetAuraApplicationDisplayCount(aUnit, anAuraInstanceId, aMinCount or 2, aMaxCount or 999);

	return tCountText or "";

end



--
local tDefaults;
function VUHDO_resolveAuraTriState(anAnchorValue, aFieldName)

	if anAnchorValue == 1 then
		return true;
	elseif anAnchorValue == 3 then
		return false;
	end

	tDefaults = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["AURA_DEFAULTS"];

	if tDefaults and tDefaults[aFieldName] ~= nil then
		return tDefaults[aFieldName];
	end

	return true;

end



--
local tR;
local tG;
local tB;
local tColorMixin;
function VUHDO_getAuraDispelColor(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId then
		return nil, nil, nil;
	end

	tColorMixin = GetAuraDispelTypeColor(aUnit, anAuraInstanceId, VUHDO_getDispelTypeCurve());

	if tColorMixin and tColorMixin.GetRGBA then
		tR, tG, tB = tColorMixin:GetRGBA();

		return tR, tG, tB;
	end

	return nil, nil, nil;

end



--
local tCachedData;
local tAuraInstanceId;
function VUHDO_cacheAuraData(aUnit, anAuraData)

	if not aUnit or not anAuraData then
		return nil;
	end

	tAuraInstanceId = anAuraData["auraInstanceID"];

	if not tAuraInstanceId then
		return nil;
	end

	if not VUHDO_UNIT_AURA_CACHE[aUnit] then
		VUHDO_UNIT_AURA_CACHE[aUnit] = { };
	end

	tCachedData = sAuraDataPool:get();

	tCachedData["auraInstanceID"] = tAuraInstanceId;
	tCachedData["icon"] = anAuraData["icon"];
	tCachedData["name"] = anAuraData["name"];
	tCachedData["spellId"] = anAuraData["spellId"];
	tCachedData["applications"] = anAuraData["applications"];
	tCachedData["duration"] = anAuraData["duration"];
	tCachedData["expirationTime"] = anAuraData["expirationTime"];
	tCachedData["sourceUnit"] = anAuraData["sourceUnit"];
	tCachedData["isHarmful"] = anAuraData["isHarmful"];
	tCachedData["dispelName"] = anAuraData["dispelName"];

	VUHDO_UNIT_AURA_CACHE[aUnit][tAuraInstanceId] = tCachedData;

	return tCachedData;

end



--
local tCachedData;
function VUHDO_uncacheAuraData(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId then
		return;
	end

	if not VUHDO_UNIT_AURA_CACHE[aUnit] then
		return;
	end

	tCachedData = VUHDO_UNIT_AURA_CACHE[aUnit][anAuraInstanceId];

	if tCachedData then
		sAuraDataPool:release(tCachedData);

		VUHDO_UNIT_AURA_CACHE[aUnit][anAuraInstanceId] = nil;
	end

	return;

end



--
local tUnitCache;
local tUnitSlots;
function VUHDO_clearUnitAuraCache(aUnit)

	if not aUnit then
		return;
	end

	tUnitCache = VUHDO_UNIT_AURA_CACHE[aUnit];

	if tUnitCache then
		for tInstanceId, tCachedData in pairs(tUnitCache) do
			sAuraDataPool:release(tCachedData);
			tUnitCache[tInstanceId] = nil;
		end
	end

	tUnitSlots = VUHDO_UNIT_AURA_SLOT_INDEX[aUnit];

	if tUnitSlots then
		for tInstanceId, tSlotInfo in pairs(tUnitSlots) do
			sSlotIndexPool:release(tSlotInfo);
			tUnitSlots[tInstanceId] = nil;
		end
	end

	if VUHDO_UNIT_AURA_SLOTS[aUnit] then
		for tPanelNum, tPanelSlots in pairs(VUHDO_UNIT_AURA_SLOTS[aUnit]) do
			for tAnchorIndex, tAnchorSlots in pairs(tPanelSlots) do
				twipe(tAnchorSlots);
			end
		end
	end

	return;

end



--
function VUHDO_clearAllAuraCaches()

	for tUnit, _ in pairs(VUHDO_UNIT_AURA_CACHE) do
		VUHDO_clearUnitAuraCache(tUnit);
	end

	return;

end



--
function VUHDO_refreshAllUnitAuras()

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_fullAuraRefresh(tUnit);
	end

	return;

end



--
local tPanelAnchors;
function VUHDO_initUnitAuraSlots(aUnit)

	if not aUnit then
		return;
	end

	if not VUHDO_UNIT_AURA_SLOTS[aUnit] then
		VUHDO_UNIT_AURA_SLOTS[aUnit] = { };
	end

	if not VUHDO_UNIT_AURA_SLOT_INDEX[aUnit] then
		VUHDO_UNIT_AURA_SLOT_INDEX[aUnit] = { };
	end

	if not VUHDO_UNIT_AURA_CACHE[aUnit] then
		VUHDO_UNIT_AURA_CACHE[aUnit] = { };
	end

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		if not VUHDO_UNIT_AURA_SLOTS[aUnit][tPanelNum] then
			VUHDO_UNIT_AURA_SLOTS[aUnit][tPanelNum] = { };
		end

		tPanelAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

		if tPanelAnchors then
			for tAnchorKey, _ in pairs(tPanelAnchors) do
				if not VUHDO_UNIT_AURA_SLOTS[aUnit][tPanelNum][tAnchorKey] then
					VUHDO_UNIT_AURA_SLOTS[aUnit][tPanelNum][tAnchorKey] = { };
				end
			end
		end
	end

	return;

end



--
local tPanelSlots;
local tAnchorSlots;
function VUHDO_getAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, aSlotIndex)

	if not aUnit or not aPanelNum or not anAnchorIndex or not aSlotIndex then
		return nil;
	end

	tPanelSlots = VUHDO_UNIT_AURA_SLOTS[aUnit];

	if not tPanelSlots then
		return nil;
	end

	tPanelSlots = tPanelSlots[aPanelNum];

	if not tPanelSlots then
		return nil;
	end

	tAnchorSlots = tPanelSlots[anAnchorIndex];

	if not tAnchorSlots then
		return nil;
	end

	return tAnchorSlots[aSlotIndex];

end



--
local tOldAuraId;
local tAuraIndex;
local tPanelIndex;
function VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, aSlotIndex, anAuraInstanceId)

	if not aUnit or not aPanelNum or not anAnchorIndex or not aSlotIndex then
		return;
	end

	if not VUHDO_UNIT_AURA_SLOTS[aUnit] or not VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum] or not VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum][anAnchorIndex] then
		return;
	end

	tOldAuraId = VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum][anAnchorIndex][aSlotIndex];

	if tOldAuraId and tOldAuraId ~= anAuraInstanceId then
		tAuraIndex = VUHDO_UNIT_AURA_SLOT_INDEX[aUnit][tOldAuraId];

		if tAuraIndex then
			tPanelIndex = tAuraIndex[aPanelNum];

			if tPanelIndex then
				tPanelIndex[anAnchorIndex] = nil;

				if not next(tPanelIndex) then
					tAuraIndex[aPanelNum] = nil;
				end
			end

			if not next(tAuraIndex) then
				VUHDO_UNIT_AURA_SLOT_INDEX[aUnit][tOldAuraId] = nil;
			end
		end
	end

	VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum][anAnchorIndex][aSlotIndex] = anAuraInstanceId;

	if anAuraInstanceId then
		if not VUHDO_UNIT_AURA_SLOT_INDEX[aUnit][anAuraInstanceId] then
			VUHDO_UNIT_AURA_SLOT_INDEX[aUnit][anAuraInstanceId] = { };
		end

		if not VUHDO_UNIT_AURA_SLOT_INDEX[aUnit][anAuraInstanceId][aPanelNum] then
			VUHDO_UNIT_AURA_SLOT_INDEX[aUnit][anAuraInstanceId][aPanelNum] = { };
		end

		VUHDO_UNIT_AURA_SLOT_INDEX[aUnit][anAuraInstanceId][aPanelNum][anAnchorIndex] = aSlotIndex;
	end

	return;

end



--
local tAuraIndex;
function VUHDO_findAllAnchorSlotsByAuraId(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId then
		return nil;
	end

	if not VUHDO_UNIT_AURA_SLOT_INDEX[aUnit] then
		return nil;
	end

	tAuraIndex = VUHDO_UNIT_AURA_SLOT_INDEX[aUnit][anAuraInstanceId];

	if not tAuraIndex or not next(tAuraIndex) then
		return nil;
	end

	return tAuraIndex;

end



--
local tTriValue;
function VUHDO_getAnchorTriStateBool(anAnchorConfig, aFieldName, aDefaultValue)

	tTriValue = anAnchorConfig and anAnchorConfig[aFieldName];

	if tTriValue == 1 then
		return true;
	elseif tTriValue == 3 then
		return false;
	else
		return aDefaultValue;
	end

end



--
local tInfo;
function VUHDO_onUnitAura(aUnit, aUpdateInfo)

	if not aUnit then
		return;
	end

	tInfo = (VUHDO_RAID or sEmpty)[aUnit];

	if not tInfo then
		return;
	end

	if not aUpdateInfo or aUpdateInfo["isFullUpdate"] then
		VUHDO_fullAuraRefresh(aUnit);
	else
		VUHDO_incrementalAuraUpdate(aUnit, aUpdateInfo);
	end

	tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineDebuff(aUnit, aUpdateInfo);

	return;

end



--
local tNow;
local tAuraName;
local tAuraIcon;
local tApplications;
local tDuration;
local tExpirationTime;
local tSourceUnit;
local tSpellId;
local tAuraInstanceId;
function VUHDO_updateHotPredicateFromAura(aUnit, anAuraData, anIsUpdate)

	if not aUnit or not anAuraData then
		return;
	end

	tAuraIcon = anAuraData["icon"];
	tApplications = anAuraData["applications"];
	tDuration = anAuraData["duration"];
	tExpirationTime = anAuraData["expirationTime"];

	if (tAuraIcon and issecretvalue(tAuraIcon)) or (tApplications and issecretvalue(tApplications)) or
		(tDuration and issecretvalue(tDuration)) or (tExpirationTime and issecretvalue(tExpirationTime)) then
		return;
	end

	tAuraName = anAuraData["name"];
	tSpellId = anAuraData["spellId"];
	tSourceUnit = anAuraData["sourceUnit"];
	tAuraInstanceId = anAuraData["auraInstanceID"];

	if not VUHDO_ACTIVE_HOTS[tAuraName] and not VUHDO_ACTIVE_HOTS[tostring(tSpellId or -1)] then
		return;
	end

	if not tAuraIcon then
		return;
	end

	tNow = GetTime();

	VUHDO_updateHotPredicate(aUnit, tNow, tAuraInstanceId, tAuraName, tAuraIcon, tApplications, tDuration, tExpirationTime, tSourceUnit, tSpellId, anIsUpdate);

	return;

end



--
local tAuras;
function VUHDO_refreshHotDataForUnit(aUnit)

	if not aUnit or not GetUnitAuras then
		return;
	end

	tAuras = GetUnitAuras(aUnit, "HELPFUL", 40, 0, 0);

	if tAuras then
		for _, tAura in ipairs(tAuras) do
			VUHDO_updateHotPredicateFromAura(aUnit, tAura, false);
		end
	end

	tAuras = GetUnitAuras(aUnit, "HARMFUL", 40, 0, 0);

	if tAuras then
		for _, tAura in ipairs(tAuras) do
			VUHDO_updateHotPredicateFromAura(aUnit, tAura, false);
		end
	end

	return;

end



--
local tAuras;
function VUHDO_fullAuraRefresh(aUnit)

	if not aUnit then
		return;
	end

	VUHDO_clearUnitAuraCache(aUnit);

	tAuras = GetUnitAuras(aUnit, "HELPFUL", 40, 0, 0);

	if tAuras then
		for _, tAura in ipairs(tAuras) do
			VUHDO_cacheAuraData(aUnit, tAura);
			VUHDO_updateHotPredicateFromAura(aUnit, tAura, false);
		end
	end

	tAuras = GetUnitAuras(aUnit, "HARMFUL", 40, 0, 0);

	if tAuras then
		for _, tAura in ipairs(tAuras) do
			VUHDO_cacheAuraData(aUnit, tAura);
			VUHDO_updateHotPredicateFromAura(aUnit, tAura, false);
		end
	end

	for tPanelNum = 1, 10 do
		VUHDO_rebuildSlotAssignmentsForPanel(aUnit, tPanelNum);
	end

	VUHDO_updateAuraDisplaysForUnit(aUnit);

	return;

end



--
local tAura;
local tCachedData;
function VUHDO_incrementalAuraUpdate(aUnit, aUpdateInfo)

	if not aUnit or not aUpdateInfo then
		return;
	end

	if aUpdateInfo["addedAuras"] then
		for _, tAura in pairs(aUpdateInfo["addedAuras"]) do
			VUHDO_cacheAuraData(aUnit, tAura);

			VUHDO_onAuraAdded(aUnit, tAura);
		end
	end

	if aUpdateInfo["updatedAuraInstanceIDs"] then
		for _, tAuraInstanceId in pairs(aUpdateInfo["updatedAuraInstanceIDs"]) do
			tCachedData = VUHDO_UNIT_AURA_CACHE[aUnit] and VUHDO_UNIT_AURA_CACHE[aUnit][tAuraInstanceId];

			tAura = VUHDO_getAuraDataByInstanceId(aUnit, tAuraInstanceId);

			if tCachedData and tAura then
				tCachedData["applications"] = tAura["applications"];
				tCachedData["duration"] = tAura["duration"];
				tCachedData["expirationTime"] = tAura["expirationTime"];
			end

			if tAura then
				VUHDO_onAuraUpdated(aUnit, tAura);
			end
		end
	end

	if aUpdateInfo["removedAuraInstanceIDs"] then
		for _, tAuraInstanceId in pairs(aUpdateInfo["removedAuraInstanceIDs"]) do
			VUHDO_uncacheAuraData(aUnit, tAuraInstanceId);

			VUHDO_onAuraRemoved(aUnit, tAuraInstanceId);
		end
	end

	VUHDO_updateAuraDisplaysForUnit(aUnit);

	return;

end



--
function VUHDO_onAuraAdded(aUnit, anAuraData)

	if not aUnit or not anAuraData then
		return;
	end

	for tPanelNum = 1, 10 do
		VUHDO_checkAuraForPanelAnchors(aUnit, tPanelNum, anAuraData);
	end

	VUHDO_updateHotPredicateFromAura(aUnit, anAuraData, false);

	return;

end



--
function VUHDO_onAuraUpdated(aUnit, anAuraData)

	if not aUnit or not anAuraData then
		return;
	end

	VUHDO_updateHotPredicateFromAura(aUnit, anAuraData, true);

	return;

end



--
local tPanelNum;
local tAnchorIndex;
local tSlotIndex;
local tAuraIndex;
local tPanelIndex;
local tIdx;
function VUHDO_onAuraRemoved(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId then
		return;
	end

	tAuraIndex = VUHDO_findAllAnchorSlotsByAuraId(aUnit, anAuraInstanceId);

	if tAuraIndex then
		twipe(sSlotsToClear);
		sSlotsToClearCount = 0;

		for tPanelNum, tPanelIndex in pairs(tAuraIndex) do
			for tAnchorIndex, tSlotIndex in pairs(tPanelIndex) do
				sSlotsToClearCount = sSlotsToClearCount + 1;
				tIdx = sSlotsToClearCount * 3;
				sSlotsToClear[tIdx - 2] = tPanelNum;
				sSlotsToClear[tIdx - 1] = tAnchorIndex;
				sSlotsToClear[tIdx] = tSlotIndex;
			end
		end

		for tIdx = 1, sSlotsToClearCount do
			tPanelNum = sSlotsToClear[tIdx * 3 - 2];
			tAnchorIndex = sSlotsToClear[tIdx * 3 - 1];
			tSlotIndex = sSlotsToClear[tIdx * 3];

			VUHDO_setAnchorSlotAuraId(aUnit, tPanelNum, tAnchorIndex, tSlotIndex, nil);

			VUHDO_refillAnchorSlots(aUnit, tPanelNum, tAnchorIndex);
		end
	end

	VUHDO_removeHotByAuraInstanceId(aUnit, anAuraInstanceId);

	return;

end



--
local tPanelAnchors;
local tGroup;
function VUHDO_checkAuraForPanelAnchors(aUnit, aPanelNum, anAuraData)

	if not aUnit or not aPanelNum or not anAuraData then
		return;
	end

	tPanelAnchors = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"];

	if not tPanelAnchors then
		return;
	end

	for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
		if tAnchorConfig["enabled"] ~= false then
			tGroup = VUHDO_getAuraGroup(tAnchorConfig["groupId"]);

			if tGroup then
				if VUHDO_auraMatchesFilter(aUnit, anAuraData["auraInstanceID"], tGroup["filter"]) then
					if not tGroup["excludeFilter"] or not VUHDO_auraMatchesFilter(aUnit, anAuraData["auraInstanceID"], tGroup["excludeFilter"]) then
						VUHDO_tryAddAuraToAnchor(aUnit, aPanelNum, tAnchorIndex, tAnchorConfig, anAuraData);
					end
				end
			end
		end
	end

	return;

end



--
local tAnchorSlots;
local tMaxSlots;
local tOccupied;
function VUHDO_tryAddAuraToAnchor(aUnit, aPanelNum, anAnchorIndex, anAnchorConfig, anAuraData)

	if not aUnit or not aPanelNum or not anAnchorIndex or not anAnchorConfig or not anAuraData then
		return;
	end

	tMaxSlots = anAnchorConfig["maxDisplay"] or 5;
	tAnchorSlots = VUHDO_UNIT_AURA_SLOTS[aUnit] and VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum] and VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum][anAnchorIndex];

	for tSlotIndex = 1, tMaxSlots do
		tOccupied = (tAnchorSlots and tAnchorSlots[tSlotIndex]);

		if not tOccupied then
			VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tSlotIndex, anAuraData["auraInstanceID"]);

			break;
		end
	end

	return;

end



--
local tAnchorConfig;
function VUHDO_refillAnchorSlots(aUnit, aPanelNum, anAnchorIndex)

	if not aUnit or not aPanelNum or not anAnchorIndex then
		return;
	end

	tAnchorConfig = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"][anAnchorIndex];

	if tAnchorConfig then
		VUHDO_rebuildSlotAssignmentsForAnchor(aUnit, aPanelNum, anAnchorIndex, tAnchorConfig);
	end

	return;

end



--
local tPanelAnchors;
function VUHDO_queryAndCacheAurasForPanel(aUnit, aPanelNum)

	if not aUnit or not aPanelNum then
		return;
	end

	tPanelAnchors = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"];

	if not tPanelAnchors then
		return;
	end

	for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
		if tAnchorConfig["enabled"] ~= false then
			VUHDO_queryAndCacheAurasForAnchor(aUnit, aPanelNum, tAnchorIndex);
		else
			VUHDO_clearAurasForAnchor(aUnit, aPanelNum, tAnchorIndex, tAnchorConfig);
		end
	end

	return;

end



--
local tPanelAnchors;
function VUHDO_rebuildSlotAssignmentsForPanel(aUnit, aPanelNum)

	if not aUnit or not aPanelNum then
		return;
	end

	tPanelAnchors = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"];

	if not tPanelAnchors then
		return;
	end

	for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
		if tAnchorConfig["enabled"] ~= false then
			VUHDO_rebuildSlotAssignmentsForAnchor(aUnit, aPanelNum, tAnchorIndex, tAnchorConfig);
		end
	end

	return;

end



--
local tGroup;
local tUnitCache;
local tSlotIndex;
local tMaxSlots;
local tAnchorSlots;
local tInstanceId;
local tClearIdx;
local tInferredAura;
function VUHDO_rebuildSlotAssignmentsForAnchor(aUnit, aPanelNum, anAnchorIndex, anAnchorConfig)

	if not aUnit or not aPanelNum or not anAnchorIndex or not anAnchorConfig then
		return;
	end

	tGroup = VUHDO_getAuraGroup(anAnchorConfig["groupId"]);

	if not tGroup then
		return;
	end

	tMaxSlots = anAnchorConfig["maxDisplay"] or 5;
	tUnitCache = VUHDO_UNIT_AURA_CACHE[aUnit];

	if tGroup["isInferred"] then
		for tClearIdx = 1, tMaxSlots do
			VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tClearIdx, nil);
		end

		tInferredAura = VUHDO_getInferredAura(aUnit, anAnchorConfig["groupId"]);

		if tInferredAura then
			VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, 1, tInferredAura["auraInstanceID"]);
		end

		return;
	end

	if anAnchorConfig["fixedSlots"] then
		tAnchorSlots = VUHDO_UNIT_AURA_SLOTS[aUnit] and VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum] and VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum][anAnchorIndex];

		twipe(sAssignedAuras);

		if tAnchorSlots then
			for tSlotIdx = 1, tMaxSlots do
				tInstanceId = tAnchorSlots[tSlotIdx];

				if tInstanceId then
					if tUnitCache and tUnitCache[tInstanceId] then
						if VUHDO_auraMatchesFilter(aUnit, tInstanceId, tGroup["filter"]) then
							if not tGroup["excludeFilter"] or not VUHDO_auraMatchesFilter(aUnit, tInstanceId, tGroup["excludeFilter"]) then
								sAssignedAuras[tInstanceId] = true;
							else
								VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tSlotIdx, nil);
							end
						else
							VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tSlotIdx, nil);
						end
					else
						VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tSlotIdx, nil);
					end
				end
			end
		end

		if tUnitCache then
			for tInstanceId, tAuraData in pairs(tUnitCache) do
				if not sAssignedAuras[tInstanceId] then
					if VUHDO_auraMatchesFilter(aUnit, tInstanceId, tGroup["filter"]) then
						if not tGroup["excludeFilter"] or not VUHDO_auraMatchesFilter(aUnit, tInstanceId, tGroup["excludeFilter"]) then
							for tSlotIdx = 1, tMaxSlots do
								tAnchorSlots = VUHDO_UNIT_AURA_SLOTS[aUnit] and VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum] and VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum][anAnchorIndex];

								if not (tAnchorSlots and tAnchorSlots[tSlotIdx]) then
									VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tSlotIdx, tInstanceId);

									sAssignedAuras[tInstanceId] = true;

									break;
								end
							end
						end
					end
				end
			end
		end
	else
		tSlotIndex = 0;

		for tClearIdx = 1, tMaxSlots do
			VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tClearIdx, nil);
		end

		if tUnitCache then
			for tInstanceId, tAuraData in pairs(tUnitCache) do
				if VUHDO_auraMatchesFilter(aUnit, tInstanceId, tGroup["filter"]) then
					if not tGroup["excludeFilter"] or not VUHDO_auraMatchesFilter(aUnit, tInstanceId, tGroup["excludeFilter"]) then
						tSlotIndex = tSlotIndex + 1;

						if tSlotIndex <= tMaxSlots then
							VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tSlotIndex, tInstanceId);
						end
					end
				end
			end
		end
	end

	return;

end



--
local tAnchorConfig;
local tGroup;
local tAuras;
local tFilteredAuras;
local tSlotIndex;
local tMaxSlots;
function VUHDO_queryAndCacheAurasForAnchor(aUnit, aPanelNum, anAnchorIndex)

	if not aUnit or not aPanelNum or not anAnchorIndex then
		return;
	end

	tAnchorConfig = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"][anAnchorIndex];

	if not tAnchorConfig then
		return;
	end

	if tAnchorConfig["enabled"] == false then
		VUHDO_clearAurasForAnchor(aUnit, aPanelNum, anAnchorIndex, tAnchorConfig);

		return;
	end

	tGroup = VUHDO_getAuraGroup(tAnchorConfig["groupId"]);

	if not tGroup then
		return;
	end

	tAuras = VUHDO_getFilteredAuras(aUnit, tGroup["filter"], tAnchorConfig["maxDisplay"], tAnchorConfig["sortRule"], tAnchorConfig["sortDir"]);

	if tGroup["excludeFilter"] then
		twipe(sFilteredAuras);

		for _, tAura in ipairs(tAuras) do
			if not VUHDO_auraMatchesFilter(aUnit, tAura["auraInstanceID"], tGroup["excludeFilter"]) then
				tinsert(sFilteredAuras, tAura);
			end
		end

		tAuras = sFilteredAuras;
	end

	tSlotIndex = 0;
	tMaxSlots = tAnchorConfig["maxDisplay"] or 5;

	for _, tAura in ipairs(tAuras) do
		tSlotIndex = tSlotIndex + 1;

		if tSlotIndex <= tMaxSlots then
			VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tSlotIndex, tAura["auraInstanceID"]);
		end
	end

	for tSlotIndex = tSlotIndex + 1, tMaxSlots do
		VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tSlotIndex, nil);
	end

	return;

end



do
	--
	local tSlotCfg;
	local tScaleCounts;
	local tScale;
	local tMaxCount;
	local tMostCommonScale;
	function VUHDO_getMostCommonSlotScale(aHots)

		tSlotCfg = aHots and aHots["SLOTCFG"];

		if not tSlotCfg then
			return 1;
		end

		tScaleCounts = { };
		tMostCommonScale = 1;
		tMaxCount = 0;

		for tSlotNum = 1, 12 do
			tScale = tSlotCfg["" .. tSlotNum] and tSlotCfg["" .. tSlotNum]["scale"] or 1;
			tScaleCounts[tScale] = (tScaleCounts[tScale] or 0) + 1;

			if tScaleCounts[tScale] > tMaxCount then
				tMaxCount = tScaleCounts[tScale];
				tMostCommonScale = tScale;
			end
		end

		return tMostCommonScale;

	end



	--
	local tHots;
	local tAuraAnchors;
	local tRadioValue;
	local tPanelSetup;
	local tOriginalRadioValue;
	local tMostCommonScale;
	local tSizePct;
	local tIconSlotCount;
	local tBarSlotCount;
	local tSlots;
	local tBarsConfig;
	local tIconRadioValue;
	local tStacksRadioValue;
	local tBarColors;
	local tHotsColors;
	local tHotBarsConfig;
	local tIsVertical;
	local tBarsRadioValue;
	function VUHDO_migrateHotsToAuraAnchors(aPanelNum)

		tPanelSetup = _G["VUHDO_PANEL_SETUP"];

		tHots = tPanelSetup and tPanelSetup[aPanelNum] and tPanelSetup[aPanelNum]["HOTS"];
		tAuraAnchors = tPanelSetup and tPanelSetup[aPanelNum] and tPanelSetup[aPanelNum]["AURA_ANCHORS"];

		if not tHots or not tAuraAnchors or not tAuraAnchors["1"] then
			return;
		end

		tRadioValue = tHots["radioValue"];

		if 20 == tRadioValue then
			tRadioValue = 30;
		elseif 21 == tRadioValue then
			tRadioValue = 31;
		end

		tAuraAnchors["1"]["radioValue"] = tRadioValue;
		tAuraAnchors["1"]["fixedSlots"] = true;

		tOriginalRadioValue = tHots["radioValue"];
		tMostCommonScale = VUHDO_getMostCommonSlotScale(tHots);
		tSizePct = (tHots["size"] or 40) * tMostCommonScale;

		if 20 == tOriginalRadioValue or 21 == tOriginalRadioValue then
			tSizePct = tSizePct * 0.5;
		end

		tAuraAnchors["1"]["size"] = floor(tSizePct);

		if tRadioValue <= 14 then
			tAuraAnchors["1"]["growthDir"] = VUHDO_HOTS_RADIOVALUE_GROWTH[tRadioValue] or "RIGHT";
			tAuraAnchors["1"]["wrapDir"] = VUHDO_HOTS_RADIOVALUE_WRAP[tRadioValue] or "DOWN";
		end

		tAuraAnchors["1"]["maxColumns"] = 9;
		tAuraAnchors["1"]["maxRows"] = 1;
		tAuraAnchors["1"]["spacing"] = 0;
		tAuraAnchors["1"]["sortRule"] = 3;

		if tHots["TIMER_TEXT"] then
			tAuraAnchors["1"]["TIMER_TEXT"] = VUHDO_deepCopyTable(tHots["TIMER_TEXT"]);

			if not tAuraAnchors["1"]["TIMER_TEXT"]["COLOR"] then
				tAuraAnchors["1"]["TIMER_TEXT"]["COLOR"] = VUHDO_makeFullColor(0, 0, 0, 1, 1, 1, 1, 1);
			end
		end

		if tHots["COUNTER_TEXT"] then
			tAuraAnchors["1"]["COUNTER_TEXT"] = VUHDO_deepCopyTable(tHots["COUNTER_TEXT"]);

			if not tAuraAnchors["1"]["COUNTER_TEXT"]["COLOR"] then
				tAuraAnchors["1"]["COUNTER_TEXT"]["COLOR"] = VUHDO_makeFullColor(0, 0, 0, 1, 0, 1, 0, 1);
			end
		end

		tIconRadioValue = tHots["iconRadioValue"];

		if tIconRadioValue then
			if tIconRadioValue == 1 then
				tAuraAnchors["1"]["iconType"] = 1;
			elseif tIconRadioValue == 2 then
				tAuraAnchors["1"]["iconType"] = 3;
			elseif tIconRadioValue == 3 then
				tAuraAnchors["1"]["iconType"] = 2;
			elseif tIconRadioValue == 4 then
				tAuraAnchors["1"]["iconType"] = 4;
			end
		end

		tStacksRadioValue = tHots["stacksRadioValue"];

		if tStacksRadioValue then
			if tStacksRadioValue == 1 then
				tAuraAnchors["1"]["showStacks"] = 3;
				tAuraAnchors["1"]["stackType"] = 1;
			elseif tStacksRadioValue == 2 then
				tAuraAnchors["1"]["showStacks"] = 1;
				tAuraAnchors["1"]["stackType"] = 1;
			elseif tStacksRadioValue == 3 then
				tAuraAnchors["1"]["showStacks"] = 1;
				tAuraAnchors["1"]["stackType"] = 2;
			end
		end

		tBarColors = tPanelSetup["BAR_COLORS"];
		tHotsColors = tBarColors and tBarColors["HOTS"];

		if tHotsColors then
			if tHotsColors["isFadeOut"] == true then
				tAuraAnchors["1"]["fadeOnLow"] = 1;
			elseif tHotsColors["isFadeOut"] == false then
				tAuraAnchors["1"]["fadeOnLow"] = 3;
			end

			if tHotsColors["isFlashWhenLow"] == true then
				tAuraAnchors["1"]["flashOnLow"] = 1;
			elseif tHotsColors["isFlashWhenLow"] == false then
				tAuraAnchors["1"]["flashOnLow"] = 3;
			end
		end

		tSlots = tHots["SLOTS"];
		tIconSlotCount = 0;
		tBarSlotCount = 0;

		if tSlots then
			for tSlotNum = 1, 5 do
				if tSlots[tSlotNum] and tSlots[tSlotNum] ~= "" then
					tIconSlotCount = tIconSlotCount + 1;
				end
			end

			for tSlotNum = 6, 8 do
				if tSlots[tSlotNum] and tSlots[tSlotNum] ~= "" then
					tBarSlotCount = tBarSlotCount + 1;
				end
			end
		end

		if tBarSlotCount > tIconSlotCount then
			tAuraAnchors["1"]["style"] = "bars";

			tBarsConfig = tHots["BARS"];

			if tBarsConfig then
				tAuraAnchors["1"]["barWidth"] = 100;
				tAuraAnchors["1"]["barHeight"] = tBarsConfig["width"] or 25;
			end

			tHotBarsConfig = VUHDO_INDICATOR_CONFIG and
				VUHDO_INDICATOR_CONFIG[aPanelNum] and
				VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"] and
				VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["HOT_BARS"];

			tIsVertical = tHotBarsConfig and tHotBarsConfig["vertical"] or false;
			tBarsRadioValue = tBarsConfig and tBarsConfig["radioValue"] or 1;

			if tIsVertical then
				if tBarsRadioValue == 4 then
					tAuraAnchors["1"]["radioValue"] = 21;
					tAuraAnchors["1"]["growthDir"] = "LEFT";
				else
					tAuraAnchors["1"]["radioValue"] = 20;
					tAuraAnchors["1"]["growthDir"] = "RIGHT";
				end
				tAuraAnchors["1"]["maxColumns"] = 1;
				tAuraAnchors["1"]["maxRows"] = 3;
			else
				if tBarsRadioValue == 4 then
					tAuraAnchors["1"]["radioValue"] = 31;
					tAuraAnchors["1"]["growthDir"] = "UP";
				else
					tAuraAnchors["1"]["radioValue"] = 30;
					tAuraAnchors["1"]["growthDir"] = "DOWN";
				end
				tAuraAnchors["1"]["maxColumns"] = 3;
				tAuraAnchors["1"]["maxRows"] = 1;
			end

			tAuraAnchors["1"]["maxDisplay"] = 3;
			tAuraAnchors["1"]["spacing"] = 0;
			tAuraAnchors["1"]["wrapDir"] = tIsVertical and "DOWN" or "RIGHT";

			if tHotBarsConfig then
				tAuraAnchors["1"]["barVertical"] = tHotBarsConfig["vertical"] or false;
				tAuraAnchors["1"]["barTurnAxis"] = tHotBarsConfig["turnAxis"] or false;
				tAuraAnchors["1"]["barInvertGrowth"] = tHotBarsConfig["invertGrowth"] or false;
			end
		else
			tAuraAnchors["1"]["style"] = "icons";
		end

		return;

	end



	--
	local tDebuff;
	local tAuraAnchors;
	local tPoint;
	local tGrowthDir;
	local tWrapDir;
	local tTranslation;
	local tConfig;
	local tPanelSetup;
	function VUHDO_migrateCustomDebuffsToAuraAnchors(aPanelNum)

		tConfig = _G["VUHDO_CONFIG"];
		tPanelSetup = _G["VUHDO_PANEL_SETUP"];

		tDebuff = tConfig and tConfig["CUSTOM_DEBUFF"];
		tAuraAnchors = tPanelSetup and tPanelSetup[aPanelNum] and tPanelSetup[aPanelNum]["AURA_ANCHORS"];

		if not tDebuff or not tAuraAnchors or not tAuraAnchors["2"] then
			return;
		end

		tPoint = tDebuff["point"];
		tGrowthDir = ("TOPLEFT" == tPoint or "BOTTOMLEFT" == tPoint) and "RIGHT" or "LEFT";
		tWrapDir = ("TOPLEFT" == tPoint or "TOPRIGHT" == tPoint) and "DOWN" or "UP";

		tAuraAnchors["2"]["radioValue"] = VUHDO_POINT_TO_RADIOVALUE[tPoint];
		tAuraAnchors["2"]["fixedSlots"] = true;

		tAuraAnchors["2"]["size"] = tDebuff["scale"] and floor(tDebuff["scale"] * 70) or 40;

		tTranslation = VUHDO_DEBUFF_OFFSET_TRANSLATION[tPoint] or sEmpty;
		tAuraAnchors["2"]["offsetX"] = (tDebuff["xAdjust"] or -2) + (tTranslation["x"] or 0);
		tAuraAnchors["2"]["offsetY"] = (tDebuff["yAdjust"] or -34) + (tTranslation["y"] or 0);

		tAuraAnchors["2"]["maxDisplay"] = tDebuff["max_num"] or 3;
		tAuraAnchors["2"]["growthDir"] = tGrowthDir;
		tAuraAnchors["2"]["wrapDir"] = tWrapDir;
		tAuraAnchors["2"]["maxColumns"] = tDebuff["max_num"] or 3;
		tAuraAnchors["2"]["maxRows"] = 1;
		tAuraAnchors["2"]["spacing"] = 0;

		if tDebuff["TIMER_TEXT"] then
			tAuraAnchors["2"]["TIMER_TEXT"] = VUHDO_deepCopyTable(tDebuff["TIMER_TEXT"]);

			if not tAuraAnchors["2"]["TIMER_TEXT"]["COLOR"] then
				tAuraAnchors["2"]["TIMER_TEXT"]["COLOR"] = VUHDO_makeFullColor(0, 0, 0, 1, 1, 1, 1, 1);
			end
		end

		if tDebuff["COUNTER_TEXT"] then
			tAuraAnchors["2"]["COUNTER_TEXT"] = VUHDO_deepCopyTable(tDebuff["COUNTER_TEXT"]);

			if not tAuraAnchors["2"]["COUNTER_TEXT"]["COLOR"] then
				tAuraAnchors["2"]["COUNTER_TEXT"]["COLOR"] = VUHDO_makeFullColor(0, 0, 0, 1, 0, 1, 0, 1);
			end
		end

		return;

	end



	--
	local tPanelSetup;
	function VUHDO_migrateOldConfigsToAuraAnchors()

		tPanelSetup = _G["VUHDO_PANEL_SETUP"];

		if (tPanelSetup["AURA_MIGRATION_VERSION"] or 0) >= VUHDO_AURA_MIGRATION_VERSION then
			return;
		end

		for tPanelNum = 1, 10 do
			VUHDO_migrateHotsToAuraAnchors(tPanelNum);
			VUHDO_migrateCustomDebuffsToAuraAnchors(tPanelNum);
		end

		tPanelSetup["AURA_MIGRATION_VERSION"] = VUHDO_AURA_MIGRATION_VERSION;

		return;

	end



	--
	function VUHDO_resetAndRemigrateAuras()

		tPanelSetup = _G["VUHDO_PANEL_SETUP"];

		for tPanelNum = 1, VUHDO_MAX_PANELS do
			tPanelSetup[tPanelNum]["AURA_ANCHORS"] = nil;
		end

		tPanelSetup["AURA_MIGRATION_VERSION"] = nil;

		VUHDO_loadDefaultPanelSetup();
		VUHDO_reloadUI(false);

		VUHDO_Msg("Aura migration complete.");

		return;

	end



	--
	function VUHDO_auraHelp()

		VUHDO_Msg("|cffFFD100--- Aura Commands ---|r");
		VUHDO_Msg("  |cffB0E0E6/vd aura migrate|r - Re-run aura configuration migration");
		VUHDO_Msg("  |cffB0E0E6/vd aura|r - Show this help");
		VUHDO_Msg("|cffFFD100--- End of Aura Commands ---|r");

		return;

	end
end