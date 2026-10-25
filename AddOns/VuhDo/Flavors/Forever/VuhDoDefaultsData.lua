VUHDO_AURA_IGNORE_LIST_DEFAULTS = {
	[26013] = true, -- Deserter
	[2479] = true, -- Honorless Target
	[11196] = true, -- Recently Bandaged
	[15007] = true, -- Resurrection Sickness
};



VUHDO_DEFAULT_RANGE_SPELLS = {
	["WARRIOR"] = {
		["HELPFUL"] = { },
		["HARMFUL"] = { VUHDO_SPELL_ID.TAUNT },
	},
	["ROGUE"] = {
		["HELPFUL"] = { },
		["HARMFUL"] = { VUHDO_SPELL_ID.SINISTER_STRIKE },
	},
	["HUNTER"] = {
		["HELPFUL"] = { },
		["HARMFUL"] = { VUHDO_SPELL_ID.ARCANE_SHOT },
	},
	["PALADIN"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.FLASH_OF_LIGHT, VUHDO_SPELL_ID.HOLY_LIGHT },
		["HARMFUL"] = { VUHDO_SPELL_ID.HAMMER_OF_JUSTICE },
	},
	["MAGE"] = {
		["HELPFUL"] = { VUHDO_SPELL_ID.BUFF_ARCANE_INTELLECT },
		["HARMFUL"] = { 116, 133 }, -- VUHDO_SPELL_ID.FROSTBOLT, VUHDO_SPELL_ID.FIREBALL
	},
	["WARLOCK"] = {
		["HELPFUL"] = { },
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
		["HELPFUL"] = { },
		["HARMFUL"] = { },
	},
	["MONK"] = {
		["HELPFUL"] = { },
		["HARMFUL"] = { },
	},
	["DEMONHUNTER"] = {
		["HELPFUL"] = { },
		["HARMFUL"] = { },
	},
	["EVOKER"] = {
		["HELPFUL"] = { },
		["HARMFUL"] = { },
	},
};



VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT = {
	["PALADIN"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.FLASH_OF_LIGHT },
		["2"] = { "", "2", VUHDO_SPELL_ID.HOLY_LIGHT },
		["3"] = { "", "3", "dropdown" },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.LAY_ON_HANDS },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.BLESSING_OF_PROTECTION },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.PALA_CLEANSE },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.PURIFY },
		["shift3"] = { "shift-", "3", "menu" },
	},

	["SHAMAN"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.HEALING_WAVE },
		["2"] = { "", "2", VUHDO_SPELL_ID.LESSER_HEALING_WAVE },
		["3"] = { "", "3", "dropdown" },
		["4"] = { "", "4", VUHDO_SPELL_ID.CHAIN_HEAL },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.ANCESTRAL_SPIRIT },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.CURE_POISON_SHAMAN },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.CURE_POISON_SHAMAN },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.CURE_DISEASE_SHAMAN },
		["shift3"] = { "shift-", "3", "menu" },
	},

	["PRIEST"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.FLASH_HEAL },
		["2"] = { "", "2", VUHDO_SPELL_ID.RENEW },
		["3"] = { "", "3", "dropdown" },
		["4"] = { "", "4", VUHDO_SPELL_ID.GREATER_HEAL },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.PRAYER_OF_HEALING },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.DISPEL_MAGIC },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.POWERWORD_SHIELD },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.CURE_DISEASE_PRIEST },
		["shift3"] = { "shift-", "3", "menu" },
	},

	["DRUID"] = {
		["1"] = { "", "1", VUHDO_SPELL_ID.HEALING_TOUCH },
		["2"] = { "", "2", VUHDO_SPELL_ID.REJUVENATION },
		["3"] = { "", "3", "dropdown" },
		["4"] = { "", "4", VUHDO_SPELL_ID.REGROWTH },

		["alt1"] = { "alt-", "1", "target" },
		["alt2"] = { "alt-", "2", "focus" },
		["alt3"] = { "alt-", "3", "menu" },

		["ctrl1"] = { "ctrl-", "1", VUHDO_SPELL_ID.INNERVATE },
		["ctrl2"] = { "ctrl-", "2", VUHDO_SPELL_ID.REMOVE_CURSE },
		["ctrl3"] = { "ctrl-", "3", "menu" },

		["shift1"] = { "shift-", "1", VUHDO_SPELL_ID.CURE_POISON_DRUID },
		["shift2"] = { "shift-", "2", VUHDO_SPELL_ID.ABOLISH_POISON },
		["shift3"] = { "shift-", "3", "menu" },
	},
};



VUHDO_DEFAULT_AURA_GROUPS_FLAVOR_ENTRIES = {
	["RESTORATION_DRUID_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 774, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 8936, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 408120, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
		},
		["displayName"] = nil,
		["enabled"] = true,
		["priority"] = 50,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["ignoreList"] = { },
		["sound"] = nil,
	},
	["DISCIPLINE_PRIEST_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 139, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 17, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
		},
		["displayName"] = nil,
		["enabled"] = true,
		["priority"] = 50,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["ignoreList"] = { },
		["sound"] = nil,
	},
	["HOLY_PRIEST_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 139, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 17, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 401859, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
		},
		["displayName"] = nil,
		["enabled"] = true,
		["priority"] = 50,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["ignoreList"] = { },
		["sound"] = nil,
	},
	["RESTORATION_SHAMAN_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 408514, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 22419, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
		},
		["displayName"] = nil,
		["enabled"] = true,
		["priority"] = 50,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["ignoreList"] = { },
		["sound"] = nil,
	},
	["HOLY_PALADIN_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 1022, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 6940, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1044, ["mine"] = true, ["others"] = false },
		},
		["displayName"] = nil,
		["enabled"] = true,
		["priority"] = 50,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["ignoreList"] = { },
		["sound"] = nil,
	},
	["RAID_BUFFS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 1243, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 21562, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 14752, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 27681, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 976, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 27683, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1126, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 21849, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 467, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1459, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 23028, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 19740, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 19742, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 20217, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 19977, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1038, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 25898, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 25894, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 25782, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 25890, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 25895, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 6673, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
		},
		["displayName"] = nil,
		["enabled"] = true,
		["priority"] = 50,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["ignoreList"] = { },
		["sound"] = nil,
	},
	["MY_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 774, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 8936, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 408120, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 139, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 17, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 401859, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 408514, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 22419, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1022, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 6940, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1044, ["mine"] = true, ["others"] = false },
		},
		["displayName"] = nil,
		["enabled"] = true,
		["priority"] = 10,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["ignoreList"] = { },
		["sound"] = nil,
	},
	["ALL_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 774, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 8936, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 408120, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 139, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 17, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 401859, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 408514, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 22419, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 1022, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 6940, ["isNameMatch"] = true, ["mine"] = true, ["others"] = true },
			{ ["entryType"] = 1, ["value"] = 1044, ["mine"] = true, ["others"] = true },
		},
		["displayName"] = nil,
		["enabled"] = true,
		["priority"] = 12,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["ignoreList"] = { },
		["sound"] = nil,
	},
	["PRIEST_WEAKENED_SOUL"] = {
		["type"] = 1,
		["filter"] = "HARMFUL",
		["excludeFilter"] = nil,
		["matchAnyBooleans"] = {
			["isFromPlayerOrPlayerPet"] = 1,
			["canApplyAura"] = 1,
		},
		["maxDurationSeconds"] = 15,
		["priority"] = 50,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["enabled"] = true,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_FRIENDLY,
		["ignoreList"] = { },
		["sound"] = nil,
	},
};