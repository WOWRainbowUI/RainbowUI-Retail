# DBM - Dungeons, Delves, & Events

## [r188](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r188) (2025-02-08)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r187...r188) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- CI: Move globals check from LuaCheck to LuaLS  
- KarazhanCrypts: Remove dead code  
- KarazhanCrypts/DarkRider: Warn more aggressively about mirror images  
- KarazhanCrypts/Unkomon: Add interrupt warning for Shadow Bolt Volley  
    Bad pugs have shown me that this warning is good to have  
- KarazhanCrypts/DarkRider: Add option for icon setting on Illusion target  
- KarazhanCrypts/Kharon: Respect global icon disable option  
- Update koKR (#404)  
- add gossip (#401)  
- CI: Remove continue-on-error flag for DBM-Offline now that filenames are fixed  
    Besides the test execution that actually also serves as a smoke test because even without test data it still tries to load all mods  
- Fix case mismatches between tocs and files  
    DBM-Offline cares about this when running in GitHub actions  
