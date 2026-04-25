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

local function GetUI()
    return _G.RGXUI
end

local function GetDesign()
    return _G.RGXDesign
end

-- ── Layout constants ──────────────────────────────────────────────────────────

local TAB_W        = 94
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

local function CreateTabButton(parent, text, tabIndex, row, col, maxPerRow, panelRef, icon, addonKey)
    local frameName = "RGXTab_" .. addonKey .. "_" .. tabIndex
    local btn = CreateFrame("Button", frameName, parent)
    btn:SetSize(TAB_W, TAB_H)
    btn.tabIndex = tabIndex
    btn.tabRow   = row
    btn.tabCol   = col

    local function UpdatePos()
        local xOff = TAB_ROW_PAD + (col - 1) * (TAB_W + TAB_SPACING)
        local yOff = -(TAB_ROW_PAD + (row - 1) * (TAB_H + TAB_ROW_GAP))
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xOff, yOff)
    end
    UpdatePos()
    btn:HookScript("OnShow", function() UpdatePos() end)

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
        iconTex:SetPoint("LEFT", 6, 0)
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
    panel.name = opts.title or tAddonName
    panel.settingsCategoryName = opts.title or tAddonName
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
    titleStr:SetPoint("TOPLEFT", leftX, -14)
    titleStr:SetText(opts.title or tAddonName)

    if opts.subtitle then
        local sub = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        sub:SetPoint("TOPLEFT", leftX, -26)
        sub:SetText(opts.subtitle)
        sub:SetTextColor(0.70, 0.70, 0.70)
    end

    if opts.website then
        local site = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        site:SetPoint("TOPLEFT", leftX, -38)
        site:SetText(opts.website)
        site:SetTextColor(0.85, 0.85, 0.85)
    end

    local verText = opts.version or GetMeta(tAddonName, "Version") or ""
    if verText ~= "" then
        local ver = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ver:SetPoint("TOPRIGHT", rightX, -14)
        ver:SetText(verText)
        ver:SetJustifyH("RIGHT")
        do
            local D = GetDesign()
            if D then ver:SetTextColor(D:Unpack("primary")) else ver:SetTextColor(0.345, 0.745, 0.506) end
        end
    end

    if opts.author then
        local auth = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        auth:SetPoint("TOPRIGHT", rightX, -26)
        auth:SetText("by " .. opts.author)
        auth:SetTextColor(0.70, 0.70, 0.70)
        auth:SetJustifyH("RIGHT")
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
        if type(opts.banner) == "function" then
            local ok, err = pcall(opts.banner, bannerFrame)
            if not ok then RGX:Debug("[RGXOptions] Banner build error: " .. tostring(err)) end
        end
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
            tabArea, tabInfo.text, i, row, col, maxPerRow, panel, tabInfo.icon, addonKey
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

        -- Build initial content
        if type(tabInfo.content) == "function" then
            local ok, err = pcall(tabInfo.content, content)
            if not ok then RGX:Debug("[RGXOptions] Tab build error '" .. tabInfo.text .. "': " .. tostring(err)) end
        end

        panel.contents[i] = content
        panel.tabs[i]._tabInfo = tabInfo
    end

    -- ── SelectTab ─────────────────────────────────────────────────────────────
    function panel:SelectTab(index)
        for i = 1, #self.tabs do
            if self.tabs[i] then
                self.tabs[i]:SetActive(i == index)
            end
            if self.contents[i] then
                self.contents[i]:SetShown(i == index)
                if i == index then
                    local content = self.contents[i]
                    if content._dirty then
                        ClearContent(content)
                        content._dirty = nil
                        local tabInfo = self.tabs[i] and self.tabs[i]._tabInfo
                        if tabInfo and type(tabInfo.content) == "function" then
                            local ok, err = pcall(tabInfo.content, content)
                            if not ok then
                                RGX:Debug("[RGXOptions] Tab rebuild error: " .. tostring(err))
                            end
                        end
                    elseif type(content.Refresh) == "function" then
                        pcall(content.Refresh, content)
                    end
                    local tabInfo = self.tabs[i] and self.tabs[i]._tabInfo
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
        for i, content in ipairs(self.contents) do
            if content:IsShown() then
                if content._dirty then
                    local tabInfo = self.tabs[i] and self.tabs[i]._tabInfo
                    if tabInfo then
                        ClearContent(content)
                        content._dirty = nil
                        if type(tabInfo.content) == "function" then
                            pcall(tabInfo.content, content)
                        end
                    end
                elseif type(content.Refresh) == "function" then
                    pcall(content.Refresh, content)
                end
            end
        end
    end

    -- ── Open ──────────────────────────────────────────────────────────────────
    function panel:Open()
        if InCombatLockdown and InCombatLockdown() then
            RGX:Debug("[RGXOptions] Cannot open panel in combat")
            return
        end

        if not self._category then return end

        local opened = false

        if Settings and Settings.OpenToCategory then
            if self._categoryID then
                local ok = pcall(Settings.OpenToCategory, self._categoryID)
                opened = ok
            end
            if not opened then
                local ok = pcall(Settings.OpenToCategory, self.settingsCategoryName)
                opened = ok
            end
        end

        if not opened and InterfaceOptionsFrame_OpenToCategory then
            pcall(InterfaceOptionsFrame_OpenToCategory, self)
            pcall(InterfaceOptionsFrame_OpenToCategory, self)
        end

        if not opened then
            if SettingsPanel then SettingsPanel:Show()
            elseif InterfaceOptionsFrame then InterfaceOptionsFrame:Show() end
        end
    end

    -- ── Register with WoW Settings ────────────────────────────────────────────
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local cat = Settings.RegisterCanvasLayoutCategory(panel, panel.settingsCategoryName)
        Settings.RegisterAddOnCategory(cat)
        panel._category = cat
        if type(cat.GetID) == "function" then
            panel._categoryID = cat:GetID()
        end
    else
        -- Classic / pre-10.x
        panel.name = panel.settingsCategoryName
        if InterfaceOptions_AddCategory then
            InterfaceOptions_AddCategory(panel)
        end
        panel._category = panel
    end

    -- Show first tab by default
    if #panel.tabs > 0 then
        panel:SelectTab(1)
    end

    return panel
end

-- ── Inject into RGXUI once it's available ────────────────────────────────────
-- controls.lua runs first and sets up RGXUI; this file extends it.

local function Inject()
    local UI = _G.RGXUI
    if not UI then return end
    UI.CreateOptionsPanel = function(self, opts)
        return CreateOptionsPanel(self, opts)
    end
end

-- Defer injection so controls.lua has time to register the module
local injectFrame = CreateFrame("Frame")
injectFrame:RegisterEvent("ADDON_LOADED")
injectFrame:SetScript("OnEvent", function(_, _, name)
    if name == addonName then
        Inject()
        injectFrame:UnregisterAllEvents()
    end
end)
