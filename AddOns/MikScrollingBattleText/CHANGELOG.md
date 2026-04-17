# Changelog

## Release

- Version updated to `v12.020`.
- Hardened unit-API boolean checks against Blizzard secret booleans in target/focus heal attribution and target validation paths.
- Replaced raw `UnitExists`/`UnitCanAssist`/`UnitIsUnit`/`UnitCanAttack`/`UnitIsEnemy` boolean tests in MSBT hot paths with safe guarded evaluation.
