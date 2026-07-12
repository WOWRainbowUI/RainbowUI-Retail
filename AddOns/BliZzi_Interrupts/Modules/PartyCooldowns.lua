-- Copyright (c) 2026 BliZzi1337. All rights reserved.
--[[
    PartyCooldowns.lua - BliZzi_Interrupts
    ─────────────────────────────────────────────────────────
    Tracks defensive cooldowns of party members and displays a small
    icon attached to each member's Blizzard unit frame. The icon shows
    the spell texture, dims while the spell is on cooldown, and a small
    text overlay counts the remaining seconds.

    Design (Phase 1 — clean-room implementation, intentionally distinct
    from any pre-existing party-CD addon's architecture):

      Aura-First Detection
        We don't try to track every UNIT_SPELLCAST_SUCCEEDED for party
        members (unreliable for party units in 12.0.5 and doesn't help
        for cross-realm anyway). Instead we observe UNIT_AURA on each
        party slot and, when a tracked buff appears, treat that as
        proof the spell was cast. The buff carries `aura.sourceUnit`
        which tells us who cast it (for external defensives like Pain
        Suppression cast on a different player).

      Flat Spell Database
        SPELL_DEFS below is a list of plain Lua tables. No abstract
        "evidence sets", no condition objects, no rule schemas — each
        entry just states: aura X means spell Y, with this base CD.

      State by Name, not Unit Token
        Party unit tokens (party1..4) re-shuffle on join / leave, so we
        key the cooldown state by the player's name (which is stable).
        When we need to render an icon we resolve name → current unit
        token → on-screen Blizzard frame at that moment.

      Single Tick Loop
        One OnUpdate handler walks all tracked CDs every tick to update
        the remaining-time text and to remove expired entries — instead
        of one timer per spell which would be O(N²) on cleanup.

    Phase 1 scope:
      - 5 starter defensives (Pain Suppression, Ice Block, Astral Shift,
        Anti-Magic Shell, Dispersion). All have spellId == auraId, so
        no special-casing required for this set.
      - Party only (player + party1..4), not raid.
      - Attached to Blizzard CompactPartyFrame / CompactRaidFrameContainer
        (the two layouts the user can pick via Edit Mode "Use Raid-style
        party frames"). Third-party frames (ElvUI / Cell / Grid2) come
        in a later phase.
      - No talent CD reductions yet. No charge tracking. No network sync.
        All of those land in Phase 2.

    Public API:
      BIT.PartyCooldowns:Enable()       — start observing + rendering
      BIT.PartyCooldowns:Disable()      — stop and hide all icons
      BIT.PartyCooldowns:IsEnabled()    — current state
      BIT.PartyCooldowns:RebuildAnchors() — re-resolve frame anchors,
                                          called on roster + edit-mode events
    ─────────────────────────────────────────────────────────
]]

BIT = BIT or {}
BIT.PartyCooldowns = BIT.PartyCooldowns or {}
local PCD = BIT.PartyCooldowns

------------------------------------------------------------
-- Tracked spell definitions
--
-- Schema (flat, intentionally simple):
--   spellId  : number — the cast spell ID (and, for the spells we
--                       track here, also the aura ID; auraId can be
--                       added as a separate field later if needed for
--                       spells where the buff ID differs).
--   cd       : number — base cooldown in seconds (talent CD reductions
--                       come in a later phase, separate from this DB)
--   dur      : number — buff duration in seconds (informational; CD
--                       ticks down from cast time, not from buff end)
--   affects  : string — "self" (caster is the unit the buff is on) or
--                       "target" (look at aura.sourceUnit to find the
--                       caster — e.g. Pain Suppression cast on a tank)
--   class    : string — owning class clientFile (used to colour the
--                       icon border and to filter who can possibly cast
--                       this spell)
--   cat      : string — "DEF" (defensive: damage reduction / immunity /
--                       absorb) or "OFF" (offensive damage cooldown).
--                       Drives the future Settings UI filter so users
--                       can show/hide each category separately.
--   label    : string — display name (logging / debug only; the in-game
--                       tooltip uses C_Spell.GetSpellName at render time)
--
-- Optional fields:
--   auraId   : number — buff aura ID when it differs from the cast ID
--                       (e.g. Havoc Meta cast=191427 → aura=162264,
--                        Greater Invis cast=110959 → aura=110960).
--                       Used for UNIT_AURA detection; UNIT_SPELLCAST
--                       always uses spellId.
--   spec     : number or { number, ... } — restrict to one or more specs
--   talent   : number — require the spellID to be in the caster's
--                       picked talents (LibSpec talent map). For talent-
--                       only abilities (e.g. Resto Ascendance 114052).
--   race     : string — race-gated entry; class is ignored, caster's
--                       UnitRace english file must match (e.g. "NightElf"
--                       for Shadowmeld).
--   noGlow   : true   — skip the bright-buff phase, transition straight
--                       into the dimmed cooldown swipe. Used for spells
--                       where "buff is active" carries no useful info
--                       (Feign Death, Shadowmeld).
--   cdMods   : { [talentSpellID] = deltaSeconds, ... }
--                     — per-talent CD modifier (absolute seconds). When
--                       the caster has talentSpellID in their LibSpec
--                       talent map, the delta is added to the base CD
--                       (negative reduces). Example: Greater
--                       Invisibility's "Master of Escape" talent
--                       (210476) cuts the CD by 60s, so
--                       { [210476] = -60 }. Multiple talents stack
--                       additively. Applied BEFORE cdPctMods.
--   cdPctMods : { [talentSpellID] = percent, ... }
--                     — per-talent CD modifier (percentage, in whole
--                       percent units). Useful for class-wide passives
--                       like Evoker's "Interwoven Threads" (412713)
--                       that shave a flat 10% off every spell's CD:
--                       { [412713] = -10 }. Multiple pct talents on
--                       the same spell sum linearly (two -10% = -20%,
--                       not -19%). Applied AFTER absolute cdMods so
--                       the percentage operates on the already-reduced
--                       value.
--   durMods  : { [talentSpellID] = deltaSeconds, ... }
--                     — per-talent buff-duration modifier. Extends (or
--                       shortens) the active buff window. Drives the
--                       glow-end timing AND the deferred-inference
--                       observed-lifetime comparison, so a talent that
--                       buffs a spell longer than its base duration
--                       needs an entry here. Example: Druid's
--                       "Improved Barkskin" (327993) extends Barkskin
--                       from 8s to 12s → `durMods = { [327993] = 4 }`.
--   replacedBy : number — when the caster has this talent picked, hide
--                       this entry. Use on the BASE spell to point at
--                       its talent-replacement version. Example: Ice
--                       Block has `replacedBy = 414659` (Ice Cold), so
--                       a Mage who picked Ice Cold sees only the Ice
--                       Cold icon, not both. The replacement entry
--                       itself uses `talent = <id>` to gate its own
--                       appearance.
--   assumeReplaced : true — when the caster's loadout is UNKNOWN,
--                       treat the `replacedBy` talent as picked and
--                       hide this base entry instead of showing base
--                       and replacement side by side. For pairs where
--                       the replacement is the overwhelmingly common
--                       pick (Ice Block → Ice Cold). A known loadout
--                       always wins over this assumption.
--   addsDebuff : true — the spell applies a harmful side-effect aura
--                       to the recipient at cast time (Forbearance for
--                       the Divine Shield / Blessing of Protection /
--                       Blessing of Spellwarding family, Hypothermia
--                       for Ice Block / Ice Cold). Used by the
--                       classification fallback to disambiguate spell
--                       pairs that share Blizzard category flags. When
--                       a HARMFUL aura is added in the same UNIT_AURA
--                       event as the buff under inspection, the
--                       `addsDebuff=true` candidate wins over its
--                       debuff-less flag-twin.
--   charges   : number — base number of charges. Defaults to 1 if
--                       omitted. Multi-charge spells (charges > 1)
--                       recharge serially in WoW: while one charge is
--                       recharging the next one waits its full CD
--                       after the previous one completes. Tracked
--                       per-caster via `_chargeQueue` and visualised
--                       with a small charge-count badge top-right of
--                       the icon plus a CD swipe only when all charges
--                       are consumed.
--   talentChargeBonus : { [talentSpellID] = +N, ... }
--                     — per-talent charge modifier, parallel to
--                       cdMods. Adds `N` to the base charge count
--                       when the caster has the talent. Example: DH
--                       Havoc's "Demonic Resilience" talent gives Blur
--                       an extra charge → `talentChargeBonus = { [1266307] = 1 }`
--                       on the Blur entry.
--   notBig / notExternal / notImportant : true
--                     — negative flag-key overrides. Force the
--                       corresponding bit OFF in `def._auraFlagKey`
--                       regardless of what the Blizzard spell-DB
--                       probe returned. Use when the spell-DB API
--                       claims a flag the live aura instance does
--                       not actually carry at runtime (e.g. Fiery
--                       Brand: IsSpellImportant returns true but
--                       the live buff is "B---" not "B-I-").
--   flagKey  : string — explicit whole-key override (4 chars, B/E/I/R
--                       or "-"). Skips the probe-based computation
--                       entirely. Use only when the additive/negative
--                       bit overrides above can't express the
--                       desired pattern cleanly.
--   selfRefreshing : true or <talentId>
--                     — the spell's self-buff refreshes via game
--                       mechanics (spread, talent procs etc.) not via
--                       additional casts. When set, an
--                       updatedAuraInstanceIDs event runs through a
--                       spread-vs-recast disambiguator: refreshes
--                       arriving close to the 1s grid (relative to the
--                       last refresh, or to the last commit when no
--                       prior refresh exists) are SPREADS and trigger
--                       a glow-only refresh; off-grid refreshes (≥
--                       0.25s away from a 1s multiple, typical of GCD-
--                       paced recasts at ~1.5s) are RECASTS and route
--                       through the normal commit path so the charge
--                       queue advances. Glow-only extends `_glowEnd`
--                       to `now + dur`, re-arms LBG overlay, restores
--                       bright-buff visual — `_cdEnd` and the charge
--                       queue stay untouched. With `true` the
--                       behaviour is unconditional. With a talent ID,
--                       the disambiguator only engages when the caster
--                       has that talent picked — needed for spells
--                       whose self-refresh only triggers via a talent.
--                       When talent data is unknown (M+ comm-block),
--                       the disambiguator engages optimistically
--                       (alternative — counting every refresh as a
--                       recast — drains the charge queue to 0 on a
--                       single use, which is the visibly-worse
--                       failure mode). Example: Fiery Brand spreads
--                       via Burning Alive (207739) — so
--                       `selfRefreshing = 207739` rather than `true`.
--
-- Spell list compiled from game data (spell IDs and base cooldowns are
-- public information from the WoW API / spell database, not code).
-- Talent-replaced variants (e.g. Ice Block ↔ Ice Cold, Berserk ↔
-- Incarnation) are listed as separate entries so whichever version the
-- player has talented gets detected. Pure procs and cheat-death
-- auto-triggers are intentionally omitted — those aren't user-cast
-- cooldowns and would create false "this player burned their CD"
-- signals on the bar.
------------------------------------------------------------
-- WoW spec IDs (game data). Used to gate entries below.
-- Listed once here so the SPELL_DEFS list stays focused on game data.
local SPEC = {
    DK_BLOOD      = 250, DK_FROST       = 251, DK_UNHOLY      = 252,
    DH_HAVOC      = 577, DH_VENGEANCE   = 581, DH_DEVOURER   = 1480,
    DRUID_BAL     = 102, DRUID_FERAL    = 103, DRUID_GUARDIAN = 104, DRUID_RESTO    = 105,
    EVOKER_DEVA   = 1467, EVOKER_PRES   = 1468, EVOKER_AUG    = 1473,
    HUNT_BM       = 253, HUNT_MM        = 254, HUNT_SV        = 255,
    MAGE_ARCANE   = 62,  MAGE_FIRE      = 63,  MAGE_FROST     = 64,
    MONK_BREW     = 268, MONK_MIST      = 270, MONK_WW        = 269,
    PAL_HOLY      = 65,  PAL_PROT       = 66,  PAL_RET        = 70,
    PRI_DISC      = 256, PRI_HOLY       = 257, PRI_SHADOW     = 258,
    ROG_ASS       = 259, ROG_OUTLAW     = 260, ROG_SUB        = 261,
    SHAM_ELE      = 262, SHAM_ENH       = 263, SHAM_RESTO     = 264,
    WL_AFFLI      = 265, WL_DEMO        = 266, WL_DESTRO      = 267,
    WAR_ARMS      = 71,  WAR_FURY       = 72,  WAR_PROT       = 73,
}

local SPELL_DEFS = {
    -- ── Death Knight ────────────────────────────────────
    { spellId = 48707,  cd = 60,  dur = 5,   affects = "self",   class = "DEATHKNIGHT", cat = "DEF", label = "Anti-Magic Shell",
        cdMods  = { [205727] = -20,            -- Anti-Magic Barrier: -20s CD
                    [457574] =  20 },          -- Magicus Pestis (or similar): +20s CD in exchange for dispel
        durMods = { [205727] =   2 } },        -- Anti-Magic Barrier: +40% duration (5s base → 7s)
    { spellId = 48792,  cd = 120, dur = 8,   affects = "self",   class = "DEATHKNIGHT", cat = "DEF", label = "Icebound Fortitude" },
    { spellId = 55233,  cd = 90,  dur = 10,  affects = "self",   class = "DEATHKNIGHT", cat = "DEF", label = "Vampiric Blood",                   spec = SPEC.DK_BLOOD,      talent = 55233,
        durMods = { [317133] = 4 } },          -- Improved Vampiric Blood (max rank): +4s duration
    { spellId = 51271,  cd = 45,  dur = 12,  affects = "self",   class = "DEATHKNIGHT", cat = "OFF", label = "Pillar of Frost",                  spec = SPEC.DK_FROST },

    -- ── Demon Hunter ────────────────────────────────────
    -- Blur is granted to both Havoc (baseline) and Devourer (via the
    -- spec's root talent 473728, which is auto-applied with the
    -- spec). spec field is a list so both 577 and 1480 admit it.
    { spellId = 198589, auraId = 212800, cd = 60,  dur = 10,  affects = "self",   class = "DEMONHUNTER", cat = "DEF", label = "Blur",                             spec = { SPEC.DH_HAVOC, SPEC.DH_DEVOURER },
        talentChargeBonus = { [1266307] = 1 } },  -- Demonic Resilience talent: +1 charge
    -- Metamorphosis — the live self-buff carries the IMPORTANT flag
    -- ("--I-") which collides with Pala Blessing of Freedom (same key,
    -- target-cast). Both spec variants are listed so selfCands is
    -- non-empty when a DH casts Meta — without these entries the
    -- isImp branch would see target=[BoF] / self=[] and commit BoF
    -- on the DH wrongly. With Meta present, the tie branch forwards
    -- both candidates to duration narrowing which separates Meta
    -- (15s Veng, 30s Havoc base) from BoF (8s).
    --
    -- Vengeance variant is ENABLED (tracked). Last-resort
    -- class+spec exclusivity catches it even when talent-extended
    -- durations defeat the strict ±0.6s duration narrowing — Meta-
    -- Vengeance is the only DH self-cast "--I-" def, so the
    -- class+spec pool collapses uniquely to it.
    --
    -- Havoc variant stays DISABLED for now — duration narrowing is
    -- less reliable for Havoc's 30s base + multiple talent extensions,
    -- and Havoc Meta isn't typically the most useful CD to track
    -- (offensive burst window). Re-enable if there's user demand.
    { spellId = 191427, cd = 240, dur = 30,  affects = "self",   class = "DEMONHUNTER", cat = "OFF", label = "Metamorphosis (Havoc)",        spec = SPEC.DH_HAVOC,
        important = true, disabled = true },
    { spellId = 187827, cd = 180, dur = 15,  affects = "self",   class = "DEMONHUNTER", cat = "DEF", label = "Metamorphosis (Vengeance)",    spec = SPEC.DH_VENGEANCE,
        important = true,
        durMods = { [1265818] = 5 } },         -- Soul Furnace (or similar duration-extender): +5s
    -- Void Metamorphosis (Devourer): the spec's transform cooldown.
    -- Disabled for now — exact CD / duration / flag pattern needs
    -- live verification before enabling. Listed so the Spell Filter
    -- panel surfaces it and a future enable just flips `disabled`.
    { spellId = 1217605, cd = 240, dur = 30, affects = "self",   class = "DEMONHUNTER", cat = "OFF", label = "Void Metamorphosis",           spec = SPEC.DH_DEVOURER,
        important = true, disabled = true },
    -- Fiery Brand: cast ID (204021) differs from the self-buff aura
    -- ID (207771) that lands on the Vengeance DH for the damage-
    -- reduction window. The Blizzard spell-DB query IsSpellImportant
    -- returns true for both 204021 and 207771, but at RUNTIME the
    -- live aura instance is only flagged BIG ("B---" via
    -- IsAuraFilteredOutByInstanceID) — IMPORTANT is NOT set. Without
    -- `notImportant = true` the def's flag key would compute to
    -- "B-I-" and never match the "B---" live aura, so classification
    -- fails and no glow lands. `big = true` is technically redundant
    -- here (the probe already returns true) but kept explicit for
    -- consistency with the documented annotation pattern.
    { spellId = 204021, auraId = 207771, cd = 60,  dur = 12,  affects = "self",   class = "DEMONHUNTER", cat = "DEF", label = "Fiery Brand",                      spec = SPEC.DH_VENGEANCE,
        big = true,
        notImportant = true,
        selfRefreshing = 207739,                 -- Burning Alive: FB spreads to a nearby enemy every 1s, refreshing the DH self-buff. Without this talent there's no spread → refreshes ARE recasts.
        cdMods = { [389732] = -12 },             -- Down in Flames: -12s CD
        talentChargeBonus = { [389732] = 1 } },  -- Down in Flames: +1 charge (total 2)

    -- ── Druid ───────────────────────────────────────────
    { spellId = 22812,  cd = 60,  dur = 8,   affects = "self",   class = "DRUID",       cat = "DEF", label = "Barkskin",
        cdSpecMods = { [SPEC.DRUID_GUARDIAN] = -26 },   -- Guardian baseline CD is 34s (60 - 26), not 60s
        durMods = { [327993] = 4,                       -- Improved Barkskin: +4s duration (total 12s)
                    [393611] = 2 } },                   -- Ursoc's Endurance (Guardian): +2s duration
    -- Celestial Alignment: both cast event and the buff aura on the
    -- player carry spellID 194223 (an alternate ID 383410 exists in
    -- the spell database but isn't what arrives via UNIT_AURA). The
    -- buff aura carries Blizzard's IMPORTANT classification flag at
    -- runtime, but the SPELL-DB query IsSpellImportant returns false
    -- for the cast ID — `important = true` forces the I bit on the
    -- flag key so the classification fallback can pin the aura back
    -- to this def in M+ where UNIT_SPELLCAST_SUCCEEDED is silent for
    -- party members.
    --
    -- replacedBy = 102560 hides this entry when the Balance druid
    -- picks Chosen of Elune (the replacement entry below surfaces
    -- via its own `talent` gate).
    { spellId = 194223, cd = 180, dur = 15, affects = "self", class = "DRUID", cat = "OFF", label = "Celestial Alignment",      spec = SPEC.DRUID_BAL, replacedBy = 102560, important = true,
        cdMods = { [468743] = -60,                -- Whirling Stars: -60s CD
                   [390378] = -60 },              -- Orbit Breakers (or similar secondary CDR): -60s
        talentChargeBonus = { [468743] = 1 } },   -- Whirling Stars: +1 charge (total 2)
    -- Incarnation: Chosen of Elune: same story as CA — cast and buff
    -- both use 102560 in the live event stream, IMPORTANT flag set at
    -- runtime but not surfaced by IsSpellImportant.
    { spellId = 102560, cd = 180, dur = 20, affects = "self", class = "DRUID", cat = "OFF", label = "Incarnation: Chosen of Elune", spec = SPEC.DRUID_BAL, talent = 102560, important = true,
        cdMods = { [468743] = -60,                -- Whirling Stars: -60s CD
                   [390378] = -60 },              -- Secondary CDR talent: -60s
        talentChargeBonus = { [468743] = 1 } },   -- Whirling Stars: +1 charge (total 2)
    { spellId = 106951, cd = 180, dur = 15,  affects = "self",   class = "DRUID",       cat = "OFF", label = "Berserk (Feral)",                  spec = SPEC.DRUID_FERAL,
        cdMods = { [391174] = -60,             -- Heart of the Lion (shared with Avatar of Ashamane): -60s
                   [391548] = -30 } },         -- Ashamane's Guidance (shared with Avatar of Ashamane): -30s
    { spellId = 102543, cd = 180, dur = 20,  affects = "self",   class = "DRUID",       cat = "OFF", label = "Incarnation: Avatar of Ashamane",  spec = SPEC.DRUID_FERAL,   talent = 102543,
        cdMods = { [391174] = -60,             -- Shared Berserk CD-reduction: -60s
                   [391548] = -30 } },         -- Ashamane-specific CDR: -30s
    { spellId = 50334,  cd = 180, dur = 15,  affects = "self",   class = "DRUID",       cat = "OFF", label = "Berserk (Guardian)",               spec = SPEC.DRUID_GUARDIAN },
    { spellId = 102558, cd = 180, dur = 30,  affects = "self",   class = "DRUID",       cat = "OFF", label = "Incarnation: Guardian of Ursoc",   spec = SPEC.DRUID_GUARDIAN, talent = 102558 },
    { spellId = 102342, cd = 90,  dur = 12,  affects = "target", class = "DRUID",       cat = "DEF", label = "Ironbark",                         spec = SPEC.DRUID_RESTO,
        cdMods  = { [382552] = -20 },          -- Ironbark CD-reduction talent: -20s
        durMods = { [392116] =   4 } },        -- Ironbark duration extender: +4s (12s base → 16s)

    -- ── Evoker ──────────────────────────────────────────
    { spellId = 375087, cd = 120, dur = 18,  affects = "self",   class = "EVOKER",      cat = "OFF", label = "Dragonrage",                       spec = SPEC.EVOKER_DEVA,
        cdPctMods = { [412713] = -10 } },         -- Interwoven Threads class passive: -10% CD
    { spellId = 363916, cd = 90,  dur = 12,  affects = "self",   class = "EVOKER",      cat = "DEF", label = "Obsidian Scales",
        cdPctMods = { [412713] = -10 },           -- Interwoven Threads class passive: -10% CD
        talentChargeBonus = { [375406] = 1 } },   -- Obsidian Bulwark talent: +1 charge (total 2)
    { spellId = 357170, cd = 60,  dur = 8,   affects = "target", class = "EVOKER",      cat = "DEF", label = "Time Dilation",                    spec = SPEC.EVOKER_PRES,   talent = 357170,
        cdMods    = { [376204] = -10 },           -- Just in Time reduces CD by 10s
        cdPctMods = { [412713] = -10 },           -- Interwoven Threads class passive: -10% CD
        durMods   = { [376240] =   2 },           -- Extended Dilation (max rank ~+30% of 8s ≈ +2s)
        talentChargeBonus = { [376204] = 1 } },   -- Just in Time also grants +1 charge (total 2)

    -- ── Hunter ──────────────────────────────────────────
    { spellId = 264735, cd = 90,  dur = 6,   affects = "self",   class = "HUNTER",      cat = "DEF", label = "Survival of the Fittest",
        -- minDur: Dark Ranger "Smoke Screen" (430709) grants a 3s SotF
        -- aura whenever Exhilaration is used — a talent PROC, not a use.
        -- The real spell never runs below 6s, so any readable duration
        -- under 5s must not commit a charge/CD (see the proc guard in
        -- the scan loop).
        minDur = 5,
        durMods = { [388039] = 2 },              -- Lone Survivor: +2s duration (6s → 8s)
        talentChargeBonus = { [459450] = 1 } },  -- Padded Armor talent: +1 charge (total 2)
    { spellId = 288613, cd = 120, dur = 15,  affects = "self",   class = "HUNTER",      cat = "OFF", label = "Trueshot",                         spec = SPEC.HUNT_MM,
        cdMods = { [260404] = -30 } },           -- Calling the Shots: -30s CD
        -- (No duration talent modeled: the previously-listed 1253830 is a
        --  Survival talent and can never apply to a Marksmanship hunter.)
    { spellId = 1250646, cd = 90, dur = 8,   affects = "self",   class = "HUNTER",      cat = "OFF", label = "Takedown",                         spec = SPEC.HUNT_SV,
        cdMods  = { [1251790] = -30 },           -- Savagery talent reduces CD by 30s
        durMods = { [1253830] =   2 } },         -- Shared duration extension: +2s
    { spellId = 186265, cd = 180, dur = 8,   affects = "self",   class = "HUNTER",      cat = "DEF", label = "Aspect of the Turtle",
        cdMods = { [1258485] = -30,            -- Turtle CD reduction talent: -30s
                   [266921]  = -30 } },        -- Hardened Carapace (multi-rank, max effect): -30s
    -- Feign Death uses dur=360 as an upper bound only — the hunter
    -- typically stands back up far earlier. OnUnitFlags below force-ends
    -- the glow exactly when UnitIsFeignDeath flips back to false, so the
    -- nominal 360s ceiling is effectively just a safety net.
    { spellId = 5384,   cd = 30,  dur = 360, affects = "self",   class = "HUNTER",      cat = "DEF", label = "Feign Death",
        cdMods = { [1258486] = -10 } },          -- Feign Death CD reduction (max rank): -10s
    -- Roar of Sacrifice: talent-gated external defensive cast on an ally
    -- (redirects a share of their damage). Trust the Blizzard API for the
    -- EXTERNAL classification, same as the other target-cast externals.
    { spellId = 53480,  cd = 120, dur = 10,  affects = "target", class = "HUNTER",      cat = "DEF", label = "Roar of Sacrifice",                   talent = 53480 },

    -- ── Mage ────────────────────────────────────────────
    { spellId = 365350, cd = 90,  dur = 15,  affects = "self",   class = "MAGE",        cat = "OFF", label = "Arcane Surge",                     spec = SPEC.MAGE_ARCANE },
    -- Ice Block / Ice Cold both apply the Hypothermia debuff (41425)
    -- to the mage WHEN CAST — same same-batch harmful-aura side
    -- channel as the Paladin Forbearance family. Their flag-twin
    -- Alter Time applies no debuff, so `addsDebuff` splits the BIG
    -- candidate pool at apply time (live report: the second Ice Cold
    -- charge glowed as Alter Time until the duration probe swapped).
    { spellId = 45438,  cd = 240, dur = 10,  affects = "self",   class = "MAGE",        cat = "DEF", label = "Ice Block",                        replacedBy = 414659,
        -- Unknown loadout → show only the Ice Cold entry, not both:
        -- Frost (the M+ mage spec) virtually always talents Ice Cold,
        -- and two icons with optimistic 2-charge badges each read as
        -- four immunity charges. A known loadout restores the exact
        -- per-talent display either way.
        assumeReplaced = true,
        addsDebuff = true,
        cdMods = { [382424]  = -60,            -- Cold as Ice (or similar Ice Block CDR talent): -60s
                   [1265517] = -30 },          -- Secondary Ice Block CDR: -30s
        talentChargeBonus = { [1244110] = 1 } },  -- Ice Block extra-charge talent: +1 (total 2)
    -- Ice Cold (replaces Ice Block via talent 414659). LIVE event stream:
    -- the CAST fires as 414658 while the buff aura lands as 414659. The
    -- def previously had the two IDs swapped (cast 414659 / aura 414658),
    -- so neither the cast path nor the aura path ever matched and Frost
    -- mages with Ice Cold talented were not tracked at all. spellId stays
    -- the canonical 414659 (aura + icon + spell-filter identity); the
    -- real cast ID routes in via extraCastIds.
    { spellId = 414659, extraCastIds = { 414658 }, cd = 240, dur = 6,   affects = "self",   class = "MAGE",        cat = "DEF", label = "Ice Cold",                         talent = 414659,
        -- The spell-DB probe returns NO flags for either Ice Cold ID
        -- (/bitpcd flags showed "----"), but the buff is a big defensive
        -- at runtime like the Ice Block it replaces. Without the forced
        -- B bit the aura-classification path (instances, secret spellIDs)
        -- could never match this def.
        big = true,
        addsDebuff = true,                     -- Hypothermia lands in the same batch (see Ice Block note)
        cdMods = { [382424]  = -60,            -- Same Ice Block CDR talents apply to Ice Cold variant
                   [1265517] = -30 },
        talentChargeBonus = { [1244110] = 1 } },
    { spellId = 55342,  cd = 120, dur = 15,  affects = "self",   class = "MAGE",        cat = "DEF", label = "Mirror Image",                     talent = 55342,
        cdMods = { [1244025] = -60 },          -- Mirror Image CDR talent (max rank): -60s
        disabled = true },                     -- not reliably trackable (no B/E category flag)
    -- Alter Time fires UNIT_SPELLCAST_SUCCEEDED with two different cast IDs
    -- depending on the active spec (one variant is Arcane's, the other is
    -- Frost/Fire's) but both produce the same buff aura (342246) and share
    -- the same CD. The extraCastIds entry lists the alternate cast ID so
    -- the index build above routes both to this single def.
    -- The live buff aura is classified BIG_DEFENSIVE at runtime, not
    -- IMPORTANT. The def previously carried `important = true` ("--I-"),
    -- which (a) never matched the live "B---" aura for party members and
    -- (b) let a big-classified Alter Time aura fall into the mage's BIG
    -- candidate pool where only Ice Block lives — both run 10s buffs, so
    -- duration narrowing couldn't separate them and Alter Time (50s CD)
    -- could glow as Ice Block (240s CD). Same spell-DB-vs-live mismatch
    -- pattern as Fiery Brand: force B on, I off.
    { spellId = 342245, auraId = 342246, extraCastIds = { 342247 }, cd = 50,  dur = 10,  affects = "self",   class = "MAGE",        cat = "DEF", label = "Alter Time",
        big = true,
        notImportant = true,
        cdMods = { [1255166] = -10 } },        -- Alter Time CDR: -10s
    { spellId = 190319, cd = 120, dur = 10,  affects = "self",   class = "MAGE",        cat = "OFF", label = "Combustion",                       spec = SPEC.MAGE_FIRE,
        cdMods = { [1254194] = -60 } },        -- Fevered Incantation (or core Fire Combustion CDR): -60s
    { spellId = 110959, auraId = 110960, cd = 120, dur = 20,  affects = "self",   class = "MAGE",        cat = "DEF", label = "Greater Invisibility",             spec = SPEC.MAGE_ARCANE,   talent = 110959,
        noGlow = true, cdMods = { [210476] = -60 },    -- Master of Escape reduces CD by 60s
        disabled = true },                     -- not reliably trackable (no B/E category flag); spec fixed to Arcane while at it

    -- ── Monk ────────────────────────────────────────────
    { spellId = 115203, auraId = 120954, cd = 120, dur = 15,  affects = "self",   class = "MONK",        cat = "DEF", label = "Fortifying Brew",
        -- Brewmaster's baseline Fortifying Brew CD is 360s (vs 120s for WW/MW),
        -- and Expeditious Fortification reduces it far more for Brewmaster.
        cdSpecMods = { [SPEC.MONK_BREW] = 240 },                              -- Brewmaster baseline: 120 + 240 = 360
        cdMods = { [388813] = { default = -30, [SPEC.MONK_BREW] = -120 } } }, -- Expeditious Fortification: -30s (WW/MW), -120s (Brew)
    { spellId = 116849, cd = 120, dur = 12,  affects = "target", class = "MONK",        cat = "DEF", label = "Life Cocoon",                      spec = SPEC.MONK_MIST,
        absorbEvidence = true,          -- Cocoon shields the target: absorb side-channel confirms it among EXT candidates
        cdMods = { [202424] = -45 } },  -- Chrysalis: -45s (live-confirmed; do not "fix" to -30)
    { spellId = 132578, cd = 120, dur = 25,  affects = "self",   class = "MONK",        cat = "OFF", label = "Invoke Niuzao, the Black Ox",      spec = SPEC.MONK_BREW,
        cdMods = { [450989] = -25 } },         -- Call to Arms (or Brewmaster Niuzao CDR): -25s
    -- Touch of Karma: cast ID (122470) and self-buff aura ID (125174)
    -- differ — the cast applies an absorb buff to the WW monk (125174)
    -- while also placing a damage-redirect debuff on the target. Without
    -- auraId set, the aura-scan path couldn't find the buff on a party
    -- WW monk in M+ where cast events are unreliable. Set auraId so the
    -- _spellByAuraId index routes the buff scan back to this def.
    --
    -- `big = true`: the live aura carries BIG_DEFENSIVE, but the spell-DB
    -- probe (AuraIsBigDefensive) returns false for both IDs, so the flag
    -- bit must be forced on or the runtime "B---" aura never matches.
    -- NO talent gate: the buff appearing is proof enough the monk has
    -- it — gating on a talent ID dropped it
    -- from the candidate pool whenever the loadout was known but the
    -- talent set didn't list 122470. It shares the WW BIG self-cast pool
    -- with class-wide Fortifying Brew (15s); the absorb side-channel
    -- resolver below (ToK applies an absorb shield, Fort Brew doesn't)
    -- separates them.
    { spellId = 122470, auraId = 125174, cd = 90,  dur = 10,  affects = "self",   class = "MONK",        cat = "DEF", label = "Touch of Karma",                   spec = SPEC.MONK_WW,       big = true },
        -- Touch of Karma carries no CD/duration talent modifiers here: the WW
        -- talents 280197 / 450989 (cooldown) and 391370 (+duration) modify
        -- Zenith, not Karma — attaching them to Karma mis-sized its CD/duration.

    -- ── Paladin ─────────────────────────────────────────
    --
    -- Manual flag-key annotations are SURGICAL — only applied where
    -- a specific runtime mismatch was observed. The blanket-annotate
    -- approach (forcing a maximal flag set per spell) was too
    -- aggressive and broke spells that were already detected fine via
    -- the Blizzard spell-DB API (Blessing of Sacrifice was the
    -- canonical regression: a max-flag annotation BIG+EXTERNAL+RAID
    -- diverged from the runtime aura which only carries the EXTERNAL
    -- bit, and the over-specified def stopped matching).
    --
    -- Annotation rules going forward:
    --   * Only add a flag here when a confirmed user-visible bug
    --     traces to API-vs-runtime mismatch.
    --   * Defaults (no annotation) trust the Blizzard API — this
    --     worked correctly for Blessing of Sacrifice, BoP,
    --     BoSpellwarding, AC, AD, GoAK and Sentinel under live test.
    --   * Keep annotations on the Pala spells where the bug was
    --     observed: BoF, AW, DP, DS, Wake of Ashes.
    { spellId = 6940,   cd = 120, dur = 12,  affects = "target", class = "PALADIN",     cat = "DEF", label = "Blessing of Sacrifice",
        -- Sacrifice of the Just: the reduction is spec-dependent —
        -- Prot/Ret get -60s (120 → 60) but Holy only -15s (120 → 105).
        -- A flat -60 made Holy BoSac show ready 45s early.
        cdMods = { [384820] = { default = -60, [SPEC.PAL_HOLY] = -15 } } },
    -- Divine Protection: re-enabled with a BIG+IMPORTANT expected key
    -- and a Holy spec gate. Rationale: in modern WoW the base 498 spell
    -- is Holy-only (Prot uses Ardent Defender, Ret has the 403876
    -- variant), so the spec gate alone removes it from Prot/Ret pools.
    -- The `big = true` annotation moves its expected key out of the
    -- crowded "--I-" pool (BoF / DS / AW) into "B-I-", which live
    -- 12.x auras for personal damage-reduction walls carry — this is
    -- what makes it distinguishable from a self-cast BoF (same 8s
    -- duration, IMPORTANT-only). NEEDS LIVE CONFIRMATION on a Holy
    -- Paladin: if the live aura turns out to lack the BIG bit, this
    -- entry silently never matches (no wrong glow — it just won't
    -- track) and the annotation must be revisited.
    { spellId = 498,    cd = 60,  dur = 8,   affects = "self",   class = "PALADIN",     cat = "DEF", label = "Divine Protection",                spec = SPEC.PAL_HOLY,
        big = true, important = true,
        cdMods = { [114154] = -18 } },  -- Unbreakable Spirit: 30% of 60s = 18s reduction
    -- Ret-specific Divine Protection variant: separate spell ID (403876)
    -- with 90s base CD (vs the 60s base for Holy/Prot's 498). Talent-
    -- gated so the entry only materialises for a Ret who picked the
    -- DP node. Shares the same Pala "--I-" flag-key pool as BoF / AW /
    -- DS / base DP — `noGlow = true` skips the buff-active highlight
    -- phase entirely so even when the flag-twin disambiguator misses,
    -- there's no misleading glow flash on a sibling icon; only a quiet
    -- CD swipe lands. CD bookkeeping still runs so the user gets the
    -- timer if the attribution is correct.
    { spellId = 403876, cd = 90,  dur = 8,   affects = "self",   class = "PALADIN",     cat = "DEF", label = "Divine Protection (Ret)",          spec = SPEC.PAL_RET,       talent = 403876,
        important = true, noGlow = true,
        cdMods = { [114154] = -27 } },  -- Unbreakable Spirit: 30% of 90s = 27s reduction
    -- Divine Shield / BoP / BoSpellwarding all apply the Forbearance
    -- debuff (25771) to the recipient WHEN CAST — reliably, every
    -- time, regardless of whether existing debuffs got cleared.
    -- Their flag-twins (Divine Protection, Blessing of Sacrifice)
    -- don't trigger Forbearance. The classification fallback uses
    -- "did a HARMFUL aura appear in the same UNIT_AURA event as
    -- this buff" to pick `addsDebuff=true` over its twin.
    --
    -- DS gets `important=true` (same as DP) so it shares the
    -- "--I-" flag-key bucket with DP and the Forbearance probe is
    -- what distinguishes them at runtime. BIG bit removed — same
    -- reason as DP, the runtime aura doesn't carry it.
    { spellId = 642,    cd = 300, dur = 8,   affects = "self",   class = "PALADIN",     cat = "DEF", label = "Divine Shield",                    addsDebuff = true,
        important = true,
        -- Both reductions are percentages in-game, so they live in
        -- cdPctMods and sum additively (-45% with both talents = 165s);
        -- a flat -90 for Unbreakable Spirit alone is equivalent (210s)
        -- but stacked wrong with the Prot percentage.
        cdPctMods = { [114154] = -30,          -- Unbreakable Spirit: -30%
                      [378425] = -15 } },      -- Prot talent: extra -15% on DS / Forbearance blessings
    -- BoP and Spellwarding share one 300s cooldown slot in-game —
    -- Spellwarding REPLACES BoP when talented. `replacedBy` hides the
    -- BoP entry once the loadout confirms the pick (unknown loadouts
    -- keep both icons; only the one actually cast ever fires).
    { spellId = 1022,   cd = 300, dur = 10,  affects = "target", class = "PALADIN",     cat = "DEF", label = "Blessing of Protection",           addsDebuff = true, replacedBy = 204018,
        cdMods    = { [384909] = -60 },        -- Improved Blessing of Protection: -60s
        cdPctMods = { [378425] = -15 } },      -- Prot talent: extra -15% on DS / Forbearance blessings
    -- Spellwarding is a class-tree pick — any spec can talent it, so
    -- no spec gate (was wrongly Prot-only; a Holy/Ret Spellwarding
    -- went untracked and their BoP entry mis-fired instead).
    { spellId = 204018, cd = 300, dur = 10,  affects = "target", class = "PALADIN",     cat = "DEF", label = "Blessing of Spellwarding",         talent = 204018,
        addsDebuff = true,
        cdMods    = { [384909] = -60 },        -- Shared BoP/BoSpellwarding CDR: -60s
        cdPctMods = { [378425] = -15 } },      -- Prot talent: extra -15% on DS / Forbearance blessings
    -- Blessing of Freedom (1044) is intentionally NOT tracked. Its buff
    -- carries only the IMPORTANT flag (no BIG/EXTERNAL), which is shared
    -- with ordinary food/flask/intellect/trinket-proc buffs, and party
    -- cast spell IDs are secret in M+ — so there is no reliable signal to
    -- tell a real Freedom apart from a random utility buff. Do NOT re-add.
    -- Avenging Wrath: DISABLED — same root cause as Divine Protection.
    -- AW shares the "--I-" runtime flag-key with BoF / DP / DS (and,
    -- when Radiant Glory is talented, the WoA-applied AW buff with
    -- only an 8s duration that doesn't match AW's 20s either), and
    -- there's no reliable disambiguator for party-member casts in
    -- 12.0.5. Listing the def with `disabled = true` so users see
    -- "Currently not trackable" in the Spell Filter panel.
    --
    -- Wake of Ashes / Radiant Glory tracking was attempted earlier
    -- (a separate WoA def + replacedBy gate on AW) but the resulting
    -- ambiguity moved the misattribution around (WoA → BoF and back)
    -- without ever landing on the actual cast spell. Both AW and DP
    -- stay listed-but-disabled until a cleaner classification path
    -- exists for the Pala "--I-" flag-twin pool.
    { spellId = 31884,  cd = 120, dur = 20,  affects = "self",   class = "PALADIN",     cat = "OFF", label = "Avenging Wrath",
        important = true, disabled = true },
    { spellId = 216331, cd = 60,  dur = 10,  affects = "self",   class = "PALADIN",     cat = "OFF", label = "Avenging Crusader",                spec = SPEC.PAL_HOLY,      talent = 216331,
        -- Base duration corrected 15 → 10: the old 15 already baked in
        -- Sanctified Wrath; with the talent modeled separately the glow
        -- and the duration probe were both 5s long.
        cdMods  = { [1241511] = -15 },         -- Avenging Crusader CDR (max rank): -15s
        durMods = { [53376]   =   5 } },       -- Sanctified Wrath (Holy, +50% of 10s): +5s
    { spellId = 31850,  cd = 90,  dur = 8,   affects = "self",   class = "PALADIN",     cat = "DEF", label = "Ardent Defender",                  spec = SPEC.PAL_PROT,
        cdMods = { [114154] = -27 } },         -- Unbreakable Spirit: 30% of 90s = 27s reduction
    { spellId = 86659,  cd = 180, dur = 8,   affects = "self",   class = "PALADIN",     cat = "DEF", label = "Guardian of Ancient Kings",        spec = SPEC.PAL_PROT,
        talentChargeBonus = { [1246481] = 1 } },  -- GoAK extra charge talent: +1 (total 2)
    { spellId = 389539, cd = 120, dur = 20,  affects = "self",   class = "PALADIN",     cat = "OFF", label = "Sentinel",                         spec = SPEC.PAL_PROT,      talent = 389539,
        -- Base duration corrected 16 → 20 (live buff length); the
        -- talent deltas below are re-derived from the 20s base.
        cdMods  = { [204074] = -60 },          -- Sentinel CDR (-50% of 120s base): -60s
        durMods = { [53376]  =   5,            -- Sanctified Wrath (Prot, +25% of 20s): +5s
                    [204074] =  -8 } },        -- Same talent shortens duration by 40% of 20s = -8s

    -- ── Priest ──────────────────────────────────────────
    { spellId = 47585,  cd = 120, dur = 6,   affects = "self",   class = "PRIEST",      cat = "DEF", label = "Dispersion",                       spec = SPEC.PRI_SHADOW,
        cdMods  = { [288733] = -30 },          -- Intangibility (or Shadow Dispersion CDR): -30s
        durMods = { [453729] =   2 } },        -- Dispersion duration extender: +2s (6s base → 8s)
    { spellId = 19236,  cd = 90,  dur = 10,  affects = "self",   class = "PRIEST",      cat = "DEF", label = "Desperate Prayer",
        cdMods  = { [238100] = -20 },          -- Angel's Mercy reduces CD by 20s
        durMods = { [458718] =  10 } },        -- Desperate Prayer duration extender: +10s (10s → 20s)
    { spellId = 33206,  cd = 180, dur = 8,   affects = "target", class = "PRIEST",      cat = "DEF", label = "Pain Suppression",                 spec = SPEC.PRI_DISC,
        talentChargeBonus = { [373035] = 1 } },  -- Protector of the Frail talent: +1 charge
    { spellId = 64843,  cd = 180, dur = 5,   affects = "self",   class = "PRIEST",      cat = "DEF", label = "Divine Hymn",                      spec = SPEC.PRI_HOLY,
        cdMods = { [419110] = -60 },           -- Divine Hymn CDR talent: -60s
        disabled = true },                     -- not reliably trackable
    { spellId = 47788,  cd = 180, dur = 10,  affects = "target", class = "PRIEST",      cat = "DEF", label = "Guardian Spirit",                  spec = SPEC.PRI_HOLY,
        durMods = { [440738] = 2 },            -- Guardian Spirit duration extender: +2s
        disabled = true },                     -- not reliably trackable
    { spellId = 228260, cd = 120, dur = 20,  affects = "self",   class = "PRIEST",      cat = "OFF", label = "Voidform",                         spec = SPEC.PRI_SHADOW },

    -- ── Rogue ───────────────────────────────────────────
    { spellId = 1856,   cd = 120, dur = 3,   affects = "self",   class = "ROGUE",       cat = "DEF", label = "Vanish",
        disabled = true },                       -- temporarily disabled

    { spellId = 31224,  cd = 120, dur = 5,   affects = "self",   class = "ROGUE",       cat = "DEF", label = "Cloak of Shadows",
        durMods = { [457022] = 2 } },          -- Cloak duration extender: +2s
    { spellId = 5277,   cd = 120, dur = 10,  affects = "self",   class = "ROGUE",       cat = "DEF", label = "Evasion" },
    { spellId = 13750,  cd = 180, dur = 15,  affects = "self",   class = "ROGUE",       cat = "OFF", label = "Adrenaline Rush",                  spec = SPEC.ROG_OUTLAW,
        durMods = { [1259465] = 4 } },         -- Adrenaline Rush duration extender: +4s
    { spellId = 121471, cd = 90,  dur = 20,  affects = "self",   class = "ROGUE",       cat = "OFF", label = "Shadow Blades",                    spec = SPEC.ROG_SUB,       talent = 121471 },

    -- ── Shaman ──────────────────────────────────────────
    { spellId = 108271, cd = 120, dur = 12,  affects = "self",   class = "SHAMAN",      cat = "DEF", label = "Astral Shift",
        cdMods = { [381647] = -30 } },  -- Planes Traveler reduces CD by 30s
    { spellId = 114052, cd = 180, dur = 15,  affects = "self",   class = "SHAMAN",      cat = "OFF", label = "Ascendance (Resto)",               spec = SPEC.SHAM_RESTO,    talent = 114052,
        cdMods = { [462440] = -60 } },         -- Ascendance CDR talent (shared Ele/Resto): -60s
        -- (No duration talent modeled: 462443 is an Elemental-only talent and
        --  can never apply to a Restoration shaman.)
    { spellId = 114051, cd = 180, dur = 15,  affects = "self",   class = "SHAMAN",      cat = "OFF", label = "Ascendance (Enhance)",             spec = SPEC.SHAM_ENH,      talent = 114051,
        cdMods = { [384444] = -60 } },         -- Thorim's Invocation: -60s CD
    { spellId = 114050, cd = 180, dur = 15,  affects = "self",   class = "SHAMAN",      cat = "OFF", label = "Ascendance (Elemental)",           spec = SPEC.SHAM_ELE,      talent = 114050,
        cdMods  = { [462440] = -60 },          -- Ascendance CDR talent: -60s
        durMods = { [462443] =   3 } },        -- Ascendance duration extender: +3s
    { spellId = 384352, cd = 60,  dur = 8,   affects = "self",   class = "SHAMAN",      cat = "OFF", label = "Doom Winds",                       spec = SPEC.SHAM_ENH,      talent = 384352,
        durMods = { [384444] = 2 } },          -- Doom Winds duration extender: +2s

    -- ── Warlock ─────────────────────────────────────────
    { spellId = 104773, cd = 180, dur = 8,   affects = "self",   class = "WARLOCK",     cat = "DEF", label = "Unending Resolve",
        cdMods = { [386659] = -45 } },         -- Strength of Will (or Unending Resolve CDR): -45s
    -- Dark Pact (108416) intentionally NOT tracked: the buff Blizzard
    -- delivers via UNIT_AURA carries no IMPORTANT/BIG/EXTERNAL flag,
    -- so our flag-fingerprint classification can't pin it down for
    -- party-member casters in 12.0.5 where the cast event is silent.

    -- ── Warrior ─────────────────────────────────────────
    { spellId = 118038, cd = 120, dur = 8,   affects = "self",   class = "WARRIOR",     cat = "DEF", label = "Die by the Sword",                 spec = SPEC.WAR_ARMS,
        cdPctMods = { [391271] = -10 } },      -- Honed Reflexes (or shared Warrior CDR passive): -10%
    { spellId = 107574, cd = 90,  dur = 20,  affects = "self",   class = "WARRIOR",     cat = "OFF", label = "Avatar" },
    { spellId = 184364, cd = 120, dur = 8,   affects = "self",   class = "WARRIOR",     cat = "DEF", label = "Enraged Regeneration",             spec = SPEC.WAR_FURY,      talent = 184364,
        -- Honed Reflexes (391271) is NOT applied here: it only reduces Die by
        -- the Sword and Spell Reflection, not Enraged Regeneration.
        durMods = { [383468] = 3 } },          -- Invigorating Fury: +3s duration extender
    { spellId = 871,    cd = 180, dur = 8,   affects = "self",   class = "WARRIOR",     cat = "DEF", label = "Shield Wall",                      spec = SPEC.WAR_PROT,
        cdMods = { [397103] = -60 },           -- Shield Wall CDR talent: -60s
        -- Honed Reflexes (391271) is NOT applied here: it only reduces Die by
        -- the Sword and Spell Reflection, not Shield Wall.
        talentChargeBonus = { [397103] = 1 } },  -- Same talent grants +1 charge (total 2)
    -- Spell Reflection: class-wide talent (all 3 Warrior specs share the
    -- same talent ID 23920). The spell ID and talent ID are identical
    -- here — the talent IS the ability rather than enabling it from a
    -- baseline spec gate. Important flag matches the runtime aura
    -- pattern (yellow-ish "I'm reflecting!" indicator without a full
    -- defensive bar). Honed Reflexes class CDR applies.
    { spellId = 23920,  cd = 25,  dur = 5,   affects = "self",   class = "WARRIOR",     cat = "DEF", label = "Spell Reflection",                 talent = 23920,
        important = true,
        cdSpecMods = { [SPEC.WAR_PROT] = -5 },  -- Protection baseline: 20s vs 25s for Arms/Fury
        cdPctMods  = { [391271] = -10 },       -- Honed Reflexes class CDR passive: -10%
        disabled = true },                     -- not reliably trackable

    -- Racials — entries without a `class` field are race-gated instead.
    -- `race` matches the second return of UnitRace(unit) (the English
    -- race file string, e.g. "NightElf"). `noGlow = true` suppresses
    -- the buff-active highlight phase entirely; the icon transitions
    -- straight into the dimmed cooldown swipe — appropriate for spells
    -- like Shadowmeld where the "buff active" state isn't useful to
    -- show on the bar (we just care about the CD timer).
    --
    -- Both racials currently TEMPORARILY DISABLED (`disabled = true`)
    -- pending a reliable detection path. They stay in SPELL_DEFS so
    -- the Spell Filter panel surfaces them as "Currently not trackable"
    -- rows; SpellsForMember / OnUnitCast / MatchAuraByClassification
    -- skip them so no icon gets created and no false-positive glow
    -- attribution lands on adjacent class spells.
    { spellId = 58984,  cd = 120, dur = 7200, affects = "self",  race  = "NightElf",    cat = "DEF", label = "Shadowmeld",                       noGlow = true,
        disabled = true },                       -- temporarily disabled
    { spellId = 20594,  cd = 120, dur = 8,    affects = "self",  race  = "Dwarf",       cat = "DEF", label = "Stoneform",
        disabled = true },                       -- temporarily disabled
}

-- ── Offensive cooldowns: tracking centrally disabled ─────────────────
-- Recent patches stopped exposing what offensive tracking relied on.
-- Offensive auras (Avatar, Combustion, Trueshot, …) carry NO Blizzard
-- category flag — unlike defensives, which the game tags BIG_DEFENSIVE /
-- EXTERNAL_DEFENSIVE. For a party member in an instance the spellID and
-- the cast event are both secret, so an unflagged offensive aura has no
-- non-secret signal left to pin it back to its def; attribution would be
-- guesswork and could throw false glows onto neighbouring class spells.
-- We therefore track defensives only. The defs (with their talent / CDR /
-- charge logic) stay in the table for easy revival: set `disabled = false`
-- on a single def to re-enable just that one, or delete this loop to
-- restore offensive tracking wholesale if the data is ever re-exposed.
for _, def in ipairs(SPELL_DEFS) do
    if def.cat == "OFF" and def.disabled == nil then
        def.disabled = true
    end
end

-- Build the aura→spell lookup. Most defensives apply a buff whose ID
-- matches the cast spell ID, so the lookup key is just `def.spellId`
-- for those. Some abilities (e.g. Havoc Metamorphosis: cast 191427 →
-- player aura 162264) apply a DIFFERENT aura than their cast ID; for
-- those entries we read `def.auraId` instead. The spellId stays in
-- place for icon texture / display purposes — the override only
-- affects which key the detection layer uses to recognise the buff.
local _spellByAuraId = {}
for _, def in ipairs(SPELL_DEFS) do
    _spellByAuraId[def.auraId or def.spellId] = def
end

-- String-keyed mirror of _spellByAuraId. Why we need this in 12.0.5:
-- the "secret value" taint propagates through tostring AND tonumber
-- (verified via diagnostic verbose: a freshly tonumber'd value still
-- throws on table-index, and our slider-trick laundry can't always
-- recover it either). The result: pure-number indexing fails for
-- every party-member aura in M+ content.
--
-- Observed behaviour gap: string.format with %s accepts the tainted
-- string fine (our verbose logs print "47585" cleanly), and the
-- tainted string's hash equals a clean "47585" interned string in
-- the runtime — so a string-keyed table read MAY succeed where a
-- number-keyed read throws. We pre-build this mirror at init and
-- consult it as a fallback after the number paths fail.
--
-- Cost: ~80 extra table entries at load. Worth it.
local _spellByAuraIdStr = {}
for _, def in ipairs(SPELL_DEFS) do
    _spellByAuraIdStr[tostring(def.auraId or def.spellId)] = def
end

-- Localized-name index. Built from C_Spell.GetSpellName which reads
-- from the spell database (server-side state), so the returned name
-- on lookup may be clean even when the aura.spellId we received is
-- secret-tagged. Diagnostic logs from 12.0.5 M+ encounters show that
-- tainted strings do NOT hash-match clean strings of identical
-- content (string interning treats them as different identities),
-- defeating both the number-keyed and string-mirror lookups. Name
-- comes through a different code path and may dodge the taint mark.
local _spellByName = {}
for _, def in ipairs(SPELL_DEFS) do
    local okN, name = pcall(C_Spell.GetSpellName, def.spellId)
    if okN and name and type(name) == "string" and name ~= "" then
        _spellByName[name] = def
    end
    -- Also index the aura name when it differs from the cast name
    -- (rare, but Fortifying Brew's aura is "Fortifying Brew" — same
    -- name; Havoc Meta cast vs aura both "Metamorphosis"; etc.)
    if def.auraId and def.auraId ~= def.spellId then
        local okA, aname = pcall(C_Spell.GetSpellName, def.auraId)
        if okA and aname and type(aname) == "string" and aname ~= ""
           and not _spellByName[aname] then
            _spellByName[aname] = def
        end
    end
end

-- COMBAT_LOG_EVENT_UNFILTERED SPELL_CAST_SUCCESS uses the CAST spell ID
-- (not the aura ID), so this index always keys by def.spellId — even for
-- entries where auraId differs (e.g. Havoc Metamorphosis cast 191427).
--
-- Some spells fire UNIT_SPELLCAST_SUCCEEDED with different cast IDs
-- depending on spec/context but resolve to the same buff and CD —
-- Alter Time is the canonical example (Arcane casts via one ID,
-- Frost/Fire via another, both produce the 342246 buff). For those
-- entries we use `extraCastIds = { ... }` to list the alternate cast
-- IDs alongside the primary `spellId`, and index all of them here so
-- a UNIT_SPELLCAST_SUCCEEDED with any listed ID resolves to the same
-- def (and shares the same CD bookkeeping).
local _spellByCastId = {}
local _spellByCastIdStr = {}  -- string-keyed mirror, same rationale as _spellByAuraIdStr
for _, def in ipairs(SPELL_DEFS) do
    _spellByCastId[def.spellId] = def
    _spellByCastIdStr[tostring(def.spellId)] = def
    if def.extraCastIds then
        for _, extra in ipairs(def.extraCastIds) do
            _spellByCastId[extra] = def
            _spellByCastIdStr[tostring(extra)] = def
        end
    end
end

-- Texture → def fallback index. In 12.0.5 the aura.spellId field
-- arrives as a "secret value" (tainted) for party-member auras in
-- M+ content, which breaks BOTH direct DB lookup AND the slider-
-- trick taint resolver in many cases. But aura.icon (the texture
-- file ID) tends to stay clean far more often. Texture IDs are
-- stable game-data — same number across all clients — so we can
-- precompute a texture→def map at init and use it as a fallback
-- match path.
--
-- We use the CAST spellId (def.spellId) for the texture lookup
-- because that's what C_Spell.GetSpellTexture is keyed on. For
-- entries where the aura ID differs (def.auraId), Blizzard's
-- texture for the cast and the aura are usually identical.
-- If the aura.icon field itself comes through tainted (rare but
-- possible) we treat it as "no match" rather than risking a wrong
-- attribution.
local _spellByTexture = {}
-- String-keyed mirror of _spellByTexture for the same taint-resilience
-- reason as _spellByAuraIdStr. The aura.icon field comes through
-- tainted in M+ contexts and number-keyed reads throw; string-keyed
-- reads (via tostring → table index with the string) survive.
local _spellByTextureStr = {}
do
    local seen = {}  -- avoid double-keying when two defs share a texture
    -- Helper: try to add a texture for this spellId to BOTH indexes.
    -- "First def wins" if two spells happen to share a texture file ID.
    local function addTex(def, sid)
        if not sid then return end
        local ok, tex = pcall(C_Spell.GetSpellTexture, sid)
        if ok and tex and tex ~= 0 and not seen[tex] then
            _spellByTexture[tex] = def
            _spellByTextureStr[tostring(tex)] = def
            seen[tex] = true
        end
    end
    for _, def in ipairs(SPELL_DEFS) do
        -- Cast texture (button icon the player presses).
        addTex(def, def.spellId)
        -- Aura texture — for spells whose buff arrives with a
        -- different visual than the cast button (Fortifying Brew
        -- cast=115203 button → aura=120954 buff icon, which is a
        -- different texture file). Adding both forms doubles our
        -- texture-fallback coverage for these spec-specific buffs.
        if def.auraId and def.auraId ~= def.spellId then
            addTex(def, def.auraId)
        end
    end
end

-- Pre-compute the Blizzard category-flag tuple per def. Used by the
-- classification fallback to narrow candidates to those whose
-- Blizzard-side flags exactly match the aura's classification.
-- The three flags map to:
--   B = C_UnitAuras.AuraIsBigDefensive(spellId)
--   E = C_Spell.IsExternalDefensive(spellId)
--   I = C_Spell.IsSpellImportant(spellId)
-- We store a 3-char key like "BE-" / "--I" / "BEI" so the match is
-- a simple string equality. Spells with no flags get "---" which
-- won't match any classified aura (only direct spellId/texture
-- paths can find them).
for _, def in ipairs(SPELL_DEFS) do
    -- Probe BOTH the cast spellId AND the aura spellId (when they
    -- differ). The classification fallback compares this 3-char key
    -- against the aura instance's runtime classification via
    -- IsAuraFilteredOutByInstanceID, which probes the actual buff
    -- aura — so if Blizzard only flagged one side (cast OR aura)
    -- we want the flag to count. Brew is the canonical example:
    -- cast=115203 vs buff=120954 may have different Blizzard flag
    -- metadata depending on how the spell is registered server-side.
    local function probe(spellId)
        if not spellId then return false, false, false end
        local okB, isBig = pcall(C_UnitAuras.AuraIsBigDefensive, spellId)
        local okE, isExt = pcall(C_Spell.IsExternalDefensive,    spellId)
        local okI, isImp = pcall(C_Spell.IsSpellImportant,        spellId)
        return (okB and isBig) or false,
               (okE and isExt) or false,
               (okI and isImp) or false
    end
    local bCast, eCast, iCast = probe(def.spellId)
    local bAura, eAura, iAura = false, false, false
    if def.auraId and def.auraId ~= def.spellId then
        bAura, eAura, iAura = probe(def.auraId)
    end
    -- 4th char: RAID classification. Blizzard doesn't expose a spell-
    -- level API equivalent to AuraIsBigDefensive for the RAID filter,
    -- so we rely on a hardcoded `raid = true` field on the def for
    -- spells where the RAID bit is needed to disambiguate from other
    -- spells with the same B/E/I pattern. Currently only Blessing of
    -- Freedom needs this — it shares "--I" with Voidform, Avatar,
    -- Metamorphosis (Veng) etc., and only the RAID bit distinguishes
    -- it cleanly at runtime via IsAuraFilteredOutByInstanceID.
    -- Manual flag overrides. The Blizzard spell-DB API calls above
    -- (AuraIsBigDefensive / IsExternalDefensive / IsSpellImportant)
    -- aren't always populated for every defensive — some entries
    -- whose buffs carry the IMPORTANT / BIG / EXTERNAL flag at
    -- RUNTIME (probed via IsAuraFilteredOutByInstanceID on the
    -- live aura instance) return false from the SPELL-level query.
    -- When that happens the def's flag key disagrees with the
    -- runtime aura's flag key and the classification path can't
    -- pin the aura to this def. Adding `big`/`external`/`important`
    -- = true on the def forces the bit on so the flag key matches
    -- what the buff actually carries in-game.
    --
    -- Negative overrides (`notBig`/`notExternal`/`notImportant` = true)
    -- force a bit OFF regardless of what the API probe returned. Needed
    -- for the reverse case: the spell-DB query says a flag is set but
    -- the live aura instance doesn't carry it at runtime. Fiery Brand
    -- is the canonical example — IsSpellImportant returns true for the
    -- cast/aura IDs but the live buff is "B---" not "B-I-".
    --
    -- `flagKey` (string) is the full explicit override — if set, we
    -- use it verbatim and skip the probe-based computation entirely.
    -- Use this for spells where neither additive nor negative bit
    -- overrides express the desired pattern cleanly.
    if def.flagKey then
        def._auraFlagKey = def.flagKey
    else
        local bBit = (bCast or bAura or def.big)      and not def.notBig       and "B" or "-"
        local eBit = (eCast or eAura or def.external) and not def.notExternal  and "E" or "-"
        local iBit = (iCast or iAura or def.important)and not def.notImportant and "I" or "-"
        local rBit = def.raid and "R" or "-"
        def._auraFlagKey = bBit .. eBit .. iBit .. rBit
    end
end

-- (Name fallback removed — aura.name comes through as a secret
-- string value in M+ which throws even on comparison.)

-- Dynamically-learned aura-icon → def mappings. We populate this
-- whenever SafeAuraLookup succeeds via the (clean) spellId fast
-- path: record the aura's actual icon value alongside the matching
-- def. The next time the same aura appears with a tainted spellId
-- (typical M+ scenario), the texture fallback finds it via this
-- learned mapping.
--
-- Why this is needed: many spells have a CAST button texture that
-- differs from the BUFF aura texture (Pain Suppression's cast
-- texture is 135936 but the applied buff arrives with icon 135959,
-- for example). C_Spell.GetSpellTexture returns the cast texture,
-- so the init-time _spellByTexture index above misses these auras.
-- Learning at observation time + persisting across /reload gives
-- us the right texture without manual hardcoding per spell.
local function _learnAuraTexture(def, aura)
    if not def or not aura then return end
    local okT, tex = pcall(function() return aura.icon end)
    if not okT or not tex or tex == 0 then return end

    -- Check "already known" via the string mirror first because the
    -- number-keyed read might throw on a tainted tex value. The
    -- string mirror's read survives — see _spellByTextureStr header
    -- comment for the taint-propagation reasoning.
    local okS, tStr = pcall(tostring, tex)
    if okS and tStr and _spellByTextureStr[tStr] then return end
    -- Number-keyed already-known check (safe when tex is clean,
    -- pcall'd so a tainted tex doesn't crash the whole lookup).
    local okN, known = pcall(function() return _spellByTexture[tex] end)
    if okN and known then return end

    -- Add to both indexes. The string add is always safe; the number
    -- add is pcall'd in case tex is tainted (table-create with
    -- tainted number key throws in 12.0.5).
    if okS and tStr then
        _spellByTextureStr[tStr] = def
    end
    pcall(function() _spellByTexture[tex] = def end)

    -- Persist to disk so a /reload-into-M+ has the mapping ready
    -- before any group member casts a defensive again. Cache key is
    -- the texture file ID, value is the cast spellId (so a fresh
    -- module init can re-resolve def from SPELL_DEFS). Skip the SV
    -- write if tex is tainted — we can't safely use it as a number
    -- key on the SV table.
    pcall(function()
        local sv = BliZziInterruptsSavedVars
        if not sv then return end
        sv.partyCDLearnedTextures = sv.partyCDLearnedTextures or {}
        sv.partyCDLearnedTextures[tex] = def.spellId
    end)
end

-- Restore learned texture cache from disk. Called on PCD:Enable so
-- the very first M+ aura event after a /reload can match via the
-- texture-fallback path instead of waiting for a clean-spellId fast
-- hit to re-learn it.
local function _loadLearnedTextures()
    local sv = BliZziInterruptsSavedVars
    if not sv or not sv.partyCDLearnedTextures then return end
    for tex, sid in pairs(sv.partyCDLearnedTextures) do
        if not _spellByTexture[tex] then
            for _, def in ipairs(SPELL_DEFS) do
                if def.spellId == sid then
                    _spellByTexture[tex] = def
                    -- Mirror into the string-keyed table so the
                    -- taint-resilient lookup path can find it too.
                    _spellByTextureStr[tostring(tex)] = def
                    break
                end
            end
        end
    end
end

-- Per-class spell list — when we render icons for a party member we
-- only want to consider the spells that member's class can actually cast.
-- Racial entries (def.class == nil) are skipped here and indexed below
-- in _spellsByRace instead. SpellsForMember walks both lists per member.
local _spellsByClass = {}
local _spellsByRace  = {}
for _, def in ipairs(SPELL_DEFS) do
    if def.class then
        _spellsByClass[def.class] = _spellsByClass[def.class] or {}
        table.insert(_spellsByClass[def.class], def)
    end
    if def.race then
        _spellsByRace[def.race] = _spellsByRace[def.race] or {}
        table.insert(_spellsByRace[def.race], def)
    end
end

------------------------------------------------------------
-- State
--
-- _cdEnd[playerName][spellId] = GetTime() when the CD expires.
-- _icons[playerName][spellId] = the icon frame (parented to the unit
--                               frame currently displaying that player)
-- _attachedTo[playerName]     = the unit frame the icon row is anchored
--                               to right now, so RebuildAnchors knows
--                               whether to re-parent on roster changes.
------------------------------------------------------------
local _cdEnd      = {}
local _icons      = {}
local _attachedTo = {}

-- Per-(caster, spell) timestamp of the most recent OnAuraAppeared
-- commit. Used to dedup the near-simultaneous fires that happen for
-- the same cast (UNIT_SPELLCAST_SUCCEEDED → cast-event path, plus the
-- UNIT_AURA deferred ScanUnitAuras path) — both call OnAuraAppeared
-- within ~70ms of each other. Without dedup, multi-charge spells get
-- their queue pushed twice for a single cast and the charge count
-- jumps too fast. The window (0.4s) is short enough that a genuine
-- rapid double-cast (player presses Blur twice) still counts as two —
-- even off-GCD abilities rarely land two separate uses within 0.4s —
-- while wide enough to absorb event-delivery jitter under combat load
-- (the original 0.15s proved too tight: cast event and deferred aura
-- scan can arrive further apart in a busy M+ pull, double-committing).
local _lastCommitAt = {}

-- Last committed aura INSTANCE per (name, spellId). A re-detection of
-- the very same aura instance (full-update rescan on roster events,
-- duration extension by a talent, glow refresh) must never count as a
-- new use — without this guard each re-detection outside the timing
-- dedup pushed another phantom entry into the charge queue, and since
-- every push extends the queue tail by +cd, a frequently-used
-- multi-charge spell (live report: Evoker Obsidian Scales) snowballed
-- to "0 charges, 800s+ until next charge".
local _lastCommitInst = {}

-- Per-player spec ID, populated asynchronously by the LibSpecialization
-- callback below. Key is the player's short name (no realm); we look up
-- by the short half of FullName so cross-realm groups with same short
-- names still mostly work (typical 5-man parties don't collide).
local _specByName    = {}
-- Per-player parsed talent → spellID map (LibSpec's talent string,
-- decoded once via BIT.ParseTalentString). Used to gate talent-only
-- spells (e.g. Restoration Ascendance) so a player who didn't pick
-- the talent doesn't get the icon shown.
local _talentsByName = {}

-- Glow expirations: _glowEnd[fullName][spellId] = GetTime() at which
-- the active buff is expected to expire and we should hide the
-- LibButtonGlow overlay. Driven by Tick().
local _glowEnd    = {}

-- Last "harmful aura added in the same UNIT_AURA event" timestamp
-- per unit. Used to disambiguate Pala spell pairs that share
-- Blizzard flags ([B-I] or [BE-]) but where one applies the
-- Forbearance debuff and the other doesn't:
--    Divine Shield (642)        ← adds Forbearance
--    Divine Protection (498)    ← does not
--    Blessing of Protection     ← adds Forbearance
--    Blessing of Sacrifice      ← does not
--    Blessing of Spellwarding   ← adds Forbearance
-- Forbearance is a harmful aura applied alongside the buff every
-- time these spells are cast, so detecting "any harmful aura was
-- added together with the buff" is a reliable signal regardless
-- of whether the recipient previously had debuffs to clear.
local _lastHarmfulAdded = {}  -- _lastHarmfulAdded[unit] = GetTime()

-- Per-unit side-channel evidence for the Hunter Survival of the Fittest
-- (264735) vs Aspect of the Turtle (186265) flag-twin. Both surface as
-- the same BIG_DEFENSIVE flag-key with overlapping ~8s durations (SotF
-- reaches 8s with Lone Survivor), and the runtime aura spellId is secret
-- for party members — so the flag-key / duration / CD narrowers can all
-- pick the wrong twin. Two NON-secret signals separate them cleanly:
--   _immuneFlagsAt[unit]  GetTime() of the unit's most recent UNIT_FLAGS
--                         change. Aspect of the Turtle grants immunity →
--                         casting it flips the flag set; SotF never does.
--   _feignAt[unit]        GetTime() the unit entered Feign Death. Feign
--                         also flips the flag set, so a fresh feign
--                         suppresses the immunity → Turtle inference.
--   _petBigDefAt[unit]    GetTime() the unit's PET gained a BIG_DEFENSIVE
--                         aura. SotF shields the pet; Turtle never touches
--                         it — a positive Survival-of-the-Fittest confirm.
-- Also used for the Death Knight Anti-Magic Shell (48707) vs Icebound
-- Fortitude (48792) flag-twin:
--   _absorbAt[unit]       GetTime() of the unit's most recent absorb change
--                         (UNIT_ABSORB_AMOUNT_CHANGED). Anti-Magic Shell
--                         applies an absorb shield; Icebound Fortitude never
--                         does — a positive Anti-Magic-Shell confirm.
local _immuneFlagsAt = {}
local _feignAt       = {}
local _petBigDefAt   = {}
local _absorbAt      = {}
-- Window (seconds) within which the above evidence counts as concurrent
-- with the buff aura being classified.
local TWIN_EVIDENCE_WINDOW = 0.8
-- Tighter window for the UNIT_FLAGS (immunity) channel specifically:
-- a real Turtle cast flips the flags within a frame of the aura landing,
-- and the deferred scan runs ~50-120ms later — 0.35s is plenty. The
-- wider 0.8s window let unrelated flag churn (busy combat) fake Turtle
-- evidence far too often.
local TWIN_FLAGS_WINDOW = 0.35

-- Per-(unit, spellId) last refresh timestamp for selfRefreshing defs.
-- Used by the spread-vs-recast disambiguator: passive self-refresh
-- talents (Burning Alive etc.) fire at deterministic 1s intervals,
-- so a refresh arriving close to the 1s grid relative to the last
-- refresh is treated as a spread (glow-only), while an off-grid
-- refresh is treated as a recast (full commit + charge decrement).
local _lastRefreshAt = {}  -- _lastRefreshAt[unit] = { [spellId] = GetTime() }

-- Recent cast events keyed by clean spellID. Populated by OnUnitCast
-- whenever a clean spell ID arrives via UNIT_SPELLCAST_SUCCEEDED.
-- The classification fallback uses this as the strongest available
-- disambiguator: if multiple defs match the Blizzard flags + group
-- composition for an aura, the def whose spellId was JUST cast
-- (within the last 2s) wins.
--
-- This is the missing link that makes ambiguous flag-twin pairs
-- (Divine Protection vs Divine Shield, BoP vs BoSac, AW vs BoF)
-- resolvable: cast IDs typically arrive clean even when the aura's
-- spellId/icon fields are tainted in M+, so the correlation works
-- where the aura-only paths fail.
--
-- Structure: _recentCasts[spellId] = { unit = "partyN", time = GetTime() }
-- Garbage-collected on access: entries older than 5s are pruned
-- before the disambiguation check uses the map.
local _recentCasts = {}

-- Poll-based detection state. Maps fullName → spellId → auraInstanceID
-- of the most recently observed instance of that buff on that player.
-- When we observe the same buff with a DIFFERENT auraInstanceID we
-- know it's a fresh cast and trigger OnAuraAppeared. When we observe
-- the buff with the SAME auraInstanceID we no-op (still the same buff
-- we already committed). When the buff goes away (poll returns nil)
-- we clear the entry so the next cast triggers cleanly.
--
-- Why this exists: the push-based path (read aura.spellId, look it up
-- in our DB) fails in 12.0.5 M+ because aura.spellId can arrive as a
-- secret value (tainted) for party-member auras. The taint resolver
-- works often but not always. Polling INVERTS the lookup direction:
-- we hand WoW the clean spellId (from our DB) and C_UnitAuras returns
-- a clean answer about whether that buff is active. Taint cannot
-- propagate this way because we never read the dirty spellId.
local _lastInst = {}

-- NEGATIVE result cache: aura instances that already went through the
-- full SafeAuraLookup pipeline and did NOT match any def. Instance IDs
-- are stable for the lifetime of an aura application, so once an
-- instance missed, re-probing it on every subsequent UNIT_AURA event
-- is pure waste — and it was the addon's single biggest CPU sink
-- (live profile: 192,955 probes, 187,860 of them repeat-misses on the
-- same food/flask/HoT/proc instances; ~18s of scan+classify over one
-- dungeon run). Entries are pruned when the aura instance is removed
-- and the per-player set is size-capped as a leak backstop.
--   [fullName] = { [instId] = true, _n = count }
local _rejectedInst = {}
local REJECTED_CAP = 400   -- per player; wipe-and-restart beyond this

-- Tracked party slots. "player" always tracks self; party1..4 track
-- group members. We register UNIT_AURA on exactly these slots so the
-- handler is never invoked for raid / nameplate / target / focus.
local PARTY_UNITS = { "player", "party1", "party2", "party3", "party4" }

-- Set form of PARTY_UNITS for O(1) membership tests. The cast handler
-- below uses RegisterEvent("UNIT_SPELLCAST_SUCCEEDED") (broad, fires
-- for every unit token in the game) rather than RegisterUnitEvent
-- (per-unit filtered, unreliable for party slots in 12.0.5), so we
-- need a fast filter to ignore casts from non-party units.
local _isPartyUnit = {}
for _, u in ipairs(PARTY_UNITS) do _isPartyUnit[u] = true end

local _enabled    = false
local _auraFrame              -- UNIT_AURA observer
local _rosterFrame            -- GROUP_ROSTER_UPDATE / EDIT_MODE_LAYOUTS_UPDATED
local _tickFrame              -- OnUpdate driver

-- Lightweight per-function profiling. Each entry tracks:
--   calls : how many times the function was entered
--   total : cumulative milliseconds spent inside
--   max   : worst single-call time, useful for finding spike causes
--
-- Wired into the 5 hot-path functions via paired `debugprofilestop()`
-- captures at entry + each return point. Overhead per call is on the
-- order of ~0.5µs (one subtraction + one addition + one compare),
-- vastly smaller than the functions being measured.
--
-- Dump via `/bitpcd prof`. Reset via `/bitpcd resetstats` (resets
-- _stats too).
local _prof = {
    scan        = { calls = 0, total = 0, max = 0 },  -- ScanUnitAuras
    classify    = { calls = 0, total = 0, max = 0 },  -- MatchAuraByClassification
    onAura      = { calls = 0, total = 0, max = 0 },  -- OnUnitAura event handler
    onAppear    = { calls = 0, total = 0, max = 0 },  -- PCD:OnAuraAppeared
    tick        = { calls = 0, total = 0, max = 0 },  -- Tick OnUpdate driver
}
local function _profStop(p, t0)
    local dt = debugprofilestop() - t0
    p.total = p.total + dt
    if dt > p.max then p.max = dt end
end

-- Diagnostic counters: incremented at each stage of the aura → icon
-- pipeline. /bitpcd dump prints them so we can see exactly where the
-- flow breaks (e.g. lots of UNIT_AURA fires but zero lookups succeed
-- = taint resolver is failing on tainted spellIDs).
local _stats = {
    unitAuraFired    = 0,  -- total UNIT_AURA callbacks invoked
    fullUpdates      = 0,  -- updateInfo.isFullUpdate == true (or missing updateInfo)
    addedAurasSeen   = 0,  -- entries in updateInfo.addedAuras across all events
    lookupFastHit    = 0,  -- SafeAuraLookup resolved via direct pcall
    lookupTaintHit   = 0,  -- SafeAuraLookup resolved via BIT.Taint:ResolveNumber
    lookupTextureHit = 0,  -- SafeAuraLookup resolved via aura.icon → _spellByTexture
    lookupClassifyHit= 0,  -- SafeAuraLookup resolved via Blizzard category filter + duration
    lookupStringHit  = 0,  -- SafeAuraLookup resolved via string-keyed mirror OR loop-equality (12.0.5 taint workaround)
    lookupByteHit    = 0,  -- SafeAuraLookup resolved via byte-scrubber (12.0.5 hardest taint workaround)
    lookupNameHit    = 0,  -- SafeAuraLookup resolved via C_Spell.GetSpellName (12.0.5 taint workaround)
    lookupRefetchHit = 0,  -- SafeAuraLookup resolved via GetAuraDataByAuraInstanceID refetch (12.0.5 taint workaround)
    lookupLastResortHit = 0, -- SafeAuraLookup resolved via class+spec exclusivity heuristic (taint-saturated M+)
    attributionReassigns        = 0,  -- post-hoc cooldown reassignments after observed-lifetime verification
    lookupMiss       = 0,  -- SafeAuraLookup returned nil (untracked spell OR unresolvable taint)
    onAuraAppeared   = 0,  -- OnAuraAppeared actually invoked with a matched def
    casterFallback   = 0,  -- target-cast spells where sourceUnit was unreadable and we used a class-search fallback
    castersDropped   = 0,  -- OnAuraAppeared bailed because casterUnit didn't validate
    cdsCommitted     = 0,  -- successful state writes (one per detection that made it to _cdEnd)
    playerCastSeen   = 0,  -- UNIT_SPELLCAST_SUCCEEDED events received for "player"
    playerCastMatched= 0,  -- of those, how many matched a tracked spell ID
    allCastsSeen     = 0,  -- UNIT_SPELLCAST_SUCCEEDED across ALL units (broad event fires for everything)
    partyCastsSeen   = 0,  -- of those, how many were from a party-slot unit (player + party1..4)
    pollRuns         = 0,  -- ScanUnitAuras invocations (= UNIT_AURA fires after filter)
    pollHits         = 0,  -- of those, how many committed a fresh CD (new auraInstanceID)
    pollProbes       = 0,  -- per-aura SafeAuraLookup attempts inside scan
    pollSkipsRejected = 0, -- probes avoided by the negative instance cache
    procSkips        = 0,  -- short-duration talent procs blocked from committing (minDur guard)
    pollProbeFound   = 0,  -- of those, how many resolved to a tracked def
    pollProbeErrors  = 0,  -- C_UnitAuras.GetUnitAuras pcall failures
    pollDeferred     = 0,  -- deferred re-scan invocations (party-member fast-buff race fallback)
    refreshGlowOnly  = 0,  -- selfRefreshing defs: how often a glow-only refresh path triggered (no charge decrement)
    refreshFullCommit= 0,  -- selfRefreshing defs not picked: how often the normal recast path triggered via updatedAuraInstanceIDs
}

------------------------------------------------------------
-- Context visibility — the user can independently enable/disable the
-- party-CD bar inside dungeons, raids, arenas, battlegrounds, and the
-- open world. We don't tear down or unregister anything on context
-- change; we just toggle icon Show/Hide so re-entering an enabled
-- context restores everything instantly without losing CD timers.
--
-- 12.x note: both IsInInstance() and GetInstanceInfo() can return
-- secret-value-tainted booleans/strings on some clients during
-- transitions. We wrap each call in pcall and treat any failure as
-- "open world" — better to err on the side of showing icons than to
-- crash on a bad return.
------------------------------------------------------------
local function GetInstanceContextKey()
    local okI, isInst, instType = pcall(IsInInstance)
    if okI and isInst then
        if instType == "party" then return "dungeon" end
        if instType == "raid"  then return "raid"    end
        if instType == "arena" then return "arena"   end
        if instType == "pvp"   then return "bg"      end
    end
    return "openworld"
end

-- Layout-test mode bypass — `/bitpcd test` flips this on so the
-- visibility gate doesn't hide the fake icons we're applying for
-- positioning. Cleared by `/bitpcd clear`.
local _testMode = false

local function ShouldBeVisibleHere()
    if _testMode then return true end
    if not BIT.db then return true end
    local ctx = GetInstanceContextKey()
    -- Defaults mirror Core/Data.lua: dungeon/openworld/arena default
    -- ON (~= false), raid/bg default OFF (== true).
    if ctx == "dungeon"   then return BIT.db.partyCooldownsShowInDungeon   ~= false end
    if ctx == "raid"      then return BIT.db.partyCooldownsShowInRaid      == true  end
    if ctx == "openworld" then return BIT.db.partyCooldownsShowInOpenWorld ~= false end
    if ctx == "arena"     then return BIT.db.partyCooldownsShowInArena     ~= false end
    if ctx == "bg"        then return BIT.db.partyCooldownsShowInBG        == true  end
    return true
end

------------------------------------------------------------
-- Helpers
------------------------------------------------------------

-- Pull a stable per-player identifier. We use Name-Realm because in a
-- cross-realm party two members named "Joe" must not collide. For same-
-- realm parties the realm half is the local player's realm via the
-- usual GetUnitName convention.
local function FullName(unit)
    if not unit or not UnitExists(unit) then return nil end
    local name, realm = UnitName(unit)
    if not name then return nil end
    -- In 12.0.5 the realm string returned for party-member queries
    -- in M+ can come through as a secret value — a direct `realm ==
    -- ""` compare on a tainted string throws ("attempt to compare a
    -- secret string value, while execution tainted by..."). We
    -- pcall the empty-check so the function falls back to the local
    -- realm name gracefully instead of erroring out and being
    -- treated as "FullName returned nil" by the caller.
    local realmIsEmpty = true
    if realm then
        local ok, isEmpty = pcall(function() return realm == "" end)
        if ok then realmIsEmpty = isEmpty end
        -- pcall failed → realm is tainted; treat it as "needs replacement"
    end
    if realmIsEmpty then realm = GetRealmName() end
    -- The concatenation below also runs through pcall — a tainted
    -- realm string would propagate taint into the resulting name.
    local okJ, joined = pcall(function() return name .. "-" .. realm end)
    if okJ and joined then return joined end
    return name  -- last-ditch: just the short name (better than nil)
end

-- Map unit → class file ("PRIEST" etc.) so we can look up _spellsByClass.
local function UnitClassFile(unit)
    if not unit or not UnitExists(unit) then return nil end
    local _, cls = UnitClass(unit)
    return cls
end

-- Cached spec/talents for the local player. Recomputed on demand
-- (the getter checks if the cached value is stale by reading
-- GetSpecialization() each time) so spec switches without a LibSpec
-- callback still update us.
--
-- The reason this exists: after a /reload INSIDE an instance (M+,
-- raid), LibSpec's group comm can be restricted and our callback
-- may not fire for the local player for some time. GetSpecialization
-- and C_ClassTalents.GetActiveConfigID are SYNCHRONOUS Blizzard
-- APIs that always return current data — perfect for a fallback.

-- Resolve a stored spec ID by full-name key. We index _specByName by
-- SHORT name (LibSpec gives us short names) so this strips the realm
-- half off the full key before lookup.
local function GetSpecForName(name)
    if not name then return nil end
    local short = name:match("^([^%-]+)") or name

    -- Self fast-path: ask Blizzard directly. Works even when LibSpec
    -- hasn't delivered our callback yet (the typical scenario after
    -- a /reload inside an instance with comm restrictions active).
    if short == UnitName("player") then
        local idx = GetSpecialization and GetSpecialization()
        if idx and GetSpecializationInfo then
            local specId = GetSpecializationInfo(idx)
            if specId and specId > 0 then return specId end
        end
    end

    return _specByName[short]
end

-- Returns the per-player talent → spellID map, or nil if LibSpec
-- hasn't fired the callback for this player yet (typically the first
-- few seconds after login / a roster change).
--
-- Self fast-path: read the active loadout serialization string
-- directly from C_Traits and parse it through the same helper we
-- use for LibSpec-delivered strings (BIT.ParseTalentString). This
-- way our own talent gates work immediately after a /reload, even
-- when LibSpec is still waiting for comm restrictions to lift.
local _selfTalentCache = nil
local _selfTalentCacheConfigID = nil
local function GetKnownTalentsForName(name)
    if not name then return nil end
    local short = name:match("^([^%-]+)") or name

    if short == UnitName("player") then
        if C_ClassTalents and C_ClassTalents.GetActiveConfigID
           and C_Traits and C_Traits.GetLoadoutSerializationString
           and BIT.ParseTalentString then
            local ok, configID = pcall(C_ClassTalents.GetActiveConfigID)
            if ok and configID then
                -- Recompute on loadout switch (different configID) so
                -- a talent change in combat takes effect for self
                -- without waiting for a LibSpec callback.
                if configID ~= _selfTalentCacheConfigID then
                    _selfTalentCacheConfigID = configID
                    local okS, talentStr = pcall(C_Traits.GetLoadoutSerializationString, configID)
                    if okS and talentStr and talentStr ~= "" then
                        local idx = GetSpecialization and GetSpecialization()
                        local specId = idx and GetSpecializationInfo and GetSpecializationInfo(idx)
                        if specId then
                            _selfTalentCache = BIT.ParseTalentString(specId, talentStr)
                        end
                    end
                end
                if _selfTalentCache then return _selfTalentCache end
            end
        end
    end

    return _talentsByName[short]
end

-- Compute the effective CD for a spell on a specific caster, applying
-- any talent-driven CD reductions/increases from `def.cdMods` and
-- `def.cdPctMods`.
--
-- `cdMods = { [talentSpellID] = delta, ... }` — absolute seconds delta.
-- For every entry whose talent is present in the caster's loadout, we
-- add the delta (signed: negative for reductions, positive for the rare
-- case of CD increases). Applied FIRST, before any percentage scaling.
--
-- `cdPctMods = { [talentSpellID] = pct, ... }` — percentage delta, in
-- whole percent units (e.g. -10 = reduce CD by 10%). Useful for class-
-- wide passives like Evoker's "Interwoven Threads" that scale every
-- spell's CD by a flat percentage. Applied AFTER absolute cdMods so
-- the percentage operates on the already-reduced CD (matches Blizzard's
-- own multiplicative-after-additive stacking convention).
--
-- Unknown loadout (M+ with addon comm blocked, no cache): be OPTIMISTIC
-- and assume the caster took the cooldown-REDUCTION talents (the ~99%
-- case), so the displayed CD matches the talented spell instead of the
-- longer base CD. Only reductions are assumed — a rare CD-INCREASE
-- talent is never presumed. Trade-off vs. the duration path: there is
-- no reliable party-member "spell ready" event in M+, so an
-- over-reduction can't be trimmed afterwards; the exposure is that an
-- untalented caster's icon may read ready a little early. A floor of 1s
-- prevents an over-reduction edge case from writing a zero/negative CD.
local function GetEffectiveCD(def, casterName)
    local cd = def.cd
    -- Spec-level base CD modifier. For spells whose baseline CD differs
    -- per spec at the game-design level (not via a talent), `cdSpecMods`
    -- holds spec-keyed deltas. Applied BEFORE talent-driven cdMods so
    -- the spec baseline is the reference for subsequent additive /
    -- percentage adjustments.
    --
    -- Example: Spell Reflection has Cooldown=25s baseline for Arms/Fury
    -- but 20s for Protection. The Prot reduction isn't from a talent —
    -- it's part of the spec's class design — so it lives here keyed
    -- by the spec ID rather than in cdMods.
    if casterName and def.cdSpecMods then
        local spec = GetSpecForName(casterName)
        if spec and def.cdSpecMods[spec] then
            cd = cd + def.cdSpecMods[spec]
        end
    end
    if casterName and (def.cdMods or def.cdPctMods) then
        local talents = GetKnownTalentsForName(casterName)
        local knownLoadout = (talents ~= nil)
        local spec  -- resolved on demand for spec-dependent (table) deltas
        if def.cdMods then
            for talentID, delta in pairs(def.cdMods) do
                -- Known loadout → honor the actual pick. Unknown loadout
                -- → assume it's picked (the reduction filter below keeps
                -- us from ever assuming a CD-increase talent).
                local use = (not knownLoadout) or (talents[talentID] ~= nil)
                if use then
                    -- A delta may be spec-dependent: a table of
                    -- { default = x, [specID] = y } for talents whose
                    -- effect differs per spec (e.g. Sacrifice of the
                    -- Just reduces BoSac far less for Holy than for
                    -- Prot/Ret). Plain numbers stay the common case.
                    if type(delta) == "table" then
                        if spec == nil then spec = GetSpecForName(casterName) or false end
                        delta = (spec and delta[spec]) or delta.default or 0
                    end
                    -- Unknown loadout only assumes reductions (delta < 0).
                    if knownLoadout or delta < 0 then
                        cd = cd + delta
                    end
                end
            end
        end
        if def.cdPctMods then
            -- Sum percentages first, then apply once — keeps multiple
            -- pct talents on the same spell linearly additive (e.g.
            -- two -10% talents = -20%, not (1 - 0.1) * (1 - 0.1) = -19%).
            local pctSum = 0
            for talentID, pct in pairs(def.cdPctMods) do
                local use = (not knownLoadout) or (talents[talentID] ~= nil)
                if use and (knownLoadout or pct < 0) then
                    pctSum = pctSum + pct
                end
            end
            if pctSum ~= 0 then
                cd = cd * (1 + pctSum / 100)
            end
        end
    end
    if cd < 1 then cd = 1 end
    return cd
end

-- Mirror of GetEffectiveCD for the spell's buff duration. Talents that
-- extend a defensive's active window (e.g. Improved Barkskin: +4s, so
-- Barkskin glows 12s instead of 8s when the talent is picked) live in
-- `durMods = { [talentSpellID] = deltaSeconds, ... }`. The base duration
-- drives the glow-end timing AND the deferred-inference observed-lifetime
-- comparison, so getting it right on a per-caster basis keeps both
-- accurate. Floor at 1s so a buggy negative entry can't zero out the
-- glow window.
--
-- Unknown loadout (M+ with addon comm blocked, no cache): be OPTIMISTIC
-- and add every positive duration extension, mirroring the optimistic
-- charge logic. Under-estimating cuts the glow off while the buff is
-- still up (live report: a Guardian's talented 14s Barkskin only glowed
-- 8s, while the unit-frame overlay — which reads the real aura — still
-- showed 13s). Over-estimating is harmless here: the UNIT_AURA(removed)
-- early-cleanup hides the glow the moment the buff actually ends, so an
-- untalented caster's shorter buff still stops the glow on time.
local function GetEffectiveDuration(def, casterName)
    local d = def.dur or 0
    if casterName and def.durMods then
        local talents = GetKnownTalentsForName(casterName)
        if talents then
            for talentID, delta in pairs(def.durMods) do
                if talents[talentID] then
                    d = d + delta
                end
            end
        else
            -- Loadout unknown — assume every extension is picked (only
            -- positive deltas; the aura-removed cleanup trims any
            -- over-estimate back to the real buff length).
            for _, delta in pairs(def.durMods) do
                if delta > 0 then d = d + delta end
            end
        end
    end
    if d < 1 then d = 1 end
    return d
end

-- Mirror of GetEffectiveCD for charge counts. Defaults to 1 (single-
-- charge, which is what most spells are). Talent additions stack
-- additively, mirroring cdMods. Result is clamped to a minimum of 1
-- so a buggy negative entry can't ever produce a zero-charge spell
-- that would be silently un-trackable.
local function GetEffectiveCharges(def, casterName)
    local n = def.charges or 1
    if def.talentChargeBonus and casterName then
        local talents = GetKnownTalentsForName(casterName)
        if talents then
            -- Talents known — apply only the bonuses whose talent
            -- the caster actually picked.
            for talentID, delta in pairs(def.talentChargeBonus) do
                if talents[talentID] then
                    n = n + delta
                end
            end
        else
            -- Talents UNKNOWN (LibSpec hasn't delivered, common in
            -- M+ where Blizzard blocks the addon comm channel) —
            -- apply ALL charge-bonus deltas optimistically. The
            -- alternative (assume the talent isn't picked) hides
            -- the charge badge entirely for spells like Obsidian
            -- Scales + Obsidian Bulwark, which is the visibly worse
            -- failure mode. Once LibSpec delivers the real loadout
            -- (or the persistent cache rehydrates), the charge count
            -- corrects on the next RebuildAnchors pass. Mirror of
            -- the optimistic-when-unknown logic used by the talent
            -- gates in SpellsForMember.
            for _, delta in pairs(def.talentChargeBonus) do
                n = n + delta
            end
        end
    end
    if n < 1 then n = 1 end
    return n
end

-- Per-(caster, spell) FIFO of pending charge recharge times. Each entry
-- is the GetTime() value at which that charge will become available
-- again. Multi-charge spells in WoW recharge SERIALLY — while one
-- charge is recharging, the next one waits its full CD AFTER the
-- previous one completes. We model that by computing each new entry as
-- max(latest_entry + cd, now + cd) before insertion.
--
-- For single-charge spells (the default) this table is never touched —
-- _cdEnd carries everything those spells need.
--
-- Tick prunes expired entries lazily and transitions the icon visual
-- back to "ready" when at least one charge is available.
local _chargeQueue = {}

-- Filter a class's full spell list down to only the entries that match
-- the member's actual spec AND their selected talents. Each entry can
-- carry up to two optional gates:
--
--   `spec`   : number or { number, ... }
--              Restricts the entry to one or more specs. nil = class-wide.
--   `talent` : number
--              Requires that exact spell ID to be present in the
--              member's parsed talent loadout. Used for talent-only
--              abilities (e.g. Restoration Ascendance 114052: skill
--              point in the talent tree, not baseline).
--
-- LibSpec data behaviour:
--   * memberTalents non-nil (loadout known): strict — talent-gated
--     entries pass only when the loadout confirms the pick;
--     `replacedBy` hides the base when the replacement is picked.
--   * memberTalents nil (loadout unknown — typically a M+ party
--     member because Blizzard blocks the LibSpec addon-comm in
--     timed keystones): OPTIMISTIC — talent-gated entries are
--     included so an icon exists when the cast event fires.
--     `replacedBy` does NOT hide the base in this case, so both
--     options end up in the row but only the one actually cast
--     ever lights up. Better than hiding the active spell entirely.
local function SpellsForMember(name, class, race)
    local memberSpec    = GetSpecForName(name)
    local memberTalents = GetKnownTalentsForName(name)
    local talentsKnown  = memberTalents ~= nil
    local out = {}

    -- User-disabled filter — checked FIRST so a manually-toggled-off
    -- spell never reaches the spec/talent gates. partyCooldownsDisabled
    -- is `{ [spellId] = true }` set by the Spell Filter panel.
    local userDisabled = BIT.db and BIT.db.partyCooldownsDisabled or nil

    -- Shared filter helper — applied identically to class spells and
    -- racial spells. The spec / talent gates only matter for class
    -- entries in practice (racials are spec-agnostic), but keeping a
    -- single filter path means a future "racial gated by talent"
    -- entry would Just Work.
    local function accept(def)
        -- Def-level disable: spells we know we can't track reliably
        -- (e.g. Pala "--I-" flag-twins on party-member casts in
        -- 12.0.5). These are kept in SPELL_DEFS so the Spell Filter
        -- panel can surface them as "Currently not trackable" rows,
        -- but never get an icon rendered.
        if def.disabled then return end
        if userDisabled and userDisabled[def.spellId] then return end
        local specOk
        if def.spec == nil then
            specOk = true
        elseif memberSpec then
            if type(def.spec) == "number" then
                specOk = (def.spec == memberSpec)
            elseif type(def.spec) == "table" then
                for _, s in ipairs(def.spec) do
                    if s == memberSpec then specOk = true; break end
                end
            end
        end
        -- memberSpec nil + def.spec set → specOk stays nil (= false).
        -- Spec-gated entries are hidden until LibSpec delivers data or
        -- the persistent cache rehydrates. Being PESSIMISTIC here is
        -- the right default — being optimistic produced visible junk
        -- icons (e.g. Fiery Brand on a Havoc DH whose spec hadn't
        -- arrived yet, and the subsequent RebuildAnchors didn't
        -- always tidy them up promptly). The cost of pessimism is
        -- that on a fresh group-join the brief window before LibSpec
        -- delivers shows no spec-gated icons — once spec data lands
        -- the icons appear normally. That's a much less surprising
        -- failure mode than wrong-spec icons.
        if not specOk then return end

        -- Talent replacement gate: hide the base entry when we KNOW
        -- the caster picked the replacement talent. With talents
        -- unknown the default keeps the base visible so something
        -- glows on cast (both icons appear, only one ever fires) —
        -- EXCEPT for defs flagged `assumeReplaced`: there the
        -- replacement is the standard pick and base + replacement
        -- side by side reads as double the real charge count (live
        -- report: a no-LibSpec Frost Mage showed Ice Block 2 charges
        -- AND Ice Cold 2 charges). Those default to replacement-only
        -- until a loadout proves the base is the active version.
        if def.replacedBy then
            if talentsKnown then
                if memberTalents[def.replacedBy] then return end
            elseif def.assumeReplaced then
                return
            end
        end

        local talentOk
        if def.talent == nil then
            talentOk = true
        elseif not talentsKnown then
            -- Unknown loadout — be optimistic so the cast event has
            -- an icon to attach to. False-positive icons (talent not
            -- actually picked) sit idle and never glow.
            talentOk = true
        elseif memberTalents[def.talent] then
            talentOk = true
        end
        if talentOk then
            out[#out + 1] = def
        end
    end

    local byClass = class and _spellsByClass[class]
    if byClass then for _, def in ipairs(byClass) do accept(def) end end

    local byRace = race and _spellsByRace[race]
    if byRace then for _, def in ipairs(byRace) do accept(def) end end

    if #out == 0 then return nil end
    return out
end

-- LibButtonGlow lookup. Same pattern other features use — pcall keeps
-- us safe on builds where the library isn't bundled.
local function GetLBG()
    if not _G.LibStub then return nil end
    local ok, lib = pcall(_G.LibStub, "LibButtonGlowcustom", true)
    return ok and lib or nil
end

local function GetLCG()
    if not _G.LibStub then return nil end
    local ok, lib = pcall(_G.LibStub, "LibCustomGlow-1.0", true)
    return ok and lib or nil
end

------------------------------------------------------------
-- Glow style dispatch. Every glow in this module starts/stops
-- through these two helpers so the user's glow configuration
-- applies uniformly — including the test-mode preview icons.
--
-- partyCooldownsGlowCustom OFF (default): the classic action-
-- button proc glow via the long-proven bundled lib — untinted,
-- byte-identical behaviour to pre-4.1.6 builds.
--
-- partyCooldownsGlowCustom ON: the picked alternative style in
-- the picked color:
--   PIXEL     rotating dashed lines around the icon border.
--   AUTOCAST  circling sparkle particles (pet-autocast shine).
--   PROC      modern retail proc animation (burst + pulse loop).
--
-- StopGlow tears down EVERY style, not just the active one — the
-- user can switch styles from the settings while glows are live,
-- and a stale overlay from the previous style must never linger.
------------------------------------------------------------
local function StartGlow(icon)
    if not icon then return end
    icon._glowActive = true
    local db  = BIT.db
    local lcg = GetLCG()

    if not (db and db.partyCooldownsGlowCustom) or not lcg then
        local lbg = GetLBG()
        if lbg and lbg.ShowOverlayGlow then
            pcall(lbg.ShowOverlayGlow, icon)
        end
        return
    end

    local color = { db.partyCooldownsGlowColorR or 0.95,
                    db.partyCooldownsGlowColorG or 0.95,
                    db.partyCooldownsGlowColorB or 0.32, 1 }
    local style = db.partyCooldownsGlowStyle or "PIXEL"
    if style == "AUTOCAST" then
        -- 4 sparkle groups, slightly enlarged for small icons.
        pcall(lcg.AutoCastGlow_Start, icon, color, 4, 0.125, 1.2)
    elseif style == "PROC" then
        pcall(lcg.ProcGlow_Start, icon, { color = color, startAnim = true })
    else
        -- "PIXEL" — also the fallback for unknown values from a
        -- corrupted import: 8 lines, moderate speed, auto length,
        -- 2px thick.
        pcall(lcg.PixelGlow_Start, icon, color, 8, 0.25, nil, 2)
    end
end

local function StopGlow(icon)
    if not icon then return end
    icon._glowActive = nil
    local lbg = GetLBG()
    if lbg and lbg.HideOverlayGlow then
        pcall(lbg.HideOverlayGlow, icon)
    end
    local lcg = GetLCG()
    if lcg then
        pcall(lcg.ButtonGlow_Stop, icon)
        pcall(lcg.PixelGlow_Stop, icon)
        pcall(lcg.AutoCastGlow_Stop, icon)
        pcall(lcg.ProcGlow_Stop, icon)
    end
end

-- Exposed for the settings page: restyle any currently glowing icon
-- in place when the user changes style/color (stop with the union
-- teardown, restart with the new style).
function PCD:RestyleActiveGlows()
    for _, icons in pairs(_icons) do
        for _, icon in pairs(icons) do
            if icon._glowActive then
                StopGlow(icon)
                StartGlow(icon)
            end
        end
    end
end

-- Public glow hooks for the settings page's preview icon — it lives
-- outside the _icons registry, so RestyleActiveGlows can't reach it.
function PCD:StartGlowOn(frame) StartGlow(frame) end
function PCD:StopGlowOn(frame)  StopGlow(frame)  end

-- LibSpecialization registration. Library is loaded by the addon's
-- existing core (also used by the interrupt tracker for talent data).
-- We register PartyCooldowns as its OWN group so the callback fires
-- for ALL group members including the local player — Core.lua's
-- existing handler skips self because it uses a different talent-
-- scanning path for the interrupt tracker. We need self too because
-- the local player might be a Resto Shaman whose Ascendance pick
-- should drive our icon list.
--
-- The 5th callback argument (talentStr) is the LibSpec-encoded talent
-- export string. We decode it via BIT.ParseTalentString (exposed by
-- Core.lua) to get { [spellID] = true } for every talent the player
-- has actually selected — that map is what SpellsForMember consults
-- when deciding whether to render a talent-gated entry.
------------------------------------------------------------
-- Persistent spec/talent cache.
--
-- Problem: after a /reload inside a Mythic+ key, party-member
-- LibSpec data isn't immediately available — comm restrictions
-- inside instances delay the sync. Until the data arrives,
-- spec-gated icons (Pain Suppression for Disc, Life Cocoon for
-- MW, etc.) would disappear because our spec filter has no data
-- to gate on.
--
-- Fix: persist every LibSpec callback to BliZziInterruptsSavedVars
-- (account-wide, survives /reload + game restart + character
-- switches on the same account). On addon load we restore the
-- cache into _specByName / _talentsByName as the starting state.
-- LibSpec then updates over the top as fresh data arrives — so
-- the cache is just a warm start, never the source of truth.
--
-- Schema (top-level SV field):
--   BliZziInterruptsSavedVars.partyCDPlayerCache = {
--       [shortName] = {
--           spec    = number,
--           talents = { [spellID] = true, ... },
--           lastSeen = GetTime() at last update,
--       },
--       ...
--   }
-- Cache key is the short name (no realm). Cross-realm collisions
-- are extremely rare for 5-man parties; if it becomes an issue we
-- can switch to full-name keys later.
------------------------------------------------------------
local function _saveCache(short, specId, talents)
    if not short then return end
    -- BliZziInterruptsSavedVars exists by ADDON_LOADED; this code path
    -- is only reachable from LibSpec callbacks which fire well after
    -- the saved-var table is initialised by Blizzard.
    local sv = BliZziInterruptsSavedVars
    if not sv then return end
    sv.partyCDPlayerCache = sv.partyCDPlayerCache or {}
    local entry = sv.partyCDPlayerCache[short] or {}
    if specId   then entry.spec    = specId end
    if talents  then entry.talents = talents end
    entry.lastSeen = time and time() or 0
    sv.partyCDPlayerCache[short] = entry
end

local function _loadCache()
    local sv = BliZziInterruptsSavedVars
    if not sv or not sv.partyCDPlayerCache then return end
    for short, entry in pairs(sv.partyCDPlayerCache) do
        if entry.spec then _specByName[short] = entry.spec end
        if entry.talents then _talentsByName[short] = entry.talents end
    end
end

------------------------------------------------------------
-- Spec sanity check against the party ROLE — a non-secret side channel
-- that exposes stale spec data. The persistent spec cache can outlive a
-- member's respec indefinitely when no fresh LibSpec broadcast arrives
-- (member stopped running a LibSpec-carrying addon, or the instance
-- blocks addon comm): a Windwalker→Mistweaver switch kept showing Touch
-- of Karma forever, surviving /reload and group re-forms because the
-- reload re-hydrates the very cache that is stale.
--
-- UnitGroupRolesAssigned(unit) is readable for party members and
-- GetSpecializationRoleByID maps our cached spec to its role. When the
-- two disagree the cached spec is provably wrong:
--   * drop spec + talents + the persisted cache entry (the talents
--     belong to the old loadout), falling back to the pessimistic
--     spec-unknown rendering, and
--   * when the live role pins the spec uniquely for that class (every
--     class has at most ONE tank spec, and one healer spec except
--     Priest), adopt the corrected spec immediately so the right icons
--     appear without waiting for LibSpec.
------------------------------------------------------------
local ROLE_UNIQUE_SPEC = {
    HEALER = {
        MONK = SPEC.MONK_MIST, PALADIN = SPEC.PAL_HOLY, DRUID = SPEC.DRUID_RESTO,
        SHAMAN = SPEC.SHAM_RESTO, EVOKER = SPEC.EVOKER_PRES,
        -- PRIEST deliberately absent: two healer specs (Disc / Holy).
    },
    TANK = {
        WARRIOR = SPEC.WAR_PROT, PALADIN = SPEC.PAL_PROT, DEATHKNIGHT = SPEC.DK_BLOOD,
        MONK = SPEC.MONK_BREW, DRUID = SPEC.DRUID_GUARDIAN, DEMONHUNTER = SPEC.DH_VENGEANCE,
    },
}
local function _reconcileSpecWithRole(unit, name, class)
    if not unit or not name then return end
    if UnitIsUnit and UnitIsUnit(unit, "player") then return end  -- self resolves via GetSpecialization
    if not UnitGroupRolesAssigned then return end
    local okR, role = pcall(UnitGroupRolesAssigned, unit)
    if not okR or role == nil then return end
    local okS, sec = pcall(issecretvalue, role)
    if okS and sec then return end
    if type(role) ~= "string" or role == "NONE" then return end

    local short = name:match("^([^%-]+)") or name
    local spec  = _specByName[short]
    if spec then
        local okRole, specRole = pcall(GetSpecializationRoleByID, spec)
        if not okRole or not specRole or specRole == role then return end
        -- Contradiction → the cached spec is stale. Drop everything that
        -- belongs to the old loadout, including the persisted entry so
        -- the next /reload doesn't resurrect it.
        _specByName[short]    = nil
        _talentsByName[short] = nil
        local sv = BliZziInterruptsSavedVars
        if sv and sv.partyCDPlayerCache then sv.partyCDPlayerCache[short] = nil end
    end
    local uniq = ROLE_UNIQUE_SPEC[role]
    local corrected = uniq and class and uniq[class]
    if corrected and _specByName[short] ~= corrected then
        _specByName[short] = corrected
        _saveCache(short, corrected, nil)
        -- Spec knowledge changed → previously rejected aura instances
        -- may now classify; let the next scan re-probe this player.
        _rejectedInst[name] = nil
    end
end

do
    local LibSpec = _G.LibStub and _G.LibStub("LibSpecialization", true)
    if LibSpec and LibSpec.RegisterGroup then
        LibSpec.RegisterGroup(PCD, function(specId, role, position, playerName, talentStr)
            if not playerName or playerName == "" then return end
            local short = playerName:match("^([^%-]+)") or playerName

            local changed = false
            if specId and specId > 0 then
                if _specByName[short] ~= specId then
                    _specByName[short] = specId
                    changed = true
                end
            end

            local newKnown
            if talentStr and talentStr ~= "" and specId and specId > 0
               and BIT.ParseTalentString then
                newKnown = BIT.ParseTalentString(specId, talentStr)
                if newKnown then
                    _talentsByName[short] = newKnown
                    changed = true
                end
            end

            -- Persist whatever fresh data we got. _saveCache merges
            -- (a callback that only delivered spec keeps the old
            -- talents, and vice versa) so partial updates don't wipe
            -- the other half of the cache.
            if changed then
                _saveCache(short, specId, newKnown)
            end

            -- A rebuild is only worth doing while the feature is on AND
            -- something actually changed since the last callback. The
            -- LibSpec library re-fires for every group member on each
            -- spec change in the group, so without this guard we'd be
            -- redoing icon work 5x per spec switch.
            if changed and _enabled then
                -- Fresh spec/talent data can make a previously
                -- unclassifiable aura instance matchable — drop the
                -- negative caches so the next scan re-probes everything
                -- once with the new knowledge.
                for k in pairs(_rejectedInst) do _rejectedInst[k] = nil end
                PCD:RebuildAnchors()
            end
        end)
    end
end

------------------------------------------------------------
-- Standalone frame — alternative layout that renders all party
-- cooldowns inside a single movable container instead of attaching
-- to each party member's unit frame. Useful when unit frames are
-- small / cluttered / hidden, or when the user wants a centralised
-- CD readout in a fixed screen location.
--
-- Structure:
--   _standaloneFrame                       ← top-level container,
--                                            movable+lockable, drag
--                                            saves position to DB
--     ├── _standaloneSlots[name].row         ← per-player row frame
--     │   ├── label (player name, classcoloured)
--     │   └── anchor (invisible frame, returned by GetPartyFrame
--     │              when mode=STANDALONE — icons attach here)
--     └── ... one row per member
--
-- The anchor sub-frame is the "virtual unit frame" each icon row
-- attaches to. Reusing the existing EnsureIconsFor layout pipeline
-- — same anchor side / offsets / split / wrap settings — means the
-- standalone mode inherits all icon-layout work for free.
------------------------------------------------------------
local _standaloneFrame         -- top-level movable container
local _standaloneSlots = {}    -- _standaloneSlots[fullName] = { row, label, anchor }

-- Test-layout mode state. When active, the standalone frame is
-- populated with a synthetic 5-row roster (the local player + 4 names
-- from BIT.TEST_POOL, the same pool the Interrupt Tracker / Keystone
-- List previews use) so the user can position / size / theme the
-- frame without needing a real M+ group. Real party slots are hidden
-- for the duration; toggling off restores them.
local _standaloneTestActive  = false
local _standaloneTestRoster  = nil  -- ordered list of { name, class } when test mode is active

-- Forward declarations for functions defined later in the file that
-- the test-mode helpers below reference. Lua binds local-function
-- references at PARSE time, so without these the closures capture
-- nil and throw "attempt to call a nil value" when the user toggles
-- test mode. Each declared name is assigned to (not redeclared as)
-- a function via plain `name = function(...)` further down.
local EnsureStandaloneFrame
local CreateIcon
local ApplyIconBorder
local GetIconSize
local GetIconGap

-- Re-flow the per-player rows inside the standalone frame. Called
-- whenever the roster changes, the show-names toggle flips, or the
-- row-gap slider moves. Each visible member's row stacks downward
-- from the frame's top; hidden members' rows get Hide()d without
-- being destroyed (so their saved icon state is preserved across
-- briefly-leaving-and-rejoining the party).
-- Pick up to 5 class-matching, enabled SPELL_DEFS entries to use as
-- the visual sample icons in a test-mode slot. Spec/talent gates are
-- IGNORED in test mode — the preview is purely a layout visualisation
-- so showing a richer icon row helps the user gauge how a full group
-- of that class would look.
local function _populateTestIcons(slot, classFile)
    -- Clear any test icons from a previous test pass so re-toggling
    -- the test mode doesn't stack duplicates.
    if slot._testIcons then
        for _, ic in ipairs(slot._testIcons) do
            ic:Hide()
            ic:SetParent(nil)
        end
    end
    slot._testIcons = {}

    local picks = {}
    for _, def in ipairs(SPELL_DEFS) do
        if def.class == classFile and not def.disabled then
            picks[#picks+1] = def
            if #picks >= 5 then break end
        end
    end

    local iconSize = GetIconSize()
    local iconGap  = GetIconGap()
    local step     = iconSize + iconGap
    local startGap = 4
    for i, def in ipairs(picks) do
        local icon = CreateIcon(slot.anchor, def)
        icon:SetSize(iconSize, iconSize)
        icon:ClearAllPoints()
        icon:SetPoint("LEFT", slot.anchor, "RIGHT", startGap + step * (i - 1), 0)
        ApplyIconBorder(icon)
        -- Test icons aren't tracking anything live — show them in the
        -- ready state (bright, no swipe, no countdown) so the preview
        -- reads as "this is what a fresh icon row looks like".
        icon:SetAlpha(1.0)
        if icon.tex then icon.tex:SetDesaturated(false) end
        if icon.text then icon.text:SetText("") end
        if icon.cd then icon.cd:Clear() end
        icon:Show()
        slot._testIcons[#slot._testIcons+1] = icon
    end
end

-- Build the synthetic 5-entry roster used by test mode. Entry 1 is
-- always the local player with their real class so the preview feels
-- representative; entries 2-5 are picked from BIT.TEST_POOL with a
-- shuffle so consecutive previews differ. Falls back to a small
-- embedded list when BIT.TEST_POOL hasn't been populated yet.
local _FALLBACK_TEST_POOL = {
    { name = "Jvyx",       class = "DRUID"       },
    { name = "Mírajane",   class = "MAGE"        },
    { name = "Pandavii",   class = "DEMONHUNTER" },
    { name = "Skytecc",    class = "PALADIN"     },
}
local function _buildStandaloneTestRoster()
    local out = {}
    local _, selfCls = UnitClass("player")
    local selfName   = UnitName("player") or "You"
    out[#out+1] = { name = selfName, class = selfCls or "WARRIOR" }

    local pool = BIT.TEST_POOL or _FALLBACK_TEST_POOL
    -- Copy + shuffle so each invocation produces different sample names
    local shuffled = {}
    for _, p in ipairs(pool) do shuffled[#shuffled+1] = p end
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end

    local taken = { [selfName] = true }
    for _, p in ipairs(shuffled) do
        if #out >= 5 then break end
        if p and p.name and not taken[p.name] then
            out[#out+1] = { name = p.name, class = p.class or "WARRIOR" }
            taken[p.name] = true
        end
    end
    return out
end

-- Ensure a standalone slot exists for the given (name, classFile).
-- Used by test mode where we don't have a real unit token to feed
-- GetStandaloneSlot's UnitClassFile probe. The two helpers share the
-- same `_standaloneSlots` cache so an existing real slot for the local
-- player gets reused under their own name in test entry 1.
local function GetStandaloneSlotForTest(name, classFile)
    if not name then return nil end
    local f = EnsureStandaloneFrame()
    local slot = _standaloneSlots[name]
    if not slot then
        local row = CreateFrame("Frame", nil, f)
        row:SetSize(200, 28)

        local label = row:CreateFontString(nil, "OVERLAY")
        local labelFont = (BIT.Media and BIT.Media.font) or "Fonts\\FRIZQT__.TTF"
        local labelSize = (BIT.db and BIT.db.partyCooldownsStandaloneFontSize) or 11
        label:SetFont(labelFont, labelSize, "OUTLINE")
        label:SetPoint("LEFT", row, "LEFT", 6, 0)
        label:SetJustifyH("LEFT")
        label:SetWidth(80)
        label:SetWordWrap(false)
        -- Resolve via BIT.GetDisplayName so the multi-select Custom-
        -- Names filter applies — when "Party CDs" is checked, any
        -- nickname received via SyncCD shows; otherwise the raw
        -- character short name. Strip the "-Realm" suffix afterward
        -- since the row label has limited width.
        local rendered = name
        if BIT.GetDisplayName then
            rendered = BIT.GetDisplayName(name, "PARTY_CDS") or name
        end
        label:SetText(rendered:match("^([^%-]+)") or rendered)

        local cc = BIT.CLASS_COLORS and classFile and BIT.CLASS_COLORS[classFile]
        if cc then
            label:SetTextColor(cc[1], cc[2], cc[3])
        else
            label:SetTextColor(1, 1, 1)
        end

        local anchor = CreateFrame("Frame", nil, row)
        anchor:SetSize(1, 1)
        anchor:SetPoint("LEFT", label, "RIGHT", 8, 0)

        slot = { row = row, label = label, anchor = anchor }
        _standaloneSlots[name] = slot
    end
    return slot
end

local function LayoutStandaloneRows()
    if not _standaloneFrame then return end
    local showNames = BIT.db and BIT.db.partyCooldownsStandaloneShowNames ~= false
    local rowGap    = (BIT.db and BIT.db.partyCooldownsStandaloneRowGap) or 6
    local iconSize  = (BIT.db and BIT.db.partyCooldownsIconSize) or 28
    local rowHeight = math.max(iconSize, 18)
    -- Resolve the font + size once per layout pass and re-apply to
    -- every visible label below. Lets the user resize names via the
    -- settings slider with live feedback — no /reload or roster
    -- toggle needed. SetFont is idempotent when called with the
    -- same args, so this is cheap on the no-change steady state.
    local labelFont = (BIT.Media and BIT.Media.font) or "Fonts\\FRIZQT__.TTF"
    local labelSize = (BIT.db and BIT.db.partyCooldownsStandaloneFontSize) or 11

    -- Collect rows. In test mode iterate the synthetic roster
    -- (player + 4 from BIT.TEST_POOL); otherwise iterate PARTY_UNITS
    -- so the standalone frame mirrors the real party layout
    -- (player first, then party1..4). Test mode also creates the
    -- synthetic slots on-demand here so they exist before the
    -- layout loop tries to position them.
    local visibleNames = {}
    if _standaloneTestActive and _standaloneTestRoster then
        for _, e in ipairs(_standaloneTestRoster) do
            local slot = GetStandaloneSlotForTest(e.name, e.class)
            if slot then
                _populateTestIcons(slot, e.class)
                visibleNames[#visibleNames+1] = e.name
            end
        end
    else
        for _, u in ipairs(PARTY_UNITS) do
            if UnitExists(u) then
                local n = FullName(u)
                if n then visibleNames[#visibleNames+1] = n end
            end
        end
    end

    -- First, hide any rows whose members aren't present anymore.
    for n, slot in pairs(_standaloneSlots) do
        local present = false
        for _, vn in ipairs(visibleNames) do
            if vn == n then present = true; break end
        end
        if not present then slot.row:Hide() end
    end

    -- Lay out present members. growUp=false → first row at TOPLEFT
    -- of the frame, subsequent rows below (y decrement). growUp=true
    -- → first row at BOTTOMLEFT, subsequent rows above (y increment
    -- upward). The first entry (local player) ends up closest to
    -- the user's chosen anchor edge in both modes, so "where to
    -- find yourself" stays consistent.
    local growUp = BIT.db and BIT.db.partyCooldownsStandaloneGrowUpward == true
    local y = 0
    local maxRowW = 0
    for _, n in ipairs(visibleNames) do
        local slot = _standaloneSlots[n]
        if slot then
            slot.row:ClearAllPoints()
            if growUp then
                slot.row:SetPoint("BOTTOMLEFT", _standaloneFrame, "BOTTOMLEFT", 0, y)
            else
                slot.row:SetPoint("TOPLEFT",    _standaloneFrame, "TOPLEFT",    0, -y)
            end
            slot.row:SetHeight(rowHeight)
            slot.row:Show()
            -- Toggle the player-name label + refresh its font so the
            -- font-size slider updates already-cached slots, AND
            -- re-resolve the label text on every layout pass so the
            -- multi-select Custom-Names dropdown takes effect live —
            -- SyncCD HELLO broadcasts often arrive AFTER the slot was
            -- first created, so without this refresh the label would
            -- be frozen on the raw character name. For test slots
            -- the name isn't in SyncCD.users; BIT.GetDisplayName
            -- harmlessly returns the input name in that case.
            if slot.label then
                slot.label:SetFont(labelFont, labelSize, "OUTLINE")
                local rendered = n
                if BIT.GetDisplayName then
                    rendered = BIT.GetDisplayName(n, "PARTY_CDS") or n
                end
                slot.label:SetText(rendered:match("^([^%-]+)") or rendered)
                if showNames then
                    slot.label:Show()
                    slot.anchor:ClearAllPoints()
                    slot.anchor:SetPoint("LEFT", slot.label, "RIGHT", 8, 0)
                else
                    slot.label:Hide()
                    slot.anchor:ClearAllPoints()
                    slot.anchor:SetPoint("LEFT", slot.row, "LEFT", 0, 0)
                end
            end
            local rw = slot.row:GetWidth()
            if rw > maxRowW then maxRowW = rw end
            y = y + rowHeight + rowGap
        end
    end

    -- Resize the container to fit the visible rows. The width grows
    -- with the widest row; the height is the sum of rows + gaps.
    -- Falls back to a small default when the party is empty so the
    -- locked outline (if shown) still has a visible footprint.
    if #visibleNames == 0 then
        _standaloneFrame:SetSize(180, 30)
    else
        _standaloneFrame:SetSize(math.max(maxRowW, 200), math.max(y - rowGap, rowHeight))
    end
end

-- Create (or return) the top-level standalone container. Wired only
-- once per session; subsequent calls return the cached reference.
-- Position is restored from BIT.db (saved on each drag); locked
-- state is consulted on each mouse event so the user can toggle
-- lock live without re-creating the frame.
-- Anchor the standalone frame to the saved screen position using
-- the corner that matches the growth direction:
--   growUpward = false → TOPLEFT pinned, frame grows down + right
--                        as content is added (top edge stays fixed)
--   growUpward = true  → BOTTOMLEFT pinned, frame grows up + right
--                        (bottom edge stays fixed)
-- The saved (X, Y) is the offset from UIParent CENTER to the pinned
-- corner. Called from initial setup, drag-end normalisation, and the
-- Grow Upward toggle so the position survives mode flips.
local function ApplyStandaloneAnchor()
    if not _standaloneFrame then return end
    local growUp = BIT.db and BIT.db.partyCooldownsStandaloneGrowUpward == true
    local x = (BIT.db and BIT.db.partyCooldownsStandaloneX) or 0
    local y = (BIT.db and BIT.db.partyCooldownsStandaloneY) or 0
    _standaloneFrame:ClearAllPoints()
    if growUp then
        _standaloneFrame:SetPoint("BOTTOMLEFT", UIParent, "CENTER", x, y)
    else
        _standaloneFrame:SetPoint("TOPLEFT", UIParent, "CENTER", x, y)
    end
end

-- Assigned to the forward-declared `EnsureStandaloneFrame` so the
-- test-mode helpers above can reference it.
EnsureStandaloneFrame = function()
    if _standaloneFrame then return _standaloneFrame end
    local f = CreateFrame("Frame", "BIT_PartyCooldownsStandalone", UIParent, "BackdropTemplate")
    f:SetSize(200, 30)
    _standaloneFrame = f
    ApplyStandaloneAnchor()
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("MEDIUM")
    -- Mouse-enable starts based on the saved lock state — locked
    -- means clicks pass through; unlocked means drag-to-move works.
    -- ApplyStandaloneLock keeps this in sync when the setting flips.
    f:EnableMouse(not (BIT.db and BIT.db.partyCooldownsStandaloneLocked == true))

    f:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        -- Move-all mode (minimap right-click) overrides the lock at runtime.
        if BIT.db and BIT.db.partyCooldownsStandaloneLocked == true
           and not BIT._moveAllUnlock then return end
        self:StartMoving()
        self._isMoving = true
    end)
    f:SetScript("OnMouseUp", function(self, button)
        if self._isMoving then
            self:StopMovingOrSizing()
            self._isMoving = false
            -- Re-normalise the anchor back to the growth-direction
            -- corner (TOPLEFT for grow-down, BOTTOMLEFT for grow-up)
            -- so the saved offset corresponds to the pinned edge.
            -- After StartMoving/StopMovingOrSizing Blizzard's drag
            -- system leaves the frame in an arbitrary anchor state;
            -- without this re-anchor the saved offset would be
            -- meaningless on the next /reload.
            local growUp = BIT.db and BIT.db.partyCooldownsStandaloneGrowUpward == true
            local px, py = UIParent:GetCenter()
            local left, bottom = self:GetLeft(), self:GetBottom()
            local top = self:GetTop()
            if px and left and bottom and top then
                local dx, dy
                if growUp then
                    -- Save BOTTOMLEFT offset
                    dx = left - px
                    dy = bottom - py
                else
                    -- Save TOPLEFT offset
                    dx = left - px
                    dy = top - py
                end
                if BIT.db then
                    BIT.db.partyCooldownsStandaloneX = dx
                    BIT.db.partyCooldownsStandaloneY = dy
                end
                ApplyStandaloneAnchor()
            end
        end
    end)
    return f
end

-- Toggle the container's mouse-enable state to match the saved
-- lock setting. Locked → mouse disabled so clicks pass through to
-- whatever's below (world / other frames). Unlocked → mouse on so
-- the user can left-click-drag to reposition.
local function ApplyStandaloneLock()
    if not _standaloneFrame then return end
    local locked = BIT.db and BIT.db.partyCooldownsStandaloneLocked == true
    -- Move-all mode (minimap right-click) overrides the lock at runtime.
    if BIT._moveAllUnlock then locked = false end
    _standaloneFrame:EnableMouse(not locked)
end

-- Return the per-unit slot-anchor frame (inside the standalone
-- container) that icons should attach to. Creates the row + label +
-- anchor lazily on first call for a given player; subsequent calls
-- with the same name return the cached anchor.
local function GetStandaloneSlot(unit, name)
    if not name then return nil end
    local f = EnsureStandaloneFrame()
    local slot = _standaloneSlots[name]
    if not slot then
        local row = CreateFrame("Frame", nil, f)
        row:SetSize(200, 28)

        local label = row:CreateFontString(nil, "OVERLAY")
        -- Set font BEFORE SetText — FontString:SetText errors with
        -- "Font not set" on a freshly-created string. The actual
        -- font size is applied below (and re-applied on every layout
        -- pass) so the user can resize via the settings slider live.
        local labelFont = (BIT.Media and BIT.Media.font) or "Fonts\\FRIZQT__.TTF"
        local labelSize = (BIT.db and BIT.db.partyCooldownsStandaloneFontSize) or 11
        label:SetFont(labelFont, labelSize, "OUTLINE")
        label:SetPoint("LEFT", row, "LEFT", 6, 0)
        label:SetJustifyH("LEFT")
        -- Width cap so very long realm-suffixed names don't push the
        -- icons off-screen; truncates via Blizzard's standard ellipsis.
        label:SetWidth(80)
        label:SetWordWrap(false)
        -- Resolve via BIT.GetDisplayName so the multi-select Custom-
        -- Names filter applies (mirrors the test-slot path above).
        local rendered = name
        if BIT.GetDisplayName then
            rendered = BIT.GetDisplayName(name, "PARTY_CDS") or name
        end
        label:SetText(rendered:match("^([^%-]+)") or rendered)
        -- Class-colour the label so a glance at the bar tells the
        -- user who's who without reading the text.
        local cls = UnitClassFile(unit)
        local cc = BIT.CLASS_COLORS and cls and BIT.CLASS_COLORS[cls]
        if cc then
            label:SetTextColor(cc[1], cc[2], cc[3])
        else
            label:SetTextColor(1, 1, 1)
        end

        -- 1px-wide anchor frame: serves only as a positioning
        -- reference. Icons attach with their LEFT to this anchor's
        -- RIGHT + the user's startGap (4px), so they begin right
        -- after the player-name label and grow rightward.
        local anchor = CreateFrame("Frame", nil, row)
        anchor:SetSize(1, 1)
        anchor:SetPoint("LEFT", label, "RIGHT", 8, 0)

        slot = { row = row, label = label, anchor = anchor }
        _standaloneSlots[name] = slot
    end
    return slot.anchor
end

-- Resolve a unit token (player / party1..4) to the frame the icons
-- should attach to. Two modes:
--   STANDALONE → return the per-player anchor frame inside the
--                module's own movable container.
--   ANCHOR     → delegate to the shared unit-frame resolver in
--                Core/UnitFrames.lua so AttachedInterrupts,
--                OffensiveCDAlert and PartyCooldowns share one
--                provider detection (ElvUI / Cell / Grid2 /
--                ShadowedUnitFrames / Danders / EnhanceQoL /
--                Blizzard).
local function GetPartyFrame(unit, providerHint)
    if not unit then return nil end
    if BIT.db and BIT.db.partyCooldownsFrameMode == "STANDALONE" then
        local n = FullName(unit)
        if n then return GetStandaloneSlot(unit, n) end
        return nil
    end
    if BIT.UnitFrames and BIT.UnitFrames.GetPartyFrame then
        return BIT.UnitFrames:GetPartyFrame(unit, providerHint)
    end
    return nil
end

-- Walk the party and yield (unit, name, class) for every actually-present
-- member. Used by RebuildAnchors and the icon-creation path.
local function ForEachPartyMember(fn)
    for _, unit in ipairs(PARTY_UNITS) do
        if UnitExists(unit) then
            local n = FullName(unit)
            local c = UnitClassFile(unit)
            if n and c then fn(unit, n, c) end
        end
    end
end

------------------------------------------------------------
-- Icon widget
--
-- Each tracked spell on each player gets one of these. The container
-- frame holds an icon texture, a cooldown swipe (Blizzard cooldown
-- frame), a small text overlay for the remaining seconds, and an
-- outward-drawn border overlay (sized independently so growing the
-- border doesn't eat into the icon area). Sizing + bordering happen
-- in EnsureIconsFor — CreateIcon only wires up the structural pieces.
------------------------------------------------------------

-- DB-backed sizing helpers. Reading via these means every settings
-- slider that calls RebuildAnchors picks up the latest value without
-- a /reload. Defaults match Core/Data.lua.
-- Assigned to the forward-declared upvalues so the test-mode helpers
-- (which live above and parse before these definitions) can resolve
-- them at runtime without throwing nil-call errors.
GetIconSize = function() return (BIT.db and BIT.db.partyCooldownsIconSize)     or 28 end
GetIconGap  = function() return (BIT.db and BIT.db.partyCooldownsIconGap)      or 3  end
local function GetMaxPerLine()   return (BIT.db and BIT.db.partyCooldownsMaxPerLine)   or 0  end
local function GetBorderSize()   return (BIT.db and BIT.db.partyCooldownsBorderSize)   or 1  end
local function GetBorderOffset() return (BIT.db and BIT.db.partyCooldownsBorderOffset) or 0  end
local function GetOffsetX()      return (BIT.db and BIT.db.partyCooldownsOffsetX)      or 2  end
local function GetOffsetY()      return (BIT.db and BIT.db.partyCooldownsOffsetY)      or 0  end
local function GetChargeOffsetX()  return (BIT.db and BIT.db.partyCooldownsChargeOffsetX)  or  4 end
local function GetChargeOffsetY()  return (BIT.db and BIT.db.partyCooldownsChargeOffsetY)  or -3 end
local function GetChargeFontSize() return (BIT.db and BIT.db.partyCooldownsChargeFontSize) or 13 end
local function GetCdTextFontSize() return (BIT.db and BIT.db.partyCooldownsCdTextFontSize) or 15 end
-- Default-off semantics: explicit `== true` so a missing/nil db key
-- (e.g. pre-merge first-load) reads as false, matching Data.lua.
local function GetCdShowMinutes()  return BIT.db ~= nil and BIT.db.partyCooldownsCdShowMinutes == true end
local function GetCdGrayout()      return BIT.db ~= nil and BIT.db.partyCooldownsCdGrayout      == true end
-- Default-on semantics: missing/nil db key reads as ON (matches Data.lua).
-- The Tick handler consults this to decide whether to render a buff-
-- remaining countdown on top of the icon while the glow is pulsing.
local function GetShowGlowCountdown()
    return BIT.db == nil or BIT.db.partyCooldownsShowGlowCountdown ~= false
end

-- Apply the user-configured font size + offset to an icon's charge
-- badge. Called from CreateIcon to set the initial style, and from
-- PCD:RefreshChargeBadgeStyle when the user moves a slider so live
-- updates take effect without a /reload.
local function ApplyChargeBadgeStyle(icon)
    if not icon or not icon.chargeText then return end
    local font = (BIT.Media and BIT.Media.font) or "Fonts\\FRIZQT__.TTF"
    icon.chargeText:SetFont(font, GetChargeFontSize(), "OUTLINE")
    icon.chargeText:ClearAllPoints()
    icon.chargeText:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT",
        GetChargeOffsetX(), GetChargeOffsetY())
end

-- True if this spell has multiple charges and at least one charge is
-- currently recharging but at least one is still available. Used by
-- the visual code to decide whether to dim the icon: when partial,
-- the spell is still usable so it stays bright; when fully spent
-- (all charges recharging), the standard "on cooldown" dim applies.
local function IsMultiChargePartial(name, def)
    if not def then return false end
    local maxCharges = GetEffectiveCharges(def, name)
    if maxCharges <= 1 then return false end
    local q = _chargeQueue[name] and _chargeQueue[name][def.spellId]
    local pending = q and #q or 0
    return pending > 0 and pending < maxCharges
end

-- Compute and set the charge-badge text for an icon. Always shows the
-- current available-charges count for multi-charge spells (even when
-- at max, e.g. "2/2 → 2"). Empty for single-charge spells.
--
-- Reads icon._def to know the spell and `name` (the caster) to apply
-- talent-aware effective charges. Pulls pending count from the
-- _chargeQueue so the badge stays accurate after a cast.
local function SetChargeBadgeText(name, icon)
    if not icon or not icon.chargeText then return end
    local def = icon._def
    if not def then icon.chargeText:SetText(""); return end
    local maxCharges = GetEffectiveCharges(def, name)
    if maxCharges <= 1 then
        icon.chargeText:SetText("")
        return
    end
    local queue = _chargeQueue[name] and _chargeQueue[name][def.spellId]
    local pending = queue and #queue or 0
    local avail = maxCharges - pending
    if avail < 0 then avail = 0 end
    icon.chargeText:SetText(tostring(avail))
end

-- Assigned to the forward-declared `CreateIcon` upvalue (see top of
-- the standalone-frame block) so test-mode helpers above can call it.
CreateIcon = function(parent, def)
    local f = CreateFrame("Frame", nil, parent)
    -- Mouse-enable state is driven by the partyCooldownsShowTooltip
    -- toggle; EnsureIconsFor calls EnableMouse(...) on every refresh
    -- so the state stays in sync with the setting even after the user
    -- flips it live in the settings UI. We start in the OFF state and
    -- let the first EnsureIconsFor pass set the correct value.
    f:EnableMouse(false)

    -- Tooltip hooks. These are wired unconditionally — even when the
    -- toggle is off they just don't fire because EnableMouse=false
    -- suppresses OnEnter delivery. C_Spell.GetSpellName provides the
    -- localized display name; we anchor to the icon's top-right so
    -- the tooltip doesn't cover the row.
    f:SetScript("OnEnter", function(self)
        local sid = self._def and self._def.spellId
        if not sid then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
        GameTooltip:SetSpellByID(sid)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    f.tex = f:CreateTexture(nil, "ARTWORK")
    f.tex:SetAllPoints()
    f.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    -- C_Spell.GetSpellTexture is the modern (10.x+) texture lookup. The
    -- pcall guards against transient nils right after login when the
    -- spell DB isn't fully populated yet.
    local ok, tex = pcall(C_Spell.GetSpellTexture, def.spellId)
    if ok and tex then f.tex:SetTexture(tex) end

    -- Cooldown swipe — Blizzard's standard CooldownFrameTemplate handles
    -- the radial wipe + ticking blip texture for us.
    f.cd = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
    f.cd:SetAllPoints()
    f.cd:SetDrawEdge(false)
    f.cd:SetDrawBling(false)
    f.cd:SetHideCountdownNumbers(true)  -- we draw our own number

    -- Outward-drawn border overlay. Same approach as the keystone
    -- list: a sibling Frame anchored slightly LARGER than this icon
    -- so the backdrop edgeFile (which Blizzard draws inward from the
    -- frame's edges) ends up sitting OUTSIDE the icon area instead of
    -- eating into the visible texture. Size + offset come from DB and
    -- are applied via ApplyIconBorder() below.
    f.borderOverlay = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.borderOverlay:SetAllPoints(f)
    f.borderOverlay:EnableMouse(false)

    -- Remaining-seconds overlay (we render it manually so we control
    -- the font, color, and "ready" state — Blizzard's built-in
    -- countdown text depends on external cooldown-text addons to
    -- look consistent across the bar).
    --
    -- Two stacked overlay frames so the CD countdown ALWAYS renders
    -- on top of the charge badge when they overlap (e.g. when the
    -- user positions the badge near the centre via the offsets).
    --   chargeOverlay: FrameLevel + 20  (lower — badge sits here)
    --   cdOverlay:     FrameLevel + 30  (higher — countdown text)
    -- Both also need to be above the icon texture + cooldown swipe,
    -- which is why we bump well above f:GetFrameLevel().
    local font = (BIT.Media and BIT.Media.font) or "Fonts\\FRIZQT__.TTF"

    local chargeOverlay = CreateFrame("Frame", nil, f)
    chargeOverlay:SetAllPoints(f)
    chargeOverlay:SetFrameLevel(f:GetFrameLevel() + 20)
    f.chargeText = chargeOverlay:CreateFontString(nil, "OVERLAY")
    f.chargeText:SetTextColor(1, 1, 1)
    -- ApplyChargeBadgeStyle sets the font + anchor; must run BEFORE
    -- SetText, because FontString:SetText() errors with "Font not set"
    -- on a freshly-created string that has no font assigned yet.
    ApplyChargeBadgeStyle(f)
    f.chargeText:SetText("")

    -- Cooldown countdown text. Whole-second display only (FormatRemaining
    -- rounds to integer), so a single center-anchored FontString suffices
    -- — the digits 0-9 in Friz Quadrata are close enough to tabular width
    -- that the visible jitter is below perception when there's no decimal
    -- point shrinking/growing the trailing fragment.
    local cdOverlay = CreateFrame("Frame", nil, f)
    cdOverlay:SetAllPoints(f)
    cdOverlay:SetFrameLevel(f:GetFrameLevel() + 30)
    f.text = cdOverlay:CreateFontString(nil, "OVERLAY")
    f.text:SetFont(font, GetCdTextFontSize(), "OUTLINE")
    f.text:SetPoint("CENTER", cdOverlay, "CENTER", 0, 0)
    f.text:SetJustifyH("CENTER")
    f.text:SetTextColor(1, 1, 1)

    f._def = def
    f:Hide()
    return f
end

-- Apply / refresh the per-icon border overlay. Outward expansion =
-- borderSize + borderOffset; the backdrop's edgeSize draws the actual
-- border that many pixels inward from the overlay's edges. When
-- borderSize is 0 we collapse the overlay to the icon bounds and clear
-- the backdrop — same lifecycle the keystone-list border uses.
--
-- Texture + color come from the Party-CDs-specific DB keys
-- (`partyCooldownsBorderTexturePath` / `partyCooldownsBorderColor*`),
-- not the global interrupt-tracker keys — users wanted independent
-- border styling per feature. Falls back to plain white + black when
-- the keys are unset.
-- Assigned to the forward-declared `ApplyIconBorder` upvalue so the
-- test-mode helpers above can render bordered preview icons.
ApplyIconBorder = function(icon)
    local bo = icon and icon.borderOverlay
    if not bo then return end
    local sz      = GetBorderSize()
    local offset  = GetBorderOffset()
    local outward = sz + offset
    local db      = BIT.db or {}

    bo:ClearAllPoints()
    if sz > 0 then
        bo:SetPoint("TOPLEFT",     icon, "TOPLEFT",     -outward,  outward)
        bo:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT",  outward, -outward)
        local edgeFile = db.partyCooldownsBorderTexturePath
        if not edgeFile or edgeFile == "" then
            edgeFile = "Interface\\BUTTONS\\WHITE8X8"
        end
        bo:SetBackdrop({
            edgeFile = edgeFile,
            edgeSize = sz,
            insets = { left = 0, right = 0, top = 0, bottom = 0 },
        })
        bo:SetBackdropBorderColor(
            db.partyCooldownsBorderColorR or 0,
            db.partyCooldownsBorderColorG or 0,
            db.partyCooldownsBorderColorB or 0,
            db.partyCooldownsBorderColorA or 1)
        bo:Show()
    else
        bo:SetAllPoints(icon)
        bo:SetBackdrop(nil)
    end
end

-- Ensure every spell this player's class can cast has a corresponding
-- icon, parented to the unit frame they're currently displayed on, and
-- laid out in a horizontal row. Called from RebuildAnchors whenever
-- the roster shifts or the user changes Edit Mode layout.
local function EnsureIconsFor(unit, name, class)
    -- Context visibility gate — if the user disabled the feature in
    -- this zone type (e.g. "Show in Open World" off), bail before
    -- doing any frame work. CD state is still tracked separately so
    -- re-entering an enabled context restores the running timers.
    if not ShouldBeVisibleHere() then return end

    -- "Show own cooldowns" toggle: when off, skip rendering the local
    -- player's row entirely. CD state still accumulates in _cdEnd (so
    -- flipping the toggle back on restores running timers), we just
    -- don't create / refresh visible icons. HideIconsOfDepartedMembers
    -- below treats "player" as departed in this case, so existing
    -- player icons get hidden when the toggle is flipped off.
    if unit == "player" and BIT.db and BIT.db.partyCooldownsShowOwn == false then
        return
    end

    -- Resolve race so racial-gated spells (Shadowmeld) get included.
    -- UnitRace returns (localized, englishRaceFile, raceID); the
    -- englishRaceFile is what our def.race field matches against.
    local _, race = UnitRace(unit)
    local list = SpellsForMember(name, class, race)

    -- Stale-icon cleanup: when a party member changes spec (or talent
    -- loadout), LibSpec re-fires our callback and RebuildAnchors runs
    -- through this function with a NEW spell list. Without this pass
    -- the old-spec icons would stay parented + shown — only spells in
    -- the new list get re-positioned by the loop below. We hide any
    -- icon whose spellId isn't in the new list. CD state in _cdEnd is
    -- intentionally left intact so switching back to the old spec
    -- within the CD window restores the running timer.
    local valid = {}
    if list then
        for _, def in ipairs(list) do valid[def.spellId] = true end
    end
    if _icons[name] then
        for spellId, icon in pairs(_icons[name]) do
            if not valid[spellId] then
                StopGlow(icon)
                icon:Hide()
            end
        end
    end

    if not list or #list == 0 then return end  -- no spec-relevant spells (yet)

    -- Provider hint pulls from BIT.db so the user can force a specific
    -- anchor target from the settings UI (e.g. "Always use Blizzard
    -- frames" when ElvUI is loaded but disabled for party).
    local providerHint = (BIT.db and BIT.db.partyCooldownsProvider) or "AUTO"
    if providerHint == "AUTO" then providerHint = nil end
    local parent = GetPartyFrame(unit, providerHint)
    if not parent then
        -- The unit frame isn't available right now (loading screen,
        -- frame still being created, etc.). RebuildAnchors will retry
        -- on the next roster / edit-mode event.
        return
    end

    _icons[name] = _icons[name] or {}

    -- Build the per-bucket render queue. With splitCategories off
    -- (default), a single bucket covers the entire spell list with
    -- the user's main AnchorPos + OffsetX/Y. With splitCategories on,
    -- the list is partitioned into Defensive (cat="DEF" + racials)
    -- and Offensive (cat="OFF"), each routed to its own anchor — so
    -- a user can place DEF on the left of the unit frame and OFF on
    -- the right (or any other axis combination).
    --
    -- Racials always go to the Defensive bucket regardless of their
    -- declared `cat` field. The design intent of the split is "where
    -- do utility/survivability spells go vs damage cooldowns", and
    -- racials are functionally survivability tools (Shadowmeld
    -- vanish, Stoneform purge, etc.) — they belong with DEF spells.
    local iconSize  = GetIconSize()
    local iconGap   = GetIconGap()
    local startGap  = 4
    local step      = iconSize + iconGap
    local maxPerLine = GetMaxPerLine()
    -- Split DEF/OFF only applies in ANCHOR mode where the two buckets
    -- can be placed on opposite sides of the unit frame (e.g. DEF on
    -- the left, OFF on the right). In STANDALONE mode every member
    -- gets a single horizontal row in our own container — splitting
    -- there would just put OFF spells to the right of DEF spells in
    -- the same row, which is what the user gets WITHOUT split anyway,
    -- so the toggle has no useful effect. Force-disable it here so
    -- switching modes back and forth doesn't carry the split visual
    -- into standalone where it doesn't belong.
    local frameMode = (BIT.db and BIT.db.partyCooldownsFrameMode) or "ANCHOR"
    local splitOn = BIT.db and BIT.db.partyCooldownsSplitCategories == true
                    and frameMode ~= "STANDALONE"
    local buckets
    if splitOn then
        local defList, offList = {}, {}
        for _, def in ipairs(list) do
            local cat = def.cat
            if def.race then cat = "DEF" end
            if cat == "OFF" then
                offList[#offList+1] = def
            else
                defList[#defList+1] = def
            end
        end
        buckets = {
            { list = defList,
              pos  = (BIT.db and BIT.db.partyCooldownsAnchorPos) or "LEFT",
              offX = GetOffsetX(),
              offY = GetOffsetY() },
            { list = offList,
              pos  = (BIT.db and BIT.db.partyCooldownsAnchorPosOffensive) or "RIGHT",
              offX = (BIT.db and BIT.db.partyCooldownsOffsetXOffensive) or 2,
              offY = (BIT.db and BIT.db.partyCooldownsOffsetYOffensive) or 0 },
        }
    else
        buckets = {
            { list = list,
              pos  = (BIT.db and BIT.db.partyCooldownsAnchorPos) or "RIGHT",
              offX = GetOffsetX(),
              offY = GetOffsetY() },
        }
    end

    -- STANDALONE mode override. The bucket anchor pos values above
    -- are meant for the user's unit-frame side (LEFT of the frame,
    -- TOP of it, etc.). In standalone mode the icons attach to a
    -- 1px slot anchor inside our own row — only "RIGHT" makes sense
    -- (icons growing rightward from the player-name label). Force
    -- the override per bucket so split-categories on standalone
    -- still works coherently: DEF on first bucket, OFF on second,
    -- both growing right but with their own offX so the user can
    -- still control the spacing between the two groups.
    if BIT.db and BIT.db.partyCooldownsFrameMode == "STANDALONE" then
        for _, b in ipairs(buckets) do
            b.pos  = "RIGHT"
            -- Zero out the user's nudge offsets in standalone mode
            -- — they're authored for the unit-frame use case and
            -- would push icons off the row. Keep an opt-in OFF
            -- bucket offset so split mode can space the two
            -- groups apart inside the same row.
            if b == buckets[2] then
                -- Offensive bucket in split mode: use the offX as a
                -- horizontal SEPARATOR from the DEF group rather
                -- than as a generic nudge. Defaults to 4px gap.
                b.offX = math.max(b.offX or 0, 4)
                b.offY = 0
            else
                b.offX = 0
                b.offY = 0
            end
        end
    end

    local now = GetTime()

    for _, bucket in ipairs(buckets) do
        if #bucket.list > 0 then
    -- Resolve the anchor side. Each side wires a different (point,
    -- relPoint, dx, dy step) combination so icons grow in the chosen
    -- direction starting flush with the frame edge plus a small gap.
    local pos = bucket.pos
    local point, relPoint, baseX, baseY, stepX, stepY
    if pos == "LEFT" then
        point, relPoint = "RIGHT", "LEFT"
        baseX, baseY    = -startGap, 0
        stepX, stepY    = -step, 0
    elseif pos == "TOP" then
        point, relPoint = "BOTTOM", "TOP"
        baseX, baseY    = 0, startGap
        stepX, stepY    = 0, step
    elseif pos == "BOTTOM" then
        point, relPoint = "TOP", "BOTTOM"
        baseX, baseY    = 0, -startGap
        stepX, stepY    = 0, -step
    else  -- RIGHT (default)
        point, relPoint = "LEFT", "RIGHT"
        baseX, baseY    = startGap, 0
        stepX, stepY    = step, 0
    end

    -- User-configurable XY nudge, applied AFTER the anchor side has
    -- been chosen so the row keeps its growth direction but can be
    -- shifted out of the way of overlapping UI (boss-mod timers,
    -- frame borders, etc.). Negative X moves left, positive Y moves
    -- up — same sign convention Blizzard SetPoint uses. Sourced from
    -- the per-bucket config so Defensive vs Offensive can be nudged
    -- independently.
    baseX = baseX + bucket.offX
    baseY = baseY + bucket.offY

    -- Wrap parameters. When MaxPerLine is > 0, icons after that count
    -- start a new line perpendicular to the primary growth axis:
    --   LEFT/RIGHT (horizontal primary) → wrap DOWNWARD (Y-)
    --   TOP/BOTTOM (vertical   primary) → wrap to the RIGHT (X+)
    -- A line spacing equal to one icon's step keeps the grid uniform.
    local secX, secY = 0, 0
    if stepX ~= 0 then
        -- Primary axis is horizontal → wrap vertically downward.
        secX, secY = 0, -step
    else
        -- Primary axis is vertical → wrap horizontally to the right.
        secX, secY = step, 0
    end

    local idx = 0
    for _, def in ipairs(bucket.list) do
        local icon = _icons[name][def.spellId]
        if not icon then
            icon = CreateIcon(parent, def)
            _icons[name][def.spellId] = icon
        elseif icon:GetParent() ~= parent then
            -- Roster reshuffled: this player now lives on a different
            -- unit frame. Re-parent + re-anchor without recreating.
            icon:SetParent(parent)
        end
        -- Compute the icon's grid position. With maxPerLine==0 (the
        -- unlimited default) row is always 0 → behaves identically to
        -- the previous single-line layout. With a positive cap, col
        -- counts within the line and row jumps to the next line.
        local col, row
        if maxPerLine and maxPerLine > 0 then
            col = idx % maxPerLine
            row = math.floor(idx / maxPerLine)
        else
            col, row = idx, 0
        end
        -- Re-apply size + position + border on EVERY pass so changes
        -- from the settings sliders take effect live (RebuildAnchors
        -- runs us again on each slider change).
        icon:SetSize(iconSize, iconSize)
        icon:ClearAllPoints()
        icon:SetPoint(point, parent, relPoint,
            baseX + stepX * col + secX * row,
            baseY + stepY * col + secY * row)
        ApplyIconBorder(icon)
        -- Tooltip mouse-state mirrors the user's setting. When off we
        -- explicitly disable mouse so the icon doesn't intercept
        -- click-through to the underlying unit frame.
        icon:EnableMouse(BIT.db and BIT.db.partyCooldownsShowTooltip ~= false or false)
        idx = idx + 1
        icon:Show()

        -- Restore the visual state from our tracking tables. Three
        -- discrete phases the user sees on the icon:
        --
        --   1) buffActive — `_glowEnd[name][spellId]` still in the future:
        --      bright icon + LibButtonGlow ring + no cooldown swipe.
        --      This is the "spell is doing something right now" look.
        --
        --   2) onCooldown — `_cdEnd[name][spellId]` still in the future
        --      AND glow already expired: dimmed + swipe + countdown.
        --      This is the classic "wait for it to come back" look.
        --
        --   3) ready/untracked — neither timer in the future: bright,
        --      no glow, no swipe, no text. Used both for "spell is
        --      back up" and "we haven't seen this player cast it yet"
        --      (the user can't distinguish these without history, but
        --      the visual is the right one for either case).
        --
        -- This block runs on every RebuildAnchors call, so a roster
        -- reshuffle that destroys + recreates icons still ends up
        -- with the correct visual state restored from in-memory.
        local glowEnd = _glowEnd[name] and _glowEnd[name][def.spellId]
        local cdEnd   = _cdEnd[name]   and _cdEnd[name][def.spellId]
        if glowEnd and glowEnd > now then
            icon:SetAlpha(1.0)
            if icon.tex then icon.tex:SetDesaturated(false) end
            icon.text:SetText("")
            if icon.cd then icon.cd:Clear() end
            StartGlow(icon)
        elseif cdEnd and cdEnd > now then
            -- Multi-charge partial: spell is still castable so we keep
            -- the icon bright while showing the recharge swipe for the
            -- next charge. Fully-spent (single charge OR all charges
            -- consumed) takes the standard dim + desat look — unless
            -- the user disabled CD grayout in settings.
            local partial = IsMultiChargePartial(name, def)
            if partial or not GetCdGrayout() then
                icon:SetAlpha(1.0)
                if icon.tex then icon.tex:SetDesaturated(false) end
            else
                icon:SetAlpha(0.65)
                if icon.tex then icon.tex:SetDesaturated(true) end
            end
            if icon.cd then icon.cd:SetCooldown(now, cdEnd - now) end
            StopGlow(icon)
            -- text gets filled in by the next Tick
        else
            icon:SetAlpha(1.0)
            if icon.tex then icon.tex:SetDesaturated(false) end
            icon.text:SetText("")
            if icon.cd then icon.cd:Clear() end
            StopGlow(icon)
        end

        -- Charge badge: always show current available-charges count
        -- for multi-charge spells (e.g. "2" when Blur is at 2/2 with
        -- the Demonic Resilience talent). Empty string for single-
        -- charge spells.
        SetChargeBadgeText(name, icon)
    end
        end  -- if #bucket.list > 0
    end  -- for _, bucket in ipairs(buckets)
    _attachedTo[name] = parent
end

------------------------------------------------------------
-- Local-player charge authority.
--
-- For the LOCAL PLAYER, Blizzard's C_Spell.GetSpellCharges is the
-- ground-truth charge count — it knows exactly how many charges are
-- available and when each recharges, regardless of how many aura
-- events fired. We use it to REBUILD the charge queue authoritatively
-- instead of incrementally pushing per cast/aura-event. This makes the
-- local player immune to spurious charge commits from any path: a
-- self-refresh proc (Fiery Brand's Burning Alive spread), a duplicate
-- aura event, or a misclassified flag-twin can't inflate the queue,
-- because the rebuild always snaps it back to Blizzard's real count.
--
-- Taint-safe field reads (these can be secret values in 12.x M+).
-- _readCDField rejects <= 0 (cooldown start/duration of 0 = "no CD");
-- _readChargeField accepts 0 (currentCharges == 0 is valid).
local function _readCDField(t, key)
    local ok, v = pcall(function() return t and t[key] end)
    if not ok or type(v) ~= "number" then return nil end
    local okS, isSec = pcall(issecretvalue, v)
    if not okS or isSec then return nil end
    if v <= 0 then return nil end
    return v
end
local function _readChargeField(t, key)
    local ok, v = pcall(function() return t and t[key] end)
    if not ok or type(v) ~= "number" then return nil end
    local okS, isSec = pcall(issecretvalue, v)
    if not okS or isSec then return nil end
    if v < 0 then return nil end
    return v
end

-- Rebuild the local player's charge queue + _cdEnd for one spell from
-- Blizzard's authoritative GetSpellCharges. Returns true if the spell
-- IS multi-charge and was handled (so callers can skip their own
-- incremental queue logic); false if it's single-charge / unreadable
-- (caller falls back to its normal path).
local function RebuildLocalChargeQueue(name, spellId)
    if not (C_Spell and C_Spell.GetSpellCharges) then return false end
    local ok, info = pcall(C_Spell.GetSpellCharges, spellId)
    if not ok or not info then return false end
    local maxC = _readChargeField(info, "maxCharges")
    local curC = _readChargeField(info, "currentCharges")
    if not (maxC and maxC > 1 and curC) then return false end  -- not multi-charge
    if curC >= maxC then
        -- Fully charged → no CD, no queue.
        if _cdEnd[name] then _cdEnd[name][spellId] = nil end
        if _chargeQueue[name] then _chargeQueue[name][spellId] = nil end
        return true
    end
    local cdStart = _readCDField(info, "cooldownStartTime")
    local cdDur   = _readCDField(info, "cooldownDuration")
    if cdStart and cdDur and cdDur > 0 then
        local pending = maxC - curC
        local q = {}
        for i = 1, pending do q[i] = cdStart + i * cdDur end
        _chargeQueue[name] = _chargeQueue[name] or {}
        _chargeQueue[name][spellId] = q
        _cdEnd[name] = _cdEnd[name] or {}
        _cdEnd[name][spellId] = q[1]  -- soonest pending recharge
    end
    return true
end

------------------------------------------------------------
-- Detection — called from the UNIT_AURA observer when a tracked
-- buff appears on a party unit.
------------------------------------------------------------
function PCD:OnAuraAppeared(unit, def, aura)
    _stats.onAuraAppeared = _stats.onAuraAppeared + 1
    -- Pick the caster:
    --   self-cast spells:   caster is the unit the buff is on
    --   target-cast spells: caster is aura.sourceUnit (e.g. Pain
    --                       Suppression buff appears on the tank,
    --                       sourceUnit is the priest)
    --
    -- aura.sourceUnit can itself be a secret value for party-member
    -- auras in 12.0.5. The whole resolution is wrapped in pcall and
    -- gated by issecretvalue BEFORE any string compare, because
    -- comparing a tainted string with "" produces a tainted boolean
    -- and using THAT in an `if` chain is what throws — the throw
    -- isn't on the access, it's on the next conditional after the
    -- compare. Doing issecretvalue first sidesteps the trap entirely.
    -- Fallback: treat as self-cast on the unit the buff landed on.
    local casterUnit
    local casterVia = "self"
    if def.affects == "self" then
        casterUnit = unit
    else
        -- Try aura.sourceUnit first. It can be tainted for party-
        -- member auras in 12.0.5, in which case the pcall'd accessor
        -- returns nil and we fall through to a class-based fallback.
        local okSU, su = pcall(function()
            local s = aura.sourceUnit
            if s == nil then return nil end
            if type(s) ~= "string" then return nil end
            if issecretvalue(s) then return nil end
            if s == "" then return nil end
            return s
        end)
        if okSU and su and UnitExists(su) then
            casterUnit = su
            casterVia = "sourceUnit"
        else
            -- Class-search fallback: aura.sourceUnit is secret (typical
            -- in M+), so attribute by the spell's class. Dead members are
            -- excluded — a corpse can't have cast a target-cast buff.
            local candidates = {}
            for _, u in ipairs(PARTY_UNITS) do
                if UnitExists(u) and UnitClassFile(u) == def.class
                   and not UnitIsDeadOrGhost(u) then
                    candidates[#candidates + 1] = u
                end
            end
            if #candidates == 1 then
                -- Unambiguous: the only member of that class.
                casterUnit = candidates[1]
                casterVia  = "class-fallback"
                _stats.casterFallback = _stats.casterFallback + 1
            elseif #candidates > 1 then
                -- Ambiguous (e.g. two Paladins, both able to cast Blessing
                -- of Protection). We can't read the secret caster, but
                -- dropping the detection means NO icon for anyone — worse
                -- than crediting one of them. Prefer the first member whose
                -- copy of this spell is NOT already on cooldown, so a
                -- second near-simultaneous cast lands on the OTHER member
                -- (the first is now on CD) instead of being lost. If every
                -- candidate already shows it on CD (e.g. a re-detection
                -- during the active buff phase), fall back to the first so
                -- the glow still refreshes.
                local nowTs = GetTime()
                local fallback
                for _, u in ipairs(candidates) do
                    fallback = fallback or u
                    local nm = FullName(u)
                    local cdE = nm and _cdEnd[nm] and _cdEnd[nm][def.spellId]
                    if not (cdE and cdE > nowTs) then
                        casterUnit = u
                        break
                    end
                end
                casterUnit = casterUnit or fallback
                casterVia  = "class-fallback-multi"
                _stats.casterFallback = _stats.casterFallback + 1
            end
        end
    end
    if not casterUnit or not UnitExists(casterUnit) then
        _stats.castersDropped = _stats.castersDropped + 1
        return
    end

    -- Dead-caster guard for target-cast defs. When the buff is on
    -- the unit `unit` and we resolved `casterUnit` via class fallback
    -- (no usable aura.sourceUnit in M+ taint contexts), a DEAD class-
    -- member can't actually have cast a target-cast buff. Without
    -- this guard a Pala corpse in the group still gets BoF glows
    -- attributed via the class-fallback whenever a "--I-" aura lands
    -- on someone else (e.g. DH Meta on themselves). Self-cast skip
    -- the check — the buff IS on the caster, so liveness is implied.
    if def.affects == "target" and UnitIsDeadOrGhost(casterUnit) then
        _stats.castersDropped = _stats.castersDropped + 1
        return
    end

    local name = FullName(casterUnit)
    if not name then
        _stats.castersDropped = _stats.castersDropped + 1
        return
    end

    -- Class check: filters out edge cases like a non-Priest somehow
    -- getting a Pain Suppression-IDed buff applied by a script. The
    -- class for the caster has to match the spell's class. For racial
    -- entries (def.class == nil) this check is skipped, the race gate
    -- below takes over.
    local cls = UnitClassFile(casterUnit)
    if def.class and cls ~= def.class then
        _stats.castersDropped = _stats.castersDropped + 1
        return
    end

    -- Race check: same idea as the class check, but for race-gated
    -- entries like Shadowmeld (only Night Elves can have cast it).
    -- UnitRace returns (localized, englishRaceFile, raceID); the
    -- englishRaceFile is what def.race holds. Skipped when def.race
    -- isn't set (class spells).
    if def.race then
        local _, eRace = UnitRace(casterUnit)
        if eRace ~= def.race then
            _stats.castersDropped = _stats.castersDropped + 1
            return
        end
    end

    -- SPEC INFERENCE from a positively identified spec-exclusive spell:
    -- attributing e.g. Ironbark (Resto-only) to a druid PROVES the spec.
    -- Without LibSpec data and without an assigned role (manual open-
    -- world groups report role NONE), the member's spec stays unknown
    -- and SpellsForMember pessimistically hides every spec-gated icon —
    -- the detection then committed the CD but had NO icon to glow (live
    -- report: Ironbark cast on the player, buff active, nothing shown).
    -- Adopting the proven spec right here lets the EnsureIconsFor call
    -- further down build the icon in this very pass, so even the first
    -- observed cast glows. Only single-spec defs qualify (spec lists
    -- like Blur's Havoc+Devourer stay ambiguous); a spec that is already
    -- known is never overridden (LibSpec/role data outranks inference).
    if type(def.spec) == "number"
       and not (UnitIsUnit and UnitIsUnit(casterUnit, "player")) then
        local short = name:match("^([^%-]+)") or name
        if _specByName[short] == nil then
            _specByName[short] = def.spec
            _saveCache(short, def.spec, nil)
            _rejectedInst[name] = nil
        end
    end

    local now = GetTime()

    local effectiveCD = GetEffectiveCD(def, name)
    local effectiveCharges = GetEffectiveCharges(def, name)
    _cdEnd[name] = _cdEnd[name] or {}

    -- SELF-REFRESH SCAN-SKIP. A selfRefreshing spell (Fiery Brand +
    -- Burning Alive) re-fires OnAuraAppeared via the scan on every
    -- spread tick, each as a NEW aura instance. If we let those touch
    -- the charge/CD state, the recharge timer gets rewritten every
    -- second — it flickers and NEVER completes (live-observed: Fiery
    -- Brand stuck at 1/2 forever, badge jumping each second). So once
    -- we're already tracking the spell, a scan re-detection (real aura
    -- with an auraInstanceID) is treated as a passive refresh: skip the
    -- charge/CD commit entirely, leave the recharge timer ticking down
    -- monotonically. The glow still refreshes in the icon section below.
    --
    -- The cast-event path passes a SYNTHETIC aura (no auraInstanceID),
    -- so genuine recasts that fire UNIT_SPELLCAST_SUCCEEDED still commit
    -- (add the second charge). A recast seen ONLY via the scan won't add
    -- its charge until the first recharge completes — an acceptable
    -- trade-off versus a timer that never completes at all.
    -- Same-INSTANCE re-detection guard (all casters, all spells): if the
    -- exact aura instance that produced the last commit shows up again
    -- (full-update rescan, talent-driven duration extension, glow
    -- refresh), it is by definition NOT a new use — skip the commit but
    -- keep the glow refresh below. Genuine new uses arrive either as a
    -- cast event (synthetic aura, no instance ID) or as a NEW instance.
    local sameInstance = false
    if aura and aura.auraInstanceID and _cdEnd[name][def.spellId] then
        local inst = aura.auraInstanceID
        local okS, isSec = pcall(issecretvalue, inst)
        if (not okS or not isSec)
           and _lastCommitInst[name]
           and _lastCommitInst[name][def.spellId] == inst then
            sameInstance = true
        end
    end

    if sameInstance
       or (casterUnit == "player" and def.selfRefreshing
           and aura and aura.auraInstanceID
           and _cdEnd[name][def.spellId]) then
        -- (fall straight through to the glow rendering below; no commit)
    else
        -- PROC GUARD (central — catches every caller, including paths
        -- that bypass the scan-level guard): a readable duration below
        -- the def's minimum real duration is a talent proc, never a
        -- use (Dark Ranger Smoke Screen: 3s SotF from Exhilaration).
        -- Three sources tried in order, because any single one can be
        -- unreadable depending on context. Fail-open: nothing readable
        -- → never block a real cast. Cast-path synthetic auras carry
        -- none of the fields and pass through (a cast IS a real use).
        if def.minDur then
            local shortDur
            local okD, d = pcall(function() return aura and aura.duration end)
            if okD and type(d) == "number" then
                local okS, sec = pcall(issecretvalue, d)
                if (not okS or not sec) and d > 0 then shortDur = d end
            end
            if not shortDur and aura and aura.auraInstanceID then
                local okA, ad = pcall(C_UnitAuras.GetAuraDuration, unit, aura.auraInstanceID)
                if okA and type(ad) == "number" then
                    local okS, sec = pcall(issecretvalue, ad)
                    if (not okS or not sec) and ad > 0 then shortDur = ad end
                end
            end
            if not shortDur then
                local okE, exp = pcall(function() return aura and aura.expirationTime end)
                if okE and type(exp) == "number" then
                    local okS, sec = pcall(issecretvalue, exp)
                    if (not okS or not sec) and exp > 0 then
                        local remain = exp - now
                        if remain > 0 then shortDur = remain end
                    end
                end
            end
            if shortDur and shortDur < def.minDur then
                _stats.procSkips = (_stats.procSkips or 0) + 1
                return
            end
        end

        -- Same-cast dedup. UNIT_SPELLCAST_SUCCEEDED + the deferred
        -- UNIT_AURA scan both reach OnAuraAppeared for the same cast;
        -- typically ~70ms apart but notably more under combat load.
        -- Skipping the second keeps the charge queue from counting one
        -- cast as two. Before bailing, remember the real instance ID so
        -- later rescans of this same aura hit the instance guard above.
        _lastCommitAt[name] = _lastCommitAt[name] or {}
        local lastAt = _lastCommitAt[name][def.spellId]
        if lastAt and (now - lastAt) < 0.4 then
            if aura and aura.auraInstanceID then
                local okS, isSec = pcall(issecretvalue, aura.auraInstanceID)
                if not okS or not isSec then
                    _lastCommitInst[name] = _lastCommitInst[name] or {}
                    _lastCommitInst[name][def.spellId] = aura.auraInstanceID
                end
            end
            return
        end
        _lastCommitAt[name][def.spellId] = now
        if aura and aura.auraInstanceID then
            local okS, isSec = pcall(issecretvalue, aura.auraInstanceID)
            if not okS or not isSec then
                _lastCommitInst[name] = _lastCommitInst[name] or {}
                _lastCommitInst[name][def.spellId] = aura.auraInstanceID
            end
        end

        if effectiveCharges > 1 then
            -- Multi-charge: serial-recharge queue. Each cast pushes a
            -- new entry at max(latest_queue_entry + cd, now + cd). The
            -- timer is set ONCE per cast and ticks down monotonically;
            -- it is never rewritten by spreads (those are skipped above)
            -- or by a per-tick rebuild — that monotonicity is what lets
            -- the recharge actually complete.
            _chargeQueue[name] = _chargeQueue[name] or {}
            local queue = _chargeQueue[name][def.spellId] or {}

            for i = #queue, 1, -1 do
                if queue[i] <= now then table.remove(queue, i) end
            end

            local latestEnd = 0
            for _, t in ipairs(queue) do
                if t > latestEnd then latestEnd = t end
            end
            local newEnd = math.max(latestEnd + effectiveCD, now + effectiveCD)
            -- Phantom-commit safety net: with every charge spent, the
            -- farthest legitimate completion of the LAST recharge is
            -- charges × cd from now (serial recharge, all charges just
            -- consumed). Any tail beyond that can only come from
            -- double-counted uses — clamp so residual miscounts cost at
            -- most one recharge cycle instead of snowballing without
            -- bound (live report: 800s+ on a 2-charge / ~81s spell).
            local maxEnd = now + effectiveCD * effectiveCharges
            if newEnd > maxEnd then newEnd = maxEnd end
            table.insert(queue, newEnd)
            table.sort(queue)
            while #queue > effectiveCharges do
                table.remove(queue, 1)
            end
            _chargeQueue[name][def.spellId] = queue

            if #queue > 0 then
                _cdEnd[name][def.spellId] = queue[1]
            else
                _cdEnd[name][def.spellId] = nil
            end
        else
            -- Single charge.
            _cdEnd[name][def.spellId] = now + effectiveCD
        end

        _stats.cdsCommitted = _stats.cdsCommitted + 1
    end

    -- Visibility gate: CD state is committed (above) so re-entering an
    -- enabled context restores the running timer without losing time,
    -- but we skip the icon/glow rendering when the user has the
    -- feature disabled for this context.
    if not ShouldBeVisibleHere() then return end

    -- "Show own cooldowns" gate. When off, the local player's icons
    -- are kept in _icons (so flipping the toggle back on restores
    -- running timers without rebuilding the icon set), but new casts
    -- must NOT re-Show / re-glow them. Without this guard, casting
    -- a self-cast spell (e.g. Fiery Brand) re-uses a previously
    -- created icon from _icons[playerName][...] via the lookup below
    -- and calls icon:Show() + glow — producing a visible flash that
    -- disappears again when the next HideIconsOfDepartedMembers pass
    -- (roster update / ApplyVisibility) re-hides it. EnsureIconsFor
    -- already has the equivalent gate for the icon-creation path.
    if casterUnit == "player" and BIT.db and BIT.db.partyCooldownsShowOwn == false then
        return
    end

    -- Make sure the icon exists + is visible. The unit-to-frame lookup
    -- might already be cached from a previous roster pass.
    local icon = _icons[name] and _icons[name][def.spellId]
    if not icon then
        EnsureIconsFor(casterUnit, name, cls)
        icon = _icons[name] and _icons[name][def.spellId]
    end
    if icon then
        icon:Show()
        -- Two-phase visual state — same approach the addon used before:
        --
        --   Buff-active phase (now .. buffEnd):
        --     - Icon stays bright + opaque (spell is currently doing
        --       something for the player; not "on cooldown" yet from
        --       a useful-information standpoint)
        --     - LibButtonGlow ring pulses
        --     - No cooldown swipe, no countdown text
        --
        --   Cooldown phase (buffEnd .. cdEnd):
        --     - Icon desaturated + dimmed
        --     - Cooldown swipe runs from buffEnd to cdEnd
        --     - Countdown text ticks down
        --     - Glow off
        --
        --   This split happens automatically in Tick() when the glow
        --   expiration is detected: we hide the glow and START the
        --   cooldown swipe at that moment with the remaining time.
        --   That way the user reads the icon naturally — bright + glow
        --   means the spell is being USED right now, dim + swipe means
        --   the spell is on real cooldown.
        icon:SetAlpha(1.0)
        if icon.tex then icon.tex:SetDesaturated(false) end
        icon.text:SetText("")
        if icon.cd then icon.cd:Clear() end

        -- Charge badge: always shows current available-charges for
        -- multi-charge spells (even at max), empty for single-charge.
        SetChargeBadgeText(name, icon)

        if def.noGlow then
            -- Skip the buff-active phase entirely: jump straight to the
            -- cooldown visual. Used for spells like Feign Death and
            -- Shadowmeld where "buff is active" doesn't carry useful
            -- at-a-glance information — only the CD matters. No
            -- _glowEnd entry is created, so Tick() won't try to
            -- transition this icon. Use the effective CD so talent
            -- reductions apply here too. Dim/desat only when the
            -- user wants on-CD spells grayed out.
            if icon.cd then icon.cd:SetCooldown(now, effectiveCD) end
            if GetCdGrayout() then
                if icon.tex then icon.tex:SetDesaturated(true) end
                icon:SetAlpha(0.65)
            end
        else
            StartGlow(icon)
            _glowEnd[name] = _glowEnd[name] or {}
            -- We use the def's nominal duration (clean game-data)
            -- rather than the aura's own expirationTime field — the
            -- latter can be a secret-tainted number for party-member
            -- auras in 12.0.5 and arithmetic on it would throw.
            -- GetEffectiveDuration applies talent-driven extensions
            -- (e.g. Improved Barkskin = +4s) so the glow timing
            -- matches the actual buff window per-caster.
            local effectiveDur = GetEffectiveDuration(def, name)
            _glowEnd[name][def.spellId] = now + effectiveDur
        end
    end
end

------------------------------------------------------------
-- Glow-only refresh — used by selfRefreshing defs (e.g. Fiery Brand
-- with Burning Alive). When the spell's self-buff is refreshed by
-- a game mechanic (spread, talent proc) rather than a recast, we
-- want the glow ring to track the actual buff window — the buff
-- duration jumps back to its nominal value every time the spread
-- fires, and the glow should follow visually. BUT the cooldown
-- swipe and charge queue must keep running unchanged because no
-- second cast actually happened (the player only consumed one
-- charge for the original cast that's still spreading).
--
-- This helper only touches _glowEnd + re-arms the LBG overlay. It
-- explicitly does NOT call OnAuraAppeared, push to _chargeQueue,
-- or modify _cdEnd.
------------------------------------------------------------
local function RefreshGlowOnly(unit, def)
    if not unit or not def then return end
    if def.noGlow then return end
    local casterUnit
    if def.affects == "self" then
        casterUnit = unit
    else
        return  -- glow-only refresh path only makes sense for self-cast buffs
    end
    if not UnitExists(casterUnit) then return end
    local name = FullName(casterUnit)
    if not name then return end

    if not ShouldBeVisibleHere() then return end

    -- "Show own cooldowns" gate: same rationale as OnAuraAppeared.
    -- Without this, Fiery Brand's Burning Alive spread refresh would
    -- re-arm the glow on a previously-hidden player icon and the user
    -- sees a brief flash on every spread tick even with the toggle off.
    if casterUnit == "player" and BIT.db and BIT.db.partyCooldownsShowOwn == false then
        return
    end

    local icon = _icons[name] and _icons[name][def.spellId]
    if not icon then return end

    -- Extend the glow expiration to match the just-refreshed buff
    -- window. GetEffectiveDuration applies any talent-driven duration
    -- modifiers so the glow length matches the actual buff window.
    local now = GetTime()
    _glowEnd[name] = _glowEnd[name] or {}
    _glowEnd[name][def.spellId] = now + GetEffectiveDuration(def, name)

    -- Re-arm the overlay glow in case Tick already transitioned it off
    -- (rare — only happens if the refresh arrives in the same frame
    -- the previous glow expired). Idempotent when the glow is already
    -- showing, so cheap to always call.
    StartGlow(icon)
    -- Restore the bright-buff visual in case the icon had already
    -- transitioned to the dimmed on-CD state (Tick's expiry branch).
    -- The CD swipe itself is left running — only the alpha/desat
    -- get reset, which is what differentiates "buff active" from
    -- "buff over, just CD ticking" at a glance.
    icon:SetAlpha(1.0)
    if icon.tex then icon.tex:SetDesaturated(false) end
end

------------------------------------------------------------
-- Tick — once per OnUpdate frame we walk every active cooldown,
-- refresh the text overlay, and switch ready icons back to opaque.
------------------------------------------------------------
local _tickAccum = 0
local TICK_INTERVAL = 0.1   -- 10 fps is plenty for second-resolution

-- Whole-second countdown. Always rounds up so the displayed number
-- matches what the user expects ("3" means at least 3 seconds left,
-- not "anywhere between 2.5 and 3.5"). Sub-second remainder shows as
-- "1" until the very moment the CD expires — cleaner visual than a
-- jittery 0.4 / 0.3 / 0.2 decimal tick. When ShowMinutes is enabled
-- and the remainder is above 60s we compact to "Xm" (e.g. "3m").
local function FormatRemaining(rem)
    if rem >= 60 and GetCdShowMinutes() then
        return string.format("%dm", math.floor(rem / 60 + 0.5))
    end
    if rem > 0 then return tostring(math.ceil(rem)) end
    return ""
end

local function Tick(_, elapsed)
    _tickAccum = _tickAccum + elapsed
    if _tickAccum < TICK_INTERVAL then return end
    _tickAccum = 0

    local _p, _t0 = _prof.tick, debugprofilestop()
    _p.calls = _p.calls + 1
    local now = GetTime()

    -- ── Local-player CD sync ─────────────────────────────────────
    -- For the player slot (us), Blizzard's authoritative cooldown is
    -- available via C_Spell.GetSpellCooldown / GetSpellCharges. Our
    -- static cdMods/durMods can't model dynamic talent CDR (e.g.
    -- Voidfall meteor procs reducing Vengeance Metamorphosis CD by
    -- 10s every 3rd meteor) — those reductions land in the real
    -- spell CD on the server but never reach our addon as discrete
    -- events. Result without this sync: the user is actually ready
    -- but the tracker still shows tens of seconds remaining.
    --
    -- We only DECREASE our `_cdEnd` value here — never extend it.
    -- That way a transient GCD-only return from GetSpellCooldown
    -- (1.5s for a spell with no real CD) can't accidentally shorten
    -- a long-CD timer we're correctly tracking. The check is:
    --   realRemain < ourRemain - 1   (1s slack avoids noise)
    -- The 1s margin keeps us from spamming updates on jitter while
    -- still catching a 10s+ CDR proc within one tick.
    --
    -- Only applies to the local player. Party-member spells have to
    -- stay on the static model — Blizzard doesn't expose their CDs
    -- via any local API.
    -- Helper: read a cooldown field with full 12.0.5 taint defence.
    -- C_Spell.GetSpellCharges / GetSpellCooldown can return secret-
    -- tagged numbers for startTime/duration in some encounter
    -- contexts (e.g. ritual sites, M+ taint-saturated combat). A
    -- raw `>` compare on a tainted number throws "attempt to compare
    -- field 'startTime' (a secret number value)" — same failure
    -- mode the UNIT_AURA pipeline guards against for aura.duration.
    --
    -- Strategy: pcall the field read AND issecretvalue both, treat
    -- ANY failure as "field unusable". Falls through to "skip this
    -- spell on this tick" — next tick re-tries, eventually
    -- succeeding once the taint clears or returning nothing if the
    -- spell stays tainted (in which case the static cdMods model
    -- is the only source of truth, same as a party-member spell).
    local function _readCleanField(t, key)
        local ok, v = pcall(function() return t and t[key] end)
        if not ok or type(v) ~= "number" then return nil end
        local okS, isSec = pcall(issecretvalue, v)
        if not okS or isSec then return nil end
        if v <= 0 then return nil end
        return v
    end

    local selfShort = UnitName("player")
    if selfShort then
        local selfFull = FullName("player")
        if selfFull and _cdEnd[selfFull] then
            -- Snapshot the tracked spellIds first — RebuildLocalChargeQueue
            -- nils out _cdEnd entries for fully-charged spells, and
            -- mutating a table mid-pairs() is fragile.
            local spellIds = {}
            for spellId in pairs(_cdEnd[selfFull]) do
                spellIds[#spellIds + 1] = spellId
            end
            for _, spellId in ipairs(spellIds) do
                local ourEnd = _cdEnd[selfFull] and _cdEnd[selfFull][spellId]

                -- Decide multi-charge from OUR def (always available),
                -- NOT from GetSpellCharges (which can come back tainted
                -- mid-combat). This is the key: a known multi-charge
                -- spell must ALWAYS route through the authoritative
                -- rebuild and NEVER the single-charge fallback, even
                -- when Blizzard's charge fields are momentarily secret —
                -- otherwise the fallback would clobber the queue's
                -- _cdEnd and the next OnAuraAppeared could re-inflate.
                local sdef = _spellByCastId[spellId] or _spellByAuraId[spellId]
                local isMultiCharge = sdef and GetEffectiveCharges(sdef, selfFull) > 1

                if isMultiCharge then
                    -- ── Multi-charge: NO per-tick rebuild ──
                    -- We deliberately do NOT reconcile multi-charge
                    -- spells against GetSpellCharges every tick. Doing
                    -- so rewrote the recharge timer each frame, and for
                    -- a self-refreshing spell (Fiery Brand) whose
                    -- GetSpellCharges fields are tainted/sliding during
                    -- the buff, that made the timer flicker and never
                    -- complete (stuck at 1/2 forever). The charge queue
                    -- is set once per cast in OnAuraAppeared and ticks
                    -- down monotonically; the prune loop below restores
                    -- the charge when its timer elapses. Nothing to do
                    -- here.
                elseif ourEnd and C_Spell and C_Spell.GetSpellCooldown then
                    -- ── Single-charge decrease-only sync ──
                    -- Pull our timer in when the real CD is shorter
                    -- (dynamic CDR fired) but never extend it — a
                    -- transient GCD-only return must not clobber a long CD.
                    local realStart, realDur
                    local ok, cd = pcall(C_Spell.GetSpellCooldown, spellId)
                    if ok and cd then
                        realStart = _readCleanField(cd, "startTime")
                        realDur   = _readCleanField(cd, "duration")
                        if not (realStart and realDur) then realStart, realDur = nil, nil end
                    end
                    if realStart and realDur then
                        local realEnd = realStart + realDur
                        local realRemain = realEnd - now
                        local ourRemain = ourEnd - now
                        if realRemain <= 0 then
                            _cdEnd[selfFull][spellId] = nil
                        elseif realRemain < ourRemain - 1 then
                            _cdEnd[selfFull][spellId] = realEnd
                        end
                    end
                end
            end
        end
    end

    -- Multi-charge maintenance: prune expired entries from the per-
    -- spell recharge queue and recompute _cdEnd accordingly. When the
    -- queue drops below maxCharges, at least one charge is available
    -- again and the icon should drop the "on cooldown" visual.
    for name, byId in pairs(_chargeQueue) do
        for spellId, queue in pairs(byId) do
            local pruned = false
            for i = #queue, 1, -1 do
                if queue[i] <= now then
                    table.remove(queue, i)
                    pruned = true
                end
            end
            if #queue == 0 then
                byId[spellId] = nil
                if _cdEnd[name] then _cdEnd[name][spellId] = nil end
                -- Restore ready visual on transition. Badge shows max
                -- charges (since we just fully recharged).
                local icon = _icons[name] and _icons[name][spellId]
                if icon then
                    icon:SetAlpha(1.0)
                    if icon.tex then icon.tex:SetDesaturated(false) end
                    icon.text:SetText("")
                    if icon.cd then icon.cd:Clear() end
                    SetChargeBadgeText(name, icon)
                end
            elseif pruned then
                -- Some charges became available, but more still pending.
                -- _cdEnd now points at the NEXT recharging charge so
                -- Tick continues to drive the swipe + countdown for it.
                -- Visual: keep the swipe running but brighten the icon
                -- (spell is castable again with the recovered charge).
                if _cdEnd[name] then _cdEnd[name][spellId] = queue[1] end
                local icon = _icons[name] and _icons[name][spellId]
                if icon then
                    icon:SetAlpha(1.0)
                    if icon.tex then icon.tex:SetDesaturated(false) end
                    if icon.cd then icon.cd:SetCooldown(now, queue[1] - now) end
                    SetChargeBadgeText(name, icon)
                end
            end
        end
    end

    -- Death cleanup. If any party unit is currently dead, drop every
    -- glow we're maintaining on their icons — buffs typically come
    -- off on death and the UNIT_AURA(removed) handler upstream
    -- catches that, but this is a cheap belt-and-suspenders for
    -- corner cases (resurrected with stale buff state, server delay
    -- in delivering the removed event, etc.).
    --
    -- Feign-dead exclusion: UnitIsDeadOrGhost returns true for a
    -- feigning hunter, but they're still alive and their buffs (Feign
    -- Death itself, plus any prior procs) are still active. Skip the
    -- cleanup for feigned units so the FD glow keeps pulsing until
    -- the hunter stands back up (OnUnitFlags catches that transition
    -- and ends the glow at the correct moment).
    for _, u in ipairs(PARTY_UNITS) do
        local feigning = UnitIsFeignDeath and UnitIsFeignDeath(u)
        if UnitExists(u) and UnitIsDeadOrGhost(u) and not feigning then
            local n = FullName(u)
            if n and _glowEnd[n] then
                for sid in pairs(_glowEnd[n]) do
                    local icon = _icons[n] and _icons[n][sid]
                    if icon then
                        StopGlow(icon)
                    end
                    _glowEnd[n][sid] = nil
                end
            end
        end
    end

    -- Glow expirations: when a buff's visible duration ends we
    -- transition the icon from "buff active" to "on cooldown" state.
    -- The glow gets hidden and we START the cooldown swipe at this
    -- moment — running from now to whatever's left of the total CD.
    -- That way the user sees the swipe begin exactly when the spell
    -- actually leaves combat use, instead of running the full CD time
    -- through the buff-active phase as well.
    for name, byId in pairs(_glowEnd) do
        for spellId, expireAt in pairs(byId) do
            if expireAt <= now then
                local icon = _icons[name] and _icons[name][spellId]
                if icon then
                    StopGlow(icon)
                    -- Transition into cooldown visual: start swipe.
                    -- The text gets driven by the countdown loop below
                    -- on the next tick. For multi-charge spells we
                    -- show the swipe for the next recharging charge
                    -- regardless of available count, but only dim the
                    -- icon when ALL charges are spent (the spell is
                    -- actually unusable). Partial-charge state keeps
                    -- the icon bright since the spell is still castable.
                    local cdEnd = _cdEnd[name] and _cdEnd[name][spellId]
                    if cdEnd and cdEnd > now then
                        local rem = cdEnd - now
                        if icon.cd then icon.cd:SetCooldown(now, rem) end
                        local def = icon._def
                        if not IsMultiChargePartial(name, def) and GetCdGrayout() then
                            if icon.tex then icon.tex:SetDesaturated(true) end
                            icon:SetAlpha(0.65)
                        end
                    end
                end
                byId[spellId] = nil
            end
        end
    end

    for name, byId in pairs(_cdEnd) do
        local icons = _icons[name]
        for spellId, cdEndAt in pairs(byId) do
            local icon = icons and icons[spellId]
            local rem = cdEndAt - now
            if rem <= 0 then
                -- Spell ready: opaque icon, clear the text + cooldown swipe.
                -- Icons remain visible (always-visible mode) so the user
                -- can see what every party member CAN potentially cast,
                -- not just what's currently on CD. After a long ready
                -- window we drop the state from _cdEnd to keep memory
                -- bounded, but the icon stays Shown — RebuildAnchors
                -- maintains it as part of the per-class spell row.
                if icon then
                    icon:SetAlpha(1.0)
                    icon.tex:SetDesaturated(false)
                    icon.text:SetText("")
                    if icon.cd then icon.cd:Clear() end
                end
                if rem < -300 then byId[spellId] = nil end
            else
                -- Two phases on this branch — same icon, different text:
                --
                --   1) Glow active (now < glowEnd): the user-facing
                --      Show-Glow-Countdown toggle decides what runs
                --      here. ON  → render BUFF-remaining seconds
                --      (glowEnd - now), so the user sees how much
                --      duration is left on the active buff. OFF →
                --      suppress text so the glow alone conveys "spell
                --      is doing something" (the original behaviour).
                --
                --   2) Glow expired (now >= glowEnd, but spell still
                --      on cooldown): always render the post-glow
                --      cooldown countdown — unaffected by the toggle.
                if icon then
                    local glowEnd = _glowEnd[name] and _glowEnd[name][spellId]
                    if glowEnd and glowEnd > now then
                        if GetShowGlowCountdown() then
                            icon.text:SetText(FormatRemaining(glowEnd - now))
                        else
                            icon.text:SetText("")
                        end
                    else
                        icon.text:SetText(FormatRemaining(rem))
                    end
                end
            end
        end
    end
    _profStop(_p, _t0)
end

------------------------------------------------------------
-- Taint-safe aura → spell lookup.
--
-- In 12.0.5, the `spellId` field of an AuraData payload for PARTY
-- members is a "secret value". Direct table indexing with a secret
-- key throws "attempted to index a table that cannot be indexed
-- with secret keys", which would crash this handler on every
-- UNIT_AURA tick once a teammate gains any aura at all.
--
-- We delegate to BIT.Taint:ResolveNumber() (defined in Core/Core.lua).
-- That helper's heavyweight path uses a hidden Slider widget — pushing
-- the tainted value through its OnValueChanged callback runs in C++
-- context, where the secret-value mark is stripped, and the captured
-- result comes back as a fresh untainted Lua number safe to use as a
-- table key. Cheap paths (direct check + string.format → tonumber
-- round-trip) run first so the slider is only invoked when those fail.
--
-- Fast path inline: try the direct lookup first. For own-character
-- auras (and any non-secret spell IDs) the indexing succeeds without
-- the laundry, so the heavyweight path runs only when the engine
-- actually serves a tainted ID.
------------------------------------------------------------
-- Local inline-laundry. We've observed that the verbose `tostring`
-- print path succeeds on tainted spellId/icon values where
-- BIT.Taint:ResolveNumber returns nil (its string.format and
-- hidden-Slider paths fail in some 12.x contexts). This helper
-- adds a tostring→tonumber laundry as a first attempt before
-- falling back to ResolveNumber. The resulting integer is a fresh
-- Lua literal — verified clean via the table-index probe, so
-- subsequent indexing into our lookup tables can't throw.
local function _inlineLaundry(raw)
    if raw == nil then return nil end
    if type(raw) == "number" then
        local ok = pcall(function() local _ = ({[raw]=1})[raw] end)
        if ok then return raw end  -- already clean
    end
    -- tostring → tonumber laundry (often works when string.format doesn't)
    local okT, s = pcall(tostring, raw)
    if okT and s then
        local n = tonumber(s)
        if n then
            local okI = pcall(function() local _ = ({[n]=1})[n] end)
            if okI then return n end
        end
    end
    -- Last resort: BIT.Taint:ResolveNumber (slider trick).
    if BIT.Taint and BIT.Taint.ResolveNumber then
        return BIT.Taint:ResolveNumber(raw)
    end
    return nil
end

-- Byte-level taint scrubber. Built specifically for 12.0.5 M+ encounters
-- where the "secret value" taint propagates through tostring AND tonumber
-- (the freshly tonumber'd value is still secret-tagged and throws on
-- table index). Diagnostic logs confirmed even the string-equality `==`
-- path doesn't match content-equal tainted-vs-clean strings.
--
-- The trick: `string.byte(taintedStr, i)` returns each byte as a number.
-- Bytes themselves are not subject to the secret-value tracking — Blizzard
-- has no privacy reason to wrap individual character codes. We extract
-- the ASCII digits, manually reconstruct the integer via standard
-- arithmetic on fresh Lua numbers, and probe the result for clean
-- table-index usability. If it passes the probe, we have a clean number
-- recovered from a fully-tainted source.
--
-- Returns the clean number or nil. Skips silently on any error.
local function _scrubViaBytes(raw)
    if raw == nil then return nil end
    local okS, s = pcall(tostring, raw)
    if not okS or not s then return nil end

    -- IMPORTANT: do NOT use `#s` or any length operator on `s` —
    -- the `__len` metamethod is one of the operations 12.0.5's
    -- taint system blocks on a secret string, throwing
    -- "attempt to get length of a secret string value" even
    -- inside pcall. Instead, iterate a hard-bounded clean range
    -- and rely on string.byte returning nil past the string's
    -- end (its index argument is a clean number; out-of-range
    -- doesn't throw, it returns nil).
    --
    -- Hard bound 20: largest known WoW spellId is 8 digits,
    -- texture file IDs reach 10. 20 leaves headroom.
    local n = 0
    local hasDigit = false
    for i = 1, 20 do
        local okB, b = pcall(string.byte, s, i)
        if not okB then return nil end
        if not b then break end  -- past end of string
        if b >= 48 and b <= 57 then  -- '0' through '9'
            n = n * 10 + (b - 48)
            hasDigit = true
        elseif b == 46 then  -- '.' decimal point
            break  -- ignore fractional part (spell IDs are always integer)
        elseif b == 45 and not hasDigit then  -- leading '-' sign
            return nil  -- WoW spell IDs are never negative
        else
            return nil  -- unexpected non-digit character
        end
    end
    if not hasDigit then return nil end

    -- Verify the rebuilt number is clean (table-index probe).
    local okP = pcall(function() local _ = ({[n]=1})[n] end)
    if okP then return n end
    return nil
end

-- Classification fallback: when spellId + icon both arrive tainted,
-- identify the spell via:
--   1. C_UnitAuras.IsAuraFilteredOutByInstanceID — clean boolean
--      probe for Blizzard's category filters (BIG_DEFENSIVE,
--      EXTERNAL_DEFENSIVE, IMPORTANT). aura.auraInstanceID is
--      always clean so this call can't be poisoned.
--   2. C_UnitAuras.GetAuraDuration(unit, instId) — sometimes returns
--      a clean number, must type-check and screen via issecretvalue.
--   3. Walk our DB's entries for this unit's class+spec, match
--      by category + duration. If exactly one candidate fits,
--      we have an unambiguous identification.
--
-- Returns the matched def or nil. Skips silently if any input is
-- missing (e.g. no instanceID, no class data yet).

------------------------------------------------------------
-- DEFERRED INFERENCE for flag-twin disambiguation.
--
-- When 12.0.5 hides BOTH the caster's clean cast event AND the
-- aura's clean duration (party-member auras in M+ encounters),
-- spells with identical Blizzard flag patterns can't be told
-- apart at the moment of buff application. Examples:
--   PRIEST B-I = Dispersion (6s) vs Desperate Prayer (10s)
--   PAL  B-I  = Divine Shield vs Divine Protection (the
--               Forbearance disambiguator handles this; here
--               we focus on the no-Forbearance cases)
--
-- The technique: commit a TENTATIVE attribution to one candidate
-- (the one most-frequently used, heuristic: lowest CD), then
-- measure the actual buff lifetime by clocking from the
-- UNIT_AURA "added" event to the UNIT_AURA "removed" event for
-- the same instanceID. Both endpoints use only clean instance
-- IDs and GetTime() — no tainted aura.duration access required.
--
-- Post-hoc: compare the observed lifetime against each
-- candidate's nominal duration. The one with the smallest
-- absolute difference wins. If that's not the tentative we
-- committed, swap the cooldown attribution: clear the wrong
-- spell's CD entry, set the right one's CD entry as if it had
-- been cast at the original firstSeenAt timestamp.
--
-- Glow/visuals during the buff-active phase use the tentative.
-- Ten times out of twenty the tentative is correct; the other
-- times the wrong icon glows for the buff's duration and then
-- the right CD swipe appears — better than no tracking at all.
------------------------------------------------------------
-- Keyed by unit token → instId → record. Records are removed
-- on aura-remove event or on timer timeout.
local _durationProbes = {}

-- Register a tentative attribution for later disambiguation via
-- observed buff lifetime. Caller must have already committed the
-- tentative def via OnAuraAppeared so the icon glows during the
-- active phase. We only schedule the resolver for SELF-CAST
-- ambiguous matches — for target-cast spells the caster isn't
-- the unit the buff is on and the CD bookkeeping is more involved.
local function _queueDurationProbe(unit, instId, candidates, tentative)
    if not unit or not instId or not tentative then return end
    local name = FullName(unit)
    if not name then return end

    _durationProbes[unit] = _durationProbes[unit] or {}
    _durationProbes[unit][instId] = {
        unit         = unit,
        instId       = instId,
        firstSeenAt  = GetTime(),
        possibleDefs = candidates,
        committedDef = tentative,
        casterName   = name,
    }

    -- Schedule timeout in case the UNIT_AURA(remove) event never
    -- fires (loading screen, etc.). 1.5s past the longest nominal
    -- duration is a safe upper bound for cancel-early cases too.
    local maxDur = 0
    for _, def in ipairs(candidates) do
        if def.dur and def.dur > maxDur then maxDur = def.dur end
    end
    C_Timer.After((maxDur > 0 and maxDur or 10) + 1.5, function()
        if _durationProbes[unit] and _durationProbes[unit][instId] then
            _finalizeDurationProbe(unit, instId, "timeout")
        end
    end)
end

-- Reverse the tentative CD attribution and apply the correct one.
-- Both spells are self-cast on the same caster, so they share the
-- _cdEnd[name] sub-table and _icons[name] sub-table. We just swap
-- the keys.
local function _reassignAttribution(record, oldDef, newDef)
    local name = record.casterName
    if not name then return end

    -- Tear down old CD bookkeeping. The tentative attribution turned
    -- out to be wrong, so clear it completely. For a multi-charge
    -- oldDef the tentative commit also pushed a serial-recharge queue
    -- entry — pop the newest one (queue is sorted, newest push is the
    -- last element) so a genuine recharge from an earlier real cast
    -- survives the reversal. Only touched when the last commit stamp
    -- matches this very aura's appearance; otherwise the queue state
    -- belongs to older casts. The commit stamps themselves are cleared
    -- too, so the reversed commit can't poison the twin resolver's
    -- CD-sanity check or the same-instance dedup guard afterwards.
    if _chargeQueue[name] and _chargeQueue[name][oldDef.spellId] then
        local lastAt = _lastCommitAt[name] and _lastCommitAt[name][oldDef.spellId]
        if lastAt and math.abs(lastAt - record.firstSeenAt) <= 2 then
            local q = _chargeQueue[name][oldDef.spellId]
            table.remove(q)
            if #q == 0 then _chargeQueue[name][oldDef.spellId] = nil end
        end
    end
    if _cdEnd[name] then
        local q = _chargeQueue[name] and _chargeQueue[name][oldDef.spellId]
        _cdEnd[name][oldDef.spellId] = q and q[1] or nil
    end
    if _lastCommitAt[name]   then _lastCommitAt[name][oldDef.spellId]   = nil end
    if _lastCommitInst[name] then _lastCommitInst[name][oldDef.spellId] = nil end
    -- Reset OLD icon to a fully-ready visual: the spell wasn't
    -- actually cast, so anything we'd shown on it (glow, dim, swipe,
    -- countdown, charge badge) needs to go back to the clean "ready"
    -- state — not a halfway "faded" look that reads as "still on CD".
    if _icons[name] and _icons[name][oldDef.spellId] then
        local icon = _icons[name][oldDef.spellId]
        icon:SetAlpha(1.0)
        if icon.tex  then icon.tex:SetDesaturated(false) end
        icon.text:SetText("")
        if icon.cd   then icon.cd:Clear()                end
        StopGlow(icon)
        SetChargeBadgeText(name, icon)
    end

    -- Disabled-newDef guard. When the observed duration matched a
    -- disabled flag-twin (e.g. eager-BoF tentative + Pala AW silently
    -- fired without a cast event, observed dur ≈ AW.dur=20s), the
    -- correct action is to STOP at the tear-down step — never commit
    -- a CD for the disabled def because we know we can't track it
    -- reliably. The old icon (BoF) is already cleared above; just
    -- return so the disabled def doesn't get a new CD/icon state.
    if newDef.disabled then
        if _lastInst[name] then
            _lastInst[name][oldDef.spellId] = nil
        end
        _stats.attributionReassigns = (_stats.attributionReassigns or 0) + 1
        return
    end

    -- Apply correct CD as if the new def was cast at firstSeenAt.
    -- Multi-charge defs route through the same serial-recharge queue
    -- semantics as a live commit (purge expired, push, clamp, cap) —
    -- a bare _cdEnd write would leave the charge badge one count high
    -- and desync the recharge model from the queue (live report:
    -- second Ice Cold charge tentatively attributed to its flag-twin;
    -- the probe swap then showed 1 charge instead of 0).
    local effectiveCD = GetEffectiveCD(newDef, name)
    local effectiveCharges = GetEffectiveCharges(newDef, name)
    _cdEnd[name] = _cdEnd[name] or {}
    if effectiveCharges > 1 then
        _chargeQueue[name] = _chargeQueue[name] or {}
        local queue = _chargeQueue[name][newDef.spellId] or {}
        local nowQ = GetTime()
        for i = #queue, 1, -1 do
            if queue[i] <= nowQ then table.remove(queue, i) end
        end
        local latestEnd = 0
        for _, t in ipairs(queue) do
            if t > latestEnd then latestEnd = t end
        end
        local newEnd = math.max(latestEnd + effectiveCD, record.firstSeenAt + effectiveCD)
        local maxEnd = record.firstSeenAt + effectiveCD * effectiveCharges
        if newEnd > maxEnd then newEnd = maxEnd end
        table.insert(queue, newEnd)
        table.sort(queue)
        while #queue > effectiveCharges do
            table.remove(queue, 1)
        end
        _chargeQueue[name][newDef.spellId] = queue
        _cdEnd[name][newDef.spellId] = queue[1]
    else
        _cdEnd[name][newDef.spellId] = record.firstSeenAt + effectiveCD
    end
    _lastCommitAt[name] = _lastCommitAt[name] or {}
    _lastCommitAt[name][newDef.spellId] = record.firstSeenAt

    -- Show NEW icon in cooldown state (buff has already ended). Dim
    -- + desaturate only when the user wants on-CD spells grayed out;
    -- otherwise keep alpha 1.0 with just the swipe + countdown. The
    -- swipe tracks the next-ready recharge (_cdEnd), which for a
    -- multi-charge def with an older pending recharge is that OLDER
    -- entry — not necessarily this cast's own recharge.
    if _icons[name] and _icons[name][newDef.spellId] then
        local icon = _icons[name][newDef.spellId]
        local now = GetTime()
        local cdEndAt = _cdEnd[name][newDef.spellId]
        local rem = cdEndAt - now
        if rem > 0 then
            icon:Show()
            if icon.cd then icon.cd:SetCooldown(cdEndAt - effectiveCD, effectiveCD) end
            StopGlow(icon)
            if GetCdGrayout() then
                if icon.tex then icon.tex:SetDesaturated(true) end
                icon:SetAlpha(0.65)
            else
                if icon.tex then icon.tex:SetDesaturated(false) end
                icon:SetAlpha(1.0)
            end
            SetChargeBadgeText(name, icon)
        end
    end

    -- Update the per-caster instanceID tracking so subsequent
    -- ScanUnitAuras passes dedup correctly.
    if _lastInst[name] then
        _lastInst[name][oldDef.spellId] = nil
        _lastInst[name][newDef.spellId] = record.instId
    end

    _stats.attributionReassigns = (_stats.attributionReassigns or 0) + 1
end

-- Called from UNIT_AURA(removed) or from the timeout C_Timer.
-- Measures observed lifetime, picks the best-match candidate,
-- and swaps if needed.
function _finalizeDurationProbe(unit, instId, reason)
    local list = _durationProbes[unit]
    if not list then return end
    local record = list[instId]
    if not record then return end
    list[instId] = nil

    local observedDur
    if reason == "removed" then
        observedDur = GetTime() - record.firstSeenAt
    elseif reason == "timeout" then
        -- Probe whether the aura is still alive past max nominal
        -- duration. If yes, must be the longest-duration candidate.
        local okA, freshData = pcall(C_UnitAuras.GetAuraDataByAuraInstanceID, unit, instId)
        if okA and freshData then
            local longest = record.committedDef
            for _, def in ipairs(record.possibleDefs) do
                if (def.dur or 0) > (longest.dur or 0) then longest = def end
            end
            if longest ~= record.committedDef then
                _reassignAttribution(record, record.committedDef, longest)
            end
            return
        end
        observedDur = GetTime() - record.firstSeenAt
    end

    local bestDef = record.committedDef
    local bestDiff = math.huge
    for _, def in ipairs(record.possibleDefs) do
        if def.dur then
            local diff = math.abs(def.dur - observedDur)
            if diff < bestDiff then
                bestDiff = diff
                bestDef = def
            end
        end
    end

    -- 1.5s tolerance covers cancel-early (e.g. Dispersion ended
    -- by the player pressing the button again) and event-delivery
    -- delays. Outside tolerance, leave the tentative as-is rather
    -- than guess wrong.
    if bestDef and bestDef ~= record.committedDef and bestDiff < 1.5 then
        _reassignAttribution(record, record.committedDef, bestDef)
    end
end

-- Shared group-spec cache. ScanUnitAuras builds it once per scan and
-- MatchAuraByClassification reads from it instead of rebuilding the
-- party-wide UnitClassFile/FullName/GetSpecForName scan on every
-- classify call. Live profile data showed 1.66M classify calls in 30
-- minutes, ~5.5 per scan, with the seenSpec build dominating the
-- per-call cost — caching reduces classify avg from ~34µs toward the
-- ~10-15µs floor of the actual flag-probe work.
--
-- Set by ScanUnitAuras (and cleared at its end); read by
-- MatchAuraByClassification when present. When MatchAuraByClassification
-- is called outside an active scan (shouldn't happen in current
-- code, but kept defensive) the local-build path still works.
local _seenSpecCache, _seenSpeclessCache

local function _buildGroupSpecCache()
    local seenSpec, seenSpecless = {}, {}
    for _, u in ipairs(PARTY_UNITS) do
        if UnitExists(u) then
            local ucls = UnitClassFile(u)
            local uname = FullName(u)
            local uspec = uname and GetSpecForName(uname) or nil
            if ucls then
                if uspec then
                    seenSpec[ucls] = seenSpec[ucls] or {}
                    seenSpec[ucls][uspec] = true
                else
                    seenSpecless[ucls] = true
                end
            end
        end
    end
    return seenSpec, seenSpecless
end

-- ─────────────────────────────────────────────────────────────────────
-- Runtime IMPORTANT-flag reliability.
--
-- The per-instance probe C_UnitAuras.IsAuraFilteredOutByInstanceID still
-- reports BIG_DEFENSIVE / EXTERNAL_DEFENSIVE / RAID accurately, but in current
-- retail its IMPORTANT result is stuck: every helpful aura now "matches"
-- HELPFUL|IMPORTANT, so the flag carries no information at runtime. Trusting it
-- produced two failures:
--   1. Ordinary raid / utility buffs (food, intellect, flask, …) read as
--      IMPORTANT and got attributed to offensive defs that share the IMPORTANT
--      flag → random glows on every class.
--   2. A defensive whose live buff is genuinely not-IMPORTANT (key "B---") no
--      longer equalled the runtime key ("B-I-") and stopped matching.
--
-- While this is false we therefore (a) ignore the IMPORTANT position when
-- comparing flag keys, and (b) refuse to commit an IMPORTANT-only attribution
-- (no BIG, no EXTERNAL) from the heuristic narrowers — such auras may only be
-- resolved by the corroborated paths (a recent matching cast event). Flip to
-- true if a future build restores a discriminating IMPORTANT result.
local IMPORTANT_FILTER_RELIABLE = false

-- Flag-key equality honouring IMPORTANT_FILTER_RELIABLE. Positions are
-- B(1) E(2) I(3) R(4); while the IMPORTANT probe is unreliable we compare the
-- BIG / EXTERNAL / RAID positions only and treat the IMPORTANT bit as a
-- wildcard.
local function _flagKeyMatch(defKey, auraKey)
    if not defKey or not auraKey then return false end
    if IMPORTANT_FILTER_RELIABLE then
        return defKey == auraKey
    end
    return defKey:sub(1, 2) == auraKey:sub(1, 2)
       and defKey:sub(4)    == auraKey:sub(4)
end

local function MatchAuraByClassification(unit, aura)
    if not unit or not aura then return nil end
    local instId = aura.auraInstanceID
    if not instId then return nil end

    local class = UnitClassFile(unit)
    if not class then return nil end
    local name = FullName(unit)
    local memberSpec = name and GetSpecForName(name) or nil

    -- Group spec map: use scan-level cache when available, otherwise
    -- build locally. The cache lifecycle is tied to ScanUnitAuras.
    local seenSpec, seenSpecless
    if _seenSpecCache then
        seenSpec, seenSpecless = _seenSpecCache, _seenSpeclessCache
    else
        seenSpec, seenSpecless = _buildGroupSpecCache()
    end
    local function groupAdmitsClassDef(cls, def)
        if def.spec == nil then
            return seenSpec[cls] ~= nil or seenSpecless[cls] == true
        end
        if seenSpec[cls] then
            if type(def.spec) == "number" then
                return seenSpec[cls][def.spec] == true
            elseif type(def.spec) == "table" then
                for _, s in ipairs(def.spec) do
                    if seenSpec[cls][s] then return true end
                end
            end
        end
        if seenSpecless[cls] then return true end
        return false
    end

    -- TOP-PRIORITY SALVAGE: pre-classification recent-cast check.
    -- If a clean UNIT_SPELLCAST_SUCCEEDED arrived in the last 2s
    -- FROM THIS SAME UNIT, and uniquely identifies a group-admitted
    -- def, return it immediately. This path saves us when both
    -- spellId AND icon on the aura are tainted (so fast / texture
    -- lookup fails) AND IsAuraFilteredOutByInstanceID also can't
    -- classify the aura properly (so the flag-key path below
    -- returns no candidates). The cast event's spellID is the
    -- cleanest signal left, and we trust it for the full 2-second
    -- window.
    --
    -- IMPORTANT: cast.unit == unit is required. Without it, a
    -- recent Avenging Wrath cast on party1 would attribute itself
    -- to a Last Stand aura on party3 in a 5-man group — the salvage
    -- can't tell them apart by spellId alone since both buckets
    -- accept multiple admitted classes. Two-man groups rarely
    -- exposed this because only one caster's events were in flight
    -- at any time.
    do
        local now = GetTime()
        local hits = {}
        for sid, cast in pairs(_recentCasts) do
            if (now - cast.time) <= 2 then
                -- Find the def for this spellId
                local def
                for _, d in ipairs(SPELL_DEFS) do
                    if d.spellId == sid then def = d; break end
                end
                if def then
                    -- Unit pairing rule:
                    --   affects="self"   → aura is on the caster, so
                    --                       cast.unit MUST equal unit.
                    --   affects="target" → aura is on the target (this
                    --                       unit) and caster is another
                    --                       party slot. cast.unit may be
                    --                       anyone in the party.
                    -- Without this guard, in 5-man groups a recent
                    -- self-cast on party1 (e.g. Avenging Wrath) would
                    -- match against an unrelated self-cast aura on
                    -- party3 (e.g. Last Stand) because both have
                    -- def.class admitted by the current group.
                    local unitOK
                    if def.affects == "self" then
                        unitOK = (cast.unit == unit)
                    elseif def.affects == "target" then
                        unitOK = true
                    else
                        unitOK = false
                    end

                    if unitOK then
                        local admit = false
                        if def.race then
                            local _, ur = UnitRace(unit)
                            if ur == def.race then admit = true end
                        elseif def.class then
                            admit = groupAdmitsClassDef(def.class, def)
                        end
                        if admit then hits[#hits + 1] = def end
                    end
                end
            end
        end
        if #hits == 1 then
            -- aura.spellId cross-check. This salvage returns the lone
            -- recent-cast spell WITHOUT having verified that the aura
            -- we're classifying actually belongs to it. That's wrong
            -- under an event-order race: when a player casts spell B
            -- within ~2s of spell A, and B's UNIT_AURA arrives BEFORE
            -- B's UNIT_SPELLCAST_SUCCEEDED, then at scan time only A is
            -- in _recentCasts — so the salvage hands B's aura the A
            -- attribution (live-observed: casting Aspect of the Turtle
            -- or Feign Death inside Survival of the Fittest's first 2s
            -- silently committed a phantom SotF charge).
            --
            -- Guard: if the aura's own spellId reads clean and does NOT
            -- match the lone hit, this aura is NOT that spell — reject
            -- the salvage and fall through to normal classification.
            -- When spellId is unreadable (party-member taint in 12.x)
            -- we keep the original trust-the-recent-cast behaviour.
            local accept = true
            local okSid, sid = pcall(function() return aura.spellId end)
            if okSid and type(sid) == "number" then
                local okSec, isSec = pcall(issecretvalue, sid)
                if okSec and not isSec then
                    if hits[1].spellId ~= sid and hits[1].auraId ~= sid then
                        accept = false
                    end
                end
            end
            if accept then
                -- Same disabled-def guard. Even if a clean cast event
                -- uniquely identifies a disabled def, we return nil so
                -- no icon glow lands on it.
                if hits[1].disabled then return nil end
                return hits[1]
            end
        end
    end

    -- Classification probes — Blizzard's filter strings return
    -- inverse booleans (true = filtered OUT, false = matches).
    local function matches(filter)
        local ok, filtered = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID, unit, instId, filter)
        return ok and (filtered == false)
    end
    local isBig   = matches("HELPFUL|BIG_DEFENSIVE")
    local isExt   = matches("HELPFUL|EXTERNAL_DEFENSIVE")
    local isImp   = matches("HELPFUL|IMPORTANT")
    local isRaid  = matches("HELPFUL|RAID")
    if not (isBig or isExt or isImp) then
        -- No flag-key path can match. Recent-cast already ran and
        -- didn't uniquely resolve, so give up rather than guess.
        -- (R-only auras without any B/E/I are not in our DB; defaulting
        -- to the same early-return as before keeps the noise low.)
        return nil
    end

    -- Duration read via `C_UnitAuras.GetAuraDuration`. We must
    -- type-check the return — 12.0.5 sometimes returns a userdata
    -- wrapper for "secret-tagged durations". And we must also screen
    -- for secret-tagged numbers via `issecretvalue` BEFORE using the
    -- value in any comparison: tainted-vs-clean number comparisons
    -- throw `attempt to compare a secret number value` and the throw
    -- escapes pcall through the player error frame.
    --
    -- We deliberately do NOT fall through to `GetAuraDataByAuraInstanceID.duration`:
    -- reading the .duration field of that struct propagates taint into
    -- our execution context (live diagnostic: even with pcall, the
    -- subsequent comparison still throws "while execution tainted by …").
    --
    -- When the duration is unreadable, the classification continues
    -- without duration narrowing. Flag-twin ambiguity (e.g. Shadow
    -- Priest's Dispersion + Desperate Prayer both being B-I) is then
    -- carried into the candidate set and either resolved by other
    -- disambiguators (CD state, Forbearance, recent cast) or returns
    -- nil if still ambiguous.
    local cleanDur
    local okD, d = pcall(C_UnitAuras.GetAuraDuration, unit, instId)
    if okD and type(d) == "number" then
        local okS, isSec = pcall(issecretvalue, d)
        if okS and not isSec and d > 0 then
            cleanDur = d
        end
    end

    -- Build the aura's flag key — 4-char encoding matching def._auraFlagKey.
    -- This is the PRIMARY disambiguator: defs whose Blizzard flag
    -- pattern doesn't match the aura's flag pattern can't be this
    -- spell. With this filter, BoP cast (B+E, no I) only matches
    -- defs that are themselves [BE--], not [B-I-] or [BEI-] etc.
    -- The 4th R bit distinguishes Blessing of Freedom (--IR) from
    -- other spells that share Blizzard's IMPORTANT flag but lack the
    -- RAID classification (Voidform/Avatar/Metamorphosis Veng = "--I-").
    local auraFlagKey =
        (isBig and "B" or "-") ..
        (isExt and "E" or "-") ..
        (isImp and "I" or "-") ..
        (isRaid and "R" or "-")

    -- (seenSpec/seenSpecless and groupAdmitsClassDef are already
    -- built up-front near the top of MatchAuraByClassification for
    -- the recent-cast salvage pass; we reuse them here.)
    local function groupAdmits(cls, def)
        return groupAdmitsClassDef(cls, def)
    end

    -- Build two candidate buckets (target-cast vs self-cast) per
    -- flag-key match. For EXT/BIG we know which bucket applies up
    -- front. For pure IMPORTANT auras (no BIG, no EXT) we don't,
    -- so we tally both and pick whichever ends up uniquely
    -- identifying a single spell.
    local targetCands, selfCands = {}, {}
    for _, classDefs in pairs(_spellsByClass) do
        for _, def in ipairs(classDefs) do
            if _flagKeyMatch(def._auraFlagKey, auraFlagKey) and groupAdmits(def.class, def) then
                if def.affects == "target" then
                    targetCands[#targetCands + 1] = def
                else
                    selfCands[#selfCands + 1] = def
                end
            end
        end
    end

    -- Race-only defs (Shadowmeld) live in _spellsByRace, not
    -- _spellsByClass. Walk them too if the unit's race matches AND
    -- the racial's flag-key matches the aura (most racials are
    -- "---", which only enters this path when the recent-cast
    -- correlation below salvages it anyway).
    local _, unitRace = UnitRace(unit)
    if unitRace and _spellsByRace[unitRace] then
        for _, def in ipairs(_spellsByRace[unitRace]) do
            if _flagKeyMatch(def._auraFlagKey, auraFlagKey) then
                if def.affects == "target" then
                    targetCands[#targetCands + 1] = def
                else
                    selfCands[#selfCands + 1] = def
                end
            end
        end
    end

    -- PER-UNIT NARROWING for self-cast candidates. For a self-cast spell
    -- the aura is ON the caster, so the unit's class+spec must match the
    -- def. Without this, in a multi-class group, all admitted "--I" self-
    -- cast defs (e.g. Voidform from Shadow Priest, Combustion from Fire
    -- Mage, Avenging Wrath from any Pala) end up in selfCands. The
    -- IMPORTANT-bucket selection below then sees #selfCands > 1 and
    -- skips (treats as ambiguous), so a uniquely-identifiable spell like
    -- Voidform on a Shadow Priest never matches.
    --
    -- Spec unknown handling: in M+ Blizzard blocks the LibSpec addon-
    -- comm so party-member specs arrive as nil. Rejecting spec-gated
    -- defs in that state would hide every Balance Druid offensive,
    -- every Shadow Priest defensive, etc. — exactly the spells we
    -- most want to track. So when memberSpec is nil we leave specOK
    -- true (optimistic match), letting the duration probe / cast
    -- correlation / class-only narrowing do the disambiguation later.
    -- This mirrors how groupAdmitsClassDef treats unknown-spec class
    -- members via the `seenSpecless` bucket.
    --
    -- Talent / replacedBy handling: when memberTalents IS known, we
    -- mirror SpellsForMember's filter so the candidate pool reflects
    -- the live talent loadout. Critical for flag-twin replacement
    -- pairs like Balance Druid's Celestial Alignment ↔ Chosen of Elune:
    -- without this filter the deferred-inference tentative could land
    -- on CA (the replaced base) even though CA is hidden by the talent
    -- — the glow then has no icon to attach to and the user sees
    -- nothing. With the filter, CA is out of the pool when memberTalents
    -- [102560] is true → CoE is the sole candidate → tentative is correct
    -- from the first commit. With memberTalents unknown (party member
    -- in M+ no-comm), the filter stays permissive so both options can
    -- enter the duration-probe disambiguation.
    --
    -- The narrowing keeps:
    --   - Defs whose def.class matches the unit's class
    --   - Defs whose def.spec matches the unit's spec, OR memberSpec
    --     is nil (spec unknown — don't reject)
    --   - Defs not hidden by a known `replacedBy` talent
    --   - Defs whose `talent` gate passes (or is unknown — optimistic)
    --   - Class-less race-only defs (def.class==nil — Shadowmeld etc.)
    do
        local memberClassUnit = class  -- the class of the unit the aura is on
        local memberTalents = name and GetKnownTalentsForName(name) or nil
        local talentsKnown  = memberTalents ~= nil
        local narrowedSelf = {}
        for _, def in ipairs(selfCands) do
            local classOK = (def.class == nil) or (def.class == memberClassUnit)
            local specOK
            if def.spec == nil then
                specOK = true
            elseif memberSpec == nil then
                specOK = true
            elseif type(def.spec) == "number" then
                specOK = (def.spec == memberSpec)
            elseif type(def.spec) == "table" then
                for _, s in ipairs(def.spec) do
                    if s == memberSpec then specOK = true; break end
                end
            end
            -- replacedBy: drop the base entry when the caster has picked
            -- the replacement talent (mirror of SpellsForMember's filter).
            local replacedOut = def.replacedBy and talentsKnown
                                and memberTalents[def.replacedBy]
            -- talent gate: required talent must be present when known.
            local talentOK
            if def.talent == nil then
                talentOK = true
            elseif not talentsKnown then
                talentOK = true  -- optimistic when loadout unknown
            elseif memberTalents[def.talent] then
                talentOK = true
            end
            if classOK and specOK and not replacedOut and talentOK then
                narrowedSelf[#narrowedSelf + 1] = def
            end
        end
        selfCands = narrowedSelf
    end

    -- PER-CLASS NARROWING for target-cast candidates (mirror of the
    -- self-cast narrowing above, but keyed on the potential CASTERS
    -- rather than the unit carrying the buff). A target-cast def can
    -- only be the match when SOME living member of its class could
    -- actually have cast it right now:
    --   * Talent gate: every member of the def's class has a KNOWN
    --     loadout and none picked the required talent → impossible.
    --     Unknown loadouts stay optimistic. Without this, talent-gated
    --     externals (Roar of Sacrifice) injected phantom ambiguity that
    --     silently killed real detections — live report: Druid Ironbark
    --     only tracked intermittently, failing whenever another
    --     external-capable class was in the group.
    --   * Cooldown gate: every class member is modeled with the spell
    --     fully spent (single-charge on CD / all charges recharging) →
    --     nobody could have cast it. A commit within the last 3s counts
    --     as available — that IS the cast being classified (committed
    --     moments ago via the cast-event path).
    -- Fail-safe: if the narrowing would empty the pool (our model is
    -- wrong somewhere), keep the original candidates.
    if #targetCands > 1 then
        local nowTs = GetTime()
        local narrowedTarget = {}
        for _, def in ipairs(targetCands) do
            local possible = false
            for _, u in ipairs(PARTY_UNITS) do
                if UnitExists(u) and UnitClassFile(u) == def.class
                   and not UnitIsDeadOrGhost(u) then
                    local nm = FullName(u)
                    local talentOK = true
                    if def.talent and nm then
                        local talents = GetKnownTalentsForName(nm)
                        if talents and not talents[def.talent] then
                            talentOK = false
                        end
                    end
                    local cdOK = true
                    if talentOK and nm then
                        local maxCharges = GetEffectiveCharges(def, nm)
                        if maxCharges > 1 then
                            local q = _chargeQueue[nm] and _chargeQueue[nm][def.spellId]
                            local pending = 0
                            if q then
                                for _, t in ipairs(q) do
                                    if t > nowTs then pending = pending + 1 end
                                end
                            end
                            if pending >= maxCharges then cdOK = false end
                        else
                            local cdE = _cdEnd[nm] and _cdEnd[nm][def.spellId]
                            if cdE and cdE > nowTs then cdOK = false end
                        end
                        local lastAt = _lastCommitAt[nm] and _lastCommitAt[nm][def.spellId]
                        if lastAt and (nowTs - lastAt) < 3 then
                            cdOK = true   -- this very cast, just committed
                        end
                    end
                    if talentOK and cdOK then
                        possible = true
                        break
                    end
                end
            end
            if possible then
                narrowedTarget[#narrowedTarget + 1] = def
            end
        end
        if #narrowedTarget > 0 then
            targetCands = narrowedTarget
        end
    end

    -- HIGHEST-PRIORITY disambiguator: cast-event correlation. If a
    -- candidate's spellId was JUST observed via UNIT_SPELLCAST_SUCCEEDED
    -- (within the last 2s), that's our spell — don't even bother
    -- with the bucket-selection logic below. Cast spell IDs are
    -- typically clean even in M+ where aura fields are tainted,
    -- so this correlation cuts through flag-twin ambiguity.
    --
    -- Concrete: Pala casts AW → _recentCasts[31884]=NOW. Aura on
    -- pala matches [--I] flag-key. Walk target+self combined:
    -- both BoF (target, 1044) and AW (self, 31884) are candidates.
    -- 31884 is in _recentCasts → narrowed = [AW] → return AW.
    --
    -- IMPORTANT for 5-man groups: enforce unit/cast pairing.
    --   affects="self"   → cast.unit MUST == unit (caster's aura is on caster)
    --   affects="target" → cast.unit may be anyone (caster is some other
    --                      party slot; aura ends up on the target unit)
    -- Without this guard, a Pala's recent AW cast on party1 would
    -- attribute itself to a Last Stand aura on party3 (both end up
    -- in selfCands as BIG-flagged self-cast spells).
    do
        local now = GetTime()
        local hitCands = {}
        local function check(cands)
            for _, def in ipairs(cands) do
                local cast = _recentCasts[def.spellId]
                if cast and (now - cast.time) <= 2 then
                    local pairOK = false
                    if def.affects == "self" then
                        pairOK = (cast.unit == unit)
                    elseif def.affects == "target" then
                        pairOK = true
                    end
                    if pairOK then
                        hitCands[#hitCands + 1] = def
                    end
                end
            end
        end
        check(targetCands)
        check(selfCands)
        if #hitCands == 1 then
            return hitCands[1]
        end
    end

    -- Corroboration gate for IMPORTANT-only auras. With the IMPORTANT runtime
    -- flag unreliable (see IMPORTANT_FILTER_RELIABLE), an aura carrying neither
    -- BIG nor EXTERNAL can't be trusted to the heuristic narrowers below — they
    -- would light up ordinary raid / utility buffs (food, flask, intellect,
    -- trinket procs, …). The corroborated paths above (recent-cast salvage and
    -- cast-event correlation) already had their chance; if neither resolved it,
    -- don't guess.
    --
    -- KNOWN TRADE-OFF: this drops the AURA-ONLY fallback for IMPORTANT-only defs
    -- (Blessing of Freedom, Divine Shield, Spell Reflection, Alter Time,
    -- Voidform, Combustion, Celestial Alignment / Chosen of Elune, Avenging
    -- Crusader, …) in the case where the caster's UNIT_SPELLCAST_SUCCEEDED is
    -- ALSO missing / tainted (heavy M+). Those spells still glow via the cast
    -- path (OnUnitCast → OnAuraAppeared) and the two corroborated paths above
    -- whenever a clean cast event arrives — only the no-cast fallback is lost.
    --
    -- Do NOT "relax" this to commit when exactly one class+spec candidate
    -- exists: with IMPORTANT non-discriminating, a single-candidate class (e.g.
    -- a Shadow Priest whose only --I- spell is Voidform) would match an ordinary
    -- buff on that member to that lone def — the exact false-glow flood this gate
    -- exists to stop. Recovering this safely needs a REAL side-channel (an
    -- observed duration that matches a candidate, or the Forbearance harmful
    -- aura for that family), never the IMPORTANT flag alone.
    if not IMPORTANT_FILTER_RELIABLE and not isBig and not isExt then
        return nil
    end

    local candidates
    if isExt then
        -- EXT-classified aura always came from a target-cast def.
        candidates = targetCands
        -- Absorb-evidence narrowing (same side-channel the DK AMS twin
        -- resolver uses): an absorb-granting external (Life Cocoon)
        -- spikes the target's absorb in the same moment its buff lands,
        -- while BoP / Roar of Sacrifice / Time Dilation add none. When
        -- several externals stay in the pool (duration probe secret in
        -- instance combat → no narrowing → glow silently dropped) and
        -- the absorb side-channel just fired for this unit, the unique
        -- absorb-flagged candidate is the match. POSITIVE-only: absent
        -- absorb evidence changes nothing (the absorb event can lag the
        -- aura event, so its absence must never eliminate a candidate).
        if #candidates > 1 then
            local absAt = _absorbAt[unit]
            if absAt and (GetTime() - absAt) <= 1.5 then
                local absorbCands = {}
                for _, d in ipairs(candidates) do
                    if d.absorbEvidence then
                        absorbCands[#absorbCands + 1] = d
                    end
                end
                if #absorbCands == 1 then
                    candidates = absorbCands
                end
            end
        end
    elseif isBig then
        -- Pure BIG (no EXT) → self-cast major DEF on this unit.
        candidates = selfCands
    elseif isImp then
        -- IMPORTANT-only spans both layouts. Pick rules:
        --   target=1 self=0 → unique → commit target
        --   target=0 self=1 → unique → commit self
        --   target=1 self=1 → forward COMBINED to duration narrowing
        --                     so the runtime aura's duration picks
        --                     the right twin. Concrete: DH Veng casts
        --                     Meta (~15s self-buff) — target=[BoF],
        --                     self=[Meta-disabled]. Duration probe
        --                     ≈15s → Meta survives, BoF rejected →
        --                     Meta is disabled → return nil (no wrong
        --                     glow on BoF). When Pala actually casts
        --                     BoF on the DH the runtime dur ≈8s →
        --                     BoF survives, Meta rejected → commit
        --                     BoF correctly. When duration probe is
        --                     unreadable (tainted in M+) both stay
        --                     in the pool and we fall through to nil
        --                     — better no attribution than wrong.
        --   self>1 target=0 → forward to duration/CD/deferred-
        --                     inference disambiguation below. Flag-
        --                     twin pairs like Balance Druid's
        --                     Celestial Alignment vs Chosen of Elune
        --                     both land in selfCands; the duration
        --                     probe + observed-lifetime measurement
        --                     resolves which one fired.
        --   target>1 → still skip (no good disambiguator for two
        --              external target-cast buffs landing on the
        --              same unit in the same batch).
        if #targetCands == 1 and #selfCands == 0 then
            candidates = targetCands
        elseif #selfCands >= 1 and #targetCands == 0 then
            candidates = selfCands
        elseif #targetCands == 1 and #selfCands >= 1 then
            -- Combine target with ALL self candidates. The earlier
            -- 1+1-only path missed the common Pala scenario where a
            -- self-cast on the Pala (BoF target=1, AW self disabled,
            -- plus any spec-admitted self-cast --I- — though Ret/Prot
            -- spec narrowing typically leaves just AW for non-Holy
            -- Palas) creates 1+N with N>=1 — that fell into the
            -- `else` and returned candidates={} → no glow on the
            -- Pala's BoF ever, even with a clean cast. The expanded
            -- bucket lets the eager non-disabled attribution and
            -- duration-probe disambiguation below resolve it.
            candidates = { targetCands[1] }
            for _, d in ipairs(selfCands) do
                candidates[#candidates + 1] = d
            end
        else
            candidates = {}  -- target>1 → genuinely ambiguous
        end
    else
        -- No Blizzard flags at all (aura is "---"). Typically
        -- racials (Shadowmeld), Stealth-like spells (Feign Death,
        -- Vanish), or short utility buffs. Only commit when a single
        -- candidate falls out of the spec/class/race filter — the
        -- recent-cast correlation pass above would have already
        -- handled the disambiguated case by short-circuit return.
        if #targetCands == 1 and #selfCands == 0 then
            candidates = targetCands
        elseif #selfCands == 1 and #targetCands == 0 then
            candidates = selfCands
        else
            candidates = {}
        end
    end

    -- POSITIVE-ID short-circuit: if the aura's own spellId reads clean
    -- and matches one of the candidates, that IS the spell — return it
    -- before any heuristic narrowing can guess wrong. Critical for
    -- flag-twins with identical flag-key AND duration that the CD /
    -- duration narrowers can't separate: e.g. Hunter Survival of the
    -- Fittest and Aspect of the Turtle are both [B-I-] ~8s. Casting
    -- Turtle while SotF still has a charge would otherwise hit the
    -- all-self CD-narrowing below, which eliminates the just-cast
    -- Turtle (now on full CD) and keeps SotF (still has a partial
    -- charge) — silently committing a phantom SotF charge. aura.spellId
    -- cuts straight through that. Reading it can smear taint for
    -- PARTY-member auras in 12.x, so it's pcall + issecretvalue gated
    -- and only consulted when we have a genuine multi-candidate
    -- ambiguity (the common single-candidate case never reaches here).
    if #candidates > 1 then
        local okSid, sid = pcall(function() return aura.spellId end)
        if okSid and type(sid) == "number" then
            local okSec, isSec = pcall(issecretvalue, sid)
            if okSec and not isSec then
                for _, def in ipairs(candidates) do
                    if def.spellId == sid or def.auraId == sid then
                        if def.disabled then return nil end
                        _stats.classifyBySpellId = (_stats.classifyBySpellId or 0) + 1
                        return def
                    end
                end
            end
        end
    end

    -- Side-channel resolver: Survival of the Fittest (264735) vs Aspect
    -- of the Turtle (186265). Both are Hunter self-cast BIG_DEFENSIVE
    -- with overlapping ~8s durations (SotF reaches 8s with Lone
    -- Survivor), so the flag-key narrower can't separate them, the
    -- runtime aura spellId is secret for party members (the POSITIVE-ID
    -- short-circuit above already failed), and in M+ the duration is
    -- secret too — leaving the longest-duration tentative far below to
    -- default to Aspect of the Turtle (the 8s twin). That is the exact
    -- misfire reported: a Survival of the Fittest cast lighting Turtle.
    --
    -- Two NON-secret signals collected elsewhere separate the pair:
    --   * the unit's PET gained a BIG_DEFENSIVE aura (_petBigDefAt) →
    --     SotF shields the pet, Turtle never touches it → positive SotF;
    --   * the unit's combat/immune flags flipped (_immuneFlagsAt) →
    --     Turtle grants immunity, SotF does not → positive Turtle.
    --     A fresh Feign Death (_feignAt) also flips the flags, so it
    --     suppresses the Turtle inference to avoid a false match.
    --
    -- Resolution order:
    --   1. pet big-def aura present       → Survival of the Fittest
    --   2. immune flags flipped (no feign)→ Aspect of the Turtle
    --   3. no evidence + duration UNREADABLE (M+) → Survival of the
    --      Fittest. Turtle ALWAYS flips the immune flag, so the absence
    --      of that flag means the cast was NOT Turtle. This overrides
    --      only the otherwise-Turtle-defaulting tentative.
    --   4. no evidence + duration READABLE → fall through to the
    --      (reliable) duration narrower, so the normal Aspect-of-the-
    --      Turtle path is never regressed.
    if #candidates > 1 and name then
        local survivalDef, immunityDef
        for _, def in ipairs(candidates) do
            if def.spellId == 264735 then
                survivalDef = def
            elseif def.spellId == 186265 then
                immunityDef = def
            end
        end
        if survivalDef and immunityDef then
            local nowT = GetTime()
            local petAt = _petBigDefAt[unit]
            if petAt and (nowT - petAt) <= TWIN_EVIDENCE_WINDOW then
                if survivalDef.disabled then return nil end
                return survivalDef
            end

            -- CD-state sanity: a twin the model shows as fully spent
            -- cannot be this cast (commits within the last 3s are the
            -- very cast being classified and don't count). Stops the
            -- cascade where ONE swapped attribution poisons every
            -- following cast for the rest of the twin's cooldown.
            local function twinSpent(def)
                local lastAt = _lastCommitAt[name] and _lastCommitAt[name][def.spellId]
                if lastAt and (nowT - lastAt) < 3 then return false end
                local maxC = GetEffectiveCharges(def, name)
                if maxC > 1 then
                    local q = _chargeQueue[name] and _chargeQueue[name][def.spellId]
                    local pending = 0
                    if q then
                        for _, t in ipairs(q) do
                            if t > nowT then pending = pending + 1 end
                        end
                    end
                    return pending >= maxC
                end
                local cdE = _cdEnd[name] and _cdEnd[name][def.spellId]
                return (cdE and cdE > nowT) and true or false
            end
            local turtleSpent = twinSpent(immunityDef)
            local sotfSpent   = twinSpent(survivalDef)
            if turtleSpent and not sotfSpent then
                if survivalDef.disabled then return nil end
                return survivalDef
            elseif sotfSpent and not turtleSpent then
                if immunityDef.disabled then return nil end
                return immunityDef
            end

            local feignAt = _feignAt[unit]
            local feignFresh = feignAt and (nowT - feignAt) <= TWIN_EVIDENCE_WINDOW
            local flagsAt = _immuneFlagsAt[unit]
            if flagsAt and (nowT - flagsAt) <= TWIN_FLAGS_WINDOW and not feignFresh then
                if immunityDef.disabled then return nil end
                return immunityDef
            end
            -- No side-channel evidence. Turtle ALWAYS flips the immune
            -- flags, so their absence says "not Turtle":
            --   * duration unreadable (M+): default to SotF (as before);
            --   * duration readable but AMBIGUOUS between the twins —
            --     SotF matches Turtle's 8s with Lone Survivor, and with
            --     an unknown loadout both 6s and 8s are possible — the
            --     duration narrower can't split a tie and its longest-
            --     duration tentative used to hand these to Turtle: SotF.
            --   * duration readable and uniquely Turtle-like: fall
            --     through to the duration narrower (no regression).
            if not (cleanDur and cleanDur > 0) then
                if survivalDef.disabled then return nil end
                return survivalDef
            end
            local talents = GetKnownTalentsForName(name)
            local sotfDurs
            if talents then
                sotfDurs = { GetEffectiveDuration(survivalDef, name) }
            else
                -- Loadout unknown: every talent-extended duration is possible.
                sotfDurs = { survivalDef.dur or 6 }
                if survivalDef.durMods then
                    for _, delta in pairs(survivalDef.durMods) do
                        sotfDurs[#sotfDurs + 1] = (survivalDef.dur or 6) + delta
                    end
                end
            end
            local turtleDur = GetEffectiveDuration(immunityDef, name)
            local matchesTurtle = math.abs(cleanDur - turtleDur) <= 0.6
            local matchesSotf = false
            for _, d in ipairs(sotfDurs) do
                if math.abs(cleanDur - d) <= 0.6 then
                    matchesSotf = true
                    break
                end
            end
            if matchesTurtle and matchesSotf then
                if survivalDef.disabled then return nil end
                return survivalDef
            end
        end
    end

    -- Side-channel resolver: Anti-Magic Shell (48707) vs Icebound Fortitude
    -- (48792). Both are Death Knight self-cast BIG_DEFENSIVE; in M+ the aura
    -- duration is secret, so the longest-duration tentative far below
    -- defaults to Icebound (8s) — the reported misfire when AMS (5s) was the
    -- actual cast. Anti-Magic Shell applies an ABSORB shield
    -- (UNIT_ABSORB_AMOUNT_CHANGED); Icebound Fortitude never does, so a fresh
    -- absorb change on this unit positively identifies AMS. With no absorb we
    -- fall through, where the duration narrower (5 vs 8) or the tentative
    -- resolves it (→ Icebound) exactly as before — no regression.
    if #candidates > 1 and name then
        local amsDef, iceDef
        for _, def in ipairs(candidates) do
            if def.spellId == 48707 then
                amsDef = def
            elseif def.spellId == 48792 then
                iceDef = def
            end
        end
        if amsDef and iceDef then
            local isAMS = false
            -- Event-based: an absorb change fired on this unit recently.
            local absAt = _absorbAt[unit]
            if absAt and (GetTime() - absAt) <= TWIN_EVIDENCE_WINDOW then
                isAMS = true
            end
            -- Fallback poll: AMS's absorb shield is present on the unit right
            -- now. Catches event-order races and the open world (where the
            -- amount reads clean). Secret-guarded — in instances the amount
            -- may be secret, in which case we rely on the event above.
            if not isAMS and UnitGetTotalAbsorbs then
                local ok, amt = pcall(UnitGetTotalAbsorbs, unit)
                if ok and type(amt) == "number" then
                    local okSec, isSec = pcall(issecretvalue, amt)
                    if okSec and not isSec and amt > 0 then isAMS = true end
                end
            end
            if isAMS then
                if amsDef.disabled then return nil end
                return amsDef
            end
        end
    end

    -- Side-channel resolver: Touch of Karma (122470 / aura 125174) vs
    -- Fortifying Brew (115203). Both are Monk self-cast BIG_DEFENSIVE and
    -- both admit a Windwalker, so the flag-key narrower can't separate
    -- them and in M+ the duration is secret (the longest-duration
    -- tentative would default to Fortifying Brew at 15s, hiding a Touch of
    -- Karma cast — the reported "not tracked at all"). Touch of Karma
    -- applies an ABSORB shield (UNIT_ABSORB_AMOUNT_CHANGED); Fortifying
    -- Brew never does, so a fresh absorb change on this unit positively
    -- identifies Karma. With no absorb we fall through to the duration
    -- narrower (10 vs 15) / tentative exactly as before.
    if #candidates > 1 and name then
        local karmaDef, brewDef
        for _, def in ipairs(candidates) do
            if def.spellId == 122470 then
                karmaDef = def
            elseif def.spellId == 115203 then
                brewDef = def
            end
        end
        if karmaDef and brewDef then
            local isKarma = false
            local absAt = _absorbAt[unit]
            if absAt and (GetTime() - absAt) <= TWIN_EVIDENCE_WINDOW then
                isKarma = true
            end
            if not isKarma and UnitGetTotalAbsorbs then
                local ok, amt = pcall(UnitGetTotalAbsorbs, unit)
                if ok and type(amt) == "number" then
                    local okSec, isSec = pcall(issecretvalue, amt)
                    if okSec and not isSec and amt > 0 then isKarma = true end
                end
            end
            if isKarma then
                if karmaDef.disabled then return nil end
                return karmaDef
            end
        end
    end

    -- Narrow by duration if we successfully laundered it AND have
    -- multiple candidates. cleanDur is guaranteed-untainted (passed
    -- the table-index probe above), so the arithmetic comparison
    -- below is safe.
    if cleanDur and cleanDur > 0 and #candidates > 1 then
        local narrowed = {}
        for _, def in ipairs(candidates) do
            if def.dur and math.abs(def.dur - cleanDur) < 0.6 then
                narrowed[#narrowed + 1] = def
            end
        end
        if #narrowed > 0 then candidates = narrowed end
    end

    -- Self-cast-active POSITIVE identifier with per-instance gate.
    -- If a self-cast candidate's _cdEnd was just set recently enough
    -- that the spell's active aura window hasn't ended yet, AND the
    -- current aura's instance ID matches the tracked instance for
    -- that def (or no instance has been tracked yet), the buff is
    -- that self-cast def's own continuing aura.
    --
    -- The per-instance gate prevents the M+ race where: DH casts Meta
    -- (Meta's instance tracked in _lastInst), Pala casts BoF on the
    -- DH within Meta's 15s active window, BoF's NEW instance arrives.
    -- Without the gate the cdEnd-vs-now check would fire for Meta
    -- and BoF would wrongly attribute to Meta. With the gate, the
    -- instance-mismatch path skips Meta and BoF flows through to
    -- duration narrowing / regular disambiguation.
    --
    -- Catches the M+ taint scenario where party-member cast events
    -- go missing (no recent-cast salvage), aura duration is
    -- unreadable (no duration narrowing), and the flag-key matches
    -- multiple candidates.
    if #candidates > 1 and name then
        local cdState = _cdEnd[name]
        local instTrack = _lastInst[name]
        if cdState then
            local nowT = GetTime()
            for _, def in ipairs(candidates) do
                if def.affects == "self" and def.cd and def.dur then
                    local cdEnd = cdState[def.spellId]
                    if cdEnd and (cdEnd - nowT) > (def.cd - def.dur) then
                        -- Per-instance gate: if we've already tracked
                        -- an instance for this def AND the current
                        -- aura is a DIFFERENT instance, this aura is
                        -- NOT the def — it's something else with the
                        -- same flag-key arriving during the def's
                        -- active window. Skip and let other narrowers
                        -- handle it.
                        local trackedInst = instTrack and instTrack[def.spellId]
                        if not trackedInst or trackedInst == instId then
                            if def.disabled then return nil end
                            return def
                        end
                    end
                end
            end
        end
    end

    -- Narrow by active-CD state. Two spells with identical Blizzard
    -- flag patterns (e.g. Pal Divine Protection [B-I] vs Divine
    -- Shield [B-I]) can't be told apart from the aura alone, but if
    -- ONE of them is already on cooldown from a previous cast we
    -- tracked, the new cast must be the OTHER. The caster for these
    -- self-cast classifications is `name` (the unit the aura is on,
    -- since BIG/IMP self-cast auras live on the caster).
    --
    -- Multi-charge nuance: a spell whose `_cdEnd` is in the future
    -- is NOT necessarily unusable. If it has charges remaining (e.g.
    -- Hunter SotF + Padded Armor talent → 2 charges; one was used,
    -- the recharge timer is ticking, but the second charge is still
    -- castable), we must treat it as available. Otherwise the second
    -- cast gets misattributed to its flag-twin (Aspect of the Turtle
    -- in the SotF case). IsMultiChargePartial returns true exactly
    -- when 0 < pending < maxCharges — i.e. the spell is still
    -- castable right now.
    --
    -- Only applied when ALL candidates are SELF-CAST. For mixed
    -- self+target buckets, the buff unit's _cdEnd table only knows
    -- about its own self-cast CDs — target-cast defs are tracked
    -- under the caster's name elsewhere. The self-cast-active
    -- POSITIVE identifier above already handles the "self-cast is
    -- the actual buff" case directly; the elimination-style
    -- narrowing here covers the within-class flag-twin case
    -- (DP/DS, etc.) where both candidates ARE self-cast.
    if #candidates > 1 and name then
        local allSelf = true
        for _, def in ipairs(candidates) do
            if def.affects ~= "self" then allSelf = false; break end
        end
        if allSelf then
            local cdState = _cdEnd[name]
            if cdState then
                local now = GetTime()
                local available = {}
                for _, def in ipairs(candidates) do
                    local cdEnd = cdState[def.spellId]
                    local stillUsable = (not cdEnd) or cdEnd <= now
                                      or IsMultiChargePartial(name, def)
                    if stillUsable then
                        available[#available + 1] = def
                    end
                end
                if #available == 1 then candidates = available end
            end
        end
    end

    -- Final disambiguator: cast-time debuff side-effect detection.
    -- Some defensives apply a harmful aura to the recipient at cast
    -- time (Forbearance for Divine Shield / Blessing of Protection /
    -- BoSpellwarding, Hypothermia for Ice Block / Ice Cold). Their
    -- flag-twins (Divine Protection / Blessing of Sacrifice / Alter
    -- Time) don't. We use the per-unit "harmful aura added in same
    -- UNIT_AURA batch" timestamp set in OnUnitAura — if a harmful
    -- aura just arrived alongside this buff, pick the
    -- `addsDebuff=true` candidate.
    if #candidates > 1 then
        local harmfulAt = _lastHarmfulAdded[unit]
        local hadHarmful = harmfulAt and (GetTime() - harmfulAt) <= 0.6
        local narrowed = {}
        for _, def in ipairs(candidates) do
            if hadHarmful and def.addsDebuff then
                narrowed[#narrowed + 1] = def
            elseif not hadHarmful and not def.addsDebuff then
                narrowed[#narrowed + 1] = def
            end
        end
        if #narrowed > 0 then candidates = narrowed end
    end

    if #candidates == 1 then
        -- Defs marked `disabled = true` participate in the candidate
        -- pool (so they contribute to ambiguity counting and prevent
        -- wrong-glow on their flag-twins) but never get selected as
        -- the final attribution. If narrowing collapsed to a single
        -- disabled candidate, return nil — no glow on a spell we
        -- know we can't track reliably yet.
        if candidates[1].disabled then return nil end
        return candidates[1]
    end

    -- EAGER non-disabled attribution with duration-probe verification.
    --
    -- When multiple candidates remain and exactly ONE is non-disabled,
    -- attribute eagerly to that one and queue a duration probe. The
    -- disabled flag-twin(s) participate in the probe's possibleDefs so
    -- the UNIT_AURA(removed) handler can measure the actual buff lifetime
    -- and, if it matches a disabled twin instead, swap (which clears
    -- the tentative attribution without committing the disabled def).
    --
    -- Concrete: Pala self-casts BoF on themselves in 12.x where the
    -- UNIT_SPELLCAST_SUCCEEDED for party1 doesn't deliver (live-observed
    -- in open world). candidates = { BoF (target, non-disabled),
    -- AW (self, disabled) }. cleanDur is unreadable. Without this
    -- eager path the candidate pool stays at 2 forever and BoF never
    -- glows. With it, BoF glows immediately and the probe confirms at
    -- 8s when the aura ends (observedDur ≈ BoF.dur).
    --
    -- Trade-off: when the disabled twin (AW) silently fires without a
    -- cast event, BoF gets a transient wrong-glow for up to AW.dur
    -- (~20s) before the probe swap clears it. Acceptable because the
    -- alternative is permanent "BoF never glows", and AW is disabled
    -- precisely BECAUSE it has misclassification issues with its
    -- twins — surfacing it as a brief transient on the actual twin
    -- is no worse than the original tracking-confusion the disable
    -- was meant to prevent.
    if #candidates > 1 then
        local nonDisabled = {}
        for _, def in ipairs(candidates) do
            if not def.disabled then
                nonDisabled[#nonDisabled + 1] = def
            end
        end
        if #nonDisabled == 1 then
            local tentative = nonDisabled[1]
            _queueDurationProbe(unit, instId, candidates, tentative)
            return tentative
        end
    end

    -- Multiple candidates remain — flag-twin ambiguity.
    --
    -- DEFERRED-INFERENCE attribution: when every candidate is self-cast,
    -- pick a tentative attribution (heuristic: lowest nominal CD, since
    -- short-CD spells are used more often). Register the choice in
    -- `_durationProbes` and let the UNIT_AURA(removed) handler
    -- measure the actual buff lifetime to either confirm or swap the
    -- attribution post-hoc.
    --
    -- Skipped for target-cast or mixed buckets because the caster isn't
    -- the unit the buff is on, which makes CD bookkeeping more involved.
    -- For now we only handle the self-cast case (covers Shadow Priest's
    -- Dispersion + Desperate Prayer, the canonical example).
    if #candidates > 1 then
        local allSelfCast = true
        for _, def in ipairs(candidates) do
            if def.affects ~= "self" then allSelfCast = false; break end
        end
        if allSelfCast then
            -- (The aura.spellId positive-ID short-circuit that used to
            -- live here has been hoisted ABOVE the narrowing chain — it
            -- now runs right after candidate building so it can pre-empt
            -- the CD / duration narrowers, not just the final tentative
            -- guess. By the time we reach this branch the spellId was
            -- already tried and didn't resolve, so we go straight to
            -- the heuristic tentative.)

            -- Tentative selection: prefer LONGEST nominal duration,
            -- with lowest CD as a tiebreaker. Longer-duration buffs
            -- tend to be the "main" cooldowns the player is actively
            -- pressing in combat (e.g. Avatar 20s for Warriors as the
            -- standard pull buff). Shorter-duration flag-twins (e.g.
            -- Spell Reflection 8s) are reactive utility defensives
            -- cast less often. When we have no positive evidence to
            -- pick between flag-twins, biasing toward the longer-buff
            -- candidate maximises immediate-correctness rate for the
            -- common case — and the duration-probe path will still
            -- swap to the right def post-hoc if the short twin was
            -- actually the cast (observed dur ≈ short.dur → swap).
            --
            -- Previously used "lowest CD" reasoning ("short-CD spells
            -- are used more often"), but that misattributed Avatar
            -- (cd=90 dur=20) casts to Spell Reflection (cd=25 dur=8)
            -- on every pull — Avatar is functionally cast far more
            -- often than the reactive talent-gated Spell Reflection
            -- despite the higher CD.
            local function isBetter(a, b)
                local aDur, bDur = a.dur or 0, b.dur or 0
                if aDur ~= bDur then return aDur > bDur end
                return (a.cd or math.huge) < (b.cd or math.huge)
            end
            local tentative = candidates[1]
            for _, def in ipairs(candidates) do
                if isBetter(def, tentative) then
                    tentative = def
                end
            end
            -- Disabled-candidate guard: don't commit a tentative
            -- attribution to a def we know we can't track. If the
            -- top pick is disabled, walk the pool for the next best
            -- non-disabled candidate using the same isBetter ordering;
            -- if every candidate is disabled, give up and return nil.
            if tentative.disabled then
                local alt
                for _, def in ipairs(candidates) do
                    if not def.disabled and (not alt or isBetter(def, alt)) then
                        alt = def
                    end
                end
                if not alt then return nil end
                tentative = alt
            end
            _queueDurationProbe(unit, instId, candidates, tentative)
            return tentative
        end
    end

    -- LAST-RESORT salvage: class+spec exclusivity attribution.
    --
    -- Engaged only when EVERY higher-priority path has failed: tainted
    -- spellId/icon couldn't be laundered, no recent UNIT_SPELLCAST_SUCCEEDED
    -- arrived for the unit (Blizzard may suppress cast events for party
    -- members in some encounter restrictions), and the flag-key /
    -- duration / CD / Forbearance disambiguators all left either zero or
    -- multiple candidates.
    --
    -- The premise: in 12.0.5 M+ encounters, the only signal we still
    -- have on a fully-tainted aura is the unit it's on and its
    -- aura.duration (sometimes clean, sometimes not). If the unit's
    -- class+spec has exactly one off-cooldown trackable defensive
    -- whose `affects` matches the aura's flag-key bucket, that aura
    -- MUST be that spell.
    --
    -- Concrete: Brewmaster Monk has Fortifying Brew (self-cast DEF)
    -- as their only Brewmaster-spec entry in our DB. Touch of Karma
    -- is WW-only. If a helpful BIG-flagged aura appears on a Brewmaster
    -- and Brew is off CD, it's Brew.
    --
    -- Safety guards:
    --   - cat=="DEF" only (don't attribute OFF spells via this path)
    --   - The candidate's _auraFlagKey MUST match the aura's runtime
    --     flag-key (prevents attributing a target-cast aura received
    --     from another class to one of THIS class's self-cast defs)
    --   - The candidate's affects MUST match the aura's bucket
    --   - The candidate must be currently OFF cooldown for this unit
    --   - Skip if 2+ class+spec DEFs share the same flag-key bucket
    --     (we'd otherwise attribute the wrong one)
    --   - Skip if the aura is "---" (no Blizzard flags) — those are
    --     racials / utility buffs and our DB has too many ambiguous
    --     "---" entries to safely attribute.
    --   - For the player slot: skip last-resort entirely. The local
    --     player's own casts arrive via UNIT_SPELLCAST_SUCCEEDED with
    --     a clean spellId, and OnUnitCast attributes them directly
    --     against _spellByCastId — last-resort isn't needed for self-
    --     casts. For received auras (e.g. Pala casts Freedom on us)
    --     last-resort would only misattribute, so disabling it for
    --     the player slot eliminates the whole class of misattributions.
    --     `aura.isFromPlayerOrPlayerPet` proved unreliable as a guard
    --     in live 12.0.5 testing (sometimes nil/true for received auras
    --     despite the local player not being the caster), hence the
    --     blanket skip.
    if auraFlagKey ~= "---" then
        if unit == "player" then
            return nil
        end

        local memberClass = class
        local poolBucket = (isExt) and "target" or "self"

        local pool = {}
        for _, classDefs in pairs(_spellsByClass) do
            for _, def in ipairs(classDefs) do
                if def.class == memberClass
                    and def.cat == "DEF"
                    and def.affects == poolBucket
                    and _flagKeyMatch(def._auraFlagKey, auraFlagKey)
                    and groupAdmitsClassDef(def.class, def)
                then
                    -- Off-cooldown check uses the same _cdEnd table as
                    -- the regular CD narrower above.
                    local onCD = false
                    if name then
                        local cdState = _cdEnd[name]
                        if cdState then
                            local cdEnd = cdState[def.spellId]
                            if cdEnd and cdEnd > GetTime() then onCD = true end
                        end
                    end
                    if not onCD then
                        pool[#pool + 1] = def
                    end
                end
            end
        end
        if #pool == 1 then
            -- Same disabled-def guard as the higher-priority paths
            -- above: a class+spec exclusivity match to a `disabled`
            -- def doesn't count — return nil so no glow lands on a
            -- spell we know we can't track reliably yet.
            if pool[1].disabled then return nil end
            _stats.lookupLastResortHit = (_stats.lookupLastResortHit or 0) + 1
            return pool[1]
        end
    end

    -- Ambiguous match — skip rather than guess wrong.
    return nil
end

-- Caller-set unit context so SafeAuraLookup's classification
-- fallback knows which unit to query. Set before each SafeAuraLookup
-- call and cleared after (in the same call site).
local _lookupUnit = nil

local function SafeAuraLookup(aura)
    if not aura then return nil end

    -- 3.8.6 ARCHITECTURE PIVOT
    --
    -- Prior versions read `aura.spellId` and `aura.icon` and tried
    -- various laundry techniques to clean the tainted result. Every
    -- single one of those techniques failed against 12.0.5's "secret
    -- value" propagation, and worse: just READING those tainted
    -- fields smears the taint onto our addon's execution context.
    -- From that point on, every downstream operation (table reads,
    -- length operators, comparisons) throws taint errors visible
    -- in the user's error frame.
    --
    -- The only path that survives 12.0.5's taint propagation: never
    -- read the tainted fields. Use only:
    --   1. aura.auraInstanceID (clean by Blizzard's documented design)
    --   2. C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, instId, filter)
    --      → returns a clean boolean for each Blizzard classification
    --        flag (BIG_DEFENSIVE / EXTERNAL_DEFENSIVE / IMPORTANT /
    --        RAID / RAID_IN_COMBAT / HELPFUL / HARMFUL)
    --   3. C_UnitAuras.GetAuraDuration(unit, instId)
    --      → returns a clean number for some auras (must type-check
    --        and screen via issecretvalue; sometimes returns userdata
    --        or a secret-tagged number that can't be used)
    --   4. Class + spec from clean APIs (UnitClassFile, LibSpec cache)
    --
    -- The spell is identified by FINGERPRINT (class+spec+flag-pattern+
    -- duration) instead of by ID. MatchAuraByClassification implements
    -- this fingerprint matching plus duration narrowing plus the
    -- class+spec exclusivity heuristic, so SafeAuraLookup just hands
    -- everything off to it.
    if not aura.auraInstanceID or not _lookupUnit then
        _stats.lookupMiss = _stats.lookupMiss + 1
        return nil
    end

    -- Profile the MatchAuraByClassification call externally so we don't
    -- need to instrument its many early-return branches inline.
    local _cp, _ct0 = _prof.classify, debugprofilestop()
    _cp.calls = _cp.calls + 1
    local def = MatchAuraByClassification(_lookupUnit, aura)
    _profStop(_cp, _ct0)
    if def then
        _stats.lookupClassifyHit = (_stats.lookupClassifyHit or 0) + 1
        return def
    end
    _stats.lookupMiss = _stats.lookupMiss + 1
    return nil
end

------------------------------------------------------------
-- Observer wiring
------------------------------------------------------------
-- For OWN-player self-cast detection. UNIT_AURA in 12.0.5 sometimes
-- doesn't deliver incremental updates for self-cast buffs (the Hunter's
-- "I just cast Survival of the Fittest but no addedAuras fired" case),
-- so we additionally listen for UNIT_SPELLCAST_SUCCEEDED on "player"
-- and synthesise an OnAuraAppeared call from it. spellId here is
-- untainted (cast IDs are clean even for party members) so the regular
-- DB lookup works without taint laundering.
--
-- `unit` is the slot the event fired for: "player" or "party1".."party4".
-- We use `_spellByCastId` (keyed on the CAST spell ID) so spells where
-- def.spellId differs from def.auraId (Havoc Meta etc.) still resolve.
local function OnUnitCast(unit, spellId)
    if not unit or not spellId then return end

    -- ALL counter — increments for every UNIT_SPELLCAST_SUCCEEDED
    -- event no matter the unit. If this stays 0 the broad
    -- RegisterEvent isn't being delivered to our handler at all (e.g.
    -- registration didn't take effect, OnEvent script lost, etc.).
    _stats.allCastsSeen = _stats.allCastsSeen + 1

    -- Filter to party slots only. UNIT_SPELLCAST_SUCCEEDED is now
    -- registered broadly (RegisterEvent, not RegisterUnitEvent), so
    -- this handler fires for every unit token in the game — NPCs,
    -- random nearby players, target/focus mobs, everything. Bail on
    -- anything outside player + party1..4 before doing DB work.
    if not _isPartyUnit[unit] then return end

    _stats.partyCastsSeen = _stats.partyCastsSeen + 1

    -- Per-source counter so /bitpcd dump shows separately whether
    -- the player's events are firing vs. party-member events.
    if unit == "player" then
        _stats.playerCastSeen = _stats.playerCastSeen + 1
    end

    -- TAINT HANDLING: spellId from UNIT_SPELLCAST_SUCCEEDED is clean
    -- for own-player casts, but for party-member casts it can arrive
    -- as a "secret value" (12.0.5) — direct table indexing then
    -- throws "attempted to index a table that cannot be indexed with
    -- secret keys". Same defensive pattern SafeAuraLookup uses for
    -- UNIT_AURA: try direct lookup wrapped in pcall, fall back to
    -- the slider-trick laundry in BIT.Taint:ResolveNumber, then
    -- finally a string-keyed mirror lookup that survives the cases
    -- where laundering fails because the freshly-converted number is
    -- still secret-tagged.
    local def
    local cleanSpellId = spellId  -- best available value for downstream use
    local ok, fastDef = pcall(function() return _spellByCastId[spellId] end)
    if ok then
        def = fastDef
    else
        -- Try numeric laundry first (works in less-severe taint cases).
        if BIT.Taint and BIT.Taint.ResolveNumber then
            local laundered = BIT.Taint:ResolveNumber(spellId)
            if laundered then
                local okL, dL = pcall(function() return _spellByCastId[laundered] end)
                if okL and dL then
                    cleanSpellId = laundered
                    def = dL
                end
            end
        end
        -- Byte-scrubber: rebuild a clean number from the tainted
        -- value's string representation byte-by-byte. The proven-
        -- effective workaround for 12.0.5 M+ taint that defeats
        -- the tonumber roundtrip.
        if not def then
            local scrubbed = _scrubViaBytes(spellId)
            if scrubbed then
                local okB, dB = pcall(function() return _spellByCastId[scrubbed] end)
                if okB and dB then
                    cleanSpellId = scrubbed
                    def = dB
                end
            end
        end
        -- String-mirror fallback: hash lookup via tostring'd key.
        if not def then
            local okS, sStr = pcall(tostring, spellId)
            if okS and sStr then
                local okR, dR = pcall(function() return _spellByCastIdStr[sStr] end)
                if okR and dR then
                    def = dR
                end
            end
        end
    end

    -- Record the cast in the recent-casts map for the classification
    -- fallback's disambiguation pass. Use the def's spellId (clean
    -- from our DB) rather than cleanSpellId (might still be tainted
    -- if laundering failed). The fact that we have a def at all
    -- means SOMETHING matched, so the def.spellId is the right key.
    if def then
        _recentCasts[def.spellId] = { unit = unit, time = GetTime() }
    end

    if not def then return end

    -- Class / race gates. For class entries the caster's class must
    -- match def.class; race-gated entries (Shadowmeld) skip the class
    -- check and instead require the english race file to match.
    if def.class then
        local cls = UnitClassFile(unit)
        if cls ~= def.class then return end
    end
    if def.race then
        local _, eRace = UnitRace(unit)
        if eRace ~= def.race then return end
    end

    if unit == "player" then
        _stats.playerCastMatched = _stats.playerCastMatched + 1
    end

    -- Disabled-def short-circuit. Spells marked `disabled = true` in
    -- SPELL_DEFS aren't ready for tracking yet (typically because of
    -- classification ambiguity that produces wrong-glow on flag-twins).
    -- They stay in the spell list so the Spell Filter panel can show
    -- them as "Currently not trackable" rows, but cast events should
    -- not commit a CD or glow on them.
    if def.disabled then return end

    -- Synthesise a minimal aura-ish table for OnAuraAppeared. The unit
    -- token is also the sourceUnit, so OnAuraAppeared's caster
    -- resolution lands on the right player for both affects="self" and
    -- affects="target" defs without needing extra unit translation.
    local _ap, _at0 = _prof.onAppear, debugprofilestop()
    _ap.calls = _ap.calls + 1
    PCD:OnAuraAppeared(unit, def, { sourceUnit = unit, isHelpful = true })
    _profStop(_ap, _at0)
end

------------------------------------------------------------
-- Feign Death detection via UNIT_FLAGS.
--
-- The Hunter's Feign Death cast doesn't always surface reliably via
-- UNIT_SPELLCAST_SUCCEEDED for party members in 12.0.5 — the caster
-- lands in a "fake dead" unit state at the same instant the cast
-- event would normally fire, and the event either never delivers
-- or arrives with a spellId so taint-tagged that our laundry path
-- can't recover a clean numeric key.
--
-- UNIT_FLAGS fires whenever a unit's flag set changes, including
-- the entry/exit of feigned-dead state. UnitIsFeignDeath() is an
-- AllowedWhenUntainted boolean probe, so it returns a clean value
-- regardless of any aura-payload taint.
--
-- We cache the previous feign state per unit so we only act on
-- transitions — UNIT_FLAGS can fire many times for unrelated flag
-- updates within the same second. On entry: synthesise a Feign
-- Death "cast" through the same OnAuraAppeared path the normal
-- cast event would use, so glow/CD bookkeeping is identical. On
-- exit: short-circuit any still-pulsing FD glow into its on-CD
-- visual (the hunter stood back up, the buff is over).
------------------------------------------------------------
local _wasFeignDead = {}
local _wasInCombat  = {}
local _wasPvP       = {}
local FD_SPELL_ID = 5384

local function OnUnitFlags(unit)
    if not unit or not _isPartyUnit[unit] then return end
    if not UnitExists(unit) then return end
    if UnitClassFile(unit) ~= "HUNTER" then return end

    local now = GetTime()
    local isFD = (UnitIsFeignDeath and UnitIsFeignDeath(unit)) or false
    local wasFD = _wasFeignDead[unit] or false

    -- Record the flag-change timestamp for the SotF/Turtle resolver in
    -- classifyAura. Aspect of the Turtle grants immunity → casting it
    -- flips this unit's flag set; Survival of the Fittest never does.
    --
    -- UNIT_FLAGS fires for far more than immunity though: combat
    -- enter/leave, PvP flagging, feign death. Stamping on EVERY fire
    -- (the old behaviour) meant heavy combat kept the timestamp
    -- permanently fresh, faking "Turtle evidence" inside the resolver
    -- window — the live-reported swap where a Survival of the Fittest
    -- cast glowed the Turtle icon, worse the busier the fight. So we
    -- snapshot the explainable flag sources and only stamp immunity
    -- evidence when the event is NOT explained by any of them.
    local inCombat = (UnitAffectingCombat and UnitAffectingCombat(unit)) or false
    local isPvP    = (UnitIsPVP and UnitIsPVP(unit)) or false
    local explained = (inCombat ~= (_wasInCombat[unit] or false))
                   or (isPvP    ~= (_wasPvP[unit] or false))
                   or (isFD     ~= wasFD)
    _wasInCombat[unit] = inCombat
    _wasPvP[unit]      = isPvP

    if not explained then
        _immuneFlagsAt[unit] = now
    end
    if isFD and not wasFD then
        _feignAt[unit] = now
    end

    if isFD == wasFD then return end
    _wasFeignDead[unit] = isFD

    if isFD then
        -- Entered feign-dead: route through the cast-event commit
        -- path. The _lastCommitAt dedup inside OnAuraAppeared prevents
        -- a double-commit if UNIT_SPELLCAST_SUCCEEDED also delivered
        -- the same cast within the 0.15s window.
        local def
        local ok, d = pcall(function() return _spellByCastId[FD_SPELL_ID] end)
        if ok then def = d end
        if def then
            PCD:OnAuraAppeared(unit, def, { sourceUnit = unit, isHelpful = true })
        end
    else
        -- Left feign-dead: hunter is back up. End any still-pulsing
        -- FD glow and transition the icon into the cooldown visual.
        -- Mirrors the early-end branch in the UNIT_AURA(removed)
        -- handler below.
        local name = FullName(unit)
        if not name then return end
        if _glowEnd[name] and _glowEnd[name][FD_SPELL_ID] then
            _glowEnd[name][FD_SPELL_ID] = nil
            local icon = _icons[name] and _icons[name][FD_SPELL_ID]
            if icon then
                StopGlow(icon)
                local cdEnd = _cdEnd[name] and _cdEnd[name][FD_SPELL_ID]
                if cdEnd and cdEnd > now then
                    if icon.cd then icon.cd:SetCooldown(now, cdEnd - now) end
                    if GetCdGrayout() then
                        if icon.tex then icon.tex:SetDesaturated(true) end
                        icon:SetAlpha(0.65)
                    end
                end
            end
        end
    end
end

------------------------------------------------------------
-- Full-scan + classification detection.
--
-- Replaces the previous per-def polling approach that asked Blizzard
-- "is buff X active?" for each tracked spell — that returned nil in
-- M+ for tainted party-member aura state, no matter how clean our
-- query key was. The current path:
--
--   1. Call C_UnitAuras.GetUnitAuras(unit, "HELPFUL") to retrieve
--      the unit's full helpful-aura LIST. This call works in M+
--      where GetAuraDataBySpellID returns nil.
--   2. For each aura entry, read aura.auraInstanceID (always clean
--      per Blizzard's design — taint cannot propagate to this field).
--   3. Skip already-committed instances via `_lastInst[name][...]`.
--   4. Try SafeAuraLookup on the aura (which now chains: clean
--      spellId → tainted spellId via laundry → texture → texture
--      via laundry → IsAuraFilteredOutByInstanceID classification
--      + class/spec/duration matching from our DB).
--   5. If we get a def → fire OnAuraAppeared.
--
-- Runs on every UNIT_AURA fire (incremental or full update) for
-- party slots. The cost is O(N) where N = helpful auras on the
-- unit (~10-30 in combat). Cheap.
------------------------------------------------------------
-- Hide the buff-active glow on a tracked spell whose aura has ended,
-- transitioning the icon straight into its cooldown visual. Shared by
-- two callers:
--   1. The removedAuraInstanceIDs handler (incremental UNIT_AURA delta).
--   2. The ScanUnitAuras stale-instance GC below — catches early-cancels
--      (manual right-click cancel, dispel, etc.) that arrive as a FULL
--      update with no removedAuraInstanceIDs delta, which path 1 misses.
-- Idempotent: a no-op when the glow isn't currently active for the
-- spell, so calling it on a natural expiry (already handled by Tick)
-- or a re-scan does nothing.
local function HideGlowOnAuraEnd(name, spellId)
    if not name or not spellId then return end
    if not (_glowEnd[name] and _glowEnd[name][spellId]) then return end
    _glowEnd[name][spellId] = nil
    local icon = _icons[name] and _icons[name][spellId]
    if not icon then return end
    StopGlow(icon)
    -- Transition into the on-CD visual right now (same as Tick's
    -- glow-expire branch): start the swipe for the remaining CD and
    -- dim/desaturate unless the spell still has a usable charge.
    local cdEnd = _cdEnd[name] and _cdEnd[name][spellId]
    local now = GetTime()
    if cdEnd and cdEnd > now then
        if icon.cd then icon.cd:SetCooldown(now, cdEnd - now) end
        local def = icon._def
        if not IsMultiChargePartial(name, def) and GetCdGrayout() then
            if icon.tex then icon.tex:SetDesaturated(true) end
            icon:SetAlpha(0.65)
        end
    end
end

local function ScanUnitAuras(unit, name)
    local _p, _t0 = _prof.scan, debugprofilestop()
    _p.calls = _p.calls + 1
    if not unit or not name then _profStop(_p, _t0); return end
    _stats.pollRuns = _stats.pollRuns + 1

    -- Build the group-spec cache ONCE for this scan. Every classify
    -- call below reads from it instead of rebuilding the party-wide
    -- UnitClassFile/FullName/GetSpecForName loop on each call.
    _seenSpecCache, _seenSpeclessCache = _buildGroupSpecCache()

    _lastInst[name] = _lastInst[name] or {}
    local lastInst = _lastInst[name]
    _rejectedInst[name] = _rejectedInst[name] or { _n = 0 }
    local rejected = _rejectedInst[name]

    -- Get the full helpful-aura list. pcall in case the API itself
    -- ever throws — historically GetUnitAuras has been the most
    -- reliable aura-enumeration call in 11.x/12.x.
    local ok, list = pcall(C_UnitAuras.GetUnitAuras, unit, "HELPFUL")
    if not ok or not list then
        _stats.pollProbeErrors = _stats.pollProbeErrors + 1
        _seenSpecCache, _seenSpeclessCache = nil, nil
        _profStop(_p, _t0)
        return
    end

    for _, aura in ipairs(list) do
        if aura and aura.auraInstanceID then
            local rawInst = aura.auraInstanceID
            -- Launder the instanceID through string.format → tonumber.
            -- In most 12.x cases it's already clean, but the laundry
            -- is cheap and protects the lastInst table indexing below.
            local okI, instStr = pcall(string.format, "%.0f", rawInst)
            local instId = okI and tonumber(instStr) or rawInst

            -- Check if we already committed this instance. Have to
            -- pcall the table comparison because lastInst values
            -- might have come from a previous (tainted) write.
            local alreadyCommitted = false
            for _, prevInst in pairs(lastInst) do
                local okE = pcall(function() return prevInst == instId end)
                if okE and prevInst == instId then
                    alreadyCommitted = true
                    break
                end
            end

            -- NEGATIVE cache check: this exact instance already went
            -- through the full lookup and missed — don't probe again.
            -- pcall-guarded because instId can stay secret-tagged when
            -- the laundry fails; indexing a table with a secret key
            -- throws. A throwing check just counts as "not rejected".
            local alreadyRejected = false
            if not alreadyCommitted and instId ~= nil then
                local okR, r = pcall(function() return rejected[instId] end)
                if okR and r then
                    alreadyRejected = true
                    _stats.pollSkipsRejected = _stats.pollSkipsRejected + 1
                end
            end

            if not alreadyCommitted and not alreadyRejected then
                _stats.pollProbes = _stats.pollProbes + 1

                -- SafeAuraLookup chains 5 identification strategies.
                -- _lookupUnit lets the classification fallback inside
                -- query IsAuraFilteredOutByInstanceID with the right
                -- unit token.
                _lookupUnit = unit
                local def = SafeAuraLookup(aura)
                _lookupUnit = nil

                if def then
                    -- PROC GUARD: an aura whose READABLE duration is below
                    -- the def's minimum real duration is a talent proc,
                    -- never an actual use — committing a charge/CD for it
                    -- is always wrong (live case: Dark Ranger "Smoke
                    -- Screen" grants 3s of Survival of the Fittest on
                    -- every Exhilaration). Uses the taint-safe
                    -- GetAuraDuration read (same rules as classification:
                    -- never touch aura.duration directly). Fail-open: a
                    -- secret/unreadable duration must never block a real
                    -- cast. Proc instances go to the negative cache so
                    -- rescans skip them outright.
                    local isProc = false
                    if def.minDur then
                        local okD, d = pcall(C_UnitAuras.GetAuraDuration, unit, instId)
                        if okD and type(d) == "number" then
                            local okS, isSec = pcall(issecretvalue, d)
                            if (not okS or not isSec) and d > 0 and d < def.minDur then
                                isProc = true
                            end
                        end
                    end
                    if isProc then
                        _stats.procSkips = (_stats.procSkips or 0) + 1
                        pcall(function()
                            if instId ~= nil and rejected[instId] == nil then
                                if (rejected._n or 0) >= REJECTED_CAP then
                                    for k in pairs(rejected) do rejected[k] = nil end
                                    rejected._n = 0
                                end
                                rejected[instId] = true
                                rejected._n = (rejected._n or 0) + 1
                            end
                        end)
                    else
                        lastInst[def.spellId] = instId
                        _stats.pollHits = _stats.pollHits + 1
                        _stats.pollProbeFound = _stats.pollProbeFound + 1
                        local _ap, _at0 = _prof.onAppear, debugprofilestop()
                        _ap.calls = _ap.calls + 1
                        PCD:OnAuraAppeared(unit, def, aura)
                        _profStop(_ap, _at0)
                    end
                else
                    -- Miss → remember the instance so subsequent scans
                    -- skip it outright. Size cap as a leak backstop
                    -- (wipe-and-restart; the next scan re-learns the
                    -- handful of currently-active instances).
                    pcall(function()
                        if instId ~= nil and rejected[instId] == nil then
                            if (rejected._n or 0) >= REJECTED_CAP then
                                for k in pairs(rejected) do rejected[k] = nil end
                                rejected._n = 0
                            end
                            rejected[instId] = true
                            rejected._n = (rejected._n or 0) + 1
                        end
                    end)
                end
            end
        end
    end

    -- Garbage-collect stale lastInst entries: instances we tracked
    -- previously but aren't in the current aura list anymore (buff
    -- expired or was dispelled). Without this cleanup the next time
    -- the same spell is cast, its new instanceID might collide with
    -- a stale value and we'd skip the trigger.
    local seenInsts = {}
    for _, aura in ipairs(list) do
        if aura and aura.auraInstanceID then
            local okI, instStr = pcall(string.format, "%.0f", aura.auraInstanceID)
            local inst = okI and tonumber(instStr) or aura.auraInstanceID
            if inst then seenInsts[inst] = true end
        end
    end
    for spellId, inst in pairs(lastInst) do
        local okE = pcall(function() return seenInsts[inst] end)
        if not okE or not seenInsts[inst] then
            lastInst[spellId] = nil
            -- The aura for this tracked spell is no longer present on
            -- the unit — it ended (expired, dispelled, or manually
            -- cancelled). Hide its still-pulsing glow now instead of
            -- letting the ring animate for the full nominal duration.
            -- This is the full-update / no-removal-delta safety net
            -- that complements the removedAuraInstanceIDs handler.
            HideGlowOnAuraEnd(name, spellId)
        end
    end
    -- Prune the negative cache the same way: rejected instances that
    -- vanished from the aura list can never come back (instance IDs are
    -- unique per application), so their entries are dead weight.
    for inst in pairs(rejected) do
        if inst ~= "_n" then
            local okE, seen = pcall(function() return seenInsts[inst] end)
            if not okE or not seen then
                rejected[inst] = nil
                rejected._n = math.max(0, (rejected._n or 1) - 1)
            end
        end
    end
    -- Drop the group-spec cache; built fresh on the next scan.
    _seenSpecCache, _seenSpeclessCache = nil, nil
    _profStop(_p, _t0)
end

-- Static pet-unit → owner-slot map. The broad UNIT_AURA registration
-- delivers pet fires too; this O(1) lookup routes a Hunter pet's
-- BIG_DEFENSIVE aura back to its owner without a per-fire string match.
local _petOwner = {
    pet       = "player",
    party1pet = "party1",
    party2pet = "party2",
    party3pet = "party3",
    party4pet = "party4",
}

local function OnUnitAura(_, event, ...)
    local _p, _t0 = _prof.onAura, debugprofilestop()
    _p.calls = _p.calls + 1
    -- Different events deliver different positional args, so we
    -- demux on the event name and unpack what each one needs:
    --   UNIT_AURA              : (unit, updateInfo)
    --   UNIT_SPELLCAST_SUCCEEDED : (unit, castGUID, spellID)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _castGUID, spellID = ...
        if unit and spellID then
            OnUnitCast(unit, spellID)
        end
        _profStop(_p, _t0)
        return
    end
    if event == "UNIT_FLAGS" then
        local unit = ...
        if unit then OnUnitFlags(unit) end
        _profStop(_p, _t0)
        return
    end
    if event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        -- Side-channel for the DK Anti-Magic Shell vs Icebound Fortitude
        -- twin: only AMS adds an absorb. Broad event → gate to our 5 slots
        -- and stamp the time; the resolver consults it within a tight window
        -- when both twins are candidates.
        local unit = ...
        if unit and _isPartyUnit[unit] then _absorbAt[unit] = GetTime() end
        _profStop(_p, _t0)
        return
    end
    if event ~= "UNIT_AURA" then _profStop(_p, _t0); return end
    local unit, updateInfo = ...
    if not unit then _profStop(_p, _t0); return end

    -- Pet BIG_DEFENSIVE evidence for the Hunter SotF/Turtle resolver.
    -- Survival of the Fittest lands a BIG_DEFENSIVE aura on the Hunter's
    -- pet; Aspect of the Turtle never touches the pet — so a big-def
    -- aura on a pet is a positive SotF confirm for its owner. Owner-
    -- class gated to skip Warlock / DK / Mage pet churn. Pet units are
    -- never party slots, so this returns before the party filter below.
    local petOwner = _petOwner[unit]
    if petOwner then
        if updateInfo and updateInfo.addedAuras
           and UnitClassFile(petOwner) == "HUNTER" then
            for _, addedAura in ipairs(updateInfo.addedAuras) do
                if addedAura and addedAura.auraInstanceID then
                    local ok, filteredOut = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID,
                        unit, addedAura.auraInstanceID, "HELPFUL|BIG_DEFENSIVE")
                    if ok and filteredOut == false then
                        _petBigDefAt[petOwner] = GetTime()
                        break
                    end
                end
            end
        end
        _profStop(_p, _t0)
        return
    end

    -- BROAD RegisterEvent fires for every unit token in the game.
    -- Filter to our 5 slots (player + party1..4) — anything else is
    -- nameplate / target / focus / raid frame churn that we never
    -- need to look at. Bail before any DB or counter work.
    if not _isPartyUnit[unit] then _profStop(_p, _t0); return end
    _stats.unitAuraFired = _stats.unitAuraFired + 1

    -- Track "harmful aura added in this batch" context per unit.
    -- Used by the classification fallback to disambiguate Pala
    -- flag-twins (Divine Shield vs Divine Protection, BoP vs BoSac):
    -- the Forbearance-family spells apply Forbearance to the
    -- recipient AS PART OF THE SAME UNIT_AURA EVENT as their buff.
    -- We probe each addedAura via IsAuraFilteredOutByInstanceID
    -- with the HARMFUL filter — that returns a clean boolean (the
    -- API doesn't expose tainted spellIds at all). If any addedAura
    -- matches HARMFUL, mark the unit as having received a harmful
    -- aura in this batch.
    if updateInfo and updateInfo.addedAuras then
        for _, addedAura in ipairs(updateInfo.addedAuras) do
            if addedAura and addedAura.auraInstanceID then
                local ok, filteredOut = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID,
                    unit, addedAura.auraInstanceID, "HARMFUL")
                -- filteredOut == false means the aura DOES match HARMFUL
                if ok and filteredOut == false then
                    _lastHarmfulAdded[unit] = GetTime()
                    break
                end
            end
        end
    end

    -- DEFERRED-INFERENCE finaliser + EARLY-REMOVAL glow cleanup.
    -- When an aura we tentatively attributed (flag-twin ambiguity)
    -- is removed we measure its observed lifetime and swap CD
    -- attribution. AND for any tracked aura that's removed before
    -- its nominal duration ran out (death, dispel, manual cancel),
    -- we hide the still-pulsing glow on its icon — otherwise the
    -- ring would keep animating for the full def.dur seconds even
    -- though the buff is already gone.
    if updateInfo and updateInfo.removedAuraInstanceIDs then
        local nameForRemove = FullName(unit)
        local lastInstForUnit = nameForRemove and _lastInst[nameForRemove]
        for _, removedInst in ipairs(updateInfo.removedAuraInstanceIDs) do
            -- Deferred-inference verification path (unchanged).
            if _durationProbes[unit] and _durationProbes[unit][removedInst] then
                _finalizeDurationProbe(unit, removedInst, "removed")
            end
            -- Glow / charge / CD cleanup. Reverse-lookup: which
            -- tracked spell owned this instance?
            if lastInstForUnit then
                local removedSpellId
                for sid, inst in pairs(lastInstForUnit) do
                    if inst == removedInst then
                        removedSpellId = sid
                        break
                    end
                end
                if removedSpellId then
                    -- Hide the still-pulsing glow + transition to the
                    -- on-CD visual (shared with the ScanUnitAuras GC
                    -- early-cancel path). Idempotent when the glow's
                    -- already off.
                    HideGlowOnAuraEnd(nameForRemove, removedSpellId)
                    -- Drop the lastInst tracking entry so a fresh
                    -- cast after this can create a new instance
                    -- without dedup skipping it.
                    lastInstForUnit[removedSpellId] = nil
                    -- Also clear the per-spell refresh baseline used
                    -- by the spread-vs-recast disambiguator — a fresh
                    -- cast some time later must compare against a
                    -- clean slate, otherwise an old timestamp could
                    -- bias the first refresh into the off-grid bucket.
                    if _lastRefreshAt[unit] then
                        _lastRefreshAt[unit][removedSpellId] = nil
                    end
                end
            end
        end
    end

    -- MULTI-CHARGE REFRESH detection. When a multi-charge buff is
    -- recast while a previous instance is still active, Blizzard
    -- usually refreshes the existing aura (same auraInstanceID) rather
    -- than creating a new one. ScanUnitAuras' lastInst dedup then
    -- skips the "second cast" because the instance is already tracked,
    -- so the charge queue never gets a second push. Blizzard signals
    -- these refreshes via updatedAuraInstanceIDs — we use that to
    -- trigger another OnAuraAppeared commit for tracked multi-charge
    -- spells. The dedup window inside OnAuraAppeared blocks accidental
    -- double-commits from this path stacking with other code paths.
    --
    -- EXCEPTION: defs with `selfRefreshing` set are skipped here when
    -- the condition applies. The field can be:
    --   true       — unconditional skip (always treat refreshes as
    --                non-cast events)
    --   <number>   — talent ID gate: only skip when the caster has
    --                THIS talent picked. Without the talent the spell
    --                doesn't auto-refresh, so refreshes ARE recasts
    --                and should drive the charge queue normally.
    -- Example: Fiery Brand only spreads via Burning Alive (207739).
    -- A DH without that talent doesn't see auto-refreshes — for them
    -- the normal refresh-as-recast logic must still apply, otherwise
    -- a legitimate 2nd cast during the 12s buff window gets missed.
    -- For those defs we rely on UNIT_SPELLCAST_SUCCEEDED + new-
    -- instance addedAuras paths exclusively for charge accounting
    -- whenever the talent gate matches.
    if updateInfo and updateInfo.updatedAuraInstanceIDs then
        local nameForRefresh = FullName(unit)
        local lastInstForUnit = nameForRefresh and _lastInst[nameForRefresh]
        if lastInstForUnit then
            for _, updatedInst in ipairs(updateInfo.updatedAuraInstanceIDs) do
                -- Reverse lookup: which tracked spell does this
                -- instance belong to?
                local trackedSpellId
                for sid, inst in pairs(lastInstForUnit) do
                    if inst == updatedInst then
                        trackedSpellId = sid
                        break
                    end
                end
                if trackedSpellId then
                    local def = _spellByCastId[trackedSpellId]
                                or _spellByAuraId[trackedSpellId]
                    if def and GetEffectiveCharges(def, nameForRefresh) > 1 then
                        -- Resolve selfRefreshing: glow-only refresh
                        -- iff the field is `true` OR is a talent ID
                        -- the caster has picked. Glow-only means the
                        -- visual buff window extends but the CD swipe
                        -- and charge queue keep running unchanged —
                        -- the spell consumed only one charge for the
                        -- original cast that's still spreading.
                        local talentMatches = false
                        if def.selfRefreshing == true then
                            talentMatches = true
                        elseif type(def.selfRefreshing) == "number" then
                            local talents = GetKnownTalentsForName(nameForRefresh)
                            -- Optimistic when talents unknown: assume
                            -- the player has the spread talent. The
                            -- alternative (assume not, count every
                            -- refresh as a cast) is the visibly-worse
                            -- failure mode (charges drain to 0 on a
                            -- single use in M+ where talent data is
                            -- comm-blocked).
                            if not talents or talents[def.selfRefreshing] then
                                talentMatches = true
                            end
                        end

                        -- Spread-vs-recast disambiguator. Passive
                        -- self-refresh talents fire at a deterministic
                        -- 1s cadence (Burning Alive: "Every 1 sec
                        -- Fiery Brand spreads to one nearby enemy").
                        -- A refresh arriving within ±0.25s of a 1s
                        -- multiple after the reference point is
                        -- treated as a spread. An off-grid refresh
                        -- (typical GCD-paced recast at ~1.5s) is
                        -- treated as a recast and routed to the normal
                        -- commit path so the charge queue advances.
                        --
                        -- Reference point selection:
                        --   1) prefer last refresh time (most recent
                        --      grid sample, closest to the player's
                        --      current state)
                        --   2) fall back to last commit time when no
                        --      prior refresh exists (handles the "no
                        --      nearby enemies, no spreads, just a
                        --      second cast" case where the first
                        --      refresh after commit IS the recast)
                        --
                        -- Why this works: the player physically can't
                        -- cast at exactly 1.0s grid offsets relative
                        -- to a server-tick-driven passive proc — even
                        -- a perfect macro queues against GCD which
                        -- desyncs from the spread cadence after the
                        -- first second. The 0.25s tolerance absorbs
                        -- normal network/server-tick jitter.
                        local nowR = GetTime()
                        local isRecast = false
                        if talentMatches then
                            local unitRefreshes = _lastRefreshAt[unit]
                            local lastR = unitRefreshes and unitRefreshes[def.spellId]
                            local baseline = lastR
                            if not baseline then
                                -- No prior refresh — use the last
                                -- commit time as the baseline so a
                                -- "cast 2 with no intervening spreads"
                                -- gets correctly off-grid'd.
                                baseline = _lastCommitAt[nameForRefresh]
                                           and _lastCommitAt[nameForRefresh][def.spellId]
                            end
                            if baseline then
                                local delta = nowR - baseline
                                -- Distance to the nearest 1s grid
                                -- point: min(fractional, 1-fractional).
                                -- A delta of 1.5s has gridDist = 0.5
                                -- → off-grid → recast.
                                local gridDist = math.min(
                                    delta - math.floor(delta),
                                    math.ceil(delta) - delta)
                                if gridDist > 0.25 then
                                    isRecast = true
                                end
                            end
                            -- Update the timestamp regardless of
                            -- branch so the next refresh has a
                            -- baseline to measure against.
                            _lastRefreshAt[unit] = _lastRefreshAt[unit] or {}
                            _lastRefreshAt[unit][def.spellId] = nowR
                        end

                        if talentMatches and not isRecast then
                            _stats.refreshGlowOnly = (_stats.refreshGlowOnly or 0) + 1
                            RefreshGlowOnly(unit, def)
                        else
                            -- Refresh-as-recast guard. In 12.x Blizzard
                            -- fires updatedAuraInstanceIDs for non-cast
                            -- reasons too (internal aura bookkeeping,
                            -- server-side refreshes). A real recast on
                            -- a multi-charge spell can't happen faster
                            -- than the GCD (~1.5s) — if the last commit
                            -- for this spell was less than 1.0s ago,
                            -- this update can't be a legitimate recast.
                            -- Treat it as a glow-only refresh instead
                            -- so the charge queue doesn't accumulate
                            -- spurious entries.
                            --
                            -- Live-observed without this guard: party
                            -- DH Blur and party Hunter Survival of the
                            -- Fittest charge counters get stuck at 0
                            -- because each spurious update pushes a new
                            -- recharge time, queue grows beyond
                            -- maxCharges, badge avail clamps to 0 and
                            -- the CD swipe keeps restarting from
                            -- queue[1] every time prune fires.
                            -- LOCAL-PLAYER: never treat an aura update as
                            -- a recast. The player's own recasts always
                            -- arrive via a clean UNIT_SPELLCAST_SUCCEEDED
                            -- (OnUnitCast → charge-queue push), so this
                            -- path is only ever a visual refresh for us.
                            -- Committing here on top would silently drain
                            -- a charge the player never spent a few
                            -- seconds after the cast (live-observed: SotF
                            -- 2→1→0 with no second press), because
                            -- Blizzard fires updatedAuraInstanceIDs for
                            -- a still-active buff at arbitrary times. The
                            -- 1.0s guard below only caught the fast case;
                            -- the player exclusion covers all timings.
                            -- Party members keep the recast heuristic —
                            -- their cast events are the unreliable ones.
                            local lastAt = _lastCommitAt[nameForRefresh]
                                           and _lastCommitAt[nameForRefresh][def.spellId]
                            -- PROC GUARD: this full-commit branch used to
                            -- hand OnAuraAppeared a SYNTHETIC aura with no
                            -- duration data, bypassing every proc check —
                            -- a short talent proc (Smoke Screen 3s SotF)
                            -- that got updated here decremented a charge.
                            -- We have the real instance id, so read the
                            -- duration and route short auras to the
                            -- glow-only refresh instead.
                            local procShort = false
                            if def.minDur then
                                local okA, ad = pcall(C_UnitAuras.GetAuraDuration, unit, updatedInst)
                                if okA and type(ad) == "number" then
                                    local okS, sec = pcall(issecretvalue, ad)
                                    if (not okS or not sec) and ad > 0 and ad < def.minDur then
                                        procShort = true
                                    end
                                end
                            end
                            if unit == "player" or procShort
                               or (lastAt and (GetTime() - lastAt) < 1.0) then
                                if procShort then
                                    _stats.procSkips = (_stats.procSkips or 0) + 1
                                end
                                _stats.refreshGlowOnly = (_stats.refreshGlowOnly or 0) + 1
                                RefreshGlowOnly(unit, def)
                            else
                                _stats.refreshFullCommit = (_stats.refreshFullCommit or 0) + 1
                                PCD:OnAuraAppeared(unit, def,
                                    { sourceUnit = unit, isHelpful = true })
                            end
                        end
                    end
                end
            end
        end
    end

    -- POLL PATH (primary). Pull-based, taint-safe — see header comment
    -- on ScanUnitAuras above. Runs on every UNIT_AURA fire and
    -- detects defensive buffs whether the fire was a full update or
    -- an incremental delta. Enumerates the full HELPFUL aura list,
    -- identifies each via SafeAuraLookup's classification chain
    -- (Blizzard category filters + duration + class/spec narrowing).
    local name = FullName(unit)
    if name then
        -- For incremental updates with addedAuras we DEFER the scan
        -- by 0.05s. The reason: WoW can split related aura changes
        -- across separate UNIT_AURA events — Forbearance often
        -- arrives in a different fire than the Blessing of Protection
        -- buff. If we scan immediately on the first fire, the
        -- Forbearance signal hasn't been seen yet and the
        -- classification picks the wrong flag-twin (BoSac instead
        -- of BoP). A 0.05s delay lets the matched-pair event arrive
        -- and update `_lastHarmfulAdded` before classification runs.
        --
        -- Full updates (post-/reload, zone transition) get an
        -- immediate scan because we want them tracked ASAP — they're
        -- usually steady-state with no related-event ordering issue.
        local isIncremental = updateInfo and not updateInfo.isFullUpdate
                              and updateInfo.addedAuras and #updateInfo.addedAuras > 0
        if isIncremental then
            _stats.pollDeferred = _stats.pollDeferred + 1
            C_Timer.After(0.05, function()
                if UnitExists(unit) and FullName(unit) == name then
                    ScanUnitAuras(unit, name)
                end
            end)
        else
            ScanUnitAuras(unit, name)
        end
        -- Earlier versions also scheduled a second 0.15s deferred
        -- re-scan as a safety net for buffs Blizzard sometimes
        -- delivered late. Profile data over a 30-minute encounter
        -- showed it doubled scan call count without measurably
        -- improving detection (onAura already calls scan after
        -- the 0.05s defer for Forbearance ordering). Removed.
    end

    -- The full-update / addedAuras passes below are kept as DIAGNOSTIC
    -- ONLY — they print verbose lines so we can see incoming aura data
    -- and maintain the addedAurasSeen counter. They no longer call
    -- OnAuraAppeared because ScanUnitAuras above already iterates the
    -- complete helpful-aura list and commits everything it can match.
    --
    -- Why the change: when both paths called OnAuraAppeared on the
    -- same aura, the second call's classification fallback would see
    -- the first call's _cdEnd write as "already on cooldown" and pick
    -- the OTHER flag-twin candidate (e.g. Divine Shield instead of
    -- Divine Protection). Single-source detection via the scan path
    -- avoids this race entirely.
    --
    -- Full update — happens on PLAYER_ENTERING_WORLD-class transitions
    -- and any time Blizzard chooses not to deliver an incremental delta.
    -- ScanUnitAuras above already handled detection. No separate
    -- diagnostic emit here — it used to read `aura.spellId` / `aura.icon`
    -- which propagates taint into our execution context.
    if not updateInfo or updateInfo.isFullUpdate then
        _stats.fullUpdates = _stats.fullUpdates + 1
        _profStop(_p, _t0)
        return
    end

    -- Incremental update: count addedAuras for stats, but do NOT
    -- read any field except auraInstanceID. Reading aura.spellId or
    -- aura.icon would taint our addon's execution context (12.0.5
    -- secret-value contagion) and break every downstream pcall'd
    -- operation. ScanUnitAuras above already iterated the full
    -- helpful-aura list and tried classification on each, so this
    -- branch is just bookkeeping.
    local added = updateInfo.addedAuras
    if not added then _profStop(_p, _t0); return end
    for _, aura in ipairs(added) do
        _stats.addedAurasSeen = _stats.addedAurasSeen + 1
    end
    _profStop(_p, _t0)
end

local function RegisterAuraObserver()
    if not _auraFrame then
        _auraFrame = CreateFrame("Frame")
        _auraFrame:SetScript("OnEvent", BIT.Prof.Wrap("PARTY_CDS", OnUnitAura))
    end
    -- BROAD RegisterEvent for UNIT_AURA (NOT RegisterUnitEvent). In
    -- 12.0.5 the per-unit filtered registration for party slots
    -- silently fails to deliver events — the priest casts Desperate
    -- Prayer, the buff applies to party1's aura table, but no
    -- UNIT_AURA fires on the per-unit handler. The broad registration
    -- gets all unit tokens; we filter to our 5 slots via
    -- _isPartyUnit inside OnUnitAura. Same mechanism switch we apply
    -- below to UNIT_SPELLCAST_SUCCEEDED.
    _auraFrame:RegisterEvent("UNIT_AURA")
    -- UNIT_SPELLCAST_SUCCEEDED is our primary detection path in 12.0.5
    -- because UNIT_AURA is unreliable for both own self-cast buffs AND
    -- party-member buffs, and COMBAT_LOG_EVENT_UNFILTERED registration
    -- is forbidden for this addon (triggers ADDON_ACTION_FORBIDDEN —
    -- same restriction documented in Core/Core.lua).
    --
    -- We use the BROAD RegisterEvent (no unit filter) instead of
    -- RegisterUnitEvent. In 12.0.5 the per-unit registration for
    -- party slots is unreliable: events for party1..party4 may simply
    -- never fire even when the cast happened. The broad registration
    -- fires for every unit token in the game — we then filter via
    -- the _isPartyUnit set in OnUnitCast.
    --
    -- UNIT_AURA stays registered per-unit above as a secondary signal —
    -- it catches the login full-update sweep so pre-existing buffs on
    -- party members at load time still get detected.
    _auraFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    -- UNIT_FLAGS catches the feigned-dead state transition for
    -- Hunter Feign Death — the cast event for FD on party members
    -- in 12.0.5 isn't reliable, so OnUnitFlags uses the AllowedWhenUntainted
    -- UnitIsFeignDeath probe to commit FD when the flag set flips.
    _auraFrame:RegisterEvent("UNIT_FLAGS")
    -- Absorb-change side-channel for the DK Anti-Magic Shell vs Icebound
    -- Fortitude flag-twin (AMS applies an absorb shield, Icebound doesn't).
    -- MUST be broad RegisterEvent (like UNIT_AURA above), NOT per-unit:
    -- RegisterUnitEvent for party slots is unreliable for this in 12.x and
    -- the event simply never arrived, so the absorb evidence was always
    -- empty. The handler filters to party units (cheap _isPartyUnit check).
    _auraFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
end

local function UnregisterAuraObserver()
    if _auraFrame then _auraFrame:UnregisterAllEvents() end
end

------------------------------------------------------------
-- Local-player CD / charge seed from Blizzard's authoritative APIs.
--
-- Our _cdEnd / _chargeQueue tables are in-memory only — they're wiped
-- on /reload. For party members that's unavoidable (Blizzard exposes
-- no API for their cooldowns), but for the LOCAL PLAYER we can ask the
-- game directly: C_Spell.GetSpellCooldown / GetSpellCharges return the
-- real remaining cooldown and current charge count, surviving reloads
-- on the server side. So after a reload we re-seed the player's own
-- tracked spells from those APIs instead of showing them as "ready /
-- full charges" when they're actually still recharging.
--
-- Purely Blizzard-data-driven: we use the API's own maxCharges /
-- currentCharges rather than our talent-derived GetEffectiveCharges,
-- so the seed is correct even before LibSpec/talent data has loaded.
-- Called at the end of RebuildAnchors (which runs on enable and on
-- every PLAYER_ENTERING_WORLD, i.e. after each /reload) so the icons
-- exist by the time we apply the on-cooldown visual.
------------------------------------------------------------
-- Numeric field read with 12.0.5 taint defence. Unlike the Tick-local
-- _readCleanField this ACCEPTS zero — currentCharges == 0 is a valid
-- "all spent" reading we must keep.
local function _readNum(t, key)
    local ok, v = pcall(function() return t and t[key] end)
    if not ok or type(v) ~= "number" then return nil end
    local okS, isSec = pcall(issecretvalue, v)
    if not okS or isSec then return nil end
    return v
end

local function SeedLocalPlayerCDs()
    local selfFull = FullName("player")
    if not selfFull then return end
    local playerClass = UnitClassFile("player")
    if not playerClass then return end
    local _, playerRace = UnitRace("player")
    local now = GetTime()

    for _, def in ipairs(SPELL_DEFS) do
        -- Only the player's own spells: class match (or race match for
        -- racials). Disabled defs never render, so skip them.
        local mine = (def.class == playerClass)
        if def.race then mine = (playerRace == def.race) end
        if mine and not def.disabled then
            local seeded = false

            -- Multi-charge path: GetSpellCharges gives the real
            -- max / current / recharge-timer breakdown.
            if C_Spell and C_Spell.GetSpellCharges then
                local okC, info = pcall(C_Spell.GetSpellCharges, def.spellId)
                if okC and info then
                    local maxC    = _readNum(info, "maxCharges")
                    local curC    = _readNum(info, "currentCharges")
                    local cdStart = _readNum(info, "cooldownStartTime")
                    local cdDur   = _readNum(info, "cooldownDuration")
                    if maxC and maxC > 1 and curC and cdStart and cdDur
                       and cdDur > 0 and curC < maxC then
                        local pending = maxC - curC
                        local q = {}
                        for i = 1, pending do q[i] = cdStart + i * cdDur end
                        _chargeQueue[selfFull] = _chargeQueue[selfFull] or {}
                        _chargeQueue[selfFull][def.spellId] = q
                        _cdEnd[selfFull] = _cdEnd[selfFull] or {}
                        _cdEnd[selfFull][def.spellId] = q[1]
                        seeded = true
                    end
                end
            end

            -- Single-charge fallback: GetSpellCooldown. dur > 1.5
            -- filters out the global cooldown (we only want real
            -- spell CDs, not the GCD a spell briefly shows).
            if not seeded and C_Spell and C_Spell.GetSpellCooldown then
                local okCD, cd = pcall(C_Spell.GetSpellCooldown, def.spellId)
                if okCD and cd then
                    local start = _readNum(cd, "startTime")
                    local dur   = _readNum(cd, "duration")
                    if start and dur and dur > 1.5 then
                        local cdEnd = start + dur
                        if cdEnd > now then
                            _cdEnd[selfFull] = _cdEnd[selfFull] or {}
                            _cdEnd[selfFull][def.spellId] = cdEnd
                            seeded = true
                        end
                    end
                end
            end

            -- Apply the on-cooldown visual to the icon (if it exists
            -- yet). The per-tick _cdEnd loop drives the countdown text
            -- from here on; we just need to start the swipe + dim once.
            --
            -- Glow-active guard: this seed re-runs on every
            -- RebuildAnchors (roster / zone / edit-mode), which can
            -- fire mid-combat while one of the player's buffs is still
            -- active and pulsing its glow. The spell IS technically on
            -- cooldown then (GetSpellCooldown returns the CD), but we
            -- must NOT stomp the buff-active glow phase with the on-CD
            -- swipe. So when a glow is still running for this spell we
            -- refresh the _cdEnd value silently (done above) but leave
            -- the visual alone — Tick's glow-expiry will transition it
            -- to the swipe at the right moment.
            if seeded then
                local glowActive = _glowEnd[selfFull]
                                   and _glowEnd[selfFull][def.spellId]
                                   and _glowEnd[selfFull][def.spellId] > now
                local icon = _icons[selfFull] and _icons[selfFull][def.spellId]
                local cdEnd = _cdEnd[selfFull] and _cdEnd[selfFull][def.spellId]
                if not glowActive and icon and cdEnd and cdEnd > now then
                    icon:Show()
                    if icon.cd then icon.cd:SetCooldown(now, cdEnd - now) end
                    if not IsMultiChargePartial(selfFull, def) and GetCdGrayout() then
                        if icon.tex then icon.tex:SetDesaturated(true) end
                        icon:SetAlpha(0.65)
                    end
                    SetChargeBadgeText(selfFull, icon)
                end
            end
        end
    end
end

------------------------------------------------------------
-- Roster / Edit Mode handling
--
-- Three reasons we may need to re-resolve which on-screen frame each
-- party member is currently displayed on:
--   1) GROUP_ROSTER_UPDATE — someone joined / left / changed party slot
--   2) EDIT_MODE_LAYOUTS_UPDATED — user toggled "Use Raid-style party
--      frames" or applied a different layout
--   3) PLAYER_ENTERING_WORLD — initial render after a load screen
------------------------------------------------------------
function PCD:RebuildAnchors()
    if not _enabled then return end
    -- In STANDALONE mode the standalone container needs to exist
    -- BEFORE EnsureIconsFor runs (it queries GetPartyFrame which
    -- creates slot anchors inside it). Show/Hide based on mode so
    -- the frame doesn't linger on screen after a switch back to
    -- ANCHOR mode.
    local mode = (BIT.db and BIT.db.partyCooldownsFrameMode) or "ANCHOR"
    if mode == "STANDALONE" then
        EnsureStandaloneFrame()
        if _standaloneFrame and (ShouldBeVisibleHere() or _standaloneTestActive) then
            _standaloneFrame:Show()
        elseif _standaloneFrame then
            _standaloneFrame:Hide()
        end
    elseif _standaloneFrame then
        _standaloneFrame:Hide()
    end
    -- Skip the real-roster icon pipeline in standalone-test mode —
    -- the synthetic roster's icons are placed manually by
    -- LayoutStandaloneRows via _populateTestIcons. EnsureIconsFor
    -- would otherwise try to render real party-member icons into the
    -- same frame, doubling up on the player's own row.
    if not _standaloneTestActive then
        ForEachPartyMember(function(unit, name, class)
            -- Stale-spec correction BEFORE the icon build so a respec
            -- caught via the role side-channel renders the right spells
            -- in this very pass.
            _reconcileSpecWithRole(unit, name, class)
            EnsureIconsFor(unit, name, class)
        end)
    end
    -- Reflow the standalone rows after icons have been placed so the
    -- container resizes around the new content. Cheap no-op in
    -- ANCHOR mode (early-returns when _standaloneFrame is nil).
    -- ApplyStandaloneAnchor is re-run so a Grow-Upward toggle flip
    -- routes the frame's pinned corner (TOPLEFT vs BOTTOMLEFT) live.
    if mode == "STANDALONE" then
        ApplyStandaloneAnchor()
        LayoutStandaloneRows()
        ApplyStandaloneLock()
    end

    -- Re-seed the local player's own cooldowns / charges from Blizzard's
    -- authoritative APIs now that the icons exist. Restores real CD /
    -- charge state after a /reload (when our in-memory tables were
    -- wiped) instead of showing the player's spells as ready / full.
    SeedLocalPlayerCDs()
end

------------------------------------------------------------
-- Standalone test layout — populates the standalone frame with the
-- local player + 4 names from BIT.TEST_POOL (the shared sample roster
-- the Interrupt Tracker / Keystone List previews also use) so the
-- user can position / theme the frame without needing a real M+
-- group. Mirrors KeystoneList:ToggleTestMode / IsTestModeActive.
------------------------------------------------------------
function PCD:IsTestLayoutActive()
    return _standaloneTestActive == true
end

function PCD:ToggleTestLayout()
    if _standaloneTestActive then
        -- Disable: drop the synthetic roster, hide+detach the test
        -- icons from each preview slot, and let RebuildAnchors run
        -- the normal real-party path again to restore live state.
        _standaloneTestActive = false
        _standaloneTestRoster = nil
        for _, slot in pairs(_standaloneSlots) do
            if slot._testIcons then
                for _, ic in ipairs(slot._testIcons) do
                    ic:Hide()
                    ic:SetParent(nil)
                end
                slot._testIcons = nil
            end
        end
    else
        -- Enable: force STANDALONE mode + feature-enable so the
        -- preview is always visible, then build the roster. We
        -- don't persist the forced mode change — it's a side effect
        -- of opening the preview, the user picked the mode already
        -- via the dropdown.
        _standaloneTestActive = true
        _standaloneTestRoster = _buildStandaloneTestRoster()
        if BIT.db then
            BIT.db.partyCooldownsFrameMode = "STANDALONE"
            BIT.db.partyCooldownsEnabled   = true
        end
    end
    self:RebuildAnchors()
end

------------------------------------------------------------
-- Hide every icon without touching CD state — used when we cross into
-- a context where the user has the feature toggled off (e.g. entering
-- a raid with "Show in Raid" disabled). Re-entering an enabled context
-- triggers a normal RebuildAnchors which re-Shows the icons with the
-- still-running cooldown timers intact.
------------------------------------------------------------
local function HideAllIcons()
    for _name, byId in pairs(_icons) do
        for _spellId, icon in pairs(byId) do
            StopGlow(icon)
            icon:Hide()
        end
    end
    -- The standalone container is independent of the per-icon table —
    -- hide it too so it doesn't linger as a stray drag handle in
    -- contexts the user disabled (raid / arena / etc.).
    if _standaloneFrame then _standaloneFrame:Hide() end
end

------------------------------------------------------------
-- Hide icons whose owner is no longer in the group.
--
-- Icons are keyed by player NAME (stable across roster reshuffles),
-- but they're PARENTED to a unit-slot frame (party1, party2, ...) that
-- changes occupant when someone leaves and another player takes the
-- slot. Without this cleanup, the old player's icons stay parented to
-- the same slot frame and overlap the new occupant's icon row.
--
-- Runs on every GROUP_ROSTER_UPDATE / PLAYER_ENTERING_WORLD so a
-- single roster change cleans up immediately — no /reload needed.
-- State tables (_cdEnd, _glowEnd) are intentionally KEPT so if the
-- same player rejoins the group within their CD window, the timer
-- restores. Memory grows by spell-count * unique-players-this-session
-- which is bounded and gets wiped on /reload anyway.
------------------------------------------------------------
local function HideIconsOfDepartedMembers()
    -- Set of names currently in the group (player + party1..4).
    -- When the "Show own cooldowns" toggle is off, we deliberately
    -- exclude the local player from `present` — that makes the loop
    -- below treat player icons as orphaned and hide them, the same
    -- way it does for a teammate who left the group.
    local showOwn = not (BIT.db and BIT.db.partyCooldownsShowOwn == false)
    local present = {}
    for _, unit in ipairs(PARTY_UNITS) do
        if UnitExists(unit) then
            if not (unit == "player" and not showOwn) then
                local n = FullName(unit)
                if n then present[n] = true end
            end
        end
    end

    for name, byId in pairs(_icons) do
        if not present[name] then
            for _spellId, icon in pairs(byId) do
                StopGlow(icon)
                icon:Hide()
            end
        end
    end
end

------------------------------------------------------------
-- Apply the current visibility context — called on zone change AND
-- when the user flips one of the Visibility checkboxes in settings.
-- Idempotent: safe to call multiple times in a row.
------------------------------------------------------------
function PCD:ApplyVisibility()
    if not _enabled then return end
    if ShouldBeVisibleHere() then
        -- Make sure the per-event observer + per-frame Tick are running
        -- for this tracked context (idempotent — RegisterEvent is a
        -- no-op when already registered).
        RegisterAuraObserver()
        if _tickFrame then _tickFrame:Show() end
        -- Always run the orphan-cleanup pass first. This handles two
        -- cases that ApplyVisibility now has to react to live:
        --   • A toggle of "Show own cooldowns" off → player icons need
        --     to disappear without waiting for a roster event.
        --   • A roster change we already handled (idempotent — no-op
        --     when everyone's icons match the current group).
        HideIconsOfDepartedMembers()
        self:RebuildAnchors()
    else
        -- IDLE CONTEXT (e.g. a raid with "Show in Raid" off). Drop ALL
        -- per-event and per-frame work so the addon costs essentially
        -- nothing here. Without this, the broad UNIT_AURA /
        -- UNIT_SPELLCAST_SUCCEEDED registrations keep firing for every
        -- unit in the instance (40 raiders + nameplates) and run the
        -- handler on each fire just to filter it out — the bulk of the
        -- CPU the user sees when a module isn't even being shown. The
        -- roster handler stays registered (cheap, fires rarely) so a
        -- zone change back into a tracked context re-registers the
        -- observer + Tick via this same function and rescans.
        UnregisterAuraObserver()
        if _tickFrame then _tickFrame:Hide() end
        HideAllIcons()
    end
end

------------------------------------------------------------
-- Refresh tooltip mouse-state on every live icon. Called from the
-- "Show tooltip" checkbox in the settings UI so flipping the toggle
-- applies instantly without needing a roster event or /reload.
------------------------------------------------------------
function PCD:RefreshTooltips()
    local on = BIT.db and BIT.db.partyCooldownsShowTooltip ~= false or false
    for _name, byId in pairs(_icons) do
        for _spellId, icon in pairs(byId) do
            icon:EnableMouse(on)
            if not on then
                -- Force-hide any open tooltip whose owner is one of
                -- our icons — the user just turned tooltips off, so
                -- a tooltip currently shown for an icon should clear.
                if GameTooltip:IsOwned(icon) then GameTooltip:Hide() end
            end
        end
    end
end

-- Re-apply the user-configured charge-badge style (font size + offset)
-- to every existing icon. Settings sliders call this after writing the
-- new value to BIT.db so the change is visible immediately without a
-- /reload. The text content itself isn't touched — Tick / OnAuraAppeared
-- maintain it based on charge state.
function PCD:RefreshChargeBadgeStyle()
    for _name, byId in pairs(_icons) do
        for _spellId, icon in pairs(byId) do
            ApplyChargeBadgeStyle(icon)
        end
    end
end

-- Re-apply the border overlay to every existing icon. Settings UI
-- calls this after writing a new texture path / color / size / offset
-- to BIT.db so the user sees the change immediately without /reload.
-- ApplyIconBorder reads all the relevant DB keys fresh on each call,
-- so we just need to invoke it per-icon.
function PCD:RefreshBorders()
    for _name, byId in pairs(_icons) do
        for _spellId, icon in pairs(byId) do
            ApplyIconBorder(icon)
        end
    end
end

-- Expose the static spell-definitions table for read-only access
-- (the Settings UI's Spell Filter panel iterates this to build the
-- per-class checkboxes). Returning the raw table is fine because
-- nothing in the UI mutates entries — it just reads spellId/class/
-- label/cat/race fields.
function PCD:GetAllSpells()
    return SPELL_DEFS
end

-- Re-apply the user-disabled filter to all party members. Settings
-- UI's Spell Filter panel calls this after toggling a checkbox so
-- the newly-allowed / newly-disabled spells appear / disappear live
-- without a /reload. RebuildAnchors walks every roster member and
-- re-runs SpellsForMember which now respects partyCooldownsDisabled
-- via the user-disabled gate at the top of accept().
function PCD:RefreshFilter()
    if self.RebuildAnchors then self:RebuildAnchors() end
end

-- Re-apply the cooldown text font size to every existing icon. The
-- font path stays the same; only the size value changes via slider.
function PCD:RefreshCdTextStyle()
    local font = (BIT.Media and BIT.Media.font) or "Fonts\\FRIZQT__.TTF"
    local size = GetCdTextFontSize()
    for _name, byId in pairs(_icons) do
        for _spellId, icon in pairs(byId) do
            if icon.text then
                icon.text:SetFont(font, size, "OUTLINE")
            end
        end
    end
end

-- Re-evaluate the dim/desat state of every icon currently on cooldown
-- against the user's current Grayout setting. Walks _cdEnd and flips
-- alpha + desat on icons in the full-spent state. Multi-charge
-- partial icons stay bright either way. Settings slider calls this
-- when the user toggles Grayout off/on.
function PCD:RefreshCdGrayout()
    local now = GetTime()
    local gray = GetCdGrayout()
    for name, byId in pairs(_cdEnd) do
        for spellId, cdEndAt in pairs(byId) do
            if cdEndAt and cdEndAt > now then
                local icon = _icons[name] and _icons[name][spellId]
                if icon then
                    local def = icon._def
                    local partial = IsMultiChargePartial(name, def)
                    if not partial then
                        if gray then
                            icon:SetAlpha(0.65)
                            if icon.tex then icon.tex:SetDesaturated(true) end
                        else
                            icon:SetAlpha(1.0)
                            if icon.tex then icon.tex:SetDesaturated(false) end
                        end
                    end
                end
            end
        end
    end
end

local function OnRosterOrEditMode()
    if not _enabled then return end
    -- Hide icons left over from members who departed since the last
    -- roster update. Without this, when player A leaves party1 and
    -- player B takes the slot, A's icons stay parented to the slot
    -- frame and visually overlap B's new icon row.
    HideIconsOfDepartedMembers()
    -- ApplyVisibility is the single source of truth for whether the
    -- aura observer + Tick run: it (re-)registers them in a tracked
    -- context and tears them down in an idle one. We no longer
    -- unconditionally RegisterAuraObserver here — that would re-arm the
    -- broad events in an idle context (raid w/ Show-in-Raid off) right
    -- after ApplyVisibility tore them down. (The old per-unit re-bind
    -- rationale no longer applies: the observer uses a broad
    -- RegisterEvent, for which re-registering is a plain no-op.)
    PCD:ApplyVisibility()
    -- Full-update sweep to pick up pre-existing buffs on the resolved
    -- party members — but only when we're actually tracking this
    -- context (observer is live). Skipped in an idle context.
    if ShouldBeVisibleHere() then
        for _, unit in ipairs(PARTY_UNITS) do
            if UnitExists(unit) then
                OnUnitAura(nil, "UNIT_AURA", unit, { isFullUpdate = true })
            end
        end
    end
end

local function RegisterRosterHandler()
    if not _rosterFrame then
        _rosterFrame = CreateFrame("Frame")
        _rosterFrame:SetScript("OnEvent", BIT.Prof.Wrap("PARTY_CDS", OnRosterOrEditMode))
    end
    _rosterFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    _rosterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    _rosterFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
    -- Role changes (respec inside an existing group, role re-assign in
    -- the group finder) feed the stale-spec reconciliation in
    -- RebuildAnchors — same debounced rebuild path as roster changes.
    _rosterFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
end

local function UnregisterRosterHandler()
    if _rosterFrame then _rosterFrame:UnregisterAllEvents() end
end

------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------
function PCD:Enable()
    if _enabled then return end
    _enabled = true

    -- Restore the persistent spec/talent cache BEFORE registering for
    -- aura events. This way the very first RebuildAnchors below sees
    -- the priest's spec from the previous session and renders Pain
    -- Suppression immediately — without waiting for LibSpec to sync
    -- (which is delayed by comm restrictions inside M+ instances).
    _loadCache()

    -- Restore the learned aura-icon → def mappings. Combined with the
    -- init-time _spellByTexture build, this gives the texture-fallback
    -- path the broadest possible coverage right at /reload time —
    -- crucial for M+ where party-member spellIds arrive tainted.
    _loadLearnedTextures()

    RegisterAuraObserver()
    RegisterRosterHandler()

    if not _tickFrame then
        _tickFrame = CreateFrame("Frame")
        _tickFrame:SetScript("OnUpdate", BIT.Prof.Wrap("PARTY_CDS", Tick))
    else
        _tickFrame:Show()
    end

    -- Kick off the initial anchor + a full aura rescan so we catch any
    -- pre-existing buffs (e.g. someone got Pain Suppression cast on
    -- them right before we loaded). ApplyVisibility routes to either
    -- RebuildAnchors (visible context) or HideAllIcons (disabled
    -- context), so a player logging in inside a disabled zone won't
    -- see a brief flash of icons before the gate kicks in.
    self:ApplyVisibility()
    -- Initial sweep only when this context is actually tracked —
    -- ApplyVisibility tears the observer down in an idle context, so
    -- there's nothing to render there.
    if ShouldBeVisibleHere() then
        for _, unit in ipairs(PARTY_UNITS) do
            if UnitExists(unit) then
                OnUnitAura(nil, "UNIT_AURA", unit, { isFullUpdate = true })
            end
        end
    end
end

function PCD:Disable()
    if not _enabled then return end
    _enabled = false
    UnregisterAuraObserver()
    UnregisterRosterHandler()
    if _tickFrame then _tickFrame:Hide() end

    -- Hide every active icon AND any active LibButtonGlow overlay.
    -- State (_cdEnd / _glowEnd) is kept so re-enabling restores the
    -- running cooldowns without losing data.
    for name, byId in pairs(_icons) do
        for spellId, icon in pairs(byId) do
            StopGlow(icon)
            icon:Hide()
        end
    end
end

function PCD:IsEnabled()
    return _enabled
end

-- True when the module is enabled AND set to show in the current zone
-- (so the aura observer is actually running here). Used by the minimap
-- tooltip to report active vs idle.
function PCD:IsActiveHere()
    return _enabled and ShouldBeVisibleHere() or false
end

------------------------------------------------------------
-- Auto-enable on login, gated by BIT.db.partyCooldownsEnabled.
-- Deferred via PLAYER_LOGIN so BIT.db is populated (the defaults merge
-- happens in Core.lua during ADDON_LOADED and BIT.db is the active
-- profile's table after BIT.Profiles:Initialize() runs).
------------------------------------------------------------
local _bootFrame = CreateFrame("Frame")
_bootFrame:RegisterEvent("PLAYER_LOGIN")
_bootFrame:SetScript("OnEvent", function()
    if BIT.db and BIT.db.partyCooldownsEnabled then
        PCD:Enable()
    end
end)

------------------------------------------------------------
-- Slash command for quick testing during early development.
-- `/bitpcd` toggles the feature on / off without round-tripping
-- through the settings UI (which we haven't wired up yet).
-- Also persists the flag to BIT.db.partyCooldownsEnabled so the
-- choice survives a /reload.
------------------------------------------------------------
------------------------------------------------------------
-- Test mode — applies fake cooldowns to every visible party member's
-- full class spell list so the user can see icons RIGHT NOW without
-- waiting for someone to actually cast a defensive. Useful for
-- positioning the anchor + verifying the frame resolver works.
--
-- Each spell gets a randomised CD between 5..60s so the cooldown
-- swipe + countdown text are visibly different across icons. Re-runs
-- of /bitpcd test refresh those random values.
------------------------------------------------------------
function PCD:Test()
    if not _enabled then self:Enable() end
    -- Bypass the context visibility gate for the duration of the test
    -- so the user can lay out icons regardless of what zone they're
    -- in. Cleared by PCD:Clear() (or another /bitpcd clear).
    _testMode = true
    local now = GetTime()
    local hits = 0
    for _, unit in ipairs(PARTY_UNITS) do
        if UnitExists(unit) then
            local name = FullName(unit)
            local cls  = UnitClassFile(unit)
            local _, race = UnitRace(unit)
            local list = name and cls and SpellsForMember(name, cls, race)
            if list and #list > 0 then
                -- Make sure the frame parent is resolved before we
                -- populate icons; otherwise EnsureIconsFor returns
                -- silently and the icons never appear.
                EnsureIconsFor(unit, name, cls)
                _cdEnd[name] = _cdEnd[name] or {}
                _glowEnd[name] = _glowEnd[name] or {}
                for _, def in ipairs(list) do
                    local fakeCd = math.random(5, 60)
                    _cdEnd[name][def.spellId] = now + fakeCd
                    local icon = _icons[name] and _icons[name][def.spellId]
                    if icon then
                        icon:Show()
                        if icon.cd then icon.cd:SetCooldown(now, fakeCd) end
                        icon.tex:SetDesaturated(true)
                        icon:SetAlpha(0.65)
                        -- Fake a buff-active glow on roughly a third of
                        -- the icons so the user sees what the glow
                        -- effect looks like during the layout test.
                        if math.random() < 0.33 then
                            StartGlow(icon)
                            _glowEnd[name][def.spellId] = now + (def.dur or 6)
                        end
                        hits = hits + 1
                    end
                end
            end
        end
    end
    print("|cff0091edBIT|r |cFF88FFAA[PartyCooldowns]|r test layout applied: "
          .. hits .. " icon(s) across the party. Random CDs 5..60s.")
end

------------------------------------------------------------
-- Clear all currently-tracked cooldowns and hide every icon. Used to
-- wipe the fake-CD output of :Test() so the user gets back to a
-- clean state without /reload. Real CDs would just rebuild themselves
-- on the next aura observation; for test data this is the only way
-- to make the fake state go away.
------------------------------------------------------------
function PCD:Clear()
    -- Leaving test mode if /bitpcd test was running so subsequent
    -- visibility evaluations honour the context settings again.
    _testMode = false
    for _, byId in pairs(_cdEnd) do
        for spellId in pairs(byId) do
            byId[spellId] = nil
        end
    end
    -- Wipe poll instance tracking so the next genuine cast counts as
    -- "fresh instance" and re-fires OnAuraAppeared cleanly.
    for _, byId in pairs(_lastInst) do
        for spellId in pairs(byId) do
            byId[spellId] = nil
        end
    end
    -- Also hide every active glow overlay so leftover glows from a
    -- previous Test() or live cast don't keep pulsing on icons whose
    -- state we just wiped.
    for name, byId in pairs(_glowEnd) do
        for spellId in pairs(byId) do
            local icon = _icons[name] and _icons[name][spellId]
            if icon then
                StopGlow(icon)
            end
            byId[spellId] = nil
        end
    end
    -- Wipe charge-queue state too so multi-charge spells start with
    -- full charges again after a /bitpcd clear.
    for name, byId in pairs(_chargeQueue) do
        for spellId in pairs(byId) do
            byId[spellId] = nil
        end
    end
    -- Wipe the per-cast dedup timestamps so the next OnAuraAppeared
    -- after Clear isn't blocked by a stale "already committed" marker.
    for _, byId in pairs(_lastCommitAt) do
        for spellId in pairs(byId) do
            byId[spellId] = nil
        end
    end
    -- Reset every icon to its "ready" visual state — bright, opaque, no
    -- countdown text, no cooldown swipe. We keep the icons SHOWN (since
    -- the always-visible-icons behaviour added in this phase makes them
    -- a persistent part of the unit frame); only their state is wiped.
    -- Charge badges are reset via SetChargeBadgeText so multi-charge
    -- spells show their max count (e.g. "2") instead of going blank.
    for name, byId in pairs(_icons) do
        for _, icon in pairs(byId) do
            icon:SetAlpha(1.0)
            if icon.tex then icon.tex:SetDesaturated(false) end
            icon.text:SetText("")
            if icon.cd then icon.cd:Clear() end
            SetChargeBadgeText(name, icon)
        end
    end
    -- After clearing test data, re-apply the real visibility context.
    -- If the user was in a disabled zone but /bitpcd test forced icons
    -- visible, /bitpcd clear should hide them again.
    PCD:ApplyVisibility()
end

------------------------------------------------------------
-- Diagnostic dump — prints what the module currently believes about
-- the party + the on-screen frame resolver. Useful when icons aren't
-- showing up and you need to know whether the issue is frame anchor
-- resolution, class detection, or the spell DB lookup.
------------------------------------------------------------
function PCD:Dump()
    print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/dump]|r ────────────")
    print("  enabled            : " .. tostring(_enabled))
    print("  db.provider        : " .. tostring(BIT.db and BIT.db.partyCooldownsProvider))
    print("  db.anchorPos       : " .. tostring(BIT.db and BIT.db.partyCooldownsAnchorPos))
    print("  BIT.UnitFrames     : " .. tostring(BIT.UnitFrames ~= nil))
    print("  BIT.Taint          : " .. tostring(BIT.Taint ~= nil)
          .. " (ResolveNumber=" .. tostring(BIT.Taint and BIT.Taint.ResolveNumber ~= nil) .. ")")
    -- Show all the toggles that gate icon visibility, so a "icons
    -- aren't appearing" symptom can be matched to the exact setting
    -- that's hiding them.
    local function tf(v) return v and "true" or "false" end
    print("  Context check      : visible="
          .. tf(ShouldBeVisibleHere())
          .. " ctx=" .. GetInstanceContextKey())
    print("  Display toggles    : showOwn="
          .. tf(BIT.db and BIT.db.partyCooldownsShowOwn ~= false)
          .. " showTooltip="
          .. tf(BIT.db and BIT.db.partyCooldownsShowTooltip ~= false))
    print("  Zone toggles       : dungeon="
          .. tf(BIT.db and BIT.db.partyCooldownsShowInDungeon ~= false)
          .. " raid=" .. tf(BIT.db and BIT.db.partyCooldownsShowInRaid)
          .. " world=" .. tf(BIT.db and BIT.db.partyCooldownsShowInOpenWorld ~= false)
          .. " arena=" .. tf(BIT.db and BIT.db.partyCooldownsShowInArena ~= false)
          .. " bg=" .. tf(BIT.db and BIT.db.partyCooldownsShowInBG))
    if BIT.UnitFrames and BIT.UnitFrames.CountFrameAddons then
        print("  3rd-party providers: " .. tostring(BIT.UnitFrames:CountFrameAddons()))
    end

    -- LibSpec status — counts how many specs / talent maps are known
    -- right now. Useful for diagnosing the "icons disappeared after a
    -- /reload inside an instance" case where LibSpec comm is throttled
    -- by the dungeon.
    local specCount, talentCount = 0, 0
    for _ in pairs(_specByName)    do specCount   = specCount   + 1 end
    for _ in pairs(_talentsByName) do talentCount = talentCount + 1 end
    local liveCount = 0
    for _, u in ipairs(PARTY_UNITS) do if UnitExists(u) then liveCount = liveCount + 1 end end
    print("  LibSpec known      : " .. specCount .. " specs / " .. talentCount .. " talent maps  (live members: " .. liveCount .. ")")

    -- Persistent cache size — entries on disk that survive /reload.
    local cacheCount = 0
    if BliZziInterruptsSavedVars and BliZziInterruptsSavedVars.partyCDPlayerCache then
        for _ in pairs(BliZziInterruptsSavedVars.partyCDPlayerCache) do
            cacheCount = cacheCount + 1
        end
    end
    print("  Persistent cache   : " .. cacheCount .. " players (saved across /reload)")

    -- Lookup-index sizes — empty indexes mean the spell DB wasn't
    -- queryable at addon-init time (rare).
    local texCount = 0
    for _ in pairs(_spellByTexture) do texCount = texCount + 1 end
    local learnedCount = 0
    if BliZziInterruptsSavedVars and BliZziInterruptsSavedVars.partyCDLearnedTextures then
        for _ in pairs(BliZziInterruptsSavedVars.partyCDLearnedTextures) do
            learnedCount = learnedCount + 1
        end
    end
    print("  Index sizes        : auraId=" .. (#SPELL_DEFS)
          .. " castId=" .. (#SPELL_DEFS)
          .. " tex=" .. texCount
          .. " (learned=" .. learnedCount .. ")")

    print("  ── pipeline counters ──────────────────")
    print("    UNIT_AURA fires       : " .. _stats.unitAuraFired)
    print("    full updates          : " .. _stats.fullUpdates)
    print("    addedAuras seen       : " .. _stats.addedAurasSeen)
    print("    SafeAuraLookup fast   : " .. _stats.lookupFastHit)
    print("    SafeAuraLookup taint  : " .. _stats.lookupTaintHit)
    print("    SafeAuraLookup tex    : " .. _stats.lookupTextureHit)
    print("    SafeAuraLookup class  : " .. _stats.lookupClassifyHit)
    print("    SafeAuraLookup string : " .. (_stats.lookupStringHit or 0))
    print("    SafeAuraLookup byte   : " .. (_stats.lookupByteHit or 0))
    print("    SafeAuraLookup name   : " .. (_stats.lookupNameHit or 0))
    print("    SafeAuraLookup refetch: " .. (_stats.lookupRefetchHit or 0))
    print("    SafeAuraLookup last   : " .. (_stats.lookupLastResortHit or 0))
    print("    attribution reassigns : " .. (_stats.attributionReassigns or 0))
    print("    SafeAuraLookup miss   : " .. _stats.lookupMiss)
    print("    OnAuraAppeared        : " .. _stats.onAuraAppeared)
    print("    caster fallback used  : " .. _stats.casterFallback)
    print("    casters dropped       : " .. _stats.castersDropped)
    print("    CDs committed         : " .. _stats.cdsCommitted)
    print("    all casts seen (any)  : " .. _stats.allCastsSeen)
    print("    party casts seen      : " .. _stats.partyCastsSeen)
    print("    player casts seen     : " .. _stats.playerCastSeen)
    print("    player casts matched  : " .. _stats.playerCastMatched)
    print("    poll runs             : " .. _stats.pollRuns)
    print("    poll deferred         : " .. _stats.pollDeferred)
    print("    poll probes           : " .. _stats.pollProbes)
    print("    poll skips (neg cache): " .. _stats.pollSkipsRejected)
    print("    proc skips (minDur)   : " .. (_stats.procSkips or 0))
    print("    poll probes found     : " .. _stats.pollProbeFound)
    print("    poll probes errored   : " .. _stats.pollProbeErrors)
    print("    poll hits (new inst)  : " .. _stats.pollHits)
    print("    refresh glow-only     : " .. (_stats.refreshGlowOnly or 0))
    print("    refresh full-commit   : " .. (_stats.refreshFullCommit or 0))
    print("  ── party members ─────────────────────")
    for _, unit in ipairs(PARTY_UNITS) do
        if UnitExists(unit) then
            local name = FullName(unit)
            local cls  = UnitClassFile(unit)
            local providerHint = (BIT.db and BIT.db.partyCooldownsProvider) or "AUTO"
            if providerHint == "AUTO" then providerHint = nil end
            local parent = BIT.UnitFrames and BIT.UnitFrames:GetPartyFrame(unit, providerHint)
            local parentName = parent and parent:GetName() or "<nil>"
            local parentVis  = parent and parent:IsVisible() and "visible" or "hidden/nil"
            local spellCount = (cls and _spellsByClass[cls]) and #_spellsByClass[cls] or 0
            local activeIcons, totalIcons = 0, 0
            if name and _icons[name] then
                for _, icon in pairs(_icons[name]) do
                    totalIcons = totalIcons + 1
                    if icon:IsShown() then activeIcons = activeIcons + 1 end
                end
            end
            -- LibSpec status per member — "spec=?" means we have no
            -- spec data yet (typical post-/reload-in-M+ symptom), so
            -- spec-gated entries are filtered. "talents=N" is the
            -- size of the parsed talent map.
            local memberSpec = GetSpecForName(name)
            local memberTalents = GetKnownTalentsForName(name)
            local talentCount = 0
            if memberTalents then
                for _ in pairs(memberTalents) do talentCount = talentCount + 1 end
            end
            local specStr = memberSpec and tostring(memberSpec) or "?"
            local talentStr = memberTalents and tostring(talentCount) or "?"
            print("  " .. unit .. " " .. tostring(name) .. " [" .. tostring(cls) .. "] "
                  .. "spec=" .. specStr .. " talents=" .. talentStr
                  .. " spells=" .. spellCount .. " icons=" .. totalIcons
                  .. " shown=" .. activeIcons
                  .. " frame=" .. parentName .. " (" .. parentVis .. ")")
        end
    end
    print("  ──────────────────────────────────────")
end

------------------------------------------------------------
-- Manual aura scan — walks every helpful aura currently active on
-- each party unit and reports whether SafeAuraLookup recognises it.
-- Bypasses the live UNIT_AURA event entirely, so we can tell whether
-- the failure mode is "no UNIT_AURA events arriving" or "events
-- arriving but lookup misses everything".
------------------------------------------------------------
function PCD:Scan()
    print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/scan]|r ────────────")
    if not AuraUtil or not AuraUtil.ForEachAura then
        print("  AuraUtil.ForEachAura not available")
        return
    end
    for _, unit in ipairs(PARTY_UNITS) do
        if UnitExists(unit) then
            local name = FullName(unit) or "?"
            local cls  = UnitClassFile(unit) or "?"
            local total, matched = 0, 0
            local matchNames = {}
            -- Set _lookupUnit so classification probes have the right
            -- unit context for IsAuraFilteredOutByInstanceID.
            _lookupUnit = unit
            AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(aura)
                total = total + 1
                if not aura then return end
                -- 3.8.6: do NOT read aura.spellId here either. Pass the
                -- aura through to SafeAuraLookup which will identify via
                -- auraInstanceID + classification only.
                local def = SafeAuraLookup(aura)
                if def then
                    matched = matched + 1
                    matchNames[#matchNames + 1] = def.label
                end
            end, true)
            _lookupUnit = nil
            print(string.format("  %-7s %s [%s] auras=%d matched=%d %s",
                unit, name, cls, total, matched,
                (#matchNames > 0) and ("→ " .. table.concat(matchNames, ", ")) or ""))
        end
    end
    print("  ──────────────────────────────────────")
end

------------------------------------------------------------
-- Per-aura runtime flag dump. For each party member, lists every
-- helpful aura with its raw Blizzard-classification flag-key (BIG /
-- EXT / IMP / RAID probes via IsAuraFilteredOutByInstanceID), its
-- clean duration if readable, and whether it matched a tracked def.
-- Use this when SafeAuraLookup misses a buff to see exactly which
-- flags the runtime aura carries vs what our def expects.
------------------------------------------------------------
function PCD:DumpAuras()
    print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/auras]|r ────────────")
    print("  legend: flag-key = BIG/EXT/IMP/RAID (- = absent)")
    if not C_UnitAuras or not AuraUtil or not AuraUtil.ForEachAura then
        print("  required APIs not available")
        return
    end
    for _, unit in ipairs(PARTY_UNITS) do
        if UnitExists(unit) then
            local name = FullName(unit) or "?"
            local cls  = UnitClassFile(unit) or "?"
            print(string.format("  ── %s %s [%s] ──", unit, name, cls))
            AuraUtil.ForEachAura(unit, "HELPFUL", nil, function(aura)
                if not aura or not aura.auraInstanceID then return end
                local instId = aura.auraInstanceID
                -- Flag probes (same logic as MatchAuraByClassification).
                local function matches(filter)
                    local ok, filtered = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID, unit, instId, filter)
                    return ok and (filtered == false)
                end
                local isBig  = matches("HELPFUL|BIG_DEFENSIVE")
                local isExt  = matches("HELPFUL|EXTERNAL_DEFENSIVE")
                local isImp  = matches("HELPFUL|IMPORTANT")
                local isRaid = matches("HELPFUL|RAID")
                local key =
                    (isBig and "B" or "-") ..
                    (isExt and "E" or "-") ..
                    (isImp and "I" or "-") ..
                    (isRaid and "R" or "-")
                -- Duration (clean-screened).
                local durStr = "?"
                local okD, d = pcall(C_UnitAuras.GetAuraDuration, unit, instId)
                if okD and type(d) == "number" then
                    local okS, isSec = pcall(issecretvalue, d)
                    if okS and not isSec then
                        durStr = string.format("%.1fs", d)
                    else
                        durStr = "secret"
                    end
                end
                -- Try to read spellId (may be tainted in M+).
                local sidStr = "?"
                local okS, sid = pcall(function() return aura.spellId end)
                if okS and type(sid) == "number" then
                    local okSec, isSec = pcall(issecretvalue, sid)
                    if okSec and not isSec then
                        sidStr = tostring(sid)
                    else
                        sidStr = "secret"
                    end
                end
                -- Try to read name (may also be tainted).
                local nameStr = "?"
                local okN, n = pcall(function() return aura.name end)
                if okN and type(n) == "string" then
                    local okSec, isSec = pcall(issecretvalue, n)
                    if okSec and not isSec then
                        nameStr = n
                    else
                        nameStr = "<secret>"
                    end
                end
                -- Does it match any of our defs by flag-key?
                local matchLabel = ""
                for _, classDefs in pairs(_spellsByClass) do
                    for _, def in ipairs(classDefs) do
                        if def._auraFlagKey == key and def.class == cls then
                            matchLabel = matchLabel .. " ~" .. def.label
                        end
                    end
                end
                local color = (key == "----") and "|cFFAAAAAA" or "|cFF88FF88"
                print(string.format("    %s[%s]|r dur=%s sid=%s name=%s%s",
                    color, key, durStr, sidStr, nameStr, matchLabel))
            end, true)
        end
    end
    print("  ──────────────────────────────────────")
end

------------------------------------------------------------
-- Reset all diagnostic counters back to 0 so a fresh observation
-- window doesn't have stale data baked in. Useful before reproducing
-- a "no spells show up" scenario step by step.
------------------------------------------------------------
-- Wipe the persistent spec/talent cache + the in-memory maps + the
-- learned-texture cache. Useful when debugging stale-cache scenarios
-- or when a player has respec'd multiple times and you want to start
-- fresh. Public so the settings UI can offer a button.
function PCD:ClearSpecCache()
    local sv = BliZziInterruptsSavedVars
    if sv then
        sv.partyCDPlayerCache    = nil
        sv.partyCDLearnedTextures = nil
    end
    for k in pairs(_specByName)    do _specByName[k]    = nil end
    for k in pairs(_talentsByName) do _talentsByName[k] = nil end
    -- Don't wipe _spellByTexture entirely — the init-time entries are
    -- still valid (they came from the spell DB, not a cache). Only
    -- the runtime-learned entries above their precomputed value
    -- would be removed, but those re-learn on next observation.
    print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns]|r spec/talent + learned-texture cache wiped.")
    if _enabled then PCD:RebuildAnchors() end
end

function PCD:ResetStats()
    for k in pairs(_stats) do _stats[k] = 0 end
    -- Also reset the per-function profile timers so the next
    -- /bitpcd prof reflects the fresh observation window.
    for _, p in pairs(_prof) do
        p.calls = 0
        p.total = 0
        p.max   = 0
    end
    print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns]|r diagnostic counters + profile reset.")
end

-- Per-function CPU profile dump. Shows calls / total ms / avg µs /
-- worst single-call ms for each instrumented hot path. Use after a
-- representative play window (M+ encounter, raid pull etc.) to see
-- where the addon is actually spending time.
function PCD:DumpProfile()
    print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/prof]|r ────────────")
    print(string.format("  %-12s %10s %12s %12s %10s",
        "function", "calls", "total ms", "avg µs", "max ms"))
    -- Stable ordering so output is comparable run-to-run.
    local order = { "onAura", "scan", "classify", "onAppear", "tick" }
    for _, key in ipairs(order) do
        local p = _prof[key]
        if p then
            local avgUs = p.calls > 0 and (p.total * 1000 / p.calls) or 0
            print(string.format("  %-12s %10d %12.2f %12.2f %10.2f",
                key, p.calls, p.total, avgUs, p.max))
        end
    end
    print("  ──────────────────────────────────────")
end

-- Print which spells in our DB are tagged with Blizzard's filter
-- flags (BIG_DEFENSIVE / EXTERNAL_DEFENSIVE / IMPORTANT). These are
-- the spells the classification-fallback can identify in M+ when
-- spellId + icon are tainted. Spells with no flags can only be
-- detected via the clean-spellId fast path or the texture fallback.
--
-- Backed by three Blizzard APIs:
--   • C_UnitAuras.AuraIsBigDefensive(spellId)
--   • C_Spell.IsExternalDefensive(spellId)
--   • C_Spell.IsSpellImportant(spellId)
-- Print what's mapped to a specific texture file ID in our index.
-- Usage:  /bitpcd tex 132089
-- Helps verify "is Shadowmeld's texture actually indexed?" without
-- having to dump the whole table. Also shows what C_Spell.GetSpellTexture
-- returns for the spell, in case the cast button texture differs from
-- the buff aura texture.
function PCD:DumpTexture(arg)
    if not arg or arg == "" then
        print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/tex]|r usage: /bitpcd tex <textureFileID>")
        return
    end
    local tex = tonumber(arg)
    if not tex then
        print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/tex]|r not a number: " .. tostring(arg))
        return
    end
    local def = _spellByTexture[tex]
    if def then
        print(string.format("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/tex]|r %d → |cFF88FF88%s|r (spellId=%d class=%s race=%s)",
            tex, def.label or "?", def.spellId, tostring(def.class or "-"), tostring(def.race or "-")))
    else
        print(string.format("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/tex]|r %d → |cFFFF8888not indexed|r", tex))
    end
    -- Also reverse-check: what does C_Spell.GetSpellTexture return
    -- for every def whose spellId or auraId we might have indexed?
    -- Print only the ones whose texture is "close" to the queried
    -- value (numeric proximity = different version of the same icon
    -- on rare reskins). Useful to spot "we indexed X but the aura
    -- uses Y" mismatches.
    print("  ── reverse-check ─────────────────────")
    for _, def in ipairs(SPELL_DEFS) do
        local function checkOne(sid, label)
            if not sid then return end
            local ok, t = pcall(C_Spell.GetSpellTexture, sid)
            if ok and t and t == tex then
                print(string.format("    %s spellId=%d (%s) → texture %d (match)",
                    label, sid, def.label or "?", t))
            end
        end
        checkOne(def.spellId, "cast")
        if def.auraId and def.auraId ~= def.spellId then checkOne(def.auraId, "aura") end
    end
end

function PCD:DumpFlags()
    print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/flags]|r ── Blizzard category flags per tracked spell")
    print("  legend: B=BIG_DEFENSIVE  E=EXTERNAL_DEFENSIVE  I=IMPORTANT  R=RAID(hardcoded)  -=not flagged")
    local classifiable, total = 0, 0
    for _, def in ipairs(SPELL_DEFS) do
        total = total + 1
        -- Probe both spellId AND auraId (when they differ) to mirror
        -- the OR-logic in def._auraFlagKey. Blizzard's spell-DB flags
        -- sometimes live on only one side of the cast → aura pair.
        local function probe(sid)
            if not sid then return false, false, false end
            local okB, isBig = pcall(C_UnitAuras.AuraIsBigDefensive, sid)
            local okE, isExt = pcall(C_Spell.IsExternalDefensive,    sid)
            local okI, isImp = pcall(C_Spell.IsSpellImportant,        sid)
            return (okB and isBig) or false,
                   (okE and isExt) or false,
                   (okI and isImp) or false
        end
        local bC, eC, iC = probe(def.spellId)
        local bA, eA, iA = false, false, false
        if def.auraId and def.auraId ~= def.spellId then
            bA, eA, iA = probe(def.auraId)
        end
        local b = (bC or bA) and "B" or "-"
        local e = (eC or eA) and "E" or "-"
        local i = (iC or iA) and "I" or "-"
        local r = def.raid and "R" or "-"
        local rawFlags = b .. e .. i .. r
        -- Effective key: what the def actually carries after manual
        -- additive (big/external/important/raid) and negative
        -- (notBig/notExternal/notImportant) overrides plus the
        -- whole-key `flagKey` override are applied. Differs from raw
        -- when the spell-DB API disagrees with the live runtime aura.
        local effectiveFlags = def._auraFlagKey or rawFlags
        if effectiveFlags ~= "----" then classifiable = classifiable + 1 end
        local color = (effectiveFlags == "----") and "|cFFFF8888" or "|cFF88FF88"
        local overrideTag = (rawFlags ~= effectiveFlags) and (" |cFFFFAA00(raw="..rawFlags..")|r") or ""
        print(string.format("  %s[%s]|r %d %s%s (class=%s spec=%s)",
            color, effectiveFlags, def.spellId, tostring(def.label), overrideTag,
            tostring(def.class or "-"), tostring(def.spec or "-")))
    end
    print(string.format("|cff0091edBIT|r summary: %d/%d spells classifiable via flag-key (B/E/I from Blizzard APIs + R from def.raid)",
        classifiable, total))
end

-- Probe the Blizzard category flags for an ARBITRARY spell id (one not yet
-- in our DB), including the AUTHORITATIVE live-aura check. The spell-DB
-- probe (AuraIsBigDefensive/IsExternalDefensive/IsSpellImportant) very
-- frequently returns false even when the buff carries the flag at runtime,
-- so the live check is the one that decides whether a manual override is
-- needed. Cast the buff first, then run `/bitpcd flagid <id>` while active.
function PCD:DumpFlagId(spellId)
    spellId = tonumber(spellId)
    if not spellId then
        print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/flagid]|r usage: /bitpcd flagid <spellID>")
        return
    end
    print(string.format("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/flagid]|r spell %d", spellId))

    -- 1) Spell-DB probe — exactly what DumpFlags / the def builder see.
    local okB, isBig = pcall(C_UnitAuras.AuraIsBigDefensive, spellId)
    local okE, isExt = pcall(C_Spell.IsExternalDefensive,    spellId)
    local okI, isImp = pcall(C_Spell.IsSpellImportant,        spellId)
    print(string.format("  spell-DB : BIG=%s  EXT=%s  IMP=%s",
        tostring((okB and isBig) or false),
        tostring((okE and isExt) or false),
        tostring((okI and isImp) or false)))

    -- 2) Authoritative live-aura check. Walk the player's own HELPFUL
    --    auras (self auras are non-secret) for a matching spellId, then
    --    ask the same category filter the runtime classifier uses. Only
    --    yields a result while the buff is active on you.
    local found = false
    for i = 1, 60 do
        local a = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if not a then break end
        local sameId = false
        local okS, isSec = pcall(issecretvalue, a.spellId)
        if (not okS) or (not isSec) then
            sameId = (a.spellId == spellId)
        end
        if sameId then
            found = true
            local function liveFlag(filter)
                local ok, out = pcall(C_UnitAuras.IsAuraFilteredOutByInstanceID,
                    "player", a.auraInstanceID, filter)
                if not ok then return "err" end
                return tostring(not out)
            end
            print(string.format("  live-aura: BIG=%s  EXT=%s  IMP=%s  RAID=%s   (buff active)",
                liveFlag("HELPFUL|BIG_DEFENSIVE"),
                liveFlag("HELPFUL|EXTERNAL_DEFENSIVE"),
                liveFlag("HELPFUL|IMPORTANT"),
                liveFlag("HELPFUL|RAID")))
            break
        end
    end
    if not found then
        print("  live-aura: buff not active on you — cast the spell, then re-run while it is up.")
    end
end

-- Charge-state diagnostic. Dumps, per tracked (name, spellId), the
-- internal charge bookkeeping so a "badge stuck at 0" / "2 → 0 in one
-- cast" bug can be pinpointed: how many entries are in the recharge
-- queue, each entry's remaining time, the _cdEnd mirror, the computed
-- available-charge count the badge would show, and — for the local
-- player only — the raw Blizzard GetSpellCharges values the Tick sync
-- reconciles against. A queue length that exceeds maxCharges, or a
-- _cdEnd that disagrees with queue[1], localises the desync.
function PCD:DumpCharges()
    print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns/charges]|r ── per-spell charge bookkeeping")
    local now = GetTime()
    local selfFull = FullName("player")

    -- Collect every name that has either a queue or a cdEnd entry so we
    -- show orphaned state on both sides (the desync we're hunting).
    local names = {}
    for name in pairs(_chargeQueue) do names[name] = true end
    for name in pairs(_cdEnd)      do names[name] = true end

    if not next(names) then
        print("  (no tracked charge / CD state right now)")
        return
    end

    for name in pairs(names) do
        local q  = _chargeQueue[name]
        local cd = _cdEnd[name]
        local isSelf = (name == selfFull) and " |cFF88FFAA(you)|r" or ""
        print(string.format("  ── %s%s ──", tostring(name), isSelf))

        -- Union of spellIds present in either table for this name.
        local sids = {}
        if q  then for sid in pairs(q)  do sids[sid] = true end end
        if cd then for sid in pairs(cd) do sids[sid] = true end end

        for sid in pairs(sids) do
            local def = _spellByCastId[sid] or _spellByAuraId[sid]
            local label = (def and def.label) or "?"
            local maxC  = def and GetEffectiveCharges(def, name) or 1
            local queue = q and q[sid]
            local pending = queue and #queue or 0
            local avail = maxC - pending
            if avail < 0 then avail = 0 end

            -- Format queue entries as remaining seconds.
            local qStr = "none"
            if queue and #queue > 0 then
                local parts = {}
                for i, t in ipairs(queue) do
                    parts[i] = string.format("%.1fs", t - now)
                end
                qStr = "[" .. table.concat(parts, ", ") .. "]"
            end

            local cdEndVal = cd and cd[sid]
            local cdStr = cdEndVal and string.format("%.1fs", cdEndVal - now) or "nil"

            -- Flag the classic desync conditions in orange.
            local warn = ""
            if pending > maxC then
                warn = " |cFFFFAA00<< queue>maxCharges!|r"
            elseif queue and #queue > 0 and cdEndVal and math.abs(queue[1] - cdEndVal) > 0.5 then
                warn = " |cFFFFAA00<< cdEnd != queue[1]|r"
            end

            print(string.format("    %d %s: avail=%d/%d  queue=%s  cdEnd=%s%s",
                sid, label, avail, maxC, qStr, cdStr, warn))

            -- For the local player, also show what Blizzard reports.
            if isSelf ~= "" and C_Spell and C_Spell.GetSpellCharges then
                local okC, info = pcall(C_Spell.GetSpellCharges, sid)
                if okC and info then
                    local function rd(k)
                        local ok, v = pcall(function() return info[k] end)
                        if not ok or type(v) ~= "number" then return "?" end
                        local okS, isSec = pcall(issecretvalue, v)
                        if not okS or isSec then return "secret" end
                        return tostring(v)
                    end
                    print(string.format("        Blizzard: cur=%s max=%s startTime=%s dur=%s",
                        rd("currentCharges"), rd("maxCharges"),
                        rd("cooldownStartTime"), rd("cooldownDuration")))
                end
            end
        end
    end
end

SLASH_BITPCD1 = "/bitpcd"
SlashCmdList["BITPCD"] = function(msg)
    local arg = (msg or ""):match("^%s*(%S+)") or ""
    arg = arg:lower()

    if arg == "test" then
        PCD:Test()
        return
    elseif arg == "clear" or arg == "reset" then
        PCD:Clear()
        print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns]|r cleared all tracked cooldowns + hidden icons.")
        return
    elseif arg == "dump" or arg == "debug" then
        PCD:Dump()
        return
    elseif arg == "scan" then
        PCD:Scan()
        return
    elseif arg == "auras" then
        PCD:DumpAuras()
        return
    elseif arg == "resetstats" or arg == "reset" then
        PCD:ResetStats()
        return
    elseif arg == "clearcache" or arg == "wipecache" then
        PCD:ClearSpecCache()
        return
    elseif arg == "flags" then
        PCD:DumpFlags()
        return
    elseif arg == "flagid" then
        local id = (msg or ""):match("^%s*%S+%s+(%S+)")
        PCD:DumpFlagId(id)
        return
    elseif arg == "charges" then
        PCD:DumpCharges()
        return
    elseif arg == "prof" or arg == "profile" then
        PCD:DumpProfile()
        return
    elseif arg == "off" then
        PCD:Disable()
        if BIT.db then BIT.db.partyCooldownsEnabled = false end
        print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns]|r disabled.")
        return
    elseif arg == "on" then
        PCD:Enable()
        if BIT.db then BIT.db.partyCooldownsEnabled = true end
        print("|cff0091edBIT|r |cFF88FFAA[PartyCooldowns]|r enabled.")
        return
    elseif arg == "help" or arg == "?" then
        print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns]|r commands:")
        print("  /bitpcd on         - enable the feature")
        print("  /bitpcd off        - disable the feature")
        print("  /bitpcd test       - apply fake CDs to every party member (layout test)")
        print("  /bitpcd clear      - wipe all tracked cooldowns + hide icons")
        print("  /bitpcd scan       - manually walk every party member's auras and report matches")
        print("  /bitpcd dump       - print current state + pipeline counters")
        print("  /bitpcd charges    - print per-spell charge queue + cdEnd state")
        print("  /bitpcd flagid <id> - probe a spell's BIG/EXT/IMP flags (cast the buff first for the live check)")
        print("  /bitpcd prof       - print per-function CPU profile (calls / ms / avg / max)")
        print("  /bitpcd resetstats - zero the pipeline counters + profile")
        print("  /bitpcd            - toggle on / off")
        return
    end

    -- Default: toggle
    if PCD:IsEnabled() then
        PCD:Disable()
        if BIT.db then BIT.db.partyCooldownsEnabled = false end
        print("|cff0091edBIT|r |cFFAAAAAA[PartyCooldowns]|r disabled.")
    else
        PCD:Enable()
        if BIT.db then BIT.db.partyCooldownsEnabled = true end
        print("|cff0091edBIT|r |cFF88FFAA[PartyCooldowns]|r enabled — tracking "
              .. #SPELL_DEFS .. " spells across all classes.")
    end
end
