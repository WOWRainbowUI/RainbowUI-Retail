local VUHDO_IN_RAID_TARGETS = { };
VUHDO_IN_RAID_TARGET_BUTTONS = { };
local VUHDO_IN_RAID_TARGET_BUTTONS = VUHDO_IN_RAID_TARGET_BUTTONS;
local VUHDO_TOT_GUIDS = { };


-------------------------------------------------
local UnitClass = UnitClass;
local UnitPowerType = UnitPowerType;
-- Disable local alias so function can be overloaded by Velhari Health Fix addon
--local UnitHealthMax = UnitHealthMax;
local UnitHealth = UnitHealth;
local UnitName = UnitName;
local UnitPower = UnitPower;
local UnitPowerMax = UnitPowerMax;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsConnected = UnitIsConnected;
local UnitExists = UnitExists;
local UnitCreatureType = UnitCreatureType;
local strfind = strfind;
local gsub = gsub;
local GetRaidTargetIndex = GetRaidTargetIndex;
local tonumber = tonumber;
local pairs = pairs;
local twipe = table.wipe;
local issecretvalue = issecretvalue;
local sSecretsEnabled = VUHDO_SECRETS_ENABLED;
local _;


local VUHDO_CUSTOM_INFO;
local VUHDO_CLASS_IDS;

local VUHDO_getHealthBar;
local VUHDO_customizeText;
local VUHDO_setRaidTargetIconTexture
local VUHDO_RAID;
local VUHDO_getUnitButtons;
local VUHDO_getTargetButton;
local VUHDO_getTotButton;
local VUHDO_PANEL_SETUP;
local VUHDO_getTargetBarRoleIcon;
local VUHDO_POWER_TYPE_COLORS;
local VUHDO_BUTTON_CACHE;
local VUHDO_getDisplayUnit;
local VUHDO_textColor;
local VUHDO_isInRange;
local VUHDO_unitIsUnit;
local VUHDO_setStatusBarVuhDoColor;
local VUHDO_applyAllLayersToBar;
local VUHDO_getBarText;
local VUHDO_getBarTextSolo;
local VUHDO_getLifeText;



--
function VUHDO_customTargetInitLocalOverrides()

	VUHDO_CUSTOM_INFO = _G["VUHDO_CUSTOM_INFO"];
	VUHDO_CLASS_IDS = _G["VUHDO_CLASS_IDS"];

	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_customizeText = _G["VUHDO_customizeText"];
	VUHDO_setRaidTargetIconTexture = _G["VUHDO_setRaidTargetIconTexture"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_getTargetButton = _G["VUHDO_getTargetButton"];
	VUHDO_getTotButton = _G["VUHDO_getTotButton"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_getTargetBarRoleIcon = _G["VUHDO_getTargetBarRoleIcon"];
	VUHDO_POWER_TYPE_COLORS =  _G["VUHDO_POWER_TYPE_COLORS"];
	VUHDO_getDisplayUnit = _G["VUHDO_getDisplayUnit"];
	VUHDO_textColor = _G["VUHDO_textColor"];
	VUHDO_isInRange = _G["VUHDO_isInRange"];
	VUHDO_unitIsUnit = _G["VUHDO_unitIsUnit"];
	VUHDO_setStatusBarVuhDoColor = _G["VUHDO_setStatusBarVuhDoColor"];
	VUHDO_applyAllLayersToBar = _G["VUHDO_applyAllLayersToBar"];
	VUHDO_getBarText = _G["VUHDO_getBarText"];
	VUHDO_getBarTextSolo = _G["VUHDO_getBarTextSolo"];
	VUHDO_getLifeText = _G["VUHDO_getLifeText"];

end



--
local tManaBar;
local tInfo;
local function VUHDO_customizeManaBar(aButton)

	_, tInfo = VUHDO_getDisplayUnit(aButton);

	if tInfo and tInfo["connected"] then
		tManaBar = VUHDO_getHealthBar(aButton, 2);

		if sSecretsEnabled and tInfo["hasSecretPower"] then
			tManaBar:SetMinMaxValues(0, tInfo["powermax"]);
			tManaBar:SetValue(tInfo["power"]);
		elseif tInfo["powermax"] < 2 then
			tManaBar:SetMinMaxValues(0, 1);
			tManaBar:SetValue(0);
		else
			tManaBar:SetMinMaxValues(0, 1);
			tManaBar:SetValue(tInfo["power"] / tInfo["powermax"]);
		end

		VUHDO_setStatusBarVuhDoColor(tManaBar, VUHDO_POWER_TYPE_COLORS[tInfo["powertype"]]);
	else
		VUHDO_getHealthBar(aButton, 2):SetValue(0);
	end

	return;

end



--
local tInfo;
local tLocalClass, tClassName;
local tPowerType;
local tName;
local function VUHDO_fillCustomInfo(aUnit)

	tLocalClass, tClassName = UnitClass(aUnit);
	tPowerType = UnitPowerType(aUnit);
	tName = UnitName(aUnit);

	tInfo = VUHDO_CUSTOM_INFO;

	tInfo["healthmax"] = UnitHealthMax(aUnit);
	tInfo["health"] = UnitHealth(aUnit);
	tInfo["name"] = tName;

	if sSecretsEnabled then
		tInfo["hasSecretName"] = issecretvalue(tName);
	else
		tInfo["hasSecretName"] = false;
	end

	tInfo["unit"] = aUnit;
	tInfo["class"] = tClassName;
	tInfo["powertype"] = tonumber(tPowerType);
	tInfo["power"] = UnitPower(aUnit);
	tInfo["powermax"] = UnitPowerMax(aUnit);

	if sSecretsEnabled then
		tInfo["hasSecretPower"] = issecretvalue(tInfo["power"]) or issecretvalue(tInfo["powermax"]);
		tInfo["hasSecretHealth"] = issecretvalue(tInfo["health"]);
		tInfo["hasSecretHealthMax"] = issecretvalue(tInfo["healthmax"]);
	else
		tInfo["hasSecretPower"] = false;
		tInfo["hasSecretHealth"] = false;
		tInfo["hasSecretHealthMax"] = false;
	end

	tInfo["dead"] = UnitIsDeadOrGhost(aUnit);
	tInfo["connected"] = UnitIsConnected(aUnit);
	if tInfo["hasSecretName"] then
		tInfo["className"] = "";
	elseif tLocalClass == tName then
		tInfo["className"] = UnitCreatureType(aUnit) or "";
	else
		tInfo["className"] = tLocalClass or "";
	end
	tInfo["classId"] = VUHDO_CLASS_IDS[tClassName];
	tInfo["fullName"] = tName;
	tInfo["zone"], tInfo["map"] = (VUHDO_RAID["player"] or { })["zone"], (VUHDO_RAID["player"] or { })["map"];
	tInfo["fixResolveId"] = nil;

	tInfo["raidIcon"] = GetRaidTargetIndex(aUnit);
	tInfo["hasSecretRaidIcon"] = sSecretsEnabled and issecretvalue(tInfo["raidIcon"]);

	return;

end



--
local tBar;
local tQuota;
local function VUHDO_targetHealthBouquetCallback(aButton, aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

	aMaxValue = aMaxValue or 1;
	aCurrValue = aCurrValue or 0;

	tBar = VUHDO_getHealthBar(aButton, 1);

	if anIsActive then
		tBar:SetMinMaxValues(0, aMaxValue);

		if tBar["isInverted"] then
			tBar:SetValue(sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue));
		else
			tBar:SetValue(aCurrValue);
		end

		if aLayerTemplate then
			VUHDO_applyAllLayersToBar(aButton, tBar, aLayerTemplate);
		elseif aColor then
			VUHDO_setStatusBarVuhDoColor(tBar, aColor);

			VUHDO_getBarText(tBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"]);
			VUHDO_getBarTextSolo(tBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"]);
			VUHDO_getLifeText(tBar):SetTextColor(VUHDO_textColor(aColor));
		end

		aButton:SetAlpha(1);
	else
		tBar:SetMinMaxValues(0, 1);
		tBar:SetValue(tBar["isInverted"] and 1 or 0);
		aButton:SetAlpha(0);
	end

end



--
local tTexture;
local tIconIdx;
function VUHDO_customizeTargetBar(aButton, aUnit, anIsInRange)

	VUHDO_CUSTOM_INFO["range"] = anIsInRange;

	if sSecretsEnabled then
		VUHDO_CUSTOM_INFO["hasSecretRange"] = issecretvalue(anIsInRange);
	else
		VUHDO_CUSTOM_INFO["hasSecretRange"] = false;
	end

	VUHDO_invokeCustomBouquet(aButton, aUnit, VUHDO_RAID[aUnit] or VUHDO_CUSTOM_INFO, VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH, VUHDO_targetHealthBouquetCallback);
	VUHDO_customizeText(aButton, 1, true); -- VUHDO_UPDATE_ALL
	VUHDO_customizeManaBar(aButton, true);

	tIconIdx = GetRaidTargetIndex(aUnit);
	if not VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]]["RAID_ICON"]["show"] then
		VUHDO_getTargetBarRoleIcon(aButton, 50):Hide();
	elseif tIconIdx then
		if sSecretsEnabled and issecretvalue(tIconIdx) then
			tTexture = VUHDO_getTargetBarRoleIcon(aButton, 50);

			VUHDO_setRaidTargetIconTexture(tTexture, tIconIdx);

			tTexture:Show();
		elseif VUHDO_PANEL_SETUP["RAID_ICON_FILTER"][tIconIdx] then
			tTexture = VUHDO_getTargetBarRoleIcon(aButton, 50);

			VUHDO_setRaidTargetIconTexture(tTexture, tIconIdx);

			tTexture:Show();
		else
			VUHDO_getTargetBarRoleIcon(aButton, 50):Hide();
		end
	else
		VUHDO_getTargetBarRoleIcon(aButton, 50):Hide();
	end
end
local VUHDO_customizeTargetBar = VUHDO_customizeTargetBar;



-- Wir merken uns die Target-Buttons, wenn das Ziel im Raid ist,
-- die Target-Buttons sind also durch den Target-Namen indiziert.
local tName;
local function VUHDO_rememberTargetButton(aTargetUnit, aButton)
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if VUHDO_unitIsUnit(tUnit, aTargetUnit) then
			if tInfo["hasSecretName"] then
				break;
			end

			tName = tInfo["name"];

			if not VUHDO_IN_RAID_TARGET_BUTTONS[tName] then
				VUHDO_IN_RAID_TARGET_BUTTONS[tName] = { };
			end

			VUHDO_IN_RAID_TARGET_BUTTONS[tName][aButton] = aButton;
			VUHDO_IN_RAID_TARGETS[aTargetUnit] = tName;

			break;
		end
	end
end



-- L?sche alle Target-Buttons der Person, deren Ziel sich ge?ndert hat
-- Wobei die Buttons mit dem Namen des TARGETS indiziert sind, welchen
-- wir uns VUHDO_IN_RAID_TARGETS aber gemerkt haben
local tName;
local function VUHDO_forgetTargetButton(aTargetUnit, aButton)
	tName = VUHDO_IN_RAID_TARGETS[aTargetUnit];
	if tName then
		if not VUHDO_IN_RAID_TARGET_BUTTONS[tName] then
			VUHDO_IN_RAID_TARGET_BUTTONS[tName] = { };
		end
		VUHDO_IN_RAID_TARGET_BUTTONS[tName][aButton] = nil;
	end
end


--
local sTargetSourceUnits = {};
local sUnitTargetsUnits = {};
local sUnitTotUnits = {};

--
local tTargetButton, tTotButton;
local tAllButtons;
local tTarget;
local tTargetOfTarget;
function VUHDO_updateTargetBars(aUnit)
	if strfind(aUnit, "target", 1, true) and aUnit ~= "target" then
		if not sTargetSourceUnits[aUnit] then
			sTargetSourceUnits[aUnit] = gsub(aUnit, "target", "");
		end
		aUnit = sTargetSourceUnits[aUnit];
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if not tAllButtons then return; end

	if not sUnitTargetsUnits[aUnit] then
		sUnitTargetsUnits[aUnit] = aUnit .. "target";
	end
	tTarget = sUnitTargetsUnits[aUnit];

	if not sUnitTotUnits[tTarget] then
		sUnitTotUnits[tTarget] = tTarget .. "target";
	end
	tTargetOfTarget = sUnitTotUnits[tTarget];

	for _, tButton in pairs(tAllButtons) do
		VUHDO_forgetTargetButton(tTarget, VUHDO_getTargetButton(tButton));
		VUHDO_forgetTargetButton(tTargetOfTarget, VUHDO_getTotButton(tButton));
	end

	VUHDO_IN_RAID_TARGETS[tTarget] = nil;
	VUHDO_IN_RAID_TARGETS[tTargetOfTarget] = nil;

	if not UnitExists(tTarget) then
		for _, tButton in pairs(tAllButtons) do
			VUHDO_getTargetButton(tButton):SetAlpha(0);
			VUHDO_getTotButton(tButton):SetAlpha(0);
		end

		return;
	end

	-- Target
	VUHDO_fillCustomInfo(tTarget);

	for _, tButton in pairs(tAllButtons) do
		if VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[tButton]]["SCALING"]["showTarget"] then
			tTargetButton = VUHDO_getTargetButton(tButton);
			VUHDO_customizeTargetBar(tTargetButton, tTarget, VUHDO_isInRange(tTarget));
			tTargetButton:SetAlpha(1);
			VUHDO_rememberTargetButton(tTarget, tTargetButton);
		end
	end

	-- Target-of-target
	if not UnitExists(tTargetOfTarget) then
		for _, tButton in pairs(tAllButtons) do
			VUHDO_getTotButton(tButton):SetAlpha(0);
		end
		return;
	end

	VUHDO_fillCustomInfo(tTargetOfTarget);

	for _, tButton in pairs(tAllButtons) do
		if VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[tButton]]["SCALING"]["showTot"] then
			tTotButton = VUHDO_getTotButton(tButton);
			VUHDO_customizeTargetBar(tTotButton, tTargetOfTarget, VUHDO_isInRange(tTargetOfTarget));
			tTotButton:SetAlpha(1);
			VUHDO_rememberTargetButton(tTargetOfTarget, tTotButton);
		end
	end
end
local VUHDO_updateTargetBars = VUHDO_updateTargetBars;



--
function VUHDO_rebuildTargets()
	if not VUHDO_INTERNAL_TOGGLES[22] then return; end-- VUHDO_UPDATE_UNIT_TARGET

	twipe(VUHDO_IN_RAID_TARGETS);
	twipe(VUHDO_IN_RAID_TARGET_BUTTONS);
	twipe(VUHDO_TOT_GUIDS);

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateTargetBars(tUnit);
	end
end



--
local tTotUnit, tGuid;
local tAllButtons;
local function VUHDO_updateTargetHealth(aUnit, aTargetUnit)

	tAllButtons = VUHDO_getUnitButtons(aUnit);

	if not tAllButtons then
		return;
	end

	if not VUHDO_IN_RAID_TARGETS[aTargetUnit] then
		VUHDO_fillCustomInfo(aTargetUnit);

		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeTargetBar(VUHDO_getTargetButton(tButton), aTargetUnit, VUHDO_isInRange(aTargetUnit));
		end
	end

	if not sUnitTotUnits[aTargetUnit] then
		sUnitTotUnits[aTargetUnit] = aTargetUnit .. "target";
	end

	tTotUnit = sUnitTotUnits[aTargetUnit];

	tGuid = UnitGUID(tTotUnit);

	if tGuid and sSecretsEnabled and issecretvalue(tGuid) then
		-- FIXME: target-of-target tracking updates every frame when GUID is secret
		VUHDO_updateTargetBars(aUnit);
		VUHDO_TOT_GUIDS[aUnit] = nil;
	elseif VUHDO_TOT_GUIDS[aUnit] ~= tGuid then
		VUHDO_updateTargetBars(aUnit);
		VUHDO_TOT_GUIDS[aUnit] = tGuid;
	elseif VUHDO_IN_RAID_TARGETS[tTotUnit] == nil and UnitExists(tTotUnit) then
		VUHDO_fillCustomInfo(tTotUnit);

		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeTargetBar(VUHDO_getTotButton(tButton), tTotUnit, VUHDO_isInRange(tTotUnit));
		end
	end

	return;

end



--
function VUHDO_updateAllOutRaidTargetButtons()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if UnitExists(tInfo["targetUnit"]) then
			VUHDO_updateTargetHealth(tUnit, tInfo["targetUnit"]);
		end
	end
end
