--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class TravelersLog
local M = KT:NewModule("TravelersLog")
KT.TravelersLog = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local GameTooltip = GameTooltip

local db, dbChar

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHooks()
    KT_MonthlyActivitiesObjectiveTracker:HookScript("OnEvent", function(self, event, ...)
        if event == "PERKS_ACTIVITIES_TRACKED_LIST_CHANGED" then
            local _, added = ...
            if added then
                KT:Module_Expand(self)
            end
        end
    end)

    function KT_MonthlyActivitiesObjectiveTracker:OnBlockHeaderEnter(block)
        if not db.tooltipShow then return end

        local info = C_PerksActivities.GetPerksActivityInfo(block.id)
        if not info then return end

        KT.GameTooltip_SetPosition(block)

        GameTooltip_SetTitle(GameTooltip, info.activityName, NORMAL_FONT_COLOR)
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
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(REWARDS..":")
            GameTooltip:AddLine(FormatLargeNumber(info.thresholdContributionAmount).." "..MONTHLY_ACTIVITIES_POINTS, 1, 1, 1)
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

        KT.Menu_AddButton(OBJECTIVES_VIEW_IN_TRAVELERS_LOG, function()
            block.parentModule:OpenFrameToActivity(block.id)
        end)

        KT.Menu_AddButton(OBJECTIVES_STOP_TRACKING, function()
            block.parentModule:UntrackPerksActivity(block.id)
        end)

        KT:SendSignal("CONTEXT_MENU_UPDATE", info, "activity", block.id)
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
                KT.OpenService_Open("travelerslog", block.id)
            end

            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
        else
            KT_ObjectiveTracker_ToggleDropDown(block, OnOpenDropDown)
        end
    end

    function KT_MonthlyActivitiesObjectiveTracker:NormalizeObjective(text, dashStyle)  -- N
        text = string.gsub(text, "- ", "")
        dashStyle = KT_OBJECTIVE_DASH_STYLE_SHOW
        return text, dashStyle
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