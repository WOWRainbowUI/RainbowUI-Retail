
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
		if ActionBarActionEventsFrame then
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
		end
	end)

	if ActionButton_ApplyCooldown then -- Action Buttons no longer use CooldownFrame_Set
		hooksecurefunc("ActionButton_ApplyCooldown", function(normalCooldown, cooldownInfo, chargeCooldown, chargeInfo, lossOfControlCooldown, lossOfControlInfo)
			if normalCooldown and not normalCooldown:IsForbidden() then
				normalCooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
			end
			if chargeCooldown and not chargeCooldown:IsForbidden() then
				chargeCooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
			end
			if lossOfControlCooldown and not lossOfControlCooldown:IsForbidden() then
				lossOfControlCooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
			end
		end)
	end
	if CooldownFrame_Set then
		hooksecurefunc("CooldownFrame_Set", function(self)
			if self and not self:IsForbidden() then
				self:SetEdgeTexture("Interface\\Cooldown\\edge")
			end
		end)
	end
