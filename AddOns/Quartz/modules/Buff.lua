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

local MODNAME = "Buff"
local Buff = Quartz3:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0", "AceTimer-3.0")
local Player = Quartz3:GetModule("Player")
local Focus = Quartz3:GetModule("Focus", true)
local Target = Quartz3:GetModule("Target", true)

local TimeFmt = Quartz3.Util.TimeFormat

local media = LibStub("LibSharedMedia-3.0")
local lsmlist = AceGUIWidgetLSMlists

----------------------------
-- Upvalues
-- GLOBALS:
local CreateFrame, GetTime, UIParent = CreateFrame, GetTime, UIParent
local UnitIsUnit = UnitIsUnit
local unpack, pairs, next, sort = unpack, pairs, next, sort

local targetlocked = true
local focuslocked = true

local OnUpdate
local showicons = false

local db

local defaults = {
	profile = {
		target = true,
		targetbuffs = true,
		targetdebuffs = true,
		targetfixedduration = 0,
		targeticons = true,
		targeticonside = "right",

		targetanchor = "player",--L["Free"], L["Target"], L["Focus"]
		targetx = 500,
		targety = 350,
		targetgrowdirection = "up", --L["Down"]
		targetposition = "topright",

		targetgap = 1,
		targetspacing = 1,
		targetoffset = 3,

		targetwidth = 120,
		targetheight = 12,

		focus = true,
		focusbuffs = true,
		focusdebuffs = true,
		focusfixedduration = 0,
		focusicons = true,
		focusiconside = "left",

		focusanchor = "player",--L["Free"], L["Target"], L["Focus"]
		focusx = 400,
		focusy = 350,
		focusgrowdirection = "up", --L["Down"]
		focusposition = "bottomleft",

		focusgap = 1,
		focusspacing = 1,
		focusoffset = 3,

		focuswidth = 120,
		focusheight = 12,

		buffnametext = true,
		bufftimetext = true,

		bufftexture = "LiteStep",
		bufffont = "Friz Quadrata TT",
		bufffontsize = 9,
		buffalpha = 1,

		buffcolor = {0,0.49, 1},

		debuffsbytype = true,
		debuffcolor = {1.0, 0.7, 0},
		Poison = {0, 1, 0},
		Magic = {0, 0, 1},
		Disease = {.55, .15, 0},
		Curse = {1, 0, 1},

		bufftextcolor = {1,1,1},

		timesort = true,
	}
}



local function OnShow(frame)
	frame:SetScript("OnUpdate", OnUpdate)
end

local function OnHide(frame)
	frame:SetScript("OnUpdate", nil)
end

local framefactory = {
	__index = function(t,k)
		local bar = Quartz3:CreateStatusBar(nil, UIParent)
		t[k] = bar
		bar:SetFrameStrata("MEDIUM")
		bar:Hide()
		bar:SetScript("OnShow", OnShow)
		bar:SetScript("OnHide", OnHide)
		bar:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
		bar:SetBackdropColor(0,0,0,0) -- Transparent backdrop
		
		-- Name Text
		bar.text = bar:CreateFontString(nil, "OVERLAY")

		-- Background texture for "Inverse Fill" - this shows the BUFF COLOR
		bar.bg = bar:CreateTexture(nil, "BACKGROUND")
		bar.bg:SetAllPoints(bar)

		-- Cooldown frame for secret values (timer display only)
		bar.cd = CreateFrame("Cooldown", nil, bar, "CooldownFrameTemplate")
		bar.cd:SetAllPoints(bar)
		bar.cd:SetReverse(true)
		bar.cd:SetDrawEdge(false)
		bar.cd:SetDrawSwipe(false)
		bar.cd:SetHideCountdownNumbers(false)
		bar.cd:Hide()
		
		bar:SetReverseFill(true)

		for _, region in pairs({bar.cd:GetRegions()}) do
			if region:GetObjectType() == "FontString" then
				bar.cd.timerText = region
				bar.cd.timerText:ClearAllPoints()
				bar.cd.timerText:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
				break
			end
		end

		bar.icon = bar:CreateTexture(nil, "ARTWORK")
		if k == 1 then
			bar:SetMovable(true)
			bar:RegisterForDrag("LeftButton")
			bar:SetClampedToScreen(true)
		end
		Buff:ApplySettings()
		return bar
	end
}
local targetbars = setmetatable({}, framefactory)
local focusbars = setmetatable({}, framefactory)

local getOptions
do
	local positions = {
		["bottom"] = L["Bottom"],
		["top"] = L["Top"],
		["topleft"] = L["Top Left"],
		["topright"] = L["Top Right"],
		["bottomleft"] = L["Bottom Left"],
		["bottomright"] = L["Bottom Right"],
		["leftup"] = L["Left (grow up)"],
		["leftdown"] = L["Left (grow down)"],
		["rightup"] = L["Right (grow up)"],
		["rightdown"] = L["Right (grow down)"],
	}

	local function hidedebuffsbytype()
		return not db.debuffsbytype
	end

	local function hidedebuffsnottype()
		return db.debuffsbytype
	end

	local function gettargetfreeoptionshidden()
		return db.targetanchor ~= "free"
	end

	local function gettargetnotfreeoptionshidden()
		return db.targetanchor == "free"
	end

	local function targetdragstart()
		targetbars[1]:StartMoving()
	end

	local function targetdragstop()
		db.targetx = targetbars[1]:GetLeft()
		db.targety = targetbars[1]:GetBottom()
		targetbars[1]:StopMovingOrSizing()
	end
	local function targetnothing()
		targetbars[1]:SetAlpha(db.buffalpha)
	end
	local function getfocusfreeoptionshidden()
		return db.focusanchor ~= "free"
	end
	local function getfocusnotfreeoptionshidden()
		return db.focusanchor == "free"
	end
	local function focusdragstart()
		focusbars[1]:StartMoving()
	end
	local function focusdragstop()
		db.focusx = focusbars[1]:GetLeft()
		db.focusy = focusbars[1]:GetBottom()
		focusbars[1]:StopMovingOrSizing()
	end
	local function focusnothing()
		focusbars[1]:SetAlpha(db.buffalpha)
	end

	local function setOpt(info, value)
		db[info.arg or info[#info]] = value
		Buff:ApplySettings()
	end

	local function getOpt(info)
		return db[info.arg or info[#info]]
	end

	local function setOptFocus(info, value)
		db[info.arg or ("focus"..info[#info])] = value
		Buff:ApplySettings()
	end

	local function getOptFocus(info)
		return db[info.arg or ("focus"..info[#info])]
	end

	local function setOptTarget(info, value)
		db[info.arg or ("target"..info[#info])] = value
		Buff:ApplySettings()
	end

	local function getOptTarget(info)
		return db[info.arg or ("target"..info[#info])]
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
				name = L["Buff"],
				order = 600,
				get = getOpt,
				set = setOpt,
				childGroups = "tab",
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
					focus = {
						type = "group",
						name = L["Focus"],
						desc = L["Focus"],
						order = 101,
						get = getOptFocus,
						set = setOptFocus,
						args = {
							show = {
								type = "toggle",
								name = L["Enable %s"]:format(L["Focus"]),
								desc = L["Show buffs/debuffs for your %s"]:format(L["Focus"]),
								arg = "focus",
								order = 90,
								width = "full",
								disabled = false,
							},
							buffs = {
								type = "toggle",
								name = L["Enable Buffs"],
								desc = L["Show buffs for your %s"]:format(L["Focus"]),
								order = 91,
							},
							debuffs = {
								type = "toggle",
								name = L["Enable Debuffs"],
								desc = L["Show debuffs for your %s"]:format(L["Focus"]),
								order = 92,
							},
							fixedduration = {
								type = "range",
								name = L["Fixed Duration"],
								desc = L["Fix bars to a specified duration"],
								min = 0, max = 60, step = 1,
								order = 93,
							},
							nlf = {
								type = "description",
								name = "",
								order = 100,
							},
							width = {
								type = "range",
								name = L["Buff Bar Width"],
								desc = L["Set the width of the buff bars"],
								min = 50, max = 300, step = 1,
								order = 101,
							},
							height = {
								type = "range",
								name = L["Buff Bar Height"],
								desc = L["Set the height of the buff bars"],
								min = 4, max = 25, step = 1,
								order = 101,
							},
							anchor = {
								type = "select",
								name = L["Anchor Frame"],
								desc = L["Select where to anchor the %s bars"]:format(L["Focus"]),
								values = {["player"] = L["Player"], ["free"] = L["Free"], ["target"] = L["Target"], ["focus"] = L["Focus"]},
								order = 102,
							},
							-- free
							focuslock = {
								type = "toggle",
								name = L["Lock"],
								desc = L["Toggle %s bar lock"]:format(L["Focus"]),
								get = function()
									return focuslocked
								end,
								set = function(info, v)
									local bar = focusbars[1]
									if v then
										bar.Hide = nil
										bar:EnableMouse(false)
										bar:SetScript("OnDragStart", nil)
										bar:SetScript("OnDragStop", nil)
										Buff:UpdateBars()
									else
										bar:Show()
										bar:EnableMouse(true)
										bar:SetScript("OnDragStart", focusdragstart)
										bar:SetScript("OnDragStop", focusdragstop)
										bar:SetAlpha(1)
										bar.endTime = bar.endTime or 0
										bar.Hide = focusnothing
									end
									focuslocked = v
								end,
								hidden = getfocusfreeoptionshidden,
								order = 103,
							},
							x = {
								type = "range",
								name = L["X"],
								desc = L["Set an exact X value for this bar's position."],
								min = 0, max = 2560, step = 1,
								hidden = getfocusfreeoptionshidden,
								order = 104,
							},
							y = {
								type = "range",
								name = L["Y"],
								desc = L["Set an exact Y value for this bar's position."],
								min = 0, max = 1600, step = 1,
								hidden = getfocusfreeoptionshidden,
								order = 104,
							},
							growdirection = {
								type = "select",
								name = L["Grow Direction"],
								desc = L["Set the grow direction of the %s bars"]:format(L["Focus"]),
								values = {["up"] = L["Up"], ["down"] = L["Down"]},
								hidden = getfocusfreeoptionshidden,
								order = 105,
							},
							-- anchored to a cast bar
							position = {
								type = "select",
								name = L["Position"],
								desc = L["Position the bars for your %s"]:format(L["Focus"]),
								values = positions,
								hidden = getfocusnotfreeoptionshidden,
								order = 103,
							},
							gap = {
								type = "range",
								name = L["Gap"],
								desc = L["Tweak the vertical position of the bars for your %s"]:format(L["Focus"]),
								min = -35, max = 35, step = 1,
								hidden = getfocusnotfreeoptionshidden,
								order = 104,
							},
							offset = {
								type = "range",
								name = L["Offset"],
								desc = L["Tweak the horizontal position of the bars for your %s"]:format(L["Focus"]),
								min = -35, max = 35,step = 1,
								hidden = getfocusnotfreeoptionshidden,
								order = 106,
							},
							spacing = {
								type = "range",
								name = L["Spacing"],
								desc = L["Tweak the space between bars for your %s"]:format(L["Focus"]),
								min = -35, max = 35, step = 1,
								order = 107,
							},
							nli = {
								type = "description",
								name = "",
								order = 108,
							},
							icons = {
								type = "toggle",
								name = L["Show Icons"],
								desc = L["Show icons on buffs and debuffs for your %s"]:format(L["Focus"]),
								order = 109,
							},
							iconside = {
								type = "select",
								name = L["Icon Position"],
								desc = L["Set the side of the buff bar that the icon appears on"],
								values = {["left"] = L["Left"], ["right"] = L["Right"]},
								order = 110,
							},
						},
					},
					target = {
						type = "group",
						name = L["Target"],
						desc = L["Target"],
						order = 102,
						get = getOptTarget,
						set = setOptTarget,
						args = {
							show = {
								type = "toggle",
								name = L["Enable %s"]:format(L["Target"]),
								desc = L["Show buffs/debuffs for your %s"]:format(L["Target"]),
								arg = "target",
								disabled = false,
								width = "full",
								order = 90,
							},
							buffs = {
								type = "toggle",
								name = L["Enable Buffs"],
								desc = L["Show buffs for your %s"]:format(L["Target"]),
								order = 91,
							},
							debuffs = {
								type = "toggle",
								name = L["Enable Debuffs"],
								desc = L["Show debuffs for your %s"]:format(L["Target"]),
								order = 92,
							},
							fixedduration = {
								type = "range",
								name = L["Fixed Duration"],
								desc = L["Fix bars to a specified duration"],
								min = 0, max = 60, step = 1,
								order = 93,
							},
							nlf = {
								type = "description",
								name = "",
								order = 100,
							},
							width = {
								type = "range",
								name = L["Buff Bar Width"],
								desc = L["Set the width of the buff bars"],
								min = 50, max = 300, step = 1,
								order = 101,
							},
							height = {
								type = "range",
								name = L["Buff Bar Height"],
								desc = L["Set the height of the buff bars"],
								min = 4, max = 25, step = 1,
								order = 101,
							},
							anchor = {
								type = "select",
								name = L["Anchor Frame"],
								desc = L["Select where to anchor the %s bars"]:format(L["Target"]),
								values = {["player"] = L["Player"], ["free"] = L["Free"], ["target"] = L["Target"], ["focus"] = L["Focus"]},
								order = 102,
							},
							-- free
							targetlock = {
								type = "toggle",
								name = L["Lock"],
								desc = L["Toggle %s bar lock"]:format(L["Target"]),
								get = function()
									return targetlocked
								end,
								set = function(info, v)
									local bar = targetbars[1]
									if v then
										bar.Hide = nil
										bar:EnableMouse(false)
										bar:SetScript("OnDragStart", nil)
										bar:SetScript("OnDragStop", nil)
										Buff:UpdateBars()
									else
										bar:Show()
										bar:EnableMouse(true)
										bar:SetScript("OnDragStart", targetdragstart)
										bar:SetScript("OnDragStop", targetdragstop)
										bar:SetAlpha(1)
										bar.endTime = bar.endTime or 0
										bar.Hide = targetnothing
									end
									targetlocked = v
								end,
								hidden = gettargetfreeoptionshidden,
								order = 103,
							},
							x = {
								type = "range",
								name = L["X"],
								desc = L["Set an exact X value for this bar's position."],
								min = 0, max = 2560, bigStep = 1,
								hidden = gettargetfreeoptionshidden,
								order = 104,
							},
							y = {
								type = "range",
								name = L["Y"],
								desc = L["Set an exact Y value for this bar's position."],
								min = 0, max = 1600, bigStep = 1,
								hidden = gettargetfreeoptionshidden,
								order = 104,
							},
							growdirection = {
								type = "select",
								name = L["Grow Direction"],
								desc = L["Set the grow direction of the %s bars"]:format(L["Target"]),
								values = {["up"] = L["Up"], ["down"] = L["Down"]},
								hidden =  gettargetfreeoptionshidden,
								order = 105,
							},
							-- anchored to a cast bar
							position = {
								type = "select",
								name = L["Position"],
								desc = L["Position the bars for your %s"]:format(L["Target"]),
								values = positions,
								hidden = gettargetnotfreeoptionshidden,
								order = 103,
							},
							gap = {
								type = "range",
								name = L["Gap"],
								desc = L["Tweak the vertical position of the bars for your %s"]:format(L["Target"]),
								min = -35, max = 35, step = 1,
								hidden = gettargetnotfreeoptionshidden,
								order = 104,
							},
							offset = {
								type = "range",
								name = L["Offset"],
								desc = L["Tweak the horizontal position of the bars for your %s"]:format(L["Target"]),
								min = -35, max = 35, step = 1,
								hidden = gettargetnotfreeoptionshidden,
								order = 106,
							},
							spacing = {
								type = "range",
								name = L["Spacing"],
								desc = L["Tweak the space between bars for your %s"]:format(L["Target"]),
								min = -35, max = 35, step = 1,
								order = 107,
							},
							nli = {
								type = "description",
								name = "",
								order = 108,
							},
							icons = {
								type = "toggle",
								name = L["Show Icons"],
								desc = L["Show icons on buffs and debuffs for your %s"]:format(L["Target"]),
								order = 109,
							},
							iconside = {
								type = "select",
								name = L["Icon Position"],
								desc = L["Set the side of the buff bar that the icon appears on"],
								values = {["left"] = L["Left"], ["right"] = L["Right"]},
								order = 110,
							},
						},
					},
					settings = {
						type = "group",
						name = L["Settings"],
						order = 1,
						args = {
							timesort = {
								type = "toggle",
								name = L["Sort by Remaining Time"],
								desc = L["Sort the buffs and debuffs by time remaining.  If unchecked, they will be sorted alphabetically."],
								order = 103,
								width = "full",
							},
							buffnametext = {
								type = "toggle",
								name = L["Buff Name Text"],
								desc = L["Display the names of buffs/debuffs on their bars"],
								order = 106,
							},
							bufftimetext = {
								type = "toggle",
								name = L["Buff Time Text"],
								desc = L["Display the time remaining on buffs/debuffs on their bars"],
								order = 107,
							},
							bufffont = {
								type = "select",
								dialogControl = "LSM30_Font",
								name = L["Font"],
								desc = L["Set the font used in the buff bars"],
								values = lsmlist.font,
								order = 108,
							},
							bufftexture = {
								type = "select",
								dialogControl = "LSM30_Statusbar",
								name = L["Texture"],
								desc = L["Set the buff bar Texture"],
								values = lsmlist.statusbar,
								order = 109,
							},
							bufftextcolor = {
								type = "color",
								name = L["Text Color"],
								desc = L["Set the color of the text for the buff bars"],
								order = 110,
								width = "full",
								get = getColor,
								set = setColor,
							},
							bufffontsize = {
								type = "range",
								name = L["Font Size"],
								desc = L["Set the font size for the buff bars"],
								min = 3, max = 15, step = 1,
								order = 111,
							},
							buffalpha = {
								type = "range",
								name = L["Alpha"],
								desc = L["Set the alpha of the buff bars"],
								min = 0.05, max = 1, step = 0.05,
								isPercent = true,
								order = 112,
							},
						},
					},
					colors = {
						type = "group",
						name = L["Colors"],
						desc = L["Colors"],
						order = -1,
						args = {
							buffcolor = {
								type = "color",
								name = L["Buff Color"],
								desc = L["Set the color of the bars for buffs"],
								get = getColor,
								set = setColor,
							},
							debuffsbytype = {
								type = "toggle",
								name = L["Debuffs by Type"],
								desc = L["Color debuff bars according to their dispel type"],
								order = 101,
							},
							debuffcolor = {
								type = "color",
								name = L["Debuff Color"],
								desc = L["Set the color of the bars for debuffs"],
								get = getColor,
								set = setColor,
								disabled = hidedebuffsnottype,
								order = 102,
							},
							physcolor = {
								type = "color",
								name = L["Undispellable Color"],
								desc = L["Set the color of the bars for undispellable debuffs"],
								get = getColor,
								set = setColor,
								arg = "debuffcolor",
								disabled = hidedebuffsbytype,
								order = 102,
							},
							Curse = {
								type = "color",
								name = L["Curse Color"],
								desc = L["Set the color of the bars for curses"],
								get = getColor,
								set = setColor,
								disabled = hidedebuffsbytype,
								order = 103,
							},
							Disease = {
								type = "color",
								name = L["Disease Color"],
								desc = L["Set the color of the bars for diseases"],
								get = getColor,
								set = setColor,
								disabled = hidedebuffsbytype,
								order = 104,
							},
							Magic = {
								type = "color",
								name = L["Magic Color"],
								desc = L["Set the color of the bars for magic"],
								get = getColor,
								set = setColor,
								disabled = hidedebuffsbytype,
								order = 105,
							},
							Poison = {
								type = "color",
								name = L["Poison Color"],
								desc = L["Set the color of the bars for poisons"],
								get = getColor,
								set = setColor,
								disabled = hidedebuffsbytype,
								order = 106,
							},
						},
					},
				}
			}
		end
		return options
	end
end

function Buff:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	-- fix broken buff text color
	if type(db.bufftextcolor) ~= "table" then
		db.bufftextcolor = {1,1,1}
	end

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["Buff"])
end

function Buff:OnEnable()
	self:RegisterBucketEvent("UNIT_AURA", 0.5)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateBars")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED", "UpdateBars")
	media.RegisterCallback(self, "LibSharedMedia_SetGlobal", function(mtype, override)
		if mtype == "statusbar" then
			for i, v in pairs(targetbars) do
				v:SetStatusBarTexture(media:Fetch("statusbar", override))
			end
			for i, v in pairs(focusbars) do
				v:SetStatusBarTexture(media:Fetch("statusbar", override))
			end
		end
	end)

	media.RegisterCallback(self, "LibSharedMedia_Registered", function(mtype, key)
		if mtype == "statusbar" and key == self.config.bufftexture then
			for i, v in pairs(targetbars) do
				v:SetStatusBarTexture(media:Fetch("statusbar", self.config.bufftexture))
			end
			for i, v in pairs(focusbars) do
				v:SetStatusBarTexture(media:Fetch("statusbar", self.config.bufftexture))
			end
		end
	end)

	self:ApplySettings()
end

function Buff:OnDisable()
	targetbars[1].Hide = nil
	targetbars[1]:EnableMouse(false)
	targetbars[1]:SetScript("OnDragStart", nil)
	targetbars[1]:SetScript("OnDragStop", nil)
	for _, v in pairs(targetbars) do
		v:Hide()
	end

	focusbars[1].Hide = nil
	focusbars[1]:EnableMouse(false)
	focusbars[1]:SetScript("OnDragStart", nil)
	focusbars[1]:SetScript("OnDragStop", nil)
	for _, v in pairs(focusbars) do
		v:Hide()
	end

	media.UnregisterCallback(self, "LibSharedMedia_SetGlobal")
	media.UnregisterCallback(self, "LibSharedMedia_Registered")
end

function Buff:UNIT_AURA(units)
	for unit in pairs(units) do
		if unit == "target" then
			self:UpdateTargetBars()
		end
		if unit == "focus" or UnitIsUnit("focus", unit) then
			self:UpdateFocusBars()
		end
	end
end



function Buff:GetDispelColorCurve(isBuff)
	local cacheKey = isBuff and "_buffCurve" or "_debuffCurve"
	
	if( self[cacheKey] ) then return self[cacheKey] end
	if( not C_CurveUtil or not C_CurveUtil.CreateColorCurve ) then return nil end

	local curve = C_CurveUtil.CreateColorCurve()
	-- Use Enum values if available to ensure correct mapping
	local E = Enum and Enum.AuraDispelType
	local noneID = (E and E.None) or 0
	local magicID = (E and E.Magic) or 1
	local curseID = (E and E.Curse) or 2
	local diseaseID = (E and E.Disease) or 3
	local poisonID = (E and E.Poison) or 4
	
	if( curve.SetType and Enum and Enum.LuaCurveType and Enum.LuaCurveType.Step ) then
		curve:SetType(Enum.LuaCurveType.Step)
	end

	-- Hardcode standard colors
	local baseR, baseG, baseB
	if( isBuff ) then
		baseR, baseG, baseB = unpack(db.buffcolor)
	else
		baseR, baseG, baseB = unpack(db.debuffcolor)
	end
	
	-- Add points using the resolved IDs
	curve:AddPoint(noneID, CreateColor(baseR, baseG, baseB))
	curve:AddPoint(magicID, CreateColor(unpack(db.Magic or {0.2, 0.6, 1})))
	curve:AddPoint(curseID, CreateColor(unpack(db.Curse or {0.6, 0, 1})))
	curve:AddPoint(diseaseID, CreateColor(unpack(db.Disease or {0.6, 0.4, 0})))
	curve:AddPoint(poisonID, CreateColor(unpack(db.Poison or {0, 0.6, 0})))
	
	-- Add a "Cap" point to catch any IDs higher than Poison
	local capID = math.max(noneID, magicID, curseID, diseaseID, poisonID) + 1
	curve:AddPoint(capID, CreateColor(baseR, baseG, baseB))
	curve:AddPoint(255, CreateColor(baseR, baseG, baseB)) -- Safety max
	
    -- Ensure the curve covers the range
    if( curve.SetMinMaxValues ) then
	    curve:SetMinMaxValues(0, 255)
    end
	
	self[cacheKey] = curve
	return curve
end

function Buff:CheckForUpdate()
	if targetbars[1]:IsShown() then
		self:UpdateTargetBars()
	end
	if focusbars[1]:IsShown() then
		self:UpdateFocusBars()
	end
end

function Buff:UpdateBars()
	self:UpdateTargetBars()
	self:UpdateFocusBars()
end

do
	local tblCache = setmetatable({}, {__mode="k"})
	local function new()
		local entry = next(tblCache)
		if entry then tblCache[entry] = nil else entry = {} end
		return entry
	end
	local function del(tbl)
		tbl.isbuff, tbl.dispeltype, tbl.isSecret, tbl.auraInstanceID = nil, nil, nil, nil
		tblCache[tbl] = true
	end

	-- Helper: Scan auras for a unit and populate tmp table
	local function scanAuras(unit, isBuffScan, tmp, currentTime)
		local maxIndex = isBuffScan and 40 or 40
		local getAuraFunc = isBuffScan and C_UnitAuras.GetBuffDataByIndex or C_UnitAuras.GetDebuffDataByIndex
		local filter = isBuffScan and "HELPFUL|PLAYER" or "HARMFUL|PLAYER"
		
		for i = 1, maxIndex do
			local auraData = getAuraFunc(unit, i)
			if (not auraData) or (not auraData.name) then break end
			
			local isSecret = issecretvalue(auraData.expirationTime)
			local remaining = nil
			if not isSecret then
				remaining = auraData.expirationTime and (auraData.expirationTime - currentTime) or nil
			end
			
			local isPlayerAura = not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, auraData.auraInstanceID, filter)
			
			if isPlayerAura and (isSecret or auraData.duration > 0) then
				local t = new()
				tmp[#tmp+1] = t
				t.name = auraData.name
				t.texture = auraData.icon
				t.duration = auraData.duration
				t.remaining = remaining
				t.isbuff = isBuffScan
				t.applications = auraData.applications
				t.isSecret = isSecret
				t.auraInstanceID = auraData.auraInstanceID
				if not isBuffScan then
					t.dispeltype = auraData.dispelName
				end
			end
		end
	end
	
	-- Helper: Configure bar with duration and cooldown
	local function configureBar(bar, unit, auraInstanceID)
		local durationInfo = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)
		if durationInfo then
			bar:SetTimerDuration(durationInfo)
			if bar.cd then
				bar.cd:SetCooldownFromDurationObject(durationInfo)
				bar.cd:Show()
				if bar.cd.timerText then
					bar.cd.timerText:SetFont(media:Fetch("font", db.bufffont), db.bufffontsize)
					bar.cd.timerText:SetTextColor(unpack(db.bufftextcolor))
				end
			end
		end
		bar:SetScript("OnUpdate", nil)
		if bar.timetext then bar.timetext:Hide() end
	end
	
	-- Helper: Apply color to bar based on buff/debuff type
	local function applyBarColor(selfRef, bar, unit, auraData)
		local r, g, b = 1, 1, 1
		if auraData.isbuff then
			r, g, b = unpack(db.buffcolor)
		else
			local colorSet = false
			if db.debuffsbytype then
				if C_UnitAuras.GetAuraDispelTypeColor and C_CurveUtil then
					local curve = selfRef:GetDispelColorCurve(false)
					if curve then
						local color = C_UnitAuras.GetAuraDispelTypeColor(unit, auraData.auraInstanceID, curve)
						if color then
							r, g, b = color:GetRGB()
							colorSet = true
						end
					end
				end
				if not colorSet then
					local dispeltype = auraData.dispeltype
					if dispeltype and not issecretvalue(dispeltype) then
						r, g, b = unpack(db[dispeltype])
					else
						r, g, b = unpack(db.debuffcolor)
					end
				end
			else
				r, g, b = unpack(db.debuffcolor)
			end
		end
		if bar.bg then
			bar.bg:SetVertexColor(r, g, b, 1)
		end
	end
	
	-- Helper: Disable bar interactions
	local function disableBars(bars)
		bars[1].Hide = nil
		bars[1]:EnableMouse(false)
		bars[1]:SetScript("OnDragStart", nil)
		bars[1]:SetScript("OnDragStop", nil)
		for i = 1, #bars do
			bars[i]:Hide()
		end
	end

	local tmp = {}
	local called = false
	
	-- Generic update function for both target and focus
	local function updateBarsForUnit(selfRef, unit, bars, otherBars, enabledKey, buffsKey, debuffsKey)
		if called then return end
		called = true
		
		if db[enabledKey] then
			local currentTime = GetTime()
			for k in pairs(tmp) do
				tmp[k] = del(tmp[k])
			end
			
			if db[buffsKey] then
				scanAuras(unit, true, tmp, currentTime)
			end
			if db[debuffsKey] then
				scanAuras(unit, false, tmp, currentTime)
			end
			
			local maxindex = 0
			for k = 1, #tmp do
				local v = tmp[k]
				maxindex = k
				local bar = bars[k]
				
				if (not issecretvalue(v.applications)) and (v.applications > 1) then
					bar.text:SetFormattedText("%s (%s)", v.name, v.applications)
				else
					bar.text:SetText(v.name)
				end
				bar.icon:SetTexture(v.texture)
				
				configureBar(bar, unit, v.auraInstanceID)
				bar:Show()
				applyBarColor(selfRef, bar, unit, v)
			end
			
			for i = maxindex + 1, #bars do
				bars[i]:Hide()
			end
		else
			disableBars(bars)
		end
		
		-- Auto update timer management
		if bars[1]:IsShown() then
			if not selfRef.autoUpdateTimer then
				selfRef.autoUpdateTimer = selfRef:ScheduleRepeatingTimer("CheckForUpdate", 3)
			end
		elseif not otherBars[1]:IsShown() then
			if selfRef.autoUpdateTimer then
				selfRef:CancelTimer(selfRef.autoUpdateTimer)
				selfRef.autoUpdateTimer = nil
			end
		end
		
		called = false
	end
	
	function Buff:UpdateTargetBars()
		updateBarsForUnit(self, "target", targetbars, focusbars, "target", "targetbuffs", "targetdebuffs")
	end
	
	function Buff:UpdateFocusBars()
		updateBarsForUnit(self, "focus", focusbars, targetbars, "focus", "focusbuffs", "focusdebuffs")
	end
end
do
	local function apply(unit, i, bar, direction)
		local bars, position, icons, iconside, gap, spacing, offset, anchor, x, y, grow, height, width
		local qpdb = Player.db.profile
		if unit == "target" then
			bars = targetbars
			position = db.targetposition
			icons = db.targeticons
			iconside = db.targeticonside
			gap = db.targetgap
			spacing = db.targetspacing
			offset = db.targetoffset
			anchor = db.targetanchor
			x = db.targetx
			y = db.targety
			grow = db.targetgrowdirection
			width = db.targetwidth
			height = db.targetheight
		else
			bars = focusbars
			position = db.focusposition
			icons = db.focusicons
			iconside = db.focusiconside
			gap = db.focusgap
			spacing = db.focusspacing
			offset = db.focusoffset
			anchor = db.focusanchor
			x = db.focusx
			y = db.focusy
			grow = db.focusgrowdirection
			width = db.focuswidth
			height = db.focusheight
		end

		bar:ClearAllPoints()
		
		-- Inverse Fill
		-- bar.bg = User Texture
		-- StatusBar = Black mask that grows to cover it
		local tex = media:Fetch("statusbar", db.bufftexture)
		if bar.bg then
			bar.bg:SetTexture(tex)
		end
		
		bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		bar:GetStatusBarTexture():SetVertexColor(0, 0, 0, 1)
		
		bar:SetWidth(width)
		bar:SetHeight(height)
		bar:SetScale(qpdb.scale)
		bar:SetAlpha(db.buffalpha)

		if anchor == "free" then
			if i == 1 then
				bar:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
				if grow == "up" then
					direction = 1
				else --L["Down"]
					direction = -1
				end
			else
				if direction == 1 then
					bar:SetPoint("BOTTOMRIGHT", bars[i-1], "TOPRIGHT", 0, spacing)
				else -- -1
					bar:SetPoint("TOPRIGHT", bars[i-1], "BOTTOMRIGHT", 0, -1 * spacing)
				end
			end
		else
			if i == 1 then
				local anchorframe
				if anchor == "focus" and Focus and Focus.Bar then
					anchorframe = Focus.Bar
				elseif anchor == "target" and Target and Target.Bar then
					anchorframe = Target.Bar
				else -- L["Player"]
					anchorframe = Player.Bar
				end

				if position == "top" then
					direction = 1
					bar:SetPoint("BOTTOM", anchorframe, "TOP", 0, gap)
				elseif position == "bottom" then
					direction = -1
					bar:SetPoint("TOP", anchorframe, "BOTTOM", 0, -1 * gap)
				elseif position == "topright" then
					direction = 1
					bar:SetPoint("BOTTOMRIGHT", anchorframe, "TOPRIGHT", -1 * offset, gap)
				elseif position == "bottomright" then
					direction = -1
					bar:SetPoint("TOPRIGHT", anchorframe, "BOTTOMRIGHT", -1 * offset, -1 * gap)
				elseif position == "topleft" then
					direction = 1
					bar:SetPoint("BOTTOMLEFT", anchorframe, "TOPLEFT", offset, gap)
				elseif position == "bottomleft" then
					direction = -1
					bar:SetPoint("TOPLEFT", anchorframe, "BOTTOMLEFT", offset, -1 * gap)
				elseif position == "leftup" then
					if iconside == "right" and showicons then
						offset = offset + height
					end
					if qpdb.iconposition == "left" and not qpdb.hideicon then
						offset = offset + qpdb.h
					end
					direction = 1
					bar:SetPoint("BOTTOMRIGHT", anchorframe, "BOTTOMLEFT", -1 * offset, gap)
				elseif position == "leftdown" then
					if iconside == "right" and showicons then
						offset = offset + height
					end
					if qpdb.iconposition == "left" and not qpdb.hideicon then
						offset = offset + qpdb.h
					end
					direction = -1
					bar:SetPoint("TOPRIGHT", anchorframe, "TOPLEFT", -3 * offset, -1 * gap)
				elseif position == "rightup" then
					if iconside == "left" and showicons then
						offset = offset + height
					end
					if qpdb.iconposition == "right" and not qpdb.hideicon then
						offset = offset + qpdb.h
					end
					direction = 1
					bar:SetPoint("BOTTOMLEFT", anchorframe, "BOTTOMRIGHT", offset, gap)
				elseif position == "rightdown" then
					if iconside == "left" and showicons then
						offset = offset + height
					end
					if qpdb.iconposition == "right" and not qpdb.hideicon then
						offset = offset + qpdb.h
					end
					direction = -1
					bar:SetPoint("TOPLEFT", anchorframe, "TOPRIGHT", offset, -1 * gap)
				end
			else
				if direction == 1 then
					bar:SetPoint("BOTTOMRIGHT", bars[i-1], "TOPRIGHT", 0, spacing)
				else -- -1
					bar:SetPoint("TOPRIGHT", bars[i-1], "BOTTOMRIGHT", 0, -1 * spacing)
				end
			end
		end


		local timerText = bar.cd and bar.cd.timerText
		if timerText then
			if db.bufftimetext then
				timerText:Show()
				timerText:ClearAllPoints()
				timerText:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
				timerText:SetJustifyH("RIGHT")
				
				timerText:SetFont(media:Fetch("font", db.bufffont), db.bufffontsize)
				timerText:SetShadowColor( 0, 0, 0, 1)
				timerText:SetTextColor(unpack(db.bufftextcolor))
			else
				timerText:Hide()
			end
		end

		local timerWidth = db.bufftimetext and 30 or 0


		local text = bar.text
		if db.buffnametext then
			text:Show()
			text:ClearAllPoints()
			text:SetPoint("LEFT", bar, "LEFT", 2, 0)
			text:SetJustifyH("LEFT")
			if db.bufftimetext then
				text:SetWidth(width - timerWidth)
			else
				text:SetWidth(width)
			end
		else
			text:Hide()
		end
		text:SetFont(media:Fetch("font", db.bufffont), db.bufffontsize)
		text:SetShadowColor( 0, 0, 0, 1)
		text:SetShadowOffset( 0.8, -0.8 )
		text:SetTextColor(unpack(db.bufftextcolor))
		text:SetNonSpaceWrap(false)
		text:SetHeight(height)

		local icon = bar.icon
		if icons then
			icon:Show()
			icon:SetWidth(height-1)
			icon:SetHeight(height-1)
			icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			icon:ClearAllPoints()
			if iconside == "left" then
				icon:SetPoint("RIGHT", bar, "LEFT", -1, 0)
			else
				icon:SetPoint("LEFT", bar, "RIGHT", 1, 0)
			end
		else
			icon:Hide()
		end

		return direction
	end
	function Buff:ApplySettings()
		db = self.db.profile
		if self:IsEnabled() then
			local direction
			if db.targetanchor ~= "free" then
				targetbars[1].Hide = nil
				targetbars[1]:EnableMouse(false)
				targetbars[1]:SetScript("OnDragStart", nil)
				targetbars[1]:SetScript("OnDragStop", nil)
			end
			if db.focusanchor ~= "free" then
				focusbars[1].Hide = nil
				focusbars[1]:EnableMouse(false)
				focusbars[1]:SetScript("OnDragStart", nil)
				focusbars[1]:SetScript("OnDragStop", nil)
			end
			for i, v in pairs(targetbars) do
				direction = apply("target", i, v, direction)
			end
			direction = nil
			for i, v in pairs(focusbars) do
				direction = apply("focus", i, v, direction)
			end
			self:UpdateBars()
		end
	end
end

