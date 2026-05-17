local addonName, ns = ...

local GEAR_DATA = ClassCodexGearData
local L = ns.L

local IV_DATA = ClassCodexIcyVeinsData or {}

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local ROW_HEIGHT = 24
local SECTION_HEADER_HEIGHT = 24

local TIER_COLORS = {
    S = { r = 1.00, g = 0.50, b = 0.00 },
    A = { r = 0.64, g = 0.21, b = 0.93 },
    B = { r = 0.00, g = 0.44, b = 0.87 },
    C = { r = 0.12, g = 1.00, b = 0.00 },
    D = { r = 0.62, g = 0.62, b = 0.62 },
}

local TIER_ORDER = { S = 1, A = 2, B = 3, C = 4, D = 5 }

local CONTEXT_LABELS = {
    raid = L["Raid"],
    dungeon = L["Dungeon"],
    delves = L["Delves"],
    crafting = L["Crafting"],
}

local CONSUMABLE_ORDER = { "flask", "combatPotion", "food", "weaponBuff", "augmentRune" }
local CONSUMABLE_LABELS = {
    flask = L["Flask"],
    combatPotion = L["Combat Potion"],
    food = L["Food"],
    weaponBuff = L["Weapon Buff"],
    augmentRune = L["Augment Rune"],
}

local MAX_ENCHANT_ROWS = 8
local MAX_GEM_ROWS = 4
local MAX_CONSUMABLE_ROWS = 6
local MAX_TRINKET_ROWS = 15
local MAX_CRAFT_ROWS = 12
local MAX_BIS_ROWS = 18

-------------------------------------------------------------------------------
-- Item Cache
-------------------------------------------------------------------------------

local itemCache = {}
local pendingItems = {}
local gearingDirty = false

local function RequestItemData(itemId)
    if not itemId or itemId == 0 then return end
    if itemCache[itemId] or pendingItems[itemId] then return end
    pendingItems[itemId] = true
    C_Item.RequestLoadItemDataByID(itemId)
end

local function GetItemName(itemRef)
    if not itemRef then return "" end
    -- Spell-based entries (e.g. DK runeforges): resolve via C_Spell
    if itemRef.spellId then
        if C_Spell and C_Spell.GetSpellName then
            local name = C_Spell.GetSpellName(itemRef.spellId)
            if name then return name end
        elseif GetSpellInfo then
            local name = GetSpellInfo(itemRef.spellId)
            if name then return name end
        end
    end
    local cached = itemCache[itemRef.itemId]
    if cached and cached.name then return cached.name end
    if itemRef.name and itemRef.name ~= "" then return itemRef.name end
    if itemRef.spellId then return "Spell " .. itemRef.spellId end
    return "Item " .. itemRef.itemId
end

local function GetItemQuality(itemId)
    local cached = itemCache[itemId]
    return cached and cached.quality or nil
end

-- FormatItem(itemRef [, name]) -> string
-- Convenience wrapper around ns.FormatItemLabel that pulls the
-- quality from the cache for callers that don't already have it.
-- Pass an explicit name override (e.g. after StripEnchantPrefix)
-- when the displayed text differs from the resolved item name.
local function FormatItem(itemRef, nameOverride)
    if not itemRef then return "" end
    local name = nameOverride or GetItemName(itemRef)
    return ns.FormatItemLabel(name, GetItemQuality(itemRef.itemId))
end

local itemEventFrame = CreateFrame("Frame")
itemEventFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
itemEventFrame:SetScript("OnEvent", function(_, _, itemId, success)
    if success then
        pendingItems[itemId] = nil
        local name, _, quality, _, _, _, _, _, _, icon = GetItemInfo(itemId)
        if name then
            itemCache[itemId] = { name = name, quality = quality, icon = icon }
            if not gearingDirty then
                gearingDirty = true
                C_Timer.After(0.1, function()
                    gearingDirty = false
                    if ns.panel and ns.panel:IsShown() then
                        ns:UpdateGearingSections()
                        ns:LayoutPanel()
                    end
                end)
            end
        end
    end
end)

local function RequestAllItems(gearData)
    if not gearData then return end
    if gearData.enchants then
        for _, e in ipairs(gearData.enchants) do
            RequestItemData(e.best.itemId)
            if e.alternate then RequestItemData(e.alternate.itemId) end
        end
    end
    if gearData.gems then
        RequestItemData(gearData.gems.primary.itemId)
        if gearData.gems.secondary then
            for _, g in ipairs(gearData.gems.secondary) do RequestItemData(g.itemId) end
        end
    end
    if gearData.consumables then
        for _, key in ipairs(CONSUMABLE_ORDER) do
            if gearData.consumables[key] then RequestItemData(gearData.consumables[key].itemId) end
        end
    end
    if gearData.trinkets then
        for _, t in ipairs(gearData.trinkets) do RequestItemData(t.itemId) end
    end
    if gearData.crafts then
        for _, list in ipairs({ gearData.crafts.earlyCrafts, gearData.crafts.bisCrafts }) do
            if list then
                for _, s in ipairs(list) do
                    RequestItemData(s.item.itemId)
                    if s.embellishment then RequestItemData(s.embellishment.itemId) end
                end
            end
        end
    end
    if gearData.bisGear then
        for _, tab in ipairs(gearData.bisGear) do
            for _, g in ipairs(tab.slots) do RequestItemData(g.item.itemId) end
        end
    end
end

-------------------------------------------------------------------------------
-- Gear Data Lookup
-------------------------------------------------------------------------------

local function GetSpecGearData()
    if not GEAR_DATA then return nil end
    local classToken, specKey = ns.GetClassAndSpec()
    if not classToken or not specKey then return nil end
    local classData = GEAR_DATA[classToken]
    if not classData then return nil end
    return classData[specKey]
end

-- Resolve the (classToken, spec-without-class-prefix) pair the docked
-- panel uses for PvP data lookups via PvPData.lua. The docked surface
-- always reflects the player's current spec.
local function GetPlayerClassSpec()
    local classToken = select(2, UnitClass("player"))
    local specKey = ns.GetSpecKey()
    if not classToken or not specKey then return nil, nil end
    local spec = specKey:match("-(.+)") or specKey
    return classToken, spec
end

-- PvP shape conversion lives in PvPData.lua so the Compendium and the
-- docked panel consume the same builders. Bundled into one table to
-- minimise upvalue pressure on UpdateGearingSections (Lua's 60-upvalue
-- limit was tripping after these helpers were added).
local PvP = {
    bis = function()
        if not ns.BuildPvPBisTabs then return nil end
        local classToken, spec = GetPlayerClassSpec()
        return ns.BuildPvPBisTabs(classToken, spec)
    end,
    enchants = function()
        if not ns.BuildPvPEnchantsRows then return nil end
        local classToken, spec = GetPlayerClassSpec()
        return ns.BuildPvPEnchantsRows(classToken, spec)
    end,
    gems = function()
        if not ns.BuildPvPGemsRecord then return nil end
        local classToken, spec = GetPlayerClassSpec()
        return ns.BuildPvPGemsRecord(classToken, spec)
    end,
}

-- Expose trinket tier lookup for tooltip integration
function ns:GetTrinketTier(itemId)
    local gearData = GetSpecGearData()
    if not gearData or not gearData.trinkets then return nil, nil, nil end
    for _, t in ipairs(gearData.trinkets) do
        if t.itemId == itemId then
            local color = TIER_COLORS[t.tier]
            return t.tier, color, t.source
        end
    end
    return nil, nil, nil
end

-- Build reverse lookup: itemId → entries with class token for coloring
local CLASS_DISPLAY = {
    DEATHKNIGHT = "Death Knight", DEMONHUNTER = "Demon Hunter",
    DRUID = "Druid", EVOKER = "Evoker", HUNTER = "Hunter",
    MAGE = "Mage", MONK = "Monk", PALADIN = "Paladin",
    PRIEST = "Priest", ROGUE = "Rogue", SHAMAN = "Shaman",
    WARLOCK = "Warlock", WARRIOR = "Warrior",
}

-- Count how many specs each class has in GEAR_DATA
local CLASS_SPEC_COUNT = {} -- classToken → number of specs

local wowheadBisLookup = {}     -- itemId → { { label = "Frost Mage", class = "MAGE", spec = "Frost" }, ... }
local icyVeinsBisLookup = {}    -- itemId → { { label = "Frost Mage", class = "MAGE", spec = "Frost", tabs = {"Overall","Mythic+"} }, ... }
local trinketLookup = {} -- itemId → { { label = "Frost Mage", class = "MAGE", spec = "Frost", tier = "S" }, ... }
local trinketSourceLookup = {} -- itemId → source string (e.g. "Chimaerus")

-- Expose trinket source lookup (pre-built in BuildBisLookup)
function ns:GetTrinketSource(itemId)
    return trinketSourceLookup[itemId]
end

local function BuildBisLookup()
    if not GEAR_DATA then return end
    -- Count specs per class
    for classToken, specs in pairs(GEAR_DATA) do
        local count = 0
        for _ in pairs(specs) do count = count + 1 end
        CLASS_SPEC_COUNT[classToken] = count
    end

    for classToken, specs in pairs(GEAR_DATA) do
        local className = CLASS_DISPLAY[classToken] or classToken
        for specKey, specData in pairs(specs) do
            local specDisplay = specKey:sub(1, 1):upper() .. specKey:sub(2)
            local label = specDisplay .. " " .. className

            -- Build a set of trinket itemIds for this spec to exclude from bisGear
            local trinketIds = {}
            if specData.trinkets then
                for _, t in ipairs(specData.trinkets) do
                    trinketIds[t.itemId] = true
                end
            end

            if specData.bisGear then
                -- Only use "Overall" tab for tooltip lookups
                for _, tab in ipairs(specData.bisGear) do
                    if tab.label == "Overall" then
                        for _, entry in ipairs(tab.slots) do
                            local id = entry.item.itemId
                            -- Skip trinket slots — those are handled by the trinket tier list
                            local slotLower = entry.slot and entry.slot:lower() or ""
                            if not slotLower:find("trinket") and not trinketIds[id] then
                                if not wowheadBisLookup[id] then wowheadBisLookup[id] = {} end
                                wowheadBisLookup[id][#wowheadBisLookup[id] + 1] = { label = label, class = classToken, spec = specDisplay }
                            end
                        end
                        break
                    end
                end
            end

            if specData.trinkets then
                for _, t in ipairs(specData.trinkets) do
                    local id = t.itemId
                    if not trinketLookup[id] then trinketLookup[id] = {} end
                    trinketLookup[id][#trinketLookup[id] + 1] = { label = label, class = classToken, spec = specDisplay, tier = t.tier }
                    if t.source and not trinketSourceLookup[id] then
                        trinketSourceLookup[id] = t.source
                    end
                end
            end
        end
    end

    -- Build Icy Veins BiS lookup (all tabs — items differ between M+/Raid/Overall)
    for classToken, specs in pairs(IV_DATA) do
        local className = CLASS_DISPLAY[classToken] or classToken
        if not CLASS_SPEC_COUNT[classToken] then
            local count = 0
            for _ in pairs(specs) do count = count + 1 end
            CLASS_SPEC_COUNT[classToken] = count
        end
        for specKey, specData in pairs(specs) do
            local specDisplay = specKey:sub(1, 1):upper() .. specKey:sub(2)
            local label = specDisplay .. " " .. className
            if specData.bisGear then
                for _, tab in ipairs(specData.bisGear) do
                    for _, entry in ipairs(tab.slots) do
                        local id = entry.item.itemId
                        -- Find or create entry for this spec+item
                        if not icyVeinsBisLookup[id] then icyVeinsBisLookup[id] = {} end
                        local found = false
                        for _, existing in ipairs(icyVeinsBisLookup[id]) do
                            if existing.label == label then
                                existing.tabs[#existing.tabs + 1] = tab.label
                                found = true
                                break
                            end
                        end
                        if not found then
                            icyVeinsBisLookup[id][#icyVeinsBisLookup[id] + 1] = {
                                label = label, class = classToken, spec = specDisplay,
                                tabs = { tab.label },
                            }
                        end
                    end
                end
            end
        end
    end
end

BuildBisLookup()

-- Consolidate entries: if all specs of a class share the same entry, show just the class name
local function ConsolidateByClass(entries)
    -- Group by class
    local byClass = {}
    local classOrder = {}
    for _, entry in ipairs(entries) do
        if not byClass[entry.class] then
            byClass[entry.class] = {}
            classOrder[#classOrder + 1] = entry.class
        end
        byClass[entry.class][#byClass[entry.class] + 1] = entry
    end

    local result = {}
    for _, classToken in ipairs(classOrder) do
        local classEntries = byClass[classToken]
        local totalSpecs = CLASS_SPEC_COUNT[classToken] or 0
        local className = CLASS_DISPLAY[classToken] or classToken
        -- Only consolidate if all specs share the same tier
        local sameTier = true
        if #classEntries > 1 then
            for i = 2, #classEntries do
                if classEntries[i].tier ~= classEntries[1].tier then sameTier = false; break end
            end
        end
        if #classEntries >= totalSpecs and totalSpecs > 0 and sameTier then
            -- All specs, same tier — show class name, flag as consolidated
            result[#result + 1] = { label = className, class = classToken, tier = classEntries[1].tier, consolidated = true }
        else
            for _, e in ipairs(classEntries) do
                e.consolidated = false
                result[#result + 1] = e
            end
        end
    end
    return result
end

function ns:GetWowheadBisSpecs(itemId)
    local raw = wowheadBisLookup[itemId]
    if not raw then return nil end
    return ConsolidateByClass(raw)
end

function ns:GetIcyVeinsBisSpecs(itemId)
    local raw = icyVeinsBisLookup[itemId]
    if not raw then return nil end
    return ConsolidateByClass(raw)
end

function ns:GetIcyVeinsData()
    return IV_DATA
end

function ns:GetIcyVeinsSpecData(classToken, specKey)
    if not classToken or not specKey then return nil end
    local classData = IV_DATA[classToken]
    if not classData then return nil end
    return classData[specKey]
end

function ns:GetTrinketSpecs(itemId)
    local raw = trinketLookup[itemId]
    if not raw then return nil end
    return ConsolidateByClass(raw)
end

-------------------------------------------------------------------------------
-- Section Title (non-collapsible, like the About page title)
-------------------------------------------------------------------------------

local TITLE_HEIGHT = SECTION_HEADER_HEIGHT

local function CreateSectionTitle(parent, label)
    local hdr = CreateFrame("Frame", nil, parent)
    hdr:SetHeight(SECTION_HEADER_HEIGHT)
    hdr:SetPoint("TOPLEFT", 0, 0)
    hdr:SetPoint("RIGHT", 0, 0)
    local title = hdr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", 2, 0)
    title:SetText(label)
    title:SetTextColor(1, 0.82, 0)
    return hdr
end

-------------------------------------------------------------------------------
-- Item Icon Helper
-------------------------------------------------------------------------------

local ICON_SIZE = 16

local function GetItemIcon(itemId)
    local cached = itemCache[itemId]
    if cached and cached.icon then return cached.icon end
    local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemId)
    return icon
end

local function CreateRowIcon(row)
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("LEFT", 2, 0)
    icon:Hide()
    row.icon = icon
    return icon
end

local function GetSpellIcon(spellId)
    if not spellId then return nil end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellId)
        if info and info.iconID then return info.iconID end
    end
    return nil
end

local function SetRowIcon(row, itemId, spellId)
    if not row.icon then return end
    -- Try spell icon first (for DK runeforges), then item icon
    local tex = GetSpellIcon(spellId) or GetItemIcon(itemId)
    if tex then
        row.icon:SetTexture(tex)
        row.icon:Show()
    else
        row.icon:Hide()
    end
end

-------------------------------------------------------------------------------
-- Item Tooltip Helper
-------------------------------------------------------------------------------

local function GetItemLink(itemId)
    local _, link = C_Item.GetItemInfo(itemId)
    return link
end

local function HandleItemClick(self)
    if not self.itemId then return end
    local link = GetItemLink(self.itemId)
    if not link then return end
    if IsModifiedClick("CHATLINK") then
        ChatEdit_InsertLink(link)
    elseif IsModifiedClick("DRESSUP") then
        DressUpItemLink(link)
    end
end

local function SetupItemTooltip(row)
    row:EnableMouse(true)
    row:SetScript("OnMouseUp", HandleItemClick)
    row:SetScript("OnEnter", function(self)
        if self.spellId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.spellId)
            GameTooltip:Show()
        elseif self.itemId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.bonusIDs and #self.bonusIDs > 0 then
                local bonusStr = #self.bonusIDs .. ":" .. table.concat(self.bonusIDs, ":")
                local link = format("item:%d::::::::::::%s", self.itemId, bonusStr)
                local ok = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
                if not ok then GameTooltip:SetItemByID(self.itemId) end
            else
                GameTooltip:SetItemByID(self.itemId)
            end
            if self.altItemId then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Alternative:", 0.6, 0.6, 0.6)
                local altRef = { itemId = self.altItemId, name = self.altName or "" }
                GameTooltip:AddLine("  " .. FormatItem(altRef))
            end
            if self.embItemId then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Embellishment:", 0.6, 0.6, 0.6)
                local embRef = { itemId = self.embItemId, name = self.embName or "" }
                GameTooltip:AddLine("  " .. FormatItem(embRef))
            end
            if self.sourceText then
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine("Source", self.sourceText, 0.5, 0.5, 0.5, 1, 0.82, 0)
            end
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-------------------------------------------------------------------------------
-- Section: Enchants
-------------------------------------------------------------------------------

local enchantSection = CreateFrame("Frame", nil, ns.contentFrame)
enchantSection:SetHeight(SECTION_HEADER_HEIGHT)
local enchantHeader = ns.CreateSectionHeader(enchantSection, L["Enchants"])
local enchantContent = CreateFrame("Frame", nil, enchantSection)
enchantContent:SetPoint("TOPLEFT", enchantHeader, "BOTTOMLEFT", 0, 0)
enchantContent:SetPoint("RIGHT", 0, 0)
local enchantCollapsed = false
ns.SetCollapsed(enchantContent, enchantHeader, enchantCollapsed)

-- All PvP-related dock state bundled into one table to keep
-- UpdateGearingSections under Lua's 60-upvalue ceiling. Includes:
--   sourceDropdown — Wowhead/PvP toggle above the enchant rows
--   fallback       — "No PvP enchant/gem data..." line shown when PvP
--                    is selected for a spec without Murlok data
--   bisFallback    — same idea for the BiS section
--   currentSource  — "Wowhead" or "PvP", session state
--   lastSpecKey    — guard for "reset on spec switch"
local pvpDock = {
    sourceDropdown = ns.CreateOptionDropdown("ClassCodexDockEnhancementsSourceDropdown", enchantContent),
    currentSource  = "Wowhead",
    lastSpecKey    = nil,
}
pvpDock.sourceDropdown:SetPoint("TOPLEFT", 0, 0)
pvpDock.sourceDropdown:SetPoint("TOPRIGHT", 0, 0)
pvpDock.sourceDropdown:Hide()

pvpDock.fallback = enchantContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
pvpDock.fallback:SetTextColor(0.5, 0.5, 0.5)
pvpDock.fallback:Hide()

enchantHeader:SetScript("OnClick", function()
    enchantCollapsed = not enchantCollapsed
    ns.SetCollapsed(enchantContent, enchantHeader, enchantCollapsed)
    if ClassCodexCharDB and ClassCodexCharDB.collapsed then
        ClassCodexCharDB.collapsed.enchants = enchantCollapsed
    end
    ns:LayoutPanel()
end)

local function SetupSingleItemTooltip(frame)
    frame:EnableMouse(true)
    frame.itemId = nil
    frame:SetScript("OnEnter", function(self)
        if self.spellId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.spellId)
            GameTooltip:Show()
        elseif self.itemId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.bonusIDs and #self.bonusIDs > 0 then
                local bonusStr = #self.bonusIDs .. ":" .. table.concat(self.bonusIDs, ":")
                local link = format("item:%d::::::::::::%s", self.itemId, bonusStr)
                local ok = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
                if not ok then GameTooltip:SetItemByID(self.itemId) end
            else
                GameTooltip:SetItemByID(self.itemId)
            end
            GameTooltip:Show()
        end
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame:SetScript("OnMouseUp", HandleItemClick)
end

-- Strip "Enchant [Type] - " prefix from enchant names (slot label already shows it)
-- e.g. "Enchant Weapon - Arcane Mastery" → "Arcane Mastery"
local function StripEnchantPrefix(name)
    local stripped = name:match("^Enchant [^%-]+ %- (.+)$")
    return stripped or name
end

local function CreateEnchantSubRow(parent)
    local sub = CreateFrame("Frame", nil, parent)
    sub:SetHeight(ROW_HEIGHT)
    local name = sub:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("LEFT", 0, 0)
    name:SetPoint("RIGHT", 0, 0)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(true)
    sub.text = name
    SetupSingleItemTooltip(sub)
    sub:Hide()
    return sub
end

local enchantRows = {}
for i = 1, MAX_ENCHANT_ROWS do
    local row = CreateFrame("Frame", nil, enchantContent)
    row:SetHeight(ROW_HEIGHT)

    -- Icon (left side, vertically centered in full row)
    CreateRowIcon(row)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)

    -- Slot label (after icon, vertically centered in full row)
    local slot = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slot:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    slot:SetWidth(50)
    slot:SetJustifyH("LEFT")
    slot:SetTextColor(0.6, 0.6, 0.6)
    row.slotText = slot

    -- Best item sub-row (text + tooltip, no icon)
    local bestSub = CreateEnchantSubRow(row)
    bestSub:SetPoint("TOPLEFT", row, "TOPLEFT", 2 + ICON_SIZE + 4 + 50 + 2, 0)
    bestSub:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.bestSub = bestSub

    -- Alternate item sub-row (text + tooltip, no icon)
    local altSub = CreateEnchantSubRow(row)
    altSub:SetPoint("TOPLEFT", bestSub, "BOTTOMLEFT", 0, 0)
    altSub:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row.altSub = altSub

    row:Hide()
    enchantRows[i] = row
end

-------------------------------------------------------------------------------
-- Section: Gems
-------------------------------------------------------------------------------

local gemSection = CreateFrame("Frame", nil, ns.contentFrame)
gemSection:SetHeight(SECTION_HEADER_HEIGHT)
local gemHeader = ns.CreateSectionHeader(gemSection, L["Gems"])
local gemContent = CreateFrame("Frame", nil, gemSection)
gemContent:SetPoint("TOPLEFT", gemHeader, "BOTTOMLEFT", 0, 0)
gemContent:SetPoint("RIGHT", 0, 0)
local gemCollapsed = false
ns.SetCollapsed(gemContent, gemHeader, gemCollapsed)

gemHeader:SetScript("OnClick", function()
    gemCollapsed = not gemCollapsed
    ns.SetCollapsed(gemContent, gemHeader, gemCollapsed)
    if ClassCodexCharDB and ClassCodexCharDB.collapsed then
        ClassCodexCharDB.collapsed.gems = gemCollapsed
    end
    ns:LayoutPanel()
end)

local gemRows = {}
for i = 1, MAX_GEM_ROWS do
    local row = CreateFrame("Frame", nil, gemContent)
    row:SetHeight(ROW_HEIGHT)
    CreateRowIcon(row)
    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    label:SetWidth(65)
    label:SetJustifyH("LEFT")
    label:SetTextColor(0.6, 0.6, 0.6)
    row.labelText = label
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("LEFT", label, "RIGHT", 4, 0)
    name:SetPoint("RIGHT", 0, 0)
    name:SetJustifyH("LEFT")
    row.itemText = name
    SetupItemTooltip(row)
    row:Hide()
    gemRows[i] = row
end

-------------------------------------------------------------------------------
-- Section: Consumables
-------------------------------------------------------------------------------

local consumSection = CreateFrame("Frame", nil, ns.contentFrame)
consumSection:SetHeight(SECTION_HEADER_HEIGHT)
local consumHeader = ns.CreateSectionHeader(consumSection, L["Consumables"])
local consumContent = CreateFrame("Frame", nil, consumSection)
consumContent:SetPoint("TOPLEFT", consumHeader, "BOTTOMLEFT", 0, 0)
consumContent:SetPoint("RIGHT", 0, 0)
consumContent:Show()
local consumCollapsed = false
ns.SetCollapsed(consumContent, consumHeader, consumCollapsed)

consumHeader:SetScript("OnClick", function()
    consumCollapsed = not consumCollapsed
    ns.SetCollapsed(consumContent, consumHeader, consumCollapsed)
    if ClassCodexCharDB and ClassCodexCharDB.collapsed then
        ClassCodexCharDB.collapsed.consumables = consumCollapsed
    end
    ns:UpdatePanel()
end)

local consumRows = {}
for i = 1, MAX_CONSUMABLE_ROWS do
    local row = CreateFrame("Frame", nil, consumContent)
    row:SetHeight(ROW_HEIGHT)
    CreateRowIcon(row)
    local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    label:SetWidth(90)
    label:SetJustifyH("LEFT")
    label:SetTextColor(0.6, 0.6, 0.6)
    row.labelText = label
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("LEFT", label, "RIGHT", 4, 0)
    name:SetPoint("RIGHT", 0, 0)
    name:SetJustifyH("LEFT")
    row.itemText = name
    SetupItemTooltip(row)
    row:Hide()
    consumRows[i] = row
end

-------------------------------------------------------------------------------
-- Section: Trinkets
-------------------------------------------------------------------------------

local trinketSection = CreateFrame("Frame", nil, ns.contentFrame)
trinketSection:SetHeight(SECTION_HEADER_HEIGHT)
local trinketTitle = CreateSectionTitle(trinketSection, L["Trinkets"])
local trinketContent = CreateFrame("Frame", nil, trinketSection)
trinketContent:SetPoint("TOPLEFT", trinketTitle, "BOTTOMLEFT", 0, 0)
trinketContent:SetPoint("RIGHT", 0, 0)
trinketContent:Show()
local trinketCollapsed = false

-- Context filter dropdown
local trinketCtxDropdown = ns.CreateOptionDropdown("ClassCodexTrinketCtxDropdown", trinketContent)
trinketCtxDropdown:SetPoint("TOPLEFT", 0, 0)
trinketCtxDropdown:SetPoint("TOPRIGHT", 0, 0)
trinketCtxDropdown:Hide()
local currentTrinketContext = "All"

local trinketRows = {}
for i = 1, MAX_TRINKET_ROWS do
    local row = CreateFrame("Frame", nil, trinketContent)
    row:SetHeight(ROW_HEIGHT)
    local tier = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tier:SetPoint("LEFT", 2, 0)
    tier:SetWidth(16)
    tier:SetJustifyH("CENTER")
    row.tierText = tier
    CreateRowIcon(row)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("LEFT", tier, "RIGHT", 4, 0)
    local src = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    src:SetPoint("RIGHT", -2, 0)
    src:SetWidth(90)
    src:SetJustifyH("RIGHT")
    src:SetWordWrap(false)
    src:SetTextColor(0.5, 0.5, 0.5)
    row.sourceLabel = src
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    name:SetPoint("RIGHT", src, "LEFT", -4, 0)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    row.itemText = name
    SetupItemTooltip(row)
    row:Hide()
    trinketRows[i] = row
end

local function GetTrinketContextDisplayName(rawCtx)
    if rawCtx == "All" then return "All" end
    return CONTEXT_LABELS[rawCtx] or rawCtx
end

local function SaveTrinketContext(rawCtx)
    local specKey = ns.GetSpecKey()
    if not specKey or not ClassCodexCharDB then return end
    if not ClassCodexCharDB.perSpec then ClassCodexCharDB.perSpec = {} end
    if not ClassCodexCharDB.perSpec[specKey] then
        ClassCodexCharDB.perSpec[specKey] = {}
    end
    ClassCodexCharDB.perSpec[specKey].trinketContext = rawCtx
end

-- trinketCtxDropdown options are pushed in by UpdateGearingSections
-- when it knows the current trinket list (label = display name,
-- value = raw context key). The WowStyle1Dropdown owns click + popup.

-------------------------------------------------------------------------------
-- Section: Crafts
-------------------------------------------------------------------------------

local craftSection = CreateFrame("Frame", nil, ns.contentFrame)
craftSection:SetHeight(SECTION_HEADER_HEIGHT)
local craftTitle = CreateSectionTitle(craftSection, L["Crafts"])
local craftContent = CreateFrame("Frame", nil, craftSection)
craftContent:SetPoint("TOPLEFT", craftTitle, "BOTTOMLEFT", 0, 0)
craftContent:SetPoint("RIGHT", 0, 0)
craftContent:Show()
local craftCollapsed = false

local craftRows = {}
for i = 1, MAX_CRAFT_ROWS do
    local row = CreateFrame("Frame", nil, craftContent)
    row:SetHeight(ROW_HEIGHT)
    local rank = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rank:SetPoint("LEFT", 2, 0)
    rank:SetWidth(18)
    rank:SetJustifyH("RIGHT")
    rank:SetTextColor(0.5, 0.5, 0.5)
    row.rank = rank
    CreateRowIcon(row)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("LEFT", rank, "RIGHT", 4, 0)
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    name:SetPoint("RIGHT", 0, 0)
    name:SetJustifyH("LEFT")
    row.itemText = name
    local headerLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerLabel:SetPoint("LEFT", 2, 0)
    headerLabel:SetTextColor(1, 0.82, 0)
    row.headerLabel = headerLabel
    headerLabel:Hide()
    SetupItemTooltip(row)
    row:Hide()
    craftRows[i] = row
end

-------------------------------------------------------------------------------
-- Section: BiS Gear
-------------------------------------------------------------------------------

local bisSection = CreateFrame("Frame", nil, ns.contentFrame)
bisSection:SetHeight(SECTION_HEADER_HEIGHT)
local bisTitle = CreateSectionTitle(bisSection, L["BiS Gear"])
local bisContent = CreateFrame("Frame", nil, bisSection)
bisContent:SetPoint("TOPLEFT", bisTitle, "BOTTOMLEFT", 0, 0)
bisContent:SetPoint("RIGHT", 0, 0)
bisContent:Show()
local bisCollapsed = false

-- Source selector dropdown (Wowhead / Icy Veins)
local bisSourceDropdown = ns.CreateOptionDropdown("ClassCodexBisSourceDropdown", bisContent)
bisSourceDropdown:SetPoint("TOPLEFT", 0, 0)
bisSourceDropdown:SetPoint("TOPRIGHT", 0, 0)
bisSourceDropdown:Hide()
local currentBisSource = "Wowhead"

-- Tab filter dropdown (shown when multiple tabs exist, e.g. Pre-Season / Overall)
local bisTabDropdown = ns.CreateOptionDropdown("ClassCodexBisTabDropdown", bisContent)
bisTabDropdown:SetPoint("TOPLEFT", 0, 0)
bisTabDropdown:SetPoint("TOPRIGHT", 0, 0)
bisTabDropdown:Hide()
local currentBisTab = "Overall"

-- Slot | Icon Item | Source — three columns matching Compendium's
-- layout (#102). Source is right-anchored, fixed-width, truncated;
-- the full string is exposed via the row's existing tooltip path.
local BIS_SOURCE_COL_WIDTH = 80
local bisRows = {}
for i = 1, MAX_BIS_ROWS do
    local row = CreateFrame("Frame", nil, bisContent)
    row:SetHeight(ROW_HEIGHT)
    local slot = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slot:SetPoint("LEFT", 2, 0)
    slot:SetWidth(55)
    slot:SetJustifyH("LEFT")
    slot:SetTextColor(0.6, 0.6, 0.6)
    row.slotText = slot
    CreateRowIcon(row)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("LEFT", slot, "RIGHT", 2, 0)
    local source = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    source:SetPoint("RIGHT", -2, 0)
    source:SetWidth(BIS_SOURCE_COL_WIDTH)
    source:SetJustifyH("RIGHT")
    source:SetWordWrap(false)
    source:SetTextColor(0.5, 0.5, 0.5)
    row.sourceLabel = source
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    name:SetPoint("RIGHT", source, "LEFT", -4, 0)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    row.itemText = name
    SetupItemTooltip(row)
    row:Hide()
    bisRows[i] = row
end

-- BiS-side PvP fallback FontString — kept on the pvpDock table so it
-- doesn't add another upvalue to UpdateGearingSections.
pvpDock.bisFallback = bisContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
pvpDock.bisFallback:SetTextColor(0.5, 0.5, 0.5)
pvpDock.bisFallback:Hide()

-- Brand-icon labels live in PvPData.lua so the Compendium and the dock
-- share one definition (ns.BIS_SOURCE_LABELS / ns.ENH_SOURCE_LABELS).

local function SaveBisPrefs(source, tabLabel)
    local specKey = ns.GetSpecKey()
    if not specKey or not ClassCodexCharDB then return end
    if not ClassCodexCharDB.perSpec then ClassCodexCharDB.perSpec = {} end
    if not ClassCodexCharDB.perSpec[specKey] then
        ClassCodexCharDB.perSpec[specKey] = {}
    end
    if source then ClassCodexCharDB.perSpec[specKey].bisSource = source end
    if tabLabel then ClassCodexCharDB.perSpec[specKey].bisTab = tabLabel end
end

-- Resolve the active BiS gear tabs for the current source
local function GetActiveBisGear()
    if currentBisSource == "Icy Veins" then
        local classToken = select(2, UnitClass("player"))
        local specKey = ns.GetSpecKey()
        if not classToken or not specKey then return nil end
        -- strip class prefix from spec key (e.g. "MAGE-frost" → "frost")
        local spec = specKey:match("-(.+)") or specKey
        local ivSpec = ns:GetIcyVeinsSpecData(classToken, spec)
        return ivSpec and ivSpec.bisGear
    elseif currentBisSource == "PvP" then
        return PvP.bis()
    else
        local gearData = GetSpecGearData()
        return gearData and gearData.bisGear
    end
end

-- BiS source + tab dropdown options are pushed in by UpdateGearing-
-- Sections (it knows the active BiS gear list and the current source);
-- the WowStyle1Dropdown template owns click + popup itself.

-------------------------------------------------------------------------------
-- Update
-------------------------------------------------------------------------------

local lastEnchantCount = 0
local lastEnchantHeight = 0
local lastGemCount = 0
local lastConsumCount = 0
local lastTrinketCount = 0
local lastCraftCount = 0
local lastBisCount = 0

function ns:UpdateGearingSections()
    -- Restore persisted collapse state for enchants/gems
    local saved = ClassCodexCharDB and ClassCodexCharDB.collapsed
    if saved then
        enchantCollapsed = saved.enchants or false
        gemCollapsed = saved.gems or false
        consumCollapsed = saved.consumables or false
        ns.SetCollapsed(enchantContent, enchantHeader, enchantCollapsed)
        ns.SetCollapsed(gemContent, gemHeader, gemCollapsed)
        ns.SetCollapsed(consumContent, consumHeader, consumCollapsed)
    end

    local gearData = GetSpecGearData()
    RequestAllItems(gearData)
    -- Also request IV items so they're ready when user switches source
    local playerClass = select(2, UnitClass("player"))
    local playerSpecKey = ns.GetSpecKey()
    local playerSpec = playerSpecKey and (playerSpecKey:match("-(.+)") or playerSpecKey)
    local ivSpecData = playerClass and playerSpec and ns:GetIcyVeinsSpecData(playerClass, playerSpec)
    if ivSpecData and ivSpecData.bisGear then
        for _, tab in ipairs(ivSpecData.bisGear) do
            for _, g in ipairs(tab.slots) do RequestItemData(g.item.itemId) end
        end
    end

    -- Enhancements (enchants + gems) source resolution.
    -- Reset on spec change so a "PvP" choice on a previous spec doesn't
    -- bleed into the next one — matches the Compendium Enhancements tab
    -- (Compendium.lua:lastEnhancementsSpecKey).
    local dockEnhancementsSpecKey = ns.GetSpecKey() or ""
    if dockEnhancementsSpecKey ~= pvpDock.lastSpecKey then
        pvpDock.currentSource = "Wowhead"
        pvpDock.lastSpecKey = dockEnhancementsSpecKey
    end
    -- Wowhead falls back to PvP when missing; PvP stays sticky so the
    -- fallback line below tells the user the source choice was honoured.
    local pvpEnchants = PvP.enchants()
    local pvpGems = PvP.gems()
    local hasPvPEnh = pvpEnchants ~= nil or pvpGems ~= nil
    local hasWowheadEnh = gearData and (gearData.enchants or gearData.gems)
    if pvpDock.currentSource == "Wowhead" and not hasWowheadEnh then
        pvpDock.currentSource = "PvP"
    end

    -- Source dropdown — only show if Wowhead has data; otherwise the
    -- PvP option is the only sensible state and a 1-option dropdown is
    -- noise. Falls back to plain "Wowhead"/"PvP" labels if the brand-icon
    -- table from PvPData.lua isn't available yet (defensive — ns is
    -- shared but order-of-init issues have surprised us before).
    local showEnhDropdown = hasWowheadEnh
    if showEnhDropdown then
        local labels = ns.ENH_SOURCE_LABELS or {}
        pvpDock.sourceDropdown:Show()
        pvpDock.sourceDropdown:SetOptions(
            {
                { label = labels["Wowhead"] or "Wowhead", value = "Wowhead" },
                { label = labels["PvP"]     or "PvP",     value = "PvP" },
            },
            pvpDock.currentSource,
            function(picked)
                pvpDock.currentSource = picked
                ns:UpdateGearingSections()
                ns:LayoutPanel()
            end
        )
    else
        pvpDock.sourceDropdown:Hide()
    end

    local enhPvpNoData = pvpDock.currentSource == "PvP" and not hasPvPEnh
    local activeEnchants, activeGems
    if pvpDock.currentSource == "PvP" then
        activeEnchants = pvpEnchants
        activeGems = pvpGems
    else
        activeEnchants = gearData and gearData.enchants
        activeGems = gearData and gearData.gems
    end

    -- Enchants
    for i = 1, MAX_ENCHANT_ROWS do enchantRows[i]:Hide() end
    pvpDock.fallback:Hide()
    lastEnchantCount = 0
    lastEnchantHeight = 0
    local enchBaseY = showEnhDropdown and -30 or 0
    if enhPvpNoData then
        pvpDock.fallback:SetText(L["No PvP enchant/gem data for this spec yet."]
            or "No PvP enchant/gem data for this spec yet.")
        pvpDock.fallback:ClearAllPoints()
        pvpDock.fallback:SetPoint("TOPLEFT", 4, enchBaseY - 4)
        pvpDock.fallback:Show()
        lastEnchantHeight = math.abs(enchBaseY) + 20
        enchantSection:Show()
    elseif activeEnchants and #activeEnchants > 0 then
        local count = math.min(#activeEnchants, MAX_ENCHANT_ROWS)
        local yOff = enchBaseY
        for i = 1, count do
            local e = activeEnchants[i]
            local row = enchantRows[i]
            row.slotText:SetText(e.slot)

            -- Row icon shows best enchant
            SetRowIcon(row, e.best.itemId, e.best.spellId)

            -- Best item (strip "Enchant Weapon - " etc. prefix)
            row.bestSub.text:SetText(FormatItem(e.best, StripEnchantPrefix(GetItemName(e.best))))
            row.bestSub.itemId = e.best.itemId
            row.bestSub.spellId = e.best.spellId
            row.bestSub:Show()

            -- Alternate item (second line)
            local rowH = ROW_HEIGHT
            if e.alternate then
                row.altSub.text:SetText(FormatItem(e.alternate, StripEnchantPrefix(GetItemName(e.alternate))))
                row.altSub.itemId = e.alternate.itemId
                row.altSub.spellId = e.alternate.spellId
                row.altSub:Show()
                rowH = ROW_HEIGHT * 2
            else
                row.altSub:Hide()
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, yOff)
            row:SetPoint("RIGHT", 0, 0)
            row:SetHeight(rowH)
            yOff = yOff - rowH
            row:Show()
        end
        lastEnchantCount = count
        lastEnchantHeight = math.abs(yOff)
        enchantSection:Show()
    else
        enchantSection:Hide()
    end

    -- Gems
    for i = 1, MAX_GEM_ROWS do gemRows[i]:Hide() end
    lastGemCount = 0
    if not enhPvpNoData and activeGems then
        local idx = 0
        if activeGems.primary then
            idx = idx + 1
            local row = gemRows[idx]
            row.labelText:SetText(L["Primary"])
            row.itemText:SetText(FormatItem(activeGems.primary))
            row.itemId = activeGems.primary.itemId
            row.altItemId = nil
            row.embItemId = nil
            SetRowIcon(row, activeGems.primary.itemId)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, 0)
            row:SetPoint("RIGHT", 0, 0)
            row:Show()
        end
        if activeGems.secondary then
            for _, gem in ipairs(activeGems.secondary) do
                idx = idx + 1
                if idx > MAX_GEM_ROWS then break end
                local row = gemRows[idx]
                row.labelText:SetText(L["Secondary"])
                row.itemText:SetText(FormatItem(gem))
                row.itemId = gem.itemId
                row.altItemId = nil
                row.embItemId = nil
                SetRowIcon(row, gem.itemId)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_HEIGHT)
                row:SetPoint("RIGHT", 0, 0)
                row:Show()
            end
        end
        lastGemCount = idx
        if idx > 0 then gemSection:Show() else gemSection:Hide() end
    else
        gemSection:Hide()
    end

    -- Consumables
    for i = 1, MAX_CONSUMABLE_ROWS do consumRows[i]:Hide() end
    lastConsumCount = 0
    if gearData and gearData.consumables then
        local idx = 0
        for _, key in ipairs(CONSUMABLE_ORDER) do
            local item = gearData.consumables[key]
            if item then
                idx = idx + 1
                if idx > MAX_CONSUMABLE_ROWS then break end
                local row = consumRows[idx]
                row.labelText:SetText(CONSUMABLE_LABELS[key] or key)
                row.itemText:SetText(FormatItem(item))
                row.itemId = item.itemId
                row.altItemId = nil
                row.embItemId = nil
                SetRowIcon(row, item.itemId)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_HEIGHT)
                row:SetPoint("RIGHT", 0, 0)
                row:Show()
            end
        end
        lastConsumCount = idx
        if idx > 0 then consumSection:Show() else consumSection:Hide() end
    else
        consumSection:Hide()
    end

    -- Trinkets
    for i = 1, MAX_TRINKET_ROWS do trinketRows[i]:Hide() end
    lastTrinketCount = 0
    if gearData and gearData.trinkets and #gearData.trinkets > 0 then
        -- Restore trinket context from saved state
        local specKey = ns.GetSpecKey()
        if specKey and ClassCodexCharDB and ClassCodexCharDB.perSpec
            and ClassCodexCharDB.perSpec[specKey] and ClassCodexCharDB.perSpec[specKey].trinketContext then
            currentTrinketContext = ClassCodexCharDB.perSpec[specKey].trinketContext
        end

        -- Collect available contexts
        local contexts = {}
        local seen = {}
        for _, t in ipairs(gearData.trinkets) do
            for _, ctx in ipairs(t.contexts) do
                if not seen[ctx] then
                    seen[ctx] = true
                    contexts[#contexts + 1] = ctx
                end
            end
        end
        local showCtxDropdown = #contexts > 1
        if showCtxDropdown then
            local opts = { { label = "All", value = "All" } }
            for _, ctx in ipairs(contexts) do
                opts[#opts + 1] = { label = CONTEXT_LABELS[ctx] or ctx, value = ctx }
            end
            trinketCtxDropdown:Show()
            trinketCtxDropdown:SetOptions(opts, currentTrinketContext, function(picked)
                currentTrinketContext = picked
                SaveTrinketContext(currentTrinketContext)
                ns:UpdateGearingSections()
                ns:LayoutPanel()
            end)
        else
            trinketCtxDropdown:Hide()
        end

        -- Filter trinkets by context (currentTrinketContext is a raw key)
        local filtered = {}
        local contextKey = currentTrinketContext ~= "All" and currentTrinketContext or nil
        for _, t in ipairs(gearData.trinkets) do
            if not contextKey then
                filtered[#filtered + 1] = t
            else
                for _, ctx in ipairs(t.contexts) do
                    if ctx == contextKey then
                        filtered[#filtered + 1] = t
                        break
                    end
                end
            end
        end

        -- Sort by tier
        table.sort(filtered, function(a, b)
            return (TIER_ORDER[a.tier] or 99) < (TIER_ORDER[b.tier] or 99)
        end)

        local yOffset = showCtxDropdown and -30 or 0
        local count = math.min(#filtered, MAX_TRINKET_ROWS)
        for i = 1, count do
            local t = filtered[i]
            local row = trinketRows[i]
            local color = TIER_COLORS[t.tier]
            row.tierText:SetText(t.tier)
            if color then
                row.tierText:SetTextColor(color.r, color.g, color.b)
            else
                row.tierText:SetTextColor(1, 1, 1)
            end
            row.itemText:SetText(FormatItem({ itemId = t.itemId, name = "" }))
            row.itemId = t.itemId
            row.bonusIDs = t.bonusIDs
            row.altItemId = nil
            row.embItemId = nil
            row.sourceText = t.source or nil
            row.sourceLabel:SetText(t.source or "")
            SetRowIcon(row, t.itemId)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, yOffset - (i - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", 0, 0)
            row:Show()
        end
        lastTrinketCount = count
        trinketSection:Show()
    else
        trinketCtxDropdown:Hide()
        trinketSection:Hide()
    end

    -- Crafts
    for i = 1, MAX_CRAFT_ROWS do craftRows[i]:Hide() end
    lastCraftCount = 0
    if gearData and gearData.crafts then
        local idx = 0
        local hasEarly = gearData.crafts.earlyCrafts and #gearData.crafts.earlyCrafts > 0
        local hasBis = gearData.crafts.bisCrafts and #gearData.crafts.bisCrafts > 0

        if hasEarly then
            idx = idx + 1
            local row = craftRows[idx]
            row.rank:Hide()
            row.itemText:Hide()
            row.icon:Hide()
            row.headerLabel:SetText(L["Early Crafts"])
            row.headerLabel:Show()
            row.itemId = nil
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", 0, 0)
            row:Show()
            for _, step in ipairs(gearData.crafts.earlyCrafts) do
                idx = idx + 1
                if idx > MAX_CRAFT_ROWS then break end
                row = craftRows[idx]
                row.headerLabel:Hide()
                row.rank:Hide()
                row.itemText:Show()
                local text = FormatItem(step.item)
                if step.embellishment then
                    text = text .. " + " .. FormatItem(step.embellishment)
                end
                row.itemText:SetText(text)
                row.itemId = step.item.itemId
                row.bonusIDs = step.item.bonusIDs
                row.altItemId = nil
                row.embItemId = step.embellishment and step.embellishment.itemId or nil
                row.embName = step.embellishment and step.embellishment.name or nil
                SetRowIcon(row, step.item.itemId)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_HEIGHT)
                row:SetPoint("RIGHT", 0, 0)
                row:Show()
            end
        end

        if hasBis and idx < MAX_CRAFT_ROWS then
            idx = idx + 1
            local row = craftRows[idx]
            row.rank:Hide()
            row.itemText:Hide()
            row.icon:Hide()
            row.headerLabel:SetText(L["BiS Crafts"])
            row.headerLabel:Show()
            row.itemId = nil
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", 0, 0)
            row:Show()
            for _, step in ipairs(gearData.crafts.bisCrafts) do
                idx = idx + 1
                if idx > MAX_CRAFT_ROWS then break end
                row = craftRows[idx]
                row.headerLabel:Hide()
                row.rank:Hide()
                row.itemText:Show()
                local text = FormatItem(step.item)
                if step.embellishment then
                    text = text .. " + " .. FormatItem(step.embellishment)
                end
                row.itemText:SetText(text)
                row.itemId = step.item.itemId
                row.bonusIDs = step.item.bonusIDs
                row.altItemId = nil
                row.embItemId = step.embellishment and step.embellishment.itemId or nil
                row.embName = step.embellishment and step.embellishment.name or nil
                SetRowIcon(row, step.item.itemId)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_HEIGHT)
                row:SetPoint("RIGHT", 0, 0)
                row:Show()
            end
        end

        lastCraftCount = idx
        if idx > 0 then craftSection:Show() else craftSection:Hide() end
    else
        craftSection:Hide()
    end

    -- BiS Gear
    for i = 1, MAX_BIS_ROWS do bisRows[i]:Hide() end
    pvpDock.bisFallback:Hide()
    lastBisCount = 0

    local wowheadBis = gearData and gearData.bisGear
    local classToken = select(2, UnitClass("player"))
    local specKey = ns.GetSpecKey()
    local spec = specKey and (specKey:match("-(.+)") or specKey)
    local ivSpecData = classToken and spec and ns:GetIcyVeinsSpecData(classToken, spec)
    local ivBis = ivSpecData and ivSpecData.bisGear
    local pvpBis = PvP.bis()
    local hasWH = wowheadBis and #wowheadBis > 0
    local hasIV = ivBis and #ivBis > 0
    local hasPvP = pvpBis ~= nil

    if hasWH or hasIV or hasPvP then
        -- Restore persisted source preference
        currentBisSource = "Wowhead"
        if specKey and ClassCodexCharDB and ClassCodexCharDB.perSpec
            and ClassCodexCharDB.perSpec[specKey] and ClassCodexCharDB.perSpec[specKey].bisSource then
            currentBisSource = ClassCodexCharDB.perSpec[specKey].bisSource
        end
        -- Wowhead/Icy Veins fall back to each other when missing, but
        -- PvP stays sticky — if PvP is selected on a spec without
        -- Murlok data, the pvpDock.bisFallback line below tells the user
        -- the source choice was honoured.
        if currentBisSource == "Icy Veins" and not hasIV then currentBisSource = "Wowhead" end
        if currentBisSource == "Wowhead" and not hasWH then currentBisSource = hasIV and "Icy Veins" or "PvP" end

        -- Source dropdown — PvP always appears for discoverability when
        -- multiple sources are even theoretically available. Options
        -- carry the brand-icon labels for visible source attribution.
        local labels = ns.BIS_SOURCE_LABELS or {}
        local availableSources = {}
        if hasWH then availableSources[#availableSources + 1] = { label = labels["Wowhead"] or "Wowhead", value = "Wowhead" } end
        if hasIV then availableSources[#availableSources + 1] = { label = labels["Icy Veins"] or "Icy Veins", value = "Icy Veins" } end
        availableSources[#availableSources + 1] = { label = labels["PvP"] or "PvP", value = "PvP" }
        if #availableSources > 1 then
            bisSourceDropdown:Show()
            bisSourceDropdown:SetOptions(availableSources, currentBisSource, function(picked)
                currentBisSource = picked
                currentBisTab = "Overall" -- reset tab on source change
                SaveBisPrefs(currentBisSource, currentBisTab)
                ns:UpdateGearingSections()
                ns:LayoutPanel()
            end)
        else
            bisSourceDropdown:Hide()
        end

        -- PvP-no-data: render the fallback line and skip the row loop.
        if currentBisSource == "PvP" and not hasPvP then
            bisTabDropdown:Hide()
            local yOffset = bisSourceDropdown:IsShown() and -30 or 0
            pvpDock.bisFallback:SetText(L["No PvP gear data for this spec yet."]
                or "No PvP gear data for this spec yet.")
            pvpDock.bisFallback:ClearAllPoints()
            pvpDock.bisFallback:SetPoint("TOPLEFT", 4, yOffset - 4)
            pvpDock.bisFallback:Show()
            bisSection:Show()
        else
            -- Determine active bis gear from selected source. Guard
            -- everything from here to row-render against malformed /
            -- empty data — a single Lua error here would abort the
            -- function before trinkets / per-mode visibility runs,
            -- leaving the whole tab strip half-rendered.
            local activeBis
            if currentBisSource == "PvP" then activeBis = pvpBis
            elseif currentBisSource == "Icy Veins" then activeBis = ivBis
            else activeBis = wowheadBis end
            if not activeBis or #activeBis == 0 then
                activeBis = wowheadBis or ivBis or pvpBis
            end

            if not activeBis or not activeBis[1] then
                -- No populated tab anywhere — bail with section hidden
                -- rather than nil-dereffing activeBis[1].label below.
                bisTabDropdown:Hide()
                bisSection:Hide()
            else
                -- Default to first available tab if current selection is invalid
                local tabValid = false
                for _, tab in ipairs(activeBis) do
                    if tab.label == currentBisTab then tabValid = true; break end
                end
                if not tabValid then currentBisTab = activeBis[1].label end

                -- Show tab dropdown when multiple tabs exist
                local showTabDropdown = #activeBis > 1
                if showTabDropdown then
                    local labels = {}
                    for _, tab in ipairs(activeBis) do labels[#labels + 1] = tab.label end
                    bisTabDropdown:Show()
                    bisTabDropdown:SetOptions(labels, currentBisTab, function(picked)
                        currentBisTab = picked
                        SaveBisPrefs(nil, currentBisTab)
                        ns:UpdateGearingSections()
                        ns:LayoutPanel()
                    end)
                else
                    bisTabDropdown:Hide()
                end

                -- Find the selected tab's slots
                local selectedSlots
                for _, tab in ipairs(activeBis) do
                    if tab.label == currentBisTab then
                        selectedSlots = tab.slots
                        break
                    end
                end

                local yOffset = 0
                if bisSourceDropdown:IsShown() then yOffset = yOffset - 30 end
                if showTabDropdown then
                    bisTabDropdown:ClearAllPoints()
                    bisTabDropdown:SetPoint("TOPLEFT", 0, yOffset)
                    bisTabDropdown:SetPoint("TOPRIGHT", 0, yOffset)
                    yOffset = yOffset - 30
                end

                local count = selectedSlots and math.min(#selectedSlots, MAX_BIS_ROWS) or 0
                for i = 1, count do
                    local entry = selectedSlots[i]
                    local row = bisRows[i]
                    row.slotText:SetText(entry.slot)
                    row.itemText:SetText(FormatItem(entry.item))
                    row.sourceLabel:SetText(entry.source or "")

                    row.itemId = entry.item.itemId
                    row.bonusIDs = entry.item.bonusIDs
                    row.altItemId = nil
                    row.embItemId = nil
                    row.sourceText = entry.source or nil
                    SetRowIcon(row, entry.item.itemId)
                    row:ClearAllPoints()
                    row:SetPoint("TOPLEFT", 0, yOffset - (i - 1) * ROW_HEIGHT)
                    row:SetPoint("RIGHT", 0, 0)
                    row:Show()
                end
                lastBisCount = count
                bisSection:Show()
            end
        end
    else
        bisSourceDropdown:Hide()
        bisTabDropdown:Hide()
        bisSection:Hide()
    end

    -- Tab visibility: each gearing section shows on its tab
    local tab = ns.getActiveTab()
    if tab ~= "enhancements" then
        enchantSection:Hide()
        gemSection:Hide()
        consumSection:Hide()
    end
    if tab ~= "crafts" then
        craftSection:Hide()
    end
    if tab ~= "trinkets" then
        trinketSection:Hide()
    end
    if tab ~= "bis" then
        bisSection:Hide()
    end
    if tab ~= "enhancements" and tab ~= "crafts" and tab ~= "trinkets" and tab ~= "bis" then return end

    -- Section visibility per mode
    if ClassCodexDB then
        local prefix = ns.isFloating() and "floatShow" or "dockShow"
        if not ClassCodexDB[prefix .. "Enchants"] then enchantSection:Hide() end
        if not ClassCodexDB[prefix .. "Gems"] then gemSection:Hide() end
        if not ClassCodexDB[prefix .. "Consumables"] then consumSection:Hide() end
        if not ClassCodexDB[prefix .. "Trinkets"] then trinketSection:Hide() end
        if not ClassCodexDB[prefix .. "Crafts"] then craftSection:Hide() end
        if not ClassCodexDB[prefix .. "BisGear"] then bisSection:Hide() end
    end
end

-------------------------------------------------------------------------------
-- Layout
-------------------------------------------------------------------------------

function ns:LayoutGearingSections(y)
    local function LayoutSection(section, collapsed, contentHeight, headerH)
        if not section:IsShown() then return y end
        local hdrH = headerH or SECTION_HEADER_HEIGHT
        section:ClearAllPoints()
        section:SetPoint("TOPLEFT", ns.contentFrame, "TOPLEFT", ns.CONTENT_INSET, y)
        section:SetPoint("RIGHT", ns.contentFrame, "RIGHT", -ns.CONTENT_INSET, 0)
        local sectionHeight = hdrH
        if not collapsed then
            sectionHeight = sectionHeight + contentHeight + 4
        end
        section:SetHeight(sectionHeight)
        y = y - sectionHeight - 3
        return y
    end

    y = LayoutSection(enchantSection, enchantCollapsed, lastEnchantHeight)
    y = LayoutSection(gemSection, gemCollapsed, lastGemCount * ROW_HEIGHT)
    y = LayoutSection(consumSection, consumCollapsed, lastConsumCount * ROW_HEIGHT)

    -- (lastEnchantHeight already includes the source-dropdown offset and
    -- the fallback line when shown — see UpdateGearingSections.)

    local trinketContentHeight = lastTrinketCount * ROW_HEIGHT
    if trinketCtxDropdown:IsShown() then
        trinketContentHeight = trinketContentHeight + 30
    end
    y = LayoutSection(trinketSection, trinketCollapsed, trinketContentHeight)

    y = LayoutSection(craftSection, craftCollapsed, lastCraftCount * ROW_HEIGHT)

    local bisContentHeight = lastBisCount * ROW_HEIGHT
    if bisSourceDropdown:IsShown() then
        bisContentHeight = bisContentHeight + 30
    end
    if bisTabDropdown:IsShown() then
        bisContentHeight = bisContentHeight + 30
    end
    if pvpDock.bisFallback:IsShown() then
        bisContentHeight = bisContentHeight + 20
    end
    y = LayoutSection(bisSection, bisCollapsed, bisContentHeight)

    return y
end

-------------------------------------------------------------------------------
-- Section Visibility Options (for pin right-click menu)
-------------------------------------------------------------------------------

ns.gearingFloatOptions = {
    { key = "floatShowEnchants", label = L["Enchants"] },
    { key = "floatShowGems", label = L["Gems"] },
    { key = "floatShowConsumables", label = L["Consumables"] },
    { key = "floatShowTrinkets", label = L["Trinkets"] },
    { key = "floatShowCrafts", label = L["Crafts"] },
    { key = "floatShowBisGear", label = L["BiS Gear"] },
}

ns.gearingDockOptions = {
    { key = "dockShowEnchants", label = L["Enchants"] },
    { key = "dockShowGems", label = L["Gems"] },
    { key = "dockShowConsumables", label = L["Consumables"] },
    { key = "dockShowTrinkets", label = L["Trinkets"] },
    { key = "dockShowCrafts", label = L["Crafts"] },
    { key = "dockShowBisGear", label = L["BiS Gear"] },
}
