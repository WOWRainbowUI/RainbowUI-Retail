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

local gcdbar, gcdbar_width, gcdspark
local starttime, duration

local db, getOptions

local defaults = {
	profile = {
		displayMode  = "bar",        -- "bar" | "icon"

		-- Mode barre
		sparkcolor   = {1, 1, 1},
		barcolor     = {0.0, 0.5, 1.0},
		bartexture   = "Blizzard",
		gcdalpha     = 0.9,
		gcdheight    = 4,
		gcdposition  = "bottom",     -- "top" | "bottom" | "free"
		gcdgap       = -4,
		deplete      = false,

		-- Mode icône
		gcdsize      = 24,
		border       = "Blizzard Tooltip",
		bordercolor  = {0.5, 0.5, 0.5},
		bordersize   = 12,
		iconposition = "left",       -- "left" | "right" | "free"
		icongap      = 4,

		-- Position libre (commun aux deux modes)
		x = 500,
		y = 300,
	}
}

-- OnUpdate : repositionne le spark et met à jour le fill (mode barre uniquement)
-- Utilise starttime = GetTime() enregistré par nous → toujours non-secret
local function OnUpdate()
	if not starttime then return end
	local elapsed = GetTime() - starttime
	local perc = elapsed / duration
	if perc >= 1 then
		gcdbar:SetScript("OnUpdate", nil)
		gcdbar:Hide()
		return
	end
	local fillPerc = db.deplete and (1 - perc) or perc
	gcdbar.bar:SetValue(fillPerc * duration)
	gcdspark:ClearAllPoints()
	gcdspark:SetPoint("CENTER", gcdbar, "LEFT", gcdbar_width * fillPerc, 0)
end

function GCD:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["GCD"])
end

function GCD:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_START",     "CheckGCD")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "CheckGCD")
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN",    "CheckGCD")
	if not gcdbar then
		gcdbar = CreateFrame("Frame", "Quartz3GCDBar", UIParent, "BackdropTemplate")
		gcdbar:SetFrameStrata("MEDIUM")
		gcdbar:SetMovable(true)
		gcdbar:RegisterForDrag("LeftButton")
		gcdbar:SetClampedToScreen(true)
		gcdbar:Hide()
	end
	self:ApplySettings()
end

function GCD:OnDisable()
	starttime = nil
	gcdbar:SetScript("OnUpdate", nil)
	gcdbar:Hide()
end

function GCD:CheckGCD(event, unit)
	if not (event == "SPELL_UPDATE_COOLDOWN" or unit == "player") then return end

	local cooldown = C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(61304)
	local start, dur
	if cooldown then
		start, dur = cooldown.startTime, cooldown.duration
	end

	local isSecretDur = dur and issecretvalue(dur)

	if dur and (isSecretDur or dur > 0) then
		if db.displayMode == "bar" then
			-- N'initialise une nouvelle animation que si la barre n'est pas déjà active
			if not gcdbar:IsShown() then
				-- GetTime() est toujours non-secret : pas d'arithmétique sur valeurs secrètes
				starttime = GetTime()
				duration  = isSecretDur and 1.5 or dur  -- fallback 1.5s max GCD si secret
				gcdbar.bar:SetMinMaxValues(0, duration)
				gcdbar.bar:SetValue(0)
				gcdbar:SetScript("OnUpdate", OnUpdate)
			end
		else -- icon
			if gcdbar.cd then
				gcdbar.cd:SetCooldown(start, dur)
			end
		end
		gcdbar:Show()
	else
		starttime = nil
		gcdbar:SetScript("OnUpdate", nil)
		gcdbar:Hide()
	end
end

function GCD:ApplySettings()
	db = self.db.profile
	if not (gcdbar and self:IsEnabled()) then return end

	-- Réinitialise l'état lors du changement de mode
	gcdbar:SetScript("OnUpdate", nil)
	starttime = nil
	gcdbar:ClearAllPoints()
	gcdbar:SetAlpha(db.gcdalpha)
	gcdbar:SetScale(Player.db.profile.scale)

	if db.displayMode == "bar" then
		-- Dimensions
		gcdbar_width = Player.Bar:GetWidth() - 8
		gcdbar:SetWidth(gcdbar_width)
		gcdbar:SetHeight(db.gcdheight)

		-- Fond noir
		gcdbar:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
			tile = true, tileSize = 16,
		})
		gcdbar:SetBackdropColor(0, 0, 0, 1)

		-- Positionnement
		if db.gcdposition == "bottom" then
			gcdbar:SetPoint("TOP", Player.Bar, "BOTTOM", 0, db.gcdgap)
		elseif db.gcdposition == "top" then
			gcdbar:SetPoint("BOTTOM", Player.Bar, "TOP", 0, -db.gcdgap)
		else -- free
			gcdbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)
		end

		-- StatusBar (fill)
		if not gcdbar.bar then
			gcdbar.bar = CreateFrame("StatusBar", nil, gcdbar)
			gcdbar.bar:SetAllPoints(gcdbar)
		end
		gcdbar.bar:SetStatusBarTexture(media:Fetch("statusbar", db.bartexture))
		gcdbar.bar:SetStatusBarColor(unpack(db.barcolor))
		gcdbar.bar:SetMinMaxValues(0, 1)
		gcdbar.bar:SetValue(0)
		gcdbar.bar:Show()

		-- Spark
		if not gcdspark then
			gcdspark = gcdbar:CreateTexture(nil, "ARTWORK")
			gcdspark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			gcdspark:SetBlendMode("ADD")
		end
		gcdspark:SetVertexColor(unpack(db.sparkcolor))
		gcdspark:SetWidth(25)
		gcdspark:SetHeight(db.gcdheight * 2.5)
		gcdspark:Show()

		-- Masque les éléments du mode icône
		if gcdbar.cd   then gcdbar.cd:Hide()   end
		if gcdbar.icon then gcdbar.icon:Hide() end

	else -- "icon"
		local size = db.gcdsize
		gcdbar:SetWidth(size)
		gcdbar:SetHeight(size)

		gcdbar:SetBackdrop({
			bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
			edgeFile = media:Fetch("border", db.border),
			edgeSize = db.bordersize,
			tile = true, tileSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 }
		})
		gcdbar:SetBackdropColor(0, 0, 0, 0)
		gcdbar:SetBackdropBorderColor(unpack(db.bordercolor))

		-- Positionnement
		if db.iconposition == "left" then
			gcdbar:SetPoint("RIGHT", Player.Bar, "LEFT", -db.icongap, 0)
		elseif db.iconposition == "right" then
			gcdbar:SetPoint("LEFT", Player.Bar, "RIGHT", db.icongap, 0)
		else -- free
			gcdbar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)
		end

		-- Icône de classe
		if not gcdbar.icon then
			gcdbar.icon = gcdbar:CreateTexture(nil, "BACKGROUND")
			gcdbar.icon:SetAllPoints(gcdbar)
			local _, class = UnitClass("player")
			if class and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class] then
				gcdbar.icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
				local coords = CLASS_ICON_TCOORDS[class]
				local inset = 0.02
				gcdbar.icon:SetTexCoord(
					coords[1]+inset, coords[2]-inset,
					coords[3]+inset, coords[4]-inset
				)
			end
		end
		gcdbar.icon:Show()

		-- CooldownFrame
		if not gcdbar.cd then
			gcdbar.cd = CreateFrame("Cooldown", nil, gcdbar, "CooldownFrameTemplate")
			gcdbar.cd:SetAllPoints(gcdbar)
			gcdbar.cd:SetHideCountdownNumbers(true)
			gcdbar.cd:SetScript("OnCooldownDone", function() gcdbar:Hide() end)
		end
		gcdbar.cd:SetDrawEdge(false)
		gcdbar.cd:SetDrawSwipe(true)
		gcdbar.cd:SetSwipeTexture("Interface\\BUTTONS\\WHITE8X8")
		local r, g, b = unpack(db.sparkcolor)
		gcdbar.cd:SetSwipeColor(r, g, b, 0.5)
		gcdbar.cd:Show()

		-- Masque les éléments du mode barre
		if gcdbar.bar then gcdbar.bar:Hide() end
		if gcdspark   then gcdspark:Hide()   end
	end

	gcdbar:Hide()
end

do
	local locked = true
	local function nothing() end
	local function dragstart() gcdbar:StartMoving() end
	local function dragstop()
		db.x = gcdbar:GetLeft()
		db.y = gcdbar:GetBottom()
		gcdbar:StopMovingOrSizing()
	end

	-- Fonctions hidden pour Ace3
	local function inIconMode()  return db.displayMode == "icon" end
	local function inBarMode()   return db.displayMode == "bar"  end
	local function notFree()
		if db.displayMode == "bar"  then return db.gcdposition  ~= "free" end
		if db.displayMode == "icon" then return db.iconposition ~= "free" end
		return true
	end
	local function barNotFree()  return inIconMode() or db.gcdposition  == "free" end
	local function iconNotFree() return inBarMode()  or db.iconposition == "free" end

	local function setOpt(info, value) db[info[#info]] = value; GCD:ApplySettings() end
	local function getOpt(info) return db[info[#info]] end
	local function getColor(info) return unpack(getOpt(info)) end
	local function setColor(info, r, g, b) setOpt(info, {r, g, b}) end

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
					-- Options communes
					toggle = {
						type = "toggle",
						name = L["Enable"],
						desc = L["Enable"],
						get = function() return Quartz3:GetModuleEnabled(MODNAME) end,
						set = function(info, v) Quartz3:SetModuleEnabled(MODNAME, v) end,
						order = 100,
					},
					displayMode = {
						type = "select",
						name = L["Display Mode"],
						desc = L["Choose between a horizontal bar or a square icon"],
						values = { bar = L["Bar"], icon = L["Icon"] },
						order = 101,
					},
					gcdalpha = {
						type = "range",
						name = L["Alpha"],
						desc = L["Set the alpha of the GCD bar"],
						min = 0.05, max = 1, bigStep = 0.05,
						isPercent = true,
						order = 102,
					},

					-- Section barre
					barHeader = {
						type = "header",
						name = L["Bar Settings"],
						order = 200,
						hidden = inIconMode,
					},
					sparkcolor = {
						type = "color",
						name = L["Spark Color"],
						desc = L["Set the color of the GCD bar spark"],
						get = getColor,
						set = setColor,
						order = 201,
						hidden = inIconMode,
					},
					barcolor = {
						type = "color",
						name = L["Bar Color"],
						desc = L["Set the fill color of the GCD bar"],
						get = getColor,
						set = setColor,
						order = 202,
						hidden = inIconMode,
					},
					bartexture = {
						type = "select",
						dialogControl = "LSM30_Statusbar",
						name = L["Bar Texture"],
						desc = L["Set the texture of the GCD bar"],
						values = AceGUIWidgetLSMlists.statusbar,
						order = 203,
						hidden = inIconMode,
					},
					gcdheight = {
						type = "range",
						name = L["Height"],
						desc = L["Set the height of the GCD bar"],
						min = 1, max = 30, step = 1,
						order = 204,
						hidden = inIconMode,
					},
					gcdposition = {
						type = "select",
						name = L["Bar Position"],
						desc = L["Set the position of the GCD bar"],
						values = { top = L["Top"], bottom = L["Bottom"], free = L["Free"] },
						order = 205,
						hidden = inIconMode,
					},
					gcdgap = {
						type = "range",
						name = L["Gap"],
						desc = L["Tweak the distance of the GCD bar from the cast bar"],
						min = -35, max = 35, step = 1,
						order = 206,
						hidden = barNotFree,
					},
					deplete = {
						type = "toggle",
						name = L["Deplete"],
						desc = L["Reverses the direction of the GCD spark, causing it to move right-to-left"],
						order = 207,
						hidden = inIconMode,
					},

					-- Section icône
					iconHeader = {
						type = "header",
						name = L["Icon Settings"],
						order = 300,
						hidden = inBarMode,
					},
					iconSwipeColor = {
						type = "color",
						name = L["Swipe Color"],
						desc = L["Set the color of the GCD swipe overlay"],
						get = function() return unpack(db.sparkcolor) end,
						set = function(info, r, g, b) db.sparkcolor = {r, g, b}; GCD:ApplySettings() end,
						order = 301,
						hidden = inBarMode,
					},
					gcdsize = {
						type = "range",
						name = L["Size"],
						desc = L["Set the size of the GCD icon"],
						min = 12, max = 64, step = 1,
						order = 302,
						hidden = inBarMode,
					},
					border = {
						type = "select",
						dialogControl = "LSM30_Border",
						name = L["Border"],
						desc = L["Set the border texture."],
						values = AceGUIWidgetLSMlists.border,
						order = 303,
						hidden = inBarMode,
					},
					bordercolor = {
						type = "color",
						name = L["Border Color"],
						desc = L["Set the border color."],
						get = getColor,
						set = setColor,
						order = 304,
						hidden = inBarMode,
					},
					bordersize = {
						type = "range",
						name = L["Border Size"],
						desc = L["Set the border size."],
						min = 1, max = 32, step = 1,
						order = 305,
						hidden = inBarMode,
					},
					iconposition = {
						type = "select",
						name = L["Icon Position"],
						desc = L["Set the position of the GCD icon"],
						values = { left = L["Left"], right = L["Right"], free = L["Free"] },
						order = 306,
						hidden = inBarMode,
					},
					icongap = {
						type = "range",
						name = L["Gap"],
						desc = L["Tweak the distance of the GCD icon from the cast bar"],
						min = -35, max = 35, step = 1,
						order = 307,
						hidden = iconNotFree,
					},

					-- Section position libre (commune)
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
						hidden = notFree,
						order = 401,
					},
					x = {
						type = "range",
						name = L["X"],
						desc = L["Set an exact X value for this bar's position."],
						min = 0, max = 2560, step = 1,
						order = 402,
						hidden = notFree,
					},
					y = {
						type = "range",
						name = L["Y"],
						desc = L["Set an exact Y value for this bar's position."],
						min = 0, max = 1600, step = 1,
						order = 403,
						hidden = notFree,
					},
				},
			}
		end
		return options
	end
end
