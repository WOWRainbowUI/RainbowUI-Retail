local _;

local table = table;
local floor = floor;
local select = select;
local twipe = table.wipe;
local tinsert = table.insert;
local tsort = table.sort;
local ipairs = ipairs;
local pairs = pairs;
local type = type;

local CreateColorCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve;
local UnitHealthPercent = UnitHealthPercent;
local UnitPowerPercent = UnitPowerPercent;
local CreateColor = CreateColor;
local issecretvalue = issecretvalue;
local ShouldUnitAuraInstanceBeSecret = C_Secrets and C_Secrets.ShouldUnitAuraInstanceBeSecret;

local VUHDO_copyColorTo;
local VUHDO_getDispelAbilities;
local VUHDO_getPurgeAbilities;
local VUHDO_isConfigDemoUsers;
local VUHDO_displayAurasAtAnchorFromCache;
local VUHDO_getSlotData;
local VUHDO_getAuraGroupRaw;
local VUHDO_getAuraBarColorType;
local VUHDO_getAuraTextColorType;

local VUHDO_BOUQUETS = { };
local VUHDO_RAID = { };
local VUHDO_CONFIG = { };
local VUHDO_BOUQUET_BUFFS_SPECIAL = { };
local VUHDO_CUSTOM_ICONS;
local VUHDO_USER_CLASS_COLORS;
local VUHDO_POWER_TYPE_COLORS;
local VUHDO_PANEL_SETUP;
local VUHDO_AURA_LIST_BOUQUETS;
local VUHDO_UNIT_AURA_LIST_SLOTS;
local VUHDO_MAX_PANELS;
local VUHDO_AURA_GROUP_TYPE_LIST;
local VUHDO_AURA_LIST_ENTRY_BOUQUET;
local VUHDO_DEFAULT_AURA_GROUPS;
local VUHDO_AURA_GROUP_COLOR_OFF;
local VUHDO_AURA_GROUP_COLOR_DISPEL;
local VUHDO_PLAYER_CLASS;

local VUHDO_BOUQUET_LAYER_TYPE_NONSECRET;
local VUHDO_BOUQUET_LAYER_TYPE_CURVE;
local VUHDO_BOUQUET_LAYER_TYPE_DISPEL;
local VUHDO_BOUQUET_LAYER_TYPE_AURA;
local VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL;
local VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR;

local VUHDO_LAST_EVALUATED_BOUQUETS = { };
setmetatable(VUHDO_LAST_EVALUATED_BOUQUETS, VUHDO_META_NEW_ARRAY);
local VUHDO_REGISTERED_BOUQUETS = { };
setmetatable(VUHDO_REGISTERED_BOUQUETS, VUHDO_META_NEW_ARRAY);
local VUHDO_ACTIVE_BOUQUETS = { };
setmetatable(VUHDO_ACTIVE_BOUQUETS, VUHDO_META_NEW_ARRAY);

local VUHDO_REGISTERED_BOUQUET_INDICATORS = { };
local VUHDO_CYCLIC_BOUQUETS = { };

VUHDO_UNIT_AURA_BOUQUET_ACTIVE = { };
VUHDO_LIST_GROUP_COLOR_BOUQUETS = { };

local VUHDO_CUSTOM_BOUQUETS = {
	VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH,
};

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;

local sDebuffTypeCurves;
local sPlayerArray = { };
local sDurationCurves = { };
local sBouquetLayerTemplates = { };
local sBouquetCurves = { };
local sBouquetColors = { };
local sCurveCache = { };
local sBrightnessCurveCache = { };
local sTextBrightnessCurveCache = { };
local sThresholds = { };

local sBouquetStatePool;
local sThresholdEntryPool;
local sUnitBouquetActivePool;
local sValidatorEntryPool;

local sGroupsWithEnabledAnchorReusable = { };

local sDispelTypeCurve;
local sDispelTypeTextCurve;
local sDebuffDurationCurve;
local sMagicDispelCurve;
local sDiseaseDispelCurve;
local sPoisonDispelCurve;
local sCurseDispelCurve;
local sBleedDispelCurve;
local sEnrageDispelCurve;
local sFriendlyDispelCurve;
local sHostilePurgeCurve;

local sTransparentColor;
local sWhiteColor;

local VUHDO_BLIZZARD_DISPEL_TYPE_MAP = {
	[1] = 4,
	[2] = 3,
	[3] = 1,
	[4] = 2,
	[9] = 9,
};

local VUHDO_DISPEL_TYPE_COLOR_KEY_MAP = {
	[1] = "DEBUFF1",
	[2] = "DEBUFF2",
	[3] = "DEBUFF3",
	[4] = "DEBUFF4",
	[9] = "DEBUFF9",
};



--
function VUHDO_bouquetsInitLocalOverrides()

	VUHDO_BOUQUETS = _G["VUHDO_BOUQUETS"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_CUSTOM_ICONS = _G["VUHDO_CUSTOM_ICONS"];
	VUHDO_BOUQUET_BUFFS_SPECIAL = _G["VUHDO_BOUQUET_BUFFS_SPECIAL"];

	VUHDO_USER_CLASS_COLORS = _G["VUHDO_USER_CLASS_COLORS"];
	VUHDO_POWER_TYPE_COLORS = _G["VUHDO_POWER_TYPE_COLORS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_AURA_LIST_BOUQUETS = _G["VUHDO_AURA_LIST_BOUQUETS"];
	VUHDO_UNIT_AURA_LIST_SLOTS = _G["VUHDO_UNIT_AURA_LIST_SLOTS"];
	VUHDO_MAX_PANELS = _G["VUHDO_MAX_PANELS"];
	VUHDO_AURA_GROUP_TYPE_LIST = _G["VUHDO_AURA_GROUP_TYPE_LIST"];
	VUHDO_AURA_LIST_ENTRY_BOUQUET = _G["VUHDO_AURA_LIST_ENTRY_BOUQUET"];
	VUHDO_DEFAULT_AURA_GROUPS = _G["VUHDO_DEFAULT_AURA_GROUPS"];
	VUHDO_AURA_GROUP_COLOR_OFF = _G["VUHDO_AURA_GROUP_COLOR_OFF"];
	VUHDO_AURA_GROUP_COLOR_DISPEL = _G["VUHDO_AURA_GROUP_COLOR_DISPEL"];
	VUHDO_PLAYER_CLASS = _G["VUHDO_PLAYER_CLASS"];

	VUHDO_BOUQUET_LAYER_TYPE_NONSECRET = _G["VUHDO_BOUQUET_LAYER_TYPE_NONSECRET"];
	VUHDO_BOUQUET_LAYER_TYPE_CURVE = _G["VUHDO_BOUQUET_LAYER_TYPE_CURVE"];
	VUHDO_BOUQUET_LAYER_TYPE_DISPEL = _G["VUHDO_BOUQUET_LAYER_TYPE_DISPEL"];
	VUHDO_BOUQUET_LAYER_TYPE_AURA = _G["VUHDO_BOUQUET_LAYER_TYPE_AURA"];
	VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL = _G["VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL"];
	VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR = _G["VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR"];

	VUHDO_rebuildAllAlphaChains = _G["VUHDO_rebuildAllAlphaChains"];
	VUHDO_getChosenDebuffAuraInstanceId = _G["VUHDO_getChosenDebuffAuraInstanceId"];
	VUHDO_copyColorTo = _G["VUHDO_copyColorTo"];
	VUHDO_getDispelAbilities = _G["VUHDO_getDispelAbilities"];
	VUHDO_getPurgeAbilities = _G["VUHDO_getPurgeAbilities"];
	VUHDO_isConfigDemoUsers = _G["VUHDO_isConfigDemoUsers"];
	VUHDO_getAuraGroupRaw = _G["VUHDO_getAuraGroupRaw"];
	VUHDO_displayAurasAtAnchorFromCache = _G["VUHDO_displayAurasAtAnchorFromCache"];
	VUHDO_getSlotData = _G["VUHDO_getSlotData"];
	VUHDO_getAuraBarColorType = _G["VUHDO_getAuraBarColorType"];
	VUHDO_getAuraTextColorType = _G["VUHDO_getAuraTextColorType"];

	sBouquetStatePool = VUHDO_createTablePool("BouquetState", 500);
	sThresholdEntryPool = VUHDO_createTablePool("ThresholdEntry", 100);
	sValidatorEntryPool = VUHDO_createTablePool("ValidatorEntry", 200);
	sUnitBouquetActivePool = VUHDO_createTablePool("UnitBouquetActive", 50);

	sPlayerArray["player"] = VUHDO_RAID["player"];

	return;

end



--
function VUHDO_initSecretColorConstants()

	sTransparentColor = CreateColor(0, 0, 0, 0);
	sWhiteColor = CreateColor(1, 1, 1, 1);

	return;

end



--
function VUHDO_safeColorFromTable(aColorTable, aFallback)

	if aColorTable and aColorTable["R"] and aColorTable["G"] and aColorTable["B"] then
		return CreateColor(aColorTable["R"], aColorTable["G"], aColorTable["B"], aColorTable["O"] or 1);
	end

	return aFallback or sTransparentColor;

end



--
function VUHDO_safeTextColorFromTable(aColorTable, aFallback)

	if aColorTable and aColorTable["TR"] and aColorTable["TG"] and aColorTable["TB"] then
		return CreateColor(aColorTable["TR"], aColorTable["TG"], aColorTable["TB"], aColorTable["TO"] or 1);
	end

	return aFallback or sTransparentColor;

end



do
	--
	local tBrightCacheKey;
	local tColors;
	local tTransparent;
	local tNewCurve;
	local tTypeColor;
	local tR;
	local tG;
	local tB;
	local tO;
	function VUHDO_getOrBuildBrightnessCurve(aBaseCurve, aBrightness, aCurveType)

		if not aBrightness or aBrightness >= 1 then
			return aBaseCurve;
		end

		tBrightCacheKey = aCurveType .. "_" .. tostring(aBrightness);

		if sBrightnessCurveCache[tBrightCacheKey] then
			return sBrightnessCurveCache[tBrightCacheKey];
		end

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];
		tTransparent = CreateColor(0, 0, 0, 0);

		tNewCurve = CreateColorCurve();
		tNewCurve:SetType(Enum.LuaCurveType.Step);
		tNewCurve:AddPoint(0, tTransparent);

		if tColors then
			tTypeColor = tColors["DEBUFF0"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;

				tNewCurve:AddPoint(0, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF3"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;

				tNewCurve:AddPoint(1, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF4"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;

				tNewCurve:AddPoint(2, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF2"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;

				tNewCurve:AddPoint(3, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF1"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;

				tNewCurve:AddPoint(4, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF6"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;

				tNewCurve:AddPoint(6, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF8"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;

				tNewCurve:AddPoint(8, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF9"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;

				tNewCurve:AddPoint(9, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF8"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["R"] or 0) * aBrightness, (tTypeColor["G"] or 0) * aBrightness, (tTypeColor["B"] or 0) * aBrightness, tTypeColor["O"] or 1;

				tNewCurve:AddPoint(11, CreateColor(tR, tG, tB, tO));
			end
		end

		sBrightnessCurveCache[tBrightCacheKey] = tNewCurve;

		return tNewCurve;

	end
end



do
	--
	local tBrightCacheKey;
	local tColors;
	local tTransparent;
	local tNewCurve;
	local tTypeColor;
	local tR;
	local tG;
	local tB;
	local tO;
	function VUHDO_getOrBuildTextBrightnessCurve(aBaseCurve, aBrightness, aCurveType)

		if not aBrightness or aBrightness >= 1 then
			return aBaseCurve;
		end

		tBrightCacheKey = "text_" .. aCurveType .. "_" .. tostring(aBrightness);

		if sTextBrightnessCurveCache[tBrightCacheKey] then
			return sTextBrightnessCurveCache[tBrightCacheKey];
		end

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];
		tTransparent = CreateColor(0, 0, 0, 0);

		tNewCurve = CreateColorCurve();
		tNewCurve:SetType(Enum.LuaCurveType.Step);
		tNewCurve:AddPoint(0, tTransparent);

		if tColors then
			tTypeColor = tColors["DEBUFF0"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;

				tNewCurve:AddPoint(0, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF3"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;

				tNewCurve:AddPoint(1, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF4"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;

				tNewCurve:AddPoint(2, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF2"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;

				tNewCurve:AddPoint(3, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF1"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;

				tNewCurve:AddPoint(4, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF6"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;

				tNewCurve:AddPoint(6, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF8"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;

				tNewCurve:AddPoint(8, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF9"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;

				tNewCurve:AddPoint(9, CreateColor(tR, tG, tB, tO));
			end

			tTypeColor = tColors["DEBUFF8"];

			if tTypeColor then
				tR, tG, tB, tO = (tTypeColor["TR"] or 0) * aBrightness, (tTypeColor["TG"] or 0) * aBrightness, (tTypeColor["TB"] or 0) * aBrightness, tTypeColor["TO"] or 1;

				tNewCurve:AddPoint(11, CreateColor(tR, tG, tB, tO));
			end
		end

		sTextBrightnessCurveCache[tBrightCacheKey] = tNewCurve;

		return tNewCurve;

	end
end



--
local tBouquetCurves;
function VUHDO_getBouquetCurve(aBouquetName, aCurveType)

	tBouquetCurves = sBouquetCurves[aBouquetName];

	if tBouquetCurves then
		return tBouquetCurves[aCurveType];
	end

	return nil;

end



--
local tBouquetColors;
function VUHDO_getBouquetBoolColor(aBouquetName, aValidatorName)

	tBouquetColors = sBouquetColors[aBouquetName];

	if tBouquetColors then
		return tBouquetColors[aValidatorName];
	end

	return nil;

end



--
local tCacheKey;
function VUHDO_getHealthCurve(aBouquetName, aClassId)

	tCacheKey = aBouquetName .. "_" .. (aClassId or 0);

	return sCurveCache[tCacheKey] or sCurveCache[aBouquetName .. "_0"];

end



--
function VUHDO_getDispelTypeCurve()

	return sDispelTypeCurve;

end



--
function VUHDO_getDispelTypeTextCurve()

	return sDispelTypeTextCurve;

end



--
function VUHDO_getDebuffDurationCurve()

	return sDebuffDurationCurve;

end



--
function VUHDO_clearCurveCache()

	twipe(sCurveCache);
	twipe(sBouquetCurves);
	twipe(sBouquetColors);
	twipe(sTextBrightnessCurveCache);

	return;

end



do
	--
	local tCurve;
	local tRadio;
	local tBaseColor;
	local tLowColor;
	local tMedColor;
	local tHighColor;
	local tClassColor;
	local tThresholdFraction;
	local tBaseColorMixin;
	local tLowColorMixin;
	local tMedColorMixin;
	local tHighColorMixin;
	local tCurrentX;
	local tThresholdColorMixin;
	local tItem;
	local tName;
	local tEntry;
	local tHealthBright;
	function VUHDO_buildCompositeHealthCurve(aBouquet, anInfo)

		twipe(sThresholds);

		tRadio = 3;
		tBaseColor, tLowColor, tMedColor, tHighColor = nil, nil, nil, nil;
		tHealthBright = 1;

		if not VUHDO_USER_CLASS_COLORS or not VUHDO_USER_CLASS_GRADIENT_COLORS then
			VUHDO_initClassColors();
		end

		for tCnt = 1, #aBouquet do
			tItem = aBouquet[tCnt];
			tName = tItem["name"];

			if tName == "STATUS_HEALTH" then
				tRadio = tItem["custom"]["radio"] or 3;
				tHealthBright = tItem["custom"]["bright"] or 1;

				if tRadio == 1 then
					tBaseColor = tItem["color"];
				elseif tRadio == 2 then
					if tItem["custom"]["isClassGradient"] and VUHDO_USER_CLASS_GRADIENT_COLORS and VUHDO_USER_CLASS_GRADIENT_COLORS[anInfo["classId"]] then
						tClassColor = VUHDO_USER_CLASS_GRADIENT_COLORS[anInfo["classId"]]["min"];
						tBaseColor = tClassColor or tItem["color"];
					else
						tClassColor = VUHDO_USER_CLASS_COLORS and VUHDO_USER_CLASS_COLORS[anInfo["classId"]];
						tBaseColor = tClassColor or tItem["color"];
					end
				else
					tHighColor = tItem["color"];
					tMedColor = tItem["custom"]["grad_med"];
					tLowColor = tItem["custom"]["grad_low"];
				end
			elseif tName == "HEALTH_BELOW" then
				tEntry = sThresholdEntryPool:get();

				tEntry["type"] = "below";
				tEntry["percent"] = tItem["custom"][1];
				tEntry["color"] = tItem["color"];

				tinsert(sThresholds, tEntry);
			elseif tName == "HEALTH_ABOVE" then
				tEntry = sThresholdEntryPool:get();

				tEntry["type"] = "above";
				tEntry["percent"] = tItem["custom"][1];
				tEntry["color"] = tItem["color"];

				tinsert(sThresholds, tEntry);
			end
		end

		tsort(sThresholds, function(a, b) return a["percent"] < b["percent"]; end);

		tCurve = CreateColorCurve();
		tCurve:SetType(Enum.LuaCurveType.Linear);

		tBaseColorMixin = nil;

		if tBaseColor then
			if 2 == tRadio then
				tBaseColorMixin = CreateColor(
					tBaseColor["R"] * tHealthBright, tBaseColor["G"] * tHealthBright, tBaseColor["B"] * tHealthBright, tBaseColor["O"] or 1);
			else
				tBaseColorMixin = CreateColor(
					tBaseColor["R"], tBaseColor["G"], tBaseColor["B"], tBaseColor["O"] or 1);
			end
		end

		tLowColorMixin, tMedColorMixin, tHighColorMixin = nil, nil, nil;

		if tLowColor and tMedColor and tHighColor then
			tLowColorMixin = CreateColor(tLowColor["R"], tLowColor["G"], tLowColor["B"], tLowColor["O"] or 1);
			tMedColorMixin = CreateColor(tMedColor["R"], tMedColor["G"], tMedColor["B"], tMedColor["O"] or 1);
			tHighColorMixin = CreateColor(tHighColor["R"], tHighColor["G"], tHighColor["B"], tHighColor["O"] or 1);
		end

		if #sThresholds == 0 then
			if tRadio == 3 and tLowColorMixin then
				tCurve:AddPoint(0.00, tLowColorMixin);
				tCurve:AddPoint(0.25, tLowColorMixin);
				tCurve:AddPoint(0.50, tMedColorMixin);
				tCurve:AddPoint(0.70, tMedColorMixin);
				tCurve:AddPoint(0.85, tHighColorMixin);
				tCurve:AddPoint(1.00, tHighColorMixin);
			elseif tBaseColorMixin then
				tCurve:AddPoint(0.00, tBaseColorMixin);
				tCurve:AddPoint(1.00, tBaseColorMixin);
			else
				tCurve:AddPoint(0.00, sWhiteColor);
				tCurve:AddPoint(1.00, sWhiteColor);
			end

			return tCurve;
		end

		tCurrentX = 0;

		for _, tThreshold in ipairs(sThresholds) do
			tThresholdFraction = tThreshold["percent"] / 100;

			tThresholdColorMixin = CreateColor(
				tThreshold["color"]["R"], tThreshold["color"]["G"],
				tThreshold["color"]["B"], tThreshold["color"]["O"] or 1
			);

			if tThreshold["type"] == "below" then
				tCurve:AddPoint(tCurrentX, tThresholdColorMixin);
				tCurve:AddPoint(tThresholdFraction - 0.005, tThresholdColorMixin);

				tCurrentX = tThresholdFraction;

			elseif tThreshold["type"] == "above" then
				if tCurrentX < tThresholdFraction then
					if tRadio == 3 and tLowColorMixin then
						VUHDO_addGradientPointsToRange(tCurve, tCurrentX, tThresholdFraction,
							tLowColorMixin, tMedColorMixin, tHighColorMixin);
					elseif tBaseColorMixin then
						tCurve:AddPoint(tCurrentX, tBaseColorMixin);
						tCurve:AddPoint(tThresholdFraction - 0.005, tBaseColorMixin);
					end
				end

				tCurve:AddPoint(tThresholdFraction, tThresholdColorMixin);
				tCurve:AddPoint(1.00, tThresholdColorMixin);

				tCurrentX = 1.00;
			end
		end

		if tCurrentX < 1.00 then
			if tRadio == 3 and tLowColorMixin then
				VUHDO_addGradientPointsToRange(tCurve, tCurrentX, 1.00,
					tLowColorMixin, tMedColorMixin, tHighColorMixin);
			elseif tBaseColorMixin then
				tCurve:AddPoint(tCurrentX, tBaseColorMixin);
				tCurve:AddPoint(1.00, tBaseColorMixin);
			end
		end

		for tIdx = 1, #sThresholds do
			sThresholdEntryPool:release(sThresholds[tIdx]);
		end

		twipe(sThresholds);

		return tCurve;

	end
end



do
	--
	local tModi;
	local tInvModi;
	local tR;
	local tG;
	local tB;
	local tRange;
	local tX;
	local tColorMixin;
	function VUHDO_addGradientPointsToRange(aCurve, aStartX, aEndX, aLowColor, aMedColor, aHighColor)

		tRange = aEndX - aStartX;

		for tStep = 0, 6 do
			tX = aStartX + (tStep / 6) * tRange;
			tModi = (tX ^ 1.7) * 2;

			if tModi > 1 then
				tModi = tModi - 1;

				if tModi > 1 then
					tModi = 1;
				end

				tInvModi = 1 - tModi;

				tR = aMedColor:GetRed() * tInvModi + aHighColor:GetRed() * tModi;
				tG = aMedColor:GetGreen() * tInvModi + aHighColor:GetGreen() * tModi;
				tB = aMedColor:GetBlue() * tInvModi + aHighColor:GetBlue() * tModi;
			else
				tInvModi = 1 - tModi;

				tR = aLowColor:GetRed() * tInvModi + aMedColor:GetRed() * tModi;
				tG = aLowColor:GetGreen() * tInvModi + aMedColor:GetGreen() * tModi;
				tB = aLowColor:GetBlue() * tInvModi + aMedColor:GetBlue() * tModi;
			end

			tColorMixin = CreateColor(tR, tG, tB, 1);
			aCurve:AddPoint(tX, tColorMixin);
		end

		return;

	end
end



do
	--
	local VUHDO_ALL_CLASS_IDS = { 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 40 };
	local tMockInfo;
	local tItem;
	local tRadio;
	local tCacheKey;
	function VUHDO_prebuildHealthCurvesForBouquet(aBouquetName, aBouquet)

		for tCnt = 1, #aBouquet do
			tItem = aBouquet[tCnt];

			if tItem["name"] == "STATUS_HEALTH" then
				tRadio = tItem["custom"]["radio"] or 3;

				if tRadio == 2 then
					for _, tClassId in ipairs(VUHDO_ALL_CLASS_IDS) do
						tMockInfo = { ["classId"] = tClassId };

						tCacheKey = aBouquetName .. "_" .. tClassId;
						sCurveCache[tCacheKey] = VUHDO_buildCompositeHealthCurve(aBouquet, tMockInfo);
					end
				else
					tMockInfo = { ["classId"] = 0 };

					tCacheKey = aBouquetName .. "_0";
					sCurveCache[tCacheKey] = VUHDO_buildCompositeHealthCurve(aBouquet, tMockInfo);
				end

				return;
			end
		end

		return;

	end
end



do
	--
	local tPowerCurve;
	local tThreshold;
	local tPowerBaseColor;
	local tWarningColor;
	local tPowerBaseColorMixin;
	local tItem;
	function VUHDO_buildCompositePowerCurve(aBouquet, aPowerType)

		tPowerCurve = CreateColorCurve();
		tPowerCurve:SetType(Enum.LuaCurveType.Linear);

		tThreshold = nil;
		tPowerBaseColor = VUHDO_POWER_TYPE_COLORS and VUHDO_POWER_TYPE_COLORS[aPowerType];

		if not tPowerBaseColor then
			tPowerBaseColor = { ["R"] = 0, ["G"] = 0.5, ["B"] = 1 };
		end

		for tCnt = 1, #aBouquet do
			tItem = aBouquet[tCnt];

			if tItem["name"] == "MANA_BELOW" then
				tThreshold = tItem["custom"][1];

				tWarningColor = CreateColor(
					tItem["color"]["R"], tItem["color"]["G"], tItem["color"]["B"], 1);

				tPowerCurve:AddPoint(0.00, tWarningColor);
				tPowerCurve:AddPoint(tThreshold / 100 - 0.005, tWarningColor);
			end
		end

		tPowerBaseColorMixin = CreateColor(
			tPowerBaseColor["R"], tPowerBaseColor["G"], tPowerBaseColor["B"], 1);

		if tThreshold then
			tPowerCurve:AddPoint(tThreshold / 100, tPowerBaseColorMixin);
		else
			tPowerCurve:AddPoint(0.00, tPowerBaseColorMixin);
		end

		tPowerCurve:AddPoint(1.00, tPowerBaseColorMixin);

		return tPowerCurve;

	end
end



do
	--
	local tColors;
	local tDefaultColor;
	function VUHDO_buildDispelTypeCurve()

		sDispelTypeCurve = CreateColorCurve();
		sDispelTypeCurve:SetType(Enum.LuaCurveType.Step);

		sDispelTypeTextCurve = CreateColorCurve();
		sDispelTypeTextCurve:SetType(Enum.LuaCurveType.Step);

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];
		tDefaultColor = CreateColor(0.5, 0.5, 0.5, 1);

		if not tColors then
			sDispelTypeCurve:AddPoint(0, tDefaultColor);
			sDispelTypeTextCurve:AddPoint(0, tDefaultColor);

			return;
		end

		sDispelTypeCurve:AddPoint(0, VUHDO_safeColorFromTable(tColors["DEBUFF0"], tDefaultColor));
		sDispelTypeCurve:AddPoint(1, VUHDO_safeColorFromTable(tColors["DEBUFF3"], tDefaultColor));
		sDispelTypeCurve:AddPoint(2, VUHDO_safeColorFromTable(tColors["DEBUFF4"], tDefaultColor));
		sDispelTypeCurve:AddPoint(3, VUHDO_safeColorFromTable(tColors["DEBUFF2"], tDefaultColor));
		sDispelTypeCurve:AddPoint(4, VUHDO_safeColorFromTable(tColors["DEBUFF1"], tDefaultColor));
		sDispelTypeCurve:AddPoint(6, VUHDO_safeColorFromTable(tColors["DEBUFF6"], tDefaultColor));
		sDispelTypeCurve:AddPoint(8, VUHDO_safeColorFromTable(tColors["DEBUFF8"], tDefaultColor));
		sDispelTypeCurve:AddPoint(9, VUHDO_safeColorFromTable(tColors["DEBUFF9"], tDefaultColor));
		sDispelTypeCurve:AddPoint(11, VUHDO_safeColorFromTable(tColors["DEBUFF8"], tDefaultColor));

		sDispelTypeTextCurve:AddPoint(0, VUHDO_safeTextColorFromTable(tColors["DEBUFF0"], tDefaultColor));
		sDispelTypeTextCurve:AddPoint(1, VUHDO_safeTextColorFromTable(tColors["DEBUFF3"], tDefaultColor));
		sDispelTypeTextCurve:AddPoint(2, VUHDO_safeTextColorFromTable(tColors["DEBUFF4"], tDefaultColor));
		sDispelTypeTextCurve:AddPoint(3, VUHDO_safeTextColorFromTable(tColors["DEBUFF2"], tDefaultColor));
		sDispelTypeTextCurve:AddPoint(4, VUHDO_safeTextColorFromTable(tColors["DEBUFF1"], tDefaultColor));
		sDispelTypeTextCurve:AddPoint(6, VUHDO_safeTextColorFromTable(tColors["DEBUFF6"], tDefaultColor));
		sDispelTypeTextCurve:AddPoint(8, VUHDO_safeTextColorFromTable(tColors["DEBUFF8"], tDefaultColor));
		sDispelTypeTextCurve:AddPoint(9, VUHDO_safeTextColorFromTable(tColors["DEBUFF9"], tDefaultColor));
		sDispelTypeTextCurve:AddPoint(11, VUHDO_safeTextColorFromTable(tColors["DEBUFF8"], tDefaultColor));

		return;

	end
end



do
	--
	local tColors;
	local tTransparent;
	local tDispelAbilities;
	local tPurgeAbilities;
	local tBlizzType;
	local tColorKey;
	function VUHDO_buildSingleDispelTypeCurves()

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

		tTransparent = CreateColor(0, 0, 0, 0);

		sMagicDispelCurve = CreateColorCurve();
		sMagicDispelCurve:SetType(Enum.LuaCurveType.Step);
		sMagicDispelCurve:AddPoint(0, tTransparent);
		sMagicDispelCurve:AddPoint(1, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF3"], tTransparent));

		sDiseaseDispelCurve = CreateColorCurve();
		sDiseaseDispelCurve:SetType(Enum.LuaCurveType.Step);
		sDiseaseDispelCurve:AddPoint(0, tTransparent);
		sDiseaseDispelCurve:AddPoint(3, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF2"], tTransparent));

		sPoisonDispelCurve = CreateColorCurve();
		sPoisonDispelCurve:SetType(Enum.LuaCurveType.Step);
		sPoisonDispelCurve:AddPoint(0, tTransparent);
		sPoisonDispelCurve:AddPoint(4, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF1"], tTransparent));

		sCurseDispelCurve = CreateColorCurve();
		sCurseDispelCurve:SetType(Enum.LuaCurveType.Step);
		sCurseDispelCurve:AddPoint(0, tTransparent);
		sCurseDispelCurve:AddPoint(2, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF4"], tTransparent));

		sBleedDispelCurve = CreateColorCurve();
		sBleedDispelCurve:SetType(Enum.LuaCurveType.Step);
		sBleedDispelCurve:AddPoint(0, tTransparent);
		sBleedDispelCurve:AddPoint(11, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF8"], tTransparent));

		sEnrageDispelCurve = CreateColorCurve();
		sEnrageDispelCurve:SetType(Enum.LuaCurveType.Step);
		sEnrageDispelCurve:AddPoint(0, tTransparent);
		sEnrageDispelCurve:AddPoint(9, VUHDO_safeColorFromTable(tColors and tColors["DEBUFF9"], tTransparent));

		sDebuffTypeCurves = {
			[VUHDO_DEBUFF_TYPE_MAGIC] = sMagicDispelCurve,
			[VUHDO_DEBUFF_TYPE_DISEASE] = sDiseaseDispelCurve,
			[VUHDO_DEBUFF_TYPE_POISON] = sPoisonDispelCurve,
			[VUHDO_DEBUFF_TYPE_CURSE] = sCurseDispelCurve,
			[VUHDO_DEBUFF_TYPE_BLEED] = sBleedDispelCurve,
			[VUHDO_DEBUFF_TYPE_ENRAGE] = sEnrageDispelCurve,
		};

		tDispelAbilities = VUHDO_getDispelAbilities();

		sFriendlyDispelCurve = CreateColorCurve();
		sFriendlyDispelCurve:SetType(Enum.LuaCurveType.Step);
		sFriendlyDispelCurve:AddPoint(0, tTransparent);

		for tVuhDoType, tAbility in pairs(tDispelAbilities) do
			if tAbility then
				tBlizzType = VUHDO_BLIZZARD_DISPEL_TYPE_MAP[tVuhDoType];
				tColorKey = VUHDO_DISPEL_TYPE_COLOR_KEY_MAP[tVuhDoType];

				if tBlizzType and tColors and tColors[tColorKey] then
					sFriendlyDispelCurve:AddPoint(tBlizzType, VUHDO_safeColorFromTable(tColors[tColorKey], tTransparent));
				end
			end
		end

		tPurgeAbilities = VUHDO_getPurgeAbilities();

		sHostilePurgeCurve = CreateColorCurve();
		sHostilePurgeCurve:SetType(Enum.LuaCurveType.Step);
		sHostilePurgeCurve:AddPoint(0, tTransparent);

		for tVuhDoType, tAbility in pairs(tPurgeAbilities) do
			if tAbility then
				tBlizzType = VUHDO_BLIZZARD_DISPEL_TYPE_MAP[tVuhDoType];
				tColorKey = VUHDO_DISPEL_TYPE_COLOR_KEY_MAP[tVuhDoType];

				if tBlizzType and tColors and tColors[tColorKey] then
					sHostilePurgeCurve:AddPoint(tBlizzType, VUHDO_safeColorFromTable(tColors[tColorKey], tTransparent));
				end
			end
		end

		twipe(sBrightnessCurveCache);
		twipe(sTextBrightnessCurveCache);

		return;

	end
end



--
function VUHDO_getMagicDispelCurve()

	return sMagicDispelCurve;

end



--
function VUHDO_getDiseaseDispelCurve()

	return sDiseaseDispelCurve;

end



--
function VUHDO_getPoisonDispelCurve()

	return sPoisonDispelCurve;

end



--
function VUHDO_getCurseDispelCurve()

	return sCurseDispelCurve;

end



--
function VUHDO_getBleedDispelCurve()

	return sBleedDispelCurve;

end



--
function VUHDO_getEnrageDispelCurve()

	return sEnrageDispelCurve;

end



--
function VUHDO_getFriendlyDispelCurve()

	return sFriendlyDispelCurve;

end



--
function VUHDO_getHostilePurgeCurve()

	return sHostilePurgeCurve;

end



do
	--
	local tInfo;
	local tCanAttack;
	function VUHDO_getDispelCurveForUnit(aUnit, anIsHarmful)

		if not aUnit then
			return nil;
		end

		tInfo = VUHDO_RAID[aUnit];

		if not tInfo then
			return nil;
		end

		tCanAttack = tInfo["canAttack"];

		if not tCanAttack and anIsHarmful then
			return sDispelTypeCurve;
		end

		if tCanAttack and not anIsHarmful then
			return sDispelTypeCurve;
		end

		return nil;

	end
end



do
	--
	local tInfo;
	local tCanAttack;
	function VUHDO_getDispelTextCurveForUnit(aUnit, anIsHarmful)

		if not aUnit then
			return nil;
		end

		tInfo = VUHDO_RAID[aUnit];

		if not tInfo then
			return nil;
		end

		tCanAttack = tInfo["canAttack"];

		if not tCanAttack and anIsHarmful then
			return sDispelTypeTextCurve;
		end

		if tCanAttack and not anIsHarmful then
			return sDispelTypeTextCurve;
		end

		return nil;

	end
end



do
	--
	local tDurationCurve;
	local tDurationColorMixin;
	function VUHDO_buildDurationThresholdCurve(aKey, aThresholdSeconds, aActiveColor, anIsBelow)

		if sDurationCurves[aKey] then
			return sDurationCurves[aKey];
		end

		tDurationCurve = CreateColorCurve();
		tDurationCurve:SetType(Enum.LuaCurveType.Linear);

		tDurationColorMixin = CreateColor(
			aActiveColor["R"], aActiveColor["G"],
			aActiveColor["B"], aActiveColor["O"] or 1);

		if anIsBelow then
			tDurationCurve:AddPoint(0, tDurationColorMixin);
			tDurationCurve:AddPoint(aThresholdSeconds - 0.1, tDurationColorMixin);
			tDurationCurve:AddPoint(aThresholdSeconds, sTransparentColor);
			tDurationCurve:AddPoint(9999, sTransparentColor);
		else
			tDurationCurve:AddPoint(0, sTransparentColor);
			tDurationCurve:AddPoint(aThresholdSeconds - 0.1, sTransparentColor);
			tDurationCurve:AddPoint(aThresholdSeconds, tDurationColorMixin);
			tDurationCurve:AddPoint(9999, tDurationColorMixin);
		end

		sDurationCurves[aKey] = tDurationCurve;

		return tDurationCurve;

	end
end



--
function VUHDO_buildDebuffDurationCurve()

	sDebuffDurationCurve = CreateColorCurve();
	sDebuffDurationCurve:SetType(Enum.LuaCurveType.Linear);

	sDebuffDurationCurve:AddPoint(0, CreateColor(1, 0, 0, 1));
	sDebuffDurationCurve:AddPoint(3, CreateColor(1, 0.5, 0, 1));

	sDebuffDurationCurve:AddPoint(10, CreateColor(1, 1, 0, 1));

	sDebuffDurationCurve:AddPoint(30, CreateColor(1, 1, 1, 1));

	return;

end



do
	--
	local tBouquet;
	local tSpecial;
	local tHasHealthValidator;
	local tHasPowerValidator;
	local tItem;
	local tName;
	function VUHDO_buildCurvesForBouquet(aBouquetName)

		tBouquet = VUHDO_BOUQUETS["STORED"][aBouquetName];

		if not tBouquet or type(tBouquet) ~= "table" then
			return;
		end

		sBouquetCurves[aBouquetName] = { };
		sBouquetColors[aBouquetName] = { };

		tHasHealthValidator = false;
		tHasPowerValidator = false;

		for tCnt = 1, #tBouquet do
			tItem = tBouquet[tCnt];
			tName = tItem["name"];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tName];

			if tSpecial then
				if tSpecial["secretType"] == VUHDO_SECRET_TYPE_BOOLEAN then
					sBouquetColors[aBouquetName][tName] = CreateColor(
						tItem["color"]["R"], tItem["color"]["G"],
						tItem["color"]["B"], tItem["color"]["O"] or 1);
				elseif tSpecial["secretType"] == VUHDO_SECRET_TYPE_HEALTH_PERCENT then
					tHasHealthValidator = true;
				elseif tSpecial["secretType"] == VUHDO_SECRET_TYPE_POWER_PERCENT then
					tHasPowerValidator = true;
				end
			end
		end

		if tHasPowerValidator then
			sBouquetCurves[aBouquetName]["power"] = { };

			for tPowerType = 0, 19 do
				if VUHDO_POWER_TYPE_COLORS and VUHDO_POWER_TYPE_COLORS[tPowerType] then
					sBouquetCurves[aBouquetName]["power"][tPowerType] = VUHDO_buildCompositePowerCurve(tBouquet, tPowerType);
				end
			end
		end

		if tHasHealthValidator then
			VUHDO_prebuildHealthCurvesForBouquet(aBouquetName, tBouquet);
		end

		VUHDO_buildBouquetLayerTemplate(aBouquetName);

		return;

	end



	--
	function VUHDO_buildAllBouquetCurves()

		if not VUHDO_BOUQUETS or not VUHDO_BOUQUETS["STORED"] then
			return;
		end

		VUHDO_buildDispelTypeCurve();
		VUHDO_buildSingleDispelTypeCurves();
		VUHDO_buildDebuffDurationCurve();

		return;

	end
end



do
	--
	local tItem;
	local tSpecial;
	local tSecretType;
	local tTemplate;
	local tCurveIdx;
	local tBoolIdx;
	local tDispelIdx;
	local tSpriteCellIdx;
	local tAlphaIdx;
	local tNonSecretIdx;
	local tAuraIdx;
	local tTrueColor;
	local tBouquet;
	local tAllValidators;
	local tEntry;
	local tOldTemplate;
	local tHealthRadio;
	local tCurveSlot;
	local tBuildGradMax;
	local tBuildGradMin;
	local tBuildGradFactor;
	function VUHDO_buildBouquetLayerTemplate(aBouquetName)

		tBouquet = VUHDO_BOUQUETS["STORED"][aBouquetName];

		if not tBouquet then
			return nil;
		end

		tOldTemplate = sBouquetLayerTemplates[aBouquetName];

		if tOldTemplate and tOldTemplate["sortedValidators"] then
			for tIdx = 1, #tOldTemplate["sortedValidators"] do
				sValidatorEntryPool:release(tOldTemplate["sortedValidators"][tIdx]);
			end
		end

		tTemplate = {
			["hasCurves"] = false,
			["hasBools"] = false,
			["hasDispels"] = false,
			["hasAlpha"] = false,
			["hasNonSecrets"] = false,
			["hasSecretValues"] = false,
			["hasAuras"] = false,
			["useBackground"] = false,
			["useText"] = false,
			["useOpacity"] = false,
			["baseType"] = nil,
			["curveValidators"] = { },
			["booleanValidators"] = { },
			["dispelValidators"] = { },
			["spriteCellValidators"] = { },
			["nonSecretValidators"] = { },
			["auraValidators"] = { },
			["alphaValidators"] = { },
			["curveResults"] = { },
			["booleanResults"] = { },
			["dispelResults"] = { },
			["spriteCellResults"] = { },
			["nonSecretResults"] = { },
			["auraResults"] = { },
			["alphaResults"] = { },
		};

		tCurveIdx = 0;
		tBoolIdx = 0;
		tDispelIdx = 0;
		tSpriteCellIdx = 0;
		tAlphaIdx = 0;
		tNonSecretIdx = 0;
		tAuraIdx = 0;

		for tCnt = 1, #tBouquet do
			tItem = tBouquet[tCnt];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]];

			if not tSpecial then
				tAuraIdx = tAuraIdx + 1;

				tTemplate["hasAuras"] = true;

				tTemplate["auraValidators"][tAuraIdx] = {
					["item"] = tItem,
					["index"] = tCnt,
				};

				tTemplate["auraResults"][tAuraIdx] = {
					["isActive"] = false,
					["icon"] = nil,
					["timer"] = 0,
					["counter"] = 0,
					["duration"] = 0,
					["color"] = nil,
					["clipL"] = nil,
					["clipR"] = nil,
					["clipT"] = nil,
					["clipB"] = nil,
					["name"] = nil,
				};
			else
				tSecretType = tSpecial["secretType"] or VUHDO_SECRET_TYPE_NONE;

				if tSecretType == VUHDO_SECRET_TYPE_HEALTH_PERCENT or tSecretType == VUHDO_SECRET_TYPE_POWER_PERCENT then
					tCurveIdx = tCurveIdx + 1;

					tTemplate["hasCurves"] = true;

					tTemplate["curveValidators"][tCurveIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
					};

					tTemplate["curveResults"][tCurveIdx] = {
						["isActive"] = false,
						["r"] = nil,
						["g"] = nil,
						["b"] = nil,
						["a"] = nil,
						["maxR"] = nil,
						["maxG"] = nil,
						["maxB"] = nil,
						["maxO"] = nil,
						["useBarTextureGradient"] = false,
						["gradientMinMixin"] = nil,
						["gradientMaxMixin"] = nil,
						["gradientClassMaxMixins"] = nil,
						["gradientClassMaxMixinFallback"] = nil,
						["gradientClassMinMixins"] = nil,
						["gradientClassMinMixinFallback"] = nil,
						["gradientIsClassMode"] = false,
						["value"] = nil,
						["maxValue"] = 100,
						["timer"] = 0,
						["duration"] = 0,
						["timer2"] = 0,
					};

					if tSpecial["custom_type"] == VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR and not tSpecial["no_color"] and tItem["custom"] then
						tHealthRadio = tItem["custom"]["radio"] or 3;

						if tHealthRadio == 1 and tItem["custom"]["isSolidGradient"] then
							tTemplate["curveResults"][tCurveIdx]["useBarTextureGradient"] = true;
						elseif tHealthRadio == 2 and tItem["custom"]["isClassGradient"] then
							tTemplate["curveResults"][tCurveIdx]["useBarTextureGradient"] = true;
						end

						if tTemplate["curveResults"][tCurveIdx]["useBarTextureGradient"] then
							tCurveSlot = tTemplate["curveResults"][tCurveIdx];

							if tHealthRadio == 1 and tItem["custom"]["isSolidGradient"] then
								tBuildGradMin = tItem["color"];

								if tBuildGradMin and tBuildGradMin["R"] and tBuildGradMin["G"] and tBuildGradMin["B"] then
									tCurveSlot["gradientMinMixin"] = CreateColor(
										tBuildGradMin["R"],
										tBuildGradMin["G"],
										tBuildGradMin["B"],
										tBuildGradMin["O"] or 1
									);
								end

								tBuildGradMax = tItem["custom"]["maxColor"];

								if tBuildGradMax and tBuildGradMax["R"] and tBuildGradMax["G"] and tBuildGradMax["B"] then
									tCurveSlot["gradientMaxMixin"] = CreateColor(
										tBuildGradMax["R"],
										tBuildGradMax["G"],
										tBuildGradMax["B"],
										tBuildGradMax["O"] or 1
									);
								end
							elseif tHealthRadio == 2 and tItem["custom"]["isClassGradient"] then
								tCurveSlot["gradientIsClassMode"] = true;

								VUHDO_initClassColors();

								tBuildGradFactor = tItem["custom"]["bright"] or 1;
								tCurveSlot["gradientClassMinMixins"] = { };
								tCurveSlot["gradientClassMaxMixins"] = { };

								for tBuildClassGradId, tBuildClassGradEntry in pairs(VUHDO_USER_CLASS_GRADIENT_COLORS) do
									if type(tBuildClassGradId) == "number" and tBuildClassGradEntry then
										tBuildGradMin = tBuildClassGradEntry["min"] or tItem["color"];
										tBuildGradMax = tBuildClassGradEntry["max"] or tItem["custom"]["maxColor"];

										if tBuildGradMin and tBuildGradMin["R"] and tBuildGradMin["G"] and tBuildGradMin["B"] then
											tCurveSlot["gradientClassMinMixins"][tBuildClassGradId] = CreateColor(
												tBuildGradMin["R"] * tBuildGradFactor,
												tBuildGradMin["G"] * tBuildGradFactor,
												tBuildGradMin["B"] * tBuildGradFactor,
												tBuildGradMin["O"] or 1
											);
										end

										if tBuildGradMax and tBuildGradMax["R"] and tBuildGradMax["G"] and tBuildGradMax["B"] then
											tCurveSlot["gradientClassMaxMixins"][tBuildClassGradId] = CreateColor(
												tBuildGradMax["R"] * tBuildGradFactor,
												tBuildGradMax["G"] * tBuildGradFactor,
												tBuildGradMax["B"] * tBuildGradFactor,
												tBuildGradMax["O"] or 1
											);
										end
									end
								end

								tBuildGradMin = tItem["color"];

								if tBuildGradMin and tBuildGradMin["R"] and tBuildGradMin["G"] and tBuildGradMin["B"] then
									tCurveSlot["gradientClassMinMixinFallback"] = CreateColor(
										tBuildGradMin["R"] * tBuildGradFactor,
										tBuildGradMin["G"] * tBuildGradFactor,
										tBuildGradMin["B"] * tBuildGradFactor,
										tBuildGradMin["O"] or 1
									);
								end

								tBuildGradMax = tItem["custom"]["maxColor"];

								if tBuildGradMax and tBuildGradMax["R"] and tBuildGradMax["G"] and tBuildGradMax["B"] then
									tCurveSlot["gradientClassMaxMixinFallback"] = CreateColor(
										tBuildGradMax["R"] * tBuildGradFactor,
										tBuildGradMax["G"] * tBuildGradFactor,
										tBuildGradMax["B"] * tBuildGradFactor,
										tBuildGradMax["O"] or 1
									);
								end
							end
						end
					end

					if not tTemplate["baseType"] then
						if tSecretType == VUHDO_SECRET_TYPE_HEALTH_PERCENT then
							tTemplate["baseType"] = "health";
						else
							tTemplate["baseType"] = "power";
						end
					end

					if tItem["color"] then
						if tItem["color"]["useBackground"] then
							tTemplate["useBackground"] = true;
						end

						if tItem["color"]["useText"] then
							tTemplate["useText"] = true;
						end

						if tItem["color"]["useOpacity"] then
							tTemplate["useOpacity"] = true;
						end
					end
				elseif tSecretType == VUHDO_SECRET_TYPE_BOOLEAN then
					tBoolIdx = tBoolIdx + 1;

					tTemplate["hasBools"] = true;

					tTemplate["booleanValidators"][tBoolIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
					};

					tTrueColor = VUHDO_getBouquetBoolColor(aBouquetName, tItem["name"]);

					if tSpecial and tSpecial["isInverted"] then
						tTemplate["booleanResults"][tBoolIdx] = {
							["secretBool"] = nil,
							["trueColorMixin"] = sTransparentColor,
							["falseColorMixin"] = tTrueColor,
							["color"] = tItem["color"],
						};
					else
						tTemplate["booleanResults"][tBoolIdx] = {
							["secretBool"] = nil,
							["trueColorMixin"] = tTrueColor,
							["falseColorMixin"] = sTransparentColor,
							["color"] = tItem["color"],
						};
					end

					if tSpecial["isGlobal"] and tItem["color"] and tItem["color"]["useOpacity"] then
						tAlphaIdx = tAlphaIdx + 1;

						tTemplate["hasAlpha"] = true;

						tTemplate["alphaValidators"][tAlphaIdx] = {
							["item"] = tItem,
							["special"] = tSpecial,
							["index"] = tCnt,
						};

						if tSpecial and tSpecial["isInverted"] then
							tTemplate["alphaResults"][tAlphaIdx] = {
								["secretBool"] = nil,
								["trueAlpha"] = 1,
								["falseAlpha"] = tItem["color"]["O"] or 1,
							};
						else
							tTemplate["alphaResults"][tAlphaIdx] = {
								["secretBool"] = nil,
								["trueAlpha"] = tItem["color"]["O"] or 1,
								["falseAlpha"] = 1,
							};
						end
					end
				elseif tSecretType == VUHDO_SECRET_TYPE_DISPEL then
					tDispelIdx = tDispelIdx + 1;

					tTemplate["hasDispels"] = true;

					tTemplate["dispelValidators"][tDispelIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
						["debuffType"] = tSpecial["debuffType"],
					};

					if tSpecial["buildCurves"] and tItem["custom"] and tItem["custom"]["bright"] then
						tTemplate["dispelValidators"][tDispelIdx]["curves"] = tSpecial["buildCurves"](tItem["custom"]["bright"]);
					end

					if tSpecial["buildTextCurves"] and tItem["custom"] and tItem["custom"]["bright"] then
						tTemplate["dispelValidators"][tDispelIdx]["textCurves"] = tSpecial["buildTextCurves"](tItem["custom"]["bright"]);
					end

					tTemplate["dispelResults"][tDispelIdx] = {
						["isActive"] = false,
						["barColor"] = nil,
						["r"] = nil,
						["g"] = nil,
						["b"] = nil,
						["a"] = nil,
						["tr"] = nil,
						["tg"] = nil,
						["tb"] = nil,
						["ta"] = nil,
						["auraInstanceId"] = nil,
						["useBackground"] = nil,
						["useText"] = nil,
					};

					if tItem["color"] then
						if tItem["color"]["useBackground"] then
							tTemplate["useBackground"] = true;
						end

						if tItem["color"]["useText"] then
							tTemplate["useText"] = true;
						end

						if tItem["color"]["useOpacity"] then
							tTemplate["useOpacity"] = true;
						end
					end
				elseif tSecretType == VUHDO_SECRET_TYPE_SPRITE_CELL then
					tSpriteCellIdx = tSpriteCellIdx + 1;

					tTemplate["hasSpriteCells"] = true;

					tTemplate["spriteCellValidators"][tSpriteCellIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
					};

					tTemplate["spriteCellResults"][tSpriteCellIdx] = {
						["isActive"] = false,
						["icon"] = nil,
						["spriteCell"] = nil,
					};
				elseif tSecretType == VUHDO_SECRET_TYPE_NONE or tSecretType == VUHDO_SECRET_TYPE_VALUES then
					tNonSecretIdx = tNonSecretIdx + 1;

					tTemplate["hasNonSecrets"] = true;

					if tSecretType == VUHDO_SECRET_TYPE_VALUES then
						tTemplate["hasSecretValues"] = true;
					end

					tTemplate["nonSecretValidators"][tNonSecretIdx] = {
						["item"] = tItem,
						["special"] = tSpecial,
						["index"] = tCnt,
					};

					tTemplate["nonSecretResults"][tNonSecretIdx] = {
						["isActive"] = false,
						["icon"] = nil,
						["timer"] = 0,
						["counter"] = 0,
						["duration"] = 0,
						["color"] = { },
						["timer2"] = 0,
						["clipL"] = nil,
						["clipR"] = nil,
						["clipT"] = nil,
						["clipB"] = nil,
						["maxColor"] = { },
						["gradientMinMixin"] = CreateColor(0, 0, 0, 1),
						["gradientMaxMixin"] = CreateColor(0, 0, 0, 1),
					};
				end
			end
		end

		tAllValidators = { };

		if tTemplate["hasNonSecrets"] then
			for tIdx = 1, #tTemplate["nonSecretValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_NONSECRET;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["nonSecretValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		if tTemplate["hasCurves"] then
			for tIdx = 1, #tTemplate["curveValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_CURVE;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["curveValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		if tTemplate["hasDispels"] then
			for tIdx = 1, #tTemplate["dispelValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_DISPEL;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["dispelValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		if tTemplate["hasSpriteCells"] then
			for tIdx = 1, #tTemplate["spriteCellValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["spriteCellValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		if tTemplate["hasAuras"] then
			for tIdx = 1, #tTemplate["auraValidators"] do
				tEntry = sValidatorEntryPool:get();

				tEntry["type"] = VUHDO_BOUQUET_LAYER_TYPE_AURA;
				tEntry["resultIdx"] = tIdx;
				tEntry["bouquetIdx"] = tTemplate["auraValidators"][tIdx]["index"];

				tinsert(tAllValidators, tEntry);
			end
		end

		tsort(tAllValidators, function(a, b)
			return a["bouquetIdx"] > b["bouquetIdx"];
		end);

		tTemplate["sortedValidators"] = tAllValidators;

		sBouquetLayerTemplates[aBouquetName] = tTemplate;

		return tTemplate;

	end



	--
	function VUHDO_buildAllBouquetLayerTemplates()

		twipe(sBouquetLayerTemplates);

		for tBouquetName, _ in pairs(VUHDO_BOUQUETS["STORED"]) do
			VUHDO_buildBouquetLayerTemplate(tBouquetName);
		end

		return;

	end



	--
	function VUHDO_getBouquetLayerTemplate(aBouquetName)

		return sBouquetLayerTemplates[aBouquetName];

	end
end



do
	--
	local tValidatorEntry;
	local tValidators;
	local function VUHDO_findResultSlot(aLayerTemplate, aValidatorsKey, aResultsKey, aPriorityIndex)

		tValidators = aLayerTemplate[aValidatorsKey];

		for tIdx = 1, #tValidators do
			tValidatorEntry = tValidators[tIdx];
			if tValidatorEntry["index"] == aPriorityIndex then
				return aLayerTemplate[aResultsKey][tIdx];
			end
		end

		return nil;

	end



	--
	function VUHDO_findNonSecretResultSlot(aLayerTemplate, aPriorityIndex)

		return VUHDO_findResultSlot(aLayerTemplate, "nonSecretValidators", "nonSecretResults", aPriorityIndex);

	end



	--
	function VUHDO_findAuraResultSlot(aLayerTemplate, aPriorityIndex)

		return VUHDO_findResultSlot(aLayerTemplate, "auraValidators", "auraResults", aPriorityIndex);

	end



	--
	function VUHDO_findCurveResultSlot(aLayerTemplate, aPriorityIndex)

		return VUHDO_findResultSlot(aLayerTemplate, "curveValidators", "curveResults", aPriorityIndex);

	end



	--
	function VUHDO_findBoolResultSlot(aLayerTemplate, aPriorityIndex)

		return VUHDO_findResultSlot(aLayerTemplate, "booleanValidators", "booleanResults", aPriorityIndex);

	end



	--
	function VUHDO_findDispelResultSlot(aLayerTemplate, aPriorityIndex)

		return VUHDO_findResultSlot(aLayerTemplate, "dispelValidators", "dispelResults", aPriorityIndex);

	end



	do
		--
		local tValidators;
		local tValidatorEntry;
		function VUHDO_findDispelValidatorEntry(aLayerTemplate, aPriorityIndex)

			tValidators = aLayerTemplate["dispelValidators"];

			for tIdx = 1, #tValidators do
				tValidatorEntry = tValidators[tIdx];

				if tValidatorEntry["index"] == aPriorityIndex then
					return tValidatorEntry;
				end
			end

			return nil;

		end
	end



	--
	function VUHDO_findSpriteCellResultSlot(aLayerTemplate, aPriorityIndex)

		return VUHDO_findResultSlot(aLayerTemplate, "spriteCellValidators", "spriteCellResults", aPriorityIndex);

	end
end



do
	--
	function VUHDO_getColorHash(aColor)

		return
			(aColor["R"] or 0) * 0.0001
			+ (aColor["G"] or 0) * 0.001
			+ (aColor["B"] or 0) * 0.01
			+ (aColor["O"] or 0) * 0.1
			+ (aColor["TR"] or 0)
			+ (aColor["TG"] or 0) * 10
			+ (aColor["TB"] or 0) * 100
			+ (aColor["TO"] or 0) * 1000;

	end



	--
	local tHasChanged;
	local tLastTime;
	function VUHDO_hasBouquetChanged(aUnit, aBouquetName, anArg1, anArg2, anArg3, anArg4, anArg5, anArg6, anArg7, anArg8, anArg9, anArg10)

		tLastTime = VUHDO_LAST_EVALUATED_BOUQUETS[aBouquetName][aUnit];

		if not tLastTime then
			VUHDO_LAST_EVALUATED_BOUQUETS[aBouquetName][aUnit] = sBouquetStatePool:get();

			return true;
		end

		tHasChanged = false;

		if anArg1  ~= tLastTime[ 1] then
			tLastTime[ 1] = anArg1;  tHasChanged = true;
		end

		if anArg2  ~= tLastTime[ 2] then
			tLastTime[ 2] = anArg2;  tHasChanged = true;
		end

		if anArg3  ~= tLastTime[ 3] then
			tLastTime[ 3] = anArg3;  tHasChanged = true;
		end

		if anArg4  ~= tLastTime[ 4] then
			tLastTime[ 4] = anArg4;  tHasChanged = true;
		end

		if anArg5  ~= tLastTime[ 5] then
			tLastTime[ 5] = anArg5;  tHasChanged = true;
		end

		if anArg6  ~= tLastTime[ 6] then
			tLastTime[ 6] = anArg6;  tHasChanged = true;
		end

		if anArg7  ~= tLastTime[ 7] then
			tLastTime[ 7] = anArg7;  tHasChanged = true;
		end

		if anArg8  ~= tLastTime[ 8] then
			tLastTime[ 8] = anArg8;  tHasChanged = true;
		end

		if anArg9  ~= tLastTime[ 9] then
			tLastTime[ 9] = anArg9;  tHasChanged = true;
		end

		if anArg10 ~= tLastTime[10] then
			tLastTime[10] = anArg10; tHasChanged = true;
		end

		return tHasChanged;
	end
end



--
function VUHDO_releaseAndWipeLastEvaluatedBouquets()

	for tBouquetName, tUnitStates in pairs(VUHDO_LAST_EVALUATED_BOUQUETS) do
		for tUnit, tState in pairs(tUnitStates) do
			if tState then
				sBouquetStatePool:release(tState);
			end
		end
	end

	twipe(VUHDO_LAST_EVALUATED_BOUQUETS);

	return;

end



do
	--
	local function VUHDO_ensureClassColorsInitialized()

		if not VUHDO_USER_CLASS_COLORS or not VUHDO_USER_CLASS_GRADIENT_COLORS then
			VUHDO_initClassColors();
		end

		return;

	end



	--
	local tColor;
	local tFactor;
	local tModi, tInvModi;
	local tR1, tG1, tB1, tO1;
	local tR2, tG2, tB2, tO2;
	local tGood, tFair, tLow;
	local tDestColor = { ["useBackground"] = true, ["useOpacity"] = true };
	local tRadio;
	local tIsGradient;
	local tClassId;
	local tMaxColor;
	local tDestMaxColor = { ["useBackground"] = true, ["useOpacity"] = true };
	function VUHDO_getBouquetStatusBarColor(anEntry, anInfo, aValue, aMaxValue)

		VUHDO_ensureClassColorsInitialized();

		tRadio = anEntry["custom"]["radio"];

		if 1 == tRadio then -- solid
			tColor = anEntry["color"];
			tIsGradient = anEntry["custom"]["isSolidGradient"];

			if tIsGradient then
				tMaxColor = anEntry["custom"]["maxColor"];

				tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"] = tColor["R"], tColor["G"], tColor["B"], tColor["O"] or 1;

				if tMaxColor then
					tDestMaxColor["R"], tDestMaxColor["G"], tDestMaxColor["B"], tDestMaxColor["O"]
						= tMaxColor["R"], tMaxColor["G"], tMaxColor["B"], tMaxColor["O"] or 1;

					return tDestColor, tDestMaxColor;
				else
					return tDestColor, nil;
				end
			else
				tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"] = tColor["R"], tColor["G"], tColor["B"], tColor["O"] or 1;

				return tDestColor, nil;
			end
		elseif 2 == tRadio then -- class color
			tClassId = anInfo["classId"];
			tFactor = anEntry["custom"]["bright"];
			tIsGradient = anEntry["custom"]["isClassGradient"];

			if tIsGradient then
				if VUHDO_USER_CLASS_GRADIENT_COLORS and VUHDO_USER_CLASS_GRADIENT_COLORS[tClassId] then
					tColor = VUHDO_USER_CLASS_GRADIENT_COLORS[tClassId]["min"] or anEntry["color"];
					tMaxColor = VUHDO_USER_CLASS_GRADIENT_COLORS[tClassId]["max"] or anEntry["custom"]["maxColor"];
				else
					tColor = anEntry["color"];
					tMaxColor = anEntry["custom"]["maxColor"];
				end

				tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"]
					= tColor["R"] * tFactor, tColor["G"] * tFactor, tColor["B"] * tFactor, tColor["O"] or 1;

				if tMaxColor then
					tDestMaxColor["R"], tDestMaxColor["G"], tDestMaxColor["B"], tDestMaxColor["O"]
						= tMaxColor["R"] * tFactor, tMaxColor["G"] * tFactor, tMaxColor["B"] * tFactor, tMaxColor["O"] or 1;

					return tDestColor, tDestMaxColor;
				else
					return tDestColor, nil;
				end
			else
				if VUHDO_USER_CLASS_COLORS and VUHDO_USER_CLASS_COLORS[tClassId] then
					tColor = VUHDO_USER_CLASS_COLORS[tClassId] or anEntry["color"];
				else
					tColor = anEntry["color"];
				end

				tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"]
					= tColor["R"] * tFactor, tColor["G"] * tFactor, tColor["B"] * tFactor, tColor["O"] or 1;

				return tDestColor, nil;
			end
		elseif not issecretvalue(aValue) and not issecretvalue(aMaxValue) and aMaxValue ~= 0 then -- 3 == gradient
			tModi = ((aValue / aMaxValue) ^ 1.7) * 2;
			tFair = anEntry["custom"]["grad_med"];

			if tModi > 1 then
				tGood = anEntry["color"];
				tR1, tG1, tB1, tO1 = tGood["R"], tGood["G"], tGood["B"], tGood["O"];
				tR2, tG2, tB2, tO2 = tFair["R"], tFair["G"], tFair["B"], tFair["O"];
				tModi = tModi - 1;
			else
				tLow = anEntry["custom"]["grad_low"];
				tR1, tG1, tB1, tO1 = tFair["R"], tFair["G"], tFair["B"], tFair["O"];
				tR2, tG2, tB2, tO2 = tLow["R"], tLow["G"], tLow["B"], tLow["O"];
			end

			tInvModi = 1 - tModi;
			tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"]
				= tR2 * tInvModi + tR1 * tModi, tG2 * tInvModi + tG1 * tModi,
				tB2 * tInvModi + tB1 * tModi, tO2 * tInvModi + tO1 * tModi;

			return tDestColor, nil;
		else
			tColor = anEntry["color"];

			tDestColor["R"], tDestColor["G"], tDestColor["B"], tDestColor["O"] = tColor["R"], tColor["G"], tColor["B"], tColor["O"] or 1;

			return tDestColor, nil;
		end

		return;

	end
end



--
local txState = {
	["active"] = false,
	["icon"] = nil,
	["name"] = nil,

	["color"] = { },
	["isColorInit"] = false,

	["maxColor"] = { },
	["isMaxColorInit"] = false,

	["counter"] = 0,
	["timer"] = 0,
	["duration"] = 0,
	["timer2"] = 0,
	["level"] = 0,
	["activeAuras"] = 0,

	["clipL"] = nil,
	["clipR"] = nil,
	["clipT"] = nil,
	["clipB"] = nil,
};



--
function VUHDO_getIsCurrentBouquetActive()

	return txState["active"];

end



--
function VUHDO_getCurrentBouquetColor()

	if not txState["isColorInit"] then
		twipe(txState["color"]);
	end

	return txState["color"];

end



--
function VUHDO_getCurrentBouquetMaxColor()

	if not txState["isMaxColorInit"] then
		twipe(txState["maxColor"]);
	end

	return txState["maxColor"];

end


--
function VUHDO_getCurrentBouquetStacks()

	return txState["counter"];

end



--
function VUHDO_getCurrentBouquetTimer()

	return txState["timer"];

end



--
function VUHDO_getCurrentBouquetActiveAuras()

	return txState["activeAuras"];

end



do
	--
	local tInfos;
	local tName;
	local tSpecial;
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tNow;
	local tTimer2;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tColor;
	local tFactor;
	local tMaxColor;
	local tValidatorEntry;
	local tResultSlot;
	local tAuraInstanceId;
	local tSecretType;
	local tBarColorType;
	local tTextColorType;
	local tNeedsCopy;
	local tSpriteCell;
	local tAuraInstances;
	local tCachedAura;
	local tSpellId;
	local tSecretBool;
	local tExpiration;
	local tWorkingColor = { };
	local tSecretContext = { };
	local tSecretColor;
	local tGradientClassId;
	function VUHDO_evaluateBouquetSecret(aUnit, aBouquetName, aInfo, aBouquet, aAnzInfos, aLayerTemplate)

		txState["activeAuras"] = 0;

		if sSecretsEnabled then
			tSecretContext["powerCurves"] = sBouquetCurves[aBouquetName] and sBouquetCurves[aBouquetName]["power"];
			tSecretContext["healthCurve"] = VUHDO_getHealthCurve(aBouquetName, aInfo["classId"]);
			tSecretContext["dispelCurves"] = sDebuffTypeCurves;
			tSecretContext["defaultDispelCurve"] = VUHDO_getDispelTypeCurve();
		else
			tSecretContext = nil;
		end

		if aLayerTemplate then
			for tIdx = 1, #aLayerTemplate["nonSecretResults"] do
				aLayerTemplate["nonSecretResults"][tIdx]["isActive"] = false;
			end

			for tIdx = 1, #aLayerTemplate["auraResults"] do
				aLayerTemplate["auraResults"][tIdx]["isActive"] = false;
			end

			for tIdx = 1, #aLayerTemplate["curveResults"] do
				aLayerTemplate["curveResults"][tIdx]["isActive"] = false;
				aLayerTemplate["curveResults"][tIdx]["r"] = nil;
				aLayerTemplate["curveResults"][tIdx]["g"] = nil;
				aLayerTemplate["curveResults"][tIdx]["b"] = nil;
				aLayerTemplate["curveResults"][tIdx]["a"] = nil;
				aLayerTemplate["curveResults"][tIdx]["maxR"] = nil;
				aLayerTemplate["curveResults"][tIdx]["maxG"] = nil;
				aLayerTemplate["curveResults"][tIdx]["maxB"] = nil;
				aLayerTemplate["curveResults"][tIdx]["maxO"] = nil;
				aLayerTemplate["curveResults"][tIdx]["timer"] = 0;
				aLayerTemplate["curveResults"][tIdx]["duration"] = 0;
				aLayerTemplate["curveResults"][tIdx]["timer2"] = 0;
			end

			for tIdx = 1, #aLayerTemplate["booleanResults"] do
				aLayerTemplate["booleanResults"][tIdx]["secretBool"] = nil;
			end

			for tIdx = 1, #aLayerTemplate["dispelResults"] do
				aLayerTemplate["dispelResults"][tIdx]["isActive"] = false;
				aLayerTemplate["dispelResults"][tIdx]["barColor"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["r"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["g"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["b"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["a"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["tr"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["tg"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["tb"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["ta"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["auraInstanceId"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["useBackground"] = nil;
				aLayerTemplate["dispelResults"][tIdx]["useText"] = nil;
			end

			for tIdx = 1, #aLayerTemplate["spriteCellResults"] do
				aLayerTemplate["spriteCellResults"][tIdx]["isActive"] = false;
				aLayerTemplate["spriteCellResults"][tIdx]["icon"] = nil;
				aLayerTemplate["spriteCellResults"][tIdx]["spriteCell"] = nil;
			end

			for tCnt = aAnzInfos, 1, -1 do
				tInfos = aBouquet[tCnt];
				tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tInfos["name"]];

				if not tSpecial then
					tResultSlot = VUHDO_findAuraResultSlot(aLayerTemplate, tCnt);

					if tResultSlot then
						tName = tInfos["name"];
						tIsActive = false;
						tSpellId = tonumber(tName);

						tAuraInstances = VUHDO_UNIT_AURA_BY_SPELL[aUnit] and
							(VUHDO_UNIT_AURA_BY_SPELL[aUnit][tName] or (tSpellId and VUHDO_UNIT_AURA_BY_SPELL[aUnit][tSpellId]));

						if tAuraInstances then
							for _, tAuraInstanceId in ipairs(tAuraInstances) do
								if not ShouldUnitAuraInstanceBeSecret(aUnit, tAuraInstanceId) then
									tCachedAura = VUHDO_UNIT_AURA_CACHE[aUnit] and VUHDO_UNIT_AURA_CACHE[aUnit][tAuraInstanceId];

									if tCachedAura and VUHDO_auraSourceMatchesFilter(tCachedAura, tInfos) then
										tIsActive = true;
										txState["activeAuras"] = txState["activeAuras"] + 1;

										tNow = GetTime();

										if issecretvalue(tCachedAura["expirationTime"]) or issecretvalue(tCachedAura["duration"]) then
											tTimer = tCachedAura["expirationTime"];
											tDuration = tCachedAura["duration"];
										else
											tExpiration = tCachedAura["expirationTime"] or 0;
											tDuration = tCachedAura["duration"] or 0;

											if tExpiration == 0 and tDuration == 0 then
												tExpiration = tNow + 9999;

												tDuration = 9999;
											end

											if tInfos["alive"] then
												tTimer = tNow - tExpiration + tDuration;
											else
												tTimer = tExpiration - tNow;
											end

											if tTimer then
												tTimer = floor(tTimer * 10) * 0.1;
											end
										end

										tIcon = tCachedAura["icon"];
										tCounter = tCachedAura["applications"];

										tColor = tInfos["color"];

										if tInfos["icon"] ~= 1 then
											tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2];

											tColor["isDefault"] = false;
										else
											tColor["isDefault"] = true;
										end

										tResultSlot["isActive"] = true;
										tResultSlot["icon"] = tIcon;
										tResultSlot["timer"] = tTimer or 0;
										tResultSlot["counter"] = tCounter or 0;
										tResultSlot["duration"] = tDuration or 0;
										tResultSlot["color"] = tColor;
										tResultSlot["name"] = tName;
										tResultSlot["isAliveTime"] = tInfos["alive"];

										break;
									end
								end
							end
						end
					end
				else
					tSecretType = tSpecial["secretType"] or VUHDO_SECRET_TYPE_NONE;

					if tSecretType == VUHDO_SECRET_TYPE_NONE or tSecretType == VUHDO_SECRET_TYPE_VALUES then
						tResultSlot = VUHDO_findNonSecretResultSlot(aLayerTemplate, tCnt);

						if tResultSlot then
							tName = nil;

							tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, tClipL, tClipR, tClipT, tClipB = tSpecial["validator"](aInfo, tInfos, tSecretContext);

							tResultSlot["isActive"] = tIsActive;

							if tIsActive then
								if tInfos["icon"] ~= 1 then
									tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2];
								end

								if not tColor then
									if 3 == tSpecial["custom_type"] then
										tColor, tMaxColor = VUHDO_getBouquetStatusBarColor(tInfos, aInfo, tTimer, tDuration);
									end

									if not tColor then
										tColor = tInfos["color"];
									end
								elseif 4 == tSpecial["custom_type"] then
									tMaxColor = nil;

									tColor = VUHDO_copyColorTo(tColor, tWorkingColor);
									tFactor = tInfos["custom"]["bright"];

									if tColor["useBackground"] then
										tColor["R"], tColor["G"], tColor["B"] = tColor["R"] * tFactor, tColor["G"] * tFactor, tColor["B"] * tFactor;
									end

									if tColor["useText"] then
										tColor["TR"], tColor["TG"], tColor["TB"] = tColor["TR"] * tFactor, tColor["TG"] * tFactor, tColor["TB"] * tFactor;
									end
								else
									tMaxColor = nil;
								end

								if tColor["useText"] then
									tColor["useText"] = tInfos["color"]["useText"];
								end

								if tColor["useBackground"] then
									tColor["useBackground"] = tInfos["color"]["useBackground"];
								end

								if tColor["useOpacity"] then
									tColor["useOpacity"] = tInfos["color"]["useOpacity"];
								end

								tResultSlot["icon"] = tIcon;
								tResultSlot["timer"] = tTimer or 0;
								tResultSlot["counter"] = tCounter or 0;
								tResultSlot["duration"] = tDuration or 0;

								if tColor then
									VUHDO_copyColorTo(tColor, tResultSlot["color"]);
								end

								tResultSlot["timer2"] = tTimer2 or 0;
								tResultSlot["clipL"] = tClipL;
								tResultSlot["clipR"] = tClipR;
								tResultSlot["clipT"] = tClipT;
								tResultSlot["clipB"] = tClipB;

								if tMaxColor then
									VUHDO_copyColorTo(tMaxColor, tResultSlot["maxColor"]);

									tResultSlot["gradientMinMixin"]:SetRGBA(tResultSlot["color"]["R"], tResultSlot["color"]["G"], tResultSlot["color"]["B"], tResultSlot["color"]["O"] or 1);
									tResultSlot["gradientMaxMixin"]:SetRGBA(tResultSlot["maxColor"]["R"], tResultSlot["maxColor"]["G"], tResultSlot["maxColor"]["B"], tResultSlot["maxColor"]["O"] or 1);
								end
							end
						end
					elseif tSecretType == VUHDO_SECRET_TYPE_HEALTH_PERCENT then
						tResultSlot = VUHDO_findCurveResultSlot(aLayerTemplate, tCnt);

						if tResultSlot then
							tIsActive, _, tTimer, _, tDuration, _, tTimer2, _, _, _, _, _, tSecretColor = tSpecial["validator"](aInfo, tInfos, tSecretContext);

							tResultSlot["isActive"] = tIsActive;

							if tIsActive then
								if tSecretColor and not issecretvalue(tSecretColor) then
									tResultSlot["r"], tResultSlot["g"], tResultSlot["b"], tResultSlot["a"] = tSecretColor:GetRGBA();
								end

								tResultSlot["value"] = UnitHealthPercent(aUnit);
								tResultSlot["timer"] = tTimer or 0;
								tResultSlot["duration"] = tDuration or 0;
								tResultSlot["timer2"] = tTimer2 or 0;
							end

							if tResultSlot["useBarTextureGradient"] and tIsActive and tResultSlot["gradientIsClassMode"] then
								tGradientClassId = aInfo["classId"];

								tResultSlot["gradientMinMixin"] = tResultSlot["gradientClassMinMixins"][tGradientClassId] or tResultSlot["gradientClassMinMixinFallback"];
								tResultSlot["gradientMaxMixin"] = tResultSlot["gradientClassMaxMixins"][tGradientClassId] or tResultSlot["gradientClassMaxMixinFallback"];
							end
						end
					elseif tSecretType == VUHDO_SECRET_TYPE_POWER_PERCENT then
						tResultSlot = VUHDO_findCurveResultSlot(aLayerTemplate, tCnt);

						if tResultSlot then
							tIsActive, _, tTimer, _, tDuration, _, tTimer2, _, _, _, _, _, tSecretColor = tSpecial["validator"](aInfo, tInfos, tSecretContext);

							tResultSlot["isActive"] = tIsActive;

							if tIsActive then
								if tSecretColor and not issecretvalue(tSecretColor) then
									tResultSlot["r"], tResultSlot["g"], tResultSlot["b"], tResultSlot["a"] =
										tSecretColor:GetRGBA();
								end

								tResultSlot["value"] = UnitPowerPercent(aUnit, aInfo["powertype"]);
								tResultSlot["timer"] = tTimer or 0;
								tResultSlot["duration"] = tDuration or 0;
								tResultSlot["timer2"] = tTimer2 or 0;
							end

							if tResultSlot["useBarTextureGradient"] and tIsActive and tResultSlot["gradientIsClassMode"] then
								tGradientClassId = aInfo["classId"];

								tResultSlot["gradientMinMixin"] = tResultSlot["gradientClassMinMixins"][tGradientClassId] or tResultSlot["gradientClassMinMixinFallback"];
								tResultSlot["gradientMaxMixin"] = tResultSlot["gradientClassMaxMixins"][tGradientClassId] or tResultSlot["gradientClassMaxMixinFallback"];
							end
						end
					elseif tSecretType == VUHDO_SECRET_TYPE_BOOLEAN then
						tResultSlot = VUHDO_findBoolResultSlot(aLayerTemplate, tCnt);

						if tResultSlot then
							_, _, _, _, _, _, _, _, _, _, _, tSecretBool = tSpecial["validator"](aInfo, tInfos, tSecretContext);

							tResultSlot["secretBool"] = tSecretBool;
						end
					elseif tSecretType == VUHDO_SECRET_TYPE_DISPEL then
						tResultSlot = VUHDO_findDispelResultSlot(aLayerTemplate, tCnt);

						if tResultSlot then
							tValidatorEntry = VUHDO_findDispelValidatorEntry(aLayerTemplate, tCnt);

							if tValidatorEntry and tValidatorEntry["curves"] and tValidatorEntry["special"]["getCurve"] then
								tSecretContext["dispelCurve"] = tValidatorEntry["special"]["getCurve"](tValidatorEntry["curves"], aUnit, true);
							else
								tSecretContext["dispelCurve"] = nil;
							end

							if tValidatorEntry and tValidatorEntry["textCurves"] and tValidatorEntry["special"]["getTextCurve"] then
								tSecretContext["dispelTextCurve"] = tValidatorEntry["special"]["getTextCurve"](tValidatorEntry["textCurves"], aUnit, true);
							else
								tSecretContext["dispelTextCurve"] = nil;
							end

							tIsActive, _, _, _, _, tColor, _, _, _, _, _, tAuraInstanceId, tSecretColor = tSpecial["validator"](aInfo, tInfos, tSecretContext);

							tResultSlot["isActive"] = tIsActive;

							if tIsActive then
								if tColor then
									tBarColorType = VUHDO_getAuraBarColorType(aUnit);
									tTextColorType = VUHDO_getAuraTextColorType(aUnit);

									tFactor = tInfos["custom"] and tInfos["custom"]["bright"] or 1;

									tNeedsCopy = false;

									if tBarColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
										tResultSlot["r"] = tColor["R"];
										tResultSlot["g"] = tColor["G"];
										tResultSlot["b"] = tColor["B"];
										tResultSlot["a"] = tColor["O"];

										tResultSlot["useBackground"] = tColor["useBackground"];
									else
										if tFactor < 1 and tColor["useBackground"] then
											tColor = VUHDO_copyColorTo(tColor, tWorkingColor);

											tNeedsCopy = true;

											tColor["R"] = tColor["R"] * tFactor;
											tColor["G"] = tColor["G"] * tFactor;
											tColor["B"] = tColor["B"] * tFactor;
										end
									end

									if tTextColorType == VUHDO_AURA_GROUP_COLOR_DISPEL then
										tResultSlot["tr"] = tColor["TR"];
										tResultSlot["tg"] = tColor["TG"];
										tResultSlot["tb"] = tColor["TB"];
										tResultSlot["ta"] = tColor["TO"];

										tResultSlot["useText"] = tColor["useText"];
									else
										if tFactor < 1 and tColor["useText"] then
											if not tNeedsCopy then
												tColor = VUHDO_copyColorTo(tColor, tWorkingColor);
											end

											tColor["TR"] = tColor["TR"] * tFactor;
											tColor["TG"] = tColor["TG"] * tFactor;
											tColor["TB"] = tColor["TB"] * tFactor;
										end
									end

									if tBarColorType ~= VUHDO_AURA_GROUP_COLOR_DISPEL or tTextColorType ~= VUHDO_AURA_GROUP_COLOR_DISPEL then
										tResultSlot["barColor"] = tColor;
									end
								end

								if tAuraInstanceId then
									tResultSlot["auraInstanceId"] = tAuraInstanceId;
								end

								if tSecretColor then
									tResultSlot["r"], tResultSlot["g"], tResultSlot["b"], tResultSlot["a"] = tSecretColor:GetRGBA();
								end
							end
						end
					elseif tSecretType == VUHDO_SECRET_TYPE_SPRITE_CELL then
						tResultSlot = VUHDO_findSpriteCellResultSlot(aLayerTemplate, tCnt);

						if tResultSlot then
							tIsActive, tIcon, _, _, _, _, _, _, _, _, _, tSpriteCell = tSpecial["validator"](aInfo, tInfos, tSecretContext);

							tResultSlot["isActive"] = tIsActive;

							if tIsActive then
								tResultSlot["icon"] = tIcon;
								tResultSlot["spriteCell"] = tSpriteCell;
							end
						end
					end
				end
			end

			if aLayerTemplate["hasAlpha"] then
				for tIdx = 1, #aLayerTemplate["alphaValidators"] do
					tValidatorEntry = aLayerTemplate["alphaValidators"][tIdx];
					tResultSlot = aLayerTemplate["alphaResults"][tIdx];

					_, _, _, _, _, _, _, _, _, _, _, tSecretBool = tValidatorEntry["special"]["validator"](aInfo, tValidatorEntry["item"], tSecretContext);

					tResultSlot["secretBool"] = tSecretBool;
				end
			end

			txState["isColorInit"] = false;
			txState["isMaxColorInit"] = false;

			for tSortedIdx = 1, #aLayerTemplate["sortedValidators"] do
				tValidatorEntry = aLayerTemplate["sortedValidators"][tSortedIdx];

				if VUHDO_BOUQUET_LAYER_TYPE_NONSECRET == tValidatorEntry["type"] then
					tResultSlot = aLayerTemplate["nonSecretResults"][tValidatorEntry["resultIdx"]];

					if tResultSlot["isActive"] then
						txState["active"] = true;
						txState["level"] = aLayerTemplate["nonSecretValidators"][tValidatorEntry["resultIdx"]]["index"];

						if tResultSlot["icon"] then
							txState["icon"] = tResultSlot["icon"];
							txState["clipL"] = tResultSlot["clipL"];
							txState["clipR"] = tResultSlot["clipR"];
							txState["clipT"] = tResultSlot["clipT"];
							txState["clipB"] = tResultSlot["clipB"];
						end

						tColor = tResultSlot["color"];

						if tColor then
							if not txState["isColorInit"] then
								twipe(txState["color"]);
								txState["isColorInit"] = true;
							end

							if tColor["useText"] then
								txState["color"]["useText"] = true;
								txState["color"]["TR"] = tColor["TR"];
								txState["color"]["TG"] = tColor["TG"];
								txState["color"]["TB"] = tColor["TB"];
								txState["color"]["TO"] = tColor["TO"];
							end

							if tColor["useBackground"] then
								txState["color"]["useBackground"] = true;
								txState["color"]["R"] = tColor["R"];
								txState["color"]["G"] = tColor["G"];
								txState["color"]["B"] = tColor["B"];
								txState["color"]["O"] = tColor["O"];
							end

							if tColor["useOpacity"] then
								txState["color"]["useOpacity"] = true;

								if tColor["TO"] ~= nil then
									txState["color"]["TO"] = (txState["color"]["TO"] or 1) * tColor["TO"];
								end

								if tColor["O"] ~= nil then
									txState["color"]["O"] = (txState["color"]["O"] or 1) * tColor["O"];
								end
							end

							txState["color"]["isDefault"] = tColor["isDefault"];
							txState["color"]["noStacksColor"] = tColor["noStacksColor"];
							txState["color"]["useSlotColor"] = tColor["useSlotColor"];

							tMaxColor = tResultSlot["maxColor"];

							if tMaxColor then
								if not txState["isMaxColorInit"] then
									twipe(txState["maxColor"]);
									txState["isMaxColorInit"] = true;
								end

								if tMaxColor["useText"] then
									txState["maxColor"]["useText"] = true;
									txState["maxColor"]["TR"] = tMaxColor["TR"];
									txState["maxColor"]["TG"] = tMaxColor["TG"];
									txState["maxColor"]["TB"] = tMaxColor["TB"];
									txState["maxColor"]["TO"] = tMaxColor["TO"];
								end

								if tMaxColor["useBackground"] then
									txState["maxColor"]["useBackground"] = true;
									txState["maxColor"]["R"] = tMaxColor["R"];
									txState["maxColor"]["G"] = tMaxColor["G"];
									txState["maxColor"]["B"] = tMaxColor["B"];
									txState["maxColor"]["O"] = tMaxColor["O"];
								end

								if tMaxColor["useOpacity"] then
									txState["maxColor"]["useOpacity"] = true;

									if tMaxColor["TO"] ~= nil then
										txState["maxColor"]["TO"] = (txState["maxColor"]["TO"] or 1) * tMaxColor["TO"];
									end

									if tMaxColor["O"] ~= nil then
										txState["maxColor"]["O"] = (txState["maxColor"]["O"] or 1) * tMaxColor["O"];
									end
								end
							end
						end

						tCounter = tResultSlot["counter"] or 0;

						if issecretvalue(tCounter) or tCounter >= 0 then
							txState["counter"] = tCounter;
						end

						tTimer = tResultSlot["timer"] or 0;
						tTimer2 = tResultSlot["timer2"] or 0;
						tDuration = tResultSlot["duration"] or 0;

						if issecretvalue(tDuration) or tDuration >= 0 then
							if issecretvalue(tTimer) or tTimer >= 0 then
								txState["timer"] = tTimer;
								txState["duration"] = tDuration;
							end

							if issecretvalue(tTimer2) or tTimer2 >= 0 then
								txState["timer2"] = tTimer2;
							end
						end
					end
				elseif VUHDO_BOUQUET_LAYER_TYPE_AURA == tValidatorEntry["type"] then
					tResultSlot = aLayerTemplate["auraResults"][tValidatorEntry["resultIdx"]];

					if tResultSlot["isActive"] then
						txState["active"] = true;
						txState["name"] = tResultSlot["name"];
						txState["level"] = aLayerTemplate["auraValidators"][tValidatorEntry["resultIdx"]]["index"];

						if tResultSlot["icon"] then
							txState["icon"] = tResultSlot["icon"];
						end

						tColor = tResultSlot["color"];

						if tColor then
							if not txState["isColorInit"] then
								twipe(txState["color"]);
								txState["isColorInit"] = true;
							end

							if tColor["useText"] then
								txState["color"]["useText"] = true;
								txState["color"]["TR"] = tColor["TR"];
								txState["color"]["TG"] = tColor["TG"];
								txState["color"]["TB"] = tColor["TB"];
								txState["color"]["TO"] = tColor["TO"];
							end

							if tColor["useBackground"] then
								txState["color"]["useBackground"] = true;
								txState["color"]["R"] = tColor["R"];
								txState["color"]["G"] = tColor["G"];
								txState["color"]["B"] = tColor["B"];
								txState["color"]["O"] = tColor["O"];
							end

							if tColor["useOpacity"] then
								txState["color"]["useOpacity"] = true;

								if tColor["TO"] ~= nil then
									txState["color"]["TO"] = (txState["color"]["TO"] or 1) * tColor["TO"];
								end

								if tColor["O"] ~= nil then
									txState["color"]["O"] = (txState["color"]["O"] or 1) * tColor["O"];
								end
							end

							txState["color"]["isDefault"] = tColor["isDefault"];
						end

						tCounter = tResultSlot["counter"] or 0;

						if issecretvalue(tCounter) or tCounter >= 0 then
							txState["counter"] = tCounter;
						end

						tTimer = tResultSlot["timer"] or 0;
						tDuration = tResultSlot["duration"] or 0;

						if (issecretvalue(tDuration) or tDuration >= 0) and (issecretvalue(tTimer) or tTimer >= 0) then
							txState["timer"] = tTimer;
							txState["duration"] = tDuration;
						end

						txState["isAliveTime"] = tResultSlot["isAliveTime"] or false;
					end
				elseif VUHDO_BOUQUET_LAYER_TYPE_CURVE == tValidatorEntry["type"] then
					tResultSlot = aLayerTemplate["curveResults"][tValidatorEntry["resultIdx"]];

					if tResultSlot["isActive"] then
						txState["active"] = true;

						txState["timer"] = tResultSlot["timer"] or 0;
						txState["duration"] = tResultSlot["duration"] or 0;
						txState["timer2"] = tResultSlot["timer2"] or 0;
					end
				elseif VUHDO_BOUQUET_LAYER_TYPE_DISPEL == tValidatorEntry["type"] then
					if aLayerTemplate["dispelResults"][tValidatorEntry["resultIdx"]]["isActive"] then
						txState["active"] = true;
					end
				elseif VUHDO_BOUQUET_LAYER_TYPE_SPRITECELL == tValidatorEntry["type"] then
					tResultSlot = aLayerTemplate["spriteCellResults"][tValidatorEntry["resultIdx"]];

					if tResultSlot["isActive"] then
						txState["active"] = true;
						txState["icon"] = tResultSlot["icon"];
					end
				end
			end

			if aLayerTemplate["hasBools"] and not aLayerTemplate["hasCurves"] and not aLayerTemplate["hasDispels"]
				and not aLayerTemplate["hasNonSecrets"] and not aLayerTemplate["hasAuras"] then
				txState["active"] = true;
			end
		end

		return;

	end
end



do
	--
	local tInfos;
	local tName;
	local tSpecial;
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tSourceType;
	local tUnitHot;
	local tUnitHotInfo;
	local tNow;
	local tTimer2;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tColor;
	local tFactor;
	local tMaxColor;
	local tWorkingColor = { };
	function VUHDO_evaluateBouquetNonSecret(aUnit, aInfo, aBouquet, aAnzInfos)

		for tCnt = aAnzInfos, 1, -1  do
			tInfos = aBouquet[tCnt];
			tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tInfos["name"]];

			if tSpecial then
				tName = nil;

				tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2, tClipL, tClipR, tClipT, tClipB = tSpecial["validator"](aInfo, tInfos);

				if tIsActive then
					if tInfos["icon"] ~= 1 then	tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2]; end

					if not tColor then
						if 3 == tSpecial["custom_type"] then
							tColor, tMaxColor = VUHDO_getBouquetStatusBarColor(tInfos, aInfo, tTimer, tDuration);
						end

						if not tColor then
							tColor = tInfos["color"]; -- VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR
						end
					elseif 4 == tSpecial["custom_type"] then -- VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS
						tMaxColor = nil;

						tColor = VUHDO_copyColorTo(tColor, tWorkingColor);
						tFactor = tInfos["custom"]["bright"];

						if tColor["useBackground"] then
							tColor["R"], tColor["G"], tColor["B"] = tColor["R"] * tFactor, tColor["G"] * tFactor, tColor["B"] * tFactor;
						end

						if tColor["useText"] then
							tColor["TR"], tColor["TG"], tColor["TB"] = tColor["TR"] * tFactor, tColor["TG"] * tFactor, tColor["TB"] * tFactor;
						end
					else
						tMaxColor = nil;
					end

					if tColor["useText"] then
						tColor["useText"] = tInfos["color"]["useText"];
					end

					if tColor["useBackground"] then
						tColor["useBackground"] = tInfos["color"]["useBackground"];
					end

					if tColor["useOpacity"] then
						tColor["useOpacity"] = tInfos["color"]["useOpacity"];
					end
				end
			else
				tName = tInfos["name"];

				tIsActive = false;
				tSourceType = 0;

				if tInfos["mine"] and tInfos["others"] then
					tSourceType = VUHDO_UNIT_HOT_TYPE_BOTH;
				elseif tInfos["mine"] then
					tSourceType = VUHDO_UNIT_HOT_TYPE_MINE;
				elseif tInfos["others"] then
					tSourceType = VUHDO_UNIT_HOT_TYPE_OTHERS;
				end

				if tSourceType > 0 then
					tUnitHot, _ = VUHDO_getUnitHot(aUnit, tName, tSourceType);

					if tUnitHot and tUnitHot["auraInstanceId"] then
						-- tUnitHotInfo: aura icon, expiration, stacks, duration, isMine, name, spell ID
						tUnitHotInfo = VUHDO_getUnitHotInfo(aUnit, tUnitHot["auraInstanceId"]);

						if tUnitHotInfo then
							tIsActive = true;

							txState["activeAuras"] = txState["activeAuras"] + 1;

							tNow = GetTime();

							if tInfos["alive"] then
								tTimer = tNow - tUnitHotInfo[2] + (tUnitHotInfo[4] or 0);
							else
								tTimer = tUnitHotInfo[2] - tNow;
							end

							tIcon, tCounter, tDuration = tUnitHotInfo[1], tUnitHotInfo[3], tUnitHotInfo[4];

							if tTimer then
								tTimer = floor(tTimer * 10) * 0.1;
							end

							tColor = tInfos["color"];

							if tInfos["icon"] ~= 1 then
								tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2];
								tColor["isDefault"] = false;
							else
								tColor["isDefault"] = true;
							end
						end
					end
				end

				tTimer2, tClipL, tClipR, tClipT, tClipB = nil, nil, nil, nil, nil;
			end

			if tIsActive then
				txState["active"] = true;
				txState["name"] = tName;
				txState["level"] = tCnt;

				if tInfos["icon"] ~= 1 then
					tIcon = VUHDO_CUSTOM_ICONS[tInfos["icon"]][2];
					txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"] = nil, nil, nil, nil;
				elseif tIcon ~= nil then
					txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"] = tClipL, tClipR, tClipT, tClipB;
				end

				if tIcon then
					txState["icon"] = tIcon;
				end

				if tColor then
					if not txState["isColorInit"] then
						twipe(txState["color"]);
						txState["isColorInit"] = true;
					end

					if tColor["useText"] then
						txState["color"]["useText"], txState["color"]["TR"], txState["color"]["TG"], txState["color"]["TB"], txState["color"]["TO"] = true, tColor["TR"], tColor["TG"], tColor["TB"], tColor["TO"];
					end

					if tColor["useBackground"] then
						txState["color"]["useBackground"], txState["color"]["R"], txState["color"]["G"], txState["color"]["B"], txState["color"]["O"] = true, tColor["R"], tColor["G"], tColor["B"], tColor["O"];
					end

					if tColor["useOpacity"] then
						txState["color"]["useOpacity"] = true;

						if tColor["TO"] ~= nil then
							txState["color"]["TO"] = (txState["color"]["TO"] or 1) * tColor["TO"];
						end

						if tColor["O"] ~= nil then
							txState["color"]["O"] = (txState["color"]["O"] or 1) * tColor["O"];
						end
					end

					txState["color"]["isDefault"] = tColor["isDefault"];
					txState["color"]["noStacksColor"] = tColor["noStacksColor"];
					txState["color"]["useSlotColor"] = tColor["useSlotColor"];

					if tMaxColor then
						if not txState["isMaxColorInit"] then
							twipe(txState["maxColor"]);
							txState["isMaxColorInit"] = true;
						end

						if tMaxColor["useText"] then
							txState["maxColor"]["useText"], txState["maxColor"]["TR"], txState["maxColor"]["TG"], txState["maxColor"]["TB"], txState["maxColor"]["TO"] =
								true, tMaxColor["TR"], tMaxColor["TG"], tMaxColor["TB"], tMaxColor["TO"];
						end

						if tMaxColor["useBackground"] then
							txState["maxColor"]["useBackground"], txState["maxColor"]["R"], txState["maxColor"]["G"], txState["maxColor"]["B"], txState["maxColor"]["O"] =
								true, tMaxColor["R"], tMaxColor["G"], tMaxColor["B"], tMaxColor["O"];
						end

						if tMaxColor["useOpacity"] then
							txState["maxColor"]["useOpacity"] = true;

							if tMaxColor["TO"] ~= nil then
								txState["maxColor"]["TO"] = (txState["maxColor"]["TO"] or 1) * tMaxColor["TO"];
							end

							if tMaxColor["O"] ~= nil then
								txState["maxColor"]["O"] = (txState["maxColor"]["O"] or 1) * tMaxColor["O"];
							end
						end
					else
						txState["isMaxColorInit"] = false;
					end
				else
					txState["isColorInit"] = false;
					txState["isMaxColorInit"] = false;
				end

				tCounter = tCounter or 0;

				if issecretvalue(tCounter) or tCounter >= 0 then
					txState["counter"] = tCounter;
				end

				tTimer, tTimer2, tDuration = tTimer or 0, tTimer2 or 0, tDuration or 0;

				if issecretvalue(tDuration) or tDuration >= 0 then
					if issecretvalue(tTimer) or tTimer >= 0 then
						txState["timer"], txState["duration"] = tTimer, tDuration;
					end

					if issecretvalue(tTimer2) or tTimer2 >= 0 then
						txState["timer2"] = tTimer2;
					end
				end
			end
		end

		return;

	end
end



do
	--
	local tEmptyInfo = { };
	local tUnit;
	local tInfo;
	local tBouquet;
	local tAnzInfos;
	local tLayerTemplate;
	local tHasSecretResults;
	local tEvalColorHash;
	function VUHDO_evaluateBouquet(aUnit, aBouquetName, anInfo)

		tUnit = (VUHDO_RAID[aUnit] or tEmptyInfo)["isVehicle"] and VUHDO_RAID[aUnit]["petUnit"] or aUnit;
		tInfo = anInfo or VUHDO_RAID[tUnit];

		if not tInfo then
			return false, nil, nil, nil, nil, nil, nil, VUHDO_hasBouquetChanged(aUnit, aBouquetName, false), 0, 0, nil, nil, nil, nil, nil, nil, nil;
		end

		txState["active"] = false;
		txState["icon"] = nil;
		txState["isColorInit"] = false;
		txState["name"] = nil;

		txState["isMaxColorInit"] = false;
		txState["counter"] = 0;
		txState["timer"] = 0;
		txState["duration"] = 0;
		txState["timer2"] = 0;
		txState["level"] = 0;
		txState["activeAuras"] = 0;
		txState["isAliveTime"] = false;

		txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"] = nil, nil, nil, nil;

		tBouquet = VUHDO_BOUQUETS["STORED"][aBouquetName];

		if not tBouquet or type(tBouquet) ~= "table" then
			return false, nil, nil, nil, nil, nil, nil, VUHDO_hasBouquetChanged(aUnit, aBouquetName, false), 0, 0, nil, nil, nil, nil, nil, nil, nil;
		end

		tAnzInfos = #tBouquet;
		tLayerTemplate = nil;

		if sSecretsEnabled and not VUHDO_isConfigDemoUsers() then
			tLayerTemplate = sBouquetLayerTemplates[aBouquetName];

			VUHDO_evaluateBouquetSecret(tUnit, aBouquetName, tInfo, tBouquet, tAnzInfos, tLayerTemplate);
		else
			VUHDO_evaluateBouquetNonSecret(tUnit, tInfo, tBouquet, tAnzInfos);
		end

		tHasSecretResults = (tLayerTemplate and (tLayerTemplate["hasCurves"] or tLayerTemplate["hasBools"] or tLayerTemplate["hasDispels"] or tLayerTemplate["hasSecretValues"]))
			or issecretvalue(txState["icon"]) or issecretvalue(txState["timer"]) or issecretvalue(txState["counter"]) or issecretvalue(txState["duration"]);

		if txState["active"] then
			if not txState["isColorInit"] then
				txState["color"]["R"], txState["color"]["G"], txState["color"]["B"], txState["color"]["O"], txState["color"]["TR"], txState["color"]["TG"], txState["color"]["TB"], txState["color"]["TO"],
					txState["color"]["useText"], txState["color"]["useBackground"], txState["color"]["useOpacity"] = 1, 1, 1, 1, 1, 1, 1, 1, true, true, true;
			elseif not txState["color"]["useOpacity"] then
				txState["color"]["TO"], txState["color"]["O"] = 1, 1;
			end

			if txState["isMaxColorInit"] and not txState["maxColor"]["useOpacity"] then
				txState["maxColor"]["TO"], txState["maxColor"]["O"] = 1, 1;
			end

			tEvalColorHash = VUHDO_getColorHash(txState["color"]);

			if txState["isMaxColorInit"] then
				tEvalColorHash = tEvalColorHash + VUHDO_getColorHash(txState["maxColor"]) * 100000;
			end

			return true, txState["icon"], txState["timer"], txState["counter"], txState["duration"], txState["color"], txState["name"],
				tHasSecretResults or VUHDO_hasBouquetChanged(aUnit, aBouquetName, true, txState["icon"], txState["timer"], txState["counter"], txState["duration"], tEvalColorHash, txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"]),
				tAnzInfos - txState["level"], txState["timer2"], txState["clipL"], txState["clipR"], txState["clipT"], txState["clipB"], txState["isMaxColorInit"] and txState["maxColor"] or nil,
				tLayerTemplate, txState["isAliveTime"];
	else
		return false, nil, nil, nil, nil, nil, nil, tHasSecretResults or VUHDO_hasBouquetChanged(aUnit, aBouquetName, false), 0, 0,
			nil, nil, nil, nil, nil, tLayerTemplate, false;
	end

	end
end




--
do
	--
	local tBouquet;
	local tName;
	local function VUHDO_activateBuffsInScanner(aBouquetName)

		tBouquet = VUHDO_BOUQUETS["STORED"][aBouquetName];

		for _, tInfos in pairs(tBouquet) do
			tName = tInfos["name"];
			if not VUHDO_strempty(tName) and not VUHDO_BOUQUET_BUFFS_SPECIAL[tName] then
				VUHDO_ACTIVE_HOTS[tName] = true;

				if tInfos["others"] then VUHDO_ACTIVE_HOTS_OTHERS[tName] = true; end
			end
		end

		return;

	end



	--
	local function VUHDO_hasCyclic(aBouquetName)

		for _, tItem in pairs(VUHDO_BOUQUETS["STORED"][aBouquetName]) do
			if not VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]] or VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]]["updateCyclic"] then
				return true;
			end
		end

		return false;

	end



	--
	function VUHDO_registerForBouquet(aBouquetName, anOwnerName, aFunction)

		if VUHDO_strempty(aBouquetName) or VUHDO_strempty(anOwnerName) then
			return;
		elseif not VUHDO_BOUQUETS["STORED"][aBouquetName] then
			VUHDO_Msg(format(VUHDO_I18N_ERR_NO_BOUQUET, anOwnerName, aBouquetName), 1, 0.4, 0.4);

			return;
		end

		VUHDO_BOUQUETS["STORED"][aBouquetName] = VUHDO_decompressIfCompressed(VUHDO_BOUQUETS["STORED"][aBouquetName]);

		VUHDO_buildCurvesForBouquet(aBouquetName);

		VUHDO_REGISTERED_BOUQUETS[aBouquetName][anOwnerName] = aFunction;

		if not VUHDO_REGISTERED_BOUQUET_INDICATORS[anOwnerName] then
			VUHDO_REGISTERED_BOUQUET_INDICATORS[anOwnerName] = { };
		end

		VUHDO_REGISTERED_BOUQUET_INDICATORS[anOwnerName][aBouquetName] = aFunction;

		VUHDO_activateBuffsInScanner(aBouquetName);
		VUHDO_activateAurasFromBouquet(aBouquetName);

		for tUnit, _ in pairs(VUHDO_RAID) do
			aFunction(tUnit, false, nil, 0, 0, 0, nil, nil, aBouquetName);
		end

		if VUHDO_hasCyclic(aBouquetName) then
			VUHDO_CYCLIC_BOUQUETS[aBouquetName] = true;
		end

		return;

	end



	--
	function VUHDO_registerForBouquetUnique(aBouquetName, anOwnerName, aFunction, anAlreadyRegistered)

		if not anAlreadyRegistered then
			return;
		end

		if not VUHDO_strempty(aBouquetName) and not VUHDO_strempty(anOwnerName) and not anAlreadyRegistered[aBouquetName .. anOwnerName] then
			VUHDO_registerForBouquet(aBouquetName, anOwnerName, aFunction);

			anAlreadyRegistered[aBouquetName .. anOwnerName] = true;
		end

		return;

	end
end



do
	--
	local tSlotMappings;
	local tTier;
	local tSlotData;
	local tAnchorConfig;
	local tListSlots;
	local tMaxSlots;
	local tInfo;
	function VUHDO_listAuraGroupBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, anImpact, aTimer2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate, aIsAliveTime)

		tSlotMappings = VUHDO_AURA_LIST_BOUQUETS[aBouquetName];

		if not tSlotMappings then
			return;
		end

		tTier = VUHDO_UNIT_AURA_LIST_SLOTS[aUnit];

		if not tTier then
			return;
		end

		for _, tMapping in ipairs(tSlotMappings) do
			tTier = tTier[tMapping["panelNum"]];

			if tTier then
				tTier = tTier[tMapping["anchorKey"]];

				if tTier then
					tSlotData = tTier[tMapping["entryIndex"]];

					if not tSlotData then
						tSlotData = VUHDO_getSlotData();
						tTier[tMapping["entryIndex"]] = tSlotData;
					end

					tSlotData["icon"] = anIcon;

					if anIsActive and aDuration then
						if issecretvalue(aDuration) or issecretvalue(aTimer) then
							tSlotData["expirationTime"] = aTimer;
						elseif aDuration > 0 and aTimer then
							if aIsAliveTime then
								tSlotData["expirationTime"] = GetTime() - aTimer + aDuration;
							else
								tSlotData["expirationTime"] = GetTime() + aTimer;
							end
						else
							tSlotData["expirationTime"] = 0;
						end
					else
						tSlotData["expirationTime"] = 0;
					end

					tSlotData["stacks"] = aCounter;
					tSlotData["duration"] = aDuration;

					if aColor then
						VUHDO_copyColorTo(aColor, tSlotData["color"]);
					else
						twipe(tSlotData["color"]);
					end

					tInfo = VUHDO_RAID[aUnit];
					tSlotData["isActive"] = anIsActive and tInfo and tInfo["connected"] and not tInfo["dead"];

					tSlotData["name"] = aBuffName;
					tSlotData["entryType"] = 2;
					tSlotData["clipL"] = aClipL;
					tSlotData["clipR"] = aClipR;
					tSlotData["clipT"] = aClipT;
					tSlotData["clipB"] = aClipB;
					tSlotData["isAliveTime"] = aIsAliveTime or false;

					tAnchorConfig = VUHDO_PANEL_SETUP[tMapping["panelNum"]] and
						VUHDO_PANEL_SETUP[tMapping["panelNum"]]["AURA_ANCHORS"] and
						VUHDO_PANEL_SETUP[tMapping["panelNum"]]["AURA_ANCHORS"][tMapping["anchorKey"]];

					if tAnchorConfig then
						tSlotData["groupId"] = tAnchorConfig["groupId"];
						tSlotData["entryIndex"] = tMapping["entryIndex"];
					end
				end
			end

			tTier = VUHDO_UNIT_AURA_LIST_SLOTS[aUnit];
		end

		if aUnit and VUHDO_displayAurasAtAnchorFromCache then
			for _, tMapping in ipairs(tSlotMappings) do
				tAnchorConfig = VUHDO_PANEL_SETUP[tMapping["panelNum"]] and
					VUHDO_PANEL_SETUP[tMapping["panelNum"]]["AURA_ANCHORS"] and
					VUHDO_PANEL_SETUP[tMapping["panelNum"]]["AURA_ANCHORS"][tMapping["anchorKey"]];

				if tAnchorConfig and tAnchorConfig["enabled"] ~= false then
					tListSlots = VUHDO_UNIT_AURA_LIST_SLOTS[aUnit] and
						VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tMapping["panelNum"]] and
						VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][tMapping["panelNum"]][tMapping["anchorKey"]];
					tMaxSlots = tAnchorConfig["maxDisplay"] or 5;

					VUHDO_displayAurasAtAnchorFromCache(aUnit, tMapping["panelNum"], tMapping["anchorKey"],
						tAnchorConfig, tListSlots, tMaxSlots);
				end
			end
		end

		return;

	end



	--
	function VUHDO_listAuraGroupBouquetColorOnlyCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, anImpact, aTimer2, aClipL, aClipR, aClipT, aClipB, aMaxColor, aLayerTemplate)

		if not aBouquetName then
			return;
		end

		if not VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] then
			VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] = sUnitBouquetActivePool:get();
		end

		VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit][aBouquetName] = anIsActive;

		return;

	end
end



--
function VUHDO_clearUnitBouquetActiveCache(aUnit)

	if not aUnit then
		return;
	end

	if VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] then
		sUnitBouquetActivePool:release(VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit]);
		VUHDO_UNIT_AURA_BOUQUET_ACTIVE[aUnit] = nil;
	end

	return;

end



do
	--
	local tAnchors;
	local tGroup;
	local tBouquetName;
	local tGroupsWithEnabledAnchor;
	local tEffectiveColorType;
	local tConfigGroups;
	function VUHDO_registerListGroupBouquetEntries(anAlreadyRegistered)

		twipe(sGroupsWithEnabledAnchorReusable);
		tGroupsWithEnabledAnchor = sGroupsWithEnabledAnchorReusable;

		for tPanelNum = 1, VUHDO_MAX_PANELS do
			tAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

			if tAnchors then
				for tKey, tVal in pairs(tAnchors) do
					if tVal["enabled"] ~= false and tVal["groupId"] then
						tGroupsWithEnabledAnchor[tVal["groupId"]] = true;
					end

					tGroup = VUHDO_getAuraGroupRaw(tVal["groupId"]);

					if tGroup and (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST and tGroup["entries"] then
						for tEntryIndex, tEntry in ipairs(tGroup["entries"]) do
							if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
								tBouquetName = tEntry["value"];

								VUHDO_registerForBouquetUnique(
									tBouquetName,
									"ListAuraGroup",
									VUHDO_listAuraGroupBouquetCallback,
									anAlreadyRegistered
								);

								if not VUHDO_AURA_LIST_BOUQUETS[tBouquetName] then
									VUHDO_AURA_LIST_BOUQUETS[tBouquetName] = { };
								end

								tinsert(VUHDO_AURA_LIST_BOUQUETS[tBouquetName], {
									["panelNum"] = tPanelNum,
									["anchorKey"] = tKey,
									["entryIndex"] = tEntryIndex,
								});
							end
						end
					end
				end
			end
		end

		tConfigGroups = VUHDO_CONFIG and VUHDO_CONFIG["AURA_GROUPS"] or { };

		for tGroupId, tGroup in pairs(tConfigGroups) do
			tEffectiveColorType = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

			if tEffectiveColorType >= VUHDO_AURA_GROUP_COLOR_DISPEL and tGroup["enabled"] ~= false and not tGroupsWithEnabledAnchor[tGroupId] then
				if (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST and tGroup["entries"] then
					for tEntryIndex, tEntry in ipairs(tGroup["entries"]) do
						if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
							tBouquetName = tEntry["value"];

							VUHDO_registerForBouquetUnique(
								tBouquetName,
								"ListAuraGroupColorOnly",
								VUHDO_listAuraGroupBouquetColorOnlyCallback,
								anAlreadyRegistered
							);

							VUHDO_LIST_GROUP_COLOR_BOUQUETS[tBouquetName] = true;
						end
					end
				end
			end
		end

		for tGroupId, tGroup in pairs(VUHDO_DEFAULT_AURA_GROUPS or { }) do
			if (not tGroup["playerClassRequired"] or tGroup["playerClassRequired"] == VUHDO_PLAYER_CLASS) and
				not (tConfigGroups[tGroupId]) and
				tGroup["enabled"] ~= false and
				not (VUHDO_CONFIG and VUHDO_CONFIG["AURA_GROUP_DISABLED"] and VUHDO_CONFIG["AURA_GROUP_DISABLED"][tGroupId]) and
				not (VUHDO_DEFAULT_AURA_GROUPS[tGroupId] and VUHDO_DEFAULT_AURA_GROUPS[tGroupId]["enabled"] == false) and
				not tGroupsWithEnabledAnchor[tGroupId] then
				tEffectiveColorType = tGroup["colorType"] or ((tGroup["canColorBar"] or tGroup["canColorText"]) and VUHDO_AURA_GROUP_COLOR_DISPEL or VUHDO_AURA_GROUP_COLOR_OFF);

				if tEffectiveColorType >= VUHDO_AURA_GROUP_COLOR_DISPEL and (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST and tGroup["entries"] then
					for tEntryIndex, tEntry in ipairs(tGroup["entries"]) do
						if tEntry["entryType"] == VUHDO_AURA_LIST_ENTRY_BOUQUET then
							tBouquetName = tEntry["value"];

							VUHDO_registerForBouquetUnique(
								tBouquetName,
								"ListAuraGroupColorOnly",
								VUHDO_listAuraGroupBouquetColorOnlyCallback,
								anAlreadyRegistered
							);

							VUHDO_LIST_GROUP_COLOR_BOUQUETS[tBouquetName] = true;
						end
					end
				end
			end
		end

		return;

	end



	--
	local tHotSlots;
	local tAlreadyRegistered = { };
	function VUHDO_registerAllBouquets(aDoCompress)

		twipe(VUHDO_REGISTERED_BOUQUETS);
		twipe(VUHDO_CYCLIC_BOUQUETS);
		twipe(VUHDO_REGISTERED_BOUQUET_INDICATORS);
		twipe(VUHDO_AURA_LIST_BOUQUETS);
		twipe(VUHDO_LIST_GROUP_COLOR_BOUQUETS);

		for tUnit, _ in pairs(VUHDO_RAID or { }) do
			VUHDO_clearUnitBouquetActiveCache(tUnit);
		end

		if not VUHDO_BOUQUETS["STORED"] then
			return;
		end

		if aDoCompress then
			VUHDO_compressAllBouquets();
		end

		VUHDO_initSecretColorConstants();
		VUHDO_buildAllBouquetCurves();

		twipe(tAlreadyRegistered);

		for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
			if VUHDO_PANEL_MODELS[tPanelNum] then
				-- Hot Icons+Bars
				if not sSecretsEnabled then
					tHotSlots = VUHDO_PANEL_SETUP[tPanelNum]["HOTS"]["SLOTS"];

					for _, tHotName in pairs(tHotSlots) do
						if tHotName and "BOUQUET_" == strsub(tHotName, 1, 8) then
							VUHDO_registerForBouquetUnique(
								strsub(tHotName, 9),
								"HoT",
								VUHDO_hotBouquetCallback,
								tAlreadyRegistered
							);
						end
					end
				end

				-- Bar (=Outer) Border
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["BAR_BORDER"],
					"Outer Border",
					VUHDO_barBorderBouquetCallback,
					tAlreadyRegistered
				);

				-- Cluster (=Inner) Border
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["CLUSTER_BORDER"],
					"Inner Border",
					VUHDO_clusterBorderBouquetCallback,
					tAlreadyRegistered
				);

				-- Swiftmend Indicator
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SWIFTMEND_INDICATOR"],
					"Special Dot",
					VUHDO_swiftmendIndicatorBouquetCallback,
					tAlreadyRegistered
				);

				-- Aggro Line
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["AGGRO_BAR"],
					"Aggro Bar",
					VUHDO_aggroBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Mouseover Highlighter
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["MOUSEOVER_HIGHLIGHT"],
					"Mouseover Highlight",
					VUHDO_highlighterBouquetCallback,
					tAlreadyRegistered
				);

				-- Threat Marks
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["THREAT_MARK"],
					"Threat Indicators",
					VUHDO_threatIndicatorsBouquetCallback,
					tAlreadyRegistered
				);

				-- Threat Bar
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["THREAT_BAR"],
					"THREAT_BAR",
					VUHDO_threatBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Mana Bar
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["MANA_BAR"],
					"MANA_BAR",
					VUHDO_manaBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Background Bar
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["BACKGROUND_BAR"],
					"Background Bar",
					VUHDO_backgroundBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Health Bar
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["HEALTH_BAR"],
					"Health Bar",
					VUHDO_healthBarBouquetCallback,
					tAlreadyRegistered
				);

				-- Side bar left
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SIDE_LEFT"],
					"SIDE_LEFT",
					VUHDO_sideBarLeftBouquetCallback,
					tAlreadyRegistered
				);

				-- Side bar right
				VUHDO_registerForBouquetUnique(
					VUHDO_INDICATOR_CONFIG[tPanelNum]["BOUQUETS"]["SIDE_RIGHT"],
					"SIDE_RIGHT",
					VUHDO_sideBarRightBouquetCallback,
					tAlreadyRegistered
				);
			end
		end

		VUHDO_registerListGroupBouquetEntries(tAlreadyRegistered);

		for _, tBouquetName in pairs(VUHDO_CUSTOM_BOUQUETS) do
			VUHDO_BOUQUETS["STORED"][tBouquetName] = VUHDO_decompressIfCompressed(VUHDO_BOUQUETS["STORED"][tBouquetName]);

			VUHDO_buildCurvesForBouquet(tBouquetName);
		end

		VUHDO_releaseAndWipeLastEvaluatedBouquets();

		VUHDO_updateGlobalToggles();
		VUHDO_buildEventInterestCache();
		VUHDO_initAllEventBouquets();

		VUHDO_rebuildActiveAuraCaches();

		return;

	end
end



--
local VUHDO_EVENT_BOUQUETS = { };
setmetatable(VUHDO_EVENT_BOUQUETS, VUHDO_META_NEW_ARRAY);

--
local VUHDO_EVENT_INTEREST_CACHE = { };
setmetatable(VUHDO_EVENT_INTEREST_CACHE, VUHDO_META_NEW_ARRAY);

for tEventType = 1, 50 do
	VUHDO_EVENT_INTEREST_CACHE[tEventType] = { };
end



--
local tName;
local function VUHDO_isBouquetInterestedInEvent(aBouquetName, anEventType)

	if not VUHDO_EVENT_BOUQUETS[aBouquetName][anEventType] then
		VUHDO_EVENT_BOUQUETS[aBouquetName][anEventType] = 0;

		for _, tItem in pairs(VUHDO_BOUQUETS["STORED"][aBouquetName]) do
			tName = tItem["name"];

			if VUHDO_BOUQUET_BUFFS_SPECIAL[tName] then
				for _, tInterest in pairs(VUHDO_BOUQUET_BUFFS_SPECIAL[tName]["interests"]) do
					if tInterest == anEventType then
						VUHDO_EVENT_BOUQUETS[aBouquetName][anEventType] = 1;

						break;
					end
				end
			end
		end
	end

	return 1 == VUHDO_EVENT_BOUQUETS[aBouquetName][anEventType] or 1 == anEventType; -- VUHDO_UPDATE_ALL

end



--
function VUHDO_buildEventInterestCache()

	for tEventType = 1, 50 do
		twipe(VUHDO_EVENT_INTEREST_CACHE[tEventType]);
	end

	for tBouquetName, _ in pairs(VUHDO_REGISTERED_BOUQUETS) do
		for tEventType = 1, 50 do
			if VUHDO_isBouquetInterestedInEvent(tBouquetName, tEventType) then
				VUHDO_EVENT_INTEREST_CACHE[tEventType][tBouquetName] = true;
			end
		end
	end

	return;

end



do
	--
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tColor;
	local tBuffName;
	local tHasChanged;
	local tImpact;
	local tTimer2;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tMaxColor;
	local tLayerTemplate;
	local tIsAliveTime;
	function VUHDO_updateEventBouquet(aUnit, aBouquetName, anEventType)

		tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName,
			tHasChanged, tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime
			= VUHDO_evaluateBouquet(aUnit, aBouquetName, nil);

		if not tHasChanged then
			return;
		end

		if tHasChanged or tIsActive then
			for _, tDelegate in pairs(VUHDO_REGISTERED_BOUQUETS[aBouquetName]) do
				tDelegate(aUnit, tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, aBouquetName,
					tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime);
			end

			VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] = true;

			VUHDO_updateAllTextIndicatorsForEvent(aUnit, anEventType, aBouquetName, tIsActive);
		elseif VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] then
			for _, tDelegate in pairs(VUHDO_REGISTERED_BOUQUETS[aBouquetName]) do
				tDelegate(aUnit, tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, aBouquetName,
					tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime);
			end

			VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] = false;

			VUHDO_updateAllTextIndicatorsForEvent(aUnit, anEventType, aBouquetName, false);
		end

		return;

	end



	--
	function VUHDO_invokeCustomBouquet(aButton, aUnit, anInfo, aBouquetName, aDelegate)

		tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName,
			_, tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime
			= VUHDO_evaluateBouquet(aUnit, aBouquetName, anInfo);

		if tIsActive then
			aDelegate(aButton, aUnit, tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, aBouquetName,
				tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime);
			VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] = true;
		elseif VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] then
			aDelegate(aButton, aUnit, tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, aBouquetName,
				tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime);
			VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] = false;
		end

		return;

	end
end



--
local function VUHDO_isAnyBouquetInterestedIn(anUpdateMode)

	for tName, _ in pairs(VUHDO_REGISTERED_BOUQUETS) do
		if VUHDO_isBouquetInterestedInEvent(tName, anUpdateMode) then return true; end
	end

	return false;

end



--
local tInfo;
local tInterestedBouquets;
function VUHDO_updateBouquetsForEvent(aUnit, anEventType)

	tInfo = VUHDO_RAID[aUnit];

	tInterestedBouquets = VUHDO_EVENT_INTEREST_CACHE[anEventType];

	if tInfo then
		if tInterestedBouquets then
			for tName, _ in pairs(tInterestedBouquets) do
				if VUHDO_LIST_GROUP_COLOR_BOUQUETS[tName] then
					VUHDO_updateEventBouquet(aUnit, tName, anEventType);
				end
			end
		else
			for tName, _ in pairs(VUHDO_LIST_GROUP_COLOR_BOUQUETS) do
				if VUHDO_isBouquetInterestedInEvent(tName, anEventType) then
					VUHDO_updateEventBouquet(aUnit, tName, anEventType);
				end
			end
		end
	end

	if tInterestedBouquets then
		for tName, _ in pairs(tInterestedBouquets) do
			if not VUHDO_LIST_GROUP_COLOR_BOUQUETS[tName] then
				if tInfo then
					VUHDO_updateEventBouquet(aUnit, tName, anEventType);
				elseif aUnit then
					for _, tDelegate in pairs(VUHDO_REGISTERED_BOUQUETS[tName]) do
						if VUHDO_isBouquetInterestedInEvent(tName, VUHDO_UPDATE_DC) then
							tDelegate(aUnit, true, nil, 100, 0, 100, VUHDO_PANEL_SETUP["BAR_COLORS"]["OFFLINE"], nil, tName, 0);
						end
					end
				end
			end
		end
	else
		for tName, _ in pairs(VUHDO_REGISTERED_BOUQUETS) do
			if not VUHDO_LIST_GROUP_COLOR_BOUQUETS[tName] and VUHDO_isBouquetInterestedInEvent(tName, anEventType) then
				if tInfo then
					VUHDO_updateEventBouquet(aUnit, tName, anEventType);
				elseif aUnit then
					for _, tDelegate in pairs(VUHDO_REGISTERED_BOUQUETS[tName]) do
						if VUHDO_isBouquetInterestedInEvent(tName, VUHDO_UPDATE_DC) then
							tDelegate(aUnit, true, nil, 100, 0, 100, VUHDO_PANEL_SETUP["BAR_COLORS"]["OFFLINE"], nil, tName, 0);
						end
					end
				end
			end
		end
	end

	VUHDO_updateAllTextIndicatorsForEvent(aUnit, anEventType);

	return;

end
local VUHDO_updateBouquetsForEvent = VUHDO_updateBouquetsForEvent;



--
function VUHDO_initAllEventBouquets()

	VUHDO_releaseAndWipeLastEvaluatedBouquets();

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateBouquetsForEvent(tUnit, 1); -- VUHDO_UPDATE_ALL
	end

	VUHDO_updateBouquetsForEvent("focus", 19); -- VUHDO_UPDATE_DC
	VUHDO_updateBouquetsForEvent("target", 19); -- VUHDO_UPDATE_DC

	VUHDO_registerAllTextIndicators();

	return;

end



--
function VUHDO_deferInitAllEventBouquetsDelegate()

	VUHDO_releaseAndWipeLastEvaluatedBouquets();

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_deferUpdateBouquetsForEvent(tUnit, 1); -- VUHDO_UPDATE_ALL
	end

	VUHDO_deferUpdateBouquetsForEvent("focus", 19); -- VUHDO_UPDATE_DC
	VUHDO_deferUpdateBouquetsForEvent("target", 19); -- VUHDO_UPDATE_DC

	VUHDO_registerAllTextIndicators();

	return;

end



--
function VUHDO_deferInitAllEventBouquets(aPriority)

	VUHDO_deferTask(VUHDO_DEFER_INIT_ALL_EVENT_BOUQUETS, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH);

	return;

end



--
local tUnitToInit;
function VUHDO_initEventBouquetsFor(...)

	for tCnt = 1, select('#', ...) do
		tUnitToInit = select(tCnt, ...);

		for _, tAllBouquetUnits in pairs(VUHDO_LAST_EVALUATED_BOUQUETS) do
			for tUnit, tAllResults in pairs(tAllBouquetUnits) do
				if tUnit == tUnitToInit then
					tAllResults[1] = nil; -- Change "active" flag to enforce re-evaluation
				end
			end
		end

		VUHDO_updateBouquetsForEvent(tUnitToInit, 1); -- VUHDO_UPDATE_ALL
	end

	return;

end



do
	--
	local tIsActive;
	local tIcon;
	local tTimer;
	local tCounter;
	local tDuration;
	local tColor;
	local tBuffName;
	local tHasChanged;
	local tImpact;
	local tTimer2;
	local tClipL;
	local tClipR;
	local tClipT;
	local tClipB;
	local tMaxColor;
	local tLayerTemplate;
	local tIsAliveTime;
	local tAllListeners;
	local tDestArray;
	function VUHDO_updateUnitCyclicBouquet(aUnit, aBouquetName)

		if not aUnit or not aBouquetName then
			return;
		end

		tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, tHasChanged,
			tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime = VUHDO_evaluateBouquet(aUnit, aBouquetName, nil);

		if tHasChanged and (tIsActive or VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName]) then
			tAllListeners = VUHDO_REGISTERED_BOUQUETS[aBouquetName];

			for _, tDelegate in pairs(tAllListeners) do
				tDelegate(aUnit, tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tBuffName, aBouquetName,
					tImpact, tTimer2, tClipL, tClipR, tClipT, tClipB, tMaxColor, tLayerTemplate, tIsAliveTime);
			end

			VUHDO_ACTIVE_BOUQUETS[aUnit][aBouquetName] = tIsActive;
		end

		return;

	end



	--
	function VUHDO_updateAllCyclicBouquets(anIsPlayerOnly)

		tDestArray = anIsPlayerOnly and sPlayerArray or VUHDO_RAID;

		for tBouquetName, _ in pairs(VUHDO_CYCLIC_BOUQUETS) do
			for tUnit, _ in pairs(tDestArray) do
				VUHDO_updateUnitCyclicBouquet(tUnit, tBouquetName);
			end
		end

		return;

	end



	--
	function VUHDO_deferUpdateAllCyclicBouquets(anIsPlayerOnly, aPriority)

		tDestArray = anIsPlayerOnly and sPlayerArray or VUHDO_RAID;

		if not tDestArray then
			return;
		end

		for tBouquetName, _ in pairs(VUHDO_CYCLIC_BOUQUETS) do
			for tUnit, _ in pairs(tDestArray) do
				VUHDO_deferTask(VUHDO_DEFER_UPDATE_UNIT_CYCLIC_BOUQUET, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH, tUnit, tBouquetName);
			end
		end

		return;

	end
end



--
function VUHDO_bouqetsChanged()

	twipe(VUHDO_EVENT_BOUQUETS);

	for tEventType = 1, 50 do
		twipe(VUHDO_EVENT_INTEREST_CACHE[tEventType]);
	end

	VUHDO_initFromSpellbook();
	VUHDO_registerAllBouquets(false);

	return;

end



--
function VUHDO_isAnyoneInterestedIn(anUpdateMode)

	if (VUHDO_isAnyBouquetInterestedIn(anUpdateMode) or VUHDO_isAnyTextIndicatorInterestedIn(anUpdateMode)) then
		return true;
	else
		if 5 == anUpdateMode then -- VUHDO_UPDATE_RANGE
			return true;
		elseif 7 == anUpdateMode then -- VUHDO_UPDATE_AGGRO
			return VUHDO_CONFIG["THREAT"]["AGGRO_USE_TEXT"];
		elseif 16 == anUpdateMode then -- VUHDO_UPDATE_NUM_CLUSTER
			return VUHDO_getIsClusterSlotActive();
		elseif 22 == anUpdateMode then -- VUHDO_UPDATE_UNIT_TARGET
			for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
				if VUHDO_PANEL_MODELS[tCnt] then
					if (VUHDO_PANEL_SETUP[tCnt]["SCALING"]["showTarget"] or VUHDO_PANEL_SETUP[tCnt]["SCALING"]["showTot"]) then
						return true;
					end
				end
			end
		end

		return false;
	end

end



--
function VUHDO_getRegisteredBouquets()

	return VUHDO_REGISTERED_BOUQUETS;

end



--
function VUHDO_getActiveBouquets()

	return VUHDO_ACTIVE_BOUQUETS;

end



--
function VUHDO_getRegisteredBouquetIndicators(anIndicatorName)

	if anIndicatorName then
		return VUHDO_REGISTERED_BOUQUET_INDICATORS[anIndicatorName];
	else
		return VUHDO_REGISTERED_BOUQUET_INDICATORS;
	end

	return;

end