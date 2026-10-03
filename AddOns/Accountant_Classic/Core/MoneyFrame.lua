--[[
$Id: MoneyFrame.lua 425 2026-09-28 05:30:43Z arithmandar $
]]-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
local _G = getfenv(0)
local GameTooltip = _G.GameTooltip
local unpack = _G.unpack
local GetBuildInfo = _G.GetBuildInfo

-- Determine WoW client family
local _, _, _, interfaceVersion = GetBuildInfo()
local projectID = WOW_PROJECT_ID

local PROJECT_MAINLINE = WOW_PROJECT_MAINLINE
local PROJECT_CLASSIC = WOW_PROJECT_CLASSIC
local PROJECT_TBC = WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local PROJECT_CATA = WOW_PROJECT_CATACLYSM_CLASSIC
local PROJECT_MISTS = WOW_PROJECT_MISTS_CLASSIC

-- Beta-only fallback:
-- Replace these bounds with values verified from the actual Forever client.
local isForeverBeta = projectID == PROJECT_MAINLINE and interfaceVersion >= 10000 and interfaceVersion < 20000

local isRetail = projectID == PROJECT_MAINLINE and not isForeverBeta
local isClassicEra = projectID == PROJECT_CLASSIC
local isAnniversaryTBC = PROJECT_TBC ~= nil and projectID == PROJECT_TBC
local isCataclysmClassic = PROJECT_CATA ~= nil and projectID == PROJECT_CATA
local isMistsClassic = PROJECT_MISTS ~= nil and projectID == PROJECT_MISTS
local isProgressionClassic = isCataclysmClassic or isMistsClassic
local isClassicForever = isForeverBeta
local isAnyClassic = isClassicEra or isAnniversaryTBC or isProgressionClassic

-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local FOLDER_NAME, private = ...
local LibStub = _G.LibStub
local addon = LibStub("AceAddon-3.0"):GetAddon(private.addon_name)
local MoneyFrame = addon:NewModule("MoneyFrame", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(private.addon_name)

local profile
local isInLockdown = false
local AC_MNYSTR = nil

local function frame_OnUpdate(self)
	local frametxt = "|cFFFFFFFF"..addon:GetFormattedValue(GetMoney())
	if (frametxt ~= AC_MNYSTR) then
		self.Text:SetText(frametxt)
		AC_MNYSTR = frametxt
		local width = self.Text:GetStringWidth()
		self:SetWidth(width)
	end
end

local function frame_OnMouseDown(self, button)    
	-- Prevent activation when in combat
	if (isInLockdown) then
		return
	end
	-- Handle left button clicks
	if (button == "LeftButton") then
		self:StartMoving()
		GameTooltip:Hide()
	elseif (button == "RightButton") then
		AccountantClassic_ButtonOnClick()
		GameTooltip:Hide()
	end
end

local function frame_OnMouseUp(self, button)
	self:StopMovingOrSizing()
	local a, b, c, d, e = self:GetPoint()
	addon.db.profile.MnyFramePoint = { a, b, c, d, e }
end

local function frame_OnEnter(self)
	if (isInLockdown) then
		return
	end

	local tooltip
	if (isAnyClassic) then
		tooltip = GameTooltip
	else -- Retail
		tooltip = GetAppropriateTooltip()
	end

	if (not tooltip:IsShown()) then
		local amoney_str = addon:ShowSessionToolTip()

		tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -10, 0)
		GameTooltip_SetTitle(tooltip, "|cFFFFFFFF"..L["Accountant Classic"].." - "..L["This Session"])
		GameTooltip_AddNormalLine(tooltip, amoney_str, true)
		--[[
		local tokenstr = addon:BackpackTokenFrame_Update()
		if (tokenstr) then
			GameTooltip_AddNormalLine(tooltip, tokenstr, true)
		end]]
		if (profile.showintrotip == true) then
			GameTooltip_AddColoredLine(tooltip, "("..L["Left-click and drag to move this button.\nRight-Click to open Accountant Classic."]..")", GRAY_FONT_COLOR, true)
		end
		tooltip:Show()
	else
		tooltip:Hide()
	end
end

local function frame_OnLeave(self)
	GameTooltip_Hide()
end

local function createMoneyFrame()
	local f
	if not f then f = CreateFrame("Frame", "AccountantClassicMoneyInfoFrame", UIParent) end
	
	f:SetWidth(160)
	f:SetHeight(21)
	local point, _, relativePoint, ofsx, ofsy = unpack(addon.db.profile.MnyFramePoint)
	f:SetPoint(point or "TOPLEFT", UIParent, relativePoint or "TOPLEFT", ofsx or 10, ofsy or -80)
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f.Text = f:CreateFontString("AccountantClassicMoneyInfoText", "OVERLAY", "GameFontNormal")
	f.Text:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	f.Text:SetText(L["Accountant Classic"])
	f:SetScript("OnUpdate", 	frame_OnUpdate)
	f:SetScript("OnMouseDown", 	frame_OnMouseDown)
	f:SetScript("OnMouseUp", 	frame_OnMouseUp)
	f:SetScript("OnEnter", 		frame_OnEnter)
	f:SetScript("OnLeave", 		frame_OnLeave)
	f:Show()
	return f
end

function MoneyFrame:OnInitialize()
	profile = addon.db.profile
	
	MoneyFrame.frame = createMoneyFrame()
end

function MoneyFrame:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	if (profile.showmoneyinfo == true) then
		self.frame:Show()
		self:ArrangeMoneyInfoFrame()
	else
		self.frame:Hide()
	end
end

function MoneyFrame:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self.frame:Hide()
end

function MoneyFrame:ArrangeMoneyInfoFrame()
	self.frame:SetScale(profile.infoscale or 1)
	self.frame:SetAlpha(profile.infoalpha or 1)
	local point, _, relativePoint, ofsx, ofsy = unpack(profile.MnyFramePoint)
	self.frame:ClearAllPoints()
	self.frame:SetParent(UIParent)
	self.frame:SetPoint(point or "TOPLEFT", nil, relativePoint or "TOPLEFT", ofsx or 10, ofsy or -80)
end

function MoneyFrame:PLAYER_REGEN_DISABLED()
	isInLockdown = true
end

function MoneyFrame:PLAYER_REGEN_ENABLED()
	isInLockdown = false
end
