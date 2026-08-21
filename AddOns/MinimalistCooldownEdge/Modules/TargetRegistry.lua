-- TargetRegistry.lua – Central registry for tracked cooldowns
--
-- Every styled cooldown must be explicitly registered here by an adapter.
-- The registry is the single source of truth for category routing.
-- No global frame scanning is used to populate this registry.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Registry = MCE:NewModule("TargetRegistry")

local setmetatable, wipe, pairs, next, pcall = setmetatable, wipe, pairs, next, pcall
local weakMeta = addon.weakMeta
local frameState = addon.frameState
local INTERNAL_VISUAL_COOLDOWN_KEY = "MCEPlayerAuraVisualOnly"

-- cooldown -> { category, subtype }
local entries = setmetatable({}, weakMeta)

-- cooldown -> ownership generation in which every adapter rejected it.
-- Values are deliberately tiny scalars; weak keys let discarded UI frames die.
local negativeOwnership = setmetatable({}, weakMeta)
local ownershipGeneration = 1

-- category -> weak set of cooldowns
local categoryIndex = {}

-- category -> ordered adapter modules (set by adapters at enable time)
local adapters = {}

-- ordered adapter list for TryClaim fallback
local adapterOrder = {}

local function InsertUnique(list, value)
    for i = 1, #list do
        if list[i] == value then
            return false
        end
    end

    list[#list + 1] = value
    return true
end

local function EnsureCategorySet(category)
    local set = categoryIndex[category]
    if not set then
        set = setmetatable({}, weakMeta)
        categoryIndex[category] = set
    end
    return set
end

local function IsInternalVisualCooldown(cooldown)
    return MCE:SafeTableGet(cooldown, INTERNAL_VISUAL_COOLDOWN_KEY) == true
end

local function InvalidateActionbarStructure(cooldown, category)
    if category ~= C.Categories.Actionbar then return end

    local state = frameState[cooldown]
    if not state then
        state = {}
        frameState[cooldown] = state
    end
    state.forceTextRegionRefresh = true
    state.actionbarTextStructureApplied = nil
    state.actionbarStackStyleApplied = nil
    state.actionbarStackCountResolved = nil
    state.actionbarStackCountRegion = nil
    state.actionbarStackCountParent = nil
end

local function RemoveEntry(cooldown)
    if not MCE:CanUseFrameAsTableKey(cooldown) then return end

    local entry = entries[cooldown]
    if not entry then return end

    local catSet = categoryIndex[entry.category]
    if catSet then catSet[cooldown] = nil end
    entries[cooldown] = nil
end

local function TryGetEntry(cooldown)
    if not cooldown then
        return nil
    end
    if IsInternalVisualCooldown(cooldown) then
        RemoveEntry(cooldown)
        return nil
    end

    return MCE:SafeTableGet(entries, cooldown)
end

local function ReadOwnershipState(cooldown)
    return entries[cooldown], negativeOwnership[cooldown]
end

-- Pre-create index sets for known categories
for _, cat in pairs(C.Categories) do
    EnsureCategorySet(cat)
end

function Registry:Register(cooldown, category, subtype)
    if not category or not MCE:CanUseFrameAsTableKey(cooldown) then return end
    if IsInternalVisualCooldown(cooldown) then
        RemoveEntry(cooldown)
        return
    end

    negativeOwnership[cooldown] = nil

    -- Registration is also the structural invalidation signal for action
    -- buttons. Adapters register again when a button is constructed/restyled,
    -- while ordinary cooldown broadcasts use the existing registry entry.
    InvalidateActionbarStructure(cooldown, category)

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
    RemoveEntry(cooldown)
end

function Registry:IsRegistered(cooldown)
    return TryGetEntry(cooldown) ~= nil
end

function Registry:GetEntry(cooldown)
    return TryGetEntry(cooldown)
end

function Registry:GetCategory(cooldown)
    local entry = TryGetEntry(cooldown)
    return entry and entry.category or nil
end

function Registry:GetSubtype(cooldown)
    local entry = TryGetEntry(cooldown)
    return entry and entry.subtype or nil
end

function Registry:SetSubtype(cooldown, subtype)
    local entry = TryGetEntry(cooldown)
    if entry then entry.subtype = subtype end
end

function Registry:GetCategoryAndNegative(cooldown)
    if not cooldown then
        return nil, false
    end

    local ok, entry, negativeGeneration = pcall(ReadOwnershipState, cooldown)
    if not ok then
        return nil, false
    end

    if entry then
        return entry.category, false
    end
    return nil, negativeGeneration == ownershipGeneration
end

function Registry:IsNegative(cooldown)
    local _, isNegative = self:GetCategoryAndNegative(cooldown)
    return isNegative
end

function Registry:MarkNegative(cooldown)
    if not MCE:CanUseFrameAsTableKey(cooldown) or entries[cooldown] then
        return
    end

    negativeOwnership[cooldown] = ownershipGeneration
end

function Registry:InvalidateOwnership()
    ownershipGeneration = ownershipGeneration + 1
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
    if not category or not adapter then return end

    local categoryAdapters = adapters[category]
    if not categoryAdapters then
        categoryAdapters = {}
        adapters[category] = categoryAdapters
    end

    InsertUnique(categoryAdapters, adapter)

    if InsertUnique(adapterOrder, adapter) then
        self:InvalidateOwnership()
    end
end

function Registry:GetAdapter(category)
    local categoryAdapters = adapters[category]
    if not categoryAdapters then
        return nil
    end

    return categoryAdapters[#categoryAdapters]
end

--- Ask each adapter to try claiming an unregistered cooldown.
--- Returns category, subtype if claimed; nil otherwise.
function Registry:TryClaim(cooldown)
    if not MCE:CanUseFrameAsTableKey(cooldown) then return nil end
    if IsInternalVisualCooldown(cooldown) then
        RemoveEntry(cooldown)
        return nil
    end
    if negativeOwnership[cooldown] == ownershipGeneration then
        return nil
    end

    for i = 1, #adapterOrder do
        local adapter = adapterOrder[i]
        local tryClaim = adapter.TryClaim
        if tryClaim then
            local cat, sub = tryClaim(adapter, cooldown)
            if cat then
                self:Register(cooldown, cat, sub)
                return cat, sub
            end
        end
    end
    return nil
end

function Registry:RebuildCategory(category)
    local categoryAdapters = adapters[category]
    if not categoryAdapters then
        return
    end

    self:InvalidateOwnership()

    for i = 1, #categoryAdapters do
        local adapter = categoryAdapters[i]
        if adapter and adapter.Rebuild then
            adapter:Rebuild()
        end
    end
end

function Registry:RebuildAll()
    self:InvalidateOwnership()

    for i = 1, #adapterOrder do
        local adapter = adapterOrder[i]
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
