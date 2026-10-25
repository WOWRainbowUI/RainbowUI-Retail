VUHDO_AURA_IGNORE_LIST_DEFAULTS = {
	[57724] = true, -- Sated (Bloodlust)
	[57723] = true, -- Exhaustion (Heroism)
	[80354] = true, -- Temporal Displacement (Time Warp)
	[264689] = true, -- Fatigued (Primal Fury)
	[26013] = true, -- Deserter (LFG penalty)
	[71041] = true, -- Dungeon Deserter
	[1313593] = true, -- Deserter (Midnight)
	[95809] = true, -- Insanity (Drums variant)
	[160455] = true, -- Fatigued (Drums of Fury)
	[390435] = true, -- Exhaustion (alternate)
	[206151] = true, -- Challenger's Burden
	[308312] = true, -- Time Trial Practice
	[1254550] = true, -- Arcane Empowerment
	[1227806] = true, -- Lifebloom (hidden player aura)
	[404464] = true, -- Flight Style: Skyriding
	[404468] = true, -- Flight Style: Steady
	[418590] = true, -- Static Charge (Skyriding)
	[377234] = true, -- Thrill of the Skies (Skyriding)
	[369968] = true, -- Racing (Dragonriding)
	[447959] = true, -- Ride Along - Enabled (Skyriding)
	[447960] = true, -- Ride Along - Inactive (Skyriding)
	[427490] = true, -- Ride Along (Skyriding vehicle)
	[388367] = true, -- Ohn'ahra's Gusts (Dragonriding)
};



VUHDO_DEFAULT_RANGE_SPELLS = {
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
		["HELPFUL"] = { },
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
		["HELPFUL"] = { VUHDO_SPELL_ID.LIVING_FLAME, VUHDO_SPELL_ID.EMERALD_BLOSSOM },
		["HARMFUL"] = { VUHDO_SPELL_ID.AZURE_STRIKE, VUHDO_SPELL_ID.LIVING_FLAME },
	},
};



VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT = {
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



VUHDO_DEFAULT_AURA_GROUPS_FLAVOR_ENTRIES = {
	["PRESERVATION_EVOKER_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 355941, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 363502, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 364343, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 366155, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 373267, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 409895, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 444490, ["mine"] = true, ["others"] = false },
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
	["AUGMENTATION_EVOKER_BUFFS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 360827, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 395152, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 410089, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 410263, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 410686, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 413984, ["mine"] = true, ["others"] = false },
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
	["RESTORATION_DRUID_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 774, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 8936, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 33763, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 48438, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 155777, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 439530, ["mine"] = true, ["others"] = false },
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
			{ ["entryType"] = 1, ["value"] = 17, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 194384, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1253593, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 41635, ["mine"] = true, ["others"] = false },
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
			{ ["entryType"] = 1, ["value"] = 139, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 41635, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 77489, ["mine"] = true, ["others"] = false },
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
	["MISTWEAVER_MONK_HOTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 115175, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 119611, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 124682, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 450769, ["mine"] = true, ["others"] = false },
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
			{ ["entryType"] = 1, ["value"] = 974, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 61295, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 207400, ["mine"] = true, ["others"] = false },
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
			{ ["entryType"] = 1, ["value"] = 53563, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 156322, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 156910, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 200025, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1244893, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 431381, ["mine"] = true, ["others"] = false },
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
			{ ["entryType"] = 1, ["value"] = 1126, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1459, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 6673, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 21562, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 369459, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 462854, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 474750, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
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
	["BLESSING_OF_BRONZE"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 381732, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
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
	["ROGUE_POISONS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 2823, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 8679, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 3408, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 5761, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 315584, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 381637, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 381664, ["mine"] = true, ["others"] = false },
		},
		["displayName"] = nil,
		["enabled"] = true,
		["priority"] = 50,
		["colorType"] = VUHDO_AURA_GROUP_COLOR_OFF,
		["canColorBar"] = false,
		["canColorText"] = false,
		["canGlowBar"] = false,
		["glowBarColor"] = nil,
		["unitScope"] = VUHDO_AURA_GROUP_UNIT_SCOPE_HOSTILE,
		["ignoreList"] = { },
		["sound"] = nil,
	},
	["SHAMAN_WEAPON_IMBUEMENTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 319773, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 319778, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 382021, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 457481, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 462742, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
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
	["PALADIN_WEAPON_IMBUEMENTS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 433550, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 433583, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
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
	["ENHANCEMENT_SHAMAN_BUFFS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 344179, ["mine"] = true, ["others"] = false },
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
	["BREWMASTER_MONK_BUFFS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 124255, ["mine"] = true, ["others"] = false },
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
	["FERAL_DRUID_BUFFS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 405189, ["mine"] = true, ["others"] = false },
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
	["WARLOCK_METAMORPHOSIS"] = {
		["type"] = 2,
		["entries"] = {
			{ ["entryType"] = 1, ["value"] = 1217607, ["isNameMatch"] = true, ["mine"] = true, ["others"] = false },
			{ ["entryType"] = 1, ["value"] = 1227702, ["mine"] = true, ["others"] = false },
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
};



--
function VUHDO_registerFlavorCustomDebuffDefaults(aAddCustomSpellIds)

	aAddCustomSpellIds(54, {
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
	aAddCustomSpellIds(55, {
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

		-- 11.2.0 The War Within Ghosts of K'aresh
	aAddCustomSpellIds(56, {
			-- Plexus Sentinel
			[1219459] = false,  -- Manifest Matrices (magic)
			[1218626] = false,  -- Displacement Matrix (magic)
			--[1219531] = false,  -- Eradicating Salvo (magic)
			[1219354] = false,  -- Potent Mana Residue (magic)
			--[1219248] = false,  -- Arcane Radiation (magic)
			--[1233110] = false,  -- Purging Lightning (magic)
			-- Loom'ithar
			[1226311] = false,  -- Infusion Tether (magic)
			[1226721] = false,  -- Silken Snare (magic)
			[1227784] = false,  -- Arcane Outrage (magic)
			[1226395] = false,  -- Overinfusion Burst (magic)
			--[1243771] = false,  -- Arcane Ichor (magic)
			[1226366] = false,  -- Living Silk (nature)
			-- Soulbinder Naazindhri
			[1226827] = false,  -- Soulrend Orb (magic)
			[1227048] = false,  -- Voidblade Ambush (shadow)
			[1227052] = true,   -- Void Burst (shadow)
			[1252952] = true,   -- Void Burst (shadow)
			[1225616] = false,  -- Soulfire Convergence (magic)
			[1227276] = false,  -- Soulfray Annihilation (magic)
			[1249065] = false,  -- Soulfire Convergence (magic)
			--[1237607] = false,  -- Mystic Lash (magic)
			--[1242088] = false,  -- Arcane Expulsion (magic)
			--[1242084] = true,   -- Arcane Energy (magic)
			--[1242086] = true,   -- Arcane Energy (magic)
			--[1250008] = false,  -- Shatterpulse (magic)
			-- Forgeweaver Araz
			[1228214] = false,  -- Astral Harvest (magic)
			[1228188] = false,  -- Silencing Tempest (magic)
			[245075] = false,   -- Hungering Gloom (shadow)
			--[1243901] = false,  -- Void Harvest (shadow)
			--[1234324] = false,  -- Photon Blast (magic)
			--[1232412] = true,   -- Focusing Iris (magic)
			--[1250185] = true,   -- Focusing Iris (magic)
			--[1232411] = true,   -- Focusing Iris (magic)
			--[1240705] = false,  -- Astral Burn (magic)
			--[1233076] = false,  -- Dark Singularity (shadow)
			-- The Soul Hunters
			[1234565] = true,   -- Consume (cosmic)
			[1222307] = true,   -- Consume (cosmic)
			[1235158] = true,   -- Consume (cosmic)
			--[1225127] = true,   -- Felblade (fire)
			--[1225130] = true,   -- Felblade (fire)
			--[1241917] = true,   -- Frailty (chaos)
			--[1241946] = true,   -- Frailty (chaos)
			--[1254762] = true,   -- Frailty (chaos)
			--[1233968] = true,   -- Event Horizon (cosmic)
			--[1235045] = false,  -- Encroaching Oblivion (cosmic)
			--[1242284] = true,   -- Soulcrush (cosmic)
			--[1233105] = false,  -- Dark Residue (cosmic)
			--[1223725] = true,   -- Fel Inferno (fire)
			--[1245384] = true,   -- Fel Inferno (fire)
			--[1239269] = true,   -- Fel Inferno (fire)
			--[1228238] = true,   -- Fel Inferno (fire)
			-- Fractilus
			[1224414] = false,  -- Crystalline Shockwave (shadow)
			[1227373] = false,  -- Shattershell (shadow)
			[1247424] = false,  -- Null Consumption (shadow)
			--[1250600] = true,   -- Void Lightning (shadow)
			--[1241137] = false,  -- Refracted Entropy (shadow)
			-- Nexus-King Salhadaar
			[1227529] = true,   -- Banishment (shadow)
			[1227549] = true,   -- Banishment (shadow)
			[1227562] = true,   -- Banishment (shadow)
			[1227554] = true,   -- Banishment (shadow)
			--[1224787] = false,  -- Conquer (shadow)
			--[1224737] = false,  -- Oath-Bound (shadow)
			--[1228196] = false,  -- Dimension Breath (cosmic)
			--[1226362] = false,  -- Twilight Scar (cosmic)
			--[1231097] = false,  -- Cosmic Rip (cosmic)
			--[1225444] = false,  -- Atomized (cosmic)
			--[1227330] = true,   -- Besiege (cosmic)
			--[1227472] = true,   -- Besiege (cosmic)
			--[1227331] = true,   -- Besiege (cosmic)
			--[1227384] = true,   -- Besiege (cosmic)
			--[1227470] = true,   -- Besiege (cosmic)
			--[1247194] = true,   -- Besiege (cosmic)
			--[1237120] = true,   -- Besiege (cosmic)
			--[1228081] = false,  -- Nexus Beams (shadow)
			[1228053] = true,   -- Reap (shadow)
			[1228056] = true,   -- Reap (shadow)
			-- Dimensius
			--[1243699] = false,  -- Spatial Fragment (cosmic)
			[1231002] = false,  -- Dark Energy (cosmic)
			--[1237097] = false,  -- Astrophysical Jet (cosmic)
			--[1238765] = true,   -- Extinction (cosmic)
			--[1238773] = true,   -- Extinction (cosmic)
			--[1239270] = false,  -- Voidwarding (shadow)
			--[1237325] = false,  -- Gamma Burst (cosmic)
			--[1246145] = false,  -- Touch of Oblivion (shadow)
			[1246542] = false,  -- Null Binding (shadow)
			--[1237696] = false,  -- Debris Field (cosmic)
			[1234054] = false,  -- Shadowquake (shadow)
			[1232394] = true,   -- Gravity Well (shadow)
			--[1250055] = false,  -- Voidgrasp (cosmic)
		} );

		-- 11.2.0 The War Within Season 3 dungeons
	aAddCustomSpellIds(57, {
			-- Ara-Kara, City of Echoes
			--[438599] = false,  -- Bleeding Jab (bleed)
			--[1241785] = true,  -- Tainted Blood (magic, stacking tank debuff)
			--[436614] = true,   -- Web Wrap (magic)
			--[219861] = true,   -- Web Wrap (magic)
			[461487] = false,  -- Cultivated Poisons (poison, via Ki'katal)
			--[461507] = false,  -- Cultivated Poisons (poison, dot version)
			[436322] = true,   -- Poison Bolt (poison, interruptible)
			--[448248] = false,  -- Revolting Volley (poison, interruptible)
			[433841] = true,   -- Venom Volley (poison, interruptible)
			[432227] = true,   -- Venom Volley (poison, interruptible)
			[438618] = true,   -- Venomous Spit (poison)
			-- Eco-Dome Al'dani
			--[1219535] = false, -- Rift Claws (bleed, tank debuff)
			--[1221133] = true,  -- Hungering Rage (enrage)
			[1221483] = true,  -- Arcing Energy (magic)
			[1221484] = true,  -- Arcing Energy (magic)
			[1221485] = true,  -- Arcing Energy (magic)
			[1221615] = true,  -- Arcing Energy (magic)
			--[1231608] = true,  -- Alacrity (purge)
			--[1223000] = false, -- Embrace of K'aresh (purge)
			-- Halls of Atonement
			--[1235245] = true,  -- Ankle Bite (bleed, stacking)
			[1237602] = true,  -- Gushing Wound (bleed, stacking tank debuff)
			--[326450] = false,  -- Loyal Beasts (enrage, interruptible)
			--[1235060] = false, -- Anima Tainted Armor (magic, stacking tank debuff)
			--[325876] = false,  -- Mark of Obliteration (magic)
			[339237] = false,  -- Sinlight Visions (magic)
			[325701] = true,   -- Siphon Life (magic, interruptible)
			[1235762] = true,  -- Turn to Stone (magic)
			[1236513] = true,  -- Unstable Anima (magic, spread mechanic)
			[1236514] = true,  -- Unstable Anima (magic, spread mechanic)
			[1236512] = true,  -- Unstable Anima (magic, spread mechanic)
			-- Operation: Floodgate
			[468631] = true,   -- Harpoon (bleed, interruptible)
			--[1213803] = false, -- Nailed (bleed, roots)
			--[463061] = false,  -- Bloodthirsty Cackle (enrage, interruptible)
			--[462737] = false,  -- Black Blood Wound (magic, stacking tank debuff)
			--[473713] = false,  -- Kinetic Explosive Gel (magic)
			[469799] = true,   -- Overcharge (magic, stuns if not dispelled)
			--[465813] = false,  -- Lethargic Venom (poison)
			--[471733] = false,  -- Restorative Algae (purge, interruptible)
			-- Priory of the Sacred Flame
			--[453461] = true,   -- Caltrops (bleed, avoidable)
			--[453458] = true,   -- Caltrops (bleed, avoidable)
			[427635] = true,   -- Grievous Rip (bleed)
			[446779] = true,   -- Grievous Rip (bleed)
			[427621] = true,   -- Impale (bleed)
			--[424426] = false,  -- Lunging Strike (bleed, avoidable)
			[424414] = true,   -- Pierce Armor (bleed)
			--[424419] = true,   -- Battle Cry (enrage, interruptible)
			[435148] = true,   -- Blazing Strike (magic, tankbuster)
			[435165] = true,   -- Blazing Strike (magic, tankbuster)
			[435166] = true,   -- Blazing Strike (magic, tankbuster) --noid
			[428170] = true,   -- Blinding Light (magic)
			[428169] = true,   -- Blinding Light (magic)
			[448515] = false,  -- Divine Judgment (magic, tankbuster)
			[427897] = true,   -- Heat Wave (magic)
			--[451606] = false,  -- Holy Flame (magic)
			[427583] = true,   -- Repentance (magic, interruptible)
			--[427342] = false,  -- Defend (purge)
			--[427346] = true,   -- Inner Fire (purge, stuns on removal)
			--[427347] = true,   -- Inner Fire (purge, stuns on removal)
			--[429103] = true,   -- Inner Fire (purge, stuns on removal)
			--[429104] = true,   -- Inner Fire (purge, stuns on removal)
			--[428916] = true,   -- Inner Fire (purge, stuns on removal)
			--[429091] = true,   -- Inner Fire (purge, stuns on removal)
			--[444728] = false,  -- Templar's Wrath (purge)
			-- Tazavesh: So'leah's Gambit
			[351119] = true,   -- Shuriken Blitz (bleed, interruptible)
			[351120] = true,   -- Shuriken Blitz (bleed, interruptible)
			[351121] = true,   -- Shuriken Blitz (bleed, interruptible)
			[351122] = true,   -- Shuriken Blitz (bleed, interruptible)
			--[355057] = false,  -- Cry of Mrrggllrrgg (enrage)
			--[356133] = false,  -- Super Saison (enrage)
			[1240097] = true,  -- Time Bomb (magic, spread mechanic)
			[1240099] = true,  -- Time Bomb (magic, spread mechanic)
			[1240102] = true,  -- Time Bomb (magic, spread mechanic)
			--[1240214] = false, -- Double Time (purge)
			-- Tazavesh: Streets of Wonder
			--[350101] = false,  -- Chains of Damnation (bleed)
			--[357827] = false,  -- Frantic Rip (bleed)
			[347716] = false,  -- Letter Opener (bleed, tankbuster)
			--[1248211] = false, -- Phase Slash (bleed, party wide)
			--[355832] = false,  -- Quickblade (bleed)
			--[356407] = false,  -- Ancient Dread (curse)
			--[353706] = true,   -- Rowdy (enrage)
			--[1244446] = false, -- Force Multiplier (enrage)
			--[346844] = false,  -- Alchemical Residue (magic)
			--[356324] = false,  -- Empowered Glyph of Restraint (magic)
			--[355915] = false,  -- Glyph of Restraint (magic)
			[355934] = true,   -- Hard Light Barrier (magic)
			--[355888] = true,   -- Hard Light Baton (magic)
			[355889] = true,   -- Hard Light Baton (magic)
			--[357029] = false,  -- Hyperlight Bomb (magic)
			[356943] = true,   -- Lockdown (magic)
			[356942] = true,   -- Lockdown (magic)
			[349954] = false,  -- Purification Protocol (magic)
			--[355641] = false,  -- Scintillate (magic)
			--[351960] = true,   -- Static Cling (magic)
			--[349933] = false,  -- Flagellation Protocol (purge)
			--[355980] = false,  -- Refraction Shield (purge)
			--[347775] = false,  -- Spam Filter (purge)
			-- The Dawnbreaker
			--[431491] = false,  -- Tainted Slash (bleed)
			--[431309] = false,  -- Ensnaring Shadows (curse)
			--[1242074] = false, -- Intensifying Aggression (enrage, stacks)
			--[451112] = false,  -- Tactician's Rage (enrage)
			[426735] = true,   -- Burning Shadows (magic)
			[426734] = true,   -- Burning Shadows (magic)
			[432448] = false,  -- Stygian Seed (magic)
			--[450756] = false,  -- Abyssal Howl (purge)
		} );

	return;

end



VUHDO_FLAVOR_DEFAULT_SPELL_TRACE_IDS = {
	1064,
	34861,
	596,
	194509,
};
