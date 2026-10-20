# DBM - Core

## [12.1.16](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.16) (2026-10-19)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.15...12.1.16) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Update RU locales (#2260)  
    * Update localization.ru.lua  
    * Update localization.ru.lua  
- prep new tag  
- Refactor generic trash alerts to be boss opt in rather than hardcoded with boss opt outs of hardcode. expand opt ins to world event bosses  
- Add a full consumables check for retail (with classic support coming later) (#2259)  
    * Add a full consumables check for retail (with classic support pending more research)  
    * refactor raid checks into a single frame with multiple tabs, for an easier to navigate experience for raid leaders to change between  
- allow updateicon to work even on non started bars  
- handle libdurability and liblatency only sending first name for "player"  
- already know luacheck isn't gonna like this, so fix this too  
- have retail use legacy demo mode, since everything is hardcoded  
- bump alpha  
