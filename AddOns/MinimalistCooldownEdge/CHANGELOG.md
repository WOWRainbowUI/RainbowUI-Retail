# Changelog


## [4.0.7] - HealerCC Support
- Added HealerCC support for friendly and enemy alert cooldown icons.
- Added dedicated HealerCC styling options and a quick toggle.


## [4.0.6] - BetterBlizzFrames Support
- Added BetterBlizzFrames support for Player Auras.
- Improved Player Aura timer handling with BetterBlizzFrames.


## [4.0.5] - External Defensive Buffs
- Added Player Aura styling for external defensive buffs.
- Added a separate toggle for external defensive buff styling.
- Added a Timer Inside Icon option for Player Auras.

## [4.0.4] - Split Buff Styling
- Added separate Buff Styling and Debuff Styling options for Player Auras.
- Added separate toggles for styling player buffs and debuffs.
- Player Aura buffs and debuffs now use separate styling settings.

## [4.0.3] - Player Aura Swipe Options
- Improved Player Auras swipe behavior on Blizzard buffs, debuffs, and external defensives.
- Added a Reverse Swipe option for Player Auras.
- Updated the Player Auras swipe settings layout.

## [4.0.2] - Player Aura Support
- Added Player Auras styling for Blizzard default player buffs and debuffs.
- Added player aura duration, stack/count, fading, and swipe overlay options.
- Added Player Auras to the General quick-toggle dashboard.

## [4.0.1] - Party and Raid Frames Retirement
- Retired Party / Raid Frames support for Blizzard Patch 12.0.5 compatibility. The options entry now shows an informational notice and MiniCE no longer loads the compact group frame adapter/controller.
- Blacklist: Add CompactPartyFrame, CompactRaidFrame, RaidFrameAuras, and RFA_ to Classifier

## [3.9.8] - MiniCC Healer Text Color
- feat: add healer warning text color customization and apply it in MiniCC

## [3.9.7] - MiniCC Enemy CD Options
- refactor: streamline aura scanning logic and remove unused charge cooldown functions
- Added MiniCC Enemy CDs text options for both Arena Frames and Linear Bar.
- Font size sliders can now go down to 6 for extra-small cooldown text.

## [3.9.6] - Short Cooldown Precision
- Added an option to show tenths of a second on very short cooldowns.
- Improved cooldown timer accuracy and consistency across more UI elements on Retail 12.0.5.

## [3.9.5] - Retail 12.0.5 TOC Update
- Updated the TOC file to include the 12.0.5 interface versions

## [3.9.4] - Cooldown Performance Update
- Performance improvements for cooldowns, styling, and update ticks
- Lower CPU and memory overhead from better caching and less reprocessing
- More efficient action bar and nameplate cooldown updates
- Internal cleanup to remove duplicate helper logic

## [3.9.3] - Viewer Refresh Queue
- feat: Implement queuing mechanism for buff icon owners and viewer refreshes to prevent redundant updates

## [3.9.2] - MiniCC Compatibility Update
- feat: Add new frame types to Classifier for enhanced compatibility with additional addons
- perf: Reduce MiniCC integration overhead by reusing MiniCC's cached countdown FontString instead of rescanning cooldown regions on every update.
- compat: Stop forcing per-pass MiniCC text-region refreshes once the countdown region is already known.

## [3.9.1] - Loss of Control Cooldowns
- feat: Implement loss of control cooldown handling in HookBridge and adapters for improved cooldown management

## [3.9.0] - CooldownManager Buff Fixes
- Fixed buff icon issue where one timer could stay on the expiring color.
- Added a safer compatibility refresh for CooldownManagerCentered buff icons without affecting normal CooldownManager setups.

## [3.8.9] - CooldownManager Aura Recovery
- Better aura timer tracking in CooldownManager, especially right after viewer refreshes.
- Buff-icon slots now recover their timer color faster and more reliably.

## [3.8.8] - CooldownManager Buff Colors
- CooldownManager slots that temporarily display aura/buff time now use a dedicated static buff color, then fall back to normal threshold colors once they return to the real cooldown.
- CooldownManager viewer detection now follows tullaCTC-style first-named-frame matching, which keeps Essential and Utility viewers separated instead of falling back to a shared subtype.
- Smoother aura cooldown handling in busy fights, with fewer wasted refresh attempts.
- feat: Enhanced HookBridge with unmanaged aura claim retry logic and safer frame state handling.
- CooldownManager no longer has its threshold colors forcibly disabled just because CooldownManagerCentered is loaded.
- Removed the CooldownManagerCentered override switch; CooldownManager viewers now stay routed through MiniCE while keeping the compatibility alerts.

## [3.8.7] - Retail Startup Reliability
- Improved startup reliability so cooldown styling initializes more consistently on Retail Midnight.
- Better compatibility with late-loaded addons like mUI and LibSharedMedia.
- Reduced extra addon detection work in cooldown styling paths.

## [3.8.6] - CooldownManagerCentered Override
- Added a MiniCE override for CooldownManagerCentered on CooldownManager viewers.
- Added a small orange warning when MiniCE and CMC style the same viewer timers.

## [3.8.5] - Bartender4 Combat Compatibility
- Reduced stutters with Bartender4 and compatible BT4 plugins on Retail.
- MiniCE now avoids fighting some BT4 cast animation swipe changes during combat.

## [3.8.4] - mUI Combat Compatibility
- Reduced freezes and stuttering when using MiniCE with mUI on Retail.
- MiniCE now leaves mUI's aura swipe styling alone instead of fighting it.

## [3.8.3] - Masque Compatibility
- Improved compatibility with Masque and Masque skin packs/plugins.

## [3.8.2] - CooldownManagerCentered Freeze Fix
- Fixed freezes/stuttering when used alongside CooldownManagerCentered.

## [3.8.1-beta] - Blacklist Coverage Beta
- compat: Expand classifier blacklists for Blizzard inventory, bank, mail, and inspect UI cooldown widgets.
- compat: Add explicit blacklist coverage for Platynator, Masque, ShadowedUF, and Cell frame families.

## [3.8.0] - Bartender4 Adapter Support
- feat: Add dedicated Bartender4 adapter with pre-registered cooldown frames and Options toggle.
- fix: Preserve the 3.7.9 behavior for Bartender4 by excluding its Loss-of-Control cooldown overlay from MiniCE styling.
- perf: HookBridge - registered cooldowns skip all security pcalls on every hook invocation, benefiting all adapters.
- perf: Enforcement hooks check `frameState` first so unmanaged frames exit at zero pcall cost.

## [3.7.9] - Loss-of-Control Overlay Exclusion
- feat: Exclude Blizzard's Loss-of-Control cooldown overlay

## [3.7.8] - MiniCC Hide Swipe Toggles
- MiniCC: Added per-frame-group **Hide Swipe** toggles (CC, Friendly CDs, Nameplates, Portraits, Alerts/Healer/Timers). Toggling a group hides both the swipe animation and the swipe edge for that group while keeping countdown text visible.
- Added French (frFR) locale strings for the new Hide Swipe options and several previously untranslated keys (Show Swipe Animation, Swipe Shade Alpha, CC Frames Text Size, Friendly CDs Text Size, Hide Stack Text).

## [3.7.7] - Nameplate GCD Tracker Blacklist
- Blacklisted the Nameplate GCD Tracker frame so MiniCE won't style it.

## [3.7.6] - Dominos Adapter Support
- Add dedicated Dominos adapter for independent cooldown management.

## [3.7.5] - Dominos and EllesmereUI Blacklist
- Expanded classifier blacklists for Dominos and EllesmereUI so their known frames and parent containers are ignored by MiniCE styling.

## [3.7.4] - Expanded MiniCC Support
- Improved MiniCC support so more widgets are detected and styled correctly, including Friendly CDs, Friendly Indicators, Portraits, Alerts, Healer CC, Kick Timer, and Precognition.
- Added separate MiniCC text size controls for Friendly CDs and cleaned up the MiniCC options so the groups are easier to understand.
- Improved font stability on MiniCC cooldowns so your chosen text size sticks more reliably.

## [3.7.3] - ElvUI Adapter Fix
- Fixed the ElvUI adapter after the 3.7.1 changes so ElvUI action bars, unit frames, and nameplates are styled correctly.

## [3.7.2] - Blacklist Security Checks
- feat: Enhance blacklist handling with secret value checks and access control in Classifier and HookBridge modules

## [3.7.1] - Chat Taint Fix
- Fixed a Blizzard chat taint issue that could affect separate whisper and Battle.net whisper windows.
- Improved cooldown filtering so unsupported Blizzard UI elements are ignored earlier for better stability.

## [3.7.0] - ElvUI Beta Support
- Added a reload prompt for settings that need `Reload UI`.
- Improved category settings handling.
- Added beta ElvUI support with dedicated options and edge color handling.
- Improved ElvUI detection and blacklist handling.
- ArenaDR Nameplates: Added to the Help & Support page

## [3.6.9] - ShinyAuras Support
- Add ShinyAuras addon support via ShinyAurasAdapter

## [3.6.8] - Blacklist Expansion
- feat: Enhance blacklist functionality in Classifier module with additional entries and improved parent name checks

## [3.6.7] - Unit Frame Integration
- Enhance GroupFrameAdapter and UnitFrameAdapter integration for cooldown management

## [3.6.6] - ElvUI Blacklist Update
- feat: Add ElvUI and Gw2_ to blacklist Classifier entries
   
## [3.6.5] - Blacklist Caching Update
- feat: Enhance blacklist functionality in Classifier module with caching and parent frame checks
- fix: Blacklist TotemFrame and PlayerFrameBottomManagedFramesContainer

## [3.6.4] - TellMeWhen Support
- feat: Add TellMeWhen support with new adapter and configuration options

## [3.6.3] - Unit Frame Stack Options
- feat: Enhance unit frame stack count customization with new options and styling
- Remove ElvUI Support

## [3.6.2] - sArena and Threshold Colors
- Remove "Others" / "Global" category
- Add support to sArena
- Implement allowThresholdColors feature for category-based cooldown text coloring
- Add aura retry logic and text region tracking

## [3.6.1] - Totem and MiniCC Cleanup
- feat: Add "TotemFrame" to classifier frame list
- feat: Simplify MiniCC frame hierarchy handling and update related constants

## [3.6.0] - Adapter Registry Refactor
### Refactor
- The monolithic global frame-scanning model has been replaced with an adapter-driven registry architecture.

## [3.5.7] - Compact Party Swipe Options
- feat: Add swipe animation options for compact party auras

## [3.5.6] - Unit Frame Aura Filters
- Disable duration text colors and add performance warning in options
- Add 'Only Mine' option for cooldown text display on unitframes's auras

## [3.5.5] - Duration Source Tracking
- feat: Enhance cooldown duration handling with source key support

## [3.5.4] - Nameplate Stack Support
- Add nameplate stacks and fix minor issues

## [3.5.3] - Shared Constants
- Extracted the shared static values into Constants

## [3.5.2] - Charge Swipe Update
- Update swipe drawing logic for charge cooldowns

## [3.5.1] - Housing Dashboard Blacklist
- Add "HousingDashboardFrame" to blacklist
- Minor improved performance

## [3.5.0] - Performance and Swipe Options

### Improved
- Better performance during cooldown styling.
- New swipe animation option for action bars.
- Cooldown visuals now stay in sync more reliably.

## [Pre-3.5] - Addon Evolution Summary

### Summary
- Built the addon from the initial release into a configurable cooldown styling system with SavedVariables, slash commands, an in-game options panel, Ace3 integration, and the MiniCE rebrand.
- Added per-category customization for action bars, nameplates, unit frames, party/raid auras, MiniCC, and other cooldown viewers, including text positioning, stack/charge styling, swipe controls, and charge timer visibility.
- Expanded user-facing features with profile import/export, dynamic cooldown text colors, threshold tuning, localization across many languages, extra font support, and several usability improvements in the options UI.
- Improved detection and compatibility through deep-scan heuristics, blacklist/classifier/styler refactors, faster frame detection, safer aura/context resolution, and better support for addons such as Bartender4 and MiniCC.
- Fixed major stability and performance issues over time, including taint and secret-value errors, flicker/flash behavior, forbidden-frame handling, charge cooldown overlap, startup/load-order problems, and various action bar, raid, and nameplate edge cases.
