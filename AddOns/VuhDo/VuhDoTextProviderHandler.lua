local _;

local pairs = pairs;
local tinsert = table.insert;
local twipe = table.wipe;
local sort = table.sort;

local VUHDO_RAID;
local VUHDO_TEXT_PROVIDER_SOURCES;
local VUHDO_TEXT_PROVIDER_FORMATS;
local VUHDO_INDICATOR_CONFIG;
local VUHDO_PANEL_MODELS;

local VUHDO_tableGetKeyFromValue;
local VUHDO_getRegisteredBouquets;
local VUHDO_getRegisteredBouquetIndicators;
local VUHDO_updateBouquetsForEvent;
local VUHDO_isBouquetInterestedInEvent;
local VUHDO_strempty;
local VUHDO_getActiveBouquets;

VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL = { };
local VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL = VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL;

VUHDO_TEXT_PROVIDER_FORMAT_COMBO_MODEL = { };
local VUHDO_TEXT_PROVIDER_FORMAT_COMBO_MODEL = VUHDO_TEXT_PROVIDER_FORMAT_COMBO_MODEL;

local VUHDO_REGISTERED_PROVIDERS = { };
setmetatable(VUHDO_REGISTERED_PROVIDERS, VUHDO_META_NEW_ARRAY);
local VUHDO_INTERESTED_PROVIDERS = { };
setmetatable(VUHDO_INTERESTED_PROVIDERS, VUHDO_META_NEW_ARRAY);

local VUHDO_INDICATOR_TEXT_PROVIDERS = { };

local sFormatModelCache = { };
local sResolvedProviders = { };
setmetatable(sResolvedProviders, VUHDO_META_NEW_ARRAY);
local sEmpty = { };



--
function VUHDO_textProviderHandlersInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_TEXT_PROVIDER_SOURCES = _G["VUHDO_TEXT_PROVIDER_SOURCES"];
	VUHDO_TEXT_PROVIDER_FORMATS = _G["VUHDO_TEXT_PROVIDER_FORMATS"];
	VUHDO_INDICATOR_CONFIG = _G["VUHDO_INDICATOR_CONFIG"];
	VUHDO_PANEL_MODELS = _G["VUHDO_PANEL_MODELS"];

	VUHDO_tableGetKeyFromValue = _G["VUHDO_tableGetKeyFromValue"];
	VUHDO_getRegisteredBouquets = _G["VUHDO_getRegisteredBouquets"];
	VUHDO_getRegisteredBouquetIndicators = _G["VUHDO_getRegisteredBouquetIndicators"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_isBouquetInterestedInEvent = _G["VUHDO_isBouquetInterestedInEvent"];
	VUHDO_strempty = _G["VUHDO_strempty"];
	VUHDO_getActiveBouquets = _G["VUHDO_getActiveBouquets"];

	return;

end



--
local tSourceKey;
local function VUHDO_isTextProviderInterestedInEvent(aResolved, anEventType)

	if 1 == anEventType then -- VUHDO_UPDATE_ALL
		return true;
	end

	if not aResolved then
		return false;
	end

	tSourceKey = aResolved["sourceKey"];

	if not VUHDO_INTERESTED_PROVIDERS[tSourceKey][anEventType] then
		VUHDO_INTERESTED_PROVIDERS[tSourceKey][anEventType] =
			VUHDO_tableGetKeyFromValue(aResolved["source"]["interests"], anEventType) ~= nil
			and 1 or 0;
	end

	return 1 == VUHDO_INTERESTED_PROVIDERS[tSourceKey][anEventType];

end



--
local tBouquets;
local function VUHDO_isAnyIndicatorBouquetInterestedIn(anIndicatorName, anEventType)

	tBouquets = VUHDO_getRegisteredBouquetIndicators(anIndicatorName);

	if not tBouquets then
		return false;
	end

	for tBouquetName, _ in pairs(tBouquets) do
		if VUHDO_isBouquetInterestedInEvent(tBouquetName, anEventType) then
			return true;
		end
	end

	return false;

end



--
local tBouquets;
local tActiveBouquets;
local tIsInactive;
local function VUHDO_isIndicatorBouquetInactive(aUnit, anIndicatorName)

	if not aUnit then
		return false;
	end

	tBouquets = VUHDO_getRegisteredBouquetIndicators(anIndicatorName);

	if not tBouquets then
		return false;
	end

	tActiveBouquets = ((VUHDO_getActiveBouquets() or sEmpty)[aUnit] or sEmpty);
	tIsInactive = false;

	for tBouquetName, _ in pairs(tBouquets) do
		if tActiveBouquets[tBouquetName] then
			return false;
		end

		tIsInactive = true;
	end

	return tIsInactive;

end



--
local tInfo;
local tIndicators;
local tValue;
local tMaxValue;
local tEmpty = { };
function VUHDO_updateAllTextIndicatorsForEvent(aUnit, anEventType, aBouquetName, anIsActive)

	tInfo = (VUHDO_RAID or tEmpty)[aUnit];

	if tInfo then
		if aBouquetName then
			tIndicators = VUHDO_getRegisteredBouquets()[aBouquetName];

			if tIndicators then
				for tIndicatorName, _ in pairs(tIndicators) do
					if VUHDO_INDICATOR_TEXT_PROVIDERS[tIndicatorName] then
						for tResolved, tFunction in pairs(VUHDO_INDICATOR_TEXT_PROVIDERS[tIndicatorName]) do
							if VUHDO_isTextProviderInterestedInEvent(tResolved, anEventType) then
								if not anIsActive then
									tFunction(aUnit, tResolved, "", tIndicatorName, "%s", "");
								else
									tValue, tMaxValue = tResolved["source"]["calculator"](tInfo);

									tFunction(aUnit, tResolved, tValue, tIndicatorName,
										tResolved["format"]["validator"](tInfo, tValue, tMaxValue));
								end
							end
						end
					end
				end
			end
		else
			for tResolved, tAllIndicators in pairs(VUHDO_REGISTERED_PROVIDERS) do
				if VUHDO_isTextProviderInterestedInEvent(tResolved, anEventType) then
					for tIndicatorName, tFunction in pairs(tAllIndicators) do
						if not VUHDO_isAnyIndicatorBouquetInterestedIn(tIndicatorName, anEventType) then
							if VUHDO_isIndicatorBouquetInactive(aUnit, tIndicatorName) then
								tFunction(aUnit, tResolved, "", tIndicatorName, "%s", "");
							else
								tValue, tMaxValue = tResolved["source"]["calculator"](tInfo);

								tFunction(aUnit, tResolved, tValue, tIndicatorName,
									tResolved["format"]["validator"](tInfo, tValue, tMaxValue));
							end
						end
					end
				end
			end
		end
	elseif aUnit then
		for tResolved, tAllIndicators in pairs(VUHDO_REGISTERED_PROVIDERS) do
			if VUHDO_isTextProviderInterestedInEvent(tResolved, anEventType) then
				for tIndicatorName, tFunction in pairs(tAllIndicators) do
					tFunction(aUnit, tResolved, "", tIndicatorName, "%s", "");
				end
			end
		end
	end

	return;

end
local VUHDO_updateAllTextIndicatorsForEvent = VUHDO_updateAllTextIndicatorsForEvent;



--
function VUHDO_isAnyTextIndicatorInterestedIn(anEventType)

	for tResolved, _ in pairs(VUHDO_REGISTERED_PROVIDERS) do
		if VUHDO_isTextProviderInterestedInEvent(tResolved, anEventType) then
			return true;
		end
	end

	return false;

end



--
local function VUHDO_registerIndicatorForProvider(aResolved, anIndicatorName, aFunction)

	VUHDO_REGISTERED_PROVIDERS[aResolved][anIndicatorName] = aFunction;

	if not VUHDO_INDICATOR_TEXT_PROVIDERS[anIndicatorName] then
		VUHDO_INDICATOR_TEXT_PROVIDERS[anIndicatorName] = { };
	end

	VUHDO_INDICATOR_TEXT_PROVIDERS[anIndicatorName][aResolved] = aFunction;

	return;

end



--
local tResolved;
local function VUHDO_getOrCreateResolvedTextProvider(aSourceKey, aFormatKey)

	if VUHDO_strempty(aSourceKey) or VUHDO_strempty(aFormatKey) then
		return nil;
	end

	if not sResolvedProviders[aSourceKey][aFormatKey] then
		sResolvedProviders[aSourceKey][aFormatKey] = {
			["source"] = VUHDO_TEXT_PROVIDER_SOURCES[aSourceKey],
			["format"] = VUHDO_TEXT_PROVIDER_FORMATS[aFormatKey],
			["sourceKey"] = aSourceKey,
			["formatKey"] = aFormatKey,
		};
	end

	return sResolvedProviders[aSourceKey][aFormatKey];

end



--
local function VUHDO_registerIndicatorForProviderUnique(aSourceKey, aFormatKey, anIndicatorName, aFunction, anAlreadyRegistered)

	if not anAlreadyRegistered then
		return;
	end

	tResolved = VUHDO_getOrCreateResolvedTextProvider(aSourceKey, aFormatKey);

	if tResolved and not VUHDO_strempty(anIndicatorName)
		and not (anAlreadyRegistered[tResolved] and anAlreadyRegistered[tResolved][anIndicatorName]) then

		if not anAlreadyRegistered[tResolved] then
			anAlreadyRegistered[tResolved] = { };
		end

		VUHDO_registerIndicatorForProvider(tResolved, anIndicatorName, aFunction);

		anAlreadyRegistered[tResolved][anIndicatorName] = true;
	end

	return;

end



--
local function VUHDO_initTextProviderSourceComboModel()

	twipe(VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL);

	for tName, tInfo in pairs(VUHDO_TEXT_PROVIDER_SOURCES) do
		tinsert(VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL, { tName, tInfo["displayName"] });
	end

	sort(VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL,
		function(anEntry, anotherEntry)
			return anEntry[2] < anotherEntry[2];
		end
	);

	tinsert(VUHDO_TEXT_PROVIDER_SOURCE_COMBO_MODEL, 1, { "", "- empty / nothing -" });

	return;

end



--
local tFormatCnt;
local tFormatKey;
local tFormatInfo;
function VUHDO_getFormatComboModelForSource(aSourceKey)

	if not sFormatModelCache[aSourceKey] then
		sFormatModelCache[aSourceKey] = { };

		tinsert(sFormatModelCache[aSourceKey], { "", "- empty / nothing -" });

		if aSourceKey ~= "" and VUHDO_TEXT_PROVIDER_SOURCES[aSourceKey] then
			for tFormatCnt = 1, #VUHDO_TEXT_PROVIDER_SOURCES[aSourceKey]["supportedFormats"] do
				tFormatKey = VUHDO_TEXT_PROVIDER_SOURCES[aSourceKey]["supportedFormats"][tFormatCnt];
				tFormatInfo = VUHDO_TEXT_PROVIDER_FORMATS[tFormatKey];

				tinsert(sFormatModelCache[aSourceKey], { tFormatKey, tFormatInfo["displayName"] });
			end
		end
	end

	return sFormatModelCache[aSourceKey];

end



--
local VUHDO_TEXT_INDICATOR_CALLBACKS = {
	["OVERHEAL_TEXT"] = "VUHDO_overhealTextCallback",
	["MANA_BAR"] = "VUHDO_manaBarTextCallback",
	["SIDE_LEFT"] = "VUHDO_sideLeftTextCallback",
	["SIDE_RIGHT"] = "VUHDO_sideRightTextCallback",
	["THREAT_BAR"] = "VUHDO_threatBarTextCallback",
};



--
local tAlreadyRegistered = { };
local tSourceKey;
local tFormatKey;
function VUHDO_registerAllTextIndicators()

	twipe(VUHDO_REGISTERED_PROVIDERS);
	twipe(VUHDO_INTERESTED_PROVIDERS);
	twipe(VUHDO_INDICATOR_TEXT_PROVIDERS);
	twipe(sFormatModelCache);
	twipe(sResolvedProviders);

	twipe(tAlreadyRegistered);

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		if VUHDO_PANEL_MODELS[tPanelNum] then
			for tIndicatorName, tIndicatorConfig in pairs(VUHDO_INDICATOR_CONFIG[tPanelNum]["TEXT_INDICATORS"]) do
				tSourceKey = tIndicatorConfig["TEXT_PROVIDER_SOURCE"] or "";
				tFormatKey = tIndicatorConfig["TEXT_PROVIDER_FORMAT"] or "";

				VUHDO_registerIndicatorForProviderUnique(tSourceKey, tFormatKey, tIndicatorName,
					_G[VUHDO_TEXT_INDICATOR_CALLBACKS[tIndicatorName]], tAlreadyRegistered);
			end
		end
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateBouquetsForEvent(tUnit, 1); -- VUHDO_UPDATE_ALL
	end

	VUHDO_initTextProviderSourceComboModel();

	return;

end



--
function VUHDO_getResolvedTextProvider(aSourceKey, aFormatKey)

	if VUHDO_strempty(aSourceKey) or VUHDO_strempty(aFormatKey) then
		return nil;
	end

	return (sResolvedProviders[aSourceKey] or sEmpty)[aFormatKey];

end



--
function VUHDO_getRegisteredTextProviders()

	return VUHDO_REGISTERED_PROVIDERS;

end
