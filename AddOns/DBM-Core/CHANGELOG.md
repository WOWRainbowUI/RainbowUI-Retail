# DBM - Core

## [11.1.9](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.1.9) (2025-03-12)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.1.8...11.1.9) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- Vexie is still a vexing boss on heroic and mythuc. restore stage 1 fuckery timers and in fact extend fuckery even more  
- Gallywix  
     - Fixed a bug where false messages about missing timers were displayed. the checks are more robust now and should only report actual missing timers  
     - Fixed a bug where Ecocheck subcount wasn't a recoverable variable on mid fight reload  
     - Fixed a bug that caused canisters timers to break mid fight due to typo in resetting of variable name on phase change  
- update vexie normal test to new golden data that has march 11th hotfixes  
- Blizzard appears to have hotfixed vexie to fix issue where her cds were longer in initial stage 1. Fixes and closes https://github.com/DeadlyBossMods/DeadlyBossMods/issues/1577  
- turn this infoframe off by default  
- Fix redundant/bad taunt warnings on gallywix  
    Fix iniital timers after inventions being too long by 2 sec on lockenstock  
- Hard disable timers in story mode. it's literally impossible to wipe or die in story mode and you can ignore every single mechanic and go afk and still win, so wasting any time on even supporting story mode timers is pointless.  
- bump alpha  
    Fix a bug where stix could start phase change timers on wipe if wipe occured mid overdrive.  
