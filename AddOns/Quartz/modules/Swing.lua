--[[
	Copyright (C) 2006-2007 Nymbia
	Copyright (C) 2010-2017 Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
local L = LibStub("AceLocale-3.0"):GetLocale("Quartz3")

if not (C_SwingTimer and Enum.PlayerSwingType) then return end

local MODNAME = "Swing"
local Swing = Quartz3:NewModule(MODNAME, "AceEvent-3.0")
local Player = Quartz3:GetModule("Player")

local media = LibStub("LibSharedMedia-3.0")
local ApplyFontStyle = Quartz3.Util.ApplyFontStyle

----------------------------
-- Upvalues
local CreateFrame, GetTime, UIParent, UnitAttackSpeed = CreateFrame, GetTime, UIParent, UnitAttackSpeed
local unpack, ipairs, pairs, hooksecurefunc = unpack, ipairs, pairs, hooksecurefunc

local BAR_SPACING = 1
local RANGE_DIM_ALPHA = 0.6

local SWING_TYPES = { Enum.PlayerSwingType.MainHand, Enum.PlayerSwingType.OffHand, Enum.PlayerSwingType.Ranged }
local swingInfo = {
	[Enum.PlayerSwingType.MainHand] = { option = "showmainhand", label = SWING_TIMER_MAIN_HAND or L["Main Hand"], blizzard = "SwingTimerMainHandFrame" },
	[Enum.PlayerSwingType.OffHand]  = { option = "showoffhand",  label = SWING_TIMER_OFF_HAND or L["Off Hand"],   blizzard = "SwingTimerOffHandFrame" },
	[Enum.PlayerSwingType.Ranged]   = { option = "showranged",   label = SWING_TIMER_RANGED or L["Ranged"],       blizzard = "SwingTimerRangedFrame" },
}

local bars = {}
local barWidth
local locked = true
local mover
local hookedShown, hookedRange = {}, {}

local db, getOptions

local defaults = {
	profile = {
		hideblizz = true,
		showmainhand = true,
		showoffhand = true,
		showranged = true,
		rangedim = true,

		barcolor = {1, 1, 1},
		bartexture = "Blizzard",
		swingalpha = 1,
		swingheight = 4,
		swingposition = "top",
		swinggap = -4,

		showlabel = true,
		durationtext = true,
		remainingtext = true,
	}
}

local FREE_DEFAULT_X, FREE_DEFAULT_Y = 0, -250

local function freeX()
	local x = db.x
	if x == nil then x = FREE_DEFAULT_X end
	return x
end

local function freeY()
	local y = db.y
	if y == nil then y = FREE_DEFAULT_Y end
	return y
end

local function isFreePosition()
	return db.swingposition == "free" or not Player:IsEnabled()
end

local function playerBarWidth()
	local width = Player.Bar and Player.Bar:GetWidth() or 0
	if width < 1 then width = Player.db.profile.w + 10 end
	return width - 8
end

----------------------------
-- Mover (free position)

local function ensureMover()
	if mover then return mover end

	mover = CreateFrame("Frame", nil, UIParent)
	mover:SetFrameStrata("MEDIUM")
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:EnableMouse(false)
	mover:RegisterForDrag("LeftButton")
	mover:Hide()

	mover.bg = mover:CreateTexture(nil, "BACKGROUND")
	mover.bg:SetAllPoints(mover)
	mover.bg:SetColorTexture(0, 0.5, 1, 0.25)

	mover.bar = CreateFrame("StatusBar", nil, mover)
	mover.bar:SetAllPoints(mover)
	mover.bar:SetMinMaxValues(0, 1)
	mover.bar:SetValue(0.5)

	mover.overlay = CreateFrame("Frame", nil, mover)
	mover.overlay:SetAllPoints(mover)
	mover.overlay:SetFrameLevel(mover:GetFrameLevel() + 5)
	mover.label = mover.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	mover.label:SetPoint("CENTER")
	mover.label:SetText(L["Swing"])

	mover:SetScript("OnDragStart", mover.StartMoving)
	mover:SetScript("OnDragStop", function(frame)
		frame:StopMovingOrSizing()
		local scale = frame:GetScale()
		db.x = frame:GetLeft() - UIParent:GetWidth() / 2 / scale
		db.y = frame:GetBottom() - UIParent:GetHeight() / 2 / scale
		Swing:ApplySettings()
	end)

	local demoTime = 0
	mover:SetScript("OnUpdate", function(self, elapsed)
		demoTime = demoTime + elapsed
		self.bar:SetValue((demoTime % 2.5) / 2.5)
	end)

	return mover
end

local function positionMover()
	if not mover then return end

	mover:SetScale(Player.db.profile.scale)
	mover:SetSize(barWidth or playerBarWidth(), db.swingheight)
	mover:ClearAllPoints()
	if db.swingposition == "top" and Player:IsEnabled() then
		mover:SetPoint("BOTTOM", Player.Bar, "TOP", 0, db.swinggap)
	elseif db.swingposition == "bottom" and Player:IsEnabled() then
		mover:SetPoint("TOP", Player.Bar, "BOTTOM", 0, -db.swinggap)
	else
		mover:SetPoint("BOTTOMLEFT", UIParent, "CENTER", freeX(), freeY())
	end

	mover.bar:SetStatusBarTexture(media:Fetch("statusbar", db.bartexture))
	mover.bar:SetStatusBarColor(unpack(db.barcolor))
end

function Swing:SetMoverLocked(lock)
	locked = lock
	ensureMover()
	mover:EnableMouse(not lock and isFreePosition())
	mover:SetShown(not lock)
	if not lock then
		positionMover()
	end
end

function Swing:Unlock()
	if not self:IsEnabled() then return end
	self:SetMoverLocked(false)
end

function Swing:Lock()
	if not self:IsEnabled() then return end
	self:SetMoverLocked(true)
end

----------------------------
-- Bars

local function layoutBars()
	local attached = db.swingposition ~= "free" and Player:IsEnabled()
	local growDown = attached and db.swingposition == "bottom"
	local previous
	for _, swingType in ipairs(SWING_TYPES) do
		local bar = bars[swingType]
		if bar and bar:IsShown() then
			bar:ClearAllPoints()
			if previous then
				if growDown then
					bar:SetPoint("TOP", previous, "BOTTOM", 0, -BAR_SPACING)
				else
					bar:SetPoint("BOTTOM", previous, "TOP", 0, BAR_SPACING)
				end
			elseif growDown then
				bar:SetPoint("TOP", Player.Bar, "BOTTOM", 0, -db.swinggap)
			elseif attached then
				bar:SetPoint("BOTTOM", Player.Bar, "TOP", 0, db.swinggap)
			else
				bar:SetPoint("BOTTOMLEFT", ensureMover(), "BOTTOMLEFT")
			end
			previous = bar
		end
	end
end

local function OnUpdate(self)
	local startTime = self.startTime
	if not startTime then return end
	local elapsed = GetTime() - startTime
	if elapsed >= self.duration then
		self:Hide()
		return
	end
	self.bar:SetValue(elapsed / self.duration)
	if db.remainingtext then
		self.remaining:SetFormattedText("%.1f", self.duration - elapsed)
	end
end

local function OnShow(self)
	self:SetScript("OnUpdate", OnUpdate)
	layoutBars()
end

local function OnHide(self)
	self:SetScript("OnUpdate", nil)
	self.startTime = nil
	layoutBars()
end

local function ensureBar(swingType)
	local bar = bars[swingType]
	if bar then return bar end

	bar = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	bar.swingType = swingType
	bar:SetFrameStrata("HIGH")
	bar:SetClampedToScreen(true)
	bar:Hide()
	bar:SetScript("OnShow", OnShow)
	bar:SetScript("OnHide", OnHide)

	bar.bar = Quartz3:CreateStatusBar(nil, bar)
	bar.bar:SetAllPoints(bar)
	bar.bar:SetMinMaxValues(0, 1)

	bar.label = bar.bar:CreateFontString(nil, "OVERLAY")
	bar.remaining = bar.bar:CreateFontString(nil, "OVERLAY")

	-- Two nested alpha holders let possibly secret range booleans drive the dimming without being tested.
	bar.rangeFrame = CreateFrame("Frame", nil, bar)
	bar.rangeFrame:SetAllPoints(bar)
	bar.rangeFrame:SetFrameLevel(bar.bar:GetFrameLevel() + 1)
	bar.rangeOverlay = bar.rangeFrame:CreateTexture(nil, "OVERLAY")
	bar.rangeOverlay:SetAllPoints(bar.rangeFrame)
	bar.rangeOverlay:SetColorTexture(0, 0, 0)
	bar.rangeOverlay:SetAlpha(0)

	bars[swingType] = bar
	return bar
end

local function styleText(text, anchor, justify)
	ApplyFontStyle(text, media:Fetch("font", Player.db.profile.font), 9, "SHADOW", {0, 0, 0, 1}, 0.8, -0.8)
	text:SetTextColor(1, 1, 1)
	text:SetNonSpaceWrap(false)
	text:SetWidth(barWidth)
	text:ClearAllPoints()
	text:SetPoint(anchor, text:GetParent(), anchor)
	text:SetJustifyH(justify)
end

local function styleBar(bar)
	bar:ClearAllPoints()
	bar:SetSize(barWidth, db.swingheight)
	bar:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
	bar:SetBackdropColor(0, 0, 0)
	bar:SetAlpha(db.swingalpha)
	bar:SetScale(Player.db.profile.scale)

	bar.bar:SetStatusBarTexture(media:Fetch("statusbar", db.bartexture))
	bar.bar:SetStatusBarColor(unpack(db.barcolor))

	styleText(bar.label, "BOTTOMLEFT", "LEFT")
	bar.label:SetShown(db.showlabel or db.durationtext)
	styleText(bar.remaining, "BOTTOMRIGHT", "RIGHT")
	bar.remaining:SetShown(db.remainingtext)
	if not db.rangedim then
		bar.rangeOverlay:SetAlpha(0)
	end
end

local function setLabel(bar, duration)
	if db.showlabel and db.durationtext then
		bar.label:SetFormattedText("%s %.1f", swingInfo[bar.swingType].label, duration)
	elseif db.durationtext then
		bar.label:SetFormattedText("%.1f", duration)
	else
		bar.label:SetText(swingInfo[bar.swingType].label)
	end
end

local function startBar(bar, duration)
	bar.startTime = GetTime()
	bar.duration = duration
	bar.bar:SetValue(0)
	setLabel(bar, duration)
	if db.remainingtext then
		bar.remaining:SetFormattedText("%.1f", duration)
	end
	bar:Show()
end

local function equippedSwingDuration(swingType)
	local mainHand, offHand, ranged = UnitAttackSpeed("player")
	local duration = mainHand
	if swingType == Enum.PlayerSwingType.OffHand then
		duration = offHand
	elseif swingType == Enum.PlayerSwingType.Ranged then
		duration = ranged
	end
	if issecretvalue(duration) or duration == nil or duration <= 0 then
		return nil
	end
	return duration
end

----------------------------
-- Range check

local function applyRange(bar, isInRange, checksRange)
	if not db.rangedim then
		bar.rangeOverlay:SetAlpha(0)
		return
	end
	bar.rangeFrame:SetAlphaFromBoolean(checksRange, 1, 0)
	bar.rangeOverlay:SetAlphaFromBoolean(isInRange, 0, RANGE_DIM_ALPHA)
end

local function wantsRangeCheck(swingType, active)
	return active and db.rangedim and db[swingInfo[swingType].option] or false
end

-- The range check is a client-wide switch per swing type, so it is only released when Blizzard's own bar is not relying on it.
local function updateRangeChecks(active)
	for _, swingType in ipairs(SWING_TYPES) do
		if wantsRangeCheck(swingType, active) then
			C_SwingTimer.EnableRangeCheck(swingType, true)
		else
			local frame = _G[swingInfo[swingType].blizzard]
			if not (frame and frame.IsRangeCheckEnabled and frame:IsRangeCheckEnabled()) then
				C_SwingTimer.EnableRangeCheck(swingType, false)
			end
		end
	end
end

local function reassertRangeChecks()
	updateRangeChecks(Swing:IsEnabled())
end

local function hookBlizzardRangeChecks()
	for _, swingType in ipairs(SWING_TYPES) do
		local frame = _G[swingInfo[swingType].blizzard]
		if frame and frame.UpdateRangeCheckRegistration and not hookedRange[frame] then
			hookedRange[frame] = true
			hooksecurefunc(frame, "UpdateRangeCheckRegistration", reassertRangeChecks)
		end
	end
end

----------------------------
-- Blizzard swing timers

local function hideBlizzardFrame(frame)
	if db.hideblizz then
		frame:Hide()
	end
end

local function applyBlizzardVisibility()
	for _, swingType in ipairs(SWING_TYPES) do
		local frame = _G[swingInfo[swingType].blizzard]
		if frame then
			if db.hideblizz then
				if not hookedShown[frame] then
					hookedShown[frame] = true
					hooksecurefunc(frame, "Show", hideBlizzardFrame)
					hooksecurefunc(frame, "SetShown", hideBlizzardFrame)
				end
				frame:Hide()
			elseif hookedShown[frame] and frame.UpdateShownState then
				frame:UpdateShownState()
			end
		end
	end
end

----------------------------
-- Module

function Swing:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["Swing"])
end

function Swing:OnEnable()
	for _, swingType in ipairs(SWING_TYPES) do
		ensureBar(swingType)
	end
	hookBlizzardRangeChecks()

	self:RegisterEvent("PLAYER_SWING")
	self:RegisterEvent("PLAYER_SWING_RANGE_UPDATE")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateRange")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("WEAPON_SLOT_CHANGED")

	self:ApplySettings()
end

function Swing:OnDisable()
	for _, bar in pairs(bars) do
		bar:Hide()
	end
	if mover then
		locked = true
		mover:EnableMouse(false)
		mover:Hide()
	end
	updateRangeChecks(false)
end

function Swing:PLAYER_SWING(event, swingDuration, swingType)
	if issecretvalue(swingType) then return end
	local info = swingInfo[swingType]
	if not info or not db[info.option] then return end

	local bar = bars[swingType]
	if issecretvalue(swingDuration) or swingDuration <= 0 then
		bar:Hide()
		return
	end
	startBar(bar, swingDuration)
end

function Swing:PLAYER_SWING_RANGE_UPDATE(event, swingType, isInRange, checksRange)
	if issecretvalue(swingType) then return end
	local bar = bars[swingType]
	if bar then
		applyRange(bar, isInRange, checksRange)
	end
end

function Swing:UpdateRange()
	for swingType, bar in pairs(bars) do
		if wantsRangeCheck(swingType, true) then
			local isInRange = C_SwingTimer.IsTargetWithinSwingRange(swingType)
			if issecretvalue(isInRange) then
				applyRange(bar, isInRange, true)
			else
				applyRange(bar, isInRange == true, isInRange ~= nil)
			end
		else
			bar.rangeOverlay:SetAlpha(0)
		end
	end
end

function Swing:PLAYER_ENTERING_WORLD()
	for _, bar in pairs(bars) do
		bar:Hide()
	end
	updateRangeChecks(true)
	self:UpdateRange()
end

function Swing:WEAPON_SLOT_CHANGED()
	for swingType, bar in pairs(bars) do
		if bar:IsShown() then
			local duration = equippedSwingDuration(swingType)
			if duration then
				startBar(bar, duration)
			else
				bar:Hide()
			end
		end
	end
	updateRangeChecks(true)
end

function Swing:ApplySettings()
	db = self.db.profile
	applyBlizzardVisibility()

	if not self:IsEnabled() then return end

	barWidth = playerBarWidth()
	for _, bar in pairs(bars) do
		styleBar(bar)
	end

	if isFreePosition() then
		ensureMover()
	end
	if mover then
		positionMover()
		mover:SetShown(not locked)
		mover:EnableMouse(not locked and isFreePosition())
	end

	layoutBars()
	updateRangeChecks(true)
	self:UpdateRange()
end

----------------------------
-- Options

do
	local function notFree()
		return not isFreePosition()
	end

	local function setOpt(info, value)
		db[info[#info]] = value
		Swing:ApplySettings()
	end

	local function getOpt(info)
		return db[info[#info]]
	end

	local function getColor(info)
		return unpack(getOpt(info))
	end

	local function setColor(info, r, g, b, a)
		setOpt(info, {r, g, b, a})
	end

	local options
	function getOptions()
		options = options or {
			type = "group",
			name = L["Swing"],
			desc = L["Swing"],
			get = getOpt,
			set = setOpt,
			order = 600,
			args = {
				toggle = {
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable"],
					get = function()
						return Quartz3:GetModuleEnabled(MODNAME)
					end,
					set = function(info, v)
						Quartz3:SetModuleEnabled(MODNAME, v)
					end,
					order = 100,
				},
				hideblizz = {
					type = "toggle",
					name = L["Disable Blizzard Swing Timer"],
					desc = L["Disable and hide the default UI's swing timer bars"],
					order = 101,
				},
				showmainhand = {
					type = "toggle",
					name = L["Main Hand"],
					desc = L["Show the swing timer bar for this weapon slot"],
					order = 102,
				},
				showoffhand = {
					type = "toggle",
					name = L["Off Hand"],
					desc = L["Show the swing timer bar for this weapon slot"],
					order = 103,
				},
				showranged = {
					type = "toggle",
					name = L["Ranged"],
					desc = L["Show the swing timer bar for this weapon slot"],
					order = 104,
				},
				barcolor = {
					type = "color",
					name = L["Bar Color"],
					desc = L["Set the color of the swing timer bar"],
					get = getColor,
					set = setColor,
					order = 110,
				},
				bartexture = {
					type = "select",
					dialogControl = "LSM30_Statusbar",
					name = L["Bar Texture"],
					desc = L["Set the texture of the swing timer bar"],
					values = AceGUIWidgetLSMlists.statusbar,
					order = 110.5,
				},
				swingheight = {
					type = "range",
					name = L["Height"],
					desc = L["Set the height of the swing timer bar"],
					min = 1, max = 20, step = 1,
					order = 111,
				},
				swingalpha = {
					type = "range",
					name = L["Alpha"],
					desc = L["Set the alpha of the swing timer bar"],
					min = 0.05, max = 1, bigStep = 0.05,
					isPercent = true,
					order = 112,
				},
				swingposition = {
					type = "select",
					name = L["Bar Position"],
					desc = L["Set the position of the swing timer bar"],
					values = {["top"] = L["Top"], ["bottom"] = L["Bottom"], ["free"] = L["Free"]},
					order = 113,
				},
				swinggap = {
					type = "range",
					name = L["Gap"],
					desc = L["Tweak the distance of the swing timer bar from the cast bar"],
					min = -35, max = 35, step = 1,
					hidden = isFreePosition,
					order = 114,
				},
				showlabel = {
					type = "toggle",
					name = L["Bar Label"],
					desc = L["Show the weapon slot name on the swing timer bar"],
					order = 120,
				},
				durationtext = {
					type = "toggle",
					name = L["Duration Text"],
					desc = L["Toggle display of text showing your total swing time"],
					order = 121,
				},
				remainingtext = {
					type = "toggle",
					name = L["Remaining Text"],
					desc = L["Toggle display of text showing the time remaining until you can swing again"],
					order = 122,
				},
				rangedim = {
					type = "toggle",
					name = L["Dim when out of range"],
					desc = L["Fade the swing timer bar while the target is out of attack range"],
					order = 123,
				},
				freeHeader = {
					type = "header",
					name = L["Free Position"],
					order = 400,
					hidden = notFree,
				},
				lock = {
					type = "toggle",
					name = L["Lock"],
					desc = L["Toggle Cast Bar lock"],
					get = function() return locked end,
					set = function(info, v)
						Swing:SetMoverLocked(v)
					end,
					hidden = notFree,
					order = 401,
				},
				x = {
					type = "range",
					name = L["X"],
					desc = L["Set an exact X value for this bar's position."],
					min = -2560, max = 2560, step = 1,
					get = function() return freeX() end,
					hidden = notFree,
					order = 402,
				},
				y = {
					type = "range",
					name = L["Y"],
					desc = L["Set an exact Y value for this bar's position."],
					min = -1600, max = 1600, step = 1,
					get = function() return freeY() end,
					hidden = notFree,
					order = 403,
				},
			},
		}
		return options
	end
end
