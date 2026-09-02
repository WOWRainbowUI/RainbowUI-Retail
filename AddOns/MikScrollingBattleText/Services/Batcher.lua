local Batcher = {
	config = {},
}

function Batcher:Configure(config)
	self.config = config
end

local function CanMerge(unmergedEvent, mergedEvent)
	if unmergedEvent.eventType ~= mergedEvent.eventType then
		return false
	end
	if not unmergedEvent.effectName then
		return unmergedEvent.name ~= nil
			and unmergedEvent.name == mergedEvent.name
	end

	return unmergedEvent.effectName == mergedEvent.effectName
end

function Batcher:MergeEvent(unmergedEvent, mergedEvent)
	if unmergedEvent.effectName then
		if unmergedEvent.name ~= mergedEvent.name then
			mergedEvent.name = self.config.multipleTargets
		end
		if unmergedEvent.class ~= mergedEvent.class then
			mergedEvent.class = nil
		end
	end

	mergedEvent.partialEffects = nil
	unmergedEvent.eventMerged = true
	if unmergedEvent.amount then
		mergedEvent.amount = (mergedEvent.amount or 0) + unmergedEvent.amount
	end
	if unmergedEvent.overhealAmount then
		mergedEvent.overhealAmount = (mergedEvent.overhealAmount or 0)
			+ unmergedEvent.overhealAmount
	end

	mergedEvent.numMerged = mergedEvent.numMerged + 1
	if unmergedEvent.isCrit then
		mergedEvent.numCrits = mergedEvent.numCrits + 1
	else
		mergedEvent.isCrit = false
	end
end

function Batcher:AddMergeTrailer(mergedEvent)
	if mergedEvent.numMerged <= 0 then
		return
	end

	local critTrailer = ""
	if mergedEvent.numCrits > 0 then
		local critLabel = mergedEvent.numCrits == 1
			and self.config.crit or self.config.crits
		critTrailer = string.format(
			", %d %s",
			mergedEvent.numCrits,
			critLabel
		)
	end

	mergedEvent.mergeTrailer = string.format(
		" [%d %s%s]",
		mergedEvent.numMerged + 1,
		self.config.hits,
		critTrailer
	)
end

function Batcher:Merge(unmergedEvents, mergedEvents, options)
	for _, unmergedEvent in ipairs(unmergedEvents) do
		local wasMerged = false
		for _, mergedEvent in ipairs(mergedEvents) do
			if CanMerge(unmergedEvent, mergedEvent) then
				self:MergeEvent(unmergedEvent, mergedEvent)
				wasMerged = true
				break
			end
		end

		if not wasMerged then
			unmergedEvent.numMerged = 0
			unmergedEvent.numCrits = unmergedEvent.isCrit and 1 or 0
			mergedEvents[#mergedEvents + 1] = unmergedEvent
		end
	end

	if not options.hideTrailer then
		for _, mergedEvent in ipairs(mergedEvents) do
			self:AddMergeTrailer(mergedEvent)
		end
	end

	while #unmergedEvents > 0 do
		local event = table.remove(unmergedEvents, 1)
		if event.eventMerged then
			self.config.erase(event)
			local recycle = options.recycle or self.config.recycle
			recycle(event)
		end
	end
end

MikSBT.Services = MikSBT.Services or {}
MikSBT.Services.Batcher = Batcher

return Batcher
