local env = select(2, ...)
local UIKit_Primitives_Frame = env.WPM:Import("wpm_modules\\ui-kit\\primitives\\frame")
local UIKit_Primitives_ScrollBase = env.WPM:Import("wpm_modules\\ui-kit\\primitives\\scroll-view-base")
local UIKit_Primitives_LazyScrollView = env.WPM:New("wpm_modules\\ui-kit\\primitives\\lazy-scroll-view")

local Mixin = Mixin
local huge = math.huge
local tinsert = table.insert
local assert = assert
local ipairs = ipairs
local ScrollViewBaseMixin = UIKit_Primitives_ScrollBase.Mixin
local MouseWheelHandler = UIKit_Primitives_ScrollBase.MouseWheelHandler
local UpdateContentExtentEvents = UIKit_Primitives_ScrollBase.UpdateContentExtentEvents


local LazyScrollViewPoolingMixin = {}

function LazyScrollViewPoolingMixin:InitLazyScrollViewPooling()
    self.__elementPool = {}
    self.__data = nil
    self.__templateConstructorFunc = nil
    self.__onElementUpdateFunc = nil
    self.__elementHeight = 25
    self.__elementWidth = 25
    self.__numVisibleElements = 0
    self.__visibleStartingIndex = nil
    self.__lastUpdateStartingIndex = nil
end

function LazyScrollViewPoolingMixin:UpdateAllVisibleElements()
    if not self.__data or not self.__visibleStartingIndex then return end

    local startingIndex = self.__visibleStartingIndex

    for i = 1, self.__numVisibleElements do
        local dataIndex = startingIndex + i - 1
        local dataValue = self.__data[dataIndex]

        local element = self:GetElement(i)

        if dataIndex > #self.__data then
            element:Hide()
        else
            element:Show()

            if self.__onElementUpdateFunc then
                self.__onElementUpdateFunc(element, dataIndex, dataValue)
            end
        end
    end
end

function LazyScrollViewPoolingMixin:SetTemplate(templateConstructorFunc)
    self.__templateConstructorFunc = templateConstructorFunc
end

function LazyScrollViewPoolingMixin:SetOnElementUpdate(func)
    self.__onElementUpdateFunc = func
end

function LazyScrollViewPoolingMixin:SetData(data)
    self.__data = data
    self:ResetScrolling()
    self:UpdateContentExtent()
    self:RenderElements()

    C_Timer.After(0, function()
        self:UpdateScrolling()
    end)
end

function LazyScrollViewPoolingMixin:SetElementHeight(height)
    self.__elementHeight = height
    self:UpdateAfterSizingChange()
end

function LazyScrollViewPoolingMixin:SetElementWidth(width)
    self.__elementWidth = width
    self:UpdateAfterSizingChange()
end

function LazyScrollViewPoolingMixin:ScrollToIndex(index)
    if not self.__data then return end

    local elementPosition = self:GetElementPosition(index + 1) - self:GetScrollFrame():GetHeight() / 2
    self:SetVerticalScroll(elementPosition)
end

function LazyScrollViewPoolingMixin:GetElementHeight()
    return self.__elementHeight
end

function LazyScrollViewPoolingMixin:GetElementWidth()
    return self.__elementWidth
end

function LazyScrollViewPoolingMixin:GetElementPosition(index)
    if not self.__data then return end

    local elementSize = self:GetPrimaryElementSize()
    local elementPosition = (index - 1) * elementSize
    return elementPosition
end

function LazyScrollViewPoolingMixin:IsHorizontalPrimary()
    return self.__isHorizontal and not self.__isVertical
end

function LazyScrollViewPoolingMixin:IsVerticalPrimary()
    return self.__isVertical and not self.__isHorizontal
end

function LazyScrollViewPoolingMixin:GetPrimaryElementSize()
    local size
    if self:IsHorizontalPrimary() then
        size = self.__elementWidth
        if (not size or size <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetWidth then
            size = self.__elementPool[1]:GetWidth()
        end
    else
        size = self.__elementHeight
        if (not size or size <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetHeight then
            size = self.__elementPool[1]:GetHeight()
        end
    end

    return size and size > 0 and size or 1
end

function LazyScrollViewPoolingMixin:GetPoolingContentHeight()
    if not self.__data then return 0 end
    local elementHeight = self.__elementHeight
    if (not elementHeight or elementHeight <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetHeight then
        elementHeight = self.__elementPool[1]:GetHeight()
    end
    return (elementHeight or 1) * #self.__data
end

function LazyScrollViewPoolingMixin:GetPoolingContentWidth()
    if not self.__data then return 0 end
    local elementWidth = self.__elementWidth
    if (not elementWidth or elementWidth <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetWidth then
        elementWidth = self.__elementPool[1]:GetWidth()
    end
    if (not elementWidth or elementWidth <= 0) and self.__elementPool and self.__elementPool[1] and self.__elementPool[1].GetHeight then
        elementWidth = self.__elementPool[1]:GetHeight()
    end
    return (elementWidth or 1) * #self.__data
end

function LazyScrollViewPoolingMixin:GetData()
    return self.__data
end

function LazyScrollViewPoolingMixin:GetNumElementsToDisplay()
    local shouldFitWidth, shouldFitHeight = self:GetFitContent()

    local scrollFrame = self:GetScrollFrame()
    local elementSize = self:GetPrimaryElementSize()
    local frameExtent

    if self:IsHorizontalPrimary() then
        frameExtent = scrollFrame:GetWidth()
        if shouldFitWidth then
            local maxWidth = self:GetMaxWidth()
            frameExtent = maxWidth or huge
        end
    else
        frameExtent = scrollFrame:GetHeight()
        if shouldFitHeight then
            local maxHeight = self:GetMaxHeight()
            frameExtent = maxHeight or huge
        end
    end

    return math.ceil(frameExtent / elementSize) + 1
end

function LazyScrollViewPoolingMixin:HideElements()
    for k, v in ipairs(self.__elementPool) do
        v:Hide()
    end
end

function LazyScrollViewPoolingMixin:NewElement()
    assert(self.__templateConstructorFunc, "No template constructor set!")
    local index = #self.__elementPool + 1
    local name = self:GetDebugName() .. ".Element" .. index
    local element = self.__templateConstructorFunc(name)

    element:parent(self:GetContentFrame())

    tinsert(self.__elementPool, element)

    return element
end

function LazyScrollViewPoolingMixin:GetElement(index)
    local element = nil

    if #self.__elementPool < index then
        element = self:NewElement()
    else
        element = self.__elementPool[index]
    end

    return element
end

function LazyScrollViewPoolingMixin:GetAllElementsInPool()
    return self.__elementPool
end

function LazyScrollViewPoolingMixin:RenderElements()
    self:HideElements()
    if not self.__data then
        self.__numVisibleElements = 0
        self:UpdateContentExtent()
        return
    end

    local numElementsToDisplay = self:GetNumElementsToDisplay()
    local elementsToCreate = math.min(numElementsToDisplay, #self.__data)
    self.__numVisibleElements = math.min(numElementsToDisplay, #self.__data)

    for i = 1, elementsToCreate do
        local element = self:GetElement(i)
        element:Show()
    end

    self:UpdateContentExtent()
    self:UpdateScrolling()
end

function LazyScrollViewPoolingMixin:UpdateContentExtent()
    local contentFrame = self:GetContentFrame()
    if not contentFrame then return end

    local dataCount = self.__data and #self.__data or 0

    local primarySize = self:GetPrimaryElementSize() * dataCount

    local scrollFrame = self:GetScrollFrame()
    if self:IsHorizontalPrimary() then
        contentFrame:SetWidth(primarySize)
        if not self.__isVertical then
            contentFrame:SetHeight(scrollFrame:GetHeight())
        end
    else
        contentFrame:SetHeight(primarySize)
        if not self.__isHorizontal then
            contentFrame:SetWidth(scrollFrame:GetWidth())
        end
    end
end

function LazyScrollViewPoolingMixin:UpdateAfterSizingChange()
    self:UpdateContentExtent()
    self:UpdateScrolling()
end

function LazyScrollViewPoolingMixin:ResetScrolling()
    self.__visibleStartingIndex = nil
    self.__lastUpdateStartingIndex = nil
end

function LazyScrollViewPoolingMixin:UpdateScrolling()
    if not self.__data then return end

    local useHorizontal = self:IsHorizontalPrimary()
    local scrollFrame = self:GetScrollFrame()
    local elementSize = self:GetPrimaryElementSize()
    local scrollOffset = nil

    if useHorizontal then
        scrollOffset = scrollFrame:GetHorizontalScroll()
    else
        scrollOffset = scrollFrame:GetVerticalScroll()
    end

    self.__visibleStartingIndex = math.floor(scrollOffset / elementSize) + 1
    if self.__lastUpdateStartingIndex ~= self.__visibleStartingIndex then
        self.__lastUpdateStartingIndex = self.__visibleStartingIndex

        for i = 1, self.__numVisibleElements do
            local element = self:GetElement(i)
            if not element then break end

            element:ClearAllPoints()
            local offset = elementSize * ((i - 1) + (self.__visibleStartingIndex - 1))
            if useHorizontal then
                element:SetPoint("TOPLEFT", self:GetContentFrame(), "TOPLEFT", offset, 0)
            else
                element:SetPoint("TOPLEFT", self:GetContentFrame(), "TOPLEFT", 0, -offset)
            end
        end

        self:UpdateAllVisibleElements()
    end

    UpdateContentExtentEvents(self)
end


local LazyScrollViewMixin = {}

function LazyScrollViewMixin:CustomFitContent()
    local shouldFitWidth, shouldFitHeight = self:GetFitContent()
    self:FitContent(shouldFitWidth, shouldFitHeight, { self.__ContentFrame })
end

function LazyScrollViewMixin:OnSmoothScrollUpdate()
    self:UpdateScrolling()
end


local LazyScrollViewContentMixin = {}

function LazyScrollViewContentMixin:GetParent()
    return self.__parentRef
end

function LazyScrollViewContentMixin:CustomFitContent()
    local shouldFitWidth, shouldFitHeight = self:GetFitContent()
    local parent = self:GetParent()

    if shouldFitHeight and parent.__isVertical then
        self:SetHeight(parent:GetPoolingContentHeight())
    end

    if shouldFitWidth and parent.__isHorizontal then
        self:SetWidth(parent:GetPoolingContentWidth())
    end
end


function UIKit_Primitives_LazyScrollView.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, ScrollViewBaseMixin)
    Mixin(frame, LazyScrollViewPoolingMixin)
    Mixin(frame, LazyScrollViewMixin)
    frame:InitScrollViewBase()
    frame:InitLazyScrollViewPooling()

    local scrollFrame = UIKit_Primitives_Frame.New("ScrollFrame", "$parent.ScrollFrame", frame)
    scrollFrame:SetAllPoints(frame)
    scrollFrame:SetClipsChildren(true)
    scrollFrame:EnableMouseWheel(true)

    local contentFrame = UIKit_Primitives_Frame.New("Frame", "$parent.ContentFrame", scrollFrame)
    contentFrame.uk_type = "LazyScrollViewContent"
    contentFrame.__parentRef = frame
    Mixin(contentFrame, LazyScrollViewContentMixin)
    scrollFrame:SetScrollChild(contentFrame)

    frame.__ScrollFrame = scrollFrame
    frame.__ContentFrame = contentFrame

    scrollFrame:SetScript("OnMouseWheel", MouseWheelHandler)
    scrollFrame:HookScript("OnVerticalScroll", function()
        frame:TriggerEvent("OnVerticalScroll")
        frame:UpdateScrolling()
    end)
    scrollFrame:HookScript("OnHorizontalScroll", function()
        frame:TriggerEvent("OnHorizontalScroll")
        frame:UpdateScrolling()
    end)

    return frame
end
