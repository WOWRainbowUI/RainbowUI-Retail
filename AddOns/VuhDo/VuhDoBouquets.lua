local _;

local table = table;
local floor = floor;
local select = select;
local twipe = table.wipe;
local tinsert = table.insert;
local tsort = table.sort;
local ipairs = ipairs;
local pairs = pairs;
local type = type;

local CreateColorCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve;
local UnitHealthPercent = UnitHealthPercent;
local UnitPowerPercent = UnitPowerPercent;
local CreateColor = CreateColor;
local issecretvalue = issecretvalue;
local ShouldUnitAuraInstanceBeSecret = C_Secrets and C_Secrets.ShouldUnitAuraInstanceBeSecret;

local VUHDO_copyColorTo;
local VUHDO_isConfigDemoUsers;
local VUHDO_displayAurasAtAnchorFromCache;
local VUHDO_isAuraDisplaySuspended;
local VUHDO_getSlotData;
local VUHDO_getAuraGroupRaw;
local VUHDO_getAuraBarColorType;
local VUHDO_getAuraTextColorType;
local VUHDO_determineAura;
local VUHDO_updateHealthBarsFor;
local VUHDO_isAuraDataRestricted;
local VUHDO_isAuraModeContainers;
local VUHDO_resolveGroupCandidateFilters;
local VUHDO_resolveAuraContainerSpellId;
local VUHDO_addResolvedAuraContainerSpellIds;
local VUHDO_getAuraGroup;
local VUHDO_isAuraGroupContainerExpressible;
local VUHDO_releaseAllOverlays;
local VUHDO_invalidateAuraContainerTemplateCache;
local VUHDO_renderNonAuraListSlots;
local VUHDO_deferSyncOverlaysForUnit;
local VUHDO_incrementAlphaChainConfigVersion;

local VUHDO_BOUQUETS = { };
local VUHDO_RAID = { };
local VUHDO_CONFIG = { };
local VUHDO_BOUQUET_BUFFS_SPECIAL = { };
local VUHDO_CUSTOM_ICONS;
local VUHDO_USER_CLASS_COLORS;
local VUHDO_POWER_TYPE_COLORS;
local VUHDO_PANEL_SETUP;
local VUHDO_PANEL_MODELS;
local VUHDO_AURA_LIST_BOUQUETS;
local VUHDO_UNIT_AURA_LIST_SLOTS;
local VUHDO_MAX_PANELS;
local VUHDO_AURA_GROUP_TYPE_LIST;
local VUHDO_AURA_LIST_ENTRY_BOUQUET;
local VUHDO_AURA_LIST_ENTRY_SPELL;
local VUHDO_BOUQUET_RESTRICTED_NON_AURA;
local VUHDO_SECRET_TYPE_DISPEL;
local VUHDO_SECRET_TYPE_DURATION;
local VUHDO_BOUQUET_CUSTOM_TYPE_AURA_GROUP;
local VUHDO_DEFAULT_AURA_GROUPS;
local VUHDO_AURA_GROUP_COLOR_OFF;
local VUHDO_AURA_GROUP_COLOR_DISPEL;
local VUHDO_AURA_GROUP_COLOR_ALL_DISPEL;
local VUHDO_PLAYER_CLASS;

local VUHDO_BOUQUET_LAYER_TYPE_NONSECRET;
local VUHDO_BOUQUET_LAYER_TYPE_CURVE;
local VUHDO_BOUQUET_LAYER_TYPE_DISPEL;
local VUHDO_BOUQUET_LAYER_TYPE_AURA;
local VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL;
local VUHDO_BOUQUET_LAYER_TYPE_BOOLEAN;
local VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR;

local VUHDO_LAST_EVALUATED_BOUQUETS = { };
setmetatable(VUHDO_LAST_EVALUATED_BOUQUETS, VUHDO_META_NEW_ARRAY);
local VUHDO_REGISTERED_BOUQUETS = { };
setmetatable(VUHDO_REGISTERED_BOUQUETS, VUHDO_META_NEW_ARRAY);
local VUHDO_ACTIVE_BOUQUETS = { };
setmetatable(VUHDO_ACTIVE_BOUQUETS, VUHDO_META_NEW_ARRAY);

local VUHDO_REGISTERED_BOUQUET_INDICATORS = { };
local VUHDO_CYCLIC_BOUQUETS = { };

VUHDO_UNIT_AURA_BOUQUET_ACTIVE = { };
VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS = { };

local VUHDO_CUSTOM_BOUQUETS = {
	VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH,
};

VUHDO_DISPEL_COLOR_GENERATION = 0;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;
local sEmpty = { };

local sDebuffTypeCurves;
local sPlayerArray = { };
local sBouquetLayerTemplates = { };
local sBouquetCurves = { };
local sBouquetColors = { };
local sBouquetTextColors = { };
local sCurveCache = { };
local sBrightnessCurveCache = { };
local sTextBrightnessCurveCache = { };
local sThresholds = { };

local sBouquetStatePool;
local sThresholdEntryPool;
local sUnitBouquetActivePool;
local sValidatorEntryPool;

local sGroupsWithEnabledAnchorReusable = { };

local sDispelTypeCurve;
local sDispelTypeBorderCurve;
local sDispelTypeTextCurve;
local sDispelTypeColorMap = { };
local sDispelTypeColorMapOpaque = { };
local sDispelTypeBackgroundFillColorMap = { };
local sDispelTypeBackgroundBackingColorMap = { };
local sDispelTypeColorMapOpaqueBrightCache = { };
local sDispelTypeBackgroundFillBrightCache = { };
local sDispelTypeBackgroundBackingBrightCache = { };
local sDispelTypeColorMapVariantCache = { };
local sDispelTypeBackgroundFillCurve;
local sDispelTypeBackgroundBackingCurve;
local sDispelTypeBackgroundFillCurveCache = { };
local sDispelTypeBackgroundBackingCurveCache = { };

local sDispelNameColorKeyMap = {
	["None"] = "DEBUFF0",
	["Magic"] = "DEBUFF3",
	["Curse"] = "DEBUFF4",
	["Disease"] = "DEBUFF2",
	["Poison"] = "DEBUFF1",
	["Bleed"] = "DEBUFF8",
	["Enrage"] = "DEBUFF9",
};

local sBackgroundDispelTypeNames = { };
local sGlowDispelTypeNames = { };

local sDispelTypeCurvePointKeys = {
	{ 0, "DEBUFF0" },
	{ 1, "DEBUFF3" },
	{ 2, "DEBUFF4" },
	{ 3, "DEBUFF2" },
	{ 4, "DEBUFF1" },
	{ 6, "DEBUFF6" },
	{ 8, "DEBUFF8" },
	{ 9, "DEBUFF9" },
	{ 11, "DEBUFF8" },
};

local sMagicDispelCurve;
local sDiseaseDispelCurve;
local sPoisonDispelCurve;
local sCurseDispelCurve;
local sBleedDispelCurve;
local sEnrageDispelCurve;

local sTransparentColor;
local sWhiteColor;

local sIsDispelColorType = { };



--
function VUHDO_bouquetsInitLocalOverrides()

	VUHDO_BOUQUETS = _G["VUHDO_BOUQUETS"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_CUSTOM_ICONS = _G["VUHDO_CUSTOM_ICONS"];
	VUHDO_BOUQUET_BUFFS_SPECIAL = _G["VUHDO_BOUQUET_BUFFS_SPECIAL"];

	VUHDO_USER_CLASS_COLORS = _G["VUHDO_USER_CLASS_COLORS"];
	VUHDO_POWER_TYPE_COLORS = _G["VUHDO_POWER_TYPE_COLORS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_PANEL_MODELS = _G["VUHDO_PANEL_MODELS"];
	VUHDO_AURA_LIST_BOUQUETS = _G["VUHDO_AURA_LIST_BOUQUETS"];
	VUHDO_UNIT_AURA_LIST_SLOTS = _G["VUHDO_UNIT_AURA_LIST_SLOTS"];
	VUHDO_MAX_PANELS = _G["VUHDO_MAX_PANELS"];
	VUHDO_AURA_GROUP_TYPE_LIST = _G["VUHDO_AURA_GROUP_TYPE_LIST"];
	VUHDO_AURA_LIST_ENTRY_BOUQUET = _G["VUHDO_AURA_LIST_ENTRY_BOUQUET"];
	VUHDO_AURA_LIST_ENTRY_SPELL = _G["VUHDO_AURA_LIST_ENTRY_SPELL"];
	VUHDO_BOUQUET_RESTRICTED_NON_AURA = _G["VUHDO_BOUQUET_RESTRICTED_NON_AURA"];
	VUHDO_SECRET_TYPE_DISPEL = _G["VUHDO_SECRET_TYPE_DISPEL"];
	VUHDO_SECRET_TYPE_DURATION = _G["VUHDO_SECRET_TYPE_DURATION"];
	VUHDO_BOUQUET_CUSTOM_TYPE_AURA_GROUP = _G["VUHDO_BOUQUET_CUSTOM_TYPE_AURA_GROUP"];
	VUHDO_DEFAULT_AURA_GROUPS = _G["VUHDO_DEFAULT_AURA_GROUPS"];
	VUHDO_AURA_GROUP_COLOR_OFF = _G["VUHDO_AURA_GROUP_COLOR_OFF"];
	VUHDO_AURA_GROUP_COLOR_DISPEL = _G["VUHDO_AURA_GROUP_COLOR_DISPEL"];
	VUHDO_AURA_GROUP_COLOR_ALL_DISPEL = _G["VUHDO_AURA_GROUP_COLOR_ALL_DISPEL"];
	VUHDO_PLAYER_CLASS = _G["VUHDO_PLAYER_CLASS"];

	VUHDO_BOUQUET_LAYER_TYPE_NONSECRET = _G["VUHDO_BOUQUET_LAYER_TYPE_NONSECRET"];
	VUHDO_BOUQUET_LAYER_TYPE_CURVE = _G["VUHDO_BOUQUET_LAYER_TYPE_CURVE"];
	VUHDO_BOUQUET_LAYER_TYPE_DISPEL = _G["VUHDO_BOUQUET_LAYER_TYPE_DISPEL"];
	VUHDO_BOUQUET_LAYER_TYPE_AURA = _G["VUHDO_BOUQUET_LAYER_TYPE_AURA"];
	VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL = _G["VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL"];
	VUHDO_BOUQUET_LAYER_TYPE_BOOLEAN = _G["VUHDO_BOUQUET_LAYER_TYPE_BOOLEAN"];
	VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR = _G["VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR"];

	VUHDO_copyColorTo = _G["VUHDO_copyColorTo"];
	VUHDO_isConfigDemoUsers = _G["VUHDO_isConfigDemoUsers"];
	VUHDO_getAuraGroupRaw = _G["VUHDO_getAuraGroupRaw"];
	VUHDO_displayAurasAtAnchorFromCache = _G["VUHDO_displayAurasAtAnchorFromCache"];
	VUHDO_isAuraDisplaySuspended = _G["VUHDO_isAuraDisplaySuspended"];
	VUHDO_getSlotData = _G["VUHDO_getSlotData"];
	VUHDO_getAuraBarColorType = _G["VUHDO_getAuraBarColorType"];
	VUHDO_getAuraTextColorType = _G["VUHDO_getAuraTextColorType"];
	VUHDO_determineAura = _G["VUHDO_determineAura"];
	VUHDO_updateHealthBarsFor = _G["VUHDO_updateHealthBarsFor"];
	VUHDO_isAuraDataRestricted = _G["VUHDO_isAuraDataRestricted"];
	VUHDO_isAuraModeContainers = _G["VUHDO_isAuraModeContainers"];
	VUHDO_resolveGroupCandidateFilters = _G["VUHDO_resolveGroupCandidateFilters"];
	VUHDO_resolveAuraContainerSpellId = _G["VUHDO_resolveAuraContainerSpellId"];
	VUHDO_addResolvedAuraContainerSpellIds = _G["VUHDO_addResolvedAuraContainerSpellIds"];
	VUHDO_getAuraGroup = _G["VUHDO_getAuraGroup"];
	VUHDO_isAuraGroupContainerExpressible = _G["VUHDO_isAuraGroupContainerExpressible"];
	VUHDO_releaseAllOverlays = _G["VUHDO_releaseAllOverlays"];
	VUHDO_invalidateAuraContainerTemplateCache = _G["VUHDO_invalidateAuraContainerTemplateCache"];
	VUHDO_renderNonAuraListSlots = _G["VUHDO_renderNonAuraListSlots"];
	VUHDO_deferSyncOverlaysForUnit = _G["VUHDO_deferSyncOverlaysForUnit"];
	VUHDO_incrementAlphaChainConfigVersion = _G["VUHDO_incrementAlphaChainConfigVersion"];

	VUHDO_updateHealthBarsFor = _G["VUHDO_deferUpdateHealthBarsFor"];

	twipe(sIsDispelColorType);
	sIsDispelColorType[VUHDO_AURA_GROUP_COLOR_DISPEL] = true;
	sIsDispelColorType[VUHDO_AURA_GROUP_COLOR_ALL_DISPEL] = true;

	sBouquetStatePool = VUHDO_createTablePool("BouquetState", 500);
	sThresholdEntryPool = VUHDO_createTablePool("ThresholdEntry", 100);
	sValidatorEntryPool = VUHDO_createTablePool("ValidatorEntry", 200);
	sUnitBouquetActivePool = VUHDO_createTablePool("UnitBouquetActive", 50);

	sPlayerArray["player"] = VUHDO_RAID["player"];

	return;

end



--
function VUHDO_initSecretColorConstants()

	sTransparentColor = CreateColor(0, 0, 0, 0);
	sWhiteColor = CreateColor(1, 1, 1, 1);

	return;

end



--
function VUHDO_safeColorFromTable(aColorTable, aFallback)

	if aColorTable and aColorTable["R"] and aColorTable["G"] and aColorTable["B"] then
		return CreateColor(aColorTable["R"], aColorTable["G"], aColorTable["B"], aColorTable["O"] or 1);
	end

	return aFallback or sTransparentColor;

end



--
function VUHDO_safeTextColorFromTable(aColorTable, aFallback)

	if aColorTable and aColorTable["TR"] and aColorTable["TG"] and aColorTable["TB"] then
		return CreateColor(aColorTable["TR"], aColorTable["TG"], aColorTable["TB"], aColorTable["TO"] or 1);
	end

	return aFallback or sTransparentColor;

end



--
function VUHDO_safeOpaqueDispelColorFromTable(aColorTable, aFallback)

	if not aColorTable or not aColorTable["useBackground"] then
		return aFallback or sTransparentColor;
	end

	if aColorTable["R"] and aColorTable["G"] and aColorTable["B"] then
		return CreateColor(aColorTable["R"], aColorTable["G"], aColorTable["B"], 1);
	end

	return aFallback or sTransparentColor;

end



--
local tBackgroundDispelAlpha;
function VUHDO_safeBackgroundDispelColorFromTable(aColorTable, aFallback, aBrightness, anOpacityProduct)

	if not aColorTable or not aColorTable["useBackground"] then
		return aFallback or sTransparentColor;
	end

	if aColorTable["R"] and aColorTable["G"] and aColorTable["B"] then
		if aColorTable["useOpacity"] then
			tBackgroundDispelAlpha = (aColorTable["O"] or 1) * (anOpacityProduct or 1);
		else
			tBackgroundDispelAlpha = aColorTable["O"] or 1;
		end

		return CreateColor((aColorTable["R"] or 0) * aBrightness, (aColorTable["G"] or 0) * aBrightness, (aColorTable["B"] or 0) * aBrightness, tBackgroundDispelAlpha);
	end

	return aFallback or sTransparentColor;

end



--
function VUHDO_safeBackgroundDispelBackingColorFromTable(aColorTable, aFallback, aBrightness, anOpacityProduct)

	if not aColorTable or not aColorTable["useBackground"] then
		return aFallback or sTransparentColor;
	end

	if aColorTable["R"] and aColorTable["G"] and aColorTable["B"] then
		if aColorTable["useOpacity"] then
			tBackgroundDispelAlpha = (aColorTable["O"] or 1) * (anOpacityProduct or 1);
		else
			tBackgroundDispelAlpha = aColorTable["O"] or 1;
		end

		return CreateColor((aColorTable["R"] or 0) * aBrightness, (aColorTable["G"] or 0) * aBrightness, (aColorTable["B"] or 0) * aBrightness, tBackgroundDispelAlpha < 1 and 0 or 1);
	end

	return aFallback or sTransparentColor;

end



--
local tPopulateColors;
local tPopulateDefaultColor;
local tPopulateTransparent;
local tPointEntry;
function VUHDO_populateDispelTypeBackgroundCurves(aFillCurve, aBackingCurve, aBrightness, anOpacityProduct)

	tPopulateColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];
	tPopulateDefaultColor = CreateColor(0.5, 0.5, 0.5, 1);
	tPopulateTransparent = CreateColor(0, 0, 0, 0);

	if not tPopulateColors then
		aFillCurve:AddPoint(0, tPopulateDefaultColor);
		aBackingCurve:AddPoint(0, tPopulateTransparent);

		return;
	end

	for tIdx = 1, #sDispelTypeCurvePointKeys do
		tPointEntry = sDispelTypeCurvePointKeys[tIdx];

		aFillCurve:AddPoint(tPointEntry[1], VUHDO_safeBackgroundDispelColorFromTable(tPopulateColors[tPointEntry[2]], tPopulateDefaultColor, aBrightness, anOpacityProduct));
		aBackingCurve:AddPoint(tPointEntry[1], VUHDO_safeBackgroundDispelBackingColorFromTable(tPopulateColors[tPointEntry[2]], tPopulateTransparent, aBrightness, anOpacityProduct));
	end

	return;

end



--
function VUHDO_safeBorderDispelColorFromTable(aColorTable, aFallback)

	if not aColorTable or not aColorTable["useBorder"] then
		return aFallback or sTransparentColor;
	end

	return VUHDO_safeColorFromTable(aColorTable, aFallback);

end



--
local tPopulateBorderColors;
local tPopulateBorderTransparent;
function VUHDO_populateDispelTypeBorderCurve(aBorderCurve)

	tPopulateBorderColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

	tPopulateBorderTransparent = CreateColor(0, 0, 0, 0);

	aBorderCurve:AddPoint(0, tPopulateBorderTransparent);

	if not tPopulateBorderColors then
		return;
	end

	aBorderCurve:AddPoint(1, VUHDO_safeBorderDispelColorFromTable(tPopulateBorderColors["DEBUFF3"], tPopulateBorderTransparent));
	aBorderCurve:AddPoint(2, VUHDO_safeBorderDispelColorFromTable(tPopulateBorderColors["DEBUFF4"], tPopulateBorderTransparent));
	aBorderCurve:AddPoint(3, VUHDO_safeBorderDispelColorFromTable(tPopulateBorderColors["DEBUFF2"], tPopulateBorderTransparent));
	aBorderCurve:AddPoint(4, VUHDO_safeBorderDispelColorFromTable(tPopulateBorderColors["DEBUFF1"], tPopulateBorderTransparent));
	aBorderCurve:AddPoint(9, VUHDO_safeBorderDispelColorFromTable(tPopulateBorderColors["DEBUFF9"], tPopulateBorderTransparent));
	aBorderCurve:AddPoint(11, VUHDO_safeBorderDispelColorFromTable(tPopulateBorderColors["DEBUFF8"], tPopulateBorderTransparent));

	return;

end



--
function VUHDO_safeBrightOpaqueDispelColorFromTable(aColorTable, aFallback, aBrightness)

	if not aColorTable or not aColorTable["useBackground"] then
		return aFallback or sTransparentColor;
	end

	if aColorTable["R"] and aColorTable["G"] and aColorTable["B"] then
		return CreateColor((aColorTable["R"] or 0) * aBrightness, (aColorTable["G"] or 0) * aBrightness, (aColorTable["B"] or 0) * aBrightness, 1);
	end

	return aFallback or sTransparentColor;

end



--
function VUHDO_safeBrightOpacityColorFromTable(aColorTable, aFallback, aBrightness, aOpacity)

	if aColorTable and aColorTable["R"] and aColorTable["G"] and aColorTable["B"] then
		return CreateColor((aColorTable["R"] or 0) * aBrightness, (aColorTable["G"] or 0) * aBrightness, (aColorTable["B"] or 0) * aBrightness, (aColorTable["O"] or 1) * aOpacity);
	end

	return aFallback or sTransparentColor;

end



do
	--
	local tBrightCacheKey;
	local tColors;
	local tTransparent;
	local tNewCurve;
	local tTypeColor;
	local tR;
	local tG;
	local tB;
	local tO;
	local tPointEntry;
	local tCache;
	function VUHDO_getOrBuildDispelBrightnessCurve(aBaseCurve, aBrightness, aCurveType, anIsText)

		if not aBrightness or aBrightness >= 1 then
			return aBaseCurve;
		end

		tBrightCacheKey = (anIsText and "text_" or "") .. aCurveType .. "_" .. tostring(aBrightness);
		tCache = anIsText and sTextBrightnessCurveCache or sBrightnessCurveCache;

		if tCache[tBrightCacheKey] then
			return tCache[tBrightCacheKey];
		end

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];
		tTransparent = CreateColor(0, 0, 0, 0);

		tNewCurve = CreateColorCurve();
		tNewCurve:SetType(Enum.LuaCurveType.Step);
		tNewCurve:AddPoint(0, tTransparent);

		if tColors then
			for tIdx = 1, #sDispelTypeCurvePointKeys do
				tPointEntry = sDispelTypeCurvePointKeys[tIdx];
				tTypeColor = tColors[tPointEntry[2]];

				if tTypeColor then
					if anIsText then
						tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;
					else
						tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;
					end

					tNewCurve:AddPoint(tPointEntry[1], CreateColor(tR, tG, tB, tO));
				end
			end
		end

		tCache[tBrightCacheKey] = tNewCurve;

		return tNewCurve;

	end



	--
	function VUHDO_getOrBuildBrightnessCurve(aBaseCurve, aBrightness, aCurveType)

		return VUHDO_getOrBuildDispelBrightnessCurve(aBaseCurve, aBrightness, aCurveType, false);

	end



	--
	function VUHDO_getOrBuildTextBrightnessCurve(aBaseCurve, aBrightness, aCurveType)

		return VUHDO_getOrBuildDispelBrightnessCurve(aBaseCurve, aBrightness, aCurveType, true);

	end
end



--
local tBouquetColors;
function VUHDO_getBouquetBoolColor(aBouquetName, aValidatorName)

	tBouquetColors = sBouquetColors[aBouquetName];

	if tBouquetColors then
		return tBouquetColors[aValidatorName];
	end

	return nil;

end



--
local tBouquetTextColors;
function VUHDO_getBouquetBoolTextColor(aBouquetName, aValidatorName)

	tBouquetTextColors = sBouquetTextColors[aBouquetName];

	if tBouquetTextColors then
		return tBouquetTextColors[aValidatorName];
	end

	return nil;

end



--
local tCacheKey;
function VUHDO_getHealthCurve(aBouquetName, aClassId)

	tCacheKey = aBouquetName .. "_" .. (aClassId or 0);

	return sCurveCache[tCacheKey] or sCurveCache[aBouquetName .. "_0"];

end



--
function VUHDO_getDispelTypeCurve()

	return sDispelTypeCurve;

end



--
function VUHDO_getDispelTypeBorderCurve()

	return sDispelTypeBorderCurve;

end



do
	--
	local tBrightKey;
	local tOpacityKey;
	local function VUHDO_getOrBuildDispelBrightOpacityVariant(aBaseValue, aCacheTable, aBright, anOpacity, aBuildDelegate)

		tBrightKey = aBright or 1;
		tOpacityKey = anOpacity or 1;

		if tBrightKey >= 1 and tOpacityKey >= 1 then
			return aBaseValue;
		end

		if not aCacheTable[tBrightKey] then
			aCacheTable[tBrightKey] = { };
		end

		if not aCacheTable[tBrightKey][tOpacityKey] then
			aBuildDelegate(tBrightKey, tOpacityKey);
		end

		return aCacheTable[tBrightKey][tOpacityKey];

	end



	--
	function VUHDO_getDispelTypeColorMap(aBright, aOpacity)

		return VUHDO_getOrBuildDispelBrightOpacityVariant(sDispelTypeColorMap, sDispelTypeColorMapVariantCache, aBright, aOpacity, VUHDO_buildDispelTypeColorMapVariant);

	end



	--
	function VUHDO_getDispelTypeColorMapOpaque(aBright)

		tBrightKey = aBright or 1;

		if tBrightKey >= 1 then
			return sDispelTypeColorMapOpaque;
		end

		if not sDispelTypeColorMapOpaqueBrightCache[tBrightKey] then
			VUHDO_buildDispelTypeColorMapVariant(tBrightKey, 1);
		end

		return sDispelTypeColorMapOpaqueBrightCache[tBrightKey];

	end



	--
	function VUHDO_getBackgroundDispelTypeNames()

		return sBackgroundDispelTypeNames;

	end



	--
	function VUHDO_getGlowDispelTypeNames()

		return sGlowDispelTypeNames;

	end



	--
	function VUHDO_getDispelTypeBackgroundFillColorMap(aBright, aOpacity)

		return VUHDO_getOrBuildDispelBrightOpacityVariant(sDispelTypeBackgroundFillColorMap, sDispelTypeBackgroundFillBrightCache, aBright, aOpacity, VUHDO_buildDispelTypeColorMapVariant);

	end



	--
	function VUHDO_getDispelTypeBackgroundBackingColorMap(aBright, aOpacity)

		return VUHDO_getOrBuildDispelBrightOpacityVariant(sDispelTypeBackgroundBackingColorMap, sDispelTypeBackgroundBackingBrightCache, aBright, aOpacity, VUHDO_buildDispelTypeColorMapVariant);

	end



	--
	function VUHDO_getDispelTypeBackgroundFillCurve(aBright, aOpacity)

		return VUHDO_getOrBuildDispelBrightOpacityVariant(sDispelTypeBackgroundFillCurve, sDispelTypeBackgroundFillCurveCache, aBright, aOpacity, VUHDO_buildDispelTypeBackgroundCurveVariant);

	end



	--
	function VUHDO_getDispelTypeBackgroundBackingCurve(aBright, aOpacity)

		return VUHDO_getOrBuildDispelBrightOpacityVariant(sDispelTypeBackgroundBackingCurve, sDispelTypeBackgroundBackingCurveCache, aBright, aOpacity, VUHDO_buildDispelTypeBackgroundCurveVariant);

	end
end



--
function VUHDO_getDispelColorGeneration()

	return VUHDO_DISPEL_COLOR_GENERATION;

end



--
function VUHDO_getDispelTypeTextCurve()

	return sDispelTypeTextCurve;

end



--
function VUHDO_clearCurveCache()

	twipe(sCurveCache);
	twipe(sBouquetCurves);
	twipe(sBouquetColors);
	twipe(sBouquetTextColors);
	twipe(sTextBrightnessCurveCache);

	return;

end



do
	--
	local tCurve;
	local tRadio;
	local tBaseColor;
	local tLowColor;
	local tMedColor;
	local tHighColor;
	local tClassColor;
	local tThresholdFraction;
	local tBaseColorMixin;
	local tLowColorMixin;
	local tMedColorMixin;
	local tHighColorMixin;
	local tCurrentX;
	local tThresholdColorMixin;
	local tItem;
	local tName;
	local tEntry;
	local tHealthBright;
	function VUHDO_buildCompositeHealthCurve(aBouquet, anInfo)

		twipe(sThresholds);

		tRadio = 3;
		tBaseColor, tLowColor, tMedColor, tHighColor = nil, nil, nil, nil;
		tHealthBright = 1;

		if not VUHDO_USER_CLASS_COLORS or not VUHDO_USER_CLASS_GRADIENT_COLORS then
			VUHDO_initClassColors();
		end

		for tCnt = 1, #aBouquet do
			tItem = aBouquet[tCnt];
			tName = tItem["name"];

			if tName == "STATUS_HEALTH" then
				tRadio = tItem["custom"]["radio"] or 3;
				tHealthBright = tItem["custom"]["bright"] or 1;

				if tRadio == 1 then
					tBaseColor = tItem["color"];
				elseif tRadio == 2 then
					if tItem["custom"]["isClassGradient"] and VUHDO_USER_CLASS_GRADIENT_COLORS and VUHDO_USER_CLASS_GRADIENT_COLORS[anInfo["classId"]] then
						tClassColor = VUHDO_USER_CLASS_GRADIENT_COLORS[anInfo["classId"]]["min"];
						tBaseColor = tClassColor or tItem["color"];
					else
						tClassColor = VUHDO_USER_CLASS_COLORS and VUHDO_USER_CLASS_COLORS[anInfo["classId"]];
						tBaseColor = tClassColor or tItem["color"];
					end
				else
					tHighColor = tItem["custom"]["grad_high"] or tItem["color"];
					tMedColor = tItem["custom"]["grad_med"];
					tLowColor = tItem["custom"]["grad_low"];
				end
			elseif tName == "HEALTH_BELOW" then
				tEntry = sThresholdEntryPool:get();

				tEntry["type"] = "below";
				tEntry["percent"] = tItem["custom"][1];
				tEntry["color"] = tItem["color"];

				tinsert(sThresholds, tEntry);
			elseif tName == "HEALTH_ABOVE" then
				tEntry = sThresholdEntryPool:get();

				tEntry["type"] = "above";
				tEntry["percent"] = tItem["custom"][1];
				tEntry["color"] = tItem["color"];

				tinsert(sThresholds, tEntry);
			end
		end

		tsort(sThresholds, function(a, b) return a["percent"] < b["percent"]; end);

		tCurve = CreateColorCurve();
		tCurve:SetType(Enum.LuaCurveType.Linear);

		tBaseColorMixin = nil;

		if tBaseColor then
			if 2 == tRadio then
				tBaseColorMixin = CreateColor(tBaseColor["R"] * tHealthBright, tBaseColor["G"] * tHealthBright, tBaseColor["B"] * tHealthBright, tBaseColor["O"] or 1);
			else
				tBaseColorMixin = CreateColor(tBaseColor["R"], tBaseColor["G"], tBaseColor["B"], tBaseColor["O"] or 1);
			end
		end

		tLowColorMixin, tMedColorMixin, tHighColorMixin = nil, nil, nil;

		if tLowColor and tMedColor and tHighColor then
			tLowColorMixin = CreateColor(tLowColor["R"], tLowColor["G"], tLowColor["B"], tLowColor["O"] or 1);
			tMedColorMixin = CreateColor(tMedColor["R"], tMedColor["G"], tMedColor["B"], tMedColor["O"] or 1);
			tHighColorMixin = CreateColor(tHighColor["R"], tHighColor["G"], tHighColor["B"], tHighColor["O"] or 1);
		end

		if #sThresholds == 0 then
			if tRadio == 3 and tLowColorMixin then
				tCurve:AddPoint(0.00, tLowColorMixin);
				tCurve:AddPoint(0.25, tLowColorMixin);
				tCurve:AddPoint(0.50, tMedColorMixin);
				tCurve:AddPoint(0.70, tMedColorMixin);
				tCurve:AddPoint(0.85, tHighColorMixin);
				tCurve:AddPoint(1.00, tHighColorMixin);
			elseif tBaseColorMixin then
				tCurve:AddPoint(0.00, tBaseColorMixin);
				tCurve:AddPoint(1.00, tBaseColorMixin);
			else
				tCurve:AddPoint(0.00, sWhiteColor);
				tCurve:AddPoint(1.00, sWhiteColor);
			end

			return tCurve;
		end

		tCurrentX = 0;

		for _, tThreshold in ipairs(sThresholds) do
			tThresholdFraction = tThreshold["percent"] / 100;

			tThresholdColorMixin = CreateColor(
				tThreshold["color"]["R"], tThreshold["color"]["G"],
				tThreshold["color"]["B"], tThreshold["color"]["O"] or 1
			);

			if tThreshold["type"] == "below" then
				tCurve:AddPoint(tCurrentX, tThresholdColorMixin);
				tCurve:AddPoint(tThresholdFraction - 0.005, tThresholdColorMixin);

				tCurrentX = tThresholdFraction;

			elseif tThreshold["type"] == "above" then
				if tCurrentX < tThresholdFraction then
					if tRadio == 3 and tLowColorMixin then
						VUHDO_addGradientPointsToRange(tCurve, tCurrentX, tThresholdFraction,
							tLowColorMixin, tMedColorMixin, tHighColorMixin);
					elseif tBaseColorMixin then
						tCurve:AddPoint(tCurrentX, tBaseColorMixin);
						tCurve:AddPoint(tThresholdFraction - 0.005, tBaseColorMixin);
					end
				end

				tCurve:AddPoint(tThresholdFraction, tThresholdColorMixin);
				tCurve:AddPoint(1.00, tThresholdColorMixin);

				tCurrentX = 1.00;
			end
		end

		if tCurrentX < 1.00 then
			if tRadio == 3 and tLowColorMixin then
				VUHDO_addGradientPointsToRange(tCurve, tCurrentX, 1.00,
					tLowColorMixin, tMedColorMixin, tHighColorMixin);
			elseif tBaseColorMixin then
				tCurve:AddPoint(tCurrentX, tBaseColorMixin);
				tCurve:AddPoint(1.00, tBaseColorMixin);
			end
		end

		for tIdx = 1, #sThresholds do
			sThresholdEntryPool:release(sThresholds[tIdx]);
		end

		twipe(sThresholds);

		return tCurve;

	end
end



do
	--
	local tModi;
	local tInvModi;
	local tR;
	local tG;
	local tB;
	local tRange;
	local tX;
	local tColorMixin;
	function VUHDO_addGradientPointsToRange(aCurve, aStartX, aEndX, aLowColor, aMedColor, aHighColor)

		tRange = aEndX - aStartX;

		for tStep = 0, 6 do
			tX = aStartX + (tStep / 6) * tRange;
			tModi = (tX ^ 1.7) * 2;

			if tModi > 1 then
				tModi = tModi - 1;

				if tModi > 1 then
					tModi = 1;
				end

				tInvModi = 1 - tModi;

				tR = aMedColor:GetRed() * tInvModi + aHighColor:GetRed() * tModi;
				tG = aMedColor:GetGreen() * tInvModi + aHighColor:GetGreen() * tModi;
				tB = aMedColor:GetBlue() * tInvModi + aHighColor:GetBlue() * tModi;
			else
				tInvModi = 1 - tModi;

				tR = aLowColor:GetRed() * tInvModi + aMedColor:GetRed() * tModi;
				tG = aLowColor:GetGreen() * tInvModi + aMedColor:GetGreen() * tModi;
				tB = aLowColor:GetBlue() * tInvModi + aMedColor:GetBlue() * tModi;
			end

			tColorMixin = CreateColor(tR, tG, tB, 1);
			aCurve:AddPoint(tX, tColorMixin);
		end

		return;

	end
end



do
	--
	local VUHDO_ALL_CLASS_IDS = { 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 40 };
	local tMockInfo;
	local tItem;
	local tRadio;
	local tCacheKey;
	function VUHDO_prebuildHealthCurvesForBouquet(aBouquetName, aBouquet)

		for tCnt = 1, #aBouquet do
			tItem = aBouquet[tCnt];

			if tItem["name"] == "STATUS_HEALTH" then
				tRadio = tItem["custom"]["radio"] or 3;

				if tRadio == 2 then
					for _, tClassId in ipairs(VUHDO_ALL_CLASS_IDS) do
						tMockInfo = { ["classId"] = tClassId };

						tCacheKey = aBouquetName .. "_" .. tClassId;
						sCurveCache[tCacheKey] = VUHDO_buildCompositeHealthCurve(aBouquet, tMockInfo);
					end
				else
					tMockInfo = { ["classId"] = 0 };

					tCacheKey = aBouquetName .. "_0";
					sCurveCache[tCacheKey] = VUHDO_buildCompositeHealthCurve(aBouquet, tMockInfo);
				end

				return;
			end
		end

		return;

	end
end



do
	--
	local tPowerCurve;
	local tThreshold;
	local tPowerBaseColor;
	local tWarningColor;
	local tPowerBaseColorMixin;
	local tItem;
	function VUHDO_buildCompositePowerCurve(aBouquet, aPowerType)

		tPowerCurve = CreateColorCurve();
		tPowerCurve:SetType(Enum.LuaCurveType.Linear);

		tThreshold = nil;
		tPowerBaseColor = VUHDO_POWER_TYPE_COLORS and VUHDO_POWER_TYPE_COLORS[aPowerType];

		if not tPowerBaseColor then
			tPowerBaseColor = { ["R"] = 0, ["G"] = 0.5, ["B"] = 1 };
		end

		for tCnt = 1, #aBouquet do
			tItem = aBouquet[tCnt];

			if tItem["name"] == "MANA_BELOW" then
				tThreshold = tItem["custom"][1];

				tWarningColor = CreateColor(tItem["color"]["R"], tItem["color"]["G"], tItem["color"]["B"], 1);

				tPowerCurve:AddPoint(0.00, tWarningColor);
				tPowerCurve:AddPoint(tThreshold / 100 - 0.005, tWarningColor);
			end
		end

		tPowerBaseColorMixin = CreateColor(tPowerBaseColor["R"], tPowerBaseColor["G"], tPowerBaseColor["B"], 1);

		if tThreshold then
			tPowerCurve:AddPoint(tThreshold / 100, tPowerBaseColorMixin);
		else
			tPowerCurve:AddPoint(0.00, tPowerBaseColorMixin);
		end

		tPowerCurve:AddPoint(1.00, tPowerBaseColorMixin);

		return tPowerCurve;

	end
end



do
	--
	local tColors;
	local tDefaultColor;
	local tTransparent;
	local tDispelName;
	local tColorKey;
	local tBrightMap;
	local tBrightOpaqueMap;
	local tBrightBackgroundFillMap;
	local tBrightBackgroundBackingMap;
	function VUHDO_buildDispelTypeColorMapVariant(aBrightness, aOpacity)

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];
		tDefaultColor = CreateColor(0.5, 0.5, 0.5, 1);
		tTransparent = CreateColor(0, 0, 0, 0);
		tBrightMap = { };
		tBrightOpaqueMap = { };
		tBrightBackgroundFillMap = { };
		tBrightBackgroundBackingMap = { };

		for tDispelName, tColorKey in pairs(sDispelNameColorKeyMap) do
			tBrightMap[tDispelName] = VUHDO_safeBrightOpacityColorFromTable(tColors and tColors[tColorKey], tDefaultColor, aBrightness, aOpacity);
			tBrightOpaqueMap[tDispelName] = VUHDO_safeBrightOpaqueDispelColorFromTable(tColors and tColors[tColorKey], tTransparent, aBrightness);
			tBrightBackgroundFillMap[tDispelName] = VUHDO_safeBackgroundDispelColorFromTable(tColors and tColors[tColorKey], tDefaultColor, aBrightness, aOpacity);
			tBrightBackgroundBackingMap[tDispelName] = VUHDO_safeBackgroundDispelBackingColorFromTable(tColors and tColors[tColorKey], tTransparent, aBrightness, aOpacity);
		end

		if not sDispelTypeColorMapVariantCache[aBrightness] then
			sDispelTypeColorMapVariantCache[aBrightness] = { };
		end

		sDispelTypeColorMapVariantCache[aBrightness][aOpacity] = tBrightMap;
		sDispelTypeColorMapOpaqueBrightCache[aBrightness] = tBrightOpaqueMap;

		if not sDispelTypeBackgroundFillBrightCache[aBrightness] then
			sDispelTypeBackgroundFillBrightCache[aBrightness] = { };
		end

		sDispelTypeBackgroundFillBrightCache[aBrightness][aOpacity] = tBrightBackgroundFillMap;

		if not sDispelTypeBackgroundBackingBrightCache[aBrightness] then
			sDispelTypeBackgroundBackingBrightCache[aBrightness] = { };
		end

		sDispelTypeBackgroundBackingBrightCache[aBrightness][aOpacity] = tBrightBackgroundBackingMap;

		return;

	end



	--
	local tFillCurve;
	local tBackingCurve;
	function VUHDO_buildDispelTypeBackgroundCurveVariant(aBrightness, aOpacity)

		tFillCurve = CreateColorCurve();
		tFillCurve:SetType(Enum.LuaCurveType.Step);

		tBackingCurve = CreateColorCurve();
		tBackingCurve:SetType(Enum.LuaCurveType.Step);

		VUHDO_populateDispelTypeBackgroundCurves(tFillCurve, tBackingCurve, aBrightness, aOpacity);

		if not sDispelTypeBackgroundFillCurveCache[aBrightness] then
			sDispelTypeBackgroundFillCurveCache[aBrightness] = { };
		end

		sDispelTypeBackgroundFillCurveCache[aBrightness][aOpacity] = tFillCurve;

		if not sDispelTypeBackgroundBackingCurveCache[aBrightness] then
			sDispelTypeBackgroundBackingCurveCache[aBrightness] = { };
		end

		sDispelTypeBackgroundBackingCurveCache[aBrightness][aOpacity] = tBackingCurve;

		return;

	end
end



do
	--
	local tColors;
	local tDefaultColor;
	local tTransparent;
	local tDispelName;
	local tColorKey;
	local tPointEntry;
	function VUHDO_buildDispelTypeCurve()

		sDispelTypeCurve = CreateColorCurve();
		sDispelTypeCurve:SetType(Enum.LuaCurveType.Step);

		sDispelTypeTextCurve = CreateColorCurve();
		sDispelTypeTextCurve:SetType(Enum.LuaCurveType.Step);

		twipe(sDispelTypeColorMap);
		twipe(sDispelTypeColorMapOpaque);
		twipe(sBackgroundDispelTypeNames);
		twipe(sGlowDispelTypeNames);
		twipe(sDispelTypeBackgroundFillColorMap);
		twipe(sDispelTypeBackgroundBackingColorMap);
		twipe(sDispelTypeColorMapOpaqueBrightCache);
		twipe(sDispelTypeBackgroundFillBrightCache);
		twipe(sDispelTypeBackgroundBackingBrightCache);
		twipe(sDispelTypeColorMapVariantCache);
		twipe(sDispelTypeBackgroundFillCurveCache);
		twipe(sDispelTypeBackgroundBackingCurveCache);

		VUHDO_DISPEL_COLOR_GENERATION = VUHDO_DISPEL_COLOR_GENERATION + 1;

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];
		tDefaultColor = CreateColor(0.5, 0.5, 0.5, 1);
		tTransparent = CreateColor(0, 0, 0, 0);

		for tDispelName, tColorKey in pairs(sDispelNameColorKeyMap) do
			if tColors and tColors[tColorKey] and tColors[tColorKey]["useBackground"] then
				sBackgroundDispelTypeNames[tDispelName] = true;
			end

			if tColors and tColors[tColorKey] and tColors[tColorKey]["useGlow"] then
				sGlowDispelTypeNames[tDispelName] = true;
			end

			sDispelTypeColorMap[tDispelName] = VUHDO_safeColorFromTable(tColors and tColors[tColorKey], tDefaultColor);
			sDispelTypeColorMapOpaque[tDispelName] = VUHDO_safeOpaqueDispelColorFromTable(tColors and tColors[tColorKey], tTransparent);
			sDispelTypeBackgroundFillColorMap[tDispelName] = VUHDO_safeBackgroundDispelColorFromTable(tColors and tColors[tColorKey], tDefaultColor, 1, 1);
			sDispelTypeBackgroundBackingColorMap[tDispelName] = VUHDO_safeBackgroundDispelBackingColorFromTable(tColors and tColors[tColorKey], tTransparent, 1, 1);
		end

		if not tColors then
			sDispelTypeCurve:AddPoint(0, tDefaultColor);
			sDispelTypeTextCurve:AddPoint(0, tDefaultColor);

			sDispelTypeBackgroundFillCurve = CreateColorCurve();
			sDispelTypeBackgroundFillCurve:SetType(Enum.LuaCurveType.Step);

			sDispelTypeBackgroundBackingCurve = CreateColorCurve();
			sDispelTypeBackgroundBackingCurve:SetType(Enum.LuaCurveType.Step);

			VUHDO_populateDispelTypeBackgroundCurves(sDispelTypeBackgroundFillCurve, sDispelTypeBackgroundBackingCurve, 1, 1);

			sDispelTypeBorderCurve = CreateColorCurve();
			sDispelTypeBorderCurve:SetType(Enum.LuaCurveType.Step);
			VUHDO_populateDispelTypeBorderCurve(sDispelTypeBorderCurve);

			VUHDO_rebuildDerivedDispelTypeNameMaps();

			return;
		end

		for tIdx = 1, #sDispelTypeCurvePointKeys do
			tPointEntry = sDispelTypeCurvePointKeys[tIdx];

			sDispelTypeCurve:AddPoint(tPointEntry[1], VUHDO_safeColorFromTable(tColors[tPointEntry[2]], tDefaultColor));
			sDispelTypeTextCurve:AddPoint(tPointEntry[1], VUHDO_safeTextColorFromTable(tColors[tPointEntry[2]], tDefaultColor));
		end

		sDispelTypeBackgroundFillCurve = CreateColorCurve();
		sDispelTypeBackgroundFillCurve:SetType(Enum.LuaCurveType.Step);

		sDispelTypeBackgroundBackingCurve = CreateColorCurve();
		sDispelTypeBackgroundBackingCurve:SetType(Enum.LuaCurveType.Step);

		VUHDO_populateDispelTypeBackgroundCurves(sDispelTypeBackgroundFillCurve, sDispelTypeBackgroundBackingCurve, 1, 1);

		sDispelTypeBorderCurve = CreateColorCurve();
		sDispelTypeBorderCurve:SetType(Enum.LuaCurveType.Step);
		VUHDO_populateDispelTypeBorderCurve(sDispelTypeBorderCurve);

		VUHDO_rebuildDerivedDispelTypeNameMaps();

		return;

	end
end



do
	--
	local tColors;
	local tTransparent;
	function VUHDO_buildSingleDispelTypeCurves()

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

		tTransparent = CreateColor(0, 0, 0, 0);

		sMagicDispelCurve = CreateColorCurve();
		sMagicDispelCurve:SetType(Enum.LuaCurveType.Step);
		sMagicDispelCurve:AddPoint(0, tTransparent);
		sMagicDispelCurve:AddPoint(1, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF3"], tTransparent));

		sDiseaseDispelCurve = CreateColorCurve();
		sDiseaseDispelCurve:SetType(Enum.LuaCurveType.Step);
		sDiseaseDispelCurve:AddPoint(0, tTransparent);
		sDiseaseDispelCurve:AddPoint(3, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF2"], tTransparent));

		sPoisonDispelCurve = CreateColorCurve();
		sPoisonDispelCurve:SetType(Enum.LuaCurveType.Step);
		sPoisonDispelCurve:AddPoint(0, tTransparent);
		sPoisonDispelCurve:AddPoint(4, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF1"], tTransparent));

		sCurseDispelCurve = CreateColorCurve();
		sCurseDispelCurve:SetType(Enum.LuaCurveType.Step);
		sCurseDispelCurve:AddPoint(0, tTransparent);
		sCurseDispelCurve:AddPoint(2, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF4"], tTransparent));

		sBleedDispelCurve = CreateColorCurve();
		sBleedDispelCurve:SetType(Enum.LuaCurveType.Step);
		sBleedDispelCurve:AddPoint(0, tTransparent);
		sBleedDispelCurve:AddPoint(11, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF8"], tTransparent));

		sEnrageDispelCurve = CreateColorCurve();
		sEnrageDispelCurve:SetType(Enum.LuaCurveType.Step);
		sEnrageDispelCurve:AddPoint(0, tTransparent);
		sEnrageDispelCurve:AddPoint(9, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF9"], tTransparent));

		sDebuffTypeCurves = {
			[VUHDO_DEBUFF_TYPE_MAGIC] = sMagicDispelCurve,
			[VUHDO_DEBUFF_TYPE_DISEASE] = sDiseaseDispelCurve,
			[VUHDO_DEBUFF_TYPE_POISON] = sPoisonDispelCurve,
			[VUHDO_DEBUFF_TYPE_CURSE] = sCurseDispelCurve,
			[VUHDO_DEBUFF_TYPE_BLEED] = sBleedDispelCurve,
			[VUHDO_DEBUFF_TYPE_ENRAGE] = sEnrageDispelCurve,
		};

		twipe(sBrightnessCurveCache);
		twipe(sTextBrightnessCurveCache);

		return;

	end
end



do
	--
	local tInfo;
	local tCanAttack;
	local tCurve;
	function VUHDO_getDispelCurveForUnit(aUnit, anIsHarmful, anIsText)

		if not aUnit then
			return nil;
		end

		tInfo = VUHDO_RAID[aUnit];

		if not tInfo then
			return nil;
		end

		tCanAttack = tInfo["canAttack"];
		tCurve = anIsText and sDispelTypeTextCurve or sDispelTypeCurve;

		if not tCanAttack and anIsHarmful then
			return tCurve;
		end

		if tCanAttack and not anIsHarmful then
			return tCurve;
		end

		return nil;

	end



	--
	function VUHDO_getDispelTextCurveForUnit(aUnit, anIsHarmful)

		return VUHDO_getDispelCurveForUnit(aUnit, anIsHarmful, true);

	end
end



do
	--
	local tBouquet;
	local tSpecial;
	local tHasHealthValidator;
	local tHasPowerValidator;
	local tItem;
	local tName;
	function VUHDO_buildCurvesForBouquet(aBouquetName)

		tBouquet = VUHDO_BOUQUETS["STORED"][aBouquetName];

		if not tBouquet or type(tBouquet) ~= "table" then
			return;
		end

		sBouquetCurves[aBouquetName] = { };
		sBouquetColors[aBouquetName] = { };
		sBouquetTextColors[aBouquetName] = { };

		tHasHealthValidator = false;
		tHasPowerValidator = false;

		for tCnt = 1, #tBouquet do
			tItem = tBouquet[tCnt];
			tName = tItem["name"];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tName];

			if tSpecial then
				if tSpecial["secretType"] == VUHDO_SECRET_TYPE_BOOLEAN then
					sBouquetColors[aBouquetName][tName] = CreateColor(tItem["color"]["R"], tItem["color"]["G"], tItem["color"]["B"], 1);

					if tItem["color"]["useText"] then
						sBouquetTextColors[aBouquetName][tName] = CreateColor(tItem["color"]["TR"], tItem["color"]["TG"], tItem["color"]["TB"], 1);
					end
				elseif tSpecial["secretType"] == VUHDO_SECRET_TYPE_HEALTH_PERCENT then
					tHasHealthValidator = true;
				elseif tSpecial["secretType"] == VUHDO_SECRET_TYPE_POWER_PERCENT then
					tHasPowerValidator = true;
				end
			end
		end

		if tHasPowerValidator then
			sBouquetCurves[aBouquetName]["power"] = { };

			for tPowerType = 0, 19 do
				if VUHDO_POWER_TYPE_COLORS and VUHDO_POWER_TYPE_COLORS[tPowerType] then
					sBouquetCurves[aBouquetName]["power"][tPowerType] = VUHDO_buildCompositePowerCurve(tBouquet, tPowerType);
				end
			end
		end

		if tHasHealthValidator then
			VUHDO_prebuildHealthCurvesForBouquet(aBouquetName, tBouquet);
		end

		VUHDO_buildBouquetLayerTemplate(aBouquetName);

		return;

	end



	--
	function VUHDO_buildAllBouquetCurves()

		if not VUHDO_BOUQUETS or not VUHDO_BOUQUETS["STORED"] then
			return;
		end

		VUHDO_buildDispelTypeCurve();
		VUHDO_buildSingleDispelTypeCurves();

		return;

	end
end



do
	--
	local tItem;
	local tSpecial;
	local tSecretType;
	local tTemplate;
	local tCurveIdx;
	local tBoolIdx;
	local tDispelIdx;
	local tSpriteCellIdx;
	local tAlphaIdx;
	local tNonSecretIdx;
	local tAuraIdx;
	local tTrueColor;
	local tBouquet;
	local tAllValidators;
	local tEntry;
	local tOldTemplate;
	local tHealthRadio;
	local tCurveSlot;
	local tBuildGradMax;
	local tBuildGradMin;
	local tBuildGradFactor;
	local tTrueTextColor;
	function VUHDO_buildBouquetLayerTemplate(aBouquetName)

		tBouquet = VUHDO_BOUQUETS["STORED"][aBouquetName];

		if not tBouquet then
			return nil;
		end

		tOldTemplate = sBouquetLayerTemplates[aBouquetName];

		if tOldTemplate and tOldTemplate["sortedValidators"] then
			for tIdx = 1, #tOldTemplate["sortedValidators"] do
				sValidatorEntryPool:release(tOldTemplate["sortedValidators"][tIdx]);
			end
		end

		tTemplate = {
			["hasCurves"] = false,
			["hasBools"] = false,
			["hasDispels"] = false,
			["hasAlpha"] = false,
			["hasNonSecrets"] = false,
			["hasSecretValues"] = false,
			["hasAuras"] = false,
			["useBackground"] = false,
			["useText"] = false,
			["useOpacity"] = false,
			["baseType"] = nil,
			["curveValidators"] = { },
			["booleanValidators"] = { },
			["dispelValidators"] = { },
			["spriteCellValidators"] = { },
			["nonSecretValidators"] = { },
			["auraValidators"] = { },
			["alphaValidators"] = { },
			["curveResults"] = { },
			["booleanResults"] = { },
			["dispelResults"] = { },
			["spriteCellResults"] = { },
			["nonSecretResults"] = { },
			["auraResults"] = { },
			["alphaResults"] = { },
		};

		tCurveIdx = 0;
		tBoolIdx = 0;
		tDispelIdx = 0;
		tSpriteCellIdx = 0;
		tAlphaIdx = 0;
		tNonSecretIdx = 0;
		tAuraIdx = 0;

		for tCnt = 1, #tBouquet do
			tItem = tBouquet[tCnt];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]];

			if tSpecial and tSpecial["isGlobal"] and tItem["color"] and tItem["color"]["useOpacity"] and not tItem["color"]["useBackground"] then
				if not tTemplate["globalOpacityNames"] then
					tTemplate["globalOpacityNames"] = { };
				end

				tTemplate["globalOpacityNames"][tItem["name"]] = true;
			end

			if not tSpecial then
				tAuraIdx = tAuraIdx + 1;

				tTemplate["hasAuras"] = true;

				tTemplate["auraValidators"][tAuraIdx] = {
					["item"] = tItem,
					["index"] = tCnt,
				};

				tTemplate["auraResults"][tAuraIdx] = {
					["isActive"] = false,
					["icon"] = nil,
					["timer"] = 0,
					["counter"] = 0,
					["duration"] = 0,
					["color"] = nil,
					["clipL"] = nil,
					["clipR"] = nil,
					["clipT"] = nil,
					["clipB"] = nil,
					["name"] = nil,
				};
			else
				tSecretType = tSpecial["secretType"] or VUHDO_SECRET_TYPE_NONE;

				if tSecretType == VUHDO_SECRET_TYPE_HEALTH_PERCENT or tSecretType == VUHDO_SECRET_TYPE_POWER_PERCENT then
					tCurveIdx = tCurveIdx + 1;

					tTemplate["hasCurves"] = true;

					tTemplate["curveValidators"][tCurveIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
					};

					tTemplate["curveResults"][tCurveIdx] = {
						["isActive"] = false,
						["r"] = nil,
						["g"] = nil,
						["b"] = nil,
						["a"] = nil,
						["maxR"] = nil,
						["maxG"] = nil,
						["maxB"] = nil,
						["maxO"] = nil,
						["useBarTextureGradient"] = false,
						["gradientMinMixin"] = nil,
						["gradientMaxMixin"] = nil,
						["gradientClassMaxMixins"] = nil,
						["gradientClassMaxMixinFallback"] = nil,
						["gradientClassMinMixins"] = nil,
						["gradientClassMinMixinFallback"] = nil,
						["gradientIsClassMode"] = false,
						["value"] = nil,
						["maxValue"] = 100,
						["timer"] = 0,
						["duration"] = 0,
						["timer2"] = 0,
					};

					if tSpecial["custom_type"] == VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR and not tSpecial["no_color"] and tItem["custom"] then
						tHealthRadio = tItem["custom"]["radio"] or 3;

						if tHealthRadio == 1 and tItem["custom"]["isSolidGradient"] then
							tTemplate["curveResults"][tCurveIdx]["useBarTextureGradient"] = true;
						elseif tHealthRadio == 2 and tItem["custom"]["isClassGradient"] then
							tTemplate["curveResults"][tCurveIdx]["useBarTextureGradient"] = true;
						end

						if tTemplate["curveResults"][tCurveIdx]["useBarTextureGradient"] then
							tCurveSlot = tTemplate["curveResults"][tCurveIdx];

							if tHealthRadio == 1 and tItem["custom"]["isSolidGradient"] then
								tBuildGradMin = tItem["color"];

								if tBuildGradMin and tBuildGradMin["R"] and tBuildGradMin["G"] and tBuildGradMin["B"] then
									tCurveSlot["gradientMinMixin"] = CreateColor(
										tBuildGradMin["R"],
										tBuildGradMin["G"],
										tBuildGradMin["B"],
										tBuildGradMin["O"] or 1
									);
								end

								tBuildGradMax = tItem["custom"]["maxColor"];

								if tBuildGradMax and tBuildGradMax["R"] and tBuildGradMax["G"] and tBuildGradMax["B"] then
									tCurveSlot["gradientMaxMixin"] = CreateColor(
										tBuildGradMax["R"],
										tBuildGradMax["G"],
										tBuildGradMax["B"],
										tBuildGradMax["O"] or 1
									);
								end
							elseif tHealthRadio == 2 and tItem["custom"]["isClassGradient"] then
								tCurveSlot["gradientIsClassMode"] = true;

								VUHDO_initClassColors();

								tBuildGradFactor = tItem["custom"]["bright"] or 1;
								tCurveSlot["gradientClassMinMixins"] = { };
								tCurveSlot["gradientClassMaxMixins"] = { };

								for tBuildClassGradId, tBuildClassGradEntry in pairs(VUHDO_USER_CLASS_GRADIENT_COLORS) do
									if type(tBuildClassGradId) == "number" and tBuildClassGradEntry then
										tBuildGradMin = tBuildClassGradEntry["min"] or tItem["color"];
										tBuildGradMax = tBuildClassGradEntry["max"] or tItem["custom"]["maxColor"];

										if tBuildGradMin and tBuildGradMin["R"] and tBuildGradMin["G"] and tBuildGradMin["B"] then
											tCurveSlot["gradientClassMinMixins"][tBuildClassGradId] = CreateColor(
												tBuildGradMin["R"] * tBuildGradFactor,
												tBuildGradMin["G"] * tBuildGradFactor,
												tBuildGradMin["B"] * tBuildGradFactor,
												tBuildGradMin["O"] or 1
											);
										end

										if tBuildGradMax and tBuildGradMax["R"] and tBuildGradMax["G"] and tBuildGradMax["B"] then
											tCurveSlot["gradientClassMaxMixins"][tBuildClassGradId] = CreateColor(
												tBuildGradMax["R"] * tBuildGradFactor,
												tBuildGradMax["G"] * tBuildGradFactor,
												tBuildGradMax["B"] * tBuildGradFactor,
												tBuildGradMax["O"] or 1
											);
										end
									end
								end

								tBuildGradMin = tItem["color"];

								if tBuildGradMin and tBuildGradMin["R"] and tBuildGradMin["G"] and tBuildGradMin["B"] then
									tCurveSlot["gradientClassMinMixinFallback"] = CreateColor(
										tBuildGradMin["R"] * tBuildGradFactor,
										tBuildGradMin["G"] * tBuildGradFactor,
										tBuildGradMin["B"] * tBuildGradFactor,
										tBuildGradMin["O"] or 1
									);
								end

								tBuildGradMax = tItem["custom"]["maxColor"];

								if tBuildGradMax and tBuildGradMax["R"] and tBuildGradMax["G"] and tBuildGradMax["B"] then
									tCurveSlot["gradientClassMaxMixinFallback"] = CreateColor(
										tBuildGradMax["R"] * tBuildGradFactor,
										tBuildGradMax["G"] * tBuildGradFactor,
										tBuildGradMax["B"] * tBuildGradFactor,
										tBuildGradMax["O"] or 1
									);
								end
							end
						end
					end

					if not tTemplate["baseType"] then
						if tSecretType == VUHDO_SECRET_TYPE_HEALTH_PERCENT then
							tTemplate["baseType"] = "health";
						else
							tTemplate["baseType"] = "power";
						end
					end

					if tItem["color"] then
						if tItem["color"]["useBackground"] then
							tTemplate["useBackground"] = true;
						end

						if tItem["color"]["useText"] then
							tTemplate["useText"] = true;
						end

						if tItem["color"]["useOpacity"] then
							tTemplate["useOpacity"] = true;
						end
					end
				elseif tSecretType == VUHDO_SECRET_TYPE_BOOLEAN then
					tBoolIdx = tBoolIdx + 1;

					tTemplate["hasBools"] = true;

					tTemplate["booleanValidators"][tBoolIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
					};

					tTrueColor = VUHDO_getBouquetBoolColor(aBouquetName, tItem["name"]);
					tTrueTextColor = VUHDO_getBouquetBoolTextColor(aBouquetName, tItem["name"]);

					if tSpecial and tSpecial["isInverted"] then
						tTemplate["booleanResults"][tBoolIdx] = {
							["secretBool"] = nil,
							["trueColorMixin"] = sTransparentColor,
							["falseColorMixin"] = tTrueColor,
							["color"] = tItem["color"],
							["trueAlpha"] = 0,
							["falseAlpha"] = tItem["color"]["useOpacity"] and (tItem["color"]["O"] or 1) or 1,
							["activeTextColorMixin"] = tTrueTextColor,
						};
					else
						tTemplate["booleanResults"][tBoolIdx] = {
							["secretBool"] = nil,
							["trueColorMixin"] = tTrueColor,
							["falseColorMixin"] = sTransparentColor,
							["color"] = tItem["color"],
							["trueAlpha"] = tItem["color"]["useOpacity"] and (tItem["color"]["O"] or 1) or 1,
							["falseAlpha"] = 0,
							["activeTextColorMixin"] = tTrueTextColor,
						};
					end

					if tSpecial["isGlobal"] and tItem["color"] and tItem["color"]["useOpacity"] then
						tAlphaIdx = tAlphaIdx + 1;

						tTemplate["hasAlpha"] = true;

						tTemplate["alphaValidators"][tAlphaIdx] = {
							["item"] = tItem,
							["special"] = tSpecial,
							["index"] = tCnt,
						};

						if tSpecial and tSpecial["isInverted"] then
							tTemplate["alphaResults"][tAlphaIdx] = {
								["secretBool"] = nil,
								["trueAlpha"] = 1,
								["falseAlpha"] = tItem["color"]["O"] or 1,
							};
						else
							tTemplate["alphaResults"][tAlphaIdx] = {
								["secretBool"] = nil,
								["trueAlpha"] = tItem["color"]["O"] or 1,
								["falseAlpha"] = 1,
							};
						end
					end
				elseif tSecretType == VUHDO_SECRET_TYPE_DISPEL then
					tDispelIdx = tDispelIdx + 1;

					tTemplate["hasDispels"] = true;

					tTemplate["dispelValidators"][tDispelIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
						["debuffType"] = tSpecial["debuffType"],
					};

					if tSpecial["buildCurves"] and tItem["custom"] and tItem["custom"]["bright"] then
						tTemplate["dispelValidators"][tDispelIdx]["curves"] = tSpecial["buildCurves"](tItem["custom"]["bright"]);
					end

					if tSpecial["buildTextCurves"] and tItem["custom"] and tItem["custom"]["bright"] then
						tTemplate["dispelValidators"][tDispelIdx]["textCurves"] = tSpecial["buildTextCurves"](tItem["custom"]["bright"]);
					end

					tTemplate["dispelResults"][tDispelIdx] = {
						["isActive"] = false,
						["barColor"] = nil,
						["r"] = nil,
						["g"] = nil,
						["b"] = nil,
						["a"] = nil,
						["tr"] = nil,
						["tg"] = nil,
						["tb"] = nil,
						["ta"] = nil,
						["auraInstanceId"] = nil,
						["useBackground"] = nil,
						["useText"] = nil,
					};

					if tItem["color"] then
						if tItem["color"]["useBackground"] then
							tTemplate["useBackground"] = true;
						end

						if tItem["color"]["useText"] then
							tTemplate["useText"] = true;
						end

						if tItem["color"]["useOpacity"] then
							tTemplate["useOpacity"] = true;
						end
					end
				elseif tSecretType == VUHDO_SECRET_TYPE_SPRITE_CELL then
					tSpriteCellIdx = tSpriteCellIdx + 1;

					tTemplate["hasSpriteCells"] = true;

					tTemplate["spriteCellValidators"][tSpriteCellIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
					};

					tTemplate["spriteCellResults"][tSpriteCellIdx] = {
						["isActive"] = false,
						["icon"] = nil,
						["spriteCell"] = nil,
					};
				elseif tSecretType == VUHDO_SECRET_TYPE_NONE or tSecretType == VUHDO_SECRET_TYPE_VALUES then
					tNonSecretIdx = tNonSecretIdx + 1;

					tTemplate["hasNonSecrets"] = true;

					if tSecretType == VUHDO_SECRET_TYPE_VALUES then
						tTemplate["hasSecretValues"] = true;
					end

					tTemplate["nonSecretValidators"][tNonSecretIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
					};

					tTemplate["nonSecretResults"][tNonSecretIdx] = {
						["isActive"] = false,
						["icon"] = nil,
						["timer"] = 0,
						["counter"] = 0,
						["duration"] = 0,
						["color"] = { },
						["timer2"] = 0,
						["clipL"] = nil,
						["clipR"] = nil,
						["clipT"] = nil,
						["clipB"] = nil,
						["maxColor"] = { },
						["gradientMinMixin"] = CreateColor(0, 0, 0, 1),
						["gradientMaxMixin"] = CreateColor(0, 0, 0, 1),
					};
				end
			end
		end

		tAllValidators = { };

		if tTemplate["hasNonSecrets"] then
			for tIdx = 1, #tTemplate["nonSecretValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_NONSECRET;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["nonSecretValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		if tTemplate["hasCurves"] then
			for tIdx = 1, #tTemplate["curveValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_CURVE;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["curveValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		if tTemplate["hasBools"] then
			for tIdx = 1, #tTemplate["booleanValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_BOOLEAN;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["booleanValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		if tTemplate["hasDispels"] then
			for tIdx = 1, #tTemplate["dispelValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_DISPEL;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["dispelValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		if tTemplate["hasSpriteCells"] then
			for tIdx = 1, #tTemplate["spriteCellValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["spriteCellValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		if tTemplate["hasAuras"] then
			for tIdx = 1, #tTemplate["auraValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_AURA;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["auraValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		tsort(tAllValidators, function(a, b)
			return a["bouquetIdx"] > b["bouquetIdx"];
		end);

		tTemplate["sortedValidators"] = tAllValidators;

		sBouquetLayerTemplates[aBouquetName] = tTemplate;

		return tTemplate;

	end



	--
	function VUHDO_getBouquetLayerTemplate(aBouquetName)

		return sBouquetLayerTemplates[aBouquetName];

	end



	--
	function VUHDO_getBouquetGlobalOpacityNames(aBouquetName)

		if not sBouquetLayerTemplates[aBouquetName] then
			return nil;
		end

		return sBouquetLayerTemplates[aBouquetName]["globalOpacityNames"];

	end
end



do
	--
	local tValidators;
	local tValidatorEntry;
	function VUHDO_findDispelValidatorEntry(aLayerTemplate, aPriorityIndex)

		tValidators = aLayerTemplate["dispelValidators"];

		for tIdx = 1, #tValidators do
			tValidatorEntry = tValidators[tIdx];

			if tValidatorEntry["index"] == aPriorityIndex then
				return tValidatorEntry;
			end
		end

		return nil;

	end
end



do
	--
	function VUHDO_getColorHash(aColor)

		return
			(aColor["R"] or 0) * 0.0001
			+ (aColor["G"] or 0) * 0.001
			+ (aColor["B"] or 0) * 0.01
			+ (aColor["O"] or 0) * 0.1
			+ (aColor["TR"] or 0)
			+ (aColor["TG"] or 0) * 10
			+ (aColor["TB"] or 0) * 100
			+ (aColor["TO"] or 0) * 1000;

	end



	--
	local tHasChanged;
	local tLastTime;
	function VUHDO_hasBouquetChanged(aUnit, aBouquetName, anArg1, anArg2, anArg3, anArg4, anArg5, anArg6, anArg7, anArg8, anArg9, anArg10)

		tLastTime = VUHDO_LAST_EVALUATED_BOUQUETS[aBouquetName][aUnit];

		if not tLastTime then
			VUHDO_LAST_EVALUATED_BOUQUETS[aBouquetName][aUnit] = sBouquetStatePool:get();

			return true;
		end

		tHasChanged = false;

		if anArg1  ~= tLastTime[ 1] then
			tLastTime[ 1] = anArg1;  tHasChanged = true;
		end

		if anArg2  ~= tLastTime[ 2] then
			tLastTime[ 2] = anArg2;  tHasChanged = true;
		end

		if anArg3  ~= tLastTime[ 3] then
			tLastTime[ 3] = anArg3;  tHasChanged = true;
		end

		if anArg4  ~= tLastTime[ 4] then
			tLastTime[ 4] = anArg4;  tHasChanged = true;
		end

		if anArg5  ~= tLastTime[ 5] then
			tLastTime[ 5] = anArg5;  tHasChanged = true;
		end

		if anArg6  ~= tLastTime[ 6] then
			tLastTime[ 6] = anArg6;  tHasChanged = true;
		end

		if anArg7  ~= tLastTime[ 7] then
			tLastTime[ 7] = anArg7;  tHasChanged = true;
		end

		if anArg8  ~= tLastTime[ 8] then
			tLastTime[ 8] = anArg8;  tHasChanged = true;
		end

		if anArg9  ~= tLastTime[ 9] then
			tLastTime[ 9] = anArg9;  tHasChanged = true;
		end

		if anArg10 ~= tLastTime[10] then
			tLastTime[10] = anArg10; tHasChanged = true;
		end

		return tHasChanged;
	end
end



--
function VUHDO_releaseAndWipeLastEvaluatedBouquets()

	for tBouquetName, tUnitStates in pairs(VUHDO_LAST_EVALUATED_BOUQUETS) do
		for tUnit, tState in pairs(tUnitStates) do
			if tState then
				sBouquetStatePool:release(tState);
			end
		end
	end

	twipe(VUHDO_LAST_EVALUATED_BOUQUETS);

	return;

end



do
	--
	local function VUHDO_ensureClassColorsInitialized()

		if not VUHDO_USER_CLASS_COLORS or not VUHDO_USER_CLASS_GRADIENT_COLORS then
			VUHDO_initClassColors();
		end

		return;

	end



	--
	local tColor;
	local tFactor;
	local tModi, tInvModi;
	local tR1, tG1, tB1, tO1;
	local tR2, tG2, tB2, tO2;
	local tGood, tFair, tLow;
	local tDestColor = { ["useBackground"] = true, ["useOpacity"] = true };
	local tRadio;
	local tIsGradient;
	local tClassId;
	local tMaxColor;
	local tDestMaxColor = { ["useBackground"] = true, ["useOpacity"] = true };
	function VUHDO_getBouquetStatusBarColor(anEntry, anInfo, aValue, aMaxValue)

		VUHDO_ensureClassColorsInitialized();

		tRadio = anEntry["custom"]["radio"];

		if 1 == tRadio then -- solid
			tColor = anEntry["color"];
			tIsGradient = anEntry["custom"]["isSolidGradient"];

			if tIsGradient then
				tMaxColor = anEntry["custom"]["maxColor"];

				tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"] = tColor["R"], tColor["G"], tColor["B"], tColor["O"] or 1;

				if tMaxColor then
					tDestMaxColor["R"], tDestMaxColor["G"], tDestMaxColor["B"], tDestMaxColor["O"]
						= tMaxColor["R"], tMaxColor["G"], tMaxColor["B"], tMaxColor["O"] or 1;

					return tDestColor, tDestMaxColor;
				else
					return tDestColor, nil;
				end
			else
				tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"] = tColor["R"], tColor["G"], tColor["B"], tColor["O"] or 1;

				return tDestColor, nil;
			end
		elseif 2 == tRadio then -- class color
			tClassId = anInfo["classId"];
			tFactor = anEntry["custom"]["bright"];
			tIsGradient = anEntry["custom"]["isClassGradient"];

			if anInfo["hasSecretClass"] and not (VUHDO_USER_CLASS_COLORS and VUHDO_USER_CLASS_COLORS[tClassId]) then
				return VUHDO_getBlizzardClassColorMixin(anInfo["class"]), nil;
			end

			if tIsGradient then
				if VUHDO_USER_CLASS_GRADIENT_COLORS and VUHDO_USER_CLASS_GRADIENT_COLORS[tClassId] then
					tColor = VUHDO_USER_CLASS_GRADIENT_COLORS[tClassId]["min"] or anEntry["color"];
					tMaxColor = VUHDO_USER_CLASS_GRADIENT_COLORS[tClassId]["max"] or anEntry["custom"]["maxColor"];
				else
					tColor = anEntry["color"];
					tMaxColor = anEntry["custom"]["maxColor"];
				end

				tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"]
					= tColor["R"] * tFactor, tColor["G"] * tFactor, tColor["B"] * tFactor, tColor["O"] or 1;

				if tMaxColor then
					tDestMaxColor["R"], tDestMaxColor["G"], tDestMaxColor["B"], tDestMaxColor["O"]
						= tMaxColor["R"] * tFactor, tMaxColor["G"] * tFactor, tMaxColor["B"] * tFactor, tMaxColor["O"] or 1;

					return tDestColor, tDestMaxColor;
				else
					return tDestColor, nil;
				end
			else
				if VUHDO_USER_CLASS_COLORS and VUHDO_USER_CLASS_COLORS[tClassId] then
					tColor = VUHDO_USER_CLASS_COLORS[tClassId] or anEntry["color"];
				else
					tColor = anEntry["color"];
				end

				tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"]
					= tColor["R"] * tFactor, tColor["G"] * tFactor, tColor["B"] * tFactor, tColor["O"] or 1;

				return tDestColor, nil;
			end
		elseif not issecretvalue(aValue) and not issecretvalue(aMaxValue) and aMaxValue ~= 0 then -- 3 == gradient
			tModi = ((aValue / aMaxValue) ^ 1.7) * 2;
			tFair = anEntry["custom"]["grad_med"];

			if tModi > 1 then
				tGood = anEntry["custom"]["grad_high"] or anEntry["color"];
				tR1, tG1, tB1, tO1 = tGood["R"], tGood["G"], tGood["B"], tGood["O"];
				tR2, tG2, tB2, tO2 = tFair["R"], tFair["G"], tFair["B"], tFair["O"];
				tModi = tModi - 1;
			else
				tLow = anEntry["custom"]["grad_low"];
				tR1, tG1, tB1, tO1 = tFair["R"], tFair["G"], tFair["B"], tFair["O"];
				tR2, tG2, tB2, tO2 = tLow["R"], tLow["G"], tLow["B"], tLow["O"];
			end

			tInvModi = 1 - tModi;
			tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"]
				= tR2 * tInvModi + tR1 * tModi, tG2 * tInvModi + tG1 * tModi,
				tB2 * tInvModi + tB1 * tModi, tO2 * tInvModi + tO1 * tModi;

			return tDestColor, nil;
		else
			tColor = anEntry["color"];

			tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"] = tColor["R"], tColor["G"], tColor["B"], tColor["O"] or 1;

			return tDestColor, nil;
		end

		return;

	end
end



--
local txState = {
	["active"] = false,
	["icon"] = nil,
	["name"] = nil,

	["color"] = { },
	["isColorInit"] = false,

	["maxColor"] = { },
	["isMaxColorInit"] = false,

	["counter"] = 0,
	["timer"] = 0,
	["duration"] = 0,
	["timer2"] = 0,
	["level"] = 0,
	["activeAuras"] = 0,

	["clipL"] = nil,
	["clipR"] = nil,
	["clipT"] = nil,
	["clipB"] = nil,

	["workingColor"] = { },
	["secretContext"] = { },
};



--
function VUHDO_getIsCurrentBouquetActive()

	return txState["active"];

end



--
function VUHDO_getCurrentBouquetColor()

	if not txState["isColorInit"] then
		twipe(txState["color"]);
	end

	return txState["color"];

end



--
function VUHDO_getCurrentBouquetStacks()

	return txState["counter"];

end



--
function VUHDO_getCurrentBouquetTimer()

	return txState["timer"];

end



--
function VUHDO_getCurrentBouquetActiveAuras()

	return txState["activeAuras"];

end



do
	--
	local tInfos;
	local tResultSlot;
	local tName;
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tColor;
	local tAuraInstances;
	local tCachedAura;
	local tSpellId;
	local tExpiration;
	local tNow;



	--
	function VUHDO_evaluateBouquetSecretAuraLayer(aUnit, aInfo, aBouquet, aLayerTemplate, aValidatorEntry, aCnt)

		tInfos = aBouquet[aCnt];
		tResultSlot = aLayerTemplate["auraResults"][aValidatorEntry["resultIdx"]];

		if tResultSlot and not VUHDO_isAuraModeContainers() and not VUHDO_isAuraDataRestricted() then
			tName = tInfos["name"];
			tIsActive = false;
			tSpellId = tonumber(tName);

			tAuraInstances = VUHDO_UNIT_AURA_BY_SPELL[aUnit] and
				(VUHDO_UNIT_AURA_BY_SPELL[aUnit][tName] or (tSpellId and VUHDO_UNIT_AURA_BY_SPELL[aUnit][tSpellId]));

			if tAuraInstances then
				for _, tAuraInstanceId in ipairs(tAuraInstances) do
					if not ShouldUnitAuraInstanceBeSecret(aUnit, tAuraInstanceId) then
						tCachedAura = VUHDO_UNIT_AURA_CACHE[aUnit] and VUHDO_UNIT_AURA_CACHE[aUnit][tAuraInstanceId];

						if tCachedAura and VUHDO_auraSourceMatchesFilter(tCachedAura, tInfos) then
							tIsActive = true;
							txState["activeAuras"] = txState["activeAuras"] + 1;

							tNow = GetTime();

							if issecretvalue(tCachedAura["expirationTime"]) or issecretvalue(tCachedAura["duration"]) then
								tTimer = tCachedAura["expirationTime"];
								tDuration = tCachedAura["duration"];
							else
								tExpiration = tCachedAura["expirationTime"] or 0;
								tDuration = tCachedAura["duration"] or 0;

								if tExpiration == 0 and tDuration == 0 then
									tExpiration = tNow + 9999;

									tDuration = 9999;
								end

								if tInfos["alive"] then
									tTimer = tNow - tExpiration + tDuration;
								else
									tTimer = tExpiration - tNow;
								end

								if tTimer then
									tTimer = floor(tTimer * 10) * 0.1;
								end
							end

							tIcon = tCachedAura["icon"];
							tCounter = tCachedAura["applications"];

							tColor = tInfos["color"];

							if tInfos["icon"] ~= 1 then
								tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2];

								tColor["isDefault"] = false;
							else
								tColor["isDefault"] = true;
							end

							tResultSlot["isActive"] = true;
							tResultSlot["icon"] = tIcon;
							tResultSlot["timer"] = tTimer or 0;
							tResultSlot["counter"] = tCounter or 0;
							tResultSlot["duration"] = tDuration or 0;
							tResultSlot["color"] = tColor;
							tResultSlot["name"] = tName;
							tResultSlot["isAliveTime"] = tInfos["alive"];

							break;
						end
					end
				end
			end
		end

		tResultSlot = aLayerTemplate["auraResults"][aValidatorEntry["resultIdx"]];

		if tResultSlot and tResultSlot["isActive"] then
			txState["active"] = true;
			txState["name"] = tResultSlot["name"];
			txState["level"] = aLayerTemplate["auraValidators"][aValidatorEntry["resultIdx"]]["index"];

			if tResultSlot["icon"] then
				txState["icon"] = tResultSlot["icon"];
			end

			tColor = tResultSlot["color"];

			if tColor then
				if not txState["isColorInit"] then
					twipe(txState["color"]);
					txState["isColorInit"] = true;
				end

				if tColor["useText"] then
					txState["color"]["useText"] = true;
					txState["color"]["TR"] = tColor["TR"];
					txState["color"]["TG"] = tColor["TG"];
					txState["color"]["TB"] = tColor["TB"];

					if not tColor["useOpacity"] then
						txState["color"]["TO"] = tColor["TO"];
					end
				end

				if tColor["useBackground"] then
					txState["color"]["useBackground"] = true;
					txState["color"]["R"] = tColor["R"];
					txState["color"]["G"] = tColor["G"];
					txState["color"]["B"] = tColor["B"];

					if not tColor["useOpacity"] then
						txState["color"]["O"] = tColor["O"];
					end
				end

				if tColor["useOpacity"] then
					txState["color"]["useOpacity"] = true;

					if tColor["TO"] ~= nil then
						txState["color"]["TO"] = (txState["color"]["TO"] or 1) * tColor["TO"];
					end

					if tColor["O"] ~= nil then
						txState["color"]["O"] = (txState["color"]["O"] or 1) * tColor["O"];
					end
				end

				txState["color"]["isDefault"] = tColor["isDefault"];
			end

			tCounter = tResultSlot["counter"] or 0;

			if issecretvalue(tCounter) or tCounter >= 0 then
				txState["counter"] = tCounter;
			end

			tTimer = tResultSlot["timer"] or 0;
			tDuration = tResultSlot["duration"] or 0;

			if (issecretvalue(tDuration) or tDuration >= 0) and (issecretvalue(tTimer) or tTimer >= 0) then
				txState["timer"] = tTimer;
				txState["duration"] = tDuration;
			end

			txState["isAliveTime"] = tResultSlot["isAliveTime"] or false;
		end

		return;

	end
end



do
	--
	local tInfos;
	local tSpecial;
	local tSecretType;
	local tResultSlot;
	local tName;
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tTimer2;
	local tColor;
	local tFactor;
	local tMaxColor;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;



	--
	function VUHDO_evaluateBouquetSecretNonSecretLayer(aUnit, aInfo, aBouquet, aLayerTemplate, aValidatorEntry, aCnt)

		tInfos = aBouquet[aCnt];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tInfos["name"]];
		tSecretType = tSpecial["secretType"] or VUHDO_SECRET_TYPE_NONE;

		if tSecretType == VUHDO_SECRET_TYPE_NONE or tSecretType == VUHDO_SECRET_TYPE_VALUES then
			tResultSlot = aLayerTemplate["nonSecretResults"][aValidatorEntry["resultIdx"]];

			if tResultSlot then
				tName = nil;

				tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, tClipL, tClipR, tClipT, tClipB = tSpecial["validator"](aInfo, tInfos, sSecretsEnabled and txState["secretContext"] or nil);

				tResultSlot["isActive"] = tIsActive;

				if tIsActive then
					if tInfos["icon"] ~= 1 then
						tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2];
					end

					if not tColor then
						if 3 == tSpecial["custom_type"] then
							tColor, tMaxColor = VUHDO_getBouquetStatusBarColor(tInfos, aInfo, tTimer, tDuration);
						end

						if not tColor then
							tColor = tInfos["color"];
						end
					elseif 4 == tSpecial["custom_type"] then
						tMaxColor = nil;

						tColor = VUHDO_copyColorTo(tColor, txState["workingColor"]);
						tFactor = tInfos["custom"]["bright"];

						if tColor["useBackground"] then
							tColor["R"], tColor["G"], tColor["B"] = tColor["R"] * tFactor, tColor["G"] * tFactor, tColor["B"] * tFactor;
						end

						if tColor["useText"] then
							tColor["TR"], tColor["TG"], tColor["TB"] = tColor["TR"] * tFactor, tColor["TG"] * tFactor, tColor["TB"] * tFactor;
						end
					else
						tMaxColor = nil;
					end

					if tColor["useText"] then
						tColor["useText"] = tInfos["color"]["useText"];
					end

					if tColor["useBackground"] then
						tColor["useBackground"] = tInfos["color"]["useBackground"];
					end

					if tColor["useOpacity"] then
						tColor["useOpacity"] = tInfos["color"]["useOpacity"];
					end

					tResultSlot["icon"] = tIcon;
					tResultSlot["timer"] = tTimer or 0;
					tResultSlot["counter"] = tCounter or 0;
					tResultSlot["duration"] = tDuration or 0;

					if tColor then
						VUHDO_copyColorTo(tColor, tResultSlot["color"]);
					end

					tResultSlot["timer2"] = tTimer2 or 0;
					tResultSlot["clipL"] = tClipL;
					tResultSlot["clipR"] = tClipR;
					tResultSlot["clipT"] = tClipT;
					tResultSlot["clipB"] = tClipB;

					if tMaxColor then
						VUHDO_copyColorTo(tMaxColor, tResultSlot["maxColor"]);

						tResultSlot["gradientMinMixin"]:SetRGBA(tResultSlot["color"]["R"], tResultSlot["color"]["G"], tResultSlot["color"]["B"], tResultSlot["color"]["O"] or 1);
						tResultSlot["gradientMaxMixin"]:SetRGBA(tResultSlot["maxColor"]["R"], tResultSlot["maxColor"]["G"], tResultSlot["maxColor"]["B"], tResultSlot["maxColor"]["O"] or 1);
					end
				end
			end
		end

		tResultSlot = aLayerTemplate["nonSecretResults"][aValidatorEntry["resultIdx"]];

		if tResultSlot and tResultSlot["isActive"] then
			txState["active"] = true;
			txState["level"] = aLayerTemplate["nonSecretValidators"][aValidatorEntry["resultIdx"]]["index"];

			if tResultSlot["icon"] then
				txState["icon"] = tResultSlot["icon"];
				txState["clipL"] = tResultSlot["clipL"];
				txState["clipR"] = tResultSlot["clipR"];
				txState["clipT"] = tResultSlot["clipT"];
				txState["clipB"] = tResultSlot["clipB"];
			end

			tColor = tResultSlot["color"];

			if tColor then
				if not txState["isColorInit"] then
					twipe(txState["color"]);
					txState["isColorInit"] = true;
				end

				if tColor["useText"] then
					txState["color"]["useText"] = true;
					txState["color"]["TR"] = tColor["TR"];
					txState["color"]["TG"] = tColor["TG"];
					txState["color"]["TB"] = tColor["TB"];

					if not tColor["useOpacity"] then
						txState["color"]["TO"] = tColor["TO"];
					end
				end

				if tColor["useBackground"] then
					txState["color"]["useBackground"] = true;
					txState["color"]["R"] = tColor["R"];
					txState["color"]["G"] = tColor["G"];
					txState["color"]["B"] = tColor["B"];

					if not tColor["useOpacity"] then
						txState["color"]["O"] = tColor["O"];
					end
				end

				if tColor["useOpacity"] then
					txState["color"]["useOpacity"] = true;

					if tColor["TO"] ~= nil then
						txState["color"]["TO"] = (txState["color"]["TO"] or 1) * tColor["TO"];
					end

					if tColor["O"] ~= nil then
						txState["color"]["O"] = (txState["color"]["O"] or 1) * tColor["O"];
					end
				end

				txState["color"]["isDefault"] = tColor["isDefault"];
				txState["color"]["noStacksColor"] = tColor["noStacksColor"];
				txState["color"]["useSlotColor"] = tColor["useSlotColor"];

				tMaxColor = tResultSlot["maxColor"];

				if tMaxColor then
					if not txState["isMaxColorInit"] then
						twipe(txState["maxColor"]);
						txState["isMaxColorInit"] = true;
					end

					if tMaxColor["useText"] then
						txState["maxColor"]["useText"] = true;
						txState["maxColor"]["TR"] = tMaxColor["TR"];
						txState["maxColor"]["TG"] = tMaxColor["TG"];
						txState["maxColor"]["TB"] = tMaxColor["TB"];

						if not tMaxColor["useOpacity"] then
							txState["maxColor"]["TO"] = tMaxColor["TO"];
						end
					end

					if tMaxColor["useBackground"] then
						txState["maxColor"]["useBackground"] = true;
						txState["maxColor"]["R"] = tMaxColor["R"];
						txState["maxColor"]["G"] = tMaxColor["G"];
						txState["maxColor"]["B"] = tMaxColor["B"];

						if not tMaxColor["useOpacity"] then
							txState["maxColor"]["O"] = tMaxColor["O"];
						end
					end

					if tMaxColor["useOpacity"] then
						txState["maxColor"]["useOpacity"] = true;

						if tMaxColor["TO"] ~= nil then
							txState["maxColor"]["TO"] = (txState["maxColor"]["TO"] or 1) * tMaxColor["TO"];
						end

						if tMaxColor["O"] ~= nil then
							txState["maxColor"]["O"] = (txState["maxColor"]["O"] or 1) * tMaxColor["O"];
						end
					end
				end
			end

			tCounter = tResultSlot["counter"] or 0;

			if issecretvalue(tCounter) or tCounter >= 0 then
				txState["counter"] = tCounter;
			end

			tTimer = tResultSlot["timer"] or 0;
			tTimer2 = tResultSlot["timer2"] or 0;
			tDuration = tResultSlot["duration"] or 0;

			if issecretvalue(tDuration) or tDuration >= 0 then
				if issecretvalue(tTimer) or tTimer >= 0 then
					txState["timer"] = tTimer;
					txState["duration"] = tDuration;
				end

				if issecretvalue(tTimer2) or tTimer2 >= 0 then
					txState["timer2"] = tTimer2;
				end
			end
		end



		return;

	end
end



do
	--
	local tInfos;
	local tSpecial;
	local tSecretType;
	local tResultSlot;
	local tIsActive;
	local tTimer;
	local tDuration;
	local tTimer2;
	local tSecretColor;
	local tGradientClassId;



	--
	function VUHDO_evaluateBouquetSecretCurveLayer(aUnit, aInfo, aBouquet, aLayerTemplate, aValidatorEntry, aCnt)

		tInfos = aBouquet[aCnt];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tInfos["name"]];
		tSecretType = tSpecial["secretType"] or VUHDO_SECRET_TYPE_NONE;
		tResultSlot = aLayerTemplate["curveResults"][aValidatorEntry["resultIdx"]];

		if tSecretType == VUHDO_SECRET_TYPE_HEALTH_PERCENT then
			if tResultSlot then
				tIsActive, _, tTimer, _, tDuration, _, tTimer2, _, _, _, _, _, tSecretColor = tSpecial["validator"](aInfo, tInfos, sSecretsEnabled and txState["secretContext"] or nil);

				tResultSlot["isActive"] = tIsActive;

				if tIsActive then
					if tSecretColor and tSecretColor.GetRGBA then
						tResultSlot["r"], tResultSlot["g"], tResultSlot["b"], tResultSlot["a"] = tSecretColor:GetRGBA();
					end

					tResultSlot["value"] = UnitHealthPercent(aUnit);
					tResultSlot["timer"] = tTimer or 0;
					tResultSlot["duration"] = tDuration or 0;
					tResultSlot["timer2"] = tTimer2 or 0;
				end

				if tResultSlot["useBarTextureGradient"] and tIsActive and tResultSlot["gradientIsClassMode"] then
					tGradientClassId = aInfo["classId"];

					tResultSlot["gradientMinMixin"] = tResultSlot["gradientClassMinMixins"][tGradientClassId] or tResultSlot["gradientClassMinMixinFallback"];
					tResultSlot["gradientMaxMixin"] = tResultSlot["gradientClassMaxMixins"][tGradientClassId] or tResultSlot["gradientClassMaxMixinFallback"];
				end
			end
		elseif tSecretType == VUHDO_SECRET_TYPE_POWER_PERCENT then
			if tResultSlot then
				tIsActive, _, tTimer, _, tDuration, _, tTimer2, _, _, _, _, _, tSecretColor = tSpecial["validator"](aInfo, tInfos, sSecretsEnabled and txState["secretContext"] or nil);

				tResultSlot["isActive"] = tIsActive;

				if tIsActive then
					if tSecretColor and not issecretvalue(tSecretColor) then
						tResultSlot["r"], tResultSlot["g"], tResultSlot["b"], tResultSlot["a"] =
						tSecretColor:GetRGBA();
					end

					tResultSlot["value"] = UnitPowerPercent(aUnit, aInfo["powertype"]);
					tResultSlot["timer"] = tTimer or 0;
					tResultSlot["duration"] = tDuration or 0;
					tResultSlot["timer2"] = tTimer2 or 0;
				end

				if tResultSlot["useBarTextureGradient"] and tIsActive and tResultSlot["gradientIsClassMode"] then
					tGradientClassId = aInfo["classId"];

					tResultSlot["gradientMinMixin"] = tResultSlot["gradientClassMinMixins"][tGradientClassId] or tResultSlot["gradientClassMinMixinFallback"];
					tResultSlot["gradientMaxMixin"] = tResultSlot["gradientClassMaxMixins"][tGradientClassId] or tResultSlot["gradientClassMaxMixinFallback"];
				end
			end
		end

		tResultSlot = aLayerTemplate["curveResults"][aValidatorEntry["resultIdx"]];

		if tResultSlot and tResultSlot["isActive"] then
			txState["active"] = true;

			tTimer = tResultSlot["timer"] or 0;
			tDuration = tResultSlot["duration"] or 0;
			tTimer2 = tResultSlot["timer2"] or 0;

			if (issecretvalue(tDuration) or tDuration >= 0) and (issecretvalue(tTimer) or tTimer >= 0) then
				txState["timer"] = tTimer;
				txState["duration"] = tDuration;
			end

			if issecretvalue(tTimer2) or tTimer2 >= 0 then
				txState["timer2"] = tTimer2;
			end
		end



		return;

	end
end



do
	--
	local tInfos;
	local tSpecial;
	local tResultSlot;
	local tBooleanSecretBool;



	--
	function VUHDO_evaluateBouquetSecretBooleanLayer(aUnit, aInfo, aBouquet, aLayerTemplate, aValidatorEntry, aCnt)

		tInfos = aBouquet[aCnt];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tInfos["name"]];
		tResultSlot = aLayerTemplate["booleanResults"][aValidatorEntry["resultIdx"]];

		if tResultSlot then
			_, _, _, _, _, _, _, _, _, _, _, tBooleanSecretBool = tSpecial["validator"](aInfo, tInfos, sSecretsEnabled and txState["secretContext"] or nil);

			tResultSlot["secretBool"] = tBooleanSecretBool;
		end



		return;

	end
end



do
	--
	local tInfos;
	local tSpecial;
	local tResultSlot;
	local tIsActive;
	local tColor;
	local tFactor;
	local tSecretColor;
	local tDispelValidatorEntry;
	local tBarColorType;
	local tTextColorType;
	local tNeedsCopy;
	local tAuraInstanceId;



	--
	function VUHDO_evaluateBouquetSecretDispelLayer(aUnit, aInfo, aBouquet, aLayerTemplate, aValidatorEntry, aCnt)

		tInfos = aBouquet[aCnt];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tInfos["name"]];
		tResultSlot = aLayerTemplate["dispelResults"][aValidatorEntry["resultIdx"]];

		if tResultSlot then
			tDispelValidatorEntry = VUHDO_findDispelValidatorEntry(aLayerTemplate, aCnt);

			if tDispelValidatorEntry and tDispelValidatorEntry["curves"] and tDispelValidatorEntry["special"]["getCurve"] then
				txState["secretContext"]["dispelCurve"] = tDispelValidatorEntry["special"]["getCurve"](tDispelValidatorEntry["curves"], aUnit, true);
			else
				txState["secretContext"]["dispelCurve"] = nil;
			end

			if tDispelValidatorEntry and tDispelValidatorEntry["textCurves"] and tDispelValidatorEntry["special"]["getTextCurve"] then
				txState["secretContext"]["dispelTextCurve"] = tDispelValidatorEntry["special"]["getTextCurve"](tDispelValidatorEntry["textCurves"], aUnit, true);
			else
				txState["secretContext"]["dispelTextCurve"] = nil;
			end

			tIsActive, _, _, _, _, tColor, _, _, _, _, _, tAuraInstanceId, tSecretColor = tSpecial["validator"](aInfo, tInfos, sSecretsEnabled and txState["secretContext"] or nil);

			tResultSlot["isActive"] = tIsActive;

			if tIsActive then
				if tColor then
					tBarColorType = VUHDO_getAuraBarColorType(aUnit);
					tTextColorType = VUHDO_getAuraTextColorType(aUnit);

					tFactor = tInfos["custom"] and tInfos["custom"]["bright"] or 1;

					tNeedsCopy = false;

					if sIsDispelColorType[tBarColorType] then
						tResultSlot["r"] = tColor["R"];
						tResultSlot["g"] = tColor["G"];
						tResultSlot["b"] = tColor["B"];
						tResultSlot["a"] = tColor["O"];

						tResultSlot["useBackground"] = tColor["useBackground"];
					else
						if tFactor < 1 and tColor["useBackground"] then
							tColor = VUHDO_copyColorTo(tColor, txState["workingColor"]);

							tNeedsCopy = true;

							tColor["R"] = tColor["R"] * tFactor;
							tColor["G"] = tColor["G"] * tFactor;
							tColor["B"] = tColor["B"] * tFactor;
						end
					end

					if sIsDispelColorType[tTextColorType] then
						tResultSlot["tr"] = tColor["TR"];
						tResultSlot["tg"] = tColor["TG"];
						tResultSlot["tb"] = tColor["TB"];
						tResultSlot["ta"] = tColor["TO"];

						tResultSlot["useText"] = tColor["useText"];
					else
						if tFactor < 1 and tColor["useText"] then
							if not tNeedsCopy then
								tColor = VUHDO_copyColorTo(tColor, txState["workingColor"]);
							end

							tColor["TR"] = tColor["TR"] * tFactor;
							tColor["TG"] = tColor["TG"] * tFactor;
							tColor["TB"] = tColor["TB"] * tFactor;
						end
					end

					if not sIsDispelColorType[tBarColorType] or not sIsDispelColorType[tTextColorType] then
						tResultSlot["barColor"] = tColor;
					end
				end

				if tAuraInstanceId and not issecretvalue(tAuraInstanceId) then
					tResultSlot["auraInstanceId"] = tAuraInstanceId;
				end

				if tSecretColor then
					tResultSlot["r"], tResultSlot["g"], tResultSlot["b"], tResultSlot["a"] = tSecretColor:GetRGBA();
				end
			end
		end

		if aLayerTemplate["dispelResults"][aValidatorEntry["resultIdx"]]["isActive"] then
			txState["active"] = true;
		end

		return;

	end
end



do
	--
	local tInfos;
	local tSpecial;
	local tResultSlot;
	local tIsActive;
	local tIcon;
	local tSpriteCell;



	--
	function VUHDO_evaluateBouquetSecretSpriteCellLayer(aUnit, aInfo, aBouquet, aLayerTemplate, aValidatorEntry, aCnt)

		tInfos = aBouquet[aCnt];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tInfos["name"]];
		tResultSlot = aLayerTemplate["spriteCellResults"][aValidatorEntry["resultIdx"]];

		if tResultSlot then
			tIsActive, tIcon, _, _, _, _, _, _, _, _, _, tSpriteCell = tSpecial["validator"](aInfo, tInfos, sSecretsEnabled and txState["secretContext"] or nil);

			tResultSlot["isActive"] = tIsActive;

			if tIsActive then
				tResultSlot["icon"] = tIcon;
				tResultSlot["spriteCell"] = tSpriteCell;
			end
		end

		tResultSlot = aLayerTemplate["spriteCellResults"][aValidatorEntry["resultIdx"]];

		if tResultSlot and tResultSlot["isActive"] then
			txState["active"] = true;
			txState["icon"] = tResultSlot["icon"];
		end



		return;

	end
end



do
	--
	local tHealthCurve;
	local tValidatorEntry;
	local tCnt;
	local tResultSlot;
	local tSecretBool;



	--
	function VUHDO_evaluateBouquetSecret(aUnit, aBouquetName, aInfo, aBouquet, aAnzInfos, aLayerTemplate)

		txState["activeAuras"] = 0;

		if sSecretsEnabled then
			txState["secretContext"]["powerCurves"] = sBouquetCurves[aBouquetName] and sBouquetCurves[aBouquetName]["power"];
			tHealthCurve = VUHDO_getHealthCurve(aBouquetName, aInfo["classId"]);

			txState["secretContext"]["blizzardClassColor"] = nil;

			if not tHealthCurve and aInfo["hasSecretClass"] then
				txState["secretContext"]["blizzardClassColor"] = VUHDO_getBlizzardClassColorMixin(aInfo["class"]);
			end

			txState["secretContext"]["healthCurve"] = tHealthCurve;
			txState["secretContext"]["dispelCurves"] = sDebuffTypeCurves;
			txState["secretContext"]["defaultDispelCurve"] = VUHDO_getDispelTypeCurve();
		end

		if aLayerTemplate then
			for tIdx = 1, #aLayerTemplate["nonSecretResults"] do
				aLayerTemplate["nonSecretResults"][tIdx]["isActive"] = false;
			end

			for tIdx = 1, #aLayerTemplate["auraResults"] do
				aLayerTemplate["auraResults"][tIdx]["isActive"] = false;
			end

			for tIdx = 1, #aLayerTemplate["curveResults"] do
				aLayerTemplate["curveResults"][tIdx]["isActive"] = false;
				aLayerTemplate["curveResults"][tIdx]["r"] = nil;
				aLayerTemplate["curveResults"][tIdx]["g"] = nil;
				aLayerTemplate["curveResults"][tIdx]["b"] = nil;
				aLayerTemplate["curveResults"][tIdx]["a"] = nil;
				aLayerTemplate["curveResults"][tIdx]["maxR"] = nil;
				aLayerTemplate["curveResults"][tIdx]["maxG"] = nil;
				aLayerTemplate["curveResults"][tIdx]["maxB"] = nil;
				aLayerTemplate["curveResults"][tIdx]["maxO"] = nil;
				aLayerTemplate["curveResults"][tIdx]["timer"] = 0;
				aLayerTemplate["curveResults"][tIdx]["duration"] = 0;
				aLayerTemplate["curveResults"][tIdx]["timer2"] = 0;
			end

			for tIdx = 1, #aLayerTemplate["booleanResults"] do
				aLayerTemplate["booleanResults"][tIdx]["secretBool"] = nil;
			end

			for tIdx = 1, #aLayerTemplate["dispelResults"] do
				aLayerTemplate["dispelResults"][tIdx]["isActive"] = false;
				aLayerTemplate["dispelResults"][tIdx]["barColor"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["r"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["g"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["b"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["a"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["tr"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["tg"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["tb"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["ta"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["auraInstanceId"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["useBackground"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["useText"] = nil;
			end

			for tIdx = 1, #aLayerTemplate["spriteCellResults"] do
				aLayerTemplate["spriteCellResults"][tIdx]["isActive"] = false;
				aLayerTemplate["spriteCellResults"][tIdx]["icon"] = nil;
				aLayerTemplate["spriteCellResults"][tIdx]["spriteCell"] = nil;
			end

			txState["isColorInit"] = false;
			txState["isMaxColorInit"] = false;

			for tSortedIdx = 1, #aLayerTemplate["sortedValidators"] do
				tValidatorEntry = aLayerTemplate["sortedValidators"][tSortedIdx];
				tCnt = tValidatorEntry["bouquetIdx"];

				if VUHDO_BOUQUET_LAYER_TYPE_NONSECRET == tValidatorEntry["type"] then
					VUHDO_evaluateBouquetSecretNonSecretLayer(aUnit, aInfo, aBouquet, aLayerTemplate, tValidatorEntry, tCnt);
				elseif VUHDO_BOUQUET_LAYER_TYPE_AURA == tValidatorEntry["type"] then
					VUHDO_evaluateBouquetSecretAuraLayer(aUnit, aInfo, aBouquet, aLayerTemplate, tValidatorEntry, tCnt);
				elseif VUHDO_BOUQUET_LAYER_TYPE_CURVE == tValidatorEntry["type"] then
					VUHDO_evaluateBouquetSecretCurveLayer(aUnit, aInfo, aBouquet, aLayerTemplate, tValidatorEntry, tCnt);
				elseif VUHDO_BOUQUET_LAYER_TYPE_BOOLEAN == tValidatorEntry["type"] then
					VUHDO_evaluateBouquetSecretBooleanLayer(aUnit, aInfo, aBouquet, aLayerTemplate, tValidatorEntry, tCnt);
				elseif VUHDO_BOUQUET_LAYER_TYPE_DISPEL == tValidatorEntry["type"] then
					VUHDO_evaluateBouquetSecretDispelLayer(aUnit, aInfo, aBouquet, aLayerTemplate, tValidatorEntry, tCnt);
				elseif VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL == tValidatorEntry["type"] then
					VUHDO_evaluateBouquetSecretSpriteCellLayer(aUnit, aInfo, aBouquet, aLayerTemplate, tValidatorEntry, tCnt);
				end
			end

			if aLayerTemplate["hasAlpha"] then
				for tIdx = 1, #aLayerTemplate["alphaValidators"] do
					tValidatorEntry = aLayerTemplate["alphaValidators"][tIdx];
					tResultSlot = aLayerTemplate["alphaResults"][tIdx];

					_, _, _, _, _, _, _, _, _, _, _, tSecretBool = tValidatorEntry["special"]["validator"](aInfo, tValidatorEntry["item"], sSecretsEnabled and txState["secretContext"] or nil);

					tResultSlot["secretBool"] = tSecretBool;
				end
			end

			if aLayerTemplate["hasBools"] and not aLayerTemplate["hasCurves"] and not aLayerTemplate["hasDispels"]
				and not aLayerTemplate["hasNonSecrets"] and not aLayerTemplate["hasAuras"] then
				txState["active"] = true;
			end
		end

		return;

	end
end



do
	--
	local tInfos;
	local tName;
	local tSpecial;
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tSourceType;
	local tUnitHot;
	local tUnitHotInfo;
	local tNow;
	local tTimer2;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tColor;
	local tFactor;
	local tMaxColor;
	local tWorkingColor = { };



	--
	function VUHDO_evaluateBouquetNonSecret(aUnit, aInfo, aBouquet, aAnzInfos)

		for tCnt = aAnzInfos, 1, -1  do
			tInfos = aBouquet[tCnt];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tInfos["name"]];

			if tSpecial then
				tName = nil;

				tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, tClipL, tClipR, tClipT, tClipB = tSpecial["validator"](aInfo, tInfos);

				if tIsActive then
					if tInfos["icon"] ~= 1 then	tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2]; end

					if not tColor then
						if 3 == tSpecial["custom_type"] then
							tColor, tMaxColor = VUHDO_getBouquetStatusBarColor(tInfos, aInfo, tTimer, tDuration);
						end

						if not tColor then
							tColor = tInfos["color"]; -- VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR
						end
					elseif 4 == tSpecial["custom_type"] then -- VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS
						tMaxColor = nil;

						tColor = VUHDO_copyColorTo(tColor, tWorkingColor);
						tFactor = tInfos["custom"]["bright"];

						if tColor["useBackground"] then
							tColor["R"], tColor["G"], tColor["B"] = tColor["R"] * tFactor, tColor["G"] * tFactor, tColor["B"] * tFactor;
						end

						if tColor["useText"] then
							tColor["TR"], tColor["TG"], tColor["TB"] = tColor["TR"] * tFactor, tColor["TG"] * tFactor, tColor["TB"] * tFactor;
						end
					else
						tMaxColor = nil;
					end

					if tColor["useText"] then
						tColor["useText"] = tInfos["color"]["useText"];
					end

					if tColor["useBackground"] then
						tColor["useBackground"] = tInfos["color"]["useBackground"];
					end

					if tColor["useOpacity"] then
						tColor["useOpacity"] = tInfos["color"]["useOpacity"];
					end
				end
			else
				tName = tInfos["name"];

				tIsActive = false;
				tSourceType = 0;

				if tInfos["mine"] and tInfos["others"] then
					tSourceType = VUHDO_UNIT_HOT_TYPE_BOTH;
				elseif tInfos["mine"] then
					tSourceType = VUHDO_UNIT_HOT_TYPE_MINE;
				elseif tInfos["others"] then
					tSourceType = VUHDO_UNIT_HOT_TYPE_OTHERS;
				end

				if tSourceType > 0 then
					tUnitHot, _ = VUHDO_getUnitHot(aUnit, tName, tSourceType);

					if tUnitHot and tUnitHot["auraInstanceId"] then
						-- tUnitHotInfo: aura icon, expiration, stacks, duration, isMine, name, spell ID
						tUnitHotInfo = VUHDO_getUnitHotInfo(aUnit, tUnitHot["auraInstanceId"]);

						if tUnitHotInfo then
							tIsActive = true;

							txState["activeAuras"] = txState["activeAuras"] + 1;

							tNow = GetTime();

							if tInfos["alive"] then
								tTimer = tNow - tUnitHotInfo[2] + (tUnitHotInfo[4] or 0);
							else
								tTimer = tUnitHotInfo[2] - tNow;
							end

							tIcon, tCounter, tDuration = tUnitHotInfo[1], tUnitHotInfo[3], tUnitHotInfo[4];

							if tTimer then
								tTimer = floor(tTimer * 10) * 0.1;
							end

							tColor = tInfos["color"];

							if tInfos["icon"] ~= 1 then
								tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2];
								tColor["isDefault"] = false;
							else
								tColor["isDefault"] = true;
							end
						end
					end
				end

				tTimer2, tClipL, tClipR, tClipT, tClipB = nil, nil, nil, nil, nil;
			end

			if tIsActive then
				txState["active"] = true;
				txState["name"] = tName;
				txState["level"] = tCnt;

				if tInfos["icon"] ~= 1 then
					tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2];
					txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"] = nil, nil, nil, nil;
				elseif tIcon ~= nil then
					txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"] = tClipL, tClipR, tClipT, tClipB;
				end

				if tIcon then
					txState["icon"] = tIcon;
				end

				if tColor then
					if not txState["isColorInit"] then
						twipe(txState["color"]);
						txState["isColorInit"] = true;
					end

					if tColor["useText"] then
						txState["color"]["useText"] = true;
						txState["color"]["TR"] = tColor["TR"];
						txState["color"]["TG"] = tColor["TG"];
						txState["color"]["TB"] = tColor["TB"];

						if not tColor["useOpacity"] then
							txState["color"]["TO"] = tColor["TO"];
						end
					end

					if tColor["useBackground"] then
						txState["color"]["useBackground"] = true;
						txState["color"]["R"] = tColor["R"];
						txState["color"]["G"] = tColor["G"];
						txState["color"]["B"] = tColor["B"];

						if not tColor["useOpacity"] then
							txState["color"]["O"] = tColor["O"];
						end
					end

					if tColor["useOpacity"] then
						txState["color"]["useOpacity"] = true;

						if tColor["TO"] ~= nil then
							txState["color"]["TO"] = (txState["color"]["TO"] or 1) * tColor["TO"];
						end

						if tColor["O"] ~= nil then
							txState["color"]["O"] = (txState["color"]["O"] or 1) * tColor["O"];
						end
					end

					txState["color"]["isDefault"] = tColor["isDefault"];
					txState["color"]["noStacksColor"] = tColor["noStacksColor"];
					txState["color"]["useSlotColor"] = tColor["useSlotColor"];

					if tMaxColor then
						if not txState["isMaxColorInit"] then
							twipe(txState["maxColor"]);
							txState["isMaxColorInit"] = true;
						end

						if tMaxColor["useText"] then
							txState["maxColor"]["useText"] = true;
							txState["maxColor"]["TR"] = tMaxColor["TR"];
							txState["maxColor"]["TG"] = tMaxColor["TG"];
							txState["maxColor"]["TB"] = tMaxColor["TB"];

							if not tMaxColor["useOpacity"] then
								txState["maxColor"]["TO"] = tMaxColor["TO"];
							end
						end

						if tMaxColor["useBackground"] then
							txState["maxColor"]["useBackground"] = true;
							txState["maxColor"]["R"] = tMaxColor["R"];
							txState["maxColor"]["G"] = tMaxColor["G"];
							txState["maxColor"]["B"] = tMaxColor["B"];

							if not tMaxColor["useOpacity"] then
								txState["maxColor"]["O"] = tMaxColor["O"];
							end
						end

						if tMaxColor["useOpacity"] then
							txState["maxColor"]["useOpacity"] = true;

							if tMaxColor["TO"] ~= nil then
								txState["maxColor"]["TO"] = (txState["maxColor"]["TO"] or 1) * tMaxColor["TO"];
							end

							if tMaxColor["O"] ~= nil then
								txState["maxColor"]["O"] = (txState["maxColor"]["O"] or 1) * tMaxColor["O"];
							end
						end
					else
						txState["isMaxColorInit"] = false;
					end
				else
					txState["isColorInit"] = false;
					txState["isMaxColorInit"] = false;
				end

				tCounter = tCounter or 0;

				if issecretvalue(tCounter) or tCounter >= 0 then
					txState["counter"] = tCounter;
				end

				tTimer, tTimer2, tDuration = tTimer or 0, tTimer2 or 0, tDuration or 0;

				if issecretvalue(tDuration) or tDuration >= 0 then
					if issecretvalue(tTimer) or tTimer >= 0 then
						txState["timer"], txState["duration"] = tTimer, tDuration;
					end

					if issecretvalue(tTimer2) or tTimer2 >= 0 then
						txState["timer2"] = tTimer2;
					end
				end
			end
		end

		return;

	end
end



do
	--
	local tEmptyInfo = { };
	local tUnit;
	local tInfo;
	local tBouquet;
	local tAnzInfos;
	local tLayerTemplate;
	local tHasSecretResults;
	local tEvalColorHash;
	function VUHDO_evaluateBouquet(aUnit, aBouquetName, anInfo)

		tUnit = (VUHDO_RAID[aUnit] or tEmptyInfo)["isVehicle"] and VUHDO_RAID[aUnit]["petUnit"] or aUnit;
		tInfo = anInfo or VUHDO_RAID[tUnit];

		if not tInfo then
			return false, nil, nil, nil, nil, nil, nil, VUHDO_hasBouquetChanged(aUnit, aBouquetName, false), 0, 0, nil, nil, nil, nil, nil, nil, nil;
		end

		txState["active"] = false;
		txState["icon"] = nil;
		txState["isColorInit"] = false;
		txState["name"] = nil;

		txState["isMaxColorInit"] = false;
		txState["counter"] = 0;
		txState["timer"] = 0;
		txState["duration"] = 0;
		txState["timer2"] = 0;
		txState["level"] = 0;
		txState["activeAuras"] = 0;
		txState["isAliveTime"] = false;

		txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"] = nil, nil, nil, nil;

		tBouquet = VUHDO_BOUQUETS["STORED"][aBouquetName];

		if not tBouquet or type(tBouquet) ~= "table" then
			return false, nil, nil, nil, nil, nil, nil, VUHDO_hasBouquetChanged(aUnit, aBouquetName, false), 0, 0, nil, nil, nil, nil, nil, nil, nil;
		end

		tAnzInfos = #tBouquet;
		tLayerTemplate = nil;

		if sSecretsEnabled and not VUHDO_isConfigDemoUsers() then
			tLayerTemplate = sBouquetLayerTemplates[aBouquetName];

			VUHDO_evaluateBouquetSecret(tUnit, aBouquetName, tInfo, tBouquet, tAnzInfos, tLayerTemplate);
		else
			VUHDO_evaluateBouquetNonSecret(tUnit, tInfo, tBouquet, tAnzInfos);
		end

		tHasSecretResults = issecretvalue(txState["icon"]) or issecretvalue(txState["timer"]) or issecretvalue(txState["counter"]) or issecretvalue(txState["duration"]);

		if txState["active"] then
			if not txState["isColorInit"] then
				txState["color"]["R"], txState["color"]["G"], txState["color"]["B"], txState["color"]["O"], txState["color"]["TR"], txState["color"]["TG"], txState["color"]["TB"], txState["color"]["TO"],
					txState["color"]["useText"], txState["color"]["useBackground"], txState["color"]["useOpacity"] = 1, 1, 1, 1, 1, 1, 1, 1, true, true, true;
			elseif not txState["color"]["useOpacity"] then
				txState["color"]["TO"], txState["color"]["O"] = 1, 1;
			end

			if txState["isMaxColorInit"] and not txState["maxColor"]["useOpacity"] then
				txState["maxColor"]["TO"], txState["maxColor"]["O"] = 1, 1;
			end

			tEvalColorHash = VUHDO_getColorHash(txState["color"]);

			if txState["isMaxColorInit"] then
				tEvalColorHash = tEvalColorHash + VUHDO_getColorHash(txState["maxColor"]) * 100000;
			end

			return true, txState["icon"], txState["timer"], txState["counter"], txState["duration"], txState["color"], txState["name"],
				tHasSecretResults or VUHDO_hasBouquetChanged(aUnit, aBouquetName, true, txState["icon"], txState["timer"], txState["counter"], txState["duration"], tEvalColorHash, txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"]),
				tAnzInfos - txState["level"], txState["timer2"], txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"], txState["isMaxColorInit"] and txState["maxColor"] or nil,
				tLayerTemplate, txState["isAliveTime"];
	else
		return false, nil, nil, nil, nil, nil, nil, tHasSecretResults or VUHDO_hasBouquetChanged(aUnit, aBouquetName, false), 0, 0,
			nil, nil, nil, nil, nil, tLayerTemplate, false;
	end

	end
end



	--
do
	--
	local tBouquet;
	local tName;
	local function VUHDO_activateBuffsInScanner(aBouquetName)

		tBouquet = VUHDO_BOUQUETS["STORED"][aBouquetName];

		for _, tInfos in pairs(tBouquet) do
			tName = tInfos["name"];
			if not VUHDO_strempty(tName) and not VUHDO_BOUQUET_BUFFS_SPECIAL[tName] then
				VUHDO_ACTIVE_HOTS[tName] = true;

				if tInfos["others"] then VUHDO_ACTIVE_HOTS_OTHERS[tName] = true; end
			end
		end

		return;

	end



	--
	local function VUHDO_hasCyclic(aBouquetName)

		for _, tItem in pairs(VUHDO_BOUQUETS["STORED"][aBouquetName]) do
			if not VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]] or VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]]["updateCyclic"] then
				return true;
			end
		end

		return false;

	end



	--
	function VUHDO_registerForBouquet(aBouquetName, anOwnerName, aFunction)

		if VUHDO_strempty(aBouquetName) or VUHDO_strempty(anOwnerName) then
			return;
		elseif not VUHDO_BOUQUETS["STORED"][aBouquetName] then
			VUHDO_Msg(format(VUHDO_I18N_ERR_NO_BOUQUET, anOwnerName, aBouquetName), 1, 0.4, 0.4);

			return;
		end

		VUHDO_BOUQUETS["STORED"][aBouquetName] = VUHDO_decompressIfCompressed(VUHDO_BOUQUETS["STORED"][aBouquetName]);

		VUHDO_buildCurvesForBouquet(aBouquetName);

		VUHDO_REGISTERED_BOUQUETS[aBouquetName][anOwnerName] = aFunction;

		if not VUHDO_REGISTERED_BOUQUET_INDICATORS[anOwnerName] then
			VUHDO_REGISTERED_BOUQUET_INDICATORS[anOwnerName] = { };
		end

		VUHDO_REGISTERED_BOUQUET_INDICATORS[anOwnerName][aBouquetName] = aFunction;

		VUHDO_activateBuffsInScanner(aBouquetName);
		VUHDO_activateAurasFromBouquet(aBouquetName);

		for tUnit, _ in pairs(VUHDO_RAID) do
			aFunction(tUnit, false, nil, 0, 0, 0, nil, nil, aBouquetName, nil, nil, nil, nil, nil, nil, nil, nil, nil, VUHDO_UPDATE_BOUQUET_RESET);
		end

		if VUHDO_hasCyclic(aBouquetName) then
			VUHDO_CYCLIC_BOUQUETS[aBouquetName] = true;
		end

		return;

	end



	--
	function VUHDO_registerForBouquetUnique(aBouquetName, anOwnerName, aFunction, anAlreadyRegistered)

		if not anAlreadyRegistered then
			return;
		end

		if not VUHDO_strempty(aBouquetName) and not VUHDO_strempty(anOwnerName) and not anAlreadyRegistered[aBouquetName .. anOwnerName] then
			VUHDO_registerForBouquet(aBouquetName, anOwnerName, aFunction);

			anAlreadyRegistered[aBouquetName .. anOwnerName] = true;
		end

		return;

	end
end



do
	--
	local tSlotMappings;
	local tTier;
	local tSlotData;
	local tAnchorConfig;
	local tListSlots;
	local tMaxSlots;
	local tInfo;
	local tPreviouslyActive;
	local tActiveStateChanged;
	local tIsRestricted;
	function VUHDO_listAuraGroupBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, anImpact, aTimer2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate, aIsAliveTime)

		tSlotMappings = VUHDO_AURA_LIST_BOUQUETS[aBouquetName];

		if not tSlotMappings then
			return;
		end

		tTier = VUHDO_UNIT_AURA_LIST_SLOTS[aUnit];

		if not tTier then
			return;
		end

		tActiveStateChanged = false;

		for _, tMapping in ipairs(tSlotMappings) do
			tTier = tTier[tMapping["panelNum"]];

			if tTier then
				tTier = tTier[tMapping["anchorKey"]];

				if tTier then
					tSlotData = tTier[tMapping["entryIndex"]];

					if not tSlotData then
						tSlotData = VUHDO_getSlotData();
						tTier[tMapping["entryIndex"]] = tSlotData;
					end

					tSlotData["icon"] = anIcon;

					if anIsActive and aDuration then
						if issecretvalue(aDuration) or issecretvalue(aTimer) then
							tSlotData["expirationTime"] = aTimer;
						elseif aDuration > 0 and aTimer then
							if aIsAliveTime then
								tSlotData["expirationTime"] = GetTime() - aTimer + aDuration;
							else
								tSlotData["expirationTime"] = GetTime() + aTimer;
							end
						else
							tSlotData["expirationTime"] = 0;
						end
					else
						tSlotData["expirationTime"] = 0;
					end

					tSlotData["stacks"] = aCounter;
					tSlotData["duration"] = aDuration;

					if aColor then
						VUHDO_copyColorTo(aColor, tSlotData["color"]);
					else
						twipe(tSlotData["color"]);
					end

					tInfo = VUHDO_RAID[aUnit];
					tPreviouslyActive = tSlotData["isActive"] or false;
					tSlotData["isActive"] = anIsActive and tInfo and tInfo["connected"] and not tInfo["dead"];

					if tSlotData["isActive"] ~= tPreviouslyActive then
						tActiveStateChanged = true;
					end

					tSlotData["name"] = aBuffName;
					tSlotData["entryType"] = 2;
					tSlotData["clipL"] = aClipL;
					tSlotData["clipR"] = aClipR;
					tSlotData["clipT"] = aClipT;
					tSlotData["clipB"] = aClipB;
					tSlotData["isAliveTime"] = aIsAliveTime or false;

					tAnchorConfig = VUHDO_PANEL_SETUP[tMapping["panelNum"]] and
						VUHDO_PANEL_SETUP[tMapping["panelNum"]]["AURA_ANCHORS"] and
						VUHDO_PANEL_SETUP[tMapping["panelNum"]]["AURA_ANCHORS"][tMapping["anchorKey"]];

					if tAnchorConfig then
						tSlotData["groupId"] = tAnchorConfig["groupId"];
						tSlotData["entryIndex"] = tMapping["entryIndex"];
					end
				end
			end

			tTier = VUHDO_UNIT_AURA_LIST_SLOTS[aUnit];
		end

		if aUnit and VUHDO_displayAurasAtAnchorFromCache and not VUHDO_isAuraDisplaySuspended() then
			tIsRestricted = VUHDO_isAuraDataRestricted();

			for _, tMapping in ipairs(tSlotMappings) do
				tAnchorConfig = VUHDO_PANEL_SETUP[tMapping["panelNum"]] and
					VUHDO_PANEL_SETUP[tMapping["panelNum"]]["AURA_ANCHORS"] and
					VUHDO_PANEL_SETUP[tMapping["panelNum"]]["AURA_ANCHORS"][tMapping["anchorKey"]];

				if tAnchorConfig and tAnchorConfig["enabled"] ~= false then
					if VUHDO_isAuraModeContainers() then
						VUHDO_updateStaticBouquetSlotsForUnit(aUnit, tMapping["panelNum"], tMapping["anchorKey"]);
					elseif tIsRestricted then
						VUHDO_renderNonAuraListSlots(aUnit, tMapping["panelNum"], tMapping["anchorKey"]);
					else
						tListSlots = VUHDO_UNIT_AURA_LIST_SLOTS[aUnit] and
							VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tMapping["panelNum"]] and
							VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tMapping["panelNum"]][tMapping["anchorKey"]];
						tMaxSlots = tAnchorConfig["maxDisplay"] or 5;

						VUHDO_displayAurasAtAnchorFromCache(aUnit, tMapping["panelNum"], tMapping["anchorKey"],
							tAnchorConfig, tListSlots, tMaxSlots);
					end
				end
			end
		end

		if tActiveStateChanged then
			tInfo = VUHDO_RAID[aUnit];

			if tInfo then
				tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineAura(aUnit);

				VUHDO_updateHealthBarsFor(aUnit, 4);
			end
		end

		return;

	end



	--
	function VUHDO_listAuraGroupBouquetColorOnlyCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, anImpact, aTimer2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

		if not aBouquetName then
			return;
		end

		if not VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] then
			VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] = sUnitBouquetActivePool:get();
		end

		tPreviouslyActive = VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit][aBouquetName] or false;
		VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit][aBouquetName] = anIsActive;

		if anIsActive ~= tPreviouslyActive then
			tInfo = VUHDO_RAID[aUnit];

			if tInfo then
				tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineAura(aUnit);

				VUHDO_updateHealthBarsFor(aUnit, 4);
			end
		end

		return;

	end
end



--
function VUHDO_clearUnitBouquetActiveCache(aUnit)

	if not aUnit then
		return;
	end

	if VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] then
		sUnitBouquetActivePool:release(VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit]);
		VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] = nil;
	end

	return;

end



do
	-- Specials with secretType NONE that nonetheless read aura/HoT-derived state and therefore degrade in restricted mode.
	local sAuraConsumingSpecialNames = {
		["OTHER"] = true,
		["SWIFTMEND"] = true,
		["CHI_HARMONY_ICON_MINE"] = true,
		["CHI_HARMONY_ICON_OTHERS"] = true,
		["CHI_HARMONY_ICON_BOTH"] = true,
		["DEBUFF_CHARMED"] = true,
	};

	local sDispelSpecialToDispelName = {
		["DEBUFF_MAGIC"] = "Magic",
		["DEBUFF_CURSE"] = "Curse",
		["DEBUFF_DISEASE"] = "Disease",
		["DEBUFF_POISON"] = "Poison",
		["DEBUFF_BLEED"] = "Bleed",
		["DEBUFF_ENRAGE"] = "Enrage",
	};

	local sRestrictedModeClassCache = { };

	--
	local tBouquet;
	local tItem;
	local tName;
	local tSpecial;
	local tSpellId;
	local tHasAuraItem;
	local tAllHelpfulSpells;
	local tAllDispel;
	local tClass;
	local tMineOthersMode;
	local tEntryMineMode;
	local tHasOverlayAuraItem;
	local tHasUnsupportedAuraItem;
	local tHasNonAuraItem;
	local tAuraGroup;
	local tAuraGroupId;
	function VUHDO_classifyBouquetRestrictedMode(aBouquetName)

		if not aBouquetName then
			return VUHDO_BOUQUET_RESTRICTED_NON_AURA;
		end

		tClass = sRestrictedModeClassCache[aBouquetName];

		if tClass then
			return tClass;
		end

		tBouquet = VUHDO_BOUQUETS["STORED"] and VUHDO_BOUQUETS["STORED"][aBouquetName];
		tBouquet = VUHDO_decompressIfCompressed(tBouquet);

		if type(tBouquet) ~= "table" then
			sRestrictedModeClassCache[aBouquetName] = VUHDO_BOUQUET_RESTRICTED_NON_AURA;

			return VUHDO_BOUQUET_RESTRICTED_NON_AURA;
		end

		tHasAuraItem = false;
		tAllHelpfulSpells = true;
		tAllDispel = true;
		tMineOthersMode = nil;
		tHasOverlayAuraItem = false;
		tHasUnsupportedAuraItem = false;
		tHasNonAuraItem = false;

		for tCnt = 1, #tBouquet do
			tItem = tBouquet[tCnt];
			tName = tItem["name"];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tName];

			if tSpecial then
				if sDispelSpecialToDispelName[tName] then
					tHasAuraItem = true;
					tHasOverlayAuraItem = true;
					tAllHelpfulSpells = false;
				elseif tSpecial["custom_type"] == VUHDO_BOUQUET_CUSTOM_TYPE_AURA_GROUP then
					tHasAuraItem = true;
					tAllHelpfulSpells = false;
					tAuraGroupId = tItem["custom"] and tItem["custom"]["auraGroupId"];
					tAuraGroup = VUHDO_getAuraGroup(tAuraGroupId);

					if tAuraGroup and VUHDO_isAuraGroupContainerExpressible(tAuraGroup) then
						tHasOverlayAuraItem = true;
					else
						tHasUnsupportedAuraItem = true;
						tAllDispel = false;
					end
				elseif tName == "DEBUFF_BAR_COLOR" then
					tHasAuraItem = true;
					tHasOverlayAuraItem = true;
					tAllHelpfulSpells = false;
				elseif tSpecial["secretType"] == VUHDO_SECRET_TYPE_DISPEL
					or tSpecial["secretType"] == VUHDO_SECRET_TYPE_DURATION
					or sAuraConsumingSpecialNames[tName] then
					tHasAuraItem = true;
					tAllHelpfulSpells = false;
					tAllDispel = false;
				else
					tHasNonAuraItem = true;
				end
			elseif not VUHDO_strempty(tName) then
				tHasAuraItem = true;
				tAllDispel = false;
				tSpellId = VUHDO_resolveAuraContainerSpellId(tName);

				if not tSpellId then
					tAllHelpfulSpells = false;
					tHasUnsupportedAuraItem = true;
				else
					tHasOverlayAuraItem = true;
					if tItem["mine"] ~= false and tItem["others"] ~= true then
						tEntryMineMode = "mine";
					elseif tItem["others"] == true and tItem["mine"] == false then
						tEntryMineMode = "others";
					elseif tItem["mine"] ~= false and tItem["others"] == true then
						tEntryMineMode = "both";
					else
						tAllHelpfulSpells = false;
					end

					if tAllHelpfulSpells and tEntryMineMode then
						if tMineOthersMode and tMineOthersMode ~= tEntryMineMode then
							tAllHelpfulSpells = false;
						else
							tMineOthersMode = tEntryMineMode;
						end
					end
				end
			end
		end

		if not tHasAuraItem then
			tClass = VUHDO_BOUQUET_RESTRICTED_NON_AURA;
		elseif tHasNonAuraItem then
			tClass = VUHDO_BOUQUET_RESTRICTED_MIXED;
		elseif tHasUnsupportedAuraItem then
			tClass = VUHDO_BOUQUET_RESTRICTED_UNSUPPORTED;
		elseif tAllHelpfulSpells or tAllDispel or tHasOverlayAuraItem then
			tClass = VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER;
		else
			tClass = VUHDO_BOUQUET_RESTRICTED_UNSUPPORTED;
		end

		sRestrictedModeClassCache[aBouquetName] = tClass;

		return tClass;

	end



	--
	function VUHDO_invalidateBouquetRestrictedModeCache()

		twipe(sRestrictedModeClassCache);

		return;

	end



	--
	local tEntries;
	local tEntryCount;
	local tDispelTypes;
	local tDispelCount;
	local tStaticIcon;
	local tStaticColor;
	local tSourceColor;
	local tSyntheticGroup;
	local tCandidateFilters;
	local tFilterString;
	local tMineOthersMode;
	local tEntryMineMode;
	function VUHDO_buildListEntryContainerGroupTemplate(aBouquetName)

		if not aBouquetName then
			return nil;
		end

		tBouquet = VUHDO_BOUQUETS["STORED"] and VUHDO_BOUQUETS["STORED"][aBouquetName];
		tBouquet = VUHDO_decompressIfCompressed(tBouquet);

		if type(tBouquet) ~= "table" then
			return nil;
		end

		tEntries = { };
		tEntryCount = 0;
		tDispelTypes = nil;
		tDispelCount = 0;
		tStaticIcon = nil;
		tStaticColor = nil;
		tMineOthersMode = nil;

		for tCnt = 1, #tBouquet do
			tItem = tBouquet[tCnt];
			tName = tItem["name"];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tName];
			tSpellId = nil;

			if not tSpecial then
				tSpellId = VUHDO_resolveAuraContainerSpellId(tName);

				if tSpellId then
					tEntryCount = tEntryCount + 1;

					tEntries[tEntryCount] = {
						["entryType"] = VUHDO_AURA_LIST_ENTRY_SPELL,
						["value"] = tName,
					};

					if tItem["mine"] ~= false and tItem["others"] ~= true then
						tEntryMineMode = "mine";
					elseif tItem["others"] == true and tItem["mine"] == false then
						tEntryMineMode = "others";
					elseif tItem["mine"] ~= false and tItem["others"] == true then
						tEntryMineMode = "both";
					else
						tEntryMineMode = nil;
					end

					if tEntryMineMode then
						if tMineOthersMode and tMineOthersMode ~= tEntryMineMode then
							tMineOthersMode = nil;
						else
							tMineOthersMode = tEntryMineMode;
						end
					end
				end
			elseif sDispelSpecialToDispelName[tName] then
				tDispelTypes = tDispelTypes or { };
				tDispelTypes[sDispelSpecialToDispelName[tName]] = true;
				tDispelCount = tDispelCount + 1;
			end

			if tSpellId or sDispelSpecialToDispelName[tName] then
				if tStaticColor == nil and tItem["color"] and tItem["color"]["R"] then
					tSourceColor = tItem["color"];

					tStaticColor = {
						["R"] = tSourceColor["R"],
						["G"] = tSourceColor["G"],
						["B"] = tSourceColor["B"],
						["O"] = tSourceColor["O"] or 1,
					};
				end

				if tStaticIcon == nil and tItem["icon"] and tItem["icon"] ~= 1 and VUHDO_CUSTOM_ICONS[tItem["icon"]] then
					tStaticIcon = VUHDO_CUSTOM_ICONS[tItem["icon"]][2];
				end
			end
		end

		if tEntryCount > 0 and tDispelCount == 0 then
			tSyntheticGroup = {
				["type"] = VUHDO_AURA_GROUP_TYPE_LIST,
				["isHarmful"] = false,
				["entries"] = tEntries,
			};

			tCandidateFilters = VUHDO_resolveGroupCandidateFilters(tSyntheticGroup, nil);
			tFilterString = "HELPFUL";

			if tMineOthersMode == "mine" then
				tFilterString = "HELPFUL|PLAYER";
			elseif tMineOthersMode == "others" then
				tFilterString = "HELPFUL|!PLAYER";
			end
		elseif tDispelCount > 0 and tEntryCount == 0 then
			tCandidateFilters = {
				["includeDispelTypes"] = tDispelTypes,
			};
			tFilterString = "HARMFUL";
		else
			return nil;
		end

		return {
			["key"] = "VuhDoB1Bouquet_" .. aBouquetName,
			["filterString"] = tFilterString,
			["candidateFilters"] = tCandidateFilters,
			["isHarmful"] = tEntryCount == 0 and tDispelCount > 0,
			["maxFrameCount"] = 1,
			["templateName"] = "VuhDoAuraButtonIconTemplate",
			["buttonSetup"] = {
				["staticIcon"] = tStaticIcon,
				["staticColor"] = tStaticColor,
				["durationCooldown"] = true,
				["durationText"] = true,
				["applicationCount"] = true,
				["mouseMotion"] = false,
			},
		};

	end



	--
	local tMixedResult;
	local tMixedItemCount;
	local tMixedItem;
	local tMixedItemStackLevel;
	local tMixedPieceKey;
	local tMixedSpellId;
	local tMixedIncludeSpellIds;
	local tMixedDispelName;
	local tMixedFilterString;
	local tMixedCandidateFilters;
	local tMixedButtonSetup;
	local tMixedFrameLevelOffset;
	function VUHDO_buildMixedBouquetListSlotTemplates(aBouquetName, aListEntryIndex, aSlotX, aSlotY, aPixelWidth, aPixelHeight, aTemplateName, aAnchorButtonSetup)

		tMixedResult = { };

		if not aBouquetName then
			return tMixedResult;
		end

		tBouquet = VUHDO_BOUQUETS["STORED"] and VUHDO_BOUQUETS["STORED"][aBouquetName];
		tBouquet = VUHDO_decompressIfCompressed(tBouquet);

		if type(tBouquet) ~= "table" then
			return tMixedResult;
		end

		tMixedItemCount = #tBouquet;

		for tMixedItemIdx = 1, tMixedItemCount do
			tMixedItem = tBouquet[tMixedItemIdx];
			tName = tMixedItem["name"];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tName];
			tMixedItemStackLevel = tMixedItemCount - tMixedItemIdx + 1;
			tMixedFrameLevelOffset = 1 + tMixedItemStackLevel;
			tMixedPieceKey = format("slot%d:%d", aListEntryIndex, tMixedItemIdx);
			tMixedSpellId = nil;
			tMixedDispelName = nil;

			if not tSpecial then
				tMixedIncludeSpellIds = { };

				VUHDO_addResolvedAuraContainerSpellIds(tMixedIncludeSpellIds, tName);

				if next(tMixedIncludeSpellIds) then
					tMixedSpellId = VUHDO_resolveAuraContainerSpellId(tName);
				else
					tMixedSpellId = nil;
				end
			elseif sDispelSpecialToDispelName[tName] then
				tMixedDispelName = sDispelSpecialToDispelName[tName];
			end

			if tMixedSpellId then
				if tMixedItem["mine"] ~= false and tMixedItem["others"] ~= true then
					tMixedFilterString = "HELPFUL|PLAYER";
				elseif tMixedItem["others"] == true and tMixedItem["mine"] == false then
					tMixedFilterString = "HELPFUL|!PLAYER";
				else
					tMixedFilterString = "HELPFUL";
				end

				tMixedCandidateFilters = {
					["includeSpellIDs"] = tMixedIncludeSpellIds,
				};

				tMixedButtonSetup = { };

				for tMixedKey, tMixedValue in pairs(aAnchorButtonSetup) do
					tMixedButtonSetup[tMixedKey] = tMixedValue;
				end

				tMixedButtonSetup["frameLevelOffset"] = tMixedFrameLevelOffset;

				if tMixedItem["color"] and tMixedItem["color"]["R"] then
					tMixedButtonSetup["iconColor"] = tMixedItem["color"];
				end

				if tMixedItem["icon"] and tMixedItem["icon"] ~= 1 and VUHDO_CUSTOM_ICONS[tMixedItem["icon"]] then
					tMixedButtonSetup["staticIcon"] = VUHDO_CUSTOM_ICONS[tMixedItem["icon"]][2];
				end

				tinsert(tMixedResult, {
					["key"] = tMixedPieceKey,
					["filterString"] = tMixedFilterString,
					["candidateFilters"] = tMixedCandidateFilters,
					["isHarmful"] = false,
					["friendlyOnly"] = true,
					["mixedEntryIndex"] = aListEntryIndex,
					["mixedItemIndex"] = tMixedItemIdx,
					["templateName"] = aTemplateName,
					["buttonSetup"] = tMixedButtonSetup,
					["x"] = aSlotX,
					["y"] = aSlotY,
					["width"] = aPixelWidth,
					["height"] = aPixelHeight,
				});
			elseif tMixedDispelName then
				tMixedButtonSetup = { };

				for tMixedKey, tMixedValue in pairs(aAnchorButtonSetup) do
					tMixedButtonSetup[tMixedKey] = tMixedValue;
				end

				tMixedButtonSetup["frameLevelOffset"] = tMixedFrameLevelOffset;

				if tMixedItem["color"] and tMixedItem["color"]["R"] then
					tMixedButtonSetup["iconColor"] = tMixedItem["color"];
				end

				tinsert(tMixedResult, {
					["key"] = tMixedPieceKey,
					["filterString"] = "HARMFUL|RAID",
					["candidateFilters"] = {
						["includeDispelTypes"] = {
							[tMixedDispelName] = true,
						},
					},
					["isHarmful"] = true,
					["friendlyOnly"] = true,
					["mixedEntryIndex"] = aListEntryIndex,
					["mixedItemIndex"] = tMixedItemIdx,
					["templateName"] = aTemplateName,
					["buttonSetup"] = tMixedButtonSetup,
					["x"] = aSlotX,
					["y"] = aSlotY,
					["width"] = aPixelWidth,
					["height"] = aPixelHeight,
				});
			else
				tMixedButtonSetup = { };

				for tMixedKey, tMixedValue in pairs(aAnchorButtonSetup) do
					tMixedButtonSetup[tMixedKey] = tMixedValue;
				end

				tMixedButtonSetup["frameLevelOffset"] = tMixedFrameLevelOffset;

				tinsert(tMixedResult, {
					["key"] = tMixedPieceKey,
					["isStaticBouquetSlot"] = true,
					["isMixedBouquetItem"] = true,
					["bouquetName"] = aBouquetName,
					["entryIndex"] = aListEntryIndex,
					["itemIndex"] = tMixedItemIdx,
					["frameLevelOffset"] = tMixedFrameLevelOffset,
					["buttonSetup"] = tMixedButtonSetup,
					["x"] = aSlotX,
					["y"] = aSlotY,
					["width"] = aPixelWidth,
					["height"] = aPixelHeight,
				});
			end
		end

		return tMixedResult;

	end



	--
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tColor;
	local tBuffName;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tSecretBool;
	function VUHDO_evaluateBouquetItemForStaticSlot(aBouquetName, anItemIndex, anInfo)

		if not aBouquetName or not anItemIndex or not anInfo then
			return false;
		end

		tBouquet = VUHDO_BOUQUETS["STORED"] and VUHDO_BOUQUETS["STORED"][aBouquetName];
		tBouquet = VUHDO_decompressIfCompressed(tBouquet);

		if type(tBouquet) ~= "table" or not tBouquet[anItemIndex] then
			return false;
		end

		tItem = tBouquet[anItemIndex];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]];

		if tSpecial and tSpecial["validator"] then
			tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, tClipL, tClipR, tClipT, tClipB, tSecretBool = tSpecial["validator"](anInfo, tItem);

			if tIsActive then
				if tItem["icon"] and tItem["icon"] ~= 1 and VUHDO_CUSTOM_ICONS[tItem["icon"]] then
					if not tIcon or not issecretvalue(tIcon) then
						tIcon = VUHDO_CUSTOM_ICONS[tItem["icon"]][2];
					end
				end

				if not tColor and tItem["color"] and tItem["color"]["R"] then
					tColor = tItem["color"];
				end
			end

			return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, tClipL, tClipR, tClipT, tClipB, tSecretBool;
		end

		return false;

	end

end



do
	--
	local tAnchors;
	local tGroup;
	local tBouquetName;
	local tGroupsWithEnabledAnchor;
	local tEffectiveColorType;
	local tConfigGroups;
	function VUHDO_registerListGroupBouquetEntries(anAlreadyRegistered)

		twipe(sGroupsWithEnabledAnchorReusable);
		tGroupsWithEnabledAnchor = sGroupsWithEnabledAnchorReusable;

		for tPanelNum = 1, VUHDO_MAX_PANELS do
			if VUHDO_PANEL_MODELS[tPanelNum] then
				tAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

				if tAnchors then
					for tKey, tVal in pairs(tAnchors) do
						if tVal["enabled"] ~= false and tVal["groupId"] then
							tGroupsWithEnabledAnchor[tVal["groupId"]] = true;
						end

						tGroup = VUHDO_getAuraGroupRaw(tVal["groupId"]);

						if tGroup and (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST and tGroup["entries"] then
							for tEntryIndex, tEntry in ipairs(tGroup["entries"]) do
								if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
									tBouquetName = tEntry["value"];

									if tBouquetName then
										VUHDO_registerForBouquetUnique(
											tBouquetName,
											"ListAuraGroup",
											VUHDO_listAuraGroupBouquetCallback,
											anAlreadyRegistered
										);

										if not VUHDO_AURA_LIST_BOUQUETS[tBouquetName] then
											VUHDO_AURA_LIST_BOUQUETS[tBouquetName] = { };
										end

										tinsert(VUHDO_AURA_LIST_BOUQUETS[tBouquetName], {
											["panelNum"] = tPanelNum,
											["anchorKey"] = tKey,
											["entryIndex"] = tEntryIndex,
										});
									end
								end
							end
						end
					end
				end
			end
		end

		tConfigGroups = VUHDO_CONFIG and VUHDO_CONFIG["AURA_GROUPS"] or { };

		for tGroupId, tGroup in pairs(tConfigGroups) do
			tEffectiveColorType = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

			if tEffectiveColorType >= VUHDO_AURA_GROUP_COLOR_DISPEL and tGroup["enabled"] ~= false and not tGroupsWithEnabledAnchor[tGroupId] then
				if (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST and tGroup["entries"] then
					for tEntryIndex, tEntry in ipairs(tGroup["entries"]) do
						if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
							tBouquetName = tEntry["value"];

							if tBouquetName then
								VUHDO_registerForBouquetUnique(
									tBouquetName,
									"ListAuraGroupColorOnly",
									VUHDO_listAuraGroupBouquetColorOnlyCallback,
									anAlreadyRegistered
								);
							end
						end
					end
				end
			end
		end

		for tGroupId, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or { }) do
			if (not tGroup["playerClassRequired"] or tGroup["playerClassRequired"] == VUHDO_PLAYER_CLASS) and
				not (tConfigGroups[tGroupId]) and
				tGroup["enabled"] ~= false and
				not (VUHDO_CONFIG and VUHDO_CONFIG["AURA_GROUP_DISABLED"] and VUHDO_CONFIG["AURA_GROUP_DISABLED"][tGroupId]) and
				not (VUHDO_DEFAULT_AURA_GROUPS[tGroupId] and VUHDO_DEFAULT_AURA_GROUPS[tGroupId]["enabled"] == false) and
				not tGroupsWithEnabledAnchor[tGroupId] then
				tEffectiveColorType = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

				if tEffectiveColorType >= VUHDO_AURA_GROUP_COLOR_DISPEL and (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST and tGroup["entries"] then
					for tEntryIndex, tEntry in ipairs(tGroup["entries"]) do
						if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
							tBouquetName = tEntry["value"];

							if tBouquetName then
								VUHDO_registerForBouquetUnique(
									tBouquetName,
									"ListAuraGroupColorOnly",
									VUHDO_listAuraGroupBouquetColorOnlyCallback,
									anAlreadyRegistered
								);
							end
						end
					end
				end
			end
		end

		return;

	end



	--
	local tHotSlots;
	local tAlreadyRegistered = { };
	function VUHDO_registerAllBouquets(aDoCompress)

		twipe(VUHDO_REGISTERED_BOUQUETS);
		twipe(VUHDO_CYCLIC_BOUQUETS);
		twipe(VUHDO_REGISTERED_BOUQUET_INDICATORS);
		twipe(VUHDO_AURA_LIST_BOUQUETS);
		twipe(VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS);

		VUHDO_invalidateBouquetRestrictedModeCache();
		VUHDO_invalidateAuraContainerTemplateCache();
		VUHDO_releaseAllOverlays();

		VUHDO_incrementAlphaChainConfigVersion();

		for tUnit, _ in pairs(VUHDO_RAID or { }) do
			VUHDO_clearUnitBouquetActiveCache(tUnit);
		end

		if not VUHDO_BOUQUETS["STORED"] then
			return;
		end

		if aDoCompress then
			VUHDO_compressAllBouquets();
		end

		VUHDO_clearCurveCache();
		VUHDO_initSecretColorConstants();
		VUHDO_buildAllBouquetCurves();

		twipe(tAlreadyRegistered);

		for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
			if VUHDO_PANEL_MODELS[tPanelNum] then
				-- Hot Icons+Bars
				if not sSecretsEnabled then
					tHotSlots = VUHDO_PANEL_SETUP[tPanelNum]["HOTS"]["SLOTS"];

					for _, tHotName in pairs(tHotSlots) do
						if tHotName and "BOUQUET_" == strsub(tHotName, 1, 8) then
							VUHDO_registerForBouquetUnique(
								strsub(tHotName, 9),
								"HoT",
								VUHDO_hotBouquetCallback,
								tAlreadyRegistered
							);
						end
					end
				end

				-- Bar (=Outer) Border
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["BAR_BORDER"],
					"Outer Border",
					VUHDO_barBorderBouquetCallback,
					tAlreadyRegistered
				);

				-- Cluster (=Inner) Border
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["CLUSTER_BORDER"],
					"Inner Border",
					VUHDO_clusterBorderBouquetCallback,
					tAlreadyRegistered
				);

				-- Swiftmend Indicator
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SWIFTMEND_INDICATOR"],
					"Special Dot",
					VUHDO_swiftmendIndicatorBouquetCallback,
					tAlreadyRegistered
				);

				-- Aggro Line
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["AGGRO_BAR"],
					"Aggro Bar",
					VUHDO_aggroBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Mouseover Highlighter
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["MOUSEOVER_HIGHLIGHT"],
					"Mouseover Highlight",
					VUHDO_highlighterBouquetCallback,
					tAlreadyRegistered
				);

				-- Threat Marks
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["THREAT_MARK"],
					"Threat Indicators",
					VUHDO_threatIndicatorsBouquetCallback,
					tAlreadyRegistered
				);

				-- Threat Bar
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["THREAT_BAR"],
					"THREAT_BAR",
					VUHDO_threatBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Mana Bar
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["MANA_BAR"],
					"MANA_BAR",
					VUHDO_manaBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Background Bar
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["BACKGROUND_BAR"],
					"Background Bar",
					VUHDO_backgroundBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Health Bar
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["HEALTH_BAR"],
					"Health Bar",
					VUHDO_healthBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Side bar left
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SIDE_LEFT"],
					"SIDE_LEFT",
					VUHDO_sideBarLeftBouquetCallback,
					tAlreadyRegistered
				);

				-- Side bar right
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SIDE_RIGHT"],
					"SIDE_RIGHT",
					VUHDO_sideBarRightBouquetCallback,
					tAlreadyRegistered
				);
			end
		end

		VUHDO_registerListGroupBouquetEntries(tAlreadyRegistered);

		for _, tBouquetName in pairs(VUHDO_CUSTOM_BOUQUETS) do
			VUHDO_BOUQUETS["STORED"][tBouquetName] = VUHDO_decompressIfCompressed(VUHDO_BOUQUETS["STORED"][tBouquetName]);

			VUHDO_buildCurvesForBouquet(tBouquetName);
		end

		VUHDO_releaseAndWipeLastEvaluatedBouquets();

		VUHDO_updateGlobalToggles();
		VUHDO_buildEventInterestCache();
		VUHDO_initAllEventBouquets();

		VUHDO_rebuildCanColorBarGroupsCache();

		for tUnit, _ in pairs(VUHDO_RAID or { }) do
			VUHDO_deferSyncOverlaysForUnit(tUnit);
		end

		return;

	end
end



--
local tBouquetStored;
local tAuraGroupIdFromItem;
function VUHDO_collectBouquetAuraGroupIds()

	twipe(VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS);

	for tBouquetName, _ in pairs(VUHDO_REGISTERED_BOUQUETS) do
		tBouquetStored = VUHDO_BOUQUETS["STORED"][tBouquetName];

		if tBouquetStored then
			for _, tBouquetItemForAuraGroup in pairs(tBouquetStored) do
				if "AURA_GROUP_ACTIVE" == tBouquetItemForAuraGroup["name"] and tBouquetItemForAuraGroup["custom"] then
					tAuraGroupIdFromItem = tBouquetItemForAuraGroup["custom"]["auraGroupId"];

					if tAuraGroupIdFromItem and tAuraGroupIdFromItem ~= "" then
						VUHDO_BOUQUET_TRACKED_AURA_GROUP_IDS[tAuraGroupIdFromItem] = true;
					end
				end
			end
		end
	end

	return;

end



--
local VUHDO_EVENT_BOUQUETS = { };
setmetatable(VUHDO_EVENT_BOUQUETS, VUHDO_META_NEW_ARRAY);

--
local VUHDO_EVENT_INTEREST_CACHE = { };
setmetatable(VUHDO_EVENT_INTEREST_CACHE, VUHDO_META_NEW_ARRAY);

for tEventType = 1, 50 do
	VUHDO_EVENT_INTEREST_CACHE[tEventType] = { };
end



--
local tName;
function VUHDO_isBouquetInterestedInEvent(aBouquetName, anEventType)

	if not VUHDO_EVENT_BOUQUETS[aBouquetName][anEventType] then
		VUHDO_EVENT_BOUQUETS[aBouquetName][anEventType] = 0;

		for _, tItem in pairs(VUHDO_BOUQUETS["STORED"][aBouquetName]) do
			tName = tItem["name"];

			if VUHDO_BOUQUET_BUFFS_SPECIAL[tName] then
				for _, tInterest in pairs(VUHDO_BOUQUET_BUFFS_SPECIAL[tName]["interests"]) do
					if tInterest == anEventType then
						VUHDO_EVENT_BOUQUETS[aBouquetName][anEventType] = 1;

						break;
					end
				end
			end
		end
	end

	return 1 == VUHDO_EVENT_BOUQUETS[aBouquetName][anEventType] or 1 == anEventType; -- VUHDO_UPDATE_ALL

end



--
function VUHDO_buildEventInterestCache()

	for tEventType = 1, 50 do
		twipe(VUHDO_EVENT_INTEREST_CACHE[tEventType]);
	end

	for tBouquetName, _ in pairs(VUHDO_REGISTERED_BOUQUETS) do
		for tEventType = 1, 50 do
			if VUHDO_isBouquetInterestedInEvent(tBouquetName, tEventType) then
				VUHDO_EVENT_INTEREST_CACHE[tEventType][tBouquetName] = true;
			end
		end
	end

	return;

end



do
	--
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tColor;
	local tBuffName;
	local tHasChanged;
	local tImpact;
	local tTimer2;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tMaxColor;
	local tLayerTemplate;
	local tIsAliveTime;
	function VUHDO_updateEventBouquet(aUnit, aBouquetName, anEventType)

		tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName,
			tHasChanged, tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime
			= VUHDO_evaluateBouquet(aUnit, aBouquetName, nil);

		if not tHasChanged then
			return;
		end

		for _, tDelegate in pairs(VUHDO_REGISTERED_BOUQUETS[aBouquetName]) do
			tDelegate(aUnit, tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, aBouquetName,
				tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime, anEventType);
		end

		VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] = tIsActive;

		VUHDO_updateAllTextIndicatorsForEvent(aUnit, anEventType, aBouquetName, tIsActive);

		return;

	end



	--
	function VUHDO_invokeCustomBouquet(aButton, aUnit, anInfo, aBouquetName, aDelegate)

		tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName,
			_, tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime
			= VUHDO_evaluateBouquet(aUnit, aBouquetName, anInfo);

		if tIsActive then
			aDelegate(aButton, aUnit, tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, aBouquetName,
				tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime, 1);
			VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] = true;
		elseif VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] then
			aDelegate(aButton, aUnit, tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, aBouquetName,
				tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime, 1);
			VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] = false;
		end

		return;

	end
end



--
local function VUHDO_isAnyBouquetInterestedIn(anUpdateMode)

	for tName, _ in pairs(VUHDO_REGISTERED_BOUQUETS) do
		if VUHDO_isBouquetInterestedInEvent(tName, anUpdateMode) then return true; end
	end

	return false;

end



--
local tInterestedBouquets;
function VUHDO_updateBouquetsForEvent(aUnit, anEventType)

	if aUnit then
		tInterestedBouquets = VUHDO_EVENT_INTEREST_CACHE[anEventType];

		for tName, _ in pairs(tInterestedBouquets) do
			VUHDO_updateEventBouquet(aUnit, tName, anEventType);
		end
	end

	VUHDO_updateAllTextIndicatorsForEvent(aUnit, anEventType);

	return;

end
local VUHDO_updateBouquetsForEvent = VUHDO_updateBouquetsForEvent;



--
function VUHDO_initAllEventBouquets()

	VUHDO_releaseAndWipeLastEvaluatedBouquets();

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateBouquetsForEvent(tUnit, 1); -- VUHDO_UPDATE_ALL
	end

	VUHDO_updateBouquetsForEvent("focus", 1); -- VUHDO_UPDATE_ALL
	VUHDO_updateBouquetsForEvent("target", 1); -- VUHDO_UPDATE_ALL

	VUHDO_registerAllTextIndicators();

	return;

end



--
function VUHDO_deferInitAllEventBouquetsDelegate()

	VUHDO_releaseAndWipeLastEvaluatedBouquets();

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_deferUpdateBouquetsForEvent(tUnit, 1); -- VUHDO_UPDATE_ALL
	end

	VUHDO_deferUpdateBouquetsForEvent("focus", 1); -- VUHDO_UPDATE_ALL
	VUHDO_deferUpdateBouquetsForEvent("target", 1); -- VUHDO_UPDATE_ALL

	VUHDO_registerAllTextIndicators();

	return;

end



--
function VUHDO_deferInitAllEventBouquets(aPriority)

	VUHDO_deferTask(VUHDO_DEFER_INIT_ALL_EVENT_BOUQUETS, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH);

	return;

end



--
local tUnitToInit;
function VUHDO_initEventBouquetsFor(...)

	for tCnt = 1, select('#', ...) do
		tUnitToInit = select(tCnt, ...);

		for _, tAllBouquetUnits in pairs(VUHDO_LAST_EVALUATED_BOUQUETS) do
			for tUnit, tAllResults in pairs(tAllBouquetUnits) do
				if tUnit == tUnitToInit then
					tAllResults[1] = nil; -- Change "active" flag to enforce re-evaluation
				end
			end
		end

		VUHDO_updateBouquetsForEvent(tUnitToInit, 1); -- VUHDO_UPDATE_ALL
	end

	return;

end



--
local tRefreshBouquetName;
local tRefreshIsRestricted;
local tRefreshRestrictedMode;
local tRefreshLastEval;
function VUHDO_refreshListBouquetsForUnit(aUnit)

	if not aUnit or not VUHDO_RAID[aUnit] then
		return;
	end

	tRefreshIsRestricted = VUHDO_isAuraDataRestricted();

	for tRefreshBouquetName, _ in pairs(VUHDO_AURA_LIST_BOUQUETS or sEmpty) do
		tRefreshRestrictedMode = VUHDO_classifyBouquetRestrictedMode(tRefreshBouquetName);

		if not tRefreshIsRestricted or tRefreshRestrictedMode == VUHDO_BOUQUET_RESTRICTED_NON_AURA
			or tRefreshRestrictedMode == VUHDO_BOUQUET_RESTRICTED_MIXED then
			tRefreshLastEval = VUHDO_LAST_EVALUATED_BOUQUETS[tRefreshBouquetName] and VUHDO_LAST_EVALUATED_BOUQUETS[tRefreshBouquetName][aUnit];

			if tRefreshLastEval then
				tRefreshLastEval[1] = nil;
			end

			VUHDO_updateEventBouquet(aUnit, tRefreshBouquetName, 1);
		end
	end

	return;

end



do
	--
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tColor;
	local tBuffName;
	local tHasChanged;
	local tImpact;
	local tTimer2;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tMaxColor;
	local tLayerTemplate;
	local tIsAliveTime;
	local tAllListeners;
	local tDestArray;
	function VUHDO_updateUnitCyclicBouquet(aUnit, aBouquetName)

		if not aUnit or not aBouquetName then
			return;
		end

		tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, tHasChanged,
			tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime = VUHDO_evaluateBouquet(aUnit, aBouquetName, nil);

		if tHasChanged and (tIsActive or VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName]) then
			tAllListeners = VUHDO_REGISTERED_BOUQUETS[aBouquetName];

			for _, tDelegate in pairs(tAllListeners) do
				tDelegate(aUnit, tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, aBouquetName,
					tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime);
			end

			VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] = tIsActive;
		end

		return;

	end



	--
	function VUHDO_updateAllCyclicBouquets(anIsPlayerOnly)

		tDestArray = anIsPlayerOnly and sPlayerArray or VUHDO_RAID;

		for tBouquetName, _ in pairs(VUHDO_CYCLIC_BOUQUETS) do
			for tUnit, _ in pairs(tDestArray) do
				VUHDO_updateUnitCyclicBouquet(tUnit, tBouquetName);
			end
		end

		return;

	end



	--
	function VUHDO_deferUpdateAllCyclicBouquets(anIsPlayerOnly, aPriority)

		tDestArray = anIsPlayerOnly and sPlayerArray or VUHDO_RAID;

		if not tDestArray then
			return;
		end

		for tBouquetName, _ in pairs(VUHDO_CYCLIC_BOUQUETS) do
			for tUnit, _ in pairs(tDestArray) do
				VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_CYCLIC_BOUQUET, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH, tUnit, tBouquetName);
			end
		end

		return;

	end
end



--
function VUHDO_bouqetsChanged()

	twipe(VUHDO_EVENT_BOUQUETS);

	for tEventType = 1, 50 do
		twipe(VUHDO_EVENT_INTEREST_CACHE[tEventType]);
	end

	VUHDO_initFromSpellbook();
	VUHDO_registerAllBouquets(false);

	return;

end



--
function VUHDO_isAnyoneInterestedIn(anUpdateMode)

	if (VUHDO_isAnyBouquetInterestedIn(anUpdateMode) or VUHDO_isAnyTextIndicatorInterestedIn(anUpdateMode)) then
		return true;
	else
		if 5 == anUpdateMode then -- VUHDO_UPDATE_RANGE
			return true;
		elseif 7 == anUpdateMode then -- VUHDO_UPDATE_AGGRO
			return VUHDO_CONFIG["THREAT"]["AGGRO_USE_TEXT"];
		elseif 16 == anUpdateMode then -- VUHDO_UPDATE_NUM_CLUSTER
			return VUHDO_getIsClusterSlotActive();
		elseif 22 == anUpdateMode then -- VUHDO_UPDATE_UNIT_TARGET
			for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
				if VUHDO_PANEL_MODELS[tCnt] then
					if (VUHDO_PANEL_SETUP[tCnt]["SCALING"]["showTarget"] or VUHDO_PANEL_SETUP[tCnt]["SCALING"]["showTot"]) then
						return true;
					end
				end
			end
		end

		return false;
	end

end



--
function VUHDO_getRegisteredBouquets()

	return VUHDO_REGISTERED_BOUQUETS;

end



--
function VUHDO_getActiveBouquets()

	return VUHDO_ACTIVE_BOUQUETS;

end



--
function VUHDO_getRegisteredBouquetIndicators(anIndicatorName)

	if anIndicatorName then
		return VUHDO_REGISTERED_BOUQUET_INDICATORS[anIndicatorName];
	else
		return VUHDO_REGISTERED_BOUQUET_INDICATORS;
	end

	return;

end