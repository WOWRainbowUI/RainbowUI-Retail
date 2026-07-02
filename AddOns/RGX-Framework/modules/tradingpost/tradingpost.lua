--=====================================================================================
-- RGX-Framework | RGXTradingPost
-- Trading Post purchase and currency gain callbacks for addon authors.
--=====================================================================================

local addonName, RGX = ...

local TradingPost = {
    _eventsInit = false,
    _onPurchase = {},
    _onCurrencyGained = {},
    lastCurrencyAmount = nil,
}

local function AddCb(list, fn)
    if type(fn) ~= "function" then return nil end
    list[#list + 1] = fn
    return function()
        for i = #list, 1, -1 do
            if list[i] == fn then
                table.remove(list, i)
                return
            end
        end
    end
end

local function Fire(list, ...)
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, ...)
        if not ok then RGX:Debug("[RGXTradingPost] Callback error: " .. tostring(err)) end
    end
end

function TradingPost:GetCurrencyAmount()
    if C_PerksProgram and C_PerksProgram.GetCurrencyAmount then
        return C_PerksProgram.GetCurrencyAmount() or 0
    end
    return 0
end

function TradingPost:OnPurchase(fn) return AddCb(self._onPurchase, fn) end
function TradingPost:OnCurrencyGained(fn) return AddCb(self._onCurrencyGained, fn) end

function TradingPost:Init()
    if self._eventsInit then return end
    self._eventsInit = true
    self.lastCurrencyAmount = self:GetCurrencyAmount()

    RGX:RegisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS", function(_, vendorItemID, ...)
        Fire(TradingPost._onPurchase, vendorItemID, ...)
    end, "RGXTradingPost_Purchase")

    RGX:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH", function()
        local current = TradingPost:GetCurrencyAmount()
        local previous = TradingPost.lastCurrencyAmount
        TradingPost.lastCurrencyAmount = current
        if previous and current > previous then
            Fire(TradingPost._onCurrencyGained, current - previous, current, previous)
        end
    end, "RGXTradingPost_Currency")
end

_G.RGXTradingPost = TradingPost
RGX:RegisterModule("tradingpost", TradingPost)
