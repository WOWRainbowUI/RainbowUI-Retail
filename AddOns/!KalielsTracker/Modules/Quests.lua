--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Quests
local M = KT:NewModule("Quests")
KT.Quests = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local GameTooltip = GameTooltip

local db, dbChar
local tooltipUpdateQuestID = 0
local freeIcons = {}

-- Internal ------------------------------------------------------------------------------------------------------------

local function GetBlockIcon(block)
    local icon = block.icon
    if not icon then
        local numFreeIcons = #freeIcons
        if numFreeIcons > 0 then
            icon = freeIcons[numFreeIcons]
            tremove(freeIcons, numFreeIcons)
            icon:ClearAllPoints()
        else
            icon = CreateFrame("Frame", nil, block, "KT_ObjectiveTrackerBlockIconTemplate")
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

local function SetHooks()
    local function OnEvent(self, event, ...)
        if event == "QUEST_WATCH_LIST_CHANGED" then
            local questID, added = ...
            if added and KT:Module_IsCollapsed(self) then
                local quest = KT_QuestCache:Get(questID)
                if self:ShouldDisplayQuest(quest) then
                    KT:Module_Expand(self)
                end
            end
        end
    end
    KT_QuestObjectiveTracker:HookScript("OnEvent", OnEvent)
    KT_CampaignQuestObjectiveTracker:HookScript("OnEvent", OnEvent)

    hooksecurefunc(KT_QuestObjectiveTracker, "OnFreeBlock", function(self, block)
        block.questCompleted = nil
        KT.QuestButtons_Remove(block)
        RemoveBlockIcon(block)
    end)
    KT_CampaignQuestObjectiveTracker.OnFreeBlock = KT_QuestObjectiveTracker.OnFreeBlock

    function KT_QuestObjectiveTracker:UntrackQuest(questID)  -- N
        C_QuestLog.RemoveQuestWatch(questID)
        if db.questsAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
            KT.QuestSuperTracking_ChooseClosestQuest()
        end
    end
    KT_CampaignQuestObjectiveTracker.UntrackQuest = KT_QuestObjectiveTracker.UntrackQuest

    function KT_QuestObjectiveTracker:OnBlockHeaderEnter(block)
        if not db.tooltipShow then return end

        local questLink = GetQuestLink(block.id)
        if not questLink then return end

        KT.GameTooltip_SetPosition(block)

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

        if db.tooltipShowID then
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..block.id)
        end

        GameTooltip:Show()
    end
    KT_CampaignQuestObjectiveTracker.OnBlockHeaderEnter = KT_QuestObjectiveTracker.OnBlockHeaderEnter

    function KT_QuestObjectiveTracker:OnBlockHeaderLeave(block)
        if db.tooltipShow then
            tooltipUpdateQuestID = 0
            GameTooltip:Hide()
        end
    end
    KT_CampaignQuestObjectiveTracker.OnBlockHeaderLeave = KT_QuestObjectiveTracker.OnBlockHeaderLeave

    local function OnOpenDropDown(self)
        local block = self.activeFrame

        local info = KT.Menu_CreateInfo()
        KT.Menu_AddTitle(C_QuestLog.GetTitleForQuestID(block.id))

        local text, func
        if C_SuperTrack.GetSuperTrackedQuestID() ~= block.id then
            text = SUPER_TRACK_QUEST
            func = function()
                C_SuperTrack.SetSuperTrackedQuestID(block.id)
            end
        else
            text = STOP_SUPER_TRACK_QUEST
            func = function()
                C_SuperTrack.SetSuperTrackedQuestID(0)
            end
        end
        KT.Menu_AddButton(text, func)

        KT.Menu_AddButton(OBJECTIVES_SHOW_QUEST_MAP, function()
            KT.OpenService_Open("quest", block.id)
        end)

        if ( C_QuestLog.IsPushableQuest(block.id) and IsInGroup() ) then
            KT.Menu_AddButton(SHARE_QUEST, function()
                QuestUtil.ShareQuest(block.id)
            end)
        end

        KT.Menu_AddButton(OBJECTIVES_STOP_TRACKING, function()
            block.parentModule:UntrackQuest(block.id)
        end, (dbChar.filterAuto[1] ~= nil))

        info.disabled = false

        if C_QuestLog.CanAbandonQuest(block.id) then
            KT.Menu_AddButton(ABANDON_QUEST, function()
                QuestMapQuestOptions_AbandonQuest(block.id)
            end)
        end

        KT:SendSignal("CONTEXT_MENU_UPDATE", info, "quest", block.id)
    end

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
                local quest = KT_QuestCache:Get(questID);
                if quest.isAutoComplete and quest:IsComplete() then
                    self:RemoveAutoQuestPopUp(questID);
                    ShowQuestComplete(questID);
                else
                    KT.OpenService_Open("quest", questID)
                end
            end
        else
            KT_ObjectiveTracker_ToggleDropDown(block, OnOpenDropDown)
        end
    end
    KT_CampaignQuestObjectiveTracker.OnBlockHeaderClick = KT_QuestObjectiveTracker.OnBlockHeaderClick
end

-- External ------------------------------------------------------------------------------------------------------------

function M:SetHeaderText()
    local suffix
    if db.questsHeaderSuffix then
        local numOver = dbChar.quests.numOver > 0 and " +"..dbChar.quests.numOver or ""
        suffix = dbChar.quests.num.."/"..MAX_QUESTS..numOver
    end
    KT_QuestObjectiveTracker:SetHeaderSuffix(suffix)
end

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    dbChar = KT.db.char
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetHooks()
end