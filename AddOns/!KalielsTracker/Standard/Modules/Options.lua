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
local WidgetLists = AceGUIWidgetLSMlists
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local abs = math.abs
local floor = math.floor
local format = string.format
local ipairs = ipairs
local pairs = pairs
local round = function(n) return floor(n + 0.5) end
local strsub = string.sub

local db, dbChar
local defaults
local anchors = { ["TOPLEFT"] = "左上", ["TOPRIGHT"] = "右上", ["BOTTOMLEFT"] = "左下", ["BOTTOMRIGHT"] = "右下" }
local strata = { "BACKGROUND", "LOW", "MEDIUM", "HIGH" }
local flags = { [""] = "無", ["OUTLINE"] = "外框", ["OUTLINE, MONOCHROME"] = "無消除鋸齒外框" }
local textures = { "None", "預設 (暴雪)", "單線", "雙線" }
local modifiers = { [""] = "無", ["ALT"] = "Alt", ["CTRL"] = "Ctrl", ["ALT-CTRL"] = "Alt + Ctrl" }
local SOUND_CHANNELS = { "Master", "Music", "SFX", "Ambience" }
local SOUND_CHANNELS_LOCALIZED = { Master = "Master", Music = MUSIC_VOLUME, SFX = FX_VOLUME, Ambience = AMBIENCE_VOLUME }
local VISIBILITY_OPTIONS = { "show", "hide", "expand", "collapse" }
local VISIBILITY_OPTIONS_LOCALIZED = { show = "Show", hide = "Hide", expand = "顯示 + 展開", collapse = "顯示 + 收合" }
local realmZones = { ["EU"] = "歐洲", ["NA"] = "北美" }
local ICON_HEART = "|T"..KT.MEDIA_PATH.."Help\\help_patreon:14:14:0:0:256:32:174:190:0:16|t"

local questsEnabled
local achievementsEnabled
local hasOptions = {}

local cTitle = " "..NORMAL_FONT_COLOR_CODE
local cBold = "|cff00ffe3"
local cBold2 = "|cffffd200"
local cWarning = "|cffff7f00"

local KTF = KT.frame

local KTSetHeight = KTF.SetHeight

local Module_Move, SetSharedColor  -- functions

-- Edit Mode - Mover
local moverOptions
local trackerOptions
local mover = KT:Mover_Create(addonName, KTF, "tracker")
mover.editAnchors = true

local function Mover_UpdateOptions()
	local opt = trackerOptions.args
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

local function Mover_UpdateOptionsUI()
	Mover_UpdateOptions()
	KT.EditMode:NotifyChange()
end

local function Mover_SetScale()
	if db.pixelPerfectScale then
		db.frameScale = KT.GetPixelPerfectScale(KTF)
		KT:Tracker_SetScale(db.frameScale)
	end
	Mover_UpdateOptions()
	KT:Tracker_Move()
	KT:Tracker_Update()
	mover:Update()
end

function mover:Anchor_OnEnter(frame)
	local anchor = frame.value
	local leftText = "- 追蹤清單展開方向:\n- 浮動提示資訊位置:\n- 任務物品按鈕位置:"
	local rightText = ""

	if anchor == "TOPLEFT" then
		rightText = "向下\n右側\n右側"
	elseif anchor == "TOPRIGHT" then
		rightText = "向下\n左側\n左側"
	elseif anchor == "BOTTOMLEFT" then
		rightText = "向上\n右側\n右側"
	elseif anchor == "BOTTOMRIGHT" then
		rightText = "向上\n左側\n左側"
	end

	GameTooltip:AddDoubleLine(leftText, rightText, 1, 1, 1, 0, 1, 0.89)
	GameTooltip:Show()
end

function mover:Anchor_OnClick(frame)
	db.anchorPoint = frame.value
	db.xOffset, db.yOffset = self:GetPosition(db.anchorPoint, db.frameScale)

	Mover_UpdateOptionsUI()
	KT:Tracker_Move()
	KTF.height = 0  -- force update
	KT:Tracker_Update()
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
	db.xOffset, db.yOffset = self:GetPosition(db.anchorPoint, db.frameScale)

	Mover_UpdateOptionsUI()
	KT:Tracker_Move()
	KT:Tracker_SetSize(true)
end

function mover:OnMouseUp(frame, button)
	if button == "RightButton" then
		db.anchorPoint = defaults.profile.anchorPoint
		db.xOffset = defaults.profile.xOffset
		db.yOffset = defaults.profile.yOffset
		db.maxHeight = defaults.profile.maxHeight

		Mover_UpdateOptionsUI()
		KT:Tracker_Move()
		KTF.height = 0  -- force update
		KT:Tracker_Update()
	end
end

function mover:OnScaleChanged()
	Mover_SetScale()
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
trackerOptions = {
	name = "追蹤清單",
	type = "group",
	order = 1,
	args = {
		xOffset = {
			name = "水平位置",
			desc = function()
				return "水平位置\n- 預設值: "..defaults.profile.xOffset.."\n- 每次: 1"
			end,
			type = "range",
			min = 0,
			max = 0,
			step = 1,
			set = function(_, value)
				db.xOffset = value
				KT:Tracker_Move()
				mover:Update()
			end,
			order = 1,
		},
		yOffset = {
			name = "垂直位移",
			desc = function()
				return "垂直位置\n- 預設值: "..defaults.profile.yOffset.."\n- 每次: 1"
			end,
			type = "range",
			min = 0,
			max = 0,
			step = 1,
			set = function(_, value)
				db.yOffset = value
				Mover_UpdateOptions()
				KT:Tracker_Move()
				KT:Tracker_SetSize(true)
				mover:Update()
			end,
			order = 2,
		},
		width = {
			name = "寬度",
			desc = function()
				return "- 預設值: "..defaults.profile.width.."\n- 每次: 1"
			end,
			type = "range",
			min = function() return defaults.profile.width end,
			max = function() return defaults.profile.width end,
			step = 1,
			disabled = true,
			set = function(_, value)
				db.width = value
				KT:Tracker_SetSize()
				mover:Update()
			end,
			order = 3,
		},
		maxHeight = {
			name = "最大高度",
			desc = function()
				return "- 預設值: "..defaults.profile.maxHeight.."\n- 每次: 1"
			end,
			type = "range",
			min = 130,
			max = 130,
			step = 1,
			set = function(_, value)
				db.maxHeight = value
				KT:Tracker_SetSize(true)
				mover:Update()
			end,
			order = 4,
		},
		notes = {
			name = cBold.." 寬度|r目前無法使用，因為尚未實裝。\n\n"..
					cBold.." 最大高度|r和清單的垂直位移 (上/下) 有關。\n"..
					" - 內容較少 ... 清單高度會自動增加。\n"..
					" - 內容較多 ... 清單會啟用捲動功能。",
			type = "description",
			order = 5,
		},
		frameScale = {
			name = "縮放大小",
			desc = function()
				return "- 預設值: "..defaults.profile.frameScale.."\n- 每次: 0.001"
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
				KT:Tracker_SetScale(db.frameScale)
				Mover_UpdateOptions()
				KT:Tracker_Move()
				KTF.height = 0  -- force update
				KT:Tracker_Update()
				mover:Update()
			end,
			order = 6,
		},
		pixelPerfectScale = {
			name = "像素精確縮放",
			desc = "內容使用像素精確縮放，相對於整體介面縮放。",
			type = "toggle",
			set = function()
				db.pixelPerfectScale = not db.pixelPerfectScale
				Mover_SetScale()
			end,
			order = 7,
		},
		frameStrata = {
			name = "框架層級",
			desc = function()
				return "- 預設值: "..defaults.profile.frameStrata
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
				KT:Tracker_SetFrameStrata(db.frameStrata)
			end,
			order = 8,
		},
	},
}

moverOptions = {
	name = "|T"..KT.MEDIA_PATH.."KT_logo:22:22:0:0|t"..KT.TITLE.."|cffffffff - 編輯模式",
	type = "group",
	get = function(info) return db[info[#info]] end,
	args = {
		editMode = {
			name = "編輯模式",
			type = "group",
			childGroups = "tab",
			args = {
				intro = {
					name = "\n"..KT.GetUiIcon("MouseLeft", "markup")..cBold.."左鍵|r 點擊方塊來拖曳移動追蹤清單。\n"..
							KT.GetUiIcon("MouseRight", "markup")..cBold.."Right Click|r on mover to restore the default position and size.",
					type = "description",
					justifyH = "CENTER",
					order = 0,
				},
			},
		},
	},
}

KT.EditMode = KT:EditMode_Create(addonName, moverOptions, "editMode", 465, 465)
KT.EditMode:RegisterOptions("tracker", trackerOptions)
KT.EditMode.OnOpen = function()
    KT:Tracker_SetHidden(false)
end

-- Options
local options = {
	name = "|T"..KT.MEDIA_PATH.."KT_logo:22:22:-1:7|t任務追蹤清單增強"..KT.TITLE,
	type = "group",
	get = function(info) return db[info[#info]] end,
	args = {
		general = {
			name = "選項",
			type = "group",
			args = {
				sec0 = {
					name = "資訊",
					type = "group",
					inline = true,
					order = 0,
					args = {
						version = {
							name = " |cffffd100版本:|r  "..KT.VERSION,
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 1.1,
						},
						build = {
							name = " |cffffd100Build:|r  "..KT.FLAVOR.name,
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
							name = "更新資訊",
							type = "execute",
							disabled = function()
								return not KT:Addon_IsModule(KT.Help)
							end,
							func = function()
								KT.Help:ShowHelp(true)
							end,
							order = 2,
						},
						help = {
							name = "使用說明",
							type = "execute",
							disabled = function()
								return not KT:Addon_IsModule(KT.Help)
							end,
							func = function()
								KT.Help:ShowHelp()
							end,
							order = 4,
						},
						supportersLabel = {
							name = "|cff00ff00成為贊助者",
							type = "description",
							width = "double",
							fontSize = "medium",
							justifyH = "RIGHT",
							order = 5.1,
						},
						supporters = {
							name = "支持贊助",
							type = "execute",
							disabled = function()
								return not KT:Addon_IsModule(KT.Help)
							end,
							func = function()
								KT.Help:ShowSupporters()
							end,
							order = 5.2,
						},
					},
				},
				sec1 = {
					name = "位置/大小",
					type = "group",
					inline = true,
					order = 1,
					args = {
						editMode = {
							name = "編輯模式",
							desc = "解鎖插件介面元素。",
							type = "execute",
							func = function()
                                KT.EditMode:Open()
                            end,
							order = 1,
						},
						editModeNote = {
							name = cBold.." 設定插件介面元素的位置、大小、縮放和框架層級。",
							type = "description",
							width = "double",
							order = 2,
						},
						frameScrollbar = {
							name = "顯示捲軸",
							desc = "啟用捲動功能時顯示捲軸，使用與邊框相同顏色。",
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
					name = "背景/邊框",
					type = "group",
					inline = true,
					order = 2,
					args = {
						bgr = {
							name = "背景材質",
							type = "select",
							dialogControl = "LSM30_Background",
							values = WidgetLists.background,
							set = function(_, value)
								db.bgr = value
								KT:Tracker_SetBackground()
							end,
							order = 1,
						},
						bgrColor = {
							name = "背景顏色",
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
								KT:Tracker_SetBackground()
							end,
							order = 2,
						},
						bgrNote = {
							name = cBold.." 使用自訂背景時\n 材質設為白色。",
							type = "description",
							width = "normal",
							order = 2.1,
						},
						border = {
							name = "邊框材質",
							type = "select",
							dialogControl = "LSM30_Border",
							values = WidgetLists.border,
							set = function(_, value)
								db.border = value
								KT:Tracker_SetBackground()
								KT.QuestButtons_Move()
							end,
							order = 3,
						},
						borderColor = {
							name = "邊框顏色",
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
								KT:Tracker_SetBackground()
								KT:Tracker_SetText()
								SetSharedColor(db.borderColor)
							end,
							order = 4,
						},
						classBorder = {
							name = "邊框使用 |cff%s職業顏色|r",
							type = "toggle",
							get = function(info)
								if db[info[#info]] then
									SetSharedColor(KT.classColor)
								end
								return db[info[#info]]
							end,
							set = function()
								db.classBorder = not db.classBorder
								KT:Tracker_SetBackground()
								KT:Tracker_SetText()
							end,
							order = 5,
						},
						borderAlpha = {
							name = "邊框透明度",
							desc = function()
								return "- 預設值: "..defaults.profile.borderAlpha.."\n- 每次: 0.05"
							end,
							type = "range",
							min = 0.1,
							max = 1,
							step = 0.05,
							set = function(_, value)
								db.borderAlpha = value
								KT:Tracker_SetBackground()
							end,
							order = 6,
						},
						borderThickness = {
							name = "邊框粗細",
							desc = function()
								return "- 預設值: "..defaults.profile.borderThickness.."\n- 每次: 0.5"
							end,
							type = "range",
							min = 1,
							max = 24,
							step = 0.5,
							set = function(_, value)
								db.borderThickness = value
								KT:Tracker_SetBackground()
							end,
							order = 7,
						},
						bgrInset = {
							name = "背景內縮",
							desc = function()
								return "- 預設值: "..defaults.profile.bgrInset.."\n- 每次: 0.5"
							end,
							type = "range",
							min = 0,
							max = 10,
							step = 0.5,
							set = function(_, value)
								db.bgrInset = value
								KT:Tracker_SetBackground()
								KT.QuestButtons_Move()
							end,
							order = 8,
						},
						progressBar = {
							name = "進度條材質",
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
					name = "文字",
					type = "group",
					inline = true,
					order = 3,
					args = {
						font = {
							name = "字體",
							type = "select",
							dialogControl = "LSM30_Font",
							values = WidgetLists.font,
							set = function(_, value)
								db.font = value
								KT:Tracker_SetText(true)
								KT:SendSignal("OPTIONS_CHANGED")
							end,
							order = 1,
						},
						fontSize = {
							name = "文字大小",
							type = "range",
							min = 10,
							max = 20,
							step = 1,
							set = function(_, value)
								db.fontSize = value
								KT:Tracker_SetText(true)
								KT:SendSignal("OPTIONS_CHANGED")
							end,
							order = 2,
						},
						fontFlag = {
							name = "文字樣式",
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
								KT:Tracker_SetText(true)
								KT:SendSignal("OPTIONS_CHANGED")
							end,
							order = 3,
						},
						fontShadow = {
							name = "文字陰影",
							desc = KT.TEXT.OPTION_WARNING,
							type = "toggle",
							confirm = true,
							confirmText = KT.TEXT.OPTION_WARNING,
							get = function()
								return (db.fontShadow == 1)
							end,
							set = function(_, value)
								db.fontShadow = value and 1 or 0
								ReloadUI()	-- WTF
							end,
							order = 4,
						},
						textWordWrap = {
							name = "文字自動換行",
							desc = "單行或兩行過長的文字使用 ... 來省略。 ",
							type = "toggle",
							set = function()
								db.textWordWrap = not db.textWordWrap
								KT:Tracker_Update(true)
							end,
							order = 5,
						},
					},
				},
				sec4 = {
					name = "標題列",
					type = "group",
					inline = true,
					order = 4,
					args = {
						hdrBgrLabel = {
							name = " 材質",
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
								KT:Tracker_SetBackground()
							end,
							order = 1.1,
						},
						hdrBgrColor = {
							name = "顏色",
							desc = "設定標題列材質的顏色。",
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
								KT:Tracker_SetBackground()
							end,
							order = 1.2,
						},
						hdrBgrColorShare = {
							name = "使用邊框顏色",
							desc = "材質使用與邊框相同的顏色。",
							type = "toggle",
							disabled = function()
								return (db.hdrBgr == 1)
							end,
							set = function()
								db.hdrBgrColorShare = not db.hdrBgrColorShare
								KT:Tracker_SetBackground()
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
							name = "顯示標題列材質",
							type = "toggle",
							width = "normal+half",
							disabled = function()
								return (db.hdrBgr == 1)
							end,
							set = function()
								db.hdrTrackerBgrShow = not db.hdrTrackerBgrShow
								KT:Tracker_SetBackground()
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
							name = " 文字",
							type = "description",
							width = "half",
							fontSize = "medium",
							order = 2,
						},
						hdrTxtColor = {
							name = "顏色",
							desc = "設定標題列文字的顏色。",
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
								KT:Tracker_SetText()
							end,
							order = 2.1,
						},
						hdrTxtColorShare = {
							name = "使用邊框顏色",
							desc = "標題列文字使用與邊框相同的顏色。",
							type = "toggle",
							set = function()
								db.hdrTxtColorShare = not db.hdrTxtColorShare
								KT:Tracker_SetText()
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
							name = " 按鈕",
							type = "description",
							width = "half",
							fontSize = "medium",
							order = 3,
						},
						hdrBtnColor = {
							name = "顏色",
							desc = "設定所有標題列按鈕的顏色。",
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
								KT:Tracker_SetBackground()
							end,
							order = 3.2,
						},
						hdrBtnColorShare = {
							name = "使用邊框顏色",
							desc = "所有標題列按鈕都使用與邊框相同的顏色。",
							type = "toggle",
							set = function()
								db.hdrBtnColorShare = not db.hdrBtnColorShare
								KT:Tracker_SetBackground()
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
							order = 4,
						},
						hdrCollapsedTxtLabel = {
							name = "      最小化時的摘要文字",
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 5,
						},
						hdrCollapsedTxt1 = {
							name = "無",
							desc = "最小化時縮短追蹤清單的寬度。",
							type = "toggle",
							width = "half",
							get = function()
								return (db.hdrCollapsedTxt == 1)
							end,
							set = function()
								db.hdrCollapsedTxt = 1
								KT:Tracker_Update()
							end,
							order = 5.1,
						},
						hdrCollapsedTxt2 = {
							name = "|T"..KT.MEDIA_PATH.."KT_logo:22:22:2:0|t 所有目標"..KT.TITLE,
							type = "toggle",
							width = "normal",
							get = function()
								return (db.hdrCollapsedTxt == 2)
							end,
							set = function()
								db.hdrCollapsedTxt = 2
								KT:Tracker_Update()
							end,
							order = 5.2,
						},
						sec4SpacerMid3 = {
							name = " ",
							type = "description",
							order = 6,
						},
						hdrOtherButtons = {
							name = "顯示任務日誌和成就按鈕",
							type = "toggle",
							width = "double",
							set = function()
								db.hdrOtherButtons = not db.hdrOtherButtons
								KT:SetOtherButtons()
								KT:Tracker_SetBackground()
                                KT:SendSignal("OPTIONS_CHANGED")
							end,
							order = 7,
						},
					},
				},
				sec5 = {
					name = "任務物品按鈕",
					type = "group",
					inline = true,
					order = 5,
					args = {
						qiBgrBorder = {
							name = "顯示按鈕區塊的背景和邊框",
							type = "toggle",
							width = "double",
							set = function()
								db.qiBgrBorder = not db.qiBgrBorder
								KT:Tracker_SetBackground()
								KT.QuestButtons_Move()
							end,
							order = 1,
						},
						qiXOffset = {
							name = "水平位置",
							type = "range",
							min = -10,
							max = 10,
							step = 1,
							set = function(_, value)
								db.qiXOffset = value
								KT.QuestButtons_Move()
							end,
							order = 2,
						},
						addonMasqueLabel = {
							name = " Skin options for Quest item buttons",
							type = "description",
							width = "double",
							fontSize = "medium",
							disabled = function()
								return not (KT:Addon_IsModule(KT.AddonMasque) and KT.AddonMasque:IsActive())
							end,
							order = 3.1,
						},
						addonMasqueOptions = {
							name = "按鈕外觀 Masque",
							type = "execute",
							disabled = function()
								return not (KT:Addon_IsModule(KT.AddonMasque) and KT.AddonMasque:IsActive())
							end,
							func = function()
								SlashCmdList["MASQUE"]()
							end,
							order = 3.2,
						},
					},
				},
				sec6 = {
					name = "通知訊息",
					type = "group",
					inline = true,
					hidden = function()
						return not (questsEnabled or achievementsEnabled)
					end,
					order = 6,
					args = {
						messageQuest = {
							name = "任務訊息",
							type = "toggle",
							hidden = function()
								return not questsEnabled
							end,
							set = function()
								db.messageQuest = not db.messageQuest
							end,
							order = 1,
						},
						messageAchievement = {
							name = "成就訊息",
							width = 1.1,
							type = "toggle",
							hidden = function()
								return not achievementsEnabled
							end,
							set = function()
								db.messageAchievement = not db.messageAchievement
							end,
							order = 2,
						},
						-- LibSink options
					},
				},
				sec7 = {
					name = "通知音效",
					type = "group",
					inline = true,
					hidden = function()
						return not questsEnabled
					end,
					order = 7,
					args = {
						soundChannelLabel = {
							name = " 音效頻道",
							type = "description",
							width = 1,
							fontSize = "medium",
							disabled = function()
								return not (questsEnabled and db.soundQuest)
							end,
							order = 1,
						},
						soundChannel = {
							name = "",
							type = "select",
							width = 1.05,
							disabled = function()
								return not (questsEnabled and db.soundQuest)
							end,
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
							name = "任務音效",
							type = "toggle",
							hidden = function()
								return not questsEnabled
							end,
							set = function()
								db.soundQuest = not db.soundQuest
							end,
							order = 2,
						},
						soundQuestComplete = {
							name = "完成音效",
							desc = "插件音效的開頭為 \"KT - \"。",
							type = "select",
							width = 1.05,
							hidden = function()
								return not questsEnabled
							end,
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
			name = "控制",
			type = "group",
			args = {
				sec1 = {
					name = "指令",
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
							name = "展開 / 收合追蹤清單",
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
							name = "顯示 / 隱藏追蹤清單",
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
							name = "打開插件設定選項",
							type = "description",
							width = 2.3,
							order = 3.24,
						},
					},
				},
				keybindings = {
					name = "按鍵綁定",
					type = "group",
					inline = true,
					order = 2,
					args = {
						keyBindCollapseLabel = {
							name = " 展開 / 收合追蹤清單",
							type = "description",
							width = 2,
							fontSize = "medium",
							order = 1.1,
						},
						keyBindCollapse = {
							name = "",
							type = "keybinding",
							set = function(_, value)
								KT.Keybind(value, "keyBindCollapse")
							end,
							order = 1.2,
						},
						keyBindHideLabel = {
							name = " 顯示 / 隱藏追蹤清單",
							type = "description",
							width = 2,
							fontSize = "medium",
							order = 2.1,
						},
						keyBindHide = {
							name = "",
							type = "keybinding",
							set = function(_, value)
								KT.Keybind(value, "keyBindHide")
							end,
							order = 2.2,
						},
						keyBindClosestQuestLabel = {
							name = " 將最近的任務設為專注",
							type = "description",
							width = 2,
							fontSize = "medium",
							order = 3.1,
						},
						keyBindClosestQuest = {
							name = "",
							type = "keybinding",
							set = function(_, value)
								KT.Keybind(value, "keyBindClosestQuest")
							end,
							order = 3.2,
						},
						-- keybinding options
					},
				},
				sec3 = {
					name = "顯示規則",
					type = "group",
					inline = true,
					order = 3,
					args = {
						visibilityDesc = {
							name = " 規則只會在符合條件時套用一次。\n"..
									" 被隱藏或收合的追蹤清單可以隨時手動顯示或展開。",
							type = "description",
							order = 0,
						},
						activeContextLabel = {
							name = "\n 現用規則 ...\n ",
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
							name = " 追蹤清單",
							type = "description",
							width = 0.7,
							fontSize = "medium",
							order = 2.1,
						},
						hideEmptyTracker = {
							name = "隱藏空的追蹤清單",
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
						-- rules options
						contextsNote = {
							name = "\n * 普通 / 英雄 / 傳奇 / 事件 / 探究",
							type = "description",
							order = 30,
						},
					},
				},
			},
		},
		modules = {
			name = "模組",
			type = "group",
			childGroups = "tab",
			args = {
				sec1 = {
					name = "模組順序",
					type = "group",
					order = 1,
					args = {
						descCurOrder = {
							name = cTitle.."目前順序",
							type = "description",
							width = "double",
							fontSize = "medium",
							order = 0.1,
						},
						descDefOrder = {
							name = "|T:1:20|t"..cTitle.."預設順序",
							type = "description",
							width = "normal",
							fontSize = "medium",
							order = 0.2,
						},
					},
				},
				sec2 = {
					name = "一般",
					type = "group",
					order = 2,
					args = {
						tooltip = {
							name = "浮動提示資訊",
							type = "group",
							inline = true,
							order = 1,
							args = {
								tooltipShow = {
									name = "顯示浮動提示資訊",
									desc = "顯示任務 / 世界任務 / 成就 / 任務型地下城的浮動提示資訊。",
									type = "toggle",
									set = function()
										db.tooltipShow = not db.tooltipShow
									end,
									order = 1.1,
								},
								tooltipShowRewards = {
									name = "顯示獎勵",
									desc = "在浮動提示資訊中顯示任務獎勵－神器能量、教團資源、金錢、裝備等。",
									type = "toggle",
									disabled = function()
										return not db.tooltipShow
									end,
									set = function()
										db.tooltipShowRewards = not db.tooltipShowRewards
									end,
									order = 1.2,
								},
								tooltipShowID = {
									name = "顯示 ID",
									desc = "在浮動提示資訊中顯示任務 / 世界任務 / 成就的 ID 編號。",
									type = "toggle",
									disabled = function()
										return not db.tooltipShow
									end,
									set = function()
										db.tooltipShowID = not db.tooltipShowID
									end,
									order = 1.3,
								},
							},
						},
						contextMenu = {
							name = "右鍵選單",
							type = "group",
							inline = true,
							order = 2,
							args = {
								menuWowheadURL = {
									name = "Wowhead 網址",
									desc = "在追蹤器與任務記錄中顯示 Wowhead 網址選單項目。",
									type = "toggle",
									set = function()
										db.menuWowheadURL = not db.menuWowheadURL
									end,
									order = 1.1,
								},
								menuWowheadURLModifierLabel = {
									name = "點擊輔助鍵",
									type = "description",
									width = 0.6,
									fontSize = "medium",
									justifyH = "RIGHT",
									order = 1.2,
								},
								menuWowheadURLModifier = {
									name = "",
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
									order = 1.3,
								},
								menuYouTubeURL = {
									name = "YouTube 搜尋網址",
									desc = "在追蹤器與任務記錄中顯示 YouTube 搜尋網址選單項目。",
									type = "toggle",
									set = function()
										db.menuYouTubeURL = not db.menuYouTubeURL
									end,
									order = 2.1,
								},
								menuYouTubeURLModifierLabel = {
									name = "點擊輔助鍵",
									type = "description",
									width = 0.6,
									fontSize = "medium",
									justifyH = "RIGHT",
									order = 2.2,
								},
								menuYouTubeURLModifier = {
									name = "",
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
									order = 2.3,
								},
							},
						},
						popups = {
							name = "彈出視窗",
							type = "group",
							inline = true,
							order = 3,
							args = {
								popupCloseOnCopy = {
									name = "複製後關閉彈出視窗",
									desc = "使用 Ctrl+C 之後。",
									type = "toggle",
									set = function()
										db.popupCloseOnCopy = not db.popupCloseOnCopy
									end,
									order = 1,
								},
							},
						},
					},
				},
			},
		},
		features = {
			name = "功能特色",
			type = "group",
			args = {
				-- feature options
			},
		},
		addons = {
			name = "支援插件",
			type = "group",
			childGroups = "tab",
			args = {
				general = {
					name = "一般",
					type = "group",
					order = 1,
					args = {
						desc = {
							name = " |cff00d200綠色|r - 相容版本 - 此版本已經過測試並提供支援。\n"..
									" |cffff0000紅色|r - 不相容版本 - 此版本未經測試，可能需要修改部分程式碼。\n"..
									" 請回報所有問題。",
							type = "description",
							order = 0,
						},
						addons = {
							name = "插件",
							type = "group",
							inline = true,
							order = 1,
							args = {
								-- addon options
							},
						},
						uis = {
							name = "使用者介面",
							type = "group",
							inline = true,
							order = 2,
							args = {
								-- UI addon options
							},
						},
					},
				},
				-- addon tab options
			},
		},
		hacks = {
			name = "遊戲修正",
			type = "group",
			args = {
				desc = {
					name = cWarning.."警告:|r 遊戲修正可能會影響其他插件\n\n請回報任何未提及的負面影響。",
					type = "description",
					order = 0,
				},
			},
		},
	},
}

local general = options.args.general
local controls = options.args.controls
local modules = options.args.modules
local features = options.args.features
local addons = options.args.addons
local hacks = options.args.hacks

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
				args.descModules = {
					name = KT.TEXT.OPTION_MODULE_SCENARIO_LEGEND,
					type = "description",
					order = 30,
				}
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
				name = (i > 1) and "上移" or "|T:25:1|t",
				desc = text,
				type = (i > 1) and "execute" or "description",
				width = "half",
				func = function()
					Module_Move(i, "up")
				end,
				order = i + 0.1,
			}
			args["pos"..i.."down"] = {
				name = (i < numModules) and "下移" or "|T:25:1|t",
				desc = text,
				type = (i < numModules) and "execute" or "description",
				width = "half",
				func = function()
					Module_Move(i)
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

function Module_Move(idx, direction)
	local opt = modules.args.sec1.args
	local text = strsub(opt["pos"..idx].name, 2)
	local tmpIdx = (direction == "up") and idx - 1 or idx + 1
	local tmpText = strsub(opt["pos"..tmpIdx].name, 2)
	opt["pos"..tmpIdx].name = " "..text
	opt["pos"..tmpIdx.."up"].desc = text
	opt["pos"..tmpIdx.."down"].desc = text
	opt["pos"..idx].name = " "..tmpText
	opt["pos"..idx.."up"].desc = tmpText
	opt["pos"..idx.."down"].desc = tmpText

	KT.Module_Move(idx, direction)
end

function SetSharedColor(color)
	local name = "使用邊框|cff"..KT.RgbToHex(color).."顏色|r"
	local opt = general.args.sec4.args
	opt.hdrBgrColorShare.name = name
	opt.hdrTxtColorShare.name = name
	opt.hdrBtnColorShare.name = name
end

local function Alert_TrackedQuests()
	if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE and WOW_PROJECT_ID ~= WOW_PROJECT_CAMELOT then return end

	local trackedQuests = GetCVar("trackedQuests")
	local trackedQuestsVersion = trackedQuests:match("^(v%d+)")
	if not trackedQuestsVersion or trackedQuests == trackedQuestsVersion then return end

	local game = "_retail_"
	if WOW_PROJECT_ID == WOW_PROJECT_CAMELOT then
		game = "_forever_"
	end
	local character = UnitName("player")
	local realm = GetRealmName()
	general.args.alert = {
		name = "警告 - 自動追蹤任務問題",
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
				name = "插件偵測到潛在問題：每次登入或重新載入介面後，任務可能會自動加入追蹤。請嘗試以下步驟修復。",
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
				name = "1. Go to the directory:  World of Warcraft\\"..game.."\\WTF\\Account\\...ID...\\"..realm.."\\"..character.."\n"..
						"2. Open the file:  "..cBold.."config-cache.wtf|r\n"..
						"3. Find the line:  "..cBold.."SET trackedQuests \""..trackedQuests.."\"|r\n"..
						"4. Change it to:  "..cBold.."SET trackedQuests \""..trackedQuestsVersion.."\"|r\n"..
						"5. Restart WoW",
				type = "description",
				width = 2.8,
				order = 2.2,
			},
		},
	}
end

local function Setup()
	local opt

	-- General
	Alert_TrackedQuests()

	-- General > Background / Border
	opt = general.args.sec2.args
	opt.classBorder.name = format(opt.classBorder.name, KT.RgbToHex(KT.classColor))

	-- General > Notification messages
	opt = general.args.sec6.args
	opt.messageOutput = KT:GetSinkAce3OptionsDataTable()
	opt.messageOutput.inline = true
	opt.messageOutput.disabled = function()
		return not ((questsEnabled and db.messageQuest) or
				(achievementsEnabled and db.messageAchievement))
	end
	KT:SetSinkStorage(db)

	-- Controls > Visibility rules
	Visibility_CreateContextOptions(controls.args.sec3.args)

	-- Supported Addons > General
	opt = addons.args.general.args
	opt.addons.hidden = function()
		return KT.IsTableEmpty(opt.addons.args)
	end
	opt.uis.hidden = function()
		return KT.IsTableEmpty(opt.uis.args)
	end

	-- Profiles
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(KT.db)
	profiles.confirm = true
	profiles.args.current.width = "double"
	profiles.args.reset.confirmText = "重置設定檔 - "..cBold2..KT.db:GetCurrentProfile().."|r|n|n"..KT.TEXT.OPTION_WARNING
	profiles.args.new.confirmText = KT.TEXT.OPTION_WARNING
	profiles.args.choose.confirmText = KT.TEXT.OPTION_WARNING
	profiles.args.copyfrom.confirmText = KT.TEXT.OPTION_WARNING
	if not profiles.plugins then
		profiles.plugins = {}
	end
	profiles.plugins[addonName] = {
		clearTrackerDataDesc1 = {
			name = "清空當前角色已追蹤的任容資料 (任務、成就等，不包含設定)。",
			type = "description",
			order = 0.1,
		},
		clearTrackerData = {
			name = "清空追蹤清單",
			desc = "清空已追蹤內容的資料。",
			type = "execute",
			confirmText = "清空追蹤清單 - "..cBold..KT.playerName.."|r|n|n"..KT.TEXT.OPTION_WARNING,
			func = function()
				for i = 1, #dbChar.filterAuto do
					dbChar.filterAuto[i] = nil
				end
				if KT.QuestsCache_Reset then
					KT.QuestsCache_Reset()
				end
				if KT.AchievementsCache_Reset then
					KT.AchievementsCache_Reset()
				end
				ReloadUI()
			end,
			order = 0.2,
		},
		clearTrackerDataDesc2 = {
			name = "當前角色: "..cBold..KT.playerName,
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
	KT.optionsFrame.general, parentID = ACD:AddToBlizOptions(addonName, "任務-清單", nil, "general")
	KT.optionsFrame.controls = ACD:AddToBlizOptions(addonName, controls.name, parentID, "controls")
	KT.optionsFrame.modules = ACD:AddToBlizOptions(addonName, modules.name, parentID, "modules")
	if hasOptions.features then
		KT.optionsFrame.features = ACD:AddToBlizOptions(addonName, features.name, parentID, "features")
	end
	if hasOptions.addons then
		KT.optionsFrame.addons = ACD:AddToBlizOptions(addonName, addons.name, parentID, "addons")
	end
	if KT:Addon_IsModule(KT.Hacks) then
		KT.optionsFrame.hacks = ACD:AddToBlizOptions(addonName, hacks.name, parentID, "hacks")
	end
	KT.optionsFrame.profiles = ACD:AddToBlizOptions(addonName, profiles.name, parentID, "profiles")

	KT.db.RegisterCallback(KT, "OnProfileChanged", "InitProfile")
	KT.db.RegisterCallback(KT, "OnProfileCopied", "InitProfile")
	KT.db.RegisterCallback(KT, "OnProfileReset", "InitProfile")
end

local function SetHooks()
	SettingsPanel:HookScript("OnShow", function()
		KT:RegSignal("VISIBILITY_CONTEXT", Visibility_ShowActiveContext, M)
		KT:SendSignal("OPTIONS_OPENED")
	end)

	SettingsPanel:HookScript("OnHide", function()
		KT:UnregSignal("VISIBILITY_CONTEXT", M)
	end)
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

function KT.Keybind(key, command)
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

function M.AddControlOption(section, opt)
	local target = controls.args[section]
	KT.MergeTables(opt, target.args)
end

function M.AddModuleTab(name, opt, parent)
	local tab = modules.args[name]
	if tab then
		KT.MergeTables(opt, tab.args)
	else
		modules.args[name] = parent or opt
	end
end

function M.AddFeatureSection(name, opt)
	features.args[name] = opt
	hasOptions.features = true
end

function M.AddAddonOption(section, opt)
	local target = addons.args.general.args[section]
	KT.MergeTables(opt, target.args)
	hasOptions.addons = true
end

function M.AddAddonTab(name, opt)
	addons.args[name] = opt
end

function M:Open()
	if not KT.InCombatBlocked() and KT.optionsFrame and not EditModeManagerFrame:IsEditModeActive() then
		Settings.OpenToCategory(KT.optionsFrame.general.name, KT.TITLE)
	end
end

function M:OnInitialize()
	_DBG("|cffffff00初始化|r - "..self:GetName(), true)
	defaults = KT.db.defaults
	db = KT.db.profile
	dbChar = KT.db.char
	self.isAvailable = true

	db.questsAutoFocusClosest = false
end

function M:OnEnable()
	_DBG("|cff00ff00啟用|r - "..self:GetName(), true)
	questsEnabled = KT:Addon_IsModule(KT.Quests)
	achievementsEnabled = KT:Addon_IsModule(KT.Achievements)

	Setup()
	SetHooks()

	KT:RegSignal("ADDON_ENABLED", SetupModules, self)
	KT:RegSignal("TRACKER_INITIALIZING", ActivateBinding, self)
end
