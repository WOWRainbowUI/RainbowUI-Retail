# CLAUDE.md — RGX-Framework

Agent guidance for this repository. Read this before touching any file.

---

## What this repo is

RGX-Framework is a shared WoW addon framework that serves two roles:

1. **Shared runtime for the entire RGX Mods addon suite** — BLU, BattlePetUtility, SimpleQuestPlates, EnhancedTravelersLog, RemoveNameplateDebuffs, and 14+ sound-pack addons all declare `RequiredDeps: RGX-Framework`. One load, one instance, shared by all.

2. **The foundation layer for `rgx-mod`** — a WeakAuras replacement being built on top of this framework. Every subsystem added to RGX-Framework that benefits current addons is also a building block for rgx-mod's trigger/condition/display engine. This is the north star. Design decisions should be consistent with that scope.

The framework is **not** embedded into addons and has **no LibStub**. It is a hard dependency shipped as its own addon.

---

## Current version

- **Version:** `2.0.0`
- **Interface:** `120007` (WoW Retail Midnight 12.0.7)
- **TOC:** `RGX-Framework.toc`
- **Loader:** `RGX-Framework.xml` — this is the single source of truth for what modules are loaded

---

## Module status

### Active (loaded by XML)

| Module | Global | What it provides |
|---|---|---|
| Core | `RGXFramework` | Events, timers, hooks, slash, DB/profiles, Mixin, utilities, `RGX.Addon()` factory |
| Dropdowns | `RGXDropdowns` | Nested dropdown menus, auto-width, inline buttons |
| Fonts | `RGXFonts` | 36 font definitions, registry, query, apply, style objects, dropdowns, selectors |
| Colors | `RGXColors` | Color palette, math, apply, picker |
| ColorPicker | `RGXColorPicker` | HSV color picker widget |
| Textures | `RGXTextures` | Statusbar texture registry |
| Design | `RGXDesign` | Visual palette, building blocks, theme tokens |
| UI | `RGXUI` | Slider, toggle, label, dropdown, button, section, options panel builder |
| Minimap | `RGXMinimap` | Circular-drag minimap button |
| DataBroker | `RGXDataBroker` | LDB bridge |
| Sound | `RGXSound` | Sound pack registration, variant playback, mute list, SavedVar integration |
| Achievement | `RGXAchievement` | Achievement unlock callbacks |
| LevelUp | `RGXLevelUp` | Level-up event callbacks |
| Collectibles | `RGXCollectibles` | Mount/pet/toy unlock callbacks |
| Loot | `RGXLoot` | Loot and currency callbacks |
| Quest | `RGXQuest` | Quest lifecycle and progress callbacks |
| Honor | `RGXHonor` | Honor level callbacks |
| Delves | `RGXDelves` | Delve companion/lives callbacks |
| Housing | `RGXHousing` | Housing progression/decor callbacks |
| TradingPost | `RGXTradingPost` | Trading Post activity callbacks |
| Prey | `RGXPrey` | Prey hunt callbacks |

### Dormant (in-tree, NOT loaded by XML)

These are complete and tested. Re-enabling is a one-line addition to `RGX-Framework.xml` per module.

| Module | Global | What it provides | Who needs it |
|---|---|---|---|
| SharedMedia | `RGXSharedMedia` | Sound/font/texture registry, KittyPack hook, DBM registrar scan, known-addon compat, generic global scan | BLU (drops 901-line local sharedmedia.lua) |
| PetBattles | `RGXPetBattles` | `OnLevelUp`, `OnCapture`, `OnBattleStart/End`, `IsInBattle`, `GetPetLevel`, `ScanPetLevels` | BattlePetUtility |
| Combat | `RGXCombat` | `OnEnter`, `OnLeave`, `OnKill`, `OnPlayerDied`, `OnCrit`, `OnLowHealth`, `OnExecuteWindow`, `OnEncounterEnd/Victory` | BLU Combat module, rgx-mod triggers |
| Reputation | `RGXReputation` | Reputation and renown tracking callbacks | ReputationLevelUp migration |

**To enable a dormant module:** add the `<Script>` entry in `RGX-Framework.xml` in load-order position, verify `TryInit` call in `core/initialization.lua` if needed, bump version, release.

---

## Consumer addon integration levels

Current state as of v2.0.0:

| Addon | RGX Dep | Systems Used | Level |
|---|---|---|---|
| BLU | Required | events, timers, hooks, slash, DB, dropdowns, sound, utilities | 100% |
| EnhancedTravelersLog | Required | events, timers, hooks, slash, minimap, design | 75% |
| SimpleQuestPlates | Required | events, timers, minimap, slash, design | 75% |
| BattlePetUtility | Required | events, timers, hooks, slash, DB, minimap, debug | 65% |
| RemoveNameplateDebuffs | Required | events, timers, minimap, slash | 50% |
| HelloRGX | Required | DB, slash, UI (RGX.Addon bootstrap) | 50% |
| 14× LevelUp sound packs | Required | sound, events, slash | 25% |
| ReputationLevelUp | None | — | 0% |
| CoordinationCloakUtility | None | — | 0% |
| BLU_Classic | None (Ace3) | — | 0% — intentional, will never migrate |

---

## Priority work order

Build subsystems that benefit **current addons first**, then rgx-mod. Do not build abstract framework modules that no current addon uses.

### Immediate (enable dormant modules — zero new code)

1. **Enable RGXSharedMedia** → BLU drops 901 lines of local scanning code
2. **Enable RGXPetBattles** → BattlePetUtility uses it for pet battle state
3. **Enable RGXCombat** → BLU Combat module simplifies to callbacks
4. **Enable RGXReputation** → enables ReputationLevelUp migration

### Near-term (wire existing modules into addons)

5. **Wire BLU → RGXSharedMedia** — drop `core/sounds/sharedmedia.lua` from BLU
6. **Wire BPU → RGXPetBattles** — replace raw `C_PetBattles.*` calls
7. **Wire BLU Combat → RGXCombat** — simplify to `Combat:OnEnter/OnLeave` callbacks
8. **Wire BPU → RGXDropdowns** — replace `EasyMenu`/`UIDropDownMenu` in BPU options

### Next build (new modules, guided by WoW UI dump)

9. **RGXAuras** — taint-safe aura scanning: `HasAura(spellId)`, `GetAura(spellId)`, unit filtering, pcall guards. Generalizes BPU's `PlayerHasAuraSpellID` pattern. Also a core rgx-mod trigger primitive.
10. **RGXTooltip** — `GameTooltip` hook registry, structured composition, `AddLine`/`AddDoubleLine` helpers. BPU hooks GameTooltip in 5 files today. Also needed by rgx-mod display types.
11. **RGXCombatLog** — structured `COMBAT_LOG_EVENT_UNFILTERED` dispatch: parse subevent, source/dest GUIDs, spellId. Needed by BLU Combat, BPU capture events, and is the core rgx-mod event trigger.

### rgx-mod foundation phases (after above)

12. **Frame pooling** — `CreatePool(frameType, parent, resetFunc)` for rgx-mod's dynamic display regions
13. **Bucket events** — `RegisterBucketEvent(event, delay, callback)` for throttling `UNIT_AURA` spam
14. **Animation/tween helpers** — lerp utilities for smooth display transitions
15. **RGXTriggers** — trigger evaluation engine (aura, event, status, custom) — rgx-mod Phase 2
16. **RGXDisplays** — dynamic frame/texture/text/progressbar display regions — rgx-mod Phase 3
17. **RGXConditions** — boolean condition evaluator for trigger logic — rgx-mod Phase 3

---

## rgx-mod context

`rgx-mod` is a WeakAuras replacement being built on RGX-Framework. WeakAuras provides:
- Trigger system (aura/event/status/custom)
- Display regions (icon, aurabar, text, texture, group, dynamic group)
- Condition/logic evaluator
- Action system (sound, chat, custom code)
- Import/export string system
- Animation system

RGX-Framework already has the foundations: events, timers, DB/profiles, serialization, sound, fonts, colors, textures, dropdowns, UI. What's missing is the trigger engine, display region system, condition evaluator, and animation helpers.

**The WoW UI dump** (full Blizzard API dump) is the reference for building new framework modules. Use it to map APIs correctly before implementing. Do not guess at WoW APIs — consult the dump.

**Build priority rule:** if a new framework module benefits a current maintained addon AND rgx-mod, build it. If it only benefits rgx-mod with no current addon use, defer it.

---

## Architecture rules

- **No LibStub** — ever. No version negotiation. One instance via `_G.RGXFramework`.
- **No embedding** — consumers use `RequiredDeps: RGX-Framework` in TOC, not copy-paste.
- **No C_Timer** — use `RGX:After` / `RGX:Every`.
- **No manual event frames** — use `RGX:RegisterEvent` / `RGX:RegisterUnitEvent`.
- **No raw `SLASH_X` patterns** — use `RGX:RegisterSlashCommand`.
- **All dispatch is pcall-wrapped** — framework never lets a consumer handler crash the frame.
- **Combat lockdown guards** — frame registration deferred during lockdown, queued via `pendingFrameEvents`.
- **New modules register via `RGX:RegisterModule(name, table, opts)`** — sets global alias, stored in `RGX.modules`.
- **Consumer addons `assert(_G.RGXFramework, ...)`** at file scope — fast fail if dependency missing.

---

## Key file locations

```
RGX-Framework.toc        — version, interface, SavedVariables declarations
RGX-Framework.xml        — XML loader (single source of truth for load order)
core/core.lua            — global object, module registry, RGX.Addon() factory
core/systems/config.lua  — framework defaults
core/systems/database.lua — RGX:NewDatabase(), RGX:DB(), serialization, import/export
core/systems/events.lua  — RegisterEvent, RegisterUnitEvent, RegisterMessage, CreateEmitter
core/systems/runtime.lua — After, Every, CancelTimer, Hook, RegisterSlashCommand, Safe* helpers
core/initialization.lua  — ADDON_LOADED handler, TryInit, OnReady lifecycle
modules/                 — one subdirectory per module
docs/ROADMAP.md          — planned work, phase tracking
docs/ARCHITECTURE.md     — internals, load order, module registration conventions
```

---

## Version and release conventions

- Version string lives in `RGX-Framework.toc` (`## Version:`)
- `core/core.lua` reads it at runtime: `RGX.version = GetAddOnMetadataCompat(addonName, "Version")`
- Keep `docs/CHANGES.md` as the current release summary
- Add matching file in `docs/changelogs/<version>.md`
- Merge to `main`, tag `vX.Y.Z`, push tag to trigger GitHub Actions release

---

## What NOT to do

- Do not add modules that no current addon needs
- Do not embed or fork framework code into consumer addons
- Do not add LibStub, Ace3, or any third-party library
- Do not break the `RGX.Addon()` factory API — addons depend on it
- Do not change `NewDatabase` proxy behavior without full regression check across BLU and BPU
- Do not enable dormant modules without verifying `Init()` and `TryInit` wiring in `initialization.lua`
- Do not commit directly to `main` — work on `dev`, merge via PR
