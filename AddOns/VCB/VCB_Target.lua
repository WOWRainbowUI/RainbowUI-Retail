-- function for the texts --
local function VCBtexts(var1)
	VCBnameTextTarget = var1:CreateFontString(nil, "OVERLAY", nil)
	VCBnameTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBnameTextTarget:SetHeight(var1.Text:GetHeight())
	VCBnameTextTarget:Hide()
	VCBcurrentTimeTextTarget = var1:CreateFontString(nil, "OVERLAY", nil)
	VCBcurrentTimeTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBcurrentTimeTextTarget:SetHeight(var1.Text:GetHeight())
	VCBcurrentTimeTextTarget:Hide()
	VCBtotalTimeTextTarget = var1:CreateFontString(nil, "OVERLAY", nil)
	VCBtotalTimeTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBtotalTimeTextTarget:SetHeight(var1.Text:GetHeight())
	VCBtotalTimeTextTarget:Hide()
	VCBbothTimeTextTarget = var1:CreateFontString(nil, "OVERLAY", nil)
	VCBbothTimeTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBbothTimeTextTarget:SetHeight(var1.Text:GetHeight())
	VCBbothTimeTextTarget:Hide()
end
-- Position of the Name Text --
local function NameTextPosition(self, var1, var2)
	if VCBrTarget[var1] == "Top Left" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "Left" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "Bottom Left" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "Top" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "Center" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "Bottom" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "Top Right" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "Right" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "Bottom Right" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "Hide" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Position of the Casting Texts --
local function CastingTextPosition(self, var1, var2)
	if VCBrTarget[var1]["Position"] == "Top Left" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "Left" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "Bottom Left" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "Top" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "Center" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "Bottom" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "Top Right" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "Right" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "Bottom Right" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "Hide" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Ascending, Descending and Sec --
local function AscendingDescendingSec(self)
	if self.casting then
		if VCBrTarget["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
			if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
			if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
			if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	elseif self.channeling then
		if VCBrTarget["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
			if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
			if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
			if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
				if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
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
		if VCBrTarget["Color"] == "Default Color" then
			self:SetStatusBarDesaturated(false)
			self:SetStatusBarColor(1, 1, 1, 1)
		elseif VCBrTarget["Color"] == "Class' Color" then
			self:SetStatusBarDesaturated(true)
			self:SetStatusBarColor(vcbClassColorTarget:GetRGB())
		end
	else
		self:SetStatusBarDesaturated(false)
		self:SetStatusBarColor(1, 1, 1, 1)
	end
end
-- hooking time --
local function AloneTargetSpellBar()
	VCBtexts(TargetFrameSpellBar)
-- Hooking Time part 1 --
	TargetFrameSpellBar:HookScript("OnShow", function(self)
		NameTextPosition(self, "NameText", VCBnameTextTarget)
		CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeTextTarget)
		CastingTextPosition(self, "BothTimeText", VCBbothTimeTextTarget)
		CastingTextPosition(self, "TotalTimeText", VCBtotalTimeTextTarget)
	end)
-- Hooking Time part 2 --
	TargetFrameSpellBar:HookScript("OnUpdate", function(self)
		self.Text:SetAlpha(0)
		VCBnameTextTarget:SetText(self.Text:GetText())
		AscendingDescendingSec(self)
		CastBarColor(self)
		if VCBrTarget["TotalTimeText"]["Decimals"] == 2 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.2f sec", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.1f sec", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.0f sec", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end)
end
-- SUF interaction --
local function vcbSufCoOp_Traget()
	SUFUnittarget.vcbCastbar = CreateFrame("StatusBar", nil, UIParent, "SmallCastingBarFrameTemplate")
	SUFUnittarget.vcbCastbar:SetSize(150, 10)
	SUFUnittarget.vcbCastbar:ClearAllPoints()
	SUFUnittarget.vcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
	SUFUnittarget.vcbCastbar:SetScale(VCBrTarget["Scale"]/100)
	SUFUnittarget.vcbCastbar:SetUnit("target", true, true)
	SUFUnittarget.vcbCastbar:UpdateShownState(true)
	VCBtexts(SUFUnittarget.vcbCastbar)
-- Hooking Time part 1 --
	SUFUnittarget.vcbCastbar:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
		self:SetScale(VCBrTarget["Scale"]/100)
		CastBarColor(self)
		NameTextPosition(self, "NameText", VCBnameTextTarget)
		CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeTextTarget)
		CastingTextPosition(self, "BothTimeText", VCBbothTimeTextTarget)
		CastingTextPosition(self, "TotalTimeText", VCBtotalTimeTextTarget)
	end)
-- Hooking Time part 2 --
	SUFUnittarget.vcbCastbar:HookScript("OnUpdate", function(self)
		self.Text:SetAlpha(0)
		VCBnameTextTarget:SetText(self.Text:GetText())
		AscendingDescendingSec(self)
		if VCBrTarget["TotalTimeText"]["Decimals"] == 2 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.2f sec", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.1f sec", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.0f sec", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end)
end
-- loading saved variables --
local function LoadSavedVariables1()
	if VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" and VCBrTarget["Unlock"] then
		SUFUnittarget:HookScript("OnShow", function(self)
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		end)
		vcbSufCoOp_Traget()
	elseif VCBrTarget["otherAdddon"] == "None" and VCBrTarget["Unlock"] then
		AloneTargetSpellBar()
		-- extra hooking --
		TargetFrameSpellBar:HookScript("OnUpdate", function(self)
			self:SetScale(VCBrTarget["Scale"]/100)
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
		end)
	elseif VCBrTarget["otherAdddon"] == "None" and not VCBrTarget["Unlock"] then
		AloneTargetSpellBar()
	end
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		LoadSavedVariables1()
	elseif event == "PLAYER_TARGET_CHANGED" then
		if TargetFrame:IsShown() then
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		elseif SUFUnittarget ~= nil and VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" and SUFUnittarget:IsShown() then
			SUFUnittarget.vcbCastbar:SetUnit(nil, true, true)
			SUFUnittarget.vcbCastbar:PlayFinishAnim()
			SUFUnittarget.vcbCastbar:SetUnit("target", true, true)
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		end
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
