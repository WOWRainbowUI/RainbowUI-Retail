
	-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_ActionBar/Mainline/ActionButtonTemplate.xml#L47
	-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_ActionBar/Mainline/ActionButton.lua

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
		"UNIT_SPELLCAST_SENT",
	}

	local AfterAddOnHasLoadedFrame = CreateFrame("Frame")
	AfterAddOnHasLoadedFrame:RegisterEvent("PLAYER_LOGIN")
	AfterAddOnHasLoadedFrame:SetScript("OnEvent", function(self, event, ...)
		for _, events in ipairs(ActionBarAnimationEvents) do
			ActionBarActionEventsFrame:UnregisterEvent(events)
		end

		ActionBarActionEventsFrame:HookScript("OnEvent", function(self, event, ...)
			if self.IsSpellcastEvent and self:IsSpellcastEvent(event) then
				for _, events in ipairs(ActionBarAnimationEvents) do
					self:UnregisterEvent(events)
				end
			end
		end)
	end)

	hooksecurefunc("CooldownFrame_Set", function(self)
		if not self:IsForbidden() then
			self:SetEdgeTexture("Interface\\Cooldown\\edge")
		end
	end)