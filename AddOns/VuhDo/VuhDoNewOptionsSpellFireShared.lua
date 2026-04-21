--
local tLayoutAnchors;
local tLayout;
function VUHDO_activateLayoutLoadAurasForPanel(aName, aPanelNum)

	if not aName or not aPanelNum or not VUHDO_SPELL_LAYOUTS or not VUHDO_SPELL_LAYOUTS[aName] or
		not VUHDO_SPELL_CONFIG or not VUHDO_SPELL_CONFIG["IS_LOAD_AURAS"] then

		return;
	end

	tLayout = VUHDO_SPELL_LAYOUTS[aName];

	if tLayout["AURAS"] and tLayout["AURAS"][aPanelNum] then
		if VUHDO_SPELL_CONFIG["IS_LOAD_AURAS_ONLY_ANCHORS"] then
			tLayoutAnchors = VUHDO_decompressOrCopy(tLayout["AURAS"][aPanelNum]);

			for tAnchorId, tAnchorConfig in pairs(tLayoutAnchors) do
				if VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"][tAnchorId] then
					VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"][tAnchorId]["groupId"] = tAnchorConfig["groupId"];
				end
			end
		else
			VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"] = VUHDO_decompressOrCopy(tLayout["AURAS"][aPanelNum]);
		end
	end

	if aPanelNum == 1 then
		if tLayout["AURA_GROUPS"] then
			VUHDO_CONFIG["AURA_GROUPS"] = VUHDO_decompressOrCopy(tLayout["AURA_GROUPS"]);
		end

		if tLayout["AURA_GROUP_DISABLED"] then
			VUHDO_CONFIG["AURA_GROUP_DISABLED"] = VUHDO_decompressOrCopy(tLayout["AURA_GROUP_DISABLED"]);
		end
	end

	return;

end



--
function VUHDO_activateLayoutNoInit(aName)

	VUHDO_invalidateBindingCodeCache();

	VUHDO_SPELL_ASSIGNMENTS = VUHDO_decompressOrCopy(VUHDO_SPELL_LAYOUTS[aName]["MOUSE"]);
	VUHDO_HOSTILE_SPELL_ASSIGNMENTS = VUHDO_decompressOrCopy(VUHDO_SPELL_LAYOUTS[aName]["HOSTILE_MOUSE"]);

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_activateLayoutLoadAurasForPanel(aName, tPanelNum);
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

	VUHDO_incrementAuraAnchorConfigVersion();

	VUHDO_loadVariables();
	VUHDO_initAllBurstCaches();
	VUHDO_initFromSpellbook();
	VUHDO_registerAllBouquets(false);
	VUHDO_initBuffs();
	VUHDO_initDebuffs();
	VUHDO_initKeyboardMacros();
	VUHDO_timeReloadUI(1);

end
