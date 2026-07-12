------------------------------------------------------------
-- BliZzi Interrupts — Custom Settings Window
-- Modern dark UI with sidebar navigation, toggles,
-- color pickers, custom dropdowns.  Opened via /blizzi.
------------------------------------------------------------
local _, BIT_NS = ...
local L   -- set in Init (locale not ready at parse time)

BIT.SettingsUI = BIT.SettingsUI or {}

------------------------------------------------------------
-- ── Style constants ──────────────────────────────────────
------------------------------------------------------------
local ACCENT    = { 0, 0.75, 0.85 }      -- cyan (DEFAULT theme)
local ACCENT2   = { 0.90, 0.55, 0.10 }   -- orange (DEFAULT secondary)

-- Custom faction crests bundled with the addon (Media/alliance.tga
-- and Media/horde.tga). Extension is omitted because WoW auto-
-- resolves .tga / .blp; the prepended "Interface\\" path is the
-- standard format for SetTexture file references.
local FACTION_TEX_ALLIANCE = "Interface\\AddOns\\BliZzi_Interrupts\\Media\\alliance"
local FACTION_TEX_HORDE    = "Interface\\AddOns\\BliZzi_Interrupts\\Media\\horde"

-- Full theme palettes for the settings window. Each palette covers
-- every theme-able surface, not just the border, so the whole window
-- reads as the chosen faction (or stays in BliZzi's cyan default).
--
-- Conventions:
--   accent    — dominant colour (border, primary highlights)
--   accent2   — secondary accent (title separator, outer glow,
--               sidebar selected-state highlight)
--   bg        — main content-area background (kept dark for text
--               legibility; just a subtle tint toward the faction)
--   titleBg   — title-bar background (more visible faction colour)
--   sidebarBg — left sidebar background tint
--
-- HORDE = red with black accents. ALLIANCE = blue with white accents.
-- DEFAULT = unchanged BliZzi look (cyan + orange + dark grey backdrops).
-- Each palette specifies explicit RGBA tuples for the title-line
-- and outer glow so themes can dial those in independently of the
-- main accent colour. DEFAULT uses the same dim-cyan tone the
-- section-header dividers use (line:SetColorTexture(ACCENT, 0.3)
-- further down in this file), so the title separator matches the
-- in-page divider style and the border feel. Faction themes pick
-- a contrasting "pinstripe" colour (white for Alliance, black for
-- Horde) for the title separator so it reads as a distinct accent
-- against the strongly-coloured title bar.
-- Title-bar separator uses the same subtle grey across all themes —
-- matches the sidebar-to-content divider colour (BORDER = 0.20,0.20,
-- 0.24) so the window's internal trim feels consistent regardless of
-- the picked accent. Coloured pinstripes (white for Alliance, black
-- for Horde) read too prominently against the heavily-tinted title
-- bar; the subtle grey integrates cleanly with both the cyan default
-- look and the faction tints.
local TITLE_LINE_GREY = { 0.20, 0.20, 0.24, 1.0 }

local THEME_DEFAULT = {
    accent     = ACCENT,
    bg         = { 0.06, 0.06, 0.08 },           -- mirror of BG
    titleBg    = { 0.08, 0.08, 0.10 },
    sidebarBg  = { 0.09, 0.09, 0.11 },           -- mirror of SIDEBAR
    titleLine  = TITLE_LINE_GREY,
    glow       = { ACCENT[1] * 0.25, ACCENT[2] * 0.25, ACCENT[3] * 0.25, 0.5 },    -- faded cyan halo
    factionTex = nil,
}
local THEME_ALLIANCE = {
    accent     = { 0.20, 0.50, 0.95 },           -- bright Alliance blue (border)
    bg         = { 0.04, 0.06, 0.10 },           -- dark blue-tinted content area
    titleBg    = { 0.06, 0.11, 0.24 },           -- mid-dark blue title bar
    sidebarBg  = { 0.05, 0.07, 0.13 },           -- slight blue tint on the sidebar
    titleLine  = TITLE_LINE_GREY,
    glow       = { 0.45, 0.47, 0.50, 0.5 },      -- white halo (dimmed)
    factionTex = FACTION_TEX_ALLIANCE,
}
local THEME_HORDE = {
    accent     = { 0.85, 0.14, 0.14 },           -- bright Horde red (border)
    bg         = { 0.08, 0.03, 0.03 },           -- dark red-tinted content area
    titleBg    = { 0.22, 0.05, 0.05 },           -- mid-dark red title bar
    sidebarBg  = { 0.10, 0.04, 0.04 },           -- slight red tint on the sidebar
    titleLine  = TITLE_LINE_GREY,
    glow       = { 0.03, 0.03, 0.03, 0.5 },      -- black halo
    factionTex = FACTION_TEX_HORDE,
}

-- Resolve the user's theme preference to a concrete palette. AUTO
-- consults the player's faction once on demand — the addon doesn't
-- watch for faction changes (impossible in modern WoW anyway) so
-- the AUTO mode locks in whatever the player is at the moment the
-- window opens.
local function GetThemePalette()
    local theme = BIT.db and BIT.db.settingsTheme or "AUTO"
    if theme == "AUTO" then
        local f = UnitFactionGroup and UnitFactionGroup("player") or nil
        if f == "Alliance" then theme = "ALLIANCE"
        elseif f == "Horde" then theme = "HORDE"
        else theme = "DEFAULT" end
    end
    if theme == "ALLIANCE" then return THEME_ALLIANCE end
    if theme == "HORDE"    then return THEME_HORDE    end
    return THEME_DEFAULT
end

-- Public accessor so other modules (e.g. the Keystone List join banner)
-- can paint themselves with the same theme the settings window uses.
function BIT.SettingsUI:GetThemePalette()
    return GetThemePalette()
end
local BG        = { 0.06, 0.06, 0.08 }   -- main bg
local SIDEBAR   = { 0.09, 0.09, 0.11 }   -- sidebar bg
local WIDGET_BG = { 0.12, 0.12, 0.14 }   -- input bg
local BORDER    = { 0.20, 0.20, 0.24 }   -- subtle border
local TEXT      = { 0.90, 0.90, 0.92 }   -- primary text
local TEXT_DIM  = { 0.55, 0.55, 0.60 }   -- secondary text
local WHITE8    = "Interface\\Buttons\\WHITE8X8"

local SIDEBAR_W   = 180
local CONTENT_PAD = 16
local WIDGET_H    = 28
local SECTION_H   = 32
local GAP         = 6
local WIN_W       = 780
local WIN_H       = 560

------------------------------------------------------------
-- ── Helpers ──────────────────────────────────────────────
------------------------------------------------------------
local mainFrame, contentScroll, contentChild, sidebarBtns
local activePage = nil
local pages = {}
local _stickPreview   -- set by the interrupt page: pins its preview to the top while scrolling

local function RGB(t) return t[1], t[2], t[3] end

local function ApplyFont(fs, size, flags)
    local font = BIT.Media and BIT.Media.font or "Fonts\\FRIZQT__.TTF"
    fs:SetFont(font, size, flags or "")
end

--- Locale-safe string lookup.  Uses rawget so the metatable
--- fallback (which returns the key itself) is bypassed.
local function LS(key, fb)
    if not L then return fb end
    local v = rawget(L, key)
    return v or fb
end

-- ── Custom scrollbar skin ────────────────────────────────
-- Replaces the default arrow-button scrollbar of a
-- UIPanelScrollFrameTemplate with a slim, themed, thumb-only
-- bar. The template's own slider + arrow buttons are neutralised
-- (alpha 0, mouse off) rather than Hide()'d, so the template's
-- range-driven show logic can't bring them back. The native
-- scroll machinery (Get/SetVerticalScroll + range) is untouched —
-- we only re-skin the visible control and drive SetVerticalScroll
-- while the thumb (or empty track) is clicked.
local _themedScrollThumbs = {}   -- list of repaint() closures; ApplyTheme calls each

local function SkinScrollFrame(scrollFrame, opts)
    opts = opts or {}
    local rightOffset = opts.rightOffset or 16    -- push into the reserved gutter
    local topPad      = opts.topPad      or -6
    local bottomPad   = opts.bottomPad   or 6
    local width       = opts.width       or 6
    local minThumb    = opts.minThumb    or 30
    local baseAlpha   = opts.alpha       or 0.55

    -- Neutralise the template's built-in scrollbar + arrow buttons.
    local old = scrollFrame.ScrollBar
    if old then
        old:SetAlpha(0)
        old:EnableMouse(false)
        old:HookScript("OnShow", function(self) self:SetAlpha(0) end)
        local up, down = old.ScrollUpButton, old.ScrollDownButton
        if up   then up:SetAlpha(0);   up:EnableMouse(false)   end
        if down then down:SetAlpha(0); down:EnableMouse(false) end
    end

    -- Track: sibling of the scroll frame (never clipped by the scroll
    -- child), pinned down the reserved right-hand gutter.
    local host  = scrollFrame:GetParent() or scrollFrame
    local track = CreateFrame("Frame", nil, host)
    track:SetWidth(width)
    track:SetPoint("TOPRIGHT",    scrollFrame, "TOPRIGHT",    rightOffset, topPad)
    track:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", rightOffset, bottomPad)
    track:SetFrameLevel((scrollFrame:GetFrameLevel() or 0) + 10)

    local trackTex = track:CreateTexture(nil, "BACKGROUND")
    trackTex:SetAllPoints()
    trackTex:SetColorTexture(1, 1, 1, 0.04)

    local thumb = CreateFrame("Frame", nil, track)
    thumb:SetWidth(width)
    thumb:SetPoint("TOP", track, "TOP", 0, 0)
    thumb:EnableMouse(true)
    local thumbTex = thumb:CreateTexture(nil, "ARTWORK")
    thumbTex:SetAllPoints()

    local function repaint()
        local a = baseAlpha
        if thumb._dragging then a = 0.90 elseif thumb._hover then a = 0.78 end
        local ac = GetThemePalette().accent
        thumbTex:SetColorTexture(ac[1], ac[2], ac[3], a)
    end
    repaint()
    _themedScrollThumbs[#_themedScrollThumbs + 1] = repaint

    local function UpdateThumb()
        local range  = scrollFrame:GetVerticalScrollRange() or 0
        local trackH = track:GetHeight() or 0
        if range <= 1 or trackH <= 0 then
            thumb:Hide()
            trackTex:SetAlpha(0)
            return
        end
        trackTex:SetAlpha(1)
        thumb:Show()
        local frameH   = scrollFrame:GetHeight() or 0
        local contentH = frameH + range
        local thumbH   = (contentH > 0) and (trackH * frameH / contentH) or trackH
        if thumbH < minThumb then thumbH = minThumb end
        if thumbH > trackH   then thumbH = trackH   end
        local frac = (scrollFrame:GetVerticalScroll() or 0) / range
        if frac < 0 then frac = 0 elseif frac > 1 then frac = 1 end
        thumb:SetHeight(thumbH)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP", track, "TOP", 0, -(trackH - thumbH) * frac)
    end

    thumb:SetScript("OnEnter", function(self) self._hover = true;  repaint() end)
    thumb:SetScript("OnLeave", function(self) self._hover = false; repaint() end)
    thumb:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        self._dragging   = true
        local _, cy      = GetCursorPosition()
        self._grabCursor = cy
        self._grabScroll = scrollFrame:GetVerticalScroll() or 0
        repaint()
    end)
    thumb:SetScript("OnMouseUp", function(self) self._dragging = false; repaint() end)
    thumb:SetScript("OnUpdate", function(self)
        -- Fail-safe: if the mouse-up landed off the thumb we'd miss it.
        if self._dragging and not IsMouseButtonDown("LeftButton") then
            self._dragging = false; repaint(); return
        end
        if not self._dragging then return end
        local range  = scrollFrame:GetVerticalScrollRange() or 0
        local usable = (track:GetHeight() or 0) - (self:GetHeight() or 0)
        if range <= 0 or usable <= 0 then return end
        local scale = self:GetEffectiveScale(); if not scale or scale == 0 then scale = 1 end
        local _, cy = GetCursorPosition()
        local newScroll = self._grabScroll + ((self._grabCursor - cy) / scale / usable) * range
        if newScroll < 0 then newScroll = 0 elseif newScroll > range then newScroll = range end
        scrollFrame:SetVerticalScroll(newScroll)
    end)

    -- Click the empty track to jump toward the click point.
    track:EnableMouse(true)
    track:SetScript("OnMouseDown", function(self)
        local range = scrollFrame:GetVerticalScrollRange() or 0
        if range <= 0 then return end
        local scale = self:GetEffectiveScale(); if not scale or scale == 0 then scale = 1 end
        local _, cy = GetCursorPosition()
        local frac  = ((self:GetTop() or 0) - cy / scale) / (self:GetHeight() or 1)
        if frac < 0 then frac = 0 elseif frac > 1 then frac = 1 end
        scrollFrame:SetVerticalScroll(frac * range)
    end)

    scrollFrame:HookScript("OnVerticalScroll",     UpdateThumb)
    scrollFrame:HookScript("OnScrollRangeChanged", UpdateThumb)
    scrollFrame:HookScript("OnShow",               UpdateThumb)
    -- Safety-net poll for content-height changes that don't emit a range
    -- event; only runs while the (visible) track is shown, throttled to
    -- ~10 Hz so it costs next to nothing.
    local acc = 0
    track:HookScript("OnUpdate", function(_, e)
        acc = acc + (e or 0)
        if acc < 0.1 then return end
        acc = 0
        UpdateThumb()
    end)

    UpdateThumb()
    return track, thumb
end

--- Build dropdown option list from a BIT.Media:GetAvailable*() list.
--- Each entry has .name (display string) used as both value and label.
--- `previewKind` adds a live preview to each option:
---   * "font"   — renders every name in its own typeface (Font dropdown)
---   * "bar"    — renders a small bar swatch using the option's texture
---                path next to the name (Bar Texture dropdown)
---   * "border" — renders a small bordered frame using the option's
---                edge texture as a live preview (Border dropdown).
---                "None" has no path and is skipped automatically.
---   * "sound"  — adds a click-to-play speaker button next to the name
---                (Kick Success / Kick Failed sound dropdowns). The
---                "None" entry has no file and is skipped.
local function MediaOpts(getListFn, previewKind)
    local opts = {}
    if BIT.Media and getListFn then
        for _, e in ipairs(getListFn()) do
            local opt = { value = e.name, label = e.name }
            if previewKind == "font" and e.path and e.path ~= "" then
                opt.font = e.path
            elseif previewKind == "bar" and e.path and e.path ~= "" then
                opt.barTexture = e.path
            elseif previewKind == "border" and e.path and e.path ~= "" then
                opt.borderTextureEdge = e.path
                -- Carry minSize so the preview can pick a sane edgeSize
                -- for decorative textures (Dialog, Achievement Wood …)
                -- that need more pixels to render readably.
                opt.borderMinSize = e.minSize or 8
            elseif previewKind == "sound" and e.file and e.file ~= "" then
                opt.sound = true
            end
            opts[#opts+1] = opt
        end
    end
    return opts
end

local function MakeBg(f, r, g, b, a)
    f:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1,
                     insets = { left = 1, right = 1, top = 1, bottom = 1 } })
    f:SetBackdropColor(r, g, b, a or 0.95)
    f:SetBackdropBorderColor(RGB(BORDER))
end

local function Refresh()
    if activePage and pages[activePage] and pages[activePage].refresh then
        pages[activePage].refresh()
    end
    -- Rebuild the interrupt tracker bars (handles size, font, color, layout changes)
    if BIT.UI then
        if BIT.UI.RebuildBars then BIT.UI:RebuildBars() end
        if BIT.UI.CheckZoneVisibility then BIT.UI:CheckZoneVisibility() end
    end
    -- Rebuild party CD tracker (Rebuild() debounces internally at 50ms)
    if BIT.SyncCD and BIT.SyncCD.Rebuild then
        BIT.SyncCD:Rebuild()
    end
    -- Apply frame scale
    if BIT.UI and BIT.UI.mainFrame and BIT.db then
        BIT.UI.mainFrame:SetScale((BIT.db.frameScale or 100) / 100)
    end
end

------------------------------------------------------------
-- ── Widget Factory ───────────────────────────────────────
------------------------------------------------------------

-- Reusable pool for dropdown popups
local dropdownPopup

------------------------------------------------------------
-- Toggle (modern switch)
------------------------------------------------------------
-- `iconTexture` is optional. When provided, a 16×16 icon is inserted
-- between the toggle track and the label (used for the per-spell rows
-- on the PI Caller settings page).
-- suppressHint (8th arg): when true, skip the "Under Construction" hint
-- text that's normally rendered next to a disabled toggle. Used by the
-- class-gated Smart Misdirect page where the toggles are greyed out
-- because the feature doesn't apply to the current class — not because
-- the feature itself is under construction. Default behaviour (no value
-- passed) keeps the hint visible, matching the PI Caller
-- developer-disabled pages.
local function CreateToggle(parent, label, getter, setter, indent, disabled, iconTexture, suppressHint)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(parent:GetWidth() - CONTENT_PAD * 2, WIDGET_H)

    -- track
    local track = CreateFrame("Frame", nil, f, "BackdropTemplate")
    track:SetSize(36, 18)
    track:SetPoint("LEFT", indent or 0, 0)
    MakeBg(track, 0.18, 0.18, 0.20, 1)

    -- thumb
    local thumb = track:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(14, 14)
    thumb:SetColorTexture(RGB(ACCENT))

    local function UpdateVisual()
        if disabled then
            thumb:ClearAllPoints()
            thumb:SetPoint("LEFT", track, "LEFT", 2, 0)
            thumb:SetColorTexture(0.3, 0.3, 0.3)
            track:SetBackdropColor(0.12, 0.12, 0.13, 1)
            return
        end
        local on = getter()
        if on then
            thumb:ClearAllPoints()
            thumb:SetPoint("LEFT", track, "LEFT", 20, 0)
            thumb:SetColorTexture(RGB(ACCENT))
            track:SetBackdropColor(ACCENT[1] * 0.3, ACCENT[2] * 0.3, ACCENT[3] * 0.3, 1)
        else
            thumb:ClearAllPoints()
            thumb:SetPoint("LEFT", track, "LEFT", 2, 0)
            thumb:SetColorTexture(0.45, 0.45, 0.48)
            track:SetBackdropColor(0.18, 0.18, 0.20, 1)
        end
    end
    UpdateVisual()

    -- click
    if not disabled then
        track:EnableMouse(true)
        track:SetScript("OnMouseDown", function()
            setter(not getter())
            UpdateVisual()
            Refresh()
        end)
    end

    -- optional icon (e.g. spell texture for per-spell PI Caller rows)
    local labelOffsetX = 8
    if iconTexture then
        local ico = f:CreateTexture(nil, "OVERLAY")
        ico:SetSize(16, 16)
        ico:SetPoint("LEFT", track, "RIGHT", 6, 0)
        ico:SetTexture(iconTexture)
        ico:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        labelOffsetX = 6 + 16 + 4   -- track-gap + icon-width + label-gap
    end
    -- label
    local lbl = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, 12)
    lbl:SetPoint("LEFT", track, "RIGHT", labelOffsetX, 0)
    if disabled then
        lbl:SetTextColor(0.4, 0.4, 0.4)
    else
        lbl:SetTextColor(RGB(TEXT))
    end
    lbl:SetText(label)

    -- "Under Construction" hint for disabled toggles. Skipped when the
    -- caller passes suppressHint=true (e.g. class-gated pages where the
    -- toggles are inactive for a different reason than "feature is being
    -- worked on" — see Smart Misdirect).
    if disabled and not suppressHint then
        local hint = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(hint, 10)
        hint:SetPoint("RIGHT", f, "RIGHT", 0, 0)
        hint:SetJustifyH("RIGHT")
        hint:SetText("|cffff8800Under Construction|r")
    end

    f._update = UpdateVisual
    f._searchLabel = label
    f._searchKind  = "toggle"
    return f
end

------------------------------------------------------------
-- Slider
------------------------------------------------------------
local function CreateSlider(parent, label, minV, maxV, step, getter, setter, fmt)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(parent:GetWidth() - CONTENT_PAD * 2, WIDGET_H + 4)

    local lbl = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, 11)
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetTextColor(RGB(TEXT_DIM))
    lbl:SetText(label)

    -- value text
    local valTxt = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(valTxt, 11)
    valTxt:SetPoint("TOPRIGHT", 0, 0)
    valTxt:SetTextColor(RGB(TEXT))

    -- slider
    local sl = CreateFrame("Slider", nil, f, "MinimalSliderTemplate")
    sl:SetSize(f:GetWidth() - 60, 14)
    sl:SetPoint("BOTTOMLEFT", 0, 0)
    sl:SetMinMaxValues(minV, maxV)
    sl:SetValueStep(step)
    sl:SetObeyStepOnDrag(true)
    sl:SetValue(getter())

    -- edit box (right of slider)
    local eb = CreateFrame("EditBox", nil, f, "BackdropTemplate")
    eb:SetSize(50, 18)
    eb:SetPoint("LEFT", sl, "RIGHT", 6, 0)
    MakeBg(eb, RGB(WIDGET_BG))
    eb:SetAutoFocus(false)
    ApplyFont(eb, 11)
    eb:SetTextColor(RGB(TEXT))
    eb:SetJustifyH("CENTER")
    local initVal = getter()
    eb:SetText(fmt and fmt(initVal) or tostring(math.floor(initVal + 0.5)))

    local _lastApplied
    local function UpdateVal(v)
        v = math.max(minV, math.min(maxV, v))
        if v == _lastApplied then return end
        _lastApplied = v
        setter(v)
        sl:SetValue(v)
        eb:SetText(fmt and fmt(v) or tostring(math.floor(v + 0.5)))
        valTxt:SetText("")
        Refresh()
    end

    sl:SetScript("OnValueChanged", function(_, v)
        UpdateVal(v)
    end)
    -- Live update during drag: OnValueChanged may not fire on every frame,
    -- so poll the slider value while mouse is held down.
    sl:HookScript("OnMouseDown", function()
        sl:SetScript("OnUpdate", function()
            UpdateVal(sl:GetValue())
        end)
    end)
    sl:HookScript("OnMouseUp", function()
        sl:SetScript("OnUpdate", nil)
        UpdateVal(sl:GetValue())
    end)
    eb:SetScript("OnEnterPressed", function(self)
        local raw = self:GetText():gsub("[^%d%.%-]", "")  -- strip px, %, etc.
        local n = tonumber(raw)
        if n then UpdateVal(n) end
        self:ClearFocus()
    end)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    f._enabled = true
    -- Stable value-refresh (registerAttached overwrites f._update with its
    -- visibility sync, so SetWidgetEnabled uses this directly instead).
    f._refreshValue = function()
        sl:SetValue(getter())
        eb:SetText(fmt and fmt(getter()) or tostring(math.floor(getter() + 0.5)))
    end
    f._update = function()
        if f._enabled == false then return end  -- keep info text while disabled
        f._refreshValue()
    end

    -- Enable/disable (gray out) the slider. When disabled the slider + edit
    -- box stop taking input, the whole widget dims, and an optional short
    -- info string replaces the value box (e.g. "= frame").
    function f:SetWidgetEnabled(enabled, infoText)
        f._enabled = enabled and true or false
        if enabled then
            sl:Enable(); eb:EnableMouse(true); eb:EnableKeyboard(true)
            f:SetAlpha(1)
            f._refreshValue()
        else
            sl:Disable(); eb:EnableMouse(false); eb:EnableKeyboard(false); eb:ClearFocus()
            f:SetAlpha(0.45)
            if infoText then eb:SetText(infoText) end
        end
    end

    f._searchLabel = label
    f._searchKind  = "slider"
    return f
end

------------------------------------------------------------
-- Dropdown (custom popup)
------------------------------------------------------------
local function CreateDropdown(parent, label, options, getter, setter)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(parent:GetWidth() - CONTENT_PAD * 2, WIDGET_H)

    local lbl = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, 11)
    lbl:SetPoint("LEFT", 0, 0)
    lbl:SetTextColor(RGB(TEXT_DIM))
    lbl:SetText(label)

    -- button
    local btn = CreateFrame("Button", nil, f, "BackdropTemplate")
    btn:SetSize(180, 22)
    btn:SetPoint("RIGHT", 0, 0)
    MakeBg(btn, RGB(WIDGET_BG))

    local btnText = btn:CreateFontString(nil, "OVERLAY")
    ApplyFont(btnText, 11)
    btnText:SetPoint("LEFT", 6, 0)
    btnText:SetTextColor(RGB(TEXT))

    local arrow = btn:CreateFontString(nil, "OVERLAY")
    ApplyFont(arrow, 10)
    arrow:SetPoint("RIGHT", -6, 0)
    arrow:SetTextColor(RGB(TEXT_DIM))
    arrow:SetText("v")

    local function UpdateText()
        local cur = getter()
        for _, opt in ipairs(options) do
            if opt.value == cur then
                -- Mirror the per-option font onto the closed dropdown
                -- button as well, so the user sees the active font in
                -- its own typeface even when the list is collapsed.
                if opt.font then
                    local ok = pcall(function()
                        btnText:SetFont(opt.font, 12, "")
                    end)
                    if not ok or not btnText:GetFont() then ApplyFont(btnText, 11) end
                else
                    ApplyFont(btnText, 11)
                end
                btnText:SetText(opt.label)
                return
            end
        end
        ApplyFont(btnText, 11)
        btnText:SetText(tostring(cur))
    end
    UpdateText()

    btn:SetScript("OnClick", function()
        -- close existing
        if dropdownPopup and dropdownPopup:IsShown() then
            dropdownPopup:Hide()
            return
        end
        if not dropdownPopup then
            dropdownPopup = CreateFrame("Frame", "BIT_DropdownPopup", UIParent, "BackdropTemplate")
            dropdownPopup:SetFrameStrata("TOOLTIP")
            dropdownPopup:SetFrameLevel(200)
            dropdownPopup:SetClampedToScreen(true)
            dropdownPopup.items = {}

            -- scroll frame inside popup
            local sf = CreateFrame("ScrollFrame", nil, dropdownPopup, "UIPanelScrollFrameTemplate")
            sf:SetPoint("TOPLEFT", 2, -2)
            sf:SetPoint("BOTTOMRIGHT", -20, 2)
            dropdownPopup.scrollFrame = sf
            -- Slim themed scrollbar (same skin as the settings window)
            -- in the reserved 20px right gutter, replacing the
            -- template's arrow-button bar.
            SkinScrollFrame(sf, { rightOffset = 13, topPad = -2, bottomPad = 2 })

            local child = CreateFrame("Frame", nil, sf)
            child:SetWidth(1) -- set dynamically
            child:SetHeight(1)
            sf:SetScrollChild(child)
            dropdownPopup.scrollChild = child

            -- mouse wheel on the popup itself
            dropdownPopup:EnableMouseWheel(true)
            dropdownPopup:SetScript("OnMouseWheel", function(_, delta)
                local cur = sf:GetVerticalScroll()
                local max = sf:GetVerticalScrollRange()
                sf:SetVerticalScroll(math.max(0, math.min(max, cur - delta * 22 * 3)))
            end)
        end
        local popup = dropdownPopup
        local child = popup.scrollChild
        local sf    = popup.scrollFrame
        -- clear old
        for _, item in ipairs(popup.items) do item:Hide() end
        wipe(popup.items)

        local itemH   = 22
        local maxShow = 10
        -- Widen the popup when any option ships a preview (font / bar
        -- texture / border edge / sound). Without the extra room the
        -- preview swatch overlaps the option name, especially for
        -- longer entries like "Blizzard Achievement". Closed-button
        -- width stays unchanged so the row layout is unaffected.
        local hasPreview = false
        for _, opt in ipairs(options) do
            if opt.font or opt.barTexture or opt.borderTextureEdge or opt.sound then
                hasPreview = true
                break
            end
        end
        local btnW    = btn:GetWidth()
        local w       = hasPreview and (btnW + 110) or btnW
        local visH    = math.min(#options, maxShow) * itemH + 4
        popup:ClearAllPoints()
        popup:SetSize(w, visH)
        popup:SetPoint("TOP", btn, "BOTTOM", 0, -2)
        MakeBg(popup, 0.10, 0.10, 0.12, 0.98)
        popup:SetBackdropBorderColor(RGB(ACCENT))

        child:SetWidth(w - (#options > maxShow and 22 or 4))
        child:SetHeight(#options * itemH)

        -- hide scrollbar when not needed
        if sf.ScrollBar then
            if #options > maxShow then sf.ScrollBar:Show() else sf.ScrollBar:Hide() end
        end

        for i, opt in ipairs(options) do
            local item = CreateFrame("Button", nil, child)
            item:SetSize(child:GetWidth(), itemH)
            item:SetPoint("TOPLEFT", 0, -(i - 1) * itemH)
            local itxt = item:CreateFontString(nil, "OVERLAY")
            -- If the option carries its own font path (Font dropdown
            -- preview), render the entry's label in *that* typeface so
            -- the user sees what each option actually looks like before
            -- picking. Falls back to the addon's UI font on failure.
            if opt.font then
                local ok = pcall(function() itxt:SetFont(opt.font, 13, "") end)
                if not ok or not itxt:GetFont() then ApplyFont(itxt, 11) end
            else
                ApplyFont(itxt, 11)
            end
            itxt:SetPoint("LEFT", 6, 0)
            itxt:SetTextColor(RGB(TEXT))
            itxt:SetText(opt.label)
            -- highlight current selection
            if opt.value == getter() then
                itxt:SetTextColor(RGB(ACCENT))
            end
            -- Bar Texture dropdown preview: render the texture as a
            -- small bar swatch on the right half of the row so the user
            -- can compare the actual look (smooth vs grainy vs raised)
            -- before selecting. Tinted with the BIT accent blue so the
            -- swatch reads as "this is what your tracker bar will use".
            if opt.barTexture then
                local swatchBg = item:CreateTexture(nil, "BACKGROUND")
                swatchBg:SetColorTexture(0, 0, 0, 0.4)
                swatchBg:SetPoint("LEFT", item, "CENTER", 8, 0)
                swatchBg:SetPoint("RIGHT", item, "RIGHT", -8, 0)
                swatchBg:SetHeight(12)

                local swatch = item:CreateTexture(nil, "ARTWORK")
                local okT = pcall(function() swatch:SetTexture(opt.barTexture) end)
                if not okT then swatch:SetColorTexture(0.5, 0.5, 0.5, 1) end
                swatch:SetVertexColor(0.40, 0.65, 1.00, 1)
                swatch:SetPoint("LEFT", item, "CENTER", 8, 0)
                swatch:SetPoint("RIGHT", item, "RIGHT", -8, 0)
                swatch:SetHeight(12)
            end
            -- Border dropdown preview: render a tiny bordered frame on
            -- the right side of the row using the option's edge texture
            -- so the user can see the actual border style (thin tooltip
            -- vs heavy wooden vs ornate gold) before picking. Skipped
            -- for "None" because there's no path to render.
            if opt.borderTextureEdge then
                local borderFrame = CreateFrame("Frame", nil, item, "BackdropTemplate")
                borderFrame:SetSize(60, 18)
                borderFrame:SetPoint("RIGHT", item, "RIGHT", -8, 0)
                local edgeSize = math.min(8, opt.borderMinSize or 8)
                local okBd = pcall(function()
                    borderFrame:SetBackdrop({
                        bgFile   = "Interface\\BUTTONS\\WHITE8X8",
                        edgeFile = opt.borderTextureEdge,
                        edgeSize = edgeSize,
                        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
                    })
                end)
                if okBd then
                    -- Dark inner fill so the edge stands out, accent-
                    -- coloured border tint matches the rest of the UI.
                    borderFrame:SetBackdropColor(0.05, 0.05, 0.07, 0.95)
                    borderFrame:SetBackdropBorderColor(0.85, 0.85, 0.90, 1)
                end
            end
            -- Sound dropdown preview: render a click-to-play speaker
            -- icon on the right edge of the row. As a child Button it
            -- swallows its own clicks (the row's OnClick that picks the
            -- option doesn't fire). Lets the user audition each sound
            -- before committing to it.
            if opt.sound then
                local playBtn = CreateFrame("Button", nil, item)
                playBtn:SetSize(16, 16)
                playBtn:SetPoint("RIGHT", -6, 0)

                local pTex = playBtn:CreateTexture(nil, "ARTWORK")
                pTex:SetAllPoints()
                local okT = pcall(function()
                    pTex:SetTexture("Interface\\COMMON\\VoiceChat-Speaker")
                end)
                if not okT or not pTex:GetTexture() then
                    -- Fallback: a plain coloured square so the button is
                    -- still clickable even if the speaker asset isn't
                    -- found in the current client build.
                    pTex:SetColorTexture(RGB(ACCENT))
                end
                pTex:SetVertexColor(0.85, 0.85, 0.85, 1)

                playBtn:SetScript("OnEnter", function()
                    pTex:SetVertexColor(1.00, 0.85, 0.30, 1)
                end)
                playBtn:SetScript("OnLeave", function()
                    pTex:SetVertexColor(0.85, 0.85, 0.85, 1)
                end)
                playBtn:SetScript("OnClick", function()
                    if BIT.Media and BIT.Media.PlayKickSound then
                        BIT.Media:PlayKickSound(opt.value)
                    end
                end)
            end
            local hl = item:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.15)
            item:SetScript("OnClick", function()
                setter(opt.value)
                UpdateText()
                popup:Hide()
                Refresh()
            end)
            popup.items[i] = item
        end
        sf:SetVerticalScroll(0)
        popup:Show()
        -- close on outside click
        popup:SetScript("OnUpdate", function(self)
            if not self:IsMouseOver() and not btn:IsMouseOver() and IsMouseButtonDown("LeftButton") then
                self:Hide()
            end
        end)
    end)

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(RGB(ACCENT))
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(RGB(BORDER))
    end)

    f._update = UpdateText
    f._searchLabel = label
    f._searchKind  = "dropdown"
    return f
end

------------------------------------------------------------
-- Multi-select dropdown
--
-- Like CreateDropdown, but each option carries a checkbox state and
-- clicking an item TOGGLES its checked status (popup stays open).
-- Getter returns a table keyed by option.value with `true` entries
-- for selected values; setter receives a fresh table on every
-- change. Closed-button label summarises the selection ("None",
-- "All", "<label>", "<label>, +N").
------------------------------------------------------------
local function CreateMultiSelectDropdown(parent, label, options, getter, setter)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(parent:GetWidth() - CONTENT_PAD * 2, WIDGET_H)

    local lbl = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, 11)
    lbl:SetPoint("LEFT", 0, 0)
    lbl:SetTextColor(RGB(TEXT_DIM))
    lbl:SetText(label)

    local btn = CreateFrame("Button", nil, f, "BackdropTemplate")
    btn:SetSize(180, 22)
    btn:SetPoint("RIGHT", 0, 0)
    MakeBg(btn, RGB(WIDGET_BG))

    local btnText = btn:CreateFontString(nil, "OVERLAY")
    ApplyFont(btnText, 11)
    btnText:SetPoint("LEFT", 6, 0)
    btnText:SetPoint("RIGHT", -16, 0)
    btnText:SetJustifyH("LEFT")
    btnText:SetTextColor(RGB(TEXT))

    local arrow = btn:CreateFontString(nil, "OVERLAY")
    ApplyFont(arrow, 10)
    arrow:SetPoint("RIGHT", -6, 0)
    arrow:SetTextColor(RGB(TEXT_DIM))
    arrow:SetText("v")

    local function summarize()
        local sel = getter() or {}
        local labels = {}
        for _, opt in ipairs(options) do
            if sel[opt.value] then labels[#labels+1] = opt.label end
        end
        local n = #labels
        if n == 0           then return LS("MULTI_NONE", "None") end
        if n == #options    then return LS("MULTI_ALL",  "All")  end
        if n == 1           then return labels[1] end
        if n == 2           then return labels[1] .. ", " .. labels[2] end
        return labels[1] .. ", " .. labels[2] .. ", +" .. (n - 2)
    end
    local function UpdateText() btnText:SetText(summarize()) end
    UpdateText()

    local popup
    btn:SetScript("OnClick", function()
        if popup and popup:IsShown() then popup:Hide(); return end
        if not popup then
            popup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            popup:SetFrameStrata("TOOLTIP")
            popup:SetFrameLevel(200)
            popup:SetClampedToScreen(true)
            MakeBg(popup, 0.06, 0.06, 0.08, 0.97)
            popup.items = {}
        end
        local ITEM_H = 22
        local W = btn:GetWidth()
        popup:SetSize(W, ITEM_H * #options + 8)
        popup:ClearAllPoints()
        popup:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, -2)

        -- Hide any items from a previous popup pass so re-opening with
        -- different option counts doesn't leave dangling rows.
        for _, old in ipairs(popup.items) do old:Hide() end

        for i, opt in ipairs(options) do
            local item = popup.items[i]
            if not item then
                item = CreateFrame("Button", nil, popup)
                local check = item:CreateFontString(nil, "OVERLAY")
                ApplyFont(check, 13)
                check:SetPoint("LEFT", 8, 0)
                check:SetTextColor(RGB(ACCENT))
                item.check = check

                local itxt = item:CreateFontString(nil, "OVERLAY")
                ApplyFont(itxt, 11)
                itxt:SetPoint("LEFT", 26, 0)
                itxt:SetTextColor(RGB(TEXT))
                item.itxt = itxt

                local hl = item:CreateTexture(nil, "HIGHLIGHT")
                hl:SetAllPoints()
                hl:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.15)
                popup.items[i] = item
            end
            item:SetSize(W - 4, ITEM_H)
            item:ClearAllPoints()
            item:SetPoint("TOPLEFT", 2, -2 - (i - 1) * ITEM_H)
            item:Show()
            item.itxt:SetText(opt.label)

            -- Refresh checked state on every open.
            local sel = getter() or {}
            item.check:SetText(sel[opt.value] and "x" or " ")

            item:SetScript("OnClick", function()
                local cur = getter() or {}
                local newSel = {}
                for k, v in pairs(cur) do newSel[k] = v end
                if newSel[opt.value] then newSel[opt.value] = nil
                else newSel[opt.value] = true end
                setter(newSel)
                item.check:SetText(newSel[opt.value] and "x" or " ")
                UpdateText()
            end)
        end

        popup:Show()
        -- Close on outside mouse-down. Same pattern as the single-
        -- select dropdown popup so the two widgets feel identical.
        popup:SetScript("OnUpdate", function(self)
            if not self:IsMouseOver() and not btn:IsMouseOver()
               and IsMouseButtonDown("LeftButton") then
                self:Hide()
            end
        end)
    end)

    btn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
    btn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)

    f._update = UpdateText
    f._searchLabel = label
    f._searchKind  = "multidropdown"
    return f
end

------------------------------------------------------------
-- Color Swatch (opens Blizzard ColorPicker)
------------------------------------------------------------
local function CreateColorSwatch(parent, label, getR, getG, getB, setColor, getA, setA)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(parent:GetWidth() - CONTENT_PAD * 2, WIDGET_H)

    local lbl = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, 11)
    lbl:SetPoint("LEFT", 0, 0)
    lbl:SetTextColor(RGB(TEXT_DIM))
    lbl:SetText(label)

    -- swatch
    local sw = CreateFrame("Button", nil, f, "BackdropTemplate")
    sw:SetSize(60, 20)
    sw:SetPoint("RIGHT", 0, 0)
    sw:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1,
                      insets = { left = 1, right = 1, top = 1, bottom = 1 } })
    sw:SetBackdropBorderColor(0.3, 0.3, 0.3)

    -- hex text
    local hex = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(hex, 10)
    hex:SetPoint("RIGHT", sw, "LEFT", -8, 0)
    hex:SetTextColor(RGB(TEXT_DIM))

    local function UpdateSwatch()
        local r, g, b = getR(), getG(), getB()
        sw:SetBackdropColor(r, g, b, 1)
        hex:SetText(string.format("#%02X%02X%02X", math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5)))
    end
    UpdateSwatch()

    sw:SetScript("OnClick", function()
        local info = {}
        info.r, info.g, info.b = getR(), getG(), getB()
        info.hasOpacity = (getA ~= nil)
        info.opacity = getA and (1 - getA()) or 1
        info.swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            setColor(r, g, b)
            if setA and info.hasOpacity then
                setA(1 - ColorPickerFrame:GetColorAlpha())
            end
            UpdateSwatch()
            Refresh()
        end
        info.cancelFunc = function(prev)
            setColor(prev.r, prev.g, prev.b)
            if setA and prev.a then setA(prev.a) end
            UpdateSwatch()
            Refresh()
        end
        info.opacityFunc = info.swatchFunc
        -- Skin the shared Blizzard picker to our theme (once), then show.
        pcall(function() BIT.SettingsUI:SkinColorPicker() end)
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)

    sw:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
    sw:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(0.3, 0.3, 0.3) end)

    f._update = UpdateSwatch
    f._searchLabel = label
    f._searchKind  = "color"
    return f
end

------------------------------------------------------------
-- Blizzard ColorPickerFrame skin
-- The picker is a shared global frame, so we skin its structure
-- ONCE and recolor on theme change. Everything is heavily guarded
-- (pcall / nil checks) because its layout differs across client
-- versions — a failed skin must never break the picker itself.
------------------------------------------------------------
local _cpSkinned = false

local function _cpSkinButton(btn)
    if not btn or btn._bitSkinned then return end
    btn._bitSkinned = true
    -- Strip the default button art (atlas slices differ by version).
    for _, k in ipairs({ "Left", "Middle", "Right", "TopLeft", "TopRight",
                         "BottomLeft", "BottomRight", "TopMiddle", "MiddleLeft",
                         "MiddleRight", "BottomMiddle", "MiddleMiddle" }) do
        local t = btn[k]
        if t and t.SetAlpha then t:SetAlpha(0) end
    end
    if btn.NineSlice and btn.NineSlice.SetAlpha then btn.NineSlice:SetAlpha(0) end
    pcall(function() btn:SetNormalTexture("") end)
    pcall(function() btn:SetPushedTexture("") end)
    pcall(function() btn:SetDisabledTexture("") end)
    local hl = btn.GetHighlightTexture and btn:GetHighlightTexture()
    if hl and hl.SetColorTexture then hl:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.15) end

    local bd = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    bd:SetPoint("TOPLEFT", 1, -1)
    bd:SetPoint("BOTTOMRIGHT", -1, 1)
    bd:SetFrameLevel(math.max(0, (btn:GetFrameLevel() or 1) - 1))
    bd:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1,
                     insets = { left = 1, right = 1, top = 1, bottom = 1 } })
    btn._bitBd = bd

    btn:HookScript("OnEnter", function()
        local p = GetThemePalette()
        bd:SetBackdropBorderColor(p.accent[1], p.accent[2], p.accent[3], 1)
    end)
    btn:HookScript("OnLeave", function()
        bd:SetBackdropBorderColor(RGB(BORDER))
    end)

    local fs = btn.GetFontString and btn:GetFontString()
    if fs and fs.SetTextColor then fs:SetTextColor(RGB(TEXT)) end
end

-- Find the hex-code EditBox regardless of client-version naming: known
-- keys first, then a child scan for the first EditBox under Content / cp.
local function _cpFindHexBox(cp)
    local content = cp.Content or cp
    if content.HexBox then return content.HexBox end
    for _, scope in ipairs({ content, cp }) do
        if scope.GetChildren then
            for _, child in ipairs({ scope:GetChildren() }) do
                if child.GetObjectType and child:GetObjectType() == "EditBox" then
                    return child
                end
            end
        end
    end
    return nil
end

local function _cpSkinEditBox(eb)
    if not eb or eb._bitSkinned then return end
    eb._bitSkinned = true
    -- Strip the InputBoxTemplate border/background art.
    for _, k in ipairs({ "Left", "Middle", "Right" }) do
        local t = eb[k]
        if t and t.SetAlpha then t:SetAlpha(0) end
    end

    local bd = CreateFrame("Frame", nil, eb, "BackdropTemplate")
    bd:SetPoint("TOPLEFT", -2, 2)
    bd:SetPoint("BOTTOMRIGHT", 2, -2)
    bd:SetFrameLevel(math.max(0, (eb:GetFrameLevel() or 1) - 1))
    bd:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1,
                     insets = { left = 1, right = 1, top = 1, bottom = 1 } })
    bd:SetBackdropColor(WIDGET_BG[1], WIDGET_BG[2], WIDGET_BG[3], 1)
    bd:SetBackdropBorderColor(RGB(BORDER))
    eb._bitBd = bd

    if eb.SetTextColor then eb:SetTextColor(RGB(TEXT)) end
    -- Accent border on focus, matching the settings search box.
    eb:HookScript("OnEditFocusGained", function()
        local p = GetThemePalette()
        bd:SetBackdropBorderColor(p.accent[1], p.accent[2], p.accent[3], 1)
    end)
    eb:HookScript("OnEditFocusLost", function()
        bd:SetBackdropBorderColor(RGB(BORDER))
    end)
end

function BIT.SettingsUI:ApplyColorPickerTheme()
    local cp = ColorPickerFrame
    if not cp or not cp._bitBackdrop then return end
    local p = GetThemePalette()
    cp._bitBackdrop:SetBackdropColor(p.bg[1], p.bg[2], p.bg[3], 1)
    cp._bitBackdrop:SetBackdropBorderColor(
        p.accent[1] * 0.7, p.accent[2] * 0.7, p.accent[3] * 0.7, 1)
    if cp._bitBackdrop._glow then
        cp._bitBackdrop._glow:SetBackdropBorderColor(p.glow[1], p.glow[2], p.glow[3], p.glow[4])
    end
    if cp._bitHeaderText and cp._bitHeaderText.SetTextColor then
        cp._bitHeaderText:SetTextColor(p.accent[1], p.accent[2], p.accent[3])
    end
    if cp._bitButtons then
        for _, btn in ipairs(cp._bitButtons) do
            if btn._bitBd then
                btn._bitBd:SetBackdropColor(p.titleBg[1], p.titleBg[2], p.titleBg[3], 1)
                btn._bitBd:SetBackdropBorderColor(RGB(BORDER))
            end
        end
    end
end

function BIT.SettingsUI:SkinColorPicker()
    local cp = ColorPickerFrame
    if not cp then return end
    if _cpSkinned then
        -- Already skinned — just re-assert the theme (the picker may
        -- open after the user changed the settings theme).
        self:ApplyColorPickerTheme()
        return
    end
    _cpSkinned = true

    -- Hide Blizzard's frame border / background art.
    for _, key in ipairs({ "Border", "NineSlice", "Bg", "Background" }) do
        local r = cp[key]
        if r and r.SetAlpha then pcall(function() r:SetAlpha(0) end) end
    end

    -- Header: keep the title text, drop the textured strip.
    local header = cp.Header
    if header then
        for _, k in ipairs({ "Left", "Middle", "Right", "Background" }) do
            local t = header[k]
            if t and t.SetAlpha then pcall(function() t:SetAlpha(0) end) end
        end
        cp._bitHeaderText = header.Text or (header.GetFontString and header:GetFontString()) or nil
    end

    -- Our themed backdrop behind the content, with the same outer glow
    -- line as the settings window.
    local bd = CreateFrame("Frame", nil, cp, "BackdropTemplate")
    bd:SetPoint("TOPLEFT", 0, 0)
    bd:SetPoint("BOTTOMRIGHT", 0, 0)
    bd:SetFrameLevel(math.max(0, (cp:GetFrameLevel() or 1) - 1))
    bd:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1,
                     insets = { left = 1, right = 1, top = 1, bottom = 1 } })
    local glow = CreateFrame("Frame", nil, bd, "BackdropTemplate")
    glow:SetPoint("TOPLEFT", -1, 1)
    glow:SetPoint("BOTTOMRIGHT", 1, -1)
    glow:SetBackdrop({ edgeFile = WHITE8, edgeSize = 2 })
    bd._glow = glow
    cp._bitBackdrop = bd

    -- Footer buttons (frame keys differ across client versions).
    local buttons = {}
    local candidates = {
        cp.Footer and cp.Footer.OkayButton,
        cp.Footer and cp.Footer.CancelButton,
        _G.ColorPickerOkayButton,
        _G.ColorPickerCancelButton,
    }
    for _, b in ipairs(candidates) do
        if b and not b._bitSkinned then
            _cpSkinButton(b)
            buttons[#buttons + 1] = b
        end
    end
    cp._bitButtons = buttons

    -- Hex-code input box.
    pcall(function() _cpSkinEditBox(_cpFindHexBox(cp)) end)

    -- Re-hide Blizzard art + re-assert the theme on every open, in case
    -- a show re-shows the border textures or the theme changed while
    -- the picker was closed.
    cp:HookScript("OnShow", function()
        for _, key in ipairs({ "Border", "NineSlice", "Bg", "Background" }) do
            local r = cp[key]
            if r and r.SetAlpha then pcall(function() r:SetAlpha(0) end) end
        end
        BIT.SettingsUI:ApplyColorPickerTheme()
    end)

    self:ApplyColorPickerTheme()
end

------------------------------------------------------------
-- Section Header (collapsible)
------------------------------------------------------------
local function CreateSectionHeader(parent, label, stateKey)
    local f = CreateFrame("Button", nil, parent)
    f:SetSize(parent:GetWidth() - CONTENT_PAD * 2, SECTION_H)

    local line = f:CreateTexture(nil, "BACKGROUND")
    line:SetHeight(1)
    line:SetPoint("BOTTOMLEFT", 0, 0)
    line:SetPoint("BOTTOMRIGHT", 0, 0)
    line:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.3)

    local arrowFs = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(arrowFs, 10)
    arrowFs:SetPoint("LEFT", 0, 0)
    arrowFs:SetTextColor(RGB(ACCENT))

    local lbl = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, 13, "OUTLINE")
    lbl:SetPoint("LEFT", 16, 0)
    lbl:SetTextColor(RGB(TEXT))
    lbl:SetText(label)

    f._expanded = (BIT.db and BIT.db.sectionExpanded and BIT.db.sectionExpanded[stateKey] ~= false) or true
    f._children = {}
    f._stateKey = stateKey
    -- Stash the arrow FontString on the frame so external code (e.g.
    -- the changelog page's single-section-open accordion logic) can
    -- refresh the v/> glyph after programmatically collapsing a peer.
    f._arrowFs  = arrowFs

    local function UpdateArrow()
        arrowFs:SetText(f._expanded and "v" or ">")
    end
    UpdateArrow()

    f:SetScript("OnClick", function()
        f._expanded = not f._expanded
        if BIT.db and BIT.db.sectionExpanded then
            BIT.db.sectionExpanded[f._stateKey] = f._expanded
        end
        UpdateArrow()
        -- When re-expanding, run every `_update` callback first so that
        -- `_dynamic` widgets reclaim their correct visibility. Collapsing
        -- hides children via `w:Hide()`, which wipes the state that the
        -- _update closures normally maintain — without this pass, those
        -- widgets would stay hidden in `IsShown()` terms and the layout
        -- would continue skipping them.
        if f._expanded and pages[activePage] and pages[activePage].refresh then
            pages[activePage].refresh()
        end
        if pages[activePage] and pages[activePage].layout then
            pages[activePage].layout()
        end
    end)

    f:SetScript("OnEnter", function() lbl:SetTextColor(RGB(ACCENT)) end)
    f:SetScript("OnLeave", function() lbl:SetTextColor(RGB(TEXT)) end)

    f._searchLabel = label
    f._searchKind  = "section"
    return f
end

------------------------------------------------------------
-- Label (info line)
------------------------------------------------------------
local function CreateLabel(parent, text, size, col)
    local f = CreateFrame("Frame", nil, parent)
    local width = (parent:GetWidth() or 0) - CONTENT_PAD * 2
    if width < 50 then width = 360 end   -- fallback if the parent isn't sized yet
    f:SetSize(width, (size or 11) + 4)
    local lbl = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, size or 11)
    lbl:SetPoint("TOPLEFT", 0, 0)
    lbl:SetWidth(width)                  -- explicit width → reliable word wrap
    lbl:SetJustifyH("LEFT")
    lbl:SetWordWrap(true)
    lbl:SetTextColor(col and col[1] or TEXT_DIM[1], col and col[2] or TEXT_DIM[2], col and col[3] or TEXT_DIM[3])
    lbl:SetText(text)
    -- Fit the frame to the wrapped text. Frames are shown by default, so an
    -- OnShow handler alone won't fire for the initial layout and a multi-line
    -- note would only reserve one line of height (the next widget overlaps it).
    -- So size it NOW, again next frame (once the panel width has settled), and
    -- on every later show.
    local function fit()
        f:SetHeight(math.max((size or 11) + 4, lbl:GetStringHeight() + 4))
    end
    fit()
    f:SetScript("OnShow", fit)
    return f
end

------------------------------------------------------------
-- Thin horizontal blue line for separating section groups in
-- a settings page. Same accent colour as the tab-bar underline so
-- the dividers visually echo the navigation styling.
------------------------------------------------------------
local function CreateSectionDivider(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(parent:GetWidth() - CONTENT_PAD * 2, 10)
    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("LEFT", 0, 0)
    line:SetPoint("RIGHT", 0, 0)
    line:SetColorTexture(0.3, 0.5, 1.0, 0.6)
    return f
end

------------------------------------------------------------
-- Spell Filter Panel (tabbed list with checkboxes + icons)
-- spells: flat list of { id, label, class, className }
-- getter(sid): returns true if spell is enabled
-- setter(sid, enabled): sets spell enabled/disabled
-- tabs: optional { { label, spells }, ... } for multi-tab mode
------------------------------------------------------------
local function CreateSpellFilterPanel(parent, spells, getter, setter, tabs)
    local PANEL_W  = parent:GetWidth() - CONTENT_PAD * 2
    local PANEL_H  = 320
    local ROW_H    = 24
    local TAB_H    = 26
    local BTN_H    = 28
    local ICON_SZ  = 20

    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(PANEL_W, PANEL_H)
    MakeBg(panel, 0.08, 0.08, 0.10, 1)

    -- Tab data: if tabs provided, use them; otherwise single-tab with all spells
    local tabDefs = tabs or { { label = "All", spells = spells } }
    local activeTab = 1
    local checkboxes = {}  -- trackable rows' checkbox refs (for Check/Uncheck All)
    local rows       = {}  -- EVERY row frame on the current tab, trackable or not.
                           -- Needed because `notTrackable` rows are skipped by the
                           -- checkboxes-array population below (their checkbox is
                           -- disabled). Without a separate rows tracker, switching
                           -- tabs would leave the disabled racial / DP / AW rows
                           -- visible on top of the next tab's content.

    -- ── Tab bar ──────────────────────────────────────────────
    local tabBar = CreateFrame("Frame", nil, panel)
    tabBar:SetPoint("TOPLEFT", 4, -4)
    tabBar:SetPoint("TOPRIGHT", -4, -4)
    tabBar:SetHeight(TAB_H)

    local tabBtns = {}
    local tabW = math.floor((PANEL_W - 8) / #tabDefs)

    -- ── Scroll area ──────────────────────────────────────────
    local listTop = TAB_H + 8
    local listH   = PANEL_H - listTop - BTN_H - 12

    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 6, -listTop)
    scrollFrame:SetPoint("BOTTOMRIGHT", -24, BTN_H + 10)

    -- Custom slim scrollbar (replaces the default arrow-button bar).
    SkinScrollFrame(scrollFrame, { rightOffset = 16, topPad = -4, bottomPad = 4 })

    local listChild = CreateFrame("Frame", nil, scrollFrame)
    listChild:SetWidth(PANEL_W - 32)
    scrollFrame:SetScrollChild(listChild)

    -- ── Build rows for a spell list ──────────────────────────
    local function PopulateList(spellList)
        -- Clear ALL existing rows — iterate the full rows tracker, not
        -- just the trackable checkboxes. Disabled rows live in `rows`
        -- but never made it into `checkboxes` (their cb is disabled),
        -- so the old cleanup left their frames parented + shown,
        -- causing a visual overlap with the next tab's content.
        for _, row in ipairs(rows) do
            row:Hide()
            row:SetParent(nil)
        end
        wipe(rows)
        wipe(checkboxes)

        local yOff = 0
        for i, s in ipairs(spellList) do
            local row = CreateFrame("Frame", nil, listChild)
            row:SetSize(listChild:GetWidth(), ROW_H)
            row:SetPoint("TOPLEFT", 0, -yOff)
            rows[#rows+1] = row

            -- Alternating row bg
            if i % 2 == 0 then
                local bg = row:CreateTexture(nil, "BACKGROUND")
                bg:SetAllPoints()
                bg:SetColorTexture(1, 1, 1, 0.03)
            end

            -- Highlight on hover
            local hl = row:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetColorTexture(RGB(ACCENT))
            hl:SetAlpha(0.08)

            -- Checkbox
            local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
            cb:SetSize(22, 22)
            cb:SetPoint("LEFT", 4, 0)
            cb._spellId = s.id

            if s.notTrackable then
                -- Not trackable: permanently unchecked and disabled
                cb:SetChecked(false)
                cb:Disable()
                cb:SetAlpha(0.35)
            else
                cb:SetChecked(getter(s.id))
                cb:SetScript("OnClick", function(self)
                    local checked = self:GetChecked()
                    setter(s.id, checked)
                end)
                checkboxes[#checkboxes+1] = cb
            end

            -- Spell icon
            local iconID = C_Spell.GetSpellTexture(s.id)
            if iconID then
                local ico = row:CreateTexture(nil, "ARTWORK")
                ico:SetSize(ICON_SZ, ICON_SZ)
                ico:SetPoint("LEFT", cb, "RIGHT", 4, 0)
                ico:SetTexture(iconID)
                ico:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                if s.notTrackable then ico:SetDesaturated(true) end

                -- Icon border
                local icoBorder = row:CreateTexture(nil, "OVERLAY")
                icoBorder:SetSize(ICON_SZ + 2, ICON_SZ + 2)
                icoBorder:SetPoint("CENTER", ico)
                icoBorder:SetColorTexture(0, 0, 0, 0)
                -- Thin black edge via nested frame
                local icoBg = CreateFrame("Frame", nil, row, "BackdropTemplate")
                icoBg:SetSize(ICON_SZ + 2, ICON_SZ + 2)
                icoBg:SetPoint("CENTER", ico)
                icoBg:SetBackdrop({ edgeFile = WHITE8, edgeSize = 1 })
                icoBg:SetBackdropBorderColor(0, 0, 0, 0.8)
            end

            -- Spell name + class
            local nameStr = row:CreateFontString(nil, "OVERLAY")
            ApplyFont(nameStr, 11)
            nameStr:SetPoint("LEFT", cb, "RIGHT", ICON_SZ + 10, 0)
            nameStr:SetJustifyH("LEFT")

            if s.notTrackable then
                -- Show name (dimmed) + "Aktuell nicht trackbar" hint on the right
                local cc = BIT.CLASS_COLORS and BIT.CLASS_COLORS[s.class]
                local cr, cg, cb2 = cc and cc[1] or 0.6, cc and cc[2] or 0.6, cc and cc[3] or 0.6
                local classHex = string.format("%02x%02x%02x",
                    math.floor(cr * 255), math.floor(cg * 255), math.floor(cb2 * 255))
                nameStr:SetText(s.label .. "  |cff" .. classHex .. "(" .. (s.className or s.class) .. ")|r")
                nameStr:SetTextColor(0.5, 0.5, 0.5)

                local hintStr = row:CreateFontString(nil, "OVERLAY")
                ApplyFont(hintStr, 10)
                hintStr:SetPoint("RIGHT", row, "RIGHT", -6, 0)
                hintStr:SetText("|cffff8800" .. LS("NOT_TRACKABLE", "Currently not trackable") .. "|r")
                hintStr:SetJustifyH("RIGHT")

                -- No mouse interaction for not-trackable rows
                row:EnableMouse(false)
            else
                nameStr:SetPoint("RIGHT", row, "RIGHT", -6, 0)

                -- Class-colored class name suffix
                local cc = BIT.CLASS_COLORS and BIT.CLASS_COLORS[s.class]
                local cr, cg, cb2 = cc and cc[1] or 0.6, cc and cc[2] or 0.6, cc and cc[3] or 0.6
                local classHex = string.format("%02x%02x%02x",
                    math.floor(cr * 255), math.floor(cg * 255), math.floor(cb2 * 255))
                nameStr:SetText(s.label .. "  |cff" .. classHex .. "(" .. (s.className or s.class) .. ")|r")
                nameStr:SetTextColor(RGB(TEXT))

                -- Click row to toggle
                row:EnableMouse(true)
                row:SetScript("OnMouseDown", function()
                    cb:SetChecked(not cb:GetChecked())
                    setter(s.id, cb:GetChecked())
                end)

                -- Spell tooltip on hover
                row:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetSpellByID(s.id)
                    GameTooltip:Show()
                end)
                row:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end

            yOff = yOff + ROW_H
        end

        listChild:SetHeight(math.max(1, yOff))
        scrollFrame:SetVerticalScroll(0)
    end

    -- ── Tab button styling + switching ───────────────────────
    local function SetActiveTab(idx)
        activeTab = idx
        PopulateList(tabDefs[idx].spells)
        for ti, btn in ipairs(tabBtns) do
            if ti == idx then
                btn.bg:SetColorTexture(RGB(ACCENT))
                btn.bg:SetAlpha(0.25)
                btn.text:SetTextColor(RGB(ACCENT))
            else
                btn.bg:SetColorTexture(0.15, 0.15, 0.18, 1)
                btn.bg:SetAlpha(1)
                btn.text:SetTextColor(RGB(TEXT_DIM))
            end
        end
    end

    for ti, td in ipairs(tabDefs) do
        local btn = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
        btn:SetSize(tabW - 2, TAB_H - 2)
        btn:SetPoint("LEFT", (ti - 1) * tabW + 1, 0)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.15, 0.15, 0.18, 1)
        btn.bg = bg

        local txt = btn:CreateFontString(nil, "OVERLAY")
        ApplyFont(txt, 11, "OUTLINE")
        txt:SetPoint("CENTER")
        txt:SetText(td.label)
        btn.text = txt

        btn:SetScript("OnClick", function() SetActiveTab(ti) end)
        btn:SetScript("OnEnter", function()
            if ti ~= activeTab then btn.bg:SetColorTexture(0.2, 0.2, 0.24, 1) end
        end)
        btn:SetScript("OnLeave", function()
            if ti ~= activeTab then btn.bg:SetColorTexture(0.15, 0.15, 0.18, 1) end
        end)

        tabBtns[ti] = btn
    end

    -- ── Bottom buttons: Check All / Uncheck All ──────────────
    local btnW = math.floor((PANEL_W - 16) / 2)

    local function MakeBottomBtn(label, xOff, color, onClick)
        local btn = CreateFrame("Button", nil, panel, "BackdropTemplate")
        btn:SetSize(btnW, BTN_H)
        btn:SetPoint("BOTTOMLEFT", 6 + xOff, 6)
        MakeBg(btn, 0.14, 0.14, 0.16, 1)

        local txt = btn:CreateFontString(nil, "OVERLAY")
        ApplyFont(txt, 11)
        txt:SetPoint("CENTER")
        txt:SetTextColor(color[1], color[2], color[3])
        txt:SetText(label)

        btn:SetScript("OnClick", onClick)
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.2, 0.2, 0.24, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.14, 0.14, 0.16, 1)
        end)
        return btn
    end

    MakeBottomBtn("Check All", 0, { 0.3, 0.9, 0.3 }, function()
        for _, cb in ipairs(checkboxes) do
            cb:SetChecked(true)
            setter(cb._spellId, true)
        end
    end)

    MakeBottomBtn("Uncheck All", btnW + 4, { 0.9, 0.3, 0.3 }, function()
        for _, cb in ipairs(checkboxes) do
            cb:SetChecked(false)
            setter(cb._spellId, false)
        end
    end)

    -- Init first tab
    SetActiveTab(1)

    return panel
end

------------------------------------------------------------
-- EditBox (text input)
------------------------------------------------------------
-- ─────────────────────────────────────────────────────────────────────────
-- CreateEditBox(parent, label, getter, setter, width, lines)
--
--   lines (optional, default 1)
--     Number of visible text rows. > 1 enables a multi-line EditBox: the
--     box grows vertically, Enter inserts a newline (commit happens on
--     Tab or focus-loss instead so users can type linebreaks freely),
--     and the surrounding frame height grows to match. Single-line mode
--     is fully backwards compatible — existing CreateEditBox callers
--     don't pass this argument and behave exactly as before.
--
-- Note: callers that send the contents into a chat message should strip
-- newlines from the saved string before SendChatMessage — the multi-line
-- input is purely a quality-of-life feature for editing long templates,
-- not a way to send actual multi-line chat lines.
-- ─────────────────────────────────────────────────────────────────────────
local function CreateEditBox(parent, label, getter, setter, width, lines)
    lines = (type(lines) == "number" and lines > 1) and lines or 1

    -- Single-line: 20px tall as before. Multi-line: each additional row
    -- adds 16px (line height ≈ font size + a sliver of leading).
    local boxHeight   = 20 + (lines - 1) * 16
    -- Frame must be tall enough to contain the box plus a tiny vertical
    -- pad so the row above / below doesn't visually clip into it.
    local frameHeight = math.max(WIDGET_H, boxHeight + 4)

    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(parent:GetWidth() - CONTENT_PAD * 2, frameHeight)

    local lbl = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, 11)
    -- For multi-line, anchor the label to the top-left so it doesn't
    -- visually hover in the middle of a tall edit-box. Single-line keeps
    -- the original LEFT-centered anchor.
    if lines > 1 then
        lbl:SetPoint("TOPLEFT", 0, -4)
    else
        lbl:SetPoint("LEFT", 0, 0)
    end
    lbl:SetTextColor(RGB(TEXT_DIM))
    lbl:SetText(label)

    local eb = CreateFrame("EditBox", nil, f, "BackdropTemplate")
    eb:SetSize(width or 160, boxHeight)
    eb:SetPoint("RIGHT", 0, 0)
    MakeBg(eb, RGB(WIDGET_BG))
    eb:SetAutoFocus(false)
    ApplyFont(eb, 11)
    eb:SetTextColor(RGB(TEXT))
    -- Multi-line gets a touch of top/bottom inset so the first / last row
    -- isn't pinned against the edge of the backdrop frame.
    if lines > 1 then
        eb:SetTextInsets(6, 6, 4, 4)
        eb:SetMultiLine(true)
        eb:SetMaxLetters(0)
    else
        eb:SetTextInsets(6, 6, 0, 0)
    end
    eb:SetText(getter() or "")

    if lines > 1 then
        -- In multi-line mode, Enter must insert a newline (otherwise
        -- the user can never produce a 2-line template). Commit on Tab,
        -- focus loss, and Escape — Escape additionally reverts to the
        -- saved value so a user can back out of an in-progress edit.
        eb:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
            self:SetText(getter() or "")
        end)
        eb:SetScript("OnTabPressed", function(self)
            setter(self:GetText())
            self:ClearFocus()
            Refresh()
        end)
        eb:SetScript("OnEditFocusLost", function(self)
            setter(self:GetText())
        end)
    else
        eb:SetScript("OnEnterPressed", function(self)
            setter(self:GetText())
            self:ClearFocus()
            Refresh()
        end)
        eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    end

    f._update = function() eb:SetText(getter() or "") end
    f._searchLabel = label
    f._searchKind  = "editbox"
    return f
end

------------------------------------------------------------
-- ── Main Frame ───────────────────────────────────────────
------------------------------------------------------------
local function CreateMainFrame()
    if mainFrame then return end

    mainFrame = CreateFrame("Frame", "BIT_SettingsFrame", UIParent, "BackdropTemplate")
    mainFrame:SetSize(WIN_W, WIN_H)
    mainFrame:SetPoint("CENTER")
    mainFrame:SetFrameStrata("DIALOG")
    mainFrame:SetFrameLevel(100)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:SetClampedToScreen(true)

    -- backdrop with glow
    mainFrame:SetBackdrop({
        bgFile = WHITE8,
        edgeFile = WHITE8,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    mainFrame:SetBackdropColor(RGB(BG))
    mainFrame:SetBackdropBorderColor(ACCENT[1] * 0.5, ACCENT[2] * 0.5, ACCENT[3] * 0.5, 0.8)

    -- Outer glow line, drawn as three per-side textures (top, left,
    -- right). The BOTTOM side is intentionally missing: the CPU
    -- footer docks flush below and carries the bottom line itself,
    -- so window + footer read as one continuous outline with no
    -- divider across the seam.
    local glow = CreateFrame("Frame", nil, mainFrame)
    glow:SetPoint("TOPLEFT", -1, 1)
    glow:SetPoint("BOTTOMRIGHT", 1, -1)
    glow._lines = {}
    do
        local gTop = glow:CreateTexture(nil, "BORDER")
        gTop:SetPoint("TOPLEFT"); gTop:SetPoint("TOPRIGHT"); gTop:SetHeight(2)
        local gLeft = glow:CreateTexture(nil, "BORDER")
        gLeft:SetPoint("TOPLEFT"); gLeft:SetPoint("BOTTOMLEFT"); gLeft:SetWidth(2)
        local gRight = glow:CreateTexture(nil, "BORDER")
        gRight:SetPoint("TOPRIGHT"); gRight:SetPoint("BOTTOMRIGHT"); gRight:SetWidth(2)
        glow._lines = { gTop, gLeft, gRight }
        for _, line in ipairs(glow._lines) do
            line:SetColorTexture(ACCENT[1] * 0.25, ACCENT[2] * 0.25, ACCENT[3] * 0.25, 0.5)
        end
    end
    mainFrame._glow = glow

    -- ── Title bar ────────────────────────────────────────
    local titleBar = CreateFrame("Frame", nil, mainFrame)
    titleBar:SetHeight(36)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)

    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetAllPoints()
    titleBg:SetColorTexture(0.08, 0.08, 0.10, 1)
    mainFrame._titleBg = titleBg

    local titleLine = titleBar:CreateTexture(nil, "ARTWORK")
    titleLine:SetHeight(1)
    titleLine:SetPoint("BOTTOMLEFT")
    titleLine:SetPoint("BOTTOMRIGHT")
    titleLine:SetColorTexture(ACCENT[1] * 0.4, ACCENT[2] * 0.4, ACCENT[3] * 0.4, 0.8)
    mainFrame._titleLine = titleLine

    -- Faction crest, centered horizontally on the title bar. Sized
    -- generously since the bundled Media/alliance.tga and horde.tga
    -- are clean transparent-background icons (no decorative borders
    -- to crop). Hidden when the resolved theme is DEFAULT.
    local factionLogo = titleBar:CreateTexture(nil, "ARTWORK")
    factionLogo:SetSize(32, 32)
    factionLogo:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    factionLogo:Hide()
    mainFrame._factionLogo = factionLogo

    -- logo icon
    local logo = titleBar:CreateTexture(nil, "ARTWORK")
    logo:SetSize(24, 24)
    logo:SetPoint("LEFT", 8, 0)
    logo:SetTexture("Interface\\AddOns\\BliZzi_Interrupts\\Media\\icon")
    logo:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    ApplyFont(titleText, 14, "OUTLINE")
    titleText:SetPoint("LEFT", logo, "RIGHT", 6, 0)
    titleText:SetText("|cff0091edBliZzi|r |cffffa300Party Tools|r  |cff666666" .. LS("UI_SETTINGS_SUFFIX", "Settings") .. "|r")

    -- version
    local verText = titleBar:CreateFontString(nil, "OVERLAY")
    ApplyFont(verText, 10)
    verText:SetPoint("RIGHT", -40, 0)
    verText:SetTextColor(RGB(TEXT_DIM))
    verText:SetText("v" .. (BIT.VERSION or "?"))

    -- close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("RIGHT", -4, 0)
    local closeX = closeBtn:CreateFontString(nil, "OVERLAY")
    ApplyFont(closeX, 16)
    closeX:SetPoint("CENTER")
    closeX:SetText("X")
    closeX:SetTextColor(0.6, 0.6, 0.6)
    closeBtn:SetScript("OnEnter", function() closeX:SetTextColor(1, 0.3, 0.3) end)
    closeBtn:SetScript("OnLeave", function() closeX:SetTextColor(0.6, 0.6, 0.6) end)
    closeBtn:SetScript("OnClick", function() mainFrame:Hide() end)

    -- ── Sidebar ──────────────────────────────────────────
    local sidebar = CreateFrame("Frame", nil, mainFrame)
    sidebar:SetWidth(SIDEBAR_W)
    sidebar:SetPoint("TOPLEFT", 0, -36)
    sidebar:SetPoint("BOTTOMLEFT", 0, 0)

    local sbBg = sidebar:CreateTexture(nil, "BACKGROUND")
    sbBg:SetAllPoints()
    sbBg:SetColorTexture(RGB(SIDEBAR))
    mainFrame._sidebarBg = sbBg

    local sbLine = sidebar:CreateTexture(nil, "ARTWORK")
    sbLine:SetWidth(1)
    sbLine:SetPoint("TOPRIGHT", 0, 0)
    sbLine:SetPoint("BOTTOMRIGHT", 0, 0)
    sbLine:SetColorTexture(RGB(BORDER))

    mainFrame._sidebar = sidebar
    sidebarBtns = {}

    -- ── Social links (bottom of sidebar) ─────────────────
    -- Copy-URL popup. WoW can't open external links, so clicking a social
    -- link shows the URL in a focused, pre-selected edit box — the user
    -- presses Ctrl+C to copy and the box closes itself. Lazily created and
    -- reused. Read-only via the OnChar re-inject trick so the URL can't be
    -- mangled before copying (Ctrl+C produces no char, so it's unaffected).
    local copyBox
    -- ShowCopyBox(url, extraText): show the URL pre-selected for Ctrl+C, and
    -- optionally an extra info line below it (e.g. the Twitch stream invite).
    local function ShowCopyBox(url, extraText)
        if not copyBox then
            local f = CreateFrame("Frame", "BIT_SocialCopyBox", UIParent, "BackdropTemplate")
            f:SetSize(340, 80)
            f:SetPoint("CENTER")
            f:SetFrameStrata("FULLSCREEN_DIALOG")
            f:SetToplevel(true)
            f:EnableMouse(true)
            f:SetBackdrop({
                bgFile   = "Interface\\BUTTONS\\WHITE8X8",
                edgeFile = "Interface\\BUTTONS\\WHITE8X8",
                edgeSize = 1,
                insets   = { left = 1, right = 1, top = 1, bottom = 1 },
            })
            f:SetBackdropColor(0.10, 0.10, 0.12, 1)
            f:SetBackdropBorderColor(RGB(ACCENT))

            local hint = f:CreateFontString(nil, "OVERLAY")
            ApplyFont(hint, 11)
            hint:SetPoint("TOP", 0, -10)
            hint:SetTextColor(RGB(TEXT_DIM))
            hint:SetText(LS("COPY_LINK_HINT", "Press Ctrl+C to copy, Esc to close"))

            -- URL box: top-anchored below the hint so an optional info line
            -- can sit beneath it and the frame can grow downward to fit.
            local eb = CreateFrame("EditBox", nil, f, "BackdropTemplate")
            eb:SetSize(308, 24)
            eb:SetPoint("TOP", 0, -30)
            MakeBg(eb, RGB(WIDGET_BG))
            ApplyFont(eb, 12)
            eb:SetTextColor(RGB(TEXT))
            eb:SetTextInsets(6, 6, 0, 0)
            eb:SetAutoFocus(false)
            eb:SetJustifyH("CENTER")
            eb._val = ""
            -- Read-only: re-inject the stored value on any typed char.
            eb:SetScript("OnChar", function(self) self:SetText(self._val or "") self:HighlightText() end)
            eb:SetScript("OnEscapePressed", function() f:Hide() end)
            -- Ctrl+C (copy) and Ctrl+X (cut — also copies to clipboard) both
            -- copy the highlighted text natively; close right after (deferred
            -- a frame so the copy completes before we hide).
            eb:SetScript("OnKeyDown", function(self, key)
                if (key == "C" or key == "X") and IsControlKeyDown() then
                    C_Timer.After(0, function() f:Hide() end)
                end
            end)
            f.eb = eb

            -- Optional info line below the URL box (word-wrapped, auto height).
            local extra = f:CreateFontString(nil, "OVERLAY")
            ApplyFont(extra, 11)
            extra:SetPoint("TOPLEFT",  eb, "BOTTOMLEFT",  -2, -10)
            extra:SetPoint("TOPRIGHT", eb, "BOTTOMRIGHT",  2, -10)
            extra:SetJustifyH("CENTER")
            extra:SetWordWrap(true)
            extra:SetTextColor(RGB(TEXT_DIM))
            f.extra = extra

            f:SetScript("OnHide", function() f.eb:ClearFocus() end)
            copyBox = f
        end
        copyBox.eb._val = url
        copyBox.eb:SetText(url)
        -- Show / hide the info line and size the frame to fit.
        local baseH = 30 + 24 + 14   -- hint + box + bottom padding
        if extraText and extraText ~= "" then
            copyBox.extra:SetText(extraText)
            copyBox.extra:Show()
            copyBox:SetHeight(baseH + 10 + (copyBox.extra:GetStringHeight() or 14) + 6)
        else
            copyBox.extra:SetText("")
            copyBox.extra:Hide()
            copyBox:SetHeight(baseH)
        end
        copyBox:Show()
        copyBox.eb:SetFocus()
        copyBox.eb:HighlightText()
    end

    local function CreateSocialLink(parent, yOff, iconPath, text, color, url, extraText)
        local linkBtn = CreateFrame("Button", nil, parent)
        linkBtn:SetSize(SIDEBAR_W - 2, 24)
        linkBtn:SetPoint("BOTTOMLEFT", 1, yOff)
        linkBtn:RegisterForClicks("LeftButtonUp")

        local ico = linkBtn:CreateTexture(nil, "ARTWORK")
        ico:SetSize(20, 20)
        ico:SetPoint("LEFT", 12, 0)
        ico:SetTexture(iconPath)

        local lbl = linkBtn:CreateFontString(nil, "OVERLAY")
        ApplyFont(lbl, 11)
        lbl:SetPoint("LEFT", ico, "RIGHT", 6, 0)
        lbl:SetTextColor(color[1], color[2], color[3], 0.7)
        lbl:SetText(text)

        linkBtn:SetScript("OnEnter", function()
            lbl:SetTextColor(color[1], color[2], color[3], 1)
            GameTooltip:SetOwner(linkBtn, "ANCHOR_RIGHT")
            GameTooltip:AddLine(url, 1, 1, 1)
            GameTooltip:AddLine(LS("COPY_LINK_TOOLTIP", "Click to copy"), 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        linkBtn:SetScript("OnLeave", function()
            lbl:SetTextColor(color[1], color[2], color[3], 0.7)
            GameTooltip:Hide()
        end)
        -- Click → show a copy box with the full URL (https-prefixed so it
        -- pastes straight into a browser) + an optional info line.
        linkBtn:SetScript("OnClick", function()
            ShowCopyBox("https://" .. url, extraText)
        end)

        return linkBtn
    end

    -- Separator line above links
    local linkSep = sidebar:CreateTexture(nil, "ARTWORK")
    linkSep:SetHeight(1)
    linkSep:SetPoint("BOTTOMLEFT", 12, 54)
    linkSep:SetPoint("BOTTOMRIGHT", -12, 54)
    linkSep:SetColorTexture(RGB(BORDER))

    -- ── Search field (above the separator) ───────────────────────────
    -- Live-filter the settings on the right by typing here. Empty string
    -- restores whichever page was active before the search began.
    local searchBg = CreateFrame("Frame", nil, sidebar, "BackdropTemplate")
    searchBg:SetHeight(24)
    searchBg:SetPoint("BOTTOMLEFT", 12, 64)
    searchBg:SetPoint("BOTTOMRIGHT", -12, 64)
    searchBg:SetBackdrop({
        bgFile   = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    searchBg:SetBackdropColor(0.10, 0.10, 0.12, 1)
    searchBg:SetBackdropBorderColor(RGB(BORDER))

    local searchEB = CreateFrame("EditBox", nil, searchBg)
    searchEB:SetPoint("LEFT", 6, 0)
    searchEB:SetPoint("RIGHT", -6, 0)
    searchEB:SetHeight(20)
    searchEB:SetAutoFocus(false)
    searchEB:SetMaxLetters(40)
    searchEB:SetFontObject(GameFontHighlight)
    ApplyFont(searchEB, 11)
    searchEB:SetTextColor(RGB(TEXT))

    -- Placeholder hint (fades when text is present)
    local searchHint = searchBg:CreateFontString(nil, "OVERLAY")
    ApplyFont(searchHint, 11)
    searchHint:SetPoint("LEFT", 8, 0)
    searchHint:SetTextColor(0.5, 0.5, 0.55, 1)
    searchHint:SetText(LS("SEARCH_PLACEHOLDER", "Search settings..."))

    -- Track the page the user was viewing before they started searching
    -- so an empty input field can restore it.
    local searchPreviousPage = nil

    -- Hover / focus visual on the backdrop border
    searchBg:SetScript("OnEnter", function() searchBg:SetBackdropBorderColor(RGB(ACCENT)) end)
    searchBg:SetScript("OnLeave", function()
        if not searchEB:HasFocus() then searchBg:SetBackdropBorderColor(RGB(BORDER)) end
    end)
    searchEB:SetScript("OnEditFocusGained", function()
        searchBg:SetBackdropBorderColor(RGB(ACCENT))
    end)
    searchEB:SetScript("OnEditFocusLost", function()
        searchBg:SetBackdropBorderColor(RGB(BORDER))
    end)
    searchEB:SetScript("OnEscapePressed", function(self) self:ClearFocus() self:SetText("") end)

    -- Live filtering on every keystroke. Only USER input drives the
    -- filter — programmatic SetText("") (which ShowPage uses to reset
    -- the field when switching pages) MUST NOT call ApplySearch back,
    -- otherwise we'd re-enter ShowPage from inside itself when it
    -- clears the field. The placeholder hint visibility runs on every
    -- text change regardless.
    searchEB:SetScript("OnTextChanged", function(self, userInput)
        local q = self:GetText() or ""
        if q == "" then
            searchHint:Show()
        else
            searchHint:Hide()
        end
        if not userInput then return end
        -- Remember the active page at the START of search interaction
        -- (the first keystroke that left a non-search page) so empty
        -- input later can restore it.
        if activePage ~= "_search" then
            searchPreviousPage = activePage
        end
        if BIT.SettingsUI and BIT.SettingsUI.ApplySearch then
            BIT.SettingsUI:ApplySearch(q, searchPreviousPage)
        end
    end)
    mainFrame._searchEditBox = searchEB
    mainFrame._searchHint    = searchHint

    CreateSocialLink(sidebar, 28,
        "Interface\\AddOns\\BliZzi_Interrupts\\Media\\twitch",
        "twitch.tv/BliZzi1337",
        { 0.57, 0.27, 1.0 },  -- Twitch purple
        "twitch.tv/BliZzi1337",
        LS("TWITCH_STREAM_INFO", "Feel free to drop by the stream to ask questions or give feedback — the stream is in German & English."))

    CreateSocialLink(sidebar, 6,
        "Interface\\AddOns\\BliZzi_Interrupts\\Media\\discord",
        "discord.gg",
        { 0.35, 0.40, 0.95 },  -- Discord blurple
        "discord.gg/QDNpjqJFPC")

    -- ── Content area ─────────────────────────────────────
    local contentArea = CreateFrame("Frame", nil, mainFrame)
    contentArea:SetPoint("TOPLEFT", SIDEBAR_W + 1, -36)
    contentArea:SetPoint("BOTTOMRIGHT", 0, 0)

    contentScroll = CreateFrame("ScrollFrame", nil, contentArea, "UIPanelScrollFrameTemplate")
    contentScroll:SetPoint("TOPLEFT", 0, 0)
    contentScroll:SetPoint("BOTTOMRIGHT", -24, 0)

    contentChild = CreateFrame("Frame", nil, contentScroll)
    contentChild:SetWidth(contentArea:GetWidth() - 24)
    contentChild:SetHeight(1) -- auto-resized
    contentScroll:SetScrollChild(contentChild)

    -- Re-pin the (sticky) interrupt preview whenever the view scrolls.
    contentScroll:HookScript("OnVerticalScroll", function()
        if _stickPreview then _stickPreview() end
    end)

    -- Smooth mouse-wheel scrolling: glide toward a target instead of the
    -- template's large discrete jumps. A small per-notch step plus per-frame
    -- easing makes it feel smooth; the scrollbar-drag path is untouched (the
    -- easing only runs while a wheel scroll is still settling).
    local WHEEL_STEP = 48
    contentScroll:EnableMouseWheel(true)
    contentScroll:SetScript("OnMouseWheel", function(self, delta)
        local maxS = self:GetVerticalScrollRange() or 0
        -- Re-sync the target to the live position when not already gliding so
        -- a scrollbar drag in between doesn't make the next notch jump.
        if not self._wheelGliding then self._targetScroll = self:GetVerticalScroll() or 0 end
        self._targetScroll = math.max(0, math.min(maxS, (self._targetScroll or 0) - delta * WHEEL_STEP))
        self._wheelGliding = true
    end)
    contentScroll:SetScript("OnUpdate", function(self, elapsed)
        if not self._wheelGliding then return end
        local cur    = self:GetVerticalScroll() or 0
        local target = self._targetScroll or cur
        local diff   = target - cur
        if math.abs(diff) < 0.5 then
            self:SetVerticalScroll(target)
            self._wheelGliding = false
            return
        end
        self:SetVerticalScroll(cur + diff * math.min(1, elapsed * 16))
    end)

    -- Custom slim scrollbar (replaces the default arrow-button bar).
    SkinScrollFrame(contentScroll, { rightOffset = 16, topPad = -6, bottomPad = 6 })

    -- ── CPU usage footer ─────────────────────────────────
    -- Slim themed bar attached below the window. The headline number
    -- is Blizzard's own per-addon profiler (C_AddOnProfiler, always
    -- on — no CVar, no external tooling): RecentAverageTime = avg ms
    -- of CPU per rendered frame; percent = share of the frame budget
    -- at the current FPS. Hovering breaks the cost down per module
    -- from the BIT.Prof self-instrumentation counters (wall-clock ms
    -- billed at each module's event/ticker entry points). The module
    -- rows measure our wrapped entry points only, so their sum reads
    -- slightly below the whole-addon total (settings UI, libraries
    -- and unwrapped glue make up the rest).
    -- Docked flush: 1px overlap so the footer's top border merges
    -- with the window's bottom border — reads as one continuous
    -- frame instead of a floating bar.
    local cpuFooter = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    cpuFooter:SetHeight(24)
    cpuFooter:SetPoint("TOPLEFT",  mainFrame, "BOTTOMLEFT",  0, 1)
    cpuFooter:SetPoint("TOPRIGHT", mainFrame, "BOTTOMRIGHT", 0, 1)
    -- Same construction as the main window: 1px accent border +
    -- the 1px-overhanging outer glow line. Without the glow the
    -- footer reads one pixel narrower than the window and its
    -- border looks like a different style.
    cpuFooter:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1,
                            insets = { left = 1, right = 1, top = 1, bottom = 1 } })
    -- Per-side glow lines (bottom, left, right) — no TOP line, the
    -- seam to the window above stays open so both frames share one
    -- continuous outline.
    local cpuGlow = CreateFrame("Frame", nil, cpuFooter)
    cpuGlow:SetPoint("TOPLEFT", -1, 1)
    cpuGlow:SetPoint("BOTTOMRIGHT", 1, -1)
    do
        local gBottom = cpuGlow:CreateTexture(nil, "BORDER")
        gBottom:SetPoint("BOTTOMLEFT"); gBottom:SetPoint("BOTTOMRIGHT"); gBottom:SetHeight(2)
        local gLeft = cpuGlow:CreateTexture(nil, "BORDER")
        gLeft:SetPoint("TOPLEFT"); gLeft:SetPoint("BOTTOMLEFT"); gLeft:SetWidth(2)
        local gRight = cpuGlow:CreateTexture(nil, "BORDER")
        gRight:SetPoint("TOPRIGHT"); gRight:SetPoint("BOTTOMRIGHT"); gRight:SetWidth(2)
        cpuGlow._lines = { gBottom, gLeft, gRight }
        for _, line in ipairs(cpuGlow._lines) do
            line:SetColorTexture(ACCENT[1] * 0.25, ACCENT[2] * 0.25, ACCENT[3] * 0.25, 0.5)
        end
    end
    cpuFooter._glow = cpuGlow

    -- Divider at the seam — same subtle grey as the sidebar's
    -- socials/search separator, full width.
    local cpuSep = cpuFooter:CreateTexture(nil, "ARTWORK")
    cpuSep:SetHeight(1)
    cpuSep:SetPoint("TOPLEFT", 0, 0)
    cpuSep:SetPoint("TOPRIGHT", 0, 0)
    cpuSep:SetColorTexture(RGB(BORDER))

    mainFrame._cpuFooter = cpuFooter

    -- Two separate font strings pinned around the frame's CENTER:
    -- the label ends at center, the value grows rightwards from it.
    -- Fixed anchors = no horizontal jitter when digits change width.
    local cpuLabel = cpuFooter:CreateFontString(nil, "OVERLAY")
    ApplyFont(cpuLabel, 11)
    cpuLabel:SetPoint("RIGHT", cpuFooter, "CENTER", -2, 0)
    cpuLabel:SetTextColor(RGB(TEXT_DIM))
    cpuLabel:SetText(LS("CPU_USAGE", "CPU Usage:"))

    local cpuText = cpuFooter:CreateFontString(nil, "OVERLAY")
    ApplyFont(cpuText, 11)
    cpuText:SetPoint("LEFT", cpuFooter, "CENTER", 2, 0)
    cpuText:SetJustifyH("LEFT")
    cpuText:SetTextColor(RGB(TEXT))

    local CPU_MODULES = {
        { key = "INTERRUPTS",    labelKey = "PANEL_INTERRUPTS",    fb = "Interrupts" },
        { key = "PARTY_CDS",     labelKey = "PANEL_PARTY_CDS",     fb = "Party CDs" },
        { key = "KEYSTONE_LIST", labelKey = "PANEL_KEYSTONE_LIST", fb = "Keystone List" },
        { key = "SMART_MD",      labelKey = "PANEL_SMART_MD",      fb = "Smart Misdirect" },
        { key = "PI_CALLER",     labelKey = "PANEL_PI_CALLER",     fb = "PI Caller" },
    }
    local _lastAcc, _rate = {}, {}   -- _rate[key] = ms of CPU per real-time second
    local _lastT

    local function _totalMsPerFrame()
        if C_AddOnProfiler and C_AddOnProfiler.GetAddOnMetric
           and Enum and Enum.AddOnProfilerMetric then
            local ok, v = pcall(C_AddOnProfiler.GetAddOnMetric, "BliZzi_Interrupts",
                                Enum.AddOnProfilerMetric.RecentAverageTime)
            if ok and type(v) == "number" then return v end
        end
        return nil
    end

    local function _fmtPerFrame(msPerFrame)
        local fps = GetFramerate() or 0
        local pct = (fps > 0) and (msPerFrame / (1000 / fps) * 100) or 0
        return string.format("%.3f ms (%.1f%%)", msPerFrame, pct)
    end

    local function _refreshTooltip()
        GameTooltip:SetOwner(cpuFooter, "ANCHOR_TOP")
        GameTooltip:ClearLines()
        -- Fixed row ORDER (module list order, not sorted by load) and
        -- a fixed minimum width — the tooltip keeps a constant shape
        -- instead of resizing/reshuffling with every 1s sample.
        GameTooltip:SetMinimumWidth(240)
        GameTooltip:AddLine(LS("CPU_TT_HEADER", "Live CPU by module"), 1, 1, 1)
        local fps = GetFramerate() or 0
        for _, m in ipairs(CPU_MODULES) do
            local perFrame = (fps > 0) and ((_rate[m.key] or 0) / fps) or 0
            GameTooltip:AddDoubleLine(LS(m.labelKey, m.fb), _fmtPerFrame(perFrame),
                0.75, 0.75, 0.8, 1, 1, 1)
        end
        local total = _totalMsPerFrame()
        if total then
            GameTooltip:AddDoubleLine(LS("CPU_TT_TOTAL", "Total (whole addon)"),
                _fmtPerFrame(total), 1, 1, 1, 1, 1, 1)
        end
        GameTooltip:Show()
    end

    local function _sample()
        local nowT = GetTime()
        local acc  = BIT.Prof and BIT.Prof.acc
        if acc then
            if _lastT and nowT > _lastT then
                local dt = nowT - _lastT
                for _, m in ipairs(CPU_MODULES) do
                    local cur = acc[m.key] or 0
                    _rate[m.key] = (cur - (_lastAcc[m.key] or cur)) / dt
                end
            end
            for _, m in ipairs(CPU_MODULES) do
                _lastAcc[m.key] = acc[m.key] or 0
            end
        end
        _lastT = nowT

        local total = _totalMsPerFrame()
        cpuText:SetText(total and _fmtPerFrame(total) or "N/A")
        if GameTooltip:IsOwned(cpuFooter) then _refreshTooltip() end
    end

    -- Ticker only runs while the settings window is on screen — the
    -- footer inherits show/hide from mainFrame.
    local _cpuTicker
    cpuFooter:SetScript("OnShow", function()
        _lastT = nil
        _sample()
        if not _cpuTicker then _cpuTicker = C_Timer.NewTicker(1, _sample) end
    end)
    cpuFooter:SetScript("OnHide", function()
        if _cpuTicker then _cpuTicker:Cancel(); _cpuTicker = nil end
    end)

    cpuFooter:EnableMouse(true)
    cpuFooter:SetScript("OnEnter", _refreshTooltip)
    cpuFooter:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ESC to close
    tinsert(UISpecialFrames, "BIT_SettingsFrame")

    -- When settings close, re-check fade state so hideOutOfCombat kicks in
    mainFrame:SetScript("OnHide", function()
        if BIT.UI and BIT.UI.CheckZoneVisibility then
            BIT.UI:CheckZoneVisibility()
        end
    end)

    mainFrame:Hide()
end

------------------------------------------------------------
-- ── Sidebar Button ───────────────────────────────────────
------------------------------------------------------------
-- `label` is the page identifier (English key, used for ShowPage /
-- sidebarBtns[label] / activePage tracking — must stay stable).
-- `displayLabel` is the user-visible text rendered on the button; if
-- omitted, falls back to `label` so existing callers keep working.
local function CreateSidebarBtn(idx, label, iconPath, displayLabel)
    local sidebar = mainFrame._sidebar
    local btn = CreateFrame("Button", nil, sidebar)
    btn:SetSize(SIDEBAR_W - 2, 32)
    btn:SetPoint("TOPLEFT", 1, -(idx - 1) * 33 - 8)

    -- active indicator (cyan left line)
    local indicator = btn:CreateTexture(nil, "ARTWORK")
    indicator:SetWidth(3)
    indicator:SetPoint("TOPLEFT", 0, 0)
    indicator:SetPoint("BOTTOMLEFT", 0, 0)
    indicator:SetColorTexture(RGB(ACCENT))
    indicator:Hide()
    btn._indicator = indicator

    -- bg highlight
    local bgHl = btn:CreateTexture(nil, "BACKGROUND")
    bgHl:SetAllPoints()
    bgHl:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.08)
    bgHl:Hide()
    btn._bgHl = bgHl

    -- Sidebar icons removed per user preference — labels alone read
    -- cleaner in a vertical menu. The iconPath parameter is kept on
    -- the function signature so existing call sites don't need to
    -- change, but it's intentionally unused. Text always anchors at
    -- 12px left padding now (was iconPath and 34 or 12).
    local text = btn:CreateFontString(nil, "OVERLAY")
    ApplyFont(text, 12)
    text:SetPoint("LEFT", 12, 0)
    text:SetTextColor(RGB(TEXT_DIM))
    text:SetText(displayLabel or label)
    btn._text = text

    btn:SetScript("OnEnter", function()
        if activePage ~= label then
            bgHl:Show()
            text:SetTextColor(RGB(TEXT))
        end
    end)
    btn:SetScript("OnLeave", function()
        if activePage ~= label then
            bgHl:Hide()
            text:SetTextColor(RGB(TEXT_DIM))
        end
    end)
    btn:SetScript("OnClick", function()
        BIT.SettingsUI:ShowPage(label)
    end)

    sidebarBtns[label] = btn
    return btn
end

------------------------------------------------------------
-- ── Page System ──────────────────────────────────────────
------------------------------------------------------------
local function LayoutWidgets(widgetList)
    local y = -CONTENT_PAD
    local currentSection = nil
    for _, w in ipairs(widgetList) do
        if w._isPageBanner then
            -- Search-results page-context banner. Top-level item, resets
            -- the section context so the next real section header starts
            -- a fresh group beneath the banner. Slightly more vertical
            -- breathing room above than below so the banner visually
            -- groups with the section/widgets that follow it.
            if y < -CONTENT_PAD then y = y - 6 end  -- extra gap above (skip on first)
            w:ClearAllPoints()
            w:SetPoint("TOPLEFT", contentChild, "TOPLEFT", CONTENT_PAD, y)
            w:Show()
            y = y - w:GetHeight() - 2
            currentSection = nil
        elseif w._stateKey then
            -- Section header. Supports `_dynamic` + `_update` the same way
            -- child widgets do: if the update callback hid the header,
            -- children of this section are collapsed to zero height too.
            currentSection = w
            if w._dynamic and not w:IsShown() then
                -- Entire section hidden — no layout slot, no gap.
            else
                w:ClearAllPoints()
                w:SetPoint("TOPLEFT", contentChild, "TOPLEFT", CONTENT_PAD, y)
                w:Show()
                y = y - SECTION_H - 2
            end
        elseif currentSection then
            -- child of a section
            local sectionHidden = currentSection._dynamic and not currentSection:IsShown()
            if sectionHidden then
                -- Parent section is hidden → hide child entirely, no gap.
                w:Hide()
            elseif currentSection._expanded then
                if w._dynamic and not w:IsShown() then
                    -- conditional widget hidden by _update — skip, no gap
                else
                    w:ClearAllPoints()
                    w:SetPoint("TOPLEFT", contentChild, "TOPLEFT", CONTENT_PAD, y)
                    if not w._dynamic then w:Show() end
                    local wh = w:GetHeight()
                    y = y - wh - (wh > 0 and GAP or 0)
                end
            else
                w:Hide()
            end
        else
            -- no section yet — just place it
            if w._dynamic and not w:IsShown() then
                -- conditional widget hidden — skip, no gap
            else
                w:ClearAllPoints()
                w:SetPoint("TOPLEFT", contentChild, "TOPLEFT", CONTENT_PAD, y)
                if not w._dynamic then w:Show() end
                -- Sticky preview: remember its natural distance from the top so
                -- _stickPreview can pin it once it would scroll past the top.
                if w._stickyTop then w._flowY = -y end
                local wh = w:GetHeight()
                y = y - wh - (wh > 0 and GAP or 0)
            end
        end
    end
    contentChild:SetHeight(math.abs(y) + 20)
    if _stickPreview then _stickPreview() end
end

local _pageOrder = {}  -- registration order, used by the search index for
                        -- deterministic display order independent of pairs()
local function RegisterPage(name, buildFunc)
    pages[name] = { build = buildFunc, widgets = nil }
    _pageOrder[#_pageOrder + 1] = name
end

------------------------------------------------------------
-- ── Category: General ────────────────────────────────────
------------------------------------------------------------
local function BuildGeneral()
    local w = {}
    local p = contentChild

    -- General
    w[#w+1] = CreateSectionHeader(p, LS("SEC_GENERAL", "General"), "sui_gen_general")
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_WELCOME", "Show Welcome Message"),
        function() return BIT.db.showWelcome end,
        function(v) BIT.db.showWelcome = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_MINIMAP", "Show Minimap Button"),
        function()
            local iconDB = BliZziInterruptsMinimapDB
            return not (iconDB and iconDB.hide)
        end,
        function(v)
            local ldbi = LibStub and LibStub("LibDBIcon-1.0", true)
            if ldbi then
                if not BliZziInterruptsMinimapDB then BliZziInterruptsMinimapDB = {} end
                BliZziInterruptsMinimapDB.hide = not v
                if v then ldbi:Show("BliZziInterrupts")
                else ldbi:Hide("BliZziInterrupts") end
            end
        end)

    -- Language
    w[#w+1] = CreateSectionHeader(p, LS("SEC_LANGUAGE", "Language"), "sui_gen_lang")

    -- Popup shown after a language change. ApplyLocale() swaps the live
    -- locale table but doesn't re-build cached page widgets — so the
    -- visible text on already-built pages stays in the previous
    -- language until /reload. The prompt makes that obvious and offers
    -- a one-click reload.
    local function ShowLangChangedPopup()
        if _G["BIT_LangReloadPopup"] then _G["BIT_LangReloadPopup"]:Hide() end
        local pop = CreateFrame("Frame", "BIT_LangReloadPopup", UIParent, "BackdropTemplate")
        pop:SetSize(380, 140) pop:SetPoint("CENTER")
        pop:SetFrameStrata("DIALOG") pop:SetFrameLevel(320)
        pop:SetBackdrop({
            bgFile   = "Interface\\BUTTONS\\WHITE8X8",
            edgeFile = "Interface\\BUTTONS\\WHITE8X8",
            edgeSize = 1,
            insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        pop:SetBackdropColor(0.10, 0.10, 0.12, 1)
        pop:SetBackdropBorderColor(RGB(BORDER))
        pop:EnableMouse(true)

        local titleFs = pop:CreateFontString(nil, "OVERLAY")
        ApplyFont(titleFs, 13, "OUTLINE")
        titleFs:SetPoint("TOPLEFT", 12, -12)
        titleFs:SetTextColor(1, 0.85, 0.4)
        titleFs:SetText(LS("LANG_CHANGED_TITLE", "Language changed"))

        local bodyFs = pop:CreateFontString(nil, "OVERLAY")
        ApplyFont(bodyFs, 11)
        bodyFs:SetPoint("TOPLEFT", 12, -36)
        bodyFs:SetPoint("RIGHT", -12, 0)
        bodyFs:SetJustifyH("LEFT") bodyFs:SetJustifyV("TOP")
        bodyFs:SetTextColor(RGB(TEXT))
        bodyFs:SetText(LS("LANG_CHANGED_BODY",
            "The settings will appear in the new language only after a UI reload."))
        bodyFs:SetWordWrap(true)

        -- Reload button (right-most, accent green) — runs the reload now.
        local reloadBtn = CreateFrame("Button", nil, pop, "BackdropTemplate")
        reloadBtn:SetSize(120, 24) reloadBtn:SetPoint("BOTTOMRIGHT", -12, 12)
        MakeBg(reloadBtn, 0.10, 0.20, 0.10, 1)
        local rT = reloadBtn:CreateFontString(nil, "OVERLAY") ApplyFont(rT, 11)
        rT:SetPoint("CENTER") rT:SetTextColor(0.5, 1, 0.5)
        rT:SetText(LS("BTN_RELOAD", "UI Reload"))
        reloadBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(0.4, 1, 0.4) end)
        reloadBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        reloadBtn:SetScript("OnClick", function() pop:Hide(); ReloadUI() end)

        -- OK button (left of Reload) — dismiss without reloading.
        local okBtn = CreateFrame("Button", nil, pop, "BackdropTemplate")
        okBtn:SetSize(100, 24) okBtn:SetPoint("RIGHT", reloadBtn, "LEFT", -6, 0)
        MakeBg(okBtn, 0.15, 0.15, 0.18, 1)
        local oT = okBtn:CreateFontString(nil, "OVERLAY") ApplyFont(oT, 11)
        oT:SetPoint("CENTER") oT:SetTextColor(RGB(ACCENT))
        oT:SetText(LS("DLG_OK", "OK"))
        okBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        okBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        okBtn:SetScript("OnClick", function() pop:Hide() end)

        pop:Show()
    end

    w[#w+1] = CreateDropdown(p, LS("SEC_LANGUAGE", "Language"),
        { { value = "auto",  label = "Auto" },
          { value = "enUS",  label = "English" },
          { value = "deDE",  label = "Deutsch" },
          { value = "frFR",  label = "Francais" },
          { value = "esES",  label = "Espanol" },
          { value = "ruRU",  label = "Russian" },
          { value = "zhCN",  label = "Chinese (Simplified)" },
          { value = "zhTW",  label = "Chinese (Traditional)" },
          { value = "koKR",  label = "Korean" },
          { value = "tlhTLH", label = "tlhIngan" } },
        function() return BIT.db.language or "auto" end,
        function(v)
            local old = BIT.db.language or "auto"
            if v == old then return end
            BIT.db.language = v
            if BIT.ApplyLocale then BIT:ApplyLocale() end
            ShowLangChangedPopup()
        end)

    -- Settings-window theme (cosmetic only). Tints border + glow +
    -- title-bar separator and swaps the title-bar centre crest.
    -- AUTO picks Alliance/Horde from UnitFactionGroup at open-time;
    -- DEFAULT keeps the BliZzi cyan look without a faction crest.
    w[#w+1] = CreateSectionHeader(p, LS("SEC_THEME", "Theme"), "sui_gen_theme")
    w[#w+1] = CreateDropdown(p, LS("DD_THEME", "Settings Theme"),
        { { value = "AUTO",     label = LS("THEME_AUTO",     "Auto (by faction)") },
          { value = "ALLIANCE", label = LS("THEME_ALLIANCE", "Alliance") },
          { value = "HORDE",    label = LS("THEME_HORDE",    "Horde") },
          { value = "DEFAULT",  label = LS("THEME_DEFAULT",  "Default (BliZzi)") } },
        function() return BIT.db.settingsTheme or "AUTO" end,
        function(v)
            BIT.db.settingsTheme = v
            -- Live-apply so the user sees the new colours / crest the
            -- moment they pick from the dropdown. Cheap operation.
            if BIT.SettingsUI and BIT.SettingsUI.ApplyTheme then
                BIT.SettingsUI:ApplyTheme()
            end
        end)

    -- Font — single, global font face used by every feature in the
    -- addon (interrupt bars, keystone list, M+ tools, etc.). Lives on
    -- the General page in 3.8.0+ because it's a cross-cutting setting;
    -- no per-feature font selection anymore. Anything that renders text
    -- pulls the path/name via BIT.Media.font/fontName + ApplyFont(),
    -- so the setter writes both BIT.db.* and BIT.Media.* and then asks
    -- the visible feature modules to redraw.
    w[#w+1] = CreateSectionHeader(p, LS("SEC_FONT", "Font"), "sui_gen_font")
    w[#w+1] = CreateDropdown(p, LS("DD_FONT", "Font"),
        MediaOpts(function() return BIT.Media:GetAvailableFonts() end, "font"),
        function() return BIT.db.fontName or BIT.Media.fontName or "Default" end,
        function(v)
            for _, e in ipairs(BIT.Media:GetAvailableFonts()) do
                if e.name == v then
                    BIT.db.fontPath = e.path; BIT.db.fontName = e.name
                    BIT.Media.font  = e.path; BIT.Media.fontName = e.name
                    break
                end
            end
            -- Refresh every feature that renders text so the new font
            -- shows immediately without /reload. Each call is nil-guarded
            -- so missing or never-loaded modules are silently skipped.
            if BIT.UI and BIT.UI.RebuildBars then BIT.UI:RebuildBars() end
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)

    -- Custom Name
    w[#w+1] = CreateSectionHeader(p, LS("SEC_CUSTOM_NAME", "Custom Name"), "sui_gen_cnames")
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_CUSTOM_NAMES", "Show Custom Names"),
        function() return BIT.db.showCustomNames end,
        function(v) BIT.db.showCustomNames = v end)
    -- Per-feature filter: when the master toggle above is ON, this
    -- dropdown decides WHICH features substitute custom names for
    -- character names. Unchecking a feature shows the raw character
    -- name in that feature only — useful when the user wants
    -- nicknames for some surfaces (Interrupt Tracker) but real
    -- names elsewhere (Keystone List for accountability).
    w[#w+1] = CreateMultiSelectDropdown(p,
        LS("CUSTOM_NAMES_FEATURES", "Apply to"),
        { { value = "INTERRUPTS",    label = LS("CUSTOM_NAMES_FT_INTERRUPTS",    "Interrupt Tracker") },
          { value = "PARTY_CDS",     label = LS("CUSTOM_NAMES_FT_PARTY_CDS",     "Party CDs") },
          { value = "KEYSTONE_LIST", label = LS("CUSTOM_NAMES_FT_KEYSTONE_LIST", "Keystone List") } },
        function()
            return BIT.db.customNamesFeatures
                or { INTERRUPTS = true, PARTY_CDS = true, KEYSTONE_LIST = true }
        end,
        function(v)
            BIT.db.customNamesFeatures = v
            -- Live-refresh visible name labels across all features.
            if BIT.UI and BIT.UI.UpdateDisplay then BIT.UI:UpdateDisplay() end
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
            if BIT.KeystoneList and BIT.KeystoneList.RebuildDisplays then
                BIT.KeystoneList:RebuildDisplays()
            end
        end)
    -- Shared local-UI refresh helper for the nickname-related
    -- setters below. When the user changes their own nickname
    -- (per-char / global / use-global toggle), BroadcastHello tells
    -- OTHER players via the addon channel — but the LOCAL Party CD
    -- frame and Keystone List don't re-render until something else
    -- triggers them. Without these explicit calls only the Interrupt
    -- Tracker would pick up the change (it re-renders per tick).
    local function _refreshOwnNickname()
        if BIT.UI and BIT.UI.UpdateDisplay then BIT.UI:UpdateDisplay() end
        if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
            BIT.PartyCooldowns:RebuildAnchors()
        end
        if BIT.KeystoneList and BIT.KeystoneList.RebuildDisplays then
            BIT.KeystoneList:RebuildDisplays()
        end
    end

    -- Per-character nickname (stored in BIT.charDb.myCustomName)
    w[#w+1] = CreateEditBox(p, LS("CUSTOM_NAMES_NICK_CHAR", "Character Nickname"),
        function() return (BIT.charDb and BIT.charDb.myCustomName) or "" end,
        function(v)
            if not BIT.charDb then return end
            BIT.charDb.myCustomName = v
            if BIT.Self and BIT.Self.BroadcastHello then BIT.Self:BroadcastHello() end
            _refreshOwnNickname()
        end)
    -- Global override: use the same nickname on every character
    w[#w+1] = CreateToggle(p, LS("CUSTOM_NAMES_USE_GLOBAL", "Use Global Nickname (overrides per-character)"),
        function() return BIT.db.useGlobalCustomName end,
        function(v)
            BIT.db.useGlobalCustomName = v
            if BIT.Self and BIT.Self.BroadcastHello then BIT.Self:BroadcastHello() end
            _refreshOwnNickname()
        end)
    w[#w+1] = CreateEditBox(p, LS("CUSTOM_NAMES_NICK_GLOBAL", "Global Nickname"),
        function() return BIT.db.globalCustomName or "" end,
        function(v)
            BIT.db.globalCustomName = v
            if BIT.db.useGlobalCustomName and BIT.Self and BIT.Self.BroadcastHello then
                BIT.Self:BroadcastHello()
            end
            _refreshOwnNickname()
        end)

    return w
end

------------------------------------------------------------
-- ── Category: Interrupt Tracker ──────────────────────────
-- This page now owns the visual-styling sections that used to live
-- on their own "Size & Font" and "Colors" top-level pages (3.8.0
-- consolidation: each feature gets its own complete settings, no
-- shared global "Size & Font" / "Colors" pages anymore).
--
-- The size/font and colors widgets are still authored in their
-- original BuildSizeFont and BuildColors functions further down the
-- file (forward-declared below so this function can call them);
-- BuildInterrupts simply appends their widget output at the end of
-- its own list. Keeping the helpers as separate functions keeps the
-- diff small and lets us reuse the exact same widget set without
-- copy-pasting hundreds of lines.
------------------------------------------------------------
local BuildSizeFont  -- forward declaration (defined later in this file)
local BuildColors    -- forward declaration (defined later in this file)
local function BuildInterrupts()
    local w = {}
    local p = contentChild

    -- ── Patch 12.0.7 disclosure banner ──────────────────────────────
    -- Explains why the interrupt display looks different now, so players
    -- don't think it's broken: the game stopped exposing the data the
    -- old per-player tracking needed, leaving a recent-interrupt history
    -- as the only thing still possible. Same layout as the Party CDs /
    -- Smart Misdirect banners.
    do
        local f = CreateFrame("Frame", nil, p, "BackdropTemplate")
        local frameWidth = p:GetWidth() - CONTENT_PAD * 2
        MakeBg(f, 0.13, 0.18, 0.30, 0.95)
        f:SetBackdropBorderColor(0.3, 0.5, 1.0, 0.9)

        local title = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(title, 13, "OUTLINE")
        title:SetPoint("TOPLEFT", 10, -6)
        title:SetTextColor(0.5, 0.8, 1.0)
        title:SetText(LS("INFO_INT_127_TITLE", "斷法追蹤器已重製"))

        local body = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(body, 11)
        body:SetPoint("TOPLEFT", 10, -26)
        body:SetWidth(frameWidth - 20)
        body:SetJustifyH("LEFT")
        body:SetJustifyV("TOP")
        body:SetWordWrap(true)
        body:SetNonSpaceWrap(false)
        body:SetTextColor(0.95, 0.95, 1.0)
        body:SetText(LS("INFO_INT_127_BODY",
            "自至暗之夜上線以來，我一直試著把斷法追蹤器做到完美。但其他玩家的斷法根本無法 100% 可靠地追蹤——遊戲不會向插件公開這些資料。\n\n所以現在改為：不再顯示舊的計條，而是顯示最近斷法的歷史紀錄（誰打斷了哪個法術）。你自己的斷法條仍然顯示真實的冷卻時間。\n\n這是刻意設計，不是錯誤。勾選下方選項後此提示將不再顯示。"))

        local bodyH = body:GetStringHeight()
        f:SetSize(frameWidth, math.max(50, 26 + bodyH + 8))

        w[#w+1] = f
        do
            local sp = CreateFrame("Frame", nil, p)
            sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
            w[#w+1] = sp
        end
    end

    -- ── Interactive bar preview ──────────────────────────────────────
    -- A static, representative interrupt bar sits under the info banner.
    -- Every visible part carries an invisible click overlay: hovering shows
    -- an accent outline, clicking smooth-scrolls the panel to that part's
    -- settings section and flashes it. All parts are always shown (even ones
    -- the user has hidden via toggles) so they stay reachable as jump targets.
    do
        local pv = CreateFrame("Frame", nil, p)
        pv:SetSize(p:GetWidth() - CONTENT_PAD * 2, 82)

        -- Sticky header: the preview stays in the scroll child (so it reserves
        -- its slot and scrolls normally near the top), but _stickPreview pins it
        -- to the top once it would scroll off — the info banner above scrolls
        -- away underneath. Raised above the list + an opaque backdrop so the
        -- scrolling sections are hidden behind it while pinned, with a thin
        -- divider so the pinned header reads as separate from the list.
        pv._stickyTop = true
        pv:SetFrameLevel((contentChild:GetFrameLevel() or 1) + 50)
        local pvBg = pv:CreateTexture(nil, "BACKGROUND")
        pvBg:SetPoint("TOPLEFT",     pv, "TOPLEFT",     -CONTENT_PAD, 2)
        pvBg:SetPoint("BOTTOMRIGHT", pv, "BOTTOMRIGHT",  CONTENT_PAD, 0)
        -- Match the sidebar exactly: themed colour at 0.9 alpha (the sidebar /
        -- title bar are drawn the same way), so the pinned header reads as the
        -- same translucent panel rather than a solid patch.
        local _pal = GetThemePalette()
        pvBg:SetColorTexture(_pal.sidebarBg[1], _pal.sidebarBg[2], _pal.sidebarBg[3], 0.9)
        local pvLine = pv:CreateTexture(nil, "ARTWORK")
        pvLine:SetHeight(1)
        pvLine:SetPoint("BOTTOMLEFT",  pv, "BOTTOMLEFT",  -CONTENT_PAD, 0)
        pvLine:SetPoint("BOTTOMRIGHT", pv, "BOTTOMRIGHT",  CONTENT_PAD, 0)
        pvLine:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.5)
        -- The header backdrop + divider only make sense once the preview is
        -- pinned. They fade IN the moment it docks at the top (and fade out when
        -- it lifts off) — a time-based fade triggered by the pin STATE, not a
        -- scroll gradient. _stickPreview sets the target; pv's OnUpdate eases the
        -- shared factor (SetAlpha multiplies the 0.9 / 0.5 base alphas).
        pvBg:SetAlpha(0); pvLine:SetAlpha(0)
        pv._hdrFactor = 0
        pv:SetScript("OnUpdate", function(self, e)
            local target = self._hdrTarget or 0
            local cur    = self._hdrFactor or 0
            if cur == target then return end
            local step = e / 0.18                 -- fade duration ~0.18s
            if target > cur then cur = math.min(target, cur + step)
            else                 cur = math.max(target, cur - step) end
            self._hdrFactor = cur
            pvBg:SetAlpha(cur)
            pvLine:SetAlpha(cur)
        end)
        _stickPreview = function()
            if not pv:IsShown() or not pv._flowY then return end
            local s = (contentScroll and contentScroll:GetVerticalScroll()) or 0
            pv._hdrTarget = (s >= pv._flowY) and 1 or 0
            pv:ClearAllPoints()
            pv:SetPoint("TOPLEFT", contentChild, "TOPLEFT", CONTENT_PAD, -math.max(s, pv._flowY))
        end

        -- Forward declarations: the hit factory references these before they
        -- are assigned further down (closures capture by reference, and a
        -- click can't fire until the whole block has run).
        local _dismissHint
        local _scrollAnim, _flashTex, _flashAnim

        -- Locate a section header in the live page widget list by its stateKey.
        local function _findSection(stateKey)
            local pg = pages[activePage]
            if not pg or not pg.widgets then return nil end
            for _, wd in ipairs(pg.widgets) do
                if wd._stateKey == stateKey then return wd end
            end
            return nil
        end

        -- Eased smooth scroll of the content frame to an absolute offset.
        local function _smoothScrollTo(target)
            if not contentScroll then return end
            local maxS = contentScroll:GetVerticalScrollRange() or 0
            if target < 0 then target = 0 elseif target > maxS then target = maxS end
            if _scrollAnim then _scrollAnim:Cancel(); _scrollAnim = nil end
            local start = contentScroll:GetVerticalScroll() or 0
            local dist  = target - start
            if math.abs(dist) < 1 then contentScroll:SetVerticalScroll(target); return end
            local i, steps = 0, 12
            _scrollAnim = C_Timer.NewTicker(0.016, function()
                i = i + 1
                local t = i / steps
                local e = 1 - (1 - t) * (1 - t)       -- ease-out quad
                contentScroll:SetVerticalScroll(start + dist * e)
                if i >= steps then
                    contentScroll:SetVerticalScroll(target)
                    if _scrollAnim then _scrollAnim:Cancel(); _scrollAnim = nil end
                end
            end)
        end

        -- Brief accent flash over a section header so the landing spot is obvious.
        local function _flashSection(sec)
            if not _flashTex then
                _flashTex = contentChild:CreateTexture(nil, "OVERLAY")
                _flashTex:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 1)
                _flashTex:Hide()
            end
            _flashTex:ClearAllPoints()
            _flashTex:SetPoint("TOPLEFT",     sec, "TOPLEFT",     0, 0)
            _flashTex:SetPoint("BOTTOMRIGHT", sec, "BOTTOMRIGHT", 0, 0)
            _flashTex:SetAlpha(0.35)
            _flashTex:Show()
            if _flashAnim then _flashAnim:Cancel() end
            local i, steps = 0, 28
            _flashAnim = C_Timer.NewTicker(0.02, function()
                i = i + 1
                _flashTex:SetAlpha(0.35 * (1 - i / steps))
                if i >= steps then
                    _flashTex:Hide()
                    if _flashAnim then _flashAnim:Cancel(); _flashAnim = nil end
                end
            end)
        end

        -- Expand (if collapsed), scroll to, and flash a section by stateKey.
        local function _navigateTo(stateKey)
            local sec = _findSection(stateKey)
            if not sec then return end
            if sec._stateKey and not sec._expanded then
                sec._expanded = true
                if BIT.db and BIT.db.sectionExpanded then
                    BIT.db.sectionExpanded[sec._stateKey] = true
                end
                if sec._arrowFs then sec._arrowFs:SetText("v") end
                local pg = pages[activePage]
                if pg then
                    if pg.refresh then pg.refresh() end
                    if pg.layout  then pg.layout()  end
                end
            end
            local _, _, _, _, y = sec:GetPoint(1)
            if not y then return end
            -- Offset by the sticky preview's height so the target lands BELOW
            -- the pinned header instead of scrolling behind it.
            _smoothScrollTo(math.max(0, math.abs(y) - (pv:GetHeight() or 0) - 12))
            C_Timer.After(0.12, function() _flashSection(sec) end)
        end

        -- Invisible click overlay over a preview part. `sizeToText` fits the
        -- button to a FontString; otherwise it covers the whole region.
        -- `lvl` is a frame-level offset so overlapping parts (marker > icon,
        -- name/cd > bar, bar > background) resolve to the more specific one.
        local function _addHit(target, stateKey, sizeToText, lvl)
            local btn = CreateFrame("Button", nil, pv)
            -- Sit well above the preview bar's own border + content frames so the
            -- hover outline draws ON TOP of the bar border (which would otherwise
            -- cover it). `lvl` still orders overlapping parts amongst themselves.
            btn:SetFrameLevel((pv:GetFrameLevel() or 1) + 30 + (lvl or 6))
            if sizeToText then
                local function fit()
                    local tw = (target.GetStringWidth and target:GetStringWidth()) or 20
                    local th = (target.GetStringHeight and target:GetStringHeight()) or 12
                    btn:SetSize(math.max(8, tw) + 6, math.max(8, th) + 4)
                end
                fit()
                -- Anchor by the FontString's justification so the box sits over
                -- the actual glyphs (a left/right-justified text frame can be far
                -- wider than its text — centering would float the box in empty
                -- space) and tracks the text when its position changes.
                local just = (target.GetJustifyH and target:GetJustifyH()) or "CENTER"
                if just == "LEFT" then
                    btn:SetPoint("LEFT", target, "LEFT", -3, 0)
                elseif just == "RIGHT" then
                    btn:SetPoint("RIGHT", target, "RIGHT", 3, 0)
                else
                    btn:SetPoint("CENTER", target, "CENTER", 0, 0)
                end
                btn:SetScript("OnShow", fit)
            else
                btn:SetAllPoints(target)
            end
            local hl = CreateFrame("Frame", nil, btn, "BackdropTemplate")
            hl:SetPoint("TOPLEFT", -2, 2)
            hl:SetPoint("BOTTOMRIGHT", 2, -2)
            hl:SetBackdrop({ edgeFile = WHITE8, edgeSize = 1 })
            hl:SetBackdropBorderColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
            hl:Hide()
            btn:SetScript("OnEnter", function() hl:Show() end)
            btn:SetScript("OnLeave", function() hl:Hide() end)
            btn:SetScript("OnMouseDown", function()
                if _dismissHint then _dismissHint() end
                _navigateTo(stateKey)
            end)
            return btn
        end

        -- One-time hint under the bar; fades away the first time a part is clicked.
        local hintFS = pv:CreateFontString(nil, "OVERLAY")
        ApplyFont(hintFS, 11)
        hintFS:SetTextColor(RGB(TEXT_DIM))
        hintFS:SetText(LS("PRV_HINT", "Tip: click a part of the bar above to jump to its settings"))
        if BIT.db and BIT.db.interruptPreviewHintDismissed then hintFS:Hide() end
        _dismissHint = function()
            if hintFS:IsShown() then
                hintFS:Hide()
                if BIT.db then BIT.db.interruptPreviewHintDismissed = true end
            end
        end

        -- (Re)build the preview from the LIVE config and wire up the jump
        -- overlays. The bar itself is rendered by BIT.UI:BuildPreviewBar so it
        -- matches the real tracker exactly (texture / colours / sizes / border);
        -- here we only place it and lay the invisible click overlays on top.
        -- Only parts that are actually visible (per the user's toggles) get an
        -- overlay — the preview is faithful, so a hidden element isn't a target.
        local function _buildPreview()
            if pv._bar then pv._bar:Hide(); pv._bar:SetParent(nil); pv._bar = nil end
            if pv._hits then
                for _, b in ipairs(pv._hits) do b:Hide(); b:SetParent(nil) end
            end
            pv._hits = {}

            local bar = (BIT.UI and BIT.UI.BuildPreviewBar) and BIT.UI:BuildPreviewBar(pv) or nil
            if not bar then pv:SetHeight(24); return end
            pv._bar = bar

            -- Top room = icon overhang above the bar top + the title line +
            -- breathing room above the title so it isn't flush with the top edge.
            local bh     = bar:GetHeight() or 30
            local over   = math.max(0, (bar._iconS or 0) - (bar._barH or bh))
            local tShown = bar._previewTitle and bar._previewTitle:IsShown()
            local tH     = tShown and ((bar._previewTitle:GetStringHeight() or 12) + 5) or 0
            local top    = over + tH + 16
            bar:ClearAllPoints()
            bar:SetPoint("TOP", pv, "TOP", 0, -top)

            local hintH = hintFS:IsShown() and 16 or 2
            pv:SetHeight(top + bh + 10 + hintH)
            hintFS:ClearAllPoints()
            hintFS:SetPoint("TOP", bar, "BOTTOM", 0, -9)

            local function add(target, key, txt, lvl)
                if not target then return end
                if target.IsShown and not target:IsShown() then return end
                pv._hits[#pv._hits + 1] = _addHit(target, key, txt, lvl)
            end
            add(bar,               "sui_sf_frame",        false, 2)
            add(bar.cdBar,         "sui_sf_bartex",       false, 4)
            add(bar.icon,          "sui_int_displaymode", false, 4)
            add(bar._previewTitle, "sui_sf_title",        true,  6)
            add(bar.nameText,      "sui_sf_name",         true,  8)
            add(bar.partyCdText,   "sui_sf_cd",           true,  8)
            add(bar.intMark,       "sui_int_displaymode", false, 10)

            -- The preview's height may have changed → re-flow so its slot is
            -- reserved correctly and the sticky position is recomputed (the
            -- layout pass re-pins via _stickPreview at its end).
            if pages and pages[activePage] and pages[activePage].layout then
                pages[activePage].layout()
            end
        end

        _buildPreview()
        -- Live update: RebuildBars (the live renderer) fires on every visual
        -- setting change; re-render the preview from the same data so it stays
        -- in sync. Debounced (slider drags fire RebuildBars per step) and
        -- guarded to the interrupt page being on-screen.
        if BIT.UI then
            BIT.UI._previewRebuild = function()
                if not pv:IsShown() or pv._pendingBuild then return end
                pv._pendingBuild = true
                C_Timer.After(0.03, function()
                    pv._pendingBuild = false
                    if pv:IsShown() then _buildPreview() end
                end)
            end
        end

        w[#w+1] = pv
        do
            local sp = CreateFrame("Frame", nil, p)
            sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
            w[#w+1] = sp
        end
    end

    -- General
    w[#w+1] = CreateSectionHeader(p, LS("SEC_GENERAL", "General"), "sui_int_gen")
    w[#w+1] = CreateToggle(p, LS("INT_ENABLE", "Enable Interrupt Tracker"),
        function() return BIT.db.interruptTrackerEnabled ~= false end,
        function(v)
            BIT.db.interruptTrackerEnabled = v
            if not BIT.Interrupts then return end
            if v then BIT.Interrupts:Enable() else BIT.Interrupts:Disable() end
        end)
    w[#w+1] = CreateToggle(p, LS("SEC_TEST_MODE", "Test Mode"),
        function() return BIT.testMode end,
        function(v) if v then BIT:StartTestMode() else BIT:StopTestMode() end end)
    w[#w+1] = CreateToggle(p, LS("SEC_SOLO_MODE", "Solo Mode") .. " |cFF888888(" .. LS("SEC_SOLO_MODE_HINT", "only your own interrupt is tracked") .. ")|r",
        function() return BIT.db.soloMode end,
        function(v)
            BIT.db.soloMode = v
            if BIT.UI.UpdateDisplay then BIT.UI:UpdateDisplay() end
            if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
                BIT.UI.AttachedInterrupts:Rebuild()
            end
        end)
    w[#w+1] = CreateToggle(p, LS("CB_HIDE_OUT_OF_COMBAT", "Hide Out of Combat"),
        function() return BIT.db.hideOutOfCombat end,
        function(v) BIT.db.hideOutOfCombat = v end)
    w[#w+1] = CreateToggle(p, LS("CB_INTERRUPT_TOOLTIP", "Show Tooltips"),
        function() return BIT.db.interruptTooltip ~= false end,
        function(v) BIT.db.interruptTooltip = v and true or false end)
    w[#w+1] = CreateSlider(p, LS("SL_RECORD_DURATION", "Interrupt history — entry duration"), 5, 30, 1,
        function() return BIT.db.interruptRecordDuration or 15 end,
        function(v) BIT.db.interruptRecordDuration = v end,
        function(v) return math.floor(v) .. "s" end)
    w[#w+1] = CreateLabel(p, LS("INFO_INTERRUPT_HISTORY",
        "This list is a HISTORY of recent interrupts (who interrupted which spell) — it is NOT a cooldown tracker. "
        .. "The timer only controls how long each entry stays shown; it does NOT show when that player's interrupt is "
        .. "ready again. The game does not give addons another player's interrupt cooldown."),
        11, {1, 0.82, 0})
    w[#w+1] = CreateSlider(p, LS("SL_OPACITY", "Opacity"), 10, 100, 5,
        function() return (BIT.db.alpha or 1) * 100 end,
        function(v) BIT.db.alpha = v / 100 end,
        function(v) return math.floor(v) .. "%" end)

    -- Frame strata: which UI layer the standalone tracker window draws on
    -- (Background ... Dialog). Lets users push the tracker behind or in
    -- front of other addons / default UI. Applied live, no reload needed.
    w[#w+1] = CreateDropdown(p, LS("DD_FRAME_STRATA", "Frame Layer (Strata)"),
        { { value = "BACKGROUND", label = LS("STRATA_BACKGROUND", "Background") },
          { value = "LOW",        label = LS("STRATA_LOW",        "Low") },
          { value = "MEDIUM",     label = LS("STRATA_MEDIUM",     "Medium (default)") },
          { value = "HIGH",       label = LS("STRATA_HIGH",       "High") },
          { value = "DIALOG",     label = LS("STRATA_DIALOG",     "Dialog (on top)") } },
        function() return BIT.db.interruptFrameStrata or "MEDIUM" end,
        function(v)
            BIT.db.interruptFrameStrata = v
            if BIT.UI.ApplyFrameStrata then BIT.UI:ApplyFrameStrata() end
            -- Attached Icons re-apply strata only on rebuild; Attached Bars
            -- pick it up on the next 0.1s layout tick automatically.
            if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
                BIT.UI.AttachedInterrupts:Rebuild()
            end
        end)

    -- Display mode selector + mode-scoped bar-window options
    w[#w+1] = CreateSectionHeader(p, LS("SEC_DISPLAY_MODE", "Display Mode"), "sui_int_displaymode")

    -- Forward declarations so the dropdown setter can re-evaluate the
    -- mode-scoped widgets on change and trigger a page re-layout.
    local lockToggle, growToggle, showIconToggle, markerToggle, iconPosDD, barFillDD, sortDD
    local freeToggle, freeRow, freeOffX, freeOffY
    local function _syncBarsOnlyVisibility()
        local mode    = BIT.db.interruptDisplayMode or "BARS"
        local bars    = mode == "BARS"
        -- Icon-side + bar-fill affect bar rendering in BOTH the standalone
        -- window and the attached-bars mode, so show them for both. Lock /
        -- grow / sort only make sense for the stacked standalone window.
        local barLike = bars or mode == "ATTACHED_BARS"
        local setVis = function(wd, show)
            if not wd then return end
            if show then wd:Show() else wd:Hide() end
        end
        setVis(lockToggle, bars)
        setVis(growToggle, bars)
        setVis(showIconToggle, barLike)
        -- Icon Position + raid-marker toggle only matter while the icon is
        -- actually shown (the marker is a badge on the icon).
        setVis(iconPosDD,    barLike and BIT.db.showIcon ~= false)
        setVis(markerToggle, barLike and BIT.db.showIcon ~= false)
        setVis(barFillDD,  barLike)
        setVis(sortDD,     bars)
        -- Free Anchor (Standalone only). Toggle shows in BARS mode; the
        -- target row needs it on; the offset sliders also need a picked frame.
        local freeOn = bars and (BIT.db.interruptFreeAnchor == true)
        local freePicked = freeOn
            and type(BIT.db.interruptFreeAnchorTarget) == "string"
            and BIT.db.interruptFreeAnchorTarget ~= ""
        setVis(freeToggle, bars)
        setVis(freeRow,    freeOn)
        setVis(freeOffX,   freePicked)
        setVis(freeOffY,   freePicked)
        if pages and pages[activePage] and pages[activePage].layout then
            pages[activePage].layout()
        end
    end

    -- Forward declaration: the Attached-Display sync closure is defined
    -- later in this function (after the section is built). Calling it via
    -- a local upvalue that gets assigned before the first layout pass.
    local _syncAttachedVisibility = function() end  -- replaced below

    -- Display Mode dropdown removed: with the interrupt-history rework a kick
    -- can't be tied to a specific party member, so the attached modes were
    -- meaningless — the tracker is standalone-only now. The mode is forced to
    -- "BARS" for every saved profile at login (see BIT:Initialize), so anyone
    -- who had picked an attached mode is migrated back to the window
    -- automatically. The attached-mode widgets below stay in the code but are
    -- permanently hidden (mode is always BARS).

    -- Bars/Window-only options: Lock Position + Grow Upward. These belong
    -- to the classic bars renderer and make no sense for the attached
    -- per-member icons, so they are hidden when mode is "ATTACHED".
    lockToggle = CreateToggle(p, LS("CB_LOCK_POSITION", "Lock Position"),
        function() return BIT.db.locked end,
        function(v) BIT.db.locked = v end)
    lockToggle._dynamic = true
    lockToggle._update  = _syncBarsOnlyVisibility
    w[#w+1] = lockToggle

    growToggle = CreateToggle(p, LS("CB_GROW_UPWARD", "Grow Upward"),
        function() return BIT.db.growUpward end,
        function(v) BIT.db.growUpward = v end)
    growToggle._dynamic = true
    growToggle._update  = _syncBarsOnlyVisibility
    w[#w+1] = growToggle

    showIconToggle = CreateToggle(p, LS("CB_SHOW_ICON", "Show Icon"),
        function() return BIT.db.showIcon ~= false end,
        function(v)
            BIT.db.showIcon = v
            -- The icon column width is baked into the bar layout at build
            -- time, so rebuild for instant feedback; re-sync so the Icon
            -- Position dropdown appears/disappears with the toggle.
            if BIT.UI.RebuildBars then BIT.UI:RebuildBars() end
            _syncBarsOnlyVisibility()
        end)
    showIconToggle._dynamic = true
    do  -- chain, don't overwrite: keep CreateToggle's visual refresh
        local origUpdate = showIconToggle._update
        showIconToggle._update = function()
            if origUpdate then origUpdate() end
            _syncBarsOnlyVisibility()
        end
    end
    w[#w+1] = showIconToggle

    -- Show the interrupted mob's raid target marker (a badge on the icon).
    -- On by default. Only visible while "Show Icon" is on — the marker rides
    -- the icon, so it has no meaning without one (visibility owned by
    -- _syncBarsOnlyVisibility).
    markerToggle = CreateToggle(p, LS("CB_SHOW_MARKER", "Show raid markers"),
        function() return BIT.db.interruptShowMarker ~= false end,
        function(v)
            BIT.db.interruptShowMarker = v
            if BIT.UI.UpdateDisplay then BIT.UI:UpdateDisplay() end
        end)
    markerToggle._dynamic = true
    markerToggle._update  = _syncBarsOnlyVisibility
    w[#w+1] = markerToggle

    iconPosDD = CreateDropdown(p, LS("SEC_ICON_POSITION", "Icon Position"),
        { { value = "LEFT",  label = LS("ICON_LEFT",  "Left") },
          { value = "RIGHT", label = LS("ICON_RIGHT", "Right") } },
        function() return BIT.db.iconSide or "LEFT" end,
        function(v) BIT.db.iconSide = v; if BIT.UI.RebuildBars then BIT.UI:RebuildBars() end end)
    iconPosDD._dynamic = true
    iconPosDD._update  = _syncBarsOnlyVisibility
    w[#w+1] = iconPosDD

    barFillDD = CreateDropdown(p, LS("SEC_BAR_FILL", "Bar Fill Mode"),
        { { value = "DRAIN", label = LS("FILL_DRAIN", "Drain") },
          { value = "FILL",  label = LS("FILL_FILL",  "Fill") } },
        function() return BIT.db.barFillMode or "DRAIN" end,
        function(v) BIT.db.barFillMode = v end)
    barFillDD._dynamic = true
    barFillDD._update  = _syncBarsOnlyVisibility
    w[#w+1] = barFillDD

    sortDD = CreateDropdown(p, LS("SEC_SORT_ORDER", "Sort Order"),
        { { value = "NONE",    label = LS("SORT_NONE", "None") },
          { value = "CD_ASC",  label = LS("SORT_ASC",  "CD Ascending") },
          { value = "CD_DESC", label = LS("SORT_DESC", "CD Descending") } },
        function() return BIT.db.sortMode or "NONE" end,
        function(v) BIT.db.sortMode = v end)
    sortDD._dynamic = true
    sortDD._update  = _syncBarsOnlyVisibility
    w[#w+1] = sortDD

    -- Shared helper: register a bars-only widget so it lays out + hides with
    -- the bar settings. Used by the Free Anchor controls below. (The old
    -- "Anchor to unit frames" controls were removed — Free Anchor replaces them.)
    local function registerBarsAnchor(wd)
        wd._dynamic = true
        -- Chain, don't overwrite: keep the widget's own value/visual
        -- refresh (toggle checkmark, slider value) working on profile
        -- switches, then apply the mode-visibility sync.
        local origUpdate = wd._update
        wd._update = function()
            if origUpdate then origUpdate() end
            _syncBarsOnlyVisibility()
        end
        w[#w + 1] = wd
    end

    -- ── Free Anchor: pin the window to ANY frame (mouse-picked) ──
    -- Bars/window-only (see ApplyFramePosition). Visibility is owned by
    -- _syncBarsOnlyVisibility above (toggle shows in BARS mode; the target row
    -- needs Free Anchor on; the offset sliders also need a frame to be picked).
    freeToggle = CreateToggle(p, LS("CB_FREE_ANCHOR", "Free Anchor (pick a frame)"),
        function() return BIT.db.interruptFreeAnchor == true end,
        function(v)
            BIT.db.interruptFreeAnchor = v
            if BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
            _syncBarsOnlyVisibility()
        end)
    registerBarsAnchor(freeToggle)

    -- Picked-target text + "Pick with Mouse" button (one row).
    do
        local rowWidth = p:GetWidth() - CONTENT_PAD * 2
        freeRow = CreateFrame("Frame", nil, p)
        freeRow:SetSize(rowWidth, WIDGET_H + 4)

        local nameFs = freeRow:CreateFontString(nil, "OVERLAY")
        ApplyFont(nameFs, 11)
        nameFs:SetPoint("LEFT", 0, 0)
        nameFs:SetWidth(rowWidth - 150)
        nameFs:SetJustifyH("LEFT")
        nameFs:SetWordWrap(false)

        local btn = CreateFrame("Button", nil, freeRow, "BackdropTemplate")
        btn:SetSize(140, 24)
        btn:SetPoint("RIGHT", 0, 0)
        MakeBg(btn, 0.15, 0.15, 0.18, 1)
        local btxt = btn:CreateFontString(nil, "OVERLAY")
        ApplyFont(btxt, 11)
        btxt:SetPoint("CENTER")
        btxt:SetTextColor(RGB(ACCENT))
        btxt:SetText(LS("BTN_PICK_FRAME", "Pick with Mouse"))
        btn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        btn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        btn:SetScript("OnClick", function()
            if BIT.SettingsUI.StartInterruptAnchorPick then
                BIT.SettingsUI:StartInterruptAnchorPick()
            end
        end)

        -- _update only refreshes the displayed target name; visibility is
        -- owned by _syncBarsOnlyVisibility (registerBarsAnchor chains it in).
        freeRow._update = function()
            local picked = type(BIT.db.interruptFreeAnchorTarget) == "string"
                and BIT.db.interruptFreeAnchorTarget ~= ""
            local t = picked and BIT.db.interruptFreeAnchorTarget
                      or LS("FREE_ANCHOR_NONE", "(none picked)")
            nameFs:SetText("|cffaaaaaa" .. LS("FREE_ANCHOR_TARGET", "Anchor:")
                           .. "|r |cffffd700" .. t .. "|r")
        end
        registerBarsAnchor(freeRow)
    end

    freeOffX = CreateSlider(p, LS("FREE_ANCHOR_OFFX", "Free Anchor X"), -1000, 1000, 1,
        function() return BIT.db.interruptFreeAnchorX or 0 end,
        function(v)
            BIT.db.interruptFreeAnchorX = v
            if BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
        end,
        function(v) return math.floor(v) .. "px" end)
    registerBarsAnchor(freeOffX)

    freeOffY = CreateSlider(p, LS("FREE_ANCHOR_OFFY", "Free Anchor Y"), -1000, 1000, 1,
        function() return BIT.db.interruptFreeAnchorY or 0 end,
        function(v)
            BIT.db.interruptFreeAnchorY = v
            if BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
        end,
        function(v) return math.floor(v) .. "px" end)
    registerBarsAnchor(freeOffY)

    -- Apply initial visibility right after creation so the first layout
    -- pass already honors the current display mode.
    _syncBarsOnlyVisibility()

    -- Attached-mode widgets. All of these live directly under the existing
    -- "Display Mode" section header (no separate section of their own), are
    -- marked _dynamic, and hide away when the user is in Bars/Window mode.
    -- `_syncAttachedOnlyVisibility` owns the show/hide logic and is invoked
    -- by the Display Mode dropdown via the forward-declared
    -- `_syncAttachedVisibility` upvalue above.
    -- Attached widgets are grouped so each shows only in the right mode:
    --   "common" → shared by both attached modes (provider, offsets)
    --   "icon"   → icon-only attached mode (ATTACHED)
    --   "bar"    → attached-bars mode (ATTACHED_BARS)
    local attachedWidgets = {}  -- list of { wd = widget, group = "common"|"icon"|"bar" }
    local function _syncAttachedOnlyVisibility()
        local mode  = BIT.db.interruptDisplayMode or "BARS"
        local icons = mode == "ATTACHED"
        local barsM = mode == "ATTACHED_BARS"
        for _, e in ipairs(attachedWidgets) do
            local show = (e.group == "common" and (icons or barsM))
                      or (e.group == "icon" and icons)
                      or (e.group == "bar"  and barsM)
            if show then e.wd:Show() else e.wd:Hide() end
        end
        if pages and pages[activePage] and pages[activePage].layout then
            pages[activePage].layout()
        end
    end
    _syncAttachedVisibility = _syncAttachedOnlyVisibility  -- wire forward-decl

    -- Helper: register a widget into both the page widget list and the
    -- local attachedWidgets group, stamping it as _dynamic with the right
    -- _update callback so a full page re-layout respects its visibility.
    -- `group` defaults to "icon" (the original behaviour).
    local function registerAttached(wd, group)
        wd._dynamic = true
        wd._update  = _syncAttachedOnlyVisibility
        attachedWidgets[#attachedWidgets + 1] = { wd = wd, group = group or "icon" }
        w[#w + 1] = wd
    end

    -- All attached-display widgets live directly under the "Display Mode"
    -- section (no separate "Attached Display" header). They appear only
    -- when the Display Mode dropdown is set to "Attached to Unit Frames".
    -- Frame Provider list comes from BIT.UnitFrames (shared resolver).
    local attachProviderOpts = (BIT.UnitFrames and BIT.UnitFrames.GetAvailableProviders)
        and BIT.UnitFrames:GetAvailableProviders()
        or  { { value = "AUTO", label = LS("PROVIDER_AUTO", "Auto Detect") }, { value = "BLIZZARD", label = "Blizzard" } }
    registerAttached(CreateDropdown(p, LS("DD_ATTACH_FRAMES", "Attach to Frames"),
        attachProviderOpts,
        function() return BIT.db.interruptAttachFrameProvider or "AUTO" end,
        function(v)
            BIT.db.interruptAttachFrameProvider = v
            if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
                BIT.UI.AttachedInterrupts:Rebuild()
            end
        end), "common")
    -- ATTACHED_BARS only: where each member's full bar sits on their frame.
    registerAttached(CreateDropdown(p, LS("DD_ATTACH_BAR_POS", "Bar Position"),
        { { value = "TOP",     label = LS("ATTACH_BAR_TOP",     "Above frame") },
          { value = "BOTTOM",  label = LS("ATTACH_BAR_BOTTOM",  "Below frame") },
          { value = "OVERLAY", label = LS("ATTACH_BAR_OVERLAY", "Overlay frame") } },
        function() return BIT.db.interruptAttachBarPos or "TOP" end,
        function(v) BIT.db.interruptAttachBarPos = v end), "bar")
    -- ATTACHED_BARS only: match the unit frame width, or set a custom one.
    -- When matching, the Bar Width slider below is greyed out + shows info.
    local attachBarWidthSlider
    local matchInfo = LS("ATTACH_BAR_W_MATCH", "= frame")
    registerAttached(CreateToggle(p, LS("CB_ATTACH_BAR_MATCH_W", "Match unit frame width"),
        function() return BIT.db.interruptAttachBarMatchWidth ~= false end,
        function(v)
            BIT.db.interruptAttachBarMatchWidth = v
            if attachBarWidthSlider then
                attachBarWidthSlider:SetWidgetEnabled(not v, v and matchInfo or nil)
            end
        end), "bar")
    attachBarWidthSlider = CreateSlider(p, LS("SL_ATTACH_BAR_WIDTH", "Bar Width"), 40, 400, 1,
        function() return BIT.db.interruptAttachBarWidth or 120 end,
        function(v) BIT.db.interruptAttachBarWidth = v end,
        function(v) return math.floor(v) .. "px" end)
    registerAttached(attachBarWidthSlider, "bar")
    -- Initial greyed state mirrors the toggle (default = matching → greyed).
    attachBarWidthSlider:SetWidgetEnabled(
        BIT.db.interruptAttachBarMatchWidth == false,
        (BIT.db.interruptAttachBarMatchWidth ~= false) and matchInfo or nil)
    registerAttached(CreateDropdown(p, LS("DD_ATTACH_POS", "Attach Position"),
        { { value = "LEFT",   label = LS("SYNC_POS_LEFT",   "Left") },
          { value = "RIGHT",  label = LS("SYNC_POS_RIGHT",  "Right") },
          { value = "TOP",    label = LS("SYNC_POS_TOP",    "Top") },
          { value = "BOTTOM", label = LS("SYNC_POS_BOTTOM", "Bottom") } },
        function() return BIT.db.interruptAttachPos or "RIGHT" end,
        function(v)
            BIT.db.interruptAttachPos = v
            if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
                BIT.UI.AttachedInterrupts:Rebuild()
            end
        end))
    registerAttached(CreateSlider(p, LS("SL_OFFSET_X", "Offset X"), -100, 100, 1,
        function() return BIT.db.interruptAttachOffsetX or 0 end,
        function(v)
            BIT.db.interruptAttachOffsetX = v
            if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
                BIT.UI.AttachedInterrupts:Rebuild()
            end
        end,
        function(v) return math.floor(v) .. "px" end), "common")
    registerAttached(CreateSlider(p, LS("SL_OFFSET_Y", "Offset Y"), -100, 100, 1,
        function() return BIT.db.interruptAttachOffsetY or 0 end,
        function(v)
            BIT.db.interruptAttachOffsetY = v
            if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
                BIT.UI.AttachedInterrupts:Rebuild()
            end
        end,
        function(v) return math.floor(v) .. "px" end), "common")
    registerAttached(CreateSlider(p, LS("SL_SYNC_ICON_SIZE", "Icon Size"), 12, 64, 1,
        function() return BIT.db.interruptAttachIconSize or 32 end,
        function(v)
            BIT.db.interruptAttachIconSize = v
            if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
                BIT.UI.AttachedInterrupts:Rebuild()
            end
        end,
        function(v) return math.floor(v) .. "px" end))
    registerAttached(CreateSlider(p, LS("SL_SYNC_COUNTER_SIZE", "Counter Text Size"), 6, 28, 1,
        function() return BIT.db.interruptAttachCounterSize or 14 end,
        function(v)
            BIT.db.interruptAttachCounterSize = v
            if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
                BIT.UI.AttachedInterrupts:Rebuild()
            end
        end,
        function(v) return math.floor(v) .. "px" end))
    registerAttached(CreateToggle(p, LS("CB_ATT_DESATURATE", "Desaturate on Cooldown"),
        function() return BIT.db.interruptAttachDesaturateOnCD ~= false end,
        function(v) BIT.db.interruptAttachDesaturateOnCD = v end))
    registerAttached(CreateToggle(p, LS("CB_ATT_SHOW_OWN", "Show Own Icon on Player Frame"),
        function() return BIT.db.interruptAttachShowOwn ~= false end,
        function(v)
            BIT.db.interruptAttachShowOwn = v
            if BIT.UI.AttachedInterrupts and BIT.UI.AttachedInterrupts.Rebuild then
                BIT.UI.AttachedInterrupts:Rebuild()
            end
        end))

    -- Apply initial visibility so the first layout pass respects the mode.
    _syncAttachedOnlyVisibility()

    -- (Icon Only Mode was removed in 3.3.8 — use the new "Attached to Unit
    --  Frames" display mode above for a compact per-player layout.)

    -- Visibility
    w[#w+1] = CreateSectionHeader(p, LS("SEC_VISIBILITY", "Visibility"), "sui_int_vis")
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_DUNGEON", "Show in Dungeon"),
        function() return BIT.db.showInDungeon end,
        function(v) BIT.db.showInDungeon = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_RAID", "Show in Raid"),
        function() return BIT.db.showInRaid end,
        function(v) BIT.db.showInRaid = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_WORLD", "Show in Open World"),
        function() return BIT.db.showInOpenWorld end,
        function(v) BIT.db.showInOpenWorld = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_ARENA", "Show in Arena"),
        function() return BIT.db.showInArena end,
        function(v) BIT.db.showInArena = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_BG", "Show in Battleground"),
        function() return BIT.db.showInBG end,
        function(v) BIT.db.showInBG = v end)

    -- Failed Kick
    w[#w+1] = CreateSectionHeader(p, LS("SEC_FAILED_KICK", "Failed Kick Detection"), "sui_int_fk")
    w[#w+1] = CreateToggle(p, LS("CB_FAILED_KICK", "Show Failed Kick Detection"),
        function() return BIT.db.showFailedKick end,
        function(v) BIT.db.showFailedKick = v end)

    -- Sounds
    w[#w+1] = CreateSectionHeader(p, LS("SEC_SOUNDS", "Sounds"), "sui_int_snd")
    w[#w+1] = CreateToggle(p, LS("CB_SOUND_ENABLED", "Sound Enabled"),
        function() return BIT.db.soundEnabled end,
        function(v) BIT.db.soundEnabled = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SOUND_OWN_ONLY", "Only Own Kicks"),
        function() return BIT.db.soundOwnKickOnly end,
        function(v) BIT.db.soundOwnKickOnly = v end)
    -- "sound" preview mode: each entry gets a click-to-play speaker
    -- icon so the user can audition the sound straight from the list.
    w[#w+1] = CreateDropdown(p, LS("DD_SOUND_SUCCESS", "Kick Success Sound"),
        MediaOpts(function() return BIT.Media:GetAvailableSounds() end, "sound"),
        function() return BIT.db.soundKickSuccess or "None" end,
        function(v) BIT.db.soundKickSuccess = v end)
    w[#w+1] = CreateDropdown(p, LS("DD_SOUND_FAILED", "Kick Failed Sound"),
        MediaOpts(function() return BIT.Media:GetAvailableSounds() end, "sound"),
        function() return BIT.db.soundKickFailed or "None" end,
        function(v) BIT.db.soundKickFailed = v end)

    -- ── Size & Font + Colors (merged in from the former top-level pages) ──
    -- Append the widget list produced by the helpers below. Each helper
    -- creates its own section headers, so they slot into this page's flow
    -- without any extra structuring code here.
    if BuildSizeFont then
        for _, wd in ipairs(BuildSizeFont()) do w[#w+1] = wd end
    end
    if BuildColors then
        for _, wd in ipairs(BuildColors()) do w[#w+1] = wd end
    end

    return w
end

------------------------------------------------------------
-- ── Size & Font widget group (used by the Interrupts page) ───
-- No longer registered as its own top-level page; called from
-- BuildInterrupts via the forward-declared local above. The function
-- itself is unchanged so its widgets still author the same DB keys.
------------------------------------------------------------
function BuildSizeFont()
    local w = {}
    local p = contentChild

    -- Frame
    w[#w+1] = CreateSectionHeader(p, LS("SEC_FRAME", "Frame"), "sui_sf_frame")
    w[#w+1] = CreateSlider(p, LS("SL_WIDTH", "Frame Width"), 10, 500, 1,
        function() return BIT.db.frameWidth or 180 end,
        function(v) BIT.db.frameWidth = v end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_BAR_HEIGHT", "Bar Height"), 2, 60, 1,
        function() return BIT.db.barHeight or 30 end,
        function(v) BIT.db.barHeight = v
            if BIT.UI.RebuildBars then BIT.UI:RebuildBars() end end,
        function(v) return math.floor(v) .. "px" end)
    -- Independent icon size (0 = Auto: square matches the bar height). When
    -- set larger than the bar the icon overhangs vertically (centered) and
    -- sits beside the bar — raise Bar Gap if big icons start to overlap.
    w[#w+1] = CreateSlider(p, LS("SL_ICON_SIZE", "Icon Size"), 0, 64, 1,
        function() return BIT.db.interruptIconSize or 0 end,
        function(v) BIT.db.interruptIconSize = v
            if BIT.UI.RebuildBars then BIT.UI:RebuildBars() end end,
        function(v) if v <= 0 then return LS("AUTO", "Auto") end return math.floor(v) .. "px" end)
    -- Horizontal gap between the icon and the bar (bar shrinks; frame width
    -- stays the same). Only matters while the icon is shown.
    w[#w+1] = CreateSlider(p, LS("SL_ICON_GAP", "Icon Gap"), 0, 40, 1,
        function() return BIT.db.interruptIconGap or 0 end,
        function(v) BIT.db.interruptIconGap = v
            if BIT.UI.RebuildBars then BIT.UI:RebuildBars() end end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_BAR_GAP", "Bar Gap"), -1, 40, 1,
        function() return BIT.db.barGap or 0 end,
        function(v) BIT.db.barGap = v end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_FRAME_SCALE", "Frame Scale"), 10, 200, 5,
        function() return BIT.db.frameScale or 100 end,
        function(v) BIT.db.frameScale = v end,
        function(v) return math.floor(v) .. "%" end)

    -- Font face dropdown moved to the General page in 3.8.0+ (it's a
    -- cross-cutting setting used by every feature, so it lives in a
    -- single global spot now). Per-element font SIZES + outline +
    -- shadow stay here because they apply only to the interrupt bars.

    -- Bar Texture
    w[#w+1] = CreateSectionHeader(p, LS("SEC_BAR_TEXTURE", "Bar Texture"), "sui_sf_bartex")
    -- "bar" preview mode: each entry shows the actual texture as a
    -- small swatch next to its name so the user sees what every bar
    -- texture looks like before picking.
    w[#w+1] = CreateDropdown(p, LS("DD_BAR_TEXTURE", "Bar Texture"),
        MediaOpts(function() return BIT.Media:GetAvailableTextures() end, "bar"),
        function() return BIT.db.barTextureName or BIT.Media.barTextureName or "Flat" end,
        function(v)
            for _, e in ipairs(BIT.Media:GetAvailableTextures()) do
                if e.name == v then
                    BIT.db.barTexturePath = e.path; BIT.db.barTextureName = e.name
                    BIT.Media.barTexture  = e.path; BIT.Media.barTextureName = e.name
                    break
                end
            end
        end)

    -- Border
    w[#w+1] = CreateSectionHeader(p, LS("SEC_BORDER", "Border"), "sui_sf_border")
    -- "border" preview mode: each entry renders a tiny bordered frame
    -- using its edge texture so the user sees the real border style
    -- (thin / wooden / achievement / etc.) directly in the dropdown.
    w[#w+1] = CreateDropdown(p, LS("DD_BORDER_TEXTURE", "Border Texture"),
        MediaOpts(function() return BIT.Media:GetAvailableBorders() end, "border"),
        function() return BIT.db.borderTextureName or "None" end,
        function(v)
            for _, e in ipairs(BIT.Media:GetAvailableBorders()) do
                if e.name == v then
                    BIT.db.borderTexturePath = e.path
                    BIT.db.borderTextureName = e.name
                    if BIT.UI and BIT.UI.ApplyBorderToAll then BIT.UI:ApplyBorderToAll() end
                    break
                end
            end
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)
    w[#w+1] = CreateSlider(p, LS("SL_BORDER_SIZE", "Border Size"), 1, 24, 1,
        function() return BIT.db.borderSize or 12 end,
        function(v)
            BIT.db.borderSize = v
            if BIT.UI and BIT.UI.ApplyBorderToAll then BIT.UI:ApplyBorderToAll() end
            -- Keystone List border is now driven by its own keystoneListBorderSize
            -- / keystoneListBorderOffset keys (see the Border section on the
            -- Keystone List page) — this slider no longer touches it.
        end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_BORDER_OFFSET", "Border Offset"), -20, 30, 1,
        function() return BIT.db.borderOffset or 0 end,
        function(v) BIT.db.borderOffset = v; if BIT.UI and BIT.UI.ApplyBorderToAll then BIT.UI:ApplyBorderToAll() end end,
        function(v) return math.floor(v) .. "px" end)

    -- Title
    w[#w+1] = CreateSectionHeader(p, LS("SEC_TITLE_BAR", "Title Bar"), "sui_sf_title")
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_TITLE", "Show Title"),
        function() return BIT.db.showTitle end,
        function(v) BIT.db.showTitle = v end)
    w[#w+1] = CreateSlider(p, LS("SL_FONT_TITLE", "Title Font Size"), 0, 36, 1,
        function() return BIT.db.titleFontSize or 16 end,
        function(v) BIT.db.titleFontSize = v end,
        function(v) return v == 0 and "Auto" or (math.floor(v) .. "px") end)
    w[#w+1] = CreateDropdown(p, LS("DD_TITLE_ALIGN", "Title Alignment"),
        { { value = "LEFT",   label = LS("ALIGN_LEFT",   "Left") },
          { value = "CENTER", label = LS("ALIGN_CENTER", "Center") },
          { value = "RIGHT",  label = LS("ALIGN_RIGHT",  "Right") } },
        function() return BIT.db.titleAlign or "RIGHT" end,
        function(v) BIT.db.titleAlign = v end)
    w[#w+1] = CreateSlider(p, LS("SL_TITLE_OFFSET_Y", "Title Offset Y"), -30, 30, 1,
        function() return BIT.db.titleOffsetY or 3 end,
        function(v) BIT.db.titleOffsetY = v end,
        function(v) return math.floor(v) .. "px" end)

    -- Name
    w[#w+1] = CreateSectionHeader(p, LS("SEC_NAME", "Name"), "sui_sf_name")
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_NAME", "Show Name"),
        function() return BIT.db.showName end,
        function(v) BIT.db.showName = v end)
    w[#w+1] = CreateSlider(p, LS("SL_FONT_NAME", "Name Font Size"), 0, 24, 1,
        function() return BIT.db.nameFontSize or 0 end,
        function(v) BIT.db.nameFontSize = v end,
        function(v) return v == 0 and "Auto" or (math.floor(v) .. "px") end)
    w[#w+1] = CreateSlider(p, LS("SL_NAME_OFFX", "Name Offset X"), -100, 100, 1,
        function() return BIT.db.nameOffsetX or 0 end,
        function(v) BIT.db.nameOffsetX = v end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_NAME_OFFY", "Name Offset Y"), -20, 20, 1,
        function() return BIT.db.nameOffsetY or 0 end,
        function(v) BIT.db.nameOffsetY = v end,
        function(v) return math.floor(v) .. "px" end)

    -- CD / Ready
    w[#w+1] = CreateSectionHeader(p, LS("SEC_CD_READY", "CD / Ready"), "sui_sf_cd")
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_READY", "Show Ready Text"),
        function() return BIT.db.showReady end,
        function(v) BIT.db.showReady = v end)
    w[#w+1] = CreateSlider(p, LS("SL_FONT_CD", "CD Font Size"), 0, 24, 1,
        function() return BIT.db.readyFontSize or 0 end,
        function(v) BIT.db.readyFontSize = v end,
        function(v) return v == 0 and "Auto" or (math.floor(v) .. "px") end)
    w[#w+1] = CreateSlider(p, LS("SL_CD_OFFSET_X", "CD Offset X"), -50, 50, 1,
        function() return BIT.db.cdOffsetX or 0 end,
        function(v) BIT.db.cdOffsetX = v end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_CD_OFFSET_Y", "CD Offset Y"), -50, 50, 1,
        function() return BIT.db.cdOffsetY or 0 end,
        function(v) BIT.db.cdOffsetY = v end,
        function(v) return math.floor(v) .. "px" end)

    -- Outline & Shadow
    w[#w+1] = CreateSectionHeader(p, LS("SEC_OUTLINE_SHADOW", "Outline & Shadow"), "sui_sf_outline")
    w[#w+1] = CreateDropdown(p, LS("DD_FONT_OUTLINE", "Font Outline"),
        { { value = "NONE",         label = LS("OUTLINE_NONE",  "None") },
          { value = "OUTLINE",      label = LS("OUTLINE_THIN",  "Outline") },
          { value = "THICKOUTLINE", label = LS("OUTLINE_THICK", "Thick Outline") } },
        function() return BIT.db.fontOutline or "OUTLINE" end,
        function(v)
            BIT.db.fontOutline = v
            BIT.Media:Load()
            BIT.UI:RebuildBars()
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)
    w[#w+1] = CreateSlider(p, LS("SL_SHADOW_X", "Shadow X"), -5, 5, 1,
        function() return BIT.db.shadowOffsetX or 0 end,
        function(v)
            BIT.db.shadowOffsetX = v
            BIT.UI:RebuildBars()
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    w[#w+1] = CreateSlider(p, LS("SL_SHADOW_Y", "Shadow Y"), -5, 5, 1,
        function() return BIT.db.shadowOffsetY or 0 end,
        function(v)
            BIT.db.shadowOffsetY = v
            BIT.UI:RebuildBars()
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)

    return w
end

------------------------------------------------------------
-- ── Colors widget group (used by the Interrupts page) ────────
-- No longer registered as its own top-level page; called from
-- BuildInterrupts via the forward-declared local above. The function
-- itself is unchanged so its widgets still author the same DB keys.
------------------------------------------------------------
function BuildColors()
    local w = {}
    local p = contentChild

    -- All color-pickers consolidated under one "Colors" header instead
    -- of five separate sub-sections (Bar / Title / Name / Border /
    -- Ready). Each swatch carries its own label so the contents stay
    -- self-explanatory; the dynamic-visibility helper below still
    -- hides the ready/cd swatches when "Use Class Colors" is on.
    w[#w+1] = CreateSectionHeader(p, LS("SEC_COLORS", "Colors"), "sui_col_all")
    -- Forward-declare the dynamic widgets so the Use-Class-Colors toggle's
    -- setter can re-run their visibility checks via a single helper.
    local fadeToggle, readyBarSwatch, cdBarSwatch, bgToggle, bgSwatch
    local function _syncBarColorVisibility()
        local classOn = BIT.db.useClassColors and true or false
        local function set(wd, show)
            if not wd then return end
            if show then wd:Show() else wd:Hide() end
        end
        -- Hidden when class colors take over the bar look.
        set(fadeToggle,     not classOn)
        set(readyBarSwatch, not classOn)
        set(cdBarSwatch,    not classOn)
        -- Background section is independent of class colors — shown
        -- whenever the user has opted in to a custom background.
        local bgOn = BIT.db.useCustomBgColor and true or false
        set(bgSwatch, bgOn)
        if pages and pages[activePage] and pages[activePage].layout then
            pages[activePage].layout()
        end
    end

    w[#w+1] = CreateToggle(p, LS("COLOR_CLASS_BARS", "Class Colors (Bars)"),
        function() return BIT.db.useClassColors end,
        function(v)
            BIT.db.useClassColors = v
            _syncBarColorVisibility()
        end)

    fadeToggle = CreateToggle(p, LS("COLOR_CD_FADE", 'Fade (Looks good with "Fill" Option)'),
        function() return BIT.db.cdBarFade end,
        function(v) BIT.db.cdBarFade = v end)
    fadeToggle._dynamic = true
    fadeToggle._update  = _syncBarColorVisibility
    w[#w+1] = fadeToggle

    readyBarSwatch = CreateColorSwatch(p, LS("COLOR_CUSTOM", "Ready Bar"),
        function() return BIT.db.customColorR or 0.4 end,
        function() return BIT.db.customColorG or 0.8 end,
        function() return BIT.db.customColorB or 1.0 end,
        function(r, g, b) BIT.db.customColorR = r; BIT.db.customColorG = g; BIT.db.customColorB = b end)
    readyBarSwatch._dynamic = true
    readyBarSwatch._update  = _syncBarColorVisibility
    w[#w+1] = readyBarSwatch

    cdBarSwatch = CreateColorSwatch(p, LS("COLOR_CD_BAR", "Cooldown Bar"),
        function() return BIT.db.cdBarColorR or 0.8 end,
        function() return BIT.db.cdBarColorG or 0.2 end,
        function() return BIT.db.cdBarColorB or 0.2 end,
        function(r, g, b) BIT.db.cdBarColorR = r; BIT.db.cdBarColorG = g; BIT.db.cdBarColorB = b end)
    cdBarSwatch._dynamic = true
    cdBarSwatch._update  = _syncBarColorVisibility
    w[#w+1] = cdBarSwatch

    -- Custom Background. This pair lives inside the Bar Color section
    -- (no separate header). The toggle is independent of class colors —
    -- when on, the custom color is used as the bar's background even
    -- when class-color mode is active.
    bgToggle = CreateToggle(p, LS("CB_CUSTOM_BG", "Use Custom Background Color"),
        function() return BIT.db.useCustomBgColor end,
        function(v)
            BIT.db.useCustomBgColor = v
            _syncBarColorVisibility()
        end)
    w[#w+1] = bgToggle

    bgSwatch = CreateColorSwatch(p, LS("COLOR_BG", "Background Color"),
        function() return BIT.db.customBgColorR or 0.1 end,
        function() return BIT.db.customBgColorG or 0.1 end,
        function() return BIT.db.customBgColorB or 0.1 end,
        function(r, g, b) BIT.db.customBgColorR = r; BIT.db.customBgColorG = g; BIT.db.customBgColorB = b end,
        function() return BIT.db.customBgColorA or 0.9 end,
        function(a) BIT.db.customBgColorA = a end)
    bgSwatch._dynamic = true
    bgSwatch._update  = _syncBarColorVisibility
    w[#w+1] = bgSwatch

    -- Initial visibility pass so the first layout reflects the saved state.
    _syncBarColorVisibility()

    w[#w+1] = CreateColorSwatch(p, LS("COLOR_TITLE_SWATCH", "Title Color"),
        function() return BIT.db.titleColorR or 1.0 end,
        function() return BIT.db.titleColorG or 0.867 end,
        function() return BIT.db.titleColorB or 0.867 end,
        function(r, g, b) BIT.db.titleColorR = r; BIT.db.titleColorG = g; BIT.db.titleColorB = b end)

    -- ── Name Color ───────────────────────────────────────────
    -- Controls the player-name text color in the interrupt tracker bars.
    -- The color picker is hidden while the Use-Class-Colors toggle is on,
    -- since the per-class color wins in that mode.
    w[#w+1] = CreateToggle(p, LS("CB_NAME_USE_CLASS", "Use Class Colors (Names)"),
        function() return BIT.db.nameColorUseClass end,
        function(v)
            BIT.db.nameColorUseClass = v
            if pages[activePage] and pages[activePage].refresh then pages[activePage].refresh() end
            if pages[activePage] and pages[activePage].layout  then pages[activePage].layout()  end
            if BIT.UI.UpdateDisplay then BIT.UI:UpdateDisplay() end
        end)
    local nameSwatch = CreateColorSwatch(p, LS("COLOR_NAME_SWATCH", "Name Color"),
        function() return BIT.db.nameColorR or 1.0 end,
        function() return BIT.db.nameColorG or 1.0 end,
        function() return BIT.db.nameColorB or 1.0 end,
        function(r, g, b)
            BIT.db.nameColorR = r
            BIT.db.nameColorG = g
            BIT.db.nameColorB = b
            if BIT.UI.UpdateDisplay then BIT.UI:UpdateDisplay() end
        end)
    nameSwatch._dynamic = true
    nameSwatch._update  = function()
        if BIT.db.nameColorUseClass then nameSwatch:Hide() else nameSwatch:Show() end
    end
    nameSwatch._update()
    w[#w+1] = nameSwatch

    w[#w+1] = CreateColorSwatch(p, LS("COLOR_BORDER_SWATCH", "Border Color"),
        function() return BIT.db.borderColorR or 0 end,
        function() return BIT.db.borderColorG or 0 end,
        function() return BIT.db.borderColorB or 0 end,
        function(r, g, b) BIT.db.borderColorR = r; BIT.db.borderColorG = g; BIT.db.borderColorB = b end,
        function() return BIT.db.borderColorA or 1.0 end,
        function(a) BIT.db.borderColorA = a end)

    w[#w+1] = CreateColorSwatch(p, LS("COLOR_READY_SWATCH", "Ready Color"),
        function() return BIT.db.readyColorR or 0.2 end,
        function() return BIT.db.readyColorG or 1.0 end,
        function() return BIT.db.readyColorB or 0.2 end,
        function(r, g, b) BIT.db.readyColorR = r; BIT.db.readyColorG = g; BIT.db.readyColorB = b end)

    return w
end

------------------------------------------------------------
-- ── Category: Party CDs ──────────────────────────────────
-- Settings page for the new clean-room Party Cooldowns module
-- (BIT.PartyCooldowns). Phase 1 surface — the tracked-spell list
-- starts small (5 starter defensives) and grows as we expand
-- coverage; this page exposes the master toggle, anchor provider,
-- icon size, and visibility filters so live testing is comfortable
-- without the slash command (/bitpcd).
------------------------------------------------------------
local function BuildPartyCDs()
    local w = {}
    local p = contentChild

    -- ── Phase-1 disclosure banner ───────────────────────────────────
    -- Sets honest expectations: the user sees what's tracked NOW so
    -- they don't wonder why their Warrior buddy's Shield Wall isn't
    -- showing up yet.
    do
        local f = CreateFrame("Frame", nil, p, "BackdropTemplate")
        local frameWidth = p:GetWidth() - CONTENT_PAD * 2
        MakeBg(f, 0.13, 0.18, 0.30, 0.95)
        f:SetBackdropBorderColor(0.3, 0.5, 1.0, 0.9)

        local title = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(title, 13, "OUTLINE")
        title:SetPoint("TOPLEFT", 10, -6)
        title:SetTextColor(0.5, 0.8, 1.0)
        title:SetText(LS("PCD_BADGE_TITLE", "Active development"))

        local body = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(body, 11)
        body:SetPoint("TOPLEFT", 10, -26)
        body:SetWidth(frameWidth - 20)
        body:SetJustifyH("LEFT")
        body:SetJustifyV("TOP")
        body:SetWordWrap(true)
        body:SetNonSpaceWrap(false)
        body:SetTextColor(0.95, 0.95, 1.0)
        body:SetText(LS("PCD_BADGE_BODY",
            "Party Cooldowns is actively being reworked. If you see a spell tracked incorrectly (wrong icon glowing, no glow, wrong cooldown timer, missing charges), please report it on our Discord so we can fix it."))

        local bodyH = body:GetStringHeight()
        f:SetSize(frameWidth, math.max(50, 26 + bodyH + 8))

        w[#w+1] = f
        do
            local sp = CreateFrame("Frame", nil, p)
            sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
            w[#w+1] = sp
        end
    end

    -- ApplyVisibility helper used by both General (own/tooltip) and the
    -- Visibility section below. Lifted to the top of the function so
    -- both sections can call it without a forward-declare dance.
    local function _applyVis()
        if BIT.PartyCooldowns and BIT.PartyCooldowns.ApplyVisibility then
            BIT.PartyCooldowns:ApplyVisibility()
        end
    end

    -- ── General ─────────────────────────────────────────────────────
    -- Master enable + the two “what gets rendered” toggles. Kept here
    -- (rather than in a separate Display section) so the user finds
    -- everything they’re likely to flip first in one place.
    w[#w+1] = CreateSectionHeader(p, LS("SEC_GENERAL", "General"), "sui_pcd_gen")
    w[#w+1] = CreateToggle(p, LS("PCD_ENABLE", "Enable Party Cooldowns"),
        function() return BIT.db.partyCooldownsEnabled ~= false end,
        function(v)
            BIT.db.partyCooldownsEnabled = v
            if not BIT.PartyCooldowns then return end
            if v then BIT.PartyCooldowns:Enable() else BIT.PartyCooldowns:Disable() end
        end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_OWN", "Show own cooldowns"),
        function() return BIT.db.partyCooldownsShowOwn == true end,
        function(v) BIT.db.partyCooldownsShowOwn = v; _applyVis() end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_TOOLTIP", "Show tooltip"),
        function() return BIT.db.partyCooldownsShowTooltip ~= false end,
        function(v)
            BIT.db.partyCooldownsShowTooltip = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshTooltips then
                BIT.PartyCooldowns:RefreshTooltips()
            end
        end)
    -- Show buff-remaining countdown during the glow phase. With this
    -- ON (default) the CD-text overlay renders seconds-remaining on
    -- the active buff while it pulses, then transitions to the
    -- post-glow cooldown counter when the buff ends. OFF restores
    -- the legacy behaviour: glow phase shows no text.
    w[#w+1] = CreateToggle(p, LS("PCD_SHOW_GLOW_COUNTDOWN", "Show buff countdown during glow"),
        function() return BIT.db.partyCooldownsShowGlowCountdown ~= false end,
        function(v) BIT.db.partyCooldownsShowGlowCountdown = v end)

    -- Custom glow: the toggle gates the style dropdown + color picker
    -- (`_dynamic` mechanism — hidden widgets collapse without a gap).
    -- The dropdown deliberately has NO "default" entry: custom OFF is
    -- the default glow, so picking it while custom is on would be a
    -- contradiction. The preview icon below always mirrors the live
    -- configuration (classic glow when custom is off).
    local glowStyleDD, glowColorSwatch, glowPreviewIcon
    local _ovlPreviewRefresh   -- forward-declared: assigned by the overlay preview further down
    local function _restyleGlows()
        if BIT.PartyCooldowns and BIT.PartyCooldowns.RestyleActiveGlows then
            BIT.PartyCooldowns:RestyleActiveGlows()
        end
        if glowPreviewIcon and BIT.PartyCooldowns
           and BIT.PartyCooldowns.StopGlowOn and BIT.PartyCooldowns.StartGlowOn then
            BIT.PartyCooldowns:StopGlowOn(glowPreviewIcon)
            BIT.PartyCooldowns:StartGlowOn(glowPreviewIcon)
        end
        -- The unit-frame overlays share the glow configuration: restyle
        -- the live overlay icons AND the overlay preview too, so a
        -- style/color change is visible everywhere immediately.
        if BIT.DefensiveOverlay and BIT.DefensiveOverlay.RefreshStyle then
            BIT.DefensiveOverlay:RefreshStyle()
        end
        if _ovlPreviewRefresh then _ovlPreviewRefresh() end
    end
    local function _syncGlowVisibility()
        local on = BIT.db.partyCooldownsGlowCustom == true
        if glowStyleDD then
            if on then glowStyleDD:Show() else glowStyleDD:Hide() end
        end
        if glowColorSwatch then
            if on then glowColorSwatch:Show() else glowColorSwatch:Hide() end
        end
        if pages and pages[activePage] and pages[activePage].layout then
            pages[activePage].layout()
        end
    end
    w[#w+1] = CreateToggle(p, LS("PCD_GLOW_CUSTOM", "Use custom glow"),
        function() return BIT.db.partyCooldownsGlowCustom == true end,
        function(v)
            BIT.db.partyCooldownsGlowCustom = v
            _syncGlowVisibility()
            _restyleGlows()
        end)
    glowStyleDD = CreateDropdown(p, LS("PCD_GLOW_STYLE", "Glow style"),
        { { value = "PIXEL",    label = LS("PCD_GLOW_STYLE_PIXEL",    "Pixel lines") },
          { value = "AUTOCAST", label = LS("PCD_GLOW_STYLE_AUTOCAST", "Autocast shine") },
          { value = "PROC",     label = LS("PCD_GLOW_STYLE_PROC",     "Modern proc") } },
        function() return BIT.db.partyCooldownsGlowStyle or "PIXEL" end,
        function(v)
            BIT.db.partyCooldownsGlowStyle = v
            _restyleGlows()
        end)
    glowStyleDD._dynamic = true
    glowStyleDD._update  = _syncGlowVisibility
    w[#w+1] = glowStyleDD
    glowColorSwatch = CreateColorSwatch(p, LS("PCD_GLOW_COLOR", "Glow color"),
        function() return BIT.db.partyCooldownsGlowColorR or 0.95 end,
        function() return BIT.db.partyCooldownsGlowColorG or 0.95 end,
        function() return BIT.db.partyCooldownsGlowColorB or 0.32 end,
        function(r, g, b)
            BIT.db.partyCooldownsGlowColorR = r
            BIT.db.partyCooldownsGlowColorG = g
            BIT.db.partyCooldownsGlowColorB = b
            _restyleGlows()
        end)
    glowColorSwatch._dynamic = true
    glowColorSwatch._update  = _syncGlowVisibility
    w[#w+1] = glowColorSwatch

    -- Glow preview: a single sample icon glowing with the current
    -- configuration. Restyled on every glow-setting change and
    -- restarted whenever the page (re-)shows, so it also picks up
    -- profile switches without a dedicated refresh hook.
    do
        local pv = CreateFrame("Frame", nil, p)
        pv:SetSize(p:GetWidth() - CONTENT_PAD * 2, 54)

        local lbl = pv:CreateFontString(nil, "OVERLAY")
        ApplyFont(lbl, 11)
        lbl:SetPoint("LEFT", 0, 0)
        lbl:SetTextColor(RGB(TEXT_DIM))
        lbl:SetText(LS("PCD_GLOW_PREVIEW", "Glow preview"))

        local iconF = CreateFrame("Frame", nil, pv)
        iconF:SetSize(38, 38)
        iconF:SetPoint("RIGHT", -12, 0)
        local border = iconF:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", 1, -1)
        border:SetColorTexture(0, 0, 0, 1)
        local tex = iconF:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints()
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        tex:SetTexture((C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(102342))
                       or "Interface\\Icons\\INV_Misc_QuestionMark")
        glowPreviewIcon = iconF

        local function _restartPreviewGlow()
            if BIT.PartyCooldowns and BIT.PartyCooldowns.StopGlowOn
               and BIT.PartyCooldowns.StartGlowOn then
                BIT.PartyCooldowns:StopGlowOn(iconF)
                BIT.PartyCooldowns:StartGlowOn(iconF)
            end
        end
        pv:SetScript("OnShow", _restartPreviewGlow)
        -- Also start once right here: the frame is born in the shown
        -- state, so the FIRST page display never produces a
        -- hidden→shown transition and OnShow stays silent until the
        -- page is left and revisited.
        _restartPreviewGlow()
        w[#w+1] = pv
    end
    _syncGlowVisibility()

    -- ── Unit Frame Overlay ──────────────────────────────────────────
    -- Mirrors the currently ACTIVE defensive as an icon centered on
    -- the member's unit frame while the buff runs (server-side aura
    -- category filter — works without any spec/talent data).
    w[#w+1] = CreateSectionHeader(p, LS("PCD_SEC_OVERLAY", "Unit Frame Overlay"), "sui_pcd_overlay")
    -- (_ovlPreviewRefresh is forward-declared up in the glow block so
    -- the glow style/color setters can restyle the overlay preview too.)
    local function _ovlRefresh()
        if BIT.DefensiveOverlay and BIT.DefensiveOverlay.RefreshStyle then
            BIT.DefensiveOverlay:RefreshStyle()
        end
        if _ovlPreviewRefresh then _ovlPreviewRefresh() end
    end
    w[#w+1] = CreateToggle(p, LS("OVL_ENABLE", "Show active defensive on unit frames"),
        function() return BIT.db.defensiveOverlayEnabled == true end,
        function(v)
            BIT.db.defensiveOverlayEnabled = v
            if BIT.DefensiveOverlay and BIT.DefensiveOverlay.ApplyEnabled then
                BIT.DefensiveOverlay:ApplyEnabled()
            end
        end)
    w[#w+1] = CreateSlider(p, LS("OVL_SIZE", "Overlay Icon Size"), 26, 64, 1,
        function() return BIT.db.defensiveOverlaySize or 32 end,
        function(v) BIT.db.defensiveOverlaySize = v; _ovlRefresh() end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("OVL_OFFSET_X", "Overlay X Offset"), -80, 80, 1,
        function() return BIT.db.defensiveOverlayOffsetX or 0 end,
        function(v) BIT.db.defensiveOverlayOffsetX = v; _ovlRefresh() end)
    w[#w+1] = CreateSlider(p, LS("OVL_OFFSET_Y", "Overlay Y Offset"), -80, 80, 1,
        function() return BIT.db.defensiveOverlayOffsetY or 0 end,
        function(v) BIT.db.defensiveOverlayOffsetY = v; _ovlRefresh() end)
    w[#w+1] = CreateToggle(p, LS("OVL_GLOW", "Glow on overlay icon"),
        function() return BIT.db.defensiveOverlayGlow ~= false end,
        function(v) BIT.db.defensiveOverlayGlow = v; _ovlRefresh() end)

    -- Overlay preview: a mock party frame with the REAL unit frame's
    -- dimensions — resolved through the same provider the overlay
    -- anchors to (ElvUI / Cell / EllesmereUI / ...), so icon size and
    -- offsets are judged at true proportions. If the frame is wider
    -- than the settings column, frame AND icons scale down together
    -- so the proportions stay honest. Two sample icons demo the
    -- side-by-side layout; swipe + glow run live.
    do
        local OVL_GAP = 2   -- must match the overlay module's icon gap

        local pv = CreateFrame("Frame", nil, p)
        pv:SetSize(p:GetWidth() - CONTENT_PAD * 2, 84)

        local cap = pv:CreateFontString(nil, "OVERLAY")
        ApplyFont(cap, 10)
        cap:SetPoint("TOPLEFT", 0, -2)
        cap:SetTextColor(RGB(TEXT_DIM))
        cap:SetText(LS("OVL_PREVIEW", "Preview (your real frame size)"))

        local mock = CreateFrame("Frame", nil, pv, "BackdropTemplate")
        mock:SetPoint("CENTER", 0, -6)
        mock:SetBackdrop({ bgFile = WHITE8, edgeFile = WHITE8, edgeSize = 1,
                           insets = { left = 1, right = 1, top = 1, bottom = 1 } })
        mock:SetBackdropColor(0, 0, 0, 0.9)
        mock:SetBackdropBorderColor(RGB(BORDER))

        local _, cls = UnitClass("player")
        local cc = (BIT.CLASS_COLORS and BIT.CLASS_COLORS[cls]) or { 0.2, 0.6, 1 }
        local hp = mock:CreateTexture(nil, "ARTWORK")
        hp:SetPoint("TOPLEFT", 1, -1)
        hp:SetPoint("BOTTOMRIGHT", -1, 1)
        hp:SetColorTexture(cc[1] * 0.72, cc[2] * 0.72, cc[3] * 0.72, 1)

        local nameFS = mock:CreateFontString(nil, "OVERLAY")
        ApplyFont(nameFS, 11, "OUTLINE")
        nameFS:SetPoint("TOP", 0, -3)
        nameFS:SetTextColor(1, 1, 1)
        nameFS:SetText(UnitName("player") or "Player")

        -- Two sample overlay icons with the same construction as the
        -- live overlay (black 1px border, cropped icon, glow only — no
        -- swipe / countdown).
        local SAMPLE_SPELLS = { 102342, 33206 }   -- Ironbark, Pain Suppression
        local icons = {}
        for i = 1, 2 do
            local f = CreateFrame("Frame", nil, mock)
            local border = f:CreateTexture(nil, "BACKGROUND")
            border:SetPoint("TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", 1, -1)
            border:SetColorTexture(0, 0, 0, 1)
            local tex = f:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints()
            tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            local okT, t = pcall(C_Spell.GetSpellTexture, SAMPLE_SPELLS[i])
            tex:SetTexture((okT and t) or "Interface\\Icons\\INV_Misc_QuestionMark")
            icons[i] = f
        end

        local function layoutPreview()
            -- Resolve the live frame's dimensions; sane fallback when
            -- no provider frame is available right now.
            local fw, fh = 180, 50
            local hint = (BIT.db and BIT.db.partyCooldownsProvider) or "AUTO"
            if hint == "AUTO" then hint = nil end
            if BIT.UnitFrames and BIT.UnitFrames.GetPartyFrame then
                local ok, fr = pcall(BIT.UnitFrames.GetPartyFrame, BIT.UnitFrames, "player", hint)
                if ok and fr and fr.GetWidth then
                    local rw, rh = fr:GetWidth(), fr:GetHeight()
                    if rw and rw > 10 and rh and rh > 10 then fw, fh = rw, rh end
                end
            end
            local availW = (pv:GetWidth() or 300) - 20
            local k = (fw > availW) and (availW / fw) or 1
            local mw, mh = fw * k, fh * k
            mock:SetSize(mw, mh)

            local size = (((BIT.db and BIT.db.defensiveOverlaySize) or 26)) * k
            local offX = (((BIT.db and BIT.db.defensiveOverlayOffsetX) or 0)) * k
            local offY = (((BIT.db and BIT.db.defensiveOverlayOffsetY) or 0)) * k
            local gap  = OVL_GAP * k
            local n = #icons
            local totalW = n * size + (n - 1) * gap
            local startX = -(totalW / 2) + size / 2 + offX
            for i, f in ipairs(icons) do
                f:SetSize(size, size)
                f:ClearAllPoints()
                f:SetPoint("CENTER", mock, "CENTER", startX + (i - 1) * (size + gap), offY)
                f:SetFrameLevel((mock:GetFrameLevel() or 0) + 20)
                f:Show()
            end

            -- Grow the widget row with the mock (icons can also hang
            -- below the frame with a big Y offset) and reflow the page
            -- when the height actually changed.
            local wantH = math.max(84, mh + 30)
            if math.abs((pv:GetHeight() or 0) - wantH) > 0.5 then
                pv:SetHeight(wantH)
                if pages and pages[activePage] and pages[activePage].layout then
                    pages[activePage].layout()
                end
            end
        end

        local function restartGlow()
            for _, f in ipairs(icons) do
                if BIT.PartyCooldowns and BIT.PartyCooldowns.StopGlowOn then
                    BIT.PartyCooldowns:StopGlowOn(f)
                end
                if BIT.db and BIT.db.defensiveOverlayGlow ~= false
                   and BIT.PartyCooldowns and BIT.PartyCooldowns.StartGlowOn then
                    BIT.PartyCooldowns:StartGlowOn(f)
                end
            end
        end

        local function fullRefresh()
            layoutPreview()
            restartGlow()
        end
        pv:SetScript("OnShow", fullRefresh)
        -- Frames are born shown — the first page display fires no
        -- OnShow (same lesson as the glow preview), so kick once here.
        fullRefresh()

        _ovlPreviewRefresh = fullRefresh
        w[#w+1] = pv
    end

    -- ── Anchor & Position ───────────────────────────────────────────
    -- Where the icon row attaches and how it’s nudged. Provider picks
    -- which unit-frame addon supplies the anchor; AUTO walks the
    -- priority order (ElvUI → Danders → Cell → Grid2 → EnhanceQoL →
    -- SUF → Blizzard) and uses the first one currently rendering.
    w[#w+1] = CreateSectionHeader(p, LS("PCD_SEC_ANCHOR", "Anchor & Position"), "sui_pcd_anchor")

    -- Frame mode dropdown — selects between attaching the icon row to
    -- each party member's unit frame ("Anchor", original behaviour)
    -- and rendering all party CDs inside a single movable container
    -- ("Standalone"). The provider / anchor-side / offset controls
    -- below are only meaningful in Anchor mode; the Standalone
    -- subsection that follows exposes the controls relevant when
    -- that mode is active. Both groups use the `_dynamic` mechanism
    -- to show only the controls relevant to the picked mode — when
    -- the toggle flips, refresh()+layout() in the setter callback
    -- re-evaluates every widget's visibility and closes the gap.
    w[#w+1] = CreateDropdown(p, LS("PCD_FRAME_MODE", "Frame Mode"),
        { { value = "ANCHOR",     label = LS("PCD_MODE_ANCHOR",     "Anchor (unit frames)") },
          { value = "STANDALONE", label = LS("PCD_MODE_STANDALONE", "Standalone (movable)") } },
        function() return BIT.db.partyCooldownsFrameMode or "ANCHOR" end,
        function(v)
            BIT.db.partyCooldownsFrameMode = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
            if pages[activePage] and pages[activePage].refresh then
                pages[activePage].refresh()
            end
            if pages[activePage] and pages[activePage].layout then
                pages[activePage].layout()
            end
        end)

    -- Test Layout toggle — placed directly under Frame Mode so the
    -- user lands on it immediately after picking Standalone. Mirrors
    -- the Interrupt Tracker / Keystone List preview pattern: populates
    -- the standalone frame with the local player + 4 sample names from
    -- BIT.TEST_POOL so positioning / theming works without a real M+
    -- group. Dynamic-visible only in STANDALONE mode.
    local pcdTestLayoutToggle = CreateToggle(p, LS("PCD_TEST_LAYOUT", "Test Layout"),
        function()
            return BIT.PartyCooldowns and BIT.PartyCooldowns:IsTestLayoutActive() or false
        end,
        function(v)
            if not BIT.PartyCooldowns or not BIT.PartyCooldowns.ToggleTestLayout then return end
            local active = BIT.PartyCooldowns:IsTestLayoutActive()
            if v ~= active then
                BIT.PartyCooldowns:ToggleTestLayout()
            end
        end)
    pcdTestLayoutToggle._dynamic = true
    pcdTestLayoutToggle._update  = function()
        if (BIT.db.partyCooldownsFrameMode or "ANCHOR") == "STANDALONE" then
            pcdTestLayoutToggle:Show()
        else
            pcdTestLayoutToggle:Hide()
        end
    end
    pcdTestLayoutToggle._update()
    w[#w+1] = pcdTestLayoutToggle

    local pcdProviderOpts = (BIT.UnitFrames and BIT.UnitFrames.GetAvailableProviders)
        and BIT.UnitFrames:GetAvailableProviders()
        or  { { value = "AUTO", label = "Auto Detect" }, { value = "BLIZZARD", label = "Blizzard" } }
    -- All controls in this block (Anchor To, Anchor Position, X/Y
    -- Offsets, Split toggle) are ANCHOR-mode specific — they wire up
    -- how the icon rows attach to the user's unit frames. Hidden
    -- when Frame Mode = STANDALONE since the standalone container
    -- has its own anchor (single screen-anchored frame, no unit-
    -- frame relationship). The helper builds the closure once per
    -- widget; each widget is marked `_dynamic` + assigned an
    -- `_update` that consults the live mode value.
    local function isAnchorMode()
        return (BIT.db.partyCooldownsFrameMode or "ANCHOR") == "ANCHOR"
    end

    local providerDD = CreateDropdown(p, LS("PCD_PROVIDER", "Anchor To"),
        pcdProviderOpts,
        function() return BIT.db.partyCooldownsProvider or "AUTO" end,
        function(v)
            BIT.db.partyCooldownsProvider = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end)
    providerDD._dynamic = true
    providerDD._update  = function()
        if isAnchorMode() then providerDD:Show() else providerDD:Hide() end
    end
    providerDD._update()
    w[#w+1] = providerDD

    -- Which side of the party unit frame the icon row attaches to.
    -- RIGHT / LEFT extend horizontally, TOP / BOTTOM stack vertically.
    local anchorPosDD = CreateDropdown(p, LS("PCD_ANCHOR_POS", "Anchor Position"),
        { { value = "RIGHT",  label = LS("PCD_POS_RIGHT",  "Right") },
          { value = "LEFT",   label = LS("PCD_POS_LEFT",   "Left") },
          { value = "TOP",    label = LS("PCD_POS_TOP",    "Top") },
          { value = "BOTTOM", label = LS("PCD_POS_BOTTOM", "Bottom") } },
        function() return BIT.db.partyCooldownsAnchorPos or "LEFT" end,
        function(v)
            BIT.db.partyCooldownsAnchorPos = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end)
    anchorPosDD._dynamic = true
    anchorPosDD._update  = function()
        if isAnchorMode() then anchorPosDD:Show() else anchorPosDD:Hide() end
    end
    anchorPosDD._update()
    w[#w+1] = anchorPosDD

    -- XY nudge sliders. Useful when the chosen anchor side puts the
    -- row over a boss-mod timer / raid-frame border / etc. Range is
    -- generous (-200..+200) for big frames. Live-applies via RebuildAnchors.
    local offXMain = CreateSlider(p, LS("PCD_OFFSET_X", "X Offset"), -200, 200, 1,
        function() return BIT.db.partyCooldownsOffsetX or 2 end,
        function(v)
            BIT.db.partyCooldownsOffsetX = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    offXMain._dynamic = true
    offXMain._update  = function()
        if isAnchorMode() then offXMain:Show() else offXMain:Hide() end
    end
    offXMain._update()
    w[#w+1] = offXMain

    local offYMain = CreateSlider(p, LS("PCD_OFFSET_Y", "Y Offset"), -200, 200, 1,
        function() return BIT.db.partyCooldownsOffsetY or 0 end,
        function(v)
            BIT.db.partyCooldownsOffsetY = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    offYMain._dynamic = true
    offYMain._update  = function()
        if isAnchorMode() then offYMain:Show() else offYMain:Hide() end
    end
    offYMain._update()
    w[#w+1] = offYMain

    -- Split toggle. When enabled, the spell row gets partitioned into
    -- Defensive (cat=DEF + racials) and Offensive (cat=OFF). The main
    -- anchor/offset above drive the Defensive row; the Offensive row
    -- uses the separate anchor + offsets below. With the toggle off,
    -- the Offensive controls have no effect (everything renders in
    -- one row using the main config) — and they hide themselves via
    -- the `_dynamic`/`_update` mechanism so the settings panel
    -- doesn't show inactive controls. Also hidden when Frame Mode =
    -- STANDALONE since the standalone container has its own layout.
    local splitToggle = CreateToggle(p, LS("PCD_SPLIT_CATEGORIES", "Split Offensive / Defensive"),
        function() return BIT.db.partyCooldownsSplitCategories == true end,
        function(v)
            BIT.db.partyCooldownsSplitCategories = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
            -- Re-layout the panel so the dependent Offensive controls
            -- below appear/disappear immediately (no menu reopen needed).
            -- refresh() runs every widget's _update() (toggling visibility);
            -- layout() repositions the remaining visible widgets so the
            -- gap closes instead of leaving an empty slot.
            if pages[activePage] and pages[activePage].refresh then
                pages[activePage].refresh()
            end
            if pages[activePage] and pages[activePage].layout then
                pages[activePage].layout()
            end
        end)
    splitToggle._dynamic = true
    splitToggle._update  = function()
        if isAnchorMode() then splitToggle:Show() else splitToggle:Hide() end
    end
    splitToggle._update()
    w[#w+1] = splitToggle

    -- The three Offensive controls below are only meaningful when
    -- (split is active) AND (mode = ANCHOR). Composite gate.
    local offAnchorDD = CreateDropdown(p, LS("PCD_ANCHOR_POS_OFFENSIVE", "Offensive Anchor Position"),
        { { value = "RIGHT",  label = LS("PCD_POS_RIGHT",  "Right") },
          { value = "LEFT",   label = LS("PCD_POS_LEFT",   "Left") },
          { value = "TOP",    label = LS("PCD_POS_TOP",    "Top") },
          { value = "BOTTOM", label = LS("PCD_POS_BOTTOM", "Bottom") } },
        function() return BIT.db.partyCooldownsAnchorPosOffensive or "RIGHT" end,
        function(v)
            BIT.db.partyCooldownsAnchorPosOffensive = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end)
    offAnchorDD._dynamic = true
    offAnchorDD._update  = function()
        if isAnchorMode() and BIT.db.partyCooldownsSplitCategories then
            offAnchorDD:Show()
        else
            offAnchorDD:Hide()
        end
    end
    offAnchorDD._update()
    w[#w+1] = offAnchorDD

    local offXSlider = CreateSlider(p, LS("PCD_OFFSET_X_OFFENSIVE", "Offensive X Offset"), -200, 200, 1,
        function() return BIT.db.partyCooldownsOffsetXOffensive or 2 end,
        function(v)
            BIT.db.partyCooldownsOffsetXOffensive = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    offXSlider._dynamic = true
    offXSlider._update  = function()
        if isAnchorMode() and BIT.db.partyCooldownsSplitCategories then
            offXSlider:Show()
        else
            offXSlider:Hide()
        end
    end
    offXSlider._update()
    w[#w+1] = offXSlider

    local offYSlider = CreateSlider(p, LS("PCD_OFFSET_Y_OFFENSIVE", "Offensive Y Offset"), -200, 200, 1,
        function() return BIT.db.partyCooldownsOffsetYOffensive or 0 end,
        function(v)
            BIT.db.partyCooldownsOffsetYOffensive = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    offYSlider._dynamic = true
    offYSlider._update  = function()
        if isAnchorMode() and BIT.db.partyCooldownsSplitCategories then
            offYSlider:Show()
        else
            offYSlider:Hide()
        end
    end
    offYSlider._update()
    w[#w+1] = offYSlider

    -- ── Standalone frame controls ─────────────────────────────────
    -- Only active when Frame Mode = STANDALONE. All four widgets
    -- below are `_dynamic` + hide themselves when the mode is set
    -- to ANCHOR (so the panel doesn't show inactive controls).
    local saHeader = CreateSectionHeader(p, LS("PCD_SEC_STANDALONE", "Standalone Frame"), "sui_pcd_standalone")
    saHeader._dynamic = true
    saHeader._update  = function()
        if (BIT.db.partyCooldownsFrameMode or "ANCHOR") == "STANDALONE" then
            saHeader:Show()
        else
            saHeader:Hide()
        end
    end
    saHeader._update()
    w[#w+1] = saHeader

    local saLockToggle = CreateToggle(p, LS("PCD_STANDALONE_LOCK", "Lock frame position"),
        function() return BIT.db.partyCooldownsStandaloneLocked == true end,
        function(v)
            BIT.db.partyCooldownsStandaloneLocked = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end)
    saLockToggle._dynamic = true
    saLockToggle._update  = function()
        if (BIT.db.partyCooldownsFrameMode or "ANCHOR") == "STANDALONE" then
            saLockToggle:Show()
        else
            saLockToggle:Hide()
        end
    end
    saLockToggle._update()
    w[#w+1] = saLockToggle

    -- Grow Upward toggle. With grow-down (default) the frame is
    -- anchored TOPLEFT and rows stack downward as members appear;
    -- with grow-up it's anchored BOTTOMLEFT and rows stack upward
    -- (useful when the frame sits above action bars and you want
    -- the bottom edge to stay pinned). Mirrors the Keystone List
    -- grow-direction toggle.
    local saGrowUpToggle = CreateToggle(p, LS("PCD_STANDALONE_GROW_UPWARD", "Grow Upward"),
        function() return BIT.db.partyCooldownsStandaloneGrowUpward == true end,
        function(v)
            BIT.db.partyCooldownsStandaloneGrowUpward = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end)
    saGrowUpToggle._dynamic = true
    saGrowUpToggle._update  = function()
        if (BIT.db.partyCooldownsFrameMode or "ANCHOR") == "STANDALONE" then
            saGrowUpToggle:Show()
        else
            saGrowUpToggle:Hide()
        end
    end
    saGrowUpToggle._update()
    w[#w+1] = saGrowUpToggle

    local saNamesToggle = CreateToggle(p, LS("PCD_STANDALONE_SHOW_NAMES", "Show player names"),
        function() return BIT.db.partyCooldownsStandaloneShowNames ~= false end,
        function(v)
            BIT.db.partyCooldownsStandaloneShowNames = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
            -- Refresh the panel so the font-size slider below
            -- hides/appears in sync with the names toggle.
            if pages[activePage] and pages[activePage].refresh then
                pages[activePage].refresh()
            end
            if pages[activePage] and pages[activePage].layout then
                pages[activePage].layout()
            end
        end)
    saNamesToggle._dynamic = true
    saNamesToggle._update  = function()
        if (BIT.db.partyCooldownsFrameMode or "ANCHOR") == "STANDALONE" then
            saNamesToggle:Show()
        else
            saNamesToggle:Hide()
        end
    end
    saNamesToggle._update()
    w[#w+1] = saNamesToggle

    local saRowGapSlider = CreateSlider(p, LS("PCD_STANDALONE_ROW_GAP", "Row Spacing"), 0, 30, 1,
        function() return BIT.db.partyCooldownsStandaloneRowGap or 6 end,
        function(v)
            BIT.db.partyCooldownsStandaloneRowGap = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    saRowGapSlider._dynamic = true
    saRowGapSlider._update  = function()
        if (BIT.db.partyCooldownsFrameMode or "ANCHOR") == "STANDALONE" then
            saRowGapSlider:Show()
        else
            saRowGapSlider:Hide()
        end
    end
    saRowGapSlider._update()
    w[#w+1] = saRowGapSlider

    local saFontSlider = CreateSlider(p, LS("PCD_STANDALONE_FONT_SIZE", "Name Font Size"), 6, 28, 1,
        function() return BIT.db.partyCooldownsStandaloneFontSize or 11 end,
        function(v)
            BIT.db.partyCooldownsStandaloneFontSize = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end,
        function(v) return math.floor(v) .. "pt" end)
    saFontSlider._dynamic = true
    saFontSlider._update  = function()
        if (BIT.db.partyCooldownsFrameMode or "ANCHOR") == "STANDALONE"
           and BIT.db.partyCooldownsStandaloneShowNames ~= false then
            saFontSlider:Show()
        else
            saFontSlider:Hide()
        end
    end
    saFontSlider._update()
    w[#w+1] = saFontSlider

    -- ── Visibility ──────────────────────────────────────────────────
    -- Positioned here (3rd section, right after Anchor & Position)
    -- to mirror the Interrupt Tracker page layout. Visibility =
    -- "where/when does the feature appear?" — same logical bucket as
    -- General + Anchor, so users find all the "should this show up"
    -- toggles in one stretch before scrolling into pure-visual tuning.
    -- Each toggle stores its flag in BIT.db and immediately calls
    -- BIT.PartyCooldowns:ApplyVisibility() so the user sees the icon
    -- bar appear/disappear without needing to /reload or change zone.
    w[#w+1] = CreateSectionHeader(p, LS("PCD_SEC_VISIBILITY", "Visibility"), "sui_pcd_vis")
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_DUNGEON", "Show in Dungeon"),
        function() return BIT.db.partyCooldownsShowInDungeon ~= false end,
        function(v) BIT.db.partyCooldownsShowInDungeon = v; _applyVis() end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_RAID", "Show in Raid"),
        function() return BIT.db.partyCooldownsShowInRaid == true end,
        function(v) BIT.db.partyCooldownsShowInRaid = v; _applyVis() end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_WORLD", "Show in Open World"),
        function() return BIT.db.partyCooldownsShowInOpenWorld ~= false end,
        function(v) BIT.db.partyCooldownsShowInOpenWorld = v; _applyVis() end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_ARENA", "Show in Arena"),
        function() return BIT.db.partyCooldownsShowInArena == true end,
        function(v) BIT.db.partyCooldownsShowInArena = v; _applyVis() end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_BG", "Show in Battleground"),
        function() return BIT.db.partyCooldownsShowInBG == true end,
        function(v) BIT.db.partyCooldownsShowInBG = v; _applyVis() end)

    -- ── Icon Appearance ─────────────────────────────────────────────
    -- How each individual icon looks: size, spacing, and border.
    w[#w+1] = CreateSectionHeader(p, LS("PCD_SEC_ICON", "Icon Appearance"), "sui_pcd_icon")
    -- Max icons per line before wrapping. 0 = unlimited (single line).
    -- Placed at the top of Icon Appearance because it's a structural
    -- layout decision — the user usually wants to set the wrap before
    -- fine-tuning size/gap/border. Useful for TOP/BOTTOM anchor when
    -- many icons would extend off screen; LEFT/RIGHT also benefit
    -- when the row gets too wide. Wraps downward for horizontal
    -- anchors, sideways for vertical.
    w[#w+1] = CreateSlider(p, LS("PCD_MAX_PER_LINE", "Max icons per line (0 = unlimited)"), 0, 10, 1,
        function() return BIT.db.partyCooldownsMaxPerLine or 0 end,
        function(v)
            BIT.db.partyCooldownsMaxPerLine = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end,
        function(v)
            v = math.floor(v)
            if v == 0 then return "off" end
            return tostring(v)
        end)
    -- Per-icon visual size in pixels. EnsureIconsFor reads this on each
    -- RebuildAnchors so changes apply live (no /reload).
    w[#w+1] = CreateSlider(p, LS("PCD_ICON_SIZE", "Icon Size"), 26, 64, 1,
        function() return BIT.db.partyCooldownsIconSize or 28 end,
        function(v)
            BIT.db.partyCooldownsIconSize = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    -- Spacing between adjacent icons along the anchor axis.
    w[#w+1] = CreateSlider(p, LS("PCD_ICON_GAP", "Icon Gap"), 0, 20, 1,
        function() return BIT.db.partyCooldownsIconGap or 3 end,
        function(v)
            BIT.db.partyCooldownsIconGap = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RebuildAnchors then
                BIT.PartyCooldowns:RebuildAnchors()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    -- Per-icon outline thickness. 0 = no border (raw spell texture),
    -- positive values draw a colored ring around each icon.
    w[#w+1] = CreateSlider(p, LS("PCD_BORDER_SIZE", "Border Size"), 0, 8, 1,
        function() return BIT.db.partyCooldownsBorderSize or 1 end,
        function(v)
            BIT.db.partyCooldownsBorderSize = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshBorders then
                BIT.PartyCooldowns:RefreshBorders()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    -- How far the border sits OUTSIDE the icon edge. 0 = flush,
    -- positive pushes outward, negative overlaps the icon edge.
    w[#w+1] = CreateSlider(p, LS("PCD_BORDER_OFFSET", "Border Offset"), -10, 20, 1,
        function() return BIT.db.partyCooldownsBorderOffset or 0 end,
        function(v)
            BIT.db.partyCooldownsBorderOffset = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshBorders then
                BIT.PartyCooldowns:RefreshBorders()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    -- Border texture (edge file). Same media library as the interrupt
    -- tracker's border dropdown so the user gets the bundled decorative
    -- borders (Achievement, Thin, Wooden, etc.) plus the bundled
    -- LibSharedMedia entries. RefreshBorders applies the new edge file
    -- to every existing icon live.
    w[#w+1] = CreateDropdown(p, LS("PCD_BORDER_TEXTURE", "Border Texture"),
        MediaOpts(function() return BIT.Media:GetAvailableBorders() end, "border"),
        function() return BIT.db.partyCooldownsBorderTextureName or "Flat" end,
        function(v)
            for _, e in ipairs(BIT.Media:GetAvailableBorders()) do
                if e.name == v then
                    BIT.db.partyCooldownsBorderTexturePath = e.path
                    BIT.db.partyCooldownsBorderTextureName = e.name
                    break
                end
            end
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshBorders then
                BIT.PartyCooldowns:RefreshBorders()
            end
        end)
    -- Border color picker — independent from the interrupt-tracker
    -- border color so each feature can be styled separately.
    w[#w+1] = CreateColorSwatch(p, LS("PCD_BORDER_COLOR", "Border Color"),
        function() return BIT.db.partyCooldownsBorderColorR or 0 end,
        function() return BIT.db.partyCooldownsBorderColorG or 0 end,
        function() return BIT.db.partyCooldownsBorderColorB or 0 end,
        function(r, g, b)
            BIT.db.partyCooldownsBorderColorR = r
            BIT.db.partyCooldownsBorderColorG = g
            BIT.db.partyCooldownsBorderColorB = b
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshBorders then
                BIT.PartyCooldowns:RefreshBorders()
            end
        end,
        function() return BIT.db.partyCooldownsBorderColorA or 1.0 end,
        function(a)
            BIT.db.partyCooldownsBorderColorA = a
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshBorders then
                BIT.PartyCooldowns:RefreshBorders()
            end
        end)

    -- ── Cooldown Text ───────────────────────────────────────────────
    -- The seconds-remaining countdown sitting on top of each icon.
    -- Controls font size, minute compaction (>60s), and whether
    -- on-CD icons get a darkened/desaturated look.
    w[#w+1] = CreateSectionHeader(p, LS("PCD_SEC_CD_TEXT", "Cooldown Text"), "sui_pcd_cdtext")
    w[#w+1] = CreateSlider(p, LS("PCD_CD_FONT_SIZE", "CD Font Size"), 6, 30, 1,
        function() return BIT.db.partyCooldownsCdTextFontSize or 15 end,
        function(v)
            BIT.db.partyCooldownsCdTextFontSize = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshCdTextStyle then
                BIT.PartyCooldowns:RefreshCdTextStyle()
            end
        end,
        function(v) return math.floor(v) .. "pt" end)
    w[#w+1] = CreateToggle(p, LS("PCD_CD_SHOW_MINUTES", "Show minutes (Xm) for >60s remaining"),
        function() return BIT.db.partyCooldownsCdShowMinutes == true end,
        function(v) BIT.db.partyCooldownsCdShowMinutes = v end)
    w[#w+1] = CreateToggle(p, LS("PCD_CD_GRAYOUT", "Gray out icons while on cooldown"),
        function() return BIT.db.partyCooldownsCdGrayout == true end,
        function(v)
            BIT.db.partyCooldownsCdGrayout = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshCdGrayout then
                BIT.PartyCooldowns:RefreshCdGrayout()
            end
        end)

    -- ── Charge Badge ────────────────────────────────────────────────
    -- Small number in the corner of multi-charge spells (e.g. Blur
    -- with Demonic Resilience). Defaults: bottom-right with 1px inset,
    -- 10pt font.
    w[#w+1] = CreateSectionHeader(p, LS("PCD_SEC_CHARGE", "Charge Badge"), "sui_pcd_charge")
    w[#w+1] = CreateSlider(p, LS("PCD_CHARGE_OFFSET_X", "Charge X Offset"), -20, 20, 1,
        function() return BIT.db.partyCooldownsChargeOffsetX or 4 end,
        function(v)
            BIT.db.partyCooldownsChargeOffsetX = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshChargeBadgeStyle then
                BIT.PartyCooldowns:RefreshChargeBadgeStyle()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("PCD_CHARGE_OFFSET_Y", "Charge Y Offset"), -20, 20, 1,
        function() return BIT.db.partyCooldownsChargeOffsetY or -3 end,
        function(v)
            BIT.db.partyCooldownsChargeOffsetY = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshChargeBadgeStyle then
                BIT.PartyCooldowns:RefreshChargeBadgeStyle()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("PCD_CHARGE_FONT_SIZE", "Charge Font Size"), 6, 24, 1,
        function() return BIT.db.partyCooldownsChargeFontSize or 13 end,
        function(v)
            BIT.db.partyCooldownsChargeFontSize = v
            if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshChargeBadgeStyle then
                BIT.PartyCooldowns:RefreshChargeBadgeStyle()
            end
        end,
        function(v) return math.floor(v) .. "pt" end)

    -- ── Spell Filter ────────────────────────────────────────────────
    -- Per-spell on/off toggles, grouped by class (Defensives / Offensives
    -- tabs + a Racial tab for Shadowmeld). Tooltips on hover via
    -- GameTooltip:SetSpellByID. Disabled spells skip the icon-creation
    -- path entirely (SpellsForMember checks partyCooldownsDisabled at
    -- the top of its accept() helper). Toggling a checkbox calls
    -- PCD:RefreshFilter which re-runs RebuildAnchors so the icon
    -- appears / disappears live without /reload.
    w[#w+1] = CreateSectionHeader(p, LS("PCD_SEC_SPELLS", "Spell Filter"), "sui_pcd_spells")

    -- Build the three buckets (DEF / OFF / Racial) from BIT.PartyCooldowns'
    -- exposed SPELL_DEFS table. Each entry is converted to the shape
    -- CreateSpellFilterPanel expects: { id, label, class, className }.
    -- Class spells use UnitClassFile strings (DRUID, HUNTER, etc.); race
    -- entries map to the engineered "RACIAL" pseudo-class with the
    -- human race name as className. Sorted by class first, then by
    -- spell label inside each class so the list reads alphabetically.
    local pcdSpellDefs = (BIT.PartyCooldowns and BIT.PartyCooldowns.GetAllSpells)
        and BIT.PartyCooldowns:GetAllSpells() or {}
    local PCD_RACE_DISPLAY = {
        NightElf = "Night Elf",
        Dwarf    = "Dwarf",
    }
    local pcdDef, pcdOff, pcdRacial = {}, {}, {}
    for _, def in ipairs(pcdSpellDefs) do
        local className
        local classKey = def.class
        if def.race then
            classKey  = "RACIAL"
            className = PCD_RACE_DISPLAY[def.race] or def.race
        elseif def.class and LOCALIZED_CLASS_NAMES_MALE then
            className = LOCALIZED_CLASS_NAMES_MALE[def.class] or def.class
        else
            className = def.class or "?"
        end
        local row = {
            id        = def.spellId,
            label     = def.label or tostring(def.spellId),
            class     = classKey,
            className = className,
            -- Mirror the def's disabled flag onto the row so the
            -- Spell Filter panel renders it as a permanently-off
            -- "Currently not trackable" entry. SpellsForMember
            -- already filters disabled defs out of the icon row,
            -- so this purely controls the settings-page display.
            notTrackable = def.disabled or nil,
        }
        if def.race then
            pcdRacial[#pcdRacial+1] = row
        elseif def.cat == "OFF" then
            pcdOff[#pcdOff+1] = row
        else
            pcdDef[#pcdDef+1] = row
        end
    end
    local function pcdSort(a, b)
        if a.className ~= b.className then return a.className < b.className end
        return a.label < b.label
    end
    table.sort(pcdDef,    pcdSort)
    table.sort(pcdOff,    pcdSort)
    table.sort(pcdRacial, pcdSort)

    local pcdSpellGetter = function(sid)
        return not (BIT.db.partyCooldownsDisabled and BIT.db.partyCooldownsDisabled[sid])
    end
    local pcdSpellSetter = function(sid, enabled)
        if not BIT.db.partyCooldownsDisabled then BIT.db.partyCooldownsDisabled = {} end
        BIT.db.partyCooldownsDisabled[sid] = (not enabled) or nil
        if BIT.PartyCooldowns and BIT.PartyCooldowns.RefreshFilter then
            BIT.PartyCooldowns:RefreshFilter()
        end
    end

    w[#w+1] = CreateSpellFilterPanel(p, pcdDef, pcdSpellGetter, pcdSpellSetter, {
        { label = LS("PCD_TAB_DEF",    "Def"),    spells = pcdDef    },
        { label = LS("PCD_TAB_OFF",    "Off"),    spells = pcdOff    },
        { label = LS("PCD_TAB_RACIAL", "Racial"), spells = pcdRacial },
    })

    return w
end

-- ─────────────────────────────────────────────────────────
-- Dead code below: the original Party CDs page body is parked in
-- _BuildPartyCDs_DEAD(). Lua never EXECUTES a function body until the
-- function is called, so this is a safe parking lot — defining a
-- never-called local has zero runtime cost. References only this addon's
-- own DB keys, kept temporarily to ease a future reintroduction of the
-- feature once a clean-room replacement is ready. Slated for full
-- removal in a later release.
-- ─────────────────────────────────────────────────────────
local function _BuildPartyCDs_DEAD()
    local w = {}
    local p = contentChild

    -- General
    w[#w+1] = CreateSectionHeader(p, LS("SEC_GENERAL", "General"), "sui_pcd_gen")
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_SYNC_CDS", "Show Party CD Tracker"),
        function() return BIT.db.showSyncCDs end,
        function(v) BIT.db.showSyncCDs = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SYNC_ONLY_GROUP", "Show Only in Group"),
        function() return BIT.db.syncOnlyInGroup end,
        function(v) BIT.db.syncOnlyInGroup = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_OWN_SYNC", "Show Own Cooldowns"),
        function() return BIT.db.showOwnSyncCD end,
        function(v) BIT.db.showOwnSyncCD = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_DMG", "Show Offensives"),
        function() return BIT.db.syncCdShowDMG end,
        function(v) BIT.db.syncCdShowDMG = v; BIT.db.syncCdCatVer = (BIT.db.syncCdCatVer or 0) + 1 end)
    w[#w+1] = CreateToggle(p, LS("CB_SHOW_DEF", "Show Defensives"),
        function() return BIT.db.syncCdShowDEF end,
        function(v) BIT.db.syncCdShowDEF = v; BIT.db.syncCdCatVer = (BIT.db.syncCdCatVer or 0) + 1 end)
    w[#w+1] = CreateToggle(p, LS("CB_SYNC_TOOLTIP", "Show Spell Tooltips"),
        function() return BIT.db.syncCdTooltip end,
        function(v) BIT.db.syncCdTooltip = v end)
    w[#w+1] = CreateToggle(p, LS("CB_SYNC_GLOW", "Show Buff Glow"),
        function() return BIT.db.syncCdGlow end,
        function(v) BIT.db.syncCdGlow = v end)

    -- Display & Layout
    w[#w+1] = CreateSectionHeader(p, LS("SEC_DISPLAY_LAYOUT", "Display & Layout"), "sui_pcd_layout")
    -- Mode dropdowns. "Off" was removed in 3.4.0 — to disable the tracker
    -- in a specific zone, use the Visibility section below instead.

    -- Forward-declare so the dropdown setters below can re-trigger
    -- the lock-position visibility check when modes change.
    local pcdLockToggle

    -- Lock Position only makes sense for Group Bars / Standalone
    -- Window mode — those are draggable. "Attach to Party Frames"
    -- pins to the unit frame and has no movable position of its own,
    -- so the toggle hides when *both* Group and Raid mode are set
    -- to ATTACH.
    local function _syncPcdLockVisibility()
        if not pcdLockToggle then return end
        local g = BIT.db.syncCdModeGroup or "ATTACH"
        local r = BIT.db.syncCdModeRaid  or "BARS"
        local anyMovable = (g ~= "ATTACH") or (r ~= "ATTACH")
        if anyMovable then pcdLockToggle:Show() else pcdLockToggle:Hide() end
        if pages and pages[activePage] and pages[activePage].layout then
            pages[activePage].layout()
        end
    end

    w[#w+1] = CreateDropdown(p, LS("SYNC_DISPLAY_MODE_GROUP", "Mode (Group)"),
        { { value = "ATTACH", label = LS("SYNC_MODE_ATTACH", "Attach to Party Frames") },
          { value = "WINDOW", label = LS("SYNC_MODE_WINDOW", "Standalone Window") },
          { value = "BARS",   label = LS("SYNC_MODE_BARS",   "Group Bars") } },
        function() return BIT.db.syncCdModeGroup or "ATTACH" end,
        function(v) BIT.db.syncCdModeGroup = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
            _syncPcdLockVisibility()
        end)
    w[#w+1] = CreateDropdown(p, LS("SYNC_DISPLAY_MODE_RAID", "Mode (Raid)"),
        { { value = "BARS",   label = LS("SYNC_MODE_BARS",   "Group Bars") },
          { value = "WINDOW", label = LS("SYNC_MODE_WINDOW", "Standalone Window") },
          { value = "ATTACH", label = LS("SYNC_MODE_ATTACH", "Attach to Party Frames") } },
        function() return BIT.db.syncCdModeRaid or "BARS" end,
        function(v) BIT.db.syncCdModeRaid = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
            _syncPcdLockVisibility()
        end)

    -- Lock Position lives directly below Mode (Raid). _dynamic + the
    -- _update binding lets LayoutWidgets reclaim the slot (no leftover
    -- gap) when both modes are ATTACH and the toggle hides itself.
    pcdLockToggle = CreateToggle(p, LS("CB_BARS_LOCKED", "Lock Position"),
        function() return BIT.db.syncCdBarsLocked end,
        function(v) BIT.db.syncCdBarsLocked = v end)
    pcdLockToggle._dynamic = true
    pcdLockToggle._update  = _syncPcdLockVisibility
    w[#w+1] = pcdLockToggle

    -- Frame Provider list comes from BIT.UnitFrames (shared resolver).
    local providerOpts = (BIT.UnitFrames and BIT.UnitFrames.GetAvailableProviders)
        and BIT.UnitFrames:GetAvailableProviders()
        or  { { value = "AUTO", label = LS("PROVIDER_AUTO", "Auto Detect") }, { value = "BLIZZARD", label = "Blizzard" } }
    w[#w+1] = CreateDropdown(p, LS("DD_ATTACH_FRAMES", "Attach to Frames"),
        providerOpts,
        function() return BIT.db.syncCdFrameProvider or "AUTO" end,
        function(v)
            BIT.db.syncCdFrameProvider = v
            BIT.db._frameProviderAsked = true
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    -- Top / Bottom layout only matters when the icons grow vertically
    -- (TOP / BOTTOM attach). With LEFT or RIGHT attach the rows-based
    -- layout is the only sensible option, so we hide the dropdown.
    -- Forward-declare so the Attach Position setter below can poke
    -- the visibility check after a position change.
    local tbLayoutDropdown
    local function _syncTBLayoutVisibility()
        if not tbLayoutDropdown then return end
        local pos = BIT.db.syncCdAttachPos or "LEFT"
        if pos == "TOP" or pos == "BOTTOM" then
            tbLayoutDropdown:Show()
        else
            tbLayoutDropdown:Hide()
        end
        if pages and pages[activePage] and pages[activePage].layout then
            pages[activePage].layout()
        end
    end

    w[#w+1] = CreateDropdown(p, LS("SYNC_ATTACH_POS", "Attach Position"),
        { { value = "LEFT",   label = LS("SYNC_POS_LEFT",   "Left") },
          { value = "RIGHT",  label = LS("SYNC_POS_RIGHT",  "Right") },
          { value = "TOP",    label = LS("SYNC_POS_TOP",    "Top") },
          { value = "BOTTOM", label = LS("SYNC_POS_BOTTOM", "Bottom") } },
        function() return BIT.db.syncCdAttachPos or "LEFT" end,
        function(v)
            BIT.db.syncCdAttachPos = v
            _syncTBLayoutVisibility()
        end)

    -- Initial visibility pass so the first layout already reflects
    -- whichever mode pair is saved.
    _syncPcdLockVisibility()
    -- Unified Top / Bottom layout (3.5.0+). Was previously two separate
    -- dropdowns, but in practice users always picked the same mode for
    -- both attach directions — collapsing them into one knob removes
    -- the redundancy. Falls back to the legacy per-direction keys for
    -- existing user databases that haven't been touched yet.
    tbLayoutDropdown = CreateDropdown(p, LS("SYNC_TB_LAYOUT", "Top / Bottom - Layout"),
        { { value = "ROWS",    label = LS("SYNC_LAYOUT_ROWS",    "Rows") },
          { value = "COLUMNS", label = LS("SYNC_LAYOUT_COLUMNS", "Columns") } },
        function()
            return BIT.db.syncCdTBLayout
                or BIT.db.syncCdTopLayout
                or BIT.db.syncCdBottomLayout
                or "ROWS"
        end,
        function(v)
            BIT.db.syncCdTBLayout = v
            -- Mirror to the legacy keys so a downgrade to 3.4.x or an
            -- old export round-trips with the same selection.
            BIT.db.syncCdTopLayout    = v
            BIT.db.syncCdBottomLayout = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    tbLayoutDropdown._dynamic = true
    tbLayoutDropdown._update  = _syncTBLayoutVisibility
    w[#w+1] = tbLayoutDropdown

    -- Initial visibility for the TB-Layout dropdown so the first
    -- layout pass honours the saved attach position.
    _syncTBLayoutVisibility()

    -- Category Row Assignment
    w[#w+1] = CreateSectionHeader(p, LS("SEC_CATEGORY_ROWS", "Category Rows"), "sui_pcd_rows")
    local rowOpts = {
        { value = "1", label = LS("ROW_1", "Row 1") },
        { value = "2", label = LS("ROW_2", "Row 2") },
        { value = "3", label = LS("ROW_3", "Row 3") },
    }
    local function bumpCatVer()
        BIT.db.syncCdCatVer = (BIT.db.syncCdCatVer or 0) + 1
        if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
    end
    w[#w+1] = CreateDropdown(p, LS("DD_CAT_ROW_DMG", "Offensives — Row"), rowOpts,
        function() return tostring(BIT.db.syncCdCatRowDMG or "1") end,
        function(v) BIT.db.syncCdCatRowDMG = v; bumpCatVer() end)
    w[#w+1] = CreateDropdown(p, LS("DD_CAT_ROW_DEF", "Defensives — Row"), rowOpts,
        function() return tostring(BIT.db.syncCdCatRowDEF or "2") end,
        function(v) BIT.db.syncCdCatRowDEF = v; bumpCatVer() end)
    -- Icons & Text
    w[#w+1] = CreateSectionHeader(p, LS("SEC_ICONS_TEXT", "Icons & Text"), "sui_pcd_icons")
    w[#w+1] = CreateSlider(p, LS("SL_SYNC_ICON_SIZE", "Icon Size"), 12, 60, 1,
        function() return BIT.db.syncCdIconSize or 28 end,
        function(v) BIT.db.syncCdIconSize = v end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_SYNC_ICON_SPACING", "Icon Spacing"), 0, 20, 1,
        function() return BIT.db.syncCdIconSpacing or 4 end,
        function(v) BIT.db.syncCdIconSpacing = v end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_ATTACH_ROW_GAP", "Row Spacing"), 0, 20, 1,
        function() return BIT.db.syncCdAttachRowGap or 4 end,
        function(v) BIT.db.syncCdAttachRowGap = v end,
        function(v) return math.floor(v) .. "px" end)
    -- Max icons per row: when a category has more spells than this, the
    -- overflow wraps into a new sub-row. TOP attach grows upward, BOTTOM
    -- attach grows downward. Default is high enough to not wrap by
    -- default; lower it to compact wide categories into a tighter grid.
    w[#w+1] = CreateSlider(p, LS("SL_MAX_PER_ROW", "Max Icons per Row"), 1, 10, 1,
        function() return BIT.db.syncCdAttachMaxPerRow or 10 end,
        function(v)
            BIT.db.syncCdAttachMaxPerRow = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end,
        function(v) return tostring(math.floor(v)) end)
    w[#w+1] = CreateSlider(p, LS("SL_OFFSET_X", "Offset X"), -100, 100, 1,
        function() return BIT.db.syncCdAttachOffsetX or 0 end,
        function(v) BIT.db.syncCdAttachOffsetX = v end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_OFFSET_Y", "Offset Y"), -100, 100, 1,
        function() return BIT.db.syncCdAttachOffsetY or 0 end,
        function(v) BIT.db.syncCdAttachOffsetY = v end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_SYNC_COUNTER_SIZE", "Counter Text Size"), 6, 24, 1,
        function() return BIT.db.syncCdCounterSize or 14 end,
        function(v) BIT.db.syncCdCounterSize = v end,
        function(v) return math.floor(v) .. "px" end)

    -- ── Charges ─────────────────────────────────────────────────────
    w[#w+1] = CreateSectionHeader(p, LS("SEC_PCD_CHARGES", "Charges"), "sui_pcd_charges")
    local function chargeStyleSetter(key, def)
        return function(v)
            BIT.db[key] = v
            if BIT.SyncCD and BIT.SyncCD.UpdateChargeBadgeStyle then
                BIT.SyncCD:UpdateChargeBadgeStyle()
            end
        end
    end
    w[#w+1] = CreateSlider(p, LS("SL_CHARGE_SIZE", "Badge Size"), 6, 24, 1,
        function() return BIT.db.syncCdChargeSize or 13 end,
        chargeStyleSetter("syncCdChargeSize"),
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateDropdown(p, LS("DD_CHARGE_ANCHOR", "Anchor"),
        { { value = "TOPLEFT",     label = LS("ANCHOR_TOPLEFT",     "Top Left") },
          { value = "TOP",         label = LS("SYNC_POS_TOP",       "Top") },
          { value = "TOPRIGHT",    label = LS("ANCHOR_TOPRIGHT",    "Top Right") },
          { value = "LEFT",        label = LS("SYNC_POS_LEFT",      "Left") },
          { value = "CENTER",      label = LS("ALIGN_CENTER",       "Center") },
          { value = "RIGHT",       label = LS("SYNC_POS_RIGHT",     "Right") },
          { value = "BOTTOMLEFT",  label = LS("ANCHOR_BOTTOMLEFT",  "Bottom Left") },
          { value = "BOTTOM",      label = LS("SYNC_POS_BOTTOM",    "Bottom") },
          { value = "BOTTOMRIGHT", label = LS("ANCHOR_BOTTOMRIGHT", "Bottom Right") } },
        function() return BIT.db.syncCdChargeAnchor or "BOTTOMRIGHT" end,
        chargeStyleSetter("syncCdChargeAnchor"))
    w[#w+1] = CreateSlider(p, LS("SL_CHARGE_OFFSET_X", "Offset X"), -20, 20, 1,
        function() return BIT.db.syncCdChargeOffX or -1 end,
        chargeStyleSetter("syncCdChargeOffX"),
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("SL_CHARGE_OFFSET_Y", "Offset Y"), -20, 20, 1,
        function() return BIT.db.syncCdChargeOffY or 1 end,
        chargeStyleSetter("syncCdChargeOffY"),
        function(v) return math.floor(v) .. "px" end)

    -- ── Visibility ──────────────────────────────────────────────────
    -- Per-zone toggles. Replaces the old "Off" mode option — instead of
    -- one global on/off, the user can choose per content type.
    local function _vis(label, key)
        return CreateToggle(p, label,
            function() return BIT.db[key] ~= false end,
            function(v)
                BIT.db[key] = v
                if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
            end)
    end
    w[#w+1] = CreateSectionHeader(p, LS("SEC_VISIBILITY", "Visibility"), "sui_pcd_vis")
    w[#w+1] = _vis(LS("CB_SHOW_DUNGEON", "Show in Dungeon"),    "syncCdShowInDungeon")
    w[#w+1] = _vis(LS("CB_SHOW_RAID",    "Show in Raid"),        "syncCdShowInRaid")
    w[#w+1] = _vis(LS("CB_SHOW_WORLD",   "Show in Open World"),  "syncCdShowInOpenWorld")
    w[#w+1] = _vis(LS("CB_SHOW_ARENA",   "Show in Arena"),       "syncCdShowInArena")
    w[#w+1] = _vis(LS("CB_SHOW_BG",      "Show in Battleground"),"syncCdShowInBG")

    -- ── Spell Filters — Party CDs ───────────────────────────────────
    w[#w+1] = CreateSectionHeader(p, LS("SEC_SPELL_FILTERS", "Spell Filters"), "sui_pcd_spellfilter")

    local SPEC_TO_CLASS = {
        [250]="DEATHKNIGHT",[251]="DEATHKNIGHT",[252]="DEATHKNIGHT",
        [577]="DEMONHUNTER",[581]="DEMONHUNTER",[1480]="DEMONHUNTER",
        [102]="DRUID",[103]="DRUID",[104]="DRUID",[105]="DRUID",
        [1467]="EVOKER",[1468]="EVOKER",[1473]="EVOKER",
        [253]="HUNTER",[254]="HUNTER",[255]="HUNTER",
        [62]="MAGE",[63]="MAGE",[64]="MAGE",
        [268]="MONK",[269]="MONK",[270]="MONK",
        [65]="PALADIN",[66]="PALADIN",[70]="PALADIN",
        [256]="PRIEST",[257]="PRIEST",[258]="PRIEST",
        [259]="ROGUE",[260]="ROGUE",[261]="ROGUE",
        [262]="SHAMAN",[263]="SHAMAN",[264]="SHAMAN",
        [265]="WARLOCK",[266]="WARLOCK",[267]="WARLOCK",
        [71]="WARRIOR",[72]="WARRIOR",[73]="WARRIOR",
    }
    local PCD_CLASS_DISPLAY = {
        DEATHKNIGHT="DK", DEMONHUNTER="DH",
        DRUID="Druid", EVOKER="Evoker", HUNTER="Hunter",
        MAGE="Mage", MONK="Monk", PALADIN="Paladin",
        PRIEST="Priest", ROGUE="Rogue", SHAMAN="Shaman",
        WARLOCK="Warlock", WARRIOR="Warrior",
    }

    -- Build flat spell list with category + class from BIT.SYNC_SPELLS
    local pcdSpells = {}
    local seenSpell = {}
    if BIT.SYNC_SPELLS then
        for specID, spells in pairs(BIT.SYNC_SPELLS) do
            local cls = SPEC_TO_CLASS[specID]
            if cls then
                for _, s in ipairs(spells) do
                    if not seenSpell[s.id] then
                        seenSpell[s.id] = true
                        pcdSpells[#pcdSpells+1] = {
                            id           = s.id,
                            label        = s.name,
                            class        = cls,
                            className    = PCD_CLASS_DISPLAY[cls] or cls,
                            cat          = s.cat or "DEF",
                            notTrackable = s.notTrackable,
                        }
                    end
                end
            end
        end
        table.sort(pcdSpells, function(a, b)
            if a.class ~= b.class then return a.class < b.class end
            return a.label < b.label
        end)
    end

    -- Split into tab groups: DEF, DMG
    local pcdDef, pcdDmg = {}, {}
    for _, s in ipairs(pcdSpells) do
        if s.cat == "DEF" then pcdDef[#pcdDef+1] = s
        elseif s.cat == "DMG" then pcdDmg[#pcdDmg+1] = s end
    end

    -- Build racial list from BIT.SyncCD.byRace (Shadowmeld, Stoneform, …).
    -- Racials have no class affiliation — use class="RACIAL" so the panel's
    -- CLASS_COLORS lookup falls back to neutral gray; race name is shown
    -- as the suffix (e.g. "Shadowmeld (Night Elf)").
    local PCD_RACE_DISPLAY = {
        NightElf = "Night Elf",
        Dwarf    = "Dwarf",
    }
    local pcdRacial = {}
    if BIT.SyncCD and BIT.SyncCD.byRace then
        for raceKey, entries in pairs(BIT.SyncCD.byRace) do
            for _, s in ipairs(entries) do
                pcdRacial[#pcdRacial+1] = {
                    id        = s.id,
                    label     = s.name,
                    class     = "RACIAL",
                    className = PCD_RACE_DISPLAY[raceKey] or raceKey,
                    cat       = s.cat or "DEF",
                }
            end
        end
        table.sort(pcdRacial, function(a, b)
            if a.className ~= b.className then return a.className < b.className end
            return a.label < b.label
        end)
    end

    local pcdGetter = function(sid) return not (BIT.db.syncCdDisabled and BIT.db.syncCdDisabled[sid]) end
    local pcdSetter = function(sid, enabled)
        if not BIT.db.syncCdDisabled then BIT.db.syncCdDisabled = {} end
        BIT.db.syncCdDisabled[sid] = not enabled or nil
        BIT.db.syncCdDisabledVer = (BIT.db.syncCdDisabledVer or 0) + 1
        if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
    end

    w[#w+1] = CreateSpellFilterPanel(p, pcdDef, pcdGetter, pcdSetter, {
        { label = "Def",    spells = pcdDef    },
        { label = "Off",    spells = pcdDmg    },
        { label = "Racial", spells = pcdRacial },
    })

    return w
end

------------------------------------------------------------
-- ── Category: Smart Misdirect ────────────────────────────
--   Hunter: Misdirection (34477)
--   Rogue : Tricks of the Trade (57934)
--   On any other class the page renders the full settings as
--   a greyed-out, read-only preview so the user can see what
--   the feature offers without being able to interact with it
--   — same disabled-banner pattern as PI Caller,
--   but driven by class instead of a developer flag.
------------------------------------------------------------
local function BuildSmartMisdirect()
    local w = {}
    local p = contentChild

    local myClass = BIT.Self and BIT.Self.class or BIT.myClass
    local eligible = (myClass == "HUNTER" or myClass == "ROGUE")

    -- Class-gate: when the player is neither Hunter nor Rogue every
    -- interactive widget on the page becomes inert (setters wrapped
    -- to no-ops, buttons made un-clickable, alpha dropped) but stays
    -- visible. Users get a full preview of what the feature looks
    -- like without being able to change anything.
    local gated = not eligible

    local function setIf(fn)
        if gated then return function() end end
        return fn
    end

    if gated then
        -- Prominent orange banner with title + auto-wrapped body. Same
        -- layout pattern as the PI Caller disabled banner:
        -- frame height is computed from the body's wrapped string
        -- height so the localized text never gets clipped on the right
        -- edge regardless of language.
        local f = CreateFrame("Frame", nil, p, "BackdropTemplate")
        local frameWidth = p:GetWidth() - CONTENT_PAD * 2
        MakeBg(f, 0.30, 0.20, 0.05, 0.95)
        f:SetBackdropBorderColor(1, 0.55, 0.1, 0.9)

        local title = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(title, 13, "OUTLINE")
        title:SetPoint("TOPLEFT", 10, -6)
        title:SetTextColor(1, 0.7, 0.2)
        title:SetText(LS("SMD_CLASS_GATE_TITLE", "Hunter / Rogue only"))

        local body = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(body, 11)
        body:SetPoint("TOPLEFT", 10, -26)
        body:SetWidth(frameWidth - 20)
        body:SetJustifyH("LEFT")
        body:SetJustifyV("TOP")
        body:SetWordWrap(true)
        body:SetNonSpaceWrap(false)
        body:SetTextColor(0.95, 0.85, 0.7)
        body:SetText(LS("SMD_CLASS_GATE_BODY",
            "Smart Misdirect only works for Hunters (Misdirection) and Rogues (Tricks of the Trade). The settings below are visible so you can see what the feature offers — they are greyed out and inactive on your current class."))

        local bodyH = body:GetStringHeight()
        f:SetSize(frameWidth, math.max(50, 26 + bodyH + 8))

        w[#w+1] = f
        do
            local sp = CreateFrame("Frame", nil, p)
            sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
            w[#w+1] = sp
        end
    end

    w[#w+1] = CreateSectionHeader(p, LS("SMD_SEC_GENERAL", "General"), "sui_smd_gen")
    w[#w+1] = CreateLabel(p, LS("SMD_DESC",
        "Automatically re-targets Misdirection / Tricks of the Trade based on your group, focus and tanks."),
        11)
    -- All toggles below pass suppressHint=gated as the 8th CreateToggle arg
    -- so the orange "Under Construction" text is omitted on the class-gate
    -- preview (the toggles are inactive because the feature doesn't apply
    -- to the current class, not because it's being reworked).
    w[#w+1] = CreateToggle(p, LS("SMD_ENABLED", "Enable Smart Misdirect"),
        function() return BIT.db.smartMdEnabled end,
        setIf(function(v)
            BIT.db.smartMdEnabled = v
            if not BIT.SmartMisdirect then return end
            if v then
                if BIT.SmartMisdirect.CreateButtons then BIT.SmartMisdirect:CreateButtons() end
                if BIT.SmartMisdirect.QueueUpdate   then BIT.SmartMisdirect:QueueUpdate()   end
            else
                if BIT.SmartMisdirect.ClearButtons  then BIT.SmartMisdirect:ClearButtons()  end
            end
        end),
        nil, gated, nil, gated)
    w[#w+1] = CreateToggle(p, LS("SMD_ANNOUNCE_TARGET", "Announce target change in chat"),
        function() return BIT.db.smartMdAnnounceTarget end,
        setIf(function(v) BIT.db.smartMdAnnounceTarget = v end),
        nil, gated, nil, gated)

    -- ── Targeting ───────────────────────────────────────
    w[#w+1] = CreateSectionHeader(p, LS("SMD_SEC_TARGETING", "Targeting"), "sui_smd_target")
    w[#w+1] = CreateToggle(p, LS("SMD_PRIORITIZE_FOCUS", "Prefer Focus target (if in group)"),
        function() return BIT.db.smartMdPrioritizeFocus end,
        setIf(function(v)
            BIT.db.smartMdPrioritizeFocus = v
            if BIT.SmartMisdirect then BIT.SmartMisdirect:QueueUpdate() end
        end),
        nil, gated, nil, gated)
    -- The pet-fallback toggle is normally Hunter-only. When gated
    -- (non-Hunter, non-Rogue) we still render it so the preview is
    -- complete; Rogues continue to see it hidden because the toggle
    -- is genuinely meaningless for them.
    if myClass == "HUNTER" or gated then
        w[#w+1] = CreateToggle(p, LS("SMD_INCLUDE_PET", "Fallback to own pet (Hunter)"),
            function() return BIT.db.smartMdIncludePet end,
            setIf(function(v)
                BIT.db.smartMdIncludePet = v
                if BIT.SmartMisdirect then BIT.SmartMisdirect:QueueUpdate() end
            end),
            nil, gated, nil, gated)
    end
    w[#w+1] = CreateDropdown(p, LS("SMD_TANK_METHOD", "Tank Selection"),
        { { value = "byRole",          label = LS("SMD_METHOD_BY_ROLE",    "By Role (TANK)") },
          { value = "roleAndMainTank", label = LS("SMD_METHOD_ROLE_AND_MT","Role + Main Tank") },
          { value = "mainTankFirst",   label = LS("SMD_METHOD_MT_FIRST",   "Main Tank first") },
          { value = "mainTankOnly",    label = LS("SMD_METHOD_MT_ONLY",    "Main Tank only") } },
        function() return BIT.db.smartMdTankMethod or "byRole" end,
        setIf(function(v)
            BIT.db.smartMdTankMethod = v
            if BIT.SmartMisdirect then BIT.SmartMisdirect:QueueUpdate() end
        end))

    -- ── Manual Override ─────────────────────────────────
    w[#w+1] = CreateSectionHeader(p, LS("SMD_SEC_OVERRIDE", "Manual Override"), "sui_smd_over")
    w[#w+1] = CreateLabel(p, LS("SMD_OVERRIDE_HINT", "Leave empty to disable."), 11)
    w[#w+1] = CreateEditBox(p, LS("SMD_OVERRIDE_NAME", "Player Name"),
        function() return BIT.db.smartMdManualName or "" end,
        setIf(function(v)
            BIT.db.smartMdManualName = v or ""
            if BIT.SmartMisdirect then BIT.SmartMisdirect:QueueUpdate() end
        end))
    w[#w+1] = CreateEditBox(p, LS("SMD_OVERRIDE_REALM", "Realm (cross-realm only)"),
        function() return BIT.db.smartMdManualRealm or "" end,
        setIf(function(v)
            BIT.db.smartMdManualRealm = v or ""
            if BIT.SmartMisdirect then BIT.SmartMisdirect:QueueUpdate() end
        end))
    -- Clear button
    do
        local f = CreateFrame("Frame", nil, p)
        f:SetSize(p:GetWidth() - CONTENT_PAD * 2, WIDGET_H)
        local btn = CreateFrame("Button", nil, f, "BackdropTemplate")
        btn:SetSize(160, 24)
        btn:SetPoint("LEFT", 0, 0)
        MakeBg(btn, 0.18, 0.10, 0.10, 1)
        local txt = btn:CreateFontString(nil, "OVERLAY")
        ApplyFont(txt, 11)
        txt:SetPoint("CENTER")
        txt:SetTextColor(1, 0.5, 0.5)
        txt:SetText(LS("SMD_OVERRIDE_CLEAR", "Clear Override"))
        btn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(1, 0.4, 0.4) end)
        btn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        if gated then
            btn:EnableMouse(false)
        else
            btn:SetScript("OnClick", function()
                if BIT.SmartMisdirect and BIT.SmartMisdirect.ClearManualOverride then
                    BIT.SmartMisdirect:ClearManualOverride(false)
                end
                -- Force a rebuild so the two EditBox widgets re-read the empty value
                if pages[activePage] and pages[activePage].layout then
                    pages[activePage].layout()
                end
                Refresh()
            end)
        end
        w[#w+1] = f
    end

    -- ── Macro ───────────────────────────────────────────
    w[#w+1] = CreateSectionHeader(p, LS("SMD_SEC_MACRO", "Macro"), "sui_smd_macro")
    w[#w+1] = CreateLabel(p, LS("SMD_MACRO_HINT",
        "Creates a per-character macro you can drag onto your action bar."), 11)
    do
        local f = CreateFrame("Frame", nil, p)
        f:SetSize(p:GetWidth() - CONTENT_PAD * 2, WIDGET_H + 6)

        local btn = CreateFrame("Button", nil, f, "BackdropTemplate")
        btn:SetSize(220, 26)
        btn:SetPoint("LEFT", 0, 0)
        MakeBg(btn, 0.15, 0.15, 0.18, 1)
        local txt = btn:CreateFontString(nil, "OVERLAY")
        ApplyFont(txt, 12)
        txt:SetPoint("CENTER")
        txt:SetTextColor(RGB(ACCENT))
        txt:SetText(LS("SMD_MACRO_BTN", "Create / Update Macro"))
        btn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        btn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        if gated then
            btn:EnableMouse(false)
        else
            btn:SetScript("OnClick", function()
                if not BIT.SmartMisdirect or not BIT.SmartMisdirect.CreateMacro then return end
                if InCombatLockdown() then
                    txt:SetTextColor(1, 0.4, 0.4)
                    txt:SetText("|cffff5555" .. LS("SMD_MACRO_IN_COMBAT",
                        "Cannot create macros while in combat.") .. "|r")
                    C_Timer.After(3, function()
                        txt:SetTextColor(RGB(ACCENT))
                        txt:SetText(LS("SMD_MACRO_BTN", "Create / Update Macro"))
                    end)
                    return
                end
                local idx, created, updated = BIT.SmartMisdirect:CreateMacro()
                if idx then
                    txt:SetText("|cFF00FF00" .. (created and "Created!" or "Updated!") .. "|r")
                    C_Timer.After(2, function()
                        txt:SetTextColor(RGB(ACCENT))
                        txt:SetText(LS("SMD_MACRO_BTN", "Create / Update Macro"))
                    end)
                end
            end)
        end

        w[#w+1] = f
    end

    -- Final greying pass when gated: drop alpha on every widget except
    -- the class-gate banner (index 1 when gated) so the page reads as
    -- "look but don't touch". Toggles already grey themselves via the
    -- built-in disabled flag; this extends the visual treatment to the
    -- dropdown, edit boxes, buttons, labels and section headers. The
    -- banner itself stays at full alpha so its message remains prominent.
    if gated then
        for i = 1, #w do
            local widget = w[i]
            if i > 1 and widget and widget.SetAlpha then
                widget:SetAlpha(0.45)
            end
        end
    end

    return w
end

------------------------------------------------------------
-- ── Category: Offensive CD Alert ─────────────────────────
------------------------------------------------------------
local function BuildOffensiveCDAlert()
    local w = {}
    local p = contentChild

    -- Developer feature-gate: when OCA.FEATURE_DISABLED is true the
    -- entire PI Caller page renders read-only. Banner at top, all
    -- interactive widgets greyed and inert (no DB writes, no button
    -- clicks). Flip the flag in OffensiveCDAlert.lua to bring it
    -- back online.
    local gated = BIT.OffensiveCDAlert and BIT.OffensiveCDAlert.FEATURE_DISABLED == true

    local function setIf(fn)
        if gated then return function() end end
        return fn
    end

    if gated then
        -- Prominent orange banner with title + auto-wrapped body —
        -- frame height is computed from the body's wrapped string
        -- height so the localized text never gets clipped on the right
        -- edge regardless of language.
        local f = CreateFrame("Frame", nil, p, "BackdropTemplate")
        local frameWidth = p:GetWidth() - CONTENT_PAD * 2
        MakeBg(f, 0.30, 0.20, 0.05, 0.95)
        f:SetBackdropBorderColor(1, 0.55, 0.1, 0.9)

        local title = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(title, 13, "OUTLINE")
        title:SetPoint("TOPLEFT", 10, -6)
        title:SetTextColor(1, 0.7, 0.2)
        title:SetText(LS("PI_DISABLED_TITLE", "Feature temporarily disabled"))

        local body = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(body, 11)
        body:SetPoint("TOPLEFT", 10, -26)
        body:SetWidth(frameWidth - 20)
        body:SetJustifyH("LEFT")
        body:SetJustifyV("TOP")
        body:SetWordWrap(true)
        body:SetNonSpaceWrap(false)
        body:SetTextColor(0.95, 0.85, 0.7)
        body:SetText(LS("PI_DISABLED_BODY",
            "PI Caller is being reworked and is currently disabled in this build. The settings below are read-only previews — toggles, sliders and buttons won't apply. The feature will be re-enabled in a future release."))

        local bodyH = body:GetStringHeight()
        f:SetSize(frameWidth, math.max(50, 26 + bodyH + 8))

        w[#w+1] = f
        do
            local sp = CreateFrame("Frame", nil, p)
            sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
            w[#w+1] = sp
        end
    else
        -- Beta disclaimer at the top of the page so users know what state
        -- the feature is in before they tweak settings or report issues.
        -- Only shown when NOT gated — when gated the disabled banner
        -- above carries the messaging.
        w[#w+1] = CreateLabel(p, LS("PI_BETA_DISCLAIMER",
            "|cffff8800BETA - work in progress.|r The PI Caller feature is "
            .. "still under development and largely non-functional. It needs "
            .. "extensive testing before it can be considered reliable. "
            .. "Expect spells to be missed, false positives, or visual quirks."),
            11)
    end

    -- General toggle + display mode
    w[#w+1] = CreateSectionHeader(p, LS("SEC_GENERAL", "General"), "sui_oca_gen")
    w[#w+1] = CreateToggle(p, LS("CB_ENABLE_PI_CALLER", "Enable PI Caller"),
        function() return BIT.db.offensiveCDAlertEnabled end,
        setIf(function(v)
            BIT.db.offensiveCDAlertEnabled = v
            if BIT.OffensiveCDAlert then BIT.OffensiveCDAlert:Refresh() end
        end),
        nil, gated)
    w[#w+1] = CreateDropdown(p, LS("DD_DISPLAY_MODE", "Display Mode"),
        { { value = "GLOW",   label = LS("DM_GLOW_ONLY",   "Button Glow only") },
          { value = "BORDER", label = LS("DM_BORDER_ONLY", "Border only") },
          { value = "BOTH",   label = LS("DM_GLOW_BORDER", "Glow + Border") } },
        function() return BIT.db.offensiveCDAlertMode or "BOTH" end,
        setIf(function(v)
            BIT.db.offensiveCDAlertMode = v
            if BIT.OffensiveCDAlert then BIT.OffensiveCDAlert:Refresh() end
        end))

    -- Test button: paints the alert visuals on a real party frame (or
    -- the player frame if you're solo) for 5 seconds so you can see how
    -- your current settings look without waiting for someone to burst.
    do
        local f = CreateFrame("Frame", nil, p)
        f:SetSize(p:GetWidth() - CONTENT_PAD * 2, WIDGET_H + 6)
        local btn = CreateFrame("Button", nil, f, "BackdropTemplate")
        btn:SetSize(180, 26)
        btn:SetPoint("LEFT", 0, 0)
        MakeBg(btn, 0.13, 0.18, 0.13, 1)
        local txt = btn:CreateFontString(nil, "OVERLAY")
        ApplyFont(txt, 11)
        txt:SetPoint("CENTER")
        txt:SetTextColor(0.6, 1, 0.6)
        txt:SetText(LS("PI_PREVIEW_BTN", "Preview Alert (5s)"))
        btn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(0.4, 1, 0.4) end)
        btn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        if gated then
            btn:EnableMouse(false)
        else
            btn:SetScript("OnClick", function()
                if BIT.OffensiveCDAlert and BIT.OffensiveCDAlert.Test then
                    BIT.OffensiveCDAlert:Test(5)
                end
            end)
        end
        w[#w+1] = f
    end

    -- Border styling
    w[#w+1] = CreateSectionHeader(p, LS("SEC_BORDER_STYLE", "Border Style"), "sui_oca_border")
    w[#w+1] = CreateSlider(p, LS("SL_PI_BORDER_THICK", "Border Thickness"), 1, 8, 1,
        function() return BIT.db.offensiveCDAlertBorderSize or 3 end,
        setIf(function(v)
            BIT.db.offensiveCDAlertBorderSize = v
            if BIT.OffensiveCDAlert then BIT.OffensiveCDAlert:Refresh() end
        end),
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateColorSwatch(p, LS("COLOR_BORDER_SWATCH", "Border Color"),
        function() return BIT.db.offensiveCDAlertColorR or 1.0 end,
        function() return BIT.db.offensiveCDAlertColorG or 0.4 end,
        function() return BIT.db.offensiveCDAlertColorB or 0.1 end,
        setIf(function(r, g, b)
            BIT.db.offensiveCDAlertColorR = r
            BIT.db.offensiveCDAlertColorG = g
            BIT.db.offensiveCDAlertColorB = b
            if BIT.OffensiveCDAlert then BIT.OffensiveCDAlert:Refresh() end
        end))

    -- Per-spell whitelist, grouped by class. Class headers mirror the
    -- styling used on the Profiles → Auto-Switch page: localised class
    -- name in class colour, class-coloured hover line underneath, and
    -- collapse/expand on click. All classes start expanded so the user
    -- sees every spell immediately on first open — collapse is a
    -- power-user shortcut, not the default state.
    if BIT.OffensiveCDAlert and BIT.OffensiveCDAlert.GetSpellList then
        w[#w+1] = CreateSectionHeader(p, LS("SEC_SPELL_FILTERS", "Spell Filters"), "sui_oca_spells")

        local spells = BIT.OffensiveCDAlert:GetSpellList()
        local classExpanded = {}

        -- Helper to add a clickable class header to the widget list. Returns
        -- the per-class expanded-state lookup so the spell toggles below
        -- can wire their visibility to it.
        local function addClassHeader(classFile)
            classExpanded[classFile] = true

            local cc = (BIT.CLASS_COLORS and BIT.CLASS_COLORS[classFile]) or { 0.8, 0.8, 0.8 }
            local localizedName =
                (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classFile])
                or classFile

            local header = CreateFrame("Button", nil, p)
            header:SetSize(p:GetWidth() - CONTENT_PAD * 2, 22)

            local arrowFs = header:CreateFontString(nil, "OVERLAY")
            ApplyFont(arrowFs, 10)
            arrowFs:SetPoint("LEFT", 0, 0)
            arrowFs:SetTextColor(RGB(ACCENT))

            local nameFs = header:CreateFontString(nil, "OVERLAY")
            ApplyFont(nameFs, 12, "OUTLINE")
            nameFs:SetPoint("LEFT", 16, 0)
            nameFs:SetTextColor(cc[1], cc[2], cc[3])
            nameFs:SetText(localizedName)

            local hoverLine = header:CreateTexture(nil, "BACKGROUND")
            hoverLine:SetHeight(1)
            hoverLine:SetPoint("BOTTOMLEFT", 0, 0)
            hoverLine:SetPoint("BOTTOMRIGHT", 0, 0)
            hoverLine:SetColorTexture(cc[1], cc[2], cc[3], 0.25)

            local function syncArrow()
                arrowFs:SetText(classExpanded[classFile] and "v" or ">")
            end
            syncArrow()

            header:SetScript("OnEnter", function()
                hoverLine:SetColorTexture(cc[1], cc[2], cc[3], 0.6)
            end)
            header:SetScript("OnLeave", function()
                hoverLine:SetColorTexture(cc[1], cc[2], cc[3], 0.25)
            end)
            header:SetScript("OnClick", function()
                classExpanded[classFile] = not classExpanded[classFile]
                syncArrow()
                if pages and pages[activePage] and pages[activePage].refresh then
                    pages[activePage].refresh()
                end
                if pages and pages[activePage] and pages[activePage].layout then
                    pages[activePage].layout()
                end
            end)

            w[#w+1] = header
        end

        local lastClass = nil
        for _, s in ipairs(spells) do
            if s.class ~= lastClass then
                lastClass = s.class
                addClassHeader(s.class)
            end
            -- Pull the spell's texture so the toggle row shows the
            -- familiar in-game icon next to the spell name.
            local tex
            local okT, t = pcall(C_Spell.GetSpellTexture, s.id)
            if okT and t then tex = t end

            local thisClass = s.class
            local toggle = CreateToggle(p, s.name,
                function()
                    local ov = BIT.db.offensiveCDAlertSpells and BIT.db.offensiveCDAlertSpells[s.id]
                    if ov ~= nil then return ov end
                    return s.default
                end,
                setIf(function(v)
                    BIT.db.offensiveCDAlertSpells = BIT.db.offensiveCDAlertSpells or {}
                    BIT.db.offensiveCDAlertSpells[s.id] = v
                    if BIT.OffensiveCDAlert then BIT.OffensiveCDAlert:Refresh() end
                end),
                nil,    -- indent
                gated,  -- disabled while feature-gated
                tex)    -- iconTexture

            -- Wire visibility to the class-header expanded state so a
            -- collapsed class hides every spell underneath it (and
            -- LayoutWidgets reclaims the slots — no leftover gaps).
            toggle._dynamic = true
            local origUpdate = toggle._update
            toggle._update = function()
                if classExpanded[thisClass] then
                    toggle:Show()
                else
                    toggle:Hide()
                end
                if origUpdate then origUpdate() end
            end

            w[#w+1] = toggle
        end
    end

    -- ── PI Macro auto-cast ─────────────────────────────────
    -- Smart-Misdirect-style architecture: the macro body is FIXED (just
    -- /clicks N hidden secure buttons in priority order). The priority
    -- list lives on the secure buttons themselves, updated dynamically
    -- as the user edits the list — no need to ever rewrite the macro.
    w[#w+1] = CreateSectionHeader(p, LS("PI_MACRO_SEC", "PI Macro Auto-Cast"), "sui_pi_macro")
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 6)
        w[#w+1] = sp
    end
    w[#w+1] = CreateLabel(p, LS("PI_MACRO_DESC",
        "Creates a macro \"BIT_PI\" that casts Power Infusion on the first valid name from your priority list (alive, in group, friendly). The macro itself is a one-time creation — the priority list lives on hidden secure buttons that update automatically as you edit it. Drag the macro onto an action bar to use it."), 11)
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
        w[#w+1] = sp
    end

    w[#w+1] = CreateToggle(p, LS("PI_MACRO_ENABLE", "Enable PI auto-cast"),
        function() return BIT.db.piMacroEnabled == true end,
        setIf(function(v)
            BIT.db.piMacroEnabled = v
            if BIT.OffensiveCDAlert and BIT.OffensiveCDAlert.QueuePIUpdate then
                -- Toggle on:  apply current names to the secure buttons
                -- Toggle off: clear button targets so the macro becomes
                --             a no-op (instead of firing on stale names)
                BIT.OffensiveCDAlert:QueuePIUpdate()
            end
        end),
        nil, gated)

    -- Priority-list editor: free-form multi-line text, one name per
    -- line. The OffensiveCDAlert module parses this on apply, trims
    -- whitespace, dedupes, and caps at 5 entries (= number of secure
    -- buttons we expose). Names can be either short ("Mvphunt") or
    -- full realm-suffixed ("Mvphunt-Eredar"); WoW unit-attribute
    -- semantics accept both.
    w[#w+1] = CreateLabel(p, LS("PI_MACRO_LIST_HINT",
        "One player name per line, top = highest priority. Use \"Name\" for same-realm or \"Name-Realm\" for cross-realm. Maximum 5 names."), 11)
    w[#w+1] = CreateEditBox(p, LS("PI_MACRO_LIST_LABEL", "Priority list"),
        function() return BIT.db.piMacroNames or "" end,
        setIf(function(v)
            BIT.db.piMacroNames = v or ""
            -- Live-apply the new names to the secure buttons. Combat-
            -- locked SetAttribute calls are auto-deferred via the
            -- module's PLAYER_REGEN_ENABLED queue, so the user can
            -- save during a fight and the change takes effect on the
            -- next out-of-combat tick.
            if BIT.db.piMacroEnabled
                and BIT.OffensiveCDAlert and BIT.OffensiveCDAlert.QueuePIUpdate then
                BIT.OffensiveCDAlert:QueuePIUpdate()
            end
        end),
        340, 6)

    -- Macro preview: read-only display of the FIXED macro body. Same
    -- content for everyone — only the secure-button targets change.
    do
        local f = CreateFrame("Frame", nil, p)
        f:SetSize(p:GetWidth() - CONTENT_PAD * 2, 110)

        local lbl = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(lbl, 11)
        lbl:SetPoint("TOPLEFT", 0, 0)
        lbl:SetTextColor(RGB(TEXT_DIM))
        lbl:SetText(LS("PI_MACRO_PREVIEW_LABEL", "Macro preview (fixed — never rewrites)"))

        local box = CreateFrame("Frame", nil, f, "BackdropTemplate")
        box:SetPoint("TOPLEFT", 0, -16)
        box:SetPoint("RIGHT", 0, 0)
        box:SetHeight(86)
        MakeBg(box, RGB(WIDGET_BG))

        local txt = box:CreateFontString(nil, "ARTWORK")
        ApplyFont(txt, 11, "OUTLINE")
        txt:SetPoint("TOPLEFT", 6, -4)
        txt:SetPoint("BOTTOMRIGHT", -6, 4)
        txt:SetJustifyH("LEFT")
        txt:SetJustifyV("TOP")
        txt:SetTextColor(0.85, 0.85, 0.85)
        local body = (BIT.OffensiveCDAlert and BIT.OffensiveCDAlert.GetPIMacroBody
            and BIT.OffensiveCDAlert:GetPIMacroBody()) or ""
        txt:SetText(body)

        w[#w+1] = f
    end

    -- Action buttons: Create / update macro (one-shot — writes the
    -- fixed body to a per-character macro slot) + Open Macro UI
    -- (jumps to Blizzard's macro frame so the user can drag the
    -- BIT_PI macro onto an action bar).
    do
        local f = CreateFrame("Frame", nil, p)
        f:SetSize(p:GetWidth() - CONTENT_PAD * 2, WIDGET_H + 4)

        local createBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
        createBtn:SetSize(220, 24)
        createBtn:SetPoint("LEFT", 0, 0)
        MakeBg(createBtn, 0.15, 0.15, 0.18, 1)
        local createTxt = createBtn:CreateFontString(nil, "OVERLAY")
        ApplyFont(createTxt, 11)
        createTxt:SetPoint("CENTER")
        createTxt:SetTextColor(RGB(ACCENT))
        createTxt:SetText(LS("PI_MACRO_CREATE_BTN", "Create / update macro"))
        createBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        createBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        if gated then
            createBtn:EnableMouse(false)
        else
            createBtn:SetScript("OnClick", function()
                if BIT.OffensiveCDAlert and BIT.OffensiveCDAlert.CreatePIMacro then
                    BIT.OffensiveCDAlert:CreatePIMacro()
                end
            end)
        end

        local openBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
        openBtn:SetSize(180, 24)
        openBtn:SetPoint("LEFT", createBtn, "RIGHT", 8, 0)
        MakeBg(openBtn, 0.15, 0.15, 0.18, 1)
        local openTxt = openBtn:CreateFontString(nil, "OVERLAY")
        ApplyFont(openTxt, 11)
        openTxt:SetPoint("CENTER")
        openTxt:SetTextColor(RGB(ACCENT))
        openTxt:SetText(LS("PI_MACRO_OPEN_BTN", "Open Blizzard macro UI"))
        openBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        openBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        if gated then
            openBtn:EnableMouse(false)
        else
            openBtn:SetScript("OnClick", function()
                if BIT.OffensiveCDAlert and BIT.OffensiveCDAlert.OpenPIMacroFrame then
                    BIT.OffensiveCDAlert:OpenPIMacroFrame()
                end
            end)
        end

        w[#w+1] = f
    end

    -- Final greying pass when gated: drop alpha on every widget except
    -- the disabled-state banner (index 1 when gated) so the page reads
    -- as "look but don't touch". Toggles already grey themselves via the
    -- built-in disabled flag; this extends the visual treatment to
    -- sliders, the color swatch, buttons, labels, section headers, and
    -- the spell-filter list. The banner stays at full alpha so its
    -- message remains prominent.
    if gated then
        for i = 1, #w do
            local widget = w[i]
            if i > 1 and widget and widget.SetAlpha then
                widget:SetAlpha(0.45)
            end
        end
    end

    return w
end

------------------------------------------------------------
-- ── Category: Keystone List ──────────────────────────────
-- Optional Mythic+ keystone group display. All settings gated by
-- BIT.db.keystoneListEnabled; when off, the panel still renders the toggle
-- so the feature can be discovered. Cross-addon compat via WA-KeyStGrList
-- protocol (default ON) and LibOpenRaid-1.0 (default ON if available).
------------------------------------------------------------
local function BuildKeystoneList()
    local w = {}
    local p = contentChild

    w[#w+1] = CreateSectionHeader(p, LS("KEY_SEC_GENERAL", "General"), "sui_kl_gen")
    -- Spacer between header and description so the wrapped multi-line text
    -- doesn't overflow into the section header line. CreateLabel sizes
    -- itself based on its initial single-line height; long wrapped text
    -- expands later in OnShow which can race the layout pass — a small
    -- spacer below the header guarantees breathing room either way.
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 6)
        w[#w+1] = sp
    end
    w[#w+1] = CreateLabel(p, LS("KEY_DESC_1",
        "Shows your party's Mythic+ keystones with click-to-teleport."), 11)
    w[#w+1] = CreateLabel(p, LS("KEY_DESC_2",
        "Compatible with cross-addon keystone protocols and LibOpenRaid for shared key data."), 11)
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 6)
        w[#w+1] = sp
    end

    -- Test Layout toggle — populates the frame with 5 sample rows so the
    -- user can position the frame as if a full M+ group were present.
    -- Lives at the very top of the page so it's reachable without
    -- scrolling past the other toggles, since positioning is the most
    -- common reason to open this page. Mirrors the Interrupt Tracker's
    -- "Test Mode" toggle pattern: the getter reads live state from the
    -- module, the setter routes to ToggleTestMode only when the value
    -- actually changes (avoids a double-flip on the initial render).
    w[#w+1] = CreateToggle(p, LS("KEY_TEST_LAYOUT", "Test Layout"),
        function()
            return BIT.KeystoneList and BIT.KeystoneList:IsTestModeActive() or false
        end,
        function(v)
            if not BIT.KeystoneList or not BIT.KeystoneList.ToggleTestMode then return end
            local active = BIT.KeystoneList:IsTestModeActive()
            if v ~= active then
                BIT.KeystoneList:ToggleTestMode()
            end
        end)

    w[#w+1] = CreateToggle(p, LS("KEY_ENABLED", "Enable Keystone List"),
        function() return BIT.db.keystoneListEnabled end,
        function(v)
            BIT.db.keystoneListEnabled = v
            if BIT.KeystoneList and BIT.KeystoneList.SetEnabled then
                BIT.KeystoneList:SetEnabled(v)
            end
        end)

    w[#w+1] = CreateToggle(p, LS("KEY_LOCKED", "Lock Position"),
        function() return BIT.db.keystoneListLocked end,
        function(v) BIT.db.keystoneListLocked = v end)

    w[#w+1] = CreateToggle(p, LS("KEY_GROW_UPWARD", "Grow Upward"),
        function() return BIT.db.keystoneListGrowUpward == true end,
        function(v)
            BIT.db.keystoneListGrowUpward = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)

    w[#w+1] = CreateToggle(p, LS("KEY_MIRROR", "Mirror layout (icon on right)"),
        function() return BIT.db.keystoneListMirror == true end,
        function(v)
            BIT.db.keystoneListMirror = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)

    w[#w+1] = CreateToggle(p, LS("KEY_CLICK_TELEPORT", "Click icon to teleport"),
        function() return BIT.db.keystoneListClickTeleport ~= false end,
        function(v)
            BIT.db.keystoneListClickTeleport = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)

    -- Row gap: vertical spacing between stacked keystone rows. Default 1px
    -- keeps the historical look; 0 makes rows touch edge-to-edge; higher
    -- values are useful when a border thickness or a textured edge needs
    -- visual breathing room between adjacent rows.
    w[#w+1] = CreateSlider(p, LS("KEY_ROW_GAP", "Row Gap"), 0, 20, 1,
        function() return BIT.db.keystoneListRowGap or 1 end,
        function(v)
            BIT.db.keystoneListRowGap = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end,
        function(v) return math.floor(v) .. "px" end)

    -- ── Border ─────────────────────────────────────────────
    -- Dedicated size + offset sliders for the keystone list. The
    -- global Size & Font border slider used to drive this too, which
    -- made changing the tracker border also change the keystone list
    -- (and inversely: growing it shrank the visible icon, because
    -- Blizzard's edgeFile draws inward). Texture path and color are
    -- still shared with the global Border settings — only thickness
    -- and outward distance are independent here.
    w[#w+1] = CreateSectionHeader(p, LS("KEY_SEC_BORDER", "Border"), "sui_kl_border")
    w[#w+1] = CreateSlider(p, LS("KEY_BORDER_SIZE", "Border Size"), 0, 24, 1,
        function() return BIT.db.keystoneListBorderSize or 2 end,
        function(v)
            BIT.db.keystoneListBorderSize = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    -- Negative offsets pull the border inward so it overlaps the icon's
    -- outer edge — useful for decorative frames where a slight overlap
    -- looks intentional on small (42x38) keystone icons. Range chosen
    -- so the bo frame stays renderable even at the lower bound.
    w[#w+1] = CreateSlider(p, LS("KEY_BORDER_OFFSET", "Border Offset"), -10, 20, 1,
        function() return BIT.db.keystoneListBorderOffset or 0 end,
        function(v)
            BIT.db.keystoneListBorderOffset = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end,
        function(v) return math.floor(v) .. "px" end)

    -- ── Visibility ──────────────────────────────────────
    w[#w+1] = CreateSectionHeader(p, LS("KEY_SEC_VIS", "Visibility"), "sui_kl_vis")
    w[#w+1] = CreateToggle(p, LS("KEY_SHOW_IN_PARTY", "Show in party (5-player group)"),
        function() return BIT.db.keystoneListShowInParty ~= false end,
        function(v)
            BIT.db.keystoneListShowInParty = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)
    w[#w+1] = CreateToggle(p, LS("KEY_SHOW_IN_RAID", "Show in raid"),
        function() return BIT.db.keystoneListShowInRaid == true end,
        function(v)
            BIT.db.keystoneListShowInRaid = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)
    w[#w+1] = CreateToggle(p, LS("KEY_SHOW_SOLO", "Show when solo / open world"),
        function() return BIT.db.keystoneListShowSolo ~= false end,
        function(v)
            BIT.db.keystoneListShowSolo = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)
    w[#w+1] = CreateToggle(p, LS("KEY_HIDE_IN_M", "Hide during active M+ run"),
        function() return BIT.db.keystoneListHideInM == true end,
        function(v)
            BIT.db.keystoneListHideInM = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)

    -- ── Text Sizes ──────────────────────────────────────
    -- Font face + outline come from Size & Font (so the keystone list
    -- matches the rest of the addon). Size is tuned here so users can
    -- shrink / grow individual rows without touching the main tracker.
    w[#w+1] = CreateSectionHeader(p, LS("KEY_SEC_TEXT_SIZE", "Text Sizes"), "sui_kl_text")
    -- Frame scale: uniform multiplier on the whole list (icons, text,
    -- gaps). Independent of the per-element font sizes below.
    w[#w+1] = CreateSlider(p, LS("KEY_FRAME_SCALE", "Frame Scale"), 50, 200, 5,
        function() return BIT.db.keystoneListScale or 100 end,
        function(v)
            BIT.db.keystoneListScale = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end,
        function(v) return math.floor(v) .. "%" end)
    w[#w+1] = CreateSlider(p, LS("KEY_LEVEL_SIZE", "Keystone Level Size"), 8, 28, 1,
        function() return BIT.db.keystoneListLevelSize or 16 end,
        function(v)
            BIT.db.keystoneListLevelSize = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("KEY_NAME_SIZE", "Player Name Size"), 6, 24, 1,
        function() return BIT.db.keystoneListNameSize or 11 end,
        function(v)
            BIT.db.keystoneListNameSize = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end,
        function(v) return math.floor(v) .. "px" end)
    w[#w+1] = CreateSlider(p, LS("KEY_DUNGEON_SIZE", "Dungeon Name Size"), 8, 28, 1,
        function() return BIT.db.keystoneListDungeonSize or 14 end,
        function(v)
            BIT.db.keystoneListDungeonSize = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end,
        function(v) return math.floor(v) .. "px" end)

    -- ── Display options ────────────────────────────────
    w[#w+1] = CreateSectionHeader(p, LS("KEY_SEC_DISPLAY", "Display Options"), "sui_kl_disp")
    w[#w+1] = CreateToggle(p, LS("KEY_USE_ABBREV", "Use abbreviations for keystone names"),
        function() return BIT.db.keystoneListUseAbbreviation == true end,
        function(v)
            BIT.db.keystoneListUseAbbreviation = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)
    w[#w+1] = CreateToggle(p, LS("KEY_SHOW_NO_PORT", "Show 'no port' indicator when teleport is unknown"),
        function() return BIT.db.keystoneListShowNoPort ~= false end,
        function(v)
            BIT.db.keystoneListShowNoPort = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)
    w[#w+1] = CreateToggle(p, LS("KEY_SHOW_RESILIENT", "Show resilient keystone indicator"),
        function() return BIT.db.keystoneListShowResilient ~= false end,
        function(v)
            BIT.db.keystoneListShowResilient = v
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)
    -- LFG queue → dungeon icon glow toggle.
    -- Default ON. When enabled, the dungeon icon for the M+ Group Finder
    -- activity the user is queued into lights up (LibButtonGlow ring) the
    -- moment the queue resolves into a full 5-player party — same visual
    -- as the spell-activation flare. Auto-clears on entering the dungeon
    -- or leaving the party. Flipping this toggle off mid-glow clears any
    -- currently-active glow on the next display rebuild.
    w[#w+1] = CreateToggle(p, LS("KEY_QUEUE_GLOW", "Glow dungeon icon when queued group fills"),
        function() return BIT.db.keystoneListQueueGlow ~= false end,
        function(v)
            BIT.db.keystoneListQueueGlow = v
            if v == false and BIT.KeystoneList and BIT.KeystoneList.ClearDungeonGlow then
                -- Disabling mid-glow → drop the current glow target so
                -- it doesn't linger on the icon until the next reload.
                BIT.KeystoneList:ClearDungeonGlow()
            end
            if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                BIT.KeystoneList:OnSettingsChanged()
            end
        end)

    -- Position the banner via the "Test Layout" toggle at the top of this
    -- page: enabling test mode also shows a movable banner placeholder.
    w[#w+1] = CreateToggle(p, LS("KEY_JOIN_BANNER", "Show join info banner (Group Finder)"),
        function() return BIT.db.keystoneListJoinBanner ~= false end,
        function(v)
            BIT.db.keystoneListJoinBanner = v
            if v == false and BIT.KeystoneList and BIT.KeystoneList.HideJoinBanner
               and not (BIT.KeystoneList.IsTestModeActive and BIT.KeystoneList:IsTestModeActive()) then
                BIT.KeystoneList:HideJoinBanner()
            end
        end)

    -- ── Port-CD Announce ───────────────────────────────
    -- When enabled, clicking a dungeon icon while the teleport is on
    -- cooldown posts a chat message to the party / raid. Useful for
    -- letting the group know you can't teleport without manually typing
    -- the dungeon name + remaining time.
    w[#w+1] = CreateSectionHeader(p, LS("KEY_SEC_PORTCD", "Port Cooldown Announce"), "sui_kl_portcd")
    -- Spacer between header and description: CreateLabel sizes itself
    -- on its initial single-line height; multi-line text expands later
    -- in OnShow, which races the layout pass on the very first render.
    -- An explicit spacer guarantees breathing room on first paint so the
    -- info text doesn't visually collide with the section header until
    -- the user collapses + re-expands the section.
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 6)
        w[#w+1] = sp
    end
    w[#w+1] = CreateLabel(p, LS("KEY_PORTCD_DESC",
        "When your dungeon teleport is on cooldown and you click the icon, post a chat message to your group."), 11)
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
        w[#w+1] = sp
    end
    w[#w+1] = CreateToggle(p, LS("KEY_PORTCD_ENABLE", "Announce port cooldown in group chat"),
        function() return BIT.db.keystoneListPortCdAnnounce == true end,
        function(v) BIT.db.keystoneListPortCdAnnounce = v end)

    -- Variable hint with hover tooltips. Each variable name is a tiny
    -- invisible Button so GameTooltip can show what the placeholder
    -- substitutes to in the chat output. Lets users discover the
    -- available variables without having to read the changelog or wiki
    -- — just hover over the gold {dungeon} / {abbr} / {remain} chips.
    do
        local row = CreateFrame("Frame", nil, p)
        row:SetSize(p:GetWidth() - CONTENT_PAD * 2, WIDGET_H - 4)

        local prefix = row:CreateFontString(nil, "OVERLAY")
        ApplyFont(prefix, 11)
        prefix:SetPoint("LEFT", 0, 0)
        prefix:SetTextColor(RGB(TEXT_DIM))
        prefix:SetText(LS("KEY_PORTCD_VARS_LABEL", "Available variables:"))

        -- Build a hover-only Button that displays {varName} in gold and
        -- shows a GameTooltip describing the substitution on hover.
        -- No OnClick wired — it's a label-with-tooltip, not an action.
        local function makeVarChip(varName, tooltipKey, tooltipDefault)
            local chip = CreateFrame("Button", nil, row)
            local fs = chip:CreateFontString(nil, "OVERLAY")
            ApplyFont(fs, 11)
            fs:SetPoint("LEFT", 0, 0)
            fs:SetTextColor(1, 0.84, 0)         -- |cffffd700 gold
            fs:SetText("{" .. varName .. "}")
            -- Size the hit-target to the rendered text width so the
            -- tooltip only fires when the cursor is actually over the
            -- variable name, not the surrounding whitespace.
            chip:SetSize(math.max(8, fs:GetStringWidth()), 14)
            chip:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
                GameTooltip:SetText("{" .. varName .. "}", 1, 0.84, 0)
                GameTooltip:AddLine(LS(tooltipKey, tooltipDefault), 1, 1, 1, true)
                GameTooltip:Show()
            end)
            chip:SetScript("OnLeave", function() GameTooltip:Hide() end)
            return chip
        end

        local cDungeon = makeVarChip("dungeon", "KEY_PORTCD_VAR_DUNGEON",
            "Full dungeon name (e.g. \"Magisters' Terrace\").")
        cDungeon:SetPoint("LEFT", prefix, "RIGHT", 8, 0)

        local cAbbr = makeVarChip("abbr", "KEY_PORTCD_VAR_ABBR",
            "Short dungeon abbreviation (e.g. \"MT\").")
        cAbbr:SetPoint("LEFT", cDungeon, "RIGHT", 10, 0)

        local cRemain = makeVarChip("remain", "KEY_PORTCD_VAR_REMAIN",
            "Remaining teleport cooldown, formatted as e.g. \"8m 32s\".")
        cRemain:SetPoint("LEFT", cAbbr, "RIGHT", 10, 0)

        w[#w+1] = row
    end
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
        w[#w+1] = sp
    end

    -- Custom message edit box (wide so a full sentence fits, two lines
    -- tall so longer templates with all five variables are readable
    -- without horizontal scrolling). When the saved value is empty,
    -- show the localised default text so the user has something to read
    -- / edit instead of a blank box. Saving the default text back
    -- unchanged is treated as "still default" by collapsing it to an
    -- empty string in the DB.
    w[#w+1] = CreateEditBox(p, LS("KEY_PORTCD_MESSAGE", "Chat message"),
        function()
            local v = BIT.db.keystoneListPortCdMessage
            if v == nil or v == "" then
                return LS("KEY_PORTCD_DEFAULT", "Sorry, could I get a port please? My {dungeon} port is on cooldown ({remain} left).")
            end
            return v
        end,
        function(v)
            v = v or ""
            local default = LS("KEY_PORTCD_DEFAULT", "Sorry, could I get a port please? My {dungeon} port is on cooldown ({remain} left).")
            if v == default then
                BIT.db.keystoneListPortCdMessage = ""  -- treat "matches default" as "use default"
            else
                BIT.db.keystoneListPortCdMessage = v
            end
        end,
        340, 2)

    -- "Reset to default" + "Test announce" buttons side by side
    -- - Reset clears the custom message so the locale-default kicks in
    --   again on the next port-CD click.
    -- - Test fires a preview-only announce with a sample dungeon + fake
    --   8m 32s remaining time so the user can see what their template
    --   looks like even when their actual port is ready.
    do
        local f = CreateFrame("Frame", nil, p)
        f:SetSize(p:GetWidth() - CONTENT_PAD * 2, WIDGET_H + 4)

        local resetBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
        resetBtn:SetSize(180, 24)
        resetBtn:SetPoint("LEFT", 0, 0)
        MakeBg(resetBtn, 0.15, 0.15, 0.18, 1)
        local resetTxt = resetBtn:CreateFontString(nil, "OVERLAY")
        ApplyFont(resetTxt, 11)
        resetTxt:SetPoint("CENTER")
        resetTxt:SetTextColor(RGB(ACCENT))
        resetTxt:SetText(LS("KEY_PORTCD_RESET", "Reset to default text"))
        resetBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        resetBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        resetBtn:SetScript("OnClick", function()
            BIT.db.keystoneListPortCdMessage = ""
            if pages[activePage] and pages[activePage].layout then
                pages[activePage].layout()
            end
        end)

        local testBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
        testBtn:SetSize(140, 24)
        testBtn:SetPoint("LEFT", resetBtn, "RIGHT", 8, 0)
        MakeBg(testBtn, 0.15, 0.15, 0.18, 1)
        local testTxt = testBtn:CreateFontString(nil, "OVERLAY")
        ApplyFont(testTxt, 11)
        testTxt:SetPoint("CENTER")
        testTxt:SetTextColor(RGB(ACCENT))
        testTxt:SetText(LS("KEY_PORTCD_TEST", "Test announce"))
        testBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        testBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        testBtn:SetScript("OnClick", function()
            if BIT.KeystoneList and BIT.KeystoneList.PreviewPortCdAnnounce then
                BIT.KeystoneList:PreviewPortCdAnnounce()
            end
        end)

        w[#w+1] = f
    end

    -- ── Post Keystone (shift-click) ───────────────────────────
    -- Shift-clicking a row's icon posts that keystone's info to PARTY
    -- chat. Two configurable templates: one for the user's own
    -- keystone, one for any other party member's. Each template gets
    -- the standard {dungeon} / {abbr} / {level} / {player} substitutions
    -- (the {player} variable resolves to the row OWNER, so own-clicks
    -- substitute your own name and other-clicks the clicked player).
    w[#w+1] = CreateSectionHeader(p, LS("KEY_SEC_POST", "Post Keystone (Shift-Click)"), "sui_kl_post")
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 6)
        w[#w+1] = sp
    end
    w[#w+1] = CreateLabel(p, LS("KEY_POST_DESC",
        "Shift-click any keystone row's icon to post the keystone info to party chat. Posts your own key when shift-clicking your row, or another player's key when shift-clicking theirs."), 11)
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
        w[#w+1] = sp
    end
    w[#w+1] = CreateToggle(p, LS("KEY_POST_ENABLE", "Enable shift-click keystone post"),
        function() return BIT.db.keystoneListPostEnabled ~= false end,
        function(v) BIT.db.keystoneListPostEnabled = v end)

    -- Variable hint with hover tooltips, matching the Port-CD pattern.
    do
        local row = CreateFrame("Frame", nil, p)
        row:SetSize(p:GetWidth() - CONTENT_PAD * 2, WIDGET_H - 4)
        local prefix = row:CreateFontString(nil, "OVERLAY")
        ApplyFont(prefix, 11)
        prefix:SetPoint("LEFT", 0, 0)
        prefix:SetTextColor(RGB(TEXT_DIM))
        prefix:SetText(LS("KEY_PORTCD_VARS_LABEL", "Available variables:"))

        local function makeVarChip(varName, tooltipKey, tooltipDefault)
            local chip = CreateFrame("Button", nil, row)
            local fs = chip:CreateFontString(nil, "OVERLAY")
            ApplyFont(fs, 11)
            fs:SetPoint("LEFT", 0, 0)
            fs:SetTextColor(1, 0.84, 0)
            fs:SetText("{" .. varName .. "}")
            chip:SetSize(math.max(8, fs:GetStringWidth()), 14)
            chip:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
                GameTooltip:SetText("{" .. varName .. "}", 1, 0.84, 0)
                GameTooltip:AddLine(LS(tooltipKey, tooltipDefault), 1, 1, 1, true)
                GameTooltip:Show()
            end)
            chip:SetScript("OnLeave", function() GameTooltip:Hide() end)
            return chip
        end

        local cDungeon = makeVarChip("dungeon", "KEY_PORTCD_VAR_DUNGEON",
            "Full dungeon name (e.g. \"Magisters' Terrace\").")
        cDungeon:SetPoint("LEFT", prefix, "RIGHT", 8, 0)
        local cAbbr = makeVarChip("abbr", "KEY_PORTCD_VAR_ABBR",
            "Short dungeon abbreviation (e.g. \"MT\").")
        cAbbr:SetPoint("LEFT", cDungeon, "RIGHT", 10, 0)
        local cLevel = makeVarChip("level", "KEY_POST_VAR_LEVEL",
            "Keystone level number (e.g. \"18\").")
        cLevel:SetPoint("LEFT", cAbbr, "RIGHT", 10, 0)
        local cPlayer = makeVarChip("player", "KEY_POST_VAR_PLAYER",
            "Keystone owner's display name (your own name when posting your row, the other player's name when posting theirs).")
        cPlayer:SetPoint("LEFT", cLevel, "RIGHT", 10, 0)
        local cResilient = makeVarChip("resilient", "KEY_POST_VAR_RESILIENT",
            "Resilient-keystone marker. Substitutes \"(resilient)\" when the clicked row's keystone has the resilient flag, or empty string otherwise — trailing whitespace is auto-trimmed when empty.")
        cResilient:SetPoint("LEFT", cPlayer, "RIGHT", 10, 0)

        w[#w+1] = row
    end
    do
        local sp = CreateFrame("Frame", nil, p)
        sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 4)
        w[#w+1] = sp
    end

    -- Own-key template
    w[#w+1] = CreateEditBox(p, LS("KEY_POST_OWN_LABEL", "Your own keystone"),
        function()
            local v = BIT.db.keystoneListPostOwnText
            if v == nil or v == "" then
                return LS("KEY_POST_OWN_DEFAULT", "My key: {dungeon} +{level} {resilient}")
            end
            return v
        end,
        function(v)
            v = v or ""
            local default = LS("KEY_POST_OWN_DEFAULT", "My key: {dungeon} +{level} {resilient}")
            if v == default then
                BIT.db.keystoneListPostOwnText = ""
            else
                BIT.db.keystoneListPostOwnText = v
            end
        end,
        340, 2)

    -- Reset + Test buttons for the OWN template
    do
        local f = CreateFrame("Frame", nil, p)
        f:SetSize(p:GetWidth() - CONTENT_PAD * 2, WIDGET_H + 4)

        local resetBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
        resetBtn:SetSize(180, 24)
        resetBtn:SetPoint("LEFT", 0, 0)
        MakeBg(resetBtn, 0.15, 0.15, 0.18, 1)
        local resetTxt = resetBtn:CreateFontString(nil, "OVERLAY")
        ApplyFont(resetTxt, 11)
        resetTxt:SetPoint("CENTER")
        resetTxt:SetTextColor(RGB(ACCENT))
        resetTxt:SetText(LS("KEY_POST_OWN_RESET", "Reset own template"))
        resetBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        resetBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        resetBtn:SetScript("OnClick", function()
            BIT.db.keystoneListPostOwnText = ""
            if pages[activePage] and pages[activePage].layout then
                pages[activePage].layout()
            end
        end)

        local testBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
        testBtn:SetSize(140, 24)
        testBtn:SetPoint("LEFT", resetBtn, "RIGHT", 8, 0)
        MakeBg(testBtn, 0.15, 0.15, 0.18, 1)
        local testTxt = testBtn:CreateFontString(nil, "OVERLAY")
        ApplyFont(testTxt, 11)
        testTxt:SetPoint("CENTER")
        testTxt:SetTextColor(RGB(ACCENT))
        testTxt:SetText(LS("KEY_PORTCD_TEST", "Test announce"))
        testBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        testBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        testBtn:SetScript("OnClick", function()
            if BIT.KeystoneList and BIT.KeystoneList.PreviewKeystonePost then
                BIT.KeystoneList:PreviewKeystonePost(true)
            end
        end)

        w[#w+1] = f
    end

    -- Other-player template
    w[#w+1] = CreateEditBox(p, LS("KEY_POST_OTHER_LABEL", "Another player's keystone"),
        function()
            local v = BIT.db.keystoneListPostOtherText
            if v == nil or v == "" then
                return LS("KEY_POST_OTHER_DEFAULT", "{player}'s key: {dungeon} +{level} {resilient}")
            end
            return v
        end,
        function(v)
            v = v or ""
            local default = LS("KEY_POST_OTHER_DEFAULT", "{player}'s key: {dungeon} +{level} {resilient}")
            if v == default then
                BIT.db.keystoneListPostOtherText = ""
            else
                BIT.db.keystoneListPostOtherText = v
            end
        end,
        340, 2)

    -- Reset + Test buttons for the OTHER template
    do
        local f = CreateFrame("Frame", nil, p)
        f:SetSize(p:GetWidth() - CONTENT_PAD * 2, WIDGET_H + 4)

        local resetBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
        resetBtn:SetSize(180, 24)
        resetBtn:SetPoint("LEFT", 0, 0)
        MakeBg(resetBtn, 0.15, 0.15, 0.18, 1)
        local resetTxt = resetBtn:CreateFontString(nil, "OVERLAY")
        ApplyFont(resetTxt, 11)
        resetTxt:SetPoint("CENTER")
        resetTxt:SetTextColor(RGB(ACCENT))
        resetTxt:SetText(LS("KEY_POST_OTHER_RESET", "Reset other template"))
        resetBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        resetBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        resetBtn:SetScript("OnClick", function()
            BIT.db.keystoneListPostOtherText = ""
            if pages[activePage] and pages[activePage].layout then
                pages[activePage].layout()
            end
        end)

        local testBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
        testBtn:SetSize(140, 24)
        testBtn:SetPoint("LEFT", resetBtn, "RIGHT", 8, 0)
        MakeBg(testBtn, 0.15, 0.15, 0.18, 1)
        local testTxt = testBtn:CreateFontString(nil, "OVERLAY")
        ApplyFont(testTxt, 11)
        testTxt:SetPoint("CENTER")
        testTxt:SetTextColor(RGB(ACCENT))
        testTxt:SetText(LS("KEY_PORTCD_TEST", "Test announce"))
        testBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
        testBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        testBtn:SetScript("OnClick", function()
            if BIT.KeystoneList and BIT.KeystoneList.PreviewKeystonePost then
                BIT.KeystoneList:PreviewKeystonePost(false)
            end
        end)

        w[#w+1] = f
    end

    return w
end


------------------------------------------------------------
-- ── Category: Changelog ──────────────────────────────────
-- Renders BIT.CHANGELOG (Core/Changelog.lua) directly into the page
-- using the native CreateSectionHeader / CreateLabel pattern. Each
-- version becomes its own collapsible section (same look as the
-- "General", "Visibility", "Anchor & Position" sections on every
-- other settings page). Click the header to toggle. Bullet rows
-- are CreateLabel widgets that auto-wrap to the panel width and
-- collapse with the section.
--
-- No extra container, no extra scroll frame — the addon's main
-- settings scroll handles overflow when many versions stack up.
------------------------------------------------------------
-- Hanging-indent bullet row used by the Changelog page. Bullet glyph
-- pins at TOPLEFT; the body FontString sits to the right of the
-- bullet, word-wrapping inside an EXPLICIT SetWidth so subsequent
-- lines align under the first line of body text instead of snapping
-- back to column zero.
--
-- Why explicit SetWidth instead of TOPLEFT+RIGHT anchors: with the
-- anchor pair, FontString:GetStringHeight() can return a stale (1-
-- line) value before the engine has run a layout pass, which made
-- the page's first render under-allocate vertical space and bullets
-- overlapped until the user toggled the section. Setting an explicit
-- width via SetWidth forces the FontString to lay out immediately,
-- so GetStringHeight returns the final multi-line height at
-- construction time and the frame can size itself synchronously.
local function CreateBulletLine(parent, text)
    local panelW       = parent:GetWidth() - CONTENT_PAD * 2
    local bulletIndent = 16    -- left margin before the bullet glyph
    local bulletWidth  = 8     -- approximate width of "•" at 11pt
    local bulletGap    = 6     -- gap between bullet and body text
    local rightPad     = 4     -- right margin inside the frame
    local topPad       = 4     -- top breathing room (also adds gap below header)
    local bodyW        = panelW - bulletIndent - bulletWidth - bulletGap - rightPad

    local f = CreateFrame("Frame", nil, parent)
    f:SetWidth(panelW)

    local bullet = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(bullet, 11)
    bullet:SetPoint("TOPLEFT", bulletIndent, -topPad)
    bullet:SetTextColor(RGB(ACCENT))
    bullet:SetText("•")

    local body = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(body, 11)
    body:SetPoint("TOPLEFT", bullet, "TOPRIGHT", bulletGap, 0)
    body:SetWidth(bodyW)
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")
    body:SetWordWrap(true)
    body:SetNonSpaceWrap(false)
    body:SetTextColor(1, 1, 1)
    body:SetText(text)

    -- Inline height computation. GetStringHeight is reliable here
    -- because body has explicit SetWidth, so word-wrap math is
    -- resolved at construction time (not deferred to OnShow).
    f:SetHeight(math.max(16, body:GetStringHeight() + topPad + 4))

    return f
end

local function BuildChangelog()
    local w = {}
    local p = contentChild

    local cl = BIT.CHANGELOG or {}
    if #cl == 0 then
        w[#w+1] = CreateLabel(p, LS("CHANGELOG_EMPTY",
            "No changelog data available."), 12)
        return w
    end

    -- Default expand/collapse policy: newest version (index 1) opens
    -- automatically so the user sees current changes on first visit.
    -- Older versions start collapsed to keep the page short. After a
    -- user toggles a section manually their preference persists via
    -- BIT.db.sectionExpanded (same DB the native sections use).
    BIT.db.sectionExpanded = BIT.db.sectionExpanded or {}

    -- Collected list of every changelog section header — the accordion
    -- OnClick replacement iterates this to collapse peers whenever a
    -- new section is being expanded.
    local changelogHeaders = {}

    for i, entry in ipairs(cl) do
        local stateKey = "sui_changelog_" .. (entry.version:gsub("%.", "_"))
        if BIT.db.sectionExpanded[stateKey] == nil then
            BIT.db.sectionExpanded[stateKey] = (i == 1)
        end

        local dateStr = entry.date and ("  |cff888888" .. entry.date .. "|r") or ""
        local header  = CreateSectionHeader(p, "v" .. entry.version .. dateStr, stateKey)
        w[#w+1] = header
        changelogHeaders[#changelogHeaders + 1] = header

        -- Spacer between the header's accent underline and the
        -- first bullet — gives the section a comfortable breathing
        -- room instead of the bullet hugging the line. Counts as
        -- a section-child so it collapses with the rest.
        do
            local sp = CreateFrame("Frame", nil, p)
            sp:SetSize(p:GetWidth() - CONTENT_PAD * 2, 6)
            w[#w+1] = sp
        end

        for _, line in ipairs(entry.bullets or {}) do
            w[#w+1] = CreateBulletLine(p, line)
        end
    end

    -- Accordion behaviour: only one section can be open at a time.
    -- Override the native OnClick handler (installed by
    -- CreateSectionHeader) with one that first collapses every peer
    -- and only THEN flips the clicked section on. Clicking an already-
    -- open section closes it without re-opening anything (so the page
    -- can also be fully collapsed).
    for _, header in ipairs(changelogHeaders) do
        header:SetScript("OnClick", function(self)
            local wasExpanded = self._expanded
            for _, h in ipairs(changelogHeaders) do
                h._expanded = false
                if BIT.db.sectionExpanded then
                    BIT.db.sectionExpanded[h._stateKey] = false
                end
                if h._arrowFs then h._arrowFs:SetText(">") end
            end
            if not wasExpanded then
                self._expanded = true
                if BIT.db.sectionExpanded then
                    BIT.db.sectionExpanded[self._stateKey] = true
                end
                if self._arrowFs then self._arrowFs:SetText("v") end
            end
            if pages[activePage] and pages[activePage].refresh then
                pages[activePage].refresh()
            end
            if pages[activePage] and pages[activePage].layout then
                pages[activePage].layout()
            end
        end)
    end

    -- Enforce single-section-open invariant on first build too. If
    -- multiple versions ended up flagged expanded (e.g. user toggled
    -- several open under the previous non-accordion behaviour), keep
    -- only the first and collapse the rest.
    local firstOpen = nil
    for _, h in ipairs(changelogHeaders) do
        if h._expanded then
            if firstOpen then
                h._expanded = false
                if BIT.db.sectionExpanded then
                    BIT.db.sectionExpanded[h._stateKey] = false
                end
                if h._arrowFs then h._arrowFs:SetText(">") end
            else
                firstOpen = h
            end
        end
    end

    return w
end

------------------------------------------------------------
-- ── Category: Profiles ───────────────────────────────────
------------------------------------------------------------
local function BuildProfiles()
    local w = {}
    local p = contentChild

    ----------------------------------------------------------------
    -- Active Profile
    --
    -- Status pill + selector + 3x2 button grid. ASCII-only labels so
    -- nothing renders as a fallback rectangle in the default WoW font.
    -- Buttons are color-coded by purpose and share a uniform width so
    -- the row reads as a single block instead of a ragged toolbar.
    ----------------------------------------------------------------
    w[#w+1] = CreateSectionHeader(p, LS("SEC_ACTIVE_PROFILE", "Active Profile"), "sui_prof_active")

    -- Status row: vertical accent strip (texture, no unicode) acts as
    -- a "live indicator" left of the profile name. The section header
    -- above already says "Active Profile", so the word isn't repeated.
    do
        local f = CreateFrame("Frame", nil, p)
        f:SetSize(p:GetWidth() - CONTENT_PAD * 2, 22)

        local strip = f:CreateTexture(nil, "ARTWORK")
        strip:SetSize(3, 16)
        strip:SetPoint("LEFT", 1, 0)
        strip:SetColorTexture(RGB(ACCENT))

        local active = f:CreateFontString(nil, "OVERLAY")
        ApplyFont(active, 14, "OUTLINE")
        active:SetPoint("LEFT", strip, "RIGHT", 8, 0)
        active:SetTextColor(RGB(TEXT))

        local function refreshActive()
            active:SetText(BIT.Profiles and BIT.Profiles:GetActiveName() or "Default")
        end
        f._update = refreshActive
        refreshActive()

        w[#w+1] = f
    end

    -- Selector dropdown (lists every saved profile). The options array
    -- is *mutated in place* by `refillOpts` because CreateDropdown
    -- captures it by reference — refilling rebuilds the displayed list
    -- without needing to recreate the widget.
    local function refillOpts(opts, includeNone)
        wipe(opts)
        if includeNone then
            opts[#opts + 1] = { value = "(none)", label = "|cff888888" .. LS("PROFILE_SPEC_NONE_OPT", "(none)") .. "|r" }
        end
        if BIT.Profiles and BIT.Profiles.GetNames then
            for _, n in ipairs(BIT.Profiles:GetNames()) do
                opts[#opts + 1] = { value = n, label = n }
            end
        else
            opts[#opts + 1] = { value = "Default", label = "Default" }
        end
        return opts
    end

    -- Every profile-listing dropdown on this page registers itself here
    -- so a single call refreshes the lot when profiles change.
    -- We wrap each dropdown's existing `_update` (set by CreateDropdown
    -- to its internal UpdateText) so that the standard page-refresh
    -- path automatically refills options too — this matters for the
    -- Import popup path, where the import calls NotifyAllChanged →
    -- RefreshActivePage → page.refresh → every widget's _update.
    local profileDropdowns = {}
    local function registerProfileDropdown(dd, refillFn)
        dd._refillOpts = refillFn
        local origUpdate = dd._update
        dd._update = function()
            refillFn()
            if origUpdate then origUpdate() end
        end
        profileDropdowns[#profileDropdowns + 1] = dd
    end
    local function refreshProfileDropdowns()
        for _, dd in ipairs(profileDropdowns) do
            if dd._update then dd._update() end
        end
    end

    local function refreshActiveDropdown()
        refreshProfileDropdowns()
        if pages and pages[activePage] and pages[activePage].refresh then
            pages[activePage].refresh()
        end
        if pages and pages[activePage] and pages[activePage].layout then
            pages[activePage].layout()
        end
    end

    do
        local activeOpts = refillOpts({}, false)
        local activeDD = CreateDropdown(p, LS("DD_SWITCH_PROFILE", "Switch Profile"),
            activeOpts,
            function() return BIT.Profiles and BIT.Profiles:GetActiveName() or "Default" end,
            function(v)
                if BIT.Profiles and BIT.Profiles.Switch then
                    BIT.Profiles:Switch(v)
                end
                refreshActiveDropdown()
            end)
        registerProfileDropdown(activeDD, function() refillOpts(activeOpts, false) end)
        w[#w + 1] = activeDD
    end

    -- Action buttons in a uniform 3x2 grid. Equal-width cells make
    -- the row read as a single block rather than a ragged toolbar.
    do
        local f = CreateFrame("Frame", nil, p)
        local containerW = p:GetWidth() - CONTENT_PAD * 2
        local BTN_GAP    = 6
        local BTN_ROWGAP = 6
        local BTN_H      = 26
        local BTN_W      = math.floor((containerW - BTN_GAP * 2) / 3)
        f:SetSize(containerW, BTN_H * 2 + BTN_ROWGAP)

        -- BIT-styled button helper. Color tuple is the background;
        -- the text uses the same hue but at higher value so each
        -- action is visually distinct without being shouty.
        local function makeBtn(label, bg, fg, w_, h_, onClick)
            local btn = CreateFrame("Button", nil, f, "BackdropTemplate")
            btn:SetSize(w_ or 84, h_ or 24)
            MakeBg(btn, bg[1], bg[2], bg[3], 1)
            local txt = btn:CreateFontString(nil, "OVERLAY")
            ApplyFont(txt, 11, "OUTLINE")
            txt:SetPoint("CENTER")
            txt:SetTextColor(fg[1], fg[2], fg[3])
            txt:SetText(label)
            btn:SetScript("OnEnter", function(self)
                self:SetBackdropBorderColor(fg[1], fg[2], fg[3])
            end)
            btn:SetScript("OnLeave", function(self)
                self:SetBackdropBorderColor(RGB(BORDER))
            end)
            btn:SetScript("OnClick", onClick)
            btn._txt = txt
            btn._fg  = fg
            return btn
        end

        -- Yes/Cancel confirmation modal. Use for destructive actions
        -- (Delete, Reset) so a fat-finger click can't wipe a profile.
        local function ConfirmDialog(title, body, onConfirm)
            if _G["BIT_ProfileConfirmPopup"] then _G["BIT_ProfileConfirmPopup"]:Hide() end
            local pop = CreateFrame("Frame", "BIT_ProfileConfirmPopup", UIParent, "BackdropTemplate")
            pop:SetSize(380, 140) pop:SetPoint("CENTER")
            pop:SetFrameStrata("DIALOG") pop:SetFrameLevel(310)
            pop:SetBackdrop({
                bgFile   = "Interface\\BUTTONS\\WHITE8X8",
                edgeFile = "Interface\\BUTTONS\\WHITE8X8",
                edgeSize = 1,
                insets   = { left = 1, right = 1, top = 1, bottom = 1 },
            })
            pop:SetBackdropColor(0.10, 0.10, 0.12, 1)
            pop:SetBackdropBorderColor(RGB(BORDER))
            pop:EnableMouse(true)

            local titleFs = pop:CreateFontString(nil, "OVERLAY")
            ApplyFont(titleFs, 13, "OUTLINE")
            titleFs:SetPoint("TOPLEFT", 12, -12)
            titleFs:SetTextColor(1, 0.85, 0.4)
            titleFs:SetText(title)

            local bodyFs = pop:CreateFontString(nil, "OVERLAY")
            ApplyFont(bodyFs, 11)
            bodyFs:SetPoint("TOPLEFT", 12, -36)
            bodyFs:SetPoint("RIGHT", -12, 0)
            bodyFs:SetJustifyH("LEFT")
            bodyFs:SetJustifyV("TOP")
            bodyFs:SetTextColor(RGB(TEXT))
            bodyFs:SetText(body)
            bodyFs:SetWordWrap(true)

            local confirmBtn = CreateFrame("Button", nil, pop, "BackdropTemplate")
            confirmBtn:SetSize(100, 24) confirmBtn:SetPoint("BOTTOMRIGHT", -12, 12)
            MakeBg(confirmBtn, 0.20, 0.08, 0.08, 1)
            local cT = confirmBtn:CreateFontString(nil, "OVERLAY") ApplyFont(cT, 11)
            cT:SetPoint("CENTER") cT:SetTextColor(1, 0.6, 0.6) cT:SetText(LS("DLG_CONFIRM", "Confirm"))
            confirmBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(1, 0.4, 0.4) end)
            confirmBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
            confirmBtn:SetScript("OnClick", function()
                pop:Hide()
                if onConfirm then onConfirm() end
            end)

            local cancelBtn = CreateFrame("Button", nil, pop, "BackdropTemplate")
            cancelBtn:SetSize(100, 24) cancelBtn:SetPoint("RIGHT", confirmBtn, "LEFT", -6, 0)
            MakeBg(cancelBtn, 0.15, 0.15, 0.18, 1)
            local caT = cancelBtn:CreateFontString(nil, "OVERLAY") ApplyFont(caT, 11)
            caT:SetPoint("CENTER") caT:SetTextColor(RGB(ACCENT)) caT:SetText(LS("DLG_CANCEL", "Cancel"))
            cancelBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
            cancelBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
            cancelBtn:SetScript("OnClick", function() pop:Hide() end)

            pop:Show()
        end

        local function PromptInput(title, default, onAccept)
            if _G["BIT_ProfilePromptPopup"] then _G["BIT_ProfilePromptPopup"]:Hide() end
            local pop = CreateFrame("Frame", "BIT_ProfilePromptPopup", UIParent, "BackdropTemplate")
            pop:SetSize(360, 130) pop:SetPoint("CENTER")
            pop:SetFrameStrata("DIALOG") pop:SetFrameLevel(300)
            pop:SetBackdrop({
                bgFile   = "Interface\\BUTTONS\\WHITE8X8",
                edgeFile = "Interface\\BUTTONS\\WHITE8X8",
                edgeSize = 1,
                insets   = { left = 1, right = 1, top = 1, bottom = 1 },
            })
            pop:SetBackdropColor(0.10, 0.10, 0.12, 1)
            pop:SetBackdropBorderColor(RGB(BORDER))
            pop:EnableMouse(true)

            local lbl = pop:CreateFontString(nil, "OVERLAY")
            ApplyFont(lbl, 12) lbl:SetPoint("TOPLEFT", 12, -12)
            lbl:SetTextColor(RGB(TEXT)) lbl:SetText(title)

            local eb = CreateFrame("EditBox", nil, pop, "BackdropTemplate")
            eb:SetSize(336, 24) eb:SetPoint("TOPLEFT", 12, -36)
            MakeBg(eb, RGB(WIDGET_BG)) ApplyFont(eb, 11)
            eb:SetTextColor(RGB(TEXT)) eb:SetTextInsets(6, 6, 0, 0)
            eb:SetAutoFocus(true) eb:SetText(default or "") eb:HighlightText()

            local ok = CreateFrame("Button", nil, pop, "BackdropTemplate")
            ok:SetSize(84, 24) ok:SetPoint("BOTTOMRIGHT", -12, 12)
            MakeBg(ok, 0.12, 0.20, 0.12, 1)
            local okT = ok:CreateFontString(nil, "OVERLAY") ApplyFont(okT, 11)
            okT:SetPoint("CENTER") okT:SetTextColor(0.5, 1, 0.5) okT:SetText(LS("DLG_OK", "OK"))
            local function accept()
                local v = eb:GetText()
                pop:Hide()
                if onAccept and v then onAccept(v) end
            end
            ok:SetScript("OnEnter",  function(self) self:SetBackdropBorderColor(0.4, 1, 0.4) end)
            ok:SetScript("OnLeave",  function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
            ok:SetScript("OnClick",  accept)
            eb:SetScript("OnEnterPressed", accept)

            local cancel = CreateFrame("Button", nil, pop, "BackdropTemplate")
            cancel:SetSize(84, 24) cancel:SetPoint("RIGHT", ok, "LEFT", -6, 0)
            MakeBg(cancel, 0.18, 0.10, 0.10, 1)
            local cT = cancel:CreateFontString(nil, "OVERLAY") ApplyFont(cT, 11)
            cT:SetPoint("CENTER") cT:SetTextColor(1, 0.6, 0.6) cT:SetText(LS("DLG_CANCEL", "Cancel"))
            cancel:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(1, 0.4, 0.4) end)
            cancel:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
            cancel:SetScript("OnClick", function() pop:Hide() end)
            eb:SetScript("OnEscapePressed", function() pop:Hide() end)
            pop:Show()
        end

        -- Row 1: constructive / edit operations
        local newBtn = makeBtn(LS("PROFILE_NEW", "New"), { 0.10, 0.20, 0.10 }, { 0.5, 1, 0.5 }, BTN_W, BTN_H, function()
            PromptInput(LS("PROMPT_NEW_NAME", "New profile name:"), "", function(name)
                name = name and name:gsub("^%s+",""):gsub("%s+$","") or ""
                if name == "" then return end
                local ok, msg = BIT.Profiles:Create(name)
                if ok then
                    BIT.Profiles:Switch(name); refreshActiveDropdown()
                elseif msg then print("|cff0091edBIT|r " .. msg) end
            end)
        end)
        newBtn:SetPoint("TOPLEFT", 0, 0)

        local renameBtn = makeBtn(LS("PROFILE_RENAME", "Rename"), { 0.20, 0.18, 0.08 }, { 1, 0.85, 0.4 }, BTN_W, BTN_H, function()
            local cur = BIT.Profiles:GetActiveName()
            if cur == "Default" then return end
            PromptInput(string.format(LS("PROMPT_RENAME", "Rename '%s' to:"), cur), cur, function(name)
                name = name and name:gsub("^%s+",""):gsub("%s+$","") or ""
                if name == "" or name == cur then return end
                local ok, msg = BIT.Profiles:Rename(cur, name)
                if ok then refreshActiveDropdown()
                elseif msg then print("|cff0091edBIT|r " .. msg) end
            end)
        end)
        renameBtn:SetPoint("LEFT", newBtn, "RIGHT", BTN_GAP, 0)

        local cloneBtn = makeBtn(LS("PROFILE_CLONE", "Clone"), { 0.08, 0.16, 0.20 }, { 0.5, 0.85, 1 }, BTN_W, BTN_H, function()
            local cur = BIT.Profiles:GetActiveName()
            PromptInput(string.format(LS("PROMPT_CLONE", "Clone '%s' as:"), cur), cur .. " (copy)", function(name)
                name = name and name:gsub("^%s+",""):gsub("%s+$","") or ""
                if name == "" then return end
                local ok, msg = BIT.Profiles:Clone(cur, name)
                if ok then
                    BIT.Profiles:Switch(name); refreshActiveDropdown()
                elseif msg then print("|cff0091edBIT|r " .. msg) end
            end)
        end)
        cloneBtn:SetPoint("LEFT", renameBtn, "RIGHT", BTN_GAP, 0)

        -- Row 2: state + sharing. Delete sits bottom-right (modern
        -- convention for "danger" actions: corner-most, hardest to
        -- reach by accident).
        local resetBtn = makeBtn(LS("PROFILE_RESET", "Reset"), { 0.20, 0.13, 0.08 }, { 1, 0.7, 0.4 }, BTN_W, BTN_H, function()
            local cur = BIT.Profiles:GetActiveName()
            ConfirmDialog(
                LS("DLG_RST_TITLE", "Reset profile?"),
                string.format(LS("DLG_RST_BODY",
                    "This restores |cffffd700%s|r to the addon defaults - "
                    .. "every setting on this profile will be reverted. "
                    .. "This cannot be undone."), cur),
                function()
                    BIT.Profiles:Reset(cur); refreshActiveDropdown()
                end)
        end)
        resetBtn:SetPoint("TOPLEFT", newBtn, "BOTTOMLEFT", 0, -BTN_ROWGAP)

        local imexBtn = makeBtn(LS("PROFILE_IMEX", "Import / Export"), { 0.10, 0.10, 0.20 }, ACCENT, BTN_W, BTN_H, function()
            if BIT.SettingsUI and BIT.SettingsUI.ShowImportExportPopup then
                BIT.SettingsUI:ShowImportExportPopup()
            end
        end)
        imexBtn:SetPoint("LEFT", resetBtn, "RIGHT", BTN_GAP, 0)

        local deleteBtn = makeBtn(LS("PROFILE_DEL", "Delete"), { 0.20, 0.08, 0.08 }, { 1, 0.5, 0.5 }, BTN_W, BTN_H, function()
            local cur = BIT.Profiles:GetActiveName()
            if cur == "Default" then return end
            ConfirmDialog(
                LS("DLG_DEL_TITLE", "Delete profile?"),
                string.format(LS("DLG_DEL_BODY",
                    "This permanently deletes the profile |cffffd700%s|r "
                    .. "and removes it from any spec assignments. "
                    .. "The Default profile becomes active. "
                    .. "This cannot be undone."), cur),
                function()
                    local ok, msg = BIT.Profiles:Delete(cur)
                    if ok then refreshActiveDropdown()
                    elseif msg then print("|cff0091edBIT|r " .. msg) end
                end)
        end)
        deleteBtn:SetPoint("LEFT", imexBtn, "RIGHT", BTN_GAP, 0)

        -- Enable / disable Rename + Delete based on whether the active
        -- profile is "Default" (which is protected).
        local function refreshButtonState()
            local cur = BIT.Profiles:GetActiveName()
            local atDefault = cur == "Default"
            local function setEnabled(btn, enabled)
                if enabled then
                    btn:Enable()
                    btn._txt:SetTextColor(btn._fg[1], btn._fg[2], btn._fg[3])
                else
                    btn:Disable()
                    btn._txt:SetTextColor(0.4, 0.4, 0.4)
                end
            end
            setEnabled(renameBtn, not atDefault)
            setEnabled(deleteBtn, not atDefault)
        end
        f._update = refreshButtonState
        refreshButtonState()

        w[#w+1] = f
    end

    ----------------------------------------------------------------
    -- Auto-Switch on spec change
    --
    -- Each spec gets one row that IS a real CreateDropdown widget
    -- (so LayoutWidgets places it correctly). The spec icon is
    -- baked into the dropdown's left-hand label via WoW's inline
    -- |T...|t texture syntax — same row, no separate frame needed.
    ----------------------------------------------------------------
    w[#w+1] = CreateSectionHeader(p, LS("SEC_AUTO_SWITCH", "Auto-Switch"), "sui_prof_autoswitch")
    w[#w+1] = CreateLabel(p,
        "|cff999999" .. LS("PROFILE_AUTOSWITCH_HINT",
            "Pick a profile per spec - switches automatically when you change specialization.") .. "|r", 11)
    w[#w+1] = CreateLabel(p,
        "|cff666666" .. LS("PROFILE_AUTOSWITCH_HINT2",
            "Every class is listed so you can pre-configure spec mappings for your alts without logging in.") .. "|r", 11)

    -- Build the full class → specs map from the Blizzard API. Returns an
    -- ordered list (player's own class first, rest alphabetical by
    -- localized class name) so the section the user usually edits is
    -- visible without scrolling.
    local function GetAllClassesWithSpecs()
        local out = {}
        local seen = {}
        local _, playerClassFile = UnitClass("player")

        local function addClass(classID)
            if not classID then return end
            local localized, classFile = GetClassInfo(classID)
            if not classFile or seen[classFile] then return end
            local n = (GetNumSpecializationsForClassID and GetNumSpecializationsForClassID(classID)) or 0
            local specs = {}
            for i = 1, n do
                local sid, sname, _, sicon = GetSpecializationInfoForClassID(classID, i)
                if sid and sname and sname ~= "" then
                    specs[#specs+1] = { id = sid, name = sname, icon = sicon }
                end
            end
            if #specs > 0 then
                out[#out+1] = { class = classFile, name = localized, specs = specs }
                seen[classFile] = true
            end
        end

        -- Player's own class first.
        local _, _, playerClassID = UnitClass("player")
        if playerClassID then addClass(playerClassID) end

        -- Then every other class, alphabetised by localized name.
        local rest = {}
        local total = (GetNumClasses and GetNumClasses()) or 13
        for cid = 1, total do
            if not seen[(GetClassInfo and select(2, GetClassInfo(cid))) or ""] then
                local localized, classFile = GetClassInfo(cid)
                if classFile then
                    rest[#rest+1] = { id = cid, localized = localized or classFile }
                end
            end
        end
        table.sort(rest, function(a, b) return (a.localized or "") < (b.localized or "") end)
        for _, e in ipairs(rest) do addClass(e.id) end

        return out
    end

    local classBlocks = GetAllClassesWithSpecs()
    if #classBlocks == 0 then
        w[#w+1] = CreateLabel(p,
            "|cff888888" .. LS("PROFILE_NO_SPEC_DATA",
                "No specialization data available yet - log in fully to populate.") .. "|r", 11)
    else
        -- Per-class expanded state. Player's own class starts open, the
        -- rest start collapsed so the section isn't a wall of dropdowns.
        -- The page is cached after first build, so this table survives
        -- between page switches without polluting the saved profile.
        local classExpanded = {}
        local _, playerClassFile = UnitClass("player")

        for _, cb in ipairs(classBlocks) do
            local clsFile = cb.class
            classExpanded[clsFile] = (clsFile == playerClassFile)

            -- Clickable class header. Holds an expand arrow on the left
            -- (ASCII "v"/">"), then the class name in class colour.
            local header = CreateFrame("Button", nil, p)
            header:SetSize(p:GetWidth() - CONTENT_PAD * 2, 22)

            local arrowFs = header:CreateFontString(nil, "OVERLAY")
            ApplyFont(arrowFs, 10)
            arrowFs:SetPoint("LEFT", 0, 0)
            arrowFs:SetTextColor(RGB(ACCENT))

            local nameFs = header:CreateFontString(nil, "OVERLAY")
            ApplyFont(nameFs, 12, "OUTLINE")
            nameFs:SetPoint("LEFT", 16, 0)
            local cc = (BIT.CLASS_COLORS and BIT.CLASS_COLORS[clsFile]) or { 0.8, 0.8, 0.8 }
            nameFs:SetTextColor(cc[1], cc[2], cc[3])
            nameFs:SetText(cb.name)

            -- Subtle hover line under the header so it reads as a button
            local hoverLine = header:CreateTexture(nil, "BACKGROUND")
            hoverLine:SetHeight(1)
            hoverLine:SetPoint("BOTTOMLEFT", 0, 0)
            hoverLine:SetPoint("BOTTOMRIGHT", 0, 0)
            hoverLine:SetColorTexture(cc[1], cc[2], cc[3], 0.25)

            local function syncArrow()
                arrowFs:SetText(classExpanded[clsFile] and "v" or ">")
            end
            syncArrow()

            header:SetScript("OnEnter", function()
                hoverLine:SetColorTexture(cc[1], cc[2], cc[3], 0.6)
            end)
            header:SetScript("OnLeave", function()
                hoverLine:SetColorTexture(cc[1], cc[2], cc[3], 0.25)
            end)
            header:SetScript("OnClick", function()
                classExpanded[clsFile] = not classExpanded[clsFile]
                syncArrow()
                -- Page-level refresh runs every widget's _update so the
                -- spec dropdowns flip their visibility, then layout
                -- repositions everything skipping the hidden ones.
                if pages[activePage] and pages[activePage].refresh then
                    pages[activePage].refresh()
                end
                if pages[activePage] and pages[activePage].layout then
                    pages[activePage].layout()
                end
            end)

            w[#w+1] = header

            for _, sp in ipairs(cb.specs) do
                -- Inline spec icon + name as the dropdown label
                local label
                if sp.icon then
                    label = string.format("|T%s:18:18:0:0:64:64:5:59:5:59|t  %s", sp.icon, sp.name)
                else
                    label = sp.name
                end
                -- Each spec dropdown gets its own mutable options table so
                -- new profiles appear without recreating the widget.
                local specOpts = refillOpts({}, true)
                local dd = CreateDropdown(p, label,
                    specOpts,
                    function()
                        local cur = BIT.Profiles and BIT.Profiles:GetSpecProfile(sp.id)
                        return cur or "(none)"
                    end,
                    function(v)
                        if BIT.Profiles and BIT.Profiles.SetSpecProfile then
                            BIT.Profiles:SetSpecProfile(sp.id, v == "(none)" and nil or v)
                        end
                    end)
                registerProfileDropdown(dd, function() refillOpts(specOpts, true) end)

                -- Layout-driven visibility: when the class is collapsed,
                -- the dropdown hides itself and LayoutWidgets skips its
                -- slot entirely (see `_dynamic` handling in LayoutWidgets).
                dd._dynamic = true
                local origUpdate = dd._update
                dd._update = function()
                    if classExpanded[clsFile] then
                        dd:Show()
                    else
                        dd:Hide()
                    end
                    if origUpdate then origUpdate() end
                end

                w[#w+1] = dd
            end
        end
    end

    return w
end

------------------------------------------------------------
-- ── ShowPage ─────────────────────────────────────────────
------------------------------------------------------------
-- Forward-declared so ShowPage can hide leftover banners when
-- navigating away from search results. Actual table init lives
-- in the Search section further down; the upvalue is shared.
local _pageBanners = {}

function BIT.SettingsUI:ShowPage(name)
    if not pages[name] then return end

    -- Clear search field when navigating to a real page so the search
    -- UI state stays consistent with what's displayed.
    if mainFrame and mainFrame._searchEditBox then
        mainFrame._searchEditBox:SetText("")
        if mainFrame._searchHint then mainFrame._searchHint:Show() end
    end

    -- hide old widgets — handle both real pages and search-mode results
    if activePage == "_search" then
        -- Hide every widget that may currently be shown across all pages
        -- (search results pull from multiple pages and a normal-page
        -- show wouldn't otherwise clean those up). Also hide the
        -- page-context banners we may have inserted between groups.
        for _, p in pairs(pages) do
            if p.widgets then
                for _, w in ipairs(p.widgets) do w:Hide() end
            end
        end
        for _, b in pairs(_pageBanners) do b:Hide() end
    elseif activePage and pages[activePage] and pages[activePage].widgets then
        for _, w in ipairs(pages[activePage].widgets) do w:Hide() end
    end

    -- update sidebar
    for k, btn in pairs(sidebarBtns) do
        if k == name then
            btn._indicator:Show()
            btn._bgHl:Show()
            btn._text:SetTextColor(RGB(TEXT))
        else
            btn._indicator:Hide()
            btn._bgHl:Hide()
            btn._text:SetTextColor(RGB(TEXT_DIM))
        end
    end

    activePage = name
    local page = pages[name]

    -- build on first show
    if not page.widgets then
        page.widgets = page.build()
    end

    -- layout
    page.layout = function() LayoutWidgets(page.widgets) end
    page.refresh = function()
        for _, w in ipairs(page.widgets) do
            if w._update then w._update() end
        end
    end

    -- Run every widget's `_update` callback now that `page.layout` exists.
    -- This is essential for `_dynamic` widgets whose visibility depends on
    -- other settings (e.g. mode-scoped options in the Interrupts page):
    -- their `_update` closures call `page.layout()` internally, and that
    -- closure only has a layout to invoke after this function is assigned.
    page.refresh()
    page.layout()

    contentScroll._wheelGliding = false   -- cancel any in-flight wheel glide
    contentScroll:SetVerticalScroll(0)
end

------------------------------------------------------------
-- ── Search ───────────────────────────────────────────────
------------------------------------------------------------
-- Lazy search index. First call builds widget lists for every page so
-- the search has labels to match against. Subsequent calls reuse the
-- cached index. The index is invalidated implicitly: a page whose
-- widgets table is nil-ed out (none currently do this) would simply
-- be re-built next time around. We don't bother with explicit
-- invalidation because page builds are idempotent for our purposes.
local _searchIndex = nil

-- Page-context banners shown above each group of search results. They
-- tell the user WHICH module's settings they're currently editing —
-- without them, identical section names (e.g. "Visibility" or
-- "General") across the Interrupts / Party CDs / PI Caller pages
-- would be indistinguishable in a flat result list. One banner is
-- created per page on demand and cached for reuse. The `_pageBanners`
-- table itself is forward-declared above ShowPage (the only other
-- function that touches it) so both share the same upvalue.
local function GetPageBanner(pageName)
    if _pageBanners[pageName] then return _pageBanners[pageName] end
    -- Button (not plain Frame) so the banner is clickable — clicking it
    -- jumps straight into that module's page, clearing the search.
    local f = CreateFrame("Button", nil, contentChild)
    f:SetSize(contentChild:GetWidth() - CONTENT_PAD * 2, 20)

    local lbl = f:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, 12, "OUTLINE")
    lbl:SetPoint("LEFT", 0, 1)
    lbl:SetTextColor(RGB(ACCENT))
    lbl:SetText(string.upper(pageName))

    -- Accent underline that exactly spans the label width — anchored to
    -- the FontString's own edges (the label auto-sizes to its text since
    -- it's only pinned at LEFT), so the line grows / shrinks with the
    -- page name instead of using a fixed width.
    local underline = f:CreateTexture(nil, "ARTWORK")
    underline:SetHeight(1)
    underline:SetPoint("TOPLEFT",  lbl, "BOTTOMLEFT",  0, -1)
    underline:SetPoint("TOPRIGHT", lbl, "BOTTOMRIGHT", 0, -1)
    underline:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.8)

    -- Hover: brighten the label + underline so it's discoverable that
    -- the banner is an interactive shortcut.
    f:SetScript("OnEnter", function()
        lbl:SetTextColor(1, 1, 1)
        underline:SetColorTexture(1, 1, 1, 0.9)
    end)
    f:SetScript("OnLeave", function()
        lbl:SetTextColor(RGB(ACCENT))
        underline:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.8)
    end)
    f:SetScript("OnClick", function()
        BIT.SettingsUI:ShowPage(pageName)
    end)

    f._isPageBanner = true
    f:Hide()
    _pageBanners[pageName] = f
    return f
end
local function BuildSearchIndex()
    if _searchIndex then return _searchIndex end
    _searchIndex = {}
    for _, pageName in ipairs(_pageOrder) do
        local page = pages[pageName]
        if page then
            if not page.widgets then
                page.widgets = page.build()
                for _, w in ipairs(page.widgets) do w:Hide() end
            end
            local currentSection = nil
            for _, w in ipairs(page.widgets) do
                if w._searchKind == "section" then
                    currentSection = w
                    _searchIndex[#_searchIndex + 1] = {
                        widget = w, section = w, page = pageName,
                        label = w._searchLabel or "", isSection = true,
                    }
                elseif w._searchLabel then
                    _searchIndex[#_searchIndex + 1] = {
                        widget = w, section = currentSection, page = pageName,
                        label = w._searchLabel or "", isSection = false,
                    }
                end
            end
        end
    end
    return _searchIndex
end

-- ApplySearch(query, previousPage)
--   query        : text typed in the search EditBox (already case-checked
--                  inside; whitespace not stripped — the user might
--                  legitimately search for "Bar Width" with a space).
--   previousPage : the page that was active before the user started
--                  searching, used for the "empty input restores the
--                  prior page" UX path.
--
-- Matching rules:
--   • Substring match on widget label OR section header label (case-insensitive).
--   • When a section HEADER matches: show that section + every widget under it
--     (so typing the section name brings up the whole group).
--   • When a child widget matches but the section name does not: show the
--     section header (for context) + only the matched widget(s) of that section.
--   • Sections force-expand in search results — collapsed sections wouldn't
--     show their children otherwise.
function BIT.SettingsUI:ApplySearch(query, previousPage)
    if query == nil or query == "" then
        -- Restore the page the user came from (or General as a safe default).
        if activePage == "_search" then
            self:ShowPage(previousPage or "General")
        end
        return
    end

    -- Hide whatever's currently on screen (widgets from previous page OR
    -- previous search-result set, which can span multiple pages).
    if activePage == "_search" then
        for _, p in pairs(pages) do
            if p.widgets then
                for _, w in ipairs(p.widgets) do w:Hide() end
            end
        end
    elseif activePage and pages[activePage] and pages[activePage].widgets then
        for _, w in ipairs(pages[activePage].widgets) do w:Hide() end
    end
    activePage = "_search"
    -- Note: sidebar selection stays on previousPage's button — when search
    -- is dismissed (empty input) we restore that page, so showing it as
    -- the selected tab keeps the UX consistent.

    local index = BuildSearchIndex()
    local lq = string.lower(query)

    -- Two-pass: (1) decide which sections + widgets match, (2) emit in
    -- original index order so the result list mirrors the natural page
    -- layout.
    local sectionShowAll  = {}   -- section_widget → true if header matched
    local sectionChildren = {}   -- section_widget → { widget = true, ... }
    local noSection       = {}   -- widget → true (for orphan widgets w/o a section)

    for _, e in ipairs(index) do
        if string.find(string.lower(e.label), lq, 1, true) then
            if e.isSection then
                sectionShowAll[e.widget] = true
                sectionChildren[e.widget] = sectionChildren[e.widget] or {}
            else
                if e.section then
                    sectionChildren[e.section] = sectionChildren[e.section] or {}
                    sectionChildren[e.section][e.widget] = true
                else
                    noSection[e.widget] = true
                end
            end
        end
    end

    local displayList = {}
    local lastSectionEmitted = nil
    local currentPage = nil
    -- Helper: ensure a page-context banner precedes content from a
    -- newly-encountered page. No-op when the page hasn't changed.
    local function emitPageBannerIfNeeded(pageName)
        if pageName and pageName ~= currentPage then
            displayList[#displayList + 1] = GetPageBanner(pageName)
            currentPage = pageName
        end
    end

    for _, e in ipairs(index) do
        if e.isSection then
            if sectionChildren[e.widget] then
                emitPageBannerIfNeeded(e.page)
                displayList[#displayList + 1] = e.widget
                lastSectionEmitted = e.widget
            else
                lastSectionEmitted = nil
            end
        else
            if e.section and sectionChildren[e.section] then
                if sectionShowAll[e.section]
                   or sectionChildren[e.section][e.widget] then
                    emitPageBannerIfNeeded(e.page)
                    displayList[#displayList + 1] = e.widget
                end
            elseif not e.section and noSection[e.widget] then
                emitPageBannerIfNeeded(e.page)
                displayList[#displayList + 1] = e.widget
            end
        end
    end

    -- Hide all page banners first so leftover banners from a previous
    -- search aren't still visible alongside the new results. The ones
    -- referenced by displayList get re-shown by LayoutWidgets below.
    for _, b in pairs(_pageBanners) do b:Hide() end

    -- Force-expand any section we're about to display — a collapsed
    -- section would skip rendering its children in LayoutWidgets and
    -- defeat the search match.
    for sec, _ in pairs(sectionChildren) do
        if not sec._expanded then
            sec._expanded = true
            if sec._arrowFs then sec._arrowFs:SetText("v") end
        end
    end

    -- Refresh widget visuals so they show current saved values.
    for _, w in ipairs(displayList) do
        if w._update then pcall(w._update) end
    end

    LayoutWidgets(displayList)
    if contentScroll and contentScroll.SetVerticalScroll then
        contentScroll._wheelGliding = false
        contentScroll:SetVerticalScroll(0)
    end
end

------------------------------------------------------------
-- ── Public API ───────────────────────────────────────────
------------------------------------------------------------
-- Re-runs the active page's _update callbacks and re-layouts. Called
-- from BIT.Profiles after a profile switch so every widget re-reads
-- its getter (which now points at the new profile's saved values).
function BIT.SettingsUI:RefreshActivePage()
    if activePage and pages and pages[activePage] then
        local pg = pages[activePage]
        if pg.refresh then pg.refresh() end
        if pg.layout  then pg.layout()  end
    end
end

-- Modal popup with two stacked sections:
--   • Export Profile — read-only output of the current profile
--   • Import Profile — name + encoded string + Import button
-- Mirrors the screenshot mockup and replaces the previous in-page
-- import / export controls.
function BIT.SettingsUI:ShowImportExportPopup()
    if _G["BIT_ImportExportPopup"] then
        local existing = _G["BIT_ImportExportPopup"]
        -- Refresh the cached widgets so the export string reflects the
        -- *current* state of profiles + spec assignments, the name
        -- field gets a fresh "Default (N)" suggestion, and any leftover
        -- status / typed string from a previous session is cleared.
        if existing._refresh then existing._refresh() end
        existing:Show()
        return
    end
    local pop = CreateFrame("Frame", "BIT_ImportExportPopup", UIParent, "BackdropTemplate")
    pop:SetSize(480, 600)
    pop:SetPoint("CENTER")
    pop:SetFrameStrata("DIALOG")
    pop:SetFrameLevel(310)
    pop:SetMovable(true)
    pop:EnableMouse(true)
    pop:RegisterForDrag("LeftButton")
    pop:SetScript("OnDragStart", pop.StartMoving)
    pop:SetScript("OnDragStop",  pop.StopMovingOrSizing)
    pop:SetBackdrop({
        bgFile   = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    -- Themed surfaces: every accent-coloured element registers a paint
    -- callback; applyPopupTheme() runs them with the CURRENT palette so
    -- the popup follows the settings window's theme (default cyan /
    -- Alliance blue / Horde red) instead of baking in one look. Called
    -- once at creation (bottom of this function) and on every reopen.
    local themed = {}
    local function addThemed(fn) themed[#themed + 1] = fn end
    local function applyPopupTheme()
        local p = GetThemePalette()
        for _, fn in ipairs(themed) do fn(p) end
    end
    pop._applyTheme = applyPopupTheme

    addThemed(function(p)
        pop:SetBackdropColor(p.bg[1], p.bg[2], p.bg[3], 1)
        pop:SetBackdropBorderColor(p.accent[1], p.accent[2], p.accent[3], 1)
    end)

    -- Title strip: mirrors the main window's title bar (tinted background
    -- + subtle grey separator), stays draggable via the popup itself.
    local TITLE_H = 32
    local titleBg = pop:CreateTexture(nil, "BORDER")
    titleBg:SetPoint("TOPLEFT", 1, -1)
    titleBg:SetPoint("TOPRIGHT", -1, -1)
    titleBg:SetHeight(TITLE_H - 1)
    local titleLine = pop:CreateTexture(nil, "ARTWORK")
    titleLine:SetPoint("TOPLEFT", 1, -TITLE_H)
    titleLine:SetPoint("TOPRIGHT", -1, -TITLE_H)
    titleLine:SetHeight(1)
    addThemed(function(p)
        titleBg:SetColorTexture(p.titleBg[1], p.titleBg[2], p.titleBg[3], 0.9)
        titleLine:SetColorTexture(p.titleLine[1], p.titleLine[2], p.titleLine[3], p.titleLine[4])
    end)

    local title = pop:CreateFontString(nil, "OVERLAY")
    ApplyFont(title, 13, "OUTLINE")
    title:SetPoint("LEFT", pop, "TOPLEFT", 12, -TITLE_H / 2)
    title:SetTextColor(RGB(TEXT))
    title:SetText(LS("IMEX_TITLE", "Import/Export Profile"))

    -- Close X in the title strip (the bottom Close button stays too).
    local xBtn = CreateFrame("Button", nil, pop)
    xBtn:SetSize(22, 22)
    xBtn:SetPoint("TOPRIGHT", -6, -5)
    local xTxt = xBtn:CreateFontString(nil, "OVERLAY")
    ApplyFont(xTxt, 13, "OUTLINE")
    xTxt:SetPoint("CENTER")
    xTxt:SetText("X")
    xTxt:SetTextColor(RGB(TEXT_DIM))
    xBtn:SetScript("OnEnter", function() xTxt:SetTextColor(1, 0.35, 0.35) end)
    xBtn:SetScript("OnLeave", function() xTxt:SetTextColor(RGB(TEXT_DIM)) end)
    xBtn:SetScript("OnClick", function() pop:Hide() end)

    -- ── Export ──────────────────────────────────────────
    -- Section header in the settings window's banner style: uppercase
    -- accent text with an accent underline spanning the label.
    local expLbl = pop:CreateFontString(nil, "OVERLAY")
    ApplyFont(expLbl, 12, "OUTLINE")
    expLbl:SetPoint("TOPLEFT", 16, -46)
    expLbl:SetText(string.upper(LS("IMEX_EXPORT", "Export Profile")))
    local expUnder = pop:CreateTexture(nil, "ARTWORK")
    expUnder:SetHeight(1)
    expUnder:SetPoint("TOPLEFT",  expLbl, "BOTTOMLEFT",  0, -2)
    expUnder:SetPoint("TOPRIGHT", expLbl, "BOTTOMRIGHT", 0, -2)
    addThemed(function(p)
        expLbl:SetTextColor(p.accent[1], p.accent[2], p.accent[3])
        expUnder:SetColorTexture(p.accent[1], p.accent[2], p.accent[3], 0.8)
    end)

    -- Export scope: two modes with multi-select chips.
    --   PROFILES — pick WHICH saved profiles ship in the bundle (all
    --              checked = the classic full export).
    --   MODULES  — pick one or more modules; ships only those settings
    --              from the ACTIVE profile as a module-scoped string.
    -- Module display names shared with the import-side detection below.
    -- MODULE_LABELS keeps ALL categories (the import side may need to name
    -- any category found in a string); MODULE_ORDER lists only the modules
    -- offered for export — PI Caller is force-disabled right now and Smart
    -- Misdirect has nothing worth sharing, so neither is selectable.
    local MODULE_LABELS = {
        INTERRUPTS      = "Interrupt Tracker",
        PARTY_CDS       = "Party Cooldowns",
        PI_CALLER       = "PI Caller",
        KEYSTONE_LIST   = "Keystone List",
        SMART_MISDIRECT = "Smart Misdirect",
    }
    local MODULE_ORDER = { "INTERRUPTS", "PARTY_CDS", "KEYSTONE_LIST" }
    local exportMode = "PROFILES"
    local profileChecks = {}   -- profile name → checked (nil = default true)
    local moduleChecks  = {}   -- category key  → checked
    for _, c in ipairs(MODULE_ORDER) do moduleChecks[c] = (c == "INTERRUPTS") end
    local pendingModuleStr = nil   -- two-click confirm state for module imports
    local refreshExport            -- forward: assigned below the export box

    -- Mode toggle: a two-segment control (Profiles | Modules) aligned with
    -- the export header. The active segment fills with a translucent
    -- accent tint; segments sit flush (1px overlap) so they read as one
    -- connected control rather than two loose buttons.
    local function makeModeBtn(label, anchorTo)
        local b = CreateFrame("Button", nil, pop, "BackdropTemplate")
        b:SetSize(84, 20)
        if anchorTo then
            b:SetPoint("TOPRIGHT", anchorTo, "TOPLEFT", 1, 0)
        else
            b:SetPoint("TOPRIGHT", -16, -44)
        end
        MakeBg(b, RGB(WIDGET_BG))
        b._txt = b:CreateFontString(nil, "OVERLAY")
        ApplyFont(b._txt, 10)
        b._txt:SetPoint("CENTER")
        b._txt:SetText(label)
        return b
    end
    local modeModulesBtn  = makeModeBtn(LS("IMEX_MODE_MODULES", "Modules"))
    local modeProfilesBtn = makeModeBtn(LS("IMEX_MODE_PROFILES", "Profiles"), modeModulesBtn)
    local function styleModeBtns()
        local p = GetThemePalette()
        local function paint(btn, on)
            if on then
                btn._txt:SetTextColor(p.accent[1], p.accent[2], p.accent[3])
                btn:SetBackdropBorderColor(p.accent[1], p.accent[2], p.accent[3])
                btn:SetBackdropColor(p.accent[1] * 0.18, p.accent[2] * 0.18, p.accent[3] * 0.18, 1)
                btn:SetFrameLevel(pop:GetFrameLevel() + 3)   -- active border wins the 1px overlap
            else
                btn._txt:SetTextColor(RGB(TEXT_DIM))
                btn:SetBackdropBorderColor(RGB(BORDER))
                btn:SetBackdropColor(RGB(WIDGET_BG))
                btn:SetFrameLevel(pop:GetFrameLevel() + 2)
            end
        end
        paint(modeProfilesBtn, exportMode == "PROFILES")
        paint(modeModulesBtn,  exportMode == "MODULES")
    end
    styleModeBtns()
    addThemed(function() styleModeBtns() end)

    -- Multi-select chip area between the header and the export box.
    -- Chips wrap into up to 3 rows; each toggle re-generates the string.
    local CHIP_AREA_H = 74
    local chipArea = CreateFrame("Frame", nil, pop)
    chipArea:SetPoint("TOPLEFT", 16, -72)
    chipArea:SetSize(pop:GetWidth() - 32, CHIP_AREA_H)
    local chipPool = {}
    local function getChip(i)
        local c = chipPool[i]
        if c then return c end
        c = CreateFrame("Button", nil, chipArea, "BackdropTemplate")
        c:SetHeight(20)
        MakeBg(c, RGB(WIDGET_BG))
        c._box = c:CreateTexture(nil, "OVERLAY")
        c._box:SetSize(10, 10)
        c._box:SetPoint("LEFT", 6, 0)
        c._txt = c:CreateFontString(nil, "OVERLAY")
        ApplyFont(c._txt, 10)
        c._txt:SetPoint("LEFT", 22, 0)
        c:SetScript("OnClick", function(self)
            if self._onToggle then self._onToggle() end
        end)
        c:SetScript("OnEnter", function(self)
            local p = GetThemePalette()
            self:SetBackdropBorderColor(p.accent[1], p.accent[2], p.accent[3])
        end)
        c:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
        chipPool[i] = c
        return c
    end
    local function layoutChips()
        for _, c in ipairs(chipPool) do c:Hide() end
        local items = {}
        if exportMode == "PROFILES" then
            local sv = BliZziInterruptsSavedVars
            local names = {}
            if sv and sv.profiles then
                for n in pairs(sv.profiles) do
                    -- "Default" never ships in bundles (see _buildPayload),
                    -- so it isn't offered as a choice either.
                    if type(n) == "string" and n ~= "" and n ~= "Default" then
                        names[#names + 1] = n
                    end
                end
            end
            table.sort(names)
            for _, n in ipairs(names) do
                if profileChecks[n] == nil then profileChecks[n] = true end
                items[#items + 1] = {
                    label  = n,
                    get    = function() return profileChecks[n] end,
                    toggle = function() profileChecks[n] = not profileChecks[n] end,
                }
            end
        else
            for _, cat in ipairs(MODULE_ORDER) do
                items[#items + 1] = {
                    label  = MODULE_LABELS[cat],
                    get    = function() return moduleChecks[cat] end,
                    toggle = function() moduleChecks[cat] = not moduleChecks[cat] end,
                }
            end
        end
        local x, y, maxW = 0, 0, chipArea:GetWidth()
        for i, it in ipairs(items) do
            local c = getChip(i)
            c._txt:SetText(it.label)
            local w = math.min(maxW, math.floor((c._txt:GetStringWidth() or 40) + 32))
            c:SetWidth(w)
            if x + w > maxW and x > 0 then x = 0; y = y - 24 end
            c:ClearAllPoints()
            c:SetPoint("TOPLEFT", chipArea, "TOPLEFT", x, y)
            x = x + w + 6
            local function paint()
                local p = GetThemePalette()
                if it.get() then
                    c._box:SetColorTexture(p.accent[1], p.accent[2], p.accent[3], 1)
                    c._txt:SetTextColor(RGB(TEXT))
                    c:SetBackdropColor(p.accent[1] * 0.12, p.accent[2] * 0.12, p.accent[3] * 0.12, 1)
                else
                    c._box:SetColorTexture(0.25, 0.25, 0.28, 1)
                    c._txt:SetTextColor(RGB(TEXT_DIM))
                    c:SetBackdropColor(RGB(WIDGET_BG))
                end
            end
            paint()
            c._onToggle = function()
                it.toggle()
                paint()
                if refreshExport then refreshExport() end
            end
            c:Show()
        end
    end
    local function setExportMode(mode)
        exportMode = mode
        styleModeBtns()
        layoutChips()
        if refreshExport then refreshExport() end
    end
    modeProfilesBtn:SetScript("OnClick", function() setExportMode("PROFILES") end)
    modeModulesBtn:SetScript("OnClick",  function() setExportMode("MODULES")  end)

    -- Multi-line scrollable export box (~10 visible rows). Built as a
    -- bordered Frame containing a ScrollFrame whose child is a single
    -- multi-line EditBox. The EditBox itself stays read-only via the
    -- OnChar trick (re-injects the cached value on every key press) so
    -- the user can still mouse-select / Ctrl+C the text but not edit it.
    local EXP_VISIBLE_LINES = 10
    local EXP_LINE_H        = 14
    local EXP_BOX_H         = EXP_VISIBLE_LINES * EXP_LINE_H + 12
    local EXP_INNER_PAD     = 6

    local expFrame = CreateFrame("Frame", nil, pop, "BackdropTemplate")
    expFrame:SetSize(pop:GetWidth() - 32, EXP_BOX_H)
    expFrame:SetPoint("TOPLEFT", 16, -72 - CHIP_AREA_H - 8)
    MakeBg(expFrame, RGB(WIDGET_BG))

    local expScroll = CreateFrame("ScrollFrame", nil, expFrame)
    expScroll:SetPoint("TOPLEFT", EXP_INNER_PAD, -EXP_INNER_PAD)
    expScroll:SetPoint("BOTTOMRIGHT", -EXP_INNER_PAD, EXP_INNER_PAD)
    expScroll:EnableMouseWheel(true)

    local expBox = CreateFrame("EditBox", nil, expScroll)
    expBox:SetMultiLine(true)
    expBox:SetWidth(expScroll:GetWidth())
    ApplyFont(expBox, 10)
    expBox:SetTextColor(RGB(TEXT))
    expBox:SetAutoFocus(false)
    expBox:SetTextInsets(0, 0, 0, 0)
    expBox._val = ""
    expBox:SetScript("OnChar", function(self) self:SetText(self._val or "") end)
    expBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    -- Copy-box convention: clicking into the box re-selects the whole
    -- string, so it's always one Ctrl+C away.
    expBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    expScroll:SetScrollChild(expBox)

    -- Mouse wheel scrolling. Without this the ScrollFrame is silent on
    -- the wheel and the user can only drag-select to reach lines below.
    expScroll:SetScript("OnMouseWheel", function(self, delta)
        local cur   = self:GetVerticalScroll()
        local range = self:GetVerticalScrollRange()
        local next_ = cur - delta * EXP_LINE_H * 3
        if next_ < 0 then next_ = 0 end
        if next_ > range then next_ = range end
        self:SetVerticalScroll(next_)
    end)

    -- Re-export the bundle from current saved-vars state. Hooked from
    -- two places: once at popup creation (below), and again every time
    -- the popup is reopened (via `pop._refresh` in ShowImportExportPopup
    -- above) so the string always reflects the user's *current*
    -- profiles + spec assignments, not whatever was the case the first
    -- time the popup was built.
    refreshExport = function()
        local s
        if exportMode == "MODULES" then
            local sel = {}
            for _, cat in ipairs(MODULE_ORDER) do
                if moduleChecks[cat] then sel[cat] = true end
            end
            if not next(sel) then
                expBox._val = ""
                expBox:SetText(LS("IMEX_ERR_NO_SELECTION", "Select at least one module."))
                expScroll:SetVerticalScroll(0)
                return
            end
            s = BIT.ExportModule and BIT.ExportModule(sel)
        else
            -- Profile mode: ship the checked profiles as a (possibly
            -- partial) bundle. All checked → classic full export; none
            -- checked → flat settings of the active profile only.
            local wanted, total, checked = {}, 0, 0
            local sv = BliZziInterruptsSavedVars
            if sv and sv.profiles then
                for n in pairs(sv.profiles) do
                    if type(n) == "string" and n ~= "" and n ~= "Default" then
                        total = total + 1
                        if profileChecks[n] ~= false then
                            wanted[n] = true
                            checked = checked + 1
                        end
                    end
                end
            end
            local bundleArg
            if checked == 0 then bundleArg = false
            elseif checked == total then bundleArg = true
            else bundleArg = wanted end
            local catFilter = {}
            for _, c in ipairs(BIT.PROFILE_CATEGORIES or {}) do catFilter[c] = true end
            s = BIT.ExportProfile(catFilter, true, bundleArg)
        end
        expBox._val = s or ""
        expBox:SetText(s or "")
        expScroll:SetVerticalScroll(0)
        -- Pre-select + focus so the string is one Ctrl+C away the moment
        -- the popup opens (or the scope selection changes).
        expBox:SetFocus()
        expBox:HighlightText()
    end
    layoutChips()
    refreshExport()

    -- Anchor everything below the export box dynamically so changes to
    -- EXP_VISIBLE_LINES don't require re-tuning each y-offset by hand.
    -- The extra 26px leaves room for the divider above the import header.
    local impTop = -72 - CHIP_AREA_H - 8 - EXP_BOX_H - 26

    -- ── Import ──────────────────────────────────────────
    -- Full-width divider separates the two halves of the popup; the header
    -- repeats the export section's banner style (uppercase + underline).
    local impDiv = pop:CreateTexture(nil, "ARTWORK")
    impDiv:SetHeight(1)
    impDiv:SetPoint("TOPLEFT",  16, impTop + 14)
    impDiv:SetPoint("TOPRIGHT", -16, impTop + 14)
    impDiv:SetColorTexture(RGB(BORDER))

    local impLbl = pop:CreateFontString(nil, "OVERLAY")
    ApplyFont(impLbl, 12, "OUTLINE")
    impLbl:SetPoint("TOPLEFT", 16, impTop)
    impLbl:SetText(string.upper(LS("IMEX_IMPORT_HEADER", "Import Profile")))
    local impUnder = pop:CreateTexture(nil, "ARTWORK")
    impUnder:SetHeight(1)
    impUnder:SetPoint("TOPLEFT",  impLbl, "BOTTOMLEFT",  0, -2)
    impUnder:SetPoint("TOPRIGHT", impLbl, "BOTTOMRIGHT", 0, -2)
    addThemed(function(p)
        impLbl:SetTextColor(p.accent[1], p.accent[2], p.accent[3])
        impUnder:SetColorTexture(p.accent[1], p.accent[2], p.accent[3], 0.8)
    end)

    local nameLbl = pop:CreateFontString(nil, "OVERLAY")
    ApplyFont(nameLbl, 11)
    nameLbl:SetPoint("TOPLEFT", 16, impTop - 20)
    nameLbl:SetTextColor(RGB(TEXT_DIM))
    nameLbl:SetText(LS("IMEX_NAME", "Profile Name"))

    local nameBox = CreateFrame("EditBox", nil, pop, "BackdropTemplate")
    nameBox:SetSize(pop:GetWidth() - 32, 24)
    nameBox:SetPoint("TOPLEFT", 16, impTop - 36)
    MakeBg(nameBox, RGB(WIDGET_BG))
    ApplyFont(nameBox, 11)
    nameBox:SetTextColor(RGB(TEXT))
    nameBox:SetTextInsets(6, 6, 0, 0)
    nameBox:SetAutoFocus(false)
    -- Suggest "Default (N)" where N keeps incrementing until unused.
    local function nextSuggestion()
        local i = 2
        while BIT.Profiles and BIT.Profiles:Exists("Default (" .. i .. ")") do
            i = i + 1
        end
        return "Default (" .. i .. ")"
    end
    nameBox:SetText(nextSuggestion())
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Visual + functional enable / disable for the profile-name field.
    -- When a bundle is detected in the string box, the name field is
    -- ignored by the import path — so we grey it out + lock interaction
    -- so the user doesn't waste time typing into a non-functional input.
    -- Reset back to "enabled" on popup refresh and when the string box
    -- contains something that isn't a bundle (or is empty).
    local function setNameBoxEnabled(enabled)
        nameBox:EnableMouse(enabled)
        nameBox:EnableKeyboard(enabled)
        if enabled then
            nameBox:SetTextColor(RGB(TEXT))
            nameLbl:SetTextColor(RGB(TEXT_DIM))
            nameBox:SetBackdropColor(RGB(WIDGET_BG))
        else
            nameBox:ClearFocus()
            nameBox:SetTextColor(0.4, 0.4, 0.4)
            nameLbl:SetTextColor(0.30, 0.30, 0.32)
            nameBox:SetBackdropColor(0.10, 0.10, 0.11, 1)
        end
    end

    local strLbl = pop:CreateFontString(nil, "OVERLAY")
    ApplyFont(strLbl, 11)
    strLbl:SetPoint("TOPLEFT", 16, impTop - 68)
    strLbl:SetTextColor(RGB(TEXT_DIM))
    strLbl:SetText(LS("IMEX_STR", "Profile String"))

    local strBox = CreateFrame("EditBox", nil, pop, "BackdropTemplate")
    strBox:SetSize(pop:GetWidth() - 32, 24)
    strBox:SetPoint("TOPLEFT", 16, impTop - 84)
    MakeBg(strBox, RGB(WIDGET_BG))
    ApplyFont(strBox, 10)
    strBox:SetTextColor(RGB(TEXT))
    strBox:SetTextInsets(6, 6, 0, 0)
    strBox:SetAutoFocus(false)
    strBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Status / hint text. Anchored directly BELOW the string box and
    -- grows DOWNWARD (top-anchored, JustifyV TOP, auto height). The old
    -- bottom-anchored version grew upward and overlapped the string box
    -- whenever the bundle hint ran multi-line. Width-constrained + word
    -- wrap so long lines wrap inside the popup. The popup is tall enough
    -- to hold a few lines of status above the bottom buttons.
    local statusLbl = pop:CreateFontString(nil, "OVERLAY")
    ApplyFont(statusLbl, 11)
    statusLbl:SetPoint("TOPLEFT",  strBox, "BOTTOMLEFT",  0, -10)
    statusLbl:SetPoint("TOPRIGHT", strBox, "BOTTOMRIGHT", 0, -10)
    statusLbl:SetJustifyH("LEFT")
    statusLbl:SetJustifyV("TOP")
    statusLbl:SetWordWrap(true)
    statusLbl:SetNonSpaceWrap(true)
    statusLbl:SetHeight(0)  -- height auto-grows from content
    statusLbl:SetTextColor(RGB(TEXT_DIM))
    statusLbl:SetText("")

    -- Close button (bottom right).
    local closeBtn = CreateFrame("Button", nil, pop, "BackdropTemplate")
    closeBtn:SetSize(96, 26)
    closeBtn:SetPoint("BOTTOMRIGHT", -110, 12)
    MakeBg(closeBtn, 0.18, 0.10, 0.10, 1)
    local cT = closeBtn:CreateFontString(nil, "OVERLAY") ApplyFont(cT, 11)
    cT:SetPoint("CENTER") cT:SetTextColor(1, 0.6, 0.6) cT:SetText(LS("IMEX_CLOSE", "Close"))
    closeBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(1, 0.4, 0.4) end)
    closeBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
    closeBtn:SetScript("OnClick", function() pop:Hide() end)

    -- Import button (bottom right, next to Close) — the popup's primary
    -- action, so it carries the theme accent (tinted fill + accent text).
    local importBtn = CreateFrame("Button", nil, pop, "BackdropTemplate")
    importBtn:SetSize(96, 26)
    importBtn:SetPoint("BOTTOMRIGHT", -8, 12)
    MakeBg(importBtn, RGB(WIDGET_BG))
    local iT = importBtn:CreateFontString(nil, "OVERLAY") ApplyFont(iT, 11)
    iT:SetPoint("CENTER") iT:SetText(LS("IMEX_BTN_IMPORT", "Import"))
    addThemed(function(p)
        iT:SetTextColor(p.accent[1], p.accent[2], p.accent[3])
        importBtn:SetBackdropColor(p.accent[1] * 0.15, p.accent[2] * 0.15, p.accent[3] * 0.15, 1)
        importBtn:SetBackdropBorderColor(p.accent[1] * 0.6, p.accent[2] * 0.6, p.accent[3] * 0.6, 1)
    end)
    importBtn:SetScript("OnEnter", function(self)
        local p = GetThemePalette()
        self:SetBackdropBorderColor(p.accent[1], p.accent[2], p.accent[3])
    end)
    importBtn:SetScript("OnLeave", function(self)
        local p = GetThemePalette()
        self:SetBackdropBorderColor(p.accent[1] * 0.6, p.accent[2] * 0.6, p.accent[3] * 0.6, 1)
    end)
    importBtn:SetScript("OnClick", function()
        local pname = nameBox:GetText()
        local pstr  = strBox:GetText()
        pname = pname and pname:gsub("^%s+", ""):gsub("%s+$", "") or ""
        pstr  = pstr  and pstr:gsub("^%s+", ""):gsub("%s+$", "")  or ""

        if pstr == "" then
            statusLbl:SetTextColor(1.0, 0.3, 0.3)
            statusLbl:SetText(LS("IMEX_ERR_STR", "Profile string is required."))
            return
        end

        -- Peek the string kind so we know whether a profile name is
        -- needed. Bundle exports already carry their own profile names
        -- and don't use the name field at all.
        local kind, kmeta
        if BIT.PeekProfileImport then kind, kmeta = BIT.PeekProfileImport(pstr) end
        kind = kind or "legacy"

        -- Module-scoped string: never run the full-profile import (it
        -- would reset every other module to defaults). Warn on the first
        -- click; a second click confirms and applies ONLY that module's
        -- settings onto the CURRENT profile (name field is ignored).
        if kind == "module" then
            local labels = {}
            for _, c in ipairs((kmeta and kmeta.categories) or {}) do
                labels[#labels + 1] = MODULE_LABELS[c] or c
            end
            local what = table.concat(labels, ", ")
            if pendingModuleStr ~= pstr then
                pendingModuleStr = pstr
                statusLbl:SetTextColor(1.0, 0.72, 0.2)
                statusLbl:SetText(string.format(
                    LS("IMEX_MODULE_WARN",
                       "This string is a MODULE export (%s), not a full profile. Importing applies only that module's settings to your CURRENT profile. Click Import again to confirm."),
                    what))
                return
            end
            pendingModuleStr = nil
            local ok, msg = BIT.ImportModule and BIT.ImportModule(pstr)
            if ok then
                statusLbl:SetTextColor(0.2, 1.0, 0.2)
                statusLbl:SetText(string.format(
                    LS("IMEX_OK_MODULE", "Module settings imported (%s)."), what))
                strBox:SetText("")
                if BIT.SettingsUI.RefreshActivePage then
                    BIT.SettingsUI:RefreshActivePage()
                end
            else
                statusLbl:SetTextColor(1.0, 0.3, 0.3)
                statusLbl:SetText(msg or LS("IMEX_ERR_FAILED", "Import failed."))
            end
            return
        end

        if kind ~= "bundle" and pname == "" then
            statusLbl:SetTextColor(1.0, 0.3, 0.3)
            statusLbl:SetText(LS("IMEX_ERR_NAME", "Profile name is required."))
            return
        end

        if BIT.Profiles and BIT.Profiles.Import then
            local ok, msg, meta = BIT.Profiles:Import(pname, pstr)
            if ok then
                statusLbl:SetTextColor(0.2, 1.0, 0.2)
                if meta and meta.kind == "bundle" and (meta.profiles or 0) == 1 and pname ~= "" then
                    -- Single-profile bundle imported under the typed name.
                    statusLbl:SetText(string.format(LS("IMEX_OK", "Imported as '%s'."), pname))
                elseif meta and meta.kind == "bundle" then
                    statusLbl:SetText(string.format(
                        LS("IMEX_OK_BUNDLE",
                           "Imported %d profile(s), %d spec assignment(s)."),
                        meta.profiles or 0, meta.mappings or 0))
                else
                    statusLbl:SetText(string.format(LS("IMEX_OK", "Imported as '%s'."), pname))
                end
                strBox:SetText("")
                nameBox:SetText(nextSuggestion())
                if BIT.SettingsUI.RefreshActivePage then
                    BIT.SettingsUI:RefreshActivePage()
                end
            else
                statusLbl:SetTextColor(1.0, 0.3, 0.3)
                statusLbl:SetText(msg or LS("IMEX_ERR_FAILED", "Import failed."))
            end
        end
    end)

    -- Live bundle detection: as the user pastes/types into the string
    -- box, peek the encoded payload and surface a neutral hint in the
    -- status line if it looks like a bundle. Helps the user understand
    -- ahead of clicking Import that the profile-name field is going to
    -- be ignored. Cleared as soon as the box is empty again.
    strBox:SetScript("OnTextChanged", function(self)
        -- Any text change invalidates a pending module-import confirmation
        -- (the warning referred to the previous string).
        pendingModuleStr = nil
        local pstr = self:GetText()
        pstr = pstr and pstr:gsub("^%s+", ""):gsub("%s+$", "") or ""
        if pstr == "" then
            statusLbl:SetText("")
            setNameBoxEnabled(true)
            return
        end
        if not BIT.PeekProfileImport then
            statusLbl:SetText("")
            setNameBoxEnabled(true)
            return
        end
        local kind, meta = BIT.PeekProfileImport(pstr)
        if kind == "module" and meta then
            -- Same early feedback as the bundle hint: tell the user right
            -- away this is a module-only string (name field unused).
            local labels = {}
            for _, c in ipairs(meta.categories or {}) do
                labels[#labels + 1] = MODULE_LABELS[c] or c
            end
            statusLbl:SetTextColor(1.0, 0.72, 0.2)
            statusLbl:SetText(string.format(
                LS("IMEX_MODULE_HINT",
                   "Module export detected (%s) — this string contains only that module's settings. The profile name field is ignored."),
                table.concat(labels, ", ")))
            setNameBoxEnabled(false)
        elseif kind == "bundle" and meta then
            local pal = GetThemePalette()
            statusLbl:SetTextColor(pal.accent[1], pal.accent[2], pal.accent[3])
            if (meta.profiles or 0) == 1 then
                -- Single-profile bundle: from the user's perspective this
                -- is "one exported profile" — the name field stays usable
                -- and the profile imports under whatever it says. Prefill
                -- with the exporter's name so a plain Import keeps it.
                local orig = (meta.names and meta.names[1]) or "?"
                statusLbl:SetText(string.format(
                    LS("IMEX_BUNDLE_SINGLE_HINT",
                       "Profile export detected: '%s' (+%d spec assignment(s)). It imports under the profile name above — edit the name to rename it."),
                    orig, meta.mappings or 0))
                nameBox:SetText(orig)
                setNameBoxEnabled(true)
                return
            end
            -- Build the hint text: a one-line summary + (when present) a
            -- vertically-listed roster of the profiles inside the bundle.
            -- statusLbl was created with SetWordWrap(true) + auto-grow
            -- height so multi-line content just expands the label
            -- downward without overflowing the popup.
            local hint = string.format(
                LS("IMEX_BUNDLE_HINT",
                   "Bundle detected: %d profile(s) + %d spec assignment(s). The profile name field is ignored for bundle imports."),
                meta.profiles or 0, meta.mappings or 0)
            if meta.names and #meta.names > 0 then
                local lines = { hint, "", LS("IMEX_BUNDLE_PROFILES", "Profiles:") }
                local active = meta.activeProfile
                for _, n in ipairs(meta.names) do
                    -- Mark the bundle's active profile so the user knows
                    -- which one becomes the new "current" on import.
                    if n == active then
                        lines[#lines + 1] = "  - " .. n .. "  "
                            .. LS("IMEX_BUNDLE_ACTIVE_MARK", "(active)")
                    else
                        lines[#lines + 1] = "  - " .. n
                    end
                end
                statusLbl:SetText(table.concat(lines, "\n"))
            else
                statusLbl:SetText(hint)
            end
            -- Multi-profile bundles bring their own profile names — the
            -- name field above the string box is ignored. Grey it out so
            -- the user doesn't try to type into something unused.
            setNameBoxEnabled(false)
        else
            statusLbl:SetText("")
            setNameBoxEnabled(true)
        end
    end)

    -- Public refresh: rebuilds the export string from current saved-vars
    -- state, resets the import side to a clean state, and clears any
    -- leftover status from a previous open. Called by the early-return
    -- branch of ShowImportExportPopup.
    pop._refresh = function()
        -- Follow the settings window's theme on every reopen (the user may
        -- have switched theme or faction since the popup was created).
        applyPopupTheme()
        -- Reset the export scope to the predictable default (full bundle):
        -- profile mode with every profile checked, module picks cleared.
        exportMode = "PROFILES"
        for k in pairs(profileChecks) do profileChecks[k] = nil end
        for _, c in ipairs(MODULE_ORDER) do moduleChecks[c] = (c == "INTERRUPTS") end
        styleModeBtns()
        layoutChips()
        pendingModuleStr = nil
        refreshExport()
        nameBox:SetText(nextSuggestion())
        strBox:SetText("")
        statusLbl:SetText("")
        -- Reset the name field back to "enabled" on every reopen — the
        -- previous session may have left it greyed out from a bundle paste.
        setNameBoxEnabled(true)
    end

    -- First open: the creation path doesn't go through _refresh, so paint
    -- the theme onto every registered surface now.
    applyPopupTheme()
end

function BIT.SettingsUI:Toggle()
    if not mainFrame then
        self:Init()
    end
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        if not activePage then
            self:ShowPage("General")
        end
        -- Re-apply theme on each open so a faction-change between
        -- sessions, or a setting flip via the dropdown without the
        -- window having been re-opened yet, lands correctly.
        BIT.SettingsUI:ApplyTheme()
    end
end

------------------------------------------------------------
-- Anchor frame picker (interrupt tracker "Free Anchor")
------------------------------------------------------------
-- While picking, the big settings window steps aside and a small prompt
-- box shows the instructions, so the whole screen is free to point at the
-- target frame. The prompt is mouse-disabled so the picker never selects it.
function BIT.SettingsUI:EnterPickerMode()
    local prompt = self._pickPrompt
    if not prompt then
        -- Distinct layout (not a cursor-following tooltip): a fixed, centred
        -- panel with the live frame name on its own prominent line and the
        -- instructions tucked underneath.
        prompt = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        prompt:SetSize(380, 116)
        prompt:SetPoint("TOP", UIParent, "TOP", 0, -150)
        prompt:SetFrameStrata("FULLSCREEN_DIALOG")
        prompt:EnableMouse(false)
        prompt:SetBackdrop({
            bgFile   = "Interface\\BUTTONS\\WHITE8X8",
            edgeFile = "Interface\\BUTTONS\\WHITE8X8",
            edgeSize = 1,
            insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        prompt:SetBackdropColor(0.08, 0.09, 0.11, 0.95)
        prompt:SetBackdropBorderColor(RGB(ACCENT))

        -- Accent bar down the left edge — a small visual signature.
        local stripe = prompt:CreateTexture(nil, "ARTWORK")
        stripe:SetPoint("TOPLEFT", 1, -1)
        stripe:SetPoint("BOTTOMLEFT", 1, 1)
        stripe:SetWidth(3)
        stripe:SetColorTexture(RGB(ACCENT))

        local title = prompt:CreateFontString(nil, "OVERLAY")
        ApplyFont(title, 12)
        title:SetPoint("TOPLEFT", 16, -12)
        title:SetTextColor(0.6, 0.6, 0.66)
        title:SetText(LS("PICK_PROMPT_TITLE", "Pick an anchor frame"))

        -- The live frame name — the headline of the panel.
        local nameLine = prompt:CreateFontString(nil, "OVERLAY")
        ApplyFont(nameLine, 16, "OUTLINE")
        nameLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
        nameLine:SetPoint("RIGHT", prompt, "RIGHT", -16, 0)
        nameLine:SetJustifyH("LEFT")
        nameLine:SetWordWrap(false)
        nameLine:SetTextColor(RGB(ACCENT))
        self._pickPromptName = nameLine

        local body = prompt:CreateFontString(nil, "OVERLAY")
        ApplyFont(body, 11)
        body:SetPoint("BOTTOMLEFT", 16, 12)
        body:SetPoint("RIGHT", prompt, "RIGHT", -16, 0)
        body:SetJustifyH("LEFT")
        body:SetTextColor(RGB(TEXT))
        body:SetText(LS("PICK_PROMPT_BODY",
            "Left-Click selects · Right-Click / ESC cancels"))
        self._pickPrompt = prompt
    end
    -- Reset the headline to the "no frame yet" placeholder each time.
    if self._pickPromptName then
        self._pickPromptName:SetText("|cff777777"
            .. LS("PICK_PROMPT_HOVER", "Hover a frame…") .. "|r")
    end
    if mainFrame then mainFrame:Hide() end
    prompt:Show()
end

function BIT.SettingsUI:ExitPickerMode()
    if self._pickPrompt then self._pickPrompt:Hide() end
    if mainFrame then mainFrame:Show() end
end

function BIT.SettingsUI:StartInterruptAnchorPick()
    if not (BIT.UI and BIT.UI.StartFramePicker) then return end
    self:EnterPickerMode()
    BIT.UI:StartFramePicker(
        function(name)  -- confirmed
            BIT.SettingsUI:ExitPickerMode()
            if not BIT.db then return end
            BIT.db.interruptFreeAnchorTarget = name
            BIT.db.interruptFreeAnchor       = true
            BIT.db.interruptFreeAnchorX      = 0
            BIT.db.interruptFreeAnchorY      = 0
            if BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
            if pages[activePage] and pages[activePage].refresh then pages[activePage].refresh() end
            if pages[activePage] and pages[activePage].layout then pages[activePage].layout() end
        end,
        function()  -- cancelled
            BIT.SettingsUI:ExitPickerMode()
        end,
        function(name)  -- hover changed: update the fixed panel headline
            local fs = BIT.SettingsUI._pickPromptName
            if not fs then return end
            if name and name ~= "" then
                fs:SetText(name)
            else
                fs:SetText("|cff777777" .. LS("PICK_PROMPT_HOVER", "Hover a frame…") .. "|r")
            end
        end
    )
end

-- Apply the user's selected theme to every theme-able surface on
-- the live settings window:
--   • Main backdrop colour + border (border = strong faction colour)
--   • Outer glow (uses accent2 — black for Horde, white for Alliance)
--   • Title bar background + separator line
--   • Sidebar background
--   • Faction crest texture (from Media/alliance.tga or horde.tga)
-- Called from CreateMainFrame (initial paint), Toggle (window
-- re-open), and the theme dropdown setter (live flip).
function BIT.SettingsUI:ApplyTheme()
    if not mainFrame then return end
    local p = GetThemePalette()
    -- Main content backdrop. The 1px backdrop border is painted in
    -- the BACKGROUND color (not removed — the backdrop insets would
    -- otherwise leave a 1px see-through ring): the visible outline
    -- is the outer glow halo alone, no colored accent stripe.
    mainFrame:SetBackdropColor(p.bg[1], p.bg[2], p.bg[3], 0.9)  -- slightly transparent (matches the rework popup)
    mainFrame:SetBackdropBorderColor(p.bg[1], p.bg[2], p.bg[3], 0.9)
    -- Outer glow + title-line use explicit RGBA tuples from the
    -- palette so each theme can dial its halo and pinstripe
    -- separately from the main accent.
    if mainFrame._glow and mainFrame._glow._lines then
        for _, line in ipairs(mainFrame._glow._lines) do
            line:SetColorTexture(p.glow[1], p.glow[2], p.glow[3], p.glow[4])
        end
    end
    if mainFrame._titleBg then
        -- Match the sidebar exactly (same colour + alpha) so the title
        -- bar and sidebar read as one consistent panel.
        mainFrame._titleBg:SetColorTexture(p.sidebarBg[1], p.sidebarBg[2], p.sidebarBg[3], 0.9)
    end
    if mainFrame._titleLine then
        mainFrame._titleLine:SetColorTexture(p.titleLine[1], p.titleLine[2], p.titleLine[3], p.titleLine[4])
    end
    if mainFrame._sidebarBg then
        mainFrame._sidebarBg:SetColorTexture(p.sidebarBg[1], p.sidebarBg[2], p.sidebarBg[3], 0.9)
    end
    -- Faction crest. The bundled custom textures don't need
    -- SetTexCoord cropping (they're clean transparent PNGs/TGAs).
    if mainFrame._factionLogo then
        if p.factionTex then
            mainFrame._factionLogo:SetTexture(p.factionTex)
            mainFrame._factionLogo:SetTexCoord(0, 1, 0, 1)
            mainFrame._factionLogo:Show()
        else
            mainFrame._factionLogo:Hide()
        end
    end
    -- Repaint the custom scrollbar thumbs in the live accent.
    for _, repaint in ipairs(_themedScrollThumbs) do repaint() end
    -- Re-theme the color picker if it has already been skinned (no-op
    -- until the user first opens it).
    if self.ApplyColorPickerTheme then self:ApplyColorPickerTheme() end
    -- CPU footer surface matches the TITLE BAR (sidebarBg tint) so
    -- top and bottom of the window read as the same panel color;
    -- borderless look (border painted in the same color), glow halo
    -- shared with the window.
    if mainFrame._cpuFooter then
        mainFrame._cpuFooter:SetBackdropColor(p.sidebarBg[1], p.sidebarBg[2], p.sidebarBg[3], 0.9)
        mainFrame._cpuFooter:SetBackdropBorderColor(p.sidebarBg[1], p.sidebarBg[2], p.sidebarBg[3], 0.9)
        if mainFrame._cpuFooter._glow and mainFrame._cpuFooter._glow._lines then
            for _, line in ipairs(mainFrame._cpuFooter._glow._lines) do
                line:SetColorTexture(p.glow[1], p.glow[2], p.glow[3], p.glow[4])
            end
        end
    end
end

function BIT.SettingsUI:Init()
    L = BIT.L

    CreateMainFrame()
    -- Initial theme paint. CreateMainFrame ran with the cyan default
    -- so every surface is currently grey/cyan; ApplyTheme repaints
    -- according to the user's saved setting (or AUTO from faction).
    self:ApplyTheme()

    -- Register pages. Page keys stay English (used internally for
    -- ShowPage / activePage tracking and sidebarBtns lookup); the
    -- localised label is passed via the second argument and rendered
    -- on the sidebar button itself.
    --
    -- 3.8.0: "Size & Font" and "Colors" were merged into the Interrupts
    -- page so each feature owns its own visual styling. Their helper
    -- builders (BuildSizeFont / BuildColors) still exist further up in
    -- this file and are now called from inside BuildInterrupts, so the
    -- DB keys, widgets and locale strings all keep working unchanged.
    RegisterPage("General",        BuildGeneral)
    RegisterPage("Interrupts",     BuildInterrupts)
    RegisterPage("Party CDs",      BuildPartyCDs)
    RegisterPage("Smart Misdirect",BuildSmartMisdirect)
    RegisterPage("PI Caller",      BuildOffensiveCDAlert)
    RegisterPage("Keystone List",  BuildKeystoneList)
    RegisterPage("Profiles",       BuildProfiles)
    RegisterPage("Changelog",      BuildChangelog)

    -- Create sidebar buttons. All pages are always visible; pages that
    -- require a specific class (Smart Misdirect) show an informational
    -- note on their own page when the feature isn't applicable.
    CreateSidebarBtn(1, "General",        136243, LS("PANEL_GENERAL",     "General"))         -- Interface/misc
    CreateSidebarBtn(2, "Interrupts",     236281, LS("PANEL_INTERRUPTS",  "Interrupts"))      -- Ability_kick
    CreateSidebarBtn(3, "Party CDs",      236440, LS("PANEL_PARTY_CDS",   "Party CDs"))       -- Spell_holy_powerwordbarrier
    CreateSidebarBtn(4, "Smart Misdirect", 132180, LS("PANEL_SMART_MD",   "Smart Misdirect")) -- ability_hunter_misdirection
    -- Pull the live Power Infusion (id 10060) texture instead of a
    -- hard-coded FileDataID — survives art swaps in future patches.
    local piIcon
    do
        local ok, tex = pcall(C_Spell.GetSpellTexture, 10060)
        if ok and tex then piIcon = tex end
    end
    CreateSidebarBtn(5, "PI Caller",       piIcon or 135932, LS("PANEL_PI_CALLER", "PI Caller"))
    -- Keystone icon: inv_relics_hourglass_02 (golden hourglass)
    CreateSidebarBtn(6, "Keystone List",   525134, LS("PANEL_KEYSTONE_LIST", "Keystone List"))
    CreateSidebarBtn(7, "Profiles",        134400, LS("PANEL_PROFILES", "Profiles"))           -- inv_misc_note_05
    CreateSidebarBtn(8, "Changelog",       413587, LS("PANEL_CHANGELOG", "Changelog"))         -- inv_misc_book_07

    -- Adjust contentChild width after frame is visible
    mainFrame:HookScript("OnShow", function()
        contentChild:SetWidth(WIN_W - SIDEBAR_W - 26)
    end)
end

------------------------------------------------------------
-- ── Slash command hook (called from Core.lua) ────────────
------------------------------------------------------------
function BIT.SettingsUI:HookSlash()
    -- Settings UI entry points — all aliases just open the panel. The
    -- old `/blizzi <subcommand>` shortcuts (rotation / profile / test /
    -- debug) were removed in 3.6.4 along with the standalone /bittest
    -- and /bitrotation commands; everything is now driven through the
    -- Settings UI's sidebar pages.
    SLASH_BLIZZI1       = "/blizzi"
    SLASH_BLIZZI2       = "/bitset"
    SLASH_BLIZZI3       = "/bliset"
    SLASH_BLIZZI4       = "/interrupts"
    SlashCmdList["BLIZZI"] = function()
        BIT.SettingsUI:Toggle()
    end
end

------------------------------------------------------------
-- ── Minimap Button (LibDBIcon) ──────────────────────────
------------------------------------------------------------

-- Right-click on the minimap button: flip every movable module into its
-- test/preview layout at once so the user can reposition all frames in
-- one go — Interrupt Tracker test bars, Keystone List test layout, and
-- the Party CDs standalone frame (only when standalone mode is active;
-- the anchored mode glues icons to unit frames, nothing to move there).
-- A second right-click ends the mode everywhere it is running. Each
-- module only joins when its feature is enabled, and modules the user
-- toggled individually beforehand are respected (no double-toggles).
-- Shared "all active modules at once" toggle. Both entry points flip
-- the same module set — Interrupt test bars, Keystone List test
-- layout, Party CDs standalone test layout (only when standalone mode
-- is active). `withUnlock` decides the flavor:
--   true   right-click move mode: every frame lock is overridden at
--          runtime so the test frames can be dragged.
--   false  shift-click preview: pure test mode, locks stay as the
--          user configured them.
local function ToggleAllTestModes(withUnlock)
    local klActive  = BIT.KeystoneList and BIT.KeystoneList.IsTestModeActive
                      and BIT.KeystoneList:IsTestModeActive()
    local pcdActive = BIT.PartyCooldowns and BIT.PartyCooldowns.IsTestLayoutActive
                      and BIT.PartyCooldowns:IsTestLayoutActive()
    local anyActive = (BIT.testMode == true) or klActive or pcdActive

    -- Re-applies the (possibly overridden) lock state to the frames that
    -- cache it in EnableMouse/SetMovable. The Keystone List needs no
    -- re-apply — its drag handler reads the flag live.
    local function reapplyLocks()
        if BIT.UI and BIT.UI.ApplyClickThrough then BIT.UI:ApplyClickThrough() end
        if BIT.PartyCooldowns and BIT.PartyCooldowns.IsEnabled
           and BIT.PartyCooldowns:IsEnabled()
           and BIT.db and BIT.db.partyCooldownsFrameMode == "STANDALONE"
           and BIT.PartyCooldowns.RebuildAnchors then
            BIT.PartyCooldowns:RebuildAnchors()
        end
    end

    if anyActive then
        -- End the mode: drop the runtime lock override FIRST so the
        -- teardown paths re-apply the user's real lock settings.
        BIT._moveAllUnlock = nil
        if BIT.testMode and BIT.StopTestMode then BIT:StopTestMode() end
        if klActive then BIT.KeystoneList:ToggleTestMode() end
        if pcdActive then BIT.PartyCooldowns:ToggleTestLayout() end
        reapplyLocks()
        return
    end

    -- Start. Move mode additionally unlocks everything (runtime only,
    -- saved lock settings stay untouched) so "movable" actually means
    -- movable; the preview flavor leaves the locks alone.
    BIT._moveAllUnlock = withUnlock and true or nil
    if BIT.Interrupts and BIT.Interrupts.IsEnabled and BIT.Interrupts:IsEnabled()
       and BIT.StartTestMode then
        BIT:StartTestMode()
    end
    if BIT.db and BIT.db.keystoneListEnabled == true
       and BIT.KeystoneList and BIT.KeystoneList.ToggleTestMode then
        BIT.KeystoneList:ToggleTestMode()
    end
    if BIT.PartyCooldowns and BIT.PartyCooldowns.IsEnabled and BIT.PartyCooldowns:IsEnabled()
       and BIT.db and BIT.db.partyCooldownsFrameMode == "STANDALONE"
       and BIT.PartyCooldowns.ToggleTestLayout then
        BIT.PartyCooldowns:ToggleTestLayout()
    end
    reapplyLocks()
end

function BIT.SettingsUI:ToggleMoveAllFrames()
    ToggleAllTestModes(true)
end

-- Shift-click on the minimap button: test-mode preview of every
-- active module, frames stay locked.
function BIT.SettingsUI:ToggleTestAllModules()
    ToggleAllTestModes(false)
end

function BIT.SettingsUI:CreateMinimapButton()
    if self.minimapBtn then return end

    local ldb  = LibStub and LibStub("LibDataBroker-1.1", true)
    local ldbi = LibStub and LibStub("LibDBIcon-1.0", true)
    if not ldb or not ldbi then return end

    local ICON = "Interface\\AddOns\\BliZzi_Interrupts\\Media\\icon"

    -- Create a LibDataBroker data object (standard LDB consumer pattern).
    local dataObj = ldb:NewDataObject("BliZziInterrupts", {
        type = "data source",
        text = "隊友技能和斷法監控",
        icon = ICON,
        OnClick = function(_, button)
            if IsShiftKeyDown() then
                BIT.SettingsUI:ToggleTestAllModules()
            elseif button == "RightButton" then
                BIT.SettingsUI:ToggleMoveAllFrames()
            elseif button == "LeftButton" then
                BIT.SettingsUI:Toggle()
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("|cff0091ed隊友技能|r和|cffffa300斷法監控|r", 1, 1, 1)
            tt:AddLine(" ")

            -- Per-module status at a glance: Active (working/shown here) /
            -- Idle (enabled but dormant in this context, e.g. a raid with
            -- its raid toggle off) / Deactivated (switched off in settings).
            local function statusLine(label, state)
                local txt, r, g, b
                if state == "active" then
                    txt, r, g, b = "已啟用", 0.30, 1.00, 0.30
                elseif state == "idle" then
                    txt, r, g, b = "閒置", 1.00, 0.82, 0.00
                elseif state == "hidden" then
                    txt, r, g, b = "隱藏", 0.45, 0.65, 0.95
                else
                    txt, r, g, b = "已停用", 0.60, 0.60, 0.60
                end
                tt:AddDoubleLine(label, txt, 0.9, 0.9, 0.9, r, g, b)
            end

            -- Interrupt Tracker (enabled + shown in the current zone)
            local intState = "deactivated"
            if BIT.Interrupts and BIT.Interrupts:IsEnabled() then
                intState = (BIT.UI and BIT.UI.IsZoneEnabled and BIT.UI:IsZoneEnabled())
                           and "active" or "idle"
            end
            statusLine("打斷追蹤", intState)

            -- Party CDs (enabled + shown in the current zone)
            local pcdState = "deactivated"
            if BIT.PartyCooldowns and BIT.PartyCooldowns.IsEnabled and BIT.PartyCooldowns:IsEnabled() then
                pcdState = (BIT.PartyCooldowns.IsActiveHere and BIT.PartyCooldowns:IsActiveHere())
                           and "active" or "idle"
            end
            statusLine("小隊冷卻", pcdState)

            -- PI Caller is being reworked and disabled in this build, so it's
            -- always Deactivated regardless of the read-only preview toggle.
            statusLine("灌注提醒", "deactivated")

            -- Smart Misdirect only works for Hunters / Rogues, so on any other
            -- class it's Deactivated (the feature can never do anything there),
            -- not merely Idle. Active when enabled on an eligible class.
            local smdState = "deactivated"
            if BIT.db and BIT.db.smartMdEnabled then
                local _, class = UnitClass("player")
                if class == "HUNTER" or class == "ROGUE" then
                    smdState = "active"
                end
            end
            statusLine("智慧誤導/嫁禍", smdState)

            -- Keystone List: Deactivated when switched off; otherwise Active
            -- when the list is on screen, or Hidden when enabled but not shown
            -- right now (e.g. inside an active dungeon run, or no keys to list).
            local keyState = "deactivated"
            if BIT.db and BIT.db.keystoneListEnabled then
                keyState = (BIT.KeystoneList and BIT.KeystoneList.IsShown
                            and BIT.KeystoneList:IsShown()) and "active" or "hidden"
            end
            statusLine("鑰石清單", keyState)

            -- Group roster: who is broadcasting spec data (LibSpec).
            -- Members without it fall back to role/cache inference for
            -- spec-gated Party CDs, so seeing who sends is genuinely
            -- useful. PARTY ONLY: raids are excluded (too many rows,
            -- and the party-CD features are 5-man focused anyway).
            if IsInGroup and IsInGroup() and not (IsInRaid and IsInRaid()) then
                tt:AddLine(" ")
                tt:AddLine("隊伍成員 (LibSpec)", 0.9, 0.9, 0.9)
                for _, unit in ipairs({ "player", "party1", "party2", "party3", "party4" }) do
                    if UnitExists(unit) then
                        local name = UnitName(unit)
                        if type(name) == "string" and name ~= "" then
                            local short = name:match("^([^%-]+)") or name
                            local _, cls = UnitClass(unit)
                            local cc = cls and RAID_CLASS_COLORS and RAID_CLASS_COLORS[cls]
                            local colored = (cc and cc.colorStr)
                                and ("|c" .. cc.colorStr .. short .. "|r") or short
                            local has
                            if unit == "player" then
                                has = true   -- we embed the library ourselves
                            else
                                local u = BIT.SyncCD and BIT.SyncCD.users
                                          and BIT.SyncCD.users[short]
                                has = (u and u._hasLibSpec) and true or false
                            end
                            if has then
                                tt:AddDoubleLine(colored, "是", 1, 1, 1, 0.30, 1.00, 0.30)
                            else
                                tt:AddDoubleLine(colored, "否", 1, 1, 1, 1.00, 0.35, 0.35)
                            end
                        end
                    end
                end
            end

            tt:AddLine(" ")
            tt:AddLine("|cFFFFD700左鍵|r  開啟設定", 0.8, 0.8, 0.8)
            tt:AddLine("|cFFFFD700右鍵|r  開關所有框架的移動模式", 0.8, 0.8, 0.8)
            tt:AddLine("|cFFFFD700Shift+左鍵|r  切換測試模式", 0.8, 0.8, 0.8)
            tt:AddLine("|cFFFFD700拖曳|r  移動按鈕", 0.8, 0.8, 0.8)
        end,
    })

    -- Initialize the SavedVariable DB for icon position/visibility
    if not BliZziInterruptsMinimapDB then
        BliZziInterruptsMinimapDB = {}
    end

    -- Migrate old position if user had the custom minimap button before
    if BIT.db.minimapPos and not BliZziInterruptsMinimapDB.minimapPos then
        BliZziInterruptsMinimapDB.minimapPos = BIT.db.minimapPos
    end
    if BIT.db.minimapButton == false and BliZziInterruptsMinimapDB.hide == nil then
        BliZziInterruptsMinimapDB.hide = true
    end

    -- Register with LibDBIcon — handles positioning, dragging, border, background
    ldbi:Register("BliZziInterrupts", dataObj, BliZziInterruptsMinimapDB)

    self.minimapBtn = ldbi:GetMinimapButton("BliZziInterrupts")
end
------------------------------------------------------------
-- One-time "Interrupt tracker reworked" notice
--
-- Shown on login / reload to anyone who hasn't ticked "I understand".
-- The acknowledgment lives ACCOUNT-WIDE in BliZziInterruptsSavedVars,
-- so it only needs to be confirmed once per account. Closing the popup
-- WITHOUT ticking the box leaves the flag unset → it returns on the
-- next login / reload, until the box is ticked. Purpose: stop updating
-- users from thinking the changed interrupt display is a bug.
------------------------------------------------------------
function BIT.SettingsUI:ShowReworkNotice()
    if _G["BIT_ReworkNotice"] then _G["BIT_ReworkNotice"]:Show(); return end

    local W = 460
    local pop = CreateFrame("Frame", "BIT_ReworkNotice", UIParent, "BackdropTemplate")
    pop:SetFrameStrata("DIALOG")
    pop:SetFrameLevel(330)
    pop:SetPoint("CENTER")
    pop:SetBackdrop({
        bgFile   = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    pop:SetBackdropColor(0.10, 0.10, 0.12, 0.9)  -- slightly transparent panel
    pop:SetBackdropBorderColor(RGB(BORDER))
    pop:EnableMouse(true)
    pop:SetMovable(true)
    pop:RegisterForDrag("LeftButton")
    pop:SetScript("OnDragStart", pop.StartMoving)
    pop:SetScript("OnDragStop", pop.StopMovingOrSizing)

    local titleFs = pop:CreateFontString(nil, "OVERLAY")
    ApplyFont(titleFs, 14, "OUTLINE")
    titleFs:SetPoint("TOPLEFT", 16, -14)
    titleFs:SetTextColor(0.5, 0.8, 1.0)
    titleFs:SetText(LS("REWORK_TITLE", "斷法追蹤器已重製"))

    local bodyFs = pop:CreateFontString(nil, "OVERLAY")
    ApplyFont(bodyFs, 12)
    bodyFs:SetPoint("TOPLEFT", 16, -40)
    bodyFs:SetWidth(W - 32)
    bodyFs:SetJustifyH("LEFT")
    bodyFs:SetJustifyV("TOP")
    bodyFs:SetTextColor(RGB(TEXT))
    bodyFs:SetWordWrap(true)
    bodyFs:SetText(LS("REWORK_BODY",
        "自至暗之夜上線以來，我一直試著把斷法追蹤器做到完美。但其他玩家的斷法根本無法 100% 可靠地追蹤——遊戲不會向插件公開這些資料。\n\n所以現在改為：不再顯示舊的計量條，而是顯示最近斷法的歷史紀錄（誰打斷了哪個法術）。你自己的斷法條仍然顯示真實的冷卻時間。\n\n這是刻意設計，不是錯誤。勾選下方選項後此提示將不再顯示。"))

    local bodyH = bodyFs:GetStringHeight()
    pop:SetSize(W, math.max(210, 120 + bodyH))

    -- "I understand" checkbox (custom, themed). Ticking stores the
    -- account-wide ack immediately; un-ticking clears it again.
    local function acked()
        return (BliZziInterruptsSavedVars and BliZziInterruptsSavedVars.interruptReworkAck) and true or false
    end
    local box = CreateFrame("Button", nil, pop, "BackdropTemplate")
    box:SetSize(18, 18)
    box:SetPoint("BOTTOMLEFT", 16, 48)  -- own row above the Close button
    MakeBg(box, 0.15, 0.15, 0.18, 1)
    local checkTex = box:CreateTexture(nil, "OVERLAY")
    checkTex:SetPoint("CENTER")
    checkTex:SetSize(10, 10)
    checkTex:SetColorTexture(RGB(ACCENT))
    checkTex:SetShown(acked())
    box:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
    box:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
    box:SetScript("OnClick", function()
        if not BliZziInterruptsSavedVars then BliZziInterruptsSavedVars = {} end
        local newState = not acked()
        BliZziInterruptsSavedVars.interruptReworkAck = newState or nil
        checkTex:SetShown(newState)
    end)

    local ackLbl = pop:CreateFontString(nil, "OVERLAY")
    ApplyFont(ackLbl, 12)
    ackLbl:SetPoint("LEFT", box, "RIGHT", 6, 0)
    ackLbl:SetTextColor(RGB(TEXT))
    ackLbl:SetText(LS("REWORK_ACK", "點擊此處，此提示將不再顯示"))
    -- clicking the label toggles the box too
    local lblBtn = CreateFrame("Button", nil, pop)
    lblBtn:SetPoint("TOPLEFT", ackLbl, "TOPLEFT", -2, 2)
    lblBtn:SetPoint("BOTTOMRIGHT", ackLbl, "BOTTOMRIGHT", 2, -2)
    lblBtn:SetScript("OnClick", function() box:Click() end)

    -- Close button — just hides; the ack flag decides whether it returns.
    local closeBtn = CreateFrame("Button", nil, pop, "BackdropTemplate")
    closeBtn:SetSize(120, 26)
    closeBtn:SetPoint("BOTTOMRIGHT", -16, 12)
    MakeBg(closeBtn, 0.15, 0.15, 0.18, 1)
    local cT = closeBtn:CreateFontString(nil, "OVERLAY")
    ApplyFont(cT, 12)
    cT:SetPoint("CENTER")
    cT:SetTextColor(RGB(ACCENT))
    cT:SetText(LS("REWORK_CLOSE", CLOSE))
    closeBtn:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(RGB(ACCENT)) end)
    closeBtn:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(RGB(BORDER)) end)
    closeBtn:SetScript("OnClick", function() pop:Hide() end)

    pop:Show()
end

function BIT.SettingsUI:MaybeShowReworkNotice()
    if BliZziInterruptsSavedVars and BliZziInterruptsSavedVars.interruptReworkAck then return end
    self:ShowReworkNotice()
end
