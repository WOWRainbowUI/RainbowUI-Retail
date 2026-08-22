-- BliZzi Party Tools — public profile API for UI pack tooling
-- ============================================================
-- Implements the profile-management surface that the Wago UI Pack
-- installer calls to export / import / switch profiles during pack
-- creation and setup. The functions follow the documented contract:
--   * ExportProfile must export ANY profile by name (not just the
--     active one) and the string must round-trip through the addon's
--     own import/export system — ours does, it IS the native format.
--   * ImportProfile must land the data under the given profileKey and
--     make it the active profile.
--   * No ReloadUI() calls anywhere in here (the pack installer batches
--     reloads itself); our import applies live anyway.
--
-- Everything routes through the existing profile engine in
-- Profile/Profile.lua + Profile/Profiles.lua — no duplicate logic.
-- ============================================================

BliZziPartyToolsAPI = BliZziPartyToolsAPI or {}
local API = BliZziPartyToolsAPI

-- Virtual "bundle" profile key exposed to the Wago UI Pack tooling.
-- The pack installer lets the creator pick ONE profile from the list
-- getProfileKeys() returns — it reads that list live from the addon,
-- it does NOT go through our export popup. But this addon's setup is
-- usually SEVERAL profiles plus the spec-to-profile map (the role/spec
-- auto-switching), so picking a single real profile loses the rest on
-- the user's side (e.g. only Healer OR DPS/Tank, never both).
--
-- The fix: ALWAYS expose one extra virtual key in getProfileKeys(). It
-- looks like a normal profile to the pack tooling; exporting it produces
-- the addon's native FULL bundle (all profiles + spec assignments +
-- active-profile pointer); importing that string restores everything.
-- The key is always present (not gated behind any manual export) so the
-- creator always finds it in the pack creator's dropdown.
--
-- The DISPLAYED name is creator-configurable (Profiles settings page →
-- "UI Pack Bundle") and stored at the SavedVariables ROOT — account-
-- wide, never inside a profile, so it neither ships with exports nor
-- resets on profile switches. It defaults to a fixed fallback so the
-- entry is present even before the creator sets a name. IMPORT never
-- compares against this name (the installing user's value differs from
-- the creator's) — the import side detects bundles by payload shape.

local BUNDLE_NAME_DEFAULT = "All Profiles"

local function SV()
    return BliZziInterruptsSavedVars
end

---@return string  the bundle entry's display name (never nil/empty)
local function BundleKey()
    local sv = SV()
    local name = sv and sv.wagoBundleName
    if type(name) == "string" then
        name = name:gsub("^%s+", ""):gsub("%s+$", "")
        if name ~= "" then return name end
    end
    return BUNDLE_NAME_DEFAULT
end

---@param profileKey string  the name of the profile to export
---@return string|nil        encoded profile string ("!BIT!" format)
function API:ExportProfile(profileKey)
    if type(profileKey) ~= "string" or profileKey == "" then return nil end
    -- Virtual bundle entry: ship EVERY profile + the spec map + the
    -- active-profile pointer (includeBundle omitted → defaults to the
    -- ship-everything path). Checked before the real-profile lookup, so
    -- a real profile that happens to share the chosen name is shadowed
    -- for pack export (the creator set that name deliberately).
    if profileKey == BundleKey() then
        return BIT.ExportProfile(false, false)
    end
    local sv = SV()
    if not (sv and sv.profiles and sv.profiles[profileKey]) then return nil end
    -- categories=false → no flat settings section (the bundle already
    -- carries the complete profile table, positions included);
    -- includeBundle as a set → exactly this one profile ships.
    return BIT.ExportProfile(false, false, { [profileKey] = true })
end

---@param profileString string  encoded profile string
---@param profileKey string     name the imported profile should get
function API:ImportProfile(profileString, profileKey)
    if type(profileString) ~= "string" or profileString == "" then return end
    -- Bundle detection is by PAYLOAD SHAPE, never by comparing
    -- profileKey against our local bundle name: the creator chose the
    -- displayed name on THEIR client, so on the installing user's side
    -- the key is an arbitrary string we cannot predict. A multi-profile
    -- payload is imported without a rename target (its profiles keep
    -- the creator's names) and restores its own active profile inside
    -- the importer — no explicit switch afterwards.
    if BIT.PeekProfileImport then
        local kind, meta = BIT.PeekProfileImport(profileString)
        if kind == "bundle" and type(meta) == "table"
           and (meta.profiles or 0) > 1 then
            BIT.ImportProfile(profileString, nil)
            return
        end
    end
    -- Single-profile bundles are renamed to profileKey by the importer;
    -- afterwards we switch to it explicitly — the payload only carries
    -- an active-profile pointer when the profile was active on export.
    local ok = BIT.ImportProfile(profileString, profileKey)
    if ok and type(profileKey) == "string" and profileKey ~= ""
       and BIT.Profiles and BIT.Profiles.Exists and BIT.Profiles:Exists(profileKey) then
        BIT.Profiles:Switch(profileKey)
    end
end

---@param profileString string
---@return table|nil  decoded profile data (for comparisons / changelogs)
function API:DecodeProfileString(profileString)
    local payload = BIT.DecodeProfileString and BIT.DecodeProfileString(profileString)
    if not payload then return nil end
    -- For the single-profile bundles this API exports, the comparable
    -- data is the inner profile table — return it directly so diffs
    -- aren't polluted by volatile envelope fields (addonVersion etc.).
    if type(payload.profiles) == "table" then
        local only, count = nil, 0
        for _, profileTable in pairs(payload.profiles) do
            count = count + 1
            only = profileTable
        end
        if count == 1 and type(only) == "table" then return only end
        -- Multi-profile bundle (the virtual bundle-key export): return
        -- every comparable section, NOT payload.settings — the bundle
        -- redundantly carries the active profile's flat settings for
        -- older clients, and diffing only that block would hide edits
        -- made in any of the other shipped profiles (the pack tooling
        -- would then never offer the update).
        if count > 1 then
            -- activeProfile is deliberately absent: it still ships in the
            -- export (the import activates it), but it is not part of what
            -- makes two packs different. It records which profile happened
            -- to be active when the string was made, and a spec change
            -- rewrites it on its own whenever a spec-to-profile mapping
            -- exists — which is exactly what multi-profile packs are for.
            -- Comparing it made pack tooling report an edit every time the
            -- author swapped spec.
            return {
                profiles       = payload.profiles,
                specProfileMap = payload.specProfileMap,
            }
        end
    end
    return payload.settings or payload
end

---@param profileKey string  an existing profile name
function API:SetProfile(profileKey)
    if type(profileKey) ~= "string" or profileKey == "" then return end
    -- The virtual bundle key is not a switchable profile; the bundle
    -- import already activated the profile that was active on export.
    if profileKey == BundleKey() then return end
    if BIT.Profiles and BIT.Profiles.Exists and BIT.Profiles:Exists(profileKey) then
        BIT.Profiles:Switch(profileKey)
    end
end

---@return table<string, boolean>  [profileKey] = true
function API:GetProfileKeys()
    local keys = {}
    local sv = SV()
    if sv and sv.profiles then
        for name in pairs(sv.profiles) do
            if type(name) == "string" and name ~= "" then
                keys[name] = true
            end
        end
    end
    if not next(keys) then keys["Default"] = true end
    -- Virtual "bundle" entry, ALWAYS present: exporting it ships every
    -- profile + the spec assignments in one pack slot. This is the entry
    -- pack creators pick in the Wago pack creator — a single real profile
    -- would lose the role/spec auto-switching on the user's side. Its
    -- display name is creator-configurable (Profiles page → UI Pack
    -- Bundle) and defaults to a fixed fallback so the entry never
    -- disappears from the installer's list.
    keys[BundleKey()] = true
    return keys
end

---@return table<string, string>|nil  [characterKey] = profileKey
function API:GetProfileAssignments()
    -- Our active profile is account-wide (plus spec/role auto-switching),
    -- not a per-character assignment map — nothing meaningful to return.
    return nil
end

---@return string  the currently active profile name
function API:GetCurrentProfileKey()
    if BIT.Profiles and BIT.Profiles.GetActiveName then
        local name = BIT.Profiles:GetActiveName()
        if type(name) == "string" and name ~= "" then return name end
    end
    local sv = SV()
    return (sv and sv.activeProfile) or "Default"
end

function API:OpenConfig()
    if BIT.SettingsUI and BIT.SettingsUI.Toggle then
        local f = _G["BIT_SettingsFrame"]
        if not (f and f:IsShown()) then
            BIT.SettingsUI:Toggle()
        end
    end
end

function API:CloseConfig()
    local f = _G["BIT_SettingsFrame"]
    if f and f:IsShown() then
        f:Hide()
    end
end
