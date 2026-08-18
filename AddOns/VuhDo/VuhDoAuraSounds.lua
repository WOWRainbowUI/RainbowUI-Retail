local _;

local pairs = pairs;
local ipairs = ipairs;
local twipe = table.wipe;
local tinsert = table.insert;

local GetTime = GetTime;
local InCombatLockdown = InCombatLockdown;
local issecretvalue = issecretvalue;

local AddAuraSound = (C_UnitAuras and C_UnitAuras.AddAuraSound) or function() return nil; end;
local RemoveAuraSound = (C_UnitAuras and C_UnitAuras.RemoveAuraSound) or function() end;
local UnitAuraSoundTriggerAdded = Enum.UnitAuraSoundTrigger and Enum.UnitAuraSoundTrigger.Added;

local VUHDO_CONFIG;
local VUHDO_RAID;
local VUHDO_AURA_GROUPS;
local VUHDO_DEFAULT_AURA_GROUPS;
local VUHDO_AURA_GROUP_TYPE_FILTER;
local VUHDO_AURA_GROUP_TYPE_LIST;
local VUHDO_AURA_LIST_ENTRY_SPELL;

local VUHDO_getAuraGroup;
local VUHDO_getAllAuraGroups;
local VUHDO_auraMatchesFilter;
local VUHDO_auraSourceMatchesFilter;
local VUHDO_isAuraIgnored;
local VUHDO_playSoundFile;
local VUHDO_addResolvedAuraContainerSpellIds;
local VUHDO_isAuraModeContainers;
local VUHDO_LibSharedMedia;

local sNextSoundTime = { };
local sNativeAuraSoundIds = { };
local sNativeAuraSoundUnits = { };
local sPendingNativeAuraSoundUnits = { };
local sPendingNativeAuraSoundClear = false;
local sSoundEnabledAuraGroups = { };



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
	VUHDO_auraMatchesFilter = _G["VUHDO_auraMatchesFilter"];
	VUHDO_auraSourceMatchesFilter = _G["VUHDO_auraSourceMatchesFilter"];
	VUHDO_isAuraIgnored = _G["VUHDO_isAuraIgnored"];
	VUHDO_playSoundFile = _G["VUHDO_playSoundFile"];
	VUHDO_addResolvedAuraContainerSpellIds = _G["VUHDO_addResolvedAuraContainerSpellIds"];
	VUHDO_isAuraModeContainers = _G["VUHDO_isAuraModeContainers"];
	VUHDO_LibSharedMedia = _G["VUHDO_LibSharedMedia"];

	return;

end



--
function VUHDO_clearNativeAuraSounds()

	if InCombatLockdown() then
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
local tSoundPath;
local tSoundId;
local tSettings;
local tSpellId;
local tResolvedSpellIds;
function VUHDO_registerNativeAuraSoundForUnit(aUnit, aSpellId, aSoundKey)

	if not aUnit or not aSpellId or not aSoundKey or aSoundKey == "" then
		return;
	end

	if InCombatLockdown() then
		return;
	end

	if VUHDO_LibSharedMedia then
		tSoundPath = VUHDO_LibSharedMedia:Fetch("sound", aSoundKey);
	else
		tSoundPath = aSoundKey;
	end

	if not tSoundPath or tSoundPath == "" then
		return;
	end

	tSoundId = AddAuraSound(UnitAuraSoundTriggerAdded, {
		["unitToken"] = aUnit,
		["spellID"] = aSpellId,
		["soundFileName"] = tSoundPath,
	});

	if tSoundId then
		sNativeAuraSoundIds[tSoundId] = true;
	end

	return;

end



--
local tAllGroups;
local tGroup;
local tSound;
local tGroupType;
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

				if tGroupType == VUHDO_AURA_GROUP_TYPE_FILTER or tGroupType == VUHDO_AURA_GROUP_TYPE_LIST then
					tinsert(sSoundEnabledAuraGroups, tGroupId);
				end
			end
		end
	end

	return;

end



--
local tDefaultSound;
local tHasSoundsToRegister;
function VUHDO_syncNativeAuraSoundsForUnit(aUnit)

	if not VUHDO_isAuraModeContainers() or not aUnit then
		return;
	end

	if sNativeAuraSoundUnits[aUnit] then
		return;
	end

	if not VUHDO_CONFIG or not VUHDO_CONFIG["CUSTOM_DEBUFF"] then
		sNativeAuraSoundUnits[aUnit] = true;

		return;
	end

	tDefaultSound = VUHDO_CONFIG["CUSTOM_DEBUFF"]["SOUND"];
	tSettings = VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"];
	tHasSoundsToRegister = false;

	if tSettings then
		for tSettingsKey, tDebuffSettings in pairs(tSettings) do
			tResolvedSpellIds = { };

			VUHDO_addResolvedAuraContainerSpellIds(tResolvedSpellIds, tSettingsKey);

			if next(tResolvedSpellIds) and ((tDebuffSettings["SOUND"] or "") ~= "" or (tDefaultSound or "") ~= "") then
				tHasSoundsToRegister = true;

				break;
			end
		end
	end

	if not tHasSoundsToRegister then
		sNativeAuraSoundUnits[aUnit] = true;

		return;
	end

	if InCombatLockdown() then
		sPendingNativeAuraSoundUnits[aUnit] = true;

		return;
	end

	if tSettings then
		for tSettingsKey, tDebuffSettings in pairs(tSettings) do
			tResolvedSpellIds = { };

			VUHDO_addResolvedAuraContainerSpellIds(tResolvedSpellIds, tSettingsKey);

			for tSpellId, _ in pairs(tResolvedSpellIds) do
				if tDebuffSettings["SOUND"] and tDebuffSettings["SOUND"] ~= "" then
					VUHDO_registerNativeAuraSoundForUnit(aUnit, tSpellId, tDebuffSettings["SOUND"]);
				elseif tDefaultSound and tDefaultSound ~= "" then
					VUHDO_registerNativeAuraSoundForUnit(aUnit, tSpellId, tDefaultSound);
				end
			end
		end
	end

	sNativeAuraSoundUnits[aUnit] = true;

	return;

end



--
function VUHDO_processPendingNativeAuraSounds()

	if InCombatLockdown() then
		return;
	end

	if sPendingNativeAuraSoundClear then
		VUHDO_clearNativeAuraSounds();

		if VUHDO_isAuraModeContainers() then
			VUHDO_initNativeAuraSounds();
		end

		return;
	end

	for tUnit, _ in pairs(sPendingNativeAuraSoundUnits) do
		VUHDO_syncNativeAuraSoundsForUnit(tUnit);
	end

	twipe(sPendingNativeAuraSoundUnits);

	return;

end



--
local tUnit;
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
local tEntries;
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
					if tGroup["filter"] and VUHDO_auraMatchesFilter(aUnit, anAuraData["auraInstanceID"], tGroup["resolvedFilter"]) then
						if (not tGroup["excludeFilter"] or not VUHDO_auraMatchesFilter(aUnit, anAuraData["auraInstanceID"], tGroup["excludeFilter"]))
							and not VUHDO_isAuraIgnored(anAuraData, tGroupId) then
							VUHDO_playAuraGroupSound(tGroupId);
						end
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