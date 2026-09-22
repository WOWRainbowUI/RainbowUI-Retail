
	local Version, _, _, tocVersion = GetBuildInfo()

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or (tocVersion >= 16000 and tocVersion < 17000) then -- Both Retail and Forever unregister properly

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

	end

	if (tocVersion >= 16000 and tocVersion < 17000) then -- Forever specific fix for mousing over an active cast, might come to Retail later

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
			if button.PlaySpellCastAnim then
				hooksecurefunc(button, "PlaySpellCastAnim", function(self)
					HideActionButtonCast(self)
				end)
			end
		end

		for i = 1, 12 do
			StyleButton(_G["ActionButton"..i])
			StyleButton(_G["MultiBarBottomLeftButton"..i])
			StyleButton(_G["MultiBarBottomRightButton"..i])
			StyleButton(_G["MultiBarLeftButton"..i])
			StyleButton(_G["MultiBarRightButton"..i])
			StyleButton(_G["MultiBar5Button"..i])
			StyleButton(_G["MultiBar6Button"..i])
			StyleButton(_G["MultiBar7Button"..i])
		end
		for i = 1, 6 do
			StyleButton(_G["OverrideActionBarButton"..i])
		end
		-- Don't think these are needed
		-- for i = 1, 10 do
			-- StyleButton(_G["StanceButton"..i])
			-- StyleButton(_G["PetActionButton"..i])
		-- end 
		-- for i = 1, 2 do 
			-- StyleButton(_G["PossessButton"..i])
		-- end
		StyleButton(ExtraActionButton1)

	end
