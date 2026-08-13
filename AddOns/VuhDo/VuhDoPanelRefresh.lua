local _G = _G;

local table = table;
local ipairs = ipairs;
local twipe = table.wipe;
local InCombatLockdown = InCombatLockdown;

local RemovePrivateAuraAnchor = C_UnitAuras and C_UnitAuras.RemovePrivateAuraAnchor;
local AddPrivateAuraAnchor = C_UnitAuras and C_UnitAuras.AddPrivateAuraAnchor;

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
local VUHDO_isSpecialUnit;
local VUHDO_getPrivateAuraIcon;
local VUHDO_getUnitButtons;
local VUHDO_deferTask;
local VUHDO_getPanelButtonInitRev;
local VUHDO_startRefreshButtonInits;
local VUHDO_enqueueRefreshButtonInit;
local VUHDO_waitRefreshButtonInits;

local sRefreshUiNoMembers;
local sShowPanels;
local sDurationAnchor = { };
local sDeferredRefreshCount = 0;
local sStaleButtonIndices = { };



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
	VUHDO_isSpecialUnit = _G["VUHDO_isSpecialUnit"];
	VUHDO_getPrivateAuraIcon = _G["VUHDO_getPrivateAuraIcon"];
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_deferTask = _G["VUHDO_deferTask"];
	VUHDO_getPanelButtonInitRev = _G["VUHDO_getPanelButtonInitRev"];
	VUHDO_startRefreshButtonInits = _G["VUHDO_startRefreshButtonInits"];
	VUHDO_enqueueRefreshButtonInit = _G["VUHDO_enqueueRefreshButtonInit"];
	VUHDO_waitRefreshButtonInits = _G["VUHDO_waitRefreshButtonInits"];

	if VUHDO_CONFIG["USE_DEFERRED_REDRAW"] then
		sRefreshUiNoMembers = _G["VUHDO_deferRefreshUiNoMembers"];
	else
		sRefreshUiNoMembers = _G["VUHDO_refreshUiNoMembers"];
	end

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

			if tButton["initRevision"] ~= VUHDO_getPanelButtonInitRev(aPanelNum) then
				VUHDO_initHealButton(tButton, aPanelNum);
			end

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

		VUHDO_clearAuraContainersForButton(tButton);

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



--
function VUHDO_refreshUI()

	VUHDO_IS_RELOADING = true;

	VUHDO_reloadRaidMembers();

	sRefreshUiNoMembers();

	VUHDO_IS_RELOADING = false;

	return;

end



--
function VUHDO_deferRefreshUiNoMembers()

	VUHDO_resetNameTextCache();

	twipe(VUHDO_UNIT_BUTTONS);
	twipe(VUHDO_UNIT_BUTTONS_PANEL);

	sDeferredRefreshCount = sDeferredRefreshCount + 1;

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		VUHDO_deferTask(VUHDO_DEFER_REFRESH_PANEL, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, tPanelNum);
	end

	VUHDO_deferTask(VUHDO_DEFER_REFRESH_UI_COMPLETE, VUHDO_DEFERRED_TASK_PRIORITY_NORMAL);

	return;

end



--
local tButtonIdx;
local tModels;
local tSortBy;
local tSetup;
local tGroupArray;
local tButton;
function VUHDO_deferRefreshPanelDelegate(aPanelNum)

	if not VUHDO_isPanelVisible(aPanelNum) then
		VUHDO_PixelUtil.Hide(VUHDO_getActionPanelOrStub(aPanelNum));

		return;
	end

	tSetup = VUHDO_PANEL_SETUP[aPanelNum];
	tModels = VUHDO_getDynamicModelArray(aPanelNum);
	tSortBy = tSetup["MODEL"]["sort"];

	twipe(sStaleButtonIndices);

	tButtonIdx = 1;

	VUHDO_initLocalVars(aPanelNum);

	for tModelIndex, tModelId in ipairs(tModels) do
		tGroupArray = VUHDO_getGroupMembersSorted(tModelId, tSortBy, aPanelNum, tModelIndex);

		for tGroupIdx, tUnit in ipairs(tGroupArray) do
			tButton = VUHDO_getOrCreateHealButton(tButtonIdx, aPanelNum);
			tButtonIdx = tButtonIdx + 1;

			if tButton["initRevision"] ~= VUHDO_getPanelButtonInitRev(aPanelNum) then
				sStaleButtonIndices[#sStaleButtonIndices + 1] = tButtonIdx - 1;
			end
		end
	end

	if #sStaleButtonIndices > 0 and VUHDO_startRefreshButtonInits(aPanelNum, #sStaleButtonIndices) then
		for tStaleCnt = 1, #sStaleButtonIndices do
			VUHDO_enqueueRefreshButtonInit(aPanelNum, sStaleButtonIndices[tStaleCnt]);
		end
	end

	VUHDO_deferTask(VUHDO_DEFER_REFRESH_PANEL_COMPLETE, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum);

	return;

end



--
function VUHDO_deferRefreshPanelCompleteDelegate(aPanelNum)

	if not VUHDO_waitRefreshButtonInits(aPanelNum, VUHDO_DEFER_REFRESH_PANEL_COMPLETE, VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum) then
		return;
	end

	VUHDO_refreshPanel(aPanelNum);

	return;

end



--
function VUHDO_deferRefreshUiCompleteDelegate()

	VUHDO_updateAllRaidBars();
	VUHDO_updatePanelVisibility();
	VUHDO_PixelUtil.Hide(VuhDoGcdStatusBar);

	VUHDO_updateAllCustomDebuffs(true);

	VUHDO_refreshAllUnitAuras();

	if VUHDO_INTERNAL_TOGGLES[22] then -- VUHDO_UPDATE_UNIT_TARGET
		VUHDO_rebuildTargets();
	end

	VUHDO_initAllEventBouquets();

	if sDeferredRefreshCount > 0 then
		sDeferredRefreshCount = sDeferredRefreshCount - 1;
	end

	return;

end



--
function VUHDO_isDeferredRefreshActive()

	return sDeferredRefreshCount > 0;

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
local tPanelSetup;
local tPrivateAuraSetup;
local tNumAuras;
local tDurationPos;
local tPoint;
local tRelativePoint;
local tDurationAnchor;
local tPrivateAura;
local tPrivateAuraAnchor;
local tDurationFrame;
local tToggleLevel;
local tTextScale;
local tShowDispelIcon;
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
		VUHDO_removePrivateAuras(aButton);

		return;
	end

	tShowDispelIcon = tPrivateAuraSetup["showDispelIcon"];

	if tShowDispelIcon == nil then
		tShowDispelIcon = false;
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

	tTextScale = (tPrivateAuraSetup["textScale"] or 100) * 0.01;

	for tAuraIndex = 1, tNumAuras do
		tPrivateAura = VUHDO_getPrivateAuraIcon(aButton, tAuraIndex);

		if not tPrivateAura then
			return;
		end

		if tPrivateAura["anchorId"] then
			RemovePrivateAuraAnchor(tPrivateAura["anchorId"]);

			tPrivateAura["anchorId"] = nil;
		end

		tPrivateAuraAnchor = {
			unitToken = aUnit,
			auraIndex = tAuraIndex,
			parent = tPrivateAura,
			showCountdownFrame = tPrivateAuraSetup["showCooldown"] ~= false,
			showCountdownNumbers = tPrivateAuraSetup["showCooldownNumbers"] ~= false,
			showDispelIcon = tShowDispelIcon,
			isContainer = false,
			iconInfo = {
				iconWidth = 32 / tTextScale,
				iconHeight = 32 / tTextScale,
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
			tPrivateAuraAnchor["iconInfo"]["borderScale"] = 1 / tTextScale;
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
local tPrivateAura;
function VUHDO_removePrivateAuras(aButton)

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