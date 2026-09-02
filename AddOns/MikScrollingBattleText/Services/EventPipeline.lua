local EventPipeline = {}
EventPipeline.__index = EventPipeline

function EventPipeline:New(config)
	return setmetatable({
		config = config,
		elapsed = 0,
		pending = {},
		merged = {},
		cache = {},
	}, self)
end

function EventPipeline:Acquire()
	return table.remove(self.cache) or {}
end

function EventPipeline:Recycle(event)
	self.config.erase(event)
	self.cache[#self.cache + 1] = event
end

function EventPipeline:Queue(event)
	self.pending[#self.pending + 1] = event
end

local function DisplayMergedEvent(self, event, profile)
	local eventKey = event.isCrit
		and event.eventType .. "_CRIT"
		or event.eventType
	local eventSettings = profile.events[eventKey]
	local hideSkills = event.effectTexture
		and not profile.exclusiveSkillsDisabled
		or profile.hideSkills
	local outputMessage = self.config.formatter:FormatLegacyEvent(
		eventSettings.message,
		event.amount,
		event.damageType,
		event.overhealAmount,
		event.overkillAmount,
		event.powerType,
		event.name,
		event.class,
		event.effectName,
		event.partialEffects,
		event.mergeTrailer,
		event.ignoreDamageColoring,
		hideSkills,
		profile.hideNames or event.hideNames,
		true
	)

	self.config.display(eventSettings, outputMessage, event.effectTexture)
end

function EventPipeline:Tick(elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed < self.config.delay then
		return #self.pending > 0
	end

	local profile = self.config.getProfile()
	self.config.batcher:Merge(self.pending, self.merged, {
		hideTrailer = profile.hideMergeTrailer,
	})

	for index, event in ipairs(self.merged) do
		DisplayMergedEvent(self, event, profile)
		self.merged[index] = nil
		self:Recycle(event)
	end

	self.elapsed = 0
	return #self.pending > 0
end

MikSBT.Services = MikSBT.Services or {}
MikSBT.Services.EventPipeline = EventPipeline

return EventPipeline
