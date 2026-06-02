local _, ns = ...
ns.Sections = ns.Sections or {}

local L = ns.L

-- "Gear" section — Best in Slot gear from Wowhead / Icy Veins / PvP. The
-- displayed title still reads "Best in Slot Gear" (L["tab.best_in_slot"]).
local Gear = {}
ns.Sections.Gear = Gear

-------------------------------------------------------------------------------
-- Shared helpers + state persistence
-------------------------------------------------------------------------------

local MAX_ROWS = 20

local function LoadBisPrefs()
    local specKey = ns.GetSpecKey and ns.GetSpecKey()
    local source, tabLabel = "Wowhead", nil
    if specKey and ClassCodexCharDB and ClassCodexCharDB.perSpec
        and ClassCodexCharDB.perSpec[specKey] then
        local s = ClassCodexCharDB.perSpec[specKey]
        if s.bisSource then source = s.bisSource end
        if s.bisTab then tabLabel = s.bisTab end
    end
    return source, tabLabel
end

local function SaveBisPrefs(source, tabLabel)
    local specKey = ns.GetSpecKey and ns.GetSpecKey()
    if not specKey or not ClassCodexCharDB then return end
    if not ClassCodexCharDB.perSpec then ClassCodexCharDB.perSpec = {} end
    if not ClassCodexCharDB.perSpec[specKey] then
        ClassCodexCharDB.perSpec[specKey] = {}
    end
    if source ~= nil then ClassCodexCharDB.perSpec[specKey].bisSource = source end
    if tabLabel ~= nil then ClassCodexCharDB.perSpec[specKey].bisTab = tabLabel end
end

local function FindTabByLabel(tabs, label)
    if not label then return nil end
    for _, tab in ipairs(tabs) do
        if tab.label == label then return tab end
    end
    return nil
end

-------------------------------------------------------------------------------
-- Panel surface (always reflects the player's current spec)
-------------------------------------------------------------------------------

local panel = {}

function Gear.InitPanel(parent)
    panel.section = CreateFrame("Frame", nil, parent)
    panel.section:SetHeight(ns.SECTION_HEADER_HEIGHT)
    panel.title = ns.CreateSectionTitle(panel.section, L["tab.bis_gear"])
    panel.content = CreateFrame("Frame", nil, panel.section)
    panel.content:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, 0)
    panel.content:SetPoint("RIGHT", 0, 0)
    panel.content:Show()

    panel.sourceDropdown = ns.CreateOptionDropdown("ClassCodexBisSourceDropdown", panel.content)
    panel.sourceDropdown:SetPoint("TOPLEFT", 0, 0)
    panel.sourceDropdown:SetPoint("TOPRIGHT", 0, 0)
    panel.sourceDropdown:Hide()

    panel.tabDropdown = ns.CreateOptionDropdown("ClassCodexBisTabDropdown", panel.content)
    panel.tabDropdown:SetPoint("TOPLEFT", 0, 0)
    panel.tabDropdown:SetPoint("TOPRIGHT", 0, 0)
    panel.tabDropdown:Hide()

    panel.rows = {}
    for i = 1, MAX_ROWS do
        local row = CreateFrame("Frame", nil, panel.content)
        row:SetHeight(ns.ROW_HEIGHT)
        local slot = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slot:SetPoint("LEFT", 2, 0); slot:SetWidth(55); slot:SetJustifyH("LEFT")
        slot:SetTextColor(0.6, 0.6, 0.6)
        row.slotText = slot
        ns.CreateRowIcon(row)
        row.icon:ClearAllPoints()
        row.icon:SetPoint("LEFT", slot, "RIGHT", 2, 0)
        local source = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        source:SetPoint("RIGHT", -2, 0); source:SetWidth(80); source:SetJustifyH("RIGHT")
        source:SetWordWrap(false); source:SetTextColor(0.5, 0.5, 0.5)
        row.sourceLabel = source
        local ownedBg = row:CreateTexture(nil, "BACKGROUND")
        ownedBg:SetAllPoints(row); ownedBg:SetColorTexture(0.2, 0.9, 0.2, 0.10); ownedBg:Hide()
        row.ownedBg = ownedBg
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        name:SetPoint("RIGHT", source, "LEFT", -4, 0)
        name:SetJustifyH("LEFT"); name:SetWordWrap(false)
        row.itemText = name
        ns.SetupItemTooltip(row)
        row:Hide()
        panel.rows[i] = row
    end

    panel.fallback = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.fallback:SetTextColor(0.5, 0.5, 0.5)
    panel.fallback:Hide()

    return panel.section
end

function Gear.IsPanelSourceDropdownShown() return panel.sourceDropdown:IsShown() end
function Gear.IsPanelTabDropdownShown() return panel.tabDropdown:IsShown() end
function Gear.IsPanelFallbackShown() return panel.fallback:IsShown() end

-- args = { wowheadBis, ivBis, pvpBis, onChange }
-- Returns the rendered row count (height in ROW_HEIGHT units).
function Gear.RenderPanel(args)
    for i = 1, MAX_ROWS do panel.rows[i]:Hide() end
    panel.fallback:Hide()

    local wowheadBis, ivBis, pvpBis = args.wowheadBis, args.ivBis, args.pvpBis
    local hasWH  = wowheadBis and #wowheadBis > 0
    local hasIV  = ivBis and #ivBis > 0
    local hasPvP = pvpBis ~= nil

    if not (hasWH or hasIV or hasPvP) then
        panel.sourceDropdown:Hide()
        panel.tabDropdown:Hide()
        panel.section:Hide()
        return 0
    end

    local currentSource, currentTab = LoadBisPrefs()
    if currentSource == "Icy Veins" and not hasIV then currentSource = "Wowhead" end
    if currentSource == "Wowhead" and not hasWH then
        currentSource = hasIV and "Icy Veins" or "PvP"
    end

    -- Source dropdown
    local labels = ns.BIS_SOURCE_LABELS or {}
    local availableSources = {}
    if hasWH then availableSources[#availableSources + 1] = { label = labels["Wowhead"] or "Wowhead", value = "Wowhead" } end
    if hasIV then availableSources[#availableSources + 1] = { label = labels["Icy Veins"] or "Icy Veins", value = "Icy Veins" } end
    availableSources[#availableSources + 1] = { label = labels["PvP"] or "PvP", value = "PvP" }
    if #availableSources > 1 then
        panel.sourceDropdown:Show()
        panel.sourceDropdown:SetOptions(availableSources, currentSource, function(picked)
            SaveBisPrefs(picked, "Overall")
            if args.onChange then args.onChange() end
        end)
    else
        panel.sourceDropdown:Hide()
    end

    -- PvP-no-data fallback
    if currentSource == "PvP" and not hasPvP then
        panel.tabDropdown:Hide()
        local yOff = panel.sourceDropdown:IsShown() and -30 or 0
        panel.fallback:SetText(L["pvp.no_gear_data"] or "No PvP gear data for this spec yet.")
        panel.fallback:ClearAllPoints()
        panel.fallback:SetPoint("TOPLEFT", 4, yOff - 4)
        panel.fallback:Show()
        panel.section:Show()
        return 0
    end

    -- Pick the active source's tab list
    local activeBis
    if currentSource == "PvP" then activeBis = pvpBis
    elseif currentSource == "Icy Veins" then activeBis = ivBis
    else activeBis = wowheadBis end
    if not activeBis or #activeBis == 0 then
        activeBis = wowheadBis or ivBis or pvpBis
    end
    if not activeBis or not activeBis[1] then
        panel.tabDropdown:Hide()
        panel.section:Hide()
        return 0
    end

    -- Validate tab selection
    if not FindTabByLabel(activeBis, currentTab) then
        currentTab = activeBis[1].label
    end

    -- Tab dropdown
    local showTabDropdown = #activeBis > 1
    if showTabDropdown then
        local tabLabels = {}
        for _, tab in ipairs(activeBis) do tabLabels[#tabLabels + 1] = tab.label end
        panel.tabDropdown:Show()
        panel.tabDropdown:SetOptions(tabLabels, currentTab, function(picked)
            SaveBisPrefs(nil, picked)
            if args.onChange then args.onChange() end
        end)
    else
        panel.tabDropdown:Hide()
    end

    -- Selected slots
    local selectedTab = FindTabByLabel(activeBis, currentTab)
    local selectedSlots = selectedTab and selectedTab.slots or nil

    local yOffset = 0
    if panel.sourceDropdown:IsShown() then yOffset = yOffset - 30 end
    if showTabDropdown then
        panel.tabDropdown:ClearAllPoints()
        panel.tabDropdown:SetPoint("TOPLEFT", 0, yOffset)
        panel.tabDropdown:SetPoint("TOPRIGHT", 0, yOffset)
        yOffset = yOffset - 30
    end

    local count = selectedSlots and math.min(#selectedSlots, MAX_ROWS) or 0
    for i = 1, count do
        local entry = selectedSlots[i]
        local row = panel.rows[i]
        row.slotText:SetText(entry.slot)
        row.itemText:SetText(ns.FormatItem(entry.item))
        row.sourceLabel:SetText(entry.source or "")
        row.itemId = entry.item.itemId
        row.bonusIDs = entry.item.bonusIDs
        row.altItemId = nil
        row.embItemId = nil
        row.sourceText = entry.source or nil
        ns.SetRowIcon(row, entry.item.itemId)
        if row.ownedBg then
            if ns.IsItemOwned(entry.item.itemId) then row.ownedBg:Show() else row.ownedBg:Hide() end
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 0, yOffset - (i - 1) * ns.ROW_HEIGHT)
        row:SetPoint("RIGHT", 0, 0)
        row:Show()
    end
    panel.section:Show()
    return count
end

-------------------------------------------------------------------------------
-- Compendium surface (reflects the selected spec, may differ from player's)
-------------------------------------------------------------------------------

local comp = {}
-- Session-scoped state — only this module owns it now. lastSpecKey is the
-- guard that resets the source/tab when the user picks a different spec in
-- the Compendium.
local compSource = "Wowhead"
local compTab    = nil
local compLastSpecKey = nil

-- opts.parent + opts.headerFactory + opts.rowFactory
function Gear.InitCompendium(opts)
    comp.section = CreateFrame("Frame", nil, opts.parent)
    comp.header = opts.headerFactory(comp.section, L["tab.best_in_slot"], false)
    comp.content = CreateFrame("Frame", nil, comp.section)
    comp.content:SetPoint("TOPLEFT", comp.header, "BOTTOMLEFT", 0, -2)
    comp.content:SetPoint("RIGHT", 0, 0)

    comp.sourceDropdown = CreateFrame(
        "DropdownButton", "ClassCodexCompBisSourceDD",
        comp.content, "WowStyle1DropdownTemplate"
    )
    comp.sourceDropdown:SetPoint("TOPLEFT", 0, 0)
    comp.sourceDropdown:SetPoint("TOPRIGHT", 0, 0)
    comp.sourceDropdown:SetHeight(24); comp.sourceDropdown:Hide()

    comp.tabDropdown = CreateFrame(
        "DropdownButton", "ClassCodexCompBisTabDD",
        comp.content, "WowStyle1DropdownTemplate"
    )
    comp.tabDropdown:SetPoint("TOPLEFT", 0, 0)
    comp.tabDropdown:SetPoint("TOPRIGHT", 0, 0)
    comp.tabDropdown:SetHeight(24); comp.tabDropdown:Hide()

    comp.rows = {}
    for i = 1, MAX_ROWS do
        local row = opts.rowFactory(comp.content)
        ns.CreateRowIcon(row)
        local slot = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slot:SetPoint("LEFT", row.icon, "RIGHT", 4, 0); slot:SetWidth(70)
        slot:SetJustifyH("LEFT"); slot:SetTextColor(0.6, 0.6, 0.6)
        row.slot = slot
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local source = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        source:SetPoint("RIGHT", -2, 0); source:SetWidth(110); source:SetJustifyH("RIGHT")
        source:SetWordWrap(false); source:SetTextColor(0.5, 0.5, 0.5)
        name:SetPoint("LEFT", slot, "RIGHT", 4, 0); name:SetPoint("RIGHT", source, "LEFT", -4, 0)
        name:SetJustifyH("LEFT"); name:SetWordWrap(false)
        row.name = name
        row.source = source
        comp.rows[i] = row
    end

    comp.pvpFallback = comp.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    comp.pvpFallback:SetTextColor(0.5, 0.5, 0.5)
    comp.pvpFallback:Hide()

    return comp.section, comp.header, comp.content
end

-- args = { wowheadBis, ivBis, pvpBis, specKey, refresh }
function Gear.RenderCompendium(args)
    for i = 1, MAX_ROWS do comp.rows[i]:Hide() end

    -- Reset source/tab when browsing a different spec
    if args.specKey ~= compLastSpecKey then
        compSource = "Wowhead"
        compTab = nil
        compLastSpecKey = args.specKey
    end

    local wowheadBis, ivBis, pvpBis = args.wowheadBis, args.ivBis, args.pvpBis
    local hasWH = wowheadBis and #wowheadBis > 0
    local hasIV = ivBis and #ivBis > 0
    local hasPvP = pvpBis ~= nil

    comp.pvpFallback:Hide()
    if not hasWH and not hasIV and not hasPvP then return end

    if compSource == "Icy Veins" and not hasIV then compSource = "Wowhead" end
    if compSource == "Wowhead" and not hasWH then
        compSource = hasIV and "Icy Veins" or "PvP"
    end

    local availableSources = {}
    if hasWH then availableSources[#availableSources + 1] = "Wowhead" end
    if hasIV then availableSources[#availableSources + 1] = "Icy Veins" end
    availableSources[#availableSources + 1] = "PvP"

    local showSourceDropdown = #availableSources > 1
    if showSourceDropdown then
        comp.sourceDropdown:SetupMenu(function(_, rootDescription)
            for _, src in ipairs(availableSources) do
                rootDescription:CreateRadio(
                    (ns.BIS_SOURCE_LABELS and ns.BIS_SOURCE_LABELS[src]) or src,
                    function() return compSource == src end,
                    function()
                        compSource = src
                        compTab = nil
                        if args.refresh then args.refresh() end
                    end,
                    src)
            end
        end)
        comp.sourceDropdown:Show()
    else
        comp.sourceDropdown:Hide()
    end

    local pvpNoData = compSource == "PvP" and not hasPvP
    local activeBis
    if compSource == "PvP" then activeBis = pvpBis
    elseif compSource == "Icy Veins" then activeBis = ivBis
    else activeBis = wowheadBis end
    if not pvpNoData and (not activeBis or #activeBis == 0) then
        activeBis = wowheadBis or ivBis or pvpBis
    end

    if pvpNoData then
        local yOff = showSourceDropdown and -30 or 0
        comp.pvpFallback:SetText(L["pvp.no_gear_data"] or "No PvP gear data for this spec yet.")
        comp.pvpFallback:ClearAllPoints()
        comp.pvpFallback:SetPoint("TOPLEFT", comp.content, "TOPLEFT", 4, yOff - 4)
        comp.pvpFallback:Show()
        comp.tabDropdown:Hide()
        comp.content:SetHeight(math.abs(yOff) + 20)
        comp.section:Show()
        return
    end

    if not FindTabByLabel(activeBis, compTab) then
        compTab = activeBis[1].label
    end

    local showTabDropdown = #activeBis > 1
    if showTabDropdown then
        comp.tabDropdown:SetupMenu(function(_, rootDescription)
            for _, tab in ipairs(activeBis) do
                rootDescription:CreateRadio(tab.label,
                    function() return compTab == tab.label end,
                    function()
                        compTab = tab.label
                        if args.refresh then args.refresh() end
                    end,
                    tab.label)
            end
        end)
        comp.tabDropdown:Show()
    else
        comp.tabDropdown:Hide()
    end

    local selectedTab = FindTabByLabel(activeBis, compTab)
    local selectedSlots = selectedTab and selectedTab.slots or nil

    local yOffset = 0
    if showSourceDropdown then yOffset = yOffset - 30 end
    if showTabDropdown then
        comp.tabDropdown:ClearAllPoints()
        comp.tabDropdown:SetPoint("TOPLEFT", 0, yOffset)
        comp.tabDropdown:SetPoint("TOPRIGHT", 0, yOffset)
        yOffset = yOffset - 30
    end

    local idx = 0
    if selectedSlots then
        for _, g in ipairs(selectedSlots) do
            idx = idx + 1
            if idx > MAX_ROWS then break end
            local row = comp.rows[idx]
            row.slot:SetText(g.slot or "")
            row.name:SetText(ns.FormatItem(g.item))
            row.source:SetText(g.source or "")
            row.sourceText = g.source or nil
            row.itemId = g.item and g.item.itemId
            row.bonusIDs = g.item and g.item.bonusIDs
            ns.SetRowIcon(row, g.item and g.item.itemId)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", comp.content, "TOPLEFT", 0, yOffset - (idx - 1) * ns.ROW_HEIGHT)
            row:SetPoint("RIGHT", comp.content, "RIGHT", 0, 0)
            row:Show()
        end
    end
    comp.content:SetHeight(math.abs(yOffset) + idx * ns.ROW_HEIGHT)
    comp.section:Show()
end

function Gear.GetCompendiumContentHeight()
    local h = 0
    if comp.sourceDropdown:IsShown() then h = h + 30 end
    if comp.tabDropdown:IsShown() then h = h + 30 end
    if comp.pvpFallback:IsShown() then h = h + 20 end
    for i = 1, MAX_ROWS do
        if comp.rows[i]:IsShown() then h = h + ns.ROW_HEIGHT end
    end
    return h
end
