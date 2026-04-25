# v1.3.0 - 2026-04-24

## Core
- Added `RGX:OnReady(fn)` — queue a callback to fire once the framework finishes its `ADDON_LOADED` init; fires immediately if already ready.
- Added `RGX:IsReady()` — returns `true` after framework initialization completes.
- Added `RGX:Print(...)`, `RGX:Warn(...)`, `RGX:Error(...)` — standard output helpers with colored `[RGX]` prefix (green / yellow / red).
- Added `RGX:Mixin(target, ...)` — copy all fields from one or more source tables into `target`; returns `target`.

## Dropdowns
- `ForceWidth` internal timer migrated from `C_Timer.After(0)` to `RGX:After(0)` — framework is now fully self-contained with no external timer dependencies.
