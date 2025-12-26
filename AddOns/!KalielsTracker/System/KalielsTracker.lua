--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

local addonName, addon = ...

---@class KT
local KT = LibStub("MSA-AceAddon-3.0"):NewAddon(addon, addonName, "LibSink-2.0", "MSA-Event-1.0", "MSA-ProtRouter-1.0", "MSA-EditMode-1.0")
KT:SetDefaultModuleState(false)

local LSM = LibStub("LibSharedMedia-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local floor = math.floor
local fmod = math.fmod
local format = string.format
local gsub = string.gsub
local ipairs = ipairs
local max = math.max
local pairs = pairs
local strfind = string.find
local tonumber = tonumber
local tinsert = table.insert
local tremove = table.remove
local tContains = tContains
local unpack = unpack

-- WoW API
local _G = _G
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local HaveQuestRewardData = HaveQuestRewardData
local InCombatLockdown = InCombatLockdown
local FormatLargeNumber = FormatLargeNumber
local UIParent = UIParent

local testLine
local freeIcons = {}
local freeTags = {}
local freeButtons = {}
local msgPatterns = {}
local tooltipUpdateQuestID = 0
local combatLockdown = false
local db, dbChar

-- Main frame
local KTF = CreateFrame("Frame", addonName.."Frame", UIParent)
KT.frame = KTF

-- Blizzard frame
local OTF = KT_ObjectiveTrackerFrame
local OTFHeader = OTF.Header
local MawBuffs = KT_ScenarioObjectiveTracker.MawBuffsBlock.Container
local UIWidgetBaseScenarioHeaderText

local KTSetShown, KTSetWidth, KTSetHeight, KTSetPoint, KTClearAllPoints, KTSetScale, KTSetFrameStrata, KTSetAlpha, KTBSetPoint

-- Prototype -----------------------------------------------------------------------------------------------------------

---@type KT|Options|Hacks|Filters|Events|QuestLog|ActiveButton|AddonPetTracker|AddonTomTom|AddonRareScanner|AddonOthers|Help
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

local function Default_SetChangedMixin(name, ...)
	tinsert(changedMixins, {
		name = name,
		modules = { ... }
	})
end

local function Default_UpdateMixins()
	for _, mixin in ipairs(changedMixins) do
		local modules = #mixin.modules > 0 and mixin.modules or KT.MODULES
		for _, module in ipairs(modules) do
			_G[module][mixin.name] = KT_ObjectiveTrackerModuleMixin[mixin.name]
		end
	end

	for k, v in pairs(KT_ObjectiveTrackerBlockMixin) do
		KT_ScenarioObjectiveTracker.ObjectivesBlock[k] = v
	end
end

local function HasTrackerContents()
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

local function ShowTrackerHeader()
	local show = (not KT:IsCollapsed() and HasTrackerContents()) or db.hdrCollapsedTxt > 1
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
		ShowTrackerHeader()

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
		KT:SetHidden()
	else
		KT:MinimizeButton_OnClick()
	end
end

local function SetScrollbarPosition()
	local xOffset = -5
	local yOffset = -5
	local scrollRange = OTF.height - db.maxHeight
	if scrollRange > 0 then
		local barSpace = 60  -- 50 + 2×5
		local usableHeight = db.maxHeight - barSpace
		local scrollRatio = KTF.Scroll.value / scrollRange
		yOffset = -1 * KT.round(5 + (usableHeight * scrollRatio))
	end
	KTF.Bar:SetPoint("TOPRIGHT", xOffset, yOffset)
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

local function GetBlockIcon(block)
	local icon = block.icon
	if not icon then
		local numFreeIcons = #freeIcons
		if numFreeIcons > 0 then
			icon = freeIcons[numFreeIcons]
			tremove(freeIcons, numFreeIcons)
			icon:ClearAllPoints()
		else
			icon = CreateFrame("Frame", nil, OTF.BlocksFrame, "KT_ObjectiveTrackerBlockIconTemplate")
		end
		icon:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", 1, 8)
		block.icon = icon
	end
	icon:Show()
	return icon
end

local function RemoveBlockIcon(block)
	local icon = block.icon
	if icon then
		tinsert(freeIcons, icon)
		icon:Hide()
		block.icon = nil
	end
end

local function ModuleMinimize_OnClick(module)
	module:ToggleCollapsed()
	local icon = module.Header.Icon
	if module:IsCollapsed() then
		icon:SetTexCoord(0, 0.5, 0.75, 1)
	else
		icon:SetTexCoord(0.5, 1, 0.75, 1)
	end
end

-- Init ----------------------------------------------------------------------------------------------------------------

local function Init()
	KT:SendSignal("INIT")

	for i, moduleName in ipairs(db.modulesOrder) do
		local module = _G[moduleName]
		module.uiOrder = i
		KT:SetModuleHeader(module)
	end

	KT:MoveTracker()
	KT:SetBackground()
	KT:SetText(true)
	KT:SendSignal("OPTIONS_CHANGED")

	KT.stopUpdate = false
	KT.inWorld = true

	C_Timer.After(0, function()
		KT:SetQuestsHeaderText()
		KT:SetAchievsHeaderText()

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
					KT:RemoveFixedButton(KT_ScenarioObjectiveBlock.spells[i])
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
				dbChar.quests.num = KT.QuestsCache_Update()
				KT:SetQuestsHeaderText()

				KT.QuestsCache_UpdateProperty(questID, "startMapID", KT.GetCurrentMapAreaID())
				KT.QuestsCache_UpdateProperty(questID, "updateTime", time())
			end
		elseif event == "QUEST_REMOVED" then
			local questID = ...
			if not C_QuestLog.IsQuestTask(questID) and not C_QuestLog.IsQuestBounty(questID) then
				KT.QuestsCache_RemoveQuest(questID)

				dbChar.quests.num = KT.QuestsCache_Update()
				KT:SetQuestsHeaderText()

				if db.questAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
					KT.QuestSuperTracking_ChooseClosestQuest()
				end
			end
		elseif event == "QUEST_TURNED_IN" then
			if db.questAutoFocusClosest then
				KT.QuestSuperTracking_ChooseClosestQuest()
			end
		elseif event == "QUEST_WATCH_UPDATE" then
			local questID = ...
			KT.QuestsCache_UpdateProperty(questID, "updateTime", time())
		elseif event == "ACHIEVEMENT_EARNED" then
			KT:SetAchievsHeaderText()
		elseif event == "PLAYER_REGEN_ENABLED" and combatLockdown then
			combatLockdown = false
			KT:RemoveFixedButton()
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
				KT:Update()
			end)
		elseif event == "QUEST_POI_UPDATE" then
			dbChar.quests.num = KT.GetNumQuests()
			KT:SetQuestsHeaderText()
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
	KTF:RegisterEvent("QUEST_POI_UPDATE")
	KTF:RegisterEvent("ACHIEVEMENT_EARNED")
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
			KT:Update()
		elseif IsAltKeyDown() then
			KT:OpenOptions()
		elseif HasTrackerContents() and not KT.locked then
			KT:MinimizeButton_OnClick()
		end
	end)
	button:SetScript("OnEnter", function(self)
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local title = KT.TITLE..((db.keyBindCollapse ~= "") and NORMAL_FONT_COLOR_CODE.." ("..db.keyBindCollapse..")|r" or "")
		GameTooltip:AddLine("任務追蹤清單增強", 1, 1, 1)
		GameTooltip:AddLine("右鍵: 將最近的任務設為專注", 0.5, 0.5, 0.5)
		GameTooltip:AddLine("Alt+左鍵: 設定選項", 0.5, 0.5, 0.5)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function(self)
		self:GetNormalTexture():SetVertexColor(KT.hdrBtnColor.r, KT.hdrBtnColor.g, KT.hdrBtnColor.b)
		GameTooltip:Hide()
	end)
	KTF.MinimizeButton = button
	KT:SetHeaderButtons(1)

	-- Scroll frame
	local Scroll = CreateFrame("ScrollFrame", addonName.."Scroll", KTF)
	Scroll:SetPoint("TOPLEFT", KTF.borderSpace, KTF.borderSpace * -1)
	Scroll:SetPoint("BOTTOMRIGHT", KTF.borderSpace * -1, KTF.borderSpace)
    Scroll:SetClipsChildren(true)
	Scroll:EnableMouseWheel(true)
	Scroll.step = 20
	Scroll.value = 0
	Scroll:SetScript("OnMouseWheel", function(self, delta)
		if not KT:IsCollapsed() and OTF.height > db.maxHeight then
			if delta < 0 then
				self.value = (self.value+self.step < OTF.height-db.maxHeight) and self.value + self.step or OTF.height - db.maxHeight
			else
				self.value = (self.value-self.step > 0) and self.value - self.step or 0
			end
			self:SetVerticalScroll(self.value)
			if db.frameScrollbar then
				SetScrollbarPosition()
			end
			if self.value >= 0 and self.value < OTF.height-db.maxHeight then
				MSA_CloseDropDownMenus()
				MawBuffs.List:Hide()
			end
			_DBG("SCROLL ... "..self.value.." ... "..OTF.height.." - "..db.maxHeight)
		end
	end)
	KTF.Scroll = Scroll

	-- Scroll child frame
	local Child = CreateFrame("Frame", addonName.."ScrollChild", KTF.Scroll)
	Child:SetSize(db.width - 8, 8000)
	KTF.Scroll:SetScrollChild(Child)
	KTF.Child = Child

	-- Scroll indicator
	local Bar = CreateFrame("Frame", addonName.."ScrollBar", KTF)
	Bar:SetSize(2, 50)
	Bar:SetPoint("TOPRIGHT", -5, -5)
	Bar:SetFrameLevel(KTF:GetFrameLevel() + 10)
	Bar.texture = Bar:CreateTexture()
	Bar.texture:SetAllPoints()
	Bar:Hide()
	KTF.Bar = Bar

	-- Blizzard frames
	OTF:ClearAllPoints()
	OTF:SetParent(Scroll)
	OTF:SetPoint("TOPLEFT", Child, "TOPLEFT", 20, 0)
	OTF:SetPoint("BOTTOMRIGHT", Child)
	OTFHeader.MinimizeButton:Hide()
	OTFHeader.FilterButton:Hide()
	OTFHeader.Text:SetWidth(db.width - 85)
	OTFHeader.Text:SetWordWrap(false)
	-- OTF.headerText = KT.TITLE
	KT_ScenarioObjectiveTracker.fromBlockOffsetY = 0
	KT_ScenarioObjectiveTracker.lineSpacing = 4
	KT_ScenarioObjectiveTracker.ObjectivesBlock.offsetX = 40
	KT_ScenarioObjectiveTracker.ObjectivesBlock.HeaderButton:EnableMouse(false)
	KT_ScenarioObjectiveTracker.StageBlock.offsetX = 22
	KT_ScenarioObjectiveTracker.ProvingGroundsBlock.offsetX = 27
	KT_ScenarioObjectiveTracker.MawBuffsBlock.offsetX = 0
	KT_ScenarioObjectiveTracker.TopWidgetContainerBlock.offsetX = 28
	MawBuffs.List:SetParent(UIParent)
	MawBuffs.List:SetFrameLevel(MawBuffs:GetFrameLevel() - 1)
	MawBuffs.List:SetClampedToScreen(true)
	HelpTip:Hide(MawBuffs, JAILERS_TOWER_BUFFS_TUTORIAL)

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
		KT:SetHidden()
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

	KTBSetPoint = KTF.Buttons.SetPoint
	KTF.Buttons.SetPoint = null
end

-- Hooks ---------------------------------------------------------------------------------------------------------------

local function SetHooks()
	local function SetFixedButton(block, idx, height, yOfs)
		if block.fixedTag and KT.fixedButtons[block.id] then
			idx = idx + 1
			block.fixedTag.text:SetText(idx)
			KT.fixedButtons[block.id].text:SetText(idx)
			KT.fixedButtons[block.id].num = idx
			yOfs = -(height + 7)
			height = height + 26 + 3
			KT.fixedButtons[block.id]:SetPoint("TOP", 0, yOfs)
		end
		return idx, height, yOfs
	end

	local function FixedButtonsReanchor()
		if InCombatLockdown() then
			if KTF.Buttons.num > 0 then
				combatLockdown = true
			end
		else
			if KTF.Buttons.reanchor then
				local questID, block, questLogIndex, yOfs
				local idx = 0
				local contentsHeight = 0
				-- Scenario
				_DBG(" - REANCHOR buttons - Scen", true)
				for spellFrame in KT_ScenarioObjectiveTracker.spellFramePool:EnumerateActive() do
					if spellFrame.SpellButton then
						idx, contentsHeight, yOfs = SetFixedButton(spellFrame, idx, contentsHeight, yOfs)
					end
				end
				-- World Quest items
				_DBG(" - REANCHOR buttons - WQ", true)
				local tasksTable = GetTasksTable()
				for i = 1, #tasksTable do
					questID = tasksTable[i]
					if not QuestUtils_IsQuestWatched(questID) then
						block = KT_WorldQuestObjectiveTracker:GetExistingBlock(questID) or KT_BonusObjectiveTracker:GetExistingBlock(questID)
						if block and block.ItemButton then
							idx, contentsHeight, yOfs = SetFixedButton(block, idx, contentsHeight, yOfs)
						end
					end
				end
				-- TODO: Delete y/n?
				for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
					questID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i)
					if questID then
						block = KT_WorldQuestObjectiveTracker:GetExistingBlock(questID)
						if block and block.ItemButton then
							idx, contentsHeight, yOfs = SetFixedButton(block, idx, contentsHeight, yOfs)
						end
					end
				end
				-- Quest items
				_DBG(" - REANCHOR buttons - Q", true)
				for i = 1, C_QuestLog.GetNumQuestWatches() do
					questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
					block = KT_QuestObjectiveTracker:GetExistingBlock(questID) or KT_CampaignQuestObjectiveTracker:GetExistingBlock(questID)
					if block and block.ItemButton then
						idx, contentsHeight, yOfs = SetFixedButton(block, idx, contentsHeight, yOfs)
					end
				end
				if contentsHeight > 0 then
					contentsHeight = contentsHeight + 7 + 4
				end
				KTF.Buttons:SetHeight(contentsHeight)
				KTF.Buttons.num = idx
				KTF.Buttons.reanchor = false
			end
			if KT:IsCollapsed() or KTF.Buttons.num == 0 then
				KTF.Buttons:Hide()
			else
				KTF.Buttons:SetShown(not KT.locked)
			end
		end
		if KT:IsCollapsed() or KTF.Buttons.num == 0 then
			KTF.Buttons:SetAlpha(0)
		else
			KTF.Buttons:SetAlpha(1)
		end
	end

	-- -----------------------------------------------------------------------------------------------------------------

	local bck_KT_ObjectiveTrackerContainerMixin_Update = KT_ObjectiveTrackerContainerMixin.Update
	function KT_ObjectiveTrackerContainerMixin:Update(dirtyUpdate)
		if KT.stopUpdate then return end

		bck_KT_ObjectiveTrackerContainerMixin_Update(self, dirtyUpdate)

		FixedButtonsReanchor()
		KT:SendSignal("BUTTONS_UPDATED")
		ShowTrackerHeader()
		KT:ToggleEmptyTracker()
		KT:SetSize()
	end

	local bck_KT_ObjectiveTrackerModuleMixin_MarkDirty = KT_ObjectiveTrackerModuleMixin.MarkDirty
	function KT_ObjectiveTrackerModuleMixin:MarkDirty()
		if KT.stopUpdate then return end

		bck_KT_ObjectiveTrackerModuleMixin_MarkDirty(self)
	end
	Default_SetChangedMixin("MarkDirty")

	hooksecurefunc(KT_ObjectiveTrackerModuleMixin, "SetNeedsFanfare", function(self, key)
		if KT.stopUpdate and key then
			self.fanfares[key] = nil
		end
	end)
	Default_SetChangedMixin("SetNeedsFanfare")

	function KT_ObjectiveTrackerBlockMixin:AddObjective(objectiveKey, text, template, useFullHeight, dashStyle, colorStyle, adjustForNoText, overrideHeight)  -- RO
		if objectiveKey == "TimeLeft" then
			text, colorStyle = GetTaskTimeLeftData(self.id)
		end
		if self.parentModule == KT_MonthlyActivitiesObjectiveTracker then
			text = gsub(text, "- ", "")
			dashStyle = KT_OBJECTIVE_DASH_STYLE_SHOW
		end
		local _, _, leftText, colon, progress, numHave, numNeed, rightText = strfind(text, "(.-)(%s?:?%s?)((%d+)%s?/%s?(%d+))(.*)")
		if progress then
			if tonumber(numHave) > 0 and tonumber(numHave) < tonumber(numNeed) then
				progress = "|cffc8c800" .. progress .. "|r"
			end
			if not db.objNumSwitch then
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
		local textHeight = self:SetStringText(line.Text, text, useFullHeight, colorStyle, self.isHighlighted);
		local height = overrideHeight or textHeight;
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
				elseif db.colorDifficulty then
					_, colorStyle = GetQuestDifficultyColor(self.level)
				end
				colorStyleTag = KT_OBJECTIVE_TRACKER_COLOR["NormalHighlight"]
			else
				if self.questCompleted then
					colorStyle = KT_OBJECTIVE_TRACKER_COLOR["Complete"]
				elseif db.colorDifficulty then
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

	local function TooltipPosition(block, xOffsetLeft, yOffsetLeft, xOffsetRight, yOffsetRight, skipSetOwner)
		if not skipSetOwner then
			GameTooltip:SetOwner(block, "ANCHOR_NONE")
		end
		GameTooltip:ClearAllPoints()
		if KTF.anchorLeft then
			GameTooltip:SetPoint("TOPLEFT", block, "TOPRIGHT", db.frameScale * (xOffsetLeft or 19), db.frameScale * (yOffsetLeft or 1))
		else
			GameTooltip:SetPoint("TOPRIGHT", block, "TOPLEFT", db.frameScale * (xOffsetRight or -42), db.frameScale * (yOffsetRight or 1))
		end
	end

	function KT_ObjectiveTrackerModuleMixin:OnBlockHeaderEnter(block)
		if db.tooltipShow and (self == KT_QuestObjectiveTracker or
				self == KT_CampaignQuestObjectiveTracker or
				self == KT_AchievementObjectiveTracker) then
			TooltipPosition(block)

			if self == KT_QuestObjectiveTracker or
					self == KT_CampaignQuestObjectiveTracker then
				local questLink = GetQuestLink(block.id)
				if not questLink then
					return
				end
				GameTooltip:SetHyperlink(questLink)
				if db.tooltipShowRewards then
					if KT.HaveQuestRewardData(block.id) then
						tooltipUpdateQuestID = 0
						KT.GameTooltip_AddQuestRewardsToTooltip(GameTooltip, block.id)
					else
						tooltipUpdateQuestID = block.id
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(KT.RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
						C_Timer.After(0.1, function()
							if tooltipUpdateQuestID == block.id then
								self:OnBlockHeaderEnter(block)
							end
						end)
					end
				end
				if IsInGroup() then
					local tooltipData = C_TooltipInfo.GetQuestPartyProgress(block.id, true)
					if tooltipData then
						GameTooltip:AddLine(" ")
						local tooltipInfo = { tooltipData = tooltipData, append = true }
						GameTooltip:ProcessInfo(tooltipInfo)
					end
				end
			else
				GameTooltip:SetHyperlink(GetAchievementLink(block.id))
			end
			if db.tooltipShowID then
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..block.id)
			end
			GameTooltip:Show()
		end
	end
	Default_SetChangedMixin("OnBlockHeaderEnter", "KT_QuestObjectiveTracker", "KT_CampaignQuestObjectiveTracker", "KT_AchievementObjectiveTracker")

	function KT_ObjectiveTrackerModuleMixin:OnBlockHeaderLeave(block)
		if db.tooltipShow then
			if self == KT_QuestObjectiveTracker or
					self == KT_CampaignQuestObjectiveTracker then
				tooltipUpdateQuestID = 0
			end
			GameTooltip:Hide()
		end
	end
	Default_SetChangedMixin("OnBlockHeaderLeave", "KT_QuestObjectiveTracker", "KT_CampaignQuestObjectiveTracker", "KT_AchievementObjectiveTracker", "KT_MonthlyActivitiesObjectiveTracker", "KT_ProfessionsRecipeTracker")

	function KT_BonusObjectiveBlockMixin:TryShowRewardsTooltip()  -- R
		if db.tooltipShow then
			local questID;
			if self.id < 0 then
				-- this is a scenario bonus objective
				questID = C_Scenario.GetBonusStepRewardQuestID(-self.id);
				if questID == 0 then
					-- huh, no reward
					return;
				end
			else
				questID = self.id;
			end
			local questLink = GetQuestLink(questID)
			if not questLink then
				return
			end

			TooltipPosition(self)

			GameTooltip:SetHyperlink(questLink)
			if db.tooltipShowRewards then
				if not HaveQuestRewardData(questID) then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(KT.RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
					GameTooltip_SetTooltipWaitingForData(GameTooltip, true);
				else
					KT.GameTooltip_AddQuestRewardsToTooltip(GameTooltip, questID, true)
					GameTooltip_SetTooltipWaitingForData(GameTooltip, false);
				end
			end
			if db.tooltipShowID then
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..questID)
			end

			GameTooltip:Show();
			self.hasRewardsTooltip = true;
		end
	end

	function KT_MonthlyActivitiesObjectiveTracker:OnBlockHeaderEnter(block)
		if db.tooltipShow then
			local activityInfo = C_PerksActivities.GetPerksActivityInfo(block.id)
			if activityInfo then
				TooltipPosition(block)

				GameTooltip_SetTitle(GameTooltip, activityInfo.activityName, NORMAL_FONT_COLOR, true)
				GameTooltip:AddLine(" ")

				if activityInfo.description ~= "" then
					GameTooltip:AddLine(activityInfo.description, 1, 1, 1, true)
					GameTooltip:AddLine(" ")
				end

				GameTooltip:AddLine(REQUIREMENTS..":")
				for _, requirement in ipairs(activityInfo.requirementsList) do
					local tooltipLine = requirement.requirementText
					tooltip4Line = string.gsub(tooltipLine, " / ", "/")
					local color = not requirement.completed and WHITE_FONT_COLOR or DISABLED_FONT_COLOR
					GameTooltip:AddLine(tooltipLine, color.r, color.g, color.b)
				end

				if db.tooltipShowRewards then
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(REWARDS..":")
					GameTooltip:AddLine(FormatLargeNumber(activityInfo.thresholdContributionAmount).." "..MONTHLY_ACTIVITIES_POINTS, 1, 1, 1)
				end

				if db.tooltipShowID then
					GameTooltip:AddLine(" ")
					GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..block.id)
				end
				GameTooltip:Show()
			end
		end
	end

	function KT_ProfessionsRecipeTracker:OnBlockHeaderEnter(block)
		if db.tooltipShow then
			TooltipPosition(block)

			local recipeID = KT.GetRecipeID(block)
			GameTooltip:SetRecipeResultItem(recipeID)

			if db.tooltipShowID then
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..recipeID)
			end
			GameTooltip:Show()
		end
	end

	function KT_ObjectiveTrackerBlockMixin:OnEnter()
		self:OnHeaderEnter()
	end

	function KT_ObjectiveTrackerBlockMixin:OnLeave()
		self:OnHeaderLeave()
	end

	function KT_ObjectiveTrackerBlockMixin:OnMouseUp(mouseButton)
		self:OnHeaderClick(mouseButton)
	end

	hooksecurefunc(QuestUtil, "UntrackWorldQuest", function(questID)
		if db.questAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
			KT.QuestSuperTracking_ChooseClosestQuest()
		end
	end)

	local function AddFixedTag(block, tag)
		if block.rightEdgeFrame == tag then
			return
		end

		tag:ClearAllPoints()

		local settings = block.parentModule.questItemButtonSettings
		local spacing = block.parentModule.rightEdgeFrameSpacing
		if block.rightEdgeFrame then
			tag:SetPoint("RIGHT", block.rightEdgeFrame, "LEFT", -spacing, 0)
		else
			tag:SetPoint("TOPRIGHT", block, settings.offsetX + 6, settings.offsetY + 3)
			block:AdjustRightEdgeOffset(settings.offsetX)
		end

		tag:Show()

		block.rightEdgeFrame = tag
		block:AdjustRightEdgeOffset(-tag:GetWidth() - spacing)
		local isManaged = true
		block:OnAddedRegion(tag, isManaged)
	end

	local function CreateFixedTag(block, x, y, anchor)
		local tag = block.fixedTag
		if not tag then
			local numFreeButtons = #freeTags
			if numFreeButtons > 0 then
				tag = freeTags[numFreeButtons]
				tremove(freeTags, numFreeButtons)
				tag:SetParent(block)
				tag:ClearAllPoints()
			else
				tag = CreateFrame("Frame", nil, block, "BackdropTemplate")
				tag:SetSize(32, 32)
				tag:SetBackdrop({ bgFile = KT.MEDIA_PATH.."UI-KT-QuestItemTag" })
				tag.text = tag:CreateFontString(nil, "ARTWORK", "GameFontNormalMed1")
				tag.text:SetFont(LSM:Fetch("font", "Arial Narrow"), 13, "")
				tag.text:SetPoint("CENTER", -0.5, 1)
			end
			block.fixedTag = tag
		end

		if not anchor then
			AddFixedTag(block, tag)
		else
			tag:SetPoint(anchor, block, x, y)
			tag:Show()
		end

		local colorStyle = KT_OBJECTIVE_TRACKER_COLOR["Normal"]
		if block.isHighlighted and colorStyle.reverse then
			colorStyle = colorStyle.reverse
		end
		tag:SetBackdropColor(colorStyle.r, colorStyle.g, colorStyle.b)
		tag.text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
	end

	local function CreateFixedButton(block, isSpell)
		local questID = block.id
		local button = KT:GetFixedButton(questID)
		if not button then
			if InCombatLockdown() then
				_DBG(" - STOP Create button")
				combatLockdown = true
				return nil
			end

			local numFreeButtons = #freeButtons
			if numFreeButtons > 0 then
				_DBG(" - USE button "..questID)
				button = freeButtons[numFreeButtons]
				tremove(freeButtons, numFreeButtons)
			else
				_DBG(" - CREATE button "..questID)
				button = CreateFrame("Button", nil, KTF.Buttons, "SecureActionButtonTemplate")		--"KTQuestObjectiveItemButtonTemplate"
				button:SetSize(26, 26)

				button.icon = button:CreateTexture(nil, "BORDER")
				button.icon:SetAllPoints()
				button.Icon = button.icon   -- for Spell

				button.Count = button:CreateFontString(nil, "BORDER", "NumberFontNormal")
				button.Count:SetJustifyH("RIGHT")
				button.Count:SetPoint("BOTTOMRIGHT", button.icon, 0, 2)

				button.Cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
				button.Cooldown:SetAllPoints()

				button.HotKey = button:CreateFontString(nil, "ARTWORK", "NumberFontNormalSmallGray")
				button.HotKey:SetSize(29, 10)
				button.HotKey:SetJustifyH("RIGHT")
				button.HotKey:SetText(RANGE_INDICATOR)
				button.HotKey:SetPoint("TOPRIGHT", button.icon, 2, -2)

				button.text = button:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
				button.text:SetSize(29, 10)
				button.text:SetJustifyH("LEFT")
				button.text:SetPoint("TOPLEFT", button.icon, 1, -3)

				button:RegisterForClicks("AnyDown", "AnyUp")

				button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
				do local tex = button:GetNormalTexture()
					tex:ClearAllPoints()
					tex:SetPoint("CENTER")
					tex:SetSize(44, 44)
				end
				button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
				button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
				button:SetFrameLevel(KTF:GetFrameLevel() + 1)
				--button:Hide()  -- Cooldown init

				KT:Masque_AddButton(button, 1)
			end
			if not isSpell then
				button:SetScript("OnEvent", KT.ItemButton.OnEvent)
				button:SetScript("OnUpdate", KT.ItemButton.OnUpdate)
				button:SetScript("OnShow", KT.ItemButton.OnShow)
				button:SetScript("OnHide", KT.ItemButton.OnHide)
				button:SetScript("OnEnter", KT.ItemButton.OnEnter)
				button:SetScript("OnLeave", KT.ItemButton.OnLeave)
			else
				button.HotKey:Hide()
				button:SetScript("OnEvent", nil)
				button:SetScript("OnUpdate", nil)
				button:SetScript("OnShow", nil)
				button:SetScript("OnHide", nil)
				button:SetScript("OnEnter", KT.SpellButton.OnEnter)
				button:SetScript("OnLeave", GameTooltip_Hide)
			end
			button:SetAttribute("type", isSpell and "spell" or "item")
			button:Show()
			KT.fixedButtons[questID] = button
			KTF.Buttons.reanchor = true
		end
		button.block = block
		block.ItemButton = button  -- reset inside Core
		button:SetAlpha(1)
		return button
	end

	local function QuestItemButton_Add(block, x, y)
		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(block.id)
		if not questLogIndex then return end

		local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
		if item and (not block.questCompleted or showItemWhenComplete) then
			CreateFixedTag(block, x, y)
			local button = CreateFixedButton(block)
			if not InCombatLockdown() then
				button:SetAttribute("questLogIndex", questLogIndex)
				button:SetAttribute("questID", block.id)
				button.charges = charges
				button.rangeTimer = -1
				button.item = item
				button.link = link
				SetItemButtonTexture(button, item)
				SetItemButtonCount(button, charges)
				KT.ItemButton.UpdateCooldown(button)
				button:SetAttribute("item", link)
			end
		else
			KT:RemoveFixedButton(block)
		end
	end

	KT.ItemButton = {}
	KT.ItemButton.OnEvent = KT_QuestObjectiveItemButtonMixin.OnEvent
	KT.ItemButton.OnShow = KT_QuestObjectiveItemButtonMixin.OnShow
	KT.ItemButton.OnHide = KT_QuestObjectiveItemButtonMixin.OnHide
	KT.ItemButton.UpdateCooldown = KT_QuestObjectiveItemButtonMixin.UpdateCooldown

	function KT_QuestObjectiveItemButtonMixin:OnUpdate(elapsed)  -- R
		local questLogIndex = self:GetAttribute("questLogIndex");
		if not questLogIndex then return end  -- for EditMode

		local rangeTimer = self.rangeTimer
		if rangeTimer then
			rangeTimer = rangeTimer - elapsed
			if rangeTimer <= 0 then
				local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
				if not charges or charges ~= self.charges then
					KT_QuestObjectiveTracker:MarkDirty()
					return
				end
				local count = self.HotKey
				local valid = IsQuestLogSpecialItemInRange(questLogIndex)
				if count:GetText() == RANGE_INDICATOR then
					if valid == 0 then
						count:Show()
						count:SetVertexColor(1.0, 0.1, 0.1)
					elseif valid == 1 then
						count:Show()
						count:SetVertexColor(0.6, 0.6, 0.6)
					else
						count:Hide()
					end
				else
					if valid == 0 then
						count:SetVertexColor(1.0, 0.1, 0.1)
					else
						count:SetVertexColor(0.6, 0.6, 0.6)
					end
				end
				rangeTimer = TOOLTIP_UPDATE_TIME
			end
			self.rangeTimer = rangeTimer
		end
	end
	KT.ItemButton.OnUpdate = KT_QuestObjectiveItemButtonMixin.OnUpdate

	function KT_QuestObjectiveItemButtonMixin:OnEnter()  -- R
		self.block.isHighlighted = true
		self.block:UpdateHighlight()
		if KTF.anchorLeft then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", db.frameScale * 3)
		else
			GameTooltip:SetOwner(self, "ANCHOR_LEFT", db.frameScale * -3)
		end
		local questLogIndex = self:GetAttribute("questLogIndex");
		GameTooltip:SetQuestLogSpecialItem(questLogIndex)
	end
	KT.ItemButton.OnEnter = KT_QuestObjectiveItemButtonMixin.OnEnter

	function KT_QuestObjectiveItemButtonMixin:OnLeave()
		self.block.isHighlighted = false
		self.block:UpdateHighlight()
		GameTooltip:Hide()
	end
	KT.ItemButton.OnLeave = KT_QuestObjectiveItemButtonMixin.OnLeave

	KT.SpellButton = {}

	function KT_ScenarioSpellButtonMixin:OnEnter()  -- R
		if KTF.anchorLeft then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 3)
		else
			GameTooltip:SetOwner(self, "ANCHOR_LEFT", -3)
		end
		GameTooltip:SetSpellByID(self.spellID)
	end
	KT.SpellButton.OnEnter = KT_ScenarioSpellButtonMixin.OnEnter

	function KT_ObjectiveTrackerBlockMixin:SetHeader(text, questID, isQuestComplete, quest)
		local isTask = questID and QuestUtil.IsQuestTrackableTask(questID)
		if questID and not isTask then
			if db.questShowTags then
				local tagInfo = KT.GetQuestTagInfo(questID)
				text = KT:CreateQuestTag(quest.level, tagInfo.tagID, quest.frequency, quest.suggestedGroup)..text
			end
			self.level = quest.level
			self.title = text
			self.questCompleted = isQuestComplete
		end

		KT.KT_ObjectiveTrackerBlockMixin.SetHeader(self, text)

		local colorStyle
		if self.parentModule == KT_QuestObjectiveTracker or self.parentModule == KT_CampaignQuestObjectiveTracker then
			if self.questCompleted then
				colorStyle = KT_OBJECTIVE_TRACKER_COLOR["Complete"]
			elseif db.colorDifficulty then
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
				if db.questShowZones and questsCache[questID] then
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
				if db.taskShowFactions then
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
		if not db.hackLFG and settings.template == "KT_QuestObjectiveFindGroupButtonTemplate" then
			return nil
		end

		local frame
		if settings.template == "KT_QuestObjectiveItemButtonTemplate" then
			QuestItemButton_Add(self, 3, 4)
			frame = self.ItemButton
		else
			frame = KT.KT_ObjectiveTrackerBlockMixin.AddRightEdgeFrame(self, settings, identifier, ...)
			frame:SetFrameLevel(self:GetFrameLevel() + 1)
		end
		return frame
	end

	hooksecurefunc(KT_QuestObjectiveTracker, "OnFreeBlock", function(self, block)
		block.questCompleted = nil
		KT:RemoveFixedButton(block)
		RemoveBlockIcon(block)
	end)
	KT_CampaignQuestObjectiveTracker.OnFreeBlock = KT_QuestObjectiveTracker.OnFreeBlock

	hooksecurefunc(KT_BonusObjectiveTracker, "OnQuestRemoved", function(self, questID)
		local block = self:GetExistingBlock(questID)
		if block then
			KT:RemoveFixedButton(block)
		end
	end)

	hooksecurefunc(KT_BonusObjectiveTracker, "OnQuestTurnedIn", function(self, questID)
		local block = self:GetExistingBlock(questID)
		if block then
			KT:RemoveFixedButton(block)
		end
	end)
	KT_WorldQuestObjectiveTracker.OnQuestTurnedIn = KT_BonusObjectiveTracker.OnQuestTurnedIn

	hooksecurefunc(KT_BonusObjectiveTracker, "OnFreeBlock", function(self, block)
		KT:RemoveFixedButton(block)
	end)
	KT_WorldQuestObjectiveTracker.OnFreeBlock = KT_BonusObjectiveTracker.OnFreeBlock

	local function SetProgressBarStyle(block, progressBar, xOffsetMod)
		if progressBar.KTskinID ~= KT.skinID then
			block.height = block.height - progressBar.height

			progressBar:SetSize(240, 21)
			progressBar.height = 21

			local xOffset = KT.dashWidth + 2
			progressBar.Bar:SetSize(205 - xOffset, 13)
			progressBar.Bar:EnableMouse(false)
			progressBar.Bar:ClearAllPoints()

			if progressBar.Bar.BarFrame then
				-- World Quest / Scenario
				xOffsetMod = xOffsetMod or 0
				progressBar.Bar:SetPoint("LEFT", xOffset + xOffsetMod, 0)
				progressBar.Bar.BarFrame:Hide()
				progressBar.Bar.BarFrame2:Hide()
				progressBar.Bar.BarFrame3:Hide()
				progressBar.Bar.BarGlow:Hide()
				progressBar.Bar.Sheen:Hide()
				progressBar.Bar.Starburst:Hide()
			else
				-- Default
				progressBar.Bar:SetPoint("LEFT", xOffset, 0)
				progressBar.Bar.BorderLeft:Hide()
				progressBar.Bar.BorderRight:Hide()
				progressBar.Bar.BorderMid:Hide()
			end

			local border1 = progressBar.Bar:CreateTexture(nil, "BACKGROUND", nil, -2)
			border1:SetPoint("TOPLEFT", -1, 1)
			border1:SetPoint("BOTTOMRIGHT", 1, -1)
			border1:SetColorTexture(0, 0, 0)

			local border2 = progressBar.Bar:CreateTexture(nil, "BACKGROUND", nil, -3)
			border2:SetPoint("TOPLEFT", -2, 2)
			border2:SetPoint("BOTTOMRIGHT", 2, -2)
			border2:SetColorTexture(0.4, 0.4, 0.4)

			progressBar.Bar.Label:SetPoint("CENTER", 0, 0.5)
			progressBar.Bar.Label:SetFont(LSM:Fetch("font", "Arial Narrow"), 13, "")
			progressBar.Bar:SetStatusBarTexture(LSM:Fetch("statusbar", db.progressBar))
			progressBar.KTskinID = KT.skinID
			progressBar.isSkinned = true  -- ElvUI hack

			block.height = block.height + progressBar.height
		end
	end

	function KT_ObjectiveTrackerBlockMixin:AddProgressBar(id, lineSpacing)
		local progressBar = KT.KT_ObjectiveTrackerBlockMixin.AddProgressBar(self, id, lineSpacing)
		SetProgressBarStyle(self, progressBar)
		return progressBar
	end

	function KT_BonusObjectiveTrackerProgressBarMixin:UpdateReward()  -- R
		self.needsReward = nil
		self.Bar.Icon:Hide()
		self.Bar.IconBG:Hide()
	end

	KT_BonusObjectiveTrackerProgressBarMixin.PlayFlareAnim = function() end
	KT_ScenarioTrackerProgressBarMixin.PlayFlareAnim = function() end

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

	hooksecurefunc(KT_ScenarioObjectiveTracker, "AddSpells", function(self, allSpellInfo)
	 	if not allSpellInfo then return end

		self.ObjectivesBlock.numSpells = #allSpellInfo
		local i = 1
		for spellFrame in self.spellFramePool:EnumerateActive() do
			spellFrame.SpellButton:Hide()
			local spellInfo = allSpellInfo[i]
			spellFrame.id = spellInfo.spellID
			CreateFixedTag(spellFrame, 17, -2, "TOPLEFT")
			local button = CreateFixedButton(spellFrame, true)
			if not InCombatLockdown() then
				button.spellID = spellInfo.spellID
				button.Icon:SetTexture(spellInfo.spellIcon)
				spellFrame.SpellButton.UpdateCooldown(button)
				button:SetAttribute("spell", spellInfo.spellID)
			end
			spellFrame.KTSpellButton = button
			i = i + 1
		end
	end)

	hooksecurefunc(KT_ScenarioObjectiveTracker, "UpdateSpellCooldowns", function(self)
		for spellFrame in self.spellFramePool:EnumerateActive() do
			if spellFrame.KTSpellButton then
				spellFrame.SpellButton.UpdateCooldown(spellFrame.KTSpellButton)
			end
		end
	end)

	-- WidgetSetID:
	-- 461 ... Ember Court
	-- 291 ... Torghast (3302, 11)
	-- 842 ... Delves (6183, 29)
	hooksecurefunc(KT_ScenarioObjectiveTracker.StageBlock, "UpdateStageBlock", function(self, scenarioID, scenarioType, widgetSetID, textureKit, flags, currentStage, stageName, numStages)
		if widgetSetID == 291 then
			self.offsetX = 27
			self.KTtooltipOffsetXmod = 5
			self.KTtooltipOffsetYmod = 0
		elseif widgetSetID == 842 then
			self.offsetX = 17
			self.KTtooltipOffsetXmod = -5
			self.KTtooltipOffsetYmod = 2
		else
			self.offsetX = 22
			self.KTtooltipOffsetXmod = 0
			self.KTtooltipOffsetYmod = 0
		end
	end)

	-- Disable all spell effects (I can't beat the magic of Blizzard widgets)
	UIWidgetTemplateScenarioHeaderDelvesMixin.UpdateSpellFrameEffects = function() end

	KT_ScenarioObjectiveTracker.StageBlock:HookScript("OnEnter", function(self)
		TooltipPosition(self, 19, -2 - self.KTtooltipOffsetYmod, -24 - self.KTtooltipOffsetXmod, -2 - self.KTtooltipOffsetYmod, true)
	end)

	hooksecurefunc(OTF.Header, "SetCollapsed", function(self, collapsed)
		if collapsed then
			_DBG("COLLAPSE", true)
			KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.25)
			MawBuffs.List:Hide()
		else
			_DBG("EXPAND", true)
			KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.25, 0.5)
		end
		MSA_CloseDropDownMenus()
	end)

	local bck_KT_AdventureObjectiveTracker_OpenToAppearance = KT_AdventureObjectiveTracker.OpenToAppearance
	function KT_AdventureObjectiveTracker:OpenToAppearance(appearanceID)
		if not KT.InCombatBlocked() then
			bck_KT_AdventureObjectiveTracker_OpenToAppearance(self, appearanceID)
		end
	end

	function KT_ObjectiveTrackerQuestPOIBlockMixin:AddPOIButton(questID, isComplete, isSuperTracked, isWorldQuest)  -- R
		local style
		if self.poiInfo then
			style = POIButtonUtil.Style[self.poiInfo.areaPoiID and "AreaPOI" or "BonusObjective"]
		elseif self.poiIsWorldQuest then
			style = POIButtonUtil.Style.WorldQuest
		elseif self.poiIsComplete then
			style = POIButtonUtil.Style.QuestComplete
		else
			style = POIButtonUtil.Style.QuestInProgress
		end
		local poiButton = self:GetPOIButton(style)
		poiButton:SetPoint("TOPRIGHT", self.HeaderText, "TOPLEFT", -7, 3)
		poiButton:SetPingWorldMap(isWorldQuest)
	end

	hooksecurefunc(UIWidgetBaseScenarioHeaderTemplateMixin, "Setup", function(self, widgetInfo, widgetContainer)
		if self.KTskinID ~= KT.skinID then
			local fontSize = db.fontSize + 4
			self.HeaderText:SetFont(KT.font, fontSize, db.fontFlag)  -- see KT:SetText()
			UIWidgetBaseScenarioHeaderText = self.HeaderText
			self.KTskinID = KT.skinID
		end
	end)

	-- ContentTrackingManager.lua
	local function OnContentTrackingUpdate(self, trackableType, id, isTracked)
		if trackableType == Enum.ContentTrackingType.Appearance or trackableType == Enum.ContentTrackingType.Mount then
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

	-- TODO: Delete y/n?
	-- QuestMapFrame.lua (taint)
	--[[function QuestMapFrame_OpenToQuestDetails(questID)  -- R
		local mapID = GetQuestUiMapID(questID)
		if mapID == 0 then
			mapID = nil
		end
		OpenQuestLog(mapID);  -- fix Blizz bug
		QuestMapFrame_ShowQuestDetails(questID);
	end]]

	-- QuestUtils.lua
	local function ShouldShowWarModeBonus(questID, currencyID, firstInstance)
		if not C_PvP.IsWarModeDesired() then
			return false;
		end

		local warModeBonusApplies, limitOncePerTooltip = C_CurrencyInfo.DoesWarModeBonusApply(currencyID);
		if not warModeBonusApplies or (limitOncePerTooltip and not firstInstance) then
			return false;
		end

		return QuestUtils_IsQuestWorldQuest(questID) and C_QuestLog.QuestCanHaveWarModeBonus(questID) and not C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID);
	end

	function QuestUtils_AddQuestCurrencyRewardsToTooltip(questID, tooltip, currencyContainerTooltip)  -- RO
		local currencies = { };
		local uniqueCurrencyIDs = { };
		local currencyRewards = C_QuestLog.GetQuestRewardCurrencies(questID);
		for index, currencyReward in ipairs(currencyRewards) do
			local rarity = C_CurrencyInfo.GetCurrencyInfo(currencyReward.currencyID).quality;
			local firstInstance = not uniqueCurrencyIDs[currencyReward.currencyID];
			if firstInstance then
				uniqueCurrencyIDs[currencyReward.currencyID] = true;
			end
			local currencyInfo = { name = currencyReward.name,
								   texture = currencyReward.texture,
								   numItems = currencyReward.totalRewardAmount,
								   currencyID = currencyReward.currencyID,
								   questRewardContextFlags = currencyReward.questRewardContextFlags,
								   rarity = rarity,
								   firstInstance = firstInstance,
								};
			if(currencyInfo.currencyID ~= ECHOS_OF_NYLOTHA_CURRENCY_ID or #currencyRewards == 1) then
				tinsert(currencies, currencyInfo);
			end
		end

		table.sort(currencies,
			function(currency1, currency2)
				if currency1.rarity ~= currency2.rarity then
					return currency1.rarity > currency2.rarity;
				end
				return currency1.currencyID > currency2.currencyID;
			end
		);

		local addedQuestCurrencies = 0;
		local alreadyUsedCurrencyContainerId = 0; --In the case of multiple currency containers needing to displayed, we only display the first.
		local alreadyUsedCurrencyContainerInfo = nil;  --In the case of multiple currency containers needing to displayed, we only display the first.
		local warModeBonus = C_PvP.GetWarModeRewardBonus();

		for i, currencyInfo in ipairs(currencies) do
			local isCurrencyContainer = C_CurrencyInfo.IsCurrencyContainer(currencyInfo.currencyID, currencyInfo.numItems);
			if ( currencyContainerTooltip and isCurrencyContainer and (alreadyUsedCurrencyContainerId == 0) ) then
				if ( EmbeddedItemTooltip_SetCurrencyByID(currencyContainerTooltip, currencyInfo.currencyID, currencyInfo.numItems) ) then
					if ShouldShowWarModeBonus(questID, currencyInfo.currencyID, currencyInfo.firstInstance) then
						currencyContainerTooltip.Tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(warModeBonus));
						currencyContainerTooltip.Tooltip:Show();
					end

					if ( not tooltip ) then
						break;
					end

					addedQuestCurrencies = addedQuestCurrencies + 1;
					alreadyUsedCurrencyContainerId = currencyInfo.currencyID;
					alreadyUsedCurrencyContainerInfo = currencyInfo;
				end
			elseif ( tooltip ) then
				if( alreadyUsedCurrencyContainerId ~= currencyInfo.currencyID ) then --if there's already a currency container of this same type skip it entirely
					local text, color
					if currencyInfo.currencyID == 1553 then  -- Azerite
						text = format(BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT, FormatLargeNumber(currencyInfo.numItems))
						color = { r = 1, g = 1, b = 1 }
					else
						text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(currencyInfo.texture, currencyInfo.numItems, currencyInfo.name);
						local contextIcon = KT.GetBestQuestRewardContextIcon(currencyInfo.questRewardContextFlags)
						if contextIcon then
							text = text..CreateAtlasMarkup(contextIcon, 12, 16, 3, -1)
						end
						color = GetColorForCurrencyReward(currencyInfo.currencyID, currencyInfo.numItems);
					end
					tooltip:AddLine(text, color.r, color.g, color.b)

					if ShouldShowWarModeBonus(questID, currencyInfo.currencyID, currencyInfo.firstInstance) then
						tooltip:AddLine(WAR_MODE_BONUS_PERCENTAGE_FORMAT:format(warModeBonus));
					end

					addedQuestCurrencies = addedQuestCurrencies + 1;
				end
			end
		end
		return addedQuestCurrencies, alreadyUsedCurrencyContainerId > 0, alreadyUsedCurrencyContainerInfo;
	end

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

	-- DropDown
	function KT_ObjectiveTracker_ToggleDropDown(frame, handlerFunc)
		local dropDown = KT.DropDown;
		if ( dropDown.activeFrame ~= frame ) then
			MSA_CloseDropDownMenus();
		end
		dropDown.activeFrame = frame;
		dropDown.initialize = handlerFunc;
		MSA_ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3, nil, nil, MSA_DROPDOWNMENU_SHOW_TIME);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	function KT_QuestObjectiveTracker:UntrackQuest(questID)  -- N
		C_QuestLog.RemoveQuestWatch(questID)
		if db.questAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
			KT.QuestSuperTracking_ChooseClosestQuest()
		end
	end
	KT_CampaignQuestObjectiveTracker.UntrackQuest = KT_QuestObjectiveTracker.UntrackQuest

	function KT_QuestObjectiveTracker:OnBlockHeaderClick(block, mouseButton)  -- R
		if ChatFrameUtil.TryInsertQuestLinkForQuestID(block.id) then
			return;
		end

		if mouseButton ~= "RightButton" then
			local questID = block.id;
			if IsModifiedClick("QUESTWATCHTOGGLE") then
				self:UntrackQuest(questID)
			elseif IsModifiedClick(db.menuWowheadURLModifier) then
				KT:Alert_WowheadURL("quest", questID)
			elseif IsModifiedClick(db.menuYouTubeURLModifier) then
				KT:Alert_YouTubeURL("quest", questID)
			else
				local quest = QuestCache:Get(questID);
				if quest.isAutoComplete and quest:IsComplete() then
					self:RemoveAutoQuestPopUp(questID);
					ShowQuestComplete(questID);
				else
					if db.questDefaultActionMap then
						QuestMapFrame_OpenToQuestDetails(questID);
					else
						QuestUtil.OpenQuestDetails(questID);
					end
				end
			end
		else
			KT_ObjectiveTracker_ToggleDropDown(block, KT_QuestObjectiveTracker_OnOpenDropDown)
		end
	end
	KT_CampaignQuestObjectiveTracker.OnBlockHeaderClick = KT_QuestObjectiveTracker.OnBlockHeaderClick

	function KT_QuestObjectiveTracker_OnOpenDropDown(self)
		local block = self.activeFrame;

		local info = MSA_DropDownMenu_CreateInfo();
		info.text = C_QuestLog.GetTitleForQuestID(block.id);
		info.isTitle = 1;
		info.notCheckable = 1;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info = MSA_DropDownMenu_CreateInfo();
		info.notCheckable = 1;

		if C_SuperTrack.GetSuperTrackedQuestID() ~= block.id then
			info.text = SUPER_TRACK_QUEST
			info.func = function()
				C_SuperTrack.SetSuperTrackedQuestID(block.id)
			end
		else
			info.text = STOP_SUPER_TRACK_QUEST
			info.func = function()
				C_SuperTrack.SetSuperTrackedQuestID(0)
			end
		end
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)

		local toggleDetailsText = QuestUtil.IsShowingQuestDetails(block.id) and OBJECTIVES_HIDE_VIEW_IN_QUESTLOG or OBJECTIVES_VIEW_IN_QUESTLOG;
		info.text = toggleDetailsText;
		info.func = function()
			QuestUtil.OpenQuestDetails(block.id)
		end;
		info.noClickSound = 1;
		info.checked = false;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info.text = OBJECTIVES_SHOW_QUEST_MAP;
		info.func = function()
			QuestMapFrame_OpenToQuestDetails(block.id)
		end;
		info.checked = false;
		info.noClickSound = 1;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		if ( C_QuestLog.IsPushableQuest(block.id) and IsInGroup() ) then
			info.text = SHARE_QUEST;
			info.func = function()
				QuestUtil.ShareQuest(block.id)
			end;
			info.checked = false;
			MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);
		end

		info.text = OBJECTIVES_STOP_TRACKING;
		info.func = function()
			block.parentModule:UntrackQuest(block.id)
		end;
		info.checked = false;
		info.disabled = (dbChar.filterAuto[1]);
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info.disabled = false;

		if C_QuestLog.CanAbandonQuest(block.id) then
			info.text = ABANDON_QUEST;
			info.func = function()
				QuestMapQuestOptions_AbandonQuest(block.id)
			end;
			MSA_DropDownMenu_AddButton(info, MSA_DROPDOWNMENU_MENU_LEVEL);
		end

		KT:SendSignal("CONTEXT_MENU_UPDATE", info, "quest", block.id)
	end

	function KT_AchievementObjectiveTracker:OnBlockHeaderClick(block, mouseButton)  -- R
		local achievementID = block.id;
		if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
			local achievementLink = GetAchievementLink(achievementID);
			if achievementLink then
				ChatFrameUtil.InsertLink(achievementLink);
			end
		elseif mouseButton ~= "RightButton" then
			if not AchievementFrame then
				AchievementFrame_LoadUI();
			end
			if IsModifiedClick("QUESTWATCHTOGGLE") then
				self:UntrackAchievement(achievementID);
			elseif IsModifiedClick(db.menuWowheadURLModifier) then
				KT:Alert_WowheadURL("achievement", achievementID)
			elseif IsModifiedClick(db.menuYouTubeURLModifier) then
				KT:Alert_YouTubeURL("achievement", achievementID)
			elseif not AchievementFrame:IsShown() then
				AchievementFrame_ToggleAchievementFrame();
				AchievementFrame_SelectAchievement(achievementID);
			else
				if AchievementFrameAchievements.selection ~= achievementID then
					AchievementFrame_SelectAchievement(achievementID);
				else
					AchievementFrame_ToggleAchievementFrame();
				end
			end
		else
			KT_ObjectiveTracker_ToggleDropDown(block, KT_AchievementObjectiveTracker_OnOpenDropDown)
		end
	end

	function KT_AchievementObjectiveTracker_OnOpenDropDown(self)
		local block = self.activeFrame;
		local _, achievementName = GetAchievementInfo(block.id);

		local info = MSA_DropDownMenu_CreateInfo();
		info.text = achievementName;
		info.isTitle = 1;
		info.notCheckable = 1;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info = MSA_DropDownMenu_CreateInfo();
		info.notCheckable = 1;

		info.text = OBJECTIVES_VIEW_ACHIEVEMENT;
		info.func = function()
			OpenAchievementFrameToAchievement(block.id)
		end;
		info.checked = false;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info.text = OBJECTIVES_STOP_TRACKING;
		info.func = function()
			block.parentModule:UntrackAchievement(block.id)
		end;
		info.checked = false;
		info.disabled = (dbChar.filterAuto[2]);
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info.disabled = false;

		KT:SendSignal("CONTEXT_MENU_UPDATE", info, "achievement", block.id)
	end

	local function SetSuperTrackedEventPoiID(poiID)
		if poiID then
			C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI, poiID)
		end
	end

	function KT_BonusObjectiveTracker:OnBlockHeaderClick(block, button)  -- R
		local questID = block.id;
		local isThreatQuest = C_QuestLog.IsThreatQuest(questID);
		if button == "LeftButton" then
			if ( not ChatFrameUtil.TryInsertQuestLinkForQuestID(questID) ) then
				if IsShiftKeyDown() then
					if QuestUtils_IsQuestWatched(questID) and not isThreatQuest then
						QuestUtil.UntrackWorldQuest(questID);
					end
				elseif IsModifiedClick(db.menuWowheadURLModifier) then
					KT:Alert_WowheadURL("quest", questID)
				elseif IsModifiedClick(db.menuYouTubeURLModifier) then
					KT:Alert_YouTubeURL("quest", questID)
				else
					local mapID = (self.showWorldQuests or isThreatQuest) and C_TaskQuest.GetQuestZoneID(questID) or GetQuestUiMapID(questID)
					if mapID and mapID > 0 then
						QuestMapFrame:SetDisplayMode(QuestLogDisplayMode.Quests)
						QuestMapFrame_CloseQuestDetails()
						OpenQuestLog(mapID);
						if block.poiInfo and block.poiInfo.areaPoiID then
							EventRegistry:TriggerEvent("PingAreaPOIEvent", block.poiInfo.areaPoiID)
						else
							EventRegistry:TriggerEvent("MapCanvas.PingQuestID", questID);
						end
					end
				end
			end
		elseif button == "RightButton" then
			KT_ObjectiveTracker_ToggleDropDown(block, KT_BonusObjectiveTracker_OnOpenDropDown)
		end
	end
	KT_WorldQuestObjectiveTracker.OnBlockHeaderClick = KT_BonusObjectiveTracker.OnBlockHeaderClick

	function KT_BonusObjectiveTracker_OnOpenDropDown(self)
		local block = self.activeFrame;
		local questID = block.id;
		local addStopTracking = QuestUtils_IsQuestWatched(questID);

		local info = MSA_DropDownMenu_CreateInfo();
		info.text = C_TaskQuest.GetQuestInfoByQuestID(questID) or C_QuestLog.GetTitleForQuestID(questID)
		info.isTitle = 1;
		info.notCheckable = 1;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info = MSA_DropDownMenu_CreateInfo();
		info.notCheckable = 1;

		local isWorldQuest = block.parentModule.showWorldQuests
		local isThreatQuest = C_QuestLog.IsThreatQuest(questID)
		local areaPoiID = KT.GetAreaPoiID(block.poiInfo)
		if isWorldQuest or isThreatQuest or not areaPoiID then
			if C_SuperTrack.GetSuperTrackedQuestID() ~= questID then
				info.text = SUPER_TRACK_QUEST
				info.func = function()
					C_SuperTrack.SetSuperTrackedQuestID(questID)
				end
			else
				info.text = STOP_SUPER_TRACK_QUEST
				info.func = function()
					C_SuperTrack.SetSuperTrackedQuestID(0)
				end
			end
		else
			local _, superTrackedPoiID = C_SuperTrack.GetSuperTrackedMapPin()
			if areaPoiID ~= superTrackedPoiID then
				info.text = SUPER_TRACK_QUEST
				info.func = function()
					SetSuperTrackedEventPoiID(areaPoiID)
				end
			else
				info.text = STOP_SUPER_TRACK_QUEST
				info.func = function()
					C_SuperTrack.ClearSuperTrackedMapPin()
				end
			end
		end
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)

		-- Add "stop tracking"
		if addStopTracking then
			info.text = OBJECTIVES_STOP_TRACKING;
			info.func = function()
				QuestUtil.UntrackWorldQuest(questID)
			end
			MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);
		end

		KT:SendSignal("CONTEXT_MENU_UPDATE", info, "quest", questID)
	end

	function KT_ProfessionsRecipeTracker:OnBlockHeaderClick(block, mouseButton)  -- R
		local recipeID = KT.GetRecipeID(block)
		if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
			local link = C_TradeSkillUI.GetRecipeLink(recipeID);
			if link then
				ChatFrameUtil.InsertLink(link);
			end
		elseif mouseButton ~= "RightButton" then
			if not ProfessionsFrame then
				ProfessionsFrame_LoadUI();
			end
			if IsModifiedClick("RECIPEWATCHTOGGLE") then
				local track = false;
				C_TradeSkillUI.SetRecipeTracked(recipeID, track, KT.IsRecraftBlock(block));
			elseif IsModifiedClick(db.menuWowheadURLModifier) then
				KT:Alert_WowheadURL("spell", recipeID)
			else
				if not KT.IsRecraftBlock(block) then
					if C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
						C_TradeSkillUI.OpenRecipe(recipeID)
					else
						Professions.InspectRecipe(recipeID);
					end
				end
			end
		else
			KT_ObjectiveTracker_ToggleDropDown(block, KT_RecipeObjectiveTracker_OnOpenDropDown)
		end
	end

	function KT_RecipeObjectiveTracker_OnOpenDropDown(self)
		local block = self.activeFrame;
		local recipeID = KT.GetRecipeID(block);

		local info = MSA_DropDownMenu_CreateInfo();
		info.text = C_Spell.GetSpellName(recipeID);
		info.isTitle = 1;
		info.notCheckable = 1;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info = MSA_DropDownMenu_CreateInfo();
		info.notCheckable = 1;

		local spellBank = Enum.SpellBookSpellBank.Player;
		local includeOverrides = false;
		if not KT.IsRecraftBlock(block) and C_SpellBook.IsSpellInSpellBook(recipeID, spellBank, includeOverrides) then
			info.text = PROFESSIONS_TRACKING_VIEW_RECIPE;
			info.func = function()
				if C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
					C_TradeSkillUI.OpenRecipe(recipeID);
				else
					Professions.InspectRecipe(recipeID);
				end
			end;
			MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);
		end

		info.text = PROFESSIONS_UNTRACK_RECIPE;
		info.func = function()
			C_TradeSkillUI.SetRecipeTracked(recipeID, false, KT.IsRecraftBlock(block))
		end;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		KT:SendSignal("CONTEXT_MENU_UPDATE", info, "spell", recipeID)
	end

	function KT_MonthlyActivitiesObjectiveTracker:OnBlockHeaderClick(block, mouseButton)  -- R
		if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
			local perksActivityLink = C_PerksActivities.GetPerksActivityChatLink(block.id);
			ChatFrameUtil.InsertLink(perksActivityLink);
		elseif mouseButton ~= "RightButton" then
			if not EncounterJournal then
				EncounterJournal_LoadUI();
			end
			if IsModifiedClick("QUESTWATCHTOGGLE") then
				self:UntrackPerksActivity(block.id);
			elseif IsModifiedClick(db.menuWowheadURLModifier) then
				KT:Alert_WowheadURL("activity", block.id)
			else
				MonthlyActivitiesFrame_OpenFrameToActivity(block.id);
			end

			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
			KT_ObjectiveTracker_ToggleDropDown(block, KT_MonthlyActivitiesObjectiveTracker_OnOpenDropDown)
		end
	end

	function KT_MonthlyActivitiesObjectiveTracker_OnOpenDropDown(self)
		local block = self.activeFrame;

		local info = MSA_DropDownMenu_CreateInfo();
		info.text = block.name;
		info.isTitle = 1;
		info.notCheckable = 1;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info = MSA_DropDownMenu_CreateInfo();
		info.notCheckable = 1;

		info.text = "Open "..TRACKER_HEADER_MONTHLY_ACTIVITIES;
		info.func = function ()
			block.parentModule:OpenFrameToActivity(block.id)
		end;
		info.checked = false;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info.text = OBJECTIVES_STOP_TRACKING;
		info.func = function()
			block.parentModule:UntrackPerksActivity(block.id)
		end;
		info.checked = false;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		KT:SendSignal("CONTEXT_MENU_UPDATE", info, "activity", block.id)
	end

	function KT_AdventureObjectiveTracker:OnBlockHeaderClick(block, mouseButton)  -- R
		if not ContentTrackingUtil.ProcessChatLink(block.trackableType, block.trackableID) then
			if mouseButton ~= "RightButton" then
				if ContentTrackingUtil.IsTrackingModifierDown() then
					C_ContentTracking.StopTracking(block.trackableType, block.trackableID, Enum.ContentTrackingStopType.Manual);
				elseif (block.trackableType == Enum.ContentTrackingType.Appearance) and IsModifiedClick("DRESSUP") then
					DressUpVisual(block.trackableID);
				elseif block.targetType == Enum.ContentTrackingTargetType.Achievement then
					OpenAchievementFrameToAchievement(block.targetID);
				elseif block.targetType == Enum.ContentTrackingTargetType.Profession then
					self:ClickProfessionTarget(block.targetID);
				else
					ContentTrackingUtil.OpenMapToTrackable(block.trackableType, block.trackableID);
				end

				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			else
				KT_ObjectiveTracker_ToggleDropDown(block, KT_AdventureObjectiveTracker_OnOpenDropDown)
			end
		end
	end

	function KT_AdventureObjectiveTracker_OnOpenDropDown(self)
		local block = self.activeFrame;

		local info = MSA_DropDownMenu_CreateInfo();
		info.text = block.name;
		info.isTitle = 1;
		info.notCheckable = 1;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);

		info = MSA_DropDownMenu_CreateInfo();
		info.notCheckable = 1;

		if block.trackableType == Enum.ContentTrackingType.Appearance then
			info.text = CONTENT_TRACKING_OPEN_JOURNAL_OPTION;
			info.func = function()
				block.parentModule:OpenToAppearance(block.trackableID)
			end;
			info.checked = false;
			MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);
		end

		info.text = OBJECTIVES_STOP_TRACKING;
		info.func = function()
			block.parentModule:Untrack(block.trackableType, block.trackableID)
		end;
		info.checked = false;
		MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL);
	end

	-- Torghast - Blizzard_UIWidgetTemplateStatusBar.lua
	hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", function(self, widgetInfo, widgetContainer)
		if self.frameTextureKit == "jailerstower-scorebar" and self.KTskinID ~= KT.skinID then
			local bck_Bar_OnEnter = self.Bar:GetScript("OnEnter")
			self.Bar:SetScript("OnEnter", function(self)
				if KTF.anchorLeft then
					self:SetTooltipLocation(Enum.UIWidgetTooltipLocation.Right)
					self.tooltipXOffset = 30
				else
					self:SetTooltipLocation(Enum.UIWidgetTooltipLocation.Left)
					self.tooltipXOffset = -31
				end
				self.tooltipYOffset = 0
				bck_Bar_OnEnter(self)
			end)
			self.KTskinID = KT.skinID
		end
	end)

	hooksecurefunc(UIWidgetTemplateStatusBarMixin, "EvaluateTutorials", function(self)
		if self.frameTextureKit == "jailerstower-scorebar" then
			HelpTip:Hide(self, TORGHAST_DOMINANCE_BAR_TIP)
			HelpTip:Hide(self, TORGHAST_DOMINANCE_BAR_CUTOFF_TIP)
		end
	end)

	-- Torghast - Blizzard_MawBuffs.lua
	hooksecurefunc(MawBuffs, "UpdateAlignment", function(self)
		if KTF.anchorLeft == self.KTanchorLeft then return end

		self.KTanchorLeft = KTF.anchorLeft

		self:SetPushedTextOffset(KTF.anchorLeft and -1.25 or 1.25, -1)

		self:ClearAllPoints()
		self.List:ClearAllPoints()

		if KTF.anchorLeft then
			self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 27, 0)
			self.List:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, 1)

			self.NormalTexture:SetTexCoord(1, 0, 0, 1)
			self.PushedTexture:SetTexCoord(1, 0, 0, 1)
			self.HighlightTexture:SetTexCoord(1, 0, 0, 1)
			self.DisabledTexture:SetTexCoord(1, 0, 0, 1)
		else
			self:SetPoint("TOPRIGHT", self:GetParent(), "TOPRIGHT", -10, 0)
			self.List:SetPoint("TOPRIGHT", self, "TOPLEFT", -2, 1)

			self.NormalTexture:SetTexCoord(0, 1, 0, 1)
			self.PushedTexture:SetTexCoord(0, 1, 0, 1)
			self.HighlightTexture:SetTexCoord(0, 1, 0, 1)
			self.DisabledTexture:SetTexCoord(0, 1, 0, 1)
		end
	end)

	MawBuffs.List:HookScript("OnShow", function(self)
		self.button:SetButtonState("NORMAL")
		self.button:SetPushedTextOffset(KTF.anchorLeft and -8.75 or 8.75, -1)
		self.button:SetButtonState("PUSHED", true)
	end)

	MawBuffs.List:HookScript("OnHide", function(self)
		self.button:SetButtonState("NORMAL", false)
		self.button:SetPushedTextOffset(KTF.anchorLeft and -1.25 or 1.25, -1)
	end)

	MawBuffs.UpdateHelptip = function() end

	-- Update Mixins
	Default_UpdateMixins()
end

local function SetHooks_Init()
	-- POIButton.lua
	hooksecurefunc(POIButtonMixin, "UpdateButtonStyle", function(self)
		self.questTagInfo = nil  -- fix Blizz bug
		if self.Display.SubTypeIcon and self.hideSubTypeIcon then
			self.Display.SubTypeIcon:Hide()
		end
		self.Glow:SetShown(false)
	end)
end

-- External ------------------------------------------------------------------------------------------------------------

---Set tracker hidden state.
---@param hidden boolean|nil Hidden state (true = hide, false = show, nil = toggle)
function KT:SetHidden(hidden)
	if db.hideEmptyTracker then return end
	if hidden ~= nil then
		self.hidden = hidden
	else
		self.hidden = not self.hidden
	end
	_DBG((self.hidden and "HIDE" or "SHOW").." ... collapsed: "..tostring(dbChar.collapsed), true)
	self.locked = self.hidden
	OTF:SetCollapsed(self.hidden or dbChar.collapsed)
end

---Set tracker collapsed or expanded.
---@param collapsed boolean|nil Collapsed state (true = collapse, false = expand, nil = toggle)
---@param silent boolean|nil If true, does not save collapsed state
function KT:SetCollapsed(collapsed, silent)
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
function KT:IsCollapsed()
	return OTF:IsCollapsed()
end

---Update the tracker.
---@param forced boolean|nil If true, forces update.
function KT:Update(forced)
	self:SetForced(forced)
	OTF:Update()
end

function KT:MinimizeButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	self:SetCollapsed()
end

function KT_WorldQuestPOIButton_OnClick(self)
	local questID = self.questID
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	C_SuperTrack.SetSuperTrackedQuestID(questID)
	EventRegistry:TriggerEvent("MapCanvas.PingQuestID", questID)
end

function KT:SetSize(forced)
	local height = KTF.headerHeight + (2 * KTF.borderSpace)
	local mod = 0

	if not OTF.contentsHeight then
		return
	end

	_DBG(" - height = "..OTF.contentsHeight)
	if not self:IsCollapsed() and HasTrackerContents() then
		-- width
		KTSetWidth(KTF, db.width)

		-- height
		height = KTF.paddingTop + OTF.contentsHeight + mod + 10 + KTF.paddingBottom
		_DBG(" - "..KTF.paddingTop.." + "..OTF.contentsHeight.." + "..mod.." + 10 + "..KTF.paddingBottom.." = "..height, true)
		OTF.height = height

		if floor(height) > db.maxHeight then
			_DBG("MOVE ... "..KTF.Scroll.value.." > "..OTF.height.." - "..db.maxHeight)
			if KTF.Scroll.value > OTF.height-db.maxHeight then
				KTF.Scroll.value = OTF.height - db.maxHeight
			end
			KTF.Scroll:SetVerticalScroll(KTF.Scroll.value)
			if db.frameScrollbar then
				SetScrollbarPosition()
				KTF.Bar:Show()
			end
			height = db.maxHeight
		elseif height <= db.maxHeight then
			if KTF.Scroll.value > 0 then
				KTF.Scroll.value = 0
				KTF.Scroll:SetVerticalScroll(0)
			end
			if db.frameScrollbar then
				KTF.Bar:Hide()
			end
		end

		if height ~= KTF.height or forced then
			KTSetHeight(KTF, KTF.directionUp and height or db.maxHeight)
			KTF.Background:SetHeight(height)
			KTF.height = height
		end

		self:MoveButtons()
	else
		-- width
		if db.hdrCollapsedTxt == 1 then
			KTSetWidth(KTF, KTF.HeaderButtons:GetWidth() + 8)
		else
			KTSetWidth(KTF, db.width)
		end

		-- height
		OTF.height = height - 10
		if OTF.contentsHeight == 0 then
			KTF.Scroll.value = 0
		end
		KTF.Scroll:SetVerticalScroll(0)
		if db.frameScrollbar then
			KTF.Bar:Hide()
		end

		if height ~= KTF.height or forced then
			KTSetHeight(KTF, KTF.directionUp and height or db.maxHeight)
			KTF.Background:SetHeight(height)
			KTF.height = height
		end
	end
end

function KT:MoveTracker()
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

	self:MoveButtons()
end

function KT:SetShown(show)
	KTSetShown(KTF, show)
	KTF.Buttons:SetShown(show)
end

function KT:SetScale(scale)
	KTSetScale(KTF, scale)
	KTF.Buttons:SetScale(scale)
end

function KT:SetFrameStrata(strata)
	KTSetFrameStrata(KTF, strata)
	KTF.Buttons:SetFrameStrata(strata)
end

function KT:SetBackground()
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

	self:SendSignal("OPTIONS_CHANGED")
end

-- TODO: Rename function
function KT:SetText(forced)
	if forced then
		self.skinID = self.skinID + 1
	end

	self.font = LSM:Fetch("font", db.font)
	testLine.Dash:SetFont(self.font, db.fontSize, db.fontFlag)
	self.dashWidth = testLine.Dash:GetWidth() + 1

	-- Headers
	SetHeadersStyle("text")

	-- Others
	if KT_ScenarioObjectiveTracker.KTskinID ~= KT.skinID then
		KT_ScenarioObjectiveTracker.StageBlock.Stage:SetFont(self.font, db.fontSize + 5, db.fontFlag)
		KT_ScenarioObjectiveTracker.ProvingGroundsBlock.WaveLabel:SetFont(self.font, db.fontSize + 5, db.fontFlag)
		KT_ScenarioObjectiveTracker.ProvingGroundsBlock.Wave:SetFont(self.font, db.fontSize + 5, db.fontFlag)
		KT_ScenarioObjectiveTracker.ProvingGroundsBlock.StatusBar:SetStatusBarTexture(LSM:Fetch("statusbar", db.progressBar))
		if UIWidgetBaseScenarioHeaderText then
			UIWidgetBaseScenarioHeaderText:SetFont(self.font, db.fontSize + 4, db.fontFlag)  -- see UIWidgetBaseScenarioHeaderTemplateMixin:Setup
		end
		KT_ScenarioObjectiveTracker.KTskinID = KT.skinID
	end
end

function KT:SetHeaderButtons(numAddButtons)
	local buttonSpace = 20
	KTF.HeaderButtons.num = KTF.HeaderButtons.num + numAddButtons
	KTF.HeaderButtons:SetWidth((KTF.HeaderButtons.num * buttonSpace) + 11)
	OTFHeader.Text:SetWidth(OTFHeader.Text:GetWidth() - (numAddButtons * buttonSpace))
end

function KT:SetModuleHeader(module)
	if not module.Header then return end
	module.Header.Text.ClearAllPoints = function() end
	module.Header.Text:SetPoint("LEFT", 10, 1)
	module.Header.Text.SetPoint = function() end
	module.Header.PlayAddAnimation = function() end
	module.Header.MinimizeButton:SetShown(false)
	module.Header.MinimizeButton.SetShown = function() end
	module.Header:SetScript("OnMouseUp", function()
		ModuleMinimize_OnClick(module)
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

function KT:SetHeaderText(module, append)
	local text = module.headerText
	if append then
		text = format("%s (%s)", text, append)
	end
	module.Header.Text:SetText(text)
end

function KT:SetQuestsHeaderText(reset)
	if db.hdrQuestsTitleAppend then
		self:SetHeaderText(KT_QuestObjectiveTracker, dbChar.quests.num.."/"..MAX_QUESTS)
	elseif reset then
		self:SetHeaderText(KT_QuestObjectiveTracker)
	end
end

function KT:SetAchievsHeaderText(reset)
	if db.hdrAchievsTitleAppend then
		self:SetHeaderText(KT_AchievementObjectiveTracker, GetTotalAchievementPoints())
	elseif reset then
		self:SetHeaderText(KT_AchievementObjectiveTracker)
	end
end

function KT:SetOtherButtons()
	if not db.hdrOtherButtons then
		if KTF.QuestLogButton then
			KTF.QuestLogButton:Hide()
			KTF.AchievementsButton:Hide()
			self:SetHeaderButtons(-2)
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
			ToggleAchievementFrame()
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
			ToggleQuestLog()
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
	self:SetHeaderButtons(2)
end

function KT:MoveButtons()
	if not InCombatLockdown() then
		local point, xOfs, yOfs
		if KTF.anchorLeft then
			point = "LEFT"
			xOfs = KTF:GetRight() and KTF:GetRight() + db.qiXOffset
		else
			point = "RIGHT"
			xOfs = KTF:GetLeft() and KTF:GetLeft() - db.qiXOffset
		end
		local hMod = 2 * (4 - db.bgrInset)
		local yMod = 0
		if not db.qiBgrBorder then
			hMod = hMod + 4
			yMod = 2 + (4 - db.bgrInset)
		end
		if KTF.directionUp and (db.maxHeight+hMod) < KTF.Buttons:GetHeight() then
			point = "BOTTOM"..point
			yOfs = KTF:GetBottom() and KTF:GetBottom() - yMod
		else
			point = "TOP"..point
			yOfs = KTF:GetTop() and KTF:GetTop() + yMod
		end
		if xOfs and yOfs then
			KTF.Buttons:ClearAllPoints()
			KTBSetPoint(KTF.Buttons, point, UIParent, "BOTTOMLEFT", xOfs, yOfs)
		end
	end
end

function KT:RemoveFixedButton(block)
	if block then
		local tag = block.fixedTag
		if tag then
			tinsert(freeTags, tag)
			tag.text:SetText("")
			tag:Hide()
			block.fixedTag = nil
		end
		local questID = block.id
		local button = self:GetFixedButton(questID)
		if button then
			button:SetAlpha(0)
			if InCombatLockdown() then
				_DBG(" - STOP Remove button")
				combatLockdown = true
			else
				_DBG(" - REMOVE button "..questID)
				tinsert(freeButtons, button)
				self.fixedButtons[questID] = nil
				button:Hide()
				KTF.Buttons.reanchor = true
			end
		end
	else
		for questID, button in pairs(self.fixedButtons) do
			_DBG(" - REMOVE button "..questID)
			tinsert(freeButtons, button)
			self.fixedButtons[questID] = nil
			button:Hide()
		end
		KTF.Buttons.reanchor = true
	end
end

function KT:GetFixedButton(questID)
	if self.fixedButtons[questID] then
		return self.fixedButtons[questID]
	else
		return nil
	end
end

function KT:CreateQuestTag(level, questTag, frequency, suggestedGroup)
	local tag = ""

	if level == -1 then
		level = "*"
	else
		level = tostring(level)
	end

	if questTag then
		if questTag == Enum.QuestTag.Group then
			tag = "g"
			if suggestedGroup and suggestedGroup > 0 then
				tag = tag..suggestedGroup
			end
		elseif questTag == Enum.QuestTag.PvP then
			tag = "pvp"
		elseif questTag == Enum.QuestTag.Dungeon then
			tag = "d"
		elseif questTag == Enum.QuestTag.Heroic then
			tag = "hc"
		elseif questTag == Enum.QuestTag.Raid then
			tag = "r"
		elseif questTag == Enum.QuestTag.Raid10 then
			tag = "r10"
		elseif questTag == Enum.QuestTag.Raid25 then
			tag = "r25"
		elseif questTag == Enum.QuestTag.Delve then
			tag = "de"
		elseif questTag == Enum.QuestTag.Scenario then
			tag = "s"
		elseif questTag == Enum.QuestTag.Account then
			tag = "a"
		elseif questTag == Enum.QuestTag.Legendary then
			tag = "leg"
		end
	end

	if frequency == Enum.QuestFrequency.Daily then
		tag = tag.."!"
	elseif frequency == Enum.QuestFrequency.Weekly then
		tag = tag.."!!"
	end

	if tag ~= "" then
		tag = ("|cff00b3ff%s|r"):format(tag)
	end

	tag = ("[%s%s] "):format(level, tag)
	return tag
end

local function ShowState(state)
	return state and "|cff00ff00empty" or "|cffff0000content"
end

function KT:IsTrackerEmpty(noaddon)
	local result = (KT.GetNumQuestWatches() == 0 and
			(GetNumAutoQuestPopUps() == 0 or self.hiddenQuestPopUps) and
			self.GetNumTrackedAchievements() == 0 and
			self.GetNumTasks() == 0 and
			C_QuestLog.GetNumWorldQuestWatches() == 0 and
			not self.inScenario and
			self.GetNumTrackedRecipes() == 0 and
			self.GetNumTrackedActivities() == 0 and
			self.GetNumTrackedCollectibles() == 0)
	if not noaddon then
		result = (result and not self.AddonPetTracker:IsShown())
	end
	return result
end

function KT:ToggleEmptyTracker()
	local alpha, mouse = 1, true
	if not HasTrackerContents() or self.hidden then
		KTF.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 0.75)
		if db.hideEmptyTracker or self.hidden then
			alpha = 0
			mouse = false
		end
	else
		if self:IsCollapsed() then
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

function KT:SetMessage(text, r, g, b, pattern, icon, x, y)
	if pattern then
		text = format(pattern, text.." ...")
	end
	if icon then
		x = x or 0
		y = y or 0
		if db.sink20OutputSink == "Blizzard" then
			x = floor(x * 3)
			y = y - 8
		end
		text = format("|T%s:0:0:%d:%d|t%s", icon, x, y, text)
	end
	self:Pour(text, r, g, b)
end

local SOUND_COOLDOWN = 2
local lastSoundTime = 0
function KT:PlaySound(key)
	local now = GetTime()
	if now - lastSoundTime >= SOUND_COOLDOWN then
		PlaySoundFile(LSM:Fetch("sound", key), db.soundChannel)
		lastSoundTime = now
	end
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

function KT.CompareQuestWatchInfos(info1, info2)
	local quest1, quest2 = info1.quest, info2.quest

	if quest1:IsCalling() ~= quest2:IsCalling() then
		return quest1:IsCalling()
	end

	if dbChar.filter.quests.sortTopOverride and quest1.overridesSortOrder ~= quest2.overridesSortOrder then
		return quest1.overridesSortOrder
	end

	local sort = dbChar.filter.quests.sort
	if sort == "newest" then
		local time1 = info1.KTquest and info1.KTquest.updateTime or 0
		local time2 = info2.KTquest and info2.KTquest.updateTime or 0
		return time1 > time2
	elseif sort == "zone" then
		local zone1 = info1.KTquest and info1.KTquest.zone or ""
		local zone2 = info2.KTquest and info2.KTquest.zone or ""
		if zone1 == zone2 then
			if quest1.level == quest2.level then
				return quest1.title < quest2.title
			else
				return quest1.level > quest2.level
			end
		else
			return zone1 < zone2
		end
	elseif sort == "level" then
		if quest1.level == quest2.level then
			return quest1.title < quest2.title
		else
			return quest1.level > quest2.level
		end
	elseif sort == "title" then
		return quest1.title < quest2.title
	end

	return info1.index > info2.index
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
	local _, class = UnitClass("player")
	self.classColor = RAID_CLASS_COLORS[class]

	-- Tracker data
	self.headers = {}
	self.borderColor = {}
	self.hdrBtnColor = {}
	self.fixedButtons = {}
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

	self.Storage_Init()

	SetHooks_Init()
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

	self:RegSignal("OPTIONS_CHANGED", "Update")
	self:RegEvent("PLAYER_ENTERING_WORLD", function(eventID, ...)
		KT.ObjectiveTrackerManager:OnPlayerEnteringWorld(...)
		Init()
		self:UnregEvent(eventID)
	end)

	self:EnableModules()

	if self.db.global.version ~= self.VERSION then
		self.db.global.version = self.VERSION
	end

	db.modulesOrder = self.ReconcileOrder(self.MODULES, db.modulesOrder)
end