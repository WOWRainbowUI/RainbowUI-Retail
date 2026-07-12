-- Copyright (c) 2026 BliZzi1337. All rights reserved.
-- Unauthorized copying, modification, distribution or use of this
-- software, in whole or in part, without prior written permission
-- from the copyright holder is strictly prohibited.
--[[
    Data.lua - BliZzi Interrupts
    -----------------------------------------------------------------------
    Spec-first data architecture.

    Single source of truth: BIT.SPEC_REGISTRY
      One record per WoW spec ID describing everything about that spec's
      interrupt(s). All other lookup tables (ALL_INTERRUPTS, CLASS_INTERRUPTS,
      CLASS_INTERRUPT_LIST, SPEC_INTERRUPT_OVERRIDES, etc.) are compiled
      automatically from this registry at load time.

    To add / change a spell: edit SPEC_REGISTRY only.
    -----------------------------------------------------------------------
]]

BIT = BIT or {}

------------------------------------------------------------
-- Class colours (r, g, b) — purely visual, not spell data
------------------------------------------------------------
BIT.CLASS_COLORS = {
    DEATHKNIGHT = { 0.77, 0.12, 0.23 },
    DEMONHUNTER = { 0.64, 0.19, 0.79 },
    DRUID       = { 1.00, 0.49, 0.04 },
    EVOKER      = { 0.20, 0.58, 0.50 },
    HUNTER      = { 0.67, 0.83, 0.45 },
    MAGE        = { 0.41, 0.80, 0.94 },
    MONK        = { 0.00, 1.00, 0.59 },
    PALADIN     = { 0.96, 0.55, 0.73 },
    PRIEST      = { 1.00, 1.00, 1.00 },
    ROGUE       = { 1.00, 0.96, 0.41 },
    SHAMAN      = { 0.00, 0.44, 0.87 },
    WARLOCK     = { 0.58, 0.51, 0.79 },
    WARRIOR     = { 0.78, 0.61, 0.43 },
}

------------------------------------------------------------
-- Spec Registry  (single source of truth)
------------------------------------------------------------
-- Each entry describes one spec:
--   class       WoW class token (string)
--   spellID     primary interrupt spell ID (number)
--   name        spell display name
--   cd          base cooldown in seconds
--   icon        texture ID or path
--   noKick      true  = spec has no interrupt
--   isPet       true  = kick is cast by a pet
--   petSpellID  server-side pet spell ID that maps to this spell
--   extraKicks  array of { spellID, cd, name, icon, talentCheck? }
------------------------------------------------------------
local SPEC_REGISTRY = {

    -------------------- Death Knight --------------------
    [250] = { class="DEATHKNIGHT", spellID=47528, name="Mind Freeze",        cd=15, icon=237527 },
    [251] = { class="DEATHKNIGHT", spellID=47528, name="Mind Freeze",        cd=15, icon=237527 },
    [252] = { class="DEATHKNIGHT", spellID=47528, name="Mind Freeze",        cd=15, icon=237527 },

    -------------------- Demon Hunter --------------------
    [577]  = { class="DEMONHUNTER", spellID=183752, name="Disrupt", cd=15, icon=1305153 },
    [581]  = { class="DEMONHUNTER", spellID=183752, name="Disrupt", cd=15, icon=1305153 },
    [1480] = { class="DEMONHUNTER", spellID=183752, name="Disrupt", cd=15, icon=1305153 },

    -------------------- Druid --------------------
    [102] = { class="DRUID", spellID=78675,  name="Solar Beam",              cd=45,
              icon=252188 },
    [103] = { class="DRUID", spellID=106839, name="Skull Bash",              cd=15, icon=236946 },
    [104] = { class="DRUID", spellID=106839, name="Skull Bash",              cd=15, icon=236946 },
    [105] = { class="DRUID", noKick=true },

    -------------------- Evoker --------------------
    [1467] = { class="EVOKER", spellID=351338, name="Quell",                 cd=18, icon=4622469 },
    [1468] = { class="EVOKER", spellID=351338, name="Quell",                 cd=18, icon=4622469 },
    [1473] = { class="EVOKER", spellID=351338, name="Quell",                 cd=18, icon=4622469 },

    -------------------- Hunter --------------------
    [253] = { class="HUNTER", spellID=147362, name="Counter Shot",           cd=24, icon=249170  },
    [254] = { class="HUNTER", spellID=147362, name="Counter Shot",           cd=24, icon=249170  },
    [255] = { class="HUNTER", spellID=187707, name="Muzzle",                 cd=15, icon=1376045 },

    -------------------- Mage --------------------
    -- Midnight (12.0.5): Counterspell base CD is 25s. The TWW-era passive
    -- that auto-reduced CD on a successful interrupt is gone — players
    -- now talent into "Quick Witted" (382297) for a flat -5s reduction
    -- (handled via CD_REDUCTION_DEFS below).
    [62]  = { class="MAGE", spellID=2139, name="Counterspell",               cd=25, icon=135856  },
    [63]  = { class="MAGE", spellID=2139, name="Counterspell",               cd=25, icon=135856  },
    [64]  = { class="MAGE", spellID=2139, name="Counterspell",               cd=25, icon=135856  },

    -------------------- Monk --------------------
    [268] = { class="MONK", spellID=116705, name="Spear Hand Strike",        cd=15, icon=608940  },
    [269] = { class="MONK", spellID=116705, name="Spear Hand Strike",        cd=15, icon=608940  },
    [270] = { class="MONK", noKick=true }, -- Mistweaver has no interrupt

    -------------------- Paladin --------------------
    [65]  = { class="PALADIN", noKick=true },
    [66]  = { class="PALADIN", spellID=96231, name="Rebuke",                 cd=15, icon=523893  },
    [70]  = { class="PALADIN", spellID=96231, name="Rebuke",                 cd=15, icon=523893  },

    -------------------- Priest --------------------
    [256] = { class="PRIEST", noKick=true },
    [257] = { class="PRIEST", noKick=true },
    [258] = { class="PRIEST", spellID=15487, name="Silence",                 cd=30, icon=458230  },

    -------------------- Rogue --------------------
    [259] = { class="ROGUE", spellID=1766, name="Kick",                      cd=15, icon=132219  },
    [260] = { class="ROGUE", spellID=1766, name="Kick",                      cd=15, icon=132219  },
    [261] = { class="ROGUE", spellID=1766, name="Kick",                      cd=15, icon=132219  },

    -------------------- Shaman --------------------
    [262] = { class="SHAMAN", spellID=57994, name="Wind Shear",              cd=12, icon=136018  },
    [263] = { class="SHAMAN", spellID=57994, name="Wind Shear",              cd=12, icon=136018  },
    [264] = { class="SHAMAN", spellID=57994, name="Wind Shear",              cd=30, icon=136018  }, -- Resto: 30s

    -------------------- Warlock --------------------
    [265] = { class="WARLOCK", spellID=19647, name="Spell Lock",             cd=24, icon=136174 },
    [266] = { class="WARLOCK", spellID=119914, name="Axe Toss",              cd=30,
              icon=236316,
              isPet=true, petSpellID=89766 },
    [267] = { class="WARLOCK", spellID=19647, name="Spell Lock",             cd=24, icon=136174 },

    -------------------- Warrior --------------------
    [71]  = { class="WARRIOR", spellID=6552, name="Pummel", cd=15, icon=132938 },
    [72]  = { class="WARRIOR", spellID=6552, name="Pummel", cd=15, icon=132938 },
    [73]  = { class="WARRIOR", spellID=6552, name="Pummel", cd=15, icon=132938 },
}

BIT.SPEC_REGISTRY = SPEC_REGISTRY

------------------------------------------------------------
-- Classes that keep their interrupt even as healer spec
------------------------------------------------------------
BIT.HEALER_KEEPS_KICK = {
    SHAMAN = true,  -- Restoration Shaman keeps Wind Shear
}

------------------------------------------------------------
-- Spell alias map
-- Maps IDs that fire differently on party vs own client
-- back to the canonical player-facing spell ID.
------------------------------------------------------------
local SPELL_ALIAS_MAP = {
    [1276467] = 132409,  -- Fel Ravager summon event  -> Spell Lock extra bar
    [89766]   = 119914,  -- Felguard Axe Toss (pet)   -> Axe Toss (player-facing)
    [132409]  = 132409,  -- identity: Spell Lock extra bar resolves cleanly
}

------------------------------------------------------------
-- Talent definitions
------------------------------------------------------------
local CD_REDUCTION_DEFS = {
    [388039] = { affects=147362, reduction=2,     name="Lone Survivor"      }, -- Hunter
    [412713] = { affects=351338, pctReduction=10, name="Interwoven Threads" }, -- Evoker
    [391271] = { affects=6552,   pctReduction=10, name="Seasoned Soldier", affectsExtraKicks=true }, -- Warrior (Pummel + Spell Reflection)
    [382297] = { affects=2139,   reduction=5,     name="Quick Witted"       }, -- Mage (replaces TWW's CD-on-interrupt passive)
}

local CD_ON_KICK_DEFS = {
    [378848] = { reduction=3, name="Coldthirst" }, -- Death Knight
}

local EXTRA_KICK_DEFS = {}

------------------------------------------------------------
-- Compiler: derive all BIT.* lookup tables from SPEC_REGISTRY
------------------------------------------------------------
local allSpells          = {}
local classInterruptList = {}
local classDefault       = {}
local specOverrides      = {}
local specNoKick         = {}
local specExtraKicks     = {}

local function registerSpell(id, name, cd, icon)
    if not id or not name then return end
    if not allSpells[id] then
        allSpells[id] = { name=name, cd=cd, icon=icon }
    end
end

local function appendClassSpell(class, spellID)
    classInterruptList[class] = classInterruptList[class] or {}
    for _, v in ipairs(classInterruptList[class]) do
        if v == spellID then return end
    end
    classInterruptList[class][#classInterruptList[class]+1] = spellID
end

-- Phase 1: register spells, build classDefault and classInterruptList.
-- classDefault must be fully resolved before specOverrides can be computed,
-- because pairs() iteration order is non-deterministic — if a spec with a
-- non-default interrupt (e.g. Solar Beam, cd=60) is visited before the
-- lowest-CD spec (Skull Bash, cd=15), it would incorrectly see itself as
-- the class default and never appear in specOverrides.
for specID, spec in pairs(SPEC_REGISTRY) do
    local cls = spec.class
    if spec.noKick then
        specNoKick[specID] = true
    else
        local sid = spec.spellID
        registerSpell(sid, spec.name, spec.cd, spec.icon)
        appendClassSpell(cls, sid)

        -- Prefer lowest-CD, non-pet interrupt as class default.
        if not classDefault[cls] or (spec.cd < classDefault[cls].cd and not spec.isPet) then
            classDefault[cls] = { id=sid, cd=spec.cd, name=spec.name }
        end

        if spec.extraKicks then
            specExtraKicks[specID] = spec.extraKicks
            for _, ek in ipairs(spec.extraKicks) do
                registerSpell(ek.spellID, ek.name, ek.cd, ek.icon)
                appendClassSpell(cls, ek.spellID)
            end
        end
    end
end

-- Phase 2: now that classDefault is fully resolved, compute specOverrides.
for specID, spec in pairs(SPEC_REGISTRY) do
    if not spec.noKick then
        local cls = spec.class
        local sid = spec.spellID
        local def = classDefault[cls]
        if def and (sid ~= def.id or spec.cd ~= def.cd) then
            specOverrides[specID] = {
                id         = sid,
                cd         = spec.cd,
                name       = spec.name,
                isPet      = spec.isPet     or nil,
                petSpellID = spec.petSpellID or nil,
            }
        end
    end
end

-- Classes that have BOTH a kicking spec AND a no-interrupt spec
-- (e.g. Monk: WW/Brew kick, Mistweaver doesn't; Druid: Feral/Guardian/
-- Balance kick, Resto doesn't; Paladin: Prot/Ret kick, Holy doesn't).
-- For these, the class-default interrupt must NOT be assigned to a
-- party member whose spec is still unknown unless their role proves a
-- kicking spec — otherwise a Mistweaver / Resto / Holy with an
-- unassigned role would show a phantom interrupt bar.
local classHasNoKick = {}
for _specID, _spec in pairs(SPEC_REGISTRY) do
    if _spec.noKick and _spec.class and classDefault[_spec.class] then
        classHasNoKick[_spec.class] = true
    end
end

------------------------------------------------------------
-- Publish onto BIT namespace
------------------------------------------------------------
BIT.ALL_INTERRUPTS           = allSpells
BIT.CLASS_INTERRUPT_LIST     = classInterruptList
BIT.CLASS_INTERRUPTS         = classDefault
BIT.SPEC_INTERRUPT_OVERRIDES = specOverrides
BIT.SPEC_NO_INTERRUPT        = specNoKick
BIT.CLASS_HAS_NOKICK_SPEC    = classHasNoKick
BIT.SPEC_EXTRA_KICKS         = specExtraKicks
BIT.SPELL_ALIASES            = SPELL_ALIAS_MAP
BIT.CD_REDUCTION_TALENTS     = CD_REDUCTION_DEFS
BIT.CD_ON_KICK_TALENTS       = CD_ON_KICK_DEFS
BIT.EXTRA_KICK_TALENTS       = EXTRA_KICK_DEFS

------------------------------------------------------------
-- String-keyed mirrors for taint-safe lookups (WoW 12.0)
------------------------------------------------------------
BIT.ALL_INTERRUPTS_STR       = {}
BIT.SPELL_ALIASES_STR        = {}
BIT.CD_REDUCTION_TALENTS_STR = {}
BIT.CD_ON_KICK_TALENTS_STR   = {}
BIT.EXTRA_KICK_TALENTS_STR   = {}

for id, v in pairs(BIT.ALL_INTERRUPTS)       do BIT.ALL_INTERRUPTS_STR[tostring(id)]       = v end
for id, v in pairs(BIT.SPELL_ALIASES)        do BIT.SPELL_ALIASES_STR[tostring(id)]        = v end
for id, v in pairs(BIT.CD_REDUCTION_TALENTS) do BIT.CD_REDUCTION_TALENTS_STR[tostring(id)] = v end
for id, v in pairs(BIT.CD_ON_KICK_TALENTS)   do BIT.CD_ON_KICK_TALENTS_STR[tostring(id)]   = v end
for id, v in pairs(BIT.EXTRA_KICK_TALENTS)   do BIT.EXTRA_KICK_TALENTS_STR[tostring(id)]   = v end

for aliasID, targetID in pairs(BIT.SPELL_ALIASES) do
    if BIT.ALL_INTERRUPTS[targetID] then
        BIT.ALL_INTERRUPTS_STR[tostring(aliasID)] = BIT.ALL_INTERRUPTS[targetID]
    end
end

-- Name-keyed lookup: spell name (string) → { id, cd }
-- Used by UNIT_SPELLCAST_SENT which delivers an untainted spell name
-- instead of a tainted spellID, making it the most reliable detection
-- path for party members without the addon.
BIT.ALL_INTERRUPTS_BY_NAME = {}
for id, v in pairs(BIT.ALL_INTERRUPTS) do
    if v.name then
        -- Keep the entry with the lowest CD for this name (avoids Solar Beam
        -- overwriting Skull Bash if both happened to share a name).
        local existing = BIT.ALL_INTERRUPTS_BY_NAME[v.name]
        if not existing or v.cd < existing.cd then
            BIT.ALL_INTERRUPTS_BY_NAME[v.name] = { id = id, cd = v.cd, name = v.name }
        end
    end
end

------------------------------------------------------------
-- SavedVariables defaults
------------------------------------------------------------
BIT.DEFAULTS = {
    frameWidth        = 180,
    barHeight         = 30,
    interruptIconSize = 0,     -- 0 = Auto (icon square matches bar height); >0 = independent size (overhangs the bar)
    interruptIconGap  = 0,     -- horizontal gap (px) between the icon and the bar; 0 = flush
    locked            = false,
    hideOutOfCombat   = false,
    language          = "auto",
    barGap            = 0,
    showTitle         = true,
    showOwnSyncCD     = true,
    syncOnlyInGroup   = false,
    titleFontSize     = 16,
    titleAlign        = "RIGHT",
    titleColorR       = 1,
    titleColorG       = 1,
    titleColorB       = 1,
    -- Player-name text color in the interrupt tracker bars
    nameColorUseClass = false,  -- true = use the player's class color
    nameColorR        = 1.0,
    nameColorG        = 1.0,
    nameColorB        = 1.0,
    -- Offensive CD Alert: glow a teammate's unit frame when they pop a burst CD
    offensiveCDAlertEnabled    = false,         -- master toggle
    offensiveCDAlertMode       = "BOTH",        -- "GLOW" | "BORDER" | "BOTH"
    offensiveCDAlertSpells     = {},            -- spellID → bool override (empty = use defaults)
    offensiveCDAlertColorR     = 1.0,           -- border color RGB
    offensiveCDAlertColorG     = 0.4,
    offensiveCDAlertColorB     = 0.1,
    offensiveCDAlertBorderSize = 3,             -- border thickness in px
    -- PI Macro auto-cast: hidden secure buttons receive the priority
    -- list as `unit` attributes; the user-facing macro is FIXED and just
    -- /clicks each button in priority order. First valid (alive,
    -- friendly, in-group) name fires Power Infusion; the rest fall
    -- through silently. Capped at 5 names = 5 secure buttons.
    piMacroEnabled       = false, -- master toggle (off by default — opt-in)
    piMacroNames         = "",    -- newline-separated priority list, top = highest priority
    alpha             = 1.0,
    nameFontSize      = 0,
    readyFontSize     = 0,
    showName          = true,
    interruptFrameStrata = "MEDIUM",  -- standalone tracker window strata: BACKGROUND/LOW/MEDIUM/HIGH/DIALOG
    showIcon          = true,    -- spell icon column on the interrupt bars (false = bar spans full width)
    interruptShowMarker = true,  -- show the interrupted mob's raid target marker in the interrupt feed / own-bar overlay
    showReady         = true,
    soundEnabled         = false,
    soundKickSuccess     = "None",
    soundKickFailed      = "None",
    soundOwnKickOnly     = true,
    showInDungeon     = true,
    showInRaid        = false,
    showInOpenWorld   = true,
    showInArena       = false,
    showInBG          = false,
    fontPath          = nil,
    fontName          = nil,
    barTexturePath    = "Interface\\BUTTONS\\WHITE8X8",
    barTextureName    = "Flat",
    nameOffsetX       = 0,
    nameOffsetY       = 0,
    iconSide          = "LEFT",
    barFillMode       = "DRAIN",
    sortMode          = "NONE",
    useClassColors    = true,
    customColorR      = 0.4,
    customColorG      = 0.8,
    customColorB      = 1.0,
    customBgColorR    = 0.1,
    customBgColorG    = 0.1,
    customBgColorB    = 0.1,
    customBgColorA    = 0.9,   -- background opacity (matches the previous hard-coded value)
    -- When true, the customBgColor is used for the bar background regardless
    -- of class-color mode. When false, class-color mode picks a darker
    -- shade of the player's class color and non-class mode uses a fixed
    -- neutral default. Off by default — users opt in via Colors → Bar Color.
    useCustomBgColor  = false,
    borderTexturePath = nil,
    borderTextureName = "None",
    borderSize        = 2,
    borderColorR      = 0,
    borderColorG      = 0,
    borderColorB      = 0,
    borderColorA      = 1,
    -- Outward offset of the border from the bar edge (independent of border size).
    -- 0  = border's inner rim sits flush against the bar's outer edge (default)
    -- +N = N-pixel gap between bar and border
    -- -N = border bleeds N pixels into the bar
    borderOffset      = 0,
    disabledSpells    = {},
    rotationEnabled   = false,
    rotationOrder     = {},
    rotationIndex     = 1,
    growUpward        = false,
    frameScale        = 100,
    readyColorR       = 0.2,
    readyColorG       = 1.0,
    readyColorB       = 0.2,
    fontOutline       = "OUTLINE",  -- "NONE", "OUTLINE", "THICKOUTLINE"
    shadowOffsetX     = 0,
    shadowOffsetY     = 0,
    cdOffsetX         = 0,
    cdOffsetY         = 0,
    showFailedKick    = true,
    showWelcome       = true,
    showSyncCDs       = true,

    -- Master switch for the Interrupt Tracker. Enabled by default; when
    -- off, the feature's two cast-event watchers and its display ticker
    -- are torn down so a player who doesn't use it spends no resources.
    interruptTrackerEnabled = true,

    -- Free Anchor: pin the standalone interrupt window's CENTRE to any
    -- on-screen frame (picked with the mouse) plus an X/Y offset. Takes
    -- priority over "Anchor to unit frames" when enabled. Target is a
    -- frame name / dotted global path; empty = none picked yet.
    interruptFreeAnchor       = false,
    interruptFreeAnchorTarget = "",
    interruptFreeAnchorX      = 0,
    interruptFreeAnchorY      = 0,

    -- Clean-room Party Cooldown tracker. Enabled by default so users
    -- see the feature without having to opt in through settings first.
    partyCooldownsEnabled  = true,
    -- Display mode for the icon rows:
    --   "ANCHOR"     → icons attach to each party member's unit frame
    --                  (ElvUI / Cell / Blizzard / etc., via the
    --                  Provider setting). Original behaviour.
    --   "STANDALONE" → icons render in a single movable container
    --                  frame anchored to the screen, with one row per
    --                  party member. Useful when the unit frames are
    --                  small/cluttered or hidden, or when the user
    --                  prefers a centralised CD readout.
    partyCooldownsFrameMode       = "ANCHOR",
    -- Standalone-frame position (saved point offset from UIParent
    -- CENTER). Updated live whenever the user drags the unlocked
    -- frame. Falls back to 0,0 = screen centre on first use.
    partyCooldownsStandaloneX     = 0,
    partyCooldownsStandaloneY     = 0,
    -- Standalone-frame lock state. While locked the frame ignores
    -- mouse drag so it can't be moved accidentally during combat;
    -- unlocking surfaces a subtle drag cursor + saves the new
    -- position on mouse-up.
    partyCooldownsStandaloneLocked    = false,
    -- Whether to render the party member's name to the left of each
    -- icon row in standalone mode. Disabling drops the row to just
    -- icons for a more compact look.
    partyCooldownsStandaloneShowNames = true,
    -- Vertical pixel gap between adjacent player rows inside the
    -- standalone frame. Defaults to 6 — enough breathing room without
    -- bloating the overall footprint.
    partyCooldownsStandaloneRowGap    = 6,
    -- Row growth direction:
    --   false (default) → frame anchored TOPLEFT, rows grow DOWN. The
    --                     saved position pins the top edge, so adding
    --                     a 5th member extends the frame downward
    --                     without pushing the top off-screen.
    --   true             → frame anchored BOTTOMLEFT, rows grow UP.
    --                     The saved position pins the BOTTOM edge —
    --                     useful when the user wants the frame above
    --                     their action bars and the topmost row to
    --                     scoot up as more members appear.
    partyCooldownsStandaloneGrowUpward = false,
    -- Font size (pt) of the player-name labels in standalone mode.
    -- Defaults to 11 to match the original hardcoded value; users
    -- can scale up for readability or down for a more compact look.
    partyCooldownsStandaloneFontSize  = 11,
    -- Anchor provider for the attached icons. "AUTO" tries ElvUI first
    -- (if loaded) then falls back to Blizzard's CompactRaidFrameContainer
    -- (raid-style) or CompactPartyFrame (classic) depending on Edit Mode.
    -- Force a specific provider for users running mixed setups.
    partyCooldownsProvider  = "AUTO",   -- "AUTO" | "ELVUI" | "BLIZZARD" | "DANDERS" | "CELL" | "GRID2" | "ENHANCEQOL" | "SUF"
    -- Which side of the party unit frame the icon row attaches to.
    -- RIGHT / LEFT extend horizontally, TOP / BOTTOM stack vertically.
    -- Icons grow in the chosen direction starting flush with the frame
    -- edge plus a 4px gap, then spaced by IconSize + IconGap each.
    partyCooldownsAnchorPos    = "LEFT",   -- "RIGHT" | "LEFT" | "TOP" | "BOTTOM"
    -- Per-icon visual size in pixels. 28 is a comfortable default —
    -- big enough to read the spell texture clearly, small enough that
    -- 6+ icons still fit next to a unit frame without overflowing.
    partyCooldownsIconSize     = 28,
    -- Gap (in pixels) between adjacent icons along the anchor axis.
    -- 3 gives a subtle separation; 0 makes icons flush, 8+ spreads
    -- them out for a less crowded row.
    partyCooldownsIconGap      = 3,
    -- Max icons per line before wrapping to a new row/column. 0 means
    -- unlimited (everything fits in one straight line). Useful for
    -- TOP/BOTTOM anchor where a long vertical column would clip off
    -- the screen edge: set this to e.g. 5 and a 9-icon row becomes
    -- 5+4 wrapping horizontally next to each other. For LEFT/RIGHT
    -- anchors the wrap goes downward. Uses iconGap for both inter-
    -- icon spacing and inter-line spacing so the grid looks uniform.
    partyCooldownsMaxPerLine   = 0,
    -- Per-icon border thickness in pixels (0 = no border). Drawn
    -- OUTWARD via a sibling overlay frame, same trick the keystone
    -- list uses — increasing the border does NOT shrink the visible
    -- icon, it grows the visual footprint around it.
    partyCooldownsBorderSize   = 1,
    -- Distance (in pixels) the border sits OUTSIDE the icon edge.
    -- 0 = flush, positive = floats further out, negative = overlaps
    -- the icon's outer pixels (useful for decorative borders).
    partyCooldownsBorderOffset = 0,
    -- Border texture (edge file). Defaults to Blizzard's plain 8×8
    -- white so the user gets a solid line out of the box; Media
    -- options expose the addon's bundled decorative borders
    -- (achievement, wooden, thin, etc.) for users who want a more
    -- ornate look. Mirrors the structure used by the interrupt-
    -- tracker so both features feel consistent.
    partyCooldownsBorderTexturePath = "Interface\\BUTTONS\\WHITE8X8",
    partyCooldownsBorderTextureName = "Flat",
    -- Border RGBA. Black at full opacity by default — neutral, reads
    -- as a clean outline against any spell icon art.
    partyCooldownsBorderColorR = 0,
    partyCooldownsBorderColorG = 0,
    partyCooldownsBorderColorB = 0,
    partyCooldownsBorderColorA = 1,
    -- Fine-grained position offset for the whole icon row, applied
    -- on top of the AnchorPos-derived placement. Lets users nudge
    -- the row out of the way of other addon overlays (boss-mod
    -- timers, raid frame borders, etc.) without having to switch
    -- anchor side. X defaults to 2px so the row doesn't sit flush
    -- against the unit-frame edge; Y stays flush.
    partyCooldownsOffsetX      = 2,
    partyCooldownsOffsetY      = 0,
    -- Category split. When enabled, spells get partitioned into two
    -- groups: Defensive (cat="DEF" + all racials) and Offensive
    -- (cat="OFF"). Each group anchors independently so users can put
    -- DEF on one side of the unit frame and OFF on the other —
    -- improves at-a-glance scanning when many spells are tracked.
    -- The Offensive row uses the *Offensive variants below; the main
    -- AnchorPos / OffsetX/Y stay as the Defensive-row config so the
    -- single-row default behaviour is preserved when this toggle is
    -- off. Racials count as Defensive per the documented design
    -- intent — they're typically escape / survivability utilities
    -- regardless of cat field.
    partyCooldownsSplitCategories      = false,
    partyCooldownsAnchorPosOffensive   = "RIGHT", -- "RIGHT" | "LEFT" | "TOP" | "BOTTOM"
    partyCooldownsOffsetXOffensive     = 2,
    partyCooldownsOffsetYOffensive     = 0,
    -- Charge-count badge styling. Only visible on multi-charge spells
    -- (Blur with Demonic Resilience etc.) when below max charges. The
    -- defaults anchor a 13pt white number to the bottom-right corner
    -- with a small offset so it doesn't collide with the icon border.
    partyCooldownsChargeOffsetX  =  4,
    partyCooldownsChargeOffsetY  = -3,
    partyCooldownsChargeFontSize = 13,
    -- Cooldown countdown styling. Font size of the central seconds-
    -- remaining number. ShowMinutes toggles "Xm" for remaining > 60s
    -- (off = always show raw seconds). Grayout dims + desaturates the
    -- icon while the spell is on a full cooldown — off keeps the icon
    -- bright with only the swipe + countdown indicating CD state.
    partyCooldownsCdTextFontSize = 15,
    partyCooldownsCdShowMinutes  = false,
    partyCooldownsCdGrayout      = false,
    -- Zone visibility: same shape as the interrupt-tracker show-in-*
    -- toggles so users can confine the feature to dungeon-only etc.
    partyCooldownsShowInDungeon   = true,
    partyCooldownsShowInRaid      = false,    -- party-only feature for now
    partyCooldownsShowInOpenWorld = true,
    partyCooldownsShowInArena     = false,
    partyCooldownsShowInBG        = false,
    -- Display behaviour toggles independent of zone visibility.
    -- ShowOwn = false → icons aren't rendered on the local player's
    -- own unit frame (some users want their own CDs tracked via other
    -- UIs and only want the bar for teammates).
    -- ShowTooltip = false → icons stop intercepting mouse hovers, so
    -- click-through to the underlying unit frame works again (e.g. for
    -- targeting / selecting in dense raid frames).
    partyCooldownsShowOwn         = false,
    partyCooldownsShowTooltip     = true,
    -- Buff-remaining countdown during the glow phase. When ON, the
    -- CD-text overlay shows seconds-remaining while the buff is
    -- active (instead of being suppressed), then transitions to the
    -- regular cooldown countdown when the buff ends. Same style as
    -- the post-glow CD counter (font, position, color). Default ON.
    partyCooldownsShowGlowCountdown = true,
    -- Custom glow for the buff-active phase. OFF (default) = the
    -- classic action-button proc glow, untinted — the pre-4.1.6
    -- look. ON = the picked alternative style in the picked color:
    -- "PIXEL" = rotating dashed border lines, "AUTOCAST" = circling
    -- sparkle particles, "PROC" = the modern retail proc animation.
    -- The style list deliberately has no "default" entry — custom
    -- off IS the default glow.
    partyCooldownsGlowCustom         = false,
    partyCooldownsGlowStyle          = "PIXEL",
    partyCooldownsGlowColorR         = 0.95,
    partyCooldownsGlowColorG         = 0.95,
    partyCooldownsGlowColorB         = 0.32,
    -- Unit-frame overlay: mirrors the currently ACTIVE defensive as an
    -- icon centered on the member's unit frame while the buff runs.
    -- On by default (26px, centered).
    defensiveOverlayEnabled          = true,
    defensiveOverlaySize             = 26,
    defensiveOverlayOffsetX          = 0,
    defensiveOverlayOffsetY          = 0,
    defensiveOverlayGlow             = true,
    -- User-toggled spell filter. Keyed by cast spellID; `true` =
    -- disabled (don't render an icon for this spell). The settings
    -- UI's Spell Filter panel lets users turn off specific spells
    -- per-class. Defaults to empty = every tracked spell visible.
    partyCooldownsDisabled        = {},
    -- Spell tooltip on hovering the interrupt icon (standalone bar) or the
    -- attached-mode icon. Default on; user can disable on the Interrupts
    -- settings page if the tooltips get in the way of dungeon UI clarity.
    interruptTooltip  = true,
    -- Interrupt tracker display mode
    interruptDisplayMode           = "BARS",  -- standalone-only now; the attached modes were removed (history rework). Kept + forced to "BARS" at login for back-compat reads.
    interruptAttachPos             = "RIGHT", -- "LEFT" | "RIGHT" | "TOP" | "BOTTOM"
    interruptAttachBarPos          = "TOP",   -- ATTACHED_BARS: "TOP" (above frame) | "BOTTOM" | "OVERLAY"
    interruptAttachBarMatchWidth   = true,    -- ATTACHED_BARS: bar width = unit frame width (false = use interruptAttachBarWidth)
    interruptAttachBarWidth        = 120,     -- ATTACHED_BARS: custom bar width when not matching the frame
    interruptAttachOffsetX         = 0,
    interruptAttachOffsetY         = 0,
    interruptAttachIconSize        = 32,
    interruptAttachCounterSize     = 14,
    interruptAttachDesaturateOnCD  = true,
    interruptAttachShowOwn         = true,    -- also show own icon on player frame
    interruptAttachFrameProvider   = "AUTO",  -- reuses SyncCD provider detection: AUTO/BLIZZARD/ELVUI/CELL/GRID2/DANDERS/ENHANCEQOL/SUF/VUHDO/ELLESMERE/MICHS
    -- ("Anchor to unit frames" was removed — Free Anchor replaces it.)
    syncCdModeGroup      = "ATTACH",   -- mode when in a party/group: "WINDOW", "ATTACH", "BARS"
    syncCdModeRaid       = "BARS",     -- mode when in a raid: "WINDOW", "ATTACH", "BARS"
    -- Per-zone visibility for the Party CD tracker. Mirrors the
    -- interrupt tracker's showIn* keys but namespaced separately so
    -- the two systems can be configured independently.
    syncCdShowInDungeon   = true,
    syncCdShowInRaid      = true,
    syncCdShowInOpenWorld = true,
    syncCdShowInArena     = true,
    syncCdShowInBG        = true,
    syncCdWindowCompact  = true,       -- Standalone Window: true = no background/title, just name+icons
    syncCdFrameProvider  = "AUTO",     -- "AUTO", "ELVUI", "DANDERS", "CELL", "GRID2", "ENHANCEQOL", "SUF", "BLIZZARD"
    syncCdAttachPos      = "LEFT",     -- "LEFT", "RIGHT", "TOP", "BOTTOM"
    syncCdIconSize    = 28,         -- icon size in pixels
    syncCdIconSpacing = 4,          -- gap between icons in pixels
    syncCdTooltip     = true,
    syncCdGlow        = true,          -- show buff-active glow overlay on Party CD icons
    syncCdCounterSize = 14,         -- CD countdown text size
    syncCdTimeFormat  = "MMSS",     -- "SECONDS" = 90  /  "MMSS" = 1:30
    syncCdDisabled    = { [10060] = true },   -- Power Infusion: not trackable by default
    -- (legacy db.myCustomName key was removed in 3.3.6 — replaced by charDb.myCustomName + db.globalCustomName below)
    globalCustomName  = "",         -- global nickname (used for all characters when useGlobalCustomName is true)
    useGlobalCustomName = false,    -- when true: use globalCustomName instead of the per-character one
    showCustomNames   = true,       -- display custom names set by other players
    -- Settings-window visual theme.
    --   "AUTO"     → pick faction theme based on UnitFactionGroup("player")
    --   "ALLIANCE" → blue accent, Alliance crest in the title bar
    --   "HORDE"    → red accent, Horde crest in the title bar
    --   "DEFAULT"  → BliZzi cyan / orange accent, no faction crest
    -- Pure cosmetic — affects only the in-game settings window. The
    -- choice is broadcast nowhere; it's a per-character preference.
    settingsTheme     = "AUTO",
    -- Per-feature filter for the Show Custom Names master toggle.
    -- When the master toggle is ON, this table decides WHICH features
    -- substitute custom names for character names. Defaults to all
    -- features enabled so the legacy behaviour is preserved out of
    -- the box. Users can deselect individual features (e.g. keep
    -- custom names in the Interrupt Tracker but show real character
    -- names in the Keystone List). Keys match profile categories:
    --   INTERRUPTS    — Interrupt Tracker rows (UI.lua)
    --   PARTY_CDS     — Party Cooldowns standalone-frame labels
    --   KEYSTONE_LIST — Keystone List rows
    customNamesFeatures = { INTERRUPTS = true, PARTY_CDS = true, KEYSTONE_LIST = true },
    titleOffsetY           = 3,
    -- Group Bars mode settings
    syncCdBarsLocked       = false,
    syncCdShowDEF          = true,   -- show defensive CD icons in Party CDs
    syncCdShowDMG          = true,   -- show offensive/damage CD icons in Party CDs
    syncCdCatVer           = 0,      -- bumped when a category toggle changes (forces icon rebuild)
    syncCdCatRowDMG        = "1",   -- which row Offensive CDs appear on (Attach mode)
    syncCdCatRowDEF        = "2",   -- which row Defensive CDs appear on (Attach mode)
    -- syncCdCatRowCC removed (CC tracking removed)
    syncCdAttachRowGap     = 4,     -- vertical spacing between rows (Attach mode)
    syncCdAttachOffsetX    = 0,     -- additional X offset for the attached bar
    syncCdAttachOffsetY    = 0,     -- additional Y offset for the attached bar
    syncCdAttachMaxPerRow  = 10,    -- max icons per row before wrapping into a new sub-row
    syncCdTBLayout         = "ROWS",    -- TOP & BOTTOM attach: unified "ROWS" or "COLUMNS"
    -- Legacy keys (kept in DEFAULTS so 3.4.x exports keep importing
    -- cleanly; not read by the runtime any more).
    syncCdTopLayout        = "ROWS",
    syncCdBottomLayout     = "ROWS",
    -- Charge-badge style on Party CD icons (configurable via Party CDs settings)
    syncCdChargeSize       = 13,
    syncCdChargeAnchor     = "BOTTOMRIGHT",
    syncCdChargeOffX       = -1,
    syncCdChargeOffY       = 1,
    minimapButton          = true,     -- show minimap button
    minimapPos             = 225,      -- angle in degrees around minimap
    -- Icon Only mode (interrupt tracker)
    -- (Icon Only Mode was removed in 3.3.8 — replaced by "Attached to Unit Frames".)
    -- Profile auto-apply toggles (per-spec and per-role override global/char profile)
    useSpecProfile         = false,    -- auto-apply profile matching current spec on login/spec change
    useRoleProfile         = false,    -- auto-apply profile matching current role (Tank/Healer/DPS)
    -- Smart Misdirect (Hunter: Misdirection, Rogue: Tricks of the Trade)
    -- Class-gated feature: the secure action buttons are only ever created on a
    -- Hunter or Rogue. All other classes silently skip every Smart Misdirect path.
    smartMdEnabled         = false,       -- master switch (opt-in extra feature)
    smartMdTankMethod      = "byRole",    -- "byRole" | "roleAndMainTank" | "mainTankFirst" | "mainTankOnly"
    smartMdPrioritizeFocus = true,        -- focus target wins over tank list
    smartMdIncludePet      = true,        -- Hunter-only: use own pet if no player target
    smartMdAnnounceTarget  = true,        -- print current target in chat when it changes
    smartMdManualName      = "",          -- manual override: player name (empty = disabled)
    smartMdManualRealm     = "",          -- manual override: realm (empty = same realm as player)
    -- Keystone List (extra feature, default OFF — opt-in)
    -- Speaks the WA-KeyStGrList protocol on PARTY channel for cross-addon
    -- compatibility. Optional LibOpenRaid-1.0 integration catches keystone
    -- data from any addon that publishes through that library.
    keystoneListEnabled         = false,    -- master toggle
    keystoneListLocked          = false,    -- frame movability
    keystoneListPosX            = 200,      -- position X (BOTTOMLEFT anchor)
    keystoneListPosY            = 400,      -- position Y (BOTTOMLEFT anchor)
    keystoneListUseAbbreviation = false,    -- show "AD" instead of "Atal'Dazar"
    keystoneListShowNoPort      = true,     -- show "no port" text when teleport spell unknown
    keystoneListShowResilient   = true,     -- show resilient-keystone icon
    -- Per-context visibility (3.6.3 redesign — replaces the old
    -- HideOutdoors / ShowAfter / OnlyInParty trio with explicit
    -- "show when ..." toggles. The keystone list is conceptually a
    -- party / open-world feature; raid is opt-in because most users
    -- don't want it cluttering the raid UI).
    keystoneListShowInParty     = true,     -- show in a 5-player party
    keystoneListShowInRaid      = false,    -- show in a raid group (raid feature is rarely wanted)
    keystoneListShowSolo        = true,     -- show when not in any group (solo / open world)
    keystoneListHideInM         = true,     -- hide while inside an active M+ run (default ON to avoid clutter mid-run)
    keystoneListClickTeleport   = true,     -- click-to-teleport on row hover (false = display only, no SecureAction button)
    keystoneListPortCdAnnounce  = false,    -- when true, clicking a dungeon icon while the teleport is on CD posts a chat message to the party
    keystoneListPortCdMessage   = "",       -- custom message template (empty string = use the localised default from KEY_PORTCD_DEFAULT)
    keystoneListQueueGlow       = true,     -- when true, glow the dungeon icon for the M+ Group Finder activity once the queued group fills up to 5 players
    keystoneListJoinBanner      = true,     -- when true, show a center-screen info banner (title / dungeon / category / leader) when joining a Group Finder dungeon group
    keystoneListJoinBannerX     = 0,        -- banner position: x offset from screen center (drag to move)
    keystoneListJoinBannerY     = 150,      -- banner position: y offset from screen center
    keystoneListPostEnabled     = true,     -- when true, shift-clicking a row's icon posts the keystone info to PARTY chat
    keystoneListPostOwnText     = "",       -- custom template for posting the user's own keystone (empty = use localised default KEY_POST_OWN_DEFAULT)
    keystoneListPostOtherText   = "",       -- custom template for posting another party member's keystone (empty = use localised default KEY_POST_OTHER_DEFAULT)
    keystoneListGrowUpward      = false,    -- false = grow top→down (first row top), true = grow bottom→up
    keystoneListMirror          = false,    -- false = icon on left, names extending right; true = icon on right, names extending left (for right-edge placement)
    keystoneListScale           = 100,      -- frame scale percentage (50..200) — uniform scale of the whole list
    -- Per-element font sizes (0 = use default). The font face + outline
    -- come from Size & Font settings; only the size is local to this
    -- feature so the user can tune the keystone list independently.
    keystoneListLevelSize       = 16,       -- "+XX" centered on the dungeon icon
    keystoneListNameSize        = 11,       -- player name (small, top of right side)
    keystoneListDungeonSize     = 14,       -- dungeon name (large, bottom of right side)
    -- Dedicated border size + offset for the keystone list. The global
    -- Size & Font border size used to drive this too, but Blizzard's
    -- backdrop draws inward from the frame's edges, so increasing the
    -- shared size shrank the visible icon while it grew the interrupt
    -- tracker's outward overlay. These keys decouple the keystone list
    -- so its border can be tuned independently — texture and color stay
    -- shared with the global Border settings for visual consistency.
    keystoneListBorderSize      = 2,        -- border thickness in px (0 = no border)
    keystoneListBorderOffset    = 0,        -- distance from icon edge in px (>= 0)
    keystoneListRowGap          = 1,        -- vertical gap in px between stacked rows (0 = rows touch)

}
