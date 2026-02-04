local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ToggleOptions : {text: string, value:boolean, secondaryText: string, onChange: function}

---@class ExalityFramesToggleInput
local toggle = EXFrames:GetFrame('toggle')

toggle.pool = {}

toggle.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

---@param f Frame
---@param options ToggleOptions
local function ConfigureFrame(f, options)
    EXFrames.utils.addObserver(f)
    f:SetSize(49, 20)

    local base = f:CreateTexture(nil, 'ARTWORK')
    base:SetTexture(EXFrames.assets.textures.input.toggle)
    base:SetTexCoord(1 / 256, 167 / 256, 181 / 256, 248 / 256)
    base:SetAllPoints()

    local borderDisabled = f:CreateTexture(nil, 'ARTWORK')
    borderDisabled:SetTexture(EXFrames.assets.textures.input.toggle)
    borderDisabled:SetTexCoord(1 / 256, 167 / 256, 90 / 256, 157 / 256)
    borderDisabled:SetAllPoints()

    local borderEnabled = f:CreateTexture(nil, 'ARTWORK')
    borderEnabled:SetTexture(EXFrames.assets.textures.input.toggle)
    borderEnabled:SetTexCoord(1 / 256, 167 / 256, 1 / 256, 68 / 256)
    borderEnabled:SetAllPoints()
    borderEnabled:SetAlpha(0)

    local thumbDisabled = f:CreateTexture(nil, 'OVERLAY')
    thumbDisabled:SetTexture(EXFrames.assets.textures.input.toggle)
    thumbDisabled:SetTexCoord(176 / 256, 255 / 256, 84 / 256, 163 / 256)
    thumbDisabled:SetSize(25, 25)
    thumbDisabled:SetPoint('CENTER', base, 'LEFT', 10, 0)

    local thumbEnabled = f:CreateTexture(nil, 'OVERLAY')
    thumbEnabled:SetTexture(EXFrames.assets.textures.input.toggle)
    thumbEnabled:SetTexCoord(176 / 256, 255 / 256, 1 / 256, 80 / 256)
    thumbEnabled:SetSize(25, 25)
    thumbEnabled:SetPoint('CENTER', base, 'LEFT', 10, 0)
    thumbEnabled:SetAlpha(0)

    local duration = 0.2
    local moveBy = 29

    -- KMS part
    local thumbEnabledEnableGroup = EXFrames.utils.animation.getAnimationGroup(thumbEnabled)
    EXFrames.utils.animation.fade(thumbEnabled, duration, 0, 1, thumbEnabledEnableGroup)
    EXFrames.utils.animation.move(thumbEnabled, duration, moveBy, 0, thumbEnabledEnableGroup)

    local thumbEnabledDisableGroup = EXFrames.utils.animation.getAnimationGroup(thumbEnabled)
    EXFrames.utils.animation.fade(thumbEnabled, duration, 1, 0, thumbEnabledDisableGroup)
    EXFrames.utils.animation.move(thumbEnabled, duration, -moveBy, 0, thumbEnabledDisableGroup)

    local thumbDisabledEnableGroup = EXFrames.utils.animation.getAnimationGroup(thumbDisabled)
    EXFrames.utils.animation.fade(thumbDisabled, duration, 1, 0, thumbDisabledEnableGroup)
    EXFrames.utils.animation.move(thumbDisabled, duration, moveBy, 0, thumbDisabledEnableGroup)

    local thumbDisabledDisableGroup = EXFrames.utils.animation.getAnimationGroup(thumbDisabled)
    EXFrames.utils.animation.fade(thumbDisabled, duration, 0, 1, thumbDisabledDisableGroup)
    EXFrames.utils.animation.move(thumbDisabled, duration, -moveBy, 0, thumbDisabledDisableGroup)

    local borderDisabledDisableGroup = EXFrames.utils.animation.getAnimationGroup(borderDisabled)
    EXFrames.utils.animation.fade(borderDisabled, duration, 0, 1, borderDisabledDisableGroup)
    local borderDisabledEnableGroup = EXFrames.utils.animation.getAnimationGroup(borderDisabled)
    EXFrames.utils.animation.fade(borderDisabled, duration, 1, 0, borderDisabledEnableGroup)

    local borderEnabledDisableGroup = EXFrames.utils.animation.getAnimationGroup(borderEnabled)
    EXFrames.utils.animation.fade(borderEnabled, duration, 1, 0, borderEnabledDisableGroup)
    local borderEnabledEnableGroup = EXFrames.utils.animation.getAnimationGroup(borderEnabled)
    EXFrames.utils.animation.fade(borderEnabled, duration, 0, 1, borderEnabledEnableGroup)


    f.Enable = function(self)
        self.enabled = true
        thumbEnabledEnableGroup:Play(false, self.disableAnim and duration or 0)
        thumbDisabledEnableGroup:Play(false, self.disableAnim and duration or 0)
        borderDisabledEnableGroup:Play(false, self.disableAnim and duration or 0)
        borderEnabledEnableGroup:Play(false, self.disableAnim and duration or 0)
    end

    f.Disable = function(self)
        self.enabled = false
        thumbEnabledDisableGroup:Play(false, self.disableAnim and duration or 0)
        thumbDisabledDisableGroup:Play(false, self.disableAnim and duration or 0)
        borderDisabledDisableGroup:Play(false, self.disableAnim and duration or 0)
        borderEnabledDisableGroup:Play(false, self.disableAnim and duration or 0)
    end

    f.Toggle = function(self)
        f:SetValue('value', not f.value)
    end

    f:SetScript('OnMouseDown', function(self)
        self:Toggle()
    end)

    local text = f:CreateFontString(nil, 'OVERLAY')
    text:SetWidth(0)
    text:SetFont(EXFrames.assets.font.default(), 11, 'OUTLINE')
    text:SetPoint('LEFT', base, 'RIGHT', 10, 0)
    text:SetText(options.text)
    f.label = text

    local secondaryText = f:CreateFontString(nil, 'OVERLAY')
    secondaryText:SetWidth(0)
    secondaryText:SetFont(EXFrames.assets.font.default(), 9, 'OUTLINE')
    secondaryText:SetPoint('TOPLEFT', text, 'BOTTOMLEFT', 0, -3)
    secondaryText:SetVertexColor(0.8, 0.8, 0.8, 1)
    secondaryText:SetText(options.secondaryText or "")
    f.secondaryText = secondaryText

    f.SetSecondaryText = function(self, text)
        self.label:ClearAllPoints()
        if (not text or text == '') then
            self.label:SetPoint('LEFT', base, 'RIGHT', 10, 0)
            self.secondaryText:SetText('')
            return
        end
        self.label:SetPoint('TOPLEFT', base, 'TOPRIGHT', 10, 0)
        self.secondaryText:SetText(text)
    end

    f.SetOptionData = function(self, option)
        self.optionData = option
        self.label:SetText(option.label)
        if (option.onChange) then
            self.onChange = option.onChange
        end
        if (option.onClick) then
            self.onClick = option.onClick
        end
        if (option.description) then
            self:SetSecondaryText(option.description)
        end
    end

    f.SetFrameWidth = function(self, width)
        --noop
    end

    f.isConfigured = true
end

---@param self ExalityFramesToggleInput
---@param options ToggleOptions
---@param parent FRAME
---@return FRAME
toggle.Create = function(self, options, parent)
    ---@type FRAME
    local input = self.pool:Acquire()
    input.value = false
    if (not input.isConfigured) then
        ConfigureFrame(input, options)
    end

    if (parent) then
        input:SetParent(parent)
    else
        input:SetParent(nil)
    end

    input.Destroy = function(self)
        self:ClearObservable()
        self:SetSecondaryText()
        toggle.pool:Release(self)
    end

    if (options.text) then
        input.label:SetText(options.text)
    end

    if (options.secondaryText) then
        input:SetSecondaryText(options.secondaryText)
    end

    input.disableAnim = true
    input:SetValue('value', options.value)

    if (options.value and not input.enabled) then
        input:Enable()
    elseif (not options.value and input.enabled) then
        input:Disable()
    end
    input.disableAnim = false

    input:Observe('value', function(value, oldValue)
        if (value and not input.enabled) then
            input:Enable()
        elseif (not value and input.enabled) then
            input:Disable();
        end
        if (input.onChange) then
            input.onChange(value)
        end
    end)

    input:Show()
    return input
end
