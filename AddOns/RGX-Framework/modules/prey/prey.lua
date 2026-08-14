--=====================================================================================
-- RGX-Framework | RGXPrey
-- Prey hunt progression callbacks for addon authors.
--=====================================================================================

local addonName, RGX = ...

local Prey = {
    _eventsInit = false,
    _onHuntStarted = {},
    _onAmbush = {},
    _onCapped = {},
    _onComplete = {},
    lastState = {},
    cappedFired = {},
    activeQuestID = nil,
    knownVignettes = {},
}

local PREY_WIDGET_TYPE = Enum and Enum.UIWidgetVisualizationType and Enum.UIWidgetVisualizationType.PreyHuntProgress

local function AddCb(list, fn)
    if type(fn) ~= "function" then return nil end
    list[#list + 1] = fn
    return function()
        for i = #list, 1, -1 do
            if list[i] == fn then
                table.remove(list, i)
                return
            end
        end
    end
end

local function Fire(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then RGX:Debug("[RGXPrey] Callback error: " .. tostring(err)) end
    end
end

local function HasAPI()
    return PREY_WIDGET_TYPE ~= nil
        and C_UIWidgetManager
        and type(C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo) == "function"
end

function Prey:OnHuntStarted(fn) return AddCb(self._onHuntStarted, fn) end
function Prey:OnAmbush(fn) return AddCb(self._onAmbush, fn) end
function Prey:OnCapped(fn) return AddCb(self._onCapped, fn) end
function Prey:OnComplete(fn) return AddCb(self._onComplete, fn) end

function Prey:OnWidgetUpdate(widgetInfo)
    if not HasAPI() or not widgetInfo or widgetInfo.widgetType ~= PREY_WIDGET_TYPE then return end
    local info = C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo(widgetInfo.widgetID)
    if not info then return end

    local newState = info.progressState
    local lastState = self.lastState[widgetInfo.widgetID]
    if newState == lastState then return end
    self.lastState[widgetInfo.widgetID] = newState

    local states = Enum and Enum.PreyHuntProgressState or {}
    local Cold  = states.Cold  or 0
    local Warm  = states.Warm  or 1
    local Hot   = states.Hot   or 2
    local Final = states.Final or 3

    if newState == Final then
        if not self.cappedFired[widgetInfo.widgetID] then
            self.cappedFired[widgetInfo.widgetID] = true
            Fire(self._onCapped, widgetInfo.widgetID, info)
        end
    elseif newState == Hot then
        Fire(self._onAmbush, widgetInfo.widgetID, info, "widget")
    elseif newState == Warm and (lastState == nil or lastState == Cold) then
        self.cappedFired[widgetInfo.widgetID] = nil
        if C_QuestLog and C_QuestLog.GetActivePreyQuest then
            self.activeQuestID = C_QuestLog.GetActivePreyQuest()
        end
        Fire(self._onHuntStarted, widgetInfo.widgetID, info, self.activeQuestID)
    elseif newState == Cold then
        self.lastState[widgetInfo.widgetID] = nil
        self.cappedFired[widgetInfo.widgetID] = nil
    end
end

function Prey:OnQuestTurnedIn(questID, ...)
    if questID and questID == self.activeQuestID then
        self.activeQuestID = nil
        Fire(self._onComplete, questID, ...)
    end
end

function Prey:OnVignettesUpdated()
    if not C_VignetteInfo then return end
    local current = C_VignetteInfo.GetVignettes() or {}
    local currentSet = {}
    for _, guid in ipairs(current) do
        currentSet[guid] = true
        if not self.knownVignettes[guid] then
            local info = C_VignetteInfo.GetVignetteInfo(guid)
            if info and info.name then
                local name = string.lower(info.name)
                if name:find("prey") or name:find("ambush") or name:find("astalor") then
                    Fire(self._onAmbush, guid, info, "vignette")
                end
            end
        end
    end
    self.knownVignettes = currentSet
end

function Prey:Init()
    if self._eventsInit then return end
    self._eventsInit = true
    if not RGX:HasCapability("prey") or not HasAPI() then return end

    RGX:RegisterEvent("UPDATE_UI_WIDGET", function(_, widgetInfo) Prey:OnWidgetUpdate(widgetInfo) end, "RGXPrey_Widget")
    RGX:RegisterEvent("VIGNETTES_UPDATED", function() Prey:OnVignettesUpdated() end, "RGXPrey_Vignettes")
    RGX:RegisterEvent("QUEST_TURNED_IN", function(_, questID, ...) Prey:OnQuestTurnedIn(questID, ...) end, "RGXPrey_Quest")
end

_G.RGXPrey = Prey
RGX:RegisterModule("prey", Prey)
