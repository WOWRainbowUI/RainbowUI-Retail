local _;

local GetTime = GetTime;
local pairs = pairs;
local string = string;
local xpcall = xpcall;
local debugprofilestop = debugprofilestop;
local MeasureCall = C_AddOnProfiler and C_AddOnProfiler.MeasureCall;
local format = string.format;
local tinsert = table.insert;
local tcreate = table.create or VUHDO_tableCreate;
local tremove = table.remove;
local twipe = table.wipe;
local max = math.max;
local min = math.min;
local floor = math.floor;
local abs = math.abs;



VUHDO_DEFERRED_TASK_PRIORITY_LOW = 1;
VUHDO_DEFERRED_TASK_PRIORITY_NORMAL = 2;
VUHDO_DEFERRED_TASK_PRIORITY_HIGH = 3;
VUHDO_DEFERRED_TASK_PRIORITY_CRITICAL = 4;

VUHDO_DEFER_UPDATE_HEALTH = 1;
VUHDO_DEFER_UPDATE_HEALTH_BARS_FOR = 2;
VUHDO_DEFER_SET_HEALTH = 3;
VUHDO_DEFER_UPDATE_SHIELD_BAR = 4;
VUHDO_DEFER_UPDATE_HEAL_ABSORB_BAR = 5;
VUHDO_DEFER_UPDATE_MANA_BARS = 6;
VUHDO_DEFER_UPDATE_UNIT_HOTS = 7;
VUHDO_DEFER_INIT_ALL_EVENT_BOUQUETS = 8;
VUHDO_DEFER_UPDATE_BOUQUETS_FOR_EVENT = 9;
VUHDO_DEFER_UPDATE_UNIT_CYCLIC_BOUQUET = 10;
VUHDO_DEFER_UPDATE_UNIT_DEBUFF_ICONS = 11;
VUHDO_DEFER_UPDATE_UNIT_AGGRO = 12;
VUHDO_DEFER_UPDATE_UNIT_RANGE = 13;
VUHDO_DEFER_UPDATE_ALL_CLUSTERS = 14;
VUHDO_DEFER_UPDATE_CLUSTER_HIGHLIGHTS = 15;
VUHDO_DEFER_AOE_UPDATE_ALL = 16;
VUHDO_DEFER_UPDATE_SPELL_TRACE = 17;
VUHDO_DEFER_UPDATE_ALL_RAID_BARS = 18;
VUHDO_DEFER_UPDATE_PANEL_BUTTONS = 19;
VUHDO_DEFER_HANDLE_SCALE_CHANGE = 20;
VUHDO_DEFER_INIT_HEAL_BUTTON = 21;
VUHDO_DEFER_POSITION_HEAL_BUTTON = 22;
VUHDO_DEFER_REDRAW_PANEL_COMPLETE = 23;
VUHDO_DEFER_INIT_ALL_HEAL_BUTTONS_COMPLETE = 24;
VUHDO_DEFER_POSITION_CONFIG_PANELS = 25;
VUHDO_DEFER_REDRAW_PANEL = 26;
VUHDO_DEFER_REDRAW_ALL_PANELS_COMPLETE = 27;

local VUHDO_DEFERRED_TASK_TYPES = {
	VUHDO_DEFER_UPDATE_HEALTH,
	VUHDO_DEFER_UPDATE_HEALTH_BARS_FOR,
	VUHDO_DEFER_SET_HEALTH,
	VUHDO_DEFER_UPDATE_SHIELD_BAR,
	VUHDO_DEFER_UPDATE_HEAL_ABSORB_BAR,
	VUHDO_DEFER_UPDATE_MANA_BARS,
	VUHDO_DEFER_UPDATE_UNIT_HOTS,
	VUHDO_DEFER_INIT_ALL_EVENT_BOUQUETS,
	VUHDO_DEFER_UPDATE_BOUQUETS_FOR_EVENT,
	VUHDO_DEFER_UPDATE_UNIT_CYCLIC_BOUQUET,
	VUHDO_DEFER_UPDATE_UNIT_DEBUFF_ICONS,
	VUHDO_DEFER_UPDATE_UNIT_AGGRO,
	VUHDO_DEFER_UPDATE_UNIT_RANGE,
	VUHDO_DEFER_UPDATE_ALL_CLUSTERS,
	VUHDO_DEFER_UPDATE_CLUSTER_HIGHLIGHTS,
	VUHDO_DEFER_AOE_UPDATE_ALL,
	VUHDO_DEFER_UPDATE_SPELL_TRACE,
	VUHDO_DEFER_UPDATE_ALL_RAID_BARS,
	VUHDO_DEFER_UPDATE_PANEL_BUTTONS,
	VUHDO_DEFER_HANDLE_SCALE_CHANGE,
	VUHDO_DEFER_INIT_HEAL_BUTTON,
	VUHDO_DEFER_POSITION_HEAL_BUTTON,
	VUHDO_DEFER_REDRAW_PANEL_COMPLETE,
	VUHDO_DEFER_INIT_ALL_HEAL_BUTTONS_COMPLETE,
	VUHDO_DEFER_POSITION_CONFIG_PANELS,
	VUHDO_DEFER_REDRAW_PANEL,
	VUHDO_DEFER_REDRAW_ALL_PANELS_COMPLETE,
};

local VUHDO_COMBAT_UNSAFE_TASKS = {
	[VUHDO_DEFER_INIT_HEAL_BUTTON] = true,
	[VUHDO_DEFER_POSITION_HEAL_BUTTON] = true,
	[VUHDO_DEFER_REDRAW_PANEL_COMPLETE] = true,
	[VUHDO_DEFER_INIT_ALL_HEAL_BUTTONS_COMPLETE] = true,
	[VUHDO_DEFER_POSITION_CONFIG_PANELS] = true,
	[VUHDO_DEFER_REDRAW_PANEL] = true,
	[VUHDO_DEFER_REDRAW_ALL_PANELS_COMPLETE] = true,
	[VUHDO_DEFER_UPDATE_PANEL_BUTTONS] = true,
	[VUHDO_DEFER_UPDATE_ALL_RAID_BARS] = true,
};

local sDeferredTaskDelegates;
local sNextTaskEnqueueOrder = 0;

local VUHDO_DEFERRED_TASK_PROFILING_ENABLED = false;

local VUHDO_DEFERRED_TASK_CONFIG = {
	["TARGET_EXEC_TIME_US"] = 50000,
	["MAX_EXEC_TIME_US"] = 75000,
	["MIN_TASKS_PER_FRAME"] = 1,
	["INITIAL_TASKS_PER_FRAME"] = 250,
	["MAX_TASKS_PER_FRAME"] = 500,
	["ADJUST_INTERVAL_SECS"] = 1.5,
	["IDLE_TASK_INC_THRESHOLD_US"] = 50,
	["CHUNK_SNAPSHOT_LIMIT"] = 5,
};

local VUHDO_TASK_TYPE_DEFAULT_COSTS = {
	[1] = 130,    -- tm50=105μs, tm80=154μs → 130μs estimate (avg of tm50+tm80)
	[2] = 96,     -- tm50=85μs, tm80=106μs → 96μs estimate
	[3] = 177,    -- tm50=177μs, tm80=177μs → 177μs estimate
	[4] = 51,     -- tm50=42μs, tm80=60μs → 51μs estimate
	[5] = 36,     -- tm50=30μs, tm80=41μs → 36μs estimate
	[6] = 22,     -- tm50=9μs, tm80=34μs → 22μs estimate
	[7] = 45,     -- tm50=35μs, tm80=55μs → 45μs estimate
	[8] = 674,    -- tm50=674μs, tm80=674μs → 674μs estimate
	[9] = 17,     -- tm50=14μs, tm80=19μs → 17μs estimate
	[10] = 17,    -- tm50=10μs, tm80=23μs → 17μs estimate
	[11] = 2,     -- tm50=1μs, tm80=2μs → 2μs estimate
	[12] = 7,     -- tm50=6μs, tm80=8μs → 7μs estimate
	[13] = 17,    -- tm50=6μs, tm80=27μs → 17μs estimate
	[17] = 2,     -- tm50=2μs, tm80=2μs → 2μs estimate
	[18] = 215,   -- tm50=215μs, tm80=215μs → 215μs estimate
	[19] = 33,    -- tm50=33μs, tm80=33μs → 33μs estimate
	[21] = 660,   -- tm50=613μs, tm80=706μs → 660μs estimate
	[22] = 1375,  -- tm50=1.29ms, tm80=1.46ms → 1375μs estimate
	[23] = 450,   -- tm50=366μs, tm80=533μs → 450μs estimate
	[24] = 74,    -- tm50=47μs, tm80=100μs → 74μs estimate
	[25] = 205,   -- tm50=180μs, tm80=230μs → 205μs estimate
	[26] = 181,   -- tm50=136μs, tm80=225μs → 181μs estimate
	[27] = 6200,  -- tm50=4.26ms, tm80=8.13ms → 6200μs estimate
};

local VUHDO_DEFERRED_TASK_STATE = {
	["isInit"] = false,
	["maxTasksPerFrame"] = VUHDO_DEFERRED_TASK_CONFIG["INITIAL_TASKS_PER_FRAME"],
	["lastAdjustTime"] = 0,
	["invocationCountByType"] = nil,
	["avgCostUsByType"] = nil,
	["costHistoryByType"] = nil,
	["individualCostsByType"] = nil,
	["queueTimeUsByType"] = nil,
	["costPredictionAccuracy"] = nil,

	["metrics"] = {
		["sessionStartTime"] = 0,
		["totalTasksEnqueued"] = 0,
		["totalTasksDeduped"] = 0,
		["totalTasksProcessedSession"] = 0,
		["totalProcessingTimeUsSession"] = 0,
		["chunksExecutedSuccessfully"] = 0,
		["minQueueLength"] = 999999,
		["maxQueueLength"] = 0,
		["sumQueueLength"] = 0,
		["queueLengthSamples"] = 0,
		["tasksInChunkPercentileTracker"] = nil,
		["chunkTimePercentileTracker"] = nil,
		["hardStopsHit"] = 0,
		["unsafeTasksProcessed"] = 0,
		["tasksEnqueuedByType"] = { },
		["tasksProcessedByTypeSession"] = { },
		["totalTimeUsByTypeSession"] = { },
		["queueTimeUsByTypeSession"] = { },
		["queueTimeHistoryByType"] = { },
		["minTaskTimeUsByTypeSession"] = { },
		["maxTaskTimeUsByTypeSession"] = { },
		["maxTaskTimeUsContextByTypeSession"] = { },
		["taskDurationHistoryByType"] = { },
		["taskDurationTrimmedMeansByType"] = { },
		["queueTimeTrimmedMeansByType"] = { },
	},
};

local VUHDO_DEFERRED_TASK_CHUNK_SNAPSHOTS = {
	-- {
	-- {
	--	["totalChunkTimeUs" = <total time>,
	--	["numTasksInChunk"] = <total tasks>,
	--	["tasks"] = {
	--		{
	--			["type"] = <task type>,
	--			["unit"] = <unit>,
	--			["mode"] = <mode>,
	--			["durationUs"] = <microsecond duration>,
	--		},
	--		["timestamp"] = <task timestamp>,
	--	},
	-- },
};

local VUHDO_DEFERRED_TASK_POOL;
local VUHDO_DEFERRED_TASK_POOL_MAX_SIZE = 1500;

local VUHDO_TASK_PRIORITY_QUEUE = { };
local VUHDO_TASK_QUEUE_MAP = { };



do
	--
	local tDefaultPercentiles;
	local tDefaultPercentileKeys;
	local tDefaultFallbackTable;
	local tPercentile;
	local tKey;
	local tCopy;
	function VUHDO_getDefaultPercentileFallback()

		if not tDefaultFallbackTable then
			tDefaultPercentiles = { 0.5, 0.8, 0.9, 0.99, 1.0 };

			tDefaultPercentileKeys = { };
			tDefaultFallbackTable = { };

			for tIndex = 1, #tDefaultPercentiles do
				tPercentile = tDefaultPercentiles[tIndex];
				tKey = "tm" .. floor(tPercentile * 100);

				tDefaultPercentileKeys[tIndex] = tKey;
				tDefaultFallbackTable[tKey] = 0;
			end
		end

		tCopy = { };

		for tKey, tValue in pairs(tDefaultFallbackTable) do
			tCopy[tKey] = tValue;
		end

		return tCopy;

	end



	--
	local tPercentileKeys;
	local tPercentileFormatString;
	local tPercentileValueString;
	local tKey;
	function VUHDO_getPercentileFormatStrings()

		if not tPercentileFormatString then
			tPercentileKeys = { };

			tDefaultFallbackTable = VUHDO_getDefaultPercentileFallback();

			for tKey in pairs(tDefaultFallbackTable) do
				tinsert(tPercentileKeys, tKey);
			end

			VUHDO_sortPercentileKeys(tPercentileKeys);

			tPercentileFormatString = "";
			tPercentileValueString = "";

			for tIndex = 1, #tPercentileKeys do
				tKey = tPercentileKeys[tIndex];

				if tIndex > 1 then
					tPercentileFormatString = tPercentileFormatString .. ", ";
					tPercentileValueString = tPercentileValueString .. ", ";
				end

				tPercentileFormatString = tPercentileFormatString .. tKey;
				tPercentileValueString = tPercentileValueString .. tKey .. ": %s";
			end
		end

		return tPercentileFormatString, tPercentileValueString, tPercentileKeys;

	end
end



--
function VUHDO_getDeferredTaskConfig()

	return VUHDO_DEFERRED_TASK_CONFIG;

end



--
function VUHDO_getDeferredTaskState()

	return VUHDO_DEFERRED_TASK_STATE;

end



--
function VUHDO_deferUpdateHealth(aUnit, aMode, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_HEALTH, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_CRITICAL, aUnit, aMode);

	return;

end



--
function VUHDO_deferUpdateBouquetsForEvent(aUnit, aMode, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_BOUQUETS_FOR_EVENT, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, aUnit, aMode);

	return;

end



--
function VUHDO_deferUpdateShieldBar(aUnit, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_SHIELD_BAR, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aUnit, 1);

	return;

end



--
function VUHDO_deferUpdateHealAbsorbBar(aUnit, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_HEAL_ABSORB_BAR, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aUnit, 1);

	return;

end



--
function VUHDO_deferUpdateHealthBarsFor(aUnit, aMode, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_HEALTH_BARS_FOR, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aUnit, aMode);

	return;

end



--
function VUHDO_deferUpdateAllClusters(aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_ALL_CLUSTERS, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL);

	return;

end



--
function VUHDO_deferAoeUpdateAll(aPriority)

	VUHDO_deferTask(VUHDO_DEFER_AOE_UPDATE_ALL, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL);

	return;

end



--
function VUHDO_deferUpdateSpellTrace(aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_SPELL_TRACE, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL);

	return;

end



--
function VUHDO_deferUpdateAllRaidBars(aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_ALL_RAID_BARS, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH);

	return;

end



--
function VUHDO_deferUpdatePanelButtons(aPanelNum, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_PANEL_BUTTONS, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH, aPanelNum);

	return;

end



--
function VUHDO_deferUpdateManaBars(aUnit, aMode, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_MANA_BARS, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL, aUnit, aMode);

	return;

end



--
function VUHDO_deferSetHealth(aUnit, aMode, aPriority)

	VUHDO_deferTask(VUHDO_DEFER_SET_HEALTH, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_CRITICAL, aUnit, aMode);

	return;

end



--
function VUHDO_deferUpdateClusterHighlights(aPriority)

	VUHDO_deferTask(VUHDO_DEFER_UPDATE_CLUSTER_HIGHLIGHTS, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL);

	return;

end



--
function VUHDO_deferHandleScaleChange(aPriority)

	VUHDO_deferTask(VUHDO_DEFER_HANDLE_SCALE_CHANGE, aPriority or VUHDO_DEFERRED_TASK_PRIORITY_HIGH);

	return;

end



--
local tNewTask;
local function VUHDO_createDeferredTaskDelegate()

	tNewTask = {
		["args"] = { },
		["delegate"] = nil,
		["type"] = nil,
		["priority"] = VUHDO_DEFERRED_TASK_PRIORITY_NORMAL,
		["enqueueOrder"] = 0,
		["heapIndex"] = 0
	};

	return tNewTask;

end



--
local tCleanupTask;
local function VUHDO_cleanupDeferredTaskDelegate(aTask)

	tCleanupTask = aTask;

	twipe(tCleanupTask["args"]);
	tCleanupTask["delegate"] = nil;
	tCleanupTask["type"] = nil;
	tCleanupTask["priority"] = VUHDO_DEFERRED_TASK_PRIORITY_NORMAL;
	tCleanupTask["enqueueOrder"] = 0;
	tCleanupTask["heapIndex"] = 0;

	return;

end



do
	--
	local function VUHDO_getTaskKey(aType, aArgs)

		local tKey = tostring(aType);
		for i = 1, #aArgs do
			tKey = tKey .. "|" .. tostring(aArgs[i] or "");
		end
		return tKey;

	end



	--
	local function VUHDO_heapCompare(aTaskA, aTaskB)

		if aTaskA["priority"] ~= aTaskB["priority"] then
			return aTaskA["priority"] > aTaskB["priority"];
		end

		if aTaskA["enqueueOrder"] ~= aTaskB["enqueueOrder"] then
			return aTaskA["enqueueOrder"] < aTaskB["enqueueOrder"];
		end

		return aTaskA["heapIndex"] < aTaskB["heapIndex"];

	end



	--
	local tTaskA;
	local tTaskB;
	local function VUHDO_heapSwap(aHeap, anIndexA, anIndexB)

		tTaskA = aHeap[anIndexA];
		tTaskB = aHeap[anIndexB];

		aHeap[anIndexA] = tTaskB;
		aHeap[anIndexB] = tTaskA;

		tTaskA["heapIndex"] = anIndexB;
		tTaskB["heapIndex"] = anIndexA;

		return;

	end



	--
	local tChildIndex;
	local tParentIndex;
	local function VUHDO_heapSiftUp(aHeap, anIndex)

		tChildIndex = anIndex;
		tParentIndex = floor(tChildIndex / 2);

		while tChildIndex > 1 and VUHDO_heapCompare(aHeap[tChildIndex], aHeap[tParentIndex]) do
			VUHDO_heapSwap(aHeap, tChildIndex, tParentIndex);

			tChildIndex = tParentIndex;
			tParentIndex = floor(tChildIndex / 2);
		end

		return;

	end



	--
	local tParentIndex;
	local tLeftChildIndex;
	local tRightChildIndex;
	local tSwapIndex;
	local function VUHDO_heapSiftDown(aHeap, anIndex, aNumElements)

		tParentIndex = anIndex;

		while true do
			tLeftChildIndex = tParentIndex * 2;
			tRightChildIndex = tLeftChildIndex + 1;

			tSwapIndex = tParentIndex;

			if tLeftChildIndex <= aNumElements and VUHDO_heapCompare(aHeap[tLeftChildIndex], aHeap[tSwapIndex]) then
				tSwapIndex = tLeftChildIndex;
			end

			if tRightChildIndex <= aNumElements and VUHDO_heapCompare(aHeap[tRightChildIndex], aHeap[tSwapIndex]) then
				tSwapIndex = tRightChildIndex;
			end

			if tSwapIndex == tParentIndex then
				break;
			end

			VUHDO_heapSwap(aHeap, tParentIndex, tSwapIndex);

			tParentIndex = tSwapIndex;
		end

		return;

	end



	--
	local tNewIndex;
	function VUHDO_heapInsert(aHeap, aTask, aTaskMap)

		sNextTaskEnqueueOrder = sNextTaskEnqueueOrder + 1;
		aTask["enqueueOrder"] = sNextTaskEnqueueOrder;

		tNewIndex = #aHeap + 1;
		aHeap[tNewIndex] = aTask;
		aTask["heapIndex"] = tNewIndex;

		aTaskMap[VUHDO_getTaskKey(aTask["type"], aTask["args"])] = aTask;

		VUHDO_heapSiftUp(aHeap, tNewIndex);

		return;

	end



	--
	local tHeapSize;
	local tTopTask;
	local tTopTaskKey;
	function VUHDO_heapExtractTop(aHeap, aTaskMap)

		tHeapSize = #aHeap;
		if tHeapSize == 0 then
			return nil;
		end

		tTopTask = aHeap[1];

		tTopTaskKey = VUHDO_getTaskKey(tTopTask["type"], tTopTask["args"]);
		aTaskMap[tTopTaskKey] = nil;

		if tHeapSize == 1 then
			aHeap[1] = nil;
		else
			aHeap[1] = aHeap[tHeapSize];
			aHeap[tHeapSize] = nil;
			aHeap[1]["heapIndex"] = 1;

			VUHDO_heapSiftDown(aHeap, 1, tHeapSize - 1);
		end

		tTopTask["heapIndex"] = 0;

		return tTopTask;

	end



	--
	local tOldPriority;
	local function VUHDO_heapUpdateTask(aHeap, aTask, aNewPriority)

		tOldPriority = aTask["priority"];
		aTask["priority"] = aNewPriority;

		sNextTaskEnqueueOrder = sNextTaskEnqueueOrder + 1;
		aTask["enqueueOrder"] = sNextTaskEnqueueOrder;

		if aNewPriority > tOldPriority then
			VUHDO_heapSiftUp(aHeap, aTask["heapIndex"]);
		elseif aNewPriority < tOldPriority then
			VUHDO_heapSiftDown(aHeap, aTask["heapIndex"], #aHeap);
		else
			VUHDO_heapSiftUp(aHeap, aTask["heapIndex"]);
		end

		return;

	end



	--
	local tTaskChunkSnapshots;
	local tNewSnapshot;
	local tIsDuplicate;
	local tCompositionKey;
	local tTaskTypes;
	local function VUHDO_addChunkSnapshot(aTotalChunkTimeUs, aNumTasksInChunk, aTasksDetailTable)

		if not VUHDO_DEFERRED_TASK_PROFILING_ENABLED or aTotalChunkTimeUs < (VUHDO_DEFERRED_TASK_CONFIG["MAX_EXEC_TIME_US"] or 50000) then
			return;
		end

		tTaskChunkSnapshots = VUHDO_DEFERRED_TASK_CHUNK_SNAPSHOTS;
		tIsDuplicate = false;

		if aNumTasksInChunk > 0 and aTasksDetailTable and #aTasksDetailTable > 0 then
			tTaskTypes = { };

			for _, tTaskDetail in ipairs(aTasksDetailTable) do
				tinsert(tTaskTypes, tostring(tTaskDetail["type"]));
			end

			tCompositionKey = table.concat(tTaskTypes, ",");

			for _, tExistingSnapshot in ipairs(tTaskChunkSnapshots) do
				if not tExistingSnapshot["compositionKey"] then
					tTaskTypes = { };

					if tExistingSnapshot["tasks"] then
						for _, tTaskDetail in ipairs(tExistingSnapshot["tasks"]) do
							tinsert(tTaskTypes, tostring(tTaskDetail["type"]));
						end
					end

					tExistingSnapshot["compositionKey"] = table.concat(tTaskTypes, ",");
				end

				if tExistingSnapshot["compositionKey"] == tCompositionKey then
					tExistingSnapshot["dedupedCount"] = (tExistingSnapshot["dedupedCount"] or 1) + 1;

					if aTotalChunkTimeUs > tExistingSnapshot["totalChunkTimeUs"] then
						tExistingSnapshot["totalChunkTimeUs"] = aTotalChunkTimeUs;
						tExistingSnapshot["timestamp"] = time();

						twipe(tExistingSnapshot["tasks"]);

						for _, tTaskDetailSnapshot in ipairs(aTasksDetailTable) do
							tinsert(tExistingSnapshot["tasks"], {
								["type"] = tTaskDetailSnapshot["type"],
								["args"] = tTaskDetailSnapshot["args"],
								["argCount"] = tTaskDetailSnapshot["argCount"],
								["durationUs"] = tTaskDetailSnapshot["durationUs"],
							});
						end
					end

					tIsDuplicate = true;

					break;
				end
			end
		end

		if not tIsDuplicate then
			tNewSnapshot = {
				["totalChunkTimeUs"] = aTotalChunkTimeUs,
				["numTasksInChunk"] = aNumTasksInChunk,
				["tasks"] = { },
				["timestamp"] = time(),
				["dedupedCount"] = 1,
			};

			if aTasksDetailTable and #aTasksDetailTable > 0 then
				tTaskTypes = { };

				for _, tTaskDetailSnapshot in ipairs(aTasksDetailTable) do
					tinsert(tNewSnapshot["tasks"], {
						["type"] = tTaskDetailSnapshot["type"],
						["args"] = tTaskDetailSnapshot["args"],
						["argCount"] = tTaskDetailSnapshot["argCount"],
						["durationUs"] = tTaskDetailSnapshot["durationUs"],
					});

					tinsert(tTaskTypes, tostring(tTaskDetailSnapshot["type"]));
				end

				tNewSnapshot["compositionKey"] = table.concat(tTaskTypes, ",");
			else
				tNewSnapshot["compositionKey"] = "";
			end

			tinsert(tTaskChunkSnapshots, tNewSnapshot);
		end

		table.sort(tTaskChunkSnapshots, function(a, b) return a.totalChunkTimeUs > b.totalChunkTimeUs; end);

		while #tTaskChunkSnapshots > VUHDO_DEFERRED_TASK_CONFIG["CHUNK_SNAPSHOT_LIMIT"] do
			tremove(tTaskChunkSnapshots);
		end

		return;

	end



	--
	local tMetrics;
	local function VUHDO_sampleDeferredTaskQueueLength(aCurrentQueueLen)

		if not VUHDO_DEFERRED_TASK_PROFILING_ENABLED or not aCurrentQueueLen or aCurrentQueueLen <= 0 then
			return;
		end

		tMetrics = VUHDO_DEFERRED_TASK_STATE["metrics"];

		tMetrics["minQueueLength"] = min(tMetrics["minQueueLength"], aCurrentQueueLen);
		tMetrics["maxQueueLength"] = max(tMetrics["maxQueueLength"], aCurrentQueueLen);
		tMetrics["sumQueueLength"] = tMetrics["sumQueueLength"] + aCurrentQueueLen;
		tMetrics["queueLengthSamples"] = tMetrics["queueLengthSamples"] + 1;

		return;

	end



	--
	local tMetrics;
	local function VUHDO_incrementDeferredTaskHardStops()

		if not VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
			return;
		end

		tMetrics = VUHDO_DEFERRED_TASK_STATE["metrics"];
		tMetrics["hardStopsHit"] = (tMetrics["hardStopsHit"] or 0) + 1;

		return;

	end



	--
	local tMetrics;
	local function VUHDO_updateDeferredTasksInChunkPercentiles(aTasksCompletedInChunk)

		if not VUHDO_DEFERRED_TASK_PROFILING_ENABLED or not aTasksCompletedInChunk or aTasksCompletedInChunk <= 0 then
			return;
		end

		tMetrics = VUHDO_DEFERRED_TASK_STATE["metrics"];

		if not tMetrics["tasksInChunkPercentileTracker"] then
			tMetrics["tasksInChunkPercentileTracker"] = VUHDO_createPercentileTracker();
		end

		tMetrics["tasksInChunkPercentileTracker"]:update(aTasksCompletedInChunk);

		return;

	end



	--
	local tMetrics;
	local tHistory;
	local tTaskTrimmedMeans;
	local tQueueTrimmedMeans;
	local function VUHDO_updateDeferredTaskIndividualMetrics(aTaskType, aTaskDurationUs, aArgsSummary, aArgCount, aQueueTimeUs)

		if not VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
			return;
		end

		tMetrics = VUHDO_DEFERRED_TASK_STATE["metrics"];

		if not tMetrics["tasksProcessedByTypeSession"][aTaskType] then
			tMetrics["tasksProcessedByTypeSession"][aTaskType] = 0;

			if tMetrics["totalTimeUsByTypeSession"][aTaskType] == nil then
				tMetrics["totalTimeUsByTypeSession"][aTaskType] = 0;
			end

			if tMetrics["queueTimeUsByTypeSession"][aTaskType] == nil then
				tMetrics["queueTimeUsByTypeSession"][aTaskType] = 0;
			end

			if tMetrics["minTaskTimeUsByTypeSession"][aTaskType] == nil then
				tMetrics["minTaskTimeUsByTypeSession"][aTaskType] = 9999999;
			end

			if tMetrics["maxTaskTimeUsByTypeSession"][aTaskType] == nil then
				tMetrics["maxTaskTimeUsByTypeSession"][aTaskType] = 0;
			end

			if tMetrics["maxTaskTimeUsContextByTypeSession"][aTaskType] == nil then
				tMetrics["maxTaskTimeUsContextByTypeSession"][aTaskType] = nil;
			end

			if tMetrics["taskDurationHistoryByType"][aTaskType] == nil then
				tMetrics["taskDurationHistoryByType"][aTaskType] = { };
			end

			if tMetrics["queueTimeHistoryByType"][aTaskType] == nil then
				tMetrics["queueTimeHistoryByType"][aTaskType] = { };
			end
		end

		tMetrics["tasksProcessedByTypeSession"][aTaskType] = tMetrics["tasksProcessedByTypeSession"][aTaskType] + 1;
		tMetrics["totalTimeUsByTypeSession"][aTaskType] = tMetrics["totalTimeUsByTypeSession"][aTaskType] + aTaskDurationUs;
		tMetrics["queueTimeUsByTypeSession"][aTaskType] = tMetrics["queueTimeUsByTypeSession"][aTaskType] + (aQueueTimeUs or 0);

		if aQueueTimeUs and aQueueTimeUs > 0 then
			if not tMetrics["queueTimeHistoryByType"][aTaskType] then
				tMetrics["queueTimeHistoryByType"][aTaskType] = { };
			end

			tinsert(tMetrics["queueTimeHistoryByType"][aTaskType], aQueueTimeUs);

			if not tMetrics["queueTimePercentileTrackerByType"] then
				tMetrics["queueTimePercentileTrackerByType"] = { };
			end

			if not tMetrics["queueTimePercentileTrackerByType"][aTaskType] then
				tMetrics["queueTimePercentileTrackerByType"][aTaskType] = VUHDO_createPercentileTracker();
			end

			tMetrics["queueTimePercentileTrackerByType"][aTaskType]:update(aQueueTimeUs);

			tQueueTrimmedMeans = tMetrics["queueTimePercentileTrackerByType"][aTaskType]:getPercentiles();

			if not tQueueTrimmedMeans then
				tQueueTrimmedMeans = VUHDO_getDefaultPercentileFallback();
			end

			tMetrics["queueTimeTrimmedMeansByType"][aTaskType] = tQueueTrimmedMeans;
		end

		tMetrics["minTaskTimeUsByTypeSession"][aTaskType] = min(tMetrics["minTaskTimeUsByTypeSession"][aTaskType], aTaskDurationUs);

		tHistory = tMetrics["taskDurationHistoryByType"][aTaskType];
		tinsert(tHistory, aTaskDurationUs);

		if not tMetrics["taskDurationPercentileTrackerByType"] then
			tMetrics["taskDurationPercentileTrackerByType"] = { };
		end

		if not tMetrics["taskDurationPercentileTrackerByType"][aTaskType] then
			tMetrics["taskDurationPercentileTrackerByType"][aTaskType] = VUHDO_createPercentileTracker();
		end

		tMetrics["taskDurationPercentileTrackerByType"][aTaskType]:update(aTaskDurationUs);

		tTaskTrimmedMeans = tMetrics["taskDurationPercentileTrackerByType"][aTaskType]:getPercentiles();

		if not tTaskTrimmedMeans then
			tTaskTrimmedMeans = VUHDO_getDefaultPercentileFallback();
		end

		tMetrics["taskDurationTrimmedMeansByType"][aTaskType] = tTaskTrimmedMeans;

		if aTaskDurationUs > (tMetrics["maxTaskTimeUsByTypeSession"][aTaskType] or -1) then
			tMetrics["maxTaskTimeUsByTypeSession"][aTaskType] = aTaskDurationUs;

			tMetrics["maxTaskTimeUsContextByTypeSession"][aTaskType] = {
				["args"] = aArgsSummary,
				["argCount"] = aArgCount,
			};
		end

		return;

	end



	--
	local tMetrics;
	local function VUHDO_updateDeferredTaskChunkMetrics(aChunkElapsedTime, aNumTasksProcessed)

		if not VUHDO_DEFERRED_TASK_PROFILING_ENABLED or not aNumTasksProcessed or aNumTasksProcessed <= 0 then
			return;
		end

		tMetrics = VUHDO_DEFERRED_TASK_STATE["metrics"];

		tMetrics["chunksExecutedSuccessfully"] = (tMetrics["chunksExecutedSuccessfully"] or 0) + 1;
		tMetrics["totalTasksProcessedSession"] = (tMetrics["totalTasksProcessedSession"] or 0) + aNumTasksProcessed;
		tMetrics["totalProcessingTimeUsSession"] = (tMetrics["totalProcessingTimeUsSession"] or 0) + aChunkElapsedTime;

		if not tMetrics["chunkTimePercentileTracker"] then
			tMetrics["chunkTimePercentileTracker"] = VUHDO_createPercentileTracker();
		end

		tMetrics["chunkTimePercentileTracker"]:update(aChunkElapsedTime);

		return;

	end



	--
	local tDelegate;
	local tTaskKey;
	local tTask;
	local tNewTask;
	local tMetrics;
	local tCurrentPriority;
	function VUHDO_enqueueDeferredTask(aType, aPriority, ...)

		if not aType then
			return;
		end

		if not sDeferredTaskDelegates then
			return;
		end

		if not VUHDO_DEFERRED_TASK_POOL then
			return;
		end

		tCurrentPriority = aPriority or VUHDO_DEFERRED_TASK_PRIORITY_NORMAL;

		if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
			tMetrics = VUHDO_DEFERRED_TASK_STATE["metrics"];
		end

		tDelegate = sDeferredTaskDelegates[aType];

		if tDelegate then
			if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
				tMetrics["totalTasksEnqueued"] = tMetrics["totalTasksEnqueued"] + 1;

				if not tMetrics["tasksEnqueuedByType"][aType] then
					tMetrics["tasksEnqueuedByType"][aType] = 0;
				end

				tMetrics["tasksEnqueuedByType"][aType] = tMetrics["tasksEnqueuedByType"][aType] + 1;
			end

			tNewTask = VUHDO_DEFERRED_TASK_POOL:get();

			for tArgCnt = 1, select("#", ...) do
				tNewTask["args"][tArgCnt] = select(tArgCnt, ...);
			end

			tNewTask["delegate"] = tDelegate;
			tNewTask["type"] = aType;
			tNewTask["priority"] = tCurrentPriority;

			if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
				tNewTask["enqueueTime"] = GetTime();
			end

			tTaskKey = VUHDO_getTaskKey(aType, tNewTask["args"]);
			tTask = VUHDO_TASK_QUEUE_MAP[tTaskKey];

			if tTask then
				VUHDO_heapUpdateTask(VUHDO_TASK_PRIORITY_QUEUE, tTask, tCurrentPriority);

				tTask["delegate"] = tDelegate;

				VUHDO_DEFERRED_TASK_POOL:release(tNewTask);

				if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
					tMetrics["totalTasksDeduped"] = tMetrics["totalTasksDeduped"] + 1;
				end
			else
				VUHDO_heapInsert(VUHDO_TASK_PRIORITY_QUEUE, tNewTask, VUHDO_TASK_QUEUE_MAP);
			end
		end

		return;

	end



	--
	local tMaxTasksPerFrame;
	local tInvocationCount;
	local tTaskState;
	local tTaskConfig;
	local tCostHistory;
	local tIndividualCosts;
	local tCostEstimate;
	local tSum;
	local tTrimCount;
	local tStartIndex;
	local tEndIndex;
	local tCount;
	local tDefaultCost;
	local tMaxReasonableCost;
	function VUHDO_adjustDynamicDeferTasks()

		tTaskState = VUHDO_DEFERRED_TASK_STATE;
		tTaskConfig = VUHDO_DEFERRED_TASK_CONFIG;

		tMaxTasksPerFrame = tTaskState["maxTasksPerFrame"];

		if VUHDO_DEFERRED_TASK_PROFILING_ENABLED and VUHDO_DEFERRED_TASK_TYPES then
			for _, tTaskType in pairs(VUHDO_DEFERRED_TASK_TYPES) do
				tInvocationCount = tTaskState["invocationCountByType"][tTaskType] or 0;

				if tInvocationCount > 0 then
					if not tTaskState["costHistoryByType"] then
						tTaskState["costHistoryByType"] = { };
					end

					if not tTaskState["costHistoryByType"][tTaskType] then
						tTaskState["costHistoryByType"][tTaskType] = { };
					end

					tCostHistory = tTaskState["costHistoryByType"][tTaskType];
					tIndividualCosts = tTaskState["individualCostsByType"] and tTaskState["individualCostsByType"][tTaskType] or { };

					for _, tCost in pairs(tIndividualCosts) do
						tinsert(tCostHistory, tCost);
					end

					while #tCostHistory > 20 do
						tremove(tCostHistory, 1);
					end

					tCostEstimate = 0;

					if #tCostHistory >= 5 then
						table.sort(tCostHistory);

						tTrimCount = max(1, floor(#tCostHistory * 0.1));
						tStartIndex = tTrimCount + 1;
						tEndIndex = #tCostHistory - tTrimCount;

						if tStartIndex <= tEndIndex then
							tSum = 0;
							tCount = 0;

							for tCnt = tStartIndex, tEndIndex do
								tSum = tSum + tCostHistory[tCnt];

								tCount = tCount + 1;
							end

							tCostEstimate = tSum / tCount;
						else
							tSum = 0;

							for _, tCost in pairs(tCostHistory) do
								tSum = tSum + tCost;
							end

							tCostEstimate = tSum / #tCostHistory;
						end
					else
						tSum = 0;

						for _, tCost in pairs(tCostHistory) do
							tSum = tSum + tCost;
						end

						tCostEstimate = #tCostHistory > 0 and (tSum / #tCostHistory) or 0;
					end

					tDefaultCost = VUHDO_TASK_TYPE_DEFAULT_COSTS[tTaskType] or (tTaskConfig["TARGET_EXEC_TIME_US"] / max(1, tTaskConfig["MAX_TASKS_PER_FRAME"])) * 1.2;
					tMaxReasonableCost = tDefaultCost * 2;

					if tCostEstimate > tMaxReasonableCost or tCostEstimate <= 0 then
						tCostEstimate = tDefaultCost;
					end

					tTaskState["avgCostUsByType"][tTaskType] = tCostEstimate;

					if tTaskState["individualCostsByType"] then
						tTaskState["individualCostsByType"][tTaskType] = { };
					end
				elseif tTaskState["avgCostUsByType"][tTaskType] == nil then
					tTaskState["avgCostUsByType"][tTaskType] = VUHDO_TASK_TYPE_DEFAULT_COSTS[tTaskType] or
						(tTaskConfig["TARGET_EXEC_TIME_US"] / max(1, tTaskConfig["MAX_TASKS_PER_FRAME"])) * 1.2;

					tTaskState["invocationCountByType"][tTaskType] = 0;
				end
			end
		end

		tTaskState["maxTasksPerFrame"] = floor(max(tTaskConfig["MIN_TASKS_PER_FRAME"], min(tMaxTasksPerFrame, tTaskConfig["MAX_TASKS_PER_FRAME"])));

		return;

	end



	--
	local tStack;
	local function VUHDO_deferredTaskErrorHandler(tError)

		-- tError is the original error string/object
		-- debugstack([thread,] startLevel, numLevels, levelsToSkip)
		-- we want to skip 3 levels:
		-- 1. this error handler function itself
		-- 2. the C/internal call for xpcall
		-- 3. the function wrapper around the delegate
		-- then start capturing from the next level (the actual delegate).
		tStack = debugstack(1, 20, 3); -- capture up to 20 levels, after skipping 3

		return tostring(tError) .. "\nStacktrace:\n" .. tStack;

	end



	--
	local sCurrentTaskForPcall;
	local function VUHDO_pcallTaskDelegate()

		return sCurrentTaskForPcall["delegate"](unpack(sCurrentTaskForPcall["args"]));

	end



	--
	local function VUHDO_pcallWrapper()

		return xpcall(VUHDO_pcallTaskDelegate, VUHDO_deferredTaskErrorHandler);

	end



	--
	local tTask;
	local tTaskType;
	local tDelegateSuccess;
	local tDelegateResult;
	local tTaskDurationUs;
	local tTaskStartTime;
	local tArgsSummary;
	local tProfilerResult;
	local tQueueTimeUs;
	function VUHDO_executeSingleTask(aTask)

		tTask = aTask;
		tTaskType = tTask["type"];

		if not tTask["delegate"] then
			return false, "No delegate function", 0;
		end

		sCurrentTaskForPcall = tTask;

		if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
			tTaskDurationUs = 0;

			if MeasureCall then
				tProfilerResult, tDelegateSuccess, tDelegateResult = MeasureCall(VUHDO_pcallWrapper);

				if tProfilerResult and tProfilerResult.elapsedMilliseconds then
					tTaskDurationUs = tProfilerResult.elapsedMilliseconds * 1000;
				end
			else
				tTaskStartTime = debugprofilestop();

				tDelegateSuccess, tDelegateResult = VUHDO_pcallWrapper();

				tTaskDurationUs = (debugprofilestop() - tTaskStartTime) * 1000;
			end
		else
			tDelegateSuccess, tDelegateResult = VUHDO_pcallWrapper();
		end

		sCurrentTaskForPcall = nil;

		if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
			tQueueTimeUs = 0;

			if tTask["enqueueTime"] then
				tQueueTimeUs = (GetTime() - tTask["enqueueTime"]) * 1000000;
			end

			VUHDO_DEFERRED_TASK_STATE["invocationCountByType"][tTaskType] = (VUHDO_DEFERRED_TASK_STATE["invocationCountByType"][tTaskType] or 0) + 1;

			if not VUHDO_DEFERRED_TASK_STATE["individualCostsByType"] then
				VUHDO_DEFERRED_TASK_STATE["individualCostsByType"] = { };
			end

			if not VUHDO_DEFERRED_TASK_STATE["individualCostsByType"][tTaskType] then
				VUHDO_DEFERRED_TASK_STATE["individualCostsByType"][tTaskType] = { };
			end

			tinsert(VUHDO_DEFERRED_TASK_STATE["individualCostsByType"][tTaskType], tTaskDurationUs);

			if not VUHDO_DEFERRED_TASK_STATE["queueTimeUsByType"] then
				VUHDO_DEFERRED_TASK_STATE["queueTimeUsByType"] = { };
			end

			VUHDO_DEFERRED_TASK_STATE["queueTimeUsByType"][tTaskType] = (VUHDO_DEFERRED_TASK_STATE["queueTimeUsByType"][tTaskType] or 0) + tQueueTimeUs;
		end

		if not tDelegateSuccess then
			tArgsSummary = "";

			if tTask["args"] and #tTask["args"] > 0 then
				for tCnt = 1, #tTask["args"] do
					if tCnt > 1 then
						tArgsSummary = tArgsSummary .. ",";
					end

					tArgsSummary = tArgsSummary .. tostring(tTask["args"][tCnt] or "nil");
				end
			else
				tArgsSummary = "none";
			end

			VUHDO_Msg(format("Task Execution Failure: [ Args: %s Type: %s Prio: %s ]\nError: %s",
				tArgsSummary, tostring(tTaskType), tostring(tTask["priority"]),
				tostring(tDelegateResult)
			));
		end

		return tDelegateSuccess, tDelegateResult, tTaskDurationUs;

	end



	--
	local tTaskState;
	local tTaskConfig;
	local tTasksCompleted;
	local tHardStopTime;
	local tTask;
	local tTaskType;
	local tTaskDurationUs;
	local tCurrentQueueLen;
	local tTaskMetricsForSnapshot = { };
	local tArgsSummary;
	local tQueueTimeUs;
	local tShouldProcessTask;
	local tEstimatedCostOfNextTask;
	local tPredictionError;
	local tPredictionAccuracy;
	local tAccuracy;
	function VUHDO_executeDeferredTaskChunk()

		tTaskState = VUHDO_DEFERRED_TASK_STATE;
		tTaskConfig = VUHDO_DEFERRED_TASK_CONFIG;

		if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
			tCurrentQueueLen = #VUHDO_TASK_PRIORITY_QUEUE;

			VUHDO_sampleDeferredTaskQueueLength(tCurrentQueueLen);

			twipe(tTaskMetricsForSnapshot);
		end

		tTasksCompleted = 0;
		tHardStopTime = (debugprofilestop() * 1000) + tTaskConfig["MAX_EXEC_TIME_US"] + 100;

		for tTaskCount = 1, tTaskState["maxTasksPerFrame"] do
			if #VUHDO_TASK_PRIORITY_QUEUE == 0 then
				break;
			end

			if (debugprofilestop() * 1000) > tHardStopTime and tTasksCompleted >= tTaskConfig["MIN_TASKS_PER_FRAME"] then
				VUHDO_incrementDeferredTaskHardStops();

				break;
			end

			tTask = VUHDO_TASK_PRIORITY_QUEUE[1];

			tTaskType = tTask["type"];

			tShouldProcessTask = (tTasksCompleted < tTaskConfig["MIN_TASKS_PER_FRAME"]) or
				(tTasksCompleted < tTaskState["maxTasksPerFrame"]);

			if tShouldProcessTask then
				tTask = VUHDO_heapExtractTop(VUHDO_TASK_PRIORITY_QUEUE, VUHDO_TASK_QUEUE_MAP);

				if tTask["delegate"] and tTaskType then
					_, _, tTaskDurationUs = VUHDO_executeSingleTask(tTask);

					if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
						tArgsSummary = "";

						if tTask["args"] and #tTask["args"] > 0 then
							for tCnt = 1, #tTask["args"] do
								if tCnt > 1 then
									tArgsSummary = tArgsSummary .. ",";
								end

								tArgsSummary = tArgsSummary .. tostring(tTask["args"][tCnt] or "nil");
							end
						else
							tArgsSummary = "none";
						end

						tQueueTimeUs = 0;

						if tTask["enqueueTime"] then
							tQueueTimeUs = (GetTime() - tTask["enqueueTime"]) * 1000000;
						end

						VUHDO_updateDeferredTaskIndividualMetrics(tTaskType, tTaskDurationUs, tArgsSummary, #tTask["args"] or 0, tQueueTimeUs);

						if tTaskMetricsForSnapshot then
							tinsert(tTaskMetricsForSnapshot, {
								["type"] = tTaskType,
								["args"] = tArgsSummary,
								["argCount"] = #tTask["args"] or 0,
								["durationUs"] = tTaskDurationUs,
							});
						end

						tEstimatedCostOfNextTask = tTaskState["avgCostUsByType"][tTaskType] or VUHDO_TASK_TYPE_DEFAULT_COSTS[tTaskType] or 0;
						tPredictionError = abs(tEstimatedCostOfNextTask - tTaskDurationUs);
						tPredictionAccuracy = 1 - (tPredictionError / max(1, tTaskDurationUs));

						tPredictionAccuracy = max(-1, min(1, tPredictionAccuracy));

						if not tTaskState["costPredictionAccuracy"] then
							tTaskState["costPredictionAccuracy"] = { };
						end

						if not tTaskState["costPredictionAccuracy"][tTaskType] then
							tTaskState["costPredictionAccuracy"][tTaskType] = {
								["total"] = 0,
								["count"] = 0,
								["accuracy"] = 0,
							};
						end

						tAccuracy = tTaskState["costPredictionAccuracy"][tTaskType];

						tAccuracy["total"] = tAccuracy["total"] + tPredictionAccuracy;
						tAccuracy["count"] = tAccuracy["count"] + 1;
						tAccuracy["accuracy"] = tAccuracy["total"] / tAccuracy["count"];
					end

					tTasksCompleted = tTasksCompleted + 1;

					VUHDO_DEFERRED_TASK_POOL:release(tTask);

					tTask = nil;
				end
			end
		end

		if VUHDO_DEFERRED_TASK_PROFILING_ENABLED and tTasksCompleted > 0 then
			VUHDO_updateDeferredTasksInChunkPercentiles(tTasksCompleted);
		end

		return tTasksCompleted, tTaskMetricsForSnapshot;

	end



	--
	local tTaskState;
	local tTaskConfig;
	local tNumTasksProcessed;
	local tChunkElapsedTime;
	local tChunkDelegate;
	local tProfilerResult;
	local tChunkStartTime;
	local tChunkTaskMetrics;
	function VUHDO_processDeferredTaskQueue()

		VUHDO_checkAllSemaphoreTimeouts();

		tTaskState = VUHDO_DEFERRED_TASK_STATE;
		tTaskConfig = VUHDO_DEFERRED_TASK_CONFIG;

		tNumTasksProcessed = 0;

		if not VUHDO_DEFERRED_TASK_POOL then
			return;
		end

		if #VUHDO_TASK_PRIORITY_QUEUE > 0 then
			if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
				tChunkDelegate = VUHDO_executeDeferredTaskChunk;

				if MeasureCall then
					tProfilerResult, tNumTasksProcessed, tChunkTaskMetrics = MeasureCall(tChunkDelegate);

					if tProfilerResult and tProfilerResult.elapsedMilliseconds then
						tChunkElapsedTime = tProfilerResult.elapsedMilliseconds * 1000;
					end
				else
					tChunkStartTime = debugprofilestop();

					tNumTasksProcessed, tChunkTaskMetrics = tChunkDelegate();

					tChunkElapsedTime = (debugprofilestop() - tChunkStartTime) * 1000;
				end

				if tNumTasksProcessed and tNumTasksProcessed > 0 then
					VUHDO_updateDeferredTaskChunkMetrics(tChunkElapsedTime, tNumTasksProcessed);

					if tChunkTaskMetrics then
						VUHDO_addChunkSnapshot(tChunkElapsedTime, tNumTasksProcessed, tChunkTaskMetrics);
					end
				end
			else
				tNumTasksProcessed = VUHDO_executeDeferredTaskChunk();
			end
		end

		if VUHDO_DEFERRED_TASK_PROFILING_ENABLED and GetTime() - tTaskState["lastAdjustTime"] >= tTaskConfig["ADJUST_INTERVAL_SECS"] then
			VUHDO_adjustDynamicDeferTasks();

			tTaskState["lastAdjustTime"] = GetTime();
		end

		return;

	end



	--
	function VUHDO_deferTask(aType, aPriority, ...)

		VUHDO_enqueueDeferredTask(aType, aPriority, ...);

		return;

	end



	--
	function VUHDO_setDeferredTaskProfiling(anIsEnabled)

		VUHDO_DEFERRED_TASK_PROFILING_ENABLED = anIsEnabled;

		if anIsEnabled then
			VUHDO_Msg("Task profiling is enabled.");
		else
			VUHDO_Msg("Task Profiling is disabled.");
		end

		return;

	end



	--
	function VUHDO_isDeferredTaskProfilingEnabled()

		return VUHDO_DEFERRED_TASK_PROFILING_ENABLED;

	end



	--
	local tMetricsReset;
	function VUHDO_resetDeferredTaskMetrics()

		tMetricsReset = VUHDO_DEFERRED_TASK_STATE["metrics"];

		tMetricsReset["sessionStartTime"] = GetTime();
		tMetricsReset["totalTasksEnqueued"] = 0;
		tMetricsReset["totalTasksDeduped"] = 0;
		tMetricsReset["totalTasksProcessedSession"] = 0;
		tMetricsReset["totalProcessingTimeUsSession"] = 0;
		tMetricsReset["chunksExecutedSuccessfully"] = 0;

		tMetricsReset["minQueueLength"] = 999999;
		tMetricsReset["maxQueueLength"] = 0;
		tMetricsReset["sumQueueLength"] = 0;
		tMetricsReset["queueLengthSamples"] = 0;

		if tMetricsReset["tasksInChunkPercentileTracker"] then
			tMetricsReset["tasksInChunkPercentileTracker"]:reset();
		else
			tMetricsReset["tasksInChunkPercentileTracker"] = nil;
		end

		if tMetricsReset["chunkTimePercentileTracker"] then
			tMetricsReset["chunkTimePercentileTracker"]:reset();
		else
			tMetricsReset["chunkTimePercentileTracker"] = nil;
		end

		tMetricsReset["hardStopsHit"] = 0;
		tMetricsReset["unsafeTasksProcessed"] = 0;

		twipe(tMetricsReset["tasksEnqueuedByType"]);
		twipe(tMetricsReset["tasksProcessedByTypeSession"]);
		twipe(tMetricsReset["totalTimeUsByTypeSession"]);
		twipe(tMetricsReset["queueTimeUsByTypeSession"]);

		if tMetricsReset["minTaskTimeUsByTypeSession"] then
			twipe(tMetricsReset["minTaskTimeUsByTypeSession"]);
		else
			tMetricsReset["minTaskTimeUsByTypeSession"] = { };
		end

		if tMetricsReset["maxTaskTimeUsByTypeSession"] then
			twipe(tMetricsReset["maxTaskTimeUsByTypeSession"]);
		else
			tMetricsReset["maxTaskTimeUsByTypeSession"] = { };
		end

		if tMetricsReset["maxTaskTimeUsContextByTypeSession"] then
			twipe(tMetricsReset["maxTaskTimeUsContextByTypeSession"]);
		else
			tMetricsReset["maxTaskTimeUsContextByTypeSession"] = { };
		end

		if tMetricsReset["taskDurationHistoryByType"] then
			twipe(tMetricsReset["taskDurationHistoryByType"]);
		else
			tMetricsReset["taskDurationHistoryByType"] = { };
		end

		if tMetricsReset["taskDurationTrimmedMeansByType"] then
			twipe(tMetricsReset["taskDurationTrimmedMeansByType"]);
		else
			tMetricsReset["taskDurationTrimmedMeansByType"] = { };
		end

		if tMetricsReset["queueTimeTrimmedMeansByType"] then
			twipe(tMetricsReset["queueTimeTrimmedMeansByType"]);
		else
			tMetricsReset["queueTimeTrimmedMeansByType"] = { };
		end

		if tMetricsReset["taskDurationPercentileTrackerByType"] then
			twipe(tMetricsReset["taskDurationPercentileTrackerByType"]);
		else
			tMetricsReset["taskDurationPercentileTrackerByType"] = { };
		end

		if tMetricsReset["queueTimePercentileTrackerByType"] then
			twipe(tMetricsReset["queueTimePercentileTrackerByType"]);
		else
			tMetricsReset["queueTimePercentileTrackerByType"] = { };
		end

		twipe(VUHDO_DEFERRED_TASK_CHUNK_SNAPSHOTS);

		if VUHDO_DEFERRED_TASK_POOL and VUHDO_DEFERRED_TASK_POOL.resetMetrics then
			VUHDO_DEFERRED_TASK_POOL:resetMetrics();
		end

		if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
			VUHDO_Msg("Deferred task metrics reset.");
		end

		return;

	end



	--
	local tMetrics;
	local tTaskConfig;
	local tEnqueued;
	local tProcessed;
	local tPoolMetrics;
	local tMaxTaskContextArgs;
	local tDedupedText;
	local tTrimmedMeans;
	local tArgsSummary;
	local tTotalTasksProcessed;
	local tSessionDuration;
	local tTasksPerSecond;
	local tTasksPerCentumMs;
	local tTotalQueueTimeUsForType;
	local tQueueTimeTrimmedMeans;
	local tAccuracy;
	local tKey;
	local tPercentileFormatString;
	local tPercentileValueString;
	local tPercentileKeys;
	local tPercentileValues;
	local tQueuePercentileValues;
	local tTasksPercentileValues;
	local tTimePercentileValues;
	function VUHDO_printDeferredTaskMetrics(anIsReset)

		if not VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
			VUHDO_Msg("Task profiling is currently disabled.");

			return;
		end

		tMetrics = VUHDO_DEFERRED_TASK_STATE["metrics"];
		tTaskConfig = VUHDO_DEFERRED_TASK_CONFIG;

		tSessionDuration = GetTime() - (tMetrics["sessionStartTime"] or GetTime());

		if tSessionDuration < 0 then
			tSessionDuration = 0;
		end

		VUHDO_Msg("|cffFFD100--- Deferred Task Queue Metrics (Session: " .. format("%.2f sec", tSessionDuration) .. ") ---|r");

		VUHDO_Msg(format("|cffFFA500** Overall Tasks:|r Enqueued: %d, Deduped: %d, Processed: %d, Unsafe: %d",
			(tMetrics["totalTasksEnqueued"] or 0), (tMetrics["totalTasksDeduped"] or 0), (tMetrics["totalTasksProcessedSession"] or 0), (tMetrics["unsafeTasksProcessed"] or 0)));
		VUHDO_Msg(format("|cffFFA500** Overall Time:|r Total: %s, Chunks Executed: %d",
			VUHDO_formatTime(tMetrics["totalProcessingTimeUsSession"]), (tMetrics["chunksExecutedSuccessfully"] or 0)));

		VUHDO_Msg("|cffFFA500** Queue Length:|r Current: " .. #VUHDO_TASK_PRIORITY_QUEUE);

		if (tMetrics["queueLengthSamples"] or 0) > 0 then
			VUHDO_Msg(format("  |cff98FB98Samples:|r Min: %d, Max: %d, Avg: %.2f",
				(tMetrics["minQueueLength"] == 999999 and 0 or (tMetrics["minQueueLength"] or 0)),
				(tMetrics["maxQueueLength"] or 0),
				((tMetrics["sumQueueLength"] or 0) / tMetrics["queueLengthSamples"])));
		else
			VUHDO_Msg("  |cff98FB98Samples:|r No queue length samples recorded (empty or reset).");
		end

		tPercentileFormatString, tPercentileValueString, tPercentileKeys = VUHDO_getPercentileFormatStrings();

		VUHDO_Msg("|cffFFA500** Chunk Performance (for " .. (tMetrics["chunksExecutedSuccessfully"] or 0) .. " successful chunks):|r");

		if (tMetrics["chunksExecutedSuccessfully"] or 0) > 0 then
			tTrimmedMeans = tMetrics["tasksInChunkPercentileTracker"] and tMetrics["tasksInChunkPercentileTracker"]:getPercentiles() or VUHDO_getDefaultPercentileFallback();
			tTasksPercentileValues = { };

			for tIndex = 1, #tPercentileKeys do
				tKey = tPercentileKeys[tIndex];
				tTasksPercentileValues[tIndex] = tostring(tTrimmedMeans[tKey] or 0);
			end

			VUHDO_Msg(format("  |cffB0E0E6Tasks/Chunk:|r " .. tPercentileValueString,
				unpack(tTasksPercentileValues)));

			tTrimmedMeans = tMetrics["chunkTimePercentileTracker"] and tMetrics["chunkTimePercentileTracker"]:getPercentiles() or VUHDO_getDefaultPercentileFallback();
			tTimePercentileValues = { };

			for tIndex = 1, #tPercentileKeys do
				tKey = tPercentileKeys[tIndex];
				tTimePercentileValues[tIndex] = VUHDO_formatTime(tTrimmedMeans[tKey] or 0) or "0 us";
			end

			VUHDO_Msg(format("  |cffB0E0E6Time/Chunk:|r " .. tPercentileValueString,
				unpack(tTimePercentileValues)));
		else
			VUHDO_Msg("  |cff98FB98No chunks processed tasks or metrics reset.|r");
		end

		VUHDO_Msg(format("  |cff98FB98Stops:|r Hard (Time Limit): %d",
			(tMetrics["hardStopsHit"] or 0)));

		tTotalTasksProcessed = tMetrics["totalTasksProcessedSession"] or 0;
		tSessionDuration = GetTime() - (tMetrics["sessionStartTime"] or GetTime());

		if tSessionDuration > 0 then
			tTasksPerSecond = tTotalTasksProcessed / tSessionDuration;
			tTasksPerCentumMs = tTasksPerSecond * 0.1;

			VUHDO_Msg(format("|cffFFA500** Task Throughput:|r %.2f tasks/sec (%.2f tasks/100ms)",
				tTasksPerSecond, tTasksPerCentumMs));
		end

		VUHDO_Msg("|cffFFA500** Per-Task Type (Enqueued, Processed, " .. tPercentileFormatString .. " [Args]): **|r");
		VUHDO_Msg("|cffFFA500** Queue Time Statistics (Total Queue Time, Avg Queue Time per Task): **|r");
		VUHDO_Msg("|cffFFA500** Cost Prediction Accuracy (Predicted vs Actual): **|r");

		if VUHDO_DEFERRED_TASK_TYPES then
			for _, tTaskType in ipairs(VUHDO_DEFERRED_TASK_TYPES) do
				tEnqueued = (tMetrics["tasksEnqueuedByType"] and tMetrics["tasksEnqueuedByType"][tTaskType]) or 0;
				tProcessed = (tMetrics["tasksProcessedByTypeSession"] and tMetrics["tasksProcessedByTypeSession"][tTaskType]) or 0;
				tTotalQueueTimeUsForType = (tMetrics["queueTimeUsByTypeSession"] and tMetrics["queueTimeUsByTypeSession"][tTaskType]) or 0;

				tMaxTaskContextArgs = "-";

				if tMetrics["maxTaskTimeUsContextByTypeSession"] and tMetrics["maxTaskTimeUsContextByTypeSession"][tTaskType] then
					tMaxTaskContextArgs = tostring(tMetrics["maxTaskTimeUsContextByTypeSession"][tTaskType]["args"] or "-");
				end

				tTrimmedMeans = tMetrics["taskDurationTrimmedMeansByType"][tTaskType];

				if not tTrimmedMeans then
					tTrimmedMeans = VUHDO_getDefaultPercentileFallback();
				end

				tPercentileValues = { };

				if tTrimmedMeans then
					for tIndex = 1, #tPercentileKeys do
						tKey = tPercentileKeys[tIndex];

						tPercentileValues[tIndex] = VUHDO_formatTime(tTrimmedMeans[tKey] or 0) or "0 us";
					end
				else
					for tIndex = 1, #tPercentileKeys do
						tPercentileValues[tIndex] = "0 us";
					end
				end

				local tArgs = { tostring(tTaskType), tEnqueued, tProcessed };

				for tIndex = 1, #tPercentileValues do
					tinsert(tArgs, tPercentileValues[tIndex]);
				end

				tinsert(tArgs, tMaxTaskContextArgs);

				VUHDO_Msg(format("  |cffB0E0E6Type[%s]:|r E=%d, P=%d, " .. tPercentileValueString .. " [%s]",
					unpack(tArgs)
				));

				tQueueTimeTrimmedMeans = tMetrics["queueTimeTrimmedMeansByType"][tTaskType];

				if not tQueueTimeTrimmedMeans then
					tQueueTimeTrimmedMeans = VUHDO_getDefaultPercentileFallback();
				end

				tQueuePercentileValues = { };

				for tIndex = 1, #tPercentileKeys do
					tQueuePercentileValues[tIndex] = "0 us";
				end

				if tQueueTimeTrimmedMeans then
					for tIndex = 1, #tPercentileKeys do
						tKey = tPercentileKeys[tIndex];

						if tQueueTimeTrimmedMeans[tKey] then
							tQueuePercentileValues[tIndex] = VUHDO_formatTime(tQueueTimeTrimmedMeans[tKey]) or "0 us";
						end
					end
				end

				if not tQueuePercentileValues or #tQueuePercentileValues == 0 then
					tQueuePercentileValues = { };

					for tIndex = 1, #tPercentileKeys do
						tQueuePercentileValues[tIndex] = "0 us";
					end
				end

				local tQueueArgs = { VUHDO_formatTime(tTotalQueueTimeUsForType) };

				for tIndex = 1, #tQueuePercentileValues do
					tinsert(tQueueArgs, tQueuePercentileValues[tIndex]);
				end

				VUHDO_Msg(format("    |cff98FB98Queue:|r Total=%s, " .. tPercentileValueString,
					unpack(tQueueArgs)));

				tAccuracy = VUHDO_DEFERRED_TASK_STATE["costPredictionAccuracy"] and VUHDO_DEFERRED_TASK_STATE["costPredictionAccuracy"][tTaskType];

				if tAccuracy and tAccuracy["count"] > 0 then
					VUHDO_Msg(format("    |cff98FB98Cost:|r Accuracy=%.1f%%, Samples=%d, Avg Cost=%s",
						tAccuracy["accuracy"] * 100, tAccuracy["count"],
						VUHDO_formatTime(VUHDO_DEFERRED_TASK_STATE["avgCostUsByType"] and VUHDO_DEFERRED_TASK_STATE["avgCostUsByType"][tTaskType] or 0)));
				else
					VUHDO_Msg("    |cff98FB98Cost Prediction:|r No data available");
				end
			end
		else
			VUHDO_Msg("  (VUHDO_DEFERRED_TASK_TYPES not found for detailed stats)");
		end

		VUHDO_Msg("|cffFFA500** Dynamic Config:|r");

		VUHDO_Msg(format("  |cffB0E0E6Target Time/Chunk:|r %s, |cffB0E0E6Max Time/Chunk:|r %s",
			VUHDO_formatTime(tTaskConfig["TARGET_EXEC_TIME_US"]), VUHDO_formatTime(tTaskConfig["MAX_EXEC_TIME_US"])));
		VUHDO_Msg(format("  |cffB0E0E6Max Tasks/Frame:|r %d, |cffB0E0E6Idle Inc Threshold:|r %s",
			(VUHDO_DEFERRED_TASK_STATE["maxTasksPerFrame"] or 0), VUHDO_formatTime(tTaskConfig["IDLE_TASK_INC_THRESHOLD_US"])));

		VUHDO_Msg("|cffFFA500** Pool Stats (Size, Idle, PeakIdle, Hits, Misses, RejectedReleases): **|r");

		if VUHDO_DEFERRED_TASK_POOL and VUHDO_DEFERRED_TASK_POOL.getMetrics then
			tPoolMetrics = VUHDO_DEFERRED_TASK_POOL:getMetrics();

			VUHDO_Msg(format("  |cffB0E0E6Tasks Pool:|r %d, %d, %d, %d, %d, %d",
				(tPoolMetrics["maxSize"] or 0), (tPoolMetrics["currentIdle"] or 0), (tPoolMetrics["peakIdleCount"] or 0),
				(tPoolMetrics["hits"] or 0), (tPoolMetrics["misses"] or 0), (tPoolMetrics["rejectedReleases"] or 0)
			));
		else
			VUHDO_Msg("  |cffB0E0E6Tasks Pool:|r Metrics unavailable.");
		end

		if #VUHDO_DEFERRED_TASK_CHUNK_SNAPSHOTS > 0 then
			VUHDO_Msg("|cffFFA500** Top " .. #VUHDO_DEFERRED_TASK_CHUNK_SNAPSHOTS .. " Expensive Deferred Task Chunks (|cffB0E0E6Threshold:|r >" .. (VUHDO_formatTime(VUHDO_DEFERRED_TASK_CONFIG["MAX_EXEC_TIME_US"])) .. "): **|r");

			for tSnapshotCnt, tSnapshot in ipairs(VUHDO_DEFERRED_TASK_CHUNK_SNAPSHOTS) do
				tDedupedText = "";

				if (tSnapshot["dedupedCount"] or 0) > 1 then
					tDedupedText = format(" (|cff98FB98deduped|r %d times)", tSnapshot["dedupedCount"]);
				end

				VUHDO_Msg(format("  #%d: |cffB0E0E6ChunkTotalTime:|r %s, |cffB0E0E6NumTasks:|r %d, |cffB0E0E6Timestamp:|r %s%s",
					tSnapshotCnt,
					VUHDO_formatTime(tSnapshot["totalChunkTimeUs"]),
					tSnapshot["numTasksInChunk"],
					date("%m/%d/%y %H:%M:%S", tSnapshot["timestamp"]),
					tDedupedText
				));

				if tSnapshot["tasks"] then
					for tCnt, tTask in ipairs(tSnapshot["tasks"]) do
						tArgsSummary = tTask["args"] or "none";

						VUHDO_Msg(format("    T%d: |cffB0E0E6Type[%s]|r %s (|cff98FB98Args:|r%s)",
							tCnt,
							tostring(tTask["type"]),
							VUHDO_formatTime(tTask["durationUs"]),
							tArgsSummary
						));
					end
				end
			end
		else
			VUHDO_Msg("|cffFFA500** No expensive deferred task chunks captured. **|r");
		end

		VUHDO_Msg("|cffFFD100--- End of Metrics ---|r");

		if anIsReset then
			VUHDO_resetDeferredTaskMetrics();
		end

		return;

	end
end



--
local tTask;
local tTasksToReinsert;
local function VUHDO_extractAllTasksFromQueue()

	tTasksToReinsert = {};

	while #VUHDO_TASK_PRIORITY_QUEUE > 0 do
		tTask = VUHDO_heapExtractTop(VUHDO_TASK_PRIORITY_QUEUE, VUHDO_TASK_QUEUE_MAP);

		tinsert(tTasksToReinsert, tTask);
	end

	twipe(VUHDO_TASK_QUEUE_MAP);

	return tTasksToReinsert;

end



--
function VUHDO_reinsertTasksToQueue(aTasksToReinsert)

	for _, tTask in ipairs(aTasksToReinsert) do
		VUHDO_heapInsert(VUHDO_TASK_PRIORITY_QUEUE, tTask, VUHDO_TASK_QUEUE_MAP);
	end

	return;

end



--
local tSuccess;
local tIterationCount;
local tTotalTasksProcessed;
local tCurrentTask;
local tTasksProcessedThisIteration;
local tCombatSafeTasks;
local tCombatUnsafeTasks;
function VUHDO_processCombatUnsafeTasksBeforeLockdown()

	if not VUHDO_CONFIG["USE_DEFERRED_REDRAW"] then
		return;
	end

	tTotalTasksProcessed = 0;
	tIterationCount = 0;

	repeat
		tTasksProcessedThisIteration = 0;
		tCombatSafeTasks = { };
		tCombatUnsafeTasks = { };

		while #VUHDO_TASK_PRIORITY_QUEUE > 0 do
			tCurrentTask = VUHDO_heapExtractTop(VUHDO_TASK_PRIORITY_QUEUE, VUHDO_TASK_QUEUE_MAP);

			if VUHDO_COMBAT_UNSAFE_TASKS[tCurrentTask["type"]] then
				tinsert(tCombatUnsafeTasks, tCurrentTask);
			else
				tinsert(tCombatSafeTasks, tCurrentTask);
			end
		end

		for _, tTask in ipairs(tCombatUnsafeTasks) do
			tSuccess, _ = VUHDO_executeSingleTask(tTask);

			if tSuccess then
				tTasksProcessedThisIteration = tTasksProcessedThisIteration + 1;
				tTotalTasksProcessed = tTotalTasksProcessed + 1;
			end

			VUHDO_DEFERRED_TASK_POOL:release(tTask);
		end

		for _, tTask in ipairs(tCombatSafeTasks) do
			VUHDO_heapInsert(VUHDO_TASK_PRIORITY_QUEUE, tTask, VUHDO_TASK_QUEUE_MAP);
		end

		tIterationCount = tIterationCount + 1;
		VUHDO_checkAllSemaphoreTimeouts();

	until tTasksProcessedThisIteration == 0 or tIterationCount > 10;

	if VUHDO_DEFERRED_TASK_PROFILING_ENABLED then
		VUHDO_Msg("WARNING: Processed " .. tTotalTasksProcessed .. " combat-unsafe tasks in " .. tIterationCount .. " iterations before combat lockdown.");
	end

	if tTotalTasksProcessed > 0 then
		VUHDO_DEFERRED_TASK_STATE["metrics"]["unsafeTasksProcessed"] = (VUHDO_DEFERRED_TASK_STATE["metrics"]["unsafeTasksProcessed"] or 0) + tTotalTasksProcessed;
	end

	return;

end



--
local tTaskTypeCount;
local tTasksToReinsert;
function VUHDO_initTaskSystem()

	if not VUHDO_DEFERRED_TASK_STATE["isInit"] then
		sDeferredTaskDelegates = {
			[VUHDO_DEFER_UPDATE_HEALTH] = _G["VUHDO_updateHealth"],
			[VUHDO_DEFER_UPDATE_HEALTH_BARS_FOR] = _G["VUHDO_updateHealthBarsFor"],
			[VUHDO_DEFER_SET_HEALTH] = _G["VUHDO_setHealth"],
			[VUHDO_DEFER_UPDATE_SHIELD_BAR] = _G["VUHDO_updateShieldBar"],
			[VUHDO_DEFER_UPDATE_HEAL_ABSORB_BAR] = _G["VUHDO_updateHealAbsorbBar"],
			[VUHDO_DEFER_UPDATE_MANA_BARS] = _G["VUHDO_updateManaBars"],
			[VUHDO_DEFER_UPDATE_UNIT_HOTS] = _G["VUHDO_updateUnitHoTs"],
			[VUHDO_DEFER_INIT_ALL_EVENT_BOUQUETS] = _G["VUHDO_deferInitAllEventBouquetsDelegate"],
			[VUHDO_DEFER_UPDATE_BOUQUETS_FOR_EVENT] = _G["VUHDO_updateBouquetsForEvent"],
			[VUHDO_DEFER_UPDATE_UNIT_CYCLIC_BOUQUET] = _G["VUHDO_updateUnitCyclicBouquet"],
			[VUHDO_DEFER_UPDATE_UNIT_DEBUFF_ICONS] = _G["VUHDO_updateUnitDebuffIcons"],
			[VUHDO_DEFER_UPDATE_UNIT_AGGRO] = _G["VUHDO_updateUnitAggro"],
			[VUHDO_DEFER_UPDATE_UNIT_RANGE] = _G["VUHDO_updateUnitRange"],
			[VUHDO_DEFER_UPDATE_ALL_CLUSTERS] = _G["VUHDO_updateAllClusters"],
			[VUHDO_DEFER_UPDATE_CLUSTER_HIGHLIGHTS] = _G["VUHDO_updateClusterHighlights"],
			[VUHDO_DEFER_AOE_UPDATE_ALL] = _G["VUHDO_aoeUpdateAll"],
			[VUHDO_DEFER_UPDATE_SPELL_TRACE] = _G["VUHDO_updateSpellTrace"],
			[VUHDO_DEFER_UPDATE_ALL_RAID_BARS] = _G["VUHDO_deferUpdateAllRaidBarsDelegate"],
			[VUHDO_DEFER_UPDATE_PANEL_BUTTONS] = _G["VUHDO_updatePanelButtons"],
			[VUHDO_DEFER_HANDLE_SCALE_CHANGE] = _G["VUHDO_handleScaleChange"],
			[VUHDO_DEFER_INIT_HEAL_BUTTON] = _G["VUHDO_deferInitHealButtonDelegate"],
			[VUHDO_DEFER_POSITION_HEAL_BUTTON] = _G["VUHDO_deferPositionHealButtonDelegate"],
			[VUHDO_DEFER_REDRAW_PANEL_COMPLETE] = _G["VUHDO_deferRedrawPanelCompleteDelegate"],
			[VUHDO_DEFER_INIT_ALL_HEAL_BUTTONS_COMPLETE] = _G["VUHDO_deferInitAllHealButtonsCompleteDelegate"],
			[VUHDO_DEFER_POSITION_CONFIG_PANELS] = _G["VUHDO_deferPositionConfigPanelsDelegate"],
			[VUHDO_DEFER_REDRAW_PANEL] = _G["VUHDO_deferRedrawPanelDelegate"],
			[VUHDO_DEFER_REDRAW_ALL_PANELS_COMPLETE] = _G["VUHDO_deferRedrawAllPanelsCompleteDelegate"],
		};

		tTaskTypeCount = 0;

		if VUHDO_DEFERRED_TASK_TYPES then
			tTaskTypeCount = #VUHDO_DEFERRED_TASK_TYPES;
		end

		VUHDO_DEFERRED_TASK_STATE["invocationCountByType"] = tcreate(0, tTaskTypeCount);
		VUHDO_DEFERRED_TASK_STATE["avgCostUsByType"] = tcreate(0, tTaskTypeCount);

		VUHDO_DEFERRED_TASK_STATE["costHistoryByType"] = { };
		VUHDO_DEFERRED_TASK_STATE["individualCostsByType"] = { };
		VUHDO_DEFERRED_TASK_STATE["costPredictionAccuracy"] = { };

		VUHDO_resetDeferredTaskMetrics();

		VUHDO_DEFERRED_TASK_POOL = VUHDO_createTablePool(
			"DeferredTask",
			VUHDO_DEFERRED_TASK_POOL_MAX_SIZE,
			VUHDO_createDeferredTaskDelegate,
			VUHDO_cleanupDeferredTaskDelegate
		);

		tTasksToReinsert = VUHDO_extractAllTasksFromQueue();

		for _, tTask in ipairs(tTasksToReinsert) do
			VUHDO_DEFERRED_TASK_POOL:release(tTask);
		end

		sNextTaskEnqueueOrder = 0;

		VUHDO_DEFERRED_TASK_STATE["lastAdjustTime"] = GetTime();
		VUHDO_DEFERRED_TASK_STATE["maxTasksPerFrame"] = VUHDO_DEFERRED_TASK_CONFIG["MAX_TASKS_PER_FRAME"];

		VUHDO_DEFERRED_TASK_STATE["isInit"] = true;
	end

	return;

end