# Changelog

## Release

- Version updated to `v12.019`.
- General tab Blizzard CT controls were finalized:
- `Enable Blizzard CT In Group` controls Blizzard CT only while grouped.
- `Disable Blizzard CT While Solo` controls Blizzard CT only while solo.
- Fixed checkbox interaction bugs where group settings could incorrectly affect solo behavior.
- Removed extra Blizzard group child toggles and simplified to one group toggle.
- Stopped writing the global `enableFloatingCombatText` CVar from MSBT; toggles now use specific combat-text lane CVars only.
- Improved outgoing fallback filtering to reduce misattribution from `UNIT_COMBAT("target")`:
- Requires valid attackable target context.
- Requires recent outgoing signal confidence (recent cast, active owned DoT fallback, or valid auto-attack swing timing).
- Removed unconditional auto-attack fallback acceptance.
- Fixed crit batch font scaling so Master Fonts `Crit Font Size` applies correctly to crit attack output.
- Fixed outgoing heal visibility outside combat by exempting outgoing heal/HoT events from the outgoing combat gate.
- Hardened search-message parsing against Blizzard secret strings in chat-based parser events such as XP gain.
- Fixed a nil helper scope issue in `MSBTMain.lua` that could break parser dispatch.
- Fixed monster emote target-name matching so secret-string comparisons no longer throw errors.
- Added Escape-key close support for the MSBT Options window.
