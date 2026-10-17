--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, addon = ...

---@class KT
local KT = LibStub("MSA-AceAddon-3.0"):NewAddon(addon, addonName, "LibSink-2.0", "MSA-Event-1.0", "MSA-ProtRouter-1.0", "MSA-EditMode-1.0", "MSA-AceConfigPatcher-1.0")
KT:SetDefaultModuleState(false)

local LSM = LibStub("LibSharedMedia-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local floor = math.floor
local format = string.format
local ipairs = ipairs
local tinsert = table.insert

-- WoW API
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local UIParent = UIParent

local db, dbChar
local testLine

-- Main frame
local KTF = CreateFrame("Frame", addonName.."Frame", UIParent)
KT.frame = KTF

-- Core frames
local OTF = KT_ObjectiveTrackerFrame
local OTFHeader = OTF.Header

local KTSetShown, KTSetWidth, KTSetHeight, KTSetPoint, KTClearAllPoints, KTSetScale, KTSetFrameStrata, KTSetAlpha

-- Prototype -----------------------------------------------------------------------------------------------------------

---@type KT|Options|Hacks|Filters|Events|QuestLog|ActiveButton|AddonPetTracker|AddonBattlePetCompletionist|AddonTomTom|AddonRareScanner|Help
local prototype = {}

---SetForced (prototype)
function prototype:SetForced(forced)
	if forced then
		KT.skinID = KT.skinID + 1
	end
end

local mt = getmetatable(KT)
mt.__index = prototype
setmetatable(KT, mt)
KT:SetDefaultModulePrototype(prototype)

-- Internal ------------------------------------------------------------------------------------------------------------

local function Tracker_HasContents()
	return OTF.contentsHeight > 0
end

function KT:Tracker_ShowHeader()
	local show = (not self:Tracker_IsCollapsed() and Tracker_HasContents()) or db.hdrCollapsedTxt > 1
	OTFHeader.Background:SetShown(db.hdrTrackerBgrShow and db.hdrBgr > 1 and show)
	OTFHeader.Logo:SetShown(show)
	OTFHeader.Text:SetShown(show)
end

local function SetHeadersStyle(type)
	local bgrColor = db.hdrBgrColorShare and KT.borderColor or db.hdrBgrColor
	local txtColor = db.hdrTxtColorShare and KT.borderColor or db.hdrTxtColor

	if not type or type == "background" then
		local spriteID = db.hdrBgr - 1
		if db.hdrBgr == 2 then
			KT.SetSprite(OTFHeader.Background, "tracker-header-bgr-"..spriteID, true)
			OTFHeader.Background:SetVertexColor(bgrColor.r, bgrColor.g, bgrColor.b)
			OTFHeader.Background:ClearAllPoints()
			OTFHeader.Background:SetPoint("TOP", 0, -1)
		elseif db.hdrBgr >= 3 then
			KT.SetSprite(OTFHeader.Background, "tracker-header-bgr-"..spriteID)
			OTFHeader.Background:SetVertexColor(bgrColor.r, bgrColor.g, bgrColor.b)
			OTFHeader.Background:ClearAllPoints()
			OTFHeader.Background:SetPoint("TOPLEFT", -20, -1)
			OTFHeader.Background:SetPoint("TOPRIGHT", 17, -1)
			OTFHeader.Background:SetHeight(29)
		end
		KT:Tracker_ShowHeader()

		for _, module in ipairs(OTF.modules) do
			local header = module.Header
			if db.hdrBgr == 1 then
				header.Background:Hide()
			elseif db.hdrBgr == 2 then
				KT.SetSprite(header.Background, "module-header-bgr-"..spriteID, true)
				header.Background:SetVertexColor(bgrColor.r, bgrColor.g, bgrColor.b)
				header.Background:ClearAllPoints()
				header.Background:SetPoint("TOP")
				header.Background:Show()
			elseif db.hdrBgr >= 3 then
				KT.SetSprite(header.Background, "module-header-bgr-"..spriteID)
				header.Background:SetVertexColor(bgrColor.r, bgrColor.g, bgrColor.b)
				header.Background:ClearAllPoints()
				header.Background:SetPoint("TOPLEFT", -20, 0)
				header.Background:SetPoint("TOPRIGHT", 17, 0)
				header.Background:SetHeight(24)
				header.Background:Show()
			end
		end
	end
	if not type or type == "text" then
		OTFHeader.Text:SetFont(KT.font, db.fontSize + 1, db.fontFlag)
		OTFHeader.Text:SetTextColor(txtColor.r, txtColor.g, txtColor.b)
		OTFHeader.Text:SetShadowColor(0, 0, 0, db.fontShadow)

		if type == "text" then
			for _, module in ipairs(OTF.modules) do
				local header = module.Header
				header.Icon:SetVertexColor(txtColor.r, txtColor.g, txtColor.b)
				header.Text:SetFont(KT.font, db.fontSize + 1, db.fontFlag)
				header.Text:SetTextColor(txtColor.r, txtColor.g, txtColor.b)
				header.Text:SetShadowColor(0, 0, 0, db.fontShadow)
				header.Text:SetPoint("LEFT", 4, 0.5)
			end
		end
	end
end

local function SetMsgPatterns()
	local patterns = {
		-- enUS/frFR/etc. ... "%s: %d/%d"
		-- deDE (only) ...... "%1$s: %2$d/%3$d"
		ERR_QUEST_ADD_FOUND_SII,
		ERR_QUEST_ADD_ITEM_SII,
		ERR_QUEST_ADD_KILL_SII,
		ERR_QUEST_ADD_PLAYER_KILL_SII,
	}
	for _, patt in ipairs(patterns) do
		patt = "^"..patt:gsub("%d+%$", ""):gsub("%%s", ".*"):gsub("%%d", "%%d+").."$"
		tinsert(KT.msgPatterns, patt)
	end
end

local function SlashHandler(msg)
	local cmd = msg:match("^(%S*)%s*(.-)$")
	if cmd == "config" then
		if KT:Addon_IsModule(KT.Options) then
			KT.Options:Open()
		end
	elseif cmd == "showhide" then
		KT:Tracker_SetHidden()
	else
		KT:MinimizeButton_OnClick()
	end
end

local function Quests_UpdateCount()
	dbChar.quests.num, dbChar.quests.numOver = KT.GetNumQuests()
	KT:SendSignal("QUESTS_COUNT_UPDATED")
end

local function InitMainFrame()
	KTF.Child:SetParent(KTF.Scroll)
	KTF.Scroll:SetScrollChild(KTF.Child)
end

local function Init()
	KT:SendSignal("TRACKER_INITIALIZING")

	KT:Tracker_Move()
	KT:Tracker_SetBackground()
	KT:Tracker_SetText(true)
	KT:SendSignal("OPTIONS_CHANGED")

	KT.stopUpdate = false
	KT.inWorld = true

	C_Timer.After(0, function()
		InitMainFrame()
		OTF:Update()

		KT.initialized = true
		KT:SendSignal("TRACKER_INITIALIZED")
	end)
end

-- Frames --------------------------------------------------------------------------------------------------------------

local function SetFrames()
	-- Main frame
	KTF:SetWidth(db.width)
	KTF:SetScale(db.frameScale)
	KTF:SetFrameStrata(db.frameStrata)
	KTF:SetFrameLevel(KTF:GetFrameLevel() + 25)
	KTF:SetClampedToScreen(true)
	KTF.height = 0
	KTF.paddingTop = OTF.topModulePadding
	KTF.paddingBottom = OTF.bottomModulePadding
	KTF.borderSpace = 4
	KTF.headerHeight = 31

	KTF:SetScript("OnEvent", function(self, event, ...)
		_DBG("Event - "..event)
		if event == "PLAYER_ENTERING_WORLD" and not KT.stopUpdate then
			KT.inWorld = true
			KT.inInstance = IsInInstance()
		elseif event == "PLAYER_LEAVING_WORLD" then
			KT.inWorld = false
		elseif event == "QUEST_DETAIL" then
			C_SuperTrack.ClearAllSuperTracked()
		elseif event == "QUEST_AUTOCOMPLETE" then
			KTF.Scroll.value = 0
		elseif event == "QUEST_ACCEPTED" then
			local questID = ...
			if not C_QuestLog.IsQuestTask(questID) and not C_QuestLog.IsQuestBounty(questID) then
				dbChar.quests.num, dbChar.quests.numOver = KT.QuestsCache_Update()
				KT:SendSignal("QUESTS_COUNT_UPDATED")

				KT.QuestsCache_UpdateProperty(questID, "startMapID", KT.GetCurrentMapAreaID())
				KT.QuestsCache_UpdateProperty(questID, "updateTime", time())
			end
		elseif event == "QUEST_REMOVED" then
			local questID = ...
			if not C_QuestLog.IsQuestTask(questID) and not C_QuestLog.IsQuestBounty(questID) then
				KT.QuestsCache_RemoveQuest(questID)

				dbChar.quests.num, dbChar.quests.numOver = KT.QuestsCache_Update()
				KT:SendSignal("QUESTS_COUNT_UPDATED")

				if db.questsAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
					KT.QuestSuperTracking_ChooseClosestQuest()
				end
			end
		elseif event == "QUEST_TURNED_IN" then
			if db.questsAutoFocusClosest then
				KT.QuestSuperTracking_ChooseClosestQuest()
			end
		elseif event == "QUEST_WATCH_UPDATE" then
			local questID = ...
			KT.QuestsCache_UpdateProperty(questID, "updateTime", time())
		elseif event == "QUEST_SESSION_JOINED" then
			self:RegisterEvent("QUEST_POI_UPDATE")
		elseif event == "QUEST_SESSION_LEFT" then
			C_Timer.After(1.1, function()
				KT.QuestsCache_Update()
				KT:Tracker_Update()
			end)
		elseif event == "QUEST_POI_UPDATE" then
			Quests_UpdateCount()
			self:UnregisterEvent(event)
		elseif event == "PLAYER_REGEN_ENABLED" then
			KT.QuestButtons_Rebuild()
			KT:Tracker_Update()
		elseif event == "PLAYER_LEVEL_UP" then
			local level = ...
			KT.playerLevel = level
		end
	end)
	KTF:RegisterEvent("PLAYER_ENTERING_WORLD")
	KTF:RegisterEvent("PLAYER_LEAVING_WORLD")
	KTF:RegisterEvent("QUEST_DETAIL")
	KTF:RegisterEvent("QUEST_AUTOCOMPLETE")
	KTF:RegisterEvent("QUEST_ACCEPTED")
	KTF:RegisterEvent("QUEST_REMOVED")
	KTF:RegisterEvent("QUEST_TURNED_IN")
	KTF:RegisterEvent("QUEST_SESSION_JOINED")
	KTF:RegisterEvent("QUEST_SESSION_LEFT")
	KTF:RegisterEvent("QUEST_WATCH_UPDATE")
	KTF:RegisterEvent("PLAYER_REGEN_ENABLED")
	KTF:RegisterEvent("PLAYER_LEVEL_UP")

	-- Backround
	local background = CreateFrame("Frame", addonName.."Background", KTF, "BackdropTemplate")
	background:SetFrameLevel(KTF:GetFrameLevel() - 1)
	KTF.Background = background

	-- Test line
	testLine = CreateFrame("Frame", nil, KTF, "KT_ObjectiveTrackerLineTemplate")

	-- DropDown frame
	KT.DropDown = MSA_DropDownMenu_Create(addonName.."DropDown", KTF)
	MSA_DropDownMenu_Initialize(KT.DropDown, nil, "MENU")

	-- Header buttons
	local headerButtons = CreateFrame("Frame", addonName.."HeaderButtons", KTF)
	headerButtons:SetSize(0, KTF.headerHeight)
	headerButtons:SetPoint("TOPRIGHT", -4, -4)
	headerButtons:SetFrameLevel(KTF:GetFrameLevel() + 10)
	headerButtons:EnableMouse(true)
	headerButtons.num = 0
	KTF.HeaderButtons = headerButtons

	-- Minimize button
	local button = CreateFrame("Button", addonName.."MinimizeButton", KTF.HeaderButtons)
	button:SetSize(16, 16)
	button:SetPoint("TOPRIGHT", -8, -7)
	button:SetNormalTexture(KT.MEDIA_PATH.."UI-KT-HeaderButtons")
	button:GetNormalTexture():SetTexCoord(0, 0.5, 0.25, 0.5)
	button:RegisterForClicks("AnyDown")
	button:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			KT.QuestSuperTracking_ChooseClosestQuest()
			KT:Tracker_Update()
		elseif IsAltKeyDown() then
			if KT:Addon_IsModule(KT.Options) then
				KT.Options:Open()
			end
		elseif Tracker_HasContents() and not KT.locked then
			KT:MinimizeButton_OnClick()
		end
	end)
	button:SetScript("OnEnter", function(self)
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local title = KT.TITLE..((db.keyBindCollapse ~= "") and NORMAL_FONT_COLOR_CODE.." ("..db.keyBindCollapse..")|r" or "")
		GameTooltip:AddLine(title, 1, 1, 1)
		GameTooltip:AddLine("Right Click - Focus closest Quest", 0.57, 0.57, 0.57)
		GameTooltip:AddLine("Alt + Click - Open addon Options", 0.57, 0.57, 0.57)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		self:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
		GameTooltip:Hide()
	end)
	KTF.MinimizeButton = button
	KT:Tracker_SetHeaderButtons(1)

	-- Scroll frame
	local Scroll = CreateFrame("ScrollFrame", addonName.."Scroll", KTF, "ScrollFrameTemplate")
	Scroll:SetPoint("TOPLEFT", KTF.borderSpace, KTF.borderSpace * -1)
	Scroll:SetPoint("BOTTOMRIGHT", KTF.borderSpace * -1, KTF.borderSpace)
    Scroll:SetClipsChildren(true)
	Scroll:EnableMouseWheel(true)
	Scroll.value = 0
	Scroll:SetScript("OnVerticalScroll", function(self, offset)
		MSA_CloseDropDownMenus()
		if KT:Addon_IsModule(KT.Scenario) then
			KT.Scenario:ExternalFrames_Hide()
		end
	end)
	KTF.Scroll = Scroll

	-- Scrollbar
	local bar = Scroll.ScrollBar
	bar:SetParent(KTF)
	bar:SetWidth(4)
	bar:SetPoint("TOPLEFT", Scroll, "TOPRIGHT", -4, 0)
	bar:SetPoint("BOTTOMLEFT", Scroll, "BOTTOMRIGHT", -4, 0)
	bar:SetFrameLevel(headerButtons:GetFrameLevel())
	bar:SetHideIfUnscrollable(true)
	bar.minThumbExtent = 52
	bar.fixedThumbExtent = 52
	bar.Back:Hide()
	bar.Forward:Hide()
	bar.Track:SetWidth(4)
	bar.Track:ClearAllPoints()
	bar.Track:SetAllPoints()
	local barTexture = bar.Track
	if bar.Background then
		barTexture = bar.Background
		local barBackground = bar:GetRegions()
		barBackground:Hide()
	end
	barTexture.Begin:Hide()
	barTexture.Middle:Hide()
	barTexture.End:Hide()
	local thumb = bar.Track.Thumb
	thumb:SetWidth(4)
	thumb.Begin:Hide()
	thumb.Middle:Hide()
	thumb.End:Hide()
	thumb.texture = thumb:CreateTexture()
	thumb.texture:SetPoint("TOPLEFT", 1, -1)
	thumb.texture:SetPoint("BOTTOMRIGHT", -1, 1)
	bar.texture = thumb.texture
	thumb.isDragging = false
	bar:SetScript("OnShow", function(self)
		self:SetShown(db.frameScrollbar)
	end)
	thumb:SetScript("OnEnter", function(self)
		self.texture:SetColorTexture(1, 1, 1, db.borderAlpha)
	end)
	thumb:SetScript("OnLeave", function(self)
		if not self.isDragging then
			self.texture:SetColorTexture(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b, db.borderAlpha)
		end
	end)
	thumb:SetScript("OnMouseDown", function(self)
		self.isDragging = true
	end)
	thumb:SetScript("OnMouseUp", function(self)
		self.isDragging = false
		if not self:IsMouseOver() then
			self.texture:SetColorTexture(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b, db.borderAlpha)
		end
	end)
	KTF.Bar = bar

	-- Scroll child frame
	local Child = CreateFrame("Frame", addonName.."ScrollChild", UIParent)
	Child:SetSize(db.width - 8, 1)
	Child:SetPoint("TOPLEFT")
	KTF.Child = Child

	-- Core frames
	OTF:ClearAllPoints()
	OTF:SetParent(Scroll)
	OTF:SetPoint("TOPLEFT", Child, 20, 0)
	OTF:SetPoint("BOTTOMRIGHT", Child)
	OTFHeader.MinimizeButton:Hide()
	OTFHeader.FilterButton:Hide()
	OTFHeader.Text:SetWidth(db.width - 85)
	OTFHeader.Text:SetWordWrap(false)
	OTF.headerText = KT.TITLE

	-- Other buttons
	KT:SetOtherButtons()

	-- Keybinding
	local BindingButton = CreateFrame("Button", "KT_BindingButton", UIParent)
	BindingButton:SetScript("OnClick", function(self, btn)
		KT:Tracker_SetHidden()
	end)

	-- Frame resets
	local Noop = function() end

	OTF.Show = Noop
	OTF.Hide = Noop
	OTF.SetShown = Noop
	OTF.SetSize = Noop
	OTF.SetWidth = Noop
	OTF.SetHeight = Noop
	OTF.SetParent = Noop
	OTF.SetPoint = Noop
	OTF.SetAllPoints = Noop
	OTF.ClearAllPoints = Noop
	OTF.SetScale = Noop
	OTF.SetAlpha = Noop
	OTF.SetFrameStrata = Noop
	OTF.SetFrameLevel = Noop
	OTF:SetClampedToScreen(false)
	OTF.SetClampedToScreen = Noop
	OTF:EnableMouse(false)
	OTF.EnableMouse = Noop
	OTF:SetMovable(false)
	OTF.SetMovable = Noop

	KTF.Show = Noop
	KTF.Hide = Noop
	KTSetShown = KTF.SetShown
	KTF.SetShown = Noop
	KTF.SetSize = Noop
	KTSetWidth = KTF.SetWidth
	KTF.SetWidth = Noop
	KTSetHeight = KTF.SetHeight
	KTF.SetHeight = Noop
	KTF.SetParent = Noop
	KTSetPoint = KTF.SetPoint
	KTF.SetPoint = Noop
	KTF.SetAllPoints = Noop
	KTClearAllPoints = KTF.ClearAllPoints
	KTF.ClearAllPoints = Noop
	KTSetScale = KTF.SetScale
	KTF.SetScale = Noop
	KTSetAlpha = KTF.SetAlpha
	KTF.SetAlpha = Noop
	KTSetFrameStrata = KTF.SetFrameStrata
	KTF.SetFrameStrata = Noop
	KTF.SetFrameLevel = Noop
	KTF.SetClampedToScreen = Noop
	KTF.EnableMouse = Noop
end

-- External ------------------------------------------------------------------------------------------------------------

---Set tracker collapsed or expanded.
---@param collapsed boolean|nil Collapsed state (true = collapse, false = expand, nil = toggle)
---@param silent boolean|nil If true, does not save collapsed state
function KT:Tracker_SetCollapsed(collapsed, silent)
	if collapsed == nil then
		OTF:ToggleCollapsed()
	else
		OTF:SetCollapsed(collapsed)
	end
	if not silent then
		dbChar.collapsed = OTF.isCollapsed
	end
end

---Get tracker collapsed state.
---@return boolean True is collapsed, false is expanded
function KT:Tracker_IsCollapsed()
	return OTF:IsCollapsed()
end

---Expand tracker only if it is currently collapsed.
function KT:Tracker_Expand()
	if self:Tracker_IsCollapsed() then
		self:Tracker_SetCollapsed(false)
	end
end

---Set tracker hidden state.
---@param hidden boolean|nil Hidden state (true = hide, false = show, nil = toggle)
---@param ignoreHideEmpty boolean Ignore 'Hide empty tracker' override
function KT:Tracker_SetHidden(hidden, ignoreHideEmpty)
	if not ignoreHideEmpty and db.hideEmptyTracker and not Tracker_HasContents() then return end

	if hidden == nil then
		self.hidden = not self.hidden
	else
		self.hidden = hidden
	end
	_DBG((self.hidden and "HIDE" or "SHOW").." ... collapsed: "..tostring(dbChar.collapsed), true)
	self.locked = self.hidden
	OTF:SetCollapsed(self.hidden or dbChar.collapsed)
end

---Update the tracker.
---@param forced boolean|nil If true, forces update.
function KT:Tracker_Update(forced)
	self:SetForced(forced)
	OTF:Update()
end

function KT:MinimizeButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	self:Tracker_SetCollapsed()
end

function KT:Tracker_SetSize(forced)
	local height = KTF.headerHeight + (2 * KTF.borderSpace)
	local mod = 0

	if not OTF.contentsHeight then
		return
	end

	_DBG(" - height = "..OTF.contentsHeight)
	if not self:Tracker_IsCollapsed() and Tracker_HasContents() then
		-- width
		KTSetWidth(KTF, db.width)

		-- height
		height = KTF.paddingTop + OTF.contentsHeight + mod + 10 + KTF.paddingBottom
		_DBG(" - "..KTF.paddingTop.." + "..OTF.contentsHeight.." + "..mod.." + 10 + "..KTF.paddingBottom.." = "..height, true)
		OTF.height = height

		if floor(height) > db.maxHeight then
			_DBG("MOVE ... "..KTF.Scroll.value.." > "..OTF.height.." - "..db.maxHeight)
			height = db.maxHeight
		elseif height <= db.maxHeight then
			KTF.Scroll.value = 0
		end

		if height ~= KTF.height or forced then
			KTSetHeight(KTF, KTF.directionUp and height or db.maxHeight)
			KTF.Background:SetHeight(height)
			KTF.height = height

			KTF.Scroll:SetVerticalScroll(KTF.Scroll.value)
		end
		KTF.Child:SetHeight(OTF.height - 8)

		self.QuestButtons_Move()
	else
		-- width
		if db.hdrCollapsedTxt == 1 then
			KTSetWidth(KTF, KTF.HeaderButtons:GetWidth() + 8)
		else
			KTSetWidth(KTF, db.width)
		end

		-- height
		OTF.height = height - 8
		if height ~= KTF.height or forced then
			KTF.Scroll.value = KTF.Scroll:GetVerticalScroll()
			KTF.Scroll:SetVerticalScroll(0)

			KTSetHeight(KTF, KTF.directionUp and height or db.maxHeight)
			KTF.Background:SetHeight(height)
			KTF.height = height
		end
		KTF.Child:SetHeight(OTF.height)
	end
end

function KT:Tracker_Move()
	KTF.directionUp = (db.anchorPoint == "BOTTOMLEFT" or db.anchorPoint == "BOTTOMRIGHT")
	KTF.anchorLeft = (db.anchorPoint == "TOPLEFT" or db.anchorPoint == "BOTTOMLEFT")

	local xOffset = self.round(db.xOffset / db.frameScale)
	local yOffset = self.round(db.yOffset / db.frameScale)
	KTClearAllPoints(KTF)
	KTSetPoint(KTF, db.anchorPoint, UIParent, db.anchorPoint, xOffset, yOffset)

	KTF.Background:ClearAllPoints()
	if KTF.directionUp then
		KTF.Background:SetPoint("BOTTOMLEFT")
		KTF.Background:SetPoint("BOTTOMRIGHT")
	else
		KTF.Background:SetPoint("TOPLEFT")
		KTF.Background:SetPoint("TOPRIGHT")
	end

	self.QuestButtons_Move()
end

function KT:Tracker_SetShown(show)
	KTSetShown(KTF, show)
	KTF.Buttons:SetShown(show and KTF.Buttons.num > 0)
end

function KT:Tracker_SetScale(scale)
	KTSetScale(KTF, scale)
	KTF.Buttons:SetScale(scale)
end

function KT:Tracker_SetFrameStrata(strata)
	KTSetFrameStrata(KTF, strata)
	KTF.Buttons:SetFrameStrata(strata)
end

function KT:Tracker_SetBackground()
	local backdrop = {
		bgFile = LSM:Fetch("background", db.bgr),
		edgeFile = LSM:Fetch("border", db.border),
		edgeSize = db.borderThickness,
		insets = { left=db.bgrInset, right=db.bgrInset, top=db.bgrInset, bottom=db.bgrInset }
	}
	self.borderColor = db.classBorder and self.classColor or db.borderColor

	KTF.Background:SetBackdrop(backdrop)
	KTF.Background:SetBackdropColor(db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a)
	KTF.Background:SetBackdropBorderColor(self.borderColor.r, self.borderColor.g, self.borderColor.b, db.borderAlpha)

	SetHeadersStyle("background")

	self.hdrBtnColor = db.hdrBtnColorShare and self.borderColor or db.hdrBtnColor
	KTF.MinimizeButton:GetNormalTexture():SetVertexColor(self.hdrBtnColor.r, self.hdrBtnColor.g, self.hdrBtnColor.b)
	if self:Addon_IsModule(self.Filters) then
		if dbChar.filterAuto[1] or dbChar.filterAuto[2] or dbChar.filterAuto[3] then
			KTF.FilterButton:GetNormalTexture():SetVertexColor(0, 1, 0)
		else
			KTF.FilterButton:GetNormalTexture():SetVertexColor(self.hdrBtnColor.r, self.hdrBtnColor.g, self.hdrBtnColor.b)
		end
	end
	if db.hdrOtherButtons then
		KTF.QuestLogButton:GetNormalTexture():SetVertexColor(self.hdrBtnColor.r, self.hdrBtnColor.g, self.hdrBtnColor.b)
		KTF.AchievementsButton:GetNormalTexture():SetVertexColor(self.hdrBtnColor.r, self.hdrBtnColor.g, self.hdrBtnColor.b)
	end

	if db.qiBgrBorder then
		KTF.Buttons:SetBackdrop(backdrop)
		KTF.Buttons:SetBackdropColor(db.bgrColor.r, db.bgrColor.g, db.bgrColor.b, db.bgrColor.a)
		KTF.Buttons:SetBackdropBorderColor(self.borderColor.r, self.borderColor.g, self.borderColor.b, db.borderAlpha)
	else
		KTF.Buttons:SetBackdrop(nil)
	end

	KTF.Bar.texture:SetColorTexture(self.borderColor.r, self.borderColor.g, self.borderColor.b, db.borderAlpha)
end

-- TODO: Rename function
function KT:Tracker_SetText(forced)
	if forced then
		self.skinID = self.skinID + 1
	end

	self.font = LSM:Fetch("font", db.font)
	testLine.Dash:SetFont(self.font, db.fontSize, db.fontFlag)
	self.dashWidth = testLine.Dash:GetWidth() + 1

	-- Headers
	SetHeadersStyle("text")

	-- Others
	if self:Addon_IsModule(self.Scenario) then
		self.Scenario:Module_SetText()
	end
end

function KT:Tracker_SetHeaderButtons(numAddButtons)
	local buttonSpace = 20
	KTF.HeaderButtons.num = KTF.HeaderButtons.num + numAddButtons
	KTF.HeaderButtons:SetWidth((KTF.HeaderButtons.num * buttonSpace) + 11)
	OTFHeader.Text:SetWidth(OTFHeader.Text:GetWidth() - (numAddButtons * buttonSpace))
end

function KT:SetOtherButtons()
	if not db.hdrOtherButtons then
		if KTF.QuestLogButton then
			KTF.QuestLogButton:Hide()
			KTF.AchievementsButton:Hide()
			self:Tracker_SetHeaderButtons(-2)
		end
		return
	end
	if KTF.QuestLogButton then
		KTF.QuestLogButton:Show()
		KTF.AchievementsButton:Show()
	else
		local button
		-- Achievements button
		button = CreateFrame("Button", addonName.."AchievementsButton", KTF.HeaderButtons)
		button:SetSize(16, 16)
		button:SetPoint("TOPRIGHT", KTF.FilterButton or KTF.MinimizeButton, "TOPLEFT", -4, 0)
		button:SetNormalTexture(KT.MEDIA_PATH.."UI-KT-HeaderButtons")
		button:GetNormalTexture():SetTexCoord(0.5, 1, 0.25, 0.5)
		button:RegisterForClicks("AnyDown")
		button:SetScript("OnClick", function(self, btn)
			KT.OpenService_Open("achievements")
		end)
		button:SetScript("OnEnter", function(self)
			self:GetNormalTexture():SetVertexColor(1, 1, 1)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(AchievementMicroButton.tooltipText, 1, 1, 1)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function(self)
			self:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
			GameTooltip:Hide()
		end)
		KTF.AchievementsButton = button

		-- Quest Log button
		button = CreateFrame("Button", addonName.."QuestLogButton", KTF.HeaderButtons)
		button:SetSize(16, 16)
		button:SetPoint("TOPRIGHT", KTF.AchievementsButton, "TOPLEFT", -4, 0)
		button:SetNormalTexture(KT.MEDIA_PATH.."UI-KT-HeaderButtons")
		button:GetNormalTexture():SetTexCoord(0.5, 1, 0, 0.25)
		button:RegisterForClicks("AnyDown")
		button:SetScript("OnClick", function(self, btn)
			KT.OpenService_Open("questlog")
		end)
		button:SetScript("OnEnter", function(self)
			self:GetNormalTexture():SetVertexColor(1, 1, 1)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(QuestLogMicroButton.tooltipText, 1, 1, 1)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function(self)
			self:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
			GameTooltip:Hide()
		end)
		KTF.QuestLogButton = button
	end
	self:Tracker_SetHeaderButtons(2)
end

function KT:Tracker_ToggleEmpty()
	local alpha, mouse = 1, true
	if not Tracker_HasContents() or self.hidden then
		KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 0.75)
		if db.hideEmptyTracker or self.hidden then
			alpha = 0
			mouse = false
		end
	else
		if self:Tracker_IsCollapsed() then
			KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.25)
		else
			KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.25, 0.5)
		end
	end

	KTSetAlpha(KTF, alpha)
	KTF.MinimizeButton:EnableMouse(mouse)
	if self:Addon_IsModule(self.Filters) then
		KTF.FilterButton:EnableMouse(mouse)
	end
	if db.hdrOtherButtons then
		KTF.QuestLogButton:EnableMouse(mouse)
		KTF.AchievementsButton:EnableMouse(mouse)
	end
end

function KT.GameTooltip_SetPosition(frame, xOffsetLeft, yOffsetLeft, xOffsetRight, yOffsetRight, skipSetOwner)
	if not skipSetOwner then
		GameTooltip:SetOwner(frame, "ANCHOR_NONE")
	end
	GameTooltip:ClearAllPoints()
	if KTF.anchorLeft then
		GameTooltip:SetPoint("TOPLEFT", frame, "TOPRIGHT", db.frameScale * (xOffsetLeft or 19), db.frameScale * (yOffsetLeft or 1))
	else
		GameTooltip:SetPoint("TOPRIGHT", frame, "TOPLEFT", db.frameScale * (xOffsetRight or -42), db.frameScale * (yOffsetRight or 1))
	end
end

function KT:SetMessage(text, r, g, b, pattern, icon, x, y)
	if pattern then
		text = format(pattern, text.." ...")
	end
	if icon then
		x = x or 0
		y = y or 0
		if db.sink20OutputSink == "Default" or db.sink20OutputSink == "Blizzard" then
			x = x - 6 - (db.sink20Sticky and 2 or 0)
			y = y - 8
		end
		text = format("|T%s:0:0:%d:%d|t%s", icon, x, y, text)
	end
	self:Pour(text, r, g, b)
end

local SOUND_COOLDOWN = 1
local soundLocked = false
function KT:PlaySound(key, forceChannel)
	if soundLocked then return end

	local sound = LSM:Fetch("sound", key)
	if not sound then return end

	soundLocked = true
	PlaySoundFile(sound, forceChannel or db.soundChannel)
	C_Timer.After(SOUND_COOLDOWN, function()
		soundLocked = false
	end)
end

-- ---------------------------------------------------------------------------------------------------------------------

function KT:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)

	SLASH_KALIELSTRACKER1, SLASH_KALIELSTRACKER2 = "/kt", "/kalielstracker"
	SlashCmdList["KALIELSTRACKER"] = SlashHandler

	-- Character data
	self.playerName = UnitName("player")
	self.playerFaction = UnitFactionGroup("player")
	self.playerLevel = UnitLevel("player")
	local className, classFile = UnitClass("player")
	self.playerClass = className
	self.classColor = RAID_CLASS_COLORS[classFile]

	-- Tracker data
	self.msgPatterns = {}
	self.borderColor = {}
	self.hdrBtnColor = {}
	self.skinID = 0
	self.font = ""
	self.dashWidth = 0
	self.inWorld = false
	self.inInstance = IsInInstance()
	self.inScenario = C_Scenario.IsInScenario() and not KT.IsScenarioHidden()
	self.autoExpand = false
	self.hiddenQuestPopUps = false
	self.stopUpdate = true
	self.questStateStopUpdate = false
	self.hidden = false
	self.locked = false
	self.initialized = false

	self:Config_Init()
	self:Storage_Init()

	SetMsgPatterns()
end

function KT:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	db = self.db.profile
	dbChar = self.db.char

	self:Alert_ResetIncompatibleProfiles()

	self.isTimerunningPlayer = (PlayerGetTimerunningSeasonID() ~= nil)

	self:InitSubsystems({
		Quests = { self.storage.quests },
		Achievements = { self.storage.achievements }
	})

	SetFrames()

	self:RegSignal("QUESTS_READY:10", Quests_UpdateCount)
	self:RegSignal("OPTIONS_CHANGED", "Tracker_Update")
	self:RegEvent("PLAYER_ENTERING_WORLD", function(eventID, ...)
		self.ObjectiveTrackerManager:OnPlayerEnteringWorld(...)
		Init()
		self:UnregEvent(eventID)
	end)

	self:Addon_EnableModules()
	self.Modules_ReconcileOrder()

	if self.db.global.version ~= self.VERSION then
		self.db.global.version = self.VERSION
	end

	self:SendSignal("ADDON_ENABLED")
end