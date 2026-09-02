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
	["showWhenHelpful"] = false,
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
local sSignatureParts = { };

local sBorderTexture;
local sBorderEdgeTop;
local sBorderEdgeBottom;
local sBorderEdgeLeft;
local sBorderEdgeRight;
local sBorderColorR;
local sBorderColorG;
local sBorderColorB;
local sBorderColorO;
local sBorderWidth;
local sBorderFile;



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
	function VUHDO_applyAuraButtonText(anButtonSetup, aAuraButton, aTextRegion, aFieldName)

		tTextConfig = anButtonSetup["textConfig"];

		if tTextConfig and tTextConfig[aFieldName] then
			if anButtonSetup["durationBar"] and aAuraButton["IconFrame"] and anButtonSetup["iconTextSize"] then
				tTextParent = aAuraButton["IconFrame"];
				tTextSize = anButtonSetup["iconTextSize"];
			else
				tTextParent = aAuraButton;
				tTextSize = anButtonSetup["textSize"] or 20;
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
	function VUHDO_layoutBarAuraButtonFrames(anButtonSetup, aAuraButton)

		if not anButtonSetup["durationBar"] or not aAuraButton["IconFrame"] then
			return true;
		end

		tIconSize = anButtonSetup["iconTextSize"];
		tBarWidth = anButtonSetup["barSegmentWidth"];
		tBarHeight = anButtonSetup["barSegmentHeight"];
		tBarVertical = anButtonSetup["barVertical"];
		tBarTurnAxis = anButtonSetup["barTurnAxis"];
		tIconFrame = aAuraButton["IconFrame"];
		tDurationBar = aAuraButton["DurationBar"];
		tIconTexture = aAuraButton["IconTexture"];
		tIconColorOverlay = aAuraButton["IconColorOverlay"];
		tDurationCooldown = aAuraButton["DurationCooldown"];

		if (anButtonSetup["iconType"] or 1) == 5 or not tIconSize or tIconSize <= 0 then
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

		if (anButtonSetup["iconType"] or 1) == 4 and tDurationBar then
			tDurationBar:ClearAllPoints();
			tDurationBar:SetAllPoints(aAuraButton);
		end

		if anButtonSetup["dispelBorder"] then
			VUHDO_bindAuraButtonDispelBorder(aAuraButton, anButtonSetup);
		elseif not anButtonSetup["dispelOverlayChrome"] then
			VUHDO_unbindAuraButtonDispelBorder(aAuraButton);
		end

		return true;

	end
end



do
	--
	local tSlot;
	function VUHDO_applyAuraButtonSublevelSlot(aTexture, anButtonSetup, anIndex, aFallbackLayer, aFallbackSublevel)

		if not aTexture then
			return;
		end

		tSlot = anButtonSetup["sublevelSlots"] and anButtonSetup["sublevelSlots"][anIndex];

		if tSlot then
			aTexture:SetDrawLayer(tSlot["layer"], tSlot["sublevel"]);
		else
			aTexture:SetDrawLayer(aFallbackLayer, aFallbackSublevel);
		end

		return;

	end
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
	function VUHDO_applyAuraButtonVolatileSetup(anButtonSetup, aAuraButton)

		if not anButtonSetup or not aAuraButton or not aAuraButton["ShadowBar"] then
			return;
		end

		tVolatileShadowBar = aAuraButton["ShadowBar"];

		if anButtonSetup["shadowValueMode"] == "duration" then
			tVolatileShadowBackground = tVolatileShadowBar["ShadowBackground"];

			if anButtonSetup["barOrientation"] then
				VUHDO_setStatusBarOrientation(tVolatileShadowBar, anButtonSetup["barOrientation"]);
			end

			if anButtonSetup["barTexture"] then
				VUHDO_setLlcStatusBarTexture(tVolatileShadowBar, anButtonSetup["barTexture"]);
			end

			if anButtonSetup["barInverted"] ~= nil then
				tVolatileShadowBar["isInverted"] = anButtonSetup["barInverted"];
			end

			if tVolatileShadowBackground and anButtonSetup["occlusionColor"] then
				tVolatileOcclusionColor = anButtonSetup["occlusionColor"];
				tVolatileShadowBackground:SetColorTexture(tVolatileOcclusionColor["R"] or 0, tVolatileOcclusionColor["G"] or 0, tVolatileOcclusionColor["B"] or 0, 1);

				VUHDO_applyAuraButtonSublevelSlot(tVolatileShadowBackground, anButtonSetup, 1, "ARTWORK", 1);

				tVolatileShadowBackground:Show();
			end

			tVolatileShadowTexture = tVolatileShadowBar:GetStatusBarTexture();

			if tVolatileShadowTexture then
				if anButtonSetup["dispelFill"] then
					tVolatileShadowTexture:SetVertexColor(1, 1, 1, 1);
				elseif anButtonSetup["staticColor"] then
					tVolatileStaticColor = anButtonSetup["staticColor"];
					tVolatileStaticAlpha = tVolatileStaticColor["O"] or 1;

					tVolatileShadowTexture:SetVertexColor(tVolatileStaticColor["R"] or 1, tVolatileStaticColor["G"] or 1, tVolatileStaticColor["B"] or 1, tVolatileStaticAlpha);
				end

				VUHDO_applyAuraButtonSublevelSlot(tVolatileShadowTexture, anButtonSetup, 2, "ARTWORK", 1);
			end
		else
			tVolatileFillTexture = aAuraButton["FillTexture"];

			if tVolatileFillTexture and anButtonSetup["targetBar"] then
				if not anButtonSetup["dispelFill"] then
					tVolatileFillMask = aAuraButton["VuhDoFillMask"];

					if tVolatileFillMask then
						tVolatileFillMask:ClearAllPoints();

						if anButtonSetup["shadowValueMode"] == "cover" then
							tVolatileFillMask:SetAllPoints(anButtonSetup["targetBar"]);
						else
							tVolatileFillMask:SetAllPoints(anButtonSetup["targetBar"]:GetStatusBarTexture());
						end
					end
				end

				if anButtonSetup["dispelFill"] then
					tVolatileFillBackground = aAuraButton["VuhDoFillBackground"];

					if tVolatileFillBackground then
						if anButtonSetup["dispelOpacity"] and "cover" ~= anButtonSetup["shadowValueMode"] then
							tVolatileFillBackground:Hide();
						else
							VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, anButtonSetup, 1, "ARTWORK", 1);
							tVolatileFillBackground:Show();
						end
					end

					VUHDO_copyStatusBarFillTexture(tVolatileFillTexture, anButtonSetup["targetBar"]);

					if anButtonSetup["barTexture"] then
						VUHDO_applyOverlayBarTextureToFill(tVolatileFillTexture, anButtonSetup["barTexture"]);
					end

					tVolatileFillTexture:SetVertexColor(1, 1, 1, 1);

					VUHDO_applyAuraButtonSublevelSlot(tVolatileFillTexture, anButtonSetup, 2, "ARTWORK", 1);
				else
					tVolatileFillBackground = aAuraButton["VuhDoFillBackground"];

					if tVolatileFillBackground then
						if anButtonSetup["staticColor"] then
							tVolatileStaticColor = anButtonSetup["staticColor"];
							tVolatileStaticAlpha = tVolatileStaticColor["O"] or 1;

							if tVolatileStaticAlpha < 1 then
								tVolatileFillBackground:Hide();
							else
								tVolatileFillBackground:SetColorTexture(tVolatileStaticColor["R"] or 1, tVolatileStaticColor["G"] or 1, tVolatileStaticColor["B"] or 1, 1);

								VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, anButtonSetup, 1, "ARTWORK", 1);

								tVolatileFillBackground:Show();
							end
						elseif anButtonSetup["occlusionColor"] then
							tVolatileOcclusionColor = anButtonSetup["occlusionColor"];
							tVolatileFillBackground:SetColorTexture(tVolatileOcclusionColor["R"] or 0, tVolatileOcclusionColor["G"] or 0, tVolatileOcclusionColor["B"] or 0, 1);

							VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, anButtonSetup, 1, "ARTWORK", 1);

							tVolatileFillBackground:Show();
						else
							tVolatileFillBackground:SetColorTexture(0, 0, 0, 1);

							VUHDO_applyAuraButtonSublevelSlot(tVolatileFillBackground, anButtonSetup, 1, "ARTWORK", 1);

							tVolatileFillBackground:Show();
						end
					end

					VUHDO_copyStatusBarFillTexture(tVolatileFillTexture, anButtonSetup["targetBar"]);

					if anButtonSetup["barTexture"] then
						VUHDO_applyOverlayBarTextureToFill(tVolatileFillTexture, anButtonSetup["barTexture"]);
					end

					if anButtonSetup["staticColor"] then
						tVolatileStaticColor = anButtonSetup["staticColor"];
						tVolatileStaticAlpha = tVolatileStaticColor["O"] or 1;

						tVolatileFillTexture:SetVertexColor(tVolatileStaticColor["R"] or 1, tVolatileStaticColor["G"] or 1, tVolatileStaticColor["B"] or 1, tVolatileStaticAlpha);
					end

					VUHDO_applyAuraButtonSublevelSlot(tVolatileFillTexture, anButtonSetup, 2, "ARTWORK", 1);
				end
			end
		end

		if anButtonSetup["targetFrameLevel"] then
			if anButtonSetup["shadowValueMode"] == "duration" then
				VUHDO_PixelUtil.SetFrameLevel(aAuraButton, anButtonSetup["targetFrameLevel"] + 1);
				VUHDO_PixelUtil.SetFrameLevel(tVolatileShadowBar, anButtonSetup["targetFrameLevel"]);
			else
				VUHDO_PixelUtil.SetFrameLevel(aAuraButton, anButtonSetup["targetFrameLevel"]);
			end
		end

		return;

	end
end



do
	--
	local tAnchorFrame;
	local function VUHDO_anchorAuraButtonBorderEdges(aAuraButton, anButtonSetup, anAnchorFrame)

		sBorderEdgeTop = aAuraButton["BorderEdgeTop"];
		sBorderEdgeBottom = aAuraButton["BorderEdgeBottom"];
		sBorderEdgeLeft = aAuraButton["BorderEdgeLeft"];
		sBorderEdgeRight = aAuraButton["BorderEdgeRight"];

		if not sBorderEdgeTop or not sBorderEdgeBottom or not sBorderEdgeLeft or not sBorderEdgeRight then
			return false;
		end

		tAnchorFrame = anAnchorFrame or aAuraButton;

		sBorderWidth = (anButtonSetup and anButtonSetup["borderWidth"]) or 1;
		sBorderFile = (anButtonSetup and anButtonSetup["borderFile"]) or "Interface\\AddOns\\VuhDo\\Images\\white_square_16_16";

		sBorderEdgeTop:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(sBorderEdgeTop, "TOPLEFT", tAnchorFrame, "TOPLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(sBorderEdgeTop, "TOPRIGHT", tAnchorFrame, "TOPRIGHT", 0, 0);
		sBorderEdgeTop:SetTexture(sBorderFile);
		VUHDO_PixelUtil.SetHeight(sBorderEdgeTop, sBorderWidth, 1);

		sBorderEdgeBottom:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(sBorderEdgeBottom, "BOTTOMLEFT", tAnchorFrame, "BOTTOMLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(sBorderEdgeBottom, "BOTTOMRIGHT", tAnchorFrame, "BOTTOMRIGHT", 0, 0);
		sBorderEdgeBottom:SetTexture(sBorderFile);
		VUHDO_PixelUtil.SetHeight(sBorderEdgeBottom, sBorderWidth, 1);

		sBorderEdgeLeft:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(sBorderEdgeLeft, "TOPLEFT", tAnchorFrame, "TOPLEFT", 0, 0);
		VUHDO_PixelUtil.SetPoint(sBorderEdgeLeft, "BOTTOMLEFT", tAnchorFrame, "BOTTOMLEFT", 0, 0);
		sBorderEdgeLeft:SetTexture(sBorderFile);
		VUHDO_PixelUtil.SetWidth(sBorderEdgeLeft, sBorderWidth, 1);

		sBorderEdgeRight:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(sBorderEdgeRight, "TOPRIGHT", tAnchorFrame, "TOPRIGHT", 0, 0);
		VUHDO_PixelUtil.SetPoint(sBorderEdgeRight, "BOTTOMRIGHT", tAnchorFrame, "BOTTOMRIGHT", 0, 0);
		sBorderEdgeRight:SetTexture(sBorderFile);
		VUHDO_PixelUtil.SetWidth(sBorderEdgeRight, sBorderWidth, 1);

		sBorderEdgeTop:SetDrawLayer("OVERLAY", 7);
		sBorderEdgeBottom:SetDrawLayer("OVERLAY", 7);
		sBorderEdgeLeft:SetDrawLayer("OVERLAY", 7);
		sBorderEdgeRight:SetDrawLayer("OVERLAY", 7);

		sBorderEdgeTop:Show();
		sBorderEdgeBottom:Show();
		sBorderEdgeLeft:Show();
		sBorderEdgeRight:Show();

		return true;

	end



	--
	function VUHDO_applyAuraButtonDispelBorder(aAuraButton, anButtonSetup)

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		if not VUHDO_anchorAuraButtonBorderEdges(aAuraButton, anButtonSetup) then
			return;
		end

		sAuraBorderOptions["customDispelColorCurve"] = nil;
		sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);

		aAuraButton:AddDispelTypeTexture(sBorderEdgeTop, sAuraBorderOptions);
		aAuraButton:AddDispelTypeTexture(sBorderEdgeBottom, sAuraBorderOptions);
		aAuraButton:AddDispelTypeTexture(sBorderEdgeLeft, sAuraBorderOptions);
		aAuraButton:AddDispelTypeTexture(sBorderEdgeRight, sAuraBorderOptions);

		if anButtonSetup["targetFrameLevel"] then
			VUHDO_PixelUtil.SetFrameLevel(aAuraButton, anButtonSetup["targetFrameLevel"]);
		end

		return;

	end



	--
	local tDispelIconTexture;
	function VUHDO_applyAuraButtonDispelIcon(aAuraButton, anButtonSetup)

		tDispelIconTexture = aAuraButton["IconColorOverlay"] or aAuraButton["FillTexture"];

		if not tDispelIconTexture then
			return;
		end

		sAuraBorderOptions["customDispelColorCurve"] = nil;

		if anButtonSetup["dispelOpacity"] then
			sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);
		else
			sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMapOpaque(anButtonSetup["dispelBright"]);
		end

		aAuraButton:AddDispelTypeTexture(tDispelIconTexture, sAuraBorderOptions);

		return;

	end



	--
	function VUHDO_applyAuraButtonStaticBorder(aAuraButton, anButtonSetup)

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		if not anButtonSetup["dispelFill"] and not anButtonSetup["auraGroupBarGlow"] then
			aAuraButton:ClearDispelTypeTextures();
		end

		if not VUHDO_anchorAuraButtonBorderEdges(aAuraButton, anButtonSetup) then
			return;
		end

		sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO = VUHDO_backColorWithFallback(anButtonSetup["staticColor"]);

		sBorderEdgeTop:SetVertexColor(sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);
		sBorderEdgeBottom:SetVertexColor(sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);
		sBorderEdgeLeft:SetVertexColor(sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);
		sBorderEdgeRight:SetVertexColor(sBorderColorR, sBorderColorG, sBorderColorB, sBorderColorO);

		if anButtonSetup["targetFrameLevel"] then
			VUHDO_PixelUtil.SetFrameLevel(aAuraButton, anButtonSetup["targetFrameLevel"]);
		end

		return;

	end



	--
	function VUHDO_hideAuraButtonBorder(aAuraButton)

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		sBorderEdgeTop = aAuraButton["BorderEdgeTop"];

		if sBorderEdgeTop then
			sBorderEdgeTop:Hide();
		end

		sBorderEdgeBottom = aAuraButton["BorderEdgeBottom"];

		if sBorderEdgeBottom then
			sBorderEdgeBottom:Hide();
		end

		sBorderEdgeLeft = aAuraButton["BorderEdgeLeft"];

		if sBorderEdgeLeft then
			sBorderEdgeLeft:Hide();
		end

		sBorderEdgeRight = aAuraButton["BorderEdgeRight"];

		if sBorderEdgeRight then
			sBorderEdgeRight:Hide();
		end

		return;

	end



	--
	local tIconTexture;
	local tInsetParent;
	function VUHDO_bindAuraButtonDispelBorder(aAuraButton, anButtonSetup)

		if not aAuraButton then
			return;
		end

		sBorderTexture = aAuraButton["BorderTexture"];

		if sBorderTexture then
			sBorderTexture:Hide();
		end

		if not VUHDO_anchorAuraButtonBorderEdges(aAuraButton, anButtonSetup, aAuraButton["IconFrame"]) then
			return;
		end

		sAuraIconDispelBorderOptionsBind["customDispelColorMap"] = nil;
		sAuraIconDispelBorderOptionsBind["customDispelColorCurve"] = VUHDO_getDispelTypeBorderCurve();

		aAuraButton:ClearDispelTypeTextures();

		aAuraButton:AddDispelTypeTexture(sBorderEdgeTop, sAuraIconDispelBorderOptionsBind);
		aAuraButton:AddDispelTypeTexture(sBorderEdgeBottom, sAuraIconDispelBorderOptionsBind);
		aAuraButton:AddDispelTypeTexture(sBorderEdgeLeft, sAuraIconDispelBorderOptionsBind);
		aAuraButton:AddDispelTypeTexture(sBorderEdgeRight, sAuraIconDispelBorderOptionsBind);

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
	function VUHDO_applyDispelOverlayGradientTexture(aAuraButton, anButtonSetup, aBorderOptions)

		tGradientTexture = aAuraButton["GradientTexture"];

		if not tGradientTexture then
			return;
		end

		SetTextureWithAddressModeOptions(tGradientTexture, "_RaidFrame-Dispel-Highlight-Horizontal", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeWrap, TextureKitConstants.AddressModeClamp);

		tGradientTexture:SetTexCoord(0, 1, 0, 1);

		aBorderOptions["customDispelColorCurve"] = nil;
		aBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"]);

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
	function VUHDO_applyAuraButtonSetup(anButtonSetup, aAuraButton)

		if not anButtonSetup then
			return;
		end

		tTextOverlayFrame = aAuraButton["TextOverlayFrame"];

		if tTextOverlayFrame then
			aAuraButton["SymbolText"] = tTextOverlayFrame["SymbolText"];
			aAuraButton["TimerText"] = tTextOverlayFrame["TimerText"];
			aAuraButton["CountText"] = tTextOverlayFrame["CountText"];
		end

		tBarNoIconTexts = anButtonSetup["durationBar"] and (anButtonSetup["iconType"] or 1) == 5;

		tMainTexture = aAuraButton["IconTexture"] or aAuraButton["FillTexture"];

		if anButtonSetup["hideIcon"] then
			if tMainTexture then
				tMainTexture:Hide();
			end
		elseif anButtonSetup["staticIcon"] then
			if tMainTexture then
				if VUHDO_ATLAS_TEXTURES[anButtonSetup["staticIcon"]] then
					tMainTexture:SetAtlas(anButtonSetup["staticIcon"]);
				else
					tMainTexture:SetTexture(anButtonSetup["staticIcon"]);
				end

				if anButtonSetup["iconTexCoords"] then
					tTexCoords = anButtonSetup["iconTexCoords"];

					tMainTexture:SetTexCoord(tTexCoords[1] or 0, tTexCoords[2] or 1, tTexCoords[3] or 0, tTexCoords[4] or 1);
				elseif not VUHDO_ATLAS_TEXTURES[anButtonSetup["staticIcon"]] then
					tMainTexture:SetTexCoord(0, 1, 0, 1);
				end

				tMainTexture:Show();

				tMainTexture:SetVertexColor(1, 1, 1, 1);

				VUHDO_applyAuraButtonSublevelSlot(tMainTexture, anButtonSetup, 1, "ARTWORK", 1);
			end
		elseif aAuraButton["IconTexture"] then
			aAuraButton:SetIcon(aAuraButton["IconTexture"]);
		end

		if anButtonSetup["staticColor"] and tMainTexture and not anButtonSetup["shadowBar"] and not anButtonSetup["border"] then
			tStaticColor = anButtonSetup["staticColor"];

			if anButtonSetup["staticIcon"] then
				tMainTexture:SetVertexColor(tStaticColor["R"] or 1, tStaticColor["G"] or 1, tStaticColor["B"] or 1, tStaticColor["O"] or 1);
			else
				tMainTexture:SetColorTexture(tStaticColor["R"] or 1, tStaticColor["G"] or 1, tStaticColor["B"] or 1, tStaticColor["O"] or 1);
			end

			tMainTexture:Show();
		end

		if aAuraButton["IconTexture"] then
			if anButtonSetup["iconColor"] then
				tIconColor = anButtonSetup["iconColor"];

				aAuraButton["IconColorOverlay"]:SetColorTexture(tIconColor["R"] or 1, tIconColor["G"] or 1, tIconColor["B"] or 1, 1);
				aAuraButton["IconColorOverlay"]:Show();
			else
				aAuraButton["IconColorOverlay"]:Hide();
			end
		end

		if anButtonSetup["shadowBar"] and aAuraButton["ShadowBar"] then
			tShadowBar = aAuraButton["ShadowBar"];

			if anButtonSetup["shadowValueMode"] == "duration" then
				if aAuraButton["FillTexture"] then
					aAuraButton["FillTexture"]:Hide();
				end

				VUHDO_applyAuraButtonVolatileSetup(anButtonSetup, aAuraButton);

				if anButtonSetup["dispelFill"] then
					tShadowTexture = tShadowBar:GetStatusBarTexture();

					if tShadowTexture then
						tShadowTexture:SetVertexColor(1, 1, 1, 1);

						sAuraOpaqueBorderOptions["customDispelColorCurve"] = nil;

						if anButtonSetup["dispelOpacity"] then
							sAuraOpaqueBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);
						else
							sAuraOpaqueBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMapOpaque(anButtonSetup["dispelBright"]);
						end

						aAuraButton:ClearDispelTypeTextures();

						aAuraButton:AddDispelTypeTexture(tShadowTexture, sAuraOpaqueBorderOptions);
					end
				end

				if anButtonSetup["barInverted"] then
					sAuraDurationBarOptions["direction"] = Enum.StatusBarTimerDirection.ElapsedTime;
				else
					sAuraDurationBarOptions["direction"] = Enum.StatusBarTimerDirection.RemainingTime;
				end

				aAuraButton:SetDurationBar(tShadowBar, sAuraDurationBarOptions);

				tShadowBar["isDuration"] = true;

				tShadowBar:Show();
			else
				tShadowBar:Hide();

				tFillTexture = aAuraButton["FillTexture"];

				if tFillTexture and anButtonSetup["targetBar"] then
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

					if anButtonSetup["shadowValueMode"] == "cover" then
						tFillMask:SetAllPoints(anButtonSetup["targetBar"]);
					else
						tFillMask:SetAllPoints(anButtonSetup["targetBar"]:GetStatusBarTexture());
					end

					if anButtonSetup["dispelFill"] then
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
					elseif anButtonSetup["staticColor"] then
						tFillBackground = aAuraButton["VuhDoFillBackground"];

						if not tFillBackground then
							tFillBackground = aAuraButton:CreateTexture(nil, "ARTWORK");
							aAuraButton["VuhDoFillBackground"] = tFillBackground;

							tFillBackground:AddMaskTexture(tFillMask);
						end

						tFillBackground:ClearAllPoints();
						tFillBackground:SetAllPoints(aAuraButton);
					end

					VUHDO_applyAuraButtonVolatileSetup(anButtonSetup, aAuraButton);

					if anButtonSetup["dispelFill"] then
						tFillBackground = aAuraButton["VuhDoFillBackground"];

						aAuraButton:ClearDispelTypeTextures();

						if "cover" == anButtonSetup["shadowValueMode"] then
							sAuraOpaqueBorderOptions["customDispelColorMap"] = nil;
							sAuraOpaqueBorderOptions["customDispelColorCurve"] = sAuraOpaqueBorderOptions["backingCurveFn"](anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);

							if tFillBackground then
								aAuraButton:AddDispelTypeTexture(tFillBackground, sAuraOpaqueBorderOptions);
							end

							sAuraOpaqueBorderOptions["customDispelColorCurve"] = sAuraOpaqueBorderOptions["fillCurveFn"](anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);

							aAuraButton:AddDispelTypeTexture(tFillTexture, sAuraOpaqueBorderOptions);
						elseif anButtonSetup["dispelOpacity"] then
							sAuraBorderOptions["customDispelColorCurve"] = nil;
							sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"], anButtonSetup["dispelOpacity"]);

							aAuraButton:AddDispelTypeTexture(tFillTexture, sAuraBorderOptions);
						else
							sAuraOpaqueBorderOptions["customDispelColorCurve"] = nil;
							sAuraOpaqueBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMapOpaque(anButtonSetup["dispelBright"]);

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

		if not anButtonSetup["dispelOverlayChrome"] then
			if anButtonSetup["dispelIcon"] then
				if not anButtonSetup["dispelFill"] and not anButtonSetup["auraGroupBarGlow"] then
					aAuraButton:ClearDispelTypeTextures();
				end

				VUHDO_applyAuraButtonDispelIcon(aAuraButton, anButtonSetup);
			elseif anButtonSetup["dispelBorder"] then
				if aAuraButton["IconTexture"] then
					VUHDO_bindAuraButtonDispelBorder(aAuraButton, anButtonSetup);
				else
					if not anButtonSetup["dispelFill"] and not anButtonSetup["auraGroupBarGlow"] then
						aAuraButton:ClearDispelTypeTextures();
					end

					VUHDO_applyAuraButtonDispelBorder(aAuraButton, anButtonSetup);
				end
			elseif anButtonSetup["border"] then
				VUHDO_applyAuraButtonStaticBorder(aAuraButton, anButtonSetup);
			elseif aAuraButton["IconTexture"] then
				VUHDO_unbindAuraButtonDispelBorder(aAuraButton);
			elseif not anButtonSetup["dispelFill"] and not anButtonSetup["auraGroupBarGlow"] then
				aAuraButton:ClearDispelTypeTextures();

				VUHDO_hideAuraButtonBorder(aAuraButton);
			end
		end

		if anButtonSetup["dispelOverlayChrome"] then
			if not anButtonSetup["auraGroupBarGlow"] then
				aAuraButton:ClearDispelTypeTextures();
			end

			tFillTexture = aAuraButton["FillTexture"];

			if tFillTexture then
				tFillTexture:SetVertexColor(1, 1, 1, 1);
				tFillTexture:SetAlpha(0.2);
				tFillTexture:Show();
			end

			VUHDO_applyDispelOverlayGradientTexture(aAuraButton, anButtonSetup, sAuraBorderOptions);

			if aAuraButton["BorderTexture"] then
				sAuraBorderOptions["customDispelColorCurve"] = nil;
				sAuraBorderOptions["customDispelColorMap"] = VUHDO_getDispelTypeColorMap(anButtonSetup["dispelBright"]);

				aAuraButton:AddDispelTypeTexture(aAuraButton["BorderTexture"], sAuraBorderOptions);
			end

			tDispelIconTexture = aAuraButton["DispelIconTexture"];

			if tDispelIconTexture then
				aAuraButton:AddDispelTypeTexture(tDispelIconTexture, sDispelOverlayIconOptions);
			end
		end

		if anButtonSetup["auraSymbol"] and aAuraButton["SymbolText"] then
			aAuraButton:SetDispelTypeText(aAuraButton["SymbolText"], sAuraSymbolOptions);
		end

		if anButtonSetup["durationBar"] and (anButtonSetup["iconType"] or 1) == 5 then
			aAuraButton:ClearDurationCooldown();

			if aAuraButton["DurationCooldown"] then
				aAuraButton["DurationCooldown"]:Hide();
			end
		elseif anButtonSetup["durationCooldown"] and aAuraButton["DurationCooldown"] then
			aAuraButton["DurationCooldown"]:SetHideCountdownNumbers(true);

			aAuraButton:SetDurationCooldown(aAuraButton["DurationCooldown"]);
		elseif not anButtonSetup["durationCooldown"] then
			aAuraButton:ClearDurationCooldown();
		end

		if anButtonSetup["durationBar"] and aAuraButton["DurationBar"] then
			if anButtonSetup["durationBarOrientation"] then
				VUHDO_setStatusBarOrientation(aAuraButton["DurationBar"], anButtonSetup["durationBarOrientation"]);
			end

			if anButtonSetup["barTexture"] then
				VUHDO_setLlcStatusBarTexture(aAuraButton["DurationBar"], anButtonSetup["barTexture"]);
			end

			if anButtonSetup["barColor"] then
				tBarColor = anButtonSetup["barColor"];

				aAuraButton["DurationBar"]:GetStatusBarTexture():SetVertexColor(tBarColor["R"] or 0.2, tBarColor["G"] or 0.6, tBarColor["B"] or 0.2, tBarColor["O"] or 1);
			end

			aAuraButton:SetDurationBar(aAuraButton["DurationBar"], anButtonSetup["durationBarOptions"] or sEmpty);

			if tTextOverlayFrame then
				tTextOverlayFrame:SetFrameLevel(aAuraButton["DurationBar"]:GetFrameLevel() + 1);
			end

			VUHDO_layoutBarAuraButtonFrames(anButtonSetup, aAuraButton);
		end

		if not tBarNoIconTexts and anButtonSetup["durationText"] and aAuraButton["TimerText"] then
			VUHDO_applyAuraButtonText(anButtonSetup, aAuraButton, aAuraButton["TimerText"], "TIMER_TEXT");

			aAuraButton:SetDurationText(aAuraButton["TimerText"], anButtonSetup["durationTextOptions"] or sEmpty);
		elseif tBarNoIconTexts or not anButtonSetup["durationText"] then
			aAuraButton:ClearDurationText();
		end

		if not tBarNoIconTexts and anButtonSetup["applicationCount"] and aAuraButton["CountText"] then
			VUHDO_applyAuraButtonText(anButtonSetup, aAuraButton, aAuraButton["CountText"], "COUNTER_TEXT");

			aAuraButton:SetApplicationCount(aAuraButton["CountText"], sEmpty);
		elseif tBarNoIconTexts or not anButtonSetup["applicationCount"] then
			aAuraButton:ClearApplicationCount();
		end

		if anButtonSetup["width"] and anButtonSetup["height"] then
			VUHDO_PixelUtil.SetSize(aAuraButton, anButtonSetup["width"], anButtonSetup["height"]);
		end

		aAuraButton:SetMouseClickEnabled(false);

		if anButtonSetup["disableMouse"] then
			aAuraButton:EnableMouse(false);
			aAuraButton:SetMouseClickEnabled(false);
			aAuraButton:SetMouseMotionEnabled(false);
		elseif anButtonSetup["mouseMotion"] == false then
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

		if anButtonSetup["glowIcon"] then
			VUHDO_startAuraButtonGlow(aAuraButton, anButtonSetup);
		else
			VUHDO_stopAuraButtonGlow(aAuraButton);
		end

		if anButtonSetup["auraGroupBarGlow"] then
			VUHDO_applyAuraGroupBarGlowFromAuraButton(aAuraButton, anButtonSetup);
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
	local tSlotContainerLevel;
	local tSlotFrameLevelOffset;
	local tSlotAnchor;
	local tSlotRelPoint;
	local tSlotAnchorFrame;
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

			tSlotContainerLevel = aContainer:GetFrameLevel();

			if not tSlotContainerLevel or tSlotContainerLevel <= 0 then
				tSlotContainerLevel = aTemplateRef["containerLevel"];
			end

			tSlotFrameLevelOffset = tSlotButtonSetup["frameLevelOffset"];

			if tSlotFrameLevelOffset and tSlotContainerLevel then
				VUHDO_PixelUtil.SetFrameLevel(aAuraButton, tSlotContainerLevel + tSlotFrameLevelOffset);
			end

			return;

		end;

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

				-- FIXME: aura containers seem to keep a one pixel minimum height
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
		tinsert(aSignatureParts, format("%d", aButtonSetup["borderWidth"] or 0));
		tinsert(aSignatureParts, aButtonSetup["borderFile"] or "");
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
	local tFilterSlotKeys;
	local tFilterSlotTemplateRefs;
	local tFilterSlot;
	local tFilterRecordedKey;
	local tFilterTemplateRef;
	local tFilterGroupKeys;
	local tFilterGroupTemplateRefs;
	local tFilterGroup;
	local tFilterEngineSlotCnt;
	function VUHDO_applyAuraContainerFilterPass(aContainer, aContainerData, aContainerTemplate)

		if not aContainer or not aContainerData or not aContainerTemplate then
			return;
		end

		VUHDO_restoreAuraContainerGroups(aContainer, aContainerData);

		tFilterSlotKeys = aContainerData["slotKeys"];
		tFilterSlotTemplateRefs = aContainerData["slotTemplateRefs"];
		tFilterEngineSlotCnt = 0;

		for tFilterSlotCnt = 1, #(aContainerTemplate["slots"] or sEmpty) do
			tFilterSlot = aContainerTemplate["slots"][tFilterSlotCnt];

			if tFilterSlot and not tFilterSlot["isStaticBouquetSlot"] then
				tFilterEngineSlotCnt = tFilterEngineSlotCnt + 1;
				tFilterRecordedKey = tFilterSlotKeys and tFilterSlotKeys[tFilterEngineSlotCnt];

				if tFilterRecordedKey then
					aContainer:SetAuraSlotFilterString(tFilterRecordedKey, tFilterSlot["filterString"] or "HELPFUL");
					aContainer:SetAuraSlotCandidateFilters(tFilterRecordedKey, tFilterSlot["candidateFilters"]);

					tFilterTemplateRef = tFilterSlotTemplateRefs and tFilterSlotTemplateRefs[tFilterEngineSlotCnt];

					if tFilterTemplateRef then
						tFilterTemplateRef["template"] = tFilterSlot;
						tFilterTemplateRef["identityGate"] = VUHDO_getTemplateIdentityGate(tFilterSlot);
						tFilterTemplateRef["isCompoundFilterString"] = VUHDO_isCompoundFilterStringTemplate(tFilterSlot);
					end
				end
			end
		end

		tFilterGroupKeys = aContainerData["groupKeys"];
		tFilterGroupTemplateRefs = aContainerData["groupTemplateRefs"];

		for tFilterGroupCnt = 1, #(aContainerTemplate["groups"] or sEmpty) do
			tFilterGroup = aContainerTemplate["groups"][tFilterGroupCnt];
			tFilterRecordedKey = tFilterGroupKeys and tFilterGroupKeys[tFilterGroupCnt];

			if tFilterGroup and tFilterRecordedKey then
				aContainer:SetAuraGroupMaxFrameCount(tFilterRecordedKey, tFilterGroup["maxFrameCount"] or 5);
				aContainer:SetAuraGroupFilterString(tFilterRecordedKey, tFilterGroup["filterString"] or "HELPFUL");
				aContainer:SetAuraGroupCandidateFilters(tFilterRecordedKey, tFilterGroup["candidateFilters"]);

				tFilterTemplateRef = tFilterGroupTemplateRefs and tFilterGroupTemplateRefs[tFilterGroupCnt];

				if tFilterTemplateRef then
					tFilterTemplateRef["template"] = tFilterGroup;
					tFilterTemplateRef["identityGate"] = VUHDO_getTemplateIdentityGate(tFilterGroup);
					tFilterTemplateRef["isCompoundFilterString"] = VUHDO_isCompoundFilterStringTemplate(tFilterGroup);
				end
			end
		end

		aContainerData["lastSlotSuppress"] = nil;
		aContainerData["lastGroupSuppress"] = nil;
		aContainerData["lastContainerSuppressed"] = nil;
		aContainerData["appliedSlotCandidateSuppress"] = nil;

		return;

	end



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
	local tVolatileContainerTemplate;
	local tVolatileGroupKeys;
	local tVolatileGroup;
	local tVolatileRecordedKey;
	local tVolatileGroupFrameCount;
	local tVolatileAuraFrame;
	local tVolatileSlotKeys;
	local tVolatileSlotFrames;
	local tVolatileSlot;
	local tVolatileEngineSlotCnt;
	local tVolatileButtonSetup;
	function VUHDO_applyAuraContainerVolatilePass(aContainer, aContainerData)

		if not aContainer or not aContainerData then
			return;
		end

		tVolatileContainerTemplate = aContainerData["containerTemplate"];

		if not tVolatileContainerTemplate then
			return;
		end

		tVolatileGroupKeys = aContainerData["groupKeys"];

		if tVolatileGroupKeys then
			for tVolatileGroupCnt = 1, #(tVolatileContainerTemplate["groups"] or sEmpty) do
				tVolatileGroup = tVolatileContainerTemplate["groups"][tVolatileGroupCnt];
				tVolatileRecordedKey = tVolatileGroupKeys[tVolatileGroupCnt];

				if tVolatileGroup and tVolatileRecordedKey and tVolatileGroup["buttonSetup"] then
					tVolatileButtonSetup = tVolatileGroup["buttonSetup"];
					tVolatileGroupFrameCount = aContainer:GetAuraGroupFrameCount(tVolatileRecordedKey);

					for tVolatileGroupFrameCnt = 1, tVolatileGroupFrameCount do
						tVolatileAuraFrame = aContainer:GetAuraGroupFrame(tVolatileRecordedKey, tVolatileGroupFrameCnt);

						if tVolatileAuraFrame and tVolatileAuraFrame:CanBeAccessedInContext() then
							VUHDO_applyAuraButtonVolatileSetup(tVolatileButtonSetup, tVolatileAuraFrame);

							if tVolatileButtonSetup["auraGroupBarGlow"] then
								VUHDO_applyAuraGroupBarGlowFromAuraButton(tVolatileAuraFrame, tVolatileButtonSetup);
							end

							if tVolatileButtonSetup["glowIcon"] then
								VUHDO_startAuraButtonGlow(tVolatileAuraFrame, tVolatileButtonSetup);
							end

							if "class" == tVolatileButtonSetup["barColorMode"] and tVolatileAuraFrame["DurationBar"] then
								VUHDO_reregisterContainerClassColorBar(aContainer, tVolatileAuraFrame["DurationBar"]);
							end
						end
					end
				end
			end
		end

		tVolatileSlotKeys = aContainerData["slotKeys"];
		tVolatileSlotFrames = aContainerData["slotFrames"];
		tVolatileEngineSlotCnt = 0;

		for tVolatileSlotCnt = 1, #(tVolatileContainerTemplate["slots"] or sEmpty) do
			tVolatileSlot = tVolatileContainerTemplate["slots"][tVolatileSlotCnt];

			if tVolatileSlot and not tVolatileSlot["isStaticBouquetSlot"] then
				tVolatileEngineSlotCnt = tVolatileEngineSlotCnt + 1;
				tVolatileRecordedKey = tVolatileSlotKeys and tVolatileSlotKeys[tVolatileEngineSlotCnt];

				if tVolatileRecordedKey then
					tVolatileAuraFrame = tVolatileSlotFrames and tVolatileSlotFrames[tVolatileRecordedKey];

					if tVolatileAuraFrame and tVolatileSlot["buttonSetup"] and tVolatileAuraFrame:CanBeAccessedInContext() then
						if not VUHDO_isThreatMarkSlotFlashing(tVolatileAuraFrame, tVolatileSlot) then
							tVolatileButtonSetup = tVolatileSlot["buttonSetup"];

							VUHDO_applyAuraButtonVolatileSetup(tVolatileButtonSetup, tVolatileAuraFrame);

							if tVolatileButtonSetup["auraGroupBarGlow"] then
								VUHDO_applyAuraGroupBarGlowFromAuraButton(tVolatileAuraFrame, tVolatileButtonSetup);
							end

							if tVolatileButtonSetup["glowIcon"] then
								VUHDO_startAuraButtonGlow(tVolatileAuraFrame, tVolatileButtonSetup);
							end

							if "class" == tVolatileButtonSetup["barColorMode"] and tVolatileAuraFrame["DurationBar"] then
								VUHDO_reregisterContainerClassColorBar(aContainer, tVolatileAuraFrame["DurationBar"]);
							end
						end
					end
				end
			end
		end

		return;

	end



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
			["slotOrder"] = { },
			["plannedSlots"] = { },
			["lastSyncedSlotEnabled"] = { },
			["lastSyncedUnit"] = nil,
			["lastSyncedGuid"] = nil,
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

		tContainer:SetAuraSlotFilterString(aSlotKey, "");

		tSlotRecord["appliedFilterString"] = "";
		tSlotRecord["appliedSuppress"] = true;

		VUHDO_stopOverlayThreatMarkFlashForSlotRecord(tSlotRecord);

		if not aHostData["lastSyncedSlotEnabled"] then
			aHostData["lastSyncedSlotEnabled"] = { };
		end

		aHostData["lastSyncedSlotEnabled"][aSlotKey] = false;

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



--
function VUHDO_resetAuraContainerMetrics()

	twipe(VUHDO_AURA_CONTAINER_METRICS["builds"]);
	twipe(VUHDO_AURA_CONTAINER_METRICS["releases"]);

	VUHDO_Msg("Aura container metrics reset.");

	return;

end



--
function VUHDO_printAuraContainerMetrics()

	VUHDO_Msg("|cffFFD100--- Aura Container Metrics ---|r");

	VUHDO_Msg(format("|cffFFA500** Containers:|r |cff98FB98Builds=|r%d |cff98FB98Releases=|r%d",
		VUHDO_AURA_CONTAINER_METRICS["builds"]["container"] or 0,
		VUHDO_AURA_CONTAINER_METRICS["releases"]["container"] or 0));
	VUHDO_Msg(format("|cffFFA500** Overlay Slots:|r |cff98FB98SlotHosts=|r%d |cff98FB98Slots=|r%d",
		VUHDO_AURA_CONTAINER_METRICS["builds"]["slotHost"] or 0,
		VUHDO_AURA_CONTAINER_METRICS["builds"]["overlaySlot"] or 0));

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
function VUHDO_applyBarButtonSetupFields(anButtonSetup, anAnchorConfig)

	anButtonSetup["durationBar"] = true;
	anButtonSetup["durationBarOptions"] = {
		["direction"] = anAnchorConfig["barInvertGrowth"] and Enum.StatusBarTimerDirection.ElapsedTime
			or Enum.StatusBarTimerDirection.RemainingTime,
	};

	if anAnchorConfig["barVertical"] then
		anButtonSetup["durationBarOrientation"] = anAnchorConfig["barTurnAxis"] and VUHDO_STATUSBAR_TOP_TO_BOTTOM or VUHDO_STATUSBAR_BOTTOM_TO_TOP;
	else
		anButtonSetup["durationBarOrientation"] = anAnchorConfig["barTurnAxis"] and VUHDO_STATUSBAR_RIGHT_TO_LEFT or VUHDO_STATUSBAR_LEFT_TO_RIGHT;
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



--
local tButtonName;
local tUnit;
local tPanelAnchors;
local tContainerData;
local tSeenAnchors;
local tBuildSignature;
local tFilterSignature;
local tFilterContainer;
local tContainerTemplate;
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

	tSeenAnchors = { };

	for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
		if tAnchorConfig and tAnchorConfig["enabled"] ~= false then
			tSeenAnchors[tAnchorIndex] = true;

			tContainerTemplate = VUHDO_buildAnchorContainerTemplate(aButton, tAnchorIndex, tAnchorConfig);

			if tContainerTemplate then
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

					tFilterSignature = VUHDO_getAuraContainerFilterSignature(tContainerTemplate);
					tFilterContainer = tContainerData["container"];

					if tFilterContainer and tContainerData["filterSignature"] ~= tFilterSignature then
						VUHDO_applyAuraContainerFilterPass(tFilterContainer, tContainerData, tContainerTemplate);

						tContainerData["filterSignature"] = tFilterSignature;
					end

					VUHDO_deferVolatilePassForButton(aButton);
				else
					if tContainerData then
						VUHDO_retireAuraContainer(aButton, tContainerData);
					end

					tContainerData = VUHDO_acquireAuraContainer(aButton, tContainerTemplate);

					if tContainerData then
						VUHDO_AURA_CONTAINERS[tButtonName][tAnchorIndex] = tContainerData;
					end
				end
			end
		end
	end

	for tAnchorIndex, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tButtonName]) do
		if not tSeenAnchors[tAnchorIndex] then
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

	if not tVolatilePassButtonName or not VUHDO_AURA_CONTAINERS[tVolatilePassButtonName] then
		return;
	end

	for _, tContainerData in pairs(VUHDO_AURA_CONTAINERS[tVolatilePassButtonName]) do
		tVolatilePassContainer = tContainerData and tContainerData["container"];

		if tVolatilePassContainer then
			VUHDO_applyAuraContainerVolatilePass(tVolatilePassContainer, tContainerData);
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
		return;
	end

	aContainer:UpdateAllAuras();

	return;

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