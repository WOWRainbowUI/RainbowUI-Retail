local _;

local pairs = pairs;
local ipairs = ipairs;
local twipe = table.wipe;
local tinsert = table.insert;

local GetTime = GetTime;
local InCombatLockdown = InCombatLockdown;
local issecretvalue = issecretvalue;

local AddAuraSound = C_UnitAuras and C_UnitAuras.AddAuraSound;
local RemoveAuraSound = C_UnitAuras and C_UnitAuras.RemoveAuraSound;
local IsAddOnRestrictionActive = C_RestrictedActions and C_RestrictedActions.IsAddOnRestrictionActive;
local AddOnRestrictionType = Enum and Enum.AddOnRestrictionType;
local UnitAuraSoundTrigger = Enum and Enum.UnitAuraSoundTrigger;
local UnitAuraSoundTriggerAdded = UnitAuraSoundTrigger and UnitAuraSoundTrigger["Added"];

local VUHDO_CONFIG;
local VUHDO_RAID;
local VUHDO_AURA_GROUPS;
local VUHDO_DEFAULT_AURA_GROUPS;
local VUHDO_AURA_GROUP_TYPE_FILTER;
local VUHDO_AURA_GROUP_TYPE_LIST;
local VUHDO_AURA_LIST_ENTRY_SPELL;

local VUHDO_getAuraGroup;
local VUHDO_getAllAuraGroups;
local VUHDO_isAuraMatchingGroupFilters;
local VUHDO_auraSourceMatchesFilter;
local VUHDO_playSoundFile;
local VUHDO_addResolvedAuraContainerSpellIds;
local VUHDO_isAuraModeContainers;

local sNextSoundTime = { };
local sNativeAuraSoundIds = { };
local sNativeAuraSoundUnits = { };
local sPendingNativeAuraSoundUnits = { };
local sPendingNativeAuraSoundRetry = { };
local sPendingNativeAuraSoundClear = false;
local sSoundEnabledAuraGroups = { };
local sHasNativeAuraSoundsToRegister = nil;
local sNativeResolvedSpellIds = { };



--
function VUHDO_auraSoundsInitLocalOverrides()

	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_AURA_GROUPS = VUHDO_CONFIG and VUHDO_CONFIG["AURA_GROUPS"];

	VUHDO_DEFAULT_AURA_GROUPS = _G["VUHDO_DEFAULT_AURA_GROUPS"];
	VUHDO_AURA_GROUP_TYPE_FILTER = _G["VUHDO_AURA_GROUP_TYPE_FILTER"];
	VUHDO_AURA_GROUP_TYPE_LIST = _G["VUHDO_AURA_GROUP_TYPE_LIST"];
	VUHDO_AURA_LIST_ENTRY_SPELL = _G["VUHDO_AURA_LIST_ENTRY_SPELL"];

	VUHDO_getAuraGroup = _G["VUHDO_getAuraGroup"];
	VUHDO_getAllAuraGroups = _G["VUHDO_getAllAuraGroups"];
	VUHDO_isAuraMatchingGroupFilters = _G["VUHDO_isAuraMatchingGroupFilters"];
	VUHDO_auraSourceMatchesFilter = _G["VUHDO_auraSourceMatchesFilter"];
	VUHDO_playSoundFile = _G["VUHDO_playSoundFile"];
	VUHDO_addResolvedAuraContainerSpellIds = _G["VUHDO_addResolvedAuraContainerSpellIds"];
	VUHDO_isAuraModeContainers = _G["VUHDO_isAuraModeContainers"];

	return;

end



--
function VUHDO_isNativeAuraSoundRestricted()

	if IsAddOnRestrictionActive then
		if IsAddOnRestrictionActive(AddOnRestrictionType and AddOnRestrictionType["Encounter"] or 1) then
			return true;
		end

		if IsAddOnRestrictionActive(AddOnRestrictionType and AddOnRestrictionType["Combat"] or 0)
			and IsAddOnRestrictionActive(AddOnRestrictionType and AddOnRestrictionType["ChallengeMode"] or 2) then
			return true;
		end
	end

	return false;

end



--
local tAllGroups;
local tSound;
local tGroupType;
local tEntries;
local tEntry;
local function VUHDO_listGroupHasNativeAuraSoundSpellIds(aGroup)

	if not aGroup then
		return false;
	end

	twipe(sNativeResolvedSpellIds);
	tEntries = aGroup["entries"];

	if not tEntries then
		return false;
	end

	for tCnt = 1, #tEntries do
		tEntry = tEntries[tCnt];

		if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
			VUHDO_addResolvedAuraContainerSpellIds(sNativeResolvedSpellIds, tEntry["value"]);
		end
	end

	return next(sNativeResolvedSpellIds) ~= nil;

end



--
function VUHDO_computeHasNativeAuraSoundsToRegister()

	tAllGroups = VUHDO_getAllAuraGroups();

	if not tAllGroups then
		return false;
	end

	for tGroupId, tGroup in pairs(tAllGroups) do
		if VUHDO_getAuraGroup(tGroupId) then
			tSound = tGroup["sound"];

			if (tSound or "") ~= "" then
				tGroupType = tGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER;

				if tGroupType == VUHDO_AURA_GROUP_TYPE_LIST and VUHDO_listGroupHasNativeAuraSoundSpellIds(tGroup) then
					return true;
				end
			end
		end
	end

	return false;

end



--
function VUHDO_invalidateNativeAuraSoundScanCache()

	sHasNativeAuraSoundsToRegister = nil;

	return;

end



--
function VUHDO_clearNativeAuraSounds()

	if InCombatLockdown() or VUHDO_isNativeAuraSoundRestricted() then
		sPendingNativeAuraSoundClear = true;

		return;
	end

	for tSoundId, _ in pairs(sNativeAuraSoundIds) do
		RemoveAuraSound(tSoundId);
	end

	twipe(sNativeAuraSoundIds);
	twipe(sNativeAuraSoundUnits);
	twipe(sPendingNativeAuraSoundUnits);

	sPendingNativeAuraSoundClear = false;

	return;

end



--
local tSoundId;
local tSoundInfo;
function VUHDO_registerNativeAuraSoundForUnit(aUnit, aSpellId, aSoundKey)

	if not aUnit or not aSpellId or aSoundKey == nil or aSoundKey == "" then
		return false;
	end

	if InCombatLockdown() or VUHDO_isNativeAuraSoundRestricted() then
		sPendingNativeAuraSoundUnits[aUnit] = true;

		return false;
	end

	if not UnitAuraSoundTriggerAdded then
		return false;
	end

	tSoundInfo = {
		["unitToken"] = aUnit,
		["spellID"] = aSpellId,
	};

	if type(aSoundKey) == "number" then
		tSoundInfo["soundFileID"] = aSoundKey;
	elseif type(aSoundKey) == "string" then
		tSoundInfo["soundFileName"] = aSoundKey;
	else
		return false;
	end

	tSoundId = AddAuraSound(UnitAuraSoundTriggerAdded, tSoundInfo);

	if tSoundId then
		sNativeAuraSoundIds[tSoundId] = true;

		return true;
	end

	return false;

end



--
function VUHDO_rebuildSoundEnabledAuraGroups()

	twipe(sSoundEnabledAuraGroups);

	tAllGroups = VUHDO_getAllAuraGroups();

	if not tAllGroups then
		return;
	end

	for tGroupId, tGroup in pairs(tAllGroups) do
		if VUHDO_getAuraGroup(tGroupId) then
			tSound = tGroup["sound"];

			if (tSound or "") ~= "" then
				tGroupType = tGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER;

				if tGroupType == VUHDO_AURA_GROUP_TYPE_FILTER then
					tinsert(sSoundEnabledAuraGroups, tGroupId);
				elseif tGroupType == VUHDO_AURA_GROUP_TYPE_LIST then
					if not VUHDO_listGroupHasNativeAuraSoundSpellIds(tGroup) then
						tinsert(sSoundEnabledAuraGroups, tGroupId);
					end
				end
			end
		end
	end

	return;

end



--
local tRegistrationFailed;
function VUHDO_syncNativeAuraSoundsForUnit(aUnit)

	if not VUHDO_isAuraModeContainers() or not aUnit then
		return true;
	end

	if sNativeAuraSoundUnits[aUnit] then
		return true;
	end

	if sHasNativeAuraSoundsToRegister == nil then
		sHasNativeAuraSoundsToRegister = VUHDO_computeHasNativeAuraSoundsToRegister();
	end

	if not sHasNativeAuraSoundsToRegister then
		sNativeAuraSoundUnits[aUnit] = true;

		return true;
	end

	if InCombatLockdown() or VUHDO_isNativeAuraSoundRestricted() then
		sPendingNativeAuraSoundUnits[aUnit] = true;

		return false;
	end

	tAllGroups = VUHDO_getAllAuraGroups();
	tRegistrationFailed = false;

	if tAllGroups then
		for tGroupId, tGroup in pairs(tAllGroups) do
			if VUHDO_getAuraGroup(tGroupId) then
				tSound = tGroup["sound"];

				if (tSound or "") ~= "" then
					tGroupType = tGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER;

					if tGroupType == VUHDO_AURA_GROUP_TYPE_LIST then
						twipe(sNativeResolvedSpellIds);
						tEntries = tGroup["entries"];

						if tEntries then
							for tCnt = 1, #tEntries do
								tEntry = tEntries[tCnt];

								if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
									VUHDO_addResolvedAuraContainerSpellIds(sNativeResolvedSpellIds, tEntry["value"]);
								end
							end
						end

						for tSpellId, _ in pairs(sNativeResolvedSpellIds) do
							if not VUHDO_registerNativeAuraSoundForUnit(aUnit, tSpellId, tSound) then
								tRegistrationFailed = true;
							end
						end
					end
				end
			end
		end
	end

	if tRegistrationFailed then
		sPendingNativeAuraSoundUnits[aUnit] = true;

		return false;
	end

	sNativeAuraSoundUnits[aUnit] = true;

	return true;

end



--
function VUHDO_processPendingNativeAuraSounds()

	if InCombatLockdown() or VUHDO_isNativeAuraSoundRestricted() then
		return;
	end

	if sPendingNativeAuraSoundClear then
		VUHDO_clearNativeAuraSounds();

		if VUHDO_isAuraModeContainers() then
			VUHDO_initNativeAuraSounds();
		end

		return;
	end

	twipe(sPendingNativeAuraSoundRetry);

	for tUnit, _ in pairs(sPendingNativeAuraSoundUnits) do
		if not VUHDO_syncNativeAuraSoundsForUnit(tUnit) then
			sPendingNativeAuraSoundRetry[tUnit] = true;
		end
	end

	twipe(sPendingNativeAuraSoundUnits);

	for tUnit, _ in pairs(sPendingNativeAuraSoundRetry) do
		sPendingNativeAuraSoundUnits[tUnit] = true;
	end

	twipe(sPendingNativeAuraSoundRetry);

	return;

end



--
function VUHDO_initNativeAuraSounds()

	if not VUHDO_isAuraModeContainers() then
		return;
	end

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_syncNativeAuraSoundsForUnit(tUnit);
	end

	return;

end



--
local tGroup;
local tSound;
local tSuccess;
function VUHDO_playAuraGroupSound(aGroupId)

	if not aGroupId then
		return;
	end

	if _G["VUHDO_IS_CONFIG"] then
		return;
	end

	tGroup = VUHDO_AURA_GROUPS and VUHDO_AURA_GROUPS[aGroupId];

	if not tGroup then
		tGroup = VUHDO_DEFAULT_AURA_GROUPS and VUHDO_DEFAULT_AURA_GROUPS[aGroupId];
	end

	if not tGroup then
		return;
	end

	tSound = tGroup["sound"];

	if (tSound or "") == "" then
		return;
	end

	if GetTime() < (sNextSoundTime[aGroupId] or 0) then
		return;
	end

	tSuccess = VUHDO_playSoundFile(tSound);

	if tSuccess then
		sNextSoundTime[aGroupId] = GetTime() + 2;
	end

	return;

end



--
local tValue;
local tSpellId;
local tName;
local function VUHDO_auraMatchesListGroup(anAuraData, aGroup)

	if not anAuraData or not aGroup then
		return false;
	end

	tEntries = aGroup["entries"];

	if not tEntries then
		return false;
	end

	tSpellId = anAuraData["spellId"];
	tName = anAuraData["name"];

	if tName and issecretvalue(tName) then
		tName = nil;
	end

	for _, tEntry in ipairs(tEntries) do
		if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
			tValue = tEntry["value"];

			if tValue == tSpellId or tValue == tName then
				if VUHDO_auraSourceMatchesFilter(anAuraData, tEntry) then
					return true;
				end
			end
		end
	end

	return false;

end



--
local tGroupId;
local tGroup;
local tGroupType;
local tSound;
function VUHDO_checkAuraGroupSounds(aUnit, anAuraData)

	if not aUnit or not anAuraData then
		return;
	end

	if _G["VUHDO_IS_CONFIG"] then
		return;
	end

	for tCnt = 1, #sSoundEnabledAuraGroups do
		tGroupId = sSoundEnabledAuraGroups[tCnt];
		tGroup = VUHDO_getAuraGroup(tGroupId);

		if tGroup then
			tSound = tGroup["sound"];

			if (tSound or "") ~= "" then
				tGroupType = tGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER;

				if tGroupType == VUHDO_AURA_GROUP_TYPE_FILTER then
					if tGroup["filter"] and VUHDO_isAuraMatchingGroupFilters(aUnit, tGroupId, tGroup, anAuraData) then
						VUHDO_playAuraGroupSound(tGroupId);
					end
				elseif tGroupType == VUHDO_AURA_GROUP_TYPE_LIST then
					if VUHDO_auraMatchesListGroup(anAuraData, tGroup) then
						VUHDO_playAuraGroupSound(tGroupId);
					end
				end
			end
		end
	end

	return;

end