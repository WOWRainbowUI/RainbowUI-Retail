-- Position of the Name Text --
local function NameTextPosition(self, var1, var2)
	if VCBrFocus[var1] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Position of the Casting Texts --
local function CastingTextPosition(self, var1, var2)
	if VCBrFocus[var1]["Position"] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrFocus[var1]["Position"] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Ascending, Descending and Sec --
local function AscendingDescendingSec(self)
	if self.casting then
		if VCBrFocus["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "正數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrFocus["BothTimeText"]["Decimals"] == 2 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrFocus["BothTimeText"]["Decimals"] == 1 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrFocus["BothTimeText"]["Decimals"] == 0 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "正數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	elseif self.channeling then
		if VCBrFocus["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrFocus["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrFocus["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f 秒", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f 秒", VCBdescending)
				end
			elseif VCBrFocus["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["CurrentTimeText"]["Direction"] == "倒數" or VCBrFocus["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f", self.value)
				elseif VCBrFocus["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextFocus:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrFocus["BothTimeText"]["Decimals"] == 2 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrFocus["BothTimeText"]["Decimals"] == 1 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrFocus["BothTimeText"]["Decimals"] == 0 then
			if VCBrFocus["BothTimeText"]["Sec"] == "顯示" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrFocus["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrFocus["BothTimeText"]["Direction"] == "倒數" or VCBrFocus["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrFocus["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextFocus:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	end
end
-- coloring the bar --
local function CastBarColor(self)
	if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
		if VCBrFocus["Color"] == "預設顏色" then
			self:SetStatusBarDesaturated(false)
			self:SetStatusBarColor(1, 1, 1, 1)
		elseif VCBrFocus["Color"] == "職業顏色" then
			self:SetStatusBarDesaturated(true)
			self:SetStatusBarColor(vcbClassColorFocus:GetRGB())
		end
	else
		self:SetStatusBarDesaturated(false)
		self:SetStatusBarColor(1, 1, 1, 1)
	end
end
-- icon and shield visibility --
local function IconShieldVisibility()
	if VCBrFocus["Icon"] == "顯示圖示 & 盾牌" then
		if not FocusFrameSpellBar.Icon:IsShown() then FocusFrameSpellBar.Icon:Show() end
		if not FocusFrameSpellBar.showShield then FocusFrameSpellBar.showShield = true end
	elseif VCBrFocus["Icon"] == "隱藏圖示 & 盾牌" then
		if FocusFrameSpellBar.Icon:IsShown() then FocusFrameSpellBar.Icon:Hide() end
		if FocusFrameSpellBar.showShield then FocusFrameSpellBar.showShield = false end
	elseif VCBrFocus["Icon"] == "只隱藏圖示" then
		if FocusFrameSpellBar.Icon:IsShown() then FocusFrameSpellBar.Icon:Hide() end
		if not FocusFrameSpellBar.showShield then FocusFrameSpellBar.showShield = true end
	end
end
-- hooking time --
local function AloneFocusSpellBar()
-- texts --
	VCBnameTextFocus = FocusFrameSpellBar:CreateFontString("VCBnameTextFocus", "OVERLAY", nil)
	VCBnameTextFocus:SetFontObject("SystemFont_Shadow_Small")
	VCBnameTextFocus:SetHeight(FocusFrameSpellBar.Text:GetHeight())
	VCBnameTextFocus:Hide()
	VCBcurrentTimeTextFocus = FocusFrameSpellBar:CreateFontString("VCBcurrentTimeTextFocus", "OVERLAY", nil)
	VCBcurrentTimeTextFocus:SetFontObject("SystemFont_Shadow_Small")
	VCBcurrentTimeTextFocus:SetHeight(FocusFrameSpellBar.Text:GetHeight())
	VCBcurrentTimeTextFocus:Hide()
	VCBtotalTimeTextFocus = FocusFrameSpellBar:CreateFontString("VCBtotalTimeTextFocus", "OVERLAY", nil)
	VCBtotalTimeTextFocus:SetFontObject("SystemFont_Shadow_Small")
	VCBtotalTimeTextFocus:SetHeight(FocusFrameSpellBar.Text:GetHeight())
	VCBtotalTimeTextFocus:Hide()
	VCBbothTimeTextFocus = FocusFrameSpellBar:CreateFontString("VCBbothTimeTextFocus", "OVERLAY", nil)
	VCBbothTimeTextFocus:SetFontObject("SystemFont_Shadow_Small")
	VCBbothTimeTextFocus:SetHeight(FocusFrameSpellBar.Text:GetHeight())
	VCBbothTimeTextFocus:Hide()
-- Hooking Time part 1 --
	FocusFrameSpellBar:HookScript("OnShow", function(self)
		NameTextPosition(self, "NameText", VCBnameTextFocus)
		CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeTextFocus)
		CastingTextPosition(self, "BothTimeText", VCBbothTimeTextFocus)
		CastingTextPosition(self, "TotalTimeText", VCBtotalTimeTextFocus)
	end)
-- Hooking Time part 2 --
	FocusFrameSpellBar:HookScript("OnUpdate", function(self)
		self.Text:SetAlpha(0)
		VCBnameTextFocus:SetText(self.Text:GetText())
		AscendingDescendingSec(self)
		CastBarColor(self)
		if VCBrFocus["TotalTimeText"]["Decimals"] == 2 then
			if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.2f 秒", self.maxValue)
			elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 1 then
			if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.1f 秒", self.maxValue)
			elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 0 then
			if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.0f 秒", self.maxValue)
			elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end)
end
-- SUF interaction --
local function vcbSufCoOp_Focus()
-- castbar --
	SUFUnitfocusvcbCastbar = CreateFrame("StatusBar", "SUFUnitfocusvcbCastbar", SUFUnitfocus, "SmallCastingBarFrameTemplate")
	SUFUnitfocusvcbCastbar:SetSize(150, 10)
	SUFUnitfocusvcbCastbar:ClearAllPoints()
	SUFUnitfocusvcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
	SUFUnitfocusvcbCastbar:SetScale(VCBrFocus["Scale"]/100)
	SUFUnitfocusvcbCastbar:OnLoad("focus", true, true)
-- texts --
	VCBnameTextFocus = SUFUnitfocusvcbCastbar:CreateFontString("VCBnameTextFocus", "OVERLAY", nil)
	VCBnameTextFocus:SetFontObject("SystemFont_Shadow_Small")
	VCBnameTextFocus:SetHeight(SUFUnitfocusvcbCastbar.Text:GetHeight())
	VCBnameTextFocus:Hide()
	VCBcurrentTimeTextFocus = SUFUnitfocusvcbCastbar:CreateFontString("VCBcurrentTimeTextFocus", "OVERLAY", nil)
	VCBcurrentTimeTextFocus:SetFontObject("SystemFont_Shadow_Small")
	VCBcurrentTimeTextFocus:SetHeight(SUFUnitfocusvcbCastbar.Text:GetHeight())
	VCBcurrentTimeTextFocus:Hide()
	VCBtotalTimeTextFocus = SUFUnitfocusvcbCastbar:CreateFontString("VCBtotalTimeTextFocus", "OVERLAY", nil)
	VCBtotalTimeTextFocus:SetFontObject("SystemFont_Shadow_Small")
	VCBtotalTimeTextFocus:SetHeight(SUFUnitfocusvcbCastbar.Text:GetHeight())
	VCBtotalTimeTextFocus:Hide()
	VCBbothTimeTextFocus = SUFUnitfocusvcbCastbar:CreateFontString("VCBbothTimeTextFocus", "OVERLAY", nil)
	VCBbothTimeTextFocus:SetFontObject("SystemFont_Shadow_Small")
	VCBbothTimeTextFocus:SetHeight(SUFUnitfocusvcbCastbar.Text:GetHeight())
	VCBbothTimeTextFocus:Hide()
-- Hooking Time part 1 --
	SUFUnitfocusvcbCastbar:HookScript("OnShow", function(self)
		SUFUnitfocusvcbCastbar:ClearAllPoints()
		SUFUnitfocusvcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
		SUFUnitfocusvcbCastbar:SetScale(VCBrFocus["Scale"]/100)
		CastBarColor(self)
		NameTextPosition(self, "NameText", VCBnameTextFocus)
		CastingTextPosition(self, "CurrentTimeText", VCBcurrentTimeTextFocus)
		CastingTextPosition(self, "BothTimeText", VCBbothTimeTextFocus)
		CastingTextPosition(self, "TotalTimeText", VCBtotalTimeTextFocus)
	end)
-- Hooking Time part 2 --
	SUFUnitfocusvcbCastbar:HookScript("OnUpdate", function(self)
		self.Text:SetAlpha(0)
		VCBnameTextFocus:SetText(self.Text:GetText())
		AscendingDescendingSec(self)
		if VCBrFocus["TotalTimeText"]["Decimals"] == 2 then
			if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.2f 秒", self.maxValue)
			elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 1 then
			if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.1f 秒", self.maxValue)
			elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrFocus["TotalTimeText"]["Decimals"] == 0 then
			if VCBrFocus["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.0f 秒", self.maxValue)
			elseif VCBrFocus["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextFocus:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end)
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		IconShieldVisibility()
		if not VCBrFocus["Unlock"] and VCBrFocus["otherAdddon"] == "無" then
			AloneFocusSpellBar()
		elseif VCBrFocus["Unlock"] and VCBrFocus["otherAdddon"] == "無" then
			-- extra hooking --
			FocusFrameSpellBar:HookScript("OnUpdate", function(self)
				self:SetScale(VCBrFocus["Scale"]/100)
				self:ClearAllPoints()
				self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
			end)
			AloneFocusSpellBar()
		elseif VCBrFocus["Unlock"] and VCBrFocus["otherAdddon"] == "Shadowed Unit Frame" then
			SUFUnitfocus:HookScript("OnShow", function(self)
				local classFilename = UnitClassBase("focus")
				if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
			end)
			vcbSufCoOp_Focus()
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if FocusFrame:IsShown() then
			local classFilename = UnitClassBase("focus")
			if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
		elseif SUFUnitfocus ~= nil and VCBrFocus["otherAdddon"] == "Shadowed Unit Frame" and SUFUnitfocus:IsShown() then
			SUFUnitfocusvcbCastbar:SetUnit(nil, true, true)
			SUFUnitfocusvcbCastbar:PlayFinishAnim()
			SUFUnitfocusvcbCastbar:SetUnit("focus", true, true)
			local classFilename = UnitClassBase("focus")
			if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
		end
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
