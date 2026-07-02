--=====================================================================================
-- RGX-Framework | RGXLoot
-- Loot and currency acquisition event library for any RGX-Framework addon.
--
-- Usage:
--   local Loot = RGX:GetLoot()
--
--   -- Fire when a Rare+ quality item appears in bags (quality >= 3)
--   Loot:OnRareLoot(function(bag, slot, quality) ... end)
--
--   -- Fire when a tracked currency quantity increases
--   Loot:OnCurrencyGained(function(currencyID, gained, newAmount) ... end)
--
-- Item quality thresholds (Enum.ItemQuality):
--   Poor=0  Common=1  Uncommon=2  Rare=3  Epic=4  Legendary=5
--
-- All callbacks fire-and-forget; multiple addons can register independently.
-- Errors in callbacks are caught and do not break other callbacks.
--=====================================================================================

local addonName, RGX = ...

local Loot = {}

-- ── State ─────────────────────────────────────────────────────────────────────

Loot._eventsInit      = false
Loot._onRareLoot      = {}
Loot._onCurrencyGained = {}
Loot._currencyCache   = {}

local RARE_QUALITY_THRESHOLD = 3

-- ── Callback helpers ──────────────────────────────────────────────────────────

local function AddCb(list, fn)
    if type(fn) ~= "function" then return nil end
    table.insert(list, fn)
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
        if not ok then RGX:Debug("[RGXLoot] Callback error: " .. tostring(err)) end
    end
end

-- ── Public callback registration ─────────────────────────────────────────────

-- Fired when a new Rare+ item appears in bags.
-- fn(bag, slot, quality)
function Loot:OnRareLoot(fn)       return AddCb(self._onRareLoot,       fn) end

-- Fired when a tracked currency quantity increases.
-- fn(currencyID, gained, newAmount)
function Loot:OnCurrencyGained(fn) return AddCb(self._onCurrencyGained, fn) end

-- ── Internal helpers ──────────────────────────────────────────────────────────

local function ScanBagsForRareLoot()
    local numBags = NUM_BAG_SLOTS or 4
    for bag = 0, numBags do
        local numSlots = 0
        if C_Container and C_Container.GetContainerNumSlots then
            numSlots = C_Container.GetContainerNumSlots(bag) or 0
        elseif GetContainerNumSlots then
            numSlots = GetContainerNumSlots(bag) or 0
        end

        for slot = 1, numSlots do
            local isNew = C_NewItems and C_NewItems.IsNewItem and C_NewItems.IsNewItem(bag, slot)
            if isNew then
                local quality
                if C_Container and C_Container.GetContainerItemInfo then
                    local info = C_Container.GetContainerItemInfo(bag, slot)
                    quality = info and info.quality
                elseif GetContainerItemInfo then
                    local _, _, q = GetContainerItemInfo(bag, slot)
                    quality = q
                end
                if quality and quality >= RARE_QUALITY_THRESHOLD then
                    Fire(Loot._onRareLoot, bag, slot, quality)
                    return  -- one notification per bag update is enough
                end
            end
        end
    end
end

-- ── Framework event wiring ────────────────────────────────────────────────────

function Loot:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    RGX:RegisterEvent("BAG_NEW_ITEMS_UPDATED", function()
        ScanBagsForRareLoot()
    end)

    RGX:RegisterEvent("CURRENCY_DISPLAY_UPDATE", function(_, currencyID)
        if not currencyID then return end

        local newAmount = 0
        if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
            local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
            newAmount = (info and info.quantity) or 0
        end

        local oldAmount = Loot._currencyCache[currencyID]
        Loot._currencyCache[currencyID] = newAmount

        if oldAmount ~= nil and newAmount > oldAmount then
            Fire(Loot._onCurrencyGained, currencyID, newAmount - oldAmount, newAmount)
        end
    end)
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXLoot = Loot
RGX:RegisterModule("loot", Loot)
