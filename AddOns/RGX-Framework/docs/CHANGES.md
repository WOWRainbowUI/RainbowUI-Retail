# Changes

## Current Development Release

### [v2.1.0](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/2.1.0.md) - 2026-06-30

- Enabled RGXCombat — combat enter/leave/kill/crit/low-health/execute/encounter callbacks now active for all consumers.
- Enabled 8 event callback modules that were dormant since v1.8.0: Achievement, LevelUp, Quest, Honor, Delves, Housing, TradingPost, Prey.
- All modules are now active in the XML loader. No dormant code remains in-tree.
- `TryInit("RGXCombat")` wired into initialization.lua between RGXSharedMedia and RGXPetBattles.
- Removed stale comment in initialization.lua that described RGXCombat as blocked during load screen (its Init() already defers via PLAYER_REGEN_ENABLED).

Full notes:
- [v2.1.0 changelog](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/2.1.0.md)

## Production Releases

### [v2.0.0](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/2.0.0.md) - 2026-06-30

- Stable RGX 2.0 framework release for retail 12.0.7.
- Promotes the RGX.Addon, NewDatabase, event, timer, and runtime integration work out of alpha.
- Keeps unfinished callback modules out of the XML loader for a clean live load.
- Includes combat-safe event/runtime hardening and SharedMedia scan coalescing from the alpha cycle.

Full notes:
- [v2.0.0 changelog](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/2.0.0.md)

### [v2.0.0-alpha.2](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/2.0.0-alpha.2.md) - 2026-06-28

- SharedMedia startup scan now coalesces light/full rescans instead of doing the expensive generic pass immediately.
- Generic addon-global media scan is deferred until after `PLAYER_LOGIN`, reducing startup timer-slow warnings.
- Added scan-state guards so late media-provider loads can upgrade a pending scan without duplicating work.

Full notes:
- [v2.0.0-alpha.2 changelog](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/2.0.0-alpha.2.md)

### [v2.0.0-alpha.1](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/2.0.0-alpha.1.md) - 2026-06-11

- **RGX.Addon()** â€” one-call addon factory: auto-creates database, slash commands, minimap button from a single declarative table.
- **Declarative options engine** â€” table-driven panel builder with toggle, slider, dropdown, button, section, label controls, all auto-bound to `addon.db`.
- **Proxy fix** â€” `__newindex`/`__index` now guard internal fields (`_guard`, `_raw`, `_defaults`, `_callbacks`, `_onSwitch`) with `rawget`/`rawset` so they never leak into profile SavedVars.
- Fixed `MergeDefaults` â†’ `MergeTable` (3 call sites â€” `MergeDefaults` was never defined).
- Added `database_test.lua` with 14 assertions, wired via `/rgx dbtest` command.
- `RGX.Addon()` now passes `opts.onSwitch` through to `NewDatabase`.
- Timer-slow threshold: 50ms â†’ 250ms (SharedMedia:QueueScan ~207ms is normal I/O).

Full notes:
- [v2.0.0-alpha.1 changelog](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/2.0.0-alpha.1.md)

### [v1.9.0](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/1.9.0.md) - 2026-06-09

- **NewDatabase API** â€” `RGX:NewDatabase(name, defaults, opts)` with metamethod-based profile access, profile CRUD, cross-character `db.global`.
- Combat lockdown safety â€” `pcall(function() ... end)` closure pattern replaces raw C function reference.
- `RGXCombat` returned to dormant status.

### [v1.8.0](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/1.8.0.md) - 2026-06-09

- **BLU v7 migration foundation** â€” 10 callback modules (Achievement, LevelUp, Collectibles, Loot, Quest, Honor, Delves, Housing, TradingPost, Prey).
- Theme highlight tokens, combat safety guards.

### [v1.6.0](https://github.com/DonnieDice/RGX-Framework/blob/main/docs/changelogs/1.6.0.md) - 2026-05-01

## Changes

- Reworked backend font handling to properly support shared bundled fonts across downstream addons.
- Improved RGX font registration, lookup, and UI application paths so addons can reliably consume the shared font system.
- Updated shared option UI behavior for tabs, buttons, labels, and reset controls.
- Restored framework tab sizing and label anchoring to the expected RGX defaults.
- Cleaned up button/tab text handling to avoid unintended wrapping, alignment drift, and inconsistent font-string anchors.
- Rewrote README.md as a polished entry point with links to the full wiki documentation.
- Added comprehensive wiki documentation: Architecture, API Reference, Fonts System, Dropdowns System, Theming & Design, Troubleshooting, and Migration Guide.
- Updated CurseForge description.html with current module list, font counts, and documentation links.
- Fixed stale file path references (modules/fonts/fonts.lua â†’ modules/fonts/definitions.lua).
- Fixed inconsistent dormant module wording across all docs (standardized to "in-tree but not loaded by the XML loader").
- Fixed stale interface version in Super Simple example code (110002 â†’ 120005).
- Standardized font count language across all docs (36 bundled + 8 WoW defaults = ~44 total, 10 blocked, ~34 available).

## Fixes

- Fixed shared font plumbing needed by BattlePetUtility and SimpleQuestPlates.
- Fixed RGX option tabs using widened dimensions and incorrect text alignment.
- Fixed non-icon option tab labels being left-aligned instead of centered.
- Fixed icon tab label padding regressions.
- Removed unintended word-wrap and font-string anchor changes from shared RGX controls.
- Verified touched RGX Lua files pass syntax validation.
