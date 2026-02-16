local _, ns = ...

local DB = ns.TrackerDB
local ItemsData = ns.TrackerItemsData or {}
ns.TrackerItemsData = ItemsData

local ITEM_EQUIP_FIRST = INVSLOT_FIRST_EQUIPPED or 1
local ITEM_EQUIP_LAST = INVSLOT_LAST_EQUIPPED or 19

local ITEM_STATE_HIDDEN = "hidden"

local ITEM_STATE_TRACKER1 = "tracker1"
local ITEM_STATE_TRACKER2 = "tracker2"

local RACIAL_NAME_FALLBACK = "Racial"
local GENERAL_NAME_FALLBACK = "General"

local racialSpellCache = nil

local function MakeEntry(kind, id)
    return {
        kind = kind,
        id = id,
    }
end

local function IsSpellEntry(entry)
    return entry and entry.kind == "spell"
end

local function EntriesEqual(a, b)
    return a and b and a.kind == b.kind and a.id == b.id
end

local function GetSpellNameByID(spellID)
    if C_Spell and C_Spell.GetSpellName then
        return C_Spell.GetSpellName(spellID)
    end
    if GetSpellInfo then
        local name = GetSpellInfo(spellID)
        return name
    end
    return nil
end

local function IsPassiveSpellID(spellID)
    if C_Spell and C_Spell.IsSpellPassive then
        return C_Spell.IsSpellPassive(spellID)
    end
    if IsPassiveSpell then
        return IsPassiveSpell(spellID)
    end
    return false
end

local function IsRacialSkillLineName(name)
    if not name or name == "" then
        return false
    end
    local racialAbilities = _G and _G.RACIAL_ABILITIES or nil
    if racialAbilities and name == racialAbilities then
        return true
    end
    if name == RACIAL_NAME_FALLBACK then
        return true
    end
    if name:lower():find(RACIAL_NAME_FALLBACK:lower(), 1, true) then
        return true
    end
    return false
end

local function IsGeneralSkillLineName(name)
    if not name or name == "" then
        return false
    end
    local generalLabel = _G and _G.GENERAL or nil
    if generalLabel and name == generalLabel then
        return true
    end
    local generalTab = _G and _G.SPELLBOOK_GENERAL_TAB or nil
    if generalTab and name == generalTab then
        return true
    end
    if name == GENERAL_NAME_FALLBACK then
        return true
    end
    if name:lower():find(GENERAL_NAME_FALLBACK:lower(), 1, true) then
        return true
    end
    return false
end

local function IsRacialOrGeneralSkillLineName(name)
    return IsRacialSkillLineName(name) or IsGeneralSkillLineName(name)
end

local function GetRacialSpellIDsFromSpellBook()
    if racialSpellCache then
        return racialSpellCache
    end

    local ids = {}
    if not C_SpellBook or not C_SpellBook.GetNumSpellBookSkillLines or not C_SpellBook.GetSpellBookSkillLineInfo then
        return ids
    end

    local spellBank = Enum and Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or nil

    local okNum, numLines = pcall(C_SpellBook.GetNumSpellBookSkillLines, spellBank)
    if not okNum then
        okNum, numLines = pcall(C_SpellBook.GetNumSpellBookSkillLines)
    end
    if not okNum or type(numLines) ~= "number" then
        return ids
    end

    local function GetSkillLineInfo(index)
        local ok, info = pcall(C_SpellBook.GetSpellBookSkillLineInfo, index, spellBank)
        if ok and info then
            return info
        end
        ok, info = pcall(C_SpellBook.GetSpellBookSkillLineInfo, index)
        if ok and info then
            return info
        end
        return nil
    end

    local function GetSpellBookItemInfo(index)
        local ok, info = pcall(C_SpellBook.GetSpellBookItemInfo, spellBank, index)
        if ok and info then
            return info
        end
        ok, info = pcall(C_SpellBook.GetSpellBookItemInfo, index, spellBank)
        if ok and info then
            return info
        end
        ok, info = pcall(C_SpellBook.GetSpellBookItemInfo, index)
        if ok and info then
            return info
        end
        return nil
    end

    for skillLineIndex = 1, numLines do
        local info = GetSkillLineInfo(skillLineIndex)
        if info and IsRacialOrGeneralSkillLineName(info.name) then
            local offset = info.itemIndexOffset or info.itemIndexOffsetFromParent or 0
            local count = info.numSpellBookItems or info.numSlots or 0
            for slot = 1, count do
                local spellBookIndex = offset + slot
                local itemInfo = GetSpellBookItemInfo(spellBookIndex)
                if itemInfo then
                    local spellID = itemInfo.spellID or itemInfo.actionID
                    local isPassive = itemInfo.isPassive
                    local itemType = itemInfo.itemType or itemInfo.spellBookItemType
                    local isSpellItem = not itemType
                    if Enum and Enum.SpellBookItemType and itemType ~= nil then
                        isSpellItem = itemType == Enum.SpellBookItemType.Spell
                    end
                    if spellID and isSpellItem and not (isPassive or IsPassiveSpellID(spellID)) then
                        ids[spellID] = true
                    end
                end
            end
        end
    end

    racialSpellCache = ids
    return ids
end

function ItemsData:GetItemNameByID(itemID)
    if C_Item and C_Item.GetItemNameByID then
        return C_Item.GetItemNameByID(itemID)
    end
    local name = GetItemInfo(itemID)
    return name
end

function ItemsData:GetEntryName(kind, id)
    if kind == "spell" then
        return GetSpellNameByID(id)
    end
    return self:GetItemNameByID(id)
end

local function GetEntrySettings(entry)
    if IsSpellEntry(entry) then
        return DB.GetSpellItemSettings(entry.id)
    end
    return DB.GetItemSettings(entry.id)
end

local function EnsureEntrySettings(entry)
    if IsSpellEntry(entry) then
        return DB.EnsureSpellItemSettings(entry.id)
    end
    return DB.EnsureItemSettings(entry.id)
end

local function EntrySortKey(entry)
    local name = ItemsData:GetEntryName(entry.kind, entry.id)
    if not name or name == "" then
        return tostring(entry.id)
    end
    return name:lower()
end

local function SortEntries(entries)
    table.sort(entries, function(a, b)
        local aOrder = GetEntrySettings(a) and GetEntrySettings(a).order or nil
        local bOrder = GetEntrySettings(b) and GetEntrySettings(b).order or nil
        if aOrder ~= nil and bOrder ~= nil and aOrder ~= bOrder then
            return aOrder < bOrder
        elseif aOrder ~= nil and bOrder == nil then
            return true
        elseif aOrder == nil and bOrder ~= nil then
            return false
        end
        local aName = EntrySortKey(a)
        local bName = EntrySortKey(b)
        if aName ~= bName then
            return aName < bName
        end
        if a.kind ~= b.kind then
            return a.kind < b.kind
        end
        return a.id < b.id
    end)
end

local function GetEntryOrder(entry)
    local settings = GetEntrySettings(entry)
    return settings and settings.order or nil
end

local function SetEntryOrder(entry, order)
    local settings = EnsureEntrySettings(entry)
    settings.order = order
end

local function EnsureOrderForEntries(entries)
    local maxOrder = 0
    for _, entry in ipairs(entries) do
        local order = GetEntryOrder(entry)
        if order and order > maxOrder then
            maxOrder = order
        end
    end

    for _, entry in ipairs(entries) do
        if GetEntryOrder(entry) == nil then
            maxOrder = maxOrder + 1
            SetEntryOrder(entry, maxOrder)
        end
    end
end

local function ReassignOrders(entries)
    for index, entry in ipairs(entries) do
        SetEntryOrder(entry, index)
    end
end

function ItemsData:InsertItemAt(state, entry, targetEntry, insertBefore)
    if not entry then
        return
    end

    local entries = self:GetEntriesByState(state)
    local existingIndex = nil
    for index, candidate in ipairs(entries) do
        if EntriesEqual(candidate, entry) then
            existingIndex = index
            break
        end
    end

    if existingIndex then
        table.remove(entries, existingIndex)
    end

    local insertIndex = #entries + 1
    if targetEntry then
        for index, candidate in ipairs(entries) do
            if EntriesEqual(candidate, targetEntry) then
                insertIndex = insertBefore and index or (index + 1)
                break
            end
        end
    end

    table.insert(entries, insertIndex, MakeEntry(entry.kind, entry.id))
    ReassignOrders(entries)
end

function ItemsData:GetEntryState(kind, id)
    if kind == "spell" then
        return DB.GetSpellItemState(id)
    end
    return DB.GetItemState(id)
end

function ItemsData:SetEntryState(kind, id, state)
    if kind == "spell" then
        DB.SetSpellItemState(id, state)
    else
        DB.SetItemState(id, state)
    end
end

local function IsTrackableItem(itemID)
    if not itemID then
        return false
    end
    local name, spellID = C_Item.GetItemSpell(itemID)
    if spellID or name then
        return true
    end
    return false
end

local function IsTrackableBagItem(itemID)
    if not itemID then
        return false
    end
    local classID, subclassID = select(6, GetItemInfoInstant(itemID))
    if classID == Enum.ItemClass.Consumable and subclassID ~= Enum.ItemConsumableSubclass.Other then
        return true
    end
end

function ItemsData:ScanOwnedItems()
    local owned = {
        items = {},
        spells = {},
    }

    if C_Container and NUM_BAG_SLOTS then
        for bag = 0, NUM_BAG_SLOTS do
            local slots = C_Container.GetContainerNumSlots(bag)
            for slot = 1, slots do
                local itemID = C_Container.GetContainerItemID(bag, slot)
                if IsTrackableBagItem(itemID) then
                    owned.items[itemID] = true
                end
            end
        end
    end

    for slot = ITEM_EQUIP_FIRST, ITEM_EQUIP_LAST do
        local location = ItemLocation:CreateFromEquipmentSlot(slot)
        if location and C_Item.DoesItemExist(location) then
            local itemID = C_Item.GetItemID(location)
            if IsTrackableItem(itemID) then
                owned.items[itemID] = true
            end
        end
    end

    local racialSpells = GetRacialSpellIDsFromSpellBook()
    for spellID in pairs(racialSpells) do
        owned.spells[spellID] = true
    end

    return owned
end

function ItemsData:EnsureTrackedItems(owned)
    local ownedItems = owned and owned.items or {}
    local ownedSpells = owned and owned.spells or {}

    for itemID in pairs(ownedItems) do
        local state = DB.GetItemState(itemID)
        if state == nil then
            DB.SetItemState(itemID, ITEM_STATE_HIDDEN)
        end
    end

    for spellID in pairs(ownedSpells) do
        local state = DB.GetSpellItemState(spellID)
        if state == nil then
            DB.SetSpellItemState(spellID, ITEM_STATE_HIDDEN)
        end
    end
end

function ItemsData:GetEntriesByState(state)
    local entries = {}
    local db = DB.GetDB()

    for itemID, settings in pairs(db.itemSettings or {}) do
        if settings.state == state then
            table.insert(entries, MakeEntry("item", itemID))
        end
    end

    for spellID, settings in pairs(db.spellItemSettings or {}) do
        if settings.state == state then
            table.insert(entries, MakeEntry("spell", spellID))
        end
    end

    EnsureOrderForEntries(entries)
    SortEntries(entries)
    return entries
end

function ItemsData:CleanupHiddenEntries(owned)
    local ownedItems = owned and owned.items or {}
    local ownedSpells = owned and owned.spells or {}

    local db = DB.GetDB()
    for itemID, settings in pairs(db.itemSettings or {}) do
        if settings.state == ITEM_STATE_HIDDEN and not ownedItems[itemID] then
            DB.SetItemState(itemID, nil)
        end
    end

    for spellID, settings in pairs(db.spellItemSettings or {}) do
        if settings.state == ITEM_STATE_HIDDEN and not ownedSpells[spellID] then
            DB.SetSpellItemState(spellID, nil)
        end
    end
end

function ItemsData:GetItemIDsByState(state)
    local entries = self:GetEntriesByState(state)
    local ids = {}
    for _, entry in ipairs(entries) do
        if entry.kind == "item" then
            table.insert(ids, entry.id)
        end
    end
    return ids
end

function ItemsData:GetTracker1Entries(owned)
    local entries = {}
    local db = DB.GetDB()
    local ownedItems = owned and owned.items or {}
    local ownedSpells = owned and owned.spells or {}

    for itemID, settings in pairs(db.itemSettings or {}) do
        if settings.state == ITEM_STATE_TRACKER1 and ownedItems[itemID] then
            table.insert(entries, MakeEntry("item", itemID))
        end
    end

    for spellID, settings in pairs(db.spellItemSettings or {}) do
        if settings.state == ITEM_STATE_TRACKER1 and ownedSpells[spellID] then
            table.insert(entries, MakeEntry("spell", spellID))
        end
    end

    EnsureOrderForEntries(entries)
    SortEntries(entries)
    return entries
end

function ItemsData:GetTracker2Entries(owned)
    local entries = {}
    local db = DB.GetDB()
    local ownedItems = owned and owned.items or {}
    local ownedSpells = owned and owned.spells or {}

    for itemID, settings in pairs(db.itemSettings or {}) do
        if settings.state == ITEM_STATE_TRACKER2 and ownedItems[itemID] then
            table.insert(entries, MakeEntry("item", itemID))
        end
    end

    for spellID, settings in pairs(db.spellItemSettings or {}) do
        if settings.state == ITEM_STATE_TRACKER2 and ownedSpells[spellID] then
            table.insert(entries, MakeEntry("spell", spellID))
        end
    end

    EnsureOrderForEntries(entries)
    SortEntries(entries)
    return entries
end

ItemsData.ITEM_STATE_HIDDEN = ITEM_STATE_HIDDEN
ItemsData.ITEM_STATE_TRACKER1 = ITEM_STATE_TRACKER1
ItemsData.ITEM_STATE_TRACKER2 = ITEM_STATE_TRACKER2
