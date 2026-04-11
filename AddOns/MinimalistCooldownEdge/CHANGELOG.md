
# Changelog

## [3.8.4] - 2026-04-10
- Reduced freezes and stuttering when using MiniCE with mUI on Retail.
- MiniCE now leaves mUI's aura swipe styling alone instead of fighting it.

## [3.8.3] - 2026-04-10
- Improved compatibility with Masque and Masque skin packs/plugins.

## [3.8.2] - 2026-04-10
- Fixed freezes/stuttering when used alongside CooldownManagerCentered.

## [3.8.1-beta] - 2026-04-08
- compat: Expand classifier blacklists for Blizzard inventory, bank, mail, and inspect UI cooldown widgets.
- compat: Add explicit blacklist coverage for Platynator, Masque, ShadowedUF, and Cell frame families.

## [3.8.0] - 2026-04-08
- feat: Add dedicated Bartender4 adapter with pre-registered cooldown frames and Options toggle.
- fix: Preserve the 3.7.9 behavior for Bartender4 by excluding its Loss-of-Control cooldown overlay from MiniCE styling.
- perf: HookBridge - registered cooldowns skip all security pcalls on every hook invocation, benefiting all adapters.
- perf: Enforcement hooks check `frameState` first so unmanaged frames exit at zero pcall cost.

## [3.7.9] - 2026-04-07
- feat: Exclude Blizzard's Loss-of-Control cooldown overlay

## [3.7.8] - 2026-04-07
- MiniCC: Added per-frame-group **Hide Swipe** toggles (CC, Friendly CDs, Nameplates, Portraits, Alerts/Healer/Timers). Toggling a group hides both the swipe animation and the swipe edge for that group while keeping countdown text visible.
- Added French (frFR) locale strings for the new Hide Swipe options and several previously untranslated keys (Show Swipe Animation, Swipe Shade Alpha, CC Frames Text Size, Friendly CDs Text Size, Hide Stack Text).

## [3.7.7] - 2026-04-05
- Blacklisted the Nameplate GCD Tracker frame so MiniCE won't style it.

## [3.7.6] - 2026-04-03
- Add dedicated Dominos adapter for independent cooldown management.

## [3.7.5] - 2026-04-03
- Expanded classifier blacklists for Dominos and EllesmereUI so their known frames and parent containers are ignored by MiniCE styling.

## [3.7.4] - 2026-04-02
- Improved MiniCC support so more widgets are detected and styled correctly, including Friendly CDs, Friendly Indicators, Portraits, Alerts, Healer CC, Kick Timer, and Precognition.
- Added separate MiniCC text size controls for Friendly CDs and cleaned up the MiniCC options so the groups are easier to understand.
- Improved font stability on MiniCC cooldowns so your chosen text size sticks more reliably.

## [3.7.3] - 2026-04-01
- Fixed the ElvUI adapter after the 3.7.1 changes so ElvUI action bars, unit frames, and nameplates are styled correctly.

## [3.7.2] - 2026-03-31
- feat: Enhance blacklist handling with secret value checks and access control in Classifier and HookBridge modules

## [3.7.1] - 2026-03-30
- Fixed a Blizzard chat taint issue that could affect separate whisper and Battle.net whisper windows.
- Improved cooldown filtering so unsupported Blizzard UI elements are ignored earlier for better stability.

## [3.7.0] - 2026-03-29
- Added a reload prompt for settings that need `Reload UI`.
- Improved category settings handling.
- Added beta ElvUI support with dedicated options and edge color handling.
- Improved ElvUI detection and blacklist handling.
- ArenaDR Nameplates: Added to the Help & Support page

## [3.6.9] - 2026-03-28
- Add ShinyAuras addon support via ShinyAurasAdapter

## [3.6.8] - 2026-03-28
- feat: Enhance blacklist functionality in Classifier module with additional entries and improved parent name checks

## [3.6.7] - 2026-03-26
- Enhance GroupFrameAdapter and UnitFrameAdapter integration for cooldown management

## [3.6.6] - 2026-03-25
- feat: Add ElvUI and Gw2_ to blacklist Classifier entries
   
## [3.6.5] - 2026-03-24
- feat: Enhance blacklist functionality in Classifier module with caching and parent frame checks
- fix: Blacklist TotemFrame and PlayerFrameBottomManagedFramesContainer

## [3.6.4] - 2026-03-24
- feat: Add TellMeWhen support with new adapter and configuration options

## [3.6.3] - 2026-03-24
- feat: Enhance unit frame stack count customization with new options and styling
- Remove ElvUI Support

## [3.6.2] - 2026-03-22
- Remove "Others" / "Global" category
- Add support to sArena
- Implement allowThresholdColors feature for category-based cooldown text coloring
- Add aura retry logic and text region tracking

## [3.6.1] - 2026-03-22
- feat: Add "TotemFrame" to classifier frame list
- feat: Simplify MiniCC frame hierarchy handling and update related constants

## [3.6.0] - 2026-03-22
### Refactor
- The monolithic global frame-scanning model has been replaced with an adapter-driven registry architecture.

## [3.5.7] - 2026-03-21
- feat: Add swipe animation options for compact party auras

## [3.5.6] - 2026-03-21
- Disable duration text colors and add performance warning in options
- Add 'Only Mine' option for cooldown text display on unitframes's auras

## [3.5.5] - 2026-03-20
- feat: Enhance cooldown duration handling with source key support

## [3.5.4] - 2026-03-20
- Add nameplate stacks and fix minor issues

## [3.5.3] - 2026-03-20
- Extracted the shared static values into Constants

## [3.5.2] - 2026-03-18
- Update swipe drawing logic for charge cooldowns

## [3.5.1] - 2026-03-17
- Add "HousingDashboardFrame" to blacklist
- Minor improved performance

## [3.5.0] - 2026-03-17

### Improved
- Better performance during cooldown styling.
- New swipe animation option for action bars.
- Cooldown visuals now stay in sync more reliably.

## [Pre-3.5] - 2025-01-25 to 2026-03-15

### Summary
- Built the addon from the initial release into a configurable cooldown styling system with SavedVariables, slash commands, an in-game options panel, Ace3 integration, and the MiniCE rebrand.
- Added per-category customization for action bars, nameplates, unit frames, party/raid auras, MiniCC, and other cooldown viewers, including text positioning, stack/charge styling, swipe controls, and charge timer visibility.
- Expanded user-facing features with profile import/export, dynamic cooldown text colors, threshold tuning, localization across many languages, extra font support, and several usability improvements in the options UI.
- Improved detection and compatibility through deep-scan heuristics, blacklist/classifier/styler refactors, faster frame detection, safer aura/context resolution, and better support for addons such as Bartender4 and MiniCC.
- Fixed major stability and performance issues over time, including taint and secret-value errors, flicker/flash behavior, forbidden-frame handling, charge cooldown overlap, startup/load-order problems, and various action bar, raid, and nameplate edge cases.
