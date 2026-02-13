local env = select(2, ...)
local Utils_General = env.WPM:New("wpm_modules\\utils\\general")

local GetCursorPosition = GetCursorPosition

function Utils_General.GetMouseDelta(originX, originY)
    local mouseX, mouseY = GetCursorPosition()
    local deltaX = mouseX - originX
    local deltaY = originY - mouseY
    return deltaX, deltaY
end
