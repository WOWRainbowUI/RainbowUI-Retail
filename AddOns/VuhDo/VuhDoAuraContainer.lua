local _;

local pairs = pairs;
local ipairs = ipairs;
local tinsert = table.insert;
local tconcat = table.concat;
local tsort = table.sort;
local twipe = table.wipe;
local format = string.format;

local CreateFrame = CreateFrame;
local InCombatLockdown = InCombatLockdown;
local UnitExists = UnitExists;
local UnitCanAttack = UnitCanAttack;
local UnitCanAssist = UnitCanAssist;
local UnitIsPlayerControlledOrGroupMember = UnitIsPlayerControlledOrGroupMember;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsVisible = UnitIsVisible;
local issecretvalue = issecretvalue;
local CreateNumericRuleFormatter = C_StringUtil and C_StringUtil.CreateNumericRuleFormatter;
local CreateColorCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve;
local CreateColor = CreateColor;

local VUHDO_ON_UPDATE_MODE_RUN_ONCE = Enum.OnUpdateMode.RunOnce;

VUHDO_AURA_CONTAINERS = VUHDO_AURA_CONTAINERS or { };
local VUHDO_AURA_CONTAINERS = VUHDO_AURA_CONTAINERS;

VUHDO_OVERLAY_CONTAINERS = VUHDO_OVERLAY_CONTAINERS or { };
local VUHDO_OVERLAY_CONTAINERS = VUHDO_OVERLAY_CONTAINERS;

VUHDO_OVERLAY_SLOT_HOSTS = VUHDO_OVERLAY_SLOT_HOSTS or { };
local VUHDO_OVERLAY_SLOT_HOSTS = VUHDO_OVERLAY_SLOT_HOSTS;

VUHDO_MISSING_BUFF_CONTAINERS = VUHDO_MISSING_BUFF_CONTAINERS or { };
local VUHDO_MISSING_BUFF_CONTAINERS = VUHDO_MISSING_BUFF_CONTAINERS;

local VUHDO_AURA_CONTAINER_TEMPLATE = "VuhDoAuraContainerTemplate";
local VUHDO_FILL_CHAIN_CONTAINER_TEMPLATE = "VuhDoFillChainAuraContainerTemplate";
VUHDO_AURA_BUTTON_ICON_TEMPLATE = "VuhDoAuraButtonIconTemplate";
VUHDO_AURA_BUTTON_BAR_TEMPLATE = "VuhDoAuraButtonBarTemplate";
VUHDO_AURA_BUTTON_DISPEL_OVERLAY_TEMPLATE = "VuhDoAuraButtonDispelOverlayTemplate";

VUHDO_AURA_CONTAINER_TEMPLATE_CACHE = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE or { };
local VUHDO_AURA_CONTAINER_TEMPLATE_CACHE = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE;
VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION or 0;
local VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION;

VUHDO_AURA_CONTAINER_METRICS = VUHDO_AURA_CONTAINER_METRICS or {
	["builds"] = { },
	["releases"] = { },
	["runtime"] = { },
};
local VUHDO_AURA_CONTAINER_METRICS = VUHDO_AURA_CONTAINER_METRICS;

VUHDO_AURA_GROWTH_OFFSETS = VUHDO_AURA_GROWTH_OFFSETS or {
	["LEFT"] = { -1, 0 },
	["RIGHT"] = { 1, 0 },
	["UP"] = { 0, 1 },
	["DOWN"] = { 0, -1 },
};

VUHDO_INDICATOR_OVERLAY_TARGETS = {
	["HEALTH_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 1,
		["barValue"] = "bouquet",
	},
	["MANA_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 2,
		["barValue"] = "bouquet",
	},
	["BACKGROUND_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 3,
		["barValue"] = "binary",
	},
	["AGGRO_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 4,
		["barValue"] = "binary",
	},
	["THREAT_BAR"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 7,
		["barValue"] = "bouquet",
	},
	["MOUSEOVER_HIGHLIGHT"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 8,
		["barValue"] = "binary",
	},
	["SIDE_LEFT"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 17,
		["barValue"] = "bouquet",
	},
	["SIDE_RIGHT"] = {
		["shape"] = "bar",
		["getter"] = "VUHDO_getHealthBar",
		["barIndex"] = 18,
		["barValue"] = "bouquet",
	},
	["BAR_BORDER"] = {
		["shape"] = "border",
		["getter"] = "VUHDO_getPlayerTargetFrame",
	},
	["CLUSTER_BORDER"] = {
		["shape"] = "border",
		["getter"] = "VUHDO_getClusterBorderFrame",
	},
	["SWIFTMEND_INDICATOR"] = {
		["shape"] = "dot",
		["getter"] = "VUHDO_getBarRoleIcon",
		["iconIndex"] = 51,
	},
	["THREAT_MARK"] = {
		["shape"] = "dot",
		["getter"] = "VUHDO_getAggroTexture",
		["barIndex"] = 1,
		["isBarRelative"] = true,
		["staticIcon"] = "Interface\\AddOns\\VuhDo\\Images\\aggro",
	},
};

local VUHDO_PANEL_SETUP;
local VUHDO_RAID;
local VUHDO_STATUSBAR_LEFT_TO_RIGHT;
local VUHDO_STATUSBAR_RIGHT_TO_LEFT;
local VUHDO_STATUSBAR_BOTTOM_TO_TOP;
local VUHDO_STATUSBAR_TOP_TO_BOTTOM;
local VUHDO_SPELL_DURATION_MODE_FULL;
local VUHDO_SPELL_DURATION_MODE_ALIVE;
local VUHDO_ATLAS_TEXTURES;
local VUHDO_AURA_IDENTITY_GATE_HELPFUL;
local VUHDO_AURA_IDENTITY_GATE_HARMFUL;
local VUHDO_BUTTON_CACHE;
local VUHDO_MAX_PANELS;

local VUHDO_PixelUtil;
local VUHDO_LibSharedMedia;

local VUHDO_getUnitButtonsSafe;
local VUHDO_getHealthBar;
local VUHDO_setStatusBarOrientation;
local VUHDO_setLlcStatusBarTexture;
local VUHDO_copyStatusBarFillTexture;
local VUHDO_getClassColor;
local VUHDO_backColorWithFallback;
local VUHDO_customizeIconText;
local VUHDO_resolveAuraTriState;
local VUHDO_isAuraDataRestricted;
local VUHDO_isAuraModeContainers;
local VUHDO_resolveGroupTimerSettings;
local VUHDO_startAuraButtonGlow;
local VUHDO_getDispelTypeColorMap;
local VUHDO_getDispelTypeColorMapOpaque;
local VUHDO_getDispelTypeBorderCurve;
local VUHDO_applyAuraGroupBarGlowFromAuraButton;
local VUHDO_getAuraAnchorHost;
local VUHDO_unitPhaseReason;
local VUHDO_isSpecialUnit;
local VUHDO_stopOverlayThreatMarkFlashForSlotRecord;
local VUHDO_deferVolatilePassForButton;
local VUHDO_fixFrameLevels;
local VUHDO_deferInitAuraContainersForButton;
local VUHDO_rebuildAuraAnchorsForAllButtons;

local sAuraBorderOptions = {
	["style"] = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
	["showWhenHarmful"] = true,
	["showWhenHelpful"] = true,
};

local sAuraIconDispelBorderOptionsBind = {
	["style"] = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
	["showWhenHarmful"] = true,
	["showWhenHelpful"] = true,
};

local sAuraSymbolOptions = {
	["showWhenHarmful"] = true,
	["showWhenHelpful"] = true,
};

local sDispelOverlayIconOptions = {
	["style"] = Enum.CustomAuraButtonDispelTypeTextureStyle.Icon,
	["showWhenHarmful"] = true,
	["showWhenHelpful"] = true,
};

local sAuraOpaqueBorderOptions = {
	["style"] = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
	["showWhenHarmful"] = true,
	["showWhenHelpful"] = true,
};

local sAuraDurationBarOptions = { };
local sEmpty = { };

local sGateState = {
	["canAttack"] = false,
	["canApplyHelpfulIdentity"] = false,
	["canApplyHarmfulIdentity"] = false,
	["isAuraFilterRestricted"] = false,
	["isDisconnected"] = false,
};
VUHDO_AURA_CONTAINER_GATE_STATE = sGateState;

local sPendingContainerBuilds = { };
local sPendingClassColors = { };
local sPendingClassColorRetry = { };
local sHasPendingBuilds = false;
local sSeenAnchors = { };
local sDirtyAnchorPanels = { };
local sContainerClassColorBars = { };

local sAuraBarIconLayouts = {
	[0] = {
		["iconPoint"] = "LEFT",
		["barPoint"] = "LEFT",
		["barRelPoint"] = "RIGHT",
		["useBarWidth"] = true,
	},
	[1] = {
		["iconPoint"] = "RIGHT",
		["barPoint"] = "RIGHT",
		["barRelPoint"] = "LEFT",
		["useBarWidth"] = true,
	},
	[2] = {
		["iconPoint"] = "BOTTOM",
		["barPoint"] = "BOTTOM",
		["barRelPoint"] = "TOP",
		["useBarWidth"] = false,
	},
	[3] = {
		["iconPoint"] = "TOP",
		["barPoint"] = "TOP",
		["barRelPoint"] = "BOTTOM",
		["useBarWidth"] = false,
	},
};

local sAuraTimerFormatterFull;
local sAuraTimerFormattersByThreshold = { };
local sAuraTimerColorCurveFull;
local sAuraTimerColorCurvesByThreshold = { };
local sChainBaselineColors = { };
local sChainBaselineFrames = { };
local sChainBackgroundFillOwners = { };
local sMissingBuffBarColors = { };
local sSignatureParts = { };
local sVolatileSignatureParts = { };

local sBorderTexture;
local sBorderColorR;
local sBorderColorG;
local sBorderColorB;
local sBorderColorO;
local sBorderWidth;
local sBorderFile;

local sBorderCoordStart = 0.0625;
local sBorderCoordEnd = 1 - sBorderCoordStart;

local sBorderPieceKeys = {
	"BorderCornerTopLeft",
	"BorderCornerTopRight",
	"BorderCornerBottomLeft",
	"BorderCornerBottomRight",
	"BorderEdgeTop",
	"BorderEdgeBottom",
	"BorderEdgeLeft",
	"BorderEdgeRight",
};

local sBorderPieceCoords = {
	["BorderCornerTopLeft"] = {
		["ULx"] = 0.5078125, ["ULy"] = sBorderCoordStart, ["LLx"] = 0.5078125, ["LLy"] = sBorderCoordEnd,
		["URx"] = 0.6171875, ["URy"] = sBorderCoordStart, ["LRx"] = 0.6171875, ["LRy"] = sBorderCoordEnd,
	},
	["BorderCornerTopRight"] = {
		["ULx"] = 0.6328125, ["ULy"] = sBorderCoordStart, ["LLx"] = 0.6328125, ["LLy"] = sBorderCoordEnd,
		["URx"] = 0.7421875, ["URy"] = sBorderCoordStart, ["LRx"] = 0.7421875, ["LRy"] = sBorderCoordEnd,
	},
	["BorderCornerBottomLeft"] = {
		["ULx"] = 0.7578125, ["ULy"] = sBorderCoordStart, ["LLx"] = 0.7578125, ["LLy"] = sBorderCoordEnd,
		["URx"] = 0.8671875, ["URy"] = sBorderCoordStart, ["LRx"] = 0.8671875, ["LRy"] = sBorderCoordEnd,
	},
	["BorderCornerBottomRight"] = {
		["ULx"] = 0.8828125, ["ULy"] = sBorderCoordStart, ["LLx"] = 0.8828125, ["LLy"] = sBorderCoordEnd,
		["URx"] = 0.9921875, ["URy"] = sBorderCoordStart, ["LRx"] = 0.9921875, ["LRy"] = sBorderCoordEnd,
	},
	["BorderEdgeTop"] = {
		["ULx"] = 0.2578125, ["ULy"] = "repeatX", ["LLx"] = 0.3671875, ["LLy"] = "repeatX",
		["URx"] = 0.2578125, ["URy"] = sBorderCoordStart, ["LRx"] = 0.3671875, ["LRy"] = sBorderCoordStart,
	},
	["BorderEdgeBottom"] = {
		["ULx"] = 0.3828125, ["ULy"] = "repeatX", ["LLx"] = 0.4921875, ["LLy"] = "repeatX",
		["URx"] = 0.3828125, ["URy"] = sBorderCoordStart, ["LRx"] = 0.4921875, ["LRy"] = sBorderCoordStart,
	},
	["BorderEdgeLeft"] = {
		["ULx"] = 0.0078125, ["ULy"] = sBorderCoordStart, ["LLx"] = 0.0078125, ["LLy"] = "repeatY",
		["URx"] = 0.1171875, ["URy"] = sBorderCoordStart, ["LRx"] = 0.1171875, ["LRy"] = "repeatY",
	},
	["BorderEdgeRight"] = {
		["ULx"] = 0.1328125, ["ULy"] = sBorderCoordStart, ["LLx"] = 0.1328125, ["LLy"] = "repeatY",
		["URx"] = 0.2421875, ["URy"] = sBorderCoordStart, ["LRx"] = 0.2421875, ["LRy"] = "repeatY",
	},
};



do
	--
	local tBreakpoints;
	local function VUHDO_copyAuraTimerBaseBreakpoints()

		tBreakpoints = {
			{
				["threshold"] = 3600,
				["format"] = "%.1f",
				["components"] = {
					{
						["div"] = 3600,
						["step"] = 0.1,
						["rounding"] = Enum.NumericRuleFormatRounding.Down,
					},
				},
			},
			{
				["threshold"] = 60,
				["format"] = "%d",
				["components"] = {
					{
						["div"] = 60,
						["step"] = 1,
						["rounding"] = Enum.NumericRuleFormatRounding.Down,
					},
				},
			},
			{
				["threshold"] = 0,
				["step"] = 1,
				["rounding"] = Enum.NumericRuleFormatRounding.Down,
				["format"] = "%d",
			},
		};

		return tBreakpoints;

	end



	--
	local tFormatter;
	local tTimerThreshold;
	local tHideThreshold;
	function VUHDO_getAuraTimerFormatter(aDurationMode, aTimerThreshold)

		if aDurationMode == VUHDO_SPELL_DURATION_MODE_FULL or aDurationMode == VUHDO_SPELL_DURATION_MODE_ALIVE then
			-- FIXME: alive mode elapsed time is not supported by CustomAuraButton DurationTextBinding
			if not sAuraTimerFormatterFull then
				sAuraTimerFormatterFull = CreateNumericRuleFormatter();
				sAuraTimerFormatterFull:SetBreakpoints(VUHDO_copyAuraTimerBaseBreakpoints());
			end

			return sAuraTimerFormatterFull;
		end

		tTimerThreshold = aTimerThreshold or 9.99;
		tFormatter = sAuraTimerFormattersByThreshold[tTimerThreshold];

		if not tFormatter then
			tFormatter = CreateNumericRuleFormatter();
			tBreakpoints = VUHDO_copyAuraTimerBaseBreakpoints();

			tHideThreshold = tTimerThreshold + 0.01;

			tBreakpoints[#tBreakpoints + 1] = {
				["threshold"] = tHideThreshold,
				["format"] = "",
			};

			tsort(tBreakpoints, function(aLeft, aRight)
				return aLeft["threshold"] > aRight["threshold"];
			end);

			tFormatter:SetBreakpoints(tBreakpoints);
			sAuraTimerFormattersByThreshold[tTimerThreshold] = tFormatter;
		end

		return tFormatter;

	end



	--
	local tColorCurve;
	function VUHDO_getAuraTimerColorCurve(aDurationMode, aTimerThreshold)

		if aDurationMode == VUHDO_SPELL_DURATION_MODE_FULL then
			return sAuraTimerColorCurveFull;
		end

		tColorCurve = sAuraTimerColorCurvesByThreshold[aTimerThreshold];

		if not tColorCurve then
			tColorCurve = CreateColorCurve();
			tColorCurve:SetType(Enum.LuaCurveType.Step);

			tColorCurve:AddPoint(0, CreateColor(1, 1, 1, 0));
			tColorCurve:AddPoint(0.1, CreateColor(1, 0.2, 0.2, 1));
			tColorCurve:AddPoint(4.9, CreateColor(1, 1, 1, 1));
			tColorCurve:AddPoint((aTimerThreshold or 9.99) + 0.01, CreateColor(1, 1, 1, 0));

			sAuraTimerColorCurvesByThreshold[aTimerThreshold] = tColorCurve;
		end

		return tColorCurve;

	end
end



--
function VUHDO_auraContainerInitLocalOverrides()

	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_STATUSBAR_LEFT_TO_RIGHT = _G["VUHDO_STATUSBAR_LEFT_TO_RIGHT"];
	VUHDO_STATUSBAR_RIGHT_TO_LEFT = _G["VUHDO_STATUSBAR_RIGHT_TO_LEFT"];
	VUHDO_STATUSBAR_BOTTOM_TO_TOP = _G["VUHDO_STATUSBAR_BOTTOM_TO_TOP"];
	VUHDO_STATUSBAR_TOP_TO_BOTTOM = _G["VUHDO_STATUSBAR_TOP_TO_BOTTOM"];
	VUHDO_SPELL_DURATION_MODE_FULL = _G["VUHDO_SPELL_DURATION_MODE_FULL"];
	VUHDO_SPELL_DURATION_MODE_ALIVE = _G["VUHDO_SPELL_DURATION_MODE_ALIVE"];
	VUHDO_ATLAS_TEXTURES = _G["VUHDO_ATLAS_TEXTURES"];
	VUHDO_AURA_IDENTITY_GATE_HELPFUL = _G["VUHDO_AURA_IDENTITY_GATE_HELPFUL"];
	VUHDO_AURA_IDENTITY_GATE_HARMFUL = _G["VUHDO_AURA_IDENTITY_GATE_HARMFUL"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_MAX_PANELS = _G["VUHDO_MAX_PANELS"];

	VUHDO_PixelUtil = _G["VUHDO_PixelUtil"];
	VUHDO_LibSharedMedia = _G["VUHDO_LibSharedMedia"];

	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_setStatusBarOrientation = _G["VUHDO_setStatusBarOrientation"];
	VUHDO_setLlcStatusBarTexture = _G["VUHDO_setLlcStatusBarTexture"];
	VUHDO_copyStatusBarFillTexture = _G["VUHDO_copyStatusBarFillTexture"];
	VUHDO_getClassColor = _G["VUHDO_getClassColor"];
	VUHDO_backColorWithFallback = _G["VUHDO_backColorWithFallback"];
	VUHDO_customizeIconText = _G["VUHDO_customizeIconText"];
	VUHDO_resolveAuraTriState = _G["VUHDO_resolveAuraTriState"];
	VUHDO_isAuraDataRestricted = _G["VUHDO_isAuraDataRestricted"];
	VUHDO_isAuraModeContainers = _G["VUHDO_isAuraModeContainers"];
	VUHDO_resolveGroupTimerSettings = _G["VUHDO_resolveGroupTimerSettings"];
	VUHDO_startAuraButtonGlow = _G["VUHDO_startAuraButtonGlow"];
	VUHDO_getDispelTypeColorMap = _G["VUHDO_getDispelTypeColorMap"];
	VUHDO_getDispelTypeColorMapOpaque = _G["VUHDO_getDispelTypeColorMapOpaque"];
	VUHDO_getDispelTypeBorderCurve = _G["VUHDO_getDispelTypeBorderCurve"];
	VUHDO_applyAuraGroupBarGlowFromAuraButton = _G["VUHDO_applyAuraGroupBarGlowFromAuraButton"];
	VUHDO_getAuraAnchorHost = _G["VUHDO_getAuraAnchorHost"];
	VUHDO_unitPhaseReason = _G["VUHDO_unitPhaseReason"];
	VUHDO_isSpecialUnit = _G["VUHDO_isSpecialUnit"];
	VUHDO_stopOverlayThreatMarkFlashForSlotRecord = _G["VUHDO_stopOverlayThreatMarkFlashForSlotRecord"];
	VUHDO_precomputeStaticBouquetSlotsForButton = _G["VUHDO_precomputeStaticBouquetSlotsForButton"];
	VUHDO_updateStaticBouquetSlotsForButton = _G["VUHDO_updateStaticBouquetSlotsForButton"];
	VUHDO_hideStaticBouquetSlotsForButton = _G["VUHDO_hideStaticBouquetSlotsForButton"];
	VUHDO_deferVolatilePassForButton = _G["VUHDO_deferVolatilePassForButton"];
	VUHDO_fixFrameLevels = _G["VUHDO_fixFrameLevels"];
	VUHDO_deferInitAuraContainersForButton = _G["VUHDO_deferInitAuraContainersForButton"];
	VUHDO_rebuildAuraAnchorsForAllButtons = _G["VUHDO_rebuildAuraAnchorsForAllButtons"];

	sAuraOpaqueBorderOptions["backingCurveFn"] = _G["VUHDO_getDispelTypeBackgroundBackingCurve"];
	sAuraOpaqueBorderOptions["fillCurveFn"] = _G["VUHDO_getDispelTypeBackgroundFillCurve"];

	if not sAuraTimerColorCurveFull then
		sAuraTimerColorCurveFull = CreateColorCurve();

		sAuraTimerColorCurveFull:SetType(Enum.LuaCurveType.Step);
		sAuraTimerColorCurveFull:AddPoint(0, CreateColor(1, 1, 1, 1));
		sAuraTimerColorCurveFull:AddPoint(0.1, CreateColor(1, 0.2, 0.2, 1));
		sAuraTimerColorCurveFull:AddPoint(4.9, CreateColor(1, 1, 1, 1));
	end

	VUHDO_auraContainerOverlaysInitLocalOverrides();

	return;

end



--
do
	--
	local tTextConfig;
	local tTextParent;
	local tTextSize;
	function VUHDO_applyAuraButtonText(aButtonSetup, aAuraButton, aTextRegion, aFieldName)

		tTextConfig = aButtonSetup["textConfig"];

		if tTextConfig and tTextConfig[aFieldName] then
			if aButtonSetup["durationBar"] and aAuraButton["IconFrame"] and aButtonSetup["iconTextSize"] then
				tTextParent = aAuraButton["IconFrame"];
				tTextSize = aButtonSetup["iconTextSize"];
			else
				tTextParent = aAuraButton;
				tTextSize = aButtonSetup["textSize"] or 20;
			end

			VUHDO_customizeIconText(tTextParent, tTextSize, aTextRegion, tTextConfig[aFieldName]);

			aTextRegion:SetDrawLayer("OVERLAY", 3);
		end

		return;

	end



	--
	local tIconSize;
	local tBarWidth;
	local tBarHeight;
	local tBarVertical;
	local tBarTurnAxis;
	local tIconFrame;
	local tDurationBar;
	local tIconTexture;
	local tIconColorOverlay;
	local tDurationCooldown;
	local tLayoutSpec;
	local tDurationBarWidth;
	function VUHDO_layoutBarAuraButtonFrames(aButtonSetup, aAuraButton)

		if not aButtonSetup["durationBar"] or not aAuraButton["IconFrame"] then
			return true;
		end

		tIconSize = aButtonSetup["iconTextSize"];
		tBarWidth = aButtonSetup["barSegmentWidth"];
		tBarHeight = aButtonSetup["barSegmentHeight"];
		tBarVertical = aButtonSetup["barVertical"];
		tBarTurnAxis = aButtonSetup["barTurnAxis"];
		tIconFrame = aAuraButton["IconFrame"];
		tDurationBar = aAuraButton["DurationBar"];
		tIconTexture = aAuraButton["IconTexture"];
		tIconColorOverlay = aAuraButton["IconColorOverlay"];
		tDurationCooldown = aAuraButton["DurationCooldown"];

		if (aButtonSetup["iconType"] or 1) == 5 or not tIconSize or tIconSize <= 0 then
			tIconFrame:Hide();

			if tDurationCooldown then
				tDurationCooldown:Hide();
			end

			if tDurationBar then
				tDurationBar:ClearAllPoints();
				tDurationBar:SetAllPoints(aAuraButton);
			end

			if tIconTexture then
				tIconTexture:ClearAllPoints();
				tIconTexture:SetAllPoints(aAuraButton);
			end

			if tIconColorOverlay then
				tIconColorOverlay:ClearAllPoints();
				tIconColorOverlay:SetAllPoints(aAuraButton);
			end

			return true;
		end

		tIconFrame:ClearAllPoints();
		tIconFrame:Show();

		tLayoutSpec = sAuraBarIconLayouts[(tBarVertical and 2 or 0) + (tBarTurnAxis and 1 or 0)];

		VUHDO_PixelUtil.SetPoint(tIconFrame, tLayoutSpec["iconPoint"], aAuraButton, tLayoutSpec["iconPoint"], 0, 0);
		VUHDO_PixelUtil.SetSize(tIconFrame, tIconSize, tIconSize);

		if tDurationBar then
			tDurationBarWidth = tLayoutSpec["useBarWidth"] and tBarWidth or tIconSize;

			tDurationBar:ClearAllPoints();

			VUHDO_PixelUtil.SetPoint(tDurationBar, tLayoutSpec["barPoint"], tIconFrame, tLayoutSpec["barRelPoint"], 0, 0);
			VUHDO_PixelUtil.SetSize(tDurationBar, tDurationBarWidth, tBarHeight);
		end

		if tIconTexture then
			tIconTexture:ClearAllPoints();
			tIconTexture:SetAllPoints(tIconFrame);
		end

		if tIconColorOverlay then
			tIconColorOverlay:ClearAllPoints();
			tIconColorOverlay:SetAllPoints(tIconFrame);
		end

		if tDurationCooldown then
			tDurationCooldown:ClearAllPoints();
			tDurationCooldown:SetAllPoints(tIconFrame);
			tDurationCooldown:Show();
		end

		if (aButtonSetup["iconType"] or 1) == 4 and tDurationBar then
			tDurationBar:ClearAllPoints();
			tDurationBar:SetAllPoints(aAuraButton);
		end

		if aButtonSetup["dispelBorder"] then
			VUHDO_bindAuraButtonDispelBorder(aAuraButton, aButtonSetup);
		elseif not aButtonSetup["dispelOverlayChrome"] then
			VUHDO_unbindAuraButtonDispelBorder(aAuraButton);
		end

		return true;

	end
end



do
	--
	local tSlot;
	function VUHDO_applyAuraButtonSublevelSlot(aTexture, aButtonSetup, anIndex, aFallbackLayer, aFallbackSublevel)

		if not aTexture then
			return;
		end

		tSlot = aButtonSetup["sublevelSlots"] and aButtonSetup["sublevelSlots"][anIndex];

		if tSlot then
			aTexture:SetDrawLayer(tSlot["layer"], tSlot["sublevel"]);
		else
			aTexture:SetDrawLayer(aFallbackLayer, aFallbackSublevel);
		end

		return;

	end
end



--
local tFillMaskTexture;
local function VUHDO_anchorAuraButtonFillMask(aFillMask, aButtonSetup)

	aFillMask:ClearAllPoints();

	if "cover" == aButtonSetup["shadowValueMode"] then
		aFillMask:SetAllPoints(aButtonSetup["targetBar"]);
	else
		tFillMaskTexture = aButtonSetup["targetBar"]:GetStatusBarTexture();

		VUHDO_PixelUtil.SetPoint(aFillMask, "TOPLEFT", tFillMaskTexture, "TOPLEFT", aButtonSetup["fillMaskTopLeftX"] or 0, aButtonSetup["fillMaskTopLeftY"] or 0);
		VUHDO_PixelUtil.SetPoint(aFillMask, "BOTTOMRIGHT", tFillMaskTexture, "BOTTOMRIGHT", aButtonSetup["fillMaskBottomRightX"] or 0, aButtonSetup["fillMaskBottomRightY"] or 0);
	end

	return;

end



do
	--
	local tOverlayBarTextureFile;
	local function VUHDO_applyOverlayBarTextureToFill(aFillTexture, aBarTextureName)

		tOverlayBarTextureFile = VUHDO_LibSharedMedia:Fetch('statusbar', aBarTextureName);

		if tOverlayBarTextureFile then
			aFillTexture:SetTexture(tOverlayBarTextureFile, "CLAMP", "CLAMP", "NEAREST");

			VUHDO_PixelUtil.ApplySettings(aFillTexture);
		end

		return;

	end



	--
	local tVolatileShadowBar;
	local tVolatileShadowBackground;
	local tVolatileShadowTexture;
	local tVolatileFillTexture;
	local tVolatileFillBackground;
	local tVolatileFillMask;
	local tVolatileOcclusionColor;
	local tVolatileStaticColor;
	local tVolatileStaticAlpha;
	function VUHDO_applyAuraButtonVolatileSetup(aButtonSetup, aAuraButton)

		if not aButtonSetup or not aAuraButton then
			return;
		end

		if aButtonSetup["border"] or aButtonSetup["dispelBorder"] then
			VUHDO_reapplyAuraButtonBorderEdges(aAuraButton, aButtonSetup);
		end

		if not aAuraButton["ShadowBar"] then
			return;
		end

		tVolatileShadowBar = aAuraButton["ShadowBar"];

		if aButtonSetup["shadowValueMode"] == "duration" then
			tVolatileShadowBackground = tVolatileShadowBar["ShadowBackground"];

			if aButtonSetup["barOrientation"] then
				VUHDO_setStatusBarOrientation(tVolatileShadowBar, aButtonSetup["barOrientation"]);
			end

			if aButtonSetup["barTexture"] and not tVolatileShadowBar["isDuration"] then
				VUHDO_setLlcStatusBarTexture(tVolatileShadowBar, aButtonSetup["barTexture"]);
			end

			if aButtonSetup["barInverted"] ~= nil then
				tVolatileShadowBar["isInverted"] = aButtonSetup["barInverted"];
			end

			if tVolatileShadowBackground and aButtonSetup["occlusionColor"] then
				tVolatileOcclusionColor = aButtonSetup["occlusionColor"];
				tVolatileShadowBackground:SetColorTexture(tVolatileOcclusionColor["R"] or 0, tVolatileOcclusionColor["G"] or 0, tVolatileOcclusionColor["B"] or 0, 1);

				VUHDO_applyAuraButtonSublevelSlot(tVolatileShadowBackground, aButtonSetup, 1, "ARTWORK", 1);

				tVolatileShadowBackground:Show();
			end

			tVolatileShadowTexture = tVolatileShadowBar:GetStatusBarTexture();

			if tVolatileShadowTexture then
				if aButtonSetup["dispelFill"] then
					tVolatileShadowTexture:SetVertexColor(1, 1, 1, 1);
				elseif aButtonSetup["staticColor"] then
					tVolatileStaticColor = aButtonSetup["staticColor"];
					tVolatileStaticAlpha = tVolatileStaticColor["O"] or 1;

					tVolatileShadowTexture:SetVertexColor(tVolatileStaticColor["R"] or 1, tVolatileStaticColor["G"] or 1, tVolatileStaticColor["B"] or 1, tVolatileStaticAlpha);
				end

				VUHDO_applyAuraButtonSublevelSlot(tVolatileShadowTexture, aButtonSetup, 2, "ARTWORK", 1);
			end
		else
			tVolatileFillTexture = aAuraButton["FillTexture"];

			if tVolatileFillTexture and aButtonSetup["targetBar"] then
				if not aButtonSetup["dispelFill"] then
					tVolatileFillMask = aAuraButton["VuhDoFillMask"];

					if tVolatileFillMask then
						VUHDO_anchorAuraButtonFillMask(tVolatileFillMask, aButtonSetup);
					end
				end

				if aButtonSetup["dispelFill"] then
					tVolatileFillBackground = aAuraButton["VuhDoFillBackground"];

					if tVolatileFillBackground then
						if aButtonSetup["dispelOpacity"] and "cover" ~= aButtonSetup["shadowValueMode"] then
							tVolatileFillBackground:Hide();
						else
							VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, aButtonSetup, 1, "ARTWORK", 1);
							tVolatileFillBackground:Show();
						end
					end

					VUHDO_copyStatusBarFillTexture(tVolatileFillTexture, aButtonSetup["targetBar"]);

					if aButtonSetup["barTexture"] then
						VUHDO_applyOverlayBarTextureToFill(tVolatileFillTexture, aButtonSetup["barTexture"]);
					end

					tVolatileFillTexture:SetVertexColor(1, 1, 1, 1);

					VUHDO_applyAuraButtonSublevelSlot(tVolatileFillTexture, aButtonSetup, 2, "ARTWORK", 1);
				else
					tVolatileFillBackground = aAuraButton["VuhDoFillBackground"];

					if tVolatileFillBackground then
						if aButtonSetup["staticColor"] then
							tVolatileStaticColor = aButtonSetup["staticColor"];
							tVolatileStaticAlpha = tVolatileStaticColor["O"] or 1;

							if tVolatileStaticAlpha < 1 then
								tVolatileFillBackground:Hide();
							else
								tVolatileFillBackground:SetColorTexture(tVolatileStaticColor["R"] or 1, tVolatileStaticColor["G"] or 1, tVolatileStaticColor["B"] or 1, 1);

								VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, aButtonSetup, 1, "ARTWORK", 1);

								tVolatileFillBackground:Show();
							end
						elseif aButtonSetup["occlusionColor"] then
							tVolatileOcclusionColor = aButtonSetup["occlusionColor"];
							tVolatileFillBackground:SetColorTexture(tVolatileOcclusionColor["R"] or 0, tVolatileOcclusionColor["G"] or 0, tVolatileOcclusionColor["B"] or 0, 1);

							VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, aButtonSetup, 1, "ARTWORK", 1);

							tVolatileFillBackground:Show();
						else
							tVolatileFillBackground:SetColorTexture(0, 0, 0, 1);

							VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, aButtonSetup, 1, "ARTWORK", 1);

							tVolatileFillBackground:Show();
						end
					end

					VUHDO_copyStatusBarFillTexture(tVolatileFillTexture, aButtonSetup["targetBar"]);

					if aButtonSetup["barTexture"] then
						VUHDO_applyOverlayBarTextureToFill(tVolatileFillTexture, aButtonSetup["barTexture"]);
					end

					if aButtonSetup["staticColor"] then
						tVolatileStaticColor = aButtonSetup["staticColor"];
						tVolatileStaticAlpha = tVolatileStaticColor["O"] or 1;

						tVolatileFillTexture:SetVertexColor(tVolatileStaticColor["R"] or 1, tVolatileStaticColor["G"] or 1, tVolatileStaticColor["B"] or 1, tVolatileStaticAlpha);
					end

					VUHDO_applyAuraButtonSublevelSlot(tVolatileFillTexture, aButtonSetup, 2, "ARTWORK", 1);
				end
			end
		end

		if aButtonSetup["targetFrameLevel"] then
			if aButtonSetup["shadowValueMode"] == "duration" then
				VUHDO_PixelUtil.SetFrameLevel(aAuraButton, aButtonSetup["targetFrameLevel"] + 1);
				VUHDO_PixelUtil.SetFrameLevel(tVolatileShadowBar, aButtonSetup["targetFrameLevel"] + 1);
			else
				VUHDO_PixelUtil.SetFrameLevel(aAuraButton, aButtonSetup["targetFrameLevel"]);
			end
		end

		return;

	end
end



do
	--
	local tAnchorFrame;
	local tBorderEdgeSize;
	local tBorderRepeatX;
	local tBorderRepeatY;
	local tBorderPiece;
	local tBorderCoordValue;
	local function VUHDO_resolveAuraButtonBorderCoordValue(aCoordKey, aPieceSetup, aRepeatX, aRepeatY)

		tBorderCoordValue = aPieceSetup[aCoordKey];

		if tBorderCoordValue == "repeatX" then
			return aRepeatX;
		end

		if tBorderCoordValue == "repeatY" then
			return aRepeatY;
		end

		return tBorderCoordValue;

	end



	--
	local function VUHDO_applyAuraButtonBorderTexCoord(aTexture, aPieceSetup, aRepeatX, aRepeatY)

		aTexture:SetTexCoord(
			VUHDO_resolveAuraButtonBorderCoordValue("ULx", aPieceSetup, aRepeatX, aRepeatY),
			VUHDO_resolveAuraButtonBorderCoordValue("ULy", aPieceSetup, aRepeatX, aRepeatY),
			VUHDO_resolveAuraButtonBorderCoordValue("LLx", aPieceSetup, aRepeatX, aRepeatY),
			VUHDO_resolveAuraButtonBorderCoordValue("LLy", aPieceSetup, aRepeatX, aRepeatY),
			VUHDO_resolveAuraButtonBorderCoordValue("URx", aPieceSetup, aRepeatX, aRepeatY),
			VUHDO_resolveAuraButtonBorderCoordValue("URy", aPieceSetup, aRepeatX, aRepeatY),
			VUHDO_resolveAuraButtonBorderCoordValue("LRx", aPieceSetup, aRepeatX, aRepeatY),
			VUHDO_resolveAuraButtonBorderCoordValue("LRy", aPieceSetup, aRepeatX, aRepeatY)
		);

		return;

	end



	--
	local function VUHDO_setAuraButtonBorderVertexColor(aAuraButton, aR, aG, aB, aO)

		for tCnt = 1, #sBorderPieceKeys do
			tBorderPiece = aAuraButton[sBorderPieceKeys[tCnt]];

			if tBorderPiece then
				tBorderPiece:SetVertexColor(aR, aG, aB, aO);
			end
		end

		return;

	end



	--
	local function VUHDO_addAuraButtonBorderDispelTextures(aAuraButton, aBorderOptions)

		for tCnt = 1, #sBorderPieceKeys do
			tBorderPiece = aAuraButton[sBorderPieceKeys[tCnt]];

			if tBorderPiece then
				aAuraButton:AddDispelTypeTexture(tBorderPiece, aBorderOptions);
			end
		end

		return;

	end



	--
	local function VUHDO_anchorAuraButtonBorderEdges(aAuraButton, aButtonSetup, aAnchorFrame)

		for tCnt = 1, #sBorderPieceKeys do
			if not aAuraButton[sBorderPieceKeys[tCnt]] then
				return false;
			end
		end

		tAnchorFrame = aAnchorFrame or aAuraButton;

		sBorderWidth = (aButtonSetup and aButtonSetup["borderWidth"]) or 1;
		sBorderFile = (aButtonSetup and aButtonSetup["borderFile"]) or "Interface\\AddOns\\VuhDo\\Images\\white_square_16_16";
		tBorderEdgeSize = aButtonSetup["borderEdgeSize"] or VUHDO_PixelUtil.RoundToPixel(sBorderWidth, 1);
		tBorderRepeatX = aButtonSetup["borderRepeatX"] or 1;
		tBorderRepeatY = aButtonSetup["borderRepeatY"] or 1;

		tBorderPiece = aAuraButton["BorderCornerTopLeft"];
		tBorderPiece:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "TOPLEFT", tAnchorFrame, "TOPLEFT", 0, 0);
		VUHDO_PixelUtil.SetSize(tBorderPiece, tBorderEdgeSize, tBorderEdgeSize);
		tBorderPiece:SetTexture(sBorderFile, true, true);
		VUHDO_applyAuraButtonBorderTexCoord(tBorderPiece, sBorderPieceCoords["BorderCornerTopLeft"], tBorderRepeatX, tBorderRepeatY);

		tBorderPiece = aAuraButton["BorderCornerTopRight"];
		tBorderPiece:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "TOPRIGHT", tAnchorFrame, "TOPRIGHT", 0, 0);
		VUHDO_PixelUtil.SetSize(tBorderPiece, tBorderEdgeSize, tBorderEdgeSize);
		tBorderPiece:SetTexture(sBorderFile, true, true);
		VUHDO_applyAuraButtonBorderTexCoord(tBorderPiece, sBorderPieceCoords["BorderCornerTopRight"], tBorderRepeatX, tBorderRepeatY);

		tBorderPiece = aAuraButton["BorderCornerBottomLeft"];
		tBorderPiece:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "BOTTOMLEFT", tAnchorFrame, "BOTTOMLEFT", 0, 0);
		VUHDO_PixelUtil.SetSize(tBorderPiece, tBorderEdgeSize, tBorderEdgeSize);
		tBorderPiece:SetTexture(sBorderFile, true, true);
		VUHDO_applyAuraButtonBorderTexCoord(tBorderPiece, sBorderPieceCoords["BorderCornerBottomLeft"], tBorderRepeatX, tBorderRepeatY);

		tBorderPiece = aAuraButton["BorderCornerBottomRight"];
		tBorderPiece:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "BOTTOMRIGHT", tAnchorFrame, "BOTTOMRIGHT", 0, 0);
		VUHDO_PixelUtil.SetSize(tBorderPiece, tBorderEdgeSize, tBorderEdgeSize);
		tBorderPiece:SetTexture(sBorderFile, true, true);
		VUHDO_applyAuraButtonBorderTexCoord(tBorderPiece, sBorderPieceCoords["BorderCornerBottomRight"], tBorderRepeatX, tBorderRepeatY);

		tBorderPiece = aAuraButton["BorderEdgeTop"];
		tBorderPiece:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "TOPLEFT", tAnchorFrame, "TOPLEFT", tBorderEdgeSize, 0);
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "TOPRIGHT", tAnchorFrame, "TOPRIGHT", -tBorderEdgeSize, 0);
		VUHDO_PixelUtil.SetHeight(tBorderPiece, tBorderEdgeSize, 1);
		tBorderPiece:SetTexture(sBorderFile, true, true);
		VUHDO_applyAuraButtonBorderTexCoord(tBorderPiece, sBorderPieceCoords["BorderEdgeTop"], tBorderRepeatX, tBorderRepeatY);

		tBorderPiece = aAuraButton["BorderEdgeBottom"];
		tBorderPiece:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "BOTTOMLEFT", tAnchorFrame, "BOTTOMLEFT", tBorderEdgeSize, 0);
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "BOTTOMRIGHT", tAnchorFrame, "BOTTOMRIGHT", -tBorderEdgeSize, 0);
		VUHDO_PixelUtil.SetHeight(tBorderPiece, tBorderEdgeSize, 1);
		tBorderPiece:SetTexture(sBorderFile, true, true);
		VUHDO_applyAuraButtonBorderTexCoord(tBorderPiece, sBorderPieceCoords["BorderEdgeBottom"], tBorderRepeatX, tBorderRepeatY);

		tBorderPiece = aAuraButton["BorderEdgeLeft"];
		tBorderPiece:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "TOPLEFT", tAnchorFrame, "TOPLEFT", 0, -tBorderEdgeSize);
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "BOTTOMLEFT", tAnchorFrame, "BOTTOMLEFT", 0, tBorderEdgeSize);
		VUHDO_PixelUtil.SetWidth(tBorderPiece, tBorderEdgeSize, 1);
		tBorderPiece:SetTexture(sBorderFile, true, true);
		VUHDO_applyAuraButtonBorderTexCoord(tBorderPiece, sBorderPieceCoords["BorderEdgeLeft"], tBorderRepeatX, tBorderRepeatY);

		tBorderPiece = aAuraButton["BorderEdgeRight"];
		tBorderPiece:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "TOPRIGHT", tAnchorFrame, "TOPRIGHT", 0, -tBorderEdgeSize);
		VUHDO_PixelUtil.SetPoint(tBorderPiece, "BOTTOMRIGHT", tAnchorFrame, "BOTTOMRIGHT", 0, tBorderEdgeSize);
		VUHDO_PixelUtil.SetWidth(tBorderPiece, tBorderEdgeSize, 1);
		tBorderPiece:SetTexture(sBorderFile, true, true);
		VUHDO_applyAuraButtonBorderTexCoord(tBorderPiece, sBorderPieceCoords["BorderEdgeRight"], tBorderRepeatX, tBorderRepeatY);

		for tCnt = 1, #sBorderPieceKeys do
			tBorderPiece = aAuraButton[sBorderPieceKeys[tCnt]];
			tBorderPiece:SetDrawLayer("OVERLAY", 7);
			tBorderPiece:Show();
		end

		return true;

	end



	--
	function VUHDO_reapplyAuraButtonBorderEdges(aAuraButton, aButtonSetup)

		if not aButtonSetup or not aAuraButton then
			return;
		end

		if not aButtonSetup["border"] and not aButtonSetup["dispelBorder"] then
			return;
		end

		tAnchorFrame = nil;

		if aButtonSetup["dispelBorder"] and aAuraButton["IconTexture"] then
			tAnchorFrame = aAuraButton["IconFrame"];
		end

		if not VUHDO_anchorAuraButtonBorderEdges(aAuraButton, aButtonSetup, tAnchorFrame) then
			return;
		end

		if aButtonSetup["border"] and not aButtonSetup["dispelBorder"] then
			sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO = VUHDO_backColorWithFallback(aButtonSetup["staticColor"]);

			VUHDO_setAuraButtonBorderVertexColor(aAuraButton, sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);
		end

		return;

	end



	--
	function VUHDO_applyAuraButtonDispelBorder(aAuraButton, aButtonSetup)

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		if not VUHDO_anchorAuraButtonBorderEdges(aAuraButton, aButtonSetup) then
			return;
		end

		sAuraBorderOptions["customDispelColorCurve"] = nil;
		sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(aButtonSetup["dispelBright"], aButtonSetup["dispelOpacity"]);

		VUHDO_addAuraButtonBorderDispelTextures(aAuraButton, sAuraBorderOptions);

		if aButtonSetup["targetFrameLevel"] then
			VUHDO_PixelUtil.SetFrameLevel(aAuraButton, aButtonSetup["targetFrameLevel"]);
		end

		return;

	end



	--
	local tDispelIconTexture;
	function VUHDO_applyAuraButtonDispelIcon(aAuraButton, aButtonSetup)

		tDispelIconTexture = aAuraButton["IconColorOverlay"] or aAuraButton["FillTexture"];

		if not tDispelIconTexture then
			return;
		end

		sAuraBorderOptions["customDispelColorCurve"] = nil;

		if aButtonSetup["dispelOpacity"] then
			sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(aButtonSetup["dispelBright"], aButtonSetup["dispelOpacity"]);
		else
			sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMapOpaque(aButtonSetup["dispelBright"]);
		end

		aAuraButton:AddDispelTypeTexture(tDispelIconTexture, sAuraBorderOptions);

		return;

	end



	--
	function VUHDO_applyAuraButtonStaticBorder(aAuraButton, aButtonSetup)

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		if not aButtonSetup["dispelFill"] and not aButtonSetup["auraGroupBarGlow"] then
			aAuraButton:ClearDispelTypeTextures();
		end

		if not VUHDO_anchorAuraButtonBorderEdges(aAuraButton, aButtonSetup) then
			return;
		end

		sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO = VUHDO_backColorWithFallback(aButtonSetup["staticColor"]);

		VUHDO_setAuraButtonBorderVertexColor(aAuraButton, sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);

		if aButtonSetup["targetFrameLevel"] then
			VUHDO_PixelUtil.SetFrameLevel(aAuraButton, aButtonSetup["targetFrameLevel"]);
		end

		return;

	end



	--
	function VUHDO_hideAuraButtonBorder(aAuraButton)

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		for tCnt = 1, #sBorderPieceKeys do
			tBorderPiece = aAuraButton[sBorderPieceKeys[tCnt]];

			if tBorderPiece then
				tBorderPiece:Hide();
			end
		end

		return;

	end



	--
	local tIconTexture;
	local tInsetParent;
	function VUHDO_bindAuraButtonDispelBorder(aAuraButton, aButtonSetup)

		if not aAuraButton then
			return;
		end

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		if not VUHDO_anchorAuraButtonBorderEdges(aAuraButton, aButtonSetup, aAuraButton["IconFrame"]) then
			return;
		end

		sAuraIconDispelBorderOptionsBind["customDispelColorMap"] = nil;
		sAuraIconDispelBorderOptionsBind["customDispelColorCurve"] = VUHDO_getDispelTypeBorderCurve();

		aAuraButton:ClearDispelTypeTextures();

		VUHDO_addAuraButtonBorderDispelTextures(aAuraButton, sAuraIconDispelBorderOptionsBind);

		return;

	end



	--
	function VUHDO_unbindAuraButtonDispelBorder(aAuraButton)

		if not aAuraButton then
			return;
		end

		aAuraButton:ClearDispelTypeTextures();
		aAuraButton:ClearDispelTypeText();

		VUHDO_hideAuraButtonBorder(aAuraButton);

		tIconTexture = aAuraButton["IconTexture"];
		tInsetParent = aAuraButton["IconFrame"] or aAuraButton;

		if tIconTexture then
			tIconTexture:ClearAllPoints();
			tIconTexture:SetAllPoints(tInsetParent);
			tIconTexture:SetTexCoord(0, 1, 0, 1);
		end

		return;

	end



	--
	local tGradientTexture;
	function VUHDO_applyDispelOverlayGradientTexture(aAuraButton, aButtonSetup, aBorderOptions)

		tGradientTexture = aAuraButton["GradientTexture"];

		if not tGradientTexture then
			return;
		end

		SetTextureWithAddressModeOptions(tGradientTexture, "_RaidFrame-Dispel-Highlight-Horizontal", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeWrap, TextureKitConstants.AddressModeClamp);

		tGradientTexture:SetTexCoord(0, 1, 0, 1);

		aBorderOptions["customDispelColorCurve"] = nil;
		aBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(aButtonSetup["dispelBright"]);

		aAuraButton:AddDispelTypeTexture(tGradientTexture, aBorderOptions);

		return;

	end
end



do
	--
	local tMainTexture;
	local tStaticColor;
	local tBarColor;
	local tIconColor;
	local tShadowBar;
	local tShadowTexture;
	local tFillTexture;
	local tFillMask;
	local tFillBackground;
	local tTexCoords;
	local tDispelIconTexture;
	local tTextOverlayFrame;
	local tBarNoIconTexts;
	function VUHDO_applyAuraButtonSetup(aButtonSetup, aAuraButton)

		if not aButtonSetup then
			return;
		end

		tTextOverlayFrame = aAuraButton["TextOverlayFrame"];

		if tTextOverlayFrame then
			aAuraButton["SymbolText"] = tTextOverlayFrame["SymbolText"];
			aAuraButton["TimerText"] = tTextOverlayFrame["TimerText"];
			aAuraButton["CountText"] = tTextOverlayFrame["CountText"];
		end

		tBarNoIconTexts = aButtonSetup["durationBar"] and (aButtonSetup["iconType"] or 1) == 5;

		tMainTexture = aAuraButton["IconTexture"] or aAuraButton["FillTexture"];

		if aButtonSetup["hideIcon"] then
			if tMainTexture then
				tMainTexture:Hide();
			end
		elseif aButtonSetup["staticIcon"] then
			if tMainTexture then
				if VUHDO_ATLAS_TEXTURES[aButtonSetup["staticIcon"]] then
					tMainTexture:SetAtlas(aButtonSetup["staticIcon"]);
				else
					tMainTexture:SetTexture(aButtonSetup["staticIcon"]);
				end

				if aButtonSetup["iconTexCoords"] then
					tTexCoords = aButtonSetup["iconTexCoords"];

					tMainTexture:SetTexCoord(tTexCoords[1] or 0, tTexCoords[2] or 1, tTexCoords[3] or 0, tTexCoords[4] or 1);
				elseif not VUHDO_ATLAS_TEXTURES[aButtonSetup["staticIcon"]] then
					tMainTexture:SetTexCoord(0, 1, 0, 1);
				end

				tMainTexture:Show();

				tMainTexture:SetVertexColor(1, 1, 1, 1);

				VUHDO_applyAuraButtonSublevelSlot(tMainTexture, aButtonSetup, 1, "ARTWORK", 1);
			end
		elseif aAuraButton["IconTexture"] then
			aAuraButton:SetIcon(aAuraButton["IconTexture"]);
		end

		if aButtonSetup["staticColor"] and tMainTexture and not aButtonSetup["shadowBar"] and not aButtonSetup["border"] then
			tStaticColor = aButtonSetup["staticColor"];

			if aButtonSetup["staticIcon"] then
				tMainTexture:SetVertexColor(tStaticColor["R"] or 1, tStaticColor["G"] or 1, tStaticColor["B"] or 1, tStaticColor["O"] or 1);
			else
				tMainTexture:SetColorTexture(tStaticColor["R"] or 1, tStaticColor["G"] or 1, tStaticColor["B"] or 1, tStaticColor["O"] or 1);
			end

			tMainTexture:Show();
		end

		if aAuraButton["IconTexture"] then
			if aButtonSetup["iconColor"] then
				tIconColor = aButtonSetup["iconColor"];

				aAuraButton["IconColorOverlay"]:SetColorTexture(tIconColor["R"] or 1, tIconColor["G"] or 1, tIconColor["B"] or 1, 1);
				aAuraButton["IconColorOverlay"]:Show();
			else
				aAuraButton["IconColorOverlay"]:Hide();
			end
		end

		if aButtonSetup["shadowBar"] and aAuraButton["ShadowBar"] then
			tShadowBar = aAuraButton["ShadowBar"];

			if aButtonSetup["shadowValueMode"] == "duration" then
				if aAuraButton["FillTexture"] then
					aAuraButton["FillTexture"]:Hide();
				end

				VUHDO_applyAuraButtonVolatileSetup(aButtonSetup, aAuraButton);

				if aButtonSetup["dispelFill"] then
					tShadowTexture = tShadowBar:GetStatusBarTexture();

					if tShadowTexture then
						tShadowTexture:SetVertexColor(1, 1, 1, 1);

						sAuraOpaqueBorderOptions["customDispelColorCurve"] = nil;

						if aButtonSetup["dispelOpacity"] then
							sAuraOpaqueBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(aButtonSetup["dispelBright"], aButtonSetup["dispelOpacity"]);
						else
							sAuraOpaqueBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMapOpaque(aButtonSetup["dispelBright"]);
						end

						aAuraButton:ClearDispelTypeTextures();

						aAuraButton:AddDispelTypeTexture(tShadowTexture, sAuraOpaqueBorderOptions);
					end
				end

				if aButtonSetup["barInverted"] then
					sAuraDurationBarOptions["direction"] = Enum.StatusBarTimerDirection.ElapsedTime;
				else
					sAuraDurationBarOptions["direction"] = Enum.StatusBarTimerDirection.RemainingTime;
				end

				VUHDO_layoutOverlayDurationShadowBar(aAuraButton);

				aAuraButton:SetDurationBar(tShadowBar, sAuraDurationBarOptions);

				tShadowBar["isDuration"] = true;

				tShadowBar:Show();
			else
				tShadowBar["isDuration"] = nil;

				tShadowBar:Hide();

				tFillTexture = aAuraButton["FillTexture"];

				if tFillTexture and aButtonSetup["targetBar"] then
					tFillTexture:ClearAllPoints();
					tFillTexture:SetAllPoints(aAuraButton);

					tFillMask = aAuraButton["VuhDoFillMask"];

					if not tFillMask then
						tFillMask = aAuraButton:CreateMaskTexture();
						aAuraButton["VuhDoFillMask"] = tFillMask;

						tFillTexture:AddMaskTexture(tFillMask);
						tFillMask:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST");

						VUHDO_PixelUtil.ApplySettings(tFillMask);
					end

					VUHDO_anchorAuraButtonFillMask(tFillMask, aButtonSetup);

					if aButtonSetup["dispelFill"] then
						tFillBackground = aAuraButton["VuhDoFillBackground"];

						if not tFillBackground then
							tFillBackground = aAuraButton:CreateTexture(nil, "ARTWORK");
							aAuraButton["VuhDoFillBackground"] = tFillBackground;

							tFillBackground:AddMaskTexture(tFillMask);
						end

						tFillBackground:ClearAllPoints();
						tFillBackground:SetAllPoints(aAuraButton);

						tFillBackground:SetTexture("Interface\\Buttons\\WHITE8X8");

						VUHDO_PixelUtil.ApplySettings(tFillBackground);
					elseif aButtonSetup["staticColor"] then
						tFillBackground = aAuraButton["VuhDoFillBackground"];

						if not tFillBackground then
							tFillBackground = aAuraButton:CreateTexture(nil, "ARTWORK");
							aAuraButton["VuhDoFillBackground"] = tFillBackground;

							tFillBackground:AddMaskTexture(tFillMask);
						end

						tFillBackground:ClearAllPoints();
						tFillBackground:SetAllPoints(aAuraButton);
					end

					VUHDO_applyAuraButtonVolatileSetup(aButtonSetup, aAuraButton);

					if aButtonSetup["dispelFill"] then
						tFillBackground = aAuraButton["VuhDoFillBackground"];

						aAuraButton:ClearDispelTypeTextures();

						if "cover" == aButtonSetup["shadowValueMode"] then
							sAuraOpaqueBorderOptions["customDispelColorMap"] = nil;
							sAuraOpaqueBorderOptions["customDispelColorCurve"] = sAuraOpaqueBorderOptions["backingCurveFn"](aButtonSetup["dispelBright"], aButtonSetup["dispelOpacity"]);

							if tFillBackground then
								aAuraButton:AddDispelTypeTexture(tFillBackground, sAuraOpaqueBorderOptions);
							end

							sAuraOpaqueBorderOptions["customDispelColorCurve"] = sAuraOpaqueBorderOptions["fillCurveFn"](aButtonSetup["dispelBright"], aButtonSetup["dispelOpacity"]);

							aAuraButton:AddDispelTypeTexture(tFillTexture, sAuraOpaqueBorderOptions);
						elseif aButtonSetup["dispelOpacity"] then
							sAuraBorderOptions["customDispelColorCurve"] = nil;
							sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(aButtonSetup["dispelBright"], aButtonSetup["dispelOpacity"]);

							aAuraButton:AddDispelTypeTexture(tFillTexture, sAuraBorderOptions);
						else
							sAuraOpaqueBorderOptions["customDispelColorCurve"] = nil;
							sAuraOpaqueBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMapOpaque(aButtonSetup["dispelBright"]);

							if tFillBackground then
								aAuraButton:AddDispelTypeTexture(tFillBackground, sAuraOpaqueBorderOptions);
							end

							aAuraButton:AddDispelTypeTexture(tFillTexture, sAuraOpaqueBorderOptions);
						end
					end

					tFillTexture:Show();
				end
			end
		end

		if not aButtonSetup["dispelOverlayChrome"] then
			if aButtonSetup["dispelIcon"] then
				if not aButtonSetup["dispelFill"] and not aButtonSetup["auraGroupBarGlow"] then
					aAuraButton:ClearDispelTypeTextures();
				end

				VUHDO_applyAuraButtonDispelIcon(aAuraButton, aButtonSetup);
			elseif aButtonSetup["dispelBorder"] then
				if aAuraButton["IconTexture"] then
					VUHDO_bindAuraButtonDispelBorder(aAuraButton, aButtonSetup);
				else
					if not aButtonSetup["dispelFill"] and not aButtonSetup["auraGroupBarGlow"] then
						aAuraButton:ClearDispelTypeTextures();
					end

					VUHDO_applyAuraButtonDispelBorder(aAuraButton, aButtonSetup);
				end
			elseif aButtonSetup["border"] then
				VUHDO_applyAuraButtonStaticBorder(aAuraButton, aButtonSetup);
			elseif aAuraButton["IconTexture"] then
				VUHDO_unbindAuraButtonDispelBorder(aAuraButton);
			elseif not aButtonSetup["dispelFill"] and not aButtonSetup["auraGroupBarGlow"] then
				aAuraButton:ClearDispelTypeTextures();

				VUHDO_hideAuraButtonBorder(aAuraButton);
			end
		end

		if aButtonSetup["dispelOverlayChrome"] then
			if not aButtonSetup["auraGroupBarGlow"] then
				aAuraButton:ClearDispelTypeTextures();
			end

			tFillTexture = aAuraButton["FillTexture"];

			if tFillTexture then
				tFillTexture:SetVertexColor(1, 1, 1, 1);
				tFillTexture:SetAlpha(0.2);
				tFillTexture:Show();
			end

			VUHDO_applyDispelOverlayGradientTexture(aAuraButton, aButtonSetup, sAuraBorderOptions);

			if aAuraButton["BorderTexture"] then
				sAuraBorderOptions["customDispelColorCurve"] = nil;
				sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(aButtonSetup["dispelBright"]);

				aAuraButton:AddDispelTypeTexture(aAuraButton["BorderTexture"], sAuraBorderOptions);
			end

			tDispelIconTexture = aAuraButton["DispelIconTexture"];

			if tDispelIconTexture then
				aAuraButton:AddDispelTypeTexture(tDispelIconTexture, sDispelOverlayIconOptions);
			end
		end

		if aButtonSetup["auraSymbol"] and aAuraButton["SymbolText"] then
			aAuraButton:SetDispelTypeText(aAuraButton["SymbolText"], sAuraSymbolOptions);
		end

		if aButtonSetup["durationBar"] and (aButtonSetup["iconType"] or 1) == 5 then
			aAuraButton:ClearDurationCooldown();

			if aAuraButton["DurationCooldown"] then
				aAuraButton["DurationCooldown"]:Hide();
			end
		elseif aButtonSetup["durationCooldown"] and aAuraButton["DurationCooldown"] then
			aAuraButton["DurationCooldown"]:SetHideCountdownNumbers(true);

			aAuraButton:SetDurationCooldown(aAuraButton["DurationCooldown"]);
		elseif not aButtonSetup["durationCooldown"] then
			aAuraButton:ClearDurationCooldown();
		end

		if aButtonSetup["durationBar"] and aAuraButton["DurationBar"] then
			if aButtonSetup["durationBarOrientation"] then
				VUHDO_setStatusBarOrientation(aAuraButton["DurationBar"], aButtonSetup["durationBarOrientation"]);
			end

			if aButtonSetup["barTexture"] then
				VUHDO_setLlcStatusBarTexture(aAuraButton["DurationBar"], aButtonSetup["barTexture"]);
			end

			if aButtonSetup["barColor"] then
				tBarColor = aButtonSetup["barColor"];

				aAuraButton["DurationBar"]:GetStatusBarTexture():SetVertexColor(tBarColor["R"] or 0.2, tBarColor["G"] or 0.6, tBarColor["B"] or 0.2, tBarColor["O"] or 1);
			end

			aAuraButton:SetDurationBar(aAuraButton["DurationBar"], aButtonSetup["durationBarOptions"] or sEmpty);

			if tTextOverlayFrame then
				tTextOverlayFrame:SetFrameLevel(aAuraButton["DurationBar"]:GetFrameLevel() + 1);
			end

			VUHDO_layoutBarAuraButtonFrames(aButtonSetup, aAuraButton);
		end

		if not tBarNoIconTexts and aButtonSetup["durationText"] and aAuraButton["TimerText"] then
			VUHDO_applyAuraButtonText(aButtonSetup, aAuraButton, aAuraButton["TimerText"], "TIMER_TEXT");

			aAuraButton:SetDurationText(aAuraButton["TimerText"], aButtonSetup["durationTextOptions"] or sEmpty);
		elseif tBarNoIconTexts or not aButtonSetup["durationText"] then
			aAuraButton:ClearDurationText();
		end

		if not tBarNoIconTexts and aButtonSetup["applicationCount"] and aAuraButton["CountText"] then
			VUHDO_applyAuraButtonText(aButtonSetup, aAuraButton, aAuraButton["CountText"], "COUNTER_TEXT");

			aAuraButton:SetApplicationCount(aAuraButton["CountText"], sEmpty);
		elseif tBarNoIconTexts or not aButtonSetup["applicationCount"] then
			aAuraButton:ClearApplicationCount();
		end

		if aButtonSetup["width"] and aButtonSetup["height"] then
			VUHDO_PixelUtil.SetSize(aAuraButton, aButtonSetup["width"], aButtonSetup["height"]);
		end

		aAuraButton:SetMouseClickEnabled(false);

		if aButtonSetup["disableMouse"] then
			aAuraButton:EnableMouse(false);
			aAuraButton:SetMouseClickEnabled(false);
			aAuraButton:SetMouseMotionEnabled(false);
		elseif aButtonSetup["mouseMotion"] == false then
			aAuraButton:SetMouseMotionEnabled(false);
		else
			aAuraButton:EnableMouse(true);
			aAuraButton:SetMouseMotionEnabled(true);
			aAuraButton:SetPropagateMouseMotion(true);
			aAuraButton:SetMouseClickEnabled(false);

			if not InCombatLockdown() then
				aAuraButton:SetPropagateMouseClicks(true);
			end
		end

		if aButtonSetup["glowIcon"] then
			VUHDO_startAuraButtonGlow(aAuraButton, aButtonSetup);
		else
			VUHDO_stopAuraButtonGlow(aAuraButton);
		end

		if aButtonSetup["auraGroupBarGlow"] then
			VUHDO_applyAuraGroupBarGlowFromAuraButton(aAuraButton, aButtonSetup);
		else
			VUHDO_stopAuraButtonAuraGroupBarGlow(aAuraButton);

			aAuraButton["vuhdoAuraGroupBarGlowActive"] = nil;
		end

		return;

	end
end



do
	--
	local function VUHDO_registerContainerClassColorBar(aContainer, aDurationBar)

		if not aContainer or not aDurationBar then
			return;
		end

		if not sContainerClassColorBars[aContainer] then
			sContainerClassColorBars[aContainer] = { };
		end

		for tCnt = 1, #sContainerClassColorBars[aContainer] do
			if sContainerClassColorBars[aContainer][tCnt] == aDurationBar then
				return;
			end
		end

		tinsert(sContainerClassColorBars[aContainer], aDurationBar);

		return;

	end



	--
	local tClassColorBars;
	local tClassColor;
	local tClassColorBar;
	function VUHDO_applyContainerClassColorBars(aContainer, aUnit)

		tClassColorBars = sContainerClassColorBars[aContainer];

		if not tClassColorBars or not aUnit or not VUHDO_RAID[aUnit] then
			return true;
		end

		tClassColor = VUHDO_getClassColor(VUHDO_RAID[aUnit]);

		if not tClassColor then
			return true;
		end

		for tCnt = 1, #tClassColorBars do
			tClassColorBar = tClassColorBars[tCnt];

			if tClassColorBar:CanBeAccessedInContext() then
				tClassColorBar:GetStatusBarTexture():SetVertexColor(tClassColor["R"], tClassColor["G"], tClassColor["B"], 1);
			else
				sPendingClassColors[aContainer] = aUnit;

				sHasPendingBuilds = true;

				return false;
			end
		end

		return true;

	end



	--
	local tButtonSetup;
	function VUHDO_buildAuraButtonInitializer(aTemplateRef, aContainer)

		return function(aAuraButton)

			tButtonSetup = aTemplateRef["template"]["buttonSetup"];

			VUHDO_applyAuraButtonSetup(tButtonSetup, aAuraButton);

			if "class" == tButtonSetup["barColorMode"] and aAuraButton["DurationBar"] then
				VUHDO_registerContainerClassColorBar(aContainer, aAuraButton["DurationBar"]);
			end

			return;

		end;

	end



	--
	local tSlotTemplate;
	local tSlotButtonSetup;
	local tSlotAnchor;
	local tSlotRelPoint;
	local tSlotAnchorFrame;
	local tShadowBar;
	function VUHDO_buildAuraSlotButtonInitializer(aTemplateRef, aContainer, anAnchorPoint)

		return function(aAuraButton)

			tSlotTemplate = aTemplateRef["template"];
			tSlotButtonSetup = tSlotTemplate["buttonSetup"];

			VUHDO_applyAuraButtonSetup(tSlotButtonSetup, aAuraButton);

			if "class" == tSlotButtonSetup["barColorMode"] and aAuraButton["DurationBar"] then
				VUHDO_registerContainerClassColorBar(aContainer, aAuraButton["DurationBar"]);
			end

			tSlotAnchorFrame = tSlotTemplate["anchorFrame"] or aContainer;
			tSlotAnchor = tSlotTemplate["anchor"] or anAnchorPoint;
			tSlotRelPoint = tSlotTemplate["relPoint"] or tSlotAnchor;

			aAuraButton:ClearAllPoints();

			if tSlotTemplate["anchorMode"] == "cover" then
				VUHDO_pixelSnapCoverFrame(aAuraButton, tSlotAnchorFrame);
			else
				VUHDO_PixelUtil.SetPoint(aAuraButton, tSlotAnchor, tSlotAnchorFrame, tSlotRelPoint, tSlotTemplate["x"] or 0, tSlotTemplate["y"] or 0);
				VUHDO_PixelUtil.SetSize(aAuraButton, tSlotTemplate["width"] or 20, tSlotTemplate["height"] or 20);
			end

			VUHDO_applyAuraSlotFrameLevel(aContainer, aAuraButton, tSlotButtonSetup, aTemplateRef["containerLevel"]);

			if tSlotButtonSetup["shadowBar"] and tSlotButtonSetup["shadowValueMode"] == "duration" then
				VUHDO_reapplyOverlayDurationSlotSetup(aAuraButton, tSlotButtonSetup);
			end

			return;

		end;

	end



	--
	function VUHDO_reapplyOverlayDurationSlotSetup(aAuraButton, aButtonSetup)

		if not aAuraButton or not aButtonSetup then
			return;
		end

		if aButtonSetup["shadowValueMode"] ~= "duration" or not aButtonSetup["shadowBar"] then
			return;
		end

		if not aAuraButton:CanBeAccessedInContext() then
			return;
		end

		tShadowBar = aAuraButton["ShadowBar"];

		if not tShadowBar then
			return;
		end

		VUHDO_layoutOverlayDurationShadowBar(aAuraButton);

		VUHDO_applyAuraButtonVolatileSetup(aButtonSetup, aAuraButton);

		if aButtonSetup["barInverted"] then
			sAuraDurationBarOptions["direction"] = Enum.StatusBarTimerDirection.ElapsedTime;
		else
			sAuraDurationBarOptions["direction"] = Enum.StatusBarTimerDirection.RemainingTime;
		end

		aAuraButton:SetDurationBar(tShadowBar, sAuraDurationBarOptions);

		tShadowBar["isDuration"] = true;

		tShadowBar:Show();

		return;

	end
end



do
	--
	local tContainerLevel;
	local tFrameLevelOffset;
	function VUHDO_applyAuraSlotFrameLevel(aContainer, aAuraButton, aButtonSetup, aFallbackContainerLevel)

		if not aContainer or not aAuraButton or not aButtonSetup then
			return;
		end

		tContainerLevel = aContainer:GetFrameLevel();

		if not tContainerLevel or tContainerLevel <= 0 then
			tContainerLevel = aFallbackContainerLevel;
		end

		tFrameLevelOffset = aButtonSetup["frameLevelOffset"];

		if tFrameLevelOffset and tContainerLevel then
			VUHDO_PixelUtil.SetFrameLevel(aAuraButton, tContainerLevel + tFrameLevelOffset);
		end

		return;

	end
end



do
	--
	function VUHDO_reapplyAuraSlotVolatileSetup(aContainer, aButtonSetup, aAuraButton)

		if not aButtonSetup or not aAuraButton then
			return;
		end

		VUHDO_applyAuraButtonVolatileSetup(aButtonSetup, aAuraButton);

		VUHDO_applyAuraSlotFrameLevel(aContainer, aAuraButton, aButtonSetup, nil);

		if aButtonSetup["auraGroupBarGlow"] then
			VUHDO_applyAuraGroupBarGlowFromAuraButton(aAuraButton, aButtonSetup);
		end

		if aButtonSetup["glowIcon"] then
			VUHDO_startAuraButtonGlow(aAuraButton, aButtonSetup);
		end

		return;

	end
end



do
	--
	function VUHDO_pixelSnapCoverFrame(aFrame, aTargetFrame)

		VUHDO_PixelUtil.ClearAllPoints(aFrame);

		VUHDO_PixelUtil.SetPoint(aFrame, "TOPLEFT", aTargetFrame, "TOPLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(aFrame, "TOPRIGHT", aTargetFrame, "TOPRIGHT", 0, 0);
		VUHDO_PixelUtil.SetPoint(aFrame, "BOTTOMLEFT", aTargetFrame, "BOTTOMLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(aFrame, "BOTTOMRIGHT", aTargetFrame, "BOTTOMRIGHT", 0, 0);

		return;

	end



	--
	local tLayoutShadowBar;
	function VUHDO_layoutOverlayDurationShadowBar(aAuraButton)

		tLayoutShadowBar = aAuraButton["ShadowBar"];

		if not tLayoutShadowBar then
			return;
		end

		VUHDO_PixelUtil.ClearAllPoints(tLayoutShadowBar);

		VUHDO_PixelUtil.SetPoint(tLayoutShadowBar, "TOPLEFT", aAuraButton, "TOPLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(tLayoutShadowBar, "TOPRIGHT", aAuraButton, "TOPRIGHT", 0, 0);
		VUHDO_PixelUtil.SetPoint(tLayoutShadowBar, "BOTTOMLEFT", aAuraButton, "BOTTOMLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(tLayoutShadowBar, "BOTTOMRIGHT", aAuraButton, "BOTTOMRIGHT", 0, 0);

		tLayoutShadowBar:Show();

		return;

	end



	--
	local tMode;
	local tRelFrame;
	local tYOff;
	local tLevelBase;
	local tOffsetX;
	local tOffsetY;
	function VUHDO_applyAuraContainerAnchor(aContainer, anAnchor, aParent)

		aContainer:ClearAllPoints();

		if not anAnchor then
			aContainer:SetAllPoints(aParent);

			return;
		end

		tMode = anAnchor["mode"];

		if tMode == "healthBarCover" then
			tRelFrame = VUHDO_getAuraAnchorHost(aParent) or aParent;

			tOffsetX = anAnchor["offsetX"] or 0;
			tOffsetY = anAnchor["offsetY"] or 0;

			VUHDO_PixelUtil.SetPoint(aContainer, "TOPLEFT", tRelFrame, "TOPLEFT", tOffsetX, tOffsetY);
			VUHDO_PixelUtil.SetPoint(aContainer, "BOTTOMRIGHT", tRelFrame, "BOTTOMRIGHT", tOffsetX, tOffsetY);
		elseif tMode == "anchorpos" and anAnchor["points"] then
			for _, tPoint in ipairs(anAnchor["points"]) do
				if tPoint["relFrame"] == "HealthBar" then
					tRelFrame = VUHDO_getAuraAnchorHost(aParent);
				else
					tRelFrame = aParent;
				end

				if not tRelFrame then
					tRelFrame = aParent;
				end

				tYOff = tPoint["y"] or 0;

				VUHDO_PixelUtil.SetPoint(aContainer, tPoint["point"] or "TOPLEFT", tRelFrame, tPoint["relativePoint"] or tPoint["point"] or "TOPLEFT", tPoint["x"] or 0, tYOff);
			end
		elseif tMode == "topEdge" then
			VUHDO_PixelUtil.SetPoint(aContainer, "TOPLEFT", anAnchor["target"] or aParent, "TOPLEFT", 0, 0);
			VUHDO_PixelUtil.SetPoint(aContainer, "TOPRIGHT", anAnchor["target"] or aParent, "TOPRIGHT", 0, 0);
		else
			if not InCombatLockdown() then
				VUHDO_pixelSnapCoverFrame(aContainer, anAnchor["target"] or aParent);
			end
		end

		if anAnchor["frameLevelOffset"] then
			tLevelBase = anAnchor["levelBase"] or aParent;

			aContainer:SetFrameLevel(tLevelBase:GetFrameLevel() + anAnchor["frameLevelOffset"]);
		end

		return;

	end



	--
	function VUHDO_getAuraRangeFadeParent(aButton, anIsRangeFade)

		if anIsRangeFade then
			return VUHDO_getHealthBar(aButton, 3) or aButton;
		end

		return aButton;

	end



	--
	local tFadeParent;
	function VUHDO_applyAuraContainerFadeParent(aContainer, aButton, aContainerTemplate)

		if not aContainer or not aButton or not aContainerTemplate then
			return;
		end

		if aContainerTemplate["isOverlay"] then
			return;
		end

		if InCombatLockdown() then
			return;
		end

		tFadeParent = VUHDO_getAuraRangeFadeParent(aButton, aContainerTemplate["rangeFade"]);

		if aContainer:GetParent() ~= tFadeParent then
			aContainer:SetParent(tFadeParent);

			VUHDO_applyAuraContainerAnchor(aContainer, aContainerTemplate["anchor"], aButton);
		end

		return;

	end
end



do
	--
	local tStaticSlots;
	local tStaticSlotEntry;
	local tStaticSlotKey;
	function VUHDO_collectStaticSlotsFromTemplate(aContainerTemplate)

		tStaticSlots = { };

		for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
			if tSlot["isStaticBouquetSlot"] then
				tStaticSlotEntry = {
					["bouquetName"] = tSlot["bouquetName"],
					["entryIndex"] = tSlot["entryIndex"],
					["slotIndex"] = tSlot["entryIndex"],
					["itemIndex"] = tSlot["itemIndex"],
					["isMixedBouquetItem"] = tSlot["isMixedBouquetItem"],
					["frameLevelOffset"] = tSlot["frameLevelOffset"] or (tSlot["buttonSetup"] and tSlot["buttonSetup"]["frameLevelOffset"]),
					["anchor"] = tSlot["anchor"],
					["relPoint"] = tSlot["relPoint"],
					["x"] = tSlot["x"],
					["y"] = tSlot["y"],
					["width"] = tSlot["width"],
					["height"] = tSlot["height"],
				};

				if tSlot["isMixedBouquetItem"] and tSlot["itemIndex"] then
					tStaticSlotKey = format("%d:%d", tSlot["entryIndex"], tSlot["itemIndex"]);
					tStaticSlotEntry["slotIndex"] = tStaticSlotKey;
				else
					tStaticSlotKey = tSlot["entryIndex"];
				end

				tStaticSlots[tStaticSlotKey] = tStaticSlotEntry;
			end
		end

		return tStaticSlots;

	end



	--
	function VUHDO_finalizeCachedAuraContainerTemplate(aContainerTemplate)

		if not aContainerTemplate then
			return nil;
		end

		if not aContainerTemplate["buildSignature"] then
			VUHDO_getAuraContainerBuildSignature(aContainerTemplate);
		end

		if not aContainerTemplate["filterSignature"] then
			VUHDO_getAuraContainerFilterSignature(aContainerTemplate);
		end

		if not aContainerTemplate["staticSlots"] then
			aContainerTemplate["staticSlots"] = VUHDO_collectStaticSlotsFromTemplate(aContainerTemplate);
		end

		if aContainerTemplate["usesDispelTextures"] == nil then
			aContainerTemplate["usesDispelTextures"] = VUHDO_containerTemplateUsesDispelTextures(aContainerTemplate);
		end

		return aContainerTemplate;

	end

end



do
	--
	local tOptions;
	local tTemplateRef;
	local tGroupKey;
	local function VUHDO_addAuraContainerGroup(aContainer, aGroup, aGroupKeys, aGroupRefs)

		tTemplateRef = {
			["template"] = aGroup,
		};

		if aGroupRefs then
			tinsert(aGroupRefs, tTemplateRef);
		end

		tTemplateRef["identityGate"] = VUHDO_getTemplateIdentityGate(aGroup);
		tTemplateRef["isCompoundFilterString"] = VUHDO_isCompoundFilterStringTemplate(aGroup);

		tOptions = {
			["maxFrameCount"] = aGroup["maxFrameCount"] or 5,
			["sortMethod"] = aGroup["sortMethod"] or AuraContainerSortMethod.Default,
			["sortDirection"] = aGroup["sortDir"] or AuraContainerSortDirection.Normal,
			["templateNames"] = { aGroup["templateName"] },
			["candidateFilters"] = aGroup["candidateFilters"],
			["layout"] = aGroup["layout"],
			["initializeFrame"] = VUHDO_buildAuraButtonInitializer(tTemplateRef, aContainer),
		};

		tGroupKey = aGroup["key"] or "aura";

		aContainer:AddAuraGroup(tGroupKey, aGroup["filterString"] or "HELPFUL", tOptions);

		if aGroupKeys then
			tinsert(aGroupKeys, tGroupKey);
		end

		return;

	end



	--
	local tTemplateRef;
	local tSlotOptions;
	local tSlotKey;
	local tAuraFrame;
	local function VUHDO_addAuraContainerSlot(aContainer, aSlot, anAnchorPoint, aSlotKeys, aSlotFrames, aSlotRefs)

		tTemplateRef = {
			["template"] = aSlot,
		};

		tTemplateRef["containerLevel"] = aContainer:GetFrameLevel();

		if aSlotRefs then
			tinsert(aSlotRefs, tTemplateRef);
		end

		tTemplateRef["identityGate"] = VUHDO_getTemplateIdentityGate(aSlot);
		tTemplateRef["isCompoundFilterString"] = VUHDO_isCompoundFilterStringTemplate(aSlot);

		tSlotOptions = {
			["templateNames"] = { aSlot["templateName"] },
			["candidateFilters"] = aSlot["candidateFilters"],
			["initializeFrame"] = VUHDO_buildAuraSlotButtonInitializer(tTemplateRef, aContainer, anAnchorPoint),
		};

		tSlotKey = aSlot["key"];

		tAuraFrame = aContainer:AddAuraSlot(tSlotKey, aSlot["filterString"] or "HELPFUL", tSlotOptions);

		if aSlotKeys then
			tinsert(aSlotKeys, tSlotKey);
		end

		if aSlotFrames and tSlotKey and tAuraFrame then
			aSlotFrames[tSlotKey] = tAuraFrame;
		end

		return tAuraFrame;

	end



	--
	local tChainTargetBar;
	local tChainBaselineFrame;
	local tChainBaselineMask;
	local tChainBaselineTexture;
	local tChainButtonName;
	local tPreviousBaselineFrame;
	local tPreviousBaselineMask;
	local tPreviousBackgroundFillOwner;
	local tChainBaselineTopInset;
	function VUHDO_setupOverlayFillChain(aContainer, aContainerTemplate, aContainerData)

		if not aContainer or not aContainerTemplate or not aContainerTemplate["isFillChain"] then
			return;
		end

		tChainTargetBar = aContainerTemplate["overlayTargetBar"];

		if not tChainTargetBar then
			return;
		end

		if aContainerTemplate["chainHasBaseline"] then
			tChainBaselineFrame = aContainer["ChainBaselineFrame"];
			tChainBaselineTexture = tChainBaselineFrame and tChainBaselineFrame["ChainBaselineTexture"];
			tChainBaselineMask = tChainBaselineFrame and tChainBaselineFrame["ChainBaselineMask"];

			if tChainBaselineFrame and tChainBaselineTexture and tChainBaselineMask then
				tPreviousBaselineFrame = sChainBaselineFrames[tChainTargetBar];

				if tPreviousBaselineFrame and tPreviousBaselineFrame ~= tChainBaselineFrame then
					tPreviousBaselineMask = tPreviousBaselineFrame["ChainBaselineMask"];

					if tPreviousBaselineMask then
						tPreviousBaselineMask:ClearAllPoints();
					end

					tPreviousBaselineFrame:ClearAllPoints();
					tPreviousBaselineFrame:Hide();
					tPreviousBaselineFrame:SetParent(nil);
				end

				tChainBaselineMask:SetTexture(nil);
				tChainBaselineMask:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST");

				VUHDO_PixelUtil.ApplySettings(tChainBaselineMask);

				tChainBaselineFrame:SetParent(tChainTargetBar);
				tChainBaselineFrame:SetFrameLevel(aContainer:GetFrameLevel());

				tChainBaselineFrame:ClearAllPoints();
				tChainBaselineFrame:SetAllPoints(tChainTargetBar);

				tChainBaselineTexture:Show();

				tChainBaselineMask:ClearAllPoints();

				-- AnchorUtil.ApplyFlowLayout clamps an empty container to a one pixel minimum size
				tChainBaselineTopInset = VUHDO_PixelUtil.RoundToPixel(1, 1);

				VUHDO_PixelUtil.SetPoint(tChainBaselineMask, "TOPLEFT", aContainer, "BOTTOMLEFT", 0, tChainBaselineTopInset);
				VUHDO_PixelUtil.SetPoint(tChainBaselineMask, "BOTTOMRIGHT", tChainTargetBar, "BOTTOMRIGHT", 0, 0);

				tPreviousBackgroundFillOwner = sChainBackgroundFillOwners[tChainTargetBar];

				if tPreviousBackgroundFillOwner and tPreviousBackgroundFillOwner ~= aContainerData then
					tPreviousBackgroundFillOwner["ownsBackgroundFill"] = nil;
					tPreviousBackgroundFillOwner["backgroundFillHidden"] = nil;
				end

				aContainerData["ownsBackgroundFill"] = true;

				aContainerData["chainBaselineFrame"] = tChainBaselineFrame;
				aContainerData["chainBaselineTexture"] = tChainBaselineTexture;

				sChainBaselineFrames[tChainTargetBar] = tChainBaselineFrame;
				sChainBackgroundFillOwners[tChainTargetBar] = aContainerData;

				tChainButtonName = tChainTargetBar:GetParent() and tChainTargetBar:GetParent():GetName();

				if tChainButtonName then
					VUHDO_applyStoredChainBaselineColor(tChainButtonName, aContainerData);
				end
			end
		end

		return;

	end



	--
	local tParent;
	local tContainer;
	local tContainerLayout;
	local tMaxLineSize;
	local tSlotTemplateRefs;
	local tGroupTemplateRefs;
	local tContainerData;
	local tSlotKeys;
	local tSlotFrames;
	local tGroupKeys;
	local tNeedsProcessAuraPolicy;
	local tGroupCandidateFilters;
	local tSlotCandidateFilters;
	function VUHDO_buildManagedAuraContainer(aContainerTemplate)

		tParent = aContainerTemplate["parent"];

		tContainer = CreateFrame("AuraContainer", nil, tParent, aContainerTemplate["chainHasBaseline"] and VUHDO_FILL_CHAIN_CONTAINER_TEMPLATE or VUHDO_AURA_CONTAINER_TEMPLATE);

		tContainerLayout = aContainerTemplate["containerLayout"];

		if tContainerLayout and not tContainerLayout["isFixedLayout"] then
			tContainer:SetFlowLayoutAnchorPoint(tContainerLayout["anchorPoint"] or "TOPLEFT");

			tContainer:SetFlowLayoutAxis(tContainerLayout["layoutAxis"] or AnchorUtil.FlowLayoutAxis.Horizontal);

			tContainer:SetFlowLayoutGrowthDirection(tContainerLayout["horizontalDir"] or AnchorUtil.FlowDirection.Right, tContainerLayout["verticalDir"] or AnchorUtil.FlowDirection.Down);

			tContainer:SetFlowLayoutPadding(tContainerLayout["paddingLeft"] or 0, tContainerLayout["paddingRight"] or 0, tContainerLayout["paddingTop"] or 0, tContainerLayout["paddingBottom"] or 0);

			if (tContainerLayout["maxColumns"] or 1) <= 1 then
				tContainer:SetFlowLayoutMaximumLineSize(nil);
			elseif AnchorUtil.FlowLayoutAxis.Vertical == tContainerLayout["layoutAxis"] and tContainerLayout["elementHeight"] then
				tMaxLineSize = (tContainerLayout["maxColumns"] or 1) * (tContainerLayout["elementHeight"] + (tContainerLayout["spacing"] or 0));

				tContainer:SetFlowLayoutMaximumLineSize(tMaxLineSize);
			elseif tContainerLayout["elementWidth"] then
				tMaxLineSize = (tContainerLayout["maxColumns"] or 1) * (tContainerLayout["elementWidth"] + (tContainerLayout["spacing"] or 0));

				tContainer:SetFlowLayoutMaximumLineSize(tMaxLineSize);
			end
		end

		VUHDO_applyAuraContainerAnchor(tContainer, aContainerTemplate["anchor"], tParent);

		tContainer:SetMouseClickEnabled(false);

		if aContainerTemplate["isOverlay"] then
			tContainer:EnableMouse(false);
			tContainer:SetMouseMotionEnabled(false);
		end

		tNeedsProcessAuraPolicy = false;

		for _, tGroup in ipairs(aContainerTemplate["groups"] or sEmpty) do
			tGroupCandidateFilters = tGroup["candidateFilters"];

			if tGroupCandidateFilters and tGroupCandidateFilters["processedAuraType"] then
				tNeedsProcessAuraPolicy = true;

				break;
			end
		end

		if not tNeedsProcessAuraPolicy then
			for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
				tSlotCandidateFilters = tSlot["candidateFilters"];

				if tSlotCandidateFilters and tSlotCandidateFilters["processedAuraType"] then
					tNeedsProcessAuraPolicy = true;

					break;
				end
			end
		end

		if tNeedsProcessAuraPolicy then
			tContainer:SetAuraProcessingPolicy(CustomAuraContainerAuraProcessingPolicy.ProcessAura, nil);
		end

		tSlotKeys = { };
		tSlotFrames = { };
		tGroupKeys = { };
		tSlotTemplateRefs = { };
		tGroupTemplateRefs = { };

		for _, tGroup in ipairs(aContainerTemplate["groups"] or sEmpty) do
			VUHDO_addAuraContainerGroup(tContainer, tGroup, tGroupKeys, tGroupTemplateRefs);
		end

		for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
			if not tSlot["isStaticBouquetSlot"] then
				VUHDO_addAuraContainerSlot(tContainer, tSlot, tContainerLayout and tContainerLayout["anchorPoint"] or "TOPLEFT", tSlotKeys, tSlotFrames, tSlotTemplateRefs);
			end
		end

		tContainer:SetEnabled(false);
		tContainer:SetShown(false);

		tContainerData = {
			["container"] = tContainer,
			["containerTemplate"] = aContainerTemplate,
			["overlayTargetBar"] = aContainerTemplate["overlayTargetBar"],
			["slotKeys"] = tSlotKeys,
			["slotFrames"] = tSlotFrames,
			["groupKeys"] = tGroupKeys,
			["slotTemplateRefs"] = tSlotTemplateRefs,
			["groupTemplateRefs"] = tGroupTemplateRefs,
			["staticSlots"] = aContainerTemplate["staticSlots"] or VUHDO_collectStaticSlotsFromTemplate(aContainerTemplate),
			["panelNum"] = aContainerTemplate["panelNum"],
			["anchorIndex"] = aContainerTemplate["anchorIndex"],
		};

		if aContainerTemplate["isFillChain"] then
			VUHDO_setupOverlayFillChain(tContainer, aContainerTemplate, tContainerData);
		elseif aContainerTemplate["isMissingBuff"] then
			if not VUHDO_setupOverlayMissingBuff(tContainer, aContainerTemplate, tContainerData) then
				tContainer:Hide();
				tContainer:SetParent(nil);

				return nil;
			end
		end

		return tContainerData;

	end



	--
	function VUHDO_addOverlaySlotToHost(aContainer, aSlot, anAnchorPoint, aSlotKeys, aSlotFrames, aSlotRefs)

		return VUHDO_addAuraContainerSlot(aContainer, aSlot, anAnchorPoint, aSlotKeys, aSlotFrames, aSlotRefs);

	end
end



do
	--
	local tFrameName;
	local tFrame;
	function VUHDO_getOrCreateMissingBuffBarFrame(aTargetBar, aSlotIndex)

		if not aTargetBar or not aSlotIndex then
			return nil;
		end

		tFrameName = format("%sMbBar%d", aTargetBar:GetName(), aSlotIndex);
		tFrame = _G[tFrameName];

		if not tFrame then
			if InCombatLockdown() then
				return nil;
			end

			tFrame = CreateFrame("Frame", tFrameName, aTargetBar, "VuhDoMissingBuffBarTemplate");
			tFrame["addLevel"] = 0;

			VUHDO_fixFrameLevels(false, aTargetBar, aTargetBar:GetFrameLevel(), aTargetBar:GetChildren());
		end

		return tFrame;

	end
end



do
	--
	local tTargetBar;
	local tCategName;
	local tSlotIndex;
	local tFrame;
	local tEmptyMask;
	local tBarTexture;
	local tFillMask;
	local tButtonName;
	function VUHDO_setupOverlayMissingBuff(aContainer, aContainerTemplate, aContainerData)

		if not aContainer or not aContainerTemplate or not aContainerTemplate["isMissingBuff"] then
			return false;
		end

		tTargetBar = aContainerTemplate["overlayTargetBar"];
		tCategName = aContainerTemplate["missingBuffCategName"];
		tSlotIndex = aContainerTemplate["missingBuffSlotIndex"];

		if not tTargetBar or not tCategName or not tSlotIndex then
			return false;
		end

		tFrame = VUHDO_getOrCreateMissingBuffBarFrame(tTargetBar, tSlotIndex);

		if not tFrame then
			return false;
		end

		tBarTexture = tFrame["BarTexture"];
		tEmptyMask = tFrame["EmptyMask"];
		tFillMask = tFrame["FillMask"];

		if tBarTexture and tEmptyMask and tFillMask then

			tEmptyMask:SetTexture(nil);
			tEmptyMask:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST");

			VUHDO_PixelUtil.ApplySettings(tEmptyMask);

			tFillMask:SetTexture(nil);
			tFillMask:SetTexture("Interface\\Buttons\\WHITE8X8", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE", "NEAREST");

			VUHDO_PixelUtil.ApplySettings(tFillMask);

			tFrame:ClearAllPoints();
			tFrame:SetAllPoints(tTargetBar);

			tFrame:Show();
			tBarTexture:Show();

			tBarTexture:SetDrawLayer("ARTWORK", aContainerTemplate["missingBuffSublevel"] or 0);

			aContainerData["missingBuffBarFrame"] = tFrame;
			aContainerData["missingBuffBarTexture"] = tBarTexture;
			aContainerData["missingBuffCategName"] = tCategName;
			aContainerData["missingBuffSlotIndex"] = tSlotIndex;

			VUHDO_refreshMissingBuffBarFill(aContainerData, true);

			tButtonName = tTargetBar:GetParent() and tTargetBar:GetParent():GetName();

			if tButtonName then
				VUHDO_applyStoredMissingBuffBarColor(tButtonName, tCategName, aContainerData);
			end

			return true;
		end

		return false;

	end
end



do
	--
	local tOverlayHostTargetBarName;
	local tOverlayHostFrameName;
	local tOverlayHostFrame;
	function VUHDO_getOverlayHostFrame(aTargetBar)

		if not aTargetBar then
			return nil;
		end

		tOverlayHostTargetBarName = aTargetBar:GetName();

		if not tOverlayHostTargetBarName then
			return nil;
		end

		tOverlayHostFrameName = tOverlayHostTargetBarName .. "OlHost";
		tOverlayHostFrame = aTargetBar["VuhDoOverlayHostFrame"];

		if not tOverlayHostFrame then
			tOverlayHostFrame = _G[tOverlayHostFrameName];

			if tOverlayHostFrame then
				aTargetBar["VuhDoOverlayHostFrame"] = tOverlayHostFrame;
			elseif not aTargetBar:IsObjectType("Frame") then
				tOverlayHostFrame = aTargetBar:GetParent();
			end
		end

		return tOverlayHostFrame;

	end



	--
	local tButtonSetup;
	function VUHDO_containerTemplateUsesDispelTextures(aContainerTemplate)

		if not aContainerTemplate then
			return false;
		end

		for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
			tButtonSetup = tSlot["buttonSetup"];

			if tButtonSetup and (tButtonSetup["dispelFill"] or tButtonSetup["dispelBorder"] or tButtonSetup["dispelIcon"] or tButtonSetup["dispelOverlayChrome"]) then
				return true;
			end

			if tButtonSetup and tButtonSetup["auraGroupBarGlow"] then
				if tButtonSetup["glowColorType"] == _G["VUHDO_AURA_GROUP_COLOR_DISPEL"] or tButtonSetup["glowColorType"] == _G["VUHDO_AURA_GROUP_COLOR_ALL_DISPEL"] then
					return true;
				end
			end
		end

		for _, tGroup in ipairs(aContainerTemplate["groups"] or sEmpty) do
			tButtonSetup = tGroup["buttonSetup"];

			if tButtonSetup and (tButtonSetup["dispelFill"] or tButtonSetup["dispelBorder"] or tButtonSetup["dispelIcon"] or tButtonSetup["dispelOverlayChrome"]) then
				return true;
			end

			if tButtonSetup and tButtonSetup["auraGroupBarGlow"] then
				if tButtonSetup["glowColorType"] == _G["VUHDO_AURA_GROUP_COLOR_DISPEL"] or tButtonSetup["glowColorType"] == _G["VUHDO_AURA_GROUP_COLOR_ALL_DISPEL"] then
					return true;
				end
			end
		end

		return false;

	end
end



do
	--
	local tCandidateKeys;
	local tCandidateKey;
	local tCandidateValue;
	local tCandidateSpellIds;
	local tCandidateDispelNames;
	local tCandidateParts;
	local function VUHDO_appendSignatureCandidateFilters(aSignatureParts, aCandidateFilters)

		if not aCandidateFilters then
			tinsert(aSignatureParts, "");

			return;
		end

		tCandidateParts = { };

		tCandidateKeys = { };

		for tCandidateKey in pairs(aCandidateFilters) do
			tinsert(tCandidateKeys, tCandidateKey);
		end

		tsort(tCandidateKeys);

		for tCandidateCnt = 1, #tCandidateKeys do
			tCandidateKey = tCandidateKeys[tCandidateCnt];
			tCandidateValue = aCandidateFilters[tCandidateKey];

			if "includeSpellIDs" == tCandidateKey or "excludeSpellIDs" == tCandidateKey then
				tCandidateSpellIds = { };

				for tSpellId in pairs(tCandidateValue or sEmpty) do
					tinsert(tCandidateSpellIds, tSpellId);
				end

				tsort(tCandidateSpellIds);

				tinsert(tCandidateParts, format("%s=%s", tCandidateKey, tconcat(tCandidateSpellIds, ",")));
			elseif "includeDispelTypes" == tCandidateKey or "excludeDispelTypes" == tCandidateKey then
				tCandidateDispelNames = { };

				for tDispelName, tIsIncluded in pairs(tCandidateValue or sEmpty) do
					if tIsIncluded then
						tinsert(tCandidateDispelNames, tDispelName);
					end
				end

				tsort(tCandidateDispelNames);

				tinsert(tCandidateParts, format("%s=%s", tCandidateKey, tconcat(tCandidateDispelNames, ",")));
			else
				tinsert(tCandidateParts, format("%s=%s", tCandidateKey, tostring(tCandidateValue)));
			end
		end

		tinsert(aSignatureParts, tconcat(tCandidateParts, ";"));

		return;

	end



	--
	local tSublevelSlots;
	local tSublevelSlot;
	local tDurationBarOptions;
	local function VUHDO_appendAuraContainerBuildSignatureExtras(aSignatureParts, aButtonSetup)

		tSublevelSlots = aButtonSetup["sublevelSlots"];

		if tSublevelSlots then
			for tSublevelCnt = 1, #tSublevelSlots do
				tSublevelSlot = tSublevelSlots[tSublevelCnt];

				if tSublevelSlot then
					tinsert(aSignatureParts, tSublevelSlot["layer"] or "");
					tinsert(aSignatureParts, format("%d", tSublevelSlot["sublevel"] or 0));
				end
			end
		end

		tinsert(aSignatureParts, format("%d", aButtonSetup["iconType"] or 0));
		tinsert(aSignatureParts, aButtonSetup["barVertical"] and "1" or "0");
		tinsert(aSignatureParts, aButtonSetup["barTurnAxis"] and "1" or "0");
		tinsert(aSignatureParts, aButtonSetup["durationBar"] and "1" or "0");
		tinsert(aSignatureParts, format("%d", aButtonSetup["durationBarOrientation"] or 0));

		tDurationBarOptions = aButtonSetup["durationBarOptions"];

		if tDurationBarOptions then
			tinsert(aSignatureParts, format("%d", tDurationBarOptions["direction"] or 0));
		else
			tinsert(aSignatureParts, "0");
		end

		return;

	end



	local function VUHDO_appendAuraContainerBuildSignatureButtonSetupCore(aSignatureParts, aButtonSetup)

		tinsert(aSignatureParts, aButtonSetup["shadowBar"] and "1" or "0");
		tinsert(aSignatureParts, aButtonSetup["dispelFill"] and "1" or "0");
		tinsert(aSignatureParts, aButtonSetup["dispelBorder"] and "1" or "0");
		tinsert(aSignatureParts, aButtonSetup["dispelIcon"] and "1" or "0");
		tinsert(aSignatureParts, format("%d", aButtonSetup["targetFrameLevel"] or 0));
		tinsert(aSignatureParts, aButtonSetup["border"] and "1" or "0");
		tinsert(aSignatureParts, aButtonSetup["glowIcon"] and "1" or "0");
		tinsert(aSignatureParts, aButtonSetup["dispelOverlayChrome"] and "1" or "0");
		tinsert(aSignatureParts, aButtonSetup["disableMouse"] and "1" or "0");

		VUHDO_appendAuraContainerBuildSignatureExtras(aSignatureParts, aButtonSetup);

	end



	--
	local tContainerLayout;
	local tButtonSetup;
	local function VUHDO_appendAuraContainerBuildSignatureParts(aSignatureParts, aContainerTemplate)

		tinsert(aSignatureParts, aContainerTemplate["isOverlay"] and "1" or "0");
		tinsert(aSignatureParts, aContainerTemplate["isFillChain"] and "1" or "0");
		tinsert(aSignatureParts, aContainerTemplate["chainHasBaseline"] and "1" or "0");
		tinsert(aSignatureParts, aContainerTemplate["isMissingBuff"] and "1" or "0");
		tinsert(aSignatureParts, aContainerTemplate["missingBuffCategName"] or "");
		tinsert(aSignatureParts, format("%d", aContainerTemplate["missingBuffSlotIndex"] or 0));

		if aContainerTemplate["anchor"] then
			tinsert(aSignatureParts, aContainerTemplate["anchor"]["mode"] or "");
			tinsert(aSignatureParts, format("%d", aContainerTemplate["anchor"]["frameLevelOffset"] or 0));
			tinsert(aSignatureParts, format("%d", aContainerTemplate["anchor"]["offsetX"] or 0));
			tinsert(aSignatureParts, format("%d", aContainerTemplate["anchor"]["offsetY"] or 0));
		end

		tContainerLayout = aContainerTemplate["containerLayout"];

		if tContainerLayout then
			tinsert(aSignatureParts, tContainerLayout["isFixedLayout"] and "1" or "0");
			tinsert(aSignatureParts, format("%d", tContainerLayout["fixedRadioValue"] or 0));
			tinsert(aSignatureParts, tContainerLayout["useFixedSlots"] and "1" or "0");
			tinsert(aSignatureParts, tContainerLayout["anchorPoint"] or "");
			tinsert(aSignatureParts, format("%d", tContainerLayout["elementWidth"] or 0));
			tinsert(aSignatureParts, format("%d", tContainerLayout["elementHeight"] or 0));
			tinsert(aSignatureParts, format("%d", tContainerLayout["maxColumns"] or 0));
			tinsert(aSignatureParts, format("%d", tContainerLayout["maxRows"] or 0));
			tinsert(aSignatureParts, format("%d", tContainerLayout["spacing"] or 0));
			tinsert(aSignatureParts, format("%d", tContainerLayout["layoutAxis"] or 0));
			tinsert(aSignatureParts, format("%d", tContainerLayout["horizontalDir"] or 0));
			tinsert(aSignatureParts, format("%d", tContainerLayout["verticalDir"] or 0));
		end

		for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
			tinsert(aSignatureParts, "s");
			tinsert(aSignatureParts, tSlot["key"] or "");

			if tSlot["isStaticBouquetSlot"] then
				tinsert(aSignatureParts, "static");
				tinsert(aSignatureParts, tSlot["bouquetName"] or "");
				tinsert(aSignatureParts, format("%d", tSlot["entryIndex"] or 0));
				tinsert(aSignatureParts, format("%d", tSlot["itemIndex"] or 0));
				tinsert(aSignatureParts, format("%d", tSlot["frameLevelOffset"] or 0));
				tinsert(aSignatureParts, tSlot["isMixedBouquetItem"] and "1" or "0");
				tinsert(aSignatureParts, format("%d", tSlot["x"] or 0));
				tinsert(aSignatureParts, format("%d", tSlot["y"] or 0));

				tButtonSetup = tSlot["buttonSetup"];

				if tButtonSetup then
					tinsert(aSignatureParts, format("%d", tButtonSetup["frameLevelOffset"] or 0));
				end
			else
				tinsert(aSignatureParts, tSlot["templateName"] or "");
			end

			tinsert(aSignatureParts, format("%d", tSlot["width"] or 0));
			tinsert(aSignatureParts, format("%d", tSlot["height"] or 0));
			tinsert(aSignatureParts, tSlot["anchor"] or "");
			tinsert(aSignatureParts, tSlot["relPoint"] or "");
			tinsert(aSignatureParts, format("%d", tSlot["x"] or 0));
			tinsert(aSignatureParts, format("%d", tSlot["y"] or 0));

			tButtonSetup = tSlot["buttonSetup"];

			if tButtonSetup and not tSlot["isStaticBouquetSlot"] then
				tinsert(aSignatureParts, format("%d", tButtonSetup["frameLevelOffset"] or 0));

				VUHDO_appendAuraContainerBuildSignatureButtonSetupCore(aSignatureParts, tButtonSetup);
			end
		end

		for _, tGroup in ipairs(aContainerTemplate["groups"] or sEmpty) do
			tinsert(aSignatureParts, "g");
			tinsert(aSignatureParts, tGroup["key"] or "");
			tinsert(aSignatureParts, tGroup["templateName"] or "");

			if tGroup["layout"] then
				tinsert(aSignatureParts, format("%d", tGroup["layout"]["elementWidth"] or 0));
				tinsert(aSignatureParts, format("%d", tGroup["layout"]["elementHeight"] or 0));
				tinsert(aSignatureParts, tGroup["layout"]["forceNewLine"] and "1" or "0");
				tinsert(aSignatureParts, format("%d", tGroup["layout"]["layoutIndex"] or 0));
				tinsert(aSignatureParts, format("%d", tGroup["layout"]["groupSpacing"] or 0));
			end

			tButtonSetup = tGroup["buttonSetup"];

			if tButtonSetup then
				tinsert(aSignatureParts, format("%d", tButtonSetup["frameLevelOffset"] or 0));
				tinsert(aSignatureParts, tGroup["isFixedLayout"] and "1" or "0");
				tinsert(aSignatureParts, format("%d", tGroup["fixedRadioValue"] or 0));
				tinsert(aSignatureParts, format("%d", tGroup["fixedBarWidth"] or 0));
				tinsert(aSignatureParts, format("%d", tGroup["fixedBarHeight"] or 0));
				tinsert(aSignatureParts, format("%d", tGroup["fixedIconSize"] or 0));
				tinsert(aSignatureParts, tButtonSetup["auraSymbol"] and "1" or "0");

				VUHDO_appendAuraContainerBuildSignatureButtonSetupCore(aSignatureParts, tButtonSetup);
			end
		end

		return;

	end



	--
	local function VUHDO_appendAuraContainerFilterSignatureParts(aSignatureParts, aContainerTemplate)

		for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
			if not tSlot["isStaticBouquetSlot"] then
				tinsert(aSignatureParts, "s");
				tinsert(aSignatureParts, tSlot["key"] or "");
				tinsert(aSignatureParts, tSlot["filterString"] or "");

				VUHDO_appendSignatureCandidateFilters(aSignatureParts, tSlot["candidateFilters"]);
			end
		end

		for _, tGroup in ipairs(aContainerTemplate["groups"] or sEmpty) do
			tinsert(aSignatureParts, "g");
			tinsert(aSignatureParts, tGroup["key"] or "");
			tinsert(aSignatureParts, tGroup["filterString"] or "");

			VUHDO_appendSignatureCandidateFilters(aSignatureParts, tGroup["candidateFilters"]);

			tinsert(aSignatureParts, format("%d", tGroup["maxFrameCount"] or 0));
			tinsert(aSignatureParts, format("%d", tGroup["sortMethod"] or 0));
			tinsert(aSignatureParts, format("%d", tGroup["sortDir"] or 0));
		end

		return;

	end



	--
	function VUHDO_getAuraContainerBuildSignature(aContainerTemplate)

		if not aContainerTemplate then
			return nil;
		end

		if aContainerTemplate["buildSignature"] then
			return aContainerTemplate["buildSignature"];
		end

		twipe(sSignatureParts);

		VUHDO_appendAuraContainerBuildSignatureParts(sSignatureParts, aContainerTemplate);

		aContainerTemplate["buildSignature"] = tconcat(sSignatureParts, "|");

		return aContainerTemplate["buildSignature"];

	end



	--
	function VUHDO_getAuraContainerFilterSignature(aContainerTemplate)

		if not aContainerTemplate then
			return nil;
		end

		if aContainerTemplate["filterSignature"] then
			return aContainerTemplate["filterSignature"];
		end

		twipe(sSignatureParts);

		VUHDO_appendAuraContainerFilterSignatureParts(sSignatureParts, aContainerTemplate);

		aContainerTemplate["filterSignature"] = tconcat(sSignatureParts, "|");

		return aContainerTemplate["filterSignature"];

	end



	--
	local function VUHDO_appendAuraButtonSetupColorSignature(aSignatureParts, aColor)

		if not aColor then
			tinsert(aSignatureParts, "0");
			tinsert(aSignatureParts, "0");
			tinsert(aSignatureParts, "0");
			tinsert(aSignatureParts, "0");

			return;
		end

		tinsert(aSignatureParts, format("%.3f", aColor["R"] or 0));
		tinsert(aSignatureParts, format("%.3f", aColor["G"] or 0));
		tinsert(aSignatureParts, format("%.3f", aColor["B"] or 0));
		tinsert(aSignatureParts, format("%.3f", aColor["O"] or 1));

		return;

	end



	--
	local function VUHDO_appendAuraButtonSetupVolatileSignatureParts(aSignatureParts, aButtonSetup)

		if not aButtonSetup then
			return;
		end

		tinsert(aSignatureParts, aButtonSetup["barTexture"] or "");
		tinsert(aSignatureParts, format("%d", aButtonSetup["barOrientation"] or 0));
		tinsert(aSignatureParts, aButtonSetup["barInverted"] and "1" or "0");
		tinsert(aSignatureParts, aButtonSetup["shadowValueMode"] or "");
		tinsert(aSignatureParts, format("%.3f", aButtonSetup["dispelOpacity"] or 0));
		VUHDO_appendAuraButtonSetupColorSignature(aSignatureParts, aButtonSetup["staticColor"]);
		tinsert(aSignatureParts, format("%d", aButtonSetup["borderWidth"] or 0));
		tinsert(aSignatureParts, aButtonSetup["borderFile"] or "");
		tinsert(aSignatureParts, format("%.3f", aButtonSetup["borderRepeatX"] or 1));
		tinsert(aSignatureParts, format("%.3f", aButtonSetup["borderRepeatY"] or 1));
		tinsert(aSignatureParts, aButtonSetup["glowStyle"] or "");
		tinsert(aSignatureParts, aButtonSetup["glowColorType"] or "");
		VUHDO_appendAuraButtonSetupColorSignature(aSignatureParts, aButtonSetup["glowColor"]);

		return;

	end



	--
	function VUHDO_getAuraButtonSetupBuildSignature(aButtonSetup)

		if not aButtonSetup then
			return nil;
		end

		if aButtonSetup["buildSignature"] then
			return aButtonSetup["buildSignature"];
		end

		twipe(sSignatureParts);

		VUHDO_appendAuraContainerBuildSignatureButtonSetupCore(sSignatureParts, aButtonSetup);

		aButtonSetup["buildSignature"] = tconcat(sSignatureParts, "|");

		return aButtonSetup["buildSignature"];

	end



	--
	function VUHDO_getAuraButtonSetupVolatileSignature(aButtonSetup)

		if not aButtonSetup then
			return nil;
		end

		if aButtonSetup["volatileSignature"] then
			return aButtonSetup["volatileSignature"];
		end

		twipe(sSignatureParts);

		VUHDO_appendAuraButtonSetupVolatileSignatureParts(sSignatureParts, aButtonSetup);

		aButtonSetup["volatileSignature"] = tconcat(sSignatureParts, "|");

		return aButtonSetup["volatileSignature"];

	end
end



do
	--
	local tButtonSetup;
	function VUHDO_getAuraContainerVolatileSignature(aContainerTemplate)

		if not aContainerTemplate then
			return nil;
		end

		if aContainerTemplate["volatileSignature"] then
			return aContainerTemplate["volatileSignature"];
		end

		twipe(sVolatileSignatureParts);

		for _, tSlot in ipairs(aContainerTemplate["slots"] or sEmpty) do
			if tSlot and not tSlot["isStaticBouquetSlot"] then
				tButtonSetup = tSlot["buttonSetup"];

				if tButtonSetup then
					tinsert(sVolatileSignatureParts, "s");
					tinsert(sVolatileSignatureParts, VUHDO_getAuraButtonSetupVolatileSignature(tButtonSetup) or "");
				end
			end
		end

		for _, tGroup in ipairs(aContainerTemplate["groups"] or sEmpty) do
			tButtonSetup = tGroup["buttonSetup"];

			if tButtonSetup then
				tinsert(sVolatileSignatureParts, "g");
				tinsert(sVolatileSignatureParts, VUHDO_getAuraButtonSetupVolatileSignature(tButtonSetup) or "");
			end
		end

		aContainerTemplate["volatileSignature"] = tconcat(sVolatileSignatureParts, "|");

		return aContainerTemplate["volatileSignature"];

	end
end



do
	--
	local tSlotKeys;
	local tSlotTemplateRefs;
	local tSlot;
	local tRecordedKey;
	local tTemplateRef;
	local tGroupKeys;
	local tGroupTemplateRefs;
	local tGroup;
	local tEngineSlotCnt;
	function VUHDO_updateAuraContainerTemplateRefs(aContainerData, aContainerTemplate)

		if not aContainerData or not aContainerTemplate then
			return;
		end

		tSlotKeys = aContainerData["slotKeys"];
		tSlotTemplateRefs = aContainerData["slotTemplateRefs"];
		tEngineSlotCnt = 0;

		for tSlotCnt = 1, #(aContainerTemplate["slots"] or sEmpty) do
			tSlot = aContainerTemplate["slots"][tSlotCnt];

			if tSlot and not tSlot["isStaticBouquetSlot"] then
				tEngineSlotCnt = tEngineSlotCnt + 1;
				tRecordedKey = tSlotKeys and tSlotKeys[tEngineSlotCnt];

				if tRecordedKey then
					tTemplateRef = tSlotTemplateRefs and tSlotTemplateRefs[tEngineSlotCnt];

					if tTemplateRef then
						tTemplateRef["template"] = tSlot;
						tTemplateRef["identityGate"] = VUHDO_getTemplateIdentityGate(tSlot);
						tTemplateRef["isCompoundFilterString"] = VUHDO_isCompoundFilterStringTemplate(tSlot);
					end
				end
			end
		end

		tGroupKeys = aContainerData["groupKeys"];
		tGroupTemplateRefs = aContainerData["groupTemplateRefs"];

		for tGroupCnt = 1, #(aContainerTemplate["groups"] or sEmpty) do
			tGroup = aContainerTemplate["groups"][tGroupCnt];
			tRecordedKey = tGroupKeys and tGroupKeys[tGroupCnt];

			if tGroup and tRecordedKey then
				tTemplateRef = tGroupTemplateRefs and tGroupTemplateRefs[tGroupCnt];

				if tTemplateRef then
					tTemplateRef["template"] = tGroup;
					tTemplateRef["identityGate"] = VUHDO_getTemplateIdentityGate(tGroup);
					tTemplateRef["isCompoundFilterString"] = VUHDO_isCompoundFilterStringTemplate(tGroup);
				end
			end
		end

		return;

	end
end



do
	--
	local tGroupKeys;
	local tGroup;
	local tRecordedKey;
	local tGroupFrameCount;
	local tAuraFrame;
	local tSlotKeys;
	local tSlotFrames;
	local tSlot;
	local tEngineSlotCnt;
	function VUHDO_canDeferAuraContainerVolatilePass(aContainer, aContainerData, aContainerTemplate)

		if not aContainer or not aContainerData or not aContainerTemplate then
			return false;
		end

		tGroupKeys = aContainerData["groupKeys"];

		if tGroupKeys then
			for tGroupCnt = 1, #(aContainerTemplate["groups"] or sEmpty) do
				tGroup = aContainerTemplate["groups"][tGroupCnt];
				tRecordedKey = tGroupKeys[tGroupCnt];

				if tGroup and tRecordedKey and tGroup["buttonSetup"] then
					tGroupFrameCount = aContainer:GetAuraGroupFrameCount(tRecordedKey);

					for tGroupFrameCnt = 1, tGroupFrameCount do
						tAuraFrame = aContainer:GetAuraGroupFrame(tRecordedKey, tGroupFrameCnt);

						if tAuraFrame and not tAuraFrame:CanBeAccessedInContext() then
							return false;
						end
					end
				end
			end
		end

		tSlotKeys = aContainerData["slotKeys"];
		tSlotFrames = aContainerData["slotFrames"];
		tEngineSlotCnt = 0;

		for tSlotCnt = 1, #(aContainerTemplate["slots"] or sEmpty) do
			tSlot = aContainerTemplate["slots"][tSlotCnt];

			if tSlot and not tSlot["isStaticBouquetSlot"] then
				tEngineSlotCnt = tEngineSlotCnt + 1;
				tRecordedKey = tSlotKeys and tSlotKeys[tEngineSlotCnt];

				if tRecordedKey then
					tAuraFrame = tSlotFrames and tSlotFrames[tRecordedKey];

					if tAuraFrame and not tAuraFrame:CanBeAccessedInContext() then
						return false;
					end
				end
			end
		end

		return true;

	end
end



do
	--
	local tSignature;
	function VUHDO_reconcileAuraContainerVolatilePass(aContainer, aContainerData, aContainerTemplate)

		if not aContainer or not aContainerData or not aContainerTemplate then
			return VUHDO_AURA_VOLATILE_PASS_KEEP;
		end

		VUHDO_updateAuraContainerTemplateRefs(aContainerData, aContainerTemplate);

		tSignature = VUHDO_getAuraContainerVolatileSignature(aContainerTemplate);

		if tSignature == aContainerData["appliedVolatileSignature"] then
			return VUHDO_AURA_VOLATILE_PASS_KEEP;
		end

		if VUHDO_canDeferAuraContainerVolatilePass(aContainer, aContainerData, aContainerTemplate) then
			aContainerData["pendingVolatileSignature"] = tSignature;

			return VUHDO_AURA_VOLATILE_PASS_DEFER;
		end

		return VUHDO_AURA_VOLATILE_PASS_REBUILD;

	end
end



do
	--
	local tSlotKeys;
	local tSlotTemplateRefs;
	local tSlot;
	local tRecordedKey;
	local tTemplateRef;
	local tGroupKeys;
	local tGroupTemplateRefs;
	local tGroup;
	local tEngineSlotCnt;
	function VUHDO_applyAuraContainerFilterPass(aContainer, aContainerData, aContainerTemplate)

		if not aContainer or not aContainerData or not aContainerTemplate then
			return;
		end

		VUHDO_restoreAuraContainerGroups(aContainer, aContainerData);

		tSlotKeys = aContainerData["slotKeys"];
		tSlotTemplateRefs = aContainerData["slotTemplateRefs"];
		tEngineSlotCnt = 0;

		for tSlotCnt = 1, #(aContainerTemplate["slots"] or sEmpty) do
			tSlot = aContainerTemplate["slots"][tSlotCnt];

			if tSlot and not tSlot["isStaticBouquetSlot"] then
				tEngineSlotCnt = tEngineSlotCnt + 1;
				tRecordedKey = tSlotKeys and tSlotKeys[tEngineSlotCnt];

				if tRecordedKey then
					aContainer:SetAuraSlotFilterString(tRecordedKey, tSlot["filterString"] or "HELPFUL");
					aContainer:SetAuraSlotCandidateFilters(tRecordedKey, tSlot["candidateFilters"]);

					tTemplateRef = tSlotTemplateRefs and tSlotTemplateRefs[tEngineSlotCnt];

					if tTemplateRef then
						tTemplateRef["template"] = tSlot;
						tTemplateRef["identityGate"] = VUHDO_getTemplateIdentityGate(tSlot);
						tTemplateRef["isCompoundFilterString"] = VUHDO_isCompoundFilterStringTemplate(tSlot);
					end
				end
			end
		end

		tGroupKeys = aContainerData["groupKeys"];
		tGroupTemplateRefs = aContainerData["groupTemplateRefs"];

		for tGroupCnt = 1, #(aContainerTemplate["groups"] or sEmpty) do
			tGroup = aContainerTemplate["groups"][tGroupCnt];
			tRecordedKey = tGroupKeys and tGroupKeys[tGroupCnt];

			if tGroup and tRecordedKey then
				aContainer:SetAuraGroupMaxFrameCount(tRecordedKey, tGroup["maxFrameCount"] or 5);
				aContainer:SetAuraGroupFilterString(tRecordedKey, tGroup["filterString"] or "HELPFUL");
				aContainer:SetAuraGroupCandidateFilters(tRecordedKey, tGroup["candidateFilters"]);

				tTemplateRef = tGroupTemplateRefs and tGroupTemplateRefs[tGroupCnt];

				if tTemplateRef then
					tTemplateRef["template"] = tGroup;
					tTemplateRef["identityGate"] = VUHDO_getTemplateIdentityGate(tGroup);
					tTemplateRef["isCompoundFilterString"] = VUHDO_isCompoundFilterStringTemplate(tGroup);
				end
			end
		end

		aContainerData["lastSlotSuppress"] = nil;
		aContainerData["lastGroupSuppress"] = nil;
		aContainerData["lastContainerSuppressed"] = nil;
		aContainerData["appliedSlotCandidateSuppress"] = nil;

		return;

	end

end



do
	--
	local tClassColorBars;
	local function VUHDO_reregisterContainerClassColorBar(aContainer, aDurationBar)

		if not aContainer or not aDurationBar then
			return;
		end

		if not sContainerClassColorBars[aContainer] then
			sContainerClassColorBars[aContainer] = { };
		end

		tClassColorBars = sContainerClassColorBars[aContainer];

		for tCnt = 1, #tClassColorBars do
			if tClassColorBars[tCnt] == aDurationBar then
				return;
			end
		end

		tinsert(tClassColorBars, aDurationBar);

		return;

	end



	--
	local tThreatMarkFlashTexture;
	local function VUHDO_isThreatMarkSlotFlashing(aAuraFrame, aSlot)

		if not aSlot or aSlot["indicatorKey"] ~= "THREAT_MARK" then
			return false;
		end

		tThreatMarkFlashTexture = aAuraFrame and aAuraFrame["FillTexture"];

		return tThreatMarkFlashTexture and tThreatMarkFlashTexture.flashTimer ~= nil;

	end



	--
	local tContainerTemplate;
	local tGroupKeys;
	local tGroup;
	local tRecordedKey;
	local tGroupFrameCount;
	local tAuraFrame;
	local tSlotKeys;
	local tSlotFrames;
	local tSlot;
	local tEngineSlotCnt;
	local tButtonSetup;
	local tSkippedCount;
	local tOwnerButton;
	function VUHDO_applyAuraContainerVolatilePass(aContainer, aContainerData)

		if not aContainer or not aContainerData then
			return;
		end

		tContainerTemplate = aContainerData["containerTemplate"];

		if not tContainerTemplate then
			return;
		end

		tSkippedCount = 0;

		tGroupKeys = aContainerData["groupKeys"];

		if tGroupKeys then
			for tGroupCnt = 1, #(tContainerTemplate["groups"] or sEmpty) do
				tGroup = tContainerTemplate["groups"][tGroupCnt];
				tRecordedKey = tGroupKeys[tGroupCnt];

				if tGroup and tRecordedKey and tGroup["buttonSetup"] then
					tButtonSetup = tGroup["buttonSetup"];
					tGroupFrameCount = aContainer:GetAuraGroupFrameCount(tRecordedKey);

					for tGroupFrameCnt = 1, tGroupFrameCount do
						tAuraFrame = aContainer:GetAuraGroupFrame(tRecordedKey, tGroupFrameCnt);

						if tAuraFrame and tAuraFrame:CanBeAccessedInContext() then
							VUHDO_applyAuraButtonVolatileSetup(tButtonSetup, tAuraFrame);

							if tButtonSetup["auraGroupBarGlow"] then
								VUHDO_applyAuraGroupBarGlowFromAuraButton(tAuraFrame, tButtonSetup);
							end

							if tButtonSetup["glowIcon"] then
								VUHDO_startAuraButtonGlow(tAuraFrame, tButtonSetup);
							end

							if "class" == tButtonSetup["barColorMode"] and tAuraFrame["DurationBar"] then
								VUHDO_reregisterContainerClassColorBar(aContainer, tAuraFrame["DurationBar"]);
							end
						elseif tAuraFrame then
							tSkippedCount = tSkippedCount + 1;
						end
					end
				end
			end
		end

		tSlotKeys = aContainerData["slotKeys"];
		tSlotFrames = aContainerData["slotFrames"];
		tEngineSlotCnt = 0;

		for tSlotCnt = 1, #(tContainerTemplate["slots"] or sEmpty) do
			tSlot = tContainerTemplate["slots"][tSlotCnt];

			if tSlot and not tSlot["isStaticBouquetSlot"] then
				tEngineSlotCnt = tEngineSlotCnt + 1;
				tRecordedKey = tSlotKeys and tSlotKeys[tEngineSlotCnt];

				if tRecordedKey then
					tAuraFrame = tSlotFrames and tSlotFrames[tRecordedKey];

					if tAuraFrame and tSlot["buttonSetup"] and tAuraFrame:CanBeAccessedInContext() then
						if not VUHDO_isThreatMarkSlotFlashing(tAuraFrame, tSlot) then
							tButtonSetup = tSlot["buttonSetup"];

							VUHDO_reapplyAuraSlotVolatileSetup(aContainer, tButtonSetup, tAuraFrame);

							if "class" == tButtonSetup["barColorMode"] and tAuraFrame["DurationBar"] then
								VUHDO_reregisterContainerClassColorBar(aContainer, tAuraFrame["DurationBar"]);
							end
						end
					elseif tAuraFrame and tSlot["buttonSetup"] then
						tSkippedCount = tSkippedCount + 1;
					end
				end
			end
		end

		if tSkippedCount == 0 and aContainerData["pendingVolatileSignature"] then
			aContainerData["appliedVolatileSignature"] = aContainerData["pendingVolatileSignature"];
			aContainerData["pendingVolatileSignature"] = nil;
		elseif tSkippedCount > 0 then
			tOwnerButton = aContainerData["ownerButton"];

			if tOwnerButton and aContainerData["panelNum"] then
				sPendingContainerBuilds[tOwnerButton] = aContainerData["panelNum"];

				sHasPendingBuilds = true;
			end
		end

		return;

	end

end



do
	--
	local tRestoreTargetBar;
	local tRestoreButtonName;
	local tRestoreStoredColor;
	local tRestoreOpacity;
	local tRestoreChainBaselineFrame;
	local tRestoreChainBaselineMask;
	local tRestoreContainer;
	local tRestoreBackgroundFillOwner;
	local function VUHDO_restoreOverlayFillChainBackground(aContainerData)

		if not aContainerData then
			return;
		end

		tRestoreChainBaselineFrame = aContainerData["chainBaselineFrame"];

		if tRestoreChainBaselineFrame then
			tRestoreChainBaselineMask = tRestoreChainBaselineFrame["ChainBaselineMask"];

			if tRestoreChainBaselineMask then
				tRestoreChainBaselineMask:ClearAllPoints();
			end

			tRestoreChainBaselineFrame:ClearAllPoints();
			tRestoreChainBaselineFrame:Hide();

			tRestoreContainer = aContainerData["container"];

			if tRestoreContainer then
				tRestoreChainBaselineFrame:SetParent(tRestoreContainer);
			else
				tRestoreChainBaselineFrame:SetParent(nil);
			end

			tRestoreTargetBar = aContainerData["overlayTargetBar"];

			if tRestoreTargetBar and sChainBaselineFrames[tRestoreTargetBar] == tRestoreChainBaselineFrame then
				sChainBaselineFrames[tRestoreTargetBar] = nil;
			end
		end

		if aContainerData["ownsBackgroundFill"] then
			tRestoreTargetBar = aContainerData["overlayTargetBar"];

			if tRestoreTargetBar then
				tRestoreBackgroundFillOwner = sChainBackgroundFillOwners[tRestoreTargetBar];

				if tRestoreBackgroundFillOwner == aContainerData then
					sChainBackgroundFillOwners[tRestoreTargetBar] = nil;

					tRestoreButtonName = tRestoreTargetBar:GetParent() and tRestoreTargetBar:GetParent():GetName();
					tRestoreStoredColor = tRestoreButtonName and sChainBaselineColors[tRestoreButtonName];

					if tRestoreStoredColor then
						tRestoreOpacity = tRestoreStoredColor["O"];

						if tRestoreOpacity == nil then
							tRestoreOpacity = 1;
						end

						tRestoreTargetBar:SetStatusBarColor(tRestoreStoredColor["R"] or 0, tRestoreStoredColor["G"] or 0, tRestoreStoredColor["B"] or 0, tRestoreOpacity);
					end

					VUHDO_showOverlayFillChainBackgroundForData(aContainerData);
				end
			end
		end

		aContainerData["ownsBackgroundFill"] = nil;
		aContainerData["backgroundFillHidden"] = nil;
		aContainerData["chainBaselineFrame"] = nil;
		aContainerData["chainBaselineTexture"] = nil;

		return;

	end




	--
	local tContainerData;
	local tOverlayTargetBar;
	local tContainerParent;
	function VUHDO_acquireAuraContainer(aButton, aContainerTemplate)

		if not aButton or not aContainerTemplate then
			return nil;
		end

		if aContainerTemplate["isOverlay"] then
			tOverlayTargetBar = aContainerTemplate["overlayTargetBar"];

			if tOverlayTargetBar then
				tContainerParent = tOverlayTargetBar["VuhDoOverlayHostFrame"] or aContainerTemplate["overlayHostFrame"];

				if tContainerParent and tContainerParent:GetName() then
				elseif tOverlayTargetBar:GetName() then
					tContainerParent = tOverlayTargetBar;
				else
					tContainerParent = aButton;
				end
			else
				tContainerParent = aButton;
			end
		else
			tContainerParent = aButton;
		end

		aContainerTemplate["parent"] = tContainerParent;

		VUHDO_AURA_CONTAINER_METRICS["builds"]["container"] = (VUHDO_AURA_CONTAINER_METRICS["builds"]["container"] or 0) + 1;


		tContainerData = VUHDO_buildManagedAuraContainer(aContainerTemplate);

		if tContainerData then
			tContainerData["ownerButton"] = aButton;
			tContainerData["buildSignature"] = VUHDO_getAuraContainerBuildSignature(aContainerTemplate);
			tContainerData["filterSignature"] = VUHDO_getAuraContainerFilterSignature(aContainerTemplate);
			tContainerData["appliedVolatileSignature"] = VUHDO_getAuraContainerVolatileSignature(aContainerTemplate);
			tContainerData["pendingVolatileSignature"] = nil;
		end

		return tContainerData;

	end



	--
	local tContainer;
	function VUHDO_retireAuraContainer(aButton, aContainerData)

		if not aContainerData or not aContainerData["container"] then
			return;
		end

		VUHDO_restoreOverlayFillChainBackground(aContainerData);
		VUHDO_restoreMissingBuffBar(aContainerData);

		VUHDO_AURA_CONTAINER_METRICS["releases"]["container"] = (VUHDO_AURA_CONTAINER_METRICS["releases"]["container"] or 0) + 1;


		tContainer = aContainerData["container"];

		VUHDO_clearAuraContainerUnit(tContainer, aContainerData);

		sContainerClassColorBars[tContainer] = nil;
		sPendingClassColors[tContainer] = nil;
		sPendingClassColorRetry[tContainer] = nil;

		tContainer:Hide();
		tContainer:SetParent(nil);

		aContainerData["container"] = nil;

		return;

	end
end




do
	--
	local tFrame;
	local tEmptyMask;
	local tFillMask;
	function VUHDO_restoreMissingBuffBar(aContainerData)

		if not aContainerData then
			return;
		end

		tFrame = aContainerData["missingBuffBarFrame"];

		if tFrame then
			tEmptyMask = tFrame["EmptyMask"];
			tFillMask = tFrame["FillMask"];

			if tEmptyMask then
				tEmptyMask:ClearAllPoints();
			end

			if tFillMask then
				tFillMask:ClearAllPoints();
			end

			tFrame:ClearAllPoints();
			tFrame:Hide();
		end

		aContainerData["missingBuffBarFrame"] = nil;
		aContainerData["missingBuffBarTexture"] = nil;
		aContainerData["missingBuffCategName"] = nil;
		aContainerData["missingBuffSlotIndex"] = nil;

		return;

	end
end


do
	--
	local tHostData;
	local tContainer;
	local tSlotHostFrameName;
	function VUHDO_getOrCreateOverlaySlotHost(aButton, aButtonName)

		if not aButton or not aButtonName then
			return nil;
		end

		tHostData = VUHDO_OVERLAY_SLOT_HOSTS[aButtonName];

		if tHostData and tHostData["container"] then
			return tHostData;
		end

		if InCombatLockdown() then
			return nil;
		end

		tSlotHostFrameName = aButtonName .. "OlSlotHost";
		tContainer = aButton["VuhDoOverlaySlotHost"];

		if not tContainer then
			tContainer = _G[tSlotHostFrameName];
		end

		if not tContainer then
			tContainer = CreateFrame("AuraContainer", tSlotHostFrameName, aButton, VUHDO_AURA_CONTAINER_TEMPLATE);

			VUHDO_AURA_CONTAINER_METRICS["builds"]["slotHost"] = (VUHDO_AURA_CONTAINER_METRICS["builds"]["slotHost"] or 0) + 1;
		end

		tContainer:ClearAllPoints();
		tContainer:SetAllPoints(aButton);
		tContainer:SetMouseClickEnabled(false);
		tContainer:EnableMouse(false);
		tContainer:SetMouseMotionEnabled(false);
		tContainer:SetEnabled(false);
		tContainer:SetShown(false);

		aButton["VuhDoOverlaySlotHost"] = tContainer;

		tHostData = {
			["container"] = tContainer,
			["slotRecords"] = { },
			["slotRecordsByFamily"] = { },
			["slotOrder"] = { },
			["plannedSlots"] = { },
			["lastSyncedSlotEnabled"] = { },
			["lastSyncedUnit"] = nil,
			["lastSyncedGuid"] = nil,
			["suppressedSlotCount"] = 0,
		};

		VUHDO_OVERLAY_SLOT_HOSTS[aButtonName] = tHostData;

		return tHostData;

	end



	--
	local tContainer;
	local tSlotRecord;
	function VUHDO_suppressOverlaySlotHostSlot(aHostData, aSlotKey)

		if not aHostData or not aSlotKey then
			return;
		end

		tContainer = aHostData["container"];

		if not tContainer or not aHostData["slotRecords"][aSlotKey] then
			return;
		end

		tSlotRecord = aHostData["slotRecords"][aSlotKey];

		if tSlotRecord["appliedSuppress"] then
			return;
		end

		tContainer:SetAuraSlotFilterString(aSlotKey, "");

		tSlotRecord["appliedFilterString"] = "";
		tSlotRecord["appliedSuppress"] = true;

		aHostData["suppressedSlotCount"] = (aHostData["suppressedSlotCount"] or 0) + 1;

		VUHDO_stopOverlayThreatMarkFlashForSlotRecord(tSlotRecord);

		if not aHostData["lastSyncedSlotEnabled"] then
			aHostData["lastSyncedSlotEnabled"] = { };
		end

		aHostData["lastSyncedSlotEnabled"][aSlotKey] = false;

		VUHDO_updateOverlaySuppressedSlotMetrics();

		return;

	end



	--
	local tHostData;
	local tContainer;
	function VUHDO_disableOverlaySlotHost(aButtonName)

		tHostData = VUHDO_OVERLAY_SLOT_HOSTS[aButtonName];

		if not tHostData or not tHostData["container"] then
			return;
		end

		tContainer = tHostData["container"];

		for tDisableSlotKey, tDisableSlotRecord in pairs(tHostData["slotRecords"]) do
			VUHDO_stopOverlayThreatMarkFlashForSlotRecord(tDisableSlotRecord);
		end

		if tContainer:IsEnabled() then
			tContainer:SetEnabled(false);
		end

		if tContainer:IsShown() then
			tContainer:SetShown(false);
		end

		if tContainer:GetUnit() ~= "none" then
			tContainer:SetUnit("none");
		end

		tContainer:SetOnUpdateMode(VUHDO_ON_UPDATE_MODE_RUN_ONCE);

		tHostData["lastSyncedUnit"] = nil;
		tHostData["lastSyncedGuid"] = nil;

		if tHostData["lastSyncedSlotEnabled"] then
			twipe(tHostData["lastSyncedSlotEnabled"]);
		end

		if tHostData["plannedSlots"] then
			twipe(tHostData["plannedSlots"]);
		end

		return;

	end



	--
	local tContainer;
	function VUHDO_clearOverlaySlotHostUnit(aHostData)

		if not aHostData or not aHostData["container"] then
			return;
		end

		tContainer = aHostData["container"];

		for tClearSlotKey, tClearSlotRecord in pairs(aHostData["slotRecords"] or sEmpty) do
			VUHDO_stopOverlayThreatMarkFlashForSlotRecord(tClearSlotRecord);
		end

		if tContainer:IsEnabled() then
			tContainer:SetEnabled(false);
		end

		if tContainer:IsShown() then
			tContainer:SetShown(false);
		end

		if tContainer:GetUnit() ~= "none" then
			tContainer:SetUnit("none");
		end

		tContainer:SetOnUpdateMode(VUHDO_ON_UPDATE_MODE_RUN_ONCE);

		aHostData["lastSyncedUnit"] = nil;
		aHostData["lastSyncedGuid"] = nil;

		if aHostData["lastSyncedSlotEnabled"] then
			twipe(aHostData["lastSyncedSlotEnabled"]);
		end

		aHostData["lastHostGated"] = true;

		return;

	end
end



do
	--
	local tCount;
	local tTotal;
	local tMax;
	function VUHDO_updateOverlaySuppressedSlotMetrics()

		tTotal = 0;
		tMax = 0;

		for _, tHostData in pairs(VUHDO_OVERLAY_SLOT_HOSTS or sEmpty) do
			tCount = tHostData["suppressedSlotCount"] or 0;

			tTotal = tTotal + tCount;

			if tCount > tMax then
				tMax = tCount;
			end
		end

		if not VUHDO_AURA_CONTAINER_METRICS["runtime"] then
			VUHDO_AURA_CONTAINER_METRICS["runtime"] = { };
		end

		VUHDO_AURA_CONTAINER_METRICS["runtime"]["suppressedOverlaySlots"] = tTotal;
		VUHDO_AURA_CONTAINER_METRICS["runtime"]["maxHostSuppressedOverlaySlots"] = tMax;

		return;

	end

end



--
function VUHDO_resetAuraContainerMetrics()

	twipe(VUHDO_AURA_CONTAINER_METRICS["builds"]);
	twipe(VUHDO_AURA_CONTAINER_METRICS["releases"]);
	twipe(VUHDO_AURA_CONTAINER_METRICS["runtime"]);

	VUHDO_Msg("Aura container metrics reset.");

	return;

end



--
function VUHDO_printAuraContainerMetrics()

	VUHDO_Msg("|cffFFD100--- Aura Container Metrics ---|r");

	VUHDO_Msg(format("|cffFFA500** Containers:|r |cff98FB98Builds=|r%d |cff98FB98Releases=|r%d",
		VUHDO_AURA_CONTAINER_METRICS["builds"]["container"] or 0,
		VUHDO_AURA_CONTAINER_METRICS["releases"]["container"] or 0));
	VUHDO_Msg(format("|cffFFA500** Overlay Slots:|r |cff98FB98SlotHosts=|r%d |cff98FB98Slots=|r%d |cff98FB98Suppressed=|r%d |cff98FB98MaxHostSuppressed=|r%d",
		VUHDO_AURA_CONTAINER_METRICS["builds"]["slotHost"] or 0,
		VUHDO_AURA_CONTAINER_METRICS["builds"]["overlaySlot"] or 0,
		VUHDO_AURA_CONTAINER_METRICS["runtime"]["suppressedOverlaySlots"] or 0,
		VUHDO_AURA_CONTAINER_METRICS["runtime"]["maxHostSuppressedOverlaySlots"] or 0));

	VUHDO_Msg("|cffFFD100--- End of Metrics ---|r");

	return;

end



--
function VUHDO_getOverlayChainBaselineStoredColor(aButtonName)

	if not aButtonName then
		return nil;
	end

	return sChainBaselineColors[aButtonName];

end



--
local tBaselineButtonName;
local tBaselineStoredColor;
local tBaselineIndicatorEntry;
local tBaselineContainerData;
local tBaselineTexture;
local tBaselineOpacity;
local tBaselineColorChanged;
function VUHDO_setOverlayChainBaselineColor(aButton, aColor)

	if not aButton or not aColor then
		return;
	end

	tBaselineButtonName = aButton:GetName();

	if not tBaselineButtonName then
		return;
	end

	tBaselineStoredColor = sChainBaselineColors[tBaselineButtonName];

	tBaselineColorChanged = not tBaselineStoredColor
		or tBaselineStoredColor["R"] ~= (aColor["R"] or 0)
		or tBaselineStoredColor["G"] ~= (aColor["G"] or 0)
		or tBaselineStoredColor["B"] ~= (aColor["B"] or 0)
		or tBaselineStoredColor["O"] ~= (aColor["O"] == nil and 1 or aColor["O"]);

	if tBaselineColorChanged then
		if not tBaselineStoredColor then
			tBaselineStoredColor = { };

			sChainBaselineColors[tBaselineButtonName] = tBaselineStoredColor;
		end

		tBaselineStoredColor["R"] = aColor["R"] or 0;
		tBaselineStoredColor["G"] = aColor["G"] or 0;
		tBaselineStoredColor["B"] = aColor["B"] or 0;
		tBaselineStoredColor["O"] = aColor["O"];

		if tBaselineStoredColor["O"] == nil then
			tBaselineStoredColor["O"] = 1;
		end
	end

	tBaselineIndicatorEntry = VUHDO_OVERLAY_CONTAINERS[tBaselineButtonName] and VUHDO_OVERLAY_CONTAINERS[tBaselineButtonName]["BACKGROUND_BAR"];
	tBaselineContainerData = tBaselineIndicatorEntry and tBaselineIndicatorEntry["fillChain"];
	tBaselineTexture = tBaselineContainerData and tBaselineContainerData["chainBaselineTexture"];

	if tBaselineTexture and not tBaselineTexture:IsForbidden() then
		tBaselineStoredColor = sChainBaselineColors[tBaselineButtonName];
		tBaselineOpacity = tBaselineStoredColor and tBaselineStoredColor["O"];

		if tBaselineOpacity == nil then
			tBaselineOpacity = 1;
		end

		tBaselineTexture:SetColorTexture(tBaselineStoredColor["R"] or 0, tBaselineStoredColor["G"] or 0, tBaselineStoredColor["B"] or 0, tBaselineOpacity);
	end

	return;

end



--
local tShowFillTargetBar;
local tShowFillTargetTexture;
local tShowChainBaselineFrame;
function VUHDO_showOverlayFillChainBackgroundForData(aContainerData)

	if not aContainerData or not aContainerData["ownsBackgroundFill"] then
		return;
	end

	if not aContainerData["backgroundFillHidden"] then
		return;
	end

	tShowFillTargetBar = aContainerData["overlayTargetBar"];

	if not tShowFillTargetBar then
		return;
	end

	tShowFillTargetTexture = tShowFillTargetBar:GetStatusBarTexture();

	if tShowFillTargetTexture then
		tShowFillTargetTexture:SetAlpha(1);
	end

	tShowChainBaselineFrame = aContainerData["chainBaselineFrame"];

	if tShowChainBaselineFrame then
		tShowChainBaselineFrame:Hide();
	end

	aContainerData["backgroundFillHidden"] = nil;

	return;

end



--
local tHideFillTargetBar;
local tHideFillTargetTexture;
local tHideChainBaselineFrame;
function VUHDO_hideOverlayFillChainBackgroundForData(aContainerData)

	if not aContainerData or not aContainerData["ownsBackgroundFill"] then
		return;
	end

	if not aContainerData["lastSyncedEnabled"] then
		return;
	end

	tHideFillTargetBar = aContainerData["overlayTargetBar"];

	if not tHideFillTargetBar then
		return;
	end

	tHideFillTargetTexture = tHideFillTargetBar:GetStatusBarTexture();

	if tHideFillTargetTexture then
		tHideFillTargetTexture:SetAlpha(0);
	end

	tHideChainBaselineFrame = aContainerData["chainBaselineFrame"];

	if tHideChainBaselineFrame then
		tHideChainBaselineFrame:Show();
	end

	aContainerData["backgroundFillHidden"] = true;

	return;

end



--
local tHideFillButtonName;
local tHideFillIndicatorEntry;
local tHideFillContainerData;
function VUHDO_showOverlayFillChainBackground(aButton)

	if not aButton then
		return;
	end

	tHideFillButtonName = aButton:GetName();

	if not tHideFillButtonName then
		return;
	end

	tHideFillIndicatorEntry = VUHDO_OVERLAY_CONTAINERS[tHideFillButtonName] and VUHDO_OVERLAY_CONTAINERS[tHideFillButtonName]["BACKGROUND_BAR"];
	tHideFillContainerData = tHideFillIndicatorEntry and tHideFillIndicatorEntry["fillChain"];

	VUHDO_showOverlayFillChainBackgroundForData(tHideFillContainerData);

	return;

end



--
function VUHDO_hideOverlayFillChainBackground(aButton)

	if not aButton then
		return;
	end

	tHideFillButtonName = aButton:GetName();

	if not tHideFillButtonName then
		return;
	end

	tHideFillIndicatorEntry = VUHDO_OVERLAY_CONTAINERS[tHideFillButtonName] and VUHDO_OVERLAY_CONTAINERS[tHideFillButtonName]["BACKGROUND_BAR"];
	tHideFillContainerData = tHideFillIndicatorEntry and tHideFillIndicatorEntry["fillChain"];

	VUHDO_hideOverlayFillChainBackgroundForData(tHideFillContainerData);

	return;

end



--
local tBaselineStoredColor;
local tBaselineTexture;
local tBaselineOpacity;
function VUHDO_applyStoredChainBaselineColor(aButtonName, aContainerData)

	if not aButtonName or not aContainerData then
		return;
	end

	tBaselineStoredColor = sChainBaselineColors[aButtonName];
	tBaselineTexture = aContainerData["chainBaselineTexture"];

	if not tBaselineTexture or tBaselineTexture:IsForbidden() then
		return;
	end

	if tBaselineStoredColor then
		tBaselineOpacity = tBaselineStoredColor["O"];

		if tBaselineOpacity == nil then
			tBaselineOpacity = 1;
		end

		tBaselineTexture:SetColorTexture(tBaselineStoredColor["R"] or 0, tBaselineStoredColor["G"] or 0, tBaselineStoredColor["B"] or 0, tBaselineOpacity);
	else
		tBaselineTexture:SetColorTexture(0, 0, 0, 0);
	end

	return;

end



do
	--
	local tSourceTexture;
	local tSourceFile;
	local tSourceAtlas;
	function VUHDO_copyMissingBuffBarTexture(aDestTexture, aSourceBar)

		if "StatusBar" ~= aSourceBar:GetObjectType() then
			return;
		end

		tSourceTexture = aSourceBar:GetStatusBarTexture();

		if not tSourceTexture then
			return;
		end

		tSourceAtlas = tSourceTexture:GetAtlas();

		if tSourceAtlas then
			aDestTexture:SetAtlas(tSourceAtlas);
		else
			tSourceFile = tSourceTexture:GetTexture();

			if not tSourceFile then
				return;
			end

			aDestTexture:SetTexture(tSourceFile, "CLAMP", "CLAMP", "NEAREST");
		end

		aDestTexture:SetTexCoord(0, 1, 0, 1);

		VUHDO_PixelUtil.ApplySettings(aDestTexture);

		return true;

	end
end



do
	--
	local tBarTexture;
	local tFrame;
	local tTargetBar;
	local tContainer;
	local tFillMask;
	local tEmptyMask;
	local tTargetTexture;
	local tTextureKey;
	local tSourceAtlas;
	local tSourceFile;
	local tCopySucceeded;
	local tBarTopInset;
	local tMaskHeight;
	function VUHDO_refreshMissingBuffBarFill(aContainerData, anForceTextureCopy)

		if not aContainerData then
			return;
		end

		tBarTexture = aContainerData["missingBuffBarTexture"];
		tFrame = aContainerData["missingBuffBarFrame"];
		tTargetBar = aContainerData["overlayTargetBar"];
		tContainer = aContainerData["container"];
		tFillMask = tFrame and tFrame["FillMask"];
		tEmptyMask = tFrame and tFrame["EmptyMask"];

		tTextureKey = nil;
		tTargetTexture = tTargetBar and tTargetBar:GetStatusBarTexture();

		if tTargetTexture then
			tSourceAtlas = tTargetTexture:GetAtlas();

			if tSourceAtlas then
				tTextureKey = "a:" .. tSourceAtlas;
			else
				tSourceFile = tTargetTexture:GetTexture();
				tTextureKey = "f:" .. tostring(tSourceFile);
			end
		end

		if anForceTextureCopy or tTextureKey ~= aContainerData["missingBuffLastTextureKey"] then
			tCopySucceeded = false;

			if tBarTexture and tTargetBar then
				tCopySucceeded = VUHDO_copyMissingBuffBarTexture(tBarTexture, tTargetBar);
			end

			if tCopySucceeded then
				aContainerData["missingBuffLastTextureKey"] = tTextureKey;
			else
				aContainerData["missingBuffLastTextureKey"] = nil;
			end
		end

		if tFillMask and tTargetBar then
			tTargetTexture = tTargetBar:GetStatusBarTexture();

			tFillMask:ClearAllPoints();

			if tTargetTexture then
				tFillMask:SetAllPoints(tTargetTexture);
			end
		end

		if tEmptyMask and tContainer and tTargetBar then
			tBarTopInset = VUHDO_PixelUtil.RoundToPixel(1, 1);
			tMaskHeight = tTargetBar:GetHeight() + tBarTopInset + 1;

			tEmptyMask:ClearAllPoints();

			VUHDO_PixelUtil.SetPoint(tEmptyMask, "TOPLEFT", tContainer, "BOTTOMLEFT", 0, tBarTopInset);
			VUHDO_PixelUtil.SetPoint(tEmptyMask, "TOPRIGHT", tContainer, "BOTTOMRIGHT", 0, tBarTopInset);
			VUHDO_PixelUtil.SetHeight(tEmptyMask, tMaskHeight);
		end

		return;

	end
end



do
	--
	local tColorKey;
	function VUHDO_setMissingBuffBarColor(aButtonName, aCategName, aColor)

		if not aButtonName or not aCategName or not aColor then
			return;
		end

		tColorKey = aButtonName .. ":" .. aCategName;

		if not sMissingBuffBarColors[tColorKey] then
			sMissingBuffBarColors[tColorKey] = { };
		end

		sMissingBuffBarColors[tColorKey]["R"] = aColor["R"] or 0;
		sMissingBuffBarColors[tColorKey]["G"] = aColor["G"] or 0;
		sMissingBuffBarColors[tColorKey]["B"] = aColor["B"] or 0;
		sMissingBuffBarColors[tColorKey]["O"] = aColor["O"];
		sMissingBuffBarColors[tColorKey]["useBackground"] = aColor["useBackground"];

		if sMissingBuffBarColors[tColorKey]["O"] == nil then
			sMissingBuffBarColors[tColorKey]["O"] = 1;
		end

		return;

	end
end



do
	--
	local tColorKey;
	local tStoredColor;
	local tBarTexture;
	local tBarOpacity;
	function VUHDO_applyStoredMissingBuffBarColor(aButtonName, aCategName, aContainerData)

		if not aButtonName or not aCategName or not aContainerData then
			return;
		end

		tColorKey = aButtonName .. ":" .. aCategName;
		tStoredColor = sMissingBuffBarColors[tColorKey];
		tBarTexture = aContainerData["missingBuffBarTexture"];

		if not tBarTexture or tBarTexture:IsForbidden() then
			return;
		end

		if tStoredColor and tStoredColor["useBackground"] ~= false then
			tBarOpacity = tStoredColor["O"];

			if tBarOpacity == nil then
				tBarOpacity = 1;
			end

			tBarTexture:SetVertexColor(tStoredColor["R"] or 0, tStoredColor["G"] or 0, tStoredColor["B"] or 0, tBarOpacity);
		else
			tBarTexture:SetVertexColor(0, 0, 0, 0);
		end

		return;

	end
end



do
	--
	local tFrame;
	function VUHDO_setMissingBuffBarShown(aContainerData, anIsShown)

		tFrame = aContainerData and aContainerData["missingBuffBarFrame"];

		if tFrame then
			tFrame:SetShown(anIsShown and true or false);
		end

		return;

	end
end



--
function VUHDO_invalidateAuraContainerTemplateCache()

	_G["VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION"] = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION + 1;
	VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION = _G["VUHDO_AURA_CONTAINER_TEMPLATE_CACHE_VERSION"];

	twipe(VUHDO_AURA_CONTAINER_TEMPLATE_CACHE);

	VUHDO_invalidateAuraGroupFilterCache();

	VUHDO_incrementAuraAnchorConfigVersion();

	return;

end



--
function VUHDO_applyBarButtonSetupFields(aButtonSetup, anAnchorConfig)

	aButtonSetup["durationBar"] = true;
	aButtonSetup["durationBarOptions"] = {
		["direction"] = anAnchorConfig["barInvertGrowth"] and Enum.StatusBarTimerDirection.ElapsedTime
			or Enum.StatusBarTimerDirection.RemainingTime,
	};

	if anAnchorConfig["barVertical"] then
		aButtonSetup["durationBarOrientation"] = anAnchorConfig["barTurnAxis"] and VUHDO_STATUSBAR_TOP_TO_BOTTOM or VUHDO_STATUSBAR_BOTTOM_TO_TOP;
	else
		aButtonSetup["durationBarOrientation"] = anAnchorConfig["barTurnAxis"] and VUHDO_STATUSBAR_RIGHT_TO_LEFT or VUHDO_STATUSBAR_LEFT_TO_RIGHT;
	end

	return;

end



--
local tDispelBorder;
local tShowTooltip;
local tButtonSetup;
local tDurationMode;
local tTimerThreshold;
local tIconTextSize;
local tIconType;
function VUHDO_buildAnchorButtonSetup(anAnchorConfig, aPixelWidth, aPixelHeight, anIsBar, aGroup, aBarWidth, aBarHeight)

	tDispelBorder = VUHDO_resolveAuraTriState(anAnchorConfig["dispelBorder"], "dispelBorder");
	tShowTooltip = VUHDO_resolveAuraTriState(anAnchorConfig["showTooltip"], "showTooltip");

	tDurationMode, tTimerThreshold = VUHDO_resolveGroupTimerSettings(aGroup);

	tIconType = anAnchorConfig["iconType"] or 1;

	tButtonSetup = {
		["dispelBorder"] = tDispelBorder,
		["auraSymbol"] = tDispelBorder,
		["borderWidth"] = tDispelBorder and 2 or nil,
		["durationText"] = VUHDO_resolveAuraTriState(anAnchorConfig["showTimer"], "showTimer"),
		["durationCooldown"] = VUHDO_resolveAuraTriState(anAnchorConfig["showClock"], "showClock"),
		["durationBar"] = false,
		["hideIcon"] = tIconType >= 4,
		["applicationCount"] = VUHDO_resolveAuraTriState(anAnchorConfig["showStacks"], "showStacks"),
		["mouseMotion"] = tShowTooltip,
		["disableMouse"] = not tShowTooltip,
		["width"] = aPixelWidth,
		["height"] = aPixelHeight,
		["textSize"] = aPixelHeight or 20,
		["textConfig"] = {
			["TIMER_TEXT"] = anAnchorConfig["TIMER_TEXT"],
			["COUNTER_TEXT"] = anAnchorConfig["COUNTER_TEXT"],
		},
	};

	tButtonSetup["durationMode"] = tDurationMode;
	tButtonSetup["timerThreshold"] = tTimerThreshold;

	if tButtonSetup["durationText"] then
		tButtonSetup["durationTextOptions"] = {
			["textFormatter"] = VUHDO_getAuraTimerFormatter(tDurationMode, tTimerThreshold),
			["textColor"] = {
				["curve"] = VUHDO_getAuraTimerColorCurve(tDurationMode, tTimerThreshold),
				["property"] = Enum.DurationTextBindingProperty.RemainingDuration,
			},
		};
	end

	if tIconType == 2 then
		tButtonSetup["staticIcon"] = "Interface\\AddOns\\VuhDo\\Images\\icon_white_square";
	elseif tIconType == 3 then
		tButtonSetup["staticIcon"] = "Interface\\AddOns\\VuhDo\\Images\\hot_flat_16_16";
	end

	if anIsBar then
		VUHDO_applyBarButtonSetupFields(tButtonSetup, anAnchorConfig);

		tButtonSetup["barVertical"] = anAnchorConfig["barVertical"] or false;
		tButtonSetup["barTurnAxis"] = anAnchorConfig["barTurnAxis"] or false;
		tButtonSetup["iconType"] = tIconType;
		tButtonSetup["barSegmentWidth"] = aBarWidth;
		tButtonSetup["barSegmentHeight"] = aBarHeight;

		if tButtonSetup["iconType"] ~= 5 and aBarWidth and aBarHeight then
			if tButtonSetup["barVertical"] then
				tIconTextSize = aBarWidth;
			else
				tIconTextSize = aBarHeight;
			end

			tButtonSetup["iconTextSize"] = tIconTextSize;
			tButtonSetup["textSize"] = tIconTextSize;
		end
	end

	return tButtonSetup;

end



--
local tContainerTemplate;
function VUHDO_createAuraContainer(aButton, anAnchorIndex, anAnchorConfig)

	tContainerTemplate = VUHDO_buildAnchorContainerTemplate(aButton, anAnchorIndex, anAnchorConfig);

	if not tContainerTemplate then
		return nil;
	end

	return VUHDO_acquireAuraContainer(aButton, tContainerTemplate);

end



do
	--
	local tPanelAnchors;
	local tTemplatePanelCache;
	function VUHDO_rebuildAuraAnchorsForGroups(aGroupIds)

		if not aGroupIds then
			return;
		end

		if VUHDO_isAuraModeContainers() then
			twipe(sDirtyAnchorPanels);

			for tPanelNum = 1, VUHDO_MAX_PANELS do
				tPanelAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

				if tPanelAnchors then
					for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
						if tAnchorConfig and tAnchorConfig["groupId"] and aGroupIds[tAnchorConfig["groupId"]] then
							tTemplatePanelCache = VUHDO_AURA_CONTAINER_TEMPLATE_CACHE[tPanelNum];

							if tTemplatePanelCache then
								tTemplatePanelCache[tAnchorIndex] = nil;
							end

							sDirtyAnchorPanels[tPanelNum] = true;
						end
					end
				end
			end

			for tButton, tPanelNum in pairs(VUHDO_BUTTON_CACHE) do
				if sDirtyAnchorPanels[tPanelNum] then
					VUHDO_deferInitAuraContainersForButton(tButton, tPanelNum);
				end
			end
		else
			VUHDO_invalidateAuraContainerTemplateCache();
			VUHDO_rebuildAuraAnchorsForAllButtons();
		end

		return;

	end
end



--
local tButtonName;
local tUnit;
local tPanelAnchors;
local tContainerData;
local tBuildSignature;
local tFilterSignature;
local tFilterContainer;
local tContainerTemplate;
local tVolatileAction;
function VUHDO_initAuraContainersForButton(aButton, aPanelNum)

	if not aButton or not aPanelNum then
		return;
	end

	if not aButton:CanBeAccessedInContext() then
		sPendingContainerBuilds[aButton] = aPanelNum;

		sHasPendingBuilds = true;

		return;
	end

	sPendingContainerBuilds[aButton] = nil;

	tPanelAnchors = VUHDO_PANEL_SETUP[aPanelNum] and VUHDO_PANEL_SETUP[aPanelNum]["AURA_ANCHORS"];

	if not tPanelAnchors then
		return;
	end

	tButtonName = aButton:GetName();

	if not tButtonName then
		return;
	end

	if not VUHDO_AURA_CONTAINERS[tButtonName] then
		VUHDO_AURA_CONTAINERS[tButtonName] = { };
	end

	twipe(sSeenAnchors);

	for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
		if tAnchorConfig and tAnchorConfig["enabled"] ~= false then
			tContainerTemplate = VUHDO_buildAnchorContainerTemplate(aButton, tAnchorIndex, tAnchorConfig);

			if tContainerTemplate then
				sSeenAnchors[tAnchorIndex] = true;
				tBuildSignature = VUHDO_getAuraContainerBuildSignature(tContainerTemplate);
				tContainerData = VUHDO_AURA_CONTAINERS[tButtonName][tAnchorIndex];

				if tContainerData and tContainerData["container"] and tContainerData["buildSignature"] == tBuildSignature and tContainerData["panelNum"] == aPanelNum then
					tContainerData["containerTemplate"] = tContainerTemplate;
					tContainerData["ownerButton"] = aButton;
					tContainerData["panelNum"] = aPanelNum;
					tContainerData["anchorIndex"] = tAnchorIndex;
					tContainerData["staticSlots"] = tContainerTemplate["staticSlots"] or VUHDO_collectStaticSlotsFromTemplate(tContainerTemplate);
					tContainerData["lastSlotSuppress"] = nil;
					tContainerData["lastGroupSuppress"] = nil;
					tContainerData["groupsSuppressed"] = nil;
					tContainerData["lastContainerSuppressed"] = nil;
					tContainerData["appliedSlotCandidateSuppress"] = nil;

					VUHDO_applyAuraContainerAnchor(tContainerData["container"], tContainerTemplate["anchor"], aButton);

					VUHDO_applyAuraContainerFadeParent(tContainerData["container"], aButton, tContainerTemplate);

					tFilterSignature = VUHDO_getAuraContainerFilterSignature(tContainerTemplate);
					tFilterContainer = tContainerData["container"];

					if tFilterContainer and tContainerData["filterSignature"] ~= tFilterSignature then
						VUHDO_applyAuraContainerFilterPass(tFilterContainer, tContainerData, tContainerTemplate);

						tContainerData["filterSignature"] = tFilterSignature;
					end

					tVolatileAction = VUHDO_reconcileAuraContainerVolatilePass(tFilterContainer, tContainerData, tContainerTemplate);

					if VUHDO_AURA_VOLATILE_PASS_REBUILD == tVolatileAction then
						VUHDO_retireAuraContainer(aButton, tContainerData);

						tContainerData = VUHDO_acquireAuraContainer(aButton, tContainerTemplate);

						if tContainerData then
							VUHDO_AURA_CONTAINERS[tButtonName][tAnchorIndex] = tContainerData;

							VUHDO_applyAuraContainerFadeParent(tContainerData["container"], aButton, tContainerTemplate);
						end
					elseif VUHDO_AURA_VOLATILE_PASS_DEFER == tVolatileAction then
						VUHDO_deferVolatilePassForButton(aButton);
					end
				else
					if tContainerData then
						VUHDO_retireAuraContainer(aButton, tContainerData);
					end

					tContainerData = VUHDO_acquireAuraContainer(aButton, tContainerTemplate);

					if tContainerData then
						VUHDO_AURA_CONTAINERS[tButtonName][tAnchorIndex] = tContainerData;

						VUHDO_applyAuraContainerFadeParent(tContainerData["container"], aButton, tContainerTemplate);
					end
				end
			end
		end
	end

	for tAnchorIndex, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
		if not sSeenAnchors[tAnchorIndex] then
			VUHDO_retireAuraContainer(aButton, tContainerData);

			VUHDO_AURA_CONTAINERS[tButtonName][tAnchorIndex] = nil;
		end
	end

	for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
		if tContainerData and tContainerData["staticSlots"] and next(tContainerData["staticSlots"]) then
			VUHDO_precomputeStaticBouquetSlotsForButton(aButton, tContainerData);
		end
	end

	tUnit = aButton["raidid"] or aButton:GetAttribute("unit");

	if tUnit then
		VUHDO_syncAuraContainersForButton(aButton, tUnit);
	end

	return;

end



--
local tVolatilePassButtonName;
local tVolatilePassContainer;
function VUHDO_applyVolatilePassForButton(aButton)

	if not aButton then
		return;
	end

	tVolatilePassButtonName = aButton:GetName();

	if not tVolatilePassButtonName then
		return;
	end

	for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tVolatilePassButtonName] or sEmpty) do
		tVolatilePassContainer = tContainerData and tContainerData["pendingVolatileSignature"] and tContainerData["container"];

		if tVolatilePassContainer then
			VUHDO_applyAuraContainerVolatilePass(tVolatilePassContainer, tContainerData);
		end
	end

	for _, tIndicatorEntry in pairs(VUHDO_OVERLAY_CONTAINERS[tVolatilePassButtonName] or sEmpty) do
		for _, tContainerData in pairs(tIndicatorEntry) do
			tVolatilePassContainer = tContainerData and tContainerData["pendingVolatileSignature"] and tContainerData["container"];

			if tVolatilePassContainer then
				VUHDO_applyAuraContainerVolatilePass(tVolatilePassContainer, tContainerData);
			end
		end
	end

	return;

end



do
	--
	local tCandidateFilters;
	function VUHDO_getTemplateIdentityGate(aTemplate)

		if not aTemplate then
			return nil;
		end

		tCandidateFilters = aTemplate["candidateFilters"];

		if not tCandidateFilters or not tCandidateFilters["includeSpellIDs"] then
			return nil;
		end

		if aTemplate["isHarmful"] then
			return VUHDO_AURA_IDENTITY_GATE_HARMFUL;
		end

		return VUHDO_AURA_IDENTITY_GATE_HELPFUL;

	end
end



do
	--
	local tFilterString;
	function VUHDO_isCompoundFilterStringTemplate(aTemplate)

		if not aTemplate then
			return false;
		end

		tFilterString = aTemplate["filterString"];

		if not tFilterString then
			return false;
		end

		if tFilterString == "HELPFUL" or tFilterString == "HARMFUL" then
			return false;
		end

		return true;

	end
end



do
	--
	local tUnitInfo;
	local tVisible;
	local tIsDeadOrGhost;
	function VUHDO_isUnitAuraFilterRestricted(aUnit)

		if not aUnit then
			return true;
		end

		tUnitInfo = VUHDO_RAID[aUnit];

		if not tUnitInfo and not VUHDO_isSpecialUnit(aUnit) then
			return true;
		end

		if tUnitInfo and not tUnitInfo["connected"] then
			return true;
		end

		tIsDeadOrGhost = UnitIsDeadOrGhost(aUnit);

		if issecretvalue(tIsDeadOrGhost) then
			return false;
		end

		if tIsDeadOrGhost then
			return true;
		end

		if not VUHDO_isSpecialUnit(aUnit) and VUHDO_unitPhaseReason(aUnit) then
			return true;
		end

		if tUnitInfo then
			tVisible = tUnitInfo["visible"];
		else
			tVisible = UnitIsVisible(aUnit);
		end

		if issecretvalue(tVisible) then
			return false;
		end

		if not tVisible then
			return true;
		end

		return false;

	end
end



do
	--
	local tUnitInfo;
	local tCanAssist;
	local tIsGroupMember;
	local tIdentityGate;
	function VUHDO_rewriteAuraContainerIdentityGates(aUnit)

		if not aUnit then
			sGateState["canApplyHelpfulIdentity"] = false;
			sGateState["canApplyHarmfulIdentity"] = false;

			return;
		end

		tCanAssist = UnitCanAssist("player", aUnit, true, true);

		if issecretvalue(tCanAssist) then
			tCanAssist = true;
		end

		tIsGroupMember = UnitIsPlayerControlledOrGroupMember(aUnit);

		if issecretvalue(tIsGroupMember) then
			tIsGroupMember = false;
		end

		sGateState["canApplyHelpfulIdentity"] = tIsGroupMember or tCanAssist;
		sGateState["canApplyHarmfulIdentity"] = not tCanAssist;

		return;

	end



	--
	function VUHDO_rewriteAuraContainerGateState(aUnit)

		tUnitInfo = VUHDO_RAID[aUnit];

		sGateState["canAttack"] = aUnit and UnitCanAttack("player", aUnit) or false;
		sGateState["isAuraFilterRestricted"] = VUHDO_isUnitAuraFilterRestricted(aUnit);
		sGateState["isDisconnected"] = tUnitInfo and tUnitInfo["connected"] == false;

		VUHDO_rewriteAuraContainerIdentityGates(aUnit);

		return;

	end



	--
	function VUHDO_isAuraDisplaySuppressed(aTemplateRef, aGateState)

		aGateState = aGateState or sGateState;

		if aGateState["isDisconnected"] or aGateState["isAuraFilterRestricted"] then
			return true;
		end

		tIdentityGate = aTemplateRef["identityGate"];

		if not tIdentityGate then
			return false;
		end

		if VUHDO_AURA_IDENTITY_GATE_HARMFUL == tIdentityGate then
			return not aGateState["canApplyHarmfulIdentity"];
		end

		return not aGateState["canApplyHelpfulIdentity"];

	end
end



do
	--
	local tContainerTemplate;
	local tGroupKeys;
	local tGroupTemplateRefs;
	local tGroupKey;
	local tGroup;
	local tTemplateRef;
	local tSlotKeys;
	local tSlotTemplateRefs;
	local tEngineSlotCnt;
	local tSlot;
	local tRecordedKey;
	local tMixedPriorityCutoffs;
	local tMixedEntryIndex;
	local tMixedItemIndex;
	local tPriorityCutoff;
	local tGroupShouldShow;
	local tSlotShouldShow;
	local tShouldSuppress;
	local tLastSlotSuppress;
	local tLastGroupSuppress;
	local tAppliedSlotCandidateSuppress;
	local tContainerSuppressed;
	local tIsDirty;
	local tRecoverGroupKey;
	local tNeedsRestoreEnable;
	function VUHDO_applyAuraContainerVisibility(aContainer, aContainerData)

		if not aContainer or not aContainerData then
			return false;
		end

		tContainerTemplate = aContainerData["containerTemplate"];

		if not tContainerTemplate then
			return false;
		end

		tMixedPriorityCutoffs = aContainerData["mixedPriorityCutoffs"];
		tGroupKeys = aContainerData["groupKeys"];
		tGroupTemplateRefs = aContainerData["groupTemplateRefs"];
		tLastSlotSuppress = aContainerData["lastSlotSuppress"];
		tLastGroupSuppress = aContainerData["lastGroupSuppress"];
		tAppliedSlotCandidateSuppress = aContainerData["appliedSlotCandidateSuppress"];
		tIsDirty = false;
		tNeedsRestoreEnable = false;

		tContainerSuppressed = sGateState["isDisconnected"] or sGateState["isAuraFilterRestricted"];

		if tContainerSuppressed then
			if not aContainerData["lastContainerSuppressed"] then
				tIsDirty = true;
			end

			if aContainer:IsEnabled() then
				aContainer:SetEnabled(false);
				tIsDirty = true;
			end

			aContainerData["lastContainerSuppressed"] = true;

			return tIsDirty;
		end

		if aContainerData["lastContainerSuppressed"] then
			if not aContainer:IsEnabled() then
				tNeedsRestoreEnable = true;
			end

			aContainerData["lastContainerSuppressed"] = nil;
			tIsDirty = true;

			if tGroupKeys and tGroupTemplateRefs and tLastGroupSuppress then
				for tRecoverGroupCnt = 1, #tGroupKeys do
					tRecoverGroupKey = tGroupKeys[tRecoverGroupCnt];

					if tRecoverGroupKey and tLastGroupSuppress[tRecoverGroupKey] then
						aContainer:SetAuraGroupMaxFrameCount(tRecoverGroupKey, 0);
					end
				end
			end

			if tLastSlotSuppress and tAppliedSlotCandidateSuppress then
				for tRecoverSlotKey, tRecoverWasSuppressed in pairs(tLastSlotSuppress) do
					if tRecoverWasSuppressed and tAppliedSlotCandidateSuppress[tRecoverSlotKey] then
						aContainer:SetAuraSlotFilterString(tRecoverSlotKey, "");
					end
				end
			end
		end

		if tGroupKeys and tGroupTemplateRefs then
			for tGroupCnt = 1, #tGroupKeys do
				tTemplateRef = tGroupTemplateRefs[tGroupCnt];
				tGroupKey = tGroupKeys[tGroupCnt];

				if tTemplateRef and tGroupKey then
					tGroup = tTemplateRef["template"];

					tGroupShouldShow = not VUHDO_isAuraDisplaySuppressed(tTemplateRef, sGateState);

					if tGroup["friendlyOnly"] and sGateState["canAttack"] then
						tGroupShouldShow = false;
					end

					if tGroup["hostileOnly"] and not sGateState["canAttack"] then
						tGroupShouldShow = false;
					end

					tShouldSuppress = not tGroupShouldShow;

					if not tLastGroupSuppress or tLastGroupSuppress[tGroupKey] ~= tShouldSuppress then
						if tGroupShouldShow then
							aContainer:SetAuraGroupMaxFrameCount(tGroupKey, tGroup["maxFrameCount"] or 5);
							aContainer:SetAuraGroupFilterString(tGroupKey, tGroup["filterString"] or "HELPFUL");
						else
							aContainer:SetAuraGroupMaxFrameCount(tGroupKey, 0);
						end

						if not tLastGroupSuppress then
							tLastGroupSuppress = { };
							aContainerData["lastGroupSuppress"] = tLastGroupSuppress;
						end

						tLastGroupSuppress[tGroupKey] = tShouldSuppress;
						tIsDirty = true;
					end
				end
			end
		end

		tSlotKeys = aContainerData["slotKeys"];
		tSlotTemplateRefs = aContainerData["slotTemplateRefs"];
		tEngineSlotCnt = 0;

		for tSlotCnt = 1, #(tContainerTemplate["slots"] or sEmpty) do
			tSlot = tContainerTemplate["slots"][tSlotCnt];

			if tSlot and not tSlot["isStaticBouquetSlot"] then
				tEngineSlotCnt = tEngineSlotCnt + 1;
				tTemplateRef = tSlotTemplateRefs and tSlotTemplateRefs[tEngineSlotCnt];
				tRecordedKey = tSlotKeys and tSlotKeys[tEngineSlotCnt];

				if tTemplateRef and tRecordedKey then
					tSlotShouldShow = not VUHDO_isAuraDisplaySuppressed(tTemplateRef, sGateState);

					if tSlot["friendlyOnly"] and sGateState["canAttack"] then
						tSlotShouldShow = false;
					end

					if tSlot["hostileOnly"] and not sGateState["canAttack"] then
						tSlotShouldShow = false;
					end

					tMixedEntryIndex = tSlot["mixedEntryIndex"];
					tMixedItemIndex = tSlot["mixedItemIndex"];
					tPriorityCutoff = tMixedPriorityCutoffs and tMixedEntryIndex and tMixedPriorityCutoffs[tMixedEntryIndex];

					if tMixedItemIndex and tPriorityCutoff and tMixedItemIndex > tPriorityCutoff then
						tSlotShouldShow = false;
					end

					tShouldSuppress = not tSlotShouldShow;

					if not tLastSlotSuppress or tLastSlotSuppress[tRecordedKey] ~= tShouldSuppress then
						if tSlotShouldShow then
							aContainer:SetAuraSlotFilterString(tRecordedKey, tSlot["filterString"] or "HELPFUL");
							aContainer:SetAuraSlotCandidateFilters(tRecordedKey, tSlot["candidateFilters"]);
						else
							aContainer:SetAuraSlotFilterString(tRecordedKey, "");
						end

						if not tLastSlotSuppress then
							tLastSlotSuppress = { };
							aContainerData["lastSlotSuppress"] = tLastSlotSuppress;
						end

						if not tAppliedSlotCandidateSuppress then
							tAppliedSlotCandidateSuppress = { };
							aContainerData["appliedSlotCandidateSuppress"] = tAppliedSlotCandidateSuppress;
						end

						tLastSlotSuppress[tRecordedKey] = tShouldSuppress;
						tAppliedSlotCandidateSuppress[tRecordedKey] = tShouldSuppress;

						tIsDirty = true;
					end
				end
			end
		end

		if tNeedsRestoreEnable then

			aContainer:SetEnabled(true);

			tIsDirty = true;
		end

		return tIsDirty;

	end
end



--
local tRestoreGroupsTemplate;
local tRestoreGroupsKeys;
local tRestoreGroup;
local tRestoreGroupKey;
function VUHDO_restoreAuraContainerGroups(aContainer, aContainerData)

	if not aContainer or not aContainerData or not aContainerData["groupsSuppressed"] then
		return;
	end

	tRestoreGroupsTemplate = aContainerData["containerTemplate"];

	if not tRestoreGroupsTemplate then
		return;
	end

	tRestoreGroupsKeys = aContainerData["groupKeys"];

	for tRestoreGroupCnt = 1, #(tRestoreGroupsTemplate["groups"] or sEmpty) do
		tRestoreGroup = tRestoreGroupsTemplate["groups"][tRestoreGroupCnt];
		tRestoreGroupKey = tRestoreGroupsKeys and tRestoreGroupsKeys[tRestoreGroupCnt];

		if tRestoreGroup and tRestoreGroupKey then
			aContainer:SetAuraGroupMaxFrameCount(tRestoreGroupKey, tRestoreGroup["maxFrameCount"] or 5);
			aContainer:SetAuraGroupFilterString(tRestoreGroupKey, tRestoreGroup["filterString"] or "HELPFUL");
		end
	end

	aContainerData["groupsSuppressed"] = nil;
	aContainerData["lastGroupSuppress"] = nil;
	aContainerData["lastSlotSuppress"] = nil;
	aContainerData["lastContainerSuppressed"] = nil;
	aContainerData["appliedSlotCandidateSuppress"] = nil;

	return;

end



--
local tButton;
function VUHDO_clearAuraContainerUnit(aContainer, aContainerData)

	if not aContainer then
		return;
	end

	if aContainerData and aContainerData["staticSlots"] and next(aContainerData["staticSlots"]) then
		tButton = aContainerData["ownerButton"];

		if not tButton then
			tButton = aContainer:GetParent();
		end

		if tButton then
			VUHDO_hideStaticBouquetSlotsForButton(tButton, aContainerData);
		end
	end


	if aContainer:IsEnabled() then
		aContainer:SetEnabled(false);
	end

	if aContainer:IsShown() then
		aContainer:SetShown(false);
	end

	if aContainer:GetUnit() ~= "none" then
		aContainer:SetUnit("none");
	end

	aContainer:SetOnUpdateMode(VUHDO_ON_UPDATE_MODE_RUN_ONCE);

	if aContainerData then
		aContainerData["lastSyncedUnit"] = nil;
		aContainerData["lastSyncedGuid"] = nil;
		aContainerData["lastSyncedRestricted"] = nil;
		aContainerData["lastSyncedEnabled"] = nil;
		aContainerData["lastSyncedGroupEnabled"] = nil;
		aContainerData["lastSlotSuppress"] = nil;
		aContainerData["lastGroupSuppress"] = nil;
		aContainerData["lastAuraFilterDenied"] = nil;
		aContainerData["lastHelpfulIdentity"] = nil;
		aContainerData["lastHarmfulIdentity"] = nil;
		aContainerData["lastContainerSuppressed"] = nil;
		aContainerData["appliedSlotCandidateSuppress"] = nil;
		aContainerData["mixedPriorityCutoffs"] = nil;
	end

	return;

end



--
local tClearBindingContainer;
function VUHDO_clearAuraContainerBinding(aContainerData)

	if not aContainerData or not aContainerData["container"] then
		return;
	end

	tClearBindingContainer = aContainerData["container"];


	if tClearBindingContainer:IsEnabled() then
		tClearBindingContainer:SetEnabled(false);
	end

	if tClearBindingContainer:GetUnit() ~= "none" then
		tClearBindingContainer:SetUnit("none");
	end

	if tClearBindingContainer:IsShown() then
		tClearBindingContainer:SetShown(false);
	end

	tClearBindingContainer:SetOnUpdateMode(VUHDO_ON_UPDATE_MODE_RUN_ONCE);

	aContainerData["lastSyncedUnit"] = nil;
	aContainerData["lastSyncedGuid"] = nil;
	aContainerData["lastSyncedEnabled"] = nil;
	aContainerData["lastSyncedGroupEnabled"] = nil;

	return;

end



--
function VUHDO_refreshAuraContainer(aContainer)

	if not aContainer or not aContainer:IsShown() then
		return false;
	end

	aContainer:UpdateAllAuras();

	return true;

end



--
local tIsAuraDataRestricted;
local tCanAttack;
local tOccupantGuid;
local tButton;
local tBindEnabled;
local tBindShown;
local tContainerSuppressed;
function VUHDO_bindAuraContainerUnit(aContainer, aContainerData, aUnit, aButton)

	if not aContainer or not aContainerData or not aUnit then
		return;
	end

	if aButton then
		aContainerData["ownerButton"] = aButton;
	end


	VUHDO_rewriteAuraContainerGateState(aUnit);

	tContainerSuppressed = sGateState["isDisconnected"] or sGateState["isAuraFilterRestricted"];
	tIsAuraDataRestricted = VUHDO_isAuraDataRestricted();

	if VUHDO_isAuraModeContainers() then
		if tContainerSuppressed then
			tBindEnabled = false;
			tBindShown = true;
		else
			tBindEnabled = true;
			tBindShown = true;
		end
	else
		tBindEnabled = tIsAuraDataRestricted;
		tBindShown = tIsAuraDataRestricted;
	end

	if aContainer:GetUnit() ~= aUnit then
		aContainer:SetUnit(aUnit);
	end

	aContainerData["lastSyncedRestricted"] = tIsAuraDataRestricted;

	VUHDO_applyContainerClassColorBars(aContainer, aUnit);

	if aContainerData["staticSlots"] and next(aContainerData["staticSlots"]) then
		tButton = aButton or aContainerData["ownerButton"];

		if not tButton then
			tButton = aContainer:GetParent();
		end

		if tButton then
			tCanAttack = UnitCanAttack("player", aUnit);

			VUHDO_updateStaticBouquetSlotsForButton(tButton, aUnit, aContainerData, tCanAttack);
		end
	end

	VUHDO_applyAuraContainerVisibility(aContainer, aContainerData);

	if aContainer:IsEnabled() ~= tBindEnabled then

		aContainer:SetEnabled(tBindEnabled);
	end

	if aContainer:IsShown() ~= tBindShown then

		aContainer:SetShown(tBindShown);
	end

	if not tContainerSuppressed then
		VUHDO_refreshAuraContainer(aContainer);
	end

	tOccupantGuid = VUHDO_RAID[aUnit] and VUHDO_RAID[aUnit]["guid"];

	if tOccupantGuid and issecretvalue(tOccupantGuid) then
		tOccupantGuid = nil;
	end

	aContainerData["lastSyncedUnit"] = aUnit;
	aContainerData["lastSyncedGuid"] = tOccupantGuid;
	aContainerData["lastHelpfulIdentity"] = sGateState["canApplyHelpfulIdentity"];
	aContainerData["lastHarmfulIdentity"] = sGateState["canApplyHarmfulIdentity"];

	return;

end



--
local tButtonName;
local tContainer;
local tNeedsSync;
local tIsAuraDataRestricted;
local tIsAuraFilterRestricted;
local tIsRestricted;
local tIsPreviouslyRestricted;
local tIsRestrictionRegained;
local tCanApplyHelpfulIdentity;
local tCanApplyHarmfulIdentity;
local tLastHelpfulIdentity;
local tLastHarmfulIdentity;
local tIdentityGateRegained;
local tOccupantGuid;
local tLastSyncedGuid;
local tVisibilityDirty;
function VUHDO_syncAuraContainersForButton(aButton, aUnit)

	if not aButton or not aUnit then
		return;
	end

	tButtonName = aButton:GetName();

	if not tButtonName or not VUHDO_AURA_CONTAINERS[tButtonName] then
		return;
	end

	tIsAuraDataRestricted = VUHDO_isAuraDataRestricted();

	VUHDO_rewriteAuraContainerGateState(aUnit);

	tIsAuraFilterRestricted = sGateState["isAuraFilterRestricted"];
	tIsRestricted = tIsAuraFilterRestricted;
	tCanApplyHelpfulIdentity = sGateState["canApplyHelpfulIdentity"];
	tCanApplyHarmfulIdentity = sGateState["canApplyHarmfulIdentity"];

	if not UnitExists(aUnit) then
		for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
			tContainer = tContainerData and tContainerData["container"];

			if tContainer then
				VUHDO_clearAuraContainerUnit(tContainer, tContainerData);
			end
		end

		return;
	end

	for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
		tContainer = tContainerData and tContainerData["container"];

		if tContainer then
			VUHDO_restoreAuraContainerGroups(tContainer, tContainerData);

			if VUHDO_isAuraModeContainers() then
				tContainerData["lastSyncedRestricted"] = tIsAuraDataRestricted;

				tNeedsSync = tContainerData["lastSyncedUnit"] ~= aUnit or not tContainer:IsEnabled() or not tContainer:IsShown();
			else
				tNeedsSync = tContainerData["lastSyncedUnit"] ~= aUnit or tContainerData["lastSyncedRestricted"] ~= tIsAuraDataRestricted or not tContainer:IsEnabled() or not tContainer:IsShown();
			end

			if not tNeedsSync then
				tOccupantGuid = VUHDO_RAID[aUnit] and VUHDO_RAID[aUnit]["guid"];
				tLastSyncedGuid = tContainerData["lastSyncedGuid"];

				if not tOccupantGuid or issecretvalue(tOccupantGuid) then
					tNeedsSync = true;
				elseif not tLastSyncedGuid or issecretvalue(tLastSyncedGuid) then
					tNeedsSync = true;
				elseif tLastSyncedGuid ~= tOccupantGuid then
					tNeedsSync = true;
				end
			end

			tLastHelpfulIdentity = tContainerData["lastHelpfulIdentity"];
			tLastHarmfulIdentity = tContainerData["lastHarmfulIdentity"];

			if not tNeedsSync and tLastHelpfulIdentity ~= nil and tLastHelpfulIdentity ~= tCanApplyHelpfulIdentity then
				tNeedsSync = true;
			end

			if not tNeedsSync and tLastHarmfulIdentity ~= nil and tLastHarmfulIdentity ~= tCanApplyHarmfulIdentity then
				tNeedsSync = true;
			end

			tIsPreviouslyRestricted = tContainerData["lastAuraFilterDenied"] == true;
			tIsRestrictionRegained = tIsPreviouslyRestricted and not tIsRestricted;

			tIdentityGateRegained = (tLastHelpfulIdentity == false and tCanApplyHelpfulIdentity)
				or (tLastHarmfulIdentity == false and tCanApplyHarmfulIdentity);

			tContainerData["lastAuraFilterDenied"] = tIsRestricted;
			tContainerData["lastHelpfulIdentity"] = tCanApplyHelpfulIdentity;
			tContainerData["lastHarmfulIdentity"] = tCanApplyHarmfulIdentity;

			if tNeedsSync then
				VUHDO_bindAuraContainerUnit(tContainer, tContainerData, aUnit, aButton);
			elseif tContainerData["staticSlots"] and next(tContainerData["staticSlots"]) then
				VUHDO_updateStaticBouquetSlotsForButton(aButton, aUnit, tContainerData, sGateState["canAttack"]);
			else
				tVisibilityDirty = VUHDO_applyAuraContainerVisibility(tContainer, tContainerData);

				if tVisibilityDirty or tIsRestrictionRegained or tIdentityGateRegained then
					VUHDO_refreshAuraContainer(tContainer);
				end
			end
		end
	end

	return;

end



--
function VUHDO_syncAuraContainersForUnit(aUnit)

	if not aUnit then
		return;
	end

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		VUHDO_syncAuraContainersForButton(tButton, aUnit);
	end

	return;

end



--
function VUHDO_syncAuraContainersForAllRaidUnits()

	if not VUHDO_RAID then
		return;
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_deferSyncAuraContainersForUnit(tUnit);
	end

	return;

end



--
function VUHDO_resetAuraContainersForUnit(aUnit)

	if not aUnit then
		return;
	end

	for _, tButton in pairs(VUHDO_getUnitButtonsSafe(aUnit)) do
		VUHDO_clearAuraContainersForButton(tButton);
	end

	return;

end



--
local tButtonName;
local tContainer;
function VUHDO_clearAuraContainersForButton(aButton)

	if not aButton then
		return;
	end

	tButtonName = aButton:GetName();

	if not tButtonName or not VUHDO_AURA_CONTAINERS[tButtonName] then
		return;
	end

	for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
		tContainer = tContainerData and tContainerData["container"];

		if tContainer then
			VUHDO_clearAuraContainerUnit(tContainer, tContainerData);
		end
	end

	return;

end



--
local tButtonName;
function VUHDO_releaseAuraContainersForButton(aButton)

	if not aButton then
		return;
	end

	sPendingContainerBuilds[aButton] = nil;

	tButtonName = aButton:GetName();

	if not tButtonName or not VUHDO_AURA_CONTAINERS[tButtonName] then
		return;
	end

	for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
		VUHDO_retireAuraContainer(aButton, tContainerData);
	end

	VUHDO_AURA_CONTAINERS[tButtonName] = nil;

	return;

end



--
function VUHDO_processPendingAuraContainerBuilds()

	if not sHasPendingBuilds then
		return;
	end

	if not InCombatLockdown() then
		for tButton, tPanelNum in pairs(sPendingContainerBuilds) do
			VUHDO_deferInitAuraContainersForButton(tButton, tPanelNum);
		end

		twipe(sPendingContainerBuilds);
	end

	for tContainer, tUnit in pairs(sPendingClassColors) do
		if not VUHDO_applyContainerClassColorBars(tContainer, tUnit) then
			sPendingClassColorRetry[tContainer] = tUnit;
		end
	end

	twipe(sPendingClassColors);

	for tRetryContainer, tRetryUnit in pairs(sPendingClassColorRetry) do
		sPendingClassColors[tRetryContainer] = tRetryUnit;
	end

	twipe(sPendingClassColorRetry);

	if not next(sPendingContainerBuilds) and not next(sPendingClassColors) then
		sHasPendingBuilds = false;
	end

	return;

end



--
local tPendingBuildCount;
function VUHDO_getPendingContainerBuildCount()

	tPendingBuildCount = 0;

	for _ in pairs(sPendingContainerBuilds) do
		tPendingBuildCount = tPendingBuildCount + 1;
	end

	return tPendingBuildCount;

end