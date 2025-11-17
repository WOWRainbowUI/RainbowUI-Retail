local _;

local GetTime = GetTime;
local UnitName = UnitName;
local UnitIsEnemy = UnitIsEnemy;
local GetSpellCooldown = GetSpellCooldown or VUHDO_getSpellCooldown;
local HasFullControl = HasFullControl;
local pairs = pairs;
local InCombatLockdown = InCombatLockdown;
local tonumber = tonumber;
local string = string;
local debugprofilestop = debugprofilestop;
local MeasureCall = C_AddOnProfiler and C_AddOnProfiler.MeasureCall;
local format = string.format;
local tinsert = table.insert;
local tremove = table.remove;
local twipe = table.wipe;
local floor = math.floor;

VUHDO_INTERNAL_TOGGLES = { };
local VUHDO_INTERNAL_TOGGLES = VUHDO_INTERNAL_TOGGLES;

local VUHDO_INSTANCE = nil;

-- BURST CACHE ---------------------------------------------------

local VUHDO_RAID;
local VUHDO_PANEL_SETUP;
VUHDO_RELOAD_UI_IS_LNF = false;


local VUHDO_HANDLER_PROFILING_ENABLED = false;

local VUHDO_HANDLER_PROFILING_SESSION_START_TIME = 0;
local VUHDO_HANDLER_PROFILING_METRICS = { };
local VUHDO_HANDLER_PROFILING_BATCH_SIZE = 10;
local VUHDO_HANDLER_PROFILING_BATCH_COUNT = 0;
local VUHDO_HANDLER_PROFILING_PENDING_UPDATES = { };
local VUHDO_HANDLER_PROFILING_ONUPDATE_INVOCATIONS = 0;

local VUHDO_HANDLER_EVENT_CONFIG = {
	["LIMIT"] = 5,
	["THRESHOLD_US"] = 2000,
	["HISTORY_LIMIT"] = 100,
};

local VUHDO_HANDLER_EVENT_SNAPSHOTS = {
	-- {
	--	["eventName"] = <event name>,
	--	["durationUs"] = <microsecond duration>,
	--	["timestamp"] = <epoch timestamp>,
	--	["args"] = {
	--		<arg1>,
	--		...
	--	},
	-- },
};


local VUHDO_parseAddonMessage;
local VUHDO_spellcastSent;
local VUHDO_parseCombatLogEvent;
local VUHDO_updateAllOutRaidTargetButtons;
local VUHDO_updateAllRaidTargetIndices;
local VUHDO_updateDirectionFrame;
local VUHDO_updateHealth;
local VUHDO_updateHealthBarsFor;
local VUHDO_setHealth;
local VUHDO_updateShieldBar;
local VUHDO_updateHealAbsorbBar;
local VUHDO_updateManaBars;
local VUHDO_updateTargetBars;
local VUHDO_initAllEventBouquets;
local VUHDO_updateBouquetsForEvent;
local VUHDO_updateAllHoTs;
local VUHDO_updateAllCyclicBouquets;
local VUHDO_updateAllDebuffIcons;
local VUHDO_createDebuffIconAnimation;
local VUHDO_cleanupDebuffIconAnimation;
local VUHDO_updateAllAggro;
local VUHDO_updateUnitAggro;
local VUHDO_updateAllRange;
local VUHDO_updateAllClusters;
local VUHDO_updateClusterHighlights;
local VUHDO_aoeUpdateAll;
local VUHDO_updateSpellTrace;
local VUHDO_cleanupSpellTraceForUnit;
local VUHDO_clearAllSpellTraces;
local VUHDO_updateAllRaidBars;
local VUHDO_updateCustomDebuffTooltip;
local VUHDO_getUnitZoneName;
local VUHDO_handleScaleChange;
local VUHDO_redrawPanel;
local VUHDO_redrawAllPanels;

local VUHDO_UIFrameFlash_OnUpdate = function() end;



do
	--
	function VUHDO_setHandlerProfiling(anIsEnabled)

		VUHDO_HANDLER_PROFILING_ENABLED = anIsEnabled;

		if anIsEnabled then
			VUHDO_Msg("Handler profiling is enabled.");
		else
			VUHDO_Msg("Handler profiling is disabled.");
		end

		return;

	end



	--
	local tSnapshots;
	local tNewSnapshot;
	local tIsDuplicate;
	local tCompositionKey;
	local tArgs;
	function VUHDO_addEventSnapshot(aEventName, aDurationUs, ...)

		if not VUHDO_HANDLER_PROFILING_ENABLED or aDurationUs < VUHDO_HANDLER_EVENT_CONFIG["THRESHOLD_US"] then
			return;
		end

		tSnapshots = VUHDO_HANDLER_EVENT_SNAPSHOTS;
		tIsDuplicate = false;

		tArgs = { };

		for tCnt = 1, select("#", ...) do
			tinsert(tArgs, tostring(select(tCnt, ...)));

			-- don't capture more than 5 arguments
			if tCnt >= 5 then
				break;
			end
		end

		tCompositionKey = aEventName .. ":" .. table.concat(tArgs, ",");

		for _, tExistingSnapshot in ipairs(tSnapshots) do
			if not tExistingSnapshot["compositionKey"] then
				-- backward compatibility: create composition key for existing snapshots
				tArgs = { };

				for _, tArg in ipairs(tExistingSnapshot["args"] or { }) do
					tinsert(tArgs, tostring(tArg));
				end

				tExistingSnapshot["compositionKey"] = tExistingSnapshot["eventName"] .. ":" .. table.concat(tArgs, ",");
			end

			if tExistingSnapshot["compositionKey"] == tCompositionKey then
				tExistingSnapshot["dedupedCount"] = (tExistingSnapshot["dedupedCount"] or 1) + 1;

				if aDurationUs > tExistingSnapshot["durationUs"] then
					tExistingSnapshot["durationUs"] = aDurationUs;
					tExistingSnapshot["timestamp"] = time();

					twipe(tExistingSnapshot["args"]);

					for _, tArg in ipairs(tArgs) do
						tinsert(tExistingSnapshot["args"], tArg);
					end
				end

				tIsDuplicate = true;

				break;
			end
		end

		if not tIsDuplicate then
			tNewSnapshot = {
				["eventName"] = aEventName,
				["durationUs"] = aDurationUs,
				["timestamp"] = time(),
				["args"] = { },
				["compositionKey"] = tCompositionKey,
				["dedupedCount"] = 1,
			};

			for _, tArg in ipairs(tArgs) do
				tinsert(tNewSnapshot["args"], tArg);
			end

			tinsert(tSnapshots, tNewSnapshot);
		end

		table.sort(tSnapshots, function(a, b) return a.durationUs > b.durationUs; end);

		while #tSnapshots > VUHDO_HANDLER_EVENT_CONFIG["LIMIT"] do
			tremove(tSnapshots);
		end

		return;

	end



	--
	local tSegmentName;
	local tTracker;
	function VUHDO_updateOnEventProfilingMetrics(anEventName, aDurationUs)

		if not VUHDO_HANDLER_PROFILING_ENABLED or not anEventName then
			return;
		end

		tSegmentName = "OnEvent_" .. anEventName;

		if not VUHDO_HANDLER_PROFILING_METRICS[tSegmentName] then
			VUHDO_HANDLER_PROFILING_METRICS[tSegmentName] = VUHDO_createPercentileTracker();
		end

		tTracker = VUHDO_HANDLER_PROFILING_METRICS[tSegmentName];
		tTracker:update(aDurationUs);

		return;

	end



	--
	function VUHDO_updateHandlerOnEventMetrics(anEventName, aDurationUs, anArg1, anArg2, anArg3, anArg4, anArg5)

		if not VUHDO_HANDLER_PROFILING_ENABLED or not anEventName then
			return;
		end

		VUHDO_updateOnEventProfilingMetrics(anEventName, aDurationUs);

		VUHDO_addEventSnapshot(anEventName, aDurationUs, anArg1, anArg2, anArg3, anArg4, anArg5);

		return;

	end



	--
	local tOnUpdateSegments = {
		"segment1A",
		"segment1B",
		"segment1Total",
		"segment2Total",
		"segment2A",
		"segment2B",
		"segment2C",
		"segment2D",
		"segment2E",
		"segment2F",
		"segment2G",
		"segment2H",
		"segment2I",
		"segment2J",
		"segment2K",
		"segment2L",
		"segment2M",
		"total",
	};
	function VUHDO_resetHandlerMetrics()

		VUHDO_HANDLER_PROFILING_SESSION_START_TIME = GetTime();
		VUHDO_HANDLER_PROFILING_ONUPDATE_INVOCATIONS = 0;

		twipe(VUHDO_HANDLER_EVENT_SNAPSHOTS);
		twipe(VUHDO_HANDLER_PROFILING_METRICS);

		if VUHDO_HANDLER_PROFILING_ENABLED then
			VUHDO_Msg("Handler profiling metrics reset.");
		end

		return;

	end



	--
	local function VUHDO_sortEventStats(anEntryA, anEntryB)

		return anEntryA["totalTime"] > anEntryB["totalTime"];

	end



	--
	local tPercentileKeys;
	local tPercentileText;
	local tPercentileKey;
	function VUHDO_printHandlerMetricSegment(aSegName, aSegData, anInvocationCount, anIndent)

		if not aSegData then
			return;
		end

		tPercentileKeys = { };

		for tPercentileKey in pairs(aSegData) do
			if string.sub(tPercentileKey, 1, 2) == "tm" then
				tinsert(tPercentileKeys, tPercentileKey);
			end
		end

		VUHDO_sortPercentileKeys(tPercentileKeys);

		tPercentileText = "";

		for tIndex = 1, #tPercentileKeys do
			tPercentileKey = tPercentileKeys[tIndex];

			if tIndex > 1 then
				tPercentileText = tPercentileText .. ", ";
			end

			tPercentileText = tPercentileText .. tPercentileKey .. ": " .. VUHDO_formatTime(aSegData[tPercentileKey] or 0);
		end

		VUHDO_Msg(format("%s|cffB0E0E6%s:|r Total: %s, %s",
			anIndent or "  ", aSegName,
			VUHDO_formatTime(aSegData["Total"] or 0),
			tPercentileText
		));

		return;

	end



	--
	local tSeg1Segments = {
		["segment1A"] = "Seg 1A (Animations)",
		["segment1B"] = "Seg 1B (Deferred Tasks)",
	};
	local tSeg2Segments = {
		["segment2A"] = "Seg 2A (UI Reloads)",
		["segment2B"] = "Seg 2B (Panel Reset)",
		["segment2C"] = "Seg 2C (Roster & Core)",
		["segment2D"] = "Seg 2D (Combat Chk)",
		["segment2E"] = "Seg 2E (Slow Thres)",
		["segment2F"] = "Seg 2F (Post-Combat)",
		["segment2G"] = "Seg 2G (Get Auto Prof)",
		["segment2H"] = "Seg 2H (Load Profile)",
		["segment2I"] = "Seg 2I (Hide Blizz)",
		["segment2J"] = "Seg 2J (Shield Cleanup)",
		["segment2K"] = "Seg 2K (Zones)",
		["segment2L"] = "Seg 2L (Inspect)",
		["segment2M"] = "Seg 2M (Macros)",
	};
	local tMetrics;
	local tSessionDuration;
	local tInvocationCount;
	local tEventStats;
	local tEventName;
	local tPercentiles;
	local tTotal;
	local tCount;
	local tArgString;
	local tDedupedText;
	local tThresholdText;
	local tSortedKeys;
	local tSegmentName;
	function VUHDO_printHandlerMetrics()

		if not VUHDO_HANDLER_PROFILING_ENABLED then
			VUHDO_Msg("Handler profiling is currently disabled.");

			return;
		end

		tMetrics = VUHDO_getHandlerProfilingMetrics();
		tSessionDuration = GetTime() - VUHDO_HANDLER_PROFILING_SESSION_START_TIME;
		tInvocationCount = VUHDO_HANDLER_PROFILING_ONUPDATE_INVOCATIONS;

		VUHDO_Msg("|cffFFD100--- Handler Profiling Metrics (Session: " .. format("%.2f sec", tSessionDuration) .. ") ---|r");

		VUHDO_Msg(format("|cffFFA500** VUHDO_OnUpdate Invocations:|r %d", tInvocationCount));

		if tMetrics["segment1Total"] then
			VUHDO_printHandlerMetricSegment("Segment 1 Total", tMetrics["segment1Total"], tInvocationCount);
		end

		VUHDO_Msg("  |cff98FB98Detailed Segment 1 Breakdown:|r");

		tSortedKeys = VUHDO_sortSegmentKeys(tSeg1Segments);

		for _, tSegmentKey in ipairs(tSortedKeys) do
			tSegmentName = tSeg1Segments[tSegmentKey];

			if tMetrics[tSegmentKey] then
				VUHDO_printHandlerMetricSegment(tSegmentName, tMetrics[tSegmentKey], tInvocationCount, "    - ");
			end
		end

		if tMetrics["segment2Total"] then
			VUHDO_printHandlerMetricSegment("Segment 2 Total", tMetrics["segment2Total"], tInvocationCount);
		end

		VUHDO_Msg("  |cff98FB98Detailed Segment 2 Breakdown:|r");

		tSortedKeys = VUHDO_sortSegmentKeys(tSeg2Segments);

		for _, tSegmentKey in ipairs(tSortedKeys) do
			tSegmentName = tSeg2Segments[tSegmentKey];

			if tMetrics[tSegmentKey] then
				VUHDO_printHandlerMetricSegment(tSegmentName, tMetrics[tSegmentKey], tInvocationCount, "    - ");
			end
		end

		if tMetrics["total"] then
			VUHDO_printHandlerMetricSegment("Sum (Segment 1 + Segment 2)", tMetrics["total"], tInvocationCount);
		end

		VUHDO_Msg("|cffFFA500** VUHDO_OnEvent (time per event type): **|r");

		tEventStats = { };

		for tSegmentName, tTracker in pairs(VUHDO_HANDLER_PROFILING_METRICS) do
			if string.sub(tSegmentName, 1, 8) == "OnEvent_" and tTracker:isInitialized() then
				tEventName = string.sub(tSegmentName, 9);

				tPercentiles = tTracker:getPercentiles();

				tTotal = tTracker:getCumulativeTotal();
				tCount = tTracker["totalCount"];

				tinsert(tEventStats, {
					["name"] = tEventName,
					["totalTime"] = tTotal,
					["count"] = tCount,
					["trimmedMeans"] = tPercentiles,
				});
			end
		end

		if #tEventStats == 0 then
			VUHDO_Msg("  No OnEvent calls recorded.");
		else
			table.sort(tEventStats, VUHDO_sortEventStats);

			VUHDO_Msg("  |cff98FB98Sorted by Total Time|r (Event: Total, Count, percentiles)");

			for _, tStats in ipairs(tEventStats) do
				tPercentileKeys = { };

				for tPercentileKey in pairs(tStats["trimmedMeans"]) do
					if string.sub(tPercentileKey, 1, 2) == "tm" then
						tinsert(tPercentileKeys, tPercentileKey);
					end
				end

				VUHDO_sortPercentileKeys(tPercentileKeys);

				tPercentileText = "";

				for tIndex = 1, #tPercentileKeys do
					tPercentileKey = tPercentileKeys[tIndex];

					if tIndex > 1 then
						tPercentileText = tPercentileText .. ", ";
					end

					tPercentileText = tPercentileText .. "|cff98FB98" .. tPercentileKey .. ":|r " .. VUHDO_formatTime(tStats["trimmedMeans"][tPercentileKey] or 0);
				end

						VUHDO_Msg(format("  |cffB0E0E6%s:|r |cff98FB98Total:|r %s, |cff98FB98Count:|r %d, %s",
			tStats["name"],
			VUHDO_formatTime(tStats["totalTime"]),
			tStats["count"],
			tPercentileText
		));
			end
		end

		if #VUHDO_HANDLER_EVENT_SNAPSHOTS > 0 then
			if VUHDO_HANDLER_EVENT_CONFIG["THRESHOLD_US"] then
				tThresholdText = VUHDO_formatTime(VUHDO_HANDLER_EVENT_CONFIG["THRESHOLD_US"]);
			else
				tThresholdText = "N/A";
			end

			VUHDO_Msg("|cffFFA500** Top " .. #VUHDO_HANDLER_EVENT_SNAPSHOTS .. " Expensive Event Invocations (|cffB0E0E6Threshold:|r " .. tThresholdText .. "): **|r");

			for tCnt, tSnapshot in ipairs(VUHDO_HANDLER_EVENT_SNAPSHOTS) do
				tArgString = table.concat(tSnapshot["args"], ", ");
				tDedupedText = "";

				if (tSnapshot["dedupedCount"] or 0) > 1 then
					tDedupedText = format(" (|cff98FB98deduped|r %d times)", tSnapshot["dedupedCount"]);
				end

				VUHDO_Msg(format("  #%d: |cffB0E0E6%s|r - %s @ |cffB0E0E6%s|r. |cff98FB98Args:|r %s%s",
					tCnt,
					tSnapshot["eventName"],
					VUHDO_formatTime(tSnapshot["durationUs"]),
					date("%m/%d/%y %H:%M:%S", tSnapshot["timestamp"]),
					tArgString,
					tDedupedText
				));
			end
		else
			VUHDO_Msg("|cffFFA500** No expensive event invocations captured. **|r");
		end

		VUHDO_Msg("|cffFFD100--- End of Metrics ---|r")

		return;

	end
end



--
local sIsDirectionArrow = false;
local sHotToggleUpdateSecs = 1;
local sAggroRefreshSecs = 1;
local sRangeRefreshSecs = 1.1;
local sClusterRefreshSecs = 1.2;
local sAoeRefreshSecs = 1.3;
local sBuffsRefreshSecs;
local sParseCombatLog;

local VuhDoGcdStatusBar;
local VuhDoDirectionFrame;

local function VUHDO_eventHandlerInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];

	VUHDO_updateHealth = _G["VUHDO_updateHealth"];
	VUHDO_updateManaBars = _G["VUHDO_updateManaBars"];
	VUHDO_updateTargetBars = _G["VUHDO_updateTargetBars"];
	VUHDO_updateAllRaidBars = _G["VUHDO_updateAllRaidBars"];
	VUHDO_updateAllOutRaidTargetButtons = _G["VUHDO_updateAllOutRaidTargetButtons"];
	VUHDO_parseAddonMessage = _G["VUHDO_parseAddonMessage"];
	VUHDO_spellcastSent = _G["VUHDO_spellcastSent"];
	VUHDO_parseCombatLogEvent = _G["VUHDO_parseCombatLogEvent"];
	VUHDO_updateAllHoTs = _G["VUHDO_updateAllHoTs"];
	VUHDO_updateAllCyclicBouquets = _G["VUHDO_updateAllCyclicBouquets"];
	VUHDO_updateAllDebuffIcons = _G["VUHDO_updateAllDebuffIcons"];
	VUHDO_createDebuffIconAnimation = _G["VUHDO_createDebuffIconAnimation"];
	VUHDO_cleanupDebuffIconAnimation = _G["VUHDO_cleanupDebuffIconAnimation"];
	VUHDO_updateAllRaidTargetIndices = _G["VUHDO_updateAllRaidTargetIndices"];
	VUHDO_updateAllClusters = _G["VUHDO_updateAllClusters"];
	VUHDO_aoeUpdateAll = _G["VUHDO_aoeUpdateAll"];
	VuhDoGcdStatusBar = _G["VuhDoGcdStatusBar"];
	VuhDoDirectionFrame = _G["VuhDoDirectionFrame"];
	VUHDO_updateDirectionFrame = _G["VUHDO_updateDirectionFrame"];
	VUHDO_getUnitZoneName = _G["VUHDO_getUnitZoneName"];
	VUHDO_updateClusterHighlights = _G["VUHDO_updateClusterHighlights"];
	VUHDO_updateCustomDebuffTooltip = _G["VUHDO_updateCustomDebuffTooltip"];
	VUHDO_UIFrameFlash_OnUpdate = _G["VUHDO_UIFrameFlash_OnUpdate"];
	VUHDO_handleScaleChange = _G["VUHDO_handleScaleChange"];

	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_updateShieldBar = _G["VUHDO_updateShieldBar"];
	VUHDO_updateHealAbsorbBar = _G["VUHDO_updateHealAbsorbBar"];
	VUHDO_updateHealthBarsFor = _G["VUHDO_updateHealthBarsFor"];

	VUHDO_updateSpellTrace = _G["VUHDO_updateSpellTrace"];
	VUHDO_setHealth = _G["VUHDO_setHealth"];
	VUHDO_initAllEventBouquets = _G["VUHDO_initAllEventBouquets"];
	VUHDO_updateAllAggro = _G["VUHDO_updateAllAggro"];
	VUHDO_updateUnitAggro = _G["VUHDO_updateUnitAggro"];
	VUHDO_updateAllRange = _G["VUHDO_updateAllRange"];

	VUHDO_cleanupSpellTraceForUnit = _G["VUHDO_cleanupSpellTraceForUnit"];
	VUHDO_clearAllSpellTraces = _G["VUHDO_clearAllSpellTraces"];

	VUHDO_initTaskSystem();

	-- override the base functions with their deferred counterparts
	VUHDO_updateHealth = _G["VUHDO_deferUpdateHealth"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_deferUpdateBouquetsForEvent"];
	VUHDO_updateShieldBar = _G["VUHDO_deferUpdateShieldBar"];
	VUHDO_updateHealAbsorbBar = _G["VUHDO_deferUpdateHealAbsorbBar"];
	VUHDO_updateHealthBarsFor = _G["VUHDO_deferUpdateHealthBarsFor"];
	VUHDO_updateAllHoTs = _G["VUHDO_deferUpdateAllHoTs"];
	VUHDO_updateAllCyclicBouquets = _G["VUHDO_deferUpdateAllCyclicBouquets"];
	VUHDO_updateAllDebuffIcons = _G["VUHDO_deferUpdateAllDebuffIcons"];
	VUHDO_updateAllAggro = _G["VUHDO_deferUpdateAllAggro"];
	VUHDO_updateUnitAggro = _G["VUHDO_deferUpdateUnitAggro"];
	VUHDO_updateAllRange = _G["VUHDO_deferUpdateAllRange"];
	VUHDO_updateAllClusters = _G["VUHDO_deferUpdateAllClusters"];
	VUHDO_aoeUpdateAll = _G["VUHDO_deferAoeUpdateAll"];
	VUHDO_updateSpellTrace = _G["VUHDO_deferUpdateSpellTrace"];
	VUHDO_updateAllRaidBars = _G["VUHDO_deferUpdateAllRaidBars"];
	VUHDO_initAllEventBouquets = _G["VUHDO_deferInitAllEventBouquets"];
	VUHDO_updateManaBars = _G["VUHDO_deferUpdateManaBars"];
	VUHDO_setHealth = _G["VUHDO_deferSetHealth"];
	VUHDO_updateClusterHighlights = _G["VUHDO_deferUpdateClusterHighlights"];
	VUHDO_handleScaleChange = _G["VUHDO_deferHandleScaleChange"];

	if VUHDO_CONFIG["USE_DEFERRED_REDRAW"] then
		VUHDO_redrawPanel = _G["VUHDO_deferRedrawPanel"];
		VUHDO_redrawAllPanels = _G["VUHDO_deferRedrawAllPanels"];
	else
		VUHDO_redrawPanel = _G["VUHDO_redrawPanel"];
		VUHDO_redrawAllPanels = _G["VUHDO_redrawAllPanels"];
	end

	sIsDirectionArrow = VUHDO_isShowDirectionArrow();

	sHotToggleUpdateSecs = VUHDO_CONFIG["UPDATE_HOTS_MS"] * 0.00033;
	sAggroRefreshSecs = VUHDO_CONFIG["THREAT"]["AGGRO_REFRESH_MS"] * 0.001;
	sRangeRefreshSecs = VUHDO_CONFIG["RANGE_CHECK_DELAY"] * 0.001;
	sClusterRefreshSecs = VUHDO_CONFIG["CLUSTER"]["REFRESH"] * 0.001;
	sAoeRefreshSecs = VUHDO_CONFIG["AOE_ADVISOR"]["refresh"] * 0.001;
	sBuffsRefreshSecs = VUHDO_BUFF_SETTINGS["CONFIG"]["REFRESH_SECS"];

	sParseCombatLog = VUHDO_CONFIG["PARSE_COMBAT_LOG"];

	return;

end


----------------------------------------------------

local VUHDO_VARIABLES_LOADED = false;
local VUHDO_IS_RELOAD_BUFFS = false;
local VUHDO_LOST_CONTROL = false;
local VUHDO_RELOAD_AFTER_BATTLE = false;
local VUHDO_OPTIONS_SHOW_AFTER_BATTLE = false;
local VUHDO_GCD_UPDATE = false;

local VUHDO_RELOAD_PANEL_NUM = nil;


VUHDO_TIMERS = {
	["RELOAD_UI"] = 0,
	["RELOAD_PANEL"] = 0,
	["CUSTOMIZE"] = 0,
	["CHECK_PROFILES"] = 6.2,
	["RELOAD_ZONES"] = 3.45,
	["UPDATE_CLUSTERS"] = 0,
	["REFRESH_INSPECT"] = 2.1,
	["REFRESH_TOOLTIP"] = 2.3,
	["UPDATE_AGGRO"] = 0,
	["UPDATE_RANGE"] = 1,
	["UPDATE_HOTS"] = 0.25,
	["REFRESH_TARGETS"] = 0.51,
	["RELOAD_RAID"] = 0,
	["RELOAD_ROSTER"] = 0,
	["REFRESH_DRAG"] = 0.05,
	["MIRROR_TO_MACRO"] = 8,
	["REFRESH_CUDE_TOOLTIP"] = 1,
	["UPDATE_AOE"] = 3,
	["BUFF_WATCH"] = 1,
};
local VUHDO_TIMERS = VUHDO_TIMERS;


VUHDO_CONFIG = nil;
VUHDO_PANEL_SETUP = nil;
VUHDO_SPELL_ASSIGNMENTS = nil;
VUHDO_SPELLS_KEYBOARD = nil;
VUHDO_SPELL_CONFIG = nil;

VUHDO_IS_RELOADING = false;
VUHDO_FONTS = { };
VUHDO_STATUS_BARS = { };
VUHDO_SOUNDS = { };
VUHDO_BORDERS = { };


VUHDO_MAINTANK_NAMES = { };
local VUHDO_FIRST_RELOAD_UI = false;



--
function VUHDO_isVariablesLoaded()

	return VUHDO_VARIABLES_LOADED;

end



--
function VUHDO_initBuffs()

	VUHDO_initBuffsFromSpellBook();
	VUHDO_reloadBuffPanel();

	return;

end



--
function VUHDO_initTooltipTimer()

	VUHDO_TIMERS["REFRESH_TOOLTIP"] = 2.3;

	return;

end



--
function VUHDO_initAllBurstCaches()

	VUHDO_tooltipInitLocalOverrides();
	VUHDO_modelToolsInitLocalOverrides();
	VUHDO_toolboxInitLocalOverrides();
	VUHDO_guiToolboxInitLocalOverrides();
	VUHDO_vuhdoInitLocalOverrides();
	VUHDO_spellEventHandlerInitLocalOverrides();
	VUHDO_macroFactoryInitLocalOverrides();
	VUHDO_keySetupInitLocalOverrides();
	VUHDO_combatLogInitLocalOverrides();
	VUHDO_eventHandlerInitLocalOverrides();
	VUHDO_customHealthInitLocalOverrides();
	VUHDO_customManaInitLocalOverrides();
	VUHDO_customTargetInitLocalOverrides();
	VUHDO_customClustersInitLocalOverrides();
	VUHDO_panelInitLocalOverrides();
	VUHDO_panelRedrawInitLocalOverrides();
	VUHDO_panelRefreshInitLocalOverrides();
	VUHDO_roleCheckerInitLocalOverrides();
	VUHDO_sizeCalculatorInitLocalOverrides();
	VUHDO_customHotsInitLocalOverrides();
	VUHDO_customDebuffIconsInitLocalOverrides();
	VUHDO_debuffsInitLocalOverrides();
	VUHDO_healCommAdapterInitLocalOverrides();
	VUHDO_buffWatchInitLocalOverrides();
	VUHDO_clusterBuilderInitLocalOverrides();
	VUHDO_aoeAdvisorInitLocalOverrides();
	VUHDO_bouquetValidatorsSpellTraceInitLocalOverrides();
	VUHDO_bouquetValidatorsStatusInitLocalOverrides();
	VUHDO_bouquetValidatorsInitLocalOverrides();
	VUHDO_bouquetsInitLocalOverrides();
	VUHDO_textProvidersInitLocalOverrides();
	VUHDO_textProviderHandlersInitLocalOverrides();
	VUHDO_actionEventHandlerInitLocalOverrides();
	VUHDO_directionsInitLocalOverrides();
	VUHDO_dcShieldInitLocalOverrides();
	VUHDO_shieldAbsorbInitLocalOverrides();
	VUHDO_spellTraceInitLocalOverrides();
	VUHDO_playerTargetEventHandlerInitLocalOverrides();

	return;

end



--
local function VUHDO_initOptions()

	if VuhDoNewOptionsTabbedFrame then
		VUHDO_initHotComboModels();
		VUHDO_initHotBarComboModels();
		VUHDO_initDebuffIgnoreComboModel();
		VUHDO_initBouquetComboModel();
		VUHDO_initBouquetSlotsComboModel();
		VUHDO_bouquetsUpdateDefaultColors();
	end

	return;

end



--
local tName;
local tProfile;
function VUHDO_loadCurrentProfile()

	if not VUHDO_CONFIG then
		return;
	end

	tName = VUHDO_CONFIG["CURRENT_PROFILE"];

	if (tName or "") ~= "" then
		_, tProfile = VUHDO_getProfileNamedCompressed(tName);

		if tProfile then
			if tProfile["LOCKED"] then
				VUHDO_Msg("Profile " .. tProfile["NAME"] .. " is currently locked and has NOT been loaded.");

				return;
			end

			VUHDO_loadProfileNoInit(tName);
		else
			VUHDO_Msg("Error: Currently selected profile \"" .. tName .. "\" doesn't exist.", 1, 0.4, 0.4);
		end
	end

	return;

end



--
local tName;
local function VUHDO_loadCurrentKeyLayout()

	if not VUHDO_CONFIG or not VUHDO_SPEC_LAYOUTS then
		return;
	end

	tName = VUHDO_SPEC_LAYOUTS["selected"];

	if (tName or "") ~= "" then
		if VUHDO_SPELL_LAYOUTS and VUHDO_SPELL_LAYOUTS[tName] then
			VUHDO_activateLayoutNoInit(tName);
		else
			VUHDO_Msg("Error: Currently selected key layout \"" .. tName .. "\" doesn't exist.", 1, 0.4, 0.4);
		end
	end

	return;

end



--
local tProfile;
local function VUHDO_loadDefaultProfile()

	if not VUHDO_CONFIG then
		return;
	end

	if ((VUHDO_CONFIG["CURRENT_PROFILE"] or "") == "") and ((VUHDO_DEFAULT_PROFILE or "") ~= "") then
		_, tProfile = VUHDO_getProfileNamedCompressed(VUHDO_DEFAULT_PROFILE);

		if tProfile then
			if tProfile["LOCKED"] then
				VUHDO_Msg("Profile " .. tProfile["NAME"] .. " is currently locked and has NOT been loaded.");

				return;
			end

			VUHDO_loadProfile(VUHDO_DEFAULT_PROFILE);
		else
			VUHDO_Msg("Error: Default profile \"" .. VUHDO_DEFAULT_PROFILE .. "\" doesn't exist.", 1, 0.4, 0.4);
		end
	end

	return;

end



--
local function VUHDO_loadDefaultLayout()

	if not VUHDO_SPEC_LAYOUTS then
		return;
	end

	if ((VUHDO_SPEC_LAYOUTS["selected"] or "") == "") and ((VUHDO_DEFAULT_LAYOUT or "") ~= "") then
		if VUHDO_SPELL_LAYOUTS and VUHDO_SPELL_LAYOUTS[VUHDO_DEFAULT_LAYOUT] ~= nil then
			VUHDO_activateLayout(VUHDO_DEFAULT_LAYOUT);
		else
			VUHDO_Msg(VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 .. VUHDO_DEFAULT_LAYOUT .. VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2, 1, 0.4, 0.4);
		end
	end

	return;

end



--
local tLevel = 0;
local tHasPerCharacterConfig;
local function VUHDO_init()

	if tLevel == 0 or VUHDO_VARIABLES_LOADED then
		tLevel = 1;

		return;
	end

	--VUHDO_COMBAT_LOG_TRACE = {};

	if not VUHDO_RAID then
		VUHDO_RAID = { };
	end

	tHasPerCharacterConfig = _G["VUHDO_CONFIG"] and true or false;

	VUHDO_loadCurrentProfile(); -- 1. Diese Reihenfolge scheint wichtig zu sein, erzeugt
	VUHDO_loadCurrentKeyLayout();

	VUHDO_loadVariables(); -- 2. umgekehrt undefiniertes Verhalten (VUHDO_CONFIG ist nil etc.)
	VUHDO_initAllBurstCaches();
	VUHDO_initDefaultProfiles();

	VUHDO_VARIABLES_LOADED = true;

	VUHDO_initPanelModels();
	VUHDO_initFromSpellbook();
	VUHDO_initBuffs();

	if not InCombatLockdown() then
		VUHDO_setIsOutOfCombat(true);
	end

	VUHDO_initDebuffs(); -- Too soon obviously => ReloadUI
	VUHDO_clearUndefinedModelEntries();
	VUHDO_registerAllBouquets(true);
	VUHDO_reloadUI(false);
	VUHDO_getAutoProfile();
	VUHDO_initCliqueSupport();

	if VuhDoNewOptionsTabbedFrame then
		VuhDoNewOptionsTabbedFrame:ClearAllPoints();
		VUHDO_PixelUtil.SetPoint(VuhDoNewOptionsTabbedFrame, "CENTER", "UIParent", "CENTER", 0, 0);
	end

	VUHDO_initSharedMedia();
	VUHDO_initFuBar();
	VUHDO_initButtonFacade(VUHDO_INSTANCE);
	VUHDO_initLibSpecialization();
	VUHDO_initHideBlizzFrames();
	VUHDO_initScaleMonitoring();

	if not InCombatLockdown() then
		VUHDO_initKeyboardMacros();
	end

	VUHDO_timeReloadUI(3);
	VUHDO_aoeUpdateTalents();

	if not tHasPerCharacterConfig then
		VUHDO_loadDefaultProfile();
		VUHDO_loadDefaultLayout();
	end

	return;

end



--
do
	--
	local tEventTotalStartTime;
	local tEventTotalDuration;
	local tUnitInfo;
	local tEmptyRaid = { };
	local tSpecNumber;
	local tBestProfileName;
	function VUHDO_OnEvent(anInstance, anEvent, anArg1, anArg2, anArg3, anArg4, anArg5, anArg6, anArg7, anArg8, anArg9, anArg10, anArg11, anArg12, anArg13, anArg14, anArg15, anArg16, anArg17, anArg18, anArg19)

		if VUHDO_HANDLER_PROFILING_ENABLED and anEvent then
			tEventTotalStartTime = debugprofilestop();
		end

		if "COMBAT_LOG_EVENT_UNFILTERED" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				-- As of 8.x COMBAT_LOG_EVENT_UNFILTERED is now just an event with no arguments
				anArg1, anArg2, anArg3, anArg4, anArg5, anArg6, anArg7, anArg8, anArg9, anArg10, anArg11, anArg12, anArg13, anArg14, anArg15, anArg16, anArg17, anArg18, anArg19 = CombatLogGetCurrentEventInfo();

				if sParseCombatLog then
					-- SWING_DAMAGE - the amount of damage is the 12th arg
					-- ENVIRONMENTAL_DAMAGE - the amount of damage is the 13th arg
					-- for all other events with the _DAMAGE suffix the amount of damage is the 15th arg
					VUHDO_parseCombatLogEvent(anArg2, anArg8, anArg12, anArg13, anArg15);
				end

				if VUHDO_INTERNAL_TOGGLES[36] then -- VUHDO_UPDATE_SHIELD
					-- for SPELL events with _AURA suffixes the amount healed is the 16th arg
					-- for SPELL_HEAL/SPELL_PERIODIC_HEAL the amount absorbed is the 17th arg
					-- for SPELL_ABSORBED the absorb spell ID is either the 16th or 19th arg
					VUHDO_parseCombatLogShieldAbsorb(anArg2, anArg4, anArg8, anArg13, anArg16, anArg12, anArg17, anArg19);
				end

				if VUHDO_INTERNAL_TOGGLES[37] then -- VUHDO_UPDATE_SPELL_TRACE
					VUHDO_parseCombatLogSpellTrace(
						anArg2,  -- message/event
						anArg4,  -- source GUID
						anArg8,  -- dest GUID
						anArg13, -- spell name
						anArg12, -- spell ID
						anArg16  -- amount
					);
				end
			end

		elseif "UNIT_AURA" == anEvent then
			tUnitInfo = (VUHDO_RAID or tEmptyRaid)[anArg1];

			if tUnitInfo then
				tUnitInfo["debuff"], tUnitInfo["debuffName"] = VUHDO_determineDebuff(anArg1, anArg2);
				VUHDO_updateBouquetsForEvent(anArg1, 4); -- VUHDO_UPDATE_DEBUFF
			end

		elseif "UNIT_HEALTH" == anEvent then
			if anArg1 and ((VUHDO_RAID or tEmptyRaid)[anArg1] or VUHDO_isBossUnit(anArg1)) then
				VUHDO_updateHealth(anArg1, 2);
			end

		elseif "UNIT_HEAL_PREDICTION" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then -- auch target, focus
				VUHDO_updateHealth(anArg1, 9); -- VUHDO_UPDATE_INC
				VUHDO_updateBouquetsForEvent(anArg1, 9); -- VUHDO_UPDATE_INC
			end

		elseif "UNIT_POWER_UPDATE" == anEvent or "UNIT_POWER_FREQUENT" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then
				if "CHI" == anArg2 then
					if "player" == anArg1 then
						VUHDO_updateBouquetsForEvent("player", 35); -- VUHDO_UPDATE_CHI
					end
				elseif "HOLY_POWER" == anArg2 then
					if "player" == anArg1 then
						VUHDO_updateBouquetsForEvent("player", 31); -- VUHDO_UPDATE_OWN_HOLY_POWER
					end
				elseif "COMBO_POINTS" == anArg2 then
					if "player" == anArg1 then
						VUHDO_updateBouquetsForEvent("player", 40); -- VUHDO_UPDATE_COMBO_POINTS
					end
				elseif "SOUL_SHARDS" == anArg2 then
					if "player" == anArg1 then
						VUHDO_updateBouquetsForEvent("player", 41); -- VUHDO_UPDATE_SOUL_SHARDS
					end
				elseif "RUNES" == anArg2 then
					if "player" == anArg1 then
						VUHDO_updateBouquetsForEvent("player", 42); -- VUHDO_UPDATE_RUNES
					end
				elseif "ARCANE_CHARGES" == anArg2 then
					if "player" == anArg1 then
						VUHDO_updateBouquetsForEvent("player", 43); -- VUHDO_UPDATE_ARCANE_CHARGES
					end
				elseif "ALTERNATE" == anArg2 then
					VUHDO_updateBouquetsForEvent(anArg1, 30); -- VUHDO_UPDATE_ALT_POWER
				else
					VUHDO_updateManaBars(anArg1, 1);
				end
			end

		elseif "UNIT_ABSORB_AMOUNT_CHANGED" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then
				VUHDO_updateBouquetsForEvent(anArg1, 36); -- VUHDO_UPDATE_SHIELD

				VUHDO_updateShieldBar(anArg1);
			end

		elseif "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then
				VUHDO_updateBouquetsForEvent(anArg1, 36); -- VUHDO_UPDATE_SHIELD

				VUHDO_updateHealAbsorbBar(anArg1);
			end

		elseif "UNIT_SPELLCAST_SENT" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				VUHDO_spellcastSent(anArg1, anArg2, anArg4);
			end

		elseif "UNIT_SPELLCAST_START" == anEvent or "UNIT_SPELLCAST_DELAYED" == anEvent or "UNIT_SPELLCAST_CHANNEL_START" == anEvent or
			"UNIT_SPELLCAST_CHANNEL_UPDATE" == anEvent then
			if VUHDO_VARIABLES_LOADED and VUHDO_INTERNAL_TOGGLES[37] and VUHDO_CONFIG["SHOW_SPELL_TRACE"] and anArg1 and
				((VUHDO_CONFIG["SPELL_TRACE"]["showIncomingEnemy"] and UnitIsEnemy(anArg1, "player")) or
					(VUHDO_CONFIG["SPELL_TRACE"]["showIncomingFriendly"] and UnitIsFriend(anArg1, "player"))) then
				VUHDO_addIncomingSpellTrace(anArg1, anArg2, anArg3);
			end

		elseif "UNIT_SPELLCAST_STOP" == anEvent or "UNIT_SPELLCAST_INTERRUPTED" == anEvent or "UNIT_SPELLCAST_FAILED" == anEvent or
			"UNIT_SPELLCAST_FAILED_QUIET" == anEvent or "UNIT_SPELLCAST_CHANNEL_STOP" == anEvent then
			if VUHDO_VARIABLES_LOADED and VUHDO_INTERNAL_TOGGLES[37] and VUHDO_CONFIG["SHOW_SPELL_TRACE"] and anArg1 and
				((VUHDO_CONFIG["SPELL_TRACE"]["showIncomingEnemy"] and UnitIsEnemy(anArg1, "player")) or
					(VUHDO_CONFIG["SPELL_TRACE"]["showIncomingFriendly"] and UnitIsFriend(anArg1, "player"))) then
				VUHDO_removeIncomingSpellTrace(anArg1, anArg2, anArg3);
			end

		elseif "NAME_PLATE_UNIT_REMOVED" == anEvent then
			if anArg1 and VUHDO_VARIABLES_LOADED and VUHDO_INTERNAL_TOGGLES[37] and VUHDO_CONFIG["SHOW_SPELL_TRACE"] then
				VUHDO_cleanupSpellTraceForUnit(anArg1);
			end

		elseif "UNIT_THREAT_SITUATION_UPDATE" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				VUHDO_updateUnitAggro(anArg1);
			end

		elseif "PLAYER_REGEN_ENABLED" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				VUHDO_updateAllAggro();
			end

			if VUHDO_OPTIONS_SHOW_AFTER_BATTLE and VuhDoNewOptionsTabbedFrame and not VuhDoNewOptionsTabbedFrame:IsShown() then
				VuhDoNewOptionsTabbedFrame:SetShown(true);

				VUHDO_OPTIONS_SHOW_AFTER_BATTLE = false;
			end

			VUHDO_setIsOutOfCombat(true);

		elseif "PLAYER_REGEN_DISABLED" == anEvent then
			if VuhDoNewOptionsTabbedFrame and VuhDoNewOptionsTabbedFrame:IsShown() then
				VuhDoNewOptionsTabbedFrame:SetShown(false);

				VUHDO_OPTIONS_SHOW_AFTER_BATTLE = true;
			end

			VUHDO_processCombatUnsafeTasksBeforeLockdown();

			VUHDO_setIsOutOfCombat(false);

		elseif "UNIT_MAXHEALTH" == anEvent then
			if anArg1 and (VUHDO_RAID or tEmptyRaid)[anArg1] then
				VUHDO_updateHealth(anArg1, VUHDO_UPDATE_HEALTH_MAX);
			end

		elseif "UNIT_TARGET" == anEvent then
			if VUHDO_VARIABLES_LOADED and "player" ~= anArg1 then
				VUHDO_updateTargetBars(anArg1); -- TODO: add deferred task
				VUHDO_updateBouquetsForEvent(anArg1, 22); -- VUHDO_UPDATE_UNIT_TARGET
				VUHDO_updatePanelVisibility();
			end

		elseif "UNIT_DISPLAYPOWER" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then
				VUHDO_updateManaBars(anArg1, 3);
			end

		elseif "UNIT_MAXPOWER" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then
				if "ALTERNATE" == anArg2 then
					VUHDO_updateBouquetsForEvent(anArg1, 30); -- VUHDO_UPDATE_ALT_POWER
				else
					VUHDO_updateManaBars(anArg1, 2);
				end
			end

		elseif "UNIT_PET" == anEvent then
			if VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS] or not InCombatLockdown() then
				VUHDO_REMOVE_HOTS = false;

				if "player" == anArg1 then
					VUHDO_quickRaidReload();
				else
					VUHDO_normalRaidReload();
				end
			end

		elseif "UNIT_ENTERED_VEHICLE" == anEvent or "UNIT_EXITED_VEHICLE" == anEvent or "UNIT_EXITING_VEHICLE" == anEvent then
			VUHDO_REMOVE_HOTS = false;

			VUHDO_normalRaidReload();

		elseif "RAID_TARGET_UPDATE" == anEvent then
			VUHDO_TIMERS["CUSTOMIZE"] = 0.1;

		-- INSTANCE_ENCOUNTER_ENGAGE_UNIT fires when a boss unit is added to the UI
		-- this is essentially the equivalent of GROUP_ROSTER_UPDATE for bosses/NPCs
		elseif "GROUP_ROSTER_UPDATE" == anEvent or "INSTANCE_ENCOUNTER_ENGAGE_UNIT" == anEvent or "UPDATE_ACTIVE_BATTLEFIELD" == anEvent then
			if VUHDO_FIRST_RELOAD_UI then
				VUHDO_normalRaidReload(true);

				if VUHDO_TIMERS["RELOAD_ROSTER"] < 0.4 then
					VUHDO_TIMERS["RELOAD_ROSTER"] = 0.6;
				end
			end

		elseif "PLAYER_FOCUS_CHANGED" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				if VUHDO_RAID["focus"] then
					VUHDO_determineIncHeal("focus");
					VUHDO_updateHealth("focus", 9); -- VUHDO_UPDATE_INC
				end

				VUHDO_clParserSetCurrentFocus();

				if VUHDO_isModelConfigured(VUHDO_ID_FOCUS) or
					(VUHDO_isModelConfigured(VUHDO_ID_PRIVATE_TANKS) and not VUHDO_CONFIG["OMIT_FOCUS"]) then
					if VUHDO_INTERNAL_TOGGLES[37] and VUHDO_CONFIG["SHOW_SPELL_TRACE"] then
						VUHDO_cleanupSpellTraceForUnit("focus");

						VUHDO_cleanupStaleSpellTracesForTargetFocus();
					end

					if UnitExists("focus") then
						VUHDO_setHealth("focus", 1); -- VUHDO_UPDATE_ALL
					else
						VUHDO_removeHots("focus");
						VUHDO_removeAllDebuffIcons("focus");
						VUHDO_resetDebuffsFor("focus");

						if VUHDO_RAID["focus"] then
							table.wipe(VUHDO_RAID["focus"]);
						end

						VUHDO_RAID["focus"] = nil;
					end

					VUHDO_updateHealthBarsFor("focus", 1); -- VUHDO_UPDATE_ALL
					VUHDO_initEventBouquetsFor("focus");
				end

				VUHDO_updateBouquetsForEvent("player", 23); -- VUHDO_UPDATE_PLAYER_FOCUS
				VUHDO_updateBouquetsForEvent("focus", 23); -- VUHDO_UPDATE_PLAYER_FOCUS

				VUHDO_updatePanelVisibility();
			end

		elseif "PARTY_MEMBER_ENABLE" == anEvent or "PARTY_MEMBER_DISABLE" == anEvent then
			VUHDO_TIMERS["CUSTOMIZE"] = 0.2;

		elseif "PLAYER_FLAGS_CHANGED" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then
				VUHDO_updateHealth(anArg1, 6); -- VUHDO_UPDATE_AFK
				VUHDO_updateBouquetsForEvent(anArg1, 6); -- VUHDO_UPDATE_AFK
			end

		elseif "PLAYER_ENTERING_WORLD" == anEvent then
			VUHDO_init();
			VUHDO_initAddonMessages();

			if VUHDO_VARIABLES_LOADED and VUHDO_INTERNAL_TOGGLES[37] and VUHDO_CONFIG["SHOW_SPELL_TRACE"] then
				VUHDO_clearAllSpellTraces();
			end

		elseif "UNIT_POWER_BAR_SHOW" == anEvent or "UNIT_POWER_BAR_HIDE" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then
				VUHDO_RAID[anArg1]["isAltPower"] = VUHDO_isAltPowerActive(anArg1);
				VUHDO_updateBouquetsForEvent(anArg1, 30); -- VUHDO_UPDATE_ALT_POWER
			end

		elseif "LEARNED_SPELL_IN_SKILL_LINE" == anEvent or "TRAIT_CONFIG_UPDATED" == anEvent or "SPELLS_CHANGED" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				VUHDO_initFromSpellbook();
				VUHDO_registerAllBouquets(false);
				VUHDO_initBuffs();
				VUHDO_initDebuffs();

				if not InCombatLockdown() then
					VUHDO_initKeyboardMacros();
					VUHDO_timeReloadUI(1);
				end

				if "SPELLS_CHANGED" == anEvent then
					-- workaround slow clients where partial spellbook is available on SPELLS_CHANGED
					C_Timer.After(3, VUHDO_initBuffs);
				end
			end

		elseif "VARIABLES_LOADED" == anEvent then
			VUHDO_init();

		elseif "UPDATE_BINDINGS" == anEvent then
			if not InCombatLockdown() and VUHDO_VARIABLES_LOADED then
				VUHDO_initKeyboardMacros();
			end

		elseif "PLAYER_TARGET_CHANGED" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				VUHDO_updatePlayerTarget();

				VUHDO_updateHealth("player", 1);
				VUHDO_updateBouquetsForEvent("player", 22); -- VUHDO_UPDATE_UNIT_TARGET

				VUHDO_updateHealth("target", 1);
				VUHDO_updateBouquetsForEvent("target", 22); -- VUHDO_UPDATE_UNIT_TARGET

				VUHDO_updatePanelVisibility();
			end

		elseif "CHAT_MSG_ADDON" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				VUHDO_parseAddonMessage(anArg1, anArg2, anArg4);
			end

		elseif "READY_CHECK" == anEvent then
			if VUHDO_RAID then
				VUHDO_readyStartCheck(anArg1, anArg2);
			end

		elseif "READY_CHECK_CONFIRM" == anEvent then
			if VUHDO_RAID then
				VUHDO_readyCheckConfirm(anArg1, anArg2);
			end

		elseif "READY_CHECK_FINISHED" == anEvent then
			if VUHDO_RAID then
				VUHDO_readyCheckEnds();
			end

		elseif "CVAR_UPDATE" == anEvent then
			-- Patch 10.0.0 makes setting CVars freeze the game client
			-- FIXME: also there is some issue where this event fires before bouquets have been properly decompressed
			VUHDO_IS_SFX_ENABLED = false; --tonumber(GetCVar("Sound_EnableSFX")) == 1;
			VUHDO_IS_SOUND_ERRORSPEECH_ENABLED = false; --tonumber(GetCVar("Sound_EnableErrorSpeech")) == 1;
			--if VUHDO_VARIABLES_LOADED then VUHDO_reloadUI(false); end

		elseif "INSPECT_READY" == anEvent then
			VUHDO_inspectLockRole();

		elseif "UNIT_CONNECTION" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then
				VUHDO_updateHealth(anArg1, VUHDO_UPDATE_DC);
			end

		elseif "ROLE_CHANGED_INFORM" == anEvent then
			if VUHDO_RAID_NAMES[anArg1] then
				VUHDO_resetTalentScan(VUHDO_RAID_NAMES[anArg1]);
			end

		elseif "MODIFIER_STATE_CHANGED" == anEvent then
			if VuhDoTooltip:IsShown() then
				VUHDO_updateTooltip();
			end

		elseif "PLAYER_LOGOUT" == anEvent then
			VUHDO_compressAllBouquets();

		elseif "UNIT_NAME_UPDATE" == anEvent then
			if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
				VUHDO_resetNameTextCache();

				VUHDO_updateHealthBarsFor(anArg1, 7); -- VUHDO_UPDATE_AGGRO
			end

		elseif "PLAYER_EQUIPMENT_CHANGED" == anEvent then
			VUHDO_aoeUpdateSpellAverages();

		elseif "LFG_PROPOSAL_SHOW" == anEvent then
			VUHDO_buildSafeParty();

		elseif "LFG_PROPOSAL_FAILED" == anEvent then
			VUHDO_quickRaidReload();

		elseif "LFG_PROPOSAL_SUCCEEDED" == anEvent then
			VUHDO_lateRaidReload();

		--elseif("UPDATE_MACROS" == anEvent) then
			--VUHDO_timeReloadUI(0.1); -- @WARNING Ldt wg. shield macro alle 8 sec.

		elseif "UNIT_FACTION" == anEvent then
			if (VUHDO_RAID or tEmptyRaid)[anArg1] then
				VUHDO_updateBouquetsForEvent(anArg1, 34); -- VUHDO_UPDATE_MINOR_FLAGS
			end

		elseif "INCOMING_RESURRECT_CHANGED" == anEvent then
			if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
				VUHDO_updateBouquetsForEvent(anArg1, 25); -- VUHDO_UPDATE_RESURRECTION
			end

		elseif "PET_BATTLE_OPENING_START" == anEvent then
			VUHDO_setPetBattle(true);

		elseif "PET_BATTLE_CLOSE" == anEvent then
			VUHDO_setPetBattle(false);

		elseif "INCOMING_SUMMON_CHANGED" == anEvent then
			if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
				VUHDO_updateBouquetsForEvent(anArg1, 38); -- VUHDO_UPDATE_SUMMON
			end

		elseif "UNIT_PHASE" == anEvent then
			if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
				VUHDO_updateBouquetsForEvent(anArg1, 39); -- VUHDO_UPDATE_PHASE
			end

		elseif "RUNE_POWER_UPDATE" == anEvent then
			VUHDO_updateBouquetsForEvent("player", 42); -- VUHDO_UPDATE_RUNES

		elseif "PLAYER_SPECIALIZATION_CHANGED" == anEvent or "ACTIVE_TALENT_GROUP_CHANGED" == anEvent then
			if VUHDO_VARIABLES_LOADED and not InCombatLockdown() then
				if "ACTIVE_TALENT_GROUP_CHANGED" == anEvent then
					anArg1 = "player";
				end

				if "player" == anArg1 then
					tSpecNumber = tostring(GetSpecialization()) or "1";
					tBestProfileName = VUHDO_getBestProfileAfterSpecChange();

					-- event sometimes fires multiple times so we must de-dupe
					if (not VUHDO_strempty(VUHDO_SPEC_LAYOUTS[tSpecNumber]) and (VUHDO_SPEC_LAYOUTS["selected"] ~= VUHDO_SPEC_LAYOUTS[tSpecNumber])) or
						(not VUHDO_strempty(tBestProfileName) and (VUHDO_CONFIG["CURRENT_PROFILE"] ~= tBestProfileName)) then
						VUHDO_activateSpecc(tSpecNumber);
					end
				end

				if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
					VUHDO_resetTalentScan(anArg1);
					VUHDO_initDebuffs(); -- Talentabhngige Debuff-Fhigkeiten neu initialisieren.
					VUHDO_timeReloadUI(1);
				end
			end

		elseif "UI_SCALE_CHANGED" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				VUHDO_handleScaleChange();
			end

		elseif "DISPLAY_SIZE_CHANGED" == anEvent then
			if VUHDO_VARIABLES_LOADED then
				VUHDO_handleScaleChange();
			end

		else
			VUHDO_Msg("Error: Unexpected event: " .. anEvent);
		end

		if VUHDO_HANDLER_PROFILING_ENABLED and anEvent then
			tEventTotalDuration = (debugprofilestop() - tEventTotalStartTime) * 1000;

			VUHDO_updateHandlerOnEventMetrics(anEvent, tEventTotalDuration, anArg1, anArg2, anArg3, anArg4, anArg5);
		end

		return;

	end
end



--
local function VUHDO_setPanelsVisible(anIsVisible)

	if not InCombatLockdown() then
		VUHDO_CONFIG["SHOW_PANELS"] = anIsVisible;

		VUHDO_Msg(anIsVisible and VUHDO_I18N_PANELS_SHOWN or VUHDO_I18N_PANELS_HIDDEN);

		VUHDO_redrawAllPanels(false);
		VUHDO_saveCurrentProfile();
	else
		VUHDO_Msg("Not possible during combat!");
	end

	return;

end



--
local function VUHDO_printAbout()

	VUHDO_Msg("VuhDo |cffffe566['vu:du:]|r v" .. VUHDO_VERSION .. " (use /vd). Currently maintained by Ivaria@US-Hyjal in honor of Anny and our two daughters.");

	return;

end



--
do
	--
	local tParsedTexts;
	local tCommandWord;
	local tTokens;
	local tName;
	local tUnit;
	local tSubCommand;
	local tPanelNum;
	local tHelpText;
	function VUHDO_slashCmd(aCommand)

		tParsedTexts = VUHDO_textParse(aCommand);
		tCommandWord = strlower(tParsedTexts[1]);

		if strfind(tCommandWord, "opt") then
			if VuhDoNewOptionsTabbedFrame then
				if InCombatLockdown() and not VuhDoNewOptionsTabbedFrame:IsShown() then
					VUHDO_Msg("戰鬥中無法使用設定選項!", 1, 0.4, 0.4);
				else
					VUHDO_CURR_LAYOUT = VUHDO_SPEC_LAYOUTS["selected"];
					VUHDO_CURRENT_PROFILE = VUHDO_CONFIG["CURRENT_PROFILE"];

					VUHDO_toggleMenu(VuhDoNewOptionsTabbedFrame);
				end
			else
				VUHDO_Msg(VUHDO_I18N_OPTIONS_NOT_LOADED, 1, 0.4, 0.4);
			end

		elseif tCommandWord == "pt" then
			if tParsedTexts[2] then
				tTokens = VUHDO_splitString(tParsedTexts[2], ",");

				if "clear" == tTokens[1] then
					table.wipe(VUHDO_PLAYER_TARGETS);

					VUHDO_quickRaidReload();
				else
					for _, tName in ipairs(tTokens) do
						tName = strtrim(tName);

						if VUHDO_RAID_NAMES[tName] ~= nil and not InCombatLockdown() then
							VUHDO_PLAYER_TARGETS[tName] = true;
						end
					end

					VUHDO_quickRaidReload();
				end
			else
				tUnit = VUHDO_RAID_NAMES[UnitName("target")];
				tName = (VUHDO_RAID[tUnit] or {})["name"];

				if not InCombatLockdown() and tName then
					if VUHDO_PLAYER_TARGETS[tName] then
						VUHDO_PLAYER_TARGETS[tName] = nil;
					else
						VUHDO_PLAYER_TARGETS[tName] = true;
					end

					VUHDO_quickRaidReload();
				end
			end

		elseif tCommandWord == "load" and tParsedTexts[2] then
			tTokens = VUHDO_splitString(tParsedTexts[2] .. (tParsedTexts[3] or ""), ",");

			if #tTokens >= 2 and not VUHDO_strempty(tTokens[2]) then
				tName = strtrim(tTokens[2]);

				if (VUHDO_SPELL_LAYOUTS[tName] ~= nil) then
					VUHDO_activateLayout(tName);
				else
					VUHDO_Msg(VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 .. tName .. VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2, 1, 0.4, 0.4);
				end
			end

			if #tTokens >= 1 and not VUHDO_strempty(tTokens[1]) then
				VUHDO_loadProfile(strtrim(tTokens[1]));
			end

		elseif strfind(tCommandWord, "res") then
			for tPanelNum = 1, VUHDO_MAX_PANELS do
				VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] = nil;
			end

			VUHDO_BUFF_SETTINGS["CONFIG"]["POSITION"] = {
				["x"] = 100, ["y"] = -100, ["point"] = "TOPLEFT", ["relativePoint"] = "TOPLEFT",
			};

			VUHDO_loadDefaultPanelSetup();
			VUHDO_reloadUI(false);

			VUHDO_Msg(VUHDO_I18N_PANELS_RESET);

		elseif tCommandWord == "lock" then
			VUHDO_CONFIG["LOCK_PANELS"] = not VUHDO_CONFIG["LOCK_PANELS"];

			if (VUHDO_CONFIG["LOCK_PANELS"]) then
				VUHDO_Msg(VUHDO_I18N_LOCK_PANELS_PRE .. VUHDO_I18N_LOCK_PANELS_LOCKED);
			else
				VUHDO_Msg(VUHDO_I18N_LOCK_PANELS_PRE .. VUHDO_I18N_LOCK_PANELS_UNLOCKED);
			end

			VUHDO_saveCurrentProfile();

		elseif tCommandWord == "show" then
			VUHDO_setPanelsVisible(true);

		elseif tCommandWord == "hide" then
			VUHDO_setPanelsVisible(false);

		elseif tCommandWord == "toggle" then
			VUHDO_setPanelsVisible(not VUHDO_CONFIG["SHOW_PANELS"]);

		elseif strfind(tCommandWord, "cast") or tCommandWord == "mt" then
			VUHDO_ctraBroadCastMaintanks();

			VUHDO_Msg(VUHDO_I18N_MTS_BROADCASTED);

		elseif (tCommandWord == "pron") then
			SetCVar("scriptProfile", "1");
			ReloadUI();

		elseif tCommandWord == "proff" then
			SetCVar("scriptProfile", "0");
			ReloadUI();

		elseif (strfind(tCommandWord, "chkvars")) then
			table.wipe(VUHDO_DEBUG);

			for tFName, _ in pairs(_G) do
				if(strsub(tFName, 1, 1) == "t" or strsub(tFName, 1, 1) == "s") then
					VUHDO_Msg("Emerging local variable " .. tFName);
				end
			end

		elseif strfind(tCommandWord, "mm") or strfind(tCommandWord, "map") then
			VUHDO_MM_SETTINGS["hide"] = VUHDO_forceBooleanValue(VUHDO_MM_SETTINGS["hide"]);
			VUHDO_MM_SETTINGS["hide"] = not VUHDO_MM_SETTINGS["hide"];

			VUHDO_initShowMinimap();

			VUHDO_Msg(VUHDO_I18N_MM_ICON .. (VUHDO_MM_SETTINGS["hide"] and VUHDO_I18N_CHAT_HIDDEN or VUHDO_I18N_CHAT_SHOWN));

		elseif strfind(tCommandWord, "compart") then
			VUHDO_MM_SETTINGS["addon_compartment_hide"] = VUHDO_forceBooleanValue(VUHDO_MM_SETTINGS["addon_compartment_hide"]);
			VUHDO_MM_SETTINGS["addon_compartment_hide"] = not VUHDO_MM_SETTINGS["addon_compartment_hide"];

			VUHDO_initShowAddOnCompartment();

			VUHDO_Msg(VUHDO_I18N_ADDON_COMPARTMENT_ICON ..
				(VUHDO_MM_SETTINGS["addon_compartment_hide"] and VUHDO_I18N_CHAT_HIDDEN or VUHDO_I18N_CHAT_SHOWN));

		elseif tCommandWord == "ui" then
			VUHDO_reloadUI(false);

		elseif strfind(tCommandWord, "role") then
			VUHDO_Msg("Roles have been reset.");

			table.wipe(VUHDO_MANUAL_ROLES);

			VUHDO_reloadUI(false);

		elseif tCommandWord == "test" then
			table.wipe(VUHDO_DEBUG);

			collectgarbage("collect");

		elseif tCommandWord == "pool" then
			tSubCommand = strlower(tParsedTexts[2] or "");

			if tSubCommand == "on" then
				VUHDO_setPoolProfiling(true);
			elseif tSubCommand == "off" then
				VUHDO_setPoolProfiling(false);
			elseif strfind(tSubCommand, "res") then
				VUHDO_resetPoolMetrics();
			else
				VUHDO_printPoolMetrics();
			end

		elseif tCommandWord == "task" then
			tSubCommand = strlower(tParsedTexts[2] or "");

			if tSubCommand == "on" then
				VUHDO_setDeferredTaskProfiling(true);
			elseif tSubCommand == "off" then
				VUHDO_setDeferredTaskProfiling(false);
			elseif strfind(tSubCommand, "res") then
				VUHDO_resetDeferredTaskMetrics();
			else
				VUHDO_printDeferredTaskMetrics(false);
			end

		elseif strfind(tCommandWord, "hand") then
			tSubCommand = strlower(tParsedTexts[2] or "");

			if tSubCommand == "on" then
				VUHDO_setHandlerProfiling(true);
			elseif tSubCommand == "off" then
				VUHDO_setHandlerProfiling(false);
			elseif strfind(tSubCommand, "res") then
				VUHDO_resetHandlerMetrics();
			else
				VUHDO_printHandlerMetrics();
			end

		elseif strfind(tCommandWord, "sem") then
			tSubCommand = strlower(tParsedTexts[2] or "");

			if tSubCommand == "on" then
				VUHDO_setSemaphoreProfiling(true);
			elseif tSubCommand == "off" then
				VUHDO_setSemaphoreProfiling(false);
			elseif strfind(tSubCommand, "res") then
				VUHDO_resetSemaphoreMetrics();
			else
				VUHDO_printSemaphoreMetrics();
			end

		elseif tCommandWord == "defer" then
			tSubCommand = strlower(tParsedTexts[2] or "");

			if tSubCommand == "on" then
				VUHDO_setDeferredRedrawEnabled(true);
			elseif tSubCommand == "off" then
				VUHDO_setDeferredRedrawEnabled(false);
			else
				VUHDO_printDeferredRedrawStatus();
			end

		elseif strfind(tCommandWord, "prof") then
			tSubCommand = strlower(tParsedTexts[2] or "");

			if tSubCommand == "on" then
				VUHDO_setHandlerProfiling(true);
				VUHDO_setDeferredTaskProfiling(true);
				VUHDO_setPoolProfiling(true);
				VUHDO_setSemaphoreProfiling(true);
			elseif tSubCommand == "off" then
				VUHDO_setHandlerProfiling(false);
				VUHDO_setDeferredTaskProfiling(false);
				VUHDO_setPoolProfiling(false);
				VUHDO_setSemaphoreProfiling(false);
			elseif strfind(tSubCommand, "res") then
				VUHDO_resetHandlerMetrics();
				VUHDO_resetDeferredTaskMetrics();
				VUHDO_resetPoolMetrics();
				VUHDO_resetSemaphoreMetrics();

				VUHDO_Msg("All profiling metrics reset.");
			elseif tSubCommand == "test" then
				VUHDO_testProfilingSystem();
			else
				VUHDO_showProfilingMetrics();
			end

		elseif tCommandWord == "pixel" then
			tSubCommand = strlower(tParsedTexts[2] or "");

			if tSubCommand == "test" then
				VUHDO_pixelTest();
			elseif tSubCommand == "spacing" then
				VUHDO_pixelTestSpacing();
			elseif tSubCommand == "hide" then
				VUHDO_pixelHideTestFrame();
			elseif tSubCommand == "scale" then
				VUHDO_pixelShowScale();
			elseif tSubCommand == "cache" then
				VUHDO_pixelPrintCacheStats();
			elseif tSubCommand == "validate" then
				tPanelNum = tonumber(tParsedTexts[3]);

				VUHDO_pixelValidate(tPanelNum);
			else
				VUHDO_pixelHelp();
			end

		elseif tCommandWord == "anim" then
			tSubCommand = strlower(tParsedTexts[2] or "");

			if tSubCommand == "test" then
				tCount = tonumber(tParsedTexts[3]) or 5;
				tCount = max(1, min(40, tCount));

				VUHDO_animTest(tCount);
			elseif tSubCommand == "hide" then
				VUHDO_animHideTestFrames();
			elseif tSubCommand == "on" then
				VUHDO_setAnimationGroupEnabled(true);
			elseif tSubCommand == "off" then
				VUHDO_setAnimationGroupEnabled(false);
			else
				VUHDO_animHelp();
			end

		elseif tCommandWord == "ab" or tCommandWord == "about" then
			VUHDO_printAbout();

		elseif aCommand == "?" or strfind(tCommandWord, "help") or aCommand == "" then
			tHelpText = (VUHDO_I18N_COMMAND_LIST or ""):gsub("\n", "|n");
			VUHDO_MsgC(tHelpText);

		else
			VUHDO_Msg(VUHDO_I18N_BAD_COMMAND, 1, 0.4, 0.4);
		end

		return;

	end
end



--
local tEvent;
local function VUHDO_UnRegisterEvent(aCondition, ...)

	for tCnt = 1, select("#", ...) do
		tEvent = select(tCnt, ...);

		if "UNIT_POWER_FREQUENT" == tEvent and aCondition then
			VUHDO_INSTANCE:RegisterUnitEvent(tEvent, "player");
		else
			if aCondition then
				VUHDO_INSTANCE:RegisterEvent(tEvent);
			else
				VUHDO_INSTANCE:UnregisterEvent(tEvent);
			end
		end
	end

	return;

end



--
local tIsShieldInterest;
local tIsHealAbsorbInterest;
function VUHDO_updateGlobalToggles()

	if not VUHDO_INSTANCE then
		return;
	end

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_LEVEL] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_THREAT_LEVEL);

	VUHDO_UnRegisterEvent(VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_LEVEL]
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_AGGRO),
		"UNIT_THREAT_SITUATION_UPDATE"
	);

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_THREAT_PERC);
	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_AGGRO);

	VUHDO_TIMERS["UPDATE_AGGRO"] =
		 (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] or VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO])
		 and 1 or -1;

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_NUM_CLUSTER);
	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_MOUSEOVER_CLUSTER);
	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AOE_ADVICE] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_AOE_ADVICE);

	if VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER]
	 or VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER]
	 or VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AOE_ADVICE]
	 or (VUHDO_isShowDirectionArrow() and VUHDO_CONFIG["DIRECTION"]["isDistanceText"]) then
		VUHDO_TIMERS["UPDATE_CLUSTERS"] = 1;
		VUHDO_TIMERS["UPDATE_AOE"] = VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AOE_ADVICE] and 1 or -1;
	else
		VUHDO_TIMERS["UPDATE_CLUSTERS"] = -1;
		VUHDO_TIMERS["UPDATE_AOE"] = -1;
	end

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_MOUSEOVER);
	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_GROUP] = VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_MOUSEOVER_GROUP);

	VUHDO_UnRegisterEvent(
		VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_MANA)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_OTHER_POWERS)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_ALT_POWER)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_OWN_HOLY_POWER)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_CHI)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_COMBO_POINTS)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SOUL_SHARDS)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_RUNES)
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_ARCANE_CHARGES),
		"UNIT_DISPLAYPOWER", "UNIT_MAXPOWER", "UNIT_POWER_UPDATE", "UNIT_POWER_FREQUENT"
	);

	if VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_UNIT_TARGET) then
		VUHDO_INSTANCE:RegisterEvent("UNIT_TARGET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_UNIT_TARGET] = true;
		VUHDO_TIMERS["REFRESH_TARGETS"] = 1;
	else
		VUHDO_INSTANCE:UnregisterEvent("UNIT_TARGET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_UNIT_TARGET] = false;
		VUHDO_TIMERS["REFRESH_TARGETS"] = -1;
	end

	VUHDO_UnRegisterEvent(VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_ALT_POWER),
		"UNIT_POWER_BAR_SHOW", "UNIT_POWER_BAR_HIDE");

	VUHDO_TIMERS["REFRESH_INSPECT"] = VUHDO_CONFIG["IS_SCAN_TALENTS"] and 1 or -1

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS]
		= VUHDO_isModelConfigured(VUHDO_ID_PETS)
		or VUHDO_isModelConfigured(VUHDO_ID_SELF_PET); -- Event nicht deregistrieren => Problem mit manchen Vehikeln

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET]
		= (VUHDO_isModelConfigured(VUHDO_ID_PRIVATE_TANKS) and not VUHDO_CONFIG["OMIT_TARGET"])
		or VUHDO_isModelConfigured(VUHDO_ID_TARGET);

	VUHDO_UnRegisterEvent(VUHDO_CONFIG["SHOW_INCOMING"] or VUHDO_CONFIG["SHOW_OWN_INCOMING"],
		"UNIT_HEAL_PREDICTION");

	VUHDO_UnRegisterEvent(not VUHDO_CONFIG["IS_READY_CHECK_DISABLED"],
		"READY_CHECK", "READY_CHECK_CONFIRM", "READY_CHECK_FINISHED");

	tIsShieldInterest =
		VUHDO_PANEL_SETUP["BAR_COLORS"]["HOTS"]["showShieldAbsorb"]
			or VUHDO_CONFIG["SHOW_SHIELD_BAR"]
			or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SHIELD);

	tIsHealAbsorbInterest =
		VUHDO_CONFIG["SHOW_HEAL_ABSORB_BAR"]
			or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SHIELD);

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_SHIELD] =
		tIsShieldInterest
			or tIsHealAbsorbInterest;

	VUHDO_UnRegisterEvent(tIsShieldInterest, "UNIT_ABSORB_AMOUNT_CHANGED");
	VUHDO_UnRegisterEvent(tIsHealAbsorbInterest, "UNIT_HEAL_ABSORB_AMOUNT_CHANGED");

	VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_SPELL_TRACE] = VUHDO_CONFIG["SHOW_SPELL_TRACE"]
		or VUHDO_isAnyoneInterestedIn(VUHDO_UPDATE_SPELL_TRACE);

	VUHDO_UnRegisterEvent(sParseCombatLog or VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_SPELL_TRACE],
		"COMBAT_LOG_EVENT_UNFILTERED");

	return;

end



--
function VUHDO_loadVariables()

	_, VUHDO_PLAYER_CLASS = UnitClass("player");
	VUHDO_PLAYER_NAME = UnitName("player");

	VUHDO_loadDefaultConfig();
	VUHDO_setDeferredRedrawEnabled(VUHDO_CONFIG["USE_DEFERRED_REDRAW"], true);
	VUHDO_loadSpellArray();
	VUHDO_loadDefaultPanelSetup();
	VUHDO_initBuffSettings();
	VUHDO_loadDefaultBouquets();
	VUHDO_panelRedrawInitLocalOverrides();
	VUHDO_initClassColors();
	VUHDO_initTextProviderConfig();

	VUHDO_lnfPatchFont(VuhDoOptionsTooltipText, "Text");

	return;

end



--
function VUHDO_normalRaidReload(anIsReloadBuffs)

	if VUHDO_isConfigPanelShowing() then
		return;
	end

	VUHDO_TIMERS["RELOAD_RAID"] = 2.3;

	if anIsReloadBuffs then
		VUHDO_IS_RELOAD_BUFFS = true;
	end

	return;

end



--
function VUHDO_quickRaidReload()

	VUHDO_TIMERS["RELOAD_RAID"] = 0.3;

	return;

end



--
function VUHDO_lateRaidReload()

	if not VUHDO_isReloadPending() then
		VUHDO_TIMERS["RELOAD_RAID"] = 5;
	end

	return;

end



--
function VUHDO_isReloadPending()

	return VUHDO_TIMERS["RELOAD_RAID"] > 0
		or VUHDO_TIMERS["RELOAD_UI"] > 0
		or VUHDO_IS_RELOADING;

end



--
function VUHDO_timeReloadUI(aNumSecs, anIsLnf)

	VUHDO_TIMERS["RELOAD_UI"] = aNumSecs;
	VUHDO_RELOAD_UI_IS_LNF = anIsLnf;

	return;

end



--
function VUHDO_timeRedrawPanel(aPanelNum, aNumSecs)

	VUHDO_RELOAD_PANEL_NUM = aPanelNum;
	VUHDO_TIMERS["RELOAD_PANEL"] = aNumSecs;

	return;

end






--
function VUHDO_initGcd()

	VUHDO_GCD_UPDATE = true;

	return;

end



--
local function VUHDO_doReloadRoster(anIsQuick)

	if not VUHDO_isConfigPanelShowing() then
		if VUHDO_IS_RELOADING then
			VUHDO_quickRaidReload();
		else
			VUHDO_rebuildTargets();

			if InCombatLockdown() then
				VUHDO_RELOAD_AFTER_BATTLE = true;
				VUHDO_IS_RELOADING = true;

				VUHDO_refreshRaidMembers();
				VUHDO_updateAllRaidBars();
				VUHDO_initAllEventBouquets();

				VUHDO_updatePanelVisibility();

				VUHDO_IS_RELOADING = false;
			else
				VUHDO_refreshUI();

				if VUHDO_IS_RELOAD_BUFFS and not anIsQuick then
					VUHDO_reloadBuffPanel();

					VUHDO_IS_RELOAD_BUFFS = false;
				end

				VUHDO_initHideBlizzRaid(); -- Scheint bei betreten eines Raids von aussen getriggert zu werden.
			end
		end

		VUHDO_initDebuffs(); -- Verzgerung nach Taltentwechsel-Spell?
	end

	return;

end



--
local sTimerDelta;
local function VUHDO_setTimerDelta(aTimeDelta)

	sTimerDelta = aTimeDelta;

	return;

end



--
local function VUHDO_checkResetTimer(aTimerName, aNextTick)

	if VUHDO_TIMERS[aTimerName] > 0 then
		VUHDO_TIMERS[aTimerName] = VUHDO_TIMERS[aTimerName] - sTimerDelta;

		if VUHDO_TIMERS[aTimerName] <= 0 then
			VUHDO_TIMERS[aTimerName] = aNextTick;

			return true;
		end
	end

	return false;

end



--
local function VUHDO_checkTimer(aTimerName)

	if VUHDO_TIMERS[aTimerName] > 0 then
		VUHDO_TIMERS[aTimerName] = VUHDO_TIMERS[aTimerName] - sTimerDelta;

		return VUHDO_TIMERS[aTimerName] <= 0;
	end

	return false;

end



--
do
	--
	local sTimeDelta = 0;
	local sSlowDelta = 0;
	local sHotDebuffToggle = 1;
	local sAutoProfile;
	local sTrigger;



	--
	local function VUHDO_finalizeOnUpdateMetrics(anOverallStart, aSeg2Start, aSegment1Total)

		if VUHDO_HANDLER_PROFILING_ENABLED then
			VUHDO_updateOnUpdateSubSegmentMetrics("segment1Total", aSegment1Total);
			VUHDO_updateOnUpdateSubSegmentMetrics("segment2Total", (debugprofilestop() - aSeg2Start) * 1000);
			VUHDO_updateOnUpdateSubSegmentMetrics("total", (debugprofilestop() - anOverallStart) * 1000);

			VUHDO_HANDLER_PROFILING_ONUPDATE_INVOCATIONS = VUHDO_HANDLER_PROFILING_ONUPDATE_INVOCATIONS + 1;
		end

		return;

	end



	--
	local tGcdStart;
	local tGcdDuration;
	local function VUHDO_handleSegment1A(aTimeDelta)

		-- Update GCD-Bar
		if VUHDO_GCD_UPDATE then
			tGcdStart, tGcdDuration = GetSpellCooldown(VUHDO_SPELL_ID.GLOBAL_COOLDOWN);

			if (tGcdDuration or 0) == 0 then
				VuhDoGcdStatusBar:SetValue(0);

				VUHDO_GCD_UPDATE = false;
			else
				VuhDoGcdStatusBar:SetValue((tGcdDuration - (GetTime() - tGcdStart)) / tGcdDuration);
			end
		end

		-- Direction Arrow
		if sIsDirectionArrow and VuhDoDirectionFrame["shown"] then
			VUHDO_updateDirectionFrame();
		end

		-- Own frame flash routines to avoid taints
		VUHDO_UIFrameFlash_OnUpdate(aTimeDelta);

		return;

	end



	--
	local tIsDeferredActive;
	local function VUHDO_handleSegment2A(aTimeDelta)

		-- reload UI?
		if VUHDO_checkTimer("RELOAD_UI") then
			tIsDeferredActive = VUHDO_CONFIG and VUHDO_CONFIG["USE_DEFERRED_REDRAW"] and VUHDO_isDeferredRedrawActive();

			if VUHDO_IS_RELOADING or InCombatLockdown() or tIsDeferredActive then
				VUHDO_TIMERS["RELOAD_UI"] = 0.3;
			else
				if VUHDO_RELOAD_UI_IS_LNF then
					VUHDO_lnfReloadUI();
				else
					VUHDO_reloadUI(false);
				end

				VUHDO_initOptions();

				VUHDO_FIRST_RELOAD_UI = true;
			end
		end

		return;

	end



	--
	local tIsDeferredActive;
	local function VUHDO_handleSegment2B(aTimeDelta)

		-- reset single panel?
		if VUHDO_checkTimer("RELOAD_PANEL") then
			tIsDeferredActive = VUHDO_CONFIG and VUHDO_CONFIG["USE_DEFERRED_REDRAW"] and VUHDO_isDeferredRedrawActive();

			if VUHDO_IS_RELOADING or InCombatLockdown() or tIsDeferredActive then
				VUHDO_TIMERS["RELOAD_PANEL"] = 0.3;
			else
				VUHDO_PROHIBIT_REPOS = true;

				VUHDO_initAllBurstCaches();
				VUHDO_redrawPanel(VUHDO_RELOAD_PANEL_NUM);
				VUHDO_updateAllPanelBars(VUHDO_RELOAD_PANEL_NUM);
				VUHDO_buildGenericHealthBarBouquet();
				VUHDO_buildGenericTargetHealthBouquet();
				VUHDO_registerAllBouquets(false);
				VUHDO_initAllEventBouquets();

				VUHDO_PROHIBIT_REPOS = false;
			end
		end

		return;

	end



	--
	local function VUHDO_handleSegment2C(aTimeDelta)

		-- Reload raid roster?
		if VUHDO_checkTimer("RELOAD_RAID") then
			VUHDO_doReloadRoster(false);
		end

		-- Quick update after raid roster change?
		if VUHDO_checkTimer("RELOAD_ROSTER") then
			VUHDO_doReloadRoster(true);
		end

		-- refresh HoTs, cyclic bouquets and custom debuffs?
		if VUHDO_checkResetTimer("UPDATE_HOTS", sHotToggleUpdateSecs) then
			if VUHDO_RAID then
				if sHotDebuffToggle == 1 then
					VUHDO_updateAllHoTs();

					if VUHDO_INTERNAL_TOGGLES[18] then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
						VUHDO_updateClusterHighlights();
					end

					if VUHDO_INTERNAL_TOGGLES[37] then -- VUHDO_UPDATE_SPELL_TRACE
						VUHDO_updateSpellTrace();
					end
				elseif sHotDebuffToggle == 2 then
					VUHDO_updateAllCyclicBouquets(false);
				else
					VUHDO_updateAllDebuffIcons(false);

					-- Reload after played gained control
					if not HasFullControl() then
						VUHDO_LOST_CONTROL = true;
					else
						if VUHDO_LOST_CONTROL then
							if VUHDO_TIMERS["RELOAD_RAID"] <= 0 then
								VUHDO_TIMERS["CUSTOMIZE"] = 0.3;
							end

							VUHDO_LOST_CONTROL = false;
						end
					end
				end
			end

			if sHotDebuffToggle > 2 then
				sHotDebuffToggle = 1;
			else
				sHotDebuffToggle = sHotDebuffToggle + 1;
			end
		end

		-- track dragged panel coords
		if VUHDO_DRAG_PANEL and VUHDO_checkResetTimer("REFRESH_DRAG", 0.05) then
			VUHDO_refreshDragTarget(VUHDO_DRAG_PANEL);
		end

		-- Set Button colors without repositioning
		if VUHDO_checkTimer("CUSTOMIZE") then
			VUHDO_updateAllRaidTargetIndices();
			VUHDO_updateAllRaidBars();
			VUHDO_initAllEventBouquets();
		end

		-- Refresh Tooltip
		if VUHDO_checkResetTimer("REFRESH_TOOLTIP", 2.3) and VuhDoTooltip:IsShown() then
			VUHDO_updateTooltip();
		end

		-- Refresh custom debuff Tooltip
		if VUHDO_checkResetTimer("REFRESH_CUDE_TOOLTIP", 1) then
			VUHDO_updateCustomDebuffTooltip();
		end

		-- Refresh Buff Watch
		if VUHDO_checkResetTimer("BUFF_WATCH", sBuffsRefreshSecs) then
			VUHDO_updateBuffPanel();
		end

		-- Refresh Inspect, check timeout
		if VUHDO_NEXT_INSPECT_UNIT ~= nil and GetTime() > VUHDO_NEXT_INSPECT_TIME_OUT then
			VUHDO_setRoleUndefined(VUHDO_NEXT_INSPECT_UNIT);

			VUHDO_NEXT_INSPECT_UNIT = nil;
		end

		-- Refresh targets not in raid
		if VUHDO_checkResetTimer("REFRESH_TARGETS", 0.51) then
			VUHDO_updateAllOutRaidTargetButtons();
		end

		return;

	end



	--
	local function VUHDO_handleSegment2D(aTimeDelta)

		-- refresh aggro?
		if VUHDO_checkResetTimer("UPDATE_AGGRO", sAggroRefreshSecs) then
			VUHDO_updateAllAggro();
		end

		-- refresh range?
		if VUHDO_checkResetTimer("UPDATE_RANGE", sRangeRefreshSecs) then
			VUHDO_updateAllRange();
		end

		-- Refresh Cluster
		if VUHDO_checkResetTimer("UPDATE_CLUSTERS", sClusterRefreshSecs) then
			VUHDO_updateAllClusters();
		end

		-- AoE advice
		if VUHDO_checkResetTimer("UPDATE_AOE", sAoeRefreshSecs) then
			VUHDO_aoeUpdateAll();
		end

		return;

	end



	--
	local function VUHDO_handleSegment2F(aTimeDelta)

		-- reload after battle
		if VUHDO_RELOAD_AFTER_BATTLE and not InCombatLockdown() then
			VUHDO_RELOAD_AFTER_BATTLE = false;

			if VUHDO_TIMERS["RELOAD_RAID"] <= 0 then
				VUHDO_quickRaidReload();

				if VUHDO_IS_RELOAD_BUFFS then
					VUHDO_reloadBuffPanel();

					VUHDO_IS_RELOAD_BUFFS = false;
				end
			end
		end

		return;

	end



	--
	local function VUHDO_handleSegment2G(aTimeDelta)

		if not InCombatLockdown() then
			sAutoProfile, sTrigger = VUHDO_getAutoProfile();
		end

		return;

	end



	--
	local function VUHDO_handleSegment2H(aTimeDelta)

		if not InCombatLockdown() and sAutoProfile and not VUHDO_IS_CONFIG then
			VUHDO_Msg(VUHDO_I18N_AUTO_ARRANG_1 .. sTrigger .. VUHDO_I18N_AUTO_ARRANG_2 .. "|cffffffff" .. sAutoProfile .. "|r\"");

			VUHDO_loadProfile(sAutoProfile);
		end

		return;

	end



	--
	local function VUHDO_handleSegment2I(aTimeDelta)

		VUHDO_hideBlizzCompactPartyFrame();

		return;

	end



	--
	local function VUHDO_handleSegment2J(aTimeDelta)

		VUHDO_removeObsoleteShields();

		return;

	end



	--
	local function VUHDO_handleSegment2K(aTimeDelta)

		-- Unit Zones
		if VUHDO_checkResetTimer("RELOAD_ZONES", 3.45) then
			if VUHDO_RAID then
				for tUnit, tUnitInfo in pairs(VUHDO_RAID) do
					tUnitInfo["zone"], tUnitInfo["map"] = VUHDO_getUnitZoneName(tUnit);
				end
			end
		end

		return;

	end



	--
	local function VUHDO_handleSegment2L(aTimeDelta)

		if not VUHDO_NEXT_INSPECT_UNIT and not InCombatLockdown() and VUHDO_checkResetTimer("REFRESH_INSPECT", 2.1) then
			VUHDO_tryInspectNext();
		end

		return;

	end



	--
	local function VUHDO_handleSegment2M(aTimeDelta)

		-- Refresh d/c shield macros?
		if VUHDO_checkTimer("MIRROR_TO_MACRO") then
			if InCombatLockdown() then
				VUHDO_TIMERS["MIRROR_TO_MACRO"] = 2;
			else
				VUHDO_mirrorToMacro();
			end
		end

		return;

	end



	--
	local tStartTime;
	local tProfilerResult;
	local tCallbackResult;
	local tEndTime;
	local tDuration;
	function VUHDO_profileSegment(aSegmentName, aCallback, ...)

		if not VUHDO_HANDLER_PROFILING_ENABLED then
			return aCallback(...), 0;
		end

		if MeasureCall then
			tProfilerResult, tCallbackResult = MeasureCall(aCallback, ...);

			if tProfilerResult and tProfilerResult["elapsedMilliseconds"] then
				tDuration = tProfilerResult["elapsedMilliseconds"] * 1000;
			else
				tDuration = 0;
			end
		else
			tStartTime = debugprofilestop();

			tCallbackResult = aCallback(...);

			tEndTime = debugprofilestop();
			tDuration = (tEndTime - tStartTime) * 1000;
		end

		VUHDO_updateOnUpdateSubSegmentMetrics(aSegmentName, tDuration);

		return tCallbackResult, tDuration;

	end



	--
	local tSegmentCallbacks = {
		["segment1A"] = function(aTimeDelta) VUHDO_handleSegment1A(aTimeDelta); end,
		["segment1B"] = function() VUHDO_processDeferredTaskQueue(); end,
		["segment2A"] = function(aTimeDelta) VUHDO_handleSegment2A(aTimeDelta); end,
		["segment2B"] = function(aTimeDelta) VUHDO_handleSegment2B(aTimeDelta); end,
		["segment2C"] = function(aTimeDelta) VUHDO_handleSegment2C(aTimeDelta); end,
		["segment2D"] = function(aTimeDelta) VUHDO_handleSegment2D(aTimeDelta); end,
		["segment2E"] = function(aTimeDelta) VUHDO_handleSegment2E(aTimeDelta); end,
		["segment2F"] = function(aTimeDelta) VUHDO_handleSegment2F(aTimeDelta); end,
		["segment2G"] = function(aTimeDelta) VUHDO_handleSegment2G(aTimeDelta); end,
		["segment2H"] = function(aTimeDelta) VUHDO_handleSegment2H(aTimeDelta); end,
		["segment2I"] = function(aTimeDelta) VUHDO_handleSegment2I(aTimeDelta); end,
		["segment2J"] = function(aTimeDelta) VUHDO_handleSegment2J(aTimeDelta); end,
		["segment2K"] = function(aTimeDelta) VUHDO_handleSegment2K(aTimeDelta); end,
		["segment2L"] = function(aTimeDelta) VUHDO_handleSegment2L(aTimeDelta); end,
		["segment2M"] = function(aTimeDelta) VUHDO_handleSegment2M(aTimeDelta); end,
	};
	local tStartTimes = {
		[1] = -1, -- overall
		[2] = -1, -- segment
		[3] = -1, -- subsegment
	};
	local tSegment1ADuration;
	local tSegment1BDuration;
	local tSegment1Total;
	function VUHDO_OnUpdate(anInstance, aTimeDelta)

		if VUHDO_HANDLER_PROFILING_ENABLED then
			tStartTimes[1] = debugprofilestop();
			tStartTimes[2] = tStartTimes[1];

			tSegment1Total = 0;
		end

		-----------------------------------------------------
		-- Segment 1
		-----------------------------------------------------

		-----------------------------------------------------
		-- These need to update very frequenly to not stutter
		-- --------------------------------------------------

		-- Segment 1A - Animations etc.

		_, tSegment1ADuration = VUHDO_profileSegment("segment1A", tSegmentCallbacks["segment1A"], aTimeDelta);

		if VUHDO_HANDLER_PROFILING_ENABLED then
			tSegment1Total = tSegment1Total + tSegment1ADuration;
		end

		-- Segment 1B - Process deferred tasks
		_, tSegment1BDuration = VUHDO_profileSegment("segment1B", tSegmentCallbacks["segment1B"]);

		if VUHDO_HANDLER_PROFILING_ENABLED then
			tSegment1Total = tSegment1Total + tSegment1BDuration;

			tStartTimes[2] = debugprofilestop();
		end

		---------------------------------------------------------
		-- Segment 2
		---------------------------------------------------------

		---------------------------------------------------------
		-- From here 0.08 (80 msec) sec tick should be sufficient
		---------------------------------------------------------

		if sTimeDelta < 0.08 then
			sTimeDelta = sTimeDelta + aTimeDelta;
			sSlowDelta = sSlowDelta + aTimeDelta;

			VUHDO_finalizeOnUpdateMetrics(tStartTimes[1], tStartTimes[2], tSegment1Total);

			return;
		else
			VUHDO_setTimerDelta(sTimeDelta);

			sTimeDelta = 0;
		end

		if VUHDO_HANDLER_PROFILING_ENABLED then
			tStartTimes[3] = debugprofilestop();
		end

		-- Segment 2A - UI reloads

		VUHDO_profileSegment("segment2A", tSegmentCallbacks["segment2A"], aTimeDelta);

		---------------------------------------------------
		------------------------- below only if vars loaded
		---------------------------------------------------

		if not VUHDO_VARIABLES_LOADED then
			VUHDO_finalizeOnUpdateMetrics(tStartTimes[1], tStartTimes[2], tSegment1Total);

			return;
		end

		-- Segment 2B: Roster and core updates

		VUHDO_profileSegment("segment2B", tSegmentCallbacks["segment2B"], aTimeDelta);

		-- Segment 2C: Roster and core updates

		VUHDO_profileSegment("segment2C", tSegmentCallbacks["segment2C"], aTimeDelta);

		-- Segment 2D: Combat checks

		if VUHDO_CONFIG_SHOW_RAID then
			VUHDO_finalizeOnUpdateMetrics(tStartTimes[1], tStartTimes[2], tSegment1Total);

			return;
		end

		VUHDO_profileSegment("segment2D", tSegmentCallbacks["segment2D"], aTimeDelta);

		-- Segment 2E: Slow tasks

		if VUHDO_HANDLER_PROFILING_ENABLED then
			tStartTimes[3] = debugprofilestop();
		end

		if sSlowDelta < 1.2 then
			sSlowDelta = sSlowDelta + sTimerDelta;

			if VUHDO_HANDLER_PROFILING_ENABLED then
				VUHDO_updateOnUpdateSubSegmentMetrics("segment2E", (debugprofilestop() - tStartTimes[3]) * 1000);
			end

			VUHDO_finalizeOnUpdateMetrics(tStartTimes[1], tStartTimes[2], tSegment1Total);

			return;
		else
			VUHDO_setTimerDelta(aTimeDelta + sSlowDelta);

			sSlowDelta = 0;
		end

		if VUHDO_HANDLER_PROFILING_ENABLED then
			VUHDO_updateOnUpdateSubSegmentMetrics("segment2E", (debugprofilestop() - tStartTimes[3]) * 1000);
			tStartTimes[3] = debugprofilestop();
		end

		-- Segment 2F: Post-Combat Reload

		VUHDO_profileSegment("segment2F", tSegmentCallbacks["segment2F"], aTimeDelta);

		-- automatic profiles, shield cleanup, hide generic blizz party
		if VUHDO_checkResetTimer("CHECK_PROFILES", 3.1) then
			-- Segment 2G: Auto profile detection

			VUHDO_profileSegment("segment2G", tSegmentCallbacks["segment2G"], aTimeDelta);

			-- Segment 2H: Auto profile loading

			VUHDO_profileSegment("segment2H", tSegmentCallbacks["segment2H"], aTimeDelta);

			-- Segment 2I: Hide Blizzard compact party frame

			VUHDO_profileSegment("segment2I", tSegmentCallbacks["segment2I"], aTimeDelta);

			-- Segment 2J: Remove obsolete shields

			VUHDO_profileSegment("segment2J", tSegmentCallbacks["segment2J"], aTimeDelta);
		end

		-- Segment 2K: Zones

		VUHDO_profileSegment("segment2K", tSegmentCallbacks["segment2K"], aTimeDelta);

		-- Segment 2L: Inspect

		VUHDO_profileSegment("segment2L", tSegmentCallbacks["segment2L"], aTimeDelta);

		-- Segment 2M: Macros

		VUHDO_profileSegment("segment2M", tSegmentCallbacks["segment2M"], aTimeDelta);

		VUHDO_finalizeOnUpdateMetrics(tStartTimes[1], tStartTimes[2], tSegment1Total);

		VUHDO_flushProfilingBatch();

		return;

	end
end



--
local VUHDO_ALL_EVENT_NAMES = {
	"VARIABLES_LOADED", "PLAYER_ENTERING_WORLD", "SPELLS_CHANGED",
	"UNIT_MAXHEALTH", "UNIT_HEALTH",
	"UNIT_AURA",
	"UNIT_TARGET",
	"GROUP_ROSTER_UPDATE", "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "UPDATE_ACTIVE_BATTLEFIELD",
	"UNIT_PET",
	"UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "UNIT_EXITING_VEHICLE",
	"CHAT_MSG_ADDON",
	"RAID_TARGET_UPDATE",
	"LEARNED_SPELL_IN_SKILL_LINE", "TRAIT_CONFIG_UPDATED",
	"PLAYER_FLAGS_CHANGED",
	"PLAYER_LOGOUT",
	"UNIT_DISPLAYPOWER", "UNIT_MAXPOWER", "UNIT_POWER_UPDATE", "RUNE_POWER_UPDATE",
	"UNIT_SPELLCAST_SENT",
	"PARTY_MEMBER_ENABLE", "PARTY_MEMBER_DISABLE",
	"COMBAT_LOG_EVENT_UNFILTERED",
	"UNIT_THREAT_SITUATION_UPDATE",
	"UPDATE_BINDINGS",
	"PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED",
	"PLAYER_EQUIPMENT_CHANGED",
	"READY_CHECK", "READY_CHECK_CONFIRM", "READY_CHECK_FINISHED",
	"ROLE_CHANGED_INFORM",
	"CVAR_UPDATE",
	"INSPECT_READY",
	"MODIFIER_STATE_CHANGED",
	"UNIT_CONNECTION",
	"UNIT_HEAL_PREDICTION",
	"UNIT_POWER_BAR_SHOW","UNIT_POWER_BAR_HIDE",
	"UNIT_NAME_UPDATE",
	"LFG_PROPOSAL_SHOW", "LFG_PROPOSAL_FAILED", "LFG_PROPOSAL_SUCCEEDED",
	--"UPDATE_MACROS",
	"UNIT_FACTION",
	"INCOMING_RESURRECT_CHANGED",
	"PET_BATTLE_CLOSE", "PET_BATTLE_OPENING_START",
	"PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED",
	"UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
	"INCOMING_SUMMON_CHANGED",
	"UNIT_PHASE",
	"PLAYER_SPECIALIZATION_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED",
	"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE",
	"UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_FAILED_QUIET", "UNIT_SPELLCAST_CHANNEL_STOP",
	"NAME_PLATE_UNIT_REMOVED",
	"UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED",
};



--
do
	--
	local tTocVersion;
	function VUHDO_OnLoad(anInstance)

		_, _, _, tTocVersion = GetBuildInfo();

		if tonumber(tTocVersion or 999999) < VUHDO_MIN_TOC_VERSION then
			VUHDO_Msg(format(VUHDO_I18N_DISABLE_BY_MIN_VERSION, VUHDO_VERSION, VUHDO_MIN_TOC_VERSION));

			return;
		elseif tonumber(tTocVersion or 0) > VUHDO_MAX_TOC_VERSION then
			VUHDO_Msg(format(VUHDO_I18N_DISABLE_BY_MAX_VERSION, VUHDO_VERSION, VUHDO_MAX_TOC_VERSION));

			return;
		end

		VUHDO_INSTANCE = anInstance;

		for _, tEvent in pairs(VUHDO_ALL_EVENT_NAMES) do
			anInstance:RegisterEvent(tEvent);
		end

		VUHDO_ALL_EVENT_NAMES = nil;

		SLASH_VUHDO1 = "/vuhdo";
		SLASH_VUHDO2 = "/vd";

		SlashCmdList["VUHDO"] = function(aMessage)
			VUHDO_slashCmd(aMessage);
		end

		SLASH_RELOADUI1 = "/rl";

		SlashCmdList["RELOADUI"] = ReloadUI;



		anInstance:SetScript("OnEvent", VUHDO_OnEvent);
		anInstance:SetScript("OnUpdate", VUHDO_OnUpdate);

		VUHDO_refreshPixelScale();

		VUHDO_printAbout();

		return;

	end
end



--
function VUHDO_setDeferredRedrawEnabled(anIsEnabled, anIsQuiet)

	VUHDO_CONFIG["USE_DEFERRED_REDRAW"] = anIsEnabled and true or false;

	if VUHDO_CONFIG["USE_DEFERRED_REDRAW"] then
		VUHDO_redrawPanel = _G["VUHDO_deferRedrawPanel"];
		VUHDO_redrawAllPanels = _G["VUHDO_deferRedrawAllPanels"];
	else
		VUHDO_redrawPanel = _G["VUHDO_redrawPanel"];
		VUHDO_redrawAllPanels = _G["VUHDO_redrawAllPanels"];
	end

	if not anIsQuiet then
		if anIsEnabled then
			VUHDO_Msg("Deferred panel redraw is enabled.");
		else
			VUHDO_Msg("Deferred panel redraw is disabled.");
		end
	end

	return;

end



--
function VUHDO_printDeferredRedrawStatus()

	if VUHDO_CONFIG["USE_DEFERRED_REDRAW"] then
		VUHDO_Msg("Deferred panel redraw is currently |cff00ff00ENABLED|r.");
	else
		VUHDO_Msg("Deferred panel redraw is currently |cffff0000DISABLED|r.");
	end

	return;

end



--
function VUHDO_setAnimationGroupEnabled(anIsEnabled, anIsQuiet)

	VUHDO_CONFIG["USE_ANIMATION_GROUPS"] = anIsEnabled and true or false;

	if not anIsQuiet then
		if anIsEnabled then
			VUHDO_Msg("Debuff icon AnimationGroup API is now |cff00ff00ENABLED|r.");
			VUHDO_Msg("  |cffB0E0E6Note:|r Type '/reload' for a clean transition.");
		else
			VUHDO_Msg("Debuff icon AnimationGroup API is now |cffff0000DISABLED|r (using OnUpdate).");
			VUHDO_Msg("  |cffB0E0E6Note:|r Type '/reload' for a clean transition.");
		end
	end

	return;

end



--
function VUHDO_printAnimationMethodStatus()

	if VUHDO_CONFIG["USE_ANIMATION_GROUPS"] then
		VUHDO_Msg("Debuff icon animation method: |cff00ff00AnimationGroup API|r");
	else
		VUHDO_Msg("Debuff icon animation method: |cffff0000OnUpdate Script|r");
	end

	return;

end



--
local tSegmentName;
local tDuration;
function VUHDO_updateOnUpdateSubSegmentMetrics(aSegmentName, aDuration)

	if not VUHDO_HANDLER_PROFILING_ENABLED then
		return;
	end

	VUHDO_HANDLER_PROFILING_BATCH_COUNT = VUHDO_HANDLER_PROFILING_BATCH_COUNT + 1;

	tSegmentName = aSegmentName;
	tDuration = aDuration;

	VUHDO_HANDLER_PROFILING_PENDING_UPDATES[VUHDO_HANDLER_PROFILING_BATCH_COUNT] = {
		["segment"] = tSegmentName,
		["duration"] = tDuration
	};

	if VUHDO_HANDLER_PROFILING_BATCH_COUNT >= VUHDO_HANDLER_PROFILING_BATCH_SIZE then
		VUHDO_processProfilingBatch();
	end

	return;

end



--
local tUpdate;
local tSegmentName;
local tDuration;
local tTracker;
function VUHDO_processProfilingBatch()

	if VUHDO_HANDLER_PROFILING_BATCH_COUNT == 0 then
		return;
	end

	for tIndex = 1, VUHDO_HANDLER_PROFILING_BATCH_COUNT do
		tUpdate = VUHDO_HANDLER_PROFILING_PENDING_UPDATES[tIndex];
		tSegmentName = tUpdate["segment"];
		tDuration = tUpdate["duration"];

		if not VUHDO_HANDLER_PROFILING_METRICS[tSegmentName] then
			VUHDO_HANDLER_PROFILING_METRICS[tSegmentName] = VUHDO_createPercentileTracker();
		end

		tTracker = VUHDO_HANDLER_PROFILING_METRICS[tSegmentName];
		tTracker:update(tDuration);
	end

	VUHDO_HANDLER_PROFILING_BATCH_COUNT = 0;

	return;

end



--
function VUHDO_flushProfilingBatch()

	VUHDO_processProfilingBatch();

	return;

end



--
local tResult;
local tPercentiles;
local tTotal;
local tCount;
local tPercentile;
local tKey;
function VUHDO_getHandlerProfilingMetrics()

	VUHDO_flushProfilingBatch();

	tResult = { };

	for tSegmentName, tTracker in pairs(VUHDO_HANDLER_PROFILING_METRICS) do
		tPercentiles = tTracker:getPercentiles();

		tTotal = tTracker:getCumulativeTotal();
		tCount = tTracker["totalCount"];

		tResult[tSegmentName] = {
			["Total"] = tTotal,
			["Count"] = tCount
		};

		for tIndex = 1, #tTracker["percentiles"] do
			tPercentile = tTracker["percentiles"][tIndex];
			tKey = "tm" .. floor(tPercentile * 100);

			tResult[tSegmentName][tKey] = tPercentiles[tKey] or 0;
		end
	end

	return tResult;

end



--
local tSortedKeys;
function VUHDO_sortSegmentKeys(aSegments)

	tSortedKeys = { };

	for tKey in pairs(aSegments) do
		tinsert(tSortedKeys, tKey);
	end

	table.sort(tSortedKeys);

	return tSortedKeys;

end



--
local tTestTracker;
local tExpectedTotal;
local tBufferTotal;
local tCumulativeTotal;
local tBufferCount;
local tCumulativeCount;
local tValue;
local tDataLossPercent;
local tAccuracyPercent;
local tTm50;
local tTm80;
local tTm90;
local tTm99;
local tTm100;
function VUHDO_testProfilingSystem()

	VUHDO_Msg("=== Testing Profiling System ===");

	tTestTracker = VUHDO_createPercentileTracker();
	tExpectedTotal = 0;

	VUHDO_Msg("Adding 2000 test measurements...");

	for tCnt = 1, 2000 do
		tValue = 0.1 * tCnt;
		tExpectedTotal = tExpectedTotal + tValue;
		tTestTracker:update(tValue);
	end

	tBufferTotal = 0;

	for tCnt = 1, tTestTracker["bufferSize"] do
		tBufferTotal = tBufferTotal + tTestTracker["buffer"][tCnt];
	end

	tCumulativeTotal = tTestTracker:getCumulativeTotal();
	tBufferCount = tTestTracker["bufferSize"];
	tCumulativeCount = tTestTracker["totalCount"];

	VUHDO_Msg("Expected Total: " .. string.format("%.2f", tExpectedTotal) .. " ms");
	VUHDO_Msg("Buffer Total: " .. string.format("%.2f", tBufferTotal) .. " ms");
	VUHDO_Msg("Cumulative Total: " .. string.format("%.2f", tCumulativeTotal) .. " ms");
	VUHDO_Msg("Buffer Count: " .. tBufferCount);
	VUHDO_Msg("Cumulative Count: " .. tCumulativeCount);

	if tBufferCount > 0 then
		tDataLossPercent = ((tExpectedTotal - tBufferTotal) / tExpectedTotal) * 100;
		tAccuracyPercent = (tCumulativeTotal / tExpectedTotal) * 100;
		VUHDO_Msg("Buffer Data Loss: " .. string.format("%.2f", tDataLossPercent) .. "%");
		VUHDO_Msg("Cumulative Accuracy: " .. string.format("%.2f", tAccuracyPercent) .. "%");
	end

	tTm50 = tTestTracker:getPercentile(50);
	tTm80 = tTestTracker:getPercentile(80);
	tTm90 = tTestTracker:getPercentile(90);
	tTm99 = tTestTracker:getPercentile(99);
	tTm100 = tTestTracker:getPercentile(100);

	VUHDO_Msg("tm50: " .. string.format("%.2f", tTm50) .. " ms, tm80: " .. string.format("%.2f", tTm80) .. " ms, tm90: " .. string.format("%.2f", tTm90) .. " ms, tm99: " .. string.format("%.2f", tTm99) .. " ms, tm100: " .. string.format("%.2f", tTm100) .. " ms");

	VUHDO_Msg("=== Test Complete ===");

	return;

end



--
local sProfilingFrame;
local sProfilingScrollFrame;
local sProfilingScrollChildFrame;
local sProfilingEditBox;
local sProfilingCopyButton;



--
local tTitle;
local tProfilingCloseButton;
local tLeft;
local tRight;
local tMiddle;
function VUHDO_ensureProfilingFrames()

	if sProfilingFrame then
		return;
	end

	sProfilingFrame = CreateFrame("Frame", "VuhDoProfilingFrame", UIParent, "BackdropTemplate");

	sProfilingFrame:SetSize(800, 600);
	sProfilingFrame:SetPoint("CENTER");

	sProfilingFrame:SetBackdrop( {
		["bgFile"] = "Interface\\Buttons\\WHITE8x8",
		["edgeFile"] = "Interface\\Tooltips\\UI-Tooltip-Border",
		["tile"] = true,
		["tileSize"] = 8,
		["edgeSize"] = 16,
		["insets"] = {
			["left"] = 4,
			["right"] = 4,
			["top"] = 4,
			["bottom"] = 4,
		},
	} );
	sProfilingFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9);
	sProfilingFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8);

	sProfilingFrame:SetMovable(true);
	sProfilingFrame:EnableMouse(true);

	sProfilingFrame:RegisterForDrag("LeftButton");
	sProfilingFrame:SetScript("OnDragStart", sProfilingFrame.StartMoving);
	sProfilingFrame:SetScript("OnDragStop", sProfilingFrame.StopMovingOrSizing);

	tTitle = sProfilingFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");

	tTitle:SetPoint("TOP", 0, -8);
	tTitle:SetText("VuhDo Profiling Metrics");

	sProfilingScrollFrame = CreateFrame("ScrollFrame", "VuhDoProfilingFrameScrollFrame", sProfilingFrame, "UIPanelScrollFrameTemplate");

	sProfilingScrollFrame:SetPoint("TOPLEFT", 12, -40);
	sProfilingScrollFrame:SetPoint("BOTTOMRIGHT", -32, 50);

	sProfilingScrollChildFrame = CreateFrame("Frame", nil, sProfilingScrollFrame);

	sProfilingScrollChildFrame:SetPoint("TOPLEFT");
	sProfilingScrollChildFrame:SetPoint("TOPRIGHT");
	sProfilingScrollChildFrame:SetSize(756, 400);

	sProfilingEditBox = CreateFrame("EditBox", nil, sProfilingScrollChildFrame, "InputBoxTemplate");

	sProfilingEditBox:SetPoint("TOPLEFT");
	sProfilingEditBox:SetPoint("TOPRIGHT");
	sProfilingEditBox:SetMultiLine(true);
	sProfilingEditBox:SetAutoFocus(false);
	sProfilingEditBox:SetFontObject("GameFontHighlight");

	tLeft = sProfilingEditBox["Left"];
	tRight = sProfilingEditBox["Right"];
	tMiddle = sProfilingEditBox["Middle"];

	if tLeft then
		tLeft:SetVertexColor(1, 1, 1, 0);
	end

	if tRight then
		tRight:SetVertexColor(1, 1, 1, 0);
	end

	if tMiddle then
		tMiddle:SetVertexColor(1, 1, 1, 0);
	end

	sProfilingEditBox:SetScript("OnEscapePressed", function()
		if not InCombatLockdown() then
			sProfilingFrame:Hide();
		end
	end);

	sProfilingScrollFrame:SetScrollChild(sProfilingScrollChildFrame);

	sProfilingCopyButton = CreateFrame("Button", nil, sProfilingFrame, "GameMenuButtonTemplate");

	sProfilingCopyButton:SetSize(100, 25);
	sProfilingCopyButton:SetPoint("BOTTOMLEFT", 12, 12);
	sProfilingCopyButton:SetText("Select All");

	sProfilingCopyButton:SetScript("OnClick", function()
		if sProfilingCopyButton:GetText() == "Select All" then
			sProfilingEditBox:SetFocus();
			sProfilingEditBox:HighlightText();
			sProfilingCopyButton:SetText("Unselect All");
		else
			sProfilingEditBox:HighlightText(0, 0);
			sProfilingCopyButton:SetText("Select All");
		end
	end);

	tProfilingCloseButton = CreateFrame("Button", nil, sProfilingFrame, "GameMenuButtonTemplate");

	tProfilingCloseButton:SetSize(100, 25);
	tProfilingCloseButton:SetPoint("BOTTOMRIGHT", -12, 12);
	tProfilingCloseButton:SetText("Close");

	tProfilingCloseButton:SetScript("OnClick", function()
		if not InCombatLockdown() then
			sProfilingFrame:Hide();
		end
	end);

	return;

end



--
function VUHDO_showProfilingFrame()

	if InCombatLockdown() then
		VUHDO_Msg("Cannot show profiling frame during combat.");

		return;
	end

	VUHDO_ensureProfilingFrames();

	sProfilingFrame:Show();

	return;

end



--
local tCapturedOutput;
local tOriginalMsg;
local tOutputText;
function VUHDO_captureProfilingOutput(aCallback)

	if InCombatLockdown() then
		VUHDO_Msg("Cannot capture profiling output during combat.");

		return;
	end

	VUHDO_ensureProfilingFrames();

	tCapturedOutput = { };
	tOriginalMsg = VUHDO_Msg;

	VUHDO_Msg = function(aMessage, aRed, aGreen, aBlue)
		tinsert(tCapturedOutput, aMessage);

		return;
	end

	aCallback();

	VUHDO_Msg = tOriginalMsg;

	tOutputText = "";

	for _, tLine in ipairs(tCapturedOutput) do
		tOutputText = tOutputText .. tLine .. "\n";
	end

	sProfilingEditBox:SetText(tOutputText);
	sProfilingCopyButton:SetText("Select All");
	sProfilingEditBox:HighlightText(0, 0);

	sProfilingScrollFrame:SetVerticalScroll(0);

	return;

end



--
function VUHDO_showProfilingMetrics()

	VUHDO_showProfilingFrame();

	VUHDO_captureProfilingOutput(function()
		VUHDO_printHandlerMetrics();
		VUHDO_printDeferredTaskMetrics(false);
		VUHDO_printPoolMetrics();
		VUHDO_printSemaphoreMetrics();
	end);

	return;

end
