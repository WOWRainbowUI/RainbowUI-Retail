local _, ns = ...
ns.Sections = ns.Sections or {}

local L = ns.L

local Trinkets = {}
ns.Sections.Trinkets = Trinkets

-------------------------------------------------------------------------------
-- Shared constants + state helpers
-------------------------------------------------------------------------------

local MAX_ROWS = 20

local function LoadCtx()
    local specKey = ns.GetSpecKey and ns.GetSpecKey()
    if specKey and ClassCodexCharDB and ClassCodexCharDB.perSpec
        and ClassCodexCharDB.perSpec[specKey]
        and ClassCodexCharDB.perSpec[specKey].trinketContext then
        return ClassCodexCharDB.perSpec[specKey].trinketContext
    end
    return "All"
end

local function SaveCtx(ctx)
    local specKey = ns.GetSpecKey and ns.GetSpecKey()
    if not specKey or not ClassCodexCharDB then return end
    if not ClassCodexCharDB.perSpec then ClassCodexCharDB.perSpec = {} end
    if not ClassCodexCharDB.perSpec[specKey] then
        ClassCodexCharDB.perSpec[specKey] = {}
    end
    ClassCodexCharDB.perSpec[specKey].trinketContext = ctx
end

-- Trinket data source (default Icy Veins). Stored per current spec, alongside
-- trinketContext; GetSpecGearData reads the same pref so the panel, Compendium
-- and item-tooltip tier all reflect the chosen source.
local function LoadSource()
    local specKey = ns.GetSpecKey and ns.GetSpecKey()
    if specKey and ClassCodexCharDB and ClassCodexCharDB.perSpec
        and ClassCodexCharDB.perSpec[specKey]
        and ClassCodexCharDB.perSpec[specKey].trinketSource then
        return ClassCodexCharDB.perSpec[specKey].trinketSource
    end
    return "icyveins"
end

local function SaveSource(src)
    local specKey = ns.GetSpecKey and ns.GetSpecKey()
    if not specKey or not ClassCodexCharDB then return end
    if not ClassCodexCharDB.perSpec then ClassCodexCharDB.perSpec = {} end
    if not ClassCodexCharDB.perSpec[specKey] then
        ClassCodexCharDB.perSpec[specKey] = {}
    end
    ClassCodexCharDB.perSpec[specKey].trinketSource = src
end

local function SourceHasTrinkets(src, classToken, specKey)
    local sd = ns.SourceSpec and ns.SourceSpec(src, classToken, specKey)
    return not not (sd and sd.trinkets and sd.trinkets["all"] and sd.trinkets["all"]["all"])
end

local function CollectContexts(trinkets)
    local contexts, seen = {}, {}
    for _, t in ipairs(trinkets) do
        if t.contexts then
            for _, ctx in ipairs(t.contexts) do
                if not seen[ctx] then
                    seen[ctx] = true
                    contexts[#contexts + 1] = ctx
                end
            end
        end
    end
    return contexts
end

local function FilterAndSort(trinkets, ctxKey)
    local TIER_ORDER = ns.TIER_ORDER
    local filtered = {}
    local key = ctxKey ~= "All" and ctxKey or nil
    for i, t in ipairs(trinkets) do
        local include = not key
        if key and t.contexts then
            for _, ctx in ipairs(t.contexts) do
                if ctx == key then include = true; break end
            end
        end
        if include then filtered[#filtered + 1] = { t = t, i = i } end
    end
    -- Group by tier, but keep the source's within-tier order: table.sort is not
    -- stable, so we tie-break on the original index. The data arrives in the
    -- source's ranked order (e.g. Icy Veins' page order), which we preserve.
    table.sort(filtered, function(a, b)
        local ta, tb = TIER_ORDER[a.t.tier] or 99, TIER_ORDER[b.t.tier] or 99
        if ta ~= tb then return ta < tb end
        return a.i < b.i
    end)
    local out = {}
    for _, w in ipairs(filtered) do out[#out + 1] = w.t end
    return out
end

local function CtxLabel(ctx)
    return (ns.CONTEXT_LABELS and ns.CONTEXT_LABELS[ctx]) or ctx
end

local function SetTierColor(textWidget, tier)
    local color = ns.TIER_COLORS and ns.TIER_COLORS[tier]
    if color then
        textWidget:SetTextColor(color.r, color.g, color.b)
    else
        textWidget:SetTextColor(1, 1, 1)
    end
end

-------------------------------------------------------------------------------
-- Panel surface
-------------------------------------------------------------------------------

local panel = {}

function Trinkets.InitPanel(parent)
    panel.section = CreateFrame("Frame", nil, parent)
    panel.section:SetHeight(ns.SECTION_HEADER_HEIGHT)
    panel.title = ns.CreateSectionTitle(panel.section, L["tab.trinkets"])
    panel.content = CreateFrame("Frame", nil, panel.section)
    panel.content:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, 0)
    panel.content:SetPoint("RIGHT", 0, 0)
    panel.content:Show()

    panel.sourceDropdown = ns.CreateOptionDropdown("ClassCodexTrinketSourceDropdown", panel.content)
    panel.sourceDropdown:SetPoint("TOPLEFT", 0, 0)
    panel.sourceDropdown:SetPoint("TOPRIGHT", 0, 0)
    panel.sourceDropdown:Hide()

    panel.ctxDropdown = ns.CreateOptionDropdown("ClassCodexTrinketCtxDropdown", panel.content)
    panel.ctxDropdown:SetPoint("TOPLEFT", 0, 0)
    panel.ctxDropdown:SetPoint("TOPRIGHT", 0, 0)
    panel.ctxDropdown:Hide()

    panel.rows = {}
    for i = 1, MAX_ROWS do
        local row = CreateFrame("Frame", nil, panel.content)
        row:SetHeight(ns.ROW_HEIGHT)
        local ownedBg = row:CreateTexture(nil, "BACKGROUND")
        ownedBg:SetAllPoints(row)
        ownedBg:SetColorTexture(0.2, 0.9, 0.2, 0.10)
        ownedBg:Hide()
        row.ownedBg = ownedBg
        local tier = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tier:SetPoint("LEFT", 2, 0); tier:SetWidth(16); tier:SetJustifyH("CENTER")
        row.tierText = tier
        ns.CreateRowIcon(row)
        row.icon:ClearAllPoints()
        row.icon:SetPoint("LEFT", tier, "RIGHT", 4, 0)
        local src = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        src:SetPoint("RIGHT", -2, 0); src:SetWidth(90); src:SetJustifyH("RIGHT")
        src:SetWordWrap(false); src:SetTextColor(0.5, 0.5, 0.5)
        row.sourceLabel = src
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        name:SetPoint("RIGHT", src, "LEFT", -4, 0)
        name:SetJustifyH("LEFT"); name:SetWordWrap(false)
        row.itemText = name
        ns.SetupItemTooltip(row)
        row:Hide()
        panel.rows[i] = row
    end
    return panel.section
end

function Trinkets.IsPanelCtxDropdownShown() return panel.ctxDropdown:IsShown() end
function Trinkets.IsPanelSourceDropdownShown() return panel.sourceDropdown:IsShown() end

-- args = { trinkets, onChange }
-- Returns the rendered row count (height in ROW_HEIGHT units).
function Trinkets.RenderPanel(args)
    for i = 1, MAX_ROWS do panel.rows[i]:Hide() end
    if not args.trinkets or #args.trinkets == 0 then
        panel.sourceDropdown:Hide()
        panel.ctxDropdown:Hide()
        return 0
    end

    local yOffset = 0

    -- Source dropdown (top) — only when both sources carry trinkets for the spec.
    local classToken, specKey = ns.GetClassAndSpec()
    local hasIV  = SourceHasTrinkets("icyveins", classToken, specKey)
    local hasUgg = SourceHasTrinkets("ugg", classToken, specKey)
    if hasIV and hasUgg then
        local labels = ns.TRINKET_SOURCE_LABELS or {}
        local srcOpts = {
            { label = labels.icyveins or "Icy Veins", value = "icyveins" },
            { label = labels.ugg or "u.gg", value = "ugg" },
        }
        panel.sourceDropdown:ClearAllPoints()
        panel.sourceDropdown:SetPoint("TOPLEFT", 0, yOffset)
        panel.sourceDropdown:SetPoint("TOPRIGHT", 0, yOffset)
        panel.sourceDropdown:Show()
        panel.sourceDropdown:SetOptions(srcOpts, LoadSource(), function(picked)
            SaveSource(picked)
            if args.onChange then args.onChange() end
        end)
        yOffset = yOffset - 30
    else
        panel.sourceDropdown:Hide()
    end

    -- Context dropdown (below the source dropdown).
    local ctxKey = LoadCtx()
    local contexts = CollectContexts(args.trinkets)
    local showDropdown = #contexts > 1

    if showDropdown then
        local opts = { { label = "All", value = "All" } }
        for _, c in ipairs(contexts) do
            opts[#opts + 1] = { label = CtxLabel(c), value = c }
        end
        panel.ctxDropdown:ClearAllPoints()
        panel.ctxDropdown:SetPoint("TOPLEFT", 0, yOffset)
        panel.ctxDropdown:SetPoint("TOPRIGHT", 0, yOffset)
        panel.ctxDropdown:Show()
        panel.ctxDropdown:SetOptions(opts, ctxKey, function(picked)
            SaveCtx(picked)
            if args.onChange then args.onChange() end
        end)
        yOffset = yOffset - 30
    else
        panel.ctxDropdown:Hide()
    end

    local filtered = FilterAndSort(args.trinkets, ctxKey)
    local count = math.min(#filtered, MAX_ROWS)

    for i = 1, count do
        local t = filtered[i]
        local row = panel.rows[i]
        row.tierText:SetText(t.tier)
        SetTierColor(row.tierText, t.tier)
        row.itemText:SetText(ns.FormatItem({ itemId = t.itemId, name = "" }))
        row.itemId = t.itemId
        row.bonusIDs = t.bonusIDs
        row.altItemId = nil
        row.embItemId = nil
        row.sourceText = t.source or nil
        row.sourceLabel:SetText(t.source or "")
        ns.SizeSourceColumn(row.sourceLabel, row:GetParent():GetWidth(), 48, 92, 180)
        ns.SetRowIcon(row, t.itemId)
        if row.ownedBg then
            if ns.IsItemOwned(t.itemId) then row.ownedBg:Show() else row.ownedBg:Hide() end
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
-- Compendium surface
-------------------------------------------------------------------------------

local comp = {}
-- Session-scoped Compendium trinket source (registry key), independent of the
-- panel's saved per-spec pref. Resets to Icy Veins when the browsed spec
-- changes — mirrors the BiS Compendium source model in Sections/Gear.lua.
local compSource = "icyveins"
local compLastSpecKey = nil

-- Resolve (and validate) the active Compendium trinket source for a spec.
-- Called by Compendium.lua before fetching, so the reset happens before the
-- data is read.
function Trinkets.GetCompendiumSourceKey(classToken, specKey)
    if specKey ~= compLastSpecKey then
        compSource = "icyveins"
        compLastSpecKey = specKey
    end
    if compSource == "icyveins" and not SourceHasTrinkets("icyveins", classToken, specKey) then
        compSource = "ugg"
    elseif compSource == "ugg" and not SourceHasTrinkets("ugg", classToken, specKey) then
        compSource = "icyveins"
    end
    return compSource
end

-- opts.parent + opts.headerFactory + opts.rowFactory (Compendium-side
-- MakeItemRow with click-to-link + tooltip)
function Trinkets.InitCompendium(opts)
    comp.section = CreateFrame("Frame", nil, opts.parent)
    comp.header = opts.headerFactory(comp.section, L["tab.trinkets"], false)
    comp.content = CreateFrame("Frame", nil, comp.section)
    comp.content:SetPoint("TOPLEFT", comp.header, "BOTTOMLEFT", 0, -2)
    comp.content:SetPoint("RIGHT", 0, 0)

    comp.rows = {}
    for i = 1, MAX_ROWS do
        local row = opts.rowFactory(comp.content)
        local tier = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tier:SetPoint("LEFT", 2, 0); tier:SetWidth(16); tier:SetJustifyH("CENTER")
        row.tier = tier
        ns.CreateRowIcon(row)
        row.icon:ClearAllPoints()
        row.icon:SetPoint("LEFT", tier, "RIGHT", 4, 0)
        local src = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        src:SetPoint("RIGHT", -2, 0); src:SetWidth(120); src:SetJustifyH("RIGHT")
        src:SetWordWrap(false); src:SetTextColor(0.5, 0.5, 0.5)
        row.source = src
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        name:SetPoint("RIGHT", src, "LEFT", -4, 0)
        name:SetJustifyH("LEFT"); name:SetWordWrap(false)
        row.name = name
        comp.rows[i] = row
    end

    comp.sourceDropdown = CreateFrame(
        "DropdownButton", "ClassCodexCompTrinketSourceDD",
        comp.content, "WowStyle1DropdownTemplate"
    )
    comp.sourceDropdown:SetPoint("TOPLEFT", 0, 0)
    comp.sourceDropdown:SetPoint("TOPRIGHT", 0, 0)
    comp.sourceDropdown:SetHeight(24)
    comp.sourceDropdown:Hide()

    comp.ctxDropdown = CreateFrame(
        "DropdownButton", "ClassCodexCompTrinketCtxDD",
        comp.content, "WowStyle1DropdownTemplate"
    )
    comp.ctxDropdown:SetPoint("TOPLEFT", 0, 0)
    comp.ctxDropdown:SetPoint("TOPRIGHT", 0, 0)
    comp.ctxDropdown:SetHeight(24)
    comp.ctxDropdown:Hide()

    return comp.section, comp.header, comp.content
end

-- args = { trinkets, class, specKey, refresh }
function Trinkets.RenderCompendium(args)
    if not args or not args.trinkets then return end
    for i = 1, MAX_ROWS do comp.rows[i]:Hide() end

    local dropH = 0

    -- Source dropdown (top) — only when both sources carry trinkets for the spec.
    if SourceHasTrinkets("icyveins", args.class, args.specKey)
        and SourceHasTrinkets("ugg", args.class, args.specKey) then
        local labels = ns.TRINKET_SOURCE_LABELS or {}
        comp.sourceDropdown:SetupMenu(function(_, rootDescription)
            for _, src in ipairs({ "icyveins", "ugg" }) do
                rootDescription:CreateRadio(labels[src] or src,
                    function() return compSource == src end,
                    function()
                        compSource = src
                        if args.refresh then args.refresh() end
                    end,
                    src)
            end
        end)
        comp.sourceDropdown:ClearAllPoints()
        comp.sourceDropdown:SetPoint("TOPLEFT", 0, -dropH)
        comp.sourceDropdown:SetPoint("TOPRIGHT", 0, -dropH)
        comp.sourceDropdown:Show()
        dropH = dropH + 30
    else
        comp.sourceDropdown:Hide()
    end

    local ctxKey = LoadCtx()
    local contexts = CollectContexts(args.trinkets)
    local showDropdown = #contexts > 1

    if showDropdown then
        local valid = ctxKey == "All"
        if not valid then
            for _, c in ipairs(contexts) do
                if c == ctxKey then valid = true; break end
            end
        end
        if not valid then ctxKey = "All"; SaveCtx("All") end

        local allOptions = { "All" }
        for _, c in ipairs(contexts) do allOptions[#allOptions + 1] = c end

        comp.ctxDropdown:SetupMenu(function(_, rootDescription)
            for _, ctx in ipairs(allOptions) do
                local label = ctx == "All" and "All" or CtxLabel(ctx)
                rootDescription:CreateRadio(label,
                    function() return ctxKey == ctx end,
                    function()
                        SaveCtx(ctx)
                        if args.refresh then args.refresh() end
                    end,
                    ctx)
            end
        end)
        comp.ctxDropdown:ClearAllPoints()
        comp.ctxDropdown:SetPoint("TOPLEFT", 0, -dropH)
        comp.ctxDropdown:SetPoint("TOPRIGHT", 0, -dropH)
        comp.ctxDropdown:Show()
        dropH = dropH + 30
    else
        comp.ctxDropdown:Hide()
    end

    local filtered = FilterAndSort(args.trinkets, ctxKey)
    local yOffset = -dropH
    local idx = 0
    for _, t in ipairs(filtered) do
        idx = idx + 1
        if idx > MAX_ROWS then break end
        local row = comp.rows[idx]
        row.tier:SetText(t.tier or "?")
        SetTierColor(row.tier, t.tier)
        row.name:SetText(ns.FormatItem({ itemId = t.itemId, name = t.name }))
        row.itemId = t.itemId
        row.bonusIDs = t.bonusIDs
        row.source:SetText(t.source or "")
        ns.SetRowIcon(row, t.itemId)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", comp.content, "TOPLEFT", 0, yOffset - (idx - 1) * ns.ROW_HEIGHT)
        row:SetPoint("RIGHT", comp.content, "RIGHT", 0, 0)
        row:Show()
    end
    comp.content:SetHeight(dropH + idx * ns.ROW_HEIGHT)
    comp.section:Show()
end

function Trinkets.GetCompendiumContentHeight()
    local h = 0
    if comp.sourceDropdown:IsShown() then h = h + 30 end
    if comp.ctxDropdown:IsShown() then h = h + 30 end
    for i = 1, MAX_ROWS do
        if comp.rows[i]:IsShown() then h = h + ns.ROW_HEIGHT end
    end
    return h
end
