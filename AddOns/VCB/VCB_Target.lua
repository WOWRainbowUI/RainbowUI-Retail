-- Blizzard Target Castbar --
local function TargetSpellBarTexts()
-- function for the texts --
	local function VCBtexts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(TargetFrameSpellBar.Text:GetHeight())
		var1:Hide()
	end
-- Name Text --
	VCBnameTextTarget = TargetFrameSpellBar:CreateFontString("VCBnameTextTarget", "OVERLAY", nil)
	VCBtexts(VCBnameTextTarget)
-- Current Time Text --
	VCBcurrentTimeTextTarget = TargetFrameSpellBar:CreateFontString("VCBcurrentTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBcurrentTimeTextTarget)
-- Total Time Text --
	VCBtotalTimeTextTarget = TargetFrameSpellBar:CreateFontString("VCBtotalTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBtotalTimeTextTarget)
-- Both Time Text --
	VCBbothTimeTextTarget = TargetFrameSpellBar:CreateFontString("VCBbothTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBbothTimeTextTarget)
end
-- SUF Target Castbar --
local function sufTargetSpellBarTexts()
-- castbar --
	SUFUnittargetvcbCastbar = CreateFrame("StatusBar", "SUFUnittargetvcbCastbar", SUFUnittarget, "SmallCastingBarFrameTemplate")
	SUFUnittargetvcbCastbar:SetSize(150, 10)
	SUFUnittargetvcbCastbar:ClearAllPoints()
	SUFUnittargetvcbCastbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
	SUFUnittargetvcbCastbar:SetScale(VCBrTarget["Scale"]/100)
	SUFUnittargetvcbCastbar:OnLoad("target", true, true)
-- function for the texts --
	local function VCBtexts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(SUFUnittargetvcbCastbar.Text:GetHeight())
		var1:Hide()
	end
-- Name Text --
	VCBnameTextTarget = SUFUnittargetvcbCastbar:CreateFontString("VCBnameTextTarget", "OVERLAY", nil)
	VCBtexts(VCBnameTextTarget)
-- Current Time Text --
	VCBcurrentTimeTextTarget = SUFUnittargetvcbCastbar:CreateFontString("VCBcurrentTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBcurrentTimeTextTarget)
-- Total Time Text --
	VCBtotalTimeTextTarget = SUFUnittargetvcbCastbar:CreateFontString("VCBtotalTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBtotalTimeTextTarget)
-- Both Time Text --
	VCBbothTimeTextTarget = SUFUnittargetvcbCastbar:CreateFontString("VCBbothTimeTextTarget", "OVERLAY", nil)
	VCBtexts(VCBbothTimeTextTarget)
end
-- Icon --
function chkTargetIconVisibility()
	if VCBrTarget["Icon"] == "Show Icon & Shiled" then
		function vcbTargetIconVisibility(self)
			if not self.Icon:IsShown() then self.Icon:Show() end
			if not self.showShield then self.showShield = true end
		end
	elseif VCBrTarget["Icon"] == "Hide Icon & Shiled" then
		function vcbTargetIconVisibility(self)
			if self.Icon:IsShown() then self.Icon:Hide() end
			if self.showShield then self.showShield = false end
		end
	elseif VCBrTarget["Icon"] == "Hide Only Icon" then
		function vcbTargetIconVisibility(self)
			if self.Icon:IsShown() then self.Icon:Hide() end
			if not self.showShield then self.showShield = true end
		end
	end
end
-- Name position --
function chkTargetNamePosition()
	if VCBrTarget["NameText"] == "Top Left" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			VCBnameTextTarget:SetJustifyH("LEFT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "Left" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("LEFT", self, "LEFT", 4, 0)
			VCBnameTextTarget:SetJustifyH("LEFT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "Bottom Left" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			VCBnameTextTarget:SetJustifyH("LEFT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "Top" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("BOTTOM", self, "TOP", 0, -2)
			VCBnameTextTarget:SetJustifyH("CENTER")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "Center" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("CENTER", self, "CENTER", 0, 0)
			VCBnameTextTarget:SetJustifyH("CENTER")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "Bottom" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("TOP", self, "BOTTOM", 0, 1)
			VCBnameTextTarget:SetJustifyH("CENTER")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "Top Right" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			VCBnameTextTarget:SetJustifyH("RIGHT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "Right" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			VCBnameTextTarget:SetJustifyH("RIGHT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "Bottom Right" then
		function vcbTargetNamePosition(self)
			VCBnameTextTarget:ClearAllPoints()
			VCBnameTextTarget:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			VCBnameTextTarget:SetJustifyH("RIGHT")
			if not VCBnameTextTarget:IsShown() then VCBnameTextTarget:Show() end
		end
	elseif VCBrTarget["NameText"] == "Hide" then
		function vcbTargetNamePosition(self)
			if VCBnameTextTarget:IsShown() then VCBnameTextTarget:Hide() end
		end
	end
end
-- Current time position --
function chkTargetCurrentTimePosition()
	if VCBrTarget["CurrentTimeText"]["Position"] == "Top Left" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "Left" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "Bottom Left" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "Top" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "Center" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "Bottom" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "Top Right" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "Right" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "Bottom Right" then
		function vcbTargetCurrentTimePosition(self)
			VCBcurrentTimeTextTarget:ClearAllPoints()
			VCBcurrentTimeTextTarget:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Show() end
		end
	elseif VCBrTarget["CurrentTimeText"]["Position"] == "Hide" then
		function vcbTargetCurrentTimePosition(self)
			if VCBcurrentTimeTextTarget:IsShown() then VCBcurrentTimeTextTarget:Hide() end
		end
	end
end
-- Both time position --
function chkTargetBothTimePosition()
	if VCBrTarget["BothTimeText"]["Position"] == "Top Left" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "Left" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "Bottom Left" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "Top" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "Center" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "Bottom" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "Top Right" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "Right" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "Bottom Right" then
		function vcbTargetBothTimePosition(self)	
			VCBbothTimeTextTarget:ClearAllPoints()
			VCBbothTimeTextTarget:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Show() end
		end
	elseif VCBrTarget["BothTimeText"]["Position"] == "Hide" then
		function vcbTargetBothTimePosition(self)	
			if VCBbothTimeTextTarget:IsShown() then VCBbothTimeTextTarget:Hide() end
		end
	end
end
-- Total Time position --
function chkTargetTotalTimePosition()
	if VCBrTarget["TotalTimeText"]["Position"] == "Top Left" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "Left" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "Bottom Left" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "Top" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "Center" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "Bottom" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "Top Right" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "Right" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "Bottom Right" then
		function vcbTargetTotalTimePosition(self)
			VCBtotalTimeTextTarget:ClearAllPoints()
			VCBtotalTimeTextTarget:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Show() end
		end
	elseif VCBrTarget["TotalTimeText"]["Position"] == "Hide" then
		function vcbTargetTotalTimePosition(self)
			if VCBtotalTimeTextTarget:IsShown() then VCBtotalTimeTextTarget:Hide() end
		end
	end
end
-- Current time update --
function chkTargetCurrentTimeUpdate()
	if VCBrTarget["CurrentTimeText"]["Decimals"] == 2 then
		if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f sec", self.value)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.2f", self.value)
				end
			end
		end
	elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 1 then
		if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f sec", self.value)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.1f", self.value)
				end
			end
		end
	elseif VCBrTarget["CurrentTimeText"]["Decimals"] == 0 then
		if VCBrTarget["CurrentTimeText"]["Sec"] == "Show" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f sec", self.value)
				end
			end
		elseif VCBrTarget["CurrentTimeText"]["Sec"] == "Hide" then
			if VCBrTarget["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbTargetCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
					end
				end
			elseif VCBrTarget["CurrentTimeText"]["Direction"] == "Both" then
				function vcbTargetCurrentTimeUpdate(self)
					VCBcurrentTimeTextTarget:SetFormattedText("%.0f", self.value)
				end
			end
		end
	end
end
-- Both time update --
function chkTargetBothTimeUpdate()
	if VCBrTarget["BothTimeText"]["Decimals"] == 2 then
		if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
			if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Both" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
			if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Both" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrTarget["BothTimeText"]["Decimals"] == 1 then
		if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
			if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Both" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
			if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Both" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrTarget["BothTimeText"]["Decimals"] == 0 then
		if VCBrTarget["BothTimeText"]["Sec"] == "Show" then
			if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Both" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
				end
			end
		elseif VCBrTarget["BothTimeText"]["Sec"] == "Hide" then
			if VCBrTarget["BothTimeText"]["Direction"] == "Ascending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Descending" then
				function vcbTargetBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					end
				end
			elseif VCBrTarget["BothTimeText"]["Direction"] == "Both" then
				function vcbTargetBothTimeUpdate(self)
					VCBbothTimeTextTarget:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				end
			end
		end
	end
end
-- Total time update --
function chkTargetTotalTimeUpdate()
	if VCBrTarget["TotalTimeText"]["Sec"] == "Show" then
		if VCBrTarget["TotalTimeText"]["Decimals"] == 2 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.2f sec", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.1f sec", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.0f sec", self.maxValue)
			end
		end
	elseif VCBrTarget["TotalTimeText"]["Sec"] == "Hide" then
		if VCBrTarget["TotalTimeText"]["Decimals"] == 2 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 1 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrTarget["TotalTimeText"]["Decimals"] == 0 then
			function vcbTargetTotalTimeUpdate(self)
				VCBtotalTimeTextTarget:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end
end
-- Coloring the bar --
function chkTargetCastbarColor()
	if VCBrTarget["Color"] == "Default Color" then
		function vcbTargetCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	elseif VCBrTarget["Color"] == "Class' Color" then
		function vcbTargetCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(true)
				self:SetStatusBarColor(vcbClassColorTarget:GetRGB())
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	end
end
-- Position of  the bar --
function vcbTargetCastbarPosition(self)
	self:SetScale(VCBrTarget["Scale"]/100)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		if VCBrTarget["otherAdddon"] == "None" then
			TargetSpellBarTexts()
			if VCBrTarget["Unlock"] then
				TargetFrameSpellBar:HookScript("OnUpdate", function(self)
					vcbTargetCastbarPosition(self)
				end)
			end
		elseif VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then
			sufTargetSpellBarTexts()
			SUFUnittargetvcbCastbar:HookScript("OnUpdate", function(self)
				vcbTargetCastbarPosition(self)
			end)
		end
			chkTargetIconVisibility()
			chkTargetNamePosition()
			chkTargetCurrentTimePosition()
			chkTargetBothTimePosition()
			chkTargetTotalTimePosition()
			chkTargetCurrentTimeUpdate()
			chkTargetBothTimeUpdate()
			chkTargetTotalTimeUpdate()
			chkTargetCastbarColor()
		if VCBrTarget["otherAdddon"] == "None" then
			TargetFrameSpellBar:HookScript("OnShow", function(self)
				VCBnameTextTarget:SetWidth(self:GetWidth())
				vcbTargetNamePosition(self)
				vcbTargetCurrentTimePosition(self)
				vcbTargetBothTimePosition(self)
				vcbTargetTotalTimePosition(self)
			end)
			TargetFrameSpellBar:HookScript("OnUpdate", function(self)
				self.Text:SetAlpha(0)
				VCBnameTextTarget:SetText(self.Text:GetText())
				if self.value ~= nil and self.maxValue ~= nil then
					vcbTargetCurrentTimeUpdate(self)
					vcbTargetBothTimeUpdate(self)
					vcbTargetTotalTimeUpdate(self)
					vcbTargetCastbarColor(self)
				end
			end)
		elseif VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then
			SUFUnittargetvcbCastbar:HookScript("OnShow", function(self)
				VCBnameTextTarget:SetWidth(self:GetWidth())
				vcbTargetNamePosition(self)
				vcbTargetCurrentTimePosition(self)
				vcbTargetBothTimePosition(self)
				vcbTargetTotalTimePosition(self)
			end)
			SUFUnittargetvcbCastbar:HookScript("OnUpdate", function(self)
				self.Text:SetAlpha(0)
				VCBnameTextTarget:SetText(self.Text:GetText())
				if self.value ~= nil and self.maxValue ~= nil then
					vcbTargetCurrentTimeUpdate(self)
					vcbTargetBothTimeUpdate(self)
					vcbTargetTotalTimeUpdate(self)
					vcbTargetCastbarColor(self)
				end
			end)
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
