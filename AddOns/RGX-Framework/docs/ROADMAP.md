# RGX-Framework Roadmap

## Direction

RGX-Framework is a modern WoW addon framework — an alternative to Ace3. It ships as a single `RequiredDeps` entry so every addon in a suite shares the same initialized instance. No embedding. No version conflicts. One dependency, everything included.

The player-facing experience stays quiet. The author-facing experience should be powerful, predictable, and simple to adopt.

---

## Core Principles

- One shared instance for all consumers — the single-load model beats per-addon embedding past 2 addons
- Modules are siloed by responsibility but designed to work together
- The public API stays simple; complexity lives inside the framework
- Build once in RGX, consume across the entire suite
- No LibStub, no embedding tax, no legacy compat shims

---

## What's Built

| System | Module | Status |
|---|---|---|
| Events, timers, hooks, slash commands | Core | ✅ Done |
| Lifecycle (`OnReady`, `IsReady`) | Core | ✅ Done |
| Output helpers (`Print`, `Warn`, `Error`) | Core | ✅ Done |
| Object composition (`Mixin`) | Core | ✅ Done |
| Deep-merge DB defaults (`MergeTable` recursive) | Core | ✅ Done |
| Version-based DB migration (`MigrateDB`) | Core | ✅ Done |
| Unit-filtered event registration (`RegisterUnitEvent`) | Core | ✅ Done |
| Font registry + dropdowns + style objects | RGXFonts | ✅ Done |
| Color palette + picker + math | RGXColors | ✅ Done |
| Statusbar texture registry | RGXTextures | ✅ Done |
| Nested dropdowns + auto-width + inline buttons | RGXDropdowns | ✅ Done |
| Slider, toggle, label, dropdown, options panel builder | RGXUI | ✅ Done |
| Color picker widget | RGXColorPicker | ✅ Done |
| Circular-drag minimap button | RGXMinimap | ✅ Done |
| Pet battle callbacks + level-up detection | RGXPetBattles | ✅ Done (dormant †) |
| Sound/font/texture registry + pack scanner | RGXSharedMedia | ✅ Done (dormant †) |
| Visual building blocks (Design palette) | RGXDesign | ✅ Done |
| Combat event library | RGXCombat | ✅ Done (dormant †) |
| Reputation + renown tracking | RGXReputation | ✅ Done (dormant †) |
| Data broker registry | RGXDataBroker | ✅ Done |
| Level-up sound system (variant playback, mute, settings) | RGXSound | ✅ Done |
| Opt-in scroll container for options tabs | RGXUI | ✅ Done |

† Dormant — in-tree but not loaded by the XML loader since v1.5.18. `Get*()` returns `nil` until re-added to `RGX-Framework.xml`.

---

## Immediate Priority

### Profile / Database System
**Priority: HIGH — biggest gap vs Ace3**

A profile-aware saved variable system so any addon can do:

```lua
local db = RGX:NewDatabase("MyAddonDB", {
  iconSize = 32,
  showIcon = true,
})

db.iconSize -- reads active profile, falls back to default
db.iconSize = 48 -- writes to active profile
db.global.foo -- cross-character storage

db:CreateProfile("Tank")
db:LoadProfile("Tank")
db:DeleteProfile("Tank")
db:ResetProfile()
db:GetProfiles()
db:GetActiveProfile()
db:OnProfileChanged(fn)
```

**Design principles (why this is better than AceDB):**
- Two scopes only: `profile` (per-character) and `global` (cross-character). No realm/class/race/faction scopes — those exist in AceDB to cover every possible case; we cover what 95% of addons need.
- `db.myKey` just works — `__index`/`__newindex` metamethods so the active profile IS the table surface. No `db.profile.myKey` namespace prefix bleeding into every line of consumer code.
- Flat defaults — pass a plain table, not a namespace-structured table mirrored to the scope system.
- Protected `Default` profile — always exists, never deleted, always a safe fallback.
- Missing keys auto-filled from defaults at read time (metamethod, not copy) — adding a new setting to defaults is safe for existing saved variables.

**Base:** BLU's `core/systems/database.lua` — profile CRUD, `MergeDefaults`, protected Default, rename, import/export serialization are all solid. Remove BLU-specific coupling, make it a generic factory, replace `GetDB`/`SetDB` dot-path accessors with metamethods.

---

## Near-Term Roadmap

### SharedMedia Drop-In for All RGX Consumers
**Priority: HIGH**

Currently `RGXSharedMedia` has the scanning logic (KittyRegisterSoundPack hook, DBM registrars, known addon compat, generic global scan). The missing pieces:

1. **Cross-feed to RGXFonts and RGXTextures** — fonts and textures discovered via LibSharedMedia or pack addons should automatically flow into the `RGXFonts` and `RGXTextures` registries. Currently the modules are siloed.

2. **`RGX_MEDIA_UPDATED` message** — after any scan, fire `RGX:SendMessage("RGX_MEDIA_UPDATED", type)`. Consumer addon dropdowns listen and rebuild. A font pack loads late → every RGX font dropdown across every addon refreshes automatically.

3. **BLU's sharedmedia.lua scanning logic belongs here** — KittyPack hook, DBM registrar invocation, known addon compat (Prat-3.0, TradeSkillMaster), generic audio path scanner. When BLU migrates to RGX, it drops its own `sharedmedia.lua` entirely.

**End state:** install any KittyPack, DBM sound pack, LibSharedMedia font/texture pack, or future RGX media pack alongside any RGX addon → all registered media appears in every RGX dropdown across every consumer addon. Zero per-addon wiring.

---

### RGXTheme Module (Scaffold)
**Priority: MEDIUM — build scaffold only, no consumer hooks yet**

Inspired by BetterMusicPlayer's theming architecture, but extended for the RGX suite:

**What BLP does:**
- Flat RGBA keys in SavedVars (e.g. `db.theme.windowBg = {r,g,b,a}`)
- `copyDefaults` pattern fills missing keys
- `ApplyTheme()` walks all registered widgets, calls `SetBackdropColor` / `SetTextColor` / etc per property
- Inline color picker per theme property
- No named presets — one flat table

**What RGXTheme adds beyond BLP:**
- **Named presets** — users pick from named themes ("Dark", "Light", "Ocean") stored as override tables; custom is just a preset with all keys overridden
- **Extended properties** — colors + font, fontSize, texture, spacing so a theme controls the full visual identity, not just color
- **Central registry** — `RGXTheme:Register(widget, properties)` / `RGXTheme:Unregister(widget)` so any frame opts in; `ApplyTheme()` walks the registry
- **Cross-addon consumption** — other addons call `RGX:GetTheme():Apply()` or listen to `RGX_THEME_CHANGED` message
- **Brand theme ↔ addon panel color picker merge** — brand themes (e.g. SQP green, BLU blue) define a base preset; the addon's own options panel color picker overrides individual properties on top. The theme module merges: `preset → brand overrides → user color-picker overrides`. This means changing the global theme preserves per-addon brand identity while letting users tweak individual colors.

**Scaffold scope:**
- `modules/theme/theme.lua` with `RGXTheme:Register`, `Unregister`, `Apply`, `SetPreset`, `GetPresets`, `OnThemeChanged`
- Default preset table matching existing RGXDesign palette
- `RGX_THEME_CHANGED` message on preset change
- No consumer wiring yet — addons adopt when ready

---

### New RGX Modules (Sound/Combat Alert Addons)

These are standalone RGX-native addons (not framework modules) that use the framework's events, design, dropdowns, and theme system. Listed here because the framework needs to support their patterns.

#### TrinketAlarm
**Priority: MEDIUM**

Alerts when trinket cooldowns expire. Based on TrinketAlarm reference:

- `GetInventoryItemCooldown("player", slot)` polling on `BAG_UPDATE_COOLDOWN` / `SPELL_UPDATE_COOLDOWN`
- Per-slot state machine: `ready → onCooldown → ready`
- Sound alert on transition to ready
- Per-trinket slot enable/disable and sound selection

**Framework dependency:** `RGX:RegisterEvent`, `RGX:After` (poll timer), `RGXSharedMedia` (sound selection dropdown), `RGXUI` (options)

#### PotionAlarm
**Priority: MEDIUM**

Same pattern as TrinketAlarm but for potion cooldowns. Tracks `GetItemCooldown` for equipped/consumed potions.

#### WhisperAlarm
**Priority: LOW-MEDIUM**

Plays a user-selected sound on incoming whispers. Based on Whisper Sound reference:

- `CHAT_MSG_WHISPER` and `CHAT_MSG_BN_WHISPER` events
- Sound file selection via `RGXSharedMedia` dropdown
- Per-character enable/disable

**Framework dependency:** `RGX:RegisterEvent`, `RGXSharedMedia`, `RGXUI`

#### ExtraAttackTrigger
**Priority: LOW**

Plays a sound when extra attacks proc (Windfury, Sword Specialization). Based on ExtraAttackSounds reference:

- `COMBAT_LOG_EVENT_UNFILTERED` — `SWING_MISSED` sub-event with `extraAttacks` field
- Sound selection per spec/class
- Only fires for the player's own events

**Framework dependency:** `RGX:RegisterEvent`, `RGXCombat`, `RGXSharedMedia`, `RGXUI`

---

### Combat System Hooks

#### Bloodlust Detection
**Priority: MEDIUM**

Add `RGX_BLOODLUST` and `RGX_SATED` messages to the framework's event system. Based on BLDetect reference:

- Uses `C_UnitAuras.GetPlayerAuraBySpellID()` for Sated-family debuff detection (modern API, more reliable than combat log)
- `UNIT_AURA` event on `"player"` via `RegisterUnitEvent` for real-time tracking
- Expose: `RGX:RegisterMessage("RGX_BLOODLUST", fn)` and `RGX:RegisterMessage("RGX_SATED", fn)`
- Sated spell IDs: 57723, 57724, 80354, 95809, 115969, 117897, 117901, 160738

#### Combat Rez Tracking
**Priority: MEDIUM**

Add `RGX_COMBATREZ_AVAILABLE` and `RGX_COMBATREZ_USED` messages. Based on BRTracker reference:

- `C_DeathInfo.GetSelfResurrectOptions()` for available self-rez spells
- `GetDeathResurrectChargeInfo()` for charge counts
- `UNIT_SPELL_SUCCEEDED` for charge consumption events
- Expose as framework messages so any addon can react to combat rez state

---

### Pack / Addin System
**Priority: MEDIUM — roadmap, not immediate**

External addon packs that extend RGX-Framework with fonts, style presets, sound collections, or texture sets. Shipped as separate CurseForge addons.

**Pattern:**
```lua
-- In a pack addon's main file:
## OptionalDeps: RGX-Framework

RGX:OnReady(function()
  local Fonts = RGX:GetFonts()
  Fonts:RegisterFontPack("PixelFontPack", {
    ["Press Start 2P"] = { file = "fonts/PressStart2P.ttf", category = "pixel" },
  })
end)
```

**Why it works structurally:** because all RGX consumers share the same `_G.RGXFramework` instance, a pack registering into `RGXFonts` is immediately visible to every addon using `RGXFonts` — BLU, SQP, PB2, RND, anything. The `RGX_MEDIA_UPDATED` message then signals dropdowns to rebuild.

**Compatibility:** existing LibSharedMedia packs (Caith, SharedMedia-Fonts, etc.) already work via `RGXSharedMedia:ImportLibSharedMedia()`. The pack system extends this to RGX-native packs with richer metadata (categories, families, licenses, previews).

**Initial media size:** default bundled assets stay lean — packs are how users expand options, not something every consumer pays for upfront.

---

### Hello RGX — Reference Addon
**Priority: MEDIUM — developer experience**

A minimal, fully-commented "Hello World" addon built on RGX-Framework. Ships as a standalone CurseForge addon and lives in the workspace as the canonical starting point for new consumers.

**What it demonstrates:**
- TOC setup with `RequiredDeps: RGX-Framework` and the `assert` pattern
- `RGX:OnReady` bootstrap flow
- `RGX:RegisterEvent` and `RGX:After`
- A minimap button via `RGX:GetMinimap()`
- A slash command via `RGX:RegisterSlashCommand`
- A font lookup via `RGX.Fonts:GetPath`
- A dropdown via `RGX:GetDropdowns()`
- A simple saved variable via `RGX:NewDatabase` (once the profile system ships)

**Why it matters:** every new addon author spends time wiring the same boilerplate. Hello RGX eliminates that — copy the folder, rename, remove comments, start building. Also serves as a live integration test that RGX-Framework's public API is working.

---

### Localization Helper
**Priority: MEDIUM**

Simple `RGX:NewLocale(addonName, locale, isDefault)` — far simpler than AceLocale. Enables community addon authors to ship multilingual addons without rolling their own L table system.

**Implementation:** metatable-fallback `__index` pattern — each locale table chains to its parent via `__index`, so `enUS` is the root fallback and missing keys in `deDE` fall through to `enUS` automatically.

---

### ColorTools Integration
**Priority: LOW-MEDIUM**

Upgrade the existing color picker in `RGXColorPicker` with ColorTools reference features:

- Opacity/alpha slider in the color picker
- HSL input mode (not just RGB)
- Saved color swatches/palette
- Eye-dropper mode for screen sampling

This integrates into the existing `RGXColorPicker` module rather than being a separate module.

---

## Longer-Term Roadmap

### Declarative Options
AceConfig-style but without AceConfig's complexity. A table-driven panel builder where you define structure and get a complete options UI — reduces the most common boilerplate from ~50 manual lines to a declarative table.

### Bucket / Coalesced Events
`RGX:RegisterBucketEvent(event, delay, callback)` — fires the callback once after `delay` seconds when the event fires multiple times in quick succession (e.g. inventory updates, aura stacks). Prevents callback storms.

### Widget `SetEnabled(bool)` State
Standardized enable/disable on all RGXUI widgets. Currently only dropdowns have `SetEnabled`. Add it to sliders, toggles, color pickers, and buttons so addon authors can grey out controls based on other settings.

### BLU Migration to RGX
BLU currently has its own parallel implementations of: event system, timers, SharedMedia scanning, dropdown helpers, database/profiles. As RGX matures, BLU migrates to consume RGX for each of these. This is a gradual process — BLU is complex and stable; no disruption for its own sake.

Target: BLU drops its own `sharedmedia.lua`, `database.lua`, and event infrastructure in favour of `RGX:GetSharedMedia()`, `RGX:NewDatabase()`, and `RGX:RegisterEvent()`.

### RGX-Mod
WeakAuras-style aura engine. Starts as a copy of BLU, then grows into a configurable trigger/condition/display system. See [RGX-Mod docs](../../RGX-Mod/docs/) for full architecture.

**Framework dependencies by phase:**

| Phase | RGX-Mod Feature | Framework API Needed | Status |
|-------|----------------|---------------------|--------|
| 1 | BLU copy baseline | Core, DB, Events, Options, Sound, Combat | Done |
| 2 | Multi-trigger auras | `RegisterUnitEvent` | Done |
| 3 | Display types + conditions | None new | — |
| 4 | Options editor + actions | Scroll, Dropdown | Done |
| 5 | Import/export + profiles | Serialization, Profiles, Bucket events | Not built |
| 6 | Groups, animations, pooling | Frame pooling, Animation helpers, Locale | Not built |

**Framework work triggered by RGX-Mod (ordered by phase need):**

1. **Profile system** (Phase 5) — highest priority. `RGX:NewDatabase()` with profile CRUD, metamethod access, protected Default. Every addon benefits.
2. **Bucket events** (Phase 5) — `RegisterBucketEvent(event, delay, callback)`. Needed for `UNIT_AURA` spam throttle. Any combat addon benefits.
3. **Serialization** (Phase 5) — `Serialize(table)` / `Deserialize(string)` with type preservation. Needed for import/export.
4. **Frame pooling** (Phase 6) — `CreatePool(frameType, parent, resetFunc)`. General performance utility.
5. **Animation/tween helpers** (Phase 6) — lerp utilities for smooth transitions. Any animated UI benefits.
6. **Locale** (Phase 6) — `RGX:NewLocale(addonName, locale, isDefault)`. Any addon going to CurseForge benefits.

---

## Completed Infrastructure (This Cycle)

| Feature | File | Description |
|---|---|---|
| Deep-merge `MergeTable` | `core/systems/utils.lua` | Recursive table merge replacing shallow nil-fill. Nested defaults now auto-fill correctly. |
| `DB()` uses `MergeTable` | `core/systems/database.lua` | `RGX:DB(name, defaults)` now deep-merges, so `db.nested.key` gets defaults even when `db.nested` exists partially. |
| `InitDatabase` uses `MergeTable` | `core/systems/database.lua` | Framework's own DB init now deep-merges `self.defaults.global`. |
| `MigrateDB` | `core/systems/database.lua` | Version-based migration system. Addons call `RGX:MigrateDB(db, name, currentVersion, migrations)` to run ordered upgrade functions once. |
| `RegisterUnitEvent` | `core/systems/events.lua` | Per-unit event filtering (e.g. `UNIT_AURA` for `"player"` only). Callbacks receive `(event, unit, ...)`. |
| `UnregisterUnitEvent` / `UnregisterAllUnitEvents` | `core/systems/events.lua` | Cleanup for unit-filtered handlers. |
| Opt-in scroll container | `modules/ui/options.lua` | Tab option `scroll = true` wraps content in a ScrollFrame with scrollbar and mousewheel support. |
| `CreateDropdown` widget | `modules/ui/controls.lua` | UI wrapper around `RGXDropdowns:CreateNestedDropdown` for use in options panels. |
| `add:Dropdown()` helper | `modules/ui/options.lua` | Auto-layout helper for dropdowns in tab content functions. |

---

## Non-Goals

- Not a bloated everything-framework — each module stays focused on its responsibility
- Not a replacement for WoW's native APIs — RGX wraps where wrapping adds value, exposes native APIs otherwise
- Not AceComm / AceSerialization — addon-to-addon communication via chat channels is niche; not planned
- Consuming addons should never need to understand RGX internals to benefit from it
