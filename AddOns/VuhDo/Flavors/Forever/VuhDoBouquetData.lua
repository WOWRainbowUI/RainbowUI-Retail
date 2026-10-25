local GetSpellName = C_Spell.GetSpellName;

VUHDO_DEFAULT_TANKS_CDS_EXTD_BOUQUET = {
	[VUHDO_I18N_DEF_TANK_CDS_EXTENDED] = {
	},
};



VUHDO_DEFAULT_RAID_CDS_BOUQUET = {
	[VUHDO_I18N_DEF_RAID_CDS] = {
	},
};



VUHDO_DEFAULT_PVP_FLAGS_BOUQUET = {
	[VUHDO_I18N_DEF_PVP_FLAGS] = {
	},
};



VUHDO_DEFAULT_TANK_CDS_EXTENDED_SPELLS = {
	871, -- Shield Wall
	12975, -- Last Stand
	2565, -- Shield Block
	642, -- Divine Shield
	498, -- Divine Protection
	22812, -- Barkskin
	22842, -- Frenzied Regeneration
};



VUHDO_DEFAULT_RAID_CDS_SPELLS = {
	1022, -- Blessing of Protection
	6940, -- Blessing of Sacrifice
	1044, -- Blessing of Freedom
	642, -- Divine Shield
	10060, -- Power Infusion
	29166, -- Innervate
	6346, -- Fear Ward
	20707, -- Soulstone Resurrection
};



VUHDO_DEFAULT_PVP_FLAGS_SPELLS = {
	23333, -- Warsong Flag
	23335, -- Silverwing Flag
};



VUHDO_DEFAULT_PW_S_WEAKENED_SOUL_ICONS_BOUQUET = {
	[VUHDO_I18N_DEF_BOUQUET_PW_S_WEAKENED_SOUL_ICONS] = {
		{
			["name"] = GetSpellName(17), -- Power Word: Shield
			["mine"] = true, ["icon"] = 1,
			["color"] = VUHDO_makeFullColorForBouquet(1, 1, 1, 1,   1, 1, 1, 1),
			["custom"] = { [1] = 1, ["radio"] = 1, ["bright"] = 1.0 },
		},
		{
			["name"] = "AURA_GROUP_ACTIVE",
			["mine"] = true, ["others"] = true, ["icon"] = 1,
			["color"] = VUHDO_makeFullColorForBouquet(1, 1, 1, 1,   1, 1, 1, 1),
			["custom"] = { [1] = 1, ["radio"] = 1, ["bright"] = 1.0, ["auraGroupId"] = "PRIEST_WEAKENED_SOUL" },
		},
	},
};



VUHDO_DEFAULT_BOUQUET_ITEM_REPLACEMENTS = {
	[VUHDO_I18N_DEF_BOUQUET_PW_S_WEAKENED_SOUL] = {
		{
			["fromName"] = GetSpellName(6788), -- Weakened Soul
			["item"] = {
				["name"] = "AURA_GROUP_ACTIVE",
				["mine"] = true,
				["others"] = true,
				["icon"] = 9,
				["color"] = VUHDO_makeFullColorForBouquet(1, 0.623, 0.305, 1, 1, 1, 1, 1),
				["custom"] = {
					[1] = 1,
					["radio"] = 1,
					["bright"] = 1.0,
					["auraGroupId"] = "PRIEST_WEAKENED_SOUL",
				},
			},
		},
	},
};