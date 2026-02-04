local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

local LSM = LibStub:GetLibrary("LibSharedMedia-3.0", true)

---@class ExalityFramesScrollFrame
local scrollFrame = EXFrames:GetFrame('scroll-frame')

---@class DropdownOptions : {initial: string, onChange: function, options: table, label: string, width?: number, height?: number}

---@class ExalityFramesDropdownInput
local dropdown = EXFrames:GetFrame('dropdown')

dropdown.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
    self.optionItemPool = CreateFramePool('Frame', UIParent)
end

local function CreateOption(f, frameOptions)
    local option = dropdown.optionItemPool:Acquire()
    option:SetSize(
        frameOptions.width or 200,
        frameOptions.height and ((frameOptions.height * 0.75)) or 20
    )

    if (not option.valueDisplay) then
        local valueDisplay = option:CreateFontString(nil, 'OVERLAY')
        option.valueDisplay = valueDisplay
        valueDisplay:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
        valueDisplay:SetPoint('LEFT', 10, 0)
        valueDisplay:SetWidth(0)

        option.SetOption = function(self, value, label)
            if (f.optionData and f.optionData.isFontDropdown and LSM) then
                valueDisplay:SetFont(LSM:Fetch('font', value), 10, 'OUTLINE')
            else
                valueDisplay:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
            end
            option.value = value
            option.valueDisplay:SetText(label)
        end

        local tex = option:CreateTexture(nil, 'BACKGROUND')
        tex:SetTexture(EXFrames.assets.textures.window.bg)
        tex:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
        tex:SetTextureSliceMargins(15, 15, 15, 15)
        tex:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
        tex:SetVertexColor(0.15, 0.15, 0.15, 1)
        tex:SetAllPoints()
        option.texture = tex
        option.SetSelected = function(self, selected)
            if (selected) then
                option.texture:SetVertexColor(0.25, 0.25, 0.25, 1)
            else
                option.texture:SetVertexColor(0.15, 0.15, 0.15, 1)
            end
        end
    end

    option:SetScript('OnMouseDown', function(self)
        EXFrames:Callback('dropdownSelect', self.dropdownId, self.value)
        f:SetInputValue(self.value)
        f:SetValue('isOpen', false)
    end)

    if (not option.hoverContainer) then
        local hoverContainer = CreateFrame('Frame', nil, option)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        option.hoverContainer = hoverContainer
        hoverBorder:SetTexture(EXFrames.assets.textures.input.editBoxHover)
        hoverBorder:SetTexCoord(6 / 512, 506 / 512, 5 / 64, 58 / 64)
        hoverBorder:SetAllPoints()
        hoverContainer:SetAlpha(0)
        option.animDur = 0.15
        option.onHover = EXFrames.utils.animation.fade(hoverContainer, option.animDur, 0, 1)
        option.onHoverLeave = EXFrames.utils.animation.fade(hoverContainer, option.animDur, 1, 0)
        hoverBorder:SetVertexColor(252 / 255, 102 / 255, 3 / 255, 1)
    end

    option:SetScript('OnEnter', function(self)
        self.onHover:Play()
    end)
    option:SetScript('OnLeave', function(self) self.onHoverLeave:Play() end)
    return option
end

local function PopulateOptions(f, options, frameOptions, selectedValue)
    dropdown.optionItemPool:ReleaseAll()
    local previous
    local optionsNum = CountTable(options)
    local count = min(optionsNum, 10) -- Limit to 10 options to be visible

    local container = f.optionContainer
    local overLimit = optionsNum > 10
    if (overLimit) then
        container = f.optionContainer.scrollFrame.child
        f.optionContainer.scrollFrame:Show()
    else
        f.optionContainer.scrollFrame:Hide()
    end

    for value, label in EXFrames.utils.spairs(options, function(t, a, b) return t[a] < t[b] end) do
        local option = CreateOption(f, frameOptions)
        if (overLimit) then
            option:SetWidth((frameOptions.width or 200) - 20)
        else
            option:SetWidth(frameOptions.width or 200)
        end
        option:SetOption(value, label)
        option:SetSelected(option.value == selectedValue)
        option:SetPoint('TOPLEFT',
            previous or container,
            previous and 'BOTTOMLEFT' or 'TOPLEFT',
            0,
            previous and -2 or (overLimit and 0 or 2)
        )
        option:SetParent(container)
        option:Show()
        previous = option
    end
    local optionHeight = frameOptions.height and ((frameOptions.height * 0.75)) or 20
    f.optionContainer:SetHeight(optionHeight * count)
    f.optionContainer.scrollFrame:UpdateScrollChild(f.optionContainer:GetWidth() - 20, optionHeight * optionsNum)
end

local function ConfigureFrame(f, options)
    EXFrames.utils.addObserver(f)
    f.dropdownId = EXFrames.utils.generateRandomString(10)
    f:SetSize(options.width or 200, options.height or 40)
    f:SetFrameStrata('TOOLTIP')
    f.isOpen = false
    f.frameOptions = options
    f.onChange = options.onChange
    f.options = options.options

    if (not f.valueDisplay) then
        local valueDisplay = f:CreateFontString(nil, 'OVERLAY')
        f.valueDisplay = valueDisplay
        valueDisplay:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
        valueDisplay:SetPoint('LEFT', 10, -6)
        valueDisplay:SetWidth(0)
        valueDisplay:SetText(' ')
        f:Observe('value', function(value)
            local label = f.options[value] or value
            valueDisplay:SetText(label ~= '' and label or ' ')
        end)

        f.SetInputValue = function(self, value)
            self:SetValue('value', value)
            if (self.onChange) then
                self.onChange(value)
            end
        end

        f:SetScript('OnMouseDown', function()
            local isOpen = not f.isOpen
            EXFrames:Callback(isOpen and 'dropdownOpen' or 'dropdownClose', f.dropdownId)
            f:SetValue('isOpen', isOpen)
        end)

        local tex = f:CreateTexture(nil, 'BACKGROUND')
        tex:SetTexture(EXFrames.assets.textures.window.bg)
        tex:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
        tex:SetTextureSliceMargins(15, 15, 15, 15)
        tex:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
        tex:SetVertexColor(0.25, 0.25, 0.25, 0.6)
        tex:SetPoint('TOPLEFT', 0, -12)
        tex:SetPoint('BOTTOMRIGHT')
        f.texture = tex
    end

    if (not f.chevron) then
        local chevron = f:CreateTexture(nil, 'OVERLAY')
        chevron:SetSize(12, 12)
        chevron:SetPoint('RIGHT', -10, -6)
        chevron:SetTexture(EXFrames.assets.textures.icon.chevronDown)
        f:Observe('isOpen', function(value)
            if (value) then
                f.optionContainer:Show()
                PopulateOptions(f, f.options, f.frameOptions, f.value)
                chevron:SetRotation(math.rad(180))
            else
                f.optionContainer:Hide()
                chevron:SetRotation(math.rad(0))
            end
        end)
    end

    if (not f.hoverContainer) then
        local hoverContainer = CreateFrame('Frame', nil, f)
        hoverContainer:SetPoint('TOPLEFT', 0, -12)
        hoverContainer:SetPoint('BOTTOMRIGHT')
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        f.hoverContainer = hoverContainer
        hoverBorder:SetTexture(EXFrames.assets.textures.input.editBoxHover)
        hoverBorder:SetTexCoord(6 / 512, 506 / 512, 5 / 64, 58 / 64)
        hoverBorder:SetAllPoints()
        hoverContainer:SetAlpha(0.1)
        f.animDur = 0.15
        f.onHover = EXFrames.utils.animation.fade(hoverContainer, f.animDur, 0.1, 1)
        f.onHoverLeave = EXFrames.utils.animation.fade(hoverContainer, f.animDur, 1, 0.1)
        hoverBorder:SetVertexColor(0.9, 0.9, 0.9, 1)
    end

    if (not f.label) then
        local textFrame = f:CreateFontString(nil, 'OVERLAY')
        textFrame:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
        textFrame:SetPoint('BOTTOMLEFT', f.valueDisplay, 'TOPLEFT', -10, 12)
        textFrame:SetWidth(0)
        f.label = textFrame
        textFrame:SetText(options.label or '')

        f.SetLabel = function(self, text)
            self.label:SetText(text)
        end
    end

    f:SetScript('OnEnter', function(self)
        self.onHover:Play()
    end)
    f:SetScript('OnLeave', function(self) self.onHoverLeave:Play() end)

    if (not f.optionContainer) then
        local optionContainer = CreateFrame('Frame', nil, UIParent)
        optionContainer:SetHeight(1)
        optionContainer:SetPoint('TOPLEFT', f, 'BOTTOMLEFT', 0, -5)
        optionContainer:SetPoint('TOPRIGHT', f, 'BOTTOMRIGHT', 0, -5)
        optionContainer:SetFrameStrata('FULLSCREEN_DIALOG')
        optionContainer:SetFrameLevel(99)
        f.optionContainer = optionContainer
        optionContainer:Hide()
        optionContainer:SetScript('OnEnter', function() end)
        optionContainer:SetScript('OnLeave', function() end)
        local optionContainerBg = optionContainer:CreateTexture(nil, 'BACKGROUND')
        optionContainerBg:SetTexture(EXFrames.assets.textures.window.bg)
        optionContainerBg:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
        optionContainerBg:SetTextureSliceMargins(15, 15, 15, 15)
        optionContainerBg:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
        optionContainerBg:SetVertexColor(0, 0, 0, 1)
        optionContainerBg:SetAllPoints()
        f.optionContainerBg = optionContainerBg

        local scrollFrame = scrollFrame:Create()
        scrollFrame:SetParent(optionContainer)
        scrollFrame:SetPoint('TOPLEFT', 0, 0)
        scrollFrame:SetPoint('BOTTOMRIGHT', -20, 0)
        scrollFrame:Hide()
        f.optionContainer.scrollFrame = scrollFrame
    end

    if (options.initial) then
        f:SetValue('value', options.initial)
    end

    f.SetOptions = function(self, newOptions)
        self.options = newOptions
    end

    f.SetOptionData = function(self, option)
        self.optionData = option
        self:SetLabel(option.label)
        self:SetOptions(option.getOptions())
        self:SetValue('value', option.currentValue())
        self.frameOptions.isFontDropdown = option.isFontDropdown
        self.onChange = option.onChange
    end

    f.SetFrameWidth = function(self, width)
        self.frameOptions.width = width
        self:SetWidth(width)
    end

    local handleDropdownEvent = function(event, id)
        if (event == 'dropdownOpen') then
            if (id ~= f.dropdownId and f.isOpen) then
                f:SetValue('isOpen', false) -- Close dropdown if other has closed it
            end
        end
        if (event == 'windowClose') then
            f:SetValue('isOpen', false) -- Close Dropdown if window is closed
        end
    end

    EXFrames:RegisterCallback({
        events = { 'dropdownOpen', 'windowClose' },
        func = handleDropdownEvent
    })
end


---@param self ExalityFramesDropdownInput
---@param options DropdownOptions
---@param parent FRAME
---@return FRAME
dropdown.Create = function(self, options, parent)
    local input = self.pool:Acquire()
    ConfigureFrame(input, options)
    if (parent) then
        input:SetParent(parent)
    else
        input:SetParent(nil)
    end
    input.Destroy = function(self)
        self.optionData = nil
        dropdown.pool:Release(self)
    end
    input:Show()
    return input
end
