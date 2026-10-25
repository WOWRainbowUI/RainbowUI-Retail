local _;

local tinsert = table.insert;
local twipe = table.wipe;

VUHDO_FLAVOR_CLASS_MODEL_IDS_WORK = { };
local VUHDO_FLAVOR_CLASS_MODEL_IDS_WORK = VUHDO_FLAVOR_CLASS_MODEL_IDS_WORK;

local sFlavor = VUHDO_FLAVOR;
local sEmpty = { };

local sFlavorClassModelOrder = {
	20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
};



--
function VUHDO_getFlavor()

	return sFlavor;

end



--
local tRules;
local tClasses;
function VUHDO_flavorHasClass(aModelId)

	tRules = VUHDO_FLAVOR_RULES;

	if not tRules then
		return true;
	end

	tClasses = tRules["CLASSES"];

	if not tClasses then
		return true;
	end

	return tClasses[aModelId] == true;

end



--
local tPowerTypes;
function VUHDO_flavorHasPowerType(aPowerType)

	tRules = VUHDO_FLAVOR_RULES;

	if not tRules then
		return true;
	end

	tPowerTypes = tRules["POWER_TYPES"];

	if not tPowerTypes then
		return true;
	end

	return tPowerTypes[aPowerType] == true;

end



--
local tFeatures;
function VUHDO_flavorHasFeature(aFeature)

	tRules = VUHDO_FLAVOR_RULES;

	if not tRules then
		return true;
	end

	tFeatures = tRules["FEATURES"];

	if not tFeatures then
		return true;
	end

	return tFeatures[aFeature] == true;

end



--
function VUHDO_getFlavorSpecModel()

	tRules = VUHDO_FLAVOR_RULES;

	if not tRules or not tRules["SPEC_MODEL"] then
		return VUHDO_FLAVOR_SPEC_SPECIALIZATIONS;
	end

	return tRules["SPEC_MODEL"];

end



--
local tKind;
local tValue;
function VUHDO_isFlavorRequirementMet(aRequirement)

	if not aRequirement then
		return true;
	end

	tKind = aRequirement[1];
	tValue = aRequirement[2];

	if VUHDO_FLAVOR_REQ_CLASS == tKind then
		return VUHDO_flavorHasClass(tValue);
	elseif VUHDO_FLAVOR_REQ_POWER == tKind then
		return VUHDO_flavorHasPowerType(tValue);
	elseif VUHDO_FLAVOR_REQ_FEATURE == tKind then
		return VUHDO_flavorHasFeature(tValue);
	end

	return true;

end



--
local tKey;
local tValue;
function VUHDO_applyFlavorEntries(aBase, aEntries)

	if not aBase or not aEntries then
		return;
	end

	for tKey, tValue in pairs(aEntries) do
		aBase[tKey] = tValue;
	end

	return;

end



--
local tClassId;
function VUHDO_getFlavorClassModelIds()

	twipe(VUHDO_FLAVOR_CLASS_MODEL_IDS_WORK);

	for _, tClassId in ipairs(sFlavorClassModelOrder) do
		if VUHDO_flavorHasClass(tClassId) then
			tinsert(VUHDO_FLAVOR_CLASS_MODEL_IDS_WORK, tClassId);
		end
	end

	return VUHDO_FLAVOR_CLASS_MODEL_IDS_WORK;

end



--
function VUHDO_verifyFlavorRulesLoaded()

	if sFlavor and not VUHDO_FLAVOR_RULES then
		print("|cffff0000{VuhDo}|r Flavor \"" .. tostring(sFlavor) .. "\" loaded without VUHDO_FLAVOR_RULES (VuhDoFlavorRules.lua missing?).");
	end

	return;

end



if not sFlavor then
	print("|cffff0000{VuhDo}|r No flavor loaded (TOC flavor slots missing).");
end
