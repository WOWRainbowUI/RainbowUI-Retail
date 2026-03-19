# Changelog

## Dev Version 1 (2026-03-17)

- Checkpoint tag for rollback/reference.
- Outgoing damage is combat-only; incoming/notifications/static can still display out of combat.
- Added crit/normal split routing for batched outgoing and incoming damage/heal when configured to different scroll areas.
- Improved outgoing spell fallback attribution at range (including delayed spell effects like Ignite).
- Added incoming self-heal icon attribution improvement for better icon consistency.

## 2026-03-17

- Added `MSBTOptions` as a nested folder inside `MikScrollingBattleText/MSBTOptions` for unified codebase packaging.
- Updated outgoing hit summary formatting in `MSBTMain.lua` so a single non-critical hit shows only the amount (no `1 hit` suffix).
- Kept single critical hit formatting as ` (Crit)`.
- Added an `AI_POLICY_NOTICE` comment block to `MikSBT.lua`.
- Added an `AI_POLICY_NOTICE` comment block to `MSBTOptions/MSBTOptionsMain.lua` (nested copy inside `MikScrollingBattleText`).
