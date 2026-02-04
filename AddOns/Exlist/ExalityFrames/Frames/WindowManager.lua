local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesWindowManager
local windowManager = EXFrames:GetFrame('window-manager')

windowManager.activeWindows = {}

windowManager.windowMargin = 20

---@param self ExalityFramesWindowManager
---@param window Frame
windowManager.RegisterWindow = function(self, window)
    table.insert(self.activeWindows, window)
end

---@param self ExalityFramesWindowManager
---@param windowToShow Frame
windowManager.SetValidCenterPosition = function(self, windowToShow)
    local screenWidth = GetScreenWidth()
    local centerPoint = Round(screenWidth / 2)
    local reservedLeft, reservedRight = centerPoint, centerPoint
    local showWindowWidth = windowToShow:GetWidth()
    local isAnyActive = false
    -- We only care about putting them left or right for now
    for _, window in pairs(self.activeWindows) do
        if (window:IsShown() and window ~= windowToShow) then
            isAnyActive = true
            local left, _, width = window:GetBoundsRect();
            if (left < reservedLeft) then
                reservedLeft = left
            end
            local right = left + width
            if (right > reservedRight) then
                reservedRight = right
            end
        end
    end

    if (not isAnyActive) then
        return
    end

    windowToShow:ClearAllPoints()
    if ((screenWidth - reservedRight) > showWindowWidth) then
        -- First check if we can put frame on right
        windowToShow:SetPoint('CENTER', reservedRight - centerPoint + showWindowWidth / 2 + self.windowMargin, 0)
    elseif ((screenWidth - reservedLeft) > showWindowWidth) then
        -- Second check if we can put frame on left
        windowToShow:SetPoint('CENTER', reservedLeft - centerPoint - showWindowWidth / 2 - self.windowMargin, 0)
    else
        -- Just put it in middle and a bit offset. let user drag
        windowToShow:SetPoint('CENTER', 300, 300)
    end
end
