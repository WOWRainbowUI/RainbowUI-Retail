-- BURST CACHE ---------------------------------------------------
local VUHDO_PANEL_SETUP;
local VUHDO_getHeaderWidthHor;
local VUHDO_getHeaderWidthVer;
local VUHDO_getHeaderHeightHor;
local VUHDO_getHeaderHeightVer;
local VUHDO_getHeaderPosHor;
local VUHDO_getHeaderPosVer;
local VUHDO_getHealButtonPosHor;
local VUHDO_getHealButtonPosVer;
local VUHDO_strempty;
local VUHDO_splitString;
local strfind = strfind;
local abs = math.abs;

function VUHDO_sizeCalculatorInitLocalOverrides()
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_sizeCalculatorInitLocalOverridesHor();
	VUHDO_sizeCalculatorInitLocalOverridesVer();

	VUHDO_getHeaderWidthHor = _G["VUHDO_getHeaderWidthHor"];
	VUHDO_getHeaderWidthVer = _G["VUHDO_getHeaderWidthVer"];
	VUHDO_getHeaderHeightHor = _G["VUHDO_getHeaderHeightHor"];
	VUHDO_getHeaderHeightVer = _G["VUHDO_getHeaderHeightVer"];
	VUHDO_getHeaderPosHor = _G["VUHDO_getHeaderPosHor"];
	VUHDO_getHeaderPosVer = _G["VUHDO_getHeaderPosVer"];
	VUHDO_getHealButtonPosHor = _G["VUHDO_getHealButtonPosHor"];
	VUHDO_getHealButtonPosVer = _G["VUHDO_getHealButtonPosVer"];
	VUHDO_strempty = _G["VUHDO_strempty"];
	VUHDO_splitString = _G["VUHDO_splitString"];

	return;
end

-- BURST CACHE ---------------------------------------------------

local sHealButtonWidthCache = { };
local sTopHeightCache = { };
local sBottomHeightCache = { };
local sHotSlotsCache = { };
local sNamePositionCache = { };
local sPixelPerfectCache = { };


function VUHDO_resetSizeCalcCaches()
	table.wipe(sHealButtonWidthCache);
	table.wipe(sTopHeightCache);
	table.wipe(sBottomHeightCache);
	table.wipe(sHotSlotsCache);
	table.wipe(sNamePositionCache);
	table.wipe(sPixelPerfectCache);
	VUHDO_resetSizeCalcCachesHor();
	VUHDO_resetSizeCalcCachesVer();

	return;
end



--
function VUHDO_forceRefreshPixelPerfectCache()

	table.wipe(sPixelPerfectCache);
	VUHDO_refreshPixelScale();

	return;

end



--
local tCacheKey;
local tBarScaling;
local tValue;
function VUHDO_getPixelPerfectSpacing(aPanelNum, aSpacingType)

	tCacheKey = aPanelNum .. "_" .. aSpacingType;

	if not sPixelPerfectCache[tCacheKey] then
		tBarScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];
		tValue = tBarScaling[aSpacingType] or 0;

		if type(tValue) == "number" and tValue >= 0 then
			sPixelPerfectCache[tCacheKey] = VUHDO_PixelUtil.RoundToPixel(tValue);
		else
			sPixelPerfectCache[tCacheKey] = 0;
		end
	end

	return sPixelPerfectCache[tCacheKey];

end



--
local tCacheKey;
local tBarScaling;
local tValue;
function VUHDO_getPixelPerfectGap(aPanelNum, aGapType)

	tCacheKey = "gap_" .. aPanelNum .. "_" .. aGapType;

	if not sPixelPerfectCache[tCacheKey] then
		tBarScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];
		tValue = tBarScaling[aGapType] or 0;

		if type(tValue) == "number" and tValue >= 0 then
			sPixelPerfectCache[tCacheKey] = VUHDO_PixelUtil.RoundToPixel(tValue);
		else
			sPixelPerfectCache[tCacheKey] = 0;
		end
	end

	return sPixelPerfectCache[tCacheKey];

end



--
local tCacheKey;
local tBorder;
local tValue;
function VUHDO_getPixelPerfectBorderEdgeSize(aPanelNum)

	tCacheKey = "border_edge_" .. aPanelNum;
	if not sPixelPerfectCache[tCacheKey] then
		tBorder = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["BORDER"];
		tValue = tBorder["edgeSize"] or 0;
		sPixelPerfectCache[tCacheKey] = VUHDO_PixelUtil.RoundToPixel(tValue);
	end

	return sPixelPerfectCache[tCacheKey];

end



--
local tCacheKey;
local tBorder;
local tValue;
function VUHDO_getPixelPerfectBorderInsets(aPanelNum)

	tCacheKey = "border_insets_" .. aPanelNum;
	if not sPixelPerfectCache[tCacheKey] then
		tBorder = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["BORDER"];
		tValue = tBorder["insets"] or 0;
		sPixelPerfectCache[tCacheKey] = VUHDO_PixelUtil.RoundToPixel(tValue);
	end

	return sPixelPerfectCache[tCacheKey];

end



--
local tNamePos;
local tNameHeight;
function VUHDO_parseNamePosition(aPanelNum)

	if not sNamePositionCache[aPanelNum] then
		tNamePos = VUHDO_splitString(VUHDO_PANEL_SETUP[aPanelNum]["ID_TEXT"]["position"], "+");
		tNameHeight = VUHDO_PANEL_SETUP[aPanelNum]["ID_TEXT"]["_spacing"];

		sNamePositionCache[aPanelNum] = {
			["pos1"] = tNamePos[1],
			["pos2"] = tNamePos[2],
			["height"] = tNameHeight,
			["isBottomTop"] = strfind(tNamePos[1], "BOTTOM", 1, true) and strfind(tNamePos[2], "TOP", 1, true),
			["isTopBottom"] = strfind(tNamePos[1], "TOP", 1, true) and strfind(tNamePos[2], "BOTTOM", 1, true)
		};
	end

	return sNamePositionCache[aPanelNum];

end



-- Returns the total height of optional threat bars
local tTopSpace;
local tNamePos;
function VUHDO_getAdditionalTopHeight(aPanelNum)

	if not sTopHeightCache[aPanelNum] then
		tTopSpace = 0;

		if VUHDO_INDICATOR_CONFIG[aPanelNum]["BOUQUETS"]["THREAT_BAR"] ~= "" then
			tTopSpace = VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["THREAT_BAR"]["HEIGHT"];
		end

		tNamePos = VUHDO_parseNamePosition(aPanelNum);

		if tNamePos["isBottomTop"] and tNamePos["height"] and tNamePos["height"] > tTopSpace then
			tTopSpace = tNamePos["height"];
		end

		sTopHeightCache[aPanelNum] = tTopSpace;
	end

	return sTopHeightCache[aPanelNum];

end



--
local tHotCfg;
local tBottomSpace;
local tNamePos;
function VUHDO_getAdditionalBottomHeight(aPanelNum)

	if not sBottomHeightCache[aPanelNum] then
		-- HoT icons
		tHotCfg = VUHDO_PANEL_SETUP[aPanelNum]["HOTS"];
		tBottomSpace = 0;

		if tHotCfg["radioValue"] == 7 or tHotCfg["radioValue"] == 8 then
			tBottomSpace = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["barHeight"] * VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["size"] * 0.01;
		end

		tNamePos = VUHDO_parseNamePosition(aPanelNum);

		if tNamePos["isTopBottom"] and tNamePos["height"] and tNamePos["height"] > tBottomSpace then
			tBottomSpace = tNamePos["height"];
		end

		sBottomHeightCache[aPanelNum] = tBottomSpace;
	end

	return sBottomHeightCache[aPanelNum];

end



--
local tBarScaling;
local tTargetWidth;
local function VUHDO_getTargetBarWidth(aPanelNum)

	tBarScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];

	tTargetWidth = 0;

	if tBarScaling["showTarget"] then
		tTargetWidth = tTargetWidth + tBarScaling["targetSpacing"] + tBarScaling["targetWidth"];
	end

	if tBarScaling["showTot"] then
		tTargetWidth = tTargetWidth + tBarScaling["totSpacing"] + tBarScaling["totWidth"];
	end

	return tTargetWidth;

end



--
local tSlots;
function VUHDO_getNumHotSlots(aPanelNum)

	if not sHotSlotsCache[aPanelNum] then
		tSlots = VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["SLOTS"];

		if not VUHDO_strempty(tSlots[12]) then
			sHotSlotsCache[aPanelNum] = 9;
		elseif not VUHDO_strempty(tSlots[11]) then
			sHotSlotsCache[aPanelNum] = 8;
		elseif not VUHDO_strempty(tSlots[10]) then
			sHotSlotsCache[aPanelNum] = 7;
		elseif not VUHDO_strempty(tSlots[9]) then
			sHotSlotsCache[aPanelNum] = 6;
		else
			for tCnt = 5, 1, -1 do
				if not VUHDO_strempty(tSlots[tCnt]) then
					sHotSlotsCache[aPanelNum] = tCnt;

					break;
				end
			end

			if not sHotSlotsCache[aPanelNum] then
				sHotSlotsCache[aPanelNum] = 0;
			end
		end
	end

	return sHotSlotsCache[aPanelNum];

end



--
local tHotCfg;
local function VUHDO_getHotIconWidth(aPanelNum)

	tHotCfg = VUHDO_PANEL_SETUP[aPanelNum]["HOTS"];

	if tHotCfg["radioValue"] == 1 or tHotCfg["radioValue"] == 4 then
		return VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["barHeight"]
			* VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["size"]
			* VUHDO_getNumHotSlots(aPanelNum) * 0.01;
	else
		return 0;
	end

end



--
function VUHDO_getHealButtonWidth(aPanelNum)
	if not sHealButtonWidthCache[aPanelNum] then
		sHealButtonWidthCache[aPanelNum] =
			VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["barWidth"]
			+ VUHDO_getTargetBarWidth(aPanelNum)
			+ VUHDO_getHotIconWidth(aPanelNum);
	end
	return sHealButtonWidthCache[aPanelNum];
end



--
local function VUHDO_isPanelHorizontal(aPanelNum)
	return VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["arrangeHorizontal"]
		and (not VUHDO_IS_PANEL_CONFIG or VUHDO_CONFIG_SHOW_RAID);
end



-- Returns total header width
function VUHDO_getHeaderWidth(aPanelNum)
	return VUHDO_isPanelHorizontal(aPanelNum)
		and VUHDO_getHeaderWidthHor(aPanelNum) or VUHDO_getHeaderWidthVer(aPanelNum);
end



-- Returns total header height
function VUHDO_getHeaderHeight(aPanelNum)

	return VUHDO_isPanelHorizontal(aPanelNum) and VUHDO_getHeaderHeightHor(aPanelNum) or VUHDO_getHeaderHeightVer(aPanelNum);

end



--
function VUHDO_getHeaderPos(aHeaderPlace, aPanelNum)

	if VUHDO_CONFIG and VUHDO_CONFIG["PIXEL_PERFECT"] and VUHDO_CONFIG["PIXEL_PERFECT"]["autoRefresh"] then
		VUHDO_ensurePixelPerfectSpacing(aPanelNum);
	end

	if VUHDO_isPanelHorizontal(aPanelNum) then
		return VUHDO_getHeaderPosHor(aHeaderPlace, aPanelNum);
	else
		return VUHDO_getHeaderPosVer(aHeaderPlace, aPanelNum);
	end

end



--
function VUHDO_getHealButtonPos(aPlaceNum, aRowNo, aPanelNum)

	-- Achtung: Positionen nicht cachen, da z.T. von dynamischen Models abhngig

	if VUHDO_CONFIG and VUHDO_CONFIG["PIXEL_PERFECT"] and VUHDO_CONFIG["PIXEL_PERFECT"]["autoRefresh"] then
		VUHDO_ensurePixelPerfectSpacing(aPanelNum);
	end

	if VUHDO_isPanelHorizontal(aPanelNum) then
		return VUHDO_getHealButtonPosHor(aPlaceNum, aRowNo, aPanelNum);
	else
		return VUHDO_getHealButtonPosVer(aPlaceNum, aRowNo, aPanelNum);
	end

end



--
function VUHDO_getHealPanelWidth(aPanelNum)

	if VUHDO_CONFIG and VUHDO_CONFIG["PIXEL_PERFECT"] and VUHDO_CONFIG["PIXEL_PERFECT"]["autoRefresh"] then
		VUHDO_ensurePixelPerfectSpacing(aPanelNum);
	end

	return VUHDO_isPanelHorizontal(aPanelNum) and VUHDO_getHealPanelWidthHor(aPanelNum) or VUHDO_getHealPanelWidthVer(aPanelNum);

end



--
local tHeight;
function VUHDO_getHealPanelHeight(aPanelNum)

	if VUHDO_CONFIG and VUHDO_CONFIG["PIXEL_PERFECT"] and VUHDO_CONFIG["PIXEL_PERFECT"]["autoRefresh"] then
		VUHDO_ensurePixelPerfectSpacing(aPanelNum);
	end

	tHeight = VUHDO_isPanelHorizontal(aPanelNum) and VUHDO_getHealPanelHeightHor(aPanelNum) or VUHDO_getHealPanelHeightVer(aPanelNum);

	return tHeight >= 20 and tHeight or 20;

end



--
local tSpacingKeys = { "rowSpacing", "columnSpacing", "borderGapX", "borderGapY", "headerSpacing" };
local tBorderKeys = { "edgeSize", "insets" };
local tScaling;
local tScale;
local tUIUnitFactor;
local tFixed;
local tValue;
local tCurrentRendered;
local tTargetRendered;
local tNewConfigValue;
local tBorder;
function VUHDO_ensurePixelPerfectSpacing(aPanelNum)

	if not VUHDO_PANEL_SETUP or not VUHDO_PANEL_SETUP[aPanelNum] then
		return;
	end

	tScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];
	tScale = VUHDO_getPixelScale();
	tUIUnitFactor = VUHDO_getPixelToUIUnitFactor();

	tFixed = false;

	for _, tKey in ipairs(tSpacingKeys) do
		tValue = tScaling[tKey] or 0;

		if type(tValue) == "number" and tValue >= 0 then
			tCurrentRendered = (tValue * tScale) / tUIUnitFactor;
			tTargetRendered = floor(tCurrentRendered + 0.5);
			tNewConfigValue = tTargetRendered * tUIUnitFactor / tScale;

			if abs(tNewConfigValue - tValue) < 0.000001 then
				tNewConfigValue = tValue;
			end

			if tNewConfigValue ~= tValue then
				tScaling[tKey] = tNewConfigValue;

				tFixed = true;
			end
		else
			tScaling[tKey] = 0;

			tFixed = true;
		end
	end

	tBorder = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["BORDER"];

	for _, tKey in ipairs(tBorderKeys) do
		tValue = tBorder[tKey] or 0;

		if type(tValue) == "number" and tValue >= 0 then
			tCurrentRendered = (tValue * tScale) / tUIUnitFactor;
			tTargetRendered = floor(tCurrentRendered + 0.5);
			tNewConfigValue = tTargetRendered * tUIUnitFactor / tScale;

			if abs(tNewConfigValue - tValue) < 0.000001 then
				tNewConfigValue = tValue;
			end

			if tNewConfigValue ~= tValue then
				tBorder[tKey] = tNewConfigValue;

				tFixed = true;
			end
		else
			tBorder[tKey] = 0;

			tFixed = true;
		end
	end

	if tFixed then
		VUHDO_forceRefreshPixelPerfectCache();
	end

	return;

end