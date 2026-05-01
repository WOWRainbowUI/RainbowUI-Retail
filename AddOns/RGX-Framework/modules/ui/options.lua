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
--       website   = "discord.gg/...",
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

-- ── Layout constants ──────────────────────────────────────────────────────────

local TAB_W = 94
local TAB_H        = 22
local TAB_SPACING  = 6
local TAB_ROW_PAD  = 8
local TAB_ROW_GAP  = 3
local HEADER_H     = 52

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

local function CreateTabButton(parent, text, tabIndex, row, col, panelRef, icon, addonKey)
    local frameName = "RGXTab_" .. addonKey .. "_" .. tabIndex
    local btn = CreateFrame("Button", frameName, parent)
    btn:SetSize(TAB_W, TAB_H)
    btn.tabIndex = tabIndex
    btn.tabRow   = row
    btn.tabCol   = col
    -- Positioning is handled externally by RepositionTabs for dynamic centering.

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.11, 0.15, 0.90)
    btn.bg = bg

    local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    border:SetAllPoints()
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    border:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
    btn.border = border

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
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
    btnText:SetTextColor(0.75, 0.75, 0.75, 1)
    btn.text = btnText

    btn:SetScript("OnClick", function()
        panelRef:SelectTab(tabIndex)
    end)

    btn:SetScript("OnEnter", function(self)
        if not self.isActive then
            local D = GetDesign()
            local pr, pg, pb = D and D:Unpack("primary") or 0.345, 0.745, 0.506
            self.border:SetBackdropBorderColor(pr, pg, pb, 1)
            self.text:SetTextColor(pr, pg, pb, 1)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if not self.isActive then
            self.border:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
            self.text:SetTextColor(0.75, 0.75, 0.75, 1)
        end
    end)

    function btn:SetActive(active)
        self.isActive = active
        if active then
            local D = GetDesign()
            local pr, pg, pb = D and D:Unpack("primary") or 0.345, 0.745, 0.506
            self.bg:SetColorTexture(0.11, 0.18, 0.24, 1)
            self.border:SetBackdropBorderColor(pr, pg, pb, 1)
            self.text:SetTextColor(pr, pg, pb, 1)
            if self.iconTex then self.iconTex:SetDesaturated(false); self.iconTex:SetAlpha(1) end
        else
            self.bg:SetColorTexture(0.08, 0.11, 0.15, 0.90)
            self.border:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)
            self.text:SetTextColor(0.75, 0.75, 0.75, 1)
            if self.iconTex then self.iconTex:SetDesaturated(false); self.iconTex:SetAlpha(0.90) end
        end
    end

    return btn
end

-- ── Auto-layout helper (passed to tab content functions) ─────────────────────
-- Widgets stack vertically so authors never need to call SetPoint.
--
-- Usage inside a tab content function:
--   content = function(add)
--       add:Toggle("Enable",  db, "enabled")
--       add:Slider("Volume",  db, "volume",  0, 100)
--       add:Color("Bar Color", db, "barColor")
--   end

local function CreateAddHelper(frame)
    local UI = GetUI()
    local yOff = 0
    local X    = 16
    local Y0   = 16
    local GAP  = 10

    local function Place(w)
        w:SetPoint("TOPLEFT", frame, "TOPLEFT", X, -(Y0 + yOff))
        yOff = yOff + w:GetHeight() + GAP
    end

    -- Extend the frame itself with helper methods so it remains a valid WoW
    -- frame (usable as a parent, CreateTexture target, etc.) while also
    -- supporting the auto-layout API.
    frame._frame = frame

    function frame:Toggle(label, storage, key, default, onChange)
        if not UI then return end
        local w = UI:CreateToggle(frame, {
            label    = label,
            storage  = storage,
            key      = key,
            default  = default ~= false,
            onChange = onChange,
        })
        Place(w)
        return w
    end

    function frame:Slider(label, storage, key, min, max, default, suffix)
        if not UI then return end
        local w = UI:CreateSlider(frame, {
            label   = label,
            storage = storage,
            key     = key,
            min     = min or 0,
            max     = max or 100,
            step    = 1,
            default = default,
            suffix  = suffix or "",
        })
        Place(w)
        return w
    end

    function frame:Color(label, storage, key, default)
        if not UI then return end
        local w = UI:CreateColorPicker(frame, {
            label   = label,
            storage = storage,
            key     = key,
            default = default or { r = 1, g = 1, b = 1 },
        })
        Place(w)
        return w
    end

    function frame:Section(title)
        if not UI then return end
        local w = UI:CreateLabel(frame, { text = title, size = "normal", color = "accent" })
        w:SetPoint("TOPLEFT", frame, "TOPLEFT", X, -(Y0 + yOff))
        yOff = yOff + 28 + GAP
        return w
    end

    function frame:Text(text)
        if not UI then return end
        local w = UI:CreateLabel(frame, { text = text, size = "small", color = "muted" })
        local y = -(Y0 + yOff)
        w:SetPoint("TOPLEFT",  frame, "TOPLEFT",  X,  y)
        w:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -X, y)
        yOff = yOff + 20 + GAP
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

-- ── CreateOptionsPanel ────────────────────────────────────────────────────────

local _panelCounter = 0

local function CreateOptionsPanel(UI, opts)
    opts = opts or {}

    local tAddonName = opts.addonName or addonName
    local tabs       = opts.tabs or {}
    local maxPerRow  = opts.maxPerRow or 6

    _panelCounter = _panelCounter + 1
    local addonKey = tAddonName:gsub("[^%w]", "_") .. "_" .. _panelCounter

    -- ── Panel frame ───────────────────────────────────────────────────────────
    local panel = CreateFrame("Frame", "RGXOptionsPanel_" .. addonKey, UIParent, "BackdropTemplate")
    panel:SetSize(opts.width or 760, opts.height or 620)
    panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    panel:SetFrameStrata("DIALOG")
    panel:EnableMouse(true)
    local _sidebarIcon  = opts.icon or GetMeta(tAddonName, "IconTexture")
    local _sidebarTitle = opts.title or tAddonName
    local _sidebarName  = _sidebarIcon
        and format("|T%s:16:16:0:0|t %s", _sidebarIcon, _sidebarTitle)
        or  _sidebarTitle
    panel.name = _sidebarName
    panel.settingsCategoryName = _sidebarName
    panel.tabs     = {}
    panel.contents = {}

    -- Outer container
    local container = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    container:SetAllPoints()
    container:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = {left=1, right=1, top=1, bottom=1},
    })
    container:SetBackdropColor(0.05, 0.07, 0.10, 0.95)
    container:SetBackdropBorderColor(0.10, 0.18, 0.24, 1)

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
    header:SetBackdropColor(0.07, 0.10, 0.14, 0.95)
    header:SetBackdropBorderColor(0.12, 0.22, 0.30, 1)

    -- Accent line along header bottom
    local accent = header:CreateTexture(nil, "ARTWORK")
    accent:SetHeight(2)
    accent:SetPoint("BOTTOMLEFT",  8, 0)
    accent:SetPoint("BOTTOMRIGHT", -8, 0)
    do
        local D = GetDesign()
        if D then
            accent:SetColorTexture(D:Unpack("primary"))
        else
            accent:SetColorTexture(0.345, 0.745, 0.506)
        end
    end

    -- Icon
    if opts.icon then
        local logo = header:CreateTexture(nil, "ARTWORK")
        logo:SetSize(28, 28)
        logo:SetPoint("LEFT", 10, 0)
        logo:SetTexture(opts.icon)
    end

    local leftX  = opts.icon and 50 or 14
    local rightX = -14

    local titleStr = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleStr:SetPoint("LEFT", header, "TOPLEFT", leftX, -14)
    titleStr:SetJustifyV("MIDDLE")
    titleStr:SetText(opts.title or tAddonName)

    if opts.subtitle then
        local sub = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        sub:SetPoint("LEFT", header, "TOPLEFT", leftX, -26)
        sub:SetJustifyV("MIDDLE")
        sub:SetText(opts.subtitle)
        sub:SetTextColor(0.70, 0.70, 0.70)
    end

    if opts.website then
        local site = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        site:SetPoint("LEFT", header, "TOPLEFT", leftX, -38)
        site:SetJustifyV("MIDDLE")
        site:SetText(opts.website)
        site:SetTextColor(0.85, 0.85, 0.85)
    end

    local verText = opts.version or GetMeta(tAddonName, "Version") or ""
    if verText ~= "" then
        if not verText:match("^v") then verText = "v" .. verText end
        local ver = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ver:SetPoint("RIGHT", header, "TOPRIGHT", rightX, -14)
        ver:SetJustifyV("MIDDLE")
        ver:SetText(verText)
        ver:SetJustifyH("RIGHT")
        do
            local D = GetDesign()
            if D then ver:SetTextColor(D:Unpack("primary")) else ver:SetTextColor(0.345, 0.745, 0.506) end
        end
    end

    if opts.author then
        local auth = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        auth:SetPoint("RIGHT", header, "TOPRIGHT", rightX, -26)
        auth:SetJustifyV("MIDDLE")
        auth:SetText("by " .. opts.author)
        auth:SetTextColor(0.70, 0.70, 0.70)
        auth:SetJustifyH("RIGHT")
    end

    if opts.brand then
        local brand = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        brand:SetPoint("RIGHT", header, "TOPRIGHT", rightX, -38)
        brand:SetJustifyV("MIDDLE")
        brand:SetText(opts.brand)
        brand:SetJustifyH("RIGHT")
    end

    -- ── Banner (optional, sits between header and tabs) ───────────────────────
    local tabAnchor = header  -- tabs anchor to this; swapped to banner when present

    if opts.bannerHeight and opts.bannerHeight > 0 then
        local bannerFrame = CreateFrame("Frame", nil, container, "BackdropTemplate")
        bannerFrame:SetHeight(opts.bannerHeight)
        bannerFrame:SetPoint("TOPLEFT",  header, "BOTTOMLEFT",  0, -2)
        bannerFrame:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -2)
        bannerFrame:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = {left=1, right=1, top=1, bottom=1},
        })
        bannerFrame:SetBackdropColor(0.05, 0.07, 0.10, 0.95)
        bannerFrame:SetBackdropBorderColor(0.12, 0.22, 0.30, 1)
        panel.bannerFrame = bannerFrame
        tabAnchor = bannerFrame
    end

    -- ── Tab container ─────────────────────────────────────────────────────────
    local rowCount      = GetRowCount(tabs, maxPerRow)
    local tabAreaHeight = GetTabContainerHeight(rowCount)

    local tabArea = CreateFrame("Frame", nil, container)
    tabArea:SetPoint("TOPLEFT",  tabAnchor, "BOTTOMLEFT",  0, -2)
    tabArea:SetPoint("TOPRIGHT", tabAnchor, "BOTTOMRIGHT", 0, -2)
    tabArea:SetHeight(tabAreaHeight)

    local tabBg = tabArea:CreateTexture(nil, "BACKGROUND")
    tabBg:SetAllPoints()
    tabBg:SetColorTexture(0.03, 0.03, 0.03, 0.60)

    -- ── Build tabs and content frames ─────────────────────────────────────────
    for i, tabInfo in ipairs(tabs) do
        local row = math.ceil(i / maxPerRow)
        local col = ((i - 1) % maxPerRow) + 1

        local tabBtn = CreateTabButton(
            tabArea, tabInfo.text, i, row, col, panel, tabInfo.icon, addonKey
        )
        panel.tabs[i] = tabBtn

        -- Content frame for this tab
        local content = CreateFrame("Frame", nil, container, "BackdropTemplate")
        content:SetPoint("TOPLEFT",     tabArea, "BOTTOMLEFT",          1, -8)
        content:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT",      -7,  8)
        content:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = true, tileSize = 16, edgeSize = 1,
            insets = {left=1, right=1, top=1, bottom=1},
        })
        content:SetBackdropColor(0.06, 0.06, 0.06, 0.95)
        content:SetBackdropBorderColor(0.20, 0.20, 0.20, 1)
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

    local bannerQueued = false

    local function BuildBanner()
        if panel._bannerBuilt then
            return
        end

        panel._bannerBuilt = true
        if panel.bannerFrame and type(opts.banner) == "function" then
            local ok, err = pcall(opts.banner, panel.bannerFrame)
            if not ok then RGX:Debug("[RGXOptions] Banner build error: " .. tostring(err)) end
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
    function panel:SelectTab(index)
        QueueBannerBuild()

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
                        if content._dirty then
                            ClearContent(content)
                            content._dirty = nil
                        end
                        if tabInfo and type(tabInfo.content) == "function" then
                            local ok, err = pcall(tabInfo.content, CreateAddHelper(content))
                            if ok then
                                content._built = true
                            else
                                RGX:Debug("[RGXOptions] Tab build error: " .. tostring(err))
                            end
                        else
                            content._built = true
                        end
                    elseif type(content.Refresh) == "function" then
                        pcall(content.Refresh, content)
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

    function panel:InvalidateAllTabs()
        for _, content in ipairs(self.contents) do
            content._dirty = true
        end
    end

    function panel:Refresh()
        QueueBannerBuild()

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
                        end
                    end
                elseif type(content.Refresh) == "function" then
                    pcall(content.Refresh, content)
                end
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
    end

    panel:SetScript("OnShow", function(self)
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

    panel:Hide()

    if type(UISpecialFrames) == "table" and panel.GetName and panel:GetName() then
        table.insert(UISpecialFrames, panel:GetName())
    end

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
