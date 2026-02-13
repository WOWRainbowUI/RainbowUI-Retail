local env = select(2, ...)
local UIKit_Primitives_Frame = env.WPM:Import("wpm_modules\\ui-kit\\primitives\\frame")
local UIKit_Primitives_ScrollBase = env.WPM:Import("wpm_modules\\ui-kit\\primitives\\scroll-view-base")
local UIKit_Primitives_ScrollView = env.WPM:New("wpm_modules\\ui-kit\\primitives\\scroll-view")

local Mixin = Mixin
local ScrollViewBaseMixin = UIKit_Primitives_ScrollBase.Mixin
local MouseWheelHandler = UIKit_Primitives_ScrollBase.MouseWheelHandler


local ScrollViewMixin = {}

function ScrollViewMixin:CustomFitContent()
    local shouldFitWidth, shouldFitHeight = self:GetFitContent()
    self:FitContent(shouldFitWidth, shouldFitHeight, { self.__ContentFrame })
end


local ScrollViewContentMixin = {}

function ScrollViewContentMixin:GetParent()
    return self.__parentRef
end

function ScrollViewContentMixin:CustomFitContent()
    local shouldFitWidth, shouldFitHeight = self:GetFitContent()
    self:FitContent(shouldFitWidth, shouldFitHeight, self.__parentRef:GetFrameChildren())
end


function UIKit_Primitives_ScrollView.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, ScrollViewBaseMixin)
    Mixin(frame, ScrollViewMixin)
    frame:InitScrollViewBase()

    local scrollFrame = UIKit_Primitives_Frame.New("ScrollFrame", "$parent.ScrollFrame", frame)
    scrollFrame:SetAllPoints(frame)
    scrollFrame:SetClipsChildren(true)
    scrollFrame:EnableMouseWheel(true)

    local contentFrame = UIKit_Primitives_Frame.New("Frame", "$parent.ContentFrame", scrollFrame)
    contentFrame.uk_type = "ScrollViewContent"
    contentFrame.__parentRef = frame
    Mixin(contentFrame, ScrollViewContentMixin)
    scrollFrame:SetScrollChild(contentFrame)

    frame.__ScrollFrame = scrollFrame
    frame.__ContentFrame = contentFrame

    scrollFrame:SetScript("OnMouseWheel", MouseWheelHandler)
    scrollFrame:HookScript("OnVerticalScroll", function() frame:TriggerEvent("OnVerticalScroll") end)
    scrollFrame:HookScript("OnHorizontalScroll", function() frame:TriggerEvent("OnHorizontalScroll") end)

    return frame
end
