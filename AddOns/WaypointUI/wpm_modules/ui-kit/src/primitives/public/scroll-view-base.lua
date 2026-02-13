local env = select(2, ...)
local UIKit_Primitives_ScrollBase = env.WPM:New("wpm_modules\\ui-kit\\primitives\\scroll-view-base")

local CreateFrame = CreateFrame
local abs = math.abs
local exp = math.exp
local max = math.max
local min = math.min
local IsShiftKeyDown = IsShiftKeyDown


local STOP_EPSILON = 0.05

function UIKit_Primitives_ScrollBase.UpdateContentExtentEvents(container)
    local scrollFrame = container.__ScrollFrame
    local contentFrame = container.__ContentFrame

    local verticalScroll = scrollFrame:GetVerticalScroll()
    local horizontalScroll = scrollFrame:GetHorizontalScroll()
    local scrollFrameHeight = scrollFrame:GetHeight()
    local scrollFrameWidth = scrollFrame:GetWidth()
    local contentFrameHeight = contentFrame:GetHeight()
    local contentFrameWidth = contentFrame:GetWidth()

    local hasContentAbove = verticalScroll > 1
    local hasContentBelow = verticalScroll < contentFrameHeight - scrollFrameHeight - 1
    local hasContentLeft = horizontalScroll > 1
    local hasContentRight = horizontalScroll < contentFrameWidth - scrollFrameWidth - 1

    if hasContentAbove ~= container.__lastHasContentAboveState then
        container:TriggerEvent("OnContentAboveChanged", hasContentAbove)
        container.__lastHasContentAboveState = hasContentAbove
    end

    if hasContentBelow ~= container.__lastHasContentBelowState then
        container:TriggerEvent("OnContentBelowChanged", hasContentBelow)
        container.__lastHasContentBelowState = hasContentBelow
    end

    if hasContentLeft ~= container.__lastHasContentLeftState then
        container:TriggerEvent("OnContentLeftChanged", hasContentLeft)
        container.__lastHasContentLeftState = hasContentLeft
    end

    if hasContentRight ~= container.__lastHasContentRightState then
        container:TriggerEvent("OnContentRightChanged", hasContentRight)
        container.__lastHasContentRightState = hasContentRight
    end
end

function UIKit_Primitives_ScrollBase.MouseWheelHandler(scrollFrame, delta)
    local container = scrollFrame:GetParent()
    if not container then return end

    local useHorizontal = (IsShiftKeyDown() and container.__isHorizontal) or (not container.__isVertical and container.__isHorizontal)

    if useHorizontal then
        local currentScroll = container.__interpolate and container.__targetHorizontal or container:GetHorizontalScroll()
        container:SetHorizontalScroll(currentScroll + container.__stepSize * delta)
    elseif container.__isVertical then
        local currentScroll = container.__interpolate and container.__targetVertical or container:GetVerticalScroll()
        container:SetVerticalScroll(currentScroll - container.__stepSize * delta)
    end
end


local ScrollViewBaseMixin = {}
UIKit_Primitives_ScrollBase.Mixin = ScrollViewBaseMixin

function ScrollViewBaseMixin:InitScrollViewBase()
    self.__isVertical = true
    self.__isHorizontal = false
    self.__stepSize = 150
    self.__interpolate = false
    self.__interpolateRatio = 8
    self.__targetVertical = 0
    self.__targetHorizontal = 0
end

function ScrollViewBaseMixin:GetContentFrame()
    return self.__ContentFrame
end

function ScrollViewBaseMixin:GetScrollFrame()
    return self.__ScrollFrame
end

function ScrollViewBaseMixin:GetContentHeight()
    return self.__ContentFrame:GetHeight()
end

function ScrollViewBaseMixin:GetContentWidth()
    return self.__ContentFrame:GetWidth()
end

function ScrollViewBaseMixin:HasContentAbove()
    return self.__ScrollFrame:GetVerticalScroll() > 1
end

function ScrollViewBaseMixin:HasContentBelow()
    local scrollFrame = self.__ScrollFrame
    local contentFrame = self.__ContentFrame
    return scrollFrame:GetVerticalScroll() < contentFrame:GetHeight() - scrollFrame:GetHeight() - 1
end

function ScrollViewBaseMixin:HasContentLeft()
    return self.__ScrollFrame:GetHorizontalScroll() > 1
end

function ScrollViewBaseMixin:HasContentRight()
    local scrollFrame = self.__ScrollFrame
    local contentFrame = self.__ContentFrame
    return scrollFrame:GetHorizontalScroll() < contentFrame:GetWidth() - scrollFrame:GetWidth() - 1
end

function ScrollViewBaseMixin:SetDirection(vertical, horizontal)
    self.__isVertical = vertical ~= false
    self.__isHorizontal = horizontal == true
end

function ScrollViewBaseMixin:SetStepSize(size)
    self.__stepSize = size or 150
end

local function SmoothOnUpdate(smoothFrame, elapsed)
    local container = smoothFrame.__container
    local scrollFrame = container.__ScrollFrame
    local interpolationFactor = 1 - exp(-container.__interpolateRatio * elapsed)

    local currentVertical = scrollFrame:GetVerticalScroll()
    local currentHorizontal = scrollFrame:GetHorizontalScroll()
    local targetVertical = container.__targetVertical
    local targetHorizontal = container.__targetHorizontal
    local deltaVertical = targetVertical - currentVertical
    local deltaHorizontal = targetHorizontal - currentHorizontal
    local isMoving = false

    if abs(deltaVertical) > STOP_EPSILON then
        scrollFrame:SetVerticalScroll(currentVertical + deltaVertical * interpolationFactor)
        isMoving = true
    elseif deltaVertical ~= 0 then
        scrollFrame:SetVerticalScroll(targetVertical)
    end

    if abs(deltaHorizontal) > STOP_EPSILON then
        scrollFrame:SetHorizontalScroll(currentHorizontal + deltaHorizontal * interpolationFactor)
        isMoving = true
    elseif deltaHorizontal ~= 0 then
        scrollFrame:SetHorizontalScroll(targetHorizontal)
    end

    if not isMoving then
        smoothFrame:SetScript("OnUpdate", nil)
    end

    UIKit_Primitives_ScrollBase.UpdateContentExtentEvents(container)

    if container.OnSmoothScrollUpdate then
        container:OnSmoothScrollUpdate()
    end
end

local function StartSmoothScrolling(container)
    local smoothFrame = container.uk_smoothFrame
    if not smoothFrame then
        smoothFrame = CreateFrame("Frame", nil, container)
        smoothFrame.__container = container
        container.uk_smoothFrame = smoothFrame
    end
    if not smoothFrame:GetScript("OnUpdate") then
        smoothFrame:SetScript("OnUpdate", SmoothOnUpdate)
    end
end

local function StopSmoothScrolling(container)
    local smoothFrame = container.uk_smoothFrame
    if smoothFrame then
        smoothFrame:SetScript("OnUpdate", nil)
    end
end

function ScrollViewBaseMixin:SetSmoothScrolling(enabled, ratio)
    self.__interpolate = enabled
    self.__interpolateRatio = ratio or 8

    if not enabled then
        StopSmoothScrolling(self)
        return
    end

    local scrollFrame = self.__ScrollFrame
    self.__targetVertical = self.__targetVertical or scrollFrame:GetVerticalScroll()
    self.__targetHorizontal = self.__targetHorizontal or scrollFrame:GetHorizontalScroll()

    local deltaVertical = abs(self.__targetVertical - scrollFrame:GetVerticalScroll())
    local deltaHorizontal = abs(self.__targetHorizontal - scrollFrame:GetHorizontalScroll())
    if deltaVertical >= 1 or deltaHorizontal >= 1 then
        StartSmoothScrolling(self)
    end
end

local function ClampScrollValue(container, isVertical, value)
    local contentFrame = container.__ContentFrame
    local scrollFrame = container.__ScrollFrame
    local contentSize = isVertical and contentFrame:GetHeight() or contentFrame:GetWidth()
    local frameSize = isVertical and scrollFrame:GetHeight() or scrollFrame:GetWidth()
    local maxScrollValue = max(0, contentSize - frameSize)
    return min(maxScrollValue, max(0, value))
end

local function SetScrollInternal(container, isVertical, value, instant)
    local scrollFrame = container.__ScrollFrame
    local clampedValue = ClampScrollValue(container, isVertical, value)

    if container.__interpolate and not instant then
        if isVertical then
            container.__targetVertical = clampedValue
        else
            container.__targetHorizontal = clampedValue
        end

        local currentScroll = isVertical and scrollFrame:GetVerticalScroll() or scrollFrame:GetHorizontalScroll()
        if abs(currentScroll - clampedValue) >= STOP_EPSILON then
            StartSmoothScrolling(container)
        else
            if isVertical then
                scrollFrame:SetVerticalScroll(clampedValue)
            else
                scrollFrame:SetHorizontalScroll(clampedValue)
            end
            StopSmoothScrolling(container)
        end
    else
        if container.__interpolate then
            if isVertical then
                container.__targetVertical = clampedValue
            else
                container.__targetHorizontal = clampedValue
            end
        end

        if isVertical then
            scrollFrame:SetVerticalScroll(clampedValue)
        else
            scrollFrame:SetHorizontalScroll(clampedValue)
        end

        UIKit_Primitives_ScrollBase.UpdateContentExtentEvents(container)
    end
end

function ScrollViewBaseMixin:SetVerticalScroll(value, instant)
    SetScrollInternal(self, true, value, instant)
end

function ScrollViewBaseMixin:SetHorizontalScroll(value, instant)
    SetScrollInternal(self, false, value, instant)
end

function ScrollViewBaseMixin:GetVerticalScroll()
    if self.__interpolate then
        return self.__targetVertical
    end
    return self.__ScrollFrame:GetVerticalScroll()
end

function ScrollViewBaseMixin:GetHorizontalScroll()
    if self.__interpolate then
        return self.__targetHorizontal
    end
    return self.__ScrollFrame:GetHorizontalScroll()
end

function ScrollViewBaseMixin:ScrollToPosition(horizontal, vertical, instant)
    if horizontal then
        self:SetHorizontalScroll(horizontal, instant)
    end
    if vertical then
        self:SetVerticalScroll(vertical, instant)
    end
end

function ScrollViewBaseMixin:ScrollToTop()
    self:SetVerticalScroll(0)
end

function ScrollViewBaseMixin:ScrollToBottom()
    self:SetVerticalScroll(self.__ContentFrame:GetHeight())
end

function ScrollViewBaseMixin:ScrollToLeft()
    self:SetHorizontalScroll(0)
end

function ScrollViewBaseMixin:ScrollToRight()
    self:SetHorizontalScroll(self.__ContentFrame:GetWidth())
end
