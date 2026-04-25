# v2.0.0 - 2026-04-25

## Changes
- Full RGX-Framework native migration: removed manual `eventFrame`, all 14 events now registered via `RGX:RegisterEvent`. Slash command via `RGX:RegisterSlashCommand`. `C_Timer.After` replaced with `RGX:After`.
- `RequiredDeps: RGX-Framework` declared in TOC — deterministic load order guaranteed.
