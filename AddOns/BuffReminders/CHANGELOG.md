# BuffReminders

## [v6.11.0](https://github.com/zerbiniandrea/BuffReminders/tree/v6.11.0) (2026-11-16)
[Full Changelog](https://github.com/zerbiniandrea/BuffReminders/compare/v6.10.1...v6.11.0) [Previous Releases](https://github.com/zerbiniandrea/BuffReminders/releases)

### New Features ✨

- **Consumables:** add the Midnight flask cauldron to the flask reminder
- **Consumables:** mark flask cauldrons with a C badge
- **Profiles:** ask for confirmation before deleting a profile

### Bug Fixes 🐛

- **Consumables:** recognize the hearty versions of the Midnight 12.1 feasts
- **Profiles:** keep settings of new and reset profiles after a reload
- **Profiles:** keep tracked externals and warlock demons when importing old profiles

### Localization 🌐

- Updated translations: koKR

### Other Changes 🔧

- **Libs:** update embedded libs (AceDB-3.0 LibSharedMedia-3.0 LibSpecialization)
- **Migrations:** stamp unversioned profiles on raw saved data at every login
- **Migrations:** reset profiles below v48 instead of migrating them
- **Migrations:** migrate every profile on raw saved data before AceDB loads
- **Migrations:** migrate import strings before they replace the live profile
- **Migrations:** describe the raw per-profile migration runner and the v48 floor
- Rename the fleeting flask set to match its cauldron entries

