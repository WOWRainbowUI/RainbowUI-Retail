local _, BR = ...

-- ============================================================================
-- OPTIONS PANEL
-- ============================================================================
-- Simplified 3-tab layout: Buffs, Display/Behavior, Settings

-- Aliases from BR namespace
local Components = BR.Components
local CreateButton = BR.CreateButton
local CreatePanel = BR.CreatePanel
local CreateSectionHeader = BR.CreateSectionHeader
local CreateBuffIcon = BR.CreateBuffIcon
local StyleEditBox = BR.StyleEditBox

-- Shared constants
local TEXCOORD_INSET = BR.TEXCOORD_INSET
local DEFAULT_BORDER_SIZE = BR.DEFAULT_BORDER_SIZE
local DEFAULT_ICON_ZOOM = BR.DEFAULT_ICON_ZOOM
local OPTIONS_BASE_SCALE = BR.OPTIONS_BASE_SCALE

-- Buff tables
local BUFF_TABLES = BR.BUFF_TABLES
local BuffGroups = BR.BuffGroups

-- Local aliases for buff arrays
local RaidBuffs = BUFF_TABLES.raid
local PresenceBuffs = BUFF_TABLES.presence
local TargetedBuffs = BUFF_TABLES.targeted
local SelfBuffs = BUFF_TABLES.self
local PetBuffs = BUFF_TABLES.pet
local Consumables = BUFF_TABLES.consumable

-- Glow module
local Glow = BR.Glow
local GlowTypes = Glow.Types

-- Export references from BuffReminders.lua
local defaults = BR.defaults
local LSM = BR.LSM

-- Helper function aliases
local GetCategorySettings = BR.Helpers.GetCategorySettings
local IsCategorySplit = BR.Helpers.IsCategorySplit
local GetBuffTexture = BR.Helpers.GetBuffTexture
local ValidateSpellID = BR.Helpers.ValidateSpellID
local ValidateItemID = BR.Helpers.ValidateItemID
local GenerateCustomBuffKey = BR.Helpers.GenerateCustomBuffKey

-- Display function aliases
local UpdateDisplay = BR.Display.Update
local ToggleTestMode = BR.Display.ToggleTestMode
local UpdateVisuals = BR.Display.UpdateVisuals
local ResetCategoryFramePosition = BR.Display.ResetCategoryFramePosition
local ReparentBuffFrames = BR.CallbackRegistry.TriggerEvent
        and function()
            BR.CallbackRegistry:TriggerEvent("FramesReparent")
        end
    or function() end

-- Masque state
local IsMasqueActive = BR.Masque and BR.Masque.IsActive or function()
    return false
end

-- Custom buff management
local CreateCustomBuffFrameRuntime = BR.CustomBuffs.CreateRuntime
local RemoveCustomBuffFrame = BR.CustomBuffs.Remove
local UpdateCustomBuffFrame = BR.CustomBuffs.UpdateFrame

-- Module-level variables
local optionsPanel = nil
local glowDemoPanel = nil
local customBuffModal = nil

-- Forward declarations
local ShowGlowDemo, ShowCustomBuffModal

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local PANEL_WIDTH = 540
local COL_PADDING = 20
local SECTION_SPACING = 12
local ITEM_HEIGHT = 22
local SCROLLBAR_WIDTH = 24

-- Vertical layout spacing constants
local COMPONENT_GAP = 4 -- Standard gap between components
local SECTION_GAP = 8 -- Gap before/after section boundaries
local DROPDOWN_EXTRA = 8 -- Extra clearance after dropdowns (menu overlay space)

local CATEGORY_ORDER = { "raid", "presence", "targeted", "self", "pet", "consumable", "custom" }
local CATEGORY_LABELS = {
    raid = "團隊增益",
    presence = "在場增益",
    targeted = "目標增益",
    self = "自身增益",
    pet = "寵物提醒",
    consumable = "消耗品",
    custom = "自訂增益",
}

-- Layout-aware section header (uses VerticalLayout instead of manual Y tracking)
local function LayoutSectionHeader(layout, parent, text)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetText("|cffffcc00" .. text .. "|r")
    layout:AddText(header, 14, COMPONENT_GAP)
    return header
end

-- ============================================================================
-- OPTIONS PANEL
-- ============================================================================

local function CreateOptionsPanel()
    local panel = CreatePanel("BuffRemindersOptions", PANEL_WIDTH, 620, { escClose = true })
    panel:Hide()

    -- Forward declarations for banner system
    local UpdateBannerLayout
    local housingBanner, masqueBanner, readyCheckBanner

    -- Track all EditBoxes so we can clear focus when panel hides
    local panelEditBoxes = {}
    Components.SetEditBoxesRef(panelEditBoxes)
    panel:SetScript("OnHide", function()
        for _, editBox in ipairs(panelEditBoxes) do
            editBox:ClearFocus()
        end
    end)

    -- Refresh all component values from DB when panel opens (OnShow pattern)
    panel:SetScript("OnShow", function()
        Components.RefreshAll()
        UpdateBannerLayout()
    end)

    -- Title (inline with tab row)
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", COL_PADDING, -10)
    title:SetText("|cffffffff增益|r|cffffcc00提醒|r")

    -- Version (next to title, smaller font)
    local version = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    version:SetPoint("LEFT", title, "RIGHT", 6, 0)
    local addonVersion = C_AddOns.GetAddOnMetadata("BuffReminders", "版本") or ""
    version:SetText(addonVersion)

    -- Discord link (next to version)
    local discordSep = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    discordSep:SetPoint("LEFT", version, "RIGHT", 6, 0)
    discordSep:SetText("|cff555555·|r")

    local discordLink = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    discordLink:SetPoint("LEFT", discordSep, "RIGHT", 6, 0)
    discordLink:SetText("|cff7289da加入Discord|r")

    local discordHit = CreateFrame("Button", nil, panel)
    discordHit:SetAllPoints(discordLink)
    discordHit:SetScript("OnClick", function()
        StaticPopup_Show("BUFFREMINDERS_DISCORD_URL")
    end)
    discordHit:SetScript("OnEnter", function()
        discordLink:SetText("|cff99aaff加入Discord|r")
        BR.ShowTooltip(
            discordHit,
            "點擊取得邀請連結",
            "取得反饋、功能建議或者錯誤回報？\n加入到Discord!",
            "ANCHOR_BOTTOM"
        )
    end)
    discordHit:SetScript("OnLeave", function()
        discordLink:SetText("|cff7289da加入Discord|r")
        BR.HideTooltip()
    end)

    -- Scale controls (top right area) - text link style: < 100% >
    local BASE_SCALE = OPTIONS_BASE_SCALE
    local MIN_PCT, MAX_PCT = 80, 150

    local currentScale = BuffRemindersDB.optionsPanelScale or BASE_SCALE
    local currentPct = math.floor(currentScale / BASE_SCALE * 100 + 0.5)

    -- Close button
    local closeBtn = CreateButton(panel, "x", function()
        panel:Hide()
    end)
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("TOPRIGHT", -5, -5)

    local scaleHolder = CreateFrame("Frame", nil, panel)
    scaleHolder:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
    scaleHolder:SetSize(60, 16)

    local scaleDown = scaleHolder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    scaleDown:SetPoint("LEFT", 0, 0)
    scaleDown:SetText("<")

    local scaleValue = scaleHolder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    scaleValue:SetPoint("LEFT", scaleDown, "RIGHT", 4, 0)
    scaleValue:SetText(currentPct .. "%")

    local scaleUp = scaleHolder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    scaleUp:SetPoint("LEFT", scaleValue, "RIGHT", 4, 0)
    scaleUp:SetText(">")

    local function UpdateScaleText()
        local pct = math.floor((BuffRemindersDB.optionsPanelScale or BASE_SCALE) / BASE_SCALE * 100 + 0.5)
        scaleValue:SetText(pct .. "%")
        scaleDown:SetTextColor(pct > MIN_PCT and 1 or 0.4, pct > MIN_PCT and 1 or 0.4, pct > MIN_PCT and 1 or 0.4)
        scaleUp:SetTextColor(pct < MAX_PCT and 1 or 0.4, pct < MAX_PCT and 1 or 0.4, pct < MAX_PCT and 1 or 0.4)
    end

    local function UpdateScale(delta)
        local oldPct = math.floor((BuffRemindersDB.optionsPanelScale or BASE_SCALE) / BASE_SCALE * 100 + 0.5)
        local newPct = math.max(MIN_PCT, math.min(MAX_PCT, oldPct + delta))
        local newScale = newPct / 100 * BASE_SCALE
        BuffRemindersDB.optionsPanelScale = newScale
        panel:SetScale(newScale)
        UpdateScaleText()
    end

    -- Clickable regions for < and >
    local downBtn = CreateFrame("Button", nil, scaleHolder)
    downBtn:SetAllPoints(scaleDown)
    downBtn:SetScript("OnClick", function()
        UpdateScale(-10)
    end)
    downBtn:SetScript("OnEnter", function()
        if currentPct > MIN_PCT then
            scaleDown:SetTextColor(1, 0.82, 0)
        end
    end)
    downBtn:SetScript("OnLeave", function()
        UpdateScaleText()
    end)

    local upBtn = CreateFrame("Button", nil, scaleHolder)
    upBtn:SetAllPoints(scaleUp)
    upBtn:SetScript("OnClick", function()
        UpdateScale(10)
    end)
    upBtn:SetScript("OnEnter", function()
        local pct = math.floor((BuffRemindersDB.optionsPanelScale or BASE_SCALE) / BASE_SCALE * 100 + 0.5)
        if pct < MAX_PCT then
            scaleUp:SetTextColor(1, 0.82, 0)
        end
    end)
    upBtn:SetScript("OnLeave", function()
        UpdateScaleText()
    end)

    UpdateScaleText()

    if BuffRemindersDB.optionsPanelScale then
        panel:SetScale(BuffRemindersDB.optionsPanelScale)
    end

    -- ========== TABS ==========
    local tabButtons = {}
    local contentContainers = {}
    local TAB_HEIGHT = 22
    local activeTabName = "buffs"

    local function SetActiveTab(tabName)
        activeTabName = tabName
        for name, tab in pairs(tabButtons) do
            tab:SetActive(name == tabName)
        end
        for name, container in pairs(contentContainers) do
            if name == tabName then
                container:Show()
            else
                container:Hide()
            end
        end
        if masqueBanner then
            masqueBanner:Refresh()
            readyCheckBanner:Refresh()
            UpdateBannerLayout()
        end
    end

    -- Create 4 tabs: Buffs, Display & Behavior, Settings, Import/Export
    tabButtons.buffs = Components.Tab(panel, { name = "buffs", label = "增益", width = 50 })
    tabButtons.displayBehavior =
        Components.Tab(panel, { name = "displayBehavior", label = "顯示/行為", width = 110 })
    tabButtons.settings = Components.Tab(panel, { name = "settings", label = "設定", width = 65 })
    tabButtons.profiles = Components.Tab(panel, { name = "profiles", label = "匯入/匯出", width = 95 })

    -- Position tabs below title
    tabButtons.buffs:SetPoint("TOPLEFT", panel, "TOPLEFT", COL_PADDING, -30)
    tabButtons.displayBehavior:SetPoint("LEFT", tabButtons.buffs, "RIGHT", 2, 0)
    tabButtons.settings:SetPoint("LEFT", tabButtons.displayBehavior, "RIGHT", 2, 0)
    tabButtons.profiles:SetPoint("LEFT", tabButtons.settings, "RIGHT", 2, 0)

    for name, tab in pairs(tabButtons) do
        tab:SetScript("OnClick", function()
            SetActiveTab(name)
        end)
    end

    -- Separator line below tabs
    local tabSeparator = panel:CreateTexture(nil, "ARTWORK")
    tabSeparator:SetHeight(1)
    tabSeparator:SetPoint("TOPLEFT", COL_PADDING, -30 - TAB_HEIGHT)
    tabSeparator:SetPoint("TOPRIGHT", -COL_PADDING, -30 - TAB_HEIGHT)
    tabSeparator:SetColorTexture(0.3, 0.3, 0.3, 1)

    -- ========== CONTENT CONTAINERS ==========
    local CONTENT_TOP = -30 - TAB_HEIGHT - 10

    -- Helper to create a scrollable content container using Components
    local function CreateScrollableContent(name)
        local scrollFrame, content = Components.ScrollableContainer(panel, {
            contentHeight = 600,
            scrollbarWidth = SCROLLBAR_WIDTH,
        })
        scrollFrame:SetPoint("TOPLEFT", 0, CONTENT_TOP)
        scrollFrame:SetPoint("BOTTOMRIGHT", 0, 46)
        scrollFrame:Hide()

        contentContainers[name] = scrollFrame
        return content, scrollFrame
    end

    -- ========== BANNERS ==========
    local BANNER_HEIGHT = 28
    local BANNER_TOP_GAP = 6
    local BANNER_BETWEEN_GAP = 4
    local BANNER_BOTTOM_GAP = 0

    housingBanner = Components.Banner(panel, {
        text = "在住家社區增益追蹤是停用的",
        visible = function()
            return C_Housing
                and (
                    (C_Housing.IsInsideHouseOrPlot and C_Housing.IsInsideHouseOrPlot())
                    or (C_Housing.IsOnNeighborhoodMap and C_Housing.IsOnNeighborhoodMap())
                )
        end,
    })

    masqueBanner = Components.Banner(panel, {
        text = "縮放以及邊框設定是由Masque所管理",
        icon = "QuestNormal",
        color = "orange",
        visible = function()
            return IsMasqueActive() and activeTabName == "displayBehavior"
        end,
    })

    readyCheckBanner = Components.Banner(panel, {
        text = '"只顯示在準備確認"移動到個別類別設定',
        color = "orange",
        visible = function()
            return activeTabName == "settings"
        end,
    })

    UpdateBannerLayout = function()
        local bannerY = -30 - TAB_HEIGHT - BANNER_TOP_GAP
        local bannerOffset = 0

        if housingBanner:IsShown() then
            housingBanner:ClearAllPoints()
            housingBanner:SetPoint("TOPLEFT", panel, "TOPLEFT", COL_PADDING, bannerY)
            housingBanner:SetPoint("RIGHT", panel, "RIGHT", -COL_PADDING, 0)
            bannerY = bannerY - BANNER_HEIGHT - BANNER_BETWEEN_GAP
            bannerOffset = bannerOffset + BANNER_HEIGHT + BANNER_BETWEEN_GAP
        end

        if masqueBanner:IsShown() then
            masqueBanner:ClearAllPoints()
            masqueBanner:SetPoint("TOPLEFT", panel, "TOPLEFT", COL_PADDING, bannerY)
            masqueBanner:SetPoint("RIGHT", panel, "RIGHT", -COL_PADDING, 0)
            bannerY = bannerY - BANNER_HEIGHT - BANNER_BETWEEN_GAP
            bannerOffset = bannerOffset + BANNER_HEIGHT + BANNER_BETWEEN_GAP
        end

        if readyCheckBanner:IsShown() then
            readyCheckBanner:ClearAllPoints()
            readyCheckBanner:SetPoint("TOPLEFT", panel, "TOPLEFT", COL_PADDING, bannerY)
            readyCheckBanner:SetPoint("RIGHT", panel, "RIGHT", -COL_PADDING, 0)
            bannerOffset = bannerOffset + BANNER_HEIGHT + BANNER_BOTTOM_GAP
        elseif bannerOffset > 0 then
            -- Replace the between-gap with a bottom-gap after the last visible banner
            bannerOffset = bannerOffset - BANNER_BETWEEN_GAP + BANNER_BOTTOM_GAP
        end

        local newTop = CONTENT_TOP - bannerOffset
        for _, container in pairs(contentContainers) do
            container:ClearAllPoints()
            container:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, newTop)
            if container.GetContentFrame then
                container:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 46)
            end
        end
    end

    -- Store buff checkboxes for refresh
    panel.buffCheckboxes = {}

    -- ========== HELPER FUNCTIONS ==========

    -- Resolve icon textures from displayIcon texture IDs or spell IDs
    local function ResolveBuffIcons(displayIcon, spellIDs)
        if displayIcon then
            -- Use override textures directly
            if type(displayIcon) == "table" then
                return displayIcon
            else
                return { displayIcon }
            end
        elseif spellIDs then
            -- Look up textures from spell IDs (deduplicated)
            local icons = {}
            local seenTextures = {}
            local spellList = type(spellIDs) == "table" and spellIDs or { spellIDs }
            for _, spellID in ipairs(spellList) do
                local texture = GetBuffTexture(spellID)
                if texture and not seenTextures[texture] then
                    seenTextures[texture] = true
                    table.insert(icons, texture)
                end
            end
            return #icons > 0 and icons or nil
        end
        return nil
    end

    -- Create buff checkbox using Components.Checkbox
    local function CreateBuffCheckbox(
        parent,
        x,
        y,
        spellIDs,
        key,
        displayName,
        infoTooltip,
        displayIcon,
        readyCheckOnly
    )
        local holder = Components.Checkbox(parent, {
            label = displayName,
            icons = ResolveBuffIcons(displayIcon, spellIDs),
            infoTooltip = not readyCheckOnly and infoTooltip or nil,
            get = function()
                return BuffRemindersDB.enabledBuffs[key] ~= false
            end,
            onChange = function(checked)
                BuffRemindersDB.enabledBuffs[key] = checked
                UpdateDisplay()
                if readyCheckOnly then
                    Components.RefreshAll()
                end
            end,
        })
        holder:SetPoint("TOPLEFT", x, y)
        panel.buffCheckboxes[key] = holder

        -- Inline toggle: "Ready check only" / "Always show" (replaces info tooltip icon)
        if readyCheckOnly then
            local function GetReadyCheckOnlyState()
                local overrides = BuffRemindersDB.readyCheckOnlyOverrides
                return not overrides or overrides[key] ~= false
            end

            local function ToggleLabel(checked)
                return checked and "準備確認" or "永遠"
            end

            local toggle
            toggle = Components.Toggle(holder, {
                label = ToggleLabel(GetReadyCheckOnlyState()),
                get = GetReadyCheckOnlyState,
                enabled = function()
                    return BuffRemindersDB.enabledBuffs[key] ~= false
                end,
                onChange = function(checked)
                    if checked then
                        -- Ready check only (default): remove override
                        BR.Config.Set("readyCheckOnlyOverrides." .. key, nil)
                    else
                        -- Always show: store explicit false
                        BR.Config.Set("readyCheckOnlyOverrides." .. key, false)
                    end
                    toggle.label:SetText(ToggleLabel(checked))
                end,
            })
            -- Also update label text on Refresh (wrap original Refresh)
            local origRefresh = toggle.Refresh
            function toggle:Refresh()
                origRefresh(self)
                self.label:SetText(ToggleLabel(GetReadyCheckOnlyState()))
            end
            toggle:SetPoint("LEFT", holder.label, "RIGHT", 6, 0)
        end

        return y - ITEM_HEIGHT
    end

    -- ========== BUFFS TAB (Two-Column Layout) ==========
    local buffsContent, _ = CreateScrollableContent("buffs")

    -- Render checkboxes for a buff array (single column within each side)
    local function RenderBuffCheckboxes(parent, x, y, buffArray)
        local groupSpells = {}
        local groupDisplaySpells = {}
        local groupIconOverrides = {}
        local groupReadyCheckOnly = {}

        for _, buff in ipairs(buffArray) do
            if buff.groupId then
                groupSpells[buff.groupId] = groupSpells[buff.groupId] or {}
                groupDisplaySpells[buff.groupId] = groupDisplaySpells[buff.groupId] or {}
                if buff.spellID then
                    local spellList = type(buff.spellID) == "table" and buff.spellID or { buff.spellID }
                    for _, id in ipairs(spellList) do
                        table.insert(groupSpells[buff.groupId], id)
                    end
                end
                if buff.displaySpells then
                    local displayList = type(buff.displaySpells) == "table" and buff.displaySpells
                        or { buff.displaySpells }
                    for _, id in ipairs(displayList) do
                        table.insert(groupDisplaySpells[buff.groupId], id)
                    end
                end
                -- Resolve display icon(s) per entry: displayIcon > displaySpells > primary spellID
                -- Deduplicate icons within the same group (e.g., MH + OH weapon buffs share icons)
                if not groupIconOverrides[buff.groupId] then
                    groupIconOverrides[buff.groupId] = {}
                    groupIconOverrides[buff.groupId]._seen = {}
                end
                local seen = groupIconOverrides[buff.groupId]._seen
                if buff.displayIcon then
                    local overrides = type(buff.displayIcon) == "table" and buff.displayIcon or { buff.displayIcon }
                    for _, icon in ipairs(overrides) do
                        if not seen[icon] then
                            seen[icon] = true
                            table.insert(groupIconOverrides[buff.groupId], icon)
                        end
                    end
                elseif buff.displaySpells then
                    local displayList = type(buff.displaySpells) == "table" and buff.displaySpells
                        or { buff.displaySpells }
                    for _, id in ipairs(displayList) do
                        local texture = GetBuffTexture(id)
                        if texture and not seen[texture] then
                            seen[texture] = true
                            table.insert(groupIconOverrides[buff.groupId], texture)
                        end
                    end
                elseif buff.spellID then
                    local primarySpell = type(buff.spellID) == "table" and buff.spellID[1] or buff.spellID
                    if primarySpell and primarySpell > 0 then
                        local texture = GetBuffTexture(primarySpell)
                        if texture and not seen[texture] then
                            seen[texture] = true
                            table.insert(groupIconOverrides[buff.groupId], texture)
                        end
                    end
                end
                if buff.readyCheckOnly then
                    groupReadyCheckOnly[buff.groupId] = true
                end
            end
        end

        local seenGroups = {}
        for _, buff in ipairs(buffArray) do
            if buff.groupId then
                if not seenGroups[buff.groupId] then
                    seenGroups[buff.groupId] = true
                    local groupInfo = BuffGroups[buff.groupId]
                    local displayIcon = groupIconOverrides[buff.groupId]
                    if displayIcon and #displayIcon == 0 then
                        displayIcon = nil
                    end
                    local displaySpells = groupDisplaySpells[buff.groupId]
                    local spells = (#displaySpells > 0) and displaySpells or groupSpells[buff.groupId]
                    if #spells == 0 then
                        spells = nil
                    end
                    y = CreateBuffCheckbox(
                        parent,
                        x,
                        y,
                        spells,
                        buff.groupId,
                        groupInfo.displayName,
                        buff.infoTooltip,
                        displayIcon,
                        groupReadyCheckOnly[buff.groupId]
                    )
                end
            else
                local displaySpells = buff.displaySpells or buff.spellID
                y = CreateBuffCheckbox(
                    parent,
                    x,
                    y,
                    displaySpells,
                    buff.key,
                    buff.name,
                    buff.infoTooltip,
                    buff.displayIcon,
                    buff.readyCheckOnly
                )
            end
        end

        return y
    end

    -- Column layout constants
    local COL_WIDTH = (PANEL_WIDTH - COL_PADDING * 3) / 2
    local buffsLeftX = COL_PADDING
    local buffsRightX = COL_PADDING + COL_WIDTH + COL_PADDING
    local buffsLeftY = -6
    local buffsRightY = -6

    -- LEFT COLUMN: Group-wide buffs
    -- Raid Buffs
    _, buffsLeftY = CreateSectionHeader(buffsContent, "團隊增益", buffsLeftX, buffsLeftY)
    local raidNote = buffsContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    raidNote:SetPoint("TOPLEFT", buffsLeftX, buffsLeftY)
    raidNote:SetText("(為整個團隊)")
    buffsLeftY = buffsLeftY - 14
    buffsLeftY = RenderBuffCheckboxes(buffsContent, buffsLeftX, buffsLeftY, RaidBuffs)
    buffsLeftY = buffsLeftY - SECTION_SPACING

    -- Targeted Buffs
    _, buffsLeftY = CreateSectionHeader(buffsContent, "目標增益", buffsLeftX, buffsLeftY)
    local targetedNote = buffsContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    targetedNote:SetPoint("TOPLEFT", buffsLeftX, buffsLeftY)
    targetedNote:SetText("(針對他人的增益)")
    buffsLeftY = buffsLeftY - 14
    buffsLeftY = RenderBuffCheckboxes(buffsContent, buffsLeftX, buffsLeftY, TargetedBuffs)
    buffsLeftY = buffsLeftY - SECTION_SPACING

    -- Consumables
    _, buffsLeftY = CreateSectionHeader(buffsContent, "消耗品", buffsLeftX, buffsLeftY)
    local consumablesNote = buffsContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    consumablesNote:SetPoint("TOPLEFT", buffsLeftX, buffsLeftY)
    consumablesNote:SetText("(精鍊、食物、符文、油)")
    buffsLeftY = buffsLeftY - 14
    buffsLeftY = RenderBuffCheckboxes(buffsContent, buffsLeftX, buffsLeftY, Consumables)

    -- RIGHT COLUMN: Individual buffs
    -- Presence Buffs
    _, buffsRightY = CreateSectionHeader(buffsContent, "在場增益", buffsRightX, buffsRightY)
    local presenceNote = buffsContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    presenceNote:SetPoint("TOPLEFT", buffsRightX, buffsRightY)
    presenceNote:SetText("(至少1人需要)")
    buffsRightY = buffsRightY - 14
    buffsRightY = RenderBuffCheckboxes(buffsContent, buffsRightX, buffsRightY, PresenceBuffs)
    buffsRightY = buffsRightY - SECTION_SPACING

    -- Self Buffs
    _, buffsRightY = CreateSectionHeader(buffsContent, "自身增益", buffsRightX, buffsRightY)
    local selfNote = buffsContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    selfNote:SetPoint("TOPLEFT", buffsRightX, buffsRightY)
    selfNote:SetText("(完全為你自己的增益)")
    buffsRightY = buffsRightY - 14
    buffsRightY = RenderBuffCheckboxes(buffsContent, buffsRightX, buffsRightY, SelfBuffs)
    buffsRightY = buffsRightY - SECTION_SPACING

    -- Pet Reminders
    _, buffsRightY = CreateSectionHeader(buffsContent, "寵物提醒", buffsRightX, buffsRightY)
    local petNote = buffsContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    petNote:SetPoint("TOPLEFT", buffsRightX, buffsRightY)
    petNote:SetText("(寵物召喚提醒)")
    buffsRightY = buffsRightY - 14
    buffsRightY = RenderBuffCheckboxes(buffsContent, buffsRightX, buffsRightY, PetBuffs)
    buffsRightY = buffsRightY - SECTION_SPACING

    -- Custom Buffs (right column)
    _, buffsRightY = CreateSectionHeader(buffsContent, "自訂增益", buffsRightX, buffsRightY)
    panel.customBuffRows = {}

    local customNote = buffsContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    customNote:SetPoint("TOPLEFT", buffsRightX, buffsRightY)
    customNote:SetText("(透過法術ID追蹤任何增益/發光)")
    buffsRightY = buffsRightY - 14

    local customSectionStartY = buffsRightY
    local customBuffsContainer = CreateFrame("Frame", nil, buffsContent)
    customBuffsContainer:SetPoint("TOPLEFT", buffsRightX, buffsRightY)
    customBuffsContainer:SetSize(COL_WIDTH, 200)

    local ADD_BTN_GAP = 4
    local ADD_BTN_HEIGHT = 22
    local CUSTOM_CONTAINER_PAD = ADD_BTN_GAP + ADD_BTN_HEIGHT + 2

    local function RenderCustomBuffRows()
        for _, row in ipairs(panel.customBuffRows) do
            row:Hide()
            row:SetParent(nil)
        end
        panel.customBuffRows = {}

        local db = BuffRemindersDB
        local rowY = 0

        local sortedKeys = {}
        if db.customBuffs then
            for key in pairs(db.customBuffs) do
                table.insert(sortedKeys, key)
            end
        end
        table.sort(sortedKeys)

        for _, key in ipairs(sortedKeys) do
            local customBuff = db.customBuffs[key]

            -- Use Components.Checkbox for consistent styling
            local holder = Components.Checkbox(customBuffsContainer, {
                label = customBuff.name or ("Spell " .. tostring(customBuff.spellID)),
                icons = ResolveBuffIcons(nil, customBuff.spellID),
                get = function()
                    return BuffRemindersDB.enabledBuffs[key] ~= false
                end,
                onChange = function(checked)
                    BuffRemindersDB.enabledBuffs[key] = checked
                    UpdateDisplay()
                end,
                onRightClick = function()
                    ShowCustomBuffModal(key, RenderCustomBuffRows)
                end,
                tooltip = { title = "自訂增益", desc = "右鍵點擊來編輯或刪除" },
            })
            holder:SetPoint("TOPLEFT", 0, rowY)
            panel.buffCheckboxes[key] = holder

            table.insert(panel.customBuffRows, holder)
            rowY = rowY - ITEM_HEIGHT
        end

        local addBtn = CreateButton(customBuffsContainer, "+ 新增自訂增益", function()
            ShowCustomBuffModal(nil, RenderCustomBuffRows)
        end)
        addBtn:SetPoint("TOPLEFT", 0, rowY - ADD_BTN_GAP)
        table.insert(panel.customBuffRows, addBtn)

        customBuffsContainer:SetHeight(math.abs(rowY) + CUSTOM_CONTAINER_PAD)

        -- Recalculate content height when custom buffs change
        local effectiveRightY = customSectionStartY + rowY - CUSTOM_CONTAINER_PAD
        buffsContent:SetHeight(math.max(math.abs(buffsLeftY), math.abs(effectiveRightY)) + 4)

        return rowY
    end

    panel.RenderCustomBuffRows = RenderCustomBuffRows
    RenderCustomBuffRows()

    -- ========== DISPLAY/BEHAVIOR TAB ==========
    local displayBehaviorContent, _ = CreateScrollableContent("displayBehavior")
    local displayBehaviorX = COL_PADDING
    local displayBehaviorLayout = Components.VerticalLayout(displayBehaviorContent, { x = displayBehaviorX, y = -10 })

    -- Global Defaults section
    LayoutSectionHeader(displayBehaviorLayout, displayBehaviorContent, "全局預設")

    local defNote = displayBehaviorContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    displayBehaviorLayout:AddText(defNote, 12, COMPONENT_GAP)
    defNote:SetText("(全部類別都會繼承設定，除非被覆蓋)")

    -- Fixed column layout: all sliders use default labelWidth (70)
    local DEF_COL2 = 260 -- labelWidth(70) + sliderWidth(100) + value(60) + gap(30)

    local defSizeHolder = Components.Slider(displayBehaviorContent, {
        label = "圖示大小",
        min = 16,
        max = 128,
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.iconSize or 64
        end,
        onChange = function(val)
            BR.Config.Set("defaults.iconSize", val)
        end,
    })

    local defZoomHolder = Components.Slider(displayBehaviorContent, {
        label = "圖示縮放",
        min = 0,
        max = 15,
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.iconZoom or DEFAULT_ICON_ZOOM
        end,
        enabled = function()
            return not IsMasqueActive()
        end,
        suffix = "%",
        onChange = function(val)
            BR.Config.Set("defaults.iconZoom", val)
        end,
    })
    displayBehaviorLayout:AddRow(
        { { defSizeHolder, displayBehaviorX }, { defZoomHolder, displayBehaviorX + DEF_COL2 } },
        COMPONENT_GAP
    )

    local defBorderHolder = Components.Slider(displayBehaviorContent, {
        label = "邊框",
        min = 0,
        max = 8,
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.borderSize or DEFAULT_BORDER_SIZE
        end,
        enabled = function()
            return not IsMasqueActive()
        end,
        suffix = "px",
        onChange = function(val)
            BR.Config.Set("defaults.borderSize", val)
        end,
    })

    local defAlphaHolder = Components.Slider(displayBehaviorContent, {
        label = "透明度",
        min = 10,
        max = 100,
        get = function()
            return math.floor((BuffRemindersDB.defaults and BuffRemindersDB.defaults.iconAlpha or 1) * 100)
        end,
        suffix = "%",
        onChange = function(val)
            BR.Config.Set("defaults.iconAlpha", val / 100)
        end,
    })
    displayBehaviorLayout:AddRow(
        { { defBorderHolder, displayBehaviorX }, { defAlphaHolder, displayBehaviorX + DEF_COL2 } },
        COMPONENT_GAP
    )

    local defSpacingHolder = Components.Slider(displayBehaviorContent, {
        label = "間距",
        min = 0,
        max = 50,
        get = function()
            return math.floor((BuffRemindersDB.defaults and BuffRemindersDB.defaults.spacing or 0.2) * 100)
        end,
        suffix = "%",
        onChange = function(val)
            BR.Config.Set("defaults.spacing", val / 100)
        end,
    })

    local defTextSizeHolder = Components.NumericStepper(displayBehaviorContent, {
        label = "文字",
        min = 6,
        max = 32,
        get = function()
            local db = BuffRemindersDB.defaults
            if db and db.textSize then
                return db.textSize
            end
            -- Auto: derive from icon size (matches rendering behavior)
            local iconSize = db and db.iconSize or 64
            return math.floor(iconSize * 0.32)
        end,
        onChange = function(val)
            BR.Config.Set("defaults.textSize", val)
        end,
    })

    local defTextColorHolder = Components.ColorSwatch(displayBehaviorContent, {
        hasOpacity = true,
        get = function()
            local tc = BuffRemindersDB.defaults and BuffRemindersDB.defaults.textColor or { 1, 1, 1 }
            local ta = BuffRemindersDB.defaults and BuffRemindersDB.defaults.textAlpha or 1
            return tc[1], tc[2], tc[3], ta
        end,
        onChange = function(r, g, b, a)
            BR.Config.SetMulti({
                ["defaults.textColor"] = { r, g, b },
                ["defaults.textAlpha"] = a or 1,
            })
        end,
    })
    displayBehaviorLayout:AddRow(
        { { defSpacingHolder, displayBehaviorX }, { defTextSizeHolder, displayBehaviorX + DEF_COL2 } },
        COMPONENT_GAP
    )
    defTextColorHolder:SetPoint("LEFT", defTextSizeHolder, "RIGHT", 12, 0) -- aligns alpha % with slider values

    -- Font dropdown (global setting, uses LibSharedMedia)
    local function BuildFontOptions()
        local fontList = LSM:List("font")
        local opts = { { label = "預設", value = nil } }
        for _, name in ipairs(fontList) do
            table.insert(opts, { label = name, value = name })
        end
        return opts
    end

    local defFontHolder = Components.Dropdown(displayBehaviorContent, {
        label = "字體:",
        labelWidth = 70,
        options = BuildFontOptions(),
        width = 200,
        maxItems = 15,
        itemInit = function(_, itemLabel, opt)
            if opt.value then
                local path = LSM:Fetch("font", opt.value)
                if path then
                    itemLabel:SetFont(path, 12, "")
                end
            end
        end,
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.fontFace or nil
        end,
        onChange = function(val)
            BR.Config.Set("defaults.fontFace", val)
        end,
    })
    displayBehaviorLayout:Add(defFontHolder, nil, COMPONENT_GAP)

    local defDirHolder = Components.DirectionButtons(displayBehaviorContent, {
        labelWidth = 70,
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.growDirection or "CENTER"
        end,
        onChange = function(dir)
            BR.Config.Set("defaults.growDirection", dir)
        end,
    })
    displayBehaviorLayout:Add(defDirHolder, nil, COMPONENT_GAP + DROPDOWN_EXTRA)

    -- Expiration Glow section
    LayoutSectionHeader(displayBehaviorLayout, displayBehaviorContent, "過期發光")
    displayBehaviorLayout:Space(COMPONENT_GAP)

    local previewBtn = CreateButton(displayBehaviorContent, "預覽", function()
        ShowGlowDemo()
    end)
    displayBehaviorLayout:Add(previewBtn, nil, SECTION_GAP)

    local defGlowHolder = Components.Checkbox(displayBehaviorContent, {
        label = "發光",
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.showExpirationGlow ~= false
        end,
        onChange = function(checked)
            BR.Config.Set("defaults.showExpirationGlow", checked)
            Components.RefreshAll()
        end,
    })

    local function isExpirationGlowEnabled()
        return BuffRemindersDB.defaults and BuffRemindersDB.defaults.showExpirationGlow ~= false
    end

    local defThresholdHolder = Components.Slider(displayBehaviorContent, {
        min = 1,
        max = 45,
        step = 5,
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.expirationThreshold or 15
        end,
        enabled = isExpirationGlowEnabled,
        suffix = " min",
        onChange = function(val)
            BR.Config.Set("defaults.expirationThreshold", val)
        end,
    })
    defThresholdHolder:SetPoint("LEFT", defGlowHolder.checkbox, "RIGHT", 40, 0)

    local typeOptions = {}
    for i, gt in ipairs(GlowTypes) do
        typeOptions[i] = { label = gt.name, value = i }
    end

    local defTypeHolder = Components.Dropdown(displayBehaviorContent, {
        label = "類型:",
        labelWidth = 34,
        options = typeOptions,
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.glowType or 1
        end,
        enabled = isExpirationGlowEnabled,
        width = 130,
        onChange = function(val)
            BR.Config.Set("defaults.glowType", val)
        end,
    }, "BuffRemindersDefGlowTypeDropdown")
    defTypeHolder:SetPoint("LEFT", defThresholdHolder, "RIGHT", 8, 0)

    local defUseCustomColorHolder = Components.Checkbox(displayBehaviorContent, {
        label = "顏色",
        tooltip = "使用自訂發光顏色而不是預設顏色。\n關閉時，發光使用原生顏色，看起來更加鮮豔。",
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.useCustomGlowColor or false
        end,
        enabled = isExpirationGlowEnabled,
        onChange = function(checked)
            BR.Config.Set("defaults.useCustomGlowColor", checked)
            Components.RefreshAll()
        end,
    })

    local defGlowColorHolder = Components.ColorSwatch(displayBehaviorContent, {
        hasOpacity = true,
        get = function()
            local c = BR.Config.Get("defaults.glowColor", Glow.DEFAULT_COLOR)
            return c[1], c[2], c[3], c[4] or 1
        end,
        enabled = function()
            return isExpirationGlowEnabled()
                and (BuffRemindersDB.defaults and BuffRemindersDB.defaults.useCustomGlowColor or false)
        end,
        onChange = function(r, g, b, a)
            BR.Config.Set("defaults.glowColor", { r, g, b, a or 1 })
        end,
    })

    local defGlowSizeHolder = Components.NumericStepper(displayBehaviorContent, {
        label = "大小:",
        labelWidth = 34,
        min = 1,
        max = 5,
        step = 1,
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.glowSize or 2
        end,
        enabled = isExpirationGlowEnabled,
        onChange = function(val)
            BR.Config.Set("defaults.glowSize", val)
        end,
    })
    displayBehaviorLayout:Add(defGlowHolder, nil, COMPONENT_GAP + DROPDOWN_EXTRA)

    local defGlowWhenMissingHolder = Components.Checkbox(displayBehaviorContent, {
        label = "也在缺少時",
        tooltip = "在完全缺少的增益圖示上顯示發光效果，而不僅僅是過期。",
        get = function()
            return BuffRemindersDB.defaults and BuffRemindersDB.defaults.glowWhenMissing ~= false
        end,
        enabled = isExpirationGlowEnabled,
        onChange = function(checked)
            BR.Config.Set("defaults.glowWhenMissing", checked)
        end,
    })
    defGlowWhenMissingHolder:SetPoint("TOPLEFT", defGlowHolder, "BOTTOMLEFT", 20, -COMPONENT_GAP)
    defGlowSizeHolder:SetPoint("LEFT", defTypeHolder, "LEFT", 0, 0)
    defGlowSizeHolder:SetPoint("TOP", defGlowWhenMissingHolder, "TOP")
    defUseCustomColorHolder:SetPoint("LEFT", defGlowSizeHolder, "RIGHT", 6, 0)
    defGlowColorHolder:SetPoint("LEFT", defUseCustomColorHolder.label, "RIGHT", 4, 0)
    displayBehaviorLayout:Space(20 + COMPONENT_GAP)

    -- Per-Category Customization section
    LayoutSectionHeader(displayBehaviorLayout, displayBehaviorContent, "按類別自訂")
    displayBehaviorLayout:Space(COMPONENT_GAP)

    -- Create collapsible sections that chain-anchor to each other
    local categorySections = {}
    local previousSection = nil

    local function UpdateAppearanceContentHeight()
        -- Calculate total height: fixed header area + all collapsible sections
        local totalHeight = math.abs(displayBehaviorLayout:GetY())
        for _, sec in ipairs(categorySections) do
            totalHeight = totalHeight + sec:GetHeight() + 4
        end
        displayBehaviorContent:SetHeight(totalHeight)
    end

    local SECTION_SCROLLBAR_OFFSET = COL_PADDING
    for _, category in ipairs(CATEGORY_ORDER) do
        local section = Components.CollapsibleSection(displayBehaviorContent, {
            title = CATEGORY_LABELS[category],
            defaultCollapsed = true,
            scrollbarOffset = SECTION_SCROLLBAR_OFFSET,
            onToggle = function()
                -- Defer layout update to next frame
                C_Timer.After(0, UpdateAppearanceContentHeight)
            end,
        })

        if previousSection then
            section:SetPoint("TOPLEFT", previousSection, "BOTTOMLEFT", 0, -4)
        else
            section:SetPoint("TOPLEFT", displayBehaviorX, displayBehaviorLayout:GetY())
        end

        local catContent = section:GetContentFrame()
        local catLayout = Components.VerticalLayout(catContent, { x = 0, y = 0 })

        local db = BuffRemindersDB

        -- Visibility callback for W/S/D/R toggles
        local function OnCategoryVisibilityChange()
            UpdateDisplay()
        end

        -- W/S/D/R content visibility toggles
        local visToggles = Components.VisibilityToggles(catContent, {
            category = category,
            onChange = OnCategoryVisibilityChange,
        })
        catLayout:Add(visToggles, nil, SECTION_GAP)

        -- Show only on ready check (per-category)
        local readyCheckHolder = Components.Checkbox(catContent, {
            label = "只在準備確認時顯示",
            get = function()
                local cs = db.categorySettings and db.categorySettings[category]
                return cs and cs.showOnlyOnReadyCheck == true
            end,
            tooltip = {
                title = "只在準備確認時顯示",
                desc = "準備檢查開始後僅顯示該類別的增益效果15秒",
            },
            onChange = function(checked)
                BR.Config.Set("categorySettings." .. category .. ".showOnlyOnReadyCheck", checked)
            end,
        })
        catLayout:Add(readyCheckHolder, nil, COMPONENT_GAP)

        -- Icons sub-header (all categories except custom)
        if category ~= "custom" then
            local iconsHeader = catContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            iconsHeader:SetText("|cffffcc00圖示|r")
            catLayout:AddText(iconsHeader, 12, COMPONENT_GAP)
        end

        -- Show text on icons (not for custom — custom buffs have per-buff missing text)
        if category ~= "custom" then
            local showTextHolder = Components.Checkbox(catContent, {
                label = "顯示文字在圖示上",
                get = function()
                    local cs = db.categorySettings and db.categorySettings[category]
                    return not cs or cs.showText ~= false
                end,
                tooltip = {
                    title = "顯示文字在圖示上",
                    desc = "在該類別的增益圖示上覆蓋顯示計數或缺少的文字",
                },
                onChange = function(checked)
                    BR.Config.Set("categorySettings." .. category .. ".showText", checked)
                end,
            })
            catLayout:Add(showTextHolder, nil, COMPONENT_GAP)
        end

        -- "BUFF!" text (raid only, grouped under Icons)
        if category == "raid" then
            local reminderHolder = Components.Checkbox(catContent, {
                label = '顯示"BUFF!"提醒文字',
                get = function()
                    local cs = db.categorySettings and db.categorySettings.raid
                    return not cs or cs.showBuffReminder ~= false
                end,
                onChange = function(checked)
                    BR.Config.Set("categorySettings.raid.showBuffReminder", checked)
                    Components.RefreshAll()
                end,
            })
            catLayout:Add(reminderHolder, nil, COMPONENT_GAP)

            local buffTextSizeHolder = Components.NumericStepper(reminderHolder, {
                label = "大小",
                labelWidth = 28,
                min = 6,
                max = 40,
                get = function()
                    local cs = db.categorySettings and db.categorySettings.raid
                    if cs and cs.buffTextSize then
                        return cs.buffTextSize
                    end
                    -- Default: 80% of text size (matching current behavior)
                    local textSize = cs and cs.textSize
                    if not textSize then
                        local iconSize = (cs and cs.iconSize) or 64
                        textSize = math.floor(iconSize * 0.32)
                    end
                    return math.max(6, math.floor(textSize * 0.8))
                end,
                enabled = function()
                    local cs = db.categorySettings and db.categorySettings.raid
                    return not cs or cs.showBuffReminder ~= false
                end,
                onChange = function(val)
                    BR.Config.Set("categorySettings.raid.buffTextSize", val)
                end,
            })
            buffTextSizeHolder:SetPoint("LEFT", reminderHolder, "LEFT", 210, 0)
        end

        -- Click to cast checkbox
        if category ~= "custom" then
            local clickableHolder = Components.Checkbox(catContent, {
                label = "點擊來施放",
                get = function()
                    local cs = db.categorySettings and db.categorySettings[category]
                    return cs and cs.clickable == true
                end,
                tooltip = {
                    title = "點擊來施放",
                    desc = "使增益圖示可點擊以施放對應的法術（僅限非戰鬥中）。 "
                        .. "只適用於你的角色可以施放的法術。",
                },
                onChange = function(checked)
                    if not db.categorySettings then
                        db.categorySettings = {}
                    end
                    if not db.categorySettings[category] then
                        db.categorySettings[category] = {}
                    end
                    db.categorySettings[category].clickable = checked
                    BR.Display.UpdateActionButtons(category)
                    Components.RefreshAll()
                end,
            })
            catLayout:Add(clickableHolder, nil, 2)

            catLayout:SetX(20)
            local highlightHolder = Components.Checkbox(catContent, {
                label = "滑鼠懸停高亮",
                get = function()
                    local hcs = db.categorySettings and db.categorySettings[category]
                    return hcs and hcs.clickableHighlight ~= false
                end,
                enabled = function()
                    local hcs = db.categorySettings and db.categorySettings[category]
                    return hcs and hcs.clickable == true
                end,
                tooltip = {
                    title = "滑鼠懸停高亮",
                    desc = "將滑鼠懸停在可點擊的增益圖示上時顯示細微的高亮。",
                },
                onChange = function(checked)
                    if not db.categorySettings then
                        db.categorySettings = {}
                    end
                    if not db.categorySettings[category] then
                        db.categorySettings[category] = {}
                    end
                    db.categorySettings[category].clickableHighlight = checked
                    BR.Display.UpdateActionButtons(category)
                end,
            })
            catLayout:Add(highlightHolder, nil, COMPONENT_GAP)

            if category == "pet" then
                local specIconHolder = Components.Checkbox(catContent, {
                    label = "滑鼠懸停時顯示獵人寵物專精圖示",
                    get = function()
                        return BR.Config.Get("defaults.petSpecIconOnHover", true)
                    end,
                    enabled = function()
                        local hcs = db.categorySettings and db.categorySettings[category]
                        return hcs and hcs.clickable == true
                    end,
                    tooltip = {
                        title = "滑鼠懸停顯示寵物專精圖示",
                        desc = "Swap the pet icon to its specialization ability (Cunning, Ferocity, Tenacity) when hovering.",
                    },
                    onChange = function(checked)
                        BR.Config.Set("defaults.petSpecIconOnHover", checked)
                    end,
                })
                catLayout:Add(specIconHolder, nil, COMPONENT_GAP)
            end

            catLayout:SetX(0)
        end

        -- Behavior sub-header (pet only)
        if category == "pet" then
            catLayout:Space(SECTION_GAP)
            local behaviorHeader = catContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            behaviorHeader:SetText("|cffffcc00行為|r")
            catLayout:AddText(behaviorHeader, 12, COMPONENT_GAP)

            local hideMountHolder = Components.Checkbox(catContent, {
                label = "當上坐騎時隱藏",
                get = function()
                    return BuffRemindersDB.hidePetWhileMounted ~= false
                end,
                onChange = function(checked)
                    BuffRemindersDB.hidePetWhileMounted = checked
                    UpdateDisplay()
                end,
            })
            catLayout:Add(hideMountHolder, nil, COMPONENT_GAP)

            local passiveCombatHolder = Components.Checkbox(catContent, {
                label = "寵物被動僅在戰鬥中",
                get = function()
                    return BuffRemindersDB.petPassiveOnlyInCombat == true
                end,
                tooltip = {
                    title = "寵物被動僅在戰鬥中",
                    desc = "僅在戰鬥時顯示被動寵物提醒。停用時，始終顯示提醒。",
                },
                onChange = function(checked)
                    BuffRemindersDB.petPassiveOnlyInCombat = checked
                    UpdateDisplay()
                end,
            })
            catLayout:Add(passiveCombatHolder, nil, COMPONENT_GAP)

            local updatePetDisplayModePreview -- forward declaration for preview update
            local petDisplayModeHolder = Components.Dropdown(catContent, {
                label = "寵物顯示",
                width = 120,
                get = function()
                    return BR.Config.Get("defaults.petDisplayMode", "generic")
                end,
                options = {
                    { value = "generic", label = "通用圖示", desc = "單一通用的 '沒有寵物' 圖示。" },
                    { value = "expanded", label = "召喚法術", desc = "每個寵物召喚法術都有自己的圖示" },
                },
                tooltip = {
                    title = "寵物顯示模式",
                    desc = "如何顯示缺失寵物提醒。",
                },
                onChange = function(val)
                    BR.Config.Set("defaults.petDisplayMode", val)
                    if updatePetDisplayModePreview then
                        updatePetDisplayModePreview(val)
                    end
                end,
            })
            catLayout:Add(petDisplayModeHolder, nil, COMPONENT_GAP)

            -- Pet display mode preview (anchored to the right of the dropdown)
            local PP_ICON = 24
            local PP_BORDER = 2
            local PP_GAP = 3
            local PP_STEP = PP_ICON + PP_GAP + PP_BORDER * 2

            local TEX_PET_GENERIC = 136082 -- Summon Demon flyout icon
            local TEX_PETS = { 136218, 136221, 136217 } -- Imp, Voidwalker, Felhunter

            local petPreviewHeight = PP_ICON + PP_BORDER * 2
            local PET_MODE_ICON_COUNT = { generic = 1, expanded = 3 }

            local petPreviewHolder = CreateFrame("Frame", nil, catContent)
            petPreviewHolder:SetSize(PP_STEP, petPreviewHeight)
            petPreviewHolder:SetPoint("TOPLEFT", petDisplayModeHolder, "TOPRIGHT", 12, 0)

            local petPreviewContainer = CreateFrame("Frame", nil, petPreviewHolder)
            petPreviewContainer:SetPoint("TOPLEFT", 0, 0)
            petPreviewContainer:SetSize(3 * PP_STEP, petPreviewHeight)
            petPreviewContainer:SetAlpha(0.7)

            local function CreatePetPreviewIcon(parent, texture, size)
                local f = CreateFrame("Frame", nil, parent)
                f:SetSize(size, size)
                f.icon = f:CreateTexture(nil, "ARTWORK")
                f.icon:SetAllPoints()
                f.icon:SetTexture(texture)
                local z = TEXCOORD_INSET
                f.icon:SetTexCoord(z, 1 - z, z, 1 - z)
                f.border = f:CreateTexture(nil, "BACKGROUND")
                f.border:SetColorTexture(0, 0, 0, 1)
                f.border:SetPoint("TOPLEFT", -PP_BORDER, PP_BORDER)
                f.border:SetPoint("BOTTOMRIGHT", PP_BORDER, -PP_BORDER)
                return f
            end

            local allPetPreviewFrames = {}

            -- Generic: single icon
            local genericFrame = CreatePetPreviewIcon(petPreviewContainer, TEX_PET_GENERIC, PP_ICON)
            genericFrame:SetPoint("TOPLEFT", petPreviewContainer, "TOPLEFT", 0, 0)
            genericFrame:Hide()
            allPetPreviewFrames[#allPetPreviewFrames + 1] = genericFrame

            -- Expanded: individual summon spell icons
            local expandedPetFrames = {}
            for i = 1, 3 do
                local f = CreatePetPreviewIcon(petPreviewContainer, TEX_PETS[i], PP_ICON)
                f:SetPoint("TOPLEFT", petPreviewContainer, "TOPLEFT", (i - 1) * PP_STEP, 0)
                f:Hide()
                expandedPetFrames[i] = f
                allPetPreviewFrames[#allPetPreviewFrames + 1] = f
            end

            local PET_MODE_FRAMES = {
                generic = { genericFrame },
                expanded = expandedPetFrames,
            }
            updatePetDisplayModePreview = function(mode)
                for _, f in ipairs(allPetPreviewFrames) do
                    f:Hide()
                end
                local shown = PET_MODE_FRAMES[mode]
                if shown then
                    for _, f in ipairs(shown) do
                        f:Show()
                    end
                end
                petPreviewHolder:SetWidth((PET_MODE_ICON_COUNT[mode] or 1) * PP_STEP)
            end

            -- Initial state
            updatePetDisplayModePreview(BR.Config.Get("defaults.petDisplayMode", "generic"))

            -- Register for refresh so reopening the panel re-reads the value
            function petPreviewHolder:Refresh()
                updatePetDisplayModePreview(BR.Config.Get("defaults.petDisplayMode", "generic"))
            end
            table.insert(BR.RefreshableComponents, petPreviewHolder)

            local petLabelsHolder = Components.Checkbox(catContent, {
                label = "Pet labels",
                get = function()
                    return BR.Config.Get("defaults.petLabels", true)
                end,
                tooltip = {
                    title = "寵物標籤",
                    desc = "在每個圖示下方顯示寵物名稱和專精。",
                },
                onChange = function(checked)
                    BR.Config.Set("defaults.petLabels", checked)
                    Components.RefreshAll()
                end,
            })
            catLayout:Add(petLabelsHolder, nil, COMPONENT_GAP)

            local petLabelScaleHolder = Components.NumericStepper(petLabelsHolder, {
                label = "大小 %",
                labelWidth = 36,
                min = 50,
                max = 200,
                step = 10,
                get = function()
                    return BR.Config.Get("defaults.petLabelScale", 100)
                end,
                enabled = function()
                    return BR.Config.Get("defaults.petLabels", true)
                end,
                onChange = function(val)
                    BR.Config.Set("defaults.petLabelScale", val)
                end,
            })
            petLabelScaleHolder:SetPoint("LEFT", petLabelsHolder, "LEFT", 90, 0)

            -- Pet class label toggles (H/W/D/M) — anchored to the right of the scale stepper
            local function classColor(cls)
                local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[cls]
                if c then
                    return { c.r, c.g, c.b }
                end
                return { 0.5, 0.5, 0.5 }
            end

            local petClassBar, petClassButtons = Components.CreateSegmentedBar(petLabelsHolder, {
                toggleDefs = {
                    { key = "HUNTER", label = "H", tooltip = "獵人", color = classColor("HUNTER") },
                    { key = "WARLOCK", label = "W", tooltip = "術士", color = classColor("WARLOCK") },
                    { key = "DEATHKNIGHT", label = "D", tooltip = "死亡騎士", color = classColor("DEATHKNIGHT") },
                    { key = "MAGE", label = "M", tooltip = "法師", color = classColor("MAGE") },
                },
                getState = function(key)
                    local vis = BuffRemindersDB.defaults.petLabelClasses
                    return not vis or vis[key] ~= false
                end,
                setState = function(key)
                    if not BuffRemindersDB.defaults.petLabelClasses then
                        BuffRemindersDB.defaults.petLabelClasses = {
                            HUNTER = true,
                            WARLOCK = true,
                            DEATHKNIGHT = true,
                            MAGE = true,
                        }
                    end
                    BuffRemindersDB.defaults.petLabelClasses[key] = not BuffRemindersDB.defaults.petLabelClasses[key]
                end,
                onChange = function()
                    UpdateDisplay()
                end,
            })
            petClassBar:SetPoint("LEFT", petLabelScaleHolder, "RIGHT", 8, 0)

            local function isPetLabelsEnabled()
                return BR.Config.Get("defaults.petLabels", true)
            end
            petClassBar:SetBarDisabled(not isPetLabelsEnabled())

            local petClassBarRefreshHolder = CreateFrame("Frame", nil, petLabelsHolder)
            petClassBarRefreshHolder:SetSize(1, 1)
            function petClassBarRefreshHolder:Refresh()
                petClassBar:SetBarDisabled(not isPetLabelsEnabled())
                for _, btn in ipairs(petClassButtons) do
                    btn.UpdateVisual()
                end
            end
            table.insert(BR.RefreshableComponents, petClassBarRefreshHolder)
        end

        -- Item display mode (consumable only, grouped with icon options)
        if category == "consumable" then
            local updateDisplayModePreview -- forward declaration for preview update
            local updateSubIconSideVisibility -- forward declaration for sub-icon side visibility
            local displayModeHolder = Components.Dropdown(catContent, {
                label = "物品顯示",
                get = function()
                    return BR.Config.Get("defaults.consumableDisplayMode", "sub_icons")
                end,
                options = {
                    { value = "icon_only", label = "只有圖示", desc = "顯示次數最高的物品" },
                    {
                        value = "sub_icons",
                        label = "Sub-icons",
                        desc = "每個圖示下方可點擊的各種小物品",
                    },
                    { value = "expanded", label = "開展", desc = "每種物品都為全尺寸圖示" },
                },
                tooltip = {
                    title = "消耗物品顯示",
                    desc = "如何顯示具有多種類型的消耗品 (例如：不同類型的精鍊)。",
                },
                onChange = function(val)
                    BR.Config.Set("defaults.consumableDisplayMode", val)
                    if updateDisplayModePreview then
                        updateDisplayModePreview(val)
                    end
                    if updateSubIconSideVisibility then
                        updateSubIconSideVisibility(val)
                    end
                end,
            })
            catLayout:Add(displayModeHolder, nil, COMPONENT_GAP)

            -- Display mode preview (anchored to the right of the dropdown)
            local P_ICON = 24
            local P_SUB = 12
            local P_BORDER = 2
            local P_GAP = 3
            local P_STEP = P_ICON + P_GAP + P_BORDER * 2
            local P_SUB_STEP = P_SUB + P_BORDER * 2 -- sub-icons touch borders
            -- Distinct textures for flask/food/oil and their variants
            local TEX_FLASK = { 134877, 134863, 134852 } -- main + 2 other variants
            local TEX_FOOD = { 134062, 133984 } -- main + 1 other variant
            local TEX_OIL = 609892

            local previewHeight = P_ICON + P_SUB + P_GAP + P_BORDER * 2
            local MODE_ICON_COUNT = { icon_only = 3, sub_icons = 3, expanded = 6 }

            local previewHolder = CreateFrame("Frame", nil, catContent)
            previewHolder:SetSize(3 * P_STEP, previewHeight)
            previewHolder:SetPoint("TOPLEFT", displayModeHolder, "TOPRIGHT", 12, 0)

            local previewContainer = CreateFrame("Frame", nil, previewHolder)
            previewContainer:SetPoint("TOPLEFT", 0, 0)
            previewContainer:SetSize(6 * P_STEP, previewHeight)
            previewContainer:SetAlpha(0.7)

            local function CreatePreviewIcon(parent, texture, size)
                local f = CreateFrame("Frame", nil, parent)
                f:SetSize(size, size)
                f.icon = f:CreateTexture(nil, "ARTWORK")
                f.icon:SetAllPoints()
                f.icon:SetTexture(texture)
                local z = TEXCOORD_INSET
                f.icon:SetTexCoord(z, 1 - z, z, 1 - z)
                f.border = f:CreateTexture(nil, "BACKGROUND")
                f.border:SetColorTexture(0, 0, 0, 1)
                f.border:SetPoint("TOPLEFT", -P_BORDER, P_BORDER)
                f.border:SetPoint("BOTTOMRIGHT", P_BORDER, -P_BORDER)
                return f
            end

            local allPreviewFrames = {}

            -- Icon-only: [Flask] [Food] [Oil]
            local iconOnlyFrames = {}
            local iconOnlyTextures = { TEX_FLASK[1], TEX_FOOD[1], TEX_OIL }
            for i = 1, 3 do
                local f = CreatePreviewIcon(previewContainer, iconOnlyTextures[i], P_ICON)
                f:SetPoint("TOPLEFT", previewContainer, "TOPLEFT", (i - 1) * P_STEP, 0)
                f:Hide()
                iconOnlyFrames[i] = f
                allPreviewFrames[#allPreviewFrames + 1] = f
            end

            -- Sub-icons: [Flask] [Food] [Oil] with variant sub-icons below
            local subIconsFrames = { mains = {}, subs = {} }
            local subVariants = { TEX_FLASK, TEX_FOOD, {} } -- oil has no variants
            for i, variants in ipairs(subVariants) do
                local mainTex = (#variants > 0) and variants[1] or TEX_OIL
                local main = CreatePreviewIcon(previewContainer, mainTex, P_ICON)
                main:SetPoint("TOPLEFT", previewContainer, "TOPLEFT", (i - 1) * P_STEP, 0)
                main:Hide()
                subIconsFrames.mains[i] = main
                allPreviewFrames[#allPreviewFrames + 1] = main
                if #variants > 1 then
                    local subCount = #variants - 1
                    local subRowWidth = (subCount - 1) * P_SUB_STEP + P_SUB
                    local subOffsetX = (P_ICON - subRowWidth) / 2
                    for j = 2, #variants do
                        local sub = CreatePreviewIcon(previewContainer, variants[j], P_SUB)
                        sub:SetPoint("TOPLEFT", main, "BOTTOMLEFT", subOffsetX + (j - 2) * P_SUB_STEP, -P_GAP)
                        sub:Hide()
                        subIconsFrames.subs[#subIconsFrames.subs + 1] = sub
                        allPreviewFrames[#allPreviewFrames + 1] = sub
                    end
                end
            end

            -- Expanded: [F1][F2][F3][Fd1][Fd2][Oil] — each variant at full size
            local expandedFrames = {}
            local expandedTextures = {
                TEX_FLASK[1],
                TEX_FLASK[2],
                TEX_FLASK[3],
                TEX_FOOD[1],
                TEX_FOOD[2],
                TEX_OIL,
            }
            for i = 1, 6 do
                local f = CreatePreviewIcon(previewContainer, expandedTextures[i], P_ICON)
                f:SetPoint("TOPLEFT", previewContainer, "TOPLEFT", (i - 1) * P_STEP, 0)
                f:Hide()
                expandedFrames[i] = f
                allPreviewFrames[#allPreviewFrames + 1] = f
            end

            -- Combine sub-icons mains + subs into one flat list
            local subIconsAll = {}
            for _, f in ipairs(subIconsFrames.mains) do
                subIconsAll[#subIconsAll + 1] = f
            end
            for _, f in ipairs(subIconsFrames.subs) do
                subIconsAll[#subIconsAll + 1] = f
            end

            local MODE_FRAMES = {
                icon_only = iconOnlyFrames,
                sub_icons = subIconsAll,
                expanded = expandedFrames,
            }
            updateDisplayModePreview = function(mode)
                for _, f in ipairs(allPreviewFrames) do
                    f:Hide()
                end
                local shown = MODE_FRAMES[mode]
                if shown then
                    for _, f in ipairs(shown) do
                        f:Show()
                    end
                end
                previewHolder:SetWidth((MODE_ICON_COUNT[mode] or 3) * P_STEP)
            end

            -- Initial state
            updateDisplayModePreview(BR.Config.Get("defaults.consumableDisplayMode", "sub_icons"))

            -- Register for refresh so reopening the panel re-reads the value
            function previewHolder:Refresh()
                updateDisplayModePreview(BR.Config.Get("defaults.consumableDisplayMode", "sub_icons"))
            end
            table.insert(BR.RefreshableComponents, previewHolder)

            -- Sub-icon placement side (anchored below preview, visible only in sub_icons mode)
            local subIconSideHolder = Components.Dropdown(catContent, {
                label = "位置",
                labelWidth = 30,
                width = 85,
                get = function()
                    local catSettings = db.categorySettings and db.categorySettings[category]
                    return catSettings and catSettings.subIconSide or "BOTTOM"
                end,
                options = {
                    { value = "BOTTOM", label = "底部" },
                    { value = "TOP", label = "頂部" },
                    { value = "LEFT", label = "左側" },
                    { value = "RIGHT", label = "右側" },
                },
                onChange = function(val)
                    BR.Config.Set("categorySettings." .. category .. ".subIconSide", val)
                end,
            })
            subIconSideHolder:SetPoint("TOPLEFT", previewHolder, "TOPRIGHT", 12, 0)

            updateSubIconSideVisibility = function(mode)
                subIconSideHolder:SetShown(mode == "sub_icons")
            end
            updateSubIconSideVisibility(BR.Config.Get("defaults.consumableDisplayMode", "sub_icons"))

            -- Sub-header for behavior options
            catLayout:Space(SECTION_GAP)
            local behaviorHeader = catContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            behaviorHeader:SetText("|cffffcc00行為|r")
            catLayout:AddText(behaviorHeader, 12, COMPONENT_GAP)

            local showWithoutItemsHolder = Components.Checkbox(catContent, {
                label = "顯示不在背包的消耗品",
                get = function()
                    return BR.Config.Get("defaults.showConsumablesWithoutItems", false) == true
                end,
                tooltip = {
                    title = "顯示沒有物品的消耗品",
                    desc = "啟用後，即使您的包包中沒有該物品，也會顯示消耗品提醒。停用時，僅顯示您實際攜帶的消耗品。",
                },
                onChange = function(checked)
                    BR.Config.Set("defaults.showConsumablesWithoutItems", checked)
                end,
            })
            catLayout:Add(showWithoutItemsHolder, nil, COMPONENT_GAP)
        end

        -- Layout sub-header
        catLayout:Space(SECTION_GAP)
        local layoutHeader = catContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        layoutHeader:SetText("|cffffcc00佈局|r")
        catLayout:AddText(layoutHeader, 12, COMPONENT_GAP)

        -- Priority slider (only relevant when not split)
        local priorityHolder = Components.Slider(catContent, {
            label = "優先級",
            min = 1,
            max = 7,
            step = 1,
            get = function()
                local cs = db.categorySettings and db.categorySettings[category]
                return cs and cs.priority or defaults.categorySettings[category].priority
            end,
            enabled = function()
                return not IsCategorySplit(category)
            end,
            tooltip = {
                title = "顯示優先級",
                desc = "控制該類別在組合框架中的順序。首先顯示較低的值。",
            },
            onChange = function(val)
                BR.Config.Set("categorySettings." .. category .. ".priority", val)
            end,
        })
        catLayout:Add(priorityHolder, nil, COMPONENT_GAP)

        -- Split frame checkbox
        local splitHolder = Components.Checkbox(catContent, {
            label = "分割成單獨的框架",
            get = function()
                return IsCategorySplit(category)
            end,
            tooltip = {
                title = "分割成單獨的框架",
                desc = "在單獨的以及可獨立移動的框架中顯示此類別的增益",
            },
            onChange = function(checked)
                if not db.categorySettings then
                    db.categorySettings = {}
                end
                if not db.categorySettings[category] then
                    db.categorySettings[category] = {}
                end
                db.categorySettings[category].split = checked
                ReparentBuffFrames()
                UpdateVisuals()
            end,
        })
        catLayout:Add(splitHolder, nil, COMPONENT_GAP)

        -- Reset position button (only relevant when split)
        local resetBtn = CreateButton(catContent, "重設位置", function()
            local catDefaults = defaults.categorySettings[category]
            if catDefaults and catDefaults.position then
                ResetCategoryFramePosition(category, catDefaults.position.x, catDefaults.position.y)
            end
        end)
        resetBtn:SetPoint("LEFT", splitHolder, "RIGHT", 10, 0)
        resetBtn:SetEnabled(IsCategorySplit(category))

        local origSplitClick = splitHolder.checkbox:GetScript("OnClick")
        splitHolder.checkbox:SetScript("OnClick", function(self)
            if origSplitClick then
                origSplitClick(self)
            end
            resetBtn:SetEnabled(IsCategorySplit(category))
            Components.RefreshAll()
        end)

        -- Shared enabled predicates for this category
        local function isCustomAppearanceEnabled()
            return db.categorySettings
                and db.categorySettings[category]
                and db.categorySettings[category].useCustomAppearance == true
        end

        -- Use custom appearance checkbox
        catLayout:SetX(0)
        local useCustomAppHolder = Components.Checkbox(catContent, {
            label = "使用自訂外觀",
            get = function()
                return db.categorySettings
                    and db.categorySettings[category]
                    and db.categorySettings[category].useCustomAppearance == true
            end,
            tooltip = {
                title = "使用自訂外觀",
                desc = "停用時，此類別繼承全域預設值的外觀設置。延展方向需要分離成一個單獨的框架。",
            },
            onChange = function(checked)
                if not db.categorySettings then
                    db.categorySettings = {}
                end
                if not db.categorySettings[category] then
                    db.categorySettings[category] = {}
                end
                -- When enabling custom appearance, snapshot current effective values
                -- so the category starts independent from future Global Defaults changes
                if checked then
                    local effective = GetCategorySettings(category)
                    local cs = db.categorySettings[category]
                    local appearanceKeys = {
                        "iconSize",
                        "spacing",
                        "iconZoom",
                        "borderSize",
                        "iconAlpha",
                        "textAlpha",
                        "growDirection",
                    }
                    for _, key in ipairs(appearanceKeys) do
                        if cs[key] == nil and effective[key] ~= nil then
                            cs[key] = effective[key]
                        end
                    end
                    -- textSize: only snapshot if explicitly set (nil = auto-derive from iconSize)
                    if cs.textSize == nil and effective.textSize ~= nil then
                        cs.textSize = effective.textSize
                    end
                    -- textColor: deep copy (table value)
                    if cs.textColor == nil and effective.textColor then
                        local tc = effective.textColor
                        cs.textColor = { tc[1], tc[2], tc[3] }
                    end
                end
                BR.Config.Set("categorySettings." .. category .. ".useCustomAppearance", checked)
                Components.RefreshAll()
            end,
        })
        catLayout:Add(useCustomAppHolder, nil, COMPONENT_GAP)

        -- Direction buttons (part of custom appearance)
        catLayout:SetX(10)
        local dirHolder = Components.DirectionButtons(catContent, {
            get = function()
                local catSettings = db.categorySettings and db.categorySettings[category]
                local val = catSettings and catSettings.growDirection
                if val ~= nil then
                    return val
                end
                return db.defaults and db.defaults.growDirection or "CENTER"
            end,
            enabled = function()
                return isCustomAppearanceEnabled() and IsCategorySplit(category)
            end,
            onChange = function(dir)
                BR.Config.Set("categorySettings." .. category .. ".growDirection", dir)
            end,
        })
        catLayout:Add(dirHolder, nil, COMPONENT_GAP + DROPDOWN_EXTRA)

        -- Appearance controls (3-row grid with fixed columns)
        catLayout:SetX(10)
        local appFrame = CreateFrame("Frame", nil, catContent)
        appFrame:SetSize(380, 50)
        catLayout:SetX(10)
        catLayout:Add(appFrame, 0)

        -- Read the category's own saved value, falling back to defaults only if no value was saved.
        -- This avoids showing inherited defaults when useCustomAppearance is off, so toggling
        -- custom appearance off/on preserves the user's previously configured values.
        local function getCatOwnValue(key, default)
            local catSettings = db.categorySettings and db.categorySettings[category]
            local val = catSettings and catSettings[key]
            if val ~= nil then
                return val
            end
            return db.defaults and db.defaults[key] or default
        end

        local CAT_LW = 50 -- Shared label width for aligned columns
        local CAT_COL2 = CAT_LW + 100 + 60 + 10 -- labelWidth + slider + value + gap = 220

        local sizeHolder = Components.Slider(appFrame, {
            label = "大小",
            min = 16,
            max = 128,
            labelWidth = CAT_LW,
            get = function()
                return getCatOwnValue("iconSize", 64)
            end,
            enabled = isCustomAppearanceEnabled,
            onChange = function(val)
                BR.Config.Set("categorySettings." .. category .. ".iconSize", val)
            end,
        })
        sizeHolder:SetPoint("TOPLEFT", 0, 0)

        local zoomHolder = Components.Slider(appFrame, {
            label = "縮放",
            min = 0,
            max = 15,
            labelWidth = CAT_LW,
            get = function()
                return getCatOwnValue("iconZoom", DEFAULT_ICON_ZOOM)
            end,
            enabled = function()
                return isCustomAppearanceEnabled() and not IsMasqueActive()
            end,
            suffix = "%",
            onChange = function(val)
                BR.Config.Set("categorySettings." .. category .. ".iconZoom", val)
            end,
        })
        zoomHolder:SetPoint("TOPLEFT", CAT_COL2, 0)

        local borderHolder = Components.Slider(appFrame, {
            label = "邊框",
            min = 0,
            max = 8,
            labelWidth = CAT_LW,
            get = function()
                return getCatOwnValue("borderSize", DEFAULT_BORDER_SIZE)
            end,
            enabled = function()
                return isCustomAppearanceEnabled() and not IsMasqueActive()
            end,
            suffix = "px",
            onChange = function(val)
                BR.Config.Set("categorySettings." .. category .. ".borderSize", val)
            end,
        })
        borderHolder:SetPoint("TOPLEFT", 0, -24)

        local catAlphaHolder = Components.Slider(appFrame, {
            label = "透明度",
            min = 10,
            max = 100,
            labelWidth = CAT_LW,
            get = function()
                return math.floor((getCatOwnValue("iconAlpha", 1)) * 100)
            end,
            enabled = isCustomAppearanceEnabled,
            suffix = "%",
            onChange = function(val)
                BR.Config.Set("categorySettings." .. category .. ".iconAlpha", val / 100)
            end,
        })
        catAlphaHolder:SetPoint("TOPLEFT", CAT_COL2, -24)

        local spacingHolder = Components.Slider(appFrame, {
            label = "間距",
            min = 0,
            max = 50,
            labelWidth = CAT_LW,
            get = function()
                return math.floor((getCatOwnValue("spacing", 0.2)) * 100)
            end,
            enabled = isCustomAppearanceEnabled,
            suffix = "%",
            onChange = function(val)
                BR.Config.Set("categorySettings." .. category .. ".spacing", val / 100)
            end,
        })
        spacingHolder:SetPoint("TOPLEFT", 0, -48)

        local catTextSizeHolder = Components.NumericStepper(appFrame, {
            label = "文字",
            labelWidth = CAT_LW,
            min = 6,
            max = 32,
            get = function()
                local textSize = getCatOwnValue("textSize", nil)
                if textSize then
                    return textSize
                end
                -- Auto: derive from icon size
                local iconSize = getCatOwnValue("iconSize", 64)
                return math.floor(iconSize * 0.32)
            end,
            enabled = isCustomAppearanceEnabled,
            onChange = function(val)
                BR.Config.Set("categorySettings." .. category .. ".textSize", val)
            end,
        })
        catTextSizeHolder:SetPoint("TOPLEFT", CAT_COL2, -48)

        local catTextColorHolder = Components.ColorSwatch(appFrame, {
            hasOpacity = true,
            get = function()
                local tc = getCatOwnValue("textColor", { 1, 1, 1 })
                local ta = getCatOwnValue("textAlpha", 1)
                return tc[1], tc[2], tc[3], ta
            end,
            enabled = isCustomAppearanceEnabled,
            onChange = function(r, g, b, a)
                BR.Config.SetMulti({
                    ["categorySettings." .. category .. ".textColor"] = { r, g, b },
                    ["categorySettings." .. category .. ".textAlpha"] = a or 1,
                })
            end,
        })
        catTextColorHolder:SetPoint("LEFT", catTextSizeHolder, "RIGHT", 12, 0) -- aligns alpha % with slider values

        -- Row 4: Glow settings
        local gridHeight
        if category == "pet" then
            -- Pets don't expire — single "Glow when missing" checkbox
            -- (sets both showExpirationGlow and glowWhenMissing under the hood)
            local catPetGlowHolder = Components.Checkbox(appFrame, {
                label = "缺少時發光",
                get = function()
                    return getCatOwnValue("showExpirationGlow", true) ~= false
                        and getCatOwnValue("glowWhenMissing", true) ~= false
                end,
                enabled = isCustomAppearanceEnabled,
                onChange = function(checked)
                    BR.Config.SetMulti({
                        ["categorySettings." .. category .. ".showExpirationGlow"] = checked,
                        ["categorySettings." .. category .. ".glowWhenMissing"] = checked,
                    })
                end,
            })
            catPetGlowHolder:SetPoint("TOPLEFT", 0, -72)

            local catGlowTypeOptions = {}
            for gi, gt in ipairs(GlowTypes) do
                catGlowTypeOptions[gi] = { label = gt.name, value = gi }
            end

            local function isPetGlowEnabled()
                return isCustomAppearanceEnabled()
                    and getCatOwnValue("showExpirationGlow", true) ~= false
                    and getCatOwnValue("glowWhenMissing", true) ~= false
            end

            local catGlowTypeHolder = Components.Dropdown(appFrame, {
                label = "類型:",
                labelWidth = CAT_LW,
                options = catGlowTypeOptions,
                get = function()
                    return getCatOwnValue("glowType", 1)
                end,
                enabled = isPetGlowEnabled,
                width = 130,
                onChange = function(val)
                    BR.Config.Set("categorySettings." .. category .. ".glowType", val)
                end,
            }, "BuffReminders_" .. category .. "_GlowTypeDropdown")
            catGlowTypeHolder:SetPoint("TOPLEFT", CAT_COL2, -72)

            local catUseCustomColorHolder = Components.Checkbox(appFrame, {
                label = "顏色",
                tooltip = "Use a custom glow color instead of the default.\nWhen off, glows use the native library color which looks more vibrant.",
                get = function()
                    return getCatOwnValue("useCustomGlowColor", false)
                end,
                enabled = isPetGlowEnabled,
                onChange = function(checked)
                    BR.Config.Set("categorySettings." .. category .. ".useCustomGlowColor", checked)
                    Components.RefreshAll()
                end,
            })
            local catGlowColorHolder = Components.ColorSwatch(appFrame, {
                hasOpacity = true,
                get = function()
                    local c = getCatOwnValue("glowColor", Glow.DEFAULT_COLOR)
                    return c[1], c[2], c[3], c[4] or 1
                end,
                enabled = function()
                    return isPetGlowEnabled() and (getCatOwnValue("useCustomGlowColor", false) or false)
                end,
                onChange = function(r, g, b, a)
                    BR.Config.Set("categorySettings." .. category .. ".glowColor", { r, g, b, a or 1 })
                end,
            })
            local catGlowSizeHolder = Components.NumericStepper(appFrame, {
                label = "大小:",
                labelWidth = CAT_LW,
                min = 1,
                max = 5,
                step = 1,
                get = function()
                    return getCatOwnValue("glowSize", 2)
                end,
                enabled = isPetGlowEnabled,
                onChange = function(val)
                    BR.Config.Set("categorySettings." .. category .. ".glowSize", val)
                end,
            })
            catGlowSizeHolder:SetPoint("TOPLEFT", CAT_COL2, -96)
            catUseCustomColorHolder:SetPoint("LEFT", catGlowSizeHolder, "RIGHT", 6, 0)
            catGlowColorHolder:SetPoint("LEFT", catUseCustomColorHolder.label, "RIGHT", 4, 0)

            gridHeight = 120 -- 5 rows (glow + size)
        else
            local function isGlowEnabled()
                return isCustomAppearanceEnabled() and getCatOwnValue("showExpirationGlow", true) ~= false
            end

            local catGlowCheckHolder = Components.Checkbox(appFrame, {
                label = "發光",
                get = function()
                    return getCatOwnValue("showExpirationGlow", true) ~= false
                end,
                enabled = isCustomAppearanceEnabled,
                onChange = function(checked)
                    BR.Config.Set("categorySettings." .. category .. ".showExpirationGlow", checked)
                    Components.RefreshAll()
                end,
            })
            catGlowCheckHolder:SetPoint("TOPLEFT", 0, -72)

            local catGlowThresholdHolder = Components.Slider(appFrame, {
                min = 1,
                max = 45,
                step = 5,
                suffix = " min",
                get = function()
                    return getCatOwnValue("expirationThreshold", 15)
                end,
                enabled = isGlowEnabled,
                onChange = function(val)
                    BR.Config.Set("categorySettings." .. category .. ".expirationThreshold", val)
                end,
            })
            catGlowThresholdHolder:SetPoint("LEFT", catGlowCheckHolder.checkbox, "RIGHT", 40, 0)

            local catGlowTypeOptions = {}
            for gi, gt in ipairs(GlowTypes) do
                catGlowTypeOptions[gi] = { label = gt.name, value = gi }
            end

            local catGlowTypeHolder = Components.Dropdown(appFrame, {
                label = "類型:",
                labelWidth = CAT_LW,
                options = catGlowTypeOptions,
                get = function()
                    return getCatOwnValue("glowType", 1)
                end,
                enabled = isGlowEnabled,
                width = 130,
                onChange = function(val)
                    BR.Config.Set("categorySettings." .. category .. ".glowType", val)
                end,
            }, "BuffReminders_" .. category .. "_GlowTypeDropdown")
            catGlowTypeHolder:SetPoint("TOPLEFT", CAT_COL2, -72)

            local catUseCustomColorHolder = Components.Checkbox(appFrame, {
                label = "顏色",
                tooltip = "使用自訂發光顏色而不是預設顏色。\n關閉時，發光使用原生顏色，看起來更加鮮豔。",
                get = function()
                    return getCatOwnValue("useCustomGlowColor", false)
                end,
                enabled = isGlowEnabled,
                onChange = function(checked)
                    BR.Config.Set("categorySettings." .. category .. ".useCustomGlowColor", checked)
                    Components.RefreshAll()
                end,
            })
            local catGlowColorHolder = Components.ColorSwatch(appFrame, {
                hasOpacity = true,
                get = function()
                    local c = getCatOwnValue("glowColor", Glow.DEFAULT_COLOR)
                    return c[1], c[2], c[3], c[4] or 1
                end,
                enabled = function()
                    return isGlowEnabled() and (getCatOwnValue("useCustomGlowColor", false) or false)
                end,
                onChange = function(r, g, b, a)
                    BR.Config.Set("categorySettings." .. category .. ".glowColor", { r, g, b, a or 1 })
                end,
            })

            local catGlowSizeHolder = Components.NumericStepper(appFrame, {
                label = "大小:",
                labelWidth = CAT_LW,
                min = 1,
                max = 5,
                step = 1,
                get = function()
                    return getCatOwnValue("glowSize", 2)
                end,
                enabled = isGlowEnabled,
                onChange = function(val)
                    BR.Config.Set("categorySettings." .. category .. ".glowSize", val)
                end,
            })

            local catGlowWhenMissingHolder = Components.Checkbox(appFrame, {
                label = "也在缺少時",
                tooltip = "Show glow on buff icons that are completely missing, not just expiring.",
                get = function()
                    return getCatOwnValue("glowWhenMissing", true) ~= false
                end,
                enabled = isGlowEnabled,
                onChange = function(checked)
                    BR.Config.Set("categorySettings." .. category .. ".glowWhenMissing", checked)
                end,
            })
            catGlowWhenMissingHolder:SetPoint("TOPLEFT", 20, -96)
            catGlowSizeHolder:SetPoint("TOPLEFT", CAT_COL2, -96)
            catUseCustomColorHolder:SetPoint("LEFT", catGlowSizeHolder, "RIGHT", 6, 0)
            catGlowColorHolder:SetPoint("LEFT", catUseCustomColorHolder.label, "RIGHT", 4, 0)

            gridHeight = 120 -- 5 rows with glow + when missing
        end

        -- Advance past the appFrame grid and finalize section height
        catLayout:Space(gridHeight)
        catLayout:SetX(0)

        section:SetContentHeight(math.abs(catLayout:GetY()) + 10)
        table.insert(categorySections, section)
        previousSection = section
    end

    UpdateAppearanceContentHeight()

    -- ========== SETTINGS TAB ==========
    -- Simple frame (not scrollable) - content fits without scrolling
    local settingsContent = CreateFrame("Frame", nil, panel)
    settingsContent:SetPoint("TOPLEFT", 0, CONTENT_TOP)
    settingsContent:SetSize(PANEL_WIDTH, 300)
    settingsContent:Hide()
    contentContainers.settings = settingsContent

    local setX = COL_PADDING
    local setLayout = Components.VerticalLayout(settingsContent, { x = setX, y = -10 })

    local loginMsgHolder = Components.Checkbox(settingsContent, {
        label = "顯示登入訊息",
        get = function()
            return BuffRemindersDB.showLoginMessages ~= false
        end,
        onChange = function(checked)
            BuffRemindersDB.showLoginMessages = checked
        end,
    })
    setLayout:Add(loginMsgHolder, nil, COMPONENT_GAP)

    -- General Settings section
    LayoutSectionHeader(setLayout, settingsContent, "可視性")

    local groupHolder = Components.Checkbox(settingsContent, {
        label = "只有在隊伍/團隊中顯示",
        get = function()
            return BuffRemindersDB.showOnlyInGroup ~= false
        end,
        onChange = function(checked)
            BuffRemindersDB.showOnlyInGroup = checked
            UpdateDisplay()
        end,
    })
    setLayout:Add(groupHolder, nil, COMPONENT_GAP)

    local restingHolder = Components.Checkbox(settingsContent, {
        label = "休息狀態時隱藏",
        get = function()
            return BuffRemindersDB.hideWhileResting == true
        end,
        tooltip = { title = "休息狀態時隱藏", desc = "在旅館或主城時隱藏增益提醒" },
        onChange = function(checked)
            BuffRemindersDB.hideWhileResting = checked
            UpdateDisplay()
        end,
    })
    setLayout:Add(restingHolder, nil, COMPONENT_GAP)

    local combatHolder = Components.Checkbox(settingsContent, {
        label = "戰鬥中隱藏",
        get = function()
            return BuffRemindersDB.hideInCombat == true
        end,
        onChange = function(checked)
            BuffRemindersDB.hideInCombat = checked
            UpdateDisplay()
        end,
    })
    setLayout:Add(combatHolder, nil, COMPONENT_GAP)

    local combatExpiringHolder = Components.Checkbox(settingsContent, {
        label = "戰鬥中隱藏過期",
        tooltip = "透過僅顯示完全缺少的增益效果（而不是仍然有效但即將過期的增益效果）來減少戰鬥期間的混亂。",
        get = function()
            return BuffRemindersDB.hideExpiringInCombat ~= false
        end,
        enabled = function()
            return BuffRemindersDB.hideInCombat ~= true
        end,
        onChange = function(checked)
            BuffRemindersDB.hideExpiringInCombat = checked
            UpdateDisplay()
        end,
    })
    setLayout:Add(combatExpiringHolder, nil, COMPONENT_GAP)

    local vehicleHolder = Components.Checkbox(settingsContent, {
        label = "載具中隱藏",
        tooltip = { title = "載具中隱藏", desc = "在任務載具中隱藏所有增益提醒。禁用後，團隊和在場增益仍然顯示" },
        get = function()
            return BuffRemindersDB.hideAllInVehicle == true
        end,
        onChange = function(checked)
            BuffRemindersDB.hideAllInVehicle = checked
            UpdateDisplay()
        end,
    })
    setLayout:Add(vehicleHolder, nil, COMPONENT_GAP)

    local trackingModeHolder = Components.Dropdown(settingsContent, {
        label = "增益追蹤",
        width = 200,
        options = {
            {
                value = "all",
                label = "全部增益，全部玩家",
                desc = "顯示每個職業的所有團隊和在場增益，追蹤完整的團隊覆蓋範圍。",
            },
            {
                value = "my_buffs",
                label = "只有我的增益，全部玩家",
                desc = "只顯示你的職業可以提供的增益。仍然追踪完整的團隊範圍。",
            },
            {
                value = "personal",
                label = "只有我需要的增益",
                desc = "顯示所有增益類型，但僅檢查您個人是否擁有它們。沒有團體計數。",
            },
            {
                value = "smart",
                label = "智能",
                desc = "針對全隊範圍追蹤您的職業能提供的增益。其他職業增益只檢查你個人。",
            },
        },
        get = function()
            return BR.Config.Get("buffTrackingMode", "all")
        end,
        tooltip = {
            title = "增益追蹤模式",
            desc = "控制顯示哪些團隊和在場增益，以及它們是否追蹤整個團隊或僅追蹤您。",
        },
        onChange = function(val)
            BR.Config.Set("buffTrackingMode", val)
            UpdateDisplay()
        end,
    })
    setLayout:Add(trackingModeHolder, nil, COMPONENT_GAP)

    LayoutSectionHeader(setLayout, settingsContent, "Danger zone")

    local resetBtn = CreateButton(settingsContent, "重置回預設", function()
        StaticPopup_Show("BUFFREMINDERS_RESET_DEFAULTS")
    end, {
        title = "重置回預設",
        desc = "清除所有設定並恢復到預設，這會重載UI。",
    })
    resetBtn:SetSize(130, 22)
    setLayout:Add(resetBtn)

    -- ========== IMPORT/EXPORT TAB ==========
    -- Use simple frame (not scrollable) to avoid nested scroll frame issues with edit boxes
    local profilesContent = CreateFrame("Frame", nil, panel)
    profilesContent:SetPoint("TOPLEFT", 0, CONTENT_TOP)
    profilesContent:SetSize(PANEL_WIDTH, 500)
    profilesContent:Hide()
    contentContainers.profiles = profilesContent

    local profX = COL_PADDING
    local profLayout = Components.VerticalLayout(profilesContent, { x = profX, y = -10 })

    -- Export section
    LayoutSectionHeader(profLayout, profilesContent, "匯出設定")

    local exportDesc = profilesContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    exportDesc:SetText("複製下面的字串以與其他人分享您的設定。")
    profLayout:AddText(exportDesc, 12, COMPONENT_GAP)

    local exportTextArea = Components.TextArea(profilesContent, {
        width = PANEL_WIDTH - COL_PADDING * 2 - SCROLLBAR_WIDTH,
        height = 80,
    })
    profLayout:Add(exportTextArea, 80, COMPONENT_GAP)

    local exportButton = CreateButton(profilesContent, "匯出", function()
        local exportString, err = BuffReminders:Export()
        if exportString then
            exportTextArea:SetText(exportString)
            exportTextArea:HighlightText()
            exportTextArea:SetFocus()
        else
            exportTextArea:SetText("錯誤: " .. (err or "匯出失敗"))
        end
    end)
    profLayout:Add(exportButton, 22, SECTION_GAP)

    -- Import section
    LayoutSectionHeader(profLayout, profilesContent, "匯入設定")

    local importDesc = profilesContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    importDesc:SetText("在下面貼上設定字串。這將覆蓋您當前的設定。")
    profLayout:AddText(importDesc, 12, COMPONENT_GAP)

    local importTextArea = Components.TextArea(profilesContent, {
        width = PANEL_WIDTH - COL_PADDING * 2 - SCROLLBAR_WIDTH,
        height = 80,
    })
    profLayout:Add(importTextArea, 80, COMPONENT_GAP)

    local importStatus = profilesContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    importStatus:SetWidth(PANEL_WIDTH - COL_PADDING * 2 - 120)
    importStatus:SetJustifyH("LEFT")
    importStatus:SetText("")

    local importButton = CreateButton(profilesContent, "匯入", function()
        local importString = importTextArea:GetText()
        local success, err = BuffReminders:Import(importString)
        if success then
            importStatus:SetText("|cff00ff00設定已成功匯入！|r")
            StaticPopup_Show("BUFFREMINDERS_RELOAD_UI")
        else
            importStatus:SetText("|cffff0000錯誤: " .. (err or "未知的錯誤") .. "|r")
        end
    end)
    profLayout:Add(importButton, 22)
    importStatus:SetPoint("LEFT", importButton, "RIGHT", 10, 0)

    profilesContent:SetHeight(math.abs(profLayout:GetY()) + 50)

    -- ========== BOTTOM BUTTONS ==========
    local bottomFrame = CreateFrame("Frame", nil, panel)
    bottomFrame:SetPoint("BOTTOMLEFT", 0, 0)
    bottomFrame:SetPoint("BOTTOMRIGHT", 0, 0)
    bottomFrame:SetHeight(45)
    bottomFrame:SetFrameLevel(panel:GetFrameLevel() + 10)

    local separator = bottomFrame:CreateTexture(nil, "ARTWORK")
    separator:SetSize(PANEL_WIDTH - 40, 1)
    separator:SetPoint("TOP", 0, -5)
    separator:SetColorTexture(0.3, 0.3, 0.3, 1)

    local btnHolder = CreateFrame("Frame", nil, bottomFrame)
    btnHolder:SetPoint("TOP", separator, "BOTTOM", 0, -8)
    btnHolder:SetSize(1, 22)

    local BTN_WIDTH = 80

    local lockBtn = CreateButton(btnHolder, "解鎖", function()
        BR.Display.ToggleLock()
        Components.RefreshAll()
    end, { title = "鎖定 / 解鎖", desc = "解鎖以顯示用於重新定位增益框架的定位點。" })
    lockBtn:SetSize(BTN_WIDTH, 22)
    lockBtn:SetPoint("RIGHT", btnHolder, "CENTER", -4, 0)

    function lockBtn:Refresh()
        self.text:SetText(BuffRemindersDB.locked and "解鎖" or "鎖定")
    end
    lockBtn:Refresh()
    table.insert(BR.RefreshableComponents, lockBtn)

    local testBtn = CreateButton(btnHolder, "停止測試", function(self)
        local isOn = ToggleTestMode()
        self.text:SetText(isOn and "停止測試" or "測試")
    end, {
        title = "測試圖示的外觀",
        desc = "顯示您選擇要模擬的增益，以便您可以預覽它們的外觀。",
    })
    testBtn:SetText("測試")
    testBtn:SetSize(BTN_WIDTH, 22)
    testBtn:SetPoint("LEFT", btnHolder, "CENTER", 4, 0)
    panel.testBtn = testBtn

    -- Set initial active tab
    SetActiveTab("buffs")

    return panel
end

-- Toggle options panel
local function ToggleOptions()
    if not optionsPanel then
        optionsPanel = CreateOptionsPanel()
    end

    if optionsPanel:IsShown() then
        optionsPanel:Hide()
    else
        -- Refresh custom buffs
        if optionsPanel.RenderCustomBuffRows then
            optionsPanel.RenderCustomBuffRows()
        end
        -- Update button texts
        if BR.Display.IsTestMode() then
            optionsPanel.testBtn.text:SetText("停止測試")
        else
            optionsPanel.testBtn.text:SetText("測試")
        end
        optionsPanel:Show()
    end
end

-- Glow demo panel
ShowGlowDemo = function()
    -- Clean up old panel (recreate to reflect current color)
    if glowDemoPanel then
        glowDemoPanel:Hide()
        glowDemoPanel = nil
    end

    local ICON_SIZE = 64
    local SPACING = 20
    local numTypes = #GlowTypes

    local demoPanel = CreatePanel("BuffRemindersGlowDemo", numTypes * (ICON_SIZE + SPACING) + SPACING, ICON_SIZE + 70, {
        strata = "TOOLTIP",
        modal = true,
    })

    local demoTitle = demoPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    demoTitle:SetPoint("TOP", 0, -8)
    demoTitle:SetText("|cffffcc00發光類型預覽|r")

    local demoCloseBtn = CreateButton(demoPanel, "x", function()
        demoPanel:Hide()
    end)
    demoCloseBtn:SetSize(22, 22)
    demoCloseBtn:SetPoint("TOPRIGHT", -5, -5)

    local useCustomColor = BR.Config.Get("defaults.useCustomGlowColor", false)
    local color = useCustomColor and BR.Config.Get("defaults.glowColor", Glow.DEFAULT_COLOR) or nil
    local demoFrames = {}

    for i, gt in ipairs(GlowTypes) do
        local iconFrame = CreateFrame("Frame", nil, demoPanel)
        iconFrame:SetSize(ICON_SIZE, ICON_SIZE)
        iconFrame:SetPoint("TOPLEFT", SPACING + (i - 1) * (ICON_SIZE + SPACING), -30)

        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexCoord(TEXCOORD_INSET, 1 - TEXCOORD_INSET, TEXCOORD_INSET, 1 - TEXCOORD_INSET)
        icon:SetTexture(GetBuffTexture(1459))

        local border = iconFrame:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("TOPLEFT", -DEFAULT_BORDER_SIZE, DEFAULT_BORDER_SIZE)
        border:SetPoint("BOTTOMRIGHT", DEFAULT_BORDER_SIZE, -DEFAULT_BORDER_SIZE)
        border:SetColorTexture(0, 0, 0, 1)

        local demoSize = BR.Config.Get("defaults.glowSize", 2)
        Glow.Start(iconFrame, i, color, "BR_demo_" .. i, demoSize)
        demoFrames[i] = iconFrame

        local typeLabel = demoPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        typeLabel:SetPoint("TOP", iconFrame, "BOTTOM", 0, -4)
        typeLabel:SetText(gt.name)
        typeLabel:SetWidth(ICON_SIZE + 10)
    end

    -- Clean up glows when panel hides
    demoPanel:SetScript("OnHide", function()
        for i in ipairs(GlowTypes) do
            if demoFrames[i] then
                Glow.StopAll(demoFrames[i], "BR_demo_" .. i)
            end
        end
    end)

    glowDemoPanel = demoPanel
end

-- Delete confirmation dialog for custom buffs
StaticPopupDialogs["BUFFREMINDERS_DELETE_CUSTOM"] = {
    text = '要刪除自訂增益 "%s" 嗎？',
    button1 = "刪除",
    button2 = "取消",
    OnAccept = function(_, data)
        if data and data.key then
            BuffRemindersDB.customBuffs[data.key] = nil
            BuffRemindersDB.enabledBuffs[data.key] = nil
            RemoveCustomBuffFrame(data.key)
            if data.refreshPanel then
                data.refreshPanel()
            end
            UpdateDisplay()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BUFFREMINDERS_RESET_DEFAULTS"] = {
    text = "重置增益提醒回預設嗎？\n\n這會清除所有自訂設置\n並重載介面。",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        wipe(BuffRemindersDB)
        ReloadUI()
    end,
    showAlert = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BUFFREMINDERS_RELOAD_UI"] = {
    text = "設定已成功匯入！\n重載介面以套用變更？",
    button1 = "重載",
    button2 = "取消",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["BUFFREMINDERS_DISCORD_URL"] = {
    text = "加入 BuffReminders 的 Discord!\n複製以下網址 (Ctrl+C):",
    button1 = "關閉",
    hasEditBox = true,
    editBoxWidth = 250,
    OnShow = function(self)
        self.EditBox:SetText("https://discord.gg/qezQ2hXJJ7")
        self.EditBox:HighlightText()
        self.EditBox:SetFocus()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Custom buff add/edit modal dialog
ShowCustomBuffModal = function(existingKey, refreshPanelCallback)
    if customBuffModal then
        customBuffModal:Hide()
    end

    local MODAL_WIDTH = 460
    local BASE_HEIGHT = 530
    local ROW_HEIGHT = 26
    local CONTENT_LEFT = 20
    local ROWS_START_Y = -60
    local editingBuff = existingKey and BuffRemindersDB.customBuffs[existingKey] or nil

    local existingSpellIDs = {}
    if editingBuff then
        if type(editingBuff.spellID) == "table" then
            for _, id in ipairs(editingBuff.spellID) do
                table.insert(existingSpellIDs, id)
            end
        else
            table.insert(existingSpellIDs, editingBuff.spellID)
        end
    end

    local modal = CreatePanel("BuffRemindersCustomBuffModal", MODAL_WIDTH, BASE_HEIGHT, {
        bgColor = { 0.1, 0.1, 0.1, 0.98 },
        borderColor = { 0.4, 0.4, 0.4, 1 },
        level = 200,
        modal = true,
    })

    local spellRows, nameBox, missingBox
    local castSpellEditBox, castItemEditBox, macroEditBox, requireItemEditBox

    modal:SetScript("OnHide", function()
        if spellRows then
            for _, rowData in ipairs(spellRows) do
                if rowData.editBox then
                    rowData.editBox:ClearFocus()
                end
            end
        end
        if nameBox then
            nameBox:ClearFocus()
        end
        if missingBox then
            missingBox:ClearFocus()
        end
        if castSpellEditBox then
            castSpellEditBox:ClearFocus()
        end
        if castItemEditBox then
            castItemEditBox:ClearFocus()
        end
        if macroEditBox then
            macroEditBox:ClearFocus()
        end
        if requireItemEditBox then
            requireItemEditBox:ClearFocus()
        end
    end)

    local modalTitle = modal:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    modalTitle:SetPoint("TOP", 0, -12)
    modalTitle:SetText(editingBuff and "編輯自訂增益" or "新增自訂增益")

    local modalCloseBtn = CreateButton(modal, "x", function()
        modal:Hide()
    end)
    modalCloseBtn:SetSize(22, 22)
    modalCloseBtn:SetPoint("TOPRIGHT", -5, -5)

    local spellIdsLabel = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    spellIdsLabel:SetPoint("TOPLEFT", CONTENT_LEFT, -40)
    spellIdsLabel:SetText("法術ID:")

    spellRows = {}

    local addSpellBtn, sectionsFrame
    local showIconToggle
    local glowModeDropdown, requireSpellKnownToggle
    local classDropdownHolder
    local specDropdownHolder
    local actionTypeDropdown
    local actionInputHolder

    local function UpdateLayout()
        local rowCount = #spellRows

        for i, rowData in ipairs(spellRows) do
            rowData.frame:ClearAllPoints()
            rowData.frame:SetPoint("TOPLEFT", modal, "TOPLEFT", CONTENT_LEFT, ROWS_START_Y - ((i - 1) * ROW_HEIGHT))
            if rowCount > 1 then
                rowData.removeBtn:Show()
            else
                rowData.removeBtn:Hide()
            end
        end

        local addBtnY = ROWS_START_Y - (rowCount * ROW_HEIGHT) - 4
        addSpellBtn:ClearAllPoints()
        addSpellBtn:SetPoint("TOPLEFT", modal, "TOPLEFT", CONTENT_LEFT, addBtnY)

        sectionsFrame:ClearAllPoints()
        sectionsFrame:SetPoint("TOPLEFT", modal, "TOPLEFT", CONTENT_LEFT, addBtnY - 28)

        local extraRows = math.max(0, rowCount - 1)
        modal:SetHeight(BASE_HEIGHT + (extraRows * ROW_HEIGHT))
    end

    local function CreateSpellRow(initialSpellID)
        local rowFrame = CreateFrame("Frame", nil, modal)
        rowFrame:SetSize(MODAL_WIDTH - 40, ROW_HEIGHT - 2)

        local editBox = CreateFrame("EditBox", nil, rowFrame)
        editBox:SetFontObject("GameFontHighlight")
        editBox:SetAutoFocus(false)
        local editContainer = StyleEditBox(editBox)
        editContainer:SetSize(70, 20)
        editContainer:SetPoint("LEFT", 0, 0)
        if initialSpellID then
            editBox:SetText(tostring(initialSpellID))
        end

        local doLookup -- forward declare for onClick
        local lookupBtn = CreateButton(rowFrame, "Lookup", function()
            doLookup()
        end)
        lookupBtn:SetSize(55, 20)
        lookupBtn:SetPoint("LEFT", editContainer, "RIGHT", 5, 0)

        local icon = CreateBuffIcon(rowFrame, 18)
        icon:SetPoint("LEFT", lookupBtn, "RIGHT", 8, 0)
        icon:Hide()

        local nameText = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nameText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        nameText:SetPoint("RIGHT", rowFrame, "RIGHT", -28, 0)
        nameText:SetJustifyH("LEFT")
        nameText:SetWordWrap(false)

        local removeBtn = CreateButton(rowFrame, "-", nil)
        removeBtn:SetSize(22, 20)
        removeBtn:SetPoint("RIGHT", 0, 0)
        removeBtn:Hide()

        local rowData = {
            frame = rowFrame,
            editBox = editBox,
            icon = icon,
            nameText = nameText,
            removeBtn = removeBtn,
            validated = false,
            spellID = nil,
            spellName = nil,
        }

        removeBtn:SetScript("OnClick", function()
            for i, rd in ipairs(spellRows) do
                if rd == rowData then
                    rowData.frame:Hide()
                    table.remove(spellRows, i)
                    UpdateLayout()
                    break
                end
            end
        end)

        doLookup = function()
            local spellID = tonumber(editBox:GetText())
            if not spellID then
                icon:Hide()
                nameText:SetText("|cffff4d4d無效的ID|r")
                rowData.validated, rowData.spellID, rowData.spellName = false, nil, nil
                return
            end

            local valid, name, iconID = ValidateSpellID(spellID)
            if valid then
                icon:SetTexture(iconID)
                icon:Show()
                nameText:SetText(name or "")
                rowData.validated, rowData.spellID, rowData.spellName = true, spellID, name
            else
                icon:Hide()
                nameText:SetText("|cffff4d4d未找到|r")
                rowData.validated, rowData.spellID, rowData.spellName = false, nil, nil
            end
        end

        table.insert(spellRows, rowData)

        if initialSpellID then
            doLookup()
        end

        return rowData
    end

    addSpellBtn = CreateButton(modal, "+ Add Spell ID", function()
        CreateSpellRow(nil)
        UpdateLayout()
    end)

    -- Sections frame (always visible, below add-spell button)
    sectionsFrame = CreateFrame("Frame", nil, modal)
    sectionsFrame:SetSize(MODAL_WIDTH - 40, 350)

    local function CreateSeparator(parent, yOff, width)
        local line = parent:CreateTexture(nil, "ARTWORK")
        line:SetHeight(1)
        line:SetPoint("TOPLEFT", 0, yOff)
        if width then
            line:SetWidth(width)
        else
            line:SetPoint("RIGHT", 0, 0)
        end
        line:SetColorTexture(0.25, 0.25, 0.25, 0.8)
    end

    -- Appearance section
    CreateSeparator(sectionsFrame, 0)
    CreateSectionHeader(sectionsFrame, "外觀", 0, -9)

    local nameHolder = Components.TextInput(sectionsFrame, {
        label = "名稱:",
        value = editingBuff and editingBuff.name or "",
        width = 250,
        labelWidth = 50,
    })
    nameHolder:SetPoint("TOPLEFT", 0, -30)
    nameBox = nameHolder.editBox

    local missingHolder = Components.TextInput(sectionsFrame, {
        label = "文字:",
        value = editingBuff and editingBuff.missingText and editingBuff.missingText:gsub("\n", "\\n") or "",
        width = 250,
        labelWidth = 50,
    })
    missingHolder:SetPoint("TOPLEFT", 0, -54)
    missingBox = missingHolder.editBox

    local missingHint = sectionsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    missingHint:SetPoint("LEFT", missingHolder, "RIGHT", 5, 0)
    missingHint:SetText("(使用 \\n 來換行)")

    -- Conditions section (merges restrictions, visibility, advanced)
    CreateSeparator(sectionsFrame, -76)
    CreateSectionHeader(sectionsFrame, "條件", 0, -85)

    local classOptions = {
        { value = nil, label = "任何" },
        { value = "DEATHKNIGHT", label = "死亡騎士" },
        { value = "DEMONHUNTER", label = "惡魔獵人" },
        { value = "DRUID", label = "德魯伊" },
        { value = "EVOKER", label = "喚能師" },
        { value = "HUNTER", label = "獵人" },
        { value = "MAGE", label = "法師" },
        { value = "MONK", label = "武僧" },
        { value = "PALADIN", label = "聖騎士" },
        { value = "PRIEST", label = "牧師" },
        { value = "ROGUE", label = "盜賊" },
        { value = "SHAMAN", label = "薩滿" },
        { value = "WARLOCK", label = "術士" },
        { value = "WARRIOR", label = "戰士" },
    }

    local function CreateSpecDropdown(classToken, selectedSpecId)
        if specDropdownHolder then
            specDropdownHolder:Hide()
            specDropdownHolder = nil
        end
        if not classToken then
            return
        end
        local specOptions = BR.CLASS_SPEC_OPTIONS[classToken]
        if not specOptions then
            return
        end
        specDropdownHolder = Components.Dropdown(sectionsFrame, {
            label = "專精:",
            options = specOptions,
            selected = selectedSpecId,
            width = 140,
            labelWidth = 45,
            onChange = function() end,
        })
        specDropdownHolder:SetPoint("TOPLEFT", 210, -132)
    end

    classDropdownHolder = Components.Dropdown(sectionsFrame, {
        label = "職業:",
        options = classOptions,
        selected = editingBuff and editingBuff.class or nil,
        width = 140,
        labelWidth = 45,
        maxItems = 10,
        onChange = function(value)
            CreateSpecDropdown(value, nil)
        end,
    }, "BuffRemindersCustomClassDropdown")
    classDropdownHolder:SetPoint("TOPLEFT", 0, -132)

    -- Initialize spec dropdown for editing existing buff
    if editingBuff and editingBuff.class then
        CreateSpecDropdown(editingBuff.class, editingBuff.requireSpecId)
    end

    showIconToggle = Components.Toggle(sectionsFrame, {
        label = editingBuff and editingBuff.showWhenPresent and "當啟用時" or "當缺少時",
        checked = editingBuff and editingBuff.showWhenPresent or false,
        onChange = function(isChecked)
            if isChecked then
                showIconToggle.label:SetText("當啟用時")
            else
                showIconToggle.label:SetText("當缺少時")
            end
        end,
    })
    showIconToggle:SetPoint("TOPLEFT", 0, -106)

    requireSpellKnownToggle = Components.Toggle(sectionsFrame, {
        label = "只限已知的法術",
        checked = editingBuff and editingBuff.requireSpellKnown or false,
        onChange = function() end,
    })
    requireSpellKnownToggle:SetPoint("TOPLEFT", 210, -106)

    -- Require item (item gate)
    local requireItemLabel = sectionsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    requireItemLabel:SetPoint("TOPLEFT", 0, -166)
    requireItemLabel:SetText("需要物品:")

    requireItemEditBox = CreateFrame("EditBox", nil, sectionsFrame)
    requireItemEditBox:SetFontObject("GameFontHighlight")
    requireItemEditBox:SetAutoFocus(false)
    local requireItemContainer = StyleEditBox(requireItemEditBox)
    requireItemContainer:SetSize(70, 20)
    requireItemContainer:SetPoint("LEFT", requireItemLabel, "RIGHT", 5, 0)
    if editingBuff and editingBuff.requireItemID then
        requireItemEditBox:SetText(tostring(editingBuff.requireItemID))
    end

    local requireItemHint = sectionsFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    requireItemHint:SetPoint("LEFT", requireItemContainer, "RIGHT", 5, 0)
    requireItemHint:SetText("(如果未擁有則隱藏)")

    local glowModeOptions = {
        { value = "whenGlowing", label = "發光時檢測" },
        { value = "whenNotGlowing", label = "不發光時檢測" },
        { value = "disabled", label = "停用" },
    }
    local currentGlowMode = editingBuff and editingBuff.glowMode or "disabled"
    glowModeDropdown = Components.Dropdown(sectionsFrame, {
        label = "條發光:",
        options = glowModeOptions,
        selected = currentGlowMode,
        width = 175,
        tooltip = {
            title = "動作列發光反饋",
            desc = "當增益的API受到限制時，M+/PvP/戰鬥期間，使用動作列法術發光的反饋偵測。如果您只想進行增益在場追踪請停用。",
        },
        onChange = function() end,
    })
    glowModeDropdown:SetPoint("TOPLEFT", 0, -192)

    -- Click action section
    CreateSeparator(sectionsFrame, -224)
    CreateSectionHeader(sectionsFrame, "點擊動作", 0, -233)

    -- Determine existing action type
    local existingActionType = "none"
    if editingBuff then
        if editingBuff.castMacro and editingBuff.castMacro ~= "" then
            existingActionType = "macro"
        elseif editingBuff.castItemID then
            existingActionType = "item"
        elseif editingBuff.castSpellID then
            existingActionType = "spell"
        end
    end

    -- Container for the conditional input (spell/item Lookup or macro text)
    actionInputHolder = CreateFrame("Frame", nil, sectionsFrame)
    actionInputHolder:SetSize(MODAL_WIDTH - 40, 26)
    actionInputHolder:SetPoint("TOPLEFT", 0, -284)

    -- Spell ID input with Lookup
    castSpellEditBox = CreateFrame("EditBox", nil, actionInputHolder)
    castSpellEditBox:SetFontObject("GameFontHighlight")
    castSpellEditBox:SetAutoFocus(false)
    local castSpellContainer = StyleEditBox(castSpellEditBox)
    castSpellContainer:SetSize(70, 20)
    castSpellContainer:SetPoint("LEFT", 0, 0)
    if editingBuff and editingBuff.castSpellID then
        castSpellEditBox:SetText(tostring(editingBuff.castSpellID))
    end

    local castSpellIcon = CreateBuffIcon(actionInputHolder, 18)
    castSpellIcon:SetPoint("LEFT", castSpellContainer, "RIGHT", 68, 0)
    castSpellIcon:Hide()

    local castSpellName = actionInputHolder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    castSpellName:SetPoint("LEFT", castSpellIcon, "RIGHT", 5, 0)
    castSpellName:SetPoint("RIGHT", actionInputHolder, "RIGHT", 0, 0)
    castSpellName:SetJustifyH("LEFT")
    castSpellName:SetWordWrap(false)

    local castSpellLookupBtn = CreateButton(actionInputHolder, "Lookup", function()
        local id = tonumber(castSpellEditBox:GetText())
        if not id then
            castSpellIcon:Hide()
            castSpellName:SetText("|cffff4d4d無效的ID|r")
            return
        end
        local valid, name, iconID = ValidateSpellID(id)
        if valid then
            castSpellIcon:SetTexture(iconID)
            castSpellIcon:Show()
            castSpellName:SetText(name or "")
        else
            castSpellIcon:Hide()
            castSpellName:SetText("|cffff4d4d未找到|r")
        end
    end)
    castSpellLookupBtn:SetSize(55, 20)
    castSpellLookupBtn:SetPoint("LEFT", castSpellContainer, "RIGHT", 5, 0)

    -- Item ID input with Lookup
    castItemEditBox = CreateFrame("EditBox", nil, actionInputHolder)
    castItemEditBox:SetFontObject("GameFontHighlight")
    castItemEditBox:SetAutoFocus(false)
    local castItemContainer = StyleEditBox(castItemEditBox)
    castItemContainer:SetSize(70, 20)
    castItemContainer:SetPoint("LEFT", 0, 0)
    if editingBuff and editingBuff.castItemID then
        castItemEditBox:SetText(tostring(editingBuff.castItemID))
    end

    local castItemIcon = CreateBuffIcon(actionInputHolder, 18)
    castItemIcon:SetPoint("LEFT", castItemContainer, "RIGHT", 68, 0)
    castItemIcon:Hide()

    local castItemName = actionInputHolder:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    castItemName:SetPoint("LEFT", castItemIcon, "RIGHT", 5, 0)
    castItemName:SetPoint("RIGHT", actionInputHolder, "RIGHT", 0, 0)
    castItemName:SetJustifyH("LEFT")
    castItemName:SetWordWrap(false)

    local castItemLookupBtn = CreateButton(actionInputHolder, "Lookup", function()
        local id = tonumber(castItemEditBox:GetText())
        if not id then
            castItemIcon:Hide()
            castItemName:SetText("|cffff4d4d無效的ID|r")
            return
        end
        local valid, name, iconID = ValidateItemID(id)
        if valid then
            castItemIcon:SetTexture(iconID)
            castItemIcon:Show()
            castItemName:SetText(name or "")
        else
            castItemIcon:Hide()
            castItemName:SetText("|cffff4d4d未找到 (再次嘗試)|r")
            -- Request item data load for next lookup attempt
            pcall(C_Item.RequestLoadItemDataByID, id)
        end
    end)
    castItemLookupBtn:SetSize(55, 20)
    castItemLookupBtn:SetPoint("LEFT", castItemContainer, "RIGHT", 5, 0)

    -- Macro text input
    local macroHolder = Components.TextInput(actionInputHolder, {
        label = "",
        value = editingBuff and editingBuff.castMacro or "",
        width = MODAL_WIDTH - 80,
        labelWidth = 0,
    })
    macroHolder:SetPoint("LEFT", 0, 0)
    macroEditBox = macroHolder.editBox

    local macroHint = actionInputHolder:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    macroHint:SetPoint("TOPLEFT", 0, -24)
    macroHint:SetText("e.g. /use item:12345\\n/use 13")

    -- Show/hide inputs based on action type
    local function UpdateActionInputVisibility(actionType)
        -- Hide all first
        castSpellContainer:Hide()
        castSpellLookupBtn:Hide()
        castSpellIcon:Hide()
        castSpellName:SetText("")
        castItemContainer:Hide()
        castItemLookupBtn:Hide()
        castItemIcon:Hide()
        castItemName:SetText("")
        macroHolder:Hide()
        macroHint:Hide()

        if actionType == "spell" then
            castSpellContainer:Show()
            castSpellLookupBtn:Show()
            -- Trigger lookup if there's a value
            if castSpellEditBox:GetText() ~= "" then
                local id = tonumber(castSpellEditBox:GetText())
                if id then
                    local valid, name, iconID = ValidateSpellID(id)
                    if valid then
                        castSpellIcon:SetTexture(iconID)
                        castSpellIcon:Show()
                        castSpellName:SetText(name or "")
                    end
                end
            end
        elseif actionType == "item" then
            castItemContainer:Show()
            castItemLookupBtn:Show()
            -- Trigger lookup if there's a value
            if castItemEditBox:GetText() ~= "" then
                local id = tonumber(castItemEditBox:GetText())
                if id then
                    local valid, name, iconID = ValidateItemID(id)
                    if valid then
                        castItemIcon:SetTexture(iconID)
                        castItemIcon:Show()
                        castItemName:SetText(name or "")
                    end
                end
            end
        elseif actionType == "macro" then
            macroHolder:Show()
            macroHint:Show()
        end
    end

    local actionTypeOptions = {
        { value = "none", label = "無" },
        { value = "spell", label = "法術" },
        { value = "item", label = "物品" },
        { value = "macro", label = "巨集" },
    }
    actionTypeDropdown = Components.Dropdown(sectionsFrame, {
        label = "On click:",
        options = actionTypeOptions,
        selected = existingActionType,
        width = 120,
        tooltip = {
            title = "點擊動作",
            desc = "當你點擊這個增益圖示時會發生什麼事。法術施放法術，物品使用物品，巨集運行巨集指令。",
        },
        onChange = function(value)
            UpdateActionInputVisibility(value)
        end,
    })
    actionTypeDropdown:SetPoint("TOPLEFT", 0, -254)

    -- Initialize visibility for the current action type
    UpdateActionInputVisibility(existingActionType)

    local saveError = modal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    saveError:SetPoint("BOTTOMLEFT", 20, 42)
    saveError:SetWidth(MODAL_WIDTH - 120)
    saveError:SetJustifyH("LEFT")
    saveError:SetTextColor(1, 0.3, 0.3)

    local cancelBtn = CreateButton(modal, "取消", function()
        modal:Hide()
    end)
    cancelBtn:SetPoint("BOTTOMRIGHT", -20, 15)

    -- Delete button (only when editing existing buff)
    if existingKey and editingBuff then
        local buffName = editingBuff.name or existingKey
        local deleteBtn = CreateButton(modal, "Delete", function()
            modal:Hide()
            StaticPopup_Show("BUFFREMINDERS_DELETE_CUSTOM", buffName, nil, {
                key = existingKey,
                refreshPanel = refreshPanelCallback,
            })
        end)
        deleteBtn:SetPoint("BOTTOMLEFT", 20, 15)
    end

    local saveBtn = CreateButton(modal, "儲存", function()
        local validatedIDs = {}
        local firstName = nil
        for _, rowData in ipairs(spellRows) do
            if rowData.validated and rowData.spellID then
                table.insert(validatedIDs, rowData.spellID)
                if not firstName then
                    firstName = rowData.spellName
                end
            end
        end

        if #validatedIDs == 0 then
            saveError:SetText("請驗證至少一個法術ID")
            return
        end
        saveError:SetText("")

        local spellIDValue = #validatedIDs == 1 and validatedIDs[1] or validatedIDs
        local key = existingKey or GenerateCustomBuffKey(spellIDValue)
        local displayName = nameBox:GetText()
        if displayName == "" then
            displayName = firstName or ("法術 " .. validatedIDs[1])
        end

        local missingTextValue = strtrim(missingBox:GetText())
        if missingTextValue ~= "" then
            missingTextValue = missingTextValue:gsub("\\n", "\n")
        else
            missingTextValue = nil
        end

        -- Resolve click action fields based on selected action type
        local selectedAction = actionTypeDropdown:GetValue()
        local castSpellIDValue = nil
        local castItemIDValue = nil
        local castMacroValue = nil
        if selectedAction == "spell" then
            castSpellIDValue = tonumber(strtrim(castSpellEditBox:GetText())) or nil
        elseif selectedAction == "item" then
            castItemIDValue = tonumber(strtrim(castItemEditBox:GetText())) or nil
        elseif selectedAction == "macro" then
            local macroText = strtrim(macroEditBox:GetText())
            if macroText ~= "" then
                castMacroValue = macroText
            end
        end

        local customBuff = {
            spellID = spellIDValue,
            key = key,
            name = displayName,
            missingText = missingTextValue,
            class = classDropdownHolder:GetValue(),
            requireSpecId = specDropdownHolder and specDropdownHolder:GetValue() or nil,
            showWhenPresent = showIconToggle:GetChecked() or nil,
            requireSpellKnown = requireSpellKnownToggle:GetChecked() or nil,
            glowMode = glowModeDropdown:GetValue() ~= "disabled" and glowModeDropdown:GetValue() or nil,
            castSpellID = castSpellIDValue,
            castItemID = castItemIDValue,
            castMacro = castMacroValue,
            requireItemID = tonumber(strtrim(requireItemEditBox:GetText())) or nil,
        }

        BuffRemindersDB.customBuffs[key] = customBuff

        if not existingKey then
            CreateCustomBuffFrameRuntime(customBuff)
        else
            UpdateCustomBuffFrame(key, spellIDValue, displayName)
        end

        modal:Hide()
        if refreshPanelCallback then
            refreshPanelCallback()
        end
        UpdateDisplay()
    end)
    saveBtn:SetPoint("RIGHT", cancelBtn, "LEFT", -10, 0)

    if #existingSpellIDs > 0 then
        for _, spellID in ipairs(existingSpellIDs) do
            CreateSpellRow(spellID)
        end
    else
        CreateSpellRow(nil)
    end

    UpdateLayout()

    customBuffModal = modal
    modal:Show()
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

BR.Options = {
    Toggle = ToggleOptions,
}
