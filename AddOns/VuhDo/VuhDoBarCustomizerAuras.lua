local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local twipe = table.wipe;
local floor = math.floor;
local max = math.max;
local min = math.min;

local InCombatLockdown = InCombatLockdown;
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
local VUHDO_setAnchorSlotAuraId;
local VUHDO_isPanelPopulated;

VUHDO_AURA_FRAMES = VUHDO_AURA_FRAMES or { };
local VUHDO_AURA_FRAMES = VUHDO_AURA_FRAMES;

local sAuraAnchorConfigVersion = 0;

local sPrewarmIconsNeeded = 0;
local sPrewarmBarsNeeded = 0;
local sPrewarmIconsCreated = 0;
local sPrewarmBarsCreated = 0;
local sPrewarmTempIconFrames = { };
local sPrewarmTempBarFrames = { };

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

local sCurveTimerVisible;
local sCurveTimerVisibleElapsed;
local sCurveFlashZone;
local sCurveFadeAlpha;
local sCurveTimerColor;
local sAuraDispelCurve;
local sBarColors;

local sAuraTimerData = { };
local sAuraTimerIsAlive = { };
local sAuraTimerFrame;
local sAuraTimerAnimGroup;
local sAuraTimerAnimation;
local sAuraTimerCount = 0;

local sAuraIconPool;
local sAuraBarPool;
local sSlotDataAsAuraPool;
local sSlotAssignmentPool;
local sAuraPoolContainer;

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

local sDurationCache = { };

local sAurasSuspended = false;



--
local tCacheKey;
local tCachedDuration;
function VUHDO_getOrCreateDuration(anAnchorIndex, aSlotIndex)

	tCacheKey = anAnchorIndex * 100 + aSlotIndex;
	tCachedDuration = sDurationCache[tCacheKey];

	if not tCachedDuration then
		tCachedDuration = CreateDuration();
		sDurationCache[tCacheKey] = tCachedDuration;
	end

	return tCachedDuration;

end



--
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

	sSlotDataAsAuraPool = VUHDO_createTablePool("SlotDataAsAura", 500);
	sSlotAssignmentPool = VUHDO_createTablePool("SlotAssignment", 200);

	VUHDO_initAuraDurationCurves();
	VUHDO_initAuraTimer();

	sBarColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];

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
		tAvailableWidth = max(0, tBarWidth - VUHDO_getAuraBarHeightPixels(aButton, anAnchorConfig));

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

		tBarHeight = tPanelNum and VUHDO_getHealthBarHeight(tPanelNum) or 40;
		tIconSize = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);

		tAvailableHeight = max(0, tBarHeight - tIconSize);

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
	local function VUHDO_getAuraIconTimer(aBackdropFrame)

		_, tTimer = aBackdropFrame:GetRegions();

		return tTimer;

	end



	--
	local tCounter;
	local function VUHDO_getAuraIconCounter(aBackdropFrame)

		_, _, tCounter = aBackdropFrame:GetRegions();

		return tCounter;

	end



	--
	local tCooldown;
	local function VUHDO_getAuraIconCooldown(aBackdropFrame)

		tCooldown = aBackdropFrame:GetChildren();

		return tCooldown;

	end



	--
	local tChargeFrame;
	local function VUHDO_getAuraIconChargeFrame(aBackdropFrame)

		_, tChargeFrame = aBackdropFrame:GetChildren();

		return tChargeFrame;

	end



	--
	local tRegion;
	local function VUHDO_getAuraIconChargeTexture(aChargeFrame)

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
	local tIcon;
	local function VUHDO_getAuraBarIconTexture(aFrame)

		tIcon = aFrame:GetRegions();

		return tIcon;

	end



	--
	local tTimer;
	local function VUHDO_getAuraBarTimer(aFrame)

		_, tTimer = aFrame:GetRegions();

		return tTimer;

	end



	--
	local tCounter;
	local function VUHDO_getAuraBarCounter(aFrame)

		_, _, tCounter = aFrame:GetRegions();

		return tCounter;

	end



	--
	local tChargeFrame;
	local function VUHDO_getAuraBarChargeFrame(aFrame)

		_, _, tChargeFrame = aFrame:GetChildren();

		return tChargeFrame;

	end



	--
	local tRegion;
	local function VUHDO_getAuraBarChargeTexture(aFrame)

		tChargeFrame = VUHDO_getAuraBarChargeFrame(aFrame);

		if not tChargeFrame then
			return nil;
		end

		tRegion = tChargeFrame:GetRegions();

		return tRegion;

	end



	--
	local tCooldown;
	local function VUHDO_getAuraBarCooldown(aFrame)

		tCooldown = aFrame:GetChildren();

		return tCooldown;

	end



	--
	local tColors;
	local tTransparent;
	function VUHDO_initAuraDurationCurves()

		sCurveTimerVisible = CreateCurve();
		sCurveTimerVisible:SetType(Enum.LuaCurveType.Step);
		sCurveTimerVisible:AddPoint(0, 0);
		sCurveTimerVisible:AddPoint(0.1, 1);
		sCurveTimerVisible:AddPoint(9.99, 0);

		sCurveTimerVisibleElapsed = CreateCurve();
		sCurveTimerVisibleElapsed:SetType(Enum.LuaCurveType.Step);
		sCurveTimerVisibleElapsed:AddPoint(0, 1);

		sCurveFlashZone = CreateCurve();
		sCurveFlashZone:SetType(Enum.LuaCurveType.Step);
		sCurveFlashZone:AddPoint(0, 0);
		sCurveFlashZone:AddPoint(0.1, 1);
		sCurveFlashZone:AddPoint(4.9, 0);

		sCurveFadeAlpha = CreateCurve();
		sCurveFadeAlpha:SetType(Enum.LuaCurveType.Linear);
		sCurveFadeAlpha:AddPoint(0, 0);
		sCurveFadeAlpha:AddPoint(10, 1);

		sCurveTimerColor = CreateColorCurve();
		sCurveTimerColor:SetType(Enum.LuaCurveType.Step);
		sCurveTimerColor:AddPoint(0, CreateColor(1, 1, 1, 1));
		sCurveTimerColor:AddPoint(0.1, CreateColor(1, 0.2, 0.2, 1));
		sCurveTimerColor:AddPoint(4.9, CreateColor(1, 1, 1, 1));

		tColors = VUHDO_PANEL_SETUP and VUHDO_PANEL_SETUP["BAR_COLORS"];
		tTransparent = CreateColor(0, 0, 0, 0);
		sAuraDispelCurve = CreateColorCurve();
		sAuraDispelCurve:SetType(Enum.LuaCurveType.Step);
		sAuraDispelCurve:AddPoint(0, tTransparent);

		if tColors and tColors["DEBUFF3"] and tColors["DEBUFF3"]["useBorder"] then
			sAuraDispelCurve:AddPoint(1, VUHDO_safeColorFromTable(tColors["DEBUFF3"], tTransparent));
		else
			sAuraDispelCurve:AddPoint(1, tTransparent);
		end

		if tColors and tColors["DEBUFF4"] and tColors["DEBUFF4"]["useBorder"] then
			sAuraDispelCurve:AddPoint(2, VUHDO_safeColorFromTable(tColors["DEBUFF4"], tTransparent));
		else
			sAuraDispelCurve:AddPoint(2, tTransparent);
		end

		if tColors and tColors["DEBUFF2"] and tColors["DEBUFF2"]["useBorder"] then
			sAuraDispelCurve:AddPoint(3, VUHDO_safeColorFromTable(tColors["DEBUFF2"], tTransparent));
		else
			sAuraDispelCurve:AddPoint(3, tTransparent);
		end

		if tColors and tColors["DEBUFF1"] and tColors["DEBUFF1"]["useBorder"] then
			sAuraDispelCurve:AddPoint(4, VUHDO_safeColorFromTable(tColors["DEBUFF1"], tTransparent));
		else
			sAuraDispelCurve:AddPoint(4, tTransparent);
		end

		if tColors and tColors["DEBUFF9"] and tColors["DEBUFF9"]["useBorder"] then
			sAuraDispelCurve:AddPoint(9, VUHDO_safeColorFromTable(tColors["DEBUFF9"], tTransparent));
		else
			sAuraDispelCurve:AddPoint(9, tTransparent);
		end

		if tColors and tColors["DEBUFF8"] and tColors["DEBUFF8"]["useBorder"] then
			sAuraDispelCurve:AddPoint(11, VUHDO_safeColorFromTable(tColors["DEBUFF8"], tTransparent));
		else
			sAuraDispelCurve:AddPoint(11, tTransparent);
		end

		return;

	end



	--
	function VUHDO_getAuraDispelCurve()

		return sAuraDispelCurve;

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
			return sAuraDispelCurve;
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



	--
	local tRemainingSeconds;
	local tDurationText;
	local tTimerVisibility;
	local tTimerColorMixin;
	local function VUHDO_auraTimerOnLoop()

		for tFontString, tDurationObj in pairs(sAuraTimerData) do
			if tDurationObj and sCurveTimerVisible then
				if sAuraTimerIsAlive[tFontString] then
					tRemainingSeconds = tDurationObj:GetElapsedDuration();
					tTimerVisibility = tDurationObj:EvaluateElapsedDuration(sCurveTimerVisibleElapsed);
				else
					tRemainingSeconds = tDurationObj:GetRemainingDuration();
					tTimerVisibility = tDurationObj:EvaluateRemainingDuration(sCurveTimerVisible);
				end

				tDurationText = AbbreviateNumbers(tRemainingSeconds, sTimeAbbrevData);
				tFontString:SetText(tDurationText or "");

				if sCurveTimerColor and not sAuraTimerIsAlive[tFontString] then
					tTimerColorMixin = tDurationObj:EvaluateRemainingDuration(sCurveTimerColor);
					tFontString:SetTextColor(tTimerColorMixin:GetRGBA());
				end

				tFontString:SetAlpha(tTimerVisibility);
			end
		end

		return;

	end



	--
	function VUHDO_initAuraTimer()

		if sAuraTimerFrame then
			return;
		end

		sAuraTimerFrame = CreateFrame("Frame");
		sAuraTimerFrame:Hide();

		sAuraTimerAnimGroup = sAuraTimerFrame:CreateAnimationGroup();
		sAuraTimerAnimGroup:SetLooping("REPEAT");
		sAuraTimerAnimation = sAuraTimerAnimGroup:CreateAnimation();
		sAuraTimerAnimation:SetDuration(0.1);
		sAuraTimerAnimGroup:SetScript("OnLoop", VUHDO_auraTimerOnLoop);

		return;

	end



	--
	function VUHDO_registerAuraTimerText(aFontString, aDurationObj, anIsAliveTime)

		if not aFontString or not aDurationObj then
			return;
		end

		if not sAuraTimerData[aFontString] then
			sAuraTimerCount = sAuraTimerCount + 1;
		end

		sAuraTimerData[aFontString] = aDurationObj;
		sAuraTimerIsAlive[aFontString] = anIsAliveTime or false;

		if sAuraTimerCount == 1 and sAuraTimerAnimGroup then
			sAuraTimerAnimGroup:Play();
		end

		return;

	end



	--
	function VUHDO_unregisterAuraTimerText(aFontString)

		if not aFontString then
			return;
		end

		if not sAuraTimerData[aFontString] then
			return;
		end

		sAuraTimerData[aFontString] = nil;
		sAuraTimerIsAlive[aFontString] = nil;
		sAuraTimerCount = sAuraTimerCount - 1;

		if sAuraTimerCount == 0 and sAuraTimerAnimGroup then
			sAuraTimerAnimGroup:Stop();
		end

		return;

	end



	--
	local function VUHDO_auraFramePoolReset(aPool, aFrame)

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

		if sAuraIconPool then
			return;
		end

		sAuraIconPool = CreateFramePool("Frame", nil, "VuhDoAuraAnchorIconTemplate", VUHDO_auraFramePoolReset);
		sAuraBarPool = CreateFramePool("Frame", nil, "VuhDoAuraAnchorBarTemplate", VUHDO_auraFramePoolReset);

		return;

	end



	--
	function VUHDO_getAuraPoolContainer()

		if not sAuraPoolContainer then
			sAuraPoolContainer = CreateFrame("Frame", nil, UIParent);

			sAuraPoolContainer:Hide();

			sAuraPoolContainer:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -10000, 10000);
			sAuraPoolContainer:SetSize(1, 1);
		end

		return sAuraPoolContainer;

	end



	--
	local tFrame;
	local tStartTime;
	local tElapsed;
	function VUHDO_prewarmAuraFramePoolsChunk()

		VUHDO_initAuraFramePools();

		tStartTime = debugprofilestop();

		while sPrewarmIconsCreated < sPrewarmIconsNeeded do
			tFrame = sAuraIconPool:Acquire();

			if tFrame then
				tinsert(sPrewarmTempIconFrames, tFrame);
			end

			sPrewarmIconsCreated = sPrewarmIconsCreated + 1;

			tElapsed = (debugprofilestop() - tStartTime) * 1000;

			if tElapsed >= VUHDO_AURA_PREWARM_BUDGET_MS then
				VUHDO_deferPrewarmAuraPools();

				return;
			end
		end

		while sPrewarmBarsCreated < sPrewarmBarsNeeded do
			tFrame = sAuraBarPool:Acquire();

			if tFrame then
				tinsert(sPrewarmTempBarFrames, tFrame);
			end

			sPrewarmBarsCreated = sPrewarmBarsCreated + 1;

			tElapsed = (debugprofilestop() - tStartTime) * 1000;

			if tElapsed >= VUHDO_AURA_PREWARM_BUDGET_MS then
				VUHDO_deferPrewarmAuraPools();

				return;
			end
		end

		for _, tTempFrame in ipairs(sPrewarmTempIconFrames) do
			sAuraIconPool:Release(tTempFrame);
		end

		for _, tTempFrame in ipairs(sPrewarmTempBarFrames) do
			sAuraBarPool:Release(tTempFrame);
		end

		twipe(sPrewarmTempIconFrames);
		twipe(sPrewarmTempBarFrames);

		return;

	end



	--
	function VUHDO_startAuraPoolPrewarm()

		sPrewarmIconsNeeded, sPrewarmBarsNeeded = VUHDO_estimateRequiredAuraFrames();
		sPrewarmIconsCreated = 0;
		sPrewarmBarsCreated = 0;

		twipe(sPrewarmTempIconFrames);
		twipe(sPrewarmTempBarFrames);

		if sPrewarmIconsNeeded > 0 or sPrewarmBarsNeeded > 0 then
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

		tFrame = sAuraIconPool:Acquire();

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

		tFrame = sAuraBarPool:Acquire();

		if not tFrame then
			return nil;
		end

		tFrame["cooldownFrame"] = VUHDO_getAuraBarCooldown(tFrame);
		tFrame["childBar"] = VUHDO_getAuraBarStatusBar(tFrame);

		if tFrame["childBar"] then
			tFrame["childBar"]:SetFrameLevel(tFrame:GetFrameLevel() - 1);
		end

		tFrame["childIcon"] = VUHDO_getAuraBarIconTexture(tFrame);
		tFrame["timerText"] = VUHDO_getAuraBarTimer(tFrame);
		tFrame["countText"] = VUHDO_getAuraBarCounter(tFrame);
		tFrame["chargeTexture"] = VUHDO_getAuraBarChargeTexture(tFrame);

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

		if anIsBar then
			sAuraBarPool:Release(tFrame);
		else
			sAuraIconPool:Release(tFrame);
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

		if not sAuraIconPool or not sAuraBarPool then
			VUHDO_AURA_FRAMES[tFrameName] = nil;

			return;
		end

		for tAnchorIndex, tAnchorFrames in pairs(tButtonFrames) do
			for tSlotIndex, tFrame in pairs(tAnchorFrames) do
				if tFrame then
					if tFrame["childBar"] then
						sAuraBarPool:Release(tFrame);
					elseif tFrame["childB"] then
						sAuraIconPool:Release(tFrame);
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

		if sAuraTimerAnimGroup then
			sAuraTimerAnimGroup:Stop();
		end

		twipe(sAuraTimerData);
		twipe(sAuraTimerIsAlive);

		sAuraTimerCount = 0;

		if sAuraIconPool then
			sAuraIconPool:ReleaseAll();
		end

		if sAuraBarPool then
			sAuraBarPool:ReleaseAll();
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
					sSlotAssignmentPool:release(tAssignment);
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
				sSlotAssignmentPool:release(tAssignment);
			end

			tAssignment = sSlotAssignmentPool:get();

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
					sSlotAssignmentPool:release(tAssignment);
				end

				tAssignment = sSlotAssignmentPool:get();

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
		tHealthBarHeight = tPanelNum and VUHDO_getHealthBarHeight(tPanelNum) or 40;
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

			if tBarVertical then
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
			tXOff = tBaseX + (tCol * (tIconSize + tSpacing) * tGrowX) + (tRow * (tIconSize + tSpacing) * tWrapX);
			tYOff = tBaseY + (tCol * (tTotalHeight + tSpacing) * tGrowY) + (tRow * (tTotalHeight + tSpacing) * tWrapY);
		else
			tXOff = tBaseX + (tCol * (tTotalWidth + tSpacing) * tGrowX) + (tRow * (tTotalWidth + tSpacing) * tWrapX);
			tYOff = tBaseY + (tCol * (tBarHeight + tSpacing) * tGrowY) + (tRow * (tBarHeight + tSpacing) * tWrapY);
		end

		aFrame:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(aFrame, tPos["anchor"], tRelFrame, tPos["relPoint"], tXOff, tYOff);

		if aFrame["childBar"] and tBarVertical then
			VUHDO_PixelUtil.SetSize(aFrame, tIconSize, tTotalHeight);
		else
			VUHDO_PixelUtil.SetSize(aFrame, tTotalWidth, tBarHeight);
		end

		if aFrame["childIcon"] and aFrame["childBar"] then
			aFrame["childIcon"]:ClearAllPoints();
			if tBarVertical then
				if tBarTurnAxis then
					VUHDO_PixelUtil.SetPoint(aFrame["childIcon"], "TOP", aFrame, "TOP", 0, 0);
					VUHDO_PixelUtil.SetSize(aFrame["childIcon"], tIconSize, tIconSize);
					aFrame["childIcon"]:Show();

					if aFrame["cooldownFrame"] and aFrame["childIcon"] then
						aFrame["cooldownFrame"]:ClearAllPoints();
						aFrame["cooldownFrame"]:SetAllPoints(aFrame["childIcon"]);
					end

					if aFrame["chargeTexture"] and aFrame["childIcon"] then
						aFrame["chargeTexture"]:ClearAllPoints();
						aFrame["chargeTexture"]:SetAllPoints(aFrame["childIcon"]);
					end

					aFrame["childBar"]:ClearAllPoints();
					VUHDO_PixelUtil.SetPoint(aFrame["childBar"], "TOP", aFrame["childIcon"], "BOTTOM", 0, 0);
					VUHDO_PixelUtil.SetSize(aFrame["childBar"], tIconSize, tBarHeight);
				else
					VUHDO_PixelUtil.SetPoint(aFrame["childIcon"], "BOTTOM", aFrame, "BOTTOM", 0, 0);
					VUHDO_PixelUtil.SetSize(aFrame["childIcon"], tIconSize, tIconSize);
					aFrame["childIcon"]:Show();

					if aFrame["cooldownFrame"] and aFrame["childIcon"] then
						aFrame["cooldownFrame"]:ClearAllPoints();
						aFrame["cooldownFrame"]:SetAllPoints(aFrame["childIcon"]);
					end

					if aFrame["chargeTexture"] and aFrame["childIcon"] then
						aFrame["chargeTexture"]:ClearAllPoints();
						aFrame["chargeTexture"]:SetAllPoints(aFrame["childIcon"]);
					end

					aFrame["childBar"]:ClearAllPoints();
					VUHDO_PixelUtil.SetPoint(aFrame["childBar"], "BOTTOM", aFrame["childIcon"], "TOP", 0, 0);
					VUHDO_PixelUtil.SetSize(aFrame["childBar"], tIconSize, tBarHeight);
				end
			else
				if tBarTurnAxis then
					VUHDO_PixelUtil.SetPoint(aFrame["childIcon"], "RIGHT", aFrame, "RIGHT", 0, 0);
					VUHDO_PixelUtil.SetSize(aFrame["childIcon"], tIconSize, tIconSize);
					aFrame["childIcon"]:Show();

					if aFrame["cooldownFrame"] and aFrame["childIcon"] then
						aFrame["cooldownFrame"]:ClearAllPoints();
						aFrame["cooldownFrame"]:SetAllPoints(aFrame["childIcon"]);
					end

					if aFrame["chargeTexture"] and aFrame["childIcon"] then
						aFrame["chargeTexture"]:ClearAllPoints();
						aFrame["chargeTexture"]:SetAllPoints(aFrame["childIcon"]);
					end

					aFrame["childBar"]:ClearAllPoints();
					VUHDO_PixelUtil.SetPoint(aFrame["childBar"], "RIGHT", aFrame["childIcon"], "LEFT", 0, 0);
					VUHDO_PixelUtil.SetSize(aFrame["childBar"], tBarWidth, tBarHeight);
				else
					VUHDO_PixelUtil.SetPoint(aFrame["childIcon"], "LEFT", aFrame, "LEFT", 0, 0);
					VUHDO_PixelUtil.SetSize(aFrame["childIcon"], tIconSize, tIconSize);
					aFrame["childIcon"]:Show();

					if aFrame["cooldownFrame"] and aFrame["childIcon"] then
						aFrame["cooldownFrame"]:ClearAllPoints();
						aFrame["cooldownFrame"]:SetAllPoints(aFrame["childIcon"]);
					end

					if aFrame["chargeTexture"] and aFrame["childIcon"] then
						aFrame["chargeTexture"]:ClearAllPoints();
						aFrame["chargeTexture"]:SetAllPoints(aFrame["childIcon"]);
					end

					aFrame["childBar"]:ClearAllPoints();
					VUHDO_PixelUtil.SetPoint(aFrame["childBar"], "LEFT", aFrame["childIcon"], "RIGHT", 0, 0);
					VUHDO_PixelUtil.SetSize(aFrame["childBar"], tBarWidth, tBarHeight);
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
			tBarHeight = VUHDO_getHealthBarHeight(tPanelNum);
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

		if aFrame["childBar"] then
			tBarVertical = anAnchorConfig["barVertical"] or false;

			if tBarVertical then
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
			tHealthBarHeight = tPanelNum and VUHDO_getHealthBarHeight(tPanelNum) or 40;
			tOffsetXPixels = (anAnchorConfig["offsetX"] or 0) * tHealthBarWidth * 0.01;
			tOffsetYPixels = -(anAnchorConfig["offsetY"] or 0) * tHealthBarHeight * 0.01;

			if aFrame["childBar"] and tBarVertical then
				tXOff = tOffsetXPixels + (tCol * (tIconSize + tSpacing) * tGrowX) + (tRow * (tIconSize + tSpacing) * tWrapX);
				tYOff = tOffsetYPixels + (tCol * (tTotalHeight + tSpacing) * tGrowY) + (tRow * (tTotalHeight + tSpacing) * tWrapY);
			else
				tXOff = tOffsetXPixels + (tCol * (tTotalWidth + tSpacing) * tGrowX) + (tRow * (tTotalWidth + tSpacing) * tWrapX);
				tYOff = tOffsetYPixels + (tCol * (tBarHeight + tSpacing) * tGrowY) + (tRow * (tBarHeight + tSpacing) * tWrapY);
			end

			aFrame:ClearAllPoints();
			VUHDO_PixelUtil.SetPoint(aFrame, tAnchorPoint[1], aButton, tAnchorPoint[1], tXOff, tYOff);

			if aFrame["childBar"] and tBarVertical then
				VUHDO_PixelUtil.SetSize(aFrame, tIconSize, tTotalHeight);
			else
				VUHDO_PixelUtil.SetSize(aFrame, tTotalWidth, tBarHeight);
			end
		end

		tChild = aFrame["childB"] or aFrame["childBar"] or VUHDO_getAuraIconBackdrop(aFrame) or VUHDO_getAuraBarStatusBar(aFrame);

		if tChild then
			tChild:ClearAllPoints();

			if aFrame["childIcon"] and aFrame["childBar"] then
				tBarVertical = anAnchorConfig["barVertical"] or false;
				tBarTurnAxis = anAnchorConfig["barTurnAxis"] or false;

				if tBarVertical then
					tBarWidth = VUHDO_getAuraBarWidthPixelsVertical(aButton, anAnchorConfig);
					tBarHeight = VUHDO_getAuraBarHeightPixelsVertical(aButton, anAnchorConfig);

					tIconSize = tBarWidth;

					aFrame["childIcon"]:ClearAllPoints();
					if tBarTurnAxis then
						VUHDO_PixelUtil.SetPoint(aFrame["childIcon"], "TOP", aFrame, "TOP", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["childIcon"], tIconSize, tIconSize);
						aFrame["childIcon"]:Show();

						if aFrame["cooldownFrame"] and aFrame["childIcon"] then
							aFrame["cooldownFrame"]:ClearAllPoints();
							aFrame["cooldownFrame"]:SetAllPoints(aFrame["childIcon"]);
						end

						if aFrame["chargeTexture"] and aFrame["childIcon"] then
							aFrame["chargeTexture"]:ClearAllPoints();
							aFrame["chargeTexture"]:SetAllPoints(aFrame["childIcon"]);
						end

						tChild:ClearAllPoints();
						VUHDO_PixelUtil.SetPoint(tChild, "TOP", aFrame["childIcon"], "BOTTOM", 0, 0);
						VUHDO_PixelUtil.SetSize(tChild, tIconSize, tBarHeight);
					else
						VUHDO_PixelUtil.SetPoint(aFrame["childIcon"], "BOTTOM", aFrame, "BOTTOM", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["childIcon"], tIconSize, tIconSize);
						aFrame["childIcon"]:Show();

						if aFrame["cooldownFrame"] and aFrame["childIcon"] then
							aFrame["cooldownFrame"]:ClearAllPoints();
							aFrame["cooldownFrame"]:SetAllPoints(aFrame["childIcon"]);
						end

						if aFrame["chargeTexture"] and aFrame["childIcon"] then
							aFrame["chargeTexture"]:ClearAllPoints();
							aFrame["chargeTexture"]:SetAllPoints(aFrame["childIcon"]);
						end

						tChild:ClearAllPoints();
						VUHDO_PixelUtil.SetPoint(tChild, "BOTTOM", aFrame["childIcon"], "TOP", 0, 0);
						VUHDO_PixelUtil.SetSize(tChild, tIconSize, tBarHeight);
					end
				else
					aFrame["childIcon"]:ClearAllPoints();
					if tBarTurnAxis then
						VUHDO_PixelUtil.SetPoint(aFrame["childIcon"], "RIGHT", aFrame, "RIGHT", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["childIcon"], tIconSize, tIconSize);
						aFrame["childIcon"]:Show();

						if aFrame["cooldownFrame"] and aFrame["childIcon"] then
							aFrame["cooldownFrame"]:ClearAllPoints();
							aFrame["cooldownFrame"]:SetAllPoints(aFrame["childIcon"]);
						end

						if aFrame["chargeTexture"] and aFrame["childIcon"] then
							aFrame["chargeTexture"]:ClearAllPoints();
							aFrame["chargeTexture"]:SetAllPoints(aFrame["childIcon"]);
						end

						tChild:ClearAllPoints();
						VUHDO_PixelUtil.SetPoint(tChild, "RIGHT", aFrame["childIcon"], "LEFT", 0, 0);
						VUHDO_PixelUtil.SetSize(tChild, tBarWidth, tBarHeight);
					else
						VUHDO_PixelUtil.SetPoint(aFrame["childIcon"], "LEFT", aFrame, "LEFT", 0, 0);
						VUHDO_PixelUtil.SetSize(aFrame["childIcon"], tIconSize, tIconSize);
						aFrame["childIcon"]:Show();

						if aFrame["cooldownFrame"] and aFrame["childIcon"] then
							aFrame["cooldownFrame"]:ClearAllPoints();
							aFrame["cooldownFrame"]:SetAllPoints(aFrame["childIcon"]);
						end

						if aFrame["chargeTexture"] and aFrame["childIcon"] then
							aFrame["chargeTexture"]:ClearAllPoints();
							aFrame["chargeTexture"]:SetAllPoints(aFrame["childIcon"]);
						end

						tChild:ClearAllPoints();
						VUHDO_PixelUtil.SetPoint(tChild, "LEFT", aFrame["childIcon"], "RIGHT", 0, 0);
						VUHDO_PixelUtil.SetSize(tChild, tBarWidth, tBarHeight);
					end
				end

				tSize = tIconSize;

				if aFrame["timerText"] and anAnchorConfig["TIMER_TEXT"] then
					VUHDO_customizeIconText(aFrame["childIcon"], tSize, aFrame["timerText"], anAnchorConfig["TIMER_TEXT"]);
				end

				if aFrame["countText"] and anAnchorConfig["COUNTER_TEXT"] then
					VUHDO_customizeIconText(aFrame["childIcon"], tSize, aFrame["countText"], anAnchorConfig["COUNTER_TEXT"]);
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

	tShowTooltip = VUHDO_resolveAuraTriState(tAnchorConfig and tAnchorConfig["showTooltip"], "showTooltip");

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

	for tAnchorIndex, tSlots in pairs(tAnchorSlots) do
		tAnchorConfig = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"][tAnchorIndex];

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

					tSlotDataAsAura = sSlotDataAsAuraPool:get();

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

					VUHDO_displayAuraInSlot(tButton, aPanelNum, anAnchorIndex, tActualSlot, tSlotDataAsAura, anAnchorConfig);

					sSlotDataAsAuraPool:release(tSlotDataAsAura);
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
	function VUHDO_updateAuraIconDisplay(aIconTexture, aCooldownFrame, aBackdropFrame, anAnchorConfig, anAuraData, aDurationObj, aUnit)

		tIconType = anAnchorConfig["iconType"] or 1;

		if aIconTexture then
			if tIconType == 4 then
				aIconTexture:Hide();
			elseif tIconType == 3 then
				aIconTexture:SetTexture("Interface\\AddOns\\VuhDo\\Images\\hot_flat_16_16");

				if anAuraData["color"] and anAuraData["color"]["R"] then
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

				if anAuraData["color"] and anAuraData["color"]["R"] then
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

				if anAuraData["color"] and anAuraData["color"]["R"] then
					aIconTexture:SetVertexColor(VUHDO_backColor(anAuraData["color"]));
				else
					aIconTexture:SetVertexColor(1, 1, 1);
				end

				aIconTexture:Show();
			end
		end

		tShowClock = VUHDO_resolveAuraTriState(anAnchorConfig["showClock"], "showClock");

		if aCooldownFrame then
			if tShowClock and aDurationObj then
				aCooldownFrame:SetCooldownFromDurationObject(aDurationObj);
				aCooldownFrame:SetAlpha(1);
			else
				aCooldownFrame:SetAlpha(0);
			end
		end

		tFadeOnLow = VUHDO_resolveAuraTriState(anAnchorConfig["fadeOnLow"], "fadeOnLow");

		if aIconTexture then
			if tFadeOnLow and aDurationObj and sCurveFadeAlpha then
				tFadeAlpha = aDurationObj:EvaluateRemainingDuration(sCurveFadeAlpha);
				aIconTexture:SetAlpha(tFadeAlpha);
			else
				aIconTexture:SetAlpha(1);
			end
		end

		tDispelBorder = VUHDO_resolveAuraTriState(anAnchorConfig["dispelBorder"], "dispelBorder");

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
	function VUHDO_updateAuraTimerAndStacks(aTimerText, aCountText, aChargeTexture, anAnchorConfig, anAuraData, aDurationObj, aUnit)

		if aTimerText then
			tShowTimer = VUHDO_resolveAuraTriState(anAnchorConfig["showTimer"], "showTimer");

			if tShowTimer and aDurationObj and sCurveTimerVisible then
				if anAuraData["isAliveTime"] then
					tRemainingSeconds = aDurationObj:GetElapsedDuration();
					tTimerVisibility = aDurationObj:EvaluateElapsedDuration(sCurveTimerVisibleElapsed);
				else
					tRemainingSeconds = aDurationObj:GetRemainingDuration();
					tTimerVisibility = aDurationObj:EvaluateRemainingDuration(sCurveTimerVisible);
				end

				tDurationText = AbbreviateNumbers(tRemainingSeconds, sTimeAbbrevData);
				aTimerText:SetText(tDurationText or "");

				if sCurveTimerColor and not anAuraData["isAliveTime"] then
					tTimerColorMixin = aDurationObj:EvaluateRemainingDuration(sCurveTimerColor);
					aTimerText:SetTextColor(tTimerColorMixin:GetRGBA());
				elseif anAnchorConfig["TIMER_TEXT"] and anAnchorConfig["TIMER_TEXT"]["COLOR"] then
					aTimerText:SetTextColor(VUHDO_textColor(anAnchorConfig["TIMER_TEXT"]["COLOR"]));
				else
					aTimerText:SetTextColor(1, 1, 1, 1);
				end

				aTimerText:SetAlpha(tTimerVisibility);

				VUHDO_registerAuraTimerText(aTimerText, aDurationObj, anAuraData["isAliveTime"]);
			else
				VUHDO_unregisterAuraTimerText(aTimerText);

				aTimerText:SetText("");
				aTimerText:SetTextColor(1, 1, 1, 1);
				aTimerText:SetAlpha(1);
			end
		end

		if aCountText then
			tShowStacks = VUHDO_resolveAuraTriState(anAnchorConfig["showStacks"], "showStacks");
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
	local tFlashZone;
	function VUHDO_displayAuraAsIcon(aButton, aPanelNum, anAnchorIndex, aSlotIndex, anAuraData, anAnchorConfig)

		if not aButton or not anAnchorIndex or not aSlotIndex or not anAuraData or not anAnchorConfig then
			return;
		end

		tIconFrame = VUHDO_acquireAuraIconFrame(aButton, anAnchorIndex, aSlotIndex);

		if not tIconFrame then
			return;
		end

		tIconFrame["panelNum"] = aPanelNum;
		tIconFrame["anchorIndex"] = anAnchorIndex;
		tIconFrame["auraInstanceId"] = anAuraData["auraInstanceID"];

		tUnit = aButton:GetAttribute("unit");

		tDurationObj = nil;

		if tUnit and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
			tDurationObj = GetAuraDuration(tUnit, anAuraData["auraInstanceID"]);
		elseif anAuraData["duration"] and anAuraData["duration"] > 0 and anAuraData["expirationTime"] then
			tDurationObj = VUHDO_getOrCreateDuration(anAnchorIndex, aSlotIndex);

			tDurationObj:SetTimeFromEnd(anAuraData["expirationTime"], anAuraData["duration"]);
		end

		tChild = tIconFrame["childB"] or VUHDO_getAuraIconBackdrop(tIconFrame);

		if tChild then
			tTexture = tChild["textureI"] or VUHDO_getAuraIconTexture(tChild);

			VUHDO_updateAuraIconDisplay(tTexture, tChild["cooldownFrame"], tChild, anAnchorConfig, anAuraData, tDurationObj, tUnit);

			tTimerText = tChild["timerText"];
			tCountText = tChild["countText"];

			VUHDO_updateAuraTimerAndStacks(tTimerText, tCountText, tChild["chargeTexture"], anAnchorConfig, anAuraData, tDurationObj, tUnit);

			tChild:SetAlpha(1);

			tFlashOnLow = VUHDO_resolveAuraTriState(anAnchorConfig["flashOnLow"], "flashOnLow");

			if tFlashOnLow and tDurationObj and sCurveFlashZone and not tDurationObj:HasSecretValues() then
				tFlashZone = tDurationObj:EvaluateRemainingDuration(sCurveFlashZone);

				if tFlashZone > 0.5 then
					VUHDO_UIFrameFlash(tIconFrame, 0.2, 0.1, 5, true, 0, 0.1);
				else
					VUHDO_UIFrameFlashStop(tIconFrame);
				end
			else
				VUHDO_UIFrameFlashStop(tIconFrame);
			end
		end

		tIconFrame:SetAlpha(1);

		return;

	end
end



do
	--
	local tBarFrame;
	local tBar;
	local tBarTexName;
	local tUnit;
	local tDurationObj;
	local tFlashOnLow;
	local tFlashZone;
	local tBarVertical;
	local tBarTurnAxis;
	local tBarInvertGrowth;
	local tBarOrientation;
	local tTimerDirection;
	local tColorMode;
	local tColorMixin;
	local tClassColor;
	local tBarColor;
	local tDispelCurve;
	function VUHDO_displayAuraAsBar(aButton, aPanelNum, anAnchorIndex, aSlotIndex, anAuraData, anAnchorConfig)

		if not aButton or not anAnchorIndex or not aSlotIndex or not anAuraData or not anAnchorConfig then
			return;
		end

		tBarFrame = VUHDO_acquireAuraBarFrame(aButton, anAnchorIndex, aSlotIndex);

		if not tBarFrame then
			return;
		end

		tBarFrame["panelNum"] = aPanelNum;
		tBarFrame["anchorIndex"] = anAnchorIndex;
		tBarFrame["auraInstanceId"] = anAuraData["auraInstanceID"];

		tUnit = aButton:GetAttribute("unit");

		tDurationObj = nil;

		if tUnit and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
			tDurationObj = GetAuraDuration(tUnit, anAuraData["auraInstanceID"]);
		elseif anAuraData["duration"] and anAuraData["duration"] > 0 and anAuraData["expirationTime"] then
			tDurationObj = VUHDO_getOrCreateDuration(anAnchorIndex, aSlotIndex);

			tDurationObj:SetTimeFromEnd(anAuraData["expirationTime"], anAuraData["duration"]);
		end

		tBar = tBarFrame["childBar"];

		if not tBar then
			return;
		end

		tBarTexName = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"] and VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["barTexture"];

		if tBarTexName then
			VUHDO_setLlcStatusBarTexture(tBar, tBarTexName);
		end

		if anAuraData["color"] and anAuraData["color"]["R"] then
			tBar:GetStatusBarTexture():SetVertexColor(VUHDO_backColor(anAuraData["color"]));
		else
			tColorMode = anAnchorConfig["colorMode"] or "default";

			if "debuff" == tColorMode and anAuraData["dispelName"] then
				tDispelCurve = VUHDO_getDispelTypeCurve();

				if tDispelCurve and anAuraData["auraInstanceID"] and anAuraData["auraInstanceID"] >= 0 then
					tColorMixin = GetAuraDispelTypeColor(tUnit, anAuraData["auraInstanceID"], tDispelCurve);

					if tColorMixin then
						tBar:GetStatusBarTexture():SetVertexColor(tColorMixin:GetRGBA());
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
				tBarColor = sBarColors and sBarColors["AURA_BAR_DEFAULT"];

				if tBarColor then
					tBar:GetStatusBarTexture():SetVertexColor(tBarColor["R"], tBarColor["G"], tBarColor["B"], tBarColor["O"] or 1);
				else
					tBar:GetStatusBarTexture():SetVertexColor(0.2, 0.6, 0.2, 1);
				end
			end
		end

		tBarVertical = anAnchorConfig["barVertical"] or false;
		tBarTurnAxis = anAnchorConfig["barTurnAxis"] or false;
		tBarInvertGrowth = anAnchorConfig["barInvertGrowth"] or false;

		if tBarVertical then
			tBarOrientation = tBarTurnAxis and VUHDO_STATUSBAR_TOP_TO_BOTTOM or VUHDO_STATUSBAR_BOTTOM_TO_TOP;
		else
			tBarOrientation = tBarTurnAxis and VUHDO_STATUSBAR_RIGHT_TO_LEFT or VUHDO_STATUSBAR_LEFT_TO_RIGHT;
		end

		VUHDO_setStatusBarOrientation(tBar, tBarOrientation);

		if tDurationObj then
			tTimerDirection = tBarInvertGrowth and Enum.StatusBarTimerDirection.ElapsedTime or Enum.StatusBarTimerDirection.RemainingTime;

			tBar:SetTimerDuration(tDurationObj, Enum.StatusBarInterpolation.Immediate, tTimerDirection);
		else
			tBar:SetMinMaxValues(0, 1);

			tBar:SetValue(tBarInvertGrowth and 0 or 1);
		end

		VUHDO_updateAuraIconDisplay(tBarFrame["childIcon"], tBarFrame["cooldownFrame"], nil, anAnchorConfig, anAuraData, tDurationObj, tUnit);

		VUHDO_updateAuraTimerAndStacks(tBarFrame["timerText"], tBarFrame["countText"], tBarFrame["chargeTexture"], anAnchorConfig, anAuraData, tDurationObj, tUnit);

		tBar:SetAlpha(1);

		tFlashOnLow = VUHDO_resolveAuraTriState(anAnchorConfig["flashOnLow"], "flashOnLow");

		if tFlashOnLow and tDurationObj and sCurveFlashZone and not tDurationObj:HasSecretValues() then
			tFlashZone = tDurationObj:EvaluateRemainingDuration(sCurveFlashZone);

			if tFlashZone > 0.5 then
				VUHDO_UIFrameFlash(tBarFrame, 0.2, 0.1, 5, true, 0, 0.1);
			else
				VUHDO_UIFrameFlashStop(tBarFrame);
			end
		else
			VUHDO_UIFrameFlashStop(tBarFrame);
		end

		tBarFrame:SetAlpha(1);

		return;

	end
end



do
	--
	local tFrameName;
	local tFrame;
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

			VUHDO_UIFrameFlashStop(tFrame);

			if tFrame["childIcon"] then
				tFrame["childIcon"]:Hide();
			end

			if tFrame["auraInstanceId"] then
				tFrame["auraInstanceId"] = nil;
			end

			tFrame:SetAlpha(0);
		end

		return;

	end
end



--
function VUHDO_updateAuraDisplaysForUnit(aUnit)

	if sAurasSuspended then
		return;
	end

	if not aUnit then
		return;
	end

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		VUHDO_updateAurasForAnchors(aUnit, tPanelNum);
	end

	return;

end