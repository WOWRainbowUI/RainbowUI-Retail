local _;

local floor = math.floor;
local ceil = math.ceil;
local tsort = table.sort;



--
local tPercentiles;
local tBufferSize;
local tPercentileTracker;
local tPercentile;
local tKey;
function VUHDO_createPercentileTracker(aBufferSize, aPercentiles)

	if not aBufferSize then
		tBufferSize = 1000;
	else
		tBufferSize = aBufferSize;
	end

	if not aPercentiles then
		tPercentiles = { 0.5, 0.8, 0.9, 0.99, 1.0 };
	else
		tPercentiles = aPercentiles;
	end

	tPercentileTracker = {
		["percentiles"] = tPercentiles,
		["buffer"] = { },
		["bufferSize"] = tBufferSize,
		["nextIndex"] = 1,
		["isFull"] = false,
		["maxValue"] = 0,
		["totalCount"] = 0,
		["cumulativeTotal"] = 0,
		["sorted"] = nil,
		["lastSortCount"] = 0,
		["sortThreshold"] = 100,
		["resultCache"] = { },
	};

	for tIndex = 1, #tPercentiles do
		tPercentile = tPercentiles[tIndex];
		tKey = "tm" .. floor(tPercentile * 100);

		tPercentileTracker["resultCache"][tIndex] = tKey;
	end

	local tOldValue;
	local tWillOverwrite;
	function tPercentileTracker:update(aValue)

		tOldValue = 0;
		tWillOverwrite = self["isFull"];

		if tWillOverwrite then
			tOldValue = self["buffer"][self["nextIndex"]] or 0;
		end

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

		if self["totalCount"] - self["lastSortCount"] >= self["sortThreshold"] then
			self["sorted"] = nil;
		end

		return;

	end

	local tResult;
	local tPercentile;
	local tPosition;
	local tFloorPos;
	local tCeilPos;
	local tValue;
	local tWeight;
	local tValue1;
	local tValue2;
	local tCount;
	local tSortedCount;
	local tCachedKey;
	function tPercentileTracker:getPercentiles()

		tResult = { };

		if self["totalCount"] == 0 then
			for tIndex = 1, #self["percentiles"] do
				tCachedKey = self["resultCache"][tIndex];
				tResult[tCachedKey] = 0;
			end

			return tResult;
		end

		if not self["sorted"] then
			self["sorted"] = { };

			tCount = self["isFull"] and self["bufferSize"] or (self["nextIndex"] - 1);

			for tIndex = 1, tCount do
				self["sorted"][tIndex] = self["buffer"][tIndex];
			end

			tsort(self["sorted"]);

			self["lastSortCount"] = self["totalCount"];
		end

		tSortedCount = #self["sorted"];

		for tIndex = 1, #self["percentiles"] do
			tPercentile = self["percentiles"][tIndex];
			tPosition = tPercentile * tSortedCount;

			tFloorPos = floor(tPosition);
			tCeilPos = ceil(tPosition);

			if tFloorPos <= 0 then
				tValue = self["sorted"][1];
			elseif tCeilPos > tSortedCount then
				tValue = self["sorted"][tSortedCount];
			elseif tFloorPos == tCeilPos then
				tValue = self["sorted"][tFloorPos];
			else
				tValue1 = self["sorted"][tFloorPos];
				tValue2 = self["sorted"][tCeilPos];
				tWeight = tPosition - tFloorPos;

				tValue = tValue1 + (tValue2 - tValue1) * tWeight;
			end

			tCachedKey = self["resultCache"][tIndex];
			tResult[tCachedKey] = tValue;
		end

		for tIndex = 1, #self["percentiles"] do
			if self["percentiles"][tIndex] == 1.0 then
				tResult["tm100"] = self["maxValue"];
				break;
			end
		end

		return tResult;

	end

	function tPercentileTracker:getCumulativeTotal()

		return self["cumulativeTotal"];

	end

	local tPercentileDecimal;
	local tAllPercentiles;
	local tClosestKey;
	local tClosestDiff;
	local tKeyPercentile;
	local tDiff;
	function tPercentileTracker:getPercentile(aPercentile)

		tPercentileDecimal = aPercentile / 100;

		tAllPercentiles = self:getPercentiles();

		tClosestKey = nil;
		tClosestDiff = math.huge;

		for tKey, tValue in pairs(tAllPercentiles) do
			if string.sub(tKey, 1, 2) == "tm" then
				tKeyPercentile = tonumber(string.sub(tKey, 3)) / 100;
				tDiff = math.abs(tKeyPercentile - tPercentileDecimal);

				if tDiff < tClosestDiff then
					tClosestDiff = tDiff;
					tClosestKey = tKey;
				end
			end
		end

		return tAllPercentiles[tClosestKey] or 0;

	end

	function tPercentileTracker:reset()

		for tIndex = 1, self["bufferSize"] do
			self["buffer"][tIndex] = nil;
		end

		self["nextIndex"] = 1;
		self["isFull"] = false;
		self["maxValue"] = 0;
		self["totalCount"] = 0;
		self["cumulativeTotal"] = 0;
		self["sorted"] = nil;
		self["lastSortCount"] = 0;

		return;

	end

	function tPercentileTracker:isInitialized()

		return self["totalCount"] > 0;

	end

	return tPercentileTracker;

end



--
function VUHDO_sortPercentileKeys(aPercentileKeys)

	table.sort(aPercentileKeys, function(a, b)
		local aPercentile = tonumber(string.sub(a, 3)) or 0;
		local bPercentile = tonumber(string.sub(b, 3)) or 0;

		return aPercentile < bPercentile;
	end);

	return;

end
