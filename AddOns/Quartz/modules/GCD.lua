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
local media = LibStub("LibSharedMedia-3.0")

local MODNAME = "GCD"
local GCD = Quartz3:NewModule(MODNAME, "AceEvent-3.0")
local Player = Quartz3:GetModule("Player")

----------------------------
-- Upvalues
local CreateFrame, GetTime, UIParent = CreateFrame, GetTime, UIParent
local unpack = unpack

local gcdbar, gcdbar_width

local db, getOptions

local defaults = {
	profile = {
		sparkcolor = {1, 1, 1, 0.5},
		gcdalpha = 0.9,
		gcdsize = 24,
		gcdposition = "left",
		gcdgap = 4,

		border = "Blizzard Tooltip",
		bordercolor = {0.5, 0.5, 0.5},
		bordersize = 12,

		x = 500,
		y = 300,
	}
}


local function OnHide()
	-- Clean up if needed
end

local function OnShow()
	-- Clean up if needed
end

function GCD:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["GCD"])
end


function GCD:OnEnable()
	--self:RegisterEvent("UNIT_SPELLCAST_SENT","CheckGCD")
	self:RegisterEvent("UNIT_SPELLCAST_START","CheckGCD")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED","CheckGCD")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN","CheckGCD")
	if not gcdbar then
		gcdbar = CreateFrame("Frame", "Quartz3GCDBar", UIParent, "BackdropTemplate")
		gcdbar:SetFrameStrata("HIGH")
		gcdbar:SetScript("OnShow", OnShow)
		gcdbar:SetScript("OnHide", OnHide)
		gcdbar:SetMovable(true)
		gcdbar:RegisterForDrag("LeftButton")
		gcdbar:SetClampedToScreen(true)
		
		-- Class Icon as background
		gcdbar.icon = gcdbar:CreateTexture(nil, "BACKGROUND")
		gcdbar.icon:SetAllPoints(gcdbar)
		local _, class = UnitClass("player")
		if class and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class] then
			gcdbar.icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
			local coords = CLASS_ICON_TCOORDS[class]
			local inset = 0.02
			gcdbar.icon:SetTexCoord(coords[1] + inset, coords[2] - inset, coords[3] + inset, coords[4] - inset)
		end
	end
	self:ApplySettings()
end

function GCD:OnDisable()
	gcdbar:Hide()
end

function GCD:CheckGCD(event, unit, guid, spell)
	if (event == "SPELL_UPDATE_COOLDOWN") or (unit == "player") then
		local gcdSpellID = 61304
		local start, dur
		if C_Spell and C_Spell.GetSpellCooldown then
			local cooldown = C_Spell.GetSpellCooldown(gcdSpellID)
			if cooldown then
				start, dur = cooldown.startTime, cooldown.duration
			end
		else
			start, dur = GetSpellCooldown(gcdSpellID)
		end
		
		if dur and (issecretvalue(dur) or dur > 0) then
			if gcdbar.cd then
				gcdbar.cd:SetCooldown(start, dur)
				gcdbar:Show()
				gcdbar:SetAlpha(db.gcdalpha) -- Reset alpha in case of fade out
				if gcdbar.fadeAnim and gcdbar.fadeAnim:IsPlaying() then
					gcdbar.fadeAnim:Stop()
				end
			end
		else

			if gcdbar:IsShown() then
				if gcdbar.fadeAnim and not gcdbar.fadeAnim:IsPlaying() then
					gcdbar.fadeAnim:Play()
				end
			else
				gcdbar:Hide()
			end
		end
	end
end

function GCD:ApplySettings()
	db = self.db.profile
	if gcdbar and self:IsEnabled() then
		gcdbar:ClearAllPoints()
		
		-- Square icon
		local size = db.gcdsize or 24
		gcdbar:SetHeight(size)
		gcdbar:SetWidth(size)
		
		gcdbar:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = media:Fetch("border", db.border),
			edgeSize = db.bordersize,
			tile = true, tileSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		gcdbar:SetBackdropColor(0,0,0,0) -- Transparent bg so icon shows through
		gcdbar:SetBackdropBorderColor(unpack(db.bordercolor))
		gcdbar:SetAlpha(db.gcdalpha)
		gcdbar:SetScale(Player.db.profile.scale)
		
		-- Positioning
		if db.gcdposition == "left" then
			gcdbar:SetPoint("RIGHT", Player.Bar, "LEFT", -db.gcdgap, 0)
		elseif db.gcdposition == "right" then
			gcdbar:SetPoint("LEFT", Player.Bar, "RIGHT", db.gcdgap, 0)
		else -- "free"
			gcdbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)
		end

		-- Setup Cooldown Frame for GCD
		if not gcdbar.cd then
			gcdbar.cd = CreateFrame("Cooldown", nil, gcdbar, "CooldownFrameTemplate")
			gcdbar.cd:SetAllPoints(gcdbar)
			gcdbar.cd:SetHideCountdownNumbers(true)
			gcdbar.cd:SetScript("OnCooldownDone", function()
				if gcdbar.fadeAnim then
					gcdbar.fadeAnim:Play()
				else
					gcdbar:Hide()
				end
			end)
		end
		
		-- Setup Fade Out Animation
		if not gcdbar.fadeAnim then
			gcdbar.fadeAnim = gcdbar:CreateAnimationGroup()
			local alpha = gcdbar.fadeAnim:CreateAnimation("Alpha")
			alpha:SetFromAlpha(1)
			alpha:SetToAlpha(0)
			alpha:SetDuration(0.5) -- Fade duration
			alpha:SetSmoothing("OUT")
			gcdbar.fadeAnim:SetScript("OnFinished", function() gcdbar:Hide() end)
		end
		

		gcdbar.cd:SetDrawEdge(false)
		gcdbar.cd:SetDrawSwipe(true)
		gcdbar.cd:SetSwipeTexture("Interface\\BUTTONS\\WHITE8X8")
		local r, g, b, a = unpack(db.sparkcolor)
		gcdbar.cd:SetSwipeColor(r, g, b, a or 0.5)
		
		gcdbar:Hide()
	end
end

do
	local locked = true
	local function nothing()
	end
	local function dragstart()
		gcdbar:StartMoving()
	end
	local function dragstop()
		db.x = gcdbar:GetLeft()
		db.y = gcdbar:GetBottom()
		gcdbar:StopMovingOrSizing()
	end

	local function hiddennofree()
		return db.gcdposition ~= "free"
	end

	local function setOpt(info, value)
		db[info[#info]] = value
		GCD:ApplySettings()
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
		if not options then
			options = {
				type = "group",
				name = L["Global Cooldown"],
				order = 600,
				get = getOpt,
				set = setOpt,
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
					sparkcolor = {
						type = "color",
						name = L["Spark Color"],
						desc = L["Set the color of the GCD swipe overlay"],
						hasAlpha = true,
						get = getColor,
						set = setColor,
						order = 103,
					},
					border = {
						type = "select",
						dialogControl = "LSM30_Border",
						name = L["Border"],
						desc = L["Set the border texture."],
						values = AceGUIWidgetLSMlists.border,
						order = 115,
					},
					bordercolor = {
						type = "color",
						name = L["Border Color"],
						desc = L["Set the border color."],
						get = getColor,
						set = setColor,
						order = 116,
					},
					bordersize = {
						type = "range",
						name = L["Border Size"],
						desc = L["Set the border size."],
						min = 1, max = 32, step = 1,
						order = 117,
					},
					gcdsize = {
						type = "range",
						name = L["Size"],
						desc = L["Set the size of the GCD icon"],
						min = 12, max = 64, step = 1,
						order = 104,
					},
					gcdalpha = {
						type = "range",
						name = L["Alpha"],
						desc = L["Set the alpha of the GCD icon"],
						min = 0.05, max = 1, bigStep = 0.05,
						isPercent = true,
						order = 105,
					},
					gcdposition = {
						type = "select",
						name = L["Position"],
						desc = L["Set the position of the GCD icon"],
						values = {["left"] = L["Left"], ["right"] = L["Right"], ["free"] = L["Free"]},
						order = 106,
					},
					lock = {
						type = "toggle",
						name = L["Lock"],
						desc = L["Toggle Cast Bar lock"],
						get = function()
							return locked
						end,
						set = function(info, v)
							if v then
								gcdbar.Hide = nil
								gcdbar:EnableMouse(false)
								gcdbar:SetScript("OnDragStart", nil)
								gcdbar:SetScript("OnDragStop", nil)
								gcdbar:Hide()
							else
								gcdbar:Show()
								gcdbar:EnableMouse(true)
								gcdbar:SetScript("OnDragStart", dragstart)
								gcdbar:SetScript("OnDragStop", dragstop)
								gcdbar:SetAlpha(1)
								gcdbar.Hide = nothing
							end
							locked = v
						end,
						hidden = hiddennofree,
						order = 107,
					},
					x = {
						type = "range",
						name = L["X"],
						desc = L["Set an exact X value for this bar's position."],
						min = 0, max = 2560, step = 1,
						order = 108,
						hidden = hiddennofree,
					},
					y = {
						type = "range",
						name = L["Y"],
						desc = L["Set an exact Y value for this bar's position."],
						min = 0, max = 1600, step = 1,
						order = 109,
						hidden = hiddennofree,
					},
					gcdgap = {
						type = "range",
						name = L["Gap"],
						desc = L["Tweak the distance of the GCD icon from the cast bar"],
						min = -35, max = 35, step = 1,
						order = 110,
					},
				},
			}
		end
		return options
	end
end
