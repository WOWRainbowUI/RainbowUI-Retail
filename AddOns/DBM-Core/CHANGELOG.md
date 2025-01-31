# DBM - Core

## [11.1.2](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.1.2) (2025-01-31)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.1.1...11.1.2) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Update koKR (#1513)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- prep tag. More stuff to do from mythic testing, but this tag is mostly for vanilla SoD  
- Rik reverb Update  
    rework icon markin to be much smarter and reserve marks based on active amplifiers.  
    Updated timers for Mythic test 2  
    Make timer counts not reset to match BW behavior for weak aura synergy  
- Add droptorch definition  
- Forgot to add these IDs  
- Missed this  
- Rework and finish off rik reverb mod wit normal heroic and mythic timers  
- Update localization.ru.lua (#1512)  
- Update koKR strings in tocs (#1508)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Update localization.fr.lua (#1506)  
- Update localization.br.lua (#1507)  
- Update localization.es.lua (#1505)  
- Tests: Slightly better metadata guessing for retail  
- Tests/GUI: Add test export feature  
- Tests/GUI: Small layout fixes  
- Tests/CLI: Move anon validation failure to a callback  
- Bugfixes for test mode  
- Tests: Remove warning ignore feature (#1510)  
- CI: Improve commit message in test results repo (#1509)  
- Parital mythic updates for Mugzee  
- Mythic updates for One armed bandit  
- Mythic timersf for Lockenstock.  
- Only one difference on mythic :D  
- Refactor timer handling on lockenstock to make it easier to maintain since heroic and normal timers differ. Plus now it'll be easier to plug mythic timers in  
    In addition. announce berserk and show berserk timer for gigadeath  
- Improve meltdown tank warnings and timer for stix  
- Improve normal mode timers for one armed bandit  
- Tests: Make order between OnUpdate() calls to frames deterministic (#1504)  
- Update localization.tw.lua (#1499)  
- Update localization.br.lua (#1500)  
- Update localization.es.lua (#1501)  
- Update localization.fr.lua (#1502)  
- Update koKR (#1503)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Prelkiminary cauldron of carnage updates from heroic testing  
- popuplate mythic table with heroic timers for now  
- update vexie from normal and heroic testing  
- Update localization.ru.lua (#1498)  
- add another localization  
- Update localization.ru.lua (#1497)  
- delete these for now. sorry about that. I did say they weren't final though :D  
- Cleanup variance option texts  
- restore sending to wago  
- Update localization.es.lua (#1493)  
- Update localization.fr.lua (#1494)  
- Update localization.br.lua (#1495)  
- Add RU locale for Title in .toc file (#1496)  
- Preliminary phase change and timer support for mugzee. some timers not complete due to boss just being extra hard for most pugs. but most should be covered now  
- Fix some variances  
- Tests: Trace and report early timer refresh warnings (#1492)  
- Add /dbm test freeze/resume/toggle-freeze  
- Fix error  
- Push full DBM-Offline results on any push to master (#1490)  
- Push one armed bandit update  
- Fix nil spellID due to blizzard hotfixing 472039 out of existance  
- Fix two option keys that caused duplicate entries in GUI  
- fix some bugs found by test mode in stix and lockenstock  
- CI: Run all tests for all repos on core change  
- Fix some failures caused by forgetting to change timer object  
- Tests: Apply SPELL\_HEAL\_ABSORBED filtering to NerubarPalace tests  
- Tests: More creature ID filters  
- Tests: Avoid NaN in role guesser  
- Tests: Support more extra args and strip trailing nils in combat log  
- Tests: Strip SPELL\_HEAL\_ABSORBED like SPELL\_HEAL  
- Tests: Add more Undermine logs  
- Push finished Lockenstock mod  
- suspend wago packaging for now  
