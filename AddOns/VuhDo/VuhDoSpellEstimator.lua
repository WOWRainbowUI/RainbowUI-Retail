VUHDO_ACTIVE_HOTS = { };
VUHDO_ACTIVE_HOTS_OTHERS = { };
VUHDO_PLAYER_HOTS = { };

VUHDO_SPELL_TYPE_HOT = 1;  -- Spell type heal over time



local twipe = table.wipe;
local pairs = pairs;



--
VUHDO_SPELLS = {
	-- Paladin
	[VUHDO_SPELL_ID.BUFF_BEACON_OF_FAITH] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.BUFF_BEACON_OF_LIGHT] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.BUFF_BEACON_OF_VIRTUE] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ETERNAL_FLAME] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.GLIMMER_OF_LIGHT] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.OVERFLOWING_LIGHT] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.DAWNLIGHT] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.TYRS_DELIVERANCE] = { ["isHot"] = true, },

	-- Priest
	[VUHDO_SPELL_ID.RENEW] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.POWERWORD_SHIELD] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.PRAYER_OF_MENDING] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ECHO_OF_LIGHT] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ATONEMENT] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.PAIN_SUPPRESSION] = { ["isHot"] = true, ["nodefault"] = true, },
	[VUHDO_SPELL_ID.GUARDIAN_SPIRIT] = { ["isHot"] = true, ["nohelp"] = true, ["noselftarget"] = true, },
	[VUHDO_SPELL_ID.DIVINE_AEGIS] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.LUMINOUS_BARRIER] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.PREMONITION_OF_SOLACE] = { ["isHot"] = true, },

	-- Shaman
	[VUHDO_SPELL_ID.RIPTIDE] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.GIFT_OF_THE_NAARU] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.BUFF_EARTH_SHIELD] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.EARTHLIVING_WEAPON] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.HYDROBUBBLE] = { ["isHot"] = true, },

	-- Druid
	[VUHDO_SPELL_ID.REJUVENATION] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.REGROWTH] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.LIFEBLOOM] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.WILD_GROWTH] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.CENARION_WARD] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.GERMINATION] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.SPRING_BLOSSOMS] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ADAPTIVE_SWARM] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.EFFLORESCENCE] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.GROVE_TENDING] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.SYMBIOTIC_BLOOMS] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.MINOR_CENARION_WARD] = { ["isHot"] = true, },

	-- Hunter
	[VUHDO_SPELL_ID.MEND_PET] = { ["isHot"] = true, },

	-- Monk
	[VUHDO_SPELL_ID.SOOTHING_MIST] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ENVELOPING_MIST] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.RENEWING_MIST] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ZEN_SPHERE] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ENVELOPING_BREATH] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.CHI_COCOON] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ASPECT_OF_HARMONY] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.PURIFIED_SPIRIT] = { ["isHot"] = true, },

	-- Mage
	[VUHDO_SPELL_ID.ICE_BARRIER] = { ["isHot"] = true, },

	-- 6.2 Healer Legendary Ring
	[VUHDO_SPELL_ID.BUFF_ETHERALUS] = { ["isHot"] = true, },

	-- Evoker
	[VUHDO_SPELL_ID.DREAM_BREATH] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.DREAM_FLIGHT] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ECHO] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.LIFEBIND] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.REVERSION] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.REWIND] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.TIME_DILATION] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.TEMPORAL_ANOMALY] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.PRESCIENCE] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.ENKINDLE] = { ["isHot"] = true, },
	[VUHDO_SPELL_ID.SPIRITBLOOM] = { ["isHot"] = true, },

	-- Ward of Faceless Ire trinket
	[VUHDO_SPELL_ID.WRITHING_WARD] = { ["isHot"] = true, },

};
local VUHDO_SPELLS = VUHDO_SPELLS;



-- initializes some dynamic information into VUHDO_SPELLS
function VUHDO_initFromSpellbook()

	twipe(VUHDO_PLAYER_HOTS);

	for tSpellName, someParams in pairs(VUHDO_SPELLS) do
		if someParams["isHot"] and (VUHDO_isSpellKnown(tSpellName) or VUHDO_isTalentKnown(tSpellName)) then
			VUHDO_PLAYER_HOTS[#VUHDO_PLAYER_HOTS + 1] = tSpellName;
		end
	end

	if "PRIEST" == VUHDO_PLAYER_CLASS then
		VUHDO_PLAYER_HOTS[#VUHDO_PLAYER_HOTS + 1] = VUHDO_SPELL_ID.ECHO_OF_LIGHT;
	end

	if "DRUID" == VUHDO_PLAYER_CLASS then
		VUHDO_PLAYER_HOTS[#VUHDO_PLAYER_HOTS + 1] = VUHDO_SPELL_ID.GERMINATION;
		VUHDO_PLAYER_HOTS[#VUHDO_PLAYER_HOTS + 1] = VUHDO_SPELL_ID.SPRING_BLOSSOMS;
	end

	twipe(VUHDO_ACTIVE_HOTS);
	twipe(VUHDO_ACTIVE_HOTS_OTHERS);

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		local tHotSlots = VUHDO_PANEL_SETUP[tPanelNum]["HOTS"]["SLOTS"];

		if tHotSlots["firstFlood"] then
			tHotSlots["firstFlood"] = nil;

			for tCnt = 1, #VUHDO_PLAYER_HOTS do
				if not (VUHDO_SPELLS[VUHDO_PLAYER_HOTS[tCnt]] or { })["nodefault"] then
					if tCnt < 6 then
						tinsert(tHotSlots, VUHDO_PLAYER_HOTS[tCnt]);
					elseif tCnt > 8 then
						tinsert(tHotSlots, VUHDO_PLAYER_HOTS[tCnt - 3]);
					end

					if #tHotSlots == 12 then -- VUHDO_MAX_HOTS
						break;
					end
				end
			end
		end

		local tHotCfg = VUHDO_PANEL_SETUP[tPanelNum]["HOTS"]["SLOTCFG"];

		if tHotCfg["firstFlood"] then
			for tCnt = 1, #tHotSlots do
				tHotCfg["" .. tCnt]["others"] = VUHDO_EXCLUSIVE_HOTS[tHotSlots[tCnt]];
			end

			tHotCfg["firstFlood"] = nil;
		end

		for tCnt = #tHotSlots + 1, 12 do -- VUHDO_MAX_HOTS
			tinsert(tHotSlots, "");
		end

		for tCnt, tHotName in pairs(tHotSlots) do
			if not VUHDO_strempty(tHotName) then
				VUHDO_ACTIVE_HOTS[tHotName] = true;

				if tHotCfg["" .. tCnt]["others"] then
					VUHDO_ACTIVE_HOTS_OTHERS[tHotName] = true;
				end
			end
		end
	end

	VUHDO_initTalentSpellCaches();

	VUHDO_setKnowsSwiftmend(VUHDO_isSpellKnown(VUHDO_SPELL_ID.SWIFTMEND));
	VUHDO_setKnowsTrailOfLight(VUHDO_isTalentKnown(VUHDO_SPELL_ID.TRAIL_OF_LIGHT));

end
