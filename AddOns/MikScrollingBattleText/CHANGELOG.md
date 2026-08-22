# Changelog

## v12.022

- Fixed CurseForge release metadata to publish explicit WoW Retail `12.1.0` game-version names.
- Bumped the addon version to `12.022`.

## v12.021

- Fixed `UnitAttackSpeed("player")` secret-number handling in auto-attack fallback timing.
- Prevented restricted-content arithmetic errors caused by secret swing-speed values.
- Hardened `MSBTMain.lua` against Blizzard secret booleans in target/focus heal attribution and target validation paths.
- Fixed secret-string comparison issues in monster emote matching and safe string-key generation.
- Hardened damage-meter outgoing polling against secret GUID / secret key failures.
- Reworked damage-meter dedupe/cache keys to avoid indexing Lua tables with secret GUID-derived values.
- Hardened `MSBTParser.lua` pet-map refresh logic against secret booleans, secret GUID comparisons, and secret GUID table-key writes.
