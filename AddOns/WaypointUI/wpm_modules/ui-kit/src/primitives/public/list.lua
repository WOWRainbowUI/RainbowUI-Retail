local env = select(2, ...)
local UIKit_Primitives_Frame = env.WPM:Import("wpm_modules\\ui-kit\\primitives\\frame")
local UIKit_Primitives_List = env.WPM:New("wpm_modules\\ui-kit\\primitives\\list")

local Mixin = Mixin
local tinsert = table.insert
local ipairs = ipairs
local type = type

local DEFAULT_TYPE_KEY = "Default"
local ListMixin = {}

function ListMixin:Init()
    self.__elementPool = {}
    self.__elementPoolTypeIndex = {}
    self.__data = nil
    self.__templateConstructorFunc = {}
    self.__onElementUpdateFunc = nil
end

function ListMixin:UpdateAllVisibleElements()
    if not self.__data then return end

    for index, value in ipairs(self.__data) do
        local typeKey = value.uk_poolElementType or DEFAULT_TYPE_KEY
        local element = self:GetElement(index, typeKey)
        self.__onElementUpdateFunc(element, index, value)
    end
end

function ListMixin:SetTemplate(templateConstructorFunc)
    if type(templateConstructorFunc) == "table" then
        for k, v in pairs(templateConstructorFunc) do
            self.__templateConstructorFunc[k] = v
        end
    else
        self.__templateConstructorFunc[DEFAULT_TYPE_KEY] = templateConstructorFunc
    end
end

function ListMixin:SetOnElementUpdate(func)
    self.__onElementUpdateFunc = func
end

function ListMixin:SetData(data)
    self.__data = data
    self:RenderElements()
end

function ListMixin:GetData()
    return self.__data
end

function ListMixin:HideElements()
    for _, typeFramePool in pairs(self.__elementPool) do
        for typeKey, element in pairs(typeFramePool) do
            element:Hide()
        end
    end
end

function ListMixin:WipeElementTypeIndex()
    wipe(self.__elementPoolTypeIndex)
end

function ListMixin:EnsureTypeKeyInPool(typeKey)
    if not self.__elementPool[typeKey] then
        self.__elementPool[typeKey] = {}
    end

    if not self.__elementPoolTypeIndex[typeKey] then
        self.__elementPoolTypeIndex[typeKey] = 0
    end
end

function ListMixin:NewElement(typeKey)
    assert(self.__templateConstructorFunc, "No template constructor set!")
    assert(self.uk_parent, "No parent set!")

    self:EnsureTypeKeyInPool(typeKey)

    local index = #self.__elementPool[typeKey] + 1
    local name = self:GetDebugName() .. ".Element" .. index
    local element = self.__templateConstructorFunc[typeKey](name)
    element:parent(self.uk_parent)
    tinsert(self.__elementPool[typeKey], element)

    return element
end

function ListMixin:GetElement(index, typeKey)
    self:EnsureTypeKeyInPool(typeKey)

    local element = nil
    if #self.__elementPool[typeKey] < index then
        element = self:NewElement(typeKey)
    else
        element = self.__elementPool[typeKey][index]
    end
    return element
end

function ListMixin:GetAllElementsInPoolByType(typeKey)
    if not typeKey then return end
    return self.__elementPool[typeKey]
end

function ListMixin:RenderElements()
    self:HideElements()
    self:WipeElementTypeIndex()
    if not self.__data then return end

    for index, value in ipairs(self.__data) do
        local typeKey = value.uk_poolElementType or DEFAULT_TYPE_KEY
        self:EnsureTypeKeyInPool(typeKey)

        self.__elementPoolTypeIndex[typeKey] = self.__elementPoolTypeIndex[typeKey] + 1

        local element = self:GetElement(self.__elementPoolTypeIndex[typeKey], typeKey)
        element:Show()

        if self.__onElementUpdateFunc then
            self.__onElementUpdateFunc(element, index, value)
        end
    end
end

function UIKit_Primitives_List.New(name, parent)
    name = name or "undefined"

    local frame = UIKit_Primitives_Frame.New("Frame", name, parent)
    Mixin(frame, ListMixin)
    frame:Init()

    return frame
end
