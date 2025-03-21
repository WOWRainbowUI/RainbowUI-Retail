--
function VUHDO_activateLayoutNoInit(aName)

	VUHDO_SPELL_ASSIGNMENTS = VUHDO_decompressOrCopy(VUHDO_SPELL_LAYOUTS[aName]["MOUSE"]);
	VUHDO_HOSTILE_SPELL_ASSIGNMENTS = VUHDO_decompressOrCopy(VUHDO_SPELL_LAYOUTS[aName]["HOSTILE_MOUSE"]);

	if VUHDO_SPELL_LAYOUTS[aName]["HOTS"] and VUHDO_SPELL_CONFIG["IS_LOAD_HOTS"] then
		for tPanelNum = 1, VUHDO_MAX_PANELS do
			-- support for pre per-panel HoTs
			if type(VUHDO_SPELL_LAYOUTS[aName]["HOTS"]) == "table" then
				VUHDO_PANEL_SETUP[tPanelNum]["HOTS"] = VUHDO_decompressOrCopy(VUHDO_SPELL_LAYOUTS[aName]["HOTS"][tPanelNum]);
			else
				VUHDO_PANEL_SETUP[tPanelNum]["HOTS"] = VUHDO_decompressOrCopy(VUHDO_SPELL_LAYOUTS[aName]["HOTS"]);
			end
		end
	end

	VUHDO_SPELLS_KEYBOARD = VUHDO_decompressOrCopy(VUHDO_SPELL_LAYOUTS[aName]["KEYS"]);

	if VUHDO_SPELL_LAYOUTS[aName]["FIRE"] then
		VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_1"] = VUHDO_SPELL_LAYOUTS[aName]["FIRE"]["T1"];
		VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_2"] = VUHDO_SPELL_LAYOUTS[aName]["FIRE"]["T2"];
		VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_1"] = VUHDO_SPELL_LAYOUTS[aName]["FIRE"]["I1"];
		VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_2"] = VUHDO_SPELL_LAYOUTS[aName]["FIRE"]["I2"];
		VUHDO_SPELL_CONFIG["FIRE_CUSTOM_1_SPELL"] = VUHDO_SPELL_LAYOUTS[aName]["FIRE"]["I1N"];
		VUHDO_SPELL_CONFIG["FIRE_CUSTOM_2_SPELL"] = VUHDO_SPELL_LAYOUTS[aName]["FIRE"]["I2N"];
		VUHDO_SPELL_CONFIG["IS_FIRE_GLOVES"] = VUHDO_SPELL_LAYOUTS[aName]["FIRE"]["T3"];
		VUHDO_SPELL_CONFIG["custom1Unit"] = VUHDO_SPELL_LAYOUTS[aName]["FIRE"]["I1U"];
		VUHDO_SPELL_CONFIG["custom2Unit"] = VUHDO_SPELL_LAYOUTS[aName]["FIRE"]["I2U"];
	end

	VUHDO_SPEC_LAYOUTS["selected"] = aName;
	VUHDO_Msg("按鍵配置 \"" .. aName .. "\" 已載入。");

end



--
function VUHDO_activateLayout(aName)

	VUHDO_activateLayoutNoInit(aName);

	VUHDO_loadVariables();
	VUHDO_initAllBurstCaches();
	VUHDO_initFromSpellbook();
	VUHDO_registerAllBouquets(false);
	VUHDO_initBuffs();
	VUHDO_initDebuffs();
	VUHDO_initKeyboardMacros();
	VUHDO_timeReloadUI(1);

end
