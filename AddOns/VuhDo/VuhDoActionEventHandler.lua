local _;

local VUHDO_IS_SMART_CAST = false;

local VUHDO_setStatusBarVuhDoColor;
local VUHDO_applyAllLayersToBar;

local SecureButton_GetButtonSuffix = SecureButton_GetButtonSuffix;
local GetTexCoordsForRole = GetTexCoordsForRole or VUHDO_getTexCoordsForRole;
local InCombatLockdown = InCombatLockdown;
local strlower = strlower;
local strfind = strfind;
local pairs = pairs;
local GameTooltip = GameTooltip;

local sMouseoverUnit = nil;
local sSecretsEnabled = VUHDO_SECRETS_ENABLED;

local VUHDO_updateBouquetsForEvent;
local VUHDO_highlightClusterFor;
local VUHDO_showTooltip;
local VUHDO_hideTooltip;
local VUHDO_getMouseFocus;
local VUHDO_showAuraTooltip;
local VUHDO_resetClusterUnit;
local VUHDO_removeAllClusterHighlights;
local VUHDO_getHealthBar;
local VUHDO_findButtonFromChild;
local VUHDO_setupSmartCast;
local VUHDO_updateDirectionFrame;
local VUHDO_getCurrentKeyModifierString;
local VUHDO_redrawAllPanels;
local VUHDO_displayPlayerIcon;
local VUHDO_hidePlayerIconsForButton;
local VUHDO_getBarRoleIcon;
local VUHDO_suspendSpecialDot;

local VUHDO_SPELL_CONFIG;
local VUHDO_SPELL_ASSIGNMENTS;
local VUHDO_getUnitButtonsSafe;
local VUHDO_CONFIG;
local VUHDO_INTERNAL_TOGGLES;
local VUHDO_RAID;



--
function VUHDO_actionEventHandlerInitLocalOverrides()

	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_highlightClusterFor = _G["VUHDO_highlightClusterFor"];
	VUHDO_showTooltip = _G["VUHDO_showTooltip"];
	VUHDO_hideTooltip = _G["VUHDO_hideTooltip"];
	VUHDO_getMouseFocus = _G["VUHDO_getMouseFocus"];
	VUHDO_showAuraTooltip = _G["VUHDO_showAuraTooltip"];
	VUHDO_resetClusterUnit = _G["VUHDO_resetClusterUnit"];
	VUHDO_removeAllClusterHighlights = _G["VUHDO_removeAllClusterHighlights"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_findButtonFromChild = _G["VUHDO_findButtonFromChild"];
	VUHDO_setupSmartCast = _G["VUHDO_setupSmartCast"];
	VUHDO_updateDirectionFrame = _G["VUHDO_updateDirectionFrame"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_getCurrentKeyModifierString = _G["VUHDO_getCurrentKeyModifierString"];
	VUHDO_setStatusBarVuhDoColor = _G["VUHDO_setStatusBarVuhDoColor"];
	VUHDO_applyAllLayersToBar = _G["VUHDO_applyAllLayersToBar"];
	VUHDO_displayPlayerIcon = _G["VUHDO_displayPlayerIcon"];
	VUHDO_hidePlayerIconsForButton = _G["VUHDO_hidePlayerIconsForButton"];
	VUHDO_getBarRoleIcon = _G["VUHDO_getBarRoleIcon"];
	VUHDO_suspendSpecialDot = _G["VUHDO_suspendSpecialDot"];

	VUHDO_SPELL_CONFIG = _G["VUHDO_SPELL_CONFIG"];
	VUHDO_SPELL_ASSIGNMENTS = _G["VUHDO_SPELL_ASSIGNMENTS"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_INTERNAL_TOGGLES = _G["VUHDO_INTERNAL_TOGGLES"];
	VUHDO_RAID = _G["VUHDO_RAID"];

	if VUHDO_CONFIG["USE_DEFERRED_REDRAW"] then
		VUHDO_redrawAllPanels = _G["VUHDO_deferRedrawAllPanels"];
	else
		VUHDO_redrawAllPanels = _G["VUHDO_redrawAllPanels"];
	end

	return;

end



--
function VUHDO_getCurrentMouseOver()
	return sMouseoverUnit;
end



--
local function VUHDO_placePlayerIcon(aButton, anIconNo, anIndex)
	VUHDO_getBarIconTimer(aButton, anIconNo):SetText("");
	VUHDO_getBarIconCounter(aButton, anIconNo):SetText("");
	VUHDO_getBarIconCharge(aButton, anIconNo):Hide();

	local tFrame = VUHDO_getBarIconFrame(aButton, anIconNo);
	VUHDO_PixelUtil.SetScale(tFrame, 1);
	tFrame:Show();

	local anIcon = VUHDO_getBarIcon(aButton, anIconNo);
	anIcon:ClearAllPoints();
	if 2 == anIndex then
		VUHDO_PixelUtil.SetPoint(anIcon, "CENTER", aButton:GetName(), "TOPRIGHT", -5, -10);
	else
		if anIndex > 2 then anIndex = anIndex - 1; end
		local tCol = floor(anIndex * 0.5);
		local tRow = anIndex - tCol * 2;
		VUHDO_PixelUtil.SetPoint(anIcon, "TOPLEFT", aButton:GetName(), "TOPLEFT", tCol * 14, -tRow * 14);
	end

	VUHDO_PixelUtil.SetWidth(anIcon, 16);
	VUHDO_PixelUtil.SetHeight(anIcon, 16);
	anIcon:SetAlpha(1);
	anIcon:SetVertexColor(1, 1, 1);
	anIcon:Show();
end



--
local tUnitNo, tRank;
local tIsLeader;
local tIsAssist;
local tIsMasterLooter;
function VUHDO_getUnitGroupPrivileges(aUnit)
	tIsLeader, tIsAssist, tIsMasterLooter = false, false, false;

	if VUHDO_GROUP_TYPE_RAID == VUHDO_getCurrentGroupType() then
		tUnitNo = VUHDO_getUnitNo(aUnit);
		if tUnitNo then
			_, tRank, _, _, _, _, _, _, _, _, tIsMasterLooter = GetRaidRosterInfo(tUnitNo);
			if 2 == tRank then tIsLeader = true;
			elseif 1 == tRank then tIsAssist = true; end
		end
	else
		tIsLeader = UnitIsGroupLeader(aUnit);
	end

	return tIsLeader, tIsAssist, tIsMasterLooter;
end



--
local tIcon;
local function VUHDO_showPlayerIcons(aButton, aPanelNum)
	local tUnit = aButton:GetAttribute("unit");
	local tInfo = VUHDO_RAID[tUnit];
	if not tInfo then	return; end

	local tIsLeader, tIsAssist, tIsMasterLooter = VUHDO_getUnitGroupPrivileges(tUnit);

	if sSecretsEnabled then
		if tIsLeader or tIsAssist then
			VUHDO_displayPlayerIcon(aButton, 1,
				"Interface\\groupframe\\ui-group-" .. (tIsLeader and "leader" or "assistant") .. "icon",
				nil, 16, 16, 0);
		end

		if tIsMasterLooter then
			VUHDO_displayPlayerIcon(aButton, 2, "Interface\\groupframe\\ui-group-masterlooter", nil, 16, 16, 1);
		end

		if UnitIsPVP(tUnit) and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["barWidth"] > 54 then
			VUHDO_displayPlayerIcon(aButton, 3,
				"Interface\\groupframe\\ui-group-pvp-"
					.. ("Alliance" == (UnitFactionGroup(tUnit)) and "alliance" or "horde"),
				nil, 32, 32, 2);
		end

		if tInfo["class"] then
			VUHDO_displayPlayerIcon(aButton, 4, "Interface\\TargetingFrame\\UI-Classes-Circles",
				CLASS_ICON_TCOORDS[tInfo["class"]], 16, 16, 3);
		end

		if tInfo["role"] then
			VUHDO_displayPlayerIcon(aButton, 5, "Interface\\LFGFrame\\UI-LFG-ICON-ROLES",
				{ GetTexCoordsForRole(
					VUHDO_ID_MELEE_TANK == tInfo["role"] and "TANK"
					or VUHDO_ID_RANGED_HEAL == tInfo["role"] and "HEALER" or "DAMAGER") },
				16, 16, 5);
		end
	else
		if tIsLeader or tIsAssist then
			tIcon = VUHDO_getOrCreateHotIcon(aButton, 1);

			tIcon:SetTexture(
				"Interface\\groupframe\\ui-group-" .. (tIsLeader and "leader" or "assistant") .. "icon");
			VUHDO_PixelUtil.ApplySettings(tIcon);
			VUHDO_placePlayerIcon(aButton, 1, 0);
		end

		if tIsMasterLooter then
			tIcon = VUHDO_getOrCreateHotIcon(aButton, 2);

			tIcon:SetTexture("Interface\\groupframe\\ui-group-masterlooter");
			VUHDO_PixelUtil.ApplySettings(tIcon);
			VUHDO_placePlayerIcon(aButton, 2, 1);
		end

		if UnitIsPVP(tUnit) and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["barWidth"] > 54 then
			tIcon = VUHDO_getOrCreateHotIcon(aButton, 3);

			tIcon:SetTexture("Interface\\groupframe\\ui-group-pvp-"
				.. ("Alliance" == (UnitFactionGroup(tUnit)) and "alliance" or "horde"));
			VUHDO_PixelUtil.ApplySettings(tIcon);
			VUHDO_placePlayerIcon(aButton, 3, 2);
			VUHDO_PixelUtil.SetWidth(tIcon, 32);
			VUHDO_PixelUtil.SetHeight(tIcon, 32);
		end

		if tInfo["class"] then
			tIcon = VUHDO_getOrCreateHotIcon(aButton, 4);

			tIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
			VUHDO_PixelUtil.ApplySettings(tIcon);
			tIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[tInfo["class"]]));
			VUHDO_placePlayerIcon(aButton, 4, 3);
		end

		if tInfo["role"] then
			tIcon = VUHDO_getOrCreateHotIcon(aButton, 5);

			tIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-ROLES");
			VUHDO_PixelUtil.ApplySettings(tIcon);
			tIcon:SetTexCoord(GetTexCoordsForRole(
				VUHDO_ID_MELEE_TANK == tInfo["role"] and "TANK"
				or VUHDO_ID_RANGED_HEAL == tInfo["role"] and "HEALER"	or "DAMAGER"));
			VUHDO_placePlayerIcon(aButton, 5, 5);
		end
	end

	return;

end



--
function VUHDO_hideAllPlayerIcons()

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		VUHDO_initLocalVars(tPanelNum);

		for _, tButton in pairs(VUHDO_getPanelButtons(tPanelNum)) do
			if tButton:IsShown() then
				if sSecretsEnabled then
					VUHDO_hidePlayerIconsForButton(tButton);
				else
					VUHDO_initButtonStatics(tButton, tPanelNum);
					VUHDO_initAllHotIcons(tPanelNum);
				end
			end
		end
	end

	if sSecretsEnabled then
		VUHDO_suspendAuras(false);
		VUHDO_showAllAuras();
		VUHDO_suspendSpecialDot(false);
	else
		VUHDO_removeAllHots();
		VUHDO_suspendHoTs(false);
	end

	return;

end



--
local function VUHDO_showAllPlayerIcons(aPanel)

	if sSecretsEnabled then
		VUHDO_suspendAuras(true);
		VUHDO_hideAllAuras();
		VUHDO_suspendSpecialDot(true);
	else
		VUHDO_suspendHoTs(true);
		VUHDO_removeAllHots();
	end

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		for _, tButton in pairs(VUHDO_getPanelButtons(tPanelNum)) do
			if tButton:IsShown() then
				VUHDO_showPlayerIcons(tButton, tPanelNum);

				VUHDO_getBarRoleIcon(tButton, 51):Hide();
			end
		end
	end

	return;

end



--
local tAllUnits;
local tInfo;
local tOldMouseover;
local tFocus;
function VuhDoActionOnEnter(aButton)

	tFocus = VUHDO_getMouseFocus();

	if tFocus and tFocus ~= aButton and tFocus["auraInstanceId"] then
		VUHDO_showAuraTooltip(tFocus);

		return;
	end

	VUHDO_showTooltip(aButton);

	tOldMouseover = sMouseoverUnit;
	sMouseoverUnit = aButton:GetAttribute("unit");

	if VUHDO_INTERNAL_TOGGLES[15] then -- VUHDO_UPDATE_MOUSEOVER
		VUHDO_updateBouquetsForEvent(tOldMouseover, 15); -- Seems to be ghosting sometimes, -- VUHDO_UPDATE_MOUSEOVER
		VUHDO_updateBouquetsForEvent(sMouseoverUnit, 15); -- VUHDO_UPDATE_MOUSEOVER
	end

	if VUHDO_isShowDirectionArrow() then
		VUHDO_updateDirectionFrame(aButton);
	end

	if VUHDO_isShowGcd() then
		VuhDoGcdStatusBar:ClearAllPoints();
		VuhDoGcdStatusBar:SetAllPoints(aButton);
		VuhDoGcdStatusBar:SetValue(0);
		VuhDoGcdStatusBar:Show();
	end

	if VUHDO_INTERNAL_TOGGLES[18] and sMouseoverUnit then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
		VUHDO_highlightClusterFor(sMouseoverUnit);
	end

	if VUHDO_INTERNAL_TOGGLES[20] then -- VUHDO_UPDATE_MOUSEOVER_GROUP
		tInfo = VUHDO_RAID[sMouseoverUnit];

		if not tInfo then
			return;
		end

		tAllUnits = VUHDO_GROUPS[tInfo["group"]];

		if tAllUnits then
			for _, tUnit in pairs(tAllUnits) do
				VUHDO_updateBouquetsForEvent(tUnit, 20); -- VUHDO_UPDATE_MOUSEOVER_GROUP
			end
		end
	end

	return;

end



--
local tOldMouseover;
local tAllUnits;
local tInfo;
function VuhDoActionOnLeave(aButton)

	tFocus = VUHDO_getMouseFocus();

	if tFocus and tFocus["auraInstanceId"] then
		return;
	end

	if tFocus and VUHDO_findButtonFromChild(tFocus) == aButton then
		return;
	end

	VUHDO_hideTooltip();

	VuhDoDirectionFrame["shown"] = false;
	VuhDoDirectionFrame:Hide();

	tOldMouseover = sMouseoverUnit;
	sMouseoverUnit = nil;

	if VUHDO_INTERNAL_TOGGLES[15] then -- VUHDO_UPDATE_MOUSEOVER
		VUHDO_updateBouquetsForEvent(tOldMouseover, 15); -- VUHDO_UPDATE_MOUSEOVER
	end

	if VUHDO_INTERNAL_TOGGLES[18] then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
		VUHDO_resetClusterUnit();
		VUHDO_removeAllClusterHighlights();
	end

	if VUHDO_INTERNAL_TOGGLES[20] then -- VUHDO_UPDATE_MOUSEOVER_GROUP
		tInfo = VUHDO_RAID[aButton:GetAttribute("unit")];

		if not tInfo then
			return;
		end

		tAllUnits = VUHDO_GROUPS[tInfo["group"]];

		if tAllUnits then
			for _, tUnit in pairs(tAllUnits) do
				VUHDO_updateBouquetsForEvent(tUnit, 20); -- VUHDO_UPDATE_MOUSEOVER_GROUP
			end
		end
	end

	return;

end



--
local tQuota, tHighlightBar;
function VUHDO_highlighterBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

	tQuota = (anIsActive or (aMaxValue or 0) > 1) and 1 or 0;

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		if VUHDO_INDICATOR_CONFIG[VUHDO_BUTTON_CACHE[tButton]]["BOUQUETS"]["MOUSEOVER_HIGHLIGHT"] == aBouquetName then
			tHighlightBar = VUHDO_getHealthBar(tButton, 8);

			tHighlightBar:SetMinMaxValues(0, 1);
			tHighlightBar:SetValue(tQuota);

			if anIsActive then
				if aLayerTemplate then
					VUHDO_applyAllLayersToBar(tButton, tHighlightBar, aLayerTemplate);
				elseif aColor then
					VUHDO_setStatusBarVuhDoColor(tHighlightBar, aColor);
				end
			end

			if sSecretsEnabled then
				VUHDO_updateIndicatorAlphaChain(tButton, "MOUSEOVER_HIGHLIGHT", VUHDO_RAID[aUnit]);
			end
		end
	end

end



--
local tModi;
local tKey;
function VuhDoActionPreClick(aButton, aMouseButton)
	tModi = VUHDO_getCurrentKeyModifierString();
	tKey = VUHDO_SPELL_ASSIGNMENTS[tModi .. SecureButton_GetButtonSuffix(aMouseButton)];

	-- allow VuhDo menu command to be bound even when using Clique compat mode
	if VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"] and 
		(strlower(tKey and tKey[3] or "") ~= "menu" or not VUHDO_CONFIG["IS_CLIQUE_PASSTHROUGH"]) then 
		return;
	end

	if tKey and strlower(tKey[3]) == "menu" then
		if not InCombatLockdown() then
			VUHDO_disableActions(aButton);
			VUHDO_IS_SMART_CAST = true;
		end
		VUHDO_setMenuUnit(aButton);
		ToggleDropDownMenu(1, nil, VuhDoPlayerTargetDropDown, aButton:GetName(), 0, -5);

	elseif tKey and strlower(tKey[3]) == "tell" then
		ChatFrame_SendTell(VUHDO_RAID[aButton:GetAttribute("unit")]["fullName"]);

	else
		if VUHDO_SPELL_CONFIG["smartCastModi"] == "all"
			or strfind(tModi, VUHDO_SPELL_CONFIG["smartCastModi"], 1, true) then
			VUHDO_IS_SMART_CAST = VUHDO_setupSmartCast(aButton);
		else
			VUHDO_IS_SMART_CAST = false;
		end
	end
end



--
function VuhDoActionPostClick(aButton)
	if VUHDO_IS_SMART_CAST then
		VUHDO_setupAllHealButtonAttributes(aButton, nil, false, false, false, false);
		VUHDO_IS_SMART_CAST = false;
	end
end


local sIsStatusShown = false;


---
function VUHDO_startMoving(aPanel)
	if VuhDoNewOptionsPanelPanel and VuhDoNewOptionsPanelPanel:IsVisible() then

		local tNewNum = VUHDO_getComponentPanelNum(aPanel);
		if tNewNum ~= DESIGN_MISC_PANEL_NUM then
			VuhDoNewOptionsTabbedFrame:Hide();
			DESIGN_MISC_PANEL_NUM = tNewNum;
			VuhDoNewOptionsTabbedFrame:Show();
			VUHDO_redrawAllPanels(false);
			return;
		end
	end

	if (IsMouseButtonDown(1) and VUHDO_mayMoveHealPanels()) then
		if (not aPanel["isMoving"]) then
			aPanel["isMoving"] = true;
			VUHDO_PixelUtil.SetFrameStrata(aPanel, "TOOLTIP");
			aPanel:StartMoving();
		end
	elseif IsMouseButtonDown(2) and not InCombatLockdown()
		and (not VuhDoNewOptionsPanelPanel or not VuhDoNewOptionsPanelPanel:IsVisible()) then
		VUHDO_showAllPlayerIcons(aPanel);
		sIsStatusShown = true;
	end
end



--
function VUHDO_stopMoving(aPanel)

	if not InCombatLockdown() then
		VUHDO_PixelUtil.StopMovingOrSizing(aPanel);

		VUHDO_PixelUtil.SetFrameStrata(aPanel, VUHDO_PANEL_SETUP[VUHDO_getPanelNum(aPanel)]["frameStrata"]);
	end

	aPanel["isMoving"] = false;

	VUHDO_savePanelCoords(aPanel);
	VUHDO_saveCurrentProfilePanelPosition(VUHDO_getPanelNum(aPanel));

	if sIsStatusShown then
		sIsStatusShown = false;

		VUHDO_hideAllPlayerIcons();
		VUHDO_initAllEventBouquets();
	end

	return;

end



--
local tPosition;
function VUHDO_savePanelCoords(aPanel)
	tPosition = VUHDO_PANEL_SETUP[VUHDO_getPanelNum(aPanel)]["POSITION"];
	tPosition["orientation"], _, tPosition["relativePoint"], tPosition["x"], tPosition["y"] = aPanel:GetPoint();
	tPosition["width"] = aPanel:GetWidth();
	tPosition["height"] = aPanel:GetHeight();
end



--
local tButton;
local sDebuffIcon = nil;
function VUHDO_showDebuffTooltip(aDebuffIcon)
	if not VUHDO_CONFIG["DEBUFF_TOOLTIP"] then return; end

	tButton = VUHDO_findButtonFromChild(aDebuffIcon);

	if not GameTooltip:IsForbidden() then
		GameTooltip:SetOwner(aDebuffIcon, "ANCHOR_RIGHT", 0, 0);
	end

	if aDebuffIcon["debuffInstanceId"] then
		if not GameTooltip:IsForbidden() then
			if aDebuffIcon["isBuff"] then 
				GameTooltip:SetUnitBuffByAuraInstanceID(tButton["raidid"], aDebuffIcon["debuffInstanceId"]);
			else 
				GameTooltip:SetUnitDebuffByAuraInstanceID(tButton["raidid"], aDebuffIcon["debuffInstanceId"]); 
			end
		end
	end
	sDebuffIcon = aDebuffIcon;
end



--
function VUHDO_hideDebuffTooltip()
	sDebuffIcon = nil;

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide();
	end
end



--
function VUHDO_updateCustomDebuffTooltip()
	if sDebuffIcon then VUHDO_showDebuffTooltip(sDebuffIcon); end
end
