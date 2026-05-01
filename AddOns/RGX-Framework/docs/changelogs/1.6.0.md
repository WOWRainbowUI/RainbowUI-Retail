# v1.6.0 - 2026-05-01

## Changes

- Reworked backend font handling to properly support shared bundled fonts across downstream addons.
- Improved RGX font registration, lookup, and UI application paths so addons can reliably consume the shared font system.
- Updated shared option UI behavior for tabs, buttons, labels, and reset controls.
- Restored framework tab sizing and label anchoring to the expected RGX defaults.
- Cleaned up button/tab text handling to avoid unintended wrapping, alignment drift, and inconsistent font-string anchors.

## Fixes

- Fixed shared font plumbing needed by PetBuddy2 and SimpleQuestPlates.
- Fixed RGX option tabs using widened dimensions and incorrect text alignment.
- Fixed non-icon option tab labels being left-aligned instead of centered.
- Fixed icon tab label padding regressions.
- Removed unintended word-wrap and font-string anchor changes from shared RGX controls.
- Verified touched RGX Lua files pass syntax validation.
