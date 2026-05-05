# v1.7.0 - 2026-05-02

## Changes

- Rewrote `UI:CreateSlider` to use a custom track-style slider with RGX brand colors instead of Blizzard's OptionsSliderTemplate.
- Added `UI:CreateVolumeSlider` for discrete 3-position volume control with the same custom track styling.
- Both slider types use Design module brand colors for consistent theming across all RGX addons.
- New sliders support click, drag, scroll wheel, hover value label, and built-in reset button.

## Fixes

- Fixed reset button vertical alignment on the new slider.

# v1.6.0 - 2026-05-01

## Changes

- Reworked backend font handling to properly support shared bundled fonts across downstream addons.
- Improved RGX font registration, lookup, and UI application paths so addons can reliably consume the shared font system.
- Updated shared option UI behavior for tabs, buttons, labels, and reset controls.
- Restored framework tab sizing and label anchoring to the expected RGX defaults.
- Cleaned up button/tab text handling to avoid unintended wrapping, alignment drift, and inconsistent font-string anchors.
- Rewrote README.md as a polished entry point with links to the full wiki documentation.
- Added comprehensive wiki documentation: Architecture, API Reference, Fonts System, Dropdowns System, Theming & Design, Troubleshooting, and Migration Guide.
- Updated CurseForge description.html with current module list, font counts, and documentation links.
- Fixed stale file path references (modules/fonts/fonts.lua → modules/fonts/definitions.lua).
- Fixed inconsistent dormant module wording across all docs (standardized to "in-tree but not loaded by the XML loader").
- Fixed stale interface version in Super Simple example code (110002 → 120005).
- Standardized font count language across all docs (36 bundled + 8 WoW defaults = ~44 total, 10 blocked, ~34 available).

## Fixes

- Fixed shared font plumbing needed by PetBuddy2 and SimpleQuestPlates.
- Fixed RGX option tabs using widened dimensions and incorrect text alignment.
- Fixed non-icon option tab labels being left-aligned instead of centered.
- Fixed icon tab label padding regressions.
- Removed unintended word-wrap and font-string anchor changes from shared RGX controls.
- Verified touched RGX Lua files pass syntax validation.
