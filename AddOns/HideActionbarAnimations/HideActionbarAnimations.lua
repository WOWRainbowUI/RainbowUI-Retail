
local ActionBarAnimationEvents = {
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_RETICLE_TARGET",
    "UNIT_SPELLCAST_RETICLE_CLEAR",
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
}

-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/FrameXML/ActionButton.lua#L215

for _, events in ipairs(ActionBarAnimationEvents) do
    ActionBarActionEventsFrame:UnregisterEvent(events)
end

hooksecurefunc("CooldownFrame_Set", function(self)
	if not self:IsForbidden() then
		self:SetEdgeTexture("Interface\\Cooldown\\edge")
	end
end)