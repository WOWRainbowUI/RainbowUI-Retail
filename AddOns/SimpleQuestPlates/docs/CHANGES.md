# v2.1.0 - 2026-05-02

## Changes

- Migrated all sliders to the RGX Framework `UI:CreateSlider` with custom track-style design using RGX brand colors.
- Removed per-slider manual label, reset button, and OnValueChanged boilerplate — the framework now handles all of this internally.
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
