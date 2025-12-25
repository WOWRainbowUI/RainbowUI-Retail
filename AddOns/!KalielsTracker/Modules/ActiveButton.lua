--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

---@class ActiveButton
local M = KT:NewModule("ActiveButton")
KT.ActiveButton = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar
local KTF = KT.frame

local eventFrame
local activeFrame, abutton
local blizzardButtonIconID = 0

local isBartender, isElvui, isTukui = false, false, false

local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

-- Internal ------------------------------------------------------------------------------------------------------------

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
	local text = db.qiActiveButtonBindingShow and GetBindingText(key, 1) or ""
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
			KT:prot("Update", M)
			self.timer = 0
		else
			self.timer = self.timer + TOOLTIP_UPDATE_TIME
		end
	end
end

local function ActiveFrame_SetPosition()
	local point, relativeTo, relativePoint, xOfs, yOfs = "BOTTOM", UIParent, "BOTTOM", 0, 285
	if db.qiActiveButtonPosition then
		point, relativeTo, relativePoint, xOfs, yOfs = unpack(db.qiActiveButtonPosition)
		if point ~= "CENTER" then
			if point ~= "TOP" and point ~= "BOTTOM" then
				local xOfsMod = activeFrame:GetWidth() / 2
				if point == "TOPLEFT" or point == "BOTTOMLEFT" or point == "LEFT" then
					xOfs = max(xOfs, -1 * xOfsMod)
				else
					xOfs = min(xOfs, xOfsMod)
				end
			end
			if point ~= "LEFT" and point ~= "RIGHT" then
				local yOfsMod = activeFrame:GetHeight() / 2
				if point == "TOPLEFT" or point == "TOPRIGHT" or point == "TOP" then
					yOfs = min(yOfs, yOfsMod)
				else
					yOfs = max(yOfs, -1 * yOfsMod)
				end
			end
		end
	else
		if isBartender then
			yOfs = yOfs - 40
		elseif isElvui then
			yOfs = yOfs -14
		elseif isTukui then
			yOfs = yOfs + 26
		end
	end
	KT:prot("ClearAllPoints", activeFrame)
	KT:prot("SetPoint", activeFrame, point, relativeTo, relativePoint, xOfs, yOfs)
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
				KT:prot("Update", M)
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
		activeFrame:SetSize(256, 128)
		activeFrame:SetFrameLevel(80)
		activeFrame:Hide()
		KTF.ActiveFrame = activeFrame
	end

	ActiveFrame_SetPosition()

	-- Mover
	local mover = KT:Mover_Create(addonName, KTF.ActiveFrame)

	function mover:Show()
		self.mixin.Show(self)
		self.frame:Show()
	end

	function mover:Hide()
		self.mixin.Hide(self)
		M:Update()
	end

	function mover:OnDragStop(frame)
		db.qiActiveButtonPosition = { frame:GetPoint() }
		ActiveFrame_SetPosition()
	end

	function mover:OnMouseUp(frame, button)
		if button == "RightButton" then
			db.qiActiveButtonPosition = nil
			ActiveFrame_SetPosition()
		end
	end

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
		KT:Masque_AddButton(button, 2)
		KTF.ActiveButton = button
	end
	abutton = KTF.ActiveButton
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = db.qiActiveButton

	-- Cleanup (temporarily)
	dbChar.activeButtonPosition = nil
end

function M:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	isBartender = C_AddOns.IsAddOnLoaded("Bartender4")
	isElvui = C_AddOns.IsAddOnLoaded("ElvUI")
	isTukui = C_AddOns.IsAddOnLoaded("Tukui")

	SetFrames()

	KT:RegSignal("BUTTONS_UPDATED", "prot", KT, "Update", self)
end

function M:Update(id)
	if KT.EditMode.opened then return end

	local closestQuestID = id
	if not closestQuestID then
		if not KT:IsCollapsed() then
			local superTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID() or 0
			for questID in pairs(KT.fixedButtons) do
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
		local button = KT:GetFixedButton(closestQuestID)
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