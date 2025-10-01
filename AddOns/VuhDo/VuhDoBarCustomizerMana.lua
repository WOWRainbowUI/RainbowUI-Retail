
-- BURST CACHE ---------------------------------------------------


local VUHDO_RAID;
local VUHDO_getUnitButtonsSafe;
local VUHDO_IN_RAID_TARGET_BUTTONS;
local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;
local UnitPowerType = UnitPowerType;
local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local InCombatLockdown = InCombatLockdown;
local pairs = pairs;
local _;

local VUHDO_getHealthBar;
local VUHDO_isConfigDemoUsers;
local VUHDO_updateBouquetsForEvent;
local VUHDO_indicatorTextCallback;

local sIsInverted;
local sIsHealthBarVertical;
function VUHDO_customManaInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_IN_RAID_TARGET_BUTTONS = _G["VUHDO_IN_RAID_TARGET_BUTTONS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];

	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_isConfigDemoUsers = _G["VUHDO_isConfigDemoUsers"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_indicatorTextCallback = _G["VUHDO_indicatorTextCallback"];

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
local tAllButtons, tManaBar, tQuota;
local tManaBarHeight;
local tRegularHeight;
local tPanelNum;
function VUHDO_manaBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName)

	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;

	if aMaxValue + aCurrValue == 0 then
		anIsActive = false;
	end

	tManaBarHeight = 0;
	tQuota = (aCurrValue == 0 and aMaxValue == 0) and 0 or aMaxValue > 1 and aCurrValue / aMaxValue or 0;

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];

		if aBouquetName == nil or VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["MANA_BAR"] == aBouquetName then
			if anIsActive then
				tManaBarHeight = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["manaBarHeight"];
			end

			tManaBar = VUHDO_getHealthBar(tButton, 2);

			if tQuota > 0 and tManaBarHeight > 0 then
				if aColor then
					tManaBar:SetVuhDoColor(aColor);
				end

				tManaBar:SetValue(tQuota);
			else
				tManaBar:SetValue((not anIsActive and sIsInverted[tPanelNum]) and 1 or 0);
			end

			if not InCombatLockdown() then
				if tManaBarHeight > 0 then
					tManaBar:SetHeight(tManaBarHeight);
				end

				tRegularHeight = tButton["regularHeight"];

				if tRegularHeight then
					VUHDO_getHealthBar(tButton, 1):SetHeight(tRegularHeight - tManaBarHeight);

					if not sIsHealthBarVertical[tPanelNum] then
						VUHDO_getHealthBar(tButton, 6):SetHeight(tRegularHeight - tManaBarHeight);
						VUHDO_getHealthBar(tButton, 19):SetHeight(tRegularHeight - tManaBarHeight);
					end
				end
			end
		end
	end

	if not VUHDO_RAID[aUnit] then
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
			tManaBar = VUHDO_getHealthBar(tButton, 2);

			if tQuota > 0 then
				if aColor then
					tManaBar:SetVuhDoColor(aColor);
				end

				tManaBar:SetValue(tQuota);
			else
				tManaBar:SetValue(0);
			end

			if not InCombatLockdown() then
				tManaBarHeight = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["manaBarHeight"];
				tManaBar:SetHeight(tManaBarHeight);

				tRegularHeight = tButton["regularHeight"];

				if tRegularHeight then
					VUHDO_getHealthBar(tButton, 1):SetHeight(tRegularHeight - tManaBarHeight);
					VUHDO_getHealthBar(tButton, 6):SetHeight(tRegularHeight - tManaBarHeight);
					VUHDO_getHealthBar(tButton, 19):SetHeight(tRegularHeight - tManaBarHeight);
				end
			end
		end
	end

end



--
function VUHDO_manaBarTextCallback(...)
	VUHDO_indicatorTextCallback(2, ...);
end



--
local tQuota, tBar;
local tBouquetName;
local tPanelNum;
local function VUHDO_sideBarBouquetCallback(aBarNum, aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName)

	tQuota = (aCurrValue == 0 and aMaxValue == 0) and 0 or (aMaxValue or 0) > 1 and aCurrValue / aMaxValue or 0;

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];

		if aBarNum == 17 then
			tBouquetName = VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SIDE_LEFT"];
		elseif aBarNum == 18 then
			tBouquetName = VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SIDE_RIGHT"];
		end

		if tBouquetName == aBouquetName then
			if tQuota > 0 then
				tBar = VUHDO_getHealthBar(tButton, aBarNum);

				tBar:SetValue(tQuota);
				tBar:SetVuhDoColor(aColor);
			else
				VUHDO_getHealthBar(tButton, aBarNum):SetValue(0);
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
