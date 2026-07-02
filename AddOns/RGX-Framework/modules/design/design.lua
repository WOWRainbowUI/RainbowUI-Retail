--=====================================================================================
-- RGX-Framework | RGXDesign
-- Visual building blocks for any RGX-Framework addon UI.
--
-- Theme tokens (addon-overridable via Design:SetTheme):
--   primary - highlight color used on labels, borders, fills, slider fills
--   accent  - secondary highlight color
--
-- Usage:
--   local Design = RGX:GetDesign()
--   Design:SetTheme({
--       primary = {0.02, 0.87, 0.98}, -- BLU cyan, for example
--       accent  = {1.00, 0.84, 0.00},
--   })
--
-- Public API:
--   Design:SetTheme(config)                       -- override theme tokens
--   Design:SetHighlightColor(color, accent)       -- shorthand for primary/accent
--   Design:GetColor(key)                          -- {r,g,b}
--   Design:Unpack(key)                            -- r, g, b for direct use
--   Design:CreateFrame(parent, opts)              -- styled backdrop frame
--   Design:CreateButton(parent, text, w, h)       -- styled action button
--   Design:CreateSectionHeader(parent, text, icon)
--   Design:CreateDivider(parent)
--   Design:CreateSection(parent, title, icon)
--   Design:ApplyBackdrop(frame, variant, bgAlpha) -- "dark"|"panel"|"solid"|"border"
--   Design:RGBToHex(r, g, b)
--=====================================================================================

local addonName, RGX = ...

local Design = {}

-- Theme tokens. Addons should override these before building UI.
Design.Theme = {
    primary = {0.345, 0.745, 0.506}, -- #58be81 RGX default green
    accent  = {0.737, 0.435, 0.659}, -- #bc6fa8 RGX default purple
}

-- Structural palette. These are the BLU/RGX dark UI foundation colors.
Design.Colors = {
    surface    = {0.050, 0.070, 0.100},
    background = {0.030, 0.040, 0.060},
    text       = {1.000, 1.000, 1.000},
    subtext    = {0.700, 0.700, 0.700},
    success    = {0.200, 0.800, 0.400},
    warning    = {1.000, 0.650, 0.000},
    error      = {1.000, 0.200, 0.200},
    border     = {0.140, 0.200, 0.280},
    hover      = {0.110, 0.180, 0.240},
    track      = {0.140, 0.200, 0.280},
}

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
    highlight    = "primary",
    accent       = "accent",
    borderActive = "primary",
}

local function IsColor(value)
    return type(value) == "table"
        and type(value[1]) == "number"
        and type(value[2]) == "number"
        and type(value[3]) == "number"
end

function Design:SetTheme(config)
    if type(config) ~= "table" then return end

    local primary = config.primary
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

Design.SetColors = Design.SetTheme
Design.UseTheme = Design.SetTheme

function Design:GetColor(key)
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

function Design:CreateFrame(parent, opts)
    opts = opts or {}
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    if opts.width  then frame:SetWidth(opts.width)   end
    if opts.height then frame:SetHeight(opts.height) end
    self:ApplyBackdrop(frame, opts.variant or "dark", opts.bgAlpha)
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

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", 0, 0)
    label:SetText(text or "")
    label:SetTextColor(self:Unpack("subtext"))
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

function Design:CreateSection(parent, title, icon)
    local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    self:ApplyBackdrop(section, "panel", 0.6)

    if title then
        local header = self:CreateSectionHeader(section, title, icon)
        header:SetPoint("TOPLEFT",  10, -8)
        header:SetPoint("TOPRIGHT", -10, -8)
        section.header = header
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT",     16, -42)
        section.content:SetPoint("BOTTOMRIGHT", -16,  12)
    else
        section.content = CreateFrame("Frame", nil, section)
        section.content:SetPoint("TOPLEFT",     16, -10)
        section.content:SetPoint("BOTTOMRIGHT", -16,  10)
    end

    return section
end

_G.RGXDesign = Design
RGX:RegisterModule("design", Design)
