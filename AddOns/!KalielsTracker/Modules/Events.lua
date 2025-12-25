--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

---@class Events
local M = KT:NewModule("Events")
KT.Events = M

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

local db, dbChar
local OTF = KT_ObjectiveTrackerFrame
local EVENT_LONG_DURATION_LIMIT = 86400
local EVENT_LONG_DURATION = {}

local settings = {
    headerText = EVENTS_LABEL,
    events = { "EVENT_SCHEDULER_UPDATE" },
    blockTemplate = "KT_ObjectiveTrackerQuestPOIBlockTemplate",
    lineTemplate = "KT_ObjectiveTrackerAnimLineTemplate",
}

KT_EventObjectiveTrackerMixin = CreateFromMixins(KT_ObjectiveTrackerModuleMixin, settings)

-- Internal ------------------------------------------------------------------------------------------------------------

local function SetHooks()
    hooksecurefunc(KT.ObjectiveTrackerManager, "OnPlayerEnteringWorld", function(self, isInitialLogin, isReloadingUI)
        self:SetModuleContainer(KT_EventObjectiveTracker, OTF)
    end)

    -- fix Blizz bug
    local EVENT_MAPID = {
        [8174] = 2215,  -- Nightfall
        [8263] = 2346   -- Surge Pricing
    }
    local bck_C_EventScheduler_GetEventUiMapID = C_EventScheduler.GetEventUiMapID
    C_EventScheduler.GetEventUiMapID = function(areaPoiID)
        return bck_C_EventScheduler_GetEventUiMapID(areaPoiID) or EVENT_MAPID[areaPoiID]
    end
end

local function GetEventPOI(uiMapID, areaPoiID)
    local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, areaPoiID)
    if poiInfo then
        -- Stopgap to ensure that events don't contain widgets that are only intended for map display
        if poiInfo.tooltipWidgetSet == 1016 then
            poiInfo.tooltipWidgetSet = 1481
            poiInfo.description = nil
        end
    end

    return poiInfo
end

local function ShouldShowTimeLeft(poiInfo)
    if poiInfo.tooltipWidgetSet == 1355 then
        return false
    end
    return true
end

local function QuestMapFrame_OpenToEvent(poiID)
    QuestMapFrame:SetDisplayMode(QuestLogDisplayMode.Events)
    OpenMapToEventPoi(poiID)
end

-- External ------------------------------------------------------------------------------------------------------------

function KT_EventObjectiveTrackerMixin:InitModule()
    self.stopUpdate = false

    if not C_EventScheduler.HasData() then
        C_EventScheduler.RequestEvents()
    end
end

function KT_EventObjectiveTrackerMixin:OnEvent(event, ...)
    self:MarkDirty()
end

function KT_EventObjectiveTrackerMixin:OnFreeBlock(block)
    block.eventInfo = nil
end

function KT_EventObjectiveTrackerMixin:StopUpdate()
    if self.stopUpdate and dbChar.filter.events.track then
        self.stopUpdate = false
    end
    if self.stopUpdate or not C_PlayerInfo.CanPlayerUseEventScheduler() then
        return true
    end
    return false
end

function KT_EventObjectiveTrackerMixin:LayoutContents()
    if self.timer then
        self.timer:Cancel()
        self.timer = nil
    end
    self.nextUpdateTime = nil

    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
    self.tickerSeconds = 0

    if not dbChar.filter.events.track then
        self.stopUpdate = true
        return
    end

    -- Scheduled Events (active)
    local showLong = dbChar.filter.events.showLong
    local numLong = 0
    local scheduledEvents = C_EventScheduler.GetScheduledEvents()
    if scheduledEvents then
        local timeNow = time()
        for _, eventInfo in ipairs(scheduledEvents) do
            if not eventInfo.rewardsClaimed then
                local poiInfo = GetEventPOI(nil, eventInfo.areaPoiID)
                if poiInfo then
                    if eventInfo.startTime <= timeNow and eventInfo.endTime > timeNow then
                        local duration = eventInfo.endTime - eventInfo.startTime
                        local isShort = (duration < EVENT_LONG_DURATION_LIMIT)
                        if isShort then
                            self:AddEvent(poiInfo, eventInfo)
                        elseif showLong then
                            numLong = numLong + 1
                            EVENT_LONG_DURATION[numLong] = { poiInfo, eventInfo }
                        end
                    elseif eventInfo.startTime > timeNow then
                        if self.tickerSeconds == 0 then
                            self.nextUpdateTime = eventInfo.startTime
                        end
                        break
                    end
                end
            end
        end
        for i = 1, numLong do
            local poiInfo, eventInfo = EVENT_LONG_DURATION[i][1], EVENT_LONG_DURATION[i][2]
            self:AddEvent(poiInfo, eventInfo)
        end
    end

    -- Ongoing Events
    if showLong then
        local ongoingEvents = C_EventScheduler.GetOngoingEvents()
        if ongoingEvents then
            for _, eventInfo in ipairs(ongoingEvents) do
                if not eventInfo.rewardsClaimed then
                    local uiMapID = nil
                    local poiInfo = GetEventPOI(uiMapID, eventInfo.areaPoiID)
                    if poiInfo then
                        self:AddEvent(poiInfo)
                    end
                end
            end
        end
    end

    if self.tickerSeconds > 0 then
        self.ticker = C_Timer.NewTicker(self.tickerSeconds, function()
            self:MarkDirty()
        end)
    end

    if self.nextUpdateTime then
        self.timer = C_Timer.NewTimer(self.nextUpdateTime - time(), function()
            self:MarkDirty()
        end)
    end
end

function KT_EventObjectiveTrackerMixin:TryAddingExpirationWarningLine(block)
    if block.showTimeLeft then
        local timeLeftSeconds = block.eventInfo.endTime - time()
        local text = ""
        if timeLeftSeconds > 0 and self.tickerSeconds then
            local timeString = SecondsToTime(timeLeftSeconds)
            text = BONUS_OBJECTIVE_TIME_LEFT:format(timeString)
            self.tickerSeconds = 1
        end
        local line = block:AddObjective("State", text, nil, nil, KT_OBJECTIVE_DASH_STYLE_HIDE, KT_OBJECTIVE_TRACKER_COLOR["TimeLeft2"], true)
        line.Icon:Hide()
    end
end

function KT_EventObjectiveTrackerMixin:AddEvent(poiInfo, eventInfo)
    local poiID = poiInfo.areaPoiID
    local zoneName = C_EventScheduler.GetEventZoneName(poiID)
    local block = self:GetBlock(poiID)
    block.eventInfo = eventInfo
    block.showTimeLeft = eventInfo and ShouldShowTimeLeft(poiInfo)

    block:SetHeader(poiInfo.name)

    local isComplete = false
    local _, superTrackedID = C_SuperTrack.GetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI)
    local isSuperTracked = (poiID == superTrackedID)
    local isWorldQuest = false
    block:SetPOIInfo(0, isComplete, isSuperTracked, isWorldQuest, poiInfo)

    if zoneName then
        block:AddObjective("Zone", zoneName, nil, nil, KT_OBJECTIVE_DASH_STYLE_HIDE, KT_OBJECTIVE_TRACKER_COLOR["Normal"])
    end
    self:TryAddingExpirationWarningLine(block)

    return self:LayoutBlock(block)
end

function KT_EventObjectiveTrackerMixin:OnBlockHeaderClick(block, mouseButton)
    if mouseButton ~= "RightButton" then
        QuestMapFrame_OpenToEvent(block.id)
    else
        KT_ObjectiveTracker_ToggleDropDown(block, KT_EventObjectiveTracker_OnOpenDropDown)
    end
end

function KT_EventObjectiveTracker_OnOpenDropDown(self)
    local block = self.activeFrame

    local info = MSA_DropDownMenu_CreateInfo()
    info.text = block.poiInfo.name
    info.isTitle = 1
    info.notCheckable = 1
    MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)

    info = MSA_DropDownMenu_CreateInfo()
    info.notCheckable = 1

    local _, areaPoiID = C_SuperTrack.GetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI)
    if areaPoiID ~= block.id then
        info.text = POI_FOCUS
        info.func = function()
            C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI, block.id)
        end
    else
        info.text = POI_REMOVE_FOCUS
        info.func = function()
            C_SuperTrack.ClearSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI)
        end
    end
    MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)

    info.text = OBJECTIVES_SHOW_QUEST_MAP
    info.func = function()
        QuestMapFrame_OpenToEvent(block.id)
    end
    info.checked = false
    info.noClickSound = 1
    MSA_DropDownMenu_AddButton(info, MSA_DROPDOWN_MENU_LEVEL)
end

function M:OnInitialize()
    _DBG("|cffffff00Init|r - "..self:GetName(), true)
    db = KT.db.profile
    dbChar = KT.db.char
    self.isAvailable = true

    if self.isAvailable then
        tinsert(KT.MODULES, "KT_EventObjectiveTracker")
        KT.db:RegisterDefaults(KT.db.defaults)
    end
end

function M:OnEnable()
    _DBG("|cff00ff00Enable|r - "..self:GetName(), true)
    SetHooks()
end