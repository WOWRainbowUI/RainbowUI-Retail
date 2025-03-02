local _, DR = ...

local PLACEHOLDER = "[PH]"

DR.DragonRaceZones = {
	-- The War Within
	[1] = 2248, -- Isle of Dorn
	[2] = 2214, -- The Ringing Deeps
	[3] = 2215, --  Hallowfall
	[4] = 2255, -- Azj-Kahet
	[5] = 2346, -- Undermine

	-- Dragonflight
	[6] = 2022, -- Waking Shores
	[7] = 2023, -- Ohn'ahran Plains
	[8] = 2024, -- The Azure Span
	[9] = 2025, -- Thaldraszus
	[10] = 2151, -- Forbidden Reach
	[11] = 2133, -- Zaralek Caverns
	[12] = 2200, -- Emerald Dream

	-- Cup
	[13] = 12,	-- Kalimdor
	[14] = 13,	-- Eastern Kingdoms
	[15] = 101,	-- Outland
	[16] = 113,	-- Northrend
};

-- icon file IDs for WQ Locations 
DR.ZoneIcons = {
	-- The War Within
	[2248] = 5770811, -- Isle of Dorn
	[2214] = 5770812, -- The Ringing Deeps
	[2215] = 5770810, -- Hallowfall
	[2255] = 5770809, -- Azj-Kahet

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
	81806,
	81799,
	81805,
	81804,
	81803,
	81802,

	-- The Ringing Deeps
	81808,
	81810,
	81813,
	81807,
	81812,
	81811,

	-- Hallowfall
	81815,
	81822,
	81819,
	81818,
	81816,
	81823,

	-- Azj-Kahet
	81827,
	81825,
	81831,
	81824,
	81829,
	81828,

	-- Undermine



--Dragonflight
	-- The Waking Shores
	70415,
	70410,
	70416,
	70382,
	70412,
	70417,
	70413,
	70418,

	-- Ohn'ahran Plains
	70420,
	70424,
	70712,
	70421,
	70423,
	70422,
	70419,

	-- The Azure Span
	70425,
	70430,
	70429,
	70427,
	70426,
	70428,

	-- Thaldraszus
	70436,
	70432,
	70431,
	70435,
	70434,
	70433,

	-- The Forbidden Reach
	73083,
	73084,
	73078,
	73079,
	73080,
	73082,

	-- Zaralek Cavern
	75122,
	75119,
	75123,
	75121,
	75120,
	75124,

	-- Emerald Dream
	78434,
	78438,
	78435,
	78437,
	78436,
	78439,
};

DR.DragonRaceCurrencies = {
-- The War Within
-- Isle of Dorn - 2248
	2923, 2929, 2935,					 -- Dornogal Drift
	2924, 2930, 2936,					 -- Storm's Watch Survey
	2925, 2931, 2937,					 -- Basin Bypass
	2926, 2932, 2938,					 -- The Wold Ways
	2927, 2933, 2939,					 -- Thunderhead Trail
	2928, 2934, 2940,					 -- Orecreg's Doglegs

-- The Ringing Deeps - 2214
	2941, 2947, 2953,					 -- Earthenworks Weave
	2942, 2948, 2954,					 -- Ringing Deeps Ramble
	2943, 2949, 2955,					 -- Chittering Concourse
	2944, 2950, 2956,					 -- Cataract River Cruise
	2945, 2951, 2957,					 -- Taelloch Twist
	2946, 2952, 2958,					 -- Opportunity Point Amble

-- Hallowfall - 2215
	2959, 2965, 2971,					 -- Dunelle's Detour
	2960, 2966, 2972,					 -- Tenir's Traversal
	2961, 2967, 2973,					 -- Light's Redoubt Descent
	2962, 2968, 2974,					 -- Stillstone Slalom
	2963, 2969, 2975,					 -- Mereldar Meander
	2964, 2970, 2976,					 -- Velhan's Venture

-- Azj-Kahet - 2255
	2977, 2983, 2989,					 -- City of Threads Twist
	2978, 2984, 2990,					 -- Maddening Deep Dip
	2979, 2985, 2991,					 -- The Weaver's Wing
	2980, 2986, 2992,					 -- Rak-Ahat Rush
	2981, 2987, 2993,					 -- Pit Plunge
	2982, 2988, 2994,					 -- Siegehold Scuttle



--Dragonflight
-- Waking Shores - 2022
	2042, 2044, 2154, 2421, 2422, 2664,	 -- Ruby Lifeshrine Loop
	2048, 2049, 2176, 2423, 2424,		 -- Wild Preserve Slalom
	2052, 2053, 2177, 2425, 2426,		 -- Emberflow Flight
	2054, 2055, 2178, 2427, 2428,		 -- Apex Canopy River Run
	2056, 2057, 2179, 2429, 2430,		 -- Uktulut Coaster
	2058, 2059, 2180, 2431, 2432,		 -- Wingrest Roundabout
	2046, 2047, 2181, 2433, 2434,		 -- Flashfrost Flyover
	2050, 2051, 2182, 2435, 2436,		 -- Wild Preserve Circuit

-- Ohn'ahran Plains - 2023
	2060, 2061, 2183, 2437, 2439,		 -- Sundapple Copse Circuit
	2062, 2063, 2184, 2440, 2441, 2665,	 -- Fen Flythrough
	2064, 2065, 2185, 2442, 2443,		 -- Ravine River Run
	2066, 2067, 2186, 2444, 2445,		 -- Emerald Gardens Ascent
	2069,		2446,					 -- Maruukai Dash
	2070,		2447,					 -- Mirror of the Sky Dash
	2119, 2120, 2187, 2448, 2449,		 -- River Rapids Route

-- Azure Span - 2024
	2074, 2075, 2188, 2450, 2451,		 -- The Azure Span Sprint
	2076, 2077, 2189, 2452, 2453,		 -- The Azure Span Slalom
	2078, 2079, 2190, 2454, 2455, 2666,	 -- The Vakthros Ascent
	2083, 2084, 2191, 2456, 2457,		 -- Iskaara Tour
	2085, 2086, 2192, 2458, 2459,		 -- Frostland Flyover
	2089, 2090, 2193, 2460, 2461,		 -- Archive Ambit

-- Thaldraszus - 2025
	2080, 2081, 2194, 2462, 2463,		 -- The Flowing Forest Flight
	2092, 2093, 2195, 2464, 2465, 2667,	 -- Tyrhold Trial
	2096, 2097, 2196, 2466, 2467,		 -- Cliffside Circuit
	2098, 2099, 2197, 2468, 2469,		 -- Academy Ascent
	2101, 2102, 2198, 2470, 2471,		 -- Garden Gallivant
	2103, 2104, 2199, 2472, 2473,		 -- Caverns Criss-Cross

-- Forbidden Reach - 2151
	2201, 2207, 2213, 2474, 2475, 2668,	 -- Stormsunder Crater Circuit
	2202, 2208, 2214, 2476, 2477,		 -- Morqut Ascent
	2203, 2209, 2215, 2478, 2479,		 -- Aerie Chasm
	2204, 2210, 2216, 2480, 2481,		 -- Southern Reach Route
	2205, 2211, 2217, 2482, 2483,		 -- Caldera Coaster
	2206, 2212, 2218, 2484, 2485,		 -- Forbidden Reach Rush

-- Zaralek Caverns - 2133
	2246, 2252, 2258, 2486, 2487, 2669,	 -- Crystal Circuit
	2247, 2253, 2259, 2488, 2489,		 -- Caldera Cruise
	2248, 2254, 2260, 2490, 2491,		 -- Brimstone Scramble
	2249, 2255, 2261, 2492, 2493,		 -- Shimmering Slalom
	2250, 2256, 2262, 2494, 2495,		 -- Loamm Roamm
	2251, 2257, 2263, 2496, 2497,		 -- Sulfur Sprint

-- Emerald Dream - 2200
	2676, 2682, 2688, 2694, 2695,		 -- Ysera Invitational
	2677, 2683, 2689, 2696, 2697,		 -- Smoldering Sprint
	2678, 2684, 2690, 2698, 2699,		 -- Viridescent Venture
	2679, 2685, 2691, 2700, 2701,		 -- Shoreline Switchback
	2680, 2686, 2692, 2702, 2703,		 -- Canopy Concours
	2681, 2687, 2693, 2704, 2705,		 -- Emerald Amble

-- Kalimdor Cup - 12
	2312, 2342, 2372, 2498, 2499, -- Felwood Flyover
	2313, 2343, 2373, 2500, 2501, -- Winter Wander
	2314, 2344, 2374, 2502, 2503, -- Nordrassil Spiral
	2315, 2345, 2375, 2504, 2505, -- Hyjal Hotfoot
	2316, 2346, 2376, 2506, 2507, -- Rocketway Ride
	2317, 2347, 2377, 2508, 2509, -- Ashenvale Ambit
	2318, 2348, 2378, 2510, 2511, -- Durotar Tour
	2319, 2349, 2379, 2512, 2513, -- Webwinder Weave
	2320, 2350, 2380, 2514, 2515, -- Desolace Drift
	2321, 2351, 2381, 2516, 2517, -- Great Divide Dive
	2322, 2352, 2382, 2518, 2519, -- Razorfen Roundabout
	2323, 2353, 2383, 2520, 2521, -- Thousand Needles Thread
	2324, 2354, 2384, 2522, 2523, -- Feralas Ruins Ramble
	2325, 2355, 2385, 2524, 2525, -- Ahn'Qiraj Circuit
	2326, 2356, 2386, 2526, 2527, -- Uldum Tour
	2327, 2357, 2387, 2528, 2529, -- Un'Goro Crater Circuit

-- Eastern Kingdoms Cup - 13
	2536, 2552, 2568, -- Gilneas Gambit
	2537, 2553, 2569, -- Loch Modan Loop
	2538, 2554, 2570, -- Searing Slalom
	2539, 2555, 2571, -- Twilight Terror
	2540, 2556, 2572, -- Deadwind Derby
	2541, 2557, 2573, -- Elwynn Forest Flash
	2542, 2558, 2574, -- Gurubashi Gala
	2543, 2559, 2575, -- Ironforge Interceptor
	2544, 2560, 2576, -- Blasted Lands Bolt
	2545, 2561, 2577, -- Plaguelands Plunge
	2546, 2562, 2578, -- Booty Bay Blast
	2547, 2563, 2579, -- Fuselight Night Flight
	2548, 2564, 2580, -- Krazzworks Klash
	2549, 2565, 2581, -- Redridge Rally

-- Outland Cup - 101
	2600, 2615, 2630, -- Hellfire Hustle
	2601, 2616, 2631, -- Coilfang Caper
	2602, 2617, 2632, -- Blade's Edge Brawl
	2603, 2618, 2633, -- Telaar Tear
	2604, 2619, 2634, -- Razorthorn Rise Rush
	2605, 2620, 2635, -- Auchindoun Coaster
	2606, 2621, 2636, -- Tempest Keep Sweep
	2607, 2622, 2637, -- Shattrath City Sashay
	2608, 2623, 2638, -- Shadowmoon Slam
	2609, 2624, 2639, -- Eco-Dome Excursion
	2610, 2625, 2640, -- Warmaul Wingding
	2611, 2626, 2641, -- Skettis Scramble
	2612, 2627, 2642, -- Fel Pit Fracas

-- Northrend Cup - 113
	2720, 2738, 2756, -- Scalawag Slither
	2721, 2739, 2757, -- Daggercap Dart
	2722, 2740, 2758, -- Blackriver Burble
	2723, 2741, 2759, -- Zul'Drak Zephyr
	2724, 2742, 2760, -- Makers' Marathon
	2725, 2743, 2761, -- Crystalsong Crisis
	2726, 2744, 2762, -- Dragonblight Dragon Flight
	2727, 2745, 2763, -- Citadel Sortie
	2728, 2746, 2764, -- Sholazar Spree
	2729, 2747, 2765, -- Geothermal Jaunt
	2730, 2748, 2766, -- Gundrak Fast Track
	2731, 2749, 2767, -- Coldarra Climb
};



DR.RaceData = {
-- The War Within
-- Isle of Dorn
-- Isle of Dorn
	[1] = {

	 -- Dornogal Drift
		[1] = {
			["currencyID"] = 2923,
			["silverTime"] = 53,
			["goldTime"] = 48,
			["questID"] = 80219,
			["mapPOI"] = 7793,
		},
		[2] = {
			["currencyID"] = 2929,
			["silverTime"] = 46,
			["goldTime"] = 43,
			["questID"] = 80219,
			["mapPOI"] = 7793,
		},
		[3] = {
			["currencyID"] = 2935,
			["silverTime"] = 46,
			["goldTime"] = 43,
			["questID"] = 80219,
			["mapPOI"] = 7793,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7793,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7793,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7793,
		},
	 -- Storm's Watch Survey
		[7] = {
			["currencyID"] = 2924,
			["silverTime"] = 68,
			["goldTime"] = 63,
			["questID"] = 80220,
			["mapPOI"] = 7794,
		},
		[8] = {
			["currencyID"] = 2930,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 80220,
			["mapPOI"] = 7794,
		},
		[9] = {
			["currencyID"] = 2936,
			["silverTime"] = 65,
			["goldTime"] = 62, -- was 60 in beta
			["questID"] = 80220,
			["mapPOI"] = 7794,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7794,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7794,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7794,
		},
	 -- Basin Bypass
		[13] = {
			["currencyID"] = 2925,
			["silverTime"] = 63,
			["goldTime"] = 58,
			["questID"] = 80221,
			["mapPOI"] = 7795,
		},
		[14] = {
			["currencyID"] = 2931,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 80221,
			["mapPOI"] = 7795,
		},
		[15] = {
			["currencyID"] = 2937,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 80221,
			["mapPOI"] = 7795,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7795,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7795,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7795,
		},
	-- The Wold Ways
		[19] = {
			["currencyID"] = 2926,
			["silverTime"] = 73,
			["goldTime"] = 68,
			["questID"] = 80222,
			["mapPOI"] = 7796,
		},
		[20] = {
			["currencyID"] = 2932,
			["silverTime"] = 71,
			["goldTime"] = 68,
			["questID"] = 80222,
			["mapPOI"] = 7796,
		},
		[21] = {
			["currencyID"] = 2938,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 80222,
			["mapPOI"] = 7796,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7796,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7796,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7796,
		},
	 -- Thunderhead Trail
		[25] = {
			["currencyID"] = 2927,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 80223,
			["mapPOI"] = 7797,
		},
		[26] = {
			["currencyID"] = 2933,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 80223,
			["mapPOI"] = 7797,
		},
		[27] = {
			["currencyID"] = 2939,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 80223,
			["mapPOI"] = 7797,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7797,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7797,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7797,
		},
	 -- Orecreg's Doglegs
		[31] = {
			["currencyID"] = 2928,
			["silverTime"] = 70,
			["goldTime"] = 65,
			["questID"] = 80224,
			["mapPOI"] = 7798,
		},
		[32] = {
			["currencyID"] = 2934,
			["silverTime"] = 64,
			["goldTime"] = 61,
			["questID"] = 80224,
			["mapPOI"] = 7798,
		},
		[33] = {
			["currencyID"] = 2940,
			["silverTime"] = 64,
			["goldTime"] = 61,
			["questID"] = 80224,
			["mapPOI"] = 7798,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7798,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7798,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7798,
		},
	},

	-- The Ringing Deeps
 	-- Earthenworks Weave
	[2] = {
		[1] = {
			["currencyID"] = 2941,
			["silverTime"] = 57,
			["goldTime"] = 52,
			["questID"] = 80237,
			["mapPOI"] = 7799,
		},

		[2] = {
			["currencyID"] = 2947,
			["silverTime"] = 52,
			["goldTime"] = 49,
			["questID"] = 80237,
			["mapPOI"] = 7799,
		},

		[3] = {
			["currencyID"] = 2953,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 80237,
			["mapPOI"] = 7799,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7799,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7799,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7799,
		},
	 -- Ringing Deeps Ramble
	
		[7] = {
			["currencyID"] = 2942,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 80238,
			["mapPOI"] = 7800,
		},
		[8] = {
			["currencyID"] = 2948,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 80238,
			["mapPOI"] = 7800,
		},
		[9] = {
			["currencyID"] = 2954,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 80238,
			["mapPOI"] = 7800,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7800,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7800,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7800,
		},

	 -- Chittering Concourse
		[13] = {
			["currencyID"] = 2943,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 80239,
			["mapPOI"] = 7801,
		},
		[14] = {
			["currencyID"] = 2949,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 80239,
			["mapPOI"] = 7801,
		},
		[15] = {
			["currencyID"] = 2955,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 80239,
			["mapPOI"] = 7801,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7801,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7801,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7801,
		},

	 -- Cataract River Cruise
		[19] = {
			["currencyID"] = 2944,
			["silverTime"] = 65,
			["goldTime"] = 60,
			["questID"] = 80240,
			["mapPOI"] = 7802,
		},
		[20] = {
			["currencyID"] = 2950,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 80240,
			["mapPOI"] = 7802,
		},
		[21] = {
			["currencyID"] = 2956,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 80240,
			["mapPOI"] = 7802,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7802,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7802,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7802,
		},

	 -- Taelloch Twist
		[25] = {
			["currencyID"] = 2945,
			["silverTime"] = 52,
			["goldTime"] = 47,
			["questID"] = 80242,
			["mapPOI"] = 7803,
		},
		[26] = {
			["currencyID"] = 2951,
			["silverTime"] = 46,
			["goldTime"] = 43,
			["questID"] = 80242,
			["mapPOI"] = 7803,
		},
		[27] = {
			["currencyID"] = 2957,
			["silverTime"] = 47,
			["goldTime"] = 44,
			["questID"] = 80242,
			["mapPOI"] = 7803,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7803,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7803,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7803,
		},

	 -- Opportunity Point Amble
		[31] = {
			["currencyID"] = 2946,
			["silverTime"] = 82,
			["goldTime"] = 77,
			["questID"] = 80243,
			["mapPOI"] = 7804,
		},
		[32] = {
			["currencyID"] = 2952,
			["silverTime"] = 74,
			["goldTime"] = 71,
			["questID"] = 80243,
			["mapPOI"] = 7804,
		},
		[33] = {
			["currencyID"] = 2958,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 80243,
			["mapPOI"] = 7804,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7804,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7804,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7804,
		},
	},


-- Hallowfall

	[3] = {
	 -- Dunelle's Detour
		[1] = {
			["currencyID"] = 2959,
			["silverTime"] = 70,
			["goldTime"] = 65,
			["questID"] = 80256,
			["mapPOI"] = 7805,
		},
		[2] = {
			["currencyID"] = 2965,
			["silverTime"] = 65,
			["goldTime"] = 62,
			["questID"] = 80256,
			["mapPOI"] = 7805,
		},
		[3] = {
			["currencyID"] = 2971,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 80256,
			["mapPOI"] = 7805,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7805,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7805,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7805,
		},
	 -- Tenir's Traversal
		[7] = {
			["currencyID"] = 2960,
			["silverTime"] = 70,
			["goldTime"] = 65,
			["questID"] = 80257,
			["mapPOI"] = 7806,
		},
		[8] = {
			["currencyID"] = 2966,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 80257,
			["mapPOI"] = 7806,
		},
		[9] = {
			["currencyID"] = 2972,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 80257,
			["mapPOI"] = 7806,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7806,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7806,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7806,
		},

	 -- Light's Redoubt Descent
		[13] = {
			["currencyID"] = 2961,
			["silverTime"] = 68,
			["goldTime"] = 63,
			["questID"] = 80258,
			["mapPOI"] = 7807,
		},
		[14] = {
			["currencyID"] = 2967,
			["silverTime"] = 65,
			["goldTime"] = 62,
			["questID"] = 80258,
			["mapPOI"] = 7807,
		},
		[15] = {
			["currencyID"] = 2973,
			["silverTime"] = 65,
			["goldTime"] = 62,
			["questID"] = 80258,
			["mapPOI"] = 7807,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7807,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7807,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7807,
		},

	-- Stillstone Slalmom
		[19] = {
			["currencyID"] = 2962,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 80259,
			["mapPOI"] = 7808,
		},
		[20] = {
			["currencyID"] = 2968,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 80259,
			["mapPOI"] = 7808,
		},
		[21] = {
			["currencyID"] = 2974,
			["silverTime"] = 59,
			["goldTime"] = 56,
			["questID"] = 80259,
			["mapPOI"] = 7808,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7808,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7808,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7808,
		},

	-- Mereldar Meander 
		[25] = {
			["currencyID"] = 2963,
			["silverTime"] = 81,
			["goldTime"] = 76,
			["questID"] = 80260,
			["mapPOI"] = 7809,
		},
		[26] = {
			["currencyID"] = 2969,
			["silverTime"] = 74,
			["goldTime"] = 71,
			["questID"] = 80260,
			["mapPOI"] = 7809,
		},
		[27] = {
			["currencyID"] = 2975,
			["silverTime"] = 74,
			["goldTime"] = 71,
			["questID"] = 80260,
			["mapPOI"] = 7809,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7809,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7809,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7809,
		},

	 -- Velhan's Venture
		[31] = {
			["currencyID"] = 2964,
			["silverTime"] = 60,
			["goldTime"] = 55,
			["questID"] = 80261,
			["mapPOI"] = 7810,
		},
		[32] = {
			["currencyID"] = 2970,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 80261,
			["mapPOI"] = 7810,
		},
		[33] = {
			["currencyID"] = 2976,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 80261,
			["mapPOI"] = 7810,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7810,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7810,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7810,
		},
	},
 
-- Azj-Kahet 
	[4] = {
	 -- City of Threads Twist
		[1] = {
			["currencyID"] = 2977,
			["silverTime"] = 83,
			["goldTime"] = 78,
			["questID"] = 80277,
			["mapPOI"] = 7811,
		},
		[2] = {
			["currencyID"] = 2983,
			["silverTime"] = 77,
			["goldTime"] = 74,
			["questID"] = 80277,
			["mapPOI"] = 7811,
		},
		[3] = {
			["currencyID"] = 2989,
			["silverTime"] = 77,
			["goldTime"] = 74,
			["questID"] = 80277,
			["mapPOI"] = 7811,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7811,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7811,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7811,
		},

	 -- Maddening Deep Dip

		[7] = {
			["currencyID"] = 2978,
			["silverTime"] = 63,
			["goldTime"] = 58,
			["questID"] = 80278,
			["mapPOI"] = 7812,
		},
		[8] = {
			["currencyID"] = 2984,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 80278,
			["mapPOI"] = 7812,
		},
		[9] = {
			["currencyID"] = 2990,
			["silverTime"] = 59,
			["goldTime"] = 56,
			["questID"] = 80278,
			["mapPOI"] = 7812,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7812,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7812,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7812,
		},

	-- the Weaver's Wing
		[13] = {
			["currencyID"] = 2979,
			["silverTime"] = 59,
			["goldTime"] = 54,
			["questID"] = 80279,
			["mapPOI"] = 7813,
		},
		[14] = {
			["currencyID"] = 2985,
			["silverTime"] = 54,
			["goldTime"] = 51,
			["questID"] = 80279,
			["mapPOI"] = 7813,
		},
		[15] = {
			["currencyID"] = 2991,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 80279,
			["mapPOI"] = 7813,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7813,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7813,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7813,
		},

	 -- Rak-Ahat Rush
		[19] = {
			["currencyID"] = 2980,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 80280,
			["mapPOI"] = 7814,
		},
		[20] = {
			["currencyID"] = 2986,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 80280,
			["mapPOI"] = 7814,
		},
		[21] = {
			["currencyID"] = 2992,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 80280,
			["mapPOI"] = 7814,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7814,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7814,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7814,
		},

	 -- Pit Plunge
		[25] = {
			["currencyID"] = 2981,
			["silverTime"] = 68,
			["goldTime"] = 63,
			["questID"] = 80281,
			["mapPOI"] = 7815,
		},
		[26] = {
			["currencyID"] = 2987,
			["silverTime"] = 64,
			["goldTime"] = 61,
			["questID"] = 80281,
			["mapPOI"] = 7815,
		},
		[27] = {
			["currencyID"] = 2993,
			["silverTime"] = 64,
			["goldTime"] = 61,
			["questID"] = 80281,
			["mapPOI"] = 7815,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7815,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7815,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7815,
		},

	 -- Siegehold Scuttle
		[31] = {
			["currencyID"] = 2982,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 80282,
			["mapPOI"] = 7816,
		},
		[32] = {
			["currencyID"] = 2988,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 80282,
			["mapPOI"] = 7816,
		},
		[33] = {
			["currencyID"] = 2994,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 80282,
			["mapPOI"] = 7816,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7816,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7816,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7816,
		},
	},

	[5] = {
		-- R1 -- Skyrocketing Race
		[1] = {
			["currencyID"] = 3119,
			["silverTime"] = 42,
			["goldTime"] = 32,
			["questID"] = 85071,
			["mapPOI"] = 8144,
		},
		[2] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8144,
		},
		[3] = {
			["currencyID"] = 3121,
			["silverTime"] = 42,
			["goldTime"] = 32,
			["questID"] = 85071,
			["mapPOI"] = 8144,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8144,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8144,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8144,
		},

		-- R2
		[7] = {
			["currencyID"] = 3122,
			["silverTime"] = 43,
			["goldTime"] = 33,
			["questID"] = 85097,
			["mapPOI"] = 8145,
		},
		[8] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8145,
		},
		[9] = {
			["currencyID"] = 3123,
			["silverTime"] = 43,
			["goldTime"] = 33,
			["questID"] = 85097,
			["mapPOI"] = 8145,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8145,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8145,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8145,
		},

		-- R3
		[13] = {
			["currencyID"] = 3124,
			["silverTime"] = 46,
			["goldTime"] = 36,
			["questID"] = 85099,
			["mapPOI"] = 8146,
		},
		[14] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8146,
		},
		[15] = {
			["currencyID"] = 3125,
			["silverTime"] = 46,
			["goldTime"] = 36,
			["questID"] = 85099,
			["mapPOI"] = 8146,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8146,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8146,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8146,
		},

		-- R4
		[19] = {
			["currencyID"] = 3126,
			["silverTime"] = 50,
			["goldTime"] = 40,
			["questID"] = 85101,
			["mapPOI"] = 8147,
		},
		[20] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8147,
		},
		[21] = {
			["currencyID"] = 3127,
			["silverTime"] = 50,
			["goldTime"] = 40,
			["questID"] = 85101,
			["mapPOI"] = 8147,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8147,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8147,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8147,
		},

		-- R5
		[25] = {
			["currencyID"] = 3181,
			["silverTime"] = 40,
			["goldTime"] = 35,
			["questID"] = 85900,
			["mapPOI"] = 8177,
		},
		[26] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8177,
		},
		[27] = {
			["currencyID"] = 3182,
			["silverTime"] = 40,
			["goldTime"] = 35,
			["questID"] = 85900,
			["mapPOI"] = 8177,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8177,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8177,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8177,
		},

		-- R6
		[31] = {
			["currencyID"] = 3183,
			["silverTime"] = 40,
			["goldTime"] = 35,
			["questID"] = 85902,
			["mapPOI"] = 8178,
		},
		[32] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8178,
		},
		[33] = {
			["currencyID"] = 3184,
			["silverTime"] = 40,
			["goldTime"] = 35,
			["questID"] = 85902,
			["mapPOI"] = 8178,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8178,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8178,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8178,
		},

		-- R7
		[37] = {
			["currencyID"] = 3185,
			["silverTime"] = 35,
			["goldTime"] = 30,
			["questID"] = 85904,
			["mapPOI"] = 8179,
		},
		[38] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8179,
		},
		[39] = {
			["currencyID"] = 3186,
			["silverTime"] = 35,
			["goldTime"] = 30,
			["questID"] = 85904,
			["mapPOI"] = 8179,
		},
		[40] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8179,
		},
		[41] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8179,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8179,
		},

		-- R8
		[43] = {
			["currencyID"] = 3187,
			["silverTime"] = 38,
			["goldTime"] = 33,
			["questID"] = 85906,
			["mapPOI"] = 8180,
		},
		[44] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8180,
		},
		[45] = {
			["currencyID"] = 3188,
			["silverTime"] = 38,
			["goldTime"] = 33,
			["questID"] = 85906,
			["mapPOI"] = 8180,
		},
		[46] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8180,
		},
		[47] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8180,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 8180,
		},
	},






-- Dragonflight
-- Waking Shores
	--Ruby Lifeshrine Loop
	[6] = {
		[1] = {
			["currencyID"] = 2042,
			["silverTime"] = 56, --56
			["goldTime"] = 56, -- 53
			["questID"] = 66679,
			["mapPOI"] = 7740,
		},
		[2] = {
			["currencyID"] = 2044,
			["silverTime"] = 57,
			["goldTime"] = 52,
			["questID"] = 66679,
			["mapPOI"] = 7740,
		},
		[3] = {
			["currencyID"] = 2154,
			["silverTime"] = 55,
			["goldTime"] = 50,
			["questID"] = 66679,
			["mapPOI"] = 7740,
		},
		[4] = {
			["currencyID"] = 2421,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 66679,
			["mapPOI"] = 7740,
		},
		[5] = {
			["currencyID"] = 2422,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 66679,
			["mapPOI"] = 7740,
		},
		[6] = {
			["currencyID"] = 2664,
			["silverTime"] = 70,
			["goldTime"] = 65,
			["questID"] = 66679,
			["mapPOI"] = 7740,
		},

		--Wild Preserve Slalom
		[7] = {
			["currencyID"] = 2048,
			["silverTime"] = 45,
			["goldTime"] = 42,
			["questID"] = 66721,
			["mapPOI"] = 7742,
		},
		[8] = {
			["currencyID"] = 2049,
			["silverTime"] = 45,
			["goldTime"] = 40,
			["questID"] = 66721,
			["mapPOI"] = 7742,
		},
		[9] = {
			["currencyID"] = 2176,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 66721,
			["mapPOI"] = 7742,
		},
		[10] = {
			["currencyID"] = 2423,
			["silverTime"] = 51,
			["goldTime"] = 48,
			["questID"] = 66721,
			["mapPOI"] = 7742,
		},
		[11] = {
			["currencyID"] = 2424,
			["silverTime"] = 52,
			["goldTime"] = 49,
			["questID"] = 66721,
			["mapPOI"] = 7742,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7742,
		},

		--Emberflow Flight
		[13] = {
			["currencyID"] = 2052,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66727,
			["mapPOI"] = 7743,
		},
		[14] = {
			["currencyID"] = 2053,
			["silverTime"] = 49,
			["goldTime"] = 44,
			["questID"] = 66727,
			["mapPOI"] = 7743,
		},
		[15] = {
			["currencyID"] = 2177,
			["silverTime"] = 50,
			["goldTime"] = 45,
			["questID"] = 66727,
			["mapPOI"] = 7743,
		},
		[16] = {
			["currencyID"] = 2425,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66727,
			["mapPOI"] = 7743,
		},
		[17] = {
			["currencyID"] = 2426,
			["silverTime"] = 54,
			["goldTime"] = 51,
			["questID"] = 66727,
			["mapPOI"] = 7743,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7743,
		},

		--Apex Canopy River Run
		[19] = {
			["currencyID"] = 2054,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 66732,
			["mapPOI"] = 7744,
		},
		[20] = {
			["currencyID"] = 2055,
			["silverTime"] = 50,
			["goldTime"] = 45,
			["questID"] = 66732,
			["mapPOI"] = 7744,
		},
		[21] = {
			["currencyID"] = 2178,
			["silverTime"] = 53,
			["goldTime"] = 48,
			["questID"] = 66732,
			["mapPOI"] = 7744,
		},
		[22] = {
			["currencyID"] = 2427,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 66732,
			["mapPOI"] = 7744,
		},
		[23] = {
			["currencyID"] = 2428,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 66732,
			["mapPOI"] = 7744,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7744,
		},

		--Uktulut Coaster
		[25] = {
			["currencyID"] = 2056,
			["silverTime"] = 48,
			["goldTime"] = 45,
			["questID"] = 66777,
			["mapPOI"] = 7745,
		},
		[26] = {
			["currencyID"] = 2057,
			["silverTime"] = 45,
			["goldTime"] = 40,
			["questID"] = 66777,
			["mapPOI"] = 7745,
		},
		[27] = {
			["currencyID"] = 2179,
			["silverTime"] = 48,
			["goldTime"] = 43,
			["questID"] = 66777,
			["mapPOI"] = 7745,
		},
		[28] = {
			["currencyID"] = 2429,
			["silverTime"] = 49,
			["goldTime"] = 46,
			["questID"] = 66777,
			["mapPOI"] = 7745,
		},
		[29] = {
			["currencyID"] = 2430,
			["silverTime"] = 51,
			["goldTime"] = 48,
			["questID"] = 66777,
			["mapPOI"] = 7745,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7745,
		},
		
		--Wingrest Roundabout
		[31] = {
			["currencyID"] = 2058,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 66786,
			["mapPOI"] = 7746,
		},
		[32] = {
			["currencyID"] = 2059,
			["silverTime"] = 58,
			["goldTime"] = 53,
			["questID"] = 66786,
			["mapPOI"] = 7746,
		},
		[33] = {
			["currencyID"] = 2180,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 66786,
			["mapPOI"] = 7746,
		},
		[34] = {
			["currencyID"] = 2431,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 66786,
			["mapPOI"] = 7746,
		},
		[35] = {
			["currencyID"] = 2432,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 66786,
			["mapPOI"] = 7746,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7746,
		},
		
		--Flashfrost Flyover
		[37] = {
			["currencyID"] = 2046,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 66710,
			["mapPOI"] = 7741,
		},
		[38] = {
			["currencyID"] = 2047,
			["silverTime"] = 66,
			["goldTime"] = 61,
			["questID"] = 66710,
			["mapPOI"] = 7741,
		},
		[39] = {
			["currencyID"] = 2181,
			["silverTime"] = 65,
			["goldTime"] = 60,
			["questID"] = 66710,
			["mapPOI"] = 7741,
		},
		[40] = {
			["currencyID"] = 2433,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 66710,
			["mapPOI"] = 7741,
		},
		[41] = {
			["currencyID"] = 2434,
			["silverTime"] = 74,
			["goldTime"] = 69,
			["questID"] = 66710,
			["mapPOI"] = 7741,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7741,
		},
		
		--Wild Preserve Circuit
		[43] = {
			["currencyID"] = 2050,
			["silverTime"] = 43,
			["goldTime"] = 40,
			["questID"] = 66725,
			["mapPOI"] = 7747,
		},
		[44] = {
			["currencyID"] = 2051,
			["silverTime"] = 43,
			["goldTime"] = 38,
			["questID"] = 66725,
			["mapPOI"] = 7747,
		},
		[45] = {
			["currencyID"] = 2182,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 66725,
			["mapPOI"] = 7747,
		},
		[46] = {
			["currencyID"] = 2435,
			["silverTime"] = 46,
			["goldTime"] = 43,
			["questID"] = 66725,
			["mapPOI"] = 7747,
		},
		[47] = {
			["currencyID"] = 2436,
			["silverTime"] = 47,
			["goldTime"] = 44,
			["questID"] = 66725,
			["mapPOI"] = 7747,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7747,
		},
	},



-- Ohn'ahran Plains
	-- Sundapple Copse Circuit
	[7] = {
		[1] = {
			["currencyID"] = 2060,
			["silverTime"] = 52,
			["goldTime"] = 49,
			["questID"] = 66835,
			["mapPOI"] = 7748,
		},
		[2] = {
			["currencyID"] = 2061,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 66835,
			["mapPOI"] = 7748,
		},
		[3] = {
			["currencyID"] = 2183,
			["silverTime"] = 50,
			["goldTime"] = 45,
			["questID"] = 66835,
			["mapPOI"] = 7748,
		},
		[4] = {
			["currencyID"] = 2437,
			["silverTime"] = 54,
			["goldTime"] = 51,
			["questID"] = 66835,
			["mapPOI"] = 7748,
		},
		[5] = {
			["currencyID"] = 2439,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66835,
			["mapPOI"] = 7748,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7748,
		},

		-- Fen Flythrough
		[7] = {
			["currencyID"] = 2062,
			["silverTime"] = 51,
			["goldTime"] = 48,
			["questID"] = 66877,
			["mapPOI"] = 7749,
		},
		[8] = {
			["currencyID"] = 2063,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 66877,
			["mapPOI"] = 7749,
		},
		[9] = {
			["currencyID"] = 2184,
			["silverTime"] = 52,
			["goldTime"] = 47,
			["questID"] = 66877,
			["mapPOI"] = 7749,
		},
		[10] = {
			["currencyID"] = 2440,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66877,
			["mapPOI"] = 7749,
		},
		[11] = {
			["currencyID"] = 2441,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66877,
			["mapPOI"] = 7749,
		},
		[12] = {
			["currencyID"] = 2665,
			["silverTime"] = 87,
			["goldTime"] = 82,
			["questID"] = 66877,
			["mapPOI"] = 7749,
		},

		-- Ravine River Run
		[13] = {
			["currencyID"] = 2064,
			["silverTime"] = 52,
			["goldTime"] = 49,
			["questID"] = 66880,
			["mapPOI"] = 7750,
		},
		[14] = {
			["currencyID"] = 2065,
			["silverTime"] = 52,
			["goldTime"] = 47,
			["questID"] = 66880,
			["mapPOI"] = 7750,
		},
		[15] = {
			["currencyID"] = 2185,
			["silverTime"] = 51,
			["goldTime"] = 46,
			["questID"] = 66880,
			["mapPOI"] = 7750,
		},
		[16] = {
			["currencyID"] = 2442,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66880,
			["mapPOI"] = 7750,
		},
		[17] = {
			["currencyID"] = 2443,
			["silverTime"] = 54,
			["goldTime"] = 51,
			["questID"] = 66880,
			["mapPOI"] = 7750,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7750,
		},

		-- Emerald Gardens Ascent
		[19] = {
			["currencyID"] = 2066,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 66885,
			["mapPOI"] = 7751,
		},
		[20] = {
			["currencyID"] = 2067,
			["silverTime"] = 60,
			["goldTime"] = 55,
			["questID"] = 66885,
			["mapPOI"] = 7751,
		},
		[21] = {
			["currencyID"] = 2186,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 66885,
			["mapPOI"] = 7751,
		},
		[22] = {
			["currencyID"] = 2444,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 66885,
			["mapPOI"] = 7751,
		},
		[23] = {
			["currencyID"] = 2445,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 66885,
			["mapPOI"] = 7751,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7751,
		},

		-- Maruukai Dash
		[25] = {
			["currencyID"] = 2069,
			["silverTime"] = 28,
			["goldTime"] = 25,
			["questID"] = 66921,
			["mapPOI"] = 7753,
		},
		[26] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7753,
		},
		[27] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7753,
		},
		[28] = {
			["currencyID"] = 2446,
			["silverTime"] = 27,
			["goldTime"] = 24,
			["questID"] = 66921,
			["mapPOI"] = 7753,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7753,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7753,
		},

		-- Mirror of the Sky Dash
		[31] = {
			["currencyID"] = 2070,
			["silverTime"] = 29,
			["goldTime"] = 26,
			["questID"] = 66933,
			["mapPOI"] = 7754,
		},
		[32] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7754,
		},
		[33] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7754,
		},
		[34] = {
			["currencyID"] = 2447,
			["silverTime"] = 30,
			["goldTime"] = 27,
			["questID"] = 66933,
			["mapPOI"] = 7754,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7754,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7754,
		},

		-- River Rapids Route
		[37] = {
			["currencyID"] = 2119,
			["silverTime"] = 51,
			["goldTime"] = 48,
			["questID"] = 70710,
			["mapPOI"] = 7752,
		},
		[38] = {
			["currencyID"] = 2120,
			["silverTime"] = 48,
			["goldTime"] = 43,
			["questID"] = 70710,
			["mapPOI"] = 7752,
		},
		[39] = {
			["currencyID"] = 2187,
			["silverTime"] = 49,
			["goldTime"] = 44,
			["questID"] = 70710,
			["mapPOI"] = 7752,
		},
		[40] = {
			["currencyID"] = 2448,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 70710,
			["mapPOI"] = 7752,
		},
		[41] = {
			["currencyID"] = 2449,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 70710,
			["mapPOI"] = 7752,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7752,
		},
	},


-- Azure Span
	 -- The Azure Span Sprint
	[8] = {
		[1] = {
			["currencyID"] = 2074,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 66946,
			["mapPOI"] = 7755,
		},
		[2] = {
			["currencyID"] = 2075,
			["silverTime"] = 63,
			["goldTime"] = 58,
			["questID"] = 66946,
			["mapPOI"] = 7755,
		},
		[3] = {
			["currencyID"] = 2188,
			["silverTime"] = 65,
			["goldTime"] = 60,
			["questID"] = 66946,
			["mapPOI"] = 7755,
		},
		[4] = {
			["currencyID"] = 2450,
			["silverTime"] = 70,
			["goldTime"] = 67,
			["questID"] = 66946,
			["mapPOI"] = 7755,
		},
		[5] = {
			["currencyID"] = 2451,
			["silverTime"] = 72,
			["goldTime"] = 69,
			["questID"] = 66946,
			["mapPOI"] = 7755,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7755,
		},

		 -- The Azure Span Slalom
		[7] = {
			["currencyID"] = 2076,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 67002,
			["mapPOI"] = 7756,
		},
		[8] = {
			["currencyID"] = 2077,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 67002,
			["mapPOI"] = 7756,
		},
		[9] = {
			["currencyID"] = 2189,
			["silverTime"] = 58,
			["goldTime"] = 53,
			["questID"] = 67002,
			["mapPOI"] = 7756,
		},
		[10] = {
			["currencyID"] = 2452,
			["silverTime"] = 58,
			["goldTime"] = 55,
			["questID"] = 67002,
			["mapPOI"] = 7756,
		},
		[11] = {
			["currencyID"] = 2453,
			["silverTime"] = 58,
			["goldTime"] = 55,
			["questID"] = 67002,
			["mapPOI"] = 7756,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7756,
		},

		 -- The Vakthros Ascent
		[13] = {
			["currencyID"] = 2078,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 67031,
			["mapPOI"] = 7757,
		},
		[14] = {
			["currencyID"] = 2079,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 67031,
			["mapPOI"] = 7757,
		},
		[15] = {
			["currencyID"] = 2190,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 67031,
			["mapPOI"] = 7757,
		},
		[16] = {
			["currencyID"] = 2454,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 67031,
			["mapPOI"] = 7757,
		},
		[17] = {
			["currencyID"] = 2455,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 67031,
			["mapPOI"] = 7757,
		},
		[18] = {
			["currencyID"] = 2666,
			["silverTime"] = 125,
			["goldTime"] = 120,
			["questID"] = 67031,
			["mapPOI"] = 7757,
		},

		 -- Iskaara Tour
		[19] = {
			["currencyID"] = 2083,
			["silverTime"] = 78,
			["goldTime"] = 75,
			["questID"] = 67296,
			["mapPOI"] = 7758,
		},
		[20] = {
			["currencyID"] = 2084,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 67296,
			["mapPOI"] = 7758,
		},
		[21] = {
			["currencyID"] = 2191,
			["silverTime"] = 72,
			["goldTime"] = 67,
			["questID"] = 67296,
			["mapPOI"] = 7758,
		},
		[22] = {
			["currencyID"] = 2456,
			["silverTime"] = 81,
			["goldTime"] = 78,
			["questID"] = 67296,
			["mapPOI"] = 7758,
		},
		[23] = {
			["currencyID"] = 2457,
			["silverTime"] = 82,
			["goldTime"] = 79,
			["questID"] = 67296,
			["mapPOI"] = 7758,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7758,
		},

		 -- Frostland Flyover
		[25] = {
			["currencyID"] = 2085,
			["silverTime"] = 79,
			["goldTime"] = 76,
			["questID"] = 67565,
			["mapPOI"] = 7759,
		},
		[26] = {
			["currencyID"] = 2086,
			["silverTime"] = 77,
			["goldTime"] = 72,
			["questID"] = 67565,
			["mapPOI"] = 7759,
		},
		[27] = {
			["currencyID"] = 2192,
			["silverTime"] = 74,
			["goldTime"] = 69,
			["questID"] = 67565,
			["mapPOI"] = 7759,
		},
		[28] = {
			["currencyID"] = 2458,
			["silverTime"] = 88,
			["goldTime"] = 85,
			["questID"] = 67565,
			["mapPOI"] = 7759,
		},
		[29] = {
			["currencyID"] = 2459,
			["silverTime"] = 86,
			["goldTime"] = 83,
			["questID"] = 67565,
			["mapPOI"] = 7759,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7759,
		},

		 -- Archive Ambit
		[31] = {
			["currencyID"] = 2089,
			["silverTime"] = 94,
			["goldTime"] = 91,
			["questID"] = 67741,
			["mapPOI"] = 7760,
		},
		[32] = {
			["currencyID"] = 2090,
			["silverTime"] = 86,
			["goldTime"] = 81,
			["questID"] = 67741,
			["mapPOI"] = 7760,
		},
		[33] = {
			["currencyID"] = 2193,
			["silverTime"] = 81,
			["goldTime"] = 76,
			["questID"] = 67741,
			["mapPOI"] = 7760,
		},
		[34] = {
			["currencyID"] = 2460,
			["silverTime"] = 93,
			["goldTime"] = 90,
			["questID"] = 67741,
			["mapPOI"] = 7760,
		},
		[35] = {
			["currencyID"] = 2461,
			["silverTime"] = 95,
			["goldTime"] = 92,
			["questID"] = 67741,
			["mapPOI"] = 7760,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7760,
		},
	},


-- Thaldraszus
	[9] = {
		 -- The Flowing Forest Flight
		[1] = {
			["currencyID"] = 2080,
			["silverTime"] = 52,
			["goldTime"] = 49,
			["questID"] = 67095,
			["mapPOI"] = 7761,
		},
		[2] = {
			["currencyID"] = 2081,
			["silverTime"] = 45,
			["goldTime"] = 40,
			["questID"] = 67095,
			["mapPOI"] = 7761,
		},
		[3] = {
			["currencyID"] = 2194,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 67095,
			["mapPOI"] = 7761,
		},
		[4] = {
			["currencyID"] = 2462,
			["silverTime"] = 50,
			["goldTime"] = 47,
			["questID"] = 67095,
			["mapPOI"] = 7761,
		},
		[5] = {
			["currencyID"] = 2463,
			["silverTime"] = 49,
			["goldTime"] = 46,
			["questID"] = 67095,
			["mapPOI"] = 7761,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7761,
		},
		
		 -- Tyrhold Trial
		[7] = {
			["currencyID"] = 2092,
			["silverTime"] = 84,
			["goldTime"] = 81,
			["questID"] = 69957,
			["mapPOI"] = 7762,
		},
		[8] = {
			["currencyID"] = 2093,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 69957,
			["mapPOI"] = 7762,
		},
		[9] = {
			["currencyID"] = 2195,
			["silverTime"] = 64,
			["goldTime"] = 59,
			["questID"] = 69957,
			["mapPOI"] = 7762,
		},
		[10] = {
			["currencyID"] = 2464,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 69957,
			["mapPOI"] = 7762,
		},
		[11] = {
			["currencyID"] = 2465,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 69957,
			["mapPOI"] = 7762,
		},
		[12] = {
			["currencyID"] = 2667,
			["silverTime"] = 85,
			["goldTime"] = 80,
			["questID"] = 69957,
			["mapPOI"] = 7762,
		},
		
		 -- Cliffside Circuit
		[13] = {
			["currencyID"] = 2096,
			["silverTime"] = 72,
			["goldTime"] = 69,
			["questID"] = 70051,
			["mapPOI"] = 7763,
		},
		[14] = {
			["currencyID"] = 2097,
			["silverTime"] = 71,
			["goldTime"] = 66,
			["questID"] = 70051,
			["mapPOI"] = 7763,
		},
		[15] = {
			["currencyID"] = 2196,
			["silverTime"] = 74,
			["goldTime"] = 69,
			["questID"] = 70051,
			["mapPOI"] = 7763,
		},
		[16] = {
			["currencyID"] = 2466,
			["silverTime"] = 84,
			["goldTime"] = 81,
			["questID"] = 70051,
			["mapPOI"] = 7763,
		},
		[17] = {
			["currencyID"] = 2467,
			["silverTime"] = 83,
			["goldTime"] = 80,
			["questID"] = 70051,
			["mapPOI"] = 7763,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7763,
		},
		
		 -- Academy Ascent
		[19] = {
			["currencyID"] = 2098,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 70059,
			["mapPOI"] = 7764,
		},
		[20] = {
			["currencyID"] = 2099,
			["silverTime"] = 57,
			["goldTime"] = 52,
			["questID"] = 70059,
			["mapPOI"] = 7764,
		},
		[21] = {
			["currencyID"] = 2197,
			["silverTime"] = 58,
			["goldTime"] = 53,
			["questID"] = 70059,
			["mapPOI"] = 7764,
		},
		[22] = {
			["currencyID"] = 2468,
			["silverTime"] = 68,
			["goldTime"] = 65,
			["questID"] = 70059,
			["mapPOI"] = 7764,
		},
		[23] = {
			["currencyID"] = 2469,
			["silverTime"] = 68,
			["goldTime"] = 65,
			["questID"] = 70059,
			["mapPOI"] = 7764,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7764,
		},
		
		 -- Garden Gallivant
		[25] = {
			["currencyID"] = 2101,
			["silverTime"] = 64,
			["goldTime"] = 61,
			["questID"] = 70157,
			["mapPOI"] = 7765,
		},
		[26] = {
			["currencyID"] = 2102,
			["silverTime"] = 59,
			["goldTime"] = 54,
			["questID"] = 70157,
			["mapPOI"] = 7765,
		},
		[27] = {
			["currencyID"] = 2198,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 70157,
			["mapPOI"] = 7765,
		},
		[28] = {
			["currencyID"] = 2470,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 70157,
			["mapPOI"] = 7765,
		},
		[29] = {
			["currencyID"] = 2471,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 70157,
			["mapPOI"] = 7765,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7765,
		},
		
		 -- Caverns Criss-Cross
		[31] = {
			["currencyID"] = 2103,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 70161,
			["mapPOI"] = 7766,
		},
		[32] = {
			["currencyID"] = 2104,
			["silverTime"] = 50,
			["goldTime"] = 45,
			["questID"] = 70161,
			["mapPOI"] = 7766,
		},
		[33] = {
			["currencyID"] = 2199,
			["silverTime"] = 52,
			["goldTime"] = 47,
			["questID"] = 70161,
			["mapPOI"] = 7766,
		},
		[34] = {
			["currencyID"] = 2472,
			["silverTime"] = 59,
			["goldTime"] = 56,
			["questID"] = 70161,
			["mapPOI"] = 7766,
		},
		[35] = {
			["currencyID"] = 2473,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 70161,
			["mapPOI"] = 7766,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7766,
		},
	},


-- Forbidden Reach
	[10] = {
		 -- Stormsunder Crater Circuit
		[1] = {
			["currencyID"] = 2201,
			["silverTime"] = 46,
			["goldTime"] = 43,
			["questID"] = 73017,
			["mapPOI"] = 7767,
		},
		[2] = {
			["currencyID"] = 2207,
			["silverTime"] = 47,
			["goldTime"] = 42,
			["questID"] = 73017,
			["mapPOI"] = 7767,
		},
		[3] = {
			["currencyID"] = 2213,
			["silverTime"] = 47,
			["goldTime"] = 42,
			["questID"] = 73017,
			["mapPOI"] = 7767,
		},
		[4] = {
			["currencyID"] = 2474,
			["silverTime"] = 48,
			["goldTime"] = 45,
			["questID"] = 73017,
			["mapPOI"] = 7767,
		},
		[5] = {
			["currencyID"] = 2475,
			["silverTime"] = 47,
			["goldTime"] = 44,
			["questID"] = 73017,
			["mapPOI"] = 7767,
		},
		[6] = {
			["currencyID"] = 2668,
			["silverTime"] = 97,
			["goldTime"] = 92,
			["questID"] = 73017,
			["mapPOI"] = 7767,
		},
		
		 -- Morqut Ascent
		[7] = {
			["currencyID"] = 2202,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 73020,
			["mapPOI"] = 7768,
		},
		[8] = {
			["currencyID"] = 2208,
			["silverTime"] = 54,
			["goldTime"] = 49,
			["questID"] = 73020,
			["mapPOI"] = 7768,
		},
		[9] = {
			["currencyID"] = 2214,
			["silverTime"] = 57,
			["goldTime"] = 52,
			["questID"] = 73020,
			["mapPOI"] = 7768,
		},
		[10] = {
			["currencyID"] = 2476,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 73020,
			["mapPOI"] = 7768,
		},
		[11] = {
			["currencyID"] = 2477,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 73020,
			["mapPOI"] = 7768,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7768,
		},
		
		 -- Aerie Chasm
		[13] = {
			["currencyID"] = 2203,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 73025,
			["mapPOI"] = 7769,
		},
		[14] = {
			["currencyID"] = 2209,
			["silverTime"] = 55,
			["goldTime"] = 50,
			["questID"] = 73025,
			["mapPOI"] = 7769,
		},
		[15] = {
			["currencyID"] = 2215,
			["silverTime"] = 55,
			["goldTime"] = 50,
			["questID"] = 73025,
			["mapPOI"] = 7769,
		},
		[16] = {
			["currencyID"] = 2478,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 73025,
			["mapPOI"] = 7769,
		},
		[17] = {
			["currencyID"] = 2479,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 73025,
			["mapPOI"] = 7769,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7769,
		},
		
		 -- Southern Reach Route
		[19] = {
			["currencyID"] = 2204,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 73029,
			["mapPOI"] = 7770,
		},
		[20] = {
			["currencyID"] = 2210,
			["silverTime"] = 73,
			["goldTime"] = 68,
			["questID"] = 73029,
			["mapPOI"] = 7770,
		},
		[21] = {
			["currencyID"] = 2216,
			["silverTime"] = 68,
			["goldTime"] = 63,
			["questID"] = 73029,
			["mapPOI"] = 7770,
		},
		[22] = {
			["currencyID"] = 2480,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 73029,
			["mapPOI"] = 7770,
		},
		[23] = {
			["currencyID"] = 2481,
			["silverTime"] = 71,
			["goldTime"] = 68,
			["questID"] = 73029,
			["mapPOI"] = 7770,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7770,
		},
		
		 -- Caldera Coaster
		[25] = {
			["currencyID"] = 2205,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 73033,
			["mapPOI"] = 7771,
		},
		[26] = {
			["currencyID"] = 2211,
			["silverTime"] = 57,
			["goldTime"] = 52,
			["questID"] = 73033,
			["mapPOI"] = 7771,
		},
		[27] = {
			["currencyID"] = 2217,
			["silverTime"] = 54,
			["goldTime"] = 49,
			["questID"] = 73033,
			["mapPOI"] = 7771,
		},
		[28] = {
			["currencyID"] = 2482,
			["silverTime"] = 58,
			["goldTime"] = 55,
			["questID"] = 73033,
			["mapPOI"] = 7771,
		},
		[29] = {
			["currencyID"] = 2483,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 73033,
			["mapPOI"] = 7771,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7771,
		},
		
		 -- Forbidden Reach Rush
		[31] = {
			["currencyID"] = 2206,
			["silverTime"] = 62,
			["goldTime"] = 59,
			["questID"] = 73061,
			["mapPOI"] = 7772,
		},
		[32] = {
			["currencyID"] = 2212,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 73061,
			["mapPOI"] = 7772,
		},
		[33] = {
			["currencyID"] = 2218,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 73061,
			["mapPOI"] = 7772,
		},
		[34] = {
			["currencyID"] = 2484,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 73061,
			["mapPOI"] = 7772,
		},
		[35] = {
			["currencyID"] = 2485,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 73061,
			["mapPOI"] = 7772,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7772,
		},
	},


-- Zaralek Caverns
	[11] = {
		 -- Crystal Circuit
		[1] = {
			["currencyID"] = 2246,
			["silverTime"] = 68,
			["goldTime"] = 63,
			["questID"] = 74839,
			["mapPOI"] = 7773,
		},
		[2] = {
			["currencyID"] = 2252,
			["silverTime"] = 60,
			["goldTime"] = 55,
			["questID"] = 74839,
			["mapPOI"] = 7773,
		},
		[3] = {
			["currencyID"] = 2258,
			["silverTime"] = 58,
			["goldTime"] = 53,
			["questID"] = 74839,
			["mapPOI"] = 7773,
		},
		[4] = {
			["currencyID"] = 2486,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 74839,
			["mapPOI"] = 7773,
		},
		[5] = {
			["currencyID"] = 2487,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 74839,
			["mapPOI"] = 7773,
		},
		[6] = {
			["currencyID"] = 2669,
			["silverTime"] = 100,
			["goldTime"] = 95,
			["questID"] = 74839,
			["mapPOI"] = 7773,
		},
		
		 -- Caldera Cruise
		[7] = {
			["currencyID"] = 2247,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 74889,
			["mapPOI"] = 7774,
		},
		[8] = {
			["currencyID"] = 2253,
			["silverTime"] = 73,
			["goldTime"] = 68,
			["questID"] = 74889,
			["mapPOI"] = 7774,
		},
		[9] = {
			["currencyID"] = 2259,
			["silverTime"] = 73,
			["goldTime"] = 68,
			["questID"] = 74889,
			["mapPOI"] = 7774,
		},
		[10] = {
			["currencyID"] = 2488,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 74889,
			["mapPOI"] = 7774,
		},
		[11] = {
			["currencyID"] = 2489,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 74889,
			["mapPOI"] = 7774,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7774,
		},
		
		 -- Brimstone Scramble
		[13] = {
			["currencyID"] = 2248,
			["silverTime"] = 72,
			["goldTime"] = 69,
			["questID"] = 74939,
			["mapPOI"] = 7775,
		},
		[14] = {
			["currencyID"] = 2254,
			["silverTime"] = 69,
			["goldTime"] = 64,
			["questID"] = 74939,
			["mapPOI"] = 7775,
		},
		[15] = {
			["currencyID"] = 2260,
			["silverTime"] = 69,
			["goldTime"] = 64,
			["questID"] = 74939,
			["mapPOI"] = 7775,
		},
		[16] = {
			["currencyID"] = 2490,
			["silverTime"] = 72,
			["goldTime"] = 69,
			["questID"] = 74939,
			["mapPOI"] = 7775,
		},
		[17] = {
			["currencyID"] = 2491,
			["silverTime"] = 74,
			["goldTime"] = 71,
			["questID"] = 74939,
			["mapPOI"] = 7775,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7775,
		},
		
		 -- Shimmering Slalom
		[19] = {
			["currencyID"] = 2249,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 74951,
			["mapPOI"] = 7776,
		},
		[20] = {
			["currencyID"] = 2255,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 74951,
			["mapPOI"] = 7776,
		},
		[21] = {
			["currencyID"] = 2261,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 74951,
			["mapPOI"] = 7776,
		},
		[22] = {
			["currencyID"] = 2492,
			["silverTime"] = 82,
			["goldTime"] = 79,
			["questID"] = 74951,
			["mapPOI"] = 7776,
		},
		[23] = {
			["currencyID"] = 2493,
			["silverTime"] = 78,
			["goldTime"] = 75,
			["questID"] = 74951,
			["mapPOI"] = 7776,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7776,
		},
		
		 -- Loamm Roamm
		[25] = {
			["currencyID"] = 2250,
			["silverTime"] = 60,
			["goldTime"] = 55,
			["questID"] = 74972,
			["mapPOI"] = 7777,
		},
		[26] = {
			["currencyID"] = 2256,
			["silverTime"] = 55,
			["goldTime"] = 50,
			["questID"] = 74972,
			["mapPOI"] = 7777,
		},
		[27] = {
			["currencyID"] = 2262,
			["silverTime"] = 53,
			["goldTime"] = 48,
			["questID"] = 74972,
			["mapPOI"] = 7777,
		},
		[28] = {
			["currencyID"] = 2494,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 74972,
			["mapPOI"] = 7777,
		},
		[29] = {
			["currencyID"] = 2495,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 74972,
			["mapPOI"] = 7777,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7777,
		},
		
		 -- Sulfur Sprint
		 [31] = {
			["currencyID"] = 2251,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 75035,
			["mapPOI"] = 7778,
		},
		[32] = {
			["currencyID"] = 2257,
			["silverTime"] = 63,
			["goldTime"] = 58,
			["questID"] = 75035,
			["mapPOI"] = 7778,
		},
		[33] = {
			["currencyID"] = 2263,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 75035,
			["mapPOI"] = 7778,
		},
		[34] = {
			["currencyID"] = 2496,
			["silverTime"] = 70,
			["goldTime"] = 67,
			["questID"] = 75035,
			["mapPOI"] = 7778,
		},
		[35] = {
			["currencyID"] = 2497,
			["silverTime"] = 68,
			["goldTime"] = 65,
			["questID"] = 75035,
			["mapPOI"] = 7778,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7778,
		},
	},

-- Emerald Dream
	[12] = {
		 -- Ysera Invitational
		[1] = {
			["currencyID"] = 2676,
			["silverTime"] = 103,
			["goldTime"] = 98,
			["questID"] = 77841,
			["mapPOI"] = 7903,
		},
		[2] = {
			["currencyID"] = 2682,
			["silverTime"] = 90,
			["goldTime"] = 87,
			["questID"] = 77841,
			["mapPOI"] = 7903,
		},
		[3] = {
			["currencyID"] = 2688,
			["silverTime"] = 90,
			["goldTime"] = 87,
			["questID"] = 77841,
			["mapPOI"] = 7903,
		},
		[4] = {
			["currencyID"] = 2694,
			["silverTime"] = 98,
			["goldTime"] = 95,
			["questID"] = 77841,
			["mapPOI"] = 7903,
		},
		[5] = {
			["currencyID"] = 2695,
			["silverTime"] = 100,
			["goldTime"] = 97,
			["questID"] = 77841,
			["mapPOI"] = 7903,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7903,
		},
		
		 -- Smoldering Sprint
		[7] = {
			["currencyID"] = 2677,
			["silverTime"] = 85,
			["goldTime"] = 80,
			["questID"] = 77983,
			["mapPOI"] = 7904,
		},
		[8] = {
			["currencyID"] = 2683,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77983,
			["mapPOI"] = 7904,
		},
		[9] = {
			["currencyID"] = 2689,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77983,
			["mapPOI"] = 7904,
		},
		[10] = {
			["currencyID"] = 2696,
			["silverTime"] = 82,
			["goldTime"] = 79,
			["questID"] = 77983,
			["mapPOI"] = 7904,
		},
		[11] = {
			["currencyID"] = 2697,
			["silverTime"] = 83,
			["goldTime"] = 80,
			["questID"] = 77983,
			["mapPOI"] = 7904,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7904,
		},
		
		 -- Viridescent Venture
		[13] = {
			["currencyID"] = 2678,
			["silverTime"] = 83,
			["goldTime"] = 78,
			["questID"] = 77996,
			["mapPOI"] = 7905,
		},
		[14] = {
			["currencyID"] = 2684,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 77996,
			["mapPOI"] = 7905,
		},
		[15] = {
			["currencyID"] = 2690,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 77996,
			["mapPOI"] = 7905,
		},
		[16] = {
			["currencyID"] = 2698,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77996,
			["mapPOI"] = 7905,
		},
		[17] = {
			["currencyID"] = 2699,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77996,
			["mapPOI"] = 7905,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7905,
		},
		
		 -- Shoreline Switchback
		[19] = {
			["currencyID"] = 2679,
			["silverTime"] = 78,
			["goldTime"] = 73,
			["questID"] = 78016,
			["mapPOI"] = 7906,
		},
		[20] = {
			["currencyID"] = 2685,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 78016,
			["mapPOI"] = 7906,
		},
		[21] = {
			["currencyID"] = 2691,
			["silverTime"] = 65,
			["goldTime"] = 62,
			["questID"] = 78016,
			["mapPOI"] = 7906,
		},
		[22] = {
			["currencyID"] = 2700,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 78016,
			["mapPOI"] = 7906,
		},
		[23] = {
			["currencyID"] = 2701,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 78016,
			["mapPOI"] = 7906,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7906,
		},
		
		 -- Canopy Concours
		[25] = {
			["currencyID"] = 2680,
			["silverTime"] = 110,
			["goldTime"] = 105,
			["questID"] = 78102,
			["mapPOI"] = 7907,
		},
		[26] = {
			["currencyID"] = 2686,
			["silverTime"] = 96,
			["goldTime"] = 93,
			["questID"] = 78102,
			["mapPOI"] = 7907,
		},
		[27] = {
			["currencyID"] = 2692,
			["silverTime"] = 99,
			["goldTime"] = 96,
			["questID"] = 78102,
			["mapPOI"] = 7907,
		},
		[28] = {
			["currencyID"] = 2702,
			["silverTime"] = 108,
			["goldTime"] = 105,
			["questID"] = 78102,
			["mapPOI"] = 7907,
		},
		[29] = {
			["currencyID"] = 2703,
			["silverTime"] = 108,
			["goldTime"] = 105,
			["questID"] = 78102,
			["mapPOI"] = 7907,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7907,
		},
		
		 -- Emerald Amble
		[31] = {
			["currencyID"] = 2681,
			["silverTime"] = 89,
			["goldTime"] = 84,
			["questID"] = 78115,
			["mapPOI"] = 7908,
		},
		[32] = {
			["currencyID"] = 2687,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 78115,
			["mapPOI"] = 7908,
		},
		[33] = {
			["currencyID"] = 2693,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 78115,
			["mapPOI"] = 7908,
		},
		[34] = {
			["currencyID"] = 2704,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 78115,
			["mapPOI"] = 7908,
		},
		[35] = {
			["currencyID"] = 2705,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 78115,
			["mapPOI"] = 7908,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7908,
		},
	},



-- Kalimdor Cup
	[13] = {
	 -- Felwood Flyover
		[1] = {
			["currencyID"] = 2312,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75277,
			["mapPOI"] = 7494,
		},
		[2] = {
			["currencyID"] = 2342,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 75277,
			["mapPOI"] = 7494,
		},
		[3] = {
			["currencyID"] = 2372,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 62,
			["questID"] = 75277,
			["mapPOI"] = 7494,
		},
		[4] = {
			["currencyID"] = nil, -- 2498 UNUSED
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7494,
		},
		[5] = {
			["currencyID"] = nil, -- 2499 UNUSED
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7494,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7494,
		},
	
	 -- Winter Wander
		[7] = {
			["currencyID"] = 2313,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 80,
			["questID"] = 75310,
			["mapPOI"] = 7495,
		},
		[8] = {
			["currencyID"] = 2343,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 73,
			["questID"] = 75310,
			["mapPOI"] = 7495,
		},
		[9] = {
			["currencyID"] = 2373,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75310,
			["mapPOI"] = 7495,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7495,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7495,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7495,
		},
	
	 -- Nordrassil Spiral
		[13] = {
			["currencyID"] = 2314,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 45,
			["questID"] = 75317,
			["mapPOI"] = 7496,
		},
		[14] = {
			["currencyID"] = 2344,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 41,
			["questID"] = 75317,
			["mapPOI"] = 7496,
		},
		[15] = {
			["currencyID"] = 2374,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 41,
			["questID"] = 75317,
			["mapPOI"] = 7496,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7496,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7496,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7496,
		},
	
	 -- Hyjal Hotfoot
		[19] = {
			["currencyID"] = 2315,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75330,
			["mapPOI"] = 7497,
		},
		[20] = {
			["currencyID"] = 2345,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 69,
			["questID"] = 75330,
			["mapPOI"] = 7497,
		},
		[21] = {
			["currencyID"] = 2375,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 67,
			["questID"] = 75330,
			["mapPOI"] = 7497,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7497,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7497,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7497,
		},
	
	 -- Rocketway Ride
		[25] = {
			["currencyID"] = 2316,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 101,
			["questID"] = 75347,
			["mapPOI"] = 7498,
		},
		[26] = {
			["currencyID"] = 2346,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 94,
			["questID"] = 75347,
			["mapPOI"] = 7498,
		},
		[27] = {
			["currencyID"] = 2376,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 94,
			["questID"] = 75347,
			["mapPOI"] = 7498,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7498,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7498,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7498,
		},
	
	 -- Ashenvale Ambit
		[31] = {
			["currencyID"] = 2317,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 75378,
			["mapPOI"] = 7499,
		},
		[32] = {
			["currencyID"] = 2347,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 59,
			["questID"] = 75378,
			["mapPOI"] = 7499,
		},
		[33] = {
			["currencyID"] = 2377,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 59,
			["questID"] = 75378,
			["mapPOI"] = 7499,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7499,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7499,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7499,
		},
	
	 -- Durotar Tour
		[37] = {
			["currencyID"] = 2318,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 82,
			["questID"] = 75385,
			["mapPOI"] = 7500,
		},
		[38] = {
			["currencyID"] = 2348,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 75,
			["questID"] = 75385,
			["mapPOI"] = 7500,
		},
		[39] = {
			["currencyID"] = 2378,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 75,
			["questID"] = 75385,
			["mapPOI"] = 7500,
		},
		[40] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7500,
		},
		[41] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7500,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7500,
		},
	
	 -- Webwinder Weave
		[43] = {
			["currencyID"] = 2319,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 80,
			["questID"] = 75394,
			["mapPOI"] = 7501,
		},
		[44] = {
			["currencyID"] = 2349,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 73,
			["questID"] = 75394,
			["mapPOI"] = 7501,
		},
		[45] = {
			["currencyID"] = 2379,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75394,
			["mapPOI"] = 7501,
		},
		[46] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7501,
		},
		[47] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7501,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7501,
		},
	
	 -- Desolace Drift
		[49] = {
			["currencyID"] = 2320,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 78,
			["questID"] = 75409,
			["mapPOI"] = 7502,
		},
		[50] = {
			["currencyID"] = 2350,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75409,
			["mapPOI"] = 7502,
		},
		[51] = {
			["currencyID"] = 2380,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 71,
			["questID"] = 75409,
			["mapPOI"] = 7502,
		},
		[52] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7502,
		},
		[53] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7502,
		},
		[54] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7502,
		},
	
	 -- Great Divide Dive
		[55] = {
			["currencyID"] = 2321,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 48,
			["questID"] = 75412,
			["mapPOI"] = 7503,
		},
		[56] = {
			["currencyID"] = 2351,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 43,
			["questID"] = 75412,
			["mapPOI"] = 7503,
		},
		[57] = {
			["currencyID"] = 2381,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 44,
			["questID"] = 75412,
			["mapPOI"] = 7503,
		},
		[58] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7503,
		},
		[59] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7503,
		},
		[60] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7503,
		},
	
	 -- Razorfen Roundabout
		[61] = {
			["currencyID"] = 2322,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 53,
			["questID"] = 75437,
			["mapPOI"] = 7504,
		},
		[62] = {
			["currencyID"] = 2352,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 47,
			["questID"] = 75437,
			["mapPOI"] = 7504,
		},
		[63] = {
			["currencyID"] = 2382,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 48,
			["questID"] = 75437,
			["mapPOI"] = 7504,
		},
		[64] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7504,
		},
		[65] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7504,
		},
		[66] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7504,
		},
	
	 -- Thousand Needles Thread
		[67] = {
			["currencyID"] = 2323,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 87,
			["questID"] = 75463,
			["mapPOI"] = 7505,
		},
		[68] = {
			["currencyID"] = 2353,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 77,
			["questID"] = 75463,
			["mapPOI"] = 7505,
		},
		[69] = {
			["currencyID"] = 2383,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 77,
			["questID"] = 75463,
			["mapPOI"] = 7505,
		},
		[70] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7505,
		},
		[71] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7505,
		},
		[72] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7505,
		},
	
	 -- Feralas Ruins Ramble
		[73] = {
			["currencyID"] = 2324,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 89,
			["questID"] = 75468,
			["mapPOI"] = 7506,
		},
		[74] = {
			["currencyID"] = 2354,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 84,
			["questID"] = 75468,
			["mapPOI"] = 7506,
		},
		[75] = {
			["currencyID"] = 2384,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 84,
			["questID"] = 75468,
			["mapPOI"] = 7506,
		},
		[76] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7506,
		},
		[77] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7506,
		},
		[78] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7506,
		},
	
	 -- Ahn'Qiraj Circuit
		[79] = {
			["currencyID"] = 2325,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 77,
			["questID"] = 75472,
			["mapPOI"] = 7507,
		},
		[80] = {
			["currencyID"] = 2355,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 68,
			["questID"] = 75472,
			["mapPOI"] = 7507,
		},
		[81] = {
			["currencyID"] = 2385,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 69,
			["questID"] = 75472,
			["mapPOI"] = 7507,
		},
		[82] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7507,
		},
		[83] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7507,
		},
		[84] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7507,
		},
	
	 -- Uldum Tour
		[85] = {
			["currencyID"] = 2326,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 84,
			["questID"] = 75481,
			["mapPOI"] = 7508,
		},
		[86] = {
			["currencyID"] = 2356,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 76,
			["questID"] = 75481,
			["mapPOI"] = 7508,
		},
		[87] = {
			["currencyID"] = 2386,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 76,
			["questID"] = 75481,
			["mapPOI"] = 7508,
		},
		[88] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7508,
		},
		[89] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7508,
		},
		[90] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7508,
		},
	
	 -- Un'Goro Crater Circuit
		[91] = {
			["currencyID"] = 2327,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 100,
			["questID"] = 75485,
			["mapPOI"] = 7509,
		},
		[92] = {
			["currencyID"] = 2357,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 90,
			["questID"] = 75485,
			["mapPOI"] = 7509,
		},
		[93] = {
			["currencyID"] = 2387,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 92,
			["questID"] = 75485,
			["mapPOI"] = 7509,
		},
		[94] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7509,
		},
		[95] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7509,
		},
		[96] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7509,
		},
	};



-- Eastern Kingdoms Cup
	[14] = {
	 -- Gilneas Gambit
		[1] = {
			["currencyID"] = 2536,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 78,
			["questID"] = 76309,
			["mapPOI"] = 7571,
		},
		[2] = {
			["currencyID"] = 2552,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 74,
			["questID"] = 76309,
			["mapPOI"] = 7571,
		},
		[3] = {
			["currencyID"] = 2568,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 74,
			["questID"] = 76309,
			["mapPOI"] = 7571,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7571,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7571,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7571,
		},
	
	
	 -- Loch Modan Loop
		[7] = {
			["currencyID"] = 2537,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76339,
			["mapPOI"] = 7572,
		},
		[8] = {
			["currencyID"] = 2553,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 61,
			["questID"] = 76339,
			["mapPOI"] = 7572,
		},
		[9] = {
			["currencyID"] = 2569,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76339,
			["mapPOI"] = 7572,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7572,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7572,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7572,
		},
	
	 -- Searing Slalom
		[13] = {
			["currencyID"] = 2538,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 52,
			["questID"] = 76357,
			["mapPOI"] = 7573,
		},
		[14] = {
			["currencyID"] = 2554,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 46,
			["questID"] = 76357,
			["mapPOI"] = 7573,
		},
		[15] = {
			["currencyID"] = 2570,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 43,
			["questID"] = 76357,
			["mapPOI"] = 7573,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7573,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7573,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7573,
		},
	
	 -- Twilight Terror
		[19] = {
			["currencyID"] = 2539,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 73,
			["questID"] = 76364,
			["mapPOI"] = 7574,
		},
		[20] = {
			["currencyID"] = 2555,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 68,
			["questID"] = 76364,
			["mapPOI"] = 7574,
		},
		[21] = {
			["currencyID"] = 2571,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 66,
			["questID"] = 76364,
			["mapPOI"] = 7574,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7574,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7574,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7574,
		},
	
	 -- Deadwind Derby
		[25] = {
			["currencyID"] = 2540,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 60,
			["questID"] = 76380,
			["mapPOI"] = 7575,
		},
		[26] = {
			["currencyID"] = 2556,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 59,
			["questID"] = 76380,
			["mapPOI"] = 7575,
		},
		[27] = {
			["currencyID"] = 2572,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 59,
			["questID"] = 76380,
			["mapPOI"] = 7575,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7575,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7575,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7575,
		},
	
	 -- Elwynn Forest Flash
		[31] = {
			["currencyID"] = 2541,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 73,
			["questID"] = 76397,
			["mapPOI"] = 7576,
		},
		[32] = {
			["currencyID"] = 2557,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 66,
			["questID"] = 76397,
			["mapPOI"] = 7576,
		},
		[33] = {
			["currencyID"] = 2573,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76397,
			["mapPOI"] = 7576,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7576,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7576,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7576,
		},
	
	 -- Gurubashi Gala
		[37] = {
			["currencyID"] = 2542,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 56,
			["questID"] = 76438,
			["mapPOI"] = 7577,
		},
		[38] = {
			["currencyID"] = 2558,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 49,
			["questID"] = 76438,
			["mapPOI"] = 7577,
		},
		[39] = {
			["currencyID"] = 2574,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 50,
			["questID"] = 76438,
			["mapPOI"] = 7577,
		},
		[40] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7577,
		},
		[41] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7577,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7577,
		},
	
	 -- Ironforge Interceptor
		[43] = {
			["currencyID"] = 2543,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 76445,
			["mapPOI"] = 7578,
		},
		[44] = {
			["currencyID"] = 2559,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 76445,
			["mapPOI"] = 7578,
		},
		[45] = {
			["currencyID"] = 2575,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 60,
			["questID"] = 76445,
			["mapPOI"] = 7578,
		},
		[46] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7578,
		},
		[47] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7578,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7578,
		},
	
	 -- Blasted Lands Bolt
		[49] = {
			["currencyID"] = 2544,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 69,
			["questID"] = 76469,
			["mapPOI"] = 7579,
		},
		[50] = {
			["currencyID"] = 2560,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 62,
			["questID"] = 76469,
			["mapPOI"] = 7579,
		},
		[51] = {
			["currencyID"] = 2576,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 76469,
			["mapPOI"] = 7579,
		},
		[52] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7579,
		},
		[53] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7579,
		},
		[54] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7579,
		},
	
	 -- Plaguelands Plunge
		[55] = {
			["currencyID"] = 2545,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76510,
			["mapPOI"] = 7580,
		},
		[56] = {
			["currencyID"] = 2561,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 53,
			["questID"] = 76510,
			["mapPOI"] = 7580,
		},
		[57] = {
			["currencyID"] = 2577,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 58,
			["questID"] = 76510,
			["mapPOI"] = 7580,
		},
		[58] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7580,
		},
		[59] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7580,
		},
		[60] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7580,
		},
	
	 -- Booty Bay Blast
		[61] = {
			["currencyID"] = 2546,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76515,
			["mapPOI"] = 7581,
		},
		[62] = {
			["currencyID"] = 2562,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 57,
			["questID"] = 76515,
			["mapPOI"] = 7581,
		},
		[63] = {
			["currencyID"] = 2578,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 56,
			["questID"] = 76515,
			["mapPOI"] = 7581,
		},
		[64] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7581,
		},
		[65] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7581,
		},
		[66] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7581,
		},
	
	 -- Fuselight Night Flight
		[67] = {
			["currencyID"] = 2547,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 76523,
			["mapPOI"] = 7582,
		},
		[68] = {
			["currencyID"] = 2563,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 58,
			["questID"] = 76523,
			["mapPOI"] = 7582,
		},
		[69] = {
			["currencyID"] = 2579,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 58,
			["questID"] = 76523,
			["mapPOI"] = 7582,
		},
		[70] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7582,
		},
		[71] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7582,
		},
		[72] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7582,
		},
	
	 -- Krazzworks Klash
		[73] = {
			["currencyID"] = 2548,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 71,
			["questID"] = 76527,
			["mapPOI"] = 7583,
		},
		[74] = {
			["currencyID"] = 2564,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 76527,
			["mapPOI"] = 7583,
		},
		[75] = {
			["currencyID"] = 2580,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 62,
			["questID"] = 76527,
			["mapPOI"] = 7583,
		},
		[76] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7583,
		},
		[77] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7583,
		},
		[78] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7583,
		},
	
	 -- Redridge Rally
		[79] = {
			["currencyID"] = 2549,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 57,
			["questID"] = 76536,
			["mapPOI"] = 7584,
		},
		[80] = {
			["currencyID"] = 2565,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 52,
			["questID"] = 76536,
			["mapPOI"] = 7584,
		},
		[81] = {
			["currencyID"] = 2581,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 52,
			["questID"] = 76536,
			["mapPOI"] = 7584,
		},
		[82] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7584,
		},
		[83] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7584,
		},
		[84] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7584,
		},
	};



-- Outland Cup
	[15] = {
		 -- Hellfire Hustle
		[1] = {
			["currencyID"] = 2600,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 77102,
			["mapPOI"] = 7589,
		},
		[2] = {
			["currencyID"] = 2615,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77102,
			["mapPOI"] = 7589,
		},
		[3] = {
			["currencyID"] = 2630,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 77102,
			["mapPOI"] = 7589,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7589,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7589,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7589,
		},
		
		 -- Coilfang Caper
		[7] = {
			["currencyID"] = 2601,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 77169,
			["mapPOI"] = 7590,
		},
		[8] = {
			["currencyID"] = 2616,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 77169,
			["mapPOI"] = 7590,
		},
		[9] = {
			["currencyID"] = 2631,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 77169,
			["mapPOI"] = 7590,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7590,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7590,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7590,
		},
		
		 -- Blade's Edge Brawl
		[13] = {
			["currencyID"] = 2602,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 77205,
			["mapPOI"] = 7591,
		},
		[14] = {
			["currencyID"] = 2617,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 77205,
			["mapPOI"] = 7591,
		},
		[15] = {
			["currencyID"] = 2632,
			["silverTime"] = 78,
			["goldTime"] = 75,
			["questID"] = 77205,
			["mapPOI"] = 7591,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7591,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7591,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7591,
		},
		
		 -- Telaar Tear
		[19] = {
			["currencyID"] = 2603,
			["silverTime"] = 69,
			["goldTime"] = 64,
			["questID"] = 77238,
			["mapPOI"] = 7592,
		},
		[20] = {
			["currencyID"] = 2618,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 77238,
			["mapPOI"] = 7592,
		},
		[21] = {
			["currencyID"] = 2633,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 77238,
			["mapPOI"] = 7592,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7592,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7592,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7592,
		},
		
		 -- Razorthorn Rise Rush
		[25] = {
			["currencyID"] = 2604,
			["silverTime"] = 72,
			["goldTime"] = 67,
			["questID"] = 77260,
			["mapPOI"] = 7593,
		},
		[26] = {
			["currencyID"] = 2619,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 77260,
			["mapPOI"] = 7593,
		},
		[27] = {
			["currencyID"] = 2634,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 77260,
			["mapPOI"] = 7593,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7593,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7593,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7593,
		},
		
		 -- Auchindoun Coaster
		[31] = {
			["currencyID"] = 2605,
			["silverTime"] = 78,
			["goldTime"] = 73,
			["questID"] = 77264,
			["mapPOI"] = 7594,
		},
		[32] = {
			["currencyID"] = 2620,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 77264,
			["mapPOI"] = 7594,
		},
		[33] = {
			["currencyID"] = 2635,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 77264,
			["mapPOI"] = 7594,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7594,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7594,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7594,
		},
		
		 -- Tempest Keep Sweep
		[37] = {
			["currencyID"] = 2606,
			["silverTime"] = 105,
			["goldTime"] = 100,
			["questID"] = 77278,
			["mapPOI"] = 7595,
		},
		[38] = {
			["currencyID"] = 2621,
			["silverTime"] = 90,
			["goldTime"] = 87,
			["questID"] = 77278,
			["mapPOI"] = 7595,
		},
		[39] = {
			["currencyID"] = 2636,
			["silverTime"] = 91,
			["goldTime"] = 88,
			["questID"] = 77278,
			["mapPOI"] = 7595,
		},
		[40] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7595,
		},
		[41] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7595,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7595,
		},
		
		 -- Shattrath City Sashay
		[43] = {
			["currencyID"] = 2607,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 77322,
			["mapPOI"] = 7596,
		},
		[44] = {
			["currencyID"] = 2622,
			["silverTime"] = 68,
			["goldTime"] = 65,
			["questID"] = 77322,
			["mapPOI"] = 7596,
		},
		[45] = {
			["currencyID"] = 2637,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 77322,
			["mapPOI"] = 7596,
		},
		[46] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7596,
		},
		[47] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7596,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7596,
		},
		
		 -- Shadowmoon Slam
		[49] = {
			["currencyID"] = 2608,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 77346,
			["mapPOI"] = 7597,
		},
		[50] = {
			["currencyID"] = 2623,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 77346,
			["mapPOI"] = 7597,
		},
		[51] = {
			["currencyID"] = 2638,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 77346,
			["mapPOI"] = 7597,
		},
		[52] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7597,
		},
		[53] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7597,
		},
		[54] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7597,
		},
		
		 -- Eco-Dome Excursion
		[55] = {
			["currencyID"] = 2609,
			["silverTime"] = 120,
			["goldTime"] = 115,
			["questID"] = 77398,
			["mapPOI"] = 7598,
		},
		[56] = {
			["currencyID"] = 2624,
			["silverTime"] = 112,
			["goldTime"] = 109,
			["questID"] = 77398,
			["mapPOI"] = 7598,
		},
		[57] = {
			["currencyID"] = 2639,
			["silverTime"] = 113,
			["goldTime"] = 110,
			["questID"] = 77398,
			["mapPOI"] = 7598,
		},
		[58] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7598,
		},
		[59] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7598,
		},
		[60] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7598,
		},
		
		 -- Warmaul Wingding
		[61] = {
			["currencyID"] = 2610,
			["silverTime"] = 85,
			["goldTime"] = 80,
			["questID"] = 77589,
			["mapPOI"] = 7599,
		},
		[62] = {
			["currencyID"] = 2625,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 77589,
			["mapPOI"] = 7599,
		},
		[63] = {
			["currencyID"] = 2640,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77589,
			["mapPOI"] = 7599,
		},
		[64] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7599,
		},
		[65] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7599,
		},
		[66] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7599,
		},
		
		 -- Skettis Scramble
		[67] = {
			["currencyID"] = 2611,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 77645,
			["mapPOI"] = 7600,
		},
		[68] = {
			["currencyID"] = 2626,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 77645,
			["mapPOI"] = 7600,
		},
		[69] = {
			["currencyID"] = 2641,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 77645,
			["mapPOI"] = 7600,
		},
		[70] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7600,
		},
		[71] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7600,
		},
		[72] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7600,
		},
		
		 -- Fel Pit Fracas
		[73] = {
			["currencyID"] = 2612,
			["silverTime"] = 82,
			["goldTime"] = 77,
			["questID"] = 77684,
			["mapPOI"] = 7601,
		},
		[74] = {
			["currencyID"] = 2627,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77684,
			["mapPOI"] = 7601,
		},
		[75] = {
			["currencyID"] = 2642,
			["silverTime"] = 79,
			["goldTime"] = 76,
			["questID"] = 77684,
			["mapPOI"] = 7601,
		},
		[76] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7601,
		},
		[77] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7601,
		},
		[78] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7601,
		},
	},


-- Northrend Cup
	[16] = {
	 -- Scalawag Slither
		[1] = {
			["currencyID"] = 2720,
			["silverTime"] = 78,
			["goldTime"] = 73,
			["questID"] = 78301,
			["mapPOI"] = 7689,
		},
		[2] = {
			["currencyID"] = 2738,
			["silverTime"] = 71,
			["goldTime"] = 68,
			["questID"] = 78301,
			["mapPOI"] = 7689,
		},
		[3] = {
			["currencyID"] = 2756,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 78301,
			["mapPOI"] = 7689,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7689,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7689,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7689,
		},
	
	 -- Daggercap Dart
		[7] = {
			["currencyID"] = 2721,
			["silverTime"] = 82,
			["goldTime"] = 77,
			["questID"] = 78325,
			["mapPOI"] = 7690,
		},
		[8] = {
			["currencyID"] = 2739,
			["silverTime"] = 79,
			["goldTime"] = 76,
			["questID"] = 78325,
			["mapPOI"] = 7690,
		},
		[9] = {
			["currencyID"] = 2757,
			["silverTime"] = 79,
			["goldTime"] = 76,
			["questID"] = 78325,
			["mapPOI"] = 7690,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7690,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7690,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7690,
		},
	
	 -- Blackriver Burble
		[13] = {
			["currencyID"] = 2722,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 78334,
			["mapPOI"] = 7691,
		},
		[14] = {
			["currencyID"] = 2740,
			["silverTime"] = 70,
			["goldTime"] = 67,
			["questID"] = 78334,
			["mapPOI"] = 7691,
		},
		[15] = {
			["currencyID"] = 2758,
			["silverTime"] = 74,
			["goldTime"] = 71,
			["questID"] = 78334,
			["mapPOI"] = 7691,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7691,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7691,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7691,
		},
	
	 -- Zul'Drak Zephyr
		[19] = {
			["currencyID"] = 2723,
			["silverTime"] = 70,
			["goldTime"] = 65,
			["questID"] = 78346,
			["mapPOI"] = 7692,
		},
		[20] = {
			["currencyID"] = 2741,
			["silverTime"] = 65,
			["goldTime"] = 62,
			["questID"] = 78346,
			["mapPOI"] = 7692,
		},
		[21] = {
			["currencyID"] = 2759,
			["silverTime"] = 70,
			["goldTime"] = 67,
			["questID"] = 78346,
			["mapPOI"] = 7692,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7692,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7692,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7692,
		},
	
	 -- Makers' Marathon
		[25] = {
			["currencyID"] = 2724,
			["silverTime"] = 105,
			["goldTime"] = 100,
			["questID"] = 78389,
			["mapPOI"] = 7693,
		},
		[26] = {
			["currencyID"] = 2742,
			["silverTime"] = 96,
			["goldTime"] = 93,
			["questID"] = 78389,
			["mapPOI"] = 7693,
		},
		[27] = {
			["currencyID"] = 2760,
			["silverTime"] = 101,
			["goldTime"] = 98,
			["questID"] = 78389,
			["mapPOI"] = 7693,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7693,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7693,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7693,
		},
	
	 -- Crystalsong Crisis
		[31] = {
			["currencyID"] = 2725,
			["silverTime"] = 102,
			["goldTime"] = 97,
			["questID"] = 78441,
			["mapPOI"] = 7694,
		},
		[32] = {
			["currencyID"] = 2743,
			["silverTime"] = 97,
			["goldTime"] = 94,
			["questID"] = 78441,
			["mapPOI"] = 7694,
		},
		[33] = {
			["currencyID"] = 2761,
			["silverTime"] = 99,
			["goldTime"] = 96,
			["questID"] = 78441,
			["mapPOI"] = 7694,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7694,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7694,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7694,
		},
	
	 -- Dragonblight Dragon Flight
		[37] = {
			["currencyID"] = 2726,
			["silverTime"] = 120,
			["goldTime"] = 115,
			["questID"] = 78454,
			["mapPOI"] = 7695,
		},
		[38] = {
			["currencyID"] = 2744,
			["silverTime"] = 113,
			["goldTime"] = 110,
			["questID"] = 78454,
			["mapPOI"] = 7695,
		},
		[39] = {
			["currencyID"] = 2762,
			["silverTime"] = 113,
			["goldTime"] = 110,
			["questID"] = 78454,
			["mapPOI"] = 7695,
		},
		[40] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7695,
		},
		[41] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7695,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7695,
		},
	
	 -- Citadel Sortie
		[43] = {
			["currencyID"] = 2727,
			["silverTime"] = 115,
			["goldTime"] = 110,
			["questID"] = 78499,
			["mapPOI"] = 7696,
		},
		[44] = {
			["currencyID"] = 2745,
			["silverTime"] = 106,
			["goldTime"] = 103,
			["questID"] = 78499,
			["mapPOI"] = 7696,
		},
		[45] = {
			["currencyID"] = 2763,
			["silverTime"] = 107,
			["goldTime"] = 104,
			["questID"] = 78499,
			["mapPOI"] = 7696,
		},
		[46] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7696,
		},
		[47] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7696,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7696,
		},
	
	 -- Sholazar Spree
		[49] = {
			["currencyID"] = 2728,
			["silverTime"] = 93,
			["goldTime"] = 88,
			["questID"] = 78558,
			["mapPOI"] = 7697,
		},
		[50] = {
			["currencyID"] = 2746,
			["silverTime"] = 88,
			["goldTime"] = 85,
			["questID"] = 78558,
			["mapPOI"] = 7697,
		},
		[51] = {
			["currencyID"] = 2764,
			["silverTime"] = 88,
			["goldTime"] = 85,
			["questID"] = 78558,
			["mapPOI"] = 7697,
		},
		[52] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7697,
		},
		[53] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7697,
		},
		[54] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7697,
		},
	
	 -- Geothermal Jaunt
		[55] = {
			["currencyID"] = 2729,
			["silverTime"] = 50,
			["goldTime"] = 45,
			["questID"] = 78608,
			["mapPOI"] = 7698,
		},
		[56] = {
			["currencyID"] = 2747,
			["silverTime"] = 40,
			["goldTime"] = 37,
			["questID"] = 78608,
			["mapPOI"] = 7698,
		},
		[57] = {
			["currencyID"] = 2765,
			["silverTime"] = 40,
			["goldTime"] = 37,
			["questID"] = 78608,
			["mapPOI"] = 7698,
		},
		[58] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7698,
		},
		[59] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7698,
		},
		[60] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7698,
		},
	
	 -- Gundrak Fast Track
		[61] = {
			["currencyID"] = 2730,
			["silverTime"] = 65,
			["goldTime"] = 60,
			["questID"] = 79268,
			["mapPOI"] = 7699,
		},
		[62] = {
			["currencyID"] = 2748,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 79268,
			["mapPOI"] = 7699,
		},
		[63] = {
			["currencyID"] = 2766,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 79268,
			["mapPOI"] = 7699,
		},
		[64] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7699,
		},
		[65] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7699,
		},
		[66] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7699,
		},
	
	 -- Coldarra Climb
		[67] = {
			["currencyID"] = 2731,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 79272,
			["mapPOI"] = 7700,
		},
		[68] = {
			["currencyID"] = 2749,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 79272,
			["mapPOI"] = 7700,
		},
		[69] = {
			["currencyID"] = 2767,
			["silverTime"] = 58,
			["goldTime"] = 55,
			["questID"] = 79272,
			["mapPOI"] = 7700,
		},
		[70] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7700,
		},
		[71] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7700,
		},
		[72] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
			["mapPOI"] = 7700,
		},

	};


};