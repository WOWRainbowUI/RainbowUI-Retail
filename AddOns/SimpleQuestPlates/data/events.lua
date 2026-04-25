--=====================================================================================
-- RGX | Simple Quest Plates! - events.lua

-- Author: DonnieDice
-- Description: Event handling and management
--=====================================================================================

local addonName, SQP = ...

local RGX = _G.RGXFramework

-- ADDON_LOADED: Initialize saved variables and settings
function SQP:ADDON_LOADED(addon)
    if addon ~= addonName then return end
    
    self:LoadSettings()
    
    -- Reanchor existing plates after settings load
    for plate, questFrame in pairs(self.QuestPlates) do
        if questFrame then
            questFrame.icon:ClearAllPoints()
            questFrame.icon:SetPoint(
                SQPSettings.anchor or 'RIGHT',
                questFrame,
                SQPSettings.relativeTo or 'LEFT',
                (SQPSettings.offsetX or 0) / (SQPSettings.scale or 1),
                (SQPSettings.offsetY or 0) / (SQPSettings.scale or 1)
            )
            questFrame:SetScale(SQPSettings.scale or 1)
        end
    end
    
    RGX:UnregisterEvent("ADDON_LOADED", "SQP_ADDON_LOADED")
end

-- PLAYER_LOGIN: Initialize addon systems
function SQP:PLAYER_LOGIN()
    -- Welcome message (two-line SQP green format)
    local loadedLine = self.L["MSG_LOADED_LINE1"] or "Loaded successfully. Type |cfffff569/sqp help|r for commands."
    local versionLine = self.L["MSG_LOADED_LINE2"] or "|cfffff569Version:|r |cff7598b6v%s|r"
    self:PrintMessage(loadedLine)
    self:PrintMessage(string.format(versionLine, self.VERSION))
    
    -- Create options panel
    self:CreateOptionsPanel()
    self:ApplyMinimapVisibility()
    
    -- Load world quests
    self:LoadWorldQuests()
    
    -- Cache quest indexes
    self:CacheQuestIndexes()
end

-- Nameplate events
function SQP:NAME_PLATE_CREATED(plate)
    self:CreateQuestPlate(plate)
end

function SQP:NAME_PLATE_UNIT_ADDED(unitID)
    local plate = SQP.Compat.GetNamePlateForUnit(unitID)
    if plate then
        self:OnPlateShow(plate, unitID)
    end
end

function SQP:NAME_PLATE_UNIT_REMOVED(unitID)
    local plate = SQP.Compat.GetNamePlateForUnit(unitID)
    if plate then
        self:OnPlateHide(plate, unitID)
    end
end

-- Target/mouseover updates (helps tooltip-driven detection on Classic)
function SQP:PLAYER_TARGET_CHANGED()
    if UnitExists("target") then
        local plate = SQP.Compat.GetNamePlateForUnit and SQP.Compat.GetNamePlateForUnit("target")
        if plate then
            plate._unitID = "target"
            self:UpdateQuestIcon(plate, "target")
        end
    end
end

function SQP:UPDATE_MOUSEOVER_UNIT()
    if UnitExists("mouseover") then
        local plate = SQP.Compat.GetNamePlateForUnit and SQP.Compat.GetNamePlateForUnit("mouseover")
        if plate then
            plate._unitID = "mouseover"
            self:UpdateQuestIcon(plate, "mouseover")
        end
    end
end

-- Quest events with throttling
local questUpdateThrottle = 0
local QUEST_UPDATE_THROTTLE = 0.3  -- 300ms throttle

function SQP:UNIT_QUEST_LOG_CHANGED(unitID)
    -- Only process player quest changes, ignore group members
    if unitID == "player" then
        self:CacheQuestIndexes()
    end
    -- Removed unnecessary full refresh for non-player units
end

function SQP:QUEST_LOG_UPDATE()
    -- Throttle this spammy event
    local currentTime = GetTime()
    if currentTime - questUpdateThrottle < QUEST_UPDATE_THROTTLE then
        return
    end
    questUpdateThrottle = currentTime
    
    self:CacheQuestIndexes()
    self:RefreshAllNameplates()
end

function SQP:QUEST_ACCEPTED(questLogIndex, questID)
    if questID and C_QuestLog and C_QuestLog.IsQuestTask and C_QuestLog.IsQuestTask(questID) then
        local questName = C_TaskQuest and C_TaskQuest.GetQuestInfoByQuestID and C_TaskQuest.GetQuestInfoByQuestID(questID)
        if questName then
            self.ActiveWorldQuests[questName] = questID
        end
    end
    self:UNIT_QUEST_LOG_CHANGED('player')
end

function SQP:QUEST_REMOVED(questID)
    if C_TaskQuest and C_TaskQuest.GetQuestInfoByQuestID then
        local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
        if questName and self.ActiveWorldQuests[questName] then
            self.ActiveWorldQuests[questName] = nil
        end
    end
    self:UNIT_QUEST_LOG_CHANGED('player')
    self:RefreshAllNameplates()
end

function SQP:QUEST_COMPLETE()
    -- Quest objectives all met — refresh immediately so icons hide promptly
    self:RefreshAllNameplates()
end

function SQP:QUEST_WATCH_LIST_CHANGED(questID, added)
    self:QUEST_ACCEPTED(nil, questID)
end

-- World state events
function SQP:PLAYER_LEAVING_WORLD()
    RGX:UnregisterEvent("QUEST_LOG_UPDATE", "SQP_QUEST_LOG_UPDATE")
end

function SQP:PLAYER_ENTERING_WORLD()
    RGX:RegisterEvent("QUEST_LOG_UPDATE", function(event, ...) SQP:QUEST_LOG_UPDATE(...) end, "SQP_QUEST_LOG_UPDATE")
    -- Refresh all nameplates when entering world
    self:RefreshAllNameplates()
end

-- Combat state changes
function SQP:PLAYER_REGEN_DISABLED()
    -- Entered combat
    local animationMode = SQPSettings.animationCombatMode or "always"
    if SQPSettings.hideInCombat or animationMode ~= "always" then
        self:RefreshAllNameplates()
    end
end

function SQP:PLAYER_REGEN_ENABLED()
    -- Left combat
    local animationMode = SQPSettings.animationCombatMode or "always"
    if SQPSettings.hideInCombat or animationMode ~= "always" then
        self:RefreshAllNameplates()
    end
end

-- Register all events via RGX-Framework
RGX:RegisterEvent("ADDON_LOADED", function(event, ...) SQP:ADDON_LOADED(...) end, "SQP_ADDON_LOADED")
RGX:RegisterEvent("PLAYER_LOGIN", function(event, ...) SQP:PLAYER_LOGIN(...) end, "SQP_PLAYER_LOGIN")

-- Register nameplate events based on version
if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
    -- Modern nameplate API is available
    RGX:RegisterEvent("NAME_PLATE_CREATED", function(event, ...) SQP:NAME_PLATE_CREATED(...) end, "SQP_NAME_PLATE_CREATED")
    RGX:RegisterEvent("NAME_PLATE_UNIT_ADDED", function(event, ...) SQP:NAME_PLATE_UNIT_ADDED(...) end, "SQP_NAME_PLATE_UNIT_ADDED")
    RGX:RegisterEvent("NAME_PLATE_UNIT_REMOVED", function(event, ...) SQP:NAME_PLATE_UNIT_REMOVED(...) end, "SQP_NAME_PLATE_UNIT_REMOVED")
end
-- MoP and older versions use the OnUpdate script in compat_mop.lua

RGX:RegisterEvent("UNIT_QUEST_LOG_CHANGED", function(event, ...) SQP:UNIT_QUEST_LOG_CHANGED(...) end, "SQP_UNIT_QUEST_LOG_CHANGED")
RGX:RegisterEvent("QUEST_ACCEPTED", function(event, ...) SQP:QUEST_ACCEPTED(...) end, "SQP_QUEST_ACCEPTED")
RGX:RegisterEvent("QUEST_REMOVED", function(event, ...) SQP:QUEST_REMOVED(...) end, "SQP_QUEST_REMOVED")
RGX:RegisterEvent("QUEST_COMPLETE", function(event, ...) SQP:QUEST_COMPLETE(...) end, "SQP_QUEST_COMPLETE")
RGX:RegisterEvent("QUEST_WATCH_LIST_CHANGED", function(event, ...) SQP:QUEST_WATCH_LIST_CHANGED(...) end, "SQP_QUEST_WATCH_LIST_CHANGED")
RGX:RegisterEvent("PLAYER_LEAVING_WORLD", function(event, ...) SQP:PLAYER_LEAVING_WORLD(...) end, "SQP_PLAYER_LEAVING_WORLD")
RGX:RegisterEvent("PLAYER_ENTERING_WORLD", function(event, ...) SQP:PLAYER_ENTERING_WORLD(...) end, "SQP_PLAYER_ENTERING_WORLD")
RGX:RegisterEvent("PLAYER_REGEN_DISABLED", function(event, ...) SQP:PLAYER_REGEN_DISABLED(...) end, "SQP_PLAYER_REGEN_DISABLED")
RGX:RegisterEvent("PLAYER_REGEN_ENABLED", function(event, ...) SQP:PLAYER_REGEN_ENABLED(...) end, "SQP_PLAYER_REGEN_ENABLED")
RGX:RegisterEvent("PLAYER_TARGET_CHANGED", function(event, ...) SQP:PLAYER_TARGET_CHANGED(...) end, "SQP_PLAYER_TARGET_CHANGED")
RGX:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function(event, ...) SQP:UPDATE_MOUSEOVER_UNIT(...) end, "SQP_UPDATE_MOUSEOVER_UNIT")
