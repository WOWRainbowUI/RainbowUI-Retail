-- TargetRegistry.lua – Central registry for tracked cooldowns
--
-- Every styled cooldown must be explicitly registered here by an adapter.
-- The registry is the single source of truth for category routing.
-- No global frame scanning is used to populate this registry.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Registry = MCE:NewModule("TargetRegistry")

local setmetatable, wipe, pairs, next = setmetatable, wipe, pairs, next
local weakMeta = addon.weakMeta

-- cooldown -> { category, subtype }
local entries = setmetatable({}, weakMeta)

-- category -> weak set of cooldowns
local categoryIndex = {}

-- category -> adapter module (set by adapters at enable time)
local adapters = {}

-- ordered adapter list for TryClaim fallback
local adapterOrder = {}

local function EnsureCategorySet(category)
    local set = categoryIndex[category]
    if not set then
        set = setmetatable({}, weakMeta)
        categoryIndex[category] = set
    end
    return set
end

-- Pre-create index sets for known categories
for _, cat in pairs(C.Categories) do
    EnsureCategorySet(cat)
end

function Registry:Register(cooldown, category, subtype)
    if not cooldown or not category then return end

    local existing = entries[cooldown]
    if existing then
        if existing.category == category and existing.subtype == subtype then
            return
        end
        local oldSet = categoryIndex[existing.category]
        if oldSet then oldSet[cooldown] = nil end
        existing.category = category
        existing.subtype = subtype
    else
        entries[cooldown] = { category = category, subtype = subtype }
    end

    EnsureCategorySet(category)[cooldown] = true
end

function Registry:Unregister(cooldown)
    local entry = entries[cooldown]
    if not entry then return end

    local catSet = categoryIndex[entry.category]
    if catSet then catSet[cooldown] = nil end
    entries[cooldown] = nil
end

function Registry:IsRegistered(cooldown)
    return entries[cooldown] ~= nil
end

function Registry:GetEntry(cooldown)
    return entries[cooldown]
end

function Registry:GetCategory(cooldown)
    local entry = entries[cooldown]
    return entry and entry.category or nil
end

function Registry:GetSubtype(cooldown)
    local entry = entries[cooldown]
    return entry and entry.subtype or nil
end

function Registry:SetSubtype(cooldown, subtype)
    local entry = entries[cooldown]
    if entry then entry.subtype = subtype end
end

function Registry:IterateAll()
    return pairs(entries)
end

function Registry:IterateCategory(category)
    local catSet = categoryIndex[category]
    if not catSet then return next, {}, nil end
    return pairs(catSet)
end

function Registry:RegisterAdapter(category, adapter)
    adapters[category] = adapter
    adapterOrder[#adapterOrder + 1] = adapter
end

function Registry:GetAdapter(category)
    return adapters[category]
end

--- Ask each adapter to try claiming an unregistered cooldown.
--- Returns category, subtype if claimed; nil otherwise.
function Registry:TryClaim(cooldown)
    for i = 1, #adapterOrder do
        local adapter = adapterOrder[i]
        if adapter.TryClaim then
            local cat, sub = adapter:TryClaim(cooldown)
            if cat then
                self:Register(cooldown, cat, sub)
                return cat, sub
            end
        end
    end
    return nil
end

function Registry:RebuildCategory(category)
    local adapter = adapters[category]
    if adapter and adapter.Rebuild then
        adapter:Rebuild()
    end
end

function Registry:RebuildAll()
    for _, adapter in pairs(adapters) do
        if adapter.Rebuild then
            adapter:Rebuild()
        end
    end
end

function Registry:WipeCategory(category)
    local catSet = categoryIndex[category]
    if catSet then
        for cooldown in pairs(catSet) do
            entries[cooldown] = nil
        end
        wipe(catSet)
    end
end

function Registry:WipeAll()
    wipe(entries)
    for cat in pairs(categoryIndex) do
        wipe(categoryIndex[cat])
    end
end
