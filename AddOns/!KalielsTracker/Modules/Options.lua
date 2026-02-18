--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

---@class Options
local M = KT:NewModule("Options")
KT.Options = M

local ACD = LibStub("MSA-AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetLists = AceGUIWidgetLSMlists
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local abs = math.abs
local floor = math.floor
local fmod = math.fmod
local format = string.format
local gsub = string.gsub
local ipairs = ipairs
local pairs = pairs
local round = function(n) return floor(n + 0.5) end
local strlen = string.len
local strsplit = string.split
local strsub = string.sub

local db, dbChar
local anchors = { ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" }
local strata = { "BACKGROUND", "LOW", "MEDIUM", "HIGH" }
local flags = { [""] = "None", ["OUTLINE"] = "Outline", ["OUTLINE, MONOCHROME"] = "Outline Monochrome" }
local textures = { "None", "Default (Blizzard)", "One line", "Two lines" }
local modifiers = { [""] = "None", ["ALT"] = "Alt", ["CTRL"] = "Ctrl", ["ALT-CTRL"] = "Alt + Ctrl" }
local SOUND_CHANNELS = { "Master", "Music", "SFX", "Ambience" }
local SOUND_CHANNELS_LOCALIZED = { Master = "Master", Music = MUSIC_VOLUME, SFX = FX_VOLUME, Ambience = AMBIENCE_VOLUME }
local VISIBILITY_OPTIONS = { "show", "hide", "expand", "collapse" }
local VISIBILITY_OPTIONS_LOCALIZED = { show = "Show", hide = "Hide", expand = "Show + Expand", collapse = "Show + Collapse" }
local realmZones = { ["EU"] = "Europe", ["NA"] = "North America" }
local ICON_HEART = "|T"..KT.MEDIA_PATH.."Help\\help_patreon:14:14:0:0:256:32:174:190:0:16|t"
local defaults

local cTitle = " "..NORMAL_FONT_COLOR_CODE
local cBold = "|cff00ffe3"
local cBold2 = "|cffffd200"
local cWarning = "|cffff7f00"
local cWarning2 = "|cffff4200"
local beta = "|cffff7fff[Beta]|r"
local warning = cWarning.."Warning:|r UI will be re-loaded!"

local KTF = KT.frame
local OTF = KT_ObjectiveTrackerFrame

local KTSetHeight = KTF.SetHeight

local MoveModule, SetSharedColor, IsSpecialLocale, Keybind  -- functions

-- Edit Mode - Mover
local moverOptions
local mover = KT:Mover_Create(addonName, KTF)
mover.editAnchors = true

local function Mover_SetPositionVars(frame)
	local left = frame:GetLeft() * db.frameScale
	local top = frame:GetTop() * db.frameScale
	local bottom = frame:GetBottom() * db.frameScale
	local width = frame:GetWidth() * db.frameScale
	if db.anchorPoint == "TOPLEFT" then
		db.xOffset = round(left)
		db.yOffset = round(top - UIParent:GetHeight())
	elseif db.anchorPoint == "TOPRIGHT" then
		db.xOffset = round(left + width - UIParent:GetWidth())
		db.yOffset = round(top - UIParent:GetHeight())
	elseif db.anchorPoint == "BOTTOMLEFT" then
		db.xOffset = round(left)
		db.yOffset = round(bottom)
	elseif db.anchorPoint == "BOTTOMRIGHT" then
		db.xOffset = round(left + width - UIParent:GetWidth())
		db.yOffset = round(bottom)
	end
end

local function Mover_UpdateOptions(updateValues, stopUpdateUI)
	local opt = moverOptions.args.tracker.args
	local screenWidth = round(GetScreenWidth())
	local screenHeight = round(GetScreenHeight())
	local xOffsetMax = round(screenWidth - (db.width * db.frameScale))
	local yOffsetMax = round(screenHeight - (opt.maxHeight.min * db.frameScale))
	local anchorLeft = (db.anchorPoint == "TOPLEFT" or db.anchorPoint == "BOTTOMLEFT")
	local directionUp = (db.anchorPoint == "BOTTOMLEFT" or db.anchorPoint == "BOTTOMRIGHT")

	if anchorLeft then
		opt.xOffset.min = 0
		opt.xOffset.max = xOffsetMax
	else
		opt.xOffset.min = xOffsetMax * -1
		opt.xOffset.max = 0
	end

	if directionUp then
		opt.yOffset.min = 0
		opt.yOffset.max = yOffsetMax
	else
		opt.yOffset.min = yOffsetMax * -1
		opt.yOffset.max = 0
	end

	opt.maxHeight.max = round((screenHeight - abs(db.yOffset)) / db.frameScale)
	if opt.maxHeight.max < opt.maxHeight.min then
		opt.maxHeight.max = opt.maxHeight.min
	end

	if updateValues then
		if round(abs(db.xOffset) + (db.width * db.frameScale)) > screenWidth then
			if opt.width.min == opt.width.max then
				db.xOffset = anchorLeft and opt.xOffset.max or opt.xOffset.min
			end
		end

		if round(abs(db.yOffset) + (db.maxHeight * db.frameScale)) > screenHeight then
			db.maxHeight = opt.maxHeight.max
			if opt.maxHeight.min == opt.maxHeight.max then
				db.yOffset = directionUp and opt.yOffset.max or opt.yOffset.min
			end
		end
	end
	if not stopUpdateUI then
		ACR:NotifyChange(addonName.."EditMode")
	end
end

local function Mover_SetScale()
	if db.pixelPerfectScale then
		db.frameScale = KT.GetPixelPerfectScale(KTF)
		KT:SetScale(db.frameScale)
	end
	Mover_UpdateOptions(true, true)
	KT:MoveTracker()
	KT:Update()
	mover:Update()
end

function mover:Anchor_OnEnter()
	if self.value == "TOPLEFT" or self.value == "TOPRIGHT" then
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5 * db.frameScale)
	elseif self.value == "BOTTOMLEFT" or self.value == "BOTTOMRIGHT" then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5 * db.frameScale)
	end
	GameTooltip:AddLine("Anchor - "..anchors[self.value], 1, 0.82, 0)
	local leftText = "- Tracker expand direction:\n- Tooltips position:\n- Quest item buttons position:"
	local rightText = ""
	if self.value == "TOPLEFT" then
		rightText = "Down\nRight\nRight"
	elseif self.value == "TOPRIGHT" then
		rightText = "Down\nLeft\nLeft"
	elseif self.value == "BOTTOMLEFT" then
		rightText = "Up\nRight\nRight"
	elseif self.value == "BOTTOMRIGHT" then
		rightText = "Up\nLeft\nLeft"
	end
	GameTooltip:AddDoubleLine(leftText, rightText, 1, 1, 1, 0, 1, 0.89)
	GameTooltip:Show()
end

function mover:Anchor_OnClick()
	db.anchorPoint = self.value
	Mover_SetPositionVars(self.obj.mover)
	Mover_UpdateOptions(true)
	KT:MoveTracker()
	KTF.height = 0  -- force update
	KT:Update()
end

function mover:OnDragStart(frame)
	if frame.Buttons.num > 0 then
		frame.Buttons:Hide()
	end
	if not db.directionUp then
		KTSetHeight(KTF, KTF.height)
	end
end

function mover:OnDragStop(frame)
	if frame.Buttons.num > 0 then
		frame.Buttons:Show()
	end
	Mover_SetPositionVars(self.mover)
	Mover_UpdateOptions(true)
	KT:MoveTracker()
	KT:SetSize(true)
end

function mover:OnMouseUp(frame, button)
	if button == "RightButton" then
		db.anchorPoint = defaults.profile.anchorPoint
		db.xOffset = defaults.profile.xOffset
		db.yOffset = defaults.profile.yOffset
		db.maxHeight = defaults.profile.maxHeight

		Mover_UpdateOptions(true)
		KT:MoveTracker()
		KTF.height = 0  -- force update
		KT:Update()
	end
end

function mover:Update()
	self.anchorPoint = db.anchorPoint
	self.mixin.Update(self)

	local frame = self.mover
	if frame then
		frame:SetSize(db.width, db.maxHeight)
		frame:ClearAllPoints()
		frame:SetPoint(db.anchorPoint)
	end
end

-- Edit Mode - Options
moverOptions = {
	name = "|T"..KT.MEDIA_PATH.."KT_logo:22:22:0:0|t"..KT.TITLE.."|cffffffff - Edit Mode",
	type = "group",
	get = function(info) return db[info[#info]] end,
	args = {
		tracker = {
			name = "Tracker",
			type = "group",
			args = {
				intro = {
					name = "\n"..KT.GetUiIcon("MouseLeft", "markup")..cBold.."Left Click|r on mover to drag the tracker element.\n"..
							KT.GetUiIcon("MouseRight", "markup")..cBold.."Right Click|r on mover to restore the default position and size.\n",
					type = "description",
					justifyH = "CENTER",
					order = 0,
				},
				xOffset = {
					name = "X offset",
					desc = function()
						return "Horizontal position\n- Default: "..defaults.profile.xOffset.."\n- Step: 1"
					end,
					type = "range",
					min = 0,
					max = 0,
					step = 1,
					set = function(_, value)
						db.xOffset = value
						KT:MoveTracker()
						mover:Update()
					end,
					order = 1,
				},
				yOffset = {
					name = "Y offset",
					desc = function()
						return "Vertical position\n- Default: "..defaults.profile.yOffset.."\n- Step: 1"
					end,
					type = "range",
					min = 0,
					max = 0,
					step = 1,
					set = function(_, value)
						db.yOffset = value
						Mover_UpdateOptions(true, true)
						KT:MoveTracker()
						KT:SetSize(true)
						mover:Update()
					end,
					order = 2,
				},
				width = {
					name = "Width",
					desc = function()
						return "- Default: "..defaults.profile.width.."\n- Step: 1"
					end,
					type = "range",
					min = function() return defaults.profile.width end,
					max = function() return defaults.profile.width end,
					step = 1,
					disabled = true,
					set = function(_, value)
						db.width = value
						KT:SetSize()
						mover:Update()
					end,
					order = 3,
				},
				maxHeight = {
					name = "Max. height",
					desc = function()
						return "- Default: "..defaults.profile.maxHeight.."\n- Step: 1"
					end,
					type = "range",
					min = 130,
					max = 130,
					step = 1,
					set = function(_, value)
						db.maxHeight = value
						KT:SetSize(true)
						mover:Update()
					end,
					order = 4,
				},
				notes = {
					name = cBold.." Width|r is disabled, because it is not implemented now.\n\n"..
							cBold.." Max. height|r is related with Y offset (top/bottom) of tracker.\n"..
							" - Content is lesser ... tracker height is automatically increases.\n"..
							" - Content is greater ... tracker enables scrolling.",
					type = "description",
					order = 5,
				},
				frameScale = {
					name = "Scale",
					desc = function()
						return "- Default: "..defaults.profile.frameScale.."\n- Step: 0.001"
					end,
					type = "range",
					min = 0.4,
					max = 1.7,
					step = 0.001,
					isRaw = true,
					disabled = function()
						return db.pixelPerfectScale
					end,
					set = function(_, value)
						db.frameScale = value
						KT:SetScale(db.frameScale)
						Mover_UpdateOptions(true, true)
						KT:MoveTracker()
						KTF.height = 0  -- force update
						KT:Update()
						mover:Update()
					end,
					order = 6,
				},
				pixelPerfectScale = {
					name = "Pixel Perfect Scale",
					desc = "Constant pixel perfect scale, relative to global UI scale.",
					type = "toggle",
					set = function()
						db.pixelPerfectScale = not db.pixelPerfectScale
						Mover_SetScale()
					end,
					order = 7,
				},
				frameStrata = {
					name = "Strata",
					desc = function()
						return "- Default: "..defaults.profile.frameStrata
					end,
					type = "select",
					values = strata,
					get = function()
						for k, v in ipairs(strata) do
							if db.frameStrata == v then
								return k
							end
						end
					end,
					set = function(_, value)
						db.frameStrata = strata[value]
						KT:SetFrameStrata(db.frameStrata)
					end,
					order = 8,
				},
			},
		},
	},
}
KT.EditMode = KT:EditMode_Create(addonName, moverOptions, "tracker", 440, 420)
KT.EditMode.OnOpen = function()
    KT:SetHidden(false)
end

-- Options
local options = {
	name = "|T"..KT.MEDIA_PATH.."KT_logo:22:22:-1:7|t"..KT.TITLE,
	type = "group",
	get = function(info) return db[info[#info]] end,
	args = {
		general = {
			name = "Options",
			type = "group",
			args = {
				sec0 = {
					name = "Info",
					type = "group",
					inline = true,
					order = 0,
					args = {
						version = {
							name = " |cffffd100Version:|r  "..KT.VERSION,
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 1.1,
						},
						build = {
							name = " |cffffd100Build:|r  Retail",
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 1.2,
						},
						about = {
							name = "  Made with "..ICON_HEART.." since 2012\n"..
									"                             |cff999999by "..KT.AUTHOR,
							type = "description",
							width = "double",
							order = 3,
						},
						news = {
							name = "What's New",
							type = "execute",
							disabled = function()
								return not KT.Help:IsEnabled()
							end,
							func = function()
								KT.Help:ShowHelp(true)
							end,
							order = 2,
						},
						help = {
							name = "Help",
							type = "execute",
							disabled = function()
								return not KT.Help:IsEnabled()
							end,
							func = function()
								KT.Help:ShowHelp()
							end,
							order = 4,
						},
						supportersLabel = {
							name = "|cff00ff00Become a Patron",
							type = "description",
							width = "double",
							fontSize = "medium",
							justifyH = "RIGHT",
							order = 5.1,
						},
						supporters = {
							name = "Supporters",
							type = "execute",
							disabled = function()
								return not KT.Help:IsEnabled()
							end,
							func = function()
								KT.Help:ShowSupporters()
							end,
							order = 5.2,
						},
					},
				},
				sec1 = {
					name = "Position / Size",
					type = "group",
					inline = true,
					order = 1,
					args = {
						editMode = {
							name = "Edit Mode",
							desc = "Unlock addon UI elements.",
							type = "execute",
							func = function()
                                KT.EditMode:Open()
                            end,
							order = 1,
						},
						editModeNote = {
							name = cBold.." Set position, size, scale and strata of addon UI elements.",
							type = "description",
							width = "double",
							order = 2,
						},
						frameScrollbar = {
							name = "Show Scrollbar",
							desc = "Show Scrollbar when srolling is enabled. Color is shared with border.",
							type = "toggle",
							set = function()
								db.frameScrollbar = not db.frameScrollbar
								KTF.Bar:SetShown(db.frameScrollbar)
							end,
							order = 3,
						},
					},
				},
				sec2 = {
					name = "Background / Border",
					type = "group",
					inline = true,
					order = 2,
					args = {
						bgr = {
							name = "Background texture",
							type = "select",
							dialogControl = "LSM30_Background",
							values = WidgetLists.background,
							set = function(_, value)
								db.bgr = value
								KT:SetBackground()
							end,
							order = 1,
						},
						bgrColor = {
							name = "Background color",
							type = "color",
							hasAlpha = true,
							get = function()
								return db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a
							end,
							set = function(_, r, g, b, a)
								db.bgrColor.r = r
								db.bgrColor.g = g
								db.bgrColor.b = b
								db.bgrColor.a = a
								KT:SetBackground()
							end,
							order = 2,
						},
						bgrNote = {
							name = cBold.." For a custom background\n texture set white color.",
							type = "description",
							width = "normal",
							order = 2.1,
						},
						border = {
							name = "Border texture",
							type = "select",
							dialogControl = "LSM30_Border",
							values = WidgetLists.border,
							set = function(_, value)
								db.border = value
								KT:SetBackground()
								KT:MoveButtons()
							end,
							order = 3,
						},
						borderColor = {
							name = "Border color",
							type = "color",
							disabled = function()
								return db.classBorder
							end,
							get = function()
								if not db.classBorder then
									SetSharedColor(db.borderColor)
								end
								return db.borderColor.r, db.borderColor.g, db.borderColor.b
							end,
							set = function(_, r, g, b)
								db.borderColor.r = r
								db.borderColor.g = g
								db.borderColor.b = b
								KT:SetBackground()
								KT:SetText()
								SetSharedColor(db.borderColor)
							end,
							order = 4,
						},
						classBorder = {
							name = "Border color by |cff%sClass|r",
							type = "toggle",
							get = function(info)
								if db[info[#info]] then
									SetSharedColor(KT.classColor)
								end
								return db[info[#info]]
							end,
							set = function()
								db.classBorder = not db.classBorder
								KT:SetBackground()
								KT:SetText()
							end,
							order = 5,
						},
						borderAlpha = {
							name = "Border transparency",
							desc = function()
								return "- Default: "..defaults.profile.borderAlpha.."\n- Step: 0.05"
							end,
							type = "range",
							min = 0.1,
							max = 1,
							step = 0.05,
							set = function(_, value)
								db.borderAlpha = value
								KT:SetBackground()
							end,
							order = 6,
						},
						borderThickness = {
							name = "Border thickness",
							desc = function()
								return "- Default: "..defaults.profile.borderThickness.."\n- Step: 0.5"
							end,
							type = "range",
							min = 1,
							max = 24,
							step = 0.5,
							set = function(_, value)
								db.borderThickness = value
								KT:SetBackground()
							end,
							order = 7,
						},
						bgrInset = {
							name = "Background inset",
							desc = function()
								return "- Default: "..defaults.profile.bgrInset.."\n- Step: 0.5"
							end,
							type = "range",
							min = 0,
							max = 10,
							step = 0.5,
							set = function(_, value)
								db.bgrInset = value
								KT:SetBackground()
								KT:MoveButtons()
							end,
							order = 8,
						},
						progressBar = {
							name = "Progress bar texture",
							type = "select",
							dialogControl = "LSM30_Statusbar",
							values = WidgetLists.statusbar,
							set = function(_, value)
								db.progressBar = value
								KT:SendSignal("OPTIONS_CHANGED", true)
							end,
							order = 9,
						},
					},
				},
				sec3 = {
					name = "Texts",
					type = "group",
					inline = true,
					order = 3,
					args = {
						font = {
							name = "Font",
							type = "select",
							dialogControl = "LSM30_Font",
							values = WidgetLists.font,
							set = function(_, value)
								db.font = value
								KT:SetText(true)
								KT:SendSignal("OPTIONS_CHANGED")
							end,
							order = 1,
						},
						fontSize = {
							name = "Font size",
							type = "range",
							min = 10,
							max = 20,
							step = 1,
							set = function(_, value)
								db.fontSize = value
								KT:SetText(true)
								KT:SendSignal("OPTIONS_CHANGED")
							end,
							order = 2,
						},
						fontFlag = {
							name = "Font flag",
							type = "select",
							values = flags,
							get = function()
								for k, v in pairs(flags) do
									if db.fontFlag == k then
										return k
									end
								end
							end,
							set = function(_, value)
								db.fontFlag = value
								KT:SetText(true)
								KT:SendSignal("OPTIONS_CHANGED")
							end,
							order = 3,
						},
						fontShadow = {
							name = "Font shadow",
							desc = warning,
							type = "toggle",
							confirm = true,
							confirmText = warning,
							get = function()
								return (db.fontShadow == 1)
							end,
							set = function(_, value)
								db.fontShadow = value and 1 or 0
								ReloadUI()	-- WTF
							end,
							order = 4,
						},
						colorDifficulty = {
							name = "Color by difficulty",
							desc = "Quest titles color by difficulty.",
							type = "toggle",
							set = function()
								db.colorDifficulty = not db.colorDifficulty
								OTF:Update()
								QuestMapFrame_UpdateAll()
							end,
							order = 5,
						},
						textWordWrap = {
							name = "Wrap long texts",
							desc = "Long texts shows on two lines or on one line with ellipsis (...).",
							type = "toggle",
							set = function()
								db.textWordWrap = not db.textWordWrap
								KT:Update(true)
							end,
							order = 6,
						},
						objNumSwitch = {
							name = "Objective numbers at the beginning",
							desc = "Changing the position of objective numbers at the beginning of the line. "..
								   cBold.."Only for deDE, esES, frFR, ruRU locale.",
							descStyle = "inline",
							type = "toggle",
							width = 2.2,
							disabled = function()
								return not IsSpecialLocale()
							end,
							set = function()
								db.objNumSwitch = not db.objNumSwitch
								OTF:Update()
							end,
							order = 7,
						},
					},
				},
				sec4 = {
					name = "Headers",
					type = "group",
					inline = true,
					order = 4,
					args = {
						hdrBgrLabel = {
							name = " Texture",
							type = "description",
							width = "half",
							fontSize = "medium",
							order = 1,
						},
						hdrBgr = {
							name = "",
							type = "select",
							values = textures,
							get = function()
								for k, v in ipairs(textures) do
									if db.hdrBgr == k then
										return k
									end
								end
							end,
							set = function(_, value)
								db.hdrBgr = value
								KT:SetBackground()
							end,
							order = 1.1,
						},
						hdrBgrColor = {
							name = "Color",
							desc = "Sets the color to texture of the header.",
							type = "color",
							width = "half",
							disabled = function()
								return (db.hdrBgr == 1 or db.hdrBgrColorShare)
							end,
							get = function()
								return db.hdrBgrColor.r, db.hdrBgrColor.g, db.hdrBgrColor.b
							end,
							set = function(_, r, g, b)
								db.hdrBgrColor.r = r
								db.hdrBgrColor.g = g
								db.hdrBgrColor.b = b
								KT:SetBackground()
							end,
							order = 1.2,
						},
						hdrBgrColorShare = {
							name = "Use border color",
							desc = "The color of texture is shared with the border color.",
							type = "toggle",
							disabled = function()
								return (db.hdrBgr == 1)
							end,
							set = function()
								db.hdrBgrColorShare = not db.hdrBgrColorShare
								KT:SetBackground()
							end,
							order = 1.3,
						},
						hdrTrackerBgrSpacer1 = {
							name = " ",
							type = "description",
							width = "half",
							order = 1.4,
						},
						hdrTrackerBgrShow = {
							name = "Show tracker header texture",
							type = "toggle",
							width = "normal+half",
							disabled = function()
								return (db.hdrBgr == 1)
							end,
							set = function()
								db.hdrTrackerBgrShow = not db.hdrTrackerBgrShow
								KT:SetBackground()
							end,
							order = 1.5,
						},
						hdrTrackerBgrSpacer2 = {
							name = " ",
							type = "description",
							width = "normal",
							order = 1.6,
						},
						hdrTxtLabel = {
							name = " Text",
							type = "description",
							width = "half",
							fontSize = "medium",
							order = 2,
						},
						hdrTxtColor = {
							name = "Color",
							desc = "Sets the color to header texts.",
							type = "color",
							width = "half",
							disabled = function()
								return db.hdrTxtColorShare
							end,
							get = function()
								return db.hdrTxtColor.r, db.hdrTxtColor.g, db.hdrTxtColor.b
							end,
							set = function(_, r, g, b)
								db.hdrTxtColor.r = r
								db.hdrTxtColor.g = g
								db.hdrTxtColor.b = b
								KT:SetText()
							end,
							order = 2.1,
						},
						hdrTxtColorShare = {
							name = "Use border color",
							desc = "The color of header texts is shared with the border color.",
							type = "toggle",
							set = function()
								db.hdrTxtColorShare = not db.hdrTxtColorShare
								KT:SetText()
							end,
							order = 2.2,
						},
						hdrTxtSpacer = {
							name = " ",
							type = "description",
							width = "normal",
							order = 2.3,
						},
						hdrBtnLabel = {
							name = " Buttons",
							type = "description",
							width = "half",
							fontSize = "medium",
							order = 3,
						},
						hdrBtnColor = {
							name = "Color",
							desc = "Sets the color to all header buttons.",
							type = "color",
							width = "half",
							disabled = function()
								return db.hdrBtnColorShare
							end,
							get = function()
								return db.hdrBtnColor.r, db.hdrBtnColor.g, db.hdrBtnColor.b
							end,
							set = function(_, r, g, b)
								db.hdrBtnColor.r = r
								db.hdrBtnColor.g = g
								db.hdrBtnColor.b = b
								KT:SetBackground()
							end,
							order = 3.2,
						},
						hdrBtnColorShare = {
							name = "Use border color",
							desc = "The color of all header buttons is shared with the border color.",
							type = "toggle",
							set = function()
								db.hdrBtnColorShare = not db.hdrBtnColorShare
								KT:SetBackground()
							end,
							order = 3.3,
						},
						hdrBtnSpacer = {
							name = " ",
							type = "description",
							width = "normal",
							order = 3.4,
						},
						sec4SpacerMid1 = {
							name = " ",
							type = "description",
							order = 3.5,
						},
						hdrQuestsTitleAppend = {
							name = "Show number of Quests",
							desc = "Show number of Quests inside the Quests header.",
							type = "toggle",
							width = "normal+half",
							set = function()
								db.hdrQuestsTitleAppend = not db.hdrQuestsTitleAppend
								KT:SetQuestsHeaderText(true)
							end,
							order = 4,
						},
						hdrAchievsTitleAppend = {
							name = "Show Achievement points",
							desc = "Show Achievement points inside the Achievements header.",
							type = "toggle",
							width = "normal+half",
							set = function()
								db.hdrAchievsTitleAppend = not db.hdrAchievsTitleAppend
								KT:SetAchievsHeaderText(true)
							end,
							order = 5,
						},
						hdrPetTrackerTitleAppend = {  -- Addon - PetTracker
							name = "Show number of owned Pets",
							desc = "Show number of owned Pets inside the PetTracker header.",
							type = "toggle",
							width = "normal+half",
							disabled = function()
								return not KT.AddonPetTracker.isAvailable
							end,
							set = function()
								db.hdrPetTrackerTitleAppend = not db.hdrPetTrackerTitleAppend
								KT.AddonPetTracker:SetPetsHeaderText(true)
							end,
							order = 6,
						},
						sec4SpacerMid2 = {
							name = " ",
							type = "description",
							order = 7,
						},
						hdrCollapsedTxtLabel = {
							name = " Collapsed tracker text",
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 9,
						},
						hdrCollapsedTxt1 = {
							name = "None",
							desc = "Reduces the tracker width when minimized.",
							type = "toggle",
							width = "half",
							get = function()
								return (db.hdrCollapsedTxt == 1)
							end,
							set = function()
								db.hdrCollapsedTxt = 1
								OTF:Update()
							end,
							order = 9.1,
						},
						hdrCollapsedTxt2 = {
							name = "|T"..KT.MEDIA_PATH.."KT_logo:22:22:2:0|t "..KT.TITLE,
							type = "toggle",
							width = "normal",
							get = function()
								return (db.hdrCollapsedTxt == 2)
							end,
							set = function()
								db.hdrCollapsedTxt = 2
								OTF:Update()
							end,
							order = 9.2,
						},
						sec4SpacerMid3 = {
							name = " ",
							type = "description",
							order = 10,
						},
						hdrOtherButtons = {
							name = "Show Quest Log and Achievements buttons",
							type = "toggle",
							width = "double",
							set = function()
								db.hdrOtherButtons = not db.hdrOtherButtons
								KT:SetOtherButtons()
								KT:SetBackground()
								OTF:Update()
							end,
							order = 11,
						},
					},
				},
				sec5 = {
					name = "Quest item buttons",
					type = "group",
					inline = true,
					order = 5,
					args = {
						qiBgrBorder = {
							name = "Show buttons block background and border",
							type = "toggle",
							width = "double",
							set = function()
								db.qiBgrBorder = not db.qiBgrBorder
								KT:SetBackground()
								KT:MoveButtons()
							end,
							order = 1,
						},
						qiXOffset = {
							name = "X offset",
							type = "range",
							min = -10,
							max = 10,
							step = 1,
							set = function(_, value)
								db.qiXOffset = value
								KT:MoveButtons()
							end,
							order = 2,
						},
						qiActiveButton = {
							name = "Enable Active button",
							desc = "Show Quest item button for CLOSEST quest as \"Extra Action Button\".",
							descStyle = "inline",
							width = "double",
							type = "toggle",
                            confirm = true,
                            confirmText = warning,
							set = function()
								db.qiActiveButton = not db.qiActiveButton
								if db.qiActiveButton then
									KT.ActiveButton:Enable()
								else
									KT.ActiveButton:Disable()
                                end
                                ReloadUI()
							end,
							order = 3,
						},
						qiActiveButtonBindingShow = {
							name = "Show Active button Binding text",
							width = "normal+half",
							type = "toggle",
							disabled = function()
								return not db.qiActiveButton
							end,
							set = function()
								db.qiActiveButtonBindingShow = not db.qiActiveButtonBindingShow
								KTF.ActiveFrame:Hide()
								KT.ActiveButton:Update()
							end,
							order = 4,
						},
						qiActiveButtonSpacer = {
							name = " ",
							type = "description",
							width = "half",
							order = 5.1,
						},
						addonMasqueLabel = {
							name = " Skin options - for Quest item buttons or Active button",
							type = "description",
							width = "double",
							fontSize = "medium",
							order = 7,
						},
						addonMasqueOptions = {
							name = "Masque",
							type = "execute",
							disabled = function()
								return (not C_AddOns.IsAddOnLoaded("Masque") or not db.addonMasque or not KT.AddonOthers:IsEnabled())
							end,
							func = function()
								SlashCmdList["MASQUE"]()
							end,
							order = 7.1,
						},
					},
				},
				sec6 = {
					name = "Other options",
					type = "group",
					inline = true,
					order = 6,
					args = {
						tooltipTitle = {
							name = cTitle.."Tooltips",
							type = "description",
							fontSize = "medium",
							order = 2,
						},
						tooltipShow = {
							name = "Show tooltips",
							desc = "Show Quest / World Quest / Achievement / Scenario tooltips.",
							type = "toggle",
							set = function()
								db.tooltipShow = not db.tooltipShow
							end,
							order = 2.1,
						},
						tooltipShowRewards = {
							name = "Show Rewards",
							desc = "Show Quest Rewards inside tooltips - Artifact Power, Order Resources, Money, Equipment etc.",
							type = "toggle",
							disabled = function()
								return not db.tooltipShow
							end,
							set = function()
								db.tooltipShowRewards = not db.tooltipShowRewards
							end,
							order = 2.2,
						},
						tooltipShowID = {
							name = "Show ID",
							desc = "Show Quest / World Quest / Achievement ID inside tooltips.",
							type = "toggle",
							disabled = function()
								return not db.tooltipShow
							end,
							set = function()
								db.tooltipShowID = not db.tooltipShowID
							end,
							order = 2.3,
						},
						menuTitle = {
							name = "\n"..cTitle.."Menu items",
							type = "description",
							fontSize = "medium",
							order = 3,
						},
                        menuWowheadURL = {
							name = "Wowhead URL",
							desc = "Show Wowhead URL menu item inside the tracker and Quest Log.",
							type = "toggle",
							set = function()
								db.menuWowheadURL = not db.menuWowheadURL
							end,
							order = 3.1,
						},
                        menuWowheadURLModifier = {
							name = "Wowhead URL click modifier",
							type = "select",
							values = modifiers,
							get = function()
								for k, v in pairs(modifiers) do
									if db.menuWowheadURLModifier == k then
										return k
									end
								end
							end,
							set = function(_, value)
								db.menuWowheadURLModifier = value
							end,
							order = 3.2,
						},
						menuWowheadURLSpacer = {
							name = " ",
							type = "description",
							width = "normal",
							order = 3.3,
						},
						menuYouTubeURL = {
							name = "YouTube Search URL",
							desc = "Show YouTube Search URL menu item inside the tracker and Quest Log.",
							type = "toggle",
							set = function()
								db.menuYouTubeURL = not db.menuYouTubeURL
							end,
							order = 3.4,
						},
						menuYouTubeURLModifier = {
							name = "YouTube Search URL click modifier",
							type = "select",
							values = modifiers,
							get = function()
								for k, v in pairs(modifiers) do
									if db.menuYouTubeURLModifier == k then
										return k
									end
								end
							end,
							set = function(_, value)
								db.menuYouTubeURLModifier = value
							end,
							order = 3.5,
						},
                        questTitle = {
                            name = cTitle.."\n Quests",
                            type = "description",
                            fontSize = "medium",
                            order = 4,
                        },
                        questDefaultActionMap = {
                            name = "Quest default action - World Map",
                            desc = "Set the Quest default action as \"World Map\". Otherwise is the default action \"Quest Details\".",
                            type = "toggle",
                            width = "normal+half",
                            set = function()
                                db.questDefaultActionMap = not db.questDefaultActionMap
                            end,
                            order = 4.1,
                        },
						questShowTags = {
							name = "Show Quest tags",
							desc = "Show / Hide Quest tags (quest level, quest type) inside the tracker.",
							type = "toggle",
							width = "normal+half",
							set = function()
								db.questShowTags = not db.questShowTags
								OTF:Update()
							end,
							order = 4.2,
						},
						questShowZones = {
							name = "Show Quest Zones",
							desc = "Show / Hide Quest Zones inside the tracker.",
							type = "toggle",
							width = "normal+half",
							set = function()
								db.questShowZones = not db.questShowZones
								OTF:Update()
							end,
							order = 4.3,
						},
						taskShowFactions = {
							name = "Show World Quest Factions",
							desc = "Show / Hide World Quest Factions inside the tracker.",
							type = "toggle",
							width = "normal+half",
							set = function()
								db.taskShowFactions = not db.taskShowFactions
								OTF:Update()
							end,
							order = 4.4,
						},
						questAutoTrack = {
							name = "Auto Quest tracking",
							desc = "Quests are automatically watched when accepted. Uses Blizzard's value \"autoQuestWatch\".\n"..warning,
							type = "toggle",
							width = "normal+half",
							confirm = true,
							confirmText = warning,
							get = function()
								return GetCVarBool("autoQuestWatch")
							end,
							set = function(_, value)
								SetCVar("autoQuestWatch", value)
								ReloadUI()
							end,
							order = 4.5,
						},
						questProgressAutoTrack = {
							name = "Auto Quest progress tracking",
							desc = "Quests are automatically watched when progress updated. Uses Blizzard's value \"autoQuestProgress\".\n"..warning,
							type = "toggle",
							width = "normal+half",
							confirm = true,
							confirmText = warning,
							get = function()
								return GetCVarBool("autoQuestProgress")
							end,
							set = function(_, value)
								SetCVar("autoQuestProgress", value)
								ReloadUI()
							end,
							order = 4.6,
						},
						questAutoFocusClosest = {
							name = "Auto focus closest Quest                            ",  -- space for a wider tooltip
							desc = "Closest Quest is automatically focussed in specific situations:\n"..
									"- Quest was turned in and was focused,\n"..
									"- Quest was abandoned and was focused,\n"..
									"- Quest was untracked and was focused,\n"..
									"- World Quest was untracked and was focus,\n"..
									"- you manually or automatically select a Zone Filter and nothing is focused.",
							type = "toggle",
							width = "normal+half",
                            disabled = true,
							set = function()
								db.questAutoFocusClosest = not db.questAutoFocusClosest
							end,
							order = 4.7,
						},
					},
				},
				sec7 = {
					name = "Notification messages",
					type = "group",
					inline = true,
					order = 7,
					args = {
						messageQuest = {
							name = "Quest messages",
							type = "toggle",
							set = function()
								db.messageQuest = not db.messageQuest
							end,
							order = 1,
						},
						messageAchievement = {
							name = "Achievement messages",
							width = 1.1,
							type = "toggle",
							set = function()
								db.messageAchievement = not db.messageAchievement
							end,
							order = 2,
						},
						-- LibSink
					},
				},
				sec8 = {
					name = "Notification sounds",
					type = "group",
					inline = true,
					order = 8,
					args = {
						soundChannelLabel = {
							name = " Sound channel",
							type = "description",
							width = 1,
							fontSize = "medium",
							order = 1,
						},
						soundChannel = {
							name = "",
							type = "select",
							width = 1.05,
							values = SOUND_CHANNELS_LOCALIZED,
							sorting = SOUND_CHANNELS,
							set = function(_, value)
								db.soundChannel = value
							end,
							order = 1.1,
						},
						soundChannelSpacer1 = {
							name = " ",
							type = "description",
							width = 0.95,
							order = 1.2,
						},
						soundQuest = {
							name = "Quest sounds",
							type = "toggle",
							set = function()
								db.soundQuest = not db.soundQuest
							end,
							order = 2,
						},
						soundQuestComplete = {
							name = "Complete Sound",
							desc = "Addon sounds are prefixed \"KT - \".",
							type = "select",
							width = 1.05,
							disabled = function()
								return not db.soundQuest
							end,
							dialogControl = "MSA_LSM30_Sound",
							soundChannel = function()
								return db.soundChannel
							end,
							values = WidgetLists.sound,
							set = function(_, value)
								db.soundQuestComplete = value
							end,
							order = 2.1,
						},
					},
				},
			},
		},
		controls = {
			name = "Controls",
			type = "group",
			args = {
				sec1 = {
					name = "Slash commands",
					type = "group",
					inline = true,
					order = 1,
					args = {
						command1 = {
							name = cBold.." /kt",
							type = "description",
							width = 0.7,
							fontSize = "medium",
							order = 1.1,
						},
						command1Desc = {
							name = "Expand / Collapse tracker",
							type = "description",
							width = 2.3,
							order = 1.2,
						},
						command2 = {
							name = cBold.." /kt showhide",
							type = "description",
							width = 0.7,
							fontSize = "medium",
							order = 2.1,
						},
						command2Desc = {
							name = "Show / Hide tracker",
							type = "description",
							width = 2.3,
							order = 2.24,
						},
						command3 = {
							name = cBold.." /kt config",
							type = "description",
							width = 0.7,
							fontSize = "medium",
							order = 3.1,
						},
						command3Desc = {
							name = "Open addon Options",
							type = "description",
							width = 2.3,
							order = 3.24,
						},
					},
				},
				sec2 = {
					name = "Keybindings",
					type = "group",
					inline = true,
					order = 2,
					args = {
						keyBindCollapseLabel = {
							name = " Expand / Collapse tracker",
							type = "description",
							width = 2,
							fontSize = "medium",
							order = 1.1,
						},
						keyBindCollapse = {
							name = "",
							type = "keybinding",
							set = function(_, value)
								Keybind(value, "keyBindCollapse")
							end,
							order = 1.2,
						},
						keyBindHideLabel = {
							name = " Show / Hide tracker",
							type = "description",
							width = 2,
							fontSize = "medium",
							order = 2.1,
						},
						keyBindHide = {
							name = "",
							type = "keybinding",
							set = function(_, value)
								Keybind(value, "keyBindHide")
							end,
							order = 2.2,
						},
						keyBindClosestQuestLabel = {
							name = " Focus closest Quest",
							type = "description",
							width = 2,
							fontSize = "medium",
							order = 3.1,
						},
						keyBindClosestQuest = {
							name = "",
							type = "keybinding",
							set = function(_, value)
								Keybind(value, "keyBindClosestQuest")
							end,
							order = 3.2,
						},
						keyBindActiveButtonLabel = {
							name = " Active button (Quest item)",
							type = "description",
							width = 1,
							fontSize = "medium",
							order = 4.1,
						},
						keyBindActiveButtonDesc = {
							name = "Shared with "..cBold..BINDING_NAME_EXTRAACTIONBUTTON1,
							type = "description",
							width = 1,
							justifyH = "RIGHT",
							order = 4.15,
						},
						keyBindActiveButton = {
							name = "",
							type = "keybinding",
							disabled = function()
								return not db.qiActiveButton
							end,
							get = function()
								return GetBindingKey("EXTRAACTIONBUTTON1")
							end,
							set = function(_, value)
								Keybind(value, "EXTRAACTIONBUTTON1")
							end,
							order = 4.2,
						},
					},
				},
				sec3 = {
					name = "Visibility rules",
					type = "group",
					inline = true,
					order = 3,
					args = {
						visibilityDesc = {
							name = " Rules are applied only once when the condition is met.\n"..
									" A hidden or collapsed tracker can be manually shown or expanded at any time.",
							type = "description",
							order = 0,
						},
						activeContextLabel = {
							name = "\n Active Rule ...\n ",
							type = "description",
							width = 0.7,
							fontSize = "medium",
							order = 1.1,
						},
						activeContext = {
							name = " ",
							type = "description",
							width = 2.3,
							fontSize = "medium",
							order = 1.2,
						},
						trackerLabel = {
							name = " Tracker",
							type = "description",
							width = 0.7,
							fontSize = "medium",
							order = 2.1,
						},
						hideEmptyTracker = {
							name = "Hide empty tracker",
							type = "toggle",
							set = function()
								db.hideEmptyTracker = not db.hideEmptyTracker
								KT:SendSignal("OPTIONS_CHANGED")
							end,
							order = 2.2,
						},
						trackerSpacer = {
							name = " ",
							type = "description",
							width = 1.3,
							order = 2.3,
						},
						contextsNote = {
							name = "\n * Normal / Heroic / Mythic / Scenario",
							type = "description",
							order = 30,
						},
					},
				},
			},
		},
		modules = {
			name = "Modules",
			type = "group",
			args = {
				sec1 = {
					name = "Order of Modules",
					type = "group",
					inline = true,
					order = 1,
					args = {
						descCurOrder = {
							name = cTitle.."Current Order",
							type = "description",
							width = "double",
							fontSize = "medium",
							order = 0.1,
						},
						descDefOrder = {
							name = "|T:1:20|t"..cTitle.."Default Order",
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 0.2,
						},
						descModules = {
							name = "\n * "..TRACKER_HEADER_DUNGEON.." / "..PLAYER_DIFFICULTY_MYTHIC_PLUS.." / "..CHALLENGE_MODE.." / "..TRACKER_HEADER_SCENARIO.." / "..TRACKER_HEADER_PROVINGGROUNDS,
							type = "description",
							order = 20,
						},
					},
				},
			},
		},
		addons = {
			name = "Supported addons",
			type = "group",
			args = {
				desc = {
					name = "|cff00d200Green|r - compatible version - this version was tested and support is inserted.\n"..
							"|cffff0000Red|r - incompatible version - this version wasn't tested, maybe will need some code changes.\n"..
							"Please report all problems.",
					type = "description",
					order = 0,
				},
				sec1 = {
					name = "Addons",
					type = "group",
					inline = true,
					order = 1,
					args = {
						addonMasque = {
							name = "Masque",
							desc = "Version: %s",
							descStyle = "inline",
							type = "toggle",
							width = 1.05,
							confirm = true,
							confirmText = warning,
							disabled = function()
								return (not C_AddOns.IsAddOnLoaded("Masque") or not KT.AddonOthers:IsEnabled())
							end,
							set = function()
								db.addonMasque = not db.addonMasque
								ReloadUI()
							end,
							order = 1.1,
						},
						addonMasqueDesc = {
							name = "Enables skinning of Quest Item buttons and the Active Button.",
							type = "description",
							width = "double",
							order = 1.2,
						},
						addonPetTracker = {
							name = "PetTracker",
							desc = "Version: %s",
							descStyle = "inline",
							type = "toggle",
							width = 1.05,
							confirm = true,
							confirmText = warning,
							disabled = function()
								return not C_AddOns.IsAddOnLoaded("PetTracker")
							end,
							set = function()
								db.addonPetTracker = not db.addonPetTracker
								if PetTracker.sets then
									PetTracker.sets.zoneTracker = db.addonPetTracker
								end
								ReloadUI()
							end,
							order = 2.1,
						},
						addonPetTrackerDesc = {
							name = "Enables display of zone pet tracking inside the tracker and fixes some visual issues.",
							type = "description",
							width = "double",
							order = 2.2,
						},
						addonTomTom = {
							name = "TomTom",
							desc = "Version: %s",
							descStyle = "inline",
							type = "toggle",
							width = 1.05,
							confirm = true,
							confirmText = warning,
							disabled = function()
								return not C_AddOns.IsAddOnLoaded("TomTom")
							end,
							set = function()
								db.addonTomTom = not db.addonTomTom
								ReloadUI()
							end,
							order = 3.1,
						},
						addonTomTomDesc = {
							name = "Enables integration of Blizzard's POI with TomTom's Arrow for better navigation.",
							type = "description",
							width = "double",
							order = 3.2,
						},
						addonRareScanner = {
							name = "RareScanner",
							desc = "Version: %s",
							descStyle = "inline",
							type = "toggle",
							width = 1.05,
							confirm = true,
							confirmText = warning,
							disabled = function()
								return not C_AddOns.IsAddOnLoaded("RareScanner")
							end,
							set = function()
								db.addonRareScanner = not db.addonRareScanner
								ReloadUI()
							end,
							order = 4.1,
						},
						addonRareScannerDesc = {
							name = "Enables display of detected Rare NPCs inside the tracker.",
							type = "description",
							width = "double",
							order = 4.2,
						},
						addonAuctionator = {
							name = "Auctionator",
							desc = "Version: %s",
							descStyle = "inline",
							type = "toggle",
							width = 1.05,
							confirm = true,
							confirmText = warning,
							disabled = function()
								return not C_AddOns.IsAddOnLoaded("Auctionator")
							end,
							set = function()
								db.addonAuctionator = not db.addonAuctionator
								ReloadUI()
							end,
							order = 5.1,
						},
						addonAuctionatorDesc = {
							name = "Enables an Auctionator search button inside the Profession module header.",
							type = "description",
							width = "double",
							order = 5.2,
						},
						addonBtWQuests = {
							name = "BtWQuests",
							desc = "Version: %s",
							descStyle = "inline",
							type = "toggle",
							width = 1.05,
							confirm = true,
							confirmText = warning,
							disabled = function()
								return not C_AddOns.IsAddOnLoaded("BtWQuests")
							end,
							set = function()
								db.addonBtWQuests = not db.addonBtWQuests
								ReloadUI()
							end,
							order = 6.1,
						},
						addonBtWQuestsDesc = {
							name = "Enables an \"Open Quest Chain\" option in the Quest context menu.",
							type = "description",
							width = "double",
							order = 6.2,
						},
					},
				},
				sec2 = {
					name = "User Interfaces",
					type = "group",
					inline = true,
					order = 2,
					args = {
						elvui = {
							name = "ElvUI",
							type = "toggle",
							disabled = true,
							order = 1,
						},
						tukui = {
							name = "Tukui",
							type = "toggle",
							disabled = true,
							order = 2,
						},
						nibrealui = {
							name = "RealUI",
							type = "toggle",
							disabled = true,
							order = 3,
						},
					},
				},
			},
		},
		hacks = {
			name = "Hacks",
			type = "group",
			args = {
				desc = {
					name = cWarning.."Warning:|r Hacks may affect other addons!\n\nPlease report any negative impacts that are not described.",
					type = "description",
					order = 0,
				},
				sec1 = {
					name = DUNGEONS_BUTTON,
					type = "group",
					inline = true,
					order = 1,
					args = {
						hackLFG = {
							name = "LFG Hack",
							desc = cBold.."Affects the small Eye buttons|r for finding groups inside the tracker. When the hack is active, "..
									"the buttons work without errors. When the hack is inactive, the buttons are not available.\n\n"..
									cWarning2.."Negative impacts:|r\n"..
									"- Inside the dialog for create \"Premade Group\", the \"Title\" is not set automatically "..
									"(e.g. keystone level\nfor Mythic+).\n",
							descStyle = "inline",
							type = "toggle",
							width = "full",
							confirm = true,
							confirmText = warning,
							set = function()
								db.hackLFG = not db.hackLFG
								ReloadUI()
							end,
							order = 1,
						},
					},
				},
				sec2 = {
					name = WORLDMAP_BUTTON,
					type = "group",
					inline = true,
					order = 2,
					args = {
						hackWorldMap = {
							name = "World Map Hack",
							desc = cBold.."Affects the World Map|r and removes taint errors. The hack prevents calls to "..
									"restricted functions. When the hack is inactive, the World Map display causes errors. "..
									"It is not possible to get rid of these errors, since the tracker has a lot of interaction "..
									"with the game frames.\n\n"..
									cWarning2.."Negative impacts:|r unknown in WoW 12.0.0\n",
							descStyle = "inline",
							type = "toggle",
							width = "full",
							confirm = true,
							confirmText = warning,
							set = function()
								db.hackWorldMap = not db.hackWorldMap
								ReloadUI()
							end,
							order = 1,
						},
					},
				},
			},
		},
	},
}

local general = options.args.general
local controls = options.args.controls
local modules = options.args.modules
local addons = options.args.addons
local hacks = options.args.hacks

function KT:CheckAddOn(addon, version, isUI)
	local name = strsplit("_", addon)
	local ver = isUI and "" or "---"
	local result = false
	local opt
	if C_AddOns.IsAddOnLoaded(addon) then
		local actualVersion = C_AddOns.GetAddOnMetadata(addon, "Version") or "unknown"
		actualVersion = gsub(actualVersion, "(.*%S)%s+", "%1")
		self.T_Set(addon, actualVersion, "supportedAddons")
		ver = isUI and "  -  " or ""
		ver = (ver.."|cff%s"..actualVersion.."|r"):format(actualVersion == version and "00d200" or "ff0000")
		result = true
	end
	if not isUI then
		opt =  addons.args.sec1.args["addon"..name]
		opt.desc = opt.desc:format(ver)
	else
		opt =  addons.args.sec2.args[strlower(name)]
		opt.name = opt.name..ver
		opt.disabled = not result
		opt.get = function() return result end
	end
	return result
end

function KT:OpenOptions()
	if not self.InCombatBlocked() and self.optionsFrame and not EditModeManagerFrame:IsEditModeActive() then
		Settings.OpenToCategory(self.optionsFrame.general.name, self.TITLE)
	end
end

function KT:InitProfile(event, database, profile)
	ReloadUI()
end

local function Visibility_ShowActiveContext(_, contexts)
	local color = "|cff00ff00"
	local sep = "|r  |cff808080>|r  "
	local opt = controls.args.sec3.args

	for _, ctx in ipairs(KT.VISIBILITY_CONTEXTS) do
		local prefix = " "
		local suffix = ctx == "dungeon" and "|r *" or "|r"
		if ctx == contexts[1] then
			prefix = prefix..color
		end
		opt["visibility"..ctx.."Label"].name = prefix..KT.VISIBILITY_CONTEXTS_LOCALIZED[ctx]..suffix
	end

	local text = " "..color
	for i, ctx in ipairs(contexts) do
		if i > 1 then
			text = text..sep
		end
		text = text..KT.VISIBILITY_CONTEXTS_LOCALIZED[ctx]
	end
	opt.activeContext.name = text

	ACR:NotifyChange(addonName)
end

local function Visibility_CreateContextOptions(args)
	for i, ctx in ipairs(KT.VISIBILITY_CONTEXTS) do
		local name = "visibility"..ctx
		args[name.."Label"] = {
			name = " "..KT.VISIBILITY_CONTEXTS_LOCALIZED[ctx]..(ctx == "dungeon" and " *" or ""),
			type = "description",
			width = 0.7,
			fontSize = "medium",
			order = i + 2.1,
		}
		args[name] = {
			name = "",
			type = "select",
			values = VISIBILITY_OPTIONS_LOCALIZED,
			sorting = VISIBILITY_OPTIONS,
			set = function(_, value)
				db[name] = value
				KT:SendSignal("OPTIONS_CHANGED")
			end,
			order = i + 2.2,
		}
		args[name.."Spacer"] = {
			name = " ",
			type = "description",
			width = 1.3,
			order = i + 2.3,
		}
	end
end

local function Modules_CreateOptions(args)
	local numModules = #db.modulesOrder
	local numSkipped = 0
	for i, moduleName in ipairs(db.modulesOrder) do
		local module = _G[moduleName]
		if module.Header then
			local text = module.headerText
			if module == KT_ScenarioObjectiveTracker then
				text = text.." *"
			elseif module == KT_UIWidgetObjectiveTracker then
				text = "[ "..ZONE.." ]"
			end

			local defaultModule = (numSkipped == 0) and _G[KT.MODULES[i]] or _G[KT.MODULES[i - numSkipped]]
			local defaultText = defaultModule.headerText
			if defaultModule == KT_ScenarioObjectiveTracker then
				defaultText = defaultText.." *"
			elseif defaultModule == KT_UIWidgetObjectiveTracker then
				defaultText = "[ "..ZONE.." ]"
			end

			args["pos"..i] = {
				name = " "..text,
				type = "description",
				width = "normal",
				fontSize = "medium",
				order = i,
			}
			args["pos"..i.."up"] = {
				name = (i > 1) and "Up" or " ",
				desc = text,
				type = (i > 1) and "execute" or "description",
				width = "half",
				func = function()
					MoveModule(i, "up")
				end,
				order = i + 0.1,
			}
			args["pos"..i.."down"] = {
				name = (i < numModules) and "Down" or " ",
				desc = text,
				type = (i < numModules) and "execute" or "description",
				width = "half",
				func = function()
					MoveModule(i)
				end,
				order = i + 0.2,
			}
			args["pos"..i.."default"] = {
				name = "|T:1:24|t|cff808080"..defaultText,
				type = "description",
				width = "normal",
				fontSize = "medium",
				order = i + 0.3,
			}
		else
			numSkipped = numSkipped + 1
		end
	end
end

function MoveModule(idx, direction)
	local opt = modules.args.sec1.args
	local text = strsub(opt["pos"..idx].name, 2)
	local tmpIdx = (direction == "up") and idx-1 or idx+1
	local tmpText = strsub(opt["pos"..tmpIdx].name, 2)
	opt["pos"..tmpIdx].name = " "..text
	opt["pos"..tmpIdx.."up"].desc = text
	opt["pos"..tmpIdx.."down"].desc = text
	opt["pos"..idx].name = " "..tmpText
	opt["pos"..idx.."up"].desc = tmpText
	opt["pos"..idx.."down"].desc = tmpText

	local moduleName = tremove(db.modulesOrder, idx)
	tinsert(db.modulesOrder, tmpIdx, moduleName)

	OTF.modules[tmpIdx].uiOrder = idx
	OTF.modules[idx].uiOrder = tmpIdx
	OTF.needsSorting = true
	OTF:Update()
end

function SetSharedColor(color)
	local name = "Use border |cff"..KT.RgbToHex(color).."color|r"
	local opt = general.args.sec4.args
	opt.hdrBgrColorShare.name = name
	opt.hdrTxtColorShare.name = name
	opt.hdrBtnColorShare.name = name
end

function IsSpecialLocale()
	return (KT.LOCALE == "deDE" or
			KT.LOCALE == "esES" or
			KT.LOCALE == "frFR" or
			KT.LOCALE == "ruRU")
end

local function Setup()
	KT.options = options

	local opt = general.args.sec2.args
	opt.classBorder.name = opt.classBorder.name:format(KT.RgbToHex(KT.classColor))

	Visibility_CreateContextOptions(controls.args.sec3.args)

	opt = general.args.sec7.args
	opt.messageOutput = KT:GetSinkAce3OptionsDataTable()
	opt.messageOutput.inline = true
	opt.messageOutput.disabled = function() return not (db.messageQuest or db.messageAchievement) end
	KT:SetSinkStorage(db)

	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(KT.db)
	profiles.confirm = true
	profiles.args.current.width = "double"
	profiles.args.reset.confirmText = "Reset Profile - "..cBold2..KT.db:GetCurrentProfile().."|r|n|n"..warning
	profiles.args.new.confirmText = warning
	profiles.args.choose.confirmText = warning
	profiles.args.copyfrom.confirmText = warning
	if not profiles.plugins then
		profiles.plugins = {}
	end
	profiles.plugins[addonName] = {
		clearTrackerDataDesc1 = {
			name = "Clear the data (no settings) of the tracked content (Quests, Achievements etc.) for current character.",
			type = "description",
			order = 0.1,
		},
		clearTrackerData = {
			name = "Clear Tracker Data",
			desc = "Clear the data of the tracked content.",
			type = "execute",
			confirmText = "Clear Tracker Data - "..cBold..KT.playerName.."|r|n|n"..warning,
			func = function()
				dbChar.quests.cache = {}
				for i = 1, #dbChar.filterAuto do
					dbChar.filterAuto[i] = nil
				end
				KT.QuestsCache_Update(true)
				KT.AchievementsCache_Reset()
				ReloadUI()
			end,
			order = 0.2,
		},
		clearTrackerDataDesc2 = {
			name = "Current Character: "..cBold..KT.playerName,
			type = "description",
			width = "double",
			order = 0.3,
		},
		clearTrackerDataDesc4 = {
			name = " ",
			type = "description",
			order = 0.4,
		}
	}
	options.args.profiles = profiles

	ACR:RegisterOptionsTable(addonName, options, true)

	local parentID
	KT.optionsFrame = {}
	KT.optionsFrame.general, parentID = ACD:AddToBlizOptions(addonName, KT.TITLE, nil, "general")
	KT.optionsFrame.controls = ACD:AddToBlizOptions(addonName, controls.name, parentID, "controls")
	KT.optionsFrame.modules = ACD:AddToBlizOptions(addonName, modules.name, parentID, "modules")
	KT.optionsFrame.addons = ACD:AddToBlizOptions(addonName, addons.name, parentID, "addons")
	KT.optionsFrame.hacks = ACD:AddToBlizOptions(addonName, hacks.name, parentID, "hacks")
	KT.optionsFrame.profiles = ACD:AddToBlizOptions(addonName, profiles.name, parentID, "profiles")

	KT.db.RegisterCallback(KT, "OnProfileChanged", "InitProfile")
	KT.db.RegisterCallback(KT, "OnProfileCopied", "InitProfile")
	KT.db.RegisterCallback(KT, "OnProfileReset", "InitProfile")

	-- Disable some options
	if not IsSpecialLocale() then
		db.objNumSwitch = false
	end
end

local function SetHooks()
	hooksecurefunc(UIParent, "SetScale", function(self)
		Mover_SetScale()
	end)

	SettingsPanel:HookScript("OnShow", function()
		KT:RegSignal("VISIBILITY_CONTEXT", Visibility_ShowActiveContext, M)
		KT:SendSignal("OPTIONS_OPENED")
	end)

	SettingsPanel:HookScript("OnHide", function()
		KT:UnregSignal("VISIBILITY_CONTEXT", M)
	end)
end

local function SetAlert(type)
	if not type then return end

	if type == "trackedQuests" then
		local trackedQuests = GetCVar("trackedQuests")
		if trackedQuests ~= "" and trackedQuests ~= "v11" then
			local character = UnitName("player")
			local realm = GetRealmName()
			general.args.alert = {
				name = "Alert - Automatically tracked quests",
				type = "group",
				inline = true,
				order = 0.1,
				args = {
					alertIcon = {
						name = KT.GetUiIcon("Alert", "markup"),
						type = "description",
						width = 0.2,
						order = 1.1,
					},
					alertText = {
						name = "You are probably having problem with automatically tracked quests after every Login or Reload UI. Try the following steps to fix it.",
						type = "description",
						width = 2.8,
						fontSize = "medium",
						order = 1.2,
					},
					alertSpacer = {
						name = " ",
						type = "description",
						width = 0.2,
						order = 2.1,
					},
					alertText2 = {
						name = "- Go to the directory:  ...\\World of Warcraft\\_retail_\\WTF\\Account\\...ACCOUNT...\\"..realm.."\\"..character.."\n"..
								"- Open the file:  "..cBold.."config-cache.wtf|r\n"..
								"- Search for the string:  "..cBold.."SET trackedQuests \""..trackedQuests.."\"|r\n"..
								"- Change it to:  "..cBold.."SET trackedQuests \"v11\"|r\n"..
								"- Restart WoW",
						type = "description",
						width = 2.8,
						order = 2.2,
					},
				},
			}
		end
	end
end

local function SetupModules()
	Modules_CreateOptions(modules.args.sec1.args)
end

local function ActivateBinding()
	for cmd, data in pairs(KT.KEYBINDINGS) do
		if data and db[cmd] ~= "" then
			SetOverrideBindingClick(KTF, false, db[cmd], data.frameName, data.mouse)
		end
	end
end

function Keybind(key, command)
	local needSave = false
	for cmd, data in pairs(KT.KEYBINDINGS) do
		if data then
			if db[cmd] == key then
				SetOverrideBinding(KTF, false, db[cmd], nil)
				db[cmd] = ""
			end
		else
			local k1, k2 = GetBindingKey(cmd)
			if k1 == key then SetBinding(k1); needSave = true end
			if k2 == key then SetBinding(k2); needSave = true end
		end
	end

	local data = KT.KEYBINDINGS[command]
	if data then
		SetOverrideBinding(KTF, false, db[command], nil)
		if key ~= "" then
			SetOverrideBindingClick(KTF, false, key, data.frameName, data.mouse)
		end
		db[command] = key
	else
		local k1 = GetBindingKey(command)
		if k1 then
			SetBinding(k1)
		end
		if key ~= "" then
			SetBinding(key, command)
		end
		needSave = true
	end

	if needSave then
		SaveBindings(GetCurrentBindingSet())
	end
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	defaults = KT.db.defaults
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = true

    db.questAutoFocusClosest = false
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	Setup()
	SetHooks()

	KT:RegSignal("INIT", ActivateBinding, self)
	KT:RegEvent("PLAYER_ENTERING_WORLD", function(eventID)
		SetAlert("trackedQuests")
		SetupModules()
		Mover_SetScale()
		KT:RegEvent("UI_SCALE_CHANGED", function()
			Mover_SetScale()
		end, self)
		KT:UnregEvent(eventID)
	end, self)
end