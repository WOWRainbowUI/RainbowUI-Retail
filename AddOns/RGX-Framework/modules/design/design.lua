--=====================================================================================
-- RGX-Framework | RGXDesign
-- Visual building blocks for any RGX-Framework addon UI.
--
-- Theme tokens (addon-overridable via Design:SetTheme):
--   primary - highlight color used on labels, borders, fills, slider fills
--   accent  - secondary highlight color
--
-- Default look: sleek dark navy panels with rounded corners and a cyan
-- developer accent, in the spirit of modern dev-tool addon UIs.
--
-- Usage:
--   local Design = RGX:GetDesign()
--   Design:SetTheme({
--       primary = {0.02, 0.87, 0.98},
--       accent  = {1.00, 0.84, 0.00},
--   })
--
-- Public API:
--   Design:SetTheme(config)                       -- override theme tokens
--   Design:SetHighlightColor(color, accent)       -- shorthand for primary/accent
--   Design:GetColor(key)                          -- {r,g,b}
--   Design:Unpack(key)                            -- r, g, b for direct use
--   Design:RGBToHex(r, g, b)
--   Design:ApplyBackdrop(frame, variant, bgAlpha) -- legacy square backdrop
--   Design:CreateFrame(parent, opts)              -- rounded panel (opts.square for legacy)
--   Design:CreateButton(parent, text, w, h)       -- styled action button
--   Design:CreateSectionHeader(parent, text, icon)
--   Design:CreateDivider(parent)
--   Design:CreateSection(parent, title, icon)
--=====================================================================================

local addonName, RGX = ...

local Design = {}

-- Apply the framework default font to a label, preserving size/flags.
local function ApplyDefaultFont(fs)
    local Fonts = _G.RGXFonts
    if not (Fonts and type(Fonts.Apply) == "function" and type(Fonts.GetDefault) == "function") then return end
    if not (fs and fs.GetFont) then return end
    local _, size, flags = fs:GetFont()
    pcall(Fonts.Apply, Fonts, fs, Fonts:GetDefault(), size, flags)
end

-- Theme tokens. Addons should override these before building UI.
Design.Theme = {
    primary = {0.000, 0.902, 1.000}, -- #00e6ff cyan
    accent  = {0.737, 0.435, 0.659}, -- #bc6fa8 brand purple (highlights/active states)
}

-- Named theme presets exposed through the framework settings panel. Each
-- preset is a full {primary, accent} pair; the framework persists the
-- operator's choice in RGXFrameworkDB.themePreset and re-applies it on
-- login. "cyan" is the shipped default.
Design.THEME_PRESETS = {
    cyan   = { primary = {0.000, 0.902, 1.000}, accent = {0.737, 0.435, 0.659} },
    gold   = { primary = {1.000, 0.843, 0.000}, accent = {0.737, 0.435, 0.659} },
    green  = { primary = {0.345, 0.745, 0.506}, accent = {0.737, 0.435, 0.659} },
    purple = { primary = {0.639, 0.529, 1.000}, accent = {0.000, 0.902, 1.000} },
    rose   = { primary = {1.000, 0.416, 0.678}, accent = {0.000, 0.902, 1.000} },
}

-- Current preset name (nil = custom theme set directly via SetTheme).
Design.currentPreset = "cyan"

-- Global corner preference: "rounded" (default) or "square". Stored in
-- RGXFrameworkDB.cornerStyle and honored by CreateFrame unless the caller
-- explicitly opts into square with opts.square.
Design.cornerStyle = "rounded"

function Design:SetThemePreset(name)
    local preset = self.THEME_PRESETS and self.THEME_PRESETS[name]
    if not preset then return false end
    self:SetTheme({ primary = preset.primary, accent = preset.accent })
    self.currentPreset = name
    return true
end

function Design:GetThemePreset()
    return self.currentPreset
end

function Design:SetCornerStyle(style)
    if style == "rounded" or style == "square" then
        self.cornerStyle = style
        return true
    end
    return false
end

-- Structural palette: dark navy foundation with cyan-friendly neutrals.
Design.Colors = {
    surface    = {0.086, 0.086, 0.110}, -- panel
    background = {0.055, 0.055, 0.071},
    panelAlt   = {0.102, 0.102, 0.129},
    text       = {0.910, 0.910, 0.933},
    subtext    = {0.545, 0.545, 0.596},
    label      = {0.357, 0.357, 0.400},
    success    = {0.200, 0.800, 0.400},
    warning    = {0.941, 0.706, 0.161},
    error      = {0.878, 0.333, 0.333},
    border     = {0.137, 0.137, 0.173},
    hover      = {0.102, 0.102, 0.129},
    track      = {0.137, 0.137, 0.173},
}

-- Rounded panel rendering -----------------------------------------------------

Design.Radius = 12
Design.PANEL_TEX = "Interface\\AddOns\\RGX-Framework\\media\\panel_rounded.tga"

-- 128px texture with 32px corners: corner slice covers a quarter of the UVs.
local PANEL_TC = 0.25

local function ApplyLabelFont(fs, size)
    -- One font per addon: honor the framework font designation
    -- (RGXFonts default set by the addon) so element, button, and text fonts
    -- are always the same face. Locale fallback covers CJK/cyrillic scripts.
    local Fonts = _G.RGXFonts
    if Fonts and type(Fonts.Apply) == "function" and type(Fonts.GetDefault) == "function" then
        local ok = pcall(function()
            local _, natural = fs:GetFont()
            Fonts:Apply(fs, Fonts:GetDefault(), size or natural or 12, "")
        end)
        if ok and fs.GetFont then
            local applied = fs:GetFont()
            if applied then
                fs:SetShadowColor(0, 0, 0, 0.6)
                fs:SetShadowOffset(1, -1)
                return fs
            end
        end
    end
    local font = "Interface\\AddOns\\RGX-Framework\\media\\fonts\\Inter-Regular.otf"
    local locale = _G.GetLocale and _G.GetLocale()
    if locale == "koKR" or locale == "zhCN" or locale == "zhTW" or locale == "ruRU" then
        font = _G.STANDARD_TEXT_FONT or font
    end
    local ok = fs:SetFont(font, size or 12, "")
    if not ok then
        fs:SetFont(_G.STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", size or 12, "")
    end
    fs:SetShadowColor(0, 0, 0, 0.6)
    fs:SetShadowOffset(1, -1)
    return fs
end

local function BuildNineSlice(frame, layer, slice, inset, color, alpha)
    local function t()
        local tx = frame:CreateTexture(nil, layer)
        tx:SetTexture(Design.PANEL_TEX)
        tx:SetVertexColor(color[1], color[2], color[3], alpha or 1)
        return tx
    end
    local i = inset
    local tl, tr, bl, br = t(), t(), t(), t()
    local tm, bm, ml, mr, c = t(), t(), t(), t(), t()
    tl:SetSize(slice, slice); tl:SetPoint("TOPLEFT", i, -i); tl:SetTexCoord(0, PANEL_TC, 0, PANEL_TC)
    tr:SetSize(slice, slice); tr:SetPoint("TOPRIGHT", -i, -i); tr:SetTexCoord(1 - PANEL_TC, 1, 0, PANEL_TC)
    bl:SetSize(slice, slice); bl:SetPoint("BOTTOMLEFT", i, i); bl:SetTexCoord(0, PANEL_TC, 1 - PANEL_TC, 1)
    br:SetSize(slice, slice); br:SetPoint("BOTTOMRIGHT", -i, i); br:SetTexCoord(1 - PANEL_TC, 1, 1 - PANEL_TC, 1)
    tm:SetPoint("TOPLEFT", tl, "TOPRIGHT"); tm:SetPoint("BOTTOMRIGHT", tr, "BOTTOMLEFT"); tm:SetTexCoord(PANEL_TC, 1 - PANEL_TC, 0, PANEL_TC)
    bm:SetPoint("TOPLEFT", bl, "TOPRIGHT"); bm:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT"); bm:SetTexCoord(PANEL_TC, 1 - PANEL_TC, 1 - PANEL_TC, 1)
    ml:SetPoint("TOPLEFT", tl, "BOTTOMLEFT"); ml:SetPoint("BOTTOMRIGHT", bl, "TOPRIGHT"); ml:SetTexCoord(0, PANEL_TC, PANEL_TC, 1 - PANEL_TC)
    mr:SetPoint("TOPLEFT", tr, "BOTTOMLEFT"); mr:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT"); mr:SetTexCoord(1 - PANEL_TC, 1, PANEL_TC, 1 - PANEL_TC)
    c:SetPoint("TOPLEFT", tl, "BOTTOMRIGHT"); c:SetPoint("BOTTOMRIGHT", br, "TOPLEFT"); c:SetTexCoord(PANEL_TC, 1 - PANEL_TC, PANEL_TC, 1 - PANEL_TC)
    return { tl, tr, bl, br, tm, bm, ml, mr, c }
end

-- Legacy square backdrops (opts.square = true on CreateFrame, or ApplyBackdrop).
local BACKDROPS = {
    dark = {
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = {left=1, right=1, top=1, bottom=1},
    },
    panel = {
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = {left=1, right=1, top=1, bottom=1},
    },
    solid = {
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, edgeSize = 1,
        insets = {left=0, right=0, top=0, bottom=0},
    },
    border = {
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = {left=0, right=0, top=0, bottom=0},
    },
}

local THEME_KEYS = {
    primary      = "primary",
    main         = "primary",
    mainColor    = "primary",
    highlight    = "primary",
    accent       = "accent",
    borderActive = "primary",
}

local MAIN_SHADES = { mainSurface = 0.10, mainHover = 0.20, mainBorder = 0.35 }

local function IsColor(value)
    return type(value) == "table"
        and type(value[1]) == "number"
        and type(value[2]) == "number"
        and type(value[3]) == "number"
end

function Design:SetTheme(config)
    if type(config) ~= "table" then return end

    local primary = config.primary
        or config.main
        or config.mainColor
        or config.highlight
        or config.highlightColor
        or config.themeColor

    local accent = config.accent
        or config.secondary
        or config.secondaryHighlight

    if IsColor(primary) then self.Theme.primary = primary end
    if IsColor(accent) then self.Theme.accent = accent end
end

function Design:SetHighlightColor(color, accent)
    self:SetTheme({ primary = color, accent = accent })
end

Design.SetMainColor = Design.SetHighlightColor

-- Scoped theme override for one addon's UI construction without mutating the
-- shared defaults: applies the theme for fn's duration, then restores.
--   Design:WithTheme({ primary = MY_BRAND_GREEN }, function() ... build panel ... end)
function Design:WithTheme(theme, fn)
    if type(fn) ~= "function" then return end
    local prevPrimary = self.Theme.primary
    local prevAccent = self.Theme.accent
    self:SetTheme(theme)
    local ok, err = pcall(fn)
    self.Theme.primary = prevPrimary
    self.Theme.accent = prevAccent
    if not ok then error(err, 0) end
end

Design.SetColors = Design.SetTheme
Design.UseTheme = Design.SetTheme

function Design:GetColor(key)
    -- Shared shades derive from the active main color, including scoped
    -- construction themes. Never cache them across theme changes.
    local factor = MAIN_SHADES[key]
    if factor then
        local main = self.Theme.primary
        return { main[1] * factor, main[2] * factor, main[3] * factor }
    end
    local themeKey = THEME_KEYS[key]
    if themeKey then return self.Theme[themeKey] or {1, 1, 1} end
    return self.Colors[key] or {1, 1, 1}
end

function Design:Unpack(key)
    local c = self:GetColor(key)
    return c[1] or 1, c[2] or 1, c[3] or 1
end

function Design:RGBToHex(r, g, b)
    return string.format("%02x%02x%02x",
        math.floor((r or 1) * 255 + 0.5),
        math.floor((g or 1) * 255 + 0.5),
        math.floor((b or 1) * 255 + 0.5)
    )
end

function Design:ApplyBackdrop(frame, variant, bgAlpha)
    local bd = BACKDROPS[variant] or BACKDROPS.dark
    frame:SetBackdrop(bd)
    local r, g, b = self:Unpack("surface")
    frame:SetBackdropColor(r, g, b, bgAlpha or 0.95)
    frame:SetBackdropBorderColor(self:Unpack("border"))
end

-- Rounded panel with a 1px border ring: border layer at inset 0, fill layer
-- at inset 1, both nine-sliced from the rounded texture.
function Design:ApplyPanel(frame, opts)
    opts = opts or {}
    local slice = opts.radius or self.Radius
    local fill = self:GetColor(opts.color or "surface")
    local borderColor = self:GetColor(opts.borderColor or "border")
    local fillAlpha = opts.bgAlpha

    frame._panelBorder = BuildNineSlice(frame, "BACKGROUND", slice, 0, borderColor, 1)
    frame._panelFill   = BuildNineSlice(frame, "BORDER", slice, 1, fill, fillAlpha)

    function frame:SetPanelColor(fillColor, borderColor, alpha)
        if borderColor then
            for _, tx in ipairs(self._panelBorder) do
                tx:SetVertexColor(borderColor[1], borderColor[2], borderColor[3], 1)
            end
        end
        if fillColor then
            for _, tx in ipairs(self._panelFill) do
                tx:SetVertexColor(fillColor[1], fillColor[2], fillColor[3], alpha or 1)
            end
        end
    end

    return frame
end

function Design:CreateFrame(parent, opts)
    opts = opts or {}
    -- Corner preference: an explicit opts.square wins (callers that need the
    -- legacy backdrop say so); otherwise the framework-level cornerStyle
    -- setting decides between rounded panels and square backdrops.
    if opts.square == nil then
        opts.square = self.cornerStyle == "square"
    end
    if opts.square then
        local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        if opts.width  then frame:SetWidth(opts.width)   end
        if opts.height then frame:SetHeight(opts.height) end
        self:ApplyBackdrop(frame, opts.variant or "dark", opts.bgAlpha)
        if opts.color then
            frame:SetBackdropColor(self:Unpack(opts.color))
        end
        return frame
    end

    local frame = CreateFrame("Frame", nil, parent)
    if opts.width  then frame:SetWidth(opts.width)   end
    if opts.height then frame:SetHeight(opts.height) end
    self:ApplyPanel(frame, opts)
    return frame
end

function Design:CreateButton(parent, text, width, height, tooltipTitle, tooltipBody)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width or 120, height or 22)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(self:Unpack("surface"))
    btn.bg = bg

    local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop(BACKDROPS.border)
    border:SetBackdropBorderColor(self:Unpack("border"))
    btn.border = border

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER", 0, 0)
    label:SetText(text or "")
    label:SetTextColor(self:Unpack("subtext"))
    ApplyDefaultFont(label)
    btn.label = label

    btn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(Design:Unpack("hover"))
        self.border:SetBackdropBorderColor(Design:Unpack("primary"))
        self.label:SetTextColor(Design:Unpack("primary"))
        if self._ttTitle then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self._ttTitle, 1, 1, 1)
            if self._ttBody then
                local sr, sg, sb = Design:Unpack("subtext")
                GameTooltip:AddLine(self._ttBody, sr, sg, sb, true)
            end
            GameTooltip:Show()
        end
    end)

    btn:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(Design:Unpack("surface"))
        self.border:SetBackdropBorderColor(Design:Unpack("border"))
        self.label:SetTextColor(Design:Unpack("subtext"))
        GameTooltip:Hide()
    end)

    function btn:SetTooltip(title, body)
        self._ttTitle = title
        self._ttBody  = body
    end

    if tooltipTitle then btn:SetTooltip(tooltipTitle, tooltipBody) end

    return btn
end

Design.CreateActionButton = Design.CreateButton

function Design:CreateSectionHeader(parent, text, icon)
    local header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    header:SetHeight(32)
    self:ApplyBackdrop(header, "solid", 0.95)
    -- Section headers frame in a muted version of the theme's brand color:
    -- the primary token dimmed down, never the full-brightness or accent
    -- variant, so every addon gets its own subdued brand frame.
    header:SetBackdropBorderColor(self:Unpack("mainBorder"))

    local leftInset = 10
    if icon then
        local iconTex = header:CreateTexture(nil, "ARTWORK")
        iconTex:SetSize(16, 16)
        iconTex:SetPoint("LEFT", 8, 0)
        iconTex:SetTexture(icon)
        header.icon = iconTex
        leftInset = 30
    end

    local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", leftInset, 0)
    label:SetText(text)
    label:SetTextColor(self:Unpack("primary"))
    ApplyDefaultFont(label)
    header.label = label

    return header
end

Design.CreateHeader = Design.CreateSectionHeader

function Design:CreateDivider(parent)
    local d = parent:CreateTexture(nil, "ARTWORK")
    d:SetHeight(1)
    d:SetColorTexture(self:Unpack("border"))
    return d
end

function Design:CreateSection(parent, title, icon, opts)
    opts = opts or {}
    local section = self:CreateFrame(parent, { color = "panelAlt", square = opts.square })

    if title then
        local header = self:CreateSectionHeader(section, title, icon)
        header:SetPoint("TOPLEFT",  10, -8)
        header:SetPoint("TOPRIGHT", -10, -8)
        section.header = header
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT",     16, -42)
        section.content:SetPoint("BOTTOMRIGHT", -16,  12)
        section.contentTopInset = 42
        section.contentBottomInset = 12
    else
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT",     16, -10)
        section.content:SetPoint("BOTTOMRIGHT", -16,  10)
        section.contentTopInset = 10
        section.contentBottomInset = 10
    end

    return section
end

_G.RGXDesign = Design
RGX:RegisterModule("design", Design, { category = "library" })
