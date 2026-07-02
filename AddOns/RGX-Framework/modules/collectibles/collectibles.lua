--=====================================================================================
-- RGX-Framework | RGXCollectibles
-- Collectible unlock event library for any RGX-Framework addon.
--
-- Usage:
--   local Collectibles = RGX:GetCollectibles()
--
--   Collectibles:OnMount(function() print("New mount!") end)
--   Collectibles:OnToy(function() print("New toy!") end)
--   Collectibles:OnTransmog(function() print("New appearance!") end)
--   Collectibles:OnHeirloom(function() print("New heirloom!") end)
--
-- All callbacks fire-and-forget; multiple addons can register independently.
-- Errors in callbacks are caught and do not break other callbacks.
--=====================================================================================

local addonName, RGX = ...

local Collectibles = {}

-- ── State ─────────────────────────────────────────────────────────────────────

Collectibles._eventsInit  = false
Collectibles._onMount     = {}
Collectibles._onToy       = {}
Collectibles._onTransmog  = {}
Collectibles._onHeirloom  = {}

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
        if not ok then RGX:Debug("[RGXCollectibles] Callback error: " .. tostring(err)) end
    end
end

-- ── Public callback registration ─────────────────────────────────────────────

-- Fired when a new mount is added to the mount journal.
function Collectibles:OnMount(fn)    return AddCb(self._onMount,    fn) end

-- Fired when a new toy is added to the toy box.
function Collectibles:OnToy(fn)      return AddCb(self._onToy,      fn) end

-- Fired when a new transmog appearance is unlocked.
function Collectibles:OnTransmog(fn) return AddCb(self._onTransmog, fn) end

-- Fired when the heirloom collection is updated (heirloom added).
function Collectibles:OnHeirloom(fn) return AddCb(self._onHeirloom, fn) end

-- ── Framework event wiring ────────────────────────────────────────────────────

function Collectibles:Init()
    if self._eventsInit then return end
    self._eventsInit = true

    RGX:RegisterEvent("NEW_MOUNT_ADDED", function()
        Fire(Collectibles._onMount)
    end)

    RGX:RegisterEvent("NEW_TOY_ADDED", function()
        Fire(Collectibles._onToy)
    end)

    RGX:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED", function()
        Fire(Collectibles._onTransmog)
    end)

    RGX:RegisterEvent("HEIRLOOMS_UPDATED", function()
        Fire(Collectibles._onHeirloom)
    end)
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXCollectibles = Collectibles
RGX:RegisterModule("collectibles", Collectibles)
