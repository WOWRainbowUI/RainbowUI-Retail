
	----------------------------------------------------------------------
	-- Leatrix Plus Flight Horde for Burning Crusade Anniversary
	----------------------------------------------------------------------

	local void, Leatrix_Plus = ...
	local L = Leatrix_Plus.L

	-- Function to load flight data (load-on-demand)
	function Leatrix_Plus:LoadFlightDataHorde()

		Leatrix_Plus["FlightData"]["Horde"] = {

			----------------------------------------------------------------------
			--	Horde
			----------------------------------------------------------------------

			-- Horde: Eastern Kingdoms
			[1415] = {

				-- Horde: Acherus (Eastern Plaguelands)
				["0.62:0.34:0.61:0.35:0.61:0.28:0.58:0.06"] = 392, -- Acherus: The Ebon Hold, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.62:0.34:0.61:0.35:0.58:0.25:0.59:0.19"] = 234, -- Acherus: The Ebon Hold, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.62:0.34:0.61:0.35:0.58:0.25"] = 169, -- Acherus: The Ebon Hold, Light's Hope Chapel, Tranquillien
				["0.62:0.34:0.61:0.35:0.61:0.28"] = 145, -- Acherus: The Ebon Hold, Light's Hope Chapel, Zul'Aman
				["0.62:0.34:0.61:0.35"] = 52, -- Acherus: The Ebon Hold, Light's Hope Chapel
				["0.62:0.34:0.61:0.35:0.51:0.36"] = 147, -- Acherus: The Ebon Hold, Light's Hope Chapel, Thondoril River
				["0.62:0.34:0.61:0.35:0.51:0.36:0.45:0.37"] = 223, -- Acherus: The Ebon Hold, Light's Hope Chapel, Thondoril River, The Bulwark
				["0.62:0.34:0.61:0.35:0.51:0.36:0.42:0.37"] = 307, -- Acherus: The Ebon Hold, Light's Hope Chapel, Thondoril River, Undercity
				["0.62:0.34:0.61:0.35:0.51:0.36:0.46:0.43:0.37:0.41"] = 350, -- Acherus: The Ebon Hold, Light's Hope Chapel, Thondoril River, Tarren Mill, The Sepulcher
				["0.62:0.34:0.61:0.35:0.51:0.36:0.46:0.43"] = 247, -- Acherus: The Ebon Hold, Light's Hope Chapel, Thondoril River, Tarren Mill
				["0.62:0.34:0.61:0.35:0.59:0.45:0.55:0.46"] = 282, -- Acherus: The Ebon Hold, Light's Hope Chapel, Revantusk Village, Hammerfall
				["0.62:0.34:0.61:0.35:0.59:0.45"] = 189, -- Acherus: The Ebon Hold, Light's Hope Chapel, Revantusk Village
				["0.62:0.34:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.46:0.65"] = 595, -- Acherus: The Ebon Hold, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Thorium Point
				["0.62:0.34:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66"] = 540, -- Acherus: The Ebon Hold, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath
				["0.62:0.34:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.50:0.69"] = 606, -- Acherus: The Ebon Hold, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Flame Crest
				["0.62:0.34:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.54:0.79"] = 763, -- Acherus: The Ebon Hold, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Stonard
				["0.62:0.34:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.42:0.86"] = 777, -- Acherus: The Ebon Hold, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Grom'gol
				["0.62:0.34:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.41:0.93"] = 836, -- Acherus: The Ebon Hold, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Booty Bay

				-- Horde: Booty Bay (Stranglethorn Vale)
				["0.41:0.93:0.42:0.86"] = 75, -- Booty Bay, Grom'gol
				["0.41:0.93:0.54:0.79"] = 240, -- Booty Bay, Stonard
				["0.41:0.93:0.42:0.86:0.50:0.69"] = 273, -- Booty Bay, Grom'gol, Flame Crest
				["0.41:0.93:0.50:0.66"] = 315, -- Booty Bay, Kargath
				["0.41:0.93:0.42:0.86:0.50:0.69:0.46:0.65"] = 304, -- Booty Bay, Grom'gol, Flame Crest, Thorium Point
				["0.41:0.93:0.50:0.66:0.55:0.46:0.46:0.43:0.37:0.41"] = 789, -- Booty Bay, Kargath, Hammerfall, Tarren Mill, The Sepulcher
				["0.41:0.93:0.50:0.66:0.42:0.37"] = 811, -- Booty Bay, Kargath, Undercity
				["0.41:0.93:0.50:0.66:0.55:0.46:0.46:0.43"] = 692, -- Booty Bay, Kargath, Hammerfall, Tarren Mill
				["0.41:0.93:0.50:0.66:0.55:0.46"] = 576, -- Booty Bay, Kargath, Hammerfall
				["0.41:0.93:0.50:0.66:0.55:0.46:0.59:0.45"] = 665, -- Booty Bay, Kargath, Hammerfall, Revantusk Village
				["0.41:0.93:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35"] = 804, -- Booty Bay, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel
				["0.41:0.93:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25"] = 920, -- Booty Bay, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien
				["0.41:0.93:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25:0.59:0.19"] = 986, -- Booty Bay, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.41:0.93:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28"] = 897, -- Booty Bay, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman
				["0.41:0.93:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28:0.58:0.06"] = 1145, -- Booty Bay, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.41:0.93:0.50:0.66:0.42:0.37:0.61:0.35"] = 1000, -- Booty Bay, Kargath, Undercity, Light's Hope Chapel
				["0.41:0.93:0.50:0.66:0.46:0.65"] = 370, -- Booty Bay, Kargath, Thorium Point
				["0.41:0.93:0.50:0.66:0.50:0.69"] = 381, -- Booty Bay, Kargath, Flame Crest
				["0.41:0.93:0.50:0.66:0.55:0.46:0.46:0.43:0.45:0.37"] = 760, -- Booty Bay, Kargath, Hammerfall, Tarren Mill, The Bulwark
				["0.41:0.93:0.50:0.66:0.55:0.46:0.46:0.43:0.51:0.36"] = 792, -- Booty Bay, Kargath, Hammerfall, Tarren Mill, Thondroril River
				["0.41:0.93:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.62:0.34"] = 864, -- Booty Bay, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Flame Crest (Burning Steppes)
				["0.50:0.69:0.42:0.86:0.41:0.93"] = 284, -- Flame Crest, Grom'gol, Booty Bay
				["0.50:0.69:0.42:0.86"] = 207, -- Flame Crest, Grom'gol
				["0.50:0.69:0.54:0.79"] = 192, -- Flame Crest, Stonard
				["0.50:0.69:0.50:0.66"] = 81, -- Flame Crest, Kargath
				["0.50:0.69:0.46:0.65"] = 62, -- Flame Crest, Thorium Point
				["0.50:0.69:0.50:0.66:0.55:0.46:0.46:0.43:0.37:0.41"] = 557, -- Flame Crest, Kargath, Hammerfall, Tarren Mill, The Sepulcher
				["0.50:0.69:0.50:0.66:0.42:0.37"] = 578, -- Flame Crest, Kargath, Undercity
				["0.50:0.69:0.50:0.66:0.55:0.46:0.46:0.43"] = 458, -- Flame Crest, Kargath, Hammerfall, Tarren Mill
				["0.50:0.69:0.50:0.66:0.55:0.46"] = 343, -- Flame Crest, Kargath, Hammerfall
				["0.50:0.69:0.50:0.66:0.55:0.46:0.59:0.45"] = 433, -- Flame Crest, Kargath, Hammerfall, Revantusk Village
				["0.50:0.69:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35"] = 571, -- Flame Crest, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel
				["0.50:0.69:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25"] = 687, -- Flame Crest, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien
				["0.50:0.69:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25:0.59:0.19"] = 754, -- Flame Crest, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.50:0.69:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28:0.58:0.06"] = 912, -- Flame Crest, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.50:0.69:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28"] = 665, -- Flame Crest, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman
				["0.50:0.69:0.50:0.66:0.41:0.93"] = 378, -- Flame Crest, Kargath, Booty Bay
				["0.50:0.69:0.50:0.66:0.55:0.46:0.46:0.43:0.45:0.37"] = 527, -- Flame Crest, Kargath, Hammerfall, Tarren Mill, The Bulwark
				["0.50:0.69:0.50:0.66:0.55:0.46:0.46:0.43:0.51:0.36"] = 559, -- Flame Crest, Kargath, Hammerfall, Tarren Mill, Thondroril River
				["0.50:0.69:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.62:0.34"] = 632, -- Flame Crest, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Grom'gol (Stranglethorn Vale)
				["0.42:0.86:0.41:0.93"] = 78, -- Grom'gol, Booty Bay
				["0.42:0.86:0.54:0.79"] = 173, -- Grom'gol, Stonard
				["0.42:0.86:0.50:0.69"] = 198, -- Grom'gol, Flame Crest
				["0.42:0.86:0.50:0.66"] = 246, -- Grom'gol, Kargath
				["0.42:0.86:0.50:0.69:0.46:0.65"] = 230, -- Grom'gol, Flame Crest, Thorium Point
				["0.42:0.86:0.50:0.66:0.55:0.46:0.46:0.43:0.37:0.41"] = 722, -- Grom'gol, Kargath, Hammerfall, Tarren Mill, The Sepulcher
				["0.42:0.86:0.50:0.66:0.42:0.37"] = 743, -- Grom'gol, Kargath, Undercity
				["0.42:0.86:0.50:0.66:0.55:0.46:0.46:0.43"] = 624, -- Grom'gol, Kargath, Hammerfall, Tarren Mill
				["0.42:0.86:0.50:0.66:0.55:0.46"] = 508, -- Grom'gol, Kargath, Hammerfall
				["0.42:0.86:0.50:0.66:0.55:0.46:0.59:0.45"] = 597, -- Grom'gol, Kargath, Hammerfall, Revantusk Village
				["0.42:0.86:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35"] = 736, -- Grom'gol, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel
				["0.42:0.86:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25"] = 851, -- Grom'gol, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien
				["0.42:0.86:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25:0.59:0.19"] = 918, -- Grom'gol, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.42:0.86:0.50:0.66:0.46:0.65"] = 302, -- Grom'gol, Kargath, Thorium Point
				["0.42:0.86:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28"] = 829, -- Grom'gol, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman
				["0.42:0.86:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28:0.58:0.06"] = 1077, -- Grom'gol, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.42:0.86:0.50:0.66:0.55:0.46:0.46:0.43:0.45:0.37"] = 692, -- Grom'gol, Kargath, Hammerfall, Tarren Mill, The Bulwark
				["0.42:0.86:0.50:0.66:0.55:0.46:0.46:0.43:0.51:0.36"] = 724, -- Grom'gol, Kargath, Hammerfall, Tarren Mill, Thondroril River
				["0.42:0.86:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.62:0.34"] = 797, -- Grom'gol, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Hammerfall (Arathi Highlands)
				["0.55:0.46:0.50:0.66:0.41:0.93"] = 556, -- Hammerfall, Kargath, Booty Bay
				["0.55:0.46:0.50:0.66:0.42:0.86"] = 497, -- Hammerfall, Kargath, Grom'gol
				["0.55:0.46:0.50:0.66:0.54:0.79"] = 482, -- Hammerfall, Kargath, Stonard
				["0.55:0.46:0.50:0.66:0.50:0.69"] = 326, -- Hammerfall, Kargath, Flame Crest
				["0.55:0.46:0.50:0.66"] = 259, -- Hammerfall, Kargath
				["0.55:0.46:0.50:0.66:0.46:0.65"] = 315, -- Hammerfall, Kargath, Thorium Point
				["0.55:0.46:0.59:0.45"] = 91, -- Hammerfall, Revantusk Village
				["0.55:0.46:0.59:0.45:0.61:0.35"] = 229, -- Hammerfall, Revantusk Village, Light's Hope Chapel
				["0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25"] = 345, -- Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien
				["0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25:0.59:0.19"] = 411, -- Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.55:0.46:0.42:0.37"] = 259, -- Hammerfall, Undercity
				["0.55:0.46:0.46:0.43"] = 117, -- Hammerfall, Tarren Mill
				["0.55:0.46:0.46:0.43:0.37:0.41"] = 215, -- Hammerfall, Tarren Mill, The Sepulcher
				["0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28"] = 322, -- Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman
				["0.55:0.46:0.46:0.43:0.42:0.37:0.61:0.35:0.61:0.28"] = 532, -- Hammerfall, Tarren Mill, Undercity, Light's Hope Chapel, Zul'Aman
				["0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28:0.58:0.06"] = 571, -- Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.55:0.46:0.46:0.43:0.42:0.37:0.61:0.35"] = 441, -- Hammerfall, Tarren Mill, Undercity, Light's Hope Chapel
				["0.55:0.46:0.46:0.43:0.45:0.37"] = 185, -- Hammerfall, Tarren Mill, The Bulwark
				["0.55:0.46:0.46:0.43:0.51:0.36"] = 217, -- Hammerfall, Tarren Mill, Thondroril River
				["0.55:0.46:0.59:0.45:0.61:0.35:0.62:0.34"] = 290, -- Hammerfall, Revantusk Village, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Kargath (Badlands)
				["0.50:0.66:0.41:0.93"] = 298, -- Kargath, Booty Bay
				["0.50:0.66:0.42:0.86"] = 239, -- Kargath, Grom'gol
				["0.50:0.66:0.54:0.79"] = 225, -- Kargath, Stonard
				["0.50:0.66:0.50:0.69"] = 68, -- Kargath, Flame Crest
				["0.50:0.66:0.46:0.65"] = 56, -- Kargath, Thorium Point
				["0.50:0.66:0.55:0.46:0.46:0.43:0.37:0.41"] = 477, -- Kargath, Hammerfall, Tarren Mill, The Sepulcher
				["0.50:0.66:0.42:0.37"] = 498, -- Kargath, Undercity
				["0.50:0.66:0.55:0.46:0.46:0.43"] = 379, -- Kargath, Hammerfall, Tarren Mill
				["0.50:0.66:0.55:0.46"] = 263, -- Kargath, Hammerfall
				["0.50:0.66:0.55:0.46:0.59:0.45"] = 353, -- Kargath, Hammerfall, Revantusk Village
				["0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35"] = 490, -- Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel
				["0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25"] = 606, -- Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien
				["0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25:0.59:0.19"] = 673, -- Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28"] = 585, -- Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman
				["0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28:0.58:0.06"] = 832, -- Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.50:0.66:0.42:0.37:0.61:0.35"] = 686, -- Kargath, Undercity, Light's Hope Chapel
				["0.50:0.66:0.42:0.37:0.61:0.35:0.58:0.25:0.59:0.19"] = 870, -- Kargath, Undercity, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.50:0.66:0.42:0.37:0.37:0.41"] = 532, -- Kargath, Undercity, The Sepulcher
				["0.50:0.66:0.42:0.37:0.46:0.43"] = 565, -- Kargath, Undercity, Tarren Mill
				["0.50:0.66:0.55:0.46:0.46:0.43:0.45:0.37"] = 447, -- Kargath, Hammerfall, Tarren Mill, The Bulwark
				["0.50:0.66:0.55:0.46:0.46:0.43:0.51:0.36"] = 479, -- Kargath, Hammerfall, Tarren Mill, Thondoril River
				["0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.62:0.34"] = 551, -- Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Light's Hope Chapel (Eastern Plaguelands)
				["0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.41:0.93"] = 789, -- Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Booty Bay
				["0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.42:0.86"] = 730, -- Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Grom'gol
				["0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.54:0.79"] = 716, -- Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Stonard
				["0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.50:0.69"] = 560, -- Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Flame Crest
				["0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66"] = 492, -- Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath
				["0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.46:0.65"] = 548, -- Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Thorium Point
				["0.61:0.35:0.59:0.45:0.55:0.46"] = 234, -- Light's Hope Chapel, Revantusk Village, Hammerfall
				["0.61:0.35:0.59:0.45"] = 141, -- Light's Hope Chapel, Revantusk Village
				["0.61:0.35:0.58:0.25"] = 118, -- Light's Hope Chapel, Tranquillien
				["0.61:0.35:0.58:0.25:0.59:0.19"] = 186, -- Light's Hope Chapel, Tranquillien, Silvermoon City (was 184, changed to 190 by GurnsyTV on CurseForge, changed to 186 by Jon Kipp Lauesen)
				["0.61:0.35:0.59:0.45:0.46:0.43"] = 301, -- Light's Hope Chapel, Revantusk Village, Tarren Mill
				["0.61:0.35:0.42:0.37"] = 262, -- Light's Hope Chapel, Undercity
				["0.61:0.35:0.42:0.37:0.37:0.41"] = 294, -- Light's Hope Chapel, Undercity, The Sepulcher
				["0.61:0.35:0.42:0.37:0.46:0.43"] = 326, -- Light's Hope Chapel, Undercity, Tarren Mill
				["0.61:0.35:0.42:0.37:0.46:0.43:0.55:0.46"] = 444, -- Light's Hope Chapel, Undercity, Tarren Mill, Hammerfall (was 262, changed by B R)
				["0.61:0.35:0.61:0.28"] = 98, -- Light's Hope Chapel, Zul'Aman
				["0.61:0.35:0.42:0.37:0.50:0.66"] = 673, -- Light's Hope Chapel, Undercity, Kargath
				["0.61:0.35:0.61:0.28:0.58:0.06"] = 344, -- Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.61:0.35:0.42:0.37:0.50:0.66:0.42:0.86"] = 911, -- Light's Hope Chapel, Undercity, Kargath, Grom'gol
				["0.61:0.35:0.42:0.37:0.50:0.66:0.50:0.69"] = 740, -- Light's Hope Chapel, Undercity, Kargath, Flame Crest
				["0.61:0.35:0.58:0.25:0.59:0.19:0.58:0.06"] = 368, -- Light's Hope Chapel, Tranquillien, Silvermoon City, Shattered Sun Staging Area
				["0.61:0.35:0.42:0.37:0.50:0.66:0.46:0.65"] = 729, -- Light's Hope Chapel, Undercity, Kargath, Thorium Point
				["0.61:0.35:0.42:0.37:0.50:0.66:0.41:0.93"] = 970, -- Light's Hope Chapel, Undercity, Kargath, Booty Bay
				["0.61:0.35:0.42:0.37:0.50:0.66:0.54:0.79"] = 896, -- Light's Hope Chapel, Undercity, Kargath, Stonard
				["0.61:0.35:0.42:0.37:0.45:0.37"] = 280, -- Light's Hope Chapel, Undercity, The Bulwark
				["0.61:0.35:0.51:0.36:0.45:0.37"] = 174, -- Light's Hope Chapel, Thondroril River, The Bulwark
				["0.61:0.35:0.51:0.36"] = 99, -- Light's Hope Chapel, Thondroril River
				["0.61:0.35:0.62:0.34"] = 65, -- Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Revantusk Village (The Hinterlands)
				["0.59:0.45:0.55:0.46:0.50:0.66:0.41:0.93"] = 648, -- Revantusk Village, Hammerfall, Kargath, Booty Bay
				["0.59:0.45:0.55:0.46:0.50:0.66:0.42:0.86"] = 589, -- Revantusk Village, Hammerfall, Kargath, Grom'gol
				["0.59:0.45:0.55:0.46:0.50:0.66:0.54:0.79"] = 575, -- Revantusk Village, Hammerfall, Kargath, Stonard
				["0.59:0.45:0.55:0.46:0.50:0.66:0.50:0.69"] = 419, -- Revantusk Village, Hammerfall, Kargath, Flame Crest
				["0.59:0.45:0.55:0.46:0.50:0.66"] = 351, -- Revantusk Village, Hammerfall, Kargath
				["0.59:0.45:0.55:0.46:0.50:0.66:0.46:0.65"] = 407, -- Revantusk Village, Hammerfall, Kargath, Thorium Point
				["0.59:0.45:0.46:0.43:0.37:0.41"] = 257, -- Revantusk Village, Tarren Mill, The Sepulcher
				["0.59:0.45:0.42:0.37"] = 284, -- Revantusk Village, Undercity
				["0.59:0.45:0.46:0.43"] = 159, -- Revantusk Village, Tarren Mill
				["0.59:0.45:0.55:0.46"] = 93, -- Revantusk Village, Hammerfall
				["0.59:0.45:0.61:0.35"] = 139, -- Revantusk Village, Light's Hope Chapel
				["0.59:0.45:0.61:0.35:0.58:0.25"] = 255, -- Revantusk Village, Light's Hope Chapel, Tranquillien
				["0.59:0.45:0.61:0.35:0.58:0.25:0.59:0.19"] = 322, -- Revantusk Village, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.59:0.45:0.42:0.37:0.50:0.66:0.41:0.93"] = 993, -- Revantusk Village, Undercity, Kargath, Booty Bay
				["0.59:0.45:0.61:0.35:0.61:0.28"] = 232, -- Revantusk Village, Light's Hope Chapel, Zul'Aman
				["0.59:0.45:0.61:0.35:0.61:0.28:0.58:0.06"] = 481, -- Revantusk Village, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.59:0.45:0.42:0.37:0.50:0.66:0.46:0.65"] = 752, -- Revantusk Village, Undercity, Kargath, Thorium Point
				["0.59:0.45:0.42:0.37:0.50:0.66:0.54:0.79"] = 920, -- Revantusk Village, Undercity, Kargath, Stonard
				["0.59:0.45:0.46:0.43:0.45:0.37"] = 228, -- Revantusk Village, Tarren Mill, The Bulwark
				["0.59:0.45:0.61:0.35:0.51:0.36"] = 236, -- Revantusk Village, Light's Hope Chapel, Thondroril River
				["0.59:0.45:0.61:0.35:0.62:0.34"] = 200, -- Revantusk Village, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Shattered Sun Staging Area (Isle of Quel'Danas)
				["0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.41:0.93"] = 1117, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Booty Bay
				["0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.42:0.86"] = 1058, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Grom'gol
				["0.58:0.06:0.61:0.28"] = 233, -- Shattered Sun Staging Area, Zul'Aman
				["0.58:0.06:0.59:0.19"] = 167, -- Shattered Sun Staging Area, Silvermoon City
				["0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.46:0.65"] = 876, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Thorium Point
				["0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.54:0.79"] = 1044, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Stonard
				["0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45"] = 469, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village
				["0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66"] = 820, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath
				["0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.50:0.69"] = 888, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Flame Crest
				["0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46"] = 562, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall
				["0.58:0.06:0.61:0.28:0.61:0.35"] = 329, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel
				["0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45:0.46:0.43"] = 629, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village, Tarren Mill
				["0.58:0.06:0.59:0.19:0.58:0.25"] = 231, -- Shattered Sun Staging Area, Silvermoon City, Tranquillien
				["0.58:0.06:0.61:0.28:0.61:0.35:0.42:0.37"] = 590, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Undercity
				["0.58:0.06:0.61:0.28:0.61:0.35:0.42:0.37:0.37:0.41"] = 623, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Undercity, The Sepulcher
				["0.58:0.06:0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.41:0.93"] = 1129, -- Shattered Sun Staging Area, Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Booty Bay
				["0.58:0.06:0.59:0.19:0.58:0.25:0.61:0.35:0.42:0.37"] = 602, -- Shattered Sun Staging Area, Silvermoon City, Tranquillien, Light's Hope Chapel, Undercity
				["0.58:0.06:0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.54:0.79"] = 1060, -- Shattered Sun Staging Area, Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Stonard 
				["0.58:0.06:0.61:0.28:0.61:0.35:0.51:0.36:0.45:0.37"] = 504, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Thondroril River, The Bulwark
				["0.58:0.06:0.61:0.28:0.61:0.35:0.51:0.36"] = 427, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Thondroril River
				["0.58:0.06:0.61:0.28:0.61:0.35:0.62:0.34"] = 394, -- Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Silvermoon City (Eversong Woods)
				["0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.41:0.93"] = 963, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Booty Bay
				["0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.42:0.86"] = 904, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Grom'gol
				["0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.54:0.79"] = 890, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Stonard
				["0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.50:0.69"] = 733, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Flame Crest
				["0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66"] = 667, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath
				["0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.46:0.65"] = 722, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Thorium Point
				["0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46"] = 408, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall
				["0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45"] = 316, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village
				["0.59:0.19:0.58:0.25:0.61:0.35"] = 179, -- Silvermoon City, Tranquillien, Light's Hope Chapel
				["0.59:0.19:0.58:0.25"] = 65, -- Silvermoon City, Tranquillien
				["0.59:0.19:0.58:0.25:0.61:0.35:0.59:0.45:0.46:0.43"] = 475, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Revantusk Village, Tarren Mill
				["0.59:0.19:0.58:0.25:0.61:0.35:0.42:0.37"] = 437, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Undercity
				["0.59:0.19:0.58:0.25:0.61:0.35:0.42:0.37:0.37:0.41"] = 469, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Undercity, The Sepulcher
				["0.59:0.19:0.58:0.25:0.61:0.28"] = 111, -- Silvermoon City, Tranquillien, Zul'Aman
				["0.59:0.19:0.58:0.25:0.61:0.35:0.42:0.37:0.46:0.43:0.55:0.46"] = 619, -- Silbermond, Tristessa, Kapelle des hoffnungsvollen Lichts, Unterstadt, Tarrens Mühle, Hammerfall
				["0.59:0.19:0.58:0.06"] = 185, -- Silvermoon City, Shattered Sun Staging Area
				["0.59:0.19:0.58:0.06:0.61:0.28"] = 415, -- Silvermoon City, Shattered Sun Staging Area, Zul'Aman
				["0.59:0.19:0.58:0.25:0.61:0.35:0.42:0.37:0.50:0.66:0.54:0.79"] = 1071, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Undercity, Kargath, Stonard
				["0.59:0.19:0.58:0.06:0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.42:0.86"] = 1240, -- Silvermoon City, Shattered Sun Staging Area, Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Grom'gol
				["0.59:0.19:0.58:0.25:0.61:0.35:0.42:0.37:0.45:0.37"] = 456, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Undercity, The Bulwark
				["0.59:0.19:0.58:0.25:0.61:0.35:0.51:0.36"] = 276, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Thondroril River
				["0.59:0.19:0.58:0.25:0.61:0.35:0.51:0.36:0.45:0.37"] = 351, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Thondroril River, The Bulwark
				["0.59:0.19:0.58:0.25:0.61:0.35:0.62:0.34"] = 240, -- Silvermoon City, Tranquillien, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Stonard (Swamp of Sorrows)
				["0.54:0.79:0.41:0.93"] = 230, -- Stonard, Booty Bay
				["0.54:0.79:0.42:0.86"] = 179, -- Stonard, Grom'gol
				["0.54:0.79:0.50:0.69"] = 176, -- Stonard, Flame Crest
				["0.54:0.79:0.50:0.66"] = 231, -- Stonard, Kargath
				["0.54:0.79:0.50:0.69:0.46:0.65"] = 208, -- Stonard, Flame Crest, Thorium Point
				["0.54:0.79:0.50:0.66:0.55:0.46:0.46:0.43:0.37:0.41"] = 707, -- Stonard, Kargath, Hammerfall, Tarren Mill, The Sepulcher
				["0.54:0.79:0.50:0.66:0.42:0.37"] = 728, -- Stonard, Kargath, Undercity
				["0.54:0.79:0.50:0.66:0.55:0.46:0.46:0.43"] = 608, -- Stonard, Kargath, Hammerfall, Tarren Mill
				["0.54:0.79:0.50:0.66:0.55:0.46"] = 493, -- Stonard, Kargath, Hammerfall
				["0.54:0.79:0.50:0.66:0.55:0.46:0.59:0.45"] = 582, -- Stonard, Kargath, Hammerfall, Revantusk Village
				["0.54:0.79:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35"] = 720, -- Stonard, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel
				["0.54:0.79:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25"] = 836, -- Stonard, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien
				["0.54:0.79:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25:0.59:0.19"] = 903, -- Stonard, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.54:0.79:0.50:0.66:0.46:0.65"] = 287, -- Stonard, Kargath, Thorium Point
				["0.54:0.79:0.50:0.66:0.42:0.37:0.61:0.35"] = 917, -- Stonard, Kargath, Undercity, Light's Hope Chapel
				["0.54:0.79:0.50:0.66:0.42:0.37:0.46:0.43"] = 795, -- Stonard, Kargath, Undercity, Tarren Mill
				["0.54:0.79:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28"] = 814, -- Stonard, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman
				["0.54:0.79:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28:0.58:0.06"] = 1062, -- Stonard, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.54:0.79:0.50:0.66:0.42:0.37:0.37:0.41"] = 762, -- Stonard, Kargath, Undercity, The Sepulcher
				["0.54:0.79:0.50:0.66:0.55:0.46:0.46:0.43:0.45:0.37"] = 677, -- Stonard, Kargath, Hammerfall, Tarren Mill, The Bulwark
				["0.54:0.79:0.50:0.66:0.55:0.46:0.46:0.43:0.51:0.36"] = 708, -- Stonard, Kargath, Hammerfall, Tarren Mill, Thondoril River
				["0.54:0.79:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.62:0.34"] = 781, -- Stonard, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Tarren Mill (Hillsbrad Foothills)
				["0.46:0.43:0.55:0.46:0.50:0.66:0.41:0.93"] = 673, -- Tarren Mill, Hammerfall, Kargath, Booty Bay
				["0.46:0.43:0.55:0.46:0.50:0.66:0.42:0.86"] = 614, -- Tarren Mill, Hammerfall, Kargath, Grom'gol
				["0.46:0.43:0.55:0.46:0.50:0.66:0.54:0.79"] = 600, -- Tarren Mill, Hammerfall, Kargath, Stonard
				["0.46:0.43:0.55:0.46:0.50:0.66:0.50:0.69"] = 443, -- Tarren Mill, Hammerfall, Kargath, Flame Crest
				["0.46:0.43:0.55:0.46:0.50:0.66"] = 377, -- Tarren Mill, Hammerfall, Kargath
				["0.46:0.43:0.55:0.46:0.50:0.66:0.46:0.65"] = 432, -- Tarren Mill, Hammerfall, Kargath, Thorium Point
				["0.46:0.43:0.55:0.46"] = 118, -- Tarren Mill, Hammerfall
				["0.46:0.43:0.59:0.45"] = 160, -- Tarren Mill, Revantusk Village
				["0.46:0.43:0.59:0.45:0.61:0.35"] = 299, -- Tarren Mill, Revantusk Village, Light's Hope Chapel
				["0.46:0.43:0.59:0.45:0.61:0.35:0.58:0.25"] = 415, -- Tarren Mill, Revantusk Village, Light's Hope Chapel, Tranquillien
				["0.46:0.43:0.59:0.45:0.61:0.35:0.58:0.25:0.59:0.19"] = 481, -- Tarren Mill, Revantusk Village, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.46:0.43:0.42:0.37"] = 139, -- Tarren Mill, Undercity
				["0.46:0.43:0.37:0.41"] = 99, -- Tarren Mill, The Sepulcher
				["0.46:0.43:0.42:0.37:0.61:0.35"] = 325, -- Tarren Mill, Undercity, Light's Hope Chapel
				["0.46:0.43:0.42:0.37:0.61:0.35:0.61:0.28"] = 416, -- Tarren Mill, Undercity, Light's Hope Chapel, Zul'Aman
				["0.46:0.43:0.59:0.45:0.61:0.35:0.61:0.28"] = 393, -- Tarren Mill, Revantusk Village, Light's Hope Chapel, Zul'Aman
				["0.46:0.43:0.59:0.45:0.61:0.35:0.61:0.28:0.58:0.06"] = 640, -- Tarren Mill, Revantusk Village, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.46:0.43:0.42:0.37:0.50:0.66:0.42:0.86"] = 787, -- Tarren Mill, Undercity, Kargath, Grom'gol
				["0.46:0.43:0.42:0.37:0.50:0.66"] = 550, -- Tarren Mill, Undercity, Kargath
				["0.46:0.43:0.42:0.37:0.50:0.66:0.54:0.79"] = 773, -- Tarren Mill, Undercity, Kargath, Stonard
				["0.46:0.43:0.45:0.37"] = 69, -- Tarren Mill, The Bulwark
				["0.46:0.43:0.51:0.36"] = 101, -- Tarren Mill, Thondroril River
				["0.46:0.43:0.51:0.36:0.61:0.35:0.62:0.34"] = 257, -- Tarren Mill, Thondoril River, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: The Bulwark (Tirisfal Glades)
				["0.45:0.37:0.42:0.37:0.61:0.35:0.58:0.25"] = 400, -- The Bulwark, Undercity, Light's Hope Chapel, Tranquillien
				["0.45:0.37:0.42:0.37:0.61:0.35:0.58:0.25:0.59:0.19"] = 466, -- The Bulwark, Undercity, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.45:0.37:0.51:0.36:0.61:0.35:0.61:0.28:0.58:0.06"] = 505, -- The Bulwark, Thondroril River, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.45:0.37:0.46:0.43:0.37:0.41"] = 177, -- The Bulwark, Tarren Mill, The Sepulcher
				["0.45:0.37:0.42:0.37"] = 90, -- The Bulwark, Undercity
				["0.45:0.37:0.42:0.37:0.61:0.35"] = 283, -- The Bulwark, Undercity, Light's Hope Chapel
				["0.45:0.37:0.46:0.43"] = 74, -- The Bulwark, Tarren Mill
				["0.45:0.37:0.46:0.43:0.55:0.46"] = 191, -- The Bulwark, Tarren Mill, Hammerfall
				["0.45:0.37:0.46:0.43:0.59:0.45"] = 233, -- The Bulwark, Tarren Mill, Revantusk Village
				["0.45:0.37:0.46:0.43:0.55:0.46:0.50:0.66:0.46:0.65"] = 505, -- The Bulwark, Tarren Mill, Hammerfall, Kargath, Thorium Point
				["0.45:0.37:0.46:0.43:0.55:0.46:0.50:0.66"] = 449, -- The Bulwark, Tarren Mill, Hammerfall, Kargath
				["0.45:0.37:0.46:0.43:0.55:0.46:0.50:0.66:0.50:0.69"] = 516, -- The Bulwark, Tarren Mill, Hammerfall, Kargath, Flame Crest
				["0.45:0.37:0.46:0.43:0.55:0.46:0.50:0.66:0.41:0.93"] = 745, -- The Bulwark, Tarren Mill, Hammerfall, Kargath, Booty Bay
				["0.45:0.37:0.46:0.43:0.55:0.46:0.50:0.66:0.42:0.86"] = 686, -- The Bulwark, Tarren Mill, Hammerfall, Kargath, Grom'gol
				["0.45:0.37:0.46:0.43:0.55:0.46:0.50:0.66:0.54:0.79"] = 672, -- The Bulwark, Tarren Mill, Hammerfall, Kargath, Stonard
				["0.45:0.37:0.51:0.36"] = 68, -- The Bulwark, Thondroril River
				["0.45:0.37:0.51:0.36:0.61:0.35"] = 164, -- The Bulwark, Thondroril River, Light's Hope Chapel
				["0.45:0.37:0.51:0.36:0.61:0.35:0.58:0.25"] = 281, -- The Bulwark, Thondroril River, Light's Hope Chapel, Tranquillien
				["0.45:0.37:0.51:0.36:0.61:0.35:0.58:0.25:0.59:0.19"] = 348, -- The Bulwark, Thondroril River, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.45:0.37:0.51:0.36:0.61:0.35:0.61:0.28"] = 257, -- The Bulwark, Thondroril River, Light's Hope Chapel, Zul'Aman
				["0.45:0.37:0.51:0.36:0.61:0.35:0.62:0.34"] = 224, -- The Bulwark, Thondoril River, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: The Sepulcher (Silverpine Forest)
				["0.37:0.41:0.46:0.43:0.55:0.46:0.50:0.66:0.41:0.93"] = 767, -- The Sepulcher, Tarren Mill, Hammerfall, Kargath, Booty Bay
				["0.37:0.41:0.46:0.43:0.55:0.46:0.50:0.66:0.42:0.86"] = 708, -- The Sepulcher, Tarren Mill, Hammerfall, Kargath, Grom'gol
				["0.37:0.41:0.46:0.43:0.55:0.46:0.50:0.66:0.54:0.79"] = 695, -- The Sepulcher, Tarren Mill, Hammerfall, Kargath, Stonard
				["0.37:0.41:0.46:0.43:0.55:0.46:0.50:0.66:0.50:0.69"] = 538, -- The Sepulcher, Tarren Mill, Hammerfall, Kargath, Flame Crest
				["0.37:0.41:0.46:0.43:0.55:0.46:0.50:0.66"] = 471, -- The Sepulcher, Tarren Mill, Hammerfall, Kargath
				["0.37:0.41:0.46:0.43:0.55:0.46:0.50:0.66:0.46:0.65"] = 526, -- The Sepulcher, Tarren Mill, Hammerfall, Kargath, Thorium Point
				["0.37:0.41:0.46:0.43:0.55:0.46"] = 212, -- The Sepulcher, Tarren Mill, Hammerfall
				["0.37:0.41:0.46:0.43:0.59:0.45"] = 255, -- The Sepulcher, Tarren Mill, Revantusk Village
				["0.37:0.41:0.42:0.37:0.61:0.35"] = 299, -- The Sepulcher, Undercity, Light's Hope Chapel
				["0.37:0.41:0.42:0.37:0.61:0.35:0.58:0.25"] = 415, -- The Sepulcher, Undercity, Light's Hope Chapel, Tranquillien
				["0.37:0.41:0.42:0.37:0.61:0.35:0.58:0.25:0.59:0.19"] = 483, -- The Sepulcher, Undercity, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.37:0.41:0.42:0.37"] = 112, -- The Sepulcher, Undercity
				["0.37:0.41:0.46:0.43"] = 95, -- The Sepulcher, Tarren Mill
				["0.37:0.41:0.42:0.37:0.61:0.35:0.61:0.28"] = 392, -- The Sepulcher, Undercity, Light's Hope Chapel, Zul'Aman
				["0.37:0.41:0.42:0.37:0.61:0.35:0.61:0.28:0.58:0.06"] = 639, -- The Sepulcher, Undercity, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.37:0.41:0.46:0.43:0.45:0.37"] = 164, -- The Sepulcher, Tarren Mill, The Bulwark
				["0.37:0.41:0.46:0.43:0.51:0.36"] = 196, -- The Sepulcher, Tarren Mill, Thondroril River
				["0.37:0.41:0.46:0.43:0.51:0.36:0.61:0.35:0.62:0.34"] = 352, -- The Sepulcher, Tarren Mill, Thondoril River, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Thondroril River (Western Plaguelands)
				["0.51:0.36:0.61:0.35:0.58:0.25:0.59:0.19"] = 280, -- Thondroril River, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.51:0.36:0.45:0.37"] = 76, -- Thondroril River, The Bulwark
				["0.51:0.36:0.61:0.35:0.61:0.28:0.58:0.06"] = 438, -- Thondroril River, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.51:0.36:0.61:0.35"] = 96, -- Thondroril River, Light's Hope Chapel
				["0.51:0.36:0.46:0.43:0.55:0.46:0.50:0.66:0.42:0.86"] = 714, -- Thondroril River, Tarren Mill, Hammerfall, Kargath, Grom'gol
				["0.51:0.36:0.46:0.43:0.55:0.46:0.50:0.66:0.41:0.93"] = 773, -- Thondroril River, Tarren Mill, Hammerfall, Kargath, Booty Bay
				["0.51:0.36:0.46:0.43:0.55:0.46:0.50:0.66:0.50:0.69"] = 543, -- Thondroril River, Tarren Mill, Hammerfall, Kargath, Flame Crest
				["0.51:0.36:0.61:0.35:0.61:0.28"] = 190, -- Thondroril River, Light's Hope Chapel, Zul'Aman
				["0.51:0.36:0.46:0.43:0.55:0.46:0.50:0.66:0.46:0.65"] = 531, -- Thondroril River, Tarren Mill, Hammerfall, Kargath, Thorium Point
				["0.51:0.36:0.42:0.37"] = 160, -- Thondroril River, Undercity
				["0.51:0.36:0.46:0.43:0.37:0.41"] = 204, -- Thondroril River, Tarren Mill, The Sepulcher
				["0.51:0.36:0.46:0.43"] = 101, -- Thondroril River, Tarren Mill
				["0.51:0.36:0.61:0.35:0.59:0.45"] = 234, -- Thondroril River, Light's Hope Chapel, Revantusk Village
				["0.51:0.36:0.61:0.35:0.58:0.25"] = 214, -- Thondroril River, Light's Hope Chapel, Tranquillien
				["0.51:0.36:0.46:0.43:0.55:0.46"] = 218, -- Thondroril River, Tarren Mill, Hammerfall
				["0.51:0.36:0.46:0.43:0.55:0.46:0.50:0.66:0.54:0.79"] = 700, -- Thondroril River, Tarren Mill, Hammerfall, Kargath, Stonard
				["0.51:0.36:0.46:0.43:0.55:0.46:0.50:0.66"] = 476, -- Thondroril River, Tarren Mill, Hammerfall, Kargath
				["0.51:0.36:0.61:0.35:0.62:0.34"] = 156, -- Thondoril River, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Thorium Point (Searing Gorge)
				["0.46:0.65:0.50:0.69:0.42:0.86:0.41:0.93"] = 312, -- Thorium Point, Flame Crest, Grom'gol, Booty Bay
				["0.46:0.65:0.50:0.69:0.42:0.86"] = 234, -- Thorium Point, Flame Crest, Grom'gol
				["0.46:0.65:0.50:0.69:0.54:0.79"] = 218, -- Thorium Point, Flame Crest, Stonard
				["0.46:0.65:0.50:0.69"] = 61, -- Thorium Point, Flame Crest
				["0.46:0.65:0.50:0.66"] = 70, -- Thorium Point, Kargath
				["0.46:0.65:0.50:0.66:0.55:0.46:0.46:0.43:0.37:0.41"] = 545, -- Thorium Point, Kargath, Hammerfall, Tarren Mill, The Sepulcher
				["0.46:0.65:0.50:0.66:0.42:0.37"] = 566, -- Thorium Point, Kargath, Undercity
				["0.46:0.65:0.50:0.66:0.55:0.46:0.46:0.43"] = 446, -- Thorium Point, Kargath, Hammerfall, Tarren Mill
				["0.46:0.65:0.50:0.66:0.55:0.46"] = 332, -- Thorium Point, Kargath, Hammerfall
				["0.46:0.65:0.50:0.66:0.55:0.46:0.59:0.45"] = 420, -- Thorium Point, Kargath, Hammerfall, Revantusk Village
				["0.46:0.65:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35"] = 559, -- Thorium Point, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel
				["0.46:0.65:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25"] = 674, -- Thorium Point, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien
				["0.46:0.65:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.58:0.25:0.59:0.19"] = 741, -- Thorium Point, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.46:0.65:0.50:0.66:0.42:0.86"] = 307, -- Thorium Point, Kargath, Grom'gol
				["0.46:0.65:0.50:0.66:0.54:0.79"] = 294, -- Thorium Point, Kargath, Stonard
				["0.46:0.65:0.50:0.66:0.41:0.93"] = 366, -- Thorium Point, Kargath, Booty Bay
				["0.46:0.65:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28"] = 652, -- Thorium Point, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman
				["0.46:0.65:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.61:0.28:0.58:0.06"] = 900, -- Thorium Point, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.46:0.65:0.50:0.66:0.42:0.37:0.59:0.45"] = 775, -- Thorium Point, Kargath, Undercity, Revantusk Village
				["0.46:0.65:0.50:0.66:0.55:0.46:0.46:0.43:0.45:0.37"] = 515, -- Thorium Point, Kargath, Hammerfall, Tarren Mill, The Bulwark
				["0.46:0.65:0.50:0.66:0.55:0.46:0.46:0.43:0.51:0.36"] = 547, -- Thorium Point, Kargath, Hammerfall, Tarren Mill, Thondroril River
				["0.46:0.65:0.50:0.66:0.55:0.46:0.59:0.45:0.61:0.35:0.62:0.34"] = 619, -- Thorium Point, Kargath, Hammerfall, Revantusk Village, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Tranquillien (Ghostlands)
				["0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.41:0.93"] = 900, -- Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Booty Bay
				["0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.42:0.86"] = 841, -- Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Grom'gol
				["0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.54:0.79"] = 827, -- Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Stonard
				["0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.50:0.69"] = 671, -- Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Flame Crest
				["0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66"] = 604, -- Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath
				["0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.46:0.65"] = 659, -- Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Thorium Point
				["0.58:0.25:0.61:0.35:0.59:0.45:0.55:0.46"] = 345, -- Tranquillien, Light's Hope Chapel, Revantusk Village, Hammerfall
				["0.58:0.25:0.61:0.35:0.59:0.45"] = 253, -- Tranquillien, Light's Hope Chapel, Revantusk Village
				["0.58:0.25:0.61:0.35"] = 116, -- Tranquillien, Light's Hope Chapel
				["0.58:0.25:0.59:0.19"] = 74, -- Tranquillien, Silvermoon City
				["0.58:0.25:0.61:0.35:0.42:0.37"] = 373, -- Tranquillien, Light's Hope Chapel, Undercity
				["0.58:0.25:0.61:0.35:0.42:0.37:0.37:0.41"] = 406, -- Tranquillien, Light's Hope Chapel, Undercity, The Sepulcher
				["0.58:0.25:0.61:0.35:0.59:0.45:0.46:0.43"] = 412, -- Tranquillien, Light's Hope Chapel, Revantusk Village, Tarren Mill
				["0.58:0.25:0.61:0.28"] = 52, -- Tranquillien, Zul'Aman
				["0.58:0.25:0.59:0.19:0.58:0.06"] = 257, -- Tranquillien, Silvermoon City, Shattered Sun Staging Area
				["0.58:0.25:0.61:0.35:0.42:0.37:0.46:0.43:0.55:0.46"] = 556, -- Tranquillien, Light's Hope Chapel, Undercity, Tarren Mill, Hammerfall
				["0.58:0.25:0.61:0.35:0.42:0.37:0.45:0.37"] = 393, -- Tranquillien, Light's Hope Chapel, Undercity, The Bulwark
				["0.58:0.25:0.61:0.35:0.51:0.36:0.45:0.37"] = 288, -- Tranquillien, Light's Hope Chapel, Thondroril River, The Bulwark
				["0.58:0.25:0.61:0.35:0.51:0.36"] = 213, -- Tranquillien, Light's Hope Chapel, Thondroril River
				["0.58:0.25:0.61:0.35:0.62:0.34"] = 177, -- Tranquillien, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Undercity (Tirisfal Glades)
				["0.42:0.37:0.50:0.66:0.41:0.93"] = 785, -- Undercity, Kargath, Booty Bay
				["0.42:0.37:0.50:0.66:0.42:0.86"] = 725, -- Undercity, Kargath, Grom'gol
				["0.42:0.37:0.50:0.66:0.54:0.79"] = 712, -- Undercity, Kargath, Stonard
				["0.42:0.37:0.50:0.66:0.50:0.69"] = 555, -- Undercity, Kargath, Flame Crest
				["0.42:0.37:0.50:0.66"] = 489, -- Undercity, Kargath
				["0.42:0.37:0.50:0.66:0.46:0.65"] = 544, -- Undercity, Kargath, Thorium Point
				["0.42:0.37:0.37:0.41"] = 106, -- Undercity, The Sepulcher
				["0.42:0.37:0.46:0.43"] = 141, -- Undercity, Tarren Mill
				["0.42:0.37:0.55:0.46"] = 301, -- Undercity, Hammerfall
				["0.42:0.37:0.59:0.45"] = 284, -- Undercity, Revantusk Village
				["0.42:0.37:0.61:0.35"] = 261, -- Undercity, Light's Hope Chapel
				["0.42:0.37:0.61:0.35:0.58:0.25"] = 378, -- Undercity, Light's Hope Chapel, Tranquillien
				["0.42:0.37:0.61:0.35:0.58:0.25:0.59:0.19"] = 444, -- Undercity, Light's Hope Chapel, Tranquillien, Silvermoon City
				["0.42:0.37:0.61:0.35:0.61:0.28"] = 356, -- Undercity, Light's Hope Chapel, Zul'Aman
				["0.42:0.37:0.61:0.35:0.61:0.28:0.58:0.06"] = 601, -- Undercity, Light's Hope Chapel, Zul'Aman, Shattered Sun Staging Area
				["0.42:0.37:0.45:0.37"] = 89, -- Undercity, The Bulwark
				["0.42:0.37:0.51:0.36"] = 153, -- Undercity, Thondroril River
				["0.42:0.37:0.51:0.36:0.61:0.35:0.62:0.34"] = 309, -- Undercity, Thondoril River, Light's Hope Chapel, Acherus: The Ebon Hold

				-- Horde: Zul'Aman
				["0.61:0.28:0.58:0.25"] = 52, -- Zul'Aman, Tranquillien
				["0.61:0.28:0.58:0.25:0.59:0.19"] = 118, -- Zul'Aman, Tranquillien, Silvermoon City
				["0.61:0.28:0.61:0.35:0.42:0.37"] = 362, -- Zul'Aman, Light's Hope Chapel, Undercity
				["0.61:0.28:0.61:0.35"] = 102, -- Zul'Aman, Light's Hope Chapel
				["0.61:0.28:0.61:0.35:0.42:0.37:0.37:0.41"] = 395, -- Zul'Aman, Light's Hope Chapel, Undercity, The Sepulcher
				["0.61:0.28:0.61:0.35:0.59:0.45"] = 244, -- Zul'Aman, Light's Hope Chapel, Revantusk Village
				["0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46"] = 335, -- Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall
				["0.61:0.28:0.61:0.35:0.59:0.45:0.46:0.43"] = 401, -- Zul'Aman, Light's Hope Chapel, Revantusk Village, Tarren Mill
				["0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.41:0.93"] = 889, -- Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Booty Bay
				["0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.42:0.86"] = 831, -- Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Grom'gol
				["0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.54:0.79"] = 817, -- Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Stonard
				["0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.50:0.69"] = 661, -- Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Flame Crest
				["0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66:0.46:0.65"] = 648, -- Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath, Thorium Point
				["0.61:0.28:0.61:0.35:0.59:0.45:0.55:0.46:0.50:0.66"] = 593, -- Zul'Aman, Light's Hope Chapel, Revantusk Village, Hammerfall, Kargath
				["0.61:0.28:0.58:0.06"] = 252, -- Zul'Aman, Shattered Sun Staging Area
				["0.61:0.28:0.58:0.06:0.59:0.19"] = 416, -- Zul'Aman, Shattered Sun Staging Area, Silvermoon City
				["0.61:0.28:0.61:0.35:0.51:0.36:0.45:0.37"] = 275, -- Zul'Aman, Light's Hope Chapel, Thondroril River, The Bulwark
				["0.61:0.28:0.61:0.35:0.51:0.36"] = 201, -- Zul'Aman, Light's Hope Chapel, Thondroril River
				["0.61:0.28:0.61:0.35:0.62:0.34"] = 166, -- Zul'Aman, Light's Hope Chapel, Acherus: The Ebon Hold

			},

			-- Horde: Kalimdor
			[1414] = {

				-- Horde: Bloodvenom Post (Felwood)
				["0.46:0.30:0.56:0.53:0.55:0.73:0.61:0.80"] = 518, -- Bloodvenom Post, Crossroads, Freewind Post, Gadgetzan
				["0.46:0.30:0.56:0.53:0.44:0.69:0.42:0.79"] = 623, -- Bloodvenom Post, Crossroads, Camp Mojache, Cenarion Hold
				["0.46:0.30:0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76"] = 619, -- Bloodvenom Post, Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.46:0.30:0.56:0.53:0.55:0.73"] = 426, -- Bloodvenom Post, Crossroads, Freewind Post
				["0.46:0.30:0.56:0.53:0.53:0.61:0.57:0.64:0.58:0.70"] = 434, -- Bloodvenom Post, Crossroads, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.46:0.30:0.56:0.53:0.53:0.61:0.57:0.64"] = 373, -- Bloodvenom Post, Crossroads, Camp Taurajo, Brackenwall Village
				["0.46:0.30:0.56:0.53:0.53:0.61"] = 315, -- Bloodvenom Post, Crossroads, Camp Taurajo
				["0.46:0.30:0.56:0.53:0.44:0.69"] = 493, -- Bloodvenom Post, Crossroads, Camp Mojache
				["0.46:0.30:0.41:0.37:0.41:0.47:0.32:0.58"] = 398, -- Bloodvenom Post, Zoram'gar Outpost, Sun Rock Retreat, Shadowprey Village
				["0.46:0.30:0.56:0.53:0.45:0.56"] = 347, -- Bloodvenom Post, Crossroads, Thunder Bluff
				["0.46:0.30:0.56:0.53"] = 241, -- Bloodvenom Post, Crossroads
				["0.46:0.30:0.56:0.53:0.61:0.55"] = 292, -- Bloodvenom Post, Crossroads, Ratchet
				["0.46:0.30:0.63:0.44"] = 259, -- Bloodvenom Post, Orgrimmar
				["0.46:0.30:0.50:0.35:0.55:0.42"] = 151, -- Bloodvenom Post, Emerald Sanctuary, Splintertree Post
				["0.46:0.30:0.41:0.37:0.41:0.47"] = 256, -- Bloodvenom Post, Zoram'gar Outpost, Sun Rock Retreat
				["0.46:0.30:0.41:0.37"] = 136, -- Bloodvenom Post, Zoram'gar Outpost
				["0.46:0.30:0.50:0.35"] = 69, -- Bloodvenom Post, Emerald Sanctuary
				["0.46:0.30:0.63:0.36"] = 234, -- Bloodvenom Post, Valormok
				["0.46:0.30:0.64:0.23"] = 190, -- Bloodvenom Post, Everlook
				["0.46:0.30:0.54:0.21"] = 166, -- Bloodvenom Post, Moonglade
				["0.46:0.30:0.41:0.37:0.55:0.42"] = 309, -- Bloodvenom Post, Zoram'gar Outpost, Splintertree Post

				-- Horde: Brackenwall Village (Dustwallow Marsh)
				["0.57:0.64:0.61:0.80"] = 205, -- Brackenwall Village, Gadgetzan
				["0.57:0.64:0.55:0.73:0.44:0.69:0.42:0.79"] = 357, -- Brackenwall Village, Freewind Post, Camp Mojache, Cenarion Hold
				["0.57:0.64:0.55:0.73:0.61:0.80:0.50:0.76"] = 298, -- Brackenwall Village, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.57:0.64:0.55:0.73"] = 105, -- Brackenwall Village, Freewind Post
				["0.57:0.64:0.58:0.70"] = 62, -- Brackenwall Village, Mudsprocket
				["0.57:0.64:0.55:0.73:0.44:0.69"] = 227, -- Brackenwall Village, Freewind Post, Camp Mojache
				["0.57:0.64:0.53:0.61"] = 49, -- Brackenwall Village, Camp Taurajo
				["0.57:0.64:0.45:0.56"] = 225, -- Brackenwall Village, Thunder Bluff
				["0.57:0.64:0.53:0.61:0.45:0.56:0.32:0.58"] = 321, -- Brackenwall Village, Camp Taurajo, Thunder Bluff, Shadowprey Village
				["0.57:0.64:0.53:0.61:0.56:0.53:0.41:0.47"] = 276, -- Brackenwall Village, Camp Taurajo, Crossroads, Sun Rock Retreat
				["0.57:0.64:0.56:0.53"] = 162, -- Brackenwall Village, Crossroads
				["0.57:0.64:0.61:0.55"] = 90, -- Brackenwall Village, Ratchet
				["0.57:0.64:0.63:0.44"] = 217, -- Brackenwall Village, Orgrimmar
				["0.57:0.64:0.61:0.55:0.63:0.44:0.55:0.42"] = 273, -- Brackenwall Village, Ratchet, Orgrimmar, Splintertree Post
				["0.57:0.64:0.61:0.55:0.63:0.44:0.63:0.36"] = 279, -- Brackenwall Village, Ratchet, Orgrimmar, Valormok
				["0.57:0.64:0.61:0.55:0.63:0.44:0.55:0.42:0.50:0.35"] = 351, -- Brackenwall Village, Ratchet, Orgrimmar, Splintertree Post, Emerald Sanctuary
				["0.57:0.64:0.53:0.61:0.56:0.53:0.41:0.37"] = 357, -- Brackenwall Village, Camp Taurajo, Crossroads, Zoram'gar Outpost
				["0.57:0.64:0.53:0.61:0.56:0.53:0.46:0.30"] = 380, -- Brackenwall Village, Camp Taurajo, Crossroads, Bloodvenom Post
				["0.57:0.64:0.53:0.61:0.56:0.53:0.46:0.30:0.54:0.21"] = 501, -- Brackenwall Village, Camp Taurajo, Crossroads, Bloodvenom Post, Moonglade
				["0.57:0.64:0.61:0.55:0.63:0.44:0.63:0.36:0.64:0.23"] = 408, -- Brackenwall Village, Ratchet, Orgrimmar, Valormok, Everlook

				-- Horde: Camp Mojache (The Barrens)
				["0.44:0.69:0.42:0.79"] = 130, -- Camp Mojache, Cenarion Hold
				["0.44:0.69:0.42:0.79:0.50:0.76"] = 222, -- Camp Mojache, Cenarion Hold, Marshal's Refuge
				["0.44:0.69:0.61:0.80"] = 201, -- Camp Mojache, Gadgetzan
				["0.44:0.69:0.55:0.73"] = 107, -- Camp Mojache, Freewind Post
				["0.44:0.69:0.55:0.73:0.58:0.70"] = 176, -- Camp Mojache, Freewind Post, Mudsprocket
				["0.44:0.69:0.55:0.73:0.57:0.64"] = 203, -- Camp Mojache, Freewind Post, Brackenwall Village
				["0.44:0.69:0.55:0.73:0.53:0.61"] = 245, -- Camp Mojache, Freewind Post, Camp Taurajo
				["0.44:0.69:0.55:0.73:0.57:0.64:0.61:0.55"] = 290, -- Camp Mojache, Freewind Post, Brackenwall Village, Ratchet
				["0.44:0.69:0.56:0.53"] = 265, -- Camp Mojache, Crossroads
				["0.44:0.69:0.45:0.56"] = 259, -- Camp Mojache, Thunder Bluff
				["0.44:0.69:0.32:0.58"] = 200, -- Camp Mojache, Shadowprey Village
				["0.44:0.69:0.32:0.58:0.41:0.47"] = 400, -- Camp Mojache, Shadowprey Village, Sun Rock Retreat
				["0.44:0.69:0.56:0.53:0.41:0.37"] = 495, -- Camp Mojache, Crossroads, Zoram'gar Outpost
				["0.44:0.69:0.56:0.53:0.55:0.42"] = 427, -- Camp Mojache, Crossroads, Splintertree Post
				["0.44:0.69:0.56:0.53:0.63:0.44"] = 381, -- Camp Mojache, Crossroads, Orgrimmar
				["0.44:0.69:0.56:0.53:0.63:0.36"] = 428, -- Camp Mojache, Crossroads, Valormok
				["0.44:0.69:0.56:0.53:0.55:0.42:0.50:0.35"] = 505, -- Camp Mojache, Crossroads, Splintertree Post, Emerald Sanctuary
				["0.44:0.69:0.56:0.53:0.46:0.30"] = 518, -- Camp Mojache, Crossroads, Bloodvenom Post
				["0.44:0.69:0.56:0.53:0.46:0.30:0.54:0.21"] = 639, -- Camp Mojache, Crossroads, Bloodvenom Post, Moonglade
				["0.44:0.69:0.56:0.53:0.63:0.36:0.64:0.23"] = 557, -- Camp Mojache, Crossroads, Valormok, Everlook
				["0.44:0.69:0.55:0.73:0.61:0.80:0.50:0.76"] = 301, -- Camp Mojache, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.44:0.69:0.56:0.53:0.61:0.55"] = 316, -- Camp Mojache, Crossroads, Ratchet
				["0.44:0.69:0.56:0.53:0.63:0.44:0.64:0.23"] = 621, -- Camp Mojache, Crossroads, Orgrimmar, Everlook
				["0.44:0.69:0.56:0.53:0.41:0.47"] = 415, -- Camp Mojache, Crossroads, Sun Rock Retreat
				["0.44:0.69:0.55:0.73:0.57:0.64:0.61:0.55:0.63:0.44"] = 386, -- Camp Mojache, Freewind Post, Brackenwall Village, Ratchet, Orgrimmar
				["0.44:0.69:0.56:0.53:0.53:0.61"] = 338, -- Camp Mojache, Crossroads, Camp Taurajo

				-- Horde: Camp Taurajo (The Barrens)
				["0.53:0.61:0.55:0.73:0.61:0.80"] = 218, -- Camp Taurajo, Freewind Post, Gadgetzan
				["0.53:0.61:0.55:0.73:0.44:0.69:0.42:0.79"] = 378, -- Camp Taurajo, Freewind Post, Camp Mojache, Cenarion Hold
				["0.53:0.61:0.55:0.73:0.61:0.80:0.50:0.76"] = 319, -- Camp Taurajo, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.53:0.61:0.55:0.73"] = 125, -- Camp Taurajo, Freewind Post
				["0.53:0.61:0.57:0.64:0.58:0.70"] = 121, -- Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.53:0.61:0.57:0.64"] = 60, -- Camp Taurajo, Brackenwall Village
				["0.53:0.61:0.55:0.73:0.44:0.69"] = 248, -- Camp Taurajo, Freewind Post, Camp Mojache
				["0.53:0.61:0.45:0.56:0.32:0.58"] = 273, -- Camp Taurajo, Thunder Bluff, Shadowprey Village
				["0.53:0.61:0.45:0.56"] = 114, -- Camp Taurajo, Thunder Bluff
				["0.53:0.61:0.56:0.53"] = 79, -- Camp Taurajo, Crossroads
				["0.53:0.61:0.56:0.53:0.61:0.55"] = 130, -- Camp Taurajo, Crossroads, Ratchet
				["0.53:0.61:0.56:0.53:0.63:0.44"] = 195, -- Camp Taurajo, Crossroads, Orgrimmar
				["0.53:0.61:0.56:0.53:0.55:0.42"] = 241, -- Camp Taurajo, Crossroads, Splintertree Post
				["0.53:0.61:0.56:0.53:0.41:0.47"] = 228, -- Camp Taurajo, Crossroads, Sun Rock Retreat
				["0.53:0.61:0.56:0.53:0.41:0.37"] = 309, -- Camp Taurajo, Crossroads, Zoram'gar Outpost
				["0.53:0.61:0.56:0.53:0.55:0.42:0.50:0.35"] = 319, -- Camp Taurajo, Crossroads, Splintertree Post, Emerald Sanctuary
				["0.53:0.61:0.56:0.53:0.63:0.36"] = 242, -- Camp Taurajo, Crossroads, Valormok
				["0.53:0.61:0.56:0.53:0.46:0.30"] = 332, -- Camp Taurajo, Crossroads, Bloodvenom Post
				["0.53:0.61:0.56:0.53:0.46:0.30:0.54:0.21"] = 453, -- Camp Taurajo, Crossroads, Bloodvenom Post, Moonglade
				["0.53:0.61:0.56:0.53:0.63:0.36:0.64:0.23"] = 372, -- Camp Taurajo, Crossroads, Valormok, Everlook
				["0.53:0.61:0.56:0.53:0.44:0.69"] = 330, -- Camp Taurajo, Crossroads, Camp Mojache
				["0.53:0.61:0.56:0.53:0.63:0.44:0.64:0.23"] = 435, -- Camp Taurajo, Crossroads, Orgrimmar, Everlook
				["0.53:0.61:0.55:0.73:0.58:0.70"] = 194, -- Camp Taurajo, Freewind Post, Mudsprocket

				-- Horde: Cenarion Hold (Silithus)
				["0.42:0.79:0.61:0.80"] = 242, -- Cenarion Hold, Gadgetzan
				["0.42:0.79:0.50:0.76"] = 97, -- Cenarion Hold, Marshal's Refuge
				["0.42:0.79:0.44:0.69:0.55:0.73"] = 237, -- Cenarion Hold, Camp Mojache, Freewind Post
				["0.42:0.79:0.44:0.69:0.55:0.73:0.58:0.70"] = 306, -- Cenarion Hold, Camp Mojache, Freewind Post, Mudsprocket
				["0.42:0.79:0.44:0.69:0.55:0.73:0.57:0.64"] = 332, -- Cenarion Hold, Camp Mojache, Freewind Post, Brackenwall Village
				["0.42:0.79:0.44:0.69:0.55:0.73:0.53:0.61"] = 374, -- Cenarion Hold, Camp Mojache, Freewind Post, Camp Taurajo
				["0.42:0.79:0.44:0.69"] = 131, -- Cenarion Hold, Camp Mojache
				["0.42:0.79:0.44:0.69:0.32:0.58"] = 330, -- Cenarion Hold, Camp Mojache, Shadowprey Village
				["0.42:0.79:0.44:0.69:0.45:0.56"] = 390, -- Cenarion Hold, Camp Mojache, Thunder Bluff
				["0.42:0.79:0.44:0.69:0.56:0.53"] = 394, -- Cenarion Hold, Camp Mojache, Crossroads
				["0.42:0.79:0.44:0.69:0.55:0.73:0.57:0.64:0.61:0.55"] = 420, -- Cenarion Hold, Camp Mojache, Freewind Post, Brackenwall Village, Ratchet
				["0.42:0.79:0.44:0.69:0.56:0.53:0.63:0.44"] = 511, -- Cenarion Hold, Camp Mojache, Crossroads, Orgrimmar
				["0.42:0.79:0.44:0.69:0.56:0.53:0.55:0.42"] = 556, -- Cenarion Hold, Camp Mojache, Crossroads, Splintertree Post
				["0.42:0.79:0.44:0.69:0.32:0.58:0.41:0.47"] = 528, -- Cenarion Hold, Camp Mojache, Shadowprey Village, Sun Rock Retreat
				["0.42:0.79:0.44:0.69:0.56:0.53:0.41:0.37"] = 624, -- Cenarion Hold, Camp Mojache, Crossroads, Zoram'gar Outpost
				["0.42:0.79:0.44:0.69:0.56:0.53:0.55:0.42:0.50:0.35"] = 634, -- Cenarion Hold, Camp Mojache, Crossroads, Splintertree Post, Emerald Sanctuary
				["0.42:0.79:0.44:0.69:0.56:0.53:0.46:0.30"] = 647, -- Cenarion Hold, Camp Mojache, Crossroads, Bloodvenom Post
				["0.42:0.79:0.44:0.69:0.56:0.53:0.63:0.36"] = 557, -- Cenarion Hold, Camp Mojache, Crossroads, Valormok
				["0.42:0.79:0.44:0.69:0.56:0.53:0.63:0.36:0.64:0.23"] = 686, -- Cenarion Hold, Camp Mojache, Crossroads, Valormok, Everlook
				["0.42:0.79:0.44:0.69:0.56:0.53:0.46:0.30:0.54:0.21"] = 769, -- Cenarion Hold, Camp Mojache, Crossroads, Bloodvenom Post, Moonglade
				["0.42:0.79:0.44:0.69:0.56:0.53:0.61:0.55"] = 446, -- Cenarion Hold, Camp Mojache, Crossroads, Ratchet
				["0.42:0.79:0.44:0.69:0.56:0.53:0.63:0.44:0.64:0.23"] = 750, -- Cenarion Hold, Camp Mojache, Crossroads, Orgrimmar, Everlook
				["0.42:0.79:0.61:0.80:0.63:0.44"] = 591, -- Cenarion Hold, Gadgetzan, Orgrimmar
				["0.42:0.79:0.50:0.76:0.61:0.80:0.55:0.73"] = 292, -- Cenarion Hold, Marshal's Refuge, Gadgetzan, Freewind Post
				["0.42:0.79:0.61:0.80:0.55:0.73"] = 328, -- Cenarion Hold, Gadgetzan, Freewind Post
				["0.42:0.79:0.50:0.76:0.61:0.80:0.55:0.73:0.53:0.61"] = 428, -- Cenarion Hold, Marshal's Refuge, Gadgetzan, Freewind Post, Camp Taurajo

				-- Horde: Crossroads (The Barrens)
				["0.56:0.53:0.44:0.69:0.42:0.79"] = 382, -- Crossroads, Camp Mojache, Cenarion Hold
				["0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76"] = 379, -- Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.56:0.53:0.61:0.80"] = 303, -- Crossroads, Gadgetzan
				["0.56:0.53:0.55:0.73"] = 184, -- Crossroads, Freewind Post
				["0.56:0.53:0.53:0.61:0.57:0.64:0.58:0.70"] = 193, -- Crossroads, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.56:0.53:0.57:0.64"] = 162, -- Crossroads, Brackenwall Village
				["0.56:0.53:0.53:0.61"] = 74, -- Crossroads, Camp Taurajo
				["0.56:0.53:0.44:0.69"] = 252, -- Crossroads, Camp Mojache
				["0.56:0.53:0.45:0.56:0.32:0.58"] = 266, -- Crossroads, Thunder Bluff, Shadowprey Village
				["0.56:0.53:0.45:0.56"] = 107, -- Crossroads, Thunder Bluff
				["0.56:0.53:0.41:0.47"] = 150, -- Crossroads, Sun Rock Retreat
				["0.56:0.53:0.55:0.42"] = 162, -- Crossroads, Splintertree Post
				["0.56:0.53:0.63:0.44"] = 117, -- Crossroads, Orgrimmar
				["0.56:0.53:0.61:0.55"] = 52, -- Crossroads, Ratchet
				["0.56:0.53:0.63:0.36"] = 164, -- Crossroads, Valormok
				["0.56:0.53:0.55:0.42:0.50:0.35"] = 241, -- Crossroads, Splintertree Post, Emerald Sanctuary
				["0.56:0.53:0.41:0.37"] = 230, -- Crossroads, Zoram'gar Outpost
				["0.56:0.53:0.46:0.30"] = 254, -- Crossroads, Bloodvenom Post
				["0.56:0.53:0.46:0.30:0.54:0.21"] = 375, -- Crossroads, Bloodvenom Post, Moonglade
				["0.56:0.53:0.63:0.36:0.64:0.23"] = 293, -- Crossroads, Valormok, Everlook
				["0.56:0.53:0.61:0.55:0.61:0.80:0.50:0.76"] = 395, -- Crossroads, Ratchet, Gadgetzan, Marshal's Refuge

				-- Horde: Emerald Sanctuary (Felwood)
				["0.50:0.35:0.55:0.42:0.56:0.53:0.55:0.73:0.61:0.80"] = 514, -- Emerald Sanctuary, Splintertree Post, Crossroads, Freewind Post, Gadgetzan
				["0.50:0.35:0.55:0.42:0.56:0.53:0.44:0.69:0.42:0.79"] = 618, -- Emerald Sanctuary, Splintertree Post, Crossroads, Camp Mojache, Cenarion Hold
				["0.50:0.35:0.55:0.42:0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76"] = 615, -- Emerald Sanctuary, Splintertree Post, Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.50:0.35:0.55:0.42:0.56:0.53:0.55:0.73"] = 421, -- Emerald Sanctuary, Splintertree Post, Crossroads, Freewind Post
				["0.50:0.35:0.55:0.42:0.56:0.53:0.53:0.61:0.57:0.64:0.58:0.70"] = 430, -- Emerald Sanctuary, Splintertree Post, Crossroads, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.50:0.35:0.55:0.42:0.56:0.53:0.53:0.61:0.57:0.64"] = 368, -- Emerald Sanctuary, Splintertree Post, Crossroads, Camp Taurajo, Brackenwall Village
				["0.50:0.35:0.55:0.42:0.56:0.53:0.53:0.61"] = 310, -- Emerald Sanctuary, Splintertree Post, Crossroads, Camp Taurajo
				["0.50:0.35:0.55:0.42:0.56:0.53:0.44:0.69"] = 489, -- Emerald Sanctuary, Splintertree Post, Crossroads, Camp Mojache
				["0.50:0.35:0.41:0.37:0.41:0.47:0.32:0.58"] = 378, -- Emerald Sanctuary, Zoram'gar Outpost, Sun Rock Retreat, Shadowprey Village
				["0.50:0.35:0.55:0.42:0.56:0.53:0.45:0.56"] = 343, -- Emerald Sanctuary, Splintertree Post, Crossroads, Thunder Bluff
				["0.50:0.35:0.55:0.42:0.56:0.53"] = 237, -- Emerald Sanctuary, Splintertree Post, Crossroads
				["0.50:0.35:0.55:0.42:0.63:0.44:0.61:0.55"] = 280, -- Emerald Sanctuary, Splintertree Post, Orgrimmar, Ratchet
				["0.50:0.35:0.55:0.42:0.63:0.44"] = 173, -- Emerald Sanctuary, Splintertree Post, Orgrimmar
				["0.50:0.35:0.55:0.42"] = 84, -- Emerald Sanctuary, Splintertree Post
				["0.50:0.35:0.41:0.37:0.41:0.47"] = 235, -- Emerald Sanctuary, Zoram'gar Outpost, Sun Rock Retreat
				["0.50:0.35:0.41:0.37"] = 115, -- Emerald Sanctuary, Zoram'gar Outpost
				["0.50:0.35:0.46:0.30"] = 80, -- Emerald Sanctuary, Bloodvenom Post
				["0.50:0.35:0.55:0.42:0.63:0.36"] = 169, -- Emerald Sanctuary, Splintertree Post, Valormok
				["0.50:0.35:0.46:0.30:0.64:0.23"] = 226, -- Emerald Sanctuary, Bloodvenom Post, Everlook
				["0.50:0.35:0.46:0.30:0.54:0.21"] = 203, -- Emerald Sanctuary, Bloodvenom Post, Moonglade
				["0.50:0.35:0.46:0.30:0.56:0.53:0.61:0.55"] = 330, -- Emerald Sanctuary, Bloodvenom Post, Crossroads, Ratchet
				["0.50:0.35:0.55:0.42:0.63:0.36:0.64:0.23"] = 298, -- Emerald Sanctuary, Splintertree Post, Valormok, Everlook
				["0.50:0.35:0.55:0.42:0.63:0.44:0.64:0.23"] = 413, -- Emerald Sanctuary, Splintertree Post, Orgrimmar, Everlook

				-- Horde: Everlook (Winterspring)
				["0.64:0.23:0.63:0.36:0.56:0.53:0.55:0.73:0.61:0.80"] = 575, -- Everlook, Valormok, Crossroads, Freewind Post, Gadgetzan
				["0.64:0.23:0.63:0.36:0.56:0.53:0.55:0.73"] = 483, -- Everlook, Valormok, Crossroads, Freewind Post
				["0.64:0.23:0.63:0.36:0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76"] = 676, -- Everlook, Valormok, Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.64:0.23:0.63:0.36:0.56:0.53:0.44:0.69:0.42:0.79"] = 680, -- Everlook, Valormok, Crossroads, Camp Mojache, Cenarion Hold
				["0.64:0.23:0.63:0.36:0.56:0.53:0.53:0.61:0.57:0.64:0.58:0.70"] = 491, -- Everlook, Valormok, Crossroads, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.64:0.23:0.63:0.36:0.56:0.53:0.53:0.61:0.57:0.64"] = 430, -- Everlook, Valormok, Crossroads, Camp Taurajo, Brackenwall Village
				["0.64:0.23:0.63:0.36:0.56:0.53:0.53:0.61"] = 371, -- Everlook, Valormok, Crossroads, Camp Taurajo
				["0.64:0.23:0.63:0.36:0.56:0.53:0.44:0.69"] = 550, -- Everlook, Valormok, Crossroads, Camp Mojache
				["0.64:0.23:0.63:0.36:0.45:0.56:0.32:0.58"] = 544, -- Everlook, Valormok, Thunder Bluff, Shadowprey Village
				["0.64:0.23:0.63:0.36:0.45:0.56"] = 385, -- Everlook, Valormok, Thunder Bluff
				["0.64:0.23:0.63:0.36:0.56:0.53"] = 299, -- Everlook, Valormok, Crossroads
				["0.64:0.23:0.63:0.36:0.63:0.44:0.61:0.55"] = 342, -- Everlook, Valormok, Orgrimmar, Ratchet
				["0.64:0.23:0.63:0.44"] = 243, -- Everlook, Orgrimmar
				["0.64:0.23:0.63:0.36:0.55:0.42"] = 228, -- Everlook, Valormok, Splintertree Post
				["0.64:0.23:0.63:0.36:0.56:0.53:0.41:0.47"] = 448, -- Everlook, Valormok, Crossroads, Sun Rock Retreat
				["0.64:0.23:0.46:0.30:0.41:0.37"] = 296, -- Everlook, Bloodvenom Post, Zoram'gar Outpost
				["0.64:0.23:0.46:0.30:0.50:0.35"] = 229, -- Everlook, Bloodvenom Post, Emerald Sanctuary
				["0.64:0.23:0.63:0.36"] = 135, -- Everlook, Valormok
				["0.64:0.23:0.46:0.30"] = 195, -- Everlook, Bloodvenom Post
				["0.64:0.23:0.54:0.21"] = 135, -- Everlook, Moonglade
				["0.64:0.23:0.63:0.44:0.56:0.53:0.45:0.56"] = 457, -- Everlook, Orgrimmar, Crossroads, Thunder Bluff
				["0.64:0.23:0.63:0.44:0.61:0.55"] = 351, -- Everlook, Orgrimmar, Ratchet
				["0.64:0.23:0.63:0.44:0.55:0.42"] = 333, -- Everlook, Orgrimmar, Splintertree Post
				["0.64:0.23:0.63:0.44:0.61:0.55:0.61:0.80"] = 591, -- Everlook, Orgrimmar, Ratchet, Gadgetzan
				["0.64:0.23:0.63:0.44:0.56:0.53:0.44:0.69"] = 602, -- Everlook, Orgrimmar, Crossroads, Camp Mojache
				["0.64:0.23:0.63:0.36:0.55:0.42:0.50:0.35"] = 306, -- Everlook, Valormok, Splintertree Post, Emerald Sanctuary
				["0.64:0.23:0.63:0.44:0.61:0.55:0.61:0.80:0.50:0.76"] = 696, -- Everlook, Orgrimmar, Ratchet, Gadgetzan, Marshal's Refuge
				["0.64:0.23:0.46:0.30:0.41:0.37:0.41:0.47"] = 416, -- Everlook, Bloodvenom Post, Zoram'gar Outpost, Sun Rock Retreat
				["0.64:0.23:0.46:0.30:0.41:0.37:0.41:0.47:0.32:0.58"] = 558, -- Everlook, Bloodvenom Post, Zoram'gar Outpost, Sun Rock Retreat, Shadowprey Village

				-- Horde: Freewind Post (Thousand Needles)
				["0.55:0.73:0.44:0.69:0.42:0.79"] = 252, -- Freewind Post, Camp Mojache, Cenarion Hold
				["0.55:0.73:0.61:0.80:0.50:0.76"] = 194, -- Freewind Post, Gadgetzan, Marshal's Refuge
				["0.55:0.73:0.61:0.80"] = 93, -- Freewind Post, Gadgetzan
				["0.55:0.73:0.58:0.70"] = 69, -- Freewind Post, Mudsprocket
				["0.55:0.73:0.57:0.64"] = 96, -- Freewind Post, Brackenwall Village
				["0.55:0.73:0.53:0.61"] = 137, -- Freewind Post, Camp Taurajo
				["0.55:0.73:0.44:0.69"] = 123, -- Freewind Post, Camp Mojache
				["0.55:0.73:0.44:0.69:0.32:0.58"] = 323, -- Freewind Post, Camp Mojache, Shadowprey Village
				["0.55:0.73:0.45:0.56"] = 223, -- Freewind Post, Thunder Bluff
				["0.55:0.73:0.56:0.53"] = 192, -- Freewind Post, Crossroads
				["0.55:0.73:0.57:0.64:0.61:0.55"] = 184, -- Freewind Post, Brackenwall Village, Ratchet
				["0.55:0.73:0.57:0.64:0.61:0.55:0.63:0.44"] = 279, -- Freewind Post, Brackenwall Village, Ratchet, Orgrimmar
				["0.55:0.73:0.56:0.53:0.55:0.42"] = 354, -- Freewind Post, Crossroads, Splintertree Post
				["0.55:0.73:0.56:0.53:0.41:0.47"] = 342, -- Freewind Post, Crossroads, Sun Rock Retreat
				["0.55:0.73:0.56:0.53:0.41:0.37"] = 422, -- Freewind Post, Crossroads, Zoram'gar Outpost
				["0.55:0.73:0.56:0.53:0.46:0.30"] = 445, -- Freewind Post, Crossroads, Bloodvenom Post
				["0.55:0.73:0.56:0.53:0.55:0.42:0.50:0.35"] = 432, -- Freewind Post, Crossroads, Splintertree Post, Emerald Sanctuary
				["0.55:0.73:0.56:0.53:0.63:0.36"] = 355, -- Freewind Post, Crossroads, Valormok
				["0.55:0.73:0.56:0.53:0.63:0.36:0.64:0.23"] = 484, -- Freewind Post, Crossroads, Valormok, Everlook
				["0.55:0.73:0.56:0.53:0.46:0.30:0.54:0.21"] = 566, -- Freewind Post, Crossroads, Bloodvenom Post, Moonglade
				["0.55:0.73:0.56:0.53:0.63:0.44"] = 308, -- Freewind Post, Crossroads, Orgrimmar
				["0.55:0.73:0.45:0.56:0.32:0.58"] = 382, -- Freewind Post, Thunder Bluff, Shadowprey Village
				["0.55:0.73:0.56:0.53:0.61:0.55"] = 243, -- Freewind Post, Crossroads, Ratchet
				["0.55:0.73:0.61:0.80:0.63:0.44"] = 443, -- Freewind Post, Gadgetzan, Orgrimmar

				-- Horde: Gadgetzan (Tanaris)
				["0.61:0.80:0.42:0.79"] = 233, -- Gadgetzan, Cenarion Hold
				["0.61:0.80:0.50:0.76"] = 108, -- Gadgetzan, Marshal's Refuge
				["0.61:0.80:0.55:0.73"] = 87, -- Gadgetzan, Freewind Post
				["0.61:0.80:0.55:0.73:0.58:0.70"] = 155, -- Gadgetzan, Freewind Post, Mudsprocket
				["0.61:0.80:0.57:0.64"] = 194, -- Gadgetzan, Brackenwall Village
				["0.61:0.80:0.55:0.73:0.53:0.61"] = 223, -- Gadgetzan, Freewind Post, Camp Taurajo
				["0.61:0.80:0.44:0.69"] = 199, -- Gadgetzan, Camp Mojache
				["0.61:0.80:0.44:0.69:0.32:0.58"] = 399, -- Gadgetzan, Camp Mojache, Shadowprey Village
				["0.61:0.80:0.45:0.56"] = 304, -- Gadgetzan, Thunder Bluff
				["0.61:0.80:0.56:0.53"] = 300, -- Gadgetzan, Crossroads
				["0.61:0.80:0.61:0.55"] = 243, -- Gadgetzan, Ratchet
				["0.61:0.80:0.63:0.44"] = 350, -- Gadgetzan, Orgrimmar
				["0.61:0.80:0.61:0.55:0.63:0.44:0.55:0.42"] = 429, -- Gadgetzan, Ratchet, Orgrimmar, Splintertree Post
				["0.61:0.80:0.55:0.73:0.56:0.53:0.41:0.47"] = 427, -- Gadgetzan, Freewind Post, Crossroads, Sun Rock Retreat
				["0.61:0.80:0.55:0.73:0.56:0.53:0.41:0.37"] = 508, -- Gadgetzan, Freewind Post, Crossroads, Zoram'gar Outpost
				["0.61:0.80:0.61:0.55:0.63:0.44:0.55:0.42:0.50:0.35"] = 507, -- Gadgetzan, Ratchet, Orgrimmar, Splintertree Post, Emerald Sanctuary
				["0.61:0.80:0.55:0.73:0.56:0.53:0.46:0.30"] = 531, -- Gadgetzan, Freewind Post, Crossroads, Bloodvenom Post
				["0.61:0.80:0.61:0.55:0.63:0.44:0.63:0.36"] = 434, -- Gadgetzan, Ratchet, Orgrimmar, Valormok
				["0.61:0.80:0.61:0.55:0.63:0.44:0.63:0.36:0.64:0.23"] = 564, -- Gadgetzan, Ratchet, Orgrimmar, Valormok, Everlook
				["0.61:0.80:0.55:0.73:0.56:0.53:0.46:0.30:0.54:0.21"] = 652, -- Gadgetzan, Freewind Post, Crossroads, Bloodvenom Post, Moonglade
				["0.61:0.80:0.45:0.56:0.32:0.58"] = 463, -- Gadgetzan, Thunder Bluff, Shadowprey Village
				["0.61:0.80:0.56:0.53:0.53:0.61"] = 374, -- Gadgetzan, Crossroads, Camp Taurajo
				["0.61:0.80:0.61:0.55:0.63:0.44:0.64:0.23"] = 580, -- Gadgetzan, Ratchet, Orgrimmar, Everlook
				["0.61:0.80:0.57:0.64:0.58:0.70"] = 255, -- Gadgetzan, Brackenwall Village, Mudsprocket
				["0.61:0.80:0.55:0.73:0.56:0.53:0.63:0.36"] = 441, -- Gadgetzan, Freewind Post, Crossroads, Valormok

				-- Horde: Marshal's Refuge (Un'Goro Crater)
				["0.50:0.76:0.42:0.79"] = 100, -- Marshal's Refuge, Cenarion Hold
				["0.50:0.76:0.61:0.80"] = 113, -- Marshal's Refuge, Gadgetzan
				["0.50:0.76:0.61:0.80:0.55:0.73"] = 200, -- Marshal's Refuge, Gadgetzan, Freewind Post
				["0.50:0.76:0.61:0.80:0.55:0.73:0.58:0.70"] = 268, -- Marshal's Refuge, Gadgetzan, Freewind Post, Mudsprocket
				["0.50:0.76:0.61:0.80:0.55:0.73:0.57:0.64"] = 294, -- Marshal's Refuge, Gadgetzan, Freewind Post, Brackenwall Village
				["0.50:0.76:0.61:0.80:0.55:0.73:0.53:0.61"] = 336, -- Marshal's Refuge, Gadgetzan, Freewind Post, Camp Taurajo
				["0.50:0.76:0.42:0.79:0.44:0.69"] = 224, -- Marshal's Refuge, Cenarion Hold, Camp Mojache
				["0.50:0.76:0.42:0.79:0.44:0.69:0.32:0.58"] = 424, -- Marshal's Refuge, Cenarion Hold, Camp Mojache, Shadowprey Village
				["0.50:0.76:0.61:0.80:0.45:0.56"] = 416, -- Marshal's Refuge, Gadgetzan, Thunder Bluff
				["0.50:0.76:0.61:0.80:0.55:0.73:0.56:0.53"] = 392, -- Marshal's Refuge, Gadgetzan, Freewind Post, Crossroads
				["0.50:0.76:0.61:0.80:0.61:0.55"] = 354, -- Marshal's Refuge, Gadgetzan, Ratchet
				["0.50:0.76:0.61:0.80:0.61:0.55:0.63:0.44"] = 450, -- Marshal's Refuge, Gadgetzan, Ratchet, Orgrimmar
				["0.50:0.76:0.61:0.80:0.61:0.55:0.63:0.44:0.55:0.42"] = 540, -- Marshal's Refuge, Gadgetzan, Ratchet, Orgrimmar, Splintertree Post
				["0.50:0.76:0.61:0.80:0.55:0.73:0.56:0.53:0.41:0.47"] = 540, -- Marshal's Refuge, Gadgetzan, Freewind Post, Crossroads, Sun Rock Retreat
				["0.50:0.76:0.61:0.80:0.55:0.73:0.56:0.53:0.41:0.37"] = 621, -- Marshal's Refuge, Gadgetzan, Freewind Post, Crossroads, Zoram'gar Outpost
				["0.50:0.76:0.61:0.80:0.61:0.55:0.63:0.44:0.55:0.42:0.50:0.35"] = 618, -- Marshal's Refuge, Gadgetzan, Ratchet, Orgrimmar, Splintertree Post, Emerald Sanctuary
				["0.50:0.76:0.61:0.80:0.55:0.73:0.56:0.53:0.46:0.30"] = 645, -- Marshal's Refuge, Gadgetzan, Freewind Post, Crossroads, Bloodvenom Post
				["0.50:0.76:0.61:0.80:0.61:0.55:0.63:0.44:0.63:0.36"] = 546, -- Marshal's Refuge, Gadgetzan, Ratchet, Orgrimmar, Valormok
				["0.50:0.76:0.61:0.80:0.61:0.55:0.63:0.44:0.63:0.36:0.64:0.23"] = 675, -- Marshal's Refuge, Gadgetzan, Ratchet, Orgrimmar, Valormok, Everlook
				["0.50:0.76:0.61:0.80:0.55:0.73:0.56:0.53:0.46:0.30:0.54:0.21"] = 766, -- Marshal's Refuge, Gadgetzan, Freewind Post, Crossroads, Bloodvenom Post, Moonglade
				["0.50:0.76:0.61:0.80:0.44:0.69"] = 312, -- Marshal's Refuge, Gadgetzan, Camp Mojache
				["0.50:0.76:0.61:0.80:0.61:0.55:0.63:0.44:0.64:0.23"] = 691, -- Marshal's Refuge, Gadgetzan, Ratchet, Orgrimmar, Everlook
				["0.50:0.76:0.61:0.80:0.44:0.69:0.32:0.58"] = 512, -- Marshal's Refuge, Gadgetzan, Camp Mojache, Shadowprey Village
				["0.50:0.76:0.61:0.80:0.57:0.64:0.53:0.61"] = 354, -- Marshal's Refuge, Gadgetzan, Brackenwall Village, Camp Taurajo

				-- Horde: Moonglade (Moonglade)
				["0.54:0.21:0.46:0.30:0.56:0.53:0.44:0.69:0.42:0.79"] = 734, -- Moonglade, Bloodvenom Post, Crossroads, Camp Mojache, Cenarion Hold
				["0.54:0.21:0.46:0.30:0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76"] = 730, -- Moonglade, Bloodvenom Post, Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.54:0.21:0.46:0.30:0.56:0.53:0.55:0.73"] = 537, -- Moonglade, Bloodvenom Post, Crossroads, Freewind Post
				["0.54:0.21:0.46:0.30:0.56:0.53:0.53:0.61:0.57:0.64:0.58:0.70"] = 545, -- Moonglade, Bloodvenom Post, Crossroads, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.54:0.21:0.46:0.30:0.56:0.53:0.55:0.73:0.61:0.80"] = 629, -- Moonglade, Bloodvenom Post, Crossroads, Freewind Post, Gadgetzan
				["0.54:0.21:0.46:0.30:0.56:0.53:0.53:0.61:0.57:0.64"] = 484, -- Moonglade, Bloodvenom Post, Crossroads, Camp Taurajo, Brackenwall Village
				["0.54:0.21:0.46:0.30:0.56:0.53:0.53:0.61"] = 426, -- Moonglade, Bloodvenom Post, Crossroads, Camp Taurajo
				["0.54:0.21:0.46:0.30:0.56:0.53:0.44:0.69"] = 604, -- Moonglade, Bloodvenom Post, Crossroads, Camp Mojache
				["0.54:0.21:0.46:0.30:0.41:0.37:0.41:0.47:0.32:0.58"] = 515, -- Moonglade, Bloodvenom Post, Zoram'gar Outpost, Sun Rock Retreat, Shadowprey Village
				["0.54:0.21:0.46:0.30:0.56:0.53:0.45:0.56"] = 459, -- Moonglade, Bloodvenom Post, Crossroads, Thunder Bluff
				["0.54:0.21:0.46:0.30:0.56:0.53"] = 353, -- Moonglade, Bloodvenom Post, Crossroads
				["0.54:0.21:0.46:0.30:0.56:0.53:0.61:0.55"] = 404, -- Moonglade, Bloodvenom Post, Crossroads, Ratchet
				["0.54:0.21:0.64:0.23:0.63:0.36:0.63:0.44"] = 377, -- Moonglade, Everlook, Valormok, Orgrimmar
				["0.54:0.21:0.46:0.30:0.50:0.35:0.55:0.42"] = 269, -- Moonglade, Bloodvenom Post, Emerald Sanctuary, Splintertree Post
				["0.54:0.21:0.46:0.30:0.41:0.37:0.41:0.47"] = 373, -- Moonglade, Bloodvenom Post, Zoram'gar Outpost, Sun Rock Retreat
				["0.54:0.21:0.46:0.30:0.41:0.37"] = 253, -- Moonglade, Bloodvenom Post, Zoram'gar Outpost
				["0.54:0.21:0.46:0.30:0.50:0.35"] = 186, -- Moonglade, Bloodvenom Post, Emerald Sanctuary
				["0.54:0.21:0.64:0.23:0.63:0.36"] = 276, -- Moonglade, Everlook, Valormok
				["0.54:0.21:0.64:0.23"] = 142, -- Moonglade, Everlook
				["0.54:0.21:0.46:0.30"] = 157, -- Moonglade, Bloodvenom Post
				["0.54:0.21:0.46:0.30:0.50:0.35:0.55:0.42:0.63:0.44"] = 358, -- Moonglade, Bloodvenom Post, Emerald Sanctuary, Splintertree Post, Orgrimmar
				["0.54:0.21:0.64:0.23:0.63:0.44"] = 384, -- Moonglade, Everlook, Orgrimmar
				["0.54:0.21:0.46:0.30:0.63:0.44"] = 371, -- Moonglade, Bloodvenom Post, Orgrimmar
				["0.54:0.21:0.64:0.23:0.63:0.44:0.61:0.55:0.57:0.64"] = 592, -- Moonglade, Everlook, Orgrimmar, Ratchet, Brackenwall Village
				["0.54:0.21:0.46:0.30:0.63:0.36"] = 339, -- Moonglade, Bloodvenom Post, Valormok
				["0.54:0.21:0.64:0.23:0.63:0.36:0.55:0.42"] = 370, -- Moonglade, Everlook, Valormok, Splintertree Post
				["0.54:0.21:0.64:0.23:0.63:0.36:0.56:0.53:0.44:0.69"] = 692, -- Moonglade, Everlook, Valormok, Crossroads, Camp Mojache
				["0.54:0.21:0.64:0.23:0.63:0.44:0.61:0.55:0.61:0.80:0.50:0.76:0.42:0.79"] = 933, -- Moonglade, Everlook, Orgrimmar, Ratchet, Gadgetzan, Marshal's Refuge, Cenarion Hold
				["0.54:0.21:0.46:0.30:0.56:0.53:0.45:0.56:0.32:0.58"] = 618, -- Moonglade, Bloodvenom Post, Crossroads, Thunder Bluff, Shadowprey Village
				["0.54:0.21:0.64:0.23:0.63:0.36:0.55:0.42:0.50:0.35"] = 448, -- Moonglade, Everlook, Valormok, Splintertree Post, Emerald Sanctuary
				["0.54:0.21:0.46:0.30:0.41:0.37:0.55:0.42"] = 426, -- Moonglade, Bloodvenom Post, Zoram'gar Outpost, Splintertree Post

				-- Horde: Mudsprocket (Dustwallow Marsh)
				["0.58:0.70:0.55:0.73:0.44:0.69:0.42:0.79"] = 324, -- Mudsprocket, Freewind Post, Camp Mojache, Cenarion Hold
				["0.58:0.70:0.55:0.73:0.61:0.80:0.50:0.76"] = 265, -- Mudsprocket, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.58:0.70:0.55:0.73"] = 71, -- Mudsprocket, Freewind Post
				["0.58:0.70:0.55:0.73:0.61:0.80"] = 164, -- Mudsprocket, Freewind Post, Gadgetzan
				["0.58:0.70:0.55:0.73:0.44:0.69"] = 194, -- Mudsprocket, Freewind Post, Camp Mojache
				["0.58:0.70:0.57:0.64"] = 63, -- Mudsprocket, Brackenwall Village
				["0.58:0.70:0.57:0.64:0.53:0.61"] = 111, -- Mudsprocket, Brackenwall Village, Camp Taurajo
				["0.58:0.70:0.57:0.64:0.53:0.61:0.45:0.56:0.32:0.58"] = 383, -- Mudsprocket, Brackenwall Village, Camp Taurajo, Thunder Bluff, Shadowprey Village
				["0.58:0.70:0.57:0.64:0.53:0.61:0.45:0.56"] = 224, -- Mudsprocket, Brackenwall Village, Camp Taurajo, Thunder Bluff
				["0.58:0.70:0.57:0.64:0.53:0.61:0.56:0.53"] = 189, -- Mudsprocket, Brackenwall Village, Camp Taurajo, Crossroads
				["0.58:0.70:0.57:0.64:0.61:0.55"] = 150, -- Mudsprocket, Brackenwall Village, Ratchet
				["0.58:0.70:0.57:0.64:0.61:0.55:0.63:0.44"] = 245, -- Mudsprocket, Brackenwall Village, Ratchet, Orgrimmar
				["0.58:0.70:0.57:0.64:0.61:0.55:0.63:0.44:0.55:0.42"] = 334, -- Mudsprocket, Brackenwall Village, Ratchet, Orgrimmar, Splintertree Post
				["0.58:0.70:0.57:0.64:0.53:0.61:0.56:0.53:0.41:0.47"] = 338, -- Mudsprocket, Brackenwall Village, Camp Taurajo, Crossroads, Sun Rock Retreat
				["0.58:0.70:0.57:0.64:0.53:0.61:0.56:0.53:0.41:0.37"] = 419, -- Mudsprocket, Brackenwall Village, Camp Taurajo, Crossroads, Zoram'gar Outpost
				["0.58:0.70:0.57:0.64:0.61:0.55:0.63:0.44:0.55:0.42:0.50:0.35"] = 412, -- Mudsprocket, Brackenwall Village, Ratchet, Orgrimmar, Splintertree Post, Emerald Sanctuary
				["0.58:0.70:0.57:0.64:0.61:0.55:0.63:0.44:0.63:0.36"] = 340, -- Mudsprocket, Brackenwall Village, Ratchet, Orgrimmar, Valormok
				["0.58:0.70:0.57:0.64:0.53:0.61:0.56:0.53:0.46:0.30"] = 442, -- Mudsprocket, Brackenwall Village, Camp Taurajo, Crossroads, Bloodvenom Post
				["0.58:0.70:0.57:0.64:0.53:0.61:0.56:0.53:0.46:0.30:0.54:0.21"] = 563, -- Mudsprocket, Brackenwall Village, Camp Taurajo, Crossroads, Bloodvenom Post, Moonglade
				["0.58:0.70:0.57:0.64:0.61:0.55:0.63:0.44:0.63:0.36:0.64:0.23"] = 469, -- Mudsprocket, Brackenwall Village, Ratchet, Orgrimmar, Valormok, Everlook
				["0.58:0.70:0.55:0.73:0.45:0.56"] = 294, -- Mudsprocket, Freewind Post, Thunder Bluff
				["0.58:0.70:0.55:0.73:0.56:0.53:0.61:0.55"] = 314, -- Mudsprocket, Freewind Post, Crossroads, Ratchet
				["0.58:0.70:0.55:0.73:0.53:0.61"] = 209, -- Mudsprocket, Freewind Post, Camp Taurajo
				["0.58:0.70:0.57:0.64:0.63:0.44"] = 279, -- Mudsprocket, Brackenwall Village, Orgrimmar
				["0.58:0.70:0.55:0.73:0.56:0.53:0.63:0.44"] = 379, -- Mudsprocket, Freewind Post, Crossroads, Orgrimmar

				-- Horde: Orgrimmar (Durotar)
				["0.63:0.44:0.61:0.80"] = 417, -- Orgrimmar, Gadgetzan
				["0.63:0.44:0.56:0.53:0.44:0.69:0.42:0.79"] = 492, -- Orgrimmar, Crossroads, Camp Mojache, Cenarion Hold
				["0.63:0.44:0.61:0.55:0.61:0.80:0.50:0.76"] = 454, -- Orgrimmar, Ratchet, Gadgetzan, Marshal's Refuge
				["0.63:0.44:0.56:0.53:0.55:0.73"] = 292, -- Orgrimmar, Crossroads, Freewind Post
				["0.63:0.44:0.61:0.55:0.57:0.64:0.58:0.70"] = 268, -- Orgrimmar, Ratchet, Brackenwall Village, Mudsprocket
				["0.63:0.44:0.57:0.64"] = 229, -- Orgrimmar, Brackenwall Village
				["0.63:0.44:0.56:0.53:0.53:0.61"] = 181, -- Orgrimmar, Crossroads, Camp Taurajo
				["0.63:0.44:0.56:0.53:0.44:0.69"] = 361, -- Orgrimmar, Crossroads, Camp Mojache
				["0.63:0.44:0.56:0.53:0.45:0.56:0.32:0.58"] = 373, -- Orgrimmar, Crossroads, Thunder Bluff, Shadowprey Village
				["0.63:0.44:0.45:0.56"] = 224, -- Orgrimmar, Thunder Bluff (David Galindo suggested 233)
				["0.63:0.44:0.56:0.53"] = 110, -- Orgrimmar, Crossroads
				["0.63:0.44:0.61:0.55"] = 108, -- Orgrimmar, Ratchet
				["0.63:0.44:0.63:0.36"] = 95, -- Orgrimmar, Valormok
				["0.63:0.44:0.55:0.42"] = 90, -- Orgrimmar, Splintertree Post
				["0.63:0.44:0.56:0.53:0.41:0.47"] = 258, -- Orgrimmar, Crossroads, Sun Rock Retreat
				["0.63:0.44:0.55:0.42:0.41:0.37"] = 249, -- Orgrimmar, Splintertree Post, Zoram'gar Outpost
				["0.63:0.44:0.55:0.42:0.50:0.35"] = 168, -- Orgrimmar, Splintertree Post, Emerald Sanctuary
				["0.63:0.44:0.46:0.30"] = 252, -- Orgrimmar, Bloodvenom Post
				["0.63:0.44:0.63:0.36:0.64:0.23:0.54:0.21"] = 358, -- Orgrimmar, Valormok, Everlook, Moonglade
				["0.63:0.44:0.64:0.23"] = 240, -- Orgrimmar, Everlook
				["0.63:0.44:0.55:0.42:0.50:0.35:0.46:0.30:0.54:0.21"] = 371, -- Orgrimmar, Splintertree Post, Emerald Sanctuary, Bloodvenom Post, Moonglade
				["0.63:0.44:0.56:0.53:0.41:0.37"] = 339, -- Orgrimmar, Crossroads, Zoram'gar Outpost
				["0.63:0.44:0.64:0.23:0.54:0.21"] = 374, -- Orgrimmar, Everlook, Moonglade
				["0.63:0.44:0.61:0.55:0.61:0.80:0.50:0.76:0.42:0.79"] = 549, -- Orgrimmar, Ratchet, Gadgetzan, Marshal's Refuge, Cenarion Hold
				["0.63:0.44:0.57:0.64:0.58:0.70"] = 289, -- Orgrimmar, Brackenwall Village, Mudsprocket
				["0.63:0.44:0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76:0.42:0.79"] = 581, -- Orgrimmar, Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge, Cenarion Hold
				["0.63:0.44:0.61:0.80:0.42:0.79"] = 650, -- Orgrimmar, Gadgetzan, Cenarion Hold
				["0.63:0.44:0.45:0.56:0.53:0.61"] = 312, -- Orgrimmar, Thunder Bluff, Camp Taurajo
				["0.63:0.44:0.45:0.56:0.55:0.73"] = 429, -- Orgrimmar, Thunder Bluff, Freewind Post
				["0.63:0.44:0.56:0.53:0.55:0.73:0.58:0.70"] = 361, -- Orgrimmar, Crossroads, Freewind Post, Mudsprocket
				["0.63:0.44:0.46:0.30:0.50:0.35"] = 278, -- Orgrimmar, Bloodvenom Post, Emerald Sanctuary
				["0.63:0.44:0.61:0.55:0.57:0.64:0.55:0.73:0.44:0.69:0.32:0.58"] = 633, -- Orgrimmar, Ratchet, Brackenwall Village, Freewind Post, Camp Mojache, Shadowprey Village
				["0.63:0.44:0.56:0.53:0.41:0.47:0.32:0.58"] = 400, -- Orgrimmar, Crossroads, Sun Rock Retreat, Shadowprey Village

				-- Horde: Ratchet (The Barrens)
				["0.61:0.55:0.61:0.80:0.50:0.76:0.42:0.79"] = 443, -- Ratchet, Gadgetzan, Marshal's Refuge, Cenarion Hold
				["0.61:0.55:0.61:0.80:0.50:0.76"] = 347, -- Ratchet, Gadgetzan, Marshal's Refuge
				["0.61:0.55:0.57:0.64:0.55:0.73"] = 204, -- Ratchet, Brackenwall Village, Freewind Post
				["0.61:0.55:0.61:0.80"] = 241, -- Ratchet, Gadgetzan
				["0.61:0.55:0.56:0.53:0.44:0.69"] = 320, -- Ratchet, Crossroads, Camp Mojache
				["0.61:0.55:0.57:0.64:0.58:0.70"] = 161, -- Ratchet, Brackenwall Village, Mudsprocket
				["0.61:0.55:0.57:0.64"] = 101, -- Ratchet, Brackenwall Village
				["0.61:0.55:0.56:0.53:0.53:0.61"] = 141, -- Ratchet, Crossroads, Camp Taurajo
				["0.61:0.55:0.56:0.53:0.45:0.56:0.32:0.58"] = 334, -- Ratchet, Crossroads, Thunder Bluff, Shadowprey Village
				["0.61:0.55:0.56:0.53:0.45:0.56"] = 175, -- Ratchet, Crossroads, Thunder Bluff (Elena Liakhovskaia reported 70)
				["0.61:0.55:0.56:0.53"] = 69, -- Ratchet, Crossroads
				["0.61:0.55:0.56:0.53:0.41:0.47"] = 218, -- Ratchet, Crossroads, Sun Rock Retreat
				["0.61:0.55:0.63:0.44:0.55:0.42"] = 190, -- Ratchet, Orgrimmar, Splintertree Post -- CHANGE from 101 to 191 (Basse, Nate Sander, Lori Payne, Video Games, Josh Romey, Nelson Egger II)
				["0.61:0.55:0.63:0.44"] = 101, -- Ratchet, Orgrimmar
				["0.61:0.55:0.63:0.44:0.63:0.36"] = 196, -- Ratchet, Orgrimmar, Valormok
				["0.61:0.55:0.63:0.44:0.55:0.42:0.50:0.35"] = 269, -- Ratchet, Orgrimmar, Splintertree Post, Emerald Sanctuary
				["0.61:0.55:0.56:0.53:0.41:0.37"] = 299, -- Ratchet, Crossroads, Zoram'gar Outpost
				["0.61:0.55:0.56:0.53:0.46:0.30"] = 321, -- Ratchet, Crossroads, Bloodvenom Post
				["0.61:0.55:0.63:0.44:0.63:0.36:0.64:0.23:0.54:0.21"] = 458, -- Ratchet, Orgrimmar, Valormok, Everlook, Moonglade
				["0.61:0.55:0.63:0.44:0.63:0.36:0.64:0.23"] = 325, -- Ratchet, Orgrimmar, Valormok, Everlook
				["0.61:0.55:0.56:0.53:0.55:0.73"] = 253, -- Ratchet, Crossroads, Freewind Post
				["0.61:0.55:0.63:0.44:0.64:0.23"] = 341, -- Ratchet, Orgrimmar, Everlook
				["0.61:0.55:0.56:0.53:0.46:0.30:0.54:0.21"] = 443, -- Ratchet, Crossroads, Bloodvenom Post, Moonglade
				["0.61:0.55:0.56:0.53:0.55:0.73:0.58:0.70"] = 322, -- Ratchet, Crossroads, Freewind Post, Mudsprocket
				["0.61:0.55:0.63:0.44:0.55:0.42:0.41:0.37"] = 349, -- Ratchet, Orgrimmar, Splintertree Post, Zoram'gar Outpost

				-- Horde: Shadowprey Village (Desolace)
				["0.32:0.58:0.44:0.69:0.42:0.79"] = 326, -- Shadowprey Village, Camp Mojache, Cenarion Hold
				["0.32:0.58:0.44:0.69:0.42:0.79:0.50:0.76"] = 417, -- Shadowprey Village, Camp Mojache, Cenarion Hold, Marshal's Refuge
				["0.32:0.58:0.44:0.69:0.55:0.73:0.61:0.80"] = 395, -- Shadowprey Village, Camp Mojache, Freewind Post, Gadgetzan
				["0.32:0.58:0.44:0.69:0.55:0.73"] = 303, -- Shadowprey Village, Camp Mojache, Freewind Post
				["0.32:0.58:0.44:0.69"] = 196, -- Shadowprey Village, Camp Mojache
				["0.32:0.58:0.44:0.69:0.55:0.73:0.58:0.70"] = 372, -- Shadowprey Village, Camp Mojache, Freewind Post, Mudsprocket
				["0.32:0.58:0.45:0.56:0.53:0.61:0.57:0.64"] = 323, -- Shadowprey Village, Thunder Bluff, Camp Taurajo, Brackenwall Village
				["0.32:0.58:0.45:0.56:0.53:0.61"] = 265, -- Shadowprey Village, Thunder Bluff, Camp Taurajo
				["0.32:0.58:0.45:0.56:0.56:0.53:0.61:0.55"] = 332, -- Shadowprey Village, Thunder Bluff, Crossroads, Ratchet
				["0.32:0.58:0.45:0.56:0.56:0.53"] = 281, -- Shadowprey Village, Thunder Bluff, Crossroads
				["0.32:0.58:0.45:0.56"] = 178, -- Shadowprey Village, Thunder Bluff
				["0.32:0.58:0.41:0.47"] = 199, -- Shadowprey Village, Sun Rock Retreat
				["0.32:0.58:0.45:0.56:0.56:0.53:0.55:0.42"] = 443, -- Shadowprey Village, Thunder Bluff, Crossroads, Splintertree Post
				["0.32:0.58:0.45:0.56:0.63:0.44"] = 386, -- Shadowprey Village, Thunder Bluff, Orgrimmar
				["0.32:0.58:0.45:0.56:0.63:0.36"] = 429, -- Shadowprey Village, Thunder Bluff, Valormok
				["0.32:0.58:0.41:0.47:0.41:0.37:0.50:0.35"] = 441, -- Shadowprey Village, Sun Rock Retreat, Zoram'gar Outpost, Emerald Sanctuary
				["0.32:0.58:0.41:0.47:0.41:0.37"] = 320, -- Shadowprey Village, Sun Rock Retreat, Zoram'gar Outpost
				["0.32:0.58:0.41:0.47:0.41:0.37:0.46:0.30"] = 457, -- Shadowprey Village, Sun Rock Retreat, Zoram'gar Outpost, Bloodvenom Post
				["0.32:0.58:0.41:0.47:0.41:0.37:0.46:0.30:0.54:0.21"] = 581, -- Shadowprey Village, Sun Rock Retreat, Zoram'gar Outpost, Bloodvenom Post, Moonglade
				["0.32:0.58:0.45:0.56:0.63:0.36:0.64:0.23"] = 558, -- Shadowprey Village, Thunder Bluff, Valormok, Everlook
				["0.32:0.58:0.45:0.56:0.55:0.73"] = 382, -- Shadowprey Village, Thunder Bluff, Freewind Post
				["0.32:0.58:0.45:0.56:0.53:0.61:0.57:0.64:0.58:0.70"] = 384, -- Shadowprey Village, Thunder Bluff, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.32:0.58:0.45:0.56:0.61:0.80"] = 469, -- Shadowprey Village, Thunder Bluff, Gadgetzan
				["0.32:0.58:0.44:0.69:0.55:0.73:0.61:0.80:0.50:0.76"] = 497, -- Shadowprey Village, Camp Mojache, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.32:0.58:0.41:0.47:0.56:0.53:0.63:0.44"] = 465, -- Shadowprey Village, Sun Rock Retreat, Crossroads, Orgrimmar
				["0.32:0.58:0.45:0.56:0.63:0.44:0.64:0.23"] = 626, -- Shadowprey Village, Thunder Bluff, Orgrimmar, Everlook
				["0.32:0.58:0.45:0.56:0.63:0.36:0.64:0.23:0.54:0.21"] = 691, -- Shadowprey Village, Thunder Bluff, Valormok, Everlook, Moonglade
				["0.32:0.58:0.41:0.47:0.56:0.53:0.55:0.73"] = 533, -- Shadowprey Village, Sun Rock Retreat, Crossroads, Freewind Post
				["0.32:0.58:0.41:0.47:0.56:0.53"] = 348, -- Shadowprey Village, Sun Rock Retreat, Crossroads
				["0.32:0.58:0.45:0.56:0.56:0.53:0.55:0.42:0.50:0.35"] = 521, -- Shadowprey Village, Thunder Bluff, Crossroads, Splintertree Post, Emerald Sanctuary

				-- Horde: Splintertree Post (Ashenvale)
				["0.55:0.42:0.56:0.53:0.44:0.69:0.42:0.79"] = 541, -- Splintertree Post, Crossroads, Camp Mojache, Cenarion Hold
				["0.55:0.42:0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76"] = 538, -- Splintertree Post, Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.55:0.42:0.56:0.53:0.55:0.73"] = 345, -- Splintertree Post, Crossroads, Freewind Post
				["0.55:0.42:0.56:0.53:0.53:0.61:0.57:0.64:0.58:0.70"] = 354, -- Splintertree Post, Crossroads, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.55:0.42:0.56:0.53:0.55:0.73:0.61:0.80"] = 436, -- Splintertree Post, Crossroads, Freewind Post, Gadgetzan
				["0.55:0.42:0.56:0.53:0.53:0.61:0.57:0.64"] = 292, -- Splintertree Post, Crossroads, Camp Taurajo, Brackenwall Village
				["0.55:0.42:0.56:0.53:0.53:0.61"] = 234, -- Splintertree Post, Crossroads, Camp Taurajo
				["0.55:0.42:0.56:0.53:0.44:0.69"] = 412, -- Splintertree Post, Crossroads, Camp Mojache
				["0.55:0.42:0.56:0.53:0.45:0.56:0.32:0.58"] = 426, -- Splintertree Post, Crossroads, Thunder Bluff, Shadowprey Village
				["0.55:0.42:0.56:0.53:0.45:0.56"] = 267, -- Splintertree Post, Crossroads, Thunder Bluff
				["0.55:0.42:0.56:0.53"] = 160, -- Splintertree Post, Crossroads
				["0.55:0.42:0.63:0.44:0.61:0.55"] = 203, -- Splintertree Post, Orgrimmar, Ratchet
				["0.55:0.42:0.63:0.44"] = 96, -- Splintertree Post, Orgrimmar
				["0.55:0.42:0.63:0.36"] = 92, -- Splintertree Post, Valormok
				["0.55:0.42:0.50:0.35"] = 85, -- Splintertree Post, Emerald Sanctuary
				["0.55:0.42:0.41:0.37"] = 166, -- Splintertree Post, Zoram'gar Outpost
				["0.55:0.42:0.41:0.37:0.41:0.47"] = 287, -- Splintertree Post, Zoram'gar Outpost, Sun Rock Retreat
				["0.55:0.42:0.50:0.35:0.46:0.30"] = 163, -- Splintertree Post, Emerald Sanctuary, Bloodvenom Post
				["0.55:0.42:0.50:0.35:0.46:0.30:0.54:0.21"] = 287, -- Splintertree Post, Emerald Sanctuary, Bloodvenom Post, Moonglade
				["0.55:0.42:0.63:0.36:0.64:0.23"] = 221, -- Splintertree Post, Valormok, Everlook
				["0.55:0.42:0.56:0.53:0.61:0.55"] = 212, -- Splintertree Post, Crossroads, Ratchet
				["0.55:0.42:0.56:0.53:0.41:0.47"] = 310, -- Splintertree Post, Crossroads, Sun Rock Retreat
				["0.55:0.42:0.63:0.44:0.46:0.30"] = 348, -- Splintertree Post, Orgrimmar, Bloodvenom Post
				["0.55:0.42:0.41:0.37:0.46:0.30"] = 303, -- Splintertree Post, Zoram'gar Outpost, Bloodvenom Post
				["0.55:0.42:0.63:0.36:0.64:0.23:0.54:0.21"] = 354, -- Splintertree Post, Valormok, Everlook, Moonglade
				["0.55:0.42:0.63:0.44:0.64:0.23"] = 336, -- Splintertree Post, Orgrimmar, Everlook

				-- Horde: Sun Rock Retreat (Stonetalon Mountains)
				["0.41:0.47:0.56:0.53:0.55:0.73:0.61:0.80"] = 426, -- Sun Rock Retreat, Crossroads, Freewind Post, Gadgetzan
				["0.41:0.47:0.32:0.58:0.44:0.69:0.42:0.79"] = 469, -- Sun Rock Retreat, Shadowprey Village, Camp Mojache, Cenarion Hold
				["0.41:0.47:0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76"] = 527, -- Sun Rock Retreat, Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.41:0.47:0.56:0.53:0.55:0.73"] = 333, -- Sun Rock Retreat, Crossroads, Freewind Post
				["0.41:0.47:0.56:0.53:0.53:0.61:0.57:0.64:0.58:0.70"] = 342, -- Sun Rock Retreat, Crossroads, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.41:0.47:0.56:0.53:0.53:0.61:0.57:0.64"] = 281, -- Sun Rock Retreat, Crossroads, Camp Taurajo, Brackenwall Village
				["0.41:0.47:0.56:0.53:0.53:0.61"] = 223, -- Sun Rock Retreat, Crossroads, Camp Taurajo
				["0.41:0.47:0.32:0.58:0.44:0.69"] = 339, -- Sun Rock Retreat, Shadowprey Village, Camp Mojache
				["0.41:0.47:0.32:0.58"] = 143, -- Sun Rock Retreat, Shadowprey Village
				["0.41:0.47:0.45:0.56"] = 175, -- Sun Rock Retreat, Thunder Bluff
				["0.41:0.47:0.56:0.53"] = 150, -- Sun Rock Retreat, Crossroads
				["0.41:0.47:0.56:0.53:0.61:0.55"] = 201, -- Sun Rock Retreat, Crossroads, Ratchet (was 200, changed to 150 by William Black, changed back to 201 by Oliver Snith)
				["0.41:0.47:0.56:0.53:0.63:0.44"] = 266, -- Sun Rock Retreat, Crossroads, Orgrimmar
				["0.41:0.47:0.41:0.37:0.55:0.42"] = 294, -- Sun Rock Retreat, Zoram'gar Outpost, Splintertree Post
				["0.41:0.47:0.56:0.53:0.63:0.36"] = 313, -- Sun Rock Retreat, Crossroads, Valormok
				["0.41:0.47:0.56:0.53:0.63:0.36:0.64:0.23"] = 442, -- Sun Rock Retreat, Crossroads, Valormok, Everlook
				["0.41:0.47:0.41:0.37:0.50:0.35"] = 242, -- Sun Rock Retreat, Zoram'gar Outpost, Emerald Sanctuary
				["0.41:0.47:0.41:0.37:0.46:0.30"] = 257, -- Sun Rock Retreat, Zoram'gar Outpost, Bloodvenom Post
				["0.41:0.47:0.41:0.37:0.46:0.30:0.54:0.21"] = 382, -- Sun Rock Retreat, Zoram'gar Outpost, Bloodvenom Post, Moonglade
				["0.41:0.47:0.41:0.37"] = 121, -- Sun Rock Retreat, Zoram'gar Outpost
				["0.41:0.47:0.56:0.53:0.55:0.42"] = 312, -- Sun Rock Retreat, Crossroads, Splintertree Post

				-- Horde: Thunder Bluff (Mulgore)
				["0.45:0.56:0.44:0.69:0.42:0.79"] = 381, -- Thunder Bluff, Camp Mojache, Cenarion Hold
				["0.45:0.56:0.61:0.80:0.50:0.76"] = 395, -- Thunder Bluff, Gadgetzan, Marshal's Refuge
				["0.45:0.56:0.55:0.73"] = 204, -- Thunder Bluff, Freewind Post
				["0.45:0.56:0.61:0.80"] = 290, -- Thunder Bluff, Gadgetzan
				["0.45:0.56:0.53:0.61:0.57:0.64:0.58:0.70"] = 206, -- Thunder Bluff, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.45:0.56:0.57:0.64"] = 239, -- Thunder Bluff, Brackenwall Village
				["0.45:0.56:0.53:0.61"] = 87, -- Thunder Bluff, Camp Taurajo (Steven Martin suggested 97 but testing showed 87)
				["0.45:0.56:0.44:0.69"] = 252, -- Thunder Bluff, Camp Mojache
				["0.45:0.56:0.32:0.58"] = 159, -- Thunder Bluff, Shadowprey Village
				["0.45:0.56:0.41:0.47"] = 182, -- Thunder Bluff, Sun Rock Retreat
				["0.45:0.56:0.56:0.53"] = 103, -- Thunder Bluff, Crossroads
				["0.45:0.56:0.56:0.53:0.61:0.55"] = 154, -- Thunder Bluff, Crossroads, Ratchet
				["0.45:0.56:0.63:0.44"] = 207, -- Thunder Bluff, Orgrimmar
				["0.45:0.56:0.56:0.53:0.55:0.42"] = 265, -- Thunder Bluff, Crossroads, Splintertree Post
				["0.45:0.56:0.63:0.36"] = 251, -- Thunder Bluff, Valormok
				["0.45:0.56:0.56:0.53:0.55:0.42:0.50:0.35"] = 343, -- Thunder Bluff, Crossroads, Splintertree Post, Emerald Sanctuary
				["0.45:0.56:0.56:0.53:0.46:0.30"] = 355, -- Thunder Bluff, Crossroads, Bloodvenom Post
				["0.45:0.56:0.41:0.37"] = 265, -- Thunder Bluff, Zoram'gar Outpost
				["0.45:0.56:0.63:0.36:0.64:0.23:0.54:0.21"] = 513, -- Thunder Bluff, Valormok, Everlook, Moonglade
				["0.45:0.56:0.63:0.36:0.64:0.23"] = 380, -- Thunder Bluff, Valormok, Everlook
				["0.45:0.56:0.61:0.80:0.50:0.76:0.42:0.79"] = 490, -- Thunder Bluff, Gadgetzan, Marshal's Refuge, Cenarion Hold
				["0.45:0.56:0.63:0.44:0.64:0.23"] = 448, -- Thunder Bluff, Orgrimmar, Everlook
				["0.45:0.56:0.56:0.53:0.46:0.30:0.54:0.21"] = 477, -- Thunder Bluff, Crossroads, Bloodvenom Post, Moonglade
				["0.45:0.56:0.63:0.44:0.61:0.55"] = 315, -- Thunder Bluff, Orgrimmar, Ratchet

				-- Horde: Valormok (Azshara)
				["0.63:0.36:0.56:0.53:0.55:0.73:0.61:0.80"] = 441, -- Valormok, Crossroads, Freewind Post, Gadgetzan
				["0.63:0.36:0.56:0.53:0.44:0.69:0.42:0.79"] = 545, -- Valormok, Crossroads, Camp Mojache, Cenarion Hold
				["0.63:0.36:0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76"] = 541, -- Valormok, Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.63:0.36:0.56:0.53:0.55:0.73"] = 348, -- Valormok, Crossroads, Freewind Post
				["0.63:0.36:0.56:0.53:0.53:0.61:0.57:0.64:0.58:0.70"] = 356, -- Valormok, Crossroads, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.63:0.36:0.56:0.53:0.53:0.61:0.57:0.64"] = 295, -- Valormok, Crossroads, Camp Taurajo, Brackenwall Village
				["0.63:0.36:0.56:0.53:0.53:0.61"] = 237, -- Valormok, Crossroads, Camp Taurajo
				["0.63:0.36:0.56:0.53:0.44:0.69"] = 415, -- Valormok, Crossroads, Camp Mojache
				["0.63:0.36:0.45:0.56:0.32:0.58"] = 409, -- Valormok, Thunder Bluff, Shadowprey Village
				["0.63:0.36:0.45:0.56"] = 250, -- Valormok, Thunder Bluff
				["0.63:0.36:0.56:0.53"] = 164, -- Valormok, Crossroads
				["0.63:0.36:0.63:0.44:0.61:0.55"] = 208, -- Valormok, Orgrimmar, Ratchet
				["0.63:0.36:0.63:0.44"] = 101, -- Valormok, Orgrimmar
				["0.63:0.36:0.55:0.42"] = 94, -- Valormok, Splintertree Post
				["0.63:0.36:0.56:0.53:0.41:0.47"] = 313, -- Valormok, Crossroads, Sun Rock Retreat
				["0.63:0.36:0.55:0.42:0.41:0.37"] = 253, -- Valormok, Splintertree Post, Zoram'gar Outpost
				["0.63:0.36:0.55:0.42:0.50:0.35"] = 172, -- Valormok, Splintertree Post, Emerald Sanctuary
				["0.63:0.36:0.46:0.30"] = 233, -- Valormok, Bloodvenom Post
				["0.63:0.36:0.64:0.23:0.54:0.21"] = 264, -- Valormok, Everlook, Moonglade
				["0.63:0.36:0.64:0.23"] = 131, -- Valormok, Everlook
				["0.63:0.36:0.46:0.30:0.54:0.21"] = 349, -- Valormok, Bloodvenom Post, Moonglade

				-- Horde: Zoram'gar Outpost (Ashenvale)
				["0.41:0.37:0.56:0.53:0.55:0.73:0.61:0.80"] = 512, -- Zoram'gar Outpost, Crossroads, Freewind Post, Gadgetzan
				["0.41:0.37:0.41:0.47:0.32:0.58:0.44:0.69:0.42:0.79"] = 589, -- Zoram'gar Outpost, Sun Rock Retreat, Shadowprey Village, Camp Mojache, Cenarion Hold
				["0.41:0.37:0.56:0.53:0.55:0.73:0.61:0.80:0.50:0.76"] = 611, -- Zoram'gar Outpost, Crossroads, Freewind Post, Gadgetzan, Marshal's Refuge
				["0.41:0.37:0.56:0.53:0.55:0.73"] = 419, -- Zoram'gar Outpost, Crossroads, Freewind Post
				["0.41:0.37:0.56:0.53:0.53:0.61:0.57:0.64:0.58:0.70"] = 428, -- Zoram'gar Outpost, Crossroads, Camp Taurajo, Brackenwall Village, Mudsprocket
				["0.41:0.37:0.56:0.53:0.53:0.61:0.57:0.64"] = 366, -- Zoram'gar Outpost, Crossroads, Camp Taurajo, Brackenwall Village
				["0.41:0.37:0.56:0.53:0.53:0.61"] = 309, -- Zoram'gar Outpost, Crossroads, Camp Taurajo
				["0.41:0.37:0.41:0.47:0.32:0.58:0.44:0.69"] = 459, -- Zoram'gar Outpost, Sun Rock Retreat, Shadowprey Village, Camp Mojache
				["0.41:0.37:0.41:0.47:0.32:0.58"] = 264, -- Zoram'gar Outpost, Sun Rock Retreat, Shadowprey Village
				["0.41:0.37:0.45:0.56"] = 247, -- Zoram'gar Outpost, Thunder Bluff
				["0.41:0.37:0.56:0.53"] = 235, -- Zoram'gar Outpost, Crossroads
				["0.41:0.37:0.56:0.53:0.61:0.55"] = 287, -- Zoram'gar Outpost, Crossroads, Ratchet
				["0.41:0.37:0.55:0.42:0.63:0.44"] = 262, -- Zoram'gar Outpost, Splintertree Post, Orgrimmar
				["0.41:0.37:0.55:0.42"] = 173, -- Zoram'gar Outpost, Splintertree Post
				["0.41:0.37:0.41:0.47"] = 121, -- Zoram'gar Outpost, Sun Rock Retreat
				["0.41:0.37:0.50:0.35"] = 122, -- Zoram'gar Outpost, Emerald Sanctuary
				["0.41:0.37:0.46:0.30"] = 138, -- Zoram'gar Outpost, Bloodvenom Post
				["0.41:0.37:0.55:0.42:0.63:0.36"] = 258, -- Zoram'gar Outpost, Splintertree Post, Valormok
				["0.41:0.37:0.46:0.30:0.64:0.23"] = 285, -- Zoram'gar Outpost, Bloodvenom Post, Everlook
				["0.41:0.37:0.46:0.30:0.54:0.21"] = 263, -- Zoram'gar Outpost, Bloodvenom Post, Moonglade
				["0.41:0.37:0.56:0.53:0.63:0.44"] = 352, -- Zoram'gar Outpost, Crossroads, Orgrimmar
				["0.41:0.37:0.45:0.56:0.32:0.58"] = 407, -- Zoram'gar Outpost, Thunder Bluff, Shadowprey Village

			},

			-- Horde: Outland
			[1945] = {

				-- Horde: Altar of Sha'tar (Shadowmoon Valley)
				["0.81:0.77:0.66:0.77"] = 67, -- Altar of Sha'tar, Shadowmoon Village
				["0.81:0.77:0.51:0.73:0.44:0.67"] = 193, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath
				["0.81:0.77:0.51:0.73"] = 140, -- Altar of Sha'tar, Stonebreaker Hold
				["0.81:0.77:0.51:0.73:0.65:0.50"] = 263, -- Altar of Sha'tar, Stonebreaker Hold, Thrallmar
				["0.81:0.77:0.51:0.73:0.44:0.67:0.23:0.50"] = 329, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Zabra'jin
				["0.81:0.77:0.51:0.73:0.44:0.67:0.29:0.62"] = 274, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Garadar
				["0.81:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27"] = 398, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52
				["0.81:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 463, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.81:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 446, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.81:0.77:0.51:0.73:0.44:0.67:0.44:0.51"] = 272, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Swamprat Post
				["0.81:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32"] = 378, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold
				["0.81:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.42:0.28"] = 403, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.81:0.77:0.51:0.73:0.65:0.50:0.68:0.63"] = 328, -- Altar of Sha'tar, Stonebreaker Hold, Thrallmar, Spinebreaker Ridge
				["0.81:0.77:0.51:0.73:0.65:0.50:0.79:0.54"] = 333, -- Altar of Sha'tar, Stonebreaker Hold, Thrallmar, Hellfire Peninsula
				["0.81:0.77:0.51:0.73:0.44:0.67:0.54:0.57"] = 269, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Falcon Watch
				["0.81:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36"] = 342, -- Altar of Sha'tar, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32"] = 378, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27"] = 398, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52
				["0.81:0.77:0.66:0.77:0.51:0.73"] = 140, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67"] = 194, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.29:0.62"] = 274, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Garadar
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 445, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.81:0.77:0.66:0.77:0.51:0.73:0.65:0.50"] = 263, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Thrallmar
				["0.81:0.77:0.66:0.77:0.51:0.73:0.65:0.50:0.79:0.54"] = 333, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Thrallmar, Hellfire Peninsula
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51"] = 272, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.42:0.28"] = 403, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27"] = 474, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36"] = 342, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 463, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.23:0.50"] = 329, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Zabra'jin
				["0.81:0.77:0.66:0.77:0.51:0.73:0.44:0.67:0.54:0.57"] = 269, -- Altar of Sha'tar, Shadowmoon Village, Stonebreaker Hold, Shattrath, Falcon Watch

				-- Horde: Area 52 (Netherstorm)
				["0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77"] = 357, -- Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50:0.68:0.63"] = 342, -- Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50:0.79:0.54"] = 343, -- Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50"] = 273, -- Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar
				["0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57"] = 204, -- Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch
				["0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73"] = 292, -- Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold
				["0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67"] = 224, -- Area 52, Mok'Nathal Village, Swamprat Post, Shattrath
				["0.58:0.27:0.49:0.36:0.44:0.51"] = 137, -- Area 52, Mok'Nathal Village, Swamprat Post
				["0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.29:0.62"] = 306, -- Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Garadar
				["0.58:0.27:0.49:0.36:0.44:0.51:0.23:0.50"] = 248, -- Area 52, Mok'Nathal Village, Swamprat Post, Zabra'jin
				["0.58:0.27:0.38:0.32"] = 108, -- Area 52, Thunderlord Stronghold
				["0.58:0.27:0.49:0.36"] = 64, -- Area 52, Mok'Nathal Village
				["0.58:0.27:0.42:0.28"] = 82, -- Area 52, Evergrove (was 80, Michael Kartoz reported 86 so changed to 82)
				["0.58:0.27:0.63:0.18"] = 47, -- Area 52, The Stormspire
				["0.58:0.27:0.72:0.28"] = 66, -- Area 52, Cosmowrench
				["0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 437, -- Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.58:0.27:0.38:0.32:0.44:0.51:0.54:0.57"] = 287, -- Area 52, Thunderlord Stronghold, Swamprat Post, Falcon Watch
				["0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 420, -- Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.58:0.27:0.38:0.32:0.44:0.51:0.44:0.67"] = 311, -- Area 52, Thunderlord Stronghold, Swamprat Post, Shattrath
				["0.58:0.27:0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50"] = 359, -- Area 52, Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar
				["0.58:0.27:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77"] = 443, -- Area 52, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.58:0.27:0.38:0.32:0.44:0.51"] = 224, -- Area 52, Thunderlord Stronghold, Swamprat Post
				["0.58:0.27:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73"] = 379, -- Area 52, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold
				["0.58:0.27:0.38:0.32:0.23:0.50"] = 257, -- Area 52, Thunderlord Stronghold, Zabra'jin
				["0.58:0.27:0.38:0.32:0.23:0.50:0.29:0.62"] = 335, -- Area 52, Thunderlord Stronghold, Zabra'jin, Garadar
				["0.58:0.27:0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50:0.79:0.54"] = 430, -- Area 52, Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.58:0.27:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 507, -- Area 52, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.58:0.27:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 524, -- Area 52, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.58:0.27:0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50:0.68:0.63"] = 424, -- Area 52, Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar, Spinebreaker Ridge

				-- Horde: Cosmowrench (Netherstorm)
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77"] = 420, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50:0.68:0.63"] = 401, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50:0.79:0.54"] = 406, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50"] = 336, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57"] = 264, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73"] = 355, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67"] = 287, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51"] = 204, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.29:0.62"] = 371, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Garadar
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.23:0.50"] = 312, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Zabra'jin
				["0.72:0.28:0.58:0.27:0.38:0.32"] = 173, -- Cosmowrench, Area 52, Thunderlord Stronghold
				["0.72:0.28:0.58:0.27:0.49:0.36"] = 129, -- Cosmowrench, Area 52, Mok'Nathal Village
				["0.72:0.28:0.58:0.27:0.42:0.28"] = 146, -- Cosmowrench, Area 52, Evergrove
				["0.72:0.28:0.58:0.27"] = 64, -- Cosmowrench, Area 52
				["0.72:0.28:0.63:0.18"] = 61, -- Cosmowrench, The Stormspire
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 484, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.72:0.28:0.58:0.27:0.38:0.32:0.44:0.51:0.44:0.67"] = 374, -- Cosmowrench, Area 52, Thunderlord Stronghold, Swamprat Post, Shattrath
				["0.72:0.28:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 501, -- Cosmowrench, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.72:0.28:0.58:0.27:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73"] = 442, -- Cosmowrench, Area 52, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold
				["0.72:0.28:0.58:0.27:0.38:0.32:0.44:0.51"] = 288, -- Cosmowrench, Area 52, Thunderlord Stronghold, Swamprat Post
				["0.72:0.28:0.63:0.18:0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50"] = 457, -- Cosmowrench, The Stormspire, Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar
				["0.72:0.28:0.58:0.27:0.38:0.32:0.23:0.50"] = 320, -- Cosmowrench, Area 52, Thunderlord Stronghold, Zabra'jin
				["0.72:0.28:0.58:0.27:0.38:0.32:0.44:0.51:0.44:0.67:0.29:0.62"] = 456, -- Cosmowrench, Area 52, Thunderlord Stronghold, Swamprat Post, Shattrath, Garadar
				["0.72:0.28:0.63:0.18:0.38:0.32:0.44:0.51:0.44:0.67"] = 409, -- Cosmowrench, The Stormspire, Thunderlord Stronghold, Swamprat Post, Shattrath
				["0.72:0.28:0.58:0.27:0.38:0.32:0.23:0.50:0.29:0.62"] = 398, -- Cosmowrench, Area 52, Thunderlord Stronghold, Zabra'jin, Garadar
				["0.72:0.28:0.58:0.27:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 571, -- Cosmowrench, Area 52, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars

				-- Horde: Evergrove (Blade's Edge Mountains)
				["0.42:0.28:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77"] = 371, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.42:0.28:0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50:0.68:0.63"] = 353, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.42:0.28:0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50:0.79:0.54"] = 358, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.42:0.28:0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50"] = 287, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar
				["0.42:0.28:0.38:0.32:0.44:0.51:0.54:0.57"] = 215, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Falcon Watch
				["0.42:0.28:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73"] = 306, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold
				["0.42:0.28:0.38:0.32:0.44:0.51:0.44:0.67"] = 238, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Shattrath
				["0.42:0.28:0.38:0.32:0.44:0.51"] = 152, -- Evergrove, Thunderlord Stronghold, Swamprat Post
				["0.42:0.28:0.38:0.32:0.23:0.50:0.29:0.62"] = 262, -- Evergrove, Thunderlord Stronghold, Zabra'jin, Garadar
				["0.42:0.28:0.38:0.32:0.23:0.50"] = 184, -- Evergrove, Thunderlord Stronghold, Zabra'jin
				["0.42:0.28:0.38:0.32"] = 36, -- Evergrove, Thunderlord Stronghold
				["0.42:0.28:0.38:0.32:0.49:0.36"] = 91, -- Evergrove, Thunderlord Stronghold, Mok'Nathal Village
				["0.42:0.28:0.58:0.27"] = 78, -- Evergrove, Area 52
				["0.42:0.28:0.58:0.27:0.72:0.28"] = 143, -- Evergrove, Area 52, Cosmowrench
				["0.42:0.28:0.58:0.27:0.63:0.18"] = 125, -- Evergrove, Area 52, The Stormspire
				["0.42:0.28:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 435, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.42:0.28:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 452, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.42:0.28:0.38:0.32:0.44:0.51:0.44:0.67:0.29:0.62"] = 319, -- Evergrove, Thunderlord Stronghold, Swamprat Post, Shattrath, Garadar
				["0.42:0.28:0.38:0.32:0.63:0.18"] = 192, -- Evergrove, Thunderlord Stronghold, The Stormspire

				-- Horde: Falcon Watch (Hellfire Peninsula)
				["0.54:0.57:0.44:0.67:0.51:0.73:0.66:0.77"] = 204, -- Falcon Watch, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.54:0.57:0.65:0.50:0.68:0.63"] = 138, -- Falcon Watch, Thrallmar, Spinebreaker Ridge (suggestion of 74 by Jeremiah Wilson)
				["0.54:0.57:0.65:0.50:0.79:0.54"] = 143, -- Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.54:0.57:0.65:0.50"] = 73, -- Falcon Watch, Thrallmar
				["0.54:0.57:0.44:0.67:0.51:0.73"] = 139, -- Falcon Watch, Shattrath, Stonebreaker Hold
				["0.54:0.57:0.44:0.67"] = 71, -- Falcon Watch, Shattrath
				["0.54:0.57:0.44:0.51"] = 69, -- Falcon Watch, Swamprat Post
				["0.54:0.57:0.29:0.62"] = 132, -- Falcon Watch, Garadar
				["0.54:0.57:0.23:0.50"] = 150, -- Falcon Watch, Zabra'jin
				["0.54:0.57:0.44:0.51:0.38:0.32"] = 174, -- Falcon Watch, Swamprat Post, Thunderlord Stronghold
				["0.54:0.57:0.44:0.51:0.38:0.32:0.42:0.28"] = 201, -- Falcon Watch, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.54:0.57:0.44:0.51:0.49:0.36"] = 139, -- Falcon Watch, Swamprat Post, Mok'Nathal Village
				["0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27"] = 199, -- Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52
				["0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 260, -- Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 242, -- Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.54:0.57:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 286, -- Falcon Watch, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.54:0.57:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 269, -- Falcon Watch, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.54:0.57:0.44:0.51:0.38:0.32:0.58:0.27"] = 271, -- Falcon Watch, Swamprat Post, Thunderlord Stronghold, Area 52

				-- Horde: Garadar (Nagrand)
				["0.29:0.62:0.44:0.67:0.51:0.73:0.66:0.77"] = 210, -- Garadar, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.29:0.62:0.44:0.67:0.51:0.73"] = 145, -- Garadar, Shattrath, Stonebreaker Hold
				["0.29:0.62:0.44:0.67"] = 77, -- Garadar, Shattrath
				["0.29:0.62:0.54:0.57:0.65:0.50:0.68:0.63"] = 266, -- Garadar, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.29:0.62:0.54:0.57:0.65:0.50:0.79:0.54"] = 270, -- Garadar, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.29:0.62:0.54:0.57:0.65:0.50"] = 199, -- Garadar, Falcon Watch, Thrallmar
				["0.29:0.62:0.54:0.57"] = 126, -- Garadar, Falcon Watch
				["0.29:0.62:0.44:0.67:0.44:0.51"] = 156, -- Garadar, Shattrath, Swamprat Post
				["0.29:0.62:0.23:0.50"] = 67, -- Garadar, Zabra'jin
				["0.29:0.62:0.23:0.50:0.38:0.32"] = 177, -- Garadar, Zabra'jin, Thunderlord Stronghold
				["0.29:0.62:0.23:0.50:0.38:0.32:0.42:0.28"] = 203, -- Garadar, Zabra'jin, Thunderlord Stronghold, Evergrove
				["0.29:0.62:0.44:0.67:0.44:0.51:0.49:0.36"] = 227, -- Garadar, Shattrath, Swamprat Post, Mok'Nathal Village
				["0.29:0.62:0.23:0.50:0.38:0.32:0.58:0.27"] = 274, -- Garadar, Zabra'jin, Thunderlord Stronghold, Area 52
				["0.29:0.62:0.23:0.50:0.38:0.32:0.58:0.27:0.72:0.28"] = 339, -- Garadar, Zabra'jin, Thunderlord Stronghold, Area 52, Cosmowrench
				["0.29:0.62:0.23:0.50:0.38:0.32:0.58:0.27:0.63:0.18"] = 322, -- Garadar, Zabra'jin, Thunderlord Stronghold, Area 52, The Stormspire
				["0.29:0.62:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 291, -- Garadar, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.29:0.62:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 274, -- Garadar, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.29:0.62:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27"] = 282, -- Garadar, Shattrath, Sumpfrattenposten, Dorf der Mok'Nathal, Area 52
				["0.29:0.62:0.23:0.50:0.44:0.51"] = 175, -- Garadar, Zabra'jin, Swamprat Post
				["0.29:0.62:0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27"] = 359, -- Garadar, Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52
				["0.29:0.62:0.44:0.67:0.44:0.51:0.38:0.32:0.42:0.28"] = 287, -- Garadar, Shattrath, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.29:0.62:0.44:0.67:0.44:0.51:0.38:0.32"] = 262, -- Garadar, Shattrath, Swamprat Post, Thunderlord Stronghold

				-- Horde: Hellfire Peninsula (Hellfire Peninsula) (Dark Portal)
				["0.79:0.54:0.65:0.50:0.51:0.73:0.66:0.77"] = 252, -- Hellfire Peninsula, Thrallmar, Stonebreaker Hold, Shadowmoon Village
				["0.79:0.54:0.65:0.50:0.68:0.63"] = 125, -- Hellfire Peninsula, Thrallmar, Spinebreaker Ridge
				["0.79:0.54:0.65:0.50"] = 59, -- Hellfire Peninsula, Thrallmar
				["0.79:0.54:0.54:0.57"] = 122, -- Hellfire Peninsula, Falcon Watch
				["0.79:0.54:0.65:0.50:0.51:0.73"] = 188, -- Hellfire Peninsula, Thrallmar, Stonebreaker Hold
				["0.79:0.54:0.54:0.57:0.44:0.67"] = 193, -- Hellfire Peninsula, Falcon Watch, Shattrath
				["0.79:0.54:0.54:0.57:0.44:0.51"] = 190, -- Hellfire Peninsula, Falcon Watch, Swamprat Post
				["0.79:0.54:0.54:0.57:0.29:0.62"] = 253, -- Hellfire Peninsula, Falcon Watch, Garadar
				["0.79:0.54:0.54:0.57:0.23:0.50"] = 271, -- Hellfire Peninsula, Falcon Watch, Zabra'jin
				["0.79:0.54:0.54:0.57:0.44:0.51:0.38:0.32"] = 295, -- Hellfire Peninsula, Falcon Watch, Swamprat Post, Thunderlord Stronghold
				["0.79:0.54:0.54:0.57:0.44:0.51:0.38:0.32:0.42:0.28"] = 321, -- Hellfire Peninsula, Falcon Watch, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.79:0.54:0.54:0.57:0.44:0.51:0.49:0.36"] = 261, -- Hellfire Peninsula, Falcon Watch, Swamprat Post, Mok'Nathal Village
				["0.79:0.54:0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27"] = 316, -- Hellfire Peninsula, Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52
				["0.79:0.54:0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 381, -- Hellfire Peninsula, Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.79:0.54:0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 364, -- Hellfire Peninsula, Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.79:0.54:0.65:0.50:0.51:0.73:0.66:0.77:0.78:0.85"] = 316, -- Hellfire Peninsula, Thrallmar, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.79:0.54:0.65:0.50:0.51:0.73:0.66:0.77:0.81:0.77"] = 333, -- Hellfire Peninsula, Thrallmar, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.79:0.54:0.65:0.50:0.51:0.73:0.44:0.67"] = 241, -- Hellfire Peninsula, Thrallmar, Stonebreaker Hold, Shattrath

				-- Horde: Mok'Nathal Village (Blade's Edge Mountains)
				["0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77"] = 292, -- Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50:0.68:0.63"] = 274, -- Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50:0.79:0.54"] = 279, -- Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50"] = 208, -- Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar
				["0.49:0.36:0.44:0.51:0.54:0.57"] = 136, -- Mok'Nathal Village, Swamprat Post, Falcon Watch
				["0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73"] = 228, -- Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold
				["0.49:0.36:0.44:0.51:0.44:0.67"] = 160, -- Mok'Nathal Village, Swamprat Post, Shattrath
				["0.49:0.36:0.44:0.51"] = 74, -- Mok'Nathal Village, Swamprat Post
				["0.49:0.36:0.44:0.51:0.44:0.67:0.29:0.62"] = 243, -- Mok'Nathal Village, Swamprat Post, Shattrath, Garadar
				["0.49:0.36:0.44:0.51:0.23:0.50"] = 185, -- Mok'Nathal Village, Swamprat Post, Zabra'jin
				["0.49:0.36:0.38:0.32"] = 63, -- Mok'Nathal Village, Thunderlord Stronghold
				["0.49:0.36:0.38:0.32:0.42:0.28"] = 88, -- Mok'Nathal Village, Thunderlord Stronghold, Evergrove (Fabio Finger reported 64)
				["0.49:0.36:0.58:0.27"] = 57, -- Mok'Nathal Village, Area 52
				["0.49:0.36:0.58:0.27:0.72:0.28"] = 122, -- Mok'Nathal Village, Area 52, Cosmowrench
				["0.49:0.36:0.58:0.27:0.63:0.18"] = 104, -- Mok'Nathal Village, Area 52, The Stormspire
				["0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 374, -- Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 357, -- Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.49:0.36:0.38:0.32:0.23:0.50:0.44:0.67"] = 359, -- Mok'Nathal Village, Thunderlord Stronghold, Zabra'jin, Shattrath

				-- Horde: Sanctum of the Stars (Shadowmoon Valley)
				["0.78:0.85:0.66:0.77"] = 61, -- Sanctum of the Stars, Shadowmoon Village
				["0.78:0.85:0.51:0.73"] = 134, -- Sanctum of the Stars, Stonebreaker Hold
				["0.78:0.85:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.42:0.28"] = 397, -- Sanctum of the Stars, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.78:0.85:0.51:0.73:0.44:0.67"] = 187, -- Sanctum of the Stars, Stonebreaker Hold, Shattrath
				["0.78:0.85:0.51:0.73:0.65:0.50:0.68:0.63"] = 322, -- Sanctum of the Stars, Stonebreaker Hold, Thrallmar, Spinebreaker Ridge
				["0.78:0.85:0.51:0.73:0.44:0.67:0.29:0.62"] = 268, -- Sanctum of the Stars, Stonebreaker Hold, Shattrath, Garadar
				["0.78:0.85:0.51:0.73:0.65:0.50"] = 257, -- Sanctum of the Stars, Stonebreaker Hold, Thrallmar
				["0.78:0.85:0.51:0.73:0.44:0.67:0.23:0.50"] = 323, -- Sanctum of the Stars, Stonebreaker Hold, Shattrath, Zabra'jin
				["0.78:0.85:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 439, -- Sanctum of the Stars, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.78:0.85:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 457, -- Sanctum of the Stars, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.78:0.85:0.51:0.73:0.65:0.50:0.79:0.54"] = 327, -- Sanctum of the Stars, Stonebreaker Hold, Thrallmar, Hellfire Peninsula
				["0.78:0.85:0.51:0.73:0.44:0.67:0.44:0.51"] = 266, -- Sanctum of the Stars, Stonebreaker Hold, Shattrath, Swamprat Post
				["0.78:0.85:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27"] = 392, -- Sanctum of the Stars, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52
				["0.78:0.85:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32"] = 371, -- Sanctum of the Stars, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 439, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67"] = 187, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.29:0.62"] = 268, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Garadar
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.42:0.28"] = 397, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Thunderlord Stronghold, Evergrove
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27"] = 392, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52
				["0.78:0.85:0.66:0.77:0.51:0.73"] = 134, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51"] = 266, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27"] = 468, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32"] = 372, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.54:0.57"] = 263, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Falcon Watch
				["0.78:0.85:0.66:0.77:0.51:0.73:0.65:0.50"] = 257, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Thrallmar
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.23:0.50"] = 323, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Zabra'jin
				["0.78:0.85:0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 457, -- Sanctum of the Stars, Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench

				-- Horde: Shadowmoon Village (Shadowmoon Valley)
				["0.66:0.77:0.51:0.73"] = 73, -- Shadowmoon Village, Stonebreaker Hold
				["0.66:0.77:0.51:0.73:0.44:0.67"] = 126, -- Shadowmoon Village, Stonebreaker Hold, Shattrath
				["0.66:0.77:0.51:0.73:0.44:0.67:0.29:0.62"] = 207, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Garadar
				["0.66:0.77:0.51:0.73:0.44:0.67:0.23:0.50"] = 262, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Zabra'jin
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51"] = 205, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post
				["0.66:0.77:0.51:0.73:0.44:0.67:0.54:0.57"] = 202, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Falcon Watch
				["0.66:0.77:0.51:0.73:0.65:0.50:0.68:0.63"] = 262, -- Shadowmoon Village, Stonebreaker Hold, Thrallmar, Spinebreaker Ridge
				["0.66:0.77:0.51:0.73:0.65:0.50:0.79:0.54"] = 267, -- Shadowmoon Village, Stonebreaker Hold, Thrallmar, Hellfire Peninsula
				["0.66:0.77:0.51:0.73:0.65:0.50"] = 196, -- Shadowmoon Village, Stonebreaker Hold, Thrallmar
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36"] = 276, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32"] = 311, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.42:0.28"] = 336, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Evergrove (Kristopher Williamson reported 73, not changed)
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27"] = 331, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 397, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 379, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.66:0.77:0.78:0.85"] = 66, -- Shadowmoon Village, Sanctum of the Stars
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27"] = 407, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52
				["0.66:0.77:0.81:0.77"] = 85, -- Shadowmoon Village, Altar of Sha'tar
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27:0.72:0.28"] = 473, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52, Cosmowrench
				["0.66:0.77:0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27:0.63:0.18"] = 455, -- Shadowmoon Village, Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52, The Stormspire

				-- Horde: Shattrath (Terokkar Forest)
				["0.44:0.67:0.23:0.50"] = 136, -- Shattrath, Zabra'jin
				["0.44:0.67:0.29:0.62"] = 81, -- Shattrath, Garadar
				["0.44:0.67:0.44:0.51"] = 79, -- Shattrath, Swamprat Post
				["0.44:0.67:0.54:0.57"] = 77, -- Shattrath, Falcon Watch
				["0.44:0.67:0.51:0.73"] = 69, -- Shattrath, Stonebreaker Hold
				["0.44:0.67:0.51:0.73:0.66:0.77"] = 133, -- Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.44:0.67:0.54:0.57:0.65:0.50:0.68:0.63"] = 215, -- Shattrath, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.44:0.67:0.54:0.57:0.65:0.50:0.79:0.54"] = 220, -- Shattrath, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.44:0.67:0.54:0.57:0.65:0.50"] = 150, -- Shattrath, Falcon Watch, Thrallmar (Mirko Riemann reported 78, not changed yet)
				["0.44:0.67:0.44:0.51:0.49:0.36"] = 150, -- Shattrath, Swamprat Post, Mok'Nathal Village
				["0.44:0.67:0.44:0.51:0.38:0.32:0.42:0.28"] = 211, -- Shattrath, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.44:0.67:0.44:0.51:0.38:0.32"] = 185, -- Shattrath, Swamprat Post, Thunderlord Stronghold
				["0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27"] = 205, -- Shattrath, Swamprat Post, Mok'Nathal Village, Area 52
				["0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 253, -- Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 270, -- Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 215, -- Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27:0.72:0.28"] = 347, -- Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52, Cosmowrench
				["0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 198, -- Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27"] = 282, -- Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52
				["0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27:0.63:0.18"] = 329, -- Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52, The Stormspire
				["0.44:0.67:0.51:0.73:0.65:0.50"] = 193, -- Shattrath, Stonebreaker Hold, Thrallmar
				["0.44:0.67:0.44:0.51:0.38:0.32:0.63:0.18"] = 341, -- Shattrath, Swamprat Post, Thunderlord Stronghold, The Stormspire
				["0.44:0.67:0.51:0.73:0.65:0.50:0.68:0.63"] = 257, -- Shattrath, Stonebreaker Hold, Thrallmar, Spinebreaker Ridge
				["0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.42:0.28"] = 286, -- Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, Evergrove
				["0.44:0.67:0.23:0.50:0.38:0.32:0.58:0.27"] = 344, -- Shattrath, Zabra'jin, Thunderlord Stronghold, Area 52

				-- Horde: Spinebreaker Ridge (Hellfire Peninsula)
				["0.68:0.63:0.65:0.50:0.54:0.57:0.29:0.62"] = 263, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Garadar
				["0.68:0.63:0.65:0.50:0.54:0.57:0.44:0.67"] = 200, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Shattrath
				["0.68:0.63:0.65:0.50:0.51:0.73"] = 190, -- Spinebreaker Ridge, Thrallmar, Stonebreaker Hold
				["0.68:0.63:0.65:0.50:0.51:0.73:0.66:0.77"] = 255, -- Spinebreaker Ridge, Thrallmar, Stonebreaker Hold, Shadowmoon Village
				["0.68:0.63:0.65:0.50:0.79:0.54"] = 133, -- Spinebreaker Ridge, Thrallmar, Hellfire Peninsula
				["0.68:0.63:0.65:0.50"] = 62, -- Spinebreaker Ridge, Thrallmar
				["0.68:0.63:0.65:0.50:0.54:0.57"] = 129, -- Spinebreaker Ridge, Thrallmar, Falcon Watch
				["0.68:0.63:0.65:0.50:0.54:0.57:0.44:0.51"] = 198, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Swamprat Post
				["0.68:0.63:0.65:0.50:0.54:0.57:0.23:0.50"] = 280, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Zabra'jin
				["0.68:0.63:0.65:0.50:0.54:0.57:0.44:0.51:0.38:0.32"] = 303, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Swamprat Post, Thunderlord Stronghold
				["0.68:0.63:0.65:0.50:0.54:0.57:0.44:0.51:0.38:0.32:0.42:0.28"] = 330, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.68:0.63:0.65:0.50:0.54:0.57:0.44:0.51:0.49:0.36"] = 268, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Swamprat Post, Mok'Nathal Village
				["0.68:0.63:0.65:0.50:0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27"] = 327, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52
				["0.68:0.63:0.65:0.50:0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 389, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.68:0.63:0.65:0.50:0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 373, -- Spinebreaker Ridge, Thrallmar, Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.68:0.63:0.65:0.50:0.51:0.73:0.66:0.77:0.78:0.85"] = 319, -- Spinebreaker Ridge, Thrallmar, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.68:0.63:0.65:0.50:0.51:0.73:0.66:0.77:0.81:0.77"] = 335, -- Spinebreaker Ridge, Thrallmar, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar

				-- Horde: Stonebreaker Hold (Terokkar Forest)
				["0.51:0.73:0.66:0.77"] = 68, -- Stonebreaker Hold, Shadowmoon Village
				["0.51:0.73:0.65:0.50:0.68:0.63"] = 191, -- Stonebreaker Hold, Thrallmar, Spinebreaker Ridge
				["0.51:0.73:0.65:0.50:0.79:0.54"] = 195, -- Stonebreaker Hold, Thrallmar, Hellfire Peninsula
				["0.51:0.73:0.65:0.50"] = 125, -- Stonebreaker Hold, Thrallmar
				["0.51:0.73:0.44:0.67:0.54:0.57"] = 132, -- Stonebreaker Hold, Shattrath, Falcon Watch
				["0.51:0.73:0.44:0.67"] = 56, -- Stonebreaker Hold, Shattrath
				["0.51:0.73:0.44:0.67:0.29:0.62"] = 137, -- Stonebreaker Hold, Shattrath, Garadar
				["0.51:0.73:0.44:0.67:0.44:0.51"] = 135, -- Stonebreaker Hold, Shattrath, Swamprat Post
				["0.51:0.73:0.44:0.67:0.23:0.50"] = 193, -- Stonebreaker Hold, Shattrath, Zabra'jin
				["0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32"] = 242, -- Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold
				["0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.42:0.28"] = 266, -- Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36"] = 207, -- Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village
				["0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27"] = 261, -- Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52
				["0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 330, -- Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.51:0.73:0.44:0.67:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 313, -- Stonebreaker Hold, Shattrath, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.51:0.73:0.66:0.77:0.78:0.85"] = 133, -- Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.51:0.73:0.66:0.77:0.81:0.77"] = 149, -- Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27:0.63:0.18"] = 385, -- Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52, The Stormspire
				["0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27:0.72:0.28"] = 403, -- Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52, Cosmowrench
				["0.51:0.73:0.44:0.67:0.44:0.51:0.38:0.32:0.58:0.27"] = 338, -- Stonebreaker Hold, Shattrath, Swamprat Post, Thunderlord Stronghold, Area 52
				["0.51:0.73:0.65:0.50:0.54:0.57"] = 192, -- Stonebreaker Hold, Thrallmar, Falcon Watch
				["0.51:0.73:0.65:0.50:0.54:0.57:0.44:0.51"] = 260, -- Stonebreaker Hold, Thrallmar, Falcon Watch, Swamprat Post

				-- Horde: Swamprat Post (Zangarmarsh)
				["0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77"] = 220, -- Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.44:0.51:0.54:0.57:0.65:0.50:0.68:0.63"] = 201, -- Swamprat Post, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.44:0.51:0.54:0.57:0.65:0.50:0.79:0.54"] = 206, -- Swamprat Post, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.44:0.51:0.54:0.57:0.65:0.50"] = 136, -- Swamprat Post, Falcon Watch, Thrallmar
				["0.44:0.51:0.54:0.57"] = 61, -- Swamprat Post, Falcon Watch
				["0.44:0.51:0.44:0.67:0.51:0.73"] = 155, -- Swamprat Post, Shattrath, Stonebreaker Hold
				["0.44:0.51:0.44:0.67"] = 86, -- Swamprat Post, Shattrath
				["0.44:0.51:0.44:0.67:0.29:0.62"] = 168, -- Swamprat Post, Shattrath, Garadar
				["0.44:0.51:0.23:0.50"] = 111, -- Swamprat Post, Zabra'jin
				["0.44:0.51:0.38:0.32"] = 106, -- Swamprat Post, Thunderlord Stronghold
				["0.44:0.51:0.38:0.32:0.42:0.28"] = 132, -- Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.44:0.51:0.49:0.36"] = 71, -- Swamprat Post, Mok'Nathal Village
				["0.44:0.51:0.49:0.36:0.58:0.27"] = 126, -- Swamprat Post, Mok'Nathal Village, Area 52
				["0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 193, -- Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 174, -- Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 284, -- Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 301, -- Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.44:0.51:0.38:0.32:0.58:0.27"] = 202, -- Swamprat Post, Thunderlord Stronghold, Area 52
				["0.44:0.51:0.38:0.32:0.58:0.27:0.63:0.18"] = 250, -- Swamprat Post, Thunderlord Stronghold, Area 52, The Stormspire
				["0.44:0.51:0.54:0.57:0.65:0.50:0.51:0.73"] = 264, -- Swamprat Post, Falcon Watch, Thrallmar, Stonebreaker Hold

				-- Horde: The Stormspire (Netherstorm)
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77"] = 410, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50:0.68:0.63"] = 390, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50:0.79:0.54"] = 395, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57:0.65:0.50"] = 326, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch, Thrallmar
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.54:0.57"] = 254, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Falcon Watch
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73"] = 345, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67"] = 277, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51"] = 191, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.29:0.62"] = 359, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Garadar
				["0.63:0.18:0.38:0.32:0.23:0.50"] = 294, -- The Stormspire, Thunderlord Stronghold, Zabra'jin
				["0.63:0.18:0.58:0.27:0.49:0.36"] = 118, -- The Stormspire, Area 52, Mok'Nathal Village
				["0.63:0.18:0.38:0.32"] = 147, -- The Stormspire, Thunderlord Stronghold
				["0.63:0.18:0.58:0.27:0.42:0.28"] = 132, -- The Stormspire, Area 52, Evergrove
				["0.63:0.18:0.58:0.27"] = 53, -- The Stormspire, Area 52
				["0.63:0.18:0.72:0.28"] = 69, -- The Stormspire, Cosmowrench
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 474, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.63:0.18:0.38:0.32:0.44:0.51:0.44:0.67"] = 348, -- The Stormspire, Thunderlord Stronghold, Swamprat Post, Shattrath
				["0.63:0.18:0.58:0.27:0.49:0.36:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 490, -- The Stormspire, Area 52, Mok'Nathal Village, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.63:0.18:0.38:0.32:0.23:0.50:0.29:0.62"] = 372, -- The Stormspire, Thunderlord Stronghold, Zabra'jin, Garadar
				["0.63:0.18:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77"] = 481, -- The Stormspire, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.63:0.18:0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50"] = 397, -- The Stormspire, Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar
				["0.63:0.18:0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73"] = 417, -- The Stormspire, Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold
				["0.63:0.18:0.38:0.32:0.44:0.51"] = 262, -- The Stormspire, Thunderlord Stronghold, Swamprat Post
				["0.63:0.18:0.38:0.32:0.23:0.50:0.44:0.67"] = 443, -- The Stormspire, Thunderlord Stronghold, Zabra'jin, Shattrath

				-- Horde: Thrallmar (Hellfire Peninsula)
				["0.65:0.50:0.51:0.73:0.66:0.77"] = 192, -- Thrallmar, Stonebreaker Hold, Shadowmoon Village
				["0.65:0.50:0.68:0.63"] = 66, -- Thrallmar, Spinebreaker Ridge
				["0.65:0.50:0.79:0.54"] = 70, -- Thrallmar, Hellfire Peninsula
				["0.65:0.50:0.54:0.57"] = 66, -- Thrallmar, Falcon Watch
				["0.65:0.50:0.51:0.73"] = 129, -- Thrallmar, Stonebreaker Hold
				["0.65:0.50:0.54:0.57:0.44:0.67"] = 138, -- Thrallmar, Falcon Watch, Shattrath (Taylor Morris reported 67)
				["0.65:0.50:0.54:0.57:0.44:0.51"] = 135, -- Thrallmar, Falcon Watch, Swamprat Post
				["0.65:0.50:0.54:0.57:0.29:0.62"] = 199, -- Thrallmar, Falcon Watch, Garadar
				["0.65:0.50:0.54:0.57:0.23:0.50"] = 217, -- Thrallmar, Falcon Watch, Zabra'jin
				["0.65:0.50:0.54:0.57:0.44:0.51:0.38:0.32"] = 242, -- Thrallmar, Falcon Watch, Swamprat Post, Thunderlord Stronghold
				["0.65:0.50:0.54:0.57:0.44:0.51:0.38:0.32:0.42:0.28"] = 267, -- Thrallmar, Falcon Watch, Swamprat Post, Thunderlord Stronghold, Evergrove
				["0.65:0.50:0.54:0.57:0.44:0.51:0.49:0.36"] = 206, -- Thrallmar, Falcon Watch, Swamprat Post, Mok'Nathal Village
				["0.65:0.50:0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27"] = 262, -- Thrallmar, Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52
				["0.65:0.50:0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27:0.63:0.18"] = 309, -- Thrallmar, Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52, The Stormspire
				["0.65:0.50:0.54:0.57:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 327, -- Thrallmar, Falcon Watch, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.65:0.50:0.51:0.73:0.66:0.77:0.78:0.85"] = 257, -- Thrallmar, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.65:0.50:0.54:0.57:0.44:0.51:0.38:0.32:0.58:0.27"] = 338, -- Thrallmar, Falcon Watch, Swamprat Post, Thunderlord Stronghold, Area 52
				["0.65:0.50:0.51:0.73:0.66:0.77:0.81:0.77"] = 273, -- Thrallmar, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.65:0.50:0.54:0.57:0.44:0.51:0.38:0.32:0.58:0.27:0.63:0.18"] = 385, -- Thrallmar, Falcon Watch, Swamprat Post, Thunderlord Stronghold, Area 52, The Stormspire
				["0.65:0.50:0.54:0.57:0.44:0.51:0.38:0.32:0.58:0.27:0.72:0.28"] = 403, -- Thrallmar, Falcon Watch, Swamprat Post, Thunderlord Stronghold, Area 52, Cosmowrench
				["0.65:0.50:0.51:0.73:0.44:0.67"] = 182, -- Thrallmar, Stonebreaker Hold, Shattrath
				["0.65:0.50:0.54:0.57:0.44:0.51:0.38:0.32:0.63:0.18:0.72:0.28"] = 465, -- Thrallmar, Falcon Watch, Swamprat Post, Thunderlord Stronghold, The Stormspire, Cosmowrench

				-- Horde: Thunderlord Stronghold (Blade's Edge Mountains)
				["0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77"] = 335, -- Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50:0.68:0.63"] = 316, -- Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50:0.79:0.54"] = 322, -- Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.38:0.32:0.44:0.51:0.54:0.57:0.65:0.50"] = 251, -- Thunderlord Stronghold, Swamprat Post, Falcon Watch, Thrallmar
				["0.38:0.32:0.44:0.51:0.54:0.57"] = 179, -- Thunderlord Stronghold, Swamprat Post, Falcon Watch
				["0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73"] = 271, -- Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold
				["0.38:0.32:0.44:0.51:0.44:0.67"] = 202, -- Thunderlord Stronghold, Swamprat Post, Shattrath
				["0.38:0.32:0.44:0.51"] = 116, -- Thunderlord Stronghold, Swamprat Post
				["0.38:0.32:0.23:0.50:0.29:0.62"] = 227, -- Thunderlord Stronghold, Zabra'jin, Garadar
				["0.38:0.32:0.23:0.50"] = 149, -- Thunderlord Stronghold, Zabra'jin
				["0.38:0.32:0.49:0.36"] = 55, -- Thunderlord Stronghold, Mok'Nathal Village
				["0.38:0.32:0.42:0.28"] = 26, -- Thunderlord Stronghold, Evergrove
				["0.38:0.32:0.58:0.27"] = 97, -- Thunderlord Stronghold, Area 52
				["0.38:0.32:0.58:0.27:0.72:0.28"] = 163, -- Thunderlord Stronghold, Area 52, Cosmowrench
				["0.38:0.32:0.63:0.18"] = 158, -- Thunderlord Stronghold, The Stormspire
				["0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 416, -- Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar
				["0.38:0.32:0.44:0.51:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 400, -- Thunderlord Stronghold, Swamprat Post, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.38:0.32:0.23:0.50:0.44:0.67"] = 297, -- Thunderlord Stronghold, Zabra'jin, Shattrath

				-- Horde: Zabra'jin (Zangarmarsh)
				["0.23:0.50:0.29:0.62"] = 81, -- Zabra'jin, Garadar
				["0.23:0.50:0.44:0.67"] = 151, -- Zabra'jin, Shattrath
				["0.23:0.50:0.44:0.67:0.51:0.73"] = 220, -- Zabra'jin, Shattrath, Stonebreaker Hold
				["0.23:0.50:0.44:0.67:0.51:0.73:0.66:0.77"] = 284, -- Zabra'jin, Shattrath, Stonebreaker Hold, Shadowmoon Village
				["0.23:0.50:0.54:0.57:0.65:0.50:0.68:0.63"] = 287, -- Zabra'jin, Falcon Watch, Thrallmar, Spinebreaker Ridge
				["0.23:0.50:0.54:0.57:0.65:0.50:0.79:0.54"] = 290, -- Zabra'jin, Falcon Watch, Thrallmar, Hellfire Peninsula
				["0.23:0.50:0.54:0.57:0.65:0.50"] = 220, -- Zabra'jin, Falcon Watch, Thrallmar
				["0.23:0.50:0.54:0.57"] = 147, -- Zabra'jin, Falcon Watch
				["0.23:0.50:0.44:0.51"] = 112, -- Zabra'jin, Swamprat Post
				["0.23:0.50:0.38:0.32"] = 113, -- Zabra'jin, Thunderlord Stronghold
				["0.23:0.50:0.38:0.32:0.42:0.28"] = 139, -- Zabra'jin, Thunderlord Stronghold, Evergrove
				["0.23:0.50:0.38:0.32:0.49:0.36"] = 168, -- Zabra'jin, Thunderlord Stronghold, Mok'Nathal Village
				["0.23:0.50:0.38:0.32:0.58:0.27"] = 209, -- Zabra'jin, Thunderlord Stronghold, Area 52
				["0.23:0.50:0.38:0.32:0.58:0.27:0.63:0.18"] = 257, -- Zabra'jin, Thunderlord Stronghold, Area 52, The Stormspire
				["0.23:0.50:0.38:0.32:0.58:0.27:0.72:0.28"] = 275, -- Zabra'jin, Thunderlord Stronghold, Area 52, Cosmowrench
				["0.23:0.50:0.44:0.67:0.51:0.73:0.66:0.77:0.78:0.85"] = 349, -- Zabra'jin, Shattrath, Stonebreaker Hold, Shadowmoon Village, Sanctum of the Stars
				["0.23:0.50:0.44:0.51:0.49:0.36:0.58:0.27:0.72:0.28"] = 304, -- Zabra'jin, Swamprat Post, Mok'Nathal Village, Area 52, Cosmowrench
				["0.23:0.50:0.44:0.67:0.51:0.73:0.66:0.77:0.81:0.77"] = 365, -- Zabra'jin, Shattrath, Stonebreaker Hold, Shadowmoon Village, Altar of Sha'tar

			},

		}

	end
