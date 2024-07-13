---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")

---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')
---@class Config: AceModule
local config = BetterBags:GetModule('Config')
---@class Events: AceModule
local events = BetterBags:GetModule('Events')
---@class Items: AceModule
local items = BetterBags:GetModule('Items')

local addonName, root = ...;
local L = root.L;

-- Check if the priority addon is available
local BetterBagsPriority = LibStub('AceAddon-3.0'):GetAddon("BetterBags_Priority", true)
local priorityEnabled = BetterBagsPriority ~= nil or false

-- If the priority addon is available, we register the custom category as an empty filter with BetterBags to keep the
-- "enable system" working. The actual filtering will be done by the priority addon
if (priorityEnabled) then
    local categoriesWithPriority = BetterBagsPriority:GetModule('Categories')

    --@param data ItemData
    categories:RegisterCategoryFunction("iLvlCategoryFilter", function(data)
        return nil
    end)

    --@param data ItemData
    categoriesWithPriority:RegisterCategoryFunction(L["CATEGORY_NAME"], "iLvlCategoryFilter", function(data)
        if (data.itemInfo.classID == Enum.ItemClass.Armor or data.itemInfo.classID == Enum.ItemClass.Weapon) then
            local ilvl = data.itemInfo.currentItemLevel

            if (ilvl < (tonumber(BetterBags_iLvlDB.threshold) or BetterBags_iLvlDB.defaultThreshold)) then
                return L["CATEGORY_NAME"]
            end
        end

        return nil
    end)
else
    -- Check if the legendary and / or tabards addons are enabled
    local BetterBagsLegendary = LibStub('AceAddon-3.0'):GetAddon("BetterBags_Legendary", true)
    local legendaryEnabled = BetterBagsLegendary ~= nil or false

    local BetterBagsTabards = LibStub('AceAddon-3.0'):GetAddon("BetterBags_Tabards", true)
    local tabardsEnabled = BetterBagsTabards ~= nil or false

    --@param data ItemData
    categories:RegisterCategoryFunction("iLvlCategoryFilter", function(data)
        if (data.itemInfo.classID == Enum.ItemClass.Armor or data.itemInfo.classID == Enum.ItemClass.Weapon) then
            if (
                (tabardsEnabled and BetterBagsTabards:IsTabard(data.itemInfo))
                or (legendaryEnabled and BetterBagsLegendary:IsLegendaryPlus(data.itemInfo))
                or (not BetterBags_iLvlDB.includeJunk and data.itemInfo.itemQuality == Enum.ItemQuality.Poor)
            ) then
                return nil
            end

            local ilvl = data.itemInfo.currentItemLevel

            if (ilvl < (tonumber(BetterBags_iLvlDB.threshold) or BetterBags_iLvlDB.defaultThreshold)) then
                return L["CATEGORY_NAME"]
            end
        end

        return nil
    end)
end

