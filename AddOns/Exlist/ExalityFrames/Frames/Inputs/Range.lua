local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesRangeInput
local range = EXFrames:GetFrame('range-input')

range.pool = {}

range.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

local function ConfigureFrame(f)
    EXFrames.utils.addObserver(f)
    f:SetSize(200, 55)
    f.step = 1
    f.min = 0
    f.max = 100
    f.value = 0

    hooksecurefunc(f, 'SetPoint', function(self)
        C_Timer.After(0.01, function()
            self:UpdateDotPosition()
        end)
    end)

    local label = f:CreateFontString(nil, 'OVERLAY')
    label:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
    label:SetPoint('TOPLEFT', 2, -2)
    label:SetWidth(0)
    f.label = label

    local leftButton = CreateFrame('Button', nil, f)
    leftButton:SetSize(12, 20)
    leftButton:SetPoint('LEFT')
    local leftButtonTexture = leftButton:CreateTexture(nil, 'BACKGROUND')
    leftButtonTexture:SetTexture(EXFrames.assets.textures.input.range.leftArrow)
    leftButtonTexture:SetVertexColor(1, 1, 1, 1)
    leftButtonTexture:SetAllPoints()

    leftButton:SetScript('OnEnter', function(self)
        leftButtonTexture:SetTexture(EXFrames.assets.textures.input.range.leftArrowActive)
    end)
    leftButton:SetScript('OnLeave', function(self)
        leftButtonTexture:SetTexture(EXFrames.assets.textures.input.range.leftArrow)
    end)
    leftButton:SetScript('OnClick', function(self)
        f:SetValue('value', f.value - f.step)
    end)

    local rightButton = CreateFrame('Button', nil, f)
    rightButton:SetSize(12, 20)
    rightButton:SetPoint('RIGHT')
    local rightButtonTexture = rightButton:CreateTexture(nil, 'BACKGROUND')
    rightButtonTexture:SetTexture(EXFrames.assets.textures.input.range.rightArrow)
    rightButtonTexture:SetVertexColor(1, 1, 1, 1)
    rightButtonTexture:SetAllPoints()

    rightButton:SetScript('OnEnter', function(self)
        rightButtonTexture:SetTexture(EXFrames.assets.textures.input.range.rightArrowActive)
    end)
    rightButton:SetScript('OnLeave', function(self)
        rightButtonTexture:SetTexture(EXFrames.assets.textures.input.range.rightArrow)
    end)
    rightButton:SetScript('OnClick', function(self)
        f:SetValue('value', f.value + f.step)
    end)

    local trackContainer = CreateFrame('Frame', nil, f)
    trackContainer:SetHeight(8)
    trackContainer:SetPoint('LEFT', leftButton, 'RIGHT', 6, 0)
    trackContainer:SetPoint('RIGHT', rightButton, 'LEFT', -6, 0)
    local track = trackContainer:CreateTexture(nil, 'BACKGROUND')
    track:SetTexture(EXFrames.assets.textures.input.range.track)
    track:SetAllPoints()
    f.track = trackContainer

    local dot = CreateFrame('Button', nil, trackContainer)
    dot:SetSize(15, 15)
    dot:SetPoint('CENTER')
    local dotTexture = dot:CreateTexture(nil, 'BACKGROUND')
    dotTexture:SetTexture(EXFrames.assets.textures.input.range.dot)
    dotTexture:SetVertexColor(1, 1, 1, 1)
    dotTexture:SetAllPoints()
    f.dot = dot

    dot:SetScript('OnMouseDown', function(self)
        self.isDragging = true
        self.startX = GetCursorPosition()
        local _, _, _, offsetX = self:GetPoint(1)
        self.startDotX = offsetX
        dotTexture:SetTexture(EXFrames.assets.textures.input.range.dotActive)
        self:SetScript('OnUpdate', function(self)
            if (self.isDragging) then
                local mouseX = GetCursorPosition()
                local trackWidth = trackContainer:GetWidth() / 2
                local mouseOffset = Round(self.startDotX + (mouseX - self.startX))
                local dotPosition = math.max(mouseOffset, -trackWidth)
                dotPosition = math.min(dotPosition, trackWidth)
                self:SetPoint('CENTER', dotPosition, 0)
                f:CalculateValue()
            end
        end)
    end)

    dot:SetScript('OnMouseUp', function(self)
        self.isDragging = false
        if (f.OnChange) then
            f.OnChange(f.value)
        end
        dotTexture:SetTexture(EXFrames.assets.textures.input.range.dot)
        self:SetScript('OnUpdate', nil)
    end)
    dot:SetAlpha(0)

    local editBoxContainer = CreateFrame('Frame', nil, f)
    editBoxContainer:SetSize(50, 15)
    editBoxContainer:SetPoint('TOP', track, 'BOTTOM', 0, -5)
    local editBoxBg = editBoxContainer:CreateTexture(nil, 'BACKGROUND')
    editBoxBg:SetTexture(EXFrames.assets.textures.input.range.editBox)
    editBoxBg:SetVertexColor(1, 1, 1, 1)
    editBoxBg:SetAllPoints()
    local editBox = CreateFrame('EditBox', nil, editBoxContainer)
    editBox:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
    editBox:SetPoint('TOPLEFT', 2, -2)
    editBox:SetPoint('BOTTOMRIGHT', -2, 2)
    editBox:SetJustifyH('CENTER')
    editBox:SetTextInsets(2, 2, 1, 0)
    editBox:SetText(0)
    editBox:SetClampRectInsets(0, 0, 0, 0)
    editBox:SetNumericFullRange(true)
    editBox:SetAutoFocus(false)
    f.editBox = editBox

    editBox:SetScript('OnEditFocusLost', function(self)
        local currValue = f.value
        -- Set current value again in case value did not get commited
        f:SetValue('value', currValue)
    end)

    editBox:SetScript('OnEnterPressed', function(self)
        local value = tonumber(self:GetText())
        if (not value) then return end
        value = math.max(math.min(value, f.max), f.min)
        f:SetValue('value', value)
    end)

    editBox:SetScript('OnEscapePressed', function(self)
        self:ClearFocus()
    end)

    --- Functions
    f.SetLabel = function(self, text)
        self.label:SetText(text)
    end

    f.SetFrameWidth = function(self, width)
        self:SetWidth(width)
        C_Timer.After(0.2, function()
            self:UpdateDotPosition()
        end)
    end

    f.SetOptionData = function(self, option)
        self.optionData = option
        self.min = option.min or 0
        self.max = option.max or 100
        self.step = option.step or 1
        self:SetLabel(option.label)
        self.dot:SetAlpha(0)
        if (option.currentValue) then
            self:SetValue('value', option.currentValue())
        end
    end

    f.CalculateValue = function(self)
        local frameWidth = self.track:GetWidth()
        local _, _, _, dotX = self.dot:GetPoint(1)
        local dotRealX = frameWidth / 2 + dotX
        local perc = dotRealX / frameWidth
        local absValue = perc * (self.max - self.min)
        -- snap to closest step
        local rawValue = self.min + absValue
        local step = self.step or 1
        local value = self.min + math.floor((rawValue - self.min) / step) * step
        -- Clamp value just in case
        value = math.max(math.min(value, self.max), self.min)
        if (value == self.value) then return end
        self:SetValue('value', value)
    end

    f.UpdateDotPosition = function(self)
        local frameWidth = self.track:GetWidth()
        if (frameWidth < 1) then
            return
        end
        self.dot:SetAlpha(1)
        local value = self.value
        local offset = value - self.min
        local perc = offset / (self.max - self.min)
        local sign = perc < 0.5 and -1 or 1
        local percFromMid = math.abs(perc - 0.5)
        local dotOffset = frameWidth * percFromMid * sign
        self.dot:SetPoint('CENTER', dotOffset, 0)
    end

    f.SetOnChange = function(self, onChange)
        self.OnChange = onChange
    end

    f:Observe('value', function(value)
        f:UpdateDotPosition()
        if (not value or (type(value) ~= 'number' and type(value) ~= 'string')) then
            return
        end
        if (value % 1 == 0) then
            f.editBox:SetText(string.format('%.0f', value))
        else
            f.editBox:SetText(string.format('%.2f', value))
        end
        if (f.OnChange and not f.dot.isDragging) then
            f.OnChange(value)
        end
    end)

    f.configured = true
end

---Create Range input
---@param self ExalityFramesRangeInput
range.Create = function(self)
    local f = self.pool:Acquire()
    if (not f.configured) then
        ConfigureFrame(f)
    end

    f.onChange = nil

    f.Destroy = function(self)
        range.pool:Release(self)
    end

    f:Show()
    return f
end
