--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

---@class ActiveButton
local M = KT:NewModule("ActiveButton")
KT.ActiveButton = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local floor = math.floor
local round = function(n) return floor(n + 0.5) end

local db, dbChar
local activeFrameWidth = 256
local activeFrameHeight = 128
local strata = { "BACKGROUND", "LOW", "MEDIUM", "HIGH" }
local defaults

local KTF = KT.frame
local eventFrame
local activeFrame, abutton
local blizzardButtonIconID = 0

local buttons = KT.QuestButtons_GetButtons()

local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local Update  -- functions

-- Internal ------------------------------------------------------------------------------------------------------------

local function ActiveFrame_Move()
	local anchor = db.activeButton.anchor
	local xOffset = KT.round(db.activeButton.xOffset / db.activeButton.scale)
	local yOffset = KT.round(db.activeButton.yOffset / db.activeButton.scale)

	activeFrame:ClearAllPoints()
	activeFrame:SetPoint(anchor, UIParent, anchor, xOffset, yOffset)
end

local function ActiveFrame_SetFrameStrata(strata)
	activeFrame:SetFrameStrata(strata)
end

local function ActiveFrame_SetScale(scale)
	activeFrame:SetScale(scale)
end

-- Edit Mode
local function EditMode_SetupMover()
	if not KT.EditMode then return end

	local mover = KT:Mover_Create(addonName, KTF.ActiveFrame, "activeButton")
	mover.editAnchors = true
	mover.enabledAnchors = { "TOP", "TOPLEFT", "TOPRIGHT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT" }

	local activeButtonOptions

	local function Mover_UpdateOptions()
		local opt = activeButtonOptions.args
		local screenWidth = round(GetScreenWidth())
		local screenHeight = round(GetScreenHeight())
		local halfWidth = round(activeFrameWidth * db.activeButton.scale / 2)
		local halfHeight = round(activeFrameHeight * db.activeButton.scale / 2)
		local xOffsetMax = round(screenWidth - halfWidth)
		local xOffsetCenterMax = round(screenWidth / 2)
		local yOffsetMax = round(screenHeight - halfHeight)
		local anchorLeft = (db.activeButton.anchor == "TOPLEFT" or db.activeButton.anchor == "BOTTOMLEFT")
		local anchorCenter = (db.activeButton.anchor == "TOP" or db.activeButton.anchor == "BOTTOM")
		local anchorBottom = (db.activeButton.anchor == "BOTTOM" or db.activeButton.anchor == "BOTTOMLEFT" or db.activeButton.anchor == "BOTTOMRIGHT")

		if anchorCenter then
			opt.xOffset.min = xOffsetCenterMax * -1
			opt.xOffset.max = xOffsetCenterMax
		elseif anchorLeft then
			opt.xOffset.min = halfWidth * -1
			opt.xOffset.max = xOffsetMax
		else
			opt.xOffset.min = xOffsetMax * -1
			opt.xOffset.max = halfWidth
		end

		if anchorBottom then
			opt.yOffset.min = halfHeight * -1
			opt.yOffset.max = yOffsetMax
		else
			opt.yOffset.min = yOffsetMax * -1
			opt.yOffset.max = halfHeight
		end

		if db.activeButton.xOffset < opt.xOffset.min then
			db.activeButton.xOffset = opt.xOffset.min
		elseif db.activeButton.xOffset > opt.xOffset.max then
			db.activeButton.xOffset = opt.xOffset.max
		end

		if db.activeButton.yOffset < opt.yOffset.min then
			db.activeButton.yOffset = opt.yOffset.min
		elseif db.activeButton.yOffset > opt.yOffset.max then
			db.activeButton.yOffset = opt.yOffset.max
		end
	end

	local function Mover_UpdateOptionsUI()
		Mover_UpdateOptions()
		KT.EditMode:NotifyChange()
	end

	local function Mover_SetScale()
		if db.activeButton.pixelPerfectScale then
			db.activeButton.scale = KT.GetPixelPerfectScale(activeFrame)
			ActiveFrame_SetScale(db.activeButton.scale)
		end
		Mover_UpdateOptions()
		ActiveFrame_Move()
	end

	function mover:Show()
		self.mixin.Show(self)
		self.frame:Show()
	end

	function mover:Hide()
		self.mixin.Hide(self)
		Update()
	end

	function mover:Anchor_OnClick(frame)
		db.activeButton.anchor = frame.value
		db.activeButton.xOffset, db.activeButton.yOffset = self:GetPosition(db.activeButton.anchor, db.activeButton.scale)

		Mover_UpdateOptionsUI()
		ActiveFrame_Move()
	end

	function mover:OnDragStop(frame)
		db.activeButton.xOffset, db.activeButton.yOffset = self:GetPosition(db.activeButton.anchor, db.activeButton.scale)

		Mover_UpdateOptionsUI()
		ActiveFrame_Move()
	end

	function mover:OnMouseUp(frame, button)
		if button == "RightButton" then
			db.activeButton.anchor = defaults.profile.activeButton.anchor
			db.activeButton.xOffset = defaults.profile.activeButton.xOffset
			db.activeButton.yOffset = defaults.profile.activeButton.yOffset

			Mover_UpdateOptionsUI()
			ActiveFrame_Move()
		end
	end

	function mover:OnScaleChanged()
		Mover_SetScale()
	end

	function mover:Update()
		self.anchorPoint = db.activeButton.anchor
		self.mixin.Update(self)
	end

	defaults = KT.db.defaults
	activeButtonOptions = {
		name = "當前任務物品按鈕",
		type = "group",
		get = function(info)
			return db.activeButton[info[#info]]
		end,
		order = 2,
		args = {
			xOffset = {
				name = "水平位置",
				desc = function()
					return "水平位置\n- 預設值: "..defaults.profile.activeButton.xOffset.."\n- 每次: 1"
				end,
				type = "range",
				min = 0,
				max = 0,
				step = 1,
				set = function(_, value)
					db.activeButton.xOffset = value
					ActiveFrame_Move()
				end,
				order = 1,
			},
			yOffset = {
				name = "垂直位移",
				desc = function()
					return "垂直位置\n- 預設值: "..defaults.profile.activeButton.yOffset.."\n- 每次: 1"
				end,
				type = "range",
				min = 0,
				max = 0,
				step = 1,
				set = function(_, value)
					db.activeButton.yOffset = value
					ActiveFrame_Move()
				end,
				order = 2,
			},
			scale = {
				name = "縮放大小",
				desc = function()
					return "- 預設值: "..defaults.profile.activeButton.scale.."\n- 每次: 0.001"
				end,
				type = "range",
				min = 0.4,
				max = 1.7,
				step = 0.001,
				isRaw = true,
				disabled = function()
					return db.activeButton.pixelPerfectScale
				end,
				set = function(_, value)
					db.activeButton.scale = value
					ActiveFrame_SetScale(db.activeButton.scale)
					Mover_UpdateOptions()
					ActiveFrame_Move()
				end,
				order = 3,
			},
			pixelPerfectScale = {
				name = "像素精確縮放",
				desc = "內容使用像素精確縮放，相對於整體介面縮放。",
				type = "toggle",
				set = function()
					db.activeButton.pixelPerfectScale = not db.activeButton.pixelPerfectScale
					Mover_SetScale()
				end,
				order = 4,
			},
			strata = {
				name = "框架層級",
				desc = function()
					return "- 預設值: "..defaults.profile.activeButton.strata
				end,
				type = "select",
				values = strata,
				get = function()
					for k, v in ipairs(strata) do
						if db.activeButton.strata == v then
							return k
						end
					end
				end,
				set = function(_, value)
					db.activeButton.strata = strata[value]
					ActiveFrame_SetFrameStrata(db.activeButton.strata)
				end,
				order = 5,
			},
		},
	}
	KT.EditMode:RegisterOptions("activeButton", activeButtonOptions)
end

-- Options
local function SetupOptions()
	if not KT:Addon_IsModule(KT.Options) then return end

	KT.Options.AddFeatureSection("activeButton", {
		name = "當前任務物品按鈕",
		type = "group",
		inline = true,
		args = {
			activeButtonEnable = {
				name = "啟用當前任務物品按鈕",
				type = "toggle",
				confirm = true,
				confirmText = KT.TEXT.OPTION_WARNING,
				set = function()
					db.activeButtonEnable = not db.activeButtonEnable
					ReloadUI()
				end,
				order = 1.1,
			},
			activeButtonEnableDesc = {
				name = "距離最近的任務的物品按鈕顯示為 \"額外技能\"。",
				type = "description",
				marginLeft = 30,
				order = 1.2,
			},
			activeButtonBindingShow = {
				name = "顯示當前任務物品按鈕按鍵文字",
				width = 1.5,
				type = "toggle",
				disabled = function()
					return not db.activeButtonEnable
				end,
				set = function()
					db.activeButtonBindingShow = not db.activeButtonBindingShow
					KTF.ActiveFrame:Hide()
					Update()
				end,
				order = 2,
			},
			addonMasqueLabel = {
				name = " 啟用按鈕的外觀選項",
				type = "description",
				width = 2,
				fontSize = "medium",
				disabled = function()
					return not (db.activeButtonEnable and KT:Addon_IsModule(KT.AddonMasque) and KT.AddonMasque:IsActive())
				end,
				order = 3.1,
			},
			addonMasqueOptions = {
				name = "按鈕外觀 Masque",
				type = "execute",
				disabled = function()
					return not (db.activeButtonEnable and KT:Addon_IsModule(KT.AddonMasque) and KT.AddonMasque:IsActive())
				end,
				func = function()
					SlashCmdList["MASQUE"]()
				end,
				order = 3.2,
			},
		},
	})

	KT.Options.AddControlOption("keybindings", {
		keyBindActiveButtonLabel = {
			name = " 當前按鈕 (任務物品)",
			type = "description",
			width = 1,
			fontSize = "medium",
			disabled = function()
				return not db.activeButtonEnable
			end,
			order = 10.1,
		},
		keyBindActiveButtonDesc = {
			name = "使用"..format(KT.FORMAT.TEXT_BOLD, BINDING_NAME_EXTRAACTIONBUTTON1),
			type = "description",
			width = 1,
			justifyH = "RIGHT",
			disabled = function()
				return not db.activeButtonEnable
			end,
			order = 10.15,
		},
		keyBindActiveButton = {
			name = "",
			type = "keybinding",
			disabled = function()
				return not db.activeButtonEnable
			end,
			get = function()
				return GetBindingKey("EXTRAACTIONBUTTON1")
			end,
			set = function(_, value)
				KT.Keybind(value, "EXTRAACTIONBUTTON1")
			end,
			order = 10.2,
		},
	})
end

-- ---------------------------------------------------------------------------------------------------------------------

local function UpdateBlizzardButtonIconID()
	local iconID = 0
	if HasExtraActionBar() then
		local button = ExtraActionBarFrame.button
		local actionType, id = GetActionInfo(button.action)
		if actionType == "spell" then
			iconID = C_Spell.GetSpellTexture(id)
		end
	end
	blizzardButtonIconID = iconID
end

local function UpdateHotkey()
	local key = GetBindingKey("EXTRAACTIONBUTTON1")
	local button = KTF.ActiveButton
	local hotkey = button.HotKey
	local hotkeyExtra = ExtraActionButton1.HotKey
	local text = db.activeButtonBindingShow and GetBindingText(key, 1) or ""
	ClearOverrideBindings(button)
	if key then
		hotkeyExtra:SetText(RANGE_INDICATOR)
		hotkeyExtra:Hide()
		SetOverrideBindingClick(button, false, key, button:GetName())
	end
	if text == "" then
		hotkey:SetText(RANGE_INDICATOR)
		hotkey:Hide()
	else
		hotkey:SetText(text)
		hotkey:Show()
	end
end

local function RemoveHotkey(button)
	local key = GetBindingKey("EXTRAACTIONBUTTON1")
	local hotkeyExtra = ExtraActionButton1.HotKey
	if key then
		hotkeyExtra:SetText(GetBindingText(key, 1))
		hotkeyExtra:Show()
		ClearOverrideBindings(button)
	end
end

local function EventFrame_OnUpdate(self)
	if KTF.Buttons:IsShown() then
		if self.timer > 50 then
			KT:Prot(Update)
			self.timer = 0
		else
			self.timer = self.timer + TOOLTIP_UPDATE_TIME
		end
	end
end

local function ActiveFrame_Hide()
	if activeFrame:IsShown() then
		activeFrame:Hide()
		abutton.text:SetText("")
		RemoveHotkey(abutton)
	end
end

local function SetFrames()
	-- Event frame
	if not eventFrame then
		eventFrame = CreateFrame("Frame")
		eventFrame.timer = 0
		eventFrame:SetScript("OnEvent", function(_, event)
			_DBG("Event - "..event, true)
			if event == "UPDATE_EXTRA_ACTIONBAR" then
				UpdateBlizzardButtonIconID()
				KT:Prot(Update)
			elseif event == "UPDATE_BINDINGS" then
				if activeFrame:IsShown() then
					UpdateHotkey()
				end
			end
		end)
		eventFrame:SetScript("OnUpdate", EventFrame_OnUpdate)
	end
	eventFrame:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	eventFrame:RegisterEvent("UPDATE_BINDINGS")

	-- Main frame
	activeFrame = KTF.ActiveFrame
	if not activeFrame then
		activeFrame = CreateFrame("Frame", nil, UIParent)
		activeFrame:SetSize(activeFrameWidth, activeFrameHeight)
		activeFrame:SetScale(db.activeButton.scale)
		activeFrame:SetFrameStrata(db.activeButton.strata)
		activeFrame:SetFrameLevel(80)
		activeFrame:Hide()
		KTF.ActiveFrame = activeFrame
	end

	ActiveFrame_Move()

	-- Button frame
	if not KTF.ActiveButton then
		local button = CreateFrame("Button", addonName.."ActiveButton", activeFrame, "SecureActionButtonTemplate")
		button:SetSize(52, 52)
		button:SetPoint("CENTER")

		button.icon = button:CreateTexture(nil, "BACKGROUND")
		button.icon:SetPoint("TOPLEFT", 0, -1)
		button.icon:SetPoint("BOTTOMRIGHT", 0, -1)
		
		button.Style = button:CreateTexture(nil, "OVERLAY")
		button.Style:SetSize(256, 128)
		button.Style:SetPoint("CENTER", -2, 0)
		button.Style:SetTexture("Interface\\ExtraButton\\ChampionLight")
		
		button.Count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
		button.Count:SetJustifyH("RIGHT")
		button.Count:SetPoint("BOTTOMRIGHT", button.icon, -4, 4)
		
		button.Cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		button.Cooldown:ClearAllPoints()
		button.Cooldown:SetPoint("TOPLEFT", 4, -4)
		button.Cooldown:SetPoint("BOTTOMRIGHT", -3, 2)
		
		button.HotKey = button:CreateFontString(nil, "ARTWORK", "NumberFontNormalSmallGray")
		button.HotKey:SetSize(30, 10)
		button.HotKey:SetJustifyH("RIGHT")
		button.HotKey:SetText(RANGE_INDICATOR)
		button.HotKey:SetPoint("TOPRIGHT", button.icon, -2, -7)
		
		button.text = button:CreateFontString(nil, "ARTWORK", "NumberFontNormalSmall")
		button.text:SetSize(20, 10)
		button.text:SetJustifyH("LEFT")
		button.text:SetPoint("TOPLEFT", button.icon, 4, -7)
		
		button:SetScript("OnEvent", KT.ItemButton.OnEvent)
		button:SetScript("OnUpdate", KT.ItemButton.OnUpdate)
		button:SetScript("OnShow", KT.ItemButton.OnShow)
		button:SetScript("OnHide", KT.ItemButton.OnHide)
		button:SetScript("OnEnter", KT.ItemButton.OnEnter)
		button:SetScript("OnLeave", KT.ItemButton.OnLeave)
		button:RegisterForClicks("AnyDown", "AnyUp")
		button:SetAttribute("type", "item")
		
		button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
		do local tex = button:GetPushedTexture()
			tex:SetPoint("TOPLEFT", 0, -1)
			tex:SetPoint("BOTTOMRIGHT", 0, -1)
		end
		button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		do local tex = button:GetHighlightTexture()
			tex:SetPoint("TOPLEFT", 0, -1)
			tex:SetPoint("BOTTOMRIGHT", 0, -1)
		end

		SetItemButtonTexture(button, DEFAULT_ICON)
		if KT:Addon_IsModule(KT.AddonMasque) then
			KT.AddonMasque:AddButton(button, 2)
		end
		KTF.ActiveButton = button
	end
	abutton = KTF.ActiveButton
end

function Update(_, id)
	if InCombatLockdown() then return end
	if KT.EditMode and KT.EditMode.opened then return end

	local closestQuestID = id
	if not closestQuestID then
		if not KT:Tracker_IsCollapsed() then
			local superTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID() or 0
			for questID in pairs(buttons) do
				if questID == superTrackedQuestID then
					closestQuestID = questID
					break
				end
				if C_Minimap.IsInsideQuestBlob(questID) then
					closestQuestID = questID
				end
			end
		end
	end

	if closestQuestID and not KT.EXCLUDED_QUEST_ITEMS[closestQuestID] then
		local button = KT.QuestButtons_Get(closestQuestID)
		if button and button.item ~= blizzardButtonIconID then
			local autoShowTooltip = false
			if GameTooltip:IsShown() and GameTooltip:GetOwner() == abutton then
				KT.ItemButton.OnLeave(abutton)
				autoShowTooltip = true
			end

			abutton.block = button.block
			abutton:SetAttribute("questLogIndex", button:GetAttribute("questLogIndex"))
			abutton:SetAttribute("questID", closestQuestID)
			abutton.charges = button.charges
			abutton.rangeTimer = button.rangeTimer
			abutton.item = button.item
			abutton.link = button.link
			SetItemButtonTexture(abutton, button.item)
			SetItemButtonCount(abutton, button.charges)
			KT.ItemButton.UpdateCooldown(abutton)
			abutton.text:SetText(button.num)
			abutton:SetAttribute("item", button.link)

			if not activeFrame:IsShown() then
				UpdateHotkey()
				activeFrame:SetShown(not KT.locked)
			end

			if autoShowTooltip then
				KT.ItemButton.OnEnter(abutton)
			end
		else
			ActiveFrame_Hide()
		end
	else
		ActiveFrame_Hide()
	end
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
	_DBG("|cffffff00初始化|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = true

	-- Cleanup (temporarily)
	db.qiActiveButton = nil
	db.qiActiveButtonBindingShow = nil

	if self.isAvailable then
		local defaults = KT.MergeTables({
			profile = {
				activeButtonEnable = true,
				activeButtonBindingShow = true,
				activeButton = {
					anchor = "BOTTOM",
					xOffset = 0,
					yOffset = 264,
					scale = 1,
					pixelPerfectScale = false,
					strata = "MEDIUM",
				}
			}
		}, KT.db.defaults)
		KT.db:RegisterDefaults(defaults)
	end
end

function M:OnEnable()
	_DBG("|cff00ff00啟用|r - "..self:GetName(), true)
	SetupOptions()

	if db.activeButtonEnable then
		SetFrames()
		EditMode_SetupMover()

		KT:RegSignal("BUTTONS_UPDATED", Update, self)
	end
end