-- function for the texts --
local function VCBtexts(var1)
	var1:SetFontObject("GameFontHighlightSmall")
	var1:SetHeight(PlayerCastingBarFrame.Text:GetHeight())
	var1:Hide()
end
-- Name Text --
local VCBnameText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBnameText)
-- Current Time Text --
local VCBcurrentTimeText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBcurrentTimeText)
-- Total Time Text --
local VCBtotalTimeText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBtotalTimeText)
-- Both Time Text --
local VCBbothTimeText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBbothTimeText)
-- Copy Texture of Spell's Icon --
local VCBiconSpell = PlayerCastingBarFrame:CreateTexture(nil, "ARTWORK", nil, 0)
VCBiconSpell:SetPoint("LEFT", PlayerCastingBarFrame, "RIGHT", 2, -4)
VCBiconSpell:SetWidth(PlayerCastingBarFrame.Icon:GetWidth())
VCBiconSpell:SetHeight(PlayerCastingBarFrame.Icon:GetHeight())
VCBiconSpell:SetScale(1.3)
VCBiconSpell:Hide()
-- Texture of Spell's Shield Left --
local VCBshieldSpellLeft = PlayerCastingBarFrame:CreateTexture(nil, "ARTWORK", nil, 0)
VCBshieldSpellLeft:SetAtlas("UI-CastingBar-Shield")
VCBshieldSpellLeft:SetPoint("TOPLEFT", PlayerCastingBarFrame.Icon, "TOPLEFT", -6, 6)
VCBshieldSpellLeft:SetPoint("BOTTOMRIGHT", PlayerCastingBarFrame.Icon, "BOTTOMRIGHT", 6, -12)
VCBshieldSpellLeft:SetBlendMode("BLEND")
VCBshieldSpellLeft:SetAlpha(0.85)
VCBshieldSpellLeft:Hide()
-- Texture of Spell's Shield Right --
local VCBshieldSpellRight = PlayerCastingBarFrame:CreateTexture(nil, "ARTWORK", nil, 0)
VCBshieldSpellRight:SetAtlas("UI-CastingBar-Shield")
VCBshieldSpellRight:SetPoint("TOPLEFT", VCBiconSpell, "TOPLEFT", -6, 6)
VCBshieldSpellRight:SetPoint("BOTTOMRIGHT", VCBiconSpell, "BOTTOMRIGHT", 6, -12)
VCBshieldSpellRight:SetBlendMode("BLEND")
VCBshieldSpellRight:SetAlpha(0.85)
VCBshieldSpellRight:Hide()
-- Position of the Name Text --
local function NameTextPosition(self, var1, var2)
	if VCBrPlayer[var1] == "Top Left" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "Left" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "Bottom Left" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "Top" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "Center" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "Bottom" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "Top Right" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "Right" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "Bottom Right" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1] == "Hide" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Position of the Casting Texts --
local function CastingTextPosition(self, var1, var2)
	if VCBrPlayer[var1]["Position"] == "Top Left" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "Left" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "Bottom Left" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "Top" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "Center" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "Bottom" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "Top Right" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "Right" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "Bottom Right" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrPlayer[var1]["Position"] == "Hide" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Ascending, Descending and Sec --
local function AscendingDescendingSec(self)
	if self.casting then
		if VCBrPlayer["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrPlayer["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.2f sec", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f sec", VCBdescending)
				end
			elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrPlayer["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.1f sec", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.1f sec", VCBdescending)
				end
			elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrPlayer["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.0f sec", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f sec", VCBdescending)
				end
			elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrPlayer["BothTimeText"]["Decimals"] == 2 then
			if VCBrPlayer["BothTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrPlayer["BothTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Decimals"] == 1 then
			if VCBrPlayer["BothTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrPlayer["BothTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Decimals"] == 0 then
			if VCBrPlayer["BothTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrPlayer["BothTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	elseif self.channeling then
		if VCBrPlayer["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrPlayer["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.2f sec", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f sec", VCBdescending)
				end
			elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrPlayer["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.1f sec", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.1f sec", VCBdescending)
				end
			elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrPlayer["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.0f sec", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f sec", VCBdescending)
				end
			elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["CurrentTimeText"]["Direction"] == "Descending" or VCBrPlayer["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
				elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrPlayer["BothTimeText"]["Decimals"] == 2 then
			if VCBrPlayer["BothTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Descending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrPlayer["BothTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Descending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Decimals"] == 1 then
			if VCBrPlayer["BothTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Descending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrPlayer["BothTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Descending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Decimals"] == 0 then
			if VCBrPlayer["BothTimeText"]["Sec"] == "Show" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Descending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrPlayer["BothTimeText"]["Sec"] == "Hide" then
				if VCBrPlayer["BothTimeText"]["Direction"] == "Descending" or VCBrPlayer["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrPlayer["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	end
end
-- coloring the bar --
local function CastBarColor(self)
	if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
		if VCBrPlayer["Color"] == "Default Color" then
			self:SetStatusBarDesaturated(false)
			self:SetStatusBarColor(1, 1, 1, 1)
		elseif VCBrPlayer["Color"] == "Class' Color" then
			self:SetStatusBarDesaturated(true)
			self:SetStatusBarColor(vcbClassColorPlayer:GetRGB())
		elseif VCBrPlayer["Color"] == "Spell School Color" then
			self:SetStatusBarDesaturated(true)
			if self.barType == "uninterruptable" then self:SetStatusBarTexture("UI-CastingBar-Full-Standard") end
			if vcbSpellSchool == 1 then
				self:SetStatusBarColor(vcbPhysicalColor:GetRGB())
			elseif vcbSpellSchool == 2 then
				self:SetStatusBarColor(vcbHolyColor:GetRGB())
			elseif vcbSpellSchool == 4 then
				self:SetStatusBarColor(vcbFireColor:GetRGB())
			elseif vcbSpellSchool == 8 then
				self:SetStatusBarColor(vcbNatureColor:GetRGB())
			elseif vcbSpellSchool == 16 then
				self:SetStatusBarColor(vcbFrostColor:GetRGB())
			elseif vcbSpellSchool == 32 then
				self:SetStatusBarColor(vcbShadowColor:GetRGB())
			elseif vcbSpellSchool == 64 then
				self:SetStatusBarColor(vcbArcaneColor:GetRGB())
			elseif vcbSpellSchool == 3 then
				self:SetStatusBarColor(vcbHolystrikeColor:GetRGB())
			elseif vcbSpellSchool == 5 then
				self:SetStatusBarColor(vcbFlamestrikeColor:GetRGB())
			elseif vcbSpellSchool == 6 then
				self:SetStatusBarColor(vcbRadiantColor:GetRGB())
			elseif vcbSpellSchool == 9 then
				self:SetStatusBarColor(vcbStormstrikeColor:GetRGB())
			elseif vcbSpellSchool == 10 then
				self:SetStatusBarColor(vcbHolystormColor:GetRGB())
			elseif vcbSpellSchool == 12 then
				self:SetStatusBarColor(vcbVolcanicColor:GetRGB())
			elseif vcbSpellSchool == 17 then
				self:SetStatusBarColor(vcbFroststrikeColor:GetRGB())
			elseif vcbSpellSchool == 18 then
				self:SetStatusBarColor(vcbHolyfrostColor:GetRGB())
			elseif vcbSpellSchool == 20 then
				self:SetStatusBarColor(vcbFrostfireColor:GetRGB())
			elseif vcbSpellSchool == 24 then
				self:SetStatusBarColor(vcbFroststormColor:GetRGB())
			elseif vcbSpellSchool == 33 then
				self:SetStatusBarColor(vcbShadowstrikeColor:GetRGB())
			elseif vcbSpellSchool == 34 then
				self:SetStatusBarColor(vcbTwilightColor:GetRGB())
			elseif vcbSpellSchool == 36 then
				self:SetStatusBarColor(vcbShadowflameColor:GetRGB())
			elseif vcbSpellSchool == 40 then
				self:SetStatusBarColor(vcbPlagueColor:GetRGB())
			elseif vcbSpellSchool == 48 then
				self:SetStatusBarColor(vcbShadowfrostColor:GetRGB())
			elseif vcbSpellSchool == 65 then
				self:SetStatusBarColor(vcbSpellstrikeColor:GetRGB())
			elseif vcbSpellSchool == 66 then
				self:SetStatusBarColor(vcbDivineColor:GetRGB())
			elseif vcbSpellSchool == 68 then
				self:SetStatusBarColor(vcbSpellfireColor:GetRGB())
			elseif vcbSpellSchool == 72 then
				self:SetStatusBarColor(vcbAstralColor:GetRGB())
			elseif vcbSpellSchool == 80 then
				self:SetStatusBarColor(vcbSpellfrostColor:GetRGB())
			elseif vcbSpellSchool == 96 then
				self:SetStatusBarColor(vcbSpellshadowColor:GetRGB())
			elseif vcbSpellSchool == 28 then
				self:SetStatusBarColor(vcbElementalColor:GetRGB())
			elseif vcbSpellSchool == 62 then
				self:SetStatusBarColor(vcbChromaticColor:GetRGB())
			elseif vcbSpellSchool == 106 then
				self:SetStatusBarColor(vcbCosmicColor:GetRGB())
			elseif vcbSpellSchool == 126 then
				self:SetStatusBarColor(vcbMagicColor:GetRGB())
			elseif vcbSpellSchool == 127 or vcbSpellSchool == 124 then
				self:SetStatusBarColor(vcbChaosColor:GetRGB())
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	else
		self:SetStatusBarDesaturated(false)
		self:SetStatusBarColor(1, 1, 1, 1)
	end
end
-- Hooking Time part 1 --
PlayerCastingBarFrame:HookScript("OnShow", function(self)
	if VCBrPlayer["Icon"] == "Left" then
		if not self.Icon:IsShown() then self.Icon:Show() end
		if self.barType == "uninterruptable" then
			if not VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Show() end
		else
			if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
		end
		if VCBiconSpell:IsShown() then VCBiconSpell:Hide() end
		if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
	elseif VCBrPlayer["Icon"] == "Right" then
		if not VCBiconSpell:IsShown() then VCBiconSpell:Show() end
		VCBiconSpell:SetTexture(PlayerCastingBarFrame.Icon:GetTextureFileID())
		if self.barType == "uninterruptable" then
			if not VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Show() end
		else
			if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
		end
		if self.Icon:IsShown() then self.Icon:Hide() end
		if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
	elseif VCBrPlayer["Icon"] == "Left and Right" then
		if not self.Icon:IsShown() then self.Icon:Show() end
		if not VCBiconSpell:IsShown() then VCBiconSpell:Show() end
		VCBiconSpell:SetTexture(PlayerCastingBarFrame.Icon:GetTextureFileID())
		if self.barType == "uninterruptable" then
			if not VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Show() end
			if not VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Show() end
		else
			if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
			if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
		end
	elseif VCBrPlayer["Icon"] == "Hide" then
		if self.Icon:IsShown() then self.Icon:Hide() end
		if VCBiconSpell:IsShown() then VCBiconSpell:Hide() end
		if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
		if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
	end
	NameTextPosition(self, "NameText", VCBnameText)
	CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeText)
	CastingTextPosition(self, "BothTimeText", VCBbothTimeText)
	CastingTextPosition(self, "TotalTimeText", VCBtotalTimeText)
end)
-- Hooking Time part 2 --
PlayerCastingBarFrame:HookScript("OnUpdate", function(self)
	self.Text:SetAlpha(0)
	CastBarColor(self)
	AscendingDescendingSec(self)
	if VCBrPlayer["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
		if VCBrPlayer["TotalTimeText"]["Decimals"] == 2 then
			VCBtotalTimeText:SetFormattedText("%.2f sec", self.maxValue)
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 1 then
			VCBtotalTimeText:SetFormattedText("%.1f sec", self.maxValue)
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 0 then
			VCBtotalTimeText:SetFormattedText("%.0f sec", self.maxValue)
		end
	elseif VCBrPlayer["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
		if VCBrPlayer["TotalTimeText"]["Decimals"] == 2 then
			VCBtotalTimeText:SetFormattedText("%.2f", self.maxValue)
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 1 then
			VCBtotalTimeText:SetFormattedText("%.1f", self.maxValue)
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 0 then
			VCBtotalTimeText:SetFormattedText("%.0f", self.maxValue)
		end
	end
	VCBnameText:SetText(self.Text:GetText())
	if VCBrPlayer["Ticks"] == "Show" then vcbShowTicks(VCBarg3)
	else vcbHideTicks()
	end
end)
