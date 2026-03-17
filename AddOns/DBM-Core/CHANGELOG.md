# DBM - Core

## [12.0.31](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.31) (2026-03-16)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.30...12.0.31) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag. marking mandatory update as without it, all the new classic updates will fail to load due to new api addition. and without it, users would not have complete raid mods for next weeks raids.  
- Fix and close https://github.com/DeadlyBossMods/DBM-MoP/issues/75  
- tweak debug  
- Update localization.ru.lua (#1970)  
- Crown of the cosmos preliminary module  
- Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/1971  
- Update localization.tw.lua (#1969)  
    * Update localization.tw.lua  
    * Update localization for keystone names in Chinese  
    ---------  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
-  - Improve private aura option texts to clarify a 3rd type, lingering effects  
     - Update built in voice pack sounds  
     - Added Lightblinded vanguard module  
- Reduces DBM public surface to functions that are actually API-facing  
- fix bad arg  
- add additional debuglog event for hardcoded timer start for easy log entry comparing between events and hardcoded counterpart  
- vastly improve debugging tools for hardcoded modding  
- Add chimaerus mod  
- fix yell objects being omitted from filter  
- prune deprecated options  
    updated other options to enable quickly ignoring them at creation level for legacy mods on midnight  
- InfoFrame: Boss HP 0% -> DEAD  
- Add Vaelgor and Ezzorak mod  
- luaLS just can't accurately typecast in this situatino so remove strict checks entirely  
- luaLS can be fickle about dummest things  
- Fix object error  
    API protections against overwatch countdowns that only have 3 seconds  
- Push salad bar 2.0  
- bump alpha  
