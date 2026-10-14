--=====================================================================================
-- RGX-Framework | Options Panel Builder
-- Gives any addon a fully styled, tabbed options window in ~10 lines.
--
-- Usage:
--   local panel = RGX:GetUI():CreateOptionsPanel({
--       addonName = "MyAddon",      -- TOC addon name (for GetAddOnMetadata)
--       title     = "My Addon",     -- header title (color codes OK)
--       subtitle  = "Does cool stuff",
--       icon      = "Interface\\AddOns\\MyAddon\\icon.tga",
--       version   = nil,            -- auto-read from TOC if nil
--       author    = "Me",
--       website   = "https://realmgx.com",
--       closeButton = true,         -- standard window close button (hidden when embedded in Settings)
--       maxPerRow = 6,              -- tabs per row before wrapping
--       tabs = {
--           { text = "General", icon = "Interface\\Icons\\...", content = function(frame) ... end },
--           { text = "Sounds",  icon = "Interface\\Icons\\...", content = function(frame) ... end },
--       },
--   })
--
--   panel:Open()
--   panel:SelectTab(1)
--   panel:SelectTabByName("Sounds")
--   panel:InvalidateAllTabs()
--   panel:Refresh()
--=====================================================================================

local addonName, RGX = ...

-- This file extends the existing RGXUI module registered in controls.lua.
-- It waits until UI is available via the module system.
-- GetUI/GetDesign read _G directly: options.lua patches RGXUI after the module
-- registers itself, so RGX:GetUI() / RGX:GetDesign() are equivalent but the
-- _G read makes the bootstrap dependency explicit and avoids a forward reference.

local function GetUI()
    return _G.RGXUI
end

local function GetDesign()
    return _G.RGXDesign
end

-- Apply the framework default font (Blizzard-compatible) to panel header text
local function ApplyDefaultFont(fs)
    local Fonts = _G.RGXFonts
    if not (Fonts and type(Fonts.Apply) == "function" and type(Fonts.GetDefault) == "function") then return end
    if not (fs and fs.GetFont) then return end
    local _, size, flags = fs:GetFont()
    pcall(Fonts.Apply, Fonts, fs, Fonts:GetDefault(), size, flags)
end

-- ── Layout constants ──────────────────────────────────────────────────────────

local TAB_W = 94
local TAB_H        = 22
local TAB_SPACING  = 6
local TAB_ROW_PAD  = 8
local TAB_ROW_GAP  = 3
local TAB_AREA_GAP = 2
local HEADER_H     = 64

-- ── TOC metadata helper ───────────────────────────────────────────────────────

local function GetMeta(name, key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, v = pcall(C_AddOns.GetAddOnMetadata, name, key)
        return ok and v or nil
    elseif GetAddOnMetadata then
        local ok, v = pcall(GetAddOnMetadata, name, key)
        return ok and v or nil
    end
end

-- ── Tab row math ──────────────────────────────────────────────────────────────

local function GetRowCount(tabs, maxPerRow)
    return math.ceil(#tabs / maxPerRow)
end

local function GetTabContainerHeight(rowCount)
    return TAB_ROW_PAD
        + rowCount * TAB_H
        + (rowCount - 1) * TAB_ROW_GAP
        + TAB_ROW_PAD
end

-- ── Create a single tab button ────────────────────────────────────────────────

local function GetTabPrimary(panelRef, D)
    local theme = panelRef.theme
    if type(theme) == "table" then
        local c = theme.primary or theme.highlight or theme.highlightColor or theme.themeColor
        if type(c) == "table" and type(c[1]) == "number" then
            return c[1], c[2] or 1, c[3] or 1
        end
    end
    return D:Unpack('primary')
end

local function GetTabAccent(panelRef, D)
    local theme = panelRef.theme
    if type(theme) == "table" then
        local c = theme.accent or theme.secondary or theme.secondaryHighlight
        if type(c) == "table" and type(c[1]) == "number" then
            return c[1], c[2] or 1, c[3] or 1
        end
    end
    return D:Unpack('accent')
end

-- The header line stays primary unless the panel theme opts in with
-- accentHeader: existing consumers keep the chrome they already had.
local function GetHeaderLineColor(panelRef, D)
    local theme = panelRef.theme
    if type(theme) == "table" and theme.accentHeader then
        return GetTabAccent(panelRef, D)
    end
    return GetTabPrimary(panelRef, D)
end

local function CreateTabButton(parent, text, tabIndex, row, col, panelRef, icon, addonKey)
    local D = GetDesign()
    local sr, sg, sb = D:Unpack("surface")
    local frameName = "RGXTab_" .. addonKey .. "_" .. tabIndex
    local btn = CreateFrame("Button", frameName, parent)
    btn:SetSize(TAB_W, TAB_H)
    btn.tabIndex = tabIndex
    btn.tabRow   = row
    btn.tabCol   = col
    -- Positioning is handled externally by RepositionTabs for dynamic centering.

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(sr, sg, sb, 0.90)
    btn.bg = bg

    local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    border:SetBackdropBorderColor(D:Unpack("border"))
    btn.border = border

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ApplyDefaultFont(btnText)
    if icon then
        local iconTex = btn:CreateTexture(nil, "ARTWORK")
        iconTex:SetSize(14, 14)
        iconTex:SetPoint("LEFT", 8, 0)
        iconTex:SetTexture(icon)
        btn.iconTex = iconTex
        btnText:SetPoint("LEFT", iconTex, "RIGHT", 4, 0)
        btnText:SetPoint("RIGHT", -4, 0)
        btnText:SetJustifyH("LEFT")
    else
        btnText:SetPoint("CENTER", 0, 0)
    end
    btnText:SetText(text)
    btnText:SetTextColor(D:Unpack("subtext"))
    btn.text = btnText

    btn:SetScript("OnClick", function()
        panelRef:SelectTab(tabIndex)
    end)

    btn:SetScript("OnEnter", function(self)
        if not self.isActive then
            local D = GetDesign()
            local pr, pg, pb = GetTabPrimary(panelRef, D)
            self.border:SetBackdropBorderColor(pr, pg, pb)
            self.text:SetTextColor(pr, pg, pb)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if not self.isActive then
            local D = GetDesign()
            self.border:SetBackdropBorderColor(D:Unpack("border"))
            self.text:SetTextColor(D:Unpack("subtext"))
        end
    end)

    function btn:SetActive(active)
        self.isActive = active
        if active then
            local D = GetDesign()
            self.bg:SetColorTexture(D:Unpack("hover"))
            local pr, pg, pb = GetTabPrimary(panelRef, D)
            self.border:SetBackdropBorderColor(pr, pg, pb)
            self.text:SetTextColor(pr, pg, pb)
            if self.iconTex then self.iconTex:SetDesaturated(false); self.iconTex:SetAlpha(1) end
        else
            local D = GetDesign()
            local sr, sg, sb = D:Unpack("surface")
            self.bg:SetColorTexture(sr, sg, sb, 0.90)
            self.border:SetBackdropBorderColor(D:Unpack("border"))
            self.text:SetTextColor(D:Unpack("subtext"))
            if self.iconTex then self.iconTex:SetDesaturated(false); self.iconTex:SetAlpha(0.90) end
        end
    end

    return btn
end

-- ── Auto-layout helper (passed to tab content functions) ─────────────────────
-- Widgets stack vertically through the framework's scroll page + flow layout:
-- rows are positioned and clipped by the framework, so authors never call
-- SetPoint for routine content and tall pages scroll instead of overflowing.
--
-- Usage inside a tab content function:
--   content = function(add)
--       add:Toggle("Enable",  db, "enabled")
--       add:Slider("Volume",  db, "volume",  0, 100)
--       add:Color("Bar Color", db, "barColor")
--   end

local function CreateAddHelper(frame)
    -- The helper frame stays a valid WoW frame: callers may parent manual
    -- widgets to it directly. Managed controls land in the scroll canvas.
    local UI = GetUI()
    frame._frame = frame

    if not (UI and UI.CreateScrollPage and UI.CreateFlowLayout) then
        return frame
    end

    local canvas = UI:CreateScrollPage(frame)
    local flow = UI:CreateFlowLayout(canvas)

    frame._rgxCanvas = canvas
    frame._rgxFlow = flow

    local function Add(w)
        if w then flow:Add(w) end
        return w
    end

    function frame:Toggle(label, storage, key, default, onChange)
        local w = UI:CreateToggle(canvas, {
            label    = label,
            storage  = storage,
            key      = key,
            default  = default ~= false,
            onChange = onChange,
        })
        Add(w)
        return w
    end

    function frame:Slider(label, storage, key, min, max, default, suffix)
        local w = UI:CreateSlider(canvas, {
            label   = label,
            storage = storage,
            key     = key,
            min     = min or 0,
            max     = max or 100,
            step    = 1,
            default = default,
            suffix  = suffix or "",
        })
        Add(w)
        return w
    end

    function frame:Color(label, storage, key, default)
        local w = UI:CreateColorPicker(canvas, {
            label   = label,
            storage = storage,
            key     = key,
            default = default or { r = 1, g = 1, b = 1 },
        })
        Add(w)
        return w
    end

    function frame:Section(title)
        local w = UI:CreateLabel(canvas, { text = title, size = "normal", color = "accent" })
        Add(w)
        return w
    end

    function frame:Text(text)
        local w = UI:CreateLabel(canvas, { text = text, size = "small", color = "muted", wrap = true })
        Add(w)
        return w
    end

    return frame
end

-- ── Build the full content area ───────────────────────────────────────────────

local function ClearContent(frame)
    for _, child in ipairs({frame:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    for _, region in ipairs({frame:GetRegions()}) do
        region:Hide()
    end
    frame.Refresh = nil
end

-- ── Declarative options compositor (private addon-factory seam) ───────────────
-- Core validates declarations and owns lifecycle/storage. UI owns widget
-- construction and layout; resolveControl preserves the existing string grammar
-- and live table-list behavior without creating a second interpreter here.
local function BuildAddonOptionTabs(UI, addon, options, columns, resolveControl)
    local Drops = RGX:GetDropdowns()
    local tabs = {}
    for tabName, controls in pairs(options) do
        tabs[#tabs + 1] = {
            text = tabName,
            content = function(frame)
                local canvas = UI:CreateScrollPage(frame)
                local hosts, flows
                if columns > 1 and UI.CreateColumns then
                    hosts = { UI:CreateColumns(canvas, columns) }
                    flows = {}
                    for _, host in ipairs(hosts) do
                        flows[#flows + 1] = UI:CreateFlowLayout(host)
                    end
                else
                    hosts = { canvas }
                    flows = { UI:CreateFlowLayout(canvas) }
                end
                local perColumn, remainder = math.floor(#controls / #flows), #controls % #flows
                local boundaries, start = {}, 1
                for i = 1, #flows do
                    local size = perColumn + (i <= remainder and 1 or 0)
                    boundaries[i] = { start = start, stop = start + size - 1 }
                    start = start + size
                end
                local index = 0
                for _, rawControl in ipairs(controls) do
                    index = index + 1
                    local slot = #flows
                    for i = 1, #flows do
                        if index <= boundaries[i].stop then slot = i break end
                    end
                    local host, flow = hosts[slot], flows[slot]
                    local ctrl = resolveControl(rawControl)
                    if ctrl and type(ctrl) == "table" then
                        local w
                        if type(ctrl.toggle) == "string" then
                            w = UI:CreateToggle(host, { key = ctrl.toggle, label = ctrl.label or ctrl.toggle:gsub("^%l", string.upper), storage = addon.db, default = ctrl.default })
                        elseif type(ctrl.slider) == "string" then
                            w = UI:CreateSlider(host, { key = ctrl.slider, label = ctrl.label or ctrl.slider:gsub("^%l", string.upper), storage = addon.db, min = ctrl.min or 0, max = ctrl.max or 100, step = ctrl.step or 1, suffix = ctrl.suffix, progress = ctrl.progress, valueDisplay = ctrl.valueDisplay })
                        elseif type(ctrl.color) == "string" then
                            w = UI:CreateColorPicker(host, { key = ctrl.color, label = ctrl.label or ctrl.color:gsub("^%l", string.upper), storage = addon.db, default = ctrl.default or addon.db[ctrl.color], onChange = function(r, g, b) addon.db[ctrl.color] = { r = r, g = g, b = b } end })
                        elseif type(ctrl.font) == "string" then
                            local Fonts = RGX:GetFonts()
                            if Fonts and Fonts.AttachFontSelector then
                                w = Fonts:AttachFontSelector(host, addon.db, ctrl.font, { label = ctrl.label or "Font" })
                                if w and w.HookScript then
                                    w:HookScript("OnShow", function() w:RefreshFromDB() end)
                                end
                            end
                        elseif type(ctrl.dropdown) == "string" and Drops then
                            local items = {}
                            for _, v in ipairs(ctrl.items or {}) do items[#items + 1] = { text = tostring(v), value = v } end
                            w = Drops:CreateNestedDropdown(host, { label = ctrl.label or ctrl.dropdown:gsub("^%l", string.upper), items = items, width = ctrl.width or 260, value = addon.db[ctrl.dropdown], onChange = function(v) addon.db[ctrl.dropdown] = v end })
                        elseif type(ctrl.button) == "string" and type(ctrl.action) == "function" then
                            w = UI:CreateButton(host, { text = ctrl.button, width = ctrl.width, height = ctrl.height, onClick = ctrl.action })
                        elseif type(ctrl.section) == "string" then
                            w = UI:CreateLabel(host, { text = ctrl.section, size = "normal", color = "accent" })
                        end
                        if w then flow:Add(w) end
                    end
                end
                local function reflow()
                    if canvas:GetWidth() <= 0 then return end
                    local used = 0
                    for _, flow in ipairs(flows) do used = math.max(used, flow:Apply()) end
                    canvas:SetHeight(math.max(1, used))
                end
                reflow()
                canvas:HookScript("OnShow", reflow)
                canvas:HookScript("OnSizeChanged", reflow)
            end,
        }
    end
    return tabs
end

-- ── CreateOptionsPanel ────────────────────────────────────────────────────────

local _panelCounter = 0

local function CreateOptionsPanel(UI, opts)
    opts = opts or {}
    local D = GetDesign()
    -- Apply the requested theme for the build, then restore the previous
    -- global theme so addons do not leak theme colors into later panels.
    -- Tab buttons honor panel.theme at runtime via GetTabPrimary.
    local _prevPrimary = D and D.Theme and D.Theme.primary
    local _prevAccent  = D and D.Theme and D.Theme.accent
    if D and type(D.SetTheme) == "function" then
        D:SetTheme(opts.theme or opts.colors or opts)
    end
    local sr, sg, sb = D:Unpack("surface")
    local br, bg, bb = D:Unpack("background")

    local tAddonName = opts.addonName or addonName
    local tabs       = opts.tabs or {}
    local singlePage = #tabs == 0 and type(opts.content) == "function"
    if singlePage then
        -- Reuse the existing lazy content lifecycle without drawing a tab row.
        tabs = { { text = "", content = opts.content } }
    end
    local maxPerRow  = opts.maxPerRow or 6

    _panelCounter = _panelCounter + 1
    local addonKey = tAddonName:gsub("[^%w]", "_") .. "_" .. _panelCounter

    -- ── Panel frame ───────────────────────────────────────────────────────────
    local panel = CreateFrame("Frame", "RGXOptionsPanel_" .. addonKey, UIParent, "BackdropTemplate")
    panel:SetSize(opts.width or 760, opts.height or 632)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("DIALOG")
    panel:EnableMouse(true)
    local _sidebarIcon  = opts.icon or GetMeta(tAddonName, "IconTexture")
    local _sidebarTitle = opts.sidebarTitle or opts.title or tAddonName
    local _sidebarName  = _sidebarIcon
        and format("|T%s:16:16:0:0|t %s", _sidebarIcon, _sidebarTitle)
        or  _sidebarTitle
    panel.name = _sidebarName
    panel.settingsCategoryName = _sidebarName
    panel.tabs     = {}
    panel.contents = {}
    panel.theme    = opts.theme or opts.colors

    -- Outer container
    local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    container:SetAllPoints()
    container:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = {left=1, right=1, top=1, bottom=1},
    })
    container:SetBackdropColor(sr, sg, sb, 0.95)
    container:SetBackdropBorderColor(D:Unpack("border"))

    -- ── Header ────────────────────────────────────────────────────────────────
    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetHeight(HEADER_H)
    header:SetPoint("TOPLEFT",  8, -8)
    header:SetPoint("TOPRIGHT", -8, -8)
    header:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = {left=1, right=1, top=1, bottom=1},
    })
    header:SetBackdropColor(sr, sg, sb, 0.95)
    header:SetBackdropBorderColor(D:Unpack("border"))

    -- Accent line along header bottom
    local accent = header:CreateTexture(nil, "ARTWORK")
    accent:SetHeight(2)
    accent:SetPoint("BOTTOMLEFT",  8, 0)
    accent:SetPoint("BOTTOMRIGHT", -8, 0)
    accent:SetColorTexture(GetHeaderLineColor(panel, D))
    panel._accentLine = accent

    -- Icon
    if opts.icon then
        local logo = header:CreateTexture(nil, "ARTWORK")
        logo:SetSize(42, 42)
        logo:SetPoint("LEFT", 11, 0)
        logo:SetTexture(opts.icon)
    end

    local leftX  = opts.icon and 62 or 14
    local rightX = -14

    local titleStr = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleStr:SetPoint("LEFT", header, "TOPLEFT", leftX, -16)
    titleStr:SetJustifyV("MIDDLE")
    titleStr:SetText(opts.title or tAddonName)
    ApplyDefaultFont(titleStr)

    if opts.subtitle then
        local sub = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        sub:SetPoint("LEFT", header, "TOPLEFT", leftX, -30)
        sub:SetJustifyV("MIDDLE")
        sub:SetText(opts.subtitle)
        sub:SetTextColor(D:Unpack("subtext"))
        ApplyDefaultFont(sub)
    end

    if opts.website then
        local site = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        site:SetPoint("LEFT", header, "TOPLEFT", leftX, -44)
        site:SetJustifyV("MIDDLE")
        site:SetText(opts.website)
        site:SetTextColor(D:Unpack("text"))
        ApplyDefaultFont(site)
    end

    local verText = opts.version or GetMeta(tAddonName, "Version") or ""
    if verText ~= "" then
        if not verText:match("^v") then verText = "v" .. verText end
        local ver = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ver:SetPoint("RIGHT", header, "TOPRIGHT", rightX, -16)
        ver:SetJustifyV("MIDDLE")
        ver:SetText(verText)
        ver:SetJustifyH("RIGHT")
        ver:SetTextColor(D:Unpack("primary"))
        ApplyDefaultFont(ver)
        panel._versionText = ver
    end

    if opts.author then
        local auth = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        auth:SetPoint("RIGHT", header, "TOPRIGHT", rightX, -30)
        auth:SetJustifyV("MIDDLE")
        auth:SetText("by " .. opts.author)
        auth:SetTextColor(D:Unpack("subtext"))
        auth:SetJustifyH("RIGHT")
        ApplyDefaultFont(auth)
    end

    if opts.brand then
        local brand = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        brand:SetPoint("RIGHT", header, "TOPRIGHT", rightX, -44)
        brand:SetJustifyV("MIDDLE")
        brand:SetText(opts.brand)
        brand:SetJustifyH("RIGHT")
        ApplyDefaultFont(brand)
    end

    -- ── Close button ─────────────────────────────────────────────────────
    -- The panel uses the shared framework close-button factory so consumers
    -- see one chrome primitive everywhere. Hidden while the panel is hosted
    -- inside the Settings canvas (which owns its own chrome; hiding the
    -- canvas child would blank the category). opts.closeButton == false
    -- skips it.
    local closeBtn
    if opts.closeButton ~= false then
        closeBtn = GetUI():CreateCloseButton(panel, {
            onClick = function()
                if not panel._settingsEmbedded then panel:Hide() end
            end,
        })
        panel.closeButton = closeBtn
    end

    -- ── Banner (optional, sits between header and tabs) ───────────────────────
    local tabAnchor = header  -- tabs anchor to this; swapped to banner when present

    if opts.bannerHeight and opts.bannerHeight > 0 then
        -- The banner is a plain content area on the panel surface, not a
        -- second card: the panel container already provides the backdrop,
        -- so a boxed frame here renders as extra chrome around consumer
        -- content (reported around a consumer's nameplate preview).
        local bannerFrame = CreateFrame("Frame", nil, container)
        bannerFrame:SetHeight(opts.bannerHeight)
        bannerFrame:SetPoint("TOPLEFT",  header, "BOTTOMLEFT",  0, -2)
        bannerFrame:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -2)
        -- Divider along the banner's bottom: separates banner content
        -- (e.g. the preview's type buttons) from the tab row below.
        local bannerDivider = bannerFrame:CreateTexture(nil, "ARTWORK")
        bannerDivider:SetHeight(2)
        bannerDivider:SetPoint("BOTTOMLEFT",  bannerFrame, "BOTTOMLEFT",  0, 0)
        bannerDivider:SetPoint("BOTTOMRIGHT", bannerFrame, "BOTTOMRIGHT", 0, 0)
        bannerDivider:SetColorTexture(D:Unpack("border"))
        bannerFrame.divider = bannerDivider
        bannerFrame.dividerGap = TAB_AREA_GAP + TAB_ROW_PAD
        panel.bannerFrame = bannerFrame
        tabAnchor = bannerFrame
    end

    -- ── Tab container ─────────────────────────────────────────────────────────
    local rowCount      = GetRowCount(tabs, maxPerRow)
    local tabAreaHeight = singlePage and 0 or GetTabContainerHeight(rowCount)

    local tabArea = CreateFrame("Frame", nil, container)
    tabArea:SetPoint("TOPLEFT",  tabAnchor, "BOTTOMLEFT",  0, -TAB_AREA_GAP)
    tabArea:SetPoint("TOPRIGHT", tabAnchor, "BOTTOMRIGHT", 0, -TAB_AREA_GAP)
    tabArea:SetHeight(tabAreaHeight)

    local tabBg = tabArea:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints()
    tabBg:SetColorTexture(br, bg, bb, 0.60)
    if singlePage then tabBg:Hide() end

    -- ── Build tabs and content frames ─────────────────────────────────────────
    for i, tabInfo in ipairs(tabs) do
        local row = math.ceil(i / maxPerRow)
        local col = ((i - 1) % maxPerRow) + 1

        local tabBtn = CreateTabButton(
            tabArea, tabInfo.text, i, row, col, panel, tabInfo.icon, addonKey
        )
        panel.tabs[i] = tabBtn
        if singlePage then tabBtn:Hide() end

        -- Content frame for this tab
        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT",     tabArea, "BOTTOMLEFT",          1, -2)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT",      -7,  8)
        content:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = {left=1, right=1, top=1, bottom=1},
        })
        content:SetBackdropColor(br, bg, bb, 0.95)
        content:SetBackdropBorderColor(D:Unpack("border"))
        content:Hide()

        panel.contents[i] = content
        panel.tabs[i]._tabInfo = tabInfo
    end

    -- ── Dynamic centered tab positioning ─────────────────────────────────────
    -- Group buttons by row, then center each row within the tab area width.
    local rowGroups = {}
    for _, btn in ipairs(panel.tabs) do
        local r = btn.tabRow
        rowGroups[r] = rowGroups[r] or {}
        table.insert(rowGroups[r], btn)
    end

    local function RepositionTabs()
        local w = tabArea:GetWidth()
        if w <= 0 then return end
        for row, btns in pairs(rowGroups) do
            local count    = #btns
            local rowWidth = count * TAB_W + (count - 1) * TAB_SPACING
            local startX   = math.floor((w - rowWidth) / 2 + 0.5)
            local yOff     = -(TAB_ROW_PAD + (row - 1) * (TAB_H + TAB_ROW_GAP))
            for idx, btn in ipairs(btns) do
                local xOff = startX + (idx - 1) * (TAB_W + TAB_SPACING)
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", tabArea, "TOPLEFT", xOff, yOff)
            end
        end
    end

    tabArea:HookScript("OnSizeChanged", RepositionTabs)
    tabArea:HookScript("OnShow",        RepositionTabs)
    RepositionTabs()

    function panel:AddTab(tabInfo)
        local i = #self.tabs + 1
        local row = math.ceil(i / maxPerRow)
        local col = ((i - 1) % maxPerRow) + 1

        local tabBtn = CreateTabButton(
            tabArea, tabInfo.text, i, row, col, panel, tabInfo.icon, addonKey
        )
        self.tabs[i] = tabBtn
        self.tabs[i]._tabInfo = tabInfo

        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT",     tabArea, "BOTTOMLEFT",          1, -2)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT",      -7,  8)
        content:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = {left=1, right=1, top=1, bottom=1},
        })
        content:SetBackdropColor(br, bg, bb, 0.95)
        content:SetBackdropBorderColor(D:Unpack("border"))
        content:Hide()
        self.contents[i] = content

        rowGroups[row] = rowGroups[row] or {}
        table.insert(rowGroups[row], tabBtn)

        local rowCount = GetRowCount(self.tabs, maxPerRow)
        tabArea:SetHeight(GetTabContainerHeight(rowCount))

        RepositionTabs()
        return i
    end

local function RunSoon(delay, fn)
  -- Prefer RGX timer API for framework budget/diagnostics
  if RGX and type(RGX.After) == "function" then
    RGX:After(delay or 0, fn, "Options:RunSoon")
  elseif C_Timer and type(C_Timer.After) == "function" then
    C_Timer.After(delay or 0, fn)
  else
    fn()
  end
end

    -- Run a build/refresh callback under the panel's own theme, then restore
    -- the shared global theme so later panels/addons are unaffected. Falls
    -- back to a direct call when the panel carries no theme. Content callbacks
    -- keep their own pcall isolation; this only scopes the color surface.
    local function withPanelTheme(fn)
        if type(panel.theme) == "table" then
            D:WithTheme(panel.theme, fn)
        else
            fn()
        end
    end

    local bannerQueued = false

    local function BuildBanner()
        if panel._bannerBuilt then
            return
        end

        panel._bannerBuilt = true
        if panel.bannerFrame and type(opts.banner) == "function" then
            withPanelTheme(function()
                local ok, err = pcall(opts.banner, panel.bannerFrame)
                if not ok then RGX:Debug("[RGXOptions] Banner build error: " .. tostring(err)) end
            end)
        end
    end

    local function QueueBannerBuild()
        if panel._bannerBuilt or bannerQueued then
            return
        end

        bannerQueued = true
        RunSoon(opts.bannerDelay or 0.05, function()
            bannerQueued = false
            if panel:IsShown() then
                BuildBanner()
            end
        end)
    end

    -- ── SelectTab ─────────────────────────────────────────────────────────────
    -- Flow content lands in _rgxCanvas when the helper is used; after every
    -- build or refresh, pack the rows and size the scroll child to the used
    -- height so long pages scroll and short ones fit.
    local function ReflowScrollContent(content)
        local flow = content._rgxFlow
        local canvas = content._rgxCanvas
        if not flow or not canvas then return end
        local ok = pcall(function()
            local used = flow:Apply()
            canvas:SetHeight(math.max(1, used))
        end)
    end

    function panel:SelectTab(index)
        QueueBannerBuild()
        -- A color popup belongs to the page that opened it.
        RGX:DismissColorPicker()

        for i = 1, #self.tabs do
            if self.tabs[i] then
                self.tabs[i]:SetActive(i == index)
            end
            if self.contents[i] then
                self.contents[i]:SetShown(i == index)
                if i == index then
                    local content = self.contents[i]
                    local tabInfo = self.tabs[i] and self.tabs[i]._tabInfo
                    if not content._built or content._dirty then
                        withPanelTheme(function()
                            if content._dirty then
                                ClearContent(content)
                                content._dirty = nil
                            end
                            if tabInfo and type(tabInfo.content) == "function" then
                                local ok, err = pcall(tabInfo.content, CreateAddHelper(content))
                                if ok then
                                    content._built = true
                                else
                                    RGX:Error("[RGXOptions] " .. tostring(tabInfo.text) .. " tab build failed: " .. tostring(err))
                                    ClearContent(content)
                                end
                            else
                                content._built = true
                            end
                            ReflowScrollContent(content)
                        end)
                    elseif type(content.Refresh) == "function" then
                        withPanelTheme(function()
                            pcall(content.Refresh, content)
                            ReflowScrollContent(content)
                        end)
                    end
                    if tabInfo and type(tabInfo.onSelect) == "function" then
                        pcall(tabInfo.onSelect)
                    end
                end
            end
        end
        self._activeTab = index
    end

    function panel:SelectTabByName(name)
        for i, tab in ipairs(self.tabs) do
            if tab.text and tab.text:GetText() == name then
                self:SelectTab(i)
                return
            end
        end
    end

    -- A consumer may show a preview-selected subpage inside the current tab.
    -- Keep its content visible while clearing the tab-row active state.
    function panel:ClearTabHighlight()
        for _, tab in ipairs(self.tabs) do tab:SetActive(false) end
    end

    function panel:InvalidateAllTabs()
        for _, content in ipairs(self.contents) do
            content._dirty = true
        end
    end

    function panel:Refresh()
        QueueBannerBuild()

        withPanelTheme(function()
            for i, content in ipairs(self.contents) do
                if content:IsShown() then
                    if content._dirty then
                        local tabInfo = self.tabs[i] and self.tabs[i]._tabInfo
                        if tabInfo then
                            ClearContent(content)
                            content._dirty = nil
                            if type(tabInfo.content) == "function" then
                                local ok = pcall(tabInfo.content, CreateAddHelper(content))
                                content._built = ok == true
                                if not ok then ClearContent(content) end
                            end
                        end
                    elseif type(content.Refresh) == "function" then
                        pcall(content.Refresh, content)
                    end
                    ReflowScrollContent(content)
                end
            end
        end)
    end

    -- Apply a theme at runtime and repaint the panel's own chrome without
    -- leaking it into the shared global theme: the theme is scoped (save/apply/
    -- restore) exactly like construction, then the accent line (accent color
    -- only when the theme opts in with accentHeader, else primary), version
    -- label and tab styling (primary color) are re-derived from the panel's
    -- normalized theme. Bound color controls repaint through their own
    -- Refresh; content rebuilds pick up the theme through withPanelTheme.
    function panel:SetTheme(theme)
        if not D then return end
        local prevPrimary = D.Theme.primary
        local prevAccent  = D.Theme.accent
        D:SetTheme(theme)
        self.theme = { primary = D.Theme.primary, accent = D.Theme.accent }
        if type(theme) == "table" and theme.accentHeader then
            self.theme.accentHeader = true
        end
        D.Theme.primary = prevPrimary
        D.Theme.accent  = prevAccent

        local pr, pg, pb = GetTabPrimary(self, D)
        if self._versionText then self._versionText:SetTextColor(pr, pg, pb) end
        if self._accentLine then self._accentLine:SetColorTexture(GetHeaderLineColor(self, D)) end

        local active = self._activeTab or -1
        for i, tab in ipairs(self.tabs) do
            if tab and type(tab.SetActive) == "function" then
                tab:SetActive(i == active)
            end
        end
    end

    local function ExtractCategoryID(category)
        if type(category) ~= "table" then
            return nil
        end

        if type(category.GetID) == "function" then
            local ok, id = pcall(category.GetID, category)
            if ok and type(id) == "number" then
                return id
            end
        end

        if type(category.ID) == "number" then
            return category.ID
        end

        if type(category.GetOrder) == "function" then
            local ok, id = pcall(category.GetOrder, category)
            if ok and type(id) == "number" then
                return id
            end
        end
    end

    function panel:ResolveCategoryID()
        if self._categoryID ~= nil then
            return self._categoryID
        end

        local directID = ExtractCategoryID(self._category)
        if directID ~= nil then
            self._categoryID = directID
            return directID
        end

        if Settings and type(Settings.GetCategory) == "function" then
            local names = {
                self.settingsCategoryName,
                self.name,
                opts.categoryName,
                opts.title,
                tAddonName,
            }

            for _, categoryName in ipairs(names) do
                if type(categoryName) == "string" and categoryName ~= "" then
                    local ok, category = pcall(Settings.GetCategory, categoryName)
                    if ok and category then
                        local id = ExtractCategoryID(category)
                        if id ~= nil then
                            self._category = self._category or category
                            self._categoryID = id
                            return id
                        end
                    end
                end
            end
        end
    end

    local function TryOpenToCategory(target)
        if not target or not Settings or type(Settings.OpenToCategory) ~= "function" then
            return false
        end

        local ok, result = pcall(Settings.OpenToCategory, target)

        -- Some client builds return nil even when the Settings panel opens.
        -- Treat only an explicit error/false as failure so we do not continue
        -- into protected Blizzard panel fallbacks after a successful open.
        return ok and result ~= false
    end

    local function TryLegacyOpen(settingsPanel)
        if type(InterfaceOptionsFrame_OpenToCategory) ~= "function" or not settingsPanel then
            return false
        end

        -- Blizzard's legacy path often needs two calls to select the category.
        local okFirst = pcall(InterfaceOptionsFrame_OpenToCategory, settingsPanel)
        local okSecond = pcall(InterfaceOptionsFrame_OpenToCategory, settingsPanel)
        return okFirst or okSecond
    end

local function DeferOptionsOpen(fn)
  -- Prefer RGX timer API for framework budget/diagnostics
  if RGX and type(RGX.After) == "function" then
    RGX:After(0, fn, "Options:DeferOptionsOpen")
  elseif C_Timer and type(C_Timer.After) == "function" then
    C_Timer.After(0, fn)
  else
    fn()
  end
end

    -- Visibility must include the host: a Settings page can remain shown
    -- internally even while the containing Settings window is hidden.
    function panel:Close()
        local host = self
        if self._settingsEmbedded then
            if SettingsPanel and SettingsPanel:IsShown() then host = SettingsPanel
            elseif InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown() then host = InterfaceOptionsFrame end
        end
        RGX:SafeHide(host)
    end

    function panel:Toggle()
        if self:IsVisible() then self:Close() else self:Open() end
    end

    -- ── Open ──────────────────────────────────────────────────────────────────
    function panel:Open()
        if InCombatLockdown and InCombatLockdown() then
            RGX:Debug("[RGXOptions] Options open queued until combat ends")
            if RGX and type(RGX.QueueForCombat) == "function" then
                return RGX:QueueForCombat(function()
                    return panel:Open()
                end)
            end
            return false
        end

        if opts.openInSettings ~= false and not self._rgxOpeningDeferred and not self._rgxOpeningNow then
            self._rgxOpeningDeferred = true
            DeferOptionsOpen(function()
                if self then
                    self._rgxOpeningDeferred = nil
                    self._rgxOpeningNow = true
                    self:Open()
                    self._rgxOpeningNow = nil
                end
            end)
            return true
        end

        local opened = false

        if opts.openInSettings ~= false then
            local categoryID = self:ResolveCategoryID()
            local categoryName = self.settingsCategoryName or self.name

            if Settings and type(Settings.OpenToCategory) == "function" and categoryID ~= nil then
                opened = TryOpenToCategory(categoryID)
            end

            if Settings and type(Settings.OpenToCategory) == "function" and not opened and categoryName then
                opened = TryOpenToCategory(categoryName)
            end

            if not (Settings and type(Settings.OpenToCategory) == "function") and not opened then
                opened = TryLegacyOpen(self)
            end

            if Settings and type(Settings.OpenToCategory) == "function" and not opened then
                RGX:Debug("[RGXOptions] Settings.OpenToCategory failed for", categoryName or categoryID)
                return false
            end
        end

        if not opened then
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            self:Show()
        end

        -- Track hosting so the close button can tell floating panels
        -- (safe to hide) from Settings-canvas hosting (canvas owns chrome).
        self._settingsEmbedded = opened and true or false
        if closeBtn then closeBtn:SetShown(not self._settingsEmbedded) end
    end

    panel:SetScript("OnShow", function(self)
        -- Settings-canvas hosting: Blizzard re-parents the category panel into
        -- its own canvas container. Fill it so the panel IS the canvas page;
        -- a fixed-size centered panel inside the canvas shows the container's
        -- own frame and background as a visible border around ours.
        local parent = self:GetParent()
        if parent and parent ~= UIParent and not self._settingsEmbedded then
            self._settingsEmbedded = true
            self:ClearAllPoints()
            self:SetAllPoints(parent)
            if closeBtn then closeBtn:Hide() end
        end
        if #self.tabs > 0 and not self._activeTab then
            local initialTab = opts.initialTab or 1
            local function selectInitialTab()
                if self:IsShown() and not self._activeTab then
                    self:SelectTab(initialTab)
                end
            end

            RunSoon(0, selectInitialTab)
        else
            QueueBannerBuild()
        end
    end)

    -- ── Register with WoW Settings ────────────────────────────────────────────
    if opts.registerInSettings == false then
        panel._category = panel
    elseif Settings and Settings.RegisterCanvasLayoutCategory then
        local cat = Settings.RegisterCanvasLayoutCategory(panel, panel.settingsCategoryName)
        Settings.RegisterAddOnCategory(cat)
        panel._category = cat
        panel._categoryID = ExtractCategoryID(cat)
    else
        -- Classic / pre-10.x
        panel.name = panel.settingsCategoryName
        if InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(panel)
        end
        panel._category = panel
    end

    -- Normalize and cache the panel's theme (accepting named or array colors)
    -- now that all tabs and chrome exist, so runtime SetTheme and tab styling
    -- have a canonical value before the global theme is restored below.
    if type(panel.theme) == "table" then
        panel:SetTheme(panel.theme)
    end

    panel:Hide()

    if type(UISpecialFrames) == "table" and panel.GetName and panel:GetName() then
        table.insert(UISpecialFrames, panel:GetName())
    end

    -- Restore the previous global theme (see save above).
    if _prevPrimary then D.Theme.primary = _prevPrimary end
    if _prevAccent  then D.Theme.accent  = _prevAccent  end

    return panel
end

-- ── Inject into RGXUI once it's available ────────────────────────────────────
-- controls.lua runs first and sets up RGXUI; this file extends it.

local function Inject()
    local UI = _G.RGXUI
    if not UI then return false end
    UI.CreateOptionsPanel = function(self, opts)
        return CreateOptionsPanel(self, opts)
    end
    UI._BuildAddonOptionTabs = BuildAddonOptionTabs
    return true
end

-- controls.lua loads before this file, so inject immediately in normal loads.
-- Keep an event-bus fallback for unusual load-order changes without creating
-- another raw event frame.
if not Inject() then
    RGX:RegisterEvent("ADDON_LOADED", function(_, name)
        if name == addonName and Inject() then
            RGX:UnregisterEvent("ADDON_LOADED", "RGX_UIOptionsInject")
        end
    end, "RGX_UIOptionsInject")
end
