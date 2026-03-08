local _;

VUHDO_NAME_TEXTS = { };
local VUHDO_NAME_TEXTS = VUHDO_NAME_TEXTS;


-- BURST CACHE ---------------------------------------------------

local VUHDO_getHealthBar;
local VUHDO_getBarText;
local VUHDO_getBarTextSolo;
local VUHDO_getIncHealOnUnit;
local VUHDO_getDiffColor;
local VUHDO_isPanelVisible;
local VUHDO_updateManaBars;
local VUHDO_updateAllHoTs;
local VUHDO_removeAllHots;
local VUHDO_getPanelButtons;
local VUHDO_updateBouquetsForEvent;
local VUHDO_resolveVehicleUnit;
local VUHDO_getOverhealPanel;
local VUHDO_getOverhealText;
local VUHDO_getUnitButtons;
local VUHDO_getUnitButtonsSafe;
local VUHDO_getBarRoleIcon;
local VUHDO_updateClusterHighlights;
local VUHDO_customizeTargetBar;
local VUHDO_getUnitOverallShieldRemain;
local VUHDO_getHealAbsorbBar;
local VUHDO_setStatusBarVuhDoColor;
local VUHDO_getStatusbarOrientationString;
local VUHDO_getPixelScale;
local VUHDO_applyAllLayersToBar;
local VUHDO_getHealPredictionCalculator;
local VUHDO_getOvershieldCalculator;

local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;
local VUHDO_RAID;
local VUHDO_CONFIG;
local VUHDO_INDICATOR_CONFIG;
local VUHDO_IN_RAID_TARGET_BUTTONS;
local VUHDO_INTERNAL_TOGGLES;

local strfind = strfind;
local GetRaidTargetIndex = GetRaidTargetIndex;
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs;
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction;
local UnitHealthPercent = UnitHealthPercent;
local CreateCurve = C_CurveUtil and C_CurveUtil.CreateCurve;
local CreateColorCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve;
local CreateColor = CreateColor;
local pairs = pairs;
local twipe = table.wipe;
local format = format;
local min = math.min;
local issecretvalue = issecretvalue;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;
local sHealPredictionCalculator;
local sOvershieldCalculator;
local sOvershieldAlphaCurve;
local sHideWhenFullHealthCurve;
local sIsOverhealText;
local sIsAggroText;
local sIsInvertGrowth = { };
local sIsTurnAxisOvershield = { };
local sIsTurnAxisHealAbsorb = { };
local sConfigShieldColor;
local sConfigOvershieldColor;
local sConfigHealAbsorbColor;
local sConfigIncColor;



--
function VUHDO_customHealthInitLocalOverrides()

	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_INDICATOR_CONFIG = _G["VUHDO_INDICATOR_CONFIG"];
 	VUHDO_BAR_COLOR = VUHDO_PANEL_SETUP["BAR_COLORS"];
 	VUHDO_THREAT_CFG = VUHDO_CONFIG["THREAT"];
 	VUHDO_IN_RAID_TARGET_BUTTONS = _G["VUHDO_IN_RAID_TARGET_BUTTONS"];
	VUHDO_INTERNAL_TOGGLES = _G["VUHDO_INTERNAL_TOGGLES"];
	VUHDO_KILO_OPTIONS = _G["VUHDO_KILO_OPTIONS"];

	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getBarText = _G["VUHDO_getBarText"];
	VUHDO_getBarTextSolo = _G["VUHDO_getBarTextSolo"];
	VUHDO_getIncHealOnUnit = _G["VUHDO_getIncHealOnUnit"];
	VUHDO_getDiffColor = _G["VUHDO_getDiffColor"];
	VUHDO_isPanelVisible = _G["VUHDO_isPanelVisible"];
	VUHDO_updateManaBars = _G["VUHDO_updateManaBars"];
	VUHDO_removeAllHots = _G["VUHDO_removeAllHots"];
	VUHDO_updateAllHoTs = _G["VUHDO_updateAllHoTs"];
	VUHDO_getUnitHealthPercent = _G["VUHDO_getUnitHealthPercent"];
	VUHDO_getPanelButtons = _G["VUHDO_getPanelButtons"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_utf8Cut = _G["VUHDO_utf8Cut"];
	VUHDO_resolveVehicleUnit = _G["VUHDO_resolveVehicleUnit"];
	VUHDO_getOverhealPanel = _G["VUHDO_getOverhealPanel"];
	VUHDO_getOverhealText = _G["VUHDO_getOverhealText"];
	VUHDO_getBarRoleIcon = _G["VUHDO_getBarRoleIcon"];
	VUHDO_getBarIconFrame = _G["VUHDO_getBarIconFrame"];
	VUHDO_updateClusterHighlights = _G["VUHDO_updateClusterHighlights"];
	VUHDO_customizeTargetBar = _G["VUHDO_customizeTargetBar"];
	VUHDO_getColoredString = _G["VUHDO_getColoredString"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_getUnitOverallShieldRemain = _G["VUHDO_getUnitOverallShieldRemain"];
	VUHDO_getHealAbsorbBar = _G["VUHDO_getHealAbsorbBar"];
	VUHDO_setStatusBarVuhDoColor = _G["VUHDO_setStatusBarVuhDoColor"];
	VUHDO_getStatusBarColor = _G["VUHDO_getStatusBarColor"];
	VUHDO_calculateDerivedOrientation = _G["VUHDO_calculateDerivedOrientation"];
	VUHDO_setStatusBarOrientation = _G["VUHDO_setStatusBarOrientation"];
	VUHDO_getStatusbarOrientationString = _G["VUHDO_getStatusbarOrientationString"];
	VUHDO_getPixelScale = _G["VUHDO_getPixelScale"];
	VUHDO_applyAllLayersToBar = _G["VUHDO_applyAllLayersToBar"];
	VUHDO_getHealPredictionCalculator = _G["VUHDO_getHealPredictionCalculator"];
	VUHDO_getOvershieldCalculator = _G["VUHDO_getOvershieldCalculator"];

	sHealPredictionCalculator = VUHDO_getHealPredictionCalculator();
	sOvershieldCalculator = VUHDO_getOvershieldCalculator();

	sIsOverhealText = VUHDO_CONFIG["SHOW_TEXT_OVERHEAL"]
	sIsAggroText = VUHDO_CONFIG["THREAT"]["AGGRO_USE_TEXT"];

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		sIsInvertGrowth[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["invertGrowth"];
		sIsTurnAxisOvershield[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["turnAxisOvershield"];
		sIsTurnAxisHealAbsorb[tPanelNum] = VUHDO_INDICATOR_CONFIG[tPanelNum]["CUSTOM"]["HEALTH_BAR"]["turnAxisHealAbsorb"];
	end

	sOvershieldAlphaCurve = VUHDO_buildOvershieldAlphaCurve();
	sHideWhenFullHealthCurve = VUHDO_buildHideWhenFullHealthCurve();

	twipe(VUHDO_NAME_TEXTS);

	return;

end

----------------------------------------------------


--
local tOvershieldAlphaCurve;
function VUHDO_buildOvershieldAlphaCurve()

	tOvershieldAlphaCurve = CreateCurve();
	tOvershieldAlphaCurve:SetType(Enum.LuaCurveType.Step);

	tOvershieldAlphaCurve:AddPoint(0.0, 0);
	tOvershieldAlphaCurve:AddPoint(0.9999, 1);

	return tOvershieldAlphaCurve;

end



--
local tCurve;
function VUHDO_buildHideWhenFullHealthCurve()

	if not sSecretsEnabled then
		return nil;
	end

	tCurve = CreateColorCurve();
	tCurve:SetType(Enum.LuaCurveType.Step);
	tCurve:AddPoint(0.0, CreateColor(1, 1, 1, 1));
	tCurve:AddPoint(1.0, CreateColor(1, 1, 1, 0));

	return tCurve;

end



function VUHDO_resetNameTextCache()
	twipe(VUHDO_NAME_TEXTS);
end



local tIncColor = { ["useBackground"] = true };
local tShieldColor = { ["useBackground"] = true };
local tOvershieldColor = { ["useBackground"] = true };
local tHealAbsorbColor = { ["useBackground"] = true };



--
function VUHDO_getUnitHealthModiPercent(anInfo, aModifier)
	return anInfo["healthmax"] == 0 and 0
		or (anInfo["health"] + aModifier) / anInfo["healthmax"];
end
local VUHDO_getUnitHealthModiPercent = VUHDO_getUnitHealthModiPercent;



--
local tOpacity;
local function VUHDO_setStatusBarColor(aBar, aColor)

	tOpacity = aColor["useOpacity"] and aColor["O"] or nil;

	if aColor["useBackground"] then
		if tOpacity then
			aBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], tOpacity);
		else
			aBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"]);
		end
	elseif tOpacity then
		aBar:SetAlpha(tOpacity);
	end

end



--
local tOpacity;
local function VUHDO_setTextureColor(aTexture, aColor)

	tOpacity = aColor["useOpacity"] and aColor["O"] or nil;

	if aColor["useBackground"] then
		if tOpacity then
			aTexture:SetVertexColor(aColor["R"], aColor["G"], aColor["B"], tOpacity);
		else
			aTexture:SetVertexColor(aColor["R"], aColor["G"], aColor["B"]);
		end
	elseif tOpacity then 
		aTexture:SetAlpha(tOpacity); 
	end

end



--
local tInfo;
local tAmountInc;
local tHealthPlusInc;
local function VUHDO_getHealthPlusIncQuota(aUnit)
	tInfo = VUHDO_RAID[aUnit];
	if not tInfo["connected"] or tInfo["dead"] then
		return 0, 0;
	else
		tAmountInc = VUHDO_getIncHealOnUnit(aUnit);
		tHealthPlusInc = VUHDO_getUnitHealthModiPercent(tInfo, tAmountInc);
		tHealthPlusInc = tHealthPlusInc > 1 and 1 or tHealthPlusInc;
		return tHealthPlusInc, tAmountInc;
	end
end



--
local tBarColor, tBarClassColor;
local tInfo;
local function VUHDO_getStatusBarColor(aBarType, aUnit)

	tBarColor = VUHDO_PANEL_SETUP["BAR_COLORS"][aBarType];

	if not tBarColor then
		return;
	end

	if not tBarColor["useClassColor"] then
		return tBarColor;
	else
		tInfo = VUHDO_RAID[aUnit];

		if not tInfo then
			return tBarColor;
		end

		tBarClassColor = VUHDO_copyColor(VUHDO_getClassColor(tInfo));

		if tBarColor["useOpacity"] then
			tBarClassColor["useOpacity"] = true;
			tBarClassColor["O"], tBarClassColor["TO"] = tBarColor["O"], tBarColor["TO"];
		end

		return tBarClassColor;
	end

end



--
local tInfo;
local tAllButtons;
local tShieldInBar;
local tShieldClamped;
local tTotalShield;
local tAtFullHealth;
local tHealth;
local tHealthMax;
local tAlpha;
local tIncHeal;
local tHealthBar;
local tIncBar;
local tShieldBar;
local tOvershieldBar;
local tShieldOpacity;
local tOvershieldOpacity;
local tShieldColor = { };
local tOvershieldColor = { };
local tHealthDeficit;
local tSpaceInBar;
local tShieldAmount;
local tOvershieldAmount;
local tOverallShieldRemain;
local tAbsorbAmount;
local tVisibleAmountInc;
local tOvershieldBarSizePercent;
local tOvershieldBarOffsetPercent;
local tOvershieldBarSize;
local tOvershieldBarOffset;
local tHealthBarWidth;
local tHealthBarHeight;
local tPixelThreshold;
local tPanelNum;
local tOrientation;
local tOrientationOvershield;
local tIsInvertGrowth;
local tIsTurnAxisOvershield;
local aHealthPlusIncQuota;
local aAmountInc;
local tSecretColor;
function VUHDO_updateShieldBar(aUnit, aIncHealAmount)

	tInfo = VUHDO_RAID[aUnit];
	tAllButtons = VUHDO_getUnitButtonsSafe(VUHDO_resolveVehicleUnit(aUnit));

	if not tInfo or not VUHDO_CONFIG["SHOW_SHIELD_BAR"] then
		for _, tButton in pairs(tAllButtons) do
			VUHDO_getHealthBar(tButton, 19):Hide();
			VUHDO_getHealthBar(tButton, 20):Hide();
		end

		return;
	end

	if sSecretsEnabled and tInfo["hasSecretHealthMax"] then
		if not tInfo["healthmax"] then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_getHealthBar(tButton, 19):Hide();
				VUHDO_getHealthBar(tButton, 20):Hide();
			end

			return;
		end
	else
		if tInfo["healthmax"] <= 0 then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_getHealthBar(tButton, 19):Hide();
				VUHDO_getHealthBar(tButton, 20):Hide();
			end

			return;
		end
	end

	if not tInfo["connected"] or tInfo["dead"] then
		for _, tButton in pairs(tAllButtons) do
			VUHDO_getHealthBar(tButton, 19):Hide();
			VUHDO_getHealthBar(tButton, 20):Hide();
		end

		return;
	end

	if sHealPredictionCalculator then
		sHealPredictionCalculator:ResetPredictedValues();
		sHealPredictionCalculator:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth);

		UnitGetDetailedHealPrediction(aUnit, "player", sHealPredictionCalculator);

		tShieldInBar, _ = sHealPredictionCalculator:GetDamageAbsorbs();
		tHealthMax = sHealPredictionCalculator:GetMaximumHealth();

		if sOvershieldCalculator then
			sOvershieldCalculator:ResetPredictedValues();

			UnitGetDetailedHealPrediction(aUnit, "player", sOvershieldCalculator);

			_, tShieldClamped = sOvershieldCalculator:GetDamageAbsorbs();
		else
			tShieldClamped = false;
		end

		sHealPredictionCalculator:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MaximumHealth);

		UnitGetDetailedHealPrediction(aUnit, "player", sHealPredictionCalculator);

		tTotalShield = sHealPredictionCalculator:GetTotalDamageAbsorbs();

		sHealPredictionCalculator:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth);

		for _, tButton in pairs(tAllButtons) do
			tHealthBar = VUHDO_getHealthBar(tButton, 1);
			tShieldBar = VUHDO_getHealthBar(tButton, 19);
			tOvershieldBar = VUHDO_getHealthBar(tButton, 20);

			tShieldBar:SetMinMaxValues(0, tHealthMax);
			tShieldBar:SetValue(tShieldInBar);

			if sSecretsEnabled and tHealthBar["secretCurveColor"] and tHealthBar["secretCurveColor"]["R"] then
				sConfigShieldColor = VUHDO_getStatusBarColor("SHIELD", aUnit);

				if sConfigShieldColor then
					tSecretColor = tHealthBar["secretCurveColor"];

					if sConfigShieldColor["useBackground"] then
						tShieldBar:GetStatusBarTexture():SetVertexColor(sConfigShieldColor["R"], sConfigShieldColor["G"], sConfigShieldColor["B"], tSecretColor["O"]);
					else
						tShieldBar:GetStatusBarTexture():SetVertexColor(tSecretColor["R"], tSecretColor["G"], tSecretColor["B"], tSecretColor["O"]);
					end

					if sConfigShieldColor["useOpacity"] then
						tShieldBar:SetAlpha(sConfigShieldColor["O"] or 1);
					end
				end
			elseif not sSecretsEnabled then
				tShieldColor["R"], tShieldColor["G"], tShieldColor["B"], tShieldOpacity = tHealthBar:GetStatusBarColor();
				tShieldColor = VUHDO_getDiffColor(tShieldColor, VUHDO_getStatusBarColor("SHIELD", aUnit));

				if tShieldColor["O"] and tShieldOpacity then
					tShieldColor["O"] = tShieldColor["O"] * tShieldOpacity * (tHealthBar:GetAlpha() or 1);
				end

				VUHDO_setStatusBarVuhDoColor(tShieldBar, tShieldColor);
			else
				sConfigShieldColor = VUHDO_getStatusBarColor("SHIELD", aUnit);

				if sConfigShieldColor then
					VUHDO_setStatusBarVuhDoColor(tShieldBar, sConfigShieldColor);
				end
			end

			tShieldBar:Show();

			if sSecretsEnabled and tHealthBar["isInverted"] and sHideWhenFullHealthCurve then
				tAlpha = UnitHealthPercent(aUnit, true, sHideWhenFullHealthCurve);
				tShieldBar:SetAlpha(tAlpha and tAlpha["a"] or 1);
			end

			if VUHDO_CONFIG["SHOW_OVERSHIELD_BAR"] then
				tOvershieldBar:SetMinMaxValues(0, tHealthMax);
				tOvershieldBar:SetValue(tTotalShield);

				if sSecretsEnabled and tHealthBar["secretCurveColor"] and tHealthBar["secretCurveColor"]["R"] then
					sConfigOvershieldColor = VUHDO_getStatusBarColor("OVERSHIELD", aUnit);

					if sConfigOvershieldColor then
						tSecretColor = tHealthBar["secretCurveColor"];

						if sConfigOvershieldColor["useBackground"] then
							tOvershieldBar:GetStatusBarTexture():SetVertexColor(sConfigOvershieldColor["R"], sConfigOvershieldColor["G"], sConfigOvershieldColor["B"], tSecretColor["O"]);
						else
							tOvershieldBar:GetStatusBarTexture():SetVertexColor(tSecretColor["R"], tSecretColor["G"], tSecretColor["B"], tSecretColor["O"]);
						end

						if sConfigOvershieldColor["useOpacity"] then
							tOvershieldBar:SetAlpha(sConfigOvershieldColor["O"] or 1);
						end
					end
				elseif not sSecretsEnabled then
					tOvershieldColor["R"], tOvershieldColor["G"], tOvershieldColor["B"], tOvershieldOpacity = tHealthBar:GetStatusBarColor();
					tOvershieldColor = VUHDO_getDiffColor(tOvershieldColor, VUHDO_getStatusBarColor("OVERSHIELD", aUnit));

					if tOvershieldColor["O"] and tOvershieldOpacity then
						tOvershieldColor["O"] = tOvershieldColor["O"] * tOvershieldOpacity * (tHealthBar:GetAlpha() or 1);
					end

					VUHDO_setStatusBarVuhDoColor(tOvershieldBar, tOvershieldColor);
				else
					sConfigOvershieldColor = VUHDO_getStatusBarColor("OVERSHIELD", aUnit);

					if sConfigOvershieldColor then
						VUHDO_setStatusBarVuhDoColor(tOvershieldBar, sConfigOvershieldColor);
					end
				end

				tOvershieldBar:Show();

				if sOvershieldAlphaCurve and UnitHealthPercent then
					tAlpha = UnitHealthPercent(aUnit, true, sOvershieldAlphaCurve);
					tOvershieldBar:SetAlpha(tAlpha or 0);
				else
					tOvershieldBar:SetAlpha(0);
				end
			else
				tOvershieldBar:Hide();
			end
		end
	else
		if not aHealthPlusIncQuota or not aAmountInc then
			aHealthPlusIncQuota, aAmountInc = VUHDO_getHealthPlusIncQuota(aUnit);
		end

		tOverallShieldRemain = VUHDO_getUnitOverallShieldRemain(aUnit);
		tAbsorbAmount = tOverallShieldRemain / tInfo["healthmax"];

		tHealthDeficit = tInfo["healthmax"] - tInfo["health"];
		tVisibleAmountInc = min(aAmountInc, tHealthDeficit);
		tOverallShieldRemain = min(tOverallShieldRemain, tInfo["healthmax"]);

		tOvershieldBarSizePercent = (tOverallShieldRemain - tHealthDeficit + tVisibleAmountInc) / tInfo["healthmax"];
		tOvershieldBarOffsetPercent = (tHealthDeficit - tVisibleAmountInc) / tInfo["healthmax"];

		tPixelThreshold = 1 / VUHDO_getPixelScale() / 2;

		for _, tButton in pairs(tAllButtons) do
			tPanelNum = VUHDO_BUTTON_CACHE[tButton];

			tOrientation = VUHDO_getStatusbarOrientationString("HEALTH_BAR", tPanelNum);
			tIsInvertGrowth = sIsInvertGrowth[tPanelNum];
			tIsTurnAxisOvershield = sIsTurnAxisOvershield[tPanelNum];

			if (tIsTurnAxisOvershield and tOrientation == "HORIZONTAL") or (not tIsTurnAxisOvershield and tOrientation == "HORIZONTAL_INV") then
				tOrientationOvershield = "HORIZONTAL_INV";
			elseif (tIsTurnAxisOvershield and tOrientation == "HORIZONTAL_INV") or (not tIsTurnAxisOvershield and tOrientation == "HORIZONTAL") then
				tOrientationOvershield = "HORIZONTAL";
			elseif (tIsTurnAxisOvershield and tOrientation == "VERTICAL") or (not tIsTurnAxisOvershield and tOrientation == "VERTICAL_INV") then
				tOrientationOvershield = "VERTICAL_INV";
			else -- (tIsTurnAxisOvershield and tOrientation == "VERTICAL_INV")) or (not tIsTurnAxisOvershield and tOrientation == "VERTICAL")
				tOrientationOvershield = "VERTICAL";
			end

			tHealthBar = VUHDO_getHealthBar(tButton, 1);
			tShieldBar = VUHDO_getHealthBar(tButton, 19);

			if tAbsorbAmount > 0 then
				tShieldBar:SetMinMaxValues(aHealthPlusIncQuota, aHealthPlusIncQuota + tAbsorbAmount);
				tShieldBar:SetValue(aHealthPlusIncQuota + tAbsorbAmount);

				tShieldColor["R"], tShieldColor["G"], tShieldColor["B"], tShieldOpacity = tHealthBar:GetStatusBarColor();
				tShieldColor = VUHDO_getDiffColor(tShieldColor, VUHDO_getStatusBarColor("SHIELD", aUnit));

				if tShieldColor["O"] and tShieldOpacity then
					tShieldColor["O"] = tShieldColor["O"] * tShieldOpacity * (tHealthBar:GetAlpha() or 1);
				end

				VUHDO_setStatusBarVuhDoColor(tShieldBar, tShieldColor);

				tShieldBar:Show();
			else
				tShieldBar:SetMinMaxValues(0, 1);
				tShieldBar:SetValue(0);
				tShieldBar:Hide();
			end

			tOvershieldBar = VUHDO_getHealthBar(tButton, 20);

			if VUHDO_CONFIG["SHOW_OVERSHIELD_BAR"] and (tOverallShieldRemain > tHealthDeficit) then
				tOvershieldBar:ClearAllPoints();

				tOvershieldColor["R"], tOvershieldColor["G"], tOvershieldColor["B"], tOvershieldOpacity = tHealthBar:GetStatusBarColor();
				tOvershieldColor = VUHDO_getDiffColor(tOvershieldColor, VUHDO_getStatusBarColor("OVERSHIELD", aUnit));

				if tOvershieldColor["O"] and tOvershieldOpacity then
					tOvershieldColor["O"] = tOvershieldColor["O"] * tOvershieldOpacity * (tHealthBar:GetAlpha() or 1);
				end

				VUHDO_setStatusBarVuhDoColor(tOvershieldBar, tOvershieldColor);

				tHealthBarWidth, tHealthBarHeight = tHealthBar:GetSize();

				if (not tIsInvertGrowth and tOrientationOvershield == "HORIZONTAL") or
					(tIsInvertGrowth and tOrientationOvershield == "HORIZONTAL_INV") then
					-- VUHDO_STATUSBAR_LEFT_TO_RIGHT
					tOvershieldBarSize = max(0, tOvershieldBarSizePercent * tHealthBarWidth);
					tOvershieldBarOffset = max(0, tOvershieldBarOffsetPercent * tHealthBarWidth);

					if tOvershieldBarSize > tPixelThreshold then
						VUHDO_PixelUtil.SetPoint(tOvershieldBar, "TOPRIGHT", tHealthBar, "TOPRIGHT", tOvershieldBarOffset * -1, 0);
						VUHDO_PixelUtil.SetPoint(tOvershieldBar, "BOTTOMRIGHT", tHealthBar, "BOTTOMRIGHT", tOvershieldBarOffset * -1, 0);

						VUHDO_PixelUtil.SetSize(tOvershieldBar, tOvershieldBarSize, tHealthBarHeight);

						tOvershieldBar:SetMinMaxValues(0, tOvershieldBarSize);
						tOvershieldBar:SetValue(tOvershieldBarSize);

						tOvershieldBar:Show();
					else
						tOvershieldBar:Hide();
					end
				elseif (not tIsInvertGrowth and tOrientationOvershield == "HORIZONTAL_INV") or
					(tIsInvertGrowth and tOrientationOvershield == "HORIZONTAL") then
					-- VUHDO_STATUSBAR_RIGHT_TO_LEFT
					tOvershieldBarSize = max(0, tOvershieldBarSizePercent * tHealthBarWidth);
					tOvershieldBarOffset = max(0, tOvershieldBarOffsetPercent * tHealthBarWidth);

					if tOvershieldBarSize > tPixelThreshold then
						VUHDO_PixelUtil.SetPoint(tOvershieldBar, "TOPLEFT", tHealthBar, "TOPLEFT", tOvershieldBarOffset, 0);
						VUHDO_PixelUtil.SetPoint(tOvershieldBar, "BOTTOMLEFT", tHealthBar, "BOTTOMLEFT", tOvershieldBarOffset, 0);

						VUHDO_PixelUtil.SetSize(tOvershieldBar, tOvershieldBarSize, tHealthBarHeight);

						tOvershieldBar:SetMinMaxValues(0, tOvershieldBarSize);
						tOvershieldBar:SetValue(tOvershieldBarSize);

						tOvershieldBar:Show();
					else
						tOvershieldBar:Hide();
					end
				elseif (not tIsInvertGrowth and tOrientationOvershield == "VERTICAL") or
					(tIsInvertGrowth and tOrientationOvershield == "VERTICAL_INV") then
					-- VUHDO_STATUSBAR_BOTTOM_TO_TOP
					tOvershieldBarSize = max(0, tOvershieldBarSizePercent * tHealthBarHeight);
					tOvershieldBarOffset = max(0, tOvershieldBarOffsetPercent * tHealthBarHeight);

					if tOvershieldBarSize > tPixelThreshold then
						VUHDO_PixelUtil.SetPoint(tOvershieldBar, "TOPLEFT", tHealthBar, "TOPLEFT", 0, tOvershieldBarOffset * -1);
						VUHDO_PixelUtil.SetPoint(tOvershieldBar, "TOPRIGHT", tHealthBar, "TOPRIGHT", 0, tOvershieldBarOffset * -1);

						VUHDO_PixelUtil.SetSize(tOvershieldBar, tHealthBarWidth, tOvershieldBarSize);

						tOvershieldBar:SetMinMaxValues(0, tOvershieldBarSize);
						tOvershieldBar:SetValue(tOvershieldBarSize);

						tOvershieldBar:Show();
					else
						tOvershieldBar:Hide();
					end
				else -- (not tIsInvertGrowth and tOrientationOvershield == "VERTICAL_INV") or (tIsInvertGrowth and tOrientationOvershield == "VERTICAL")
					-- VUHDO_STATUSBAR_TOP_TO_BOTTOM
					tOvershieldBarSize = max(0, tOvershieldBarSizePercent * tHealthBarHeight);
					tOvershieldBarOffset = max(0, tOvershieldBarOffsetPercent * tHealthBarHeight);

					if tOvershieldBarSize > tPixelThreshold then
						VUHDO_PixelUtil.SetPoint(tOvershieldBar, "BOTTOMLEFT", tHealthBar, "BOTTOMLEFT", 0, tOvershieldBarOffset);
						VUHDO_PixelUtil.SetPoint(tOvershieldBar, "BOTTOMRIGHT", tHealthBar, "BOTTOMRIGHT", 0, tOvershieldBarOffset);

						VUHDO_PixelUtil.SetSize(tOvershieldBar, tHealthBarWidth, tOvershieldBarSize);

						tOvershieldBar:SetMinMaxValues(0, tOvershieldBarSize);
						tOvershieldBar:SetValue(tOvershieldBarSize);

						tOvershieldBar:Show();
					else
						tOvershieldBar:Hide();
					end
				end
			else
				tOvershieldBar:Hide();
			end
		end
	end

	return;

end
local VUHDO_updateShieldBar = VUHDO_updateShieldBar;



--
local tInfo;
local tAllButtons;
local tHealAbsorb;
local tHealAbsorbClamped;
local tHealAbsorbOpacity;
local tHealthBar;
local tHealAbsorbBar;
local tHealAbsorbColor = { };
local tHealth;
local tHealAbsorbAmount;
local tHealAbsorbRemain;
local tHealthBarWidth;
local tHealthBarHeight;
local tHealthDeficit;
local tHealAbsorbBarSize;
local tHealAbsorbBarSizePercent;
local tHealAbsorbBarOffset;
local tHealAbsorbBarOffsetPercent;
local tOrientation;
local tOrientationHealAbsorb;
local tPanelNum;
local tIsInvertGrowth;
local tIsTurnAxisHealAbsorb;
local tPixelThreshold;
local tSecretColor;
function VUHDO_updateHealAbsorbBar(aUnit)

	tInfo = VUHDO_RAID[aUnit];
	tAllButtons = VUHDO_getUnitButtonsSafe(VUHDO_resolveVehicleUnit(aUnit));

	if not tInfo or not VUHDO_CONFIG["SHOW_HEAL_ABSORB_BAR"] then
		for _, tButton in pairs(tAllButtons) do
			VUHDO_getHealAbsorbBar(VUHDO_getHealthBar(tButton, 1)):Hide();
		end

		return;
	end

	if sSecretsEnabled and tInfo["hasSecretHealthMax"] then
		if not tInfo["healthmax"] then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_getHealAbsorbBar(VUHDO_getHealthBar(tButton, 1)):Hide();
			end

			return;
		end
	else
		if tInfo["healthmax"] <= 0 then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_getHealAbsorbBar(VUHDO_getHealthBar(tButton, 1)):Hide();
			end

			return;
		end
	end

	if not tInfo["connected"] or tInfo["dead"] then
		for _, tButton in pairs(tAllButtons) do
			VUHDO_getHealAbsorbBar(VUHDO_getHealthBar(tButton, 1)):Hide();
		end
		return;
	end

	if sHealPredictionCalculator then
		sHealPredictionCalculator:ResetPredictedValues();

		UnitGetDetailedHealPrediction(aUnit, "player", sHealPredictionCalculator);

		tHealAbsorb = sHealPredictionCalculator:GetTotalHealAbsorbs();
		tHealthMax = sHealPredictionCalculator:GetMaximumHealth();

		for _, tButton in pairs(tAllButtons) do
			tHealthBar = VUHDO_getHealthBar(tButton, 1);
			tHealAbsorbBar = VUHDO_getHealAbsorbBar(tHealthBar);

			tHealAbsorbBar:SetMinMaxValues(0, tHealthMax);
			tHealAbsorbBar:SetValue(tHealAbsorb);

			if sSecretsEnabled and tHealthBar["secretCurveColor"] and tHealthBar["secretCurveColor"]["R"] then
				sConfigHealAbsorbColor = VUHDO_getStatusBarColor("HEAL_ABSORB", aUnit);

				if sConfigHealAbsorbColor then
					tSecretColor = tHealthBar["secretCurveColor"];

					if sConfigHealAbsorbColor["useBackground"] then
						tHealAbsorbBar:GetStatusBarTexture():SetVertexColor(sConfigHealAbsorbColor["R"], sConfigHealAbsorbColor["G"], sConfigHealAbsorbColor["B"], tSecretColor["O"]);
					else
						tHealAbsorbBar:GetStatusBarTexture():SetVertexColor(tSecretColor["R"], tSecretColor["G"], tSecretColor["B"], tSecretColor["O"]);
					end

					if sConfigHealAbsorbColor["useOpacity"] then
						tHealAbsorbBar:SetAlpha(sConfigHealAbsorbColor["O"] or 1);
					end
				end
			elseif not sSecretsEnabled then
				tHealAbsorbColor["R"], tHealAbsorbColor["G"], tHealAbsorbColor["B"], tHealAbsorbOpacity = tHealthBar:GetStatusBarColor();
				tHealAbsorbColor = VUHDO_getDiffColor(tHealAbsorbColor, VUHDO_getStatusBarColor("HEAL_ABSORB", aUnit));

				if tHealAbsorbColor["O"] and tHealAbsorbOpacity then
					tHealAbsorbColor["O"] = tHealAbsorbColor["O"] * tHealAbsorbOpacity * (tHealthBar:GetAlpha() or 1);
				end

				VUHDO_setStatusBarVuhDoColor(tHealAbsorbBar, tHealAbsorbColor);
			else
				sConfigHealAbsorbColor = VUHDO_getStatusBarColor("HEAL_ABSORB", aUnit);

				if sConfigHealAbsorbColor then
					VUHDO_setStatusBarVuhDoColor(tHealAbsorbBar, sConfigHealAbsorbColor);
				end
			end

			tHealAbsorbBar:Show();
		end
	else
		tHealAbsorbRemain = min(UnitGetTotalHealAbsorbs(aUnit) or 0, tInfo["health"]);
		tHealthDeficit = tInfo["healthmax"] - tInfo["health"];

		tHealAbsorbBarSizePercent = tHealAbsorbRemain / tInfo["healthmax"];
		tHealAbsorbBarOffsetPercent = tHealthDeficit / tInfo["healthmax"];

		tPixelThreshold = 1 / VUHDO_getPixelScale() / 2;

		for _, tButton in pairs(tAllButtons) do
			tPanelNum = VUHDO_BUTTON_CACHE[tButton];

			tOrientation = VUHDO_getStatusbarOrientationString("HEALTH_BAR", tPanelNum);
			tIsInvertGrowth = sIsInvertGrowth[tPanelNum];
			tIsTurnAxisHealAbsorb = sIsTurnAxisHealAbsorb[tPanelNum];

			if (tIsTurnAxisHealAbsorb and tOrientation == "HORIZONTAL") or (not tIsTurnAxisHealAbsorb and tOrientation == "HORIZONTAL_INV") then
				tOrientationHealAbsorb = "HORIZONTAL_INV";
			elseif (tIsTurnAxisHealAbsorb and tOrientation == "HORIZONTAL_INV") or (not tIsTurnAxisHealAbsorb and tOrientation == "HORIZONTAL") then
				tOrientationHealAbsorb = "HORIZONTAL";
			elseif (tIsTurnAxisHealAbsorb and tOrientation == "VERTICAL") or (not tIsTurnAxisHealAbsorb and tOrientation == "VERTICAL_INV") then
				tOrientationHealAbsorb = "VERTICAL_INV";
			else -- (tIsTurnAxisHealAbsorb and tOrientation == "VERTICAL_INV")) or (not tIsTurnAxisHealAbsorb and tOrientation == "VERTICAL")
				tOrientationHealAbsorb = "VERTICAL";
			end

			tHealthBar = VUHDO_getHealthBar(tButton, 1);
			tHealAbsorbBar = VUHDO_getHealAbsorbBar(tHealthBar);

			if VUHDO_CONFIG["SHOW_HEAL_ABSORB_BAR"] and (tHealAbsorbRemain > 0) then
				tHealAbsorbBar:SetParent(tHealthBar);
				tHealAbsorbBar:ClearAllPoints();

				tHealAbsorbColor["R"], tHealAbsorbColor["G"], tHealAbsorbColor["B"], tHealAbsorbOpacity = tHealthBar:GetStatusBarColor();
				tHealAbsorbColor = VUHDO_getDiffColor(tHealAbsorbColor, VUHDO_getStatusBarColor("HEAL_ABSORB", aUnit));

				if tHealAbsorbColor["O"] and tHealAbsorbOpacity then
					tHealAbsorbColor["O"] = tHealAbsorbColor["O"] * tHealAbsorbOpacity * (tHealthBar:GetAlpha() or 1);
				end

				VUHDO_setStatusBarVuhDoColor(tHealAbsorbBar, tHealAbsorbColor);

				tHealthBarWidth, tHealthBarHeight = tHealthBar:GetSize();

				if (not tIsInvertGrowth and tOrientationHealAbsorb == "HORIZONTAL") or
					(tIsInvertGrowth and tOrientationHealAbsorb == "HORIZONTAL_INV") then
					-- VUHDO_STATUSBAR_LEFT_TO_RIGHT
					tHealAbsorbBarSize = max(0, tHealAbsorbBarSizePercent * tHealthBarWidth);
					tHealAbsorbBarOffset = max(0, tHealAbsorbBarOffsetPercent * tHealthBarWidth);

					if tHealAbsorbBarSize > tPixelThreshold then
						VUHDO_PixelUtil.SetPoint(tHealAbsorbBar, "TOPRIGHT", tHealthBar, "TOPRIGHT", tHealAbsorbBarOffset * -1, 0);
						VUHDO_PixelUtil.SetPoint(tHealAbsorbBar, "BOTTOMRIGHT", tHealthBar, "BOTTOMRIGHT", tHealAbsorbBarOffset * -1, 0);

						VUHDO_PixelUtil.SetSize(tHealAbsorbBar, tHealAbsorbBarSize, tHealthBarHeight);

						tHealAbsorbBar:SetMinMaxValues(0, tHealAbsorbBarSize);
						tHealAbsorbBar:SetValue(tHealAbsorbBarSize);

						tHealAbsorbBar:Show();
					else
						tHealAbsorbBar:Hide();
					end
				elseif (not tIsInvertGrowth and tOrientationHealAbsorb == "HORIZONTAL_INV") or
					(tIsInvertGrowth and tOrientationHealAbsorb == "HORIZONTAL") then
					-- VUHDO_STATUSBAR_RIGHT_TO_LEFT
					tHealAbsorbBarSize = max(0, tHealAbsorbBarSizePercent * tHealthBarWidth);
					tHealAbsorbBarOffset = max(0, tHealAbsorbBarOffsetPercent * tHealthBarWidth);

					if tHealAbsorbBarSize > tPixelThreshold then
						VUHDO_PixelUtil.SetPoint(tHealAbsorbBar, "TOPLEFT", tHealthBar, "TOPLEFT", tHealAbsorbBarOffset, 0);
						VUHDO_PixelUtil.SetPoint(tHealAbsorbBar, "BOTTOMLEFT", tHealthBar, "BOTTOMLEFT", tHealAbsorbBarOffset, 0);

						VUHDO_PixelUtil.SetSize(tHealAbsorbBar, tHealAbsorbBarSize, tHealthBarHeight);

						tHealAbsorbBar:SetMinMaxValues(0, tHealAbsorbBarSize);
						tHealAbsorbBar:SetValue(tHealAbsorbBarSize);

						tHealAbsorbBar:Show();
					else
						tHealAbsorbBar:Hide();
					end
				elseif (not tIsInvertGrowth and tOrientationHealAbsorb == "VERTICAL") or
					(tIsInvertGrowth and tOrientationHealAbsorb == "VERTICAL_INV") then
					-- VUHDO_STATUSBAR_BOTTOM_TO_TOP
					tHealAbsorbBarSize = max(0, tHealAbsorbBarSizePercent * tHealthBarHeight);
					tHealAbsorbBarOffset = max(0, tHealAbsorbBarOffsetPercent * tHealthBarHeight);

					if tHealAbsorbBarSize > tPixelThreshold then
						VUHDO_PixelUtil.SetPoint(tHealAbsorbBar, "TOPLEFT", tHealthBar, "TOPLEFT", 0, tHealAbsorbBarOffset * -1);
						VUHDO_PixelUtil.SetPoint(tHealAbsorbBar, "TOPRIGHT", tHealthBar, "TOPRIGHT", 0, tHealAbsorbBarOffset * -1);

						VUHDO_PixelUtil.SetSize(tHealAbsorbBar, tHealthBarWidth, tHealAbsorbBarSize);

						tHealAbsorbBar:SetMinMaxValues(0, tHealAbsorbBarSize);
						tHealAbsorbBar:SetValue(tHealAbsorbBarSize);

						tHealAbsorbBar:Show();
					else
						tHealAbsorbBar:Hide();
					end
				else -- (not tIsInvertGrowth and tOrientationHealAbsorb == "VERTICAL_INV") or (tIsInvertGrowth and tOrientationHealAbsorb == "VERTICAL")
					-- VUHDO_STATUSBAR_TOP_TO_BOTTOM
					tHealAbsorbBarSize = max(0, tHealAbsorbBarSizePercent * tHealthBarHeight);
					tHealAbsorbBarOffset = max(0, tHealAbsorbBarOffsetPercent * tHealthBarHeight);

					if tHealAbsorbBarSize > tPixelThreshold then
						VUHDO_PixelUtil.SetPoint(tHealAbsorbBar, "BOTTOMLEFT", tHealthBar, "BOTTOMLEFT", 0, tHealAbsorbBarOffset);
						VUHDO_PixelUtil.SetPoint(tHealAbsorbBar, "BOTTOMRIGHT", tHealthBar, "BOTTOMRIGHT", 0, tHealAbsorbBarOffset);

						VUHDO_PixelUtil.SetSize(tHealAbsorbBar, tHealthBarWidth, tHealAbsorbBarSize);

						tHealAbsorbBar:SetMinMaxValues(0, tHealAbsorbBarSize);
						tHealAbsorbBar:SetValue(tHealAbsorbBarSize);

						tHealAbsorbBar:Show();
					else
						tHealAbsorbBar:Hide();
					end
				end
			else
				tHealAbsorbBar:Hide();
			end
		end
	end

	return;

end
local VUHDO_updateHealAbsorbBar = VUHDO_updateHealAbsorbBar;



--
local tAllButtons;
local tHealthPlusInc;
local tIncBar;
local tAmountInc;
local tInfo;
local tOpacity;
local tHealthBar;
local tIncHealAmount;
local tSecretColor;
local function VUHDO_updateIncHeal(aUnit)

	tInfo = VUHDO_RAID[aUnit];
	tAllButtons = VUHDO_getUnitButtons(VUHDO_resolveVehicleUnit(aUnit));

	if not tInfo or not tAllButtons then
		return;
	end

	tIncHealAmount = VUHDO_getIncHealOnUnit(aUnit);

	for _, tButton in pairs(tAllButtons) do
		tIncBar = VUHDO_getHealthBar(tButton, 6);
		tHealthBar = VUHDO_getHealthBar(tButton, 1);

		if tIncHealAmount and tInfo["healthmax"] and (not sSecretsEnabled or issecretvalue(tIncHealAmount) or tIncHealAmount > 0) and (not sSecretsEnabled or tInfo["hasSecretHealthMax"] or tInfo["healthmax"] > 0) then
			tIncBar:SetMinMaxValues(0, tInfo["healthmax"]);
			tIncBar:SetValue(tIncHealAmount);

			if sSecretsEnabled and tHealthBar["secretCurveColor"] and tHealthBar["secretCurveColor"]["R"] then
				sConfigIncColor = VUHDO_getStatusBarColor("INCOMING", aUnit);

				if sConfigIncColor then
					tSecretColor = tHealthBar["secretCurveColor"];

					if sConfigIncColor["useBackground"] then
						tIncBar:GetStatusBarTexture():SetVertexColor(sConfigIncColor["R"], sConfigIncColor["G"], sConfigIncColor["B"], tSecretColor["O"]);
					else
						tIncBar:GetStatusBarTexture():SetVertexColor(tSecretColor["R"], tSecretColor["G"], tSecretColor["B"], tSecretColor["O"]);
					end

					if sConfigIncColor["useOpacity"] then
						tIncBar:SetAlpha(sConfigIncColor["O"] or 1);
					end
				end
			elseif not sSecretsEnabled then
				tIncColor["R"], tIncColor["G"], tIncColor["B"], tOpacity = tHealthBar:GetStatusBarColor();
				tIncColor = VUHDO_getDiffColor(tIncColor, VUHDO_getStatusBarColor("INCOMING", aUnit));

				if tIncColor["O"] and tOpacity then
					tIncColor["O"] = tIncColor["O"] * tOpacity * (tHealthBar:GetAlpha() or 1);
				end

				VUHDO_setStatusBarColor(tIncBar, tIncColor);
			else
				sConfigIncColor = VUHDO_getStatusBarColor("INCOMING", aUnit);

				if sConfigIncColor then
					VUHDO_setStatusBarColor(tIncBar, sConfigIncColor);
				end
			end

			tIncBar:Show();
		else
			tIncBar:Hide();
		end
	end

	VUHDO_updateShieldBar(aUnit, tIncHealAmount);
	VUHDO_updateHealAbsorbBar(aUnit);

	return;

end



--
local tRatio, tBar, tScale;
local tPanelNum;
function VUHDO_overhealTextCallback(aUnit, aProviderName, aValue, anIndicatorName, ...)

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];

		if VUHDO_INDICATOR_CONFIG[tPanelNum]["TEXT_INDICATORS"][anIndicatorName]["TEXT_PROVIDER"] == aProviderName then
			tBar = VUHDO_getHealthBar(tButton, 1);
			VUHDO_getOverhealText(tBar):SetText(format(...));

			if strfind(aProviderName, "OVERHEAL", 1, true) then
				tInfo = VUHDO_RAID[aUnit];

				if tInfo then
					if sSecretsEnabled and (issecretvalue(aValue) or tInfo["hasSecretHealthMax"]) then
					elseif aValue > 0 and tInfo["healthmax"] > 0 then
						tRatio = aValue / tInfo["healthmax"];
						tScale = VUHDO_PANEL_SETUP[tPanelNum]["OVERHEAL_TEXT"]["scale"];

						VUHDO_PixelUtil.SetScale(VUHDO_getOverhealPanel(tBar), tRatio < 1 and (0.5 + tRatio) * tScale or 1.5 * tScale);
					end
				end
			end
		end
	end

end



--
VUHDO_CUSTOM_INFO = {
	["number"] = 1,
	["range"] = true,
	["debuff"] = 0,
	--["isPet"] = false,
	--["charmed"] = false,
	--["aggro"] = false,
	["group"] = 0,
	--["afk"] = false,
	["threat"] = 0,
	["threatPerc"] = 0,
	--["isVehicle"] = false,
	--["ownerUnit"] = nil,
	--["petUnit"] = nil,
	--["missbuff"] = nil,
	--["mibucateg"] = nil,
	--["mibuvariants"] = nil,
	--["raidIcon"] = nil,
	["visible"] = true,
	["baseRange"] = true,
};
local VUHDO_CUSTOM_INFO = VUHDO_CUSTOM_INFO;



--
local tUnit;
function VUHDO_getDisplayUnit(aButton)

	tUnit = aButton:GetAttribute("unit");

	if not tUnit then
		return nil, nil;
	elseif strfind(tUnit, "target", 1, true) and tUnit ~= "target" then
		if not VUHDO_CUSTOM_INFO["fixResolveId"] then
			return tUnit, VUHDO_CUSTOM_INFO;
		else
			return VUHDO_CUSTOM_INFO["fixResolveId"], VUHDO_RAID[VUHDO_CUSTOM_INFO["fixResolveId"]];
		end
	else
		if VUHDO_RAID[tUnit] and VUHDO_RAID[tUnit]["isVehicle"] then
			tUnit = VUHDO_RAID[tUnit]["petUnit"];
		end

		return tUnit, VUHDO_RAID[tUnit];
	end

	return;

end
local VUHDO_getDisplayUnit = VUHDO_getDisplayUnit;



do
	--
	local tHealthBar;
	local tPanelNum;
	local tQuota;
	local tBackgroundBouquet;
	local function VUHDO_updateHealthBarValueForUnit(aUnit, aCurrValue, aMaxValue, aColor, aMaxColor, aBouquetName, aLayerTemplate, aCurrValue2)

		for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
			tPanelNum = VUHDO_BUTTON_CACHE[tButton];

			if VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["HEALTH_BAR"] == aBouquetName then
				tHealthBar = VUHDO_getHealthBar(tButton, 1);

				tHealthBar:SetMinMaxValues(0, aMaxValue);

				if tHealthBar["isInverted"] then
					tQuota = sSecretsEnabled and aCurrValue2 or (aMaxValue - aCurrValue);
				else
					tQuota = aCurrValue;
				end

				tHealthBar:SetValue(tQuota);

				if aLayerTemplate then
					VUHDO_applyAllLayersToBar(tButton, tHealthBar, aLayerTemplate);
				elseif aColor then
					VUHDO_setStatusBarVuhDoColor(tHealthBar, aColor, aMaxColor);

					if aColor["useText"] then
						VUHDO_getBarText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"]);
						VUHDO_getBarTextSolo(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"]);
						VUHDO_getLifeText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"]);
					end
				end

				if sSecretsEnabled then
					tBackgroundBouquet = VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["BACKGROUND_BAR"];

					if not tBackgroundBouquet or tBackgroundBouquet == "" then
						VUHDO_updateIndicatorAlphaChain(tButton, "HEALTH_BAR", VUHDO_RAID[aUnit]);
					end
				end
			end
		end

	end



	--
	local tAllButtons;
	local tInfo;
	function VUHDO_healthBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

		aMaxValue = aMaxValue or 0;
		aCurrValue = aCurrValue or 0;
		aCurrValue2 = aCurrValue2 or 0;

		VUHDO_updateHealthBarValueForUnit(aUnit, aCurrValue, aMaxValue, aColor, aMaxColor, aBouquetName, aLayerTemplate, aCurrValue2);

		tInfo = VUHDO_RAID[aUnit]

		if not tInfo then
			return;
		end

		if tInfo["hasSecretName"] then
			return;
		end

		tAllButtons = VUHDO_IN_RAID_TARGET_BUTTONS[tInfo["name"]];

		if not tAllButtons then
			return;
		end

		VUHDO_CUSTOM_INFO["fixResolveId"] = aUnit;

		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeTargetBar(tButton, aUnit, tInfo["range"]);
		end

		if sSecretsEnabled then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_updateIndicatorAlphaChain(tButton, "HEALTH_BAR", tInfo);
			end
		end

	end



	--
	local tAggroBar;
	function VUHDO_aggroBarBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

		for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
			if aBouquetName == nil or VUHDO_INDICATOR_CONFIG[VUHDO_BUTTON_CACHE[tButton]]["BOUQUETS"]["AGGRO_BAR"] == aBouquetName then
				tAggroBar = VUHDO_getHealthBar(tButton, 4);

				if anIsActive then
					tAggroBar:SetValue(1);

					if aLayerTemplate then
						VUHDO_applyAllLayersToBar(tButton, tAggroBar, aLayerTemplate);
					elseif aColor then
						VUHDO_setStatusBarVuhDoColor(tAggroBar, aColor);
					end

					tAggroBar:Show();
				else
					tAggroBar:SetValue(0);
					tAggroBar:Hide();
				end

				if sSecretsEnabled then
					VUHDO_updateIndicatorAlphaChain(tButton, "AGGRO_BAR", VUHDO_RAID[aUnit]);
				end
			end
		end

	end



	--
	local tBar, tQuota;
	function VUHDO_backgroundBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

		tQuota = (anIsActive or (aMaxValue or 0) > 1) and 1 or 0;

		for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
			if VUHDO_INDICATOR_CONFIG[VUHDO_BUTTON_CACHE[tButton]]["BOUQUETS"]["BACKGROUND_BAR"] == aBouquetName then
				tBar = VUHDO_getHealthBar(tButton, 3);

				tBar:SetMinMaxValues(0, 1);
				tBar:SetValue(tQuota);

				if anIsActive then
					if aLayerTemplate then
						VUHDO_applyAllLayersToBar(tButton, tBar, aLayerTemplate);
					elseif aColor then
						VUHDO_setStatusBarVuhDoColor(tBar, aColor);
					end
				end

				if sSecretsEnabled then
					VUHDO_updateIndicatorAlphaChain(tButton, "BACKGROUND_BAR", VUHDO_RAID[aUnit]);
				end
			end
		end

	end
end



--
local tTexture;
local tIcon;
local tUnit;
local tPrivateAura;
function VUHDO_customizeHealButton(aButton)

	VUHDO_customizeText(aButton, 1, false); -- VUHDO_UPDATE_ALL

	tUnit = VUHDO_getDisplayUnit(aButton);

	-- Raid icon
	if VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]]["RAID_ICON"]["show"] and tUnit then
		tIcon = GetRaidTargetIndex(tUnit);

		if tIcon then
			if sSecretsEnabled and issecretvalue(tIcon) then
				tTexture = VUHDO_getBarRoleIcon(aButton, 50);

				VUHDO_setRaidTargetIconTexture(tTexture, tIcon);

				tTexture:Show();
			elseif VUHDO_PANEL_SETUP["RAID_ICON_FILTER"][tIcon] then
				tTexture = VUHDO_getBarRoleIcon(aButton, 50);

				VUHDO_setRaidTargetIconTexture(tTexture, tIcon);

				tTexture:Show();
			else
				VUHDO_getBarRoleIcon(aButton, 50):Hide();
			end
		else
			VUHDO_getBarRoleIcon(aButton, 50):Hide();
		end
	end

	for tAuraIndex = 1, VUHDO_MAX_PRIVATE_AURAS do
		tPrivateAura = VUHDO_getBarPrivateAura(aButton, tAuraIndex);

		if not tPrivateAura then
			return;
		end

		if VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]]["PRIVATE_AURA"]["show"] and tPrivateAura["anchorId"] then
			tPrivateAura:Show();
		else
			tPrivateAura:Hide();
		end
	end

end
local VUHDO_customizeHealButton = VUHDO_customizeHealButton;



--
local tInfo;
local tAllButtons;
function VUHDO_updateHealthBarsFor(aUnit, anUpdateMode)
	-- as of patch 7.1 we are seeing empty units on health related events
	if not aUnit then
		return;
	end

	VUHDO_updateBouquetsForEvent(aUnit, anUpdateMode);

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if not tAllButtons then	return; end

	if 2 == anUpdateMode then -- VUHDO_UPDATE_HEALTH
		VUHDO_determineIncHeal(aUnit);

		tInfo = VUHDO_RAID[aUnit];
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH

			if tInfo then 
				VUHDO_customizeDamageFlash(tButton, tInfo);
			end
		end

		if tInfo then
			tInfo["lifeLossPerc"] = nil;
		end

		VUHDO_updateIncHeal(aUnit);

	elseif 9 == anUpdateMode then -- VUHDO_UPDATE_INC
		VUHDO_determineIncHeal(aUnit);
		if sIsOverhealText then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH
			end
		end
		VUHDO_updateIncHeal(aUnit);

	elseif 7 == anUpdateMode then -- VUHDO_UPDATE_AGGRO
		if sIsAggroText then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_customizeText(tButton, 7, false); -- VUHDO_UPDATE_AGGRO
			end
		end

	elseif 5 == anUpdateMode then -- VUHDO_UPDATE_RANGE
		VUHDO_determineIncHeal(aUnit);
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, false); -- für d/c tag -- VUHDO_UPDATE_HEALTH
			VUHDO_customizeDebuffIconsRange(tButton);
		end
		VUHDO_updateIncHeal(aUnit);

	elseif 3 == anUpdateMode then -- VUHDO_UPDATE_HEALTH_MAX
		VUHDO_determineIncHeal(aUnit);
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH
		end
		VUHDO_updateIncHeal(aUnit);

	elseif 6 == anUpdateMode then -- VUHDO_UPDATE_AFK
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, false); -- VUHDO_UPDATE_ALL
		end
	elseif 10 == anUpdateMode then -- VUHDO_UPDATE_ALIVE
		VUHDO_determineIncHeal(aUnit);
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, false); -- VUHDO_UPDATE_ALL
		end
		VUHDO_updateIncHeal(aUnit);

	elseif 25 == anUpdateMode then -- VUHDO_UPDATE_RESURRECTION
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, false); -- VUHDO_UPDATE_ALL
		end

	elseif 19 == anUpdateMode then -- VUHDO_UPDATE_DC
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH
		end

	elseif 1 == anUpdateMode then -- VUHDO_UPDATE_ALL
		VUHDO_determineIncHeal(aUnit);
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeHealButton(tButton);
		end

		VUHDO_updateIncHeal(aUnit);
	end
end



--
function VUHDO_updateAllPanelBars(aPanelNum)
	for _, tButton in pairs(VUHDO_getPanelButtons(aPanelNum)) do
		if not tButton:GetAttribute("unit") then break; end
		VUHDO_customizeHealButton(tButton);
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateIncHeal(tUnit); -- Trotzdem wichtig um Balken zu verstecken bei neuen Units
		VUHDO_updateManaBars(tUnit, 3);
		VUHDO_manaBarBouquetCallback(tUnit, false);
	end
end



--
VUHDO_REMOVE_HOTS = true;
function VUHDO_updateAllRaidBars()

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		if VUHDO_isPanelVisible(tPanelNum) then
			for _, tButton in pairs(VUHDO_getPanelButtons(tPanelNum)) do
				if not tButton:GetAttribute("unit") then
					break;
				end

				VUHDO_customizeHealButton(tButton);
			end
		end
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateIncHeal(tUnit); -- Trotzdem wichtig um Balken zu verstecken bei neuen Units
		VUHDO_updateManaBars(tUnit, 3);
		VUHDO_manaBarBouquetCallback(tUnit, false);
		VUHDO_aggroBarBouquetCallback(tUnit, false);
	end

	if VUHDO_REMOVE_HOTS then
		if sSecretsEnabled then
			VUHDO_showAllAuras();
		else
			VUHDO_removeAllHots();
			VUHDO_updateAllHoTs();
		end

		if VUHDO_INTERNAL_TOGGLES[18] then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
			VUHDO_updateClusterHighlights();
		end
	else
		VUHDO_REMOVE_HOTS = true;
	end

	return;

end



--
function VUHDO_updatePanelButtons(aPanelNum)

	if not VUHDO_isPanelVisible(aPanelNum) then
		return;
	end

	for _, tButton in pairs(VUHDO_getPanelButtons(aPanelNum)) do
		if not tButton:GetAttribute("unit") then
			break;
		end

		VUHDO_customizeHealButton(tButton);
	end

	return;

end



--
function VUHDO_deferUpdateAllRaidBarsDelegate(aPriority)

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		if VUHDO_isPanelVisible(tPanelNum) then
			VUHDO_deferUpdatePanelButtons(tPanelNum, aPriority);
		end
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateIncHeal(tUnit);
		VUHDO_deferUpdateManaBars(tUnit, 3, aPriority);
		VUHDO_deferUpdateUnitAggro(tUnit, nil, aPriority);
	end

	if VUHDO_REMOVE_HOTS then
		VUHDO_deferUpdateAllHoTs(aPriority);

		if VUHDO_INTERNAL_TOGGLES[18] then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
			VUHDO_deferUpdateClusterHighlights(aPriority);
		end
	else
		VUHDO_REMOVE_HOTS = true;
	end

	return;

end