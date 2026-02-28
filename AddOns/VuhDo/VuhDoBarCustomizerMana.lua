-- BURST CACHE ---------------------------------------------------


local VUHDO_RAID;
local VUHDO_getUnitButtonsSafe;
local VUHDO_IN_RAID_TARGET_BUTTONS;
local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;
local UnitPowerType = UnitPowerType;
local UnitPower = UnitPower;
local UnitPowerMissing = UnitPowerMissing;
local UnitPowerMax = UnitPowerMax;
local InCombatLockdown = InCombatLockdown;
local pairs = pairs;
local sSecretsEnabled = VUHDO_SECRETS_ENABLED;
local _;

local VUHDO_getHealthBar;
local VUHDO_getRealParent;
local VUHDO_isConfigDemoUsers;
local VUHDO_updateBouquetsForEvent;
local VUHDO_indicatorTextCallback;
local VUHDO_setStatusBarVuhDoColor;
local VUHDO_applyAllLayersToBar;

local sIsInverted;
local sIsHealthBarVertical;
function VUHDO_customManaInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_IN_RAID_TARGET_BUTTONS = _G["VUHDO_IN_RAID_TARGET_BUTTONS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];

	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getRealParent = _G["VUHDO_getRealParent"];
	VUHDO_isConfigDemoUsers = _G["VUHDO_isConfigDemoUsers"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_indicatorTextCallback = _G["VUHDO_indicatorTextCallback"];
	VUHDO_setStatusBarVuhDoColor = _G["VUHDO_setStatusBarVuhDoColor"];
	VUHDO_applyAllLayersToBar = _G["VUHDO_applyAllLayersToBar"];

	sIsInverted = { };
	sIsHealthBarVertical = { };

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		sIsInverted[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["MANA_BAR"]["invertGrowth"];
		sIsHealthBarVertical[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["vertical"];
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

	if (tInfo["isVehicle"]) then
		aUnit = tInfo["petUnit"];
		if not aUnit then return; end
	
		tInfo = VUHDO_RAID[aUnit];
		if not tInfo then return; end
	end

	if not VUHDO_isConfigDemoUsers() then
		if 1 == aChange then
			tInfo["power"] = UnitPower(aUnit);
		elseif 2 == aChange  then
			tInfo["powermax"] = UnitPowerMax(aUnit);
		elseif 3 == aChange then
			tPowerType, _ = UnitPowerType(aUnit);
			tInfo["powertype"] = tonumber(tPowerType);
			tInfo["powermax"] = UnitPowerMax(aUnit);
			tInfo["power"] = UnitPower(aUnit);
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

end



--
local tAllButtons, tManaBar;
local tManaBarHeight;
local tRegularHeight;
local tPanelNum;
local tInfo;
local tHealthBar;
function VUHDO_manaBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;
	aCurrValue2 = aCurrValue2 or 0;

	tManaBarHeight = 0;

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];

		if aBouquetName == nil or VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["MANA_BAR"] == aBouquetName then
			if anIsActive then
				tManaBarHeight = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["manaBarHeight"];
			end

			tManaBar = VUHDO_getHealthBar(tButton, 2);

			if anIsActive and tManaBarHeight > 0 then
				tManaBar:SetMinMaxValues(0, aMaxValue);

				if tManaBar["isInverted"] then
					tManaBar:SetValue(sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue));
				else
					tManaBar:SetValue(aCurrValue);
				end

				if aLayerTemplate then
					VUHDO_applyAllLayersToBar(tButton, tManaBar, aLayerTemplate);
				elseif aColor then
					VUHDO_setStatusBarVuhDoColor(tManaBar, aColor);
				end
			else
				tManaBar:SetMinMaxValues(0, 1);
				tManaBar:SetValue((not anIsActive and tManaBar["isInverted"]) and 1 or 0);
			end

			if not InCombatLockdown() then
				if tManaBarHeight > 0 then
					VUHDO_PixelUtil.SetHeight(tManaBar, tManaBarHeight);
				end

				tRegularHeight = tButton["regularHeight"];

				if tRegularHeight then
					tHealthBar = VUHDO_getHealthBar(tButton, 1);
					tHealthBar:ClearAllPoints();
					tHealthBar:SetPoint("TOPLEFT", VUHDO_getRealParent(tHealthBar), "TOPLEFT", 0, 0);
					VUHDO_PixelUtil.SetSize(tHealthBar, tButton:GetWidth(), tRegularHeight - tManaBarHeight);

					if not sIsHealthBarVertical[tPanelNum] then
						VUHDO_PixelUtil.SetHeight(VUHDO_getHealthBar(tButton, 6), tRegularHeight - tManaBarHeight);
						VUHDO_PixelUtil.SetHeight(VUHDO_getHealthBar(tButton, 19), tRegularHeight - tManaBarHeight);
					end
				end
			end

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
			tManaBarHeight = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["manaBarHeight"];

			tManaBar = VUHDO_getHealthBar(tButton, 2);

			if anIsActive and tManaBarHeight > 0 then
				tManaBar:SetMinMaxValues(0, aMaxValue);

				if tManaBar["isInverted"] then
					tManaBar:SetValue(sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue));
				else
					tManaBar:SetValue(aCurrValue);
				end

				if aLayerTemplate then
					VUHDO_applyAllLayersToBar(tButton, tManaBar, aLayerTemplate);
				elseif aColor then
					VUHDO_setStatusBarVuhDoColor(tManaBar, aColor);
				end
			else
				tManaBar:SetMinMaxValues(0, 1);
				tManaBar:SetValue((not anIsActive and tManaBar["isInverted"]) and 1 or 0);
			end

			if not InCombatLockdown() then
				if tManaBarHeight > 0 then
					VUHDO_PixelUtil.SetHeight(tManaBar, tManaBarHeight);
				end

				tRegularHeight = tButton["regularHeight"];

				if tRegularHeight then
					tHealthBar = VUHDO_getHealthBar(tButton, 1);

					tHealthBar:ClearAllPoints();
					tHealthBar:SetPoint("TOPLEFT", VUHDO_getRealParent(tHealthBar), "TOPLEFT", 0, 0);
					VUHDO_PixelUtil.SetSize(tHealthBar, tButton:GetWidth(), tRegularHeight - tManaBarHeight);

					if not sIsHealthBarVertical[tPanelNum] then
						VUHDO_PixelUtil.SetHeight(VUHDO_getHealthBar(tButton, 6), tRegularHeight - tManaBarHeight);
						VUHDO_PixelUtil.SetHeight(VUHDO_getHealthBar(tButton, 19), tRegularHeight - tManaBarHeight);
					end
				end
			end

			if sSecretsEnabled then
				VUHDO_updateIndicatorAlphaChain(tButton, "MANA_BAR", VUHDO_RAID[aUnit]);
			end
		end
	end

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
local function VUHDO_sideBarBouquetCallback(aBarNum, aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

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

			tBar:SetMinMaxValues(0, aMaxValue);

			if tBar["isInverted"] then
				tBar:SetValue(sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue));
			else
				tBar:SetValue(aCurrValue);
			end

			if anIsActive then
				if aLayerTemplate then
					VUHDO_applyAllLayersToBar(tButton, tBar, aLayerTemplate);
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
