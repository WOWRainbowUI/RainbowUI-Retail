local _G = _G;

local table = table;
local ipairs = ipairs;
local twipe = table.wipe;
local min = math.min;
local InCombatLockdown = InCombatLockdown;

local RemovePrivateAuraAnchor = C_UnitAuras and C_UnitAuras.RemovePrivateAuraAnchor;
local AddPrivateAuraAnchor = C_UnitAuras and C_UnitAuras.AddPrivateAuraAnchor;
local TriggerPrivateAuraShowDispelType = C_UnitAuras and C_UnitAuras.TriggerPrivateAuraShowDispelType;

local VUHDO_CONFIG;
local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;

local VUHDO_getDynamicModelArray;
local VUHDO_getGroupMembersSorted;
local VUHDO_getHealButton;
local VUHDO_getHealButtonPos;
local VUHDO_setupAllHealButtonAttributes;
local VUHDO_isDifferentButtonPoint;
local VUHDO_addUnitButton;
local VUHDO_getTargetButton;
local VUHDO_getTotButton;
local VUHDO_getOrCreateHealButton;
local VUHDO_updateAllCustomDebuffs;
local VUHDO_initAllEventBouquets;
local VUHDO_getActionPanelOrStub;
local VUHDO_isPanelPopulated;
local VUHDO_updateAllRaidBars;
local VUHDO_fixFrameLevels;
local VUHDO_resetNameTextCache;
local VUHDO_reloadRaidMembers;
local VUHDO_isPanelVisible;
local VUHDO_positionHealButton;
local VUHDO_positionTableHeaders;
local VUHDO_refreshAllUnitAuras;
local VUHDO_getPrivateAuraDispelOverlayContainer;
local VUHDO_getCurrentGroupType;
local VUHDO_isSpecialUnit;
local VUHDO_getPrivateAuraIcon;
local VUHDO_hasDispellableAura;
local VUHDO_hasAnyDispellableAura;
local VUHDO_getUnitButtons;
local VUHDO_deferTask;

local sShowPanels;
local sDurationAnchor = { };



--
function VUHDO_panelRefreshInitLocalOverrides()

	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];

	VUHDO_getDynamicModelArray = _G["VUHDO_getDynamicModelArray"];
	VUHDO_getGroupMembersSorted = _G["VUHDO_getGroupMembersSorted"];
	VUHDO_getHealButton = _G["VUHDO_getHealButton"];
	VUHDO_getHealButtonPos = _G["VUHDO_getHealButtonPos"];
	VUHDO_setupAllHealButtonAttributes = _G["VUHDO_setupAllHealButtonAttributes"];
	VUHDO_isDifferentButtonPoint = _G["VUHDO_isDifferentButtonPoint"];
	VUHDO_addUnitButton = _G["VUHDO_addUnitButton"];
	VUHDO_getTargetButton = _G["VUHDO_getTargetButton"];
	VUHDO_getTotButton = _G["VUHDO_getTotButton"];
	VUHDO_getOrCreateHealButton = _G["VUHDO_getOrCreateHealButton"];
	VUHDO_updateAllCustomDebuffs = _G["VUHDO_updateAllCustomDebuffs"];
	VUHDO_initAllEventBouquets = _G["VUHDO_initAllEventBouquets"];
	VUHDO_getActionPanelOrStub = _G["VUHDO_getActionPanelOrStub"];
	VUHDO_isPanelPopulated = _G["VUHDO_isPanelPopulated"];
	VUHDO_updateAllRaidBars = _G["VUHDO_updateAllRaidBars"];
	VUHDO_fixFrameLevels = _G["VUHDO_fixFrameLevels"];
	VUHDO_resetNameTextCache = _G["VUHDO_resetNameTextCache"];
	VUHDO_reloadRaidMembers = _G["VUHDO_reloadRaidMembers"];
	VUHDO_isPanelVisible = _G["VUHDO_isPanelVisible"];
	VUHDO_positionHealButton = _G["VUHDO_positionHealButton"];
	VUHDO_positionTableHeaders = _G["VUHDO_positionTableHeaders"];
	VUHDO_refreshAllUnitAuras = _G["VUHDO_refreshAllUnitAuras"];
	VUHDO_getPrivateAuraDispelOverlayContainer = _G["VUHDO_getPrivateAuraDispelOverlayContainer"];
	VUHDO_getCurrentGroupType = _G["VUHDO_getCurrentGroupType"];
	VUHDO_isSpecialUnit = _G["VUHDO_isSpecialUnit"];
	VUHDO_getPrivateAuraIcon = _G["VUHDO_getPrivateAuraIcon"];
	VUHDO_hasDispellableAura = _G["VUHDO_hasDispellableAura"];
	VUHDO_hasAnyDispellableAura = _G["VUHDO_hasAnyDispellableAura"];
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_deferTask = _G["VUHDO_deferTask"];

	sShowPanels = VUHDO_CONFIG["SHOW_PANELS"];

end



--
local function VUHDO_hasPanelButtons(aPanelNum)

	if not sShowPanels or not VUHDO_IS_SHOWN_BY_GROUP then
		return false;
	end

	return #VUHDO_PANEL_DYN_MODELS[aPanelNum] > 0;

end



--
local tColIdx;
local tButtonIdx;
local tModels;
local tSortBy;
local tPanelName;
local tSetup;
local tX;
local tY;
local tButton;
local tGroupArray;
local tDebuffFrame;
local function VUHDO_refreshPositionAllHealButtons(aPanel, aPanelNum)

	tSetup = VUHDO_PANEL_SETUP[aPanelNum];
	tModels = VUHDO_getDynamicModelArray(aPanelNum);
	tSortBy = tSetup["MODEL"]["sort"];
	tPanelName = aPanel:GetName();

	tColIdx = 1;
	tButtonIdx = 1;

	VUHDO_initLocalVars(aPanelNum);

	for tModelIndex, tModelId in ipairs(tModels) do
		tGroupArray = VUHDO_getGroupMembersSorted(tModelId, tSortBy, aPanelNum, tModelIndex);

		for tGroupIdx, tUnit in ipairs(tGroupArray) do

			tButton = VUHDO_getOrCreateHealButton(tButtonIdx, aPanelNum);
			tButtonIdx = tButtonIdx + 1;

			if tButton["raidid"] ~= tUnit then
				VUHDO_setupAllHealButtonAttributes(tButton, tUnit, false, 70 == tModelId, false, false); -- VUHDO_ID_VEHICLES

				if VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["showTarget"] then
					VUHDO_setupAllTargetButtonAttributes(VUHDO_getTargetButton(tButton), tUnit);
				end

				if VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["showTot"] then
					VUHDO_setupAllTotButtonAttributes(VUHDO_getTotButton(tButton), tUnit);
				end
			end

			tX, tY = VUHDO_getHealButtonPos(tColIdx, tGroupIdx, aPanelNum);
			if VUHDO_isDifferentButtonPoint(tButton, tX, -tY) then
				tButton:Hide();-- for clearing secure handler mouse wheel bindings
				VUHDO_PixelUtil.SetPoint(tButton, "TOPLEFT", tPanelName, "TOPLEFT", tX, -tY);
			end

			VUHDO_addUnitButton(tButton, aPanelNum);
			if not tButton:IsShown() then tButton:Show(); end -- Wg. Secure handlers?

			-- On profile switches the button already exists but has the wrong size
			VUHDO_initHealButton(tButton, aPanelNum);
			VUHDO_positionHealButton(tButton, aPanelNum);
		end

		tColIdx = tColIdx + 1;
	end

	while true do
		tButton = VUHDO_getHealButton(tButtonIdx, aPanelNum);

		if not tButton then
			break;
		end

		tButton["raidid"] = nil;
		VUHDO_safeSetAttribute(tButton, "unit", nil);

		for tDebuffCnt = 40, VUHDO_CONFIG["CUSTOM_DEBUFF"]["max_num"] + 39 do
			tDebuffFrame = VUHDO_getBarIconFrame(tButton, tDebuffCnt);

			if tDebuffFrame then
				VUHDO_safeSetAttribute(tDebuffFrame, "unit", nil);
				tDebuffFrame["raidid"] = nil;
			end
		end

		VUHDO_clearUnitAuraFrames(tButton);

		VUHDO_PixelUtil.Hide(tButton);
		tButtonIdx = tButtonIdx + 1;
	end

	return;

end



--
local function VUHDO_refreshInitPanel(aPanel, aPanelNum)

	VUHDO_PixelUtil.SetHeight(aPanel, VUHDO_getHealPanelHeight(aPanelNum));
	VUHDO_PixelUtil.SetWidth(aPanel, VUHDO_getHealPanelWidth(aPanelNum));

	VUHDO_PixelUtil.StopMovingOrSizing(aPanel);
	aPanel["isMoving"] = false;

	return;

end



--
local tPanel;
local function VUHDO_refreshPanel(aPanelNum)

	tPanel = VUHDO_getOrCreateActionPanel(aPanelNum);

	if VUHDO_hasPanelButtons(aPanelNum) then
		VUHDO_PixelUtil.Show(tPanel);

		VUHDO_refreshInitPanel(tPanel, aPanelNum);
		VUHDO_positionTableHeaders(tPanel, aPanelNum);
	end

	-- Even if model is not in panel, we need to refresh VUHDO_UNIT_BUTTONS
	if VUHDO_isPanelPopulated(aPanelNum) then
		VUHDO_refreshPositionAllHealButtons(tPanel, aPanelNum);
		VUHDO_fixFrameLevels(false, tPanel, 2, tPanel:GetChildren());
	end

	return;

end



--
local function VUHDO_refreshAllPanels()

	for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
		if VUHDO_isPanelVisible(tCnt) then
			VUHDO_refreshPanel(tCnt);
		else
			VUHDO_PixelUtil.Hide(VUHDO_getActionPanelOrStub(tCnt));
		end
	end

	VUHDO_updateAllRaidBars();
	VUHDO_updatePanelVisibility();
	VUHDO_PixelUtil.Hide(VuhDoGcdStatusBar);

	return;

end



--
function VUHDO_refreshUiNoMembers()

	VUHDO_resetNameTextCache();

	twipe(VUHDO_UNIT_BUTTONS);
	twipe(VUHDO_UNIT_BUTTONS_PANEL);

	VUHDO_refreshAllPanels();

	VUHDO_updateAllCustomDebuffs(true);

	VUHDO_refreshAllUnitAuras();

	if VUHDO_INTERNAL_TOGGLES[22] then -- VUHDO_UPDATE_UNIT_TARGET
		VUHDO_rebuildTargets();
	end

	VUHDO_initAllEventBouquets();

	return;

end
local VUHDO_refreshUiNoMembers = VUHDO_refreshUiNoMembers;



--
function VUHDO_refreshUI()

	VUHDO_IS_RELOADING = true;

	VUHDO_reloadRaidMembers();
	VUHDO_refreshUiNoMembers();

	VUHDO_IS_RELOADING = false;

	return;

end



--
local tPanelNum;
function VUHDO_refreshAllPrivateAuras()

	if not VUHDO_UNIT_BUTTONS then
		return;
	end

	for tUnit, tButtons in pairs(VUHDO_UNIT_BUTTONS) do
		for _, tButton in pairs(tButtons) do
			tPanelNum = VUHDO_BUTTON_CACHE[tButton];

			if tPanelNum then
				VUHDO_refreshPrivateAuras(tPanelNum, tButton, tUnit);
			end
		end
	end

	return;

end



--
local function VUHDO_clearPrivateAuraDispelContainerCache(aButton)

	aButton["privateAuraDispelContainerConfigured"] = nil;
	aButton["privateAuraDispelContainerType"] = nil;
	aButton["privateAuraDispelContainerGroupType"] = nil;
	aButton["privateAuraDispelContainerActiveType"] = nil;

	return;

end



--
local function VUHDO_removePrivateAuraDispelContainer(aButton)

	if aButton["privateAuraDispelContainerAnchorId"] then
		RemovePrivateAuraAnchor(aButton["privateAuraDispelContainerAnchorId"]);

		aButton["privateAuraDispelContainerAnchorId"] = nil;
	end

	return;

end



--
local tContainerAnchor;
local tToggleLevel;
local function VUHDO_addPrivateAuraDispelContainerAnchor(aButton, aUnit, aDispelOverlayContainer)

	if aButton["privateAuraDispelContainerAnchorId"] or not aDispelOverlayContainer then
		return;
	end

	tContainerAnchor = {
		["unitToken"] = aUnit,
		["auraIndex"] = 1,
		["parent"] = aDispelOverlayContainer,
		["showCountdownFrame"] = false,
		["showCountdownNumbers"] = false,
		["isContainer"] = true,
	};

	aButton["privateAuraDispelContainerAnchorId"] = AddPrivateAuraAnchor(tContainerAnchor);

	tToggleLevel = aDispelOverlayContainer:GetFrameLevel();

	VUHDO_PixelUtil.SetFrameLevel(aDispelOverlayContainer, 0);
	VUHDO_PixelUtil.SetFrameLevel(aDispelOverlayContainer, tToggleLevel);

	return;

end



--
local tHasRegular;
local tDesiredAlpha;
local tDesiredType;
local tCachedType;
local function VUHDO_updatePrivateAuraDispelOverlayVisibility(aUnit, aButton, aDispelOverlayContainer, aPrivateDispelOverlay, aPrivateDispelIndicatorType, aDispelOverlay, aDispelIndicatorType)

	if not aDispelOverlayContainer then
		return;
	end

	if aDispelOverlay and aDispelIndicatorType == 2 then
		tHasRegular = VUHDO_hasAnyDispellableAura(aUnit);
	else
		tHasRegular = VUHDO_hasDispellableAura(aUnit);
	end

	if tHasRegular then
		tDesiredAlpha = aDispelOverlay and 1 or 0;
		tDesiredType = aDispelIndicatorType > 0 and aDispelIndicatorType or aPrivateDispelIndicatorType;
	else
		tDesiredAlpha = aPrivateDispelOverlay and 1 or 0;
		tDesiredType = aPrivateDispelIndicatorType > 0 and aPrivateDispelIndicatorType or aDispelIndicatorType;
	end

	tCachedType = aButton["privateAuraDispelContainerActiveType"];

	if tCachedType ~= tDesiredType and tDesiredType > 0 then
		aDispelOverlayContainer:SetAttribute("dispel-indicator-option", tDesiredType);
		aDispelOverlayContainer:SetAttribute("update-settings", true);
		aButton["privateAuraDispelContainerActiveType"] = tDesiredType;
	end

	if tDesiredAlpha == 0 then
		aDispelOverlayContainer:SetAlpha(0);
	else
		VUHDO_deferTask(VUHDO_DEFER_SHOW_PRIVATE_AURA_DISPEL_OVERLAY,
			VUHDO_DEFERRED_TASK_PRIORITY_CRITICAL, aButton, aUnit);
	end

	return;

end



--
local tShowDispelOverlayContainer;
local tShowPanelNum;
local tShowPanelSetup;
local tShowPrivateAuraSetup;
local tShowBarColors;
local tShowPrivateDispelOverlay;
local tShowPrivateDispelIndicatorType;
local tShowActivePrivateDispelIndicatorType;
local tShowDispelOverlayFlag;
local tShowDispelIndicatorTypeNum;
local tShowActiveDispelIndicatorType;
local tShowHasRegularNow;
local tShowStillWantReveal;
function VUHDO_showPrivateAuraDispelOverlay(aButton, aUnit)

	if not aButton or not aUnit then
		return;
	end

	tShowDispelOverlayContainer = VUHDO_getPrivateAuraDispelOverlayContainer(aButton);

	if not tShowDispelOverlayContainer or not tShowDispelOverlayContainer:IsShown()
		or not aButton["privateAuraDispelContainerAnchorId"] then
		return;
	end

	tShowPanelNum = VUHDO_BUTTON_CACHE[aButton];
	tShowPanelSetup = tShowPanelNum and VUHDO_PANEL_SETUP[tShowPanelNum];
	tShowPrivateAuraSetup = tShowPanelSetup and tShowPanelSetup["PRIVATE_AURA"];

	if not tShowPrivateAuraSetup or not tShowPrivateAuraSetup["show"] then
		return;
	end

	tShowBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];
	tShowDispelOverlayFlag = tShowBarColors and tShowBarColors["showDispelOverlay"];
	tShowDispelIndicatorTypeNum = (tShowBarColors and tShowBarColors["dispelIndicatorType"]) or 0;
	tShowActiveDispelIndicatorType = (tShowDispelOverlayFlag and tShowDispelIndicatorTypeNum > 0) and tShowDispelIndicatorTypeNum or 0;

	tShowPrivateDispelOverlay = tShowPrivateAuraSetup["showDispelOverlay"];

	if tShowPrivateDispelOverlay == nil then
		tShowPrivateDispelOverlay = (VUHDO_PANEL_SETUP["PRIVATE_AURA_SHOW_DISPEL_TYPE"] ~= false);
	end

	tShowPrivateDispelIndicatorType = tShowPrivateAuraSetup["dispelIndicatorType"] or 0;
	tShowActivePrivateDispelIndicatorType = (tShowPrivateDispelOverlay and tShowPrivateDispelIndicatorType > 0) and tShowPrivateDispelIndicatorType or 0;

	if tShowActiveDispelIndicatorType == 2 then
		tShowHasRegularNow = VUHDO_hasAnyDispellableAura(aUnit);
	else
		tShowHasRegularNow = VUHDO_hasDispellableAura(aUnit);
	end

	if tShowHasRegularNow then
		tShowStillWantReveal = tShowActiveDispelIndicatorType > 0;
	else
		tShowStillWantReveal = tShowActivePrivateDispelIndicatorType > 0;
	end

	if tShowStillWantReveal then
		tShowDispelOverlayContainer:SetAlpha(1);
	end

	return;

end



--
local tButtonsForUnit;
local tPanelSetup;
local tPrivateAuraSetup;
local tDispelOverlayContainer;
local tPrivateDispelIndicatorType;
local tPrivateDispelOverlay;
local tBarColors;
local tDispelOverlayFlag;
local tDispelIndicatorTypeNum;
local tActivePrivateDispelIndicatorType;
local tActiveDispelIndicatorType;
local tInitialDispelIndicatorType;
local tAnyOverlayWanted;
local tGroupType;
local tNumAuras;
local tDurationPos;
local tPoint;
local tRelativePoint;
local tDurationAnchor;
local tPrivateAura;
local tPrivateAuraAnchor;
local tIconSize;
local tIconSizePercent;
local tBarHeight;
local tVisualSize;
local tDurationFrame;
local tToggleLevel;
function VUHDO_refreshPrivateAuraDispelOverlay(aUnit)

	if not aUnit then
		return;
	end

	tButtonsForUnit = VUHDO_getUnitButtons(aUnit);

	if not tButtonsForUnit then
		return;
	end

	tBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];
	tDispelOverlayFlag = tBarColors and tBarColors["showDispelOverlay"];
	tDispelIndicatorTypeNum = (tBarColors and tBarColors["dispelIndicatorType"]) or 0;
	tActiveDispelIndicatorType = (tDispelOverlayFlag and tDispelIndicatorTypeNum > 0) and tDispelIndicatorTypeNum or 0;

	for _, tButton in pairs(tButtonsForUnit) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];
		tPanelSetup = tPanelNum and VUHDO_PANEL_SETUP[tPanelNum];

		if tPanelSetup then
			tPrivateAuraSetup = tPanelSetup["PRIVATE_AURA"];

			if tPrivateAuraSetup and tPrivateAuraSetup["show"]
				and tButton["privateAuraDispelContainerAnchorId"] then

				tPrivateDispelOverlay = tPrivateAuraSetup["showDispelOverlay"];

				if tPrivateDispelOverlay == nil then
					tPrivateDispelOverlay = (VUHDO_PANEL_SETUP["PRIVATE_AURA_SHOW_DISPEL_TYPE"] ~= false);
				end

				tPrivateDispelIndicatorType = tPrivateAuraSetup["dispelIndicatorType"] or 0;
				tActivePrivateDispelIndicatorType = (tPrivateDispelOverlay and tPrivateDispelIndicatorType > 0) and tPrivateDispelIndicatorType or 0;

				tDispelOverlayContainer = VUHDO_getPrivateAuraDispelOverlayContainer(tButton);

				VUHDO_updatePrivateAuraDispelOverlayVisibility(aUnit, tButton, tDispelOverlayContainer,
					tPrivateDispelOverlay, tActivePrivateDispelIndicatorType, tDispelOverlayFlag, tActiveDispelIndicatorType);
			end
		end
	end

	return;

end



--
function VUHDO_refreshPrivateAuras(aPanelNum, aButton, aUnit)

	if not aPanelNum or not aButton or not aUnit then
		return;
	end

	tPanelSetup = VUHDO_PANEL_SETUP[aPanelNum];

	if not tPanelSetup then
		return;
	end

	if VUHDO_isSpecialUnit(aUnit) then
		VUHDO_removePrivateAuras(aButton);

		return;
	end

	tPrivateAuraSetup = tPanelSetup["PRIVATE_AURA"];

	if not tPrivateAuraSetup or not tPrivateAuraSetup["show"] then
		VUHDO_removePrivateAuraDispelContainer(aButton);

		VUHDO_clearPrivateAuraDispelContainerCache(aButton);

		tDispelOverlayContainer = VUHDO_getPrivateAuraDispelOverlayContainer(aButton);

		if tDispelOverlayContainer and not InCombatLockdown() then
			tDispelOverlayContainer:Hide();
		end

		if tPrivateAuraSetup and not tPrivateAuraSetup["show"] then
			TriggerPrivateAuraShowDispelType(false);
		end

		return;
	end

	tPrivateDispelIndicatorType = tPrivateAuraSetup["dispelIndicatorType"];

	if tPrivateDispelIndicatorType == nil then
		tPrivateDispelIndicatorType = (VUHDO_PANEL_SETUP["PRIVATE_AURA_SHOW_DISPEL_TYPE"] ~= false) and 1 or 0;
	end

	tPrivateDispelOverlay = tPrivateAuraSetup["showDispelOverlay"];

	if tPrivateDispelOverlay == nil then
		tPrivateDispelOverlay = (VUHDO_PANEL_SETUP["PRIVATE_AURA_SHOW_DISPEL_TYPE"] ~= false);
	end

	tBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];
	tDispelOverlayFlag = tBarColors and tBarColors["showDispelOverlay"];
	tDispelIndicatorTypeNum = (tBarColors and tBarColors["dispelIndicatorType"]) or 0;

	tActivePrivateDispelIndicatorType = (tPrivateDispelOverlay and tPrivateDispelIndicatorType > 0) and tPrivateDispelIndicatorType or 0;
	tActiveDispelIndicatorType = (tDispelOverlayFlag and tDispelIndicatorTypeNum > 0) and tDispelIndicatorTypeNum or 0;

	tInitialDispelIndicatorType = tActivePrivateDispelIndicatorType > 0 and tActivePrivateDispelIndicatorType or tActiveDispelIndicatorType;

	tAnyOverlayWanted = tInitialDispelIndicatorType > 0;

	tGroupType = VUHDO_GROUP_TYPE_RAID == VUHDO_getCurrentGroupType() and 5 or 4;

	tDispelOverlayContainer = VUHDO_getPrivateAuraDispelOverlayContainer(aButton);

	TriggerPrivateAuraShowDispelType(tAnyOverlayWanted);

	if InCombatLockdown() then
		if tAnyOverlayWanted and tDispelOverlayContainer
			and aButton["privateAuraDispelContainerConfigured"] and aButton["privateAuraDispelContainerType"] == tInitialDispelIndicatorType
			and aButton["privateAuraDispelContainerGroupType"] == tGroupType then
			tDispelOverlayContainer:SetAlpha(1);
			VUHDO_addPrivateAuraDispelContainerAnchor(aButton, aUnit, tDispelOverlayContainer);
			VUHDO_updatePrivateAuraDispelOverlayVisibility(aUnit, aButton, tDispelOverlayContainer,
				tPrivateDispelOverlay, tActivePrivateDispelIndicatorType, tDispelOverlayFlag, tActiveDispelIndicatorType);
		else
			VUHDO_removePrivateAuraDispelContainer(aButton);
		end

		if (not tAnyOverlayWanted) or (not tDispelOverlayContainer)
			or (not aButton["privateAuraDispelContainerConfigured"]) or aButton["privateAuraDispelContainerType"] ~= tInitialDispelIndicatorType
			or aButton["privateAuraDispelContainerGroupType"] ~= tGroupType then
			VUHDO_deferTask(VUHDO_DEFER_REFRESH_PRIVATE_AURAS, VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, aPanelNum, aButton, aUnit);
		end
	else
		VUHDO_removePrivateAuraDispelContainer(aButton);

		if tAnyOverlayWanted and tDispelOverlayContainer then
			tDispelOverlayContainer:SetAttribute("max-buffs", 0);
			tDispelOverlayContainer:SetAttribute("max-debuffs", 0);
			tDispelOverlayContainer:SetAttribute("max-dispel-debuffs", 1);
			tDispelOverlayContainer:SetAttribute("ignore-buffs", true);
			tDispelOverlayContainer:SetAttribute("ignore-debuffs", true);
			tDispelOverlayContainer:SetAttribute("show-dispel-indicator-overlay", true);
			tDispelOverlayContainer:SetAttribute("suppress-dispel-border-icons", true);
			tDispelOverlayContainer:SetAttribute("dispel-indicator-option", tInitialDispelIndicatorType);
			tDispelOverlayContainer:SetAttribute("aura-organization-type", 0);
			tDispelOverlayContainer:SetAttribute("group-type", tGroupType);
			tDispelOverlayContainer:SetAttribute("power-bar-used-height", 0);
			tDispelOverlayContainer:SetAttribute("set-aura-size-to-icon-size", false);

			aButton["privateAuraDispelContainerConfigured"] = true;
			aButton["privateAuraDispelContainerType"] = tInitialDispelIndicatorType;
			aButton["privateAuraDispelContainerGroupType"] = tGroupType;

			aButton["privateAuraDispelContainerActiveType"] = tInitialDispelIndicatorType;

			tDispelOverlayContainer:Show();

			tDispelOverlayContainer:SetAlpha(1);

			VUHDO_addPrivateAuraDispelContainerAnchor(aButton, aUnit, tDispelOverlayContainer);

			VUHDO_updatePrivateAuraDispelOverlayVisibility(aUnit, aButton, tDispelOverlayContainer,
				tPrivateDispelOverlay, tActivePrivateDispelIndicatorType, tDispelOverlayFlag, tActiveDispelIndicatorType);
		else
			VUHDO_clearPrivateAuraDispelContainerCache(aButton);

			if tDispelOverlayContainer then
				tDispelOverlayContainer:Hide();
			end
		end
	end

	tNumAuras = tPrivateAuraSetup["numAuras"] or 3;

	if tPrivateAuraSetup["showDuration"] and tPrivateAuraSetup["durationPosition"] then
		tDurationPos = tPrivateAuraSetup["durationPosition"];

		if "BOTTOM" == tDurationPos then
			tPoint = "TOP";
			tRelativePoint = "BOTTOM";
		elseif "TOP" == tDurationPos then
			tPoint = "BOTTOM";
			tRelativePoint = "TOP";
		elseif "LEFT" == tDurationPos then
			tPoint = "RIGHT";
			tRelativePoint = "LEFT";
		else
			tPoint = "LEFT";
			tRelativePoint = "RIGHT";
		end

		twipe(sDurationAnchor);

		sDurationAnchor["point"] = tPoint;
		sDurationAnchor["relativeTo"] = nil;
		sDurationAnchor["relativePoint"] = tRelativePoint;
		sDurationAnchor["offsetX"] = tPrivateAuraSetup["durationOffsetX"] or 0;
		sDurationAnchor["offsetY"] = tPrivateAuraSetup["durationOffsetY"] or 0;

		tDurationAnchor = sDurationAnchor;
	else
		tDurationAnchor = nil;
	end

	for tAuraIndex = 1, tNumAuras do
		tPrivateAura = VUHDO_getPrivateAuraIcon(aButton, tAuraIndex);

		if not tPrivateAura then
			return;
		end

		if tPrivateAura["anchorId"] then
			RemovePrivateAuraAnchor(tPrivateAura["anchorId"]);

			tPrivateAura["anchorId"] = nil;
		end

		tIconSize = 32;

		tPrivateAuraAnchor = {
			unitToken = aUnit,
			auraIndex = tAuraIndex,
			parent = tPrivateAura,
			showCountdownFrame = tPrivateAuraSetup["showCooldown"] ~= false,
			showCountdownNumbers = tPrivateAuraSetup["showCooldownNumbers"] ~= false,
			isContainer = false,
			iconInfo = {
				iconWidth = tIconSize,
				iconHeight = tIconSize,
				iconAnchor = {
					point = "CENTER",
					relativeTo = tPrivateAura,
					relativePoint = "CENTER",
					offsetX = 0,
					offsetY = 0,
				},
			},
		};

		if tPrivateAuraSetup["showBorder"] then
			tIconSizePercent = tPrivateAuraSetup["iconSize"] or 40;

			tBarHeight = tPanelSetup["SCALING"]["barHeight"];

			if tIconSizePercent > 100 then
				tVisualSize = min(tBarHeight, tIconSizePercent);
			else
				tVisualSize = tBarHeight * (tIconSizePercent == 0 and 100 or tIconSizePercent) * 0.01;
			end

			tPrivateAuraAnchor["iconInfo"]["borderScale"] = tVisualSize / 32;
		else
			tPrivateAuraAnchor["iconInfo"]["borderScale"] = -10000;
		end

		if tDurationAnchor then
			tDurationFrame = nil;

			if not tPrivateAuraSetup["showTooltip"] then
				tDurationFrame = VUHDO_getPrivateAuraDuration(aButton, tAuraIndex);
			end

			tPrivateAuraAnchor["durationAnchor"] = {
				["point"] = tDurationAnchor["point"],
				["relativeTo"] = tDurationFrame or tPrivateAura,
				["relativePoint"] = tDurationAnchor["relativePoint"],
				["offsetX"] = tDurationAnchor["offsetX"],
				["offsetY"] = tDurationAnchor["offsetY"],
			};
		end

		tPrivateAura["anchorId"] = AddPrivateAuraAnchor(tPrivateAuraAnchor);

		tToggleLevel = tPrivateAura:GetFrameLevel();

		VUHDO_PixelUtil.SetFrameLevel(tPrivateAura, 0);
		VUHDO_PixelUtil.SetFrameLevel(tPrivateAura, tToggleLevel);
	end

	return;

end



--
local tDispelOverlayContainer;
local tPrivateAura;
function VUHDO_removePrivateAuras(aButton)

	VUHDO_removePrivateAuraDispelContainer(aButton);

	VUHDO_clearPrivateAuraDispelContainerCache(aButton);

	if not InCombatLockdown() then
		tDispelOverlayContainer = VUHDO_getPrivateAuraDispelOverlayContainer(aButton);

		if tDispelOverlayContainer then
			tDispelOverlayContainer:Hide();
		end
	end

	for tAuraIndex = 1, VUHDO_MAX_PRIVATE_AURAS do
		tPrivateAura = VUHDO_getPrivateAuraIcon(aButton, tAuraIndex);

		if not tPrivateAura then
			return;
		end

		if tPrivateAura["anchorId"] then
			RemovePrivateAuraAnchor(tPrivateAura["anchorId"]);

			tPrivateAura["anchorId"] = nil;
		end

		if not InCombatLockdown() then
			tPrivateAura:Hide();
		end
	end

	return;

end