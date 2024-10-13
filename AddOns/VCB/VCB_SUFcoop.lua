-- main function --
function vcbSufCoOp_Traget()
	SUFUnittarget.vcbCastbar = CreateFrame("StatusBar", nil, UIParent, "SmallCastingBarFrameTemplate")
	SUFUnittarget.vcbCastbar:SetSize(150, 10)
	SUFUnittarget.vcbCastbar:ClearAllPoints()
	SUFUnittarget.vcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
	SUFUnittarget.vcbCastbar:SetScale(VCBrTarget["Scale"]/100)
	SUFUnittarget.vcbCastbar:SetUnit("target", true, true)
	SUFUnittarget.vcbCastbar:UpdateShownState(true)
-- function for the texts --
	local function VCBtexts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(SUFUnittarget.vcbCastbar.Text:GetHeight())
		var1:Hide()
	end
-- Name Text --
	local VCBnameText = SUFUnittarget.vcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBtexts(VCBnameText)
-- Current Time Text --
	local VCBcurrentTimeText = SUFUnittarget.vcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBtexts(VCBcurrentTimeText)
-- Total Time Text --
	local VCBtotalTimeText = SUFUnittarget.vcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBtexts(VCBtotalTimeText)
-- Both Time Text --
	local VCBbothTimeText = SUFUnittarget.vcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBtexts(VCBbothTimeText)
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
						VCBcurrentTimeText:SetFormattedText("%.2f sec", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f sec", VCBdescending)
					end
				elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
				if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.1f sec", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f sec", VCBdescending)
					end
				elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
				if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.0f sec", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f sec", VCBdescending)
					end
				elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
					end
				end
			end
			if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
				if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
				if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
				if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					end
				end
			end
		elseif self.channeling then
			if VCBrTarget["CurrentTimeText"]["Decimals"] == 2 then
				if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.2f sec", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f sec", VCBdescending)
					end
				elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
				if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.1f sec", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f sec", VCBdescending)
					end
				elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
				if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.0f sec", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f sec", VCBdescending)
					end
				elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" or VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
					elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
					end
				end
			end
			if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
				if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
				if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
				if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
					if VCBrTarget["BothTimeText"]["Direction"] == "Descending" or VCBrTarget["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
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
-- Hooking Time part 1 --
	SUFUnittarget.vcbCastbar:HookScript("OnShow", function(self)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
		self:SetScale(VCBrTarget["Scale"]/100)
		CastBarColor(self)
		NameTextPosition(self, "NameText", VCBnameText)
		CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeText)
		CastingTextPosition(self, "BothTimeText", VCBbothTimeText)
		CastingTextPosition(self, "TotalTimeText", VCBtotalTimeText)
	end)
-- Hooking Time part 2 --
	SUFUnittarget.vcbCastbar:HookScript("OnUpdate", function(self)
		self.Text:SetAlpha(0)
		VCBnameText:SetText(self.Text:GetText())
		AscendingDescendingSec(self)
		if VCBrTarget["TotalTimeText"]["Decimals"] == 2 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.2f sec", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.1f sec", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.0f sec", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end)
end
-- main function --
function vcbSufCoOp_Focus()
	SUFUnitfocus.vcbCastbar = CreateFrame("StatusBar", nil, UIParent, "SmallCastingBarFrameTemplate")
	SUFUnitfocus.vcbCastbar:SetSize(150, 10)
	SUFUnitfocus.vcbCastbar:ClearAllPoints()
	SUFUnitfocus.vcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
	SUFUnitfocus.vcbCastbar:SetScale(VCBrFocus["Scale"]/100)
	SUFUnitfocus.vcbCastbar:OnLoad("focus", true, true)
-- function for the texts --
	local function VCBtexts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(SUFUnitfocus.vcbCastbar.Text:GetHeight())
		var1:Hide()
	end
	-- Name Text --
	local VCBnameText = SUFUnitfocus.vcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBtexts(VCBnameText)
	-- Current Time Text --
	local VCBcurrentTimeText = SUFUnitfocus.vcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBtexts(VCBcurrentTimeText)
	-- Total Time Text --
	local VCBtotalTimeText = SUFUnitfocus.vcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBtexts(VCBtotalTimeText)
	-- Both Time Text --
	local VCBbothTimeText = SUFUnitfocus.vcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBtexts(VCBbothTimeText)
-- Position of the Name Text --
	local function NameTextPosition(self, var1, var2)
		if VCBrFocus[var1] == "Top Left" then
			var2:ClearAllPoints()
			var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1] == "Left" then
			var2:ClearAllPoints()
			var2:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1] == "Bottom Left" then
			var2:ClearAllPoints()
			var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1] == "Top" then
			var2:ClearAllPoints()
			var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1] == "Center" then
			var2:ClearAllPoints()
			var2:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1] == "Bottom" then
			var2:ClearAllPoints()
			var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1] == "Top Right" then
			var2:ClearAllPoints()
			var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1] == "Right" then
			var2:ClearAllPoints()
			var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1] == "Bottom Right" then
			var2:ClearAllPoints()
			var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1] == "Hide" then
			if var2:IsShown() then var2:Hide() end
		end
	end
-- Position of the Casting Texts --
	local function CastingTextPosition(self, var1, var2)
		if VCBrFocus[var1]["Position"] == "Top Left" then
			var2:ClearAllPoints()
			var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1]["Position"] == "Left" then
			var2:ClearAllPoints()
			var2:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1]["Position"] == "Bottom Left" then
			var2:ClearAllPoints()
			var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1]["Position"] == "Top" then
			var2:ClearAllPoints()
			var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1]["Position"] == "Center" then
			var2:ClearAllPoints()
			var2:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1]["Position"] == "Bottom" then
			var2:ClearAllPoints()
			var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1]["Position"] == "Top Right" then
			var2:ClearAllPoints()
			var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1]["Position"] == "Right" then
			var2:ClearAllPoints()
			var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1]["Position"] == "Bottom Right" then
			var2:ClearAllPoints()
			var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not var2:IsShown() then var2:Show() end
		elseif VCBrFocus[var1]["Position"] == "Hide" then
			if var2:IsShown() then var2:Hide() end
		end
	end
-- Ascending, Descending and Sec --
	local function AscendingDescendingSec(self)
		if self.casting then
			if VCBrFocus["CurrentTimeText"]["Decimals"] == 2 then
				if VCBrFocus["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.2f sec", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f sec", VCBdescending)
					end
				elseif VCBrFocus["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 1 then
				if VCBrFocus["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.1f sec", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f sec", VCBdescending)
					end
				elseif VCBrFocus["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 0 then
				if VCBrFocus["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.0f sec", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f sec", VCBdescending)
					end
				elseif VCBrFocus["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
					end
				end
			end
			if VCBrFocus["BothTimeText"]["Decimals"] == 2 then
				if VCBrFocus["BothTimeText"]["Sec"] == "Show" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Ascending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrFocus["BothTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Ascending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Decimals"] == 1 then
				if VCBrFocus["BothTimeText"]["Sec"] == "Show" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Ascending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrFocus["BothTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Ascending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Decimals"] == 0 then
				if VCBrFocus["BothTimeText"]["Sec"] == "Show" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Ascending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrFocus["BothTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Ascending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Descending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					end
				end
			end
		elseif self.channeling then
			if VCBrFocus["CurrentTimeText"]["Decimals"] == 2 then
				if VCBrFocus["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.2f sec", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f sec", VCBdescending)
					end
				elseif VCBrFocus["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 1 then
				if VCBrFocus["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.1f sec", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f sec", VCBdescending)
					end
				elseif VCBrFocus["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 0 then
				if VCBrFocus["CurrentTimeText"]["Sec"] == "Show" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.0f sec", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f sec", VCBdescending)
					end
				elseif VCBrFocus["CurrentTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["CurrentTimeText"]["Direction"] == "Descending" or VCBrFocus["CurrentTimeText"]["Direction"] == "Both" then
						VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
					elseif VCBrFocus["CurrentTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
					end
				end
			end
			if VCBrFocus["BothTimeText"]["Decimals"] == 2 then
				if VCBrFocus["BothTimeText"]["Sec"] == "Show" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Descending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrFocus["BothTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Descending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Decimals"] == 1 then
				if VCBrFocus["BothTimeText"]["Sec"] == "Show" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Descending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrFocus["BothTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Descending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrFocus["BothTimeText"]["Decimals"] == 0 then
				if VCBrFocus["BothTimeText"]["Sec"] == "Show" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Descending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Ascending" then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
					end
				elseif VCBrFocus["BothTimeText"]["Sec"] == "Hide" then
					if VCBrFocus["BothTimeText"]["Direction"] == "Descending" or VCBrFocus["BothTimeText"]["Direction"] == "Both" then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif VCBrFocus["BothTimeText"]["Direction"] == "Ascending" then
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
			if VCBrFocus["Color"] == "Default Color" then
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			elseif VCBrFocus["Color"] == "Class' Color" then
				self:SetStatusBarDesaturated(true)
				self:SetStatusBarColor(vcbClassColorFocus:GetRGB())
			end
		else
			self:SetStatusBarDesaturated(false)
			self:SetStatusBarColor(1, 1, 1, 1)
		end
	end
-- Hooking Time part 1 --
	SUFUnitfocus.vcbCastbar:HookScript("OnShow", function(self)
		SUFUnitfocus.vcbCastbar:ClearAllPoints()
		SUFUnitfocus.vcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
		SUFUnitfocus.vcbCastbar:SetScale(VCBrFocus["Scale"]/100)
		CastBarColor(self)
		NameTextPosition(self, "NameText", VCBnameText)
		CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeText)
		CastingTextPosition(self, "BothTimeText", VCBbothTimeText)
		CastingTextPosition(self, "TotalTimeText", VCBtotalTimeText)
	end)
-- Hooking Time part 2 --
	SUFUnitfocus.vcbCastbar:HookScript("OnUpdate", function(self)
		self.Text:SetAlpha(0)
		VCBnameText:SetText(self.Text:GetText())
		AscendingDescendingSec(self)
		if VCBrFocus["TotalTimeText"]["Decimals"] == 2 then
			if VCBrFocus["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.2f sec", self.maxValue)
			elseif VCBrFocus["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 1 then
			if VCBrFocus["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.1f sec", self.maxValue)
			elseif VCBrFocus["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 0 then
			if VCBrFocus["TotalTimeText"]["Sec"] == "Show" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.0f sec", self.maxValue)
			elseif VCBrFocus["TotalTimeText"]["Sec"] == "Hide" and self.maxValue ~= nil then
				VCBtotalTimeText:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end)
end