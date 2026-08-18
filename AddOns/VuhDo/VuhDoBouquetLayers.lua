local _;

local pairs = pairs;
local tinsert = table.insert;
local twipe = table.wipe;
local format = string.format;

local CreateFrame = CreateFrame;
local InCombatLockdown = InCombatLockdown;

local VUHDO_META_NEW_ARRAY = VUHDO_META_NEW_ARRAY;
local VUHDO_BOUQUET_BUFFS_SPECIAL;
local VUHDO_BOUQUETS;
local VUHDO_INDICATOR_CONFIG;
local VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH;
local VUHDO_SECRET_TYPE_NONE;
local VUHDO_SECRET_TYPE_BOOLEAN;
local VUHDO_MAX_ALPHA_CHAIN_STEPS;

local VUHDO_BOUQUET_LAYER_TYPE_NONSECRET;
local VUHDO_BOUQUET_LAYER_TYPE_CURVE;
local VUHDO_BOUQUET_LAYER_TYPE_DISPEL;
local VUHDO_BOUQUET_LAYER_TYPE_AURA;

local VUHDO_RAID_TARGET_TEXTURE_ROWS = 4;
local VUHDO_RAID_TARGET_TEXTURE_COLUMNS = 4;

local VUHDO_INDICATOR_BAR_MAP = {
	["BACKGROUND_BAR"] = 3,
	["HEALTH_BAR"] = 1,
	["MANA_BAR"] = 2,
	["AGGRO_BAR"] = 4,
	["THREAT_BAR"] = 7,
	["SIDE_LEFT"] = 17,
	["SIDE_RIGHT"] = 18,
	["MOUSEOVER_HIGHLIGHT"] = 8,
};

local VUHDO_INDICATOR_FRAME_GETTERS = {
	["BAR_BORDER"] = "VUHDO_getPlayerTargetFrame",
	["CLUSTER_BORDER"] = "VUHDO_getClusterBorderFrame",
};

local VUHDO_PixelUtil;

local VUHDO_getHealthBar;
local VUHDO_getBarText;
local VUHDO_getBarTextSolo;
local VUHDO_getLifeText;
local VUHDO_restoreLifeTextAlpha;
local VUHDO_decompressIfCompressed;
local VUHDO_getBouquetGlobalOpacityNames;
local VUHDO_isAuraDataRestricted;
local VUHDO_copyStatusBarFillTexture;
local VUHDO_getBouquetLayerTemplate;
local VUHDO_invalidatePanelButtonInits;

local VUHDO_OVERLAY_CONTAINERS = VUHDO_OVERLAY_CONTAINERS or { };

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;

local sBooleanOverlayLayers = { };
setmetatable(sBooleanOverlayLayers, VUHDO_META_NEW_ARRAY);

local sGlobalAlphaChains = { };
setmetatable(sGlobalAlphaChains, VUHDO_META_NEW_ARRAY);

local sAlphaChainPool;
local sIdentityTextColor = CreateColor(1, 1, 1, 1);

local sAlphaChainStepEntryPool;

local sAlphaChainConfigVersion = 0;

local sAlphaChainWrappers = { };
setmetatable(sAlphaChainWrappers, VUHDO_META_NEW_ARRAY);

local sPendingAlphaChainRebuild = false;

local VUHDO_TARGET_TYPE_BAR = 1;
local VUHDO_TARGET_TYPE_TEXTURE = 2;
local VUHDO_TARGET_TYPE_BORDER = 3;

local sCurrentOpacity = 1;



--
local function VUHDO_createAlphaChainDelegate()

	return {
		["steps"] = { },
		["nonSecretSteps"] = { },
		["overrideValidators"] = { },
		["head"] = nil,
		["tail"] = nil,
		["originalParent"] = nil,
		["barIndex"] = nil,
	};

end



--
local function VUHDO_cleanupAlphaChainDelegate(aChain)

	for tIdx = 1, #aChain["steps"] do
		sAlphaChainStepEntryPool:release(aChain["steps"][tIdx]);
	end

	for tIdx = 1, #aChain["nonSecretSteps"] do
		sAlphaChainStepEntryPool:release(aChain["nonSecretSteps"][tIdx]);
	end

	for tIdx = 1, #aChain["overrideValidators"] do
		sAlphaChainStepEntryPool:release(aChain["overrideValidators"][tIdx]);
	end

	twipe(aChain["steps"]);
	twipe(aChain["nonSecretSteps"]);
	twipe(aChain["overrideValidators"]);

	aChain["head"] = nil;
	aChain["tail"] = nil;
	aChain["originalParent"] = nil;
	aChain["barIndex"] = nil;

	return;

end



--
function VUHDO_bouquetLayersInitLocalOverrides()

	VUHDO_META_NEW_ARRAY = _G["VUHDO_META_NEW_ARRAY"];
	VUHDO_BOUQUET_BUFFS_SPECIAL = _G["VUHDO_BOUQUET_BUFFS_SPECIAL"];
	VUHDO_BOUQUETS = _G["VUHDO_BOUQUETS"];
	VUHDO_INDICATOR_CONFIG = _G["VUHDO_INDICATOR_CONFIG"];
	VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH = _G["VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH"];
	VUHDO_SECRET_TYPE_NONE = _G["VUHDO_SECRET_TYPE_NONE"];
	VUHDO_SECRET_TYPE_BOOLEAN = _G["VUHDO_SECRET_TYPE_BOOLEAN"];
	VUHDO_MAX_ALPHA_CHAIN_STEPS = _G["VUHDO_MAX_ALPHA_CHAIN_STEPS"];

	VUHDO_BOUQUET_LAYER_TYPE_NONSECRET = _G["VUHDO_BOUQUET_LAYER_TYPE_NONSECRET"];
	VUHDO_BOUQUET_LAYER_TYPE_CURVE = _G["VUHDO_BOUQUET_LAYER_TYPE_CURVE"];
	VUHDO_BOUQUET_LAYER_TYPE_DISPEL = _G["VUHDO_BOUQUET_LAYER_TYPE_DISPEL"];
	VUHDO_BOUQUET_LAYER_TYPE_AURA = _G["VUHDO_BOUQUET_LAYER_TYPE_AURA"];

	VUHDO_PixelUtil = _G["VUHDO_PixelUtil"];

	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getBarText = _G["VUHDO_getBarText"];
	VUHDO_getBarTextSolo = _G["VUHDO_getBarTextSolo"];
	VUHDO_getLifeText = _G["VUHDO_getLifeText"];
	VUHDO_restoreLifeTextAlpha = _G["VUHDO_restoreLifeTextAlpha"];
	VUHDO_decompressIfCompressed = _G["VUHDO_decompressIfCompressed"];
	VUHDO_getBouquetGlobalOpacityNames = _G["VUHDO_getBouquetGlobalOpacityNames"];
	VUHDO_isAuraDataRestricted = _G["VUHDO_isAuraDataRestricted"];
	VUHDO_copyStatusBarFillTexture = _G["VUHDO_copyStatusBarFillTexture"];
	VUHDO_getBouquetLayerTemplate = _G["VUHDO_getBouquetLayerTemplate"];
	VUHDO_invalidatePanelButtonInits = _G["VUHDO_invalidatePanelButtonInits"];

	sAlphaChainStepEntryPool = VUHDO_createTablePool("AlphaChainStepEntry", 100);
	sAlphaChainPool = VUHDO_createTablePool("AlphaChain", 50, VUHDO_createAlphaChainDelegate, VUHDO_cleanupAlphaChainDelegate);

	return;

end



--
local tOverlay;
local tTargetOverlays;
local tFillAnchorRegion;
local tTexture;
local function VUHDO_applyBooleanOverlayFillTexture(aTexture, aTarget, aTargetType)

	if aTargetType == VUHDO_TARGET_TYPE_BAR then
		tFillAnchorRegion = aTarget:GetStatusBarTexture() or aTarget;
	else
		tFillAnchorRegion = aTarget;
	end

	aTexture:ClearAllPoints();
	aTexture:SetAllPoints(tFillAnchorRegion);

	if aTargetType == VUHDO_TARGET_TYPE_BAR then
		if not VUHDO_copyStatusBarFillTexture(aTexture, aTarget) then
			aTexture:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMP", "CLAMP", "NEAREST");

			VUHDO_PixelUtil.ApplySettings(aTexture);
		end
	else
		aTexture:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMP", "CLAMP", "NEAREST");

		VUHDO_PixelUtil.ApplySettings(aTexture);
	end

	return;

end



--
local function VUHDO_createBooleanOverlay(aButton, aTarget, aValidatorName, aTargetType)

	tTargetOverlays = sBooleanOverlayLayers[aButton][aTarget];

	if not tTargetOverlays then
		tTargetOverlays = { };

		sBooleanOverlayLayers[aButton][aTarget] = tTargetOverlays;
	end

	if tTargetOverlays[aValidatorName] then
		return tTargetOverlays[aValidatorName];
	end

	tOverlay = aTarget:CreateTexture(nil, "OVERLAY");

	tOverlay:SetAlpha(0);

	VUHDO_applyBooleanOverlayFillTexture(tOverlay, aTarget, aTargetType);

	tTargetOverlays[aValidatorName] = {
		["texture"] = tOverlay,
		["isCleared"] = true,
	};

	return tTargetOverlays[aValidatorName];

end



--
local function VUHDO_clearBooleanOverlay(aOverlay)

	if aOverlay["isCleared"] then
		return;
	end

	aOverlay["texture"]:SetAlpha(0);

	aOverlay["isCleared"] = true;

	return;

end



--
local function VUHDO_getBooleanOverlay(aButton, aTarget, aValidatorName)

	tTargetOverlays = sBooleanOverlayLayers[aButton][aTarget];

	if tTargetOverlays then
		return tTargetOverlays[aValidatorName];
	end

	return nil;

end



--
local tConfig;
function VUHDO_applyBooleanOverlay(aOverlay, aResultSlot)

	tTexture = aOverlay["texture"];
	tConfig = aResultSlot["color"];

	if tConfig["useBackground"] then
		tTexture:SetVertexColorFromBoolean(aResultSlot["secretBool"], aResultSlot["trueColorMixin"], aResultSlot["falseColorMixin"]);
		tTexture:SetAlphaFromBoolean(aResultSlot["secretBool"], aResultSlot["trueAlpha"], aResultSlot["falseAlpha"]);

		aOverlay["isCleared"] = nil;
	else
		VUHDO_clearBooleanOverlay(aOverlay);
	end

	return;

end



--
function VUHDO_clearBooleanOverlays(aButton)

	for _, tTargetOverlaysClear in pairs(sBooleanOverlayLayers[aButton]) do
		for _, tOverlay in pairs(tTargetOverlaysClear) do
			VUHDO_clearBooleanOverlay(tOverlay);
		end
	end

	return;

end



--
function VUHDO_resetAlphaChainWrappers(aButton)

	for _, tResetWrapperData in pairs(sAlphaChainWrappers[aButton]) do
		for tCnt = 1, VUHDO_MAX_ALPHA_CHAIN_STEPS do
			tResetWrapperData["wrappers"][tCnt]:SetAlpha(1);
		end
	end

	return;

end



--
local tIndicatorResetWrapperData;
function VUHDO_resetAlphaChainWrappersForIndicator(aButton, anIndicatorName)

	tIndicatorResetWrapperData = sAlphaChainWrappers[aButton] and sAlphaChainWrappers[aButton][anIndicatorName];

	if not tIndicatorResetWrapperData then
		return;
	end

	for tCnt = 1, VUHDO_MAX_ALPHA_CHAIN_STEPS do
		tIndicatorResetWrapperData["wrappers"][tCnt]:SetAlpha(1);
	end

	return;

end



--
function VUHDO_flushPendingAlphaChainRebuild()

	if not sPendingAlphaChainRebuild then
		return;
	end

	sPendingAlphaChainRebuild = false;

	VUHDO_invalidatePanelButtonInits();

	return;

end



--
function VUHDO_incrementAlphaChainConfigVersion()

	sAlphaChainConfigVersion = sAlphaChainConfigVersion + 1;

	return;

end



--
local tWrapperData;
local tParentFrame;
local tButtonName;
local tWrapper;
local function VUHDO_initAlphaChainWrapperNest(aButton, anIndicatorName, anIndicatorBar, anOriginalParent)

	tWrapperData = sAlphaChainWrappers[aButton] and sAlphaChainWrappers[aButton][anIndicatorName];

	if tWrapperData then
		return tWrapperData;
	end

	if not sAlphaChainWrappers[aButton] then
		sAlphaChainWrappers[aButton] = { };
	end

	tWrapperData = {
		["wrappers"] = { },
		["originalParent"] = anOriginalParent,
		["tail"] = nil,
	};

	tParentFrame = anOriginalParent;
	tButtonName = aButton:GetName() or "VdBtn";

	for tCnt = 1, VUHDO_MAX_ALPHA_CHAIN_STEPS do
		tWrapper = CreateFrame("Frame", format("%s%sAlpWr%d", tButtonName, anIndicatorName, tCnt), tParentFrame);

		VUHDO_PixelUtil.SetPoint(tWrapper, "TOPLEFT", tParentFrame, "TOPLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(tWrapper, "BOTTOMRIGHT", tParentFrame, "BOTTOMRIGHT", 0, 0);

		tWrapper["isAlphaChainWrapper"] = true;
		VUHDO_PixelUtil.SetFrameLevel(tWrapper, tParentFrame:GetFrameLevel());

		tWrapper:SetAlpha(1);
		tWrapper:Show();

		tWrapperData["wrappers"][tCnt] = tWrapper;
		tParentFrame = tWrapper;
	end

	tWrapperData["tail"] = tWrapperData["wrappers"][VUHDO_MAX_ALPHA_CHAIN_STEPS];

	anIndicatorBar:SetParent(tWrapperData["tail"]);
	anIndicatorBar["vuhdo_parent"] = anOriginalParent;

	sAlphaChainWrappers[aButton][anIndicatorName] = tWrapperData;

	return tWrapperData;

end



--
local tItem;
local tSpecial;
local tChain;
local tSecretType;
local tIndicatorBar;
local tOriginalParent;
local tBarIndex;
local tFrameGetter;
local tEntry;
local tHealthBouquetName;
local tHealthGlobalOpacityNames;
local tStepCnt;
local tBooleanStepByName = { };
local tItemTrueAlpha;
local tItemFalseAlpha;
local tExistingEntry;
function VUHDO_buildGlobalAlphaChainsForIndicator(aButton, anIndicatorName, aBouquet, aPanelNum)

	if not aBouquet or not sSecretsEnabled then
		return;
	end

	tBarIndex = VUHDO_INDICATOR_BAR_MAP[anIndicatorName];

	if tBarIndex then
		tIndicatorBar = VUHDO_getHealthBar(aButton, tBarIndex);
	else
		tFrameGetter = VUHDO_INDICATOR_FRAME_GETTERS[anIndicatorName];

		if tFrameGetter then
			tIndicatorBar = _G[tFrameGetter](aButton);
		end
	end

	if not tIndicatorBar then
		return;
	end

	tOriginalParent = tIndicatorBar["vuhdo_parent"] or tIndicatorBar:GetParent();

	tWrapperData = VUHDO_initAlphaChainWrapperNest(aButton, anIndicatorName, tIndicatorBar, tOriginalParent);

	for tCnt = 1, VUHDO_MAX_ALPHA_CHAIN_STEPS do
		tWrapperData["wrappers"][tCnt]:SetAlpha(1);
	end

	if sGlobalAlphaChains[aButton] and sGlobalAlphaChains[aButton][anIndicatorName] then
		sAlphaChainPool:release(sGlobalAlphaChains[aButton][anIndicatorName]);
		sGlobalAlphaChains[aButton][anIndicatorName] = nil;
	end

	if not sGlobalAlphaChains[aButton] then
		sGlobalAlphaChains[aButton] = { };
	end

	tChain = sAlphaChainPool:get();

	tChain["originalParent"] = tOriginalParent;
	tChain["barIndex"] = tBarIndex;
	tChain["tail"] = tWrapperData["tail"];

	sGlobalAlphaChains[aButton][anIndicatorName] = tChain;

	tHealthGlobalOpacityNames = nil;

	if "MANA_BAR" == anIndicatorName and aPanelNum and VUHDO_INDICATOR_CONFIG[aPanelNum] then
		tHealthBouquetName = VUHDO_INDICATOR_CONFIG[aPanelNum]["BOUQUETS"]["HEALTH_BAR"];

		if tHealthBouquetName and tHealthBouquetName ~= "" then
			tHealthGlobalOpacityNames = VUHDO_getBouquetGlobalOpacityNames(tHealthBouquetName);
		end
	end

	tStepCnt = 0;

	twipe(tBooleanStepByName);

	for tCnt = 1, #aBouquet do
		tItem = aBouquet[tCnt];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]];

		if tSpecial and tSpecial["isGlobal"] and tItem["color"] and tItem["color"]["useOpacity"] and not tItem["color"]["useBackground"] then
			if not tHealthGlobalOpacityNames or not tHealthGlobalOpacityNames[tItem["name"]] then
				tSecretType = tSpecial["secretType"] or VUHDO_SECRET_TYPE_NONE;

				if tSecretType == VUHDO_SECRET_TYPE_BOOLEAN then
					tItemTrueAlpha = tSpecial["isInverted"] and 1 or (tItem["color"]["O"] or 1);
					tItemFalseAlpha = tSpecial["isInverted"] and (tItem["color"]["O"] or 1) or 1;

					tExistingEntry = tBooleanStepByName[tItem["name"]];

					if tExistingEntry then
						tExistingEntry["trueAlpha"] = tExistingEntry["trueAlpha"] * tItemTrueAlpha;
						tExistingEntry["falseAlpha"] = tExistingEntry["falseAlpha"] * tItemFalseAlpha;
					elseif tStepCnt < VUHDO_MAX_ALPHA_CHAIN_STEPS then
						tStepCnt = tStepCnt + 1;

						tWrapper = tWrapperData["wrappers"][tStepCnt];

						tEntry = sAlphaChainStepEntryPool:get();

						tEntry["frame"] = tWrapper;
						tEntry["wrapperIndex"] = tStepCnt;
						tEntry["item"] = tItem;
						tEntry["special"] = tSpecial;
						tEntry["index"] = tCnt;
						tEntry["trueAlpha"] = tItemTrueAlpha;
						tEntry["falseAlpha"] = tItemFalseAlpha;

						tBooleanStepByName[tItem["name"]] = tEntry;

						tinsert(tChain["steps"], tEntry);
					end
				else
					tEntry = sAlphaChainStepEntryPool:get();

					tEntry["item"] = tItem;
					tEntry["special"] = tSpecial;
					tEntry["index"] = tCnt;
					tEntry["alpha"] = tItem["color"]["O"] or 1;

					tinsert(tChain["nonSecretSteps"], tEntry);
				end
			end
		end
	end

	for tCnt = 1, #aBouquet do
		tItem = aBouquet[tCnt];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]];

		if tSpecial and tSpecial["isGlobal"] and tItem["color"] and tItem["color"]["useBackground"] then
			tSecretType = tSpecial["secretType"] or VUHDO_SECRET_TYPE_NONE;

			if tSecretType == VUHDO_SECRET_TYPE_NONE then
				tEntry = sAlphaChainStepEntryPool:get();

				tEntry["item"] = tItem;
				tEntry["special"] = tSpecial;
				tEntry["index"] = tCnt;

				tinsert(tChain["overrideValidators"], tEntry);
			end
		end
	end

	if #tChain["steps"] > 0 then
		tChain["head"] = tChain["steps"][1]["frame"];
	else
		tChain["head"] = tOriginalParent;
	end

	return;

end



--
function VUHDO_getAlphaChainTail(aButton, anIndicatorName)

	if not sGlobalAlphaChains[aButton] or not sGlobalAlphaChains[aButton][anIndicatorName] then
		return nil;
	end

	return sGlobalAlphaChains[aButton][anIndicatorName]["tail"];

end



--
local tBouquetName;
local tBouquet;
local tIndicatorConfig;
function VUHDO_buildAllIndicatorAlphaChains(aButton, aPanelNum)

	if not sSecretsEnabled then
		return false;
	end

	if InCombatLockdown() then
		sPendingAlphaChainRebuild = true;

		return false;
	end

	if aButton["alphaChainConfigVersion"] == sAlphaChainConfigVersion and aButton["alphaChainPanelNum"] == aPanelNum then
		return false;
	end

	tIndicatorConfig = VUHDO_INDICATOR_CONFIG[aPanelNum];

	if not tIndicatorConfig then
		return false;
	end

	for tIndicatorName, _ in pairs(VUHDO_INDICATOR_BAR_MAP) do
		tBouquetName = tIndicatorConfig["BOUQUETS"][tIndicatorName];
		tBouquet = tBouquetName and tBouquetName ~= "" and VUHDO_BOUQUETS["STORED"][tBouquetName];

		if tBouquet then
			tBouquet = VUHDO_decompressIfCompressed(tBouquet);
			VUHDO_BOUQUETS["STORED"][tBouquetName] = tBouquet;

			VUHDO_buildGlobalAlphaChainsForIndicator(aButton, tIndicatorName, tBouquet, aPanelNum);
		end
	end

	for tIndicatorName, _ in pairs(VUHDO_INDICATOR_FRAME_GETTERS) do
		tBouquetName = tIndicatorConfig["BOUQUETS"][tIndicatorName];
		tBouquet = tBouquetName and tBouquetName ~= "" and VUHDO_BOUQUETS["STORED"][tBouquetName];

		if tBouquet then
			tBouquet = VUHDO_decompressIfCompressed(tBouquet);
			VUHDO_BOUQUETS["STORED"][tBouquetName] = tBouquet;

			VUHDO_buildGlobalAlphaChainsForIndicator(aButton, tIndicatorName, tBouquet, aPanelNum);
		end
	end

	aButton["alphaChainConfigVersion"] = sAlphaChainConfigVersion;
	aButton["alphaChainPanelNum"] = aPanelNum;

	return true;

end



--
function VUHDO_buildTargetIndicatorAlphaChains(aButton, aPanelNum)

	if not sSecretsEnabled then
		return false;
	end

	if InCombatLockdown() then
		sPendingAlphaChainRebuild = true;

		return false;
	end

	if aButton["alphaChainConfigVersion"] == sAlphaChainConfigVersion and aButton["alphaChainPanelNum"] == aPanelNum then
		return false;
	end

	tBouquet = VUHDO_BOUQUETS["STORED"][VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH];

	if not tBouquet then
		return false;
	end

	tBouquet = VUHDO_decompressIfCompressed(tBouquet);
	VUHDO_BOUQUETS["STORED"][VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH] = tBouquet;

	VUHDO_buildGlobalAlphaChainsForIndicator(aButton, "HEALTH_BAR", tBouquet, aPanelNum);
	VUHDO_buildGlobalAlphaChainsForIndicator(aButton, "MANA_BAR", tBouquet, aPanelNum);

	aButton["alphaChainConfigVersion"] = sAlphaChainConfigVersion;
	aButton["alphaChainPanelNum"] = aPanelNum;

	return true;

end



--
local tLayerTemplate;
local tValidatorEntry;
local tBuildBarIndex;
local function VUHDO_buildBooleanOverlaysForTarget(aButton, aTarget, aTargetType, aLayerTemplate)

	for tIdx = 1, #aLayerTemplate["booleanResults"] do
		tValidatorEntry = aLayerTemplate["booleanValidators"][tIdx];

		tOverlay = VUHDO_createBooleanOverlay(aButton, aTarget,
			tValidatorEntry["item"]["name"], aTargetType);

		if tOverlay then
			VUHDO_applyBooleanOverlayFillTexture(tOverlay["texture"], aTarget, aTargetType);
		end
	end

	return;

end



--
function VUHDO_buildBooleanOverlaysForButton(aButton, aPanelNum)

	if not sSecretsEnabled then
		return false;
	end

	if InCombatLockdown() then
		sPendingAlphaChainRebuild = true;

		return false;
	end

	VUHDO_clearBooleanOverlays(aButton);

	tIndicatorConfig = VUHDO_INDICATOR_CONFIG[aPanelNum];

	if not tIndicatorConfig then
		return false;
	end

	for tIndicatorName, _ in pairs(VUHDO_INDICATOR_BAR_MAP) do
		tBouquetName = tIndicatorConfig["BOUQUETS"][tIndicatorName];
		tLayerTemplate = tBouquetName and tBouquetName ~= "" and VUHDO_getBouquetLayerTemplate(tBouquetName);

		if tLayerTemplate and tLayerTemplate["hasBools"] then
			tBuildBarIndex = VUHDO_INDICATOR_BAR_MAP[tIndicatorName];
			tIndicatorBar = VUHDO_getHealthBar(aButton, tBuildBarIndex);

			if tIndicatorBar then
				VUHDO_buildBooleanOverlaysForTarget(aButton, tIndicatorBar, VUHDO_TARGET_TYPE_BAR, tLayerTemplate);
			end
		end
	end

	for tIndicatorName, _ in pairs(VUHDO_INDICATOR_FRAME_GETTERS) do
		tBouquetName = tIndicatorConfig["BOUQUETS"][tIndicatorName];
		tLayerTemplate = tBouquetName and tBouquetName ~= "" and VUHDO_getBouquetLayerTemplate(tBouquetName);

		if tLayerTemplate and tLayerTemplate["hasBools"] then
			tFrameGetter = VUHDO_INDICATOR_FRAME_GETTERS[tIndicatorName];
			tIndicatorBar = _G[tFrameGetter](aButton);

			if tIndicatorBar then
				VUHDO_buildBooleanOverlaysForTarget(aButton, tIndicatorBar, VUHDO_TARGET_TYPE_BORDER, tLayerTemplate);
			end
		end
	end

	return true;

end



--
local tChain;
local tStep;
local tSecretBool;
local tNonSecretAlpha;
local tIsActive;
local tIsBoolTrue;
local tIndicatorBar;
local tFrameGetter;
local tMinOverrideIndex;
local tOverride;
local tStepItemColor;
local tIsOpacityOnlyStep;
function VUHDO_updateIndicatorAlphaChain(aButton, anIndicatorName, anInfo)

	if not anInfo then
		return;
	end

	if not sGlobalAlphaChains[aButton] then
		VUHDO_resetAlphaChainWrappersForIndicator(aButton, anIndicatorName);

		return;
	end

	tChain = sGlobalAlphaChains[aButton][anIndicatorName];

	if not tChain then
		VUHDO_resetAlphaChainWrappersForIndicator(aButton, anIndicatorName);

		return;
	end

	if tChain["barIndex"] then
		tIndicatorBar = VUHDO_getHealthBar(aButton, tChain["barIndex"]);
	else
		tFrameGetter = VUHDO_INDICATOR_FRAME_GETTERS[anIndicatorName];

		if tFrameGetter then
			tIndicatorBar = _G[tFrameGetter](aButton);
		end
	end

	if not tIndicatorBar then
		return;
	end

	tMinOverrideIndex = nil;

	if tChain["overrideValidators"] then
		for tIdx = 1, #tChain["overrideValidators"] do
			tOverride = tChain["overrideValidators"][tIdx];

			if tOverride["special"]["validator"](anInfo, tOverride["item"]) then
				if not tMinOverrideIndex or tOverride["index"] < tMinOverrideIndex then
					tMinOverrideIndex = tOverride["index"];
				end
			end
		end
	end

	tNonSecretAlpha = 1.0;

	for tIdx = 1, #tChain["nonSecretSteps"] do
		tStep = tChain["nonSecretSteps"][tIdx];

		if not tMinOverrideIndex or tStep["index"] <= tMinOverrideIndex then
			tIsActive = tStep["special"]["validator"](anInfo, tStep["item"]);

			if tIsActive then
				tNonSecretAlpha = tNonSecretAlpha * tStep["alpha"];
			end
		end
	end

	tIndicatorBar:SetAlpha(tNonSecretAlpha);

	for tIdx = 1, #tChain["steps"] do
		tStep = tChain["steps"][tIdx];

		tStepItemColor = tStep["item"] and tStep["item"]["color"];
		tIsOpacityOnlyStep = tStepItemColor and tStepItemColor["useOpacity"] and not tStepItemColor["useBackground"];

		if tMinOverrideIndex and tStep["index"] > tMinOverrideIndex and not tIsOpacityOnlyStep then
			tStep["frame"]:SetAlpha(1);
		else
			tIsActive, _, _, _, _, _, _, _, _, _, _, tSecretBool = tStep["special"]["validator"](anInfo, tStep["item"]);

			if tSecretBool ~= nil then
				tStep["frame"]:SetAlphaFromBoolean(tSecretBool, tStep["trueAlpha"], tStep["falseAlpha"]);
			else
				if tStep["special"]["isInverted"] then
					tIsBoolTrue = not tIsActive;
				else
					tIsBoolTrue = tIsActive;
				end

				tStep["frame"]:SetAlpha(tIsBoolTrue and tStep["trueAlpha"] or tStep["falseAlpha"]);
			end
		end
	end

	return;

end



--
local tIndicatorChains;
function VUHDO_updateAllIndicatorAlphaChains(aButton, anInfo)

	if not anInfo then
		VUHDO_resetAlphaChainWrappers(aButton);

		return;
	end

	tIndicatorChains = sGlobalAlphaChains[aButton];

	if not tIndicatorChains then
		VUHDO_resetAlphaChainWrappers(aButton);

		return;
	end

	for tIndicatorName, _ in pairs(tIndicatorChains) do
		VUHDO_updateIndicatorAlphaChain(aButton, tIndicatorName, anInfo);
	end

	return;

end



--
local tValidatorResult;
function VUHDO_evaluateValidatorActive(aSpecial, anInfo, aItem)

	if not aSpecial or not aSpecial["validator"] then
		return false;
	end

	tValidatorResult = aSpecial["validator"](anInfo, aItem);

	return tValidatorResult == true;

end



--
local tDebuffInfo;
function VUHDO_getChosenDebuffAuraInstanceId(aUnit)

	tDebuffInfo = VUHDO_getChosenDebuffInfo(aUnit);

	if tDebuffInfo and tDebuffInfo[8] then
		return tDebuffInfo[8];
	end

	return nil;

end



--
function VUHDO_rebuildAllAlphaChains()

	for tButton, tIndicatorChains in pairs(sGlobalAlphaChains) do
		VUHDO_resetAlphaChainWrappers(tButton);

		for tIndicatorName, tChain in pairs(tIndicatorChains) do
			sAlphaChainPool:release(tChain);
		end
	end

	twipe(sGlobalAlphaChains);

	return;

end



--
local tResultSlot;
local tOverlay;
local function VUHDO_applyBooleanLayers(aButton, aTarget, aTargetType, aLayerTemplate)

	if not aLayerTemplate["hasBools"] then
		return;
	end

	for tIdx = 1, #aLayerTemplate["booleanResults"] do
		tResultSlot = aLayerTemplate["booleanResults"][tIdx];
		tOverlay = VUHDO_getBooleanOverlay(aButton, aTarget, aLayerTemplate["booleanValidators"][tIdx]["item"]["name"], aTargetType);

		if tOverlay then
			if tResultSlot["color"] and tResultSlot["color"]["useBackground"] and tResultSlot["trueColorMixin"] and tResultSlot["falseColorMixin"] and tResultSlot["secretBool"] ~= nil then
				VUHDO_applyBooleanOverlay(tOverlay, tResultSlot);
			else
				VUHDO_clearBooleanOverlay(tOverlay);
			end
		end
	end

	return;

end



--
local tO;
local function VUHDO_applyBackgroundColorToTarget(aTarget, aTargetType, aColor)

	if not aColor or not aColor["useBackground"] then
		return;
	end

	tO = aColor["O"];

	if tO == nil then
		tO = 1;
	end

	if aColor["useOpacity"] then
		sCurrentOpacity = tO;

		if aTargetType == VUHDO_TARGET_TYPE_BAR then
			aTarget:GetStatusBarTexture():SetVertexColor(aColor["R"], aColor["G"], aColor["B"], tO);
		elseif aTargetType == VUHDO_TARGET_TYPE_TEXTURE then
			aTarget:SetVertexColor(aColor["R"], aColor["G"], aColor["B"], tO);
		elseif aTargetType == VUHDO_TARGET_TYPE_BORDER then
			aTarget:SetBackdropBorderColor(aColor["R"], aColor["G"], aColor["B"], tO);
		end
	else
		if aTargetType == VUHDO_TARGET_TYPE_BAR then
			aTarget:GetStatusBarTexture():SetVertexColor(aColor["R"], aColor["G"], aColor["B"]);
		elseif aTargetType == VUHDO_TARGET_TYPE_TEXTURE then
			aTarget:SetVertexColor(aColor["R"], aColor["G"], aColor["B"]);
		elseif aTargetType == VUHDO_TARGET_TYPE_BORDER then
			aTarget:SetBackdropBorderColor(aColor["R"], aColor["G"], aColor["B"]);
		end
	end

	return;

end



--
local tEffectiveAlpha;
local function VUHDO_applyRawColorToTarget(aTarget, aTargetType, aR, aG, aB, aA, aLayerTemplate)

	if not aLayerTemplate["useBackground"] then
		return;
	end

	if aLayerTemplate["useOpacity"] and aA then
		tEffectiveAlpha = aA;
	elseif aLayerTemplate["useOpacity"] then
		tEffectiveAlpha = sCurrentOpacity;
	else
		tEffectiveAlpha = 1;
	end

	if aTargetType == VUHDO_TARGET_TYPE_BAR then
		aTarget:GetStatusBarTexture():SetVertexColor(aR, aG, aB, tEffectiveAlpha);
	elseif aTargetType == VUHDO_TARGET_TYPE_TEXTURE then
		aTarget:SetVertexColor(aR, aG, aB, tEffectiveAlpha);
	elseif aTargetType == VUHDO_TARGET_TYPE_BORDER then
		aTarget:SetBackdropBorderColor(aR, aG, aB, tEffectiveAlpha);
	end

	return;

end



--
local tResetBarText;
local tResetBarTextSolo;
local tResetLifeText;
function VUHDO_resetBarTextVertexColor(aBar)

	if not aBar["booleanTextStamped"] then
		return;
	end

	tResetBarText = VUHDO_getBarText(aBar);

	if tResetBarText then
		tResetBarText:SetVertexColor(1, 1, 1, 1);
	end

	tResetBarTextSolo = VUHDO_getBarTextSolo(aBar);

	if tResetBarTextSolo then
		tResetBarTextSolo:SetVertexColor(1, 1, 1, 1);
	end

	tResetLifeText = VUHDO_getLifeText(aBar);

	if tResetLifeText then
		tResetLifeText:SetVertexColor(1, 1, 1, 1);
	end

	aBar["booleanTextStamped"] = nil;

	VUHDO_restoreLifeTextAlpha(aBar);

	return;

end



--
local tBarText;
local tBarTextSolo;
local tLifeText;
local tInactiveMixin;
local function VUHDO_applyTextColorToBar(aBar, aR, aG, aB)

	VUHDO_resetBarTextVertexColor(aBar);

	if not aBar["booleanTextInactiveMixin"] then
		aBar["booleanTextInactiveMixin"] = CreateColor(1, 1, 1, 1);
	end

	aBar["booleanTextInactiveMixin"]:SetRGBA(aR or 1, aG or 1, aB or 1, 1);

	tBarText = VUHDO_getBarText(aBar);

	if tBarText then
		tBarText:SetTextColor(aR or 1, aG or 1, aB or 1);
	end

	tBarTextSolo = VUHDO_getBarTextSolo(aBar);

	if tBarTextSolo then
		tBarTextSolo:SetTextColor(aR or 1, aG or 1, aB or 1);
	end

	tLifeText = VUHDO_getLifeText(aBar);

	if tLifeText then
		tLifeText:SetTextColor(aR or 1, aG or 1, aB or 1);
	end

	return;

end



--
local tValidatorEntry;
local tWinningTextIdx;
local tWinningTextIndex;
local tSpecial;
local tTrueTextMixin;
local tFalseTextMixin;
local function VUHDO_applyBooleanTextToBar(aBar, aSecretBool, aTrueTextMixin, aFalseTextMixin)

	tBarText = VUHDO_getBarText(aBar);

	if tBarText then
		tBarText:SetTextColor(1, 1, 1);
		tBarText:SetVertexColorFromBoolean(aSecretBool, aTrueTextMixin, aFalseTextMixin);
	end

	tBarTextSolo = VUHDO_getBarTextSolo(aBar);

	if tBarTextSolo then
		tBarTextSolo:SetTextColor(1, 1, 1);
		tBarTextSolo:SetVertexColorFromBoolean(aSecretBool, aTrueTextMixin, aFalseTextMixin);
	end

	tLifeText = VUHDO_getLifeText(aBar);

	if tLifeText then
		tLifeText:SetTextColor(1, 1, 1);
		tLifeText:SetVertexColorFromBoolean(aSecretBool, aTrueTextMixin, aFalseTextMixin);
	end

	aBar["booleanTextStamped"] = true;

	VUHDO_restoreLifeTextAlpha(aBar);

	return;

end



--
local function VUHDO_applyBooleanTextLayers(aBar, aLayerTemplate)

	if not aLayerTemplate["hasBools"] then
		VUHDO_resetBarTextVertexColor(aBar);

		return;
	end

	tWinningTextIdx = nil;
	tWinningTextIndex = nil;

	for tIdx = 1, #aLayerTemplate["booleanResults"] do
		tResultSlot = aLayerTemplate["booleanResults"][tIdx];
		tValidatorEntry = aLayerTemplate["booleanValidators"][tIdx];

		if tResultSlot["color"] and tResultSlot["color"]["useText"] and tResultSlot["activeTextColorMixin"] and tResultSlot["secretBool"] ~= nil then
			if not tWinningTextIndex or tValidatorEntry["index"] < tWinningTextIndex then
				tWinningTextIdx = tIdx;
				tWinningTextIndex = tValidatorEntry["index"];
			end
		end
	end

	if not tWinningTextIdx then
		VUHDO_resetBarTextVertexColor(aBar);

		return;
	end

	tResultSlot = aLayerTemplate["booleanResults"][tWinningTextIdx];
	tValidatorEntry = aLayerTemplate["booleanValidators"][tWinningTextIdx];
	tSpecial = tValidatorEntry["special"];
	tInactiveMixin = aBar["booleanTextInactiveMixin"] or sIdentityTextColor;

	if tSpecial and tSpecial["isInverted"] then
		tTrueTextMixin = tInactiveMixin;
		tFalseTextMixin = tResultSlot["activeTextColorMixin"];
	else
		tTrueTextMixin = tResultSlot["activeTextColorMixin"];
		tFalseTextMixin = tInactiveMixin;
	end

	VUHDO_applyBooleanTextToBar(aBar, tResultSlot["secretBool"], tTrueTextMixin, tFalseTextMixin);

	return;

end



--
local tResultSlot;
function VUHDO_applySpriteCellToTexture(aTexture, aLayerTemplate)

	if not aLayerTemplate or not aLayerTemplate["hasSpriteCells"] then
		return;
	end

	for tIdx = 1, #aLayerTemplate["spriteCellResults"] do
		tResultSlot = aLayerTemplate["spriteCellResults"][tIdx];

		if tResultSlot["isActive"] and tResultSlot["spriteCell"] then
			aTexture:SetTexture(tResultSlot["icon"]);
			aTexture:SetSpriteSheetCell(tResultSlot["spriteCell"], VUHDO_RAID_TARGET_TEXTURE_ROWS, VUHDO_RAID_TARGET_TEXTURE_COLUMNS);

			return;
		end
	end

	return;

end



--
local tResultSlot;
local tColor;
local tMaxSlotColor;
local function VUHDO_applyNonSecretColorByIndex(aTarget, aTargetType, aLayerTemplate, aResultIdx)

	tResultSlot = aLayerTemplate["nonSecretResults"][aResultIdx];

	if not tResultSlot or not tResultSlot["color"] then
		return;
	end

	tColor = tResultSlot["color"];
	tMaxSlotColor = tResultSlot["maxColor"];

	if aTargetType == VUHDO_TARGET_TYPE_BAR and tColor["useBackground"] and aLayerTemplate["useBackground"] and
		tMaxSlotColor and tMaxSlotColor["R"] and tMaxSlotColor["G"] and tMaxSlotColor["B"] and
		tResultSlot["gradientMinMixin"] and tResultSlot["gradientMaxMixin"] then
		aTarget:GetStatusBarTexture():SetGradient("HORIZONTAL", tResultSlot["gradientMinMixin"], tResultSlot["gradientMaxMixin"]);
	else
		VUHDO_applyBackgroundColorToTarget(aTarget, aTargetType, tColor);
	end

	if aTargetType == VUHDO_TARGET_TYPE_BAR and tColor["useText"] then
		VUHDO_applyTextColorToBar(aTarget, tColor["TR"], tColor["TG"], tColor["TB"]);
	end

	return;

end



--
local tResultSlot;
local tColor;
local function VUHDO_applyAuraColorByIndex(aTarget, aTargetType, aLayerTemplate, aResultIdx)

	tResultSlot = aLayerTemplate["auraResults"][aResultIdx];

	if not tResultSlot or not tResultSlot["color"] then
		return;
	end

	tColor = tResultSlot["color"];

	VUHDO_applyBackgroundColorToTarget(aTarget, aTargetType, tColor);

	if aTargetType == VUHDO_TARGET_TYPE_BAR and tColor["useText"] then
		VUHDO_applyTextColorToBar(aTarget, tColor["TR"], tColor["TG"], tColor["TB"]);
	end

	return;

end



--
local tResultSlot;
local tR;
local tG;
local tB;
local tA;
local function VUHDO_applyCurveColorByIndex(aTarget, aTargetType, aLayerTemplate, aResultIdx)

	tResultSlot = aLayerTemplate["curveResults"][aResultIdx];

	if not tResultSlot then
		return;
	end

	if aTargetType == VUHDO_TARGET_TYPE_BAR and tResultSlot["useBarTextureGradient"] and tResultSlot["gradientMinMixin"] and tResultSlot["gradientMaxMixin"] then
		if tResultSlot["r"] and sSecretsEnabled then
			tR, tG, tB, tA = tResultSlot["r"], tResultSlot["g"], tResultSlot["b"], tResultSlot["a"];

			aTarget["secretCurveColor"]["R"] = tR;
			aTarget["secretCurveColor"]["G"] = tG;
			aTarget["secretCurveColor"]["B"] = tB;
			aTarget["secretCurveColor"]["O"] = tA;
		end

		if aLayerTemplate["useBackground"] then
			aTarget:GetStatusBarTexture():SetGradient("HORIZONTAL", tResultSlot["gradientMinMixin"], tResultSlot["gradientMaxMixin"]);
		end

		if aLayerTemplate["useText"] and tResultSlot["r"] then
			tR, tG, tB = tResultSlot["r"], tResultSlot["g"], tResultSlot["b"];

			VUHDO_applyTextColorToBar(aTarget, tR, tG, tB);
		end

		return;
	end

	if not tResultSlot["r"] then
		return;
	end

	tR, tG, tB, tA = tResultSlot["r"], tResultSlot["g"], tResultSlot["b"], tResultSlot["a"];

	if aTargetType == VUHDO_TARGET_TYPE_BAR and sSecretsEnabled then
		aTarget["secretCurveColor"]["R"] = tR;
		aTarget["secretCurveColor"]["G"] = tG;
		aTarget["secretCurveColor"]["B"] = tB;
		aTarget["secretCurveColor"]["O"] = tA;
	end

	VUHDO_applyRawColorToTarget(aTarget, aTargetType, tR, tG, tB, tA, aLayerTemplate);

	if aTargetType == VUHDO_TARGET_TYPE_BAR and aLayerTemplate["useText"] then
		VUHDO_applyTextColorToBar(aTarget, tR, tG, tB);
	end

	return;

end



--
local tBarColor;
local tResultSlot;
local function VUHDO_applyDispelColorByIndex(aTarget, aTargetType, aLayerTemplate, aUnit, aResultIdx)

	tResultSlot = aLayerTemplate["dispelResults"][aResultIdx];

	if not tResultSlot then
		return;
	end

	if tResultSlot["barColor"] and tResultSlot["barColor"]["useBackground"] and aLayerTemplate["useBackground"] then
		tBarColor = tResultSlot["barColor"];

		VUHDO_applyRawColorToTarget(aTarget, aTargetType, tBarColor["R"], tBarColor["G"], tBarColor["B"], nil, aLayerTemplate);
	elseif tResultSlot["r"] and tResultSlot["useBackground"] ~= false and aLayerTemplate["useBackground"] then
		VUHDO_applyRawColorToTarget(aTarget, aTargetType, tResultSlot["r"], tResultSlot["g"], tResultSlot["b"], nil, aLayerTemplate);
	end

	if aTargetType == VUHDO_TARGET_TYPE_BAR and aLayerTemplate["useText"] then
		if tResultSlot["tr"] and tResultSlot["useText"] ~= false then
			VUHDO_applyTextColorToBar(aTarget, tResultSlot["tr"], tResultSlot["tg"], tResultSlot["tb"]);
		elseif tResultSlot["barColor"] and tResultSlot["barColor"]["useText"] then
			tBarColor = tResultSlot["barColor"];

			VUHDO_applyTextColorToBar(aTarget, tBarColor["TR"], tBarColor["TG"], tBarColor["TB"]);
		end
	end

	return;

end



--
local tEntry;
local tType;
local tResultIdx;
local tResult;
local function VUHDO_applySortedValidatorsToTarget(aButton, aTarget, aTargetType, aLayerTemplate)

	if not aLayerTemplate["sortedValidators"] then
		return;
	end

	sCurrentOpacity = 1;

	for tIdx = 1, #aLayerTemplate["sortedValidators"] do
		tEntry = aLayerTemplate["sortedValidators"][tIdx];
		tType = tEntry["type"];
		tResultIdx = tEntry["resultIdx"];

		if tType == VUHDO_BOUQUET_LAYER_TYPE_NONSECRET then
			tResult = aLayerTemplate["nonSecretResults"][tResultIdx];

			if tResult["isActive"] then
				VUHDO_applyNonSecretColorByIndex(aTarget, aTargetType, aLayerTemplate, tResultIdx);
			end
		elseif tType == VUHDO_BOUQUET_LAYER_TYPE_CURVE then
			VUHDO_applyCurveColorByIndex(aTarget, aTargetType, aLayerTemplate, tResultIdx);
		elseif tType == VUHDO_BOUQUET_LAYER_TYPE_DISPEL then
			tResult = aLayerTemplate["dispelResults"][tResultIdx];

			if tResult["isActive"] then
				VUHDO_applyDispelColorByIndex(aTarget, aTargetType, aLayerTemplate, aButton["raidid"], tResultIdx);
			end
		elseif tType == VUHDO_BOUQUET_LAYER_TYPE_AURA then
			tResult = aLayerTemplate["auraResults"][tResultIdx];

			if tResult["isActive"] then
				VUHDO_applyAuraColorByIndex(aTarget, aTargetType, aLayerTemplate, tResultIdx);
			end
		end
	end

	return;

end



--
function VUHDO_applyAllLayersToTexture(aButton, aTexture, aLayerTemplate)

	if not aButton or not aTexture or not aLayerTemplate then
		return;
	end

	VUHDO_applySortedValidatorsToTarget(aButton, aTexture, VUHDO_TARGET_TYPE_TEXTURE, aLayerTemplate);
	VUHDO_applyBooleanLayers(aButton, aTexture, VUHDO_TARGET_TYPE_TEXTURE, aLayerTemplate);
	VUHDO_applySpriteCellToTexture(aTexture, aLayerTemplate);

	return;

end



--
function VUHDO_applyAllLayersToBorder(aButton, aBorder, aLayerTemplate)

	if not aButton or not aBorder or not aLayerTemplate then
		return;
	end

	VUHDO_applySortedValidatorsToTarget(aButton, aBorder, VUHDO_TARGET_TYPE_BORDER, aLayerTemplate);
	VUHDO_applyBooleanLayers(aButton, aBorder, VUHDO_TARGET_TYPE_BORDER, aLayerTemplate);

	return;

end



--
local tGateIdx;
local tResultSlot;
local tValidatorEntry;
local tButtonName;
local tIndicatorEntry;
local tContainer;
local tGroupEntry;
local tBouquetIdx;
local tOverlay;
function VUHDO_applyOverlayBouquetGating(aButton, anIndicatorKey, aBouquetName, aLayerTemplate, aTargetBar)

	if not aButton or not anIndicatorKey or not aLayerTemplate or not VUHDO_isAuraDataRestricted() then
		return;
	end

	tButtonName = aButton:GetName();

	if not tButtonName or not VUHDO_OVERLAY_CONTAINERS[tButtonName] then
		return;
	end

	tGateIdx = 0;

	for tIdx = 1, #aLayerTemplate["nonSecretResults"] do
		tResultSlot = aLayerTemplate["nonSecretResults"][tIdx];

		if tResultSlot["isActive"] and tResultSlot["color"] and tResultSlot["color"]["useBackground"] then
			tValidatorEntry = aLayerTemplate["nonSecretValidators"][tIdx];

			if tValidatorEntry and tValidatorEntry["index"] then
				if tGateIdx <= 0 or tValidatorEntry["index"] < tGateIdx then
					tGateIdx = tValidatorEntry["index"];
				end
			end
		end
	end

	tIndicatorEntry = VUHDO_OVERLAY_CONTAINERS[tButtonName][anIndicatorKey];

	if tIndicatorEntry then
		for _, tContainerData in pairs(tIndicatorEntry) do
			tContainer = tContainerData and tContainerData["container"];
			tGroupEntry = tContainerData and tContainerData["containerTemplate"] and tContainerData["containerTemplate"]["groups"] and tContainerData["containerTemplate"]["groups"][1];
			tBouquetIdx = tGroupEntry and tGroupEntry["bouquetIdx"];

			if tContainer then
				if tGateIdx > 0 and tBouquetIdx and tBouquetIdx > tGateIdx then
					tContainer:Hide();
				else
					tContainer:Show();
				end
			end
		end
	end

	aTargetBar = aTargetBar or VUHDO_getHealthBar(aButton, VUHDO_INDICATOR_BAR_MAP[anIndicatorKey] or 1);

	for tIdx = 1, #aLayerTemplate["booleanResults"] do
		tValidatorEntry = aLayerTemplate["booleanValidators"][tIdx];

		if tGateIdx > 0 and tValidatorEntry and tValidatorEntry["index"] and tValidatorEntry["index"] > tGateIdx then
			tOverlay = VUHDO_getBooleanOverlay(aButton, aTargetBar, tValidatorEntry["item"]["name"], VUHDO_TARGET_TYPE_BAR);

			if tOverlay then
				VUHDO_clearBooleanOverlay(tOverlay);
			end
		end
	end

	return;

end



--
function VUHDO_applyAllLayersToBar(aButton, aBar, aLayerTemplate, anIndicatorKey, aBouquetName)

	if not aButton or not aBar or not aLayerTemplate then
		return;
	end

	if aBar["secretCurveColor"] then
		aBar["secretCurveColor"]["R"] = nil;
		aBar["secretCurveColor"]["G"] = nil;
		aBar["secretCurveColor"]["B"] = nil;
		aBar["secretCurveColor"]["O"] = nil;
	end

	VUHDO_applySortedValidatorsToTarget(aButton, aBar, VUHDO_TARGET_TYPE_BAR, aLayerTemplate);
	VUHDO_applyBooleanLayers(aButton, aBar, VUHDO_TARGET_TYPE_BAR, aLayerTemplate);
	VUHDO_applyBooleanTextLayers(aBar, aLayerTemplate);

	if anIndicatorKey then
		VUHDO_applyOverlayBouquetGating(aButton, anIndicatorKey, aBouquetName, aLayerTemplate, aBar);
	end

	return;

end