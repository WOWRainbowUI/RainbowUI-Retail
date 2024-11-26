-- Position of the Name Text --
local function NameTextPosition(self, var1, var2)
	if VCBrTarget[var1] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Position of the Casting Texts --
local function CastingTextPosition(self, var1, var2)
	if VCBrTarget[var1]["Position"] == "左上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "左" then
		var2:ClearAllPoints()
		var2:SetPoint("LEFT", self, "LEFT", 4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "左下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOM", self, "TOP", 0, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "中" then
		var2:ClearAllPoints()
		var2:SetPoint("CENTER", self, "CENTER", 0, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOP", self, "BOTTOM", 0, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "右上" then
		var2:ClearAllPoints()
		var2:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "右" then
		var2:ClearAllPoints()
		var2:SetPoint("RIGHT", self, "RIGHT", -4, 0)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "右下" then
		var2:ClearAllPoints()
		var2:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
		if not var2:IsShown() then var2:Show() end
	elseif VCBrTarget[var1]["Position"] == "隱藏" then
		if var2:IsShown() then var2:Hide() end
	end
end
-- Ascending, Descending and Sec --
local function AscendingDescendingSec(self)
	if self.casting then
		if VCBrTarget["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "正數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "正數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "倒數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
				end
			end
		end
	elseif self.channeling then
		if VCBrTarget["CurrentTimeText"]["Decimals"] == 2 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
			if VCBrTarget["CurrentTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f 秒", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f 秒", VCBdescending)
				end
			elseif VCBrTarget["CurrentTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["CurrentTimeText"]["Direction"] == "倒數" or VCBrTarget["CurrentTimeText"]["Direction"] == "兩者" then
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
				elseif VCBrTarget["CurrentTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
				end
			end
		end
		if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
			if VCBrTarget["BothTimeText"]["Sec"] == "顯示" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
					local VCBdescending = self.maxValue - self.value
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
				end
			elseif VCBrTarget["BothTimeText"]["Sec"] == "隱藏" then
				if VCBrTarget["BothTimeText"]["Direction"] == "倒數" or VCBrTarget["BothTimeText"]["Direction"] == "兩者" then
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				elseif VCBrTarget["BothTimeText"]["Direction"] == "正數" then
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
		if VCBrTarget["Color"] == "預設顏色" then
			self:SetStatusBarDesaturated(false)
			self:SetStatusBarColor(1, 1, 1, 1)
		elseif VCBrTarget["Color"] == "職業顏色" then
			self:SetStatusBarDesaturated(true)
			self:SetStatusBarColor(vcbClassColorTarget:GetRGB())
		end
	else
		self:SetStatusBarDesaturated(false)
		self:SetStatusBarColor(1, 1, 1, 1)
	end
end
-- icon and shield visibility --
local function IconShieldVisibility()
	if VCBrTarget["Icon"] == "顯示圖示 & 盾牌" then
		if not TargetFrameSpellBar.Icon:IsShown() then TargetFrameSpellBar.Icon:Show() end
		if not TargetFrameSpellBar.showShield then TargetFrameSpellBar.showShield = true end
	elseif VCBrTarget["Icon"] == "隱藏圖示 & 盾牌" then
		if TargetFrameSpellBar.Icon:IsShown() then TargetFrameSpellBar.Icon:Hide() end
		if TargetFrameSpellBar.showShield then TargetFrameSpellBar.showShield = false end
	elseif VCBrTarget["Icon"] == "只隱藏圖示" then
		if TargetFrameSpellBar.Icon:IsShown() then TargetFrameSpellBar.Icon:Hide() end
		if not TargetFrameSpellBar.showShield then TargetFrameSpellBar.showShield = true end
	end
end
-- hooking time --
local function AloneTargetSpellBar()
-- Text --
	VCBnameTextTarget = TargetFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
	VCBnameTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBnameTextTarget:SetHeight(TargetFrameSpellBar.Text:GetHeight())
	VCBnameTextTarget:Hide()
	VCBcurrentTimeTextTarget = TargetFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
	VCBcurrentTimeTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBcurrentTimeTextTarget:SetHeight(TargetFrameSpellBar.Text:GetHeight())
	VCBcurrentTimeTextTarget:Hide()
	VCBtotalTimeTextTarget = TargetFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
	VCBtotalTimeTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBtotalTimeTextTarget:SetHeight(TargetFrameSpellBar.Text:GetHeight())
	VCBtotalTimeTextTarget:Hide()
	VCBbothTimeTextTarget = TargetFrameSpellBar:CreateFontString(nil, "OVERLAY", nil)
	VCBbothTimeTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBbothTimeTextTarget:SetHeight(TargetFrameSpellBar.Text:GetHeight())
	VCBbothTimeTextTarget:Hide()
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
			if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.2f 秒", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.1f 秒", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.0f 秒", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end)
end
-- SUF interaction --
local function vcbSufCoOp_Traget()
-- castbar --
	SUFUnittargetvcbCastbar = CreateFrame("StatusBar", "SUFUnittargetvcbCastbar", SUFUnittarget, "SmallCastingBarFrameTemplate")
	SUFUnittargetvcbCastbar:SetSize(150, 10)
	SUFUnittargetvcbCastbar:ClearAllPoints()
	SUFUnittargetvcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
	SUFUnittargetvcbCastbar:SetScale(VCBrTarget["Scale"]/100)
	SUFUnittargetvcbCastbar:OnLoad("target", true, true)
-- Text --
	VCBnameTextTarget = SUFUnittargetvcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBnameTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBnameTextTarget:SetHeight(SUFUnittargetvcbCastbar.Text:GetHeight())
	VCBnameTextTarget:Hide()
	VCBcurrentTimeTextTarget = SUFUnittargetvcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBcurrentTimeTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBcurrentTimeTextTarget:SetHeight(SUFUnittargetvcbCastbar.Text:GetHeight())
	VCBcurrentTimeTextTarget:Hide()
	VCBtotalTimeTextTarget = SUFUnittargetvcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBtotalTimeTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBtotalTimeTextTarget:SetHeight(SUFUnittargetvcbCastbar.Text:GetHeight())
	VCBtotalTimeTextTarget:Hide()
	VCBbothTimeTextTarget = SUFUnittargetvcbCastbar:CreateFontString(nil, "OVERLAY", nil)
	VCBbothTimeTextTarget:SetFontObject("SystemFont_Shadow_Small")
	VCBbothTimeTextTarget:SetHeight(SUFUnittargetvcbCastbar.Text:GetHeight())
	VCBbothTimeTextTarget:Hide()
-- Hooking Time part 1 --
	SUFUnittargetvcbCastbar:HookScript("OnShow", function(self)
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
	SUFUnittargetvcbCastbar:HookScript("OnUpdate", function(self)
		self.Text:SetAlpha(0)
		VCBnameTextTarget:SetText(self.Text:GetText())
		AscendingDescendingSec(self)
		if VCBrTarget["TotalTimeText"]["Decimals"] == 2 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.2f 秒", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.1f 秒", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
			if VCBrTarget["TotalTimeText"]["Sec"] == "顯示" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.0f 秒", self.maxValue)
			elseif VCBrTarget["TotalTimeText"]["Sec"] == "隱藏" and self.maxValue ~= nil then
				VCBtotalTimeTextTarget:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end)
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		IconShieldVisibility()
		if not VCBrTarget["Unlock"] and VCBrTarget["otherAdddon"] == "無" then
			AloneTargetSpellBar()
		elseif VCBrTarget["Unlock"] and VCBrTarget["otherAdddon"] == "無" then
			-- extra hooking --
			TargetFrameSpellBar:HookScript("OnUpdate", function(self)
				self:SetScale(VCBrTarget["Scale"]/100)
				self:ClearAllPoints()
				self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
			end)
			AloneTargetSpellBar()
		elseif VCBrTarget["Unlock"] and VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then
			SUFUnittarget:HookScript("OnShow", function(self)
				local classFilename = UnitClassBase("target")
				if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
			end)
			vcbSufCoOp_Traget()
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		if TargetFrame:IsShown() then
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		elseif SUFUnittarget ~= nil and VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" and SUFUnittarget:IsShown() then
			SUFUnittargetvcbCastbar:SetUnit(nil, true, true)
			SUFUnittargetvcbCastbar:PlayFinishAnim()
			SUFUnittargetvcbCastbar:SetUnit("target", true, true)
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		end
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
