local _, BR = ...

-- The external defensives and buffs shown by Display/AuraTracker.lua, plus the
-- accessors every consumer of that feature needs. Loads before Display and Options,
-- so both can alias the accessors at file scope. The curated list below is only
-- half the set: BR.GetExternalEntries merges the player's own entries onto it, and
-- that accessor - never BR.EXTERNALS - is what consumers walk.
--
-- Every entry is a HELPFUL aura on the player, which is the only shape Blizzard
-- permits spell-ID filtering for - "spell ID matching is only permitted for helpful
-- buffs on assistable units". A harmful aura on yourself can never be tracked, so
-- this list is buffs-you-receive by construction.
--
-- `section` buckets an entry under a heading in the options list. `labelKey` is only
-- needed when one entry spans spells with different names, since single-name entries
-- take their label from the spell itself and localize for free. `labelSpellID` names
-- an entry after the ability that grants the aura, for auras whose own name misleads.

---Display groupings, in the order the options page renders them.
BR.EXTERNAL_SECTIONS = {
    { key = "defensives", titleKey = "Externals.Defensives" },
    { key = "groupBuffs", titleKey = "Externals.GroupBuffs" },
    { key = "movement", titleKey = "Externals.Movement" },
    { key = "aggro", titleKey = "Externals.Aggro" },
    { key = "augmentation", titleKey = "Externals.Augmentation" },
}

-- Within a section, entries are ordered by their English name: the options page
-- renders them in this order, so the list reads alphabetically with no sort.
BR.EXTERNALS = {
    { key = "ancestralProtection", section = "defensives", spellIDs = { 207498 } }, -- Shaman
    { key = "antiMagicZone", section = "defensives", spellIDs = { 145629 } }, -- Death Knight
    { key = "auraMastery", section = "defensives", spellIDs = { 31821 } }, -- Paladin
    { key = "blessingOfProtection", section = "defensives", spellIDs = { 1022 } }, -- Paladin
    { key = "blessingOfSacrifice", section = "defensives", spellIDs = { 6940 } }, -- Paladin
    { key = "blessingOfSpellwarding", section = "defensives", spellIDs = { 204018 } }, -- Paladin
    { key = "darkness", section = "defensives", spellIDs = { 209426 } }, -- Demon Hunter
    { key = "earthenWall", section = "defensives", spellIDs = { 201633 } }, -- Shaman
    { key = "guardianSpirit", section = "defensives", spellIDs = { 47788 } }, -- Priest
    { key = "intervene", section = "defensives", spellIDs = { 147833 } }, -- Warrior
    { key = "ironbark", section = "defensives", spellIDs = { 102342 } }, -- Druid
    { key = "lifeCocoon", section = "defensives", spellIDs = { 116849 } }, -- Monk
    { key = "luminousBarrier", section = "defensives", spellIDs = { 271466 } }, -- Priest
    {
        key = "massBarrier", -- Mage
        section = "defensives",
        labelKey = "Externals.MassBarrier",
        spellIDs = {
            414661, -- Ice Barrier
            414662, -- Blazing Barrier
            414663, -- Prismatic Barrier
        },
    },
    { key = "painSuppression", section = "defensives", spellIDs = { 33206 } }, -- Priest
    { key = "powerWordBarrier", section = "defensives", spellIDs = { 81782 } }, -- Priest
    { key = "timeDilation", section = "defensives", spellIDs = { 357170 } }, -- Evoker
    { key = "zephyr", section = "defensives", spellIDs = { 374227 } }, -- Evoker

    {
        key = "blessingOfSeasons", -- Paladin
        defaultSound = false,
        section = "groupBuffs",
        labelKey = "Externals.BlessingOfSeasons",
        spellIDs = {
            388007, -- Blessing of Summer
            388010, -- Blessing of Autumn
            388011, -- Blessing of Winter
            388013, -- Blessing of Spring
        },
    },
    {
        key = "bloodlust", -- Shaman + the cross-class variants
        section = "groupBuffs",
        labelKey = "Externals.Bloodlust",
        spellIDs = {
            2825, -- Bloodlust
            32182, -- Heroism
            80353, -- Time Warp
            90355, -- Ancient Hysteria
            264667, -- Primal Rage
            390386, -- Fury of the Aspects
        },
    },
    { key = "innervate", section = "groupBuffs", spellIDs = { 29166 } }, -- Druid
    { key = "powerInfusion", section = "groupBuffs", spellIDs = { 10060 } }, -- Priest
    { key = "rallyingCry", section = "groupBuffs", spellIDs = { 97463 } }, -- Warrior
    { key = "spatialParadox", section = "groupBuffs", spellIDs = { 406789 } }, -- Evoker

    { key = "blessingOfFreedom", section = "movement", spellIDs = { 1044 } }, -- Paladin
    { key = "stampedingRoar", section = "movement", spellIDs = { 106898, 77761, 77764 } }, -- Druid
    { key = "tigersLust", section = "movement", spellIDs = { 116841 } }, -- Monk
    {
        key = "timeSpiral", -- Evoker
        section = "movement",
        spellIDs = {
            375234, -- Time Spiral itself; the rest are its per-class movement buffs
            375226,
            375229,
            375230,
            375238,
            375240,
            375252,
            375253,
            375254,
            375255,
            375256,
            375257,
            375258,
        },
    },
    { key = "windRushTotem", section = "movement", spellIDs = { 192082 }, defaultSound = false }, -- Shaman

    { key = "misdirection", section = "aggro", spellIDs = { 34477 }, defaultSound = false }, -- Hunter
    { key = "tricksOfTheTrade", section = "aggro", spellIDs = { 57934 }, defaultSound = false }, -- Rogue

    -- Not whitelisted since 12.1, so the reminder pipeline cannot see these in combat.
    -- A container still can.
    { key = "blisteringScales", section = "augmentation", spellIDs = { 360827 }, defaultSound = false }, -- Evoker
    { key = "ebonMight", section = "augmentation", spellIDs = { 395152, 395296 }, defaultSound = false }, -- Evoker
    { key = "prescience", section = "augmentation", spellIDs = { 410089 }, defaultSound = false }, -- Evoker
}

---The live externals settings table. Single accessor for every consumer, so the
---pre-seeding fallback can never diverge between the engine and the options pages.
---@return table
function BR.GetExternalSettings()
    return BR.profile and BR.profile.externals or BR.defaults.externals
end

---True while the player tracks at least one external. The entry set is the
---switch: nothing ticked means nothing to draw and nothing to play.
---@return boolean
function BR.AreExternalsEnabled()
    local entries = BR.GetExternalSettings().entries
    return entries ~= nil and next(entries) ~= nil
end

local floor = math.floor

-- Appearance keys that follow the global `defaults` table while
-- externals.useCustomAppearance is off. durationSize and growDirection are
-- absent on purpose: `defaults` has no countdown text, and its growDirection
-- allows CENTER, which the flow layout has no value for.
local INHERITED_KEYS = {
    iconSize = true,
    iconWidth = true,
    iconZoom = true,
    borderSize = true,
    iconAlpha = true,
    spacing = true,
}

---Effective value for one externals setting, with inheritance from the global
---defaults - the externals counterpart of BR.Config.GetCategorySetting.
---@param key string
---@return any
function BR.GetExternalSetting(key)
    local settings = BR.GetExternalSettings()
    if not INHERITED_KEYS[key] or settings.useCustomAppearance then
        return settings[key]
    end
    local defaults = BR.profile and BR.profile.defaults or BR.defaults.defaults
    if key == "spacing" then
        -- defaults.spacing is a size multiplier; the flow layout wants absolute px.
        -- Same math as the reminder rows' horizontal gap.
        local width = defaults.iconWidth or defaults.iconSize or 64
        return floor((defaults.spacing or 0) * width)
    end
    return defaults[key]
end

---Sound value for one entry: its own override, or the page sound while it inherits.
---`defaultSound = false` marks an entry that re-applies too often for the shared
---sound, so it stays silent until the player overrides it.
---@param entry table
---@return string|nil
function BR.GetExternalEntrySound(entry)
    local settings = BR.GetExternalSettings()
    local sounds = settings.sounds
    local value = sounds and sounds[entry.key]
    if value ~= nil then
        return value
    end
    if entry.defaultSound == false then
        return nil
    end
    return settings.sound
end

---True while an entry carries its own sound instead of inheriting the shared one.
---@param key string
---@return boolean
function BR.IsExternalSoundOverridden(key)
    local sounds = BR.GetExternalSettings().sounds
    return sounds ~= nil and sounds[key] ~= nil
end

---Display label for an entry: the player's own name when set, an explicit key when
---the entry spans differently-named spells, otherwise the (already localized) name
---of labelSpellID or the spell itself.
---@param entry table
---@return string
function BR.GetExternalLabel(entry)
    if entry.name then
        return entry.name
    end
    if entry.labelKey then
        return BR.L[entry.labelKey] or entry.key
    end
    local spellID = entry.labelSpellID or entry.spellIDs[1]
    return BR.GetSpellName(spellID) or tostring(spellID)
end

-- ============================================================================
-- THE PLAYER'S OWN ENTRIES
-- ============================================================================
-- Stored under externals.custom. These entries share the `entries` and `sounds`
-- tables with the curated set, so a key must never collide with a curated one.

---@class ExternalCustomEntry
---@field spellIDs number[]
---@field name? string
---@field labelSpellID? number

local tsort = table.sort
local type = type

---Every entry the addon knows: the curated list first, then the player's own,
---sorted by label. Rebuilt on each call, because the callers run on settings
---changes and world events - a cache here adds only a way to go stale.
---@return table[]
function BR.GetExternalEntries()
    local custom = BR.GetExternalSettings().custom
    if not custom or next(custom) == nil then
        return BR.EXTERNALS
    end

    local own = {}
    for key, def in pairs(custom) do
        -- A hand-edited SavedVariables file reaches this table too, so an entry
        -- without a usable spell ID is dropped rather than handed to the engine.
        if type(def) == "table" and type(def.spellIDs) == "table" and type(def.spellIDs[1]) == "number" then
            own[#own + 1] = {
                key = key,
                spellIDs = def.spellIDs,
                name = def.name,
                labelSpellID = def.labelSpellID,
                custom = true,
            }
        end
    end
    tsort(own, function(a, b)
        return BR.GetExternalLabel(a) < BR.GetExternalLabel(b)
    end)

    local merged = {}
    for _, entry in ipairs(BR.EXTERNALS) do
        merged[#merged + 1] = entry
    end
    for _, entry in ipairs(own) do
        merged[#merged + 1] = entry
    end
    return merged
end

---A key for a new custom entry. The prefix keeps it clear of every curated key,
---and the timestamp keeps it stable across an edit that changes the spell IDs, so
---the entry keeps its tracked state and its sound override.
---@param spellID number
---@return string
function BR.NewExternalKey(spellID)
    return "ext_" .. spellID .. "_" .. time()
end

---The first entry other than `exceptKey` that already lists this spell ID.
---@param spellID number
---@param exceptKey string?
---@return table?
function BR.FindExternalBySpellID(spellID, exceptKey)
    for _, entry in ipairs(BR.GetExternalEntries()) do
        if entry.key ~= exceptKey then
            for _, id in ipairs(entry.spellIDs) do
                if id == spellID then
                    return entry
                end
            end
        end
    end
    return nil
end

---The entry that takes this entry's sound, or nil while this entry keeps its own.
---Mirrors the first-wins rule in Display/AuraSounds.lua: an earlier tracked entry
---with a sound claims every spell ID it lists, and an entry loses its alert only
---when every one of its IDs is claimed.
---@param entry table
---@return table?
function BR.FindExternalSoundOwner(entry)
    local tracked = BR.GetExternalSettings().entries
    if not tracked or not tracked[entry.key] then
        return nil
    end

    local all = BR.GetExternalEntries()
    local owner
    for _, id in ipairs(entry.spellIDs) do
        local claimant
        for _, other in ipairs(all) do
            if other.key == entry.key then
                break
            end
            if tracked[other.key] and BR.GetExternalEntrySound(other) then
                for _, otherID in ipairs(other.spellIDs) do
                    if otherID == id then
                        claimant = other
                        break
                    end
                end
            end
            if claimant then
                break
            end
        end
        if not claimant then
            return nil
        end
        owner = owner or claimant
    end
    return owner
end
