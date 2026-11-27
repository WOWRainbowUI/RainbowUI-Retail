# BuffReminders

## [v7.1.0](https://github.com/zerbiniandrea/BuffReminders/tree/v7.1.0) (2026-11-26)
[Full Changelog](https://github.com/zerbiniandrea/BuffReminders/compare/v7.0.1...v7.1.0) [Previous Releases](https://github.com/zerbiniandrea/BuffReminders/releases)

### New Features ✨

- **Appearance:**
  - Allow negative spacing so icons can overlap
  - Size each text in pixels with its own control
- **Custom-buffs:** pick spell IDs from your active buffs with /br auras
- **WoW Forever:**
  - **Racials:** remind Skyborne players to get Attuned or Charged
  - **Warlock:**
    - Remind Sacrifice, Pact and Soul Link in order
    - Add a Spellstone and Firestone weapon reminder
    - Choose the demon to sacrifice per content

### Bug Fixes 🐛

- **Appearance:** render every icon gap at its exact pixel width
- **Click-to-cast:**
  - Move the click area with the icon after a set position
  - Stop icon clicks and hover effects while frames are unlocked
  - Cast a newly learned rank without waiting for combat
- **Layout:** leave the coordinate field after Enter applies the position
- Show long buff names in full in the buff list
- **WoW Forever:**
  - **Raid-buffs:** skip players whose scroll or camp buff blocks the cast

### Localization 🌐

- Updated translations: zhTW

### Other Changes 🔧

- 17 internal changes (code cleanup, build and docs). The full changelog lists each one.

