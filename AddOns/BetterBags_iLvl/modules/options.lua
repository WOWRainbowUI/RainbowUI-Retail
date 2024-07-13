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

---@class BetterBags_iLvl: AceModule
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

local thresholdError = false
local canRefreshDisabled = true

function addon:OnEnable()
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
                    name = L["OPTIONS_THRESHOLD"]:gsub("_default_", BetterBags_iLvlDB.defaultThreshold),
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
                    disabled = function() return BetterBags_iLvlDB.threshold == BetterBags_iLvlDB.defaultThreshold end,
                    func = function()
                        config.pluginOptions[L["CATEGORY_NAME"]].iLvlCategory.args.threshold.set(nil, BetterBags_iLvlDB.defaultThreshold)
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
end
