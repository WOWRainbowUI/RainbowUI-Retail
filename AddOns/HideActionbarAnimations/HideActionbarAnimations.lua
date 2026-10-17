
	if not (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or WOW_PROJECT_ID == WOW_PROJECT_CAMELOT) then return end

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
		AfterAddOnHasLoadedFrame:SetScript("OnEvent", function(self)
			if ActionBarActionEventsFrame then
				for _, event in ipairs(ActionBarAnimationEvents) do
					ActionBarActionEventsFrame:UnregisterEvent(event)
				end
			end
		end)

	if not (WOW_PROJECT_ID == WOW_PROJECT_CAMELOT) then return end -- Forever specific fix for mousing over an active cast, might come to Retail later

		local function HideActionButtonCast(self)
			if not (self.SpellCastAnimFrame and self.SpellCastAnimFrame.Fill and self.SpellCastAnimFrame.Fill.CastingAnim) then 
				return 
			end
			if self.SpellCastAnimFrame.Fill.CastingAnim:IsPlaying() then
				self.SpellCastAnimFrame.Fill.CastingAnim:Stop()
				self.SpellCastAnimFrame.Fill:Hide()
				self.SpellCastAnimFrame:Hide()
			end
		end

		local function StyleButton(button)
			if not button then return end

			HideActionButtonCast(button) -- Hide initial cast (/reload when channeling for example)
			if type(button.PlaySpellCastAnim) == "function" then
				hooksecurefunc(button, "PlaySpellCastAnim", function(self)
					HideActionButtonCast(self)
				end)
			end
		end

		local barPrefixes = {
			"ActionButton",
			"MultiBarBottomLeftButton",
			"MultiBarBottomRightButton",
			"MultiBarLeftButton",
			"MultiBarRightButton",
			"MultiBar5Button",
			"MultiBar6Button",
			"MultiBar7Button",
			"OverrideActionBarButton",
			--"StanceButton",
			--"PetActionButton",
			--"PossessButton",
		}

		for _, prefix in ipairs(barPrefixes) do
			for i = 1, 12 do
				StyleButton(_G[prefix .. i])
			end
		end

		StyleButton(ExtraActionButton1)
