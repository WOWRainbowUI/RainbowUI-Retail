local ScrollAreas = {
	config = {},
	areas = {},
	names = {},
}
local PET_MERGE_TARGETS = {
	OutgoingPet = "Outgoing",
	IncomingPet = "Incoming",
}

local function Clear(values)
	for key in pairs(values) do
		values[key] = nil
	end
end

function ScrollAreas:Configure(config)
	self.config = config
end

function ScrollAreas:Update()
	Clear(self.areas)
	Clear(self.names)

	local profile = self.config.getProfile()
	local profileAreas = profile and rawget(profile, "scrollAreas")
	if profileAreas then
		for key, settings in pairs(profileAreas) do
			self.areas[key] = settings
			self.names[key] = settings.name
		end
	end

	local masterProfile = self.config.getMasterProfile()
	for key, settings in pairs(masterProfile.scrollAreas) do
		if not self.areas[key] then
			self.areas[key] = settings
			self.names[key] = settings.name
		end
	end
end

function ScrollAreas:GetPetMergeTarget(areaKey)
	return PET_MERGE_TARGETS[areaKey]
end

function ScrollAreas:Resolve(identifier)
	local areaKey = identifier
	local settings = self.areas[identifier]
	if not settings then
		for key, areaName in pairs(self.names) do
			if identifier == areaName then
				areaKey = key
				settings = self.areas[key]
				break
			end
		end
	end

	if settings and settings.disabled and settings.mergeWhenDisabled == true then
		local target = PET_MERGE_TARGETS[areaKey]
		if target then
			settings = self.areas[target] or settings
		end
	end

	return settings or self.areas[self.config.defaultArea]
end

function ScrollAreas:ResolveKey(settings)
	for key, areaSettings in pairs(self.areas) do
		if areaSettings == settings then
			return key
		end
	end

	return self.config.defaultArea
end

function ScrollAreas:IsActive(identifier)
	local settings = self:Resolve(identifier)
	return settings ~= nil and not settings.disabled
end

function ScrollAreas:IsIconShown(identifier)
	local settings = self:Resolve(identifier)
	return settings ~= nil and not settings.skillIconsDisabled
end

function ScrollAreas:Iterate()
	return pairs(self.names)
end

MikSBT.Display = MikSBT.Display or {}
MikSBT.Display.ScrollAreas = ScrollAreas

return ScrollAreas
