--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

---@class QuestLog
local M = KT:NewModule("QuestLog")
KT.QuestLog = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar

local dropDownFrame

-- Internal ------------------------------------------------------------------------------------------------------------

local function QuestMapQuestOptionsDropDown_Initialize(self)
	local info = KT.Menu_CreateInfo()
	KT.Menu_AddTitle(C_QuestLog.GetTitleForQuestID(self.questID))

	local text, func
	if C_SuperTrack.GetSuperTrackedQuestID() ~= self.questID then
		text = SUPER_TRACK_QUEST
		func = function()
			C_SuperTrack.SetSuperTrackedQuestID(self.questID)
		end
	else
		text = STOP_SUPER_TRACK_QUEST
		func = function()
			C_SuperTrack.SetSuperTrackedQuestID(0)
		end
	end
	KT.Menu_AddButton(text, func)

	KT.Menu_AddButton(QuestUtils_IsQuestWatched(self.questID) and UNTRACK_QUEST or TRACK_QUEST, function()
		QuestMapQuestOptions_TrackQuest(self.questID)
	end, (dbChar.filterAuto[1] ~= nil))

	info.disabled = false

	KT.Menu_AddButton(SHARE_QUEST, function()
		QuestMapQuestOptions_ShareQuest(self.questID)
	end, (not C_QuestLog.IsPushableQuest(self.questID) or not IsInGroup()))

	info.disabled = false

	if C_QuestLog.CanAbandonQuest(self.questID) then
		KT.Menu_AddButton(ABANDON_QUEST, function()
			QuestMapQuestOptions_AbandonQuest(self.questID)
		end)
	end

	KT:SendSignal("CONTEXT_MENU_UPDATE", info, "quest", self.questID)
end

local function SetHooks()
    -- WorldMapFrame.lua
    WorldMapFrame:HookScript("OnHide", function()
        KT_QuestMapFrame_CloseQuestDetails()
    end)

    hooksecurefunc(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame, "Maximize", function(self, isAutomaticAction, skipCallback)
        KT_QuestMapFrame_CloseQuestDetails()
    end)

    WorldMapFrame.SidePanelToggle.CloseButton:HookScript("OnClick", function()
        KT_QuestMapFrame_CloseQuestDetails()
    end)

    -- for Mapster
    hooksecurefunc(WorldMapFrame, "SetScale", function(self, scale)
        KT_QuestMapFrame:SetScale(scale)
    end)

	-- QuestMapFrame.lua
    hooksecurefunc(QuestMapFrame, "Refresh", function(self)
        if KT_QuestMapFrame.DetailsFrame.questMapID and KT_QuestMapFrame.DetailsFrame.questMapID ~= self:GetParent():GetMapID() then
            KT_QuestMapFrame_CloseQuestDetails()
        end
    end)

	hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self, button)
		local isDisabledQuest = C_QuestLog.IsQuestDisabledForSession(self.questID)
		if not isDisabledQuest and button == "RightButton" then
			local manager = Menu.GetManager()
			local menu = manager:GetOpenMenu()
			if menu then
				manager:CloseMenu(menu)
			end
			MSA_CloseDropDownMenus()
			dropDownFrame.questID = self.questID
			MSA_ToggleDropDownMenu(1, nil, dropDownFrame, "cursor", 6, -6)
		elseif button == "LeftButton" then
			if IsModifiedClick(db.menuWowheadURLModifier) then
				KT:Alert_WowheadURL("quest", self.questID)
			elseif IsModifiedClick(db.menuYouTubeURLModifier) then
				KT:Alert_YouTubeURL("quest", self.questID)
			end
		end
	end)

	hooksecurefunc("QuestMapQuestOptions_TrackQuest", function(questID)
		if db.questAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
			KT.QuestSuperTracking_ChooseClosestQuest()
		end
	end)

    hooksecurefunc(QuestMapFrame, "SetDisplayMode", function(self, displayMode)
        if KT_QuestMapFrame.DetailsFrame.questID then
            KT_QuestMapFrame:SetShown(displayMode == QuestLogDisplayMode.Quests)
        end
    end)
end

local function SetFrames()
    -- Quest detail
    local questMapFrame = CreateFrame("Frame", "KT_QuestMapFrame", UIParent)
    questMapFrame:SetSize(331, 498)  -- 504
    questMapFrame:SetPoint("TOPRIGHT", QuestMapFrame, -1, 0)
    questMapFrame:SetFrameStrata(QuestMapFrame:GetFrameStrata())
    questMapFrame:EnableMouse(true)
    questMapFrame:Hide()

    questMapFrame:SetScript("OnEvent", function(_, event)
        if event == "QUEST_WATCH_LIST_CHANGED" then
            KT_QuestMapFrame_UpdateQuestDetailsButtons()
        elseif event == "QUEST_REMOVED" then
            KT_QuestMapFrame_CloseQuestDetails()
        elseif event == "SUPER_TRACKING_CHANGED" then
            KT_QuestMapFrame_UpdateSuperTrackedQuest()
        end
    end)
    questMapFrame:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    questMapFrame:RegisterEvent("QUEST_REMOVED")
    questMapFrame:RegisterEvent("SUPER_TRACKING_CHANGED")

    local bg = questMapFrame:CreateTexture(nil, "BACKGROUND")
    if not C_AddOns.IsAddOnLoaded("ElvUI") then
        bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock")
    else
        bg:SetColorTexture(0, 0, 0)
    end
    bg:SetAllPoints()

    local logo = CreateFrame("Frame", nil, questMapFrame)
    logo:SetSize(26, 26)
    logo:SetPoint("TOP", -9, -10)
    logo:SetFrameLevel(10)
    logo.tex = logo:CreateTexture(nil, "ARTWORK")
    logo.tex:SetTexture(KT.MEDIA_PATH.."KT_logo")
    logo.tex:SetAllPoints()
    logo:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Quest Details created by |cffffd200"..KT.TITLE, 1, 1, 1)
        GameTooltip:Show()
    end)
    logo:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    KT_QuestsFrame:SetParent(questMapFrame)
    KT_QuestsFrame:SetPoint("TOPLEFT")
    KT_QuestsFrame:SetPoint("BOTTOMRIGHT", -21, 0)
    questMapFrame.DetailsFrame = KT_QuestsFrame.DetailsFrame

	-- DropDown frame
	dropDownFrame = MSA_DropDownMenu_Create(addonName.."QuestLogDropDown", QuestMapFrame)
	dropDownFrame.questID = 0  -- for QuestMapQuestOptionsDropDown_Initialize
	MSA_DropDownMenu_Initialize(dropDownFrame, QuestMapQuestOptionsDropDown_Initialize, "MENU")
end

-- External ------------------------------------------------------------------------------------------------------------

function M:OnInitialize()
	_DBG("|cffffff00Init|r - "..self:GetName(), true)
	db = KT.db.profile
	dbChar = KT.db.char
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetFrames()
    SetHooks()
end