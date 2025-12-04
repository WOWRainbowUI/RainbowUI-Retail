local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable

local PLACEHOLDER = "[PH]"

-- icon file IDs for WQ Locations 
DR.ZoneIcons = {
	-- The War Within
	[2248] = 5770811, -- Isle of Dorn
	[2214] = 5770812, -- The Ringing Deeps
	[2215] = 5770810, -- Hallowfall
	[2255] = 5770809, -- Azj-Kahet
	[2346] = 6392630, -- Undermine
	[2371] = 6921878, -- K'aresh

	-- Dragonflight
	[2022] = 4672500, --  Waking Shores
	[2023] = 4672498, -- Ohn'ahran Plains
	[2024] = 4672495, -- The Azure Span
	[2025] = 4672499, -- Thaldraszus
	[2151] = 4672496, -- Forbidden Reach
	[2133] = 5140838, -- Zaralek Caverns
	[2200] = 5390645, -- Emerald Dream

};

DR.WorldQuestIDs = {
--The War Within
	-- Isle of Dorn
	81806, 81799, 81805,
	81804, 81803, 81802,

	-- The Ringing Deeps
	81808, 81810, 81813,
	81807, 81812, 81811,

	-- Hallowfall
	81815, 81822, 81819,
	81818, 81816, 81823,

	-- Azj-Kahet
	81827, 81825, 81831,
	81824, 81829, 81828,

	-- Undermine
	85104, 85928, 85925,
	85926, 85927, 85105,
	85106, 85107,

	-- K'aresh
	-- currently unknown


--Dragonflight
	-- The Waking Shores
	70415, 70410, 70416,
	70382, 70412, 70417,
	70413, 70418,

	-- Ohn'ahran Plains
	70420, 70424, 70712,
	70421, 70423, 70422,
	70419,

	-- The Azure Span
	70425, 70430, 70429,
	70427, 70426, 70428,

	-- Thaldraszus
	70436, 70432, 70431,
	70435, 70434, 70433,

	-- The Forbidden Reach
	73083, 73084, 73078,
	73079, 73080, 73082,

	-- Zaralek Cavern
	75122, 75119, 75123,
	75121, 75120, 75124,

	-- Emerald Dream
	78434, 78438, 78435,
	78437, 78436, 78439,
};

DR.RaceData = {
	{ -- Isle of Dorn
		zone = 2248,
		expansion = 10,
		races = {
			[1] = { -- Dornogal Drift
				["normal"] = {
					["currencyID"] = 2923,
					["silverTime"] = 53,
					["goldTime"] = 48,
				},
				["advanced"] = {
					["currencyID"] = 2929,
					["silverTime"] = 46,
					["goldTime"] = 43,
				},
				["reverse"] = {
					["currencyID"] = 2935,
					["silverTime"] = 46,
					["goldTime"] = 43,
				},
				["questID"] = 80219,
				["mapPOI"] = 7793,
			},
			[2] = { -- Storm's Watch Survey
				["normal"] = {
					["currencyID"] = 2924,
					["silverTime"] = 68,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2930,
					["silverTime"] = 63,
					["goldTime"] = 60,
				},
				["reverse"] = {
					["currencyID"] = 2936,
					["silverTime"] = 65,
					["goldTime"] = 62, -- was 60 in beta
				},
				["questID"] = 80220,
				["mapPOI"] = 7794,
			},
			[3] = { -- Basin Bypass
				["normal"] = {
					["currencyID"] = 2925,
					["silverTime"] = 63,
					["goldTime"] = 58,
				},
				["advanced"] = {
					["currencyID"] = 2931,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["reverse"] = {
					["currencyID"] = 2937,
					["silverTime"] = 60,
					["goldTime"] = 57,
				},
				["questID"] = 80221,
				["mapPOI"] = 7795,
			},
			[4] = { -- The Wold Ways
				["normal"] = {
					["currencyID"] = 2926,
					["silverTime"] = 73,
					["goldTime"] = 68,
				},
				["advanced"] = {
					["currencyID"] = 2932,
					["silverTime"] = 71,
					["goldTime"] = 68,
				},
				["reverse"] = {
					["currencyID"] = 2938,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["questID"] = 80222,
				["mapPOI"] = 7796,
			},
			[5] = { -- Thunderhead Trail
				["normal"] = {
					["currencyID"] = 2927,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["advanced"] = {
					["currencyID"] = 2933,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["reverse"] = {
					["currencyID"] = 2939,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["questID"] = 80223,
				["mapPOI"] = 7797,
			},
			[6] = { -- Orecreg's Doglegs
				["normal"] = {
					["currencyID"] = 2928,
					["silverTime"] = 70,
					["goldTime"] = 65,
				},
				["advanced"] = {
					["currencyID"] = 2934,
					["silverTime"] = 64,
					["goldTime"] = 61,
				},
				["reverse"] = {
					["currencyID"] = 2940,
					["silverTime"] = 64,
					["goldTime"] = 61,
				},
				["questID"] = 80224,
				["mapPOI"] = 7798,
			},
		},
	},
	{ -- The Ringing Deeps
		zone = 2214,
		expansion = 10,
		races = {
			[1] = { -- Earthenworks Weave
				["normal"] = {
					["currencyID"] = 2941,
					["silverTime"] = 57,
					["goldTime"] = 52,
				},
				["advanced"] = {
					["currencyID"] = 2947,
					["silverTime"] = 52,
					["goldTime"] = 49,
				},
				["reverse"] = {
					["currencyID"] = 2953,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["questID"] = 80237,
				["mapPOI"] = 7799,
			},
			[2] = { -- Ringing Deeps Ramble
				["normal"] = {
					["currencyID"] = 2942,
					["silverTime"] = 62,
					["goldTime"] = 57,
				},
				["advanced"] = {
					["currencyID"] = 2948,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["reverse"] = {
					["currencyID"] = 2954,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["questID"] = 80238,
				["mapPOI"] = 7800,
			},
			[3] = { -- Chittering Concourse
				["normal"] = {
					["currencyID"] = 2943,
					["silverTime"] = 61,
					["goldTime"] = 56,
				},
				["advanced"] = {
					["currencyID"] = 2949,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["reverse"] = {
					["currencyID"] = 2955,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["questID"] = 80239,
				["mapPOI"] = 7801,
			},
			[4] = { -- Cataract River Cruise
				["normal"] = {
					["currencyID"] = 2944,
					["silverTime"] = 65,
					["goldTime"] = 60,
				},
				["advanced"] = {
					["currencyID"] = 2950,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["reverse"] = {
					["currencyID"] = 2956,
					["silverTime"] = 60,
					["goldTime"] = 57,
				},
				["questID"] = 80240,
				["mapPOI"] = 7802,
			},
			[5] = { -- Taelloch Twist
				["normal"] = {
					["currencyID"] = 2945,
					["silverTime"] = 52,
					["goldTime"] = 47,
				},
				["advanced"] = {
					["currencyID"] = 2951,
					["silverTime"] = 46,
					["goldTime"] = 43,
				},
				["reverse"] = {
					["currencyID"] = 2957,
					["silverTime"] = 47,
					["goldTime"] = 44,
				},
				["questID"] = 80242,
				["mapPOI"] = 7803,
			},
			[6] = { -- Opportunity Point Amble
				["normal"] = {
					["currencyID"] = 2946,
					["silverTime"] = 82,
					["goldTime"] = 77,
				},
				["advanced"] = {
					["currencyID"] = 2952,
					["silverTime"] = 74,
					["goldTime"] = 71,
				},
				["reverse"] = {
					["currencyID"] = 2958,
					["silverTime"] = 75,
					["goldTime"] = 72,
				},
				["questID"] = 80243,
				["mapPOI"] = 7804,
			},
		},
	},
	{ -- Hallowfall
		zone = 2215,
		expansion = 10,
		races = {
			[1] = { -- Dunelle's Detour
				["normal"] = {
					["currencyID"] = 2959,
					["silverTime"] = 70,
					["goldTime"] = 65,
				},
				["advanced"] = {
					["currencyID"] = 2965,
					["silverTime"] = 65,
					["goldTime"] = 62,
				},
				["reverse"] = {
					["currencyID"] = 2971,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["questID"] = 80256,
				["mapPOI"] = 7805,
			},
			[2] = { -- Tenir's Traversal
				["normal"] = {
					["currencyID"] = 2960,
					["silverTime"] = 70,
					["goldTime"] = 65,
				},
				["advanced"] = {
					["currencyID"] = 2966,
					["silverTime"] = 63,
					["goldTime"] = 60,
				},
				["reverse"] = {
					["currencyID"] = 2972,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["questID"] = 80257,
				["mapPOI"] = 7806,
			},
			[3] = { -- Light's Redoubt Descent
				["normal"] = {
					["currencyID"] = 2961,
					["silverTime"] = 68,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2967,
					["silverTime"] = 65,
					["goldTime"] = 62,
				},
				["reverse"] = {
					["currencyID"] = 2973,
					["silverTime"] = 65,
					["goldTime"] = 62,
				},
				["questID"] = 80258,
				["mapPOI"] = 7807,
			},
			[4] = { -- Stillstone Slalom
				["normal"] = {
					["currencyID"] = 2962,
					["silverTime"] = 61,
					["goldTime"] = 56,
				},
				["advanced"] = {
					["currencyID"] = 2968,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["reverse"] = {
					["currencyID"] = 2974,
					["silverTime"] = 59,
					["goldTime"] = 56,
				},
				["questID"] = 80259,
				["mapPOI"] = 7808,
			},
			[5] = { -- Mereldar Meander
				["normal"] = {
					["currencyID"] = 2963,
					["silverTime"] = 81,
					["goldTime"] = 76,
				},
				["advanced"] = {
					["currencyID"] = 2969,
					["silverTime"] = 74,
					["goldTime"] = 71,
				},
				["reverse"] = {
					["currencyID"] = 2975,
					["silverTime"] = 74,
					["goldTime"] = 71,
				},
				["questID"] = 80260,
				["mapPOI"] = 7809,
			},
			[6] = { -- Velhan's Venture
				["normal"] = {
					["currencyID"] = 2964,
					["silverTime"] = 60,
					["goldTime"] = 55,
				},
				["advanced"] = {
					["currencyID"] = 2970,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["reverse"] = {
					["currencyID"] = 2976,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["questID"] = 80261,
				["mapPOI"] = 7810,
			},
		},
	},
	{ -- Azj-Kahet
		zone = 2255,
		expansion = 10,
		races = {
			[1] = { -- City of Threads Twist
				["normal"] = {
					["currencyID"] = 2977,
					["silverTime"] = 83,
					["goldTime"] = 78,
				},
				["advanced"] = {
					["currencyID"] = 2983,
					["silverTime"] = 77,
					["goldTime"] = 74,
				},
				["reverse"] = {
					["currencyID"] = 2989,
					["silverTime"] = 77,
					["goldTime"] = 74,
				},
				["questID"] = 80277,
				["mapPOI"] = 7811,
			},
			[2] = { -- Maddening Deep Dip
				["normal"] = {
					["currencyID"] = 2978,
					["silverTime"] = 63,
					["goldTime"] = 58,
				},
				["advanced"] = {
					["currencyID"] = 2984,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["reverse"] = {
					["currencyID"] = 2990,
					["silverTime"] = 59,
					["goldTime"] = 56,
				},
				["questID"] = 80278,
				["mapPOI"] = 7812,
			},
			[3] = { -- The Weaver's Wing
				["normal"] = {
					["currencyID"] = 2979,
					["silverTime"] = 59,
					["goldTime"] = 54,
				},
				["advanced"] = {
					["currencyID"] = 2985,
					["silverTime"] = 54,
					["goldTime"] = 51,
				},
				["reverse"] = {
					["currencyID"] = 2991,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["questID"] = 80279,
				["mapPOI"] = 7813,
			},
			[4] = { -- Rak-Ahat Rush
				["normal"] = {
					["currencyID"] = 2980,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["advanced"] = {
					["currencyID"] = 2986,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["reverse"] = {
					["currencyID"] = 2992,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["questID"] = 80280,
				["mapPOI"] = 7814,
			},
			[5] = { -- Pit Plunge
				["normal"] = {
					["currencyID"] = 2981,
					["silverTime"] = 68,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2987,
					["silverTime"] = 64,
					["goldTime"] = 61,
				},
				["reverse"] = {
					["currencyID"] = 2993,
					["silverTime"] = 64,
					["goldTime"] = 61,
				},
				["questID"] = 80281,
				["mapPOI"] = 7815,
			},
			[6] = { -- Siegehold Scuttle
				["normal"] = {
					["currencyID"] = 2982,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["advanced"] = {
					["currencyID"] = 2988,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["reverse"] = {
					["currencyID"] = 2994,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["questID"] = 80282,
				["mapPOI"] = 7816,
			},
		},
	},
	{ -- Undermine
		zone = 2346,
		expansion = 10,
		races = {
			[1] = { -- Skyrocketing Sprint
				["normal"] = {
					["currencyID"] = 3119,
					["silverTime"] = 42,
					["goldTime"] = 32,
				},
				["reverse"] = {
					["currencyID"] = 3121,
					["silverTime"] = 42,
					["goldTime"] = 32,
				},
				["questID"] = 85071,
				["mapPOI"] = 8144,
			},
			[2] = { -- The Heaps Leap
				["normal"] = {
					["currencyID"] = 3122,
					["silverTime"] = 43,
					["goldTime"] = 33,
				},
				["reverse"] = {
					["currencyID"] = 3123,
					["silverTime"] = 43,
					["goldTime"] = 33,
				},
				["questID"] = 85097,
				["mapPOI"] = 8145,
			},
			[3] = { -- Scrapshop Shot
				["normal"] = {
					["currencyID"] = 3124,
					["silverTime"] = 46,
					["goldTime"] = 36,
				},
				["reverse"] = {
					["currencyID"] = 3125,
					["silverTime"] = 46,
					["goldTime"] = 36,
				},
				["questID"] = 85099,
				["mapPOI"] = 8146,
			},
			[4] = { -- Rags to Riches Rush
				["normal"] = {
					["currencyID"] = 3126,
					["silverTime"] = 50,
					["goldTime"] = 40,
				},
				["reverse"] = {
					["currencyID"] = 3127,
					["silverTime"] = 50,
					["goldTime"] = 40,
				},
				["questID"] = 85101,
				["mapPOI"] = 8147,
			},
			[5] = { -- Breakneck Bolt
				["normal"] = {
					["currencyID"] = 3181,
					["silverTime"] = 40,
					["goldTime"] = 35,
				},
				["reverse"] = {
					["currencyID"] = 3182,
					["silverTime"] = 40,
					["goldTime"] = 35,
				},
				["questID"] = 85900,
				["mapPOI"] = 8177,
			},
			[6] = { -- Junkyard Jaunt
				["normal"] = {
					["currencyID"] = 3183,
					["silverTime"] = 40,
					["goldTime"] = 35,
				},
				["reverse"] = {
					["currencyID"] = 3184,
					["silverTime"] = 40,
					["goldTime"] = 35,
				},
				["questID"] = 85902,
				["mapPOI"] = 8178,
			},
			[7] = { -- Casino Cruise
				["normal"] = {
					["currencyID"] = 3185,
					["silverTime"] = 35,
					["goldTime"] = 30,
				},
				["reverse"] = {
					["currencyID"] = 3186,
					["silverTime"] = 35,
					["goldTime"] = 30,
				},
				["questID"] = 85904,
				["mapPOI"] = 8179,
			},
			[8] = { -- Sandy Scuttle
				["normal"] = {
					["currencyID"] = 3187,
					["silverTime"] = 38,
					["goldTime"] = 33,
				},
				["reverse"] = {
					["currencyID"] = 3188,
					["silverTime"] = 38,
					["goldTime"] = 33,
				},
				["questID"] = 85906,
				["mapPOI"] = 8180,
			},
		},
	},
	{ -- K'aresh
		zone = 2371,
		expansion = 10,
		races = {
			[1] = { -- Oasis Biodome
				["normal"] = {
					["currencyID"] = 3213,
					["silverTime"] = 62,
					["goldTime"] = 57,
				},
				["advanced"] = {
					["currencyID"] = 3214,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["reverse"] = {
					["currencyID"] = 3215,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["questID"] = 86339,
				["mapPOI"] = 8272, -- temp POI - Ecological Succession
			},
		},
	},
	{ -- Waking Shores
		zone = 2022,
		expansion = 9,
		races = {
			[1] = { -- Ruby Lifeshrine Loop
				["normal"] = {
					["currencyID"] = 2042,
					["silverTime"] = 56,
					["goldTime"] = 56,
				},
				["advanced"] = {
					["currencyID"] = 2044,
					["silverTime"] = 57,
					["goldTime"] = 52,
				},
				["reverse"] = {
					["currencyID"] = 2154,
					["silverTime"] = 55,
					["goldTime"] = 50,
				},
				["challenge"] = {
					["currencyID"] = 2421,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["reversechallenge"] = {
					["currencyID"] = 2422,
					["silverTime"] = 60,
					["goldTime"] = 57,
				},
				["storm"] = {
					["currencyID"] = 2664,
					["silverTime"] = 70,
					["goldTime"] = 65,
				},
				["questID"] = 66679,
				["mapPOI"] = 7740,
			},
			[2] = { -- Wild Preserve Slalom
				["normal"] = {
					["currencyID"] = 2048,
					["silverTime"] = 45,
					["goldTime"] = 42,
				},
				["advanced"] = {
					["currencyID"] = 2049,
					["silverTime"] = 45,
					["goldTime"] = 40,
				},
				["reverse"] = {
					["currencyID"] = 2176,
					["silverTime"] = 46,
					["goldTime"] = 41,
				},
				["challenge"] = {
					["currencyID"] = 2423,
					["silverTime"] = 51,
					["goldTime"] = 48,
				},
				["reversechallenge"] = {
					["currencyID"] = 2424,
					["silverTime"] = 52,
					["goldTime"] = 49,
				},
				["questID"] = 66721,
				["mapPOI"] = 7742,
			},
			[3] = { -- Emberflow Flight
				["normal"] = {
					["currencyID"] = 2052,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["advanced"] = {
					["currencyID"] = 2053,
					["silverTime"] = 49,
					["goldTime"] = 44,
				},
				["reverse"] = {
					["currencyID"] = 2177,
					["silverTime"] = 50,
					["goldTime"] = 45,
				},
				["challenge"] = {
					["currencyID"] = 2425,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["reversechallenge"] = {
					["currencyID"] = 2426,
					["silverTime"] = 54,
					["goldTime"] = 51,
				},
				["questID"] = 66727,
				["mapPOI"] = 7743,
			},
			[4] = { -- Apex Canopy River Run
				["normal"] = {
					["currencyID"] = 2054,
					["silverTime"] = 55,
					["goldTime"] = 52,
				},
				["advanced"] = {
					["currencyID"] = 2055,
					["silverTime"] = 50,
					["goldTime"] = 45,
				},
				["reverse"] = {
					["currencyID"] = 2178,
					["silverTime"] = 53,
					["goldTime"] = 48,
				},
				["challenge"] = {
					["currencyID"] = 2427,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["reversechallenge"] = {
					["currencyID"] = 2428,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["questID"] = 66732,
				["mapPOI"] = 7744,
			},
			[5] = { -- Uktulut Coaster
				["normal"] = {
					["currencyID"] = 2056,
					["silverTime"] = 48,
					["goldTime"] = 45,
				},
				["advanced"] = {
					["currencyID"] = 2057,
					["silverTime"] = 45,
					["goldTime"] = 40,
				},
				["reverse"] = {
					["currencyID"] = 2179,
					["silverTime"] = 48,
					["goldTime"] = 43,
				},
				["challenge"] = {
					["currencyID"] = 2429,
					["silverTime"] = 49,
					["goldTime"] = 46,
				},
				["reversechallenge"] = {
					["currencyID"] = 2430,
					["silverTime"] = 51,
					["goldTime"] = 48,
				},
				["questID"] = 66777,
				["mapPOI"] = 7745,
			},
			[6] = { -- Wingrest Roundabout
				["normal"] = {
					["currencyID"] = 2058,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["advanced"] = {
					["currencyID"] = 2059,
					["silverTime"] = 58,
					["goldTime"] = 53,
				},
				["reverse"] = {
					["currencyID"] = 2180,
					["silverTime"] = 61,
					["goldTime"] = 56,
				},
				["challenge"] = {
					["currencyID"] = 2431,
					["silverTime"] = 63,
					["goldTime"] = 60,
				},
				["reversechallenge"] = {
					["currencyID"] = 2432,
					["silverTime"] = 63,
					["goldTime"] = 60,
				},
				["questID"] = 66786,
				["mapPOI"] = 7746,
			},
			[7] = { -- Flashfrost Flyover
				["normal"] = {
					["currencyID"] = 2046,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2047,
					["silverTime"] = 66,
					["goldTime"] = 61,
				},
				["reverse"] = {
					["currencyID"] = 2181,
					["silverTime"] = 65,
					["goldTime"] = 60,
				},
				["challenge"] = {
					["currencyID"] = 2433,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["reversechallenge"] = {
					["currencyID"] = 2434,
					["silverTime"] = 74,
					["goldTime"] = 69,
				},
				["questID"] = 66710,
				["mapPOI"] = 7741,
			},
			[8] = { -- Wild Preserve Circuit
				["normal"] = {
					["currencyID"] = 2050,
					["silverTime"] = 43,
					["goldTime"] = 40,
				},
				["advanced"] = {
					["currencyID"] = 2051,
					["silverTime"] = 43,
					["goldTime"] = 38,
				},
				["reverse"] = {
					["currencyID"] = 2182,
					["silverTime"] = 46,
					["goldTime"] = 41,
				},
				["challenge"] = {
					["currencyID"] = 2435,
					["silverTime"] = 46,
					["goldTime"] = 43,
				},
				["reversechallenge"] = {
					["currencyID"] = 2436,
					["silverTime"] = 47,
					["goldTime"] = 44,
				},
				["questID"] = 66725,
				["mapPOI"] = 7747,
			},
		},
	},
	{ -- Ohn'ahran Plains
		zone = 2023,
		expansion = 9,
		races = {
			[1] = { -- Sundapple Copse Circuit
				["normal"] = {
					["currencyID"] = 2060,
					["silverTime"] = 52,
					["goldTime"] = 49,
				},
				["advanced"] = {
					["currencyID"] = 2061,
					["silverTime"] = 46,
					["goldTime"] = 41,
				},
				["reverse"] = {
					["currencyID"] = 2183,
					["silverTime"] = 50,
					["goldTime"] = 45,
				},
				["challenge"] = {
					["currencyID"] = 2437,
					["silverTime"] = 54,
					["goldTime"] = 51,
				},
				["reversechallenge"] = {
					["currencyID"] = 2439,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["questID"] = 66835,
				["mapPOI"] = 7748,
			},
			[2] = { -- Fen Flythrough
				["normal"] = {
					["currencyID"] = 2062,
					["silverTime"] = 51,
					["goldTime"] = 48,
				},
				["advanced"] = {
					["currencyID"] = 2063,
					["silverTime"] = 46,
					["goldTime"] = 41,
				},
				["reverse"] = {
					["currencyID"] = 2184,
					["silverTime"] = 52,
					["goldTime"] = 47,
				},
				["challenge"] = {
					["currencyID"] = 2440,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["reversechallenge"] = {
					["currencyID"] = 2441,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["storm"] = {
					["currencyID"] = 2665,
					["silverTime"] = 87,
					["goldTime"] = 82,
				},
				["questID"] = 66877,
				["mapPOI"] = 7749,
			},
			[3] = { -- Ravine River Run
				["normal"] = {
					["currencyID"] = 2064,
					["silverTime"] = 52,
					["goldTime"] = 49,
				},
				["advanced"] = {
					["currencyID"] = 2065,
					["silverTime"] = 52,
					["goldTime"] = 47,
				},
				["reverse"] = {
					["currencyID"] = 2185,
					["silverTime"] = 51,
					["goldTime"] = 46,
				},
				["challenge"] = {
					["currencyID"] = 2442,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["reversechallenge"] = {
					["currencyID"] = 2443,
					["silverTime"] = 54,
					["goldTime"] = 51,
				},
				["questID"] = 66880,
				["mapPOI"] = 7750,
			},
			[4] = { -- Emerald Gardens Ascent
				["normal"] = {
					["currencyID"] = 2066,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2067,
					["silverTime"] = 60,
					["goldTime"] = 55,
				},
				["reverse"] = {
					["currencyID"] = 2186,
					["silverTime"] = 62,
					["goldTime"] = 57,
				},
				["challenge"] = {
					["currencyID"] = 2444,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["reversechallenge"] = {
					["currencyID"] = 2445,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["questID"] = 66885,
				["mapPOI"] = 7751,
			},
			[5] = { -- Maruukai Dash
				["normal"] = {
					["currencyID"] = 2069,
					["silverTime"] = 28,
					["goldTime"] = 25,
				},
				["challenge"] = {
					["currencyID"] = 2446,
					["silverTime"] = 27,
					["goldTime"] = 24,
				},
				["questID"] = 66921,
				["mapPOI"] = 7753,
			},
			[6] = { -- Mirror of the Sky Dash
				["normal"] = {
					["currencyID"] = 2070,
					["silverTime"] = 29,
					["goldTime"] = 26,
				},
				["challenge"] = {
					["currencyID"] = 2447,
					["silverTime"] = 30,
					["goldTime"] = 27,
				},
				["questID"] = 66933,
				["mapPOI"] = 7754,
			},
			[7] = { -- River Rapids Route
				["normal"] = {
					["currencyID"] = 2119,
					["silverTime"] = 51,
					["goldTime"] = 48,
				},
				["advanced"] = {
					["currencyID"] = 2120,
					["silverTime"] = 48,
					["goldTime"] = 43,
				},
				["reverse"] = {
					["currencyID"] = 2187,
					["silverTime"] = 49,
					["goldTime"] = 44,
				},
				["challenge"] = {
					["currencyID"] = 2448,
					["silverTime"] = 55,
					["goldTime"] = 52,
				},
				["reversechallenge"] = {
					["currencyID"] = 2449,
					["silverTime"] = 55,
					["goldTime"] = 52,
				},
				["questID"] = 70710,
				["mapPOI"] = 7752,
			},
		},
	},
	{ -- The Azure Span
		zone = 2024,
		expansion = 9,
		races = {
			[1] = { -- The Azure Span Sprint
				["normal"] = {
					["currencyID"] = 2074,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2075,
					["silverTime"] = 63,
					["goldTime"] = 58,
				},
				["reverse"] = {
					["currencyID"] = 2188,
					["silverTime"] = 65,
					["goldTime"] = 60,
				},
				["challenge"] = {
					["currencyID"] = 2450,
					["silverTime"] = 70,
					["goldTime"] = 67,
				},
				["reversechallenge"] = {
					["currencyID"] = 2451,
					["silverTime"] = 72,
					["goldTime"] = 69,
				},
				["questID"] = 66946,
				["mapPOI"] = 7755,
			},
			[2] = { -- The Azure Span Slalom
				["normal"] = {
					["currencyID"] = 2076,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["advanced"] = {
					["currencyID"] = 2077,
					["silverTime"] = 61,
					["goldTime"] = 56,
				},
				["reverse"] = {
					["currencyID"] = 2189,
					["silverTime"] = 58,
					["goldTime"] = 53,
				},
				["challenge"] = {
					["currencyID"] = 2452,
					["silverTime"] = 58,
					["goldTime"] = 55,
				},
				["reversechallenge"] = {
					["currencyID"] = 2453,
					["silverTime"] = 58,
					["goldTime"] = 55,
				},
				["questID"] = 67002,
				["mapPOI"] = 7756,
			},
			[3] = { -- The Vakthros Ascent
				["normal"] = {
					["currencyID"] = 2078,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["advanced"] = {
					["currencyID"] = 2079,
					["silverTime"] = 61,
					["goldTime"] = 56,
				},
				["reverse"] = {
					["currencyID"] = 2190,
					["silverTime"] = 61,
					["goldTime"] = 56,
				},
				["challenge"] = {
					["currencyID"] = 2454,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["reversechallenge"] = {
					["currencyID"] = 2455,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["storm"] = {
					["currencyID"] = 2666,
					["silverTime"] = 125,
					["goldTime"] = 120,
				},
				["questID"] = 67031,
				["mapPOI"] = 7757,
			},
			[4] = { -- Iskaara Tour
				["normal"] = {
					["currencyID"] = 2083,
					["silverTime"] = 78,
					["goldTime"] = 75,
				},
				["advanced"] = {
					["currencyID"] = 2084,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["reverse"] = {
					["currencyID"] = 2191,
					["silverTime"] = 72,
					["goldTime"] = 67,
				},
				["challenge"] = {
					["currencyID"] = 2456,
					["silverTime"] = 81,
					["goldTime"] = 78,
				},
				["reversechallenge"] = {
					["currencyID"] = 2457,
					["silverTime"] = 82,
					["goldTime"] = 79,
				},
				["questID"] = 67296,
				["mapPOI"] = 7758,
			},
			[5] = { -- Frostland Flyover
				["normal"] = {
					["currencyID"] = 2085,
					["silverTime"] = 79,
					["goldTime"] = 76,
				},
				["advanced"] = {
					["currencyID"] = 2086,
					["silverTime"] = 77,
					["goldTime"] = 72,
				},
				["reverse"] = {
					["currencyID"] = 2192,
					["silverTime"] = 74,
					["goldTime"] = 69,
				},
				["challenge"] = {
					["currencyID"] = 2458,
					["silverTime"] = 88,
					["goldTime"] = 85,
				},
				["reversechallenge"] = {
					["currencyID"] = 2459,
					["silverTime"] = 86,
					["goldTime"] = 83,
				},
				["questID"] = 67565,
				["mapPOI"] = 7759,
			},
			[6] = { -- Archive Ambit
				["normal"] = {
					["currencyID"] = 2089,
					["silverTime"] = 94,
					["goldTime"] = 91,
				},
				["advanced"] = {
					["currencyID"] = 2090,
					["silverTime"] = 86,
					["goldTime"] = 81,
				},
				["reverse"] = {
					["currencyID"] = 2193,
					["silverTime"] = 81,
					["goldTime"] = 76,
				},
				["challenge"] = {
					["currencyID"] = 2460,
					["silverTime"] = 93,
					["goldTime"] = 90,
				},
				["reversechallenge"] = {
					["currencyID"] = 2461,
					["silverTime"] = 95,
					["goldTime"] = 92,
				},
				["questID"] = 67741,
				["mapPOI"] = 7760,
			},
		},
	},
	{ -- Thaldraszus
		zone = 2025,
		expansion = 9,
		races = {
			[1] = { -- The Flowing Forest Flight
				["normal"] = {
					["currencyID"] = 2080,
					["silverTime"] = 52,
					["goldTime"] = 49,
				},
				["advanced"] = {
					["currencyID"] = 2081,
					["silverTime"] = 45,
					["goldTime"] = 40,
				},
				["reverse"] = {
					["currencyID"] = 2194,
					["silverTime"] = 46,
					["goldTime"] = 41,
				},
				["challenge"] = {
					["currencyID"] = 2462,
					["silverTime"] = 50,
					["goldTime"] = 47,
				},
				["reversechallenge"] = {
					["currencyID"] = 2463,
					["silverTime"] = 49,
					["goldTime"] = 46,
				},
				["questID"] = 67095,
				["mapPOI"] = 7761,
			},
			[2] = { -- Tyrhold Trial
				["normal"] = {
					["currencyID"] = 2092,
					["silverTime"] = 84,
					["goldTime"] = 81,
				},
				["advanced"] = {
					["currencyID"] = 2093,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["reverse"] = {
					["currencyID"] = 2195,
					["silverTime"] = 64,
					["goldTime"] = 59,
				},
				["challenge"] = {
					["currencyID"] = 2464,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["reversechallenge"] = {
					["currencyID"] = 2465,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["storm"] = {
					["currencyID"] = 2667,
					["silverTime"] = 85,
					["goldTime"] = 80,
				},
				["questID"] = 69957,
				["mapPOI"] = 7762,
			},
			[3] = { -- Cliffside Circuit
				["normal"] = {
					["currencyID"] = 2096,
					["silverTime"] = 72,
					["goldTime"] = 69,
				},
				["advanced"] = {
					["currencyID"] = 2097,
					["silverTime"] = 71,
					["goldTime"] = 66,
				},
				["reverse"] = {
					["currencyID"] = 2196,
					["silverTime"] = 74,
					["goldTime"] = 69,
				},
				["challenge"] = {
					["currencyID"] = 2466,
					["silverTime"] = 84,
					["goldTime"] = 81,
				},
				["reversechallenge"] = {
					["currencyID"] = 2467,
					["silverTime"] = 83,
					["goldTime"] = 80,
				},
				["questID"] = 70051,
				["mapPOI"] = 7763,
			},
			[4] = { -- Academy Ascent
				["normal"] = {
					["currencyID"] = 2098,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["advanced"] = {
					["currencyID"] = 2099,
					["silverTime"] = 57,
					["goldTime"] = 52,
				},
				["reverse"] = {
					["currencyID"] = 2197,
					["silverTime"] = 58,
					["goldTime"] = 53,
				},
				["challenge"] = {
					["currencyID"] = 2468,
					["silverTime"] = 68,
					["goldTime"] = 65,
				},
				["reversechallenge"] = {
					["currencyID"] = 2469,
					["silverTime"] = 68,
					["goldTime"] = 65,
				},
				["questID"] = 70059,
				["mapPOI"] = 7764,
			},
			[5] = { -- Garden Gallivant
				["normal"] = {
					["currencyID"] = 2101,
					["silverTime"] = 64,
					["goldTime"] = 61,
				},
				["advanced"] = {
					["currencyID"] = 2102,
					["silverTime"] = 59,
					["goldTime"] = 54,
				},
				["reverse"] = {
					["currencyID"] = 2198,
					["silverTime"] = 62,
					["goldTime"] = 57,
				},
				["challenge"] = {
					["currencyID"] = 2470,
					["silverTime"] = 63,
					["goldTime"] = 60,
				},
				["reversechallenge"] = {
					["currencyID"] = 2471,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["questID"] = 70157,
				["mapPOI"] = 7765,
			},
			[6] = { -- Caverns Criss-Cross
				["normal"] = {
					["currencyID"] = 2103,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["advanced"] = {
					["currencyID"] = 2104,
					["silverTime"] = 50,
					["goldTime"] = 45,
				},
				["reverse"] = {
					["currencyID"] = 2199,
					["silverTime"] = 52,
					["goldTime"] = 47,
				},
				["challenge"] = {
					["currencyID"] = 2472,
					["silverTime"] = 59,
					["goldTime"] = 56,
				},
				["reversechallenge"] = {
					["currencyID"] = 2473,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["questID"] = 70161,
				["mapPOI"] = 7766,
			},
		},
	},
	{ -- Forbidden Reach
		zone = 2151,
		expansion = 9,
		races = {
			[1] = { -- Stormsunder Crater Circuit
				["normal"] = {
					["currencyID"] = 2201,
					["silverTime"] = 46,
					["goldTime"] = 43,
				},
				["advanced"] = {
					["currencyID"] = 2207,
					["silverTime"] = 47,
					["goldTime"] = 42,
				},
				["reverse"] = {
					["currencyID"] = 2213,
					["silverTime"] = 47,
					["goldTime"] = 42,
				},
				["challenge"] = {
					["currencyID"] = 2474,
					["silverTime"] = 48,
					["goldTime"] = 45,
				},
				["reversechallenge"] = {
					["currencyID"] = 2475,
					["silverTime"] = 47,
					["goldTime"] = 44,
				},
				["storm"] = {
					["currencyID"] = 2668,
					["silverTime"] = 97,
					["goldTime"] = 92,
				},
				["questID"] = 73017,
				["mapPOI"] = 7767,
			},
			[2] = { -- Morqut Ascent
				["normal"] = {
					["currencyID"] = 2202,
					["silverTime"] = 55,
					["goldTime"] = 52,
				},
				["advanced"] = {
					["currencyID"] = 2208,
					["silverTime"] = 54,
					["goldTime"] = 49,
				},
				["reverse"] = {
					["currencyID"] = 2214,
					["silverTime"] = 57,
					["goldTime"] = 52,
				},
				["challenge"] = {
					["currencyID"] = 2476,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["reversechallenge"] = {
					["currencyID"] = 2477,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["questID"] = 73020,
				["mapPOI"] = 7768,
			},
			[3] = { -- Aerie Chasm
				["normal"] = {
					["currencyID"] = 2203,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["advanced"] = {
					["currencyID"] = 2209,
					["silverTime"] = 55,
					["goldTime"] = 50,
				},
				["reverse"] = {
					["currencyID"] = 2215,
					["silverTime"] = 55,
					["goldTime"] = 50,
				},
				["challenge"] = {
					["currencyID"] = 2478,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["reversechallenge"] = {
					["currencyID"] = 2479,
					["silverTime"] = 55,
					["goldTime"] = 52,
				},
				["questID"] = 73025,
				["mapPOI"] = 7769,
			},
			[4] = { -- Southern Reach Route
				["normal"] = {
					["currencyID"] = 2204,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["advanced"] = {
					["currencyID"] = 2210,
					["silverTime"] = 73,
					["goldTime"] = 68,
				},
				["reverse"] = {
					["currencyID"] = 2216,
					["silverTime"] = 68,
					["goldTime"] = 63,
				},
				["challenge"] = {
					["currencyID"] = 2480,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["reversechallenge"] = {
					["currencyID"] = 2481,
					["silverTime"] = 71,
					["goldTime"] = 68,
				},
				["questID"] = 73029,
				["mapPOI"] = 7770,
			},
			[5] = { -- Caldera Coaster
				["normal"] = {
					["currencyID"] = 2205,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["advanced"] = {
					["currencyID"] = 2211,
					["silverTime"] = 57,
					["goldTime"] = 52,
				},
				["reverse"] = {
					["currencyID"] = 2217,
					["silverTime"] = 54,
					["goldTime"] = 49,
				},
				["challenge"] = {
					["currencyID"] = 2482,
					["silverTime"] = 58,
					["goldTime"] = 55,
				},
				["reversechallenge"] = {
					["currencyID"] = 2483,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["questID"] = 73033,
				["mapPOI"] = 7771,
			},
			[6] = { -- Forbidden Reach Rush
				["normal"] = {
					["currencyID"] = 2206,
					["silverTime"] = 62,
					["goldTime"] = 59,
				},
				["advanced"] = {
					["currencyID"] = 2212,
					["silverTime"] = 61,
					["goldTime"] = 56,
				},
				["reverse"] = {
					["currencyID"] = 2218,
					["silverTime"] = 62,
					["goldTime"] = 57,
				},
				["challenge"] = {
					["currencyID"] = 2484,
					["silverTime"] = 63,
					["goldTime"] = 60,
				},
				["reversechallenge"] = {
					["currencyID"] = 2485,
					["silverTime"] = 63,
					["goldTime"] = 60,
				},
				["questID"] = 73061,
				["mapPOI"] = 7772,
			},
		},
	},
	{ -- Zaralek Caverns
		zone = 2133,
		expansion = 9,
		races = {
			[1] = { -- Crystal Circuit
				["normal"] = {
					["currencyID"] = 2246,
					["silverTime"] = 68,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2252,
					["silverTime"] = 60,
					["goldTime"] = 55,
				},
				["reverse"] = {
					["currencyID"] = 2258,
					["silverTime"] = 58,
					["goldTime"] = 53,
				},
				["challenge"] = {
					["currencyID"] = 2486,
					["silverTime"] = 60,
					["goldTime"] = 57,
				},
				["reversechallenge"] = {
					["currencyID"] = 2487,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["storm"] = {
					["currencyID"] = 2669,
					["silverTime"] = 100,
					["goldTime"] = 95,
				},
				["questID"] = 74839,
				["mapPOI"] = 7773,
			},
			[2] = { -- Caldera Cruise
				["normal"] = {
					["currencyID"] = 2247,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["advanced"] = {
					["currencyID"] = 2253,
					["silverTime"] = 73,
					["goldTime"] = 68,
				},
				["reverse"] = {
					["currencyID"] = 2259,
					["silverTime"] = 73,
					["goldTime"] = 68,
				},
				["challenge"] = {
					["currencyID"] = 2488,
					["silverTime"] = 75,
					["goldTime"] = 72,
				},
				["reversechallenge"] = {
					["currencyID"] = 2489,
					["silverTime"] = 75,
					["goldTime"] = 72,
				},
				["questID"] = 74889,
				["mapPOI"] = 7774,
			},
			[3] = { -- Brimstone Scramble
				["normal"] = {
					["currencyID"] = 2248,
					["silverTime"] = 72,
					["goldTime"] = 69,
				},
				["advanced"] = {
					["currencyID"] = 2254,
					["silverTime"] = 69,
					["goldTime"] = 64,
				},
				["reverse"] = {
					["currencyID"] = 2260,
					["silverTime"] = 69,
					["goldTime"] = 64,
				},
				["challenge"] = {
					["currencyID"] = 2490,
					["silverTime"] = 72,
					["goldTime"] = 69,
				},
				["reversechallenge"] = {
					["currencyID"] = 2491,
					["silverTime"] = 74,
					["goldTime"] = 71,
				},
				["questID"] = 74939,
				["mapPOI"] = 7775,
			},
			[4] = { -- Shimmering Slalom
				["normal"] = {
					["currencyID"] = 2249,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["advanced"] = {
					["currencyID"] = 2255,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["reverse"] = {
					["currencyID"] = 2261,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["challenge"] = {
					["currencyID"] = 2492,
					["silverTime"] = 82,
					["goldTime"] = 79,
				},
				["reversechallenge"] = {
					["currencyID"] = 2493,
					["silverTime"] = 78,
					["goldTime"] = 75,
				},
				["questID"] = 74951,
				["mapPOI"] = 7776,
			},
			[5] = { -- Loamm Roamm
				["normal"] = {
					["currencyID"] = 2250,
					["silverTime"] = 60,
					["goldTime"] = 55,
				},
				["advanced"] = {
					["currencyID"] = 2256,
					["silverTime"] = 55,
					["goldTime"] = 50,
				},
				["reverse"] = {
					["currencyID"] = 2262,
					["silverTime"] = 53,
					["goldTime"] = 48,
				},
				["challenge"] = {
					["currencyID"] = 2494,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["reversechallenge"] = {
					["currencyID"] = 2495,
					["silverTime"] = 55,
					["goldTime"] = 52,
				},
				["questID"] = 74972,
				["mapPOI"] = 7777,
			},
			[6] = { -- Sulfur Sprint
				["normal"] = {
					["currencyID"] = 2251,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["advanced"] = {
					["currencyID"] = 2257,
					["silverTime"] = 63,
					["goldTime"] = 58,
				},
				["reverse"] = {
					["currencyID"] = 2263,
					["silverTime"] = 62,
					["goldTime"] = 57,
				},
				["challenge"] = {
					["currencyID"] = 2496,
					["silverTime"] = 70,
					["goldTime"] = 67,
				},
				["reversechallenge"] = {
					["currencyID"] = 2497,
					["silverTime"] = 68,
					["goldTime"] = 65,
				},
				["questID"] = 75035,
				["mapPOI"] = 7778,
			},
		},
	},
	{ -- Emerald Dream
		zone = 2200,
		expansion = 9,
		races = {
			[1] = { -- Ysera Invitational
				["normal"] = {
					["currencyID"] = 2676,
					["silverTime"] = 103,
					["goldTime"] = 98,
				},
				["advanced"] = {
					["currencyID"] = 2682,
					["silverTime"] = 90,
					["goldTime"] = 87,
				},
				["reverse"] = {
					["currencyID"] = 2688,
					["silverTime"] = 90,
					["goldTime"] = 87,
				},
				["challenge"] = {
					["currencyID"] = 2694,
					["silverTime"] = 98,
					["goldTime"] = 95,
				},
				["reversechallenge"] = {
					["currencyID"] = 2695,
					["silverTime"] = 100,
					["goldTime"] = 97,
				},
				["questID"] = 77841,
				["mapPOI"] = 7903,
			},
			[2] = { -- Smoldering Sprint
				["normal"] = {
					["currencyID"] = 2677,
					["silverTime"] = 85,
					["goldTime"] = 80,
				},
				["advanced"] = {
					["currencyID"] = 2683,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["reverse"] = {
					["currencyID"] = 2689,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["challenge"] = {
					["currencyID"] = 2696,
					["silverTime"] = 82,
					["goldTime"] = 79,
				},
				["reversechallenge"] = {
					["currencyID"] = 2697,
					["silverTime"] = 83,
					["goldTime"] = 80,
				},
				["questID"] = 77983,
				["mapPOI"] = 7904,
			},
			[3] = { -- Viridescent Venture
				["normal"] = {
					["currencyID"] = 2678,
					["silverTime"] = 83,
					["goldTime"] = 78,
				},
				["advanced"] = {
					["currencyID"] = 2684,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["reverse"] = {
					["currencyID"] = 2690,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["challenge"] = {
					["currencyID"] = 2698,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["reversechallenge"] = {
					["currencyID"] = 2699,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["questID"] = 77996,
				["mapPOI"] = 7905,
			},
			[4] = { -- Shoreline Switchback
				["normal"] = {
					["currencyID"] = 2679,
					["silverTime"] = 78,
					["goldTime"] = 73,
				},
				["advanced"] = {
					["currencyID"] = 2685,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["reverse"] = {
					["currencyID"] = 2691,
					["silverTime"] = 65,
					["goldTime"] = 62,
				},
				["challenge"] = {
					["currencyID"] = 2700,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["reversechallenge"] = {
					["currencyID"] = 2701,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["questID"] = 78016,
				["mapPOI"] = 7906,
			},
			[5] = { -- Canopy Concours
				["normal"] = {
					["currencyID"] = 2680,
					["silverTime"] = 110,
					["goldTime"] = 105,
				},
				["advanced"] = {
					["currencyID"] = 2686,
					["silverTime"] = 96,
					["goldTime"] = 93,
				},
				["reverse"] = {
					["currencyID"] = 2692,
					["silverTime"] = 99,
					["goldTime"] = 96,
				},
				["challenge"] = {
					["currencyID"] = 2702,
					["silverTime"] = 108,
					["goldTime"] = 105,
				},
				["reversechallenge"] = {
					["currencyID"] = 2703,
					["silverTime"] = 108,
					["goldTime"] = 105,
				},
				["questID"] = 78102,
				["mapPOI"] = 7907,
			},
			[6] = { -- Emerald Amble
				["normal"] = {
					["currencyID"] = 2681,
					["silverTime"] = 89,
					["goldTime"] = 84,
				},
				["advanced"] = {
					["currencyID"] = 2687,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["reverse"] = {
					["currencyID"] = 2693,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["challenge"] = {
					["currencyID"] = 2704,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["reversechallenge"] = {
					["currencyID"] = 2705,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["questID"] = 78115,
				["mapPOI"] = 7908,
			},
		},
	},
{ -- Kalimdor Cup
		zone = 12,
		expansion = 0,
		races = {
			[1] = { -- Felwood Flyover
				["normal"] = {
					["currencyID"] = 2312,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["advanced"] = {
					["currencyID"] = 2342,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["reverse"] = {
					["currencyID"] = 2372,
					["silverTime"] = 65,
					["goldTime"] = 62,
				},
				["questID"] = 75277,
				["mapPOI"] = 7494,
			},
			[2] = { -- Winter Wander
				["normal"] = {
					["currencyID"] = 2313,
					["silverTime"] = 85,
					["goldTime"] = 80,
				},
				["advanced"] = {
					["currencyID"] = 2343,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["reverse"] = {
					["currencyID"] = 2373,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["questID"] = 75310,
				["mapPOI"] = 7495,
			},
			[3] = { -- Nordrassil Spiral
				["normal"] = {
					["currencyID"] = 2314,
					["silverTime"] = 50,
					["goldTime"] = 45,
				},
				["advanced"] = {
					["currencyID"] = 2344,
					["silverTime"] = 46,
					["goldTime"] = 41,
				},
				["reverse"] = {
					["currencyID"] = 2374,
					["silverTime"] = 46,
					["goldTime"] = 41,
				},
				["questID"] = 75317,
				["mapPOI"] = 7496,
			},
			[4] = { -- Hyjal Hotfoot
				["normal"] = {
					["currencyID"] = 2315,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["advanced"] = {
					["currencyID"] = 2345,
					["silverTime"] = 72,
					["goldTime"] = 69,
				},
				["reverse"] = {
					["currencyID"] = 2375,
					["silverTime"] = 72,
					["goldTime"] = 67,
				},
				["questID"] = 75330,
				["mapPOI"] = 7497,
			},
			[5] = { -- Rocketway Ride
				["normal"] = {
					["currencyID"] = 2316,
					["silverTime"] = 106,
					["goldTime"] = 101,
				},
				["advanced"] = {
					["currencyID"] = 2346,
					["silverTime"] = 100,
					["goldTime"] = 94,
				},
				["reverse"] = {
					["currencyID"] = 2376,
					["silverTime"] = 100,
					["goldTime"] = 94,
				},
				["questID"] = 75347,
				["mapPOI"] = 7498,
			},
			[6] = { -- Ashenvale Ambit
				["normal"] = {
					["currencyID"] = 2317,
					["silverTime"] = 69,
					["goldTime"] = 64,
				},
				["advanced"] = {
					["currencyID"] = 2347,
					["silverTime"] = 64,
					["goldTime"] = 59,
				},
				["reverse"] = {
					["currencyID"] = 2377,
					["silverTime"] = 64,
					["goldTime"] = 59,
				},
				["questID"] = 75378,
				["mapPOI"] = 7499,
			},
			[7] = { -- Durotar Tour
				["normal"] = {
					["currencyID"] = 2318,
					["silverTime"] = 87,
					["goldTime"] = 82,
				},
				["advanced"] = {
					["currencyID"] = 2348,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["reverse"] = {
					["currencyID"] = 2378,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["questID"] = 75385,
				["mapPOI"] = 7500,
			},
			[8] = { -- Webwinder Weave
				["normal"] = {
					["currencyID"] = 2319,
					["silverTime"] = 85,
					["goldTime"] = 80,
				},
				["advanced"] = {
					["currencyID"] = 2349,
					["silverTime"] = 78,
					["goldTime"] = 73,
				},
				["reverse"] = {
					["currencyID"] = 2379,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["questID"] = 75394,
				["mapPOI"] = 7501,
			},
			[9] = { -- Desolace Drift
				["normal"] = {
					["currencyID"] = 2320,
					["silverTime"] = 83,
					["goldTime"] = 78,
				},
				["advanced"] = {
					["currencyID"] = 2350,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["reverse"] = {
					["currencyID"] = 2380,
					["silverTime"] = 76,
					["goldTime"] = 71,
				},
				["questID"] = 75409,
				["mapPOI"] = 7502,
			},
			[10] = { -- Great Divide Dive
				["normal"] = {
					["currencyID"] = 2321,
					["silverTime"] = 53,
					["goldTime"] = 48,
				},
				["advanced"] = {
					["currencyID"] = 2351,
					["silverTime"] = 48,
					["goldTime"] = 43,
				},
				["reverse"] = {
					["currencyID"] = 2381,
					["silverTime"] = 49,
					["goldTime"] = 44,
				},
				["questID"] = 75412,
				["mapPOI"] = 7503,
			},
			[11] = { -- Razorfen Roundabout
				["normal"] = {
					["currencyID"] = 2322,
					["silverTime"] = 58,
					["goldTime"] = 53,
				},
				["advanced"] = {
					["currencyID"] = 2352,
					["silverTime"] = 52,
					["goldTime"] = 47,
				},
				["reverse"] = {
					["currencyID"] = 2382,
					["silverTime"] = 53,
					["goldTime"] = 48,
				},
				["questID"] = 75437,
				["mapPOI"] = 7504,
			},
			[12] = { -- Thousand Needles Thread
				["normal"] = {
					["currencyID"] = 2323,
					["silverTime"] = 92,
					["goldTime"] = 87,
				},
				["advanced"] = {
					["currencyID"] = 2353,
					["silverTime"] = 82,
					["goldTime"] = 77,
				},
				["reverse"] = {
					["currencyID"] = 2383,
					["silverTime"] = 82,
					["goldTime"] = 77,
				},
				["questID"] = 75463,
				["mapPOI"] = 7505,
			},
			[13] = { -- Feralas Ruins Ramble
				["normal"] = {
					["currencyID"] = 2324,
					["silverTime"] = 94,
					["goldTime"] = 89,
				},
				["advanced"] = {
					["currencyID"] = 2354,
					["silverTime"] = 89,
					["goldTime"] = 84,
				},
				["reverse"] = {
					["currencyID"] = 2384,
					["silverTime"] = 89,
					["goldTime"] = 84,
				},
				["questID"] = 75468,
				["mapPOI"] = 7506,
			},
			[14] = { -- Ahn'Qiraj Circuit
				["normal"] = {
					["currencyID"] = 2325,
					["silverTime"] = 82,
					["goldTime"] = 77,
				},
				["advanced"] = {
					["currencyID"] = 2355,
					["silverTime"] = 73,
					["goldTime"] = 68,
				},
				["reverse"] = {
					["currencyID"] = 2385,
					["silverTime"] = 74,
					["goldTime"] = 69,
				},
				["questID"] = 75472,
				["mapPOI"] = 7507,
			},
			[15] = { -- Uldum Tour
				["normal"] = {
					["currencyID"] = 2326,
					["silverTime"] = 89,
					["goldTime"] = 84,
				},
				["advanced"] = {
					["currencyID"] = 2356,
					["silverTime"] = 81,
					["goldTime"] = 76,
				},
				["reverse"] = {
					["currencyID"] = 2386,
					["silverTime"] = 81,
					["goldTime"] = 76,
				},
				["questID"] = 75481,
				["mapPOI"] = 7508,
			},
			[16] = { -- Un'Goro Crater Circuit
				["normal"] = {
					["currencyID"] = 2327,
					["silverTime"] = 105,
					["goldTime"] = 100,
				},
				["advanced"] = {
					["currencyID"] = 2357,
					["silverTime"] = 95,
					["goldTime"] = 90,
				},
				["reverse"] = {
					["currencyID"] = 2387,
					["silverTime"] = 97,
					["goldTime"] = 92,
				},
				["questID"] = 75485,
				["mapPOI"] = 7509,
			},
		},
	},
	{ -- Eastern Kingdoms Cup
		zone = 13,
		expansion = 0,
		races = {
			[1] = { -- Gilneas Gambit
				["normal"] = {
					["currencyID"] = 2536,
					["silverTime"] = 83,
					["goldTime"] = 78,
				},
				["advanced"] = {
					["currencyID"] = 2552,
					["silverTime"] = 77,
					["goldTime"] = 74,
				},
				["reverse"] = {
					["currencyID"] = 2568,
					["silverTime"] = 77,
					["goldTime"] = 74,
				},
				["questID"] = 76309,
				["mapPOI"] = 7571,
			},
			[2] = { -- Loch Modan Loop
				["normal"] = {
					["currencyID"] = 2537,
					["silverTime"] = 68,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2553,
					["silverTime"] = 64,
					["goldTime"] = 61,
				},
				["reverse"] = {
					["currencyID"] = 2569,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["questID"] = 76339,
				["mapPOI"] = 7572,
			},
			[3] = { -- Searing Slalom
				["normal"] = {
					["currencyID"] = 2538,
					["silverTime"] = 57,
					["goldTime"] = 52,
				},
				["advanced"] = {
					["currencyID"] = 2554,
					["silverTime"] = 49,
					["goldTime"] = 46,
				},
				["reverse"] = {
					["currencyID"] = 2570,
					["silverTime"] = 46,
					["goldTime"] = 43,
				},
				["questID"] = 76357,
				["mapPOI"] = 7573,
			},
			[4] = { -- Twilight Terror
				["normal"] = {
					["currencyID"] = 2539,
					["silverTime"] = 78,
					["goldTime"] = 73,
				},
				["advanced"] = {
					["currencyID"] = 2555,
					["silverTime"] = 71,
					["goldTime"] = 68,
				},
				["reverse"] = {
					["currencyID"] = 2571,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["questID"] = 76364,
				["mapPOI"] = 7574,
			},
			[5] = { -- Deadwind Derby
				["normal"] = {
					["currencyID"] = 2540,
					["silverTime"] = 65,
					["goldTime"] = 60,
				},
				["advanced"] = {
					["currencyID"] = 2556,
					["silverTime"] = 62,
					["goldTime"] = 59,
				},
				["reverse"] = {
					["currencyID"] = 2572,
					["silverTime"] = 62,
					["goldTime"] = 59,
				},
				["questID"] = 76380,
				["mapPOI"] = 7575,
			},
			[6] = { -- Elwynn Forest Flash
				["normal"] = {
					["currencyID"] = 2541,
					["silverTime"] = 78,
					["goldTime"] = 73,
				},
				["advanced"] = {
					["currencyID"] = 2557,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["reverse"] = {
					["currencyID"] = 2573,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["questID"] = 76397,
				["mapPOI"] = 7576,
			},
			[7] = { -- Gurubashi Gala
				["normal"] = {
					["currencyID"] = 2542,
					["silverTime"] = 61,
					["goldTime"] = 56,
				},
				["advanced"] = {
					["currencyID"] = 2558,
					["silverTime"] = 52,
					["goldTime"] = 49,
				},
				["reverse"] = {
					["currencyID"] = 2574,
					["silverTime"] = 53,
					["goldTime"] = 50,
				},
				["questID"] = 76438,
				["mapPOI"] = 7577,
			},
			[8] = { -- Ironforge Interceptor
				["normal"] = {
					["currencyID"] = 2543,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["advanced"] = {
					["currencyID"] = 2559,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["reverse"] = {
					["currencyID"] = 2575,
					["silverTime"] = 63,
					["goldTime"] = 60,
				},
				["questID"] = 76445,
				["mapPOI"] = 7578,
			},
			[9] = { -- Blasted Lands Bolt
				["normal"] = {
					["currencyID"] = 2544,
					["silverTime"] = 74,
					["goldTime"] = 69,
				},
				["advanced"] = {
					["currencyID"] = 2560,
					["silverTime"] = 65,
					["goldTime"] = 62,
				},
				["reverse"] = {
					["currencyID"] = 2576,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["questID"] = 76469,
				["mapPOI"] = 7579,
			},
			[10] = { -- Plaguelands Plunge
				["normal"] = {
					["currencyID"] = 2545,
					["silverTime"] = 68,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2561,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["reverse"] = {
					["currencyID"] = 2577,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["questID"] = 76510,
				["mapPOI"] = 7580,
			},
			[11] = { -- Booty Bay Blast
				["normal"] = {
					["currencyID"] = 2546,
					["silverTime"] = 68,
					["goldTime"] = 63,
				},
				["advanced"] = {
					["currencyID"] = 2562,
					["silverTime"] = 60,
					["goldTime"] = 57,
				},
				["reverse"] = {
					["currencyID"] = 2578,
					["silverTime"] = 59,
					["goldTime"] = 56,
				},
				["questID"] = 76515,
				["mapPOI"] = 7581,
			},
			[12] = { -- Fuselight Night Flight
				["normal"] = {
					["currencyID"] = 2547,
					["silverTime"] = 69,
					["goldTime"] = 64,
				},
				["advanced"] = {
					["currencyID"] = 2563,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["reverse"] = {
					["currencyID"] = 2579,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["questID"] = 76523,
				["mapPOI"] = 7582,
			},
			[13] = { -- Krazzworks Klash
				["normal"] = {
					["currencyID"] = 2548,
					["silverTime"] = 76,
					["goldTime"] = 71,
				},
				["advanced"] = {
					["currencyID"] = 2564,
					["silverTime"] = 67,
					["goldTime"] = 64,
				},
				["reverse"] = {
					["currencyID"] = 2580,
					["silverTime"] = 65,
					["goldTime"] = 62,
				},
				["questID"] = 76527,
				["mapPOI"] = 7583,
			},
			[14] = { -- Redridge Rally
				["normal"] = {
					["currencyID"] = 2549,
					["silverTime"] = 62,
					["goldTime"] = 57,
				},
				["advanced"] = {
					["currencyID"] = 2565,
					["silverTime"] = 55,
					["goldTime"] = 52,
				},
				["reverse"] = {
					["currencyID"] = 2581,
					["silverTime"] = 55,
					["goldTime"] = 52,
				},
				["questID"] = 76536,
				["mapPOI"] = 7584,
			},
		},
	},
	{ -- Outland Cup
		zone = 101,
		expansion = 1,
		races = {
			[1] = { -- Hellfire Hustle
				["normal"] = {
					["currencyID"] = 2600,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["advanced"] = {
					["currencyID"] = 2615,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["reverse"] = {
					["currencyID"] = 2630,
					["silverTime"] = 75,
					["goldTime"] = 72,
				},
				["questID"] = 77102,
				["mapPOI"] = 7589,
			},
			[2] = { -- Coilfang Caper
				["normal"] = {
					["currencyID"] = 2601,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["advanced"] = {
					["currencyID"] = 2616,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["reverse"] = {
					["currencyID"] = 2631,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["questID"] = 77169,
				["mapPOI"] = 7590,
			},
			[3] = { -- Blade's Edge Brawl
				["normal"] = {
					["currencyID"] = 2602,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["advanced"] = {
					["currencyID"] = 2617,
					["silverTime"] = 75,
					["goldTime"] = 72,
				},
				["reverse"] = {
					["currencyID"] = 2632,
					["silverTime"] = 78,
					["goldTime"] = 75,
				},
				["questID"] = 77205,
				["mapPOI"] = 7591,
			},
			[4] = { -- Telaar Tear
				["normal"] = {
					["currencyID"] = 2603,
					["silverTime"] = 69,
					["goldTime"] = 64,
				},
				["advanced"] = {
					["currencyID"] = 2618,
					["silverTime"] = 60,
					["goldTime"] = 57,
				},
				["reverse"] = {
					["currencyID"] = 2633,
					["silverTime"] = 61,
					["goldTime"] = 58,
				},
				["questID"] = 77238,
				["mapPOI"] = 7592,
			},
			[5] = { -- Razorthorn Rise Rush
				["normal"] = {
					["currencyID"] = 2604,
					["silverTime"] = 72,
					["goldTime"] = 67,
				},
				["advanced"] = {
					["currencyID"] = 2619,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["reverse"] = {
					["currencyID"] = 2634,
					["silverTime"] = 57,
					["goldTime"] = 54,
				},
				["questID"] = 77260,
				["mapPOI"] = 7593,
			},
			[6] = { -- Auchindoun Coaster
				["normal"] = {
					["currencyID"] = 2605,
					["silverTime"] = 78,
					["goldTime"] = 73,
				},
				["advanced"] = {
					["currencyID"] = 2620,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["reverse"] = {
					["currencyID"] = 2635,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["questID"] = 77264,
				["mapPOI"] = 7594,
			},
			[7] = { -- Tempest Keep Sweep
				["normal"] = {
					["currencyID"] = 2606,
					["silverTime"] = 105,
					["goldTime"] = 100,
				},
				["advanced"] = {
					["currencyID"] = 2621,
					["silverTime"] = 90,
					["goldTime"] = 87,
				},
				["reverse"] = {
					["currencyID"] = 2636,
					["silverTime"] = 91,
					["goldTime"] = 88,
				},
				["questID"] = 77278,
				["mapPOI"] = 7595,
			},
			[8] = { -- Shattrath City Sashay
				["normal"] = {
					["currencyID"] = 2607,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["advanced"] = {
					["currencyID"] = 2622,
					["silverTime"] = 68,
					["goldTime"] = 65,
				},
				["reverse"] = {
					["currencyID"] = 2637,
					["silverTime"] = 69,
					["goldTime"] = 66,
				},
				["questID"] = 77322,
				["mapPOI"] = 7596,
			},
			[9] = { -- Shadowmoon Slam
				["normal"] = {
					["currencyID"] = 2608,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["advanced"] = {
					["currencyID"] = 2623,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["reverse"] = {
					["currencyID"] = 2638,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["questID"] = 77346,
				["mapPOI"] = 7597,
			},
			[10] = { -- Eco-Dome Excursion
				["normal"] = {
					["currencyID"] = 2609,
					["silverTime"] = 120,
					["goldTime"] = 115,
				},
				["advanced"] = {
					["currencyID"] = 2624,
					["silverTime"] = 112,
					["goldTime"] = 109,
				},
				["reverse"] = {
					["currencyID"] = 2639,
					["silverTime"] = 113,
					["goldTime"] = 110,
				},
				["questID"] = 77398,
				["mapPOI"] = 7598,
			},
			[11] = { -- Warmaul Wingding
				["normal"] = {
					["currencyID"] = 2610,
					["silverTime"] = 85,
					["goldTime"] = 80,
				},
				["advanced"] = {
					["currencyID"] = 2625,
					["silverTime"] = 75,
					["goldTime"] = 72,
				},
				["reverse"] = {
					["currencyID"] = 2640,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["questID"] = 77589,
				["mapPOI"] = 7599,
			},
			[12] = { -- Skettis Scramble
				["normal"] = {
					["currencyID"] = 2611,
					["silverTime"] = 75,
					["goldTime"] = 70,
				},
				["advanced"] = {
					["currencyID"] = 2626,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["reverse"] = {
					["currencyID"] = 2641,
					["silverTime"] = 66,
					["goldTime"] = 63,
				},
				["questID"] = 77645,
				["mapPOI"] = 7600,
			},
			[13] = { -- Fel Pit Fracas
				["normal"] = {
					["currencyID"] = 2612,
					["silverTime"] = 82,
					["goldTime"] = 77,
				},
				["advanced"] = {
					["currencyID"] = 2627,
					["silverTime"] = 76,
					["goldTime"] = 73,
				},
				["reverse"] = {
					["currencyID"] = 2642,
					["silverTime"] = 79,
					["goldTime"] = 76,
				},
				["questID"] = 77684,
				["mapPOI"] = 7601,
			},
		},
	},
	{ -- Northrend Cup
		zone = 113,
		expansion = 2,
		races = {
			[1] = { -- Scalawag Slither
				["normal"] = {
					["currencyID"] = 2720,
					["silverTime"] = 78,
					["goldTime"] = 73,
				},
				["advanced"] = {
					["currencyID"] = 2738,
					["silverTime"] = 71,
					["goldTime"] = 68,
				},
				["reverse"] = {
					["currencyID"] = 2756,
					["silverTime"] = 73,
					["goldTime"] = 70,
				},
				["questID"] = 78301,
				["mapPOI"] = 7689,
			},
			[2] = { -- Daggercap Dart
				["normal"] = {
					["currencyID"] = 2721,
					["silverTime"] = 82,
					["goldTime"] = 77,
				},
				["advanced"] = {
					["currencyID"] = 2739,
					["silverTime"] = 79,
					["goldTime"] = 76,
				},
				["reverse"] = {
					["currencyID"] = 2757,
					["silverTime"] = 79,
					["goldTime"] = 76,
				},
				["questID"] = 78325,
				["mapPOI"] = 7690,
			},
			[3] = { -- Blackriver Burble
				["normal"] = {
					["currencyID"] = 2722,
					["silverTime"] = 80,
					["goldTime"] = 75,
				},
				["advanced"] = {
					["currencyID"] = 2740,
					["silverTime"] = 70,
					["goldTime"] = 67,
				},
				["reverse"] = {
					["currencyID"] = 2758,
					["silverTime"] = 74,
					["goldTime"] = 71,
				},
				["questID"] = 78334,
				["mapPOI"] = 7691,
			},
			[4] = { -- Zul'Drak Zephyr
				["normal"] = {
					["currencyID"] = 2723,
					["silverTime"] = 70,
					["goldTime"] = 65,
				},
				["advanced"] = {
					["currencyID"] = 2741,
					["silverTime"] = 65,
					["goldTime"] = 62,
				},
				["reverse"] = {
					["currencyID"] = 2759,
					["silverTime"] = 70,
					["goldTime"] = 67,
				},
				["questID"] = 78346,
				["mapPOI"] = 7692,
			},
			[5] = { -- Makers' Marathon
				["normal"] = {
					["currencyID"] = 2724,
					["silverTime"] = 105,
					["goldTime"] = 100,
				},
				["advanced"] = {
					["currencyID"] = 2742,
					["silverTime"] = 96,
					["goldTime"] = 93,
				},
				["reverse"] = {
					["currencyID"] = 2760,
					["silverTime"] = 101,
					["goldTime"] = 98,
				},
				["questID"] = 78389,
				["mapPOI"] = 7693,
			},
			[6] = { -- Crystalsong Crisis
				["normal"] = {
					["currencyID"] = 2725,
					["silverTime"] = 102,
					["goldTime"] = 97,
				},
				["advanced"] = {
					["currencyID"] = 2743,
					["silverTime"] = 97,
					["goldTime"] = 94,
				},
				["reverse"] = {
					["currencyID"] = 2761,
					["silverTime"] = 99,
					["goldTime"] = 96,
				},
				["questID"] = 78441,
				["mapPOI"] = 7694,
			},
			[7] = { -- Dragonblight Dragon Flight
				["normal"] = {
					["currencyID"] = 2726,
					["silverTime"] = 120,
					["goldTime"] = 115,
				},
				["advanced"] = {
					["currencyID"] = 2744,
					["silverTime"] = 113,
					["goldTime"] = 110,
				},
				["reverse"] = {
					["currencyID"] = 2762,
					["silverTime"] = 113,
					["goldTime"] = 110,
				},
				["questID"] = 78454,
				["mapPOI"] = 7695,
			},
			[8] = { -- Citadel Sortie
				["normal"] = {
					["currencyID"] = 2727,
					["silverTime"] = 115,
					["goldTime"] = 110,
				},
				["advanced"] = {
					["currencyID"] = 2745,
					["silverTime"] = 106,
					["goldTime"] = 103,
				},
				["reverse"] = {
					["currencyID"] = 2763,
					["silverTime"] = 107,
					["goldTime"] = 104,
				},
				["questID"] = 78499,
				["mapPOI"] = 7696,
			},
			[9] = { -- Sholazar Spree
				["normal"] = {
					["currencyID"] = 2728,
					["silverTime"] = 93,
					["goldTime"] = 88,
				},
				["advanced"] = {
					["currencyID"] = 2746,
					["silverTime"] = 88,
					["goldTime"] = 85,
				},
				["reverse"] = {
					["currencyID"] = 2764,
					["silverTime"] = 88,
					["goldTime"] = 85,
				},
				["questID"] = 78558,
				["mapPOI"] = 7697,
			},
			[10] = { -- Geothermal Jaunt
				["normal"] = {
					["currencyID"] = 2729,
					["silverTime"] = 50,
					["goldTime"] = 45,
				},
				["advanced"] = {
					["currencyID"] = 2747,
					["silverTime"] = 40,
					["goldTime"] = 37,
				},
				["reverse"] = {
					["currencyID"] = 2765,
					["silverTime"] = 40,
					["goldTime"] = 37,
				},
				["questID"] = 78608,
				["mapPOI"] = 7698,
			},
			[11] = { -- Gundrak Fast Track
				["normal"] = {
					["currencyID"] = 2730,
					["silverTime"] = 65,
					["goldTime"] = 60,
				},
				["advanced"] = {
					["currencyID"] = 2748,
					["silverTime"] = 60,
					["goldTime"] = 57,
				},
				["reverse"] = {
					["currencyID"] = 2766,
					["silverTime"] = 60,
					["goldTime"] = 57,
				},
				["questID"] = 79268,
				["mapPOI"] = 7699,
			},
			[12] = { -- Coldarra Climb
				["normal"] = {
					["currencyID"] = 2731,
					["silverTime"] = 62,
					["goldTime"] = 57,
				},
				["advanced"] = {
					["currencyID"] = 2749,
					["silverTime"] = 56,
					["goldTime"] = 53,
				},
				["reverse"] = {
					["currencyID"] = 2767,
					["silverTime"] = 58,
					["goldTime"] = 55,
				},
				["questID"] = 79272,
				["mapPOI"] = 7700,
			},
		},
	},
};