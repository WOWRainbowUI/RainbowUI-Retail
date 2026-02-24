# DBM - Core

## [12.0.23](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.23) (2026-02-23)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.22...12.0.23) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- toc Update (#1928)  
    * Update koKR  
- Update translations (#1926)  
    * Update translations  
- Fix zone combat scanner still activating and performing combat checks.  
- Update localization.ru.lua (#1927)  
- Update DBM-Midnight\_Mainline.toc (#1924)  
- Update voice pack sounds  
- update voicepack sounds  
- Add "stun on you" and "traps incoming"  
- Prep objects for supporting warning color in a future patch rather than having to go back and do it later.  
    make luaLS more robust in validating color types as well so illiegal values can't be passed anymore  
- fix typo  
- restore player regen and unit health combat checks since we need them for world bosses and some non M+ dungeon bosses where they aren't secret. Restored checks should use strict secret checks to return end when not usable.  
    restore player combat/low health alerts in outdoor world on retail.  
    restore several unit identity functions (also needed for world bosses) when unitidentity is not secret  
- Update localization.es.lua (#1925)  
- Move boss mod options out of core and into own file for easier locating and readability  
- Fix bug that caused disabled sounds to still play  
- Move retail encounter events handler to own file, then only load that file on retail. small micro optimize for classic which doesn't need functions to even be loaded but more importantly just makes them easier to read/locate.  
- Add movetobeam  
- Automatically handle DisableSpecialWarningSounds when tlSoundsEvents table is created, this way it doesn't have to exist in every sub module.  
- Prep keystones for Midnight S1  
- toc cleanup  
    Added support for midnight world bosses (only one of them has actual warnings/timers though since blizz forgot about other 3)  
- GetViewType returns 0 if called too early on login, so to make sure we can restore users timeline setting on re-enable, we must call it on a delay  
- another spot that alpha needs to be reset to 0 to keep timeline invisible  
- Update localization.ru.lua (#1923)  
    Minor changes  
- bump alpha  
