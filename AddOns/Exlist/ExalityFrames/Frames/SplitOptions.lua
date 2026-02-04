local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesSplitOptionsScrollFrame
local scrollFrame = EXFrames:GetFrame('scroll-frame')

--- @class ExalityFramesSplitOptionsFrame
local splitOptions = EXFrames:GetFrame('split-options-frame')

splitOptions.Init = function(self)
    splitOptions.pool = CreateFramePool('Frame', UIParent)
end

local function CreateItem(parent)
    local button = CreateFrame('Button', nil, parent, 'BackdropTemplate')
    button:SetHeight(20)
    button:SetBackdrop(EXFrames.assets.backdrop.DEFAULT)
    button:SetBackdropColor(0, 0, 0, 1)
    button:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

    local text = button:CreateFontString(nil, 'OVERLAY')
    text:SetFont(EXFrames.assets.font.default(), 11, 'OUTLINE')
    text:SetPoint('CENTER')
    button.text = text

    button.SetActive = function(self, active)
        if (active) then
            button:SetBackdropBorderColor(249 / 255, 95 / 255, 9 / 255, 1)
            button:SetBackdropColor(0.15, 0.15, 0.15, 1)
        else
            button:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
            button:SetBackdropColor(0, 0, 0, 1)
        end
    end

    button.SetText = function(self, text)
        self.text:SetText(text or "")
    end

    button:SetScript('OnClick', function(self)
        if (self.onItemClick) then
            self:onItemClick(self.ID)
        end
    end)

    return button
end

local configure = function(f)
    f.items = {}
    f.onItemClick = nil
    f.activeID = nil

    local leftPanel = EXFrames:GetFrame('panel-frame'):Create()
    leftPanel:SetBackgroundColor(0.05, 0.05, 0.05, 0.8)
    leftPanel:SetParent(f)
    leftPanel:SetPoint('TOPLEFT', 5, -5)
    leftPanel:SetPoint('BOTTOMRIGHT', f, 'BOTTOMLEFT', 165, 5)

    local rightPanel = EXFrames:GetFrame('panel-frame'):Create()
    rightPanel:SetBackgroundColor(0.05, 0.05, 0.05, 0.8)
    rightPanel:SetParent(f)
    rightPanel:SetPoint('TOPLEFT', leftPanel, 'TOPRIGHT', 5, 0)
    rightPanel:SetPoint('BOTTOMRIGHT', -5, 5)
    f.rightPanel = rightPanel

    local scrollFrame = scrollFrame:Create()
    scrollFrame:SetParent(rightPanel)
    scrollFrame:SetPoint('TOPLEFT', 5, -15)
    scrollFrame:SetPoint('BOTTOMRIGHT', -30, 8)
    f.scrollFrame = scrollFrame
    f.container = scrollFrame.child

    local extraButton = EXFrames:GetFrame('button'):Create()
    extraButton:SetHeight(30)
    extraButton:SetParent(leftPanel)
    extraButton:SetPoint('BOTTOMLEFT', leftPanel, 'BOTTOMLEFT', 5, 5)
    extraButton:SetPoint('BOTTOMRIGHT', leftPanel, 'BOTTOMRIGHT', -5, 5)
    extraButton:Hide()
    f.extraButton = extraButton

    f.UpdateScroll = function(self)
        self.scrollFrame:UpdateScrollChild(self.rightPanel:GetWidth() - 50, self.rightPanel:GetHeight() - 25)
    end

    f.onItemClick = function(self, id)
        f.activeID = id
        for _, item in ipairs(f.items) do
            item:SetActive(item.ID == id)
        end
        if (f.onItemChange) then
            f.onItemChange(id)
        end
    end

    f.AddItems = function(self, items)
        for _, item in ipairs_reverse(self.items) do
            item:ClearAllPoints()
        end
        local prev = nil
        for i, item in ipairs(items) do
            if (not self.items[i]) then
                self.items[i] = CreateItem(leftPanel)
            end
            local button = self.items[i]
            button.ID = item.ID
            button:SetText(item.label)
            button.onItemClick = self.onItemClick
            if (not prev) then
                button:SetPoint('TOPLEFT', leftPanel, 'TOPLEFT', 3, -5)
                button:SetPoint('TOPRIGHT', leftPanel, 'TOPRIGHT', -3, -5)
            else
                button:SetActive(false)
                button:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -3)
                button:SetPoint('TOPRIGHT', prev, 'BOTTOMRIGHT', 0, -3)
            end

            if (self.activeID and self.activeID == item.ID) then
                button:SetActive(true)
            elseif (not self.activeID and not prev) then
                button:SetActive(true)
                self.activeID = item.ID
            end

            prev = button
        end
    end

    f.SetActiveItem = function(self, id)
        self.activeID = id
        for _, item in ipairs(self.items) do
            item:SetActive(item.ID == id)
        end
        if (self.onItemChange) then
            self.onItemChange(id)
        end
    end

    f.SetOnItemChange = function(self, callback)
        self.onItemChange = callback
    end

    f.AddExtraButton = function(self, buttonOptions)
        self.extraButton:Show()
        if (buttonOptions.color) then
            self.extraButton:SetColor(unpack(buttonOptions.color))
        end
        if (buttonOptions.text) then
            self.extraButton:SetText(buttonOptions.text)
        end
        if (buttonOptions.onClick) then
            self.extraButton:SetOnClick(buttonOptions.onClick)
        end
    end

    f.DisableExtraButton = function(self)
        self.extraButton:Hide()
    end

    f.Destroy = function(self)
        self.extraButton:Hide()
        self.activeID = nil
        self:ClearAllPoints()
        splitOptions.pool:Release(self)
    end

    f.configured = true
end

---@param self ExalityFramesSplitOptionsFrame
---@return Frame
splitOptions.Create = function(self)
    local f = self.pool:Acquire()
    if not f.configured then
        configure(f)
    end

    f:Show()
    return f
end
