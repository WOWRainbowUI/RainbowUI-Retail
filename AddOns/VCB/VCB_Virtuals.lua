-- Colors --
vcbMainColor = CreateColorFromRGBAHexString("F0E68CFF")
vcbHighColor = CreateColorFromRGBAHexString("9ACD32FF")
vcbDeafultColor = CreateColorFromRGBAHexString("FFFFFFFF")
vcbNoColor  = CreateColorFromRGBAHexString("00000000")
-- function for showing the menu --
function vcbShowMenu()
	if not vcbOptions00:IsShown() then
		vcbOptions00:Show()
	else
		vcbOptions00:Hide()
	end
end
-- Slash Command --
SLASH_VOODOOCASTINGBAR1, SLASH_VOODOOCASTINGBAR2 = '/vcb', '/voodoocastingbar'
function SlashCmdList.VOODOOCASTINGBAR(msg, editBox)
	vcbShowMenu()
end
-- Mini Map Button Functions --
-- Clicky Clicky --
function vcbMinimapClick(addonName, buttonName)
	if buttonName == "LeftButton" then
		vcbShowMenu()
	end
end
-- On Enter --
function vcbMinimapOnEnter()
	GameTooltip_ClearStatusBars(GameTooltip)
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	GameTooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nClick: "..vcbMainColor:WrapTextInColorCode("Open the main panel of settings!")) 
	GameTooltip:Show()
end
-- On Leave --
function vcbMinimapOnLeave()
	GameTooltip:Hide()
end
-- functions for the buttons and popouts --
-- on enter --
function vcbEnteringMenus(self)
	GameTooltip_ClearStatusBars(GameTooltip)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("RIGHT", self, "LEFT", 0, 0)
end
-- on leave --
function vcbLeavingMenus()
	GameTooltip:Hide()
end
-- click on Pop Out --
function vcbClickPopOut(var1, var2)
	var1:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" and down == false then
			if not var2:IsShown() then
				var2:Show()
				PlaySound(855, "Master")
			else
				var2:Hide()
			end
		end
	end)
end
-- Creating the ticks for the player's castbar --
-- Create Ticks 3 --
local function Create3Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 3
	for i = 1, 3, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB3spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB3spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB3spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 4 --
local function Create4Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 4
	for i = 1, 4, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB4spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB4spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB4spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 5 --
local function Create5Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 5
	for i = 1, 5, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB5spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB5spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB5spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 6 --
local function Create6Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 6
	for i = 1, 6, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB6spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB6spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB6spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 7 --
local function Create7Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 7
	for i = 1, 7, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB7spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB7spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB7spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		end
	end
end
-- Create Ticks 8 --
local function Create8Ticks()
	spaceTick = PlayerCastingBarFrame:GetWidth() / 8
	for i = 1, 8, 1 do
		if i == 1 then
			local tick = PlayerCastingBarFrame:CreateTexture("VCB8spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("CENTER", PlayerCastingBarFrame, "LEFT", 0, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
			tick:Hide()
		else
			local tick = PlayerCastingBarFrame:CreateTexture("VCB8spark".. i, "OVERLAY", nil, 7)
			tick:SetAtlas("ui-castingbar-empower-cursor", true)
			tick:SetHeight(PlayerCastingBarFrame:GetHeight())
			tick:ClearAllPoints()
			tick:SetPoint("LEFT", "VCB8spark".. i-1, "LEFT", spaceTick, 0)
			tick:SetBlendMode("BLEND")
			tick:SetVertexColor(1, 1, 1, 1)
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
-- Penance, Mind Flay Insanity --
	if arg3 == 391403 or arg3 == 47757 or arg3 == 47540 then
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
local function ShowEvokerTicks(arg3)
-- Disintegrate --
	if arg3 == 356995 then
		Show3Ticks()
	end
end
-- Create the Ticks --
function vcbCreateTicks()
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
	end
end
-- Show the Ticks --
function vcbShowTicks(arg3)
	if classID == 5 then ShowPriestTicks(arg3)
	elseif classID == 8 then ShowMageTicks(arg3)
	elseif classID == 9 then ShowWarlockTicks(arg3)
	elseif classID == 10 then ShowMonkTicks(arg3)
	elseif classID == 11 then ShowDruidTicks(arg3)
	elseif classID == 13 then ShowEvokerTicks(arg3)
	end
end
-- Hide the Ticks --
function vcbHideTicks()
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
	end
end
-- Spell School Color --
vcbPhysicalColor = CreateColorFromRGBAHexString("FFFF00FF") -- 1
vcbHolyColor = CreateColorFromRGBAHexString("FFE680FF") -- 2
vcbFireColor = CreateColorFromRGBAHexString("FF8000FF") -- 4
vcbNatureColor = CreateColorFromRGBAHexString("4DFF4DFF") -- 8
vcbFrostColor = CreateColorFromRGBAHexString("80FFFFFF") -- 16
vcbShadowColor = CreateColorFromRGBAHexString("8080FFFF") -- 32
vcbArcaneColor = CreateColorFromRGBAHexString("FF80FFFF") -- 64
vcbHolystrikeColor = CreateColorFromRGBAHexString("FFF04DFF") -- 3
vcbFlamestrikeColor = CreateColorFromRGBAHexString("FFB300FF") -- 5
vcbRadiantColor = CreateColorFromRGBAHexString("FFA933FF") -- 6
vcbStormstrikeColor = CreateColorFromRGBAHexString("A6FF27FF") -- 9
vcbHolystormColor = CreateColorFromRGBAHexString("A6F367FF") -- 10
vcbVolcanicColor = CreateColorFromRGBAHexString("A6C027FF") -- 12
vcbFroststrikeColor = CreateColorFromRGBAHexString("C0FF80FF") -- 17
vcbHolyfrostColor = CreateColorFromRGBAHexString("B3F5CCFF") -- 18
vcbFrostfireColor = CreateColorFromRGBAHexString("C0C080FF") -- 20
vcbFroststormColor = CreateColorFromRGBAHexString("67FFA6FF") -- 24
vcbShadowstrikeColor = CreateColorFromRGBAHexString("B3B399FF") -- 33
vcbTwilightColor = CreateColorFromRGBAHexString("C0B3C0FF") -- 34
vcbShadowflameColor = CreateColorFromRGBAHexString("B38099FF") -- 36
vcbPlagueColor = CreateColorFromRGBAHexString("67C0A6FF") -- 40
vcbShadowfrostColor = CreateColorFromRGBAHexString("80B3FFFF") -- 48
vcbSpellstrikeColor = CreateColorFromRGBAHexString("FFB399FF") -- 65
vcbDivineColor = CreateColorFromRGBAHexString("FFB3C0FF") -- 66
vcbSpellfireColor = CreateColorFromRGBAHexString("FF8080FF") -- 68
vcbAstralColor = CreateColorFromRGBAHexString("A6C0A6FF") -- 72
vcbSpellfrostColor = CreateColorFromRGBAHexString("C0C0FFFF") -- 80
vcbSpellshadowColor = CreateColorFromRGBAHexString("C080FFFF") -- 96
vcbElementalColor = CreateColorFromRGBAHexString("99D56FFF") -- 28
vcbChromaticColor = CreateColorFromRGBAHexString("A9C78FFF") -- 62
vcbCosmicColor = CreateColorFromRGBAHexString("C0B9DFFF") -- 106
vcbMagicColor = CreateColorFromRGBAHexString("B7BBA2FF") -- 126
vcbChaosColor = CreateColorFromRGBAHexString("C1C58BFF") -- 127 - 124
