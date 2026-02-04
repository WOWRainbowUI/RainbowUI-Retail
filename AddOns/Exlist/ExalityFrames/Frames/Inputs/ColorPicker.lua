local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesColorPicker
local colorPicker = EXFrames:GetFrame('color-picker')

colorPicker.pool = {}

colorPicker.Init = function(self)
    self.pool = CreateFramePool('Button', UIParent)
end

local function ConfigureFrame(f)
    EXFrames.utils.addObserver(f)
    f:SetHeight(20)
    f.color = { r = 1, g = 1, b = 1, a = 1 }
    local colorBoxContainer = CreateFrame('Frame', nil, f, 'BackdropTemplate')
    colorBoxContainer:SetBackdrop(EXFrames.assets.backdrop.DEFAULT)
    colorBoxContainer:SetBackdropColor(0, 0, 0, 0)
    colorBoxContainer:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
    colorBoxContainer:SetSize(20, 20)
    colorBoxContainer:SetPoint('LEFT')
    local colorBox = colorBoxContainer:CreateTexture(nil, 'BACKGROUND')
    colorBox:SetTexture(EXFrames.assets.textures.solidBg)
    colorBox:SetVertexColor(1, 1, 1, 1)
    colorBox:SetPoint('TOPLEFT', 1, -1)
    colorBox:SetPoint('BOTTOMRIGHT', -1, 1)
    f.colorBox = colorBox

    local label = f:CreateFontString(nil, 'OVERLAY')
    label:SetFont(EXFrames.assets.font.default(), 11, 'OUTLINE')
    label:SetPoint('LEFT', colorBoxContainer, 'RIGHT', 5, 0)
    label:SetWidth(0)
    f.label = label

    f:SetScript('OnClick', function(self)
        local options = {
            swatchFunc = self.OnColorChanged,
            opacityFunc = self.OnColorChanged,
            cancelFunc = self.OnCancel,
            hasOpacity = true,
            opacity = self.color.a,
            r = self.color.r,
            g = self.color.g,
            b = self.color.b,
        }

        ColorPickerFrame:SetupColorPickerAndShow(options)
    end)

    f.SetLabel = function(self, text)
        self.label:SetText(text)
    end

    f.OnColorChanged = function()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        local a = ColorPickerFrame:GetColorAlpha()

        f:SetValue('color', { r = r, g = g, b = b, a = a })
    end

    f.OnCancel = function()
        local r, g, b, a = ColorPickerFrame:GetPreviousValues();
        f:SetValue('color', { r = r, g = g, b = b, a = a })
    end

    f.SetFrameWidth = function(self, width)
        self:SetWidth(width)
    end

    f.SetOptionData = function(self, option)
        self.optionData = option
        self:SetValue('color', option.currentValue and option.currentValue() or { r = 1, g = 1, b = 1, a = 1 })
        self.onChange = option.onChange
        self:SetLabel(option.label)
    end

    f:Observe('color', function(color, _, _, self)
        self.colorBox:SetVertexColor(color.r, color.g, color.b, color.a)
        if (self.onChange) then
            self.onChange(color)
        end
    end)

    f.configured = true
end

---Create/Get Color Picker element
---@param self ExalityFramesColorPicker
---@return Frame
colorPicker.Create = function(self)
    local f = self.pool:Acquire()
    if (not f.configured) then
        ConfigureFrame(f)
    end

    f.Destroy = function(self)
        self.onChange = nil
        self.color = { r = 1, g = 1, b = 1, a = 1 }
        colorPicker.pool:Release(self)
    end

    f:Show()
    return f
end
