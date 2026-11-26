-- Shared live counts, inventory notifications and recipe-independent materials.
local _, RGX = ...
local Inventory = {}
local API = RGX.API
local changed = RGX:CreateEmitter("RGXInventory")

local function Accessible(value)
    local ok, allowed = pcall(API.CanAccessValue, value)
    return ok and allowed == true
end

local function Finite(value)
    return Accessible(value) and type(value) == "number"
        and value == value and value >= 0 and value < math.huge
end

local function ItemID(value)
    return Finite(value) and value > 0 and value % 1 == 0
end

local function StorageFlag(value)
    if type(value) == "nil" then return false, true end
    if not Accessible(value) or type(value) ~= "boolean" then return nil, false end
    return value, true
end

-- nil is unknown, not a fabricated zero. The compatibility owner maps flags.
function Inventory:GetItemCount(itemID, includeBank, includeReagentBank)
    if not ItemID(itemID) then return nil, "invalid-item" end
    local bank, bankKnown = StorageFlag(includeBank)
    local reagents, reagentsKnown = StorageFlag(includeReagentBank)
    if not bankKnown or not reagentsKnown then return nil, "unavailable" end
    local modern = type(C_Item) == "table" and type(C_Item.GetItemCount) == "function"
    if not modern and type(GetItemCount) ~= "function" then return nil, "unavailable" end
    if not modern and reagents then return nil, "unavailable" end
    local ok, count = pcall(API.GetItemCount, itemID, bank, reagents)
    if not ok or not Finite(count) then return nil, "unavailable" end
    return count
end

local function ItemDetails(itemID)
    local ok, name, link, quality, level, minLevel, itemType, subType, stack, equipLoc, icon =
        pcall(API.GetItemInfo, itemID)
    if not ok or not Accessible(name) or type(name) ~= "string" then name = nil end
    if not ok or not Accessible(link) or type(link) ~= "string" then link = nil end
    local function Texture(value)
        return Accessible(value) and ((type(value) == "string" and value ~= "")
            or (Finite(value) and value > 0))
    end
    if not ok or not Texture(icon) then icon = nil end
    if icon == nil then
        local iconOK, value = pcall(API.GetItemIcon, itemID)
        if iconOK and Texture(value) then icon = value end
    end
    if name == nil and type(C_Item) == "table" and type(C_Item.RequestLoadItemDataByID) == "function" then
        pcall(C_Item.RequestLoadItemDataByID, itemID)
    end
    return name, icon, link
end

-- steps = { { crafts = 3, reagents = { [itemID] = unitsPerCraft } }, ... }.
-- Recipe selection, skill progression and rank boundaries belong to consumers.
function Inventory:GetRemainingMaterials(steps, opts)
    assert(type(steps) == "table" and API.CanAccessTable(steps), "inventory steps must be an accessible table")
    opts = opts or {}
    assert(type(opts) == "table" and API.CanAccessTable(opts), "inventory options must be an accessible table")
    local required = {}
    for _, step in ipairs(steps) do
        assert(type(step) == "table" and API.CanAccessTable(step), "inventory step must be an accessible table")
        local crafts = step.crafts
        assert(Finite(crafts) and crafts % 1 == 0, "inventory crafts must be a finite nonnegative integer")
        local reagents = step.reagents
        assert(type(reagents) == "table" and API.CanAccessTable(reagents), "inventory reagents must be an accessible table")
        for itemID, units in pairs(reagents) do
            assert(ItemID(itemID), "inventory reagent ID must be a positive integer")
            assert(Finite(units) and units % 1 == 0, "inventory reagent units must be a finite nonnegative integer")
            local total = (required[itemID] or 0) + units * crafts
            assert(Finite(total), "inventory material total must be finite")
            if total > 0 then required[itemID] = total end
        end
    end
    local result = {}
    for itemID, count in pairs(required) do
        local have = self:GetItemCount(itemID, opts.includeBank, opts.includeReagentBank)
        local name, icon, link = ItemDetails(itemID)
        result[itemID] = {
            itemID = itemID, name = name, icon = icon, link = link, requiredCount = count,
            onHandCount = have,
            stillNeeded = have ~= nil and math.max(0, count - have) or nil,
        }
    end
    return result
end

-- Callbacks receive the native event name and payload. The existing emitter
-- owns snapshots, mutation and failure isolation; no parallel callback registry.
function Inventory:OnChanged(fn)
    if type(fn) ~= "function" then return nil end
    self:Init()
    local id = changed:RegisterCallback("changed", function(_, event, ...)
        fn(event, ...)
    end)
    return function() changed:UnregisterCallback("changed", id) end
end

function Inventory:Init()
    if self._eventsInit then return end
    self._eventsInit = true
    local event = RGX:HasEvent("BAG_UPDATE_DELAYED") and "BAG_UPDATE_DELAYED" or "BAG_UPDATE"
    if RGX:HasEvent(event) then
        RGX:RegisterEvent(event, function(name, ...)
            changed:Fire("changed", name, ...)
        end, "RGXInventory_Bags")
    end
    if RGX:HasEvent("GET_ITEM_INFO_RECEIVED") then
        RGX:RegisterEvent("GET_ITEM_INFO_RECEIVED", function(name, itemID, success)
            -- Failed metadata loads are not new data; avoid a refresh/request
            -- loop. A later successful response or bag update refreshes again.
            if success == true then changed:Fire("changed", name, itemID, success) end
        end, "RGXInventory_Items")
    end
end

RGX:RegisterModule("inventory", Inventory, { category = "game" })
