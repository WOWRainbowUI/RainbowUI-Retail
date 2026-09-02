local _;

local VUHDO_RAID;
local VUHDO_IN_RAID_TARGET_BUTTONS;
local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;
local VUHDO_CONFIG;

local VUHDO_IMMEDIATE = Enum.StatusBarInterpolation.Immediate;

local pairs = pairs;
local twipe = table.wipe;

local UnitPowerType = UnitPowerType;
local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local InCombatLockdown = InCombatLockdown;

local VUHDO_getUnitButtonsSafe;
local VUHDO_getHealthBar;
local VUHDO_getRealParent;
local VUHDO_isConfigDemoUsers;
local VUHDO_updateBouquetsForEvent;
local VUHDO_indicatorTextCallback;
local VUHDO_setStatusBarVuhDoColor;
local VUHDO_applyAllLayersToBar;
local VUHDO_updateHealthLossBar;
local VUHDO_syncOverlaysForUnit;
local VUHDO_updateAuraAnchorHost;
local VUHDO_repositionAuraFramesForButton;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;
local sIsInverted;
local sIsHealthBarVertical;
local sManaInterpolation = { };
local sSideLeftInterpolation = { };
local sSideRightInterpolation = { };
local sPendingManaBarLayouts = { };



--
function VUHDO_customManaInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_IN_RAID_TARGET_BUTTONS = _G["VUHDO_IN_RAID_TARGET_BUTTONS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];

	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getRealParent = _G["VUHDO_getRealParent"];
	VUHDO_isConfigDemoUsers = _G["VUHDO_isConfigDemoUsers"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_indicatorTextCallback = _G["VUHDO_indicatorTextCallback"];
	VUHDO_setStatusBarVuhDoColor = _G["VUHDO_setStatusBarVuhDoColor"];
	VUHDO_applyAllLayersToBar = _G["VUHDO_applyAllLayersToBar"];
	VUHDO_updateHealthLossBar = _G["VUHDO_updateHealthLossBar"];
	VUHDO_syncOverlaysForUnit = _G["VUHDO_syncOverlaysForUnit"];
	VUHDO_updateAuraAnchorHost = _G["VUHDO_updateAuraAnchorHost"];
	VUHDO_repositionAuraFramesForButton = _G["VUHDO_repositionAuraFramesForButton"];

	VUHDO_syncOverlaysForUnit = _G["VUHDO_deferSyncOverlaysForUnit"];

	sIsInverted = { };
	sIsHealthBarVertical = { };

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		sIsInverted[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["MANA_BAR"]["invertGrowth"];
		sIsHealthBarVertical[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["vertical"];

		sManaInterpolation[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["MANA_BAR"]["smooth"]
			and Enum.StatusBarInterpolation.ExponentialEaseOut or Enum.StatusBarInterpolation.Immediate;
		sSideLeftInterpolation[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["SIDE_LEFT"]["smooth"]
			and Enum.StatusBarInterpolation.ExponentialEaseOut or Enum.StatusBarInterpolation.Immediate;
		sSideRightInterpolation[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["SIDE_RIGHT"]["smooth"]
			and Enum.StatusBarInterpolation.ExponentialEaseOut or Enum.StatusBarInterpolation.Immediate;
	end

end

----------------------------------------------------


--
local tInfo;
local tPowerType;
function VUHDO_updateManaBars(aUnit, aChange)

	tInfo = VUHDO_RAID[aUnit];

	if not tInfo then
		return;
	end

	if tInfo["isVehicle"] then
		aUnit = tInfo["petUnit"];

		if not aUnit then
			return;
		end

		tInfo = VUHDO_RAID[aUnit];

		if not tInfo then
			return;
		end
	end

	if not VUHDO_isConfigDemoUsers() then
		tPowerType, _ = UnitPowerType(aUnit);

		tInfo["powertype"] = tonumber(tPowerType);

		if 1 == aChange then
			tInfo["power"] = UnitPower(aUnit, tInfo["powertype"]);
		elseif 2 == aChange  then
			tInfo["powermax"] = UnitPowerMax(aUnit, tInfo["powertype"]);
		elseif 3 == aChange then
			tInfo["powermax"] = UnitPowerMax(aUnit, tInfo["powertype"]);
			tInfo["power"] = UnitPower(aUnit, tInfo["powertype"]);
		end

		if sSecretsEnabled then
			tInfo["hasSecretPower"] = issecretvalue(tInfo["power"]) or issecretvalue(tInfo["powermax"]);
		else
			tInfo["hasSecretPower"] = false;
		end
	end

	if tInfo["powertype"] == 0 then -- VUHDO_UNIT_POWER_MANA
		VUHDO_updateBouquetsForEvent(aUnit, 13); -- VUHDO_UPDATE_MANA

		if 3 == aChange then
			VUHDO_updateBouquetsForEvent(aUnit, 21); -- VUHDO_UPDATE_OTHER_POWERS
		end
	else
		VUHDO_updateBouquetsForEvent(aUnit, 21); -- VUHDO_UPDATE_OTHER_POWERS

		if 3 == aChange then
			VUHDO_updateBouquetsForEvent(aUnit, 13); -- VUHDO_UPDATE_MANA
		end
	end

	if 2 == aChange or 3 == aChange then
		VUHDO_syncOverlaysForUnit(aUnit);
	end

	return;

end



do
	--
	local tLayoutManaBar;
	local tLayoutHealthBar;
	local tLayoutRegularHeight;
	local tLayoutPrevHeight;
	function VUHDO_applyManaBarLayout(aButton, aPanelNum, aManaBarHeight, aUnit)

		if InCombatLockdown() then
			aButton["pendingManaPanelNum"] = aPanelNum;
			aButton["pendingManaBarHeight"] = aManaBarHeight;
			aButton["pendingManaUnit"] = aUnit;

			sPendingManaBarLayouts[aButton] = true;

			return;
		end

		sPendingManaBarLayouts[aButton] = nil;

		tLayoutManaBar = VUHDO_getHealthBar(aButton, 2);
		tLayoutPrevHeight = aButton["manaBarLayoutHeight"];

		aButton["manaBarLayoutHeight"] = aManaBarHeight;

		VUHDO_updateAuraAnchorHost(aButton);

		if aManaBarHeight > 0 then
			VUHDO_PixelUtil.SetHeight(tLayoutManaBar, aManaBarHeight);
			VUHDO_PixelUtil.Show(tLayoutManaBar);
		else
			VUHDO_PixelUtil.Hide(tLayoutManaBar);
		end

		tLayoutRegularHeight = aButton["regularHeight"];

		if tLayoutRegularHeight then
			tLayoutHealthBar = VUHDO_getHealthBar(aButton, 1);

			VUHDO_PixelUtil.ClearAllPoints(tLayoutHealthBar);
			VUHDO_PixelUtil.SetPoint(tLayoutHealthBar, "TOPLEFT", VUHDO_getRealParent(tLayoutHealthBar), "TOPLEFT", 0, 0);
			VUHDO_PixelUtil.SetSize(tLayoutHealthBar, aButton:GetWidth(), tLayoutRegularHeight - aManaBarHeight);

			if not sIsHealthBarVertical[aPanelNum] then
				VUHDO_PixelUtil.SetHeight(VUHDO_getHealthBar(aButton, 6), tLayoutRegularHeight - aManaBarHeight);
				VUHDO_PixelUtil.SetHeight(VUHDO_getHealthBar(aButton, 19), tLayoutRegularHeight - aManaBarHeight);
			end
		end

		if VUHDO_CONFIG["SHOW_HEALTH_LOSS_BAR"] then
			VUHDO_updateHealthLossBar(aUnit);
		end

		if tLayoutPrevHeight ~= aManaBarHeight then
			VUHDO_repositionAuraFramesForButton(aButton, aPanelNum);
		end

		return;

	end



	--
	function VUHDO_processPendingManaBarLayouts()

		for tButton, _ in pairs(sPendingManaBarLayouts) do
			VUHDO_applyManaBarLayout(tButton, tButton["pendingManaPanelNum"],
				tButton["pendingManaBarHeight"], tButton["pendingManaUnit"]);
		end

		twipe(sPendingManaBarLayouts);

		return;

	end
end



--
local tAllButtons, tManaBar;
local tManaBarHeight;
local tPanelNum;
local tInterpolation;
function VUHDO_manaBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate, anIsAliveTime, anEventType)

	if -1 == anEventType then -- VUHDO_UPDATE_BOUQUET_RESET
		return;
	end

	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;
	aCurrValue2 = aCurrValue2 or 0;

	tManaBarHeight = 0;

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];

		if aBouquetName == nil or VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["MANA_BAR"] == aBouquetName then
			tManaBarHeight = 0;

			if anIsActive then
				tManaBarHeight = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["manaBarHeight"];
			end

			tManaBar = VUHDO_getHealthBar(tButton, 2);

			tInterpolation = (tManaBar["forceImmediate"] or 1 == anEventType) and VUHDO_IMMEDIATE or sManaInterpolation[tPanelNum];
			tManaBar["forceImmediate"] = nil;

			if anIsActive and tManaBarHeight > 0 then
				tManaBar:SetMinMaxValues(0, aMaxValue);

				if tManaBar["isInverted"] then
					tManaBar:SetValue(sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue), tInterpolation);
				else
					tManaBar:SetValue(aCurrValue, tInterpolation);
				end

				if aLayerTemplate then
					VUHDO_applyAllLayersToBar(tButton, tManaBar, aLayerTemplate, "MANA_BAR", aBouquetName);
				elseif aColor then
					VUHDO_setStatusBarVuhDoColor(tManaBar, aColor);
				end
			else
				tManaBar:SetMinMaxValues(0, 1, Enum.StatusBarInterpolation.Immediate);
				tManaBar:SetValue((not anIsActive and tManaBar["isInverted"]) and 1 or 0);
			end

			VUHDO_applyManaBarLayout(tButton, tPanelNum, tManaBarHeight, aUnit);

			if sSecretsEnabled then
				VUHDO_updateIndicatorAlphaChain(tButton, "MANA_BAR", VUHDO_RAID[aUnit]);
			end
		end
	end

	if not VUHDO_RAID[aUnit] then
		return;
	end

	if VUHDO_RAID[aUnit]["hasSecretName"] then
		return;
	end

	-- Targets und targets-of-target, die im Raid sind
	tAllButtons = VUHDO_IN_RAID_TARGET_BUTTONS[VUHDO_RAID[aUnit]["name"]];

	if not tAllButtons then
		return;
	end

	for _, tButton in pairs(tAllButtons) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];

		if aBouquetName == nil or VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["MANA_BAR"] == aBouquetName then
			tManaBarHeight = 0;

			if anIsActive then
				tManaBarHeight = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["manaBarHeight"];
			end

			tManaBar = VUHDO_getHealthBar(tButton, 2);

			tInterpolation = (tManaBar["forceImmediate"] or 1 == anEventType) and VUHDO_IMMEDIATE or sManaInterpolation[tPanelNum];
			tManaBar["forceImmediate"] = nil;

			if anIsActive and tManaBarHeight > 0 then
				tManaBar:SetMinMaxValues(0, aMaxValue);

				if tManaBar["isInverted"] then
					tManaBar:SetValue(sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue), tInterpolation);
				else
					tManaBar:SetValue(aCurrValue, tInterpolation);
				end

				if aLayerTemplate then
					VUHDO_applyAllLayersToBar(tButton, tManaBar, aLayerTemplate, "MANA_BAR", aBouquetName);
				elseif aColor then
					VUHDO_setStatusBarVuhDoColor(tManaBar, aColor);
				end
			else
				tManaBar:SetMinMaxValues(0, 1, Enum.StatusBarInterpolation.Immediate);
				tManaBar:SetValue((not anIsActive and tManaBar["isInverted"]) and 1 or 0);
			end

			VUHDO_applyManaBarLayout(tButton, tPanelNum, tManaBarHeight, aUnit);

			if sSecretsEnabled then
				VUHDO_updateIndicatorAlphaChain(tButton, "MANA_BAR", VUHDO_RAID[aUnit]);
			end
		end
	end

	return;

end



--
function VUHDO_manaBarTextCallback(...)
	VUHDO_indicatorTextCallback(2, ...);
end



--
local tQuota;
local tBar;
local tBouquetName;
local tPanelNum;
local tIndicatorName;
local tSideInterpolation;
local function VUHDO_sideBarBouquetCallback(aBarNum, aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate, anIsAliveTime, anEventType)

	if -1 == anEventType then -- VUHDO_UPDATE_BOUQUET_RESET
		return;
	end

	aMaxValue = aMaxValue or 1;
	aCurrValue = aCurrValue or 0;

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];

		if aBarNum == 17 then
			tBouquetName = VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SIDE_LEFT"];
		elseif aBarNum == 18 then
			tBouquetName = VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SIDE_RIGHT"];
		end

		if tBouquetName == aBouquetName then
			tBar = VUHDO_getHealthBar(tButton, aBarNum);

			tSideInterpolation = (17 == aBarNum) and sSideLeftInterpolation[tPanelNum] or sSideRightInterpolation[tPanelNum];
			tSideInterpolation = (tBar["forceImmediate"] or 1 == anEventType) and VUHDO_IMMEDIATE or tSideInterpolation;
			tBar["forceImmediate"] = nil;

			tBar:SetMinMaxValues(0, aMaxValue);

			if not anIsActive and not VUHDO_RAID[aUnit] then
				tQuota = 0;
			elseif tBar["isInverted"] then
				tQuota = sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue);
			else
				tQuota = aCurrValue;
			end

			tBar:SetValue(tQuota, tSideInterpolation);

			if anIsActive then
				if aLayerTemplate then
					tIndicatorName = (aBarNum == 17) and "SIDE_LEFT" or "SIDE_RIGHT";

					VUHDO_applyAllLayersToBar(tButton, tBar, aLayerTemplate, tIndicatorName, aBouquetName);
				elseif aColor then
					VUHDO_setStatusBarVuhDoColor(tBar, aColor);
				end
			end

			if sSecretsEnabled then
				tIndicatorName = (aBarNum == 17) and "SIDE_LEFT" or "SIDE_RIGHT";

				VUHDO_updateIndicatorAlphaChain(tButton, tIndicatorName, VUHDO_RAID[aUnit]);
			end
		end
	end

	return;

end



--
function VUHDO_sideBarLeftBouquetCallback(...)
	VUHDO_sideBarBouquetCallback(17, ...);
end



--
function VUHDO_sideBarRightBouquetCallback(...)
	VUHDO_sideBarBouquetCallback(18, ...);
end



--
function VUHDO_sideLeftTextCallback(...)
	VUHDO_indicatorTextCallback(17, ...);
end



--
function VUHDO_sideRightTextCallback(...)
	VUHDO_indicatorTextCallback(18, ...);
end
