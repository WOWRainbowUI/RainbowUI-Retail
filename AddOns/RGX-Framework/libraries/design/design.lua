--=====================================================================================
-- RGX-Framework | RGXDesign
-- Visual building blocks for any RGX-Framework addon UI.
--
-- Theme tokens (addon-overridable via Design:SetTheme):
--   primary - highlight color used on labels, borders, fills, slider fills
--   accent  - secondary highlight color
--
-- Visual styles (Design:SetStyle: "framework", "retail", "classic",
-- "forever") own the corner treatment and structural palette; color
-- presets (THEME_PRESETS) own primary/accent independently.
--
-- Default look: the framework style -- sleek dark navy panels with rounded
-- corners and a cyan developer accent, in the spirit of modern dev-tool
-- addon UIs.
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
    accent  = {0.737, 0.435, 0.659}, -- #bc6fa8 purple (highlights/active states)
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

-- Named visual styles. A style owns the corner treatment, the structural palette and how the shared
-- primitives (cards, section headers, buttons) are drawn; the primary/accent color presets stay
-- independent, so any style combines with any color preset. The operator's choice is persisted in
-- RGXFrameworkDB.style and re-applied on login.
--
--   framework      "RGX Framework"      the original RGX look (shipped default): square corners, dark navy.
--   materialround  "RGX Material Round" rounded cards, header bands and buttons on grey; the panel ring
--                                       is the mod's primary colour and card titles its accent colour.
--                                       A drop-in for every RGX addon, first used by RGXProfessions.
--
-- Brand colours are not part of a style: every mod defines its own primary/secondary (accent) pair when it
-- is created (SetTheme / WithTheme / a preset) and the framework pipes that pair into whichever style is
-- active, so all four styles are branded by the mod, never by the style.
--   classic        "WoW Classic"        the game's own classic frames (their cut corners, not rounded), warm stone
--                                       palette; the fallback art adds a heavier frame with an inner line.
--
--   forever        "WoW Forever"         the game's own Forever frames (their cut corners), near-black warm brown panels and
--                                       parchment text: the Forever-client look. Titles use the mod's accent colour.
--
-- An earlier release shipped a "retail" style; the id keeps working as an alias (retail -> framework) so
-- saved settings and callers do not break, but it is no longer listed.
Design.STYLE_ORDER = { "materialround", "framework", "classic", "forever" }
Design.STYLE_ALIASES = { retail = "framework" }

Design.STYLES = {
    framework = {
        label = "RGX Framework",
        cornerStyle = "square",
        buttonStyle = "square",
        headerStyle = "square",
        colors = {
            surface    = {0.086, 0.086, 0.110},
            background = {0.055, 0.055, 0.071},
            panelAlt   = {0.102, 0.102, 0.129},
            text       = {0.910, 0.910, 0.933},
            subtext    = {0.545, 0.545, 0.596},
            label      = {0.357, 0.357, 0.400},
            success    = {0.200, 0.800, 0.400},
            warning    = {0.941, 0.706, 0.161},
            error      = {0.878, 0.333, 0.333},
            border     = {0.137, 0.137, 0.173},
            ring       = {0.137, 0.137, 0.173},
            headerFill = {0.086, 0.086, 0.110},
            hover      = {0.102, 0.102, 0.129},
            track      = {0.137, 0.137, 0.173},
        },
    },
    materialround = {
        label = "RGX Material Round",
        cornerStyle = "rounded",
        buttonStyle = "rounded",
        headerStyle = "rounded",
        controlStyle = "rounded",   -- switches, sliders, text boxes, checkboxes, reset buttons and tabs are rounded too
        ringFrom = "primary",   -- panel ring and hover ring follow the mod's primary colour
        titleFrom = "accent",   -- card titles and the hover label follow the mod's accent colour
        colors = {
            surface    = {0.086, 0.086, 0.110},
            background = {0.055, 0.055, 0.071},
            panelAlt   = {0.102, 0.102, 0.129},
            text       = {0.922, 0.922, 0.941},
            subtext    = {0.620, 0.620, 0.660},
            label      = {0.357, 0.357, 0.400},
            success    = {0.300, 0.850, 0.400},
            warning    = {1.000, 0.700, 0.200},
            error      = {0.878, 0.333, 0.333},
            border     = {0.137, 0.137, 0.173},
            ring       = {0.137, 0.137, 0.173}, -- fallback only: the ring follows the primary colour
            headerFill = {0.118, 0.118, 0.149},
            hover      = {0.130, 0.130, 0.160},
            track      = {0.137, 0.137, 0.173},
        },
    },
    classic = {
        label = "WoW Classic",
        cornerStyle = "square",
        buttonStyle = "rounded",   -- buttons, header bands and controls sit on the framed panel art
        headerStyle = "rounded",
        titleFrom = "client",   -- card titles in the game's heading gold, as in the client's own windows
        frameArt = "classic",   -- the fallback art when the client lacks the Blizzard layouts below
        -- The client's classic frames: the gold-edged dialog border on windows, the tooltip border on cards, and the
        -- client's own button. Controls inside keep the client's native tick box and the flat palette controls.
        -- The gold-edged dialog border outside, the client's inset frame inside (the tooltip border on clients
        -- without it).
        blizzard = { frame = "border:dialog", card = { "InsetFrameTemplate", "border:tooltip" }, button = "panel", checkbox = "native", fillInset = 3 },
        colors = {
            surface    = {0.100, 0.090, 0.080},
            background = {0.070, 0.062, 0.054},
            panelAlt   = {0.120, 0.108, 0.094},
            text       = {0.930, 0.880, 0.780},
            subtext    = {0.600, 0.550, 0.470},
            label      = {0.420, 0.380, 0.320},
            success    = {0.200, 0.800, 0.400},
            warning    = {0.941, 0.706, 0.161},
            error      = {0.878, 0.333, 0.333},
            border     = {0.250, 0.210, 0.150},
            ring       = {0.250, 0.210, 0.150},
            headerFill = {0.100, 0.090, 0.080},
            hover      = {0.130, 0.118, 0.100},
            track      = {0.340, 0.290, 0.210},
        },
    },
    forever = {
        label = "WoW Forever",
        cornerStyle = "square",
        buttonStyle = "rounded",   -- buttons and header bands sit on the framed panel art
        headerStyle = "rounded",
        -- The client's own frames: the Forever metal dialog on windows, the inset frame on cards, and the dialog
        -- button art on buttons. Controls inside keep the client's native tick box and the flat palette controls.
        -- The client's metal window frame outside and its inset frame inside, as the Forever client's own windows
        -- are built (the dialog frame on clients without the metal frame).
        -- Layered: the window keeps the client's metal frame, and everything inside is flat panels in layers of depth
        -- derived from the mod's own brand colour (see Design:LayeredPalette), with a tinted tooltip border on cards.
        blizzard = { frame = { "ButtonFrameTemplateNoPortrait", "Dialog" }, card = { "border:tooltip", "InsetFrameTemplate" }, button = "panel", checkbox = "native", fillInset = 3 },
        layered = true,
        frameArt = "forever",   -- cut-corner panels with a bronze frame and a finer inner line, on clients without the metal frame
        titleFrom = "layered",  -- card titles in the palette's bright title tint
        colors = {
            surface    = {0.102, 0.082, 0.055},
            background = {0.078, 0.067, 0.051},
            panelAlt   = {0.125, 0.102, 0.070},
            text       = {0.941, 0.902, 0.824},
            subtext    = {0.612, 0.545, 0.416},
            label      = {0.430, 0.380, 0.290},
            success    = {0.400, 0.800, 0.350},
            warning    = {0.941, 0.706, 0.161},
            error      = {1.000, 0.353, 0.235},
            border     = {0.420, 0.330, 0.150},
            ring       = {0.420, 0.330, 0.150},
            headerFill = {0.125, 0.102, 0.070},
            hover      = {0.150, 0.122, 0.082},
            track      = {0.300, 0.240, 0.130},
        },
    },
}

-- How the active style draws the shared primitives (set by SetStyle). Direct SetCornerStyle/SetTheme
-- edits leave these alone.
Design.styleOptions = { buttonStyle = "square", headerStyle = "square", controlStyle = "square", frameArt = nil, ringFrom = nil, titleFrom = nil }

-- Current style name (nil = customized directly via SetCornerStyle/SetTheme).
Design.currentStyle = "framework"

-- Resolve a style id, following the legacy aliases. Returns the canonical id, or nil when unknown.
function Design:ResolveStyle(name)
    if type(name) ~= "string" then return nil end
    local id = (self.STYLE_ALIASES and self.STYLE_ALIASES[name]) or name
    if self.STYLES and self.STYLES[id] then return id end
    return nil
end

-- Apply a named style: corner treatment, the full structural palette and the button/header treatment.
-- Primary/accent color tokens are untouched. Styles take effect on UI built after the call; already-open
-- windows re-skin on reload (same contract as the corner selector). Legacy ids (retail, forever) are
-- accepted and GetStyle() reports the id that was set. Returns false for unknown names.
function Design:SetStyle(name)
    local id = self:ResolveStyle(name)
    local style = id and self.STYLES[id]
    if not style then return false end
    if style.cornerStyle then self.cornerStyle = style.cornerStyle end
    if type(style.colors) == "table" then
        for key, value in pairs(style.colors) do
            if type(value) == "table" then
                self.Colors[key] = { value[1], value[2], value[3] }
            end
        end
    end
    if style.layered then
        -- Layered styles derive their structural colours from the brand colour in effect now (WithTheme sets it
        -- before building), so every build, brand and live theme change gets its own layers.
        local p = self:LayeredPalette(self.Theme.primary)
        self.Colors.background = { p.frame[1], p.frame[2], p.frame[3] }
        self.Colors.surface    = { p.panel[1], p.panel[2], p.panel[3] }
        self.Colors.panelAlt   = { p.row[1], p.row[2], p.row[3] }
        self.Colors.headerFill = { p.header[1], p.header[2], p.header[3] }
        self.Colors.border     = { p.border[1], p.border[2], p.border[3] }
        self.Colors.ring       = { p.border[1], p.border[2], p.border[3] }
        self.Colors.hover      = { p.hover[1], p.hover[2], p.hover[3] }
        self.Colors.track      = { p.header[1], p.header[2], p.header[3] }
        self.Colors.text       = { p.text[1], p.text[2], p.text[3] }
        self.Colors.subtext    = { p.muted[1], p.muted[2], p.muted[3] }
        self.Colors.label      = { p.muted[1] * 0.75, p.muted[2] * 0.75, p.muted[3] * 0.75 }
    end
    self.styleOptions = {
        layered = style.layered and true or nil,
        buttonStyle = style.buttonStyle or "square",
        headerStyle = style.headerStyle or "square",
        controlStyle = style.controlStyle or "square",
        frameArt = style.frameArt,
        blizzard = style.blizzard,
        ringFrom = style.ringFrom,
        titleFrom = style.titleFrom,
    }
    self.currentStyle = name
    return true
end

function Design:GetStyle()
    return self.currentStyle
end

-- Canonical id of the active style ("framework" / "materialround" / "classic"), nil after direct edits.
function Design:GetStyleId()
    return self:ResolveStyle(self.currentStyle)
end

function Design:GetStyleLabel()
    local id = self:GetStyleId()
    return id and self.STYLES[id].label or nil
end

-- Build one addon's UI in a named style without changing the operator's global choice: applies the
-- style for fn's duration, then restores the previous style, palette and options.
--   Design:WithStyle("materialround", function() ... build windows ... end)
function Design:WithStyle(name, fn)
    if type(fn) ~= "function" then return end
    if not self:ResolveStyle(name) then
        error("RGXDesign:WithStyle unknown style '" .. tostring(name) .. "'", 2)
    end
    local prev = {
        corner = self.cornerStyle, current = self.currentStyle, options = self.styleOptions, colors = {},
    }
    for key, value in pairs(self.Colors) do prev.colors[key] = { value[1], value[2], value[3] } end
    self:SetStyle(name)
    local ok, a, b, c = pcall(fn)
    self.cornerStyle, self.currentStyle, self.styleOptions = prev.corner, prev.current, prev.options
    for key, value in pairs(prev.colors) do self.Colors[key] = value end
    if not ok then error(a, 0) end
    return a, b, c   -- the builder's results (typically the frame it built)
end

-- Corner treatment of the active style: "square" for RGX Framework (the default style), "rounded" for RGX
-- Material Round. WoW Classic and WoW Forever draw the game's own frames. Each style sets it; CreateFrame
-- honours it unless the caller passes opts.square.
Design.cornerStyle = "square"

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

-- The global override's colour pair: the operator's own primary and secondary picks (RGXFrameworkDB.themePrimary /
-- themeSecondary, {r=,g=,b=}) when set, else the chosen preset's pair. Returns { primary = {r,g,b}, accent = {r,g,b} }.
function Design:GetOverrideTheme(db)
    db = type(db) == "table" and db or rawget(_G, "RGXFrameworkDB") or {}
    local presets = self.THEME_PRESETS or {}
    local preset = presets[db.themePreset or "cyan"] or presets.cyan or {}
    local function pick(c, fallback)
        if type(c) == "table" and type(c.r) == "number" and type(c.g) == "number" and type(c.b) == "number" then
            return { c.r, c.g, c.b }
        end
        return fallback
    end
    return { primary = pick(db.themePrimary, preset.primary), accent = pick(db.themeSecondary, preset.accent) }
end

-- Apply the override's colour pair (custom picks or preset) as the live theme.
function Design:ApplyOverrideTheme(db)
    db = type(db) == "table" and db or rawget(_G, "RGXFrameworkDB") or {}
    local hasCustom = type(db.themePrimary) == "table" or type(db.themeSecondary) == "table"
    self:SetTheme(self:GetOverrideTheme(db))
    if hasCustom then self.currentPreset = nil else self.currentPreset = db.themePreset or "cyan" end
    return true
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
    ring       = {0.137, 0.137, 0.173}, -- outline of rounded panels/cards (styles may colour it)
    headerFill = {0.086, 0.086, 0.110}, -- fill of a rounded section-header band
    hover      = {0.102, 0.102, 0.129},
    track      = {0.137, 0.137, 0.173},
}

-- Rounded panel rendering -----------------------------------------------------

Design.Radius = 12
Design.PANEL_TEX = "Interface\\AddOns\\RGX-Framework\\libraries\\design\\panel_rounded.tga"
-- "WoW Forever" frame art: a square panel with cut corners (solid, tinted by the ring and fill colours) and a
-- matching one-pixel line drawn just inside the frame.
Design.FOREVER_TEX = "Interface\\AddOns\\RGX-Framework\\libraries\\design\\panel_forever.tga"
Design.FOREVER_LINE_TEX = "Interface\\AddOns\\RGX-Framework\\libraries\\design\\panel_forever_line.tga"
Design.FOREVER_SLICE = 8
-- "WoW Classic" frame art: a plain square panel with a heavier two-pixel frame and a hollow square line drawn
-- just inside it, so every card, button, box and tab reads as a double-framed square.
Design.CLASSIC_TEX = "Interface\\AddOns\\RGX-Framework\\libraries\\design\\panel_classic.tga"
Design.CLASSIC_LINE_TEX = "Interface\\AddOns\\RGX-Framework\\libraries\\design\\panel_classic_line.tga"

-- The frame-art styles, by the id a style names in `frameArt`: the solid panel texture, the inner-line texture,
-- the largest corner slice, the frame width (the fill sits this far inside the ring) and the line's inset.
local FRAME_ART = {
    forever = { tex = Design.FOREVER_TEX, line = Design.FOREVER_LINE_TEX, slice = Design.FOREVER_SLICE, frame = 1, lineInset = 3 },
    classic = { tex = Design.CLASSIC_TEX, line = Design.CLASSIC_LINE_TEX, slice = 6, frame = 2, lineInset = 4 },
}
Design.FRAME_ART = FRAME_ART

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

local function BuildNineSlice(frame, layer, slice, inset, color, alpha, texture)
    local function t()
        local tx = frame:CreateTexture(nil, layer)
        tx:SetTexture(texture or Design.PANEL_TEX)
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

-- Layered palette -------------------------------------------------------------------------------------
-- One brand colour becomes a set of surfaces in layers of depth, the way a well-built game window reads: a
-- near-black frame, panels a step lighter, a lighter header, rows darker than the panels, a bright selected row,
-- a mid-bright border, and a bright title over pale text. Every layer keeps the brand's hue; a grey brand stays
-- neutral. Pure arithmetic: the same colour always gives the same layers.
local function RgbToHsv(r, g, b)
    local mx, mn = math.max(r, g, b), math.min(r, g, b)
    local d = mx - mn
    if d == 0 then return 0, 0, mx end
    local h
    if mx == r then h = ((g - b) / d) % 6 elseif mx == g then h = (b - r) / d + 2 else h = (r - g) / d + 4 end
    return h * 60, d / mx, mx
end

local function HsvToRgb(h, s, v)
    if s <= 0 then return v, v, v end
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    local sector = math.floor(h / 60) % 6
    local r, g, b
    if sector == 0 then r, g, b = c, x, 0 elseif sector == 1 then r, g, b = x, c, 0
    elseif sector == 2 then r, g, b = 0, c, x elseif sector == 3 then r, g, b = 0, x, c
    elseif sector == 4 then r, g, b = x, 0, c else r, g, b = c, 0, x end
    return r + m, g + m, b + m
end

-- Value (brightness) and saturation factor of each layer.
local LAYERS = {
    frame       = { 0.035, 0.55 },
    row         = { 0.095, 0.60 },
    panel       = { 0.140, 0.60 },
    header      = { 0.200, 0.65 },
    hover       = { 0.260, 0.68 },
    rowSelected = { 0.360, 0.70 },
    border      = { 0.580, 0.65 },
    muted       = { 0.740, 0.15 },
    text        = { 0.940, 0.10 },
    title       = { 1.000, 0.35 },
}

function Design:LayeredPalette(primary)
    -- Accepts {r, g, b} or {r = , g = , b = }; anything else falls back to the active primary.
    if type(primary) == "table" and type(primary.r) == "number" and type(primary[1]) ~= "number" then
        primary = { primary.r, primary.g, primary.b }
    end
    if not (type(primary) == "table" and type(primary[1]) == "number" and type(primary[2]) == "number" and type(primary[3]) == "number") then
        primary = (self.Theme and self.Theme.primary) or { 0.5, 0.5, 0.5 }
    end
    local h, s0 = RgbToHsv(primary[1], primary[2], primary[3])
    local s = math.min(s0, 0.80)
    local palette = {}
    for name, layer in pairs(LAYERS) do
        local r, g, b = HsvToRgb(h, s * layer[2], layer[1])
        palette[name] = { r, g, b }
    end
    return palette
end

-- The colour of a card title for a style's titleFrom: the client's gold, the palette's title tint, or one of the
-- mod's own theme colours.
function Design:TitleColor(from)
    if from == "client" then return self.CLIENT_TITLE end
    if from == "layered" then return self:LayeredPalette(self.Theme.primary).title end
    return from and self.Theme[from] or nil
end

-- Blizzard frame assets ------------------------------------------------------------------------------
-- WoW Classic and WoW Forever draw their frames with the game client's own nine-slice art: a style names the
-- NineSliceLayouts entry for each role in `blizzard` ({ frame = "Dialog", card = "InsetFrameTemplate", ... }) and
-- the client's NineSliceUtil lays the metal or tooltip border out on the frame. A layout is used only when the
-- running client has it and every atlas it names; otherwise the style's own frame art (FRAME_ART) is drawn, so a
-- client without that art still gets a framed panel.
local function BlizzardLayoutReady(name)
    local util, layouts = _G.NineSliceUtil, _G.NineSliceLayouts
    if type(util) ~= "table" or type(util.ApplyLayout) ~= "function" then return false end
    if type(layouts) ~= "table" or type(layouts[name]) ~= "table" then return false end
    local atlasInfo = type(_G.C_Texture) == "table" and _G.C_Texture.GetAtlasInfo
    if type(atlasInfo) ~= "function" then return false end
    for _, piece in pairs(layouts[name]) do
        if type(piece) == "table" and type(piece.atlas) == "string" and not piece.atlas:find("%%s", 1, true) then
            local ok, info = pcall(atlasInfo, piece.atlas)
            if not (ok and info) then return false end
        end
    end
    return true
end

-- True when the active style draws with the client's own art (WoW Classic, WoW Forever).
function Design:UsesClientArt()
    return type((self.styleOptions or {}).blizzard) == "table"
end

-- Put a client atlas on `tex` when the running client has it; otherwise the texture file `file` (if any).
-- Returns true when the atlas was used.
function Design:SetAtlasOr(tex, atlas, file, useAtlasSize)
    local info = type(_G.C_Texture) == "table" and _G.C_Texture.GetAtlasInfo
    if atlas and type(tex.SetAtlas) == "function" and type(info) == "function" then
        local ok, found = pcall(info, atlas)
        if ok and found then tex:SetAtlas(atlas, useAtlasSize and true or false) return true end
    end
    if file then tex:SetTexture(file) end
    return false
end

-- Classic client borders, drawn from their texture files: the gold-edged dialog border and the tooltip border.
local CLIENT_BORDERS = {
    ["border:dialog"]  = { file = "Interface\\DialogFrame\\UI-DialogBox-Border", size = 24, inset = 6 },
    ["border:tooltip"] = { file = "Interface\\Tooltips\\UI-Tooltip-Border", size = 14, inset = 3 },
}

-- Draw `frame` with the active style's Blizzard layout for `role` ("frame" or "card"). Returns true when the
-- client art was applied. The pieces live on a child frame so they sit under the frame's own content, and a flat
-- fill in the style's surface colour sits behind them.
-- How far the flat fill sits inside each client frame (the metal window frame draws its edges inside the frame).
local CLIENT_FILL_INSET = { ButtonFrameTemplateNoPortrait = 2, InsetFrameTemplate = 3 }
local ROCK, MARBLE = "Interface\\FrameGeneral\\UI-Background-Rock", "Interface\\FrameGeneral\\UI-Background-Marble"
local CLIENT_BACKGROUND = {
    ButtonFrameTemplateNoPortrait = ROCK, Dialog = ROCK, ["border:dialog"] = ROCK,
    InsetFrameTemplate = MARBLE, ["border:tooltip"] = MARBLE,
}
-- The game's heading gold (titles in the client's own windows), used by the WoW styles for card titles.
Design.CLIENT_TITLE = { 1.0, 0.82, 0.0 }

function Design:ApplyBlizzardFrame(frame, role, opts)
    opts = opts or {}
    local set = (self.styleOptions or {}).blizzard
    local names = type(set) == "table" and set[role] or nil
    if not names then return false end
    -- A role may name several client frames, tried in order (the first one the client has wins).
    if type(names) == "table" then
        for _, name in ipairs(names) do
            if self:ApplyBlizzardFrameNamed(frame, name, set, opts) then return true end
        end
        return false
    end
    return self:ApplyBlizzardFrameNamed(frame, names, set, opts)
end

function Design:ApplyBlizzardFrameNamed(frame, name, set, opts)
    local container
    local edge = CLIENT_BORDERS[name]
    if edge then
        -- A classic client border drawn from its texture file as a backdrop edge (no centre).
        local ok, made = pcall(CreateFrame, "Frame", nil, frame, "BackdropTemplate")
        if not (ok and type(made) == "table" and made.SetBackdrop) then return false end
        container = made
        container:SetAllPoints(frame)
        container:SetBackdrop({ edgeFile = edge.file, edgeSize = edge.size, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        if container.SetBackdropBorderColor then
            -- A layered style tints the border with its own border layer; the others draw it as the client does.
            local tint = (self.styleOptions or {}).layered and self:GetColor("border") or nil
            if tint then container:SetBackdropBorderColor(tint[1], tint[2], tint[3], 1) else container:SetBackdropBorderColor(1, 1, 1, 1) end
        end
    else
        if not BlizzardLayoutReady(name) then return false end
        container = CreateFrame("Frame", nil, frame)
        container:SetAllPoints(frame)
        container.layoutType = name
        if not pcall(_G.NineSliceUtil.ApplyLayout, container, _G.NineSliceLayouts[name]) then return false end
        -- The layout's own centre (the tooltip layouts carry a grey one) would cover the style's surface colour;
        -- only the border is wanted.
        if type(container.Center) == "table" and container.Center.Hide then container.Center:Hide() end
    end
    if container.SetFrameLevel and frame.GetFrameLevel then container:SetFrameLevel(frame:GetFrameLevel() or 1) end
    local inset = (edge and edge.inset) or opts.fillInset or CLIENT_FILL_INSET[name] or set.fillInset or 3
    local fill = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    fill:SetPoint("TOPLEFT", frame, "TOPLEFT", inset, -inset)
    fill:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -inset, inset)
    -- A layered style fills a window with its frame layer; cards and insets keep the colour their caller asked for.
    local layered = (self.styleOptions or {}).layered
    local windowFrame = name == "ButtonFrameTemplateNoPortrait" or name == "Dialog" or name == "border:dialog"
    local color = self:GetColor(opts.color or (layered and windowFrame and "background") or "surface")
    fill:SetColorTexture(color[1], color[2], color[3], opts.bgAlpha or 1)
    -- The game's own background art over the flat colour: windows fill with the tiled rock texture and insets
    -- with the tiled marble, as the client's frame templates do. The colour shows where a client lacks the art.
    local backgroundFile = (not layered) and CLIENT_BACKGROUND[name] or nil
    if backgroundFile then
        local art = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
        art:SetPoint("TOPLEFT", fill, "TOPLEFT")
        art:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT")
        art:SetTexture(backgroundFile, "REPEAT", "REPEAT")
        if art.SetHorizTile then art:SetHorizTile(true) end
        if art.SetVertTile then art:SetVertTile(true) end
        frame._clientBackground = art
    end
    frame._blizzardFrame = container
    frame._panelBorder = {}      -- the client art is not tinted; callers that recolour a ring change nothing
    frame._panelFill = { fill }
    function frame:SetPanelColor(fillColor, _, alpha)
        if fillColor then fill:SetColorTexture(fillColor[1], fillColor[2], fillColor[3], alpha or 1) end
    end
    return true
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

-- Accept both array colours {r, g, b} (or {r, g, b, a}) and named colours
-- {r = ..., g = ..., b = ...}. Returns the stored array form, or nil when the
-- value is not a colour. Array inputs pass through by identity so callers that
-- keep referencing their own table are unaffected.
local function NormalizeColor(value)
    if type(value) ~= "table" then return nil end
    if type(value[1]) == "number" and type(value[2]) == "number" and type(value[3]) == "number" then
        return value
    end
    if type(value.r) == "number" and type(value.g) == "number" and type(value.b) == "number" then
        return { value.r, value.g, value.b }
    end
    return nil
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

    local normalizedPrimary = NormalizeColor(primary)
    local normalizedAccent = NormalizeColor(accent)
    if normalizedPrimary then self.Theme.primary = normalizedPrimary end
    if normalizedAccent then self.Theme.accent = normalizedAccent end
end

function Design:SetHighlightColor(color, accent)
    self:SetTheme({ primary = color, accent = accent })
end

Design.SetMainColor = Design.SetHighlightColor

-- Scoped theme override for one addon's UI construction without mutating the
-- shared defaults: applies the theme for fn's duration, then restores.
--   Design:WithTheme({ primary = MY_PRIMARY }, function() ... build panel ... end)
function Design:WithTheme(theme, fn)
    if type(fn) ~= "function" then return end
    local prevPrimary = self.Theme.primary
    local prevAccent = self.Theme.accent
    self:SetTheme(theme)
    local ok, a, b, c = pcall(fn)
    self.Theme.primary = prevPrimary
    self.Theme.accent = prevAccent
    if not ok then error(a, 0) end
    return a, b, c   -- the builder's results (typically the frame it built)
end

-- The global theme override (beta, RGXFrameworkDB.themeOverride == true): the framework's chosen main colour
-- preset and interface style replace every RGX addon's own pair and style. Read from the saved settings
-- directly so it answers the same before and after the framework applies them at login.
function Design:IsThemeOverride()
    local db = rawget(_G, "RGXFrameworkDB")
    return type(db) == "table" and db.themeOverride == true
end

-- What an addon should build with: its own brand pair and style, or the override's while it is on.
--   local theme, style = Design:ResolveAddonTheme({ primary = MY_RED, accent = MY_GREY }, "materialround")
-- theme is { primary = {r,g,b}, accent = {r,g,b} }; style is a canonical style id.
function Design:ResolveAddonTheme(brand, brandStyle)
    brand = type(brand) == "table" and brand or {}
    local style = brandStyle and self:ResolveStyle(brandStyle) or nil
    if not self:IsThemeOverride() then
        return { primary = brand.primary, accent = brand.accent }, style
    end
    local db = rawget(_G, "RGXFrameworkDB")
    local pair = self:GetOverrideTheme(db)
    local theme = (pair.primary or pair.accent) and { primary = pair.primary or brand.primary, accent = pair.accent or brand.accent }
        or { primary = brand.primary, accent = brand.accent }
    local chosen = type(db.style) == "string" and self:ResolveStyle(db.style) or nil
    return theme, chosen or style
end

-- Build in the resolved addon theme and style (scoped, restored afterwards). Returns the builder's results.
function Design:WithAddonTheme(brand, brandStyle, fn)
    local theme, style = self:ResolveAddonTheme(brand, brandStyle)
    return self:WithTheme(theme, function()
        if style then
            local r1, r2, r3
            self:WithStyle(style, function() r1, r2, r3 = fn() end)
            return r1, r2, r3
        end
        return fn()
    end)
end

-- ── Brands and live theme changes ────────────────────────────────────────────────────────────────────────
-- Every RGX addon registers its brand once: its own primary/accent pair and its own interface style.
--   local brand = RGXDesign:RegisterBrand("MyAddon", { primary = RED, accent = GREY }, "materialround")
-- brand:Build(fn) builds UI in the resolved theme and style (the own pair, or the framework's while the beta
-- global override is on) and remembers the brand on everything built inside it, so options panels and
-- dropdown menus can repaint themselves when the theme changes. brand:Colors() / brand:Hex(key) read the live
-- colours at paint time; brand:OnChange(fn) runs fn after every theme change (rebuild a window there).
-- The framework calls Design:NotifyThemeChanged() whenever the override, colour or style changes, so open
-- windows follow without a reload.
Design.brands = Design.brands or {}
Design._themeListeners = Design._themeListeners or {}

local BrandMixin = {}
BrandMixin.__index = BrandMixin

function BrandMixin:Resolve()
    return Design:ResolveAddonTheme(self.own, self.style)
end

function BrandMixin:Colors()
    local theme = self:Resolve()
    return theme
end

function BrandMixin:Style()
    local _, style = self:Resolve()
    return style
end

function BrandMixin:Color(key)
    local theme = self:Resolve()
    local c = theme[key or "primary"] or self.own[key or "primary"] or { 1, 1, 1 }
    return c[1], c[2], c[3]
end

function BrandMixin:Hex(key)
    local r, g, b = self:Color(key)
    return "|cff" .. Design:RGBToHex(r, g, b)
end

function BrandMixin:Build(fn)
    local prev = Design._activeBrand
    Design._activeBrand = self
    local ok, a, b, c = pcall(Design.WithAddonTheme, Design, self.own, self.style, fn)
    Design._activeBrand = prev
    if not ok then error(a, 0) end
    return a, b, c
end

function BrandMixin:OnChange(fn)
    if type(fn) == "function" then self.listeners[#self.listeners + 1] = fn end
end

function Design:RegisterBrand(id, own, style)
    assert(type(id) == "string" and id ~= "", "RGXDesign:RegisterBrand needs an addon id")
    own = type(own) == "table" and own or {}
    local brand = self.brands[id]
    if not brand then
        brand = setmetatable({ id = id, listeners = {} }, BrandMixin)
        self.brands[id] = brand
    end
    brand.own = { primary = own.primary, accent = own.accent }
    -- No style of its own means the default style, so turning the override off always has a style to return to.
    brand.style = (style and self:ResolveStyle(style)) or "framework"
    return brand
end

function Design:GetBrand(id)
    return self.brands[id]
end

-- The brand whose Build is running (nil outside one); panels and dropdowns built inside remember it.
function Design:GetBuildBrand()
    return self._activeBrand
end

-- A listener for every theme change, for UI that has no brand (the framework's own settings page).
function Design:OnThemeChanged(fn)
    if type(fn) == "function" then self._themeListeners[#self._themeListeners + 1] = fn end
end

-- Tell every brand and listener that the override, colour or style changed. Errors in one listener never stop
-- the others.
function Design:NotifyThemeChanged()
    for _, brand in pairs(self.brands) do
        for _, fn in ipairs(brand.listeners) do
            local ok, err = pcall(fn, brand)
            if not ok and _G.RGXFramework and _G.RGXFramework.Error then
                _G.RGXFramework:Error("[RGXDesign] theme change (" .. tostring(brand.id) .. "): " .. tostring(err))
            end
        end
    end
    for _, fn in ipairs(self._themeListeners) do
        local ok, err = pcall(fn)
        if not ok and _G.RGXFramework and _G.RGXFramework.Error then
            _G.RGXFramework:Error("[RGXDesign] theme change: " .. tostring(err))
        end
    end
end

Design.SetColors = Design.SetTheme
Design.UseTheme = Design.SetTheme

function Design:GetColor(key)
    -- A style may colour the panel ring from the mod's own brand colour (primary/accent), resolved live so
    -- scoped construction themes (WithTheme) are honoured.
    if key == "ring" then
        local from = self.styleOptions and self.styleOptions.ringFrom
        local themed = from and self.Theme[from]
        if themed then return themed end
    end
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
    if opts.role and self:ApplyBlizzardFrame(frame, opts.role, opts) then return frame end
    local art = FRAME_ART[(self.styleOptions or {}).frameArt or ""]
    -- With frame art the corner size is the art's, capped by the control's own radius, so a small box or
    -- chip keeps a small corner instead of the card's.
    local slice = art and math.min(art.slice, opts.radius or art.slice) or opts.radius or self.Radius
    local fill = self:GetColor(opts.color or "surface")
    local borderColor = self:GetColor(opts.borderColor or "ring")
    local fillAlpha = opts.bgAlpha
    local tex = art and art.tex or nil

    frame._panelBorder = BuildNineSlice(frame, "BACKGROUND", slice, 0, borderColor, 1, tex)
    frame._panelFill   = BuildNineSlice(frame, "BORDER", slice, art and art.frame or 1, fill, fillAlpha, tex)
    if art and (opts.line ~= false) then
        -- The inner line: the frame's second, finer outline, a lighter shade of the ring.
        local line = { math.min(1, borderColor[1] * 1.35 + 0.04), math.min(1, borderColor[2] * 1.35 + 0.04), math.min(1, borderColor[3] * 1.35 + 0.04) }
        frame._panelLine = BuildNineSlice(frame, "ARTWORK", slice, art.lineInset, line, 0.55, art.line)
    end

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

-- Shaped chrome for the interface controls. True when the active style draws switches, sliders, text boxes,
-- checkboxes, reset buttons and tabs as panels (rounded in "RGX Material Round", framed art in "WoW Forever"
-- and "WoW Classic"), not only cards, headers and buttons. The framework style keeps its flat controls.
function Design:IsRoundedControls()
    return (self.styleOptions or {}).controlStyle == "rounded"
end

-- A rounded shape (pill, box or dot) sized by `host` plus an optional inset, drawn behind the host's other
-- children. Returns the shape frame and a small adapter so a control's existing colour code (which targets
-- a texture's SetColorTexture/SetVertexColor and a backdrop's SetBackdropBorderColor) keeps working:
--   shape:SetPanelColor(fill, ring, alpha)   -- the panel API
--   adapter.fill(r, g, b, a) / adapter.ring(r, g, b)
-- opts: radius (default 6), color/borderColor (palette keys), inset = { left, top, right, bottom } (all 0),
-- parent (draw the shape in another frame, for hosts whose own textures must stay on top, such as a
-- checkbox's tick) and level (frame level, default the host's).
function Design:CreateRoundedShape(host, opts)
    opts = opts or {}
    local shape = CreateFrame("Frame", nil, opts.parent or host)
    local i = opts.inset or {}
    shape:SetPoint("TOPLEFT", host, "TOPLEFT", i[1] or 0, -(i[2] or 0))
    shape:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -(i[3] or 0), i[4] or 0)
    if shape.SetFrameLevel then
        local level = opts.level or (host.GetFrameLevel and host:GetFrameLevel()) or 1
        shape:SetFrameLevel(math.max(0, level))
    end
    self:ApplyPanel(shape, { color = opts.color or "surface", borderColor = opts.borderColor or "border",
        radius = opts.radius or 6, line = opts.line == true })
    local adapter = {
        fill = function(r, g, b, a) shape:SetPanelColor({ r, g, b }, nil, a or 1) end,
        ring = function(r, g, b) shape:SetPanelColor(nil, { r, g, b }, 1) end,
    }
    return shape, adapter
end

function Design:CreateFrame(parent, opts)
    opts = opts or {}
    -- Corner preference: an explicit opts.square wins (callers that need the
    -- legacy backdrop say so); otherwise the framework-level cornerStyle
    -- setting decides between rounded panels and square backdrops.
    if opts.square == nil then
        opts.square = self.cornerStyle == "square"
        -- A style with its own frame art draws it on its corners, instead of a flat backdrop.
        if opts.square and FRAME_ART[(self.styleOptions or {}).frameArt or ""] then opts.square = false end
    end
    if opts.square then
        local frame = CreateFrame("Frame", opts.name, parent, "BackdropTemplate")
        if opts.width  then frame:SetWidth(opts.width)   end
        if opts.height then frame:SetHeight(opts.height) end
        self:ApplyBackdrop(frame, opts.variant or "dark", opts.bgAlpha)
        if opts.color then
            frame:SetBackdropColor(self:Unpack(opts.color))
        end
        -- The same recolour API as the shaped panels, so callers never branch on the corner treatment.
        function frame:SetPanelColor(fillColor, borderColor, alpha)
            if fillColor and self.SetBackdropColor then
                self:SetBackdropColor(fillColor[1], fillColor[2], fillColor[3], alpha or 1)
            end
            if borderColor and self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 1)
            end
        end
        return frame
    end

    local frame = CreateFrame("Frame", opts.name, parent)
    if opts.width  then frame:SetWidth(opts.width)   end
    if opts.height then frame:SetHeight(opts.height) end
    if opts.role == nil then opts.role = "frame" end
    self:ApplyPanel(frame, opts)
    return frame
end

function Design:CreateButton(parent, text, width, height, tooltipTitle, tooltipBody)
    -- Styles that use the client's own button build it from the client's UIPanelButtonTemplate; a client
    -- without the template gets the dialog button textures below instead.
    local wantsNative = type((self.styleOptions or {}).blizzard) == "table" and self.styleOptions.blizzard.button == "panel"
    local btn
    if wantsNative then
        local ok, made = pcall(CreateFrame, "Button", nil, parent, "UIPanelButtonTemplate")
        if ok and type(made) == "table" then btn = made; btn._blizzardTemplate = true end
    end
    btn = btn or CreateFrame("Button", nil, parent)
    btn:SetSize(width or 120, height or 22)

    -- The active style decides the button shape. Rounded buttons ("RGX Material Round") sit on the same
    -- rounded panel as cards and light their ring on hover; they keep the btn.bg / btn.border surface that
    -- callers may touch, forwarding to the panel colours.
    local opts = self.styleOptions or {}
    local rounded = opts.buttonStyle == "rounded"
    local hoverBorderKey = rounded and "ring" or "primary"
    -- Rounded buttons fix their hover ring colour when they are built, inside the mod's own WithTheme
    -- scope: a hover happens long after construction, when the shared theme may belong to another mod.
    local hoverRing = rounded and { self:Unpack("ring") } or nil
    local titleTheme = self:TitleColor(opts.titleFrom)
    local hoverLabel = rounded and (titleTheme and { titleTheme[1], titleTheme[2], titleTheme[3] }
        or { self:Unpack("text") }) or { self:Unpack("primary") }

    -- A style with Blizzard button art draws the client's dialog button (red face, metal edge) with its own
    -- pressed, disabled and highlight states; the hover and press colours are the art's, not ours.
    local blizzardButton = type(opts.blizzard) == "table" and (opts.blizzard.button == "dialog" or opts.blizzard.button == "panel")
    local restLabel = blizzardButton and { self:Unpack("text") } or { self:Unpack("subtext") }
    if blizzardButton and btn._blizzardTemplate then
        -- The template draws the face, pressed, disabled and highlight states itself.
        btn._blizzardButton = true
        btn.bg = { SetColorTexture = function() end }
        btn.border = { SetBackdropBorderColor = function() end }
    elseif blizzardButton then
        local coords = { 0, 1, 0, 0.71875 }
        local function skin(setter, getter, path, mode)
            if type(btn[setter]) ~= "function" then return end
            btn[setter](btn, path, mode)
            local tex = type(btn[getter]) == "function" and btn[getter](btn) or nil
            if type(tex) == "table" and tex.SetTexCoord then tex:SetTexCoord(coords[1], coords[2], coords[3], coords[4]) end
        end
        skin("SetNormalTexture", "GetNormalTexture", "Interface\\Buttons\\UI-DialogBox-Button-Up")
        skin("SetPushedTexture", "GetPushedTexture", "Interface\\Buttons\\UI-DialogBox-Button-Down")
        skin("SetDisabledTexture", "GetDisabledTexture", "Interface\\Buttons\\UI-DialogBox-Button-Disabled")
        skin("SetHighlightTexture", "GetHighlightTexture", "Interface\\Buttons\\UI-DialogBox-Button-Highlight", "ADD")
        btn._blizzardButton = true
        btn.bg = { SetColorTexture = function() end }
        btn.border = { SetBackdropBorderColor = function() end }
    elseif rounded then
        self:ApplyPanel(btn, { color = "surface", borderColor = "border",
            radius = math.max(4, math.min(10, math.floor((height or 22) / 2))) })
        btn.bg = { SetColorTexture = function(_, r, g, b) btn:SetPanelColor({ r, g, b }, nil, 1) end }
        btn.border = { SetBackdropBorderColor = function(_, r, g, b) btn:SetPanelColor(nil, { r, g, b }, 1) end }
    else
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(self:Unpack("surface"))
        btn.bg = bg

        local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop(BACKDROPS.border)
        border:SetBackdropBorderColor(self:Unpack("border"))
        btn.border = border
    end

    local label = btn._blizzardTemplate and btn.GetFontString and btn:GetFontString() or nil
    if label then
        -- the template's own text, in the client's button font and colour
        btn:SetText(text or "")
    else
        label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("CENTER", 0, 0)
        label:SetText(text or "")
        label:SetTextColor(restLabel[1], restLabel[2], restLabel[3])
        ApplyDefaultFont(label)
    end
    btn.label = label
    local ownLabel = not (btn._blizzardTemplate and btn.GetFontString and btn:GetFontString())

    btn:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(Design:Unpack("hover"))
        if hoverRing then
            self.border:SetBackdropBorderColor(hoverRing[1], hoverRing[2], hoverRing[3])
        else
            self.border:SetBackdropBorderColor(Design:Unpack(hoverBorderKey))
        end
        if ownLabel or not btn._blizzardButton then self.label:SetTextColor(hoverLabel[1], hoverLabel[2], hoverLabel[3]) end
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
        if ownLabel or not btn._blizzardButton then self.label:SetTextColor(restLabel[1], restLabel[2], restLabel[3]) end
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
    local opts = self.styleOptions or {}
    local header
    if opts.layered then
        -- Layered styles: a flat band in the header layer with a one-pixel border in the border layer, title in the
        -- palette's bright tint.
        header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        header:SetHeight(32)
        header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 } })
        local fill, edge = self:GetColor("headerFill"), self:GetColor("border")
        header:SetBackdropColor(fill[1], fill[2], fill[3], 0.95)
        header:SetBackdropBorderColor(edge[1], edge[2], edge[3], 1)
        header.layeredBar = true
    elseif self.UsesClientArt and self:UsesClientArt() then
        -- WoW Classic / WoW Forever: the client's settings look. Where the client has its category header bar
        -- (the bevelled bar over each group in the game's settings list) the title sits on that bar, drawn in
        -- three slices so its ends keep their shape at any width; otherwise a title over the divider line.
        header = CreateFrame("Frame", nil, parent)
        header:SetHeight(32)
        local barAtlas = "Options_CategoryHeader_1"
        local info = type(_G.C_Texture) == "table" and type(_G.C_Texture.GetAtlasInfo) == "function"
            and select(2, pcall(_G.C_Texture.GetAtlasInfo, barAtlas)) or nil
        if type(info) == "table" and info.leftTexCoord and (info.file or info.filename) then
            local file = info.file or info.filename
            local l, r, t, b = info.leftTexCoord, info.rightTexCoord, info.topTexCoord, info.bottomTexCoord
            local cap = (r - l) * 0.12
            local function slice(u1, u2)
                local tex = header:CreateTexture(nil, "BACKGROUND")
                tex:SetTexture(file)
                tex:SetTexCoord(u1, u2, t, b)
                return tex
            end
            local left, mid, right = slice(l, l + cap), slice(l + cap, r - cap), slice(r - cap, r)
            local capW = math.floor((info.width or 175) * 0.12 + 0.5)
            left:SetPoint("TOPLEFT"); left:SetPoint("BOTTOMLEFT"); left:SetWidth(capW)
            right:SetPoint("TOPRIGHT"); right:SetPoint("BOTTOMRIGHT"); right:SetWidth(capW)
            mid:SetPoint("TOPLEFT", left, "TOPRIGHT"); mid:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
            header.bar = { left, mid, right }
            header.clientBar = true
        else
            local divider = header:CreateTexture(nil, "ARTWORK")
            divider:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
            divider:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
            divider:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
            divider:SetHeight(8)
            header.divider = divider
        end
    elseif opts.headerStyle == "rounded" then
        -- "RGX Material Round": a rounded band (grey fill, the style's ring colour) like every other card.
        header = CreateFrame("Frame", nil, parent)
        header:SetHeight(32)
        self:ApplyPanel(header, { color = "headerFill", borderColor = "ring", radius = 8 })
    else
        header = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        header:SetHeight(32)
        self:ApplyBackdrop(header, "solid", 0.95)
        -- Section headers frame in a muted version of the theme's primary color:
        -- the primary token dimmed down, never the full-brightness variant, so
        -- every addon gets a subdued frame that follows its theme.
        header:SetBackdropBorderColor(self:Unpack("mainBorder"))
    end

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
    local titleTheme = self:TitleColor(opts.titleFrom)
    if header.clientBar then titleTheme = { 1, 1, 1 } end   -- the game's header bars carry a white title
    if titleTheme then
        label:SetTextColor(titleTheme[1], titleTheme[2], titleTheme[3])
    else
        label:SetTextColor(self:Unpack("primary"))
    end
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
    local section = self:CreateFrame(parent, { color = "panelAlt", square = opts.square, role = "card" })

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
