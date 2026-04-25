--[[
    RGX-Framework - UI Controls
    
    Shared UI components for RGX addons.
    
    Usage:
        local UI = RGX:GetModule("ui")
        
        -- Font dropdown
        UI:CreateFontDropdown(parent, {
            key = "fontFamily",
            label = "Font",
            onChange = function(fontName, fontPath) ... end
        })
        
        -- Color picker
        UI:CreateColorPicker(parent, {
            key = "textColor",
            label = "Text Color",
            default = {r=1, g=1, b=1}
        })
        
        -- Slider
        UI:CreateSlider(parent, {
            key = "scale",
            label = "Scale",
            min = 0.5,
            max = 2,
            step = 0.1,
            default = 1
        })
        
        -- Toggle
        UI:CreateToggle(parent, {
            key = "enabled",
            label = "Enable",
            default = true
        })
--]]

local _, UI = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX UI: RGX-Framework not loaded")
    return
end

UI.name = "ui"
UI.version = "1.0.0"

-- Control registry
UI.controls = {}
UI.backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    edgeSize = 1,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}

--[[============================================================================
    FONT DROPDOWN
============================================================================]]

function UI:CreateFontDropdown(parent, options)
    options = options or {}
    local key = options.key or "fontFamily"
    local label = options.label or "Font"
    local width = options.width or 200
    local storage = options.storage or {}
    local defaultName = options.defaultName or "FRIZQT"
    local onChange = options.onChange or function() end
    
    local Fonts = RGX:GetModule("fonts")
    if not Fonts then
        return self:CreateLabel(parent, {text = "RGX-Framework not loaded", color = "red"})
    end
    
    -- Container
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width, 50)
    
    -- Label
    container.label = self:CreateLabel(container, {
        text = label,
        size = "small",
        color = "muted"
    })
    container.label:SetPoint("TOPLEFT", 0, 0)
    
    -- Dropdown button
    local button = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    button:SetSize(width, 25)
    button:SetPoint("TOPLEFT", container.label, "BOTTOMLEFT", 0, -4)
    
    -- Current font display
    local currentFont = storage[key] or Fonts:GetDefault()
    local fontInfo = Fonts:GetInfo(currentFont)
    button:SetText(fontInfo and fontInfo.name or currentFont)
    
    -- Click to open font menu
    button:SetScript("OnClick", function()
        self:OpenFontMenu(button, {
            current = currentFont,
            onSelect = function(fontName, fontPath)
                storage[key] = fontPath
                button:SetText(fontName)
                onChange(fontName, fontPath)
            end
        })
    end)
    
    container.button = button
    return container
end

function UI:CreateStatusBarDropdown(parent, options)
    options = options or {}

    local Textures = RGX:GetModule("textures")
    if not Textures or type(Textures.CreateBarSettingControl) ~= "function" then
        return self:CreateLabel(parent, {text = "RGX Textures not loaded", color = "red"})
    end

    return Textures:CreateBarSettingControl(parent, options)
end

UI.CreateTextureDropdown = UI.CreateStatusBarDropdown

function UI:OpenFontMenu(anchor, options)
    local Fonts = RGX:GetModule("fonts")
    if not Fonts then return end
    
    local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    menu:SetSize(250, 300)
    menu:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
    menu:SetBackdrop(self.backdrop)
    menu:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    menu:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Close on escape or click outside
    menu:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then self:Hide() end
    end)
    menu:EnableKeyboard(true)
    
    local closeTimer
    menu:SetScript("OnUpdate", function(self)
        if not MouseIsOver(self) and not MouseIsOver(anchor) then
            closeTimer = (closeTimer or 0) + 1
            if closeTimer > 5 then self:Hide() end
        else
            closeTimer = 0
        end
    end)
    
    -- Scroll frame
    local scroll = CreateFrame("ScrollFrame", nil, menu, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", -24, 8)
    
    local content = CreateFrame("Frame")
    content:SetSize(200, 1)
    scroll:SetScrollChild(content)
    
    -- Add fonts by category
    local categories = Fonts:GetCategories()
    local yOffset = 0
    
    for _, category in ipairs(categories) do
        -- Category header
        local header = self:CreateLabel(content, {
            text = category,
            size = "small",
            color = "accent"
        })
        header:SetPoint("TOPLEFT", 0, yOffset)
        yOffset = yOffset - 20
        
        -- Fonts in category
        local fonts = Fonts:ListByCategory(category)
        for _, fontName in ipairs(fonts) do
            local btn = CreateFrame("Button", nil, content)
            btn:SetSize(200, 20)
            btn:SetPoint("TOPLEFT", 0, yOffset)
            
            local fontInfo = Fonts:GetInfo(fontName)
            local displayText = fontInfo and fontInfo.name or fontName
            
            -- Font preview
            btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            btn.text:SetPoint("LEFT", 4, 0)
            btn.text:SetText(displayText)
            
            -- Try to apply actual font
            local path = Fonts:GetPath(fontName)
            if path then
                btn.text:SetFont(path, 11, "")
            end
            
            -- Highlight current
            if fontName == options.current then
                btn:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8"})
                btn:SetBackdropColor(0.2, 0.4, 0.6, 0.5)
            end
            
            btn:SetScript("OnClick", function()
                options.onSelect(fontName, path)
                menu:Hide()
            end)
            
            yOffset = yOffset - 22
        end
        
        yOffset = yOffset - 10
    end
    
    content:SetHeight(-yOffset)
    menu:Show()
    
    return menu
end

--[[============================================================================
    COLOR PICKER CONTROL
============================================================================]]

function UI:CreateColorPicker(parent, options)
    options = options or {}
    local key = options.key or "color"
    local label = options.label or "Color"
    local default = options.default or {r=1, g=1, b=1}
    local storage = options.storage or {}
    local onChange = options.onChange or function() end
    local previewOnClick = options.previewOnClick  -- Function to call when clicking swatch
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200, 24)
    
    -- Label
    container.label = self:CreateLabel(container, {
        text = label,
        size = "small",
        color = "muted"
    })
    container.label:SetPoint("LEFT", 0, 0)
    
    -- Color swatch button
    local swatch = CreateFrame("Button", nil, container)
    swatch:SetSize(20, 20)
    swatch:SetPoint("LEFT", container.label, "RIGHT", 10, 0)
    
    swatch.bg = swatch:CreateTexture(nil, "BACKGROUND")
    swatch.bg:SetAllPoints()
    swatch.bg:SetColorTexture(0, 0, 0, 1)
    
    swatch.tex = swatch:CreateTexture(nil, "ARTWORK")
    swatch.tex:SetSize(16, 16)
    swatch.tex:SetPoint("CENTER")
    
    -- Set initial color
    local currentColor = storage[key] or default
    swatch.tex:SetColorTexture(currentColor.r or 1, currentColor.g or 1, currentColor.b or 1, 1)
    
    swatch:SetScript("OnClick", function()
        -- Call preview function if provided (shows preview of what we're editing)
        if previewOnClick then
            previewOnClick()
        end
        
        local ColorPicker = RGX:GetModule("colorpicker")
        if ColorPicker then
            ColorPicker:Show({
                r = currentColor.r or 1,
                g = currentColor.g or 1,
                b = currentColor.b or 1
            }, function(r, g, b)
                currentColor = {r=r, g=g, b=b}
                storage[key] = currentColor
                swatch.tex:SetColorTexture(r, g, b, 1)
                onChange(r, g, b)
            end)
        else
            -- Fallback to Blizzard color picker
            local r, g, b = currentColor.r or 1, currentColor.g or 1, currentColor.b or 1
            ColorPickerFrame:SetupColorPickerAndShow({
                r = r, g = g, b = b,
                swatchFunc = function()
                    local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                    currentColor = {r=nr, g=ng, b=nb}
                    storage[key] = currentColor
                    swatch.tex:SetColorTexture(nr, ng, nb, 1)
                    onChange(nr, ng, nb)
                end
            })
        end
    end)
    
    -- Reset button
    local reset = self:CreateResetButton(container, function()
        storage[key] = {unpack(default)}
        swatch.tex:SetColorTexture(default.r, default.g, default.b, 1)
        onChange(default.r, default.g, default.b)
    end)
    reset:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
    
    container.swatch = swatch
    return container
end

--[[============================================================================
    SLIDER CONTROL
============================================================================]]

function UI:CreateSlider(parent, options)
    options = options or {}
    local key = options.key or "value"
    local label = options.label or "Slider"
    local min = options.min or 0
    local max = options.max or 100
    local step = options.step or 1
    local default = options.default or min
    local storage = options.storage or {}
    local suffix = options.suffix or ""
    local onChange = options.onChange or function() end
    local width = options.width or 200
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width, 50)
    
    -- Label with current value
    container.label = self:CreateLabel(container, {
        text = label,
        size = "small",
        color = "muted"
    })
    container.label:SetPoint("TOPLEFT", 0, 0)
    
    container.valueLabel = self:CreateLabel(container, {
        text = (storage[key] or default) .. suffix,
        size = "small"
    })
    container.valueLabel:SetPoint("TOPRIGHT", 0, 0)
    
    -- Slider
    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
    slider:SetSize(width, 20)
    slider:SetPoint("TOPLEFT", container.label, "BOTTOMLEFT", 0, -4)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetValue(storage[key] or default)
    
    -- Style the slider
    slider.Low:SetText("")
    slider.High:SetText("")
    slider.Text:SetText("")
    
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / step + 0.5) * step
        storage[key] = value
        container.valueLabel:SetText(value .. suffix)
        onChange(value)
    end)
    
    -- Reset button
    local reset = self:CreateResetButton(container, function()
        slider:SetValue(default)
        storage[key] = default
        container.valueLabel:SetText(default .. suffix)
        onChange(default)
    end)
    reset:SetPoint("LEFT", slider, "RIGHT", 8, 0)
    
    container.slider = slider
    return container
end

--[[============================================================================
    TOGGLE CONTROL
============================================================================]]

function UI:CreateToggle(parent, options)
    options = options or {}
    local key = options.key or "enabled"
    local label = options.label or "Toggle"
    local default = options.default ~= false
    local storage = options.storage or {}
    local onChange = options.onChange or function() end
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200, 24)
    
    -- Checkbox
    local check = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    check:SetSize(24, 24)
    check:SetPoint("LEFT", 0, 0)
    check:SetChecked(storage[key] ~= false and default)
    
    -- Label
    container.label = self:CreateLabel(container, {
        text = label,
        size = "small"
    })
    container.label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    
    check:SetScript("OnClick", function(self)
        local enabled = self:GetChecked()
        storage[key] = enabled
        onChange(enabled)
    end)
    
    -- Reset
    local reset = self:CreateResetButton(container, function()
        check:SetChecked(default)
        storage[key] = default
        onChange(default)
    end)
    reset:SetPoint("LEFT", container.label, "RIGHT", 10, 0)
    
    container.check = check
    return container
end

--[[============================================================================
    LABEL
============================================================================]]

function UI:CreateLabel(parent, options)
    options = options or {}
    local text = options.text or ""
    local size = options.size or "normal"  -- small, normal, large
    local color = options.color or "normal"  -- normal, muted, accent, red, green
    
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    
    -- Set font size
    if size == "small" then
        label:SetFontObject("GameFontNormalSmall")
    elseif size == "large" then
        label:SetFontObject("GameFontNormalLarge")
    else
        label:SetFontObject("GameFontNormal")
    end
    
    -- Set color
    local colors = {
        muted = {0.7, 0.7, 0.7},
        accent = {0, 0.64, 1},
        red = {1, 0.2, 0.2},
        green = {0.2, 1, 0.2},
        yellow = {1, 1, 0.2}
    }
    
    local c = colors[color] or {1, 1, 1}
    label:SetTextColor(c[1], c[2], c[3])
    
    label:SetText(text)
    return label
end

--[[============================================================================
    RESET BUTTON
============================================================================]]

function UI:CreateResetButton(parent, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(16, 16)
    
    btn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    btn:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
    
    btn:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton")
    btn:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 0.5)
    
    btn:SetScript("OnClick", onClick)
    
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Reset to default")
        GameTooltip:Show()
    end)
    
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    return btn
end

--[[============================================================================
    SECTION/PANEL
============================================================================]]

function UI:CreateSection(parent, options)
    options = options or {}
    local title = options.title or "Section"
    local width = options.width or 300
    local height = options.height or 200
    
    local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    section:SetSize(width, height)
    section:SetBackdrop(self.backdrop)
    section:SetBackdropColor(0.08, 0.08, 0.08, 0.85)
    section:SetBackdropBorderColor(0.188, 0.212, 0.231, 1)
    
    -- Header
    section.header = self:CreateLabel(section, {
        text = title,
        size = "small",
        color = "accent"
    })
    section.header:SetPoint("TOPLEFT", 12, -10)
    
    -- Content area
    section.content = CreateFrame("Frame", nil, section)
    section.content:SetPoint("TOPLEFT", 12, -30)
    section.content:SetPoint("BOTTOMRIGHT", -12, 12)
    
    return section
end

--[[============================================================================
    PREVIEW FRAME
============================================================================]]

function UI:CreatePreviewFrame(parent, options)
    options = options or {}
    local width = options.width or 250
    local height = options.height or 150
    
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetBackdrop(self.backdrop)
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Label
    frame.label = self:CreateLabel(frame, {
        text = options.title or "Preview",
        size = "small",
        color = "muted"
    })
    frame.label:SetPoint("TOP", 0, -8)
    
    -- Preview content area
    frame.preview = CreateFrame("Frame", nil, frame)
    frame.preview:SetPoint("CENTER", 0, -10)
    frame.preview:SetSize(width - 20, height - 40)
    
    -- Background for preview
    frame.preview.bg = frame.preview:CreateTexture(nil, "BACKGROUND")
    frame.preview.bg:SetAllPoints()
    frame.preview.bg:SetColorTexture(0.15, 0.15, 0.15, 1)
    
    return frame
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function UI:Init()
    RGX:RegisterModule("ui", self)
end

UI:Init()
