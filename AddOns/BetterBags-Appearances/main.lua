-- Variables --
---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon("BetterBags")

---@class Categories: AceModule
local categories = addon:GetModule('Categories')

---@class Localization: AceModule
local L = addon:GetModule('Localization')

-- Get the player's class
local className, classFilename, classId = UnitClass("player")

local HEAD = "INVTYPE_HEAD"
local SHOULDER = "INVTYPE_SHOULDER"
local BODY = "INVTYPE_BODY"
local CHEST = "INVTYPE_CHEST"
local ROBE = "INVTYPE_ROBE"
local WAIST = "INVTYPE_WAIST"
local LEGS = "INVTYPE_LEGS"
local FEET = "INVTYPE_FEET"
local WRIST = "INVTYPE_WRIST"
local HAND = "INVTYPE_HAND"
local CLOAK = "INVTYPE_CLOAK"
local WEAPON = "INVTYPE_WEAPON"
local TWOHANDEDWEAPON = "INVTYPE_2HWEAPON"
local RANGED = "INVTYPE_RANGED"
local RANGEDRIGHT = "INVTYPE_RANGEDRIGHT"
local SHIELD = "INVTYPE_SHIELD"
local TABARD = "INVTYPE_TABARD"
local BAG = "INVTYPE_BAG"
local PROFESSION_TOOL = "INVTYPE_PROFESSION_TOOL"
local RING = "INVTYPE_FINGER"
local TRINKET = "INVTYPE_TRINKET"
local NECK = "INVTYPE_NECK"

local MISC = "MISCELLANEOUS"
local CLOTH = "CLOTH"
local LEATHER = "LEATHER"
local MAIL = "MAIL"
local PLATE = "PLATE"
local COSMETIC = "COSMETIC"

local classArmorTypeMap = {
    ["DEATHKNIGHT"] = PLATE,
    ["DEMONHUNTER"] = LEATHER,
    ["DRUID"] = LEATHER,
    ["EVOKER"] = MAIL,
    ["HUNTER"] = MAIL,
    ["MAGE"] = CLOTH,
    ["MONK"] = LEATHER,
    ["PALADIN"] = PLATE,
    ["PRIEST"] = CLOTH,
    ["ROGUE"] = LEATHER,
    ["SHAMAN"] = MAIL,
    ["WARLOCK"] = CLOTH,
    ["WARRIOR"] = PLATE,
}

local classWeaponTypeMap = {
    ["DEATHKNIGHT"] = {
        ["One-Handed Axes"]     = true,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = true,
        ["Daggers"]             = false,
        ["Fist Weapons"]        = false,
        ["Two-Handed Axes"]     = true,
        ["Two-Handed Maces"]    = true,
        ["Two-Handed Swords"]   = true,
        ["Staves"]              = false,
        ["Polearms"]            = true,
        ["Warglaives"]          = false,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = false,
        ["Shields"]             = false,
    },
    ["DEMONHUNTER"] = {
        ["One-Handed Axes"]     = true,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = false,
        ["Daggers"]             = false,
        ["Fist Weapons"]        = true,
        ["Two-Handed Axes"]     = false,
        ["Two-Handed Maces"]    = false,
        ["Two-Handed Swords"]   = false,
        ["Staves"]              = false,
        ["Polearms"]            = false,
        ["Warglaives"]          = true,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = false,
        ["Shields"]             = false,
    },
    ["DRUID"] = {
        ["One-Handed Axes"]     = false,
        ["One-Handed Swords"]   = false,
        ["One-Handed Maces"]    = true,
        ["Daggers"]             = true,
        ["Fist Weapons"]        = true,
        ["Two-Handed Axes"]     = false,
        ["Two-Handed Maces"]    = true,
        ["Two-Handed Swords"]   = false,
        ["Staves"]              = true,
        ["Polearms"]            = true,
        ["Warglaives"]          = false,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = false,
        ["Shields"]             = false,
    },
    ["EVOKER"] = {
        ["One-Handed Axes"]     = true,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = true,
        ["Daggers"]             = true,
        ["Fist Weapons"]        = true,
        ["Two-Handed Axes"]     = true,
        ["Two-Handed Maces"]    = true,
        ["Two-Handed Swords"]   = true,
        ["Staves"]              = true,
        ["Polearms"]            = false,
        ["Warglaives"]          = false,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = false,
        ["Shields"]             = false,
    },
    ["HUNTER"] = {
        ["One-Handed Axes"]     = true,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = false,
        ["Daggers"]             = true,
        ["Fist Weapons"]        = true,
        ["Two-Handed Axes"]     = true,
        ["Two-Handed Maces"]    = false,
        ["Two-Handed Swords"]   = true,
        ["Staves"]              = true,
        ["Polearms"]            = true,
        ["Warglaives"]          = false,
        ["Bows"]                = true,
        ["Crossbows"]           = true,
        ["Guns"]                = true,
        ["Wand"]                = false,
        ["Shields"]             = false,
    },
    ["MAGE"] = {
        ["One-Handed Axes"]     = false,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = false,
        ["Daggers"]             = true,
        ["Fist Weapons"]        = false,
        ["Two-Handed Axes"]     = false,
        ["Two-Handed Maces"]    = false,
        ["Two-Handed Swords"]   = false,
        ["Staves"]              = true,
        ["Polearms"]            = true,
        ["Warglaives"]          = false,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = true,
        ["Shields"]             = false,
    },
    ["MONK"] = {
        ["One-Handed Axes"]     = true,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = true,
        ["Daggers"]             = false,
        ["Fist Weapons"]        = true,
        ["Two-Handed Axes"]     = false,
        ["Two-Handed Maces"]    = false,
        ["Two-Handed Swords"]   = false,
        ["Staves"]              = true,
        ["Polearms"]            = true,
        ["Warglaives"]          = false,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = false,
        ["Shields"]             = false,
    },
    ["PALADIN"] = {
        ["One-Handed Axes"]     = true,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = true,
        ["Daggers"]             = false,
        ["Fist Weapons"]        = false,
        ["Two-Handed Axes"]     = true,
        ["Two-Handed Maces"]    = true,
        ["Two-Handed Swords"]   = true,
        ["Staves"]              = false,
        ["Polearms"]            = true,
        ["Warglaives"]          = false,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = false,
        ["Shields"]             = true,
    },
    ["PRIEST"] = {
        ["One-Handed Axes"]     = false,
        ["One-Handed Swords"]   = false,
        ["One-Handed Maces"]    = true,
        ["Daggers"]             = true,
        ["Fist Weapons"]        = false,
        ["Two-Handed Axes"]     = false,
        ["Two-Handed Maces"]    = false,
        ["Two-Handed Swords"]   = false,
        ["Staves"]              = true,
        ["Polearms"]            = false,
        ["Warglaives"]          = false,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = true,
        ["Shields"]             = false,
    },
    ["ROGUE"] = {
        ["One-Handed Axes"]     = true,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = true,
        ["Daggers"]             = true,
        ["Fist Weapons"]        = true,
        ["Two-Handed Axes"]     = false,
        ["Two-Handed Maces"]    = false,
        ["Two-Handed Swords"]   = false,
        ["Staves"]              = false,
        ["Polearms"]            = false,
        ["Warglaives"]          = false,
        ["Bows"]                = true,
        ["Crossbows"]           = true,
        ["Guns"]                = true,
        ["Wand"]                = false,
        ["Shields"]             = false,
    },
    ["SHAMAN"] = {
        ["One-Handed Axes"]     = true,
        ["One-Handed Swords"]   = false,
        ["One-Handed Maces"]    = true,
        ["Daggers"]             = true,
        ["Fist Weapons"]        = true,
        ["Two-Handed Axes"]     = true,
        ["Two-Handed Maces"]    = true,
        ["Two-Handed Swords"]   = false,
        ["Staves"]              = true,
        ["Polearms"]            = false,
        ["Warglaives"]          = false,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = false,
        ["Shields"]             = true,
    },
    ["WARLOCK"] = {
        ["One-Handed Axes"]     = false,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = false,
        ["Daggers"]             = true,
        ["Fist Weapons"]        = false,
        ["Two-Handed Axes"]     = false,
        ["Two-Handed Maces"]    = false,
        ["Two-Handed Swords"]   = false,
        ["Staves"]              = true,
        ["Polearms"]            = false,
        ["Warglaives"]          = false,
        ["Bows"]                = false,
        ["Crossbows"]           = false,
        ["Guns"]                = false,
        ["Wand"]                = true,
        ["Shields"]             = false,
    },
    ["WARRIOR"] = {
        ["One-Handed Axes"]     = true,
        ["One-Handed Swords"]   = true,
        ["One-Handed Maces"]    = true,
        ["Daggers"]             = true,
        ["Fist Weapons"]        = true,
        ["Two-Handed Axes"]     = true,
        ["Two-Handed Maces"]    = true,
        ["Two-Handed Swords"]   = true,
        ["Staves"]              = true,
        ["Polearms"]            = true,
        ["Warglaives"]          = false,
        ["Bows"]                = true,
        ["Crossbows"]           = true,
        ["Guns"]                = true,
        ["Wand"]                = false,
        ["Shields"]             = true,
    },
}

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

function isKnown(itemID)
    return C_TransmogCollection.PlayerHasTransmog(itemID)
end

function isUsableByCurrentClass(data)
    local itemType = data.itemInfo.itemSubType
    local upperItemType = string.upper(data.itemInfo.itemSubType or "") -- 暫時修正
    local equipLoc = data.itemInfo.itemEquipLoc

    if equipLoc == WEAPON or equipLoc == TWOHANDEDWEAPON or equipLoc == SHIELD or equipLoc == RANGED or equipLoc == RANGEDRIGHT then
        if classWeaponTypeMap[classFilename][itemType] then
            return true
        end
    end
    if classArmorTypeMap[classFilename] == upperItemType or equipLoc == CLOAK or upperItemType == COSMETIC or upperItemType == MISC then
        return true
    end
    return false
end

categories:RegisterCategoryFunction("SetAppearanceItemCategories", function (data)
    local equipLoc = data.itemInfo.itemEquipLoc

    -- Guard clauses
    if equipLoc == "" then
        return nil
    end

    if equipLoc == PROFESSION_TOOL or equipLoc == BAG or equipLoc == RING or equipLoc == TRINKET or equipLoc == NECK then
        return nil
    end
    -- End of guard clauses
	
	if isKnown(data.itemInfo.itemID) then 
        return nil -- 自行修改，避免和 BetterBags_Bound 衝突
		--[[
		if(data.itemInfo.bindType == 2) then
            return L:G("Known - BoE")
        else
            return L:G("Known - BoP")
        end
		--]]
    end

    if isUsableByCurrentClass(data) then
        return L:G("Unknown - ") .. className
    else
        return L:G("Unknown - Other Classes")
    end
end)