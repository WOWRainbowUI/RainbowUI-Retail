local _, DR = ...

local PLACEHOLDER = "[PH]"

DR.DragonRaceZones = {
	[1] = 2022,
	[2] = 2023,
	[3] = 2024,
	[4] = 2025,
	[5] = 2151,
	[6] = 2133,
	[7] = 2200,
	[8] = 12,
	[9] = 13,
	[10] = 101,
	[11] = 113,
};

DR.ZoneIcons = {
	[2022] = 4672500, --  Waking Shores
	[2023] = 4672498, -- Ohn'ahran Plains
	[2024] = 4672495, -- The Azure Span
	[2025] = 4672499, -- Thaldraszus
	[2151] = 4672496, -- Forbidden Reach
	[2133] = 5140838, -- Zaralek Caverns
	[2200] = 5390645, -- Emerald Dream

};

DR.WorldQuestIDs = {
	-- The Waking Shores
	70415,
	70410,
	70416,
	70382,
	70412,
	70417,
	70413,
	70418,

	--Ohn'ahran Plains
	70420,
	70424,
	70712,
	70421,
	70423,
	70422,
	70419,

	--The Azure Span
	70425,
	70430,
	70429,
	70427,
	70426,
	70428,

	--Thaldraszus
	70436,
	70432,
	70431,
	70435,
	70434,
	70433,

	--The Forbidden Reach
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

	--Emerald Dream
	78434,
	78438,
	78435,
	78437,
	78436,
	78439,
};

DR.DragonRaceCurrencies = {
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
-- Waking Shores
	--Ruby Lifeshrine Loop
	[1] = {
		[1] = {
			["currencyID"] = 2042,
			["silverTime"] = 56, --56
			["goldTime"] = 56, -- 53
			["questID"] = 66679,
		},
		[2] = {
			["currencyID"] = 2044,
			["silverTime"] = 57,
			["goldTime"] = 52,
			["questID"] = 66679,
		},
		[3] = {
			["currencyID"] = 2154,
			["silverTime"] = 55,
			["goldTime"] = 50,
			["questID"] = 66679,
		},
		[4] = {
			["currencyID"] = 2421,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 66679,
		},
		[5] = {
			["currencyID"] = 2422,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 66679,
		},
		[6] = {
			["currencyID"] = 2664,
			["silverTime"] = 70,
			["goldTime"] = 65,
			["questID"] = 66679,
		},

		--Wild Preserve Slalom
		[7] = {
			["currencyID"] = 2048,
			["silverTime"] = 45,
			["goldTime"] = 42,
			["questID"] = 66721,
		},
		[8] = {
			["currencyID"] = 2049,
			["silverTime"] = 45,
			["goldTime"] = 40,
			["questID"] = 66721,
		},
		[9] = {
			["currencyID"] = 2176,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 66721,
		},
		[10] = {
			["currencyID"] = 2423,
			["silverTime"] = 51,
			["goldTime"] = 48,
			["questID"] = 66721,
		},
		[11] = {
			["currencyID"] = 2424,
			["silverTime"] = 52,
			["goldTime"] = 49,
			["questID"] = 66721,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		--Emberflow Flight
		[13] = {
			["currencyID"] = 2052,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66727,
		},
		[14] = {
			["currencyID"] = 2053,
			["silverTime"] = 49,
			["goldTime"] = 44,
			["questID"] = 66727,
		},
		[15] = {
			["currencyID"] = 2177,
			["silverTime"] = 50,
			["goldTime"] = 45,
			["questID"] = 66727,
		},
		[16] = {
			["currencyID"] = 2425,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66727,
		},
		[17] = {
			["currencyID"] = 2426,
			["silverTime"] = 54,
			["goldTime"] = 51,
			["questID"] = 66727,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		--Apex Canopy River Run
		[19] = {
			["currencyID"] = 2054,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 66732,
		},
		[20] = {
			["currencyID"] = 2055,
			["silverTime"] = 50,
			["goldTime"] = 45,
			["questID"] = 66732,
		},
		[21] = {
			["currencyID"] = 2178,
			["silverTime"] = 53,
			["goldTime"] = 48,
			["questID"] = 66732,
		},
		[22] = {
			["currencyID"] = 2427,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 66732,
		},
		[23] = {
			["currencyID"] = 2428,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 66732,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		--Uktulut Coaster
		[25] = {
			["currencyID"] = 2056,
			["silverTime"] = 48,
			["goldTime"] = 45,
			["questID"] = 66777,
		},
		[26] = {
			["currencyID"] = 2057,
			["silverTime"] = 45,
			["goldTime"] = 40,
			["questID"] = 66777,
		},
		[27] = {
			["currencyID"] = 2179,
			["silverTime"] = 48,
			["goldTime"] = 43,
			["questID"] = 66777,
		},
		[28] = {
			["currencyID"] = 2429,
			["silverTime"] = 49,
			["goldTime"] = 46,
			["questID"] = 66777,
		},
		[29] = {
			["currencyID"] = 2430,
			["silverTime"] = 51,
			["goldTime"] = 48,
			["questID"] = 66777,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		--Wingrest Roundabout
		[31] = {
			["currencyID"] = 2058,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 66786,
		},
		[32] = {
			["currencyID"] = 2059,
			["silverTime"] = 58,
			["goldTime"] = 53,
			["questID"] = 66786,
		},
		[33] = {
			["currencyID"] = 2180,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 66786,
		},
		[34] = {
			["currencyID"] = 2431,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 66786,
		},
		[35] = {
			["currencyID"] = 2432,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 66786,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		--Flashfrost Flyover
		[37] = {
			["currencyID"] = 2046,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 66710,
		},
		[38] = {
			["currencyID"] = 2047,
			["silverTime"] = 66,
			["goldTime"] = 61,
			["questID"] = 66710,
		},
		[39] = {
			["currencyID"] = 2181,
			["silverTime"] = 65,
			["goldTime"] = 60,
			["questID"] = 66710,
		},
		[40] = {
			["currencyID"] = 2433,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 66710,
		},
		[41] = {
			["currencyID"] = 2434,
			["silverTime"] = 74,
			["goldTime"] = 69,
			["questID"] = 66710,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		--Wild Preserve Circuit
		[43] = {
			["currencyID"] = 2050,
			["silverTime"] = 43,
			["goldTime"] = 40,
			["questID"] = 66725,
		},
		[44] = {
			["currencyID"] = 2051,
			["silverTime"] = 43,
			["goldTime"] = 38,
			["questID"] = 66725,
		},
		[45] = {
			["currencyID"] = 2182,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 66725,
		},
		[46] = {
			["currencyID"] = 2435,
			["silverTime"] = 46,
			["goldTime"] = 43,
			["questID"] = 66725,
		},
		[47] = {
			["currencyID"] = 2436,
			["silverTime"] = 47,
			["goldTime"] = 44,
			["questID"] = 66725,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	},



-- Ohn'ahran Plains
	-- Sundapple Copse Circuit
	[2] = {
		[1] = {
			["currencyID"] = 2060,
			["silverTime"] = 52,
			["goldTime"] = 49,
			["questID"] = 66835,
		},
		[2] = {
			["currencyID"] = 2061,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 66835,
		},
		[3] = {
			["currencyID"] = 2183,
			["silverTime"] = 50,
			["goldTime"] = 45,
			["questID"] = 66835,
		},
		[4] = {
			["currencyID"] = 2437,
			["silverTime"] = 54,
			["goldTime"] = 51,
			["questID"] = 66835,
		},
		[5] = {
			["currencyID"] = 2439,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66835,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		-- Fen Flythrough
		[7] = {
			["currencyID"] = 2062,
			["silverTime"] = 51,
			["goldTime"] = 48,
			["questID"] = 66877,
		},
		[8] = {
			["currencyID"] = 2063,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 66877,
		},
		[9] = {
			["currencyID"] = 2184,
			["silverTime"] = 52,
			["goldTime"] = 47,
			["questID"] = 66877,
		},
		[10] = {
			["currencyID"] = 2440,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66877,
		},
		[11] = {
			["currencyID"] = 2441,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66877,
		},
		[12] = {
			["currencyID"] = 2665,
			["silverTime"] = 87,
			["goldTime"] = 82,
			["questID"] = 66877,
		},

		-- Ravine River Run
		[13] = {
			["currencyID"] = 2064,
			["silverTime"] = 52,
			["goldTime"] = 49,
			["questID"] = 66880,
		},
		[14] = {
			["currencyID"] = 2065,
			["silverTime"] = 52,
			["goldTime"] = 47,
			["questID"] = 66880,
		},
		[15] = {
			["currencyID"] = 2185,
			["silverTime"] = 51,
			["goldTime"] = 46,
			["questID"] = 66880,
		},
		[16] = {
			["currencyID"] = 2442,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 66880,
		},
		[17] = {
			["currencyID"] = 2443,
			["silverTime"] = 54,
			["goldTime"] = 51,
			["questID"] = 66880,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		-- Emerald Gardens Ascent
		[19] = {
			["currencyID"] = 2066,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 66885,
		},
		[20] = {
			["currencyID"] = 2067,
			["silverTime"] = 60,
			["goldTime"] = 55,
			["questID"] = 66885,
		},
		[21] = {
			["currencyID"] = 2186,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 66885,
		},
		[22] = {
			["currencyID"] = 2444,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 66885,
		},
		[23] = {
			["currencyID"] = 2445,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 66885,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		-- Maruukai Dash
		[25] = {
			["currencyID"] = 2069,
			["silverTime"] = 28,
			["goldTime"] = 25,
			["questID"] = 66921,
		},
		[26] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[27] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[28] = {
			["currencyID"] = 2446,
			["silverTime"] = 27,
			["goldTime"] = 24,
			["questID"] = 66921,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		-- Mirror of the Sky Dash
		[31] = {
			["currencyID"] = 2070,
			["silverTime"] = 29,
			["goldTime"] = 26,
			["questID"] = 66933,
		},
		[32] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[33] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[34] = {
			["currencyID"] = 2447,
			["silverTime"] = 30,
			["goldTime"] = 27,
			["questID"] = 66933,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		-- River Rapids Route
		[37] = {
			["currencyID"] = 2119,
			["silverTime"] = 51,
			["goldTime"] = 48,
			["questID"] = 70710,
		},
		[38] = {
			["currencyID"] = 2120,
			["silverTime"] = 48,
			["goldTime"] = 43,
			["questID"] = 70710,
		},
		[39] = {
			["currencyID"] = 2187,
			["silverTime"] = 49,
			["goldTime"] = 44,
			["questID"] = 70710,
		},
		[40] = {
			["currencyID"] = 2448,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 70710,
		},
		[41] = {
			["currencyID"] = 2449,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 70710,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	},


-- Azure Span
	 -- The Azure Span Sprint
	[3] = {
		[1] = {
			["currencyID"] = 2074,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 66946,
		},
		[2] = {
			["currencyID"] = 2075,
			["silverTime"] = 63,
			["goldTime"] = 58,
			["questID"] = 66946,
		},
		[3] = {
			["currencyID"] = 2188,
			["silverTime"] = 65,
			["goldTime"] = 60,
			["questID"] = 66946,
		},
		[4] = {
			["currencyID"] = 2450,
			["silverTime"] = 70,
			["goldTime"] = 67,
			["questID"] = 66946,
		},
		[5] = {
			["currencyID"] = 2451,
			["silverTime"] = 72,
			["goldTime"] = 69,
			["questID"] = 66946,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		 -- The Azure Span Slalom
		[7] = {
			["currencyID"] = 2076,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 67002,
		},
		[8] = {
			["currencyID"] = 2077,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 67002,
		},
		[9] = {
			["currencyID"] = 2189,
			["silverTime"] = 58,
			["goldTime"] = 53,
			["questID"] = 67002,
		},
		[10] = {
			["currencyID"] = 2452,
			["silverTime"] = 58,
			["goldTime"] = 55,
			["questID"] = 67002,
		},
		[11] = {
			["currencyID"] = 2453,
			["silverTime"] = 58,
			["goldTime"] = 55,
			["questID"] = 67002,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		 -- The Vakthros Ascent
		[13] = {
			["currencyID"] = 2078,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 67031,
		},
		[14] = {
			["currencyID"] = 2079,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 67031,
		},
		[15] = {
			["currencyID"] = 2190,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 67031,
		},
		[16] = {
			["currencyID"] = 2454,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 67031,
		},
		[17] = {
			["currencyID"] = 2455,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 67031,
		},
		[18] = {
			["currencyID"] = 2666,
			["silverTime"] = 125,
			["goldTime"] = 120,
			["questID"] = 67031,
		},

		 -- Iskaara Tour
		[19] = {
			["currencyID"] = 2083,
			["silverTime"] = 78,
			["goldTime"] = 75,
			["questID"] = 67296,
		},
		[20] = {
			["currencyID"] = 2084,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 67296,
		},
		[21] = {
			["currencyID"] = 2191,
			["silverTime"] = 72,
			["goldTime"] = 67,
			["questID"] = 67296,
		},
		[22] = {
			["currencyID"] = 2456,
			["silverTime"] = 81,
			["goldTime"] = 78,
			["questID"] = 67296,
		},
		[23] = {
			["currencyID"] = 2457,
			["silverTime"] = 82,
			["goldTime"] = 79,
			["questID"] = 67296,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		 -- Frostland Flyover
		[25] = {
			["currencyID"] = 2085,
			["silverTime"] = 79,
			["goldTime"] = 76,
			["questID"] = 67565,
		},
		[26] = {
			["currencyID"] = 2086,
			["silverTime"] = 77,
			["goldTime"] = 72,
			["questID"] = 67565,
		},
		[27] = {
			["currencyID"] = 2192,
			["silverTime"] = 74,
			["goldTime"] = 69,
			["questID"] = 67565,
		},
		[28] = {
			["currencyID"] = 2458,
			["silverTime"] = 88,
			["goldTime"] = 85,
			["questID"] = 67565,
		},
		[29] = {
			["currencyID"] = 2459,
			["silverTime"] = 86,
			["goldTime"] = 83,
			["questID"] = 67565,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

		 -- Archive Ambit
		[31] = {
			["currencyID"] = 2089,
			["silverTime"] = 94,
			["goldTime"] = 91,
			["questID"] = 67741,
		},
		[32] = {
			["currencyID"] = 2090,
			["silverTime"] = 86,
			["goldTime"] = 81,
			["questID"] = 67741,
		},
		[33] = {
			["currencyID"] = 2193,
			["silverTime"] = 81,
			["goldTime"] = 76,
			["questID"] = 67741,
		},
		[34] = {
			["currencyID"] = 2460,
			["silverTime"] = 93,
			["goldTime"] = 90,
			["questID"] = 67741,
		},
		[35] = {
			["currencyID"] = 2461,
			["silverTime"] = 95,
			["goldTime"] = 92,
			["questID"] = 67741,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	},


-- Thaldraszus
	[4] = {
		 -- The Flowing Forest Flight
		[1] = {
			["currencyID"] = 2080,
			["silverTime"] = 52,
			["goldTime"] = 49,
			["questID"] = 67095,
		},
		[2] = {
			["currencyID"] = 2081,
			["silverTime"] = 45,
			["goldTime"] = 40,
			["questID"] = 67095,
		},
		[3] = {
			["currencyID"] = 2194,
			["silverTime"] = 46,
			["goldTime"] = 41,
			["questID"] = 67095,
		},
		[4] = {
			["currencyID"] = 2462,
			["silverTime"] = 50,
			["goldTime"] = 47,
			["questID"] = 67095,
		},
		[5] = {
			["currencyID"] = 2463,
			["silverTime"] = 49,
			["goldTime"] = 46,
			["questID"] = 67095,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Tyrhold Trial
		[7] = {
			["currencyID"] = 2092,
			["silverTime"] = 84,
			["goldTime"] = 81,
			["questID"] = 69957,
		},
		[8] = {
			["currencyID"] = 2093,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 69957,
		},
		[9] = {
			["currencyID"] = 2195,
			["silverTime"] = 64,
			["goldTime"] = 59,
			["questID"] = 69957,
		},
		[10] = {
			["currencyID"] = 2464,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 69957,
		},
		[11] = {
			["currencyID"] = 2465,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 69957,
		},
		[12] = {
			["currencyID"] = 2667,
			["silverTime"] = 85,
			["goldTime"] = 80,
			["questID"] = 69957,
		},
		
		 -- Cliffside Circuit
		[13] = {
			["currencyID"] = 2096,
			["silverTime"] = 72,
			["goldTime"] = 69,
			["questID"] = 70051,
		},
		[14] = {
			["currencyID"] = 2097,
			["silverTime"] = 71,
			["goldTime"] = 66,
			["questID"] = 70051,
		},
		[15] = {
			["currencyID"] = 2196,
			["silverTime"] = 74,
			["goldTime"] = 69,
			["questID"] = 70051,
		},
		[16] = {
			["currencyID"] = 2466,
			["silverTime"] = 84,
			["goldTime"] = 81,
			["questID"] = 70051,
		},
		[17] = {
			["currencyID"] = 2467,
			["silverTime"] = 83,
			["goldTime"] = 80,
			["questID"] = 70051,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Academy Ascent
		[19] = {
			["currencyID"] = 2098,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 70059,
		},
		[20] = {
			["currencyID"] = 2099,
			["silverTime"] = 57,
			["goldTime"] = 52,
			["questID"] = 70059,
		},
		[21] = {
			["currencyID"] = 2197,
			["silverTime"] = 58,
			["goldTime"] = 53,
			["questID"] = 70059,
		},
		[22] = {
			["currencyID"] = 2468,
			["silverTime"] = 68,
			["goldTime"] = 65,
			["questID"] = 70059,
		},
		[23] = {
			["currencyID"] = 2469,
			["silverTime"] = 68,
			["goldTime"] = 65,
			["questID"] = 70059,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Garden Gallivant
		[25] = {
			["currencyID"] = 2101,
			["silverTime"] = 64,
			["goldTime"] = 61,
			["questID"] = 70157,
		},
		[26] = {
			["currencyID"] = 2102,
			["silverTime"] = 59,
			["goldTime"] = 54,
			["questID"] = 70157,
		},
		[27] = {
			["currencyID"] = 2198,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 70157,
		},
		[28] = {
			["currencyID"] = 2470,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 70157,
		},
		[29] = {
			["currencyID"] = 2471,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 70157,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Caverns Criss-Cross
		[31] = {
			["currencyID"] = 2103,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 70161,
		},
		[32] = {
			["currencyID"] = 2104,
			["silverTime"] = 50,
			["goldTime"] = 45,
			["questID"] = 70161,
		},
		[33] = {
			["currencyID"] = 2199,
			["silverTime"] = 52,
			["goldTime"] = 47,
			["questID"] = 70161,
		},
		[34] = {
			["currencyID"] = 2472,
			["silverTime"] = 59,
			["goldTime"] = 56,
			["questID"] = 70161,
		},
		[35] = {
			["currencyID"] = 2473,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 70161,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	},


-- Forbidden Reach
	[5] = {
		 -- Stormsunder Crater Circuit
		[1] = {
			["currencyID"] = 2201,
			["silverTime"] = 46,
			["goldTime"] = 43,
			["questID"] = 73017,
		},
		[2] = {
			["currencyID"] = 2207,
			["silverTime"] = 47,
			["goldTime"] = 42,
			["questID"] = 73017,
		},
		[3] = {
			["currencyID"] = 2213,
			["silverTime"] = 47,
			["goldTime"] = 42,
			["questID"] = 73017,
		},
		[4] = {
			["currencyID"] = 2474,
			["silverTime"] = 48,
			["goldTime"] = 45,
			["questID"] = 73017,
		},
		[5] = {
			["currencyID"] = 2475,
			["silverTime"] = 47,
			["goldTime"] = 44,
			["questID"] = 73017,
		},
		[6] = {
			["currencyID"] = 2668,
			["silverTime"] = 97,
			["goldTime"] = 92,
			["questID"] = 73017,
		},
		
		 -- Morqut Ascent
		[7] = {
			["currencyID"] = 2202,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 73020,
		},
		[8] = {
			["currencyID"] = 2208,
			["silverTime"] = 54,
			["goldTime"] = 49,
			["questID"] = 73020,
		},
		[9] = {
			["currencyID"] = 2214,
			["silverTime"] = 57,
			["goldTime"] = 52,
			["questID"] = 73020,
		},
		[10] = {
			["currencyID"] = 2476,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 73020,
		},
		[11] = {
			["currencyID"] = 2477,
			["silverTime"] = 53,
			["goldTime"] = 50,
			["questID"] = 73020,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Aerie Chasm
		[13] = {
			["currencyID"] = 2203,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 73025,
		},
		[14] = {
			["currencyID"] = 2209,
			["silverTime"] = 55,
			["goldTime"] = 50,
			["questID"] = 73025,
		},
		[15] = {
			["currencyID"] = 2215,
			["silverTime"] = 55,
			["goldTime"] = 50,
			["questID"] = 73025,
		},
		[16] = {
			["currencyID"] = 2478,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 73025,
		},
		[17] = {
			["currencyID"] = 2479,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 73025,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Southern Reach Route
		[19] = {
			["currencyID"] = 2204,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 73029,
		},
		[20] = {
			["currencyID"] = 2210,
			["silverTime"] = 73,
			["goldTime"] = 68,
			["questID"] = 73029,
		},
		[21] = {
			["currencyID"] = 2216,
			["silverTime"] = 68,
			["goldTime"] = 63,
			["questID"] = 73029,
		},
		[22] = {
			["currencyID"] = 2480,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 73029,
		},
		[23] = {
			["currencyID"] = 2481,
			["silverTime"] = 71,
			["goldTime"] = 68,
			["questID"] = 73029,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Caldera Coaster
		[25] = {
			["currencyID"] = 2205,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 73033,
		},
		[26] = {
			["currencyID"] = 2211,
			["silverTime"] = 57,
			["goldTime"] = 52,
			["questID"] = 73033,
		},
		[27] = {
			["currencyID"] = 2217,
			["silverTime"] = 54,
			["goldTime"] = 49,
			["questID"] = 73033,
		},
		[28] = {
			["currencyID"] = 2482,
			["silverTime"] = 58,
			["goldTime"] = 55,
			["questID"] = 73033,
		},
		[29] = {
			["currencyID"] = 2483,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 73033,
		},
		
		 -- Forbidden Reach Rush
		[30] = {
			["currencyID"] = 2206,
			["silverTime"] = 62,
			["goldTime"] = 59,
			["questID"] = 73061,
		},
		[31] = {
			["currencyID"] = 2212,
			["silverTime"] = 61,
			["goldTime"] = 56,
			["questID"] = 73061,
		},
		[32] = {
			["currencyID"] = 2218,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 73061,
		},
		[33] = {
			["currencyID"] = 2484,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 73061,
		},
		[34] = {
			["currencyID"] = 2485,
			["silverTime"] = 63,
			["goldTime"] = 60,
			["questID"] = 73061,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	},


-- Zaralek Caverns
	[6] = {
		 -- Crystal Circuit
		[1] = {
			["currencyID"] = 2246,
			["silverTime"] = 68,
			["goldTime"] = 63,
			["questID"] = 74839,
		},
		[2] = {
			["currencyID"] = 2252,
			["silverTime"] = 60,
			["goldTime"] = 55,
			["questID"] = 74839,
		},
		[3] = {
			["currencyID"] = 2258,
			["silverTime"] = 58,
			["goldTime"] = 53,
			["questID"] = 74839,
		},
		[4] = {
			["currencyID"] = 2486,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 74839,
		},
		[5] = {
			["currencyID"] = 2487,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 74839,
		},
		[6] = {
			["currencyID"] = 2669,
			["silverTime"] = 100,
			["goldTime"] = 95,
			["questID"] = 74839,
		},
		
		 -- Caldera Cruise
		[7] = {
			["currencyID"] = 2247,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 74889,
		},
		[8] = {
			["currencyID"] = 2253,
			["silverTime"] = 73,
			["goldTime"] = 68,
			["questID"] = 74889,
		},
		[9] = {
			["currencyID"] = 2259,
			["silverTime"] = 73,
			["goldTime"] = 68,
			["questID"] = 74889,
		},
		[10] = {
			["currencyID"] = 2488,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 74889,
		},
		[11] = {
			["currencyID"] = 2489,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 74889,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Brimstone Scramble
		[13] = {
			["currencyID"] = 2248,
			["silverTime"] = 72,
			["goldTime"] = 69,
			["questID"] = 74939,
		},
		[14] = {
			["currencyID"] = 2254,
			["silverTime"] = 69,
			["goldTime"] = 64,
			["questID"] = 74939,
		},
		[15] = {
			["currencyID"] = 2260,
			["silverTime"] = 69,
			["goldTime"] = 64,
			["questID"] = 74939,
		},
		[16] = {
			["currencyID"] = 2490,
			["silverTime"] = 72,
			["goldTime"] = 69,
			["questID"] = 74939,
		},
		[17] = {
			["currencyID"] = 2491,
			["silverTime"] = 74,
			["goldTime"] = 71,
			["questID"] = 74939,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Shimmering Slalom
		[19] = {
			["currencyID"] = 2249,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 74951,
		},
		[20] = {
			["currencyID"] = 2255,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 74951,
		},
		[21] = {
			["currencyID"] = 2261,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 74951,
		},
		[22] = {
			["currencyID"] = 2492,
			["silverTime"] = 82,
			["goldTime"] = 79,
			["questID"] = 74951,
		},
		[23] = {
			["currencyID"] = 2493,
			["silverTime"] = 78,
			["goldTime"] = 75,
			["questID"] = 74951,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Loamm Roamm
		[25] = {
			["currencyID"] = 2250,
			["silverTime"] = 60,
			["goldTime"] = 55,
			["questID"] = 74972,
		},
		[26] = {
			["currencyID"] = 2256,
			["silverTime"] = 55,
			["goldTime"] = 50,
			["questID"] = 74972,
		},
		[27] = {
			["currencyID"] = 2262,
			["silverTime"] = 53,
			["goldTime"] = 48,
			["questID"] = 74972,
		},
		[28] = {
			["currencyID"] = 2494,
			["silverTime"] = 56,
			["goldTime"] = 53,
			["questID"] = 74972,
		},
		[29] = {
			["currencyID"] = 2495,
			["silverTime"] = 55,
			["goldTime"] = 52,
			["questID"] = 74972,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Sulfur Sprint
		 [31] = {
			["currencyID"] = 2251,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 75035,
		},
		[32] = {
			["currencyID"] = 2257,
			["silverTime"] = 63,
			["goldTime"] = 58,
			["questID"] = 75035,
		},
		[33] = {
			["currencyID"] = 2263,
			["silverTime"] = 62,
			["goldTime"] = 57,
			["questID"] = 75035,
		},
		[34] = {
			["currencyID"] = 2496,
			["silverTime"] = 70,
			["goldTime"] = 67,
			["questID"] = 75035,
		},
		[35] = {
			["currencyID"] = 2497,
			["silverTime"] = 68,
			["goldTime"] = 65,
			["questID"] = 75035,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	},

-- Emerald Dream
	[7] = {
		 -- Ysera Invitational
		[1] = {
			["currencyID"] = 2676,
			["silverTime"] = 103,
			["goldTime"] = 98,
			["questID"] = 77841,
		},
		[2] = {
			["currencyID"] = 2682,
			["silverTime"] = 90,
			["goldTime"] = 87,
			["questID"] = 77841,
		},
		[3] = {
			["currencyID"] = 2688,
			["silverTime"] = 90,
			["goldTime"] = 87,
			["questID"] = 77841,
		},
		[4] = {
			["currencyID"] = 2694,
			["silverTime"] = 98,
			["goldTime"] = 95,
			["questID"] = 77841,
		},
		[5] = {
			["currencyID"] = 2695,
			["silverTime"] = 100,
			["goldTime"] = 97,
			["questID"] = 77841,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Smoldering Sprint
		[7] = {
			["currencyID"] = 2677,
			["silverTime"] = 85,
			["goldTime"] = 80,
			["questID"] = 77983,
		},
		[8] = {
			["currencyID"] = 2683,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77983,
		},
		[9] = {
			["currencyID"] = 2689,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77983,
		},
		[10] = {
			["currencyID"] = 2696,
			["silverTime"] = 82,
			["goldTime"] = 79,
			["questID"] = 77983,
		},
		[11] = {
			["currencyID"] = 2697,
			["silverTime"] = 83,
			["goldTime"] = 80,
			["questID"] = 77983,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Viridescent Venture
		[13] = {
			["currencyID"] = 2678,
			["silverTime"] = 83,
			["goldTime"] = 78,
			["questID"] = 77996,
		},
		[14] = {
			["currencyID"] = 2684,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 77996,
		},
		[15] = {
			["currencyID"] = 2690,
			["silverTime"] = 67,
			["goldTime"] = 64,
			["questID"] = 77996,
		},
		[16] = {
			["currencyID"] = 2698,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77996,
		},
		[17] = {
			["currencyID"] = 2699,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77996,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Shoreline Switchback
		[19] = {
			["currencyID"] = 2679,
			["silverTime"] = 78,
			["goldTime"] = 73,
			["questID"] = 78016,
		},
		[20] = {
			["currencyID"] = 2685,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 78016,
		},
		[21] = {
			["currencyID"] = 2691,
			["silverTime"] = 65,
			["goldTime"] = 62,
			["questID"] = 78016,
		},
		[22] = {
			["currencyID"] = 2700,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 78016,
		},
		[23] = {
			["currencyID"] = 2701,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 78016,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Canopy Concours
		[25] = {
			["currencyID"] = 2680,
			["silverTime"] = 110,
			["goldTime"] = 105,
			["questID"] = 78102,
		},
		[26] = {
			["currencyID"] = 2686,
			["silverTime"] = 96,
			["goldTime"] = 93,
			["questID"] = 78102,
		},
		[27] = {
			["currencyID"] = 2692,
			["silverTime"] = 99,
			["goldTime"] = 96,
			["questID"] = 78102,
		},
		[28] = {
			["currencyID"] = 2702,
			["silverTime"] = 108,
			["goldTime"] = 105,
			["questID"] = 78102,
		},
		[29] = {
			["currencyID"] = 2703,
			["silverTime"] = 108,
			["goldTime"] = 105,
			["questID"] = 78102,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Emerald Amble
		[31] = {
			["currencyID"] = 2681,
			["silverTime"] = 89,
			["goldTime"] = 84,
			["questID"] = 78115,
		},
		[32] = {
			["currencyID"] = 2687,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 78115,
		},
		[33] = {
			["currencyID"] = 2693,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 78115,
		},
		[34] = {
			["currencyID"] = 2704,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 78115,
		},
		[35] = {
			["currencyID"] = 2705,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 78115,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	},



-- Kalimdor Cup
	[8] = {
	 -- Felwood Flyover
		[1] = {
			["currencyID"] = 2312,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75277,
		},
		[2] = {
			["currencyID"] = 2342,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 75277,
		},
		[3] = {
			["currencyID"] = 2372,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 62,
			["questID"] = 75277,
		},
		[4] = {
			["currencyID"] = nil, -- 2498 UNUSED
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[5] = {
			["currencyID"] = nil, -- 2499 UNUSED
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Winter Wander
		[7] = {
			["currencyID"] = 2313,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 80,
			["questID"] = 75310,
		},
		[8] = {
			["currencyID"] = 2343,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 73,
			["questID"] = 75310,
		},
		[9] = {
			["currencyID"] = 2373,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75310,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Nordrassil Spiral
		[13] = {
			["currencyID"] = 2314,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 45,
			["questID"] = 75317,
		},
		[14] = {
			["currencyID"] = 2344,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 41,
			["questID"] = 75317,
		},
		[15] = {
			["currencyID"] = 2374,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 41,
			["questID"] = 75317,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Hyjal Hotfoot
		[19] = {
			["currencyID"] = 2315,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75330,
		},
		[20] = {
			["currencyID"] = 2345,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 69,
			["questID"] = 75330,
		},
		[21] = {
			["currencyID"] = 2375,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 67,
			["questID"] = 75330,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Rocketway Ride
		[25] = {
			["currencyID"] = 2316,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 101,
			["questID"] = 75347,
		},
		[26] = {
			["currencyID"] = 2346,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 94,
			["questID"] = 75347,
		},
		[27] = {
			["currencyID"] = 2376,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 94,
			["questID"] = 75347,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Ashenvale Ambit
		[31] = {
			["currencyID"] = 2317,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 75378,
		},
		[32] = {
			["currencyID"] = 2347,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 59,
			["questID"] = 75378,
		},
		[33] = {
			["currencyID"] = 2377,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 59,
			["questID"] = 75378,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Durotar Tour
		[37] = {
			["currencyID"] = 2318,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 82,
			["questID"] = 75385,
		},
		[38] = {
			["currencyID"] = 2348,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 75,
			["questID"] = 75385,
		},
		[39] = {
			["currencyID"] = 2378,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 75,
			["questID"] = 75385,
		},
		[40] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[41] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Webwinder Weave
		[43] = {
			["currencyID"] = 2319,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 80,
			["questID"] = 75394,
		},
		[44] = {
			["currencyID"] = 2349,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 73,
			["questID"] = 75394,
		},
		[45] = {
			["currencyID"] = 2379,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75394,
		},
		[46] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[47] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Desolace Drift
		[49] = {
			["currencyID"] = 2320,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 78,
			["questID"] = 75409,
		},
		[50] = {
			["currencyID"] = 2350,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 75409,
		},
		[51] = {
			["currencyID"] = 2380,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 71,
			["questID"] = 75409,
		},
		[52] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[53] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[54] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Great Divide Dive
		[55] = {
			["currencyID"] = 2321,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 48,
			["questID"] = 75412,
		},
		[56] = {
			["currencyID"] = 2351,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 43,
			["questID"] = 75412,
		},
		[57] = {
			["currencyID"] = 2381,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 44,
			["questID"] = 75412,
		},
		[58] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[59] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[60] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Razorfen Roundabout
		[61] = {
			["currencyID"] = 2322,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 53,
			["questID"] = 75437,
		},
		[62] = {
			["currencyID"] = 2352,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 47,
			["questID"] = 75437,
		},
		[63] = {
			["currencyID"] = 2382,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 48,
			["questID"] = 75437,
		},
		[64] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[65] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[66] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Thousand Needles Thread
		[67] = {
			["currencyID"] = 2323,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 87,
			["questID"] = 75463,
		},
		[68] = {
			["currencyID"] = 2353,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 77,
			["questID"] = 75463,
		},
		[69] = {
			["currencyID"] = 2383,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 77,
			["questID"] = 75463,
		},
		[70] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[71] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[72] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Feralas Ruins Ramble
		[73] = {
			["currencyID"] = 2324,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 89,
			["questID"] = 75468,
		},
		[74] = {
			["currencyID"] = 2354,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 84,
			["questID"] = 75468,
		},
		[75] = {
			["currencyID"] = 2384,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 84,
			["questID"] = 75468,
		},
		[76] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[77] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[78] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Ahn'Qiraj Circuit
		[79] = {
			["currencyID"] = 2325,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 77,
			["questID"] = 75472,
		},
		[80] = {
			["currencyID"] = 2355,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 68,
			["questID"] = 75472,
		},
		[81] = {
			["currencyID"] = 2385,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 69,
			["questID"] = 75472,
		},
		[82] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[83] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[84] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Uldum Tour
		[85] = {
			["currencyID"] = 2326,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 84,
			["questID"] = 75481,
		},
		[86] = {
			["currencyID"] = 2356,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 76,
			["questID"] = 75481,
		},
		[87] = {
			["currencyID"] = 2386,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 76,
			["questID"] = 75481,
		},
		[88] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[89] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[90] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Un'Goro Crater Circuit
		[91] = {
			["currencyID"] = 2327,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 100,
			["questID"] = 75485,
		},
		[92] = {
			["currencyID"] = 2357,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 90,
			["questID"] = 75485,
		},
		[93] = {
			["currencyID"] = 2387,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 92,
			["questID"] = 75485,
		},
		[94] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[95] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[96] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	};



-- Eastern Kingdoms Cup
	[9] = {
	 -- Gilneas Gambit
		[1] = {
			["currencyID"] = 2536,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 78,
			["questID"] = 76309,
		},
		[2] = {
			["currencyID"] = 2552,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 74,
			["questID"] = 76309,
		},
		[3] = {
			["currencyID"] = 2568,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 74,
			["questID"] = 76309,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	
	 -- Loch Modan Loop
		[7] = {
			["currencyID"] = 2537,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76339,
		},
		[8] = {
			["currencyID"] = 2553,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 61,
			["questID"] = 76339,
		},
		[9] = {
			["currencyID"] = 2569,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76339,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Searing Slalom
		[13] = {
			["currencyID"] = 2538,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 52,
			["questID"] = 76357,
		},
		[14] = {
			["currencyID"] = 2554,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 46,
			["questID"] = 76357,
		},
		[15] = {
			["currencyID"] = 2570,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 43,
			["questID"] = 76357,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Twilight Terror
		[19] = {
			["currencyID"] = 2539,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 73,
			["questID"] = 76364,
		},
		[20] = {
			["currencyID"] = 2555,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 68,
			["questID"] = 76364,
		},
		[21] = {
			["currencyID"] = 2571,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 66,
			["questID"] = 76364,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Deadwind Derby
		[25] = {
			["currencyID"] = 2540,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 60,
			["questID"] = 76380,
		},
		[26] = {
			["currencyID"] = 2556,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 59,
			["questID"] = 76380,
		},
		[27] = {
			["currencyID"] = 2572,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 59,
			["questID"] = 76380,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Elwynn Forest Flash
		[31] = {
			["currencyID"] = 2541,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 73,
			["questID"] = 76397,
		},
		[32] = {
			["currencyID"] = 2557,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 66,
			["questID"] = 76397,
		},
		[33] = {
			["currencyID"] = 2573,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76397,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Gurubashi Gala
		[37] = {
			["currencyID"] = 2542,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 56,
			["questID"] = 76438,
		},
		[38] = {
			["currencyID"] = 2558,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 49,
			["questID"] = 76438,
		},
		[39] = {
			["currencyID"] = 2574,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 50,
			["questID"] = 76438,
		},
		[40] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[41] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Ironforge Interceptor
		[43] = {
			["currencyID"] = 2543,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 70,
			["questID"] = 76445,
		},
		[44] = {
			["currencyID"] = 2559,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 76445,
		},
		[45] = {
			["currencyID"] = 2575,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 60,
			["questID"] = 76445,
		},
		[46] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[47] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Blasted Lands Bolt
		[49] = {
			["currencyID"] = 2544,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 69,
			["questID"] = 76469,
		},
		[50] = {
			["currencyID"] = 2560,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 62,
			["questID"] = 76469,
		},
		[51] = {
			["currencyID"] = 2576,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 76469,
		},
		[52] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[53] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[54] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Plaguelands Plunge
		[55] = {
			["currencyID"] = 2545,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76510,
		},
		[56] = {
			["currencyID"] = 2561,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 53,
			["questID"] = 76510,
		},
		[57] = {
			["currencyID"] = 2577,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 58,
			["questID"] = 76510,
		},
		[58] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[59] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[60] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Booty Bay Blast
		[61] = {
			["currencyID"] = 2546,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 63,
			["questID"] = 76515,
		},
		[62] = {
			["currencyID"] = 2562,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 57,
			["questID"] = 76515,
		},
		[63] = {
			["currencyID"] = 2578,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 56,
			["questID"] = 76515,
		},
		[64] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[65] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[66] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Fuselight Night Flight
		[67] = {
			["currencyID"] = 2547,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 76523,
		},
		[68] = {
			["currencyID"] = 2563,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 58,
			["questID"] = 76523,
		},
		[69] = {
			["currencyID"] = 2579,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 58,
			["questID"] = 76523,
		},
		[70] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[71] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[72] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Krazzworks Klash
		[73] = {
			["currencyID"] = 2548,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 71,
			["questID"] = 76527,
		},
		[74] = {
			["currencyID"] = 2564,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 64,
			["questID"] = 76527,
		},
		[75] = {
			["currencyID"] = 2580,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 62,
			["questID"] = 76527,
		},
		[76] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[77] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[78] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Redridge Rally
		[79] = {
			["currencyID"] = 2549,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 57,
			["questID"] = 76536,
		},
		[80] = {
			["currencyID"] = 2565,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 52,
			["questID"] = 76536,
		},
		[81] = {
			["currencyID"] = 2581,
			["silverTime"] = nil, -- MISSING
			["goldTime"] = 52,
			["questID"] = 76536,
		},
		[82] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[83] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[84] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	};



-- Outland Cup
	[10] = {
		 -- Hellfire Hustle
		[1] = {
			["currencyID"] = 2600,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 77102,
		},
		[2] = {
			["currencyID"] = 2615,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77102,
		},
		[3] = {
			["currencyID"] = 2630,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 77102,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Coilfang Caper
		[7] = {
			["currencyID"] = 2601,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 77169,
		},
		[8] = {
			["currencyID"] = 2616,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 77169,
		},
		[9] = {
			["currencyID"] = 2631,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 77169,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Blade's Edge Brawl
		[13] = {
			["currencyID"] = 2602,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 77205,
		},
		[14] = {
			["currencyID"] = 2617,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 77205,
		},
		[15] = {
			["currencyID"] = 2632,
			["silverTime"] = 78,
			["goldTime"] = 75,
			["questID"] = 77205,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Telaar Tear
		[19] = {
			["currencyID"] = 2603,
			["silverTime"] = 69,
			["goldTime"] = 64,
			["questID"] = 77238,
		},
		[20] = {
			["currencyID"] = 2618,
			["silverTime"] = 60,
			["goldTime"] = 57,
			["questID"] = 77238,
		},
		[21] = {
			["currencyID"] = 2633,
			["silverTime"] = 61,
			["goldTime"] = 58,
			["questID"] = 77238,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Razorthorn Rise Rush
		[25] = {
			["currencyID"] = 2604,
			["silverTime"] = 72,
			["goldTime"] = 67,
			["questID"] = 77260,
		},
		[26] = {
			["currencyID"] = 2619,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 77260,
		},
		[27] = {
			["currencyID"] = 2634,
			["silverTime"] = 57,
			["goldTime"] = 54,
			["questID"] = 77260,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Auchindoun Coaster
		[31] = {
			["currencyID"] = 2605,
			["silverTime"] = 78,
			["goldTime"] = 73,
			["questID"] = 77264,
		},
		[32] = {
			["currencyID"] = 2620,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 77264,
		},
		[33] = {
			["currencyID"] = 2635,
			["silverTime"] = 73,
			["goldTime"] = 70,
			["questID"] = 77264,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Tempest Keep Sweep
		[37] = {
			["currencyID"] = 2606,
			["silverTime"] = 105,
			["goldTime"] = 100,
			["questID"] = 77278,
		},
		[38] = {
			["currencyID"] = 2621,
			["silverTime"] = 90,
			["goldTime"] = 87,
			["questID"] = 77278,
		},
		[39] = {
			["currencyID"] = 2636,
			["silverTime"] = 91,
			["goldTime"] = 88,
			["questID"] = 77278,
		},
		[40] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[41] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Shattrath City Sashay
		[43] = {
			["currencyID"] = 2607,
			["silverTime"] = 80,
			["goldTime"] = 75,
			["questID"] = 77322,
		},
		[44] = {
			["currencyID"] = 2622,
			["silverTime"] = 68,
			["goldTime"] = 65,
			["questID"] = 77322,
		},
		[45] = {
			["currencyID"] = 2637,
			["silverTime"] = 69,
			["goldTime"] = 66,
			["questID"] = 77322,
		},
		[46] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[47] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Shadowmoon Slam
		[49] = {
			["currencyID"] = 2608,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 77346,
		},
		[50] = {
			["currencyID"] = 2623,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 77346,
		},
		[51] = {
			["currencyID"] = 2638,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 77346,
		},
		[52] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[53] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[54] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Eco-Dome Excursion
		[55] = {
			["currencyID"] = 2609,
			["silverTime"] = 120,
			["goldTime"] = 115,
			["questID"] = 77398,
		},
		[56] = {
			["currencyID"] = 2624,
			["silverTime"] = 112,
			["goldTime"] = 109,
			["questID"] = 77398,
		},
		[57] = {
			["currencyID"] = 2639,
			["silverTime"] = 113,
			["goldTime"] = 110,
			["questID"] = 77398,
		},
		[58] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[59] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[60] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Warmaul Wingding
		[61] = {
			["currencyID"] = 2610,
			["silverTime"] = 85,
			["goldTime"] = 80,
			["questID"] = 77589,
		},
		[62] = {
			["currencyID"] = 2625,
			["silverTime"] = 75,
			["goldTime"] = 72,
			["questID"] = 77589,
		},
		[63] = {
			["currencyID"] = 2640,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77589,
		},
		[64] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[65] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[66] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Skettis Scramble
		[67] = {
			["currencyID"] = 2611,
			["silverTime"] = 75,
			["goldTime"] = 70,
			["questID"] = 77645,
		},
		[68] = {
			["currencyID"] = 2626,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 77645,
		},
		[69] = {
			["currencyID"] = 2641,
			["silverTime"] = 66,
			["goldTime"] = 63,
			["questID"] = 77645,
		},
		[70] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[71] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[72] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		
		 -- Fel Pit Fracas
		[73] = {
			["currencyID"] = 2612,
			["silverTime"] = 82,
			["goldTime"] = 77,
			["questID"] = 77684,
		},
		[74] = {
			["currencyID"] = 2627,
			["silverTime"] = 76,
			["goldTime"] = 73,
			["questID"] = 77684,
		},
		[75] = {
			["currencyID"] = 2642,
			["silverTime"] = 79,
			["goldTime"] = 76,
			["questID"] = 77684,
		},
		[76] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[77] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[78] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	},


-- Northrend Cup
	[11] = {
	 -- Scalawag Slither
		[1] = {
			["currencyID"] = 2720,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78301,
		},
		[2] = {
			["currencyID"] = 2738,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78301,
		},
		[3] = {
			["currencyID"] = 2756,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78301,
		},
		[4] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[5] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[6] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Daggercap Dart
		[7] = {
			["currencyID"] = 2721,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78325,
		},
		[8] = {
			["currencyID"] = 2739,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78325,
		},
		[9] = {
			["currencyID"] = 2757,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78325,
		},
		[10] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[11] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[12] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Blackriver Burble
		[13] = {
			["currencyID"] = 2722,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78334,
		},
		[14] = {
			["currencyID"] = 2740,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78334,
		},
		[15] = {
			["currencyID"] = 2758,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78334,
		},
		[16] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[17] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[18] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Zul'Drak Zephyr
		[19] = {
			["currencyID"] = 2723,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78346,
		},
		[20] = {
			["currencyID"] = 2741,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78346,
		},
		[21] = {
			["currencyID"] = 2759,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78346,
		},
		[22] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[23] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[24] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Makers' Marathon
		[25] = {
			["currencyID"] = 2724,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78389,
		},
		[26] = {
			["currencyID"] = 2742,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78389,
		},
		[27] = {
			["currencyID"] = 2760,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78389,
		},
		[28] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[29] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[30] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Crystalsong Crisis
		[31] = {
			["currencyID"] = 2725,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78441,
		},
		[32] = {
			["currencyID"] = 2743,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78441,
		},
		[33] = {
			["currencyID"] = 2761,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78441,
		},
		[34] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[35] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[36] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Dragonblight Dragon Flight
		[37] = {
			["currencyID"] = 2726,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78454,
		},
		[38] = {
			["currencyID"] = 2744,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78454,
		},
		[39] = {
			["currencyID"] = 2762,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78454,
		},
		[40] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[41] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[42] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Citadel Sortie
		[43] = {
			["currencyID"] = 2727,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78499,
		},
		[44] = {
			["currencyID"] = 2745,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78499,
		},
		[45] = {
			["currencyID"] = 2763,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78499,
		},
		[46] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[47] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[48] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Sholazar Spree
		[49] = {
			["currencyID"] = 2728,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78558,
		},
		[50] = {
			["currencyID"] = 2746,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78558,
		},
		[51] = {
			["currencyID"] = 2764,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78558,
		},
		[52] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[53] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[54] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Geothermal Jaunt
		[55] = {
			["currencyID"] = 2729,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78608,
		},
		[56] = {
			["currencyID"] = 2747,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78608,
		},
		[57] = {
			["currencyID"] = 2765,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 78608,
		},
		[58] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[59] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[60] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Gundrak Fast Track
		[61] = {
			["currencyID"] = 2730,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 79268,
		},
		[62] = {
			["currencyID"] = 2748,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 79268,
		},
		[63] = {
			["currencyID"] = 2766,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 79268,
		},
		[64] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[65] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[66] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
	
	 -- Coldarra Climb
		[67] = {
			["currencyID"] = 2731,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 79272,
		},
		[68] = {
			["currencyID"] = 2749,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 79272,
		},
		[69] = {
			["currencyID"] = 2767,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = 79272,
		},
		[70] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[71] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},
		[72] = {
			["currencyID"] = nil,
			["silverTime"] = nil,
			["goldTime"] = nil,
			["questID"] = nil,
		},

	};


};