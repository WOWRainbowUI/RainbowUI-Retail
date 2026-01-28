-- some variables --
local startT
local G = VDW.Local.Override
-- protect the options --
local function ProtectOptions()
	local loc = GetLocale()
	if loc ~= VCBspecialSettings["LastLocation"] then
		for k, v in pairs(VDW.Local.Translate) do
			for i, s in pairs (v) do
				if VCBsettings["Player"]["NameText"]["Position"] == s then
					VCBsettings["Player"]["NameText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["CurrentTimeText"]["Position"] == s then
					VCBsettings["Player"]["CurrentTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["CurrentTimeText"]["Direction"] == s then
					VCBsettings["Player"]["CurrentTimeText"]["Direction"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["CurrentTimeText"]["Sec"] == s then
					VCBsettings["Player"]["CurrentTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["BothTimeText"]["Position"] == s then
					VCBsettings["Player"]["BothTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["BothTimeText"]["Direction"] == s then
					VCBsettings["Player"]["BothTimeText"]["Direction"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["BothTimeText"]["Sec"] == s then
					VCBsettings["Player"]["BothTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["TotalTimeText"]["Position"] == s then
					VCBsettings["Player"]["TotalTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["TotalTimeText"]["Sec"] == s then
					VCBsettings["Player"]["TotalTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["LagBar"]["Visibility"] == s then
					VCBsettings["Player"]["LagBar"]["Visibility"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["QueueBar"]["Visibility"] == s then
					VCBsettings["Player"]["QueueBar"]["Visibility"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["GCD"]["Style"] == s then
					VCBsettings["Player"]["GCD"]["Style"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["GCD"]["Position"] == s then
					VCBsettings["Player"]["GCD"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["Icon"]["Position"] == s then
					VCBsettings["Player"]["Icon"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["Icon"]["Shield"] == s then
					VCBsettings["Player"]["Icon"]["Shield"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["StatusBar"]["Color"] == s then
					VCBsettings["Player"]["StatusBar"]["Color"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["StatusBar"]["Style"] == s then
					VCBsettings["Player"]["StatusBar"]["Style"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["Border"]["Color"] == s then
					VCBsettings["Player"]["Border"]["Color"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Player"]["Border"]["Style"] == s then
					VCBsettings["Player"]["Border"]["Style"] = VDW.Local.Translate[loc][i]
				end
				if VCBspecialSettings["Player"]["Ticks"]["Style"] == s then
					VCBspecialSettings["Player"]["Ticks"]["Style"] = VDW.Local.Translate[loc][i]
				end
			end
		end
	end
end
-- function for the texts --
local function Texts(var1)
	var1:SetFontObject("GameFontHighlightSmall")
	var1:SetHeight(PlayerCastingBarFrame.Text:GetHeight())
	var1:Hide()
end
-- creating the texts --
local textName = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
Texts(textName)
local textCurrent = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
Texts(textCurrent)
local textBoth = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
Texts(textBoth)
local textTotal = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
Texts(textTotal)
-- copy texture of spell's icon --
local iconSpell = PlayerCastingBarFrame:CreateTexture(nil, "ARTWORK", nil, 0)
iconSpell:Hide()
-- spell's shield left --
local shieldSpellLeft = PlayerCastingBarFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
shieldSpellLeft:SetAtlas("ui-castingbar-shield", false)
shieldSpellLeft:SetPoint("CENTER", PlayerCastingBarFrame.Icon, "CENTER", 0, -3)
shieldSpellLeft:SetSize(30, 34)
shieldSpellLeft:SetBlendMode("BLEND")
shieldSpellLeft:SetAlpha(0.75)
shieldSpellLeft:Hide()
-- spell's shield right --
local shieldSpellRight = PlayerCastingBarFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
shieldSpellRight:SetAtlas("ui-castingbar-shield", false)
shieldSpellRight:SetPoint("CENTER", iconSpell, "CENTER", 0, -3)
shieldSpellRight:SetSize(30, 34)
shieldSpellRight:SetBlendMode("BLEND")
shieldSpellRight:SetAlpha(0.75)
shieldSpellRight:Hide()
-- jailer colors & alphas --
local jailerColor = CreateColorFromRGBAHexString("0A979CFF")
local function jailerBorderAlpha(self)
	self.Background:SetAlpha(0.25)
	self.TextBorder:SetAlpha(0.25)
end
-- name position --
local function namePosition(self)
	print("namePosition is not Working!")
end
-- current time position --
local function currentPostion(self)
	print("currentPostion is not Working!")
end
-- both time position --
local function bothPostion(self)
	print("bothPostion is not Working!")
end
-- total time position--
local function totalPostion(self)
	print("totalPostion is not Working!")
end
-- icon position --
local function iconPosition(self)
	print("iconPosition is not Working!")
end
-- current time update --
local function currentUpdate(self)
	print("currentUpdate is not Working!")
end
-- both time update --
local function bothUpdate(self)
	print("bothUpdate is not Working!")
end
-- total time update--
local function totalUpdate(self)
	print("totalUpdate is not Working!")
end
-- cast bar color --
local function castbarColor(self)
	print("castbarColor is not Working!")
end
-- border color --
local function borderColor(self)
	print("borderColor is not Working!")
end
-- bar style --
local function barStyle(self)
	print("barStyle is not Working!")
end
-- border style --
local function borderStyle()
	print("borderStyle is not Working!")
end
-- position functions --
local function GlobalFunctionsCHK()
-- icon --
	function chkIconPlayer()
		if PlayerCastingBarFrame.showShield then PlayerCastingBarFrame.showShield = false end
		PlayerCastingBarFrame.Icon:SetSize(20, 20)
		iconSpell:SetWidth(PlayerCastingBarFrame.Icon:GetWidth())
		iconSpell:SetHeight(PlayerCastingBarFrame.Icon:GetHeight())
		iconSpell:SetScale(PlayerCastingBarFrame.Icon:GetEffectiveScale())
		if VCBsettings["Player"]["Icon"]["Shield"] == G.OPTIONS_V_HIDE then
			if VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
				function iconPosition(self)
					if self.Icon:IsShown() then self.Icon:Hide() end
					if iconSpell:IsShown() then iconSpell:Hide() end
					if shieldSpellLeft:IsShown() then shieldSpellLeft:Hide() end
					if shieldSpellRight:IsShown() then shieldSpellRight:Hide() end
				end
			elseif VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_LEFT then
				function iconPosition(self)
					self.Icon:ClearAllPoints()
					self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -5)
					if not self.Icon:IsShown() then self.Icon:Show() end
					if iconSpell:IsShown() then iconSpell:Hide() end
					if shieldSpellLeft:IsShown() then shieldSpellLeft:Hide() end
					if shieldSpellRight:IsShown() then shieldSpellRight:Hide() end
				end
			elseif VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_RIGHT then
				function iconPosition(self)
					if self.Icon:IsShown() then self.Icon:Hide() end
					iconSpell:ClearAllPoints()
					iconSpell:SetPoint("LEFT", self, "RIGHT", 2, -5)
					iconSpell:SetTexture(self.Icon:GetTextureFileID())
					if not iconSpell:IsShown() then iconSpell:Show() end
					if shieldSpellLeft:IsShown() then shieldSpellLeft:Hide() end
					if shieldSpellRight:IsShown() then shieldSpellRight:Hide() end
				end
			elseif VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				function iconPosition(self)
					self.Icon:ClearAllPoints()
					self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -5)
					if not self.Icon:IsShown() then self.Icon:Show() end
					iconSpell:ClearAllPoints()
					iconSpell:SetPoint("LEFT", self, "RIGHT", 2, -5)
					iconSpell:SetTexture(self.Icon:GetTextureFileID())
					if not iconSpell:IsShown() then iconSpell:Show() end
					if shieldSpellLeft:IsShown() then shieldSpellLeft:Hide() end
					if shieldSpellRight:IsShown() then shieldSpellRight:Hide() end
				end
			end
		elseif VCBsettings["Player"]["Icon"]["Shield"] == G.OPTIONS_V_SHOW then
			if VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_LEFT then
				function iconPosition(self)
					self.Icon:ClearAllPoints()
					self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -5)
					if not self.Icon:IsShown() then self.Icon:Show() end
					if iconSpell:IsShown() then iconSpell:Hide() end
					if self.barType == "uninterruptable" then
						if not shieldSpellLeft:IsShown() then shieldSpellLeft:Show() end
					else
						if shieldSpellLeft:IsShown() then shieldSpellLeft:Hide() end
					end
					if shieldSpellRight:IsShown() then shieldSpellRight:Hide() end
				end
			elseif VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_RIGHT then
				function iconPosition(self)
					if self.Icon:IsShown() then self.Icon:Hide() end
					iconSpell:ClearAllPoints()
					iconSpell:SetPoint("LEFT", self, "RIGHT", 2, -5)
					iconSpell:SetTexture(self.Icon:GetTextureFileID())
					if not iconSpell:IsShown() then iconSpell:Show() end
					if shieldSpellLeft:IsShown() then shieldSpellLeft:Hide() end
					if self.barType == "uninterruptable" then
						if not shieldSpellRight:IsShown() then shieldSpellRight:Show() end
					else
						if shieldSpellRight:IsShown() then shieldSpellRight:Hide() end
					end
				end
			elseif VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				function iconPosition(self)
					iconSpell:SetTexture(self.Icon:GetTextureFileID())
					if self.barType == "uninterruptable" then
						self.Icon:ClearAllPoints()
						self.Icon:SetPoint("RIGHT", self, "LEFT", -4, -5)
						if not shieldSpellLeft:IsShown() then shieldSpellLeft:Show() end
						iconSpell:ClearAllPoints()
						iconSpell:SetPoint("LEFT", self, "RIGHT", 4, -5)
						if not shieldSpellRight:IsShown() then shieldSpellRight:Show() end
					else
						self.Icon:ClearAllPoints()
						self.Icon:SetPoint("RIGHT", self, "LEFT", -2, -5)
						if shieldSpellLeft:IsShown() then shieldSpellLeft:Hide() end
						iconSpell:ClearAllPoints()
						iconSpell:SetPoint("LEFT", self, "RIGHT", 2, -5)
						if shieldSpellRight:IsShown() then shieldSpellRight:Hide() end
					end
					if not self.Icon:IsShown() then self.Icon:Show() end
					if not iconSpell:IsShown() then iconSpell:Show() end
				end
			end
		end
	end
-- name --
	function chkNameTxtPlayer()
		if VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_V_HIDE then
			function namePosition(self)
				if textName:IsShown() then textName:Hide() end
			end
		elseif VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_P_LEFT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("LEFT", self, "LEFT", 4, 0)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_P_TOP then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("BOTTOM", self, "TOP", 0, -2)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_P_CENTER then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("CENTER", self, "CENTER", 0, 0)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("TOP", self, "BOTTOM", 0, 1)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_P_RIGHT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("RIGHT", self, "RIGHT", -4, 0)
				if not textName:IsShown() then textName:Show() end
			end
		elseif VCBsettings["Player"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function namePosition(self)
				textName:ClearAllPoints()
				textName:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
				if not textName:IsShown() then textName:Show() end
			end
		end
	end
-- total time --
	function chkTotalTxtPlayer()
		if VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function totalPostion(self)
				if textTotal:IsShown() then textTotal:Hide() end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("LEFT", self, "LEFT", 4, 0)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("BOTTOM", self, "TOP", 0, -2)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("CENTER", self, "CENTER", 0, 0)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("TOP", self, "BOTTOM", 0, 1)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("RIGHT", self, "RIGHT", -4, 0)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function totalPostion(self)
				textTotal:ClearAllPoints()
				textTotal:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
				if not textTotal:IsShown() then textTotal:Show() end
			end
		end
	end
-- current time --
	function chkCurrentTxtPlayer()
		if VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function currentPostion(self)
				if textCurrent:IsShown() then textCurrent:Hide() end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("LEFT", self, "LEFT", 4, 0)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("BOTTOM", self, "TOP", 0, -2)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("CENTER", self, "CENTER", 0, 0)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("TOP", self, "BOTTOM", 0, 1)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("RIGHT", self, "RIGHT", -4, 0)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function currentPostion(self)
				textCurrent:ClearAllPoints()
				textCurrent:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
				if not textCurrent:IsShown() then textCurrent:Show() end
			end
		end
	end
-- both time --
	function chkBothTxtPlayer()
		if VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function bothPostion(self)
				if textBoth:IsShown() then textBoth:Hide() end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("LEFT", self, "LEFT", 4, 0)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("BOTTOM", self, "TOP", 0, -2)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("CENTER", self, "CENTER", 0, 0)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("TOP", self, "BOTTOM", 0, 1)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("RIGHT", self, "RIGHT", -4, 0)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function bothPostion(self)
				textBoth:ClearAllPoints()
				textBoth:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
				if not textBoth:IsShown() then textBoth:Show() end
			end
		end
	end
end
-- update functions --
local function GlobalFunctionsUPD()
-- current time --
	function chkCurrentUpdPlayer()
		if VCBsettings["Player"]["CurrentTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Player"]["CurrentTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Player"]["CurrentTimeText"]["Decimals"] == "0" then
					if VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.0f", self.value)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.0f", vcbValue)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.0f", vcbValue)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.0f", self.value)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.0f", self.value)
						end
					end
				elseif VCBsettings["Player"]["CurrentTimeText"]["Decimals"] == "1" then
					if VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.1f", self.value)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.1f", vcbValue)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.1f", vcbValue)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.1f", self.value)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.1f", self.value)
						end
					end
				elseif VCBsettings["Player"]["CurrentTimeText"]["Decimals"] == "2" then
					if VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.2f", self.value)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.2f", vcbValue)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.2f", vcbValue)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.2f", self.value)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.2f", self.value)
						end
					end
				elseif VCBsettings["Player"]["CurrentTimeText"]["Decimals"] == "3" then
					if VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.3f", self.value)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.3f", vcbValue)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.3f", vcbValue)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.3f", self.value)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.3f", self.value)
						end
					end
				end
			elseif VCBsettings["Player"]["CurrentTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Player"]["CurrentTimeText"]["Decimals"] == "0" then
					if VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.0f Sec", self.value)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.0f Sec", vcbValue)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.0f Sec", vcbValue)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.0f Sec", self.value)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.0f Sec", self.value)
						end
					end
				elseif VCBsettings["Player"]["CurrentTimeText"]["Decimals"] == "1" then
					if VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.1f Sec", self.value)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.1f Sec", vcbValue)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.1f Sec", vcbValue)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.1f Sec", self.value)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.1f Sec", self.value)
						end
					end
				elseif VCBsettings["Player"]["CurrentTimeText"]["Decimals"] == "2" then
					if VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.2f Sec", self.value)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.2f Sec", vcbValue)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.2f Sec", vcbValue)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.2f Sec", self.value)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.2f Sec", self.value)
						end
					end
				elseif VCBsettings["Player"]["CurrentTimeText"]["Decimals"] == "3" then
					if VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self)
							if self.casting then
								textCurrent:SetFormattedText("%.3f Sec", self.value)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.3f Sec", vcbValue)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textCurrent:SetFormattedText("%.3f Sec", vcbValue)
							elseif self.channeling then
								textCurrent:SetFormattedText("%.3f Sec", self.value)
							end
						end
					elseif VCBsettings["Player"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self)
							textCurrent:SetFormattedText("%.3f Sec", self.value)
						end
					end
				end
			end
		elseif VCBsettings["Player"]["CurrentTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function currentUpdate(self)
				return
			end
		end
	end
-- both time --
	function chkBothUpdPlayer()
		if VCBsettings["Player"]["BothTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Player"]["BothTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Player"]["BothTimeText"]["Decimals"] == "0" then
					if VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.0f/%.0f", vcbValue, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.0f/%.0f", vcbValue, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Player"]["BothTimeText"]["Decimals"] == "1" then
					if VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.1f/%.1f", vcbValue, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.1f/%.1f", vcbValue, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Player"]["BothTimeText"]["Decimals"] == "2" then
					if VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.2f/%.2f", vcbValue, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.2f/%.2f", vcbValue, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Player"]["BothTimeText"]["Decimals"] == "3" then
					if VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.3f/%.3f", vcbValue, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.3f/%.3f", vcbValue, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
						end
					end
				end
			elseif VCBsettings["Player"]["BothTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Player"]["BothTimeText"]["Decimals"] == "0" then
					if VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.0f/%.0f Sec", vcbValue, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.0f/%.0f Sec", vcbValue, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Player"]["BothTimeText"]["Decimals"] == "1" then
					if VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.1f/%.1f Sec", vcbValue, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.1f/%.1f Sec", vcbValue, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Player"]["BothTimeText"]["Decimals"] == "2" then
					if VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.2f/%.2f Sec", vcbValue, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.2f/%.2f Sec", vcbValue, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Player"]["BothTimeText"]["Decimals"] == "3" then
					if VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self)
							if self.casting then
								textBoth:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.3f/%.3f Sec", vcbValue, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self)
							if self.casting then
								local vcbValue = self.maxValue - self.value
								textBoth:SetFormattedText("%.3f/%.3f Sec", vcbValue, self.maxValue)
							elseif self.channeling then
								textBoth:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Player"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self)
							textBoth:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
						end
					end
				end
			end
		elseif VCBsettings["Player"]["BothTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function bothUpdate(self)
				return
			end
		end
	end
-- total time --
	function chkTotalUpdPlayer()
		if VCBsettings["Player"]["TotalTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Player"]["TotalTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Player"]["TotalTimeText"]["Decimals"] == "0" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.0f", self.maxValue)
					end
				elseif VCBsettings["Player"]["TotalTimeText"]["Decimals"] == "1" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.1f", self.maxValue)
					end
				elseif VCBsettings["Player"]["TotalTimeText"]["Decimals"] == "2" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.2f", self.maxValue)
					end
				elseif VCBsettings["Player"]["TotalTimeText"]["Decimals"] == "3" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.3f", self.maxValue)
					end
				end
			elseif VCBsettings["Player"]["TotalTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Player"]["TotalTimeText"]["Decimals"] == "0" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.0f sec", self.maxValue)
					end
				elseif VCBsettings["Player"]["TotalTimeText"]["Decimals"] == "1" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.1f sec", self.maxValue)
					end
				elseif VCBsettings["Player"]["TotalTimeText"]["Decimals"] == "2" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.2f sec", self.maxValue)
					end
				elseif VCBsettings["Player"]["TotalTimeText"]["Decimals"] == "3" then
					function totalUpdate(self)
						textTotal:SetFormattedText("%.3f sec", self.maxValue)
					end
				end
			end
		elseif VCBsettings["Player"]["TotalTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function totalUpdate(self)
				return
			end
		end
	end
end
-- bar artwork global function --
local function GlobalFunctionsStyle()
-- status color --
	function chkCastbarColorPlayer()
		if VCBsettings["Player"]["StatusBar"]["Color"] == G.OPTIONS_C_DEFAULT then
			function castbarColor(self)
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
				if VCBsettings["Player"]["StatusBar"]["Style"] == "Jailer" then
					self.Spark:SetDesaturated(true)
					self.Spark:SetVertexColor(jailerColor:GetRGB())
					self.ChannelShadow:SetDesaturated(true)
					self.ChannelShadow:SetVertexColor(jailerColor:GetRGB())
					self.StandardGlow:SetDesaturated(true)
					self.StandardGlow:SetVertexColor(jailerColor:GetRGB())
					self.Flash:SetDesaturated(true)
					self.Flash:SetVertexColor(jailerColor:GetRGB())
				else
					self.Spark:SetDesaturated(false)
					self.Spark:SetVertexColor(1, 1, 1, 1)
					self.ChannelShadow:SetDesaturated(false)
					self.ChannelShadow:SetVertexColor(1, 1, 1, 1)
					self.StandardGlow:SetDesaturated(false)
					self.StandardGlow:SetVertexColor(1, 1, 1, 1)
					self.Flash:SetDesaturated(false)
					self.Flash:SetVertexColor(1, 1, 1, 1)
				end
			end
		elseif VCBsettings["Player"]["StatusBar"]["Color"] == G.OPTIONS_C_FACTION then
			function castbarColor(self)
				self:SetStatusBarDesaturated(true)
				self:SetStatusBarColor(VDW.PlayerFactionColor:GetRGB())
				self.Spark:SetDesaturated(true)
				self.Spark:SetVertexColor(VDW.PlayerFactionColor:GetRGB())
				self.ChannelShadow:SetDesaturated(true)
				self.ChannelShadow:SetVertexColor(VDW.PlayerFactionColor:GetRGB())
				self.StandardGlow:SetDesaturated(true)
				self.StandardGlow:SetVertexColor(VDW.PlayerFactionColor:GetRGB())
				self.Flash:SetDesaturated(true)
				self.Flash:SetVertexColor(VDW.PlayerFactionColor:GetRGB())
			end
		elseif VCBsettings["Player"]["StatusBar"]["Color"] == G.OPTIONS_C_CLASS then
			function castbarColor(self)
				self:SetStatusBarDesaturated(true)
				self:SetStatusBarColor(VDW.PlayerClassColor:GetRGB())
				self.Spark:SetDesaturated(true)
				self.Spark:SetVertexColor(VDW.PlayerClassColor:GetRGB())
				self.ChannelShadow:SetDesaturated(true)
				self.ChannelShadow:SetVertexColor(VDW.PlayerClassColor:GetRGB())
				self.StandardGlow:SetDesaturated(true)
				self.StandardGlow:SetVertexColor(VDW.PlayerClassColor:GetRGB())
				self.Flash:SetDesaturated(true)
				self.Flash:SetVertexColor(VDW.PlayerClassColor:GetRGB())
			end
		end
	end
-- border color --
	function chkCastbarBorderColorPlayer()
		if VCBsettings["Player"]["Border"]["Color"] == G.OPTIONS_C_DEFAULT then
			function borderColor(self)
				self.Background:SetDesaturated(false)
				self.Border:SetDesaturated(false)
				self.TextBorder:SetDesaturated(false)
				self.Background:SetVertexColor(1, 1, 1, 1)
				self.Border:SetVertexColor(1, 1, 1, 1)
				self.TextBorder:SetVertexColor(1, 1, 1, 1)
				if VCBsettings["Player"]["Border"]["Style"] == "Jailer" then jailerBorderAlpha(self) end
			end
		elseif VCBsettings["Player"]["Border"]["Color"] == G.OPTIONS_C_FACTION then
			function borderColor(self)
				self.Background:SetDesaturated(true)
				self.Border:SetDesaturated(true)
				self.TextBorder:SetDesaturated(true)
				self.Background:SetVertexColor(VDW.PlayerFactionColor:GetRGB())
				self.Border:SetVertexColor(VDW.PlayerFactionColor:GetRGB())
				self.TextBorder:SetVertexColor(VDW.PlayerFactionColor:GetRGB())
				if VCBsettings["Player"]["Border"]["Style"] == "Jailer" then jailerBorderAlpha(self) end
			end
		elseif VCBsettings["Player"]["Border"]["Color"] == G.OPTIONS_C_CLASS then
			function borderColor(self)
				self.Background:SetDesaturated(true)
				self.Border:SetDesaturated(true)
				self.TextBorder:SetDesaturated(true)
				self.Background:SetVertexColor(VDW.PlayerClassColor:GetRGB())
				self.Border:SetVertexColor(VDW.PlayerClassColor:GetRGB())
				self.TextBorder:SetVertexColor(VDW.PlayerClassColor:GetRGB())
				if VCBsettings["Player"]["Border"]["Style"] == "Jailer" then jailerBorderAlpha(self) end
			end
		end
	end
-- bar style --
	function chkStylePlayer()
		if VCBsettings["Player"]["StatusBar"]["Style"] == G.OPTIONS_C_DEFAULT then
			function barStyle(self)
				return
			end
		elseif VCBsettings["Player"]["StatusBar"]["Style"] == "Jailer" then
			function barStyle(self)
				self:SetStatusBarTexture("jailerstower-scorebar-fill-onfire")
			end
		end
		if VCBsettings["Player"]["Border"]["Style"] == G.OPTIONS_C_DEFAULT then
			function borderStyle()
				return
			end
		elseif VCBsettings["Player"]["Border"]["Style"] == "Jailer" then
			function borderStyle()
				PlayerCastingBarFrame.Border:SetAtlas("jailerstower-scenario-TitleBG")
				PlayerCastingBarFrame.Border:ClearAllPoints()
				PlayerCastingBarFrame.Border:SetPoint("TOPLEFT", PlayerCastingBarFrame, "TOPLEFT", -24, 18)
				PlayerCastingBarFrame.Border:SetPoint("BOTTOMRIGHT", PlayerCastingBarFrame, "BOTTOMRIGHT", 24, -28)
				PlayerCastingBarFrame.Background:SetAtlas("jailerstower-scorebar-bgright-onfire")
				PlayerCastingBarFrame.Background:SetDesaturated(true)
				PlayerCastingBarFrame.TextBorder:SetAtlas("jailerstower-scorebar-bgright-onfire")
				PlayerCastingBarFrame.TextBorder:SetDesaturated(true)
			end
		end
	end
end
-- global cooldown --
-- textures of the class icon --
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
-- textures of the hero icon --
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
-- factions icon --
local function FactionIcon(self)
	if VDW.PlayerFactionInfo.groupTag == "Alliance" then
		self:SetSwipeTexture("Interface\\ICONS\\UI_AllianceIcon-round.blp")
	elseif VDW.PlayerFactionInfo.groupTag == "Horde" then
		self:SetSwipeTexture("Interface\\ICONS\\UI_HordeIcon-round.blp")
	end
	a = CreateVector2D(0, 0)
	b = CreateVector2D(1, 1)
	self:SetTexCoordRange(a, b)
end
-- global cooldown & color function --
local function GlobalFunctionsGCD()
-- global cooldown --
	function chkGlobalCooldownPlayer(self)
		if VCBsettings["Player"]["GCD"]["Position"] == G.OPTIONS_V_HIDE then
			if vcbGCDparent:IsShown() then vcbGCDparent:Hide() end
		elseif VCBsettings["Player"]["GCD"]["Position"] == G.OPTIONS_P_LEFT then
			vcbGCD2:ClearAllPoints()
			vcbGCD2:SetPoint("RIGHT", vcbGCDparent, "RIGHT", 0, 0)
			if VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_LEFT or VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				vcbGCDparent:ClearAllPoints()
				vcbGCDparent:SetPoint("RIGHT", PlayerCastingBarFrame.Icon, "LEFT", -4, 0)
			else
				vcbGCDparent:ClearAllPoints()
				vcbGCDparent:SetPoint("RIGHT", PlayerCastingBarFrame, "LEFT", -4, 0)
			end
			if not vcbGCDparent:IsShown() then vcbGCDparent:Show() end
		elseif VCBsettings["Player"]["GCD"]["Position"] == G.OPTIONS_P_TOP then
			vcbGCD2:ClearAllPoints()
			vcbGCD2:SetPoint("CENTER", vcbGCDparent, "CENTER", 0, 0)
			vcbGCDparent:ClearAllPoints()
			vcbGCDparent:SetPoint("BOTTOM", PlayerCastingBarFrame, "TOP", 0, 16)
			if not vcbGCDparent:IsShown() then vcbGCDparent:Show() end
		elseif VCBsettings["Player"]["GCD"]["Position"] == G.OPTIONS_P_RIGHT then
			vcbGCD2:ClearAllPoints()
			vcbGCD2:SetPoint("LEFT", vcbGCDparent, "LEFT", 0, 0)
			if VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_RIGHT or VCBsettings["Player"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				vcbGCDparent:ClearAllPoints()
				vcbGCDparent:SetPoint("LEFT", iconSpell, "RIGHT", 4, 0)
			else
				vcbGCDparent:ClearAllPoints()
				vcbGCDparent:SetPoint("LEFT", PlayerCastingBarFrame, "RIGHT", 4, 0)
			end
			if not vcbGCDparent:IsShown() then vcbGCDparent:Show() end
		elseif VCBsettings["Player"]["GCD"]["Position"] == G.OPTIONS_P_BOTTOM then
			vcbGCD2:ClearAllPoints()
			vcbGCD2:SetPoint("CENTER", vcbGCDparent, "CENTER", 0, 0)
			vcbGCDparent:ClearAllPoints()
			vcbGCDparent:SetPoint("TOP", PlayerCastingBarFrame, "BOTTOM", 0, -16)
			if not vcbGCDparent:IsShown() then vcbGCDparent:Show() end
		end
		if VCBsettings["Player"]["GCD"]["Style"] == G.OPTIONS_S_CLASS_ICON then
			ClassIcon(self)
		elseif VCBsettings["Player"]["GCD"]["Style"] == G.OPTIONS_S_HERO_ICON then
			HeroIcon(self)
		elseif VCBsettings["Player"]["GCD"]["Style"] == G.OPTIONS_S_FACTION_ICON then
			FactionIcon(self)
		elseif VCBsettings["Player"]["GCD"]["Style"] == G.OPTIONS_S_DEFAULT_BAR then
			vcbGCD2:SetFillStyle(2)
		end
	end
end
-- lag & queue bars --
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
	if (playerSpell1 or playerSpell2) and VCBsettings["Player"]["QueueBar"]["Visibility"] == G.OPTIONS_V_SHOW then
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
	if (playerSpell1 or playerSpell2) and VCBsettings["Player"]["QueueBar"]["Visibility"] == G.OPTIONS_V_SHOW then
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
	if (playerSpell1 or playerSpell2) and VCBsettings["Player"]["LagBar"]["Visibility"] == G.OPTIONS_V_SHOW then
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
	if (playerSpell1 or playerSpell2) and VCBsettings["Player"]["LagBar"]["Visibility"] == G.OPTIONS_V_SHOW then
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
local function defaultColor(self)
	self:SetStatusBarDesaturated(false)
	self:SetStatusBarColor(1, 1, 1, 1)
	self.Background:SetDesaturated(false)
	self.Border:SetDesaturated(false)
	self.TextBorder:SetDesaturated(false)
	self.Background:SetVertexColor(1, 1, 1, 1)
	self.Border:SetVertexColor(1, 1, 1, 1)
	self.TextBorder:SetVertexColor(1, 1, 1, 1)
	if VCBsettings["Player"]["Border"]["Style"] == "Jailer" then
		self.Spark:SetDesaturated(true)
		self.Spark:SetVertexColor(jailerColor:GetRGB())
		self.ChannelShadow:SetDesaturated(true)
		self.ChannelShadow:SetVertexColor(jailerColor:GetRGB())
		self.StandardGlow:SetDesaturated(true)
		self.StandardGlow:SetVertexColor(jailerColor:GetRGB())
		self.Flash:SetDesaturated(true)
		self.Flash:SetVertexColor(jailerColor:GetRGB())
		jailerBorderAlpha(self)
	else
		self.Spark:SetDesaturated(false)
		self.Spark:SetVertexColor(1, 1, 1, 1)
		self.ChannelShadow:SetDesaturated(false)
		self.ChannelShadow:SetVertexColor(1, 1, 1, 1)
		self.StandardGlow:SetDesaturated(false)
		self.StandardGlow:SetVertexColor(1, 1, 1, 1)
		self.Flash:SetDesaturated(false)
		self.Flash:SetVertexColor(1, 1, 1, 1)
	end
end
-- creating the ticks for the player's castbar --
-- create Ticks  --
local function CreateTicks(number, var1)
	local spaceTick = PlayerCastingBarFrame:GetWidth() / number
	if VCBspecialSettings["Player"]["Ticks"]["Style"] == G.OPTIONS_S_MODERN then
		for i = 1, number, 1 do
			local tick = PlayerCastingBarFrame:CreateTexture("vcb"..var1.."Tick"..i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", false)
			tick:SetDesaturated(false)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:SetWidth(12)
			tick:SetVertexColor(1, 1, 1, 1)
			tick:SetBlendMode("BLEND")
			if i == 1 then
				tick:ClearAllPoints()
				tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			else
				tick:ClearAllPoints()
				tick:SetPoint("LEFT", "vcb"..var1.."Tick"..i-1, "LEFT", spaceTick, 0)
			end
			tick:Hide()
		end
	elseif VCBspecialSettings["Player"]["Ticks"]["Style"] == G.OPTIONS_S_CLASSIC then
		for i = 1, number, 1 do
			local tick = PlayerCastingBarFrame:CreateTexture("vcb"..var1.."Tick"..i, "OVERLAY", nil, 7)
			tick:SetAtlas("!Tooltip-Azerite-NineSlice-EdgeLeft", false)
			tick:SetDesaturated(true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:SetWidth(8)
			tick:SetVertexColor(0.9, 0.9, 0.9, 0.8)
			tick:SetBlendMode("BLEND")
			if i == 1 then
				tick:ClearAllPoints()
				tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			else
				tick:ClearAllPoints()
				tick:SetPoint("LEFT", "vcb"..var1.."Tick"..i-1, "LEFT", spaceTick, 0)
			end
			tick:Hide()
		end
	end
end
-- Show Ticks --
local function ShowTicks(number, var1)
	for i = 1, number, 1 do
		_G["vcb"..var1.."Tick"..i]:Show()
	end
end
-- Hide Ticks --
local function HideTicks(number, var1)
	for i = 1, number, 1 do
		_G["vcb"..var1.."Tick"..i]:Hide()
	end
end
-- Priest --
local function ShowPriestTicks(arg3)
-- Mind Flay, Insanity --
	if arg3 == 391403 or arg3 == 47540 then
		ShowTicks(4, 1)
-- Void Torrent, Divine Hymn, Symbol of Hope --
	elseif arg3 == 263165 or arg3 == 64843 or arg3 == 64901 then
		ShowTicks(5, 2)
-- Mind Flay --
	elseif arg3 == 15407 then
		ShowTicks(6, 3)
	end
end
-- Mage --
local function ShowMageTicks(arg3)
-- Covenant: Shifting Power --
	if arg3 == 314791 then
		ShowTicks(4, 1)
-- Arcane Missiles, Ray of Frost --
	elseif arg3 == 5143 or arg3 == 205021 then
		ShowTicks(5, 2)
	end
end
-- Warlock --
local function ShowWarlockTicks(arg3)
-- Drain Life, Drain Soul, Health Funnel --
	if arg3 == 234153 or arg3 == 198590 or arg3 == 217979 then
		ShowTicks(5, 1)
	end
end
-- Monk --
local function ShowMonkTicks(arg3)
-- Essence Font, Spinning Crane Kick --
	if arg3 == 191837 or arg3 == 101546 then
		ShowTicks(3, 1)
-- Crackling Jade Lightning, Fists of Fury  --
	elseif arg3 == 117952 or arg3 == 113656 then
		ShowTicks(4, 2)
-- Soothing Mist --
	elseif arg3 == 115175 then
		ShowTicks(8, 3)
	end
end
-- Druid --
local function ShowDruidTicks(arg3)
-- Tranquility --
	if arg3 == 740 then
		ShowTicks(4, 1)
	end
end
-- Evoker --
local function ShowEvokerTicks()
-- Disintegrate --
	if vcbEvokerTicksFirstTime then
		for i = 1, 3, 1 do
			_G["vcb"..var1.."Tick"..i]:Show()
		end
	elseif vcbEvokerTicksSecondTime then
		for i = 1, 4, 1 do
			_G["vcb"..var1.."Tick"..i]:Show()
		end
	end
end
-- Create the Ticks --
local function vcbCreateTicks()
	if VDW.PlayerClassID == 5 then --Priest
		CreateTicks(4, 1)
		CreateTicks(5, 2)
		CreateTicks(6, 3)
	elseif VDW.PlayerClassID == 8 then --Mage
		CreateTicks(4, 1)
		CreateTicks(5, 2)
	elseif VDW.PlayerClassID == 9 then --Warlock
		CreateTicks(5, 1)
	elseif VDW.PlayerClassID == 10 then --Monk
		CreateTicks(3, 1)
		CreateTicks(4, 2)
		CreateTicks(8, 3)
	elseif VDW.PlayerClassID == 11 then --Druid
		CreateTicks(4, 1)
	elseif VDW.PlayerClassID == 13 then --Evoker
		CreateTicks(3, 1)
		CreateTicks(4, 2)
	end
end
-- Show the Ticks --
local function vcbShowTicks(arg3)
	if VDW.PlayerClassID == 5 then ShowPriestTicks(arg3)
	elseif VDW.PlayerClassID == 8 then ShowMageTicks(arg3)
	elseif VDW.PlayerClassID == 9 then ShowWarlockTicks(arg3)
	elseif VDW.PlayerClassID == 10 then ShowMonkTicks(arg3)
	elseif VDW.PlayerClassID == 11 then ShowDruidTicks(arg3)
	elseif VDW.PlayerClassID == 13 then ShowEvokerTicks()
	end
end
-- Hide the Ticks --
local function vcbHideTicks()
	if VDW.PlayerClassID == 5 then --Priest
		HideTicks(4, 1)
		HideTicks(5, 2)
		HideTicks(6, 3)
	elseif VDW.PlayerClassID == 8 then --Mage
		HideTicks(4, 1)
		HideTicks(5, 2)
	elseif VDW.PlayerClassID == 9 then --Warlock
		HideTicks(5, 1)
	elseif VDW.PlayerClassID == 10 then --Monk
		HideTicks(3, 1)
		HideTicks(4, 2)
		HideTicks(8, 3)
	elseif VDW.PlayerClassID == 11 then --Druid
		HideTicks(4, 1)
	elseif VDW.PlayerClassID == 13 then --Evoker
		HideTicks(3, 1)
		HideTicks(4, 2)
	end
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4, arg5)
	if event == "PLAYER_LOGIN" then
		ProtectOptions()
		GlobalFunctionsCHK()
		GlobalFunctionsUPD()
		GlobalFunctionsStyle()
		GlobalFunctionsGCD()
		chkIconPlayer()
		chkNameTxtPlayer()
		chkCurrentTxtPlayer()
		chkBothTxtPlayer()
		chkTotalTxtPlayer()
		chkCurrentUpdPlayer()
		chkBothUpdPlayer()
		chkTotalUpdPlayer()
		chkCastbarColorPlayer()
		chkCastbarBorderColorPlayer()
		chkStylePlayer()
		chkGlobalCooldownPlayer(vcbGCD1)
		vcbCreateTicks()
		borderStyle()
-- Hooking Time part 1 --
		PlayerCastingBarFrame:HookScript("OnShow", function(self)
			namePosition(self)
			currentPostion(self)
			bothPostion(self)
			totalPostion(self)
		end)
-- Hooking Time part 2 --
		PlayerCastingBarFrame:HookScript("OnUpdate", function(self)
			if self.value ~= nil and self.maxValue ~= nil then
				barStyle(self)
				self.Text:SetAlpha(0)
				textName:SetText(self.Text:GetText())
				iconPosition(self)
				currentUpdate(self)
				bothUpdate(self)
				totalUpdate(self)
				if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
					castbarColor(self)
					borderColor(self)
				else
					defaultColor(self)
				end
				if (self.barType == "channel" or self.barType =="uninterruptable") and VCBspecialSettings["Player"]["Ticks"]["Style"] ~= G.OPTIONS_V_HIDE then
					vcbShowTicks(VCBarg3)
				end
			end
		end)
	elseif event == "CURRENT_SPELL_CAST_CHANGED" and arg1 == false then
		lagStart = GetTime()
	elseif event == "UNIT_SPELLCAST_START" and arg1 == "player" then
		local name = C_Spell.GetSpellName(arg3)
		VCBLagCastBar:Hide()
		VCBLagChannelBar:Hide()
		VCBSpellQueueCastBar:Hide()
		VCBSpellQueueChannelBar:Hide()
		PlayerCastLagBar(arg3)
		PlayerCastSpellQueueBar(arg3)
		VCBarg3 = arg3
		if VCBspecialSettings["Player"]["Ticks"]["Style"] ~= G.OPTIONS_V_HIDE then vcbHideTicks() end
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" and arg1 == "player" then
		VCBLagCastBar:Hide()
		VCBLagChannelBar:Hide()
		VCBSpellQueueCastBar:Hide()
		VCBSpellQueueChannelBar:Hide()
		PlayerChannelLagBar(arg3)
		PlayerChannelSpellQueueBar(arg3)
		VCBarg3 = arg3
		if VCBspecialSettings["Player"]["Ticks"]["Style"] ~= G.OPTIONS_V_HIDE then vcbHideTicks() end
	elseif event == "UNIT_SPELLCAST_SENT" and arg1 == "player" then
		if VCBsettings["Player"]["GCD"]["Position"] ~= G.OPTIONS_V_HIDE then
			local spellCooldownInfo = C_Spell.GetSpellCooldown(61304)
			if spellCooldownInfo.duration > 0 then
				startT = GetTime()
				if VCBsettings["Player"]["GCD"]["Style"] == G.OPTIONS_S_CLASS_ICON or VCBsettings["Player"]["GCD"]["Style"] == G.OPTIONS_S_HERO_ICON or VCBsettings["Player"]["GCD"]["Style"] == G.OPTIONS_S_FACTION_ICON then
					vcbGCD1:SetAlpha(1)
					vcbGCD1:SetCooldown(GetTime(), spellCooldownInfo.duration - (startT - lagStart))
				elseif VCBsettings["Player"]["GCD"]["Style"] == G.OPTIONS_S_DEFAULT_BAR then
					vcbGCD1:SetCooldown(GetTime(), spellCooldownInfo.duration - (startT - lagStart))
					vcbGCD2:SetMinMaxValues(0, spellCooldownInfo.duration - (startT - lagStart))
					vcbGCD2:Show()
					vcbGCD1:SetAlpha(0)
					vcbGCD1:HookScript("OnUpdate", function(self)
						local duration = GetTime() - startT
						vcbGCD2:SetValue(duration)
					end)
					vcbGCD1:HookScript("OnCooldownDone", function(self)
						vcbGCD2:Hide()
					end)
				end
			end
		end
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		chkGlobalCooldownPlayer(vcbGCD1)
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
