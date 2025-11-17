local _;

local floor = math.floor;
local abs = math.abs;
local pairs = pairs;
local type = type;
local string = string;
local format = string.format;
local ipairs = ipairs;
local tinsert = table.insert;

local tPixelUtil = { };
local sPixelScale;
local sUIScale;
local sLastKnownScale = nil;
local sBackdropCache = { };
local sInsetsCache = { };
local sPixelToUIUnitFactor = nil;



--
local tPhysicalHeight;
function VUHDO_getPixelToUIUnitFactor()

	if not sPixelToUIUnitFactor then
		_, tPhysicalHeight = GetPhysicalScreenSize();

		if tPhysicalHeight and tPhysicalHeight > 0 then
			sPixelToUIUnitFactor = 768.0 / tPhysicalHeight;
		else
			sPixelToUIUnitFactor = 1.0;
		end
	end

	return sPixelToUIUnitFactor;

end



--
function VUHDO_getPixelScale()

	if not sPixelScale then
		sPixelScale = UIParent:GetEffectiveScale();
	end

	return sPixelScale;

end



--
function VUHDO_getUIScale()

	if not sUIScale then
		sUIScale = UIParent:GetScale();
	end

	return sUIScale;

end



--
local tScale;
local tUIUnitFactor;
local tPixelValue;
local tNumPixels;
local tResult;
local function VUHDO_roundToPixel(aValue, aScale, aMinPixels)

	if aValue == 0 and (not aMinPixels or aMinPixels == 0) then
		return 0;
	end

	tScale = aScale or VUHDO_getPixelScale();
	tUIUnitFactor = VUHDO_getPixelToUIUnitFactor();

	tPixelValue = (aValue * tScale) / tUIUnitFactor;
	tNumPixels = floor(tPixelValue + 0.5);

	if aValue > 0 and tNumPixels < 0 then
		tNumPixels = 0;
	elseif aValue < 0 and tNumPixels > 0 then
		tNumPixels = 0;
	end

	if aMinPixels then
		if aValue < 0.0 then
			if tNumPixels > -aMinPixels then
				tNumPixels = -aMinPixels;
			end
		else
			if tNumPixels < aMinPixels then
				tNumPixels = aMinPixels;
			end
		end
	end

	tResult = tNumPixels * tUIUnitFactor / tScale;

	if abs(tResult - aValue) < 0.000001 then
		return aValue;
	else
		return tResult;
	end

end



--
function VUHDO_refreshPixelScale()

	sPixelScale = nil;
	sUIScale = nil;
	sPixelToUIUnitFactor = nil;

	return;

end



--
function VUHDO_initScaleMonitoring()

	if VUHDO_CONFIG and VUHDO_CONFIG["PIXEL_PERFECT"] and VUHDO_CONFIG["PIXEL_PERFECT"]["enabled"] then
		sLastKnownScale = UIParent:GetEffectiveScale();

		if VUHDO_CONFIG["PIXEL_PERFECT"]["logScaleChanges"] then
			VUHDO_Msg("Pixel-perfect scale monitoring initialized. Current scale: " .. sLastKnownScale);
		end
	end

	return;

end



--
local tCurrentScale;
local tDelay;
function VUHDO_handleScaleChange()

	tCurrentScale = UIParent:GetEffectiveScale();

	VUHDO_refreshPixelScale();

	if VUHDO_CONFIG and VUHDO_CONFIG["PIXEL_PERFECT"] and VUHDO_CONFIG["PIXEL_PERFECT"]["redrawOnScaleChange"] then
		if not InCombatLockdown() then
			tDelay = VUHDO_CONFIG["PIXEL_PERFECT"]["scaleChangeDelay"] or 0.1;

			for tPanelNum = 1, 10 do
				VUHDO_timeRedrawPanel(tPanelNum, tDelay);
			end
		end
	end

	sLastKnownScale = tCurrentScale;

	return;

end



--
local tX;
local tY;
local tFrameScale;
function tPixelUtil.SetPoint(aFrame, aPoint, aRelativeFrame, aRelativePoint, aXOffset, aYOffset)

	if not aFrame then
		return;
	end

	tFrameScale = aFrame:GetEffectiveScale();
	tX = aXOffset and VUHDO_roundToPixel(aXOffset, tFrameScale) or 0;
	tY = aYOffset and VUHDO_roundToPixel(aYOffset, tFrameScale) or 0;

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:SetPoint(aPoint, aRelativeFrame, aRelativePoint, tX, tY);
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.SetPoint blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
local tWidth;
local tHeight;
local tFrameScale;
function tPixelUtil.SetSize(aFrame, aWidth, aHeight)

	if not aFrame then
		return;
	end

	tFrameScale = aFrame:GetEffectiveScale();
	tWidth = aWidth and VUHDO_roundToPixel(aWidth, tFrameScale) or aFrame:GetWidth();
	tHeight = aHeight and VUHDO_roundToPixel(aHeight, tFrameScale) or aFrame:GetHeight();

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:SetSize(tWidth, tHeight);
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.SetSize blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
local tWidth;
local tFrameScale;
function tPixelUtil.SetWidth(aFrame, aWidth)

	if not aFrame then
		return;
	end

	tFrameScale = aFrame:GetEffectiveScale();
	tWidth = aWidth and VUHDO_roundToPixel(aWidth, tFrameScale) or aFrame:GetWidth();

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:SetWidth(tWidth);
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.SetWidth blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
local tHeight;
local tFrameScale;
function tPixelUtil.SetHeight(aFrame, aHeight)

	if not aFrame then
		return;
	end

	tFrameScale = aFrame:GetEffectiveScale();
	tHeight = aHeight and VUHDO_roundToPixel(aHeight, tFrameScale) or aFrame:GetHeight();

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:SetHeight(tHeight);
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.SetHeight blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.ApplySettings(aTexture)

	if not aTexture then
		return;
	end

	aTexture:SetTexelSnappingBias(0);
	aTexture:SetSnapToPixelGrid(false);

	return;

end



--
local tCacheKey;
local tBackdrop;
local tInsets;
local tInsetsKey;
local tCurrentScale;
function tPixelUtil.ApplyBackdrop(aFrame, aBackdropInfo)

	if not aFrame or not aFrame.SetBackdrop then
		return;
	end

	if aBackdropInfo then
		tCurrentScale = VUHDO_getPixelScale();
		tCacheKey = "scale:" .. tCurrentScale .. ";";

		for tKey, tValue in pairs(aBackdropInfo) do
			if tKey == "insets" and type(tValue) == "table" then
				tCacheKey = tCacheKey .. tKey .. ":" .. (tValue["left"] or 0) .. "," .. (tValue["right"] or 0) .. "," .. (tValue["top"] or 0) .. "," .. (tValue["bottom"] or 0) .. ";";
			else
				tCacheKey = tCacheKey .. tKey .. ":" .. tostring(tValue) .. ";";
			end
		end

		if not sBackdropCache[tCacheKey] then
			tBackdrop = { };

			for tKey, tValue in pairs(aBackdropInfo) do
				if tKey == "edgeSize" then
					tBackdrop["edgeSize"] = VUHDO_roundToPixel(tValue);
				elseif tKey == "insets" and type(tValue) == "table" then
					tInsetsKey = tCurrentScale .. ":" .. (tValue["left"] or 0) .. "," .. (tValue["right"] or 0) .. "," .. (tValue["top"] or 0) .. "," .. (tValue["bottom"] or 0);

					if not sInsetsCache[tInsetsKey] then
						tInsets = { };

						tInsets["left"] = VUHDO_roundToPixel(tValue["left"] or 0);
						tInsets["right"] = VUHDO_roundToPixel(tValue["right"] or 0);
						tInsets["top"] = VUHDO_roundToPixel(tValue["top"] or 0);
						tInsets["bottom"] = VUHDO_roundToPixel(tValue["bottom"] or 0);

						sInsetsCache[tInsetsKey] = tInsets;
					end

					tBackdrop["insets"] = sInsetsCache[tInsetsKey];
				else
					tBackdrop[tKey] = tValue;
				end
			end

			sBackdropCache[tCacheKey] = tBackdrop;
		end

		aFrame:SetBackdrop(sBackdropCache[tCacheKey]);
	end

	return;

end



--
function tPixelUtil.ClearAllPoints(aFrame)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:ClearAllPoints();
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.ClearAllPoints blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.Show(aFrame)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:Show();
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.Show blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.Hide(aFrame)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:Hide();
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.Hide blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.SetScale(aFrame, aScale)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:SetScale(aScale);
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.SetScale blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.EnableMouseWheel(aFrame, aEnable)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:EnableMouseWheel(aEnable);
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.EnableMouseWheel blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.SetFrameStrata(aFrame, aStrata)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:SetFrameStrata(aStrata);
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.SetFrameStrata blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.EnableMouse(aFrame, aEnable)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:EnableMouse(aEnable);
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.EnableMouse blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.StopMovingOrSizing(aFrame)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:StopMovingOrSizing();
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.StopMovingOrSizing blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.SetFrameLevel(aFrame, aLevel)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:SetFrameLevel(aLevel);
	else
		VUHDO_Msg("WARNING: VUHDO_PixelUtil.SetFrameLevel blocked during combat for frame: " .. tostring(aFrame:GetName() or "unnamed") .. " Stack:\n" .. debugstack(2, 5, 5));
	end

	return;

end



--
function tPixelUtil.RoundToPixel(aValue)

	return VUHDO_roundToPixel(aValue);

end



--
local tBaseValue;
local tPercentage;
local tCalculated;
function tPixelUtil.SetSizeFromPercentage(aFrame, aBaseWidth, aBaseHeight, aWidthPercent, aHeightPercent)

	if not aFrame then
		return;
	end

	tBaseValue = aBaseWidth or 0;
	tPercentage = (aWidthPercent or 100) * 0.01;
	tCalculated = tBaseValue * tPercentage;

	tPixelUtil.SetWidth(aFrame, tCalculated);

	tBaseValue = aBaseHeight or 0;
	tPercentage = (aHeightPercent or 100) * 0.01;
	tCalculated = tBaseValue * tPercentage;

	tPixelUtil.SetHeight(aFrame, tCalculated);

	return;

end



VUHDO_PixelUtil = tPixelUtil;



--
local tNumFrames;
local tFrameSize;
local tSpacing;
local tTestFrames = { };
local tXOffset;
function VUHDO_pixelTest()

	VUHDO_Msg("|cffFFD100--- Pixel-Perfect Testing ---|r");

	VUHDO_Msg("|cffFFA500** Current Settings:|r");
	VUHDO_Msg("  |cffB0E0E6UI Scale:|r " .. (UIParent:GetScale() or 1));
	VUHDO_Msg("  |cffB0E0E6Pixel Scale:|r " .. VUHDO_getPixelScale());

	VUHDO_Msg("|cffFFA500** Refresh Test:|r");
	VUHDO_Msg("  Refreshing pixel scale...");
	VUHDO_refreshPixelScale();
	VUHDO_Msg("  |cffB0E0E6New Pixel Scale:|r " .. VUHDO_getPixelScale());

	VUHDO_Msg("|cffFFA500** Visual Test Frames:|r");
	VUHDO_Msg("  Creating pixel-perfect test frames...");

	tNumFrames = 5;
	tFrameSize = 96;
	tSpacing = 2;

	for tIndex = 1, tNumFrames do
		if not tTestFrames[tIndex] then
			tTestFrames[tIndex] = CreateFrame("Frame", "VuhDoPixelTestFrame" .. tIndex, UIParent, "BackdropTemplate");

			VUHDO_PixelUtil.SetFrameStrata(tTestFrames[tIndex], "HIGH");
			tTestFrames[tIndex]:SetMovable(true);
			VUHDO_PixelUtil.EnableMouse(tTestFrames[tIndex], true);
			tTestFrames[tIndex]:RegisterForDrag("LeftButton");

			tTestFrames[tIndex]:SetScript("OnDragStart", tTestFrames[tIndex].StartMoving);
			tTestFrames[tIndex]:SetScript("OnDragStop", tTestFrames[tIndex].StopMovingOrSizing);
		end

		tXOffset = (tIndex - 1) * (tFrameSize + tSpacing);

		VUHDO_PixelUtil.SetPoint(tTestFrames[tIndex], "CENTER", UIParent, "CENTER", tXOffset - ((tNumFrames - 1) * (tFrameSize + tSpacing)) / 2, 0);
		VUHDO_PixelUtil.SetSize(tTestFrames[tIndex], tFrameSize, tFrameSize);

		VUHDO_PixelUtil.ApplyBackdrop(tTestFrames[tIndex], {
			["bgFile"] = "Interface\\Buttons\\WHITE8x8",
			["edgeFile"] = "Interface\\Buttons\\WHITE8x8",
			["tile"] = true,
			["tileSize"] = 8,
			["edgeSize"] = 2,
			["insets"] = { ["left"] = 0, ["right"] = 0, ["top"] = 0, ["bottom"] = 0 }
		});

		tTestFrames[tIndex]:SetBackdropColor(0, 0, 0, 1); -- black background
		tTestFrames[tIndex]:SetBackdropBorderColor(0.5, 0.5, 0.5, 1); -- grey border

		tTestFrames[tIndex]:Show();
	end

	VUHDO_Msg("  Test frames created. Check for consistent spacing and pixel alignment.");
	VUHDO_Msg("  Use '/vd pixel hide' to remove test frames.");

	return;

end



--
local tHasAnyIssues;
local tScaling;
local tBorder;
local tRowSpacing;
local tColumnSpacing;
local tBorderGapX;
local tBorderGapY;
local tHeaderSpacing;
local tSpacingData;
local tPanelHasIssues;
local tStatus;
function VUHDO_pixelTestSpacing()

	VUHDO_Msg("|cffFFD100--- Pixel-Perfect Spacing Test ---|r");

	if not VUHDO_PANEL_SETUP then
		VUHDO_Msg("|cffFF4444Error:|r Panel setup not loaded.");
		return;
	end

	VUHDO_Msg("|cffFFA500** System Configuration:**|r");
	VUHDO_Msg("  |cffB0E0E6UI Scale:|r " .. VUHDO_getUIScale());
	VUHDO_Msg("  |cffB0E0E6Pixel Scale:|r " .. VUHDO_getPixelScale());
	VUHDO_Msg("  |cffB0E0E6UI Unit Factor:|r " .. VUHDO_getPixelToUIUnitFactor());

	tHasAnyIssues = false;

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		if VUHDO_PANEL_SETUP[tPanelNum] then
			tScaling = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"];
			tBorder = VUHDO_PANEL_SETUP[tPanelNum]["PANEL_COLOR"]["BORDER"];

			VUHDO_Msg("|cffFFA500** Panel " .. tPanelNum .. ":**|r");

			tRowSpacing = tScaling["rowSpacing"] or 0;
			tColumnSpacing = tScaling["columnSpacing"] or 0;
			tBorderGapX = tScaling["borderGapX"] or 0;
			tBorderGapY = tScaling["borderGapY"] or 0;
			tHeaderSpacing = tScaling["headerSpacing"] or 0;

			VUHDO_Msg("  |cffB0E0E6Spacing Values Analysis:|r");

			tSpacingData = {
				{ ["name"] = "Row Spacing", ["value"] = tRowSpacing, ["used"] = VUHDO_getPixelPerfectSpacing(tPanelNum, "rowSpacing"), },
				{ ["name"] = "Column Spacing", ["value"] = tColumnSpacing, ["used"] = VUHDO_getPixelPerfectSpacing(tPanelNum, "columnSpacing"), },
				{ ["name"] = "Border Gap X", ["value"] = tBorderGapX, ["used"] = VUHDO_getPixelPerfectGap(tPanelNum, "borderGapX"), },
				{ ["name"] = "Border Gap Y", ["value"] = tBorderGapY, ["used"] = VUHDO_getPixelPerfectGap(tPanelNum, "borderGapY"), },
				{ ["name"] = "Header Spacing", ["value"] = tHeaderSpacing, ["used"] = VUHDO_getPixelPerfectSpacing(tPanelNum, "headerSpacing"), },
			};

			tPanelHasIssues = false;

			for _, tData in ipairs(tSpacingData) do
				tStatus = "|cff44FF44[OK]|r";

				if type(tData.value) ~= "number" or tData.value < 0 then
					tStatus = "|cffFF4444[INVALID]|r";
					tPanelHasIssues = true;
					tHasAnyIssues = true;
				elseif tData.value ~= floor(tData.value) then
					tStatus = "|cffFFAA00[NON-INTEGER]|r";
					tPanelHasIssues = true;
					tHasAnyIssues = true;
				elseif tData.value ~= tData.used then
					tStatus = "|cffFFAA00[ROUNDING ISSUE]|r";
					tPanelHasIssues = true;
					tHasAnyIssues = true;
				end

				VUHDO_Msg("    " .. tData.name .. ": " .. tData.value .. " (used: " .. tData.used .. ") " .. tStatus);
			end

			VUHDO_Msg("  |cffB0E0E6Border Values:|r");
			VUHDO_Msg("    Edge Size: " .. (tBorder["edgeSize"] or 0) .. " (used: " .. VUHDO_getPixelPerfectBorderEdgeSize(tPanelNum) .. ")");
			VUHDO_Msg("    Insets: " .. (tBorder["insets"] or 0) .. " (used: " .. VUHDO_getPixelPerfectBorderInsets(tPanelNum) .. ")");
			VUHDO_Msg("    Color: R=" .. (tBorder["R"] or 0) .. " G=" .. (tBorder["G"] or 0) .. " B=" .. (tBorder["B"] or 0) .. " A=" .. (tBorder["O"] or 0));

			if tPanelHasIssues then
				VUHDO_Msg("  |cffFF4444[!] Issues found in Panel " .. tPanelNum .. ":|r");
				VUHDO_Msg("  |cffFFAA00Issues will be automatically fixed when panels are updated|r");
			else
				VUHDO_Msg("  |cff44FF44[OK]|r All spacing values are pixel-perfect.");
			end
		end
	end

	if tHasAnyIssues then
		VUHDO_Msg("|cffFFA500** Note:**|r");
		VUHDO_Msg("  |cffFFAA00Pixel-perfect issues are automatically fixed when panels are updated|r");
	end

	return;

end



--
local tScaling;
local tSpacingValues;
local tIssues;
function VUHDO_validatePixelPerfectSpacing(aPanelNum)

	tScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];
	tSpacingValues = {
		["rowSpacing"] = tScaling["rowSpacing"] or 0,
		["columnSpacing"] = tScaling["columnSpacing"] or 0,
		["borderGapX"] = tScaling["borderGapX"] or 0,
		["borderGapY"] = tScaling["borderGapY"] or 0,
		["headerSpacing"] = tScaling["headerSpacing"] or 0
	};

	tIssues = { };

	for tKey, tValue in pairs(tSpacingValues) do
		if type(tValue) ~= "number" or tValue < 0 then
			tinsert(tIssues, tKey .. " (invalid value: " .. tostring(tValue) .. ")");
		elseif tValue ~= floor(tValue) then
			tinsert(tIssues, tKey .. " (non-integer: " .. tValue .. ")");
		end
	end

	if #tIssues > 0 then
		VUHDO_Msg("|cffFF4444[!] Pixel-perfect spacing issues in panel " .. aPanelNum .. ":|r " .. table.concat(tIssues, ", "));

		return false;
	end

	return true;

end



--
local tVisibleCount;
function VUHDO_pixelHideTestFrame()

	tVisibleCount = 0;

	for tIndex, tFrame in pairs(tTestFrames) do
		if tFrame then
			if tFrame:IsShown() then
				tVisibleCount = tVisibleCount + 1;
			end

			tFrame:Hide();

			tFrame:SetScript("OnDragStart", nil);
			tFrame:SetScript("OnDragStop", nil);

			tFrame:SetMovable(false);
			VUHDO_PixelUtil.EnableMouse(tFrame, false);

			tFrame:UnregisterAllEvents();
			tFrame:SetParent(nil);

			tTestFrames[tIndex] = nil;
		end
	end

	if tVisibleCount > 0 then
		VUHDO_Msg("|cffFFD100--- Pixel Test Frames Hidden ---|r");

		VUHDO_Msg("  |cffB0E0E6Action:|r " .. tVisibleCount .. " test frames have been hidden and cleaned up");
		VUHDO_Msg("  |cffB0E0E6Note:|r Use '/vd pixel test' to show them again");

		VUHDO_Msg("|cffFFD100--- End of Pixel Test Frames ---|r");
	else
		VUHDO_Msg("|cffFFD100--- Pixel Test Frames ---|r");

		VUHDO_Msg("  |cffB0E0E6Status:|r No test frames were found to clean up");

		VUHDO_Msg("|cffFFD100--- End of Pixel Test Frames ---|r");
	end

	return;

end



--
local tTestValues;
local tRounded;
local tRoundedWithMin;
function VUHDO_testPixelPerfectValues()

	VUHDO_Msg("|cffFFD100--- Enhanced Pixel-Perfect Value Test ---|r");

	VUHDO_Msg("|cffFFA500** Resolution Info:|r");
	VUHDO_Msg("  |cffB0E0E6UI Unit Factor:|r " .. VUHDO_getPixelToUIUnitFactor());
	VUHDO_Msg("  |cffB0E0E6Pixel Scale:|r " .. VUHDO_getPixelScale());

	VUHDO_Msg("|cffFFA500** Rounding Test Values:|r");
	VUHDO_Msg("  |cffB0E0E6Format:|r Original -> Rounded (with min 1px)");

	tTestValues = {0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0};

	for _, tValue in ipairs(tTestValues) do
		tRounded = VUHDO_roundToPixel(tValue);
		tRoundedWithMin = VUHDO_roundToPixel(tValue, nil, 1);

		VUHDO_Msg(format("  %.2f -> %.2f (min: %.2f)", tValue, tRounded, tRoundedWithMin));
	end

	VUHDO_Msg("|cffFFA500** Edge Case Tests:|r");
	VUHDO_Msg("  Zero value: " .. VUHDO_roundToPixel(0));
	VUHDO_Msg("  Negative value: " .. VUHDO_roundToPixel(-1.5));
	VUHDO_Msg("  Negative with min: " .. VUHDO_roundToPixel(-1.5, nil, 1));
	VUHDO_Msg("  Tiny value: " .. VUHDO_roundToPixel(0.1));
	VUHDO_Msg("  Tiny with min: " .. VUHDO_roundToPixel(0.1, nil, 1));

	VUHDO_Msg("|cffFFD100--- End of Enhanced Pixel-Perfect Value Test ---|r");

	return;

end



--
local tInitialScale;
function VUHDO_testScaleChangeHandling()

	VUHDO_Msg("|cffFFD100--- Scale Change Handling Test ---|r");

	tInitialScale = VUHDO_getPixelScale();

	VUHDO_Msg("Initial scale: " .. tInitialScale);

	VUHDO_Msg("Testing scale change handler...");

	VUHDO_handleScaleChange();

	VUHDO_Msg("|cff44FF44[OK]|r Scale change task enqueued successfully");
	VUHDO_Msg("|cffFFD100--- End of Scale Change Test ---|r");

	return;

end



--
function VUHDO_clearBackdropCache()

	table.wipe(sBackdropCache);
	table.wipe(sInsetsCache);

	return;

end



--
local tBackdropCount;
local tInsetsCount;
local function VUHDO_getBackdropCacheStats()

	tBackdropCount = 0;
	tInsetsCount = 0;

	for _ in pairs(sBackdropCache) do
		tBackdropCount = tBackdropCount + 1;
	end

	for _ in pairs(sInsetsCache) do
		tInsetsCount = tInsetsCount + 1;
	end

	return tBackdropCount, tInsetsCount;

end



--
local tBackdropCount;
local tInsetsCount;
function VUHDO_pixelPrintCacheStats()

	tBackdropCount, tInsetsCount = VUHDO_getBackdropCacheStats();

	VUHDO_Msg("|cffFFD100--- Backdrop Cache Stats ---|r");

	VUHDO_Msg("Cached backdrops: " .. tBackdropCount);
	VUHDO_Msg("Cached insets: " .. tInsetsCount);

	VUHDO_Msg("|cffFFD100--- End of Cache Stats ---|r");

	return;

end



--
function VUHDO_pixelShowScale()

	VUHDO_Msg("|cffB0E0E6Current UI Scale:|r " .. VUHDO_getUIScale());
	VUHDO_Msg("|cffFFD100Current Pixel Scale:|r " .. VUHDO_getPixelScale());
	VUHDO_Msg("|cffFFD100UI Unit Factor:|r " .. VUHDO_getPixelToUIUnitFactor());

	return;

end



--
function VUHDO_pixelHelp()

	VUHDO_Msg("Pixel-perfect commands:");
	VUHDO_Msg("  /vd pixel test - Show pixel-perfect test frames");
	VUHDO_Msg("  /vd pixel hide - Hide and clean up test frames");
	VUHDO_Msg("  /vd pixel spacing - Show pixel-perfect spacing values");
	VUHDO_Msg("  /vd pixel scale - Show current scale values");
	VUHDO_Msg("  /vd pixel cache - Print backdrop cache metrics");
	VUHDO_Msg("  /vd pixel validate [panel] - Validate pixel-perfect spacing");

	return;

end



--
function VUHDO_pixelValidate(aPanelNum)

	if aPanelNum then
		VUHDO_validatePixelPerfectSpacing(aPanelNum);
	else
		for tPanelNum = 1, VUHDO_MAX_PANELS do
			if VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP[tPanelNum] then
				VUHDO_validatePixelPerfectSpacing(tPanelNum);
			end
		end
	end

	return;

end
