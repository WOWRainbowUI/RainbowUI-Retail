--[[
    RGX-Framework - Modern Color Picker

    Honeycomb spectrum selector inspired by the Windows color wheel: a
    flat-top hex grid carries hue (angle) and saturation (radius), a vertical
    brightness bar sits to its right, and a row of real client class colors
    runs underneath. RGB/HEX entry and preset palettes complete the panel.

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
-- True while UpdateUI() is programmatically re-writing the HEX/RGB boxes.
-- Their OnTextChanged handlers early-return on it so a UI refresh cannot feed
-- the just-set text back through SetRGB (and recurse).
ColorPicker.suppress = false

-- Default color palettes. Class colors are intentionally NOT hardcoded here:
-- the picker renders the live client RAID_CLASS_COLORS row instead, per flavor.
ColorPicker.presets = {
    {name="Recent", colors={}},
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

-- Accepts "RRGGBB", "RGB", "#RRGGBB" and surrounding whitespace. Returns nil
-- (not 0/0/0) for anything that is not a complete hex color so callers can
-- distinguish "invalid" from "black" instead of silently clamping to black.
function ColorPicker:HexToRGB(hex)
    if type(hex) ~= "string" then return nil end
    hex = hex:gsub("%s", ""):gsub("#", ""):upper()
    if #hex == 3 then
        hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
    end
    if #hex ~= 6 or not hex:match("^%x%x%x%x%x%x$") then
        return nil
    end
    return tonumber(hex:sub(1,2), 16) / 255,
           tonumber(hex:sub(3,4), 16) / 255,
           tonumber(hex:sub(5,6), 16) / 255
end

--[[============================================================================
    UI CREATION - Modern circular controls on RGXDesign's flat dark panel.

    RGXDesign (libraries/design/design.lua) loads AFTER this file in
    RGX-Framework.xml, so RGX:GetDesign() is only safe to call lazily, inside
    functions that run at Show()-time -- never at file-parse time. Every
    builder below fetches it locally, matching the pattern already used in
    libraries/ui/controls.lua and libraries/ui/options.lua.

    Circular elements (drag handles, swatches, preview) use the same
    SetTexture(WHITE8x8) + SetMask(TempPortraitAlphaMaskSmall) technique
    already proven in libraries/minimap/minimap.lua.
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

local PANEL_W, PANEL_H = 300, 640
local CONTENT_W = PANEL_W - 40 -- 20px padding each side
local CONTENT_X = 20           -- every section top aligns to the left margin
local SPECTRUM_TOP = 46
local VALUEBAR_W, VALUEBAR_GAP = 18, 14
local BUTTON_W, BUTTON_H, BUTTON_GAP, BOTTOM_MARGIN = 80, 28, 16, 20

--[[============================================================================
    HONEYCOMB SPECTRUM

    Flat-top hexagons on an axial grid (q right, r down-right) with radius
    `rings` -> (3*rings^2 + 3*rings + 1) cells. Hue is the angle from centre
    (cyan top-left, blue top, purple right, red bottom-right, yellow bottom,
    green left) and saturation is the ring distance, so index 0 is the
    deliberately desaturated white centre. Brightness is a separate vertical
    bar: the hexagons always render at full value and are darkened by the
    selected brightness, which keeps the hue/saturation under the cursor
    readable even when the colour is black.

    These builders are file-local on purpose: the public ColorPicker method
    surface (contract/schemas/rgx-api.catalog.json) must not grow.
============================================================================]]

local HEX_FILL = "Interface\\AddOns\\RGX-Framework\\libraries\\colors\\hexmask.tga"
local HEX_RING = "Interface\\AddOns\\RGX-Framework\\libraries\\colors\\hexring.tga"
local HEX_RINGS = 4
local SQRT3 = 1.7320508

local function HexDistance(q, r)
    return (math.abs(q) + math.abs(r) + math.abs(q + r)) / 2
end

-- Cell centre in grid-local pixels, with the whole honeycomb offset so the
-- top-left cell sits at `size`/half-row rather than at the origin.
local function HexCellCenter(q, r, size, rings)
    local x = size + 1.5 * size * (q + rings)
    local y = SQRT3 * size * (r + q / 2 + rings) + SQRT3 * size / 2
    return x, y
end

-- Closest built cell by circular hue distance plus saturation distance. Used
-- for the selection outline so the marker always lands on a real cell (and
-- therefore always matches the h/s a click on it would select).
local function NearestHexCell(cells, h, s)
    -- Achromatic (s == 0) has no meaningful hue: land the marker on the neutral
    -- centre cell instead of the coloured cell whose hue happens to be closest
    -- to the retained (arbitrary) hue.
    if (s or 0) <= 0 then
        for i = 1, #cells do
            local cell = cells[i]
            if cell.q == 0 and cell.r == 0 then return cell end
        end
    end
    local best, bestCost
    for i = 1, #cells do
        local cell = cells[i]
        local dh = math.abs((h or 0) - cell.h)
        if dh > 0.5 then dh = 1 - dh end
        local cost = dh * 2 + math.abs((s or 0) - cell.s)
        if not bestCost or cost < bestCost then
            best, bestCost = cell, cost
        end
    end
    return best
end

-- Builds the honeycomb and returns a controller. `onPick(h, s)` is assigned
-- by the caller; `SetValue(h, s, v)` keeps the spectrum readable at full value
-- and moves the outline. Brightness is shown by the value bar and preview, not
-- by darkening the palette. Both the dialog and embedded picker drive the same
-- controller, so their behavior cannot drift.
local function BuildHoneycomb(parent, opts)
    local size = opts.size
    local rings = opts.rings or HEX_RINGS
    local gridW = (3 * rings + 2) * size
    local gridH = SQRT3 * size * (2 * rings + 1)

    local grid = CreateFrame("Frame", nil, parent)
    grid:SetSize(gridW, gridH)
    grid:EnableMouse(true)

    local cells = {}
    for q = -rings, rings do
        for r = -rings, rings do
            if HexDistance(q, r) <= rings then
                local cx, cy = HexCellCenter(q, r, size, rings)
                local dist = HexDistance(q, r)
                local hue = 0
                if dist > 0 then
                    local ang = math.deg(math.atan2(cy - gridH / 2, cx - gridW / 2))
                    hue = ((330 - ang) % 360) / 360
                end
                -- Each cell quad is SQUARE and centred on the cell; the padded
                -- hexagonal fill asset supplies the flat-top shape (visible
                -- height SQRT3*size inside a 2*size square), so tiling is exact
                -- without SetMask.
                local tex = grid:CreateTexture(nil, "ARTWORK")
                tex:SetSize(2 * size, 2 * size)
                tex:SetPoint("CENTER", grid, "BOTTOMLEFT", cx, cy)
                tex:SetTexture(HEX_FILL)
                cells[#cells + 1] = {
                    q = q, r = r, x = cx, y = cy,
                    h = hue, s = (rings > 0) and dist / rings or 0,
                    tex = tex,
                }
            end
        end
    end

    local marker = grid:CreateTexture(nil, "OVERLAY")
    marker:SetSize(2 * size + 6, 2 * size + 6)
    marker:SetTexture(HEX_RING)
    local mc = opts.markerColor or { 1, 1, 1 }
    marker:SetVertexColor(mc[1], mc[2], mc[3], 1)
    marker:Hide()
    grid.marker = marker

    local controller = {
        frame = grid, cells = cells, size = size, rings = rings,
        gridW = gridW, gridH = gridH, marker = marker,
    }

    function controller:SetValue(h, s, v)
        -- v is accepted for call-site symmetry but deliberately ignored for the
        -- cells: the palette stays full-value so every colour remains
        -- discoverable while the brightness bar handle and preview reflect the
        -- current value.
        for i = 1, #cells do
            local cell = cells[i]
            local cr, cg, cb = ColorPicker:HSVToRGB(cell.h, cell.s, 1)
            cell.tex:SetVertexColor(cr, cg, cb, 1)
        end
        local sel = NearestHexCell(cells, h, s)
        if sel then
            marker:ClearAllPoints()
            marker:SetPoint("CENTER", grid, "BOTTOMLEFT", sel.x, sel.y)
            marker:Show()
            controller.selected = sel
        end
    end

    local function pickFromCursor()
        local x, y = GetCursorPosition()
        local scale = grid:GetEffectiveScale() or 1
        local wx = x / scale - (grid:GetLeft() or 0)
        local wy = y / scale - (grid:GetBottom() or 0)
        local best, bestDist
        for i = 1, #cells do
            local cell = cells[i]
            local dx, dy = wx - cell.x, wy - cell.y
            local d = dx * dx + dy * dy
            if not bestDist or d < bestDist then
                best, bestDist = cell, d
            end
        end
        -- Empty grid corners are far from every cell: ignore the click
        -- instead of selecting a color that isn't displayed. Adjacent cell
        -- centres sit ~1.5 sizes apart, so a 1.5-size reach keeps real
        -- clicks (and drags across cells) working with no dead zones.
        local reach = size * 1.5
        if best and bestDist and bestDist <= reach * reach and controller.onPick then
            controller.onPick(best.h, best.s)
        end
    end

    grid:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            grid.dragging = true
            pickFromCursor()
        end
    end)
    grid:SetScript("OnMouseUp", function() grid.dragging = false end)
    grid:SetScript("OnUpdate", function()
        if not grid.dragging then return end
        if not IsMouseButtonDown or IsMouseButtonDown("LeftButton") then
            pickFromCursor()
        else
            grid.dragging = false
        end
    end)

    return controller
end

-- Vertical black -> selected-hue brightness bar. Bottom is value 0, top is
-- value 1; the handle tracks the current value.
local function BuildValueBar(parent, opts)
    local width, height = opts.width, opts.height
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetSize(width, height)
    bar:EnableMouse(true)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 1)

    local handle = bar:CreateTexture(nil, "OVERLAY")
    handle:SetSize(width + 6, 2)
    handle:SetColorTexture(0.1, 0.1, 0.12, 1)

    local controller = { frame = bar, bg = bg, handle = handle, height = height }

    -- `SetValue(h, s, v)` shades the bar from black (v=0) up to the hue at the
    -- *current* saturation (v=1), so selecting white or a pastel does not show
    -- a misleading fully-saturated gradient. The public picker API is
    -- unchanged; only this file-local controller grew a parameter.
    function controller:SetValue(h, s, v)
        local r, g, b = ColorPicker:HSVToRGB(h or 0, s or 1, 1)
        bg:SetGradient("VERTICAL", CreateColor(0, 0, 0, 1), CreateColor(r, g, b, 1))
        v = math.max(0, math.min(1, v or 0))
        handle:ClearAllPoints()
        handle:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -2, v * height - 1)
    end

    local function pickFromCursor()
        local x, y = GetCursorPosition()
        local scale = bar:GetEffectiveScale() or 1
        local v = (y / scale - (bar:GetBottom() or 0)) / height
        if controller.onPick then controller.onPick(math.max(0, math.min(1, v))) end
    end

    bar:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            bar.dragging = true
            pickFromCursor()
        end
    end)
    bar:SetScript("OnMouseUp", function() bar.dragging = false end)
    bar:SetScript("OnUpdate", function()
        if not bar.dragging then return end
        if not IsMouseButtonDown or IsMouseButtonDown("LeftButton") then
            pickFromCursor()
        else
            bar.dragging = false
        end
    end)

    return controller
end

-- Canonical playable-class order from Blizzard's `classes` list, minus the
-- non-playable ADVENTURER/TRAVELER pseudo-classes. Filtered again by whatever
-- RAID_CLASS_COLORS actually contains on this flavor, so Classic rows simply
-- show fewer swatches instead of fabricating colors.
local CLASS_ORDER = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "DEATHKNIGHT", "SHAMAN",
    "MAGE", "WARLOCK", "MONK", "DRUID", "DEMONHUNTER", "EVOKER",
}

-- Modern clients hand back a ColorMixin (GetRGB); older flavors a plain table
-- with r/g/b. Accept both.
local function ClassRGB(color)
    if not color then return nil end
    if color.GetRGB then return color:GetRGB() end
    if color.r then return color.r, color.g, color.b end
    return nil
end

-- Live class-color swatch row. Reads the real client palette at build time;
-- hides itself when RAID_CLASS_COLORS is unavailable.
local function BuildClassRow(parent, opts)
    local size = opts.size
    local pitch = opts.pitch
    local maxWidth = opts.width
    local ringColor = opts.ringColor or { 1, 1, 1 }

    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(maxWidth, 0)

    local controller = { frame = row, swatches = {}, height = 0 }

    local colors = RAID_CLASS_COLORS
    if colors then
        -- Collect the available swatches first so a short row (Classic
        -- flavors simply have fewer classes) centres instead of hugging
        -- the left margin.
        local order = {}
        for i = 1, #CLASS_ORDER do
            local r, g, b = ClassRGB(colors[CLASS_ORDER[i]])
            if r then order[#order + 1] = { r = r, g = g, b = b } end
        end
        if #order > 0 then
            local perRow = math.max(1, math.floor(maxWidth / pitch))
            local xoff = math.max(0, (maxWidth - math.min(#order, perRow) * pitch) / 2)
            local linePitch = SQRT3 * size + 4
            for _, entry in ipairs(order) do
                local r, g, b = entry.r, entry.g, entry.b
                local index = #controller.swatches
                local col = index % perRow
                local line = math.floor(index / perRow)
                local sw = CreateFrame("Button", nil, row)
                sw:SetSize(2 * size, SQRT3 * size)
                -- Anchor by line pitch only. The swatch keeps its SQRT3*size
                -- visible height, and the 4px of pitch padding lands below it,
                -- so the final line never overhangs controller.height.
                sw:SetPoint("TOPLEFT", row, "TOPLEFT", xoff + col * pitch, -(line * linePitch))

                -- Square padded fill/ring assets centred on the button keep the
                -- flat-top hexagon shape without a mask, matching the honeycomb.
                sw.tex = sw:CreateTexture(nil, "ARTWORK")
                sw.tex:SetSize(2 * size, 2 * size)
                sw.tex:SetPoint("CENTER", sw, "CENTER")
                sw.tex:SetTexture(HEX_FILL)
                sw.tex:SetVertexColor(r, g, b, 1)

                sw.ring = sw:CreateTexture(nil, "OVERLAY")
                sw.ring:SetSize(2 * size + 4, 2 * size + 4)
                sw.ring:SetPoint("CENTER", sw, "CENTER")
                sw.ring:SetTexture(HEX_RING)
                sw.ring:SetVertexColor(ringColor[1], ringColor[2], ringColor[3], 1)
                sw.ring:Hide()

                sw:SetScript("OnEnter", function(self2) self2.ring:Show() end)
                sw:SetScript("OnLeave", function(self2)
                    if controller.selected ~= self2 then self2.ring:Hide() end
                end)
                sw:SetScript("OnClick", function()
                    if controller.onPick then controller.onPick(r, g, b) end
                end)

                sw.r, sw.g, sw.b = r, g, b
                controller.swatches[#controller.swatches + 1] = sw
            end
            local lines = math.ceil(#controller.swatches / perRow)
            controller.height = lines * linePitch
            row:SetHeight(controller.height)
        end
    end

    function controller:SetSelected(r, g, b)
        -- Clear the previous selection first: otherwise a swatch that was
        -- selected and then hovered can keep its ring visible when a non-class
        -- colour is chosen (its OnLeave sees a stale controller.selected).
        controller.selected = nil
        for i = 1, #controller.swatches do
            local sw = controller.swatches[i]
            if r and math.abs(sw.r - r) < 0.001
                and math.abs(sw.g - g) < 0.001 and math.abs(sw.b - b) < 0.001 then
                sw.ring:Show()
                controller.selected = sw
            else
                sw.ring:Hide()
            end
        end
    end

    return controller
end

function ColorPicker:GetFrame()
    if self.frame then return self.frame end

    local Design = RGX:GetDesign()

    local f = CreateFrame("Frame", "RGXColorPickerDialog", UIParent, "BackdropTemplate")
    f:SetSize(PANEL_W, PANEL_H)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    Design:ApplyBackdrop(f, "dark", 0.98)
    f:Hide()
    -- Explicit outline: a 1px backdrop edge under fractional dialog scale
    -- drops sides as the frame moves, so the outline is four solid quads
    -- and the backdrop edge stays transparent.
    f:SetBackdropBorderColor(0, 0, 0, 0)
    f._borderLines = {}
    local function BorderLine(a, b, w, h)
        local t = f:CreateTexture(nil, "BORDER")
        t:SetColorTexture(1, 1, 1, 1)
        t:SetPoint(a, f, a, 0, 0)
        t:SetPoint(b, f, b, 0, 0)
        if w then t:SetWidth(w) else t:SetHeight(h) end
        f._borderLines[#f._borderLines + 1] = t
    end
    BorderLine("TOPLEFT", "TOPRIGHT", nil, 2)
    BorderLine("BOTTOMLEFT", "BOTTOMRIGHT", nil, 2)
    BorderLine("TOPLEFT", "BOTTOMLEFT", 2, nil)
    BorderLine("TOPRIGHT", "BOTTOMRIGHT", 2, nil)
    -- ESC closes the dialog like every other RGX window. The frame carries
    -- a global name so it can join the standard close-on-escape set.
    if type(UISpecialFrames) == "table" then
        table.insert(UISpecialFrames, "RGXColorPickerDialog")
    end

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

    -- === HONEYCOMB SPECTRUM + BRIGHTNESS BAR ===
    -- Both live only in this dialog; the embedded picker builds the same
    -- controllers on its own frames (see CreateEmbedded).
    f.spectrum = BuildHoneycomb(f, {
        size = 14, rings = HEX_RINGS,
        markerColor = { Design:Unpack("primary") },
    })
    -- Centre the spectrum + brightness bar as one group; every section top
    -- below aligns back to the left content margin in ApplySections.
    f.spectrumX = (PANEL_W - (f.spectrum.gridW + VALUEBAR_GAP + VALUEBAR_W)) / 2
    f.spectrum.frame:SetPoint("TOPLEFT", f, "TOPLEFT", f.spectrumX, -SPECTRUM_TOP)
    f.spectrum.onPick = function(h, s)
        self:ApplyHSV(h, s, self.current.v or 1)
    end

    f.valueBar = BuildValueBar(f, { width = VALUEBAR_W, height = f.spectrum.gridH })
    f.valueBar.frame:SetPoint("TOPLEFT", f.spectrum.frame, "TOPRIGHT", VALUEBAR_GAP, 0)
    f.valueBar.onPick = function(v)
        self:ApplyHSV(self.current.h or 0, self.current.s or 0, v)
    end

    -- === LIVE CLASS COLORS ===
    f.classLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.classLabel:SetPoint("TOPLEFT", f.spectrum.frame, "BOTTOMLEFT", 0, -12)
    f.classLabel:SetText("Class Colors")
    local clsR, clsG, clsB = Design:Unpack("subtext")
    f.classLabel:SetTextColor(clsR, clsG, clsB)

    f.classRow = BuildClassRow(f, {
        size = 9, pitch = 20, width = CONTENT_W,
        ringColor = { Design:Unpack("primary") },
    })
    f.classRow.frame:SetPoint("TOPLEFT", f.classLabel, "BOTTOMLEFT", 0, -6)
    f.classRow.onPick = function(r, g, b) self:SetRGB(r, g, b) end
    f.classGroup = { f.classLabel, f.classRow.frame }
    f.classContent = f.classLabel:GetHeight() + 6 + f.classRow.height

    -- === PREVIEW & HEX ===
    self:CreatePreview(f)

    -- === RGB INPUTS ===
    self:CreateRGBInputs(f)

    -- === PRESETS ===
    self:CreatePresets(f)

    -- === BUTTONS ===
    self:CreateButtons(f)

    -- Section table for Show(...) opts. Each entry knows the frames that make
    -- up a section, its anchor gap, and its full vertical flow (gap + content),
    -- so Show can collapse hidden sections and shrink the panel by exactly the
    -- space they consumed.
    f.sections = {
        { key = "classes", group = f.classGroup, top = f.classLabel, bottom = f.classRow.frame, gap = 12, flow = 12 + f.classContent },
        { key = "preview", group = f.previewGroup, top = f.previewRing, bottom = f.previewRing, gap = 14, flow = 14 + f.previewContent },
        { key = "rgb", group = f.rgbGroup, top = f.rgbRow, bottom = f.rgbRow, gap = 14, flow = 14 + f.rgbContent },
        { key = "presets", group = f.presetsGroup, top = f.presetsLabel, bottom = f.presetsBottom, gap = 14, flow = 14 + f.presetsContent },
    }

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
    f.previewRing:SetPoint("TOPLEFT", f.classRow.frame, "BOTTOMLEFT", 0, -14)
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
    f.hexLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.hexLabel:SetPoint("BOTTOMLEFT", f.previewRing, "TOPRIGHT", 14, -6)
    f.hexLabel:SetText("HEX")
    local sr, sg, sb = Design:Unpack("subtext")
    f.hexLabel:SetTextColor(sr, sg, sb)

    f.hexInput = CreateFrame("EditBox", nil, f, "BackdropTemplate")
    -- Width spans from the hex label (right of the 60px preview ring) to the
    -- content's right margin; use the ring size (previewSize + 4), not the raw
    -- previewSize, so it doesn't overhang the panel edge.
    f.hexInput:SetSize(CONTENT_W - (previewSize + 4) - 14, 26)
    f.hexInput:SetPoint("TOPLEFT", f.hexLabel, "BOTTOMLEFT", 0, -6)
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

    f.hexInput:SetScript("OnTextChanged", function(box)
        if ColorPicker.suppress then return end
        if #box:GetText() ~= 6 then return end
        local r, g, b = ColorPicker:HexToRGB(box:GetText())
        if r then ColorPicker:SetRGB(r, g, b) end
    end)

    f.previewGroup = { f.previewRing, f.preview, f.eyedropper, f.hexLabel, f.hexInput }
    f.previewContent = previewSize + 4
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
    f.rgbGroup = { f.rgbRow }
    f.rgbContent = f.rgbRow:GetHeight()

    for i, label in ipairs(labels) do
        local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", f.rgbRow, "TOPLEFT", (i - 1) * (colW + 10), 0)
        lbl:SetText(label)
        local sr, sg, sb = Design:Unpack("subtext")
        lbl:SetTextColor(sr, sg, sb)
        table.insert(f.rgbGroup, lbl)

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
        table.insert(f.rgbGroup, input)

        local idx = i
        input:SetScript("OnTextChanged", function(box)
            if ColorPicker.suppress then return end
            local val = tonumber(box:GetText())
            if not val then return end
            val = math.min(255, math.max(0, val)) / 255

            local c = ColorPicker.current
            if idx == 1 then c.r = val
            elseif idx == 2 then c.g = val
            else c.b = val end

            -- Recompute HSV so the honeycomb outline and brightness bar track
            -- direct RGB edits instead of going stale against the old hue.
            c.h, c.s, c.v = ColorPicker:RGBToHSV(c.r, c.g, c.b)
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
    f.presetsLabel = lbl

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
    f.presetsGroup = { lbl, rowCursor }
    local gridHeight = 0
    for _, palette in ipairs(self.presets) do
        if #palette.colors > 0 then
            local paletteFrame = CreateFrame("Frame", nil, f)
            paletteFrame:SetPoint("TOPLEFT", lastRowBottom, firstPalette and "TOPLEFT" or "BOTTOMLEFT", 0, firstPalette and 0 or -PALETTE_GAP)
            local rows = math.ceil(#palette.colors / SWATCHES_PER_ROW)
            paletteFrame:SetSize(CONTENT_W, rows * SWATCH_PITCH)
            table.insert(f.presetsGroup, paletteFrame)
            if firstPalette then
                gridHeight = rows * SWATCH_PITCH
            else
                gridHeight = gridHeight + PALETTE_GAP + rows * SWATCH_PITCH
            end

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
                table.insert(f.presetsGroup, btn)
            end

            lastRowBottom = paletteFrame
            firstPalette = false
        end
    end

    f.presetsBottom = lastRowBottom
    f.presetsContent = lbl:GetHeight() + 8 + (gridHeight > 0 and gridHeight or rowCursor:GetHeight())
end

function ColorPicker:CreateButtons(f)
    local Design = RGX:GetDesign()

    -- OK button
    f.okBtn = Design:CreateButton(f, "OK", BUTTON_W, BUTTON_H)
    f.okBtn:SetPoint("TOPRIGHT", f.presetsBottom, "BOTTOMRIGHT", 0, -BUTTON_GAP)
    f.okBtn:SetScript("OnClick", function() self:OK() end)

    -- Cancel button
    f.cancelBtn = Design:CreateButton(f, "Cancel", BUTTON_W, BUTTON_H)
    f.cancelBtn:SetPoint("RIGHT", f.okBtn, "LEFT", -10, 0)
    f.cancelBtn:SetScript("OnClick", function() self:Cancel() end)
end

-- Applies per-consumer section visibility from Show(color, callback, opts).
-- Visible section tops chain off the previous visible section but align back
-- to the left content margin (the centred spectrum is narrower than a full
-- row, so chaining left edges alone would stair-step right). The panel
-- height is derived from the visible content plus the buttons and one bottom
-- margin, so collapsed variants end exactly below OK/Cancel with no slack.
local function ApplySections(f, opts)
    opts = opts or {}
    local buttons = opts.buttons
    if buttons ~= "ok" and buttons ~= "none" then buttons = "okcancel" end
    local prev, prevX = f.spectrum.frame, f.spectrumX
    local used = SPECTRUM_TOP + f.spectrum.gridH
    for _, section in ipairs(f.sections) do
        if opts[section.key] == false then
            for _, element in ipairs(section.group) do element:Hide() end
        else
            for _, element in ipairs(section.group) do element:Show() end
            section.top:ClearAllPoints()
            section.top:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", CONTENT_X - prevX, -section.gap)
            prev, prevX = section.bottom, CONTENT_X
            used = used + section.flow
        end
    end
    if buttons == "none" then
        -- Buttonless popups end below the last visible section.
        f.okBtn:Hide()
        f.cancelBtn:Hide()
        f:SetHeight(used + BOTTOM_MARGIN)
        return
    end
    f.okBtn:Show()
    f:SetHeight(used + BUTTON_GAP + BUTTON_H + BOTTOM_MARGIN)
    f.okBtn:ClearAllPoints()
    if buttons == "ok" then
        -- A single OK sits centred; staged picks need a confirm button.
        f.cancelBtn:Hide()
        f.okBtn:SetPoint("TOPLEFT", f, "TOPLEFT", (PANEL_W - BUTTON_W) / 2, -(used + BUTTON_GAP))
        return
    end
    -- Centre the OK/Cancel pair on the panel; Cancel rides on OK's left.
    f.cancelBtn:Show()
    local okX = (PANEL_W - (BUTTON_W * 2 + 10)) / 2 + BUTTON_W + 10
    f.okBtn:SetPoint("TOPLEFT", f, "TOPLEFT", okX, -(used + BUTTON_GAP))
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

-- HSV is authoritative while picking from the picker surfaces (honeycomb,
-- brightness bar, SV box or hue bar): set h/s/v directly and derive RGB, so the
-- hue survives the grayscale edges (s=0 or v=0) where an RGB->HSV round-trip
-- would lose it. Always refreshes the UI so the preview, cursors, hex and RGB
-- inputs follow the click/drag.
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
    if not f then return end

    -- Programmatic text writes must not echo back through OnTextChanged.
    self.suppress = true
    if f.preview then f.preview:SetVertexColor(c.r, c.g, c.b, 1) end
    if f.hexInput then f.hexInput:SetText(self:RGBToHex(c.r, c.g, c.b):upper()) end
    if f.inputR then f.inputR:SetText(tostring(math.floor(c.r * 255 + 0.5))) end
    if f.inputG then f.inputG:SetText(tostring(math.floor(c.g * 255 + 0.5))) end
    if f.inputB then f.inputB:SetText(tostring(math.floor(c.b * 255 + 0.5))) end
    self.suppress = false

    -- Honeycomb keeps the selected hue/saturation outline and repaints every
    -- cell at the chosen brightness; the bar's gradient shows the pure hue.
    if f.spectrum then f.spectrum:SetValue(c.h or 0, c.s or 0, c.v or 1) end
    if f.valueBar then f.valueBar:SetValue(c.h or 0, c.s or 1, c.v or 1) end
    if f.classRow then f.classRow:SetSelected(c.r, c.g, c.b) end
end

--[[============================================================================
    PUBLIC API
============================================================================]]

function ColorPicker:Show(color, callback, opts)
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
    ApplySections(f, opts)
    -- Re-assert every Show: anything that prunes UISpecialFrames must not
    -- silently drop the dialog's ESC handling. Written without tContains
    -- so headless harnesses need no extra mock.
    if type(UISpecialFrames) == "table" then
        local listed = false
        for _, name in ipairs(UISpecialFrames) do
            if name == "RGXColorPickerDialog" then listed = true break end
        end
        if not listed then table.insert(UISpecialFrames, "RGXColorPickerDialog") end
    end
    -- Compact consumers scale the whole dialog. The frame is a
    -- singleton shared across consumers, so the scale resets every Show.
    local scale = (opts and type(opts.scale) == "number" and opts.scale > 0) and opts.scale or 1
    f:SetScale(scale)
    -- A consumer brand color outlines the dialog; otherwise the design
    -- border token returns. Accepts {r, g, b} or {r = , g = , b = }.
    local border = opts and opts.border
    local D = RGX:GetDesign()
    local br, bg, bb = D:Unpack("border")
    if type(border) == "table" then
        br = border.r or border[1] or 1
        bg = border.g or border[2] or 1
        bb = border.b or border[3] or 1
    end
    for _, line in ipairs(f._borderLines) do line:SetVertexColor(br, bg, bb, 1) end
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
    if self.frame then self.frame:Hide() end
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
    carries no dialog chrome (title/close/OK/Cancel). Same honeycomb +
    brightness-bar picking model as the dialog, so click-and-drag selects the
    shown color.

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
    -- Optional consumer brand edge, mirroring the dialog border opt. Each
    -- embedded card is its own frame, so no restore pass is needed.
    local border = opts.border
    if type(border) == "table" then
        w:SetBackdropBorderColor(border.r or border[1] or 1,
            border.g or border[2] or 1, border.b or border[3] or 1, 1)
    end

    local boxW = width - 32

    -- Honeycomb spectrum + brightness bar (same controllers as the dialog).
    local spectrum = BuildHoneycomb(w, {
        size = 10, rings = HEX_RINGS,
        markerColor = { Design:Unpack("primary") },
    })
    local barW = 14
    local innerW = spectrum.gridW + 12 + barW
    local leftPad = math.max(12, (width - innerW) / 2)
    spectrum.frame:SetPoint("TOPLEFT", w, "TOPLEFT", leftPad, -16)

    local valueBar = BuildValueBar(w, { width = barW, height = spectrum.gridH })
    valueBar.frame:SetPoint("TOPLEFT", spectrum.frame, "TOPRIGHT", 12, 0)

    -- Live class color row.
    local classLabel = w:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    classLabel:SetPoint("TOPLEFT", spectrum.frame, "BOTTOMLEFT", 0, -10)
    classLabel:SetText("Class Colors")
    local clr, clg, clb = Design:Unpack("subtext")
    classLabel:SetTextColor(clr, clg, clb)

    local classRow = BuildClassRow(w, {
        size = 8, pitch = 22, width = width - 2 * leftPad,
        ringColor = { Design:Unpack("primary") },
    })
    classRow.frame:SetPoint("TOPLEFT", classLabel, "BOTTOMLEFT", 0, -6)

    local contentH = 16 + spectrum.gridH + 10 + 14 + 6 + (classRow.height or 0) + 12 + 34 + 12
    w:SetHeight(contentH)

    -- Preview swatch + hex entry
    local previewRing = CreateCircle(w, "ARTWORK", 0, 30, Design:Unpack("border"))
    previewRing:SetPoint("TOPLEFT", classRow.frame, "BOTTOMLEFT", 0, -12)
    local preview = CreateCircle(w, "ARTWORK", 1, 26, 1, 1, 1, 1)
    preview:SetPoint("CENTER", previewRing, "CENTER")

    local hex = CreateFrame("EditBox", nil, w, "BackdropTemplate")
    -- Cap the hex width to the space between the preview and the right
    -- margin: wide cards would otherwise push it past the card edge.
    local hexStart = leftPad + 30 + 8
    hex:SetSize(math.max(1, math.min(boxW - 45, width - 8 - hexStart)), 22)
    hex:SetPoint("LEFT", preview, "RIGHT", 8, 0)
    hex:SetFontObject("GameFontNormal")
    hex:SetTextColor(1, 1, 1)
    hex:SetAutoFocus(false)
    hex:SetMaxLetters(6)
    hex:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = { left = 4, right = 4, top = 0, bottom = 0 } })
    hex:SetBackdropColor(Design:Unpack("background"))
    hex:SetBackdropBorderColor(Design:Unpack("border"))

    -- `suppress` guards the programmatic hex rewrite from re-entering
    -- OnTextChanged (and recursing through applyHSV). Initial builds call
    -- refresh() without ever writing storage or firing onChange.
    local suppress = false
    local function refresh()
        suppress = true
        preview:SetVertexColor(st.r, st.g, st.b, 1)
        hex:SetText(CP:RGBToHex(st.r, st.g, st.b):upper())
        suppress = false

        spectrum:SetValue(st.h or 0, st.s or 0, st.v or 1)
        valueBar:SetValue(st.h or 0, st.s or 1, st.v or 1)
        classRow:SetSelected(st.r, st.g, st.b)
    end

    local function applyHSV(h, s, v)
        st.h, st.s, st.v = h, s, v
        st.r, st.g, st.b = CP:HSVToRGB(h, s, v)
        refresh()
        if key then storage[key] = { r = st.r, g = st.g, b = st.b } end
        onChange(st.r, st.g, st.b)
    end

    spectrum.onPick = function(h, s) applyHSV(h, s, st.v) end
    valueBar.onPick = function(v) applyHSV(st.h, st.s, v) end
    classRow.onPick = function(r, g, b) applyHSV(CP:RGBToHSV(r, g, b)) end

    -- Hex entry. Live typing only commits once a complete six-digit value is
    -- present, so typing "FF0000" is not autoexpanded at the third character
    -- (which would leave the remaining keystrokes uneditable). Enter commits
    -- explicitly and also accepts the 3-digit shorthand; a value equal to the
    -- current colour is a no-op so Enter cannot re-fire onChange/storage.
    local function commitHex(requireSix)
        local text = hex:GetText()
        local norm = text:gsub("%s", ""):gsub("#", "")
        if requireSix and #norm ~= 6 then return end
        local r, g, b = CP:HexToRGB(text)
        if not r then return end
        if CP:RGBToHex(st.r, st.g, st.b) == CP:RGBToHex(r, g, b) then
            if not suppress then refresh() end
            return
        end
        applyHSV(CP:RGBToHSV(r, g, b))
    end
    hex:SetScript("OnEnterPressed", function(box)
        commitHex(false)
        box:ClearFocus()
    end)
    hex:SetScript("OnTextChanged", function()
        if suppress then return end
        commitHex(true)
    end)

    -- Public setter so callers can push a value in programmatically.
    function w:SetColor(r, g, b)
        local h, s, v = CP:RGBToHSV(r, g, b)
        applyHSV(h, s, v)
    end
    function w:GetColor() return st.r, st.g, st.b end

    -- Re-read the bound storage and repaint without writing it back or firing
    -- onChange, so a peer that changed storage (or a theme/selection refresh)
    -- is reflected. Called on show and available to callers.
    function w:Refresh()
        local source = (key and storage[key]) or default
        st.r, st.g, st.b = source.r or 1, source.g or 1, source.b or 1
        st.h, st.s, st.v = CP:RGBToHSV(st.r, st.g, st.b)
        refresh()
    end

    -- Position everything once geometry is valid (frames are usually hidden at
    -- build time); OnShow re-runs so the cursors land correctly on first open.
    w:SetScript("OnShow", function() w:Refresh() end)
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
    RGX:RegisterModule("colorpicker", self, { category = "library", depends = { "colors" } })
end

ColorPicker:Init()
