local _;

local pairs = pairs;
local ipairs = ipairs;
local type = type;
local tonumber = tonumber;
local tostring = tostring;
local tinsert = table.insert;
local tconcat = table.concat;
local twipe = table.wipe;
local tsort = table.sort;
local format = string.format;
local gsub = string.gsub;
local strmatch = string.match;
local strfind = string.find;

VUHDO_SYNC_SOURCE_PROFILE = nil;
VUHDO_SYNC_SETTINGS_SEL = { };
VUHDO_SYNC_DEST_SEL = { };
VUHDO_SYNC_OPTIONS = { ["FANOUT"] = false };
VUHDO_SYNC_DEST_TREE = nil;
VUHDO_SYNC_SETTINGS_TREE = nil;

local sSettingsTree;
local sNodeById = { };
local sDestPanelMap = { };
local sSourceLive = { };
local sDestLive = { };
local sEmpty = { };
local sPartSummary = { };



--
local tClean;
local function VUHDO_syncCleanLabel(aText)

	tClean = aText or "";
	tClean = gsub(tClean, "\n", " ");

	return tClean;

end



--
local tPerPanelTabs;
local function VUHDO_syncBuildPerPanelTabs()

	tPerPanelTabs = { };

	tinsert(tPerPanelTabs, { ["suffix"] = "BASIC", ["label"] = VUHDO_I18N_GENERAL, ["roots"] = {
		"PANEL_SETUP.#PNUM#.SCALING.maxColumnsWhenStructured",
		"PANEL_SETUP.#PNUM#.SCALING.arrangeHorizontal",
		"PANEL_SETUP.#PNUM#.SCALING.alignBottom",
		"PANEL_SETUP.#PNUM#.SCALING.ommitEmptyWhenStructured",
		"PANEL_SETUP.#PNUM#.SCALING.isPlayerOnTop",
		"PANEL_SETUP.#PNUM#.SCALING.maxRowsWhenLoose",
		"PANEL_SETUP.#PNUM#.MODEL",
		"PANEL_SETUP.#PNUM#.POSITION",
		"PANEL_SETUP.#PNUM#.PANEL_COLOR.BACK",
		"PANEL_SETUP.#PNUM#.PANEL_COLOR.BORDER",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "SIZE", ["label"] = VUHDO_I18N_SIZING, ["roots"] = {
		"PANEL_SETUP.#PNUM#.SCALING.scale",
		"PANEL_SETUP.#PNUM#.SCALING.columnSpacing",
		"PANEL_SETUP.#PNUM#.SCALING.rowSpacing",
		"PANEL_SETUP.#PNUM#.SCALING.borderGapX",
		"PANEL_SETUP.#PNUM#.SCALING.borderGapY",
		"PANEL_SETUP.#PNUM#.SCALING.barHeight",
		"PANEL_SETUP.#PNUM#.SCALING.barWidth",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "BARS", ["label"] = VUHDO_I18N_BARS, ["roots"] = {
		"PANEL_SETUP.#PNUM#.PANEL_COLOR.barTexture",
		"PANEL_SETUP.#PNUM#.SCALING.manaBarHeight",
		"PANEL_SETUP.#PNUM#.SCALING.sideLeftWidth",
		"PANEL_SETUP.#PNUM#.SCALING.sideRightWidth",
		"PANEL_SETUP.#PNUM#.SCALING.isDamFlash",
		"PANEL_SETUP.#PNUM#.SCALING.damFlashFactor",
		"INDICATOR_CONFIG.#PNUM#.BOUQUETS.HEALTH_BAR",
		"INDICATOR_CONFIG.#PNUM#.CUSTOM.HEALTH_BAR",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "HEADER", ["label"] = VUHDO_I18N_HEADERS, ["roots"] = {
		"PANEL_SETUP.#PNUM#.SCALING.headerHeight",
		"PANEL_SETUP.#PNUM#.SCALING.headerWidth",
		"PANEL_SETUP.#PNUM#.SCALING.headerSpacing",
		"PANEL_SETUP.#PNUM#.SCALING.showHeaders",
		"PANEL_SETUP.#PNUM#.PANEL_COLOR.HEADER",
		"PANEL_SETUP.#PNUM#.PANEL_COLOR.classColorsHeader",
		"PANEL_SETUP.#PNUM#.PANEL_COLOR.classColorsBackHeader",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "TARGET", ["label"] = VUHDO_I18N_TARGETS, ["roots"] = {
		"PANEL_SETUP.#PNUM#.SCALING.targetSpacing",
		"PANEL_SETUP.#PNUM#.SCALING.showTarget",
		"PANEL_SETUP.#PNUM#.SCALING.targetWidth",
		"PANEL_SETUP.#PNUM#.SCALING.totSpacing",
		"PANEL_SETUP.#PNUM#.SCALING.showTot",
		"PANEL_SETUP.#PNUM#.SCALING.totWidth",
		"PANEL_SETUP.#PNUM#.SCALING.targetOrientation",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "TOOLTIP", ["label"] = VUHDO_I18N_TOOLTIPS, ["roots"] = {
		"PANEL_SETUP.#PNUM#.TOOLTIP",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "TEXT", ["label"] = VUHDO_I18N_TEXT, ["roots"] = {
		"PANEL_SETUP.#PNUM#.ID_TEXT",
		"PANEL_SETUP.#PNUM#.LIFE_TEXT",
		"PANEL_SETUP.#PNUM#.PANEL_COLOR.TEXT",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "AURAS", ["label"] = VUHDO_I18N_AURAS, ["roots"] = {
		"PANEL_SETUP.#PNUM#.AURA_ANCHORS",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "PRIVATE_AURAS", ["label"] = VUHDO_I18N_PRIVATE_AURAS_RADIO, ["roots"] = {
		"PANEL_SETUP.#PNUM#.PRIVATE_AURA",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "INDICATORS", ["label"] = VUHDO_I18N_INDICATORS, ["roots"] = {
		"INDICATOR_CONFIG.#PNUM#.BOUQUETS",
		"INDICATOR_CONFIG.#PNUM#.CUSTOM",
		"INDICATOR_CONFIG.#PNUM#.TEXT_INDICATORS",
	} });

	tinsert(tPerPanelTabs, { ["suffix"] = "MISC", ["label"] = VUHDO_I18N_MISC, ["roots"] = {
		"PANEL_SETUP.#PNUM#.RAID_ICON",
		"PANEL_SETUP.#PNUM#.OVERHEAL_TEXT",
		"PANEL_SETUP.#PNUM#.frameStrata",
	} });

	return tPerPanelTabs;

end



--
local tPanelBranch;
local tPanelNode;
local tTabNode;
local tTabs;
local function VUHDO_syncBuildPanelBranch()

	tPanelBranch = { ["id"] = "PANEL_SETTINGS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_SYNC_SEC_PANELS), ["children"] = { } };
	tTabs = VUHDO_syncBuildPerPanelTabs();

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		tPanelNode = { ["id"] = "PANEL." .. tPanelNum, ["label"] = format(VUHDO_I18N_SYNC_PANEL_N, tPanelNum), ["children"] = { } };

		for tTabIndex = 1, #tTabs do
			tTabNode = {
				["id"] = "PANEL." .. tPanelNum .. "." .. tTabs[tTabIndex]["suffix"],
				["label"] = VUHDO_syncCleanLabel(tTabs[tTabIndex]["label"]),
				["srcPanel"] = tPanelNum,
				["roots"] = tTabs[tTabIndex]["roots"],
			};

			tinsert(tPanelNode["children"], tTabNode);
		end

		tinsert(tPanelBranch["children"], tPanelNode);
	end

	return tPanelBranch;

end



--
local tStateRoots;
local tDebuffTypes;
local function VUHDO_syncBuildColorStateRoots()

	tStateRoots = {
		"PANEL_SETUP.BAR_COLORS.CLUSTER_FAIR",
		"PANEL_SETUP.BAR_COLORS.CLUSTER_GOOD",
		"PANEL_SETUP.BAR_COLORS.DEBUFF_BAR_GLOW",
		"PANEL_SETUP.BAR_COLORS.DEBUFF_ICON_GLOW",
		"PANEL_SETUP.BAR_COLORS.showDispelOverlay",
		"PANEL_SETUP.BAR_COLORS.dispelIndicatorType",
		"PANEL_SETUP.BAR_COLORS.DEAD",
		"PANEL_SETUP.BAR_COLORS.OFFLINE",
		"PANEL_SETUP.BAR_COLORS.CHARMED",
		"PANEL_SETUP.BAR_COLORS.GCD_BAR",
		"PANEL_SETUP.BAR_COLORS.DIRECTION",
	};

	tDebuffTypes = {
		VUHDO_DEBUFF_TYPE_NONE, VUHDO_DEBUFF_TYPE_POISON, VUHDO_DEBUFF_TYPE_DISEASE,
		VUHDO_DEBUFF_TYPE_CURSE, VUHDO_DEBUFF_TYPE_MAGIC, VUHDO_DEBUFF_TYPE_CUSTOM,
		VUHDO_DEBUFF_TYPE_BLEED, VUHDO_DEBUFF_TYPE_ENRAGE,
	};

	for tCnt = 1, #tDebuffTypes do
		tinsert(tStateRoots, "PANEL_SETUP.BAR_COLORS.DEBUFF" .. tDebuffTypes[tCnt]);
	end

	return tStateRoots;

end



--
local tConfigRoots;
local function VUHDO_syncBuildBuffConfigRoots()

	tConfigRoots = { "BUFF_ORDER" };

	for tBuffKey in pairs(VUHDO_BUFF_SETTINGS or sEmpty) do
		if "CONFIG" ~= tBuffKey then
			tinsert(tConfigRoots, "BUFF_SETTINGS." .. tBuffKey);
		end
	end

	return tConfigRoots;

end



--
local function VUHDO_syncBuildGeneralCat()

	return { ["id"] = "GENERAL", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_GENERAL_SHORT), ["children"] = {
		{ ["id"] = "GENERAL.BASIC", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_GENERAL), ["roots"] = {
			"CONFIG.LOCK_PANELS", "CONFIG.LOCK_CLICKS_THROUGH", "CONFIG.HIDE_PANELS_SOLO", "CONFIG.HIDE_PANELS_PARTY",
			"CONFIG.HIDE_EMPTY_BUTTONS", "CONFIG.HIDE_EMPTY_PANELS", "CONFIG.HIDE_PANELS_PET_BATTLE",
			"CONFIG.OMIT_MAIN_TANKS", "CONFIG.OMIT_DFT_MTS", "CONFIG.OMIT_PLAYER_TARGETS",
			"CONFIG.OMIT_OWN_GROUP", "CONFIG.OMIT_FOCUS", "CONFIG.OMIT_MAIN_ASSIST", "CONFIG.OMIT_SELF",
			"CONFIG.OMIT_TARGET", "CONFIG.MODE", "CONFIG.MAX_EMERGENCIES", "CONFIG.EMERGENCY_TRIGGER",
		} },
		{ ["id"] = "GENERAL.SCANNERS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_SCANNERS), ["roots"] = {
			"CONFIG.UPDATE_HOTS_MS", "CONFIG.SCAN_RANGE", "CONFIG.RANGE_CHECK_DELAY",
			"CONFIG.RANGE_PESSIMISTIC", "CONFIG.RANGE_SPELL", "CONFIG.DIRECTION", "CONFIG.IS_SCAN_TALENTS",
		} },
		{ ["id"] = "GENERAL.THREAT", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_THREAT), ["roots"] = {
			"CONFIG.THREAT", "CONFIG.SHOW_INCOMING", "CONFIG.SHOW_OVERHEAL", "CONFIG.SHOW_OWN_INCOMING",
			"CONFIG.SHOW_TEXT_OVERHEAL", "CONFIG.SHOW_SHIELD_BAR", "CONFIG.SHOW_OVERSHIELD_BAR",
			"CONFIG.SHOW_HEAL_ABSORB_BAR", "CONFIG.SHOW_HEALTH_LOSS_BAR",
		} },
		{ ["id"] = "GENERAL.MISC", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_MISC), ["roots"] = {
			"CONFIG.BLIZZ_UI_HIDE_PLAYER", "CONFIG.BLIZZ_UI_HIDE_PARTY", "CONFIG.BLIZZ_UI_HIDE_TARGET",
			"CONFIG.BLIZZ_UI_HIDE_PET", "CONFIG.BLIZZ_UI_HIDE_FOCUS", "CONFIG.BLIZZ_UI_HIDE_RAID",
			"CONFIG.BLIZZ_UI_HIDE_RAID_MGR", "CONFIG.BLIZZ_UI_HIDE_BOSS", "CONFIG.BLIZZ_UI_HIDE_ARENA",
			"CONFIG.ON_MOUSE_UP", "CONFIG.IS_SHOW_GCD", "CONFIG.IS_DC_SHIELD_DISABLED",
			"CONFIG.IS_READY_CHECK_DISABLED", "CONFIG.IS_CLIQUE_COMPAT_MODE",
			"CONFIG.IS_CLIQUE_PASSTHROUGH", "CONFIG.IS_USE_BUTTON_FACADE",
			"CONFIG.RES_ANNOUNCE_TEXT", "CONFIG.RES_ANNOUNCE_MASS_TEXT", "CONFIG.RES_IS_SHOW_TEXT",
		} },
	} };

end



--
local function VUHDO_syncBuildSpellCat()

	return { ["id"] = "SPELL", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_SPELLS), ["children"] = {
		{ ["id"] = "SPELL.MISC", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_MISC), ["roots"] = {
			"SPELL_CONFIG", "CONFIG.SMARTCAST_RESURRECT", "CONFIG.SMARTCAST_CLEANSE", "CONFIG.SMARTCAST_BUFF",
		} },
	} };

end



--
local function VUHDO_syncBuildBuffsCat()

	return { ["id"] = "BUFFS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_BUFFS), ["children"] = {
		{ ["id"] = "BUFFS.CONFIG", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_CONFIG), ["roots"] = VUHDO_syncBuildBuffConfigRoots() },
		{ ["id"] = "BUFFS.GENERAL", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_GENERAL), ["roots"] = {
			"BUFF_SETTINGS.CONFIG.SCALE", "BUFF_SETTINGS.CONFIG.PANEL_MAX_BUFFS", "BUFF_SETTINGS.CONFIG.REFRESH_SECS",
			"BUFF_SETTINGS.CONFIG.HIDE_OUT_OF_COMBAT", "BUFF_SETTINGS.CONFIG.HIDE_CHARGES", "BUFF_SETTINGS.CONFIG.SHOW_LABEL",
			"BUFF_SETTINGS.CONFIG.COMPACT", "BUFF_SETTINGS.CONFIG.SHOW", "BUFF_SETTINGS.CONFIG.POSITION",
		} },
		{ ["id"] = "BUFFS.COLORS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_COLORS), ["roots"] = {
			"BUFF_SETTINGS.CONFIG.SWATCH_COLOR_BUFF_OKAY", "BUFF_SETTINGS.CONFIG.SWATCH_COLOR_BUFF_LOW",
			"BUFF_SETTINGS.CONFIG.SWATCH_COLOR_BUFF_OUT", "BUFF_SETTINGS.CONFIG.SWATCH_COLOR_BUFF_COOLDOWN",
			"BUFF_SETTINGS.CONFIG.PANEL_BG_COLOR", "BUFF_SETTINGS.CONFIG.SWATCH_BORDER_COLOR",
			"BUFF_SETTINGS.CONFIG.PANEL_BORDER_COLOR", "BUFF_SETTINGS.CONFIG.BAR_COLORS_IN_FIGHT",
			"BUFF_SETTINGS.CONFIG.BAR_COLORS_TEXT", "BUFF_SETTINGS.CONFIG.BAR_COLORS_BACKGROUND",
		} },
		{ ["id"] = "BUFFS.REBUFF", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_REBUFF), ["roots"] = {
			"BUFF_SETTINGS.CONFIG.HIGHLIGHT_COOLDOWN", "BUFF_SETTINGS.CONFIG.REBUFF_AT_PERCENT",
			"BUFF_SETTINGS.CONFIG.REBUFF_MIN_MINUTES", "BUFF_SETTINGS.CONFIG.WHEEL_SMART_BUFF",
		} },
	} };

end



--
local function VUHDO_syncBuildAurasCat()

	return { ["id"] = "AURAS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_AURAS), ["children"] = {
		{ ["id"] = "AURAS.GROUPS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_GROUPS), ["roots"] = {
			"CONFIG.AURA_GROUPS", "CONFIG.AURA_GROUP_DISABLED",
		} },
	} };

end



--
local function VUHDO_syncBuildColorsCat()

	return { ["id"] = "COLORS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_COLORS), ["children"] = {
		{ ["id"] = "COLORS.STATES", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_STATES), ["roots"] = VUHDO_syncBuildColorStateRoots() },
		{ ["id"] = "COLORS.MODES", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_MODES), ["roots"] = {
			"PANEL_SETUP.BAR_COLORS.LIFE_LEFT", "PANEL_SETUP.BAR_COLORS.EMERGENCY",
			"PANEL_SETUP.BAR_COLORS.NO_EMERGENCY", "PANEL_SETUP.BAR_COLORS.OUTRANGED",
			"PANEL_SETUP.BAR_COLORS.OVERSHIELD", "PANEL_SETUP.BAR_COLORS.HEAL_ABSORB",
			"PANEL_SETUP.BAR_COLORS.HEALTH_LOSS", "PANEL_SETUP.BAR_COLORS.SHIELD",
			"PANEL_SETUP.BAR_COLORS.INCOMING", "PANEL_SETUP.BAR_COLORS.IRRELEVANT",
			"PANEL_SETUP.BAR_COLORS.OVERHEAL_TEXT",
			"PANEL_SETUP.PANEL_COLOR.BARS", "PANEL_SETUP.PANEL_COLOR.isSolidGradient",
			"PANEL_SETUP.PANEL_COLOR.solidMaxColor",
		} },
		{ ["id"] = "COLORS.TEXT", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_TEXT), ["roots"] = {
			"PANEL_SETUP.PANEL_COLOR.TEXT", "PANEL_SETUP.PANEL_COLOR.HEALTH_TEXT",
			"PANEL_SETUP.PANEL_COLOR.classColorsName",
		} },
		{ ["id"] = "COLORS.POWERS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_POWERS), ["roots"] = {
			"POWER_TYPE_COLORS",
		} },
		{ ["id"] = "COLORS.AURAS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_AURAS), ["roots"] = {
			"PANEL_SETUP.AURA_DEFAULTS", "PANEL_SETUP.BAR_COLORS.AURA_BAR_DEFAULT",
			"PANEL_SETUP.BAR_COLORS.AURA_STACK_TRIANGLE",
		} },
		{ ["id"] = "COLORS.RAID_ICONS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_RAID_ICON), ["roots"] = {
			"PANEL_SETUP.BAR_COLORS.RAID_ICONS", "PANEL_SETUP.RAID_ICON_FILTER",
		} },
		{ ["id"] = "COLORS.TARGETS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_TARGETS), ["roots"] = {
			"PANEL_SETUP.BAR_COLORS.TARGET", "PANEL_SETUP.BAR_COLORS.TARGET_FRIEND",
			"PANEL_SETUP.BAR_COLORS.TARGET_NEUTRAL", "PANEL_SETUP.BAR_COLORS.TARGET_ENEMY",
			"PANEL_SETUP.BAR_COLORS.TAPPED",
		} },
	} };

end



--
local function VUHDO_syncRegisterNode(aNode)

	sNodeById[aNode["id"]] = aNode;

	if aNode["children"] then
		for tCnt = 1, #aNode["children"] do
			VUHDO_syncRegisterNode(aNode["children"][tCnt]);
		end
	end

	return;

end



--
local tRoot;
local function VUHDO_syncBuildCatalog()

	twipe(sNodeById);

	tRoot = { ["id"] = "ALL_SETTINGS", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_SYNC_ALL_SETTINGS), ["children"] = { } };

	tinsert(tRoot["children"], VUHDO_syncBuildGeneralCat());
	tinsert(tRoot["children"], VUHDO_syncBuildSpellCat());
	tinsert(tRoot["children"], VUHDO_syncBuildBuffsCat());
	tinsert(tRoot["children"], VUHDO_syncBuildAurasCat());
	tinsert(tRoot["children"], VUHDO_syncBuildColorsCat());
	tinsert(tRoot["children"], VUHDO_syncBuildPanelBranch());

	VUHDO_syncRegisterNode(tRoot);

	return { tRoot };

end



--
function VUHDO_syncSettingsTreeProvider()

	if not sSettingsTree then
		sSettingsTree = VUHDO_syncBuildCatalog();
	end

	return sSettingsTree;

end



--
local function VUHDO_syncDestLeafId(aName, aPanel)

	return "DP:" .. aName .. "#" .. aPanel;

end



--
local tDestRoot;
local tProfileNode;
local tNames;
local function VUHDO_syncDestTreeProvider()

	twipe(sDestPanelMap);

	tNames = { };

	for _, tProfile in ipairs(VUHDO_PROFILES) do
		tinsert(tNames, tProfile["NAME"]);
	end

	tsort(tNames, function(aName, anotherName) return (aName or "") < (anotherName or ""); end);

	tDestRoot = { ["id"] = "ALL_PROFILES", ["label"] = VUHDO_syncCleanLabel(VUHDO_I18N_SYNC_ALL_PROFILES), ["children"] = { } };

	for tNameIndex = 1, #tNames do
		tProfileNode = { ["id"] = "DPROF:" .. tNames[tNameIndex], ["label"] = tNames[tNameIndex], ["children"] = { } };

		for tPanelNum = 1, VUHDO_MAX_PANELS do
			sDestPanelMap[VUHDO_syncDestLeafId(tNames[tNameIndex], tPanelNum)] = { ["profile"] = tNames[tNameIndex], ["panel"] = tPanelNum };

			tinsert(tProfileNode["children"], {
				["id"] = VUHDO_syncDestLeafId(tNames[tNameIndex], tPanelNum),
				["label"] = format(VUHDO_I18N_SYNC_PANEL_N, tPanelNum),
			});
		end

		tinsert(tDestRoot["children"], tProfileNode);
	end

	return { tDestRoot };

end



--
local function VUHDO_syncResolveKey(aToken)

	return tonumber(aToken) or aToken;

end



--
local tTokens;
local function VUHDO_syncResolveTokens(aRoot, aPanel)

	tTokens = VUHDO_splitString(aRoot, ".");

	if aPanel then
		for tCnt = 1, #tTokens do
			if tTokens[tCnt] == "#PNUM#" then
				tTokens[tCnt] = tostring(aPanel);
			end
		end
	end

	return tTokens;

end



--
local function VUHDO_syncMergeInto(aSource, aDest)

	if type(aDest) ~= "table" then
		aDest = { };
	end

	for tKey, tValue in pairs(aSource) do
		if type(tValue) == "table" then
			aDest[tKey] = VUHDO_syncMergeInto(tValue, aDest[tKey]);
		else
			aDest[tKey] = tValue;
		end
	end

	return aDest;

end



--
local tSrcVal;
local tParent;
local tKey;
local tDestPart;
local function VUHDO_syncCopyResolved(aSourceParts, aDestParts, aSrcTokens, aDestTokens, anIsReplace)

	tSrcVal = aSourceParts;

	for tCnt = 1, #aSrcTokens do
		if type(tSrcVal) ~= "table" then
			return false;
		end

		tSrcVal = tSrcVal[VUHDO_syncResolveKey(aSrcTokens[tCnt])];
	end

	if tSrcVal == nil then
		return false;
	end

	if #aDestTokens == 1 then
		tDestPart = aDestParts[aDestTokens[1]];

		if type(tDestPart) ~= "table" or type(tSrcVal) ~= "table" then
			return false;
		end

		if anIsReplace then
			twipe(tDestPart);
		end

		VUHDO_syncMergeInto(tSrcVal, tDestPart);

		return true;
	end

	tParent = aDestParts;

	for tCnt = 1, #aDestTokens - 1 do
		tKey = VUHDO_syncResolveKey(aDestTokens[tCnt]);

		if type(tParent[tKey]) ~= "table" then
			tParent[tKey] = { };
		end

		tParent = tParent[tKey];
	end

	tKey = VUHDO_syncResolveKey(aDestTokens[#aDestTokens]);

	if type(tSrcVal) ~= "table" then
		tParent[tKey] = tSrcVal;
	elseif anIsReplace then
		tParent[tKey] = VUHDO_deepCopyTable(tSrcVal);
	else
		tParent[tKey] = VUHDO_syncMergeInto(tSrcVal, tParent[tKey]);
	end

	return true;

end



--
local tSrcProfile;
local function VUHDO_syncGetSourceParts(aSourceName)

	if aSourceName == VUHDO_CONFIG["CURRENT_PROFILE"] then
		sSourceLive["CONFIG"] = VUHDO_CONFIG;
		sSourceLive["PANEL_SETUP"] = VUHDO_PANEL_SETUP;
		sSourceLive["POWER_TYPE_COLORS"] = VUHDO_POWER_TYPE_COLORS;
		sSourceLive["SPELL_CONFIG"] = VUHDO_SPELL_CONFIG;
		sSourceLive["BUFF_SETTINGS"] = VUHDO_BUFF_SETTINGS;
		sSourceLive["BUFF_ORDER"] = VUHDO_BUFF_ORDER;
		sSourceLive["INDICATOR_CONFIG"] = VUHDO_INDICATOR_CONFIG;

		return sSourceLive;
	end

	_, tSrcProfile = VUHDO_getProfileNamed(aSourceName);

	return tSrcProfile;

end



--
local function VUHDO_syncGetLiveParts()

	sDestLive["CONFIG"] = VUHDO_CONFIG;
	sDestLive["PANEL_SETUP"] = VUHDO_PANEL_SETUP;
	sDestLive["POWER_TYPE_COLORS"] = VUHDO_POWER_TYPE_COLORS;
	sDestLive["SPELL_CONFIG"] = VUHDO_SPELL_CONFIG;
	sDestLive["BUFF_SETTINGS"] = VUHDO_BUFF_SETTINGS;
	sDestLive["BUFF_ORDER"] = VUHDO_BUFF_ORDER;
	sDestLive["INDICATOR_CONFIG"] = VUHDO_INDICATOR_CONFIG;

	return sDestLive;

end



--
local tSnap;
local function VUHDO_syncSnapshotParts(aParts)

	tSnap = { };

	for tKey, tValue in pairs(aParts) do
		tSnap[tKey] = VUHDO_deepCopyTable(tValue);
	end

	return tSnap;

end



--
local tGlobalNodes = { };
local tPanelNodes = { };
local tSelectedSrcPanels = { };
local tSrcPanelCount;
local tSelNode;
local function VUHDO_syncCollectSelectedNodes()

	VUHDO_syncSettingsTreeProvider();

	twipe(tGlobalNodes);
	twipe(tPanelNodes);
	twipe(tSelectedSrcPanels);

	for tId in pairs(VUHDO_SYNC_SETTINGS_SEL) do
		tSelNode = sNodeById[tId];

		if tSelNode and tSelNode["roots"] then
			if tSelNode["srcPanel"] then
				tinsert(tPanelNodes, tSelNode);
				tSelectedSrcPanels[tSelNode["srcPanel"]] = true;
			else
				tinsert(tGlobalNodes, tSelNode);
			end
		end
	end

	tSrcPanelCount = 0;

	for _ in pairs(tSelectedSrcPanels) do
		tSrcPanelCount = tSrcPanelCount + 1;
	end

	return;

end



--
local tDestPanels = { };
local tDestProfiles = { };
local tDestInfo;
local function VUHDO_syncCollectDestinations()

	VUHDO_syncDestTreeProvider();

	twipe(tDestPanels);
	twipe(tDestProfiles);

	for tId in pairs(VUHDO_SYNC_DEST_SEL) do
		tDestInfo = sDestPanelMap[tId];

		if tDestInfo then
			tinsert(tDestPanels, tDestInfo);
			tDestProfiles[tDestInfo["profile"]] = true;
		end
	end

	return;

end



local sSyncRollupByLeaf = { };
local sSyncRollupLevel = -1;
local sRollupCounts = { };



--
local tWalkNode;
local tRollupAnchor;
local tSettingsRoots;
local tRollupId;
local function VUHDO_syncWalkRollup(aNodes, aDepth, aAnchor, aLevel)

	for tRollupCnt = 1, #aNodes do
		tWalkNode = aNodes[tRollupCnt];
		tRollupAnchor = aAnchor;

		if aDepth == aLevel then
			tRollupAnchor = tWalkNode;
		end

		if tWalkNode["roots"] then
			sSyncRollupByLeaf[tWalkNode["id"]] = (tRollupAnchor or tWalkNode)["id"];
		end

		if tWalkNode["children"] then
			VUHDO_syncWalkRollup(tWalkNode["children"], aDepth + 1, tRollupAnchor, aLevel);
		end
	end

	return;

end



--
local function VUHDO_syncInitSummaryRollup(aLevel)

	if sSyncRollupLevel == aLevel then
		return;
	end

	twipe(sSyncRollupByLeaf);

	tSettingsRoots = VUHDO_syncSettingsTreeProvider();

	if not tSettingsRoots[1] or not tSettingsRoots[1]["children"] then
		return;
	end

	VUHDO_syncWalkRollup(tSettingsRoots[1]["children"], 1, nil, aLevel);

	sSyncRollupLevel = aLevel;

	return;

end



--
local tNodeParentLabel;
local tNodeLabel;
local function VUHDO_syncNodeDisplayLabel(aNode, aParent)

	tNodeLabel = VUHDO_syncCleanLabel(aNode["label"]);

	if aParent then
		tNodeParentLabel = VUHDO_syncCleanLabel(aParent["label"]);

		if tNodeParentLabel ~= tNodeLabel then
			return tNodeParentLabel .. " / " .. tNodeLabel;
		end
	end

	return tNodeLabel;

end



--
local function VUHDO_syncWalkSummaryOutput(aNodes, aDepth, aParent)

	for tOutputCnt = 1, #aNodes do
		tWalkNode = aNodes[tOutputCnt];

		if sRollupCounts[tWalkNode["id"]] then
			tinsert(sPartSummary, format("%s: %d", VUHDO_syncNodeDisplayLabel(tWalkNode, aParent), sRollupCounts[tWalkNode["id"]]));
		end

		if tWalkNode["children"] then
			VUHDO_syncWalkSummaryOutput(tWalkNode["children"], aDepth + 1, tWalkNode);
		end
	end

	return;

end



--
local tLevel;
local function VUHDO_syncFormatNodeSummary(aNodeCounts)

	twipe(sPartSummary);
	twipe(sRollupCounts);

	tLevel = tonumber(VUHDO_CONFIG["SYNC_SUMMARY_LEVEL"]) or 1;

	if tLevel < 1 then
		tLevel = 1;
	end

	VUHDO_syncInitSummaryRollup(tLevel);

	for tRollupLeafId, tRollupLeafCount in pairs(aNodeCounts) do
		tRollupId = sSyncRollupByLeaf[tRollupLeafId];

		if tRollupId then
			sRollupCounts[tRollupId] = (sRollupCounts[tRollupId] or 0) + tRollupLeafCount;
		end
	end

	tSettingsRoots = VUHDO_syncSettingsTreeProvider();

	if tSettingsRoots[1] and tSettingsRoots[1]["children"] then
		VUHDO_syncWalkSummaryOutput(tSettingsRoots[1]["children"], 1, nil);
	end

	if #sPartSummary == 0 then
		return nil;
	end

	return tconcat(sPartSummary, ", ");

end



--
local tSource;
local tDestParts;
local tTouched;
local tCount;
local tNodeCounts;
local tSyncNode;
local tEntry;
local tIndex;
local tIsLive;
local tNeedReload;
local tSrcTokens;
local tDestTokens;
local tNodeSrc;
local tDestPanel;
local tIsFanOut;
local tRootPath;
local tPosTable;
local tPartDetail;
local function VUHDO_syncApplyToProfile(aDestName, aSourceName, aSourceParts, anIsReplace)

	tIndex, tEntry = VUHDO_getProfileNamedCompressed(aDestName);

	if not tIndex then
		VUHDO_Msg(format(VUHDO_I18N_PROFILE_NOT_EXISTS, aDestName));
		return false;
	end

	if tEntry["LOCKED"] or tEntry["HARDLOCKED"] then
		VUHDO_Msg(format(VUHDO_I18N_SYNC_PROFILE_LOCKED, aDestName));
		return false;
	end

	tIsLive = aDestName == VUHDO_CONFIG["CURRENT_PROFILE"];

	if tIsLive then
		tDestParts = VUHDO_syncGetLiveParts();
	else
		_, tDestParts = VUHDO_getProfileNamed(aDestName);
	end

	tTouched = { };
	tNodeCounts = { };
	tCount = 0;

	if aDestName ~= aSourceName then
		for tNodeIndex = 1, #tGlobalNodes do
			tSyncNode = tGlobalNodes[tNodeIndex];

			for tRootIndex = 1, #tSyncNode["roots"] do
				tSrcTokens = VUHDO_syncResolveTokens(tSyncNode["roots"][tRootIndex]);

				if VUHDO_syncCopyResolved(aSourceParts, tDestParts, tSrcTokens, tSrcTokens, anIsReplace) then
					tTouched[tSrcTokens[1]] = true;
					tCount = tCount + 1;
					tNodeCounts[tSyncNode["id"]] = (tNodeCounts[tSyncNode["id"]] or 0) + 1;
				end
			end
		end
	end

	tIsFanOut = VUHDO_SYNC_OPTIONS["FANOUT"] and tSrcPanelCount == 1;

	for tDestIndex = 1, #tDestPanels do
		if tDestPanels[tDestIndex]["profile"] == aDestName then
			for tNodeIndex = 1, #tPanelNodes do
				tSyncNode = tPanelNodes[tNodeIndex];
				tNodeSrc = tSyncNode["srcPanel"];
				tDestPanel = tDestPanels[tDestIndex]["panel"];

				if (tIsFanOut or tNodeSrc == tDestPanel)
					and not (aDestName == aSourceName and tNodeSrc == tDestPanel) then

					for tRootIndex = 1, #tSyncNode["roots"] do
						tRootPath = tSyncNode["roots"][tRootIndex];
						tSrcTokens = VUHDO_syncResolveTokens(tRootPath, tNodeSrc);
						tDestTokens = VUHDO_syncResolveTokens(tRootPath, tDestPanel);

						if VUHDO_syncCopyResolved(aSourceParts, tDestParts, tSrcTokens, tDestTokens, anIsReplace) then
							tTouched[tSrcTokens[1]] = true;
							tCount = tCount + 1;
							tNodeCounts[tSyncNode["id"]] = (tNodeCounts[tSyncNode["id"]] or 0) + 1;

							if "PANEL_SETUP.#PNUM#.POSITION" == tRootPath then
								tPosTable = tDestParts["PANEL_SETUP"][tDestPanel] and tDestParts["PANEL_SETUP"][tDestPanel]["POSITION"];

								if tPosTable then
									if not tEntry["PANEL_POSITIONS"] then
										tEntry["PANEL_POSITIONS"] = { };
									end

									tEntry["PANEL_POSITIONS"][tDestPanel] = VUHDO_deepCopyTable(tPosTable);
								end
							end
						end
					end
				end
			end
		end
	end

	if tTouched["INDICATOR_CONFIG"] then
		if not tDestParts["INDICATOR_CONFIG"] then
			tDestParts["INDICATOR_CONFIG"] = { };
		end

		tDestParts["INDICATOR_CONFIG"]["VERSION"] = tDestParts["INDICATOR_CONFIG"]["VERSION"] or 3;
		tDestParts["INDICATOR_CONFIG"]["BOUQUETS"] = nil;
		tDestParts["INDICATOR_CONFIG"]["CUSTOM"] = nil;
		tDestParts["INDICATOR_CONFIG"]["TEXT_INDICATORS"] = nil;
	end

	for tPart in pairs(tTouched) do
		tEntry[tPart] = VUHDO_compressTable(tDestParts[tPart]);
	end

	if tIsLive then
		tNeedReload = true;
	end

	tPartDetail = VUHDO_syncFormatNodeSummary(tNodeCounts);

	if tPartDetail then
		VUHDO_Msg(format(VUHDO_I18N_SYNC_PROFILE_DONE, tCount, aDestName, tPartDetail));
	else
		VUHDO_Msg(format(VUHDO_I18N_SYNC_PROFILE_DONE, tCount, aDestName, VUHDO_I18N_SYNC_NO_DETAIL));
	end

	return true;

end



--
function VUHDO_syncApply(anIsReplace)

	if not VUHDO_SYNC_SOURCE_PROFILE or VUHDO_SYNC_SOURCE_PROFILE == "" then
		VUHDO_Msg(VUHDO_I18N_SYNC_NO_SOURCE);
		return;
	end

	VUHDO_syncCollectSelectedNodes();

	if #tGlobalNodes == 0 and #tPanelNodes == 0 then
		VUHDO_Msg(VUHDO_I18N_SYNC_NO_SETTINGS);
		return;
	end

	VUHDO_syncCollectDestinations();

	if #tDestPanels == 0 then
		VUHDO_Msg(VUHDO_I18N_SYNC_NO_DEST);
		return;
	end

	tSource = VUHDO_syncGetSourceParts(VUHDO_SYNC_SOURCE_PROFILE);

	if not tSource then
		VUHDO_Msg(format(VUHDO_I18N_PROFILE_NOT_EXISTS, VUHDO_SYNC_SOURCE_PROFILE));
		return;
	end

	if tDestProfiles[VUHDO_SYNC_SOURCE_PROFILE]
		and VUHDO_SYNC_SOURCE_PROFILE == VUHDO_CONFIG["CURRENT_PROFILE"] then
		tSource = VUHDO_syncSnapshotParts(tSource);
	end

	tNeedReload = false;

	for tDestName in pairs(tDestProfiles) do
		VUHDO_syncApplyToProfile(tDestName, VUHDO_SYNC_SOURCE_PROFILE, tSource, anIsReplace);
	end

	VUHDO_initAllBurstCaches();

	if tNeedReload then
		VUHDO_registerAllBouquets(false);
		VUHDO_initAllEventBouquets();
		VUHDO_bouqetsChanged();
		VUHDO_reloadUI(false);
	end

	VUHDO_updateProfileSelectCombo();
	VUHDO_Msg(VUHDO_I18N_SYNC_DONE);

	return;

end



--
local function VUHDO_syncRefreshDestTree()

	if VUHDO_SYNC_DEST_TREE then
		VUHDO_lnfCheckTreeRefresh(VUHDO_SYNC_DEST_TREE);
	end

	return;

end



--
local function VUHDO_syncRefreshSettingsTree()

	if VUHDO_SYNC_SETTINGS_TREE then
		VUHDO_lnfCheckTreeRefresh(VUHDO_SYNC_SETTINGS_TREE);
	end

	return;

end



--
local function VUHDO_syncSettingsSetSubtree(aNode, anIsSelect)

	if not aNode["children"] or #aNode["children"] == 0 then
		VUHDO_SYNC_SETTINGS_SEL[aNode["id"]] = anIsSelect or nil;

		return;
	end

	for tCnt = 1, #aNode["children"] do
		VUHDO_syncSettingsSetSubtree(aNode["children"][tCnt], anIsSelect);
	end

	return;

end



--
local tSettingsRoots;
function VUHDO_syncSettingsSelectAll()

	tSettingsRoots = VUHDO_syncSettingsTreeProvider();

	twipe(VUHDO_SYNC_SETTINGS_SEL);

	for tCnt = 1, #tSettingsRoots do
		VUHDO_syncSettingsSetSubtree(tSettingsRoots[tCnt], true);
	end

	VUHDO_syncRefreshSettingsTree();

	return;

end



--
function VUHDO_syncSettingsSelectNone()

	twipe(VUHDO_SYNC_SETTINGS_SEL);
	VUHDO_syncRefreshSettingsTree();

	return;

end



--
function VUHDO_syncDestSelectAll()

	twipe(VUHDO_SYNC_DEST_SEL);

	for _, tProfile in ipairs(VUHDO_PROFILES) do
		for tCnt = 1, VUHDO_MAX_PANELS do
			VUHDO_SYNC_DEST_SEL[VUHDO_syncDestLeafId(tProfile["NAME"], tCnt)] = true;
		end
	end

	VUHDO_syncRefreshDestTree();

	return;

end



--
function VUHDO_syncDestSelectMine()

	twipe(VUHDO_SYNC_DEST_SEL);

	for _, tProfile in ipairs(VUHDO_PROFILES) do
		if tProfile["ORIGINATOR_TOON"] == VUHDO_PLAYER_NAME then
			for tCnt = 1, VUHDO_MAX_PANELS do
				VUHDO_SYNC_DEST_SEL[VUHDO_syncDestLeafId(tProfile["NAME"], tCnt)] = true;
			end
		end
	end

	VUHDO_syncRefreshDestTree();

	return;

end



--
function VUHDO_syncDestSelectNone()

	twipe(VUHDO_SYNC_DEST_SEL);
	VUHDO_syncRefreshDestTree();

	return;

end



--
function VUHDO_syncApplyClicked(anIsReplace)

	VuhDoYesNoFrameText:SetText(VUHDO_I18N_SYNC_REALLY);
	VuhDoYesNoFrame:SetAttribute("callback",
		function(aDecision)
			if (VUHDO_YES == aDecision) then
				VUHDO_syncApply(anIsReplace);
			end
		end
	);
	VuhDoYesNoFrame:Show();

	return;

end



--
function VUHDO_syncSetupSettingsTree(aTree)

	VUHDO_SYNC_SETTINGS_TREE = aTree;
	VUHDO_lnfCheckTreeSetProvider(aTree, VUHDO_syncSettingsTreeProvider, VUHDO_SYNC_SETTINGS_SEL);

	return;

end



--
function VUHDO_syncSetupDestTree(aTree)

	VUHDO_SYNC_DEST_TREE = aTree;
	VUHDO_lnfCheckTreeSetProvider(aTree, VUHDO_syncDestTreeProvider, VUHDO_SYNC_DEST_SEL);

	return;

end



--
local tReadVal;
local tParentTokens = { };
local function VUHDO_syncReadValue(aParts, aTokens)

	tReadVal = aParts[aTokens[1]];

	for tCnt = 2, #aTokens do
		if type(tReadVal) ~= "table" then
			return nil;
		end

		tReadVal = tReadVal[VUHDO_syncResolveKey(aTokens[tCnt])];
	end

	return tReadVal;

end



--
local function VUHDO_syncAuditValidateRoots()

	tSource = VUHDO_syncGetSourceParts(VUHDO_CONFIG["CURRENT_PROFILE"]);

	for tId, tNode in pairs(sNodeById) do
		if tNode["roots"] then
			for tRootIndex = 1, #tNode["roots"] do
				tSrcTokens = VUHDO_syncResolveTokens(tNode["roots"][tRootIndex], tNode["srcPanel"] or 1);

				if VUHDO_syncReadValue(tSource, tSrcTokens) == nil then
					twipe(tParentTokens);

					for tParentIdx = 1, #tSrcTokens - 1 do
						tParentTokens[tParentIdx] = tSrcTokens[tParentIdx];
					end

					if #tParentTokens == 0 or VUHDO_syncReadValue(tSource, tParentTokens) == nil then
						VUHDO_Msg(format("[Sync audit] missing source root: %s %s", tId, tNode["roots"][tRootIndex]));
					end
				end
			end
		end
	end

	return;

end



do

	local VUHDO_SYNC_COVERAGE_IGNORE = {
		["CONFIG.VERSION"] = true,
		["CONFIG.CURRENT_PROFILE"] = true,
		["CONFIG.AUTO_PROFILES"] = true,
		["CONFIG.IS_ALWAYS_OVERWRITE_PROFILE"] = true,
		["CONFIG.IS_SHARE"] = true,
		["CONFIG.SHOW_PANELS"] = true,
		["CONFIG.SHOW_PLAYER_TAGS"] = true,
		["CONFIG.LOCK_IN_FIGHT"] = true,
		["CONFIG.PARSE_COMBAT_LOG"] = true,
		["CONFIG.RANGE_FALLBACK_DELAY"] = true,
		["CONFIG.USE_DEFERRED_REDRAW"] = true,
		["CONFIG.USE_ANIMATION_GROUPS"] = true,
		["CONFIG.PIXEL_PERFECT"] = true,
		["CONFIG.AOE_ADVISOR"] = true,
		["CONFIG.CLUSTER"] = true,
		["CONFIG.SHOW_SPELL_TRACE"] = true,
		["CONFIG.SPELL_TRACE"] = true,
		["CONFIG.AURA_IGNORE_MODI"] = true,
		["CONFIG.CUSTOM_DEBUFF"] = true,
		["CONFIG.DEBUFF_TOOLTIP"] = true,
		["CONFIG.STANDARD_TOOLTIP"] = true,
		["CONFIG.SOUND_DEBUFF"] = true,
		["CONFIG.SOUND_DEBUFF_REMOVABLE_ONLY"] = true,
		["CONFIG.DETECT_DEBUFFS_REMOVABLE_ONLY"] = true,
		["CONFIG.DETECT_DEBUFFS_REMOVABLE_ONLY_ICONS"] = true,
		["CONFIG.DETECT_DEBUFFS_IGNORE_BY_CLASS"] = true,
		["CONFIG.DETECT_DEBUFFS_IGNORE_NO_HARM"] = true,
		["CONFIG.DETECT_DEBUFFS_IGNORE_MOVEMENT"] = true,
		["CONFIG.DETECT_DEBUFFS_IGNORE_DURATION"] = true,
		["CONFIG.DETECT_DEBUFFS_IGNORE_PURGEABLE_BUFFS"] = true,
		["CONFIG.COMBAT_ROSTER"] = true,
		["CONFIG.DEBUG_MODE"] = true,
		["CONFIG.SYNC_SUMMARY_LEVEL"] = true,
		["CONFIG.HIDE_PANELS_OUT_OF_COMBAT"] = true,
		["BUFF_SETTINGS.CONFIG.VERSION"] = true,
		["BUFF_SETTINGS.CONFIG.SWATCH_BG_COLOR"] = true,
		["INDICATOR_CONFIG.99"] = true,
		["INDICATOR_CONFIG.VERSION"] = true,
		["PANEL_SETUP.AURA_MIGRATION_VERSION"] = true,
		["PANEL_SETUP.BAR_COLORS.VERSION"] = true,
		["PANEL_SETUP.BAR_COLORS.BAR_FRAMES"] = true,
		["PANEL_SETUP.BAR_COLORS.THREAT"] = true,
		["PANEL_SETUP.BAR_COLORS.useDebuffIcon"] = true,
		["PANEL_SETUP.BAR_COLORS.useDebuffIconBossOnly"] = true,
		["PANEL_SETUP.HOTS"] = true,
		["PANEL_SETUP.SPELL_TRACE"] = true,
		["PANEL_SETUP.CLUSTER"] = true,
		["PANEL_SETUP.VERSION"] = true,
		["PANEL_SETUP.PRIVATE_AURA_SHOW_DISPEL_TYPE"] = true,
	};

	for tIgnorePanel = 1, VUHDO_MAX_PANELS do
		VUHDO_SYNC_COVERAGE_IGNORE["PANEL_SETUP." .. tIgnorePanel .. ".HOTS"] = true;
		VUHDO_SYNC_COVERAGE_IGNORE["PANEL_SETUP." .. tIgnorePanel .. ".SCALING.isTarClassColBack"] = true;
		VUHDO_SYNC_COVERAGE_IGNORE["PANEL_SETUP." .. tIgnorePanel .. ".SCALING.isTarClassColText"] = true;
	end

	VUHDO_SYNC_COVERAGE_IGNORE["PANEL_SETUP.BAR_COLORS.HOTS"] = true;

	for tHotIndex = 1, 12 do -- VUHDO_MAX_HOTS
		VUHDO_SYNC_COVERAGE_IGNORE["PANEL_SETUP.BAR_COLORS.HOT" .. tHotIndex] = true;
	end

	for tChargeIndex = 2, 4 do
		VUHDO_SYNC_COVERAGE_IGNORE["PANEL_SETUP.BAR_COLORS.HOT_CHARGE_" .. tChargeIndex] = true;
	end

	local sCoverExact = { };
	local sCoverPrefix = { };



	--
	local tPath;
	local function VUHDO_syncCoverageAddPath(aTokens)

		tPath = aTokens[1];
		sCoverPrefix[tPath] = true;

		for tCnt = 2, #aTokens do
			tPath = tPath .. "." .. aTokens[tCnt];
			sCoverPrefix[tPath] = true;
		end

		sCoverExact[tPath] = true;

		return;

	end



	--
	local tCoverRoot;
	local tCoverTokens;
	local tCoverPanel;
	local function VUHDO_syncCoverageBuildCovered()

		twipe(sCoverExact);
		twipe(sCoverPrefix);

		for _, tNode in pairs(sNodeById) do
			if tNode["roots"] then
				for tRootIndex = 1, #tNode["roots"] do
					tCoverRoot = tNode["roots"][tRootIndex];

					if strfind(tCoverRoot, "#PNUM#", 1, true) then
						for tCoverPanel = 1, VUHDO_MAX_PANELS do
							tCoverTokens = VUHDO_syncResolveTokens(tCoverRoot, tCoverPanel);
							VUHDO_syncCoverageAddPath(tCoverTokens);
						end
					else
						tCoverTokens = VUHDO_syncResolveTokens(tCoverRoot, tNode["srcPanel"]);
						VUHDO_syncCoverageAddPath(tCoverTokens);
					end
				end
			end
		end

		return;

	end



	--
	local tWalk;
	local function VUHDO_syncCoverageIsIgnored(aPath)

		tWalk = aPath;

		while tWalk do
			if VUHDO_SYNC_COVERAGE_IGNORE[tWalk] then
				return true;
			end

			tWalk = strmatch(tWalk, "^(.+)%.[^%.]+$");
		end

		return false;

	end



	--
	local function VUHDO_syncCoverageWalk(aTable, aPath, aGaps)

		for tKey, tValue in pairs(aTable) do
			local tChildPath = aPath .. "." .. tostring(tKey);

			if sCoverExact[tChildPath] or VUHDO_syncCoverageIsIgnored(tChildPath) then
				-- covered subtree, prune
			elseif sCoverPrefix[tChildPath] then
				if type(tValue) == "table" then
					VUHDO_syncCoverageWalk(tValue, tChildPath, aGaps);
				end
			else
				tinsert(aGaps, tChildPath);
			end
		end

		return;

	end



	--
	local tParts;
	local tGaps;
	function VUHDO_syncAuditCoverageGaps()

		VUHDO_syncCoverageBuildCovered();

		tParts = VUHDO_syncGetLiveParts();
		tGaps = { };

		for tPartName, tPartTable in pairs(tParts) do
			if not sCoverExact[tPartName] and not VUHDO_syncCoverageIsIgnored(tPartName) then
				if sCoverPrefix[tPartName] and type(tPartTable) == "table" then
					VUHDO_syncCoverageWalk(tPartTable, tPartName, tGaps);
				else
					tinsert(tGaps, tPartName);
				end
			end
		end

		tsort(tGaps);

		VUHDO_Msg(format("[Sync coverage] uncovered paths: %d", #tGaps));

		for tCnt = 1, #tGaps do
			VUHDO_Msg(format("  - %s", tGaps[tCnt]));
		end

		return;

	end

end



--
function VUHDO_syncAuditCatalogCoverage()

	VUHDO_syncSettingsTreeProvider();
	VUHDO_syncAuditValidateRoots();
	VUHDO_syncAuditCoverageGaps();

	return;

end