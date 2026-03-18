local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local twipe = table.wipe;

local CreateFrame = CreateFrame;

local VUHDO_META_NEW_ARRAY = VUHDO_META_NEW_ARRAY;
local VUHDO_BOUQUET_BUFFS_SPECIAL;
local VUHDO_BOUQUETS;
local VUHDO_INDICATOR_CONFIG;
local VUHDO_SECRET_TYPE_NONE;
local VUHDO_SECRET_TYPE_BOOLEAN;

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

local VUHDO_getHealthBar;
local VUHDO_getBarText;
local VUHDO_getBarTextSolo;
local VUHDO_getLifeText;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;

local sBooleanOverlayLayers = { };
setmetatable(sBooleanOverlayLayers, VUHDO_META_NEW_ARRAY);

local sGlobalAlphaChains = { };
setmetatable(sGlobalAlphaChains, VUHDO_META_NEW_ARRAY);

local sAlphaChainPool;
local sAlphaChainStepEntryPool;

local sWrapperNameCounter = 0;

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
	VUHDO_SECRET_TYPE_NONE = _G["VUHDO_SECRET_TYPE_NONE"];
	VUHDO_SECRET_TYPE_BOOLEAN = _G["VUHDO_SECRET_TYPE_BOOLEAN"];

	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getBarText = _G["VUHDO_getBarText"];
	VUHDO_getBarTextSolo = _G["VUHDO_getBarTextSolo"];
	VUHDO_getLifeText = _G["VUHDO_getLifeText"];

	sAlphaChainStepEntryPool = VUHDO_createTablePool("AlphaChainStepEntry", 100);
	sAlphaChainPool = VUHDO_createTablePool("AlphaChain", 50, VUHDO_createAlphaChainDelegate, VUHDO_cleanupAlphaChainDelegate);

	return;

end



--
local tOverlay;
local tOverlayText;
local tBarText;
function VUHDO_getOrCreateBooleanOverlay(aButton, aValidatorName, aHealthBar)

	if sBooleanOverlayLayers[aButton][aValidatorName] then
		return sBooleanOverlayLayers[aButton][aValidatorName];
	end

	tOverlay = aButton:CreateTexture(nil, "OVERLAY");

	tOverlay:SetAllPoints(aHealthBar);
	tOverlay:SetTexture("Interface\\Buttons\\WHITE8X8");
	tOverlay:SetAlpha(0);

	tBarText = VUHDO_getBarText(aHealthBar);

	if tBarText then
		tOverlayText = aButton:CreateFontString(nil, "OVERLAY");

		tOverlayText:SetAllPoints(tBarText);
		tOverlayText:SetFontObject(tBarText:GetFontObject());
		tOverlayText:SetAlpha(0);
	else
		tOverlayText = nil;
	end

	sBooleanOverlayLayers[aButton][aValidatorName] = {
		["texture"] = tOverlay,
		["fontString"] = tOverlayText,
	};

	return sBooleanOverlayLayers[aButton][aValidatorName];

end



--
local tTexture;
local tFontString;
function VUHDO_applyBooleanOverlay(aOverlay, aSecretBool, aConfig, aTrueColor, aFalseColor)

	tTexture = aOverlay["texture"];
	tFontString = aOverlay["fontString"];

	if aConfig["useBackground"] then
		tTexture:SetVertexColorFromBoolean(aSecretBool, aTrueColor, aFalseColor);
	end

	if aConfig["useOpacity"] then
		tTexture:SetAlphaFromBoolean(aSecretBool, aConfig["O"] or 1, 0);
	else
		tTexture:SetAlphaFromBoolean(aSecretBool, 1, 0);
	end

	if aConfig["useText"] and tFontString then
		tFontString:SetVertexColorFromBoolean(aSecretBool, aTrueColor, aFalseColor);
		tFontString:SetAlphaFromBoolean(aSecretBool, aConfig["TO"] or 1, 0);
	end

	return;

end



--
function VUHDO_clearBooleanOverlays(aButton)

	for _, tOverlay in pairs(sBooleanOverlayLayers[aButton]) do
		tOverlay["texture"]:SetAlpha(0);

		if tOverlay["fontString"] then
			tOverlay["fontString"]:SetAlpha(0);
		end
	end

	return;

end



--
local tItem;
local tSpecial;
local tWrapper;
local tChain;
local tParent;
local tSecretType;
local tIndicatorBar;
local tOriginalParent;
local tBarIndex;
local tFrameGetter;
local tIndicatorAddLevel;
local tEntry;
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

	tIndicatorAddLevel = tIndicatorBar["addLevel"] or 0;

	if sGlobalAlphaChains[aButton] and sGlobalAlphaChains[aButton][anIndicatorName] then
		tChain = sGlobalAlphaChains[aButton][anIndicatorName];

		tOriginalParent = tChain["originalParent"];

		if tOriginalParent then
			tIndicatorBar:SetParent(tOriginalParent);

			tIndicatorBar["vuhdo_parent"] = nil;
		end

		for _, tStep in ipairs(tChain["steps"] or { }) do
			if tStep["frame"] then
				tStep["frame"]:Hide();
				tStep["frame"]:ClearAllPoints();
				tStep["frame"]:SetParent(nil);
			end
		end

		sAlphaChainPool:release(tChain);
		sGlobalAlphaChains[aButton][anIndicatorName] = nil;
	else
		tOriginalParent = tIndicatorBar:GetParent();
	end

	if not sGlobalAlphaChains[aButton] then
		sGlobalAlphaChains[aButton] = { };
	end

	tChain = sAlphaChainPool:get();

	tChain["originalParent"] = tOriginalParent;
	tChain["barIndex"] = tBarIndex;

	sGlobalAlphaChains[aButton][anIndicatorName] = tChain;

	for tCnt = 1, #aBouquet do
		tItem = aBouquet[tCnt];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]];

		if tSpecial and tSpecial["isGlobal"] and tItem["color"] and tItem["color"]["useOpacity"] and not tItem["color"]["useBackground"] then
			tSecretType = tSpecial["secretType"] or VUHDO_SECRET_TYPE_NONE;

			if tSecretType == VUHDO_SECRET_TYPE_BOOLEAN then
				sWrapperNameCounter = sWrapperNameCounter + 1;

				tWrapper = CreateFrame("Frame", tOriginalParent:GetName() .. "AlpWr" .. sWrapperNameCounter, tOriginalParent);

				tWrapper:SetAllPoints(tOriginalParent);

				tWrapper["addLevel"] = tIndicatorAddLevel;
				tWrapper:SetFrameLevel(tOriginalParent:GetFrameLevel());

				tWrapper:SetAlpha(1);
				tWrapper:Show();

				tEntry = sAlphaChainStepEntryPool:get();

				tEntry["frame"] = tWrapper;
				tEntry["item"] = tItem;
				tEntry["special"] = tSpecial;
				tEntry["index"] = tCnt;
				tEntry["trueAlpha"] = tSpecial["isInverted"] and 1 or (tItem["color"]["O"] or 1);
				tEntry["falseAlpha"] = tSpecial["isInverted"] and (tItem["color"]["O"] or 1) or 1;

				tinsert(tChain["steps"], tEntry);
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

	for tCnt = 1, #aBouquet do
		tItem = aBouquet[tCnt];
		tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]];

		if tSpecial and tSpecial["isGlobal"] and tItem["color"] and tItem["color"]["useBackground"] then
			tEntry = sAlphaChainStepEntryPool:get();

			tEntry["item"] = tItem;
			tEntry["special"] = tSpecial;
			tEntry["index"] = tCnt;

			tinsert(tChain["overrideValidators"], tEntry);
		end
	end

	if #tChain["steps"] > 0 then
		tChain["head"] = tChain["steps"][1]["frame"];

		tParent = tOriginalParent;

		for tIdx = 1, #tChain["steps"] do
			tWrapper = tChain["steps"][tIdx]["frame"];

			tWrapper:SetParent(tParent);
			tWrapper:ClearAllPoints();
			tWrapper:SetAllPoints(tParent);
			tWrapper:SetFrameLevel(tParent:GetFrameLevel());

			tParent = tWrapper;
		end

		tChain["tail"] = tChain["steps"][#tChain["steps"]]["frame"];

		tIndicatorBar:SetParent(tChain["tail"]);

		tIndicatorBar["vuhdo_parent"] = tOriginalParent;
	else
		tChain["tail"] = tOriginalParent;
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
		return;
	end

	tIndicatorConfig = VUHDO_INDICATOR_CONFIG[aPanelNum];

	if not tIndicatorConfig then
		return;
	end

	for tIndicatorName, _ in pairs(VUHDO_INDICATOR_BAR_MAP) do
		tBouquetName = tIndicatorConfig["BOUQUETS"][tIndicatorName];
		tBouquet = tBouquetName and tBouquetName ~= "" and VUHDO_BOUQUETS["STORED"][tBouquetName];

		if tBouquet then
			VUHDO_buildGlobalAlphaChainsForIndicator(aButton, tIndicatorName, tBouquet, aPanelNum);
		end
	end

	for tIndicatorName, _ in pairs(VUHDO_INDICATOR_FRAME_GETTERS) do
		tBouquetName = tIndicatorConfig["BOUQUETS"][tIndicatorName];
		tBouquet = tBouquetName and tBouquetName ~= "" and VUHDO_BOUQUETS["STORED"][tBouquetName];

		if tBouquet then
			VUHDO_buildGlobalAlphaChainsForIndicator(aButton, tIndicatorName, tBouquet, aPanelNum);
		end
	end

	return;

end



--
local tChain;
local tStep;
local tSecretBool;
local tNonSecretAlpha;
local tIsActive;
local tIndicatorBar;
local tFrameGetter;
local tMinOverrideIndex;
local tOverride;
function VUHDO_updateIndicatorAlphaChain(aButton, anIndicatorName, anInfo)

	if not anInfo then
		return;
	end

	if not sGlobalAlphaChains[aButton] then
		return;
	end

	tChain = sGlobalAlphaChains[aButton][anIndicatorName];

	if not tChain then
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

		if tMinOverrideIndex and tStep["index"] > tMinOverrideIndex then
			tStep["frame"]:SetAlpha(1);
		else
			tIsActive, _, _, _, _, _, _, _, _, _, _, tSecretBool = tStep["special"]["validator"](anInfo, tStep["item"]);

			if tSecretBool ~= nil then
				tStep["frame"]:SetAlphaFromBoolean(tSecretBool, tStep["trueAlpha"], tStep["falseAlpha"]);
			else
				tStep["frame"]:SetAlpha(tIsActive and tStep["falseAlpha"] or tStep["trueAlpha"]);
			end
		end
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
		for tIndicatorName, tChain in pairs(tIndicatorChains) do
			if tChain["steps"] then
				for _, tStep in ipairs(tChain["steps"]) do
					if tStep["frame"] then
						tStep["frame"]:Hide();
						tStep["frame"]:SetParent(nil);
					end
				end
			end

			sAlphaChainPool:release(tChain);
		end
	end

	twipe(sGlobalAlphaChains);

	return;

end



--
local tResultSlot;
local tOverlay;
local function VUHDO_applyBooleanLayers(aButton, aTarget, aLayerTemplate)

	if not aLayerTemplate["hasBools"] then
		return;
	end

	for tIdx = 1, #aLayerTemplate["booleanResults"] do
		tResultSlot = aLayerTemplate["booleanResults"][tIdx];

		if tResultSlot["color"] and
		   (tResultSlot["color"]["useBackground"] or tResultSlot["color"]["useText"]) then
			tOverlay = VUHDO_getOrCreateBooleanOverlay(aButton,
				aLayerTemplate["booleanValidators"][tIdx]["item"]["name"], aTarget);

			if tOverlay and tResultSlot["trueColorMixin"] and tResultSlot["falseColorMixin"] and tResultSlot["secretBool"] ~= nil then
				VUHDO_applyBooleanOverlay(tOverlay, tResultSlot["secretBool"],
					tResultSlot["color"], tResultSlot["trueColorMixin"], tResultSlot["falseColorMixin"]);
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

	tO = aColor["O"] or 1;

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
	else
		tEffectiveAlpha = sCurrentOpacity;
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
local tBarText;
local tBarTextSolo;
local tLifeText;
local function VUHDO_applyTextColorToBar(aBar, aR, aG, aB)

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
local function VUHDO_applyNonSecretColorByIndex(aTarget, aTargetType, aLayerTemplate, aResultIdx)

	tResultSlot = aLayerTemplate["nonSecretResults"][aResultIdx];

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

	if not tResultSlot or not tResultSlot["r"] then
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

		if tType == "nonsecret" then
			tResult = aLayerTemplate["nonSecretResults"][tResultIdx];

			if tResult["isActive"] then
				VUHDO_applyNonSecretColorByIndex(aTarget, aTargetType, aLayerTemplate, tResultIdx);
			end
		elseif tType == "curve" then
			VUHDO_applyCurveColorByIndex(aTarget, aTargetType, aLayerTemplate, tResultIdx);
		elseif tType == "dispel" then
			tResult = aLayerTemplate["dispelResults"][tResultIdx];

			if tResult["isActive"] then
				VUHDO_applyDispelColorByIndex(aTarget, aTargetType, aLayerTemplate, aButton["raidid"], tResultIdx);
			end
		elseif tType == "aura" then
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
	VUHDO_applyBooleanLayers(aButton, aTexture, aLayerTemplate);
	VUHDO_applySpriteCellToTexture(aTexture, aLayerTemplate);

	return;

end



--
function VUHDO_applyAllLayersToBorder(aButton, aBorder, aLayerTemplate)

	if not aButton or not aBorder or not aLayerTemplate then
		return;
	end

	VUHDO_applySortedValidatorsToTarget(aButton, aBorder, VUHDO_TARGET_TYPE_BORDER, aLayerTemplate);
	VUHDO_applyBooleanLayers(aButton, aBorder, aLayerTemplate);

	return;

end



--
function VUHDO_applyAllLayersToBar(aButton, aBar, aLayerTemplate)

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
	VUHDO_applyBooleanLayers(aButton, aBar, aLayerTemplate);

	return;

end