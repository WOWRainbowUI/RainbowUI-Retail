-- Copyright (c) 2026 BliZzi1337. All rights reserved.
-- Unauthorized copying, modification, distribution or use of this
-- software, in whole or in part, without prior written permission
-- from the copyright holder is strictly prohibited.
--[[
    OffensiveCDAlert.lua

    Highlights a party member's unit frame whenever they pop a tracked
    offensive cooldown. The intended use case is Priests pairing Power
    Infusion with a teammate's burst — but the alert is class-agnostic
    so any caster who wants to sync to a teammate's burst can use it.

    Display modes:
      • BUTTON_GLOW  — LibButtonGlow's spell-activation flare on the frame
      • BORDER       — colored backdrop border around the frame
      • BOTH         — both at once

    Settings:
      • Master enable toggle
      • Per-spell whitelist (curated list of burst CDs, all class specs)
      • Glow display mode dropdown
      • Border color picker (used only when BORDER / BOTH)

    Detection runs off the same UNIT_AURA pipeline that BIT.SyncCD uses,
    but with a dedicated lightweight per-spell presence check (shared
    ProbeAuraPresence) so it doesn't add noise to the SyncCD scan path.
]]

BIT                  = BIT or {}
BIT.OffensiveCDAlert = BIT.OffensiveCDAlert or {}
local OCA            = BIT.OffensiveCDAlert

-- ──────────────────────────────────────────────────────────────────────
-- DEVELOPER FEATURE GATE
--
-- When true the entire PI Caller module is force-disabled: settings UI
-- renders read-only, no event handlers register, the secure-button PI
-- macro stays in its current state but the macro auto-update / preview
-- glow paths are short-circuited, alerts never fire. Used to ship the
-- feature in a "preview / coming soon" state while it's still being
-- iterated on. Flip to `false` to re-enable for users.
--
-- This is a release-engineering decision, not a per-user choice. The
-- saved-vars `offensiveCDAlertEnabled` toggle is honored when this is
-- false; otherwise this gate wins.
-- ──────────────────────────────────────────────────────────────────────
OCA.FEATURE_DISABLED = true

---------------------------------------------------------------------------
-- Curated spell list. id → { name, class, default }
-- `default` controls the initial enabled state for fresh installs;
-- existing user choices in BIT.db.offensiveCDAlertSpells override this.
---------------------------------------------------------------------------
local SPELLS = {
    -- ── Mage ────────────────────────────────────────────────
    [190319] = { name = "Combustion",                class = "MAGE",        default = true },
    [12472]  = { name = "Icy Veins",                 class = "MAGE",        default = true },
    [365350] = { name = "Arcane Surge",              class = "MAGE",        default = true },
    -- ── Warlock ─────────────────────────────────────────────
    [265187] = { name = "Summon Demonic Tyrant",     class = "WARLOCK",     default = true },
    [113858] = { name = "Dark Soul: Instability",    class = "WARLOCK",     default = true },
    [113860] = { name = "Dark Soul: Misery",         class = "WARLOCK",     default = true },
    [205180] = { name = "Summon Darkglare",          class = "WARLOCK",     default = true },
    -- ── Priest (Shadow) ─────────────────────────────────────
    [228260] = { name = "Void Eruption",             class = "PRIEST",      default = true },
    [391109] = { name = "Dark Ascension",            class = "PRIEST",      default = true },
    [123040] = { name = "Mindbender",                class = "PRIEST",      default = false },
    -- ── Death Knight ────────────────────────────────────────
    [51271]  = { name = "Pillar of Frost",           class = "DEATHKNIGHT", default = true },
    [47568]  = { name = "Empower Rune Weapon",       class = "DEATHKNIGHT", default = true },
    [275699] = { name = "Apocalypse",                class = "DEATHKNIGHT", default = true },
    [42650]  = { name = "Army of the Dead",          class = "DEATHKNIGHT", default = true },
    [49028]  = { name = "Dancing Rune Weapon",       class = "DEATHKNIGHT", default = false },
    -- ── Rogue ───────────────────────────────────────────────
    [121471] = { name = "Shadow Blades",             class = "ROGUE",       default = true },
    [13750]  = { name = "Adrenaline Rush",           class = "ROGUE",       default = true },
    [360194] = { name = "Deathmark",                 class = "ROGUE",       default = true },
    -- ── Hunter ──────────────────────────────────────────────
    [288613] = { name = "Trueshot",                  class = "HUNTER",      default = true },
    [19574]  = { name = "Bestial Wrath",             class = "HUNTER",      default = true },
    [360952] = { name = "Coordinated Assault",       class = "HUNTER",      default = true },
    -- ── Paladin ─────────────────────────────────────────────
    [31884]  = { name = "Avenging Wrath",            class = "PALADIN",     default = true },
    [231895] = { name = "Crusade",                   class = "PALADIN",     default = true },
    -- ── Druid ───────────────────────────────────────────────
    [50334]  = { name = "Berserk",                   class = "DRUID",       default = true },
    [102560] = { name = "Incarnation: Chosen of Elune", class = "DRUID",    default = true },
    [102543] = { name = "Incarnation: Avatar of Ashamane", class = "DRUID", default = true },
    [391528] = { name = "Convoke the Spirits",       class = "DRUID",       default = false },
    -- ── Monk ────────────────────────────────────────────────
    [137639] = { name = "Storm, Earth, and Fire",    class = "MONK",        default = true },
    [152173] = { name = "Serenity",                  class = "MONK",        default = true },
    [387184] = { name = "Weapons of Order",          class = "MONK",        default = true },
    -- ── Demon Hunter ────────────────────────────────────────
    [191427] = { name = "Metamorphosis (Havoc)",     class = "DEMONHUNTER", default = true },
    [258925] = { name = "Fel Barrage",               class = "DEMONHUNTER", default = false },
    [258860] = { name = "Essence Break",             class = "DEMONHUNTER", default = false },
    -- ── Shaman ──────────────────────────────────────────────
    [114050] = { name = "Ascendance (Elemental)",    class = "SHAMAN",      default = true },
    [114051] = { name = "Ascendance (Enhancement)",  class = "SHAMAN",      default = true },
    [191634] = { name = "Stormkeeper",               class = "SHAMAN",      default = true },
    [384352] = { name = "Doom Winds",                class = "SHAMAN",      default = true },
    -- ── Evoker ──────────────────────────────────────────────
    [375087] = { name = "Dragonrage",                class = "EVOKER",      default = true },
    [357210] = { name = "Deep Breath",               class = "EVOKER",      default = false },
}

OCA.SPELLS = SPELLS  -- exposed for the settings UI

---------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------
local _activeBorders = {}  -- unit → border frame
local _activeGlows   = {}  -- unit → true (LibButtonGlow active)
local _activeAuras   = {}  -- unit → spellID currently glowing
local _eventFrame    = nil

-- LibButtonGlowcustom registers itself under the bare name (no -1.0 suffix);
-- the SyncCD module already calls it as "LibButtonGlowcustom", and we must
-- match that here or LibStub returns nil and the spell-glow path silently
-- falls back to nothing.
local function GetLBG()
    return _G.LibStub and _G.LibStub("LibButtonGlowcustom", true)
end

---------------------------------------------------------------------------
-- Visual: border overlay around a unit frame
---------------------------------------------------------------------------
local function ShowBorder(unit)
    local parent = BIT.UnitFrames and BIT.UnitFrames.GetPartyFrame
                   and BIT.UnitFrames:GetPartyFrame(unit)
    if not parent then return end
    local b = _activeBorders[unit]
    if not b or b._parent ~= parent then
        if b then b:Hide(); b:SetParent(nil) end
        b = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        b._parent = parent
        b:SetFrameLevel((parent:GetFrameLevel() or 1) + 8)
        b:EnableMouse(false)
        _activeBorders[unit] = b
    end
    local db = BIT.db or {}
    local r = db.offensiveCDAlertColorR or 1.0
    local g = db.offensiveCDAlertColorG or 0.4
    local bcol = db.offensiveCDAlertColorB or 0.1
    local sz = db.offensiveCDAlertBorderSize or 3
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT",     parent, "TOPLEFT",     -sz,  sz)
    b:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT",  sz, -sz)
    b:SetBackdrop({
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = sz,
        insets   = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    b:SetBackdropBorderColor(r, g, bcol, 1)
    b:Show()
end

local function HideBorder(unit)
    local b = _activeBorders[unit]
    if b then b:Hide() end
end

---------------------------------------------------------------------------
-- Visual: LibButtonGlow flare on the unit frame
---------------------------------------------------------------------------
local function ShowGlow(unit)
    local lbg = GetLBG()
    if not lbg or not lbg.ShowOverlayGlow then return end
    local parent = BIT.UnitFrames and BIT.UnitFrames.GetPartyFrame
                   and BIT.UnitFrames:GetPartyFrame(unit)
    if not parent then return end
    pcall(lbg.ShowOverlayGlow, parent)
    _activeGlows[unit] = parent  -- remember the frame so we can hide later
end

local function HideGlow(unit)
    local lbg = GetLBG()
    if not lbg or not lbg.HideOverlayGlow then return end
    local parent = _activeGlows[unit]
    if parent then
        pcall(lbg.HideOverlayGlow, parent)
        _activeGlows[unit] = nil
    end
end

---------------------------------------------------------------------------
-- Combined apply / clear based on the current display mode
---------------------------------------------------------------------------
local function ApplyAlert(unit)
    local mode = (BIT.db and BIT.db.offensiveCDAlertMode) or "BOTH"
    if mode == "GLOW" or mode == "BOTH" then ShowGlow(unit) end
    if mode == "BORDER" or mode == "BOTH" then ShowBorder(unit) end
end

local function ClearAlert(unit)
    HideGlow(unit)
    HideBorder(unit)
end

---------------------------------------------------------------------------
-- Aura detection
---------------------------------------------------------------------------
-- Returns the first tracked-and-enabled spellID currently active on the
-- unit, or nil. Iterating the curated list keeps the cost bounded and
-- avoids walking the unit's full HELPFUL aura ring.
local function FindActiveOffensiveCD(unit)
    local choices = BIT.db and BIT.db.offensiveCDAlertSpells or {}
    -- Presence lookup shared with the Party CDs module. The check that
    -- lived here before called C_UnitAuras.GetAuraDataBySpellID — an API
    -- that does not exist for unit tokens (the by-ID variant is player-
    -- only), so the pcall failed on EVERY call and this alert silently
    -- never detected anything. The shared probe answers via
    -- GetPlayerAuraBySpellID for the player and GetAuraDataBySpellName
    -- for party members. Resolved at call time, so load order is moot.
    local pcd = BIT.PartyCooldowns
    if not (pcd and pcd.ProbeAuraPresence) then return nil end
    for sid, def in pairs(SPELLS) do
        local enabled = choices[sid]
        if enabled == nil then enabled = def.default end
        if enabled then
            local isPresent = pcd:ProbeAuraPresence(unit, sid)
            if isPresent then
                return sid
            end
        end
    end
    return nil
end

local function ScanUnit(unit)
    if not BIT.db or not BIT.db.offensiveCDAlertEnabled then
        if _activeAuras[unit] then
            ClearAlert(unit)
            _activeAuras[unit] = nil
        end
        return
    end
    if not unit:find("^party") and unit ~= "player" then return end
    if not UnitExists(unit) then
        if _activeAuras[unit] then
            ClearAlert(unit)
            _activeAuras[unit] = nil
        end
        return
    end
    local active = FindActiveOffensiveCD(unit)
    local current = _activeAuras[unit]
    if active and current ~= active then
        -- Either fresh aura or a switch from one tracked CD to another.
        if current then ClearAlert(unit) end
        _activeAuras[unit] = active
        ApplyAlert(unit)
    elseif not active and current then
        ClearAlert(unit)
        _activeAuras[unit] = nil
    end
end

local function ScanAll()
    if not BIT.db or not BIT.db.offensiveCDAlertEnabled then
        -- Disabled — clear any leftover visuals.
        for unit in pairs(_activeAuras) do ClearAlert(unit) end
        wipe(_activeAuras)
        return
    end
    -- Local player is intentionally excluded — the use case is "highlight
    -- a teammate to PI", and a Priest would never PI themselves via this.
    for i = 1, 4 do
        ScanUnit("party" .. i)
    end
end

---------------------------------------------------------------------------
-- Event handler
---------------------------------------------------------------------------
local function OnEvent(_, event, unit)
    if event == "UNIT_AURA" then
        if unit and (unit == "player" or unit:find("^party")) then
            ScanUnit(unit)
        end
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        -- Wipe stale glows on roster changes; new members will be picked
        -- up on their next UNIT_AURA.
        for unit in pairs(_activeAuras) do ClearAlert(unit) end
        wipe(_activeAuras)
        if BIT.db and BIT.db.offensiveCDAlertEnabled then ScanAll() end
    end
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------
function OCA:Enable()
    -- Hard-coded developer gate wins over the saved-vars toggle. When
    -- the feature is force-disabled (see OCA.FEATURE_DISABLED at the
    -- top of the file), no events are registered and the alert system
    -- stays completely inert regardless of the user's settings.
    if self.FEATURE_DISABLED then return end
    if not _eventFrame then
        _eventFrame = CreateFrame("Frame")
        _eventFrame:SetScript("OnEvent", BIT.Prof.Wrap("PI_CALLER", OnEvent))
    end
    -- Performance: UNIT_AURA delivery is constrained to player + party1-4
    -- via RegisterUnitEvent. The OnEvent body already early-exits for any
    -- other unit (`unit == "player" or unit:find("^party")` check at the
    -- top of the UNIT_AURA branch), so filtering at the engine instead of
    -- in Lua eliminates 80-90% of redundant callback invocations during
    -- combat (nameplates, pets, raid members beyond party4, focus, etc.)
    -- without changing observable behavior. The Lua-side filter stays as
    -- a defensive backstop.
    _eventFrame:RegisterUnitEvent("UNIT_AURA", "player", "party1", "party2", "party3", "party4")
    _eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    _eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    ScanAll()
end

function OCA:Disable()
    if _eventFrame then _eventFrame:UnregisterAllEvents() end
    for unit in pairs(_activeAuras) do ClearAlert(unit) end
    wipe(_activeAuras)
end

-- Preview the alert visuals for a few seconds so the user can see how
-- their current glow / border / color settings look without waiting for
-- a real burst to happen.
--
-- Picks a sensible target frame:
--   1) party1..party4 if any exist (so the test mirrors the real flow)
--   2) "player" as a fallback (works in solo / out-of-group scenarios)
function OCA:Test(durationSec)
    -- Developer gate: don't run preview when the feature is force-disabled.
    if self.FEATURE_DISABLED then return end
    durationSec = durationSec or 5
    -- Cancel a previous test so the timer doesn't double-fire.
    if self._testTimer then
        self._testTimer:Cancel()
        self._testTimer = nil
    end

    local target
    for i = 1, 4 do
        local u = "party" .. i
        if UnitExists(u) then target = u; break end
    end
    if not target then target = "player" end

    -- For "player" we don't go through SyncCD's party-frame finder
    -- (that path only resolves party units). Build a minimal local
    -- resolver here so the test still produces visible output for
    -- a solo player previewing settings.
    local function ResolveForTest(unit)
        if unit == "player" then
            -- Try the shared resolver for player frames first.
            local resolved = BIT.UnitFrames and BIT.UnitFrames.GetPartyFrame
                             and BIT.UnitFrames:GetPartyFrame("player")
            if resolved then return resolved end
            -- Hard fallback: Blizzard's PlayerFrame.
            return _G["PlayerFrame"]
        end
        return BIT.UnitFrames and BIT.UnitFrames.GetPartyFrame
               and BIT.UnitFrames:GetPartyFrame(unit)
    end

    -- Manually paint the alert (bypasses the aura check that real
    -- detection uses). Both visuals respect the user's current settings.
    local mode = (BIT.db and BIT.db.offensiveCDAlertMode) or "BOTH"
    local parent = ResolveForTest(target)
    if not parent then
        print("|cff0091edBIT|r |cffffd700PI Caller test:|r no target frame "
              .. "available — make sure you're in a party or that your "
              .. "player frame addon is loaded.")
        return
    end

    -- Border: build / reuse the same kind of frame the real path uses,
    -- but pinned to whatever ResolveForTest gave us (handles the player
    -- frame case which the normal show path doesn't cover).
    local b = _activeBorders[target]
    if not b or b._parent ~= parent then
        if b then b:Hide(); b:SetParent(nil) end
        b = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        b._parent = parent
        b:SetFrameLevel((parent:GetFrameLevel() or 1) + 8)
        b:EnableMouse(false)
        _activeBorders[target] = b
    end
    if mode == "BORDER" or mode == "BOTH" then
        local db = BIT.db or {}
        local r = db.offensiveCDAlertColorR or 1.0
        local g = db.offensiveCDAlertColorG or 0.4
        local bcol = db.offensiveCDAlertColorB or 0.1
        local sz = db.offensiveCDAlertBorderSize or 3
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT",     parent, "TOPLEFT",     -sz,  sz)
        b:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT",  sz, -sz)
        b:SetBackdrop({
            edgeFile = "Interface\\BUTTONS\\WHITE8X8",
            edgeSize = sz,
            insets   = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        b:SetBackdropBorderColor(r, g, bcol, 1)
        b:Show()
    end

    if mode == "GLOW" or mode == "BOTH" then
        local lbg = GetLBG()
        if lbg and lbg.ShowOverlayGlow then
            pcall(lbg.ShowOverlayGlow, parent)
            _activeGlows[target] = parent
        end
    end

    print(string.format(
        "|cff0091edBIT|r |cffffd700PI Caller test|r — previewing on |cffffffff%s|r for %ds.",
        target, durationSec))

    -- Auto-clear so the preview doesn't stick around forever.
    self._testTimer = C_Timer.NewTimer(durationSec, function()
        if _activeGlows[target] then HideGlow(target) end
        local bb = _activeBorders[target]
        if bb then bb:Hide() end
        OCA._testTimer = nil
    end)
end

-- Called from the settings page when the master toggle / per-spell list
-- / display mode changes — re-scans so new state takes effect immediately.
function OCA:Refresh()
    if BIT.db and BIT.db.offensiveCDAlertEnabled then
        self:Enable()
        ScanAll()
    else
        self:Disable()
    end
end

-- Build a stable, class-grouped, alphabetically sorted list for the
-- settings UI. Returns { { spellID, name, class }, … }.
function OCA:GetSpellList()
    local list = {}
    for sid, def in pairs(SPELLS) do
        list[#list + 1] = { id = sid, name = def.name, class = def.class, default = def.default }
    end
    table.sort(list, function(a, b)
        if a.class == b.class then return a.name < b.name end
        return a.class < b.class
    end)
    return list
end

---------------------------------------------------------------------------
-- PI Macro auto-cast (secure-button + static-macro pattern)
--
-- Mirrors Smart Misdirect's design: instead of dynamically rewriting
-- the macro body every time the priority list changes (combat-locked,
-- 255-char limit, fragile), we create N hidden SecureActionButtons
-- once and dynamically update their `unit` attribute. The user-facing
-- macro is FIXED — it just /clicks each secure button in priority
-- order. First button whose `unit` resolves to a valid friendly target
-- fires Power Infusion; subsequent /clicks fail silently (GCD blocks
-- them) so the priority fall-through works automatically.
--
-- Static macro body — written ONCE to the macro frame:
--
--   #showtooltip
--   /click BIT_PIButton1
--   /click BIT_PIButton2
--   /click BIT_PIButton3
--   /click BIT_PIButton4
--   /click BIT_PIButton5
--
-- Why this is better than dynamic-macro-rewriting:
--   • Macro body never changes → no combat-locked EditMacro calls
--   • 255-char limit is a non-issue (each button gets one name)
--   • Updates happen via SetAttribute (also combat-locked, but per-
--     button updates are queued through PLAYER_REGEN_ENABLED — same
--     pattern Smart Misdirect already uses bullet-proof in production)
--
-- Button update flow:
--   • Settings change → QueuePIUpdate() (out of combat: applies; in
--     combat: defers to PLAYER_REGEN_ENABLED)
--   • GROUP_ROSTER_UPDATE → re-resolve names against current group
--   • Disable toggle → clear all button unit attributes (macro becomes
--     a no-op, doesn't keep firing on stale targets)
---------------------------------------------------------------------------
local PI_MACRO_NAME   = "BIT_PI"
local PI_SPELL_ID     = 10060
local PI_ICON_ID      = 135932           -- spell_holy_powerinfusion
local PI_MAX_PRIORITY = 5                -- 5 secure buttons → 5 priority slots
local _piButtons      = {}               -- array of SecureActionButtonTemplate frames
local _piUpdateQueued = false            -- "want to update buttons but in combat" flag

-- Parse the newline-separated priority list out of saved settings into
-- a clean array of trimmed names. Empty lines, whitespace-only entries,
-- and duplicates are dropped. Capped at PI_MAX_PRIORITY (= number of
-- secure buttons we create).
local function parsePIPriorityList(text)
    local list, seen = {}, {}
    if not text or text == "" then return list end
    for line in text:gmatch("[^\r\n]+") do
        local n = line:gsub("^%s+", ""):gsub("%s+$", "")
        if n ~= "" and not seen[n] and #list < PI_MAX_PRIORITY then
            seen[n] = true
            list[#list+1] = n
        end
    end
    return list
end

-- Static macro body. Same content always — just N /click lines that
-- dispatch to the secure buttons. Putting `#showtooltip` first lets
-- the action bar slot pick up the PI icon + tooltip automatically.
local function buildPIMacroBody()
    local lines = { "#showtooltip" }
    for i = 1, PI_MAX_PRIORITY do
        lines[#lines+1] = "/click " .. PI_MACRO_NAME .. "Button" .. i
    end
    return table.concat(lines, "\n")
end

-- Public: macro body for the Settings UI preview. Always returns the
-- same fixed content — the priority list lives on the secure buttons
-- now, not in the macro text.
function OCA:GetPIMacroBody()
    return buildPIMacroBody()
end

-- Create the N hidden SecureActionButtons. One-shot — called once on
-- demand (when the feature is enabled or first button-update fires).
-- Combat-locked because SecureActionButtonTemplate creation runs
-- protected code; defers to PLAYER_REGEN_ENABLED via _piUpdateQueued.
local function createPIButtons()
    if #_piButtons > 0 then return end
    if InCombatLockdown() then
        _piUpdateQueued = true
        return
    end
    for i = 1, PI_MAX_PRIORITY do
        local name = PI_MACRO_NAME .. "Button" .. i
        local btn  = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
        btn:Hide()
        btn:SetAttribute("type",            "spell")
        btn:SetAttribute("typerelease",     "spell")
        btn:SetAttribute("spell",           PI_SPELL_ID)
        btn:SetAttribute("pressAndHoldAction", "1")
        btn:SetAttribute("allowVehicleTarget", false)
        btn:SetAttribute("checkselfcast",   false)
        btn:SetAttribute("checkfocuscast",  false)
        btn:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
        _piButtons[i] = btn
    end
end

-- Apply the current priority list to the secure buttons. Each slot
-- gets its `unit` attribute set; unused slots get cleared so a stale
-- name from a previous list can't keep firing. Combat-locked.
local function applyPIButtonTargets()
    if InCombatLockdown() then
        _piUpdateQueued = true
        return
    end
    if #_piButtons == 0 then createPIButtons() end
    if #_piButtons == 0 then return end  -- creation deferred (in combat)
    local enabled = BIT.db and BIT.db.piMacroEnabled == true
    local list = enabled and parsePIPriorityList(BIT.db and BIT.db.piMacroNames or "") or {}
    for i, btn in ipairs(_piButtons) do
        local target = list[i]
        if target and enabled then
            btn:SetAttribute("type", "spell")
            btn:SetAttribute("unit", target)
        else
            -- Clear so a /click on this button is a silent no-op rather
            -- than firing on whoever was there last.
            btn:SetAttribute("type", nil)
            btn:SetAttribute("unit", nil)
        end
    end
    _piUpdateQueued = false
end

-- Public: queue a button-target update. Settings UI calls this whenever
-- the priority list, master toggle, or group roster changes. Cheap to
-- call repeatedly — collapses to one apply per out-of-combat window.
function OCA:QueuePIUpdate()
    if self.FEATURE_DISABLED then return end
    _piUpdateQueued = true
    applyPIButtonTargets()
end

-- Public: write the static macro body into the macro frame. Idempotent
-- — only needs to be called once per character lifetime (on first
-- enable, or to recreate if the user accidentally deleted it). The
-- per-character slot keeps each toon's macro independent, but the body
-- is the same for everyone (the priority list lives on the buttons).
function OCA:CreatePIMacro()
    if self.FEATURE_DISABLED then return nil, "disabled" end
    if InCombatLockdown() then
        return nil, "combat"
    end
    -- Buttons must exist before the macro is usable — /click on a
    -- non-existent button is a no-op. Create them up front so the
    -- macro works the moment the user drags it onto an action bar.
    createPIButtons()
    applyPIButtonTargets()

    local body = buildPIMacroBody()
    local idx  = GetMacroIndexByName and GetMacroIndexByName(PI_MACRO_NAME) or 0
    if idx and idx > 0 then
        pcall(EditMacro, idx, PI_MACRO_NAME, PI_ICON_ID, body)
        return idx, "updated"
    end
    -- perCharacter = 1: macro slot is per-toon. The priority list is
    -- character-specific (saved via the addon's per-spec profile), so
    -- per-character makes sense — different alts can have different lists.
    local newIdx = pcall(CreateMacro, PI_MACRO_NAME, PI_ICON_ID, body, 1) and
                   GetMacroIndexByName(PI_MACRO_NAME) or nil
    return newIdx, "created"
end

-- Public: opens Blizzard's macro UI so the user can drag the BIT_PI
-- macro onto an action bar without hunting through the list.
function OCA:OpenPIMacroFrame()
    if InCombatLockdown() then return end
    if not MacroFrame then UIParentLoadAddOn("Blizzard_MacroUI") end
    if MacroFrame and MacroFrame.Show then MacroFrame:Show() end
end

-- Watcher frame: queued button-target updates run on PLAYER_REGEN_ENABLED
-- (combat ended). Group roster changes also queue an update so the
-- buttons stay in sync with the actual group composition — useful when
-- a priority-list name leaves the group and the next-priority should
-- take their slot.
do
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:SetScript("OnEvent", function(_, ev)
        if ev == "GROUP_ROSTER_UPDATE" then
            -- Targets don't actually change with roster — the secure
            -- buttons resolve unit names at click time. But we re-apply
            -- anyway so disabled-state cleanups stick if they got
            -- deferred during combat.
            if _piUpdateQueued then applyPIButtonTargets() end
        elseif ev == "PLAYER_REGEN_ENABLED" then
            if _piUpdateQueued then applyPIButtonTargets() end
        end
    end)
end

---------------------------------------------------------------------------
-- Auto-activate on PLAYER_LOGIN if the saved setting says so.
---------------------------------------------------------------------------
do
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self)
        self:UnregisterAllEvents()
        if BIT.db and BIT.db.offensiveCDAlertEnabled then OCA:Enable() end
        -- Initial PI button-target sync on login: if the user has the
        -- feature enabled and a priority list saved, push the names
        -- onto the secure buttons so the macro works the moment the
        -- user logs in (no need to open Settings to "wake it up").
        -- The macro itself is a one-shot creation — handled the first
        -- time the user clicks "Create / Update macro" in Settings —
        -- so we don't recreate it here on every login.
        if BIT.db and BIT.db.piMacroEnabled then
            -- Defer one frame so SecureActionButtonTemplate is fully
            -- registered by the time createPIButtons fires.
            C_Timer.After(0, function() OCA:QueuePIUpdate() end)
        end
    end)
end
