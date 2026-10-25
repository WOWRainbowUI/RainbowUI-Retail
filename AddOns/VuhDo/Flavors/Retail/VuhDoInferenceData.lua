VUHDO_INFERRED_AURA_SYNTHETIC_IDS = {
	["SHAMAN_RIPTIDE"] = -1001, --noid
	["EVOKER_ECHO"] = -1002, --noid
	["PRIEST_ATONEMENT"] = -1003, --noid
};

VUHDO_AURA_INFERENCE_CONFIG = {
	["SHAMAN_RIPTIDE"] = {
		["spellId"] = 61295,
		["maxAuras"] = 2,
		["sortRule"] = Enum.UnitAuraSortRule.ExpirationOnly,
		["includeSpellIds"] = { },
		["excludeSpellIds"] = { },
		["empoweredSpellIds"] = { },
		["hasExcludeUnit"] = true,
		["specRequired"] = nil,
	},
	["EVOKER_ECHO"] = {
		["spellId"] = 364343,
		["maxAuras"] = 3,
		["sortRule"] = Enum.UnitAuraSortRule.NameOnly,
		["includeSpellIds"] = {
			[366155] = true,
			[357170] = true,
			[360995] = true,
		},
		["excludeSpellIds"] = {
			[366155] = true,
			[357170] = true,
			[360995] = true,
		},
		["empoweredSpellIds"] = {
			[355936] = true,
			[382614] = true,
		},
		["hasExcludeUnit"] = false,
		["specRequired"] = nil,
	},
	["PRIEST_ATONEMENT"] = {
		["spellId"] = 194384,
		["maxAuras"] = 1,
		["sortRule"] = Enum.UnitAuraSortRule.NameOnly,
		["includeSpellIds"] = {
			[17] = true,
			[2061] = true,
			[47540] = true,
			[194509] = true,
			[200829] = true,
		},
		["excludeSpellIds"] = { },
		["empoweredSpellIds"] = { },
		["hasExcludeUnit"] = false,
		["specRequired"] = 1,
	},
};

VUHDO_AURA_INFERENCE_STATE = {
	["SHAMAN_RIPTIDE"] = {
		["activeAuras"] = { },
		["filteredAuras"] = { },
		["lastCastTime"] = nil,
		["excludeUnit"] = {
			["unit"] = nil,
			["auraInstanceID"] = nil,
		},
		["empoweredPending"] = false,
	},
	["EVOKER_ECHO"] = {
		["activeAuras"] = { },
		["filteredAuras"] = { },
		["lastCastTime"] = nil,
		["excludeUnit"] = {
			["unit"] = nil,
			["auraInstanceID"] = nil,
		},
		["empoweredPending"] = false,
	},
	["PRIEST_ATONEMENT"] = {
		["activeAuras"] = { },
		["filteredAuras"] = { },
		["lastCastTime"] = nil,
		["excludeUnit"] = {
			["unit"] = nil,
			["auraInstanceID"] = nil,
		},
		["empoweredPending"] = false,
	},
};
