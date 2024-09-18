--- MSA-EditMode-1.0
--- Copyright (c) 2024, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.

local name, version = "MSA-EditMode-1.0", 0

local lib = LibStub:NewLibrary(name, version)
if not lib then return end

local ACD = LibStub("MSA-AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")

local EMmanager = EditModeManagerFrame
local openFromEditMode = false

local anchors = { ["TOPLEFT"] = "Top Left", ["TOPRIGHT"] = "Top Right", ["BOTTOMLEFT"] = "Bottom Left", ["BOTTOMRIGHT"] = "Bottom Right" }
local moverColors = {
    normal = { r = 0, g = 1, b = 0, a = 0.7 },
    active = { r = 1, g = 0, b = 0, a = 1 }
}

lib.movers = lib.movers or {}
lib.buttons = lib.buttons or {}

-- ---------------------------------------------------------------------------------------------------------------------

local MoverMixin = {}

local function OnDragStart(self)
    local frame = self.obj.frame
    frame:StartMoving()
    self.obj:OnDragStart(frame)
end

local function OnDragStop(self)
    local frame = self.obj.frame
    frame:StopMovingOrSizing()
    self.obj:OnDragStop(frame)
    self.obj:Update()
end

local function OnMouseUp(self, button)
    local frame = self.obj.frame
    self.obj:OnMouseUp(frame, button)
    self.obj:Update()
end

function MoverMixin:Init(addonName, frame)
    assert(addonName, "function 'Init' - parameter 'addonName' is missing")
    assert(frame, "function 'Init' - parameter 'frame' is missing")

    self.name = frame:GetName() or tostring(frame)
    self.frame = frame
    self.anchorPoint = frame:GetPoint()
    self.editAnchors = false

    lib.movers[addonName] = lib.movers[addonName] or {}
    lib.movers[addonName][self.name] = self
end

function MoverMixin:Show()
    local mover = self.mover
    if not mover then
        mover = CreateFrame("Frame", nil, self.frame)
        mover:SetFrameLevel(self.frame:GetFrameLevel() + 12)
        mover.texture = mover:CreateTexture(nil, "BACKGROUND")
        mover.texture:SetAllPoints()
        mover.texture:SetColorTexture(0, 1, 0, 0.3)

        mover:EnableMouse(true)
        mover:RegisterForDrag("LeftButton")
        self.frame:SetMovable(true)

        mover:SetScript("OnDragStart", OnDragStart)
        mover:SetScript("OnDragStop", OnDragStop)
        mover:SetScript("OnMouseUp", OnMouseUp)

        mover.obj = self
        if self.editAnchors then
            for anchor in pairs(anchors) do
                local button = CreateFrame("Button", nil, mover)
                button:SetSize(12, 12)
                button:SetPoint(anchor)
                button.texture = button:CreateTexture(nil, "BACKGROUND")
                button.texture:SetAllPoints()
                button.texture:SetColorTexture(moverColors.normal.r, moverColors.normal.g, moverColors.normal.b, moverColors.normal.a)
                button.value = anchor
                button.obj = self
                button:RegisterForClicks("AnyDown")
                button:SetScript("OnEnter", function(self)
                    mover.obj.Anchor_OnEnter(self)
                end)
                button:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
                button:SetScript("OnClick", function(self)
                    mover.obj.anchorPoint = self.value
                    mover.obj.Anchor_OnClick(self)
                    mover.obj:Update()
                end)
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
    self.optionsNode = node
    self.opened = false

    ACR:RegisterOptionsTable(self.name, options, true)
    ACD:SetDefault(self.name, width or 500, height or 500, "MSA-Frame", function()
        self:HideMover()
        if openFromEditMode then
            EMmanager:Show()
            openFromEditMode = false
        end
    end)
    self:AddButtonBlizEditMode()
end

function EditModeMixin:ShowMover(name)
    HideUIPanel(SettingsPanel)
    self.opened = true
    local movers = lib.movers[self.addonName] or {}
    if name then
        movers[name]:Show()
    else
        for _, mover in pairs(movers) do
            mover:Show()
        end
    end
end

function EditModeMixin:HideMover(name)
    self.opened = false
    local movers = lib.movers[self.addonName] or {}
    if name then
        movers[name]:Hide()
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
            self:ShowMover()
            self:OpenOptions()
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