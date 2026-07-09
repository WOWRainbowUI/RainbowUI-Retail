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

local function SV()
    return BliZziInterruptsSavedVars
end

---@param profileKey string  the name of the profile to export
---@return string|nil        encoded profile string ("!BIT!" format)
function API:ExportProfile(profileKey)
    if type(profileKey) ~= "string" or profileKey == "" then return nil end
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
    end
    return payload.settings or payload
end

---@param profileKey string  an existing profile name
function API:SetProfile(profileKey)
    if type(profileKey) ~= "string" or profileKey == "" then return end
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
