local _, MKPT_env, _ = ...

---@class MKPT_Currency
local MKPT_Currency = {}

MKPT_env.MKPT_Currency = MKPT_Currency
local trackedCurrencies = {}

function MKPT_env.IsTrackedCurrency(currencyId)
    return trackedCurrencies[currencyId]
end

---@class MKPT_Currency
---@field id number - Currency Id
---@field name string - Currency name
---@field icon number - Icon Id
function MKPT_Currency:New(currencyId)
    local currency = {}
    setmetatable(currency, self)
    self.__index = self
    currency.id = currencyId

    trackedCurrencies[currencyId] = true

    local info = C_CurrencyInfo.GetCurrencyInfo(currencyId)
    currency.name = info.name
    currency.icon = info.iconFileID
    return currency
end

function MKPT_Currency:GetName()
    return self.name
end

---Get available quantities for currency
---@return table - with fields quantity, max, weeklyEarned, maxWeeklyEarned and totalEarned
function MKPT_Currency:GetQuantity()
    local info = C_CurrencyInfo.GetCurrencyInfo(self.id)
    return {
        quantity = info.quantity,
        max = info.maxQuantity,
        weeklyEarned = info.quantityEarnedThisWeek,
        maxWeeklyEarned = info.maxWeeklyQuantity,
        totalEarned = info.totalEarned,
    }
end

function MKPT_Currency:Show()
    return true
end

local MKPT_ShardOfDundun = MKPT_Currency:New(3376)
MKPT_env.MKPT_ShardOfDundun = MKPT_ShardOfDundun

function MKPT_ShardOfDundun:Show()
    if MKPT_env.db.config.hideDundun or
        MKPT_env.charDb.state.expansion ~= Enum.ExpansionLevel.Midnight
    then
        return false
    end
    return true
end

local MKPT_UnalloyedAbundance = MKPT_ShardOfDundun:New(3377)
MKPT_env.MKPT_UnalloyedAbundance = MKPT_UnalloyedAbundance