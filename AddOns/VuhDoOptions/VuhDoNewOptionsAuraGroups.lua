local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local tremove = table.remove;
local tsort = table.sort;
local twipe = table.wipe;
local format = string.format;
local strsplit = strsplit;
local strupper = string.upper;
local strfind = string.find;
local strsub = string.sub;
local tconcat = table.concat;
local SecondsToTime = SecondsToTime;

VUHDO_AURA_GROUPS_SELECTED = nil;
VUHDO_AURA_GROUPS_PENDING_SELECTION = nil;
VUHDO_AURA_GROUPS_COMBO_MODEL = { };
VUHDO_PANEL_AURA_GROUPS_COMBO_MODEL = { };
VUHDO_AURA_GROUPS_TYPE_SELECTED = 1;
VUHDO_AURA_GROUPS_PRIORITY = 50;
VUHDO_AURA_GROUPS_COLOR_TYPE = 1;
VUHDO_AURA_GROUPS_SHOW_ON = 1;

VUHDO_AURA_GROUPS_CUSTOM_COLOR = {
	["R"] = 0.6,
	["G"] = 0.3,
	["B"] = 0,
	["O"] = 1,
	["TR"] = 0.8,
	["TG"] = 0.5,
	["TB"] = 0,
	["TO"] = 1,
	["useBackground"] = true,
	["useText"] = true,
	["useOpacity"] = true,
};

VUHDO_AURA_GROUPS_CAN_COLOR_BAR = false;
VUHDO_AURA_GROUPS_CAN_COLOR_TEXT = false;
VUHDO_AURA_GROUPS_CAN_GLOW_BAR = false;
VUHDO_AURA_GROUPS_GLOW_BAR_STYLE = "none";
VUHDO_AURA_GROUPS_SOUND = nil;
VUHDO_AURA_GROUPS_ENABLED = true;
VUHDO_AURA_GROUPS_IGNORE_COMBO_MODEL = { };
VUHDO_AURA_GROUPS_IGNORE_SELECTED = "";

VUHDO_AURA_GROUPS_AURAS_SELECTED = "HARMFUL";
VUHDO_AURA_GROUPS_PRESET_SELECTED = "";
VUHDO_AURA_GROUPS_DURATION_SELECTED = VUHDO_AURA_DURATION_COMBO_NONE;

VUHDO_AURA_GROUPS_CONDITIONS = {
	["matchAny"] = { },
	["matchAll"] = { },
	["neverShow"] = { },
	["excludeDispel"] = { },
};

VUHDO_AURA_AURAS_OPTIONS = {
	{ "HELPFUL", VUHDO_I18N_AURA_GROUP_ALL_BUFFS },
	{ "HARMFUL", VUHDO_I18N_AURA_GROUP_ALL_DEBUFFS },
};

VUHDO_AURA_PRESET_OPTIONS = { };
VUHDO_AURA_CONDITION_COMBO_MODEL = { };
VUHDO_AURA_DURATION_OPTIONS = { };
VUHDO_AURA_EXCLUDE_DISPEL_OPTIONS = {
	{ "Magic", VUHDO_I18N_MAGIC, nil, nil, VUHDO_I18N_TT.K891 },
	{ "Curse", VUHDO_I18N_CURSE, nil, nil, VUHDO_I18N_TT.K892 },
	{ "Disease", VUHDO_I18N_DISEASE, nil, nil, VUHDO_I18N_TT.K893 },
	{ "Poison", VUHDO_I18N_POISON, nil, nil, VUHDO_I18N_TT.K894 },
	{ "Bleed", VUHDO_I18N_BLEED, nil, nil, VUHDO_I18N_TT.K895 },
	{ "Enrage", VUHDO_I18N_ENRAGE, nil, nil, VUHDO_I18N_TT.K897 },
};

VUHDO_AURA_GROUPS_ADD_SPELL_SELECTED = "";
VUHDO_AURA_GROUPS_ADD_SPELL_COMBO_MODEL = { };

VUHDO_SPELL_ENTRY_MINE = true;
VUHDO_SPELL_ENTRY_OTHERS = false;
VUHDO_SPELL_ENTRY_DURATION_MODE = VUHDO_SPELL_DURATION_MODE_THRESHOLD;
VUHDO_SPELL_ENTRY_TIMER_THRESHOLD = 10;
VUHDO_SPELL_ENTRY_GLOW_STYLE = "none";

VUHDO_GLOW_STYLE_COMBO_MODEL = { };
local VUHDO_GLOW_STYLE_COMBO_MODEL = VUHDO_GLOW_STYLE_COMBO_MODEL;

VUHDO_AURA_GLOW_STYLE_DISPLAY_NAMES = {
	["blizzard"] = VUHDO_I18N_GLOW_STYLE_BLIZZARD,
	["blizzardants"] = VUHDO_I18N_GLOW_STYLE_BLIZZARD_ANTS,
	["blizzardblue"] = VUHDO_I18N_GLOW_STYLE_BLIZZARD_BLUE,
	["vuhdopixel"] = VUHDO_I18N_GLOW_STYLE_PIXEL,
	["vuhdohalo"] = VUHDO_I18N_GLOW_STYLE_HALO,
	["vuhdoants"] = VUHDO_I18N_GLOW_STYLE_ANTS,
	["vuhdospark"] = VUHDO_I18N_GLOW_STYLE_SPARK,
	["vuhdocomet"] = VUHDO_I18N_GLOW_STYLE_COMET,
	["vuhdopulse"] = VUHDO_I18N_GLOW_STYLE_PULSE,
	["vuhdowave"] = VUHDO_I18N_GLOW_STYLE_WAVE,
	["vuhdoswirl"] = VUHDO_I18N_GLOW_STYLE_SWIRL,
	["vuhdorays"] = VUHDO_I18N_GLOW_STYLE_RAYS,
	["vuhdoreticle"] = VUHDO_I18N_GLOW_STYLE_RETICLE,
	["vuhdoripple"] = VUHDO_I18N_GLOW_STYLE_RIPPLE,
	["vuhdoembers"] = VUHDO_I18N_GLOW_STYLE_EMBERS,
};
local VUHDO_AURA_GLOW_STYLE_DISPLAY_NAMES = VUHDO_AURA_GLOW_STYLE_DISPLAY_NAMES;

VUHDO_SPELL_ENTRY_SETTINGS = { };
local VUHDO_SPELL_ENTRY_SETTINGS = VUHDO_SPELL_ENTRY_SETTINGS;

VUHDO_SPELL_ENTRY_COLOR_ICON = false;
VUHDO_SPELL_ENTRY_SHOW_TIMER = 2;
VUHDO_SPELL_ENTRY_SHOW_STACKS = 2;
VUHDO_SPELL_ENTRY_SHOW_CLOCK = 2;
VUHDO_SPELL_ENTRY_FADE_ON_LOW = 2;
VUHDO_SPELL_ENTRY_FADE_THRESHOLD = 3;
VUHDO_SPELL_ENTRY_FLASH_ON_LOW = 2;
VUHDO_SPELL_ENTRY_FLASH_THRESHOLD = 2;

VUHDO_AURA_FILTER_OPTIONS = {
	{ "HELPFUL", VUHDO_I18N_AURA_GROUP_ALL_BUFFS, nil, nil, VUHDO_I18N_TT.K635 },
	{ "HARMFUL", VUHDO_I18N_AURA_GROUP_ALL_DEBUFFS, nil, nil, VUHDO_I18N_TT.K636 },
	{ "HELPFUL|PLAYER|RAID_IN_COMBAT", VUHDO_I18N_AURA_GROUP_MY_HOTS, nil, nil, VUHDO_I18N_TT.K637 },
	{ "HELPFUL|RAID_IN_COMBAT", VUHDO_I18N_AURA_GROUP_ALL_HOTS, nil, nil, VUHDO_I18N_TT.K638 },
	{ "HARMFUL|RAID_PLAYER_DISPELLABLE", VUHDO_I18N_AURA_FILTER_HARMFUL_DISPELLABLE, nil, nil, VUHDO_I18N_TT.K639 },
	{ "HARMFUL|DISPELLABLE", VUHDO_I18N_AURA_FILTER_HARMFUL_ALL_DISPELLABLE, nil, nil, VUHDO_I18N_TT.K826 },
	{ "HARMFUL|CROWD_CONTROL", VUHDO_I18N_AURA_GROUP_CC, nil, nil, VUHDO_I18N_TT.K640 },
	{ "HELPFUL|BIG_DEFENSIVE", VUHDO_I18N_AURA_GROUP_BIG_DEF, nil, nil, VUHDO_I18N_TT.K641 },
	{ "HELPFUL|EXTERNAL_DEFENSIVE", VUHDO_I18N_AURA_GROUP_EXTERNAL_DEF, nil, nil, VUHDO_I18N_TT.K642 },
	{ "HELPFUL|PLAYER", VUHDO_I18N_AURA_FILTER_HELPFUL_PLAYER, nil, nil, VUHDO_I18N_TT.K842 },
	{ "HELPFUL|RAID|PLAYER", VUHDO_I18N_AURA_GROUP_MY_BUFFS, nil, nil, VUHDO_I18N_TT.K643 },
	{ "HELPFUL|RAID", VUHDO_I18N_AURA_GROUP_ALL_RAID_BUFFS, nil, nil, VUHDO_I18N_TT.K644 },
	{ "HARMFUL|RAID", VUHDO_I18N_AURA_GROUP_RAID_DEBUFFS, nil, nil, VUHDO_I18N_TT.K645 },
	{ "HELPFUL|IMPORTANT", VUHDO_I18N_AURA_GROUP_IMPORTANT_BUFFS, nil, nil, VUHDO_I18N_TT.K646 },
	{ "HARMFUL|IMPORTANT", VUHDO_I18N_AURA_GROUP_IMPORTANT_DEBUFFS, nil, nil, VUHDO_I18N_TT.K647 },
	{ "HELPFUL|CANCELABLE", VUHDO_I18N_AURA_GROUP_CANCELABLE, nil, nil, VUHDO_I18N_TT.K648 },
	{ "HELPFUL|!CANCELABLE", VUHDO_I18N_AURA_GROUP_NOT_CANCELABLE, nil, nil, VUHDO_I18N_TT.K649 },
	{ "HELPFUL|MAW", VUHDO_I18N_AURA_GROUP_TORGHAST_ANIMA, nil, nil, VUHDO_I18N_TT.K650 },
	{ "HELPFUL|RAID_PLAYER_DISPELLABLE", VUHDO_I18N_AURA_FILTER_HELPFUL_PURGEABLE, nil, nil, VUHDO_I18N_TT.K843 },
	{ "HELPFUL|DISPELLABLE", VUHDO_I18N_AURA_FILTER_HELPFUL_ALL_PURGEABLE, nil, nil, VUHDO_I18N_TT.K844 },
	{ "HARMFUL|INCLUDE_NAME_PLATE_ONLY|PLAYER", VUHDO_I18N_AURA_GROUP_MY_NAMEPLATE, nil, nil, VUHDO_I18N_TT.K651 },
	{ "HARMFUL|INCLUDE_NAME_PLATE_ONLY", VUHDO_I18N_AURA_GROUP_ALL_NAMEPLATE, nil, nil, VUHDO_I18N_TT.K652 },
	{ "HARMFUL|PLAYER", VUHDO_I18N_AURA_GROUP_MY_DEBUFFS, nil, nil, VUHDO_I18N_TT.K663 },
	{ "HELPFUL|EXTERNAL_DEFENSIVE|PLAYER", VUHDO_I18N_AURA_GROUP_MY_EXTERNAL_DEF, nil, nil, VUHDO_I18N_TT.K664 },
	{ "HARMFUL|RAID|PLAYER", VUHDO_I18N_AURA_GROUP_MY_RAID_DEBUFFS, nil, nil, VUHDO_I18N_TT.K665 },
};

local VUHDO_AURA_GROUP_TOOLTIPS = {
	["PRESERVATION_EVOKER_HOTS"] = VUHDO_I18N_TT.K670,
	["AUGMENTATION_EVOKER_BUFFS"] = VUHDO_I18N_TT.K671,
	["RESTORATION_DRUID_HOTS"] = VUHDO_I18N_TT.K672,
	["FERAL_DRUID_BUFFS"] = VUHDO_I18N_TT.K817,
	["DISCIPLINE_PRIEST_HOTS"] = VUHDO_I18N_TT.K673,
	["HOLY_PRIEST_HOTS"] = VUHDO_I18N_TT.K674,
	["MISTWEAVER_MONK_HOTS"] = VUHDO_I18N_TT.K675,
	["RESTORATION_SHAMAN_HOTS"] = VUHDO_I18N_TT.K676,
	["HOLY_PALADIN_HOTS"] = VUHDO_I18N_TT.K677,
	["RAID_BUFFS"] = VUHDO_I18N_TT.K678,
	["BLESSING_OF_BRONZE"] = VUHDO_I18N_TT.K679,
	["ROGUE_POISONS"] = VUHDO_I18N_TT.K680,
	["SHAMAN_WEAPON_IMBUEMENTS"] = VUHDO_I18N_TT.K681,
	["PALADIN_WEAPON_IMBUEMENTS"] = VUHDO_I18N_TT.K682,
	["ENHANCEMENT_SHAMAN_BUFFS"] = VUHDO_I18N_TT.K683,
	["BREWMASTER_MONK_BUFFS"] = VUHDO_I18N_TT.K684,
	["WARLOCK_METAMORPHOSIS"] = VUHDO_I18N_TT.K685,
	["RELEVANT_DEBUFFS"] = VUHDO_I18N_TT.K862,
	["RELEVANT_BUFFS"] = VUHDO_I18N_TT.K858,
};

local VUHDO_AURA_FILTER_TOOLTIPS = {
	["HELPFUL"] = VUHDO_I18N_TT.K635,
	["HARMFUL"] = VUHDO_I18N_TT.K636,
	["HELPFUL|PLAYER|RAID_IN_COMBAT"] = VUHDO_I18N_TT.K637,
	["HELPFUL|RAID_IN_COMBAT"] = VUHDO_I18N_TT.K638,
	["HARMFUL|RAID_PLAYER_DISPELLABLE"] = VUHDO_I18N_TT.K639,
	["HARMFUL|DISPELLABLE"] = VUHDO_I18N_TT.K826,
	["HARMFUL|CROWD_CONTROL"] = VUHDO_I18N_TT.K640,
	["HELPFUL|BIG_DEFENSIVE"] = VUHDO_I18N_TT.K641,
	["HELPFUL|EXTERNAL_DEFENSIVE"] = VUHDO_I18N_TT.K642,
	["HELPFUL|PLAYER"] = VUHDO_I18N_TT.K842,
	["HELPFUL|RAID|PLAYER"] = VUHDO_I18N_TT.K643,
	["HELPFUL|RAID"] = VUHDO_I18N_TT.K644,
	["HARMFUL|RAID"] = VUHDO_I18N_TT.K645,
	["HELPFUL|IMPORTANT"] = VUHDO_I18N_TT.K646,
	["HARMFUL|IMPORTANT"] = VUHDO_I18N_TT.K647,
	["HELPFUL|CANCELABLE"] = VUHDO_I18N_TT.K648,
	["HELPFUL|!CANCELABLE"] = VUHDO_I18N_TT.K649,
	["HELPFUL|MAW"] = VUHDO_I18N_TT.K650,
	["HELPFUL|RAID_PLAYER_DISPELLABLE"] = VUHDO_I18N_TT.K843,
	["HELPFUL|DISPELLABLE"] = VUHDO_I18N_TT.K844,
	["HARMFUL|INCLUDE_NAME_PLATE_ONLY|PLAYER"] = VUHDO_I18N_TT.K651,
	["HARMFUL|INCLUDE_NAME_PLATE_ONLY"] = VUHDO_I18N_TT.K652,
	["HARMFUL|PLAYER"] = VUHDO_I18N_TT.K663,
	["HELPFUL|EXTERNAL_DEFENSIVE|PLAYER"] = VUHDO_I18N_TT.K664,
	["HARMFUL|RAID|PLAYER"] = VUHDO_I18N_TT.K665,
};

VUHDO_AURA_GROUPS_COLOR_TYPE_OPTIONS = {
	{ VUHDO_AURA_GROUP_COLOR_OFF, VUHDO_I18N_AURA_COLOR_OFF },
	{ VUHDO_AURA_GROUP_COLOR_DISPEL, VUHDO_I18N_AURA_COLOR_DISPEL },
	{ VUHDO_AURA_GROUP_COLOR_ALL_DISPEL, VUHDO_I18N_AURA_COLOR_ALL_DISPEL },
	{ VUHDO_AURA_GROUP_COLOR_CUSTOM, VUHDO_I18N_AURA_COLOR_CUSTOM },
};

VUHDO_AURA_GROUP_TYPE_OPTIONS = {
	{ VUHDO_AURA_GROUP_TYPE_FILTER, VUHDO_I18N_AURA_GROUP_TYPE_FILTER },
	{ VUHDO_AURA_GROUP_TYPE_LIST, VUHDO_I18N_AURA_GROUP_TYPE_LIST },
};

VUHDO_AURA_GROUPS_SHOW_ON_OPTIONS = {
	{ VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY, VUHDO_I18N_AURA_SHOW_ON_FRIENDLY },
	{ VUHDO_AURA_GROUP_UNIT_SCOPE_HOSTILE, VUHDO_I18N_HOSTILE },
	{ VUHDO_AURA_GROUP_UNIT_SCOPE_BOTH, VUHDO_I18N_AURA_SHOW_ON_BOTH },
};

local VUHDO_AURA_GROUP_LIST_ENTRY_ROW_HEIGHT = 22;

VUHDO_AURA_GROUPS_NEW_BOUQUET_SELECTED = "";

local sSelectedGroupId = nil;
local sRefreshDepth = 0;
local sAuraGroupEntryItems = { };
local sSpellEntrySettingsGroupId = nil;
local sSpellEntrySettingsEntryIdx = nil;



do
	local sAuraConditionBooleanLabels = {
		["isBossOrRoleAura"] = VUHDO_I18N_AURA_CONDITION_BOSS_OR_ROLE,
		["isBossAura"] = VUHDO_I18N_AURA_CONDITION_BOSS_AURA,
		["isRoleAura"] = VUHDO_I18N_AURA_CONDITION_ROLE_AURA,
		["isPriorityAura"] = VUHDO_I18N_AURA_CONDITION_PRIORITY_AURA,
		["isStealable"] = VUHDO_I18N_AURA_CONDITION_STEALABLE,
		["isFromPlayerOrPlayerPet"] = VUHDO_I18N_AURA_CONDITION_FROM_ME,
		["canApplyAura"] = VUHDO_I18N_AURA_CONDITION_CAN_APPLY,
		["nameplateShowAll"] = VUHDO_I18N_AURA_CONDITION_NAMEPLATE_ALL,
		["nameplateShowPersonal"] = VUHDO_I18N_AURA_CONDITION_NAMEPLATE_PERSONAL,
	};

	local sAuraConditionTokenLabels = {
		["PLAYER"] = VUHDO_I18N_PLAYER,
		["RAID"] = VUHDO_I18N_AURA_TOKEN_RAID,
		["RAID_IN_COMBAT"] = VUHDO_I18N_AURA_TOKEN_RAID_IN_COMBAT,
		["CANCELABLE"] = VUHDO_I18N_AURA_TOKEN_CANCELABLE,
		["INCLUDE_NAME_PLATE_ONLY"] = VUHDO_I18N_AURA_TOKEN_NAMEPLATE_ONLY,
		["MAW"] = VUHDO_I18N_AURA_GROUP_TORGHAST_ANIMA,
		["EXTERNAL_DEFENSIVE"] = VUHDO_I18N_AURA_GROUP_EXTERNAL_DEF,
		["CROWD_CONTROL"] = VUHDO_I18N_AURA_GROUP_CC,
		["RAID_PLAYER_DISPELLABLE"] = VUHDO_I18N_AURA_FILTER_HARMFUL_DISPELLABLE,
		["BIG_DEFENSIVE"] = VUHDO_I18N_AURA_GROUP_BIG_DEF,
		["IMPORTANT"] = VUHDO_I18N_AURA_GROUP_IMPORTANT_DEBUFFS,
		["DISPELLABLE"] = VUHDO_I18N_AURA_FILTER_HARMFUL_ALL_DISPELLABLE,
	};

	local sAuraConditionBooleanTooltips = {
		["isBossOrRoleAura"] = VUHDO_I18N_TT.K870,
		["isBossAura"] = VUHDO_I18N_TT.K871,
		["isRoleAura"] = VUHDO_I18N_TT.K872,
		["isPriorityAura"] = VUHDO_I18N_TT.K873,
		["isStealable"] = VUHDO_I18N_TT.K874,
		["isFromPlayerOrPlayerPet"] = VUHDO_I18N_TT.K875,
		["canApplyAura"] = VUHDO_I18N_TT.K876,
		["nameplateShowAll"] = VUHDO_I18N_TT.K877,
		["nameplateShowPersonal"] = VUHDO_I18N_TT.K878,
	};

	local sAuraConditionTokenTooltips = {
		["PLAYER"] = VUHDO_I18N_TT.K879,
		["RAID"] = VUHDO_I18N_TT.K880,
		["RAID_IN_COMBAT"] = VUHDO_I18N_TT.K881,
		["CANCELABLE"] = VUHDO_I18N_TT.K882,
		["INCLUDE_NAME_PLATE_ONLY"] = VUHDO_I18N_TT.K883,
		["MAW"] = VUHDO_I18N_TT.K884,
		["EXTERNAL_DEFENSIVE"] = VUHDO_I18N_TT.K885,
		["CROWD_CONTROL"] = VUHDO_I18N_TT.K886,
		["RAID_PLAYER_DISPELLABLE"] = VUHDO_I18N_TT.K887,
		["BIG_DEFENSIVE"] = VUHDO_I18N_TT.K888,
		["IMPORTANT"] = VUHDO_I18N_TT.K889,
		["DISPELLABLE"] = VUHDO_I18N_TT.K890,
	};

	local sNonNegatableFilterTokens = {
		["INCLUDE_NAME_PLATE_ONLY"] = true,
		["MAW"] = true,
	};

	local sPresetScratchMatchAll = { };
	local sPresetScratchNeverShow = { };
	local sPresetScratchAuras;
	local sFilterParts = { };



	--
	local tBoolKey;
	local tTokenKey;
	local tDurationValue;
	local tDurationLabel;
	local tConditionTooltip;
	local tCapability;
	local function VUHDO_auraGroupsIsMatchAnyCondition(aKey)

		tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[aKey];

		if not tCapability or not tCapability["matchAny"] then
			return false;
		end

		if tCapability["storage"] == "boolean" then
			return sAuraConditionBooleanLabels[aKey] ~= nil;
		end

		return sAuraConditionTokenLabels[aKey] ~= nil;

	end



	--
	local function VUHDO_auraGroupsBuildFilterString(aPolarity, aMatchAll, aNeverShow)

		twipe(sFilterParts);

		tinsert(sFilterParts, aPolarity);

		for tCnt = 1, #VUHDO_AURA_CONDITION_FILTER_TOKEN_KEYS do
			tTokenKey = VUHDO_AURA_CONDITION_FILTER_TOKEN_KEYS[tCnt];
			tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[tTokenKey];

			if tCapability and tCapability["matchAll"] and aMatchAll[tTokenKey] then
				tinsert(sFilterParts, tTokenKey);
			end
		end

		for tCnt = 1, #VUHDO_AURA_CONDITION_FILTER_TOKEN_KEYS do
			tTokenKey = VUHDO_AURA_CONDITION_FILTER_TOKEN_KEYS[tCnt];
			tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[tTokenKey];

			if tCapability and tCapability["neverShow"] and aNeverShow[tTokenKey] then
				tinsert(sFilterParts, "!" .. tTokenKey);
			end
		end

		return tconcat(sFilterParts, "|");

	end



	--
	local function VUHDO_getAuraConditionTokenLabel(aTokenKey)

		if aTokenKey == "RAID_PLAYER_DISPELLABLE" then
			if VUHDO_AURA_GROUPS_AURAS_SELECTED == "HELPFUL" then
				return VUHDO_I18N_AURA_FILTER_HELPFUL_PURGEABLE;
			end

			return VUHDO_I18N_AURA_FILTER_HARMFUL_DISPELLABLE;
		elseif aTokenKey == "DISPELLABLE" then
			if VUHDO_AURA_GROUPS_AURAS_SELECTED == "HELPFUL" then
				return VUHDO_I18N_AURA_FILTER_HELPFUL_ALL_PURGEABLE;
			end

			return VUHDO_I18N_AURA_FILTER_HARMFUL_ALL_DISPELLABLE;
		end

		return sAuraConditionTokenLabels[aTokenKey];

	end



	--
	function VUHDO_initAuraGroupConditionComboModels()

		twipe(VUHDO_AURA_CONDITION_COMBO_MODEL);

		for tCnt = 1, #VUHDO_AURA_CONDITION_BOOLEAN_KEYS do
			tBoolKey = VUHDO_AURA_CONDITION_BOOLEAN_KEYS[tCnt];
			tDurationLabel = sAuraConditionBooleanLabels[tBoolKey];
			tConditionTooltip = sAuraConditionBooleanTooltips[tBoolKey];

			tinsert(VUHDO_AURA_CONDITION_COMBO_MODEL, { tBoolKey, tDurationLabel, nil, nil, tConditionTooltip });
		end

		for _, tTokenKey in ipairs(VUHDO_AURA_CONDITION_FILTER_TOKEN_KEYS) do
			tDurationLabel = VUHDO_getAuraConditionTokenLabel(tTokenKey);

			if tDurationLabel then
				tConditionTooltip = sAuraConditionTokenTooltips[tTokenKey];

				tinsert(VUHDO_AURA_CONDITION_COMBO_MODEL, { tTokenKey, tDurationLabel, nil, nil, tConditionTooltip });
			end
		end

		tsort(VUHDO_AURA_CONDITION_COMBO_MODEL, function(anA, anotherA) return anA[2] < anotherA[2]; end);

		twipe(VUHDO_AURA_DURATION_OPTIONS);

		for tCnt = 1, #VUHDO_AURA_DURATION_COMBO_VALUES do
			tDurationValue = VUHDO_AURA_DURATION_COMBO_VALUES[tCnt];

			if tDurationValue == VUHDO_AURA_DURATION_COMBO_NONE then
				tDurationLabel = VUHDO_I18N_AURA_FILTER_NONE;
			elseif tDurationValue == VUHDO_AURA_DURATION_COMBO_HAS then
				tDurationLabel = VUHDO_I18N_AURA_HAS_DURATION;
			else
				tDurationLabel = format(VUHDO_I18N_AURA_DURATION_UP_TO, SecondsToTime(tDurationValue));
			end

			tinsert(VUHDO_AURA_DURATION_OPTIONS, { tDurationValue, tDurationLabel });
		end

		twipe(VUHDO_AURA_PRESET_OPTIONS);

		tinsert(VUHDO_AURA_PRESET_OPTIONS, { "", VUHDO_I18N_CUSTOM });

		for _, tEntry in ipairs(VUHDO_AURA_FILTER_OPTIONS) do
			tinsert(VUHDO_AURA_PRESET_OPTIONS, { tEntry[1], tEntry[2], nil, nil, tEntry[5] });
		end

		tsort(VUHDO_AURA_PRESET_OPTIONS, function(anA, anotherA)
			if anA[1] == "" then
				return true;
			elseif anotherA[1] == "" then
				return false;
			end

			return anA[2] < anotherA[2];
		end);

		return;

	end



	--
	local tPresetFilter;
	local tMatchAny;
	local tMatchAll;
	local tNeverShow;
	local tScratchAuras;
	local function VUHDO_auraGroupsConditionTablesEqual(aLeft, aRight)

		for tTokenKey, _ in pairs(aLeft) do
			if not aRight[tTokenKey] then
				return false;
			end
		end

		for tTokenKey, _ in pairs(aRight) do
			if not aLeft[tTokenKey] then
				return false;
			end
		end

		return true;

	end



	--
	local function VUHDO_auraGroupsBuildPresetSnapshot(aFilterString, aOutMatchAll, aOutNeverShow)

		twipe(aOutMatchAll);
		twipe(aOutNeverShow);

		sPresetScratchAuras = "HARMFUL";

		if not aFilterString or aFilterString == "" then
			return sPresetScratchAuras;
		end

		tPresetFilter = { strsplit("|", aFilterString) };

		for _, tTokenKey in ipairs(tPresetFilter) do
			tTokenKey = strupper(tTokenKey);

			if tTokenKey == "HELPFUL" or tTokenKey == "HARMFUL" then
				sPresetScratchAuras = tTokenKey;
			elseif strfind(tTokenKey, "!", 1, true) == 1 then
				aOutNeverShow[strsub(tTokenKey, 2)] = true;
			elseif sAuraConditionBooleanLabels[tTokenKey] then
				aOutMatchAll[tTokenKey] = true;
			elseif sAuraConditionTokenLabels[tTokenKey] then
				aOutMatchAll[tTokenKey] = true;
			end
		end

		return sPresetScratchAuras;

	end



	--
	local function VUHDO_auraGroupsFindMatchingPreset()

		if next(VUHDO_AURA_GROUPS_CONDITIONS["matchAny"]) then
			return "";
		end

		if next(VUHDO_AURA_GROUPS_CONDITIONS["excludeDispel"]) then
			return "";
		end

		if VUHDO_AURA_GROUPS_DURATION_SELECTED ~= VUHDO_AURA_DURATION_COMBO_NONE then
			return "";
		end

		tMatchAll = VUHDO_AURA_GROUPS_CONDITIONS["matchAll"];
		tNeverShow = VUHDO_AURA_GROUPS_CONDITIONS["neverShow"];

		for _, tEntry in ipairs(VUHDO_AURA_PRESET_OPTIONS) do
			if tEntry[1] ~= "" then
				tScratchAuras = VUHDO_auraGroupsBuildPresetSnapshot(tEntry[1], sPresetScratchMatchAll, sPresetScratchNeverShow);

				if tScratchAuras == VUHDO_AURA_GROUPS_AURAS_SELECTED
					and VUHDO_auraGroupsConditionTablesEqual(tMatchAll, sPresetScratchMatchAll)
					and VUHDO_auraGroupsConditionTablesEqual(tNeverShow, sPresetScratchNeverShow) then
					return tEntry[1];
				end
			end
		end

		return "";

	end



	--
	function VUHDO_auraGroupsApplyPresetFilter(aFilterString)

		twipe(VUHDO_AURA_GROUPS_CONDITIONS["matchAny"]);
		twipe(VUHDO_AURA_GROUPS_CONDITIONS["matchAll"]);
		twipe(VUHDO_AURA_GROUPS_CONDITIONS["neverShow"]);

		if not aFilterString or aFilterString == "" then
			return;
		end

		tPresetFilter = { strsplit("|", aFilterString) };

		for _, tTokenKey in ipairs(tPresetFilter) do
			tTokenKey = strupper(tTokenKey);

			if tTokenKey == "HELPFUL" or tTokenKey == "HARMFUL" then
				VUHDO_AURA_GROUPS_AURAS_SELECTED = tTokenKey;
			elseif strfind(tTokenKey, "!", 1, true) == 1 then
				VUHDO_AURA_GROUPS_CONDITIONS["neverShow"][strsub(tTokenKey, 2)] = true;
			elseif sAuraConditionBooleanLabels[tTokenKey] then
				VUHDO_AURA_GROUPS_CONDITIONS["matchAll"][tTokenKey] = true;
			elseif sAuraConditionTokenLabels[tTokenKey] then
				VUHDO_AURA_GROUPS_CONDITIONS["matchAll"][tTokenKey] = true;
			end
		end

		return;

	end



	--
	local tCandidateBooleans;
	local tMatchAnyBooleans;
	local tMatchAnyFilters;
	local tFilter;
	local tTokens;
	local tUpper;
	local tBase;
	local tIsNegated;
	local tExcludeFilter;
	function VUHDO_auraGroupsSyncConditionModels(aGroup)

		twipe(VUHDO_AURA_GROUPS_CONDITIONS["matchAny"]);
		twipe(VUHDO_AURA_GROUPS_CONDITIONS["matchAll"]);
		twipe(VUHDO_AURA_GROUPS_CONDITIONS["neverShow"]);
		twipe(VUHDO_AURA_GROUPS_CONDITIONS["excludeDispel"]);

		VUHDO_AURA_GROUPS_AURAS_SELECTED = "HARMFUL";
		VUHDO_AURA_GROUPS_PRESET_SELECTED = "";
		VUHDO_AURA_GROUPS_DURATION_SELECTED = VUHDO_AURA_DURATION_COMBO_NONE;

		if not aGroup then
			return;
		end

		VUHDO_migrateAuraGroupConditions(aGroup);

		if aGroup["isHarmful"] ~= nil then
			VUHDO_AURA_GROUPS_AURAS_SELECTED = aGroup["isHarmful"] and "HARMFUL" or "HELPFUL";
		else
			VUHDO_AURA_GROUPS_AURAS_SELECTED = VUHDO_filterContainsToken(aGroup["filter"] or "", "HARMFUL") and "HARMFUL" or "HELPFUL";
		end

		if aGroup["maxDurationSeconds"] ~= nil then
			VUHDO_AURA_GROUPS_DURATION_SELECTED = aGroup["maxDurationSeconds"];
		elseif aGroup["hasDuration"] then
			VUHDO_AURA_GROUPS_DURATION_SELECTED = VUHDO_AURA_DURATION_COMBO_HAS;
		end

		tMatchAnyBooleans = aGroup["matchAnyBooleans"];

		if tMatchAnyBooleans then
			for tCnt = 1, #VUHDO_AURA_CONDITION_BOOLEAN_KEYS do
				tBoolKey = VUHDO_AURA_CONDITION_BOOLEAN_KEYS[tCnt];
				tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[tBoolKey];

				if tCapability and tCapability["matchAny"] and tMatchAnyBooleans[tBoolKey] == 1 then
					VUHDO_AURA_GROUPS_CONDITIONS["matchAny"][tBoolKey] = true;
				end
			end
		end

		tMatchAnyFilters = aGroup["matchAnyFilters"];

		if tMatchAnyFilters then
			for tCnt = 1, #VUHDO_AURA_MATCH_ANY_FILTER_TOKEN_ORDER do
				tTokenKey = VUHDO_AURA_MATCH_ANY_FILTER_TOKEN_ORDER[tCnt];
				tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[tTokenKey];

				if tCapability and tCapability["matchAny"] and tMatchAnyFilters[tTokenKey] == 1 then
					VUHDO_AURA_GROUPS_CONDITIONS["matchAny"][tTokenKey] = true;
				end
			end
		end

		tCandidateBooleans = aGroup["candidateBooleans"];

		if tCandidateBooleans then
			for tCnt = 1, #VUHDO_AURA_CONDITION_BOOLEAN_KEYS do
				tBoolKey = VUHDO_AURA_CONDITION_BOOLEAN_KEYS[tCnt];
				tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[tBoolKey];

				if tCapability then
					if tCandidateBooleans[tBoolKey] == 1 and tCapability["matchAll"] then
						VUHDO_AURA_GROUPS_CONDITIONS["matchAll"][tBoolKey] = true;
					elseif tCandidateBooleans[tBoolKey] == 3 and tCapability["neverShow"] then
						VUHDO_AURA_GROUPS_CONDITIONS["neverShow"][tBoolKey] = true;
					end
				end
			end
		end

		tFilter = aGroup["filter"];

		if tFilter then
			tTokens = { strsplit("|", tFilter) };

			for _, tTokenKey in ipairs(tTokens) do
				tUpper = strupper(tTokenKey);
				tIsNegated = strfind(tUpper, "!", 1, true) == 1;
				tBase = tIsNegated and strsub(tUpper, 2) or tUpper;

				if tBase ~= "HELPFUL" and tBase ~= "HARMFUL" and tBase ~= "NOT_CANCELABLE" then
					if tIsNegated then
						if not sNonNegatableFilterTokens[tBase] then
							VUHDO_AURA_GROUPS_CONDITIONS["neverShow"][tBase] = true;
						end
					elseif not VUHDO_AURA_GROUPS_CONDITIONS["matchAny"][tBase] and sAuraConditionTokenLabels[tBase] then
						VUHDO_AURA_GROUPS_CONDITIONS["matchAll"][tBase] = true;
					end
				end
			end
		end

		tExcludeFilter = aGroup["excludeFilter"];

		if tExcludeFilter then
			tTokens = { strsplit("|", tExcludeFilter) };

			for _, tTokenKey in ipairs(tTokens) do
				tUpper = strupper(tTokenKey);

				if tUpper ~= "" then
					VUHDO_AURA_GROUPS_CONDITIONS["neverShow"][tUpper] = true;
				end
			end
		end

		if aGroup["excludeDispelTypes"] then
			for tDispelName, tIsExcluded in pairs(aGroup["excludeDispelTypes"]) do
				if tIsExcluded then
					VUHDO_AURA_GROUPS_CONDITIONS["excludeDispel"][tDispelName] = true;
				end
			end
		end

		VUHDO_AURA_GROUPS_PRESET_SELECTED = VUHDO_auraGroupsFindMatchingPreset();

		return;

	end



	--
	local tExcludeDispelTypes;
	function VUHDO_auraGroupsWriteConditions(aGroup)

		if not aGroup or (aGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER) ~= VUHDO_AURA_GROUP_TYPE_FILTER then
			return;
		end

		tNeverShow = VUHDO_AURA_GROUPS_CONDITIONS["neverShow"];
		tMatchAny = VUHDO_AURA_GROUPS_CONDITIONS["matchAny"];
		tMatchAll = VUHDO_AURA_GROUPS_CONDITIONS["matchAll"];

		tCandidateBooleans = aGroup["candidateBooleans"];
		tMatchAnyBooleans = aGroup["matchAnyBooleans"];
		tMatchAnyFilters = aGroup["matchAnyFilters"];

		if tCandidateBooleans then
			for tCnt = 1, #VUHDO_AURA_CONDITION_BOOLEAN_KEYS do
				tBoolKey = VUHDO_AURA_CONDITION_BOOLEAN_KEYS[tCnt];
				tCandidateBooleans[tBoolKey] = nil;
			end
		else
			tCandidateBooleans = { };
			aGroup["candidateBooleans"] = tCandidateBooleans;
		end

		if not tMatchAnyBooleans then
			tMatchAnyBooleans = { };
			aGroup["matchAnyBooleans"] = tMatchAnyBooleans;
		end

		if not tMatchAnyFilters then
			tMatchAnyFilters = { };
			aGroup["matchAnyFilters"] = tMatchAnyFilters;
		end

		twipe(tMatchAnyBooleans);
		twipe(tMatchAnyFilters);

		for tBoolKey, _ in pairs(tMatchAll) do
			tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[tBoolKey];

			if tCapability and tCapability["storage"] == "boolean" and tCapability["matchAll"] then
				tCandidateBooleans[tBoolKey] = 1;
			end
		end

		for tBoolKey, _ in pairs(tNeverShow) do
			tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[tBoolKey];

			if tCapability and tCapability["storage"] == "boolean" and tCapability["neverShow"] then
				tCandidateBooleans[tBoolKey] = 3;
			end
		end

		for tBoolKey, _ in pairs(tMatchAny) do
			tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[tBoolKey];

			if tCapability and tCapability["storage"] == "boolean" and tCapability["matchAny"] then
				tMatchAnyBooleans[tBoolKey] = 1;
			elseif tCapability and tCapability["storage"] == "filterToken" and tCapability["matchAny"] then
				tMatchAnyFilters[tBoolKey] = 1;
			end
		end

		if not next(tCandidateBooleans) then
			aGroup["candidateBooleans"] = nil;
		end

		if not next(tMatchAnyBooleans) then
			aGroup["matchAnyBooleans"] = nil;
		end

		if not next(tMatchAnyFilters) then
			aGroup["matchAnyFilters"] = nil;
		end

		aGroup["filter"] = VUHDO_auraGroupsBuildFilterString(VUHDO_AURA_GROUPS_AURAS_SELECTED, tMatchAll, tNeverShow);
		aGroup["conditionsVersion"] = VUHDO_AURA_GROUP_CONDITIONS_VERSION;
		aGroup["isHarmful"] = VUHDO_AURA_GROUPS_AURAS_SELECTED == "HARMFUL";

		aGroup["excludeFilter"] = tNeverShow["PLAYER"] and "PLAYER" or nil;

		tExcludeDispelTypes = aGroup["excludeDispelTypes"];

		if not tExcludeDispelTypes then
			tExcludeDispelTypes = { };
			aGroup["excludeDispelTypes"] = tExcludeDispelTypes;
		end

		twipe(tExcludeDispelTypes);

		for tDispelName, _ in pairs(VUHDO_AURA_GROUPS_CONDITIONS["excludeDispel"]) do
			tExcludeDispelTypes[tDispelName] = true;
		end

		if not next(tExcludeDispelTypes) then
			aGroup["excludeDispelTypes"] = nil;
		end

		if VUHDO_AURA_GROUPS_DURATION_SELECTED == VUHDO_AURA_DURATION_COMBO_NONE then
			aGroup["hasDuration"] = nil;
			aGroup["maxDurationSeconds"] = nil;
		elseif VUHDO_AURA_GROUPS_DURATION_SELECTED == VUHDO_AURA_DURATION_COMBO_HAS then
			aGroup["hasDuration"] = true;
			aGroup["maxDurationSeconds"] = 0;
		else
			aGroup["hasDuration"] = nil;
			aGroup["maxDurationSeconds"] = VUHDO_AURA_GROUPS_DURATION_SELECTED;
		end

		VUHDO_resolveAuraGroupFilter(aGroup);

		return;

	end



	--
	local tMatchAnyCount;
	local tBranchHintLabel;
	function VUHDO_auraGroupsUpdateBranchHintLabel()

		tBranchHintLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanelConditionsBranchHintLabelLabel"];

		if not tBranchHintLabel then
			return;
		end

		tMatchAnyCount = 0;

		for tBoolKey, _ in pairs(VUHDO_AURA_GROUPS_CONDITIONS["matchAny"]) do
			if VUHDO_auraGroupsIsMatchAnyCondition(tBoolKey) then
				tMatchAnyCount = tMatchAnyCount + 1;
			end
		end

		if tMatchAnyCount == 0 then
			tBranchHintLabel:SetText("");
		else
			tBranchHintLabel:SetText(format(VUHDO_I18N_AURA_BRANCH_BUDGET, tMatchAnyCount, VUHDO_AURA_MAX_MATCH_ANY));
		end

		return;

	end



	--
	local tChangedModel;
	function VUHDO_auraGroupsIsConditionEntryDisabled(aComboBox, aValue)

		tChangedModel = aComboBox:GetAttribute("model");
		tMatchAny = VUHDO_AURA_GROUPS_CONDITIONS["matchAny"];
		tMatchAll = VUHDO_AURA_GROUPS_CONDITIONS["matchAll"];
		tNeverShow = VUHDO_AURA_GROUPS_CONDITIONS["neverShow"];

		tCapability = VUHDO_AURA_CONDITION_CAPABILITIES[aValue];

		if tChangedModel == "VUHDO_AURA_GROUPS_CONDITIONS.matchAny" and tMatchAny[aValue] then
			return false;
		elseif tChangedModel == "VUHDO_AURA_GROUPS_CONDITIONS.matchAll" and tMatchAll[aValue] then
			return false;
		elseif tChangedModel == "VUHDO_AURA_GROUPS_CONDITIONS.neverShow" and tNeverShow[aValue] then
			return false;
		end

		if tChangedModel == "VUHDO_AURA_GROUPS_CONDITIONS.matchAny" then
			if not tCapability or not tCapability["matchAny"] then
				return true;
			end

			if tMatchAll[aValue] or tNeverShow[aValue] then
				return true;
			end

			if aValue == "RAID_PLAYER_DISPELLABLE" and tMatchAny["DISPELLABLE"] then
				return true;
			end

			if aValue == "DISPELLABLE" and tMatchAny["RAID_PLAYER_DISPELLABLE"] then
				return true;
			end

			if aValue == "PLAYER" and tMatchAny["RAID_PLAYER_DISPELLABLE"] then
				return true;
			end

			tMatchAnyCount = 0;

			for tBoolKey, _ in pairs(tMatchAny) do
				if VUHDO_auraGroupsIsMatchAnyCondition(tBoolKey) then
					tMatchAnyCount = tMatchAnyCount + 1;
				end
			end

			if tMatchAnyCount >= VUHDO_AURA_MAX_MATCH_ANY then
				return true;
			end
		elseif tChangedModel == "VUHDO_AURA_GROUPS_CONDITIONS.matchAll" then
			if not tCapability or not tCapability["matchAll"] then
				return true;
			end

			if tMatchAny[aValue] or tNeverShow[aValue] then
				return true;
			end

			if aValue == "PLAYER" and tMatchAll["RAID_PLAYER_DISPELLABLE"] then
				return true;
			end
		elseif tChangedModel == "VUHDO_AURA_GROUPS_CONDITIONS.neverShow" then
			if not tCapability or not tCapability["neverShow"] then
				return true;
			end

			if tMatchAny[aValue] or tMatchAll[aValue] then
				return true;
			end
		end

		return false;

	end



	--
	function VUHDO_auraGroupsEnforceConditionExclusions(aComboBox, aValue)

		if not aValue then
			return;
		end

		tChangedModel = aComboBox:GetAttribute("model");

		if tChangedModel == "VUHDO_AURA_GROUPS_CONDITIONS.matchAny" then
			VUHDO_AURA_GROUPS_CONDITIONS["matchAll"][aValue] = nil;
			VUHDO_AURA_GROUPS_CONDITIONS["neverShow"][aValue] = nil;

			if aValue == "DISPELLABLE" then
				VUHDO_AURA_GROUPS_CONDITIONS["matchAny"]["RAID_PLAYER_DISPELLABLE"] = nil;
			elseif aValue == "RAID_PLAYER_DISPELLABLE" then
				VUHDO_AURA_GROUPS_CONDITIONS["matchAny"]["DISPELLABLE"] = nil;
				VUHDO_AURA_GROUPS_CONDITIONS["matchAny"]["PLAYER"] = nil;
				VUHDO_AURA_GROUPS_CONDITIONS["matchAll"]["PLAYER"] = nil;
			end
		elseif tChangedModel == "VUHDO_AURA_GROUPS_CONDITIONS.matchAll" then
			VUHDO_AURA_GROUPS_CONDITIONS["matchAny"][aValue] = nil;
			VUHDO_AURA_GROUPS_CONDITIONS["neverShow"][aValue] = nil;

			if aValue == "RAID_PLAYER_DISPELLABLE" then
				VUHDO_AURA_GROUPS_CONDITIONS["matchAll"]["PLAYER"] = nil;
			end
		elseif tChangedModel == "VUHDO_AURA_GROUPS_CONDITIONS.neverShow" then
			VUHDO_AURA_GROUPS_CONDITIONS["matchAny"][aValue] = nil;
			VUHDO_AURA_GROUPS_CONDITIONS["matchAll"][aValue] = nil;
		end

		return;

	end
end



--
local function VUHDO_auraGroupsRunRefresh(aCallback, ...)

	sRefreshDepth = sRefreshDepth + 1;

	aCallback(...);

	sRefreshDepth = sRefreshDepth - 1;

	return;

end



--
local tGroup;
local tTooltipResult;
local function VUHDO_getAuraGroupTooltip(aGroupId)

	tTooltipResult = VUHDO_AURA_GROUP_TOOLTIPS[aGroupId];

	if tTooltipResult then
		return tTooltipResult;
	end

	tGroup = VUHDO_getAuraGroup(aGroupId);

	if tGroup and tGroup["filter"] then
		return VUHDO_AURA_FILTER_TOOLTIPS[tGroup["filter"]];
	end

	return nil;

end



--
local tAllGroups;
local tDisplayName;
local tSortTable;
local tTooltip;
function VUHDO_initAuraGroupsComboModel()

	twipe(VUHDO_AURA_GROUPS_COMBO_MODEL);

	tAllGroups = VUHDO_getAllAuraGroups();

	if not tAllGroups then
		return;
	end

	tSortTable = { };

	for tGroupId, tGroup in pairs(tAllGroups) do
		tDisplayName = VUHDO_getAuraGroupDisplayName(tGroupId);
		tTooltip = VUHDO_getAuraGroupTooltip(tGroupId);

		tinsert(tSortTable, { tGroupId, tDisplayName, tTooltip });
	end

	tsort(tSortTable, function(anA, anotherA) return anA[2] < anotherA[2]; end);

	for _, tEntry in ipairs(tSortTable) do
		tinsert(VUHDO_AURA_GROUPS_COMBO_MODEL, { tEntry[1], tEntry[2], nil, nil, tEntry[3] });
	end

	return;

end



--
local tGlowDef;
local tDisplayName;
function VUHDO_initGlowStyleComboModel()

	twipe(VUHDO_GLOW_STYLE_COMBO_MODEL);

	tinsert(VUHDO_GLOW_STYLE_COMBO_MODEL, { "none", VUHDO_I18N_NONE });

	for _, tGlowName in ipairs(VUHDO_LibOrbitGlow:GetGlowList()) do
		tGlowDef = VUHDO_LibOrbitGlow:GetGlowInfo(tGlowName);

		if tGlowDef and not tGlowDef["engine"] and (tGlowDef["atlas"] or tGlowDef["path"] or tGlowDef["resolve"]) then
			tDisplayName = VUHDO_AURA_GLOW_STYLE_DISPLAY_NAMES[tGlowName] or tGlowName;

			tinsert(VUHDO_GLOW_STYLE_COMBO_MODEL, { tGlowName, tDisplayName });
		end
	end

	return;

end



--
local tAllGroups;
local tDisplayName;
local tSortTable;
local tTooltip;
function VUHDO_initPanelAuraGroupsComboModel()

	twipe(VUHDO_PANEL_AURA_GROUPS_COMBO_MODEL);

	tAllGroups = VUHDO_getAllAuraGroups();

	if not tAllGroups then
		return;
	end

	tSortTable = { };

	for tGroupId, tGroup in pairs(tAllGroups) do
		if VUHDO_getAuraGroup(tGroupId) then
			tDisplayName = VUHDO_getAuraGroupDisplayName(tGroupId);
			tTooltip = VUHDO_getAuraGroupTooltip(tGroupId);

			tinsert(tSortTable, { tGroupId, tDisplayName, tTooltip });
		end
	end

	tsort(tSortTable, function(anA, anotherA) return anA[2] < anotherA[2]; end);

	for _, tEntry in ipairs(tSortTable) do
		tinsert(VUHDO_PANEL_AURA_GROUPS_COMBO_MODEL, { tEntry[1], tEntry[2], nil, nil, tEntry[3] });
	end

	return;

end



--
local tSpellId;
local tSpellIds;
local tDisplayName;
local tSortTable;
function VUHDO_initAuraGroupsAddSpellComboModel()

	twipe(VUHDO_AURA_GROUPS_ADD_SPELL_COMBO_MODEL);

	VUHDO_AURA_GROUPS_ADD_SPELL_SELECTED = "";

	tSpellIds = { };

	for _, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or { }) do
		if tGroup["type"] == VUHDO_AURA_GROUP_TYPE_LIST and tGroup["entries"] then
			for _, tEntry in ipairs(tGroup["entries"]) do
				if (tEntry["entryType"] or 0) == VUHDO_AURA_LIST_ENTRY_SPELL and tEntry["value"] then
					tSpellId = tonumber(tEntry["value"]) or tEntry["value"];

					tSpellIds[tSpellId] = true;
				end
			end
		end
	end

	tSortTable = { };

	for tSpellId, _ in pairs(tSpellIds) do
		tDisplayName = VUHDO_resolveSpellId(tSpellId);

		if tDisplayName ~= tostring(tSpellId) then
			tDisplayName = "[" .. tSpellId .. "] " .. tDisplayName;
		else
			tDisplayName = tostring(tSpellId);
		end

		tinsert(tSortTable, { tSpellId, tDisplayName, VUHDO_resolveSpellId(tSpellId) });
	end

	tsort(tSortTable, function(anA, anotherA) return anA[3] < anotherA[3]; end);

	for _, tEntry in ipairs(tSortTable) do
		tinsert(VUHDO_AURA_GROUPS_ADD_SPELL_COMBO_MODEL, { tEntry[1], tEntry[2] });
	end

	return;

end



--
function VUHDO_auraGroupsComboChanged(aComboBox, aValue, anArrayModel)

	if sRefreshDepth > 0 then
		return;
	end

	VUHDO_AURA_GROUPS_SELECTED = aValue;
	sSelectedGroupId = aValue;

	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
function VUHDO_auraGroupsNameChanged(aEditBox)

	if sRefreshDepth > 0 then
		return;
	end

	if VUHDO_AURA_GROUPS_SELECTED and VUHDO_CONFIG["AURA_GROUPS"] and VUHDO_CONFIG["AURA_GROUPS"][VUHDO_AURA_GROUPS_SELECTED] and aEditBox:GetText() then
		VUHDO_CONFIG["AURA_GROUPS"][VUHDO_AURA_GROUPS_SELECTED]["displayName"] = aEditBox:GetText();
	end

	return;

end



--
function VUHDO_auraGroupsNameCommit(aEditBox)

	if sRefreshDepth > 0 then
		return;
	end

	if VUHDO_AURA_GROUPS_SELECTED and VUHDO_CONFIG["AURA_GROUPS"] and VUHDO_CONFIG["AURA_GROUPS"][VUHDO_AURA_GROUPS_SELECTED] then
		VUHDO_auraGroupsRefreshList();
	end

	return;

end



--
local tScrollPanel;
function VUHDO_auraGroupsGroupComboOnLoad(aGroupCombo)

	VUHDO_initResizeableScrollCombo(aGroupCombo);

	VUHDO_setComboModel(aGroupCombo, "VUHDO_AURA_GROUPS_SELECTED", VUHDO_AURA_GROUPS_COMBO_MODEL, VUHDO_I18N_SELECT);
	aGroupCombo:SetAttribute("custom_function", VUHDO_auraGroupsComboChanged);
	VUHDO_lnfSetTooltip(aGroupCombo, VUHDO_I18N_TT.K611);

	tScrollPanel = _G[aGroupCombo:GetName() .. "ScrollPanel"];

	if tScrollPanel then
		tScrollPanel:SetScript("OnShow", function()
			VUHDO_initAuraGroupsComboModel();
			VUHDO_lnfComboBoxInitFromModel(aGroupCombo);
		end);
	end

	return;

end



--
local tGroupCombo;
local function VUHDO_initAuraGroupsList()

	VUHDO_initAuraGroupConditionComboModels();
	VUHDO_initAuraGroupsComboModel();

	tGroupCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelGroupCombo"];

	if tGroupCombo then
		VUHDO_lnfComboBoxInitFromModel(tGroupCombo);
	end

	return;

end



--
function VUHDO_auraGroupsRefreshList()

	VUHDO_auraGroupsRunRefresh(VUHDO_initAuraGroupsList);

	return;

end



--
function VUHDO_auraGroupsListDropdownInitFromModel()

	return;

end



--
function VUHDO_auraGroupsOnGroupSelected(aGroupId)

	sSelectedGroupId = aGroupId;
	VUHDO_AURA_GROUPS_SELECTED = aGroupId;

	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



do
	local tGroup;
	local tNameEditBox;
	local tNameLabel;
	local tTypeCombo;
	local tTypeLabel;
	local tShowOnCombo;
	local tShowOnLabel;
	local tAurasCombo;
	local tPresetCombo;
	local tAurasLabel;
	local tPresetLabel;
	local tMatchAnyCombo;
	local tMatchAllCombo;
	local tNeverShowCombo;
	local tDurationCombo;
	local tExcludeDispelCombo;
	local tIsConditionsDisabled;
	local tListEntriesPanel;
	local tColorTypeLabel;
	local tPrioritySlider;
	local tColorTypeCombo;
	local tCanColorBarCheck;
	local tCanColorTextCheck;
	local tCustomColorSwatch;
	local tCanUseCustomColor;
	local tCanUseGlow;
	local tGlowBarStyleCombo;
	local tGlowBarColorSwatch;
	local tEnabledCheck;
	local tDeleteButton;
	local tIsBuiltIn;
	local tInnerSlider;
	local tNewSpellCombo;
	local tAddSpellButton;
	local tNewBouquetCombo;
	local tAddBouquetButton;
	local tAddEmptyButton;
	local tIgnoreListButton;
	local tConditionsPanel;
	local tSoundCombo;
	local tSoundLabel;
	local tFrame;
	function VUHDO_initAuraGroupsRightPanel()

		tGroup = sSelectedGroupId and VUHDO_getAuraGroupRaw(sSelectedGroupId) or nil;
		tIsBuiltIn = tGroup and VUHDO_isBuiltInAuraGroup(sSelectedGroupId);

		tNameEditBox = _G["VuhDoNewOptionsAuraGroupsStorePanelNameEditBox"];
		tNameLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelNameLabel"];
		tTypeLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelTypeLabel"];
		tTypeCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelTypeCombo"];
		tShowOnLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelShowOnLabel"];
		tShowOnCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelShowOnCombo"];
		tAurasLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelAurasLabel"];
		tPresetLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelPresetLabel"];
		tAurasCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelAurasCombo"];
		tPresetCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelPresetCombo"];
		tMatchAnyCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanelConditionsMatchAnyCombo"];
		tMatchAllCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanelConditionsMatchAllCombo"];
		tNeverShowCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanelConditionsNeverShowCombo"];
		tDurationCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanelDurationCombo"];
		tExcludeDispelCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanelExcludeDispelCombo"];
		tListEntriesPanel = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanel"];
		tColorTypeLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelColorTypeLabel"];
		tPrioritySlider = _G["VuhDoNewOptionsAuraGroupsStorePanelPrioritySlider"];
		tColorTypeCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelColorTypeCombo"];
		tCanColorBarCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelCanColorBarCheckButton"];
		tCanColorTextCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelCanColorTextCheckButton"];
		tCustomColorSwatch = _G["VuhDoNewOptionsAuraGroupsStorePanelCustomColorTexture"];
		tGlowBarStyleCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelGlowBarStyleCombo"];
		tGlowBarColorSwatch = _G["VuhDoNewOptionsAuraGroupsStorePanelGlowBarColorTexture"];
		tDeleteButton = _G["VuhDoNewOptionsAuraGroupsStorePanelDeleteButton"];
		tEnabledCheck = _G["VuhDoNewOptionsAuraGroupsStorePanelEnabledCheckButton"];
		tIgnoreListButton = _G["VuhDoNewOptionsAuraGroupsStorePanelIgnoreListButton"];
		tConditionsPanel = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanel"];
		tSoundCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelSoundCombo"];
		tSoundLabel = _G["VuhDoNewOptionsAuraGroupsStorePanelSoundLabel"];

		if tDeleteButton then
			if tGroup and not tIsBuiltIn then
				tDeleteButton:Enable();
				tDeleteButton:SetAlpha(1);
			else
				tDeleteButton:Disable();
				tDeleteButton:SetAlpha(0.5);
			end
		end

		if tNameEditBox and tGroup then
			tNameEditBox:Show();

			if tIsBuiltIn then
				tNameEditBox:SetText(VUHDO_getAuraGroupDisplayName(sSelectedGroupId) or "");
				tNameEditBox:SetCursorPosition(0);

				tNameEditBox:Disable();
				tNameEditBox:SetAlpha(0.5);
			else
				tNameEditBox:SetText(tGroup["displayName"] or "");
				tNameEditBox:SetCursorPosition(0);

				tNameEditBox:Enable();
				tNameEditBox:SetAlpha(1);
			end
		end

		if tNameLabel and tGroup then
			if tIsBuiltIn then
				tNameLabel:SetAlpha(0.5);
			else
				tNameLabel:SetAlpha(1);
			end
		end

		if tTypeLabel and tTypeCombo then
			if tGroup then
				tTypeLabel:Show();
				tTypeCombo:Show();

				VUHDO_AURA_GROUPS_TYPE_SELECTED = tGroup["type"] or 1;

				VUHDO_lnfComboBoxInitFromModel(tTypeCombo);

				if tIsBuiltIn then
					tTypeLabel:SetAlpha(0.5);
					tTypeCombo:Disable();
					tTypeCombo:SetAlpha(0.5);
				else
					tTypeLabel:SetAlpha(1);
					tTypeCombo:Enable();
					tTypeCombo:SetAlpha(1);
				end
			else
				tTypeLabel:Hide();
				tTypeCombo:Hide();
			end
		end

		if tShowOnLabel and tShowOnCombo then
			if tGroup then
				tShowOnLabel:Show();
				tShowOnCombo:Show();

				VUHDO_AURA_GROUPS_SHOW_ON = tGroup["unitScope"] or VUHDO_AURA_GROUP_UNIT_SCOPE_BOTH;

				VUHDO_lnfComboBoxInitFromModel(tShowOnCombo);

				if tIsBuiltIn then
					tShowOnLabel:SetAlpha(0.5);
					tShowOnCombo:Disable();
					tShowOnCombo:SetAlpha(0.5);
				else
					tShowOnLabel:SetAlpha(1);
					tShowOnCombo:Enable();
					tShowOnCombo:SetAlpha(1);
				end
			else
				tShowOnLabel:Hide();
				tShowOnCombo:Hide();
			end
		end

		if not tGroup then
			if tIgnoreListButton then
				tIgnoreListButton:Show();
				tIgnoreListButton:Disable();
				tIgnoreListButton:SetAlpha(0.5);
			end

			if tConditionsPanel then
				tConditionsPanel:Hide();
			end

			if tAurasLabel then
				tAurasLabel:Hide();
			end

			if tPresetLabel then
				tPresetLabel:Hide();
			end

			if tAurasCombo then
				tAurasCombo:Hide();
			end

			if tPresetCombo then
				tPresetCombo:Hide();
			end

			if tListEntriesPanel then
				tListEntriesPanel:Hide();
			end
		elseif (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST then
			if tIgnoreListButton then
				tIgnoreListButton:Hide();
			end

			if tConditionsPanel then
				tConditionsPanel:Hide();
			end

			if tAurasLabel then
				tAurasLabel:Hide();
			end

			if tPresetLabel then
				tPresetLabel:Hide();
			end

			if tAurasCombo then
				tAurasCombo:Hide();
			end

			if tPresetCombo then
				tPresetCombo:Hide();
			end

			VUHDO_auraGroupsSyncConditionModels(tGroup);

			if tListEntriesPanel then
				if VUHDO_initBouquetComboModel then
					VUHDO_initBouquetComboModel();
				end

				VUHDO_initAuraGroupsAddSpellComboModel();

				tNewSpellCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelNewSpellCombo"];

				if tNewSpellCombo then
					tFrame = _G[tNewSpellCombo:GetName() .. "EditBox"];

					if tFrame then
						tFrame:SetText("");
					end

					VUHDO_AURA_GROUPS_ADD_SPELL_SELECTED = "";
					VUHDO_lnfComboBoxInitFromModel(tNewSpellCombo);
				end

				tListEntriesPanel:Show();
				VUHDO_auraGroupsRefreshListEntries();

				tAddSpellButton = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelAddSpellButton"];
				tNewBouquetCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelNewBouquetCombo"];
				tAddBouquetButton = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelAddBouquetButton"];
				tAddEmptyButton = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelAddEmptyButton"];

				if tIsBuiltIn then
					if tNewSpellCombo then
						tNewSpellCombo:Disable();
						tNewSpellCombo:SetAlpha(0.5);
					end

					if tAddSpellButton then
						tAddSpellButton:Disable();
						tAddSpellButton:SetAlpha(0.5);
					end

					if tNewBouquetCombo then
						tNewBouquetCombo:Disable();
						tNewBouquetCombo:SetAlpha(0.5);
					end

					if tAddBouquetButton then
						tAddBouquetButton:Disable();
						tAddBouquetButton:SetAlpha(0.5);
					end

					if tAddEmptyButton then
						tAddEmptyButton:Disable();
						tAddEmptyButton:SetAlpha(0.5);
					end
				else
					if tNewSpellCombo then
						tNewSpellCombo:Enable();
						tNewSpellCombo:SetAlpha(1);
					end

					if tAddSpellButton then
						tAddSpellButton:Enable();
						tAddSpellButton:SetAlpha(1);
					end

					if tNewBouquetCombo then
						tNewBouquetCombo:Enable();
						tNewBouquetCombo:SetAlpha(1);
					end

					if tAddBouquetButton then
						tAddBouquetButton:Enable();
						tAddBouquetButton:SetAlpha(1);
					end

					if tAddEmptyButton then
						tAddEmptyButton:Enable();
						tAddEmptyButton:SetAlpha(1);
					end
				end
			end

			if tColorTypeLabel and tListEntriesPanel then
				tColorTypeLabel:ClearAllPoints();
				tColorTypeLabel:SetPoint("TOPLEFT", tListEntriesPanel, "BOTTOMLEFT", 0, -16);
			end
		else
			if tAurasLabel then
				tAurasLabel:Show();
				tAurasLabel:SetAlpha((tIsBuiltIn or tGroup["isInferred"]) and 0.5 or 1);
			end

			if tPresetLabel then
				tPresetLabel:Show();
				tPresetLabel:SetAlpha((tIsBuiltIn or tGroup["isInferred"]) and 0.5 or 1);
			end

			tIsConditionsDisabled = tIsBuiltIn or tGroup["isInferred"];

			VUHDO_auraGroupsSyncConditionModels(tGroup);

			VUHDO_initAuraGroupConditionComboModels();

			if tConditionsPanel then
				tConditionsPanel:Show();
			end

			if tAurasCombo then
				tAurasCombo:SetShown(true);
				VUHDO_lnfComboBoxInitFromModel(tAurasCombo);
				tAurasCombo:Enable();
				tAurasCombo:SetAlpha(1);

				if tIsConditionsDisabled then
					tAurasCombo:Disable();
					tAurasCombo:SetAlpha(0.5);
				end
			end

			if tPresetCombo then
				tPresetCombo:SetShown(true);
				VUHDO_lnfComboBoxInitFromModel(tPresetCombo);
				tPresetCombo:Enable();
				tPresetCombo:SetAlpha(1);

				if tIsConditionsDisabled then
					tPresetCombo:Disable();
					tPresetCombo:SetAlpha(0.5);
				end
			end

			if tListEntriesPanel then
				tListEntriesPanel:Hide();
			end

			if tConditionsPanel then

				if tMatchAnyCombo then
					VUHDO_lnfComboBoxInitFromModel(tMatchAnyCombo);

					if tIsConditionsDisabled then
						tMatchAnyCombo:Disable();
						tMatchAnyCombo:SetAlpha(0.5);
					else
						tMatchAnyCombo:Enable();
						tMatchAnyCombo:SetAlpha(1);
					end

					VUHDO_lnfComboRefreshItemStates(tMatchAnyCombo);
				end

				if tMatchAllCombo then
					VUHDO_lnfComboBoxInitFromModel(tMatchAllCombo);

					if tIsConditionsDisabled then
						tMatchAllCombo:Disable();
						tMatchAllCombo:SetAlpha(0.5);
					else
						tMatchAllCombo:Enable();
						tMatchAllCombo:SetAlpha(1);
					end

					VUHDO_lnfComboRefreshItemStates(tMatchAllCombo);
				end

				if tNeverShowCombo then
					VUHDO_lnfComboBoxInitFromModel(tNeverShowCombo);

					if tIsConditionsDisabled then
						tNeverShowCombo:Disable();
						tNeverShowCombo:SetAlpha(0.5);
					else
						tNeverShowCombo:Enable();
						tNeverShowCombo:SetAlpha(1);
					end

					VUHDO_lnfComboRefreshItemStates(tNeverShowCombo);
				end

				if tDurationCombo then
					VUHDO_lnfComboBoxInitFromModel(tDurationCombo);

					if tIsConditionsDisabled then
						tDurationCombo:Disable();
						tDurationCombo:SetAlpha(0.5);
					else
						tDurationCombo:Enable();
						tDurationCombo:SetAlpha(1);
					end
				end

				if tExcludeDispelCombo then
					VUHDO_lnfComboBoxInitFromModel(tExcludeDispelCombo);

					if tIsConditionsDisabled then
						tExcludeDispelCombo:Disable();
						tExcludeDispelCombo:SetAlpha(0.5);
					else
						tExcludeDispelCombo:Enable();
						tExcludeDispelCombo:SetAlpha(1);
					end

					VUHDO_lnfComboRefreshItemStates(tExcludeDispelCombo);
				end

				VUHDO_auraGroupsUpdateBranchHintLabel();
			end

			if tColorTypeLabel and tConditionsPanel then
				tColorTypeLabel:ClearAllPoints();
				VUHDO_PixelUtil.SetPoint(tColorTypeLabel, "TOPLEFT", tConditionsPanel, "BOTTOMLEFT", 0, -4);
			end

			if tIgnoreListButton then
				tIgnoreListButton:Show();

				if tIsBuiltIn then
					tIgnoreListButton:Disable();
					tIgnoreListButton:SetAlpha(0.5);
				else
					tIgnoreListButton:Enable();
					tIgnoreListButton:SetAlpha(1);
				end
			end
		end

		if tPrioritySlider and tGroup then
			tPrioritySlider:SetShown(true);
			tPrioritySlider:SetAlpha(1);

			VUHDO_AURA_GROUPS_PRIORITY = tGroup["priority"] or 50;

			tInnerSlider = _G[tPrioritySlider:GetName() .. "Slider"];
			VUHDO_lnfSliderInitFromModel(tInnerSlider);
			tInnerSlider:Enable();

			if tIsBuiltIn then
				tPrioritySlider:SetAlpha(0.5);
				tInnerSlider:Disable();
			end
		end

		if tSoundLabel and tSoundCombo and tGroup then
			tSoundLabel:SetShown(true);
			tSoundCombo:SetShown(true);

			VUHDO_AURA_GROUPS_SOUND = tGroup["sound"];

			VUHDO_lnfComboBoxInitFromModel(tSoundCombo);

			if tIsBuiltIn then
				tSoundLabel:SetAlpha(0.5);
				tSoundCombo:Disable();
				tSoundCombo:SetAlpha(0.5);
			else
				tSoundLabel:SetAlpha(1);
				tSoundCombo:Enable();
				tSoundCombo:SetAlpha(1);
			end
		end

		if tColorTypeCombo and tGroup then
			tColorTypeCombo:SetShown(true);

			VUHDO_AURA_GROUPS_COLOR_TYPE = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

			VUHDO_lnfComboBoxInitFromModel(tColorTypeCombo);
			tColorTypeCombo:Enable();
			tColorTypeCombo:SetAlpha(1);

			if tIsBuiltIn then
				tColorTypeCombo:Disable();
				tColorTypeCombo:SetAlpha(0.5);
			end

			if tColorTypeLabel then
				tColorTypeLabel:SetAlpha(tIsBuiltIn and 0.5 or 1);
			end
		end

		if tCanColorBarCheck and tGroup then
			tCanColorBarCheck:SetShown(true);

			VUHDO_AURA_GROUPS_CAN_COLOR_BAR = tGroup["canColorBar"];

			VUHDO_lnfCheckButtonInitFromModel(tCanColorBarCheck);

			if VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_OFF then
				tCanColorBarCheck:Disable();
				tCanColorBarCheck:SetAlpha(0.5);
			else
				tCanColorBarCheck:Enable();
				tCanColorBarCheck:SetAlpha(1);
			end

			if tIsBuiltIn then
				tCanColorBarCheck:Disable();
				tCanColorBarCheck:SetAlpha(0.5);
			end
		end

		if tCanColorTextCheck and tGroup then
			tCanColorTextCheck:SetShown(true);

			VUHDO_AURA_GROUPS_CAN_COLOR_TEXT = tGroup["canColorText"];

			VUHDO_lnfCheckButtonInitFromModel(tCanColorTextCheck);

			if VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_OFF then
				tCanColorTextCheck:Disable();
				tCanColorTextCheck:SetAlpha(0.5);
			else
				tCanColorTextCheck:Enable();
				tCanColorTextCheck:SetAlpha(1);
			end

			if tIsBuiltIn then
				tCanColorTextCheck:Disable();
				tCanColorTextCheck:SetAlpha(0.5);
			end
		end

		if tCustomColorSwatch and tGroup then
			tCustomColorSwatch:SetShown(true);

			if not tIsBuiltIn then
				VUHDO_CONFIG["AURA_GROUPS"] = VUHDO_CONFIG["AURA_GROUPS"] or { };

				if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
					VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] = { };
				end

				if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["customColor"] then
					VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["customColor"] = tGroup["customColor"] and VUHDO_deepCopyTable(tGroup["customColor"]) or {
						["R"] = 0.6, ["G"] = 0.3, ["B"] = 0, ["O"] = 1,
						["TR"] = 0.8, ["TG"] = 0.5, ["TB"] = 0, ["TO"] = 1,
						["useBackground"] = true, ["useText"] = true, ["useOpacity"] = true,
					};
				end

				VUHDO_lnfSetModel(tCustomColorSwatch, "VUHDO_CONFIG.AURA_GROUPS." .. sSelectedGroupId .. ".customColor");
				tCustomColorSwatch:SetAttribute("custom_function_post", VUHDO_auraGroupsCustomColorChanged);

				tCanUseCustomColor = VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_CUSTOM and (VUHDO_AURA_GROUPS_CAN_COLOR_BAR or VUHDO_AURA_GROUPS_CAN_COLOR_TEXT);

				tCustomColorSwatch:SetAttribute("disabled", not tCanUseCustomColor);
				tCustomColorSwatch:SetAlpha(tCanUseCustomColor and 1 or 0.5);
			else
				VUHDO_lnfSetModel(tCustomColorSwatch, "VUHDO_DEFAULT_AURA_GROUPS." .. sSelectedGroupId .. ".customColor");

				tCustomColorSwatch:SetAttribute("disabled", true);
				tCustomColorSwatch:SetAlpha(0.5);
			end

			VUHDO_lnfInitColorSwatch(tCustomColorSwatch, VUHDO_I18N_AURA_GROUP_CUSTOM_COLOR, VUHDO_I18N_AURA_GROUP_CUSTOM_COLOR);
			VUHDO_lnfSetTooltip(tCustomColorSwatch, VUHDO_I18N_TT.K616);
			VUHDO_lnfColorSwatchInitFromModel(tCustomColorSwatch);
		end

		if tGlowBarStyleCombo and tGroup then
			tGlowBarStyleCombo:SetShown(true);

			VUHDO_AURA_GROUPS_GLOW_BAR_STYLE = tGroup["glowBarStyle"] or (tGroup["canGlowBar"] == true and VUHDO_DEFAULT_AURA_GLOW_STYLE or "none");
			VUHDO_AURA_GROUPS_CAN_GLOW_BAR = "none" ~= VUHDO_AURA_GROUPS_GLOW_BAR_STYLE;

			VUHDO_initGlowStyleComboModel();
			VUHDO_lnfComboBoxInitFromModel(tGlowBarStyleCombo);

			if VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_OFF then
				tGlowBarStyleCombo:Disable();
				tGlowBarStyleCombo:SetAlpha(0.5);
			elseif tIsBuiltIn then
				tGlowBarStyleCombo:Disable();
				tGlowBarStyleCombo:SetAlpha(0.5);
			else
				tGlowBarStyleCombo:Enable();
				tGlowBarStyleCombo:SetAlpha(1);
			end
		end

		if tGlowBarColorSwatch and tGroup then
			tGlowBarColorSwatch:SetShown(true);

			if not tIsBuiltIn then
				VUHDO_CONFIG["AURA_GROUPS"] = VUHDO_CONFIG["AURA_GROUPS"] or { };

				if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
					VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] = { };
				end

				if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["glowBarColor"] then
					VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["glowBarColor"] = (VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"] and VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF_BAR_GLOW"]) and VUHDO_deepCopyTable(VUHDO_PANEL_SETUP["BAR_COLORS"]["DEBUFF_BAR_GLOW"]) or { ["R"] = 0.95, ["G"] = 0.95, ["B"] = 0.32, ["O"] = 1 };
				end

				VUHDO_lnfSetModel(tGlowBarColorSwatch, "VUHDO_CONFIG.AURA_GROUPS." .. sSelectedGroupId .. ".glowBarColor");

				tGlowBarColorSwatch:SetAttribute("custom_function_post", VUHDO_auraGroupsGlowColorChanged);

				tCanUseGlow = VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_CUSTOM and "none" ~= VUHDO_AURA_GROUPS_GLOW_BAR_STYLE;

				tGlowBarColorSwatch:SetAttribute("disabled", not tCanUseGlow);
				tGlowBarColorSwatch:SetAlpha(tCanUseGlow and 1 or 0.5);
			else
				VUHDO_lnfSetModel(tGlowBarColorSwatch, "VUHDO_DEFAULT_AURA_GROUPS." .. sSelectedGroupId .. ".glowBarColor");

				tGlowBarColorSwatch:SetAttribute("disabled", true);
				tGlowBarColorSwatch:SetAlpha(0.5);
			end

			VUHDO_lnfInitColorSwatch(tGlowBarColorSwatch, VUHDO_I18N_AURA_GLOW_BAR, VUHDO_I18N_AURA_GLOW_BAR);
			VUHDO_lnfSetTooltip(tGlowBarColorSwatch, VUHDO_I18N_TT.K780);
			VUHDO_lnfColorSwatchInitFromModel(tGlowBarColorSwatch);
			VUHDO_lnfUpdateComponentsByConstraints(tGlowBarColorSwatch);
		end

		if tEnabledCheck and tGroup then
			tEnabledCheck:SetShown(true);

			if tIsBuiltIn then
				VUHDO_AURA_GROUPS_ENABLED = not (VUHDO_CONFIG["AURA_GROUP_DISABLED"] and VUHDO_CONFIG["AURA_GROUP_DISABLED"][sSelectedGroupId]);
			else
				VUHDO_AURA_GROUPS_ENABLED = tGroup["enabled"] ~= false;
			end

			VUHDO_lnfCheckButtonInitFromModel(tEnabledCheck);

			tEnabledCheck:Enable();
			tEnabledCheck:SetAlpha(1);
		end

		if not tGroup then
			if tColorTypeLabel and tAurasCombo then
				tColorTypeLabel:ClearAllPoints();
				tColorTypeLabel:SetPoint("TOPLEFT", tAurasCombo, "BOTTOMLEFT", 0, -8);
				tColorTypeLabel:SetAlpha(0.5);
			end

			VUHDO_AURA_GROUPS_ENABLED = false;
			VUHDO_AURA_GROUPS_PRIORITY = 50;
			VUHDO_AURA_GROUPS_COLOR_TYPE = 1;
			VUHDO_AURA_GROUPS_AURAS_SELECTED = "HARMFUL";
			VUHDO_AURA_GROUPS_PRESET_SELECTED = "";
			VUHDO_AURA_GROUPS_DURATION_SELECTED = VUHDO_AURA_DURATION_COMBO_NONE;
			VUHDO_AURA_GROUPS_CAN_COLOR_BAR = false;
			VUHDO_AURA_GROUPS_CAN_COLOR_TEXT = false;
			VUHDO_AURA_GROUPS_CAN_GLOW_BAR = false;
			VUHDO_AURA_GROUPS_SOUND = nil;
			VUHDO_AURA_GROUPS_SHOW_ON = VUHDO_AURA_GROUP_UNIT_SCOPE_BOTH;

			if tNameEditBox then
				tNameEditBox:Show();
				tNameEditBox:SetText("");
				tNameEditBox:Disable();
				tNameEditBox:SetAlpha(0.5);
			end

			if tAurasLabel then
				tAurasLabel:Show();
				tAurasLabel:SetAlpha(0.5);
			end

			if tPresetLabel then
				tPresetLabel:Show();
				tPresetLabel:SetAlpha(0.5);
			end

			if tAurasCombo then
				tAurasCombo:Show();
				tAurasCombo:Disable();
				tAurasCombo:SetAlpha(0.5);

				VUHDO_lnfComboBoxInitFromModel(tAurasCombo);
			end

			if tPresetCombo then
				tPresetCombo:Show();
				tPresetCombo:Disable();
				tPresetCombo:SetAlpha(0.5);

				VUHDO_lnfComboBoxInitFromModel(tPresetCombo);
			end

			if tConditionsPanel then
				tConditionsPanel:Hide();
			end

			if tPrioritySlider then
				tPrioritySlider:Show();
				tInnerSlider = _G[tPrioritySlider:GetName() .. "Slider"];

				if tInnerSlider then
					VUHDO_lnfSliderInitFromModel(tInnerSlider);

					tInnerSlider:Disable();
				end

				tPrioritySlider:SetAlpha(0.5);
			end

			if tSoundLabel then
				tSoundLabel:Show();
				tSoundLabel:SetAlpha(0.5);
			end

			if tSoundCombo then
				tSoundCombo:Show();
				tSoundCombo:Disable();
				tSoundCombo:SetAlpha(0.5);

				VUHDO_lnfComboBoxInitFromModel(tSoundCombo);
			end

			if tColorTypeCombo then
				tColorTypeCombo:Show();
				tColorTypeCombo:Disable();
				tColorTypeCombo:SetAlpha(0.5);

				VUHDO_lnfComboBoxInitFromModel(tColorTypeCombo);
			end

			if tCanColorBarCheck then
				tCanColorBarCheck:Show();
				tCanColorBarCheck:Disable();
				tCanColorBarCheck:SetAlpha(0.5);

				VUHDO_lnfCheckButtonInitFromModel(tCanColorBarCheck);
			end

			if tCanColorTextCheck then
				tCanColorTextCheck:Show();
				tCanColorTextCheck:Disable();
				tCanColorTextCheck:SetAlpha(0.5);

				VUHDO_lnfCheckButtonInitFromModel(tCanColorTextCheck);
			end

			if tCustomColorSwatch then
				tCustomColorSwatch:Show();
				tCustomColorSwatch:SetAlpha(0.5);
			end

			if tGlowBarStyleCombo then
				tGlowBarStyleCombo:Show();
				tGlowBarStyleCombo:Disable();
				tGlowBarStyleCombo:SetAlpha(0.5);

				VUHDO_lnfComboBoxInitFromModel(tGlowBarStyleCombo);
			end

			if tGlowBarColorSwatch then
				tGlowBarColorSwatch:Show();
				tGlowBarColorSwatch:SetAlpha(0.5);
			end

			if tEnabledCheck then
				tEnabledCheck:Show();
				tEnabledCheck:Disable();
				tEnabledCheck:SetAlpha(0.5);

				VUHDO_lnfCheckButtonInitFromModel(tEnabledCheck);
			end

			if tShowOnCombo then
				tShowOnCombo:Show();
				tShowOnCombo:Disable();
				tShowOnCombo:SetAlpha(0.5);

				VUHDO_lnfComboBoxInitFromModel(tShowOnCombo);
			end

			if tShowOnLabel then
				tShowOnLabel:Show();
				tShowOnLabel:SetAlpha(0.5);
			end
		end

		return;

	end
end



--
function VUHDO_auraGroupsRefreshRightPanel()

	VUHDO_auraGroupsRunRefresh(VUHDO_initAuraGroupsRightPanel);

	return;

end



--
local tNewId;
function VUHDO_auraGroupsOnNewGroup()

	tNewId = VUHDO_generateAuraGroupId();

	VUHDO_CONFIG["AURA_GROUPS"][tNewId] = {
		["type"] = VUHDO_AURA_GROUP_TYPE_FILTER,
		["filter"] = "HELPFUL|PLAYER",
		["excludeFilter"] = nil,
		["priority"] = VUHDO_getNextAuraGroupPriority(),
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = true,
		["canColorText"] = true,
		["canGlowBar"] = false,
		["glowBarStyle"] = nil,
		["glowBarColor"] = nil,
		["enabled"] = true,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["displayName"] = VUHDO_ensureUniqueAuraGroupDisplayName(VUHDO_I18N_NEW .. " " .. VUHDO_I18N_GROUP),
		["isHarmful"] = false,
		["sound"] = nil,
	};

	VUHDO_resolveAuraGroupFilter(VUHDO_CONFIG["AURA_GROUPS"][tNewId]);

	sSelectedGroupId = tNewId;
	VUHDO_AURA_GROUPS_SELECTED = tNewId;

	VUHDO_auraGroupsRefreshList();
	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
local tNewId;
local tSourceGroup;
function VUHDO_auraGroupsOnCloneGroup(aSourceId)

	tSourceGroup = VUHDO_getAuraGroupRaw(aSourceId);

	if not tSourceGroup then
		return;
	end

	tNewId = VUHDO_cloneAuraGroup(aSourceId, VUHDO_ensureUniqueAuraGroupDisplayName(VUHDO_getAuraGroupDisplayName(aSourceId) .. " (Copy)"));

	if tNewId then
		VUHDO_resolveAuraGroupFilter(VUHDO_CONFIG["AURA_GROUPS"][tNewId]);

		sSelectedGroupId = tNewId;
		VUHDO_AURA_GROUPS_SELECTED = tNewId;

		VUHDO_auraGroupsRefreshList();
		VUHDO_auraGroupsRefreshRightPanel();
	end

	return;

end



--
function VUHDO_auraGroupsOnDeleteGroup(aGroupId)

	if VUHDO_isBuiltInAuraGroup(aGroupId) then
		return;
	end

	VUHDO_CONFIG["AURA_GROUPS"][aGroupId] = nil;
	sSelectedGroupId = nil;
	VUHDO_AURA_GROUPS_SELECTED = nil;

	VUHDO_auraGroupsRefreshList();
	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
function VUHDO_auraGroupsTypeChanged(aComboBox, aValue, anArrayModel)

	if sRefreshDepth > 0 then
		return;
	end

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["type"] = tonumber(aValue) or 1;

	if (tonumber(aValue) or 1) == VUHDO_AURA_GROUP_TYPE_LIST then
		if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["entries"] then
			VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["entries"] = { };
		end
	else
		if not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["filter"] then
			VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["filter"] = "HELPFUL|PLAYER";
		end
	end

	VUHDO_resolveAuraGroupFilter(VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]);

	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
local tPresetCombo;
function VUHDO_auraGroupsClearPresetSelection()

	VUHDO_AURA_GROUPS_PRESET_SELECTED = "";

	tPresetCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelPresetCombo"];

	if tPresetCombo then
		_G[tPresetCombo:GetName() .. "Text"]:SetText(VUHDO_I18N_CUSTOM);
	end

	return;

end



--
local tGroup;
local tMatchAnyCombo;
local tMatchAllCombo;
local tNeverShowCombo;
function VUHDO_auraGroupsConditionsChanged(aComboBox, aValue, anArrayModel)

	if sRefreshDepth > 0 then
		return;
	end

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	VUHDO_auraGroupsEnforceConditionExclusions(aComboBox, aValue);

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	VUHDO_auraGroupsWriteConditions(tGroup);

	VUHDO_auraGroupsClearPresetSelection();

	VUHDO_auraGroupsUpdateBranchHintLabel();

	tMatchAnyCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanelConditionsMatchAnyCombo"];
	tMatchAllCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanelConditionsMatchAllCombo"];
	tNeverShowCombo = _G["VuhDoNewOptionsAuraGroupsStorePanelConditionsPanelConditionsNeverShowCombo"];

	if tMatchAnyCombo then
		VUHDO_lnfComboRefreshItemStates(tMatchAnyCombo);
	end

	if tMatchAllCombo then
		VUHDO_lnfComboRefreshItemStates(tMatchAllCombo);
	end

	if tNeverShowCombo then
		VUHDO_lnfComboRefreshItemStates(tNeverShowCombo);
	end

	VUHDO_timeRebuildAuraGroups(0.3);

	return;

end



--
function VUHDO_auraGroupsAurasChanged(aComboBox, aValue, anArrayModel)

	if sRefreshDepth > 0 then
		return;
	end

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	VUHDO_AURA_GROUPS_AURAS_SELECTED = aValue or "HARMFUL";

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	VUHDO_auraGroupsWriteConditions(tGroup);

	VUHDO_auraGroupsRefreshRightPanel();

	VUHDO_timeRebuildAuraGroups(0.3);

	return;

end



--
function VUHDO_auraGroupsPresetChanged(aComboBox, aValue, anArrayModel)

	if sRefreshDepth > 0 then
		return;
	end

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	if not aValue or aValue == "" then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	VUHDO_auraGroupsApplyPresetFilter(aValue);
	VUHDO_auraGroupsWriteConditions(tGroup);

	VUHDO_AURA_GROUPS_PRESET_SELECTED = aValue;

	VUHDO_auraGroupsRefreshRightPanel();
	VUHDO_timeRebuildAuraGroups(0.3);

	return;

end



--
function VUHDO_auraGroupsDurationChanged(aComboBox, aValue, anArrayModel)

	if sRefreshDepth > 0 then
		return;
	end

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	VUHDO_AURA_GROUPS_DURATION_SELECTED = tonumber(aValue) or VUHDO_AURA_DURATION_COMBO_NONE;

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	VUHDO_auraGroupsWriteConditions(tGroup);

	VUHDO_auraGroupsClearPresetSelection();

	VUHDO_timeRebuildAuraGroups(0.3);

	return;

end



--
local tFrame;
function VUHDO_auraGroupsIgnoreListShow()

	tFrame = _G["VuhDoNewOptionsAuraGroupsIgnoreListSettingsFrame"];

	if tFrame then
		VUHDO_auraGroupsRefreshIgnorePanel();
		tFrame:Show();
	end

	return;

end



--
function VUHDO_auraGroupsIgnoreListHide()

	tFrame = _G["VuhDoNewOptionsAuraGroupsIgnoreListSettingsFrame"];

	if tFrame then
		tFrame:Hide();
	end

	return;

end



--
function VUHDO_auraGroupsPriorityChanged(aComponent, aValue)

	if sRefreshDepth > 0 then
		return;
	end

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["priority"] = tonumber(aValue) or 50;
	end

	VUHDO_timeRebuildAuraGroups(0.3);

	return;

end



--
local tOldValue = nil;
local tSuccess;
function VUHDO_auraGroupsSoundSelect(aComboBox, aValue, anArrayModel)

	if sRefreshDepth > 0 then
		return;
	end

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"] and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["sound"] = (aValue ~= nil and aValue ~= "") and aValue or nil;

		VUHDO_timeRebuildAuraGroups(0.3);
	end

	if aValue ~= nil and tOldValue ~= aValue then
		tSuccess = VUHDO_playSoundFile(aValue);

		if tSuccess then
			tOldValue = aValue;
		end
	end

	return;

end



--
local tRootPane;
local tCombo;
local tEditBox;
local function VUHDO_getAuraGroupsIgnoreListWidgets()

	tFrame = _G["VuhDoNewOptionsAuraGroupsIgnoreListSettingsFrame"];

	tRootPane = tFrame and _G[tFrame:GetName() .. "RootPane"];
	tCombo = tRootPane and _G[tRootPane:GetName() .. "IgnoreCombo"];
	tEditBox = tCombo and _G[tCombo:GetName() .. "EditBox"];

	return tRootPane, tCombo, tEditBox;

end



--
local tGroup;
local tIgnoreList;
local tDisplayName;
local tFrame;
local function VUHDO_initAuraGroupsIgnorePanel()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then

		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if (tGroup["type"] or 1) ~= VUHDO_AURA_GROUP_TYPE_FILTER then
		return;
	end

	if not tGroup["ignoreList"] then
		tGroup["ignoreList"] = { };
	end

	tIgnoreList = tGroup["ignoreList"];
	table.wipe(VUHDO_AURA_GROUPS_IGNORE_COMBO_MODEL);

	VUHDO_AURA_GROUPS_IGNORE_SELECTED = "";

	for tName, _ in pairs(tIgnoreList) do
		tDisplayName = VUHDO_formatAuraSpellDisplayName(tName);

		tinsert(VUHDO_AURA_GROUPS_IGNORE_COMBO_MODEL, { tName, tDisplayName });
	end

	_, tCombo, tEditBox = VUHDO_getAuraGroupsIgnoreListWidgets();

	if tEditBox then
		tEditBox:SetText("");
	end

	if tCombo then
		VUHDO_lnfComboBoxInitFromModel(tCombo);
	end

	tFrame = _G["VuhDoNewOptionsAuraGroupsStorePanelGroupCombo"];

	if tFrame then
		VUHDO_initAuraGroupsComboModel();
		VUHDO_lnfComboBoxInitFromModel(tFrame);
	end

	return;

end



--
function VUHDO_auraGroupsRefreshIgnorePanel()

	VUHDO_auraGroupsRunRefresh(VUHDO_initAuraGroupsIgnorePanel);

	return;

end



--
local tText;
local tKey;
local tGroup;
local tDisplayName;
function VUHDO_auraGroupsIgnoreAdd()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if (tGroup["type"] or 1) ~= VUHDO_AURA_GROUP_TYPE_FILTER then
		return;
	end

	_, _, tEditBox = VUHDO_getAuraGroupsIgnoreListWidgets();

	if not tEditBox then
		return;
	end

	tText = tEditBox:GetText();

	if not tText or tText == "" then
		return;
	end

	tText = strtrim(tText);

	if tText == "" then
		return;
	end

	if not tGroup["ignoreList"] then
		tGroup["ignoreList"] = { };
	end

	tKey = tonumber(tText);

	if tKey then
		tGroup["ignoreList"][tKey] = true;
	else
		tGroup["ignoreList"][tText] = true;
	end

	tDisplayName = VUHDO_formatAuraSpellDisplayName(tText);
	VUHDO_Msg(string.format(VUHDO_I18N_AURA_ADDED_TO_IGNORE_LIST, tDisplayName));

	tEditBox:SetText("");

	VUHDO_invalidateAuraGroupFilterCache();

	VUHDO_auraGroupsRefreshIgnorePanel();

	return;

end



--
local tText;
local tSpellId;
local tKeyToRemove;
local tGroup;
local tDisplayName;
function VUHDO_auraGroupsIgnoreDelete()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if (tGroup["type"] or 1) ~= VUHDO_AURA_GROUP_TYPE_FILTER or not tGroup["ignoreList"] then
		return;
	end

	_, _, tEditBox = VUHDO_getAuraGroupsIgnoreListWidgets();

	if not tEditBox then
		return;
	end

	tText = tEditBox:GetText();

	if not tText or tText == "" then
		return;
	end

	if string.sub(tText, 1, 2) == "|c" and string.len(tText) > 10 then
		tText = string.sub(tText, 11);
	end

	if string.sub(tText, -2) == "|r" then
		tText = string.sub(tText, 1, -3);
	end

	tSpellId = string.match(tText, '^%[([^%]]+)%] (.+)$');

	if tSpellId then
		tText = tSpellId;
	end

	tText = strtrim(tText);
	tDisplayName = VUHDO_formatAuraSpellDisplayName(tText);

	tKeyToRemove = nil;

	if tonumber(tText) and tGroup["ignoreList"][tonumber(tText)] then
		tKeyToRemove = tonumber(tText);
	elseif tGroup["ignoreList"][tText] then
		tKeyToRemove = tText;
	end

	if tKeyToRemove then
		tGroup["ignoreList"][tKeyToRemove] = nil;

		VUHDO_Msg(string.format(VUHDO_I18N_AURA_REMOVED_FROM_IGNORE_LIST, tDisplayName));
	else
		VUHDO_Msg(string.format(VUHDO_I18N_AURA_DOES_NOT_EXIST_IN_IGNORE_LIST, tDisplayName));
	end

	VUHDO_invalidateAuraGroupFilterCache();

	VUHDO_auraGroupsRefreshIgnorePanel();

	return;

end



--
function VUHDO_auraGroupsColorTypeChanged(aComboBox, aValue, anArrayModel)

	if sRefreshDepth > 0 then
		return;
	end

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["colorType"] = aValue or VUHDO_AURA_GROUP_COLOR_OFF;
	end

	VUHDO_auraGroupsRefreshRightPanel();
	VUHDO_timeRebuildAuraGroups(0.3);
	VUHDO_timeRegisterBouquets(0.3);

	return;

end



--
local tShowOnGroup;
local tShowOnScope;
function VUHDO_auraGroupsShowOnChanged(aComboBox, aValue, anArrayModel)

	if sRefreshDepth > 0 then
		return;
	end

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tShowOnGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];
	tShowOnScope = aValue or VUHDO_AURA_GROUP_UNIT_SCOPE_BOTH;

	if (tShowOnGroup["unitScope"] or VUHDO_AURA_GROUP_UNIT_SCOPE_BOTH) == tShowOnScope then
		return;
	end

	tShowOnGroup["unitScope"] = tShowOnScope;

	VUHDO_invalidateAuraContainerTemplateCache();

	VUHDO_auraGroupsRefreshRightPanel();

	VUHDO_timeRebuildAuraGroups(0.3);
	VUHDO_timeRegisterBouquets(0.3);

	VUHDO_rebuildAuraAnchorsForAllButtons();

	return;

end



--
function VUHDO_auraGroupsCustomColorChanged(aColorSwatch)

	if sRefreshDepth > 0 then
		return;
	end

	VUHDO_timeRebuildAuraGroups(0.3);

	return;

end



--
local tCustomColorSwatchForUpdate;
local tCanUseCustomColorForUpdate;
function VUHDO_auraGroupsUpdateCustomColorSwatchState()

	tCustomColorSwatchForUpdate = _G["VuhDoNewOptionsAuraGroupsStorePanelCustomColorTexture"];

	if tCustomColorSwatchForUpdate and tCustomColorSwatchForUpdate:IsShown() then
		tCanUseCustomColorForUpdate = VUHDO_AURA_GROUPS_COLOR_TYPE == VUHDO_AURA_GROUP_COLOR_CUSTOM and (VUHDO_AURA_GROUPS_CAN_COLOR_BAR or VUHDO_AURA_GROUPS_CAN_COLOR_TEXT);

		tCustomColorSwatchForUpdate:SetAttribute("disabled", not tCanUseCustomColorForUpdate);
		tCustomColorSwatchForUpdate:SetAlpha(tCanUseCustomColorForUpdate and 1 or 0.5);
	end

	return;

end



--
function VUHDO_auraGroupsCanColorBarChanged(aParent, aValue)

	if sRefreshDepth > 0 then
		return;
	end

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["canColorBar"] = aValue;
	end

	VUHDO_timeRebuildAuraGroups(0.3);

	VUHDO_auraGroupsUpdateCustomColorSwatchState();

	return;

end



--
function VUHDO_auraGroupsCanColorTextChanged(aParent, aValue)

	if sRefreshDepth > 0 then
		return;
	end

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["canColorText"] = aValue;
	end

	VUHDO_timeRebuildAuraGroups(0.3);

	VUHDO_auraGroupsUpdateCustomColorSwatchState();

	return;

end



--
function VUHDO_auraGroupsGlowBarStyleChanged(aParent, aValue)

	if sRefreshDepth > 0 then
		return;
	end

	if sSelectedGroupId and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["canGlowBar"] = "none" ~= aValue;
		VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["glowBarStyle"] = "none" ~= aValue and aValue or nil;
	end

	VUHDO_AURA_GROUPS_CAN_GLOW_BAR = "none" ~= aValue;

	VUHDO_timeRebuildAuraGroups(0.3);

	VUHDO_auraGroupsRefreshRightPanel();

	return;

end



--
function VUHDO_auraGroupsGlowColorChanged(aColorSwatch)

	if sRefreshDepth > 0 then
		return;
	end

	VUHDO_timeRebuildAuraGroups(0.3);

	return;

end



--
function VUHDO_auraGroupsEnabledChanged(aParent, aValue)

	if sRefreshDepth > 0 then
		return;
	end

	if not sSelectedGroupId then
		return;
	end

	if VUHDO_isBuiltInAuraGroup(sSelectedGroupId) then
		if not VUHDO_CONFIG["AURA_GROUP_DISABLED"] then
			VUHDO_CONFIG["AURA_GROUP_DISABLED"] = { };
		end

		if aValue then
			VUHDO_CONFIG["AURA_GROUP_DISABLED"][sSelectedGroupId] = nil;
		else
			VUHDO_CONFIG["AURA_GROUP_DISABLED"][sSelectedGroupId] = true;
		end
	else
		if VUHDO_CONFIG["AURA_GROUPS"] and VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
			VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["enabled"] = aValue;
		end
	end

	VUHDO_timeRebuildAuraGroups(0.3);

	VUHDO_auraGroupsRefreshList();

	VUHDO_timeRegisterBouquets(0.3);
	VUHDO_timeReloadUI(0.3, true);

	return;

end



--
local function VUHDO_getOrCreateAuraGroupEntryItem(anIndex, aParent)

	if sAuraGroupEntryItems[anIndex] == nil then
		sAuraGroupEntryItems[anIndex] = CreateFrame("Frame", "VuhDoAuraGroupEntry" .. anIndex, aParent, "VuhDoAuraGroupListEntryTemplate");
	end

	return sAuraGroupEntryItems[anIndex];

end



--
local tRowName;
local tIcon;
local tSpellId;
local tValueLabel;
local tTypeLabel;
local tTypeLabelFrame;
local tBouquetButton;
local tSpellButton;
local tRemoveButton;
local tUpButton;
local tDownButton;
local function VUHDO_initAuraGroupEntryItem(aParent, anItemPanel, anIndex, anEntry, anIsBuiltIn)

	anItemPanel["vuhdo_entryIdx"] = anIndex;

	anItemPanel:ClearAllPoints();
	VUHDO_PixelUtil.SetPoint(anItemPanel, "TOPLEFT", aParent:GetName(), "TOPLEFT", 0, -(anIndex - 1) * VUHDO_AURA_GROUP_LIST_ENTRY_ROW_HEIGHT);

	tRowName = anItemPanel:GetName();

	tIcon = _G[tRowName .. "IconTexture"];

	if tIcon then
		if anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_EMPTY then
			tIcon:SetTexture(nil);
		elseif anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
			tSpellId = VUHDO_resolveAuraContainerPreferredSpellId(anEntry["value"]);

			tIcon:SetTexture(VUHDO_getGlobalIcon(tostring(tSpellId or anEntry["value"])));
		else
			tIcon:SetTexture(VUHDO_getGlobalIcon(tostring(anEntry["value"])));
		end
	end

	tValueLabel = _G[tRowName .. "ValueLabelLabel"];

	if tValueLabel then
		if anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_EMPTY then
			tValueLabel:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_EMPTY);
		else
			tValueLabel:SetText(VUHDO_formatAuraSpellDisplayName(tostring(anEntry["value"] or "")));
		end

		tValueLabel:SetTextColor(0.4, 0.4, 1, 1);
	end

	tTypeLabel = _G[tRowName .. "TypeLabelLabel"];
	tTypeLabelFrame = _G[tRowName .. "TypeLabel"];
	tBouquetButton = _G[tRowName .. "BouquetButton"];
	tSpellButton = _G[tRowName .. "SpellButton"];

	if tTypeLabel then
		if anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_EMPTY then
			tTypeLabel:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_EMPTY);
		elseif anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
			tTypeLabel:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_BOUQUET);
		else
			tTypeLabel:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_SPELL);
		end
	end

	if tTypeLabelFrame and tBouquetButton and tSpellButton then
		if anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
			tTypeLabelFrame:Hide();
			tBouquetButton:Show();
			tSpellButton:Hide();

			tBouquetButton:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_BOUQUET);

			VUHDO_lnfSetTooltip(tBouquetButton, VUHDO_I18N_TT.K732);
		elseif anEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
			tTypeLabelFrame:Hide();
			tBouquetButton:Hide();
			tSpellButton:Show();

			tSpellButton:SetText(VUHDO_I18N_AURA_GROUP_ENTRY_SPELL);

			VUHDO_lnfSetTooltip(tSpellButton, VUHDO_I18N_TT.K781);
		else
			tTypeLabelFrame:Show();
			tBouquetButton:Hide();
			tSpellButton:Hide();
		end
	end

	tRemoveButton = _G[tRowName .. "RemoveButton"];
	tUpButton = _G[tRowName .. "UpButton"];
	tDownButton = _G[tRowName .. "DownButton"];

	if tRemoveButton then
		tRemoveButton:SetText("");
		VUHDO_lnfSetTooltip(tRemoveButton, VUHDO_I18N_TT.K726);
	end

	if tUpButton then
		VUHDO_lnfSetTooltip(tUpButton, VUHDO_I18N_TT.K727);
	end

	if tDownButton then
		VUHDO_lnfSetTooltip(tDownButton, VUHDO_I18N_TT.K728);
	end

	if anIsBuiltIn then
		if tBouquetButton then
			tBouquetButton:Disable();
			tBouquetButton:SetAlpha(0.5);
		end

		if tSpellButton then
			tSpellButton:Disable();
			tSpellButton:SetAlpha(0.5);
		end

		if tRemoveButton then
			tRemoveButton:Disable();
			tRemoveButton:SetAlpha(0.5);
		end

		if tUpButton then
			tUpButton:Disable();
			tUpButton:SetAlpha(0.5);
		end

		if tDownButton then
			tDownButton:Disable();
			tDownButton:SetAlpha(0.5);
		end
	else
		if tBouquetButton then
			tBouquetButton:Enable();
			tBouquetButton:SetAlpha(1);
		end

		if tSpellButton then
			tSpellButton:Enable();
			tSpellButton:SetAlpha(1);
		end

		if tRemoveButton then
			tRemoveButton:Enable();
			tRemoveButton:SetAlpha(1);
		end

		if tUpButton then
			tUpButton:Enable();
			tUpButton:SetAlpha(1);
		end

		if tDownButton then
			tDownButton:Enable();
			tDownButton:SetAlpha(1);
		end
	end

	anItemPanel:Show();

	return;

end



--
local tPanel;
local tGroup;
local tEntries;
local tEntryScrollChild;
local tIsBuiltInList;
local function VUHDO_initAuraGroupsListEntries()

	for _, tPanel in pairs(sAuraGroupEntryItems) do
		tPanel:Hide();
	end

	if not sSelectedGroupId then
		return;
	end

	tGroup = VUHDO_getAuraGroupRaw(sSelectedGroupId);

	if not tGroup or (tGroup["type"] or 1) ~= VUHDO_AURA_GROUP_TYPE_LIST then
		return;
	end

	tIsBuiltInList = VUHDO_isBuiltInAuraGroup(sSelectedGroupId);

	tEntries = tGroup["entries"] or { };
	tEntryScrollChild = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelEntryScrollEntryScrollChild"];

	if not tEntryScrollChild then
		return;
	end

	for tIdx, tEntry in ipairs(tEntries) do
		tPanel = VUHDO_getOrCreateAuraGroupEntryItem(tIdx, tEntryScrollChild);
		VUHDO_initAuraGroupEntryItem(tEntryScrollChild, tPanel, tIdx, tEntry, tIsBuiltInList);
	end

	if #tEntries > 0 then
		VUHDO_PixelUtil.SetHeight(tEntryScrollChild, #tEntries * VUHDO_AURA_GROUP_LIST_ENTRY_ROW_HEIGHT);
	else
		VUHDO_PixelUtil.SetHeight(tEntryScrollChild, VUHDO_AURA_GROUP_LIST_ENTRY_ROW_HEIGHT);
	end

	VUHDO_initEntrySettingsCache();

	VUHDO_invalidateAuraContainerTemplateCache();

	return;

end



--
function VUHDO_auraGroupsRefreshListEntries()

	VUHDO_auraGroupsRunRefresh(VUHDO_initAuraGroupsListEntries);

	return;

end



--
local tSpellComboEditBox;
local tText;
local tValue;
local tSpellIdFromMatch;
function VUHDO_auraGroupsListAddSpell()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if tGroup["type"] ~= VUHDO_AURA_GROUP_TYPE_LIST then
		return;
	end

	tSpellComboEditBox = _G["VuhDoNewOptionsAuraGroupsStorePanelListEntriesPanelNewEntryPanelNewSpellComboEditBox"];

	if not tSpellComboEditBox then
		return;
	end

	tText = tSpellComboEditBox:GetText();

	if not tText or tText == "" then
		return;
	end

	tText = strtrim(tText);

	if tText == "" then
		return;
	end

	tSpellIdFromMatch = string.match(tText, "^%[([^%]]+)%]");

	if tSpellIdFromMatch then
		tValue = tonumber(tSpellIdFromMatch) or tSpellIdFromMatch;
	else
		tValue = tonumber(tText) or tText;
	end

	if not tGroup["entries"] then
		tGroup["entries"] = { };
	end

	tinsert(tGroup["entries"], {
		["entryType"] = VUHDO_AURA_LIST_ENTRY_SPELL,
		["value"] = tValue,
		["mine"] = true,
		["others"] = false,
		["durationMode"] = VUHDO_SPELL_DURATION_MODE_THRESHOLD,
		["timerThreshold"] = 10,
		["glowIcon"] = false,
		["glowIconColor"] = nil,
		["colorIcon"] = false,
		["colorIconColor"] = nil,
		["showTimer"] = 2,
		["showStacks"] = 2,
		["showClock"] = 2,
		["fadeOnLow"] = 2,
		["fadeThreshold"] = nil,
		["flashOnLow"] = 2,
		["flashThreshold"] = nil,
	});

	tSpellComboEditBox:SetText("");
	VUHDO_AURA_GROUPS_ADD_SPELL_SELECTED = "";

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tBouquetName;
function VUHDO_auraGroupsListAddBouquet()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if tGroup["type"] ~= VUHDO_AURA_GROUP_TYPE_LIST then
		return;
	end

	tBouquetName = VUHDO_AURA_GROUPS_NEW_BOUQUET_SELECTED;

	if not tBouquetName or tBouquetName == "" then
		return;
	end

	if not tGroup["entries"] then
		tGroup["entries"] = { };
	end

	tinsert(tGroup["entries"], {
		["entryType"] = VUHDO_AURA_LIST_ENTRY_BOUQUET,
		["value"] = tBouquetName,
	});

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tGroup;
function VUHDO_auraGroupsListAddEmpty()

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tGroup = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId];

	if tGroup["type"] ~= VUHDO_AURA_GROUP_TYPE_LIST then
		return;
	end

	if not tGroup["entries"] then
		tGroup["entries"] = { };
	end

	tinsert(tGroup["entries"], {
		["entryType"] = VUHDO_AURA_LIST_ENTRY_EMPTY,
	});

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tItemPanel;
local tIdx;
local tGroup;
local tEntry;
function VUHDO_auraGroupEntryBouquetButtonClicked(aButton)

	tItemPanel = aButton:GetParent();

	if not tItemPanel then
		return;
	end

	tIdx = tItemPanel["vuhdo_entryIdx"];

	if not tIdx or not sSelectedGroupId then
		return;
	end

	tGroup = VUHDO_getAuraGroupRaw(sSelectedGroupId);

	if not tGroup or not tGroup["entries"] then
		return;
	end

	tEntry = tGroup["entries"][tIdx];

	if not tEntry or tEntry["entryType"] ~= VUHDO_AURA_LIST_ENTRY_BOUQUET then
		return;
	end

	VUHDO_BOUQUETS["SELECTED"] = tEntry["value"];

	if VUHDO_MENU_RETURN_TARGET_MAIN ~= nil or VUHDO_MENU_RETURN_TARGET ~= nil then
		VUHDO_MENU_RETURN_TARGET_MAIN_SAVED = VUHDO_MENU_RETURN_TARGET_MAIN;
		VUHDO_MENU_RETURN_TARGET_SAVED = VUHDO_MENU_RETURN_TARGET;
	end

	VUHDO_MENU_RETURN_TARGET_MAIN = VuhDoNewOptionsTabbedFrameTabsPanelAurasRadioButton;
	VUHDO_MENU_RETURN_TARGET = VuhDoNewOptionsAuraRadioPanelGroupsRadioButton;

	VUHDO_newOptionsTabbedClickedClicked(VuhDoNewOptionsTabbedFrameTabsPanelGeneralRadioButton);
	VUHDO_lnfRadioButtonClicked(VuhDoNewOptionsTabbedFrameTabsPanelGeneralRadioButton);
	VUHDO_lnfTabRadioButtonClicked(VuhDoNewOptionsGeneralRadioPanelBouquetRadioButton);

	return;

end



--
local tItemPanel;
local tIdx;
local tGroup;
local tEntry;
local tFrame;
local tRootPane;
local tTitleLabel;
local tSpellName;
local tControl;
local tMode;
function VUHDO_auraGroupEntrySpellButtonClicked(aButton)

	tItemPanel = aButton:GetParent();

	if not tItemPanel then
		return;
	end

	tIdx = tItemPanel["vuhdo_entryIdx"];

	if not tIdx or not sSelectedGroupId then
		return;
	end

	tGroup = VUHDO_getAuraGroupRaw(sSelectedGroupId);

	if not tGroup or not tGroup["entries"] then
		return;
	end

	tEntry = tGroup["entries"][tIdx];

	if not tEntry or tEntry["entryType"] ~= VUHDO_AURA_LIST_ENTRY_SPELL then
		return;
	end

	sSpellEntrySettingsGroupId = sSelectedGroupId;
	sSpellEntrySettingsEntryIdx = tIdx;

	VUHDO_spellEntrySettingsInitFromEntry(tEntry);

	tFrame = _G["VuhDoNewOptionsAuraGroupsSpellEntrySettingsFrame"];

	if not tFrame then
		return;
	end

	tRootPane = _G[tFrame:GetName() .. "RootPane"];
	tTitleLabel = tRootPane and _G[tRootPane:GetName() .. "TitleLabelLabel"];

	if tTitleLabel then
		tSpellName = VUHDO_formatAuraSpellDisplayName(tostring(tEntry["value"] or ""));
		tTitleLabel:SetText(VUHDO_I18N_SPELL_SETTINGS .. ": " .. tSpellName);
	end

	VUHDO_spellEntrySettingsRefreshFromModel(tFrame);
	VUHDO_updateSpellEntryIconPreview(tFrame);

	tFrame:Show();

	if tRootPane then
		VUHDO_spellEntrySettingsUpdateTimerSliderEnabled(tRootPane);

		tMode = VUHDO_SPELL_ENTRY_DURATION_MODE or VUHDO_SPELL_DURATION_MODE_THRESHOLD;

		tControl = _G[tRootPane:GetName() .. "FullDurationCheckButton"];

		if tControl then
			tControl:SetChecked(tMode == VUHDO_SPELL_DURATION_MODE_FULL);

			VUHDO_lnfCheckButtonClicked(tControl);
		end

		tControl = _G[tRootPane:GetName() .. "AliveTimeCheckButton"];

		if tControl then
			tControl:SetChecked(tMode == VUHDO_SPELL_DURATION_MODE_ALIVE);

			VUHDO_lnfCheckButtonClicked(tControl);
		end
	end

	return;

end



--
local tEntry;
function VUHDO_spellEntrySettingsInitFromEntry(anEntry)

	tEntry = anEntry;

	VUHDO_SPELL_ENTRY_MINE = tEntry["mine"] ~= false;
	VUHDO_SPELL_ENTRY_OTHERS = tEntry["others"] == true;
	VUHDO_SPELL_ENTRY_DURATION_MODE = tEntry["durationMode"] or VUHDO_SPELL_DURATION_MODE_THRESHOLD;
	VUHDO_SPELL_ENTRY_TIMER_THRESHOLD = tEntry["timerThreshold"] or 10;
	VUHDO_SPELL_ENTRY_GLOW_STYLE = tEntry["glowIconStyle"] or (tEntry["glowIcon"] == true and VUHDO_DEFAULT_AURA_GLOW_STYLE or "none");

	VUHDO_SPELL_ENTRY_SETTINGS["GLOW_COLOR"] = tEntry["glowIconColor"] and VUHDO_deepCopyTable(tEntry["glowIconColor"])
		or VUHDO_deepCopyTable(VUHDO_PANEL_SETUP.BAR_COLORS["DEBUFF_ICON_GLOW"]);

	VUHDO_SPELL_ENTRY_COLOR_ICON = tEntry["colorIcon"] == true;

	VUHDO_SPELL_ENTRY_SETTINGS["COLOR_ICON_COLOR"] = tEntry["colorIconColor"] and VUHDO_deepCopyTable(tEntry["colorIconColor"]) or {
		["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 1,
		["TR"] = 1, ["TG"] = 1, ["TB"] = 1, ["TO"] = 1,
		["useBackground"] = true, ["useText"] = true, ["useOpacity"] = true,
	};

	VUHDO_SPELL_ENTRY_SHOW_TIMER = tEntry["showTimer"] or 2;
	VUHDO_SPELL_ENTRY_SHOW_STACKS = tEntry["showStacks"] or 2;
	VUHDO_SPELL_ENTRY_SHOW_CLOCK = tEntry["showClock"] or 2;
	VUHDO_SPELL_ENTRY_FADE_ON_LOW = tEntry["fadeOnLow"] or 2;
	VUHDO_SPELL_ENTRY_FADE_THRESHOLD = tEntry["fadeThreshold"] or 3;
	VUHDO_SPELL_ENTRY_FLASH_ON_LOW = tEntry["flashOnLow"] or 2;
	VUHDO_SPELL_ENTRY_FLASH_THRESHOLD = tEntry["flashThreshold"] or 2;

	return;

end



--
local tEntry;
local tGroup;
function VUHDO_spellEntrySettingsSaveToEntry()

	if not sSpellEntrySettingsGroupId or not sSpellEntrySettingsEntryIdx then
		return;
	end

	tGroup = VUHDO_getAuraGroupRaw(sSpellEntrySettingsGroupId);

	if not tGroup or not tGroup["entries"] then
		return;
	end

	tEntry = tGroup["entries"][sSpellEntrySettingsEntryIdx];

	if not tEntry or tEntry["entryType"] ~= VUHDO_AURA_LIST_ENTRY_SPELL then
		return;
	end

	tEntry["mine"] = VUHDO_SPELL_ENTRY_MINE;
	tEntry["others"] = VUHDO_SPELL_ENTRY_OTHERS;
	tEntry["durationMode"] = VUHDO_SPELL_ENTRY_DURATION_MODE;
	tEntry["timerThreshold"] = VUHDO_SPELL_ENTRY_TIMER_THRESHOLD;
	tEntry["glowIcon"] = "none" ~= VUHDO_SPELL_ENTRY_GLOW_STYLE;
	tEntry["glowIconStyle"] = "none" ~= VUHDO_SPELL_ENTRY_GLOW_STYLE and VUHDO_SPELL_ENTRY_GLOW_STYLE or nil;
	tEntry["glowIconColor"] = VUHDO_deepCopyTable(VUHDO_SPELL_ENTRY_SETTINGS["GLOW_COLOR"]);
	tEntry["colorIcon"] = VUHDO_SPELL_ENTRY_COLOR_ICON;
	tEntry["colorIconColor"] = VUHDO_deepCopyTable(VUHDO_SPELL_ENTRY_SETTINGS["COLOR_ICON_COLOR"]);
	tEntry["showTimer"] = VUHDO_SPELL_ENTRY_SHOW_TIMER;
	tEntry["showStacks"] = VUHDO_SPELL_ENTRY_SHOW_STACKS;
	tEntry["showClock"] = VUHDO_SPELL_ENTRY_SHOW_CLOCK;
	tEntry["fadeOnLow"] = VUHDO_SPELL_ENTRY_FADE_ON_LOW;
	tEntry["fadeThreshold"] = VUHDO_SPELL_ENTRY_FADE_THRESHOLD;
	tEntry["flashOnLow"] = VUHDO_SPELL_ENTRY_FLASH_ON_LOW;
	tEntry["flashThreshold"] = VUHDO_SPELL_ENTRY_FLASH_THRESHOLD;

	VUHDO_initEntrySettingsCache();

	VUHDO_invalidateAuraContainerTemplateCache();

	return;

end



--
local tSliderFrame;
local tInnerSlider;
local tMode;
function VUHDO_spellEntrySettingsUpdateTimerSliderEnabled(aRootPane)

	if not aRootPane then
		return;
	end

	tSliderFrame = _G[aRootPane:GetName() .. "TimerThresholdSlider"];
	if not tSliderFrame then
		return;
	end

	tInnerSlider = _G[tSliderFrame:GetName() .. "Slider"];

	if not tInnerSlider then
		return;
	end

	tMode = VUHDO_SPELL_ENTRY_DURATION_MODE or VUHDO_SPELL_DURATION_MODE_THRESHOLD;
	if tMode == VUHDO_SPELL_DURATION_MODE_THRESHOLD then
		tInnerSlider:Enable();
		tSliderFrame:SetAlpha(1);
	else
		tInnerSlider:Disable();
		tSliderFrame:SetAlpha(0.5);
	end

	return;

end



--
local tButton;
local tRootPane;
local tFullDuration;
local tAliveTime;
local tNewChecked;
function VUHDO_spellEntryDurationModeClicked(aButton)

	tButton = aButton;
	tRootPane = tButton:GetParent();

	if not tRootPane then
		return;
	end

	tFullDuration = _G[tRootPane:GetName() .. "FullDurationCheckButton"];
	tAliveTime = _G[tRootPane:GetName() .. "AliveTimeCheckButton"];

	if not tFullDuration or not tAliveTime then
		return;
	end

	tNewChecked = tButton:GetChecked();

	if tButton == tFullDuration then
		if tNewChecked then
			tAliveTime:SetChecked(false);
			VUHDO_SPELL_ENTRY_DURATION_MODE = VUHDO_SPELL_DURATION_MODE_FULL;
		else
			VUHDO_SPELL_ENTRY_DURATION_MODE = VUHDO_SPELL_DURATION_MODE_THRESHOLD;
		end
	else
		if tNewChecked then
			tFullDuration:SetChecked(false);
			VUHDO_SPELL_ENTRY_DURATION_MODE = VUHDO_SPELL_DURATION_MODE_ALIVE;
		else
			VUHDO_SPELL_ENTRY_DURATION_MODE = VUHDO_SPELL_DURATION_MODE_THRESHOLD;
		end
	end

	VUHDO_lnfCheckButtonClicked(tFullDuration);
	VUHDO_lnfCheckButtonClicked(tAliveTime);
	VUHDO_spellEntrySettingsUpdateTimerSliderEnabled(tRootPane);
	VUHDO_spellEntrySettingsChanged();

	return;

end



--
local tRootPane;
local tControl;
local tMode;
local function VUHDO_initSpellEntrySettingsFromModel(aFrame)

	if not aFrame then
		return;
	end

	tRootPane = _G[aFrame:GetName() .. "RootPane"];

	if not tRootPane then
		return;
	end

	tControl = _G[tRootPane:GetName() .. "MineCheckButton"];

	if tControl then
		VUHDO_lnfCheckButtonInitFromModel(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "OthersCheckButton"];

	if tControl then
		VUHDO_lnfCheckButtonInitFromModel(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "FullDurationCheckButton"];

	if tControl then
		tMode = VUHDO_SPELL_ENTRY_DURATION_MODE or VUHDO_SPELL_DURATION_MODE_THRESHOLD;

		tControl:SetChecked(tMode == VUHDO_SPELL_DURATION_MODE_FULL);
		VUHDO_lnfCheckButtonClicked(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "AliveTimeCheckButton"];

	if tControl then
		tMode = VUHDO_SPELL_ENTRY_DURATION_MODE or VUHDO_SPELL_DURATION_MODE_THRESHOLD;

		tControl:SetChecked(tMode == VUHDO_SPELL_DURATION_MODE_ALIVE);
		VUHDO_lnfCheckButtonClicked(tControl);
	end

	VUHDO_spellEntrySettingsUpdateTimerSliderEnabled(tRootPane);

	tControl = _G[tRootPane:GetName() .. "TimerThresholdSliderSlider"];

	if tControl then
		VUHDO_lnfSliderInitFromModel(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "GlowStyleCombo"];

	if tControl then
		VUHDO_initGlowStyleComboModel();
		VUHDO_lnfComboBoxInitFromModel(tControl);
		VUHDO_lnfUpdateComponentsByConstraints(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "GlowColorTexture"];

	if tControl then
		VUHDO_lnfColorSwatchInitFromModel(tControl);
		VUHDO_lnfUpdateComponentsByConstraints(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "ColorIconCheckButton"];

	if tControl then
		VUHDO_lnfCheckButtonInitFromModel(tControl);
		VUHDO_lnfUpdateComponentsByConstraints(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "ColorIconTexture"];

	if tControl then
		VUHDO_lnfColorSwatchInitFromModel(tControl);
		VUHDO_lnfUpdateComponentsByConstraints(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "ShowTimerTriState"];

	if tControl then
		VUHDO_lnfTriStateCheckButtonInitFromModel(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "ShowStacksTriState"];

	if tControl then
		VUHDO_lnfTriStateCheckButtonInitFromModel(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "ShowClockTriState"];

	if tControl then
		VUHDO_lnfTriStateCheckButtonInitFromModel(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "FadeOnLowTriState"];

	if tControl then
		VUHDO_lnfTriStateCheckButtonInitFromModel(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "FlashOnLowTriState"];

	if tControl then
		VUHDO_lnfTriStateCheckButtonInitFromModel(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "FadeThresholdSliderSlider"];

	if tControl then
		VUHDO_lnfSliderInitFromModel(tControl);
	end

	tControl = _G[tRootPane:GetName() .. "FlashThresholdSliderSlider"];

	if tControl then
		VUHDO_lnfSliderInitFromModel(tControl);
	end

	return;

end



--
function VUHDO_spellEntrySettingsRefreshFromModel(aFrame)

	VUHDO_auraGroupsRunRefresh(VUHDO_initSpellEntrySettingsFromModel, aFrame);

	return;

end



--
local tFrame;
local tRootPane;
local tControl;
function VUHDO_spellEntrySettingsChanged()

	if sRefreshDepth > 0 then
		return;
	end

	VUHDO_spellEntrySettingsSaveToEntry();

	tFrame = _G["VuhDoNewOptionsAuraGroupsSpellEntrySettingsFrame"];

	if tFrame and tFrame:IsShown() then
		VUHDO_updateSpellEntryIconPreview(tFrame);

		tRootPane = _G[tFrame:GetName() .. "RootPane"];
		tControl = tRootPane and _G[tRootPane:GetName() .. "GlowStyleCombo"];

		if tControl then
			VUHDO_lnfRefreshComboGlowItems(tControl);
		end
	end

	return;

end



--
function VUHDO_spellEntrySettingsOkayClicked(aButton)

	VUHDO_spellEntrySettingsSaveToEntry();

	tFrame = _G["VuhDoNewOptionsAuraGroupsSpellEntrySettingsFrame"];

	if tFrame then
		tFrame:Hide();
	end

	sSpellEntrySettingsGroupId = nil;
	sSpellEntrySettingsEntryIdx = nil;

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tFrame;
local tRootPane;
local tPreviewPanel;
local tIconTexture;
local tTimerText;
local tSpellValue;
local tSpellId;
local tR;
local tG;
local tB;
local tO;
local sSpellEntryPreviewGlowKey = "VUHDO_SPELL_ENTRY_PREVIEW_GLOW";
local sLastPreviewGlowStyle;
local sGlowPreviewOptions = { };
local sGlowPreviewColorArray = { 1, 1, 1, 1 };
local tStyle;
function VUHDO_updateSpellEntryIconPreview(aFrame)

	if not aFrame then
		return;
	end

	tRootPane = _G[aFrame:GetName() .. "RootPane"];

	if not tRootPane then
		return;
	end

	tPreviewPanel = _G[tRootPane:GetName() .. "PreviewPanel"];

	if not tPreviewPanel then
		return;
	end

	tIconTexture = _G[tPreviewPanel:GetName() .. "IconTexture"];
	tTimerText = _G[tPreviewPanel:GetName() .. "TimerText"];

	if not tIconTexture then
		return;
	end

	if tTimerText then
		tTimerText:SetDrawLayer("OVERLAY", 3);
	end

	tSpellValue = nil;

	if sSpellEntrySettingsGroupId and sSpellEntrySettingsEntryIdx then
		tGroup = VUHDO_getAuraGroupRaw(sSpellEntrySettingsGroupId);

		if tGroup and tGroup["entries"] then
			tEntry = tGroup["entries"][sSpellEntrySettingsEntryIdx];

			if tEntry and tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_SPELL then
				tSpellValue = tEntry["value"];
			end
		end
	end

	if not tSpellValue then
		tIconTexture:SetTexture(nil);

		if tTimerText then
			tTimerText:SetText("");
			tTimerText:Hide();
		end

		sGlowPreviewOptions["key"] = sSpellEntryPreviewGlowKey;

		VUHDO_LibOrbitGlow.Proc:Clear(tPreviewPanel, sGlowPreviewOptions);

		sLastPreviewGlowStyle = nil;

		return;
	end

	tSpellId = VUHDO_resolveAuraContainerPreferredSpellId(tSpellValue);

	tIconTexture:SetTexture(VUHDO_getGlobalIcon(tostring(tSpellId or tSpellValue)));

	if VUHDO_SPELL_ENTRY_COLOR_ICON and VUHDO_SPELL_ENTRY_SETTINGS["COLOR_ICON_COLOR"] then
		tR = VUHDO_SPELL_ENTRY_SETTINGS["COLOR_ICON_COLOR"]["R"] or 1;
		tG = VUHDO_SPELL_ENTRY_SETTINGS["COLOR_ICON_COLOR"]["G"] or 1;
		tB = VUHDO_SPELL_ENTRY_SETTINGS["COLOR_ICON_COLOR"]["B"] or 1;
		tO = VUHDO_SPELL_ENTRY_SETTINGS["COLOR_ICON_COLOR"]["O"] or 1;

		tIconTexture:SetVertexColor(tR, tG, tB, tO);
	else
		tIconTexture:SetVertexColor(1, 1, 1, 1);
	end

	tStyle = VUHDO_SPELL_ENTRY_GLOW_STYLE;

	if sLastPreviewGlowStyle and (not tStyle or "none" == tStyle or sLastPreviewGlowStyle ~= tStyle) then
		sGlowPreviewOptions["key"] = sSpellEntryPreviewGlowKey;

		VUHDO_LibOrbitGlow.Proc:Clear(tPreviewPanel, sGlowPreviewOptions);

		sLastPreviewGlowStyle = nil;
	end

	if tStyle and "none" ~= tStyle and VUHDO_SPELL_ENTRY_SETTINGS["GLOW_COLOR"] then
		sGlowPreviewColorArray[1] = VUHDO_SPELL_ENTRY_SETTINGS["GLOW_COLOR"]["R"] or 1;
		sGlowPreviewColorArray[2] = VUHDO_SPELL_ENTRY_SETTINGS["GLOW_COLOR"]["G"] or 1;
		sGlowPreviewColorArray[3] = VUHDO_SPELL_ENTRY_SETTINGS["GLOW_COLOR"]["B"] or 0;
		sGlowPreviewColorArray[4] = VUHDO_SPELL_ENTRY_SETTINGS["GLOW_COLOR"]["O"] or 1;

		sGlowPreviewOptions["glow"] = tStyle;
		sGlowPreviewOptions["key"] = sSpellEntryPreviewGlowKey;
		sGlowPreviewOptions["color"] = sGlowPreviewColorArray;
		sGlowPreviewOptions["frameLevel"] = 1;

		VUHDO_LibOrbitGlow.Proc:Loop(tPreviewPanel, sGlowPreviewOptions);

		sLastPreviewGlowStyle = tStyle;
	elseif sLastPreviewGlowStyle then
		sGlowPreviewOptions["key"] = sSpellEntryPreviewGlowKey;

		VUHDO_LibOrbitGlow.Proc:Clear(tPreviewPanel, sGlowPreviewOptions);

		sLastPreviewGlowStyle = nil;
	end

	if tTimerText then
		if VUHDO_SPELL_ENTRY_SHOW_TIMER == 1 then
			tTimerText:SetText("5");
			tTimerText:Show();
		else
			tTimerText:SetText("");
			tTimerText:Hide();
		end
	end

	return;

end



--
local tPanel;
local tIdx;
function VUHDO_auraGroupEntryRemoveOnClick(aButton)

	tPanel = aButton:GetParent();

	if not tPanel then
		return;
	end

	tIdx = tPanel["vuhdo_entryIdx"];

	if not tIdx then
		return;
	end

	VUHDO_auraGroupsListRemoveEntry(tIdx);

	return;

end



--
local tPanel;
local tIdx;
function VUHDO_auraGroupEntryUpOnClick(aButton)

	tPanel = aButton:GetParent();

	if not tPanel then
		return;
	end

	tIdx = tPanel["vuhdo_entryIdx"];

	if not tIdx then
		return;
	end

	VUHDO_auraGroupsListMoveEntry(tIdx, -1);

	return;

end



--
local tPanel;
local tIdx;
function VUHDO_auraGroupEntryDownOnClick(aButton)

	tPanel = aButton:GetParent();

	if not tPanel then
		return;
	end

	tIdx = tPanel["vuhdo_entryIdx"];

	if not tIdx then
		return;
	end

	VUHDO_auraGroupsListMoveEntry(tIdx, 1);

	return;

end



--
local tEntries;
function VUHDO_auraGroupsListRemoveEntry(anIndex)

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tEntries = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["entries"];

	if not tEntries or anIndex < 1 or anIndex > #tEntries then
		return;
	end

	tremove(tEntries, anIndex);

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tEntries;
local tSwap;
function VUHDO_auraGroupsListMoveEntry(anIndex, aDirection)

	if not sSelectedGroupId or not VUHDO_CONFIG["AURA_GROUPS"] or not VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId] then
		return;
	end

	tEntries = VUHDO_CONFIG["AURA_GROUPS"][sSelectedGroupId]["entries"];

	if not tEntries or anIndex < 1 or anIndex > #tEntries then
		return;
	end

	tSwap = anIndex + aDirection;

	if tSwap < 1 or tSwap > #tEntries then
		return;
	end

	tSwap = tEntries[anIndex];
	tEntries[anIndex] = tEntries[anIndex + aDirection];
	tEntries[anIndex + aDirection] = tSwap;

	VUHDO_auraGroupsRefreshListEntries();

	return;

end



--
local tGroupsRadio;
function VUHDO_auraGroupsOnShow()

	if VUHDO_AURA_GROUPS_PENDING_SELECTION then
		sSelectedGroupId = VUHDO_AURA_GROUPS_PENDING_SELECTION;

		VUHDO_AURA_GROUPS_SELECTED = VUHDO_AURA_GROUPS_PENDING_SELECTION;
		VUHDO_AURA_GROUPS_PENDING_SELECTION = nil;
	end

	tGroupsRadio = _G["VuhDoNewOptionsAuraRadioPanelGroupsRadioButton"];

	if tGroupsRadio and tGroupsRadio:GetChecked() then
		_G["VuhDoNewOptionsAuraIgnore"]:Hide();
	else
		_G["VuhDoNewOptionsAuraGroups"]:Hide();
		_G["VuhDoNewOptionsAuraIgnore"]:Show();
	end

	VUHDO_auraGroupsRefreshList();

	if sSelectedGroupId and VUHDO_getAuraGroupRaw(sSelectedGroupId) then
		VUHDO_auraGroupsOnGroupSelected(sSelectedGroupId);
	else
		sSelectedGroupId = nil;
	end

	if _G["VuhDoNewOptionsAuraGroupsBackButton"] then
		_G["VuhDoNewOptionsAuraGroupsBackButton"]:SetShown(VUHDO_MENU_RETURN_TARGET ~= nil or VUHDO_MENU_RETURN_TARGET_MAIN ~= nil);
	end

	return;

end



--
function VUHDO_auraGroupsBackButtonClicked(aPanel)

	tFrame = _G["VuhDoNewOptionsAuraGroupsSpellEntrySettingsFrame"];

	if tFrame and tFrame:IsShown() then
		tFrame:Hide();
	end

	if VUHDO_MENU_RETURN_TARGET_MAIN ~= nil then
		VUHDO_newOptionsTabbedClickedClicked(VUHDO_MENU_RETURN_TARGET_MAIN);
		VUHDO_lnfRadioButtonClicked(VUHDO_MENU_RETURN_TARGET_MAIN);

		VUHDO_MENU_RETURN_TARGET_MAIN = nil;
	end

	if VUHDO_MENU_RETURN_TARGET ~= nil then
		VUHDO_lnfTabRadioButtonClicked(VUHDO_MENU_RETURN_TARGET);

		VUHDO_MENU_RETURN_TARGET = nil;
	end

	return;

end