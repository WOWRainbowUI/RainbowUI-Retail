--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Hacks
local M = KT:NewModule("Hacks")
KT.Hacks = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- WoW API
local InCombatLockdown = InCombatLockdown

local db

local function Noop() end

-- Group Finder
-- Affects the small Eye buttons for finding groups inside the tracker. When the hack is active,
-- the buttons work without errors. When the hack is inactive, the buttons are not available.
-- Negative impacts:
-- - Inside the dialog for create "Premade Group", the "Title" is not set automatically (e.g. keystone level for Mythic+).
local function Hack_LFG()
    if db.hackLFG then
        -- LFGList.lua
        local bck_LFGListEntryCreation_SetTitleFromActivityInfo = LFGListEntryCreation_SetTitleFromActivityInfo
        LFGListEntryCreation_SetTitleFromActivityInfo = function(self, ...)
            local activityID = self.selectedActivity or 0
            local activityInfo =  C_LFGList.GetActivityInfoTable(activityID)
            if activityInfo and activityInfo.isMythicPlusActivity then
                return
            else
                bck_LFGListEntryCreation_SetTitleFromActivityInfo(self, ...)
            end
        end
    end
end

-- World Map
-- Affects the World Map and removes taint errors. The hack prevents calls to restricted functions.
-- When the hack is inactive, the World Map display causes errors. It is not possible to get rid of these errors,
-- since the tracker has a lot of interaction with the game frames.
-- Negative impacts: unknown in WoW 11.2.7
local function Hack_WorldMap()
    if db.hackWorldMap then
        -- Blizzard_MapCanvas.lua
        local function OnPinReleased(pinPool, pin)
            local map = pin:GetMap();
            if map then
                map:UnregisterPin(pin);
            end
            Pool_HideAndClearAnchors(pinPool, pin);
            pin:OnReleased();
            pin.pinTemplate = nil;
            pin:SetOwningMap(nil);
        end

        local function OnPinMouseUp(pin, button, upInside)
            pin:OnMouseUp(button, upInside);
            if upInside then
                pin:OnClick(button);
            end
        end

        local function HackAcquirePin(mapFrame)
            function mapFrame:AcquirePin(pinTemplate, ...)  -- R
                if not self.pinPools[pinTemplate] then
                    local pinTemplateType = self:GetPinTemplateType(pinTemplate);
                    self.pinPools[pinTemplate] = CreateFramePool(pinTemplateType, self:GetCanvas(), pinTemplate, OnPinReleased);
                end

                local pin, newPin = self.pinPools[pinTemplate]:Acquire();

                pin.pinTemplate = pinTemplate;
                pin:SetOwningMap(self);

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
                end

                pin.CheckMouseButtonPassthrough = Noop
                pin.UpdateMousePropagation = Noop

                self.ScrollContainer:MarkCanvasDirty();
                pin:Show();
                pin:OnAcquired(...);
                self:RegisterPin(pin);

                return pin;
            end
        end

        HackAcquirePin(WorldMapFrame)

        KT:RegEvent("ADDON_LOADED", function(eventID, addon)
            if addon == "Blizzard_FlightMap" then
                HackAcquirePin(FlightMapFrame)
                KT:UnregEvent(eventID)
            end
        end, M)

        KT:RegEvent("ADDON_LOADED", function(eventID, addon)
            if addon == "Blizzard_BattlefieldMap" then
                HackAcquirePin(BattlefieldMapFrame)
                KT:UnregEvent(eventID)
            end
        end, M)
    end
end

-- Open/Close tainted frames during combat
-- Negative impacts: unknown
local function Hack_TaintedFrames()
    local activeFrame
    local bypassFrames = {
        WorldMapFrame = true,
        QuestLogPopupDetailFrame = true,
        AchievementFrame = true,
        EncounterJournal = true,
        PVEFrame = true,
    }

    local function IsBypassFrame(frame)
        return frame and bypassFrames[frame:GetName()] or false
    end

    hooksecurefunc("ShowUIPanel", function(frame)
        if InCombatLockdown() and IsBypassFrame(frame) and not frame:IsShown() then
            if activeFrame and activeFrame ~= frame then
                activeFrame:Hide()
            end
            frame:Show()
            activeFrame = frame
        end
    end)

    hooksecurefunc("HideUIPanel", function(frame)
        if InCombatLockdown() and IsBypassFrame(frame) and frame:IsShown() then
            frame:Hide()
            if activeFrame == frame then
                activeFrame = nil
            end
        end
    end)

    local function InitFrame(frame, x, y)
        if not frame then return end
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x or 16, y or -116)
        tinsert(UISpecialFrames, frame:GetName())
    end

    KT:RegEvent("PLAYER_ENTERING_WORLD", function(eventID)
        InitFrame(WorldMapFrame)
        InitFrame(QuestLogPopupDetailFrame)
        InitFrame(PVEFrame)
        KT:UnregEvent(eventID)
    end, M)

    KT:RegEvent("ADDON_LOADED", function(eventID, addon)
        if addon == "Blizzard_AchievementUI" then
            InitFrame(AchievementFrame, 96)
            KT:UnregEvent(eventID)
        end
    end, M)

    KT:RegEvent("ADDON_LOADED", function(eventID, addon)
        if addon == "Blizzard_EncounterJournal" then
            InitFrame(EncounterJournal)
            KT:UnregEvent(eventID)
        end
    end, M)
end

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    self.isAvailable = true

    if self.isAvailable then
        Hack_LFG()
        Hack_WorldMap()
        Hack_TaintedFrames()
    end
end