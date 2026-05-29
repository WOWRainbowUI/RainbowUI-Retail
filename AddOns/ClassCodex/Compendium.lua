local addonName, ns = ...

local DATA = ClassCodexData
local GEAR_DATA = ClassCodexGearData
if not DATA then
    -- Ensure OpenCompendium exists even if data failed to load
    function ns:OpenCompendium()
        print("|cff00ccffClass Codex:|r " .. ns.L["chat.compendium_data_not_loaded"])
    end
    return
end

local L = ns.L

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local FRAME_WIDTH = 540
local FRAME_HEIGHT = 480
local INSET_PAD = 8
local ROW_HEIGHT = 22
local SECTION_HEADER_HEIGHT = 24
local MAX_STATS = 10
-- Initial pool sizes for the Talents section. Pools grow on demand
-- (EnsureTalentButton / EnsureTalentHeroHeader); these are just the
-- pre-allocations so the common Wowhead-only render hits no cold path.
-- Archon adds ~27 contexts × 2 hero talents per spec, so the dynamic
-- growth path is what makes the Talents tab cover all sources without
-- truncation.
local MAX_TALENT_BUTTONS = 16
local MAX_TALENT_HERO_HEADERS = 6
local TALENT_HERO_HEADER_HEIGHT = 22
local MAX_ROTATION_STEPS = 20
local MAX_ENCHANT_ROWS = 12 -- one row per entry, but row grows to 2x height when an alternate exists
local MAX_GEM_ROWS = 10
local MAX_CONSUM_ROWS = 10
local MAX_TRINKET_ROWS = 20
local MAX_CRAFT_ROWS = 15 -- combined "item + embellishment" row; embellishment surfaced via tooltip line
local MAX_BIS_ROWS = 20
local TALENT_BTN_HEIGHT = 22
local TALENT_BTN_GAP = 4

local RANK_COLORS = {
    { r = 0.64, g = 0.21, b = 0.93 },
    { r = 0.00, g = 0.44, b = 0.87 },
    { r = 0.12, g = 1.00, b = 0.00 },
    { r = 1.00, g = 1.00, b = 1.00 },
    { r = 0.62, g = 0.62, b = 0.62 },
}

local TIER_COLORS = {
    S = { r = 1.00, g = 0.50, b = 0.00 },
    A = { r = 0.64, g = 0.21, b = 0.93 },
    B = { r = 0.00, g = 0.44, b = 0.87 },
    C = { r = 0.12, g = 1.00, b = 0.00 },
    D = { r = 0.62, g = 0.62, b = 0.62 },
}

local TIER_ORDER = { S = 1, A = 2, B = 3, C = 4, D = 5 }

local CONTEXT_LABELS = {
    raid = L["context.raid"],
    dungeon = L["context.dungeon"],
    delves = L["context.delves"],
    crafting = L["context.crafting"],
}

local CONSUMABLE_ORDER = { "flask", "combatPotion", "food", "weaponBuff", "augmentRune" }
local CONSUMABLE_LABELS = {
    flask = L["consumable.flask"],
    combatPotion = L["consumable.combat_potion"],
    food = L["consumable.food"],
    weaponBuff = L["consumable.weapon_buff"],
    augmentRune = L["consumable.augment_rune"],
}

local SPEC_KEYS = {
    DEATHKNIGHT  = { "blood", "frost", "unholy" },
    DEMONHUNTER  = { "havoc", "vengeance", "devourer" },
    DRUID        = { "balance", "feral", "guardian", "restoration" },
    EVOKER       = { "devastation", "preservation", "augmentation" },
    HUNTER       = { "beast-mastery", "marksmanship", "survival" },
    MAGE         = { "arcane", "fire", "frost" },
    MONK         = { "brewmaster", "mistweaver", "windwalker" },
    PALADIN      = { "holy", "protection", "retribution" },
    PRIEST       = { "discipline", "holy", "shadow" },
    ROGUE        = { "assassination", "outlaw", "subtlety" },
    SHAMAN       = { "elemental", "enhancement", "restoration" },
    WARLOCK      = { "affliction", "demonology", "destruction" },
    WARRIOR      = { "arms", "fury", "protection" },
}

local CLASS_ORDER = {
    "DEATHKNIGHT", "DEMONHUNTER", "DRUID", "EVOKER", "HUNTER", "MAGE",
    "MONK", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
}

local CLASS_ID_MAP = {
    WARRIOR = 1, PALADIN = 2, HUNTER = 3, ROGUE = 4, PRIEST = 5,
    DEATHKNIGHT = 6, SHAMAN = 7, MAGE = 8, WARLOCK = 9, MONK = 10,
    DRUID = 11, DEMONHUNTER = 12, EVOKER = 13,
}

-------------------------------------------------------------------------------
-- State
-------------------------------------------------------------------------------

local selectedClass = nil
local selectedSpec = nil
local selectedHero = nil
local activeTab = "guide"
local currentStatContext = nil
local currentRotContext = nil
local currentEnhancementsSource = "Wowhead" -- "Wowhead" | "PvP"
local lastEnhancementsSpecKey = nil
local lastTalentSpecKey = nil
local currentTrinketContext = "All"
local currentBisTab = nil
local currentBisSource = "Wowhead"
local lastBisSpecKey = nil
local initialized = false
local SaveCompendiumState -- forward declaration

-------------------------------------------------------------------------------
-- UI table (single upvalue to stay under Lua's 60-upvalue limit)
-------------------------------------------------------------------------------

local UI = {}

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

local function GetClassDisplayName(classToken)
    local info = C_CreatureInfo and C_CreatureInfo.GetClassInfo(CLASS_ID_MAP[classToken])
    return info and info.className or classToken:sub(1, 1) .. classToken:sub(2):lower()
end

local function GetSpecDisplayName(classToken, specKey)
    local classID = CLASS_ID_MAP[classToken]
    if not classID or not GetSpecializationInfoForClassID then return specKey end
    local keys = SPEC_KEYS[classToken]
    if keys then
        for i, key in ipairs(keys) do
            if key == specKey then
                local _, name = GetSpecializationInfoForClassID(classID, i)
                if name then return name end
                break
            end
        end
    end
    return specKey:gsub("^%l", string.upper):gsub("%-(%l)", function(c) return " " .. c:upper() end)
end

local function GetSpecIconTexture(classToken, specKey)
    local classID = CLASS_ID_MAP[classToken]
    if not classID or not GetSpecializationInfoForClassID then return nil end
    local keys = SPEC_KEYS[classToken]
    if keys then
        for i, key in ipairs(keys) do
            if key == specKey then
                local _, _, _, icon = GetSpecializationInfoForClassID(classID, i)
                return icon
            end
        end
    end
    return nil
end

local function HeroMatches(entryHero, heroTalent)
    if entryHero == heroTalent then return true end
    if heroTalent and entryHero:sub(1, #heroTalent) == heroTalent
        and entryHero:sub(#heroTalent + 1, #heroTalent + 1) == " " then
        return true
    end
    if entryHero and heroTalent:sub(1, #entryHero) == entryHero
        and heroTalent:sub(#entryHero + 1, #entryHero + 1) == " " then
        return true
    end
    return false
end

local function GetHeroTalentOptions(specData)
    local seen, options = {}, {}
    if specData.priorities then
        for _, p in ipairs(specData.priorities) do
            local name = p.heroTalent
            if name and name ~= "All" and not seen[name] then
                seen[name] = true
                options[#options + 1] = name
            end
        end
    end
    return options
end

local function FindMatch(entries, heroTalent, context)
    if not entries then return nil end
    for _, e in ipairs(entries) do
        if e.heroTalent == heroTalent and e.context == context then return e end
    end
    for _, e in ipairs(entries) do if e.heroTalent == heroTalent then return e end end
    for _, e in ipairs(entries) do
        if HeroMatches(e.heroTalent, heroTalent) and e.context == context then return e end
    end
    for _, e in ipairs(entries) do if HeroMatches(e.heroTalent, heroTalent) then return e end end
    for _, e in ipairs(entries) do
        if e.heroTalent == "All" and e.context == context then return e end
    end
    for _, e in ipairs(entries) do if e.heroTalent == "All" then return e end end
    return entries[1]
end

local function GetAllTalentBuildsForHero(specData, heroTalent)
    if not specData.talents then return {} end
    local builds = {}
    for _, t in ipairs(specData.talents) do
        if t.heroTalent == heroTalent or t.heroTalent == "All" or HeroMatches(t.heroTalent, heroTalent) then
            builds[#builds + 1] = t
        end
    end
    return builds
end

local function FindRotationByContext(rotations, heroTalent, rotContext)
    if not rotations then return nil end
    for _, r in ipairs(rotations) do
        if r.heroTalent == heroTalent and r.context == rotContext then return r end
    end
    for _, r in ipairs(rotations) do
        if HeroMatches(r.heroTalent, heroTalent) and r.context == rotContext then return r end
    end
    for _, r in ipairs(rotations) do
        if r.heroTalent == "All" and r.context == rotContext then return r end
    end
    for _, r in ipairs(rotations) do if r.context == rotContext then return r end end
    return nil
end

local function GetRotationContextOptions(specData, heroTalent)
    if not specData.rotation then return {} end
    local seen, options = {}, {}
    for _, r in ipairs(specData.rotation) do
        if r.heroTalent == heroTalent or r.heroTalent == "All" or HeroMatches(r.heroTalent, heroTalent) then
            if r.context and not seen[r.context] then
                seen[r.context] = true
                options[#options + 1] = r.context
            end
        end
    end
    if #options == 0 then
        for _, r in ipairs(specData.rotation) do
            if r.context and not seen[r.context] then
                seen[r.context] = true
                options[#options + 1] = r.context
            end
        end
    end
    return options
end

local function GetStatContextOptions(specData, heroTalent)
    if not specData.priorities then return {} end
    local seen, options = {}, {}
    local statsPerContext = {}
    for _, p in ipairs(specData.priorities) do
        if p.heroTalent == heroTalent or p.heroTalent == "All" or HeroMatches(p.heroTalent, heroTalent) then
            if not seen[p.context] then
                seen[p.context] = true
                options[#options + 1] = p.context
                local key = ""
                for _, tier in ipairs(p.stats) do
                    key = key .. table.concat(tier, "=") .. ">"
                end
                statsPerContext[p.context] = key
            end
        end
    end
    if #options <= 1 then return {} end
    local firstStats = statsPerContext[options[1]]
    for i = 2, #options do
        if statsPerContext[options[i]] ~= firstStats then
            return options
        end
    end
    return {}
end

local function FormatRotationStep(stepText)
    return stepText:gsub("{(%d+)}", function(id)
        local spellId = tonumber(id)
        local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellId)
        if info and info.name then return info.name end
        return "Unknown Spell"
    end)
end

local function StripConditionPrefix(stepText)
    stepText = stepText:gsub("^%?!?{%d+}:%s*", "")
    stepText = stepText:gsub("^%?%b():%s*", "")
    return stepText
end

local function GetStepSpellIcon(stepText)
    local stripped = StripConditionPrefix(stepText)
    local spellId = stripped:match("{(%d+)}")
    if spellId then
        local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(tonumber(spellId))
        if info and info.iconID then return info.iconID end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Section header + collapse helpers come from ClassCodex.lua via ns.
-- so the docked panel and Compendium share the exact same look.
local CreateSectionHeader = ns.CreateSectionHeader
local SetCollapsed = ns.SetCollapsed

-------------------------------------------------------------------------------
-- Item cache (request → cache → refresh on load)
-------------------------------------------------------------------------------

local itemCache = {}
local pendingItems = {}
local compendiumDirty = false

local function RequestItemData(itemId)
    if not itemId or itemId == 0 then return end
    if itemCache[itemId] or pendingItems[itemId] then return end
    pendingItems[itemId] = true
    C_Item.RequestLoadItemDataByID(itemId)
end

local function RequestAllGearItems(gearData)
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
    -- Also request IV items for the same class/spec
    if selectedClass and selectedSpec and ns.GetIcyVeinsSpecData then
        local ivData = ns:GetIcyVeinsSpecData(selectedClass, selectedSpec)
        if ivData and ivData.bisGear then
            for _, tab in ipairs(ivData.bisGear) do
                for _, g in ipairs(tab.slots) do RequestItemData(g.item.itemId) end
            end
        end
    end
end

local itemEventFrame = CreateFrame("Frame")
itemEventFrame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
itemEventFrame:SetScript("OnEvent", function(_, _, itemId, success)
    if success then
        pendingItems[itemId] = nil
        local name, _, quality, _, _, _, _, _, _, icon = GetItemInfo(itemId)
        if name then
            itemCache[itemId] = { name = name, quality = quality, icon = icon }
            if not compendiumDirty and UI.frame and UI.frame:IsShown() then
                compendiumDirty = true
                C_Timer.After(0.1, function()
                    compendiumDirty = false
                    if UI.frame and UI.frame:IsShown() then
                        ns:UpdateCompendium()
                    end
                end)
            end
        end
    end
end)


local function GetItemDisplayName(itemRef)
    if not itemRef then return "" end
    if itemRef.spellId then
        if C_Spell and C_Spell.GetSpellName then
            local name = C_Spell.GetSpellName(itemRef.spellId)
            if name then return name end
        end
    end
    if itemRef.itemId then
        local cached = itemCache[itemRef.itemId]
        if cached and cached.name then return cached.name end
        local name = GetItemInfo(itemRef.itemId)
        if name then return name end
    end
    return itemRef.name or ("Item " .. (itemRef.itemId or "?"))
end

local function GetItemQuality(itemId)
    if not itemId then return nil end
    local cached = itemCache[itemId]
    if cached and cached.quality then return cached.quality end
    local _, _, quality = GetItemInfo(itemId)
    return quality
end

-- FormatItem(itemRef [, name]) -> string
-- Convenience wrapper around ns.FormatItemLabel that pulls quality
-- from the cache. Pass an explicit name to override the resolved one
-- (e.g. when stripping a prefix from an enchant name).
local function FormatItem(itemRef, nameOverride)
    if not itemRef then return "" end
    local name = nameOverride or GetItemDisplayName(itemRef)
    return ns.FormatItemLabel(name, GetItemQuality(itemRef.itemId))
end

local ICON_SIZE = 16

local function GetItemIcon(itemId)
    if not itemId then return nil end
    local cached = itemCache[itemId]
    if cached and cached.icon then return cached.icon end
    local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemId)
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

local function CreateRowIcon(row)
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(ICON_SIZE, ICON_SIZE)
    icon:SetPoint("LEFT", 2, 0)
    icon:Hide()
    row.icon = icon
    return icon
end

local function SetRowIcon(row, itemId, spellId)
    if not row.icon then return end
    local tex = GetSpellIcon(spellId) or GetItemIcon(itemId)
    if tex then
        row.icon:SetTexture(tex)
        row.icon:Show()
    else
        row.icon:Hide()
    end
end

local function StripEnchantPrefix(name)
    local stripped = name:match("^Enchant [^%-]+ %- (.+)$")
    return stripped or name
end

-------------------------------------------------------------------------------
-- Dropdown setup (forward declared, assigned in InitFrame)
-------------------------------------------------------------------------------

local SetupClassDropdown, SetupSpecDropdown, SetupHeroDropdown

-------------------------------------------------------------------------------
-- InitFrame — lazily creates all UI (ensures Blizzard templates are loaded)
-------------------------------------------------------------------------------

local function InitFrame()
    if initialized then return end
    initialized = true

    -- Main frame
    UI.frame = CreateFrame("Frame", "ClassCodexCompendium", UIParent, "ButtonFrameTemplate")
    UI.frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    -- HIGH strata matches the small codex panel (ClassCodex.lua) and stops
    -- other addons' HIGH-strata frames (cooldown managers like Ayije CDM,
    -- action bars, buff icons) from rendering through the Compendium
    -- background and over the scrolling rotation list. Tooltips stay on
    -- top because TOOLTIP strata is above HIGH.
    UI.frame:SetFrameStrata("HIGH")
    -- Restore saved position or center
    if ClassCodexDB and ClassCodexDB.compendiumX and ClassCodexDB.compendiumY then
        UI.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", ClassCodexDB.compendiumX, ClassCodexDB.compendiumY)
    else
        UI.frame:SetPoint("CENTER")
    end
    UI.frame:SetTitle("Class Codex Compendium")
    UI.frame:SetPortraitToAsset("Interface\\Icons\\INV_Misc_Book_09")
    ButtonFrameTemplate_HideButtonBar(UI.frame)
    -- Blizzard's ButtonFrameTemplate anchors the NineSlice bottom corners
    -- with a -3px Y offset so they hang slightly below the frame edge,
    -- meant to overlap a tab strip flush against the frame. Our tabs sit
    -- 30px below, so the default anchors leave the corners floating as
    -- "ears" under the frame. Preserve Blizzard's X offset (which positions
    -- the corner art correctly) and pin Y at -4 so the corner art hugs
    -- the BottomEdge slice cleanly without leaving a sliver gap above it.
    -- The BottomEdge anchors between the two corners and re-appears once
    -- they're positioned.
    local function pinCornerToBottomEdge(corner)
        if not corner then return end
        local point, relTo, relPoint, x = corner:GetPoint(1)
        if not point then return end
        corner:ClearAllPoints()
        corner:SetPoint(point, relTo, relPoint, x, -4)
    end
    if UI.frame.NineSlice then
        pinCornerToBottomEdge(UI.frame.NineSlice.BottomLeftCorner)
        pinCornerToBottomEdge(UI.frame.NineSlice.BottomRightCorner)
    end
    UI.frame:EnableMouse(true)
    UI.frame:SetMovable(true)
    UI.frame:SetClampedToScreen(true)
    UI.frame:Hide()
    UI.frame:SetScript("OnHide", function()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    end)
    tinsert(UISpecialFrames, "ClassCodexCompendium")

    -- Make title bar draggable
    UI.frame.TitleContainer:EnableMouse(true)
    UI.frame.TitleContainer:RegisterForDrag("LeftButton")
    UI.frame.TitleContainer:SetScript("OnDragStart", function() UI.frame:StartMoving() end)
    UI.frame.TitleContainer:SetScript("OnDragStop", function()
        UI.frame:StopMovingOrSizing()
        if ClassCodexDB then
            ClassCodexDB.compendiumX = UI.frame:GetLeft()
            ClassCodexDB.compendiumY = UI.frame:GetTop()
        end
    end)

    -- Tabs
    local TAB_DATA = {
        { key = "guide",        label = L["tab.guide"] },
        { key = "talents",      label = L["section.talents"] },
        { key = "bis",          label = L["tab.bis_gear"] },
        { key = "trinkets",     label = L["tab.trinkets"] },
        { key = "enhancements", label = L["tab.enhancements"] },
        { key = "crafts",       label = L["tab.crafts"] },
    }
    local tabs = {}
    for i, data in ipairs(TAB_DATA) do
        local tab = CreateFrame("Button", "ClassCodexCompendiumTab" .. i, UI.frame, "PanelTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(data.label)
        tab.tabKey = data.key
        if i == 1 then
            tab:SetPoint("BOTTOMLEFT", UI.frame, "BOTTOMLEFT", 15, -30)
        else
            tab:SetPoint("LEFT", tabs[i - 1], "RIGHT", -14, 0)
        end
        tab:SetScript("OnClick", function(self)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
            activeTab = self.tabKey
            PanelTemplates_SetTab(UI.frame, self:GetID())
            SaveCompendiumState()
            ns:UpdateCompendium()
        end)
        tabs[i] = tab
    end
    UI.tabs = tabs
    UI.TAB_DATA = TAB_DATA
    PanelTemplates_SetNumTabs(UI.frame, #TAB_DATA)
    PanelTemplates_SetTab(UI.frame, 1)

    -- Scroll frame inside Inset
    local scrollFrame = CreateFrame("ScrollFrame", "ClassCodexCompendiumScroll", UI.frame.Inset, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", UI.frame.Inset, "TOPLEFT", 4, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", UI.frame.Inset, "BOTTOMRIGHT", -24, 4)

    UI.scrollChild = CreateFrame("Frame", nil, scrollFrame)
    UI.scrollChild:SetWidth(scrollFrame:GetWidth() or (FRAME_WIDTH - 40))
    UI.scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(UI.scrollChild)
    scrollFrame:SetScript("OnSizeChanged", function(_, w) UI.scrollChild:SetWidth(w) end)

    -- Dropdowns (attic area — anchored from the right)
    UI.heroDropdown = CreateFrame("DropdownButton", "ClassCodexCompHeroDD", UI.frame, "WowStyle1DropdownTemplate")
    UI.heroDropdown:SetPoint("TOPRIGHT", UI.frame.Inset, "TOPRIGHT", 0, 28)
    UI.heroDropdown:SetWidth(145)

    UI.specDropdown = CreateFrame("DropdownButton", "ClassCodexCompSpecDD", UI.frame, "WowStyle1DropdownTemplate")
    UI.specDropdown:SetPoint("RIGHT", UI.heroDropdown, "LEFT", -3, 0)
    UI.specDropdown:SetWidth(130)

    UI.classDropdown = CreateFrame("DropdownButton", "ClassCodexCompClassDD", UI.frame, "WowStyle1DropdownTemplate")
    UI.classDropdown:SetPoint("RIGHT", UI.specDropdown, "LEFT", -3, 0)
    UI.classDropdown:SetWidth(140)

    -- Copy popup (shared)
    -- Copy popup is a single shared widget exposed by ClassCodex.lua;
    -- the Compendium just hands strings to ns.ShowCopyPopup.

    ---------------------------------------------------------------------------
    -- Sections
    ---------------------------------------------------------------------------

    local function MakeItemRow(parent)
        local row = CreateFrame("Button", nil, parent)
        row:SetHeight(ROW_HEIGHT)
        row:RegisterForClicks("LeftButtonUp")
        row:SetScript("OnEnter", function(self)
            if self.itemId then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if self.bonusIDs and #self.bonusIDs > 0 then
                    local bonusStr = #self.bonusIDs .. ":" .. table.concat(self.bonusIDs, ":")
                    local link = format("item:%d::::::::::::%s", self.itemId, bonusStr)
                    local ok = pcall(GameTooltip.SetHyperlink, GameTooltip, link)
                    if not ok then GameTooltip:SetItemByID(self.itemId) end
                else
                    GameTooltip:SetItemByID(self.itemId)
                end
                -- Crafts surface their embellishment as a tooltip line so a
                -- single row can carry both items without splitting the
                -- visual list.
                if self.embItemId then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("Embellishment:", 0.6, 0.6, 0.6)
                    local embName = self.embName
                    if not embName or embName == "" then
                        embName = (C_Item and C_Item.GetItemInfo and C_Item.GetItemInfo(self.embItemId))
                            or GetItemInfo(self.embItemId) or ("Item " .. self.embItemId)
                    end
                    GameTooltip:AddLine("  " .. embName, 1, 1, 1)
                end
                if self.sourceText then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddDoubleLine("Source", self.sourceText, 0.5, 0.5, 0.5, 1, 0.82, 0)
                end
                GameTooltip:Show()
            elseif self.spellId then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.spellId)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:SetScript("OnClick", function(self)
            if not self.itemId then return end
            local _, link = C_Item.GetItemInfo(self.itemId)
            if not link then return end
            if IsModifiedClick("CHATLINK") then
                ChatEdit_InsertLink(link)
            elseif IsModifiedClick("DRESSUP") then
                DressUpItemLink(link)
            end
        end)
        return row
    end

    -- Guide: Stats
    UI.statSection = CreateFrame("Frame", nil, UI.scrollChild)
    UI.statHeader = CreateSectionHeader(UI.statSection, L["section.stat_priority"], true)
    UI.statContent = CreateFrame("Frame", nil, UI.statSection)
    UI.statContent:SetPoint("TOPLEFT", UI.statHeader, "BOTTOMLEFT", 0, -2)
    UI.statContent:SetPoint("RIGHT", 0, 0)
    UI.statCtxDropdown = CreateFrame("DropdownButton", "ClassCodexCompStatCtxDD", UI.statContent, "WowStyle1DropdownTemplate")
    UI.statCtxDropdown:SetPoint("TOPLEFT", 0, 0)
    UI.statCtxDropdown:SetPoint("TOPRIGHT", 0, 0)
    UI.statCtxDropdown:SetHeight(24)
    UI.statCtxDropdown:Hide()
    UI.statFrames = {}
    UI.statCollapsed = false
    for i = 1, MAX_STATS do
        local row = CreateFrame("Frame", nil, UI.statContent)
        row:SetHeight(20)
        local rank = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rank:SetPoint("LEFT", 0, 0); rank:SetWidth(20); rank:SetJustifyH("CENTER")
        row.rank = rank
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", rank, "RIGHT", 6, 0); name:SetPoint("RIGHT", 0, 0); name:SetJustifyH("LEFT")
        row.statName = name
        UI.statFrames[i] = row
    end
    -- Shown when the PvP stat-priority context is selected for a spec
    -- with no Murlok data — keeps the dropdown discoverable instead of
    -- silently swallowing the user's selection.
    UI.statPvpFallback = UI.statContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    UI.statPvpFallback:SetTextColor(0.5, 0.5, 0.5)
    UI.statPvpFallback:Hide()
    UI.statHeader:SetScript("OnClick", function()
        UI.statCollapsed = not UI.statCollapsed
        SetCollapsed(UI.statContent, UI.statHeader, UI.statCollapsed)
        ns:LayoutCompendium()
    end)

    -- Guide: Talents
    UI.talentSection = CreateFrame("Frame", nil, UI.scrollChild)
    UI.talentHeader = CreateSectionHeader(UI.talentSection, L["section.talents"], true)
    UI.talentContent = CreateFrame("Frame", nil, UI.talentSection)
    UI.talentContent:SetPoint("TOPLEFT", UI.talentHeader, "BOTTOMLEFT", 0, -2)
    UI.talentContent:SetPoint("RIGHT", 0, 0)
    UI.talentButtons = {}
    UI.talentCollapsed = false

    -- Lazy factory so the pool can grow past the initial allocation.
    -- Render functions call this with a 1-based index; existing buttons
    -- are reused, missing ones are created on demand. Hero badge support
    -- (used by the Archon view) hangs off btn.heroIcon.
    local function CreateTalentButton(i)
        if UI.talentButtons[i] then return UI.talentButtons[i] end
        local btn = CreateFrame("Button", nil, UI.talentContent, "BackdropTemplate")
        btn:SetHeight(TALENT_BTN_HEIGHT)
        btn:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        btn:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
        btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
        local hero = btn:CreateTexture(nil, "ARTWORK")
        hero:SetSize(14, 14); hero:SetPoint("LEFT", 6, 0); hero:Hide()
        btn.heroIcon = hero
        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("LEFT", 8, 0); text:SetPoint("RIGHT", -8, 0)
        text:SetJustifyH("LEFT"); text:SetTextColor(0.8, 0.8, 0.8)
        btn.label = text
        local ci = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        ci:SetPoint("RIGHT", -6, 0)
        ci:SetText("|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:12:12|t")
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropBorderColor(0.6, 0.6, 0.6, 1); self.label:SetTextColor(1, 1, 1)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine("Click to copy talent string", 1, 1, 1); GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8); self.label:SetTextColor(0.8, 0.8, 0.8); GameTooltip:Hide()
        end)
        btn:Hide()
        UI.talentButtons[i] = btn
        return btn
    end
    UI._ensureTalentButton = CreateTalentButton
    for i = 1, MAX_TALENT_BUTTONS do CreateTalentButton(i) end
    UI.talentFallback = UI.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    UI.talentFallback:SetTextColor(0.5, 0.5, 0.5); UI.talentFallback:Hide()
    UI.talentHeader:SetScript("OnClick", function()
        UI.talentCollapsed = not UI.talentCollapsed
        SetCollapsed(UI.talentContent, UI.talentHeader, UI.talentCollapsed)
        ns:LayoutCompendium()
    end)

    -- Hero/section group headers (Talents tab). Same lazy-grow pattern
    -- as talentButtons — Archon adds Mythic+/Raid Heroic/Raid Mythic
    -- headers on top of the hero headers.
    UI.talentHeroHeaders = {}
    local function CreateTalentHeroHeader(i)
        if UI.talentHeroHeaders[i] then return UI.talentHeroHeaders[i] end
        local hdr = CreateFrame("Frame", nil, UI.talentContent)
        hdr:SetHeight(TALENT_HERO_HEADER_HEIGHT)
        local text = hdr:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", 4, 0)
        text:SetTextColor(1, 0.82, 0)
        hdr.label = text
        hdr:Hide()
        UI.talentHeroHeaders[i] = hdr
        return hdr
    end
    UI._ensureTalentHeroHeader = CreateTalentHeroHeader
    for i = 1, MAX_TALENT_HERO_HEADERS do CreateTalentHeroHeader(i) end

    -- Source dropdown (Wowhead | Archon | PvP) — only shown by the
    -- Talents tab. Mirrors the docked panel and the addon's other
    -- dropdowns. Each option carries the brand icon via a |T...|t escape.
    local SOURCE_ICON_WOWHEAD = "|TInterface\\AddOns\\ClassCodex\\Textures\\wowhead:12:12:0:0|t  Wowhead"
    local SOURCE_ICON_ARCHON  = "|TInterface\\AddOns\\ClassCodex\\Textures\\archon:12:12:0:0|t  Archon"
    local SOURCE_ICON_PVP     = "|TInterface\\AddOns\\ClassCodex\\Textures\\bnet:12:12:0:0|t  PvP"
    local function SourceLabel(source)
        if source == "archon" then return SOURCE_ICON_ARCHON end
        if source == "pvp" then return SOURCE_ICON_PVP end
        return SOURCE_ICON_WOWHEAD
    end

    UI.talentSource = "wowhead" -- per-spec source within the Compendium
    UI.talentSourceDropdown = ns.CreateOptionDropdown("ClassCodexCompendiumTalentSourceDropdown", UI.talentContent, 140)
    UI.talentSourceDropdown:Hide()

    UI._refreshTalentSourceDropdown = function(archonAvailable)
        -- PvP always appears so users discover the feature even on specs
        -- without scraped data — RenderPvPTalentList surfaces the
        -- "No PvP builds available." fallback when empty.
        local opts = { { label = SOURCE_ICON_WOWHEAD, value = "wowhead" } }
        if archonAvailable then
            opts[#opts + 1] = { label = SOURCE_ICON_ARCHON, value = "archon" }
        end
        opts[#opts + 1] = { label = SOURCE_ICON_PVP, value = "pvp" }
        -- Archon is the only source that can vanish (per-spec coverage gap).
        local current = UI.talentSource
        if current == "archon" and not archonAvailable then current = "wowhead" end
        if current ~= UI.talentSource then UI.talentSource = current end
        UI.talentSourceDropdown:SetOptions(opts, UI.talentSource, function(picked)
            if UI.talentSource ~= picked then
                UI.talentSource = picked
                ns:UpdateCompendium()
            end
        end)
    end

    -- Guide: Rotation
    UI.rotationSection = CreateFrame("Frame", nil, UI.scrollChild)
    UI.rotationHeader = CreateSectionHeader(UI.rotationSection, L["section.rotation"], true)
    UI.rotationContent = CreateFrame("Frame", nil, UI.rotationSection)
    UI.rotationContent:SetPoint("TOPLEFT", UI.rotationHeader, "BOTTOMLEFT", 0, -2)
    UI.rotationContent:SetPoint("RIGHT", 0, 0)
    -- Context switcher for Wowhead's per-mode rotations (Single Target,
    -- Multitarget, Opener, …). Hidden when the spec exposes only one
    -- context. Mirrors statCtxDropdown / trinketCtxDropdown.
    UI.rotationCtxDropdown = CreateFrame("DropdownButton", "ClassCodexCompRotCtxDD", UI.rotationContent, "WowStyle1DropdownTemplate")
    UI.rotationCtxDropdown:SetPoint("TOPLEFT", 0, 0)
    UI.rotationCtxDropdown:SetPoint("TOPRIGHT", 0, 0)
    UI.rotationCtxDropdown:SetHeight(24)
    UI.rotationCtxDropdown:Hide()
    UI.rotationFrames = {}
    UI.rotationCollapsed = false
    for i = 1, MAX_ROTATION_STEPS do
        local row = CreateFrame("Frame", nil, UI.rotationContent)
        row:SetHeight(ROW_HEIGHT)
        local rank = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rank:SetPoint("TOPLEFT", 0, 0); rank:SetWidth(18); rank:SetJustifyH("RIGHT"); rank:SetTextColor(0.5, 0.5, 0.5)
        row.rank = rank
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16); icon:SetPoint("TOPLEFT", rank, "TOPRIGHT", 4, 0)
        row.icon = icon
        local st = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        st:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, 0); st:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        st:SetJustifyH("LEFT"); st:SetJustifyV("TOP"); st:SetWordWrap(true); st:SetNonSpaceWrap(true)
        row.stepText = st
        row:EnableMouse(true)
        row:SetScript("OnEnter", function(self)
            if self.spellId then GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetSpellByID(self.spellId); GameTooltip:Show() end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        UI.rotationFrames[i] = row
    end
    UI.rotationFallback = UI.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    UI.rotationFallback:SetTextColor(0.5, 0.5, 0.5); UI.rotationFallback:Hide()
    UI.rotationHeader:SetScript("OnClick", function()
        UI.rotationCollapsed = not UI.rotationCollapsed
        SetCollapsed(UI.rotationContent, UI.rotationHeader, UI.rotationCollapsed)
        ns:LayoutCompendium()
    end)

    -- Gearing: Enchants
    UI.enchantSection = CreateFrame("Frame", nil, UI.scrollChild)
    UI.enchantHeader = CreateSectionHeader(UI.enchantSection, L["tab.enchants"], true)
    UI.enchantContent = CreateFrame("Frame", nil, UI.enchantSection)
    UI.enchantContent:SetPoint("TOPLEFT", UI.enchantHeader, "BOTTOMLEFT", 0, -2); UI.enchantContent:SetPoint("RIGHT", 0, 0)
    -- Enhancements source dropdown — Wowhead vs Murlok (PvP) toggle for
    -- the Enchants + Gems sections. Hidden by default; shown when PvP
    -- data exists for the spec. Parented to scrollChild and positioned
    -- ABOVE the Enchants section (not inside it) so the section can
    -- collapse / hide cleanly without taking the dropdown with it, and
    -- the layout reads "source picker → Enchants → Gems".
    UI.enhancementsSourceDropdown = CreateFrame("DropdownButton", "ClassCodexCompEnhancementsSourceDD", UI.scrollChild, "WowStyle1DropdownTemplate")
    UI.enhancementsSourceDropdown:SetHeight(24)
    UI.enhancementsSourceDropdown:Hide()
    -- Enchant rows: outer frame holds icon + slot label, then a stack
    -- of two sub-rows (bestSub / altSub) — each sub is its own Button
    -- with its own tooltip + click target. Mirrors the docked panel.
    local function MakeEnchantSubRow(parent)
        local sub = CreateFrame("Button", nil, parent)
        sub:SetHeight(ROW_HEIGHT)
        sub:RegisterForClicks("LeftButtonUp")
        local text = sub:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", 0, 0); text:SetPoint("RIGHT", 0, 0)
        text:SetJustifyH("LEFT")
        text:SetWordWrap(false)
        sub.text = text
        sub:SetScript("OnEnter", function(self)
            if self.itemId then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetItemByID(self.itemId)
                GameTooltip:Show()
            elseif self.spellId then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.spellId)
                GameTooltip:Show()
            end
        end)
        sub:SetScript("OnLeave", function() GameTooltip:Hide() end)
        sub:SetScript("OnClick", function(self)
            if not self.itemId then return end
            local _, link = C_Item.GetItemInfo(self.itemId)
            if not link then return end
            if IsModifiedClick("CHATLINK") then
                ChatEdit_InsertLink(link)
            elseif IsModifiedClick("DRESSUP") then
                DressUpItemLink(link)
            end
        end)
        sub:Hide()
        return sub
    end

    UI.enchantRows = {}; UI.enchantCollapsed = false
    for i = 1, MAX_ENCHANT_ROWS do
        local row = CreateFrame("Frame", nil, UI.enchantContent)
        row:SetHeight(ROW_HEIGHT)

        CreateRowIcon(row)
        row.icon:ClearAllPoints()
        row.icon:SetPoint("LEFT", row, "LEFT", 2, 0)

        local slot = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slot:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        slot:SetWidth(55)
        slot:SetJustifyH("LEFT")
        slot:SetTextColor(0.6, 0.6, 0.6)
        row.slot = slot

        local bestSub = MakeEnchantSubRow(row)
        bestSub:SetPoint("TOPLEFT", row, "TOPLEFT", 2 + ICON_SIZE + 4 + 55 + 2, 0)
        bestSub:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.bestSub = bestSub

        local altSub = MakeEnchantSubRow(row)
        altSub:SetPoint("TOPLEFT", bestSub, "BOTTOMLEFT", 0, 0)
        altSub:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        row.altSub = altSub

        UI.enchantRows[i] = row
    end
    -- Shown when the PvP enhancements source is selected for a spec with
    -- no Murlok enchant/gem data — keeps the dropdown choice honoured
    -- instead of rendering an empty section.
    UI.enchantPvpFallback = UI.enchantContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    UI.enchantPvpFallback:SetTextColor(0.5, 0.5, 0.5)
    UI.enchantPvpFallback:Hide()
    UI.enchantHeader:SetScript("OnClick", function()
        UI.enchantCollapsed = not UI.enchantCollapsed; SetCollapsed(UI.enchantContent, UI.enchantHeader, UI.enchantCollapsed); ns:LayoutCompendium()
    end)

    -- Gearing: Gems
    UI.gemSection = CreateFrame("Frame", nil, UI.scrollChild)
    UI.gemHeader = CreateSectionHeader(UI.gemSection, L["tab.gems"], true)
    UI.gemContent = CreateFrame("Frame", nil, UI.gemSection)
    UI.gemContent:SetPoint("TOPLEFT", UI.gemHeader, "BOTTOMLEFT", 0, -2); UI.gemContent:SetPoint("RIGHT", 0, 0)
    UI.gemRows = {}; UI.gemCollapsed = false
    for i = 1, MAX_GEM_ROWS do
        local row = MakeItemRow(UI.gemContent)
        CreateRowIcon(row)
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", row.icon, "RIGHT", 4, 0); label:SetWidth(65); label:SetJustifyH("LEFT"); label:SetTextColor(0.6, 0.6, 0.6)
        row.label = label
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", label, "RIGHT", 4, 0); name:SetPoint("RIGHT", 0, 0); name:SetJustifyH("LEFT")
        row.name = name
        UI.gemRows[i] = row
    end
    UI.gemHeader:SetScript("OnClick", function()
        UI.gemCollapsed = not UI.gemCollapsed; SetCollapsed(UI.gemContent, UI.gemHeader, UI.gemCollapsed); ns:LayoutCompendium()
    end)

    -- Gearing: Consumables
    UI.consumSection = CreateFrame("Frame", nil, UI.scrollChild)
    UI.consumHeader = CreateSectionHeader(UI.consumSection, L["tab.consumables"], false)
    UI.consumContent = CreateFrame("Frame", nil, UI.consumSection)
    UI.consumContent:SetPoint("TOPLEFT", UI.consumHeader, "BOTTOMLEFT", 0, -2); UI.consumContent:SetPoint("RIGHT", 0, 0)
    UI.consumRows = {}; UI.consumCollapsed = false
    for i = 1, MAX_CONSUM_ROWS do
        local row = MakeItemRow(UI.consumContent)
        CreateRowIcon(row)
        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", row.icon, "RIGHT", 4, 0); label:SetWidth(90); label:SetJustifyH("LEFT"); label:SetTextColor(0.6, 0.6, 0.6)
        row.label = label
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", label, "RIGHT", 4, 0); name:SetPoint("RIGHT", 0, 0); name:SetJustifyH("LEFT")
        row.name = name
        UI.consumRows[i] = row
    end
    -- Single-section tab — not collapsible

    -- Gearing: Trinkets
    UI.trinketSection = CreateFrame("Frame", nil, UI.scrollChild)
    UI.trinketHeader = CreateSectionHeader(UI.trinketSection, L["tab.trinkets"], false)
    UI.trinketContent = CreateFrame("Frame", nil, UI.trinketSection)
    UI.trinketContent:SetPoint("TOPLEFT", UI.trinketHeader, "BOTTOMLEFT", 0, -2); UI.trinketContent:SetPoint("RIGHT", 0, 0)
    UI.trinketRows = {}; UI.trinketCollapsed = false
    for i = 1, MAX_TRINKET_ROWS do
        local row = MakeItemRow(UI.trinketContent)
        local tier = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tier:SetPoint("LEFT", 2, 0); tier:SetWidth(16); tier:SetJustifyH("CENTER")
        row.tier = tier
        CreateRowIcon(row)
        row.icon:ClearAllPoints(); row.icon:SetPoint("LEFT", tier, "RIGHT", 4, 0)
        local src = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        src:SetPoint("RIGHT", -2, 0); src:SetWidth(120); src:SetJustifyH("RIGHT")
        src:SetWordWrap(false); src:SetTextColor(0.5, 0.5, 0.5)
        row.source = src
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0); name:SetPoint("RIGHT", src, "LEFT", -4, 0)
        name:SetJustifyH("LEFT"); name:SetWordWrap(false)
        row.name = name
        UI.trinketRows[i] = row
    end
    UI.trinketCtxDropdown = CreateFrame("DropdownButton", "ClassCodexCompTrinketCtxDD", UI.trinketContent, "WowStyle1DropdownTemplate")
    UI.trinketCtxDropdown:SetPoint("TOPLEFT", 0, 0)
    UI.trinketCtxDropdown:SetPoint("TOPRIGHT", 0, 0)
    UI.trinketCtxDropdown:SetHeight(24)
    UI.trinketCtxDropdown:Hide()
    -- Single-section tab — not collapsible

    -- Gearing: Crafts
    UI.craftSection = CreateFrame("Frame", nil, UI.scrollChild)
    UI.craftHeader = CreateSectionHeader(UI.craftSection, L["tab.crafts"], false)
    UI.craftContent = CreateFrame("Frame", nil, UI.craftSection)
    UI.craftContent:SetPoint("TOPLEFT", UI.craftHeader, "BOTTOMLEFT", 0, -2); UI.craftContent:SetPoint("RIGHT", 0, 0)
    UI.craftRows = {}; UI.craftCollapsed = false
    for i = 1, MAX_CRAFT_ROWS do
        local row = MakeItemRow(UI.craftContent)
        local order = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        order:SetPoint("LEFT", 0, 0); order:SetWidth(20); order:SetJustifyH("CENTER"); order:SetTextColor(0.5, 0.5, 0.5)
        row.order = order
        CreateRowIcon(row)
        row.icon:ClearAllPoints(); row.icon:SetPoint("LEFT", order, "RIGHT", 2, 0)
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0); name:SetPoint("RIGHT", 0, 0); name:SetJustifyH("LEFT")
        row.name = name
        UI.craftRows[i] = row
    end
    -- Single-section tab — not collapsible

    -- Gearing: BiS Gear
    UI.bisSection = CreateFrame("Frame", nil, UI.scrollChild)
    UI.bisHeader = CreateSectionHeader(UI.bisSection, L["tab.best_in_slot"], false)
    UI.bisContent = CreateFrame("Frame", nil, UI.bisSection)
    UI.bisContent:SetPoint("TOPLEFT", UI.bisHeader, "BOTTOMLEFT", 0, -2); UI.bisContent:SetPoint("RIGHT", 0, 0)
    UI.bisSourceDropdown = CreateFrame("DropdownButton", "ClassCodexCompBisSourceDD", UI.bisContent, "WowStyle1DropdownTemplate")
    UI.bisSourceDropdown:SetPoint("TOPLEFT", 0, 0)
    UI.bisSourceDropdown:SetPoint("TOPRIGHT", 0, 0)
    UI.bisSourceDropdown:SetHeight(24)
    UI.bisSourceDropdown:Hide()
    UI.bisTabDropdown = CreateFrame("DropdownButton", "ClassCodexCompBisTabDD", UI.bisContent, "WowStyle1DropdownTemplate")
    UI.bisTabDropdown:SetPoint("TOPLEFT", 0, 0)
    UI.bisTabDropdown:SetPoint("TOPRIGHT", 0, 0)
    UI.bisTabDropdown:SetHeight(24)
    UI.bisTabDropdown:Hide()
    UI.bisRows = {}; UI.bisCollapsed = false
    for i = 1, MAX_BIS_ROWS do
        local row = MakeItemRow(UI.bisContent)
        CreateRowIcon(row)
        local slot = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        slot:SetPoint("LEFT", row.icon, "RIGHT", 4, 0); slot:SetWidth(70); slot:SetJustifyH("LEFT"); slot:SetTextColor(0.6, 0.6, 0.6)
        row.slot = slot
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local source = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        source:SetPoint("RIGHT", -2, 0); source:SetWidth(110); source:SetJustifyH("RIGHT")
        source:SetWordWrap(false); source:SetTextColor(0.5, 0.5, 0.5)
        name:SetPoint("LEFT", slot, "RIGHT", 4, 0); name:SetPoint("RIGHT", source, "LEFT", -4, 0); name:SetJustifyH("LEFT")
        name:SetWordWrap(false)
        row.name = name
        row.source = source
        UI.bisRows[i] = row
    end
    -- Shown when the PvP source is selected for a spec without Murlok
    -- gear data — keeps the dropdown discoverable instead of falling
    -- back to a different source silently.
    UI.bisPvpFallback = UI.bisContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    UI.bisPvpFallback:SetTextColor(0.5, 0.5, 0.5)
    UI.bisPvpFallback:Hide()
    -- Single-section tab — not collapsible

    -- Empty state
    UI.emptyText = UI.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    UI.emptyText:SetPoint("CENTER", UI.scrollChild, "TOP", 0, -60)
    UI.emptyText:SetText(L["empty.select_class_spec"])
    UI.emptyText:SetTextColor(0.5, 0.5, 0.5)
end

-------------------------------------------------------------------------------
-- Dropdown setup functions
-------------------------------------------------------------------------------

local HERO_TALENT_ATLAS = ns.HERO_TALENT_ATLAS

SaveCompendiumState = function()
    if not ClassCodexDB then return end
    ClassCodexDB.compendiumClass = selectedClass
    ClassCodexDB.compendiumSpec = selectedSpec
    ClassCodexDB.compendiumHero = selectedHero
    ClassCodexDB.compendiumTab = activeTab
end

SetupClassDropdown = function()
    UI.classDropdown:SetupMenu(function(_, rootDescription)
        for _, classToken in ipairs(CLASS_ORDER) do
            local color = RAID_CLASS_COLORS[classToken]
            local label = color and color:WrapTextInColorCode(GetClassDisplayName(classToken)) or GetClassDisplayName(classToken)
            rootDescription:CreateRadio(label,
                function() return selectedClass == classToken end,
                function()
                    selectedClass = classToken
                    selectedSpec = SPEC_KEYS[classToken] and SPEC_KEYS[classToken][1] or nil
                    -- Auto-select first hero talent for new spec
                    if selectedSpec then
                        local specData = DATA[classToken] and DATA[classToken][selectedSpec]
                        if specData then
                            local opts = GetHeroTalentOptions(specData)
                            selectedHero = opts[1] or "All"
                        else
                            selectedHero = nil
                        end
                    else
                        selectedHero = nil
                    end
                    SaveCompendiumState()
                    SetupSpecDropdown()
                    SetupHeroDropdown()
                    UI.specDropdown:GenerateMenu()
                    UI.heroDropdown:GenerateMenu()
                    ns:UpdateCompendium()
                end,
                classToken)
        end
    end)
end

SetupSpecDropdown = function()
    UI.specDropdown:SetupMenu(function(_, rootDescription)
        if not selectedClass then return end
        local keys = SPEC_KEYS[selectedClass]
        if not keys then return end
        for _, specKey in ipairs(keys) do
            local label = GetSpecDisplayName(selectedClass, specKey)
            rootDescription:CreateRadio(label,
                function() return selectedSpec == specKey end,
                function()
                    selectedSpec = specKey
                    -- Auto-select first hero talent
                    local specData = DATA[selectedClass] and DATA[selectedClass][specKey]
                    if specData then
                        local opts = GetHeroTalentOptions(specData)
                        selectedHero = opts[1] or "All"
                    else
                        selectedHero = nil
                    end
                    SaveCompendiumState()
                    SetupHeroDropdown()
                    UI.heroDropdown:GenerateMenu()
                    ns:UpdateCompendium()
                end,
                specKey)
        end
    end)
end

SetupHeroDropdown = function()
    UI.heroDropdown:SetupMenu(function(_, rootDescription)
        if not selectedClass or not selectedSpec then return end
        local specData = DATA[selectedClass] and DATA[selectedClass][selectedSpec]
        if not specData then return end
        local options = GetHeroTalentOptions(specData)
        if #options == 0 then
            rootDescription:CreateTitle("No hero talents")
            return
        end
        for _, heroName in ipairs(options) do
            rootDescription:CreateRadio(heroName,
                function() return selectedHero == heroName end,
                function()
                    selectedHero = heroName
                    SaveCompendiumState()
                    ns:UpdateCompendium()
                end,
                heroName)
        end
    end)
end

-------------------------------------------------------------------------------
-- Update: populate content based on selections
-------------------------------------------------------------------------------

function ns:UpdateCompendium()
    -- Hide all sections first
    UI.statSection:Hide(); UI.talentSection:Hide(); UI.rotationSection:Hide()
    UI.enchantSection:Hide(); UI.gemSection:Hide(); UI.consumSection:Hide()
    UI.trinketSection:Hide(); UI.craftSection:Hide(); UI.bisSection:Hide()
    UI.emptyText:Hide(); UI.talentFallback:Hide(); UI.rotationFallback:Hide()
    -- Enhancements source dropdown lives outside enchantSection now,
    -- so hiding the section doesn't take it down. Hide it explicitly
    -- on every tab switch — the Enhancements tab's update path will
    -- re-show it when it's actually needed.
    if UI.enhancementsSourceDropdown then UI.enhancementsSourceDropdown:Hide() end

    if not selectedClass or not selectedSpec then
        UI.emptyText:Show()
        ns:LayoutCompendium()
        return
    end

    local specData = DATA[selectedClass] and DATA[selectedClass][selectedSpec]
    if not specData then
        UI.emptyText:SetText(L["empty.no_data"])
        UI.emptyText:Show()
        ns:LayoutCompendium()
        return
    end

    -- Auto-select first hero if none selected
    local heroOptions = GetHeroTalentOptions(specData)
    if not selectedHero or selectedHero == "" then
        selectedHero = heroOptions[1] or "All"
    end

    -- Update portrait
    local icon = GetSpecIconTexture(selectedClass, selectedSpec)
    if icon then UI.frame:SetPortraitToAsset(icon)
    else UI.frame:SetPortraitToAsset("Interface\\Icons\\INV_Misc_Book_09") end

    -- Update title
    UI.frame:SetTitle("Class Codex Compendium · " .. GetSpecDisplayName(selectedClass, selectedSpec) .. " " .. GetClassDisplayName(selectedClass))

    -- Request item data for gearing tabs
    if activeTab ~= "guide" and activeTab ~= "talents" and GEAR_DATA then
        local gearData = GEAR_DATA[selectedClass] and GEAR_DATA[selectedClass][selectedSpec]
        RequestAllGearItems(gearData)
    end

    local heroTalent = selectedHero or "All"

    if activeTab == "guide" then
        self:UpdateCompendiumGuide(specData, heroTalent)
    elseif activeTab == "talents" then
        self:UpdateCompendiumAllTalents(specData, selectedClass, selectedSpec)
    elseif activeTab == "bis" then
        self:UpdateCompendiumBis()
    elseif activeTab == "trinkets" then
        self:UpdateCompendiumTrinkets()
    elseif activeTab == "enhancements" then
        self:UpdateCompendiumEnchants()
        self:UpdateCompendiumConsumables()
    elseif activeTab == "crafts" then
        self:UpdateCompendiumCrafts()
    end

    ns:LayoutCompendium()
end

-- Build a synthetic priority record from Murlok's per-spec PvP stat data
-- so the existing rendering loop (which expects priority.stats as an
-- array of stat-label tiers) works without source-specific branches.
local function BuildPvPPrioritySynthetic()
    if not selectedClass or not selectedSpec or not ns.GetPvPStats then return nil end
    local stats = ns.GetPvPStats(selectedClass, selectedSpec)
    if not stats or #stats == 0 then return nil end
    local labels = ns.STAT_LABELS or {}
    local tiers = {}
    for _, s in ipairs(stats) do
        local label = labels[s.key] or s.key
        tiers[#tiers + 1] = { label }
    end
    return { stats = tiers }
end

-- Render the Stat Priority section (shared between Guide and Stats tabs).
-- Pure layout — caller decides which other sections to show alongside it.
local function RenderStatPrioritySection(specData, heroTalent)
    local statCtxOptions = GetStatContextOptions(specData, heroTalent)
    -- PvP always appears as a sibling context so users discover the
    -- feature; when Murlok has no priority for this spec the section
    -- shows a small "no data" line instead of stat rows. The dropdown
    -- only renders if there's more than one option to pick.
    local pvpPriority = BuildPvPPrioritySynthetic()
    if #statCtxOptions == 0 then
        statCtxOptions = { "General", "PvP" }
    else
        statCtxOptions[#statCtxOptions + 1] = "PvP"
    end
    local showStatCtx = #statCtxOptions > 0

    if showStatCtx then
        if not currentStatContext then currentStatContext = statCtxOptions[1] end
        local found = false
        for _, c in ipairs(statCtxOptions) do
            if c == currentStatContext then found = true; break end
        end
        if not found then currentStatContext = statCtxOptions[1] end

        UI.statCtxDropdown:SetupMenu(function(_, rootDescription)
            for _, ctx in ipairs(statCtxOptions) do
                -- PvP context carries the Murlok brand icon — same
                -- attribution pattern the Talents/Gear source dropdowns
                -- use for Wowhead/Archon. Other contexts ("General",
                -- "Mythic+", "Raid") come from Wowhead's guide so they
                -- inherit the tab's existing Wowhead context, and route
                -- through L[ctx] for locale-specific labels.
                local label = L[ctx]
                if ctx == "PvP" then
                    label = "|TInterface\\AddOns\\ClassCodex\\Textures\\murlok:12:12:0:0|t  " .. L["pvp.label"]
                end
                rootDescription:CreateRadio(label,
                    function() return currentStatContext == ctx end,
                    function()
                        currentStatContext = ctx
                        ns:UpdateCompendium()
                    end,
                    ctx)
            end
        end)
        UI.statCtxDropdown:Show()
    else
        UI.statCtxDropdown:Hide()
        currentStatContext = nil
    end

    local statLookupCtx = currentStatContext or "General"
    local priority
    if currentStatContext == "PvP" then
        priority = pvpPriority -- may be nil; handled below
    else
        priority = FindMatch(specData.priorities, heroTalent, statLookupCtx)
    end
    UI.statPvpFallback:Hide()
    for i = 1, MAX_STATS do UI.statFrames[i]:Hide() end
    if priority then
        local yOffset = showStatCtx and -30 or 0
        for i = 1, math.min(#priority.stats, MAX_STATS) do
            local row = UI.statFrames[i]
            local color = RANK_COLORS[i]
            row.rank:SetTextColor(color and color.r or 0.6, color and color.g or 0.6, color and color.b or 0.6)
            row.rank:SetText(i .. ".")
            local names = {}
            for _, stat in ipairs(priority.stats[i]) do names[#names + 1] = stat end
            row.statName:SetTextColor(1, 1, 1)
            row.statName:SetText(table.concat(names, " / "))
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", UI.statContent, "TOPLEFT", 0, yOffset - (i - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", UI.statContent, "RIGHT", 0, 0)
            row:Show()
        end
        local statCount = math.min(#priority.stats, MAX_STATS)
        UI.statContent:SetHeight(math.abs(yOffset) + statCount * ROW_HEIGHT)
        UI.statSection:Show()
    elseif currentStatContext == "PvP" then
        local yOffset = showStatCtx and -30 or 0
        UI.statPvpFallback:SetText(L["pvp.no_stat_priority"]
            or "No PvP stat priority for this spec yet.")
        UI.statPvpFallback:ClearAllPoints()
        UI.statPvpFallback:SetPoint("TOPLEFT", UI.statContent, "TOPLEFT", 4, yOffset - 4)
        UI.statPvpFallback:Show()
        UI.statContent:SetHeight(math.abs(yOffset) + 20)
        UI.statSection:Show()
    end
end

function ns:UpdateCompendiumGuide(specData, heroTalent)
    RenderStatPrioritySection(specData, heroTalent)

    -- Talents — Guide view shows Wowhead-only context-filtered builds.
    -- The source dropdown is hidden here; the standalone Talents tab is
    -- the surface for browsing both sources.
    if UI.talentSourceDropdown then UI.talentSourceDropdown:Hide() end
    for _, b in ipairs(UI.talentButtons) do b:Hide() end
    for _, h in ipairs(UI.talentHeroHeaders) do h:Hide() end
    UI.talentFallback:Hide()
    local talentBuilds = GetAllTalentBuildsForHero(specData, heroTalent)
    if #talentBuilds > 0 then
        local count = #talentBuilds
        for i = 1, count do
            local t = talentBuilds[i]
            local btn = UI._ensureTalentButton(i)
            if btn.heroIcon then btn.heroIcon:Hide() end
            local label = t.context or L["talent.build"]
            if t.buildLabel and t.buildLabel ~= "" then label = label .. " — " .. t.buildLabel end
            btn.label:SetText(label)
            btn.label:ClearAllPoints()
            btn.label:SetPoint("LEFT", 8, 0); btn.label:SetPoint("RIGHT", -8, 0)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 0, -((i - 1) * (TALENT_BTN_HEIGHT + TALENT_BTN_GAP)))
            btn:SetPoint("RIGHT", UI.talentContent, "RIGHT", 0, 0)
            btn:SetScript("OnClick", function()
                ns.ShowCopyPopup(t.exportString, btn)
            end)
            btn:Show()
        end
        UI.talentContent:SetHeight(count * (TALENT_BTN_HEIGHT + TALENT_BTN_GAP))
        UI.talentSection:Show()
    elseif specData.talents and #specData.talents > 0 then
        UI.talentFallback:SetText(L["empty.no_builds_for"]:format(heroTalent))
        UI.talentFallback:Show()
        UI.talentContent:SetHeight(20)
        UI.talentSection:Show()
    end

    -- Rotation
    for i = 1, MAX_ROTATION_STEPS do UI.rotationFrames[i]:Hide() end
    UI.rotationFallback:Hide()
    local rotCtxOptions = GetRotationContextOptions(specData, heroTalent)
    -- Resolve the context to render: persist the user's pick across
    -- spec/hero re-renders when the new spec exposes it, otherwise fall
    -- back to the spec's first option (or the literal "General" when
    -- nothing matched at all — same fallback FindRotationByContext used
    -- before the dropdown existed).
    local rotContext = rotCtxOptions[1] or "General"
    if currentRotContext then
        for _, c in ipairs(rotCtxOptions) do
            if c == currentRotContext then rotContext = currentRotContext; break end
        end
    end
    -- Sync the persisted pick only when rendering a multi-context spec.
    -- Single-context specs are usually temporary transits (e.g. visiting
    -- a healer while still mostly in M+ on a DPS) and shouldn't clobber
    -- the user's last meaningful pick. Multi-context specs that lack the
    -- previous pick fall back to their own first option, and that IS a
    -- meaningful re-set worth persisting.
    local showRotCtx = #rotCtxOptions > 1
    if showRotCtx then currentRotContext = rotContext end
    if showRotCtx then
        UI.rotationCtxDropdown:SetupMenu(function(_, rootDescription)
            for _, ctx in ipairs(rotCtxOptions) do
                -- L[ctx] falls through to the raw ctx string when no
                -- translation exists (Locales.lua metatable __index).
                -- Common Wowhead contexts ("Single Target", "Multitarget",
                -- "Opener", …) have entries in each locale block; rare
                -- spec-specific ones ("Firestarter Examples") display
                -- as-is until someone adds them.
                rootDescription:CreateRadio(L[ctx],
                    function() return currentRotContext == ctx end,
                    function()
                        currentRotContext = ctx
                        ns:UpdateCompendium()
                    end,
                    ctx)
            end
        end)
        UI.rotationCtxDropdown:Show()
    else
        UI.rotationCtxDropdown:Hide()
    end

    local rotation = FindRotationByContext(specData.rotation, heroTalent, rotContext)
    if rotation then
        local textAreaWidth = (FRAME_WIDTH - 80) - 42
        local visibleStep = 0
        local yOffset = showRotCtx and -30 or 0
        local currentY = yOffset
        for _, step in ipairs(rotation.steps) do
            local stripped = StripConditionPrefix(step)
            visibleStep = visibleStep + 1
            if visibleStep > MAX_ROTATION_STEPS then break end
            local row = UI.rotationFrames[visibleStep]
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", UI.rotationContent, "TOPLEFT", 0, currentY)
            row:SetPoint("RIGHT", UI.rotationContent, "RIGHT", 0, 0)
            row.rank:SetText(visibleStep .. ".")
            row.icon:SetTexture(GetStepSpellIcon(step))
            row.stepText:SetText(FormatRotationStep(stripped))
            row.spellId = tonumber(stripped:match("{(%d+)}"))
            row.stepText:SetWidth(textAreaWidth)
            local textHeight = row.stepText:GetStringHeight() or 12
            local rowHeight = math.max(ROW_HEIGHT, textHeight + 6)
            row:SetHeight(rowHeight)
            row:Show()
            currentY = currentY - rowHeight
        end
        UI.rotationContent:SetHeight(math.abs(currentY))
        UI.rotationSection:Show()
    elseif specData.rotation and #specData.rotation > 0 then
        local yOffset = showRotCtx and -30 or 0
        UI.rotationFallback:ClearAllPoints()
        UI.rotationFallback:SetPoint("TOPLEFT", UI.rotationContent, "TOPLEFT", 4, yOffset - 4)
        UI.rotationFallback:SetText(L["empty.no_rotation_for"]:format(heroTalent))
        UI.rotationFallback:Show()
        UI.rotationContent:SetHeight(math.abs(yOffset) + 20)
        UI.rotationSection:Show()
    end
end

-- Helper: bind a talent button to copy a given exportString on click.
local function BindCopyClick(btn, exportString) -- luacheck: no unused
    btn:SetScript("OnClick", function()
        ns.ShowCopyPopup(exportString, btn)
    end)
end


-- Wowhead view of the standalone Talents tab: groups builds by hero
-- talent, one row per (hero × context) combination. Returns the y-cursor
-- after layout so the caller can size talentContent.
local function RenderWowheadTalentList(specData, yPos)
    local talents = specData.talents
    if not talents or #talents == 0 then
        UI.talentFallback:SetText(L["loadout_dock.no_talent_builds"])
        UI.talentFallback:ClearAllPoints()
        UI.talentFallback:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 4, -(yPos + 4))
        UI.talentFallback:Show()
        return yPos + 20
    end

    local heroOrder, heroBuilds = ns.GroupBuildsByHero(talents)
    local hdrIdx, rowIdx = 0, 0
    for _, hero in ipairs(heroOrder) do
        hdrIdx = hdrIdx + 1
        local hdr = UI._ensureTalentHeroHeader(hdrIdx)
        hdr.label:SetText(ns.FormatHeroHeaderText(hero))
        hdr.label:SetTextColor(1, 0.82, 0)
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 0, -yPos)
        hdr:SetPoint("RIGHT", UI.talentContent, "RIGHT", 0, 0)
        hdr:Show()
        yPos = yPos + TALENT_HERO_HEADER_HEIGHT

        for _, build in ipairs(heroBuilds[hero]) do
            rowIdx = rowIdx + 1
            local btn = UI._ensureTalentButton(rowIdx)
            if btn.heroIcon then btn.heroIcon:Hide() end
            btn.label:ClearAllPoints()
            btn.label:SetPoint("LEFT", 8, 0); btn.label:SetPoint("RIGHT", -8, 0)
            btn.label:SetText(ns.FormatBuildLabel(build))
            btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
            btn.label:SetTextColor(0.8, 0.8, 0.8)
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 8, -yPos)
            btn:SetPoint("RIGHT", UI.talentContent, "RIGHT", 0, 0)
            BindCopyClick(btn, build.exportString)
            btn:Show()
            yPos = yPos + TALENT_BTN_HEIGHT + TALENT_BTN_GAP
        end
        yPos = yPos + 4
    end
    return yPos
end

-- Archon view: rows are encounters (hero talent shown as a small icon
-- badge on the left). Sectioned: M+, Raid Heroic, Raid Mythic.
local function RenderArchonTalentList(class, spec, yPos)
    local archon = ns.GetArchonSpecData and ns.GetArchonSpecData(class, spec) or nil
    if not archon or not archon.contexts or not next(archon.contexts) then
        UI.talentFallback:SetText(L["loadout_dock.no_archon_builds"] or "No Archon builds available.")
        UI.talentFallback:ClearAllPoints()
        UI.talentFallback:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 4, -(yPos + 4))
        UI.talentFallback:Show()
        return yPos + 20
    end

    local groups = ns.GroupArchonContexts(archon)
    local hdrIdx, rowIdx = 0, 0

    local function emitSection(headerText, entries)
        if not entries or #entries == 0 then return end
        hdrIdx = hdrIdx + 1
        local hdr = UI._ensureTalentHeroHeader(hdrIdx)
        hdr.label:SetText(headerText)
        hdr.label:SetTextColor(1, 0.82, 0)
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 0, -yPos)
        hdr:SetPoint("RIGHT", UI.talentContent, "RIGHT", 0, 0)
        hdr:Show()
        yPos = yPos + TALENT_HERO_HEADER_HEIGHT

        for _, entry in ipairs(entries) do
            local ctx = entry.ctx
            if ctx.builds and ctx.builds[1] then
                local build = ctx.builds[1]
                rowIdx = rowIdx + 1
                local btn = UI._ensureTalentButton(rowIdx)

                local heroAtlas = build.heroTalent and ns.HERO_TALENT_ATLAS
                    and ns.HERO_TALENT_ATLAS[build.heroTalent]
                if btn.heroIcon then
                    if heroAtlas then
                        btn.heroIcon:SetAtlas(heroAtlas)
                        btn.heroIcon:Show()
                    else
                        btn.heroIcon:Hide()
                    end
                end
                btn.label:ClearAllPoints()
                local labelLeftOffset = heroAtlas and 24 or 8
                btn.label:SetPoint("LEFT", labelLeftOffset, 0)
                btn.label:SetPoint("RIGHT", -8, 0)
                local fullLabel = (ns.GetArchonEncounterLabel and ns.GetArchonEncounterLabel(ctx))
                    or ctx.encounterLabel or "Build"
                btn.label:SetText(fullLabel)
                local isActive = ns.BuildMatchesActive and ns.BuildMatchesActive(build)
                if isActive then
                    btn:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
                    btn.label:SetTextColor(0.3, 1, 0.3)
                else
                    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
                    btn.label:SetTextColor(0.8, 0.8, 0.8)
                end

                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 8, -yPos)
                btn:SetPoint("RIGHT", UI.talentContent, "RIGHT", 0, 0)
                BindCopyClick(btn, build.exportString)
                btn:Show()
                yPos = yPos + TALENT_BTN_HEIGHT + TALENT_BTN_GAP
            end
        end
        yPos = yPos + 4
    end

    -- Order: M+, Raid Heroic, Raid Mythic. Overview entry first inside each.
    local mplus = {}
    if groups.mplusOverview then mplus[#mplus + 1] = groups.mplusOverview end
    for _, e in ipairs(groups.mplusDungeons) do mplus[#mplus + 1] = e end
    emitSection("Mythic+", mplus)

    local heroic = {}
    if groups.raidOverviewHeroic then heroic[#heroic + 1] = groups.raidOverviewHeroic end
    for _, e in ipairs(groups.raidHeroicBosses) do heroic[#heroic + 1] = e end
    emitSection("Raid — Heroic", heroic)

    local mythic = {}
    if groups.raidOverviewMythic then mythic[#mythic + 1] = groups.raidOverviewMythic end
    for _, e in ipairs(groups.raidMythicBosses) do mythic[#mythic + 1] = e end
    emitSection("Raid — Mythic", mythic)

    return yPos
end

-- PvP view: rows are brackets, top class talent loadout per bracket.
-- One section header ("PvP"); one row per available bracket. Honor
-- talents are stored on the build but not rendered as separate rows
-- here — Apply takes care of them via ns.ApplyPvpHonorTalents.
local function RenderPvPTalentList(class, spec, yPos)
    if not ns.GetPvPBracketsWithData then
        UI.talentFallback:SetText(L["pvp.no_builds"] or "No PvP builds available.")
        UI.talentFallback:ClearAllPoints()
        UI.talentFallback:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 4, -(yPos + 4))
        UI.talentFallback:Show()
        return yPos + 20
    end
    local brackets = ns.GetPvPBracketsWithData(class, spec)
    if not brackets or #brackets == 0 then
        UI.talentFallback:SetText(L["pvp.no_builds"] or "No PvP builds available.")
        UI.talentFallback:ClearAllPoints()
        UI.talentFallback:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 4, -(yPos + 4))
        UI.talentFallback:Show()
        return yPos + 20
    end

    local hdrIdx, rowIdx = 0, 0
    hdrIdx = hdrIdx + 1
    local hdr = UI._ensureTalentHeroHeader(hdrIdx)
    hdr.label:SetText("PvP")
    hdr.label:SetTextColor(1, 0.82, 0)
    hdr:ClearAllPoints()
    hdr:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 0, -yPos)
    hdr:SetPoint("RIGHT", UI.talentContent, "RIGHT", 0, 0)
    hdr:Show()
    yPos = yPos + TALENT_HERO_HEADER_HEIGHT

    for _, bracketKey in ipairs(brackets) do
        local data = ns.GetPvPBuilds(class, spec, bracketKey)
        if data and data.builds and data.builds[1] then
            local bracketName = (ns.GetPvPBracketName and ns.GetPvPBracketName(bracketKey)) or bracketKey
            local variants = ns.GetPvPBuildVariants and ns.GetPvPBuildVariants(data)
                or { { hero = data.builds[1].heroTalent, build = data.builds[1] } }
            local multiVariant = #variants > 1

            for _, v in ipairs(variants) do
                local build = v.build
                rowIdx = rowIdx + 1
                local btn = UI._ensureTalentButton(rowIdx)
                -- Hero atlas icon only when surfacing multiple variants
                -- so single-bracket rows keep their existing chrome.
                local heroAtlas = multiVariant and v.hero and ns.HERO_TALENT_ATLAS
                    and ns.HERO_TALENT_ATLAS[v.hero]
                if btn.heroIcon then
                    if heroAtlas then
                        btn.heroIcon:SetAtlas(heroAtlas)
                        btn.heroIcon:Show()
                    else
                        btn.heroIcon:Hide()
                    end
                end
                btn.label:ClearAllPoints()
                local labelLeftOffset = heroAtlas and 24 or 8
                btn.label:SetPoint("LEFT", labelLeftOffset, 0)
                btn.label:SetPoint("RIGHT", -8, 0)
                local label
                if multiVariant then
                    label = bracketName .. " — " .. (v.hero or "—")
                    if v.altIndex then
                        local suffix = v.altIndex == 2
                            and (L["loadout.alt"] or "alt")
                            or string.format(L["loadout.alt_n"] or "alt %d", v.altIndex - 1)
                        label = label .. " |cff9a9a9a(" .. suffix .. ")|r"
                    end
                else
                    label = bracketName
                end
                btn.label:SetText(label)
                local isActive = ns.BuildMatchesActive and ns.BuildMatchesActive({ exportString = build.exportString })
                if isActive then
                    btn:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
                    btn.label:SetTextColor(0.3, 1, 0.3)
                else
                    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
                    btn.label:SetTextColor(0.8, 0.8, 0.8)
                end
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 8, -yPos)
                btn:SetPoint("RIGHT", UI.talentContent, "RIGHT", 0, 0)
                BindCopyClick(btn, build.exportString)
                btn:Show()
                yPos = yPos + TALENT_BTN_HEIGHT + TALENT_BTN_GAP
            end
        end
    end
    yPos = yPos + 4

    return yPos
end

function ns:UpdateCompendiumAllTalents(specData, classFile, specKey)
    for _, b in ipairs(UI.talentButtons) do b:Hide() end
    for _, h in ipairs(UI.talentHeroHeaders) do h:Hide() end
    UI.talentFallback:Hide()

    -- Reset source on spec change so users land on Wowhead by default
    -- when browsing a new spec, matching the BiS / Enhancements tabs.
    local talentSpecKey = (classFile or "") .. "-" .. (specKey or "")
    if talentSpecKey ~= lastTalentSpecKey then
        UI.talentSource = "wowhead"
        lastTalentSpecKey = talentSpecKey
    end

    -- Source dropdown is the first row of talentContent. Archon may not
    -- cover every spec, so its option drops out when missing. PvP always
    -- shows so users can discover the feature; RenderPvPTalentList
    -- handles the "no data" copy inline.
    local archonAvailable = classFile and specKey
        and ns.GetArchonSpecData and ns.GetArchonSpecData(classFile, specKey) ~= nil
    if not archonAvailable and UI.talentSource == "archon" then
        UI.talentSource = "wowhead"
    end
    if UI._refreshTalentSourceDropdown then
        UI._refreshTalentSourceDropdown(archonAvailable)
    end

    UI.talentSourceDropdown:ClearAllPoints()
    UI.talentSourceDropdown:SetPoint("TOPLEFT", UI.talentContent, "TOPLEFT", 0, 0)
    UI.talentSourceDropdown:SetPoint("TOPRIGHT", UI.talentContent, "TOPRIGHT", 0, 0)
    UI.talentSourceDropdown:Show()

    local yPos = 32 -- leave room for the dropdown row (DROPDOWN_HEIGHT 26 + 6 gap)
    if UI.talentSource == "archon" and archonAvailable then
        yPos = RenderArchonTalentList(classFile, specKey, yPos)
    elseif UI.talentSource == "pvp" then
        -- RenderPvPTalentList itself handles the no-data case and
        -- writes the talentFallback ("No PvP builds available."), so
        -- we route through it regardless of whether PvP data exists.
        yPos = RenderPvPTalentList(classFile, specKey, yPos)
    else
        yPos = RenderWowheadTalentList(specData, yPos)
    end

    UI.talentContent:SetHeight(yPos)
    UI.talentSection:Show()
end

-- Compendium enchant/gem renderers consume the slim PvP shape via
-- ns.BuildPvPEnchantsRows / ns.BuildPvPGemsRecord (PvPData.lua) — the
-- same builders the docked panel uses, so slot ordering and field
-- mapping stay in one place.
local function BuildPvPEnchantsSynthetic()
    if not ns.BuildPvPEnchantsRows then return nil end
    return ns.BuildPvPEnchantsRows(selectedClass, selectedSpec)
end

local function BuildPvPGemsSynthetic()
    if not ns.BuildPvPGemsRecord then return nil end
    return ns.BuildPvPGemsRecord(selectedClass, selectedSpec)
end

function ns:UpdateCompendiumEnchants()
    if not GEAR_DATA then return end
    local gearData = GEAR_DATA[selectedClass] and GEAR_DATA[selectedClass][selectedSpec]

    UI.enchantPvpFallback:Hide()

    -- Reset source on spec change to match the BiS / Talents tabs —
    -- Wowhead is the default landing source when browsing a new spec.
    local enhancementsSpecKey = (selectedClass or "") .. "-" .. (selectedSpec or "")
    if enhancementsSpecKey ~= lastEnhancementsSpecKey then
        currentEnhancementsSource = "Wowhead"
        lastEnhancementsSpecKey = enhancementsSpecKey
    end

    local pvpEnchants = BuildPvPEnchantsSynthetic()
    local pvpGems = BuildPvPGemsSynthetic()
    local hasPvP = pvpEnchants ~= nil or pvpGems ~= nil
    local hasWowhead = gearData and (gearData.enchants or gearData.gems)
    if not hasWowhead and not hasPvP then return end

    -- Wowhead falls back to PvP when missing, but PvP stays sticky —
    -- selecting it on a spec with no Murlok data shows a "no data" line
    -- below so users see the dropdown choice was honoured.
    if currentEnhancementsSource == "Wowhead" and not hasWowhead then currentEnhancementsSource = "PvP" end

    -- PvP always appears as a dropdown option for discoverability, so the
    -- dropdown shows whenever Wowhead exists (the second slot is PvP).
    local showSourceDropdown = hasWowhead and UI.enhancementsSourceDropdown
    if showSourceDropdown then
        UI.enhancementsSourceDropdown:SetupMenu(function(_, rootDescription)
            for _, src in ipairs({ "Wowhead", "PvP" }) do
                rootDescription:CreateRadio(ns.ENH_SOURCE_LABELS[src] or src,
                    function() return currentEnhancementsSource == src end,
                    function()
                        currentEnhancementsSource = src
                        ns:UpdateCompendiumEnchants()
                        ns:LayoutCompendium()
                    end,
                    src)
            end
        end)
        UI.enhancementsSourceDropdown:Show()
    elseif UI.enhancementsSourceDropdown then
        UI.enhancementsSourceDropdown:Hide()
    end

    -- Resolve which enchants/gems to render based on the active source.
    local activeEnchants, activeGems
    if currentEnhancementsSource == "PvP" then
        activeEnchants = pvpEnchants
        activeGems = pvpGems
    else
        activeEnchants = gearData and gearData.enchants
        activeGems = gearData and gearData.gems
    end

    -- Source dropdown now lives ABOVE the Enchants section (positioned
    -- in LayoutCompendium), so enchant rows start at the top of the
    -- content area regardless of dropdown visibility.
    local enchantBaseY = 0

    -- PvP-with-no-enchants fallback (e.g. Aug Evoker has gems but no
    -- PvP enchants). Render a placeholder line in the enchant section
    -- so the user sees their source choice acknowledged.
    local pvpEnchantsMissing = currentEnhancementsSource == "PvP" and not activeEnchants
    if pvpEnchantsMissing and showSourceDropdown then
        for i = 1, MAX_ENCHANT_ROWS do UI.enchantRows[i]:Hide() end
        local msg = activeGems
            and (L["pvp.no_enchants"] or "No PvP enchants for this spec yet.")
            or  (L["pvp.no_enchant_gem_data"] or "No PvP enchant/gem data for this spec yet.")
        UI.enchantPvpFallback:SetText(msg)
        UI.enchantPvpFallback:ClearAllPoints()
        UI.enchantPvpFallback:SetPoint("TOPLEFT", UI.enchantContent, "TOPLEFT", 4, -4)
        UI.enchantPvpFallback:Show()
        UI.enchantContent:SetHeight(20)
        UI.enchantSection:Show()
    end

    if activeEnchants then
        for i = 1, MAX_ENCHANT_ROWS do UI.enchantRows[i]:Hide() end
        -- Each entry renders as one row with stacked best / alt
        -- sub-rows; row height grows to 2x when an alternate exists.
        -- Each sub-row carries its own itemId so hovers and clicks
        -- target the right item.
        local count = math.min(#activeEnchants, MAX_ENCHANT_ROWS)
        local yOff = enchantBaseY
        for i = 1, count do
            local e = activeEnchants[i]
            local row = UI.enchantRows[i]
            row.slot:SetText(e.slot or "")
            SetRowIcon(row, e.best and e.best.itemId, e.best and e.best.spellId)

            local bestName = StripEnchantPrefix(GetItemDisplayName(e.best))
            row.bestSub.text:SetText(FormatItem(e.best, bestName))
            row.bestSub.itemId = e.best and e.best.itemId
            row.bestSub.spellId = e.best and e.best.spellId
            row.bestSub:Show()

            local rowH = ROW_HEIGHT
            if e.alternate then
                local altName = StripEnchantPrefix(GetItemDisplayName(e.alternate))
                row.altSub.text:SetText(FormatItem(e.alternate, altName))
                row.altSub.itemId = e.alternate.itemId
                row.altSub.spellId = e.alternate.spellId
                row.altSub:Show()
                rowH = ROW_HEIGHT * 2
            else
                row.altSub:Hide()
            end

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", UI.enchantContent, "TOPLEFT", 0, yOff)
            row:SetPoint("RIGHT", UI.enchantContent, "RIGHT", 0, 0)
            row:SetHeight(rowH)
            yOff = yOff - rowH
            row:Show()
        end
        UI.enchantContent:SetHeight(math.abs(yOff))
        UI.enchantSection:Show()
    end

    if activeGems then
        for i = 1, MAX_GEM_ROWS do UI.gemRows[i]:Hide() end
        local gIdx = 0
        if activeGems.primary then
            gIdx = gIdx + 1
            local row = UI.gemRows[gIdx]
            row.label:SetText(L["gem.primary"])
            row.name:SetText(FormatItem(activeGems.primary))
            row.itemId = activeGems.primary.itemId
            SetRowIcon(row, activeGems.primary.itemId)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", UI.gemContent, "TOPLEFT", 0, 0)
            row:SetPoint("RIGHT", UI.gemContent, "RIGHT", 0, 0)
            row:Show()
        end
        if activeGems.secondary then
            for _, gem in ipairs(activeGems.secondary) do
                gIdx = gIdx + 1
                if gIdx > MAX_GEM_ROWS then break end
                local row = UI.gemRows[gIdx]
                row.label:SetText(L["gem.secondary"])
                row.name:SetText(FormatItem(gem))
                row.itemId = gem.itemId
                SetRowIcon(row, gem.itemId)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", UI.gemContent, "TOPLEFT", 0, -(gIdx - 1) * ROW_HEIGHT)
                row:SetPoint("RIGHT", UI.gemContent, "RIGHT", 0, 0)
                row:Show()
            end
        end
        UI.gemContent:SetHeight(gIdx * ROW_HEIGHT)
        UI.gemSection:Show()
    end
end

function ns:UpdateCompendiumConsumables()
    if not GEAR_DATA then return end
    local gearData = GEAR_DATA[selectedClass] and GEAR_DATA[selectedClass][selectedSpec]
    if not gearData or not gearData.consumables then return end
    for i = 1, MAX_CONSUM_ROWS do UI.consumRows[i]:Hide() end
    local idx = 0
    for _, key in ipairs(CONSUMABLE_ORDER) do
        local c = gearData.consumables[key]
        if c then
            idx = idx + 1
            if idx > MAX_CONSUM_ROWS then break end
            local row = UI.consumRows[idx]
            row.label:SetText(CONSUMABLE_LABELS[key] or key)
            row.name:SetText(FormatItem(c))
            row.itemId = c.itemId
            SetRowIcon(row, c.itemId)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", UI.consumContent, "TOPLEFT", 0, -(idx - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", UI.consumContent, "RIGHT", 0, 0)
            row:Show()
        end
    end
    UI.consumContent:SetHeight(idx * ROW_HEIGHT)
    UI.consumSection:Show()
end

function ns:UpdateCompendiumTrinkets()
    if not GEAR_DATA then return end
    local gearData = GEAR_DATA[selectedClass] and GEAR_DATA[selectedClass][selectedSpec]
    if not gearData or not gearData.trinkets then return end
    for i = 1, MAX_TRINKET_ROWS do UI.trinketRows[i]:Hide() end

    -- Collect available contexts
    local contexts = {}
    local seen = {}
    for _, t in ipairs(gearData.trinkets) do
        if t.contexts then
            for _, ctx in ipairs(t.contexts) do
                if not seen[ctx] then
                    seen[ctx] = true
                    contexts[#contexts + 1] = ctx
                end
            end
        end
    end

    local showCtxDropdown = #contexts > 1
    if showCtxDropdown then
        -- Validate current selection still exists
        local found = currentTrinketContext == "All"
        if not found then
            for _, c in ipairs(contexts) do
                if c == currentTrinketContext then found = true; break end
            end
        end
        if not found then currentTrinketContext = "All" end

        local allOptions = { "All" }
        for _, c in ipairs(contexts) do allOptions[#allOptions + 1] = c end

        UI.trinketCtxDropdown:SetupMenu(function(_, rootDescription)
            for _, ctx in ipairs(allOptions) do
                local label = ctx == "All" and "All" or (CONTEXT_LABELS[ctx] or ctx)
                rootDescription:CreateRadio(label,
                    function() return currentTrinketContext == ctx end,
                    function()
                        currentTrinketContext = ctx
                        ns:UpdateCompendium()
                    end,
                    ctx)
            end
        end)
        UI.trinketCtxDropdown:Show()
    else
        UI.trinketCtxDropdown:Hide()
        currentTrinketContext = "All"
    end

    -- Filter by context
    local filtered = {}
    local contextKey = currentTrinketContext ~= "All" and currentTrinketContext or nil
    for _, t in ipairs(gearData.trinkets) do
        if not contextKey then
            filtered[#filtered + 1] = t
        elseif t.contexts then
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
    local idx = 0
    for _, t in ipairs(filtered) do
        idx = idx + 1
        if idx > MAX_TRINKET_ROWS then break end
        local row = UI.trinketRows[idx]
        local tierColor = TIER_COLORS[t.tier]
        row.tier:SetText(t.tier or "?")
        row.tier:SetTextColor(tierColor and tierColor.r or 1, tierColor and tierColor.g or 1, tierColor and tierColor.b or 1)
        row.name:SetText(FormatItem({ itemId = t.itemId, name = t.name }))
        row.itemId = t.itemId
        row.bonusIDs = t.bonusIDs
        row.source:SetText(t.source or "")
        SetRowIcon(row, t.itemId)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", UI.trinketContent, "TOPLEFT", 0, yOffset - (idx - 1) * ROW_HEIGHT)
        row:SetPoint("RIGHT", UI.trinketContent, "RIGHT", 0, 0)
        row:Show()
    end
    UI.trinketContent:SetHeight((showCtxDropdown and 30 or 0) + idx * ROW_HEIGHT)
    UI.trinketSection:Show()
end

function ns:UpdateCompendiumCrafts()
    if not GEAR_DATA then return end
    local gearData = GEAR_DATA[selectedClass] and GEAR_DATA[selectedClass][selectedSpec]
    if not gearData or not gearData.crafts then return end
    for i = 1, MAX_CRAFT_ROWS do UI.craftRows[i]:Hide() end
    local idx = 0

    local function AddCraftHeader(label)
        idx = idx + 1
        if idx > MAX_CRAFT_ROWS then return end
        local row = UI.craftRows[idx]
        row.order:SetText("")
        row.name:SetText("|cffffd100" .. label .. "|r")
        row.itemId = nil
        if row.icon then row.icon:Hide() end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", UI.craftContent, "TOPLEFT", 0, -(idx - 1) * ROW_HEIGHT)
        row:SetPoint("RIGHT", UI.craftContent, "RIGHT", 0, 0)
        row:Show()
    end

    -- Each craft renders as ONE row with "item + embellishment"
    -- combined in the label and the embellishment surfaced via the
    -- tooltip's "Embellishment:" line (handled by MakeItemRow's
    -- OnEnter when row.embItemId is set). Mirrors the docked panel.
    local function AddCrafts(list, header)
        if not list or #list == 0 then return end
        AddCraftHeader(header)
        for _, c in ipairs(list) do
            idx = idx + 1
            if idx > MAX_CRAFT_ROWS then return end
            local row = UI.craftRows[idx]
            row.order:SetText("")
            local text = FormatItem(c.item)
            if c.embellishment then
                text = text .. " + " .. FormatItem(c.embellishment)
            end
            row.name:SetText(text)
            row.itemId = c.item and c.item.itemId
            row.bonusIDs = c.item and c.item.bonusIDs
            row.embItemId = c.embellishment and c.embellishment.itemId or nil
            row.embName = c.embellishment and c.embellishment.name or nil
            SetRowIcon(row, c.item and c.item.itemId)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", UI.craftContent, "TOPLEFT", 0, -(idx - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", UI.craftContent, "RIGHT", 0, 0)
            row:Show()
        end
    end

    AddCrafts(gearData.crafts.earlyCrafts, L["craft.early"])
    AddCrafts(gearData.crafts.bisCrafts, L["craft.bis"])
    UI.craftContent:SetHeight(idx * ROW_HEIGHT)
    UI.craftSection:Show()
end

local function BuildPvPBisSyntheticTabs()
    if not ns.BuildPvPBisTabs then return nil end
    return ns.BuildPvPBisTabs(selectedClass, selectedSpec)
end

function ns:UpdateCompendiumBis()
    for i = 1, MAX_BIS_ROWS do UI.bisRows[i]:Hide() end

    -- Reset source/tab when browsing a different spec
    local bisSpecKey = (selectedClass or "") .. "-" .. (selectedSpec or "")
    if bisSpecKey ~= lastBisSpecKey then
        currentBisSource = "Wowhead"
        currentBisTab = nil -- will be set to first available tab below
        lastBisSpecKey = bisSpecKey
    end

    local wowheadBis = GEAR_DATA and GEAR_DATA[selectedClass] and GEAR_DATA[selectedClass][selectedSpec]
        and GEAR_DATA[selectedClass][selectedSpec].bisGear
    local ivSpecData = ns.GetIcyVeinsSpecData and ns:GetIcyVeinsSpecData(selectedClass, selectedSpec)
    local ivBis = ivSpecData and ivSpecData.bisGear
    local pvpBis = BuildPvPBisSyntheticTabs()
    local hasWH = wowheadBis and #wowheadBis > 0
    local hasIV = ivBis and #ivBis > 0
    local hasPvP = pvpBis ~= nil

    UI.bisPvpFallback:Hide()
    if not hasWH and not hasIV and not hasPvP then return end

    -- Auto-correct source if saved one has no data. Wowhead/Icy Veins
    -- still fall back to a sibling, but PvP stays sticky — selecting it
    -- on a spec without Murlok data shows a "no data" line so users see
    -- the dropdown choice was honoured.
    if currentBisSource == "Icy Veins" and not hasIV then currentBisSource = "Wowhead" end
    if currentBisSource == "Wowhead" and not hasWH then currentBisSource = hasIV and "Icy Veins" or "PvP" end

    -- Source dropdown — PvP always appears as a third option for
    -- discoverability, even when Murlok hasn't sampled this spec. Each
    -- entry carries the brand icon (ns.BIS_SOURCE_LABELS) as visible
    -- source attribution.
    local availableSources = {}
    if hasWH then availableSources[#availableSources + 1] = "Wowhead" end
    if hasIV then availableSources[#availableSources + 1] = "Icy Veins" end
    availableSources[#availableSources + 1] = "PvP"
    local showSourceDropdown = #availableSources > 1
    if showSourceDropdown then
        UI.bisSourceDropdown:SetupMenu(function(_, rootDescription)
            for _, src in ipairs(availableSources) do
                rootDescription:CreateRadio(ns.BIS_SOURCE_LABELS[src] or src,
                    function() return currentBisSource == src end,
                    function()
                        currentBisSource = src
                        currentBisTab = nil -- reset to first available tab
                        ns:UpdateCompendiumBis()
                        ns:LayoutCompendium()
                    end,
                    src)
            end
        end)
        UI.bisSourceDropdown:Show()
    else
        UI.bisSourceDropdown:Hide()
    end

    -- Determine active bis gear from selected source. When PvP is
    -- selected with no Murlok data, route to the PvP-no-data fallback
    -- path below — DO NOT silently fall back to Wowhead/Icy Veins.
    local pvpNoData = currentBisSource == "PvP" and not hasPvP
    local activeBis
    if currentBisSource == "PvP" then
        activeBis = pvpBis
    elseif currentBisSource == "Icy Veins" then
        activeBis = ivBis
    else
        activeBis = wowheadBis
    end
    if not pvpNoData and (not activeBis or #activeBis == 0) then
        activeBis = wowheadBis or ivBis or pvpBis
    end

    if pvpNoData then
        local yOffset = showSourceDropdown and -30 or 0
        UI.bisPvpFallback:SetText(L["pvp.no_gear_data"]
            or "No PvP gear data for this spec yet.")
        UI.bisPvpFallback:ClearAllPoints()
        UI.bisPvpFallback:SetPoint("TOPLEFT", UI.bisContent, "TOPLEFT", 4, yOffset - 4)
        UI.bisPvpFallback:Show()
        UI.bisTabDropdown:Hide()
        UI.bisContent:SetHeight(math.abs(yOffset) + 20)
        UI.bisSection:Show()
        return
    end

    -- Resolve current tab — default to first available
    local validTab = false
    if currentBisTab then
        for _, tab in ipairs(activeBis) do
            if tab.label == currentBisTab then validTab = true; break end
        end
    end
    if not validTab then currentBisTab = activeBis[1].label end

    -- Tab dropdown when multiple tabs exist
    local showTabDropdown = #activeBis > 1
    if showTabDropdown then
        UI.bisTabDropdown:SetupMenu(function(_, rootDescription)
            for _, tab in ipairs(activeBis) do
                rootDescription:CreateRadio(tab.label,
                    function() return currentBisTab == tab.label end,
                    function()
                        currentBisTab = tab.label
                        ns:UpdateCompendiumBis()
                        ns:LayoutCompendium()
                    end,
                    tab.label)
            end
        end)
        UI.bisTabDropdown:Show()
    else
        UI.bisTabDropdown:Hide()
    end

    -- Find the selected tab's slots
    local selectedSlots = nil
    for _, tab in ipairs(activeBis) do
        if tab.label == currentBisTab then
            selectedSlots = tab.slots
            break
        end
    end

    local yOffset = 0
    if showSourceDropdown then yOffset = yOffset - 30 end
    if showTabDropdown then
        UI.bisTabDropdown:ClearAllPoints()
        UI.bisTabDropdown:SetPoint("TOPLEFT", 0, yOffset)
        UI.bisTabDropdown:SetPoint("TOPRIGHT", 0, yOffset)
        yOffset = yOffset - 30
    end

    local idx = 0
    for _, g in ipairs(selectedSlots) do
        idx = idx + 1
        if idx > MAX_BIS_ROWS then break end
        local row = UI.bisRows[idx]
        row.slot:SetText(g.slot or "")
        row.name:SetText(FormatItem(g.item))
        row.source:SetText(g.source or "")
        row.sourceText = g.source or nil -- exposed via tooltip for full string
        row.itemId = g.item and g.item.itemId
        row.bonusIDs = g.item and g.item.bonusIDs
        SetRowIcon(row, g.item and g.item.itemId)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", UI.bisContent, "TOPLEFT", 0, yOffset - (idx - 1) * ROW_HEIGHT)
        row:SetPoint("RIGHT", UI.bisContent, "RIGHT", 0, 0)
        row:Show()
    end
    UI.bisContent:SetHeight(math.abs(yOffset) + idx * ROW_HEIGHT)
    UI.bisSection:Show()
end

-------------------------------------------------------------------------------
-- Layout
-------------------------------------------------------------------------------

function ns:LayoutCompendium()
    local y = 0

    local function LayoutSection(section, collapsed, content, contentHeight)
        if not section:IsShown() then return y end
        section:ClearAllPoints()
        section:SetPoint("TOPLEFT", UI.scrollChild, "TOPLEFT", INSET_PAD, y)
        section:SetPoint("RIGHT", UI.scrollChild, "RIGHT", -INSET_PAD, 0)
        local h = SECTION_HEADER_HEIGHT
        if not collapsed then h = h + contentHeight + 4 end
        section:SetHeight(h)
        y = y - h - 4
        return y
    end

    if UI.emptyText:IsShown() then
        UI.scrollChild:SetHeight(120)
        return
    end

    if activeTab == "guide" then
        local statH = 0
        if UI.statCtxDropdown:IsShown() then statH = statH + 30 end
        for i = 1, MAX_STATS do if UI.statFrames[i]:IsShown() then statH = statH + ROW_HEIGHT end end
        if UI.statPvpFallback and UI.statPvpFallback:IsShown() then statH = statH + 20 end
        LayoutSection(UI.statSection, UI.statCollapsed, UI.statContent, statH)
        local talentH = 0
        -- Iterate the actual pool (which can grow past MAX_TALENT_BUTTONS
        -- via _ensureTalentButton). The Wowhead-only Guide path doesn't
        -- usually need extra rows, but this stays consistent with the
        -- Talents-tab path below and protects against silent clipping.
        for i = 1, #UI.talentButtons do if UI.talentButtons[i]:IsShown() then talentH = talentH + TALENT_BTN_HEIGHT + TALENT_BTN_GAP end end
        if UI.talentFallback:IsShown() then talentH = 20 end
        LayoutSection(UI.talentSection, UI.talentCollapsed, UI.talentContent, talentH)
        local rotH = 0
        if UI.rotationCtxDropdown:IsShown() then rotH = rotH + 30 end
        for i = 1, MAX_ROTATION_STEPS do if UI.rotationFrames[i]:IsShown() then rotH = rotH + UI.rotationFrames[i]:GetHeight() end end
        if UI.rotationFallback:IsShown() then rotH = rotH + 20 end
        LayoutSection(UI.rotationSection, UI.rotationCollapsed, UI.rotationContent, rotH)
    elseif activeTab == "talents" then
        local talentH = 0
        if UI.talentSourceDropdown and UI.talentSourceDropdown:IsShown() then talentH = talentH + 32 end
        -- Iterate by actual pool length — the Archon view grows the
        -- pool well past the initial MAX_* allocation.
        for i = 1, #UI.talentHeroHeaders do if UI.talentHeroHeaders[i]:IsShown() then talentH = talentH + TALENT_HERO_HEADER_HEIGHT + 4 end end
        for i = 1, #UI.talentButtons do if UI.talentButtons[i]:IsShown() then talentH = talentH + TALENT_BTN_HEIGHT + TALENT_BTN_GAP end end
        if UI.talentFallback:IsShown() then talentH = 20 end
        LayoutSection(UI.talentSection, UI.talentCollapsed, UI.talentContent, talentH)
    elseif activeTab == "bis" then
        local bisH = 0
        for i = 1, MAX_BIS_ROWS do if UI.bisRows[i]:IsShown() then bisH = bisH + ROW_HEIGHT end end
        if UI.bisPvpFallback and UI.bisPvpFallback:IsShown() then
            -- Source dropdown is 30px and the fallback line replaces the row stack —
            -- include both so the section's bottom edge isn't above the fallback text.
            if UI.bisSourceDropdown and UI.bisSourceDropdown:IsShown() then bisH = bisH + 30 end
            bisH = bisH + 20
        end
        LayoutSection(UI.bisSection, UI.bisCollapsed, UI.bisContent, bisH)
    elseif activeTab == "trinkets" then
        local trinketH = 0
        if UI.trinketCtxDropdown:IsShown() then trinketH = trinketH + 30 end
        for i = 1, MAX_TRINKET_ROWS do if UI.trinketRows[i]:IsShown() then trinketH = trinketH + ROW_HEIGHT end end
        LayoutSection(UI.trinketSection, UI.trinketCollapsed, UI.trinketContent, trinketH)
    elseif activeTab == "enhancements" then
        -- Source dropdown sits ABOVE the enchants section (parented to
        -- scrollChild) so it stays visible even when the section is
        -- hidden or collapsed.
        if UI.enhancementsSourceDropdown and UI.enhancementsSourceDropdown:IsShown() then
            UI.enhancementsSourceDropdown:ClearAllPoints()
            UI.enhancementsSourceDropdown:SetPoint("TOPLEFT", UI.scrollChild, "TOPLEFT", INSET_PAD, y)
            UI.enhancementsSourceDropdown:SetPoint("RIGHT", UI.scrollChild, "RIGHT", -INSET_PAD, 0)
            y = y - 30
        end
        local enchH = 0
        -- Each enchant row is 1× or 2× ROW_HEIGHT depending on whether
        -- it has an alternate sub-row, so read each row's actual height
        -- instead of multiplying by a constant.
        for i = 1, MAX_ENCHANT_ROWS do
            if UI.enchantRows[i]:IsShown() then
                enchH = enchH + UI.enchantRows[i]:GetHeight()
            end
        end
        if UI.enchantPvpFallback and UI.enchantPvpFallback:IsShown() then enchH = enchH + 20 end
        LayoutSection(UI.enchantSection, UI.enchantCollapsed, UI.enchantContent, enchH)
        local gemH = 0
        for i = 1, MAX_GEM_ROWS do if UI.gemRows[i]:IsShown() then gemH = gemH + ROW_HEIGHT end end
        LayoutSection(UI.gemSection, UI.gemCollapsed, UI.gemContent, gemH)
        local consumH = 0
        for i = 1, MAX_CONSUM_ROWS do if UI.consumRows[i]:IsShown() then consumH = consumH + ROW_HEIGHT end end
        LayoutSection(UI.consumSection, UI.consumCollapsed, UI.consumContent, consumH)
    elseif activeTab == "crafts" then
        local craftH = 0
        for i = 1, MAX_CRAFT_ROWS do if UI.craftRows[i]:IsShown() then craftH = craftH + ROW_HEIGHT end end
        LayoutSection(UI.craftSection, UI.craftCollapsed, UI.craftContent, craftH)
    end

    UI.scrollChild:SetHeight(math.abs(y) + 20)
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

function ns:OpenCompendium()
    InitFrame()

    if UI.frame:IsShown() then
        UI.frame:Hide()
        return
    end

    -- Restore saved state or default to player's class/spec
    if not selectedClass then
        if ClassCodexDB and ClassCodexDB.compendiumClass and ClassCodexDB.compendiumSpec then
            selectedClass = ClassCodexDB.compendiumClass
            selectedSpec = ClassCodexDB.compendiumSpec
            selectedHero = ClassCodexDB.compendiumHero
        else
            local _, classToken = UnitClass("player")
            selectedClass = classToken
            local specIndex = GetSpecialization()
            if specIndex and SPEC_KEYS[classToken] then
                selectedSpec = SPEC_KEYS[classToken][specIndex]
            else
                selectedSpec = SPEC_KEYS[classToken] and SPEC_KEYS[classToken][1]
            end
        end
        -- Auto-select first hero if none saved
        if not selectedHero and selectedSpec then
            local specData = DATA[selectedClass] and DATA[selectedClass][selectedSpec]
            if specData then
                local opts = GetHeroTalentOptions(specData)
                selectedHero = opts[1] or "All"
            end
        end
    end

    -- Restore saved tab
    if ClassCodexDB and ClassCodexDB.compendiumTab then
        activeTab = ClassCodexDB.compendiumTab
        for i, data in ipairs(UI.TAB_DATA) do
            if data.key == activeTab then
                PanelTemplates_SetTab(UI.frame, i)
                break
            end
        end
    end

    SetupClassDropdown()
    SetupSpecDropdown()
    SetupHeroDropdown()

    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    UI.frame:Show()
    ns:UpdateCompendium()
end
