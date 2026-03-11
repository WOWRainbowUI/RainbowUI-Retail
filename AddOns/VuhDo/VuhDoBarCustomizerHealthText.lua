local _;

local format = format;

local UnitHealth = UnitHealth;
local UnitHealthMax = UnitHealthMax;
local UnitHealthMissing = UnitHealthMissing;
local UnitHealthPercent = UnitHealthPercent;
local AbbreviateNumbers = AbbreviateNumbers;
local CurveConstants = CurveConstants;
local CreateColorCurve =C_CurveUtil and C_CurveUtil.CreateColorCurve;
local CreateColor = CreateColor;
local TruncateWhenZero = C_StringUtil and C_StringUtil.TruncateWhenZero;
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction;
local UnitIsGhost = UnitIsGhost;

local VUHDO_getHealthBar;
local VUHDO_getBarText;
local VUHDO_getBarTextSolo;
local VUHDO_getLifeText;
local VUHDO_getUnitHealthPercent;
local VUHDO_getUnitHealthModiPercent;
local VUHDO_getColoredString;
local VUHDO_getBarIconFrame;
local VUHDO_utf8Cut;
local VUHDO_getDisplayUnit;
local VUHDO_isBossUnit;
local VUHDO_getIncHealOnUnit;
local VUHDO_getUnitOverallShieldRemain;
local VUHDO_getHealPredictionCalculator;
local VUHDO_UIFrameFlash;

local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;
local VUHDO_RAID;
local VUHDO_CONFIG;
local VUHDO_BAR_COLOR;
local VUHDO_THREAT_CFG;
local VUHDO_KILO_OPTIONS;
local VUHDO_NAME_TEXTS;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;
local sIsOverhealText;
local sIsAggroText;
local sLifeColor;
local sIsNoRangeFade;
local sHealPredictionCalculator;
local sHideIrrelevantCurve;
local sHideMissingZeroCurve;
local sShowWhenFullCurve;
local sShowWhenIrrelevantCurve;



--
local tThresholdDecimal;
local tCurve;
local function VUHDO_buildHideIrrelevantCurve()

	if not sSecretsEnabled then
		return nil;
	end

	tCurve = CreateColorCurve();
	tCurve:SetType(Enum.LuaCurveType.Step);

	-- FIXME: operation modes other than neutral with 100% trigger are bugged
	--tThresholdDecimal = VUHDO_CONFIG["EMERGENCY_TRIGGER"] / 100;
	tThresholdDecimal = 1;

	tCurve:AddPoint(0.0, CreateColor(1, 1, 1, 1));
	tCurve:AddPoint(tThresholdDecimal, CreateColor(1, 1, 1, 0));
	tCurve:AddPoint(1.0, CreateColor(1, 1, 1, 0));

	return tCurve;

end



--
local function VUHDO_buildHideMissingZeroCurve()

	if not sSecretsEnabled then
		return nil;
	end

	tCurve = CreateColorCurve();
	tCurve:SetType(Enum.LuaCurveType.Step);

	tCurve:AddPoint(0.0, CreateColor(1, 1, 1, 1));
	tCurve:AddPoint(1.0, CreateColor(1, 1, 1, 0));

	return tCurve;

end



--
local function VUHDO_buildShowWhenFullCurve()

	if not sSecretsEnabled then
		return nil;
	end

	tCurve = CreateColorCurve();
	tCurve:SetType(Enum.LuaCurveType.Step);

	tCurve:AddPoint(0.0, CreateColor(1, 1, 1, 0));
	tCurve:AddPoint(1.0, CreateColor(1, 1, 1, 1));

	return tCurve;

end



--
local function VUHDO_buildShowWhenIrrelevantCurve()

	if not sSecretsEnabled then
		return nil;
	end

	tCurve = CreateColorCurve();
	tCurve:SetType(Enum.LuaCurveType.Step);

	-- FIXME: operation modes other than neutral with 100% trigger are bugged
	--tThresholdDecimal = VUHDO_CONFIG["EMERGENCY_TRIGGER"] / 100;
	tThresholdDecimal = 1;

	tCurve:AddPoint(0.0, CreateColor(1, 1, 1, 0));
	tCurve:AddPoint(tThresholdDecimal, CreateColor(1, 1, 1, 1));
	tCurve:AddPoint(1.0, CreateColor(1, 1, 1, 1));

	return tCurve;

end



--
function VUHDO_customHealthTextInitLocalOverrides()

	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_BAR_COLOR = VUHDO_PANEL_SETUP["BAR_COLORS"];
	VUHDO_THREAT_CFG = VUHDO_CONFIG["THREAT"];
	VUHDO_KILO_OPTIONS = _G["VUHDO_KILO_OPTIONS"];
	VUHDO_NAME_TEXTS = _G["VUHDO_NAME_TEXTS"];

	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getBarText = _G["VUHDO_getBarText"];
	VUHDO_getBarTextSolo = _G["VUHDO_getBarTextSolo"];
	VUHDO_getLifeText = _G["VUHDO_getLifeText"];
	VUHDO_getUnitHealthPercent = _G["VUHDO_getUnitHealthPercent"];
	VUHDO_getUnitHealthModiPercent = _G["VUHDO_getUnitHealthModiPercent"];
	VUHDO_getColoredString = _G["VUHDO_getColoredString"];
	VUHDO_getBarIconFrame = _G["VUHDO_getBarIconFrame"];
	VUHDO_utf8Cut = _G["VUHDO_utf8Cut"];
	VUHDO_getDisplayUnit = _G["VUHDO_getDisplayUnit"];
	VUHDO_isBossUnit = _G["VUHDO_isBossUnit"];
	VUHDO_getIncHealOnUnit = _G["VUHDO_getIncHealOnUnit"];
	VUHDO_getUnitOverallShieldRemain = _G["VUHDO_getUnitOverallShieldRemain"];
	VUHDO_getHealPredictionCalculator = _G["VUHDO_getHealPredictionCalculator"];
	VUHDO_UIFrameFlash = _G["VUHDO_UIFrameFlash"];

	sIsOverhealText = VUHDO_CONFIG["SHOW_TEXT_OVERHEAL"];
	sIsAggroText = VUHDO_CONFIG["THREAT"]["AGGRO_USE_TEXT"];
	sLifeColor = VUHDO_PANEL_SETUP["PANEL_COLOR"]["HEALTH_TEXT"];
	sIsNoRangeFade = VUHDO_CONFIG["CUSTOM_DEBUFF"]["isNoRangeFade"];

	sHealPredictionCalculator = VUHDO_getHealPredictionCalculator();
	sHideIrrelevantCurve = VUHDO_buildHideIrrelevantCurve();
	sHideMissingZeroCurve = VUHDO_buildHideMissingZeroCurve();
	sShowWhenFullCurve = VUHDO_buildShowWhenFullCurve();
	sShowWhenIrrelevantCurve = VUHDO_buildShowWhenIrrelevantCurve();

	return;

end



--
local function VUHDO_getKiloText(aNumber, aMaxNumber, aSetup)

	return aSetup["LIFE_TEXT"]["verbose"] and aNumber 
		or (aNumber >= 1000000 or aNumber <= -1000000) and format("%.1fM", aNumber * 0.000001)
		or aMaxNumber > 100000 and format("%.0fk", aNumber * 0.001)
		or aMaxNumber > 10000 and format("%.1fk", aNumber * 0.001)
		or aNumber;

end



--
local function VUHDO_getTagText(anInfo)

	if not anInfo["connected"] then
		return VUHDO_I18N_DC;
	elseif anInfo["dead"] then
		return UnitIsGhost(anInfo["unit"]) and format("|cffff0000%s|r", VUHDO_I18N_GHOST) or VUHDO_I18N_RIP;
	elseif anInfo["afk"] then
		return "afk";
	end

	return "";

end



--
local tOwnerInfo;
local tNickname;
local tMaxChars;
local tIndex;
local tNameText;
local function VUHDO_buildNameText(aUnit, anInfo, aSetup, aPanelNum, anIsTarget)

	tOwnerInfo = VUHDO_RAID[anInfo["ownerUnit"]];
	tIndex = anInfo["name"] .. (anInfo["ownerUnit"] or "") .. aPanelNum;

	if not sSecretsEnabled and VUHDO_LibNickTag and aSetup["ID_TEXT"]["showNickname"] then
		tNickname = VUHDO_LibNickTag:GetNickname(anInfo["name"]) or anInfo["name"];
	else
		tNickname = anInfo["name"];
	end

	if anInfo["hasSecretName"] or not VUHDO_NAME_TEXTS[tIndex] or anInfo["name"] ~= tNickname then
		if aSetup["ID_TEXT"]["showName"] then
			tNameText = (aSetup["ID_TEXT"]["showClass"] and not anInfo["isPet"] and anInfo["className"]) 
				and anInfo["className"] .. ": " or "";

			tNameText = tNameText .. ((not tOwnerInfo or not aSetup["ID_TEXT"]["showPetOwners"])
				and tNickname or tOwnerInfo["name"] .. ": " .. tNickname);
		else
			tNameText = (aSetup["ID_TEXT"]["showClass"] and not anInfo["isPet"]) 
				and anInfo["className"] or "";

			if tOwnerInfo and aSetup["ID_TEXT"]["showPetOwners"] then
				tNameText = tNameText .. tOwnerInfo["name"];
			end
		end

		tMaxChars = aSetup["PANEL_COLOR"]["TEXT"]["maxChars"];

		if tMaxChars > 0 then
			if anInfo["hasSecretName"] then
				tNameText = format("%." .. tMaxChars .. "s", tNameText);
			elseif #tNameText > tMaxChars then
				tNameText = VUHDO_utf8Cut(tNameText, tMaxChars);
			end
		end

		if not anInfo["hasSecretName"] then
			VUHDO_NAME_TEXTS[tIndex] = tNameText;
		end
	else
		tNameText = VUHDO_NAME_TEXTS[tIndex];
	end

	if aSetup["ID_TEXT"]["showTags"] and not anIsTarget then
		if "focus" == aUnit then 
			tNameText = format("|cffff0000%s|r-%s", VUHDO_I18N_FOC, tNameText);
		elseif "target" == aUnit then 
			tNameText = format("|cffff0000%s|r-%s", VUHDO_I18N_TAR, tNameText);
		elseif tOwnerInfo and tOwnerInfo["isVehicle"] then 
			tNameText = format("|cffff0000%s|r-%s", VUHDO_I18N_VEHICLE, tNameText);
		end
	end

	return tNameText;

end



--
local tHealth;
local tHealthMax;
local tMissingHealth;
local tLifeStr;
local function VUHDO_buildLifeTextSecret(aUnit, aLifeConfig, anIsTarget)

	if not sHealPredictionCalculator then
		if 1 == aLifeConfig["mode"] or anIsTarget then
			return format("%.0f%%", UnitHealthPercent(aUnit, true, CurveConstants.ScaleTo100)), true;
		elseif 3 == aLifeConfig["mode"] then
			tLifeStr = TruncateWhenZero(UnitHealthMissing(aUnit));

			if aLifeConfig["showTotalHp"] then
				tLifeStr = tLifeStr .. " / " .. AbbreviateNumbers(UnitHealthMax(aUnit), VUHDO_KILO_OPTIONS);
			end

			return tLifeStr, true;
		else
			tLifeStr = AbbreviateNumbers(UnitHealth(aUnit), VUHDO_KILO_OPTIONS);

			if aLifeConfig["showTotalHp"] then
				tLifeStr = tLifeStr .. " / " .. AbbreviateNumbers(UnitHealthMax(aUnit), VUHDO_KILO_OPTIONS);
			end

			return tLifeStr, true;
		end
	end

	if aLifeConfig["showEffectiveHp"] then
		sHealPredictionCalculator:SetMaximumHealthMode(Enum.UnitMaximumHealthMode.WithAbsorbs);
	else
		sHealPredictionCalculator:SetMaximumHealthMode(Enum.UnitMaximumHealthMode.Default);
	end

	sHealPredictionCalculator:ResetPredictedValues();
	UnitGetDetailedHealPrediction(aUnit, "player", sHealPredictionCalculator);

	tHealth = sHealPredictionCalculator:GetCurrentHealth();
	tHealthMax = sHealPredictionCalculator:GetMaximumHealth();
	tMissingHealth = sHealPredictionCalculator:GetMissingHealth();

	if 1 == aLifeConfig["mode"] or anIsTarget then
		return format("%.0f%%", UnitHealthPercent(aUnit, true, CurveConstants.ScaleTo100)), true;
	elseif 3 == aLifeConfig["mode"] then
		tLifeStr = AbbreviateNumbers(tMissingHealth, VUHDO_KILO_OPTIONS);

		if aLifeConfig["showTotalHp"] then
			tLifeStr = tLifeStr .. " / " .. AbbreviateNumbers(tHealthMax, VUHDO_KILO_OPTIONS);
		end

		return tLifeStr, true;
	else
		tLifeStr = AbbreviateNumbers(tHealth, VUHDO_KILO_OPTIONS);

		if aLifeConfig["showTotalHp"] then
			tLifeStr = tLifeStr .. " / " .. AbbreviateNumbers(tHealthMax, VUHDO_KILO_OPTIONS);
		end

		return tLifeStr, true;
	end

end



--
local tMissLife;
local tLifeAmount;
local tShieldLeft;
local tClassicLifeStr;
local function VUHDO_buildLifeTextClassic(aUnit, anInfo, aSetup, aLifeConfig, anIsTarget)

	tLifeAmount = anInfo["health"];

	if aLifeConfig["showEffectiveHp"] then
		tShieldLeft = VUHDO_getUnitOverallShieldRemain(anInfo["unit"]);
		tLifeAmount = tLifeAmount + tShieldLeft;
	else
		tShieldLeft = 0;
	end

	if sIsOverhealText then
		tLifeAmount = tLifeAmount + VUHDO_getIncHealOnUnit(aUnit);
	end

	if 1 == aLifeConfig["mode"] or anIsTarget then
		return format("%d%%", VUHDO_getUnitHealthModiPercent(anInfo, tLifeAmount - anInfo["health"]) * 100), true;
	elseif 3 == aLifeConfig["mode"] then
		tMissLife = tLifeAmount - anInfo["healthmax"];

		if tMissLife < -10 then
			if aLifeConfig["showTotalHp"] then
				tClassicLifeStr = format("%s / %s",
					VUHDO_getKiloText(tMissLife, anInfo["healthmax"], aSetup),
					VUHDO_getKiloText(anInfo["healthmax"], anInfo["healthmax"], aSetup)
				);
			else
				tClassicLifeStr = VUHDO_getKiloText(tMissLife, anInfo["healthmax"], aSetup);
			end

			return tClassicLifeStr, true;
		else
			if aLifeConfig["showTotalHp"] then
				if aLifeConfig["showEffectiveHp"] then
					tClassicLifeStr = VUHDO_getKiloText(anInfo["healthmax"] + tShieldLeft, anInfo["healthmax"] + tShieldLeft, aSetup);
				else
					tClassicLifeStr = VUHDO_getKiloText(anInfo["healthmax"], anInfo["healthmax"], aSetup);
				end

				return tClassicLifeStr, true;
			else
				return "", false;
			end
		end
	else
		if aLifeConfig["showTotalHp"] then
			tClassicLifeStr = format("%s / %s",
				VUHDO_getKiloText(tLifeAmount, anInfo["healthmax"], aSetup),
				VUHDO_getKiloText(anInfo["healthmax"], anInfo["healthmax"], aSetup)
			);
		else
			tClassicLifeStr = format("%s", VUHDO_getKiloText(tLifeAmount, anInfo["healthmax"], aSetup));
		end

		return tClassicLifeStr, (tClassicLifeStr ~= "");
	end

end



--
local tAlphaColor;
local tSoloAlphaColor;
local function VUHDO_applyLifeTextAlpha(aHealthBar, aUnit, aInfo, aLifeConfig)

	if not sSecretsEnabled or not aInfo["hasSecretHealth"] then
		VUHDO_getLifeText(aHealthBar):SetAlpha(1);
		VUHDO_getBarText(aHealthBar):SetAlpha(1);
		VUHDO_getBarTextSolo(aHealthBar):SetAlpha(0);

		return;
	end

	tAlphaColor = nil;
	tSoloAlphaColor = nil;

	if aLifeConfig["hideIrrelevant"] and sHideIrrelevantCurve then
		tAlphaColor = UnitHealthPercent(aUnit, true, sHideIrrelevantCurve);
		tSoloAlphaColor = sShowWhenIrrelevantCurve and UnitHealthPercent(aUnit, true, sShowWhenIrrelevantCurve);
	elseif 3 == aLifeConfig["mode"] and sHideMissingZeroCurve then
		tAlphaColor = UnitHealthPercent(aUnit, true, sHideMissingZeroCurve);
		tSoloAlphaColor = sShowWhenFullCurve and UnitHealthPercent(aUnit, true, sShowWhenFullCurve);
	end

	if tAlphaColor then
		if 1 == aLifeConfig["position"] or 2 == aLifeConfig["position"] then
			VUHDO_getBarText(aHealthBar):SetAlpha(tAlphaColor["a"] or 1);
			VUHDO_getBarTextSolo(aHealthBar):SetAlpha(tSoloAlphaColor and tSoloAlphaColor["a"] or 1);
		else
			VUHDO_getLifeText(aHealthBar):SetAlpha(tAlphaColor["a"] or 1);
			VUHDO_getBarText(aHealthBar):SetAlpha(1);
			VUHDO_getBarTextSolo(aHealthBar):SetAlpha(0);
		end
	else
		VUHDO_getLifeText(aHealthBar):SetAlpha(1);
		VUHDO_getBarText(aHealthBar):SetAlpha(1);
		VUHDO_getBarTextSolo(aHealthBar):SetAlpha(0);
	end

	return;

end



--
local tIsName;
local tIsLife;
local tIsLifeInName;
local tTextString;
local tHealthBar;
local tSetup;
local tLifeConfig;
local tLifeString;
local tHasLifeText;
local tUnit, tInfo;
local tIsShowLife;
local tIsHideIrrel;
local tTagText;
local tIsLifeLeftOrRight;
local tPanelNum;
local tIsLifeTextAlpha;
local tIsLifeTextSeparate;
local tNameWithTag;
local tSoloPart;
local tDisplayLifeForSplit;
function VUHDO_customizeText(aButton, aMode, anIsTarget)

	tUnit, tInfo = VUHDO_getDisplayUnit(aButton);
	tHealthBar = VUHDO_getHealthBar(aButton, 1);

	if not tInfo or not tInfo["name"] then
		tTextString = (tUnit and "focus" == tUnit) and VUHDO_I18N_NO_FOCUS
			or (tUnit and "target" == tUnit) and VUHDO_I18N_NO_TARGET
			or (tUnit and VUHDO_isBossUnit(tUnit)) and VUHDO_I18N_NO_BOSS
			or VUHDO_I18N_NOT_AVAILABLE;
		VUHDO_getBarText(tHealthBar):SetText("");
		VUHDO_getBarText(tHealthBar):SetAlpha(0);
		VUHDO_getBarTextSolo(tHealthBar):SetText(tTextString);
		VUHDO_getBarTextSolo(tHealthBar):SetAlpha(1);
		VUHDO_getLifeText(tHealthBar):SetText("");
		VUHDO_getLifeText(tHealthBar):SetAlpha(0);

		return;
	end

	tPanelNum = VUHDO_BUTTON_CACHE[aButton];
	tSetup = VUHDO_PANEL_SETUP[tPanelNum];
	tLifeConfig = tSetup["LIFE_TEXT"];

	if sSecretsEnabled and tInfo["hasSecretHealth"] and tLifeConfig["hideIrrelevant"] then
		tIsHideIrrel = false;
	else
		-- FIXME: operation modes other than neutral with 100% trigger are bugged
		--tIsHideIrrel = tLifeConfig["hideIrrelevant"] and VUHDO_getUnitHealthPercent(tInfo) >= VUHDO_CONFIG["EMERGENCY_TRIGGER"];
		tIsHideIrrel = tLifeConfig["hideIrrelevant"] and VUHDO_getUnitHealthPercent(tInfo) >= 100;
	end

	tIsShowLife = tLifeConfig["show"] and not tIsHideIrrel;

	tIsLifeLeftOrRight =
		1 == tLifeConfig["position"]
		or 2 == tLifeConfig["position"];

	tIsLifeInName = tLifeConfig["show"] and tIsLifeLeftOrRight;

	tIsLifeTextAlpha = sSecretsEnabled
		and tInfo["hasSecretHealth"]
		and (tLifeConfig["hideIrrelevant"] or 3 == tLifeConfig["mode"]);

	tIsLifeTextSeparate = not tIsLifeLeftOrRight or tIsLifeTextAlpha;

	tIsName = aMode ~= 2 or tIsLifeInName;
	tIsLife = aMode ~= 7 or tIsLifeInName;

	tTextString = "";

	if tIsName then
		tTextString = VUHDO_buildNameText(tUnit, tInfo, tSetup, tPanelNum, anIsTarget);
	end

	tTagText = (tSetup["ID_TEXT"]["showTags"] and not anIsTarget)
		and VUHDO_getTagText(tInfo) or "";

	if tIsLife and tIsShowLife then
		if tTagText ~= "" or tIsHideIrrel then
			tLifeString = "";
			tHasLifeText = false;
		else
			if sSecretsEnabled then
				tLifeString, tHasLifeText = VUHDO_buildLifeTextSecret(tUnit, tLifeConfig, anIsTarget);
			else
				tLifeString, tHasLifeText = VUHDO_buildLifeTextClassic(tUnit, tInfo, tSetup, tLifeConfig, anIsTarget);
			end
		end

		tLifeString = VUHDO_getColoredString(tLifeString, sLifeColor);

		if tIsLifeTextSeparate then
			if not tIsLifeLeftOrRight then
				VUHDO_getLifeText(tHealthBar):SetText(tTagText ~= "" and tTagText or tLifeString);
				VUHDO_applyLifeTextAlpha(tHealthBar, tUnit, tInfo, tLifeConfig);
			end
		else
			if tTagText ~= "" then tTagText = tTagText .. "-"; end

			if 2 == tLifeConfig["position"] then
				tTextString = tHasLifeText
					and format("%s%s %s", tTagText, tLifeString, tTextString)
					or format("%s%s", tTagText, tTextString);
			else
				tTextString = format("%s%s %s", tTagText, tTextString, tLifeString);
			end

			VUHDO_getLifeText(tHealthBar):SetText("");
			VUHDO_getLifeText(tHealthBar):SetAlpha(1);
		end
	elseif tIsLife then
		if tIsLifeLeftOrRight then
			if not tIsLifeTextSeparate and tTagText ~= "" then
				tTextString = tTagText .. "-" .. tTextString;
			end

			VUHDO_getLifeText(tHealthBar):SetText("");
		else
			VUHDO_getLifeText(tHealthBar):SetText(tTagText);
		end
	end

	if tIsName then
		if tIsLifeTextSeparate and tIsLifeLeftOrRight then
			tNameWithTag = (tTagText ~= "" and tTagText .. "-" .. tTextString or tTextString);
			tDisplayLifeForSplit = (tIsLife and tIsShowLife) and (tLifeString or "") or "";

			tTextString = tNameWithTag .. " " .. tDisplayLifeForSplit;

			if tInfo["aggro"] and sIsAggroText then
				tTextString = format("|cffff2020%s|r%s|cffff2020%s|r",
					VUHDO_THREAT_CFG["AGGRO_TEXT_LEFT"], tTextString, VUHDO_THREAT_CFG["AGGRO_TEXT_RIGHT"]);
				tSoloPart = format("|cffff2020%s|r%s|cffff2020%s|r", VUHDO_THREAT_CFG["AGGRO_TEXT_LEFT"], tNameWithTag, VUHDO_THREAT_CFG["AGGRO_TEXT_RIGHT"]);
			else
				tSoloPart = tNameWithTag;
			end

			VUHDO_getBarText(tHealthBar):SetText(tTextString);
			VUHDO_getBarTextSolo(tHealthBar):SetText(tSoloPart);

			VUHDO_applyLifeTextAlpha(tHealthBar, tUnit, tInfo, tLifeConfig);
		else
			if tInfo["aggro"] and sIsAggroText then
				tTextString = format("|cffff2020%s|r%s|cffff2020%s|r",
					VUHDO_THREAT_CFG["AGGRO_TEXT_LEFT"], tTextString, VUHDO_THREAT_CFG["AGGRO_TEXT_RIGHT"]);
			end

			VUHDO_getBarText(tHealthBar):SetText(tTextString);
			VUHDO_getBarText(tHealthBar):SetAlpha(1);

			VUHDO_getBarTextSolo(tHealthBar):SetText(tTextString);
			VUHDO_getBarTextSolo(tHealthBar):SetAlpha(0);
		end
	end

	return;

end



--
local tScaling;
function VUHDO_customizeDamageFlash(aButton, anInfo)

	if sSecretsEnabled then
		return;
	end

	tScaling = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]]["SCALING"];

	if tScaling["isDamFlash"] and tScaling["damFlashFactor"] >= (anInfo["lifeLossPerc"] or -1) then
		VUHDO_UIFrameFlash(_G[aButton:GetName() .. "BgBarHlBarFlBar"], 0.05, 0.15, 0.25, false, 0.05, 0);
	end

	return;

end



--
local tRangeInfo;
local tAlpha;
local tIcon;
local tOutrangedAlpha;
local tIconAlpha;
function VUHDO_customizeDebuffIconsRange(aButton)

	if sIsNoRangeFade then
		return;
	end

	_, tRangeInfo = VUHDO_getDisplayUnit(aButton);

	if tRangeInfo then
		tOutrangedAlpha = VUHDO_BAR_COLOR["OUTRANGED"]["O"];

		for tCnt = 40, 44 do
			tIcon = VUHDO_getBarIconFrame(aButton, tCnt);

			if tIcon then
				tIconAlpha = tIcon:GetAlpha();

				if issecretvalue(tIconAlpha) or tIconAlpha > 0 then
					if tRangeInfo["hasSecretRange"] then
						tIcon:SetAlphaFromBoolean(tRangeInfo["range"], 1, tOutrangedAlpha);
					else
						tAlpha = tRangeInfo["range"] and 1 or tOutrangedAlpha;
						tIcon:SetAlpha(tAlpha);
					end
				end
			end
		end
	end

	return;

end
