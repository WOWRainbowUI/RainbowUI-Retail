local _, BR = ...

-- ============================================================================
-- LOADOUT DETECTION (talents / talent loadouts / equipment sets)
-- ============================================================================
-- Pure detection helpers for the "loadout" reminder category. None of them touch
-- the aura API, so they stay accurate in combat, encounters and M+.
--
-- BINDING. A rule stores the character and spec whose IDs its detection reads, so
-- a shared profile cannot leak one character's rules onto another as false
-- reminders. The save path stamps the binding; this module only reads it.
-- A rule with no stored specID or character applies everywhere.

local Loadouts = {}

local IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown
local IsPlayerSpell = IsPlayerSpell
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local UnitName = UnitName
local UnitClass = UnitClass
local GetRealmName = GetRealmName
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local C_ClassTalents = C_ClassTalents
local C_Traits = C_Traits
local C_EquipmentSet = C_EquipmentSet
local C_ChallengeMode = C_ChallengeMode
local C_Spell = C_Spell
local C_Timer = C_Timer
local Enum = Enum

local DEFAULT_TALENT_ICON = 133741 -- inv_misc_book_09: generic talent/loadout book icon, last resort
local DEFAULT_GEAR_ICON = 7539422 -- ui-transmog-showequippedgear: fallback for sets with no icon
local QUESTION_MARK_ICON = 134400

-- Bodies stay at file scope, not inline `pcall(function() ... end)`, so the
-- refresh-path callers below do not allocate a closure per rule per refresh.
local function ResolveCurrentSpecID()
    local idx = GetSpecialization()
    if not idx then
        return 0
    end
    return (GetSpecializationInfo(idx)) or 0
end

---Resolve the player's current spec ID (0 if none / not yet available).
---Prefers State's cached spec, so the per-rule refresh gating reuses one value
---instead of one spec API query per rule. Falls back to a live query while
---BR.StateHelpers is absent: Loadouts loads before State.
---@return number
local function GetCurrentSpecID()
    local helpers = BR.StateHelpers
    if helpers and helpers.GetPlayerSpecId then
        return helpers.GetPlayerSpecId() or 0
    end
    local ok, specID = pcall(ResolveCurrentSpecID)
    return (ok and specID) or 0
end
Loadouts.GetCurrentSpecID = GetCurrentSpecID

-- Character identity never changes during a session, so memoize it once. Only
-- cached after name AND realm resolve, so an early call cannot poison it with "?".
local cachedCharacterKey

---Stable identity for the current character ("Name - Realm"). Equipment / loadout
---rules bind to this because their IDs (setID, configID) are per-character.
---@return string
function Loadouts.GetCurrentCharacterKey()
    if cachedCharacterKey then
        return cachedCharacterKey
    end
    local name, realm = UnitName("player"), GetRealmName()
    local key = (name or "?") .. " - " .. (realm or "?")
    if name and realm then
        cachedCharacterKey = key
    end
    return key
end

---Localized spec name for a spec ID, or nil if unavailable.
---@param specID number?
---@return string?
local function ResolveSpecName(specID)
    if not specID then
        return nil
    end
    -- GetSpecializationInfoByID -> id, name, ...
    local ok, _, name = pcall(GetSpecializationInfoByID, specID)
    return (ok and name) or nil
end

---Display-only character name with the realm stripped off. Matching uses the
---full "Name - Realm" stored on the rule.
---@param character string?
---@return string?
local function CharacterDisplayName(character)
    if not character then
        return nil
    end
    return character:match("^(.-) %- ") or character
end

---Whether a rule's saved binding (spec / character) matches the current character.
---See the BINDING note at the top of the file.
---@param rule LoadoutRule
---@return boolean
function Loadouts.AppliesToCurrentCharacter(rule)
    if rule.require == "talent" then
        if rule.specID and rule.specID ~= GetCurrentSpecID() then
            return false
        end
    elseif rule.require == "loadout" then
        if rule.character and rule.character ~= Loadouts.GetCurrentCharacterKey() then
            return false
        end
        if rule.specID and rule.specID ~= GetCurrentSpecID() then
            return false
        end
    elseif rule.require == "gear" then
        if rule.character and rule.character ~= Loadouts.GetCurrentCharacterKey() then
            return false
        end
    end
    return true
end

---Human-readable "what this rule was saved on" for the list page, plus the class
---token so the caller can class-color it:
---  * talent  -> "<Spec> <Class>" (no character anchor, so name the class)
---  * gear    -> "<Name>"
---  * loadout -> "<Spec> · <Name>"  (spec-first, matching the talent ordering)
---Realm is stripped for display (see CharacterDisplayName); it lives on the rule
---for matching only. Returns nil text when the rule stores no binding.
---@param rule LoadoutRule
---@return string? text, string? classToken
function Loadouts.GetBindingLabel(rule)
    if rule.require == "talent" then
        local specName = ResolveSpecName(rule.specID)
        if not specName then
            return nil, rule.class
        end
        local className = rule.class and LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[rule.class]
        if className then
            return BR.L["Loadout.SpecClass"]:format(specName, className), rule.class
        end
        return specName, rule.class
    elseif rule.require == "gear" then
        return CharacterDisplayName(rule.character), rule.class
    elseif rule.require == "loadout" then
        local specName = ResolveSpecName(rule.specID)
        local charName = CharacterDisplayName(rule.character)
        if charName and specName then
            return specName .. " · " .. charName, rule.class
        end
        return charName or specName, rule.class
    end
    return nil, rule.class
end

-- ----------------------------------------------------------------------------
-- Requirement checks (return true == player is already correctly set up)
-- ----------------------------------------------------------------------------

local function ResolveTalentKnown(spellID)
    if IsSpellKnownOrOverridesKnown and IsSpellKnownOrOverridesKnown(spellID) then
        return true
    end
    return IsPlayerSpell and IsPlayerSpell(spellID) or false
end

---@param spellID number?
---@return boolean
function Loadouts.IsTalentKnown(spellID)
    if not spellID then
        return true
    end
    local ok, known = pcall(ResolveTalentKnown, spellID)
    return ok and known or false
end

local function ResolveLoadoutActive(specID, name)
    local cfgID = C_ClassTalents and C_ClassTalents.GetLastSelectedSavedConfigID(specID)
    if not cfgID then
        return false -- on a starter / unsaved build: no named loadout active
    end
    local info = C_Traits and C_Traits.GetConfigInfo(cfgID)
    return info ~= nil and info.name == name
end

---@param specID number?
---@param name string?
---@return boolean
function Loadouts.IsLoadoutActive(specID, name)
    if not name then
        return true
    end
    local ok, active = pcall(ResolveLoadoutActive, specID, name)
    return ok and active or false
end

-- Whether Talent Loadout Ex is installed and exposes its API. Memoized once
-- positive: an addon cannot unload mid-session. Re-probed while absent, because the
-- TLEx load order relative to BuffReminders is not guaranteed. An early probe must
-- not poison the result into skipping forever.
local tlxAvailable = false
local function IsTLXAvailable()
    if tlxAvailable then
        return true
    end
    ---@diagnostic disable-next-line: undefined-field
    local TLX = _G.TLX
    tlxAvailable = TLX ~= nil and TLX.GetLoadedData ~= nil
    return tlxAvailable
end
Loadouts.IsTLXAvailable = IsTLXAvailable

-- Resolve TLEx's stored loadout list for the current class + spec. TLEx keys its DB
-- account-wide by class token + spec INDEX (not spec ID). Returns nil when TLEx is
-- absent or has nothing saved for this spec. Callers wrap this in pcall.
local function GetTLXSpecTable()
    ---@diagnostic disable-next-line: undefined-field
    local db = _G.TalentLoadoutEx
    if not db then
        return nil
    end
    local _, class = UnitClass("player")
    local specIndex = GetSpecialization and GetSpecialization()
    if not class or not specIndex then
        return nil
    end
    return db[class] and db[class][specIndex]
end

local function ResolveTLXLoadoutIconBody(name)
    local specTable = GetTLXSpecTable()
    if not specTable then
        return nil
    end
    for _, data in ipairs(specTable) do
        if data.text and data.name == name then
            return data.icon
        end
    end
    return nil
end

-- Live-resolve a TLEx loadout's icon by name. The icon is a fileID number or an
-- atlas/path string. Returns nil when TLEx is absent or the name is not found, so
-- callers fall back to the rule's snapshotted icon / the spec icon.
local function ResolveTLXLoadoutIcon(name)
    if not name or not IsTLXAvailable() then
        return nil
    end
    local ok, icon = pcall(ResolveTLXLoadoutIconBody, name)
    return ok and icon or nil
end

local function ResolveTLXLoadoutActive(name)
    if not IsTLXAvailable() then
        return false
    end
    -- GetLoadedData() varargs the loadouts TLEx holds as loaded. It diffs each stored
    -- talent string against the active config. The pack makes the result scannable,
    -- and stays empty when TLEx computes none.
    ---@diagnostic disable-next-line: undefined-field
    local loaded = { _G.TLX.GetLoadedData() }
    for _, data in ipairs(loaded) do
        if data and data.name == name then
            return true
        end
    end
    return false
end

---Whether a Talent Loadout Ex loadout (matched by name within the current spec)
---is the one currently loaded. Talent Loadout Ex loadouts are NOT WoW named
---loadouts, so `C_ClassTalents` cannot see them. Detection goes through the TLEx
---public API. Returns false when TLEx is absent or holds no loaded state.
---@param name string?
---@return boolean
function Loadouts.IsTLXLoadoutActive(name)
    if not name then
        return true
    end
    local ok, active = pcall(ResolveTLXLoadoutActive, name)
    return ok and active or false
end

local function ResolveSetEquipped(setID)
    -- GetEquipmentSetInfo -> name, iconFileID, setID, isEquipped, ...
    local _, _, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(setID)
    return isEquipped == true
end

---@param setID number?
---@return boolean
function Loadouts.IsSetEquipped(setID)
    if not setID or not C_EquipmentSet then
        return setID == nil
    end
    local ok, equipped = pcall(ResolveSetEquipped, setID)
    return ok and equipped or false
end

---Whether the rule's expectation is currently met (no reminder needed).
---@param rule LoadoutRule
---@return boolean
function Loadouts.IsSatisfied(rule)
    if rule.require == "gear" then
        return Loadouts.IsSetEquipped(rule.gear and rule.gear.setID)
    elseif rule.require == "talent" then
        return Loadouts.IsTalentKnown(rule.spellID)
    elseif rule.require == "loadout" then
        -- Loadouts are per-spec: a rule for another spec does not apply now.
        if rule.specID and rule.specID ~= GetCurrentSpecID() then
            return true
        end
        if rule.loadout and rule.loadout.source == "tlex" then
            return Loadouts.IsTLXLoadoutActive(rule.loadout.name)
        end
        return Loadouts.IsLoadoutActive(rule.specID, rule.loadout and rule.loadout.name)
    end
    return true
end

-- ----------------------------------------------------------------------------
-- Instance context match (empty list == any)
-- ----------------------------------------------------------------------------

---@param instances table[]?
---@return boolean
function Loadouts.CurrentInstanceMatches(instances)
    if not instances or #instances == 0 then
        return true
    end
    -- Name is the one identifier that lines up across dungeons (GetMapUIInfo) and
    -- raids (Encounter Journal) with GetInstanceInfo, so it is the primary key. The
    -- challenge-map id is an exact match inside a keystone; mapID is a last resort.
    -- Identity comes from State's content-type cache: one GetInstanceInfo per zone
    -- instead of one per rule per refresh. State loads after this file, but only
    -- State.Refresh calls this function, so the runtime access is safe.
    local name, instanceID, activeChallenge = BR.BuffState.GetInstanceContext()
    for _, inst in ipairs(instances) do
        if inst.name and inst.name == name then
            return true
        end
        if activeChallenge and inst.id == activeChallenge then
            return true
        end
        if inst.mapID and inst.mapID == instanceID then
            return true
        end
    end
    return false
end

-- ----------------------------------------------------------------------------
-- Picker population (used by the rule editor dialog)
-- ----------------------------------------------------------------------------

---List the saved talent loadouts for a spec.
---@param specID number
---@return { name: string, configID: number }[]
function Loadouts.ListLoadouts(specID)
    local out = {}
    pcall(function()
        if not (C_ClassTalents and C_Traits) then
            return
        end
        local ids = C_ClassTalents.GetConfigIDsBySpecID(specID)
        if not ids then
            return
        end
        for _, cfgID in ipairs(ids) do
            local info = C_Traits.GetConfigInfo(cfgID)
            if info and info.name then
                out[#out + 1] = { name = info.name, configID = cfgID }
            end
        end
    end)
    return out
end

---List the Talent Loadout Ex loadouts saved for the current class + spec. TLEx
---stores account-wide keyed by class token + spec INDEX (not spec ID); group
---headers (entries without a `.text` talent string) are skipped. Returns an empty
---list when TLEx is absent, so the picker self-gates on its presence.
---@return { name: string, icon: number|string? }[]
function Loadouts.ListTLXLoadouts()
    local out = {}
    if not IsTLXAvailable() then
        return out
    end
    pcall(function()
        local specTable = GetTLXSpecTable()
        if not specTable then
            return
        end
        for _, data in ipairs(specTable) do
            if data.text and data.name then
                out[#out + 1] = { name = data.name, icon = data.icon }
            end
        end
    end)
    return out
end

---List the player's saved equipment sets.
---@return { setID: number, name: string, icon: number }[]
function Loadouts.ListEquipmentSets()
    local out = {}
    pcall(function()
        if not C_EquipmentSet then
            return
        end
        local ids = C_EquipmentSet.GetEquipmentSetIDs()
        if not ids then
            return
        end
        for _, setID in ipairs(ids) do
            local name, icon = C_EquipmentSet.GetEquipmentSetInfo(setID)
            out[#out + 1] = { setID = setID, name = name, icon = icon }
        end
    end)
    return out
end

---List the current season's instances (M+ dungeons + current raid tier).
---@return { id: number, mapID: number?, name: string, icon: number?, kind: string }[]
function Loadouts.ListCurrentInstances()
    local out = {}
    pcall(function()
        if C_ChallengeMode and C_ChallengeMode.GetMapTable then
            local maps = C_ChallengeMode.GetMapTable()
            if maps then
                for _, id in ipairs(maps) do
                    local name, _, _, texture, _, mapID = C_ChallengeMode.GetMapUIInfo(id)
                    if name then
                        out[#out + 1] = { id = id, mapID = mapID, name = name, icon = texture, kind = "dungeon" }
                    end
                end
            end
        end
    end)
    -- The Encounter Journal can be unloaded, so the raid list stays optional.
    pcall(function()
        if not (EJ_GetCurrentTier and EJ_SelectTier and EJ_GetInstanceByIndex) then
            return
        end
        EJ_SelectTier(EJ_GetCurrentTier())
        local i = 1
        while true do
            -- 10th return = shouldDisplayDifficulty: false for world-boss groupings
            -- (e.g. the "Midnight" world-boss zone), true for real raid instances.
            -- (Slot 9 is the instance link string; mapID sits at 8, shifting this.)
            local instanceID, name, _, _, buttonImage, _, _, _, _, shouldDisplayDifficulty =
                EJ_GetInstanceByIndex(i, true)
            if not instanceID then
                break
            end
            if shouldDisplayDifficulty ~= false then
                out[#out + 1] = { id = instanceID, name = name, icon = buttonImage, kind = "raid" }
            end
            i = i + 1
        end
    end)
    return out
end

-- ----------------------------------------------------------------------------
-- Display + fix helpers
-- ----------------------------------------------------------------------------

---Resolve the icon for a rule. The set or spec icon changes after the rule is
---saved, so this resolves live on each refresh. Falls back to the rule's cached
---icon, then to a per-type default.
---@param rule LoadoutRule
---@return number|string
function Loadouts.GetRuleIcon(rule)
    if rule.require == "talent" and rule.spellID then
        local ok, tex = pcall(C_Spell.GetSpellTexture, rule.spellID)
        if ok and tex then
            return tex
        end
    elseif rule.require == "gear" and rule.gear and rule.gear.setID then
        -- GetEquipmentSetInfo -> name, iconFileID, ...
        local ok, _, icon = pcall(C_EquipmentSet.GetEquipmentSetInfo, rule.gear.setID)
        if ok and icon and icon ~= QUESTION_MARK_ICON then
            return icon
        end
        return DEFAULT_GEAR_ICON
    elseif rule.require == "loadout" then
        -- TLEx loadouts carry their own icon. Resolve it live by name, so an external
        -- re-icon in TalentLoadoutEx shows up. Falls back to the rule's snapshot when
        -- TLEx is absent or the loadout is deleted.
        if rule.loadout and rule.loadout.source == "tlex" then
            local live = ResolveTLXLoadoutIcon(rule.loadout.name)
            if live and live ~= QUESTION_MARK_ICON then
                return live
            end
            if rule.icon and rule.icon ~= QUESTION_MARK_ICON then
                return rule.icon
            end
            -- fall through to the spec icon below
        end
        if rule.specID then
            -- GetSpecializationInfoByID -> id, name, description, icon, ...
            local ok, _, _, _, icon = pcall(GetSpecializationInfoByID, rule.specID)
            if ok and icon then
                return icon
            end
        end
    end
    if rule.icon and rule.icon ~= QUESTION_MARK_ICON then
        return rule.icon
    end
    return DEFAULT_TALENT_ICON
end

-- The talent UI's loadout dropdown reflects the spec's "last selected saved config".
-- That stamp only sticks after the config commits. A swap that changes points returns
-- LoadInProgress and runs the "Changing Talents" cast. A stamp before that commit is
-- lost: the talent frame re-derives the dropdown on commit and shows the OLD loadout.
-- So the in-progress case defers the stamp to the next TRAIT_CONFIG_UPDATED. A
-- generation token and a timeout stop a pending stamp from landing on an unrelated
-- later commit when the cast never completes.
local dropdownSyncFrame = CreateFrame("Frame")
local pendingSync
local syncGen = 0

local function StampLastSelected(specID, configID)
    if C_ClassTalents.UpdateLastSelectedSavedConfigID then
        pcall(C_ClassTalents.UpdateLastSelectedSavedConfigID, specID, configID)
    end
    -- Blizzard bug: an ALREADY-OPEN talent frame does not re-read the last-selected
    -- config after an API change, so its loadout dropdown keeps the previous set until
    -- /reload. If the frame is loaded, nudge its dropdown with the same SetSelectionID
    -- the UI uses internally. PlayerSpellsFrame is load-on-demand and nil until the
    -- first open; an unloaded dropdown reads fresh on the next open.
    local tab = PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame
    local dropdown = tab and tab.LoadSystem
    if dropdown and dropdown.SetSelectionID then
        pcall(dropdown.SetSelectionID, dropdown, configID)
    end
end

dropdownSyncFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("TRAIT_CONFIG_UPDATED")
    local sync = pendingSync
    pendingSync = nil
    if sync then
        StampLastSelected(sync.specID, sync.configID)
    end
end)

local function QueueDropdownSync(specID, configID)
    syncGen = syncGen + 1
    local myGen = syncGen
    pendingSync = { specID = specID, configID = configID }
    dropdownSyncFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    C_Timer.After(8, function()
        -- A newer queue bumps syncGen, so clear only a stamp from this generation.
        if myGen == syncGen and pendingSync then
            pendingSync = nil
            dropdownSyncFrame:UnregisterEvent("TRAIT_CONFIG_UPDATED")
        end
    end)
end

-- Load a WoW named talent loadout in place. Re-resolve the configID by name for
-- the current spec first: configIDs are per-character, so the id snapshotted on the
-- rule can be stale on an alt that shares the loadout name. Falls back to the stored
-- id, and returns false when no configID resolves.
---@param rule LoadoutRule
---@return boolean
local function LoadWoWLoadout(rule)
    if not (C_ClassTalents and C_ClassTalents.LoadConfig) then
        return false
    end
    local specID = rule.specID or GetCurrentSpecID()
    local name = rule.loadout and rule.loadout.name
    local configID
    if name then
        for _, entry in ipairs(Loadouts.ListLoadouts(specID)) do
            if entry.name == name then
                configID = entry.configID
                break
            end
        end
    end
    configID = configID or (rule.loadout and rule.loadout.configID)
    if not configID then
        return false
    end
    local result = C_ClassTalents.LoadConfig(configID, true)
    if result == nil or result == Enum.LoadConfigResult.Error then
        return false
    end
    if result == Enum.LoadConfigResult.LoadInProgress then
        QueueDropdownSync(specID, configID)
    else
        StampLastSelected(specID, configID) -- Ready / NoChangesNecessary: applied synchronously
    end
    return true
end

---Act on a clicked reminder: equip the gear set, load the talent loadout, or open
---the talent UI. Gear swaps and talent edits are blocked in combat by the client;
---guard early so the user gets a clear message instead of a silent no-op.
---@param rule LoadoutRule
function Loadouts.ApplyFix(rule)
    if InCombatLockdown() then
        UIErrorsFrame:AddMessage(BR.L["Loadout.CombatBlocked"], 1, 0.3, 0.3)
        return
    end
    if rule.require == "gear" and rule.gear and rule.gear.setID then
        pcall(C_EquipmentSet.UseEquipmentSet, rule.gear.setID)
        return
    end
    -- WoW named loadout: load it in place. TLEx loadouts are not WoW configs, so
    -- they fall through to opening the UI.
    if rule.require == "loadout" and rule.loadout and rule.loadout.source ~= "tlex" then
        local ok, loaded = pcall(LoadWoWLoadout, rule)
        if ok and loaded then
            return
        end
    end
    -- talent / TLEx loadout / unresolved: open the talent UI so the user finishes by hand.
    pcall(function()
        if PlayerSpellsUtil and PlayerSpellsUtil.OpenToClassTalentsTab then
            PlayerSpellsUtil.OpenToClassTalentsTab()
        elseif ToggleTalentFrame then
            ToggleTalentFrame()
        end
    end)
end

BR.Loadouts = Loadouts
