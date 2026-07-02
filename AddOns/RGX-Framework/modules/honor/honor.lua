--=====================================================================================
-- RGX-Framework | RGXHonor
-- Honor level-up callbacks for addon authors.
--=====================================================================================

local addonName, RGX = ...

local Honor = {
    _eventsInit = false,
    _onLevelUp = {},
    currentHonorLevel = nil,
    pendingCheck = false,
}

local CHECK_DELAY_SECONDS = 0.20

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
        if not ok then RGX:Debug("[RGXHonor] Callback error: " .. tostring(err)) end
    end
end

local function GetCurrentHonorLevel()
    if type(UnitHonorLevel) ~= "function" then return 0 end
    local ok, value = pcall(UnitHonorLevel, "player")
    return ok and math.max(0, math.floor(tonumber(value) or 0)) or 0
end

function Honor:OnLevelUp(fn) return AddCb(self._onLevelUp, fn) end

function Honor:Evaluate(triggerName)
    local newLevel = GetCurrentHonorLevel()
    local oldLevel = self.currentHonorLevel
    self.currentHonorLevel = newLevel
    if oldLevel ~= nil and newLevel > oldLevel then
        Fire(self._onLevelUp, newLevel, oldLevel, triggerName)
    end
end

function Honor:QueueCheck(triggerName, delay)
    if self.pendingCheck then return end
    self.pendingCheck = true
    C_Timer.After(delay or CHECK_DELAY_SECONDS, function()
        self.pendingCheck = false
        Honor:Evaluate(triggerName)
    end)
end

function Honor:Init()
    if self._eventsInit then return end
    self._eventsInit = true
    self.currentHonorLevel = GetCurrentHonorLevel()

    local function queue(event) Honor:QueueCheck(event) end
    RGX:RegisterEvent("HONOR_LEVEL_UPDATE", queue, "RGXHonor_Level")
    RGX:RegisterEvent("PLAYER_PVP_RANK_CHANGED", queue, "RGXHonor_Rank")
    RGX:RegisterEvent("HONOR_XP_UPDATE", queue, "RGXHonor_XP")
    RGX:RegisterEvent("PLAYER_ENTERING_WORLD", function(event) Honor:QueueCheck(event, 1.0) end, "RGXHonor_Login")
end

_G.RGXHonor = Honor
RGX:RegisterModule("honor", Honor)
