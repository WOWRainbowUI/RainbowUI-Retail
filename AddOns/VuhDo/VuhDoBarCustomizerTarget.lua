local sTargetButtonIdentityKeys = { };
VUHDO_IN_RAID_TARGET_BUTTONS = { };
local VUHDO_IN_RAID_TARGET_BUTTONS = VUHDO_IN_RAID_TARGET_BUTTONS;
local sTargetGuids = { };
local sTotGuids = { };


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
local UnitGUID = UnitGUID;
local UnitCreatureType = UnitCreatureType;
local strfind = strfind;
local gsub = gsub;
local GetRaidTargetIndex = GetRaidTargetIndex;
local tonumber = tonumber;
local pcall = pcall;
local pairs = pairs;
local twipe = table.wipe;
local issecretvalue = issecretvalue;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;

local VUHDO_IMMEDIATE = Enum.StatusBarInterpolation.Immediate;
local VUHDO_EASE_OUT = Enum.StatusBarInterpolation.ExponentialEaseOut;

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
local VUHDO_resetBarTextVertexColor;
local VUHDO_getBlizzardClassColorMixin;



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
	VUHDO_resetBarTextVertexColor = _G["VUHDO_resetBarTextVertexColor"];
	VUHDO_getBlizzardClassColorMixin = _G["VUHDO_getBlizzardClassColorMixin"];

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
local tSuccess;
local tResult;
local function VUHDO_safeCall(aFunc, aUnit, aDefault)

	tSuccess, tResult = pcall(aFunc, aUnit);

	if tSuccess then
		return tResult;
	end

	return aDefault;

end



--
local tSuccess;
local tInfo;
local tLocalClass;
local tClassName;
local tPowerType;
local tName;
local function VUHDO_fillCustomInfo(aUnit)

	if not aUnit then
		return;
	end

	tSuccess, tLocalClass, tClassName = pcall(UnitClass, aUnit);

	if not tSuccess then
		tLocalClass, tClassName = nil, nil;
	end

	tPowerType = VUHDO_safeCall(UnitPowerType, aUnit, nil);
	tName = VUHDO_safeCall(UnitName, aUnit, nil);

	tInfo = VUHDO_CUSTOM_INFO;

	VUHDO_setUnitInfoHealthMax(tInfo, VUHDO_safeCall(UnitHealthMax, aUnit, 0));

	tInfo["health"] = VUHDO_safeCall(UnitHealth, aUnit, 0);

	tInfo["name"] = tName;

	if sSecretsEnabled then
		tInfo["hasSecretName"] = issecretvalue(tName);
	else
		tInfo["hasSecretName"] = false;
	end

	tInfo["unit"] = aUnit;
	tInfo["class"] = tClassName;
	tInfo["powertype"] = tonumber(tPowerType);

	tInfo["power"] = VUHDO_safeCall(UnitPower, aUnit, 0);
	tInfo["powermax"] = VUHDO_safeCall(UnitPowerMax, aUnit, 0);

	if sSecretsEnabled then
		tInfo["hasSecretPower"] = issecretvalue(tInfo["power"]) or issecretvalue(tInfo["powermax"]);
		tInfo["hasSecretHealth"] = issecretvalue(tInfo["health"]);
		tInfo["hasSecretClass"] = issecretvalue(tClassName);

		if tInfo["hasSecretClass"] then
			tInfo["blizzardClassColor"] = VUHDO_getBlizzardClassColorMixin(tClassName);
		else
			tInfo["blizzardClassColor"] = nil;
		end
	else
		tInfo["hasSecretPower"] = false;
		tInfo["hasSecretHealth"] = false;
		tInfo["hasSecretHealthMax"] = false;
		tInfo["hasSecretClass"] = false;
		tInfo["blizzardClassColor"] = nil;
	end

	tInfo["dead"] = VUHDO_safeCall(UnitIsDeadOrGhost, aUnit, false);
	tInfo["connected"] = VUHDO_safeCall(UnitIsConnected, aUnit, false);

	if tInfo["hasSecretName"] or tInfo["hasSecretClass"] then
		tInfo["className"] = "";
	elseif sSecretsEnabled and issecretvalue(tLocalClass) then
		tInfo["className"] = "";
	elseif tLocalClass == tName then
		tInfo["className"] = VUHDO_safeCall(UnitCreatureType, aUnit, nil) or "";
	else
		tInfo["className"] = tLocalClass or "";
	end

	if sSecretsEnabled and issecretvalue(tClassName) then
		tInfo["classId"] = nil;
	else
		tInfo["classId"] = VUHDO_CLASS_IDS[tClassName];
	end

	tInfo["fullName"] = tName;
	tInfo["zone"], tInfo["map"] = (VUHDO_RAID["player"] or { })["zone"], (VUHDO_RAID["player"] or { })["map"];
	tInfo["fixResolveId"] = nil;

	tInfo["raidIcon"] = VUHDO_safeCall(GetRaidTargetIndex, aUnit, nil);
	tInfo["hasSecretRaidIcon"] = sSecretsEnabled and issecretvalue(tInfo["raidIcon"]);

	return;

end



--
local tBar;
local tInterpolation;
local function VUHDO_targetHealthBouquetCallback(aButton, aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate, anIsAliveTime, anEventType)

	aMaxValue = aMaxValue or 1;
	aCurrValue = aCurrValue or 0;

	tBar = VUHDO_getHealthBar(aButton, 1);

	tInterpolation = (tBar["forceImmediate"] or 1 == anEventType) and VUHDO_IMMEDIATE or VUHDO_EASE_OUT;
	tBar["forceImmediate"] = nil;

	if anIsActive then
		tBar:SetMinMaxValues(0, aMaxValue, tInterpolation);

		if tBar["isInverted"] then
			tBar:SetValue(sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue), tInterpolation);
		else
			tBar:SetValue(aCurrValue, tInterpolation);
		end

		if aLayerTemplate then
			VUHDO_applyAllLayersToBar(aButton, tBar, aLayerTemplate);
		elseif aColor then
			VUHDO_setStatusBarVuhDoColor(tBar, aColor);

			VUHDO_resetBarTextVertexColor(tBar);

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
local tIdentityKey;
local function VUHDO_rememberTargetButton(aTargetUnit, aButton)

	if sSecretsEnabled and issecretvalue(UnitGUID(aTargetUnit)) then
		return;
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if VUHDO_unitIsUnit(tUnit, aTargetUnit) then
			if tInfo["hasSecretIdentity"] then
				break;
			end

			tIdentityKey = VUHDO_getUnitIdentityKey(tInfo);

			if not tIdentityKey then
				break;
			end

			if not VUHDO_IN_RAID_TARGET_BUTTONS[tIdentityKey] then
				VUHDO_IN_RAID_TARGET_BUTTONS[tIdentityKey] = { };
			end

			VUHDO_IN_RAID_TARGET_BUTTONS[tIdentityKey][aButton] = aButton;
			sTargetButtonIdentityKeys[aButton] = tIdentityKey;

			break;
		end
	end

	return;

end



-- L?sche alle Target-Buttons der Person, deren Ziel sich ge?ndert hat
local tIdentityKey;
local function VUHDO_forgetTargetButton(aButton)

	tIdentityKey = sTargetButtonIdentityKeys[aButton];

	if tIdentityKey and VUHDO_IN_RAID_TARGET_BUTTONS[tIdentityKey] then
		VUHDO_IN_RAID_TARGET_BUTTONS[tIdentityKey][aButton] = nil;
	end

	sTargetButtonIdentityKeys[aButton] = nil;

	return;

end



--
local sTargetSourceUnits = { };
local sUnitTargetsUnits = { };
local sUnitTotUnits = { };



--
local tTargetButton, tTotButton;
local tAllButtons;
local tTarget;
local tTargetOfTarget;
local tCachedInfo;
local tCachedRange;
function VUHDO_updateTargetBars(aUnit)

	if strfind(aUnit, "target", 1, true) and aUnit ~= "target" then
		if not sTargetSourceUnits[aUnit] then
			sTargetSourceUnits[aUnit] = gsub(aUnit, "target", "");
		end

		aUnit = sTargetSourceUnits[aUnit];
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);

	if not tAllButtons then
		return;
	end

	if not sUnitTargetsUnits[aUnit] then
		sUnitTargetsUnits[aUnit] = aUnit .. "target";
	end

	tTarget = sUnitTargetsUnits[aUnit];

	if not sUnitTotUnits[tTarget] then
		sUnitTotUnits[tTarget] = tTarget .. "target";
	end

	tTargetOfTarget = sUnitTotUnits[tTarget];

	for _, tButton in pairs(tAllButtons) do
		VUHDO_forgetTargetButton(VUHDO_getTargetButton(tButton));
		VUHDO_forgetTargetButton(VUHDO_getTotButton(tButton));
	end

	if not UnitExists(tTarget) then
		sTargetGuids[aUnit] = nil;
		sTotGuids[aUnit] = nil;

		for _, tButton in pairs(tAllButtons) do
			VUHDO_getTargetButton(tButton):SetAlpha(0);
			VUHDO_getTotButton(tButton):SetAlpha(0);
		end

		return;
	end

	-- Target
	VUHDO_fillCustomInfo(tTarget);

	tCachedInfo = VUHDO_RAID[tTarget];
	tCachedRange = tCachedInfo and tCachedInfo["range"];

	if tCachedRange == nil then
		tCachedRange = VUHDO_isInRange(tTarget);
	end

	for _, tButton in pairs(tAllButtons) do
		if VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[tButton]]["SCALING"]["showTarget"] then
			tTargetButton = VUHDO_getTargetButton(tButton);

			VUHDO_customizeTargetBar(tTargetButton, tTarget, tCachedRange);
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

	tCachedInfo = VUHDO_RAID[tTargetOfTarget];
	tCachedRange = tCachedInfo and tCachedInfo["range"];

	if tCachedRange == nil then
		tCachedRange = VUHDO_isInRange(tTargetOfTarget);
	end

	for _, tButton in pairs(tAllButtons) do
		if VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[tButton]]["SCALING"]["showTot"] then
			tTotButton = VUHDO_getTotButton(tButton);

			VUHDO_customizeTargetBar(tTotButton, tTargetOfTarget, tCachedRange);
			tTotButton:SetAlpha(1);

			VUHDO_rememberTargetButton(tTargetOfTarget, tTotButton);
		end
	end

	return;

end
local VUHDO_updateTargetBars = VUHDO_updateTargetBars;



--
function VUHDO_rebuildTargets()
	if not VUHDO_INTERNAL_TOGGLES[22] then return; end-- VUHDO_UPDATE_UNIT_TARGET

	twipe(sTargetButtonIdentityKeys);
	twipe(VUHDO_IN_RAID_TARGET_BUTTONS);
	twipe(sTotGuids);
	twipe(sTargetGuids);

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateTargetBars(tUnit);
	end
end



do
	--
	local tGuid;
	local function VUHDO_checkTargetGuidChange(aGuidCache, aSourceUnit, aTargetUnit)

		tGuid = UnitGUID(aTargetUnit);

		if sSecretsEnabled and issecretvalue(tGuid) then
			aGuidCache[aSourceUnit] = true;

			return true, true;
		end

		if aGuidCache[aSourceUnit] ~= tGuid then
			aGuidCache[aSourceUnit] = tGuid;

			return true, false;
		end

		return false, false;

	end



	--
	local tTotUnit;
	local tAllButtons;
	local tCachedInfo;
	local tCachedRange;
	local tTargetChanged;
	local tIsTargetSecret;
	local tTotChanged;
	local tIsTotSecret;
	local tPanelNum;
	local tTargetButton;
	local tTotButton;
	local function VUHDO_refreshTargetBars(aSourceUnit, aTargetUnit)

		tAllButtons = VUHDO_getUnitButtons(aSourceUnit);

		if not tAllButtons then
			return;
		end

		if not sUnitTotUnits[aTargetUnit] then
			sUnitTotUnits[aTargetUnit] = aTargetUnit .. "target";
		end

		tTotUnit = sUnitTotUnits[aTargetUnit];

		tTargetChanged, tIsTargetSecret = VUHDO_checkTargetGuidChange(sTargetGuids, aSourceUnit, aTargetUnit);
		tTotChanged, tIsTotSecret = VUHDO_checkTargetGuidChange(sTotGuids, aSourceUnit, tTotUnit);

		if tIsTargetSecret or tIsTotSecret then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_forgetTargetButton(VUHDO_getTargetButton(tButton));
				VUHDO_forgetTargetButton(VUHDO_getTotButton(tButton));
			end

			if UnitExists(aTargetUnit) then
				VUHDO_fillCustomInfo(aTargetUnit);

				tCachedInfo = VUHDO_RAID[aTargetUnit];
				tCachedRange = tCachedInfo and tCachedInfo["range"];

				if tCachedRange == nil then
					tCachedRange = VUHDO_isInRange(aTargetUnit);
				end

				for _, tButton in pairs(tAllButtons) do
					tPanelNum = VUHDO_BUTTON_CACHE[tButton];

					if VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["showTarget"] then
						VUHDO_customizeTargetBar(VUHDO_getTargetButton(tButton), aTargetUnit, tCachedRange);
					end
				end
			end

			if UnitExists(tTotUnit) then
				VUHDO_fillCustomInfo(tTotUnit);

				tCachedInfo = VUHDO_RAID[tTotUnit];
				tCachedRange = tCachedInfo and tCachedInfo["range"];

				if tCachedRange == nil then
					tCachedRange = VUHDO_isInRange(tTotUnit);
				end

				for _, tButton in pairs(tAllButtons) do
					tPanelNum = VUHDO_BUTTON_CACHE[tButton];

					if VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["showTot"] then
						VUHDO_customizeTargetBar(VUHDO_getTotButton(tButton), tTotUnit, tCachedRange);
					end
				end
			end

			return;
		end

		if tTargetChanged or tTotChanged then
			VUHDO_updateTargetBars(aSourceUnit);

			return;
		end

		VUHDO_fillCustomInfo(aTargetUnit);

		tCachedInfo = VUHDO_RAID[aTargetUnit];
		tCachedRange = tCachedInfo and tCachedInfo["range"];

		if tCachedRange == nil then
			tCachedRange = VUHDO_isInRange(aTargetUnit);
		end

		for _, tButton in pairs(tAllButtons) do
			tPanelNum = VUHDO_BUTTON_CACHE[tButton];

			if VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["showTarget"] then
				tTargetButton = VUHDO_getTargetButton(tButton);

				if not sTargetButtonIdentityKeys[tTargetButton] then
					VUHDO_customizeTargetBar(tTargetButton, aTargetUnit, tCachedRange);
				end
			end
		end

		if UnitExists(tTotUnit) then
			VUHDO_fillCustomInfo(tTotUnit);

			tCachedInfo = VUHDO_RAID[tTotUnit];
			tCachedRange = tCachedInfo and tCachedInfo["range"];

			if tCachedRange == nil then
				tCachedRange = VUHDO_isInRange(tTotUnit);
			end

			for _, tButton in pairs(tAllButtons) do
				tPanelNum = VUHDO_BUTTON_CACHE[tButton];

				if VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["showTot"] then
					tTotButton = VUHDO_getTotButton(tButton);

					if not sTargetButtonIdentityKeys[tTotButton] then
						VUHDO_customizeTargetBar(tTotButton, tTotUnit, tCachedRange);
					end
				end
			end
		end

		return;

	end



	--
	function VUHDO_refreshAllTargetBars()

		for tUnit, tInfo in pairs(VUHDO_RAID) do
			if UnitExists(tInfo["targetUnit"]) then
				VUHDO_refreshTargetBars(tUnit, tInfo["targetUnit"]);
			elseif sTargetGuids[tUnit] then
				VUHDO_updateTargetBars(tUnit);
			end
		end

		return;

	end
end