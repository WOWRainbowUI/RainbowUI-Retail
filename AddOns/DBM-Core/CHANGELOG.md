# DBM - Core

## [11.1.8](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.1.8) (2025-03-11)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.1.7...11.1.8) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- Fix some test category bugs  
- Fix up test defines  
- scrap all PTR data for Undermine and replace with live data  
- Gallywix Update:  
     - Added more normal and heroic timer data to stage 3  
     - Adde Ego Check timer for heroic gallywix  
     - Fixed a bug where variance timers could cause lua error due to nil check performing numeric action on a string  
     - Added prints if useres encounter pulls that exceed built in timer data  
- Stix update:  
     - Disable icon setting on balls by default  
     - Enable icon setting on scrapmasters by default  
     - Scrapped dumpster dive timer, it's just not reliable  
- Fix a bug that caused timers to break in stage 1 of gallywix after a wipe  
-  fix to last  
- Update localization.fr.lua (#1572)  
- Update localization.br.lua (#1573)  
    * Update localization.br.lua  
    * Update localization.br.lua  
    * Update localization.br.lua  
- Update localization.es.lua (#1571)  
    * Update localization.es.lua  
    * Update localization.es.lua  
    * Update localization.es.lua  
- Compat updates to gallywix icon marking  
-  CI: Split DBM-Offline into two parts to fix permission issues  
- Core: Fix isName in DBM:IsTanking() (#1575)  
- Tweak difficulties to try and fix some delve difficulty odness that might occur  
- update most mythic rik timers  
- fix world boss loading for gobfather  
- Update commonlocal.fr.lua (#1559)  
    * Update commonlocal.fr.lua  
    * Update commonlocal.fr.lua  
- Update commonlocal.br.lua (#1560)  
    * Update commonlocal.br.lua  
    * Update commonlocal.br.lua  
- Update commonlocal.es.lua (#1558)  
    * Update commonlocal.es.lua  
    * Update commonlocal.es.lua  
- Reenable luals (#1568)  
    * LuaLS: Ignore new color picker frame global  
    * Revert "temporarly remove luaLS workflow for now. will be restored when it can be fixed, but right now I don't want to be spammed emails for failed builds for next two weeks."  
- bump alpha  
