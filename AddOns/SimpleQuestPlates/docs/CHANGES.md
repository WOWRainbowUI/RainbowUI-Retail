# v2.1.4 - 2026-08-08

## Changes
- **RGX-Framework DB migration**: `SQPSettings` → `RGX:NewDatabase("SQPSettings", ...)` with `profileIsGlobal = true`
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
- Removed per-slider manual label, reset button, and OnValueChanged boilerplate â€” the framework now handles all of this internally.
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
