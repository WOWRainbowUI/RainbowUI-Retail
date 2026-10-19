local _, BR = ...
local L = BR.L

-- ============================================================================
-- PET HELPERS MODULE
-- ============================================================================
-- Builds per-class lists of pet summon actions for expanded pet icons.

-- ============================================================================
-- TYPE DEFINITIONS
-- ============================================================================

---@class PetAction
---@field key string
---@field spellID number
---@field spellName string             -- Localized spell name for SecureActionButton casting
---@field icon number
---@field label string
---@field sortOrder number
---@field petFamily? string            -- Pet specialization (hunter only, e.g. "Ferocity")
---@field petSpecIcon? number          -- Spec ability icon texture (hunter only)
---@field petSpiritBeast? boolean      -- True if Spirit Beast family

---@class PetActionList : PetAction[]
---@field genericIndex? number  -- Preferred index for generic (collapsed) display mode

-- Hunter Call Pet spell IDs (Call Pet 1 through Call Pet 5)
local CALL_PET_SPELLS = { 883, 83242, 83243, 83244, 83245 }

local REVIVE_PET = 982

-- Hunter pet spec -> ability icon texture
local PET_SPEC_ICONS = {
    Cunning = 348567,
    Ferocity = 136224,
    Tenacity = 571585,
}

local SUMMON_DEMON_FLYOUT = 10
local SUMMON_FELHUNTER = 691
local SUMMON_FELGUARD = 30146

-- Warlock summon spell ID -> short pet name (fallback: full spell name)
local WARLOCK_PET_NAMES = {
    [688] = L["Label.Imp"],
    [697] = L["Label.Voidwalker"],
    [691] = L["Label.Felhunter"],
    [366222] = L["Label.Sayaad"],
    [30146] = L["Label.Felguard"],
}

-- Warlock summon spell ID -> creature family IDs that UnitCreatureFamily reports for
-- the pet. Cosmetic reskins (Wrathguard, Incubus, ...) report their own family.
local WARLOCK_DEMON_FAMILIES = {
    [688] = { [23] = true, [100] = true }, -- Imp
    [697] = { [16] = true, [101] = true }, -- Voidwalker
    [691] = { [15] = true, [103] = true }, -- Felhunter
    [366222] = { [17] = true, [102] = true, [302] = true }, -- Sayaad
    [30146] = { [29] = true, [104] = true }, -- Felguard
}

-- Resolve Spirit Beast family name from Blizzard's creature family data (localized)
local SPIRIT_BEAST_FAMILY = (C_CreatureInfo.GetCreatureFamilyInfo(46) or {}).name or "Spirit Beast"

---Build hunter pet actions from stable info
---@return PetAction[]?
local function BuildHunterActions()
    -- Marksmanship hunters have no pet without Unbreakable Bond.
    if BR.StateHelpers.GetPlayerSpecId() == 254 and not IsPlayerSpell(1223323) then
        return nil
    end

    local canUseExotic = IsPlayerSpell(53270) -- Exotic Beasts (BM passive)
    local actions = {}
    local order = 0

    for slotIndex, spellID in ipairs(CALL_PET_SPELLS) do
        if IsPlayerSpell(spellID) then
            local info = C_StableInfo.GetStablePetInfo(slotIndex)
            if info and info.name and info.icon and (not info.isExotic or canUseExotic) then
                order = order + 1
                actions[#actions + 1] = {
                    key = "pet_action_" .. spellID,
                    spellID = spellID,
                    spellName = BR.GetSpellName(spellID),
                    icon = info.icon,
                    label = info.name,
                    sortOrder = order,
                    petFamily = info.specialization,
                    petSpecIcon = PET_SPEC_ICONS[info.specialization],
                    petSpiritBeast = info.familyName == SPIRIT_BEAST_FAMILY or nil,
                }
            end
        end
    end

    if #actions > 0 and IsPlayerSpell(REVIVE_PET) then
        order = order + 1
        local icon = C_Spell.GetSpellTexture(REVIVE_PET)
        if icon then
            actions[#actions + 1] = {
                key = "pet_action_" .. REVIVE_PET,
                spellID = REVIVE_PET,
                spellName = BR.GetSpellName(REVIVE_PET),
                icon = icon,
                label = L["Label.RevivePet"],
                sortOrder = order,
            }
        end
    end

    return #actions > 0 and actions or nil
end

---Build warlock pet actions from the Summon Demon flyout
---@return PetAction[]?
local function BuildWarlockActions()
    local ok, _, _, numSlots, isKnown = pcall(GetFlyoutInfo, SUMMON_DEMON_FLYOUT)
    if not ok or not isKnown or not numSlots then
        return nil
    end

    local actions = {}
    local order = 0

    for i = 1, numSlots do
        local slotOk, spellID, _, slotIsKnown = pcall(GetFlyoutSlotInfo, SUMMON_DEMON_FLYOUT, i)
        if slotOk and spellID and slotIsKnown then
            local info = C_Spell.GetSpellInfo(spellID)
            if info then
                order = order + 1
                actions[#actions + 1] = {
                    key = "pet_action_" .. spellID,
                    spellID = spellID,
                    spellName = info.name,
                    icon = info.iconID,
                    label = WARLOCK_PET_NAMES[spellID] or info.name,
                    sortOrder = order,
                }
            end
        end
    end

    return #actions > 0 and actions or nil
end

---@param actions PetActionList
---@param spellID number
---@return number?
local function IndexOfSpell(actions, spellID)
    for idx, action in ipairs(actions) do
        if action.spellID == spellID then
            return idx
        end
    end
    return nil
end

-- Content type -> warlockDemon row. Other content uses the world row.
local DEMON_ROW_BY_CONTENT = { dungeon = "dungeon", scenario = "dungeon", raid = "raid", pvp = "pvp" }
local DEFAULT_WARLOCK_DEMON = BR.defaults.defaults.warlockDemon

---Summon spell ID that the player wants for the current content type.
---@return number
local function GetPreferredDemonSpell()
    local row = DEMON_ROW_BY_CONTENT[BR.StateHelpers.GetCurrentContentType()] or "world"
    local defaults = BR.profile.defaults
    local prefs = defaults and defaults.warlockDemon
    return prefs and prefs[row] or DEFAULT_WARLOCK_DEMON[row]
end

---Felguard on Demonology overrides the preferred demon. A preferred demon that
---is not in the flyout falls back to Felhunter (interrupt).
---@param actions PetActionList
---@param preferred number
---@return number?
local function ResolveWarlockGenericIndex(actions, preferred)
    if BR.StateHelpers.GetPlayerSpecId() == 266 then
        local idx = IndexOfSpell(actions, SUMMON_FELGUARD)
        if idx then
            return idx
        end
    end
    return IndexOfSpell(actions, preferred) or IndexOfSpell(actions, SUMMON_FELHUNTER)
end

-- These classes summon one pet with one spell. The name is the short name a
-- player uses. The full spell name is the fallback.
local SINGLE_PET = {
    DEATHKNIGHT = { spellID = 46584, name = L["Label.Ghoul"] }, -- Raise Dead
    MAGE = { spellID = 31687, name = L["Label.WaterElemental"] }, -- Summon Water Elemental
}

local SINGLE_PET_NAMES = {}
for _, pet in pairs(SINGLE_PET) do
    SINGLE_PET_NAMES[pet.spellID] = pet.name
end

---Build a single-action list for a given spell
---@param spellID number
---@return PetAction[]?
local function BuildSingleAction(spellID)
    if not IsPlayerSpell(spellID) then
        return nil
    end
    local info = C_Spell.GetSpellInfo(spellID)
    if not info then
        return nil
    end
    return {
        {
            key = "pet_action_" .. spellID,
            spellID = spellID,
            spellName = info.name,
            icon = info.iconID,
            label = SINGLE_PET_NAMES[spellID] or info.name,
            sortOrder = 1,
        },
    }
end

---@type PetActionList?
local cachedActions = nil
local cacheValid = false
local resolvedPreferredPet = nil
-- Single-entry list for the wrong-demon reminder: click summons the desired demon.
---@type PetActionList?
local cachedDesiredDemonList = nil

local CLASS_PET_BUILDERS = {
    HUNTER = BuildHunterActions,
    WARLOCK = BuildWarlockActions,
}
for class, pet in pairs(SINGLE_PET) do
    CLASS_PET_BUILDERS[class] = function()
        return BuildSingleAction(pet.spellID)
    end
end

---Build and cache the list of pet summon actions for the given class.
---Returns cached result on subsequent calls until invalidated.
---@param class ClassName
---@return PetActionList?
local function GetPetActions(class)
    if not cacheValid then
        local builder = CLASS_PET_BUILDERS[class]
        cachedActions = builder and builder() or nil
        resolvedPreferredPet = nil
        cachedDesiredDemonList = nil
        cacheValid = true
    end

    -- Keyed on the preferred spell, so a content change, a profile switch or an
    -- import also re-resolves.
    if cachedActions and class == "WARLOCK" then
        local preferred = GetPreferredDemonSpell()
        if preferred ~= resolvedPreferredPet then
            local gi = ResolveWarlockGenericIndex(cachedActions, preferred)
            cachedActions.genericIndex = gi
            cachedDesiredDemonList = gi and { cachedActions[gi], genericIndex = 1 } or nil
            resolvedPreferredPet = preferred
        end
    end
    return cachedActions
end

---The warlock demon that the player wants out now, or nil if none can be summoned.
---@return PetAction?
local function GetDesiredWarlockDemon()
    local actions = GetPetActions("WARLOCK")
    return actions and actions.genericIndex and actions[actions.genericIndex] or nil
end

---@return PetActionList?
local function GetDesiredWarlockDemonList()
    GetPetActions("WARLOCK")
    return cachedDesiredDemonList
end

---Invalidate cached pet actions (call on spec/talent/stable changes).
local function InvalidatePetActions()
    cacheValid = false
    cachedActions = nil
    cachedDesiredDemonList = nil
end

-- Export
BR.PetHelpers = {
    REVIVE_PET_ID = REVIVE_PET,
    GetPetActions = GetPetActions,
    WARLOCK_DEMON_FAMILIES = WARLOCK_DEMON_FAMILIES,
    GetDesiredWarlockDemon = GetDesiredWarlockDemon,
    GetDesiredWarlockDemonList = GetDesiredWarlockDemonList,
    InvalidatePetActions = InvalidatePetActions,
}

BR.GameContext.RegisterCache("petActions", InvalidatePetActions)
