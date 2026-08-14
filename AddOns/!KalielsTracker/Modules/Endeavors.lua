--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Endeavors
local M = KT:NewModule("Endeavors")
KT.Endeavors = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local GameTooltip = GameTooltip

local db, dbChar

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHooks()
    KT_InitiativeTasksObjectiveTracker:HookScript("OnEvent", function(self, event, ...)
        if event == "INITIATIVE_TASKS_TRACKED_LIST_CHANGED" then
            local _, added = ...
            if added then
                KT:Module_Expand(self)
            end
        end
    end)

    function KT_InitiativeTasksObjectiveTracker:OnBlockHeaderEnter(block)
        if not db.tooltipShow then return end

        local info = C_NeighborhoodInitiative.GetInitiativeTaskInfo(block.id)
        if not info then return end

        KT.GameTooltip_SetPosition(block)

        if info.timesCompleted and info.timesCompleted > 0 and info.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableInfinite then
            GameTooltip_SetTitle(GameTooltip, HOUSING_DASHBOARD_REPEATABLE_TASK_TITLE_TOOLTIP_FORMAT:format(info.taskName, info.timesCompleted), NORMAL_FONT_COLOR)
        else
            GameTooltip_SetTitle(GameTooltip, info.taskName, NORMAL_FONT_COLOR)
        end
        if info.taskType == Enum.NeighborhoodInitiativeTaskType.RepeatableInfinite then
            GameTooltip_AddNormalLine(GameTooltip, HOUSING_ENDEAVOR_REPEATABLE_TASK)
        end
        GameTooltip:AddLine(" ")

        if info.description ~= "" then
            GameTooltip:AddLine(info.description, 1, 1, 1, true)
            GameTooltip:AddLine(" ")
        end

        GameTooltip:AddLine(REQUIREMENTS..":")
        for _, requirement in ipairs(info.requirementsList) do
            local tooltipLine = requirement.requirementText
            tooltipLine = string.gsub(tooltipLine, " / ", "/")
            local color = not requirement.completed and WHITE_FONT_COLOR or DISABLED_FONT_COLOR
            GameTooltip_AddColoredLine(GameTooltip, tooltipLine, color)
        end

        if db.tooltipShowRewards then
            local rewardQuestID = info.rewardQuestID
            if rewardQuestID then
                KT.GameTooltip_AddQuestRewardsToTooltip(GameTooltip, rewardQuestID)
            end
        end

        if db.tooltipShowID then
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..block.id)
        end

        GameTooltip:Show()
    end

    local function OnOpenDropDown(self)
        local block = self.activeFrame

        local info = KT.Menu_CreateInfo()
        KT.Menu_AddTitle(block.name)

        KT.Menu_AddButton(OBJECTIVES_VIEW_IN_ENDEAVORS_TAB, function()
            KT.OpenService_Open("endeavortask", block.id)
        end)

        KT.Menu_AddButton(OBJECTIVES_STOP_TRACKING, function()
            block.parentModule:UntrackInitiativeTask(block.id)
        end)
    end

    function KT_InitiativeTasksObjectiveTracker:OnBlockHeaderClick(block, mouseButton)  -- R
        if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
            local initiativeTaskLink = C_NeighborhoodInitiative.GetInitiativeTaskChatLink(block.id);
            ChatFrameUtil.InsertLink(initiativeTaskLink);
        elseif mouseButton ~= "RightButton" then
            if IsModifiedClick("QUESTWATCHTOGGLE") then
                self:UntrackInitiativeTask(block.id);
            else
                KT.OpenService_Open("endeavortask", block.id)
            end

            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        else
            KT_ObjectiveTracker_ToggleDropDown(block, OnOpenDropDown)
        end
    end

    function KT_InitiativeTasksObjectiveTracker:NormalizeObjective(text, dashStyle)  -- N
        return KT_MonthlyActivitiesObjectiveTracker.NormalizeObjective(self, text, dashStyle)
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
    SetHooks()
end