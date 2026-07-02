--=====================================================================================
-- RGX-Framework | RGXAchievement
-- Achievement and criteria completion callbacks for addon authors.
--=====================================================================================

local addonName, RGX = ...

local Achievement = {
    _eventsInit = false,
    _onEarned = {},
    _onCriteriaEarned = {},
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
        if not ok then RGX:Debug("[RGXAchievement] Callback error: " .. tostring(err)) end
    end
end

function Achievement:OnEarned(fn) return AddCb(self._onEarned, fn) end
function Achievement:OnCriteriaEarned(fn) return AddCb(self._onCriteriaEarned, fn) end

function Achievement:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    RGX:RegisterEvent("ACHIEVEMENT_EARNED", function(_, achievementID, alreadyEarned)
        if alreadyEarned then return end
        Fire(Achievement._onEarned, achievementID, alreadyEarned)
    end, "RGXAchievement_Earned")

    RGX:RegisterEvent("CRITERIA_EARNED", function(_, achievementID, description, earnedOnAccount)
        if earnedOnAccount then return end
        Fire(Achievement._onCriteriaEarned, achievementID, description, earnedOnAccount)
    end, "RGXAchievement_Criteria")
end

_G.RGXAchievement = Achievement
RGX:RegisterModule("achievement", Achievement)
