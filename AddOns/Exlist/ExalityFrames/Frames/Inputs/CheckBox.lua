local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

--[[
Basically a dummy frame to fill space in options
]]

---@class ExalityFramesCheckbox
local checkbox = EXFrames:GetFrame('checkbox')

checkbox.pool = {}

checkbox.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

local function ConfigureFrame(f)
    EXFrames.utils.addObserver(f)
    f.value = false
    f:EnableMouse(true)
    f:SetSize(1, 20)

    local base = f:CreateTexture(nil, 'ARTWORK')
    base:SetTexture(EXFrames.assets.textures.input.checkbox.base)
    base:SetSize(15, 15)
    base:SetPoint('LEFT')
    f.Base = base

    local hover = f:CreateTexture(nil, 'OVERLAY')
    hover:SetTexture(EXFrames.assets.textures.input.checkbox.hover)
    hover:SetSize(15, 15)
    hover:SetPoint('CENTER', base, 'CENTER')
    hover:SetAlpha(0)
    f.Hover = hover

    local mark = f:CreateTexture(nil, 'OVERLAY')
    mark:SetTexture(EXFrames.assets.textures.input.checkbox.mark)
    mark:SetSize(20, 15)
    mark:SetPoint('CENTER', base, 'CENTER', 2, 1)
    mark:SetAlpha(0)
    f.Mark = mark

    local label = f:CreateFontString(nil, 'OVERLAY')
    label:SetFont(EXFrames.assets.font.default(), 11, 'OUTLINE')
    label:SetPoint('LEFT', base, 'RIGHT', 5, -1)
    label:SetWidth(0)
    f.Label = label

    f:SetScript('OnEnter', function(self)
        self.Hover:SetAlpha(1)
    end)
    f:SetScript('OnLeave', function(self)
        self.Hover:SetAlpha(0)
    end)

    f.SetLabel = function(self, label)
        self.Label:SetText(label)
    end

    f:SetScript('OnMouseDown', function(self)
        self:SetValue('value', not self.value)
    end)

    f.SetFrameWidth = function(self, width)
        self:SetWidth(width)
    end

    f:Observe('value', function(value, _, _, self)
        if (value) then
            self.Mark:SetAlpha(1)
        else
            self.Mark:SetAlpha(0)
        end

        if (self.onChange) then
            self.onChange(value)
        end
    end)

    f.SetOptionData = function(self, option)
        self.optionData = option

        self:SetValue('value', option.currentValue and option.currentValue() or false)
        self:SetLabel(option.label or '')

        self.onChange = option.onChange
    end

    f.configured = true
end

---Create/Get Checkbox element
---@param self ExalityFramesCheckbox
---@return Frame
checkbox.Create = function(self)
    local f = self.pool:Acquire()
    if (not f.configured) then
        ConfigureFrame(f)
    end
    f.Destroy = function(self)
        self.onChange = nil
        checkbox.pool:Release(self)
    end

    f:Show()
    return f
end
