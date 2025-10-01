local GetSpellName = C_Spell.GetSpellName;
local pairs = pairs;
local _;

VUHDO_GLOBAL_CONFIG = {
	["PROFILES_VERSION"] = 1;
};


--
local tHotCfg, tHotSlots;
function VUHDO_fixHotSettings()

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		tHotSlots = VUHDO_PANEL_SETUP[tPanelNum]["HOTS"]["SLOTS"];
		tHotCfg = VUHDO_PANEL_SETUP[tPanelNum]["HOTS"]["SLOTCFG"];

		for tCnt2 = 1, 12 do -- VUHDO_MAX_HOTS
			if not tHotCfg["" .. tCnt2]["mine"] and not tHotCfg["" .. tCnt2]["others"] then
				if tHotSlots[tCnt2] then
					tHotCfg["" .. tCnt2]["mine"] = true;
					tHotCfg["" .. tCnt2]["others"] = VUHDO_EXCLUSIVE_HOTS[tHotSlots[tCnt2]];
				end
			end
		end
	end

end



--
local function VUHDO_getVarDescription(aVar)
	local tMessage = "";
	if aVar == nil then
		tMessage = "<nil>";
	elseif "boolean" == type(aVar) then
		if aVar then
			tMessage = "<true>";
		else
			tMessage = "<false>";
		end
	elseif "number" == type(aVar) or "string" == type(aVar) then
		tMessage = aVar .. " (" .. type(aVar) .. ")";
	else
		tMessage = "(" .. type(aVar) .. ")";
	end

	return tMessage;
end



--
local tCreated, tRepaired;
local function _VUHDO_ensureSanity(aName, aValue, aSaneValue)
	if aSaneValue ~= nil then
		if type(aSaneValue) == "table" then
			if aValue ~= nil and type(aValue) == "table" then
				for tIndex, _ in pairs(aSaneValue) do
					aValue[tIndex] = _VUHDO_ensureSanity(aName, aValue[tIndex], aSaneValue[tIndex]);
				end
			else

				if aValue ~= nil then
					tRepaired = tRepaired + 1;
				else
					tCreated = tCreated + 1;
				end

				return VUHDO_deepCopyTable(aSaneValue);
			end
		else
			if aValue == nil or type(aValue) ~= type(aSaneValue) then
				if (type(aSaneValue) ~= "boolean" or (aValue ~= 1 and aValue ~= 0 and aValue ~= nil))
				and (type(aSaneValue) ~= "number" or (aSaneValue ~= 1 and aSaneValue ~= 0)) then

					if (aValue ~= nil) then
						tRepaired = tRepaired + 1;
					else
						tCreated = tCreated + 1;
					end

					return aSaneValue;
				end
			end

			if aValue ~= nil and "string" == type(aValue) then
				aValue = strtrim(aValue);
			end

		end
	end

	return aValue
end



--
local tRepairedArray;
function VUHDO_ensureSanity(aName, aValue, aSaneValue)
	tCreated, tRepaired = 0, 0;

	local tSaneValue = VUHDO_decompressIfCompressed(aSaneValue);
	tRepairedArray = _VUHDO_ensureSanity(aName, aValue, tSaneValue);

	if tCreated + tRepaired > 0 then
		VUHDO_Msg("auto model sanity: " .. aName .. ": created " .. tCreated .. ", repaired " .. tRepaired .. " values.");
	end

	return tRepairedArray;
end



local VUHDO_DEFAULT_MODELS = {
	{ VUHDO_ID_GROUP_1, VUHDO_ID_GROUP_2, VUHDO_ID_GROUP_3, VUHDO_ID_GROUP_4, VUHDO_ID_GROUP_5, VUHDO_ID_GROUP_6, VUHDO_ID_GROUP_7, VUHDO_ID_GROUP_8, VUHDO_ID_PETS },
	{ VUHDO_ID_PRIVATE_TANKS, VUHDO_ID_BOSSES }, 
};



local VUHDO_DEFAULT_RANGE_SPELLS = {
	["WARRIOR"] = {
		["HELPFUL"] = { }, -- FIXME: anything?
		["HARMFUL"] = { VUHDO_SPELL_ID.TAUNT },
	},
	["ROGUE"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.SHADOWSTEP },
		["HARMFUL"] = { VUHDO_SPELL_ID.SHADOWSTEP },
	},
	["HUNTER"] = {
		["HELPFUL"] = { }, -- FIXME: anything?
		["HARMFUL"] = { 193455, 19434, 132031 }, -- VUHDO_SPELL_ID.COBRA_SHOT, VUHDO_SPELL_ID.AIMED_SHOT, VUHDO_SPELL_ID.STEADY_SHOT
	},
	["PALADIN"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.FLASH_OF_LIGHT },
		["HARMFUL"] = { VUHDO_SPELL_ID.HAND_OF_RECKONING },
	},
	["MAGE"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.ARCANE_INTELLECT },
		["HARMFUL"] = { 116, 30451, 133 }, -- VUHDO_SPELL_ID.FROSTBOLT, VUHDO_SPELL_ID.ARCANE_BLAST, VUHDO_SPELL_ID.FIREBALL
	},
	["WARLOCK"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.SOULSTONE },
		["HARMFUL"] = { VUHDO_SPELL_ID.SHADOW_BOLT },
	},
	["SHAMAN"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.HEALING_WAVE },
		["HARMFUL"] = { VUHDO_SPELL_ID.FLAME_SHOCK, VUHDO_SPELL_ID.LIGHTNING_BOLT },
	},
	["DRUID"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.REJUVENATION },
		["HARMFUL"] = { VUHDO_SPELL_ID.MOONFIRE },
	},
	["PRIEST"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.FLASH_HEAL },
		["HARMFUL"] = { VUHDO_SPELL_ID.SHADOW_WORD_PAIN, VUHDO_SPELL_ID.SMITE },
	},
	["DEATHKNIGHT"] = {
		["HELPFUL"] = { 47541 }, -- VUHDO_SPELL_ID.DEATH_COIL
		["HARMFUL"] = { 47541, 49576 }, -- VUHDO_SPELL_ID.DEATH_COIL, VUHDO_SPELL_ID.DEATH_GRIP
	},
	["MONK"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.VIVIFY, VUHDO_SPELL_ID.DETOX },
		["HARMFUL"] = { VUHDO_SPELL_ID.PROVOKE },
	},
	["DEMONHUNTER"] = {
		["HELPFUL"] = { }, -- FIXME: anything?
		["HARMFUL"] = { VUHDO_SPELL_ID.THROW_GLAIVE },
	},
	["EVOKER"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.EMERALD_BLOSSOM, VUHDO_SPELL_ID.LIVING_FLAME },
		["HARMFUL"] = { VUHDO_SPELL_ID.AZURE_STRIKE, VUHDO_SPELL_ID.LIVING_FLAME },
	},
};



--local VUHDO_DEFAULT_SPELL_ASSIGNMENT = { };
--local VUHDO_DEFAULT_HOSTILE_SPELL_ASSIGNMENT = {};
local VUHDO_DEFAULT_SPELLS_KEYBOARD = {};



local VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT = {
	["PALADIN"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.FLASH_OF_LIGHT },
		["2"] = { "", "2", VUHDO_SPELL_ID.HOLY_SHOCK },
		["3"] = { "", "3", "dropdown" },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.HOLY_LIGHT },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.LAY_ON_HANDS },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.LIGHT_OF_DAWN },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.PALA_CLEANSE },
		["shift3"] = { "shift-", "3", "menu" },
	},

	["SHAMAN"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.HEALING_WAVE },
		["2"] = { "", "2", VUHDO_SPELL_ID.CHAIN_HEAL },
		["3"] = { "", "3", "dropdown" },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.BUFF_EARTH_SHIELD },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.GIFT_OF_THE_NAARU },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.RIPTIDE },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.PURIFY_SPIRIT },
		["shift3"] = { "shift-", "3", "menu" },
	},

	["PRIEST"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.FLASH_HEAL },
		["2"] = { "", "2", VUHDO_SPELL_ID.RENEW },
		["3"] = { "", "3", "dropdown" },
		["4"] = { "", "4", VUHDO_SPELL_ID.PRAYER_OF_MENDING },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.PRAYER_OF_HEALING },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.CIRCLE_OF_HEALING },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.POWERWORD_SHIELD },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.PURIFY },
		["shift3"] = { "shift-", "3", "menu" },
	},

	["DRUID"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.REGROWTH },
		["2"] = { "", "2", VUHDO_SPELL_ID.REJUVENATION },
		["3"] = { "", "3", "dropdown" },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.INNERVATE },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.LIFEBLOOM },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.TRANQUILITY },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.NATURES_CURE },
		["shift3"] = { "shift-", "3", "menu" },
	},

	["MONK"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.RENEWING_MIST },
		["2"] = { "", "2", VUHDO_SPELL_ID.ENVELOPING_MIST },
		["3"] = { "", "3", "dropdown" },
		["4"] = { "", "4", VUHDO_SPELL_ID.CHI_WAVE },
		["5"] = { "", "5", VUHDO_SPELL_ID.SOOTHING_MIST },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.REVIVAL },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.LIFE_COCOON },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.VIVIFY },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.DETOX },
		["shift3"] = { "shift-", "3", "menu" },
	},

	["EVOKER"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.LIVING_FLAME },
		["2"] = { "", "2", VUHDO_SPELL_ID.EMERALD_BLOSSOM },
		["3"] = { "", "3", "dropdown" },
		["4"] = { "", "4", VUHDO_SPELL_ID.ECHO },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.DREAM_BREATH },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.DREAM_FLIGHT },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.CAUTERIZING_FLAME },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.NATURALIZE },
		["shift3"] = { "shift-", "3", "menu" },
	},
};



--
local VUHDO_GLOBAL_DEFAULT_SPELL_ASSIGNMENT = {
	["1"] = { "", "1", "target" },
	["2"] = { "", "2", "dropdown" },
	["3"] = { "", "3", "focus" },
	["4"] = { "", "4", "menu" },
	["5"] = { "", "5", "assist" },
};



--
VUHDO_DEFAULT_SPELL_CONFIG = {
	["IS_AUTO_FIRE"] = true,
	["IS_FIRE_HOT"] = false,
	["IS_FIRE_OUT_FIGHT"] = false,
	["IS_AUTO_TARGET"] = false,
	["IS_CANCEL_CURRENT"] = false,
	["IS_FIRE_TRINKET_1"] = false,
	["IS_FIRE_TRINKET_2"] = false,
	["IS_FIRE_GLOVES"] = false,
	["IS_FIRE_CUSTOM_1"] = false,
	["FIRE_CUSTOM_1_SPELL"] = "",
	["IS_FIRE_CUSTOM_2"] = false,
	["FIRE_CUSTOM_2_SPELL"] = "",
	["IS_TOOLTIP_INFO"] = false,
	["IS_LOAD_HOTS"] = false,
	["IS_LOAD_HOTS_ONLY_SLOTS"] = false,
	["smartCastModi"] = "all",
	["autoBattleRez"] = true,
	["custom1Unit"] = "@player",
	["custom2Unit"] = "@player",
}


local tDefaultWheelAssignments = {
	["1"] = {"", "-w1", ""},
	["2"] = {"", "-w2", ""},

	["alt1"] = {"ALT-", "-w3", ""},
	["alt2"] = {"ALT-", "-w4", ""},

	["ctrl1"] = {"CTRL-", "-w5", ""},
	["ctrl2"] = {"CTRL-", "-w6", ""},

	["shift1"] = {"SHIFT-", "-w7", ""},
	["shift2"] = {"SHIFT-", "-w8", ""},

	["altctrl1"] = {"ALT-CTRL-", "-w9", ""},
	["altctrl2"] = {"ALT-CTRL-", "-w10", ""},

	["altshift1"] = {"ALT-SHIFT-", "-w11", ""},
	["altshift2"] = {"ALT-SHIFT-", "-w12", ""},

	["ctrlshift1"] = {"CTRL-SHIFT-", "-w13", ""},
	["ctrlshift2"] = {"CTRL-SHIFT-", "-w14", ""},

	["altctrlshift1"] = {"ALT-CTRL-SHIFT-", "-w15", ""},
	["altctrlshift2"] = {"ALT-CTRL-SHIFT-", "-w16", ""},
};



--
local function VUHDO_initDefaultKeySpellAssignments()
	VUHDO_DEFAULT_SPELLS_KEYBOARD = { };

	for tCnt = 1, VUHDO_NUM_KEYBOARD_KEYS do
		VUHDO_DEFAULT_SPELLS_KEYBOARD["SPELL" .. tCnt] = "";
	end

	VUHDO_DEFAULT_SPELLS_KEYBOARD["INTERNAL"] = {	};
	VUHDO_DEFAULT_SPELLS_KEYBOARD["WHEEL"] = VUHDO_deepCopyTable(tDefaultWheelAssignments);
	VUHDO_DEFAULT_SPELLS_KEYBOARD["HOSTILE_WHEEL"] = VUHDO_deepCopyTable(tDefaultWheelAssignments);
end



--
function VUHDO_trimSpellAssignments(anArray)
	local tRemove = { };

	for tKey, tValue in pairs(anArray) do
		if (VUHDO_strempty(tValue[3])) then
			tinsert(tRemove, tKey);
		end
	end

	for _, tKey in pairs(tRemove) do
		anArray[tKey] = nil;
	end
end



--
local tSpecId;
local tClass;
local tDefaultAssignments;
local function VUHDO_assignDefaultSpells()

	tSpecId = GetSpecializationInfo(GetSpecialization() or 0);
	_, tClass = UnitClass("player");

	if tSpecId and VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT[tSpecId] then
		tDefaultAssignments = VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT[tSpecId];
	elseif tClass and VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT[tClass] then
		tDefaultAssignments = VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT[tClass];
	else
		tDefaultAssignments = VUHDO_GLOBAL_DEFAULT_SPELL_ASSIGNMENT;
	end

	VUHDO_SPELL_ASSIGNMENTS = VUHDO_deepCopyTable(tDefaultAssignments);

	VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT = nil;
	VUHDO_GLOBAL_DEFAULT_SPELL_ASSIGNMENT = nil;

end



--
function VUHDO_loadSpellArray()
	-- Maus freundlich
	if (VUHDO_SPELL_ASSIGNMENTS == nil) then
		VUHDO_assignDefaultSpells();
	end
	VUHDO_SPELL_ASSIGNMENTS = VUHDO_ensureSanity("VUHDO_SPELL_ASSIGNMENTS", VUHDO_SPELL_ASSIGNMENTS, {});
	VUHDO_trimSpellAssignments(VUHDO_SPELL_ASSIGNMENTS);

	-- Maus gegnerisch
	if (VUHDO_HOSTILE_SPELL_ASSIGNMENTS == nil) then
		VUHDO_HOSTILE_SPELL_ASSIGNMENTS = { };
	end
	VUHDO_HOSTILE_SPELL_ASSIGNMENTS = VUHDO_ensureSanity("VUHDO_HOSTILE_SPELL_ASSIGNMENTS", VUHDO_HOSTILE_SPELL_ASSIGNMENTS, {});
	VUHDO_trimSpellAssignments(VUHDO_HOSTILE_SPELL_ASSIGNMENTS);

	-- Tastatur
	VUHDO_initDefaultKeySpellAssignments();
	if (VUHDO_SPELLS_KEYBOARD == nil) then
		VUHDO_SPELLS_KEYBOARD = VUHDO_deepCopyTable(VUHDO_DEFAULT_SPELLS_KEYBOARD);
	end
	VUHDO_SPELLS_KEYBOARD = VUHDO_ensureSanity("VUHDO_SPELLS_KEYBOARD", VUHDO_SPELLS_KEYBOARD, VUHDO_DEFAULT_SPELLS_KEYBOARD);
	VUHDO_DEFAULT_SPELLS_KEYBOARD = nil;

	-- Konfiguration
	if (VUHDO_SPELL_CONFIG == nil) then
		VUHDO_SPELL_CONFIG = VUHDO_deepCopyTable(VUHDO_DEFAULT_SPELL_CONFIG);
	end
	VUHDO_SPELL_CONFIG = VUHDO_ensureSanity("VUHDO_SPELL_CONFIG", VUHDO_SPELL_CONFIG, VUHDO_DEFAULT_SPELL_CONFIG);

	if (VUHDO_SPELL_LAYOUTS == nil) then
		VUHDO_SPELL_LAYOUTS = { };
	end

	if (VUHDO_SPEC_LAYOUTS == nil) then
		VUHDO_SPEC_LAYOUTS = {
			["selected"] = "",
			["1"] = "",
			["2"] = "",
			["3"] = "",
			["4"] = ""
		}
	end

	VUHDO_DEFAULT_SPELL_CONFIG = nil;
end



--
local function VUHDO_makeFullColorWoOpacity(...)

	local tColor = VUHDO_makeFullColor(...);
	
	tColor["useOpacity"] = false;
	
	return tColor;

end



--
local function VUHDO_makeHotColor(...)
	
	local tColor = VUHDO_makeFullColor(...);

	tColor["useOpacity"] = tColor["O"] and true or false;

	tColor["isFullDuration"] = false;
	tColor["isClock"] = false;
	tColor["countdownMode"] = 1;
	tColor["isFadeOut"] = false;
	tColor["isFlashWhenLow"] = false;
	
	return tColor;

end




--
local function VUHDO_customDebuffsAddDefaultSettings(aBuffName)
	if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"] == nil) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"] = { };
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName] == nil) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]	= {
			["isIcon"] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["isIcon"],
			["isColor"] = false,
			["animate"] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["animate"],
			["timer"] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["timer"],
			["isStacks"] = VUHDO_CONFIG["CUSTOM_DEBUFF"]["isStacks"],
			["isMine"] = true,
			["isOthers"] = true,
			["isBarGlow"] = false,
			["isIconGlow"] = false,
		}
	end

	if (not VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["isColor"]) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["color"] = nil;
	elseif (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["color"] == nil) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["color"]
			= VUHDO_makeFullColor(0.6, 0.3, 0, 1,   0.8, 0.5, 0, 1);
	end
	
	if (not VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["isBarGlow"]) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["barGlowColor"] = nil;
	elseif (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["barGlowColor"] == nil) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["barGlowColor"]
			= VUHDO_makeFullColor(0.95, 0.95, 0.32, 1,   1, 1, 0, 1);
	end

	if (not VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["isIconGlow"]) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["iconGlowColor"] = nil;
	elseif (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["iconGlowColor"] == nil) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]["iconGlowColor"]
			= VUHDO_makeFullColor(0.95, 0.95, 0.32, 1,   1, 1, 0, 1);
	end
end



--
local tName;
local function VUHDO_addCustomSpellIds(aVersion, aDebuffs)

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"].version or 0) < aVersion then
		VUHDO_CONFIG["CUSTOM_DEBUFF"].version = aVersion;

		for tSpellId, tIsAddBySpellId in pairs(aDebuffs) do
			if tIsAddBySpellId then
				tName = tostring(tSpellId);
			else
				tName = GetSpellName(tSpellId);
			end

			VUHDO_tableUniqueAdd(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"], tName);
		end
	end

end



--
local function VUHDO_spellTraceAddDefaultSettings(aSpellName)

	if (VUHDO_CONFIG["SPELL_TRACE"]["STORED_SETTINGS"] == nil) then
		VUHDO_CONFIG["SPELL_TRACE"]["STORED_SETTINGS"] = { };
	end

	if (VUHDO_CONFIG["SPELL_TRACE"]["STORED_SETTINGS"][aSpellName] == nil) then
		VUHDO_CONFIG["SPELL_TRACE"]["STORED_SETTINGS"][aSpellName] = {
			["isMine"] = VUHDO_CONFIG["SPELL_TRACE"]["isMine"],
			["isOthers"] = VUHDO_CONFIG["SPELL_TRACE"]["isOthers"],
			["duration"] = VUHDO_CONFIG["SPELL_TRACE"]["duration"],
			["isIncoming"] = VUHDO_CONFIG["SPELL_TRACE"]["isIncoming"],
		}
	end

end



--
local function VUHDO_addSpellTraceSpellIds(aVersion, ...)

	if ((VUHDO_CONFIG["SPELL_TRACE"].version or 0) < aVersion) then
		VUHDO_CONFIG["SPELL_TRACE"].version = aVersion;

		local tArg;

		for tCnt = 1, select("#", ...) do
			tArg = select(tCnt, ...);

			if (type(tArg) == "number") then
				-- make sure the spell ID is still added as a string
				-- otherwise getKeyFromValue look-ups w/ spell ID string fail later
				tArg = tostring(tArg);
			end

			VUHDO_tableUniqueAdd(VUHDO_CONFIG["SPELL_TRACE"]["STORED"], tArg);
		end
	end

end



--
local VUHDO_DEFAULT_CONFIG = {
	["VERSION"] = 4,

	["SHOW_PANELS"] = true,
	["HIDE_PANELS_SOLO"] = false,
	["HIDE_PANELS_PARTY"] = false,
	["HIDE_PANELS_PET_BATTLE"] = true,
	["LOCK_PANELS"] = false,
	["LOCK_CLICKS_THROUGH"] = false,
	["LOCK_IN_FIGHT"] = true,
	["PARSE_COMBAT_LOG"] = false,
	["HIDE_EMPTY_BUTTONS"] = false,

	["MODE"] = VUHDO_MODE_NEUTRAL,
	["EMERGENCY_TRIGGER"] = 100,
	["MAX_EMERGENCIES"] = 5,

	["SHOW_INCOMING"] = true,
	["SHOW_OVERHEAL"] = true,
	["SHOW_OWN_INCOMING"] = true,
	["SHOW_TEXT_OVERHEAL"] = true,
	["SHOW_SHIELD_BAR"] = true,
	["SHOW_OVERSHIELD_BAR"] = false,
	["SHOW_HEAL_ABSORB_BAR"] = true,

	["RANGE_CHECK_DELAY"] = 260,

	["SOUND_DEBUFF"] = nil,
	["SOUND_DEBUFF_REMOVABLE_ONLY"] = false,
	["DETECT_DEBUFFS_REMOVABLE_ONLY"] = true,
	["DETECT_DEBUFFS_REMOVABLE_ONLY_ICONS"] = true,
	["DETECT_DEBUFFS_IGNORE_BY_CLASS"] = true,
	["DETECT_DEBUFFS_IGNORE_NO_HARM"] = true,
	["DETECT_DEBUFFS_IGNORE_MOVEMENT"] = true,
	["DETECT_DEBUFFS_IGNORE_DURATION"] = true,
	["DETECT_DEBUFFS_IGNORE_PURGEABLE_BUFFS"] = false,

	["SMARTCAST_RESURRECT"] = true,
	["SMARTCAST_CLEANSE"] = false,
	["SMARTCAST_BUFF"] = false,

	["SHOW_PLAYER_TAGS"] = true,
	["OMIT_MAIN_TANKS"] = false,
	["OMIT_MAIN_ASSIST"] = false,
	["OMIT_PLAYER_TARGETS"] = false,
	["OMIT_OWN_GROUP"] = false,
	["OMIT_FOCUS"] = false,
	["OMIT_TARGET"] = false,
	["OMIT_SELF"] = false,
	["OMIT_DFT_MTS"] = false,
	["BLIZZ_UI_HIDE_PLAYER"] = 2,
	["BLIZZ_UI_HIDE_PARTY"] = 2,
	["BLIZZ_UI_HIDE_TARGET"] = 2,
	["BLIZZ_UI_HIDE_PET"] = 2,
	["BLIZZ_UI_HIDE_FOCUS"] = 2,
	["BLIZZ_UI_HIDE_RAID"] = 2,
	["BLIZZ_UI_HIDE_RAID_MGR"] = 2,

	["CURRENT_PROFILE"] = "",
	["IS_ALWAYS_OVERWRITE_PROFILE"] = false,
	["HIDE_EMPTY_PANELS"] = false,
	["ON_MOUSE_UP"] = false,

	["STANDARD_TOOLTIP"] = false,
	["DEBUFF_TOOLTIP"] = true,

	["AUTO_PROFILES"] = {	},

	["RES_ANNOUNCE_TEXT"] = VUHDO_I18N_DEFAULT_RES_ANNOUNCE,
	["RES_ANNOUNCE_MASS_TEXT"] = VUHDO_I18N_DEFAULT_RES_ANNOUNCE_MASS,
	["RES_IS_SHOW_TEXT"] = false,

	["CUSTOM_DEBUFF"] = {
		["scale"] = 0.8,
		["animate"] = false,
		["timer"] = true,
		["max_num"] = 3,
		["isNoRangeFade"] = false,
		["isIcon"] = true,
		["isColor"] = false,
		["isStacks"] = true,
		["isName"] = false, 
		["isShowFriendly"] = true,
		["isShowHostile"] = true,
		["isHostileMine"] = true,
		["isHostileOthers"] = true,
		["blacklistModi"] = "ALT-CTRL-SHIFT",
		["SELECTED"] = "",
		["point"] = "TOPRIGHT",
		["xAdjust"] = -2,
		["yAdjust"] = -34,
		["STORED"] = { },

		["TIMER_TEXT"] = {
			["ANCHOR"] = "BOTTOMRIGHT",
			["X_ADJUST"] = 20,
			["Y_ADJUST"] = 26,
			["SCALE"] = 85,
			["FONT"] = "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf",
			["COLOR"] = VUHDO_makeFullColor(0, 0, 0, 1,   1, 1, 1, 1),
			["USE_SHADOW"] = true,
			["USE_OUTLINE"] = false,
			["USE_MONO"] = false,
		},

		["COUNTER_TEXT"] = {
			["ANCHOR"] = "TOPLEFT",
			["X_ADJUST"] = -10,
			["Y_ADJUST"] = -15,
			["SCALE"] = 70,
			["FONT"] = "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf",
			["COLOR"] = VUHDO_makeFullColor(0, 0, 0, 1,   0, 1, 0, 1),
			["USE_SHADOW"] = true,
			["USE_OUTLINE"] = false,
			["USE_MONO"] = false,
		},
	},

	["SPELL_TRACE"] = {
		["isMine"] = true,
		["isOthers"] = false,
		["duration"] = 2,
		["showTrailOfLight"] = false,
		["SELECTED"] = "",
		["STORED"] = { },
		["isIncoming"] = false,
		["showIncomingFriendly"] = false,
		["showIncomingEnemy"] = false,
		["showIncomingAll"] = false,
		["showIncomingBossOnly"] = false,
	},

	["THREAT"] = {
		["AGGRO_REFRESH_MS"] = 300,
		["AGGRO_TEXT_LEFT"] = ">>",
		["AGGRO_TEXT_RIGHT"] = "<<",
		["AGGRO_USE_TEXT"] = false,
		["IS_TANK_MODE"] = false,
	},

	["CLUSTER"] = {
		["REFRESH"] = 500,
		["RANGE"] = 30,
		["RANGE_JUMP"] = 11,
		["BELOW_HEALTH_PERC"] = 85,
		["THRESH_FAIR"] = 3,
		["THRESH_GOOD"] = 5,
		["DISPLAY_SOURCE"] = 2, -- 1=Mine, 2=all
		["DISPLAY_DESTINATION"] = 2, -- 1=Party, 2=Raid
		["MODE"] = 1, -- 1=radial, 2=chained
		["IS_NUMBER"] = true,
		["CHAIN_MAX_JUMP"] = 3,
		["COOLDOWN_SPELL"] = "",
		["CONE_DEGREES"] = 360,
		["ARE_TARGETS_RANDOM"] = true,

		["TEXT"] = {
			["ANCHOR"] = "BOTTOMRIGHT",
			["X_ADJUST"] = 40,
			["Y_ADJUST"] = 22,
			["SCALE"] = 85,
			["FONT"] = "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf",
			["COLOR"] = VUHDO_makeFullColor(0, 0, 0, 1,   1, 1, 1, 1),
			["USE_SHADOW"] = false,
			["USE_OUTLINE"] = true,
			["USE_MONO"] = false,
		},
	},

	["UPDATE_HOTS_MS"] = 250,
	["SCAN_RANGE"] = "2", -- 0=all, 2=100 yards, 3=40 yards

	["RANGE_SPELL"] = {
		["HELPFUL"] = "",
		["HARMFUL"] = "",
	},
	["RANGE_PESSIMISTIC"] = {
		["HELPFUL"] = true,
		["HARMFUL"] = true,
	},

	["IS_SHOW_GCD"] = false,
	["IS_SCAN_TALENTS"] = true,
	["IS_CLIQUE_COMPAT_MODE"] = false,
	["IS_CLIQUE_PASSTHROUGH"] = false,
	["DIRECTION"] = {
		["enable"] = true,
		["isDistanceText"] = false,
		["isDeadOnly"] = false,
		["isAlways"] = false,
		["scale"] = 75,
	},

	["AOE_ADVISOR"] = {
		["knownOnly"] = true,
		["subInc"] = true,
		["subIncOnlyCastTime"] = true,
		["isCooldown"] = true,
		["animate"] = true,
		["isGroupWise"] = false,
		["refresh"] = 800,

		["config"] = {
			["coh"] = {
				["enable"] = false,
				["thresh"] = 15000,
			},
			["poh"] = {
				["enable"] = false,
				["thresh"] = 20000,
			},
			["ch"] = {
				["enable"] = false,
				["thresh"] = 15000,
			},
			["wg"] = {
				["enable"] = false,
				["thresh"] = 15000,
			},
			["tq"] = {
				["enable"] = false,
				["thresh"] = 15000,
			},
			["lod"] = {
				["enable"] = false,
				["thresh"] = 8000,
			},
			["hr"] = {
				["enable"] = false,
				["thresh"] = 10000,
			},
			["cb"] = {
				["enable"] = false,
				["thresh"] = 10000,
			},
		},

	},

	["IS_DC_SHIELD_DISABLED"] = false,
	["IS_USE_BUTTON_FACADE"] = false,
	["IS_SHARE"] = true,
	["IS_READY_CHECK_DISABLED"] = false,

	["SHOW_SPELL_TRACE"] = false,
};



local VUHDO_DEFAULT_CU_DE_STORED_SETTINGS = {
	["isIcon"] = true,
	["isColor"] = false,
--	["SOUND"] = "",
	["animate"] = false,
	["timer"] = true,
	["isStacks"] = true,
	["isAliveTime"] = false,
	["isFullDuration"] = false,
	["isMine"] = true,
	["isOthers"] = true,
	["isBarGlow"] = false,
	["isIconGlow"] = false,

--	["color"] = {
--		["R"] = 0.6,
--		["G"] = 0.3,
--		["B"] = 0,
--		["O"] = 1,
--		["TR"] = 0.8,
--		["TG"] = 0.5,
--		["TB"] = 0,
--		["TO"] = 1,
--		["useText"] = true,
--		["useBackground"] = true,
--		["useOpacity"] = true,
--	},
};



local VUHDO_DEFAULT_SPELL_TRACE_STORED_SETTINGS = {
	["isMine"] = true,
	["isOthers"] = false,
	["duration"] = 2,
	["isIncoming"] = false,
};



VUHDO_DEFAULT_POWER_TYPE_COLORS = {
	[VUHDO_UNIT_POWER_MANA]         = VUHDO_makeFullColor(0,     0,     1,    1,  0,     0,     1,    1),
	[VUHDO_UNIT_POWER_RAGE]         = VUHDO_makeFullColor(1,     0,     0,    1,  1,     0,     0,    1),
	[VUHDO_UNIT_POWER_FOCUS]        = VUHDO_makeFullColor(1,     0.5,   0.25, 1,  1,     0.5,   0.25, 1),
	[VUHDO_UNIT_POWER_ENERGY]       = VUHDO_makeFullColor(1,     1,     0,    1,  1,     1,     0,    1),
	[VUHDO_UNIT_POWER_COMBO_POINTS] = VUHDO_makeFullColor(0,     1,     1,    1,  0,     1,     1,    1),
	[VUHDO_UNIT_POWER_RUNIC_POWER]  = VUHDO_makeFullColor(0.5,   0.5,   0.5,  1,  0.5,   0.5,   0.5,  1),
	[VUHDO_UNIT_POWER_LUNAR_POWER]  = VUHDO_makeFullColor(0.87,  0.95,  1,    1,  0.87,  0.95,  1,    1),
	[VUHDO_UNIT_POWER_MAELSTROM]    = VUHDO_makeFullColor(0.09,  0.56,  1,    1,  0.09,  0.56,  1,    1),
	[VUHDO_UNIT_POWER_INSANITY]     = VUHDO_makeFullColor(0.15,  0.97,  1,    1,  0.15,  0.97,  1,    1),
	[VUHDO_UNIT_POWER_FURY]         = VUHDO_makeFullColor(0.54,  0.09,  0.69, 1,  0.54,  0.09,  0.69, 1),
	[VUHDO_UNIT_POWER_PAIN]         = VUHDO_makeFullColor(0.54,  0.09,  0.69, 1,  0.54,  0.09,  0.69, 1),
};



--
local function VUHDO_convertToTristate(aBoolean, aTrueVal, aFalseVal)
	if (aBoolean == nil or aBoolean == false) then
		return aFalseVal;
	elseif (aBoolean == true) then
		return aTrueVal;
	else
		return aBoolean;
	end
end



--
function VUHDO_loadDefaultConfig()
	local _, tClass = UnitClass("player");

	if (VUHDO_CONFIG == nil) then
		VUHDO_CONFIG = VUHDO_decompressOrCopy(VUHDO_DEFAULT_CONFIG);
	end
	
	VUHDO_CONFIG["BLIZZ_UI_HIDE_PLAYER"] = VUHDO_convertToTristate(VUHDO_CONFIG["BLIZZ_UI_HIDE_PLAYER"], 3, 2);
	VUHDO_CONFIG["BLIZZ_UI_HIDE_PARTY"] = VUHDO_convertToTristate(VUHDO_CONFIG["BLIZZ_UI_HIDE_PARTY"], 3, 2);
	VUHDO_CONFIG["BLIZZ_UI_HIDE_TARGET"] = VUHDO_convertToTristate(VUHDO_CONFIG["BLIZZ_UI_HIDE_TARGET"], 3, 2);
	VUHDO_CONFIG["BLIZZ_UI_HIDE_PET"] = VUHDO_convertToTristate(VUHDO_CONFIG["BLIZZ_UI_HIDE_PET"], 3, 2);
	VUHDO_CONFIG["BLIZZ_UI_HIDE_FOCUS"] = VUHDO_convertToTristate(VUHDO_CONFIG["BLIZZ_UI_HIDE_FOCUS"], 3, 2);
	VUHDO_CONFIG["BLIZZ_UI_HIDE_RAID"] = VUHDO_convertToTristate(VUHDO_CONFIG["BLIZZ_UI_HIDE_RAID"], 3, 2);
	VUHDO_CONFIG["BLIZZ_UI_HIDE_RAID_MGR"] = VUHDO_convertToTristate(VUHDO_CONFIG["BLIZZ_UI_HIDE_RAID_MGR"], 3, 2);

	VUHDO_DEFAULT_CONFIG = VUHDO_decompressIfCompressed(VUHDO_DEFAULT_CONFIG);
	VUHDO_CONFIG = VUHDO_ensureSanity("VUHDO_CONFIG", VUHDO_CONFIG, VUHDO_DEFAULT_CONFIG);

	-- deprecate "show only for friendly" option in favor of distinct show on friendly and hostile options
	if VUHDO_CONFIG["CUSTOM_DEBUFF"] and VUHDO_DEFAULT_CONFIG["CUSTOM_DEBUFF"] then
		-- FIXME: VUHDO_ensureSanity() skips creating booleans but fixing this breaks some models
		for tKey, tValue in pairs(VUHDO_DEFAULT_CONFIG["CUSTOM_DEBUFF"]) do
			if type(tValue) == "boolean" and VUHDO_CONFIG["CUSTOM_DEBUFF"][tKey] == nil then
				VUHDO_CONFIG["CUSTOM_DEBUFF"][tKey] = tValue;
			end
		end

		if VUHDO_CONFIG["CUSTOM_DEBUFF"]["isShowOnlyForFriendly"] ~= nil then
			if VUHDO_CONFIG["CUSTOM_DEBUFF"]["isShowOnlyForFriendly"] then
				VUHDO_CONFIG["CUSTOM_DEBUFF"]["isShowHostile"] = false;
			end

			VUHDO_CONFIG["CUSTOM_DEBUFF"]["isShowOnlyForFriendly"] = nil;
		end
	end

	VUHDO_DEFAULT_CONFIG = VUHDO_compressAndPackTable(VUHDO_DEFAULT_CONFIG);

	if ((VUHDO_CONFIG["VERSION"] or 1) < 4) then
		VUHDO_CONFIG["IS_SHARE"] = true;
		VUHDO_CONFIG["VERSION"] = 4;
	end

	if (VUHDO_DEFAULT_RANGE_SPELLS[tClass] ~= nil) then
		for tUnitReaction, tRangeSpells in pairs(VUHDO_DEFAULT_RANGE_SPELLS[tClass]) do
			local tIsGuessRange = true;

			if VUHDO_strempty(VUHDO_CONFIG["RANGE_SPELL"][tUnitReaction]) then
				for _, tRangeSpell in pairs(tRangeSpells) do
					if type(tRangeSpell) == "number" then
						tRangeSpell = IsPlayerSpell(tRangeSpell) and GetSpellName(tRangeSpell) or "!";
					end

					if tRangeSpell ~= "!" then
						VUHDO_CONFIG["RANGE_SPELL"][tUnitReaction] = tRangeSpell;
						tIsGuessRange = false;

						break;
					end
				end

				VUHDO_CONFIG["RANGE_PESSIMISTIC"][tUnitReaction] = tIsGuessRange;
			end
		end
	end

	-- add relevant custom debuffs for raid bosses
	-- 5.x - MoP
--	VUHDO_addCustomSpellIds(20,
--
--		--[[ Heart of Fear ]]
--
--		--Imperial Vizier Zor'lok
--		122760, --Exhale
--		123812, --Pheromones of Zeal
--		122740, --Convert
--		122706, --Noise Cancelling
--		--Blade Lord Ta'yak
--		122949, --Unseen Strike
--		123474, --Overwhelming Assault
--		124783, --Storm Unleashed
--		123180, --Wind Step
--		--Garalon
--		122835, --Pheromones
--		123081, --Pungency
--		122774, --Crush (knocked down)
--		123423, --Weak Points
--		--123120, --Pheromone Trail
--		--Wind Lord Mel'jarak
--		121881, --Amber Prison
--		122055, --Residue
--		122064, --Corrosive Resin
--		--Amber-Shaper Un'sok
--		121949, --Parasitic Growth
--		122784, --Reshape Life
--		122064, --Corrosive Resin
--		--122504, --Burning Amber
--		--Grand Empress Shek'zeer
--		125390, --Fixate
--		123707, --Eyes of the Empress
--		123788, --Cry of Terror
--		124097, --Sticky Resin
--		125824, --Trapped!
--		124777, --Poison Bomb
--		124821, --Poison-Drenched Armor
--		124827, --Poison Fumes
--		124849, --Consuming Terror
--		124863, --Visions of Demise
--		123845, --Heart of Fear
--		123184, --Dissonance Field
--		125283, --Sha Corruption
--		--Trash
--		123417, --Dismantled Armor
--		123422, --Arterial Bleeding
--		123434, --Gouge Throat
--		123436, --Riposte
--		123497, --Gale Force Winds
--		123180, --Wind Step
--		123420, --Stunning Strike
--		125081, --Slam
--		125490, --Burning Sting
--		126901, --Mortal Rend
--		126912, --Grievous Whirl
--
--		--[[ Mogushan Vaults ]]
--
--		-- Trash
--		118562, --Petrified
--		116596, --Smoke Bomb
--		116970, --Sundering Bite
--		121087, --Curse of Vitality
--		120670, --Pyroblast
--		116606, --Troll Rush
--		--The Stone Guard
--		130395, --Jasper Chains
--		130774, --Amethyst Pool
--		116038, --Jasper Petrification
--		115861, --Cobalt Petrification
--		116060, --Amethyst Petrification
--		116281, --Cobalt Mine Blast
--		125206, --Rend Flesh
--		116008, --Jade Petrification
--		--Feng The Accursed
--		131788, --Lightning Lash
--		116040, --Epicenter
--		116942, --Flaming Spear
--		116784, --Wildfire Spark
--		102464, --Arcane Shock
--		116417, --Arcane Resonance
--		116364, --Arcane Velocity
--		116374, --Lightning Charge
--		131792, --Shadowburn
--		--Gara'jal the Spiritbinder
--		122151, --Voodoo doll
--		117723, --Frail Soul
--		116260, --Crossed Over
--		116278, --Soul Sever
--		--The Spirit Kings
--		117708, --Maddening Shout
--		118303, --Fixate
--		118048, --Pillaged
--		118135, --Pinned Down
--		118047, --Pillage: Target
--		118163, --Robbed Blind
--		--Elegon
--		117878, --Overcharged
-- 		117949, --Closed circuit
--		117945, --Arcing Energy
--		132222, --Destabilizing Energies
--		--Will of the Emperor
--		116835, --Devastating Arc
--		132425, --Stomp
--		116525, --Focused Assault
--		116778, --Focused Defense
--		117485, --Impeding Thrust
--		116550, --Energizing Smash
--		116829, --Focused Energy
--
--		--[[ Sha of Anger ]]
--
--		119626, --Aggressive Behavior
--		119488, --Unleashed Wrath
--		119610, --Bitter Thoughts
--
--		--[[ Terrace of Endless Spring ]]
--
--		--Protector Kaolan
--		117519, --Touch of Sha
--		111850, --Lightning Prison: Targeted
--		117436, --Lightning Prison: Stunned
--		118191, --Corrupted Essence
--		117986, --Defiled Ground: Stacks
--		117235, --Purified
--		117283, --Cleansing Waters
--		117353, --Overwhelming Corruption
--
--		--Tsulong
--		122768, --Dread Shadows
--		122777, --Nightmares
--		122752, --Shadow Breath
--		122789, --Sunbeam
--		123012, --Terrorize
--		123036, --Fright
--		122858, --Bathed in Light
--
--		--Lei Shi
--		123121, --Spray
--		123705, --Scary Fog
--
--		--Sha of Fear
--		119414, --Breath of Fear
--		129147, --Onimous Cackle
--		119983, --Dread Spray
--		120669, --Naked and Afraid
--		75683, --Waterspout
--		120629, --Huddle in Terror
--		120394, --Eternal Darkness
--		129189, --Sha Globe
--		119086, --Penetrating Bolt
--		119775  --Reaching Attack
--
--	);


--	VUHDO_addCustomSpellIds(21,
--		-- Jin'rokh
--		138006,
--		137399,
--		138732,
--		138349,
--		137371,
--		-- Horridon
--		136769,
--		136767,
--		136708,
--		136723,
--		136587,
--		136710,
--		136670,
--		136573,
--		136512,
--		136719,
--		136654,
--		140946,
--		-- Council of Elders
--		136922,
--		137084,
--		137641,
--		136878,
--		136857,
--		137650,
--		137359,
--		137972,
--		136860,
--		--Tortos
--		134030,
--		134920,
--		136751,
--		136753,
--    		137633,
--		--Megaera
--		139822,
--		134396,
--		137731,
--		136892,
--		139909,
--		137746,
--		139843,
--		139840,
--		140179,
--		--Ji-Kun
--		138309,
--		138319,
--		140571,
--		134372,
--		--Durumu the Forgotten
--		133768,
--		133767,
--		136932,
--		134122,
--		134123,
--		134124,
--		133795,
--		133597,
--		133732,
--		133677,
--		133738,
--		133737,
--		133675,
--		134626,
--		--Primordius
--		140546,
--		136180,
--		136181,
--		136182,
--		136183,
--		136184,
--		136185,
--		136186,
--		136187,
--		136050,
--		--Dark Animus
--		138569,
--		138659,
--		138609,
--		138691,
--		136962,
--		138480,
--		--Iron Qon
--		134647,
--		136193,
--		135147,
--		134691,
--		135145,
--		136520,
--		137669,
--		137668,
--		137654,
--		136577,
--		136192,
--		--Twin Consorts
--		137440,
--		137417,
--		138306,
--		137408,
--		137360,
--		137375,
--		136722,
--		--Lei Shen
--		135695,
--		136295,
--		135000,
--		136543,
--		134821,
--		136326,
--		137176,
--		136853,
--		135153,
--		136914,
--		135001
--		--Ra-den
--	);

	-- Siege of Orgrimmar
--	VUHDO_addCustomSpellIds(22,
--		--Trash
--		143828,
--		146452,
--		--Immerseus
--		143436,
--		143298,
--		--The Fallen Protectors
--		143962,
--		144397,
--		143009,
--		143198,
--		1776,
--		144365,
--		144176,
--		147383,
--		143424,
--		--Sha of Pride
--		144358,
--		144574,
--		--Galakras
--		147200,
--		146763,
--		147705,
--		147029,
--		--Iron Juggernaut
--		144459,
--		144467,
--		144498,
--		146325,
--		--Kor'kron Dark Shaman
--		17153,
--		144215,
--		144089,
--		143993,
--		144331,
--		144328,
--		144089,
--		--General Nazgrim
--		143494,
--		143638,
--		143480,
--		143882,
--		--Malkorok
--		142990,
--		142862,
--		142861,
--		143919,
--		--Spoils of Pandaria
--		145993,
--		144853,
--		142524,
--		146217,
--		145712,
--		--Thok the Bloodthirsty
--		143766,
--		143428,
--		143445,
--		143780,
--		143773,
--		143800,
--		143767,
--		143783,
--		--Siegecrafter Blackfuse
--		143385,
--		145444,
--		143856,
--		144466,
--		--Paragons of the Klaxxi
--		142931,
--		34940,
--		142315,
--		142929,
--		142668,
--		143974,
--		143735,
--		143275,
--		143278,
--		143339,
--		142948,
--		143702,
--		143358,
--		142808
--		--Garrosh Hellscream
--	);
	
	-- 6.0 - Warlords of Draenor - part 1
--	VUHDO_addCustomSpellIds(23,
--		-- [[ Draenor World Bosses ]]
--		-- Drov
--		175915, -- Acid Breath
--		-- Rukhmar
--		167615, -- Pierce Armor
--		167650, -- Loose Quills
--		-- Tarlna
--		176004, -- Savage Vines
--
--		-- [[ Highmaul ]]
--		-- Brackenspore
--		163241, -- Rot
--		-- Kargath Bladefist
--		159250, -- Blade Dance
--		159947, -- Chain Hurl
--		162497, -- On The Hunt
--		-- Koragh
--		162186, -- Expel Magic: Arcane
--		162185, -- Expel Magic: Fire
--		-- Margok
--		156225, -- Arcane Wrath
--		158605, -- Mark Of Chaos
--		157801, -- Slow
--		157763, -- Fixate
--		-- Tectus
--		162346, -- Crystalline Barrage
--		162370, -- Crystalline Barrage Damage
--		162892, -- Petrification
--		-- The Butcher
--		156151, -- Tenderizer
--		-- Twin Ogron
--		167200, -- Arcane Wound
--		158241, -- Blaze
--		163372, -- Arcane Volatility
--
--		-- [[ Blackrock Foundry ]]
--		-- Blackhand
--		156096, -- Marked for Death
--		157000, -- Attach Slag Bombs
--		-- Darmac
--		154960, -- Pinned Down
--		155061, -- Rend and Tear
--		154981, -- Conflagration
--		155030, -- Seared Flesh
--		155236, -- Crush Armor
--		-- Gruul
--		155078, -- Overwhelming Blows
--		155326, -- Petrifying Slam
--		155506, -- Petrified
--		-- Hansgar and Franzok
--		157139, -- Shattered Vertebrae
--		-- Kagraz
--		154932, -- Molten Torrent
--		163284, -- Rising Flames
--		154952, -- Fixate
--		155074, -- Charring Breath
--		-- Kromog
--		156766, -- Warped Armor
--		-- Oregorger
--		156297, -- Acid Torrent
--		-- The Blast Furnace
--		158345, -- Shields Down
--		155196, -- Fixate
--		155192, -- Bomb
--		176121, -- Volatile Fire
--		175104, -- Melt Armor
--		-- The Iron Maidens
--		164271, -- Penetrating Shot
--		156214, -- Convulsive Shadows
--		156007, -- Impale
--		158315, -- Dark Hunt
--		157950, -- Heart Seeker
--		-- Thogar
--		155921, -- Enkindle
--		155864, -- Pulse Grenade
--		159481  -- Delayed Siege Bomb
--	);

	-- 6.0 - Warlords of Draenor - part 2
--	VUHDO_addCustomSpellIds(24,
--		-- [[ Highmaul ]]
--		-- Brackenspore
--		-- Kargath Bladefist
--		-- Koragh
--		-- Margok
--		164004, -- Arcane Wrath: Displacement
--		164005, -- Arcane Wrath: Fortification
--		164006, -- Arcane Wrath: Replication
--		164176, -- Mark of Chaos: Displacement
--		164178, -- Mark of CHaos: Fortification
--		164191  -- Mark of Chaos: Replication
--		-- Tectus
--		-- The Butcher
--		-- Twin Ogron
--	);

	-- 6.1 - Warlords of Draenor
--	VUHDO_addCustomSpellIds(25,
--		-- [[ Blackrock Foundry ]]
--		-- Blackhand
--		156743, -- Impaled
--		156047, -- Slagged
--		-- Darmac
--		-- Gruul
--		-- Hansgar and Franzok
--		-- Kagraz
--		155049, -- Singe
--		155277, -- Blazing Radiance
--		-- Kromog
--		-- Oregorger
--		-- The Blast Furnace
--		-- The Iron Maidens
--		156112  -- Convulsive Shadows
--		-- Thogar
--	);

	-- 6.2 - WoD - Hellfire Citadel
--	VUHDO_addCustomSpellIds(26,
--		-- [[ Hellfire Citadel ]]
--		-- Hellfire Assault
--		156096, -- Marked for Death
--		-- Iron Reaver
--		182001, -- Unstable Orb
--		-- Kormrok
--		181306, -- Explosive Burst
--		181321, -- Fel Touch
--		-- Hellfire High Council
--		184358, -- Fel Rage
--		-- Killrogg Deadeye
--		180372, -- Heart Seeker
--		182159, -- Fel Corruption
--		-- Gorefiend
--		179978, -- Touch of Doom
--		179909, -- Shared Fate
--		-- Shadow-Lord Iskar
--		179202, -- Eye of Anzu
--		181956, -- Phantasmal Winds
--		182323, -- Phantasmal Wounds
--		182173, -- Fel Chakram
--		181753, -- Fel Bomb
--		179218, -- Phantasmal Obliteration
--		-- Socrethar the Eternal
--		182635, -- Reverberating Blow
--		-- Fel Lord Zakuun
--		181508, -- Seed of Destruction
--		179620, -- Fel Crystal
--		-- Xhul'horac
--		186490, -- Chains of Fel
--		186546, -- Black Hole
--		-- Tyrant Velhari
--		180128, -- Edict of Condemnation
--		180526, -- Font of Corruption
--		-- Mannoroth
--		181099, -- Mark of Doom
--		181597, -- Mannoroth's Gaze
--		-- Archimonde
--		185590, -- Desecrate
--		183864, -- Shadow Blast
--		183828, -- Death Brand
--		184931, -- Shackled Torment
--
--		-- [[ Draenor World Bosses ]]
--		-- Supreme Lord Kazzak
--		187664, -- Fel Breath
--		187668  -- Mark of Kazzak
--	);

	-- 6.2 - WoD - Hellfire Citadel - part 2
--	VUHDO_addCustomSpellIds(30,
--		-- [[ Hellfire Citadel ]]
--		-- Hellfire High Council
--		184449, -- Mark of the Necromancer Purple
--		184450, -- Mark of the Necromancer Purple
--		184676, -- Mark of the Necromancer Purple
--		185065, -- Mark of the Necromancer Yellow
--		185066, -- Mark of the Necromancer Red
--		-- Socrethar the Eternal
--		184124, -- Gift of the Man'ari
--		-- Fel Lord Zakuun
--		189030, -- Befouled Red
--		189031, -- Befouled Yellow
--		189032, -- Befouled Green
--		-- Tyrant Velhari
--		180164, -- Touch of Harm
--		180166  -- Touch of Harm
--	);

	-- 7.0 - Legion
--	VUHDO_addCustomSpellIds(31, 
--		-- [[ Emerald Nightmare ]]
--		-- Nythendra
--		--204504, -- Infested
--		--203045, -- Infested Ground
--		203096, -- Rot
--		--204463, -- Volatile Rot
--		203646, -- Burst of Corruption
--		--221028, -- Unstable Decay
--		-- Il'gynoth, Heart of Corruption
--		--212886, -- Nightmare Corruption
--		--215845, -- Dispersed Spores
--		--210099, -- Fixate
--		209469, -- Touch of Corruption 
--		--209471, -- Nightmare Explosion
--		208697, -- Mind Flay
--		208929, -- Spew Corruption
--		215128, -- Cursed Blood
--		-- Erethe Renferal
--		215307, -- Web of Pain
--		--215460, -- Necrotic Venom
--		--213124, -- Venomous Pool
--		--210850, -- Twisting Shadows
--		218519, -- Wind Burn
--		210228, -- Dripping Fangs
--		-- Ursoc
--		204859, -- Rend Flesh
--		198006, -- Focused Gaze
--		--198108, -- Momentum
--		--197980, -- Nightmarish Cacophony
--		205611, -- Miasma
--		-- Dragons of Nightmare
--		207681, -- Nightmare Bloom
--		--204731, -- Wasting Dread
--		203787, -- Volatile Infection
--		204044, -- Shadow Burst
--		--204078, -- Bellowing Roar
--		--214543, -- Collapsing Nightmare
--		-- Cenarius
--		--210279, -- Creeping Nightmares
--		210315, -- Nightmare Brambles
--		211507, -- Nightmare Javelin
--		211471, -- Scorned Touch
--		216516, -- Ancient Dream
--		-- Xavius
--		206005, -- Dream Simulacrum
--		--206109, -- Awakening to the Nightmare
--		208431, -- Descent into Madness
--		--207409, -- Madness
--		206651, -- Darkening Soul
--		211802, -- Nightmare Blades
--		--205771, -- Tormenting Fixation
--		209158, -- Blackening Soul
--		205612, -- Blackened
--		210451  -- Bonds of Terror
--		--208385, -- Tainted Discharge
--		--211634  -- The Infinite Dark
--	);

	-- 7.1 - Legion - Trial of Valor
--	VUHDO_addCustomSpellIds(32,
--		-- [[ Trial of Valor ]]
--		-- Odyn
--		227959, -- Storm of Justice
--		228915, -- Stormforged Spear
--		228030, -- Expel Light
--		-- Guarm
--		228228, -- Flame Lick
--		228250, -- Shadow Lick
--		-- Helya
--		232450, -- Corrupted Axion
--		193367, -- Fetid Rot
--		228519 -- Anchor Slam
--	);

	-- 7.1 - Legion - Trial of Valor (part 2)
--	VUHDO_addCustomSpellIds(33,
--		-- [[ Trial of Valor ]]
--		-- Odyn
--		228918, -- Stormforged Spear
--		228914, -- Stormforged Spear
--		228932, -- Stormforged Spear
--		227811, -- Raging Tempest
--		-- Guarm
--		228253, -- Shadow Lick
--		-- Helya
--		232488  -- Dark Hatred
--	);

	-- 7.1.5 - Legion - Nighthold
--	VUHDO_addCustomSpellIds(34,
--		-- [[ Nighthold ]]
--		-- Skorpyron
--		204766, -- Energy Surge
--		211659, -- Arcane Tether
--		-- Chronomatic Anomaly
--		206607, -- Chronometric Particles
--		206609, -- Time Release
--		206615, -- Time Bomb
--		-- Trilliax
--		-- Spellblade Aluriel
--		212587, -- Mark of Frost
--		-- Tichondrius
--		206480, -- Carrion Plague
--		212795, -- Brand of Argus
--		208230, -- Feast of Blood
--		216024, -- Volatile Wound
--		216040, -- Burning Soul
--		-- Krosus
--		-- High Botanist Tel'arn
--		218502, -- Recursive Strikes
--		219049, -- Toxic Spores
--		218424, -- Parasitic Fetter
--		-- Star Augur Etraeus
--		206585, -- Absolute Zero
--		206388, -- Felburst
--		205649, -- Fel Ejection
--		206965, -- Voidburst
--		207143, -- Void Ejection
--		-- Grand Magistrix Elisande
--		-- Gul'dan
--		212568, -- Drain
--		206883, -- Soul Vortex
--		206222, -- Bonds of Fel
--		206221, -- Empowered Bonds of Fel
--		208802  -- Soul Corrosion
--	);

	-- 7.1.5 - Legion - Nighthold (part 2)
--	VUHDO_addCustomSpellIds(35,
--		-- [[ Nighthold ]]
--		-- Chronomatic Anomaly
--		219964, -- Time Release Green
--		219965, -- Time Release Yellow
--		219966  -- Time Release Red
--		-- Trilliax
--		-- Grand Magistrix Elisande
--	);

	-- 7.2.5 - Legion - Tomb of Sargeras
--	VUHDO_addCustomSpellIds(36,
--		-- [[ Tomb of Sargeras ]]
--		-- Goroth
--		231363, -- Burning Armor
--		230345, -- Crashing Comet
--		233062, -- Infernal Burning
--		-- Demonic Inquistion
--		-- Atrigan
--		-- Belac
--		-- Harjatan
--		231998, -- Jagged Abrasion
--		-- Mistress Sassz'ine
--		230201, -- Burden of Pain
--		230920, -- Consuming Hunger
--		230139, -- Hydra Shot
--		232754, -- Hydra Acid
--		230276, -- Jaws from the Deep
--		-- Sisters of the Moon
--		-- Huntress Kasparian
--		236550, -- Discorporate
--		237561, -- Twilight Glaive
--		-- Priestess Lunaspyre
--		239264, -- Lunar Fire
--		236519, -- Moon Burn
--		-- Captain Yathae Moonstrike
--		233263, -- Embrace of the Eclipse
--		236596, -- Rapid Shot
--		-- The Desolate Host
--		236515, -- Shattering Scream
--		236459, -- Soulbind
--		235621, -- Spirit Realm
--		236011, -- Tormented Cries
--		238442, -- Spear of Anguish
--		235924, -- Spear of Anguish
--		236131, -- Wither
--		236138, -- Wither
--		-- Maiden of Vigilence
--		235117, -- Unstable Soul
--		-- Fallen Avatar
--		239739, -- Dark Mark
--		236494, -- Desolate
--		242017, -- Black Winds
--		240728, -- Tainted Essence
--		-- Kil'jaeden
--		234310, -- Armageddon Rain
--		245509, -- Felclaws    
--		243624  -- Lingering Wail
--	);

	-- 7.3.0 - Legion - Antorus, The Burning Throne
--	VUHDO_addCustomSpellIds(37, 
--		-- [[ Antorus, The Burning Throne ]]
--		-- Garothi
--		246220, -- Fel Bombardment (tank)
--	        244410, -- Decimation
--		246920, -- Haywire Decimation (M)
----	        246848, -- Luring Destruction (M)
--		-- Felhounds of Sargeras
----		251445, -- Smouldering
--		244091, -- Singed
--		244768, -- Desolate Gaze
--		248815, -- Enflamed
----		245098, -- Decay
--		245024, -- Consumed
--		244071, -- Weight of Darkness
--		248819, -- Siphoned
--		244086, -- Molten Touch
--		254747, -- Burning Maw
----		244055, -- Shadowtouched (M)
----		244054, -- Flametouched (M)
----		245022, -- Burning Remnant (M)
--		244517, -- Lingering Flames (M)
--		-- Antoran High Command
----		244892, -- Exploit Weakness
--		257974, -- Chaos Pulse
----		244910, -- Felshield
--		245121, -- Entropic Blast
--		253037, -- Demonic Charge
--		244172, -- Psychic Assault
----		244388, -- Psychic Scarring
--		244729, -- Shock Grenade
--		244748, -- Shocked (M)
--		-- Portal Keeper Hasabel
----		244016, -- Reality Tear
----		245118, -- Cloying Shadows
----		245075, -- Hungering Gloom
----		245099, -- Mind Fog
--		244613, -- Everburning Flames
--		245050, -- Delusions
--		245040, -- Corrupt
--		244849, -- Caustic Slime (M)
----		245075, -- Hungering Gloom (M)
----		244915, -- Poison Essence
----		244915, -- Leech Essence
--		244949, -- Felsilk Wrap
--		246208, -- Acidic Web
----		244709, -- Fiery Detonation
--		-- Eonar, the Lifebinder
--		248332, -- Rain of Fel
----		248861, -- Spear of Doom
--		248795, -- Fel Wake
----		250691, -- Burning Embers (M)
----		250140, -- Foul Steps (M)
--		249016, -- Feedback: Targeted (M)
--		249017, -- Feedback: Arcane Singularity (M)
--		249014, -- Feedback: Foul Steps (M)
--		249015, -- Feedback: Burning Embers (M)
--		-- Imonar the Soulhunter
----		247367, -- Shock Lance
--		247687, -- Sever
----		250255, -- Empowered Shock Lance
--		250006, -- Empowered Pulse
----		255029, -- Asleep
--		247552, -- Sleep Canister
----		247565, -- Slumber Gas
----		247716, -- Charged Blasts
--		250224, -- Shocked
--		247949, -- Shrapnel Blast
--		247641, -- Stasis Trap
----		250191, -- Conflagration
----		254181, -- Seared Skin
----		248255, -- Infernal Rockets
--		-- Kin�garoth
----		254919, -- Forging Strike
--		249535, -- Demolished (M)
--		246706, -- Demolish
--		246687, -- Decimation
----		246840, -- Ruiner	
--		-- Varimathras
--		244094, -- Necrotic Embrace
--		243961, -- Misery
--		244042, -- Marked Prey
--		244005, -- Dark Fissure
----		243980, -- Torment of Fel
----		243968, -- Torment of Flames
----		243977, -- Torment of Frost
----		243974, -- Torment of Shadows
--		248732, -- Echoes of Doom (M)		
--		-- Coven of Shivarra
----		253203, -- Shivan Pact
----		244899, -- Fiery Strike
----		245518, -- Flashfreeze
--		253520, -- Fulminating Pulse
----		253752, -- Sense of Dread
----		245627, -- Whirling Saber
----		253697, -- Orb of Frost
----		252861, -- Storm of Darkness
--		246763, -- Fury of Golganneth
--		245586, -- Chilled Blood (healing absorb)
----		245921, -- Spectral Army
----		245671, -- Flames of Khaz'goroth
----		250757, -- Cosmic Glare (M)
--		-- Aggramar
----		244291, -- Foe Breaker
----		245990, -- Taeschalach�s Reach
--		245994, -- Scorching Blaze
----		246014, -- Searing Tempest
----		244736, -- Wake of Flame
----		244912, -- Blazing Eruption
----		245916, -- Molten Remnants
--		254452, -- Ravenous Blaze (M)
----		247079, -- Empowered Flame Rend
----		255062, -- Empowered Searing Tempest
----		255060, -- Empowered Foe Breaker
----		255528, -- Searing Binding
--		-- Argus the Unmaker
----		248499, -- Sweeping Scythe
----		258039, -- Deadly Scythe 
--		248396, -- Soulblight
----		253901, -- Strength of Sea
----		253903, -- Strength of Sky
----		258647, -- Gift of the Sea
----		258646, -- Gift of the Sky
----		255199, -- Avatar of Aggramar
--		250669, -- Soulburst
----		255200, -- Aggramar�s Boon
----		257299, -- Ember of Rage
----		252729, -- Cosmic Ray
----		252634, -- Cosmic Smash
----		257215, -- Titanforged
----		248167, -- Death Fog
----		256899, -- Soul Detonation
----		251815, -- Edge of Obliteration
----		257299, -- Ember of Rage
----		258373, -- Grasp (M)
----		257961, -- Chains of Sargeras (M)
----		257966, -- Sentence of Sargeras (M)
----		258026, -- Punishment (M)
----		258000, -- Shattered Bonds (M)
----		257930, -- Crushing (M)
----		257931, -- Sargeras Fear (M)
----		257869, -- Unleashed (M)
----		257911, -- Sargeras Rage (M)
--		251570  -- Soulbomb
--	);

	-- -- 8.0.1 - Battle for Azeroth - Uldir
	-- VUHDO_addCustomSpellIds(38, 
	-- 	-- [[ Uldir ]]
	-- 	-- Taloc
	-- 	271222, -- Plasma Discharge 
	-- 	-- Mother
	-- 	267821, -- Defense Grid
	-- 	-- Devourer
	-- 	262313, -- Malodorous Miasma
	-- 	262314, -- Deadly Disease
	-- 	-- Zek'voz
	-- 	264219, -- Fixate
	-- 	265360, -- Roiling Deceit
	-- 	265662, -- Corruptors Pact
	-- 	-- Vectis
	-- 	265129, -- Omega Vector
	-- 	265178, -- Mutagenic Pathogen
	-- 	265212, -- Gestate
	-- 	-- Zul
	-- 	273365, -- Dark Revelation
	-- 	269936, -- Fixate
	-- 	274358, -- Rupturing Blood
	-- 	274271, -- Deathwish
	-- 	-- Mythrax
	-- 	272336, -- Annihilation
	-- 	272536, -- Imminent Ruin
	-- 	-- G'huun
	-- 	263334, -- Putrid Blood
	-- 	263372  -- Power Matrix

	-- );

	-- -- 8.0.1 - Battle for Azeroth - World Bosses
	-- VUHDO_addCustomSpellIds(39,
	-- 	-- [[ World Bosses ]]
	-- 	-- T'zane
	-- 	261552, -- Terror Wail
	-- 	261632, -- Consuming Spirits
	-- 	-- Ji'arak
	-- 	261509, -- Clutch
	-- 	260908, -- Storm Wing
	-- 	-- Hailstone Construct
	-- 	274891, -- Glacial Breath
	-- 	-- The Lion's Roar
	-- 	271246, -- Demolisher Cannon
	-- 	-- Azurethos
	-- 	274839, -- Azurethos' Fury
	-- 	-- Warbringer Yenajz
	-- 	274904, -- Reality Tear
	-- 	274932  -- Endless Abyss
	-- 	-- Dunegorger Kraulok
	-- );
		
	-- -- 8.0.1 - Battle for Azeroth - Debuff Absorbs
	-- VUHDO_addCustomSpellIds(40,
	-- 	-- [[ The Underrot ]]
	-- 	-- Diseased Lasher
	-- 	278961, -- Decaying Mind
	-- 	-- [[ Uldir - Vectis ]]
	-- 	265206  -- Immunosuppression
	-- );

	-- -- 8.0.1 - Battle for Azeroth - Uldir part 2
	-- VUHDO_addCustomSpellIds(41, 
	-- 	-- [[ Uldir ]]
	-- 	-- Taloc
	-- 	275270, -- Fixate 
	-- 	-- Mother
	-- 	-- Devourer
	-- 	-- Zek'voz
	-- 	-- Vectis
	-- 	265127, -- Lingering Infection
	-- 	267160, -- Omega Vector		
	-- 	267161, -- Omega Vector
	-- 	267162, -- Omega Vector
	-- 	267163, -- Omega Vector
	-- 	267164, -- Omega Vector
	-- 	267165, -- Omega Vector
	-- 	267166, -- Omega Vector
	-- 	267167, -- Omega Vector
	-- 	267168, -- Omega Vector
	-- 	-- Zul
	-- 	276020, -- Fixate
	-- 	-- Mythrax
	-- 	-- G'huun
	-- 	272506  -- Explosive Corruption
	-- );

	-- -- 8.1 - Battle for Azeroth - Battle of Dazar'alor
	-- VUHDO_addCustomSpellIds(42,
	-- 	-- [[ Battle of Dazar'alor ]]
	-- 	-- Champion of the Light
	-- 	-- Grong (Horde & Alliance)
	-- 	285875, -- Rending Bite
	-- 	282215, -- Megatomic Seeker Missile
	-- 	282471, -- Voodoo Blast
	-- 	285659, -- Apetagonizer Core
	-- 	286434, -- Necrotic Core
	-- 	-- Jadefire Masters
	-- 	285632, -- Stalking
	-- 	286988, -- Searing Embers
	-- 	-- Treasure Guardian Opulence
	-- 	287072, -- Liquid Gold
	-- 	283507, -- Volatile Charge
	-- 	284519, -- Pulse Quickening Toxin
	-- 	-- Conclave of the Chosen
	-- 	282444, -- Lacerating Claws
	-- 	286811, -- Akunda's Wrath
	-- 	282209, -- Mark of Prey
	-- 	-- King Rastakhan
	-- 	285213, -- Caress of Death
	-- 	288449, -- Death's Door
	-- 	284662, -- Seal of Purification
	-- 	285349, -- Plague of Fire
	-- 	284781, -- Grevious Axe
	-- 	-- High Tinker Mekkatorque
	-- 	286480, -- Anti-Tampering Shock
	-- 	282182, -- Buster Cannon
	-- 	287757, -- Gigavolt Charge
	-- 	283411, -- Gigavolt Blast
	-- 	-- Stormwall Blockade
	-- 	284405, -- Tempting Song
	-- 	285000, -- Kelp Wrapping
	-- 	285350, -- Storm's Wail
	-- 	-- Lady Jaina Proudmoore
	-- 	287365, -- Searing Pitch
	-- 	288218, -- Broadside
	-- 	289220, -- Heart of Frost
	-- 	288038  -- Marked Target
	-- );

	-- -- 8.1.5 - Battle for Azeroth - Crucible of Storms
	-- VUHDO_addCustomSpellIds(43, 
	-- 	-- [[ Crucible of Storms ]]
	-- 	-- Restless Cabal
	-- 	293300, -- Storm Essence
	-- 	282540, -- Agent of Demise
	-- 	282432, -- Crushing Doubt
	-- 	287762, -- Crushing Doubt
	-- 	131097, -- Crushing Doubt
	-- 	131098, -- Crushing Doubt
	-- 	282437, -- Crushing Doubt
	-- 	282386, -- Aphotic Blast
	-- 	283524, -- Aphotic Blast
	-- 	293488, -- Oceanic Essence
	-- 	-- Uu'nat
	-- 	285345, -- Maddening Eyes of N'zoth
	-- 	285652, -- Insatiable Torment
	-- 	295609, -- Insatiable Torment
	-- 	286770, -- Embrace of the Void
	-- 	284733, -- Embrace of the Void
	-- 	283053, -- Embrace of the Void
	-- 	282738, -- Embrace of the Void
	-- 	285367  -- Piercing Gaze of N'zoth
	-- );

	-- --- 8.1.5 - Battle for Azeroth - Crucible of Storms part 2
	-- VUHDO_addCustomSpellIds(44,
	-- 	-- [[ Crucible of Storms ]]
	-- 	-- Uu'nat
	-- 	284722, -- Umbral Shell
	-- 	286771  -- Umbral Shell
	-- );

	-- --- 8.2.0 - Battle for Azeroth - Rise of Azshara
	-- VUHDO_addCustomSpellIds(45,
	-- 	-- [[ Eternal Palace ]]
	-- 	-- Abyssal Commander
-- --		294715, -- Toxic Brand
-- --		294711, -- Frost Mark
	-- 	295421, -- Overflowing Venom
	-- 	295348, -- Overflowing Chill
	-- 	300882, -- Inversion Sickness
	-- 	300957, -- Inversion Sickness
	-- 	-- Blackwater Behemoth
	-- 	292127, -- Darkest Depths
-- --		292133, -- Bioluminescence
	-- 	292307, -- Gaze from Below
	-- 	292167, -- Toxic Spine
	-- 	301494, -- Piercing Barb
	-- 	298595, -- Glowing Stinger
	-- 	-- Radiance of Aszhara
	-- 	296737, -- Arcane Bomb
	-- 	296746, -- Arcane Bomb
	-- 	-- Lady Ashvane
	-- 	296693, -- Waterlogged
	-- 	297333, -- Briny Bubble
	-- 	-- Orgozoa
	-- 	298306, -- Incubation Fluid
	-- 	295779, -- Aqua Lance
	-- 	-- The Queen's Court
	-- 	297586, -- Suffering
	-- 	299914, -- Frenetic Charge
	-- 	296851, -- Fanatical Verdict
	-- 	300545, -- Mighty Rupture
	-- 	-- Za'qul
	-- 	292971, -- Hysteria
	-- 	292963, -- Dread
	-- 	293509, -- Manifest Nightmares
	-- 	298192, -- Dark Beyond
	-- 	-- Queen Azshara
-- --		298569, -- Drained Soul
-- --		301078, -- Charged Spear 
-- --		299094, -- Beckon
	-- 	303828, -- Crushing Depths
	-- 	303825, -- Crushing Depths
	-- 	303657, -- Arcane Burst
	-- 	300492, -- Static Shock
	-- 	297907  -- Cursed Heart
	-- );

	-- -- 8.3.0 - Battle for Azeroth - Visions of N'Zoth
	-- VUHDO_addCustomSpellIds(46,
	-- 	-- [[ Ny'alotha, The Waking City ]]
	-- 	-- Wrathion
	-- 	306163, -- Incineration
	-- 	314347, -- Noxious Choke
	-- 	-- Maut
	-- 	307806, -- Devour Magic
	-- 	-- The Prophet Skitra
	-- 	308059, -- Shadow Shock
	-- 	307950, -- Shred Psyche
	-- 	308065, -- Shred Psyche
	-- 	-- Dark Inquisitor Xanesh
	-- 	313198, -- Void-Touched
	-- 	312406, -- Voidwoken
	-- 	309569, -- Voidwoken
	-- 	-- Vexiona
	-- 	307314, -- Encroaching Shadows
	-- 	307359, -- Despair
	-- 	310323, -- Desolation
	-- 	-- The Hivemind
	-- 	313461, -- Corrosion
	-- 	313129, -- Mindless
	-- 	313460, -- Nullification
	-- 	-- Ra-den
	-- 	313227, -- Decaying Wound
	-- 	310019, -- Charged Bonds
	-- 	310022, -- Charged Bonds
	-- 	313077, -- Unstable Nightmare
	-- 	315252, -- Dread Inferno Fixate
	-- 	316065, -- Corrupted Existence
	-- 	-- Shad'har the Insatiable
	-- 	307358, -- Debilitating Spit
	-- 	307945, -- Umbral Eruption
	-- 	306929, -- Bubbling Breath
	-- 	307260, -- Fixate
	-- 	-- Drest'agath
	-- 	310552, -- Mind Flay
	-- 	310358, -- Muttering Insanity
	-- 	-- Il'gynoth
	-- 	275269, -- Fixate
	-- 	311159, -- Cursed Blood
	-- 	-- Carapice of N'Zoth
	-- 	307008, -- Breed Madness
	-- 	306973, -- Madness Bomb
	-- 	306984, -- Insanity Bomb
	-- 	-- N'Zoth
	-- 	308885, -- Mind Flay
	-- 	317112, -- Evoke Anguish
	-- 	309980, -- Paranoia
	-- 	316541, -- Paranoia
	-- 	316542  -- Paranoia
	-- );

	-- -- 8.3.0 - Battle for Azeroth - Visions of N'Zoth part 2
	-- VUHDO_addCustomSpellIds(47,
	-- 	-- [[ Ny'alotha, The Waking City ]]
	-- 	-- Wrathion
	-- 	-- Maut
	-- 	-- The Prophet Skitra
	-- 	-- Dark Inquisitor Xanesh
	-- 	306311, -- Soul Flay
	-- 	-- Vexiona
	-- 	-- The Hivemind
	-- 	-- Ra-den
	-- 	306184  -- Unleashed Void
	-- 	-- Shad'har the Insatiable
	-- 	-- Drest'agath
	-- 	-- Il'gynoth
	-- 	-- Carapice of N'Zoth
	-- 	-- N'Zoth
	-- );

	-- -- 9.0.2 - Shadowlands
	-- VUHDO_addCustomSpellIds(48, 
	-- 	-- [[ Castle Nathria ]]
	-- 	-- Shriekwing
	-- 	328897, -- Exsanguinated
	-- 	342077, -- Echolocation
	-- 	341684, -- The Blood Lantern
	-- 	341489, -- Bloodlight
	-- 	-- 340324, -- Sanguine Ichor (ground damage)
	-- 	-- Huntsman Altimor
	-- 	335111, -- Huntsman's Mark
	-- 	334971, -- Jagged Claws
	-- 	334945, -- Vicious Lunge
	-- 	334852, -- Petrifying Howl
	-- 	-- 334893, -- Stone Shards (ground damage)
	-- 	-- Sun King's Salvation
	-- 	323402, -- Reflection of Guilt
	-- 	-- 326456, -- Burning Remnants (tank)
	-- 	328479, -- Eyes on Target
	-- 	-- 325442, -- Vanquished (tank)
	-- 	326583, -- Crimson Flurry
	-- 	339251, -- Drained Soul
	-- 	332871, -- Greater Castigation
	-- 	338600, -- Cloak of Flames
	-- 	343026, -- Cloak of Flames
	-- 	337859, -- Cloak of Flames
	-- 	-- 328579, -- Smoldering Remnants (ground damage)
	-- 	-- Artificer Xy'Mox
	-- 	328448, -- Dimensional Tear
	-- 	325236, -- Glyph of Destruction
	-- 	327902, -- Fixate
	-- 	-- 327414, -- Possesion (mind control)
	-- 	340860, -- Withering Touch
	-- 	-- Hungering Destroyer
	-- 	329298, -- Gluttonous Miasma
	-- 	-- Lady Inerva Darkvein
	-- 	-- 325382, -- Warped Desires (tank)
	-- 	325936, -- Shared Cognition
	-- 	324983, -- Shared Suffering
	-- 	332664, -- Concentrated Anima
	-- 	-- 331573, -- Unconscionable Guilt (tank)
	-- 	-- 325713, -- Lingering Anima (ground damage)
	-- 	-- The Council of Blood
	-- 	330967, -- Fixate
	-- 	-- 346651, -- Drain Essence (tank)
	-- 	331706, -- Scarlet Letter
	-- 	331637, -- Dark Recital
	-- 	-- 347350, -- Dancing Fever (dispel, disease)
	-- 	-- Sludgefist
	-- 	331209, -- Hateful Gaze
	-- 	342420, -- Chain Them!
	-- 	342419, -- Chain Them!
	-- 	335470, -- Chain Slam
	-- 	-- 335361, -- Stonequake (ground damage)
	-- 	-- Stone Legion Generals
	-- 	333377, -- Wicked Mark
	-- 	-- 334765, -- Heart Rend (dispel, magic)
	-- 	339690, -- Crystalize
	-- 	-- 342425, -- Stone Fist (tank)
	-- 	342655, -- Volatile Anima Infusion
	-- 	-- Sire Denathrius
	-- 	327796, -- Night Hunter
	-- 	329906, -- Carnage
	-- 	-- 329181, -- Wracking Pain (tank)
	-- 	-- 332585, -- Scorn (tank)
	-- 	332794, -- Fatal Finesse
	-- 	327992  -- Desolation (ground damage)
	-- );

	-- -- 9.0.2 - Shadowlands
	-- VUHDO_addCustomSpellIds(49, 
	-- 	-- [[ Necrotic Wake ]]
	-- 	320462, -- Necrotic Bolt
	-- 	320170, -- Necrotic Bolt
	-- 	-- [[ Theater of Pain ]]
	-- 	330784, -- Necrotic Bolt
	-- 	330868, -- Necrotic Bolt Volley
	-- 	-- Death Knight player ability
	-- 	223929  -- Necrotic Wound
	-- );

	-- -- 9.0.2 - Shadowlands
	-- VUHDO_addCustomSpellIds(50, 
	-- 	-- [[ Castle Nathria ]]
	-- 	-- Shriekwing
	-- 	330713, -- Earsplitting Shriek
	-- 	-- Huntsman Altimor
	-- 	335304, -- Sinseeker
	-- 	335112, -- Huntsman's Mark
	-- 	335113, -- Huntsman's Mark
	-- 	-- Lady Inerva Darkvein
	-- 	326538, -- Anima Web
	-- 	324982, -- Shared Suffering
	-- 	-- 340452, -- Change of Heart (tank)
	-- 	-- Artificer Xy'Mox
	-- 	328468, -- Dimensional Tear
	-- 	326302, -- Stasis Trap
	-- 	-- The Council of Blood
	-- 	331636, -- Dark Recital
	-- 	346651, -- Drain Essence
	-- 	-- Sludgefist
	-- 	339189, -- Chain Bleed
	-- 	-- Stone Legion Generals
	-- 	333913, -- Wicked Laceration
	-- 	334771, -- Heart Hemorrhage
	-- 	342735, -- Ravenous Feast
	-- 	342698, -- Volatile Anima Infection
	-- 	-- Sire Denathrius
	-- 	332797, -- Fatal Finesse (DoT debuff)
	-- 	335873, -- Rancor (ground damage)
	-- 	329951  -- Impale
	-- 	-- 332619  -- Shattering Pain (tank)
	-- 	-- 334016  -- Unworthy
	-- );

	-- -- 9.1.0 - Shadowlands
	-- VUHDO_addCustomSpellIds(51, 
	-- 	-- [[ Sanctum of Domination ]]
	-- 	-- The Tarragrue
	-- 	347668, -- Grasp of Death
	-- 	-- Eye of the Jailer
	-- 	350713, -- Slothful Corruption
	-- 	-- The Nine
	-- 	350542, -- Fragments of Destiny
	-- 	-- 350184, -- Daschla's Mighty Impact
	-- 	350109, -- Brynja's Mournful Dirge
	-- 	-- Remnant of Ner'zhul
	-- 	350073, -- Torment
	-- 	-- 350469, -- Curse of Malevolence
	-- 	-- Soulrender Dormazain
	-- 	353429, -- Tormented
	-- 	-- Painsmith Raznal
	-- 	-- Guardian of the First Ones
	-- 	350496, -- Threat Neutralization
	-- 	352833, -- Disintegration
	-- 	-- 350455, -- Unstable Energy
	-- 	-- Fatescribe Roh-Kalo
	-- 	353931, -- Twist Fate
	-- 	350568, -- Call of Eternity
	-- 	-- Kel'Thuzad
	-- 	354289, -- Necrotic Miasma
	-- 	348760, -- Frost Blast
	-- 	-- Sylvanas Windrunner
	-- 	347670, -- Shadow Dagger
	-- 	347807, -- Barbed Arrow
	-- 	347607, -- Banshee's Mark
	-- 	351091, -- Destabilize (heal absorb)
	-- 	347704  -- Veil of Darkness (heal absorb)
	-- );

	-- -- 9.2.0 - Shadowlands
	-- VUHDO_addCustomSpellIds(52,
	-- 	-- [[ Sepulcher of the First Ones ]]
	-- 	-- Vigilant Guardian
	-- 	360458, -- Unstable Core
	-- 	366393, -- Searing Ablation
	-- 	367571, -- Sear
	-- 	-- Skolex, the Insatiable Ravener
	-- 	-- 359778, -- Ephemera Dust
	-- 	-- 364522, -- Devouring Blood (dispel, magic)
	-- 	360448, -- Retch
	-- 	359981, -- Rend
	-- 	366070, -- Volatile Residue (ground damage)
	-- 	-- Artificer Xy'mox
	-- 	362882, -- Stasis Trap
	-- 	362803, -- Glyph Of Relocation
	-- 	364030, -- Debilitating Ray
	-- 	365681, -- Massive Blast
	-- 	-- Halondrus the Reclaimer
	-- 	361309, -- Lightshatter Beam
	-- 	-- 365297, -- Crushing Prism (dispel, magic)
	-- 	368957, -- Volatile Charges
	-- 	369207, -- Planetcracker Beam (ground damage)
	-- 	-- Dausegne, the Fallen Oracle
	-- 	-- 361966, -- Infused Strikes (tank)
	-- 	364289, -- Staggering Barrage
	-- 	361018, -- Staggering Barrage
	-- 	361225, -- Encroaching Dominion (ground damage)
	-- 	-- Prototype Pantheon
	-- 	360259, -- Gloom Bolt
	-- 	-- 360687, -- Runecarvers Deathtouch (dispel, magic)
	-- 	361067, -- Bastions Ward
	-- 	362352, -- Pinned
	-- 	362383, -- Anima Bolt
	-- 	-- Lihuvim, Principal Architect
	-- 	362622, -- Unstable Mote
	-- 	363795, -- Deconstructing Energy
	-- 	364073, -- Degenerate
	-- 	360869, -- Requisitioned (fixate)
	-- 	-- 360159, -- Unstable Mote (ground damage)
	-- 	-- Anduin Wrynn
	-- 	365293, -- Befouled Barrier
	-- 	-- 364031, -- Gloom (dispel, magic)
	-- 	365024, -- Wicked Star
	-- 	365021, -- Wicked Star
	-- 	366849, -- Domination Word: Pain
	-- 	-- Lords of Dread
	-- 	360006, -- Cloud of Carrion
	-- 	360012, -- Cloud of Carrion
	-- 	359963, -- Opened Veins
	-- 	-- 360148, -- Bursting Dread (dispel, magic)
	-- 	-- 360241, -- Unsettling Dreams (dispel, magic)
	-- 	360287, -- Anguishing Strike
	-- 	-- Rygelon
	-- 	361548, -- Dark Eclipse
	-- 	362806, -- Dark Eclipse
	-- 	362081, -- Cosmic Ejection
	-- 	-- 362172, -- Corrupted Wound (tank)
	-- 	362798, -- Cosmic Radiation (ground damage)
	-- 	362088, -- Cosmic Irregularity
	-- 	-- The Jailer
	-- 	365153, -- Dominating Will
	-- 	359868, -- Shattering Blast
	-- 	-- 362075, -- Domination (mind control)
	-- 	366132, -- Tyranny
	-- 	366020, -- Mark Of Tyranny
	-- 	360282, -- Rune of Damnation
	-- 	360281, -- Rune of Damnation
	-- 	365219  -- Chains Of Anguish
	-- );

	-- 10.0.2 Dragonflight
	-- VUHDO_addCustomSpellIds(53,
	--	-- [[ Vault of the Incarnates ]]
	--	-- Eranog
	--	394917, -- Leaping Flames
	--	370597, -- Kill Order
	--	396023, -- Incinerating Roar
	--	-- Terros
	--	381315, -- Awakened Earth
	--	380487, -- Rock Blast
	--	381595, -- Seismic Assault
	--	382458, -- Resonant Aftermath
	--	391592, -- Infused Fallout
	--	-- The Primal Council
	--	371624, -- Conductive Mark
	--	371836, -- Primal Blizzard
	--	374039, -- Meteor Axes
	--	-- Sennarth the Cold Breath
	--	372044, -- Wrapped in Webs
	--	371976, -- Chilling Blast
	--	372082, -- Enveloping Webs
	--	373048, -- Suffocating Webs
	--	373027, -- Suffocating Webs
	--	-- Dathea Ascended
	--	391686, -- Conductive Mark
	--	-- Kurog Grimtotem
	--	372044, -- Absolute Zero
	--	382563, -- Magma Burst
	--	391696, -- Lethal Current
	--	391019, -- Frigid Torrent
	--	396106, -- Dominance
	--	372517, -- Frozen Solid
	--	391056, -- Enveloping Earth
	--	391055, -- Enveloping Earth
	--	373487, -- Lightning Crash
	--	374623, -- Frost Binds
	--	-- Broodkeeper Diurna
	--	388716, -- Icy Shroud
	--	388717, -- Icy Shroud
	--	388920, -- Frozen Shroud
	--	388918, -- Frozen Shroud
	--	375575, -- Flame Sentry
	--	-- Raszageth
	--	381615, -- Static Charge
	--	399713, -- Fulminating Charge
	--	377467  -- Magnetic Charge
	-- );

	-- 11.1.0 The War Within Season 2 Dungeons
	VUHDO_addCustomSpellIds(54, {
		[302477] = false,
		[323437] = false,
		[285440] = false,
		[387151] = false,
		[106113] = false,
		[381862] = false,
		[374789] = false,
		[372087] = false,
		[384953] = false,
		[144519] = false,
		[263943] = false,
		[254959] = false,
		[428542] = false,
		[416139] = false,
		[409266] = false,
		[204611] = false,
		[201399] = false,
		[260741] = false,
		[333492] = false,
		[427329] = false,
		[327393] = false,
		[427378] = false,
		[460135] = false,
		[448064] = false,
		[451107] = false,
		[431349] = false,
		[473540] = false,
		[447272] = false,
		[422245] = false,
		[466190] = false,
		[426619] = false,
		[259940] = false,
		[468815] = false,
		[447439] = false,
		[228958] = true,
		[227985] = true,
		[323406] = true,
		[324154] = true,
		[356666] = true,
		[319626] = true,
		[356925] = true,
		[168398] = true,
		[162415] = true,
		[346962] = true,
		[154469] = true,
		[375937] = true,
		[376864] = true,
		[193660] = true,
		[397907] = true,
		[397908] = true,
		[373693] = true,
		[372718] = true,
		[373735] = true,
		[265019] = true,
		[377222] = true,
		[372566] = true,
		[372224] = true,
		[372570] = true,
		[381770] = true,
		[256363] = true,
		[377017] = true,
		[377018] = true,
		[197546] = true,
		[415436] = true,
		[250096] = true,
		[260551] = true,
		[200238] = true,
		[267907] = true,
		[255445] = true,
		[255421] = true,
		[273470] = true,
		[451395] = true,
		[451396] = true,
		[433740] = true,
		[449169] = true,
		[322486] = true,
		[331288] = true,
	} );

	-- 11.1.0 The War Within Liberation of Undermine
	VUHDO_addCustomSpellIds(55, {
		-- Vexie Fullthrottle
		[459978] = false,
		[468216] = false,
		[459683] = true,
		-- Cauldron of Carnage
		[1213690] = false,
		[1214009] = false,
		-- Rik Reverb
		[467044] = false,
		[469380] = false,
		[468119] = false,
		[1214598] = true,
		-- Stix Bunkjunker
		[461536] = false,
		[472893] = true,
		[466748] = true,
		-- Sprocketmonger Lockenstock
		[1217261] = false,
		-- One-Armed Bandit
		[471927] = true,
		-- Mug'Zee
		[466476] = false,
		-- Chrome King Gallywix
		[1220761] = false,
		[1214755] = false,
		[466154] = false,
		[466751] = false,
		[466834] = false,
		[469297] = false,
		[467182] = true,
	} );

	local debuffRemovalList = {};

	for tIndex, tName in pairs(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"]) do
		-- I introduced a bug which added some default custom debuffs by spell ID
		-- where spell ID was a number and not a string, this causes all sorts of odd 
		-- bugs in the custom debuff code particularly any getKeyFromValue table lookups
		if (type(tName) == "number") then
			-- if we encounter a custom debuff stored by an actual number flag this key for removal
			debuffRemovalList[tIndex] = tIndex;
		else
			VUHDO_customDebuffsAddDefaultSettings(tName);
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tName] = VUHDO_ensureSanity(
				"CUSTOM_DEBUFF.STORED_SETTINGS",
				VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tName],
				VUHDO_DEFAULT_CU_DE_STORED_SETTINGS
			);
		end
	end

	-- in Lua removal can't be done in place while perserving order properly
	-- so do the removal in a second pass
	for tIndex, _ in pairs(debuffRemovalList) do
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"][tIndex] = nil;
	end

	-- add default spells to track with spell trace
	VUHDO_addSpellTraceSpellIds(1, 
		-- Shaman
		1064,   -- Chain Heal
		-- Priest
		34861,  -- Holy Word: Sanctify
		596,    -- Prayer of Healing
		194509  -- Power Word: Radiance
	);

	for _, tName in pairs(VUHDO_CONFIG["SPELL_TRACE"]["STORED"]) do
		VUHDO_spellTraceAddDefaultSettings(tName);

		VUHDO_CONFIG["SPELL_TRACE"]["STORED_SETTINGS"][tName] = VUHDO_ensureSanity(
			"SPELL_TRACE.STORED_SETTINGS",
			VUHDO_CONFIG["SPELL_TRACE"]["STORED_SETTINGS"][tName],
			VUHDO_DEFAULT_SPELL_TRACE_STORED_SETTINGS
		);
	end

	if (VUHDO_POWER_TYPE_COLORS == nil) then
		VUHDO_POWER_TYPE_COLORS = VUHDO_decompressOrCopy(VUHDO_DEFAULT_POWER_TYPE_COLORS);
	end
	VUHDO_POWER_TYPE_COLORS = VUHDO_ensureSanity("VUHDO_POWER_TYPE_COLORS", VUHDO_POWER_TYPE_COLORS, VUHDO_DEFAULT_POWER_TYPE_COLORS);
	VUHDO_DEFAULT_POWER_TYPE_COLORS = VUHDO_compressAndPackTable(VUHDO_DEFAULT_POWER_TYPE_COLORS);
end



local VUHDO_DEFAULT_PANEL_SETUP = {
	["RAID_ICON_FILTER"] = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[7] = true,
		[8] = true,
	},

	["HOTS"] = {
		["VERSION"] = 2,
	},

	["PANEL_COLOR"] = {
		["TEXT"] = {
			["TR"] = 1, ["TG"] = 0.82, ["TB"] = 0, ["TO"] = 1,
			["useText"] = true,
		},
		["HEALTH_TEXT"] = {
			["useText"] = false,
			["TR"] = 1, ["TG"] = 0, ["TB"] = 0, ["TO"] = 1,
		},
		["BARS"] = {
			["R"] = 0.7, ["G"] = 0.7, ["B"] = 0.7, ["O"] = 1,
			["useBackground"] = true, ["useOpacity"] = true,
		},
		["classColorsName"] = false,
		["isSolidGradient"] = false,
		["solidMaxColor"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 1,
			["useBackground"] = true, ["useOpacity"] = true,
		},
	},

	["BAR_COLORS"] = {

		["TARGET"] = {
			["TR"] = 1,	["TG"] = 1,	["TB"] = 1,	["TO"] = 1,
			["R"] = 0,	["G"] = 1,	["B"] = 0,	["O"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
			["modeText"] = 2, -- 1=enemy, 2=solid, 3=class color, 4=gradient
			["modeBack"] = 1,
		},

		["IRRELEVANT"] =  {
			["R"] = 0, ["G"] = 0, ["B"] = 0.4, ["O"] = 0.2,
			["TR"] = 1, ["TG"] = 0.82, ["TB"] = 0, ["TO"] = 1,
			["useText"] = false, ["useBackground"] = false, ["useOpacity"] = true,
			["useClassColor"] = false,
		},
		["INCOMING"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.33,
			["TR"] = 1, ["TG"] = 0.82, ["TB"] = 0, ["TO"] = 1,
			["useText"] = false, ["useBackground"] = false,	["useOpacity"] = true,
			["useClassColor"] = false,
		},
		["SHIELD"] = {
			["R"] = 0.35, ["G"] = 0.52, ["B"] = 1, ["O"] = 1,
			["TR"] = 0.35, ["TG"] = 0.52, ["TB"] = 1, ["TO"] = 1,
			["useText"] = false, ["useBackground"] = true,	["useOpacity"] = true,
			["useClassColor"] = false,
		},
		["OVERSHIELD"] = {
			["R"] = 0.35, ["G"] = 0.52, ["B"] = 1, ["O"] = 1,
			["TR"] = 0.35, ["TG"] = 0.52, ["TB"] = 1, ["TO"] = 1,
			["useText"] = false, ["useBackground"] = true,	["useOpacity"] = true,
			["useClassColor"] = false,
		},
		["HEAL_ABSORB"] = {
			["R"] = 1, ["G"] = 0.4, ["B"] = 0.4, ["O"] = 1,
			["TR"] = 0.35, ["TG"] = 0.52, ["TB"] = 1, ["TO"] = 1,
			["useText"] = false, ["useBackground"] = true,	["useOpacity"] = true,
			["useClassColor"] = false,
		},
		["DIRECTION"] = {
			["R"] = 1, ["G"] = 0.4, ["B"] = 0.4, ["O"] = 1,
			["useBackground"] = true,
		},
		["EMERGENCY"] = VUHDO_makeFullColor(1, 0, 0, 1,   1, 0.82, 0, 1),
		["NO_EMERGENCY"] = VUHDO_makeFullColor(0, 0, 0.4, 1,   1, 0.82, 0, 1),
		["OFFLINE"] = VUHDO_makeFullColor(0.298, 0.298, 0.298, 0.21,   0.576, 0.576, 0.576, 0.58),
		["DEAD"] = VUHDO_makeFullColor(0.3, 0.3, 0.3, 0.5,   0.5, 0.5, 0.5, 1),
		["OUTRANGED"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.25,
			["TR"] = 0, ["TG"] = 0, ["TB"] = 0, ["TO"] = 0.5,
			["useText"] = false, ["useBackground"] = false, ["useOpacity"] = true,
		},
		["TAPPED"] = VUHDO_makeFullColor(0.4, 0.4, 0.4, 1,   0.4, 0.4, 0.4, 1),
		["TARGET_FRIEND"] = VUHDO_makeFullColor(0, 1, 0, 1,   0, 1, 0, 1),
		["TARGET_NEUTRAL"] = VUHDO_makeFullColor(1, 1, 0, 1,   1, 1, 0, 1),
		["TARGET_ENEMY"] = VUHDO_makeFullColor(1, 0, 0, 1,   1, 0, 0, 1),

		["DEBUFF" .. VUHDO_DEBUFF_TYPE_NONE] =  {
			["useText"] = false, ["useBackground"] = false, ["useOpacity"] = false,
		},
		["DEBUFF" .. VUHDO_DEBUFF_TYPE_POISON] = VUHDO_makeFullColor(0, 0.592, 0.8, 1,   0, 1, 0.686, 1),
		["DEBUFF" .. VUHDO_DEBUFF_TYPE_DISEASE] = VUHDO_makeFullColor(0.8, 0.4, 0.4, 1,   1, 0, 0, 1),
		["DEBUFF" .. VUHDO_DEBUFF_TYPE_CURSE] = VUHDO_makeFullColor(0.7, 0, 0.7, 1,   1, 0, 1, 1),
		["DEBUFF" .. VUHDO_DEBUFF_TYPE_MAGIC] = VUHDO_makeFullColor(0.4, 0.4, 0.8, 1,   0.329, 0.957, 1, 1),
		["DEBUFF" .. VUHDO_DEBUFF_TYPE_CUSTOM] = VUHDO_makeFullColor(0.6, 0.3, 0, 1,   0.8, 0.5, 0, 1),
		["DEBUFF" .. VUHDO_DEBUFF_TYPE_BLEED] = VUHDO_makeFullColor(1, 0.2, 0, 1,   1, 0.2, 0.4, 1),
		["DEBUFF" .. VUHDO_DEBUFF_TYPE_ENRAGE] = VUHDO_makeFullColor(0.95, 0.95, 0.32, 1,   1, 1, 0, 1),
		["DEBUFF_BAR_GLOW"] = VUHDO_makeFullColor(0.95, 0.95, 0.32, 1,   1, 1, 0, 1),
		["DEBUFF_ICON_GLOW"] = VUHDO_makeFullColor(0.95, 0.95, 0.32, 1,   1, 1, 0, 1),
		["CHARMED"] = VUHDO_makeFullColor(0.51, 0.082, 0.263, 1,   1, 0.31, 0.31, 1),

		["BAR_FRAMES"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.7,
			["useBackground"] = true, ["useOpacity"] = true,
		},

		["OVERHEAL_TEXT"] = {
			["TR"] = 0.8, ["TG"] = 1, ["TB"] = 0.8, ["TO"] = 1,
			["useText"] = true, ["useOpacity"] = true,
		},

		["HOTS"] = {
			["useColorText"] = false,
			["useColorBack"] = false,
			["isFadeOut"] = false,
			["isFlashWhenLow"] = false,
			["showShieldAbsorb"] = true,
			["isPumpDivineAegis"] = false,
			["WARNING"] = {
				["R"] = 0.5, ["G"] = 0.2,	["B"] = 0.2, ["O"] = 1,
				["TR"] = 1,	["TG"] = 0.6,	["TB"] = 0.6,	["TO"] = 1,
				["useText"] = true,	["useBackground"] = true,
				["lowSecs"] = 3, ["enabled"] = false,
			},
		},

		["HOT1"] = VUHDO_makeHotColor(1, 0.3, 0.3, 1,   1, 0.6, 0.6, 1),
		["HOT2"] = VUHDO_makeHotColor(1, 1, 0.3, 1,   1, 1, 0.6, 1),
		["HOT3"] = VUHDO_makeHotColor(1, 1, 1, 1,   1, 1, 1, 1),
		["HOT4"] = VUHDO_makeHotColor(0.3, 0.3, 1, 1,   0.6, 0.6, 1, 1),
		["HOT5"] = VUHDO_makeHotColor(1, 0.3, 1, 1,   1, 0.6, 1, 1),

		["HOT6"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 0.75,
			["useBackground"] = true,
		},

		["HOT7"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 0.75,
			["useBackground"] = true,
		},

		["HOT8"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 0.75,
			["useBackground"] = true,
		},

		["HOT9"] = VUHDO_makeHotColor(0.3, 1, 1, 1,   0.6, 1, 1, 1),
		["HOT10"] = VUHDO_makeHotColor(0.3, 1, 0.3, 1,   0.6, 1, 0.3, 1),
		["HOT11"] = VUHDO_makeHotColor(0.890, 0.408, 0.133, 1,   0.992, 0.443, 0.063, 1),
		["HOT12"] = VUHDO_makeHotColor(0.2, 0.576, 0.498, 1,   0.3, 0.676, 0.598, 1),

		["HOT_CHARGE_2"] = VUHDO_makeFullColorWoOpacity(1, 1, 0.3, 1,   1, 1, 0.6, 1),
		["HOT_CHARGE_3"] = VUHDO_makeFullColorWoOpacity(0.3, 1, 0.3, 1,   0.6, 1, 0.6, 1),
		["HOT_CHARGE_4"] = VUHDO_makeFullColorWoOpacity(0.8, 0.8, 0.8, 1,   1, 1, 1, 1),

		["useDebuffIcon"] = false,
		["useDebuffIconBossOnly"] = true,

		["RAID_ICONS"] = {
			["enable"] = false,
			["filterOnly"] = false,

			["1"] = VUHDO_makeFullColorWoOpacity(1, 0.976, 0.305, 1,   0.980,	1, 0.607, 1),
			["2"] = VUHDO_makeFullColorWoOpacity(1, 0.513, 0.039, 1,   1, 0.827, 0.419, 1),
			["3"] = VUHDO_makeFullColorWoOpacity(0.788, 0.290, 0.8, 1,   1, 0.674, 0.921, 1),
			["4"] = VUHDO_makeFullColorWoOpacity(0, 0.8, 0.015, 1,   0.698, 1, 0.698, 1),
			["5"] = VUHDO_makeFullColorWoOpacity(0.466, 0.717, 0.8, 1,   0.725, 0.870, 1, 1),
			["6"] = VUHDO_makeFullColorWoOpacity(0.121, 0.690, 0.972, 1,   0.662, 0.831, 1, 1),
			["7"] = VUHDO_makeFullColorWoOpacity(0.8, 0.184, 0.129, 1,   1, 0.627, 0.619, 1),
			["8"] = VUHDO_makeFullColorWoOpacity(0.847, 0.866, 0.890, 1,   0.231, 0.231, 0.231, 1),
		},

		["CLUSTER_FAIR"] = VUHDO_makeFullColorWoOpacity(0.8, 0.8, 0, 1,   1, 1, 0, 1),
		["CLUSTER_GOOD"] = VUHDO_makeFullColorWoOpacity(0, 0.8, 0, 1,   0, 1, 0, 1),

		["GCD_BAR"] = {
			["R"] = 0.4, ["G"] = 0.4, ["B"] = 0.4, ["O"] = 0.5,
			["useBackground"] = true,
		},

		["LIFE_LEFT"] = {
			["LOW"] = {
				["R"] = 1, ["G"] = 0, ["B"] = 0, ["O"] = 1,
				["useBackground"] = true,
			},
			["FAIR"] = {
				["R"] = 1, ["G"] = 1, ["B"] = 0, ["O"] = 1,
				["useBackground"] = true,
			},
			["GOOD"] = {
				["R"] = 0, ["G"] = 1, ["B"] = 0, ["O"] = 1,
				["useBackground"] = true,
			},
		},

		["THREAT"] = {
			["HIGH"] = {
				["R"] = 1, ["G"] = 0, ["B"] = 1, ["O"] = 1,
				["useBackground"] = true,
			},
			["LOW"] = {
				["R"] = 0, ["G"] = 1, ["B"] = 1, ["O"] = 1,
				["useBackground"] = true,
			},
		},
	}, -- BAR_COLORS
};



--
local VUHDO_DEFAULT_PER_PANEL_SETUP = {
	["HOTS"] = {
		["size"] = 40,
		["radioValue"] = 13,
		["iconRadioValue"] = 1,
		["stacksRadioValue"] = 2,

		["TIMER_TEXT"] = {
			["ANCHOR"] = "BOTTOMRIGHT",
			["X_ADJUST"] = 25,
			["Y_ADJUST"] = 0,
			["SCALE"] = 60,
			["FONT"] = "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf",
			["USE_SHADOW"] = false,
			["USE_OUTLINE"] = true,
			["USE_MONO"] = false,
		},

		["COUNTER_TEXT"] = {
			["ANCHOR"] = "TOP",
			["X_ADJUST"] = -25,
			["Y_ADJUST"] = 0,
			["SCALE"] = 66,
			["FONT"] = "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf",
			["USE_SHADOW"] = false,
			["USE_OUTLINE"] = true,
			["USE_MONO"] = false,
		},

		["SLOTS"] = {
			["firstFlood"] = true,
		},

		["SLOTCFG"] = {
			["firstFlood"] = true,
			["1"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["2"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["3"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["4"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["5"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["6"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["7"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["8"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["9"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["10"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["11"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
			["12"] = { ["mine"] = true, ["others"] = false, ["scale"] = 1 },
		},

		["BARS"] = {
			["radioValue"] = 1,
			["width"] = 25,
		},
	},
	["MODEL"] = {
		["ordering"] = VUHDO_ORDERING_STRICT,
		["sort"] = VUHDO_SORT_RAID_UNITID,
		["isReverse"] = false,
		["isPetsLast"] = false,
	},
--[[
	["POSITION"] = {
		["x"] = 100,
		["y"] = 668,
		["relativePoint"] = "BOTTOMLEFT",
		["orientation"] = "TOPLEFT",
		["growth"] = "TOPLEFT",
		["width"] = 200,
		["height"] = 200,
		["scale"] = 1,
	};
]]--

	["SCALING"] = {
		["columnSpacing"] = 5,
		["rowSpacing"] = 2,

		["borderGapX"] = 5,
		["borderGapY"] = 5,

		["barWidth"] = 80,
		["barHeight"] = 40,

		["showHeaders"] = true,
		["headerHeight"] = 12,
		["headerWidth"] = 100,
		["headerSpacing"] = 5,

		["manaBarHeight"] = 6,
		["sideLeftWidth"] = 6,
		["sideRightWidth"] = 6,

		["maxColumnsWhenStructured"] = 10,
		["maxRowsWhenLoose"] = 5,
		["ommitEmptyWhenStructured"] = true,
		["isPlayerOnTop"] = true,

		["showTarget"] = false,
		["targetSpacing"] = 3,
		["targetWidth"] = 30,

		["showTot"] = false,
		["totSpacing"] = 3,
		["totWidth"] = 30,
		["targetOrientation"] = 1,

		["isTarClassColText"] = true,
		["isTarClassColBack"] = false,

		["arrangeHorizontal"] = false,
		["alignBottom"] = false,

		["scale"] = 1,

		["isDamFlash"] = true,
		["damFlashFactor"] = 0.75,
	},

	["LIFE_TEXT"] = {
		["show"] = true,
		["mode"] = VUHDO_LT_MODE_PERCENT,
		["position"] = VUHDO_LT_POS_ABOVE,
		["verbose"] = false,
		["hideIrrelevant"] = false,
		["showTotalHp"] = false,
		["showEffectiveHp"] = false,
	},

	["ID_TEXT"] = {
		["showName"] = true, 
		["showNickname"] = false,
		["showClass"] = false,
		["showTags"] = true,
		["showPetOwners"] = true,
		["position"] = "CENTER+CENTER",
		["xAdjust"] = 0.000001,
		["yAdjust"] = 0.000001,
	},

	["PANEL_COLOR"] = {
		["barTexture"] = "VuhDo - Polished Wood",

		["BACK"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.35,
			["useBackground"] = true, ["useOpacity"] = true,
		},

		["BORDER"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.46,
			["useBackground"] = true, ["useOpacity"] = true,
			["file"] = "Interface\\Tooltips\\UI-Tooltip-Border",
			["edgeSize"] = 8,
			["insets"] = 1,
		},

		["TEXT"] = {
			["useText"] = true, ["useOpacity"] = true,
			["textSize"] = 10,
			["textSizeLife"] = 8,
			["maxChars"] = 0,
			["outline"] = false,
			["USE_SHADOW"] = true,
			["USE_MONO"] = false,
		},

		["HEADER"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 0.4,
			["TR"] = 1, ["TG"] = 0.859, ["TB"] = 0.38, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true,
			["barTexture"] = "LiteStepLite",
			["textSize"] = 10,
		},
	},

	["TOOLTIP"] = {
		["show"] = true,
		["position"] = 2, -- Standard-Pos
		["inFight"] = false,
		["showBuffs"] = false,
		["x"] = 100,
		["y"] = -100,
		["point"] = "TOPLEFT",
		["relativePoint"] = "TOPLEFT",
		["SCALE"] = 1,

		["BACKGROUND"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 1,
			["useBackground"] = true, ["useOpacity"] = true,
		},

		["BORDER"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 1,
			["useBackground"] = true, ["useOpacity"] = true,
		},
	},

	["PRIVATE_AURA"] = {
		["show"] = true,
		["scale"] = 0.8,
		["point"] = "LEFT",
		["xAdjust"] = 5,
		["yAdjust"] = 0,
	},

	["RAID_ICON"] = {
		["show"] = true,
		["scale"] = 1,
		["point"] = "TOP",
		["xAdjust"] = 0,
		["yAdjust"] = -20,
	},

	["OVERHEAL_TEXT"] = {
		["show"] = true,
		["scale"] = 1,
		["point"] = "LEFT",
		["xAdjust"] = 0,
		["yAdjust"] = 0,
	},

	["frameStrata"] = "MEDIUM",
};



--
function VUHDO_loadDefaultPanelSetup()
	local tAktPanel;

	if not VUHDO_PANEL_SETUP then
		VUHDO_PANEL_SETUP = VUHDO_decompressOrCopy(VUHDO_DEFAULT_PANEL_SETUP);
	end

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		if not VUHDO_PANEL_SETUP[tPanelNum] then
			VUHDO_PANEL_SETUP[tPanelNum] = VUHDO_decompressOrCopy(VUHDO_DEFAULT_PER_PANEL_SETUP);

			tAktPanel = VUHDO_PANEL_SETUP[tPanelNum];
			tAktPanel["MODEL"]["groups"] = VUHDO_DEFAULT_MODELS[tPanelNum];

			if VUHDO_DEFAULT_MODELS[tPanelNum] and VUHDO_ID_PRIVATE_TANKS == VUHDO_DEFAULT_MODELS[tPanelNum][1] then
				tAktPanel["SCALING"]["ommitEmptyWhenStructured"] = false;
			end

			if GetLocale() == "zhCN" or GetLocale() == "zhTW" or GetLocale() == "koKR" then
				tAktPanel["PANEL_COLOR"]["TEXT"]["font"] = "";
				tAktPanel["PANEL_COLOR"]["HEADER"]["font"] = "";
			else
				tAktPanel["PANEL_COLOR"]["TEXT"]["font"] = VUHDO_LibSharedMedia:Fetch('font', "Emblem");
				tAktPanel["PANEL_COLOR"]["HEADER"]["font"] = VUHDO_LibSharedMedia:Fetch('font', "Emblem");
			end

			if VUHDO_DEFAULT_MODELS[tPanelNum] and VUHDO_ID_MAINTANKS == VUHDO_DEFAULT_MODELS[tPanelNum][1] then
				tAktPanel["PANEL_COLOR"]["TEXT"]["textSize"] = 12;
			end
		end

		if not VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] and tPanelNum == 1 then
			VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] = {
				["x"] = 130,
				["y"] = 650,
				["relativePoint"] = "BOTTOMLEFT",
				["orientation"] = "TOPLEFT",
				["growth"] = "TOPLEFT",
				["width"] = 200,
				["height"] = 200,
				["scale"] = 1,
			};
		elseif not VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] and tPanelNum == 2 then
			VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] = {
				["x"] = 130,
				["y"] = 885,
				["relativePoint"] = "BOTTOMLEFT",
				["orientation"] = "TOPLEFT",
				["growth"] = "TOPLEFT",
				["width"] = 200,
				["height"] = 200,
				["scale"] = 1,
			};
		elseif not VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] then
			VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] = {
				["x"] = 130 + 75 * tPanelNum,
				["y"] = 650 - 75 * tPanelNum,
				["relativePoint"] = "BOTTOMLEFT",
				["orientation"] = "TOPLEFT",
				["growth"] = "TOPLEFT",
				["width"] = 200,
				["height"] = 200,
				["scale"] = 1,
			};
		end

		if VUHDO_PANEL_SETUP["HOTS"] and not VUHDO_PANEL_SETUP["HOTS"]["VERSION"] then
			local tHotSize;

			tAktPanel = VUHDO_PANEL_SETUP[tPanelNum];

			if tAktPanel["HOTS"] and tAktPanel["HOTS"]["size"] then
				tHotSize = tAktPanel["HOTS"]["size"];
			end

			tAktPanel["HOTS"] = VUHDO_decompressOrCopy(VUHDO_PANEL_SETUP["HOTS"]);

			if tHotSize then
				tAktPanel["HOTS"]["size"] = tHotSize;
			end
		end

		VUHDO_PANEL_SETUP[tPanelNum] = VUHDO_ensureSanity("VUHDO_PANEL_SETUP[" .. tPanelNum .. "]", VUHDO_PANEL_SETUP[tPanelNum], VUHDO_DEFAULT_PER_PANEL_SETUP);
	end

	if VUHDO_PANEL_SETUP["HOTS"] and not VUHDO_PANEL_SETUP["HOTS"]["VERSION"] then
		VUHDO_PANEL_SETUP["HOTS"] = nil;
	end

	VUHDO_PANEL_SETUP = VUHDO_ensureSanity("VUHDO_PANEL_SETUP", VUHDO_PANEL_SETUP, VUHDO_DEFAULT_PANEL_SETUP);
	VUHDO_DEFAULT_PANEL_SETUP = VUHDO_compressAndPackTable(VUHDO_DEFAULT_PANEL_SETUP);
	VUHDO_DEFAULT_PER_PANEL_SETUP = VUHDO_compressAndPackTable(VUHDO_DEFAULT_PER_PANEL_SETUP);

	VUHDO_fixHotSettings();
end



local VUHDO_DEFAULT_BUFF_CONFIG = {
  ["VERSION"] = 4,
	["SHOW"] = true,
	["COMPACT"] = true,
	["SHOW_LABEL"] = false,
	["BAR_COLORS_TEXT"] = true,
	["BAR_COLORS_BACKGROUND"] = true,
	["BAR_COLORS_IN_FIGHT"] = false,
	["HIDE_CHARGES"] = false,
	["REFRESH_SECS"] = 2,
	["POSITION"] = {
		["x"] = 130,
		["y"] = -130,
		["point"] = "TOPLEFT",
		["relativePoint"] = "TOPLEFT",
	},
	["SCALE"] = 1,
	["PANEL_MAX_BUFFS"] = 5,
	["PANEL_BG_COLOR"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0, ["O"] = 0.5,
		["useBackground"] = true,
	},
	["PANEL_BORDER_COLOR"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0, ["O"] = 0.5,
		["useBackground"] = true,
	},
	["SWATCH_BG_COLOR"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0, ["O"] = 1,
		["useBackground"] = true,
	},
	["SWATCH_BORDER_COLOR"] = {
		["R"] = 0.8, ["G"] = 0.8,	["B"] = 0.8, ["O"] = 0,
		["useBackground"] = true,
	},
	["REBUFF_AT_PERCENT"] = 25,
	["REBUFF_MIN_MINUTES"] = 3,
	["HIGHLIGHT_COOLDOWN"] = true,
	["WHEEL_SMART_BUFF"] = false,

	["SWATCH_COLOR_BUFF_OKAY"]     = VUHDO_makeFullColor(0,   0,   0,   1,   0,   0.8, 0,   1),
	["SWATCH_COLOR_BUFF_LOW"]      = VUHDO_makeFullColor(0,   0,   0,   1,   1,   0.7, 0,   1),
	["SWATCH_COLOR_BUFF_OUT"]      = VUHDO_makeFullColor(0,   0,   0,   1,   0.8, 0,   0,   1),
	["SWATCH_COLOR_BUFF_COOLDOWN"] = VUHDO_makeFullColor(0.3, 0.3, 0.3, 1,   0.6, 0.6, 0.6, 1),
}



VUHDO_DEFAULT_USER_CLASS_COLORS = {
	[VUHDO_ID_DRUIDS]        = VUHDO_makeFullColor(1,    0.49, 0.04, 1,   1,    0.6,  0.04, 1),
	[VUHDO_ID_HUNTERS]       = VUHDO_makeFullColor(0.67, 0.83, 0.45, 1,   0.77, 0.93, 0.55, 1),
	[VUHDO_ID_MAGES]         = VUHDO_makeFullColor(0.41, 0.8,  0.94, 1,   0.51, 0.9,  1,    1),
	[VUHDO_ID_PALADINS]      = VUHDO_makeFullColor(0.96, 0.55, 0.73, 1,   1,    0.65, 0.83, 1),
	[VUHDO_ID_PRIESTS]       = VUHDO_makeFullColor(0.9,  0.9,  0.9,  1,   1,    1,    1,    1),
	[VUHDO_ID_ROGUES]        = VUHDO_makeFullColor(1,    0.96, 0.41, 1,   1,    1,    0.51, 1),
	[VUHDO_ID_SHAMANS]       = VUHDO_makeFullColor(0.14, 0.35, 1,    1,   0.24, 0.45, 1,    1),
	[VUHDO_ID_WARLOCKS]      = VUHDO_makeFullColor(0.58, 0.51, 0.79, 1,   0.68, 0.61, 0.89, 1),
	[VUHDO_ID_WARRIORS]      = VUHDO_makeFullColor(0.78, 0.61, 0.43, 1,   0.88, 0.71, 0.53, 1),
	[VUHDO_ID_DEATH_KNIGHT]  = VUHDO_makeFullColor(0.77, 0.12, 0.23, 1,   0.87, 0.22, 0.33, 1),
	[VUHDO_ID_MONKS]         = VUHDO_makeFullColor(0,    1,    0.59, 1,   0,    1,    0.69, 1),
	[VUHDO_ID_DEMON_HUNTERS] = VUHDO_makeFullColor(0.54, 0.09, 0.69, 1,   0.64, 0.19, 0.79, 1),
	[VUHDO_ID_EVOKERS]       = VUHDO_makeFullColor(0.10, 0.48, 0.40, 1,   0.20, 0.58, 0.50, 1),
	[VUHDO_ID_PETS]          = VUHDO_makeFullColor(0.4,  0.6,  0.4,  1,   0.5,  0.9,  0.5,  1),
	["petClassColor"] = false,
}

-- Gradient Color "min":

-- DK: 0.498, 0.075, 0.149
-- DH: 0.365, 0.137, 0.573
-- DD: 1, 0.239, 0.008
-- EV: 0.196, 0.467, 0.537
-- HU: 0.404, 0.537, 0.224
-- MA: 0, 0.333, 0.537
-- MO: 0.016, 0.608, 0.369
-- PA: 1, 0.267, 0.537
-- PR: 0.357, 0.357, 0.357
-- SH: 0, 0.259, 0.51
-- WA: 0.263, 0.267, 0.467
-- WR: 0.427, 0.137, 0.09
-- RO: 1, 0.686, 0

-- Gradient Color 'max":

-- DK: 1, 0.184, 0.239
-- DH: 0.745, 0.192, 1
-- DD: 1, 0.486, 0.039
-- EV: 0.2, 0.576, 0.498
-- HU: 0.671, 0.929, 0.31
-- MA: 0.49, 0.871, 1
-- MO: 0, 1, 0.588
-- PA: 0.957, 0.549, 0.729
-- PR: 0.988, 0.988, 0.988
-- SH: 0, 0.439, 0.871
-- WA: 0.663, 0.392, 0.784
-- WR: 0.565, 0.431, 0.247
-- RO: 1, 0.831, 0.255

VUHDO_DEFAULT_USER_CLASS_GRADIENT_COLORS = {
	[VUHDO_ID_DRUIDS] = {
		["min"] = VUHDO_makeFullColor(1,    0.24, 0.01, 1,   1,    0.6,  0.04, 1),
		["max"] = VUHDO_makeFullColor(1,    0.49, 0.04, 1,   1,    0.6,  0.04, 1),
	},
	[VUHDO_ID_HUNTERS] = {
		["min"] = VUHDO_makeFullColor(0.40, 0.54, 0.22, 1,   0.77, 0.93, 0.55, 1),
		["max"] = VUHDO_makeFullColor(0.67, 0.93, 0.31, 1,   0.77, 0.93, 0.55, 1),
	},
	[VUHDO_ID_MAGES] = {
		["min"] = VUHDO_makeFullColor(0,    0.33, 0.54, 1,   0.51, 0.9,  1,    1),
		["max"] = VUHDO_makeFullColor(0.49, 0.87, 1,    1,   0.51, 0.9,  1,    1),
	},
	[VUHDO_ID_PALADINS] = {
		["min"] = VUHDO_makeFullColor(1,    0.28, 0.54, 1,   1,    0.65, 0.83, 1),
		["max"] = VUHDO_makeFullColor(0.96, 0.55, 0.73, 1,   1,    0.65, 0.83, 1),
	},
	[VUHDO_ID_PRIESTS] = {
		["min"] = VUHDO_makeFullColor(0.36, 0.36, 0.36, 1,   1,    1,    1,    1),
		["max"] = VUHDO_makeFullColor(0.99, 0.99, 0.99, 1,   1,    1,    1,    1),
	},
	[VUHDO_ID_ROGUES] = {
		["min"] = VUHDO_makeFullColor(1,    0.69, 0,    1,   1,    1,    0.51, 1),
		["max"] = VUHDO_makeFullColor(1,    0.83, 0.26, 1,   1,    1,    0.51, 1),
	},
	[VUHDO_ID_SHAMANS] = {
		["min"] = VUHDO_makeFullColor(0,    0.26, 0.51, 1,   0.24, 0.45, 1,    1),
		["max"] = VUHDO_makeFullColor(0,    0.44, 0.87, 1,   0.24, 0.45, 1,    1),
	},
	[VUHDO_ID_WARLOCKS] = {
		["min"] = VUHDO_makeFullColor(0.26, 0.27, 0.47, 1,   0.68, 0.61, 0.89, 1),
		["max"] = VUHDO_makeFullColor(0.66, 0.39, 0.78, 1,   0.68, 0.61, 0.89, 1),
	},
	[VUHDO_ID_WARRIORS] = {
		["min"] = VUHDO_makeFullColor(0.43, 0.14, 0.09, 1,   0.88, 0.71, 0.53, 1),
		["max"] = VUHDO_makeFullColor(0.57, 0.43, 0.25, 1,   0.88, 0.71, 0.53, 1),
	},
	[VUHDO_ID_DEATH_KNIGHT] = {
		["min"] = VUHDO_makeFullColor(0.5,  0.08, 0.15, 1,   0.87, 0.22, 0.33, 1),
		["max"] = VUHDO_makeFullColor(1,    0.18, 0.24, 1,   0.87, 0.22, 0.33, 1),
	},
	[VUHDO_ID_MONKS] = {
		["min"] = VUHDO_makeFullColor(0.02, 0.61, 0.37, 1,   0,    1,    0.69, 1),
		["max"] = VUHDO_makeFullColor(0,    1,    0.59, 1,   0,    1,    0.69, 1),
	},
	[VUHDO_ID_DEMON_HUNTERS] = {
		["min"] = VUHDO_makeFullColor(0.37, 0.14, 0.57, 1,   0.64, 0.19, 0.79, 1),
		["max"] = VUHDO_makeFullColor(0.75, 0.19, 1,    1,   0.64, 0.19, 0.79, 1),
	},
	[VUHDO_ID_EVOKERS] = {
		["min"] = VUHDO_makeFullColor(0.2,  0.47, 0.54, 1,   0.20, 0.58, 0.50, 1),
		["max"] = VUHDO_makeFullColor(0.2,  0.58, 0.5,  1,   0.20, 0.58, 0.50, 1),
	},
	[VUHDO_ID_PETS] = {
		["min"] = VUHDO_makeFullColor(0.4,  0.6,  0.4,  1,   0.5,  0.9,  0.5,  1),
		["max"] = VUHDO_makeFullColor(0.4,  0.6,  0.4,  1,   0.5,  0.9,  0.5,  1),
	},
	["isClassGradient"] = false,
};



--
function VUHDO_initClassColors()

	if not VUHDO_USER_CLASS_COLORS then
		VUHDO_USER_CLASS_COLORS = VUHDO_decompressOrCopy(VUHDO_DEFAULT_USER_CLASS_COLORS);
	end

	VUHDO_USER_CLASS_COLORS = VUHDO_ensureSanity("VUHDO_USER_CLASS_COLORS", VUHDO_USER_CLASS_COLORS, VUHDO_DEFAULT_USER_CLASS_COLORS);
	VUHDO_DEFAULT_USER_CLASS_COLORS = VUHDO_compressAndPackTable(VUHDO_DEFAULT_USER_CLASS_COLORS);

	if not VUHDO_USER_CLASS_GRADIENT_COLORS then
		VUHDO_USER_CLASS_GRADIENT_COLORS = VUHDO_decompressOrCopy(VUHDO_DEFAULT_USER_CLASS_GRADIENT_COLORS);
	end

	VUHDO_USER_CLASS_GRADIENT_COLORS = VUHDO_ensureSanity("VUHDO_USER_CLASS_GRADIENT_COLORS", VUHDO_USER_CLASS_GRADIENT_COLORS, VUHDO_DEFAULT_USER_CLASS_GRADIENT_COLORS);
	VUHDO_DEFAULT_USER_CLASS_GRADIENT_COLORS = VUHDO_compressAndPackTable(VUHDO_DEFAULT_USER_CLASS_GRADIENT_COLORS);

end



--
local function VUHDO_getFirstFreeBuffOrder()
	for tCnt = 1, 10000 do
		if not VUHDO_tableGetKeyFromValue(VUHDO_BUFF_ORDER, tCnt) then
			return tCnt;
		end
	end

	return nil;
end



--
local function VUHDO_fixBuffOrder()
	local _, tPlayerClass = UnitClass("player");
	local tAllBuffs = VUHDO_CLASS_BUFFS[tPlayerClass];
	local tSortArray = {};

	-- Order ohne buff?
	for tCategName, _ in pairs(VUHDO_BUFF_ORDER) do
		if not tAllBuffs[tCategName] then
			VUHDO_BUFF_ORDER[tCategName] = nil;
		end
	end

	-- Buffs ohne order?
	for tCategName, _ in pairs(tAllBuffs) do
		if not VUHDO_BUFF_ORDER[tCategName] then
			VUHDO_BUFF_ORDER[tCategName] = VUHDO_getFirstFreeBuffOrder();
		end

		tinsert(tSortArray, tCategName);
	end

	table.sort(tSortArray, function(aCateg, anotherCateg) return VUHDO_BUFF_ORDER[aCateg] < VUHDO_BUFF_ORDER[anotherCateg] end);
	table.wipe(VUHDO_BUFF_ORDER);
	for tIndex, tCateg in ipairs(tSortArray) do
		VUHDO_BUFF_ORDER[tCateg] = tIndex;
	end

end



--
function VUHDO_initBuffSettings()
	if not VUHDO_BUFF_SETTINGS["CONFIG"] then
		VUHDO_BUFF_SETTINGS["CONFIG"] = VUHDO_decompressOrCopy(VUHDO_DEFAULT_BUFF_CONFIG);
	end

	VUHDO_BUFF_SETTINGS["CONFIG"] = VUHDO_ensureSanity("VUHDO_BUFF_SETTINGS.CONFIG", VUHDO_BUFF_SETTINGS["CONFIG"], VUHDO_DEFAULT_BUFF_CONFIG);
	VUHDO_DEFAULT_BUFF_CONFIG = VUHDO_compressAndPackTable(VUHDO_DEFAULT_BUFF_CONFIG);

	local _, tPlayerClass = UnitClass("player");
	for tCategSpec, _ in pairs(VUHDO_CLASS_BUFFS[tPlayerClass]) do

		if not VUHDO_BUFF_SETTINGS[tCategSpec] then
			VUHDO_BUFF_SETTINGS[tCategSpec] = {
				["enabled"] = false,
				["missingColor"] = {
					["show"] = false,
					["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 1,
					["TR"] = 1, ["TG"] = 1, ["TB"] = 1, ["TO"] = 1,
					["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
				}
			};
		end

		if not VUHDO_BUFF_SETTINGS[tCategSpec]["filter"] then
			VUHDO_BUFF_SETTINGS[tCategSpec]["filter"] = { [VUHDO_ID_ALL] = true };
		end
	end

	VUHDO_fixBuffOrder();
end
