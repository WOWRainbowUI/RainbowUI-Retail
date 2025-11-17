local GetSpellBookItemTexture = GetSpellBookItemTexture or VUHDO_getSpellBookItemTexture;

local VUHDO_getHealthBar;
local VUHDO_getBarIcon;
local VUHDO_getBarIconTimer;
local VUHDO_getBarIconCounter;
local VUHDO_getBarIconCharge;
local VUHDO_getOrCreateCooldown;
local VUHDO_strempty;

local sBarColors;
local sHotConfig = { };
local sHotBarConfig = { };
local sOrientation = { };

--
function VUHDO_panelRedrawHotsInitLocalOverrides()

	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getBarIcon = _G["VUHDO_getBarIcon"];
	VUHDO_getBarIconTimer = _G["VUHDO_getBarIconTimer"];
	VUHDO_getBarIconCounter = _G["VUHDO_getBarIconCounter"];
	VUHDO_getBarIconCharge = _G["VUHDO_getBarIconCharge"];
	VUHDO_getOrCreateCooldown = _G["VUHDO_getOrCreateCooldown"];
	VUHDO_strempty = _G["VUHDO_strempty"];

	sBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		sHotConfig[tPanelNum] = VUHDO_PANEL_SETUP[tPanelNum]["HOTS"];

		sHotBarConfig[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HOT_BARS"];
		sOrientation[tPanelNum] = VUHDO_getStatusbarOrientationString("HOT_BARS", tPanelNum);
	end

end



--
local sBarScaling;
local sHotIconSize, sHotIconOffsets;
local sHotBarWidth;
local sHotBarHeight;
local tHotIconSizeTotal;
local tScale;
local tHotIconSize;
function VUHDO_panelRedrwawHotsInitLocalVars(aPanelNum)

	sBarScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];	

	sHotIconSize = sBarScaling["barHeight"] * VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["size"] * 0.01;

	if sHotIconSize == 0 then
		sHotIconSize = 0.001;
	end

	if not sHotIconOffsets then
		sHotIconOffsets = { };
	end

	tHotIconSizeTotal = 0;

	for tCnt = 1, 5 do
		sHotIconOffsets[tCnt] = tHotIconSizeTotal;

		tScale = VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["SLOTCFG"]["" .. tCnt]["scale"] or 1;
		tHotIconSize = sHotIconSize * tScale;

		tHotIconSizeTotal = tHotIconSizeTotal + tHotIconSize;
	end

	for tCnt = 9, 12 do -- VUHDO_MAX_HOTS
		sHotIconOffsets[tCnt] = tHotIconSizeTotal;

		tScale = VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["SLOTCFG"]["" .. tCnt]["scale"] or 1;
		tHotIconSize = sHotIconSize * tScale;

		tHotIconSizeTotal = tHotIconSizeTotal + tHotIconSize;
	end

	if sHotBarConfig[aPanelNum]["vertical"] then
		sHotBarWidth = sBarScaling["barWidth"] * VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["BARS"]["width"] * 0.01;
		sHotBarHeight = VUHDO_getHealthBarHeight(aPanelNum);
	else
		sHotBarWidth = VUHDO_getHealthBarWidth(aPanelNum);
		sHotBarHeight = sBarScaling["barHeight"] * VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["BARS"]["width"] * 0.01;
	end

end



--
local sButton;
local sPanelNum;
local sHealthBarName;
function VUHDO_initButtonStaticsHots(aButton, aPanelNum)
	sButton = aButton;
	sPanelNum = aPanelNum;
	sHealthBarName = VUHDO_getHealthBar(aButton, 1):GetName();
end



--
local tOrientation;
local tHotBarConfig;
local tBarsPos;
function VUHDO_initHotBars(aPanelNum)

	if aPanelNum then
		VUHDO_panelRedrwawHotsInitLocalVars(aPanelNum);
		sPanelNum = aPanelNum;
	end

	tOrientation = sOrientation[sPanelNum];
	tHotBarConfig = sHotBarConfig[sPanelNum];
	tBarsPos = sHotConfig[sPanelNum]["BARS"]["radioValue"];

	local tHotBar;

	for tCnt = 6, 8 do
		tHotBar = VUHDO_getHealthBar(sButton, tCnt + 3);
		tHotBar:ClearAllPoints();

		if VUHDO_strempty(sHotConfig[sPanelNum]["SLOTS"][tCnt]) then
			tHotBar:Hide();
		else
			VUHDO_PixelUtil.SetWidth(tHotBar, sHotBarWidth);
			VUHDO_PixelUtil.SetHeight(tHotBar, sHotBarHeight);
			tHotBar:SetValue(0);
			tHotBar:SetVuhDoColor(sBarColors["HOT" .. tCnt]);
			tHotBar:SetOrientation(tOrientation);
			tHotBar:SetIsInverted(tHotBarConfig["invertGrowth"]);
			tHotBar:Show();
		end
	end

	if tHotBarConfig["vertical"] then
		if tBarsPos == 1 then -- edges
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 9), "LEFT", sHealthBarName, "LEFT", 0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 10), "CENTER", sHealthBarName, "CENTER",  0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 11), "RIGHT", sHealthBarName, "RIGHT",  0, 0);
		elseif tBarsPos == 2 then -- center
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 9), "CENTER", sHealthBarName, "CENTER", -sHotBarWidth, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 10), "CENTER", sHealthBarName, "CENTER",  0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 11), "CENTER", sHealthBarName, "CENTER", sHotBarWidth, 0);
		elseif tBarsPos == 3 then -- top
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 9), "LEFT", sHealthBarName, "LEFT", 0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 10), "LEFT", sHealthBarName, "LEFT", sHotBarWidth, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 11), "LEFT", sHealthBarName, "LEFT", 2 * sHotBarWidth, 0);
		else -- bottom
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 9), "RIGHT", sHealthBarName, "RIGHT", 0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 10), "RIGHT", sHealthBarName, "RIGHT", -sHotBarWidth, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 11), "RIGHT", sHealthBarName, "RIGHT", -2 * sHotBarWidth, 0);
		end
	else
		if tBarsPos == 1 then -- edges
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 9), "TOP", sHealthBarName, "TOP", 0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 10), "CENTER", sHealthBarName, "CENTER",  0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 11), "BOTTOM", sHealthBarName, "BOTTOM",  0, 0);
		elseif tBarsPos == 2 then -- center
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 9), "CENTER", sHealthBarName, "CENTER", 0, sHotBarHeight);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 10), "CENTER", sHealthBarName, "CENTER",  0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 11), "CENTER", sHealthBarName, "CENTER",  0, -sHotBarHeight);
		elseif tBarsPos == 3 then -- top
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 9), "TOP", sHealthBarName, "TOP", 0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 10), "TOP", sHealthBarName, "TOP",  0, -sHotBarHeight);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 11), "TOP", sHealthBarName, "TOP",  0, -2 * sHotBarHeight);
		else -- bottom
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 9), "BOTTOM", sHealthBarName, "BOTTOM", 0, 0);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 10), "BOTTOM", sHealthBarName, "BOTTOM",  0, sHotBarHeight);
			VUHDO_PixelUtil.SetPoint(VUHDO_getHealthBar(sButton, 11), "BOTTOM", sHealthBarName, "BOTTOM",  0, 2 * sHotBarHeight);
		end
	end

	return;

end



--
local tHotIcon;
local tTimer;
local tCounter;
local tChargeIcon;
local tHotColor;
local tHotConfig;
local tIconRadio;
local tCd;
local function VUHDO_initHotIcon(anIndex)

	if not anIndex then
		return;
	end

	tHotIcon = VUHDO_getBarIcon(sButton, anIndex);
	tTimer = VUHDO_getBarIconTimer(sButton, anIndex);
	tCounter = VUHDO_getBarIconCounter(sButton, anIndex);
	tChargeIcon = VUHDO_getBarIconCharge(sButton, anIndex);
	tHotColor = sBarColors["HOT" .. anIndex];

	tHotIcon:SetAlpha(0);

	tHotConfig = sHotConfig[sPanelNum];
	tIconRadio = tHotConfig["iconRadioValue"];

	if tIconRadio ~= 1 then
		tHotIcon:SetVertexColor(tHotColor["R"], tHotColor["G"], tHotColor["B"]);
	else
		tHotIcon:SetVertexColor(1, 1, 1);
	end

	tHotIcon:Show();
	tTimer:SetText("");
	tCounter:SetText("");
	tChargeIcon:Hide();

	if "CLUSTER" == tHotConfig["SLOTS"][anIndex] then
		VUHDO_customizeIconText(tHotIcon, tHotIcon:GetHeight(), tTimer, VUHDO_CONFIG["CLUSTER"]["TEXT"]);

		tTimer:Show();
		tCounter:Hide();

		tHotIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\cluster2");
		VUHDO_PixelUtil.ApplySettings(tHotIcon);
	else
		if tIconRadio == 4 then -- Text only
			tHotIcon:Hide();
		elseif tIconRadio == 3 then -- Flat
			tHotIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\hot_flat_16_16");
			VUHDO_PixelUtil.ApplySettings(tHotIcon);
		elseif tIconRadio == 2 then -- Glossy
			tHotIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\icon_white_square");
			VUHDO_PixelUtil.ApplySettings(tHotIcon);
		else
			local tHotName = tHotConfig["SLOTS"][anIndex];

			if VUHDO_CAST_ICON_DIFF[tHotName] then
				tHotIcon:SetTexture(VUHDO_CAST_ICON_DIFF[tHotName]);
				VUHDO_PixelUtil.ApplySettings(tHotIcon);
			else
				local tTexture = GetSpellBookItemTexture(tHotName);
				if tTexture then
					tHotIcon:SetTexture(tTexture);
					VUHDO_PixelUtil.ApplySettings(tHotIcon);
				end
			end
		end

		VUHDO_customizeIconText(tHotIcon, tHotIcon:GetHeight(), tTimer, tHotConfig["TIMER_TEXT"]);
		VUHDO_customizeIconText(tHotIcon, tHotIcon:GetHeight(), tCounter, tHotConfig["COUNTER_TEXT"]);

		if tHotConfig["stacksRadioValue"] == 2 then -- Counter text
			tHotIcon:SetVertexColor(1, 1, 1);
			tCounter:SetTextColor(tHotColor["TR"], tHotColor["TG"], tHotColor["TB"]);
			tCounter:Show();
		else
			tTimer:SetTextColor(VUHDO_textColor(tHotColor));
			tCounter:Hide();
		end

		tTimer:SetShown(tHotColor["countdownMode"] ~= 0);

		VUHDO_PixelUtil.SetSize(tChargeIcon, tHotIcon:GetWidth() + 4, tHotIcon:GetHeight() + 4);
		tChargeIcon:SetVertexColor(tHotColor["R"] * 2, tHotColor["G"] * 2, tHotColor["B"] * 2);
		tChargeIcon:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tChargeIcon, "TOPLEFT", tHotIcon:GetName(), "TOPLEFT", -2, 2);

		if tHotColor["isClock"] then
			tCd = VUHDO_getOrCreateCooldown(VUHDO_getBarIconFrame(sButton, anIndex), sButton, anIndex);

			tCd:SetAllPoints(tHotIcon);

			-- Blizzard Cooldown frame options:
			--  SetReverse(true/false) - controls sweep direction (true = counter-clockwise, false = clockwise)
			--  SetHideCountdownNumbers(true/false) - controls whether countdown numbers are shown
			--  SetDrawSwipe(true/false) - controls whether the sweep animation is drawn
			--  SetDrawEdge(true/false) - controls whether the edge glow is drawn
			--  SetDrawBling(true/false) - controls whether the bling effect is drawn
			--  SetBlingTexture(texture) - sets custom bling texture
			--  SetEdgeTexture(texture) - sets custom edge texture
			--  SetSwipeTexture(texture) - sets custom swipe texture
			--  SetCooldownColor(r, g, b, a) - sets the color of the cooldown sweep

			tCd:SetHideCountdownNumbers(true); -- hide countdown numbers
			tCd:SetReverse(true); -- clockwise sweep (standard)
			tCd:SetDrawSwipe(true); -- always show the sweep animation
			tCd:SetDrawEdge(true); -- show edge glow for better visibility
			tCd:SetDrawBling(false); -- disable bling effect for cleaner look

			tCd:SetCooldown(GetTime(), 0);

			tCd:SetAlpha(0);
		end
	end

	return;

end



--
local tHotConfig;
local tHotPos;
local function VUHDO_initHotPosOffset(anIndex)

	local tHotIcon = VUHDO_getBarIcon(sButton, anIndex);

	local tOffset = sHotIconOffsets[anIndex];

	tHotIcon:ClearAllPoints();

	tHotConfig = sHotConfig[sPanelNum];
	tHotPos = tHotConfig["radioValue"];

	if tHotPos == 2 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "LEFT", sHealthBarName, "LEFT", tOffset, 0); -- li
	elseif tHotPos == 3 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "RIGHT", sHealthBarName, "RIGHT", -tOffset, 0); -- ri
	elseif tHotPos == 1 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "RIGHT", sButton:GetName(), "LEFT", -tOffset, 0); -- lo
	elseif tHotPos == 4 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "LEFT", sButton:GetName(), "RIGHT", tOffset, 0); -- ro
	elseif tHotPos == 5 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "TOPLEFT", sHealthBarName, "BOTTOMLEFT", tOffset, sHotIconSize * 0.5); -- lb
	elseif tHotPos == 6 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "TOPRIGHT", sHealthBarName, "BOTTOMRIGHT", -tOffset, sHotIconSize * 0.5); -- rb
	elseif tHotPos == 7 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "TOPLEFT", sButton:GetName(), "BOTTOMLEFT", tOffset, 0); -- lu
	elseif tHotPos == 8 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "TOPRIGHT", sButton:GetName(), "BOTTOMRIGHT", -tOffset, 0); -- ru
	elseif tHotPos == 9 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "TOPLEFT", sHealthBarName, "TOPLEFT", tOffset, sBarScaling["barHeight"] / 3); -- la
	elseif tHotPos == 10 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "TOPLEFT", sHealthBarName, "TOPLEFT", tOffset, 0); -- lu corner
	elseif tHotPos == 12 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOMLEFT", sHealthBarName, "BOTTOMLEFT", tOffset, 0); -- lb corner
	elseif tHotPos == 11 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOMRIGHT", sHealthBarName, "BOTTOMRIGHT", -tOffset, 0); -- rb corner
	elseif tHotPos == 13 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOMLEFT", sButton:GetName(), "BOTTOMLEFT", tOffset, 0); -- lb
	elseif tHotPos == 14 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOMRIGHT", sButton:GetName(), "BOTTOMRIGHT", -tOffset, 0); -- rb
	end

	VUHDO_PixelUtil.SetSize(tHotIcon, sHotIconSize * (tHotConfig["SLOTCFG"]["" .. anIndex]["scale"] or 1), sHotIconSize * (tHotConfig["SLOTCFG"]["" .. anIndex]["scale"] or 1));
	VUHDO_PixelUtil.SetScale(VUHDO_getBarIconFrame(sButton, anIndex), 1);

end



--
local tHotConfig;
local function VUHDO_initHotPosSides(anIndex)

	local tHotIcon = VUHDO_getBarIcon(sButton, anIndex);

	tHotConfig = sHotConfig[sPanelNum];

	local tIsBothBottom = tHotConfig["SLOTS"][4] ~= nil and tHotConfig["SLOTS"][5] ~= nil;
	local tIsBothTop = tHotConfig["SLOTS"][2] ~= nil and tHotConfig["SLOTS"][9] ~= nil;

	tHotIcon:ClearAllPoints();

	if anIndex == 1 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "LEFT", sHealthBarName, "LEFT", 0, 0);
	elseif anIndex == 2 then
		if tIsBothTop then VUHDO_PixelUtil.SetPoint(tHotIcon, "TOP",  sHealthBarName, "TOP", -sBarScaling["barWidth"] * 0.2, 0);
		else VUHDO_PixelUtil.SetPoint(tHotIcon, "TOP",  sHealthBarName, "TOP", 0, 0); end
	elseif anIndex == 9 then
		if tIsBothTop then VUHDO_PixelUtil.SetPoint(tHotIcon, "TOP",  sHealthBarName, "TOP", sBarScaling["barWidth"] * 0.2, 0);
		else VUHDO_PixelUtil.SetPoint(tHotIcon, "TOP",  sHealthBarName, "TOP", 0, 0); end
	elseif anIndex == 3 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "RIGHT",  sHealthBarName, "RIGHT", 0, 0);
	elseif anIndex == 4 then
		if tIsBothBottom then VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOM", sHealthBarName, "BOTTOM", sBarScaling["barWidth"] * 0.2, 0);
		else VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOM", sHealthBarName, "BOTTOM", 0, 0); end
	elseif anIndex == 5 then
		if tIsBothBottom then VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOM", sHealthBarName, "BOTTOM", -sBarScaling["barWidth"] * 0.2, 0);
		else VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOM", sHealthBarName, "BOTTOM", 0, 0); end
	elseif anIndex == 10 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "CENTER", sHealthBarName, "CENTER", 0, 0);
	elseif anIndex == 11 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "CENTER", sHealthBarName, "CENTER", -sBarScaling["barWidth"] * 0.2, 0);
	elseif anIndex == 12 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "CENTER", sHealthBarName, "CENTER", sBarScaling["barWidth"] * 0.2, 0);
	end

	VUHDO_PixelUtil.SetSize(tHotIcon, sHotIconSize * 0.5, sHotIconSize * 0.5);
	VUHDO_PixelUtil.SetScale(VUHDO_getBarIconFrame(sButton, anIndex), tHotConfig["SLOTCFG"]["" .. anIndex]["scale"] or 1);

end



--
local function VUHDO_initHotPosEdges(anIndex)

	local tHotIcon = VUHDO_getBarIcon(sButton, anIndex);
	tHotIcon:ClearAllPoints();

	if anIndex == 1 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "TOPLEFT", sHealthBarName, "TOPLEFT", 0, 0);
	elseif anIndex == 2 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "TOPRIGHT", sHealthBarName, "TOPRIGHT", 0, 0);
	elseif anIndex == 3 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOMLEFT", sHealthBarName, "BOTTOMLEFT", 0, 0);
	elseif anIndex == 4 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOMRIGHT", sHealthBarName, "BOTTOMRIGHT", 0, 0);
	elseif anIndex == 5 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "BOTTOM", sHealthBarName, "BOTTOM", 0, 0);
	elseif anIndex == 9 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "TOP", sHealthBarName, "TOP", 0, 0);
	elseif anIndex == 10 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "CENTER", sHealthBarName, "CENTER", 0, 0);
	elseif anIndex == 11 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "CENTER", sHealthBarName, "CENTER", -sBarScaling["barWidth"] * 0.2, 0);
	elseif anIndex == 12 then
		VUHDO_PixelUtil.SetPoint(tHotIcon, "CENTER", sHealthBarName, "CENTER", sBarScaling["barWidth"] * 0.2, 0);
	end

	VUHDO_PixelUtil.SetSize(tHotIcon, sHotIconSize * 0.5, sHotIconSize * 0.5);
	VUHDO_PixelUtil.SetScale(VUHDO_getBarIconFrame(sButton, anIndex), sHotConfig[sPanelNum]["SLOTCFG"]["" .. anIndex]["scale"] or 1);

end



--
local tBarIcon;
local function VUHDO_initAndPosHotIcon(anIndex, aPosFunction)

	if not VUHDO_strempty(sHotConfig[sPanelNum]["SLOTS"][anIndex]) and sHotIconSize > 1 then
		VUHDO_getOrCreateHotIcon(sButton, anIndex);
		aPosFunction(anIndex);
		VUHDO_initHotIcon(anIndex);
	else
		tBarIcon = VUHDO_getBarIcon(sButton, anIndex);
		if tBarIcon then
			tBarIcon:Hide();
			VUHDO_getBarIconTimer(sButton, anIndex):Hide();
			VUHDO_getBarIconCounter(sButton, anIndex):Hide();
		end
	end

end



--
local tHotPos;
local tPosFunction;
function VUHDO_initAllHotIcons(aPanelNum)

	if aPanelNum then
		VUHDO_panelRedrwawHotsInitLocalVars(aPanelNum);
		sPanelNum = aPanelNum;
	end

	tHotPos = sHotConfig[sPanelNum]["radioValue"];

	tPosFunction = 20 == tHotPos and VUHDO_initHotPosSides
		or 21 == tHotPos and VUHDO_initHotPosEdges or VUHDO_initHotPosOffset;

	for tCnt = 1, 5 do
		VUHDO_initAndPosHotIcon(tCnt, tPosFunction);
	end

	for tCnt = 9, 12 do -- VUHDO_MAX_HOTS
		VUHDO_initAndPosHotIcon(tCnt, tPosFunction);
	end

	return;

end
