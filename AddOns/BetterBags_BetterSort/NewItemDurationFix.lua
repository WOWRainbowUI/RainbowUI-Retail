---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')
---@class Items: AceModule
local items = BetterBags:GetModule('Items')
---@class Database: AceModule
local DB = BetterBags:GetModule('Database')
---@class Bags: AceModule
local config = BetterBags:GetModule('Config')
---@class Events: AceModule
local events = BetterBags:GetModule('Events')

-- MARK: local BetterBags functions
-------------------------------------------------------
local GetGeneralOptions = config.GetGeneralOptions

-- MARK: Databse Functions
-------------------------------------------------------
---@param enabled boolean
function DB:SetIgnoreBlizzardNewItems(enabled)
    DB.data.profile.newItemBlizzIgnore = enabled
end

---@return boolean
function DB:GetIgnoreBlizzardNewItems()
    local enabled = DB.data.profile["newItemBlizzIgnore"]
    if enabled == nil then
        DB:SetIgnoreBlizzardNewItems(false)
        return false
    end

    return enabled
end

-- MARK: Overrides
-------------------------------------------------------
---@return AceConfig.OptionsTable
function config:GetGeneralOptions()
    ---@type AceConfig.OptionsTable
    local originalOptions = GetGeneralOptions(self)

    local ignoreBlizzardNewItems = {
        type = "toggle",
        name = L:G("Ignore New Item Tag"),
        desc = L:G("If enbaled, Blizzard \"New Item Tag\" will be ignored. This makes new items strictly rely on \"New Item Duration\" setting."),
        order = 10, -- Lets just make sure that this is always at the end
        width = "full",
        get = function()
            return DB:GetIgnoreBlizzardNewItems()
        end,
        set = function(_, value)
            DB:SetIgnoreBlizzardNewItems(value)
            events:SendMessage('bags/FullRefreshAll')
        end,
    }

    -- Insert the sort option
    originalOptions.args["ignoreBlizzardNewItems"] = ignoreBlizzardNewItems
    -- Reduce step size to 1
    originalOptions.args.newItemTime.step = 1

    return originalOptions
end

---@param data ItemData
---@return boolean
function items:IsNewItem(data)
    if not data or data.isItemEmpty then return false end
    if (self._newItemTimers[data.itemInfo.itemGUID] ~= nil and time() - self._newItemTimers[data.itemInfo.itemGUID] < DB:GetNewItemTime()) or
        (C_NewItems.IsNewItem(data.bagid, data.slotid) and not DB:GetIgnoreBlizzardNewItems()) then
        return true
    end

    self._newItemTimers[data.itemInfo.itemGUID] = nil
    return false
end