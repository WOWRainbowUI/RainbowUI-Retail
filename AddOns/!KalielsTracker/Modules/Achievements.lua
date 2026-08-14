--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Achievements
local M = KT:NewModule("Achievements")
KT.Achievements = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local GameTooltip = GameTooltip

local db, dbChar

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHooks()
    KT_AchievementObjectiveTracker:HookScript("OnEvent", function(self, event, ...)
        if event == "CONTENT_TRACKING_UPDATE" then
            local trackableType, _, added = ...
            if added and trackableType == Enum.ContentTrackingType.Achievement then
                KT:Module_Expand(self)
            end
        end
    end)

    function KT_AchievementObjectiveTracker:OnBlockHeaderEnter(block)
        if not db.tooltipShow then return end

        local achievementLink = GetAchievementLink(block.id)
        if not achievementLink then return end

        KT.GameTooltip_SetPosition(block)

        GameTooltip:SetHyperlink(achievementLink)

        if db.tooltipShowID then
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..block.id)
        end

        GameTooltip:Show()
    end

    local function OnOpenDropDown(self)
        local block = self.activeFrame
        local _, achievementName = GetAchievementInfo(block.id)

        local info = KT.Menu_CreateInfo()
        KT.Menu_AddTitle(achievementName)

        KT.Menu_AddButton(OBJECTIVES_VIEW_ACHIEVEMENT, function()
            KT.OpenService_Open("achievement", block.id)
        end)

        KT.Menu_AddButton(OBJECTIVES_STOP_TRACKING, function()
            block.parentModule:UntrackAchievement(block.id)
        end, (dbChar.filterAuto[2] ~= nil))

        info.disabled = false

        KT:SendSignal("CONTEXT_MENU_UPDATE", info, "achievement", block.id)
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
            else
                KT.OpenService_Open("achievement", achievementID)
            end
        else
            KT_ObjectiveTracker_ToggleDropDown(block, OnOpenDropDown)
        end
    end
end

-- External ------------------------------------------------------------------------------------------------------------

function M:SetHeaderText()
    local suffix
    if db.achievsHeaderSuffix then
        suffix = GetTotalAchievementPoints()
    end
    KT_AchievementObjectiveTracker:SetHeaderSuffix(suffix)
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