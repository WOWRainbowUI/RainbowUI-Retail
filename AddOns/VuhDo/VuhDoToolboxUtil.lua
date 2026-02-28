local _;

local tinsert = tinsert;
local tremove = tremove;
local twipe = table.wipe;
local pairs = pairs;
local ipairs = ipairs;
local format = format;
local max = max;
local strlen = strlen;
local unpack = unpack;
local select = select;
local tostring = tostring;
local type = type;
local strsub = string.sub;
local random = math.random;

local GetTime = GetTime;
local InCombatLockdown = InCombatLockdown;

local sHexChars = "0123456789abcdef";



--
function VUHDO_tableCreate(...)

	local tTable = { };

	return tTable;

end
local tcreate = table.create or VUHDO_tableCreate;



--
local tId;
local tRandom;
local tChar;
function VUHDO_generateUUID(aPrefix, aLength)

	aLength = aLength or 12;
	tId = aPrefix or "";

	for tCnt = 1, aLength do
		tRandom = random(1, 16);

		tChar = strsub(sHexChars, tRandom, tRandom);

		tId = tId .. tChar;
	end

	return tId;

end



--
local tCnt;
local tStringChar;
local tPrefixChar;
local tSubstring;
local tPrefixSuffix;
local tStringSuffix;
local function VUHDO_radixTreePrefixSubstring(aPrefix, aString)

	if not aPrefix or not aString then
		return;
	end

	tCnt = 1;

	while tCnt <= strlen(aString) do
		tStringChar = string.sub(aString, tCnt, tCnt);
		tPrefixChar = string.sub(aPrefix, tCnt, tCnt);

		if tStringChar ~= tPrefixChar then
			break;
		end

		tCnt = tCnt + 1;
	end

	if tCnt > 1 then
		tSubstring = string.sub(aPrefix, 1, tCnt - 1);

		tPrefixSuffix = string.sub(aPrefix, tCnt, strlen(aPrefix));
		tStringSuffix = string.sub(aString, tCnt, strlen(aString));

		return tSubstring, tPrefixSuffix, tStringSuffix;
	else
		return nil, nil, nil;
	end

end



--
function VUHDO_radixTreeCreate()

	local tRootNode = {
		["prefix"] = "",
		["isLeaf"] = true,
		["children"] = { },
	};

	return tRootNode;

end



--
local tChar;
local tFound;
local tNode;
local tSubstringChar;
local tNodeTemp;
function VUHDO_radixTreeAdd(aTree, aString)

	if not aTree or not aString then
		return;
	end

	if aTree["prefix"] == aString and not aTree["isLeaf"] then
		aTree["isLeaf"] = true;
	else
		tChar = string.sub(aString, 1, 1);

		tFound = false;
		for tChildChar, _ in pairs(aTree["children"]) do
			if tChildChar == tChar then
				tFound = true;
			end
		end

		if tChar and not tFound then
			aTree["children"][tChar] = {
				["prefix"] = aString,
				["isLeaf"] = true,
				["children"] = { },
			};
		elseif tChar then
			tNode = aTree["children"][tChar];

			tSubstring, tPrefixSuffix, tStringSuffix = VUHDO_radixTreePrefixSubstring(tNode["prefix"], aString);
			tSubstringChar = string.sub(tSubstring, 1, 1);

			if tSubstringChar and VUHDO_strempty(tPrefixSuffix) then
				VUHDO_radixTreeAdd(aTree["children"][tSubstringChar], tStringSuffix);
			elseif tSubstringChar then
				tNode["prefix"] = tPrefixSuffix;

				tNodeTemp = aTree["children"][tSubstringChar];

				aTree["children"][tSubstringChar] = {
					["prefix"] = tSubstring,
					["isLeaf"] = false,
					["children"] = {
						[tPrefixSuffix] = {
							["prefix"] = tNodeTemp["prefix"],
							["isLeaf"] = tNodeTemp["isLeaf"],
							["children"] = tNodeTemp["children"],
						},
					},
				};

				if VUHDO_strempty(tStringSuffix) then
					aTree["children"][tSubstringChar]["isLeaf"] = true;
				else
					VUHDO_radixTreeAdd(aTree["children"][tSubstringChar], tStringSuffix);
				end
			end
		end
	end

end



--
function VUHDO_radixTreeAddAll(aTree, ...)

	if not aTree then
		return;
	end

	for _, tString in pairs({ ... }) do
		VUHDO_radixTreeAdd(aTree, tString);
	end

end



--
function VUHDO_radixTreeContains(aTree, aString)

	if not aTree or not aString then
		return;
	end

	tChar = string.sub(aString, 1, 1);

	if tChar then
		tNode = aTree["children"][tChar];

		if not tNode then
			return false;
		else
			tSubstring, tPrefixSuffix, tStringSuffix = VUHDO_radixTreePrefixSubstring(tNode["prefix"], aString);

			if not VUHDO_strempty(tPrefixSuffix) then
				return false;
			elseif VUHDO_strempty(tStringSuffix) then
				return tNode["isLeaf"];
			else
				return VUHDO_radixTreeContains(tNode, tStringSuffix);
			end
		end
	else
		return false;
	end

end



--
local tTokens;
local function VUHDO_tokenizeByWord(aString)

	if not aString then
		return;
	end

	tTokens = { };

	-- first try to split on camel case
	for tWord in string.gmatch(aString, "%u%U*") do
		tinsert(tTokens, tWord);
	end

	-- fallback to split on whitespace
	if #tTokens < 1 then
		for tWord in string.gmatch(aString, "%S+") do
			tinsert(tTokens, tWord);
		end
	end

	return tTokens;

end



--
local tNGrams;
local function VUHDO_tokenizeByNGram(aString, aLength)

	if not aString or not aLength then
		return;
	end

	tNGrams = { };

	if aLength > #aString then
		tinsert(tNGrams, aString);

		return tNGrams;
	end

	for tCnt = 1, strlen(aString) - aLength + 1 do
		tinsert(tNGrams, string.sub(aString, tCnt, tCnt + aLength - 1));
	end

	return tNGrams;

end



--
local tTriGramIndex;
local tTriGramCnt;
function VUHDO_createTriGramIndex(aString)

	if not aString then
		return;
	end

	tTriGramIndex = { };
	tTriGramCnt = 0;

	for _, tWord in pairs(VUHDO_tokenizeByWord(aString)) do
		for _, tGram in pairs(VUHDO_tokenizeByNGram(tWord, 3)) do
			tTriGramIndex[tGram] = true;

			tTriGramCnt = tTriGramCnt + 1;
		end
	end

	return tTriGramIndex, tTriGramCnt;

end



--
local tIsMatch;
function VUHDO_matchTriGramIndices(aTriGramIndexOne, aTriGramIndexTwo)

	if not aTriGramIndexOne or not aTriGramIndexTwo then
		return;
	end

	tIsMatch = false;

	-- return true if the first tri gram index contains the second
	for tGram in pairs(aTriGramIndexTwo) do
		if aTriGramIndexOne[tGram] then
			tIsMatch = true;
		else
			tIsMatch = false;

			break;
		end
	end

	return tIsMatch;

end



--
function VUHDO_matchTriGramIndex(aTriGramIndex, aString)

	if not aTriGramIndex or not aString then
		return;
	end

	return VUHDO_matchTriGramIndices(aTriGramIndex, VUHDO_createTriGramIndex(aString));

end



--
local VUHDO_REGISTERED_TABLE_POOLS = { };



--
function VUHDO_cleanupListNodeDelegate(aNode)

	aNode["auraInstanceId"] = nil;
	aNode["prev"] = nil;

	return;

end



--
local tNode;
function VUHDO_createListNodeDelegate()

	tNode = tcreate(0, 2);

	tNode["auraInstanceId"] = nil;
	tNode["prev"] = nil;

	return tNode;

end



--
local VUHDO_TABLE_POOL_PROFILING_ENABLED = false;
local VUHDO_DEFAULT_MAX_POOL_SIZE = 200;
local tMaxPoolSize;
local tPool;
function VUHDO_createTablePool(aPoolName, aMaxPoolSize, aCreateDelegate, aCleanupDelegate)

	tMaxPoolSize = aMaxPoolSize or VUHDO_DEFAULT_MAX_POOL_SIZE;

	tPool = {
		["poolData"] = tcreate(tMaxPoolSize),
		["maxSize"] = tMaxPoolSize,
		["createDelegate"] = aCreateDelegate or function() return { }; end,
		["cleanupDelegate"] = aCleanupDelegate,
		["_twipe"] = twipe,
		["metrics"] = {
			["hits"] = 0,
			["misses"] = 0,
			["peakIdleCount"] = 0,
			["rejectedReleases"] = 0,
		},
	};

	local tIsProfile;
	local tMetrics;
	local tPoolSize;
	local tObject;
	function tPool:get()

		tIsProfile = VUHDO_TABLE_POOL_PROFILING_ENABLED;

		if tIsProfile then
			tMetrics = self["metrics"];
		end

		tPoolSize = #self["poolData"];

		if tPoolSize > 0 then
			tObject = self["poolData"][tPoolSize];
			self["poolData"][tPoolSize] = nil;

			if tIsProfile then
				tMetrics["hits"] = tMetrics["hits"] + 1;
			end

			return tObject;
		else
			if tIsProfile then
				tMetrics["misses"] = tMetrics["misses"] + 1;
			end

			return self["createDelegate"]();
		end

	end

	local tIsProfile;
	local tMetrics;
	local tPoolSize;
	function tPool:release(aObject)

		tIsProfile = VUHDO_TABLE_POOL_PROFILING_ENABLED;

		if tIsProfile then
			tMetrics = self["metrics"];
		end

		tPoolSize = #self["poolData"];

		if aObject and tPoolSize < self["maxSize"] then
			if self["cleanupDelegate"] then
				self["cleanupDelegate"](aObject);
			else
				self["_twipe"](aObject);
			end

			tinsert(self["poolData"], aObject);

			if tIsProfile then
				tMetrics["peakIdleCount"] = max(tMetrics["peakIdleCount"], tPoolSize + 1);
			end
		elseif aObject and tIsProfile then
			tMetrics["rejectedReleases"] = tMetrics["rejectedReleases"] + 1;
		end

		return;

	end

	local tMetrics;
	local tIdleCount;
	function tPool:getMetrics()

		tMetrics = self["metrics"];
		tIdleCount = #self["poolData"];

		return {
			["hits"] = tMetrics["hits"],
			["misses"] = tMetrics["misses"],
			["peakIdleCount"] = tMetrics["peakIdleCount"],
			["rejectedReleases"] = tMetrics["rejectedReleases"],
			["currentIdle"] = tIdleCount,
			["maxSize"] = self["maxSize"],
		};

	end

	local tMetrics;
	function tPool:resetMetrics()

		tMetrics = self["metrics"];

		tMetrics["hits"] = 0;
		tMetrics["misses"] = 0;
		tMetrics["peakIdleCount"] = #self["poolData"];
		tMetrics["rejectedReleases"] = 0;

		return;

	end

	if type(aPoolName) == "string" and aPoolName ~= "" then
		VUHDO_REGISTERED_TABLE_POOLS[aPoolName] = tPool;
	else
		VUHDO_Msg("Warning: An unnamed table pool was created.");
	end

	return tPool;

end



--
local function VUHDO_getTablePools()

	return VUHDO_REGISTERED_TABLE_POOLS;

end



--
local tPoolStats;
function VUHDO_printPoolMetrics()

	if not VUHDO_TABLE_POOL_PROFILING_ENABLED then
		VUHDO_Msg("Table pool profiling is currently disabled.");
		return;
	end

	VUHDO_Msg("|cffFFD100--- Table Pool Metrics ---|r");

	for tName, tPool in pairs(VUHDO_getTablePools()) do
		if tPool and tPool.getMetrics then
			tPoolStats = tPool:getMetrics();

			VUHDO_Msg(string.format("|cffFFA500** Pool[%s]:|r (|cffB0E0E6Max:|r%d |cffB0E0E6CurIdle:|r%d |cffB0E0E6PeakIdle:|r%d): |cff98FB98Hits=|r%d |cff98FB98Misses=|r%d |cff98FB98Rejected=|r%d",
				tName,
				tPoolStats["maxSize"],
				tPoolStats["currentIdle"],
				tPoolStats["peakIdleCount"],
				tPoolStats["hits"],
				tPoolStats["misses"],
				tPoolStats["rejectedReleases"]
			));
		else
			VUHDO_Msg(string.format("|cffFFA500** Pool[%s]:|r Not available or invalid.", tName));
		end
	end

	VUHDO_Msg("|cffFFD100--- End of Metrics ---|r");

	return;

end



--
function VUHDO_resetPoolMetrics()

	for _, tPool in pairs(VUHDO_getTablePools()) do
		if tPool and tPool.resetMetrics then
			tPool:resetMetrics();
		end
	end

	if VUHDO_TABLE_POOL_PROFILE then
		VUHDO_Msg("Table pool metrics reset.");
	end

	return;

end



--
function VUHDO_setPoolProfiling(anIsEnabled)

	VUHDO_TABLE_POOL_PROFILING_ENABLED = anIsEnabled;

	if anIsEnabled then
		VUHDO_Msg("Table pool profiling is enabled.");
	else
		VUHDO_Msg("Table pool profiling is disabled.");
	end

	return;

end



--
function VUHDO_formatTime(aTimeUs)

	aTimeUs = aTimeUs or 0;

	if aTimeUs >= 1000 then
		return format("%.2f ms", aTimeUs / 1000);
	end

	return format("%.0f us", aTimeUs);

end



--
local VUHDO_REGISTERED_SEMAPHORES = { };
local VUHDO_SEMAPHORE_PROFILING_ENABLED = false;
local VUHDO_SEMAPHORE_DEFAULT_TIMEOUT_MS = 250;
local sSemaphoreId = 0;



--
local tSemaphore;
function VUHDO_createSemaphore(aSemaphoreName, aInitialCount, aMaxCount, aTimeoutMs)

	if not aSemaphoreName then
		sSemaphoreId = sSemaphoreId + 1;
		aSemaphoreName = "semaphore_" .. sSemaphoreId;
	end

	tSemaphore = {
		["name"] = aSemaphoreName,
		["count"] = aInitialCount or 0,
		["maxCount"] = aMaxCount or 999999,
		["timeoutMs"] = aTimeoutMs or VUHDO_SEMAPHORE_DEFAULT_TIMEOUT_MS,
		["waitingTasks"] = { },
		["metrics"] = {
			["increments"] = 0,
			["decrements"] = 0,
			["timeouts"] = 0,
			["peakWaitCount"] = 0,
		},
	};

	local tIsProfile;
	local tMetrics;
	function tSemaphore:increment()

		tIsProfile = VUHDO_SEMAPHORE_PROFILING_ENABLED;

		if tIsProfile then
			tMetrics = self["metrics"];
			tMetrics["increments"] = tMetrics["increments"] + 1;
		end

		if self["count"] < self["maxCount"] then
			self["count"] = self["count"] + 1;

			return true;
		end

		return false;

	end

	local tIsProfile;
	local tMetrics;
	local tTask;
	local tAllDependenciesZero;
	local tTasksToProcess;
	local tIndex;
	local tShouldProcess;
	local tShouldMigrate;
	local tMigrateToSemaphore;
	function tSemaphore:decrement()

		tIsProfile = VUHDO_SEMAPHORE_PROFILING_ENABLED;

		if tIsProfile then
			tMetrics = self["metrics"];
			tMetrics["decrements"] = tMetrics["decrements"] + 1;
		end

		if self["count"] > 0 then
			self["count"] = self["count"] - 1;

			if self["count"] == 0 then
				tTasksToProcess = { };
				tIndex = 1;

				while tIndex <= #self["waitingTasks"] do
					tTask = self["waitingTasks"][tIndex];

					tShouldProcess = false;
					tShouldMigrate = false;
					tMigrateToSemaphore = nil;

					if tTask["allDependencies"] then
						tAllDependenciesZero = true;
						tMigrateToSemaphore = nil;

						for _, tDependency in ipairs(tTask["allDependencies"]) do
							if tDependency and tDependency["count"] > 0 then
								tAllDependenciesZero = false;

								if not tMigrateToSemaphore then
									tMigrateToSemaphore = tDependency;
								end
							end
						end

						if tAllDependenciesZero then
							tShouldProcess = true;
						else
							tShouldMigrate = true;
						end
					else
						tShouldProcess = true;
					end

					if tShouldProcess then
						tremove(self["waitingTasks"], tIndex);

						tinsert(tTasksToProcess, tTask);
					elseif tShouldMigrate and tMigrateToSemaphore then
						tremove(self["waitingTasks"], tIndex);

						tinsert(tMigrateToSemaphore["waitingTasks"], tTask);
					else
						tIndex = tIndex + 1;
					end
				end

				for _, tTask in ipairs(tTasksToProcess) do
					VUHDO_deferTask(tTask["type"], tTask["priority"], unpack(tTask["args"]));
				end
			end
		end

		return true;

	end

	local tIsProfile;
	local tMetrics;
	local tTaskKey;
	function tSemaphore:waitFor(aTaskType, aPriority, ...)

		if not self then
			return true;
		end

		tIsProfile = VUHDO_SEMAPHORE_PROFILING_ENABLED;

		if tIsProfile then
			tMetrics = self["metrics"];

			tMetrics["peakWaitCount"] = max(tMetrics["peakWaitCount"], #self["waitingTasks"] + 1);
		end

		if self["count"] == 0 then
			return true;
		end

		tTaskKey = tostring(aTaskType);

		for i = 1, select("#", ...) do
			tTaskKey = tTaskKey .. "|" .. tostring(select(i, ...) or "");
		end

		for _, tExistingTask in ipairs(self["waitingTasks"]) do
			if tExistingTask["taskKey"] == tTaskKey then
				return false;
			end
		end

		tinsert(self["waitingTasks"], {
			["type"] = aTaskType,
			["priority"] = aPriority,
			["args"] = { ... },
			["startTime"] = GetTime() * 1000,
			["timeoutTime"] = GetTime() * 1000 + self["timeoutMs"],
			["taskKey"] = tTaskKey,
		});

		return false;

	end

	local tIsProfile;
	local tMetrics;
	local tOrphanedIncrements;
	function tSemaphore:validateAndRecoverState(aTimedOutCount)

		tIsProfile = VUHDO_SEMAPHORE_PROFILING_ENABLED;

		if tIsProfile then
			tMetrics = self["metrics"];
		end

		if #self["waitingTasks"] == 0 then
			if self["count"] > 0 then
				tOrphanedIncrements = self["count"];
				self["count"] = 0;

				if tIsProfile then
					tMetrics["decrements"] = tMetrics["decrements"] + tOrphanedIncrements;
				end
			end
		end

		return;

	end

	local tCurrentTime;
	local tIsProfile;
	local tMetrics;
	local tTask;
	local tTimedOutCount;
	function tSemaphore:checkTimeouts()

		tCurrentTime = GetTime() * 1000;
		tIsProfile = VUHDO_SEMAPHORE_PROFILING_ENABLED;
		tTimedOutCount = 0;

		if tIsProfile then
			tMetrics = self["metrics"];
		end

		for tIndex = #self["waitingTasks"], 1, -1 do
			tTask = self["waitingTasks"][tIndex];

			if tCurrentTime >= tTask["timeoutTime"] then
				tTimedOutCount = tTimedOutCount + 1;

				if VUHDO_SEMAPHORE_PROFILING_ENABLED then
					tMetrics = self["metrics"];
					tMetrics["timeouts"] = tMetrics["timeouts"] + 1;
				end

				table.remove(self["waitingTasks"], tIndex);
			end
		end

		if tTimedOutCount > 0 then
			self:validateAndRecoverState(tTimedOutCount);
		end

		return;

	end

	local tMetrics;
	function tSemaphore:getMetrics()

		tMetrics = self["metrics"];

		return {
			["increments"] = tMetrics["increments"],
			["decrements"] = tMetrics["decrements"],
			["timeouts"] = tMetrics["timeouts"],
			["peakWaitCount"] = tMetrics["peakWaitCount"],
			["currentCount"] = self["count"],
			["maxCount"] = self["maxCount"],
			["waitingCount"] = #self["waitingTasks"],
			["timeoutMs"] = self["timeoutMs"],
		};

	end

	local tMetrics;
	function tSemaphore:resetMetrics()

		tMetrics = self["metrics"];

		tMetrics["increments"] = 0;
		tMetrics["decrements"] = 0;
		tMetrics["timeouts"] = 0;
		tMetrics["peakWaitCount"] = 0;

		return;

	end

	VUHDO_REGISTERED_SEMAPHORES[aSemaphoreName] = tSemaphore;

	return tSemaphore;

end



--
function VUHDO_getSemaphore(aSemaphoreName)

	return VUHDO_REGISTERED_SEMAPHORES[aSemaphoreName];

end



--
function VUHDO_getSemaphores()

	return VUHDO_REGISTERED_SEMAPHORES;

end



--
function VUHDO_checkAllSemaphoreTimeouts()

	for tSemaphoreName, tSemaphore in pairs(VUHDO_REGISTERED_SEMAPHORES) do
		tSemaphore:checkTimeouts();
	end

	return;

end



--
local tAllZero;
local tTaskKey;
local tAlreadyWaiting;
local tFirstNonZeroSemaphore;
local tMaxTimeout;
function VUHDO_waitForSemaphores(aSemaphores, aTaskType, aPriority, ...)

	if not aSemaphores or #aSemaphores == 0 then
		return true;
	end

	tAllZero = true;
	tFirstNonZeroSemaphore = nil;
	tMaxTimeout = 0;

	for _, tSemaphore in ipairs(aSemaphores) do
		if tSemaphore and tSemaphore["count"] > 0 then
			tAllZero = false;

			if not tFirstNonZeroSemaphore then
				tFirstNonZeroSemaphore = tSemaphore;
			end

			tMaxTimeout = max(tMaxTimeout, tSemaphore["timeoutMs"]);
		end
	end

	if tAllZero then
		return true;
	end

	tTaskKey = tostring(aTaskType);

	for i = 1, select("#", ...) do
		tTaskKey = tTaskKey .. "|" .. tostring(select(i, ...) or "");
	end

	tAlreadyWaiting = false;

	for _, tSemaphore in ipairs(aSemaphores) do
		if tSemaphore then
			for _, tWaitingTask in ipairs(tSemaphore["waitingTasks"]) do
				if tWaitingTask["taskKey"] == tTaskKey then
					tAlreadyWaiting = true;

					break;
				end
			end

			if tAlreadyWaiting then
				break;
			end
		end
	end

	if not tAlreadyWaiting and tFirstNonZeroSemaphore then
		tinsert(tFirstNonZeroSemaphore["waitingTasks"], {
			["type"] = aTaskType,
			["priority"] = aPriority,
			["args"] = { ... },
			["startTime"] = GetTime() * 1000,
			["timeoutTime"] = GetTime() * 1000 + tMaxTimeout,
			["taskKey"] = tTaskKey,
			["allDependencies"] = aSemaphores,
		});
	end

	return false;

end



--
local tInconsistentSemaphores = { };
function VUHDO_validateAllSemaphoreStates()

	twipe(tInconsistentSemaphores);

	for _, tSemaphore in ipairs(VUHDO_REGISTERED_SEMAPHORES) do
		if tSemaphore["count"] > 0 and #tSemaphore["waitingTasks"] == 0 then
			table.insert(tInconsistentSemaphores, tSemaphore);
		end
	end

	return tInconsistentSemaphores;

end



--
local tMetrics;
local tRecoveredCount;
function VUHDO_recoverOrphanedSemaphores()

	tRecoveredCount = 0;

	for tSemaphoreName, tSemaphore in pairs(VUHDO_REGISTERED_SEMAPHORES) do
		if tSemaphore and #tSemaphore["waitingTasks"] == 0 and tSemaphore["count"] > 0 then
			if VUHDO_SEMAPHORE_PROFILING_ENABLED then
				tMetrics = tSemaphore["metrics"];
				tMetrics["decrements"] = tMetrics["decrements"] + tSemaphore["count"];
			end

			tSemaphore["count"] = 0;
			tRecoveredCount = tRecoveredCount + 1;
		end
	end

	if tRecoveredCount > 0 and VUHDO_SEMAPHORE_PROFILING_ENABLED then
		VUHDO_Msg("Recovered " .. tostring(tRecoveredCount) .. " orphaned semaphores.");
	end

	return tRecoveredCount;

end



--
local tMetrics;
local tInconsistentSemaphores;
local tAggregatedMetrics;
local tPrefix;
local tAggData;
function VUHDO_printSemaphoreMetrics()

	if not VUHDO_SEMAPHORE_PROFILING_ENABLED then
		VUHDO_Msg("Semaphore profiling is currently disabled.");

		return;
	end

	VUHDO_Msg("|cffFFD100--- Semaphore Metrics (Aggregated by Prefix) ---|r");

	tAggregatedMetrics = { };

	for tSemaphoreName, tSemaphore in pairs(VUHDO_REGISTERED_SEMAPHORES) do
		tMetrics = tSemaphore:getMetrics();
		tPrefix = VUHDO_extractSemaphorePrefix(tSemaphoreName);

		if not tAggregatedMetrics[tPrefix] then
			tAggregatedMetrics[tPrefix] = {
				["instances"] = 0,
				["totalIncrements"] = 0,
				["totalDecrements"] = 0,
				["totalTimeouts"] = 0,
				["maxPeakWaitCount"] = 0,
				["totalCurrentCount"] = 0,
				["totalWaitingCount"] = 0,
				["maxTimeout"] = 0,
				["activeInstances"] = 0,
			};
		end

		tAggData = tAggregatedMetrics[tPrefix];
		tAggData["instances"] = tAggData["instances"] + 1;
		tAggData["totalIncrements"] = tAggData["totalIncrements"] + tMetrics["increments"];
		tAggData["totalDecrements"] = tAggData["totalDecrements"] + tMetrics["decrements"];
		tAggData["totalTimeouts"] = tAggData["totalTimeouts"] + tMetrics["timeouts"];
		tAggData["maxPeakWaitCount"] = max(tAggData["maxPeakWaitCount"], tMetrics["peakWaitCount"]);
		tAggData["totalCurrentCount"] = tAggData["totalCurrentCount"] + tMetrics["currentCount"];
		tAggData["totalWaitingCount"] = tAggData["totalWaitingCount"] + tMetrics["waitingCount"];
		tAggData["maxTimeout"] = max(tAggData["maxTimeout"], tMetrics["timeoutMs"]);

		if tMetrics["currentCount"] > 0 or tMetrics["waitingCount"] > 0 then
			tAggData["activeInstances"] = tAggData["activeInstances"] + 1;
		end
	end

	for tPrefix, tAggData in pairs(tAggregatedMetrics) do
		VUHDO_Msg(format("|cffFFA500** %s:|r (|cffB0E0E6Instances:|r%d |cffB0E0E6Active:|r%d): |cff98FB98Inc=|r%d |cff98FB98Dec=|r%d |cff98FB98T=|r%d |cffB0E0E6CurCount=|r%d |cffB0E0E6Wait=|r%d |cffB0E0E6MaxPeakWait=|r%d |cffB0E0E6MaxTimeout=|r%dms",
			tPrefix,
			tAggData["instances"],
			tAggData["activeInstances"],
			tAggData["totalIncrements"],
			tAggData["totalDecrements"],
			tAggData["totalTimeouts"],
			tAggData["totalCurrentCount"],
			tAggData["totalWaitingCount"],
			tAggData["maxPeakWaitCount"],
			tAggData["maxTimeout"]));
	end

	tInconsistentSemaphores = VUHDO_validateAllSemaphoreStates();

	if #tInconsistentSemaphores > 0 then
		VUHDO_Msg("|cffFF0000** Inconsistent:|r " .. #tInconsistentSemaphores .. " orphaned increments");
	end

	VUHDO_Msg("|cffFFD100--- End of Metrics ---|r");

	return;

end



--
local tMetrics;
function VUHDO_printDetailedSemaphoreMetrics()

	if not VUHDO_SEMAPHORE_PROFILING_ENABLED then
		VUHDO_Msg("Semaphore profiling is currently disabled.");

		return;
	end

	VUHDO_Msg("|cffFFD100--- Detailed Semaphore Metrics (Individual Instances) ---|r");

	for tSemaphoreName, tSemaphore in pairs(VUHDO_REGISTERED_SEMAPHORES) do
		tMetrics = tSemaphore:getMetrics();

		VUHDO_Msg(format("|cffFFA500** %s:|r (|cffB0E0E6Cur:|r%d/%d |cffB0E0E6Peak:|r%d): |cff98FB98Inc=|r%d |cff98FB98Dec=|r%d |cff98FB98T=|r%d |cffB0E0E6Wait=|r%d |cffB0E0E6Timeout=|r%dms",
			tSemaphoreName,
			tMetrics["currentCount"],
			tMetrics["maxCount"],
			tMetrics["peakWaitCount"],
			tMetrics["increments"],
			tMetrics["decrements"],
			tMetrics["timeouts"],
			tMetrics["waitingCount"],
			tMetrics["timeoutMs"]));
	end

	VUHDO_Msg("|cffFFD100--- End of Detailed Metrics ---|r");

	return;

end



--
function VUHDO_resetSemaphoreMetrics()

	for _, tSemaphore in pairs(VUHDO_getSemaphores()) do
		if tSemaphore and tSemaphore.resetMetrics then
			tSemaphore:resetMetrics();
		end
	end

	if VUHDO_SEMAPHORE_PROFILING_ENABLED then
		VUHDO_Msg("Semaphore metrics reset.");
	end

	return;

end



--
function VUHDO_setSemaphoreProfiling(anIsEnabled)

	VUHDO_SEMAPHORE_PROFILING_ENABLED = anIsEnabled;

	if anIsEnabled then
		VUHDO_Msg("Semaphore profiling is enabled.");
	else
		VUHDO_Msg("Semaphore profiling is disabled.");
	end

	return;

end



--
function VUHDO_safeSetAttribute(aFrame, aAttribute, aValue)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		aFrame:SetAttribute(aAttribute, aValue);
	end

	return;

end



--
function VUHDO_safeSetFrameRef(aFrame, aRefName, aTargetFrame)

	if not aFrame then
		return;
	end

	if not InCombatLockdown() or (aFrame.IsProtected and not aFrame:IsProtected()) then
		if aFrame.SetFrameRef then
			aFrame:SetFrameRef(aRefName, aTargetFrame);
		end
	end

	return;

end



--
function VUHDO_safeWrapScript(aHeaderFrame, aButton, aScriptType, aScriptBody)

	if not aHeaderFrame or not aButton then
		return;
	end

	if not InCombatLockdown() or (aHeaderFrame.IsProtected and not aHeaderFrame:IsProtected()) then
		aHeaderFrame:WrapScript(aButton, aScriptType, aScriptBody);
	end

	return;

end



--
local tCycleId;
function VUHDO_extractCycleIdFromSemaphoreName(aSemaphoreName)

	if not aSemaphoreName then
		return nil;
	end

	tCycleId = string.match(aSemaphoreName, "_(%d+%.%d+_%d+)$");

	return tCycleId;

end



--
local tPrefix;
function VUHDO_extractSemaphorePrefix(aSemaphoreName)

	if not aSemaphoreName then
		return aSemaphoreName;
	end

	tPrefix = string.gsub(aSemaphoreName, "_(%d+%.%d+_%d+)$", "_");

	return tPrefix;

end



--
function VUHDO_generateCycleId(aCycleId, anIsFallback)

	if anIsFallback then
		return aCycleId or ("Unknown_" .. GetTime() .. "_" .. math.random(1000, 9999));
	else
		return GetTime() .. "_" .. math.random(1000, 9999);
	end

end