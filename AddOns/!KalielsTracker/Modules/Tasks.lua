--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Tasks
local M = KT:NewModule("Tasks")
KT.Tasks = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local GameTooltip = GameTooltip

local db, dbChar

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHooks()
    local function HasQuestClassification(questID, classification)
        return C_QuestInfoSystem.GetQuestClassification(questID) == classification
    end

    KT_BonusObjectiveTracker:HookScript("OnEvent", function(self, event, ...)
        if event == "QUEST_ACCEPTED" then
            local questID = ...
            if KT:Module_IsCollapsed(self) and
                    HasQuestClassification(questID, Enum.QuestClassification.BonusObjective) then
                KT:Module_Expand(self)
            end
        end
    end)

    KT_WorldQuestObjectiveTracker:HookScript("OnEvent", function(self, event, ...)
        if event == "QUEST_ACCEPTED" then
            local questID = ...
            if KT:Module_IsCollapsed(self) and
                    HasQuestClassification(questID, Enum.QuestClassification.WorldQuest) then
                KT:Module_Expand(self)
            end
        elseif event == "QUEST_WATCH_LIST_CHANGED" then
            local questID, added = ...
            if added and KT:Module_IsCollapsed(self) and
                    HasQuestClassification(questID, Enum.QuestClassification.WorldQuest) then
                KT:Module_Expand(self)
            end
        end
    end)

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

            KT.GameTooltip_SetPosition(self)

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

    hooksecurefunc(KT_BonusObjectiveTracker, "OnQuestRemoved", function(self, questID)
        local block = self:GetExistingBlock(questID)
        if block then
            KT.QuestButtons_Remove(block)
        end
    end)

    hooksecurefunc(KT_BonusObjectiveTracker, "OnQuestTurnedIn", function(self, questID)
        local block = self:GetExistingBlock(questID)
        if block then
            KT.QuestButtons_Remove(block)
        end
    end)
    KT_WorldQuestObjectiveTracker.OnQuestTurnedIn = KT_BonusObjectiveTracker.OnQuestTurnedIn

    hooksecurefunc(QuestUtil, "UntrackWorldQuest", function(questID)
        if db.questsAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then
            KT.QuestSuperTracking_ChooseClosestQuest()
        end
    end)

    hooksecurefunc(KT_BonusObjectiveTracker, "OnFreeBlock", function(self, block)
        KT.QuestButtons_Remove(block)
    end)
    KT_WorldQuestObjectiveTracker.OnFreeBlock = KT_BonusObjectiveTracker.OnFreeBlock

    function KT_BonusObjectiveTrackerProgressBarMixin:UpdateReward()  -- R
        self.needsReward = nil
        self.Bar.Icon:Hide()
        self.Bar.IconBG:Hide()
    end

    KT_BonusObjectiveTrackerProgressBarMixin.PlayFlareAnim = function() end

    local function SetSuperTrackedEventPoiID(poiID)
        if poiID then
            C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI, poiID)
        end
    end

    local function OnOpenDropDown(self)
        local block = self.activeFrame
        local questID = block.id
        local addStopTracking = QuestUtils_IsQuestWatched(questID)

        local info = KT.Menu_CreateInfo()
        info.isTask = true
        KT.Menu_AddTitle(C_TaskQuest.GetQuestInfoByQuestID(questID) or C_QuestLog.GetTitleForQuestID(questID))

        local isWorldQuest = block.parentModule.showWorldQuests
        local isThreatQuest = C_QuestLog.IsThreatQuest(questID)
        local areaPoiID = KT.GetAreaPoiID(block.poiInfo)
        local text, func
        if isWorldQuest or isThreatQuest or not areaPoiID then
            if C_SuperTrack.GetSuperTrackedQuestID() ~= questID then
                text = SUPER_TRACK_QUEST
                func = function()
                    C_SuperTrack.SetSuperTrackedQuestID(questID)
                end
            else
                text = STOP_SUPER_TRACK_QUEST
                func = function()
                    C_SuperTrack.SetSuperTrackedQuestID(0)
                end
            end
        else
            local _, superTrackedPoiID = C_SuperTrack.GetSuperTrackedMapPin()
            if areaPoiID ~= superTrackedPoiID then
                text = SUPER_TRACK_QUEST
                func = function()
                    SetSuperTrackedEventPoiID(areaPoiID)
                end
            else
                text = STOP_SUPER_TRACK_QUEST
                func = function()
                    C_SuperTrack.ClearSuperTrackedMapPin()
                end
            end
        end
        KT.Menu_AddButton(text, func)

        -- Add "stop tracking"
        if addStopTracking then
            KT.Menu_AddButton(OBJECTIVES_STOP_TRACKING, function()
                QuestUtil.UntrackWorldQuest(questID)
            end)
        end

        KT:SendSignal("CONTEXT_MENU_UPDATE", info, "quest", questID)
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
                    if block.poiInfo and block.poiInfo.areaPoiID then
                        KT.OpenService_Open("bonusquest", questID, block.poiInfo.areaPoiID)
                    else
                        KT.OpenService_Open("bonusquest", questID)
                    end
                end
            end
        elseif button == "RightButton" then
            KT_ObjectiveTracker_ToggleDropDown(block, OnOpenDropDown)
        end
    end
    KT_WorldQuestObjectiveTracker.OnBlockHeaderClick = KT_BonusObjectiveTracker.OnBlockHeaderClick
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
    SetHooks()
end