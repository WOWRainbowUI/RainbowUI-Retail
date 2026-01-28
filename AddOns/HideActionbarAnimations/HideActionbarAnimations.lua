
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

	local function ApplyEdgeTexture(frame)
		if frame and issecretvalue(frame) then return end
		if frame and not frame:IsForbidden() then
			if frame:GetObjectType() == "Cooldown" then
				if frame.SetEdgeTexture then
					frame:SetEdgeTexture("Interface\\Cooldown\\edge")
				end
			end
		end
	end
	if ActionButton_ApplyCooldown then -- Action Buttons no longer use CooldownFrame_Set
		hooksecurefunc("ActionButton_ApplyCooldown", function(normalCooldown, cooldownInfo, chargeCooldown, chargeInfo, lossOfControlCooldown, lossOfControlInfo)
			ApplyEdgeTexture(normalCooldown)
			ApplyEdgeTexture(chargeCooldown)
			ApplyEdgeTexture(lossOfControlCooldown)
		end)
	end
	if CooldownFrame_Set then
		hooksecurefunc("CooldownFrame_Set", function(self)
			ApplyEdgeTexture(self)
		end)
	end
