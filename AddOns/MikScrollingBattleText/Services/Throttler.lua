local Throttler = {
	config = {},
	windows = {},
}

function Throttler:Configure(config)
	self.config = config
end

function Throttler:Queue(key, event, duration, now)
	local window = self.windows[key]
	if not window then
		window = {
			remaining = 0,
			lastEventTime = 0,
			events = {},
		}
		self.windows[key] = window
	end

	if window.remaining > 0 then
		window.lastEventTime = now
		window.events[#window.events + 1] = event
		return true, false
	end

	window.remaining = duration
	if now - window.lastEventTime < duration then
		window.lastEventTime = now
		window.events[#window.events + 1] = event
		return true, true
	end

	return false, true
end

function Throttler:Tick(elapsed)
	local hasActiveWindow = false
	local releasedEvents = false

	for _, window in pairs(self.windows) do
		if window.remaining > 0 then
			window.remaining = window.remaining - elapsed
			if window.remaining > 0 then
				hasActiveWindow = true
			elseif #window.events > 0 then
				for index = 1, #window.events do
					self.config.release(window.events[index])
					window.events[index] = nil
				end
				releasedEvents = true
			end
		end
	end

	return hasActiveWindow, releasedEvents
end

MikSBT.Services = MikSBT.Services or {}
MikSBT.Services.Throttler = Throttler

return Throttler
