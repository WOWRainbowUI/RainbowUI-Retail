# Changelog

All notable changes to LibBabble-SubZone-3.0 are listed here, newest first.

Release names follow `<WoW version>-release<N>`. Each release is a Git tag and an SVN tag of the same name, and CurseForge packages it from the SVN tag.

`MINOR_VERSION` is the LibStub version in `Core/Core.lua`. When several addons embed the library, the copy with the highest `MINOR_VERSION` is used.

## [12.1-release4] - 2026-11-09

### Data

- Data regenerated from client builds 12.1.5.70783 (Mainline), 1.15.9.70576 (Classic Era), 2.5.6.70577 (Classic TBC), 1.60.1.70862 (Classic Forever), and 5.5.4.70631 (Classic Progression).
- Added 28 location names, including new Classic Forever areas such as Crystalline Highlands, The Drowned City, and Hyjal Crater. Removed 4 names that are no longer in the client data: Dalaran Exchange, The Linguists Lounge, The Violet HOld, and Wands and Wonder.
- Translation updates from the new client data in every locale.
- itIT: 9,682 names now have Italian translations, 1,384 more than in 12.1-release3. 30 incorrect Italian translations were replaced by the English name. Classic clients have no Italian locale and return English names, so the generator now prefers a real translation over an English placeholder.

### Changed

- `MINOR_VERSION` is now the fixed number `100301` instead of being derived from the SVN `$Rev$` keyword (the last derived value was `100268`). Git and SVN builds now report the same version.
- Removed all SVN keywords (`$Id$`, `$Rev$`, `$Author$`) from the source files.
- Each client data file now loads only on its own client: Mainline checks `WOW_PROJECT_MAINLINE` and Classic Forever checks `WOW_PROJECT_CAMELOT`, both through `WOW_PROJECT_ID`.
- Updated the website link in `Core/Core.lua` to CurseForge.
- The TOC now shows the release version (`## Version`).
- This changelog is now used as the file changelog on CurseForge.

### Fixed

- When several addons embed the library, only the copy that wins the LibStub version check builds `MapData`. Previously every embedded copy built its own map data tables, using more memory and load time.
- The library no longer leaves data in the host addon's private namespace table. `Core/Cleanup.lua` removes the temporary loading key after the last data file loads.

### Added

- `LICENSE` file (MIT for LibBabble-SubZone-3.0; the bundled LibBabble-3.0 core is in the public domain).
- Developer documentation in `Docs/`: this changelog, an API reference, an integration guide, and a maintainer guide.
- A Sponsor button on the GitHub repository, linking to Patreon (`.github/FUNDING.yml`).

### Project

- Source code moved from WoWAce SVN to [GitHub](https://github.com/arithmandar/LibBabble-SubZone-3.0), with the full SVN history imported.
- SVN is now a one-way mirror of GitHub. Pushes to `main` update SVN `trunk`, and Git tags create SVN tags. Existing `.pkgmeta` externals that point to the SVN repository keep working.
- Pull requests that change runtime files fail CI unless `MINOR_VERSION` increases.
- Updated the `.util` data generators to match the current `Data/` file layout.

## [12.1-release3] - 2026-10-15

- TOC update.

## [12.1-release2] - 2026-10-06

- Classic Forever now uses its own project ID, `WOW_PROJECT_CAMELOT`.
- Removed redundant lines.

## [12.1-release1] - 2026-09-29

- Added zone names from client builds 1.15.9 (11509), 1.60.1 (16001), 2.5.6 (20506), 5.5.4 (50504), and 12.1.0 (120100).
- New per-client data files in `Data/`: `AreaToUIMapID_<client>.lua` and `LocalizedNameIndexes_<client>.lua` for Mainline, Classic Era, Classic Forever, Classic Progression, and Classic TBC.
- `GetLookupTable()` now resolves names through the client APIs (`C_Map.GetAreaInfo`, `C_Map.GetMapInfo`) before falling back to the locale tables.
- Single multi-client TOC; removed the separate BCC, Classic, and WotLK Classic TOC files.
- Added `.util` maintenance scripts that download Wago Tools CSV exports and generate the data files.

## [10.0-release3] - 2023-03-20

- TOC update for WoW 10.0.7 and 3.4.1.

## [10.0-release2] - 2022-11-20

- Reorganized the folder structure and locale files.
- Added `AreaToUIMapID.lua`.
- Added area names used in TaxiNodes.

## [10.0-release1] - 2022-11-17

- Imported AreaTable and Map data from 10.0.2.46479.
- TOC update for WoW 10.0.0 and 10.0.2.

## [9.2-release5] - 2022-08-17

- TOC update for WoW 9.2.7.

## [9.2-release4] - 2022-07-23

- Retail TOC update for 9.2.5; Classic TOC update for 1.14.3.
- Added a TOC for Wrath of the Lich King Classic (3.4.0).
- Zone names updated to build 44444.

## [9.2-release3] - 2022-03-23

- Burning Crusade Classic TOC update for 2.5.4.

## [9.2-release2] - 2022-02-23

- Fixed a German translation issue.

## [9.2-release1] - 2022-02-23

- TOC update for WoW 9.2.0.

## [9.1-release4] - 2022-02-20

- Added UiMap zone names.
- Added new zones and translations from 9.2.0.42423.
- Added Classic and Burning Crusade Classic TOC files.

## [9.1-release3] - 2022-02-02

- TOC update for WoW 9.1.5.

## [9.1-release2] - 2021-06-28

- Added JournalInstance and scenario zone names.

## [9.1-release1] - 2021-06-27

- Added zones and translations from 9.1.0.39172 and 2.5.1.39170.

## [9.0-release1] - 2020-10-26

- Added zones and translations from 9.0.1.36372.

## [8.3-release3] - 2020-07-26

- Added zones up to 9.0.1.35282.

## [8.3-release2] - 2020-02-11

- zhCN and esMX translation updates.

## [8.3-release1] - 2020-01-17

- Added zones from 8.3.0.

## [8.2-release3] - 2020-01-05

- Fixed a redundant table issue.

## [8.2-release2] - 2020-01-05

- Added WoW Classic area names.

## [8.2-release1] - 2020-01-04

- Re-exported translations from the CurseForge localization database.

## [8.0-release2] - 2018-08-12

- Added taxi node names.

## [8.0-release1] - 2018-08-11

- Added new zones for Battle for Azeroth.
- Removed the "[DEV] Demo Map" entry.

## [7.3-release1] - 2017-08-29

- Translations updated to 7.3.0.24896.

## [7.2-release2] - 2017-03-26

- TOC update for WoW 7.2.

## [7.2-release1] - 2017-03-16

- Translations updated to 7.2.0.23758.

## [7.1-release3] - 2017-03-07

- Translations updated to 7.1.5.23420.

## [7.1-release2] - 2016-10-28

- Added zhCN and itIT translations.
- Added two missing new areas.

## [7.1-release1] - 2016-10-26

- Translations updated to 7.1.0.22900.

## [7.0-release2] - 2016-08-31

- Translations updated to 7.0.3.22522.
- Cleaned up the English locale file.

## [7.0-release1] - 2016-07-19

- Translations updated to 7.0.3.22248.

## [6.2-release5] - 2016-06-30

- Added WMOAreaTable names from 7.0.3.22090.

## [6.2-release4] - 2016-06-30

- Added taxi node names from 7.0.3.22077.

## [6.2-release3] - 2016-06-27

- Translations updated to 7.0.3.22045.

## [6.2-release2] - 2016-06-06

- Added new areas from 7.0.3.21737 and Map 7.0.3.21863 (English only).

## [6.2-release1] - 2015-07-07

- Data updated to 6.2.0.20201.

## [6.1-release1] - 2015-03-01

- TOC update for WoW 6.1.

## [6.0-release2] - 2014-10-18

- Added more taxi node names.

## [6.0-release1] - 2014-10-15

- TOC update for WoW 6.0.

## [5.4-release4] - 2014-10-14

- Split the subzone table into per-language files.

## [5.4-release3] - 2014-10-13

- Temporarily removed itIT and several entries to work around a file-too-long issue.

## [5.4-release2] - 2014-10-13

- Added zone names from 6.0.2.18988 and 6.0.2.19005.

## [5.4-release1] - 2013-09-09

- TOC update for WoW 5.4.0.
- zhCN and zhTW translation updates.

## [5.3-release2] - 2013-08-21

- Added subzones and translations from 5.4.0.17299 (AreaTable). The TOC still targets 5.3.

## [5.3-release1] - 2013-05-21

- Added zones and scenarios from WoW 5.3.

## [5.2-release1] - 2013-03-05

- TOC update for WoW 5.2.0.
- Added WoW 5.2 zones and subzones with translations.

## [5.1-release1] - 2013-02-07

- TOC update for WoW 5.1.0.

## [5.0-release5] - 2012-10-06

- Italian translation update.
- Added Paw'Don Village.

## [5.0-release4] - 2012-09-24

- zhCN and itIT translation updates.

## [5.0-release3] - 2012-09-10

- Added Italian translation.

## [5.0-release2] - 2012-09-10

- Fixed an incorrect library definition.

## [5.0-release1] - 2012-09-09

- Added WoW 5.0.5 translations.
- TOC update for WoW 5.0.

## [4.3-release4] - 2011-12-04

- Merged all language translations into a single file, to fix tables not loading correctly when several addons embed the library.

## [4.3-release3] - 2011-12-01

- Removed a redundant esMX reference.

## [4.3-release2] - 2011-11-30

- Added ptPT, sharing the ptBR data.

## [4.3-release1] - 2011-11-29

- zhCN translation update to 4.3.0.15005.
- TOC update for WoW 4.3.

## [4.3-beta-r116] - 2011-11-14

- Added new zones from WoW 4.3.0.14899 and translations up to 4.3.0.14980.
- Split languages into separate Lua files.
- Combined esES and esMX, which share the same zone names.
- Added ptBR.
- Several deDE fixes.

## [4.2-release4] - 2011-08-11

- zhCN translation update.

## [4.2-release3] - 2011-08-08

- Fixed missing translations.

## [4.2-release2] - 2011-08-08

- zhCN translation update for WoW 4.1.0.14250.

## [4.2-release1] - 2011-06-28

- Added subzone names from WoW 4.2.
- TOC update for WoW 4.2.
- Rebuilt the translation database.

## [4.1-release1] - 2011-04-28

- TOC update for WoW 4.1.

## [4.0.6-release1] - 2011-03-10

- Translation update for WoW 4.0.6 (13623).

## [4.0.3-release5] - 2011-01-23

- deDE fix.

## [4.0.3-release4] - 2011-01-06

- Re-exported translations from the WoWAce localization database.

## [4.0.3-release3] - 2010-12-09

- Translation fixes for ruRU, koKR, deDE (Scarlet Monastery, Wailing Caverns, Marshal's Stand), and zhTW (Westreach Summit, Marshal's Stand, Sylvanaar).
- Re-exported translations from the WoWAce localization database.

## [4.0.3-release2] - 2010-11-28

- Translation update.

## [4.0.3-release1] - 2010-11-25

- deDE fixes.

## [4.0.3-beta1] - 2010-11-21

- Translations for WoW 4.0.3 (enUS, esES, esMX, frFR, koKR first; ruRU and zhTW followed).
- Added The Eye and Temple of Ahn'Qiraj.
- deDE fixes, including missing continent names.

## [4.0-release1] - 2010-10-25

- TOC update for WoW 4.0.
- LibStub is no longer bundled in the source and is added at packaging time.
- Translations come from the WoWAce localization system (`@localization@`).
- Disabled no-lib packaging.

## [3.3-release6] - 2010-10-06

- Fixed a zhCN syntax error.

## [3.3-release5] - 2010-10-06

- deDE and zhCN translation updates.

## [3.3-release4] - 2010-08-06

- Translation updates for The Plagueworks and The Frozen Throne (deDE, esES).

## [3.3-release3] - 2010-07-11

- deDE and ruRU translation updates.
- Translations generated from the WoWAce localization system.

## [3.3-release2] - 2010-07-03

- Added Korean and partial Simplified Chinese translations.

## [3.3-release1] - 2010-06-30

- First release, with enUS, deDE, esES, frFR, ruRU, and zhTW translations.
- Includes subzone names from WMOAreaTable.

[12.1-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/compare/12.1-release3...12.1-release4
[12.1-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/12.1-release3
[12.1-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/12.1-release2
[12.1-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/12.1-release1
[10.0-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/10.0-release3
[10.0-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/10.0-release2
[10.0-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/10.0-release1
[9.2-release5]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.2-release5
[9.2-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.2-release4
[9.2-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.2-release3
[9.2-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.2-release2
[9.2-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.2-release1
[9.1-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.1-release4
[9.1-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.1-release3
[9.1-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.1-release2
[9.1-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.1-release1
[9.0-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/9.0-release1
[8.3-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/8.3-release3
[8.3-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/8.3-release2
[8.3-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/8.3-release1
[8.2-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/8.2-release3
[8.2-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/8.2-release2
[8.2-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/8.2-release1
[8.0-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/8.0-release2
[8.0-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/8.0-release1
[7.3-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/7.3-release1
[7.2-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/7.2-release2
[7.2-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/7.2-release1
[7.1-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/7.1-release3
[7.1-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/7.1-release2
[7.1-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/7.1-release1
[7.0-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/7.0-release2
[7.0-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/7.0-release1
[6.2-release5]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/6.2-release5
[6.2-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/6.2-release4
[6.2-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/6.2-release3
[6.2-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/6.2-release2
[6.2-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/6.2-release1
[6.1-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/6.1-release1
[6.0-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/6.0-release2
[6.0-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/6.0-release1
[5.4-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.4-release4
[5.4-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.4-release3
[5.4-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.4-release2
[5.4-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.4-release1
[5.3-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.3-release2
[5.3-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.3-release1
[5.2-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.2-release1
[5.1-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.1-release1
[5.0-release5]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.0-release5
[5.0-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.0-release4
[5.0-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.0-release3
[5.0-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.0-release2
[5.0-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/5.0-release1
[4.3-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.3-release4
[4.3-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.3-release3
[4.3-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.3-release2
[4.3-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.3-release1
[4.3-beta-r116]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.3-beta-r116
[4.2-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.2-release4
[4.2-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.2-release3
[4.2-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.2-release2
[4.2-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.2-release1
[4.1-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.1-release1
[4.0.6-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.0.6-release1
[4.0.3-release5]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.0.3-release5
[4.0.3-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.0.3-release4
[4.0.3-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.0.3-release3
[4.0.3-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.0.3-release2
[4.0.3-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.0.3-release1
[4.0.3-beta1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.0.3-beta1
[4.0-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/4.0-release1
[3.3-release6]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/3.3-release6
[3.3-release5]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/3.3-release5
[3.3-release4]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/3.3-release4
[3.3-release3]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/3.3-release3
[3.3-release2]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/3.3-release2
[3.3-release1]: https://github.com/arithmandar/LibBabble-SubZone-3.0/tree/3.3-release1
