--- MSA-EditMode-1.0
--- Copyright (c) 2024-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.

local name, version = "MSA-EditMode-1.0", 3

local lib = LibStub:NewLibrary(name, version)
if not lib then return end

local ACD = LibStub("MSA-AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")

-- Lua API
local floor = math.floor
local ipairs = ipairs
local pairs = pairs
local round = function(n) return floor(n + 0.5) end

local EMmanager = EditModeManagerFrame
local openFromEditMode = false

local anchors = { ["TOP"] = "Top", ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right", ["BOTTOM"] = "Bottom", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" }
local moverColors = {
    normal = { r = 0, g = 1, b = 0, a = 0.7 },
    active = { r = 1, g = 0, b = 0, a = 1 }
}

lib.movers = lib.movers or {}
lib.buttons = lib.buttons or {}

-- ---------------------------------------------------------------------------------------------------------------------

local MoverMixin = {}

local function Anchor_OnEnter(self)
    local anchor = self.value
    if anchor == "TOP" or anchor == "TOPLEFT" or anchor == "TOPRIGHT" then
        GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
    elseif anchor == "BOTTOM" or anchor == "BOTTOMLEFT" or anchor == "BOTTOMRIGHT" then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
    end
    GameTooltip:AddLine("Anchor - "..anchors[anchor], 1, 0.82, 0)
    GameTooltip:Show()

    self.obj:Anchor_OnEnter(self)
end

local function Anchor_OnClick(self)
    local mover = self.obj
    if mover.editMode then
        mover.editMode:SelectOptions(mover.id)
    end
    mover.anchorPoint = self.value
    mover:Anchor_OnClick(self)
    mover:Update()
end

local function OnDragStart(self)
    local mover = self.obj
    local frame = mover.frame
    frame:StartMoving()
    mover:OnDragStart(frame)
end

local function OnDragStop(self)
    local mover = self.obj
    local frame = mover.frame
    frame:StopMovingOrSizing()
    mover:OnDragStop(frame)
    mover:Update()
end

local function OnMouseDown(self)
    local mover = self.obj
    if mover.editMode then
        mover.editMode:SelectOptions(mover.id)
    end
end

local function OnMouseUp(self, button)
    local mover = self.obj
    local frame = mover.frame
    mover:OnMouseUp(frame, button)
    mover:Update()
end

function MoverMixin:Init(addonName, frame, id)
    assert(addonName, "function 'Init' - parameter 'addonName' is missing")
    assert(frame, "function 'Init' - parameter 'frame' is missing")
    assert(id, "function 'Init' - parameter 'id' is missing")

    self.id = id
    self.name = frame:GetName() or tostring(frame)
    self.frame = frame
    self.anchorPoint = frame:GetPoint()
    self.editAnchors = false
    self.enabledAnchors = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" }

    lib.movers[addonName] = lib.movers[addonName] or {}
    lib.movers[addonName][id] = self
end

function MoverMixin:Show()
    local mover = self.mover
    if not mover then
        mover = CreateFrame("Frame", nil, self.frame)
        mover:SetFrameLevel(self.frame:GetFrameLevel() + 20)
        mover.texture = mover:CreateTexture(nil, "BACKGROUND")
        mover.texture:SetAllPoints()
        mover.texture:SetColorTexture(0, 1, 0, 0.3)

        mover:EnableMouse(true)
        mover:RegisterForDrag("LeftButton")
        self.frame:SetMovable(true)

        mover:SetScript("OnDragStart", OnDragStart)
        mover:SetScript("OnDragStop", OnDragStop)
        mover:SetScript("OnMouseDown", OnMouseDown)
        mover:SetScript("OnMouseUp", OnMouseUp)

        mover.obj = self
        if self.editAnchors then
            for _, anchor in ipairs(self.enabledAnchors) do
                local button = CreateFrame("Button", nil, mover)
                button:SetSize(12, 12)
                button:SetPoint(anchor)
                button.texture = button:CreateTexture(nil, "BACKGROUND")
                button.texture:SetAllPoints()
                button.texture:SetColorTexture(moverColors.normal.r, moverColors.normal.g, moverColors.normal.b, moverColors.normal.a)
                button.value = anchor
                button.obj = self
                button:RegisterForClicks("AnyDown")
                button:SetScript("OnEnter", Anchor_OnEnter)
                button:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                button:SetScript("OnClick", Anchor_OnClick)
                mover["button"..anchor] = button
            end
        end

        self.mover = mover
        self:Update()
    end
    mover:Show()
end

function MoverMixin:Hide()
    local mover = self.mover
    mover:Hide()
end

function MoverMixin:GetPosition(anchor, scale)
    assert(anchor, "function 'GetPosition' - parameter 'anchor' is missing")
    assert(scale, "function 'GetPosition' - parameter 'scale' is missing")

    local mover = self.mover
    assert(mover, "function 'GetPosition' - mover does not exist")

    local left = mover:GetLeft() * scale
    local top = mover:GetTop() * scale
    local bottom = mover:GetBottom() * scale
    local width = mover:GetWidth() * scale

    local xOffset
    local yOffset

    if anchor == "TOP" then
        xOffset = left + width / 2 - UIParent:GetWidth() / 2
        yOffset = top - UIParent:GetHeight()
    elseif anchor == "TOPLEFT" then
        xOffset = left
        yOffset = top - UIParent:GetHeight()
    elseif anchor == "TOPRIGHT" then
        xOffset = left + width - UIParent:GetWidth()
        yOffset = top - UIParent:GetHeight()
    elseif anchor == "BOTTOM" then
        xOffset = left + width / 2 - UIParent:GetWidth() / 2
        yOffset = bottom
    elseif anchor == "BOTTOMLEFT" then
        xOffset = left
        yOffset = bottom
    elseif anchor == "BOTTOMRIGHT" then
        xOffset = left + width - UIParent:GetWidth()
        yOffset = bottom
    else
        error("Unsupported anchor: "..tostring(anchor))
    end

    return round(xOffset), round(yOffset)
end

function MoverMixin:Anchor_OnEnter(frame)
    -- for override
end

function MoverMixin:Anchor_OnClick(frame)
    -- for override
end

function MoverMixin:OnDragStart(frame)
    -- for override
end

function MoverMixin:OnDragStop(frame)
    -- for override
end

function MoverMixin:OnMouseUp(frame, button)
    -- for override
end

function MoverMixin:OnScaleChanged()
    -- for override
end

function MoverMixin:Update()
    local mover = self.mover
    if mover then
        mover:SetAllPoints()

        if self.editAnchors then
            assert(self.anchorPoint, self.name..":GetPoint() returns nil, set mover.anchorPoint manually inside mover:Update().")
            local button = mover["button"..self.anchorPoint]
            if button then
                if mover.activeButton then
                    mover.activeButton.texture:SetColorTexture(moverColors.normal.r, moverColors.normal.g, moverColors.normal.b, moverColors.normal.a)
                end
                button.texture:SetColorTexture(moverColors.active.r, moverColors.active.g, moverColors.active.b, moverColors.active.a)
                mover.activeButton = button
            end
        end
    end
end

function lib:Mover_Create(...)
    local obj = CreateAndInitFromMixin(MoverMixin, ...)
    obj.mixin = MoverMixin
    return obj
end

-- ---------------------------------------------------------------------------------------------------------------------

local EditModeMixin = {}

function EditModeMixin:Init(addonName, options, node, width, height)
    assert(addonName, "function 'Init' - parameter 'addonName' is missing")
    assert(options, "function 'Init' - parameter 'options' is missing")
    assert(node, "function 'Init' - parameter 'node' is missing")

    self.addonName = addonName
    self.addonTitle = C_AddOns.GetAddOnMetadata(addonName, "Title")
    self.name = addonName.."EditMode"
    self.options = options
    self.optionsNode = node
    self.opened = false

    self.OnOpen = nil
    self.OnClose = nil

    ACR:RegisterOptionsTable(self.name, options, true)
    ACD:SetDefault(self.name, width or 500, height or 500, "MSA-Frame", function()
        self:Close()
    end)
    self:AddButtonBlizEditMode()
end

function EditModeMixin:RegisterOptions(node, options)
    assert(node, "function 'RegisterOptions' - parameter 'node' is missing")
    assert(options, "function 'RegisterOptions' - parameter 'options' is missing")

    local parent = self.options.args[self.optionsNode]
    assert(parent, "Edit Mode options node '"..self.optionsNode.."' does not exist")

    parent.args[node] = options
end

function EditModeMixin:SelectOptions(node)
    assert(node, "function 'SelectOptions' - parameter 'node' is missing")

    local parent = self.options.args[self.optionsNode]
    assert(parent and parent.args[node], "Edit Mode options node '"..node.."' does not exist")

    ACD:SelectGroup(self.name, self.optionsNode, node)
end

function EditModeMixin:Open()
    if not InCombatLockdown() then
        self:ShowMover()
        self:OpenOptions()

        if self.OnOpen then
            self:OnOpen()
        end
    end
end

function EditModeMixin:Close()
    if not InCombatLockdown() then
        self:CloseOptions()
        self:HideMover()
        if openFromEditMode then
            EMmanager:Show()
            openFromEditMode = false
        end

        if self.OnClose then
            self:OnClose()
        end
    end
end

function EditModeMixin:ShowMover(id)
    HideUIPanel(SettingsPanel)
    self.opened = true
    local movers = lib.movers[self.addonName] or {}
    if id then
        local mover = movers[id]
        mover.editMode = self
        mover:Show()
    else
        for _, mover in pairs(movers) do
            mover.editMode = self
            mover:Show()
        end
    end
end

function EditModeMixin:HideMover(id)
    self.opened = false
    local movers = lib.movers[self.addonName] or {}
    if id then
        movers[id]:Hide()
    else
        for _, mover in pairs(movers) do
            mover:Hide()
        end
    end
end

function EditModeMixin:OpenOptions()
    ACD:Open(self.name, self.optionsNode)

    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local frame = ACD.OpenFrames[self.name]
    frame:SetButtonText(LOCK)
    frame.status.left = (screenWidth / 2) - (frame.status.width / 2)
    frame.status.top = screenHeight * 0.9
    frame:ApplyStatus()
end

function EditModeMixin:CloseOptions()
    ACD:Close(self.name)
end

function EditModeMixin:NotifyChange()
    ACR:NotifyChange(self.name)
end

function EditModeMixin:AddButtonBlizEditMode()
    if not EMmanager then return end

    local button = CreateFrame("Button", nil, EMmanager, "EditModeManagerFrameButtonTemplate")
    button:SetWidth(120)
    button:SetText(self.addonTitle)
    button:SetPoint("LEFT", EMmanager.LayoutDropdown, "RIGHT", 22, 1)
    button:SetScript("OnClick", function()
        if not InCombatLockdown() then
            openFromEditMode = true
            EMmanager:Hide()
            self:Open()
        end
    end)
    tinsert(lib.buttons, button)

    local numButtons = #lib.buttons
    if numButtons == 1 then
        button:SetPoint("TOPLEFT", EMmanager, "BOTTOMLEFT", 6, 0)
    elseif math.fmod(numButtons, 4) == 1 then
        button:SetPoint("TOPLEFT", lib.buttons[numButtons - 4], "BOTTOMLEFT", 0, -6)
    else
        button:SetPoint("LEFT", lib.buttons[numButtons - 1], "RIGHT", 6, 0)
    end
end

function lib:EditMode_Create(...)
    return CreateAndInitFromMixin(EditModeMixin, ...)
end

-- ---------------------------------------------------------------------------------------------------------------------

local function UpdateScale()
    for _, movers in pairs(lib.movers) do
        for _, mover in pairs(movers) do
            mover:OnScaleChanged()
        end
    end
end

if not lib.scaleHooked then
    hooksecurefunc(UIParent, "SetScale", UpdateScale)
    lib.scaleHooked = true
end

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        UpdateScale()
        self:RegisterEvent("UI_SCALE_CHANGED")
        self:UnregisterEvent(event)
    elseif event == "UI_SCALE_CHANGED" then
        UpdateScale()
    end
end)
lib.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- ---------------------------------------------------------------------------------------------------------------------

lib.embeds = lib.embeds or {}

local mixins = {
    "Mover_Create",
    "EditMode_Create"
}

function lib:Embed(target)
    lib.embeds[target] = true
    for _, v in next, mixins do
        target[v] = lib[v]
    end
    return target
end

for addon in next, lib.embeds do
    lib:Embed(addon)
end