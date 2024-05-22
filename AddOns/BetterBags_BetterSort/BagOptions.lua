---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')
---@class Bags: AceModule
local config = BetterBags:GetModule('Config')
---@class Bags: AceModule
local DB = BetterBags:GetModule('Database')
---@class Events: AceModule
local events = BetterBags:GetModule('Events')

-- MARK: local BetterBags functions
-------------------------------------------------------
local GetBagOptions = config.GetBagOptions
local GetItemLevelOptions = DB.GetItemLevelOptions

-- MARK: Databse Functions
-------------------------------------------------------
---@param kind BagKind
---@param enabled boolean
---@return boolean
function DB:SetItemLevelSortEnabled(kind, enabled)
    DB.data.profile.itemLevel[kind]["sort"] = enabled
end

-- MARK: Overrides
-------------------------------------------------------
---@param kind BagKind
---@return AceConfig.OptionsTable
function config:GetBagOptions(kind)
    local originalOptions = GetBagOptions(self, kind)

    local sortArg = {
        type = "toggle",
        name = L:G("Sort by Item Level"),
        desc = L:G("Sort Items by Item Level."),
        order = 10, -- Lets just make sure that this is always at the end
        get = function()
            return DB:GetItemLevelOptions(kind).sort
        end,
        set = function(_, value)
            DB:SetItemLevelSortEnabled(kind, value)
            events:SendMessage('bags/FullRefreshAll')
        end,
    }

    -- Insert the sort option
    originalOptions.args.itemLevel.args["sort"] = sortArg

    return originalOptions
end

---@param kind BagKind
function DB:GetItemLevelOptions(kind) 
    local options = GetItemLevelOptions(self, kind)

    if options and options["sort"] == nil then
        options["sort"] = false
        DB:SetItemLevelSortEnabled(kind, false)
    end

    return options
end
