local _;

local floor = math.floor;
local tsort = table.sort;
local twipe = table.wipe;

VUHDO_TAIL_MEAN_KEYS = { "tm50", "tm80", "tm90", "tm99", "tm100" };



--
local tRemainingMass;
local tSortedIndex;
local tWeightedSum;
local function VUHDO_computeUpperTailMean(aSortedValues, aSortedCount, aTailMass)

	if aSortedCount <= 0 or aTailMass <= 0 then
		return 0;
	end

	if aTailMass < 1 then
		return aSortedValues[aSortedCount];
	end

	tRemainingMass = aTailMass;
	tWeightedSum = 0;
	tSortedIndex = aSortedCount;

	while tRemainingMass > 0 and tSortedIndex >= 1 do
		if tRemainingMass >= 1 then
			tWeightedSum = tWeightedSum + aSortedValues[tSortedIndex];
			tRemainingMass = tRemainingMass - 1;
			tSortedIndex = tSortedIndex - 1;
		else
			tWeightedSum = tWeightedSum + tRemainingMass * aSortedValues[tSortedIndex];
			tRemainingMass = 0;
		end
	end

	return tWeightedSum / aTailMass;

end



--
local tTailPercentiles;
local tBufferSize;
local tTailMeanTracker;
local tTailPercentile;
local tTailMeanKey;
function VUHDO_createTailMeanTracker(aBufferSize, aTailPercentiles)

	if not aBufferSize then
		tBufferSize = 1000;
	else
		tBufferSize = aBufferSize;
	end

	if not aTailPercentiles then
		tTailPercentiles = { 0.5, 0.8, 0.9, 0.99, 1.0 };
	else
		tTailPercentiles = aTailPercentiles;
	end

	tTailMeanTracker = {
		["tailPercentiles"] = tTailPercentiles,
		["buffer"] = { },
		["bufferSize"] = tBufferSize,
		["nextIndex"] = 1,
		["isFull"] = false,
		["maxValue"] = 0,
		["totalCount"] = 0,
		["cumulativeTotal"] = 0,
		["sortedValues"] = { },
		["isDirty"] = true,
		["tailMeans"] = { },
		["tailMeanKeys"] = { },
	};

	for tIndex = 1, #tTailPercentiles do
		tTailPercentile = tTailPercentiles[tIndex];
		tTailMeanKey = "tm" .. floor(tTailPercentile * 100);

		tTailMeanTracker["tailMeanKeys"][tIndex] = tTailMeanKey;
		tTailMeanTracker["tailMeans"][tTailMeanKey] = 0;
	end



	--
	function tTailMeanTracker:update(aValue)

		self["buffer"][self["nextIndex"]] = aValue;
		self["nextIndex"] = self["nextIndex"] + 1;

		if self["nextIndex"] > self["bufferSize"] then
			self["nextIndex"] = 1;
			self["isFull"] = true;
		end

		self["cumulativeTotal"] = self["cumulativeTotal"] + aValue;

		if aValue > self["maxValue"] then
			self["maxValue"] = aValue;
		end

		self["totalCount"] = self["totalCount"] + 1;
		self["isDirty"] = true;

		return;

	end



	--
	local tSortedCount;
	local tTailMass;
	local tTailMeanKey;
	local tTailPercentile;
	function tTailMeanTracker:getTailMeans()

		if not self["isDirty"] then
			return self["tailMeans"];
		end

		if self["totalCount"] == 0 then
			for tIndex = 1, #self["tailPercentiles"] do
				tTailMeanKey = self["tailMeanKeys"][tIndex];
				self["tailMeans"][tTailMeanKey] = 0;
			end

			self["isDirty"] = false;

			return self["tailMeans"];
		end

		tSortedCount = self["isFull"] and self["bufferSize"] or (self["nextIndex"] - 1);

		twipe(self["sortedValues"]);

		for tIndex = 1, tSortedCount do
			self["sortedValues"][tIndex] = self["buffer"][tIndex];
		end

		tsort(self["sortedValues"]);

		for tIndex = 1, #self["tailPercentiles"] do
			tTailPercentile = self["tailPercentiles"][tIndex];
			tTailMeanKey = self["tailMeanKeys"][tIndex];

			if tTailPercentile >= 1.0 then
				self["tailMeans"][tTailMeanKey] = self["maxValue"];
			else
				tTailMass = (1 - tTailPercentile) * tSortedCount;

				self["tailMeans"][tTailMeanKey] = VUHDO_computeUpperTailMean(self["sortedValues"], tSortedCount, tTailMass);
			end
		end

		self["isDirty"] = false;

		return self["tailMeans"];

	end



	--
	function tTailMeanTracker:getCumulativeTotal()

		return self["cumulativeTotal"];

	end



	--
	local tTailMeanKey;
	function tTailMeanTracker:reset()

		for tIndex = 1, self["bufferSize"] do
			self["buffer"][tIndex] = nil;
		end

		self["nextIndex"] = 1;
		self["isFull"] = false;
		self["maxValue"] = 0;
		self["totalCount"] = 0;
		self["cumulativeTotal"] = 0;
		self["isDirty"] = true;

		for tIndex = 1, #self["tailPercentiles"] do
			tTailMeanKey = self["tailMeanKeys"][tIndex];
			self["tailMeans"][tTailMeanKey] = 0;
		end

		return;

	end



	--
	function tTailMeanTracker:isInitialized()

		return self["totalCount"] > 0;

	end

	return tTailMeanTracker;

end