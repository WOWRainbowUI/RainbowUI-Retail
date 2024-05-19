---@class RemixGemHelperPrivate
local Private = select(2, ...)
local const = Private.constants
local cache = Private.Cache

local misc = {
    clickThrottles = {}
}
Private.Misc = misc

---@param percent number
---@return ColorMixin
function misc:GetPercentColor(percent)
    if percent == 100 then
        return const.COLORS.POSITIVE
    end
    if percent >= 50 then
        return const.COLORS.NEUTRAL
    end
    return const.COLORS.NEGATIVE
end

function misc:PrintError(message, ...)
    message = (... and string.format(message, ...) or message or "")
    UIErrorsFrame:AddExternalErrorMessage(message)
end

---@param clickType any
---@return boolean
function misc:IsAllowedForClick(clickType)
    local currentTime = GetTime()
    if not self.clickThrottles[clickType] then
        self.clickThrottles[clickType] = currentTime
        return true
    end
    if self.clickThrottles[clickType] + .5 < currentTime then
        self.clickThrottles[clickType] = currentTime
        return true
    end
    if self.clickThrottles[clickType] + .25 < currentTime then
        self:PrintError("You're clicking too fast")
    end
    return false
end

function misc.ItemSorting(a, b)
    local cachedA = cache:GetItemInfo(a.itemID)
    local cachedB = cache:GetItemInfo(b.itemID)
    if cachedA.quality ~= cachedB.quality then
        return cachedA.quality > cachedB.quality
    end
    return cachedA.name < cachedB.name
end
