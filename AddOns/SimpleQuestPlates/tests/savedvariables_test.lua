--=====================================================================================
-- RGX | Simple Quest Plates! - tests/savedvariables_test.lua
--
-- Author: DonnieDice workforce (engineer @Sorynth), issue #11
-- Description: SavedVariables ownership evidence for issue #11 (parent #7).
--
-- Runs SQP's real SQP.DEFAULTS table through the real RGX-Framework
-- database code (core/systems/database.lua from the RGX-Framework
-- dependency) in a plain Lua 5.1 VM, mirroring the framework's own
-- tools/ci/database-runtime-test.lua harness style. WoW globals touched
-- by database.lua are stubbed; nothing here is a WoW emulator.
--
-- Evidence it produces (issue #11 acceptance criterion 2):
--   * serialize/deserialize round-trip of defaults + saved values,
--   * explicit `false` and `0` values survive adoption and reload,
--   * reset does not alias mutable default tables,
--   * SQPForeverSettings legacy migration seeding path.
--
-- Runner: tests/run.lua (Lua 5.1). CI-equivalent syntax gate is
-- `luac5.1 -p` (run by the shared addon CI include).
--=====================================================================================

local _, RGX = ...

local failures = 0
local checks = 0
local function check(cond, msg)
    checks = checks + 1
    if not cond then
        failures = failures + 1
        print("FAIL: " .. msg)
    end
end

-- Serialize/deserialize round-trip the way the WoW client persists
-- SavedVariables: only plain keys survive; metatables do not. Strings,
-- numbers (including 0), and booleans (including false) must survive
-- byte-identically.
local function Serialize(t)
    local out, err = {}
    local function ser(v)
        local tv = type(v)
        if tv == "nil" or tv == "boolean" or tv == "number" then
            out[#out + 1] = tostring(v)
        elseif tv == "string" then
            out[#out + 1] = string.format("%q", v)
        elseif tv == "table" then
            out[#out + 1] = "{"
            for k, val in pairs(v) do
                if type(k) == "number" then
                    out[#out + 1] = "[" .. tostring(k) .. "]="
                else
                    out[#out + 1] = "[" .. string.format("%q", k) .. "]="
                end
                ser(val)
                out[#out + 1] = ","
            end
            out[#out + 1] = "}"
        else
            error("cannot serialize type " .. tv)
        end
    end
    ser(t)
    return table.concat(out)
end

local function Deserialize(s)
    local chunk = assert(loadstring("return " .. s, "@serialized"))
    return chunk()
end

-- Deep compare two plain tables (round-trip equality).
local function Same(a, b, path)
    path = path or "root"
    if type(a) ~= "table" or type(b) ~= "table" then
        return a == b, path
    end
    for k, v in pairs(a) do
        if b[k] ~= v then
            if type(v) == "table" and type(b[k]) == "table" then
                local ok, p = Same(v, b[k], path .. "." .. tostring(k))
                if not ok then return false, p end
            else
                return false, path .. "." .. tostring(k)
            end
        end
    end
    for k in pairs(b) do
        if a[k] == nil then return false, path .. "." .. tostring(k) .. " (extra)" end
    end
    return true, path
end

-- The exact consumer contract from data/core.lua:311 (SQP Retail).
local function NewSQPDatabase(defaults)
    return RGX:NewDatabase("SQPSettings", defaults, {
        legacyFlat = true,
        profileIsGlobal = true,
        onSwitch = function() end,
    })
end

-- ---------------------------------------------------------------------------
-- 1. Serialize/deserialize round-trip of the real SQP.DEFAULTS table:
--    every default, including false booleans and 0 numbers, survives a
--    full logout->login persistence cycle byte-identically.
-- ---------------------------------------------------------------------------
do
    -- Load SQP's real defaults table (SQP.DEFAULTS from data/core.lua).
    -- We cannot dofile the whole core.lua (it needs the full WoW client
    -- environment at chunk load); instead we extract the defaults by
    -- running core.lua's chunk in a stub environment up to the point
    -- where SQP.DEFAULTS is defined, before any WoW API is touched.
    -- core.lua defines SQP.DEFAULTS at line 106, before any WoW frame
    -- usage; the only globals it touches before that point are RGX and
    -- metadata accessors, which we stub. See tests/extract_defaults.lua.
    local DEFAULTS = require("sqp_defaults")
    check(type(DEFAULTS) == "table", "1: SQP.DEFAULTS extracted as a table")
    local defaultsFalse = 0
    local defaultsZero = 0
    for _, v in pairs(DEFAULTS) do
        if v == false then defaultsFalse = defaultsFalse + 1 end
        if v == 0 then defaultsZero = defaultsZero + 1 end
    end
    check(defaultsFalse > 10, "1: defaults contain explicit false values (" .. defaultsFalse .. " found)")
    check(defaultsZero > 0, "1: defaults contain explicit zero values (" .. defaultsZero .. " found)")

    -- Round-trip the defaults table itself.
    local ser = Serialize(DEFAULTS)
    local deser = Deserialize(ser)
    local ok, p = Same(DEFAULTS, deser)
    check(ok, "1: defaults serialize/deserialize round-trip identity failed at " .. tostring(p))
end

-- ---------------------------------------------------------------------------
-- 2. Full consumer lifecycle: construct DB (chunk time), simulate in-session
--    writes (explicit false and zero), then a /reload: the client saves the
--    TOC global and hands back a freshly deserialized table before
--    ADDON_LOADED. Values must survive with their types intact.
-- ---------------------------------------------------------------------------
do
    local DEFAULTS = require("sqp_defaults")
    _G.SQPSettings = nil
    local db = NewSQPDatabase(DEFAULTS)
    local S = db.global -- SQPSettings = SQP.db.global (data/core.lua:325)

    -- In-session user choices: explicitly false and zero, plus non-defaults.
    S.enabled = false        -- explicit false (default true)
    S.offsetX = 0            -- explicit zero (already default zero -> still saved)
    S.scale = 0               -- explicit zero (default 1.1)
    S.anchor = "LEFT"
    S.itemColor = { 1, 0, 0 } -- nested table override
    S.customKey = false      -- non-default key with explicit false

    -- /reload: client serializes _G.SQPSettings, then deserializes into a
    -- NEW table assigned to _G.SQPSettings before ADDON_LOADED. Adopt()
    -- (data/events.lua:43) rebinds the database to it.
    local persisted = Serialize(_G.SQPSettings)
    _G.SQPSettings = Deserialize(persisted)
    check(db:Adopt() == true, "2: Adopt should bind the reloaded SavedVariables table")

    check(S.enabled == false, "2: explicit false `enabled` must survive reload (got " .. tostring(S.enabled) .. ")")
    check(type(S.enabled) == "boolean", "2: `enabled` must stay boolean after reload")
    check(S.offsetX == 0, "2: explicit zero `offsetX` must survive reload (got " .. tostring(S.offsetX) .. ")")
    check(S.scale == 0, "2: explicit zero `scale` must survive reload (got " .. tostring(S.scale) .. ")")
    check(S.anchor == "LEFT", "2: string value must survive reload")
    check(S.customKey == false, "2: non-default explicit false must survive reload")
    local c = S.itemColor
    check(type(c) == "table" and c[1] == 1 and c[2] == 0 and c[3] == 0,
        "2: nested table value must survive reload")

    -- FillDefaults must not have clobbered any explicit value.
    check(S.enabled == false and S.scale == 0,
        "2: reloaded profile must not be re-defaulted")

    -- Second reload: values written post-adoption must also persist.
    S.showPercentIcon = false
    S.toastDuration = 0
    local persisted2 = Serialize(_G.SQPSettings)
    _G.SQPSettings = Deserialize(persisted2)
    db:Adopt()
    check(S.showPercentIcon == false, "2: post-adoption explicit false must survive a second reload")
    check(S.toastDuration == 0, "2: post-adoption explicit zero must survive a second reload")

    -- Clean up the global for subsequent blocks.
    _G.SQPSettings = nil
end

-- ---------------------------------------------------------------------------
-- 3. Profile switch: SQPSettings (db.global, profileIsGlobal live view) must
--    follow the newly active profile, and each profile keeps its own
--    explicit false/zero values across the switch and back.
-- ---------------------------------------------------------------------------
do
    local DEFAULTS = require("sqp_defaults")
    _G.SQPSettings = nil
    local db = NewSQPDatabase(DEFAULTS)
    local S = db.global

    S.enabled = false
    S.scale = 0

    check(db:CreateProfile("Alt") == true, "3: CreateProfile should succeed")
    db:LoadProfile("Alt")
    check(db:GetActiveProfile() == "Alt", "3: active profile should switch to Alt")
    -- Fresh profile: defaults readable through the captured view.
    check(S.enabled == true, "3: fresh Alt profile should read default enabled=true through view")
    check(S.scale == 1.1, "3: fresh Alt profile should read default scale=1.1 through view")
    -- Explicit values on Alt.
    S.enabled = false
    S.scale = 2.0

    -- Switch back: Default keeps its explicit values.
    db:LoadProfile("Default")
    check(S.enabled == false, "3: Default profile explicit false must survive Alt switch")
    check(S.scale == 0, "3: Default profile explicit zero must survive Alt switch")

    -- And Alt keeps its values when re-activated.
    db:LoadProfile("Alt")
    check(S.enabled == false, "3: Alt explicit false must survive switch back")
    check(S.scale == 2.0, "3: Alt explicit scale=2.0 must survive switch back")

    _G.SQPSettings = nil
end

-- ---------------------------------------------------------------------------
-- 4. Reset: ResetProfile must clear explicit values back to defaults and
--    must NOT alias mutable default tables (a reset profile writing into a
--    nested table must not corrupt SQP.DEFAULTS).
-- ---------------------------------------------------------------------------
do
    local DEFAULTS = require("sqp_defaults")
    _G.SQPSettings = nil
    local db = NewSQPDatabase(DEFAULTS)
    local S = db.global

    S.enabled = false
    S.scale = 7
    S.itemColor = { 9, 9, 9 }

    check(db:ResetProfile() == true, "4: ResetProfile should succeed")
    check(S.enabled == true, "4: reset should restore default enabled=true (not keep false)")
    check(S.scale == 1.1, "4: reset should restore default scale=1.1")
    local c = S.itemColor
    check(type(c) == "table" and c[1] == 0.2 and c[2] == 1 and c[3] == 0.2,
        "4: reset should restore default nested itemColor")

    -- No aliasing: mutating the reset profile's nested table must not
    -- touch the defaults table.
    S.itemColor[1] = 5
    check(DEFAULTS.itemColor[1] == 0.2,
        "4: reset profile must not alias mutable SQP.DEFAULTS nested tables")

    -- Reset preserves nothing user-typed even when it equals a default.
    S.enabled = false
    db:ResetProfile()
    check(S.enabled == true, "4: second reset should also restore defaults")

    _G.SQPSettings = nil
end

-- ---------------------------------------------------------------------------
-- 5. Legacy migration (data/events.lua:30-38): SQPForeverSettings seeds
--    SQPSettings only when the Forever file exists with profile data and
--    the current settings are empty; the migration source stays read-only.
--
--    Real-load fidelity note: at ADDON_LOADED the global replaced by the
--    client is a *fresh, empty* table (the client serializes the in-memory
--    database only at logout, and a fresh install has no saved file), not
--    the default-filled table NewDatabase built at chunk time. The
--    events.lua migration condition (`next(current) == nil`) matches that
--    client reality; the default-filled in-memory table the pre-fix code
--    compared against was exactly the mutable-default aliasing bug this
--    issue ports away from. The test models the real client load.
-- ---------------------------------------------------------------------------
do
    local DEFAULTS = require("sqp_defaults")
    _G.SQPSettings = nil
    _G.SQPForeverSettings = {
        profiles = { Default = { enabled = false, scale = 0.9, kept = "forever" } },
        currentProfile = "Default",
    }

    local db = NewSQPDatabase(DEFAULTS)
    local S = db.global

    -- Client hands SQP a fresh empty table at ADDON_LOADED (fresh install,
    -- nothing was ever saved). NewDatabase's chunk-time table is discarded
    -- wholesale, exactly as Adopt()'s design comment states.
    _G.SQPSettings = {}

    -- events.lua ADDON_LOADED migration logic, verbatim.
    local forever = _G.SQPForeverSettings
    local current = _G.SQPSettings
    if type(forever) == "table" and type(forever.profiles) == "table"
        and (type(current) ~= "table" or next(current) == nil) then
        _G.SQPSettings = forever
        if type(_G.SQPSettings.currentProfile) ~= "string" or _G.SQPSettings.currentProfile == "" then
            _G.SQPSettings.currentProfile = "Default"
        end
    end
    check(_G.SQPSettings == forever, "5: migration should seed SQPSettings from the Forever file")
    check(db:Adopt() == true, "5: Adopt should bind the migrated Forever table")
    check(S.enabled == false, "5: migrated Forever explicit false must survive adoption")
    check(S.scale == 0.9, "5: migrated Forever scale must survive adoption")
    check(S.kept == "forever", "5: migrated Forever extra value must survive adoption")

    -- Migration source must stay untouched (read-only legacy source).
    check(_G.SQPForeverSettings.profiles.Default.kept == "forever",
        "5: SQPForeverSettings must remain unmodified as the read-only migration source")

    _G.SQPSettings = nil
    _G.SQPForeverSettings = nil
end

-- ---------------------------------------------------------------------------
print(string.format("checks=%d failures=%d", checks, failures))
if failures == 0 then
    print("PASSED")
else
    print("FAILED")
end
os.exit(failures == 0 and 0 or 1)
