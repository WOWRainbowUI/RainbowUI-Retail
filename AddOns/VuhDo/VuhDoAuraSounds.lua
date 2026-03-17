local _;

local pairs = pairs;
local ipairs = ipairs;
local GetTime = GetTime;
local UnitIsUnit = UnitIsUnit;
local issecretvalue = issecretvalue;

local VUHDO_CONFIG;
local VUHDO_AURA_GROUPS;
local VUHDO_DEFAULT_AURA_GROUPS;
local VUHDO_AURA_GROUP_TYPE_FILTER;
local VUHDO_AURA_GROUP_TYPE_LIST;
local VUHDO_AURA_LIST_ENTRY_SPELL;

local VUHDO_getAuraGroup;
local VUHDO_getAllAuraGroups;
local VUHDO_auraMatchesFilter;
local VUHDO_isAuraIgnored;
local VUHDO_playSoundFile;

local sNextSoundTime = { };



--
function VUHDO_auraSoundsInitLocalOverrides()

	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_AURA_GROUPS = VUHDO_CONFIG and VUHDO_CONFIG["AURA_GROUPS"];

	VUHDO_DEFAULT_AURA_GROUPS = _G["VUHDO_DEFAULT_AURA_GROUPS"];
	VUHDO_AURA_GROUP_TYPE_FILTER = _G["VUHDO_AURA_GROUP_TYPE_FILTER"];
	VUHDO_AURA_GROUP_TYPE_LIST = _G["VUHDO_AURA_GROUP_TYPE_LIST"];
	VUHDO_AURA_LIST_ENTRY_SPELL = _G["VUHDO_AURA_LIST_ENTRY_SPELL"];

	VUHDO_getAuraGroup = _G["VUHDO_getAuraGroup"];
	VUHDO_getAllAuraGroups = _G["VUHDO_getAllAuraGroups"];
	VUHDO_auraMatchesFilter = _G["VUHDO_auraMatchesFilter"];
	VUHDO_isAuraIgnored = _G["VUHDO_isAuraIgnored"];
	VUHDO_playSoundFile = _G["VUHDO_playSoundFile"];

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
local tSourceUnit;
local tIsPlayer;
local tMatchesMine;
local tMatchesOthers;
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

	tSourceUnit = anAuraData["sourceUnit"];

	if issecretvalue(tSourceUnit) then
		tIsPlayer = false;
	else
		tIsPlayer = UnitIsUnit(tSourceUnit or "", "player");
	end

	for _, tEntry in ipairs(tEntries) do
		if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
			tValue = tEntry["value"];

			if tValue == tSpellId or tValue == tName then
				tMatchesMine = tEntry["mine"];
				tMatchesOthers = tEntry["others"];

				if tMatchesMine and tMatchesOthers then
					return true;
				end

				if tMatchesMine and tIsPlayer then
					return true;
				end

				if tMatchesOthers and not tIsPlayer then
					return true;
				end
			end
		end
	end

	return false;

end



--
local tAllGroups;
local tGroupType;
local tSound;
function VUHDO_checkAuraGroupSounds(aUnit, anAuraData)

	if not aUnit or not anAuraData then
		return;
	end

	if _G["VUHDO_IS_CONFIG"] then
		return;
	end

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
					if tGroup["filter"] and VUHDO_auraMatchesFilter(aUnit, anAuraData["auraInstanceID"], tGroup["filter"]) then
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