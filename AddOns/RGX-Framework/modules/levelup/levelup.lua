--=====================================================================================
-- RGX-Framework | RGXLevelUp
-- Character level-up callbacks for addon authors.
--=====================================================================================

local addonName, RGX = ...

local LevelUp = {
    _eventsInit = false,
    _onLevelUp = {},
}

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
        if not ok then RGX:Debug("[RGXLevelUp] Callback error: " .. tostring(err)) end
    end
end

function LevelUp:OnLevelUp(fn) return AddCb(self._onLevelUp, fn) end

function LevelUp:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    RGX:RegisterEvent("PLAYER_LEVEL_UP", function(_, level, ...)
        Fire(LevelUp._onLevelUp, level, ...)
    end, "RGXLevelUp_Player")
end

_G.RGXLevelUp = LevelUp
RGX:RegisterModule("levelup", LevelUp)
