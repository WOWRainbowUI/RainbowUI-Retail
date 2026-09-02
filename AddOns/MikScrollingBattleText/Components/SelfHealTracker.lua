local SelfHealTracker = {}
SelfHealTracker.__index = SelfHealTracker

function SelfHealTracker:New(config)
	return setmetatable({
		config = config,
		entries = {},
	}, self)
end

function SelfHealTracker:Reset()
	for index = #self.entries, 1, -1 do
		self.entries[index] = nil
	end
end

function SelfHealTracker:RemoveExpired(now)
	local cutoff = now - self.config.matchWindow
	for index = #self.entries, 1, -1 do
		if self.entries[index].time < cutoff then
			table.remove(self.entries, index)
		end
	end
end

function SelfHealTracker:Record(amount)
	if not amount or amount <= 0 then
		return
	end

	local now = self.config.getTime()
	self:RemoveExpired(now)
	self.entries[#self.entries + 1] = {
		amount = amount,
		time = now,
	}
end

function SelfHealTracker:Consume(amount)
	if not amount or amount <= 0 then
		return false
	end

	self:RemoveExpired(self.config.getTime())
	for index = #self.entries, 1, -1 do
		local entry = self.entries[index]
		if math.abs(entry.amount - amount) <= self.config.tolerance then
			table.remove(self.entries, index)
			return true
		end
	end

	return false
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.SelfHealTracker = SelfHealTracker

return SelfHealTracker
