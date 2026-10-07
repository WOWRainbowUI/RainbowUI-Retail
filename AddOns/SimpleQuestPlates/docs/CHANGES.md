# v2.1.8 - 2026-10-06

## Changes
- One Background style dropdown with Blizzard and RGX groups; choices include Classic (default), coin/medal/badge Blizzard artwork, and bundled RGX addon logos (LevelUp set, SQP, BLU, RND, ETL, CCU, BPU).
- Quest-count background chip is available on every supported client with shared artwork (no Forever-only atlas requirement).
- Logo picks show a texture preview in the menu; the selected label centers on the dropdown button.
- Selecting Classic no longer forces Text Mode on; background and text-mode choices stay independent after Reset All.

# v2.1.7-beta.3 - 2026-09-29

## Changes
- Added the `AGENTS.md` framework-build and interface-versioning directives.

# v2.1.7-beta.2 - 2026-09-29

## Changes
- Match quest progress to the correct unfinished objective rather than an unrelated unit with shared name words.
- Disable the percent icon and its background by default; keep the preview and options toggle synchronized.
- Use the configured addon icon consistently in the options panel and update the Retail interface target.

# v2.1.7-beta.1 - 2026-09-25

## Changes
- New Unified nameplates option: quest overlays attach into Blizzard's own nameplate UnitFrame with a native level-style count chip. Off by default.
- Fixed default alignment in non-unified mode (health-bar anchoring, Offset Y 0); icons re-anchor after Blizzard recycles plates (death/rez).
- Fonts default to the Blizzard UI font (Friz Quadrata) and inherit globally; legacy defaults migrate automatically.
- New options: Quest Marker toggle + size (Icon tab), target glow toggle (General), percent sign side (Percent), kill/loot icon side (Kill/Loot).
- Options pages use the framework's centered two-column layout.
- Addon list Category and Group are now `RealmGX` instead of `RGX`.

# v2.1.6-beta.1 - 2026-09-25

## Changes
- Fixed options tab buttons not using the SQP brand green via the framework (requires RGX-Framework 2.7.8).

# v2.1.5 - 2026-09-17

## Changes
- Added WoW Forever Beta `1.60.1.69893` compatibility at Interface `120007`.
- Added the `C_TaskQuest.GetQuestsOnMap` fallback used by Forever's Retail-style task API.
- Synced the runtime version with the TOC metadata.

# v2.1.4 - 2026-08-08

## Changes
- **RGX-Framework DB migration**: `SQPSettings` ? `RGX:NewDatabase("SQPSettings", ...)` with `profileIsGlobal = true`
- **Timer migration**: Replaced manual `C_Timer` throttling with `RGX:After` / `RGX:Every`
- **Backward-compat**: `SQPSettings` global remains as proxy to `SQP.db.global`
- Removed manual `C_Timer` fallback in nameplates (RGX-Framework is RequiredDeps)

# v2.1.3 - 2026-08-07

## Changes
- Add Category/Group RGX for addon menu section.

# v2.1.2 - 2026-08-07

## Changes
- TOC bump: Now retail-only (Interface 120007). Removed Classic/Cata/MoP interface entries.

# v2.1.1 - 2026-06-30

## Changes

- Updated for WoW Retail 12.0.7 (Interface 120007).

# v2.1.0 - 2026-05-02

## Changes

- Migrated all sliders to the RGX Framework `UI:CreateSlider` with custom track-style design using RGX brand colors.
- Removed per-slider manual label, reset button, and OnValueChanged boilerplate � the framework now handles all of this internally.
- `SQP:CreateStyledSlider` now delegates to `UI:CreateSlider` when RGXUI is available, with fallback to the old Blizzard slider.
- Sliders support click, drag, scroll wheel, and show value label on hover.
- Net reduction of ~160 lines of manual slider setup code across all options files.

# v2.0.17 - 2026-05-01

## Changes

- Updated SimpleQuestPlates font integration to use the corrected RGX shared font backend.
- Refreshed SQP option UI text rendering so tabs, buttons, and labels use the intended bundled font styling.
- Re-aligned SQP options with the restored RGX Framework tab/button layout behavior.
- Restored Kill, Loot, and Percent reset controls to their intended sizing and placement.

## Fixes

- Fixed SQP font display issues by wiring the addon into the corrected RGX font system.
- Fixed Reset Kill Settings button width and horizontal placement.
- Fixed Reset Loot Settings button width and horizontal placement.
- Fixed Reset Percent Settings button width and horizontal placement.
- Removed unintended tab text repositioning/layout changes from the options panel.
- Verified touched SQP Lua files pass syntax validation.
.ToString().TrimStart()
