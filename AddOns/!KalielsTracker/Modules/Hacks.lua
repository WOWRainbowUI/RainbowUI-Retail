--- Kaliel's Tracker
--- Copyright (c) 2012-2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local M = KT:NewModule("Hacks")
KT.Hacks = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local InCombatLockdown = InCombatLockdown

local db

-- LFGList.lua
-- Affects the small Eye buttons for finding groups inside the tracker. When the hack is active,
-- the buttons work without errors. When hack is inactive, the buttons are not available.
-- Negative impacts:
-- - Inside the dialog for create Premade Group is hidden item "Goal".
-- - Tooltips of items in the list of Premade Groups have a hidden 2nd (green) row with "Goal".
-- - Inside the dialog for create Premade Group, no automatically set the "Title", e.g. keystone level for Mythic+.
local function Hack_LFG()
    if db.hackLFG then
        local bck_C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
        function C_LFGList.GetSearchResultInfo(resultID)
            local searchResultInfo = bck_C_LFGList_GetSearchResultInfo(resultID)
            if searchResultInfo then
                searchResultInfo.playstyle = 0
            end
            return searchResultInfo
        end

        local bck_C_LFGList_GetLfgCategoryInfo = C_LFGList.GetLfgCategoryInfo
        function C_LFGList.GetLfgCategoryInfo(categoryID)
            local categoryInfo = bck_C_LFGList_GetLfgCategoryInfo(categoryID)
            if categoryInfo then
                categoryInfo.showPlaystyleDropdown = false
            end
            return categoryInfo
        end

        LFGListEntryCreation_OnPlayStyleSelected = function() end

        LFGListEntryCreation_SetTitleFromActivityInfo = function() end
    else
        function KT_QuestObjectiveSetupBlockButton_FindGroup(block, questID)
            return false
        end
    end
end

-- World Map
-- Affects World Map and removes taint errors. The hack removes call of restricted function SetPassThroughButtons.
-- When the hack is inactive World Map display causes errors. It is not possible to get rid of these errors, since
-- the tracker has a lot of interaction with the game frames.
-- Negative impacts: unknown in WoW 11.0.7
local function Hack_WorldMap()
    if db.hackWorldMap then
        -- Blizzard_MapCanvas.lua
        local function OnPinReleased(pinPool, pin)
            Pool_HideAndClearAnchors(pinPool, pin);
            pin:OnReleased();
            pin.pinTemplate = nil;
            pin.owningMap = nil;
        end

        local function OnPinMouseUp(pin, button, upInside)
            pin:OnMouseUp(button, upInside);
            if upInside then
                pin:OnClick(button);
            end
        end

        function WorldMapFrame:AcquirePin(pinTemplate, ...)  -- R
            if not self.pinPools[pinTemplate] then
                local pinTemplateType = self:GetPinTemplateType(pinTemplate);
                self.pinPools[pinTemplate] = CreateFramePool(pinTemplateType, self:GetCanvas(), pinTemplate, OnPinReleased);
            end

            local pin, newPin = self.pinPools[pinTemplate]:Acquire();

            pin.pinTemplate = pinTemplate;
            pin.owningMap = self;

            if newPin then
                local isMouseClickEnabled = pin:IsMouseClickEnabled();
                local isMouseMotionEnabled = pin:IsMouseMotionEnabled();

                if isMouseClickEnabled then
                    pin:SetScript("OnMouseUp", OnPinMouseUp);
                    pin:SetScript("OnMouseDown", pin.OnMouseDown);

                    -- Prevent OnClick handlers from being run twice, once a frame is in the mapCanvas ecosystem it needs
                    -- to process mouse events only via the map system.
                    if pin:IsObjectType("Button") then
                        pin:SetScript("OnClick", nil);
                    end
                end

                if isMouseMotionEnabled then
                    if newPin and not pin:DisableInheritedMotionScriptsWarning() then
                        -- These will never be called, just define a OnMouseEnter and OnMouseLeave on the pin mixin and it'll be called when appropriate
                        assert(pin:GetScript("OnEnter") == nil);
                        assert(pin:GetScript("OnLeave") == nil);
                    end
                    pin:SetScript("OnEnter", pin.OnMouseEnter);
                    pin:SetScript("OnLeave", pin.OnMouseLeave);
                end

                pin:SetMouseClickEnabled(isMouseClickEnabled);
                pin:SetMouseMotionEnabled(isMouseMotionEnabled);
            end

            if newPin then
                pin:OnLoad();
                pin.CheckMouseButtonPassthrough = function() end
                pin.UpdateMousePropagation = function() end
            end

            self.ScrollContainer:MarkCanvasDirty();
            pin:Show();
            pin:OnAcquired(...);

            return pin;
        end
    end
end

-- Open/Close tainted frames during combat
-- Negative impacts: unknown
local function Hack_TaintedFrames()
    local activeFrame

    hooksecurefunc("ShowUIPanel", function(frame)
        if InCombatLockdown() and frame then
            if frame == WorldMapFrame or
                    frame == QuestLogPopupDetailFrame or
                    frame == AchievementFrame or
                    frame == EncounterJournal or
                    frame == PVEFrame then
                if not frame:IsShown() then
                    if activeFrame then
                        activeFrame:Hide()
                    end
                    frame:Show()
                    activeFrame = frame
                end
            end
        end
    end)

    hooksecurefunc("HideUIPanel", function(frame)
        if InCombatLockdown() and frame then
            if frame == WorldMapFrame or
                    frame == QuestLogPopupDetailFrame or
                    frame == AchievementFrame or
                    frame == EncounterJournal or
                    frame == PVEFrame then
                if frame:IsShown() then
                    frame:Hide()
                    activeFrame = nil
                end
            end
        end
    end)

    KT:RegEvent("PLAYER_ENTERING_WORLD", function(eventID)
        WorldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -116)
        QuestLogPopupDetailFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -116)
        PVEFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -116)
        tinsert(UISpecialFrames, "WorldMapFrame")
        tinsert(UISpecialFrames, "QuestLogPopupDetailFrame")
        tinsert(UISpecialFrames, "PVEFrame")
        KT:UnregEvent(eventID)
    end)

    KT:RegEvent("ADDON_LOADED", function(eventID, addon)
        if addon == "Blizzard_AchievementUI" then
            AchievementFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 96, -116)
            tinsert(UISpecialFrames, "AchievementFrame")
            KT:UnregEvent(eventID)
        end
    end)

    KT:RegEvent("ADDON_LOADED", function(eventID, addon)
        if addon == "Blizzard_EncounterJournal" then
            EncounterJournal:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -116)
            tinsert(UISpecialFrames, "EncounterJournal")
            KT:UnregEvent(eventID)
        end
    end)
end

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile

    Hack_LFG()
    Hack_WorldMap()
    Hack_TaintedFrames()
end