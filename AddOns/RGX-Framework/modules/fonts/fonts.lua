--[[
    RGX-Framework - Fonts Module
    
    Simple font management for WoW addons.
    
    For Addon Developers:
        1. Add ## RequiredDeps: RGX-Framework to your .toc
        2. Get fonts: local Fonts = RGX:GetModule("fonts")
        3. Use fonts: local path = Fonts:GetPath("Inter-Regular")
    
    API:
        Fonts:GetPath(name)          - Get font file path
        Fonts:Get(name, size, flags) - Get path, size, flags
        Fonts:GetFont(name)          - Get Font object
        Fonts:Apply(fontString, name, size, flags) - Apply to FontString
        Fonts:List()                 - Get all fonts
        Fonts:ListAvailable()        - Get only available fonts
        Fonts:Register(name, path, info) - Add custom font
        Fonts:SetDefault(name)       - Set default font
        Fonts:GetDefault()           - Get default font name
    
    Quick Apply:
        Fonts:Quick(textObject, "Inter-Bold", 14, "OUTLINE")
        Fonts:Quick(textObject, "default")  -- Uses default font
--]]

local _, Fonts = ...
local RGX = _G.RGXFramework
local Dropdowns = _G.RGXDropdowns

if not RGX then
    error("RGX Fonts: RGX-Framework not loaded")
    return
end

Fonts.name = "fonts"
Fonts.version = "1.0.0"

-- Storage
Fonts.registry = {}
Fonts.objects = {}
Fonts.categories = {}

-- Settings
Fonts.default = nil
Fonts.defaultSize = 12
Fonts.defaultFlags = ""
Fonts.autoScale = true
Fonts.previewSample = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus posuere, sapien ut gravida feugiat, augue turpis placerat velit, sed porta dui justo eget lorem."
Fonts._widgetId = 0
Fonts.flagPresets = {
    { value = "", label = "Normal" },
    { value = "OUTLINE", label = "Outline" },
    { value = "THICKOUTLINE", label = "Thick Outline" },
    { value = "MONOCHROME", label = "Monochrome" },
    { value = "OUTLINE,MONOCHROME", label = "Outline Monochrome" },
    { value = "THICKOUTLINE,MONOCHROME", label = "Thick Monochrome" },
}

-- Font base path
Fonts.fontPath = "Interface/AddOns/RGX-Framework/media/fonts/"

-- Font definitions - ACTUAL fonts we have in media/fonts/
Fonts.definitions = {
    -- Inter (OFL 1.1) - https://rsms.me/inter/
    ["Inter-Regular"] = {
        file = "Inter-Regular.otf",
        family = "Inter",
        category = "Sans-serif",
        license = "OFL 1.1",
    },
    ["Inter-Bold"] = {
        file = "Inter-Bold.otf",
        family = "Inter",
        category = "Sans-serif",
        license = "OFL 1.1",
    },

    -- Crimson Text (OFL 1.1) - https://fonts.google.com/specimen/Crimson+Text
    ["CrimsonText-Regular"] = {
        file = "CrimsonText-Regular.ttf",
        family = "Crimson Text",
        category = "Serif",
        license = "OFL 1.1",
    },

    -- Press Start 2P (OFL 1.1) - https://fonts.google.com/specimen/Press+Start+2P
    ["PressStart2P-Regular"] = {
        file = "PressStart2P-Regular.ttf",
        family = "Press Start 2P",
        category = "Pixel",
        license = "OFL 1.1",
    },

    -- VT323 (OFL 1.1) - https://fonts.google.com/specimen/VT323
    ["VT323-Regular"] = {
        file = "VT323-Regular.ttf",
        family = "VT323",
        category = "Pixel",
        license = "OFL 1.1",
    },
    
    -- DejaVu (Public Domain) - https://dejavu-fonts.github.io/
    ["DejaVuSans"] = {
        file = "DejaVuSans.ttf",
        family = "DejaVu Sans",
        category = "Sans-serif",
        license = "Public Domain",
    },
    ["DejaVuSans-Bold"] = {
        file = "DejaVuSans-Bold.ttf",
        family = "DejaVu Sans",
        category = "Sans-serif",
        license = "Public Domain",
    },
    ["DejaVuSansCondensed"] = {
        file = "DejaVuSansCondensed.ttf",
        family = "DejaVu Sans Condensed",
        category = "Sans-serif",
        license = "Public Domain",
    },
    ["DejaVuSansCondensed-Bold"] = {
        file = "DejaVuSansCondensed-Bold.ttf",
        family = "DejaVu Sans Condensed",
        category = "Sans-serif",
        license = "Public Domain",
    },
    
    -- Liberation (OFL 1.1) - https://github.com/liberationfonts
    ["LiberationSans-Regular"] = {
        file = "LiberationSans-Regular.ttf",
        family = "Liberation Sans",
        category = "Sans-serif",
        license = "OFL 1.1",
    },
    ["LiberationSans-Bold"] = {
        file = "LiberationSans-Bold.ttf",
        family = "Liberation Sans",
        category = "Sans-serif",
        license = "OFL 1.1",
    },
    ["LiberationSans-Italic"] = {
        file = "LiberationSans-Italic.ttf",
        family = "Liberation Sans",
        category = "Sans-serif",
        license = "OFL 1.1",
    },
    ["LiberationSans-BoldItalic"] = {
        file = "LiberationSans-BoldItalic.ttf",
        family = "Liberation Sans",
        category = "Sans-serif",
        license = "OFL 1.1",
    },
    
    -- Ubuntu Font Family (Ubuntu Font License) - https://design.ubuntu.com/font
    ["Ubuntu-Regular"] = {
        file = "Ubuntu-Regular.ttf",
        family = "Ubuntu",
        category = "Sans-serif",
        license = "Ubuntu Font License",
    },
    ["Ubuntu-Bold"] = {
        file = "Ubuntu-Bold.ttf",
        family = "Ubuntu",
        category = "Sans-serif",
        license = "Ubuntu Font License",
    },

    -- Lato (OFL 1.1) - https://fonts.google.com/specimen/Lato
    ["Lato-Regular"] = {
        file = "Lato-Regular.ttf",
        family = "Lato",
        category = "Sans-serif",
        license = "OFL 1.1",
    },
    ["Lato-Bold"] = {
        file = "Lato-Bold.ttf",
        family = "Lato",
        category = "Sans-serif",
        license = "OFL 1.1",
    },

    -- Poppins (OFL 1.1) - https://fonts.google.com/specimen/Poppins
    ["Poppins-Regular"] = {
        file = "Poppins-Regular.ttf",
        family = "Poppins",
        category = "Sans-serif",
        license = "OFL 1.1",
    },
    ["Poppins-Bold"] = {
        file = "Poppins-Bold.ttf",
        family = "Poppins",
        category = "Sans-serif",
        license = "OFL 1.1",
    },

    -- Montserrat (OFL 1.1) - https://fonts.google.com/specimen/Montserrat
    ["Montserrat-Regular"] = {
        file = "Montserrat-Regular.ttf",
        family = "Montserrat",
        category = "Sans-serif",
        license = "OFL 1.1",
    },
    ["Montserrat-Bold"] = {
        file = "Montserrat-Bold.ttf",
        family = "Montserrat",
        category = "Sans-serif",
        license = "OFL 1.1",
    },

    -- Oswald (OFL 1.1) - https://fonts.google.com/specimen/Oswald
    ["Oswald-Regular"] = {
        file = "Oswald-Regular.ttf",
        family = "Oswald",
        category = "Display",
        license = "OFL 1.1",
    },

    -- Rajdhani (OFL 1.1) - https://fonts.google.com/specimen/Rajdhani
    ["Rajdhani-Regular"] = {
        file = "Rajdhani-Regular.ttf",
        family = "Rajdhani",
        category = "Sans-serif",
        license = "OFL 1.1",
    },
    ["Rajdhani-Bold"] = {
        file = "Rajdhani-Bold.ttf",
        family = "Rajdhani",
        category = "Sans-serif",
        license = "OFL 1.1",
    },

    -- IBM Plex Mono (OFL 1.1) - https://fonts.google.com/specimen/IBM+Plex+Mono
    ["IBMPlexMono-Regular"] = {
        file = "IBMPlexMono-Regular.ttf",
        family = "IBM Plex Mono",
        category = "Monospace",
        license = "OFL 1.1",
    },

    -- JetBrains Mono (OFL 1.1) - https://www.jetbrains.com/lp/mono/
    ["JetBrainsMono-Regular"] = {
        file = "JetBrainsMono-Regular.ttf",
        family = "JetBrains Mono",
        category = "Monospace",
        license = "OFL 1.1",
    },
    ["JetBrainsMono-Bold"] = {
        file = "JetBrainsMono-Bold.ttf",
        family = "JetBrains Mono",
        category = "Monospace",
        license = "OFL 1.1",
    },

    -- Merriweather (OFL 1.1) - https://fonts.google.com/specimen/Merriweather
    ["Merriweather-Regular"] = {
        file = "Merriweather-Regular.ttf",
        family = "Merriweather",
        category = "Serif",
        license = "OFL 1.1",
    },
    ["Merriweather-Bold"] = {
        file = "Merriweather-Bold.ttf",
        family = "Merriweather",
        category = "Serif",
        license = "OFL 1.1",
    },

    -- Playfair Display (OFL 1.1) - https://fonts.google.com/specimen/Playfair+Display
    ["PlayfairDisplay-Regular"] = {
        file = "PlayfairDisplay-Regular.ttf",
        family = "Playfair Display",
        category = "Serif",
        license = "OFL 1.1",
    },
    ["PlayfairDisplay-Bold"] = {
        file = "PlayfairDisplay-Bold.ttf",
        family = "Playfair Display",
        category = "Serif",
        license = "OFL 1.1",
    },

    -- Bebas Neue (OFL 1.1) - https://fonts.google.com/specimen/Bebas+Neue
    ["BebasNeue-Regular"] = {
        file = "BebasNeue-Regular.ttf",
        family = "Bebas Neue",
        category = "Display",
        license = "OFL 1.1",
    },

    -- Bangers (OFL 1.1) - https://fonts.google.com/specimen/Bangers
    ["Bangers-Regular"] = {
        file = "Bangers-Regular.ttf",
        family = "Bangers",
        category = "Display",
        license = "OFL 1.1",
    },

    -- Creepster (OFL 1.1) - https://fonts.google.com/specimen/Creepster
    ["Creepster-Regular"] = {
        file = "Creepster-Regular.ttf",
        family = "Creepster",
        category = "Display",
        license = "OFL 1.1",
    },

    -- Orbitron (OFL 1.1) - https://fonts.google.com/specimen/Orbitron
    ["Orbitron-Regular"] = {
        file = "Orbitron-Regular.ttf",
        family = "Orbitron",
        category = "Display",
        license = "OFL 1.1",
    },

    -- Audiowide (OFL 1.1) - https://fonts.google.com/specimen/Audiowide
    ["Audiowide-Regular"] = {
        file = "Audiowide-Regular.ttf",
        family = "Audiowide",
        category = "Display",
        license = "OFL 1.1",
    },

    -- Anton (OFL 1.1) - https://fonts.google.com/specimen/Anton
    ["Anton-Regular"] = {
        file = "Anton-Regular.ttf",
        family = "Anton",
        category = "Display",
        license = "OFL 1.1",
    },

    -- Silkscreen (OFL 1.1) - https://fonts.google.com/specimen/Silkscreen
    ["Silkscreen-Regular"] = {
        file = "Silkscreen-Regular.ttf",
        family = "Silkscreen",
        category = "Pixel",
        license = "OFL 1.1",
    },

    -- Uncial Antiqua (OFL 1.1) - https://fonts.google.com/specimen/Uncial+Antiqua
    ["UncialAntiqua-Regular"] = {
        file = "UncialAntiqua-Regular.ttf",
        family = "Uncial Antiqua",
        category = "Fantasy",
        license = "OFL 1.1",
    },

    -- Cinzel (OFL 1.1) - https://fonts.google.com/specimen/Cinzel
    ["Cinzel-Regular"] = {
        file = "Cinzel-Regular.ttf",
        family = "Cinzel",
        category = "Fantasy",
        license = "OFL 1.1",
    },
}

--[[============================================================================
    REGISTRATION
============================================================================]]

function Fonts:Register(name, path, info)
    if type(name) ~= "string" or name == "" then
        RGX:Debug("Fonts: Invalid font name")
        return nil
    end
    
    if self.registry[name] then
        return self.registry[name]
    end

    info = info or {}

    self.registry[name] = {
        path = path,
        name = info.displayName or name,
        family = info.family or name,
        category = info.category or "Sans-serif",
        license = info.license or "Unknown",
        available = info.available,
        isCustom = info.isCustom or false
    }

    self.categories[info.category or "Sans-serif"] = true

    RGX:Debug("Fonts: Registered", name)
    return self.registry[name]
end

function Fonts:RegisterAddonFont(addonName, fontName, fontFile, info)
    info = info or {}
    info.isCustom = true
    info.addon = addonName
    
    local path = string.format("Interface/AddOns/%s/fonts/%s", addonName, fontFile)
    return self:Register(fontName, path, info)
end

function Fonts:RegisterFontPack(addonName, definitions)
    if type(addonName) ~= "string" or addonName == "" then
        RGX:Debug("Fonts: Invalid font pack addon name")
        return 0
    end

    if type(definitions) ~= "table" then
        RGX:Debug("Fonts: Invalid font pack definitions")
        return 0
    end

    local registered = 0

    for fontName, def in pairs(definitions) do
        if type(fontName) == "string" and type(def) == "table" and type(def.file) == "string" then
            self:RegisterAddonFont(addonName, fontName, def.file, {
                displayName = def.displayName or def.family or fontName,
                family = def.family or fontName,
                category = def.category or "Sans-serif",
                license = def.license or "Unknown",
                available = def.available,
            })
            registered = registered + 1
        end
    end

    RGX:Debug("Fonts: Registered font pack", addonName, registered)
    return registered
end

function Fonts:RegisterBuiltInFonts()
    self:Register("FrizQuadrata", "Fonts/FRIZQT__.TTF", {
        displayName = "Friz Quadrata",
        family = "Friz Quadrata",
        category = "WoW Defaults",
        license = "Blizzard Built-in",
        available = true,
    })
    self:Register("ArialNarrow", "Fonts/ARIALN.TTF", {
        displayName = "Arial Narrow",
        family = "Arial Narrow",
        category = "WoW Defaults",
        license = "Blizzard Built-in",
        available = true,
    })
    self:Register("Morpheus", "Fonts/MORPHEUS.TTF", {
        displayName = "Morpheus",
        family = "Morpheus",
        category = "WoW Defaults",
        license = "Blizzard Built-in",
        available = true,
    })
    self:Register("Skurri", "Fonts/SKURRI.TTF", {
        displayName = "Skurri",
        family = "Skurri",
        category = "WoW Defaults",
        license = "Blizzard Built-in",
        available = true,
    })
end

--[[============================================================================
    RETRIEVAL
============================================================================]]

function Fonts:Exists(name)
    return self.registry[name] ~= nil
end

function Fonts:GetInfo(name)
    return self.registry[name]
end

function Fonts:IsAvailable(name)
    local font = self.registry[name]
    if not font then return false end
    if font.available == nil then
        local testFont = CreateFont("RGX_Test_" .. name:gsub("[^%w]", "_"))
        font.available = pcall(function()
            testFont:SetFont(font.path, 12, "")
        end)
    end
    return font.available
end

function Fonts:GetPath(name)
    name = name or self.default
    
    local font = self.registry[name]
    if font and self:IsAvailable(name) then
        return font.path
    end

    -- Fall back to default
    if name ~= self.default and self.default then
        return self:GetPath(self.default)
    end

    -- Ultimate fallback
    return "Fonts/FRIZQT__.TTF"
end

function Fonts:Get(name, size, flags)
    local path = self:GetPath(name)
    local s = size or self.defaultSize
    local f = flags or self.defaultFlags
    
    if self.autoScale then
        s = s * UIParent:GetEffectiveScale()
    end
    
    return path, s, f
end

function Fonts:GetFont(name, size, flags)
    name = name or self.default
    
    if not self:Exists(name) then
        return nil
    end

    if not size and not flags then
        if not self.objects[name] then
            local path = self:GetPath(name)
            local obj = CreateFont("RGX_Font_" .. name:gsub("[^%w]", "_"))
            obj:SetFont(path, self.defaultSize, self.defaultFlags)
            self.objects[name] = obj
        end
        return self.objects[name]
    end

    local path = self:GetPath(name)
    local tempName = string.format("RGX_Font_%s_%d_%s", 
        name:gsub("[^%w]", "_"), 
        size or 0, 
        flags or "")
    
    local temp = _G[tempName]
    if not temp then
        temp = CreateFont(tempName)
        temp:SetFont(path, size or self.defaultSize, flags or self.defaultFlags)
    end
    
    return temp
end

--[[============================================================================
    APPLICATION
============================================================================]]

function Fonts:Apply(fontString, name, size, flags)
    if not fontString or not fontString.SetFont then
        return false
    end

    local path, s, f = self:Get(name, size, flags)
    if type(path) ~= "string" or path == "" then
        path = "Fonts/FRIZQT__.TTF"
    end
    if not s or s <= 0 then
        s = self.defaultSize or 12
    end
    fontString:SetFont(path, s, f or "")
    return true
end

function Fonts:Quick(fontString, name, size, flags)
    if not fontString then return false end
    
    name = name or self.default
    
    -- Handle keywords
    if name == "default" or name == "normal" then
        name = self.default
    elseif name == "header" then
        size = size or 16
        flags = flags or "OUTLINE"
        name = self.default
    elseif name == "title" then
        size = size or 18
        flags = flags or "OUTLINE"
        name = self.default
    elseif name == "small" then
        size = size or 10
        name = self.default
    end
    
    return self:Apply(fontString, name, size, flags)
end

function Fonts:ApplyChildren(frame, name, size, flags)
    if not frame then return end
    
    local regions = {frame:GetRegions()}
    for _, region in ipairs(regions) do
        if region.SetFont then
            self:Apply(region, name, size, flags)
        end
    end
    
    for _, child in ipairs({frame:GetChildren()}) do
        self:ApplyChildren(child, name, size, flags)
    end
end

--[[============================================================================
    LISTING
============================================================================]]

function Fonts:List()
    local list = {}
    for name, data in pairs(self.registry) do
        table.insert(list, {
            name = name,
            displayName = data.name,
            family = data.family,
            category = data.category,
            path = data.path,
            available = data.available,
            isCustom = data.isCustom
        })
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

function Fonts:ListAvailable()
    local list = {}
    for name, data in pairs(self.registry) do
        if self:IsAvailable(name) then
            table.insert(list, {
                name = name,
                displayName = data.name,
                family = data.family,
                category = data.category,
                path = data.path,
                isCustom = data.isCustom
            })
        end
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

function Fonts:ListByCategory(category)
    local list = {}
    for name, data in pairs(self.registry) do
        if data.category == category then
            table.insert(list, name)
        end
    end
    table.sort(list)
    return list
end

function Fonts:GetCategories()
    local cats = {}
    for cat in pairs(self.categories) do
        table.insert(cats, cat)
    end
    table.sort(cats)
    return cats
end

function Fonts:GetFamilies()
    local map = {}
    for _, data in pairs(self.registry) do
        map[data.family or data.name] = true
    end

    local list = {}
    for family in pairs(map) do
        table.insert(list, family)
    end
    table.sort(list)
    return list
end

--[[============================================================================
    DEFAULTS
============================================================================]]

function Fonts:SetDefault(name)
    if not self:Exists(name) then
        RGX:Debug("Fonts: Cannot set default - font not found:", name)
        return false
    end
    if not self:IsAvailable(name) then
        RGX:Debug("Fonts: Cannot set default - font unavailable:", name)
        return false
    end
    self.default = name
    return true
end

function Fonts:GetDefault()
    return self.default
end

function Fonts:SetDefaultSize(size)
    self.defaultSize = size
end

function Fonts:SetDefaultFlags(flags)
    self.defaultFlags = self:NormalizeFlags(flags)
end

function Fonts:SetAutoScale(enable)
    self.autoScale = enable
end

--[[============================================================================
    FONT CREATION HELPERS
============================================================================]]

function Fonts:CreateString(parent, fontName, size, flags, layer)
    parent = parent or UIParent
    layer = layer or "OVERLAY"
    
    local fs = parent:CreateFontString(nil, layer)
    self:Quick(fs, fontName, size, flags)
    
    return fs
end

function Fonts:SplitFlags(flags)
    if type(flags) ~= "string" or flags == "" then
        return {}
    end

    local map = {}
    for token in string.gmatch(flags, "([^,]+)") do
        local normalized = strtrim(token):upper()
        if normalized ~= "" then
            map[normalized] = true
        end
    end
    return map
end

function Fonts:NormalizeFlags(flags)
    if type(flags) == "table" then
        local tokens = {}
        local hasThick = flags.thickOutline or flags.thickoutline or flags.THICKOUTLINE
        local hasOutline = flags.outline or flags.OUTLINE
        local hasMono = flags.monochrome or flags.MONOCHROME

        if hasThick then
            table.insert(tokens, "THICKOUTLINE")
        elseif hasOutline then
            table.insert(tokens, "OUTLINE")
        end

        if hasMono then
            table.insert(tokens, "MONOCHROME")
        end

        return table.concat(tokens, ",")
    end

    local map = self:SplitFlags(flags)
    local tokens = {}

    if map.THICKOUTLINE then
        table.insert(tokens, "THICKOUTLINE")
    elseif map.OUTLINE then
        table.insert(tokens, "OUTLINE")
    end

    if map.MONOCHROME then
        table.insert(tokens, "MONOCHROME")
    end

    return table.concat(tokens, ",")
end

function Fonts:DescribeFlags(flags)
    local normalized = self:NormalizeFlags(flags)
    for _, preset in ipairs(self.flagPresets) do
        if preset.value == normalized then
            return preset.label
        end
    end
    return normalized ~= "" and normalized or "Normal"
end

function Fonts:GetFlagPresets()
    local list = {}
    for _, preset in ipairs(self.flagPresets) do
        table.insert(list, RGX:CopyTable(preset))
    end
    return list
end

function Fonts:NormalizeColorValue(color, fallback)
    local Colors = _G.RGXColors
    local source = color

    if source == nil or source == "" then
        source = fallback
    end

    if source == nil or source == "" then
        return nil
    end

    if Colors and type(Colors.Get) == "function" then
        local normalized = Colors:Get(source)
        if normalized then
            return {
                r = normalized.r,
                g = normalized.g,
                b = normalized.b,
                a = normalized.a,
                hex = normalized.hex,
            }
        end
    end

    if type(source) == "table" then
        local r = tonumber(source.r or source[1])
        local g = tonumber(source.g or source[2])
        local b = tonumber(source.b or source[3])
        local a = source.a ~= nil and RGX:Clamp(tonumber(source.a) or 1, 0, 1) or nil

        if r and g and b then
            return {
                r = RGX:Clamp(r, 0, 1),
                g = RGX:Clamp(g, 0, 1),
                b = RGX:Clamp(b, 0, 1),
                a = a,
            }
        end
    end

    return nil
end

function Fonts:NormalizeShadowOffset(offset, fallbackX, fallbackY)
    local x
    local y

    if type(offset) == "table" then
        x = offset.x or offset[1]
        y = offset.y or offset[2]
    elseif type(offset) == "number" then
        x = offset
        y = -offset
    end

    x = tonumber(x)
    y = tonumber(y)

    if x == nil then
        x = fallbackX or 0
    end
    if y == nil then
        y = fallbackY or 0
    end

    return math.floor(x + 0.5), math.floor(y + 0.5)
end

function Fonts:NormalizeJustify(value, fallback, isVertical)
    if type(value) ~= "string" or value == "" then
        return fallback
    end

    value = value:upper()
    if isVertical then
        if value == "TOP" or value == "MIDDLE" or value == "BOTTOM" then
            return value
        end
    else
        if value == "LEFT" or value == "CENTER" or value == "RIGHT" then
            return value
        end
    end

    return fallback
end

function Fonts:_GetPreviewSample(fontInfo)
    local family = fontInfo and (fontInfo.family or fontInfo.displayName or fontInfo.name) or "RGX Font"
    return string.format(
        "%s\n\n%s\n\n0123456789  ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz",
        family,
        self.previewSample
    )
end

function Fonts:_ApplyPreviewSelection(frame, fontName)
    if not frame or not frame.fontButtons then
        return
    end

    local entry = self.registry[fontName]
    if not entry then
        return
    end

    frame.selectedFont = fontName

    local size = math.floor(frame.sizeSlider:GetValue() + 0.5)
    local flags = self:NormalizeFlags(frame.flagsValue)
    local previewPath = self:GetPath(fontName)

    frame.previewTitle:SetFont(previewPath, size + 10, flags)
    frame.previewTitle:SetText(entry.family or entry.name or fontName)

    frame.previewMeta:SetFont(previewPath, math.max(11, size - 1), flags)
    frame.previewMeta:SetText(string.format(
        "%s\nCategory: %s\nStyle: %s\nFile: %s",
        fontName,
        entry.category or "Unknown",
        self:DescribeFlags(flags),
        entry.path or "Unknown"
    ))

    frame.previewBody:SetFont(previewPath, size, flags)
    frame.previewBody:SetText(self:_GetPreviewSample(entry))

    frame.currentFontLabel:SetText(fontName)
    frame.currentSizeLabel:SetText(string.format("%d pt", size))
    frame.currentStyleLabel:SetText(self:DescribeFlags(flags))

    for _, button in ipairs(frame.fontButtons) do
        local selected = button.fontName == fontName
        button:SetNormalFontObject(selected and "GameFontHighlight" or "GameFontNormal")
        if button.bg then
            button.bg:SetColorTexture(
                selected and 0.18 or 0.08,
                selected and 0.34 or 0.08,
                selected and 0.52 or 0.08,
                selected and 0.95 or 0.75
            )
        end
    end
end

function Fonts:_CreatePreviewFontButton(parent, fontInfo, index, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(180, 22)
    button:SetPoint("TOPLEFT", 0, -((index - 1) * 24))
    button.fontName = fontInfo.name

    button.bg = button:CreateTexture(nil, "BACKGROUND")
    button.bg:SetAllPoints()
    button.bg:SetColorTexture(0.08, 0.08, 0.08, 0.75)

    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.text:SetPoint("LEFT", 8, 0)
    button.text:SetPoint("RIGHT", -8, 0)
    button.text:SetJustifyH("LEFT")
    button.text:SetText(fontInfo.name)
    self:Apply(button.text, fontInfo.name, 12, "")

    button:SetScript("OnClick", function()
        onClick(fontInfo.name)
    end)

    return button
end

function Fonts:_BuildPreviewButtons(frame)
    if not frame or not frame.fontListContent then
        return
    end

    if frame.fontButtons then
        for _, button in ipairs(frame.fontButtons) do
            button:Hide()
        end
    end

    frame.fontButtons = {}

    local search = ""
    if frame.searchBox and type(frame.searchBox.GetText) == "function" then
        search = string.lower(strtrim(frame.searchBox:GetText() or ""))
    end

    local fonts = self:ListAvailable()
    local visible = {}
    for _, fontInfo in ipairs(fonts) do
        local haystack = string.lower(string.format("%s %s %s",
            fontInfo.name or "",
            fontInfo.family or "",
            fontInfo.category or ""
        ))
        if search == "" or string.find(haystack, search, 1, true) then
            table.insert(visible, fontInfo)
        end
    end

    for index, fontInfo in ipairs(visible) do
        local button = self:_CreatePreviewFontButton(frame.fontListContent, fontInfo, index, function(fontName)
            self:_ApplyPreviewSelection(frame, fontName)
        end)
        frame.fontButtons[index] = button
    end

    local contentHeight = math.max(1, #visible * 24)
    frame.fontListContent:SetHeight(contentHeight)
    frame.noResults:Hide()

    if #visible == 0 then
        frame.noResults:Show()
        contentHeight = 24
        frame.fontListContent:SetHeight(contentHeight)
    end

    if not frame.selectedFont or not self:Exists(frame.selectedFont) then
        frame.selectedFont = self:GetDefault()
    end

    local stillVisible = false
    for _, fontInfo in ipairs(visible) do
        if fontInfo.name == frame.selectedFont then
            stillVisible = true
            break
        end
    end

    if stillVisible then
        self:_ApplyPreviewSelection(frame, frame.selectedFont)
    elseif visible[1] then
        self:_ApplyPreviewSelection(frame, visible[1].name)
    end
end

function Fonts:GetCategoryLabel(category)
    local labels = {
        ["Sans-serif"] = "Sans / UI",
        ["Serif"] = "Serif",
        ["Monospace"] = "Monospace",
        ["Display"] = "Display",
        ["Pixel"] = "Pixel",
        ["Fantasy"] = "Fantasy / Themed",
        ["WoW Defaults"] = "WoW Defaults",
    }

    return labels[category] or category or "Other"
end

function Fonts:GetGroupedFonts()
    local groups = {}

    for _, fontInfo in ipairs(self:ListAvailable()) do
        local category = fontInfo.category or "Sans-serif"
        local family = fontInfo.family or fontInfo.displayName or fontInfo.name

        if not groups[category] then
            groups[category] = {
                category = category,
                label = self:GetCategoryLabel(category),
                count = 0,
                families = {},
            }
        end

        local categoryGroup = groups[category]
        if not categoryGroup.families[family] then
            categoryGroup.families[family] = {
                family = family,
                styles = {},
            }
        end

        table.insert(categoryGroup.families[family].styles, fontInfo)
        categoryGroup.count = categoryGroup.count + 1
    end

    local categoryOrder = { "Sans-serif", "Serif", "Monospace", "Display", "Pixel", "Fantasy", "WoW Defaults" }
    local orderedGroups = {}
    local seen = {}

    for _, category in ipairs(categoryOrder) do
        if groups[category] then
            table.insert(orderedGroups, groups[category])
            seen[category] = true
        end
    end

    for category, group in pairs(groups) do
        if not seen[category] then
            table.insert(orderedGroups, group)
        end
    end

    table.sort(orderedGroups, function(a, b)
        if a.label == b.label then
            return a.category < b.category
        end
        return a.label < b.label
    end)

    for _, group in ipairs(orderedGroups) do
        local families = {}
        for _, familyData in pairs(group.families) do
            table.sort(familyData.styles, function(a, b)
                return (a.name or "") < (b.name or "")
            end)
            table.insert(families, familyData)
        end

        table.sort(families, function(a, b)
            return a.family < b.family
        end)

        group.families = families
    end

    return orderedGroups
end

function Fonts:GetDropdownFontLabel(fontName)
    local info = self.registry[fontName]
    if not info then
        return fontName or self:GetDefault()
    end

    local family = info.family or fontName
    if family == fontName then
        return family
    end

    return string.format("%s - %s", family, fontName)
end

function Fonts:FindByPath(path)
    if type(path) ~= "string" or path == "" then
        return nil
    end

    local normalizedPath = string.lower(path:gsub("\\", "/"))

    for fontName, info in pairs(self.registry) do
        local infoPath = info and info.path
        if type(infoPath) == "string" and string.lower(infoPath:gsub("\\", "/")) == normalizedPath then
            return fontName, info
        end
    end

    return nil
end

function Fonts:CreateFontDropdown(parent, opts)
    opts = opts or {}
    parent = parent or UIParent
    Dropdowns = Dropdowns or _G.RGXDropdowns or RGX:GetModule("dropdowns")
    if not Dropdowns then
        RGX:Debug("Fonts: RGXDropdowns module is not available")
        return nil
    end

    local function buildItems()
        local items = {}

        for _, group in ipairs(self:GetGroupedFonts()) do
            if group.count > 0 then
                local categoryItem = {
                    text = string.format("%s (%d)", group.label, group.count),
                    notCheckable = true,
                    children = {},
                }

                for _, familyData in ipairs(group.families) do
                    if #familyData.styles == 1 then
                        local only = familyData.styles[1]
                        categoryItem.children[#categoryItem.children + 1] = {
                            text = familyData.family,
                            value = only.name,
                        }
                    else
                        local familyItem = {
                            text = string.format("%s (%d)", familyData.family, #familyData.styles),
                            notCheckable = true,
                            children = {},
                        }

                        for _, fontInfo in ipairs(familyData.styles) do
                            familyItem.children[#familyItem.children + 1] = {
                                text = fontInfo.name,
                                value = fontInfo.name,
                            }
                        end

                        categoryItem.children[#categoryItem.children + 1] = familyItem
                    end
                end

                items[#items + 1] = categoryItem
            end
        end

        return items
    end

    return Dropdowns:CreateNestedDropdown(parent, {
        label = opts.label or "Font",
        width = opts.width or 260,
        height = opts.height or 56,
        buttonWidth = opts.buttonWidth or 210,
        value = opts.value or self:GetDefault(),
        items = buildItems,
        getValueText = function(fontName)
            return self:GetDropdownFontLabel(fontName or self:GetDefault())
        end,
        onChange = function(fontName)
            if type(opts.onChange) == "function" then
                opts.onChange(fontName, self:GetPath(fontName))
            end
        end,
    })
end

function Fonts:CreateFontSettingControl(parent, opts)
    opts = opts or {}
    parent = parent or UIParent

    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(opts.width or 250, opts.height or 56)

    local storage = opts.storage
    local key = opts.key
    local defaultName = opts.defaultName or self:GetDefault()
    local defaultPath = opts.defaultPath or self:GetPath(defaultName)

    local function resolveCurrentName()
        if storage and key and type(storage[key]) == "string" then
            local found = self:FindByPath(storage[key])
            if found then
                return found
            end
        end

        if type(opts.value) == "string" and self:Exists(opts.value) then
            return opts.value
        end

        return defaultName
    end

    local dropdown = self:CreateFontDropdown(holder, {
        label = opts.label or "Font",
        width = opts.dropdownWidth or (opts.width or 250) - (opts.showReset == false and 0 or 28),
        height = opts.dropdownHeight or 56,
        buttonWidth = opts.buttonWidth or 180,
        value = resolveCurrentName(),
        onChange = function(fontName, fontPath)
            holder.value = fontName
            holder.path = fontPath

            if storage and key then
                storage[key] = fontPath
            end

            if type(opts.onChange) == "function" then
                opts.onChange(holder, fontName, fontPath)
            end
        end,
    })
    dropdown:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    holder.dropdown = dropdown

    local reset = nil
    if opts.showReset ~= false then
        reset = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate")
        reset:SetSize(opts.resetWidth or 22, opts.resetHeight or 18)
        reset:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", -2, -18)
        reset:SetText(opts.resetText or "R")
        holder.reset = reset
    end

    function holder:GetValue()
        return self.value
    end

    function holder:GetPath()
        return self.path or self:GetDefaultPath()
    end

    function holder:GetDefaultName()
        return defaultName
    end

    function holder:GetDefaultPath()
        return defaultPath
    end

    function holder:SetValue(fontName)
        if type(fontName) ~= "string" or not Fonts:Exists(fontName) then
            fontName = defaultName
        end
        self.value = fontName
        self.path = Fonts:GetPath(fontName)
        if storage and key then
            storage[key] = self.path
        end
        if self.dropdown and self.dropdown.Refresh then
            self.dropdown:Refresh(fontName)
        end
    end

    function holder:SetPath(fontPath)
        local fontName = Fonts:FindByPath(fontPath) or defaultName
        self:SetValue(fontName)
    end

    function holder:Reset()
        self:SetValue(defaultName)
        if type(opts.onReset) == "function" then
            opts.onReset(self, self.value, self.path)
        end
        if type(opts.onChange) == "function" then
            opts.onChange(self, self.value, self.path)
        end
    end

    function holder:SetEnabled(enabled)
        local isEnabled = enabled ~= false
        if self.dropdown and self.dropdown.label then
            self.dropdown.label:SetAlpha(isEnabled and 1 or 0.6)
        end
        if self.dropdown and self.dropdown.dropdown then
            UIDropDownMenu_DisableDropDown(self.dropdown.dropdown)
            if isEnabled then
                UIDropDownMenu_EnableDropDown(self.dropdown.dropdown)
            end
            self.dropdown.dropdown:SetAlpha(isEnabled and 1 or 0.45)
        end
        if self.reset then
            self.reset:SetEnabled(isEnabled)
            self.reset:SetAlpha(isEnabled and 1 or 0.45)
        end
    end

    holder:SetValue(resolveCurrentName())

    if reset then
        reset:SetScript("OnClick", function()
            holder:Reset()
        end)
    end

    return holder
end

function Fonts:CreateSimpleFontSelector(parent, opts)
    return self:CreateFontDropdown(parent, opts)
end

function Fonts:_EnsureBindingTable(db, key, fallback)
    if type(db) ~= "table" or type(key) ~= "string" or key == "" then
        return nil
    end

    if db[key] == nil and fallback ~= nil then
        db[key] = RGX:CopyTable(fallback)
    end

    return db[key]
end

function Fonts:NormalizeStyle(style)
    style = style or {}
    if type(style) == "string" then
        style = { font = style }
    end

    local font = style.font or style.name or self:GetDefault()
    if not self:Exists(font) or not self:IsAvailable(font) then
        font = self:GetDefault()
    end

    local size = tonumber(style.size) or self.defaultSize or 12
    size = math.floor(RGX:Clamp(size, 6, 72) + 0.5)

    local flags = self:NormalizeFlags(style.flags or style.outline or self.defaultFlags or "")

    local color = nil
    if style.color ~= nil or style.textColor ~= nil then
        color = self:NormalizeColorValue(style.color or style.textColor)
    end

    local shadowColor = nil
    if style.shadowColor ~= nil or style.shadow ~= nil then
        shadowColor = self:NormalizeColorValue(style.shadowColor or style.shadow)
    end

    local shadowOffset = nil
    if style.shadowOffset ~= nil or style.shadowXY ~= nil then
        local shadowX, shadowY = self:NormalizeShadowOffset(style.shadowOffset or style.shadowXY, 1, -1)
        shadowOffset = { x = shadowX, y = shadowY }
    end

    local alpha = style.alpha
    if alpha ~= nil then
        alpha = RGX:Clamp(tonumber(alpha) or 1, 0, 1)
    end

    local justifyH = nil
    if style.justifyH ~= nil or style.align ~= nil or style.justify ~= nil then
        justifyH = self:NormalizeJustify(style.justifyH or style.align or style.justify, "LEFT", false)
    end

    local justifyV = nil
    if style.justifyV ~= nil or style.valign ~= nil then
        justifyV = self:NormalizeJustify(style.justifyV or style.valign, "TOP", true)
    end

    local spacing = nil
    if style.spacing ~= nil then
        spacing = tonumber(style.spacing)
        if spacing ~= nil then
            spacing = RGX:Clamp(spacing, 0, 64)
        end
    end

    return {
        font = font,
        size = size,
        flags = flags,
        color = color,
        shadowColor = shadowColor,
        shadowOffset = shadowOffset,
        alpha = alpha,
        justifyH = justifyH,
        justifyV = justifyV,
        spacing = spacing,
    }
end

function Fonts:CreateStyle(style)
    return self:NormalizeStyle(style)
end

function Fonts:GetStyle(font, size, flags)
    if type(font) == "table" then
        return self:NormalizeStyle(font)
    end

    return self:NormalizeStyle({
        font = font,
        size = size,
        flags = flags,
    })
end

function Fonts:ApplyStyle(fontString, style)
    local normalized = self:NormalizeStyle(style)
    local applied = self:Apply(fontString, normalized.font, normalized.size, normalized.flags)
    if not applied or not fontString then
        return false
    end

    if normalized.color and fontString.SetTextColor then
        local alpha = normalized.alpha
        if alpha == nil then
            alpha = normalized.color.a
        end
        fontString:SetTextColor(
            normalized.color.r,
            normalized.color.g,
            normalized.color.b,
            alpha or 1
        )
    end

    if normalized.shadowColor and fontString.SetShadowColor then
        fontString:SetShadowColor(
            normalized.shadowColor.r,
            normalized.shadowColor.g,
            normalized.shadowColor.b,
            normalized.shadowColor.a or 1
        )
    end

    if normalized.shadowOffset and fontString.SetShadowOffset then
        fontString:SetShadowOffset(normalized.shadowOffset.x or 0, normalized.shadowOffset.y or 0)
    end

    if normalized.justifyH and fontString.SetJustifyH then
        fontString:SetJustifyH(normalized.justifyH)
    end

    if normalized.justifyV and fontString.SetJustifyV then
        fontString:SetJustifyV(normalized.justifyV)
    end

    if normalized.spacing ~= nil and fontString.SetSpacing then
        fontString:SetSpacing(normalized.spacing)
    end

    if normalized.alpha ~= nil and fontString.SetAlpha then
        fontString:SetAlpha(normalized.alpha)
    end

    return true
end

function Fonts:ApplyTextStyle(fontString, style)
    return self:ApplyStyle(fontString, style)
end

function Fonts:AttachFontSelector(parent, db, key, opts)
    opts = opts or {}
    if type(db) ~= "table" or type(key) ~= "string" or key == "" then
        RGX:Debug("Fonts: AttachFontSelector requires db table and key")
        return nil
    end

    local current = db[key]
    if type(current) ~= "string" or current == "" then
        current = opts.value or self:GetDefault()
        db[key] = current
    end

    local selector = self:CreateSimpleFontSelector(parent, {
        label = opts.label or "Font",
        value = current,
        width = opts.width,
        height = opts.height,
        buttonWidth = opts.buttonWidth,
        onChange = function(fontName, path)
            db[key] = fontName
            if type(opts.onChange) == "function" then
                opts.onChange(fontName, path, db)
            end
        end,
    })

    selector.DB = db
    selector.DBKey = key

    function selector:RefreshFromDB()
        local value = self.DB[self.DBKey]
        if type(value) ~= "string" or value == "" then
            value = Fonts:GetDefault()
            self.DB[self.DBKey] = value
        end
        self:Refresh(value)
    end

    selector:RefreshFromDB()
    return selector
end

function Fonts:GetOptionValues()
    local values = {}
    for _, info in ipairs(self:ListAvailable()) do
        values[info.name] = info.displayName or info.family or info.name
    end
    return values
end

function Fonts:CreateStyleSelector(parent, opts)
    opts = opts or {}
    parent = parent or UIParent

    local selector = CreateFrame("Frame", nil, parent)
    selector:SetSize(opts.width or 250, opts.height or 130)

    selector.value = self:NormalizeStyle(opts.value or {
        font = self:GetDefault(),
        size = self.defaultSize,
        flags = self.defaultFlags,
    })

    selector.label = selector:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selector.label:SetPoint("TOPLEFT", 0, 0)
    selector.label:SetText(opts.label or "Font Style")

    selector.preview = selector:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    selector.preview:SetPoint("TOPLEFT", selector.label, "BOTTOMLEFT", 0, -6)
    selector.preview:SetPoint("RIGHT", 0, 0)
    selector.preview:SetJustifyH("LEFT")
    selector.preview:SetText(opts.previewText or "The quick brown fox jumps over the lazy dog.")

    selector.dropdown = self:CreateFontDropdown(selector, {
        label = opts.fontLabel or "Font",
        value = selector.value.font,
        width = opts.dropdownWidth or 220,
        buttonWidth = opts.buttonWidth or 180,
        menuWidth = opts.menuWidth or 230,
        menuHeight = opts.menuHeight or 220,
        onChange = function(fontName)
            selector.value.font = fontName
            selector:Refresh()
        end,
    })
    selector.dropdown:SetPoint("TOPLEFT", selector.preview, "BOTTOMLEFT", 0, -12)

    self._widgetId = self._widgetId + 1
    local selectorSliderName = "RGXFontStyleSelectorSlider" .. self._widgetId
    selector.sizeSlider = CreateFrame("Slider", selectorSliderName, selector, "OptionsSliderTemplate")
    selector.sizeSlider:SetPoint("TOPLEFT", selector.dropdown, "BOTTOMLEFT", 8, -18)
    selector.sizeSlider:SetWidth(opts.sliderWidth or 150)
    selector.sizeSlider:SetMinMaxValues(opts.minSize or 8, opts.maxSize or 32)
    selector.sizeSlider:SetValueStep(1)
    selector.sizeSlider:SetObeyStepOnDrag(true)
    selector.sizeSlider:SetValue(selector.value.size)
    _G[selector.sizeSlider:GetName() .. "Low"]:SetText(tostring(opts.minSize or 8))
    _G[selector.sizeSlider:GetName() .. "High"]:SetText(tostring(opts.maxSize or 32))
    _G[selector.sizeSlider:GetName() .. "Text"]:SetText(opts.sizeLabel or "Size")

    selector.flagsLabel = selector:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selector.flagsLabel:SetPoint("TOPLEFT", selector.sizeSlider, "BOTTOMLEFT", -8, -8)
    selector.flagsLabel:SetText(opts.flagsLabel or "Style")

    selector.flagsButton = CreateFrame("Button", nil, selector, "UIPanelButtonTemplate")
    selector.flagsButton:SetSize(150, 24)
    selector.flagsButton:SetPoint("TOPLEFT", selector.flagsLabel, "BOTTOMLEFT", 0, -4)
    selector.flagsButton:SetText("")

    selector.flagsButtonText = selector.flagsButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    selector.flagsButtonText:SetPoint("LEFT", 8, 0)
    selector.flagsButtonText:SetPoint("RIGHT", -18, 0)
    selector.flagsButtonText:SetJustifyH("LEFT")

    selector.flagsArrow = selector.flagsButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selector.flagsArrow:SetPoint("RIGHT", -8, 0)
    selector.flagsArrow:SetText("v")

    selector.flagsMenu = CreateFrame("Frame", nil, selector, "BackdropTemplate")
    selector.flagsMenu:SetPoint("TOPLEFT", selector.flagsButton, "BOTTOMLEFT", 0, -2)
    selector.flagsMenu:SetSize(176, 150)
    selector.flagsMenu:SetFrameStrata("DIALOG")
    selector.flagsMenu:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    selector.flagsMenu:SetBackdropColor(0.05, 0.06, 0.08, 0.96)
    selector.flagsMenu:SetBackdropBorderColor(0.32, 0.36, 0.42, 1)
    selector.flagsMenu:Hide()

    selector.flagButtons = {}
    for index, preset in ipairs(self:GetFlagPresets()) do
        local button = CreateFrame("Button", nil, selector.flagsMenu, "UIPanelButtonTemplate")
        button:SetSize(152, 22)
        button:SetPoint("TOPLEFT", 12, -10 - ((index - 1) * 24))
        button:SetText("")

        button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        button.text:SetPoint("LEFT", 8, 0)
        button.text:SetPoint("RIGHT", -8, 0)
        button.text:SetJustifyH("LEFT")
        button.text:SetText(preset.label)
        button.value = preset.value
        button:SetScript("OnClick", function()
            selector.value.flags = preset.value
            selector.flagsButtonText:SetText(preset.label)
            selector.flagsMenu:Hide()
            Fonts:ApplyStyle(selector.preview, selector.value)
            if type(opts.onChange) == "function" then
                opts.onChange(selector:GetValue())
            end
        end)
        selector.flagButtons[#selector.flagButtons + 1] = button
    end

    selector.flagsButton:SetScript("OnClick", function()
        selector.flagsMenu:SetShown(not selector.flagsMenu:IsShown())
    end)

    function selector:GetValue()
        return RGX:CopyTable(self.value)
    end

    function selector:SetValue(style)
        self.value = Fonts:NormalizeStyle(style)
        self:Refresh()
    end

    function selector:Refresh()
        self.dropdown:Refresh(self.value.font)
        self.sizeSlider:SetValue(self.value.size)
        self.flagsButtonText:SetText(Fonts:DescribeFlags(self.value.flags))
        Fonts:ApplyStyle(self.preview, self.value)
        if type(opts.onChange) == "function" then
            opts.onChange(self:GetValue())
        end
    end

    selector.sizeSlider:SetScript("OnValueChanged", function(_, value)
        selector.value.size = math.floor(value + 0.5)
        Fonts:ApplyStyle(selector.preview, selector.value)
        if type(opts.onChange) == "function" then
            opts.onChange(selector:GetValue())
        end
    end)

    selector:Refresh()
    return selector
end

function Fonts:CreateSimpleStyleSelector(parent, opts)
    return self:CreateStyleSelector(parent, opts)
end

function Fonts:AttachStyleSelector(parent, db, key, opts)
    opts = opts or {}
    if type(db) ~= "table" or type(key) ~= "string" or key == "" then
        RGX:Debug("Fonts: AttachStyleSelector requires db table and key")
        return nil
    end

    local fallback = self:NormalizeStyle(opts.value or {
        font = self:GetDefault(),
        size = self.defaultSize,
        flags = self.defaultFlags,
    })

    local current = self:_EnsureBindingTable(db, key, fallback)
    current = self:NormalizeStyle(current)
    db[key] = current

    local selector = self:CreateSimpleStyleSelector(parent, {
        label = opts.label or "Text Style",
        value = current,
        width = opts.width,
        height = opts.height,
        dropdownWidth = opts.dropdownWidth,
        buttonWidth = opts.buttonWidth,
        menuWidth = opts.menuWidth,
        menuHeight = opts.menuHeight,
        sliderWidth = opts.sliderWidth,
        minSize = opts.minSize,
        maxSize = opts.maxSize,
        previewText = opts.previewText,
        fontLabel = opts.fontLabel,
        sizeLabel = opts.sizeLabel,
        flagsLabel = opts.flagsLabel,
        onChange = function(style)
            db[key] = Fonts:NormalizeStyle(style)
            if type(opts.onChange) == "function" then
                opts.onChange(db[key], db)
            end
        end,
    })

    selector.DB = db
    selector.DBKey = key

    function selector:RefreshFromDB()
        local value = Fonts:NormalizeStyle(self.DB[self.DBKey] or fallback)
        self.DB[self.DBKey] = value
        self:SetValue(value)
    end

    selector:RefreshFromDB()
    return selector
end

function Fonts:ApplyStyleMap(targets, styleTable)
    if type(targets) ~= "table" or type(styleTable) ~= "table" then
        return false
    end

    local applied = false

    for key, fontString in pairs(targets) do
        if fontString and fontString.SetFont and type(styleTable[key]) == "table" then
            self:ApplyStyle(fontString, styleTable[key])
            applied = true
        end
    end

    return applied
end

function Fonts:CreateStyleEditorFrame(opts)
    opts = opts or {}

    local db = opts.db
    local styles = opts.styles
    if type(db) ~= "table" or type(styles) ~= "table" then
        RGX:Debug("Fonts: CreateStyleEditorFrame requires db table and styles list")
        return nil
    end

    local parent = opts.parent or UIParent
    local frame = CreateFrame("Frame", opts.name, parent, "BasicFrameTemplateWithInset")
    frame:SetSize(opts.width or 420, opts.height or 520)
    frame:SetPoint(unpack(opts.point or { "CENTER" }))
    frame:SetFrameStrata(opts.frameStrata or "DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    frame.TitleText:SetText(opts.title or "Text Styles")

    if type(opts.subtitle) == "string" and opts.subtitle ~= "" then
        frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.subtitle:SetPoint("TOPLEFT", 16, -34)
        frame.subtitle:SetPoint("RIGHT", -16, 0)
        frame.subtitle:SetJustifyH("LEFT")
        frame.subtitle:SetText(opts.subtitle)
    end

    frame.StyleSelectors = {}
    frame.StyleOrder = {}

    local previous
    local startY = frame.subtitle and -64 or -40
    local gap = tonumber(opts.selectorGap) or 26
    local selectorWidth = opts.selectorWidth or ((opts.width or 420) - 60)

    local function onAnyStyleChanged()
        if type(opts.onChange) == "function" then
            opts.onChange(db)
        end
    end

    for index, styleDef in ipairs(styles) do
        if type(styleDef) == "table" and type(styleDef.key) == "string" and styleDef.key ~= "" then
            local selector = self:AttachStyleSelector(frame, db, styleDef.key, {
                label = styleDef.label or styleDef.key,
                value = styleDef.value or styleDef.default,
                previewText = styleDef.previewText,
                width = styleDef.width or selectorWidth,
                height = styleDef.height or 130,
                dropdownWidth = styleDef.dropdownWidth,
                buttonWidth = styleDef.buttonWidth,
                menuWidth = styleDef.menuWidth,
                menuHeight = styleDef.menuHeight,
                sliderWidth = styleDef.sliderWidth,
                minSize = styleDef.minSize,
                maxSize = styleDef.maxSize,
                fontLabel = styleDef.fontLabel,
                sizeLabel = styleDef.sizeLabel,
                flagsLabel = styleDef.flagsLabel,
                onChange = onAnyStyleChanged,
            })

            if selector then
                if previous then
                    selector:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -gap)
                else
                    selector:SetPoint("TOPLEFT", 18, startY)
                end
                previous = selector
                frame.StyleSelectors[styleDef.key] = selector
                frame.StyleOrder[#frame.StyleOrder + 1] = styleDef.key
            end
        end
    end

    if type(opts.onReset) == "function" then
        frame.resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        frame.resetButton:SetSize(opts.resetButtonWidth or 120, 24)
        frame.resetButton:SetPoint("BOTTOMLEFT", 18, 16)
        frame.resetButton:SetText(opts.resetButtonText or "Reset Styles")
        frame.resetButton:SetScript("OnClick", function()
            opts.onReset(db)
            for _, key in ipairs(frame.StyleOrder) do
                local selector = frame.StyleSelectors[key]
                if selector and selector.RefreshFromDB then
                    selector:RefreshFromDB()
                end
            end
            onAnyStyleChanged()
        end)
    end

    function frame:RefreshFromDB()
        for _, key in ipairs(self.StyleOrder) do
            local selector = self.StyleSelectors[key]
            if selector and selector.RefreshFromDB then
                selector:RefreshFromDB()
            end
        end
    end

    function frame:Toggle()
        if self:IsShown() then
            self:Hide()
            return
        end

        self:RefreshFromDB()
        self:Show()
        self:Raise()
    end

    return frame
end

function Fonts:CreateTestFrame()
    if self.testFrame then
        return self.testFrame
    end

    local frame = CreateFrame("Frame", "RGXFontTestFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(860, 560)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    frame.TitleText:SetText("RGX Font Test")

    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.subtitle:SetPoint("TOPLEFT", 16, -34)
    frame.subtitle:SetText("Preview RGX fonts and reuse the same selector pattern in your addon options.")

    frame.searchLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.searchLabel:SetPoint("TOPLEFT", 16, -58)
    frame.searchLabel:SetText("Search")

    frame.searchBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.searchBox:SetSize(190, 24)
    frame.searchBox:SetPoint("TOPLEFT", frame.searchLabel, "BOTTOMLEFT", 0, -4)
    frame.searchBox:SetAutoFocus(false)
    frame.searchBox:SetScript("OnTextChanged", function()
        self:_BuildPreviewButtons(frame)
    end)

    frame.fontListLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.fontListLabel:SetPoint("TOPLEFT", frame.searchBox, "BOTTOMLEFT", 0, -10)
    frame.fontListLabel:SetText("Available Fonts")

    frame.fontListScroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    frame.fontListScroll:SetPoint("TOPLEFT", frame.fontListLabel, "BOTTOMLEFT", 0, -6)
    frame.fontListScroll:SetSize(210, 360)

    frame.fontListContent = CreateFrame("Frame", nil, frame.fontListScroll)
    frame.fontListContent:SetSize(186, 1)
    frame.fontListScroll:SetScrollChild(frame.fontListContent)

    frame.noResults = frame.fontListContent:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    frame.noResults:SetPoint("TOPLEFT", 0, 0)
    frame.noResults:SetText("No fonts matched your search.")
    frame.noResults:Hide()

    frame.previewPane = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.previewPane:SetPoint("TOPLEFT", 252, -58)
    frame.previewPane:SetPoint("BOTTOMRIGHT", -16, 60)
    frame.previewPane:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame.previewPane:SetBackdropColor(0.05, 0.06, 0.08, 0.96)
    frame.previewPane:SetBackdropBorderColor(0.25, 0.28, 0.34, 1)

    frame.previewTitle = frame.previewPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    frame.previewTitle:SetPoint("TOPLEFT", 16, -18)
    frame.previewTitle:SetPoint("RIGHT", -16, 0)
    frame.previewTitle:SetJustifyH("LEFT")

    frame.previewMeta = frame.previewPane:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.previewMeta:SetPoint("TOPLEFT", frame.previewTitle, "BOTTOMLEFT", 0, -10)
    frame.previewMeta:SetPoint("RIGHT", -16, 0)
    frame.previewMeta:SetJustifyH("LEFT")
    frame.previewMeta:SetTextColor(0.72, 0.78, 0.86)

    frame.previewBody = frame.previewPane:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.previewBody:SetPoint("TOPLEFT", frame.previewMeta, "BOTTOMLEFT", 0, -16)
    frame.previewBody:SetPoint("BOTTOMRIGHT", -16, 16)
    frame.previewBody:SetJustifyH("LEFT")
    frame.previewBody:SetJustifyV("TOP")
    frame.previewBody:SetSpacing(6)

    frame.currentFontTag = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.currentFontTag:SetPoint("BOTTOMLEFT", 16, 36)
    frame.currentFontTag:SetText("Selected")

    frame.currentFontLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.currentFontLabel:SetPoint("LEFT", frame.currentFontTag, "RIGHT", 8, 0)

    frame.currentSizeTag = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.currentSizeTag:SetPoint("BOTTOMLEFT", 16, 14)
    frame.currentSizeTag:SetText("Preview Size")

    frame.currentSizeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.currentSizeLabel:SetPoint("LEFT", frame.currentSizeTag, "RIGHT", 8, 0)

    frame.currentStyleTag = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.currentStyleTag:SetPoint("LEFT", frame.currentSizeLabel, "RIGHT", 22, 0)
    frame.currentStyleTag:SetText("Style")

    frame.currentStyleLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.currentStyleLabel:SetPoint("LEFT", frame.currentStyleTag, "RIGHT", 8, 0)

    self._widgetId = self._widgetId + 1
    local previewSliderName = "RGXFontPreviewSlider" .. self._widgetId
    frame.sizeSlider = CreateFrame("Slider", previewSliderName, frame, "OptionsSliderTemplate")
    frame.sizeSlider:SetPoint("BOTTOMRIGHT", -180, 16)
    frame.sizeSlider:SetMinMaxValues(10, 28)
    frame.sizeSlider:SetValueStep(1)
    frame.sizeSlider:SetObeyStepOnDrag(true)
    frame.sizeSlider:SetValue(16)
    _G[frame.sizeSlider:GetName() .. "Low"]:SetText("10")
    _G[frame.sizeSlider:GetName() .. "High"]:SetText("28")
    _G[frame.sizeSlider:GetName() .. "Text"]:SetText("Size")
    frame.sizeSlider:SetScript("OnValueChanged", function()
        self:_ApplyPreviewSelection(frame, frame.selectedFont or self:GetDefault())
    end)

    frame.flagsValue = ""
    frame.flagsLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.flagsLabel:SetPoint("LEFT", frame.sizeSlider, "RIGHT", 18, 10)
    frame.flagsLabel:SetText("Style")

    frame.flagsButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.flagsButton:SetSize(150, 24)
    frame.flagsButton:SetPoint("TOPLEFT", frame.flagsLabel, "BOTTOMLEFT", 0, -2)
    frame.flagsButton:SetText("")

    frame.flagsButtonText = frame.flagsButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.flagsButtonText:SetPoint("LEFT", 8, 0)
    frame.flagsButtonText:SetPoint("RIGHT", -18, 0)
    frame.flagsButtonText:SetJustifyH("LEFT")
    frame.flagsButtonText:SetText(self:DescribeFlags(frame.flagsValue))

    frame.flagsArrow = frame.flagsButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.flagsArrow:SetPoint("RIGHT", -8, 0)
    frame.flagsArrow:SetText("v")

    frame.flagsMenu = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.flagsMenu:SetPoint("TOPLEFT", frame.flagsButton, "BOTTOMLEFT", 0, -2)
    frame.flagsMenu:SetSize(180, 150)
    frame.flagsMenu:SetFrameStrata("DIALOG")
    frame.flagsMenu:SetBackdrop({
        bgFile = "Interface/Buttons/WHITE8X8",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame.flagsMenu:SetBackdropColor(0.05, 0.06, 0.08, 0.96)
    frame.flagsMenu:SetBackdropBorderColor(0.32, 0.36, 0.42, 1)
    frame.flagsMenu:Hide()

    frame.flagButtons = {}
    for index, preset in ipairs(self:GetFlagPresets()) do
        local button = CreateFrame("Button", nil, frame.flagsMenu, "UIPanelButtonTemplate")
        button:SetSize(156, 22)
        button:SetPoint("TOPLEFT", 12, -10 - ((index - 1) * 24))
        button:SetText("")
        button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        button.text:SetPoint("LEFT", 8, 0)
        button.text:SetPoint("RIGHT", -8, 0)
        button.text:SetJustifyH("LEFT")
        button.text:SetText(preset.label)
        button.value = preset.value
        button:SetScript("OnClick", function()
            frame.flagsValue = preset.value
            frame.flagsButtonText:SetText(preset.label)
            frame.flagsMenu:Hide()
            self:_ApplyPreviewSelection(frame, frame.selectedFont or self:GetDefault())
        end)
        frame.flagButtons[#frame.flagButtons + 1] = button
    end

    frame.flagsButton:SetScript("OnClick", function()
        frame.flagsMenu:SetShown(not frame.flagsMenu:IsShown())
    end)

    frame.demoSelector = self:CreateFontDropdown(frame, {
        label = "Reusable Selector Demo",
        value = self:GetDefault(),
        width = 220,
        buttonWidth = 180,
        menuWidth = 230,
        menuHeight = 220,
        onChange = function(fontName)
            self:_ApplyPreviewSelection(frame, fontName)
        end,
    })
    frame.demoSelector:SetPoint("BOTTOMLEFT", 252, 10)

    frame.demoStyleSelector = self:CreateStyleSelector(frame, {
        label = "Full Style Selector Demo",
        value = {
            font = self:GetDefault(),
            size = 14,
            flags = "",
        },
        previewText = "Shared selector for addon settings.",
        width = 290,
        dropdownWidth = 220,
        sliderWidth = 140,
        onChange = function(style)
            frame.flagsValue = style.flags or ""
            frame.flagsButtonText:SetText(self:DescribeFlags(style.flags))
            frame.sizeSlider:SetValue(style.size or 16)
            self:_ApplyPreviewSelection(frame, style.font or self:GetDefault())
        end,
    })
    frame.demoStyleSelector:SetPoint("LEFT", frame.demoSelector, "RIGHT", 26, 0)

    self.testFrame = frame
    self:_BuildPreviewButtons(frame)
    self:_ApplyPreviewSelection(frame, self:GetDefault())

    return frame
end

function Fonts:ToggleTestFrame()
    local frame = self:CreateTestFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        frame:SetFrameStrata("DIALOG")
        frame:Raise()
        self:_BuildPreviewButtons(frame)
        self:_ApplyPreviewSelection(frame, frame.selectedFont or self:GetDefault())
    end
    return frame
end

function Fonts:FromTemplate(parent, template, text, layer)
    local settings = {
        header = { size = 16, flags = "OUTLINE" },
        title = { size = 18, flags = "OUTLINE" },
        body = { size = 12, flags = "" },
        caption = { size = 10, flags = "" },
        small = { size = 9, flags = "" },
    }
    
    local setting = settings[template] or settings.body
    local fs = self:CreateString(parent, self.default, setting.size, setting.flags, layer)
    if text then fs:SetText(text) end
    
    return fs
end

--[[============================================================================
    AUTO-DISCOVERY
============================================================================]]

-- Scan font folder and register any fonts not in definitions
function Fonts:ScanForNewFonts()
    -- This would need file system access which WoW doesn't allow
    -- Instead, we check on init which fonts are actually available
    RGX:Debug("Fonts: Scanning for available fonts...")
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function Fonts:Init()
    self:RegisterBuiltInFonts()

    -- Register packaged fonts
    for name, def in pairs(self.definitions) do
        self:Register(name, self.fontPath .. def.file, {
            displayName = def.family,
            family = def.family,
            category = def.category,
            license = def.license
        })
    end

    -- Check availability
    for name, data in pairs(self.registry) do
        if data.available == nil then
            local testFont = CreateFont("RGX_Test_" .. name:gsub("[^%w]", "_"))
            data.available = pcall(function()
                testFont:SetFont(data.path, 12, "")
            end)
        end
    end

    -- Set default
    if self:IsAvailable("Inter-Regular") then
        self:SetDefault("Inter-Regular")
    else
        self:SetDefault("FrizQuadrata")
    end
    
	-- Register with framework
	RGX:RegisterModule("fonts", self)
	
    -- SUPER SIMPLE: Make Fonts globally accessible
    _G.RGXFonts = self
end

Fonts:Init()
