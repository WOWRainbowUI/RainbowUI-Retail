-- Variables --
---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(BetterBags, "BetterBags - Appearances requires BetterBags")

---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')

---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')

---@class AceDB: AceModule
local AceDB = LibStub("AceDB-3.0")

---@class Appearances: AceModule
local Appearances = BetterBags:NewModule('Appearances')

---@class Config: AceModule
local Config = BetterBags:GetModule('Config')

---@class Events: AceModule
local Events = BetterBags:GetModule('Events')

local defaults = {
    profile = {
        enableSubdivide = false,
    },
}

local db

local configOptions = {
    msg = {
        type = "toggle",
        name = L:G("Subdivide by category"),
        desc = L:G("This will also split items into categories based on their type."),
        get = function(info)
            return Appearances.db.profile.enableSubdivide
        end,
        set = function(info, value)
            Appearances.db.profile.enableSubdivide = value
            clearExistingCategories()
            Events:SendMessage('bags/FullRefreshAll')
        end,
    },
}

local nonEquippableTypes = {
    ["INVTYPE_NON_EQUIP_IGNORE"] = true,
    ["INVTYPE_TRINKET"] = true,
    ["INVTYPE_FINGER"] = true,
    ["INVTYPE_NECK"] = true,
    ["INVTYPE_BAG"] = true,
    ["INVTYPE_PROFESSION_TOOL"] = true,
    ["INVTYPE_PROFESSION_GEAR"] = true,
}

-- Create a hidden tooltip for scanning
local scanTooltip = CreateFrame("GameTooltip", "BindCheckTooltipScanner", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

local itemIdsToIgnore = {
    49888, -- Shadow's Edge
    71084, -- Branch of Nordrassil
    71085, -- Runestaff of Nordrassil
    77945, -- Fear
    77946, -- Vengeance
    77947, -- The Sleeper
    77948, -- The Dreamer
}

-- Functions --
-- On plugin load, wipe the categories we've added
function Appearances:OnInitialize()
    self.db = AceDB:New("BetterBags_AppearancesDB", defaults)
    self.db:SetProfile("global")
    db = self.db.profile

    self:addAppearancesConfig()
    clearExistingCategories()
    killOldCategories()
end

-- Kill the subcategories if they exist --
function clearExistingCategories()
    categories:WipeCategory(WrapTextInColorCode(L:G("Mog - Learnable"), "ff00ff00"))
    categories:WipeCategory(WrapTextInColorCode(L:G("Mog - Tradable"), "ff00ff00"))
    categories:WipeCategory(WrapTextInColorCode(L:G("Mog - Sellable"), "ff00ff00"))
    categories:WipeCategory(L:G("Mog - Learnable"))
    categories:WipeCategory(L:G("Mog - Tradable"))
    categories:WipeCategory(L:G("Mog - Sellable"))

    for i = Enum.ItemWeaponSubclassMeta.MinValue, Enum.ItemWeaponSubclassMeta.MaxValue do
        local name, _ = GetItemSubClassInfo(Enum.ItemClass.Weapon, i)
        categories:WipeCategory(WrapTextInColorCode(L:G("Mog - Tradable - ") .. name, "ff00ff00"))
        categories:WipeCategory(L:G("Mog - Tradable - ") .. name)
    end

    for i = Enum.ItemArmorSubclassMeta.MinValue, Enum.ItemArmorSubclassMeta.MaxValue do
        local name, _ = GetItemSubClassInfo(Enum.ItemClass.Armor, i)
        categories:WipeCategory(WrapTextInColorCode(L:G("Mog - Tradable - ") .. name, "ff00ff00"))
        categories:WipeCategory(L:G("Mog - Tradable - ") .. name)
    end
end

function killOldCategories()
    categories:WipeCategory(L:G("Other Classes"))
    categories:WipeCategory(L:G("Unknown - Other Classes"))
    categories:WipeCategory(L:G("Known - BoE"))
    categories:WipeCategory(L:G("Known - BoP"))
    
    -- Loop through all classes and wipe the categories
    for i = 1, GetNumClasses() do
        local className, _ = GetClassInfo(i)
        categories:WipeCategory(className .. L:G(" Usable"))
        categories:WipeCategory(L:G("Unknown - ") .. className)
    end
end

-- Debug dump functions
-- @debug@
function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function printTable(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            printTable(v, indent+1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))      
        else
            print(formatting .. v)
        end
    end
end
-- @end-debug@

function isEquipabble(itemInfo)
    return not nonEquippableTypes[itemInfo.itemEquipLoc]
end

function canLearnAppearance(data)
    local itemLink = C_Container.GetContainerItemLink(data.bagid, data.slotid)
    local _, _, transmogSource = C_Transmog.CanTransmogItem(itemLink)
    if not transmogSource then return nil end

    local itemAppearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemLink)
    if not sourceID then return nil end

    local _, canCollect = C_TransmogCollection.PlayerCanCollectSource(sourceID)
    if not canCollect then return false end

    local sources = C_TransmogCollection.GetAllAppearanceSources(itemAppearanceID)
    for _, sourceID in ipairs(sources) do
        if select(5, C_TransmogCollection.GetAppearanceSourceInfo(sourceID)) then
            return false
        end
    end

    return true
end

function checkItemBindStatus(itemLink)
    scanTooltip:ClearLines()
    scanTooltip:SetHyperlink(itemLink)

    for i = 2, scanTooltip:NumLines() do
        local lineText = _G["BindCheckTooltipScannerTextLeft" .. i]:GetText()
        if lineText then
            if lineText:find(ITEM_BIND_ON_EQUIP) then return "BoE"
            elseif lineText:find(ITEM_BIND_ON_PICKUP) then return "BoP"
            elseif lineText:find(ITEM_ACCOUNTBOUND) or lineText:find(ITEM_BIND_TO_ACCOUNT) or lineText:find(ITEM_BIND_TO_BNETACCOUNT) or lineText:find(ITEM_BNETACCOUNTBOUND) then return "BoA"
            end
        end
    end
    return "None"
end

function isItemIgnored(itemID)
    for index, id in ipairs(itemIdsToIgnore) do
        if itemID == id then return true end
    end
    return false
end

function Appearances:addAppearancesConfig()
    if not Config or not configOptions then
        print("Failed to load configurations for Appearances plugin.")
        return
    end

    Config:AddPluginConfig(L:G("Appearances"), configOptions)
end

Events:RegisterEvent('TRANSMOG_COLLECTION_SOURCE_ADDED', function()
    clearExistingCategories()
end)

Events:RegisterEvent('TRANSMOG_COLLECTION_SOURCE_REMOVED', function()
    clearExistingCategories()
end)

-- Register the category function
categories:RegisterCategoryFunction("MogCategorization", function(data)
    -- Exclude non-equipable, legendaries, and artifacts
    if not isEquipabble(data.itemInfo) or data.itemInfo.itemQuality == 6 or data.itemInfo.itemQuality == 5 or isItemIgnored(data.itemInfo.itemID) or C_Heirloom.IsItemHeirloom(data.itemInfo.itemID) then
        return nil
    end

    local bindType = checkItemBindStatus(data.itemInfo.itemLink)
    local canLearn = canLearnAppearance(data)

    -- If the item cannot be learned
    if not canLearn then
        -- Handle BoA items separately, as they are bound but tradable across the account
        if bindType == "BoA" then
            if db.enableSubdivide then
                return WrapTextInColorCode(L:G("Mog - Tradable - ") .. data.itemInfo.itemSubType, "ff00ff00")
            else
                return WrapTextInColorCode(L:G("Mog - Tradable"), "ff00ff00")
            end
        -- Check if the item is bound and not BoA, categorize as "Mog - Sellable"
        elseif data.itemInfo.isBound or bindType == "BoP" then
            -- return WrapTextInColorCode(L:G("Mog - Sellable"), "ff00ff00")
        elseif bindType == "BoE" then
            -- If the item is BoE and not bound, it's tradable
            if db.enableSubdivide then
                return WrapTextInColorCode(L:G("Mog - Tradable - ") .. data.itemInfo.itemSubType, "ff00ff00")
            else
                return WrapTextInColorCode(L:G("Mog - Tradable"), "ff00ff00")
            end
        end
    elseif canLearn then
        -- If the item's appearance can be learned
        return WrapTextInColorCode(L:G("Mog - Learnable"), "ff00ff00")
    end
    -- Default case if none of the conditions are met, might need explicit handling
end)
