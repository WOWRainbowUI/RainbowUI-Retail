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
-- Some local variables --
local lagStart = 0
local lagEnd = 0
local lagTotal = 0
local statusMin = 0
local statusMax = 0
local lagWidth = 0
-- function for the lag bars --
local function VCBlagBars(var1)
	var1:SetTexture("Interface\\RAIDFRAME\\Raid-Bar-Hp-Fill")
	var1:SetHeight(PlayerCastingBarFrame:GetHeight())
	var1:SetVertexColor(1, 0, 0)
	var1:SetAlpha(0.75)
	var1:SetBlendMode("ADD")
	var1:Hide()
end
-- Lag Bar 1 --
local VCBlagBar1 = PlayerCastingBarFrame:CreateTexture(nil, "OVERLAY", nil, 7)
VCBlagBars(VCBlagBar1)
-- Lag Bar 2 --
local VCBlagBar2 = PlayerCastingBarFrame:CreateTexture(nil, "OVERLAY", nil, 7)
VCBlagBars(VCBlagBar2)
-- Player Casting Latency Bar --
local function PlayerCastLagBar(arg3)
	local playerSpell = IsPlayerSpell(arg3)
	if playerSpell and VCBrPlayer["LagBar"] == "Show" then
		lagEnd = GetTime()
		lagTotal = (lagEnd - lagStart)
		statusMin, statusMax = PlayerCastingBarFrame:GetMinMaxValues()
		lagWidth = lagTotal / (statusMax - statusMin)
		VCBlagBar1:ClearAllPoints()
		VCBlagBar1:SetWidth(PlayerCastingBarFrame:GetWidth() * lagWidth)
		VCBlagBar1:SetPoint("RIGHT", PlayerCastingBarFrame, "RIGHT", 0, 0)
		VCBlagBar1:Show()
	end
end
-- Player Channeling Latency Bar --
local function PlayerChannelLagBar(arg3)
	local playerSpell = IsPlayerSpell(arg3)
	if playerSpell and VCBrPlayer["LagBar"] == "Show" then
		lagEnd = GetTime()
		lagTotal = (lagEnd - lagStart)
		statusMin, statusMax = PlayerCastingBarFrame:GetMinMaxValues()
		lagWidth = lagTotal / (statusMax - statusMin)
		VCBlagBar2:ClearAllPoints()
		VCBlagBar2:SetWidth(PlayerCastingBarFrame:GetWidth() * lagWidth)
		VCBlagBar2:SetPoint("LEFT", PlayerCastingBarFrame, "LEFT", 0, 0)
		VCBlagBar2:Show()
	end
end
-- Creating the ticks for the player's castbar --
-- Create Ticks 3 --
local function Create3Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 3
	for i = 1, 3, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB3spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB3spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB3spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 4 --
local function Create4Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 4
	for i = 1, 4, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB4spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB4spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB4spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 5 --
local function Create5Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 5
	for i = 1, 5, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB5spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB5spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB5spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 6 --
local function Create6Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 6
	for i = 1, 6, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB6spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB6spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB6spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 7 --
local function Create7Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 7
	for i = 1, 7, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB7spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB7spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB7spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 8 --
local function Create8Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 8
	for i = 1, 8, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB8spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB8spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB8spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Show Ticks 3 --
local function Show3Ticks()
	for i = 1, 3, 1 do
		_G["VCB3spark".. i]:Show()
	end
end
-- Show Ticks 4 --
local function Show4Ticks()
	for i = 1, 4, 1 do
		_G["VCB4spark".. i]:Show()
	end
end
-- Show Ticks 5 --
local function Show5Ticks()
	for i = 1, 5, 1 do
		_G["VCB5spark".. i]:Show()
	end
end
-- Show Ticks 6 --
local function Show6Ticks()
	for i = 1, 6, 1 do
		_G["VCB6spark".. i]:Show()
	end
end
-- Show Ticks 7 --
local function Show7Ticks()
	for i = 1, 7, 1 do
		_G["VCB7spark".. i]:Show()
	end
end
-- Show Ticks 8 --
local function Show8Ticks()
	for i = 1, 8, 1 do
		_G["VCB8spark".. i]:Show()
	end
end
-- Hiding --
-- Hide Ticks 3 --
local function Hide3Ticks()
	for i = 1, 3, 1 do
		_G["VCB3spark".. i]:Hide()
	end
end
-- Hide Ticks 4 --
local function Hide4Ticks()
	for i = 1, 4, 1 do
		_G["VCB4spark".. i]:Hide()
	end
end
-- Hide Ticks 5 --
local function Hide5Ticks()
	for i = 1, 5, 1 do
		_G["VCB5spark".. i]:Hide()
	end
end
-- Hide Ticks 6 --
local function Hide6Ticks()
	for i = 1, 6, 1 do
		_G["VCB6spark".. i]:Hide()
	end
end
-- Hide Ticks 7 --
local function Hide7Ticks()
	for i = 1, 7, 1 do
		_G["VCB7spark".. i]:Hide()
	end
end
-- Hide Ticks 8 --
local function Hide8Ticks()
	for i = 1, 8, 1 do
		_G["VCB8spark".. i]:Hide()
	end
end
-- Classes --
-- Priest --
local function ShowPriestTicks(arg3)
-- Penance, Mind Flay Insanity --
	if arg3 == 391403 or arg3 == 47757 or arg3 == 47540 then
		Show4Ticks()
-- Void Torrent, Divine Hymn, Symbol of Hope --
	elseif arg3 == 263165 or arg3 == 64843 or arg3 == 64901 then
		Show5Ticks()
-- Mind Flay --
	elseif arg3 == 15407 then
		Show6Ticks()
	end
end
-- Mage --
local function ShowMageTicks(arg3)
-- Covenant: Shifting Power --
	if arg3 == 314791 then
		Show4Ticks()
-- Arcane Missiles, Ray of Frost --
	elseif arg3 == 5143 or arg3 == 205021 then
		Show5Ticks()
	end
end
-- Warlock --
local function ShowWarlockTicks(arg3)
-- Drain Life, Drain Soul, Health Funnel --
	if arg3 == 234153 or arg3 == 198590 or arg3 == 217979 then
		Show5Ticks()
	end
end
-- Monk --
local function ShowMonkTicks(arg3)
-- Essence Font, Spinning Crane Kick --
	if arg3 == 191837 or arg3 == 101546 then
		Show3Ticks()
-- Crackling Jade Lightning, Fists of Fury  --
	elseif arg3 == 117952 or arg3 == 113656 then
		Show4Ticks()
-- Soothing Mist --
	elseif arg3 == 115175 then
		Show8Ticks()
	end
end
-- Druid --
local function ShowDruidTicks(arg3)
-- Tranquility --
	if arg3 == 740 then
		Show4Ticks()
	end
end
-- Evoker --
local function ShowEvokerTicks()
-- Disintegrate --
	if vcbEvokerTicksFirstTime then
		for i = 1, 3, 1 do
			_G["VCB3spark".. i]:Show()
		end
	elseif vcbEvokerTicksSecondTime then
		for i = 1, 4, 1 do
			_G["VCB4spark".. i]:Show()
		end
	end
end
-- Create the Ticks --
local function vcbCreateTicks()
	_, _, classID = C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))
	if classID == 5 then
		Create4Ticks()
		Create5Ticks()
		Create6Ticks()
	elseif classID == 8 then
		Create4Ticks()
		Create5Ticks()
	elseif classID == 9 then
		Create5Ticks()
	elseif classID == 10 then
		Create3Ticks()
		Create4Ticks()
		Create8Ticks()
	elseif classID == 11 then
		Create4Ticks()
	elseif classID == 13 then
		Create3Ticks()
		Create4Ticks()
	end
end
-- Show the Ticks --
local function vcbShowTicks(arg3)
	if classID == 5 then ShowPriestTicks(arg3)
	elseif classID == 8 then ShowMageTicks(arg3)
	elseif classID == 9 then ShowWarlockTicks(arg3)
	elseif classID == 10 then ShowMonkTicks(arg3)
	elseif classID == 11 then ShowDruidTicks(arg3)
	elseif classID == 13 then ShowEvokerTicks()
	end
end
-- Hide the Ticks --
local function vcbHideTicks()
	if classID == 5 then
		Hide4Ticks()
		Hide5Ticks()
		Hide6Ticks()
	elseif classID == 8 then
		Hide4Ticks()
		Hide5Ticks()
	elseif classID == 9 then
		Hide5Ticks()
	elseif classID == 10 then
		Hide3Ticks()
		Hide4Ticks()
		Hide8Ticks()
	elseif classID == 11 then
		Hide4Ticks()
	elseif classID == 13 then
		Hide3Ticks()
		Hide4Ticks()
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
	if (self.barType == "channel" or self.barType =="uninterruptable") and VCBrPlayer["Ticks"] == "Show" then
		vcbShowTicks(VCBarg3)
	else
		vcbHideTicks()
	end
end)
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		PlayerCastingBarFrame.Icon:SetScale(1.3)
		PlayerCastingBarFrame.Icon:AdjustPointsOffset(2, -4)
		vcbCreateTicks()
	elseif event == "CURRENT_SPELL_CAST_CHANGED" and arg1 == false then
		lagStart = GetTime()
	elseif event == "UNIT_SPELLCAST_START" and arg1 == "player" then
		vcbHideTicks()
		VCBlagBar1:Hide()
		VCBlagBar2:Hide()
		VCBarg3 = arg3
		PlayerCastLagBar(arg3)
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" and arg1 == "player" then
		vcbHideTicks()
		VCBlagBar1:Hide()
		VCBlagBar2:Hide()
		vcbChannelSpellID = arg3
		VCBarg3 = arg3
		PlayerChannelLagBar(arg3)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
		local spellId, spellName, spellSchool = select(12, CombatLogGetCurrentEventInfo())
		if subevent == "SPELL_CAST_START" and sourceName == UnitFullName("player") then
			vcbSpellSchool = spellSchool
		elseif subevent == "SPELL_CAST_SUCCESS" and spellId == vcbChannelSpellID and sourceName == UnitFullName("player") then
			vcbSpellSchool = spellSchool
		elseif subevent == "SPELL_AURA_APPLIED" and sourceName == UnitFullName("player") and spellId == 356995 then
			vcbEvokerTicksFirstTime = true
			vcbEvokerTicksSecondTime = false
		elseif subevent == "SPELL_AURA_REFRESH" and sourceName == UnitFullName("player") and spellId == 356995 then
			vcbEvokerTicksFirstTime = false
			vcbEvokerTicksSecondTime = true
		end
	elseif event == "UNIT_SPELLCAST_SENT" and arg1 == "player" then
		vcbSpellSchool = 0
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" and arg1 == "player" then
		vcbSpellSchool = 0
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
