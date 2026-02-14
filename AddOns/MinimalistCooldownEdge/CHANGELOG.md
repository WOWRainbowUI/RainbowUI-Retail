# Changelog

## [2.8.2] - 2026-02-14
### Added
- Debug logging system
### Improved
- Centralized and extended blacklist logic for frame exclusion.

## [2.8.1] - 2026-02-13
### Fixed
- **Cooldown Edge Timing:** Fixed a deferred global styling loop that could delay edge reappearance after casting a spell.

## [2.8.0] - 2026-02-13
### Improved
- **Refactor:** Consolidated repeated nameplate detection checks into a shared helper to reduce duplication and improve maintainability.
- **Stability:** Hook installation is now idempotent, preventing duplicate hook registration if the addon is disabled/re-enabled.
- **Lifecycle:** Moved nameplate/combat event registration to `OnEnable()` and added explicit cleanup in `OnDisable()` (including ticker cancellation).
- **Performance:** Upvalued frequently used globals (`InCombatLockdown`, `EnumerateFrames`, `hooksecurefunc`, `UIParent`) to reduce repeated global lookups in hot paths.

## [2.7.0] - 2026-02-11
### Improved
- **Performance:** Upvalued frequently called globals (`string.find`, `pcall`, `C_Timer.After`, etc.) to reduce table lookups.
- **Performance:** Blacklist is now a hash table for O(1) lookups instead of O(n) `ipairs` iteration.
- **Performance:** All `string.find` calls now use `plain=true` (4th argument) since no patterns are needed, avoiding regex overhead.
- **Performance:** Replaced anonymous `pcall(function() ... end)` closures with direct `pcall(frame.Method, frame, ...)` calls to eliminate garbage generation.
- **Performance:** Centralized forbidden-frame checks into a single reusable `IsForbiddenFrame()` helper.
- **Bug Fix:** Font style "None" now correctly passes `""` to the WoW API instead of `"NONE"`, which caused font rendering issues.
- **Bug Fix:** `SetEdgeScale` is now nil-checked before calling, preventing errors on cooldown frames that don't support it.
- **UX:** Added missing **Outline Style** selector for Stack Counter text (was previously hardcoded with no UI control).
- **UX:** Profiles tab now always appears last in the options panel (`order = 10`).
- **Clean Code:** Extracted repetitive get/set closures in Options.lua into reusable `CatGet`, `CatSet`, `CatColorGet`, `CatColorSet` helper functions (~60% boilerplate reduction).
- **Clean Code:** Consolidated duplicate lookup tables (`fontOptions`, anchor values, outline values) into shared constants (`FONT_OPTIONS`, `ANCHOR_OPTIONS`, `OUTLINE_OPTIONS`).
- **Clean Code:** Renamed ambiguous `self_frame` parameter to `cdFrame` for clarity.
- **Clean Code:** Removed dead `TrackCooldown()` wrapper function; tracking is now inline.
- **Clean Code:** Removed redundant `LibStub` nil check around LibActionButton hook (LibStub is guaranteed loaded via TOC).

## [2.6.0] - 2026-02-11
### Added
- Add localization support for multiple languages in MinimalistCooldownEdge
  - Created English (enUS) localization file with default strings.
  - Added Spanish (esES and esMX) localization files with translations.
  - Introduced French (frFR), Italian (itIT), Korean (koKR), Brazilian Portuguese (ptBR), Russian (ruRU), Simplified Chinese (zhCN), and Traditional Chinese (zhTW) localization files with appropriate translations for all strings.

## [2.5.1] - 2026-02-11
### Fixed
- Fixed nameplate event handler signature so unit tokens are passed correctly.
- Avoided scanning forbidden frames so `GetChildren()` is never called on restricted frames.

## [2.5.0] - 2026-02-02
### Added
- **Cooldown Text Positioning:** You can now adjust the position of the main Cooldown Number (Timer).
  - Added "Anchor Point" (e.g., Center, Top Right).
  - Added "Offset X" and "Offset Y" sliders.
  - Available for all categories (Action Bars, Nameplates, UnitFrames, etc.).
  - Enhance cooldown tracking and style application logic for improved performance and functionality
  
## [2.4.1] - 2026-02-01
### Changed
- Adjust category options for improved styling, orders and functionality

## [2.4.0] - 2026-02-01
### Changed
- Adjust category options for improved styling and functionality

## [2.3.1] - 2026-02-01
### Added
- Added the "Expressway" font option.

## [2.3] - 2026-02-01
### Fixed
- Missing Ace3 libraries in the TOC.

# [2.2] - 2026-02-01
### Changed
- **Rebranding:** The addon is now officially named **MiniCE**! The display name in the Addon List and Options Panel has been updated to reflect this change.
  - *Note:* The internal folder name remains `MinimalistCooldownEdge` to ensure all your existing settings and profiles are **preserved**. You do not need to reset anything.
- **Visuals:** Updated the TOC title with the new name and color branding (`|cff00ccffMiniCE|r`).

### Added
- **Slash Command:** Added `/minice` as a valid command to open the options panel (alongside `/mce` and `/minimalistcooldownedge`).
- **Options UI:** Added the addon logo.

# [2.1] - 2026-02-01
### Added
- **Maintenance Tools:** Added a **"Reset Category"** button at the bottom of each tab to easily restore default settings for that specific group.
- **Factory Reset:** Added a **"Reset ALL Settings & Reload"** button in the General tab. This resets the entire profile and automatically triggers a UI reload to ensure a clean state.
- **Visual Legends:** Added color-coded performance guides for "Scan Depth" (Green/Yellow/Orange) and size guides for "Edge Scale" directly in the options panel.
- **Dynamic Hiding:** Disabling a category (e.g., toggling "Enable Category" off) now instantly hides all its related options to reduce clutter.
- **Info Header:** Added a welcome section in General Settings displaying the current version dynamically.

### Changed
- **Major Framework Overhaul (Ace3):** The addon has been completely refactored to use standard Ace3 libraries (AceAddon, AceConfig, AceDB). This ensures better long-term stability and compatibility with other addons.
- **Database Migration:** Switched SavedVariables to MinimalistCooldownEdgeDB_v2. **Note:** This update will reset your settings to default. Your old settings file is safely ignored.
- **Menu Reorganization:** The /mce command now opens a standardized configuration panel inside the Blizzard Interface Options.
- **Global & CD Manager:** The "Global/Items" category has been promoted to a main tab and renamed to **"Global & CD Manager"** for better accessibility.
- **UX Improvements:** Added spacing (padding) between options for a cleaner, less condensed look. Maintenance buttons are now full-width for better readability.

### Fixed
- **Startup Crash:** Resolved a critical race condition (attempt to index field 'categories') where other addons (like sArena) triggered cooldown updates before the database was fully loaded.
- **Load Order:** Fixed Lua errors caused by the Options module trying to attach settings before the Core addon was initialized.

## [2.0] - 2026-02-01
### Added
- **Stack Count Customization (Action Bars):** Added a dedicated section in the Options Panel to customize the "Charges" counter (e.g., for spells like Conflagrate or Shield Block).
  - **Visuals:** You can now change the Font, Size, Outline Style, and Color of the stack number.
  - **Positioning:** Full control over Anchor Points (e.g., BottomRight, Center) and X/Y Offsets.
  - **Layering:** Forces the stack count to render on the `OVERLAY` layer to ensure it stays visible on top of the cooldown swipe animation.

### Fixed
- **Crash Fix (Nil Concatenation):** Resolved a Lua error that occurred when attempting to style frames without a global name. The addon now safely checks `parent:GetName()` before attempting to find the Count region.
- **Stability:** Restricted Stack Count logic strictly to the "Action Bar" category to prevent conflicts and crashes with Nameplates or UnitFrames that have different structures.

## [1.9.3] - 2026-01-30
### Fixed
- **Crash Fix (Type Safety):** Resolved a Lua error (`attempt to index field 'cooldown' (a number value)`) that occurred when other addons (such as *PeralexBGFontEnforcer*) stored numeric data in the `.cooldown` key instead of a frame object. The addon now strictly verifies that `.cooldown` is a table before attempting to style it.

## [1.9.2] - 2026-01-28
### Added
- **Cyrillic Font Support:** Added "Friz Quadrata (Cyrillic)" to the font selection dropdown in the Options panel. This ensures correct character rendering for Russian clients and other Cyrillic users who previously saw question marks (`????`) when using the standard Friz Quadrata font.

## [1.9] - 2026-01-28
### Fixed
- **Secret Value Crash:** Resolved a critical Lua error (`attempt to index local 'self' (a secret value)`) caused by Blizzard's internal Diminishing Returns (DR) UI. All `IsForbidden()` checks are now safely wrapped in protected calls (`pcall`).

### Changed
- **Blacklist Update:** Added "Party", "Compact", and "Raid" frames to the internal hardcoded blacklist. This ensures that the addon no longer attempts to style Party or Raid frames, while still allowing styling for Player and Target frames.

## [1.8] - 2026-01-27
### Fixed
- **Glider Compatibility:** Fixed an issue where enabling the "Global" category would incorrectly attach cooldown styles to the **Glider** addon's speedometer.
- **Hardcoded Blacklist:** Implemented a blacklist system in `Core.lua`. The addon now immediately ignores frames containing specific keywords (currently "Glider") during the detection scan. This prevents interference with incompatible addons and reduces CPU usage by skipping them entirely.

## [1.7] - 2026-01-26
### Optimization
- **Critical Performance Boost (Caching):** Implemented a smart caching system in `Core.lua`. The addon now remembers the category of a cooldown frame after the first scan. This changes the complexity from O(N) to O(1) for subsequent updates, drastically reducing CPU usage during heavy combat or in crowded raids.
- **Garbage Collection:** Used weak tables for the cache to ensure memory is properly released when frames are hidden or destroyed.

## [1.6] - 2026-01-26
### Added
- **Smart Reload Logic:** The options panel now automatically detects when "Global" settings (like Scan Depth) change or when a category is disabled. A popup will appear prompting for a UI Reload, which is required to fully revert styles or update deep scan rules.

## [1.5] - 2026-01-26
### Added
- **Category-Based Styling:** Introduced independent configuration profiles. You can now set distinct styles (Font, Size, Edge Scale) for:
  - Action Bars (Spells)
  - Nameplates
  - Unit Frames
  - Global/Others (Items, Bags, Auras)
- **Deep Scan Heuristic:** Implemented a robust parent-detection algorithm in `Core.lua` that scans up to 20 levels of hierarchy. This ensures proper detection of cooldowns inside complex addon structures (e.g., Plater, ElvUI, VuhDo).

### Changed
- **GUI Overhaul:** Added a "Select Category" dropdown to the options panel, allowing real-time switching between configuration profiles.
- **Optimization:** Added a CPU-efficient "Fast Return" check for standard Blizzard Buff/Debuff buttons to bypass deep scanning and save performance.
- Merged "Auras" configuration into the "Global/Others" category for a streamlined user experience.
- Refactored `Config.lua` to support nested tables for category-specific SavedVariables.

### Fixed
- Fixed an issue where styles failed to apply to nested frames (specifically Nameplates and UnitFrames) because the addon could not identify the parent container.

## [1.4] - 2026-01-26
### Changed
- **Major Refactor:** Completely rewrote the hooking mechanism to avoid "Taint" errors. The addon now targets generic `CooldownFrame` events instead of invasive `ActionButton` hooks.
- Implemented `C_Timer.After` execution delays (0-frame delay) to ensure style application never interferes with Blizzard's Secure Execution Path.
- Enhanced compatibility with **Bartender4** and other addons using `LibActionButton-1.0`.
- Replaced unsafe `ActionBarController_UpdateAll` calls with a custom, non-tainting manual refresh method.

### Fixed
- Resolved critical `ADDON_ACTION_BLOCKED` errors that were breaking Stance/Shape-shift bars.
- Fixed `attempt to compare a secret value` Lua errors caused by modifying secure action buttons during updates.
- Fixed a crash when attempting to open the Options Panel (`/mce`) while in combat; the command now checks for `InCombatLockdown()` properly.

## [1.3] - 2026-01-26
### Changed
- Updated version to 1.3 in .toc and GUI.
- Improved event-driven initialization and hook logic in `Core.lua` for better compatibility and reliability.
- Replaced bulk cooldown apply with robust hooks for `CooldownFrame_Set`, `CooldownFrame_SetTimer`, and `ActionButton_UpdateCooldown`.
- GUI now uses a `RefreshVisuals()` helper for immediate updates when settings change.

## [1.2] - 2026-01-25
### Added
- Configuration system with SavedVariables support (`Config.lua`)
  - Persistent settings across game sessions via `MinimalistCooldownEdgeDB`
  - Default configuration with deep copy for missing values
- In-game GUI options panel (`GUI.lua`)
  - Font customization (dropdown with 7 font options)
  - Font size slider (8-36)
  - Font style options (Outline, Thick Outline, Monochrome, None)
  - Text color picker with opacity support
  - Edge enable/disable toggle
  - Edge scale slider (0.5-2.0)
  - Reset to defaults button
  - Reload UI button
- Slash commands: `/mce` and `/minimalistcooldownedge`
- Support for all action bar types (MultiBar1-7)

### Changed
- Refactored `Core.lua` to use configuration system
  - Replaced hardcoded values with dynamic config retrieval
  - Separated apply logic into `ApplyCustomStyle()` function
  - Added `ApplyAllCooldowns()` function for bulk updates
  - Proper event-driven initialization with `ADDON_LOADED` and `PLAYER_LOGIN`
- Updated `.toc` file structure
  - Added `SavedVariables: MinimalistCooldownEdgeDB`
  - Added `Config.lua` and `GUI.lua` to file list
  - Version bumped to 1.2

### Fixed
- Settings now apply to all visible cooldowns on load
- Edge settings now properly toggleable

## [1.1] - 2026-01-25
### Changed
- Translated all code comments and print messages to English.
- Updated `.toc` metadata:
  - Added colored title for better visibility in the addon list.
  - Added an icon texture.
- Improved Cooldown Text styling:
  - Now sets custom font, size, and color for cooldown timers using `GetRegions`.
  - Ensures native cooldown numbers are shown via `SetHideCountdownNumbers(false)`.

## [1.0] - 2025-01-25
### Added
- Initial release.
- Custom texture for cooldown edges (`EdgeTexture`).
- Customized swipe color (`SwipeColor`).
- "Bling" effect enabled for finished cooldowns.
- Basic hooks for `ActionButton_UpdateCooldown` and `CooldownFrame_SetDrawEdge`.