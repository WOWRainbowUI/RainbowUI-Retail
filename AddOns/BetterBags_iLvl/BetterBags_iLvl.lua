---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
assert(BetterBags, "BetterBags_Legendary requires BetterBags")

local addonName, root = ...;

---@class BetterBags_Tabards: AceModule
local addon = LibStub("AceAddon-3.0"):NewAddon(root, addonName, 'AceHook-3.0')

---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')
---@class Config: AceModule
local config = BetterBags:GetModule('Config')
---@class Constants: AceModule
local db = BetterBags:GetModule('Database')
---@class Constants: AceModule
local const = BetterBags:GetModule('Constants')
---@class Events: AceModule
local events = BetterBags:GetModule('Events')
---@class Items: AceModule
local items = BetterBags:GetModule('Items')

local L = root.L;
local _G = _G

-- Default values
local canRefreshDisabled = true
local defaultThreshold = "460"
local thresholdError = false

if (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC) then
    defaultThreshold = "60"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC) then
    defaultThreshold = "120"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC) then
    defaultThreshold = "225"
elseif (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CATACLYSM_CLASSIC) then
    defaultThreshold = "308"
end

if type(BetterBags_iLvlDB) ~= "table" then
    BetterBags_iLvlDB = {}
    BetterBags_iLvlDB.threshold = defaultThreshold
    BetterBags_iLvlDB.includeJunk = true
end

categories:CreateCategory(L["CATEGORY_NAME"])

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
            or (legendaryEnabled and BetterBagsLegendary:IsLegendary(data.itemInfo))
            or (not BetterBags_iLvlDB.includeJunk and data.itemInfo.itemQuality == Enum.ItemQuality.Poor)
        ) then
            return nil
        end

        local ilvl = data.itemInfo.currentItemLevel

        if (ilvl < (tonumber(BetterBags_iLvlDB.threshold) or defaultThreshold)) then
            return L["CATEGORY_NAME"]
        end
    end

	return nil
end)

local iLvlConfigOptions = {
    iLvlCategory = {
        name = L["CATEGORY_NAME"],
        type = "group",
        order = 0,
        inline = true,
        args = {
            createHelp = {
                type = "description",
                name = L["OPTIONS_DESC"],
                order = 0,
            },
            threshold = {
                name = L["OPTIONS_THRESHOLD"]:gsub("_default_", defaultThreshold),
                type = "input",
                order = 1,
                get = function()
                    return BetterBags_iLvlDB.threshold
                end,
                set = function(_, value)
                    if (tonumber(value)) then
                        thresholdError = false
                        BetterBags_iLvlDB.threshold = tostring(value)
                        categories:WipeCategory(L["CATEGORY_NAME"])
                        events:SendMessage('bags/FullRefreshAll')
                        items.RefreshAll()
                        canRefreshDisabled = false
                    else
                        thresholdError = true
                    end
                end,
            },
            resetDefault = {
                type = "execute",
                name = L["OPTIONS_RESET_DEFAULT"],
                order = 2,
                disabled = function() return BetterBags_iLvlDB.threshold == defaultThreshold end,
                func = function()
                    config.pluginOptions[L["CATEGORY_NAME"]].iLvlCategory.args.threshold.set(nil, defaultThreshold)
                end,
            },
            thresholdError = {
                type = "description",
                name = "\124cffff0000" .. L["OPTIONS_THRESHOLD_ERROR"] .. "\124r",
                order = 3,
                width = "full",
                hidden = function() return not thresholdError end,
            },
            includeJunk = {
                name = L["OPTIONS_INCLUDE_JUNK"],
                type = "toggle",
                order = 4,
                width = "full",
                get = function()
                    return BetterBags_iLvlDB.includeJunk
                end,
                set = function(_, value)
                    BetterBags_iLvlDB.includeJunk = value
                    categories:WipeCategory(L["CATEGORY_NAME"])
                    events:SendMessage('bags/FullRefreshAll')
                    items.RefreshAll()
                    canRefreshDisabled = false
                end,
            },
        },
    },
    refresh = {
        type = "execute",
        name = L["OPTIONS_REFRESH"],
        order = 1,
        width = "full",
        disabled = function() return canRefreshDisabled end,
        func = function()
            canRefreshDisabled = true
            ConsoleExec("reloadui")
        end,
    },
}

config:AddPluginConfig(L["CATEGORY_NAME"], iLvlConfigOptions)
