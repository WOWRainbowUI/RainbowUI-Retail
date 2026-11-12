local LootProfiler = {}
LootProfiler.__index = LootProfiler

local PHASES = { "handler", "metadata", "count", "display" }
local CAPTURE_SECONDS = 30
local MAX_EVENTS = 2000

local function Pack(...)
	return { n = select("#", ...), ... }
end

function LootProfiler:New(config)
	return setmetatable({ config = config, generation = 0 }, self)
end

function LootProfiler:Start()
	local config = self.config
	if type(config.getMilliseconds) ~= "function"
		or type(config.getTime) ~= "function"
		or type(config.after) ~= "function" then
		config.print("Loot profiling is unavailable on this client.")
		return false
	end
	local stats = {}
	for _, phase in ipairs(PHASES) do
		stats[phase] = { calls = 0, total = 0, maximum = 0, errors = 0 }
	end
	self.capture = { started = config.getTime(), stats = stats }
	self.generation = self.generation + 1
	local generation = self.generation
	config.after(CAPTURE_SECONDS, function()
		if self.generation == generation and self.capture then self:Stop() end
	end)
	config.print("Loot profile started: spam-loot for up to 30 seconds. "
		.. "Use /msbt lootprofile stop to report early (limit: 2000 events).")
	return true
end

function LootProfiler:Stop()
	local capture = self.capture
	if not capture then
		self.config.print("No loot capture is active. Use /msbt lootprofile.")
		return false
	end
	self.capture = nil
	local elapsed = math.max(0, self.config.getTime() - capture.started)
	local context = self.config.getContext and self.config.getContext() or ""
	self.config.print(string.format("Loot profile: %d loot events in %.1fs; %s",
		capture.stats.handler.calls, elapsed, context))
	for _, phase in ipairs(PHASES) do
		local stats = capture.stats[phase]
		local average = stats.calls > 0 and stats.total / stats.calls or 0
		self.config.print(string.format(
			"%s: calls=%d total=%.3fms avg=%.3fms max=%.3fms errors=%d",
			phase, stats.calls, stats.total, average, stats.maximum, stats.errors))
	end
	return true
end

function LootProfiler:Measure(phase, callback, ...)
	local capture = self.capture
	if not capture then return callback(...) end
	local started = self.config.getMilliseconds()
	local results = Pack(pcall(callback, ...))
	local elapsed = math.max(0, self.config.getMilliseconds() - started)
	-- A callback may stop or replace the capture; never write to that session.
	if self.capture == capture then
		local stats = capture.stats[phase]
		stats.calls = stats.calls + 1
		stats.total = stats.total + elapsed
		stats.maximum = math.max(stats.maximum, elapsed)
		if not results[1] then stats.errors = stats.errors + 1 end
		if phase == "handler" and stats.calls >= MAX_EVENTS then self:Stop() end
	end
	if not results[1] then error(results[2], 0) end
	return unpack(results, 2, results.n)
end

MikSBT.Components.LootProfiler = LootProfiler
return LootProfiler
