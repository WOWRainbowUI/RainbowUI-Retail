--[[
    RGX-Framework - Modern Color Picker
    
    Rectangular color selector inspired by Figma/Photoshop.
    Horizontal hue bar, saturation/value box, and RGB/HEX inputs.
    
    Usage:
        local CP = RGX:GetModule("colorpicker")
        CP:Show({r=1, g=0, b=0}, function(r, g, b, a)
            -- color selected
        end)
--]]

local _, ColorPicker = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX ColorPicker: RGX-Framework not loaded")
    return
end

ColorPicker.name = "colorpicker"
ColorPicker.version = "2.0.0"

-- Storage
ColorPicker.callback = nil
ColorPicker.current = {r=1, g=0, b=0, a=1}
ColorPicker.history = {}
ColorPicker.palettes = {}

-- Default color palettes
ColorPicker.presets = {
    {name="Recent", colors={}},
    {name="Class", colors={
        {r=0.77, g=0.12, b=0.23}, -- Warrior
        {r=0.96, g=0.55, b=0.73}, -- Paladin
        {r=0.67, g=0.83, b=0.45}, -- Hunter
        {r=1.00, g=0.96, b=0.41}, -- Rogue
        {r=1.00, g=1.00, b=1.00}, -- Priest
        {r=0.00, g=0.44, b=0.87}, -- Shaman
        {r=0.53, g=0.53, b=0.93}, -- Mage
        {r=0.58, g=0.51, b=0.79}, -- Warlock
        {r=1.00, g=0.49, b=0.04}, -- Monk
        {r=0.20, g=0.58, b=0.50}, -- Druid
    }},
    {name="Quality", colors={
        {r=0.61, g=0.61, b=0.61},
        {r=1.00, g=1.00, b=1.00},
        {r=0.12, g=1.00, b=0.00},
        {r=0.00, g=0.44, b=0.87},
        {r=0.64, g=0.21, b=0.93},
        {r=1.00, g=0.50, b=0.00},
    }},
    {name="Basic", colors={
        {r=1, g=0, b=0}, {r=0, g=1, b=0}, {r=0, g=0, b=1},
        {r=1, g=1, b=0}, {r=1, g=0, b=1}, {r=0, g=1, b=1},
        {r=0, g=0, b=0}, {r=1, g=1, b=1},
    }}
}

--[[============================================================================
    COLOR CONVERSIONS
============================================================================]]

function ColorPicker:RGBToHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v
    
    v = max
    local d = max - min
    s = max == 0 and 0 or d / max
    
    if max == min then
        h = 0
    else
        if max == r then h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then h = (b - r) / d + 2
        else h = (r - g) / d + 4 end
        h = h / 6
    end
    
    return h, s, v
end

function ColorPicker:HSVToRGB(h, s, v)
    local r, g, b
    
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q
    end
    
    return r, g, b
end

function ColorPicker:RGBToHex(r, g, b)
    return string.format("%02x%02x%02x",
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5))
end

function ColorPicker:HexToRGB(hex)
    hex = hex:gsub("#", "")
    if #hex == 3 then
        hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
    end
    return tonumber(hex:sub(1,2), 16) / 255,
           tonumber(hex:sub(3,4), 16) / 255,
           tonumber(hex:sub(5,6), 16) / 255
end

--[[============================================================================
    UI CREATION - Modern circular controls on RGXDesign's flat dark panel.

    RGXDesign (modules/design/design.lua) loads AFTER this file in
    RGX-Framework.xml, so RGX:GetDesign() is only safe to call lazily, inside
    functions that run at Show()-time -- never at file-parse time. Every
    builder below fetches it locally, matching the pattern already used in
    modules/ui/controls.lua and modules/ui/options.lua.

    Circular elements (drag handles, swatches, preview) use the same
    SetTexture(WHITE8x8) + SetMask(TempPortraitAlphaMaskSmall) technique
    already proven in modules/minimap/minimap.lua.
============================================================================]]

local CIRCLE_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMaskSmall"

-- Fills a texture as a solid-color circle. `layer`/`sublevel` let callers
-- stack two circles (e.g. a border ring behind a smaller fill) predictably.
local function CreateCircle(parent, layer, sublevel, size, r, g, b, a)
    local tex = parent:CreateTexture(nil, layer, nil, sublevel)
    tex:SetSize(size, size)
    tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    if tex.SetMask then
        tex:SetMask(CIRCLE_MASK)
    end
    tex:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
    return tex
end

local PANEL_W, PANEL_H = 300, 580
local CONTENT_W = PANEL_W - 40 -- 20px padding each side

function ColorPicker:GetFrame()
    if self.frame then return self.frame end

    local Design = RGX:GetDesign()

    local f = CreateFrame("Frame", "RGXColorPicker", UIParent, "BackdropTemplate")
    f:SetSize(PANEL_W, PANEL_H)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    Design:ApplyBackdrop(f, "dark", 0.98)
    f:Hide()

    -- Title
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOP", f, "TOP", 0, -14)
    f.title:SetText("Color")

    -- Close button -- small circular hover target, themed instead of a
    -- borrowed Blizzard minimize icon.
    f.close = CreateFrame("Button", nil, f)
    f.close:SetSize(22, 22)
    f.close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -12)
    f.close.bg = CreateCircle(f.close, "BACKGROUND", 0, 22, Design:Unpack("surface"))
    f.close.bg:SetPoint("CENTER")
    f.close.label = f.close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.close.label:SetPoint("CENTER", 0, 1)
    f.close.label:SetText("x")
    local sr, sg, sb = Design:Unpack("subtext")
    f.close.label:SetTextColor(sr, sg, sb)
    f.close:SetScript("OnEnter", function(btn)
        local pr, pg, pb = Design:Unpack("primary")
        btn.label:SetTextColor(pr, pg, pb)
        btn.bg:SetVertexColor(Design:Unpack("hover"))
    end)
    f.close:SetScript("OnLeave", function(btn)
        btn.label:SetTextColor(Design:Unpack("subtext"))
        btn.bg:SetVertexColor(Design:Unpack("surface"))
    end)
    f.close:SetScript("OnClick", function() self:Cancel() end)

    -- === SATURATION/VALUE BOX ===
    self:CreateSVBox(f)

    -- === HUE BAR ===
    self:CreateHueBar(f)

    -- === PREVIEW & HEX ===
    self:CreatePreview(f)

    -- === RGB INPUTS ===
    self:CreateRGBInputs(f)

    -- === PRESETS ===
    self:CreatePresets(f)

    -- === BUTTONS ===
    self:CreateButtons(f)

    -- Make draggable
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    self.frame = f
    return f
end

function ColorPicker:CreateSVBox(f)
    local Design = RGX:GetDesign()

    -- Saturation/Value box - the main gradient square
    local box = CreateFrame("Frame", nil, f, "BackdropTemplate")
    box:SetSize(CONTENT_W, 160)
    box:SetPoint("TOP", f, "TOP", 0, -46)
    box:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1
    })
    box:SetBackdropBorderColor(Design:Unpack("border"))

    -- Saturation gradient: white (left, s=0) -> pure hue color (right, s=1).
    -- Recolored reactively in UpdateUI() as the selected hue changes.
    -- SetGradient multiplies against the texture's existing content -- a bare
    -- texture with no base renders nothing, so the white base is required
    -- (same reason the value overlay below sets black before its gradient).
    box.bg = box:CreateTexture(nil, "BACKGROUND")
    box.bg:SetAllPoints()
    box.bg:SetColorTexture(1, 1, 1, 1)
    box.bg:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 0, 0, 1))

    -- Overlay gradient for value (black gradient)
    box.overlay = box:CreateTexture(nil, "ARTWORK")
    box.overlay:SetAllPoints()
    box.overlay:SetColorTexture(0, 0, 0, 1)
    -- Value overlay: opaque black at the bottom (value 0) fading to clear at the
    -- top (value 1), so "up" is brighter -- matching the mouse mapping in
    -- UpdateSVFromMouse and the cursor placement in UpdateUI.
    box.overlay:SetGradient("VERTICAL", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 0))

    -- Cursor: a white ring with a live hue-colored center, like a real
    -- picker handle instead of a borrowed minimize-button icon.
    box.cursor = CreateFrame("Frame", nil, box)
    box.cursor:SetSize(16, 16)
    box.cursorRing = CreateCircle(box.cursor, "OVERLAY", 0, 16, 1, 1, 1, 1)
    box.cursorRing:SetPoint("CENTER")
    box.cursorFill = CreateCircle(box.cursor, "OVERLAY", 1, 12, 1, 0, 0, 1)
    box.cursorFill:SetPoint("CENTER")

    -- Mouse interaction. A plain Frame ignores OnMouseDown until EnableMouse
    -- is set -- without this the SV box reads as "unclickable".
    box:EnableMouse(true)
    box:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.dragging = true
            ColorPicker:UpdateSVFromMouse(self)
        end
    end)
    box:SetScript("OnMouseUp", function(self) self.dragging = false end)
    box:SetScript("OnUpdate", function(self)
        if self.dragging then
            ColorPicker:UpdateSVFromMouse(self)
        end
    end)

    f.svBox = box
end

function ColorPicker:CreateHueBar(f)
    local Design = RGX:GetDesign()

    -- Horizontal hue rainbow bar
    local bar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    bar:SetSize(CONTENT_W, 14)
    bar:SetPoint("TOP", f.svBox, "BOTTOM", 0, -14)
    bar:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1
    })
    bar:SetBackdropBorderColor(Design:Unpack("border"))

    -- Rainbow gradient: SetGradient only does a 2-color linear blend, so a
    -- true 0-360 hue rainbow needs six segments, one per 60-degree hue stop
    -- (red->yellow->green->cyan->blue->magenta->red). This is static -- the
    -- rainbow itself never changes, only the cursor position does.
    local HUE_STOPS = {
        {1, 0, 0}, {1, 1, 0}, {0, 1, 0}, {0, 1, 1}, {0, 0, 1}, {1, 0, 1}, {1, 0, 0},
    }
    bar.segments = {}
    for i = 1, 6 do
        local seg = bar:CreateTexture(nil, "BACKGROUND")
        seg:SetPoint("TOP", bar, "TOP", 0, 0)
        seg:SetPoint("BOTTOM", bar, "BOTTOM", 0, 0)
        seg:SetPoint("LEFT", bar, "LEFT", (i - 1) / 6 * CONTENT_W, 0)
        seg:SetWidth(CONTENT_W / 6)
        -- White base required: SetGradient modulates the texture's pixels, so a
        -- bare texture renders nothing (same fix as the SV box.bg/overlay).
        seg:SetColorTexture(1, 1, 1, 1)
        local c1, c2 = HUE_STOPS[i], HUE_STOPS[i + 1]
        seg:SetGradient("HORIZONTAL", CreateColor(c1[1], c1[2], c1[3], 1), CreateColor(c2[1], c2[2], c2[3], 1))
        bar.segments[i] = seg
    end

    -- Hue cursor: a small bordered circle instead of a plain white bar, so
    -- it reads as a handle rather than a selection caret.
    bar.cursor = CreateFrame("Frame", nil, bar)
    bar.cursor:SetSize(14, 14)
    bar.cursorRing = CreateCircle(bar.cursor, "OVERLAY", 0, 14, 0.1, 0.1, 0.12, 1)
    bar.cursorRing:SetPoint("CENTER")
    bar.cursorFill = CreateCircle(bar.cursor, "OVERLAY", 1, 11, 1, 1, 1, 1)
    bar.cursorFill:SetPoint("CENTER")

    -- Mouse interaction. Same as the SV box: enable mouse so the hue bar
    -- receives clicks/drags.
    bar:EnableMouse(true)
    bar:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.dragging = true
            ColorPicker:UpdateHueFromMouse(self)
        end
    end)
    bar:SetScript("OnMouseUp", function(self) self.dragging = false end)
    bar:SetScript("OnUpdate", function(self)
        if self.dragging then
            ColorPicker:UpdateHueFromMouse(self)
        end
    end)

    f.hueBar = bar
end

function ColorPicker:CreatePreview(f)
    local Design = RGX:GetDesign()

    -- Circular current-color preview, matching the picker's circular
    -- handle/swatch vocabulary.
    local previewSize = 56
    f.previewRing = CreateCircle(f, "ARTWORK", 0, previewSize + 4, Design:Unpack("border"))
    f.previewRing:SetPoint("TOPLEFT", f.hueBar, "BOTTOMLEFT", 0, -16)
    f.preview = CreateCircle(f, "ARTWORK", 1, previewSize, 1, 0, 0, 1)
    f.preview:SetPoint("CENTER", f.previewRing, "CENTER")

    -- Eyedropper button, tucked above-right of the preview circle
    f.eyedropper = CreateFrame("Button", nil, f)
    f.eyedropper:SetSize(20, 20)
    f.eyedropper:SetPoint("BOTTOMLEFT", f.previewRing, "TOPRIGHT", -8, -4)
    f.eyedropper:SetNormalTexture("Interface\\Cursor\\CrossHair")

    f.eyedropper:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Eyedropper Tool")
        local sr, sg, sb = Design:Unpack("subtext")
        GameTooltip:AddLine("Click and drag to pick a color from screen", sr, sg, sb)
        GameTooltip:Show()
    end)
    f.eyedropper:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f.eyedropper:SetScript("OnClick", function()
        ColorPicker:StartEyedropper()
    end)

    -- HEX input, to the right of the preview circle
    local hexLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hexLabel:SetPoint("BOTTOMLEFT", f.previewRing, "TOPRIGHT", 14, -6)
    hexLabel:SetText("HEX")
    local sr, sg, sb = Design:Unpack("subtext")
    hexLabel:SetTextColor(sr, sg, sb)

    f.hexInput = CreateFrame("EditBox", nil, f, "BackdropTemplate")
    -- Width spans from the hex label (right of the 60px preview ring) to the
    -- content's right margin; use the ring size (previewSize + 4), not the raw
    -- previewSize, so it doesn't overhang the panel edge.
    f.hexInput:SetSize(CONTENT_W - (previewSize + 4) - 14, 26)
    f.hexInput:SetPoint("TOPLEFT", hexLabel, "BOTTOMLEFT", 0, -6)
    f.hexInput:SetFontObject("GameFontNormal")
    f.hexInput:SetTextColor(1, 1, 1)
    f.hexInput:SetAutoFocus(false)
    f.hexInput:SetMaxLetters(6)
    f.hexInput:SetText("FF0000")

    f.hexInput:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = {left=4, right=4, top=0, bottom=0}
    })
    f.hexInput:SetBackdropColor(Design:Unpack("background"))
    f.hexInput:SetBackdropBorderColor(Design:Unpack("border"))
    f.hexInput:SetScript("OnEditFocusGained", function(box)
        box:SetBackdropBorderColor(Design:Unpack("primary"))
    end)
    f.hexInput:SetScript("OnEditFocusLost", function(box)
        box:SetBackdropBorderColor(Design:Unpack("border"))
    end)

    f.hexInput:SetScript("OnTextChanged", function(self)
        local hex = self:GetText()
        if #hex == 6 then
            local r, g, b = ColorPicker:HexToRGB(hex)
            ColorPicker:SetRGB(r, g, b)
        end
    end)
end

function ColorPicker:CreateRGBInputs(f)
    local Design = RGX:GetDesign()
    local labels = {"R", "G", "B"}
    local colW = (CONTENT_W - 20) / 3 -- 2 gaps of 10px between 3 columns

    -- Full-width row anchored at the left content margin, below the preview
    -- circle. Anchoring to hexInput's bottom-left (indented beside the preview)
    -- but giving it full CONTENT_W width pushed the B channel off the panel's
    -- right edge and overlapped the preview -- anchor to the preview instead.
    f.rgbRow = CreateFrame("Frame", nil, f)
    f.rgbRow:SetPoint("TOPLEFT", f.previewRing, "BOTTOMLEFT", 0, -14)
    f.rgbRow:SetSize(CONTENT_W, 46)

    for i, label in ipairs(labels) do
        local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", f.rgbRow, "TOPLEFT", (i - 1) * (colW + 10), 0)
        lbl:SetText(label)
        local sr, sg, sb = Design:Unpack("subtext")
        lbl:SetTextColor(sr, sg, sb)

        local input = CreateFrame("EditBox", nil, f, "BackdropTemplate")
        input:SetSize(colW, 26)
        input:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -6)
        input:SetFontObject("GameFontNormal")
        input:SetTextColor(1, 1, 1)
        input:SetAutoFocus(false)
        input:SetMaxLetters(3)
        input:SetNumeric(true)

        input:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = {left=4, right=4, top=0, bottom=0}
        })
        input:SetBackdropColor(Design:Unpack("background"))
        input:SetBackdropBorderColor(Design:Unpack("border"))
        input:SetScript("OnEditFocusGained", function(box)
            box:SetBackdropBorderColor(Design:Unpack("primary"))
        end)
        input:SetScript("OnEditFocusLost", function(box)
            box:SetBackdropBorderColor(Design:Unpack("border"))
        end)

        input:SetText("255")

        local idx = i
        input:SetScript("OnTextChanged", function(self)
            local val = tonumber(self:GetText()) or 0
            val = math.min(255, math.max(0, val)) / 255

            local c = ColorPicker.current
            if idx == 1 then c.r = val
            elseif idx == 2 then c.g = val
            else c.b = val end

            ColorPicker:UpdateUI()
        end)

        if i == 1 then f.inputR = input
        elseif i == 2 then f.inputG = input
        else f.inputB = input end
    end
end

-- Row/column geometry for the preset swatch grid.
local SWATCH_SIZE = 20
local SWATCH_PITCH = 24  -- swatch size + 4px gap
local SWATCHES_PER_ROW = 8
local PALETTE_GAP = 8

function ColorPicker:CreatePresets(f)
    local Design = RGX:GetDesign()

    -- Preset label
    local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOPLEFT", f.rgbRow, "BOTTOMLEFT", 0, -14)
    lbl:SetText("Presets")
    local sr, sg, sb = Design:Unpack("subtext")
    lbl:SetTextColor(sr, sg, sb)

    -- Create circular color swatch buttons. Palettes with zero colors
    -- (e.g. "Recent" before anything has been picked) are skipped so they
    -- don't reserve empty vertical space.
    f.swatches = {}
    local rowCursor = CreateFrame("Frame", nil, f)
    rowCursor:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -8)
    rowCursor:SetSize(CONTENT_W, 1)
    f.presetsAnchor = rowCursor

    local lastRowBottom = rowCursor
    local firstPalette = true
    for _, palette in ipairs(self.presets) do
        if #palette.colors > 0 then
            local paletteFrame = CreateFrame("Frame", nil, f)
            paletteFrame:SetPoint("TOPLEFT", lastRowBottom, firstPalette and "TOPLEFT" or "BOTTOMLEFT", 0, firstPalette and 0 or -PALETTE_GAP)
            local rows = math.ceil(#palette.colors / SWATCHES_PER_ROW)
            paletteFrame:SetSize(CONTENT_W, rows * SWATCH_PITCH)

            for colorIdx, color in ipairs(palette.colors) do
                local col = (colorIdx - 1) % SWATCHES_PER_ROW
                local row = math.floor((colorIdx - 1) / SWATCHES_PER_ROW)

                local btn = CreateFrame("Button", nil, f)
                btn:SetSize(SWATCH_SIZE, SWATCH_SIZE)
                btn:SetPoint("TOPLEFT", paletteFrame, "TOPLEFT", col * SWATCH_PITCH, -row * SWATCH_PITCH)

                btn.hover = CreateCircle(btn, "BACKGROUND", 0, SWATCH_SIZE + 6, Design:Unpack("primary"))
                btn.hover:SetPoint("CENTER")
                btn.hover:Hide()

                btn.bg = CreateCircle(btn, "ARTWORK", 0, SWATCH_SIZE, color.r, color.g, color.b, 1)
                btn.bg:SetPoint("CENTER")

                btn:SetScript("OnEnter", function(self) self.hover:Show() end)
                btn:SetScript("OnLeave", function(self) self.hover:Hide() end)
                btn:SetScript("OnClick", function()
                    ColorPicker:SetRGB(color.r, color.g, color.b)
                end)

                table.insert(f.swatches, btn)
            end

            lastRowBottom = paletteFrame
            firstPalette = false
        end
    end

    f.presetsBottom = lastRowBottom
end

function ColorPicker:CreateButtons(f)
    local Design = RGX:GetDesign()

    -- OK button
    f.okBtn = Design:CreateButton(f, "OK", 80, 28)
    f.okBtn:SetPoint("TOPRIGHT", f.presetsBottom, "BOTTOMRIGHT", 0, -16)
    f.okBtn:SetScript("OnClick", function() self:OK() end)

    -- Cancel button
    f.cancelBtn = Design:CreateButton(f, "Cancel", 80, 28)
    f.cancelBtn:SetPoint("RIGHT", f.okBtn, "LEFT", -10, 0)
    f.cancelBtn:SetScript("OnClick", function() self:Cancel() end)
end

--[[============================================================================
    UPDATE FUNCTIONS
============================================================================]]

function ColorPicker:UpdateSVFromMouse(box)
    local x, y = GetCursorPosition()
    local scale = box:GetEffectiveScale()
    local left, bottom = box:GetLeft(), box:GetBottom()
    
    local relativeX = (x / scale - left) / box:GetWidth()
    local relativeY = (y / scale - bottom) / box:GetHeight()
    
    relativeX = math.max(0, math.min(1, relativeX))
    relativeY = math.max(0, math.min(1, relativeY))

    -- Horizontal = saturation (left 0 -> right 1), vertical = value
    -- (bottom 0 -> top 1). Keep the current hue.
    self:ApplyHSV(self.current.h or 0, relativeX, relativeY)
end

function ColorPicker:UpdateHueFromMouse(bar)
    local x = GetCursorPosition()
    local scale = bar:GetEffectiveScale()
    local left = bar:GetLeft()
    
    local relativeX = ((x / scale - left) / bar:GetWidth())
    relativeX = math.max(0, math.min(1, relativeX))

    -- Horizontal position is the hue; keep the current saturation/value.
    self:ApplyHSV(relativeX, self.current.s or 1, self.current.v or 1)
end

-- HSV is authoritative while picking from the SV box / hue bar: set h/s/v
-- directly and derive RGB, so the hue survives the grayscale edges (s=0 or
-- v=0) where an RGB->HSV round-trip would lose it. Always refreshes the UI so
-- the preview, cursors, hex and RGB inputs follow the click/drag.
function ColorPicker:ApplyHSV(h, s, v)
    self.current.h = h
    self.current.s = s
    self.current.v = v
    self.current.r, self.current.g, self.current.b = self:HSVToRGB(h, s, v)
    self:UpdateUI()
end

function ColorPicker:SetRGB(r, g, b, updateUI)
    self.current.r = r
    self.current.g = g
    self.current.b = b
    
    local h, s, v = self:RGBToHSV(r, g, b)
    self.current.h = h
    self.current.s = s
    self.current.v = v
    
    if updateUI ~= false then
        self:UpdateUI()
    end
end

function ColorPicker:UpdateUI()
    local c = self.current
    local f = self.frame
    
    -- Update preview
    f.preview:SetVertexColor(c.r, c.g, c.b, 1)
    
    -- Update hex
    f.hexInput:SetText(self:RGBToHex(c.r, c.g, c.b):upper())
    
    -- Update RGB inputs
    f.inputR:SetText(tostring(math.floor(c.r * 255 + 0.5)))
    f.inputG:SetText(tostring(math.floor(c.g * 255 + 0.5)))
    f.inputB:SetText(tostring(math.floor(c.b * 255 + 0.5)))
    
    -- Update SV box cursor position and color
    local cursorX = (c.s or 0) * f.svBox:GetWidth()
    local cursorY = (c.v or 0) * f.svBox:GetHeight()
    f.svBox.cursor:ClearAllPoints()
    f.svBox.cursor:SetPoint("CENTER", f.svBox, "BOTTOMLEFT", cursorX, cursorY)
    f.svBox.cursorFill:SetVertexColor(c.r, c.g, c.b, 1)
    
    -- Update hue bar cursor position and color
    local hueX = (c.h or 0) * f.hueBar:GetWidth()
    f.hueBar.cursor:ClearAllPoints()
    f.hueBar.cursor:SetPoint("CENTER", f.hueBar, "LEFT", hueX, 0)
    local hr, hg, hb = self:HSVToRGB(c.h or 0, 1, 1)
    f.hueBar.cursorFill:SetVertexColor(hr, hg, hb, 1)
    
    -- Recolor the SV box saturation gradient's right stop (s=1) to the
    -- currently selected pure hue; white(s=0) -> hue(s=1) stays intact.
    local hr, hg, hb = self:HSVToRGB(c.h or 0, 1, 1)
    f.svBox.bg:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(hr, hg, hb, 1))
end

--[[============================================================================
    PUBLIC API
============================================================================]]

function ColorPicker:Show(color, callback)
    self.callback = callback
    self.current = {
        r = color.r or 1,
        g = color.g or 0,
        b = color.b or 0,
        h = 0, s = 1, v = 1
    }
    
    -- Convert to HSV
    local h, s, v = self:RGBToHSV(self.current.r, self.current.g, self.current.b)
    self.current.h, self.current.s, self.current.v = h, s, v
    
    local f = self:GetFrame()
    self:UpdateUI()
    f:Show()
end

function ColorPicker:OK()
    if self.callback then
        self.callback(self.current.r, self.current.g, self.current.b, 1)
    end
    self.frame:Hide()
end

function ColorPicker:Cancel()
    self.frame:Hide()
end

function ColorPicker:AddToHistory(r, g, b)
    table.insert(self.history, 1, {r=r, g=g, b=b})
    if #self.history > 16 then table.remove(self.history) end
end

--[[============================================================================
    EMBEDDABLE WIDGET

    A self-contained color-picker card for placing directly inside an options
    tab, bound to storage[key] = {r,g,b} with an onChange(r,g,b) callback.
    Unlike Show(), it is multi-instance (its own local state, no singleton) and
    carries no dialog chrome (title/close/OK/Cancel). Same SV-box + hue-bar
    picking model as the dialog, so click-and-drag selects the shown color.

    Usage (or via UI:CreateColorPickerCard(parent, opts)):
        RGX:GetColorPicker():CreateEmbedded(parent, {
            key = "accent", storage = MyDB, default = { r = 1, g = 0, b = 0 },
            width = 220,
            onChange = function(r, g, b) MyAddon:SetAccent(r, g, b) end,
        })
============================================================================]]

function ColorPicker:CreateEmbedded(parent, opts)
    opts = opts or {}
    local CP = self
    local Design = RGX:GetDesign()
    local width   = opts.width or 220
    local key     = opts.key
    local storage = opts.storage or {}
    local default = opts.default or { r = 1, g = 1, b = 1 }
    local onChange = opts.onChange or function() end
    local boxW    = width - 40

    local init = (key and storage[key]) or default
    local st = { r = init.r or 1, g = init.g or 1, b = init.b or 1 }
    st.h, st.s, st.v = CP:RGBToHSV(st.r, st.g, st.b)

    local w = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    w:SetSize(width, 184)
    Design:ApplyBackdrop(w, "panel", 0.6)

    local boxW = width - 32

    -- Saturation/Value box
    local sv = CreateFrame("Frame", nil, w, "BackdropTemplate")
    sv:SetPoint("TOPLEFT", 16, -16)
    sv:SetSize(boxW, 96)
    sv:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    sv:SetBackdropBorderColor(Design:Unpack("border"))
    sv.bg = sv:CreateTexture(nil, "BACKGROUND")
    sv.bg:SetAllPoints()
    sv.bg:SetColorTexture(1, 1, 1, 1)
    sv.bg:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 0, 0, 1))
    sv.overlay = sv:CreateTexture(nil, "ARTWORK")
    sv.overlay:SetAllPoints()
    sv.overlay:SetColorTexture(0, 0, 0, 1)
    sv.overlay:SetGradient("VERTICAL", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 0))
    
    sv.cursor = CreateFrame("Frame", nil, sv)
    sv.cursor:SetSize(16, 16)
    sv.cursorRing = CreateCircle(sv.cursor, "OVERLAY", 0, 16, 1, 1, 1, 1)
    sv.cursorRing:SetPoint("CENTER")
    sv.cursorTex = CreateCircle(sv.cursor, "OVERLAY", 1, 12, 1, 0, 0, 1)
    sv.cursorTex:SetPoint("CENTER")

    -- Hue bar (six segments -> full 0-360 rainbow)
    local hue = CreateFrame("Frame", nil, w, "BackdropTemplate")
    hue:SetPoint("TOPLEFT", sv, "BOTTOMLEFT", 0, -8)
    hue:SetSize(boxW, 12)
    hue:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    hue:SetBackdropBorderColor(Design:Unpack("border"))
    local HUE_STOPS = { {1,0,0}, {1,1,0}, {0,1,0}, {0,1,1}, {0,0,1}, {1,0,1}, {1,0,0} }
    for i = 1, 6 do
        local seg = hue:CreateTexture(nil, "BACKGROUND")
        seg:SetPoint("TOP", hue, "TOP", 0, 0)
        seg:SetPoint("BOTTOM", hue, "BOTTOM", 0, 0)
        seg:SetPoint("LEFT", hue, "LEFT", (i - 1) / 6 * boxW, 0)
        seg:SetWidth(boxW / 6)
        seg:SetColorTexture(1, 1, 1, 1)
        local c1, c2 = HUE_STOPS[i], HUE_STOPS[i + 1]
        seg:SetGradient("HORIZONTAL", CreateColor(c1[1], c1[2], c1[3], 1), CreateColor(c2[1], c2[2], c2[3], 1))
    end
    
    hue.cursor = CreateFrame("Frame", nil, hue)
    hue.cursor:SetSize(16, 16)
    hue.cursorRing = CreateCircle(hue.cursor, "OVERLAY", 0, 16, 1, 1, 1, 1)
    hue.cursorRing:SetPoint("CENTER")
    hue.cursorTex = CreateCircle(hue.cursor, "OVERLAY", 1, 12, 1, 1, 1, 1)
    hue.cursorTex:SetPoint("CENTER")

    -- Preview swatch + hex entry
    local previewRing = CreateCircle(w, "ARTWORK", 0, 30, Design:Unpack("border"))
    previewRing:SetPoint("TOPLEFT", hue, "BOTTOMLEFT", 0, -8)
    local preview = CreateCircle(w, "ARTWORK", 1, 26, 1, 1, 1, 1)
    preview:SetPoint("CENTER", previewRing, "CENTER")

    local hex = CreateFrame("EditBox", nil, w, "BackdropTemplate")
    hex:SetSize(boxW - 34, 22)
    hex:SetPoint("LEFT", preview, "RIGHT", 8, 0)
    hex:SetFontObject("GameFontNormal")
    hex:SetTextColor(1, 1, 1)
    hex:SetAutoFocus(false)
    hex:SetMaxLetters(6)
    hex:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = { left = 4, right = 4, top = 0, bottom = 0 } })
    hex:SetBackdropColor(Design:Unpack("background"))
    hex:SetBackdropBorderColor(Design:Unpack("border"))

    local function refresh(writeHex)
        preview:SetVertexColor(st.r, st.g, st.b, 1)
        
        sv.cursor:ClearAllPoints()
        sv.cursor:SetPoint("CENTER", sv, "BOTTOMLEFT", st.s * sv:GetWidth(), st.v * sv:GetHeight())
        sv.cursorTex:SetVertexColor(st.r, st.g, st.b, 1)
        
        hue.cursor:ClearAllPoints()
        hue.cursor:SetPoint("CENTER", hue, "LEFT", st.h * hue:GetWidth(), 0)
        local hr, hg, hb = CP:HSVToRGB(st.h, 1, 1)
        hue.cursorTex:SetVertexColor(hr, hg, hb, 1)
        
        sv.bg:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(hr, hg, hb, 1))
        if writeHex ~= false then hex:SetText(CP:RGBToHex(st.r, st.g, st.b):upper()) end
    end

    local function applyHSV(h, s, v, writeHex)
        st.h, st.s, st.v = h, s, v
        st.r, st.g, st.b = CP:HSVToRGB(h, s, v)
        refresh(writeHex)
        if key then storage[key] = { r = st.r, g = st.g, b = st.b } end
        onChange(st.r, st.g, st.b)
    end

    -- SV box click + drag
    local function svFromMouse()
        local x, y = GetCursorPosition()
        local scale = sv:GetEffectiveScale()
        local rx = (x / scale - sv:GetLeft()) / sv:GetWidth()
        local ry = (y / scale - sv:GetBottom()) / sv:GetHeight()
        applyHSV(st.h, math.max(0, math.min(1, rx)), math.max(0, math.min(1, ry)))
    end
    sv:EnableMouse(true)
    sv:SetScript("OnMouseDown", function(self, btn) if btn == "LeftButton" then self.drag = true; svFromMouse() end end)
    sv:SetScript("OnMouseUp", function(self) self.drag = false end)
    sv:SetScript("OnUpdate", function(self) if self.drag then if IsMouseButtonDown("LeftButton") then svFromMouse() else self.drag = false end end end)

    -- Hue bar click + drag
    local function hueFromMouse()
        local x = GetCursorPosition()
        local scale = hue:GetEffectiveScale()
        local rx = (x / scale - hue:GetLeft()) / hue:GetWidth()
        applyHSV(math.max(0, math.min(1, rx)), st.s, st.v)
    end
    hue:EnableMouse(true)
    hue:SetScript("OnMouseDown", function(self, btn) if btn == "LeftButton" then self.drag = true; hueFromMouse() end end)
    hue:SetScript("OnMouseUp", function(self) self.drag = false end)
    hue:SetScript("OnUpdate", function(self) if self.drag then if IsMouseButtonDown("LeftButton") then hueFromMouse() else self.drag = false end end end)

    -- Hex entry
    hex:SetScript("OnEnterPressed", function(box)
        local t = box:GetText()
        if #t == 6 then
            local r, g, b = CP:HexToRGB(t)
            st.h, st.s, st.v = CP:RGBToHSV(r, g, b)
            applyHSV(st.h, st.s, st.v, false)
        end
        box:ClearFocus()
    end)

    -- Public setter so callers can push a value in programmatically.
    function w:SetColor(r, g, b)
        local h, s, v = CP:RGBToHSV(r, g, b)
        applyHSV(h, s, v)
    end
    function w:GetColor() return st.r, st.g, st.b end

    -- Position everything once geometry is valid (frames are usually hidden at
    -- build time); OnShow re-runs so the cursors land correctly on first open.
    w:SetScript("OnShow", function() refresh() end)
    refresh()

    return w
end

--[[============================================================================
    EYEDROPPER TOOL
============================================================================]]

function ColorPicker:StartEyedropper()
    -- Hide picker temporarily
    self.frame:Hide()
    
    -- Create eyedropper overlay
    if not self.dropperFrame then
        self.dropperFrame = CreateFrame("Frame", nil, UIParent)
        self.dropperFrame:SetFrameStrata("TOOLTIP")
        self.dropperFrame:SetAllPoints()
        self.dropperFrame:EnableMouse(true)
        self.dropperFrame:EnableKeyboard(true)
        
        -- Crosshair cursor
        self.dropperFrame.cursor = self.dropperFrame:CreateTexture(nil, "OVERLAY")
        self.dropperFrame.cursor:SetSize(32, 32)
        self.dropperFrame.cursor:SetTexture("Interface\\Cursor\\CrossHair")
        self.dropperFrame.cursor:SetPoint("CENTER", self.dropperFrame, "CENTER")
        
        -- Color preview box
        self.dropperFrame.preview = self.dropperFrame:CreateTexture(nil, "OVERLAY")
        self.dropperFrame.preview:SetSize(60, 60)
        self.dropperFrame.preview:SetPoint("CENTER", self.dropperFrame.cursor, "CENTER", 50, 50)
        self.dropperFrame.preview:SetColorTexture(1, 1, 1, 1)
        
        -- Preview border
        self.dropperFrame.previewBorder = self.dropperFrame:CreateTexture(nil, "OVERLAY")
        self.dropperFrame.previewBorder:SetSize(64, 64)
        self.dropperFrame.previewBorder:SetPoint("CENTER", self.dropperFrame.preview, "CENTER")
        self.dropperFrame.previewBorder:SetColorTexture(0, 0, 0, 1)
        
        -- HEX text
        self.dropperFrame.hexText = self.dropperFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.dropperFrame.hexText:SetPoint("TOP", self.dropperFrame.preview, "BOTTOM", 0, -5)
        self.dropperFrame.hexText:SetText("#FFFFFF")
        
        -- Instructions
        self.dropperFrame.instructions = self.dropperFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.dropperFrame.instructions:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 100)
        self.dropperFrame.instructions:SetText("|cffff7d00[Left Click]|r Pick Color  |  |cffff7d00[ESC]|r Cancel")
    end
    
    self.dropperFrame:Show()
    self.isDropping = true
    
    -- Set cursor
    self.oldCursor = GetCVar("cursorTexture")
    SetCVar("cursorTexture", "Interface\\Cursor\\CrossHair")
    
    -- OnUpdate for live preview
    self.dropperFrame:SetScript("OnUpdate", function()
        self:UpdateEyedropperPreview()
    end)
    
    -- Click to pick
    self.dropperFrame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            self:PickColorFromScreen()
        end
    end)
    
    -- ESC to cancel
    self.dropperFrame:SetScript("OnKeyDown", function(_, key)
        if key == "ESCAPE" then
            self:StopEyedropper()
        end
    end)
end

function ColorPicker:UpdateEyedropperPreview()
    -- Get mouse position
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    
    -- Move preview to follow cursor
    self.dropperFrame.preview:ClearAllPoints()
    self.dropperFrame.preview:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", (x / scale) + 20, (y / scale) + 20)
    
    -- Try to get color at cursor position
    -- Note: WoW doesn't have native screen pixel reading, so we approximate
    -- by checking what's under the cursor frame-wise
    local r, g, b = self:GetScreenColorAt(x, y)
    
    if r then
        self.dropperFrame.preview:SetColorTexture(r, g, b, 1)
        self.dropperFrame.hexText:SetText("#" .. self:RGBToHex(r, g, b):upper())
    end
end

function ColorPicker:GetScreenColorAt(x, y)
    -- NOTE: WoW doesn't provide direct screen pixel reading for security.
    -- This implementation samples colors from visible UI frames at the cursor position.
    -- For true screen-wide eyedropper, an external companion addon would be needed.
    
    local scale = UIParent:GetEffectiveScale()
    local uiX = x / scale
    local uiY = y / scale
    
    -- Check all visible frames
    local bestFrame = nil
    local bestLevel = 0
    
    local function checkFrame(frame)
        if not frame:IsVisible() then return end
        
        local left, bottom, width, height = frame:GetLeft(), frame:GetBottom(), frame:GetWidth(), frame:GetHeight()
        if not left then return end
        
        if uiX >= left and uiX <= left + width and uiY >= bottom and uiY <= bottom + height then
            local level = frame:GetFrameLevel()
            if level > bestLevel then
                -- Try to get color from frame's textures
                local regions = {frame:GetRegions()}
                for _, region in ipairs(regions) do
                    if region.GetVertexColor then
                        local r, g, b = region:GetVertexColor()
                        if r and r ~= 0 and g ~= 0 and b ~= 0 then
                            bestFrame = {r=r, g=g, b=b}
                            bestLevel = level
                        end
                    end
                end
            end
        end
        
        -- Check children
        for _, child in ipairs({frame:GetChildren()}) do
            checkFrame(child)
        end
    end
    
    checkFrame(UIParent)
    
    if bestFrame then
        return bestFrame.r, bestFrame.g, bestFrame.b
    end
    
    -- If no UI frame found, use the color under cursor from last known
    -- or sample from minimap/world frame if available
    return nil, nil, nil
end

-- Alternative: Built-in color sampler using existing textures
function ColorPicker:CreateTextureSampler()
    -- Creates a texture that can be sampled
    -- This allows picking from textures loaded in the UI
    local sampler = CreateFrame("Frame")
    sampler:SetSize(1, 1)
    sampler.tex = sampler:CreateTexture()
    sampler.tex:SetAllPoints()
    
    function sampler:SetTexture(path)
        self.tex:SetTexture(path)
    end
    
    function sampler:GetPixelColor(u, v)
        -- Returns approximate color at UV coordinates
        -- Note: Actual pixel reading requires render target access
        -- which WoW restricts for security
        return self.tex:GetVertexColor()
    end
    
    return sampler
end

-- Future: External companion addon for true screen sampling
-- An external .exe could:
-- 1. Read screen pixels via Windows API
-- 2. Send color to WoW via addon message
-- 3. This would be a separate optional download

function ColorPicker:PickColorFromScreen()
    local x, y = GetCursorPosition()
    local r, g, b = self:GetScreenColorAt(x, y)
    
    if r then
        self:SetRGB(r, g, b)
        self:AddToHistory(r, g, b)
    end
    
    self:StopEyedropper()
    self.frame:Show()
end

function ColorPicker:StopEyedropper()
    self.isDropping = false
    
    if self.dropperFrame then
        self.dropperFrame:Hide()
        self.dropperFrame:SetScript("OnUpdate", nil)
    end
    
    -- Restore cursor
    if self.oldCursor then
        SetCVar("cursorTexture", self.oldCursor)
    end
    
    -- Show picker again
    self.frame:Show()
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function ColorPicker:Init()
    RGX:RegisterModule("colorpicker", self)
end

ColorPicker:Init()
