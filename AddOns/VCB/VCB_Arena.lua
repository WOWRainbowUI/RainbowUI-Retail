-- Blizzard Arena Castbars --
local function ArenaSpellBarTexts()
-- Name Text --
	VCBnameTextArena1 = CompactArenaFrameMember1.CastingBarFrame:CreateFontString("VCBnameTextArena1", "OVERLAY", nil)
	VCBnameTextArena2 = CompactArenaFrameMember2.CastingBarFrame:CreateFontString("VCBnameTextArena2", "OVERLAY", nil)
	VCBnameTextArena3 = CompactArenaFrameMember3.CastingBarFrame:CreateFontString("VCBnameTextArena3", "OVERLAY", nil)
	VCBnameTextArena4 = CompactArenaFrameMember4.CastingBarFrame:CreateFontString("VCBnameTextArena4", "OVERLAY", nil)
	VCBnameTextArena5 = CompactArenaFrameMember5.CastingBarFrame:CreateFontString("VCBnameTextArena5", "OVERLAY", nil)
-- Current Time Text --
	VCBcurrentTimeTextArena1 = CompactArenaFrameMember1.CastingBarFrame:CreateFontString("VCBcurrentTimeTextArena1", "OVERLAY", nil)
	VCBcurrentTimeTextArena2 = CompactArenaFrameMember2.CastingBarFrame:CreateFontString("VCBcurrentTimeTextArena2", "OVERLAY", nil)
	VCBcurrentTimeTextArena3 = CompactArenaFrameMember3.CastingBarFrame:CreateFontString("VCBcurrentTimeTextArena3", "OVERLAY", nil)
	VCBcurrentTimeTextArena4 = CompactArenaFrameMember4.CastingBarFrame:CreateFontString("VCBcurrentTimeTextArena4", "OVERLAY", nil)
	VCBcurrentTimeTextArena5 = CompactArenaFrameMember5.CastingBarFrame:CreateFontString("VCBcurrentTimeTextArena5", "OVERLAY", nil)
-- Total Time Text --
	VCBtotalTimeTextArena1 = CompactArenaFrameMember1.CastingBarFrame:CreateFontString("VCBtotalTimeTextArena1", "OVERLAY", nil)
	VCBtotalTimeTextArena2 = CompactArenaFrameMember2.CastingBarFrame:CreateFontString("VCBtotalTimeTextArena2", "OVERLAY", nil)
	VCBtotalTimeTextArena3 = CompactArenaFrameMember3.CastingBarFrame:CreateFontString("VCBtotalTimeTextArena3", "OVERLAY", nil)
	VCBtotalTimeTextArena4 = CompactArenaFrameMember4.CastingBarFrame:CreateFontString("VCBtotalTimeTextArena4", "OVERLAY", nil)
	VCBtotalTimeTextArena5 = CompactArenaFrameMember5.CastingBarFrame:CreateFontString("VCBtotalTimeTextArena5", "OVERLAY", nil)
-- Both Time Text --
	VCBbothTimeTextArena1 = CompactArenaFrameMember1.CastingBarFrame:CreateFontString("VCBbothTimeTextArena1", "OVERLAY", nil)
	VCBbothTimeTextArena2 = CompactArenaFrameMember2.CastingBarFrame:CreateFontString("VCBbothTimeTextArena2", "OVERLAY", nil)
	VCBbothTimeTextArena3 = CompactArenaFrameMember3.CastingBarFrame:CreateFontString("VCBbothTimeTextArena3", "OVERLAY", nil)
	VCBbothTimeTextArena4 = CompactArenaFrameMember4.CastingBarFrame:CreateFontString("VCBbothTimeTextArena4", "OVERLAY", nil)
	VCBbothTimeTextArena5 = CompactArenaFrameMember5.CastingBarFrame:CreateFontString("VCBbothTimeTextArena5", "OVERLAY", nil)
	for i = 1, 3, 1 do
-- name --
		_G["VCBnameTextArena"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBnameTextArena"..i]:SetHeight(_G["CompactArenaFrameMember"..i].CastingBarFrame.Text:GetHeight())
		_G["VCBnameTextArena"..i]:Hide()
-- Current Time Text --
		_G["VCBcurrentTimeTextArena"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBcurrentTimeTextArena"..i]:SetHeight(_G["CompactArenaFrameMember"..i].CastingBarFrame.Text:GetHeight())
		_G["VCBcurrentTimeTextArena"..i]:Hide()
-- Total Time Text --
		_G["VCBtotalTimeTextArena"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBtotalTimeTextArena"..i]:SetHeight(_G["CompactArenaFrameMember"..i].CastingBarFrame.Text:GetHeight())
		_G["VCBtotalTimeTextArena"..i]:Hide()
-- Both Time Text --
		_G["VCBbothTimeTextArena"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBbothTimeTextArena"..i]:SetHeight(_G["CompactArenaFrameMember"..i].CastingBarFrame.Text:GetHeight())
		_G["VCBbothTimeTextArena"..i]:Hide()
	end
end
-- SUF Arena Castbar --
local function sufArenaSpellBarTexts()
-- creating the castbars --
	for i = 1, 5, 1 do
		local statusbar = CreateFrame("StatusBar", "SUFHeaderarenaUnitButton"..i.."vcbCastbar", _G["SUFHeaderarenaUnitButton"..i], "SmallCastingBarFrameTemplate")
		_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"]:SetSize(150, 10)
		_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"]:ClearAllPoints()
		if i == 1 then _G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrArena["Position"]["X"], VCBrArena["Position"]["Y"])
		else _G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"]:SetPoint("TOP", _G["SUFHeaderarenaUnitButton"..(i-1).."vcbCastbar"], "BOTTOM", 0, -32) end
		_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"]:SetScale(VCBrArena["Scale"]/100)
		_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"]:OnLoad("arena"..i, true, true)
	end
-- Name Text --
	VCBnameTextArena1 = SUFHeaderarenaUnitButton1vcbCastbar:CreateFontString("VCBnameTextArena1", "OVERLAY", nil)
	VCBnameTextArena2 = SUFHeaderarenaUnitButton2vcbCastbar:CreateFontString("VCBnameTextArena2", "OVERLAY", nil)
	VCBnameTextArena3 = SUFHeaderarenaUnitButton3vcbCastbar:CreateFontString("VCBnameTextArena3", "OVERLAY", nil)
	VCBnameTextArena4 = SUFHeaderarenaUnitButton4vcbCastbar:CreateFontString("VCBnameTextArena4", "OVERLAY", nil)
	VCBnameTextArena5 = SUFHeaderarenaUnitButton5vcbCastbar:CreateFontString("VCBnameTextArena5", "OVERLAY", nil)
-- Current Time Text --
	VCBcurrentTimeTextArena1 = SUFHeaderarenaUnitButton1vcbCastbar:CreateFontString("VCBcurrentTimeTextArena1", "OVERLAY", nil)
	VCBcurrentTimeTextArena2 = SUFHeaderarenaUnitButton2vcbCastbar:CreateFontString("VCBcurrentTimeTextArena2", "OVERLAY", nil)
	VCBcurrentTimeTextArena3 = SUFHeaderarenaUnitButton3vcbCastbar:CreateFontString("VCBcurrentTimeTextArena3", "OVERLAY", nil)
	VCBcurrentTimeTextArena4 = SUFHeaderarenaUnitButton4vcbCastbar:CreateFontString("VCBcurrentTimeTextArena4", "OVERLAY", nil)
	VCBcurrentTimeTextArena5 = SUFHeaderarenaUnitButton5vcbCastbar:CreateFontString("VCBcurrentTimeTextArena5", "OVERLAY", nil)
-- Total Time Text --
	VCBtotalTimeTextArena1 = SUFHeaderarenaUnitButton1vcbCastbar:CreateFontString("VCBtotalTimeTextArena1", "OVERLAY", nil)
	VCBtotalTimeTextArena2 = SUFHeaderarenaUnitButton2vcbCastbar:CreateFontString("VCBtotalTimeTextArena2", "OVERLAY", nil)
	VCBtotalTimeTextArena3 = SUFHeaderarenaUnitButton3vcbCastbar:CreateFontString("VCBtotalTimeTextArena3", "OVERLAY", nil)
	VCBtotalTimeTextArena4 = SUFHeaderarenaUnitButton4vcbCastbar:CreateFontString("VCBtotalTimeTextArena4", "OVERLAY", nil)
	VCBtotalTimeTextArena5 = SUFHeaderarenaUnitButton5vcbCastbar:CreateFontString("VCBtotalTimeTextArena5", "OVERLAY", nil)
-- Both Time Text --
	VCBbothTimeTextArena1 = SUFHeaderarenaUnitButton1vcbCastbar:CreateFontString("VCBbothTimeTextArena1", "OVERLAY", nil)
	VCBbothTimeTextArena2 = SUFHeaderarenaUnitButton2vcbCastbar:CreateFontString("VCBbothTimeTextArena2", "OVERLAY", nil)
	VCBbothTimeTextArena3 = SUFHeaderarenaUnitButton3vcbCastbar:CreateFontString("VCBbothTimeTextArena3", "OVERLAY", nil)
	VCBbothTimeTextArena4 = SUFHeaderarenaUnitButton4vcbCastbar:CreateFontString("VCBbothTimeTextArena4", "OVERLAY", nil)
	VCBbothTimeTextArena5 = SUFHeaderarenaUnitButton5vcbCastbar:CreateFontString("VCBbothTimeTextArena5", "OVERLAY", nil)
	for i = 1, 3, 1 do
-- name --
		_G["VCBnameTextArena"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBnameTextArena"..i]:SetHeight(_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBnameTextArena"..i]:Hide()
-- Current Time Text --
		_G["VCBcurrentTimeTextArena"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBcurrentTimeTextArena"..i]:SetHeight(_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBcurrentTimeTextArena"..i]:Hide()
-- Total Time Text --
		_G["VCBtotalTimeTextArena"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBtotalTimeTextArena"..i]:SetHeight(_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBtotalTimeTextArena"..i]:Hide()
-- Both Time Text --
		_G["VCBbothTimeTextArena"..i]:SetFontObject("SystemFont_Shadow_Small")
		_G["VCBbothTimeTextArena"..i]:SetHeight(_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"].Text:GetHeight())
		_G["VCBbothTimeTextArena"..i]:Hide()
	end
end
-- Name position --
function chkArenaNamePosition()
	if VCBrArena["NameText"] == "Top Left" then
		function vcbArenaNamePosition(self, i)
			_G["VCBnameTextArena"..i]:ClearAllPoints()
			_G["VCBnameTextArena"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			_G["VCBnameTextArena"..i]:SetJustifyH("LEFT")
			if not _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Show() end
		end
	elseif VCBrArena["NameText"] == "Left" then
		function vcbArenaNamePosition(self, i)
			_G["VCBnameTextArena"..i]:ClearAllPoints()
			_G["VCBnameTextArena"..i]:SetPoint("LEFT", self, "LEFT", 4, 0)
			_G["VCBnameTextArena"..i]:SetJustifyH("LEFT")
			if not _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Show() end
		end
	elseif VCBrArena["NameText"] == "Bottom Left" then
		function vcbArenaNamePosition(self, i)
			_G["VCBnameTextArena"..i]:ClearAllPoints()
			_G["VCBnameTextArena"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			_G["VCBnameTextArena"..i]:SetJustifyH("LEFT")
			if not _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Show() end
		end
	elseif VCBrArena["NameText"] == "Top" then
		function vcbArenaNamePosition(self, i)
			_G["VCBnameTextArena"..i]:ClearAllPoints()
			_G["VCBnameTextArena"..i]:SetPoint("BOTTOM", self, "TOP", 0, -2)
			_G["VCBnameTextArena"..i]:SetJustifyH("CENTER")
			if not _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Show() end
		end
	elseif VCBrArena["NameText"] == "Center" then
		function vcbArenaNamePosition(self, i)
			_G["VCBnameTextArena"..i]:ClearAllPoints()
			_G["VCBnameTextArena"..i]:SetPoint("CENTER", self, "CENTER", 0, 0)
			_G["VCBnameTextArena"..i]:SetJustifyH("CENTER")
			if not _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Show() end
		end
	elseif VCBrArena["NameText"] == "Bottom" then
		function vcbArenaNamePosition(self, i)
			_G["VCBnameTextArena"..i]:ClearAllPoints()
			_G["VCBnameTextArena"..i]:SetPoint("TOP", self, "BOTTOM", 0, 1)
			_G["VCBnameTextArena"..i]:SetJustifyH("CENTER")
			if not _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Show() end
		end
	elseif VCBrArena["NameText"] == "Top Right" then
		function vcbArenaNamePosition(self, i)
			_G["VCBnameTextArena"..i]:ClearAllPoints()
			_G["VCBnameTextArena"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			_G["VCBnameTextArena"..i]:SetJustifyH("RIGHT")
			if not _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Show() end
		end
	elseif VCBrArena["NameText"] == "Right" then
		function vcbArenaNamePosition(self, i)
			_G["VCBnameTextArena"..i]:ClearAllPoints()
			_G["VCBnameTextArena"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			_G["VCBnameTextArena"..i]:SetJustifyH("RIGHT")
			if not _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Show() end
		end
	elseif VCBrArena["NameText"] == "Bottom Right" then
		function vcbArenaNamePosition(self, i)
			_G["VCBnameTextArena"..i]:ClearAllPoints()
			_G["VCBnameTextArena"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			_G["VCBnameTextArena"..i]:SetJustifyH("RIGHT")
			if not _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Show() end
		end
	elseif VCBrArena["NameText"] == "Hide" then
		function vcbArenaNamePosition(self, i)
			if _G["VCBnameTextArena"..i]:IsShown() then _G["VCBnameTextArena"..i]:Hide() end
		end
	end
end
-- Current time position --
function chkArenaCurrentTimePosition()
	if VCBrArena["CurrentTimeText"]["Position"] == "Top Left" then
		function vcbArenaCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextArena"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextArena"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["CurrentTimeText"]["Position"] == "Left" then
		function vcbArenaCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextArena"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextArena"..i]:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["CurrentTimeText"]["Position"] == "Bottom Left" then
		function vcbArenaCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextArena"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextArena"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["CurrentTimeText"]["Position"] == "Top" then
		function vcbArenaCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextArena"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextArena"..i]:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["CurrentTimeText"]["Position"] == "Center" then
		function vcbArenaCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextArena"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextArena"..i]:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["CurrentTimeText"]["Position"] == "Bottom" then
		function vcbArenaCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextArena"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextArena"..i]:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["CurrentTimeText"]["Position"] == "Top Right" then
		function vcbArenaCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextArena"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextArena"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["CurrentTimeText"]["Position"] == "Right" then
		function vcbArenaCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextArena"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextArena"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["CurrentTimeText"]["Position"] == "Bottom Right" then
		function vcbArenaCurrentTimePosition(self, i)
			_G["VCBcurrentTimeTextArena"..i]:ClearAllPoints()
			_G["VCBcurrentTimeTextArena"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["CurrentTimeText"]["Position"] == "Hide" then
		function vcbArenaCurrentTimePosition(self, i)
			if _G["VCBcurrentTimeTextArena"..i]:IsShown() then _G["VCBcurrentTimeTextArena"..i]:Hide() end
		end
	end
end
-- Both time position --
function chkArenaBothTimePosition()
	if VCBrArena["BothTimeText"]["Position"] == "Top Left" then
		function vcbArenaBothTimePosition(self, i)	
			_G["VCBbothTimeTextArena"..i]:ClearAllPoints()
			_G["VCBbothTimeTextArena"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["BothTimeText"]["Position"] == "Left" then
		function vcbArenaBothTimePosition(self, i)	
			_G["VCBbothTimeTextArena"..i]:ClearAllPoints()
			_G["VCBbothTimeTextArena"..i]:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["BothTimeText"]["Position"] == "Bottom Left" then
		function vcbArenaBothTimePosition(self, i)	
			_G["VCBbothTimeTextArena"..i]:ClearAllPoints()
			_G["VCBbothTimeTextArena"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["BothTimeText"]["Position"] == "Top" then
		function vcbArenaBothTimePosition(self, i)	
			_G["VCBbothTimeTextArena"..i]:ClearAllPoints()
			_G["VCBbothTimeTextArena"..i]:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["BothTimeText"]["Position"] == "Center" then
		function vcbArenaBothTimePosition(self, i)	
			_G["VCBbothTimeTextArena"..i]:ClearAllPoints()
			_G["VCBbothTimeTextArena"..i]:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["BothTimeText"]["Position"] == "Bottom" then
		function vcbArenaBothTimePosition(self, i)	
			_G["VCBbothTimeTextArena"..i]:ClearAllPoints()
			_G["VCBbothTimeTextArena"..i]:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["BothTimeText"]["Position"] == "Top Right" then
		function vcbArenaBothTimePosition(self, i)	
			_G["VCBbothTimeTextArena"..i]:ClearAllPoints()
			_G["VCBbothTimeTextArena"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["BothTimeText"]["Position"] == "Right" then
		function vcbArenaBothTimePosition(self, i)	
			_G["VCBbothTimeTextArena"..i]:ClearAllPoints()
			_G["VCBbothTimeTextArena"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["BothTimeText"]["Position"] == "Bottom Right" then
		function vcbArenaBothTimePosition(self, i)	
			_G["VCBbothTimeTextArena"..i]:ClearAllPoints()
			_G["VCBbothTimeTextArena"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["BothTimeText"]["Position"] == "Hide" then
		function vcbArenaBothTimePosition(self, i)	
			if _G["VCBbothTimeTextArena"..i]:IsShown() then _G["VCBbothTimeTextArena"..i]:Hide() end
		end
	end
end
-- Total Time position --
function chkArenaTotalTimePosition()
	if VCBrArena["TotalTimeText"]["Position"] == "Top Left" then
		function vcbArenaTotalTimePosition(self, i)
			_G["VCBtotalTimeTextArena"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextArena"..i]:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -2)
			if not _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["TotalTimeText"]["Position"] == "Left" then
		function vcbArenaTotalTimePosition(self, i)
			_G["VCBtotalTimeTextArena"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextArena"..i]:SetPoint("LEFT", self, "LEFT", 4, 0)
			if not _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["TotalTimeText"]["Position"] == "Bottom Left" then
		function vcbArenaTotalTimePosition(self, i)
			_G["VCBtotalTimeTextArena"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextArena"..i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 5, 1)
			if not _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["TotalTimeText"]["Position"] == "Top" then
		function vcbArenaTotalTimePosition(self, i)
			_G["VCBtotalTimeTextArena"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextArena"..i]:SetPoint("BOTTOM", self, "TOP", 0, -2)
			if not _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["TotalTimeText"]["Position"] == "Center" then
		function vcbArenaTotalTimePosition(self, i)
			_G["VCBtotalTimeTextArena"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextArena"..i]:SetPoint("CENTER", self, "CENTER", 0, 0)
			if not _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["TotalTimeText"]["Position"] == "Bottom" then
		function vcbArenaTotalTimePosition(self, i)
			_G["VCBtotalTimeTextArena"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextArena"..i]:SetPoint("TOP", self, "BOTTOM", 0, 1)
			if not _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["TotalTimeText"]["Position"] == "Top Right" then
		function vcbArenaTotalTimePosition(self, i)
			_G["VCBtotalTimeTextArena"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextArena"..i]:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -2)
			if not _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["TotalTimeText"]["Position"] == "Right" then
		function vcbArenaTotalTimePosition(self, i)
			_G["VCBtotalTimeTextArena"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextArena"..i]:SetPoint("RIGHT", self, "RIGHT", -4, 0)
			if not _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["TotalTimeText"]["Position"] == "Bottom Right" then
		function vcbArenaTotalTimePosition(self, i)
			_G["VCBtotalTimeTextArena"..i]:ClearAllPoints()
			_G["VCBtotalTimeTextArena"..i]:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -5, 1)
			if not _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Show() end
		end
	elseif VCBrArena["TotalTimeText"]["Position"] == "Hide" then
		function vcbArenaTotalTimePosition(self, i)
			if _G["VCBtotalTimeTextArena"..i]:IsShown() then _G["VCBtotalTimeTextArena"..i]:Hide() end
		end
	end
end
-- Current time update --
function chkArenaCurrentTimeUpdate()
	if VCBrArena["CurrentTimeText"]["Decimals"] == 2 then
		if VCBrArena["CurrentTimeText"]["Sec"] == "Show" then
			if VCBrArena["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f sec", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f sec", VCBdescending)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f sec", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f sec", self.value)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Both" then
				function vcbArenaCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f sec", self.value)
				end
			end
		elseif VCBrArena["CurrentTimeText"]["Sec"] == "Hide" then
			if VCBrArena["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f", VCBdescending)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f", self.value)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Both" then
				function vcbArenaCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.2f", self.value)
				end
			end
		end
	elseif VCBrArena["CurrentTimeText"]["Decimals"] == 1 then
		if VCBrArena["CurrentTimeText"]["Sec"] == "Show" then
			if VCBrArena["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f sec", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f sec", VCBdescending)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f sec", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f sec", self.value)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Both" then
				function vcbArenaCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f sec", self.value)
				end
			end
		elseif VCBrArena["CurrentTimeText"]["Sec"] == "Hide" then
			if VCBrArena["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f", VCBdescending)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f", self.value)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Both" then
				function vcbArenaCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.1f", self.value)
				end
			end
		end
	elseif VCBrArena["CurrentTimeText"]["Decimals"] == 0 then
		if VCBrArena["CurrentTimeText"]["Sec"] == "Show" then
			if VCBrArena["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f sec", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f sec", VCBdescending)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f sec", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f sec", self.value)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Both" then
				function vcbArenaCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f sec", self.value)
				end
			end
		elseif VCBrArena["CurrentTimeText"]["Sec"] == "Hide" then
			if VCBrArena["CurrentTimeText"]["Direction"] == "Ascending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f", self.value)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f", VCBdescending)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Descending" then
				function vcbArenaCurrentTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f", VCBdescending)
					elseif self.channeling then
						_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f", self.value)
					end
				end
			elseif VCBrArena["CurrentTimeText"]["Direction"] == "Both" then
				function vcbArenaCurrentTimeUpdate(self, i)
					_G["VCBcurrentTimeTextArena"..i]:SetFormattedText("%.0f", self.value)
				end
			end
		end
	end
end
-- Both time update --
function chkArenaBothTimeUpdate()
	if VCBrArena["BothTimeText"]["Decimals"] == 2 then
		if VCBrArena["BothTimeText"]["Sec"] == "Show" then
			if VCBrArena["BothTimeText"]["Direction"] == "Ascending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Descending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f sec", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Both" then
				function vcbArenaBothTimeUpdate(self, i)
					_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f sec", self.value, self.maxValue)
				end
			end
		elseif VCBrArena["BothTimeText"]["Sec"] == "Hide" then
			if VCBrArena["BothTimeText"]["Direction"] == "Ascending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Descending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Both" then
				function vcbArenaBothTimeUpdate(self, i)
					_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.2f/%.2f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrArena["BothTimeText"]["Decimals"] == 1 then
		if VCBrArena["BothTimeText"]["Sec"] == "Show" then
			if VCBrArena["BothTimeText"]["Direction"] == "Ascending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Descending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f sec", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Both" then
				function vcbArenaBothTimeUpdate(self, i)
					_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f sec", self.value, self.maxValue)
				end
			end
		elseif VCBrArena["BothTimeText"]["Sec"] == "Hide" then
			if VCBrArena["BothTimeText"]["Direction"] == "Ascending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Descending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Both" then
				function vcbArenaBothTimeUpdate(self, i)
					_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.1f/%.1f", self.value, self.maxValue)
				end
			end
		end
	elseif VCBrArena["BothTimeText"]["Decimals"] == 0 then
		if VCBrArena["BothTimeText"]["Sec"] == "Show" then
			if VCBrArena["BothTimeText"]["Direction"] == "Ascending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Descending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f sec", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Both" then
				function vcbArenaBothTimeUpdate(self, i)
					_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f sec", self.value, self.maxValue)
				end
			end
		elseif VCBrArena["BothTimeText"]["Sec"] == "Hide" then
			if VCBrArena["BothTimeText"]["Direction"] == "Ascending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					elseif self.channeling then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Descending" then
				function vcbArenaBothTimeUpdate(self, i)
					if self.casting then
						local VCBdescending = self.maxValue - self.value
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f", VCBdescending, self.maxValue)
					elseif self.channeling then
						_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
					end
				end
			elseif VCBrArena["BothTimeText"]["Direction"] == "Both" then
				function vcbArenaBothTimeUpdate(self, i)
					_G["VCBbothTimeTextArena"..i]:SetFormattedText("%.0f/%.0f", self.value, self.maxValue)
				end
			end
		end
	end
end
-- Total time update --
function chkArenaTotalTimeUpdate()
	if VCBrArena["TotalTimeText"]["Sec"] == "Show" then
		if VCBrArena["TotalTimeText"]["Decimals"] == 2 then
			function vcbArenaTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextArena"..i]:SetFormattedText("%.2f sec", self.maxValue)
			end
		elseif VCBrArena["TotalTimeText"]["Decimals"] == 1 then
			function vcbArenaTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextArena"..i]:SetFormattedText("%.1f sec", self.maxValue)
			end
		elseif VCBrArena["TotalTimeText"]["Decimals"] == 0 then
			function vcbArenaTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextArena"..i]:SetFormattedText("%.0f sec", self.maxValue)
			end
		end
	elseif VCBrArena["TotalTimeText"]["Sec"] == "Hide" then
		if VCBrArena["TotalTimeText"]["Decimals"] == 2 then
			function vcbArenaTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextArena"..i]:SetFormattedText("%.2f", self.maxValue)
			end
		elseif VCBrArena["TotalTimeText"]["Decimals"] == 1 then
			function vcbArenaTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextArena"..i]:SetFormattedText("%.1f", self.maxValue)
			end
		elseif VCBrArena["TotalTimeText"]["Decimals"] == 0 then
			function vcbArenaTotalTimeUpdate(self, i)
				_G["VCBtotalTimeTextArena"..i]:SetFormattedText("%.0f", self.maxValue)
			end
		end
	end
end
-- Coloring the bar --
function chkArenaCastbarColor()
	if VCBrArena["Color"] == "Default Color" then
		function vcbArenaCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	elseif VCBrArena["Color"] == "Class' Color" then
		function vcbArenaCastbarColor(self)
			if self.barType == "standard" or self.barType == "channel" or self.barType == "uninterruptable" then
				self:SetStatusBarDesaturated(true)
				self:SetStatusBarColor(vcbClassColorArena:GetRGB())
			else
				self:SetStatusBarDesaturated(false)
				self:SetStatusBarColor(1, 1, 1, 1)
			end
		end
	end
end
-- Position of  the bar --
function vcbArenaCastbarPosition(self)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrArena["Position"]["X"], VCBrArena["Position"]["Y"])
end
-- Scale of the bar --
function vcbArenaCastbarScale(self)
	self:SetScale(VCBrArena["Scale"]/100)
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		if VCBrArena["otherAdddon"] == "None" then
			ArenaSpellBarTexts()
		elseif VCBrArena["otherAdddon"] == "Shadowed Unit Frame" then
			sufArenaSpellBarTexts()
			SUFHeaderarenaUnitButton1vcbCastbar:HookScript("OnUpdate", function(self)
				vcbArenaCastbarPosition(self)
			end)
		end
		chkArenaNamePosition()
		chkArenaCurrentTimePosition()
		chkArenaBothTimePosition()
		chkArenaTotalTimePosition()
		chkArenaCurrentTimeUpdate()
		chkArenaBothTimeUpdate()
		chkArenaTotalTimeUpdate()
		chkArenaCastbarColor()
		if VCBrArena["otherAdddon"] == "None" then
			for i = 1, 3, 1 do
				_G["CompactArenaFrameMember"..i].CastingBarFrame:HookScript("OnShow", function(self)
					local classFilename = UnitClassBase("arena"..i)
					if classFilename ~= nil then vcbClassColorArena = C_ClassColor.GetClassColor(classFilename) end
					_G["VCBnameTextArena"..i]:SetWidth(self:GetWidth())
					vcbArenaNamePosition(self, i)
					vcbArenaCurrentTimePosition(self, i)
					vcbArenaBothTimePosition(self, i)
					vcbArenaTotalTimePosition(self, i)
				end)
				_G["CompactArenaFrameMember"..i].CastingBarFrame:HookScript("OnUpdate", function(self)
					vcbArenaCastbarColor(self)
					self.Text:SetAlpha(0)
					_G["VCBnameTextArena"..i]:SetText(self.Text:GetText())
					if self.value ~= nil and self.maxValue ~= nil then
						vcbArenaCurrentTimeUpdate(self, i)
						vcbArenaBothTimeUpdate(self, i)
						vcbArenaTotalTimeUpdate(self, i)
					end
				end)
			end
		elseif VCBrArena["otherAdddon"] == "Shadowed Unit Frame" then
			for i = 1, 3, 1 do
				_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"]:HookScript("OnShow", function(self)
					self:SetScale(VCBrArena["Scale"]/100)
					local classFilename = UnitClassBase("arena"..i)
					if classFilename ~= nil then vcbClassColorArena = C_ClassColor.GetClassColor(classFilename) end
					_G["VCBnameTextArena"..i]:SetWidth(self:GetWidth())
					vcbArenaNamePosition(self, i)
					vcbArenaCurrentTimePosition(self, i)
					vcbArenaBothTimePosition(self, i)
					vcbArenaTotalTimePosition(self, i)
				end)
				_G["SUFHeaderarenaUnitButton"..i.."vcbCastbar"]:HookScript("OnUpdate", function(self)
					vcbArenaCastbarColor(self)
					self.Text:SetAlpha(0)
					_G["VCBnameTextArena"..i]:SetText(self.Text:GetText())
					if self.value ~= nil and self.maxValue ~= nil then
						vcbArenaCurrentTimeUpdate(self, i)
						vcbArenaBothTimeUpdate(self, i)
						vcbArenaTotalTimeUpdate(self, i)
					end
				end)
			end
		end		
	end
end
vcbZlave:HookScript("OnEvent", EventsTime)
