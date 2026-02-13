local env = select(2, ...)
local UIKit_Enum = env.WPM:Import("wpm_modules\\ui-kit\\enum")
local UIKit_Primitives_Frame = env.WPM:Import("wpm_modules\\ui-kit\\primitives\\frame")
local UIKit_Primitives_ScrollViewEdge = env.WPM:New("wpm_modules\\ui-kit\\primitives\\scroll-view-edge")

local Mixin = Mixin
local max = math.max
local min = math.min


local LEADING = UIKit_Enum.ScrollEdgeDirection.Leading
local TRAILING = UIKit_Enum.ScrollEdgeDirection.Trailing

local ScrollViewEdgeMixin = {}

function ScrollViewEdgeMixin:SetScrollEdgeMin(value)
    self.__scrollEdgeMin = value or 0
end

function ScrollViewEdgeMixin:SetScrollEdgeMax(value)
    self.__scrollEdgeMax = value or 0
end

function ScrollViewEdgeMixin:SetScrollEdgeDirection(direction)
    self.__scrollEdgeDirection = direction or LEADING
end

function ScrollViewEdgeMixin:SetLinkedScrollView(scrollView)
    local prevScrollView = self.__linkedScrollView
    if prevScrollView and self.__scrollHandler then
        prevScrollView:UnhookEvent("OnVerticalScroll", self.__scrollHandler)
        prevScrollView:UnhookEvent("OnHorizontalScroll", self.__scrollHandler)
    end

    self.__linkedScrollView = scrollView
    if not scrollView then return end

    if not self.__scrollHandler then
        self.__scrollHandler = function() self:UpdateAlpha() end
    end

    scrollView:HookEvent("OnVerticalScroll", self.__scrollHandler)
    scrollView:HookEvent("OnHorizontalScroll", self.__scrollHandler)

    self:UpdateAlpha()
end

function ScrollViewEdgeMixin:UpdateAlpha()
    local scrollView = self.__linkedScrollView
    if not scrollView then return end

    local scrollFrame = scrollView.__ScrollFrame
    local contentFrame = scrollView.__ContentFrame
    if not scrollFrame or not contentFrame then return end

    local edgeMin = self.__scrollEdgeMin or 0
    local edgeMax = self.__scrollEdgeMax or 0
    local direction = self.__scrollEdgeDirection or LEADING
    local isVertical = scrollView.__isVertical
    local isHorizontal = scrollView.__isHorizontal

    local scroll, contentSize, frameSize
    if isVertical then
        scroll = scrollFrame:GetVerticalScroll()
        contentSize = contentFrame:GetHeight()
        frameSize = scrollFrame:GetHeight()
    elseif isHorizontal then
        scroll = scrollFrame:GetHorizontalScroll()
        contentSize = contentFrame:GetWidth()
        frameSize = scrollFrame:GetWidth()
    else
        self:SetAlpha(0)
        return
    end

    local maxScroll = max(0, contentSize - frameSize)
    local alpha = 0

    if direction == TRAILING then
        local distanceFromEnd = maxScroll - scroll
        if distanceFromEnd <= edgeMin then
            alpha = 0
        elseif distanceFromEnd >= edgeMax then
            alpha = 1
        else
            local range = edgeMax - edgeMin
            alpha = range > 0 and (distanceFromEnd - edgeMin) / range or 0
        end
    else
        if scroll <= edgeMin then
            alpha = 0
        elseif scroll >= edgeMax then
            alpha = 1
        else
            local range = edgeMax - edgeMin
            alpha = range > 0 and (scroll - edgeMin) / range or 0
        end
    end

    self:SetAlpha(min(1, max(0, alpha)))
end

function UIKit_Primitives_ScrollViewEdge.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, ScrollViewEdgeMixin)

    frame.__scrollEdgeMin = 0
    frame.__scrollEdgeMax = 50
    frame.__scrollEdgeDirection = LEADING

    return frame
end
