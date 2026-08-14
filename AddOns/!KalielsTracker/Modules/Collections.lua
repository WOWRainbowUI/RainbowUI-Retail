--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class AdventureObjective
local M = KT:NewModule("AdventureObjective")
KT.AdventureObjective = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHooks()
    KT_AdventureObjectiveTracker:HookScript("OnEvent", function(self, event, ...)
        if event == "CONTENT_TRACKING_UPDATE" then
            local trackableType, _, added = ...
            if added and (trackableType == Enum.ContentTrackingType.Appearance or
                    trackableType == Enum.ContentTrackingType.Decor) then
                KT:Module_Expand(self)
            end
        end
    end)

    hooksecurefunc(KT_AdventureObjectiveTracker, "OnBlockHeaderEnter", function(self, block)
        if not db.tooltipShow then return end

        local info = KT.GetCollectibleItemInfo(block.trackableType, block.trackableID)
        if not info then return end

        KT.GameTooltip_SetPosition(block)

        GameTooltip:SetItemByID(info.itemID)

        if db.tooltipShowID then
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(" ", "ID: |cffffffff"..info.itemID)
        end

        GameTooltip:Show()
    end)

    hooksecurefunc(KT_AdventureObjectiveTracker, "OnBlockHeaderLeave", function(self, block)
        if db.tooltipShow then
            GameTooltip:Hide()
        end
    end)

    local bck_KT_AdventureObjectiveTracker_OpenToAppearance = KT_AdventureObjectiveTracker.OpenToAppearance
    function KT_AdventureObjectiveTracker:OpenToAppearance(appearanceID)
        if not KT.InCombatBlocked() then
            bck_KT_AdventureObjectiveTracker_OpenToAppearance(self, appearanceID)
        end
    end

    local function OnOpenDropDown(self)
        local block = self.activeFrame

        local info = KT.Menu_CreateInfo()
        KT.Menu_AddTitle(block.name)

        if block.trackableType == Enum.ContentTrackingType.Appearance then
            KT.Menu_AddButton(CONTENT_TRACKING_OPEN_JOURNAL_OPTION, function()
                block.parentModule:OpenToAppearance(block.trackableID)
            end)
        end

        KT.Menu_AddButton(OBJECTIVES_STOP_TRACKING, function()
            block.parentModule:Untrack(block.trackableType, block.trackableID)
        end)

        KT:SendSignal("CONTEXT_MENU_UPDATE", info, "item", block.trackableID, block.trackableType)
    end

    function KT_AdventureObjectiveTracker:OnBlockHeaderClick(block, mouseButton)  -- R
        if not ContentTrackingUtil.ProcessChatLink(block.trackableType, block.trackableID) then
            if mouseButton ~= "RightButton" then
                if ContentTrackingUtil.IsTrackingModifierDown() then
                    C_ContentTracking.StopTracking(block.trackableType, block.trackableID, Enum.ContentTrackingStopType.Manual);
                elseif IsModifiedClick(db.menuWowheadURLModifier) then
                    KT:Alert_WowheadURL("item", block.trackableID, block.trackableType)
                elseif (block.trackableType == Enum.ContentTrackingType.Appearance) and IsModifiedClick("DRESSUP") then
                    DressUpVisual(block.trackableID);
                elseif block.targetType == Enum.ContentTrackingTargetType.Achievement then
                    ShowAchievementFrameForAchievement(block.targetID);
                elseif block.targetType == Enum.ContentTrackingTargetType.Profession then
                    self:ClickProfessionTarget(block.targetID);
                else
                    KT.OpenService_Open("collectionitem", block.trackableType, block.trackableID)
                end

                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
            else
                KT_ObjectiveTracker_ToggleDropDown(block, OnOpenDropDown)
            end
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
    SetHooks()
end