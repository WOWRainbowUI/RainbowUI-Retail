-- function for the texts --
local function VCBtexts(var1)
	var1:SetFontObject("GameFontHighlightSmall")
	var1:SetHeight(PlayerCastingBarFrame.Text:GetHeight())
	var1:Hide()
end
-- Name Text --
VCBnameText = PlayerCastingBarFrame:CreateFontString("VCBnameText", "OVERLAY", nil)
VCBtexts(VCBnameText)
-- Current Time Text --
VCBcurrentTimeText = PlayerCastingBarFrame:CreateFontString("VCBcurrentTimeText", "OVERLAY", nil)
VCBtexts(VCBcurrentTimeText)
-- Total Time Text --
VCBtotalTimeText = PlayerCastingBarFrame:CreateFontString("VCBtotalTimeText", "OVERLAY", nil)
VCBtexts(VCBtotalTimeText)
-- Both Time Text --
VCBbothTimeText = PlayerCastingBarFrame:CreateFontString("VCBbothTimeText", "OVERLAY", nil)
VCBtexts(VCBbothTimeText)
-- Copy Texture of Spell's Icon --
VCBiconSpell = PlayerCastingBarFrame:CreateTexture("VCBiconSpell", "ARTWORK", nil, 0)
VCBiconSpell:SetWidth(PlayerCastingBarFrame.Icon:GetWidth())
VCBiconSpell:SetHeight(PlayerCastingBarFrame.Icon:GetHeight())
VCBiconSpell:SetScale(1.3)
VCBiconSpell:Hide()
-- Texture of Spell's Shield Left --
VCBshieldSpellLeft = PlayerCastingBarFrame:CreateTexture("VCBshieldSpellLeft", "BACKGROUND", nil, 0)
VCBshieldSpellLeft:SetAtlas("UI-CastingBar-Shield", false)
VCBshieldSpellLeft:SetPoint("CENTER", PlayerCastingBarFrame.Icon, "CENTER", 0, -3)
VCBshieldSpellLeft:SetWidth(36)
VCBshieldSpellLeft:SetHeight(40)
VCBshieldSpellLeft:SetScale(1)
VCBshieldSpellLeft:SetBlendMode("BLEND")
VCBshieldSpellLeft:SetAlpha(0.85)
VCBshieldSpellLeft:Hide()
-- Texture of Spell's Shield Right --
VCBshieldSpellRight = PlayerCastingBarFrame:CreateTexture("VCBshieldSpellRight", "BACKGROUND", nil, 0)
VCBshieldSpellRight:SetAtlas("UI-CastingBar-Shield", false)
VCBshieldSpellRight:SetPoint("CENTER", VCBiconSpell, "CENTER", 0, -3)
VCBshieldSpellRight:SetWidth(36)
VCBshieldSpellRight:SetHeight(40)
VCBshieldSpellRight:SetScale(1)
VCBshieldSpellRight:SetBlendMode("BLEND")
VCBshieldSpellRight:SetAlpha(0.85)
VCBshieldSpellRight:Hide()
-- icon & shield --
local function IconShieldVisibility()
	PlayerCastingBarFrame.Icon:SetScale(2.5) -- 圖示大小
	if PlayerCastingBarFrame.showShield then PlayerCastingBarFrame.showShield = false end
	if VCBrPlayer["Icon"] == "左" then
		function vcbPlayerIconVisibility(self)
			self.Icon:ClearAllPoints()
			self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -2) -- 圖示位置
			if not self.Icon:IsShown() then self.Icon:Show() end
			if self.barType == "uninterruptable" then
				self.Icon:ClearAllPoints()
				self.Icon:SetPoint("RIGHT", self, "LEFT", -8, -2) -- 圖示位置
				if not VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Show() end
			else
				self.Icon:ClearAllPoints()
				self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -2) -- 圖示位置
				if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
			end
			if VCBiconSpell:IsShown() then VCBiconSpell:Hide() end
			if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
		end
	elseif VCBrPlayer["Icon"] == "右" then
		function vcbPlayerIconVisibility(self)
			VCBiconSpell:ClearAllPoints()
			VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
			VCBiconSpell:SetTexture(self.Icon:GetTextureFileID())
			if not VCBiconSpell:IsShown() then VCBiconSpell:Show() end
			if self.barType == "uninterruptable" then
				VCBiconSpell:ClearAllPoints()
				VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 8, -4)
				if not VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Show() end
			else
				VCBiconSpell:ClearAllPoints()
				VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
				if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
			end
			if self.Icon:IsShown() then self.Icon:Hide() end
			if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
		end
	elseif VCBrPlayer["Icon"] == "左和右" then
		function vcbPlayerIconVisibility(self)
			self.Icon:ClearAllPoints()
			self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -4)
			if not self.Icon:IsShown() then self.Icon:Show() end
			VCBiconSpell:ClearAllPoints()
			VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
			VCBiconSpell:SetTexture(self.Icon:GetTextureFileID())
			if not VCBiconSpell:IsShown() then VCBiconSpell:Show() end
			VCBiconSpell:SetTexture(self.Icon:GetTextureFileID())
			if self.barType == "uninterruptable" then
				self.Icon:ClearAllPoints()
				self.Icon:SetPoint("RIGHT", self, "LEFT", -8, -4)
				if not VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Show() end
				VCBiconSpell:ClearAllPoints()
				VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 8, -4)
				if not VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Show() end
			else
				self.Icon:ClearAllPoints()
				self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -4)
				if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
				VCBiconSpell:ClearAllPoints()
				VCBiconSpell:SetPoint("LEFT", self, "RIGHT", 2, -4)
				if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
			end
		end
	elseif VCBrPlayer["Icon"] == "隱藏" then
		function vcbPlayerIconVisibility(self)
			if self.Icon:IsShown() then self.Icon:Hide() end
			if VCBiconSpell:IsShown() then VCBiconSpell:Hide() end
			if VCBshieldSpellLeft:IsShown() then VCBshieldSpellLeft:Hide() end
			if VCBshieldSpellRight:IsShown() then VCBshieldSpellRight:Hide() end
		end
	end
end
-- Name position --
local function NamePosition()
	if VCBrPlayer["NameText"] == "左上" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "左" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "左下" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "上" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "中" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "下" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "右上" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "右" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "右下" then
		function vcbPlayerNamePosition(self)
			VCBnameText:ClearAllPoints()
			VCBnameText:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBnameText:IsShown() then VCBnameText:Show() end
		end
	elseif VCBrPlayer["NameText"] == "隱藏" then
		function vcbPlayerNamePosition(self)
			if VCBnameText:IsShown() then VCBnameText:Hide() end
		end
	end
end
-- Current Time position --
local function CurrentTimePosition()
	if VCBrPlayer["CurrentTimeText"]["Position"] == "左上" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "左" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "左下" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "上" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "中" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "下" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "右上" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "右" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "右下" then
		function vcbPlayerCurrentTimePosition(self)
			VCBcurrentTimeText:ClearAllPoints()
			VCBcurrentTimeText:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Show() end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Position"] == "隱藏" then
		function vcbPlayerCurrentTimePosition(self)
			if VCBcurrentTimeText:IsShown() then VCBcurrentTimeText:Hide() end
		end
	end
end
-- Both Time position --
local function BothTimePosition()
	if VCBrPlayer["BothTimeText"]["Position"] == "左上" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "左" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "左下" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "上" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "中" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "下" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "右上" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "右" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "右下" then
		function vcbPlayerBothTimePosition(self)
			VCBbothTimeText:ClearAllPoints()
			VCBbothTimeText:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBbothTimeText:IsShown() then VCBbothTimeText:Show() end
		end
	elseif VCBrPlayer["BothTimeText"]["Position"] == "隱藏" then
		function vcbPlayerBothTimePosition(self)
			if VCBbothTimeText:IsShown() then VCBbothTimeText:Hide() end
		end
	end
end
-- Total Time position --
local function TotalTimePosition()
	if VCBrPlayer["TotalTimeText"]["Position"] == "左上" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "左" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "左下" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "上" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "中" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "下" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "右上" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "右" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "右下" then
		function vcbPlayerTotalTimePosition(self)
			VCBtotalTimeText:ClearAllPoints()
			VCBtotalTimeText:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not VCBtotalTimeText:IsShown() then VCBtotalTimeText:Show() end
		end
	elseif VCBrPlayer["TotalTimeText"]["Position"] == "隱藏" then
		function vcbPlayerTotalTimePosition(self)
			if VCBtotalTimeText:IsShown() then VCBtotalTimeText:Hide() end
		end
	end
end
-- current time update --
local function CurrentTimeUpdate()
	if VCBrPlayer["CurrentTimeText"]["Decimals"] == 2 then
		if VCBrPlayer["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f 秒", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.2f 秒", self.value)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.2f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.2f", self.value)
				end
			end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Decimals"] == 1 then
		if VCBrPlayer["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.1f 秒", self.value)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.1f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.1f", self.value)
				end
			end
		end
	elseif VCBrPlayer["CurrentTimeText"]["Decimals"] == 0 then
		if VCBrPlayer["CurrentTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f 秒", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f 秒", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.0f 秒", self.value)
				end
			end
		elseif VCBrPlayer["CurrentTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["CurrentTimeText"]["Direction"] == "正數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "倒數" then
				function vcbCurrentTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBcurrentTimeText:SetFormattedText("%.0f", VCBdescending)
					elseif self.channeling then
						VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
					end
				end
			elseif VCBrPlayer["CurrentTimeText"]["Direction"] == "兩者" then
				function vcbCurrentTimeUpdate(self)
					VCBcurrentTimeText:SetFormattedText("%.0f", self.value)
				end
			end
		end
	end
end
-- both time update --
local function BothTimeUpdate()
	if VCBrPlayer["BothTimeText"]["Decimals"] == 2 then
		if VCBrPlayer["BothTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.2f/%.2f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrPlayer["BothTimeText"]["Decimals"] == 1 then
		if VCBrPlayer["BothTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.1f/%.1f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrPlayer["BothTimeText"]["Decimals"] == 0 then
		if VCBrPlayer["BothTimeText"]["Sec"] == "顯示" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.0f/%.0f 秒", self.value, self.maxValue)
				end
			end
		elseif VCBrPlayer["BothTimeText"]["Sec"] == "隱藏" then
			if VCBrPlayer["BothTimeText"]["Direction"] == "正數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "倒數" then
				function vcbBothTimeUpdate(self)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					elseif self.channeling then
						VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					end
				end
			elseif VCBrPlayer["BothTimeText"]["Direction"] == "兩者" then
				function vcbBothTimeUpdate(self)
					VCBbothTimeText:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				end
			end
		end
	end
end
-- total time update --
local function TotalTimeUpdate()
	if VCBrPlayer["TotalTimeText"]["Sec"] == "顯示" then
		if VCBrPlayer["TotalTimeText"]["Decimals"] == 2 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.2f 秒", self.maxValue)
			end
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 1 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.1f 秒", self.maxValue)
			end
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 0 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.0f 秒", self.maxValue)
			end
		end
	elseif VCBrPlayer["TotalTimeText"]["Sec"] == "隱藏" then
		if VCBrPlayer["TotalTimeText"]["Decimals"] == 2 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 1 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrPlayer["TotalTimeText"]["Decimals"] == 0 then
			function vcbTotalTimeUpdate(self)
				VCBtotalTimeText:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end
end
-- coloring the bar --
-- default color --
local function Color_Default(self)
	self:SetStatusBarDesaturated(false)
	self:SetStatusBarColor(1, 1, 1, 1)
	self.Spark:SetDesaturated(false)
	self.Spark:SetVertexColor(1, 1, 1, 1)
	self.ChannelShadow:SetDesaturated(false)
	self.ChannelShadow:SetVertexColor(1, 1, 1, 1)
	self.StandardGlow:SetDesaturated(false)
	self.StandardGlow:SetVertexColor(1, 1, 1, 1)
	self.Flash:SetDesaturated(false)
	self.Flash:SetVertexColor(1, 1, 1, 1)
end
-- class color --
local function Color_Class(self)
	self:SetStatusBarDesaturated(true)
	self:SetStatusBarColor(vcbClassColorPlayer:GetRGB())
	self.Spark:SetDesaturated(true)
	self.Spark:SetVertexColor(vcbClassColorPlayer:GetRGB())
	self.ChannelShadow:SetDesaturated(true)
	self.ChannelShadow:SetVertexColor(vcbClassColorPlayer:GetRGB())
	self.StandardGlow:SetDesaturated(true)
	self.StandardGlow:SetVertexColor(vcbClassColorPlayer:GetRGB())
	self.Flash:SetDesaturated(true)
	self.Flash:SetVertexColor(vcbClassColorPlayer:GetRGB())
end
-- Spell School color --
local function Color_SpellSchool(self)
	self:SetStatusBarDesaturated(true)
	self.Spark:SetDesaturated(true)
	self.ChannelShadow:SetDesaturated(true)
	self.StandardGlow:SetDesaturated(true)
	self.Flash:SetDesaturated(true)
	if vcbSpellSchool == 1 then
		self:SetStatusBarColor(vcbPhysicalColor:GetRGB())
		self.Spark:SetVertexColor(vcbPhysicalColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbPhysicalColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbPhysicalColor:GetRGB())
		self.Flash:SetVertexColor(vcbPhysicalColor:GetRGB())
	elseif vcbSpellSchool == 2 then
		self:SetStatusBarColor(vcbHolyColor:GetRGB())
		self.Spark:SetVertexColor(vcbHolyColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbHolyColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbHolyColor:GetRGB())
		self.Flash:SetVertexColor(vcbHolyColor:GetRGB())
	elseif vcbSpellSchool == 4 then
		self:SetStatusBarColor(vcbFireColor:GetRGB())
		self.Spark:SetVertexColor(vcbFireColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbFireColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbFireColor:GetRGB())
		self.Flash:SetVertexColor(vcbFireColor:GetRGB())
	elseif vcbSpellSchool == 8 then
		self:SetStatusBarColor(vcbNatureColor:GetRGB())
		self.Spark:SetVertexColor(vcbNatureColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbNatureColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbNatureColor:GetRGB())
		self.Flash:SetVertexColor(vcbNatureColor:GetRGB())
	elseif vcbSpellSchool == 16 then
		self:SetStatusBarColor(vcbFrostColor:GetRGB())
		self.Spark:SetVertexColor(vcbFrostColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbFrostColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbFrostColor:GetRGB())
		self.Flash:SetVertexColor(vcbFrostColor:GetRGB())
	elseif vcbSpellSchool == 32 then
		self:SetStatusBarColor(vcbShadowColor:GetRGB())
		self.Spark:SetVertexColor(vcbShadowColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbShadowColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbShadowColor:GetRGB())
		self.Flash:SetVertexColor(vcbShadowColor:GetRGB())
	elseif vcbSpellSchool == 64 then
		self:SetStatusBarColor(vcbArcaneColor:GetRGB())
		self.Spark:SetVertexColor(vcbArcaneColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbArcaneColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbArcaneColor:GetRGB())
		self.Flash:SetVertexColor(vcbArcaneColor:GetRGB())
	elseif vcbSpellSchool == 3 then
		self:SetStatusBarColor(vcbHolystrikeColor:GetRGB())
		self.Spark:SetVertexColor(vcbHolystrikeColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbHolystrikeColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbHolystrikeColor:GetRGB())
		self.Flash:SetVertexColor(vcbHolystrikeColor:GetRGB())
	elseif vcbSpellSchool == 5 then
		self:SetStatusBarColor(vcbFlamestrikeColor:GetRGB())
		self.Spark:SetVertexColor(vcbFlamestrikeColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbFlamestrikeColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbFlamestrikeColor:GetRGB())
		self.Flash:SetVertexColor(vcbFlamestrikeColor:GetRGB())
	elseif vcbSpellSchool == 6 then
		self:SetStatusBarColor(vcbRadiantColor:GetRGB())
		self.Spark:SetVertexColor(vcbRadiantColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbRadiantColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbRadiantColor:GetRGB())
		self.Flash:SetVertexColor(vcbRadiantColor:GetRGB())
	elseif vcbSpellSchool == 9 then
		self:SetStatusBarColor(vcbStormstrikeColor:GetRGB())
		self.Spark:SetVertexColor(vcbStormstrikeColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbStormstrikeColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbStormstrikeColor:GetRGB())
		self.Flash:SetVertexColor(vcbStormstrikeColor:GetRGB())
	elseif vcbSpellSchool == 10 then
		self:SetStatusBarColor(vcbHolystormColor:GetRGB())
		self.Spark:SetVertexColor(vcbHolystormColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbHolystormColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbHolystormColor:GetRGB())
		self.Flash:SetVertexColor(vcbHolystormColor:GetRGB())
	elseif vcbSpellSchool == 12 then
		self:SetStatusBarColor(vcbVolcanicColor:GetRGB())
		self.Spark:SetVertexColor(vcbVolcanicColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbVolcanicColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbVolcanicColor:GetRGB())
		self.Flash:SetVertexColor(vcbVolcanicColor:GetRGB())
	elseif vcbSpellSchool == 17 then
		self:SetStatusBarColor(vcbFroststrikeColor:GetRGB())
		self.Spark:SetVertexColor(vcbFroststrikeColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbFroststrikeColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbFroststrikeColor:GetRGB())
		self.Flash:SetVertexColor(vcbFroststrikeColor:GetRGB())
	elseif vcbSpellSchool == 18 then
		self:SetStatusBarColor(vcbHolyfrostColor:GetRGB())
		self.Spark:SetVertexColor(vcbHolyfrostColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbHolyfrostColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbHolyfrostColor:GetRGB())
		self.Flash:SetVertexColor(vcbHolyfrostColor:GetRGB())
	elseif vcbSpellSchool == 20 then
		self:SetStatusBarColor(vcbFrostfireColor:GetRGB())
		self.Spark:SetVertexColor(vcbFrostfireColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbFrostfireColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbFrostfireColor:GetRGB())
		self.Flash:SetVertexColor(vcbFrostfireColor:GetRGB())
	elseif vcbSpellSchool == 24 then
		self:SetStatusBarColor(vcbFroststormColor:GetRGB())
		self.Spark:SetVertexColor(vcbFroststormColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbFroststormColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbFroststormColor:GetRGB())
		self.Flash:SetVertexColor(vcbFroststormColor:GetRGB())
	elseif vcbSpellSchool == 33 then
		self:SetStatusBarColor(vcbShadowstrikeColor:GetRGB())
		self.Spark:SetVertexColor(vcbShadowstrikeColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbShadowstrikeColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbShadowstrikeColor:GetRGB())
		self.Flash:SetVertexColor(vcbShadowstrikeColor:GetRGB())
	elseif vcbSpellSchool == 34 then
		self:SetStatusBarColor(vcbTwilightColor:GetRGB())
		self.Spark:SetVertexColor(vcbTwilightColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbTwilightColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbTwilightColor:GetRGB())
		self.Flash:SetVertexColor(vcbTwilightColor:GetRGB())
	elseif vcbSpellSchool == 36 then
		self:SetStatusBarColor(vcbShadowflameColor:GetRGB())
		self.Spark:SetVertexColor(vcbShadowflameColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbShadowflameColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbShadowflameColor:GetRGB())
		self.Flash:SetVertexColor(vcbShadowflameColor:GetRGB())
	elseif vcbSpellSchool == 40 then
		self:SetStatusBarColor(vcbPlagueColor:GetRGB())
		self.Spark:SetVertexColor(vcbPlagueColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbPlagueColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbPlagueColor:GetRGB())
		self.Flash:SetVertexColor(vcbPlagueColor:GetRGB())
	elseif vcbSpellSchool == 48 then
		self:SetStatusBarColor(vcbShadowfrostColor:GetRGB())
		self.Spark:SetVertexColor(vcbShadowfrostColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbShadowfrostColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbShadowfrostColor:GetRGB())
		self.Flash:SetVertexColor(vcbShadowfrostColor:GetRGB())
	elseif vcbSpellSchool == 65 then
		self:SetStatusBarColor(vcbSpellstrikeColor:GetRGB())
		self.Spark:SetVertexColor(vcbSpellstrikeColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbSpellstrikeColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbSpellstrikeColor:GetRGB())
		self.Flash:SetVertexColor(vcbSpellstrikeColor:GetRGB())
	elseif vcbSpellSchool == 66 then
		self:SetStatusBarColor(vcbDivineColor:GetRGB())
		self.Spark:SetVertexColor(vcbDivineColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbDivineColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbDivineColor:GetRGB())
		self.Flash:SetVertexColor(vcbDivineColor:GetRGB())
	elseif vcbSpellSchool == 68 then
		self:SetStatusBarColor(vcbSpellfireColor:GetRGB())
		self.Spark:SetVertexColor(vcbSpellfireColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbSpellfireColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbSpellfireColor:GetRGB())
		self.Flash:SetVertexColor(vcbSpellfireColor:GetRGB())
	elseif vcbSpellSchool == 72 then
		self:SetStatusBarColor(vcbAstralColor:GetRGB())
		self.Spark:SetVertexColor(vcbAstralColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbAstralColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbAstralColor:GetRGB())
		self.Flash:SetVertexColor(vcbAstralColor:GetRGB())
	elseif vcbSpellSchool == 80 then
		self:SetStatusBarColor(vcbSpellfrostColor:GetRGB())
		self.Spark:SetVertexColor(vcbSpellfrostColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbSpellfrostColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbSpellfrostColor:GetRGB())
		self.Flash:SetVertexColor(vcbSpellfrostColor:GetRGB())
	elseif vcbSpellSchool == 96 then
		self:SetStatusBarColor(vcbSpellshadowColor:GetRGB())
		self.Spark:SetVertexColor(vcbSpellshadowColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbSpellshadowColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbSpellshadowColor:GetRGB())
		self.Flash:SetVertexColor(vcbSpellshadowColor:GetRGB())
	elseif vcbSpellSchool == 28 then
		self:SetStatusBarColor(vcbElementalColor:GetRGB())
		self.Spark:SetVertexColor(vcbElementalColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbElementalColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbElementalColor:GetRGB())
		self.Flash:SetVertexColor(vcbElementalColor:GetRGB())
	elseif vcbSpellSchool == 62 then
		self:SetStatusBarColor(vcbChromaticColor:GetRGB())
		self.Spark:SetVertexColor(vcbChromaticColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbChromaticColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbChromaticColor:GetRGB())
		self.Flash:SetVertexColor(vcbChromaticColor:GetRGB())
	elseif vcbSpellSchool == 106 then
		self:SetStatusBarColor(vcbCosmicColor:GetRGB())
		self.Spark:SetVertexColor(vcbCosmicColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbCosmicColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbCosmicColor:GetRGB())
		self.Flash:SetVertexColor(vcbCosmicColor:GetRGB())
	elseif vcbSpellSchool == 126 then
		self:SetStatusBarColor(vcbMagicColor:GetRGB())
		self.Spark:SetVertexColor(vcbMagicColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbMagicColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbMagicColor:GetRGB())
		self.Flash:SetVertexColor(vcbMagicColor:GetRGB())
	elseif vcbSpellSchool == 127 or vcbSpellSchool == 124 then
		self:SetStatusBarColor(vcbChaosColor:GetRGB())
		self.Spark:SetVertexColor(vcbChaosColor:GetRGB())
		self.ChannelShadow:SetVertexColor(vcbChaosColor:GetRGB())
		self.StandardGlow:SetVertexColor(vcbChaosColor:GetRGB())
		self.Flash:SetVertexColor(vcbChaosColor:GetRGB())
	end
end
-- final function --
local function CastBarColor(self)
	if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
		if VCBrPlayer["Color"] == "預設顏色" then
			Color_Default(self)
		elseif VCBrPlayer["Color"] == "職業顏色" then
			Color_Class(self)
		elseif VCBrPlayer["Color"] == "法術類型顏色" then
			Color_SpellSchool(self)
		end
	else
		Color_Default(self)
	end
end
-- Some local variables --
local lagStart = 0
local lagEnd = 0
local lagTotal = 0
local statusMin = 0
local statusMax = 0
local lagWidth = 0
local lagBarWidth = 0
-- Spell Queue Window Bar --
local function VCBSpellQueueBar(var1)
	var1:SetAtlas("UI-CastingBar-Background", false, "NEAREST")
	var1:SetHeight(PlayerCastingBarFrame:GetHeight())
	var1:SetVertexColor(0, 1, 0)
	var1:SetAlpha(0.75)
	var1:Hide()
end
-- SpellQueue Bar 1 --
local VCBSpellQueueCastBar = PlayerCastingBarFrame:CreateTexture(nil, "BORDER", nil, 0)
VCBSpellQueueBar(VCBSpellQueueCastBar)
-- SpellQueue Bar 2 --
local VCBSpellQueueChannelBar = PlayerCastingBarFrame:CreateTexture(nil, "ARTWORK", nil, 7)
VCBSpellQueueBar(VCBSpellQueueChannelBar)
-- Player Casting SpellQueue Bar --
local function PlayerCastSpellQueueBar(arg3)
	local playerSpell1 = IsSpellKnownOrOverridesKnown(arg3)
	local playerSpell2 = IsPlayerSpell(arg3)
	if (playerSpell1 or playerSpell2) and VCBrPlayer["QueueBar"] == "顯示" then
		statusMin, statusMax = PlayerCastingBarFrame:GetMinMaxValues()
		local totalCastTime = statusMax - statusMin
		local spellQueueWindow = math.min(GetSpellQueueWindow() / 1000 / totalCastTime, 1)
		local spellQueueWidth = (PlayerCastingBarFrame:GetWidth() * spellQueueWindow) - lagBarWidth
		VCBSpellQueueCastBar:ClearAllPoints()
		VCBSpellQueueCastBar:SetWidth(spellQueueWidth)
		VCBSpellQueueCastBar:SetPoint("RIGHT", PlayerCastingBarFrame, "RIGHT", -lagBarWidth, 0)
		VCBSpellQueueCastBar:Show()
	end
end
-- Player Channeling SpellQueue Bar --
local function PlayerChannelSpellQueueBar(arg3)
	local playerSpell1 = IsSpellKnownOrOverridesKnown(arg3)
	local playerSpell2 = IsPlayerSpell(arg3)
	if (playerSpell1 or playerSpell2) and VCBrPlayer["QueueBar"] == "顯示" then
		statusMin, statusMax = PlayerCastingBarFrame:GetMinMaxValues()
		local totalCastTime = statusMax - statusMin
		local spellQueueWindow = math.min(GetSpellQueueWindow() / 1000 / totalCastTime, 1)
		local spellQueueWidth = (PlayerCastingBarFrame:GetWidth() * spellQueueWindow) - lagBarWidth
		VCBSpellQueueChannelBar:ClearAllPoints()
		VCBSpellQueueChannelBar:SetWidth(spellQueueWidth)
		VCBSpellQueueChannelBar:SetPoint("LEFT", PlayerCastingBarFrame, "LEFT", lagBarWidth, 0)
		VCBSpellQueueChannelBar:Show()
	end
end
-- function for the lag bars --
local function VCBlagBars(var1)
	var1:SetAtlas("UI-CastingBar-Background", false, "NEAREST")
	var1:SetHeight(PlayerCastingBarFrame:GetHeight())
	var1:SetVertexColor(1, 0, 0)
	var1:SetAlpha(0.75)
	var1:Hide()
end
-- Lag Bar 1 --
local VCBLagCastBar = PlayerCastingBarFrame:CreateTexture(nil, "BORDER", nil, 0)
VCBlagBars(VCBLagCastBar)
-- Lag Bar 2 --
local VCBLagChannelBar = PlayerCastingBarFrame:CreateTexture(nil, "ARTWORK", nil, 7)
VCBlagBars(VCBLagChannelBar)
-- Player Casting Latency Bar --
local function PlayerCastLagBar(arg3)
	lagBarWidth = 0
	local playerSpell1 = IsSpellKnownOrOverridesKnown(arg3)
	local playerSpell2 = IsPlayerSpell(arg3)
	if (playerSpell1 or playerSpell2) and VCBrPlayer["LagBar"] == "顯示" then
		lagEnd = GetTime()
		lagTotal = (lagEnd - lagStart)
		statusMin, statusMax = PlayerCastingBarFrame:GetMinMaxValues()
		lagWidth = lagTotal / (statusMax - statusMin)
		lagBarWidth = PlayerCastingBarFrame:GetWidth() * lagWidth
		if lagBarWidth == 0 then
			VCBLagCastBar:Hide()
		else
			VCBLagCastBar:ClearAllPoints()
			VCBLagCastBar:SetWidth(lagBarWidth)
			VCBLagCastBar:SetPoint("RIGHT", PlayerCastingBarFrame, "RIGHT", 0, 0)
			VCBLagCastBar:Show()
		end
	end
end
-- Player Channeling Latency Bar --
local function PlayerChannelLagBar(arg3)
	lagBarWidth = 0
	local playerSpell1 = IsSpellKnownOrOverridesKnown(arg3)
	local playerSpell2 = IsPlayerSpell(arg3)
	if (playerSpell1 or playerSpell2) and VCBrPlayer["LagBar"] == "顯示" then
		lagEnd = GetTime()
		lagTotal = (lagEnd - lagStart)
		statusMin, statusMax = PlayerCastingBarFrame:GetMinMaxValues()
		lagWidth = lagTotal / (statusMax - statusMin)
		lagBarWidth = PlayerCastingBarFrame:GetWidth() * lagWidth
		if lagBarWidth == 0 then
			VCBLagChannelBar:Hide()
		else
			VCBLagChannelBar:ClearAllPoints()
			VCBLagChannelBar:SetWidth(lagBarWidth)
			VCBLagChannelBar:SetPoint("LEFT", PlayerCastingBarFrame, "LEFT", 0, 0)
			VCBLagChannelBar:Show()
		end
	end
end
-- Creating the ticks for the player's castbar --
-- Create Ticks 3 --
local function Create3Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 3
	for i = 1, 3, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB3spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.8)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB3spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.8)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB3spark".. i-1, "LEFT", spaceTick, 0)
			tick:Hide()
		end
	end
end
-- Create Ticks 4 --
local function Create4Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 4
	for i = 1, 4, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB4spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.8)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB4spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.8)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB4spark".. i-1, "LEFT", spaceTick, 0)
			tick:Hide()
		end
	end
end
-- Create Ticks 5 --
local function Create5Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 5
	for i = 1, 5, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB5spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.8)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB5spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.8)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB5spark".. i-1, "LEFT", spaceTick, 0)
			tick:Hide()
		end
	end
end
-- Create Ticks 6 --
local function Create6Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 6
	for i = 1, 6, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB6spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.9)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB6spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.9)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB6spark".. i-1, "LEFT", spaceTick, 0)
			tick:Hide()
		end
	end
end
-- Create Ticks 7 --
local function Create7Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 7
	for i = 1, 7, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB7spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.9)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB7spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.9)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB7spark".. i-1, "LEFT", spaceTick, 0)
			tick:Hide()
		end
	end
end
-- Create Ticks 8 --
local function Create8Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 8
	for i = 1, 8, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB8spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.9)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB8spark"..i, "OVERLAY", nil, 7)
			if VCBrPlayer["Ticks"] == "顯示" or VCBrPlayer["Ticks"] == "現代" then
				tick:SetAtlas("ui-castingbar-empower-cursor", false)
				tick:SetDesaturated(false)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(12)
				tick:SetVertexColor(1, 1, 1, 1)
				tick:SetBlendMode("BLEND")
			elseif VCBrPlayer["Ticks"] == "經典" then
				tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
				tick:SetDesaturated(true)
				tick:SetHeight(PlayerCastingBarFrame:GetHeight())
				tick:SetWidth(8)
				tick:SetVertexColor(0.9, 0.9, 0.9, 0.9)
				tick:SetBlendMode("BLEND")
			end
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB8spark".. i-1, "LEFT", spaceTick, 0)
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
-- Mind Flay, Insanity --
	if arg3 == 391403 or arg3 == 47540 then
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
-- textures of the classic GCD --
local function ClassIcon(self)
	local a
	local b
	self:SetSwipeTexture("interface/hud/uiunitframeclassicons2x")
	if select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 1 then --Warrior
		a = CreateVector2D(0.478515625, 0.478515625) -- left, top
		b = CreateVector2D(0.712890625, 0.712890625) -- right, bottom
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 2 then --Paladin
		a = CreateVector2D(0.240234375, 0.240234375)
		b = CreateVector2D(0.474609375, 0.474609375)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 3 then --Hunter
		a = CreateVector2D(0.001953125, 0.240234375)
		b = CreateVector2D(0.236328125, 0.474609375)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 4 then --Rogue
		a = CreateVector2D(0.716796875, 0.240234375)
		b = CreateVector2D(0.951171875, 0.474609375)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 5 then --Priest
		a = CreateVector2D(0.478515625, 0.240234375)
		b = CreateVector2D(0.712890625, 0.474609375)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 6 then --Death Kight
		a = CreateVector2D(0.001953125, 0.236328125)
		b = CreateVector2D(0.001953125, 0.236328125)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 7 then --Shaman
		a = CreateVector2D(0.240234375, 0.478515625)
		b = CreateVector2D(0.474609375, 0.712890625)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 8 then --Mage
		a = CreateVector2D(0.001953125, 0.478515625)
		b = CreateVector2D(0.236328125, 0.712890625)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 9 then --Warlock
		a = CreateVector2D(0.240234375, 0.716796875)
		b = CreateVector2D(0.474609375, 0.951171875)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 10 then --Monk
		a = CreateVector2D(0.001953125, 0.716796875)
		b = CreateVector2D(0.236328125, 0.951171875)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 11 then --Druid
		a = CreateVector2D(0.478515625, 0.001953125)
		b = CreateVector2D(0.712890625, 0.236328125)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 12 then --Demon Hunter
		a = CreateVector2D(0.240234375, 0.001953125)
		b = CreateVector2D(0.474609375, 0.236328125)
	elseif select(3, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))) == 13 then --Evoker
		a = CreateVector2D(0.716796875, 0.001953125)
		b = CreateVector2D(0.951171875, 0.236328125)
	end
	self:SetTexCoordRange(a, b)
end
local function HeroIcon(self)
	local a
	local b
	self:SetSwipeTexture("interface/talentframe/talentsheroclassicons")
	local chkTalentID = C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID())
	local hero = C_ClassTalents.GetActiveHeroTalentSpec()
	local subTreeInfo = C_Traits.GetSubTreeInfo(chkTalentID, hero)
	if subTreeInfo.iconElementID == "talents-heroclass-deathknight-deathbringer" then
		a = CreateVector2D(0.00048828125, 0.0009765625)
		b = CreateVector2D(0.09814453125, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-deathknight-rideroftheapocalypse" then
		a = CreateVector2D(0.00048828125, 0.1982421875)
		b = CreateVector2D(0.09814453125, 0.3935546875)
	elseif subTreeInfo.iconElementID == "talents-heroclass-deathknight-sanlayn" then
		a = CreateVector2D(0.00048828125, 0.3955078125)
		b = CreateVector2D(0.09814453125, 0.5908203125)
	elseif subTreeInfo.iconElementID == "talents-heroclass-demonhunter-aldrachireaver" then
		a = CreateVector2D(0.00048828125, 0.5927734375)
		b = CreateVector2D(0.09814453125, 0.7880859375)
	elseif subTreeInfo.iconElementID == "talents-heroclass-demonhunter-felscarred" then
		a = CreateVector2D(0.00048828125, 0.7900390625)
		b = CreateVector2D(0.09814453125, 0.9853515625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-druid-druidoftheclaw" then
		a = CreateVector2D(0.09912109375, 0.0009765625)
		b = CreateVector2D(0.19677734375, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-druid-eluneschosen" then
		a = CreateVector2D(0.09912109375, 0.1982421875)
		b = CreateVector2D(0.19677734375, 0.3935546875)
	elseif subTreeInfo.iconElementID == "talents-heroclass-druid-keeperofthegrove" then
		a = CreateVector2D(0.09912109375, 0.3955078125)
		b = CreateVector2D(0.19677734375, 0.5908203125)
	elseif subTreeInfo.iconElementID == "talents-heroclass-druid-wildstalker" then
		a = CreateVector2D(0.09912109375, 0.5927734375)
		b = CreateVector2D(0.19677734375, 0.7880859375)
	elseif subTreeInfo.iconElementID == "talents-heroclass-evoker-chronowarden" then
		a = CreateVector2D(0.09912109375, 0.7900390625)
		b = CreateVector2D(0.19677734375, 0.9853515625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-evoker-flameshaper" then
		a = CreateVector2D(0.19775390625, 0.0009765625)
		b = CreateVector2D(0.29541015625, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-evoker-scalecommander" then
		a = CreateVector2D(0.19775390625, 0.1982421875)
		b = CreateVector2D(0.29541015625, 0.3935546875)
	elseif subTreeInfo.iconElementID == "talents-heroclass-hunter-darkranger" then
		a = CreateVector2D(0.19775390625, 0.3955078125)
		b = CreateVector2D(0.29541015625, 0.5908203125)
	elseif subTreeInfo.iconElementID == "talents-heroclass-hunter-packleader" then
		a = CreateVector2D(0.19775390625, 0.5927734375)
		b = CreateVector2D(0.29541015625, 0.7880859375)
	elseif subTreeInfo.iconElementID == "talents-heroclass-hunter-sentinel" then
		a = CreateVector2D(0.19775390625, 0.7900390625)
		b = CreateVector2D(0.29541015625, 0.9853515625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-mage-frostfire" then
		a = CreateVector2D(0.29638671875, 0.0009765625)
		b = CreateVector2D(0.39404296875, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-mage-spellslinger" then
		a = CreateVector2D(0.29638671875, 0.1982421875)
		b = CreateVector2D(0.39404296875, 0.3935546875)
	elseif subTreeInfo.iconElementID == "talents-heroclass-mage-sunfury" then
		a = CreateVector2D(0.29638671875, 0.3955078125)
		b = CreateVector2D(0.39404296875, 0.5908203125)
	elseif subTreeInfo.iconElementID == "talents-heroclass-monk-conduitofthecelestials" then
		a = CreateVector2D(0.29638671875, 0.5927734375)
		b = CreateVector2D(0.39404296875, 0.7880859375)
	elseif subTreeInfo.iconElementID == "talents-heroclass-monk-masterofharmony" then
		a = CreateVector2D(0.59228515625, 0.7900390625)
		b = CreateVector2D(0.68994140625, 0.9853515625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-monk-shadopan" then
		a = CreateVector2D(0.29638671875, 0.7900390625)
		b = CreateVector2D(0.39404296875, 0.9853515625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-paladin-heraldofthesun" then
		a = CreateVector2D(0.39501953125, 0.0009765625)
		b = CreateVector2D(0.49267578125, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-paladin-lightsmith" then
		a = CreateVector2D(0.39501953125, 0.1982421875)
		b = CreateVector2D(0.49267578125, 0.3935546875)
	elseif subTreeInfo.iconElementID == "talents-heroclass-paladin-templar" then
		a = CreateVector2D(0.39501953125, 0.3955078125)
		b = CreateVector2D(0.49267578125, 0.5908203125)
	elseif subTreeInfo.iconElementID == "talents-heroclass-priest-archon" then
		a = CreateVector2D(0.39501953125, 0.5927734375)
		b = CreateVector2D(0.49267578125, 0.7880859375)
	elseif subTreeInfo.iconElementID == "talents-heroclass-priest-oracle" then
		a = CreateVector2D(0.39501953125, 0.7900390625)
		b = CreateVector2D(0.49267578125, 0.9853515625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-priest-voidweaver" then
		a = CreateVector2D(0.49365234375, 0.0009765625)
		b = CreateVector2D(0.59130859375, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-rogue-deathstalker" then
		a = CreateVector2D(0.49365234375, 0.1982421875)
		b = CreateVector2D(0.59130859375, 0.3935546875)
	elseif subTreeInfo.iconElementID == "talents-heroclass-rogue-fatebound" then
		a = CreateVector2D(0.49365234375, 0.3955078125)
		b = CreateVector2D(0.59130859375, 0.5908203125)
	elseif subTreeInfo.iconElementID == "talents-heroclass-rogue-trickster" then
		a = CreateVector2D(0.49365234375, 0.5927734375)
		b = CreateVector2D(0.59130859375, 0.7880859375)
	elseif subTreeInfo.iconElementID == "talents-heroclass-shaman-farseer" then
		a = CreateVector2D(0.49365234375, 0.7900390625)
		b = CreateVector2D(0.59130859375, 0.9853515625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-shaman-stormbringer" then
		a = CreateVector2D(0.59228515625, 0.0009765625)
		b = CreateVector2D(0.68994140625, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-shaman-totemic" then
		a = CreateVector2D(0.69091796875, 0.0009765625)
		b = CreateVector2D(0.78857421875, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-warlock-diabolist" then
		a = CreateVector2D(0.78955078125, 0.0009765625)
		b = CreateVector2D(0.88720703125, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-warlock-hellcaller" then
		a = CreateVector2D(0.69091796875, 0.1982421875)
		b = CreateVector2D(0.78857421875, 0.3935546875)
	elseif subTreeInfo.iconElementID == "talents-heroclass-warlock-soulharvester" then
		a = CreateVector2D(0.88818359375, 0.0009765625)
		b = CreateVector2D(0.98583984375, 0.1962890625)
	elseif subTreeInfo.iconElementID == "talents-heroclass-warrior-colossus" then
		a = CreateVector2D(0.59228515625, 0.1982421875)
		b = CreateVector2D(0.68994140625, 0.3935546875)
	elseif subTreeInfo.iconElementID == "talents-heroclass-warrior-mountainthane" then
		a = CreateVector2D(0.59228515625, 0.3955078125)
		b = CreateVector2D(0.68994140625, 0.5908203125)
	elseif subTreeInfo.iconElementID == "talents-heroclass-warrior-slayer" then
		a = CreateVector2D(0.59228515625, 0.5927734375)
		b = CreateVector2D(0.68994140625, 0.7880859375)
	end
	self:SetTexCoordRange(a, b)
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		
		--PlayerCastingBarFrame.Icon:AdjustPointsOffset(2, -4)
		IconShieldVisibility()
		NamePosition()
		CurrentTimePosition()
		BothTimePosition()
		TotalTimePosition()
		CurrentTimeUpdate()
		BothTimeUpdate()
		TotalTimeUpdate()
		vcbCreateTicks()
		-- create the GCD --
		function vcbCreatingTheGCD()
			vcbFrameGCDparent:SetScale(PlayerCastingBarFrame.Icon:GetEffectiveScale())
			vcbFrameGCDparent:ClearAllPoints()
			vcbFrameGCDparent:SetPoint("RIGHT", PlayerCastingBarFrame.Icon, "LEFT", -4, 0)
			if VCBrPlayer["GCD"]["ClassicTexture"] == "職業圖示" then
				ClassIcon(vcbFrameGCD)
			elseif VCBrPlayer["GCD"]["ClassicTexture"] == "英雄圖示" then
				HeroIcon(vcbFrameGCD)
			end
		end
		vcbCreatingTheGCD()
		-- Hooking Time part 1 --
		PlayerCastingBarFrame:HookScript("OnShow", function(self)
			vcbPlayerIconVisibility(self)
			vcbPlayerNamePosition(self)
			vcbPlayerCurrentTimePosition(self)
			vcbPlayerBothTimePosition(self)
			vcbPlayerTotalTimePosition(self)
		end)
		-- Hooking Time part 2 --
		PlayerCastingBarFrame:HookScript("OnUpdate", function(self)
			self.Text:SetAlpha(0)
			VCBnameText:SetText(self.Text:GetText())
			CastBarColor(self)
			if self.value ~= nil and self.maxValue ~= nil then
				vcbCurrentTimeUpdate(self)
				vcbBothTimeUpdate(self)
				vcbTotalTimeUpdate(self)
			end
			if (self.barType == "channel" or self.barType =="uninterruptable") and VCBrPlayer["Ticks"] ~= "隱藏" then
				vcbShowTicks(VCBarg3)
			else
				vcbHideTicks()
			end
		end)
	elseif event == "CURRENT_SPELL_CAST_CHANGED" and arg1 == false then
		lagStart = GetTime()
	elseif event == "UNIT_SPELLCAST_START" and arg1 == "player" then
		vcbHideTicks()
		VCBLagCastBar:Hide()
		VCBLagChannelBar:Hide()
		VCBSpellQueueCastBar:Hide()
		VCBSpellQueueChannelBar:Hide()
		VCBarg3 = arg3
		PlayerCastLagBar(arg3)
		PlayerCastSpellQueueBar(arg3)
		local mountID = C_MountJournal.GetMountFromSpell(arg3)
		if mountID then vcbSpellSchool = 72 end
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" and arg1 == "player" then
		vcbHideTicks()
		VCBLagCastBar:Hide()
		VCBLagChannelBar:Hide()
		VCBSpellQueueCastBar:Hide()
		VCBSpellQueueChannelBar:Hide()
		VCBarg3 = arg3
		PlayerChannelLagBar(arg3)
		PlayerChannelSpellQueueBar(arg3)
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
		local spellId, spellName, spellSchool = select(12, CombatLogGetCurrentEventInfo())
		if subevent == "SPELL_CAST_START" and sourceName == UnitFullName("player") then
			vcbSpellSchool = spellSchool
		elseif subevent == "SPELL_CAST_SUCCESS" and sourceName == UnitFullName("player") then
			vcbSpellSchool = spellSchool
		elseif subevent == "SPELL_AURA_APPLIED" and sourceName == UnitFullName("player") and spellId == 356995 then
			vcbEvokerTicksFirstTime = true
			vcbEvokerTicksSecondTime = false
		elseif subevent == "SPELL_AURA_REFRESH" and sourceName == UnitFullName("player") and spellId == 356995 then
			vcbEvokerTicksFirstTime = false
			vcbEvokerTicksSecondTime = true
		end
	elseif event == "UNIT_SPELLCAST_SENT" and arg1 == "player" then
		local spellCooldownInfo = C_Spell.GetSpellCooldown(61304)
		if spellCooldownInfo.duration > 0 then
			if VCBrPlayer["GCD"]["ClassicTexture"] ~= "隱藏" then
				vcbFrameGCD:SetCooldown(GetTime(), spellCooldownInfo.duration - (GetTime() - lagStart))
			end
		end
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
