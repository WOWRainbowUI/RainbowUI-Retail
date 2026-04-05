local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local twipe = table.wipe;
local floor = math.floor;
local max = math.max;
local min = math.min;

local InCombatLockdown = InCombatLockdown;
local GetTime = GetTime;
local debugprofilestop = debugprofilestop;
local CreateFrame = CreateFrame;
local CreateFramePool = CreateFramePool;
local GetAuraDuration = C_UnitAuras and C_UnitAuras.GetAuraDuration;
local CreateDuration = C_DurationUtil and C_DurationUtil.CreateDuration;
local GetAuraApplicationDisplayCount = C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount;
local GetAuraDispelTypeColor = C_UnitAuras and C_UnitAuras.GetAuraDispelTypeColor;
local GetAuraDataByAuraInstanceID = C_UnitAuras and C_UnitAuras.GetAuraDataByAuraInstanceID;
local GetSpellAuraSecrecy = C_Secrets and C_Secrets.GetSpellAuraSecrecy;
local issecretvalue = issecretvalue;
local AbbreviateNumbers = AbbreviateNumbers;
local CreateCurve = C_CurveUtil and C_CurveUtil.CreateCurve;
local CreateColorCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve;
local CreateColor = CreateColor;
local format = string.format;

local VUHDO_PANEL_SETUP;
local VUHDO_CONFIG;
local VUHDO_RAID;
local VUHDO_AURA_IGNORE_LIST;
local VUHDO_BUTTON_CACHE;
local VUHDO_UNIT_AURA_CACHE;
local VUHDO_UNIT_AURA_SLOTS;
local VUHDO_UNIT_AURA_LIST_SLOTS;
local VUHDO_AURA_GROUP_TYPE_LIST;
local VUHDO_ATLAS_TEXTURES;
local VUHDO_STATUSBAR_LEFT_TO_RIGHT;
local VUHDO_STATUSBAR_RIGHT_TO_LEFT;
local VUHDO_STATUSBAR_BOTTOM_TO_TOP;
local VUHDO_STATUSBAR_TOP_TO_BOTTOM;

local VUHDO_LibCustomGlow;
local VUHDO_PixelUtil;
local VUHDO_UIFrameFlash;
local VUHDO_UIFrameFlashStop;

local VUHDO_safeSetAttribute;
local VUHDO_getUnitButtonsPanel;
local VUHDO_getHealthBar;
local VUHDO_getHealthBarWidth;
local VUHDO_getHealthBarHeight;
local VUHDO_customizeIconText;
local VUHDO_textColor;
local VUHDO_setLlcStatusBarTexture;
local VUHDO_setStatusBarOrientation;
local VUHDO_getClassColor;
local VUHDO_backColor;
local VUHDO_safeColorFromTable;
local VUHDO_resolveAuraTriState;
local VUHDO_getAuraGroup;
local VUHDO_getDispelCurveForUnit;
local VUHDO_getAnchorTriStateBool;
local VUHDO_getAllAuraGroups;
local VUHDO_setAnchorSlotAuraId;
local VUHDO_isPanelPopulated;

VUHDO_AURA_FRAMES = VUHDO_AURA_FRAMES or { };
local VUHDO_AURA_FRAMES = VUHDO_AURA_FRAMES;

local sAuraAnchorConfigVersion = 0;

local sEntrySettingsVersion = 0;

local sAnchorSettingsCache = {
	["showTooltip"] = { },
	["showClock"] = { },
	["fadeOnLow"] = { },
	["dispelBorder"] = { },
	["showTimer"] = { },
	["showStacks"] = { },
	["flashOnLow"] = { },
};

local sEntrySettingsCache = {
	["showTimer"] = { },
	["showStacks"] = { },
	["showClock"] = { },
	["fadeOnLow"] = { },
	["flashOnLow"] = { },
	["glowIcon"] = { },
	["colorIcon"] = { },
	["glowColor"] = { },
	["colorIconColor"] = { },
	["fadeThreshold"] = { },
	["flashThreshold"] = { },
	["durationMode"] = { },
	["timerThreshold"] = { },
};

local sGlowColorArray = { 1, 1, 0, 1 };

local sPanelBarHeights = { };

local sPrewarm = {
	["iconsNeeded"] = 0,
	["barsNeeded"] = 0,
	["iconsCreated"] = 0,
	["barsCreated"] = 0,
	["tempIconFrames"] = { },
	["tempBarFrames"] = { },
};

local VUHDO_AURA_PREWARM_BUDGET_MS = 2;

VUHDO_FIXED_AURA_OVERFLOW_STATE = VUHDO_FIXED_AURA_OVERFLOW_STATE or { };
local VUHDO_FIXED_AURA_OVERFLOW_STATE = VUHDO_FIXED_AURA_OVERFLOW_STATE;

VUHDO_AURA_RADIOVALUE_POSITIONS = VUHDO_AURA_RADIOVALUE_POSITIONS or {
	[1] = {
		["anchor"] = "RIGHT",
		["relPoint"] = "LEFT",
		["relFrame"] = "Button",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[2] = {
		["anchor"] = "LEFT",
		["relPoint"] = "LEFT",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[3] = {
		["anchor"] = "RIGHT",
		["relPoint"] = "RIGHT",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[4] = {
		["anchor"] = "LEFT",
		["relPoint"] = "RIGHT",
		["relFrame"] = "Button",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[5] = {
		["anchor"] = "TOPLEFT",
		["relPoint"] = "BOTTOMLEFT",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[6] = {
		["anchor"] = "TOPRIGHT",
		["relPoint"] = "BOTTOMRIGHT",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[7] = {
		["anchor"] = "TOPLEFT",
		["relPoint"] = "BOTTOMLEFT",
		["relFrame"] = "Button",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[8] = {
		["anchor"] = "TOPRIGHT",
		["relPoint"] = "BOTTOMRIGHT",
		["relFrame"] = "Button",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[9] = {
		["anchor"] = "TOPLEFT",
		["relPoint"] = "TOPLEFT",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[10] = {
		["anchor"] = "TOPLEFT",
		["relPoint"] = "TOPLEFT",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[11] = {
		["anchor"] = "BOTTOMRIGHT",
		["relPoint"] = "BOTTOMRIGHT",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[12] = {
		["anchor"] = "BOTTOMLEFT",
		["relPoint"] = "BOTTOMLEFT",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[13] = {
		["anchor"] = "BOTTOMLEFT",
		["relPoint"] = "BOTTOMLEFT",
		["relFrame"] = "Button",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[14] = {
		["anchor"] = "BOTTOMRIGHT",
		["relPoint"] = "BOTTOMRIGHT",
		["relFrame"] = "Button",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[15] = {
		["anchor"] = "TOP",
		["relPoint"] = "TOP",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[16] = {
		["anchor"] = "CENTER",
		["relPoint"] = "CENTER",
		["relFrame"] = "HealthBar",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
	[17] = {
		["anchor"] = "TOPRIGHT",
		["relPoint"] = "TOPRIGHT",
		["relFrame"] = "Button",
		["xOffset"] = 0,
		["yOffset"] = 0,
	},
};
local VUHDO_AURA_RADIOVALUE_POSITIONS = VUHDO_AURA_RADIOVALUE_POSITIONS;

VUHDO_AURA_FIXED_STRAIGHT_POSITIONS = VUHDO_AURA_FIXED_STRAIGHT_POSITIONS or {
	[1] = {
		["anchor"] = "LEFT",
		["relPoint"] = "LEFT",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[2] = {
		["anchor"] = "TOP",
		["relPoint"] = "TOP",
		["xPercent"] = -0.2,
		["yPercent"] = 0,
	},
	[3] = {
		["anchor"] = "RIGHT",
		["relPoint"] = "RIGHT",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[4] = {
		["anchor"] = "BOTTOM",
		["relPoint"] = "BOTTOM",
		["xPercent"] = 0.2,
		["yPercent"] = 0,
	},
	[5] = {
		["anchor"] = "BOTTOM",
		["relPoint"] = "BOTTOM",
		["xPercent"] = -0.2,
		["yPercent"] = 0,
	},
	[6] = {
		["anchor"] = "TOP",
		["relPoint"] = "TOP",
		["xPercent"] = 0.2,
		["yPercent"] = 0,
	},
	[7] = {
		["anchor"] = "CENTER",
		["relPoint"] = "CENTER",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[8] = {
		["anchor"] = "CENTER",
		["relPoint"] = "CENTER",
		["xPercent"] = -0.2,
		["yPercent"] = 0,
	},
	[9] = {
		["anchor"] = "CENTER",
		["relPoint"] = "CENTER",
		["xPercent"] = 0.2,
		["yPercent"] = 0,
	},
};
local VUHDO_AURA_FIXED_STRAIGHT_POSITIONS = VUHDO_AURA_FIXED_STRAIGHT_POSITIONS;

VUHDO_AURA_FIXED_DIAGONAL_POSITIONS = VUHDO_AURA_FIXED_DIAGONAL_POSITIONS or {
	[1] = {
		["anchor"] = "TOPLEFT",
		["relPoint"] = "TOPLEFT",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[2] = {
		["anchor"] = "TOPRIGHT",
		["relPoint"] = "TOPRIGHT",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[3] = {
		["anchor"] = "BOTTOMLEFT",
		["relPoint"] = "BOTTOMLEFT",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[4] = {
		["anchor"] = "BOTTOMRIGHT",
		["relPoint"] = "BOTTOMRIGHT",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[5] = {
		["anchor"] = "BOTTOM",
		["relPoint"] = "BOTTOM",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[6] = {
		["anchor"] = "TOP",
		["relPoint"] = "TOP",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[7] = {
		["anchor"] = "CENTER",
		["relPoint"] = "CENTER",
		["xPercent"] = 0,
		["yPercent"] = 0,
	},
	[8] = {
		["anchor"] = "CENTER",
		["relPoint"] = "CENTER",
		["xPercent"] = -0.2,
		["yPercent"] = 0,
	},
	[9] = {
		["anchor"] = "CENTER",
		["relPoint"] = "CENTER",
		["xPercent"] = 0.2,
		["yPercent"] = 0,
	},
};
local VUHDO_AURA_FIXED_DIAGONAL_POSITIONS = VUHDO_AURA_FIXED_DIAGONAL_POSITIONS;

local sAnchorPoints = {
	["TOPLEFT"] = { "TOPLEFT", 1, -1 },
	["TOP"] = { "TOP", 0, -1 },
	["TOPRIGHT"] = { "TOPRIGHT", -1, -1 },
	["LEFT"] = { "LEFT", 1, 0 },
	["CENTER"] = { "CENTER", 0, 0 },
	["RIGHT"] = { "RIGHT", -1, 0 },
	["BOTTOMLEFT"] = { "BOTTOMLEFT", 1, 1 },
	["BOTTOM"] = { "BOTTOM", 0, 1 },
	["BOTTOMRIGHT"] = { "BOTTOMRIGHT", -1, 1 },
};

local sGrowthOffsets = {
	["LEFT"] = { -1, 0 },
	["RIGHT"] = { 1, 0 },
	["UP"] = { 0, 1 },
	["DOWN"] = { 0, -1 },
};

local sTimeAbbrevData = {
	["breakpointData"] = {
		{
			["breakpoint"] = 3600,
			["abbreviation"] = "h",
			["significandDivisor"] = 60,
			["fractionDivisor"] = 60,
		},
		{
			["breakpoint"] = 60,
			["abbreviation"] = "m",
			["significandDivisor"] = 60,
			["fractionDivisor"] = 1,
		},
		{
			["breakpoint"] = 0,
			["abbreviation"] = "s",
			["significandDivisor"] = 1,
			["fractionDivisor"] = 1,
		},
	},
};

local sCurves = {
	["timerVisible"] = nil,
	["timerVisibleElapsed"] = nil,
	["flashZone"] = nil,
	["fadeAlpha"] = nil,
	["fadeAlphaByThreshold"] = { },
	["flashZoneByThreshold"] = { },
	["timerColor"] = nil,
	["dispel"] = nil,
};

local sBarColors;

local sAuraTimer = {
	["data"] = { },
	["isAlive"] = { },
	["durationMode"] = { },
	["timerThreshold"] = { },
	["frame"] = nil,
	["animGroup"] = nil,
	["animation"] = nil,
	["count"] = 0,
	["flashData"] = { },
	["flashThreshold"] = { },
	["flashCount"] = 0,
	["fadeData"] = { },
	["fadeThreshold"] = { },
	["fadeCount"] = 0,
};

local sAuraPools = {
	["icon"] = nil,
	["bar"] = nil,
	["slotDataAsAura"] = nil,
	["slotAssignment"] = nil,
	["container"] = nil,
};

local sAuraBackdropInfo = {
	["edgeFile"] = "Interface\\Buttons\\WHITE8X8",
	["edgeSize"] = 2,
	["insets"] = {
		["left"] = 0,
		["right"] = 0,
		["top"] = 0,
		["bottom"] = 0,
	},
};

local sAurasSuspended = false;



--
local tPanelAnchors;
function VUHDO_barCustomizerAurasInitLocalOverrides()

	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_AURA_IGNORE_LIST = _G["VUHDO_AURA_IGNORE_LIST"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_UNIT_AURA_CACHE = _G["VUHDO_UNIT_AURA_CACHE"];
	VUHDO_UNIT_AURA_SLOTS = _G["VUHDO_UNIT_AURA_SLOTS"];
	VUHDO_STATUSBAR_LEFT_TO_RIGHT = _G["VUHDO_STATUSBAR_LEFT_TO_RIGHT"];
	VUHDO_STATUSBAR_RIGHT_TO_LEFT = _G["VUHDO_STATUSBAR_RIGHT_TO_LEFT"];
	VUHDO_STATUSBAR_BOTTOM_TO_TOP = _G["VUHDO_STATUSBAR_BOTTOM_TO_TOP"];
	VUHDO_STATUSBAR_TOP_TO_BOTTOM = _G["VUHDO_STATUSBAR_TOP_TO_BOTTOM"];
	VUHDO_UNIT_AURA_LIST_SLOTS = _G["VUHDO_UNIT_AURA_LIST_SLOTS"];
	VUHDO_AURA_GROUP_TYPE_LIST = _G["VUHDO_AURA_GROUP_TYPE_LIST"];
	VUHDO_ATLAS_TEXTURES = _G["VUHDO_ATLAS_TEXTURES"];

	VUHDO_LibCustomGlow = _G["VUHDO_LibCustomGlow"];
	VUHDO_PixelUtil = _G["VUHDO_PixelUtil"];
	VUHDO_UIFrameFlash = _G["VUHDO_UIFrameFlash"];
	VUHDO_UIFrameFlashStop = _G["VUHDO_UIFrameFlashStop"];

	VUHDO_safeSetAttribute = _G["VUHDO_safeSetAttribute"];
	VUHDO_getUnitButtonsPanel = _G["VUHDO_getUnitButtonsPanel"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getHealthBarWidth = _G["VUHDO_getHealthBarWidth"];
	VUHDO_getHealthBarHeight = _G["VUHDO_getHealthBarHeight"];
	VUHDO_customizeIconText = _G["VUHDO_customizeIconText"];
	VUHDO_textColor = _G["VUHDO_textColor"];
	VUHDO_setLlcStatusBarTexture = _G["VUHDO_setLlcStatusBarTexture"];
	VUHDO_setStatusBarOrientation = _G["VUHDO_setStatusBarOrientation"];
	VUHDO_getClassColor = _G["VUHDO_getClassColor"];
	VUHDO_backColor = _G["VUHDO_backColor"];
	VUHDO_safeColorFromTable = _G["VUHDO_safeColorFromTable"];
	VUHDO_setAnchorSlotAuraId = _G["VUHDO_setAnchorSlotAuraId"];
	VUHDO_resolveAuraTriState = _G["VUHDO_resolveAuraTriState"];
	VUHDO_getAuraGroup = _G["VUHDO_getAuraGroup"];
	VUHDO_getDispelCurveForUnit = _G["VUHDO_getDispelCurveForUnit"];
	VUHDO_isPanelPopulated = _G["VUHDO_isPanelPopulated"];
	VUHDO_getAnchorTriStateBool = _G["VUHDO_getAnchorTriStateBool"];
	VUHDO_getAllAuraGroups = _G["VUHDO_getAllAuraGroups"];

	sAuraPools["slotDataAsAura"] = VUHDO_createTablePool("SlotDataAsAura", 500);
	sAuraPools["slotAssignment"] = VUHDO_createTablePool("SlotAssignment", 200);

	VUHDO_initAuraDurationCurves();
	VUHDO_initAuraTimer();

	sBarColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		sPanelBarHeights[tPanelNum] = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["barHeight"] or 40;

		sAnchorSettingsCache["showTooltip"][tPanelNum] = { };
		sAnchorSettingsCache["showClock"][tPanelNum] = { };
		sAnchorSettingsCache["fadeOnLow"][tPanelNum] = { };
		sAnchorSettingsCache["dispelBorder"][tPanelNum] = { };
		sAnchorSettingsCache["showTimer"][tPanelNum] = { };
		sAnchorSettingsCache["showStacks"][tPanelNum] = { };
		sAnchorSettingsCache["flashOnLow"][tPanelNum] = { };

		tPanelAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

		if tPanelAnchors then
			for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
				sAnchorSettingsCache["showTooltip"][tPanelNum][tAnchorIndex] = VUHDO_resolveAuraTriState(tAnchorConfig["showTooltip"], "showTooltip");
				sAnchorSettingsCache["showClock"][tPanelNum][tAnchorIndex] = VUHDO_resolveAuraTriState(tAnchorConfig["showClock"], "showClock");
				sAnchorSettingsCache["fadeOnLow"][tPanelNum][tAnchorIndex] = VUHDO_resolveAuraTriState(tAnchorConfig["fadeOnLow"], "fadeOnLow");
				sAnchorSettingsCache["dispelBorder"][tPanelNum][tAnchorIndex] = VUHDO_resolveAuraTriState(tAnchorConfig["dispelBorder"], "dispelBorder");
				sAnchorSettingsCache["showTimer"][tPanelNum][tAnchorIndex] = VUHDO_resolveAuraTriState(tAnchorConfig["showTimer"], "showTimer");
				sAnchorSettingsCache["showStacks"][tPanelNum][tAnchorIndex] = VUHDO_resolveAuraTriState(tAnchorConfig["showStacks"], "showStacks");
				sAnchorSettingsCache["flashOnLow"][tPanelNum][tAnchorIndex] = VUHDO_resolveAuraTriState(tAnchorConfig["flashOnLow"], "flashOnLow");
			end
		end
	end

	VUHDO_initEntrySettingsCache();

	return;

end



--
local tAllGroups;
local tEntries;
function VUHDO_initEntrySettingsCache()

	sEntrySettingsVersion = sEntrySettingsVersion + 1;

	twipe(sEntrySettingsCache["showTimer"]);
	twipe(sEntrySettingsCache["showStacks"]);
	twipe(sEntrySettingsCache["showClock"]);
	twipe(sEntrySettingsCache["fadeOnLow"]);
	twipe(sEntrySettingsCache["flashOnLow"]);
	twipe(sEntrySettingsCache["glowIcon"]);
	twipe(sEntrySettingsCache["colorIcon"]);
	twipe(sEntrySettingsCache["glowColor"]);
	twipe(sEntrySettingsCache["colorIconColor"]);
	twipe(sEntrySettingsCache["fadeThreshold"]);
	twipe(sEntrySettingsCache["flashThreshold"]);
	twipe(sEntrySettingsCache["durationMode"]);
	twipe(sEntrySettingsCache["timerThreshold"]);

	tAllGroups = VUHDO_getAllAuraGroups();

	if tAllGroups then
		for tGroupId, tGroup in pairs(tAllGroups) do
			if (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST then
				tEntries = tGroup["entries"];

				if tEntries then
					sEntrySettingsCache["showTimer"][tGroupId] = { };
					sEntrySettingsCache["showStacks"][tGroupId] = { };
					sEntrySettingsCache["showClock"][tGroupId] = { };
					sEntrySettingsCache["fadeOnLow"][tGroupId] = { };
					sEntrySettingsCache["flashOnLow"][tGroupId] = { };
					sEntrySettingsCache["glowIcon"][tGroupId] = { };
					sEntrySettingsCache["colorIcon"][tGroupId] = { };
					sEntrySettingsCache["glowColor"][tGroupId] = { };
					sEntrySettingsCache["colorIconColor"][tGroupId] = { };
					sEntrySettingsCache["fadeThreshold"][tGroupId] = { };
					sEntrySettingsCache["flashThreshold"][tGroupId] = { };
					sEntrySettingsCache["durationMode"][tGroupId] = { };
					sEntrySettingsCache["timerThreshold"][tGroupId] = { };

					for tEntryIndex, tEntry in ipairs(tEntries) do
						sEntrySettingsCache["showTimer"][tGroupId][tEntryIndex] = VUHDO_getAnchorTriStateBool(tEntry, "showTimer", nil);
						sEntrySettingsCache["showStacks"][tGroupId][tEntryIndex] = VUHDO_getAnchorTriStateBool(tEntry, "showStacks", nil);
						sEntrySettingsCache["showClock"][tGroupId][tEntryIndex] = VUHDO_getAnchorTriStateBool(tEntry, "showClock", nil);
						sEntrySettingsCache["fadeOnLow"][tGroupId][tEntryIndex] = VUHDO_getAnchorTriStateBool(tEntry, "fadeOnLow", nil);
						sEntrySettingsCache["flashOnLow"][tGroupId][tEntryIndex] = VUHDO_getAnchorTriStateBool(tEntry, "flashOnLow", nil);

						sEntrySettingsCache["glowIcon"][tGroupId][tEntryIndex] = tEntry["glowIcon"] == true;
						sEntrySettingsCache["colorIcon"][tGroupId][tEntryIndex] = tEntry["colorIcon"] == true;
						sEntrySettingsCache["glowColor"][tGroupId][tEntryIndex] = tEntry["glowIconColor"];
						sEntrySettingsCache["colorIconColor"][tGroupId][tEntryIndex] = tEntry["colorIconColor"];
						sEntrySettingsCache["fadeThreshold"][tGroupId][tEntryIndex] = tEntry["fadeThreshold"];
						sEntrySettingsCache["flashThreshold"][tGroupId][tEntryIndex] = tEntry["flashThreshold"];
						sEntrySettingsCache["durationMode"][tGroupId][tEntryIndex] = tEntry["durationMode"];
						sEntrySettingsCache["timerThreshold"][tGroupId][tEntryIndex] = tEntry["timerThreshold"];
					end
				end
			end
		end
	end


	return;

end



--
function VUHDO_incrementAuraAnchorConfigVersion()

	sAuraAnchorConfigVersion = sAuraAnchorConfigVersion + 1;

	return;

end



--
function VUHDO_getAuraAnchorConfigVersion()

	return sAuraAnchorConfigVersion;

end



--
local tIconCount;
local tBarCount;
local tNumButtons;
local tIsFirstPanel;
local tAnchors;
local tMaxSlots;
function VUHDO_estimateRequiredAuraFrames()

	tIconCount = 0;
	tBarCount = 0;

	tIsFirstPanel = true;

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		if VUHDO_isPanelPopulated(tPanelNum) then
			if tIsFirstPanel then
				tNumButtons = 20;

				tIsFirstPanel = false;
			else
				tNumButtons = 8;
			end

			tAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

			if tAnchors then
				for _, tAnchorConfig in pairs(tAnchors) do
					if tAnchorConfig["enabled"] then
						tMaxSlots = tAnchorConfig["maxDisplay"] or 5;

						if tAnchorConfig["style"] == "bars" then
							tBarCount = tBarCount + (tMaxSlots * tNumButtons);
						else
							tIconCount = tIconCount + (tMaxSlots * tNumButtons);
						end
					end
				end
			end
		end
	end

	tIconCount = min(tIconCount, 400);
	tBarCount = min(tBarCount, 100);

	return tIconCount, tBarCount;

end



--
local tAuraIgnoreModi;
local function VUHDO_areAuraIgnoreModifiersPressed()

	if not VUHDO_CONFIG then
		return IsAltKeyDown() and IsControlKeyDown() and IsShiftKeyDown();
	end

	tAuraIgnoreModi = VUHDO_CONFIG["AURA_IGNORE_MODI"] or "ALT-CTRL-SHIFT";

	if tAuraIgnoreModi == "OFF" then
		return false;
	elseif tAuraIgnoreModi == "ALT-CTRL-SHIFT" then
		return IsAltKeyDown() and IsControlKeyDown() and IsShiftKeyDown();
	elseif tAuraIgnoreModi == "ALT-SHIFT" then
		return IsAltKeyDown() and IsShiftKeyDown() and not IsControlKeyDown();
	elseif tAuraIgnoreModi == "ALT-CTRL" then
		return IsAltKeyDown() and IsControlKeyDown() and not IsShiftKeyDown();
	elseif tAuraIgnoreModi == "CTRL-SHIFT" then
		return IsControlKeyDown() and IsShiftKeyDown() and not IsAltKeyDown();
	elseif tAuraIgnoreModi == "SHIFT" then
		return IsShiftKeyDown() and not IsAltKeyDown() and not IsControlKeyDown();
	elseif tAuraIgnoreModi == "CTRL" then
		return IsControlKeyDown() and not IsAltKeyDown() and not IsShiftKeyDown();
	elseif tAuraIgnoreModi == "ALT" then
		return IsAltKeyDown() and not IsControlKeyDown() and not IsShiftKeyDown();
	end

	return false;

end



--
local tAuraData;
local tSpellId;
local tSecrecy;
local tDisplayName;
local tCombo;
function VUHDO_addAuraToIgnoreList(aUnit, anAuraInstanceId)

	if not aUnit or not anAuraInstanceId then
		return;
	end

	tAuraData = GetAuraDataByAuraInstanceID(aUnit, anAuraInstanceId);

	if not tAuraData or not tAuraData["spellId"] then
		return;
	end

	if issecretvalue(tAuraData["spellId"]) then
		VUHDO_Msg(VUHDO_I18N_AURA_GROUP_SPELL_ALWAYS_SECRET, 1, 0.3, 0.3);

		return;
	end

	tSpellId = tAuraData["spellId"];

	tSecrecy = GetSpellAuraSecrecy(tSpellId);

	if tSecrecy == 1 then
		VUHDO_Msg(VUHDO_I18N_AURA_GROUP_SPELL_ALWAYS_SECRET, 1, 0.3, 0.3);

		return;
	end

	if VUHDO_AURA_IGNORE_LIST[tSpellId] then
		return;
	end

	VUHDO_AURA_IGNORE_LIST[tSpellId] = true;

	tDisplayName = VUHDO_formatAuraSpellDisplayName(tSpellId);
	VUHDO_Msg(format(VUHDO_I18N_AURA_ADDED_TO_IGNORE_LIST, tDisplayName));

	VUHDO_showAllAuras();

	tCombo = _G["VuhDoNewOptionsAuraIgnoreIgnorePanelIgnoreComboBox"];

	if tCombo then
		VUHDO_initAuraIgnoreComboModel();

		VUHDO_lnfComboBoxInitFromModel(tCombo);

		tCombo:Hide();
		tCombo:Show();
	end

	return;

end



--
local VUHDO_AURA_IGNORE_GLOBAL_HANDLER_FRAME = CreateFrame("Frame");
VUHDO_AURA_IGNORE_GLOBAL_HANDLER_FRAME:RegisterEvent("GLOBAL_MOUSE_DOWN");
VUHDO_AURA_IGNORE_GLOBAL_HANDLER_FRAME:SetScript("OnEvent", function(self, anEvent, aButton)

	if anEvent == "GLOBAL_MOUSE_DOWN" and aButton == "RightButton" and VUHDO_areAuraIgnoreModifiersPressed() then
		local tButtons;
		local tFrameName;

		for tUnit, _ in pairs(VUHDO_RAID) do
			tButtons = VUHDO_getUnitButtonsSafe(tUnit);

			for _, tButton in pairs(tButtons) do
				tFrameName = tButton:GetName();

				if VUHDO_AURA_FRAMES[tFrameName] then
					for tAnchorIndex, tAnchorFrames in pairs(VUHDO_AURA_FRAMES[tFrameName]) do
						for tSlotIndex, tFrame in pairs(tAnchorFrames) do
							if tFrame and tFrame["auraInstanceId"] and tFrame:IsMouseOver() then
								VUHDO_addAuraToIgnoreList(tButton:GetAttribute("unit"), tFrame["auraInstanceId"]);

								return;
							end
						end
					end
				end
			end
		end
	end

end);



do
	--
	local tPanelNum;
	local tBarHeight;
	function VUHDO_getAuraIconSizePixels(aButton, anAnchorConfig)

		tPanelNum = VUHDO_BUTTON_CACHE and VUHDO_BUTTON_CACHE[aButton];
		tBarHeight = tPanelNum and VUHDO_getHealthBarHeight(tPanelNum) or 40;

		return tBarHeight * (anAnchorConfig["size"] or 40) * 0.01;

	end



	--
	local tPanelNum;
	local tBarHeight;
	function VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig)

		tPanelNum = VUHDO_BUTTON_CACHE and VUHDO_BUTTON_CACHE[aButton];
		tBarHeight = tPanelNum and VUHDO_getHealthBarHeight(tPanelNum) or 40;

		return tBarHeight * (anAnchorConfig["barHeight"] or 30) * 0.01;

	end



	--
	local tBarWidth;
	local tAvailableWidth;
	function VUHDO_getAuraBarWidthPixels(aButton, anAnchorConfig)

		tPanelNum = VUHDO_BUTTON_CACHE and VUHDO_BUTTON_CACHE[aButton];
		tBarWidth = tPanelNum and VUHDO_getHealthBarWidth(tPanelNum) or 80;

		if (anAnchorConfig["iconType"] or 1) == 5 then
			tAvailableWidth = tBarWidth;
		else
			tAvailableWidth = max(0, tBarWidth - VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig));
		end

		return tAvailableWidth * (anAnchorConfig["barWidth"] or 100) * 0.01;

	end



	--
	function VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig)

		tPanelNum = VUHDO_BUTTON_CACHE and VUHDO_BUTTON_CACHE[aButton];

		tBarWidth = tPanelNum and VUHDO_getHealthBarWidth(tPanelNum) or 80;

		return tBarWidth * (anAnchorConfig["barWidth"] or 30) * 0.01;

	end



	--
	local tAvailableHeight;
	local tIconSize;
	function VUHDO_getAuraBarHeightPixelsVertical(aButton, anAnchorConfig)

		tPanelNum = VUHDO_BUTTON_CACHE and VUHDO_BUTTON_CACHE[aButton];

		tBarHeight = sPanelBarHeights[tPanelNum] or 40;

		if (anAnchorConfig["iconType"] or 1) == 5 then
			tAvailableHeight = tBarHeight;
		else
			tIconSize = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);

			tAvailableHeight = max(0, tBarHeight - tIconSize);
		end

		return tAvailableHeight * (anAnchorConfig["barHeight"] or 100) * 0.01;

	end



	--
	local tChild;
	function VUHDO_getAuraIconBackdrop(aFrame)

		tChild = aFrame:GetChildren();

		return tChild;

	end



	--
	local tRegion;
	function VUHDO_getAuraIconTexture(aBackdropFrame)

		tRegion = aBackdropFrame:GetRegions();

		return tRegion;

	end



	--
	local tTimer;
	local tTextOverlay;
	function VUHDO_getAuraIconTimer(aBackdropFrame)

		_, _, tTextOverlay = aBackdropFrame:GetChildren();

		if tTextOverlay then
			tTimer = tTextOverlay:GetRegions();
		else
			tTimer = nil;
		end

		return tTimer;

	end



	--
	local tCounter;
	function VUHDO_getAuraIconCounter(aBackdropFrame)

		_, _, tTextOverlay = aBackdropFrame:GetChildren();

		if tTextOverlay then
			_, tCounter = tTextOverlay:GetRegions();
		else
			tCounter = nil;
		end

		return tCounter;

	end



	--
	local tCooldown;
	function VUHDO_getAuraIconCooldown(aBackdropFrame)

		tCooldown = aBackdropFrame:GetChildren();

		return tCooldown;

	end



	--
	local tChargeFrame;
	function VUHDO_getAuraIconChargeFrame(aBackdropFrame)

		_, tChargeFrame = aBackdropFrame:GetChildren();

		return tChargeFrame;

	end



	--
	local tRegion;
	function VUHDO_getAuraIconChargeTexture(aChargeFrame)

		tRegion = aChargeFrame:GetRegions();

		return tRegion;
	end



	--
	local tBar;
	function VUHDO_getAuraBarStatusBar(aFrame)

		_, tBar = aFrame:GetChildren();

		return tBar;

	end



	--
	local tIconFrame;
	function VUHDO_getAuraBarIconFrame(aFrame)

		tIconFrame = aFrame:GetChildren();

		return tIconFrame;

	end



	--
	local tColors;
	local tTransparent;
	local tCurve;
	function VUHDO_initAuraDurationCurves()

		sCurves["timerVisible"] = CreateCurve();
		sCurves["timerVisible"]:SetType(Enum.LuaCurveType.Step);
		sCurves["timerVisible"]:AddPoint(0, 0);
		sCurves["timerVisible"]:AddPoint(0.1, 1);
		sCurves["timerVisible"]:AddPoint(9.99, 0);

		sCurves["timerVisibleElapsed"] = CreateCurve();
		sCurves["timerVisibleElapsed"]:SetType(Enum.LuaCurveType.Step);
		sCurves["timerVisibleElapsed"]:AddPoint(0, 1);

		sCurves["flashZone"] = CreateCurve();
		sCurves["flashZone"]:SetType(Enum.LuaCurveType.Step);
		sCurves["flashZone"]:AddPoint(0, 0);
		sCurves["flashZone"]:AddPoint(0.1, 1);
		sCurves["flashZone"]:AddPoint(4.9, 0);

		sCurves["fadeAlpha"] = CreateCurve();
		sCurves["fadeAlpha"]:SetType(Enum.LuaCurveType.Linear);
		sCurves["fadeAlpha"]:AddPoint(0, 0);
		sCurves["fadeAlpha"]:AddPoint(10, 1);

		for tThreshold = 1, 30 do
			tCurve = CreateCurve();
			tCurve:SetType(Enum.LuaCurveType.Linear);
			tCurve:AddPoint(0, 0);
			tCurve:AddPoint(tThreshold, 1);

			sCurves["fadeAlphaByThreshold"][tThreshold] = tCurve;
		end

		for tThreshold = 1, 30 do
			tCurve = CreateCurve();
			tCurve:SetType(Enum.LuaCurveType.Step);
			tCurve:AddPoint(0, 0);
			tCurve:AddPoint(0.1, 1);
			tCurve:AddPoint(max(0.2, tThreshold - 0.1), 0);

			sCurves["flashZoneByThreshold"][tThreshold] = tCurve;
		end

		sCurves["timerColor"] = CreateColorCurve();
		sCurves["timerColor"]:SetType(Enum.LuaCurveType.Step);
		sCurves["timerColor"]:AddPoint(0, CreateColor(1, 1, 1, 1));
		sCurves["timerColor"]:AddPoint(0.1, CreateColor(1, 0.2, 0.2, 1));
		sCurves["timerColor"]:AddPoint(4.9, CreateColor(1, 1, 1, 1));

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];
		tTransparent = CreateColor(0, 0, 0, 0);
		sCurves["dispel"] = CreateColorCurve();
		sCurves["dispel"]:SetType(Enum.LuaCurveType.Step);
		sCurves["dispel"]:AddPoint(0, tTransparent);

		if tColors and tColors["DEBUFF3"] and tColors["DEBUFF3"]["useBorder"] then
			sCurves["dispel"]:AddPoint(1, VUHDO_safeColorFromTable(tColors["DEBUFF3"], tTransparent));
		else
			sCurves["dispel"]:AddPoint(1, tTransparent);
		end

		if tColors and tColors["DEBUFF4"] and tColors["DEBUFF4"]["useBorder"] then
			sCurves["dispel"]:AddPoint(2, VUHDO_safeColorFromTable(tColors["DEBUFF4"], tTransparent));
		else
			sCurves["dispel"]:AddPoint(2, tTransparent);
		end

		if tColors and tColors["DEBUFF2"] and tColors["DEBUFF2"]["useBorder"] then
			sCurves["dispel"]:AddPoint(3, VUHDO_safeColorFromTable(tColors["DEBUFF2"], tTransparent));
		else
			sCurves["dispel"]:AddPoint(3, tTransparent);
		end

		if tColors and tColors["DEBUFF1"] and tColors["DEBUFF1"]["useBorder"] then
			sCurves["dispel"]:AddPoint(4, VUHDO_safeColorFromTable(tColors["DEBUFF1"], tTransparent));
		else
			sCurves["dispel"]:AddPoint(4, tTransparent);
		end

		if tColors and tColors["DEBUFF9"] and tColors["DEBUFF9"]["useBorder"] then
			sCurves["dispel"]:AddPoint(9, VUHDO_safeColorFromTable(tColors["DEBUFF9"], tTransparent));
		else
			sCurves["dispel"]:AddPoint(9, tTransparent);
		end

		if tColors and tColors["DEBUFF8"] and tColors["DEBUFF8"]["useBorder"] then
			sCurves["dispel"]:AddPoint(11, VUHDO_safeColorFromTable(tColors["DEBUFF8"], tTransparent));
		else
			sCurves["dispel"]:AddPoint(11, tTransparent);
		end

		return;

	end



	--
	function VUHDO_getAuraDispelCurve()

		return sCurves["dispel"];

	end



	--
	local tGroup;
	local tCanAttack;
	local tInfo;
	function VUHDO_getAuraDispelCurveForContext(aUnit, anAnchorConfig)

		if not aUnit or not anAnchorConfig then
			return nil;
		end

		tGroup = VUHDO_getAuraGroup(anAnchorConfig["groupId"]);

		if not tGroup then
			return nil;
		end

		tInfo = VUHDO_RAID[aUnit];

		if not tInfo then
			return nil;
		end

		tCanAttack = tInfo["canAttack"];

		if tGroup["isHarmful"] ~= tCanAttack then
			return sCurves["dispel"];
		end

		return nil;

	end



	--
	local tGroup;
	function VUHDO_getDispelCurveForContext(aUnit, anAnchorConfig)

		if not aUnit or not anAnchorConfig then
			return nil;
		end

		tGroup = VUHDO_getAuraGroup(anAnchorConfig["groupId"]);

		if not tGroup then
			return nil;
		end

		return VUHDO_getDispelCurveForUnit(aUnit, tGroup["isHarmful"]);

	end
end



do
	--
	local function VUHDO_auraTimerGetLiveCount()

		return sAuraTimer["count"] + sAuraTimer["flashCount"] + sAuraTimer["fadeCount"];

	end



	--
	local tRemainingSeconds;
	local tDurationText;
	local tTimerVisibility;
	local tTimerColorMixin;
	local tDurationMode;
	local tTimerThreshold;
	local tGlowTarget;
	local tFlashLoopZone;
	local tFadeLoopAlpha;
	local tFlashLoopThreshold;
	local tFadeLoopThreshold;
	local function VUHDO_auraTimerOnLoop()

		for tFontString, tDurationObj in pairs(sAuraTimer["data"]) do
			if tDurationObj and sCurves["timerVisible"] then
				if sAuraTimer["isAlive"][tFontString] then
					tRemainingSeconds = tDurationObj:GetElapsedDuration();
					tTimerVisibility = tDurationObj:EvaluateElapsedDuration(sCurves["timerVisibleElapsed"]);
				else
					tRemainingSeconds = tDurationObj:GetRemainingDuration();
					tTimerVisibility = tDurationObj:EvaluateRemainingDuration(sCurves["timerVisible"]);
				end

				tDurationMode = sAuraTimer["durationMode"][tFontString];
				tTimerThreshold = sAuraTimer["timerThreshold"][tFontString];

				if tDurationMode == VUHDO_SPELL_DURATION_MODE_FULL then
					tTimerVisibility = 1;
				elseif (tDurationMode == nil or tDurationMode == VUHDO_SPELL_DURATION_MODE_THRESHOLD) and tTimerThreshold and tRemainingSeconds and not sAuraTimer["isAlive"][tFontString] then
					tTimerVisibility = (tRemainingSeconds <= tTimerThreshold) and 1 or 0;
				end

				tDurationText = AbbreviateNumbers(tRemainingSeconds, sTimeAbbrevData);
				tFontString:SetText(tDurationText or "");

				if sCurves["timerColor"] and not sAuraTimer["isAlive"][tFontString] then
					tTimerColorMixin = tDurationObj:EvaluateRemainingDuration(sCurves["timerColor"]);
					tFontString:SetTextColor(tTimerColorMixin:GetRGBA());
				end

				tFontString:SetAlpha(tTimerVisibility);
			end
		end

		for tFlashLoopFrame, tFlashLoopDurationObj in pairs(sAuraTimer["flashData"]) do
			if tFlashLoopDurationObj and not tFlashLoopDurationObj:HasSecretValues() then
				tFlashLoopThreshold = sAuraTimer["flashThreshold"][tFlashLoopFrame];

				if tFlashLoopThreshold and tFlashLoopThreshold >= 1 and tFlashLoopThreshold <= 30 and sCurves["flashZoneByThreshold"][tFlashLoopThreshold] then
					tFlashLoopZone = tFlashLoopDurationObj:EvaluateRemainingDuration(sCurves["flashZoneByThreshold"][tFlashLoopThreshold]);
				elseif sCurves["flashZone"] then
					tFlashLoopZone = tFlashLoopDurationObj:EvaluateRemainingDuration(sCurves["flashZone"]);
				else
					tFlashLoopZone = 0;
				end

				if tFlashLoopZone > 0.5 then
					VUHDO_UIFrameFlash(tFlashLoopFrame, 0.2, 0.1, 5, true, 0, 0.1);
				else
					VUHDO_UIFrameFlashStop(tFlashLoopFrame);
				end
			end
		end

		for tFadeLoopTexture, tFadeLoopDurationObj in pairs(sAuraTimer["fadeData"]) do
			if tFadeLoopDurationObj and not tFadeLoopDurationObj:HasSecretValues() then
				tFadeLoopThreshold = sAuraTimer["fadeThreshold"][tFadeLoopTexture];

				if tFadeLoopThreshold and tFadeLoopThreshold >= 1 and tFadeLoopThreshold <= 30 and sCurves["fadeAlphaByThreshold"][tFadeLoopThreshold] then
					tFadeLoopAlpha = tFadeLoopDurationObj:EvaluateRemainingDuration(sCurves["fadeAlphaByThreshold"][tFadeLoopThreshold]);
				elseif sCurves["fadeAlpha"] then
					tFadeLoopAlpha = tFadeLoopDurationObj:EvaluateRemainingDuration(sCurves["fadeAlpha"]);
				else
					tFadeLoopAlpha = 1;
				end

				tFadeLoopTexture:SetAlpha(tFadeLoopAlpha);
			end
		end

		return;

	end



	--
	function VUHDO_initAuraTimer()

		if sAuraTimer["frame"] then
			return;
		end

		sAuraTimer["frame"] = CreateFrame("Frame");
		sAuraTimer["frame"]:Hide();

		sAuraTimer["animGroup"] = sAuraTimer["frame"]:CreateAnimationGroup();
		sAuraTimer["animGroup"]:SetLooping("REPEAT");

		sAuraTimer["animation"] = sAuraTimer["animGroup"]:CreateAnimation();
		sAuraTimer["animation"]:SetDuration(0.1);

		sAuraTimer["animGroup"]:SetScript("OnLoop", VUHDO_auraTimerOnLoop);

		return;

	end



	--
	function VUHDO_registerAuraTimerText(aFontString, aDurationObj, anIsAliveTime, aDurationMode, aTimerThreshold)

		if not aFontString or not aDurationObj then
			return;
		end

		if not sAuraTimer["data"][aFontString] then
			sAuraTimer["count"] = sAuraTimer["count"] + 1;
		end

		sAuraTimer["data"][aFontString] = aDurationObj;
		sAuraTimer["isAlive"][aFontString] = anIsAliveTime or false;
		sAuraTimer["durationMode"][aFontString] = aDurationMode;
		sAuraTimer["timerThreshold"][aFontString] = aTimerThreshold;

		if VUHDO_auraTimerGetLiveCount() == 1 and sAuraTimer["animGroup"] then
			sAuraTimer["animGroup"]:Play();
		end

		return;

	end



	--
	function VUHDO_unregisterAuraTimerText(aFontString)

		if not aFontString then
			return;
		end

		if not sAuraTimer["data"][aFontString] then
			return;
		end

		sAuraTimer["data"][aFontString] = nil;
		sAuraTimer["isAlive"][aFontString] = nil;
		sAuraTimer["durationMode"][aFontString] = nil;
		sAuraTimer["timerThreshold"][aFontString] = nil;
		sAuraTimer["count"] = sAuraTimer["count"] - 1;

		if VUHDO_auraTimerGetLiveCount() == 0 and sAuraTimer["animGroup"] then
			sAuraTimer["animGroup"]:Stop();
		end

		return;

	end



	--
	function VUHDO_registerAuraFlashFrame(aFrame, aDurationObj, aFlashThreshold)

		if not aFrame or not aDurationObj then
			return;
		end

		if not sAuraTimer["flashData"][aFrame] then
			sAuraTimer["flashCount"] = sAuraTimer["flashCount"] + 1;
		end

		sAuraTimer["flashData"][aFrame] = aDurationObj;
		sAuraTimer["flashThreshold"][aFrame] = aFlashThreshold;

		if VUHDO_auraTimerGetLiveCount() == 1 and sAuraTimer["animGroup"] then
			sAuraTimer["animGroup"]:Play();
		end

		return;

	end



	--
	function VUHDO_unregisterAuraFlashFrame(aFrame)

		if not aFrame then
			return;
		end

		if not sAuraTimer["flashData"][aFrame] then
			return;
		end

		VUHDO_UIFrameFlashStop(aFrame);

		sAuraTimer["flashData"][aFrame] = nil;
		sAuraTimer["flashThreshold"][aFrame] = nil;
		sAuraTimer["flashCount"] = sAuraTimer["flashCount"] - 1;

		if VUHDO_auraTimerGetLiveCount() == 0 and sAuraTimer["animGroup"] then
			sAuraTimer["animGroup"]:Stop();
		end

		return;

	end



	--
	function VUHDO_registerAuraFadeTexture(aTexture, aDurationObj, aFadeThreshold)

		if not aTexture or not aDurationObj then
			return;
		end

		if not sAuraTimer["fadeData"][aTexture] then
			sAuraTimer["fadeCount"] = sAuraTimer["fadeCount"] + 1;
		end

		sAuraTimer["fadeData"][aTexture] = aDurationObj;
		sAuraTimer["fadeThreshold"][aTexture] = aFadeThreshold;

		if VUHDO_auraTimerGetLiveCount() == 1 and sAuraTimer["animGroup"] then
			sAuraTimer["animGroup"]:Play();
		end

		return;

	end



	--
	function VUHDO_unregisterAuraFadeTexture(aTexture)

		if not aTexture then
			return;
		end

		if not sAuraTimer["fadeData"][aTexture] then
			return;
		end

		sAuraTimer["fadeData"][aTexture] = nil;
		sAuraTimer["fadeThreshold"][aTexture] = nil;
		sAuraTimer["fadeCount"] = sAuraTimer["fadeCount"] - 1;

		if VUHDO_auraTimerGetLiveCount() == 0 and sAuraTimer["animGroup"] then
			sAuraTimer["animGroup"]:Stop();
		end

		return;

	end



	--
	local function VUHDO_auraFramePoolReset(aPool, aFrame)

		VUHDO_unregisterAuraFlashFrame(aFrame);

		if aFrame["childB"] and aFrame["childB"]["textureI"] then
			VUHDO_unregisterAuraFadeTexture(aFrame["childB"]["textureI"]);
		end

		if aFrame["childBar"] then
			VUHDO_unregisterAuraFadeTexture(aFrame["childBar"]);
		end

		if aFrame["iconFrame"] and aFrame["iconFrame"]["textureI"] then
			VUHDO_unregisterAuraFadeTexture(aFrame["iconFrame"]["textureI"]);
		end

		if aFrame["hasEntryGlow"] then
			tGlowTarget = aFrame;

			VUHDO_LibCustomGlow.PixelGlow_Stop(tGlowTarget, aFrame["entryGlowKey"]);

			aFrame["hasEntryGlow"] = nil;
			aFrame["entryGlowKey"] = nil;
		elseif aFrame["iconFrame"] and aFrame["iconFrame"]["hasEntryGlow"] then
			tGlowTarget = aFrame["iconFrame"];

			VUHDO_LibCustomGlow.PixelGlow_Stop(tGlowTarget, aFrame["iconFrame"]["entryGlowKey"]);

			aFrame["iconFrame"]["hasEntryGlow"] = nil;
			aFrame["iconFrame"]["entryGlowKey"] = nil;
		end

		if aFrame["childB"] and aFrame["childB"]["chargeTexture"] then
			aFrame["childB"]["chargeTexture"]:Hide();
		end

		if aFrame["chargeTexture"] then
			aFrame["chargeTexture"]:Hide();
		end

		aFrame["vuhdo_button"] = nil;

		aFrame:Hide();
		aFrame:ClearAllPoints();

		aFrame:SetParent(VUHDO_getAuraPoolContainer());

		return;

	end



	--
	function VUHDO_initAuraFramePools()

		if sAuraPools["icon"] then
			return;
		end

		sAuraPools["icon"] = CreateFramePool("Frame", nil, "VuhDoAuraAnchorIconTemplate", VUHDO_auraFramePoolReset);
		sAuraPools["bar"] = CreateFramePool("Frame", nil, "VuhDoAuraAnchorBarTemplate", VUHDO_auraFramePoolReset);

		return;

	end



	--
	function VUHDO_getAuraPoolContainer()

		if not sAuraPools["container"] then
			sAuraPools["container"] = CreateFrame("Frame", nil, UIParent);

			sAuraPools["container"]:Hide();

			sAuraPools["container"]:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -10000, 10000);
			sAuraPools["container"]:SetSize(1, 1);
		end

		return sAuraPools["container"];

	end



	--
	local tFrame;
	local tStartTime;
	local tElapsed;
	function VUHDO_prewarmAuraFramePoolsChunk()

		VUHDO_initAuraFramePools();

		tStartTime = debugprofilestop();

		while sPrewarm["iconsCreated"] < sPrewarm["iconsNeeded"] do
			tFrame = sAuraPools["icon"]:Acquire();

			if tFrame then
				tinsert(sPrewarm["tempIconFrames"], tFrame);
			end

			sPrewarm["iconsCreated"] = sPrewarm["iconsCreated"] + 1;

			tElapsed = (debugprofilestop() - tStartTime) * 1000;

			if tElapsed >= VUHDO_AURA_PREWARM_BUDGET_MS then
				VUHDO_deferPrewarmAuraPools();

				return;
			end
		end

		while sPrewarm["barsCreated"] < sPrewarm["barsNeeded"] do
			tFrame = sAuraPools["bar"]:Acquire();

			if tFrame then
				tinsert(sPrewarm["tempBarFrames"], tFrame);
			end

			sPrewarm["barsCreated"] = sPrewarm["barsCreated"] + 1;

			tElapsed = (debugprofilestop() - tStartTime) * 1000;

			if tElapsed >= VUHDO_AURA_PREWARM_BUDGET_MS then
				VUHDO_deferPrewarmAuraPools();

				return;
			end
		end

		for _, tTempFrame in ipairs(sPrewarm["tempIconFrames"]) do
			sAuraPools["icon"]:Release(tTempFrame);
		end

		for _, tTempFrame in ipairs(sPrewarm["tempBarFrames"]) do
			sAuraPools["bar"]:Release(tTempFrame);
		end

		twipe(sPrewarm["tempIconFrames"]);
		twipe(sPrewarm["tempBarFrames"]);

		return;

	end



	--
	function VUHDO_startAuraPoolPrewarm()

		sPrewarm["iconsNeeded"], sPrewarm["barsNeeded"] = VUHDO_estimateRequiredAuraFrames();
		sPrewarm["iconsCreated"] = 0;
		sPrewarm["barsCreated"] = 0;

		twipe(sPrewarm["tempIconFrames"]);
		twipe(sPrewarm["tempBarFrames"]);

		if sPrewarm["iconsNeeded"] > 0 or sPrewarm["barsNeeded"] > 0 then
			VUHDO_deferPrewarmAuraPools();
		end

		return;

	end



	--
	local tFocus;
	local function VUHDO_auraFrameOnLeave(aAuraFrame)

		VUHDO_hideAuraTooltip();

		tFocus = VUHDO_getMouseFocus();

		if tFocus and VUHDO_findButtonFromChild(tFocus) == aAuraFrame["vuhdo_button"] then
			VuhDoActionOnEnter(aAuraFrame["vuhdo_button"]);
		else
			VuhDoActionOnLeave(aAuraFrame["vuhdo_button"]);
		end

		return;

	end



	--
	local function VUHDO_setupAuraFrameForTooltips(aFrame, aButton)

		if not aFrame or not aButton then
			return;
		end

		aFrame["vuhdo_button"] = aButton;

		if aButton["raidid"] then
			aFrame["raidid"] = aButton["raidid"];
		end

		if not aFrame:GetAttribute("vd_tt_hook") then
			aFrame:SetScript("OnLeave", VUHDO_auraFrameOnLeave);

			VUHDO_safeSetAttribute(aFrame, "vd_tt_hook", true);
		end

		if not InCombatLockdown() then
			aFrame:EnableMouse(true);
			aFrame:SetPropagateMouseMotion(true);
			aFrame:SetPropagateMouseClicks(true);
			aFrame:SetMouseClickEnabled(false);
			aFrame:EnableKeyboard(false);
			aFrame:SetPropagateKeyboardInput(true);
		end

		return;

	end



	--
	local tFrame;
	local tFrameName;
	local tParent;
	local tChargeFrame;
	local tTextOverlay;
	function VUHDO_acquireAuraIconFrame(aButton, anAnchorIndex, aSlotIndex)

		if not aButton or not anAnchorIndex or not aSlotIndex then
			return nil;
		end

		VUHDO_initAuraFramePools();

		tFrameName = aButton:GetName();

		if not VUHDO_AURA_FRAMES[tFrameName] then
			VUHDO_AURA_FRAMES[tFrameName] = { };
		end

		if not VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex] then
			VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex] = { };
		end

		tFrame = VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex][aSlotIndex];

		if tFrame then
			return tFrame;
		end

		tFrame = sAuraPools["icon"]:Acquire();

		if not tFrame then
			return nil;
		end

		tFrame["childB"] = VUHDO_getAuraIconBackdrop(tFrame);

		if tFrame["childB"] then
			if tFrame["childB"].SetBackdrop then
				tFrame["childB"]:SetBackdrop(sAuraBackdropInfo);
				tFrame["childB"]:SetBackdropBorderColor(0, 0, 0, 0);
			end

			tFrame["childB"]["textureI"] = VUHDO_getAuraIconTexture(tFrame["childB"]);

			tChargeFrame = VUHDO_getAuraIconChargeFrame(tFrame["childB"]);

			if tChargeFrame then
				tFrame["childB"]["chargeTexture"] = VUHDO_getAuraIconChargeTexture(tChargeFrame);
			end

			tFrame["childB"]["timerText"] = VUHDO_getAuraIconTimer(tFrame["childB"]);
			tFrame["childB"]["countText"] = VUHDO_getAuraIconCounter(tFrame["childB"]);

			tFrame["childB"]["cooldownFrame"] = VUHDO_getAuraIconCooldown(tFrame["childB"]);

			if tFrame["childB"]["cooldownFrame"] then
				tFrame["childB"]["cooldownFrame"]:SetHideCountdownNumbers(true);
				tFrame["childB"]["cooldownFrame"]:SetReverse(true);
				tFrame["childB"]["cooldownFrame"]:SetDrawSwipe(true);
				tFrame["childB"]["cooldownFrame"]:SetDrawEdge(true);
				tFrame["childB"]["cooldownFrame"]:SetDrawBling(false);
			end

			_, _, tTextOverlay = tFrame["childB"]:GetChildren();

			if tTextOverlay and tTextOverlay.addLevel then
				tTextOverlay:SetFrameLevel(tFrame["childB"]:GetFrameLevel() + (tTextOverlay.addLevel or 2));
			end
		end

		tParent = _G[aButton:GetName() .. "BgBarHlBar"];

		if tParent then
			tFrame:SetParent(tParent);
		end

		VUHDO_setupAuraFrameForTooltips(tFrame, aButton);

		VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex][aSlotIndex] = tFrame;

		return tFrame;

	end



	--
	local tFrame;
	local tFrameName;
	local tParent;
	function VUHDO_acquireAuraBarFrame(aButton, anAnchorIndex, aSlotIndex)

		if not aButton or not anAnchorIndex or not aSlotIndex then
			return nil;
		end

		VUHDO_initAuraFramePools();

		tFrameName = aButton:GetName();

		if not VUHDO_AURA_FRAMES[tFrameName] then
			VUHDO_AURA_FRAMES[tFrameName] = { };
		end

		if not VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex] then
			VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex] = { };
		end

		tFrame = VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex][aSlotIndex];

		if tFrame then
			return tFrame;
		end

		tFrame = sAuraPools["bar"]:Acquire();

		if not tFrame then
			return nil;
		end

		tFrame["iconFrame"] = VUHDO_getAuraBarIconFrame(tFrame);

		if tFrame["iconFrame"] then
			if tFrame["iconFrame"].SetBackdrop then
				tFrame["iconFrame"]:SetBackdrop(sAuraBackdropInfo);
				tFrame["iconFrame"]:SetBackdropBorderColor(0, 0, 0, 0);
			end

			tFrame["iconFrame"]["textureI"] = VUHDO_getAuraIconTexture(tFrame["iconFrame"]);

			tChargeFrame = VUHDO_getAuraIconChargeFrame(tFrame["iconFrame"]);

			if tChargeFrame then
				tFrame["iconFrame"]["chargeTexture"] = VUHDO_getAuraIconChargeTexture(tChargeFrame);
			end

			tFrame["iconFrame"]["timerText"] = VUHDO_getAuraIconTimer(tFrame["iconFrame"]);
			tFrame["iconFrame"]["countText"] = VUHDO_getAuraIconCounter(tFrame["iconFrame"]);

			tFrame["iconFrame"]["cooldownFrame"] = VUHDO_getAuraIconCooldown(tFrame["iconFrame"]);

			if tFrame["iconFrame"]["cooldownFrame"] then
				tFrame["iconFrame"]["cooldownFrame"]:SetHideCountdownNumbers(true);
				tFrame["iconFrame"]["cooldownFrame"]:SetReverse(true);
				tFrame["iconFrame"]["cooldownFrame"]:SetDrawSwipe(true);
				tFrame["iconFrame"]["cooldownFrame"]:SetDrawEdge(true);
				tFrame["iconFrame"]["cooldownFrame"]:SetDrawBling(false);
			end

			_, _, tTextOverlay = tFrame["iconFrame"]:GetChildren();

			if tTextOverlay and tTextOverlay.addLevel then
				tTextOverlay:SetFrameLevel(tFrame["iconFrame"]:GetFrameLevel() + (tTextOverlay.addLevel or 2));
			end

			tFrame["timerText"] = tFrame["iconFrame"]["timerText"];
			tFrame["countText"] = tFrame["iconFrame"]["countText"];
			tFrame["chargeTexture"] = tFrame["iconFrame"]["chargeTexture"];
			tFrame["cooldownFrame"] = tFrame["iconFrame"]["cooldownFrame"];
		end

		tFrame["childBar"] = VUHDO_getAuraBarStatusBar(tFrame);

		if tFrame["childBar"] then
			tFrame["childBar"]:SetFrameLevel(tFrame:GetFrameLevel() - 1);
		end

		tParent = _G[aButton:GetName() .. "BgBarHlBar"];

		if tParent then
			tFrame:SetParent(tParent);
		end

		VUHDO_setupAuraFrameForTooltips(tFrame, aButton);

		VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex][aSlotIndex] = tFrame;

		return tFrame;

	end



	--
	local tFrame;
	local tFrameName;
	function VUHDO_releaseAuraFrame(aButton, anAnchorIndex, aSlotIndex, anIsBar)

		if not aButton or not anAnchorIndex or not aSlotIndex then
			return;
		end

		tFrameName = aButton:GetName();

		if not VUHDO_AURA_FRAMES[tFrameName] then
			return;
		end

		if not VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex] then
			return;
		end

		tFrame = VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex][aSlotIndex];

		if not tFrame then
			return;
		end

		if tFrame["childB"] and tFrame["childB"]["timerText"] then
			VUHDO_unregisterAuraTimerText(tFrame["childB"]["timerText"]);
		end

		VUHDO_unregisterAuraFlashFrame(tFrame);

		if tFrame["childB"] and tFrame["childB"]["textureI"] then
			VUHDO_unregisterAuraFadeTexture(tFrame["childB"]["textureI"]);
		end

		if tFrame["iconFrame"] and tFrame["iconFrame"]["textureI"] then
			VUHDO_unregisterAuraFadeTexture(tFrame["iconFrame"]["textureI"]);
		end

		if tFrame["childBar"] then
			VUHDO_unregisterAuraFadeTexture(tFrame["childBar"]);
		end

		if anIsBar then
			sAuraPools["bar"]:Release(tFrame);
		else
			sAuraPools["icon"]:Release(tFrame);
		end

		VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex][aSlotIndex] = nil;

		return;

	end



	--
	local tIconFrame;
	local tChild;
	local tTexture;
	local tPosX;
	local tPosY;
	local tAnchor;
	local tRelPoint;
	function VUHDO_displayPlayerIcon(aButton, aSlotIndex, aTexture, aTexCoords, aWidth, aHeight, aPositionIndex)

		if not aButton or not aSlotIndex or not aTexture then
			return;
		end

		tIconFrame = VUHDO_acquireAuraIconFrame(aButton, VUHDO_AURA_ANCHOR_PLAYER_ICONS, aSlotIndex);

		if not tIconFrame then
			return;
		end

		tChild = tIconFrame["childB"];

		if not tChild then
			return;
		end

		if tChild["timerText"] then
			tChild["timerText"]:SetText("");
		end

		if tChild["countText"] then
			tChild["countText"]:SetText("");
		end

		if tChild["cooldownFrame"] then
			tChild["cooldownFrame"]:SetAlpha(0);
		end

		if tChild["chargeTexture"] then
			tChild["chargeTexture"]:SetTexture(nil);
			tChild["chargeTexture"]:Hide();
		end

		tTexture = tChild["textureI"] or VUHDO_getAuraIconTexture(tChild);

		if tTexture then
			tTexture:SetTexture(aTexture);
			tTexture:SetVertexColor(1, 1, 1);
			tTexture:SetAlpha(1);

			if aTexCoords then
				tTexture:SetTexCoord(unpack(aTexCoords));
			else
				tTexture:SetTexCoord(0, 1, 0, 1);
			end

			tTexture:Show();
		end

		tChild:SetAllPoints(tIconFrame);
		tChild:SetAlpha(1);

		if aPositionIndex == 2 then
			tAnchor = "TOPRIGHT";
			tRelPoint = "TOPRIGHT";
			tPosX = -5;
			tPosY = -10;
		else
			tAnchor = "TOPLEFT";
			tRelPoint = "TOPLEFT";

			if aPositionIndex == 0 then
				tPosX = 0;
				tPosY = 0;
			elseif aPositionIndex == 1 then
				tPosX = 0;
				tPosY = -14;
			elseif aPositionIndex == 3 then
				tPosX = 14;
				tPosY = 0;
			else
				tPosX = 28;
				tPosY = 0;
			end
		end

		tIconFrame:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tIconFrame, tAnchor, aButton, tRelPoint, tPosX, tPosY);
		VUHDO_PixelUtil.SetSize(tIconFrame, aWidth or 16, aHeight or 16);
		tIconFrame:SetAlpha(1);
		tIconFrame:Show();

		return;

	end



	--
	local tButtonName;
	local tAnchorFrames;
	function VUHDO_hidePlayerIconsForButton(aButton)

		if not aButton then
			return;
		end

		tButtonName = aButton:GetName();

		if not tButtonName or not VUHDO_AURA_FRAMES[tButtonName] then
			return;
		end

		tAnchorFrames = VUHDO_AURA_FRAMES[tButtonName][VUHDO_AURA_ANCHOR_PLAYER_ICONS];

		if not tAnchorFrames then
			return;
		end

		for _, tFrame in pairs(tAnchorFrames) do
			if tFrame then
				tFrame:SetAlpha(0);
			end
		end

		return;

	end



	--
	local tButtonName;
	local tButtonAuras;
	function VUHDO_clearUnitAuraFrames(aButton)

		if not aButton then
			return;
		end

		tButtonName = aButton:GetName();
		tButtonAuras = VUHDO_AURA_FRAMES[tButtonName];

		if not tButtonAuras then
			return;
		end

		for tAnchorIndex, tAnchorFrames in pairs(tButtonAuras) do
			for tSlotIndex, tAuraFrame in pairs(tAnchorFrames) do
				if tAuraFrame then
					VUHDO_safeSetAttribute(tAuraFrame, "unit", nil);
					tAuraFrame["raidid"] = nil;
				end
			end
		end

		return;

	end



	--
	local tFrameName;
	local tButtonFrames;
	function VUHDO_releaseAllAuraFramesForButton(aButton)

		if not aButton then
			return;
		end

		tFrameName = aButton:GetName();
		tButtonFrames = VUHDO_AURA_FRAMES[tFrameName];

		if not tButtonFrames then
			return;
		end

		if not sAuraPools["icon"] or not sAuraPools["bar"] then
			VUHDO_AURA_FRAMES[tFrameName] = nil;

			return;
		end

		for tAnchorIndex, tAnchorFrames in pairs(tButtonFrames) do
			for tSlotIndex, tFrame in pairs(tAnchorFrames) do
				if tFrame then
					if tFrame["childBar"] then
						sAuraPools["bar"]:Release(tFrame);
					elseif tFrame["childB"] then
						sAuraPools["icon"]:Release(tFrame);
					end
				end
			end
		end

		VUHDO_AURA_FRAMES[tFrameName] = nil;

		return;

	end



	--
	local tButtonFramesRefresh;
	function VUHDO_refreshAuraFrameUnitsForButton(aButton)

		if not aButton then
			return;
		end

		tButtonFramesRefresh = VUHDO_AURA_FRAMES[aButton:GetName()];

		if not tButtonFramesRefresh then
			return;
		end

		for tAnchorIndex, tAnchorFramesRefresh in pairs(tButtonFramesRefresh) do
			for tSlotIndex, tFrame in pairs(tAnchorFramesRefresh) do
				if tFrame and aButton["raidid"] then
					VUHDO_safeSetAttribute(tFrame, "unit", aButton["raidid"]);

					tFrame["raidid"] = aButton["raidid"];
				end
			end
		end

		return;

	end



	--
	function VUHDO_releaseAllAuraFrames()

		if sAuraTimer["animGroup"] then
			sAuraTimer["animGroup"]:Stop();
		end

		twipe(sAuraTimer["data"]);
		twipe(sAuraTimer["isAlive"]);
		twipe(sAuraTimer["durationMode"]);
		twipe(sAuraTimer["timerThreshold"]);
		twipe(sAuraTimer["flashData"]);
		twipe(sAuraTimer["flashThreshold"]);
		twipe(sAuraTimer["fadeData"]);
		twipe(sAuraTimer["fadeThreshold"]);

		sAuraTimer["count"] = 0;
		sAuraTimer["flashCount"] = 0;
		sAuraTimer["fadeCount"] = 0;

		if sAuraPools["icon"] then
			sAuraPools["icon"]:ReleaseAll();
		end

		if sAuraPools["bar"] then
			sAuraPools["bar"]:ReleaseAll();
		end

		twipe(VUHDO_AURA_FRAMES);

		return;

	end



	--
	function VUHDO_suspendAuras(aSuspend)

		sAurasSuspended = aSuspend;

		return;

	end



	--
	function VUHDO_hideAllAuras()

		for tButtonName, tButtonFrames in pairs(VUHDO_AURA_FRAMES) do
			for tAnchorIndex, tAnchorFrames in pairs(tButtonFrames) do
				for tSlotIndex, tFrame in pairs(tAnchorFrames) do
					if tFrame then
						tFrame:SetAlpha(0);
					end
				end
			end
		end

		return;

	end



	--
	local tButtonName;
	function VUHDO_hideAurasForUnit(aUnit)

		if not aUnit then
			return;
		end

		for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
			tButtonName = tButton:GetName();

			if VUHDO_AURA_FRAMES[tButtonName] then
				for tAnchorIndex, tAnchorFrames in pairs(VUHDO_AURA_FRAMES[tButtonName]) do
					for tSlotIndex, tFrame in pairs(tAnchorFrames) do
						if tFrame then
							tFrame:SetAlpha(0);
						end
					end
				end
			end
		end

		return;

	end



	--
	function VUHDO_showAllAuras()

		for tUnit, _ in pairs(VUHDO_RAID) do
			VUHDO_updateAuraDisplaysForUnit(tUnit);
		end

		return;

	end
end



do
	--
	local tButtonName;
	local tState;
	function VUHDO_resetFixedAuraOverflowState(aButton, anAnchorIndex)

		if not aButton then
			return;
		end

		tButtonName = aButton:GetName();

		if not tButtonName then
			return;
		end

		if not VUHDO_FIXED_AURA_OVERFLOW_STATE[tButtonName] then
			VUHDO_FIXED_AURA_OVERFLOW_STATE[tButtonName] = { };
		end

		tState = VUHDO_FIXED_AURA_OVERFLOW_STATE[tButtonName][anAnchorIndex];

		if tState and tState["slotAssignments"] then
			for tSlotIdx, tAssignment in pairs(tState["slotAssignments"]) do
				if tAssignment then
					sAuraPools["slotAssignment"]:release(tAssignment);
				end
			end
		end

		VUHDO_FIXED_AURA_OVERFLOW_STATE[tButtonName][anAnchorIndex] = {
			["anchorCounts"] = { },
			["slotAssignments"] = { },
		};

		return;

	end



	--
	local tState;
	local tAnchorCounts;
	local tMaxCols;
	local tMaxRows;
	local tAnchorCapacity;
	local tBaseAnchor;
	local tLayerIndex;
	local tNumBasePositions;
	local tStartAnchor;
	local tCheckedCount;
	local tAssignment;
	function VUHDO_assignFixedOverflowSlot(aButton, anAnchorIndex, aSlotIndex, anAnchorConfig)

		if not aButton or not anAnchorIndex or not aSlotIndex or not anAnchorConfig then
			return nil, nil;
		end

		tButtonName = aButton:GetName();

		if not tButtonName then
			return nil, nil;
		end

		tState = VUHDO_FIXED_AURA_OVERFLOW_STATE[tButtonName] and VUHDO_FIXED_AURA_OVERFLOW_STATE[tButtonName][anAnchorIndex];

		if not tState then
			return nil, nil;
		end

		tNumBasePositions = 9;

		if aSlotIndex <= tNumBasePositions then
			tAnchorCounts = tState["anchorCounts"];
			tAnchorCounts[aSlotIndex] = (tAnchorCounts[aSlotIndex] or 0) + 1;

			tAssignment = tState["slotAssignments"][aSlotIndex];

			if tAssignment then
				sAuraPools["slotAssignment"]:release(tAssignment);
			end

			tAssignment = sAuraPools["slotAssignment"]:get();

			tAssignment["baseAnchor"] = aSlotIndex;
			tAssignment["layerIndex"] = 0;

			tState["slotAssignments"][aSlotIndex] = tAssignment;

			return aSlotIndex, 0;
		end

		tMaxCols = anAnchorConfig["maxColumns"] or 5;
		tMaxRows = anAnchorConfig["maxRows"] or 1;
		tAnchorCapacity = tMaxCols * tMaxRows;

		tAnchorCounts = tState["anchorCounts"];
		tStartAnchor = ((aSlotIndex - 1) % tNumBasePositions) + 1;
		tCheckedCount = 0;
		tBaseAnchor = tStartAnchor;

		while tCheckedCount < tNumBasePositions do
			if (tAnchorCounts[tBaseAnchor] or 0) < tAnchorCapacity then
				tLayerIndex = tAnchorCounts[tBaseAnchor] or 0;
				tAnchorCounts[tBaseAnchor] = tLayerIndex + 1;

				tAssignment = tState["slotAssignments"][aSlotIndex];

				if tAssignment then
					sAuraPools["slotAssignment"]:release(tAssignment);
				end

				tAssignment = sAuraPools["slotAssignment"]:get();

				tAssignment["baseAnchor"] = tBaseAnchor;
				tAssignment["layerIndex"] = tLayerIndex;

				tState["slotAssignments"][aSlotIndex] = tAssignment;

				return tBaseAnchor, tLayerIndex;
			end

			tBaseAnchor = (tBaseAnchor % tNumBasePositions) + 1;
			tCheckedCount = tCheckedCount + 1;
		end

		return nil, nil;

	end



	--
	local tAssignment;
	function VUHDO_getFixedOverflowAssignment(aButton, anAnchorIndex, aSlotIndex, anAnchorConfig)

		if not aButton or not anAnchorIndex or not aSlotIndex then
			return nil, nil;
		end

		tButtonName = aButton:GetName();

		if not tButtonName then
			return nil, nil;
		end

		tState = VUHDO_FIXED_AURA_OVERFLOW_STATE[tButtonName] and VUHDO_FIXED_AURA_OVERFLOW_STATE[tButtonName][anAnchorIndex];

		if not tState then
			return nil, nil;
		end

		tAssignment = tState["slotAssignments"][aSlotIndex];

		if tAssignment then
			return tAssignment["baseAnchor"], tAssignment["layerIndex"];
		end

		return VUHDO_assignFixedOverflowSlot(aButton, anAnchorIndex, aSlotIndex, anAnchorConfig);

	end
end



do
	--
	local tPos;
	local tRelFrame;
	local tBaseX;
	local tBaseY;
	local tPanelNum;
	local tHealthBarWidth;
	local tHealthBarHeight;
	local tGrowthDir;
	local tWrapDir;
	local tSize;
	local tSpacing;
	local tMaxCols;
	local tCol;
	local tRow;
	local tGrowX;
	local tGrowY;
	local tWrapX;
	local tWrapY;
	local tXOff;
	local tYOff;
	local tBarWidth;
	local tBarHeight;
	local tIconSize;
	local tTotalWidth;
	local tTotalHeight;
	local tBarVertical;
	local tBarTurnAxis;
	function VUHDO_positionAuraFrameDynamic(aFrame, aSlotIndex, anAnchorConfig, aButton, aRadioValue)

		tPos = VUHDO_AURA_RADIOVALUE_POSITIONS[aRadioValue];

		if not tPos then
			return;
		end

		if "HealthBar" == tPos["relFrame"] then
			tRelFrame = VUHDO_getHealthBar(aButton, 1);
		else
			tRelFrame = aButton;
		end

		if not tRelFrame then
			return;
		end

		tPanelNum = VUHDO_BUTTON_CACHE and VUHDO_BUTTON_CACHE[aButton];
		tHealthBarWidth = tPanelNum and VUHDO_getHealthBarWidth(tPanelNum) or 80;

		if anAnchorConfig["barVertical"] then
			tHealthBarHeight = sPanelBarHeights[tPanelNum] or 40;
		else
			tHealthBarHeight = tPanelNum and VUHDO_getHealthBarHeight(tPanelNum) or 40;
		end

		tBaseX = (anAnchorConfig["offsetX"] or 0) * tHealthBarWidth * 0.01;
		tBaseY = -(anAnchorConfig["offsetY"] or 0) * tHealthBarHeight * 0.01;

		if aRadioValue ~= 17 then
			tBaseX = (tPos["xOffset"] or 0) + tBaseX;
			tBaseY = (tPos["yOffset"] or 0) + tBaseY;
		end

		tGrowthDir = sGrowthOffsets[anAnchorConfig["growthDir"]] or sGrowthOffsets["RIGHT"];
		tWrapDir = sGrowthOffsets[anAnchorConfig["wrapDir"]] or sGrowthOffsets["DOWN"];
		tSize = VUHDO_getAuraIconSizePixels(aButton, anAnchorConfig);
		tSpacing = anAnchorConfig["spacing"] or 2;
		tMaxCols = anAnchorConfig["maxColumns"] or 5;

		if aFrame["childBar"] then
			tBarVertical = anAnchorConfig["barVertical"] or false;
			tBarTurnAxis = anAnchorConfig["barTurnAxis"] or false;

			if (anAnchorConfig["iconType"] or 1) == 5 then
				if tBarVertical then
					tBarWidth = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);
					tBarHeight = VUHDO_getAuraBarHeightPixelsVertical(aButton, anAnchorConfig);

					tIconSize = 0;
					tTotalHeight = tBarHeight;
					tTotalWidth = tBarWidth;
				else
					tBarWidth = VUHDO_getAuraBarWidthPixels(aButton, anAnchorConfig);
					tBarHeight = VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig);

					tIconSize = 0;
					tTotalWidth = tBarWidth;
				end
			elseif tBarVertical then
				tBarWidth = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);
				tBarHeight = VUHDO_getAuraBarHeightPixelsVertical(aButton, anAnchorConfig);

				tIconSize = tBarWidth;

				tTotalHeight = tIconSize + tBarHeight;
				tTotalWidth = tIconSize;
			else
				tBarWidth = VUHDO_getAuraBarWidthPixels(aButton, anAnchorConfig);
				tBarHeight = VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig);

				tIconSize = tBarHeight;

				tTotalWidth = tIconSize + tBarWidth;
			end
		else
			tBarWidth = tSize;
			tBarHeight = tSize;

			tIconSize = 0;
			tTotalWidth = tSize;
		end

		tCol = (aSlotIndex - 1) % tMaxCols;
		tRow = floor((aSlotIndex - 1) / tMaxCols);
		tGrowX = tGrowthDir[1];
		tGrowY = tGrowthDir[2];
		tWrapX = tWrapDir[1];
		tWrapY = tWrapDir[2];

		if aFrame["childBar"] and tBarVertical then
			tXOff = tBaseX + (tCol * (tTotalWidth + tSpacing) * tGrowX) + (tRow * (tTotalWidth + tSpacing) * tWrapX);
			tYOff = tBaseY + (tCol * (tTotalHeight + tSpacing) * tGrowY) + (tRow * (tTotalHeight + tSpacing) * tWrapY);
		else
			tXOff = tBaseX + (tCol * (tTotalWidth + tSpacing) * tGrowX) + (tRow * (tTotalWidth + tSpacing) * tWrapX);
			tYOff = tBaseY + (tCol * (tBarHeight + tSpacing) * tGrowY) + (tRow * (tBarHeight + tSpacing) * tWrapY);
		end

		aFrame:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(aFrame, tPos["anchor"], tRelFrame, tPos["relPoint"], tXOff, tYOff);

		if aFrame["childBar"] and tBarVertical then
			VUHDO_PixelUtil.SetSize(aFrame, tTotalWidth, tTotalHeight);
		else
			VUHDO_PixelUtil.SetSize(aFrame, tTotalWidth, tBarHeight);
		end

		if aFrame["iconFrame"] and aFrame["childBar"] then
			if (anAnchorConfig["iconType"] or 1) == 5 then
				aFrame["iconFrame"]:Hide();
				aFrame["childBar"]:ClearAllPoints();
				aFrame["childBar"]:SetAllPoints(aFrame);
			else
				aFrame["iconFrame"]:ClearAllPoints();
				if tBarVertical then
					if tBarTurnAxis then
						VUHDO_PixelUtil.SetPoint(aFrame["iconFrame"], "TOP", aFrame, "TOP", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["iconFrame"], tIconSize, tIconSize);
						aFrame["iconFrame"]:Show();

						if aFrame["cooldownFrame"] and aFrame["iconFrame"] then
							aFrame["cooldownFrame"]:ClearAllPoints();
							aFrame["cooldownFrame"]:SetAllPoints(aFrame["iconFrame"]);
						end

						if aFrame["chargeTexture"] and aFrame["iconFrame"] then
							aFrame["chargeTexture"]:ClearAllPoints();
							aFrame["chargeTexture"]:SetAllPoints(aFrame["iconFrame"]);
						end

						aFrame["childBar"]:ClearAllPoints();
						VUHDO_PixelUtil.SetPoint(aFrame["childBar"], "TOP", aFrame["iconFrame"], "BOTTOM", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["childBar"], tIconSize, aFrame:GetHeight() - aFrame["iconFrame"]:GetHeight());
					else
						VUHDO_PixelUtil.SetPoint(aFrame["iconFrame"], "BOTTOM", aFrame, "BOTTOM", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["iconFrame"], tIconSize, tIconSize);
						aFrame["iconFrame"]:Show();

						if aFrame["cooldownFrame"] and aFrame["iconFrame"] then
							aFrame["cooldownFrame"]:ClearAllPoints();
							aFrame["cooldownFrame"]:SetAllPoints(aFrame["iconFrame"]);
						end

						if aFrame["chargeTexture"] and aFrame["iconFrame"] then
							aFrame["chargeTexture"]:ClearAllPoints();
							aFrame["chargeTexture"]:SetAllPoints(aFrame["iconFrame"]);
						end

						aFrame["childBar"]:ClearAllPoints();
						VUHDO_PixelUtil.SetPoint(aFrame["childBar"], "BOTTOM", aFrame["iconFrame"], "TOP", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["childBar"], tIconSize, aFrame:GetHeight() - aFrame["iconFrame"]:GetHeight());
					end
				else
					if tBarTurnAxis then
						VUHDO_PixelUtil.SetPoint(aFrame["iconFrame"], "RIGHT", aFrame, "RIGHT", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["iconFrame"], tIconSize, tIconSize);
						aFrame["iconFrame"]:Show();

						if aFrame["cooldownFrame"] and aFrame["iconFrame"] then
							aFrame["cooldownFrame"]:ClearAllPoints();
							aFrame["cooldownFrame"]:SetAllPoints(aFrame["iconFrame"]);
						end

						if aFrame["chargeTexture"] and aFrame["iconFrame"] then
							aFrame["chargeTexture"]:ClearAllPoints();
							aFrame["chargeTexture"]:SetAllPoints(aFrame["iconFrame"]);
						end

						aFrame["childBar"]:ClearAllPoints();
						VUHDO_PixelUtil.SetPoint(aFrame["childBar"], "RIGHT", aFrame["iconFrame"], "LEFT", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["childBar"], aFrame:GetWidth() - aFrame["iconFrame"]:GetWidth(), tBarHeight);
					else
						VUHDO_PixelUtil.SetPoint(aFrame["iconFrame"], "LEFT", aFrame, "LEFT", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["iconFrame"], tIconSize, tIconSize);
						aFrame["iconFrame"]:Show();

						if aFrame["cooldownFrame"] and aFrame["iconFrame"] then
							aFrame["cooldownFrame"]:ClearAllPoints();
							aFrame["cooldownFrame"]:SetAllPoints(aFrame["iconFrame"]);
						end

						if aFrame["chargeTexture"] and aFrame["iconFrame"] then
							aFrame["chargeTexture"]:ClearAllPoints();
							aFrame["chargeTexture"]:SetAllPoints(aFrame["iconFrame"]);
						end

						aFrame["childBar"]:ClearAllPoints();
						VUHDO_PixelUtil.SetPoint(aFrame["childBar"], "LEFT", aFrame["iconFrame"], "RIGHT", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["childBar"], aFrame:GetWidth() - aFrame["iconFrame"]:GetWidth(), tBarHeight);
					end
				end
			end
		end

		VUHDO_constrainAuraFrameHitRect(aFrame, aButton);

		return;

	end



	--
	local tFrameLeft;
	local tFrameRight;
	local tFrameTop;
	local tFrameBottom;
	local tButtonLeft;
	local tButtonRight;
	local tButtonTop;
	local tButtonBottom;
	local tInsetLeft;
	local tInsetRight;
	local tInsetTop;
	local tInsetBottom;
	function VUHDO_constrainAuraFrameHitRect(aFrame, aButton)

		if not aFrame or not aButton then
			return;
		end

		tFrameLeft = aFrame:GetLeft();
		tFrameRight = aFrame:GetRight();
		tFrameTop = aFrame:GetTop();
		tFrameBottom = aFrame:GetBottom();

		tButtonLeft = aButton:GetLeft();
		tButtonRight = aButton:GetRight();
		tButtonTop = aButton:GetTop();
		tButtonBottom = aButton:GetBottom();

		if not tFrameLeft or not tButtonLeft then
			return;
		end

		tInsetLeft = max(0, tButtonLeft - tFrameLeft);
		tInsetRight = max(0, tFrameRight - tButtonRight);
		tInsetTop = max(0, tFrameTop - tButtonTop);
		tInsetBottom = max(0, tButtonBottom - tFrameBottom);

		if tInsetLeft > 0 or tInsetRight > 0 or tInsetTop > 0 or tInsetBottom > 0 then
			aFrame:SetHitRectInsets(tInsetLeft, tInsetRight, tInsetTop, tInsetBottom);
		else
			aFrame:SetHitRectInsets(0, 0, 0, 0);
		end

		return;

	end



	--
	local tSlotPos;
	local tRelFrame;
	local tBarWidth;
	local tBarHeight;
	local tXOff;
	local tYOff;
	local tPanelNum;
	local tSize;
	local tNumBasePositions;
	local tBaseAnchor;
	local tLayerIndex;
	local tGrowthDir;
	local tWrapDir;
	local tSpacing;
	local tMaxCols;
	local tCol;
	local tRow;
	local tGrowX;
	local tGrowY;
	local tWrapX;
	local tWrapY;
	local tGrowthXOff;
	local tGrowthYOff;
	function VUHDO_positionAuraFrameFixed(aFrame, aSlotIndex, aPositionTable, aButton, anAnchorConfig, anAnchorIndex)

		tNumBasePositions = 9;

		if aSlotIndex <= tNumBasePositions then
			tSlotPos = aPositionTable[aSlotIndex];
			tLayerIndex = 0;

			VUHDO_assignFixedOverflowSlot(aButton, anAnchorIndex, aSlotIndex, anAnchorConfig);
		else
			tBaseAnchor, tLayerIndex = VUHDO_getFixedOverflowAssignment(aButton, anAnchorIndex, aSlotIndex, anAnchorConfig);

			if not tBaseAnchor then
				aFrame:SetAlpha(0);

				return;
			end

			tSlotPos = aPositionTable[tBaseAnchor];
		end

		if not tSlotPos then
			return;
		end

		tRelFrame = VUHDO_getHealthBar(aButton, 1);

		if not tRelFrame then
			return;
		end

		tPanelNum = VUHDO_BUTTON_CACHE[aButton];

		if not tPanelNum then
			tBarWidth = 0;
			tBarHeight = 0;
		else
			tBarWidth = VUHDO_getHealthBarWidth(tPanelNum);

			if anAnchorConfig["barVertical"] then
				tBarHeight = sPanelBarHeights[tPanelNum] or 0;
			else
				tBarHeight = VUHDO_getHealthBarHeight(tPanelNum);
			end
		end

		tXOff = (tSlotPos["xPercent"] or 0) * tBarWidth;
		tYOff = (tSlotPos["yPercent"] or 0) * tBarHeight;

		tSize = VUHDO_getAuraIconSizePixels(aButton, anAnchorConfig);

		if tLayerIndex and tLayerIndex > 0 then
			tGrowthDir = sGrowthOffsets[anAnchorConfig["growthDir"]] or sGrowthOffsets["RIGHT"];
			tWrapDir = sGrowthOffsets[anAnchorConfig["wrapDir"]] or sGrowthOffsets["DOWN"];
			tSpacing = anAnchorConfig["spacing"] or 2;
			tMaxCols = anAnchorConfig["maxColumns"] or 5;

			tCol = tLayerIndex % tMaxCols;
			tRow = floor(tLayerIndex / tMaxCols);

			tGrowX = tGrowthDir[1];
			tGrowY = tGrowthDir[2];
			tWrapX = tWrapDir[1];
			tWrapY = tWrapDir[2];

			tGrowthXOff = (tCol * (tSize + tSpacing) * tGrowX) + (tRow * (tSize + tSpacing) * tWrapX);
			tGrowthYOff = (tCol * (tSize + tSpacing) * tGrowY) + (tRow * (tSize + tSpacing) * tWrapY);

			tXOff = tXOff + tGrowthXOff;
			tYOff = tYOff + tGrowthYOff;
		end

		aFrame:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(aFrame, tSlotPos["anchor"], tRelFrame, tSlotPos["relPoint"], tXOff, tYOff);
		VUHDO_PixelUtil.SetSize(aFrame, tSize, tSize);

		return;

	end
end



do
	--
	local tRadioValue;
	local tAnchorPoint;
	local tGrowthDir;
	local tWrapDir;
	local tSize;
	local tSpacing;
	local tMaxCols;
	local tCol;
	local tRow;
	local tXOff;
	local tYOff;
	local tPanelNum;
	local tHealthBarWidth;
	local tHealthBarHeight;
	local tOffsetXPixels;
	local tOffsetYPixels;
	local tGrowX;
	local tGrowY;
	local tWrapX;
	local tWrapY;
	local tParent;
	local tChild;
	local tTexture;
	local tBarWidth;
	local tBarHeight;
	local tIconSize;
	local tTotalWidth;
	local tTotalHeight;
	local tBarVertical;
	local tBarTurnAxis;
	function VUHDO_positionAuraFrame(aFrame, aButton, anAnchorConfig, aSlotIndex, anAnchorIndex)

		if not aFrame or not aButton or not anAnchorConfig then
			return;
		end

		tRadioValue = anAnchorConfig["radioValue"];

		tSize = VUHDO_getAuraIconSizePixels(aButton, anAnchorConfig);
		tBarWidth = VUHDO_getAuraBarWidthPixels(aButton, anAnchorConfig);
		tBarHeight = VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig);
		tIconSize = tBarHeight;

		if tRadioValue and tRadioValue <= 17 then
			VUHDO_positionAuraFrameDynamic(aFrame, aSlotIndex, anAnchorConfig, aButton, tRadioValue);
		elseif tRadioValue and 30 == tRadioValue then
			VUHDO_positionAuraFrameFixed(aFrame, aSlotIndex, VUHDO_AURA_FIXED_STRAIGHT_POSITIONS, aButton, anAnchorConfig, anAnchorIndex);
		elseif tRadioValue and 31 == tRadioValue then
			VUHDO_positionAuraFrameFixed(aFrame, aSlotIndex, VUHDO_AURA_FIXED_DIAGONAL_POSITIONS, aButton, anAnchorConfig, anAnchorIndex);
		else
			tAnchorPoint = sAnchorPoints[anAnchorConfig["position"]] or sAnchorPoints["TOPRIGHT"];
			tGrowthDir = sGrowthOffsets[anAnchorConfig["growthDir"]] or sGrowthOffsets["LEFT"];
			tWrapDir = sGrowthOffsets[anAnchorConfig["wrapDir"]] or sGrowthOffsets["DOWN"];

			tSize = VUHDO_getAuraIconSizePixels(aButton, anAnchorConfig);
			tSpacing = anAnchorConfig["spacing"] or 2;
			tMaxCols = anAnchorConfig["maxColumns"] or 5;

			if aFrame["iconFrame"] then
				tBarVertical = anAnchorConfig["barVertical"] or false;

				if (anAnchorConfig["iconType"] or 1) == 5 then
					if tBarVertical then
						tBarWidth = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);
						tBarHeight = VUHDO_getAuraBarHeightPixelsVertical(aButton, anAnchorConfig);

						tIconSize = 0;
						tTotalHeight = tBarHeight;
						tTotalWidth = tBarWidth;
					else
						tBarWidth = VUHDO_getAuraBarWidthPixels(aButton, anAnchorConfig);
						tBarHeight = VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig);

						tIconSize = 0;
						tTotalWidth = tBarWidth;
					end
				elseif tBarVertical then
					tBarWidth = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);
					tBarHeight = VUHDO_getAuraBarHeightPixelsVertical(aButton, anAnchorConfig);

					tIconSize = tBarWidth;

					tTotalHeight = tIconSize + tBarHeight;
					tTotalWidth = tIconSize;
				else
					tBarWidth = VUHDO_getAuraBarWidthPixels(aButton, anAnchorConfig);
					tBarHeight = VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig);

					tIconSize = tBarHeight;

					tTotalWidth = tIconSize + tBarWidth;
				end
			else
				tBarWidth = tSize;
				tBarHeight = tSize;

				tIconSize = 0;
				tTotalWidth = tBarWidth;
			end

			tCol = (aSlotIndex - 1) % tMaxCols;
			tRow = floor((aSlotIndex - 1) / tMaxCols);

			tGrowX = tGrowthDir[1];
			tGrowY = tGrowthDir[2];
			tWrapX = tWrapDir[1];
			tWrapY = tWrapDir[2];

			tPanelNum = VUHDO_BUTTON_CACHE and VUHDO_BUTTON_CACHE[aButton];

			tHealthBarWidth = tPanelNum and VUHDO_getHealthBarWidth(tPanelNum) or 80;

			if anAnchorConfig["barVertical"] then
				tHealthBarHeight = sPanelBarHeights[tPanelNum] or 40;
			else
				tHealthBarHeight = tPanelNum and VUHDO_getHealthBarHeight(tPanelNum) or 40;
			end

			tOffsetXPixels = (anAnchorConfig["offsetX"] or 0) * tHealthBarWidth * 0.01;
			tOffsetYPixels = -(anAnchorConfig["offsetY"] or 0) * tHealthBarHeight * 0.01;

			if aFrame["childBar"] and tBarVertical then
				tXOff = tOffsetXPixels + (tCol * (tTotalWidth + tSpacing) * tGrowX) + (tRow * (tTotalWidth + tSpacing) * tWrapX);
				tYOff = tOffsetYPixels + (tCol * (tTotalHeight + tSpacing) * tGrowY) + (tRow * (tTotalHeight + tSpacing) * tWrapY);
			else
				tXOff = tOffsetXPixels + (tCol * (tTotalWidth + tSpacing) * tGrowX) + (tRow * (tTotalWidth + tSpacing) * tWrapX);
				tYOff = tOffsetYPixels + (tCol * (tBarHeight + tSpacing) * tGrowY) + (tRow * (tBarHeight + tSpacing) * tWrapY);
			end

			aFrame:ClearAllPoints();
			VUHDO_PixelUtil.SetPoint(aFrame, tAnchorPoint[1], aButton, tAnchorPoint[1], tXOff, tYOff);

			if aFrame["childBar"] and tBarVertical then
				VUHDO_PixelUtil.SetSize(aFrame, tTotalWidth, tTotalHeight);
			else
				VUHDO_PixelUtil.SetSize(aFrame, tTotalWidth, tBarHeight);
			end
		end

		tChild = aFrame["childB"] or aFrame["childBar"] or VUHDO_getAuraIconBackdrop(aFrame) or VUHDO_getAuraBarStatusBar(aFrame);

		if tChild then
			tChild:ClearAllPoints();

			if aFrame["iconFrame"] and aFrame["childBar"] then
				if (anAnchorConfig["iconType"] or 1) == 5 then
					aFrame["iconFrame"]:Hide();
					tChild:ClearAllPoints();
					tChild:SetAllPoints(aFrame);
				else
					tBarVertical = anAnchorConfig["barVertical"] or false;
					tBarTurnAxis = anAnchorConfig["barTurnAxis"] or false;

					if tBarVertical then
						tBarWidth = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);
						tBarHeight = VUHDO_getAuraBarHeightPixelsVertical(aButton, anAnchorConfig);

						tIconSize = tBarWidth;

						aFrame["iconFrame"]:ClearAllPoints();

						if tBarTurnAxis then
							VUHDO_PixelUtil.SetPoint(aFrame["iconFrame"], "TOP", aFrame, "TOP", 0, 0);
							VUHDO_PixelUtil.SetSize(aFrame["iconFrame"], tIconSize, tIconSize);
							aFrame["iconFrame"]:Show();

							if aFrame["cooldownFrame"] and aFrame["iconFrame"] then
								aFrame["cooldownFrame"]:ClearAllPoints();
								aFrame["cooldownFrame"]:SetAllPoints(aFrame["iconFrame"]);
							end

							if aFrame["chargeTexture"] and aFrame["iconFrame"] then
								aFrame["chargeTexture"]:ClearAllPoints();
								aFrame["chargeTexture"]:SetAllPoints(aFrame["iconFrame"]);
							end

							tChild:ClearAllPoints();
							VUHDO_PixelUtil.SetPoint(tChild, "TOP", aFrame["iconFrame"], "BOTTOM", 0, 0);
							VUHDO_PixelUtil.SetSize(tChild, tIconSize, tBarHeight);
						else
							VUHDO_PixelUtil.SetPoint(aFrame["iconFrame"], "BOTTOM", aFrame, "BOTTOM", 0, 0);
							VUHDO_PixelUtil.SetSize(aFrame["iconFrame"], tIconSize, tIconSize);
							aFrame["iconFrame"]:Show();

							if aFrame["cooldownFrame"] and aFrame["iconFrame"] then
								aFrame["cooldownFrame"]:ClearAllPoints();
								aFrame["cooldownFrame"]:SetAllPoints(aFrame["iconFrame"]);
							end

							if aFrame["chargeTexture"] and aFrame["iconFrame"] then
								aFrame["chargeTexture"]:ClearAllPoints();
								aFrame["chargeTexture"]:SetAllPoints(aFrame["iconFrame"]);
							end

							tChild:ClearAllPoints();
							VUHDO_PixelUtil.SetPoint(tChild, "BOTTOM", aFrame["iconFrame"], "TOP", 0, 0);
							VUHDO_PixelUtil.SetSize(tChild, tIconSize, tBarHeight);
						end
					else
						aFrame["iconFrame"]:ClearAllPoints();

						if tBarTurnAxis then
							VUHDO_PixelUtil.SetPoint(aFrame["iconFrame"], "RIGHT", aFrame, "RIGHT", 0, 0);
							VUHDO_PixelUtil.SetSize(aFrame["iconFrame"], tIconSize, tIconSize);
							aFrame["iconFrame"]:Show();

							if aFrame["cooldownFrame"] and aFrame["iconFrame"] then
								aFrame["cooldownFrame"]:ClearAllPoints();
								aFrame["cooldownFrame"]:SetAllPoints(aFrame["iconFrame"]);
							end

							if aFrame["chargeTexture"] and aFrame["iconFrame"] then
								aFrame["chargeTexture"]:ClearAllPoints();
								aFrame["chargeTexture"]:SetAllPoints(aFrame["iconFrame"]);
							end

							tChild:ClearAllPoints();
							VUHDO_PixelUtil.SetPoint(tChild, "RIGHT", aFrame["iconFrame"], "LEFT", 0, 0);
							VUHDO_PixelUtil.SetSize(tChild, tBarWidth, tBarHeight);
						else
							VUHDO_PixelUtil.SetPoint(aFrame["iconFrame"], "LEFT", aFrame, "LEFT", 0, 0);
							VUHDO_PixelUtil.SetSize(aFrame["iconFrame"], tIconSize, tIconSize);
							aFrame["iconFrame"]:Show();

							if aFrame["cooldownFrame"] and aFrame["iconFrame"] then
								aFrame["cooldownFrame"]:ClearAllPoints();
								aFrame["cooldownFrame"]:SetAllPoints(aFrame["iconFrame"]);
							end

							if aFrame["chargeTexture"] and aFrame["iconFrame"] then
								aFrame["chargeTexture"]:ClearAllPoints();
								aFrame["chargeTexture"]:SetAllPoints(aFrame["iconFrame"]);
							end

							tChild:ClearAllPoints();
							VUHDO_PixelUtil.SetPoint(tChild, "LEFT", aFrame["iconFrame"], "RIGHT", 0, 0);
							VUHDO_PixelUtil.SetSize(tChild, tBarWidth, tBarHeight);
						end
					end

					tSize = tIconSize;

					if aFrame["timerText"] and anAnchorConfig["TIMER_TEXT"] then
						VUHDO_customizeIconText(aFrame["iconFrame"], tSize, aFrame["timerText"], anAnchorConfig["TIMER_TEXT"]);
					end

					if aFrame["countText"] and anAnchorConfig["COUNTER_TEXT"] then
						VUHDO_customizeIconText(aFrame["iconFrame"], tSize, aFrame["countText"], anAnchorConfig["COUNTER_TEXT"]);
					end
				end
			else
				tChild:SetAllPoints(aFrame);

				tTexture = tChild["textureI"] or VUHDO_getAuraIconTexture(tChild);

				if tTexture and tTexture.SetAllPoints then
					tTexture:SetAllPoints(tChild);
				end
			end

			tChild:SetAlpha(1);

			tSize = VUHDO_getAuraIconSizePixels(aButton, anAnchorConfig);

			if tChild["timerText"] and anAnchorConfig["TIMER_TEXT"] then
				VUHDO_customizeIconText(tChild, tSize, tChild["timerText"], anAnchorConfig["TIMER_TEXT"]);
			end

			if tChild["countText"] and anAnchorConfig["COUNTER_TEXT"] then
				VUHDO_customizeIconText(tChild, tSize, tChild["countText"], anAnchorConfig["COUNTER_TEXT"]);
			end
		end

		tParent = aFrame:GetParent();

		if tParent then
			VUHDO_PixelUtil.SetFrameStrata(aFrame, tParent:GetFrameStrata());
			VUHDO_PixelUtil.SetFrameLevel(aFrame, tParent:GetFrameLevel() + (aFrame["addLevel"] or 10));
		end

		VUHDO_constrainAuraFrameHitRect(aFrame, aButton);

		return;

	end
end



--
local tPanelAnchors;
function VUHDO_initAuraAnchorsForButton(aButton, aPanelNum)

	if not aButton or not aPanelNum then
		return;
	end

	if InCombatLockdown() then
		return;
	end

	tPanelAnchors = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"];

	if not tPanelAnchors then
		return;
	end

	if aButton["auraConfigVersion"] == sAuraAnchorConfigVersion and aButton["auraPanelNum"] == aPanelNum and VUHDO_AURA_FRAMES[aButton:GetName()] then
		VUHDO_refreshAuraFrameUnitsForButton(aButton);

		return;
	end

	VUHDO_releaseAllAuraFramesForButton(aButton);

	for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
		VUHDO_initAuraAnchorFrames(aButton, aPanelNum, tAnchorIndex, tAnchorConfig);
	end

	aButton["auraConfigVersion"] = sAuraAnchorConfigVersion;
	aButton["auraPanelNum"] = aPanelNum;

	return;

end



--
local tFrame;
local tMaxSlots;
function VUHDO_initAuraAnchorFrames(aButton, aPanelNum, anAnchorIndex, anAnchorConfig)

	if not aButton or not anAnchorConfig then
		return;
	end

	tMaxSlots = anAnchorConfig["maxDisplay"] or 5;

	VUHDO_resetFixedAuraOverflowState(aButton, anAnchorIndex);

	for tSlotIndex = 1, tMaxSlots do
		if anAnchorConfig["style"] == "bars" then
			tFrame = VUHDO_acquireAuraBarFrame(aButton, anAnchorIndex, tSlotIndex);
		else
			tFrame = VUHDO_acquireAuraIconFrame(aButton, anAnchorIndex, tSlotIndex);
		end

		if tFrame then
			VUHDO_positionAuraFrame(tFrame, aButton, anAnchorConfig, tSlotIndex, anAnchorIndex);

			tFrame:SetAlpha(0);
			tFrame:Show();
		end
	end

	return;

end



--
local tPanelNum;
local tAnchorConfig;
local tShowTooltip;
function VUHDO_showAuraTooltip(aAuraFrame)

	if not aAuraFrame then
		return false;
	end

	tPanelNum = aAuraFrame["panelNum"];
	tAnchorConfig = nil;

	if tPanelNum and aAuraFrame["anchorIndex"] then
		tAnchorConfig = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"][aAuraFrame["anchorIndex"]];
	end

	tShowTooltip = sAnchorSettingsCache["showTooltip"][tPanelNum] and sAnchorSettingsCache["showTooltip"][tPanelNum][aAuraFrame["anchorIndex"]] or VUHDO_resolveAuraTriState(tAnchorConfig and tAnchorConfig["showTooltip"], "showTooltip");

	if not tShowTooltip then
		return false;
	end

	if not aAuraFrame["raidid"] then
		return false;
	end

	if GameTooltip:IsForbidden() then
		return false;
	end

	GameTooltip:SetOwner(aAuraFrame, "ANCHOR_RIGHT", 0, 0);

	if aAuraFrame["auraInstanceId"] and aAuraFrame["auraInstanceId"] >= 0 then
		GameTooltip:SetUnitAuraByAuraInstanceID(aAuraFrame["raidid"], aAuraFrame["auraInstanceId"]);

		return true;
	end

	return false;

end



--
function VUHDO_hideAuraTooltip()

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide();
	end

	return;

end



--
local tPanelAnchors;
local tAnchorSlots;
local tMaxSlots;
local tAnchorConfig;
function VUHDO_updateAurasForAnchors(aUnit, aPanelNum)

	if not aUnit or not aPanelNum then
		return;
	end

	tAnchorSlots = VUHDO_UNIT_AURA_SLOTS[aUnit] and VUHDO_UNIT_AURA_SLOTS[aUnit][aPanelNum];

	if not tAnchorSlots then
		return;
	end

	tPanelAnchors = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"];

	if not tPanelAnchors then
		return;
	end

	for tAnchorIndex, tSlots in pairs(tAnchorSlots) do
		tAnchorConfig = tPanelAnchors[tAnchorIndex];

		if tAnchorConfig then
			if tAnchorConfig["enabled"] == false then
				VUHDO_clearAurasForAnchor(aUnit, aPanelNum, tAnchorIndex, tAnchorConfig);
			else
				tMaxSlots = tAnchorConfig["maxDisplay"] or 5;
				VUHDO_displayAurasAtAnchorFromCache(aUnit, aPanelNum, tAnchorIndex, tAnchorConfig, tSlots, tMaxSlots);
			end
		end
	end

	return;

end



--
local tPanelAnchors;
local tGroup;
local tAnchorSlots;
local tSlots;
local tMaxSlots;
function VUHDO_updateInferredAuraDisplaysForUnit(aUnit)

	if not aUnit then
		return;
	end

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		tPanelAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

		if tPanelAnchors then
			for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
				if tAnchorConfig then
					if tAnchorConfig["enabled"] == false then
						VUHDO_clearAurasForAnchor(aUnit, tPanelNum, tAnchorIndex, tAnchorConfig);
					else
						tGroup = VUHDO_getAuraGroup(tAnchorConfig["groupId"]);

						if tGroup and tGroup["isInferred"] then
							VUHDO_rebuildSlotAssignmentsForAnchor(aUnit, tPanelNum, tAnchorIndex, tAnchorConfig);

							tAnchorSlots = VUHDO_UNIT_AURA_SLOTS[aUnit] and VUHDO_UNIT_AURA_SLOTS[aUnit][tPanelNum];

							if tAnchorSlots then
								tSlots = tAnchorSlots[tAnchorIndex];
								tMaxSlots = tAnchorConfig["maxDisplay"] or 5;

								VUHDO_displayAurasAtAnchorFromCache(aUnit, tPanelNum, tAnchorIndex, tAnchorConfig, tSlots, tMaxSlots);
							end
						end
					end
				end
			end
		end
	end

	return;

end



--
local tPanelUnitButtons;
local tMaxSlots;
function VUHDO_clearAurasForAnchor(aUnit, aPanelNum, anAnchorIndex, anAnchorConfig)

	if not aUnit or not aPanelNum or not anAnchorIndex or not anAnchorConfig then
		return;
	end

	tPanelUnitButtons = VUHDO_getUnitButtonsPanel(aUnit, aPanelNum);

	if not tPanelUnitButtons then
		return;
	end

	tMaxSlots = anAnchorConfig["maxDisplay"] or 5;

	for _, tButton in pairs(tPanelUnitButtons) do
		for tSlotIndex = 1, tMaxSlots do
			VUHDO_hideAuraSlot(tButton, anAnchorIndex, tSlotIndex, anAnchorConfig["style"] == "bars");
		end
	end

	for tSlotIndex = 1, tMaxSlots do
		VUHDO_setAnchorSlotAuraId(aUnit, aPanelNum, anAnchorIndex, tSlotIndex, nil);
	end

	return;

end



--
local tPanelUnitButtons;
local tAuraInstanceId;
local tAuraData;
local tGroup;
local tListSlots;
local tSlotData;
local tSlotDataAsAura;
local tFixedSlots;
local tDisplaySlotIndex;
local tActualSlot;
function VUHDO_displayAurasAtAnchorFromCache(aUnit, aPanelNum, anAnchorIndex, anAnchorConfig, anAnchorSlots, aMaxSlots)

	if not aUnit or not aPanelNum or not anAnchorIndex or not anAnchorConfig then
		return;
	end

	tPanelUnitButtons = VUHDO_getUnitButtonsPanel(aUnit, aPanelNum);

	if not tPanelUnitButtons or next(tPanelUnitButtons) == nil then
		return;
	end

	tGroup = VUHDO_getAuraGroup(anAnchorConfig["groupId"]);

	if tGroup and (tGroup["type"] or 1) == VUHDO_AURA_GROUP_TYPE_LIST then
		tListSlots = VUHDO_UNIT_AURA_LIST_SLOTS[aUnit] and VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][aPanelNum] and VUHDO_UNIT_AURA_LIST_SLOTS[aUnit][aPanelNum][anAnchorIndex];
		tFixedSlots = anAnchorConfig["fixedSlots"];

		for _, tButton in pairs(tPanelUnitButtons) do
			tDisplaySlotIndex = 0;

			for tSlotIndex = 1, aMaxSlots do
				tSlotData = tListSlots and tListSlots[tSlotIndex];

				if tSlotData and tSlotData["isActive"] then
					tDisplaySlotIndex = tDisplaySlotIndex + 1;
					tActualSlot = tFixedSlots and tSlotIndex or tDisplaySlotIndex;

					tSlotDataAsAura = sAuraPools["slotDataAsAura"]:get();

					tSlotDataAsAura["icon"] = tSlotData["icon"];
					tSlotDataAsAura["expirationTime"] = tSlotData["expirationTime"] or 0;
					tSlotDataAsAura["duration"] = tSlotData["duration"] or 0;
					tSlotDataAsAura["applications"] = tSlotData["stacks"] or 0;
					tSlotDataAsAura["name"] = tSlotData["name"];
					tSlotDataAsAura["auraInstanceID"] = tSlotData["auraInstanceID"] or -1;
					tSlotDataAsAura["clipL"] = tSlotData["clipL"];
					tSlotDataAsAura["clipR"] = tSlotData["clipR"];
					tSlotDataAsAura["clipT"] = tSlotData["clipT"];
					tSlotDataAsAura["clipB"] = tSlotData["clipB"];
					tSlotDataAsAura["color"] = tSlotData["color"];
					tSlotDataAsAura["isAliveTime"] = tSlotData["isAliveTime"];
					tSlotDataAsAura["groupId"] = tSlotData["groupId"];
					tSlotDataAsAura["entryIndex"] = tSlotData["entryIndex"];

					VUHDO_displayAuraInSlot(tButton, aPanelNum, anAnchorIndex, tActualSlot, tSlotDataAsAura, anAnchorConfig);

					sAuraPools["slotDataAsAura"]:release(tSlotDataAsAura);
				elseif tFixedSlots then
					VUHDO_hideAuraSlot(tButton, anAnchorIndex, tSlotIndex, anAnchorConfig["style"] == "bars");
				end
			end

			if not tFixedSlots then
				for tSlotIndex = tDisplaySlotIndex + 1, aMaxSlots do
					VUHDO_hideAuraSlot(tButton, anAnchorIndex, tSlotIndex, anAnchorConfig["style"] == "bars");
				end
			end
		end
	else
		for _, tButton in pairs(tPanelUnitButtons) do
			for tSlotIndex = 1, aMaxSlots do
				tAuraInstanceId = anAnchorSlots and anAnchorSlots[tSlotIndex];

				if tAuraInstanceId then
					tAuraData = VUHDO_UNIT_AURA_CACHE[aUnit] and VUHDO_UNIT_AURA_CACHE[aUnit][tAuraInstanceId];

					if tAuraData then
						VUHDO_displayAuraInSlot(tButton, aPanelNum, anAnchorIndex, tSlotIndex, tAuraData, anAnchorConfig);
					else
						VUHDO_hideAuraSlot(tButton, anAnchorIndex, tSlotIndex, anAnchorConfig["style"] == "bars");
					end
				else
					VUHDO_hideAuraSlot(tButton, anAnchorIndex, tSlotIndex, anAnchorConfig["style"] == "bars");
				end
			end
		end
	end

	return;

end



--
function VUHDO_displayAuraInSlot(aButton, aPanelNum, anAnchorIndex, aSlotIndex, anAuraData, anAnchorConfig)

	if not aButton or not anAnchorIndex or not aSlotIndex or not anAuraData or not anAnchorConfig then
		return;
	end

	if anAnchorConfig["style"] == "bars" then
		VUHDO_displayAuraAsBar(aButton, aPanelNum, anAnchorIndex, aSlotIndex, anAuraData, anAnchorConfig);
	else
		VUHDO_displayAuraAsIcon(aButton, aPanelNum, anAnchorIndex, aSlotIndex, anAuraData, anAnchorConfig);
	end

	return;

end



do
	--
	local tIconType;
	local tShowClock;
	local tFadeOnLow;
	local tFadeAlpha;
	local tDispelBorder;
	local tColorMixin;
	local tDispelR;
	local tDispelG;
	local tDispelB;
	local tDispelA;
	local tDispelCurve;
	local tColorMode;
	local tClassColor;
	local tIconColor;
	local tGroupId;
	local tEntryIndex;
	local tEntryColor;
	local tEntryOverride;
	local tFadeThreshold;
	function VUHDO_updateAuraIconDisplay(aIconTexture, aCooldownFrame, aBackdropFrame, anAnchorConfig, anAuraData, aDurationObj, aUnit, aPanelNum, anAnchorIndex)

		tIconType = anAnchorConfig["iconType"] or 1;

		if aIconTexture then
			if tIconType == 4 or tIconType == 5 then
				aIconTexture:Hide();
			elseif tIconType == 3 then
				aIconTexture:SetTexture("Interface\\AddOns\\VuhDo\\Images\\hot_flat_16_16");

				tGroupId = anAuraData["groupId"];
				tEntryIndex = anAuraData["entryIndex"];

				if tGroupId and tEntryIndex and sEntrySettingsCache["colorIcon"][tGroupId] and sEntrySettingsCache["colorIcon"][tGroupId][tEntryIndex] then
					tEntryColor = sEntrySettingsCache["colorIconColor"][tGroupId] and sEntrySettingsCache["colorIconColor"][tGroupId][tEntryIndex];

					if tEntryColor and tEntryColor["R"] then
						aIconTexture:SetVertexColor(tEntryColor["R"], tEntryColor["G"], tEntryColor["B"], tEntryColor["O"] or 1);
					else
						aIconTexture:SetVertexColor(1, 1, 1);
					end
				elseif anAuraData["color"] and anAuraData["color"]["R"] then
					aIconTexture:SetVertexColor(VUHDO_backColor(anAuraData["color"]));
				else
					tColorMode = anAnchorConfig["colorMode"] or "default";

					if "debuff" == tColorMode and anAuraData["dispelName"] then
						tDispelCurve = VUHDO_getDispelTypeCurve();

						if tDispelCurve and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
							tColorMixin = GetAuraDispelTypeColor(aUnit, anAuraData["auraInstanceID"], tDispelCurve);

							if tColorMixin then
								aIconTexture:SetVertexColor(tColorMixin:GetRGBA());
							else
								aIconTexture:SetVertexColor(1, 1, 1);
							end
						else
							aIconTexture:SetVertexColor(1, 1, 1);
						end
					elseif "class" == tColorMode then
						tClassColor = VUHDO_getClassColor(VUHDO_RAID[aUnit]);

						if tClassColor then
							aIconTexture:SetVertexColor(tClassColor["R"], tClassColor["G"], tClassColor["B"], 1);
						else
							aIconTexture:SetVertexColor(1, 1, 1);
						end
					else
						tIconColor = sBarColors and sBarColors["AURA_BAR_DEFAULT"];

						if tIconColor then
							aIconTexture:SetVertexColor(tIconColor["R"], tIconColor["G"], tIconColor["B"], tIconColor["O"] or 1);
						else
							aIconTexture:SetVertexColor(1, 1, 1);
						end
					end
				end

				aIconTexture:Show();
			elseif tIconType == 2 then
				aIconTexture:SetTexture("Interface\\AddOns\\VuhDo\\Images\\icon_white_square");

				tGroupId = anAuraData["groupId"];
				tEntryIndex = anAuraData["entryIndex"];

				if tGroupId and tEntryIndex and sEntrySettingsCache["colorIcon"][tGroupId] and sEntrySettingsCache["colorIcon"][tGroupId][tEntryIndex] then
					tEntryColor = sEntrySettingsCache["colorIconColor"][tGroupId] and sEntrySettingsCache["colorIconColor"][tGroupId][tEntryIndex];

					if tEntryColor and tEntryColor["R"] then
						aIconTexture:SetVertexColor(tEntryColor["R"], tEntryColor["G"], tEntryColor["B"], tEntryColor["O"] or 1);
					else
						aIconTexture:SetVertexColor(1, 1, 1);
					end
				elseif anAuraData["color"] and anAuraData["color"]["R"] then
					aIconTexture:SetVertexColor(VUHDO_backColor(anAuraData["color"]));
				else
					tColorMode = anAnchorConfig["colorMode"] or "default";

					if "debuff" == tColorMode and anAuraData["dispelName"] then
						tDispelCurve = VUHDO_getDispelTypeCurve();

						if tDispelCurve and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
							tColorMixin = GetAuraDispelTypeColor(aUnit, anAuraData["auraInstanceID"], tDispelCurve);

							if tColorMixin then
								aIconTexture:SetVertexColor(tColorMixin:GetRGBA());
							else
								aIconTexture:SetVertexColor(1, 1, 1);
							end
						else
							aIconTexture:SetVertexColor(1, 1, 1);
						end
					elseif "class" == tColorMode then
						tClassColor = VUHDO_getClassColor(VUHDO_RAID[aUnit]);

						if tClassColor then
							aIconTexture:SetVertexColor(tClassColor["R"], tClassColor["G"], tClassColor["B"], 1);
						else
							aIconTexture:SetVertexColor(1, 1, 1);
						end
					else
						tIconColor = sBarColors and sBarColors["AURA_BAR_DEFAULT"];

						if tIconColor then
							aIconTexture:SetVertexColor(tIconColor["R"], tIconColor["G"], tIconColor["B"], tIconColor["O"] or 1);
						else
							aIconTexture:SetVertexColor(1, 1, 1);
						end
					end
				end

				aIconTexture:Show();
			else
				if anAuraData["icon"] and not issecretvalue(anAuraData["icon"]) and VUHDO_ATLAS_TEXTURES and VUHDO_ATLAS_TEXTURES[anAuraData["icon"]] then
					aIconTexture:SetAtlas(anAuraData["icon"]);
				else
					aIconTexture:SetTexture(anAuraData["icon"]);

					if anAuraData["clipL"] and anAuraData["clipR"] and anAuraData["clipT"] and anAuraData["clipB"] then
						aIconTexture:SetTexCoord(anAuraData["clipL"], anAuraData["clipR"], anAuraData["clipT"], anAuraData["clipB"]);
					else
						aIconTexture:SetTexCoord(0, 1, 0, 1);
					end
				end

				tGroupId = anAuraData["groupId"];
				tEntryIndex = anAuraData["entryIndex"];

				if tGroupId and tEntryIndex and sEntrySettingsCache["colorIcon"][tGroupId] and sEntrySettingsCache["colorIcon"][tGroupId][tEntryIndex] then
					tEntryColor = sEntrySettingsCache["colorIconColor"][tGroupId] and sEntrySettingsCache["colorIconColor"][tGroupId][tEntryIndex];

					if tEntryColor and tEntryColor["R"] then
						aIconTexture:SetVertexColor(tEntryColor["R"], tEntryColor["G"], tEntryColor["B"], tEntryColor["O"] or 1);
					else
						aIconTexture:SetVertexColor(1, 1, 1);
					end
				elseif anAuraData["color"] and anAuraData["color"]["R"] then
					aIconTexture:SetVertexColor(VUHDO_backColor(anAuraData["color"]));
				else
					aIconTexture:SetVertexColor(1, 1, 1);
				end

				aIconTexture:Show();
			end
		end

		tGroupId = anAuraData["groupId"];
		tEntryIndex = anAuraData["entryIndex"];
		tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["showClock"][tGroupId] and sEntrySettingsCache["showClock"][tGroupId][tEntryIndex];

		if tEntryOverride ~= nil then
			tShowClock = tEntryOverride;
		else
			tShowClock = (aPanelNum and anAnchorIndex and sAnchorSettingsCache["showClock"][aPanelNum] and sAnchorSettingsCache["showClock"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["showClock"], "showClock");
		end

		if aCooldownFrame then
			if tShowClock and aDurationObj then
				aCooldownFrame:SetCooldownFromDurationObject(aDurationObj);
				aCooldownFrame:SetAlpha(1);
			else
				aCooldownFrame:SetAlpha(0);
			end
		end

		tGroupId = anAuraData["groupId"];
		tEntryIndex = anAuraData["entryIndex"];
		tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["fadeOnLow"][tGroupId] and sEntrySettingsCache["fadeOnLow"][tGroupId][tEntryIndex];

		if tEntryOverride ~= nil then
			tFadeOnLow = tEntryOverride;
		else
			tFadeOnLow = (aPanelNum and anAnchorIndex and sAnchorSettingsCache["fadeOnLow"][aPanelNum] and sAnchorSettingsCache["fadeOnLow"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["fadeOnLow"], "fadeOnLow");
		end

		if aIconTexture then
			if tFadeOnLow and aDurationObj then
				tGroupId = anAuraData["groupId"];
				tEntryIndex = anAuraData["entryIndex"];
				tFadeThreshold = tGroupId and tEntryIndex and sEntrySettingsCache["fadeThreshold"][tGroupId] and sEntrySettingsCache["fadeThreshold"][tGroupId][tEntryIndex];

				if tFadeThreshold and tFadeThreshold >= 1 and tFadeThreshold <= 30 and sCurves["fadeAlphaByThreshold"][tFadeThreshold] then
					tFadeAlpha = aDurationObj:EvaluateRemainingDuration(sCurves["fadeAlphaByThreshold"][tFadeThreshold]);
				elseif sCurves["fadeAlpha"] then
					tFadeAlpha = aDurationObj:EvaluateRemainingDuration(sCurves["fadeAlpha"]);
				else
					tFadeAlpha = 1;
				end

				aIconTexture:SetAlpha(tFadeAlpha);
			else
				aIconTexture:SetAlpha(1);
			end
		end

		tDispelBorder = (aPanelNum and anAnchorIndex and sAnchorSettingsCache["dispelBorder"][aPanelNum] and sAnchorSettingsCache["dispelBorder"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["dispelBorder"], "dispelBorder");

		if aBackdropFrame and aBackdropFrame.SetBackdropBorderColor then
			tDispelCurve = VUHDO_getAuraDispelCurveForContext(aUnit, anAnchorConfig);

			if tDispelBorder and aUnit and tDispelCurve and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
				tColorMixin = GetAuraDispelTypeColor(aUnit, anAuraData["auraInstanceID"], tDispelCurve);

				if tColorMixin then
					tDispelR, tDispelG, tDispelB, tDispelA = tColorMixin:GetRGBA();
					aBackdropFrame:SetBackdropBorderColor(tDispelR, tDispelG, tDispelB, tDispelA);
				else
					aBackdropFrame:SetBackdropBorderColor(0, 0, 0, 0);
				end
			else
				aBackdropFrame:SetBackdropBorderColor(0, 0, 0, 0);
			end
		end

		return;

	end
end



do
	--
	local tShowTimer;
	local tShowStacks;
	local tStackType;
	local tRemainingSeconds;
	local tDurationText;
	local tTimerVisibility;
	local tTimerColorMixin;
	local tApplications;
	local tCountStr;
	local tTriangleColor;
	local tGroupId;
	local tEntryIndex;
	local tEntryOverride;
	local tDurationMode;
	local tTimerThreshold;
	function VUHDO_updateAuraTimerAndStacks(aTimerText, aCountText, aChargeTexture, anAnchorConfig, anAuraData, aDurationObj, aUnit, aPanelNum, anAnchorIndex)

		if aTimerText then
			tGroupId = anAuraData["groupId"];
			tEntryIndex = anAuraData["entryIndex"];
			tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["showTimer"][tGroupId] and sEntrySettingsCache["showTimer"][tGroupId][tEntryIndex];

			if tEntryOverride ~= nil then
				tShowTimer = tEntryOverride;
			else
				tShowTimer = (aPanelNum and anAnchorIndex and sAnchorSettingsCache["showTimer"][aPanelNum] and sAnchorSettingsCache["showTimer"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["showTimer"], "showTimer");
			end

			if tShowTimer and aDurationObj and sCurves["timerVisible"] then
				if anAuraData["isAliveTime"] then
					tRemainingSeconds = aDurationObj:GetElapsedDuration();
					tTimerVisibility = aDurationObj:EvaluateElapsedDuration(sCurves["timerVisibleElapsed"]);
				else
					tRemainingSeconds = aDurationObj:GetRemainingDuration();
					tTimerVisibility = aDurationObj:EvaluateRemainingDuration(sCurves["timerVisible"]);
				end

				tDurationMode = tGroupId and tEntryIndex and sEntrySettingsCache["durationMode"][tGroupId] and sEntrySettingsCache["durationMode"][tGroupId][tEntryIndex];
				tTimerThreshold = tGroupId and tEntryIndex and sEntrySettingsCache["timerThreshold"][tGroupId] and sEntrySettingsCache["timerThreshold"][tGroupId][tEntryIndex];

				if tDurationMode == VUHDO_SPELL_DURATION_MODE_FULL then
					tTimerVisibility = 1;
				elseif (tDurationMode == nil or tDurationMode == VUHDO_SPELL_DURATION_MODE_THRESHOLD) and tTimerThreshold and tRemainingSeconds and not anAuraData["isAliveTime"] then
					tTimerVisibility = (tRemainingSeconds <= tTimerThreshold) and 1 or 0;
				end

				tDurationText = AbbreviateNumbers(tRemainingSeconds, sTimeAbbrevData);
				aTimerText:SetText(tDurationText or "");

				if sCurves["timerColor"] and not anAuraData["isAliveTime"] then
					tTimerColorMixin = aDurationObj:EvaluateRemainingDuration(sCurves["timerColor"]);
					aTimerText:SetTextColor(tTimerColorMixin:GetRGBA());
				elseif anAnchorConfig["TIMER_TEXT"] and anAnchorConfig["TIMER_TEXT"]["COLOR"] then
					aTimerText:SetTextColor(VUHDO_textColor(anAnchorConfig["TIMER_TEXT"]["COLOR"]));
				else
					aTimerText:SetTextColor(1, 1, 1, 1);
				end

				aTimerText:SetAlpha(tTimerVisibility);

				VUHDO_registerAuraTimerText(aTimerText, aDurationObj, anAuraData["isAliveTime"], tDurationMode, tTimerThreshold);
			else
				VUHDO_unregisterAuraTimerText(aTimerText);

				aTimerText:SetText("");
				aTimerText:SetTextColor(1, 1, 1, 1);
				aTimerText:SetAlpha(1);
			end
		end

		if aCountText then
			tGroupId = anAuraData["groupId"];
			tEntryIndex = anAuraData["entryIndex"];
			tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["showStacks"][tGroupId] and sEntrySettingsCache["showStacks"][tGroupId][tEntryIndex];

			if tEntryOverride ~= nil then
				tShowStacks = tEntryOverride;
			else
				tShowStacks = (aPanelNum and anAnchorIndex and sAnchorSettingsCache["showStacks"][aPanelNum] and sAnchorSettingsCache["showStacks"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["showStacks"], "showStacks");
			end

			tStackType = anAnchorConfig["stackType"] or 1;

			if tShowStacks and tStackType == 2 and aChargeTexture then
				tApplications = anAuraData["applications"];

				if tApplications and (issecretvalue(tApplications) or tApplications > 0) then
					aChargeTexture:SetTexture("Interface\\AddOns\\VuhDo\\Images\\aura_stacks_spritesheet");
					aChargeTexture:SetSpriteSheetCell(tApplications, 1, 8);

					tTriangleColor = sBarColors and sBarColors["AURA_STACK_TRIANGLE"];

					if tTriangleColor then
						aChargeTexture:SetVertexColor(tTriangleColor["R"] or 1, tTriangleColor["G"] or 1, tTriangleColor["B"] or 1, tTriangleColor["O"] or 1);
					else
						aChargeTexture:SetVertexColor(1, 1, 1, 1);
					end

					aChargeTexture:SetAlpha(tApplications);
					aChargeTexture:Show();
				else
					aChargeTexture:Hide();
				end

				aCountText:SetText("");
			else
				if aChargeTexture then
					aChargeTexture:Hide();
				end

				if tShowStacks and aUnit and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
					tCountStr = GetAuraApplicationDisplayCount(aUnit, anAuraData["auraInstanceID"], 2, 999);
					aCountText:SetText(tCountStr or "");

					if anAnchorConfig["COUNTER_TEXT"] and anAnchorConfig["COUNTER_TEXT"]["COLOR"] then
						aCountText:SetTextColor(VUHDO_textColor(anAnchorConfig["COUNTER_TEXT"]["COLOR"]));
					end
				else
					aCountText:SetText("");
				end
			end
		end

		return;

	end
end



do
	--
	local tIconFrame;
	local tChild;
	local tTexture;
	local tUnit;
	local tFlashOnLow;
	local tTimerText;
	local tCountText;
	local tDurationObj;
	local tLastInstanceId;
	local tLastExpiration;
	local tLastApplications;
	local tLastIcon;
	local tGroupId;
	local tEntryIndex;
	local tHasFadeOrFlash;
	local tGlowColor;
	local tGlowKey;
	local tHasGlow;
	local tIconSize;
	local tNumLines;
	local tLength;
	local tThickness;
	local tEntryOverride;
	local tFlashThreshold;
	local tFadeOnLowResolved;
	local tFadeThresholdForLoop;
	function VUHDO_displayAuraAsIcon(aButton, aPanelNum, anAnchorIndex, aSlotIndex, anAuraData, anAnchorConfig)

		if not aButton or not anAnchorIndex or not aSlotIndex or not anAuraData or not anAnchorConfig then
			return;
		end

		tIconFrame = VUHDO_acquireAuraIconFrame(aButton, anAnchorIndex, aSlotIndex);

		if not tIconFrame then
			return;
		end

		tLastInstanceId = tIconFrame["lastAuraInstanceId"];
		tLastExpiration = tIconFrame["lastExpirationTime"];
		tLastApplications = tIconFrame["lastApplications"];
		tLastIcon = tIconFrame["lastIcon"];

		tGroupId = anAuraData["groupId"];
		tEntryIndex = anAuraData["entryIndex"];

		tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["fadeOnLow"] and sEntrySettingsCache["fadeOnLow"][tGroupId] and sEntrySettingsCache["fadeOnLow"][tGroupId][tEntryIndex];
		tHasFadeOrFlash = (tEntryOverride ~= nil and tEntryOverride) or (tEntryOverride == nil and ((aPanelNum and anAnchorIndex and sAnchorSettingsCache["fadeOnLow"] and sAnchorSettingsCache["fadeOnLow"][aPanelNum] and sAnchorSettingsCache["fadeOnLow"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["fadeOnLow"], "fadeOnLow")));

		if not tHasFadeOrFlash then
			tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["flashOnLow"] and sEntrySettingsCache["flashOnLow"][tGroupId] and sEntrySettingsCache["flashOnLow"][tGroupId][tEntryIndex];
			tHasFadeOrFlash = (tEntryOverride ~= nil and tEntryOverride) or (tEntryOverride == nil and ((aPanelNum and anAnchorIndex and sAnchorSettingsCache["flashOnLow"] and sAnchorSettingsCache["flashOnLow"][aPanelNum] and sAnchorSettingsCache["flashOnLow"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["flashOnLow"], "flashOnLow")));
		end

		if not tHasFadeOrFlash
			and tIconFrame["lastSettingsVersion"] == sEntrySettingsVersion
			and not (issecretvalue(tLastExpiration) or issecretvalue(anAuraData["expirationTime"]) or
				issecretvalue(tLastApplications) or issecretvalue(anAuraData["applications"]) or
				issecretvalue(tLastIcon) or issecretvalue(anAuraData["icon"]))
			and tLastInstanceId == anAuraData["auraInstanceID"]
			and tLastExpiration == anAuraData["expirationTime"]
			and tLastApplications == anAuraData["applications"]
			and tLastIcon == anAuraData["icon"] then
			return;
		end

		tIconFrame["lastAuraInstanceId"] = anAuraData["auraInstanceID"];
		tIconFrame["lastExpirationTime"] = issecretvalue(anAuraData["expirationTime"]) and nil or anAuraData["expirationTime"];
		tIconFrame["lastApplications"] = issecretvalue(anAuraData["applications"]) and nil or anAuraData["applications"];
		tIconFrame["lastIcon"] = issecretvalue(anAuraData["icon"]) and nil or anAuraData["icon"];

		tIconFrame["lastSettingsVersion"] = sEntrySettingsVersion;

		tIconFrame["panelNum"] = aPanelNum;
		tIconFrame["anchorIndex"] = anAnchorIndex;
		tIconFrame["auraInstanceId"] = anAuraData["auraInstanceID"];

		tUnit = aButton:GetAttribute("unit");

		tDurationObj = nil;

		if not issecretvalue(anAuraData["duration"]) and not issecretvalue(anAuraData["expirationTime"]) then
			if (anAuraData["duration"] or 0) > 0 and anAuraData["expirationTime"] then
				if tUnit and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
					tDurationObj = GetAuraDuration(tUnit, anAuraData["auraInstanceID"]);
				else
					if not tIconFrame["durationObj"] then
						tIconFrame["durationObj"] = CreateDuration();
					end

					tDurationObj = tIconFrame["durationObj"];

					tDurationObj:SetTimeFromEnd(anAuraData["expirationTime"], anAuraData["duration"]);
				end
			end
		else
			if tUnit and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
				tDurationObj = GetAuraDuration(tUnit, anAuraData["auraInstanceID"]);
			elseif anAuraData["duration"] and anAuraData["duration"] > 0 and anAuraData["expirationTime"] then
				if not tIconFrame["durationObj"] then
					tIconFrame["durationObj"] = CreateDuration();
				end

				tDurationObj = tIconFrame["durationObj"];

				tDurationObj:SetTimeFromEnd(anAuraData["expirationTime"], anAuraData["duration"]);
			end
		end

		tChild = tIconFrame["childB"] or VUHDO_getAuraIconBackdrop(tIconFrame);

		if tChild then
			tTexture = tChild["textureI"] or VUHDO_getAuraIconTexture(tChild);

			VUHDO_updateAuraIconDisplay(tTexture, tChild["cooldownFrame"], tChild, anAnchorConfig, anAuraData, tDurationObj, tUnit, aPanelNum, anAnchorIndex);

			tTimerText = tChild["timerText"];
			tCountText = tChild["countText"];

			VUHDO_updateAuraTimerAndStacks(tTimerText, tCountText, tChild["chargeTexture"], anAnchorConfig, anAuraData, tDurationObj, tUnit, aPanelNum, anAnchorIndex);

			tGroupId = anAuraData["groupId"];
			tEntryIndex = anAuraData["entryIndex"];
			tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["fadeOnLow"][tGroupId] and sEntrySettingsCache["fadeOnLow"][tGroupId][tEntryIndex];

			if tEntryOverride ~= nil then
				tFadeOnLowResolved = tEntryOverride;
			else
				tFadeOnLowResolved = (aPanelNum and anAnchorIndex and sAnchorSettingsCache["fadeOnLow"][aPanelNum] and sAnchorSettingsCache["fadeOnLow"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["fadeOnLow"], "fadeOnLow");
			end

			if tFadeOnLowResolved and tDurationObj and tTexture and not tDurationObj:HasSecretValues() then
				tFadeThresholdForLoop = tGroupId and tEntryIndex and sEntrySettingsCache["fadeThreshold"][tGroupId] and sEntrySettingsCache["fadeThreshold"][tGroupId][tEntryIndex];

				if tEntryOverride == nil or not tFadeThresholdForLoop then
					tFadeThresholdForLoop = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["AURA_DEFAULTS"] and VUHDO_PANEL_SETUP["AURA_DEFAULTS"]["fadeThreshold"];
				end

				VUHDO_registerAuraFadeTexture(tTexture, tDurationObj, tFadeThresholdForLoop);
			else
				VUHDO_unregisterAuraFadeTexture(tTexture);
			end

			tChild:SetAlpha(1);

			tGroupId = anAuraData["groupId"];
			tEntryIndex = anAuraData["entryIndex"];
			tHasGlow = tGroupId and tEntryIndex and sEntrySettingsCache["glowIcon"][tGroupId] and sEntrySettingsCache["glowIcon"][tGroupId][tEntryIndex];

			if tHasGlow then
				if tChild then
					tChild:SetBackdropBorderColor(0, 0, 0, 0);
				end

				tGlowColor = sEntrySettingsCache["glowColor"][tGroupId] and sEntrySettingsCache["glowColor"][tGroupId][tEntryIndex];

				if tGlowColor then
					sGlowColorArray[1] = tGlowColor["R"] or 1;
					sGlowColorArray[2] = tGlowColor["G"] or 1;
					sGlowColorArray[3] = tGlowColor["B"] or 0;
					sGlowColorArray[4] = tGlowColor["O"] or 1;
				elseif sBarColors and sBarColors["DEBUFF_ICON_GLOW"] then
					sGlowColorArray[1] = sBarColors["DEBUFF_ICON_GLOW"]["R"];
					sGlowColorArray[2] = sBarColors["DEBUFF_ICON_GLOW"]["G"];
					sGlowColorArray[3] = sBarColors["DEBUFF_ICON_GLOW"]["B"];
					sGlowColorArray[4] = sBarColors["DEBUFF_ICON_GLOW"]["O"];
				else
					sGlowColorArray[1] = 0.95;
					sGlowColorArray[2] = 0.95;
					sGlowColorArray[3] = 0.32;
					sGlowColorArray[4] = 1;
				end

				tGlowKey = format("VdAuraGlow_%d_%d_%d", aPanelNum or 0, anAnchorIndex, aSlotIndex);

				tIconSize = VUHDO_getAuraIconSizePixels(aButton, anAnchorConfig);

				if tIconSize and tIconSize < 24 then
					tNumLines = 8;
					tLength = 2;
					tThickness = 1;
				elseif tIconSize and tIconSize < 32 then
					tNumLines = 8;
					tLength = 4;
					tThickness = 1;
				else
					tNumLines = 8;
					tLength = 6;
					tThickness = 2;
				end

				VUHDO_LibCustomGlow.PixelGlow_Start(
					tIconFrame, sGlowColorArray,
					tNumLines, 0.3, tLength, tThickness, 0, 0, false, tGlowKey
				);

				tIconFrame["hasEntryGlow"] = true;
				tIconFrame["entryGlowKey"] = tGlowKey;
			elseif tIconFrame["hasEntryGlow"] then
				VUHDO_LibCustomGlow.PixelGlow_Stop(tIconFrame, tIconFrame["entryGlowKey"]);

				tIconFrame["hasEntryGlow"] = nil;
				tIconFrame["entryGlowKey"] = nil;
			end

			tGroupId = anAuraData["groupId"];
			tEntryIndex = anAuraData["entryIndex"];
			tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["flashOnLow"][tGroupId] and sEntrySettingsCache["flashOnLow"][tGroupId][tEntryIndex];

			if tEntryOverride ~= nil then
				tFlashOnLow = tEntryOverride;
			else
				tFlashOnLow = (aPanelNum and anAnchorIndex and sAnchorSettingsCache["flashOnLow"][aPanelNum] and sAnchorSettingsCache["flashOnLow"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["flashOnLow"], "flashOnLow");
			end

			if tFlashOnLow and tDurationObj and not tDurationObj:HasSecretValues() then
				tFlashThreshold = tGroupId and tEntryIndex and sEntrySettingsCache["flashThreshold"][tGroupId] and sEntrySettingsCache["flashThreshold"][tGroupId][tEntryIndex];

				if tEntryOverride == nil or not tFlashThreshold then
					tFlashThreshold = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["AURA_DEFAULTS"] and VUHDO_PANEL_SETUP["AURA_DEFAULTS"]["flashThreshold"];
				end

				VUHDO_registerAuraFlashFrame(tIconFrame, tDurationObj, tFlashThreshold);
			else
				VUHDO_unregisterAuraFlashFrame(tIconFrame);
			end
		end

		tIconFrame:SetAlpha(1);

		return;

	end
end



do
	--
	local tHasGlow;
	local tGlowColor;
	local tGlowKey;
	local tNumLines;
	local tLength;
	local tThickness;
	local tIconSize;
	local tGlowFrame;
	function VUHDO_updateAuraBarGlow(aBarFrame, aGroupId, aEntryIndex, aPanelNum, anAnchorIndex, aSlotIndex, anIsBarVertical, aButton, anAnchorConfig, aBarIconType)

		tHasGlow = aGroupId and aEntryIndex and sEntrySettingsCache["glowIcon"][aGroupId] and sEntrySettingsCache["glowIcon"][aGroupId][aEntryIndex];

		if tHasGlow and aBarIconType ~= 5 then
			tGlowColor = sEntrySettingsCache["glowColor"][aGroupId] and sEntrySettingsCache["glowColor"][aGroupId][aEntryIndex];

			if tGlowColor then
				sGlowColorArray[1] = tGlowColor["R"] or 1;
				sGlowColorArray[2] = tGlowColor["G"] or 1;
				sGlowColorArray[3] = tGlowColor["B"] or 0;
				sGlowColorArray[4] = tGlowColor["O"] or 1;
			elseif sBarColors and sBarColors["DEBUFF_ICON_GLOW"] then
				sGlowColorArray[1] = sBarColors["DEBUFF_ICON_GLOW"]["R"];
				sGlowColorArray[2] = sBarColors["DEBUFF_ICON_GLOW"]["G"];
				sGlowColorArray[3] = sBarColors["DEBUFF_ICON_GLOW"]["B"];
				sGlowColorArray[4] = sBarColors["DEBUFF_ICON_GLOW"]["O"];
			else
				sGlowColorArray[1] = 0.95;
				sGlowColorArray[2] = 0.95;
				sGlowColorArray[3] = 0.32;
				sGlowColorArray[4] = 1;
			end

			tGlowKey = format("VdAuraGlow_%d_%d_%d", aPanelNum or 0, anAnchorIndex, aSlotIndex);

			if anIsBarVertical then
				tIconSize = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);
			else
				tIconSize = VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig);
			end

			if tIconSize and tIconSize < 24 then
				tNumLines = 8;
				tLength = 2;
				tThickness = 1;
			elseif tIconSize and tIconSize < 32 then
				tNumLines = 8;
				tLength = 4;
				tThickness = 1;
			else
				tNumLines = 8;
				tLength = 6;
				tThickness = 2;
			end

			tGlowFrame = aBarFrame["iconFrame"];

			if tGlowFrame then
				VUHDO_LibCustomGlow.PixelGlow_Start(tGlowFrame, sGlowColorArray, tNumLines, 0.3, tLength, tThickness, 0, 0, false, tGlowKey);

				tGlowFrame["hasEntryGlow"] = true;
				tGlowFrame["entryGlowKey"] = tGlowKey;
			end
		elseif aBarFrame["iconFrame"] and aBarFrame["iconFrame"]["hasEntryGlow"] then
			tGlowFrame = aBarFrame["iconFrame"];

			VUHDO_LibCustomGlow.PixelGlow_Stop(tGlowFrame, tGlowFrame["entryGlowKey"]);

			tGlowFrame["hasEntryGlow"] = nil;
			tGlowFrame["entryGlowKey"] = nil;
		end

		return;

	end
end



do
	--
	local tBarFrame;
	local tBar;
	local tUnit;
	local tDurationObj;
	local tFlashOnLow;
	local tFlashThreshold;
	local tEntryOverride;
	local tBarVertical;
	local tBarTurnAxis;
	local tBarInvertGrowth;
	local tTimerDirection;
	local tColorMode;
	local tClassColor;
	local tBarColor;
	local tDispelCurve;
	local tGroupId;
	local tEntryIndex;
	local tEntryColor;
	local tBarIconType;
	local tFadeOnLowResolved;
	local tFadeThresholdForLoop;
	local tFadeTexture;
	local tLastInstanceId;
	local tHasFadeOrFlash;
	local tIsUpdate;
	local tCurrentDuration;
	local tRemaining;
	local tIsPermanent;
	local tIsFullReset;
	function VUHDO_displayAuraAsBar(aButton, aPanelNum, anAnchorIndex, aSlotIndex, anAuraData, anAnchorConfig)

		if not aButton or not anAnchorIndex or not aSlotIndex or not anAuraData or not anAnchorConfig then
			return;
		end

		tBarFrame = VUHDO_acquireAuraBarFrame(aButton, anAnchorIndex, aSlotIndex);

		if not tBarFrame then
			return;
		end

		tLastInstanceId = tBarFrame["lastAuraInstanceId"];

		tGroupId = anAuraData["groupId"];
		tEntryIndex = anAuraData["entryIndex"];

		tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["fadeOnLow"] and sEntrySettingsCache["fadeOnLow"][tGroupId] and sEntrySettingsCache["fadeOnLow"][tGroupId][tEntryIndex];
		tHasFadeOrFlash = (tEntryOverride ~= nil and tEntryOverride) or (tEntryOverride == nil and ((aPanelNum and anAnchorIndex and sAnchorSettingsCache["fadeOnLow"] and sAnchorSettingsCache["fadeOnLow"][aPanelNum] and sAnchorSettingsCache["fadeOnLow"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["fadeOnLow"], "fadeOnLow")));

		if not tHasFadeOrFlash then
			tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["flashOnLow"] and sEntrySettingsCache["flashOnLow"][tGroupId] and sEntrySettingsCache["flashOnLow"][tGroupId][tEntryIndex];
			tHasFadeOrFlash = (tEntryOverride ~= nil and tEntryOverride) or (tEntryOverride == nil and ((aPanelNum and anAnchorIndex and sAnchorSettingsCache["flashOnLow"] and sAnchorSettingsCache["flashOnLow"][aPanelNum] and sAnchorSettingsCache["flashOnLow"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["flashOnLow"], "flashOnLow")));
		end

		if not tHasFadeOrFlash
			and tBarFrame["lastSettingsVersion"] == sEntrySettingsVersion
			and not (issecretvalue(tBarFrame["lastExpirationTime"]) or issecretvalue(anAuraData["expirationTime"]) or
				issecretvalue(tBarFrame["lastApplications"]) or issecretvalue(anAuraData["applications"]) or
				issecretvalue(tBarFrame["lastIcon"]) or issecretvalue(anAuraData["icon"]))
			and tLastInstanceId == anAuraData["auraInstanceID"]
			and tBarFrame["lastExpirationTime"] == anAuraData["expirationTime"]
			and tBarFrame["lastApplications"] == anAuraData["applications"]
			and tBarFrame["lastIcon"] == anAuraData["icon"] then
			return;
		end

		tIsUpdate = tLastInstanceId and tLastInstanceId == anAuraData["auraInstanceID"];

		tUnit = aButton:GetAttribute("unit");

		tDurationObj = nil;
		tIsFullReset = false;

		if not issecretvalue(anAuraData["duration"]) and not issecretvalue(anAuraData["expirationTime"]) then
			tCurrentDuration = anAuraData["duration"] or 0;
			tRemaining = (anAuraData["expirationTime"] or 0) - GetTime();

			if not tIsUpdate then
				tBarFrame["baseDuration"] = tCurrentDuration;
				tBarFrame["maxObservedDuration"] = max(tCurrentDuration, tRemaining);
			elseif tCurrentDuration >= (tBarFrame["baseDuration"] or 0) then
				tBarFrame["maxObservedDuration"] = max(tCurrentDuration, tRemaining);

				if tBarFrame["maxObservedDuration"] - tCurrentDuration < 0.1 then
					tBarFrame["maxObservedDuration"] = tCurrentDuration;

					tIsFullReset = tRemaining >= tCurrentDuration - 0.15;
				else
					tIsFullReset = false;
				end
			elseif tRemaining > (tBarFrame["maxObservedDuration"] or 0) then
				tBarFrame["maxObservedDuration"] = tRemaining;

				tIsFullReset = false;
			end

			if (tBarFrame["maxObservedDuration"] or 0) > 0 and anAuraData["expirationTime"] then
				if not tBarFrame["durationObj"] then
					tBarFrame["durationObj"] = CreateDuration();
				end

				tDurationObj = tBarFrame["durationObj"];

				tDurationObj:SetTimeFromEnd(anAuraData["expirationTime"], tBarFrame["maxObservedDuration"]);
			end

			tIsPermanent = (tCurrentDuration == 0 and (anAuraData["expirationTime"] or 0) == 0);
		else
			if tUnit and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
				tDurationObj = GetAuraDuration(tUnit, anAuraData["auraInstanceID"]);
			elseif anAuraData["duration"] and anAuraData["duration"] > 0 and anAuraData["expirationTime"] then
				if not tBarFrame["durationObj"] then
					tBarFrame["durationObj"] = CreateDuration();
				end

				tDurationObj = tBarFrame["durationObj"];

				tDurationObj:SetTimeFromEnd(anAuraData["expirationTime"], anAuraData["duration"]);
			end

			tIsPermanent = false;
		end

		tBarFrame["lastAuraInstanceId"] = anAuraData["auraInstanceID"];
		tBarFrame["lastExpirationTime"] = issecretvalue(anAuraData["expirationTime"]) and nil or anAuraData["expirationTime"];
		tBarFrame["lastApplications"] = issecretvalue(anAuraData["applications"]) and nil or anAuraData["applications"];
		tBarFrame["lastIcon"] = issecretvalue(anAuraData["icon"]) and nil or anAuraData["icon"];

		tBarFrame["lastSettingsVersion"] = sEntrySettingsVersion;

		tBarFrame["panelNum"] = aPanelNum;
		tBarFrame["anchorIndex"] = anAnchorIndex;
		tBarFrame["auraInstanceId"] = anAuraData["auraInstanceID"];

		tBar = tBarFrame["childBar"];

		if not tBar then
			return;
		end

		if VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"] and VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["barTexture"] then
			VUHDO_setLlcStatusBarTexture(tBar, VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["barTexture"]);
		end

		if anAuraData["color"] and anAuraData["color"]["R"] then
			tBar:GetStatusBarTexture():SetVertexColor(VUHDO_backColor(anAuraData["color"]));
		else
			tColorMode = anAnchorConfig["colorMode"] or "default";

			if "debuff" == tColorMode and anAuraData["dispelName"] then
				tDispelCurve = VUHDO_getDispelTypeCurve();

				if tDispelCurve and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
					tEntryColor = GetAuraDispelTypeColor(tUnit, anAuraData["auraInstanceID"], tDispelCurve);

					if tEntryColor then
						tBar:GetStatusBarTexture():SetVertexColor(tEntryColor:GetRGBA());
					else
						tBar:GetStatusBarTexture():SetVertexColor(0.2, 0.6, 0.2, 1);
					end
				else
					tBar:GetStatusBarTexture():SetVertexColor(0.2, 0.6, 0.2, 1);
				end
			elseif "class" == tColorMode then
				tClassColor = VUHDO_getClassColor(VUHDO_RAID[tUnit]);

				if tClassColor then
					tBar:GetStatusBarTexture():SetVertexColor(tClassColor["R"], tClassColor["G"], tClassColor["B"], 1);
				else
					tBar:GetStatusBarTexture():SetVertexColor(0.2, 0.6, 0.2, 1);
				end
			else
				tGroupId = anAuraData["groupId"];
				tEntryIndex = anAuraData["entryIndex"];

				if tGroupId and tEntryIndex and sEntrySettingsCache["colorIcon"][tGroupId] and sEntrySettingsCache["colorIcon"][tGroupId][tEntryIndex] then
					tEntryColor = sEntrySettingsCache["colorIconColor"][tGroupId] and sEntrySettingsCache["colorIconColor"][tGroupId][tEntryIndex];

					if tEntryColor and tEntryColor["R"] then
						tBar:GetStatusBarTexture():SetVertexColor(tEntryColor["R"], tEntryColor["G"], tEntryColor["B"], tEntryColor["O"] or 1);
					else
						tBar:GetStatusBarTexture():SetVertexColor(0.2, 0.6, 0.2, 1);
					end
				else
					tBarColor = sBarColors and sBarColors["AURA_BAR_DEFAULT"];

					if tBarColor then
						tBar:GetStatusBarTexture():SetVertexColor(tBarColor["R"], tBarColor["G"], tBarColor["B"], tBarColor["O"] or 1);
					else
						tBar:GetStatusBarTexture():SetVertexColor(0.2, 0.6, 0.2, 1);
					end
				end
			end
		end

		tBarVertical = anAnchorConfig["barVertical"] or false;
		tBarTurnAxis = anAnchorConfig["barTurnAxis"] or false;
		tBarInvertGrowth = anAnchorConfig["barInvertGrowth"] or false;

		if tBarVertical then
			VUHDO_setStatusBarOrientation(tBar, tBarTurnAxis and VUHDO_STATUSBAR_TOP_TO_BOTTOM or VUHDO_STATUSBAR_BOTTOM_TO_TOP);
		else
			VUHDO_setStatusBarOrientation(tBar, tBarTurnAxis and VUHDO_STATUSBAR_RIGHT_TO_LEFT or VUHDO_STATUSBAR_LEFT_TO_RIGHT);
		end

		if tDurationObj then
			tBar:Show();

			tTimerDirection = tBarInvertGrowth and Enum.StatusBarTimerDirection.ElapsedTime or Enum.StatusBarTimerDirection.RemainingTime;

			tBar:SetTimerDuration(tDurationObj, (tIsUpdate and not tIsFullReset) and Enum.StatusBarInterpolation.ExponentialEaseOut or Enum.StatusBarInterpolation.Immediate, tTimerDirection);
		elseif tIsPermanent then
			tBar:Hide();
		else
			tBar:Show();

			tBar:SetMinMaxValues(0, 1);

			tBar:SetValue(tBarInvertGrowth and 0 or 1);
		end

		VUHDO_updateAuraIconDisplay(tBarFrame["iconFrame"]["textureI"], tBarFrame["iconFrame"]["cooldownFrame"], tBarFrame["iconFrame"], anAnchorConfig, anAuraData, tDurationObj, tUnit, aPanelNum, anAnchorIndex);

		tBarIconType = anAnchorConfig["iconType"] or 1;

		if tBarFrame["iconFrame"] then
			if tBarIconType == 5 then
				tBarFrame["iconFrame"]:Hide();
			else
				tBarFrame["iconFrame"]:Show();
			end
		end

		VUHDO_updateAuraTimerAndStacks(tBarFrame["timerText"], tBarFrame["countText"], tBarFrame["chargeTexture"], anAnchorConfig, anAuraData, tDurationObj, tUnit, aPanelNum, anAnchorIndex);

		tGroupId = anAuraData["groupId"];
		tEntryIndex = anAuraData["entryIndex"];
		tFadeTexture = tBarFrame["iconFrame"] and tBarFrame["iconFrame"]["textureI"];

		tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["fadeOnLow"][tGroupId] and sEntrySettingsCache["fadeOnLow"][tGroupId][tEntryIndex];

		if tEntryOverride ~= nil then
			tFadeOnLowResolved = tEntryOverride;
		else
			tFadeOnLowResolved = (aPanelNum and anAnchorIndex and sAnchorSettingsCache["fadeOnLow"][aPanelNum] and sAnchorSettingsCache["fadeOnLow"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["fadeOnLow"], "fadeOnLow");
		end

		tFadeThresholdForLoop = tGroupId and tEntryIndex and sEntrySettingsCache["fadeThreshold"][tGroupId] and sEntrySettingsCache["fadeThreshold"][tGroupId][tEntryIndex];

		if tEntryOverride == nil or not tFadeThresholdForLoop then
			tFadeThresholdForLoop = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["AURA_DEFAULTS"] and VUHDO_PANEL_SETUP["AURA_DEFAULTS"]["fadeThreshold"];
		end

		if tFadeOnLowResolved and tDurationObj and tBar and not tDurationObj:HasSecretValues() then
			VUHDO_registerAuraFadeTexture(tBar, tDurationObj, tFadeThresholdForLoop);

			if tBarIconType ~= 5 and tFadeTexture then
				VUHDO_registerAuraFadeTexture(tFadeTexture, tDurationObj, tFadeThresholdForLoop);
			elseif tFadeTexture then
				VUHDO_unregisterAuraFadeTexture(tFadeTexture);
			end
		else
			VUHDO_unregisterAuraFadeTexture(tBar);

			if tFadeTexture then
				VUHDO_unregisterAuraFadeTexture(tFadeTexture);
			end
		end

		VUHDO_updateAuraBarGlow(tBarFrame, tGroupId, tEntryIndex, aPanelNum, anAnchorIndex, aSlotIndex, tBarVertical, aButton, anAnchorConfig, tBarIconType);

		if (not tFadeOnLowResolved or not tDurationObj or tDurationObj:HasSecretValues()) and not tIsPermanent then
			tBar:SetAlpha(1);
		end

		tEntryOverride = tGroupId and tEntryIndex and sEntrySettingsCache["flashOnLow"][tGroupId] and sEntrySettingsCache["flashOnLow"][tGroupId][tEntryIndex];

		if tEntryOverride ~= nil then
			tFlashOnLow = tEntryOverride;
		else
			tFlashOnLow = (aPanelNum and anAnchorIndex and sAnchorSettingsCache["flashOnLow"][aPanelNum] and sAnchorSettingsCache["flashOnLow"][aPanelNum][anAnchorIndex]) or VUHDO_resolveAuraTriState(anAnchorConfig["flashOnLow"], "flashOnLow");
		end

		if tFlashOnLow and tDurationObj and not tDurationObj:HasSecretValues() then
			tFlashThreshold = tGroupId and tEntryIndex and sEntrySettingsCache["flashThreshold"][tGroupId] and sEntrySettingsCache["flashThreshold"][tGroupId][tEntryIndex];

			if tEntryOverride == nil or not tFlashThreshold then
				tFlashThreshold = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["AURA_DEFAULTS"] and VUHDO_PANEL_SETUP["AURA_DEFAULTS"]["flashThreshold"];
			end

			VUHDO_registerAuraFlashFrame(tBarFrame, tDurationObj, tFlashThreshold);
		else
			VUHDO_unregisterAuraFlashFrame(tBarFrame);
		end

		tBarFrame:SetAlpha(1);

		return;

	end
end



do
	--
	local tFrameName;
	local tFrame;
	local tGlowTarget;
	function VUHDO_hideAuraSlot(aButton, anAnchorIndex, aSlotIndex, anIsBar)

		if not aButton or not anAnchorIndex or not aSlotIndex then
			return;
		end

		tFrameName = aButton:GetName();

		tFrame = VUHDO_AURA_FRAMES[tFrameName] and VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex] and VUHDO_AURA_FRAMES[tFrameName][anAnchorIndex][aSlotIndex];

		if tFrame then
			if tFrame["childB"] and tFrame["childB"]["timerText"] then
				VUHDO_unregisterAuraTimerText(tFrame["childB"]["timerText"]);
			elseif tFrame["timerText"] then
				VUHDO_unregisterAuraTimerText(tFrame["timerText"]);
			end

			VUHDO_unregisterAuraFlashFrame(tFrame);

			if tFrame["childB"] and tFrame["childB"]["textureI"] then
				VUHDO_unregisterAuraFadeTexture(tFrame["childB"]["textureI"]);
			end

			if tFrame["iconFrame"] and tFrame["iconFrame"]["textureI"] then
				VUHDO_unregisterAuraFadeTexture(tFrame["iconFrame"]["textureI"]);
			end

			if tFrame["childBar"] then
				VUHDO_unregisterAuraFadeTexture(tFrame["childBar"]);
			end

			VUHDO_UIFrameFlashStop(tFrame);

			if tFrame["hasEntryGlow"] then
				tGlowTarget = tFrame;

				VUHDO_LibCustomGlow.PixelGlow_Stop(tGlowTarget, tFrame["entryGlowKey"]);

				tFrame["hasEntryGlow"] = nil;
				tFrame["entryGlowKey"] = nil;
			elseif tFrame["iconFrame"] and tFrame["iconFrame"]["hasEntryGlow"] then
				tGlowTarget = tFrame["iconFrame"];

				VUHDO_LibCustomGlow.PixelGlow_Stop(tGlowTarget, tFrame["iconFrame"]["entryGlowKey"]);

				tFrame["iconFrame"]["hasEntryGlow"] = nil;
				tFrame["iconFrame"]["entryGlowKey"] = nil;
			end

			if tFrame["iconFrame"] then
				tFrame["iconFrame"]:Hide();
			end

			if tFrame["auraInstanceId"] then
				tFrame["auraInstanceId"] = nil;
			end

			tFrame["lastAuraInstanceId"] = nil;
			tFrame["lastExpirationTime"] = nil;
			tFrame["lastApplications"] = nil;
			tFrame["lastIcon"] = nil;
			tFrame["maxObservedDuration"] = nil;
			tFrame["baseDuration"] = nil;
			tFrame["durationObj"] = nil;

			tFrame:SetAlpha(0);
		end

		return;

	end
end



--
local tUnitPanels;
function VUHDO_updateAuraDisplaysForUnit(aUnit)

	if sAurasSuspended then
		return;
	end

	if not aUnit then
		return;
	end

	tUnitPanels = VUHDO_UNIT_BUTTONS_PANEL[aUnit];

	if not tUnitPanels then
		return;
	end

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		if tUnitPanels[tPanelNum] then
			VUHDO_updateAurasForAnchors(aUnit, tPanelNum);
		end
	end

	return;

end