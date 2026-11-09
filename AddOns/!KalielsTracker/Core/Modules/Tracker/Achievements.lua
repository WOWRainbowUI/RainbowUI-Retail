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

local function SetHeaderText()
    local suffix
    if db.achievsHeaderSuffix then
        suffix = GetTotalAchievementPoints()
    end
    KT_AchievementObjectiveTracker:SetHeaderSuffix(suffix)
end

local function SetupOptions()
    if not KT:Addon_IsModule(KT.Options) then return end

    KT.Options.AddModuleTab("achievements", {
        name = "Achievements",
        type = "group",
        order = 4,
        args = {
            header = {
                name = "Header",
                type = "group",
                inline = true,
                order = 1,
                args = {
                    achievsHeaderSuffix = {
                        name = "Show Achievement points",
                        desc = "Show Achievement points inside the Achievements header.",
                        type = "toggle",
                        width = "normal+half",
                        set = function()
                            db.achievsHeaderSuffix = not db.achievsHeaderSuffix
                            SetHeaderText()
                        end,
                        order = 1,
                    },
                },
            },
            content = {
                name = "Content",
                type = "group",
                inline = true,
                order = 2,
                args = {
                    achievsProgressAutoTrack = {
                        name = "Auto Achievement progress tracking",
                        desc = "Achievements are automatically watched when progress updated.",
                        type = "toggle",
                        width = "normal+half",
                        set = function()
                            db.achievsProgressAutoTrack = not db.achievsProgressAutoTrack
                        end,
                        order = 1,
                    },
                },
            },
        },
    })
end

local function SetHooks()
    KT_AchievementObjectiveTracker:HookScript("OnEvent", function(self, event, ...)
        if event == "CONTENT_TRACKING_UPDATE" then
            local trackableType, _, added = ...
            if added and not dbChar.filterAuto[2] and trackableType == Enum.ContentTrackingType.Achievement then
                KT:Module_Expand(self)
            end
        elseif event == "CRITERIA_EARNED" then
            local achievementID = ...
            if db.achievsProgressAutoTrack then
                KT.AddTrackedAchievement(achievementID)
            end
        elseif event == "ACHIEVEMENT_EARNED" then
            SetHeaderText()
        end
    end)
    KT_AchievementObjectiveTracker:RegisterEvent("CRITERIA_EARNED")

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

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    dbChar = KT.db.char
    self.isAvailable = true
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    KT:Tracker_RegisterModule("KT_AchievementObjectiveTracker", not self.isAvailable)

    SetupOptions()
    SetHooks()

    KT:RegSignal("TRACKER_INITIALIZING", SetHeaderText, self)
end