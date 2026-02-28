----------------------------------------------------
local UnitGetIncomingHeals = UnitGetIncomingHeals;
local CreateUnitHealPredictionCalculator = CreateUnitHealPredictionCalculator;
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction;
local sSecretsEnabled = VUHDO_SECRETS_ENABLED;

local VUHDO_CONFIG;

local sHealPredictionCalculator;
local sOvershieldCalculator;
local sIsOthers, sIsOwn, sIsNoInc;

function VUHDO_healCommAdapterInitLocalOverrides()

	VUHDO_CONFIG = _G["VUHDO_CONFIG"];

	sIsOthers = VUHDO_CONFIG["SHOW_INCOMING"];
	sIsOwn = VUHDO_CONFIG["SHOW_OWN_INCOMING"];
	sIsNoInc = not sIsOwn and not sIsOthers;

	return;

end
----------------------------------------------------


local VUHDO_INC_HEAL = { };



--
function VUHDO_ensureHealPredictionCalculator()

	if sHealPredictionCalculator then
		return sHealPredictionCalculator;
	end

	sHealPredictionCalculator = CreateUnitHealPredictionCalculator();

	if not sHealPredictionCalculator then
		return nil;
	end

	sHealPredictionCalculator:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth);
	sHealPredictionCalculator:SetHealAbsorbClampMode(Enum.UnitHealAbsorbClampMode.CurrentHealth);
	sHealPredictionCalculator:SetIncomingHealClampMode(Enum.UnitIncomingHealClampMode.MissingHealth);
	sHealPredictionCalculator:SetHealAbsorbMode(Enum.UnitHealAbsorbMode.Total);
	sHealPredictionCalculator:SetIncomingHealOverflowPercent(1.0);

	return sHealPredictionCalculator;

end



--
function VUHDO_getOvershieldCalculator()

	if sOvershieldCalculator then
		return sOvershieldCalculator;
	end

	sOvershieldCalculator = CreateUnitHealPredictionCalculator();

	if not sOvershieldCalculator then
		return nil;
	end

	sOvershieldCalculator:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealth);

	return sOvershieldCalculator;

end



--
function VUHDO_getIncHealOnUnit(aUnit)

	return VUHDO_INC_HEAL[aUnit] or 0;

end



--
local tCalculator;
local tTotal;
local tFromHealer;
local tFromOthers;
local tClamped;
local tAllIncoming;
function VUHDO_determineIncHeal(aUnit)

	if sIsNoInc then
		return;
	end

	if sSecretsEnabled then
		tCalculator = VUHDO_ensureHealPredictionCalculator();

		if tCalculator then
			tCalculator:ResetPredictedValues();

			UnitGetDetailedHealPrediction(aUnit, "player", tCalculator);

			tTotal, tFromHealer, tFromOthers, tClamped = tCalculator:GetIncomingHeals();

			if sIsOthers then
				if sIsOwn then
					VUHDO_INC_HEAL[aUnit] = tTotal;
				else
					VUHDO_INC_HEAL[aUnit] = tFromOthers;
				end
			else
				VUHDO_INC_HEAL[aUnit] = tFromHealer;
			end
		else
			VUHDO_INC_HEAL[aUnit] = 0;
		end

		return;
	end

	if sIsOthers then
		if sIsOwn then
			VUHDO_INC_HEAL[aUnit] = UnitGetIncomingHeals(aUnit);
		else
			tAllIncoming = (UnitGetIncomingHeals(aUnit) or 0) - (UnitGetIncomingHeals(aUnit, "player") or 0);
			VUHDO_INC_HEAL[aUnit] = tAllIncoming < 0 and 0 or tAllIncoming;
		end
	else
		VUHDO_INC_HEAL[aUnit] = UnitGetIncomingHeals(aUnit, "player");
	end

	return;

end
