# DBM - Core

## [12.1.24](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.24) (2026-11-22)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.23...12.1.24) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- restore whisper privacy options on midnight and forever  
- Just send "" instead of player name in syncs, keep arg order as is for now.  
- Fixes for todays forever hotfix that removes realm identity from realm api and returns "" or 0 instead  
- prevent setting spec incorrectly due to setting it too early.  
    make sure spec correction runs on all game versions after 10 seconds  
- update CI  
- Optimize memory by using toc directives for localization loading, preventing unneeded localizations from existing in memory going forward (even if they do return on first linie, they still loaded. well not anymore!)  
- Fix errors caused by last  
- Add toggle to disable role check on classic versions of game (not toggle allowed on cata or later because spec detection is precise and DBM and other addons rely on accurate roles being set for deterministic icon marking and other features)  
    In forever, it's toggled off by default for druids since they are extremely problematic in accurate identification  
    In additoin, if a player manually sets their own role, DBM will no longer touch it for classic versions of game since players is likely more accurate. modern versions of game give players no agency though because DBMs is always accurate.  
    Closes https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2278  
- improve debug for generic trash  
- bump alpha  
