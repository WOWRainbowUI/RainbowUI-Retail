--[[
    RGX-Framework - Colors Module
    
    Color management and utilities for WoW addons.
    
    For Addon Developers:
        local Colors = RGX:GetModule("colors")
        local r, g, b = Colors:GetRGB("blue")
        local hex = Colors:GetHex("epic")
    
    API:
        Colors:Get(name)           - Get color table {r,g,b,hex}
        Colors:GetRGB(name)        - Get r, g, b values
        Colors:GetHex(name)        - Get hex string
        Colors:Create(r,g,b,a)     - Build a normalized color table
        Colors:Clone(color)        - Copy a named or raw color
        Colors:GetClass(class)     - Get class color
        Colors:GetQuality(quality) - Get item quality color
        Colors:Wrap(text, color)   - Wrap text in color
        Colors:Lerp(c1, c2, t)     - Blend colors
        Colors:Darken(color, amt)  - Darken color
        Colors:Lighten(color, amt) - Lighten color
        Colors:OpenPicker(opts)    - Open Blizzard color picker popup
        Colors:CreateColorPicker(parent, opts) - Create a label + swatch widget
        Colors:CreateColorSettingControl(parent, opts) - Create a bound color setting control with reset
        Colors:ApplyStatusBar(bar, color) - Apply a color to a status bar
--]]

local _, Colors = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX Colors: RGX-Framework not loaded")
    return
end

Colors.name = "colors"
Colors.version = "1.0.0"

-- WoW Class Colors
Colors.class = {}
for class, color in pairs(RAID_CLASS_COLORS) do
    Colors.class[class] = {
        r = color.r,
        g = color.g,
        b = color.b,
        hex = color.colorStr
    }
end

-- Item Quality Colors
Colors.quality = {
    poor =      { r = 0.61, g = 0.61, b = 0.61, hex = "9d9d9d" },
    common =    { r = 1.00, g = 1.00, b = 1.00, hex = "ffffff" },
    uncommon =  { r = 0.12, g = 1.00, b = 0.00, hex = "1eff00" },
    rare =      { r = 0.00, g = 0.44, b = 0.87, hex = "0070dd" },
    epic =      { r = 0.64, g = 0.21, b = 0.93, hex = "a335ee" },
    legendary = { r = 1.00, g = 0.50, b = 0.00, hex = "ff8000" },
    artifact =  { r = 0.90, g = 0.80, b = 0.50, hex = "e6cc80" },
    heirloom =  { r = 0.00, g = 0.80, b = 1.00, hex = "00ccff" },
}

-- Standard Colors
Colors.standard = {
    -- Basic
    white =     { r = 1.00, g = 1.00, b = 1.00, hex = "ffffff" },
    black =     { r = 0.00, g = 0.00, b = 0.00, hex = "000000" },
    red =       { r = 1.00, g = 0.00, b = 0.00, hex = "ff0000" },
    green =     { r = 0.00, g = 1.00, b = 0.00, hex = "00ff00" },
    blue =      { r = 0.00, g = 0.50, b = 1.00, hex = "0080ff" },
    yellow =    { r = 1.00, g = 1.00, b = 0.00, hex = "ffff00" },
    cyan =      { r = 0.00, g = 1.00, b = 1.00, hex = "00ffff" },
    magenta =   { r = 1.00, g = 0.00, b = 1.00, hex = "ff00ff" },
    
    -- Extended
    orange =    { r = 1.00, g = 0.65, b = 0.00, hex = "ffa500" },
    purple =    { r = 0.50, g = 0.00, b = 0.50, hex = "800080" },
    pink =      { r = 1.00, g = 0.41, b = 0.71, hex = "ff69b4" },
    brown =     { r = 0.65, g = 0.41, b = 0.21, hex = "a66836" },
    gray =      { r = 0.50, g = 0.50, b = 0.50, hex = "808080" },
    grey =      { r = 0.50, g = 0.50, b = 0.50, hex = "808080" },
    gold =      { r = 1.00, g = 0.84, b = 0.00, hex = "ffd700" },
    silver =    { r = 0.75, g = 0.75, b = 0.75, hex = "c0c0c0" },
    
    -- Variants
    darkred =   { r = 0.55, g = 0.00, b = 0.00, hex = "8b0000" },
    darkgreen = { r = 0.00, g = 0.39, b = 0.00, hex = "006400" },
    darkblue =  { r = 0.00, g = 0.00, b = 0.55, hex = "00008b" },
    lightblue = { r = 0.68, g = 0.85, b = 0.90, hex = "add8e6" },
    navy =      { r = 0.00, g = 0.00, b = 0.50, hex = "000080" },
    teal =      { r = 0.00, g = 0.50, b = 0.50, hex = "008080" },
    lime =      { r = 0.00, g = 1.00, b = 0.00, hex = "00ff00" },
    olive =     { r = 0.50, g = 0.50, b = 0.00, hex = "808000" },
    maroon =    { r = 0.50, g = 0.00, b = 0.00, hex = "800000" },
    coral =     { r = 1.00, g = 0.50, b = 0.31, hex = "ff7f50" },
    salmon =    { r = 0.98, g = 0.50, b = 0.45, hex = "fa8072" },
    khaki =     { r = 0.94, g = 0.90, b = 0.55, hex = "f0e68c" },
    indigo =    { r = 0.29, g = 0.00, b = 0.51, hex = "4b0082" },
    violet =    { r = 0.93, g = 0.51, b = 0.93, hex = "ee82ee" },
    turquoise = { r = 0.25, g = 0.88, b = 0.82, hex = "40e0d0" },
    lavender =  { r = 0.90, g = 0.90, b = 0.98, hex = "e6e6fa" },
    plum =      { r = 0.87, g = 0.63, b = 0.87, hex = "dda0dd" },
}

-- UI/Theme Colors
Colors.ui = {
    primary =     { r = 0.00, g = 0.64, b = 1.00, hex = "00a2ff" },
    secondary =   { r = 0.30, g = 0.30, b = 0.30, hex = "4d4d4d" },
    success =     { r = 0.00, g = 0.80, b = 0.20, hex = "00cc33" },
    warning =     { r = 1.00, g = 0.80, b = 0.00, hex = "ffcc00" },
    error =       { r = 1.00, g = 0.20, b = 0.20, hex = "ff3333" },
    info =        { r = 0.00, g = 0.64, b = 1.00, hex = "00a2ff" },
    disabled =    { r = 0.50, g = 0.50, b = 0.50, hex = "808080" },
    highlight =   { r = 1.00, g = 1.00, b = 1.00, hex = "ffffff" },
    shadow =      { r = 0.00, g = 0.00, b = 0.00, hex = "000000" },
    backdrop =    { r = 0.10, g = 0.10, b = 0.10, hex = "1a1a1a" },
    border =      { r = 0.30, g = 0.30, b = 0.30, hex = "4d4d4d" },
}

--[[============================================================================
    RETRIEVAL
============================================================================]]

--- Get color table
function Colors:Get(name)
    if type(name) == "table" then
        local r = name.r or name[1]
        local g = name.g or name[2]
        local b = name.b or name[3]
        local a = name.a
        if r and g and b then
            return {
                r = r,
                g = g,
                b = b,
                a = a,
                hex = name.hex or self:RGBToHex(r, g, b),
            }
        end
        return nil
    end

    if type(name) ~= "string" or name == "" then
        return nil
    end

    if name:sub(1, 1) == "#" then
        local r, g, b = self:HexToRGB(name)
        return {
            r = r,
            g = g,
            b = b,
            hex = self:RGBToHex(r, g, b),
        }
    end

    name = name:lower()
    return self.standard[name]
        or self.ui[name]
        or self.quality[name]
        or self.class[name]
end

--- Get RGB values
function Colors:GetRGB(name)
    local color = self:Get(name)
    if color then
        return color.r, color.g, color.b
    end
    return 1, 1, 1
end

--- Get hex string
function Colors:GetHex(name)
    local color = self:Get(name)
    return color and color.hex or "ffffff"
end

--- Get class color
function Colors:GetClass(className)
    className = className:upper()
    local color = self.class[className]
    if color then
        return color.r, color.g, color.b
    end
    return 1, 1, 1
end

--- Get quality color
function Colors:GetQuality(qualityName)
    qualityName = qualityName:lower()
    local color = self.quality[qualityName]
    if color then
        return color.r, color.g, color.b
    end
    return 1, 1, 1
end

--- Wrap text with color code
function Colors:Wrap(text, colorName)
    local hex = self:GetHex(colorName)
    return "|cff" .. hex .. text .. "|r"
end

--- Wrap with class color
function Colors:WrapClass(text, className)
    local hex = self:GetHex(className:lower())
    return "|cff" .. hex .. text .. "|r"
end

--- Wrap with quality color
function Colors:WrapQuality(text, quality)
    local entry = quality and self.quality[quality:lower()]
    local hex = entry and entry.hex or "ffffff"
    return "|cff" .. hex .. text .. "|r"
end

--[[============================================================================
    CONVERSION
============================================================================]]

--- RGB to Hex
function Colors:RGBToHex(r, g, b)
    return string.format("%02x%02x%02x",
        RGX:Clamp(r * 255, 0, 255),
        RGX:Clamp(g * 255, 0, 255),
        RGX:Clamp(b * 255, 0, 255))
end

--- Hex to RGB
function Colors:HexToRGB(hex)
    if type(hex) ~= "string" then
        return 1, 1, 1
    end
    hex = hex:gsub("#", "")
    if #hex ~= 3 and #hex ~= 6 then
        return 1, 1, 1
    end
    if #hex == 3 then
        hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
    end
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return r, g, b
end

--[[============================================================================
    MANIPULATION
============================================================================]]

--- Linear interpolation between two colors
function Colors:Lerp(color1, color2, t)
    local c1 = self:Get(color1) or color1
    local c2 = self:Get(color2) or color2
    
    return {
        r = RGX:Lerp(c1.r, c2.r, t),
        g = RGX:Lerp(c1.g, c2.g, t),
        b = RGX:Lerp(c1.b, c2.b, t),
    }
end

function Colors:Create(r, g, b, a)
    r = RGX:Clamp(tonumber(r) or 1, 0, 1)
    g = RGX:Clamp(tonumber(g) or 1, 0, 1)
    b = RGX:Clamp(tonumber(b) or 1, 0, 1)
    local color = {
        r = r,
        g = g,
        b = b,
        hex = self:RGBToHex(r, g, b),
    }

    if a ~= nil then
        color.a = RGX:Clamp(tonumber(a) or 1, 0, 1)
    end

    return color
end

function Colors:Clone(color)
    local normalized = self:Get(color)
    if not normalized then
        return nil
    end

    return self:Create(normalized.r, normalized.g, normalized.b, normalized.a)
end

--- Darken a color
function Colors:Darken(colorName, amount)
    local color = self:Get(colorName)
    if not color then return 0, 0, 0 end
    
    amount = amount or 0.2
    return RGX:Clamp(color.r - amount, 0, 1),
           RGX:Clamp(color.g - amount, 0, 1),
           RGX:Clamp(color.b - amount, 0, 1)
end

--- Lighten a color
function Colors:Lighten(colorName, amount)
    local color = self:Get(colorName)
    if not color then return 1, 1, 1 end
    
    amount = amount or 0.2
    return RGX:Clamp(color.r + amount, 0, 1),
           RGX:Clamp(color.g + amount, 0, 1),
           RGX:Clamp(color.b + amount, 0, 1)
end

--- Set alpha
function Colors:SetAlpha(colorName, alpha)
    local r, g, b = self:GetRGB(colorName)
    return r, g, b, alpha
end

--[[============================================================================
    UI HELPERS
============================================================================]]

--- Apply color to FontString
function Colors:ApplyText(fontString, colorName)
    if not fontString or not fontString.SetTextColor then return end
    local r, g, b = self:GetRGB(colorName)
    fontString:SetTextColor(r, g, b)
end

--- Apply color to Texture
function Colors:ApplyTexture(texture, colorName)
    if not texture or not texture.SetVertexColor then return end
    local color = self:Get(colorName)
    if not color then return end
    texture:SetVertexColor(color.r, color.g, color.b, color.a or 1)
end

--- Apply color to StatusBar
function Colors:ApplyStatusBar(statusBar, colorName)
    if not statusBar or not statusBar.SetStatusBarColor then return end
    local color = self:Get(colorName) or self:CreatePickerColor(colorName)
    if not color then return end
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)
end

--- Get gradient colors
function Colors:Gradient(percent, lowColor, midColor, highColor)
    if percent < 0.5 then
        return self:Lerp(lowColor, midColor, percent * 2)
    else
        return self:Lerp(midColor, highColor, (percent - 0.5) * 2)
    end
end

--- Health bar color (green -> yellow -> red)
function Colors:Health(percent)
    return self:Gradient(percent, "red", "yellow", "green")
end

--- Power bar color (mana, rage, energy, etc)
Colors.power = {
    mana =      { r = 0.00, g = 0.60, b = 1.00 },
    rage =      { r = 1.00, g = 0.00, b = 0.00 },
    focus =     { r = 1.00, g = 0.50, b = 0.25 },
    energy =    { r = 1.00, g = 1.00, b = 0.00 },
    combo =     { r = 1.00, g = 0.00, b = 0.00 },
    runes =     { r = 0.50, g = 0.50, b = 0.50 },
    runic =     { r = 0.00, g = 0.82, b = 1.00 },
    chi =       { r = 0.71, g = 1.00, b = 0.46 },
    insanity =  { r = 0.40, g = 0.00, b = 0.80 },
    maelstrom = { r = 0.00, g = 0.50, b = 1.00 },
    fury =      { r = 0.79, g = 0.26, b = 0.99 },
    pain =      { r = 1.00, g = 0.30, b = 0.00 },
}

function Colors:GetPower(powerType)
    local power = self.power[powerType:lower()]
    if power then
        return power.r, power.g, power.b
    end
    return 1, 1, 1
end

--[[============================================================================
    COLOR PICKER
============================================================================]]

function Colors:CreatePickerColor(color, alpha)
    local normalized = self:Get(color) or self:Create(1, 1, 1, alpha)
    if alpha ~= nil then
        normalized.a = RGX:Clamp(tonumber(alpha) or 1, 0, 1)
    elseif normalized.a == nil then
        normalized.a = 1
    end

    normalized.hex = self:RGBToHex(normalized.r, normalized.g, normalized.b)
    return normalized
end

function Colors:_ReadPickerColor(hasOpacity)
    local r, g, b = 1, 1, 1
    if ColorPickerFrame and type(ColorPickerFrame.GetColorRGB) == "function" then
        r, g, b = ColorPickerFrame:GetColorRGB()
    end

    local a = 1
    if hasOpacity then
        local opacity = nil
        if OpacitySliderFrame and type(OpacitySliderFrame.GetValue) == "function" then
            opacity = OpacitySliderFrame:GetValue()
        elseif ColorPickerFrame and type(ColorPickerFrame.GetColorAlpha) == "function" then
            opacity = ColorPickerFrame:GetColorAlpha()
        elseif ColorPickerFrame then
            opacity = ColorPickerFrame.opacity
        end

        if opacity ~= nil then
            a = 1 - opacity
        end
    end

    return self:CreatePickerColor({ r = r, g = g, b = b, a = a })
end

function Colors:OpenPicker(options)
    if type(options) ~= "table" then
        options = { color = options }
    end

    if not ColorPickerFrame then
        RGX:Debug("Colors: Blizzard ColorPickerFrame is unavailable")
        return false
    end

    local initial = self:CreatePickerColor(
        options.color or options.name or options.hex,
        options.a or options.alpha
    )
    local hasOpacity = options.hasOpacity == true or initial.a ~= nil
    local onChanged = options.onChanged or options.callback
    local onCancel = options.onCancel
    local function emit(color, cancelled)
        if type(onChanged) == "function" then
            onChanged(color, color.r, color.g, color.b, color.a, cancelled == true)
        end
    end

    local function swatchFunc()
        emit(self:_ReadPickerColor(hasOpacity), false)
    end

    local function cancelFunc(previousValues)
        local restored = self:CreatePickerColor({
            r = previousValues and previousValues.r or initial.r,
            g = previousValues and previousValues.g or initial.g,
            b = previousValues and previousValues.b or initial.b,
            a = previousValues and previousValues.a or initial.a,
        })
        emit(restored, true)
        if type(onCancel) == "function" then
            onCancel(restored, restored.r, restored.g, restored.b, restored.a)
        end
    end

    if type(ColorPickerFrame.SetupColorPickerAndShow) == "function" then
        local info = {
            r = initial.r,
            g = initial.g,
            b = initial.b,
            opacity = 1 - (initial.a or 1),
            hasOpacity = hasOpacity,
            swatchFunc = swatchFunc,
            opacityFunc = swatchFunc,
            cancelFunc = cancelFunc,
        }

        if type(options.extraInfo) == "table" then
            for key, value in pairs(options.extraInfo) do
                info[key] = value
            end
        end

        ColorPickerFrame:SetupColorPickerAndShow(info)
        return true
    end

    ColorPickerFrame.hasOpacity = hasOpacity
    ColorPickerFrame.opacity = 1 - (initial.a or 1)
    ColorPickerFrame.previousValues = {
        r = initial.r,
        g = initial.g,
        b = initial.b,
        a = initial.a,
    }
    ColorPickerFrame.func = swatchFunc
    ColorPickerFrame.opacityFunc = swatchFunc
    ColorPickerFrame.cancelFunc = cancelFunc
    ColorPickerFrame:SetColorRGB(initial.r, initial.g, initial.b)
    ColorPickerFrame:Show()
    return true
end

function Colors:CreateColorPicker(parent, options)
    if type(options) ~= "table" then
        options = {
            label = tostring(options or "Color"),
        }
    end

    local frame = CreateFrame("Frame", options.name, parent)
    frame:SetSize(options.width or 170, options.height or 22)

    local label = frame:CreateFontString(nil, "OVERLAY", options.labelFont or "GameFontNormal")
    label:SetPoint("LEFT", frame, "LEFT", 0, 0)
    label:SetJustifyH("LEFT")
    label:SetText(options.label or "Color")
    frame.label = label

    local swatch = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    swatch:SetSize(options.swatchWidth or 22, options.swatchHeight or 22)
    swatch:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
    swatch:SetText("")
    frame.swatch = swatch

    local border = swatch:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints()
    border:SetColorTexture(0, 0, 0, 0.75)
    swatch.border = border

    local preview = swatch:CreateTexture(nil, "ARTWORK")
    preview:SetPoint("TOPLEFT", swatch, "TOPLEFT", 2, -2)
    preview:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -2, 2)
    swatch.preview = preview

    function frame:SetColor(color, alpha)
        local value = Colors:CreatePickerColor(color, alpha)
        self.color = value
        self.swatch.preview:SetColorTexture(value.r, value.g, value.b, value.a or 1)
    end

    function frame:GetColor()
        return Colors:Clone(self.color)
    end

    frame:SetColor(options.color or options.name or options.hex, options.a or options.alpha)

    swatch:SetScript("OnClick", function()
        Colors:OpenPicker({
            color = frame.color,
            hasOpacity = options.hasOpacity,
            onChanged = function(color, r, g, b, a, cancelled)
                frame:SetColor(color)
                if type(options.onChanged) == "function" then
                    options.onChanged(frame, color, r, g, b, a, cancelled)
                end
            end,
            onCancel = function(color, r, g, b, a)
                frame:SetColor(color)
                if type(options.onCancel) == "function" then
                    options.onCancel(frame, color, r, g, b, a)
                end
            end,
            onConfirm = function(color, r, g, b, a)
                if type(options.onConfirm) == "function" then
                    options.onConfirm(frame, color, r, g, b, a)
                end
            end,
        })
    end)

    return frame
end

function Colors:CreateColorSettingControl(parent, options)
    if type(options) ~= "table" then
        options = {
            label = tostring(options or "Color"),
        }
    end

    local frame = CreateFrame("Frame", options.name, parent)
    frame:SetSize(options.width or 210, options.height or 22)

    local resetWidth = options.showReset == false and 0 or (options.resetWidth or 22)
    local pickerWidth = (options.width or 210) - resetWidth - (resetWidth > 0 and 6 or 0)

    local picker = self:CreateColorPicker(frame, {
        label = options.label or "Color",
        labelFont = options.labelFont or "GameFontNormal",
        width = pickerWidth,
        height = options.height or 22,
        swatchWidth = options.swatchWidth or 22,
        swatchHeight = options.swatchHeight or 22,
        hasOpacity = options.hasOpacity,
    })
    picker:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.picker = picker

    local reset = nil
    if resetWidth > 0 then
        reset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        reset:SetSize(resetWidth, options.resetHeight or 22)
        reset:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
        reset:SetText(options.resetText or "R")
        frame.reset = reset
    end

    local storage = options.storage
    local key = options.key
    local defaultColor = self:CreatePickerColor(
        options.defaultColor or options.default or options.color or options.name or options.hex,
        options.defaultAlpha or options.alpha
    )

    local function StoreColor(color)
        if storage and key then
            storage[key] = Colors:Clone(color)
        end
    end

    local function ResolveInitialColor()
        if storage and key and storage[key] ~= nil then
            return storage[key]
        end
        return options.color or options.name or options.hex or defaultColor
    end

    function frame:SetColor(color, alpha)
        local normalized = Colors:CreatePickerColor(color, alpha)
        self.color = normalized
        picker:SetColor(normalized)
        StoreColor(normalized)
    end

    function frame:GetColor()
        return Colors:Clone(self.color)
    end

    function frame:GetDefaultColor()
        return Colors:Clone(defaultColor)
    end

    function frame:SetEnabled(enabled)
        local isEnabled = enabled ~= false
        picker.swatch:SetEnabled(isEnabled)
        picker.swatch:SetAlpha(isEnabled and 1 or 0.45)
        picker.label:SetAlpha(isEnabled and 1 or 0.6)
        if reset then
            reset:SetEnabled(isEnabled)
            reset:SetAlpha(isEnabled and 1 or 0.45)
        end
    end

    function frame:Reset()
        self:SetColor(defaultColor)
        if type(options.onReset) == "function" then
            options.onReset(self, self:GetColor())
        end
        if type(options.onChanged) == "function" then
            local color = self:GetColor()
            options.onChanged(self, color, color.r, color.g, color.b, color.a, false)
        end
    end

    frame:SetColor(ResolveInitialColor(), options.alpha)

    picker.swatch:SetScript("OnClick", function()
        Colors:OpenPicker({
            color = frame.color,
            hasOpacity = options.hasOpacity,
            onChanged = function(color, r, g, b, a, cancelled)
                frame.color = Colors:CreatePickerColor(color)
                picker:SetColor(frame.color)
                StoreColor(frame.color)
                if type(options.onChanged) == "function" then
                    options.onChanged(frame, frame.color, r, g, b, a, cancelled)
                end
            end,
            onCancel = function(color, r, g, b, a)
                frame.color = Colors:CreatePickerColor(color)
                picker:SetColor(frame.color)
                StoreColor(frame.color)
                if type(options.onCancel) == "function" then
                    options.onCancel(frame, frame.color, r, g, b, a)
                end
            end,
        })
    end)

    if reset then
        reset:SetScript("OnClick", function()
            frame:Reset()
        end)
    end

    return frame
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function Colors:Init()
    RGX:RegisterModule("colors", self)
    _G.RGXColors = self
    RGX:Debug("Colors: Initialized")
end

Colors:Init()
