local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class SlimDropdownOptions : {initial: string, onChange: function, options: table, width?: number, height?: number}

---@class ExalityFramesSlimDropdownInput
local slimDropdown = EXFrames:GetFrame('slim-dropdown-input')

slimDropdown.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
    self.optionItemPool = CreateFramePool('Frame', UIParent)
end

local function CreateOption(f, frameOptions)
    local option = slimDropdown.optionItemPool:Acquire()
    option:SetSize(
        frameOptions.width or 200,
        frameOptions.height and (Round(frameOptions.height * 0.75)) or 20
    )

    if (not option.valueDisplay) then
        local valueDisplay = option:CreateFontString(nil, 'OVERLAY')
        option.valueDisplay = valueDisplay
        valueDisplay:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
        valueDisplay:SetPoint('LEFT', 10, 0)
        valueDisplay:SetWidth(0)

        option.SetOption = function(self, value, label)
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
    slimDropdown.optionItemPool:ReleaseAll()
    local previous
    local count = 0
    for value, label in pairs(options) do
        count = count + 1
        local option = CreateOption(f, frameOptions)
        option:SetOption(value, label)
        option:SetSelected(option.value == selectedValue)
        option:SetPoint('TOPLEFT',
            previous or f.optionContainer,
            previous and 'BOTTOMLEFT' or 'TOPLEFT',
            0,
            previous and -2 or 2
        )
        option:SetParent(f.optionContainer)
        option:Show()
        previous = option
    end
    f.optionContainer:SetHeight(70 * count)
end

local function ConfigureFrame(f, options)
    EXFrames.utils.addObserver(f)
    f.dropdownId = EXFrames.utils.generateRandomString(10)
    f:SetSize(options.width or 200, options.height or 40)
    f:SetFrameStrata('TOOLTIP')
    f.isOpen = false
    f.onChange = options.onChange
    f.options = options.options

    if (not f.valueDisplay) then
        local valueDisplay = f:CreateFontString(nil, 'OVERLAY')
        f.valueDisplay = valueDisplay
        valueDisplay:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
        valueDisplay:SetPoint('LEFT', 10, 0)
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
        tex:SetAllPoints()
        f.texture = tex
    end

    if (not f.chevron) then
        local chevron = f:CreateTexture(nil, 'OVERLAY')
        chevron:SetSize(12, 12)
        chevron:SetPoint('RIGHT', -10, 0)
        chevron:SetTexture(EXFrames.assets.textures.icon.chevronDown)
        f:Observe('isOpen', function(value)
            if (value) then
                f.optionContainer:Show()
                PopulateOptions(f, f.options, options, f.value)
                chevron:SetRotation(math.rad(180))
            else
                f.optionContainer:Hide()
                chevron:SetRotation(math.rad(0))
            end
        end)
    end

    if (not f.hoverContainer) then
        local hoverContainer = CreateFrame('Frame', nil, f)
        hoverContainer:SetAllPoints()
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
    end

    if (options.initial) then
        f:SetValue('value', options.initial)
    end

    f.SetOptions = function(self, newOptions)
        self.options = newOptions
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


---@param self ExalityFramesSlimDropdownInput
---@param options SlimDropdownOptions
---@param parent FRAME
---@return FRAME
slimDropdown.Create = function(self, options, parent)
    local input = self.pool:Acquire()
    ConfigureFrame(input, options)
    if (parent) then
        input:SetParent(parent)
    else
        input:SetParent(nil)
    end
    input.Destroy = function(self)
        self.pool:Release(self)
    end
    input:Show()
    return input
end
