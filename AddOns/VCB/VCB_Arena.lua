-- local variables --
local G = VDW.Local.Override
local textName1, textName2, textName3
local textCurrent1, textCurrent2, textCurrent3
local textBoth1, textBoth2, textBoth3
local textTotal1, textTotal2, textTotal3
local iconSpell1, iconSpell2, iconSpell3
local shieldSpell1, shieldSpell2, shieldSpell3
local vcbClassColorArena = CreateColor(1, 1, 1, 1)
-- protect the options --
local function ProtectOptions()
	local loc = GetLocale()
	if loc ~= VCBspecialSettings["LastLocation"] then
		for k, v in pairs(VDW.Local.Translate) do
			for i, s in pairs (v) do
				if VCBsettings["Arena"]["NameText"]["Position"] == s then
					VCBsettings["Arena"]["NameText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["CurrentTimeText"]["Position"] == s then
					VCBsettings["Arena"]["CurrentTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == s then
					VCBsettings["Arena"]["CurrentTimeText"]["Direction"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["CurrentTimeText"]["Sec"] == s then
					VCBsettings["Arena"]["CurrentTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["BothTimeText"]["Position"] == s then
					VCBsettings["Arena"]["BothTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["BothTimeText"]["Direction"] == s then
					VCBsettings["Arena"]["BothTimeText"]["Direction"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["BothTimeText"]["Sec"] == s then
					VCBsettings["Arena"]["BothTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["TotalTimeText"]["Position"] == s then
					VCBsettings["Arena"]["TotalTimeText"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["TotalTimeText"]["Sec"] == s then
					VCBsettings["Arena"]["TotalTimeText"]["Sec"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["Icon"]["Position"] == s then
					VCBsettings["Arena"]["Icon"]["Position"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["Icon"]["Shield"] == s then
					VCBsettings["Arena"]["Icon"]["Shield"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["StatusBar"]["Color"] == s then
					VCBsettings["Arena"]["StatusBar"]["Color"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["StatusBar"]["Style"] == s then
					VCBsettings["Arena"]["StatusBar"]["Style"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["Border"]["Color"] == s then
					VCBsettings["Arena"]["Border"]["Color"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["Border"]["Style"] == s then
					VCBsettings["Arena"]["Border"]["Style"] = VDW.Local.Translate[loc][i]
				end
				if VCBsettings["Arena"]["Lock"] == s then
					VCBsettings["Arena"]["Lock"] = VDW.Local.Translate[loc][i]
				end
			end
		end
	end
end
-- function for the default cast bar --
local function createTxtsDefault()
-- function for the texts --
	local function Texts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(CompactArenaFrameMember1.CastingBarFrame.Text:GetHeight())
		var1:Hide()
	end
-- creating the texts --
	for i = 1, 3, 1 do
		_G["textName"..i] = _G["CompactArenaFrameMember"..i].CastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textName"..i])
		_G["textCurrent"..i] = _G["CompactArenaFrameMember"..i].CastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textCurrent"..i])
		_G["textBoth"..i] = _G["CompactArenaFrameMember"..i].CastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textBoth"..i])
		_G["textTotal"..i] = _G["CompactArenaFrameMember"..i].CastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textTotal"..i])
	end
-- copy texture of spell's icon --
	for i = 1, 3, 1 do
		_G["iconSpell"..i] = _G["CompactArenaFrameMember"..i].CastingBarFrame:CreateTexture(nil, "ARTWORK", nil, 0)
		_G["iconSpell"..i]:SetWidth(_G["CompactArenaFrameMember"..i].CastingBarFrame.Icon:GetWidth())
		_G["iconSpell"..i]:SetHeight(_G["CompactArenaFrameMember"..i].CastingBarFrame.Icon:GetWidth())
		_G["iconSpell"..i]:Hide()
	end
	for i = 1, 3, 1 do
		_G["shieldSpell"..i] = _G["CompactArenaFrameMember"..i].CastingBarFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
		_G["shieldSpell"..i]:SetAtlas("ui-castingbar-shield", false)
		_G["shieldSpell"..i]:SetPoint("CENTER", _G["iconSpell"..i], "CENTER", -1, -3)
		_G["shieldSpell"..i]:SetSize(29, 33)
		_G["shieldSpell"..i]:SetBlendMode("BLEND")
		_G["shieldSpell"..i]:SetAlpha(0.75)
		_G["shieldSpell"..i]:Hide()
	end
end
-- function for the s.u.f cast bar --
local function createTxtsSUF()
-- creating the castbars --
	for i = 1, 3, 1 do
		local statusbar = CreateFrame("StatusBar", "SUFHeaderarenaUnitButton"..i.."vcb2Castbar", _G["SUFHeaderarenaUnitButton"..i], "SmallCastingBarFrameTemplate")
		_G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:SetSize(150, 10)
		_G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:ClearAllPoints()
		if i == 1 then _G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBsettings["Arena"]["Position"]["X"], VCBsettings["Arena"]["Position"]["Y"])
		else _G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:SetPoint("TOP", _G["SUFHeaderarenaUnitButton"..(i-1).."vcb2Castbar"], "BOTTOM", 0, -32) end
		_G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:SetScale(VCBsettings["Arena"]["Scale"]/100)
		_G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:OnLoad("arena"..i, true, true)
	end
-- function for the texts --
	local function Texts(var1)
		var1:SetFontObject("SystemFont_Shadow_Small")
		var1:SetHeight(SUFHeaderarenaUnitButton1vcb2Castbar.Text:GetHeight())
		var1:Hide()
	end
-- creating the texts --
	for i = 1, 3, 1 do
		_G["textName"..i] = _G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textName"..i])
		_G["textCurrent"..i] = _G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textCurrent"..i])
		_G["textBoth"..i] = _G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textBoth"..i])
		_G["textTotal"..i] = _G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:CreateFontString(nil, "OVERLAY", nil)
		Texts(_G["textTotal"..i])
	end
-- copy texture of spell's icon --
	for i = 1, 3, 1 do
		_G["iconSpell"..i] = _G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:CreateTexture(nil, "ARTWORK", nil, 0)
		_G["iconSpell"..i]:SetWidth(_G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"].Icon:GetWidth())
		_G["iconSpell"..i]:SetHeight(_G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"].Icon:GetWidth())
		_G["iconSpell"..i]:Hide()
	end
	for i = 1, 3, 1 do
		_G["shieldSpell"..i] = _G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:CreateTexture(nil, "BACKGROUND", nil, 0)
		_G["shieldSpell"..i]:SetAtlas("ui-castingbar-shield", false)
		_G["shieldSpell"..i]:SetPoint("CENTER", _G["iconSpell"..i], "CENTER", -1, -3)
		_G["shieldSpell"..i]:SetSize(29, 33)
		_G["shieldSpell"..i]:SetBlendMode("BLEND")
		_G["shieldSpell"..i]:SetAlpha(0.75)
		_G["shieldSpell"..i]:Hide()
	end
end
-- name position --
local function namePosition(self, i)
	print("namePosition is not Working!")
end
-- current time position --
local function currentPostion(self, i)
	print("currentPostion is not Working!")
end
-- both time position --
local function bothPostion(self, i)
	print("bothPostion is not Working!")
end
-- total time position--
local function totalPostion(self, i)
	print("totalPostion is not Working!")
end
-- icon position --
local function iconPosition(self, i)
	print("iconPosition is not Working!")
end
-- current time update --
local function currentUpdate(self, i)
	print("currentUpdate is not Working!")
end
-- both time update --
local function bothUpdate(self, i)
	print("bothUpdate is not Working!")
end
-- total time update--
local function totalUpdate(self, i)
	print("totalUpdate is not Working!")
end
-- cast bar color --
local function castbarColor(self, i)
	print("castbarColor is not Working!")
end
-- border color --
local function borderColor(self, i)
	print("borderColor is not Working!")
end
-- position functions --
local function GlobalFunctionsCHK()
-- icon --
	function chkIconArena()
		if VCBsettings["Arena"]["Icon"]["Shield"] == G.OPTIONS_V_HIDE then
			if VCBsettings["Arena"]["Icon"]["Position"] == G.OPTIONS_V_HIDE then
				function iconPosition(self, i)
					if self.Icon:IsShown() then self.Icon:Hide() end
					if _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Hide() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
				end
			elseif VCBsettings["Arena"]["Icon"]["Position"] == G.OPTIONS_P_LEFT then
				function iconPosition(self, i)
					if not self.Icon:IsShown() then self.Icon:Show() end
					if _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Hide() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
				end
			elseif VCBsettings["Arena"]["Icon"]["Position"] == G.OPTIONS_P_RIGHT then
				function iconPosition(self, i)
					if self.Icon:IsShown() then self.Icon:Hide() end
					_G["iconSpell"..i]:ClearAllPoints()
					_G["iconSpell"..i]:SetPoint("LEFT", self, "RIGHT", 2, -4)
					_G["iconSpell"..i]:SetTexture(self.Icon:GetTextureFileID())
					if not _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Show() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
				end
			elseif VCBsettings["Arena"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				function iconPosition(self, i)
					if not self.Icon:IsShown() then self.Icon:Show() end
					_G["iconSpell"..i]:ClearAllPoints()
					_G["iconSpell"..i]:SetPoint("LEFT", self, "RIGHT", 2, -4)
					_G["iconSpell"..i]:SetTexture(self.Icon:GetTextureFileID())
					if not _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Show() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
				end
			end
		elseif VCBsettings["Arena"]["Icon"]["Shield"] == G.OPTIONS_V_SHOW then
			if VCBsettings["Arena"]["Icon"]["Position"] == G.OPTIONS_P_LEFT then
				function iconPosition(self, i)
					if not self.Icon:IsShown() then self.Icon:Show() end
					if _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Hide() end
					if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
					if self.barType == "uninterruptable" then
						if not self.BorderShield:IsShown() then self.BorderShield:Show() end
					end
				end
			elseif VCBsettings["Arena"]["Icon"]["Position"] == G.OPTIONS_P_RIGHT then
				function iconPosition(self, i)
					if self.Icon:IsShown() then self.Icon:Hide() end
					_G["iconSpell"..i]:ClearAllPoints()
					_G["iconSpell"..i]:SetPoint("LEFT", self, "RIGHT", 2, -4)
					_G["iconSpell"..i]:SetTexture(self.Icon:GetTextureFileID())
					if not _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Show() end
					if self.BorderShield:IsShown() then self.BorderShield:Hide() end
					if self.barType == "uninterruptable" then
						if not _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Show() end
					else
						if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
					end
				end
			elseif VCBsettings["Arena"]["Icon"]["Position"] == G.OPTIONS_P_BOTH then
				function iconPosition(self, i)
					if not self.Icon:IsShown() then self.Icon:Show() end
					_G["iconSpell"..i]:ClearAllPoints()
					_G["iconSpell"..i]:SetPoint("LEFT", self, "RIGHT", 2, -4)
					_G["iconSpell"..i]:SetTexture(self.Icon:GetTextureFileID())
					if not _G["iconSpell"..i]:IsShown() then _G["iconSpell"..i]:Show() end
					if self.barType == "uninterruptable" then
						if not self.BorderShield:IsShown() then self.BorderShield:Show() end
						if not _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Show() end
					else
						if _G["shieldSpell"..i]:IsShown() then _G["shieldSpell"..i]:Hide() end
					end
				end
			end
		end
	end
-- name --
	function chkNameTxtArena()
		if VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_V_HIDE then
			function namePosition(self, i)
				if _G["textName"..i]:IsShown() then _G["textName"..i]:Hide() end
			end
		elseif VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_P_LEFT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_P_TOP then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_P_CENTER then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_P_RIGHT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["NameText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function namePosition(self, i)
				_G["textName"..i]:ClearAllPoints()
				_G["textName"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not _G["textName"..i]:IsShown() then _G["textName"..i]:Show() end
			end
		end
	end
-- total time --
	function chkTotalTxtArena()
		if VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function totalPostion(self, i)
				if _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Hide() end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function totalPostion(self, i)
				_G["textTotal"..i]:ClearAllPoints()
				_G["textTotal"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not _G["textTotal"..i]:IsShown() then _G["textTotal"..i]:Show() end
			end
		end
	end
-- current time --
	function chkCurrentTxtArena()
		if VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function currentPostion(self, i)
				if _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Hide() end
			end
		elseif VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["CurrentTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function currentPostion(self, i)
				_G["textCurrent"..i]:ClearAllPoints()
				_G["textCurrent"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not _G["textCurrent"..i]:IsShown() then _G["textCurrent"..i]:Show() end
			end
		end
	end
-- both time --
	function chkBothTxtArena()
		if VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function bothPostion(self, i)
				if _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Hide() end
			end
		elseif VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOPLEFT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_P_LEFT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("LEFT", self, "LEFT", 4, 1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOMLEFT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 2)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOP then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("BOTTOM", self, "TOP", 0, -1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_P_CENTER then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("CENTER", self, "CENTER", 0, 1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOM then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("TOP", self, "BOTTOM", 0, 2)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_P_TOPRIGHT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_P_RIGHT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 1)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		elseif VCBsettings["Arena"]["BothTimeText"]["Position"] == G.OPTIONS_P_BOTTOMRIGHT then
			function bothPostion(self, i)
				_G["textBoth"..i]:ClearAllPoints()
				_G["textBoth"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 2)
				if not _G["textBoth"..i]:IsShown() then _G["textBoth"..i]:Show() end
			end
		end
	end
end
-- update functions --
local function GlobalFunctionsUPD()
-- current time --
	function chkCurrentUpdArena()
		if VCBsettings["Arena"]["CurrentTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Arena"]["CurrentTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Arena"]["CurrentTimeText"]["Decimals"] == "0" then
					if VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.0f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.0f", vcb2Value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.0f", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.0f", self.value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.0f", self.value)
						end
					end
				elseif VCBsettings["Arena"]["CurrentTimeText"]["Decimals"] == "1" then
					if VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.1f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.1f", vcb2Value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.1f", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.1f", self.value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.1f", self.value)
						end
					end
				elseif VCBsettings["Arena"]["CurrentTimeText"]["Decimals"] == "2" then
					if VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.2f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.2f", vcb2Value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.2f", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.2f", self.value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.2f", self.value)
						end
					end
				elseif VCBsettings["Arena"]["CurrentTimeText"]["Decimals"] == "3" then
					if VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.3f", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.3f", vcb2Value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.3f", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.3f", self.value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.3f", self.value)
						end
					end
				end
			elseif VCBsettings["Arena"]["CurrentTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Arena"]["CurrentTimeText"]["Decimals"] == "0" then
					if VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.0f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.0f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.0f Sec", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.0f Sec", self.value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.0f Sec", self.value)
						end
					end
				elseif VCBsettings["Arena"]["CurrentTimeText"]["Decimals"] == "1" then
					if VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.1f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.1f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.1f Sec", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.1f Sec", self.value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.1f Sec", self.value)
						end
					end
				elseif VCBsettings["Arena"]["CurrentTimeText"]["Decimals"] == "2" then
					if VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.2f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.2f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.2f Sec", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.2f Sec", self.value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.2f Sec", self.value)
						end
					end
				elseif VCBsettings["Arena"]["CurrentTimeText"]["Decimals"] == "3" then
					if VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function currentUpdate(self, i)
							if self.casting then
								_G["textCurrent"..i]:SetFormattedText("%.3f Sec", self.value)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.3f Sec", vcb2Value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function currentUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textCurrent"..i]:SetFormattedText("%.3f Sec", vcb2Value)
							elseif self.channeling then
								_G["textCurrent"..i]:SetFormattedText("%.3f Sec", self.value)
							end
						end
					elseif VCBsettings["Arena"]["CurrentTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function currentUpdate(self, i)
							_G["textCurrent"..i]:SetFormattedText("%.3f Sec", self.value)
						end
					end
				end
			end
		else
			function currentUpdate(self, i)
				return
			end
		end
	end
-- both time --
	function chkBothUpdArena()
		if VCBsettings["Arena"]["BothTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Arena"]["BothTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Arena"]["BothTimeText"]["Decimals"] == "0" then
					if VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Arena"]["BothTimeText"]["Decimals"] == "1" then
					if VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Arena"]["BothTimeText"]["Decimals"] == "2" then
					if VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Arena"]["BothTimeText"]["Decimals"] == "3" then
					if VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.3f/%.3f", self.value, self.maxValue)
						end
					end
				end
			elseif VCBsettings["Arena"]["BothTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Arena"]["BothTimeText"]["Decimals"] == "0" then
					if VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.0f/%.0f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Arena"]["BothTimeText"]["Decimals"] == "1" then
					if VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.1f/%.1f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Arena"]["BothTimeText"]["Decimals"] == "2" then
					if VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.2f/%.2f Sec", self.value, self.maxValue)
						end
					end
				elseif VCBsettings["Arena"]["BothTimeText"]["Decimals"] == "3" then
					if VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_ASCENDING then
						function bothUpdate(self, i)
							if self.casting then
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
							elseif self.channeling then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", vcb2Value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_D_DESCENDING then
						function bothUpdate(self, i)
							if self.casting then
								local vcb2Value = self.maxValue - self.value
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", vcb2Value, self.maxValue)
							elseif self.channeling then
								_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
							end
						end
					elseif VCBsettings["Arena"]["BothTimeText"]["Direction"] == G.OPTIONS_P_BOTH then
						function bothUpdate(self, i)
							_G["textBoth"..i]:SetFormattedText("%.3f/%.3f Sec", self.value, self.maxValue)
						end
					end
				end
			end
		else
			function bothUpdate(self, i)
				return
			end
		end
	end
-- total time --
	function chkTotalUpdArena()
		if VCBsettings["Arena"]["TotalTimeText"]["Position"] ~= G.OPTIONS_V_HIDE then
			if VCBsettings["Arena"]["TotalTimeText"]["Sec"] == G.OPTIONS_V_HIDE then
				if VCBsettings["Arena"]["TotalTimeText"]["Decimals"] == "0" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.0f", self.maxValue)
					end
				elseif VCBsettings["Arena"]["TotalTimeText"]["Decimals"] == "1" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.1f", self.maxValue)
					end
				elseif VCBsettings["Arena"]["TotalTimeText"]["Decimals"] == "2" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.2f", self.maxValue)
					end
				elseif VCBsettings["Arena"]["TotalTimeText"]["Decimals"] == "3" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.3f", self.maxValue)
					end
				end
			elseif VCBsettings["Arena"]["TotalTimeText"]["Sec"] == G.OPTIONS_V_SHOW then
				if VCBsettings["Arena"]["TotalTimeText"]["Decimals"] == "0" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.0f sec", self.maxValue)
					end
				elseif VCBsettings["Arena"]["TotalTimeText"]["Decimals"] == "1" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.1f sec", self.maxValue)
					end
				elseif VCBsettings["Arena"]["TotalTimeText"]["Decimals"] == "2" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.2f sec", self.maxValue)
					end
				elseif VCBsettings["Arena"]["TotalTimeText"]["Decimals"] == "3" then
					function totalUpdate(self, i)
						_G["textTotal"..i]:SetFormattedText("%.3f sec", self.maxValue)
					end
				end
			end
		elseif VCBsettings["Arena"]["TotalTimeText"]["Position"] == G.OPTIONS_V_HIDE then
			function totalUpdate(self, i)
				return
			end
		end
	end
end
-- color function --
local function GlobalFunctionsCLR()
	function chkCastbarColorArena()
		if VCBsettings["Arena"]["StatusBar"]["Color"] == G.OPTIONS_C_DEFAULT then
			function castbarColor(self, i)
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
				self.Spark:SetDesaturated(false)
				self.Spark:SetVertexColor(1, 1, 1, 1)
				self.Flash:SetDesaturated(false)
				self.Flash:SetVertexColor(1, 1, 1, 1)
			end
		elseif VCBsettings["Arena"]["StatusBar"]["Color"] == G.OPTIONS_C_CLASS then
			function castbarColor(self, i)
				if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
					self:SetStatusBarDesaturated(true)
					self:SetStatusBarColor(vcbClassColorArena:GetRGB())
					self.Spark:SetDesaturated(true)
					self.Spark:SetVertexColor(vcbClassColorArena:GetRGB())
					self.Flash:SetDesaturated(true)
					self.Flash:SetVertexColor(vcbClassColorArena:GetRGB())
				else
					self:SetStatusBarDesaturated(false)
					self:SetStatusBarColor(1, 1, 1, 1)
					self.Spark:SetDesaturated(false)
					self.Spark:SetVertexColor(1, 1, 1, 1)
					self.Flash:SetDesaturated(false)
					self.Flash:SetVertexColor(1, 1, 1, 1)
				end
			end
		end
	end
	function chkBorderColorArena()
		if VCBsettings["Arena"]["Border"]["Color"] == G.OPTIONS_C_DEFAULT then
			function borderColor(self, i)
				self.Background:SetVertexColor(1, 1, 1, 1)
				self.Border:SetVertexColor(1, 1, 1, 1)
				self.TextBorder:SetVertexColor(1, 1, 1, 1)
			end
		elseif VCBsettings["Arena"]["Border"]["Color"] == G.OPTIONS_C_CLASS then
			function borderColor(self, i)
				self.Background:SetVertexColor(vcbClassColorArena:GetRGB())
				self.Border:SetVertexColor(vcbClassColorArena:GetRGB())
				self.TextBorder:SetVertexColor(vcbClassColorArena:GetRGB())
			end
		end
	end
end
-- position bar --
local function positionBar(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBsettings["Arena"]["Position"]["X"], VCBsettings["Arena"]["Position"]["Y"])
end
-- scale bar --
local function scaleBar(self)
	self:SetScale(VCBsettings["Arena"]["Scale"]/100)
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		ProtectOptions()
		if VCBsettings["Arena"]["Lock"] == G.OPTIONS_LS_LOCKED then
			createTxtsDefault()
		elseif VCBsettings["Arena"]["Lock"] == G.OPTIONS_LS_UNLOCKED then
			createTxtsDefault()
			CompactArenaFrameMember1.CastingBarFrame:HookScript("OnUpdate", function(self)
				positionBar(self)
				scaleBar(self)
			end)
			for i=2, 3, 1 do
				_G["CompactArenaFrameMember"..i].CastingBarFrame:HookScript("OnUpdate", function(self)
					self:ClearAllPoints()
					self:SetPoint("TOP", _G["CompactArenaFrameMember"..i-1].CastingBarFrame, "BOTTOM", 0, -32)
					scaleBar(self)
				end)
			end
		elseif VCBsettings["Arena"]["Lock"] == "S.U.F" then
			createTxtsSUF()
			SUFHeaderarenaUnitButton1vcb2Castbar:HookScript("OnUpdate", function(self)
				positionBar(self)
				scaleBar(self)
			end)
			for i=2, 3, 1 do
				_G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:HookScript("OnUpdate", function(self)
					scaleBar(self)
				end)
			end
		end
		GlobalFunctionsCHK()
		GlobalFunctionsUPD()
		GlobalFunctionsCLR()
		chkIconArena()
		chkNameTxtArena()
		chkCurrentTxtArena()
		chkBothTxtArena()
		chkTotalTxtArena()
		chkCurrentUpdArena()
		chkBothUpdArena()
		chkTotalUpdArena()
		chkCastbarColorArena()
		chkBorderColorArena()
		if VCBsettings["Arena"]["Lock"] == G.OPTIONS_LS_LOCKED or VCBsettings["Arena"]["Lock"] == G.OPTIONS_LS_UNLOCKED then
			for i = 1, 3, 1 do
				_G["CompactArenaFrameMember"..i].CastingBarFrame:HookScript("OnShow", function(self)
					local classFilename = UnitClassBase("arena"..i)
					if classFilename ~= nil then vcbClassColorArena = C_ClassColor.GetClassColor(classFilename) end
					namePosition(self, i)
					currentPostion(self, i)
					bothPostion(self, i)
					totalPostion(self, i)
				end)
				_G["CompactArenaFrameMember"..i].CastingBarFrame:HookScript("OnUpdate", function(self)
					if self.value ~= nil and self.maxValue ~= nil then
						self.Text:SetAlpha(0)
						_G["textName"..i]:SetText(self.Text:GetText())
						iconPosition(self, i)
						currentUpdate(self, i)
						bothUpdate(self, i)
						totalUpdate(self, i)
						castbarColor(self, i)
						borderColor(self, i)
					end
				end)
			end
		elseif VCBsettings["Arena"]["Lock"] == "S.U.F" then
			for i = 1, 3, 1 do
				_G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:HookScript("OnShow", function(self)
					local classFilename = UnitClassBase("arena"..i)
					if classFilename ~= nil then vcbClassColorArena = C_ClassColor.GetClassColor(classFilename) end
					namePosition(self, i)
					currentPostion(self, i)
					bothPostion(self, i)
					totalPostion(self, i)
				end)
				_G["SUFHeaderarenaUnitButton"..i.."vcb2Castbar"]:HookScript("OnUpdate", function(self)
					if self.value ~= nil and self.maxValue ~= nil then
						self.Text:SetAlpha(0)
						_G["textName"..i]:SetText(self.Text:GetText())
						iconPosition(self, i)
						currentUpdate(self, i)
						bothUpdate(self, i)
						totalUpdate(self, i)
						castbarColor(self, i)
						borderColor(self, i)
					end
				end)
			end
		end
		VCBspecialSettings["LastLocation"] = GetLocale()
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
