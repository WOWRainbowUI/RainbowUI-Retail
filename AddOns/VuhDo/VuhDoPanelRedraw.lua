local _G = _G;
local _;


local VUHDO_STD_BACKDROP = nil;
local VUHDO_DESIGN_BACKDROP = nil;
local VUHDO_CONFIG;
local VUHDO_INDICATOR_CONFIG;


local ipairs = ipairs;
local pairs = pairs;
local strfind = strfind;
local twipe = table.wipe;
local tinsert = table.insert;
local InCombatLockdown = InCombatLockdown;


--
local sPanelConfig = { };
local sButtonInitSemaphores = { };
local sButtonPositionSemaphores = { };
local sRedrawAllPanelsSemaphore;
local sRedrawPanelSemaphores = { };
local sPanelCompletionTracker;
local sWaitingAllPanelsRedraws = { };
local sWaitingIndividualRedraws = { };
local sQueuedAllPanelsRequests = { };
local sQueuedIndividualRequests = { };
local sIsManaBouquet = { };

local VUHDO_SEMAPHORE_CONFIG = {
	["BUTTON_INIT_TIME_US"] = 1200,
	["BUTTON_POSITION_TIME_MS"] = 7,
	["BUTTON_INIT_SAFETY_FACTOR"] = 2.0,
	["BUTTON_POSITION_SAFETY_FACTOR"] = 1.5,
	["PANEL_REDRAW_SAFETY_FACTOR"] = 4.0,

	["MIN_TIMEOUT_MS"] = 5,

	["PARTY_THRESHOLD"] = 5,
	["SMALL_RAID_THRESHOLD"] = 15,
	["MEDIUM_RAID_THRESHOLD"] = 25,

	["SOLO_INIT_SAFETY"] = 1.0,
	["SOLO_POSITION_SAFETY"] = 1.0,
	["SOLO_PANEL_SAFETY"] = 1.05,
	["PARTY_INIT_SAFETY"] = 1.05, -- -- party (2-5)
	["PARTY_POSITION_SAFETY"] = 1.02,
	["PARTY_PANEL_SAFETY"] = 1.1,
	["SMALL_RAID_INIT_SAFETY"] = 1.1, -- small raid (6-15)
	["SMALL_RAID_POSITION_SAFETY"] = 1.03,
	["SMALL_RAID_PANEL_SAFETY"] = 1.15,
	["MEDIUM_RAID_INIT_SAFETY"] = 1.15, -- medium raid (16-25)
	["MEDIUM_RAID_POSITION_SAFETY"] = 1.05,
	["MEDIUM_RAID_PANEL_SAFETY"] = 1.25,
	["LARGE_RAID_PANEL_MULTIPLIER"] = 1.3, -- large raid (26+) multiplier
};
local sButtonInitTimeouts = { };
local sButtonPositionTimeouts = { };
local sPanelRedrawTimeout = 0;

local VUHDO_getFont;
local VUHDO_getHealthBar;
local VUHDO_getPixelPerfectBorderEdgeSize;
local VUHDO_getPixelPerfectBorderInsets;
local VUHDO_getDynamicModelArray;
local VUHDO_getGroupMembersSorted;
local VUHDO_getGroupMembers;
local VUHDO_redrawPanel;
local VUHDO_redrawAllPanels;


--
function VUHDO_panelRedrawInitLocalOverrides()

	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_INDICATOR_CONFIG = _G["VUHDO_INDICATOR_CONFIG"];

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		sIsManaBouquet[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["MANA_BAR"] ~= "";
	end

	VUHDO_getFont = _G["VUHDO_getFont"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getPixelPerfectBorderEdgeSize = _G["VUHDO_getPixelPerfectBorderEdgeSize"];
	VUHDO_getPixelPerfectBorderInsets = _G["VUHDO_getPixelPerfectBorderInsets"];
	VUHDO_getDynamicModelArray = _G["VUHDO_getDynamicModelArray"];
	VUHDO_getGroupMembersSorted = _G["VUHDO_getGroupMembersSorted"];
	VUHDO_getGroupMembers = _G["VUHDO_getGroupMembers"];

	VUHDO_panelRedrawCustomDebuffsInitLocalOverrides();
	VUHDO_panelRedrawHeadersInitLocalOverrides();
	VUHDO_panelRedrawHotsInitLocalOverrides();

	if VUHDO_CONFIG["USE_DEFERRED_REDRAW"] then
		VUHDO_redrawPanel = _G["VUHDO_deferRedrawPanel"];
		VUHDO_redrawAllPanels = _G["VUHDO_deferRedrawAllPanels"];
	else
		VUHDO_redrawPanel = _G["VUHDO_redrawPanel"];
		VUHDO_redrawAllPanels = _G["VUHDO_redrawAllPanels"];
	end

	return;

end



--
function VUHDO_getSemaphoreConfig()

	return VUHDO_SEMAPHORE_CONFIG;

end



--
function VUHDO_invalidateSemaphoreTimeouts()

	twipe(sButtonInitTimeouts);
	twipe(sButtonPositionTimeouts);
	sPanelRedrawTimeout = 0;

	VUHDO_calculateSemaphoreTimeouts();

	return;

end



--
local sHealthBar;
local tBar;



--
local tPanelSetup;
local tSign;
function VUHDO_initLocalVars(aPanelNum)

	if not VUHDO_PANEL_SETUP or not VUHDO_PANEL_SETUP[aPanelNum] then
		return;
	end

	--VUHDO_panelRedrwawHeadersInitLocalVars(aPanelNum);
	VUHDO_panelRedrwawHotsInitLocalVars(aPanelNum);
	VUHDO_panelRedrawCustomDebuffsInitLocalVars(aPanelNum);

	tPanelSetup = VUHDO_PANEL_SETUP[aPanelNum];

	sPanelConfig[aPanelNum] = {
		["panelSetup"] = tPanelSetup,
		["barScaling"] = tPanelSetup["SCALING"],
		["raidIcon"] = tPanelSetup["RAID_ICON"],
		["overhealText"] = tPanelSetup["OVERHEAL_TEXT"],
		["sortCriterion"] = tPanelSetup["MODEL"]["sort"],
		["mainFont"] = VUHDO_getFont(tPanelSetup["PANEL_COLOR"]["TEXT"]["font"]),
		["statusTexture"] = VUHDO_LibSharedMedia:Fetch('statusbar', tPanelSetup["PANEL_COLOR"]["barTexture"]),
		["textAnchors"] = VUHDO_splitString(tPanelSetup["ID_TEXT"]["position"], "+"),
		["lifeText"] = tPanelSetup["LIFE_TEXT"],
		["mainFontHeight"] = tPanelSetup["PANEL_COLOR"]["TEXT"]["textSize"],
		["lifeFontHeight"] = tPanelSetup["PANEL_COLOR"]["TEXT"]["textSizeLife"],
		["outlineText"] = tPanelSetup["PANEL_COLOR"]["TEXT"]["outline"] and "OUTLINE|" or "",
		["shadowAlpha"] = tPanelSetup["PANEL_COLOR"]["TEXT"]["USE_SHADOW"] and 1 or 0,
		["barHeight"] = VUHDO_getHealthBarHeight(aPanelNum),
		["barWidth"] = VUHDO_getHealthBarWidth(aPanelNum),
		["manaBarHeight"] = VUHDO_getManaBarHeight(aPanelNum),
		["sideBarLeftWidth"] = VUHDO_getSideBarWidthLeft(aPanelNum),
		["sideBarRightWidth"] = VUHDO_getSideBarWidthRight(aPanelNum),
		["indicatorConfig"] = VUHDO_INDICATOR_CONFIG[aPanelNum],
		["privateAura"] = tPanelSetup["PRIVATE_AURA"],
	};

	if (tPanelSetup["PANEL_COLOR"]["TEXT"]["USE_MONO"]) then
		sPanelConfig[aPanelNum]["outlineText"] = sPanelConfig[aPanelNum]["outlineText"] .. "OUTLINEMONOCHROME";
	end

	if (sPanelConfig[aPanelNum]["manaBarHeight"] == 0) then
		sPanelConfig[aPanelNum]["manaBarHeight"] = 0.001;
	end

	sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"] = sPanelConfig[aPanelNum]["indicatorConfig"]["CUSTOM"]["SWIFTMEND_INDICATOR"];

	if sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["anchor"] == nil then
		sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["anchor"] = "TOPLEFT";
	end

	if sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["xAdjust"] == nil or sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["yAdjust"] == nil then
		sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["xAdjust"] = 5.5;
		sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["yAdjust"] = -14;
	end

	sPanelConfig[aPanelNum]["privateAuraHeight"] = sPanelConfig[aPanelNum]["barScaling"]["barHeight"];

	tSign = ("TOPLEFT" == sPanelConfig[aPanelNum]["privateAura"]["point"] or "LEFT" == sPanelConfig[aPanelNum]["privateAura"]["point"] or "BOTTOMLEFT" == sPanelConfig[aPanelNum]["privateAura"]["point"]) and 1 or -1;
	sPanelConfig[aPanelNum]["privateAuraStep"] = tSign * sPanelConfig[aPanelNum]["privateAuraHeight"];

	sPanelConfig[aPanelNum]["privateAuraXOffset"] = sPanelConfig[aPanelNum]["privateAura"]["xAdjust"] * sPanelConfig[aPanelNum]["barScaling"]["barWidth"] * 0.01;
	sPanelConfig[aPanelNum]["privateAuraYOffset"] = -sPanelConfig[aPanelNum]["privateAura"]["yAdjust"] * sPanelConfig[aPanelNum]["privateAuraHeight"] * 0.01;

	return;

end



--
function VUHDO_isPanelVisible(aPanelNum)

	if not VUHDO_CONFIG["SHOW_PANELS"] or not VUHDO_PANEL_MODELS[aPanelNum] or not VUHDO_IS_SHOWN_BY_GROUP then
		return false;
	end

	if VUHDO_isModelInPanel(aPanelNum, 42) -- VUHDO_ID_PRIVATE_TANKS
		and (not VUHDO_CONFIG["OMIT_TARGET"] or not VUHDO_CONFIG["OMIT_FOCUS"]) then
		return true;
	end

	if VUHDO_isModelInPanel(aPanelNum, 82) then -- VUHDO_ID_TARGET
		return true;
	end

	if VUHDO_isModelInPanel(aPanelNum, 83) then -- VUHDO_ID_FOCUS
		return true;
	end

	if VUHDO_isModelInPanel(aPanelNum, 44) then -- VUHDO_ID_BOSSES
		return true;
	end

	if VUHDO_CONFIG["HIDE_EMPTY_PANELS"] and not VUHDO_isConfigPanelShowing() and #VUHDO_PANEL_UNITS[aPanelNum] == 0 then
		return false;
	end

	return true;

end



--
function VUHDO_isPanelPopulated(aPanelNum)

	return VUHDO_CONFIG["SHOW_PANELS"] and VUHDO_PANEL_MODELS[aPanelNum] and VUHDO_IS_SHOWN_BY_GROUP;

end



--
local tModelArray;
local tMemberNum;
local function VUHDO_getNumButtonsPanel(aPanelNum)

	tModelArray = VUHDO_getDynamicModelArray(aPanelNum);
	tMemberNum = 0;

	for tModelIndex, tModelId in pairs(tModelArray)  do
		tMemberNum = tMemberNum + #VUHDO_getGroupMembers(tModelId, aPanelNum, tModelIndex);
	end

	return tMemberNum;

end



--
local tConfig;
local tNumButtons;
local tTotalPositionButtons;
local tModelArray;
local tGroupArray;
local tInitSafetyFactor;
local tPositionSafetyFactor;
local tTotalExpectedTime;
local tTotalButtons;
local tPanelRedrawSafetyFactor;
local tIsForceEmpty;
local tVisibleButtons;
local tIsSolo;
local tVisibleUnits;
function VUHDO_calculateSemaphoreTimeouts()

	tConfig = VUHDO_getSemaphoreConfig();

	tVisibleButtons = 0;
	tVisibleUnits = 0;
	tIsSolo = true;

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		if VUHDO_isPanelPopulated(tPanelNum) then
			if not sPanelConfig[tPanelNum] then
				VUHDO_initLocalVars(tPanelNum);
			end

			tNumButtons = VUHDO_getNumButtonsPanel(tPanelNum);
			tTotalPositionButtons = 0;
			tModelArray = VUHDO_getDynamicModelArray(tPanelNum);

			for tModelIndex, tModelId in ipairs(tModelArray) do
				tGroupArray = VUHDO_getGroupMembersSorted(tModelId, sPanelConfig[tPanelNum]["sortCriterion"], tPanelNum, tModelIndex);
				tTotalPositionButtons = tTotalPositionButtons + #tGroupArray;
			end

			if tNumButtons <= 1 then
				tInitSafetyFactor = tConfig["SOLO_INIT_SAFETY"];
			elseif tNumButtons <= tConfig["PARTY_THRESHOLD"] then
				tInitSafetyFactor = tConfig["PARTY_INIT_SAFETY"];
			elseif tNumButtons <= tConfig["SMALL_RAID_THRESHOLD"] then
				tInitSafetyFactor = tConfig["SMALL_RAID_INIT_SAFETY"];
			elseif tNumButtons <= tConfig["MEDIUM_RAID_THRESHOLD"] then
				tInitSafetyFactor = tConfig["MEDIUM_RAID_INIT_SAFETY"];
			else
				tInitSafetyFactor = tConfig["BUTTON_INIT_SAFETY_FACTOR"];
			end

			if tTotalPositionButtons <= 1 then
				tPositionSafetyFactor = tConfig["SOLO_POSITION_SAFETY"];
			elseif tTotalPositionButtons <= tConfig["PARTY_THRESHOLD"] then
				tPositionSafetyFactor = tConfig["PARTY_POSITION_SAFETY"];
			elseif tTotalPositionButtons <= tConfig["SMALL_RAID_THRESHOLD"] then
				tPositionSafetyFactor = tConfig["SMALL_RAID_POSITION_SAFETY"];
			elseif tTotalPositionButtons <= tConfig["MEDIUM_RAID_THRESHOLD"] then
				tPositionSafetyFactor = tConfig["MEDIUM_RAID_POSITION_SAFETY"];
			else
				tPositionSafetyFactor = tConfig["BUTTON_POSITION_SAFETY_FACTOR"];
			end

			sButtonInitTimeouts[tPanelNum] = math.max(tConfig["MIN_TIMEOUT_MS"], math.ceil(tNumButtons * tConfig["BUTTON_INIT_TIME_US"] * tInitSafetyFactor / 1000));
			sButtonPositionTimeouts[tPanelNum] = math.max(tConfig["MIN_TIMEOUT_MS"], math.ceil(tTotalPositionButtons * tConfig["BUTTON_POSITION_TIME_MS"] * tPositionSafetyFactor));

			if VUHDO_isPanelVisible(tPanelNum) then
				tIsForceEmpty = VUHDO_CONFIG["HIDE_EMPTY_PANELS"] and not VUHDO_isConfigPanelShowing() and #VUHDO_PANEL_UNITS[tPanelNum] == 0;

				if not tIsForceEmpty then
					tVisibleButtons = tVisibleButtons + tNumButtons;
					tVisibleUnits = tVisibleUnits + #VUHDO_PANEL_UNITS[tPanelNum];
				end
			end

			if tNumButtons > 5 then
				tIsSolo = false;
			end
		else
			sButtonInitTimeouts[tPanelNum] = tConfig["MIN_TIMEOUT_MS"];
			sButtonPositionTimeouts[tPanelNum] = tConfig["MIN_TIMEOUT_MS"];
		end
	end

	tTotalExpectedTime = 0;
	tTotalButtons = 0;

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		tTotalExpectedTime = tTotalExpectedTime + sButtonInitTimeouts[tPanelNum] + sButtonPositionTimeouts[tPanelNum];
	end

	tTotalButtons = tVisibleButtons;

	if tIsSolo and tVisibleButtons <= 5 and tVisibleUnits <= 3 then
		tPanelRedrawSafetyFactor = tConfig["SOLO_PANEL_SAFETY"];
	elseif tTotalButtons <= 1 then
		tPanelRedrawSafetyFactor = tConfig["SOLO_PANEL_SAFETY"];
	elseif tTotalButtons <= tConfig["PARTY_THRESHOLD"] then
		tPanelRedrawSafetyFactor = tConfig["PARTY_PANEL_SAFETY"];
	elseif tTotalButtons <= tConfig["SMALL_RAID_THRESHOLD"] then
		tPanelRedrawSafetyFactor = tConfig["SMALL_RAID_PANEL_SAFETY"];
	elseif tTotalButtons <= tConfig["MEDIUM_RAID_THRESHOLD"] then
		tPanelRedrawSafetyFactor = tConfig["MEDIUM_RAID_PANEL_SAFETY"];
	else
		tPanelRedrawSafetyFactor = tConfig["PANEL_REDRAW_SAFETY_FACTOR"] * tConfig["LARGE_RAID_PANEL_MULTIPLIER"];
	end

	sPanelRedrawTimeout = math.max(1, math.ceil(tTotalExpectedTime * tPanelRedrawSafetyFactor));

	return;

end



--
function VUHDO_getSemaphoreConfig()

	return VUHDO_SEMAPHORE_CONFIG;

end



--
function VUHDO_invalidateSemaphoreTimeouts()

	twipe(sButtonInitTimeouts);
	twipe(sButtonPositionTimeouts);
	sPanelRedrawTimeout = 0;

	VUHDO_calculateSemaphoreTimeouts();

	return;

end



--
local tBackdrop;
local tWidth;
local tGap;
local function VUHDO_initPlayerTargetBorder(aButton, aBorderFrame, anIsNoIndicator, aPanelNum)

	if VUHDO_INDICATOR_CONFIG[aPanelNum]["BOUQUETS"]["BAR_BORDER"] == "" then
		VUHDO_PixelUtil.Hide(aBorderFrame);
		VUHDO_PixelUtil.ClearAllPoints(aBorderFrame);

		return;
	end

	tWidth = VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["BAR_BORDER"]["WIDTH"];
	tGap = tWidth + VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["BAR_BORDER"]["ADJUST"];
	VUHDO_PixelUtil.SetPoint(aBorderFrame, "TOPLEFT", aButton:GetName(), "TOPLEFT", -tGap, tGap);
	VUHDO_PixelUtil.SetPoint(aBorderFrame, "BOTTOMRIGHT", aButton:GetName(), "BOTTOMRIGHT", tGap, -tGap);

	tBackdrop = aBorderFrame:GetBackdrop() or {};
	tBackdrop["edgeSize"] = tWidth;
	tBackdrop["edgeFile"] = VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["BAR_BORDER"]["FILE"];
	tBackdrop["insets"] = tBackdrop["insets"] or {};
	tBackdrop["insets"]["left"] = tWidth;
	tBackdrop["insets"]["right"] = tWidth;
	tBackdrop["insets"]["top"] = tWidth;
	tBackdrop["insets"]["bottom"] = tWidth;

	aBorderFrame.backdropInfo = tBackdrop;
	VUHDO_PixelUtil.ApplyBackdrop(aBorderFrame, tBackdrop);

	aBorderFrame.backdropBorderColor = VUHDO_getOrCreateCachedColor(0, 0, 0);
	aBorderFrame.backdropBorderColorAlpha = 1;
	aBorderFrame:SetBackdropBorderColor(0, 0, 0, 1);

	aBorderFrame:SetShown(anIsNoIndicator);

	return;

end



--
local tBackdropCluster;
local tClusterFrame;
local function VUHDO_initClusterBorder(aButton, aPanelNum)

	tClusterFrame = VUHDO_getClusterBorderFrame(aButton);
	VUHDO_PixelUtil.Hide(tClusterFrame);

	if VUHDO_INDICATOR_CONFIG[aPanelNum]["BOUQUETS"]["CLUSTER_BORDER"] == "" then
		tClusterFrame:ClearAllPoints();

		return;
	end

	tClusterFrame:ClearAllPoints();

	VUHDO_PixelUtil.SetPoint(tClusterFrame, "TOPLEFT", aButton:GetName(), "TOPLEFT", 0, 0);
	VUHDO_PixelUtil.SetPoint(tClusterFrame, "BOTTOMRIGHT", aButton:GetName(), "BOTTOMRIGHT", 0, 0);
	
	tBackdropCluster = tClusterFrame:GetBackdrop() or {};

	tBackdropCluster["edgeSize"] = VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["CLUSTER_BORDER"]["WIDTH"];
	tBackdropCluster["edgeFile"] = VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["CLUSTER_BORDER"]["FILE"];
	tBackdropCluster["insets"] = tBackdropCluster["insets"] or {};
	tBackdropCluster["insets"]["left"] = 0;
	tBackdropCluster["insets"]["right"] = 0;
	tBackdropCluster["insets"]["top"] = 0;
	tBackdropCluster["insets"]["bottom"] = 0;
	
	tClusterFrame.backdropInfo = tBackdropCluster;
	VUHDO_PixelUtil.ApplyBackdrop(tClusterFrame, tBackdropCluster);

	tClusterFrame.backdropBorderColor = VUHDO_getOrCreateCachedColor(0, 0, 0);
	tClusterFrame.backdropBorderColorAlpha = 0;
	tClusterFrame:SetBackdropBorderColor(0, 0, 0, 0);

	return;

end



--
function VUHDO_positionHealButton(aButton, aPanelNum, aBarScaling)

	VUHDO_PixelUtil.SetWidth(aButton, (aBarScaling or sPanelConfig[aPanelNum]["barScaling"])["barWidth"]);
	VUHDO_PixelUtil.SetHeight(aButton, (aBarScaling or sPanelConfig[aPanelNum]["barScaling"])["barHeight"]);

	-- Player Target
	VUHDO_initPlayerTargetBorder(aButton, VUHDO_getPlayerTargetFrame(aButton), false, aPanelNum);
	VUHDO_initPlayerTargetBorder(VUHDO_getTargetButton(aButton), VUHDO_getPlayerTargetFrameTarget(aButton), true, aPanelNum);
	VUHDO_initPlayerTargetBorder(VUHDO_getTotButton(aButton), VUHDO_getPlayerTargetFrameToT(aButton), true, aPanelNum);

	-- Cluster indicator
	VUHDO_initClusterBorder(aButton, aPanelNum);

	return;

end



--
local function VUHDO_initHealthBar(aButton, aPanelNum)

	VUHDO_PixelUtil.SetPoint(sHealthBar, "TOPLEFT", VUHDO_getHealthBar(aButton, 6):GetName(), "TOPLEFT", 0, 0); -- incoming bar
	VUHDO_PixelUtil.SetSize(sHealthBar, sPanelConfig[aPanelNum]["barWidth"], sPanelConfig[aPanelNum]["barHeight"]);

	return;

end



--
local tFrame;
local function VUHDO_registerFacadeIcon(aButton, aNum, aGroup)
	tFrame = VUHDO_getBarIconFrame(aButton, aNum);
	if tFrame then
		VUHDO_getBarIcon(aButton, aNum):SetTexCoord(0, 1, 0, 1);
		VUHDO_LibButtonFacade:Group("VuhDo", aGroup):AddButton(tFrame, {
			["Icon"] = VUHDO_getBarIcon(aButton, aNum),
		});
	end
end



--
local tLeft;
local tRight;
local tTop;
local tBottom;
local tIcon;
local function VUHDO_initButtonButtonFacade(aButton)

	for tCnt = 1, 5 do
		VUHDO_registerFacadeIcon(aButton, tCnt, VUHDO_I18N_HOTS);
	end

	for tCnt = 9, 12 do -- VUHDO_MAX_HOTS
		VUHDO_registerFacadeIcon(aButton, tCnt, VUHDO_I18N_HOTS);
	end

	tIcon = VUHDO_getBarIcon(aButton, 1);

	if tIcon then
		tLeft, tTop, _, _, _, _, tRight, tBottom = tIcon:GetTexCoord();

		VUHDO_hotsSetClippings(tLeft, tRight, tTop, tBottom);
	end

	return;

end



--
local tXPos;
local tYPos;
local tHealButton;
local tGroupArray;
local tColumnIndex;
local tButtonIndex;
local tModelArray;
local tPanelName;
local function VUHDO_positionAllHealButtons(aPanel, aPanelNum)

	tModelArray = VUHDO_getDynamicModelArray(aPanelNum);
	tPanelName  = aPanel:GetName();

	tColumnIndex = 1;
	tButtonIndex = 1;

	for tModelIndex,  tModelId  in ipairs(tModelArray)  do
		tGroupArray = VUHDO_getGroupMembersSorted(tModelId, sPanelConfig[aPanelNum]["sortCriterion"], aPanelNum, tModelIndex);

		for tGroupIndex, tUnit  in ipairs(tGroupArray)  do
			tHealButton = VUHDO_getHealButton(tButtonIndex, aPanelNum);

			tButtonIndex = tButtonIndex  + 1;
			VUHDO_positionHealButton(tHealButton, aPanelNum);

			VUHDO_setupAllHealButtonAttributes(tHealButton, tUnit, false, 70 == tModelId, false, false); -- VUHDO_ID_VEHICLES

			if VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["showTarget"] then
				VUHDO_setupAllTargetButtonAttributes(VUHDO_getTargetButton(tHealButton), tUnit);
			end

			if VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["showTot"] then
				VUHDO_setupAllTotButtonAttributes(VUHDO_getTotButton(tHealButton), tUnit);
			end

			tXPos, tYPos = VUHDO_getHealButtonPos(tColumnIndex, tGroupIndex, aPanelNum);
			VUHDO_PixelUtil.Hide(tHealButton);
			VUHDO_PixelUtil.ClearAllPoints(tHealButton);
			VUHDO_PixelUtil.SetPoint(tHealButton, "TOPLEFT", tPanelName, "TOPLEFT", tXPos, -tYPos);
			VUHDO_addUnitButton(tHealButton, aPanelNum);
			VUHDO_PixelUtil.Show(tHealButton);
		end

		tColumnIndex = tColumnIndex + 1;
	end

	return;

end



--
function VUHDO_deferRedrawAllPanelsComplete(anIsFixAllFrameLevels)

	VUHDO_deferTask(VUHDO_DEFER_REDRAW_ALL_PANELS_COMPLETE, VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, anIsFixAllFrameLevels);

	return;

end



--
local function VUHDO_initAggroTexture(aButton, aHealthBar)

	VUHDO_PixelUtil.Hide(VUHDO_getAggroTexture(aHealthBar));

	return;

end



--
local tUnit;
local tInfo;
local tManaHeight;
local tIsManaBouquet;
local function VUHDO_initManaBar(aButton, aManaBar, aWidth, anIsForceBar, aPanelNum)

	tIsManaBouquet = sIsManaBouquet[aPanelNum];

	VUHDO_PixelUtil.SetPoint(aManaBar, "BOTTOMLEFT", aButton:GetName(), "BOTTOMLEFT", 0, 0);
	VUHDO_setLlcStatusBarTexture(aManaBar, VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["MANA_BAR"]["TEXTURE"]);

	tUnit = aButton["raidid"];
	tInfo = VUHDO_RAID[tUnit];

	tManaHeight = (anIsForceBar or not tInfo or tIsManaBouquet) and sPanelConfig[aPanelNum]["manaBarHeight"] or 0;

	VUHDO_PixelUtil.SetWidth(aManaBar, aWidth);
	aButton["regularHeight"] = sPanelConfig[aPanelNum]["barScaling"]["barHeight"];

	if tIsManaBouquet then
		VUHDO_PixelUtil.Show(aManaBar);
		VUHDO_PixelUtil.SetHeight(aManaBar, tManaHeight);

		if (VUHDO_getHealthBar(aButton, 1):GetHeight() == 0) then
			VUHDO_PixelUtil.SetHeight(VUHDO_getHealthBar(aButton, 1), sPanelConfig[aPanelNum]["barHeight"]);
		end
	else
		VUHDO_PixelUtil.Hide(aManaBar);
		VUHDO_PixelUtil.SetHeight(VUHDO_getHealthBar(aButton, 1), sPanelConfig[aPanelNum]["barHeight"] + sPanelConfig[aPanelNum]["manaBarHeight"]);
	end

	if not anIsForceBar then
		VUHDO_customizeIconText(aManaBar, 32, VUHDO_getHealthBarText(aButton, 2),
			VUHDO_INDICATOR_CONFIG[aPanelNum]["TEXT_INDICATORS"]["MANA_BAR"]["TEXT"]);
	end

	return;

end



--
local function VUHDO_initBackgroundBar(aBgBar, aPanelNum)

	VUHDO_setLlcStatusBarTexture(aBgBar, sPanelConfig[aPanelNum]["indicatorConfig"]["CUSTOM"]["BACKGROUND_BAR"]["TEXTURE"]);

	VUHDO_PixelUtil.SetHeight(aBgBar, sPanelConfig[aPanelNum]["barScaling"]["barHeight"]);
	aBgBar:SetValue(1);
	aBgBar:SetStatusBarColor(0, 0, 0, 0);

	VUHDO_PixelUtil.Show(aBgBar);

	return;

end



--
local function VUHDO_initIncomingOrShieldBar(aButton, aBarNum, aPanelNum)

	tBar = VUHDO_getHealthBar(aButton, aBarNum);

	VUHDO_PixelUtil.SetPoint(tBar, "TOPLEFT", VUHDO_getHealthBar(aButton, 3):GetName(), "TOPLEFT", sPanelConfig[aPanelNum]["sideBarLeftWidth"], 0); -- Background bar
	VUHDO_PixelUtil.SetSize(tBar, sPanelConfig[aPanelNum]["barWidth"], sPanelConfig[aPanelNum]["barHeight"]);
	tBar:SetValueRange(0, 0);

	return;

end



--
local tThreatBar;
local function VUHDO_initThreatBar(aButton, aPanelNum)

	tThreatBar = VUHDO_getHealthBar(aButton, 7);

	if sPanelConfig[aPanelNum]["indicatorConfig"]["BOUQUETS"]["THREAT_BAR"] == "" then
		VUHDO_PixelUtil.Hide(tThreatBar);
	else
		VUHDO_PixelUtil.Show(tThreatBar);

		VUHDO_setLlcStatusBarTexture(tThreatBar, sPanelConfig[aPanelNum]["indicatorConfig"]["CUSTOM"]["THREAT_BAR"]["TEXTURE"]);

		tThreatBar:SetStatusBarColor(0, 0, 0, 0);
		VUHDO_PixelUtil.SetHeight(tThreatBar, sPanelConfig[aPanelNum]["indicatorConfig"]["CUSTOM"]["THREAT_BAR"]["HEIGHT"]);
	end

	VUHDO_customizeIconText(tThreatBar, 32, VUHDO_getHealthBarText(aButton, 7),
	sPanelConfig[aPanelNum]["indicatorConfig"]["TEXT_INDICATORS"]["THREAT_BAR"]["TEXT"]);

	return;

end



--
local tTextPanel;
local tNameText;
local tLifeText;
local tAddHeight;
local tAnchorObject;
local function VUHDO_initBarTexts(aButton, aHealthBar, aWidth, aPanelNum)

	tTextPanel  = VUHDO_getTextPanel(aHealthBar);
	tNameText = VUHDO_getBarText(aHealthBar);
	tLifeText = VUHDO_getLifeText(aHealthBar);

	VUHDO_PixelUtil.SetWidth(tNameText, aWidth);
	VUHDO_PixelUtil.SetHeight(tNameText, sPanelConfig[aPanelNum]["mainFontHeight"]);
	tNameText:SetFont(sPanelConfig[aPanelNum]["mainFont"], sPanelConfig[aPanelNum]["mainFontHeight"], sPanelConfig[aPanelNum]["outlineText"] or "");
	tNameText:SetShadowColor(0, 0, 0, sPanelConfig[aPanelNum]["shadowAlpha"]);

	tLifeText:SetFont(sPanelConfig[aPanelNum]["mainFont"], sPanelConfig[aPanelNum]["lifeFontHeight"], sPanelConfig[aPanelNum]["outlineText"] or "");
	tLifeText:SetShadowColor(0, 0, 0, sPanelConfig[aPanelNum]["shadowAlpha"]);
	tLifeText:SetText("");

	VUHDO_PixelUtil.ClearAllPoints(tNameText);
	tAddHeight = 0;

	if VUHDO_LT_POS_RIGHT == sPanelConfig[aPanelNum]["lifeText"]["position"]
		or VUHDO_LT_POS_LEFT == sPanelConfig[aPanelNum]["lifeText"]["position"]
		or (not sPanelConfig[aPanelNum]["lifeText"]["show"] and not sPanelConfig[aPanelNum]["panelSetup"]["ID_TEXT"]["showTags"]) then

		VUHDO_PixelUtil.SetWidth(tLifeText, 0);
		VUHDO_PixelUtil.SetHeight(tLifeText, 0);
		VUHDO_PixelUtil.SetPoint(tNameText, "CENTER", tTextPanel:GetName(), "CENTER", 0, 0);

		VUHDO_PixelUtil.Hide(tLifeText);
	else
		VUHDO_PixelUtil.ClearAllPoints(tLifeText);

		VUHDO_PixelUtil.SetWidth(tLifeText, aWidth);
		VUHDO_PixelUtil.SetHeight(tLifeText, sPanelConfig[aPanelNum]["lifeFontHeight"]);

		tAddHeight = sPanelConfig[aPanelNum]["lifeFontHeight"];

		if (VUHDO_LT_POS_BELOW == sPanelConfig[aPanelNum]["lifeText"]["position"]) then
			VUHDO_PixelUtil.SetPoint(tNameText, "TOP", tTextPanel:GetName(), "TOP", 0, 0);
			VUHDO_PixelUtil.SetPoint(tLifeText, "TOP", tNameText:GetName(), "BOTTOM", 0, 0);
		else
			VUHDO_PixelUtil.SetPoint(tNameText, "BOTTOM", tTextPanel:GetName(), "BOTTOM", 0, 0);
			VUHDO_PixelUtil.SetPoint(tLifeText, "BOTTOM", tNameText:GetName(), "TOP", 0, 0);
		end

		VUHDO_PixelUtil.Show(tLifeText);
	end

	VUHDO_PixelUtil.SetHeight(tTextPanel, tNameText:GetHeight() + tAddHeight);
	VUHDO_PixelUtil.SetWidth(tTextPanel, aWidth);

	sPanelConfig[aPanelNum]["panelSetup"]["ID_TEXT"]["_spacing"] = tTextPanel:GetHeight(); -- internal marker

	if strfind(sPanelConfig[aPanelNum]["textAnchors"][1], "LEFT", 1, true) then
		tNameText:SetJustifyH("LEFT");
		tLifeText:SetJustifyH("LEFT");
	elseif strfind(sPanelConfig[aPanelNum]["textAnchors"][1], "RIGHT", 1, true) then
		tNameText:SetJustifyH("RIGHT");
		tLifeText:SetJustifyH("RIGHT");
	else
		tNameText:SetJustifyH("CENTER");
		tLifeText:SetJustifyH("CENTER");
	end

	if strfind(sPanelConfig[aPanelNum]["textAnchors"][1], "BOTTOM", 1, true) and strfind(sPanelConfig[aPanelNum]["textAnchors"][2], "TOP", 1, true) -- �ber Button
		and sPanelConfig[aPanelNum]["indicatorConfig"]["BOUQUETS"]["THREAT_BAR"] ~= "" then
		tAnchorObject = VUHDO_getHealthBar(aButton, 7) or aButton; -- Target und Tot hat keinen Threat bar
	elseif strfind(sPanelConfig[aPanelNum]["textAnchors"][2], "BOTTOM", 1, true) and strfind(sPanelConfig[aPanelNum]["textAnchors"][1], "TOP", 1, true) then
		tAnchorObject = aButton;
	else
		tAnchorObject = aHealthBar;
	end

	VUHDO_PixelUtil.ClearAllPoints(tTextPanel);

	VUHDO_PixelUtil.SetPoint(tTextPanel, sPanelConfig[aPanelNum]["textAnchors"][1], tAnchorObject:GetName(), sPanelConfig[aPanelNum]["textAnchors"][2], sPanelConfig[aPanelNum]["panelSetup"]["ID_TEXT"]["xAdjust"], -sPanelConfig[aPanelNum]["panelSetup"]["ID_TEXT"]["yAdjust"]);

	return;

end



--
local tOvhColor;
local tOvhText;
local tOvhPanel;
local tX;
local tY;
local function VUHDO_initOverhealText(aHealthBar, aWidth, aPanelNum)

	tOvhText = VUHDO_getOverhealText(aHealthBar);

	VUHDO_PixelUtil.SetWidth(tOvhText, 400);
	VUHDO_PixelUtil.SetHeight(tOvhText, sPanelConfig[aPanelNum]["mainFontHeight"]);

	if not sPanelConfig[aPanelNum] then
		return;
	end

	if not sPanelConfig[aPanelNum]["panelSetup"] then
		return;
	end

	tOvhColor = VUHDO_PANEL_SETUP["BAR_COLORS"]["OVERHEAL_TEXT"];

	tOvhText:SetTextColor(tOvhColor["TR"], tOvhColor["TG"], tOvhColor["TB"], tOvhColor["TO"]);
	tOvhText:SetFont(sPanelConfig[aPanelNum]["mainFont"], sPanelConfig[aPanelNum]["mainFontHeight"], "");
	tOvhText:SetJustifyH("CENTER");
	tOvhText:SetText("");

	tOvhPanel = VUHDO_getOverhealPanel(aHealthBar);

	VUHDO_PixelUtil.SetSize(tOvhPanel, 1, 1);
	VUHDO_PixelUtil.SetScale(tOvhPanel, 1);

	tX = sPanelConfig[aPanelNum]["overhealText"]["xAdjust"] * aWidth * 0.01;
	tY = -sPanelConfig[aPanelNum]["overhealText"]["yAdjust"] * sPanelConfig[aPanelNum]["barScaling"]["barHeight"] * 0.01;
	tOvhPanel:ClearAllPoints();
	VUHDO_PixelUtil.SetPoint(tOvhPanel, sPanelConfig[aPanelNum]["overhealText"]["point"], aHealthBar:GetName(), sPanelConfig[aPanelNum]["overhealText"]["point"], tX, tY);

	return;

end



--
local tAggroBar;
local function VUHDO_initAggroBar(aButton, aHealthBar, aPanelNum)

	tAggroBar = VUHDO_getHealthBar(aButton, 4);

	if sPanelConfig[aPanelNum]["indicatorConfig"]["BOUQUETS"]["AGGRO_BAR"] == "" then
		VUHDO_PixelUtil.ClearAllPoints(tAggroBar);
		VUHDO_PixelUtil.Hide(tAggroBar);

		return;
	end

	VUHDO_setLlcStatusBarTexture(tAggroBar, sPanelConfig[aPanelNum]["indicatorConfig"]["CUSTOM"]["AGGRO_BAR"]["TEXTURE"]);

	VUHDO_PixelUtil.SetPoint(tAggroBar, "BOTTOM", aHealthBar:GetName(), "TOP", 0, 0);
	VUHDO_PixelUtil.SetSize(tAggroBar, sPanelConfig[aPanelNum]["barScaling"]["barWidth"], sPanelConfig[aPanelNum]["barScaling"]["rowSpacing"]);

	VUHDO_PixelUtil.Show(tAggroBar);

	tAggroBar:SetValue(0);

	return;

end



--
local tPrivateAura;
local tX;
local function VUHDO_initPrivateAura(aHealthBar, aButton, anAuraIndex, aPanelNum)

	tPrivateAura = VUHDO_getBarPrivateAura(aButton, anAuraIndex);

	if not tPrivateAura then
		return;
	end

	VUHDO_PixelUtil.Hide(tPrivateAura);
	VUHDO_PixelUtil.ClearAllPoints(tPrivateAura);
	VUHDO_PixelUtil.SetFrameStrata(tPrivateAura, aHealthBar:GetFrameStrata());
	VUHDO_PixelUtil.SetFrameLevel(tPrivateAura, aHealthBar:GetFrameLevel() + 2);

	tX = sPanelConfig[aPanelNum]["privateAuraXOffset"] + (sPanelConfig[aPanelNum]["privateAuraStep"] * (anAuraIndex - 1));
	VUHDO_PixelUtil.SetPoint(tPrivateAura, sPanelConfig[aPanelNum]["privateAura"]["point"], aHealthBar:GetName(), sPanelConfig[aPanelNum]["privateAura"]["point"], tX, sPanelConfig[aPanelNum]["privateAuraYOffset"]);

	VUHDO_PixelUtil.SetSize(tPrivateAura, sPanelConfig[aPanelNum]["privateAuraHeight"], sPanelConfig[aPanelNum]["privateAuraHeight"]);
	VUHDO_PixelUtil.SetScale(tPrivateAura, sPanelConfig[aPanelNum]["privateAura"]["scale"] * 0.7);

	return;

end



--
local function VUHDO_initPrivateAuras(aHealthBar, aButton, aPanelNum)

	for tAuraIndex = 1, VUHDO_MAX_PRIVATE_AURAS do
		VUHDO_initPrivateAura(aHealthBar, aButton, tAuraIndex, aPanelNum);
	end

	return;

end



--
local tX;
local tY;
local function VUHDO_initRaidIcon(aHealthBar, anIcon, aWidth, aPanelNum)

	tX = sPanelConfig[aPanelNum]["raidIcon"]["xAdjust"] * aWidth * 0.01;
	tY = -sPanelConfig[aPanelNum]["raidIcon"]["yAdjust"] * sPanelConfig[aPanelNum]["barScaling"]["barHeight"] * 0.01;

	VUHDO_PixelUtil.Hide(anIcon);
	VUHDO_PixelUtil.ClearAllPoints(anIcon);

	VUHDO_PixelUtil.SetPoint(anIcon, sPanelConfig[aPanelNum]["raidIcon"]["point"], aHealthBar:GetName(), sPanelConfig[aPanelNum]["raidIcon"]["point"], tX, tY);
	VUHDO_PixelUtil.SetSize(anIcon, sPanelConfig[aPanelNum]["barScaling"]["barHeight"] * sPanelConfig[aPanelNum]["raidIcon"]["scale"] / 1.5, sPanelConfig[aPanelNum]["barScaling"]["barHeight"] * sPanelConfig[aPanelNum]["raidIcon"]["scale"] / 1.5);

	return;

end



--
local tIcon;
local tX;
local tY;
local tHeight;
local function VUHDO_initSwiftmendIndicator(aButton, aHealthBar, aPanelNum)

	tIcon = VUHDO_getBarRoleIcon(aButton, 51);

	VUHDO_PixelUtil.ClearAllPoints(tIcon);
	VUHDO_PixelUtil.Hide(tIcon);

	if sPanelConfig[aPanelNum]["indicatorConfig"]["BOUQUETS"]["SWIFTMEND_INDICATOR"] == "" then
		return;
	end

	tX = sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["xAdjust"] * sPanelConfig[aPanelNum]["barScaling"]["barWidth"] * 0.01;
	tY = -sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["yAdjust"] * sPanelConfig[aPanelNum]["barScaling"]["barHeight"] * 0.01;
	VUHDO_PixelUtil.SetPoint(tIcon, sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["anchor"], aHealthBar:GetName(), sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["anchor"], tX, tY);

	tHeight = 50 * sPanelConfig[aPanelNum]["swiftmendIndicatorSetup"]["SCALE"];
	VUHDO_PixelUtil.SetSizeFromPercentage(tIcon, sPanelConfig[aPanelNum]["barScaling"]["barHeight"], sPanelConfig[aPanelNum]["barScaling"]["barHeight"], tHeight, tHeight);

	return;

end



--
local tTgButton;
local tTgHealthBar;
local function VUHDO_initTargetBar(aButton, aPanelNum)

	if sPanelConfig[aPanelNum]["barScaling"]["showTarget"] then
		tTgButton = VUHDO_getTargetButton(aButton);

		tTgButton:SetAlpha(0);
		tTgButton:ClearAllPoints();

		if sPanelConfig[aPanelNum]["barScaling"]["targetOrientation"] == 1 then
			VUHDO_PixelUtil.SetPoint(tTgButton, "TOPLEFT", aButton:GetName(), "TOPRIGHT", sPanelConfig[aPanelNum]["barScaling"]["targetSpacing"], 0);
		else
			VUHDO_PixelUtil.SetPoint(tTgButton, "TOPRIGHT", aButton:GetName(), "TOPLEFT", -sPanelConfig[aPanelNum]["barScaling"]["targetSpacing"], 0);
		end

		VUHDO_PixelUtil.SetSize(tTgButton, sPanelConfig[aPanelNum]["barScaling"]["targetWidth"], sPanelConfig[aPanelNum]["barScaling"]["barHeight"]);

		VUHDO_PixelUtil.Show(tTgButton);

		tTgHealthBar = VUHDO_getHealthBar(aButton, 5);
		tTgHealthBar:SetValue(1);
		VUHDO_PixelUtil.SetHeight(tTgHealthBar, sPanelConfig[aPanelNum]["barHeight"]);

		VUHDO_initBackgroundBar(VUHDO_getHealthBar(aButton, 12), aPanelNum);
		VUHDO_initManaBar(tTgButton, VUHDO_getHealthBar(aButton, 13), sPanelConfig[aPanelNum]["barScaling"]["targetWidth"], true, aPanelNum);
		VUHDO_initRaidIcon(tTgHealthBar, VUHDO_getTargetBarRoleIcon(tTgButton, 50), sPanelConfig[aPanelNum]["barScaling"]["targetWidth"], aPanelNum);
		VUHDO_initBarTexts(tTgButton, tTgHealthBar, sPanelConfig[aPanelNum]["barScaling"]["targetWidth"], aPanelNum);
		VUHDO_initOverhealText(tTgHealthBar, sPanelConfig[aPanelNum]["barScaling"]["targetWidth"], aPanelNum);

		if sPanelConfig[aPanelNum]["indicatorConfig"]["BOUQUETS"]["BACKGROUND_BAR"] ~= "" then
			VUHDO_getHealthBar(tTgButton, 3):SetStatusBarColor(0, 0, 0, 0.4);
		else
			VUHDO_getHealthBar(tTgButton, 3):SetStatusBarColor(0, 0, 0, 0);
		end
	else
		VUHDO_PixelUtil.Hide(VUHDO_getTargetButton(aButton));
	end

	return;

end



--
local tTotButton;
local tTgHealthBar;
local function VUHDO_initTotBar(aButton, aHealthBar, aPanelNum)

	if sPanelConfig[aPanelNum]["barScaling"]["showTot"] then
		tTotButton  = VUHDO_getTotButton(aButton);

		tTotButton:SetAlpha(0);
		tTotButton:ClearAllPoints();

		if sPanelConfig[aPanelNum]["barScaling"]["targetOrientation"] == 1 then
			if sPanelConfig[aPanelNum]["barScaling"]["showTarget"] then
				tTgButton = VUHDO_getTargetButton(aButton);
				VUHDO_PixelUtil.SetPoint(tTotButton, "TOPLEFT", tTgButton:GetName(), "TOPRIGHT", sPanelConfig[aPanelNum]["barScaling"]["totSpacing"], 0);
			else
				VUHDO_PixelUtil.SetPoint(tTotButton, "TOPLEFT", aHealthBar:GetName(), "TOPRIGHT", sPanelConfig[aPanelNum]["barScaling"]["totSpacing"], 0);
			end
		else
			if sPanelConfig[aPanelNum]["barScaling"]["showTarget"] then
				tTgButton = VUHDO_getTargetButton(aButton);
				VUHDO_PixelUtil.SetPoint(tTotButton, "TOPRIGHT", tTgButton:GetName(), "TOPLEFT", -sPanelConfig[aPanelNum]["barScaling"]["totSpacing"], 0);
			else
				VUHDO_PixelUtil.SetPoint(tTotButton, "TOPRIGHT", aHealthBar:GetName(), "TOPLEFT", -sPanelConfig[aPanelNum]["barScaling"]["totSpacing"], 0);
			end
		end

		VUHDO_PixelUtil.SetSize(tTotButton, sPanelConfig[aPanelNum]["barScaling"]["totWidth"], sPanelConfig[aPanelNum]["barScaling"]["barHeight"]);

		VUHDO_PixelUtil.Show(tTotButton);

		tTgHealthBar = VUHDO_getHealthBar(aButton, 14);
		tTgHealthBar:SetValue(1);
		VUHDO_PixelUtil.SetHeight(tTgHealthBar, sPanelConfig[aPanelNum]["barHeight"]);

		VUHDO_initBackgroundBar(VUHDO_getHealthBar(aButton, 15), aPanelNum);
		VUHDO_initManaBar(tTotButton, VUHDO_getHealthBar(aButton, 16), sPanelConfig[aPanelNum]["barScaling"]["totWidth"], true, aPanelNum);
		VUHDO_initRaidIcon(tTgHealthBar, VUHDO_getTargetBarRoleIcon(tTotButton, 50), sPanelConfig[aPanelNum]["barScaling"]["totWidth"], aPanelNum);
		VUHDO_initBarTexts(tTgButton, tTgHealthBar, sPanelConfig[aPanelNum]["barScaling"]["totWidth"], aPanelNum);
		VUHDO_initOverhealText(tTgHealthBar, sPanelConfig[aPanelNum]["barScaling"]["totWidth"], aPanelNum);

		if sPanelConfig[aPanelNum]["indicatorConfig"]["BOUQUETS"]["BACKGROUND_BAR"] ~= "" then
			VUHDO_getHealthBar(tTotButton, 3):SetStatusBarColor(0, 0, 0, 0.4);
		else
			VUHDO_getHealthBar(tTotButton, 3):SetStatusBarColor(0, 0, 0, 0);
		end
	else
		VUHDO_PixelUtil.Hide(VUHDO_getTotButton(aButton));
	end

	return;

end



--
local tBar;
local function VUHDO_initFlashBar(aButton)

	tBar = _G[aButton:GetName() .. "BgBarIcBarHlBarFlBar"];

	tBar:SetStatusBarTexture("Interface\\AddOns\\VuhDo\\Images\\white_square_16_16");
	VUHDO_PixelUtil.ApplySettings(tBar:GetStatusBarTexture());

	tBar:SetStatusBarColor(1, 0.8, 0.8, 1);
	tBar:SetAlpha(0);

	return;

end



--
local function VUHDO_initReadyCheckIcon(aButton)

	VUHDO_PixelUtil.Hide(VUHDO_getBarRoleIcon(aButton, 20));

	return;

end



--
local function VUHDO_initHighlightBar(aButton, aPanelNum)

	if sPanelConfig[aPanelNum]["indicatorConfig"]["BOUQUETS"]["MOUSEOVER_HIGHLIGHT"] == "" then
		VUHDO_PixelUtil.Hide(VUHDO_getHealthBar(aButton, 8));
	else
		tBar = VUHDO_getHealthBar(aButton, 8);

		VUHDO_setLlcStatusBarTexture(tBar, sPanelConfig[aPanelNum]["indicatorConfig"]["CUSTOM"]["MOUSEOVER_HIGHLIGHT"]["TEXTURE"]);
		tBar:SetAlpha(0);

		VUHDO_PixelUtil.Show(tBar);
	end

	return;

end



--
local function VUHDO_initSideBarLeft(aButton, aHealthBar, aPanelNum)

	tBar = VUHDO_getHealthBar(aButton, 17);

	if sPanelConfig[aPanelNum]["indicatorConfig"]["BOUQUETS"]["SIDE_LEFT"] == "" then
		VUHDO_PixelUtil.ClearAllPoints(tBar);
		VUHDO_PixelUtil.Hide(tBar);
	else
		VUHDO_PixelUtil.SetPoint(tBar, "RIGHT", aHealthBar:GetName(), "LEFT", 0, 0);
		VUHDO_PixelUtil.SetSize(tBar, sPanelConfig[aPanelNum]["sideBarLeftWidth"], sPanelConfig[aPanelNum]["barHeight"]);
		VUHDO_setLlcStatusBarTexture(tBar, sPanelConfig[aPanelNum]["indicatorConfig"]["CUSTOM"]["SIDE_LEFT"]["TEXTURE"]);

		VUHDO_PixelUtil.Show(tBar);
	end

	VUHDO_customizeIconText(tBar, 32, VUHDO_getHealthBarText(aButton, 17),
		sPanelConfig[aPanelNum]["indicatorConfig"]["TEXT_INDICATORS"]["SIDE_LEFT"]["TEXT"]);

	return;

end



--
local function VUHDO_initSideBarRight(aButton, aHealthBar, aPanelNum)

	tBar = VUHDO_getHealthBar(aButton, 18);

	if sPanelConfig[aPanelNum]["indicatorConfig"]["BOUQUETS"]["SIDE_RIGHT"] == "" then
		VUHDO_PixelUtil.ClearAllPoints(tBar);
		VUHDO_PixelUtil.Hide(tBar);
	else
		VUHDO_PixelUtil.SetPoint(tBar, "LEFT", aHealthBar:GetName(), "RIGHT", 0, 0);
		VUHDO_PixelUtil.SetSize(tBar, sPanelConfig[aPanelNum]["sideBarRightWidth"], sPanelConfig[aPanelNum]["barHeight"]);
		VUHDO_setLlcStatusBarTexture(tBar, sPanelConfig[aPanelNum]["indicatorConfig"]["CUSTOM"]["SIDE_RIGHT"]["TEXTURE"]);

		VUHDO_PixelUtil.Show(tBar);
	end

	VUHDO_customizeIconText(tBar, 32, VUHDO_getHealthBarText(aButton, 18),
		sPanelConfig[aPanelNum]["indicatorConfig"]["TEXT_INDICATORS"]["SIDE_RIGHT"]["TEXT"]);

	return;

end



--
function VUHDO_initButtonStatics(aButton, aPanelNum)

	VUHDO_initButtonStaticsHots(aButton, aPanelNum);
	VUHDO_initButtonStaticsCustomDebuffs(aButton, aPanelNum);

	sHealthBar = VUHDO_getHealthBar(aButton, 1);

	return;

end



--
function VUHDO_getStatusbarOrientationString(anIndicatorName, aPanelNum)

	if VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"][anIndicatorName]["vertical"] then
		return VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"][anIndicatorName]["turnAxis"]
			and "VERTICAL_INV" or "VERTICAL";
	else
		return VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"][anIndicatorName]["turnAxis"]
			and "HORIZONTAL_INV" or "HORIZONTAL";
	end

end



--
local tIsInverted;
local tOrientation;
local tClickPar;
function VUHDO_initHealButton(aButton, aPanelNum)

	tClickPar = VUHDO_CONFIG["ON_MOUSE_UP"] and "AnyUp" or "AnyDown";
	aButton:RegisterForClicks(tClickPar);

	-- Texture
	if sPanelConfig[aPanelNum]["statusTexture"] then
		for tCnt =  1, 19 do
			VUHDO_getHealthBar(aButton, tCnt):SetStatusBarTexture(sPanelConfig[aPanelNum]["statusTexture"]);
			VUHDO_PixelUtil.ApplySettings(VUHDO_getHealthBar(aButton, tCnt):GetStatusBarTexture());
		end
	end

	-- Invert Growth
	tIsInverted = VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["HEALTH_BAR"]["invertGrowth"];
	VUHDO_getHealthBar(aButton, 1):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 5):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 6):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 14):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 19):SetIsInverted(tIsInverted);

	tIsInverted = VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["MANA_BAR"]["invertGrowth"];
	VUHDO_getHealthBar(aButton, 2):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 13):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 16):SetIsInverted(tIsInverted);

	VUHDO_getHealthBar(aButton, 7):SetIsInverted(VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["THREAT_BAR"]["invertGrowth"]);
	VUHDO_getHealthBar(aButton, 17):SetIsInverted(VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["SIDE_LEFT"]["invertGrowth"])
	VUHDO_getHealthBar(aButton, 18):SetIsInverted(VUHDO_INDICATOR_CONFIG[aPanelNum]["CUSTOM"]["SIDE_RIGHT"]["invertGrowth"]);

	-- Orient Health
	tOrientation = VUHDO_getStatusbarOrientationString("HEALTH_BAR", aPanelNum);
	VUHDO_getHealthBar(aButton, 1):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 5):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 6):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 14):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 19):SetOrientation(tOrientation);

	-- Orient Mana
	tOrientation = VUHDO_getStatusbarOrientationString("MANA_BAR", aPanelNum);
	VUHDO_getHealthBar(aButton, 2):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 13):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 16):SetOrientation(tOrientation);

	-- Orient Threat
	VUHDO_getHealthBar(aButton, 7):SetOrientation(VUHDO_getStatusbarOrientationString("THREAT_BAR", aPanelNum));

	-- Orient side bar left
	VUHDO_getHealthBar(aButton, 17):SetOrientation(VUHDO_getStatusbarOrientationString("SIDE_LEFT", aPanelNum));

	-- Orient side bar right
	VUHDO_getHealthBar(aButton, 18):SetOrientation(VUHDO_getStatusbarOrientationString("SIDE_RIGHT", aPanelNum));

	VUHDO_initButtonStatics(aButton, aPanelNum);

	VUHDO_initBackgroundBar(VUHDO_getHealthBar(aButton, 3), aPanelNum);
	VUHDO_initIncomingOrShieldBar(aButton, 6, aPanelNum);
	VUHDO_initIncomingOrShieldBar(aButton, 19, aPanelNum);
	VUHDO_initHealthBar(aButton, aPanelNum);
	VUHDO_initAggroTexture(aButton, sHealthBar);
	VUHDO_initManaBar(aButton, VUHDO_getHealthBar(aButton,  2), sPanelConfig[aPanelNum]["barScaling"]["barWidth"], false, aPanelNum);
	VUHDO_initTargetBar(aButton, aPanelNum);
	VUHDO_initTotBar(aButton, sHealthBar, aPanelNum);
	VUHDO_initThreatBar(aButton, aPanelNum);
	VUHDO_initBarTexts(aButton, sHealthBar, sPanelConfig[aPanelNum]["barWidth"], aPanelNum);
	VUHDO_initOverhealText(sHealthBar, sPanelConfig[aPanelNum]["barScaling"]["barWidth"], aPanelNum);
	VUHDO_initHighlightBar(aButton, aPanelNum);
	VUHDO_initSideBarLeft(aButton, sHealthBar, aPanelNum);
	VUHDO_initSideBarRight(aButton, sHealthBar, aPanelNum);

	VUHDO_initAggroBar(aButton, sHealthBar, aPanelNum);
	VUHDO_initHotBars(aPanelNum);
	VUHDO_initAllHotIcons(aPanelNum);
	VUHDO_initCustomDebuffs(aPanelNum);
	VUHDO_initPrivateAuras(sHealthBar, aButton, aPanelNum);
	VUHDO_initRaidIcon(sHealthBar, VUHDO_getBarRoleIcon(aButton, 50), sPanelConfig[aPanelNum]["barScaling"]["barWidth"], aPanelNum);
	VUHDO_initSwiftmendIndicator(aButton, sHealthBar, aPanelNum);
	VUHDO_initFlashBar(aButton);
	VUHDO_initReadyCheckIcon(aButton);

	if VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"] then
		ClickCastFrames = ClickCastFrames or {};
		ClickCastFrames[aButton] = true;
		ClickCastFrames[_G[aButton:GetName() .. "Tg"]] = true;
		ClickCastFrames[_G[aButton:GetName() .. "Tot"]] = true;
	end

	return;

end



--
local tHealButton;
local tGroupPanel;
local tNumButtons;
local tCnt;
local tDebuffFrame;
local function VUHDO_initAllHealButtons(aPanel, aPanelNum)

	tNumButtons = VUHDO_getNumButtonsPanel(aPanelNum);

	for tCnt  = 1, tNumButtons do
		tHealButton = VUHDO_getOrCreateHealButton(tCnt, aPanelNum);

		if VUHDO_LibButtonFacade then
			VUHDO_initButtonButtonFacade(tHealButton);
		end

		VUHDO_initHealButton(tHealButton, aPanelNum);
	end

	tCnt = tNumButtons + 1;

	while true do
		tHealButton = VUHDO_getHealButton(tCnt, aPanelNum);

		if tHealButton then
			tHealButton["raidid"] = nil;
			VUHDO_safeSetAttribute(tHealButton, "unit", nil);

			for tDebuffCnt = 40, VUHDO_CONFIG["CUSTOM_DEBUFF"]["max_num"] + 39 do
				tDebuffFrame = VUHDO_getBarIconFrame(tHealButton, tDebuffCnt);

				if tDebuffFrame then
					VUHDO_safeSetAttribute(tDebuffFrame, "unit", nil);
					tDebuffFrame["raidid"] = nil;
				end
			end

			VUHDO_PixelUtil.ClearAllPoints(tHealButton);
			VUHDO_PixelUtil.Hide(tHealButton);
		else
			break;
		end

		tCnt = tCnt + 1;
	end

	for tCnt = 1, #VUHDO_PANEL_MODELS[aPanelNum] do
		tGroupPanel = VUHDO_getGroupOrderPanel(aPanelNum, tCnt);

		if tGroupPanel then
			VUHDO_PixelUtil.Hide(tGroupPanel);
		end

		tGroupPanel = VUHDO_getGroupSelectPanel(aPanelNum,  tCnt);

		if tGroupPanel then
			VUHDO_PixelUtil.Hide(tGroupPanel);
		end
	end

	return;

end



--
VUHDO_PROHIBIT_REPOS = false;
local tSetup;
local tPosition;
local tPanelColor;
local tLabel;
local tGrowth;
local tScale;
local tFactor;
local tX;
local tY;
local tBorderR;
local tBorderG;
local tBorderB;
local tBorderO;
local function VUHDO_initPanel(aPanel, aPanelNum)

	tSetup  = VUHDO_PANEL_SETUP[aPanelNum];
	tPosition = tSetup["POSITION"];
	tPanelColor = tSetup["PANEL_COLOR"];

	tScale  = tSetup["SCALING"]["scale"];
	tFactor = tScale / aPanel:GetScale();

	tGrowth = tPosition["growth"];

	VUHDO_PixelUtil.ClearAllPoints(aPanel);
	VUHDO_PixelUtil.SetWidth(aPanel, tPosition["width"]);
	VUHDO_PixelUtil.SetHeight(aPanel, tPosition["height"]);
	VUHDO_PixelUtil.SetScale(aPanel, tScale);
	VUHDO_PixelUtil.SetPoint(aPanel, tPosition["orientation"],  "UIParent", tPosition["relativePoint"],  tPosition["x"],  tPosition["y"]);
	VUHDO_PixelUtil.EnableMouseWheel(aPanel, 1);
	VUHDO_PixelUtil.SetFrameStrata(aPanel, tSetup["frameStrata"] or "MEDIUM");

	if aPanel:IsShown() then
		tX, tY = VUHDO_getAnchorCoords(aPanel, tGrowth, tFactor);
		VUHDO_PixelUtil.ClearAllPoints(aPanel);

		if VUHDO_PROHIBIT_REPOS then
			VUHDO_PixelUtil.SetPoint(aPanel, tGrowth,  "UIParent", "BOTTOMLEFT", tX, tY);
		else
			VUHDO_PixelUtil.SetPoint(aPanel, tGrowth,  "UIParent", "BOTTOMLEFT", tX  * tFactor,  tY  * tFactor);
		end
	end

	VUHDO_PANEL_SETUP[aPanelNum]["POSITION"]["orientation"] = tGrowth;

	VUHDO_PixelUtil.SetWidth(aPanel, VUHDO_getHealPanelWidth(aPanelNum));
	VUHDO_PixelUtil.SetHeight(aPanel, VUHDO_getHealPanelHeight(aPanelNum));

	VUHDO_savePanelCoords(aPanel);

	tLabel = VUHDO_getPanelNumLabel(aPanel);

	VUHDO_STD_BACKDROP = aPanel:GetBackdrop();
	VUHDO_STD_BACKDROP["edgeFile"] = tPanelColor["BORDER"]["file"];
	VUHDO_STD_BACKDROP["edgeSize"] = VUHDO_getPixelPerfectBorderEdgeSize(aPanelNum);
	VUHDO_STD_BACKDROP["insets"]["left"] = VUHDO_getPixelPerfectBorderInsets(aPanelNum);
	VUHDO_STD_BACKDROP["insets"]["right"] = VUHDO_getPixelPerfectBorderInsets(aPanelNum);
	VUHDO_STD_BACKDROP["insets"]["top"] = VUHDO_getPixelPerfectBorderInsets(aPanelNum);
	VUHDO_STD_BACKDROP["insets"]["bottom"] = VUHDO_getPixelPerfectBorderInsets(aPanelNum);

	aPanel.backdropInfo = VUHDO_STD_BACKDROP;
	VUHDO_PixelUtil.ApplyBackdrop(aPanel, VUHDO_STD_BACKDROP);

	-- Ensure proper border color with pixel-perfect alpha
	tBorderR, tBorderG, tBorderB, tBorderO = VUHDO_backColor(tPanelColor["BORDER"]);
	aPanel.backdropBorderColor = VUHDO_getOrCreateCachedColor(tBorderR, tBorderG, tBorderB, tBorderO);
	aPanel.backdropBorderColorAlpha = tBorderO or tPanelColor["BORDER"]["O"] or 0.46;
	aPanel:SetBackdropBorderColor(tBorderR, tBorderG, tBorderB, aPanel.backdropBorderColorAlpha);

	if VUHDO_IS_PANEL_CONFIG then
		tLabel:SetText("[PANEL "  .. aPanelNum .. "]");
		VUHDO_PixelUtil.SetPoint(tLabel:GetParent(), "BOTTOM", aPanel:GetName(), "TOP", 0, 3);
		VUHDO_PixelUtil.Show(tLabel:GetParent());

		if DESIGN_MISC_PANEL_NUM == aPanelNum and VuhDoNewOptionsPanelPanel and VuhDoNewOptionsPanelPanel:IsVisible() then
			VUHDO_DESIGN_BACKDROP = VUHDO_deepCopyTable(VUHDO_STD_BACKDROP);
			tLabel:SetTextColor(1, 1, 0, 1);
			VUHDO_UIFrameFlash(tLabel, 0.25, 0.5, 10000, true, 0.3, 0);

			aPanel.backdropInfo = VUHDO_DESIGN_BACKDROP;
			VUHDO_PixelUtil.ApplyBackdrop(aPanel, VUHDO_DESIGN_BACKDROP);

			aPanel.backdropBorderColor = VUHDO_getOrCreateCachedColor(1, 1, 1);
			aPanel.backdropBorderColorAlpha = 1;
			aPanel:SetBackdropBorderColor(VUHDO_backColor(tPanelColor["BORDER"]));
		else
			aPanel.backdropInfo = VUHDO_STD_BACKDROP;
			VUHDO_PixelUtil.ApplyBackdrop(aPanel, VUHDO_STD_BACKDROP);
			
			aPanel.backdropBorderColor = VUHDO_getOrCreateCachedColor(VUHDO_backColor(tPanelColor["BORDER"]));
			aPanel.backdropBorderColorAlpha = tPanelColor["BORDER"]["O"] or 1;
			aPanel:SetBackdropBorderColor(VUHDO_backColor(tPanelColor["BORDER"]));

			tLabel:SetTextColor(0.4,  0.4, 0.4, 1);
			VUHDO_UIFrameFlashStop(tLabel);			
		end

		if DESIGN_MISC_PANEL_NUM then
			VuhDoNewOptionsTabbedFramePanelNumLabelLabel:SetText(VUHDO_I18N_PANEL .. " #" .. DESIGN_MISC_PANEL_NUM);
			VUHDO_PixelUtil.Show(VuhDoNewOptionsTabbedFramePanelNumLabelLabel);
		else
			VUHDO_PixelUtil.Hide(VuhDoNewOptionsTabbedFramePanelNumLabelLabel);
		end

		_G[aPanel:GetName() .. "NewTxu"]:SetShown(not VUHDO_CONFIG_SHOW_RAID);
		_G[aPanel:GetName() .. "ClrTxu"]:SetShown(not VUHDO_CONFIG_SHOW_RAID);
	else
		VUHDO_PixelUtil.Hide(_G[aPanel:GetName() .. "NewTxu"]);
		VUHDO_PixelUtil.Hide(_G[aPanel:GetName() .. "ClrTxu"]);
		VUHDO_PixelUtil.Hide(tLabel:GetParent());

		if VuhDoNewOptionsTabbedFrame then
			VUHDO_PixelUtil.Hide(VuhDoNewOptionsTabbedFramePanelNumLabelLabel);
		end
	end

	aPanel:SetBackdropColor(VUHDO_backColor(tPanelColor["BACK"]));
	VUHDO_PixelUtil.EnableMouse(aPanel, not VUHDO_CONFIG["LOCK_CLICKS_THROUGH"]);

	VUHDO_PixelUtil.StopMovingOrSizing(aPanel);
	aPanel["isMoving"] = false;

	return;

end



--
local tNumButtons;
local tCycleId;
function VUHDO_deferInitAllHealButtons(aPanel, aPanelNum, aCycleId)

	tNumButtons = VUHDO_getNumButtonsPanel(aPanelNum);

	tCycleId = VUHDO_generateCycleId(aCycleId, true);
	sButtonInitSemaphores[aPanelNum] = VUHDO_createSemaphore("InitAllHealButtons_" .. aPanelNum .. "_" .. tCycleId, 0, tNumButtons, sButtonInitTimeouts[aPanelNum]);

	if not sButtonInitSemaphores[aPanelNum] then
		return;
	end

	for tCnt = 1, tNumButtons do
		VUHDO_deferTask(VUHDO_DEFER_INIT_HEAL_BUTTON, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum, tCnt);

		sButtonInitSemaphores[aPanelNum]:increment();
	end

	VUHDO_deferTask(VUHDO_DEFER_INIT_ALL_HEAL_BUTTONS_COMPLETE, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum);

	return;

end



--
local tModelArray;
local tColumnIndex;
local tButtonIndex;
local tGroupArray;
local tTotalButtons;
local tCycleId;
function VUHDO_deferPositionAllHealButtons(aPanel, aPanelNum, aCycleId)

	if not sButtonPositionTimeouts[aPanelNum] then
		VUHDO_calculateSemaphoreTimeouts();
	end

	tModelArray = VUHDO_getDynamicModelArray(aPanelNum);

	tColumnIndex = 1;
	tButtonIndex = 1;
	tTotalButtons = 0;

	for tModelIndex, tModelId in ipairs(tModelArray) do
		tGroupArray = VUHDO_getGroupMembersSorted(tModelId, sPanelConfig[aPanelNum]["sortCriterion"], aPanelNum, tModelIndex);
		tTotalButtons = tTotalButtons + #tGroupArray;
	end

	tCycleId = VUHDO_generateCycleId(aCycleId, true);
	sButtonPositionSemaphores[aPanelNum] = VUHDO_createSemaphore("PositionAllHealButtons_" .. aPanelNum .. "_" .. tCycleId, 0, tTotalButtons, sButtonPositionTimeouts[aPanelNum]);

	if not sButtonPositionSemaphores[aPanelNum] then
		return;
	end

	tColumnIndex = 1;
	tButtonIndex = 1;

	for tModelIndex, tModelId in ipairs(tModelArray) do
		tGroupArray = VUHDO_getGroupMembersSorted(tModelId, sPanelConfig[aPanelNum]["sortCriterion"], aPanelNum, tModelIndex);

		for tGroupIndex, tUnit in ipairs(tGroupArray) do
			VUHDO_deferTask(VUHDO_DEFER_POSITION_HEAL_BUTTON, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, tUnit, aPanelNum, tButtonIndex, tModelIndex, tModelId, tGroupIndex, tColumnIndex);

			sButtonPositionSemaphores[aPanelNum]:increment();

			tButtonIndex = tButtonIndex + 1;
		end

		tColumnIndex = tColumnIndex + 1;
	end

	return;

end



--
local tCurrentCycleId;
local tTrackerKey;
function VUHDO_deferRedrawPanelComplete(aPanelNum, anIsFixAllFrameLevels, aCycleId)

	if not sPanelCompletionTracker then
		sPanelCompletionTracker = { };
	end

	tCurrentCycleId = aCycleId or "UNKNOWN";
	tTrackerKey = tCurrentCycleId .. "_" .. aPanelNum;

	if sPanelCompletionTracker[tTrackerKey] then
		return;
	end

	sPanelCompletionTracker[tTrackerKey] = true;

	VUHDO_deferTask(VUHDO_DEFER_REDRAW_PANEL_COMPLETE, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum, anIsFixAllFrameLevels, aCycleId);

	return;

end



--
local tIsFullRedrawCycle;
local tCurrentCycleId;
local tIsPanelActive;
local tWaitingRequest;
local tCycleId;
function VUHDO_deferRedrawPanel(aPanelNum, anIsFixAllFrameLevels, aCycleId)

	tIsFullRedrawCycle = (aCycleId ~= nil);
	tCurrentCycleId = aCycleId or "UNKNOWN";

	tIsPanelActive = false;

	if tIsFullRedrawCycle then
		if sRedrawPanelSemaphores[aPanelNum] and sRedrawPanelSemaphores[aPanelNum]["count"] > 0 then
			tIsPanelActive = true;
		end
	else
		if sRedrawPanelSemaphores[aPanelNum] and sRedrawPanelSemaphores[aPanelNum]["count"] > 0 then
			tIsPanelActive = true;
		elseif sRedrawAllPanelsSemaphore and sRedrawAllPanelsSemaphore["count"] > 0 then
			tIsPanelActive = true;
		end
	end

	if tIsPanelActive then
		if not sWaitingIndividualRedraws[aPanelNum] then
			sWaitingIndividualRedraws[aPanelNum] = { };
		end

		if not sQueuedIndividualRequests[aPanelNum] then
			sQueuedIndividualRequests[aPanelNum] = { };
		end

		if sQueuedIndividualRequests[aPanelNum][anIsFixAllFrameLevels] then
			return;
		end

		tWaitingRequest = {
			["isFixAllFrameLevels"] = anIsFixAllFrameLevels,
			["cycleId"] = aCycleId,
			["timestamp"] = GetTime()
		};

		sQueuedIndividualRequests[aPanelNum][anIsFixAllFrameLevels] = true;
		tinsert(sWaitingIndividualRedraws[aPanelNum], tWaitingRequest);

		return;
	end

	if not tIsFullRedrawCycle then
		tCycleId = VUHDO_generateCycleId();
		tCurrentCycleId = tCycleId;

		if not sRedrawPanelSemaphores[aPanelNum] then
			VUHDO_calculateSemaphoreTimeouts();

			sRedrawPanelSemaphores[aPanelNum] = VUHDO_createSemaphore("RedrawPanel_" .. aPanelNum .. "_" .. tCycleId, 0, 1, sPanelRedrawTimeout);

			if sRedrawPanelSemaphores[aPanelNum] then
				sPanelCompletionTracker = { };
			end
		end
	end

	if VUHDO_isPanelPopulated(aPanelNum) then
		if tIsFullRedrawCycle and sRedrawAllPanelsSemaphore then
			sRedrawAllPanelsSemaphore:increment();
		elseif not tIsFullRedrawCycle and sRedrawPanelSemaphores[aPanelNum] then
			sRedrawPanelSemaphores[aPanelNum]:increment();
		end

		VUHDO_deferTask(VUHDO_DEFER_REDRAW_PANEL, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum, anIsFixAllFrameLevels, tCurrentCycleId);
	else
		VUHDO_PixelUtil.Hide(VUHDO_getActionPanelOrStub(aPanelNum));

		if tIsFullRedrawCycle and aCycleId and sRedrawAllPanelsSemaphore and VUHDO_extractCycleIdFromSemaphoreName(sRedrawAllPanelsSemaphore["name"]) == aCycleId then
			if sRedrawAllPanelsSemaphore["count"] > 0 then
				sRedrawAllPanelsSemaphore:decrement();
			end
		end
	end

	return;

end



--
local tHealButton;
function VUHDO_deferInitHealButtonDelegate(aPanelNum, aButtonIndex)

	tHealButton = VUHDO_getOrCreateHealButton(aButtonIndex, aPanelNum);

	sHealthBar = VUHDO_getHealthBar(tHealButton, 1);

	if VUHDO_LibButtonFacade then
		VUHDO_initButtonButtonFacade(tHealButton);
	end

	VUHDO_initHealButton(tHealButton, aPanelNum);

	if sButtonInitSemaphores[aPanelNum] then
		sButtonInitSemaphores[aPanelNum]:decrement();
	end

	return;

end



--
local tHealButton;
local tXPos;
local tYPos;
local tPanel;
function VUHDO_deferPositionHealButtonDelegate(aUnit, aPanelNum, aButtonIndex, aModelIndex, aModelId, aGroupIndex, aColumnIndex)

	tHealButton = VUHDO_getOrCreateHealButton(aButtonIndex, aPanelNum);

	VUHDO_positionHealButton(tHealButton, aPanelNum);

	if aUnit then
		VUHDO_setupAllHealButtonAttributes(tHealButton, aUnit, false, 70 == aModelId, false, false); -- VUHDO_ID_VEHICLES
	end

	if VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["showTarget"] then
		VUHDO_setupAllTargetButtonAttributes(VUHDO_getTargetButton(tHealButton), aUnit);
	end

	if VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["showTot"] then
		VUHDO_setupAllTotButtonAttributes(VUHDO_getTotButton(tHealButton), aUnit);
	end

	tXPos, tYPos = VUHDO_getHealButtonPos(aColumnIndex, aGroupIndex, aPanelNum);

	VUHDO_PixelUtil.Hide(tHealButton);
	VUHDO_PixelUtil.ClearAllPoints(tHealButton);

	tPanel = VUHDO_getOrCreateActionPanel(aPanelNum);
	VUHDO_PixelUtil.SetPoint(tHealButton, "TOPLEFT", tPanel:GetName(), "TOPLEFT", tXPos, -tYPos);

	if tHealButton:GetAttribute("unit") then
		VUHDO_addUnitButton(tHealButton, aPanelNum);
	end

	VUHDO_PixelUtil.Show(tHealButton);

	if sButtonPositionSemaphores[aPanelNum] then
		sButtonPositionSemaphores[aPanelNum]:decrement();
	end

	return;

end



--
local tCurrentCycleId;
local tTrackerKey;
local tNextRequest;
local tPanel;
local tButtonSemaphores;
function VUHDO_deferRedrawPanelCompleteDelegate(aPanelNum, anIsFixAllFrameLevels, aCycleId)

	if tButtonSemaphores then
		twipe(tButtonSemaphores);
	else
		tButtonSemaphores = { };
	end

	if sButtonInitSemaphores[aPanelNum] then
		tinsert(tButtonSemaphores, sButtonInitSemaphores[aPanelNum]);
	end

	if sButtonPositionSemaphores[aPanelNum] then
		tinsert(tButtonSemaphores, sButtonPositionSemaphores[aPanelNum]);
	end

	if #tButtonSemaphores > 0 then
		if not VUHDO_waitForSemaphores(tButtonSemaphores, VUHDO_DEFER_REDRAW_PANEL_COMPLETE, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum, anIsFixAllFrameLevels, aCycleId) then
			return;
		end
	end

	tPanel = VUHDO_getOrCreateActionPanel(aPanelNum);

	VUHDO_positionTableHeaders(tPanel, aPanelNum);

	VUHDO_initPanel(tPanel, aPanelNum);

	if VUHDO_isPanelVisible(aPanelNum) then
		VUHDO_fixFrameLevels(anIsFixAllFrameLevels, tPanel, 2, tPanel:GetChildren());

		VUHDO_PixelUtil.Show(tPanel);
	else
		VUHDO_PixelUtil.Hide(tPanel);
	end

	if aCycleId and sRedrawAllPanelsSemaphore and VUHDO_extractCycleIdFromSemaphoreName(sRedrawAllPanelsSemaphore["name"]) == aCycleId then
		if sRedrawAllPanelsSemaphore["count"] <= 0 then
			return;
		end

		sRedrawAllPanelsSemaphore:decrement();
	elseif sRedrawPanelSemaphores[aPanelNum] then
		if sRedrawPanelSemaphores[aPanelNum]["count"] <= 0 then
			return;
		end

		sRedrawPanelSemaphores[aPanelNum]:decrement();

		if sRedrawPanelSemaphores[aPanelNum]["count"] == 0 then
			sRedrawPanelSemaphores[aPanelNum] = nil;

			if sWaitingIndividualRedraws[aPanelNum] and #sWaitingIndividualRedraws[aPanelNum] > 0 then
				tNextRequest = tremove(sWaitingIndividualRedraws[aPanelNum], 1);

				if sQueuedIndividualRequests[aPanelNum] then
					sQueuedIndividualRequests[aPanelNum][tNextRequest["isFixAllFrameLevels"]] = nil;
				end

				VUHDO_deferRedrawPanel(aPanelNum, tNextRequest["isFixAllFrameLevels"], tNextRequest["cycleId"]);
			else
				if #sWaitingAllPanelsRedraws > 0 then
					tNextRequest = tremove(sWaitingAllPanelsRedraws, 1);

					sQueuedAllPanelsRequests[tNextRequest["isFixAllFrameLevels"]] = nil;

					VUHDO_deferRedrawAllPanels(tNextRequest["isFixAllFrameLevels"]);
				end
			end
		end
	end

	if sPanelCompletionTracker and aCycleId then
		tCurrentCycleId = aCycleId or "UNKNOWN";
		tTrackerKey = tCurrentCycleId .. "_" .. aPanelNum;

		sPanelCompletionTracker[tTrackerKey] = nil;
	end

	return;

end



--
local tCnt;
local tHealButton;
local tGroupPanel;
local tDebuffFrame;
function VUHDO_deferInitAllHealButtonsCompleteDelegate(aPanelNum)

	if sButtonInitSemaphores[aPanelNum] and not sButtonInitSemaphores[aPanelNum]:waitFor(VUHDO_DEFER_INIT_ALL_HEAL_BUTTONS_COMPLETE, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum) then
		return;
	end

	tCnt = VUHDO_getNumButtonsPanel(aPanelNum) + 1;

	while true do
		tHealButton = VUHDO_getHealButton(tCnt, aPanelNum);

		if tHealButton then
			tHealButton["raidid"] = nil;
			VUHDO_safeSetAttribute(tHealButton, "unit", nil);

			for tDebuffCnt = 40, VUHDO_CONFIG["CUSTOM_DEBUFF"]["max_num"] + 39 do
				tDebuffFrame = VUHDO_getBarIconFrame(tHealButton, tDebuffCnt);

				if tDebuffFrame then
					VUHDO_safeSetAttribute(tDebuffFrame, "unit", nil);
					tDebuffFrame["raidid"] = nil;
				end
			end

			VUHDO_PixelUtil.ClearAllPoints(tHealButton);
			VUHDO_PixelUtil.Hide(tHealButton);
		else
			break;
		end

		tCnt = tCnt + 1;
	end

	for tCnt = 1, #VUHDO_PANEL_MODELS[aPanelNum] do
		tGroupPanel = VUHDO_getGroupOrderPanel(aPanelNum, tCnt);

		if tGroupPanel then
			VUHDO_PixelUtil.Hide(tGroupPanel);
		end

		tGroupPanel = VUHDO_getGroupSelectPanel(aPanelNum,  tCnt);

		if tGroupPanel then
			VUHDO_PixelUtil.Hide(tGroupPanel);
		end
	end

	return;

end



--
function VUHDO_deferPositionConfigPanels(aPanelNum)

	VUHDO_deferTask(VUHDO_DEFER_POSITION_CONFIG_PANELS, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum);

	return;

end



--
function VUHDO_deferPositionConfigPanelsDelegate(aPanelNum)

	VUHDO_positionAllGroupConfigPanels(aPanelNum);

	return;

end



--
local tPanel;
function VUHDO_redrawPanel(aPanelNum, anIsFixAllFrameLevels)

	if VUHDO_isPanelPopulated(aPanelNum) then
		tPanel = VUHDO_getOrCreateActionPanel(aPanelNum);

		VUHDO_initLocalVars(aPanelNum);
		VUHDO_initAllHealButtons(tPanel, aPanelNum);

		if VUHDO_isConfigPanelShowing() then
			VUHDO_positionAllGroupConfigPanels(aPanelNum);
		else
			VUHDO_positionAllHealButtons(tPanel, aPanelNum);
		end

		VUHDO_positionTableHeaders(tPanel,  aPanelNum);

		VUHDO_initPanel(tPanel, aPanelNum);

		if VUHDO_isPanelVisible(aPanelNum) then
			VUHDO_fixFrameLevels(anIsFixAllFrameLevels, tPanel, 2, tPanel:GetChildren());

			VUHDO_PixelUtil.Show(tPanel);
		else
			VUHDO_PixelUtil.Hide(tPanel);
		end
	else
		VUHDO_PixelUtil.Hide(VUHDO_getActionPanelOrStub(aPanelNum));
	end

	return;

end
_G["VUHDO_redrawPanel"] = VUHDO_redrawPanel;



--
local tGcdCol;
function VUHDO_redrawAllPanels(anIsFixAllFrameLevels)

	VUHDO_resetMacroCaches();
	VUHDO_resetSizeCalcCaches();
	VUHDO_clearBackdropCache();
	VUHDO_clearCustomFlagCache();
	twipe(VUHDO_UNIT_BUTTONS);
	twipe(VUHDO_UNIT_BUTTONS_PANEL);

	tBackdrop = nil;
	tBackdropCluster = nil;

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		_G["VUHDO_redrawPanel"](tPanelNum, anIsFixAllFrameLevels);
	end

	VUHDO_setupAllButtonsUnitWatch(VUHDO_CONFIG["HIDE_EMPTY_BUTTONS"] and not VUHDO_IS_PANEL_CONFIG and not VUHDO_isConfigDemoUsers());
	VUHDO_updateAllRaidBars();

	-- GCD bar
	if VUHDO_isShowGcd() then
		tGcdCol = VUHDO_PANEL_SETUP["BAR_COLORS"]["GCD_BAR"];

		VuhDoGcdStatusBar:SetVuhDoColor(tGcdCol);
		VuhDoGcdStatusBar:SetStatusBarTexture("Interface\\AddOns\\VuhDo\\Images\\white_square_16_16");

		VUHDO_PixelUtil.ApplySettings(VuhDoGcdStatusBar:GetStatusBarTexture());

		VuhDoGcdStatusBar:SetValue(0);
		VUHDO_PixelUtil.SetFrameStrata(VuhDoGcdStatusBar, "TOOLTIP");
	end

	VUHDO_PixelUtil.Hide(VuhDoGcdStatusBar);

	-- Direction arrow
	VUHDO_PixelUtil.ApplySettings(VuhDoDirectionFrameArrow);
	VuhDoDirectionFrameArrow:SetVertexColor(VUHDO_backColor(VUHDO_PANEL_SETUP["BAR_COLORS"]["DIRECTION"]));
	VUHDO_PixelUtil.SetPoint(VuhDoDirectionFrameText, "TOP", "VuhDoDirectionFrameArrow", "CENTER", 5,  -2);
	VuhDoDirectionFrameText:SetText("");
	VUHDO_PixelUtil.SetFrameStrata(VuhDoDirectionFrame, "TOOLTIP");

	VUHDO_initAllEventBouquets();

	return;

end
_G["VUHDO_redrawAllPanels"] = VUHDO_redrawAllPanels;



--
function VUHDO_reloadUI(anIsFixAllFrameLevels)

	if InCombatLockdown() then
		return;
	end

	VUHDO_IS_RELOADING = true;

	VUHDO_clearBackdropCache();
	VUHDO_clearCustomFlagCache();
	VUHDO_initAllBurstCaches(); -- Wichtig f�r INTERNAL_TOGGLES=>Clusters
	VUHDO_reloadRaidMembers();
	VUHDO_resetNameTextCache();

	if VUHDO_CONFIG["USE_DEFERRED_REDRAW"] and VUHDO_IN_COMBAT_RELOG then
		VUHDO_refreshRaidMembers();

		-- force synchronous redraw on combat relog
		_G["VUHDO_redrawAllPanels"](anIsFixAllFrameLevels);
	else
		VUHDO_redrawAllPanels(anIsFixAllFrameLevels);
	end

	VUHDO_updateAllCustomDebuffs(true);
	VUHDO_rebuildTargets();
	VUHDO_updatePanelVisibility();

	VUHDO_IS_RELOADING = false;

	VUHDO_reloadBuffPanel();
	VUHDO_initDebuffs(); -- Talente scheinen recht sp�t zur Verf�gung zu stehen...

	return;

end



--
function VUHDO_lnfReloadUI()

	if InCombatLockdown() then
		return;
	end

	VUHDO_IS_RELOADING = true;

	VUHDO_clearBackdropCache();
	VUHDO_clearCustomFlagCache();
	VUHDO_initAllBurstCaches();
	VUHDO_reloadRaidMembers();
	VUHDO_updatePanelVisibility();

	-- force synchronous redraw on config reload
	_G["VUHDO_redrawAllPanels"](false);

	VUHDO_buildGenericHealthBarBouquet();
	VUHDO_buildGenericTargetHealthBouquet();
	VUHDO_bouqetsChanged();
	VUHDO_initAllBurstCaches();

	VUHDO_IS_RELOADING = false;

	return;

end



--
function VUHDO_isDeferredRedrawActive()

	if sRedrawAllPanelsSemaphore and sRedrawAllPanelsSemaphore["count"] > 0 then
		return true;
	end

	for tPanelNum = 1, 10 do
		if sRedrawPanelSemaphores[tPanelNum] and sRedrawPanelSemaphores[tPanelNum]["count"] > 0 then
			return true;
		end

		if sButtonInitSemaphores[tPanelNum] and sButtonInitSemaphores[tPanelNum]["count"] > 0 then
			return true;
		end

		if sButtonPositionSemaphores[tPanelNum] and sButtonPositionSemaphores[tPanelNum]["count"] > 0 then
			return true;
		end
	end

	return false;

end



--
local tWaitingRequest;
local tHasIndividualRedraws;
local tCycleId;
function VUHDO_deferRedrawAllPanels(anIsFixAllFrameLevels)

	if InCombatLockdown() then
		VUHDO_Msg("WARNING: VUHDO_deferRedrawAllPanels called during combat! Stack:\n" .. debugstack(2, 5, 5));
	end

	if sRedrawAllPanelsSemaphore and sRedrawAllPanelsSemaphore["count"] > 0 then
		if sQueuedAllPanelsRequests[anIsFixAllFrameLevels] then
			return;
		end

		tWaitingRequest = {
			["isFixAllFrameLevels"] = anIsFixAllFrameLevels,
			["timestamp"] = GetTime()
		};

		sQueuedAllPanelsRequests[anIsFixAllFrameLevels] = true;
		tinsert(sWaitingAllPanelsRedraws, tWaitingRequest);

		return;
	end

	tHasIndividualRedraws = false;

	for tPanelNum = 1, 10 do
		if sRedrawPanelSemaphores[tPanelNum] and sRedrawPanelSemaphores[tPanelNum]["count"] > 0 then
			tHasIndividualRedraws = true;

			break;
		end
	end

	if tHasIndividualRedraws then
		if sQueuedAllPanelsRequests[anIsFixAllFrameLevels] then
			return;
		end

		tWaitingRequest = {
			["isFixAllFrameLevels"] = anIsFixAllFrameLevels,
			["timestamp"] = GetTime()
		};

		sQueuedAllPanelsRequests[anIsFixAllFrameLevels] = true;
		tinsert(sWaitingAllPanelsRedraws, tWaitingRequest);

		return;
	end

	if sRedrawAllPanelsSemaphore and sRedrawAllPanelsSemaphore["count"] > 0 then
		return;
	end

	tCycleId = VUHDO_generateCycleId();

	VUHDO_resetMacroCaches();
	VUHDO_resetSizeCalcCaches();
	VUHDO_clearBackdropCache();
	twipe(VUHDO_UNIT_BUTTONS);
	twipe(VUHDO_UNIT_BUTTONS_PANEL);

	tBackdrop = nil;
	tBackdropCluster = nil;

	VUHDO_calculateSemaphoreTimeouts();

	if sRedrawAllPanelsSemaphore and sRedrawAllPanelsSemaphore["count"] > 0 then
		if sQueuedAllPanelsRequests[anIsFixAllFrameLevels] then
			return;
		end

		tWaitingRequest = {
			["isFixAllFrameLevels"] = anIsFixAllFrameLevels,
			["timestamp"] = GetTime()
		};

		sQueuedAllPanelsRequests[anIsFixAllFrameLevels] = true;
		tinsert(sWaitingAllPanelsRedraws, tWaitingRequest);

		return;
	end

	sRedrawAllPanelsSemaphore = VUHDO_createSemaphore("RedrawAllPanels_" .. tCycleId, 0, 10, sPanelRedrawTimeout);

	if not sRedrawAllPanelsSemaphore then
		return;
	end

	sPanelCompletionTracker = { };

	for tPanelNum = 1, 10 do
		if sWaitingIndividualRedraws[tPanelNum] and #sWaitingIndividualRedraws[tPanelNum] > 0 then
			twipe(sWaitingIndividualRedraws[tPanelNum]);
		end

		if sQueuedIndividualRequests[tPanelNum] then
			twipe(sQueuedIndividualRequests[tPanelNum]);
		end

		if sButtonInitSemaphores[tPanelNum] then
			sButtonInitSemaphores[tPanelNum] = nil;
		end

		if sButtonPositionSemaphores[tPanelNum] then
			sButtonPositionSemaphores[tPanelNum] = nil;
		end
	end

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		VUHDO_deferRedrawPanel(tPanelNum, anIsFixAllFrameLevels, tCycleId);
	end

	VUHDO_deferRedrawAllPanelsComplete(anIsFixAllFrameLevels);

	return;

end



--
local tPanel;
function VUHDO_deferRedrawPanelDelegate(aPanelNum, anIsFixAllFrameLevels, aCycleId)

	tPanel = VUHDO_getOrCreateActionPanel(aPanelNum);

	VUHDO_initLocalVars(aPanelNum);
	VUHDO_deferInitAllHealButtons(tPanel, aPanelNum, aCycleId);

	if VUHDO_isConfigPanelShowing() then
		VUHDO_deferPositionConfigPanels(aPanelNum);
	else
		VUHDO_deferPositionAllHealButtons(tPanel, aPanelNum, aCycleId);
	end

	VUHDO_deferRedrawPanelComplete(aPanelNum, anIsFixAllFrameLevels, aCycleId);

	return;

end



--
local tGcdCol;
local tNextRequest;
function VUHDO_deferRedrawAllPanelsCompleteDelegate(anIsFixAllFrameLevels)

	if sRedrawAllPanelsSemaphore and
		not sRedrawAllPanelsSemaphore:waitFor(VUHDO_DEFER_REDRAW_ALL_PANELS_COMPLETE, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, anIsFixAllFrameLevels) then
		return;
	end

	VUHDO_setupAllButtonsUnitWatch(VUHDO_CONFIG["HIDE_EMPTY_BUTTONS"] and not VUHDO_IS_PANEL_CONFIG and not VUHDO_isConfigDemoUsers());
	VUHDO_updateAllRaidBars();

	if VUHDO_isShowGcd() then
		tGcdCol = VUHDO_PANEL_SETUP["BAR_COLORS"]["GCD_BAR"];

		VuhDoGcdStatusBar:SetVuhDoColor(tGcdCol);
		VuhDoGcdStatusBar:SetStatusBarTexture("Interface\\AddOns\\VuhDo\\Images\\white_square_16_16");

		VUHDO_PixelUtil.ApplySettings(VuhDoGcdStatusBar:GetStatusBarTexture());

		VuhDoGcdStatusBar:SetValue(0);
		VUHDO_PixelUtil.SetFrameStrata(VuhDoGcdStatusBar, "TOOLTIP");
	end

	VUHDO_PixelUtil.Hide(VuhDoGcdStatusBar);

	VUHDO_PixelUtil.ApplySettings(VuhDoDirectionFrameArrow);
	VuhDoDirectionFrameArrow:SetVertexColor(VUHDO_backColor(VUHDO_PANEL_SETUP["BAR_COLORS"]["DIRECTION"]));
	VUHDO_PixelUtil.SetPoint(VuhDoDirectionFrameText, "TOP", "VuhDoDirectionFrameArrow", "CENTER", 5,  -2);
	VuhDoDirectionFrameText:SetText("");
	VUHDO_PixelUtil.SetFrameStrata(VuhDoDirectionFrame, "TOOLTIP");

	VUHDO_initAllEventBouquets();

	sRedrawAllPanelsSemaphore = nil;

	for tPanelNum = 1, 10 do
		if sRedrawPanelSemaphores[tPanelNum] then
			sRedrawPanelSemaphores[tPanelNum] = nil;
		end
	end

	if #sWaitingAllPanelsRedraws > 0 then
		tNextRequest = tremove(sWaitingAllPanelsRedraws, 1);

		sQueuedAllPanelsRequests[tNextRequest["isFixAllFrameLevels"]] = nil;

		VUHDO_deferRedrawAllPanels(tNextRequest["isFixAllFrameLevels"]);
	end

	return;

end
