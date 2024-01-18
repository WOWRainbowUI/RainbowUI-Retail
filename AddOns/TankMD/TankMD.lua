local _, addon = ...
local config = addon.config

local LGIST = LibStub("LibGroupInSpecT-1.1", true)

-- Create frame
local frame = CreateFrame("Frame")
addon.frame = frame
frame:SetScript("OnEvent", function(self, event)
	if config.queueEvents[event] then
		addon:QueueUpdate()
		addon:Update()
	elseif config.updateEvents[event] then
		addon:Update()
	end
end)

-- Register queue and update events
for event, _ in pairs(config.queueEvents) do
	frame:RegisterEvent(event)
end
for event, _ in pairs(config.updateEvents) do
	frame:RegisterEvent(event)
end

if LGIST then
	local inspectHandler = {}
	function inspectHandler:GroupInSpecT_Update(...)
		addon:QueueUpdate()
		addon:Update()
	end

	LGIST.RegisterCallback(inspectHandler, "GroupInSpecT_Update")
end

addon:CreateButtons()
