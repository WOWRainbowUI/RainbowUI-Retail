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
local fmod = math.fmod
local format = string.format
local ipairs = ipairs
local max = math.max
local pairs = pairs
local strfind = string.find
local tonumber = tonumber
local tinsert = table.insert

-- WoW API
local _G = _G
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local UIParent = UIParent

local db, dbChar
local testLine
local msgPatterns = {}

-- Main frame
local KTF = CreateFrame("Frame", addonName.."Frame", UIParent)
KT.frame = KTF

-- Core frames
local OTF = KT_ObjectiveTrackerFrame
local OTFHeader = OTF.Header

local KTSetShown, KTSetWidth, KTSetHeight, KTSetPoint, KTClearAllPoints, KTSetScale, KTSetFrameStrata, KTSetAlpha

-- Prototype -----------------------------------------------------------------------------------------------------------

---@type KT|Options|Hacks|Filters|Events|QuestLog|ActiveButton|AddonPetTracker|AddonBattlePetCompletionist|AddonTomTom|AddonRareScanner|AddonOthers|Help
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

local changedMixins = {}

local function Default_SetChangedMixin(mixin, parentKey, method, ...)
	tinsert(changedMixins, {
		mixin = mixin,
		parentKey = parentKey,
		method = method,
		modules = { ... }
	})
end

local function Default_UpdateMixins()
	for _, data in ipairs(changedMixins) do
		local modules = #data.modules > 0 and data.modules or KT.MODULES
		for _, module in ipairs(modules) do
			local frame = data.parentKey and _G[module][data.parentKey] or _G[module]
			frame[data.method] = data.mixin[data.method]
		end
	end

	for k, v in pairs(KT_ObjectiveTrackerBlockMixin) do
		KT_ScenarioObjectiveTracker.ObjectivesBlock[k] = v
	end
end

local function Tracker_HasContent()
	local result = false
	if OTF.modules then
		for _, module in ipairs(OTF.modules) do
			if module.hasContents then
				result = true
				break
			end
		end
	end
	return result
end

local function Tracker_ShowHeader()
	local show = (not KT:Tracker_IsCollapsed() and Tracker_HasContent()) or db.hdrCollapsedTxt > 1
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
		Tracker_ShowHeader()

		for _, header in ipairs(KT.headers) do
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

		for _, header in ipairs(KT.headers) do
			if type == "text" then
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
		tinsert(msgPatterns, patt)
	end
end

local function SlashHandler(msg)
	local cmd = msg:match("^(%S*)%s*(.-)$")
	if cmd == "config" then
		KT:OpenOptions()
	elseif cmd == "showhide" then
		KT:Tracker_SetHidden()
	else
		KT:MinimizeButton_OnClick()
	end
end

local function CreateQuestTags(quest)
	local level, tag = "", ""
	local result = ""

	if db.questsShowLevel then
		level = tostring(quest.level)
	end

	if db.questsShowTags then
		local questID = quest:GetID()
		local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
		local questTag = tagInfo and tagInfo.tagID
		if questTag then
			tag = KT.QUEST_TAGS[questTag] or ""
			if questTag == Enum.QuestTag.Group then
				local suggestedGroup = quest.suggestedGroup
				if suggestedGroup and suggestedGroup > 0 then
					tag = tag..suggestedGroup
				end
			end
		end

		if C_QuestLog.IsAccountQuest(questID) then
			tag = "•"..tag
		end

		local frequency = quest.frequency
		if frequency == Enum.QuestFrequency.Daily then
			tag = tag.."!"
		elseif frequency == Enum.QuestFrequency.Weekly or frequency == Enum.QuestFrequency.ResetByScheduler then
			tag = tag.."!!"
		end
	end

	if level ~= "" or tag ~= "" then
		result = format("[%s|cff00b3ff%s|r] ", level, tag)
	end

	return result
end

local function GetTaskTimeLeftData(questID)
	local timeString = ""
	local timeColor = KT_OBJECTIVE_TRACKER_COLOR["TimeLeft2"]
	local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questID)
	if timeLeftMinutes and timeLeftMinutes > 0 then
		timeString = SecondsToTime(timeLeftMinutes * 60)
		if timeLeftMinutes <= WORLD_QUESTS_TIME_CRITICAL_MINUTES then
			timeColor = KT_OBJECTIVE_TRACKER_COLOR["TimeLeft"]
		end
	end
	return timeString, timeColor
end

local function Quests_UpdateCount()
	dbChar.quests.num, dbChar.quests.numOver = KT.GetNumQuests()
	KT.Quests:SetHeaderText()
end

local function InitMainFrame()
	KTF.Child:SetParent(KTF.Scroll)
	KTF.Scroll:SetScrollChild(KTF.Child)
end

-- Init ----------------------------------------------------------------------------------------------------------------

local function Init()
	KT:SendSignal("INIT")

	for i, moduleName in ipairs(db.modulesOrder) do
		local module = _G[moduleName]
		module.uiOrder = i
		KT:Module_SetHeader(module)
		KT:Module_SetCollapsed(module, dbChar.collapsedModules[moduleName])
	end

	KT:Tracker_Move()
	KT:Tracker_SetBackground()
	KT:Tracker_SetText(true)
	KT:SendSignal("OPTIONS_CHANGED")

	KT.stopUpdate = false
	KT.inWorld = true

	C_Timer.After(0, function()
		KT.Quests:SetHeaderText()
		KT.Achievements:SetHeaderText()

		InitMainFrame()
		OTF:Update()

		KT.initialized = true
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
		elseif event == "SCENARIO_UPDATE" then
			local newStage = ...
			KT.inInstance = IsInInstance()
			if not C_Scenario.IsInScenario() or IsInJailersTower() == nil or IsOnGroundFloorInJailersTower() == true then
				KT.inScenario = false
			else
				KT.inScenario = true
			end
			KT_ScenarioObjectiveTracker:MarkDirty()
			if not newStage then
				-- TODO
				--[[local numSpells = KT_ScenarioObjectiveTracker.ObjectivesBlock.numSpells or 0
				for i = 1, numSpells do
					KT.QuestButtons_Remove(KT_ScenarioObjectiveBlock.spells[i])
				end
				KT_ObjectiveTracker_Update()]]
			end
		elseif event == "SCENARIO_COMPLETED" then
			KT.inInstance = IsInInstance()
			KT.inScenario = false
			KT_ScenarioObjectiveTracker:MarkDirty()
		elseif event == "QUEST_DETAIL" then
			C_SuperTrack.ClearAllSuperTracked()
		elseif event == "QUEST_AUTOCOMPLETE" then
			KTF.Scroll.value = 0
		elseif event == "QUEST_ACCEPTED" then
			local questID = ...
			if not C_QuestLog.IsQuestTask(questID) and not C_QuestLog.IsQuestBounty(questID) then
				dbChar.quests.num, dbChar.quests.numOver = KT.QuestsCache_Update()
				KT.Quests:SetHeaderText()

				KT.QuestsCache_UpdateProperty(questID, "startMapID", KT.GetCurrentMapAreaID())
				KT.QuestsCache_UpdateProperty(questID, "updateTime", time())
			end
		elseif event == "QUEST_REMOVED" then
			local questID = ...
			if not C_QuestLog.IsQuestTask(questID) and not C_QuestLog.IsQuestBounty(questID) then
				KT.QuestsCache_RemoveQuest(questID)

				dbChar.quests.num, dbChar.quests.numOver = KT.QuestsCache_Update()
				KT.Quests:SetHeaderText()

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
		elseif event == "ACHIEVEMENT_EARNED" then
			KT.Achievements:SetHeaderText()
        elseif event == "CRITERIA_EARNED" then
            local achievementID = ...
            if db.achievsProgressAutoTrack then
                KT.AddTrackedAchievement(achievementID)
            end
		elseif event == "PLAYER_REGEN_ENABLED" and KT.combatLockdown then
			KT.combatLockdown = false
			KT.QuestButtons_Remove()
			OTF:Update()
		elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
			KTF.Buttons.reanchor = (KTF.Buttons.num > 0)
		elseif event == "PLAYER_LEVEL_UP" then
			local level = ...
			KT.playerLevel = level
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
		end
	end)
	KTF:RegisterEvent("PLAYER_ENTERING_WORLD")
	KTF:RegisterEvent("PLAYER_LEAVING_WORLD")
	KTF:RegisterEvent("SCENARIO_UPDATE")
	KTF:RegisterEvent("SCENARIO_COMPLETED")
	KTF:RegisterEvent("QUEST_DETAIL")
	KTF:RegisterEvent("QUEST_AUTOCOMPLETE")
	KTF:RegisterEvent("QUEST_ACCEPTED")
	KTF:RegisterEvent("QUEST_REMOVED")
	KTF:RegisterEvent("QUEST_TURNED_IN")
	KTF:RegisterEvent("QUEST_SESSION_JOINED")
	KTF:RegisterEvent("QUEST_SESSION_LEFT")
	KTF:RegisterEvent("QUEST_WATCH_UPDATE")
	KTF:RegisterEvent("ACHIEVEMENT_EARNED")
    KTF:RegisterEvent("CRITERIA_EARNED")
	KTF:RegisterEvent("PLAYER_REGEN_ENABLED")
	KTF:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	KTF:RegisterEvent("ZONE_CHANGED")
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
			KT:OpenOptions()
		elseif Tracker_HasContent() and not KT.locked then
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
		KT.Scenario:ExternalFrames_Hide()
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
	bar.Track.Begin:Hide()
	bar.Track.Middle:Hide()
	bar.Track.End:Hide()
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

	-- Buttons frame
	local Buttons = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	Buttons:SetSize(40, 40)
	Buttons:SetPoint("TOPLEFT", 0, 0)
	Buttons:SetScale(db.frameScale)
	Buttons:SetFrameStrata(db.frameStrata)
	Buttons:SetFrameLevel(KTF:GetFrameLevel() - 1)
	Buttons:SetAlpha(0)
	Buttons.num = 0
	Buttons.reanchor = false
	KTF.Buttons = Buttons

	-- Keybinding
	local BindingButton = CreateFrame("Button", "KT_BindingButton", UIParent)
	BindingButton:SetScript("OnClick", function(self, btn)
		KT:Tracker_SetHidden()
	end)

	-- Frame resets
	local null = function() end

	OTF.Show = null
	OTF.Hide = null
	OTF.SetShown = null
	OTF.SetSize = null
	OTF.SetWidth = null
	OTF.SetHeight = null
	OTF.SetParent = null
	OTF.SetPoint = null
	OTF.SetAllPoints = null
	OTF.ClearAllPoints = null
	OTF.SetScale = null
	OTF.SetAlpha = null
	OTF.SetFrameStrata = null
	OTF.SetFrameLevel = null
	OTF:SetClampedToScreen(false)
	OTF.SetClampedToScreen = null
	OTF:EnableMouse(false)
	OTF.EnableMouse = null
	OTF:SetMovable(false)
	OTF.SetMovable = null

	KTF.Show = null
	KTF.Hide = null
	KTSetShown = KTF.SetShown
	KTF.SetShown = null
	KTF.SetSize = null
	KTSetWidth = KTF.SetWidth
	KTF.SetWidth = null
	KTSetHeight = KTF.SetHeight
	KTF.SetHeight = null
	KTF.SetParent = null
	KTSetPoint = KTF.SetPoint
	KTF.SetPoint = null
	KTF.SetAllPoints = null
	KTClearAllPoints = KTF.ClearAllPoints
	KTF.ClearAllPoints = null
	KTSetScale = KTF.SetScale
	KTF.SetScale = null
	KTSetAlpha = KTF.SetAlpha
	KTF.SetAlpha = null
	KTSetFrameStrata = KTF.SetFrameStrata
	KTF.SetFrameStrata = null
	KTF.SetFrameLevel = null
	KTF.SetClampedToScreen = null
	KTF.EnableMouse = null
end

-- Hooks ---------------------------------------------------------------------------------------------------------------

local function SetHooks()
	local bck_KT_ObjectiveTrackerContainerMixin_Update = KT_ObjectiveTrackerContainerMixin.Update
	function KT_ObjectiveTrackerContainerMixin:Update(dirtyUpdate)
		if KT.stopUpdate then return end

		bck_KT_ObjectiveTrackerContainerMixin_Update(self, dirtyUpdate)

		KT.QuestButtons_Reanchor()
		KT:SendSignal("BUTTONS_UPDATED")
		Tracker_ShowHeader()
		KT:Tracker_ToggleEmpty()
		KT:Tracker_SetSize()
	end

	hooksecurefunc(OTF.Header, "SetCollapsed", function(self, collapsed)
		local texture = KTF.MinimizeButton:GetNormalTexture()
		if collapsed then
			_DBG("COLLAPSE", true)
			texture:SetTexCoord(0, 0.5, 0, 0.25)
			KT.Scenario:ExternalFrames_Hide()
		else
			_DBG("EXPAND", true)
			texture:SetTexCoord(0, 0.5, 0.25, 0.5)
		end
		MSA_CloseDropDownMenus()
	end)

	hooksecurefunc(KT_ObjectiveTrackerModuleHeaderMixin, "SetCollapsed", function(self, collapsed)
		local texture = self.Icon
		if collapsed then
			texture:SetTexCoord(0, 0.5, 0.75, 1)
		else
			texture:SetTexCoord(0.5, 1, 0.75, 1)
		end
	end)
	Default_SetChangedMixin(KT_ObjectiveTrackerModuleHeaderMixin, "Header", "SetCollapsed")

	local bck_KT_ObjectiveTrackerModuleMixin_MarkDirty = KT_ObjectiveTrackerModuleMixin.MarkDirty
	function KT_ObjectiveTrackerModuleMixin:MarkDirty()
		if KT.stopUpdate then return end

		bck_KT_ObjectiveTrackerModuleMixin_MarkDirty(self)
	end
	Default_SetChangedMixin(KT_ObjectiveTrackerModuleMixin, nil, "MarkDirty")

	hooksecurefunc(KT_ObjectiveTrackerModuleMixin, "SetNeedsFanfare", function(self, key)
		if KT.stopUpdate and key then
			self.fanfares[key] = nil
		end
	end)
	Default_SetChangedMixin(KT_ObjectiveTrackerModuleMixin, nil, "SetNeedsFanfare")

	function KT_ObjectiveTrackerModuleMixin:OnBlockHeaderLeave(block)
		if db.tooltipShow then
			GameTooltip:Hide()
		end
	end
	Default_SetChangedMixin(KT_ObjectiveTrackerModuleMixin, nil, "OnBlockHeaderLeave", "KT_AchievementObjectiveTracker", "KT_MonthlyActivitiesObjectiveTracker", "KT_InitiativeTasksObjectiveTracker", "KT_ProfessionsRecipeTracker")

	function KT_ObjectiveTrackerBlockMixin:AddObjective(objectiveKey, text, template, useFullHeight, dashStyle, colorStyle, adjustForNoText, overrideHeight)  -- RO
		if objectiveKey == "TimeLeft" then
			text, colorStyle = GetTaskTimeLeftData(self.id)
		end

		if self.parentModule.NormalizeObjective then
			text, dashStyle = self.parentModule:NormalizeObjective(text, dashStyle)
		end

		local _, _, leftText, colon, progress, numHave, numNeed, rightText = strfind(text, "(.-)(%s?:?%s?)((%d+)%s?/%s?(%d+))(.*)")
		if progress then
			if tonumber(numHave) > 0 and tonumber(numHave) < tonumber(numNeed) then
				progress = "|cffc8c800" .. progress .. "|r"
			end
			if not db.questsObjectiveNumAtStart then
				text = leftText .. colon .. progress .. rightText
			else
				text = progress
				if rightText ~= " " then
					text = text .. rightText
				end
				if leftText ~= "" then
					text = text .. " " .. leftText
				end
			end
		end

		local line = self:GetLine(objectiveKey, template);

		line.progressBar = nil;

		-- dash
		if line.Dash then
			if not dashStyle then
				dashStyle = KT_OBJECTIVE_DASH_STYLE_SHOW;
			end
			if line.dashStyle ~= dashStyle then
				if dashStyle == KT_OBJECTIVE_DASH_STYLE_SHOW then
					line.Dash:Show();
					line.Dash:SetText(KT.QUEST_DASH);
				elseif dashStyle == KT_OBJECTIVE_DASH_STYLE_HIDE then
					line.Dash:Hide();
					line.Dash:SetText(KT.QUEST_DASH);
				elseif dashStyle == KT_OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE then
					line.Dash:Hide();
					line.Dash:SetText(nil);
				else
					assertsafe(false, "Invalid dash style: " .. tostring(dashStyle));
				end
				line.dashStyle = dashStyle;
			end
			if line.Dash.KTskinID ~= KT.skinID then
				line.Dash:SetFont(KT.font, db.fontSize, db.fontFlag)
				line.Dash:SetShadowColor(0, 0, 0, db.fontShadow)
				line.Dash.KTskinID = KT.skinID
			end
		end

		-- check
		if line.Icon and line.Icon.KTskinID ~= KT.skinID then
			line.Icon:SetSize(db.fontSize, db.fontSize)
			line.Icon:ClearAllPoints()
			line.Icon:SetPoint("TOPLEFT", KT.round(db.fontSize * -0.4) + (db.fontFlag == "" and 0 or 1), 0)
			line.Icon.KTskinID = KT.skinID
		end

		local lineSpacing = self.parentModule.lineSpacing;
		local offsetY = -lineSpacing;

		-- anchor the line
		local anchor = self.lastRegion or self.HeaderText;
		if anchor then
			line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, offsetY);
		else
			line:SetPoint("TOPLEFT", 0, offsetY);
		end
		line:SetPoint("RIGHT", self.rightEdgeOffset, 0);

		-- set the text
		local textHeight = self:SetStringText(line.Text, text, useFullHeight, colorStyle, self.isHighlighted or line.isHighlighted);  -- MSA
		local height = overrideHeight and max(overrideHeight,  textHeight) or textHeight;  -- MSA
		line:SetHeight(height);

		self.height = self.height + height + lineSpacing;

		self.lastRegion = line;

		-- completion state
		if KT.inWorld and type(objectiveKey) == "string" then
			local state = KT.QuestsCache_GetProperty(self.id, "state")
			if strfind(objectiveKey, "Complete") then
				if not state or state ~= "complete" then
					if db.messageQuest then
						KT:SetMessage(self.title, 0, 1, 0, ERR_QUEST_COMPLETE_S, "Interface\\GossipFrame\\ActiveQuestIcon", -2, 0)
					end
					if db.soundQuest then
						KT:PlaySound(db.soundQuestComplete)
					end
					KT.QuestsCache_UpdateProperty(self.id, "state", "complete")
				end
			elseif strfind(objectiveKey, "Failed") then
				if not state or state ~= "failed" then
					if db.messageQuest then
						KT:SetMessage(self.title, 1, 0, 0, ERR_QUEST_FAILED_S, "Interface\\GossipFrame\\AvailableQuestIcon", -2, 0)
					end
					KT.QuestsCache_UpdateProperty(self.id, "state", "failed")
				end
			end
		end

		return line;
	end

	function KT_ObjectiveTrackerBlockMixin:SetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)  -- RO
		if fontString.KTskinID ~= KT.skinID then
			fontString:SetFont(KT.font, db.fontSize, db.fontFlag)
			fontString:SetShadowColor(0, 0, 0, db.fontShadow)
			fontString:SetWordWrap(db.textWordWrap)
			fontString.KTskinID = KT.skinID
		end

		if useFullHeight then
			fontString:SetMaxLines(0);
		else
			fontString:SetMaxLines(2);
		end
		fontString:SetHeight(0);	-- force a clear of internals or GetHeight() might return an incorrect value

		-- fix Blizz bug
		local origWidth = fontString:GetWidth()
		fontString:SetWidth(origWidth + 2)

		fontString:SetText(text);

		local stringHeight = fontString:GetHeight();
		colorStyle = colorStyle or KT_OBJECTIVE_TRACKER_COLOR["Normal"];
		if useHighlight and colorStyle.reverse then
			colorStyle = colorStyle.reverse;
		end
		if fontString.colorStyle ~= colorStyle then
			fontString:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
			fontString.colorStyle = colorStyle;
		end
		return stringHeight;
	end

	function KT_ObjectiveTrackerBlockMixin:UpdateHighlight()
		KT.KT_ObjectiveTrackerBlockMixin.UpdateHighlight(self)

		local colorStyle, colorStyleTag, _
		if self.parentModule == KT_QuestObjectiveTracker or self.parentModule == KT_CampaignQuestObjectiveTracker then
			if self.isHighlighted then
				if self.questCompleted then
					colorStyle = KT_OBJECTIVE_TRACKER_COLOR["CompleteHighlight"]
				elseif db.questsColorByDifficulty then
					_, colorStyle = GetQuestDifficultyColor(self.level)
				end
				colorStyleTag = KT_OBJECTIVE_TRACKER_COLOR["NormalHighlight"]
			else
				if self.questCompleted then
					colorStyle = KT_OBJECTIVE_TRACKER_COLOR["Complete"]
				elseif db.questsColorByDifficulty then
					colorStyle = GetQuestDifficultyColor(self.level)
				end
				colorStyleTag = KT_OBJECTIVE_TRACKER_COLOR["Normal"]
			end
		end
		if colorStyle then
			self.HeaderText:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
			self.HeaderText.colorStyle = colorStyle
		end

		if self.fixedTag then
			if self.isHighlighted then
				colorStyleTag = KT_OBJECTIVE_TRACKER_COLOR["NormalHighlight"]
			else
				colorStyleTag = KT_OBJECTIVE_TRACKER_COLOR["Normal"]
			end
			self.fixedTag:SetBackdropColor(colorStyleTag.r, colorStyleTag.g, colorStyleTag.b)
			self.fixedTag.text:SetTextColor(colorStyleTag.r, colorStyleTag.g, colorStyleTag.b)
		end
	end

	function KT_ObjectiveTrackerBlockMixin:SetHeader(text, questID, isQuestComplete, quest)
		local isTask = questID and QuestUtil.IsQuestTrackableTask(questID)
		if questID and not isTask then
			text = CreateQuestTags(quest)..text
			self.level = quest.level
            KT.T_Set("level", self.level, self.parentModule.name, "block")
			self.title = text
            KT.T_Set("title", self.title, self.parentModule.name, "block")
			self.questCompleted = isQuestComplete
            KT.T_Set("questComplete", self.questCompleted, self.parentModule.name, "block")
		end

		KT.KT_ObjectiveTrackerBlockMixin.SetHeader(self, text)

		local colorStyle
		if self.parentModule == KT_QuestObjectiveTracker or self.parentModule == KT_CampaignQuestObjectiveTracker then
			if self.questCompleted then
				colorStyle = KT_OBJECTIVE_TRACKER_COLOR["Complete"]
			elseif db.questsColorByDifficulty then
				colorStyle = GetQuestDifficultyColor(self.level)
			end
		end
		if colorStyle then
			self.HeaderText:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
			self.HeaderText.colorStyle = colorStyle
		end

		if questID then
			if not isTask then
				local questsCache = dbChar.quests.cache
                KT.T_Set("cache", questsCache[questID], self.parentModule.name, "questData")
				if db.questsShowZone and questsCache[questID] then
					local infoText = questsCache[questID].zone
					if infoText then
						if questsCache[questID].isCalling then
							local timeRemaining = GetTaskTimeLeftData(questID)
							if timeRemaining ~= "" then
								infoText = infoText.." - "..timeRemaining
							end
						end
						self:AddObjective("Zone", infoText, nil, nil, KT_OBJECTIVE_DASH_STYLE_HIDE, KT_OBJECTIVE_TRACKER_COLOR["Zone"])
					end
				end
			else
				if db.tasksShowFaction then
					local _, factionID, capped = C_TaskQuest.GetQuestInfoByQuestID(questID)
					local factionData = factionID and C_Reputation.GetFactionDataByID(factionID)
					local factionColor = KT_OBJECTIVE_TRACKER_COLOR["Zone"]
					if factionData then
						local reputationYieldsRewards = not capped or C_Reputation.IsFactionParagon(factionID)
						if not reputationYieldsRewards then
							factionColor = KT_OBJECTIVE_TRACKER_COLOR["Inactive"]
						end
						self:AddObjective("Faction", factionData.name, nil, nil, KT_OBJECTIVE_DASH_STYLE_HIDE, factionColor)
					end
				end
			end
		end
	end

	function KT_ObjectiveTrackerBlockMixin:AddRightEdgeFrame(settings, identifier, ...)
		local frame
		if settings.template == "KT_QuestObjectiveItemButtonTemplate" then
			KT.QuestButtons_Add(self, 3, 4)
			frame = self.ItemButton
        else
            frame = KT.KT_ObjectiveTrackerBlockMixin.AddRightEdgeFrame(self, settings, identifier, ...)
            frame:SetFrameLevel(self:GetFrameLevel() + 1)
		end
		return frame
	end

	function KT_ObjectiveTrackerBlockMixin:AddProgressBar(id, lineSpacing)
		local progressBar = KT.KT_ObjectiveTrackerBlockMixin.AddProgressBar(self, id, lineSpacing)
		KT.ProgressBar_SetStyle(self, progressBar)
		KT.ProgressBar_SetValue(self, progressBar, id)
		return progressBar
	end

	local function SetTimerBarStyle(block, progressBar)
		if progressBar.KTskinID ~= KT.skinID then
			block.height = block.height - progressBar.height

			local barHeight = max(12, db.fontSize + fmod(db.fontSize, 2))
			progressBar:SetSize(240, barHeight)
			progressBar.height = barHeight

			progressBar.Label:SetWidth(0)
			progressBar.Label:SetPoint("LEFT", KT.dashWidth, 1)
			progressBar.Label:SetFont(LSM:Fetch("font", "Arial Narrow"), db.fontSize, db.fontFlag)
			progressBar.Label:SetText("00:00")
			local labelWidth = progressBar.Label:GetWidth() + 10
			progressBar.Label:SetText()
			progressBar.Label:SetWidth(labelWidth)

			progressBar.Bar:SetSize(205 - KT.dashWidth - labelWidth, 8)
			progressBar.Bar:EnableMouse(false)
			progressBar.Bar:ClearAllPoints()
			progressBar.Bar:SetPoint("LEFT", progressBar.Label, "RIGHT", 0, 0)
			progressBar.Bar.BorderLeft:Hide()
			progressBar.Bar.BorderRight:Hide()
			progressBar.Bar.BorderMid:Hide()

			local border1 = progressBar.Bar:CreateTexture(nil, "BACKGROUND", nil, -2)
			border1:SetPoint("TOPLEFT", -1, 1)
			border1:SetPoint("BOTTOMRIGHT", 1, -1)
			border1:SetColorTexture(0, 0, 0)

			local border2 = progressBar.Bar:CreateTexture(nil, "BACKGROUND", nil, -3)
			border2:SetPoint("TOPLEFT", -2, 2)
			border2:SetPoint("BOTTOMRIGHT", 2, -2)
			border2:SetColorTexture(0.4, 0.4, 0.4)

			progressBar.Bar:SetStatusBarTexture(LSM:Fetch("statusbar", db.progressBar))
			progressBar.KTskinID = KT.skinID
			progressBar.isSkinned = true  -- ElvUI hack

			block.height = block.height + progressBar.height
		end
	end

	function KT_ObjectiveTrackerBlockMixin:AddTimerBar(duration, startTime)
		local timerBar = KT.KT_ObjectiveTrackerBlockMixin.AddTimerBar(self, duration, startTime)
		SetTimerBarStyle(self, timerBar)
		return timerBar
	end

	function KT_ObjectiveTrackerQuestPOIBlockMixin:AddPOIButton(questID, isComplete, isSuperTracked, isWorldQuest)  -- R
		local style
		if self.poiInfo then
			style = KT_POIButtonUtil.Style[self.poiInfo.areaPoiID and "AreaPOI" or "BonusObjective"]
		elseif self.poiIsWorldQuest then
			style = KT_POIButtonUtil.Style.WorldQuest
		elseif self.poiIsComplete then
			style = KT_POIButtonUtil.Style.QuestComplete
		else
			style = KT_POIButtonUtil.Style.QuestInProgress
		end
		local poiButton = self:GetPOIButton(style)
		poiButton:SetPoint("TOPRIGHT", self.HeaderText, "TOPLEFT", -7, 3)
		poiButton:SetPingWorldMap(isWorldQuest)
	end

	function KT_ObjectiveTracker_ToggleDropDown(frame, handlerFunc)
		local dropDown = KT.DropDown;
		if ( dropDown.activeFrame ~= frame ) then
			MSA_CloseDropDownMenus();
		end
		dropDown.activeFrame = frame;
		dropDown.initialize = handlerFunc;
		MSA_ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	-- POIButton.lua
	hooksecurefunc(KT_POIButtonMixin, "UpdateButtonStyle", function(self)
		self.questTagInfo = nil  -- fix Blizz bug
		if self.Display.SubTypeIcon and self.hideSubTypeIcon then
			self.Display.SubTypeIcon:Hide()
		end
		self.Glow:SetShown(false)
	end)

	-- ContentTrackingManager.lua
	local function OnContentTrackingUpdate(self, trackableType, id, isTracked)
		-- Assume other types don't need bespoke behavior (Enum.ContentTrackingType.Appearance, Enum.ContentTrackingType.Mount, Enum.ContentTrackingType.Decor)
		if trackableType ~= Enum.ContentTrackingType.Achievement then
			KT_AdventureObjectiveTracker:MarkDirty()
		end
	end

	local function OnContentTrackingToggled(self, isEnabled)
		KT_AdventureObjectiveTracker:MarkDirty()
	end

	EventRegistry:RegisterFrameEventAndCallback("CONTENT_TRACKING_UPDATE", OnContentTrackingUpdate, KT)
	EventRegistry:RegisterFrameEventAndCallback("CONTENT_TRACKING_IS_ENABLED_UPDATE", OnContentTrackingToggled, KT)

	-- GossipFrame.lua
	hooksecurefunc(GossipFrame, "HandleShow", function(self, textureKit)
		local gossipQuests = C_GossipInfo.GetActiveQuests()
		for _, questInfo in ipairs(gossipQuests) do
			KT.QuestsCache_UpdateProperty(questInfo.questID, "startMapID", KT.GetCurrentMapAreaID())
		end
		KT:SendSignal("QUEST_DATA_CHANGED")
	end)

	-- QuestFrame.lua
	QuestFrame:HookScript("OnShow", function(self)
		local questID = GetQuestID()
		KT.QuestsCache_UpdateProperty(questID, "startMapID", KT.GetCurrentMapAreaID())
		KT:SendSignal("QUEST_DATA_CHANGED")
	end)

	-- SplashFrame.lua
	hooksecurefunc(SplashFrame, "SetupFrame", function(self, screenInfo)
		if screenInfo then
			OTF:Update()
		end
	end)

	hooksecurefunc(SplashFrame, "OpenQuestDialog", function(self)
		local questID = self.RightFeature.questID
		KT_QuestObjectiveTracker:RemoveAutoQuestPopUp(questID)
	end)

	SplashFrame:HookScript("OnHide", function(self)
		OTF:ForceExpand()
		OTF:Update()
	end)

	-- UIErrorsFrame.lua
	local bck_UIErrorsFrame_OnEvent = UIErrorsFrame:GetScript("OnEvent")
	UIErrorsFrame:SetScript("OnEvent", function(self, event, ...)
		if db.messageQuest and event == "UI_INFO_MESSAGE" then
			local text, _ = ...
			for _, patt in ipairs(msgPatterns) do
				if strfind(text, patt) then
					KT:SetMessage(text, 1, 1, 0, nil, "Interface\\GossipFrame\\AvailableQuestIcon", -2, 0)
					return
				end
			end
		end
		bck_UIErrorsFrame_OnEvent(self, event, ...)
	end)

	-- Update Mixins
	Default_UpdateMixins()
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
	if not ignoreHideEmpty and db.hideEmptyTracker and not Tracker_HasContent() then return end

	if hidden == nil then
		self.hidden = not self.hidden
	else
		self.hidden = hidden
	end
	_DBG((self.hidden and "HIDE" or "SHOW").." ... collapsed: "..tostring(dbChar.collapsed), true)
	self.locked = self.hidden
	OTF:SetCollapsed(self.hidden or dbChar.collapsed)
end

---Set module collapsed or expanded.
---@param module table Module object
---@param collapsed boolean|nil Collapsed state (true = collapse, false = expand, nil = toggle)
---@param silent boolean|nil If true, does not save collapsed state
function KT:Module_SetCollapsed(module, collapsed, silent)
	if collapsed == nil then
		module:ToggleCollapsed()
	else
		module:SetCollapsed(collapsed)
	end
	if not silent then
		dbChar.collapsedModules[module.name] = module.isCollapsed
	end
end

---Get module collapsed state.
---@param module table Module object
---@return boolean True is collapsed, false is expanded
function KT:Module_IsCollapsed(module)
	return module:IsCollapsed()
end

---Expand module only if it is currently collapsed.
---@param module table Module object
function KT:Module_Expand(module)
	if self:Module_IsCollapsed(module) then
		self:Module_SetCollapsed(module, false)
	end
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

function KT:ModuleHeader_OnClick(module)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	self:Module_SetCollapsed(module)
end

function KT:Tracker_SetSize(forced)
	local height = KTF.headerHeight + (2 * KTF.borderSpace)
	local mod = 0

	if not OTF.contentsHeight then
		return
	end

	_DBG(" - height = "..OTF.contentsHeight)
	if not self:Tracker_IsCollapsed() and Tracker_HasContent() then
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
	KTF.Buttons:SetShown(show)
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
	if self.Filters:IsEnabled() then
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
	self.Scenario:Module_SetText()
end

function KT:Tracker_SetHeaderButtons(numAddButtons)
	local buttonSpace = 20
	KTF.HeaderButtons.num = KTF.HeaderButtons.num + numAddButtons
	KTF.HeaderButtons:SetWidth((KTF.HeaderButtons.num * buttonSpace) + 11)
	OTFHeader.Text:SetWidth(OTFHeader.Text:GetWidth() - (numAddButtons * buttonSpace))
end

function KT:Module_SetHeader(module)
	if not module.Header then return end

	module.Header.Text.ClearAllPoints = function() end
	module.Header.Text:SetPoint("LEFT", 10, 1)
	module.Header.Text.SetPoint = function() end
	module.Header.PlayAddAnimation = function() end
	module.Header.MinimizeButton:SetShown(false)
	module.Header.MinimizeButton.SetShown = function() end
	module.Header:SetScript("OnMouseUp", function()
		KT:ModuleHeader_OnClick(module)
	end)
	tinsert(KT.headers, module.Header)

	-- Module collapse icon
	local icon = module.Header:CreateTexture(nil, "ARTWORK")
	icon:SetSize(16, 16)
	icon:SetTexture(KT.MEDIA_PATH.."UI-KT-HeaderButtons")
	icon:SetTexCoord(0.5, 1, 0.75, 1)
	icon:SetPoint("LEFT", -6, 2)
	module.Header.Icon = icon
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
	if not Tracker_HasContent() or self.hidden then
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
	if self.Filters:IsEnabled() then
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

function KT:MergeTables(source, target)
	if type(target) ~= "table" then target = {} end
	for k, v in pairs(source) do
		if type(v) == "table" then
			target[k] = self:MergeTables(v, target[k])
		elseif target[k] == nil then
			target[k] = v
		end
	end
	return target
end

-- ---------------------------------------------------------------------------------------------------------------------

function KT:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)

	SLASH_KALIELSTRACKER1, SLASH_KALIELSTRACKER2 = "/kt", "/kalielstracker"
	SlashCmdList["KALIELSTRACKER"] = SlashHandler

	SetMsgPatterns()

	-- Get character data
	self.playerName = UnitName("player")
	self.playerFaction = UnitFactionGroup("player")
	self.playerLevel = UnitLevel("player")
	local className, classFile = UnitClass("player")
	self.playerClass = className
	self.classColor = RAID_CLASS_COLORS[classFile]

	-- Tracker data
	self.headers = {}
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
    self.combatLockdown = InCombatLockdown()
	self.initialized = false

	self:Config_Init()
	self:Storage_Init()
end

function KT:OnEnable()
	_DBG("|cff00ff00Enable|r - "..self:GetName(), true)
	db = self.db.profile
	dbChar = self.db.char

	KT:Alert_ResetIncompatibleProfiles("7.0.0")

	self.isTimerunningPlayer = (PlayerGetTimerunningSeasonID() ~= nil)

	self:InitSubsystems({
		Quests = { dbChar.quests.cache },
		Achievements = { KalielsTrackerCache.achievements }
	})

	SetFrames()
	SetHooks()

	self:RegSignal("QUESTS_READY:10", Quests_UpdateCount)
	self:RegSignal("OPTIONS_CHANGED", "Tracker_Update")
	self:RegEvent("PLAYER_ENTERING_WORLD", function(eventID, ...)
		KT.ObjectiveTrackerManager:OnPlayerEnteringWorld(...)
		Init()
		self:UnregEvent(eventID)
	end)

	self:Addon_EnableModules()

	if self.db.global.version ~= self.VERSION then
		self.db.global.version = self.VERSION
	end

	db.modulesOrder = self.ReconcileOrder(self.MODULES, db.modulesOrder)
end