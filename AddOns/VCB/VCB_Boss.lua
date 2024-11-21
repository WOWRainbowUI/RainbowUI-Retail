-- Position of the Name Text --
local function NameTextPosition(self, var1, var2)
	if VCBrBoss[var1] == "Top Left" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1] == "Left" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1] == "Bottom Left" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1] == "Top" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1] == "Center" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1] == "Bottom" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1] == "Top Right" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1] == "Right" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1] == "Bottom Right" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1] == "Hide" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Position of the Casting Texts --
local function CastingTextPosition(self, var1, var2)
	if VCBrBoss[var1]["Position"] == "Top Left" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1]["Position"] == "Left" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1]["Position"] == "Bottom Left" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1]["Position"] == "Top" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1]["Position"] == "Center" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1]["Position"] == "Bottom" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1]["Position"] == "Top Right" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1]["Position"] == "Right" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1]["Position"] == "Bottom Right" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrBoss[var1]["Position"] == "Hide" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Ascending, Descending and Sec --
local function AscendingDescendingSec(self)
	if self.casting then
		if VCBrBoss["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrBoss["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", VCBdescending)
				end
			elseif VCBrBoss["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrBoss["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrBoss["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", VCBdescending)
				end
			elseif VCBrBoss["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrBoss["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrBoss["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", VCBdescending)
				end
			elseif VCBrBoss["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrBoss["BothTimeText"]["Decimals"] == 2 then
			if VCBrBoss["BothTimeText"]["Sec"] == "Show" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Ascending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrBoss["BothTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Ascending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrBoss["BothTimeText"]["Decimals"] == 1 then
			if VCBrBoss["BothTimeText"]["Sec"] == "Show" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Ascending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrBoss["BothTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Ascending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrBoss["BothTimeText"]["Decimals"] == 0 then
			if VCBrBoss["BothTimeText"]["Sec"] == "Show" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Ascending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrBoss["BothTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Ascending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	elseif self.channeling then
		if VCBrBoss["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrBoss["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", VCBdescending)
				end
			elseif VCBrBoss["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrBoss["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrBoss["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", VCBdescending)
				end
			elseif VCBrBoss["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrBoss["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrBoss["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", VCBdescending)
				end
			elseif VCBrBoss["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["CurrentTimeText"]["Direction"] == "Descending" or VCBrBoss["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
				elseif VCBrBoss["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrBoss["BothTimeText"]["Decimals"] == 2 then
			if VCBrBoss["BothTimeText"]["Sec"] == "Show" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Descending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrBoss["BothTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Descending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrBoss["BothTimeText"]["Decimals"] == 1 then
			if VCBrBoss["BothTimeText"]["Sec"] == "Show" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Descending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrBoss["BothTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Descending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrBoss["BothTimeText"]["Decimals"] == 0 then
			if VCBrBoss["BothTimeText"]["Sec"] == "Show" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Descending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrBoss["BothTimeText"]["Sec"] == "Hide" then
				if VCBrBoss["BothTimeText"]["Direction"] == "Descending" or VCBrBoss["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrBoss["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	end
end
-- coloring the bar --
local function CastBarColor(self)
	if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
		if VCBrBoss["Color"] == "Default Color" then
			self:SetStatusBarDesaturated(false)
			self:SetStatusBarColor(1, 1, 1, 1)
		elseif VCBrBoss["Color"] == "Class' Color" then
			self:SetStatusBarDesaturated(true)
			self:SetStatusBarColor(vcbClassColorBoss:GetRGB())
		end
	else
		self:SetStatusBarDesaturated(false)
		self:SetStatusBarColor(1, 1, 1, 1)
	end
end
-- Hooking Times--
local function AloneBossSpellBar()
-- Name Text --
	VCBnameTextBoss1 = Boss1TargetFrameSpellBar:CreateFontString("VCBnameTextBoss1", "OVERLAY", nil)
	VCBnameTextBoss2 = Boss2TargetFrameSpellBar:CreateFontString("VCBnameTextBoss2", "OVERLAY", nil)
	VCBnameTextBoss3 = Boss3TargetFrameSpellBar:CreateFontString("VCBnameTextBoss3", "OVERLAY", nil)
	VCBnameTextBoss4 = Boss4TargetFrameSpellBar:CreateFontString("VCBnameTextBoss4", "OVERLAY", nil)
	VCBnameTextBoss5 = Boss5TargetFrameSpellBar:CreateFontString("VCBnameTextBoss5", "OVERLAY", nil)
-- Current Time Text --
	VCBcurrentTimeTextBoss1 = Boss1TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss1", "OVERLAY", nil)
	VCBcurrentTimeTextBoss2 = Boss2TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss2", "OVERLAY", nil)
	VCBcurrentTimeTextBoss3 = Boss3TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss3", "OVERLAY", nil)
	VCBcurrentTimeTextBoss4 = Boss4TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss4", "OVERLAY", nil)
	VCBcurrentTimeTextBoss5 = Boss5TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextBoss5", "OVERLAY", nil)
-- Total Time Text --
	VCBtotalTimeTextBoss1 = Boss1TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss1", "OVERLAY", nil)
	VCBtotalTimeTextBoss2 = Boss2TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss2", "OVERLAY", nil)
	VCBtotalTimeTextBoss3 = Boss3TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss3", "OVERLAY", nil)
	VCBtotalTimeTextBoss4 = Boss4TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss4", "OVERLAY", nil)
	VCBtotalTimeTextBoss5 = Boss5TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextBoss5", "OVERLAY", nil)
-- Both Time Text --
	VCBbothTimeTextBoss1 = Boss1TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss1", "OVERLAY", nil)
	VCBbothTimeTextBoss2 = Boss2TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss2", "OVERLAY", nil)
	VCBbothTimeTextBoss3 = Boss3TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss3", "OVERLAY", nil)
	VCBbothTimeTextBoss4 = Boss4TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss4", "OVERLAY", nil)
	VCBbothTimeTextBoss5 = Boss5TargetFrameSpellBar:CreateFontString("VCBbothTimeTextBoss5", "OVERLAY", nil)
	for i = 1, 5, 1 do
		-- name --
		_G["VCBnameTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBnameTextBoss"..i]:SetHeight(_G["Boss"..i.."TargetFrameSpellBar"].Text:GetHeight())
		_G["VCBnameTextBoss"..i]:Hide()
		-- Current Time Text --
		_G["VCBcurrentTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBcurrentTimeTextBoss"..i]:SetHeight(_G["Boss"..i.."TargetFrameSpellBar"].Text:GetHeight())
		_G["VCBcurrentTimeTextBoss"..i]:Hide()
		-- Total Time Text --
		_G["VCBtotalTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBtotalTimeTextBoss"..i]:SetHeight(_G["Boss"..i.."TargetFrameSpellBar"].Text:GetHeight())
		_G["VCBtotalTimeTextBoss"..i]:Hide()
		-- Both Time Text --
		_G["VCBbothTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBbothTimeTextBoss"..i]:SetHeight(_G["Boss"..i.."TargetFrameSpellBar"].Text:GetHeight())
		_G["VCBbothTimeTextBoss"..i]:Hide()
		-- Hooking Time part 1 --
		_G["Boss"..i.."TargetFrameSpellBar"]:HookScript("OnShow", function(self)
			local classFilename = UnitClassBase("boss"..i)
			if classFilename ~= nil then vcbClassColorBoss = C_ClassColor.GetClassColor(classFilename) end
			NameTextPosition(self, "NameText", _G["VCBnameTextBoss"..i])
			CastingTextPosition(self, "CurrentTimeText", _G["VCBcurrentTimeTextBoss"..i])
			CastingTextPosition(self, "BothTimeText", _G["VCBbothTimeTextBoss"..i])
			CastingTextPosition(self, "TotalTimeText", _G["VCBtotalTimeTextBoss"..i])
		end)
		-- Hooking Time part 2 --
		_G["Boss"..i.."TargetFrameSpellBar"]:HookScript("OnUpdate", function(self)
			self.Text:SetAlpha(0)
			_G["VCBnameTextBoss"..i]:SetText(self.Text:GetText())
			AscendingDescendingSec(self)
			CastBarColor(self)
			if VCBrBoss["TotalTimeText"]["Decimals"] == 2 then
				if VCBrBoss["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.2f sec", self.maxValue)
				elseif VCBrBoss["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.2f", self.maxValue)
				end
			elseif VCBrBoss["TotalTimeText"]["Decimals"] == 1 then
				if VCBrBoss["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.1f sec", self.maxValue)
				elseif VCBrBoss["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.1f", self.maxValue)
				end
			elseif VCBrBoss["TotalTimeText"]["Decimals"] == 0 then
				if VCBrBoss["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.0f sec", self.maxValue)
				elseif VCBrBoss["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.0f", self.maxValue)
				end
			end
		end)
	end
end
-- SUF interaction --
local function vcbSufCoOp_Boss()
	for i = 1, 5, 1 do
		local statusbar = CreateFrame("StatusBar", "SUFHeaderbossUnitButton"..i.."vcbCastbar", _G["SUFHeaderbossUnitButton"..i], "SmallCastingBarFrameTemplate")
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetSize(150, 10)
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:ClearAllPoints()
		if i == 1 then _G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrBoss["Position"]["X"], VCBrBoss["Position"]["Y"])
		else _G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetPoint("TOP", _G["SUFHeaderbossUnitButton"..(i-1).."vcbCastbar"], "BOTTOM", 0, -32) end
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetScale(VCBrBoss["Scale"]/100)
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:OnLoad("boss"..i, true, true)
	end
-- Name Text --
	VCBnameTextBoss1 = SUFHeaderbossUnitButton1vcbCastbar:CreateFontString("VCBnameTextBoss1", "OVERLAY", nil)
	VCBnameTextBoss2 = SUFHeaderbossUnitButton2vcbCastbar:CreateFontString("VCBnameTextBoss2", "OVERLAY", nil)
	VCBnameTextBoss3 = SUFHeaderbossUnitButton3vcbCastbar:CreateFontString("VCBnameTextBoss3", "OVERLAY", nil)
	VCBnameTextBoss4 = SUFHeaderbossUnitButton4vcbCastbar:CreateFontString("VCBnameTextBoss4", "OVERLAY", nil)
	VCBnameTextBoss5 = SUFHeaderbossUnitButton5vcbCastbar:CreateFontString("VCBnameTextBoss5", "OVERLAY", nil)
-- Current Time Text --
	VCBcurrentTimeTextBoss1 = SUFHeaderbossUnitButton1vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss1", "OVERLAY", nil)
	VCBcurrentTimeTextBoss2 = SUFHeaderbossUnitButton2vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss2", "OVERLAY", nil)
	VCBcurrentTimeTextBoss3 = SUFHeaderbossUnitButton3vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss3", "OVERLAY", nil)
	VCBcurrentTimeTextBoss4 = SUFHeaderbossUnitButton4vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss4", "OVERLAY", nil)
	VCBcurrentTimeTextBoss5 = SUFHeaderbossUnitButton5vcbCastbar:CreateFontString("VCBcurrentTimeTextBoss5", "OVERLAY", nil)
-- Total Time Text --
	VCBtotalTimeTextBoss1 = SUFHeaderbossUnitButton1vcbCastbar:CreateFontString("VCBtotalTimeTextBoss1", "OVERLAY", nil)
	VCBtotalTimeTextBoss2 = SUFHeaderbossUnitButton2vcbCastbar:CreateFontString("VCBtotalTimeTextBoss2", "OVERLAY", nil)
	VCBtotalTimeTextBoss3 = SUFHeaderbossUnitButton3vcbCastbar:CreateFontString("VCBtotalTimeTextBoss3", "OVERLAY", nil)
	VCBtotalTimeTextBoss4 = SUFHeaderbossUnitButton4vcbCastbar:CreateFontString("VCBtotalTimeTextBoss4", "OVERLAY", nil)
	VCBtotalTimeTextBoss5 = SUFHeaderbossUnitButton5vcbCastbar:CreateFontString("VCBtotalTimeTextBoss5", "OVERLAY", nil)
-- Both Time Text --
	VCBbothTimeTextBoss1 = SUFHeaderbossUnitButton1vcbCastbar:CreateFontString("VCBbothTimeTextBoss1", "OVERLAY", nil)
	VCBbothTimeTextBoss2 = SUFHeaderbossUnitButton2vcbCastbar:CreateFontString("VCBbothTimeTextBoss2", "OVERLAY", nil)
	VCBbothTimeTextBoss3 = SUFHeaderbossUnitButton3vcbCastbar:CreateFontString("VCBbothTimeTextBoss3", "OVERLAY", nil)
	VCBbothTimeTextBoss4 = SUFHeaderbossUnitButton4vcbCastbar:CreateFontString("VCBbothTimeTextBoss4", "OVERLAY", nil)
	VCBbothTimeTextBoss5 = SUFHeaderbossUnitButton5vcbCastbar:CreateFontString("VCBbothTimeTextBoss5", "OVERLAY", nil)
	for i = 1, 5, 1 do
		-- name --
		_G["VCBnameTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBnameTextBoss"..i]:SetHeight(_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBnameTextBoss"..i]:Hide()
		-- Current Time Text --
		_G["VCBcurrentTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBcurrentTimeTextBoss"..i]:SetHeight(_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBcurrentTimeTextBoss"..i]:Hide()
		-- Total Time Text --
		_G["VCBtotalTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBtotalTimeTextBoss"..i]:SetHeight(_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBtotalTimeTextBoss"..i]:Hide()
		-- Both Time Text --
		_G["VCBbothTimeTextBoss"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBbothTimeTextBoss"..i]:SetHeight(_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBbothTimeTextBoss"..i]:Hide()
		-- hook times 1 --
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:HookScript("OnShow", function(self)
			self:SetScale(VCBrBoss["Scale"]/100)
			self:ClearAllPoints()
			if i == 1 then _G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrBoss["Position"]["X"], VCBrBoss["Position"]["Y"])
			else _G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:SetPoint("TOP", _G["SUFHeaderbossUnitButton"..(i-1).."vcbCastbar"], "BOTTOM", 0, -32) end
			local classFilename = UnitClassBase("boss"..i)
			if classFilename ~= nil then vcbClassColorBoss = C_ClassColor.GetClassColor(classFilename) end
			NameTextPosition(self, "NameText", _G["VCBnameTextBoss"..i])
			CastingTextPosition(self, "CurrentTimeText", _G["VCBcurrentTimeTextBoss"..i])
			CastingTextPosition(self, "BothTimeText", _G["VCBbothTimeTextBoss"..i])
			CastingTextPosition(self, "TotalTimeText", _G["VCBtotalTimeTextBoss"..i])
		end)
		-- hook times 2 --
		_G["SUFHeaderbossUnitButton"..i.."vcbCastbar"]:HookScript("OnUpdate", function(self)
			self.Text:SetAlpha(0)
			_G["VCBnameTextBoss"..i]:SetText(self.Text:GetText())
			AscendingDescendingSec(self)
			CastBarColor(self)
			if VCBrBoss["TotalTimeText"]["Decimals"] == 2 then
				if VCBrBoss["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.2f sec", self.maxValue)
				elseif VCBrBoss["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.2f", self.maxValue)
				end
			elseif VCBrBoss["TotalTimeText"]["Decimals"] == 1 then
				if VCBrBoss["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.1f sec", self.maxValue)
				elseif VCBrBoss["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.1f", self.maxValue)
				end
			elseif VCBrBoss["TotalTimeText"]["Decimals"] == 0 then
				if VCBrBoss["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.0f sec", self.maxValue)
				elseif VCBrBoss["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
					_G["VCBtotalTimeTextBoss"..i]:SetFormattedText("%.0f", self.maxValue)
				end
			end
		end)
	end
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		if not VCBrBoss["Unlock"] and VCBrBoss["otherAdddon"] == "None" then
			AloneBossSpellBar()
		elseif VCBrBoss["Unlock"] and VCBrBoss["otherAdddon"] == "None" then
			AloneBossSpellBar()
			Boss1TargetFrameSpellBar:HookScript("OnUpdate", function(self)
				self:SetScale(VCBrBoss["Scale"]/100)
				self:ClearAllPoints()
				self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrBoss["Position"]["X"], VCBrBoss["Position"]["Y"])
			end)
			Boss2TargetFrameSpellBar:HookScript("OnUpdate", function(self)
				self:SetScale(VCBrBoss["Scale"]/100)
				self:ClearAllPoints()
				self:SetPoint("TOP", Boss1TargetFrameSpellBar, "BOTTOM", 0, -32)
			end)
			Boss3TargetFrameSpellBar:HookScript("OnUpdate", function(self)
				self:SetScale(VCBrBoss["Scale"]/100)
				self:ClearAllPoints()
				self:SetPoint("TOP", Boss2TargetFrameSpellBar, "BOTTOM", 0, -32)
			end)
			Boss4TargetFrameSpellBar:HookScript("OnUpdate", function(self)
				self:SetScale(VCBrBoss["Scale"]/100)
				self:ClearAllPoints()
				self:SetPoint("TOP", Boss3TargetFrameSpellBar, "BOTTOM", 0, -32)
			end)
			Boss5TargetFrameSpellBar:HookScript("OnUpdate", function(self)
				self:SetScale(VCBrBoss["Scale"]/100)
				self:ClearAllPoints()
				self:SetPoint("TOP", Boss4TargetFrameSpellBar, "BOTTOM", 0, -32)
			end)
		elseif VCBrBoss["Unlock"] and VCBrBoss["otherAdddon"] == "Shadowed Unit Frame" then
			vcbSufCoOp_Boss()
		end
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
