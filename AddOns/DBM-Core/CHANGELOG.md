# DBM - Core

## [11.1.6](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.1.6) (2025-03-04)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.1.5...11.1.6) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep day 1 update  
- fine tune rik sway to be every 4 stacks instead of every 5, and swaps starting at 8 instead of 10  
- tweak two phase 2 timers on mugzee non mythic based on test results  
- Stix Update:  
     - Added throttle to dumpster dive and re-enabled by default  
     - Correctly support normal and LFR having different fight pacing from heroic/mythic (although need to confirm that's still true on live)  
- Fix another timer lookup bug causing wrong timer to start on mythic lockenstock  
- SprocketMonger:  
     - Fixed a bug that caused mythic timer not to start due to mismatching spellID (bad copy paste, right id was in table).  
     - Also warn for incoming shifts on mythic  
     - Fixed bug where gigadeath timer didn't start with backup stage trigger  
- Update koKR (#1550)  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Revert  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR stings in tocs  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    ---------  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Update RU commonlocal (#1549)  
    * Update commonlocal.ru.lua  
    * Update localization.ru.lua  
    * Update commonlocal.ru.lua  
- Rik Reverb Update:  
     - Fixed bug causing drop timer to start an extra in intermission  
     - Added missing cast timer for drop as well  
     - Fixed bad spell key specifically in heroic timer table that resulted in Lua errors and missing timers  
     - Fixed faulty zap splitting targets into two or three warnings on non mythic difficulty. On mythic, it still splits only because boss casts it multimple times.  
     - Fixed non tanks getting tracked for Tinnitus stacks if they are standing in wrong place (ie in front of boss)  
     - Fixed phase transition timer being 4 seconds too long in all difficulties  
- Cauldron of Carnage Fixes:  
     - Fixed initial roar cannon timer being too long on normal  
     - Fixed timer restarts firing twice on phase change  
     - Fix voltiac image timer having redundant out of date starts  
- rework vexie after running couple dozen tests and finding table approach not as clean. variance timers better approach for now.  
- Add timer callback parity for buds  
- bump alpha  
