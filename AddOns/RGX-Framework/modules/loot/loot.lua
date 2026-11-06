--=====================================================================================
-- RGX-Framework | RGXLoot
-- Loot and currency acquisition event library for any RGX-Framework addon.
--
-- Usage:
--   local Loot = RGX:GetLoot()
--
--   -- Fire once per bag update for the first newly acquired item of any quality
--   Loot:OnItemLooted(function(bag, slot, quality) ... end)
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
Loot._onItemLooted    = {}
Loot._onRareLoot      = {}
Loot._seenNewItems    = {}
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

-- Fired once per bag update for the first newly acquired item of any quality.
-- "Looted" means it newly arrived in the bags (drops, vendors, mail and crafting all count).
-- fn(bag, slot, quality)   quality may be nil on clients that do not report it
function Loot:OnItemLooted(fn)     return AddCb(self._onItemLooted,     fn) end

-- Fired when a new Rare+ item appears in bags.
-- fn(bag, slot, quality)
function Loot:OnRareLoot(fn)       return AddCb(self._onRareLoot,       fn) end

-- Fired when a tracked currency quantity increases.
-- fn(currencyID, gained, newAmount)
function Loot:OnCurrencyGained(fn) return AddCb(self._onCurrencyGained, fn) end

-- ── Internal helpers ──────────────────────────────────────────────────────────

local function ItemQuality(bag, slot)
    if C_Container and C_Container.GetContainerItemInfo then
        local info = C_Container.GetContainerItemInfo(bag, slot)
        return info and info.quality
    elseif GetContainerItemInfo then
        local _, _, q = GetContainerItemInfo(bag, slot)
        return q
    end
end

-- C_NewItems keeps an item flagged new until the player clears it, so a later bag update
-- still sees it. Each slot is reported once; slots that stop being new are forgotten.
local function ScanBagsForNewLoot()
    local numBags = NUM_BAG_SLOTS or 4
    local stillNew = {}
    local first, rare

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
                local key = bag .. ":" .. slot
                stillNew[key] = true
                if not Loot._seenNewItems[key] then
                    local quality = ItemQuality(bag, slot)
                    first = first or { bag, slot, quality }
                    if not rare and quality and quality >= RARE_QUALITY_THRESHOLD then
                        rare = { bag, slot, quality }
                    end
                end
            end
        end
    end

    Loot._seenNewItems = stillNew
    -- One notification per bag update is enough for each callback list.
    if first then Fire(Loot._onItemLooted, first[1], first[2], first[3]) end
    if rare then Fire(Loot._onRareLoot, rare[1], rare[2], rare[3]) end
end

-- ── Framework event wiring ────────────────────────────────────────────────────

function Loot:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    RGX:RegisterEvent("BAG_NEW_ITEMS_UPDATED", function()
        ScanBagsForNewLoot()
    end)

    RGX:RegisterEvent("CURRENCY_DISPLAY_UPDATE", function(_, currencyID, quantity, quantityChange)
        if not currencyID then return end

        local newAmount
        if type(quantity) == "number" then
            newAmount = quantity
        else
            local info = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(currencyID)
            newAmount = (info and info.quantity) or 0
        end

        local oldAmount = Loot._currencyCache[currencyID]
        Loot._currencyCache[currencyID] = newAmount

        -- The event carries its own delta where the client provides it. The
        -- cache starts empty, so a pure cache-diff gate silently swallowed
        -- the first gain of every session; prefer quantityChange when it is
        -- a positive number and only fall back to the diff on flavors that
        -- do not report one (guarded by elseif so a delta never fires twice).
        if type(quantityChange) == "number" and quantityChange > 0 then
            Fire(Loot._onCurrencyGained, currencyID, quantityChange, newAmount)
        elseif oldAmount ~= nil and newAmount > oldAmount then
            Fire(Loot._onCurrencyGained, currencyID, newAmount - oldAmount, newAmount)
        end
    end)
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXLoot = Loot
RGX:RegisterModule("loot", Loot, { category = "game" })
