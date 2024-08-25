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
	elseif self.channeling then
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
	end
end
-- coloring the bar --
local function PlayerColorCastBar()
	if VCBrPlayer["Color"] == "Default Color" then
		PlayerCastingBarFrame:SetStatusBarDesaturated(false)
		PlayerCastingBarFrame:SetStatusBarColor(1, 1, 1, 1)
	elseif VCBrPlayer["Color"] == "Class' Color" then
		PlayerCastingBarFrame:SetStatusBarDesaturated(true)
		PlayerCastingBarFrame:SetStatusBarColor(vcbClassColor:GetRGB())
	elseif VCBrPlayer["Color"] == "Spell School Color" then
		PlayerCastingBarFrame:SetStatusBarDesaturated(true)
		if PlayerCastingBarFrame.barType == "uninterruptable" then PlayerCastingBarFrame:SetStatusBarTexture("UI-CastingBar-Full-Standard") end
		if vcbSpellSchool == 1 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbPhysicalColor:GetRGB())
		elseif vcbSpellSchool == 2 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbHolyColor:GetRGB())
		elseif vcbSpellSchool == 4 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbFireColor:GetRGB())
		elseif vcbSpellSchool == 8 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbNatureColor:GetRGB())
		elseif vcbSpellSchool == 16 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbFrostColor:GetRGB())
		elseif vcbSpellSchool == 32 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbShadowColor:GetRGB())
		elseif vcbSpellSchool == 64 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbArcaneColor:GetRGB())
		elseif vcbSpellSchool == 3 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbHolystrikeColor:GetRGB())
		elseif vcbSpellSchool == 5 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbFlamestrikeColor:GetRGB())
		elseif vcbSpellSchool == 6 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbRadiantColor:GetRGB())
		elseif vcbSpellSchool == 9 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbStormstrikeColor:GetRGB())
		elseif vcbSpellSchool == 10 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbHolystormColor:GetRGB())
		elseif vcbSpellSchool == 12 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbVolcanicColor:GetRGB())
		elseif vcbSpellSchool == 17 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbFroststrikeColor:GetRGB())
		elseif vcbSpellSchool == 18 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbHolyfrostColor:GetRGB())
		elseif vcbSpellSchool == 20 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbFrostfireColor:GetRGB())
		elseif vcbSpellSchool == 24 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbFroststormColor:GetRGB())
		elseif vcbSpellSchool == 33 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbShadowstrikeColor:GetRGB())
		elseif vcbSpellSchool == 34 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbTwilightColor:GetRGB())
		elseif vcbSpellSchool == 36 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbShadowflameColor:GetRGB())
		elseif vcbSpellSchool == 40 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbPlagueColor:GetRGB())
		elseif vcbSpellSchool == 48 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbShadowfrostColor:GetRGB())
		elseif vcbSpellSchool == 65 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbSpellstrikeColor:GetRGB())
		elseif vcbSpellSchool == 66 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbDivineColor:GetRGB())
		elseif vcbSpellSchool == 68 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbSpellfireColor:GetRGB())
		elseif vcbSpellSchool == 72 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbAstralColor:GetRGB())
		elseif vcbSpellSchool == 80 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbSpellfrostColor:GetRGB())
		elseif vcbSpellSchool == 96 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbSpellshadowColor:GetRGB())
		elseif vcbSpellSchool == 28 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbElementalColor:GetRGB())
		elseif vcbSpellSchool == 62 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbChromaticColor:GetRGB())
		elseif vcbSpellSchool == 106 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbCosmicColor:GetRGB())
		elseif vcbSpellSchool == 126 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbMagicColor:GetRGB())
		elseif vcbSpellSchool == 127 or vcbSpellSchool == 124 then
			PlayerCastingBarFrame:SetStatusBarColor(vcbChaosColor:GetRGB())
		else
			PlayerCastingBarFrame:SetStatusBarDesaturated(false)
			PlayerCastingBarFrame:SetStatusBarColor(1, 1, 1, 1)
		end
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
	PlayerColorCastBar()
	AscendingDescendingSec(self)
	if VCBrPlayer["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
		VCBtotalTimeText:SetFormattedText("%.2f sec", self.maxValue)
	elseif VCBrPlayer["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
		VCBtotalTimeText:SetFormattedText("%.2f", self.maxValue)
	end
	VCBnameText:SetText(self.Text:GetText())
	if VCBrPlayer["Ticks"] == "Show" then vcbShowTicks(VCBarg3)
	else vcbHideTicks()
	end
end)
