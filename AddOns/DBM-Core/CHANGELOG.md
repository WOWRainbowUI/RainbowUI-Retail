# DBM - Core

## [11.0.31](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.31) (2024-11-20)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.29...11.0.31) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag to fix regression in last update  
- don't send it on cast timers either  
- don't send "always keep" on hybrid timers, since that functionality would break on pretty much any count timer  
- Update localization.fr.lua (#1368)  
- bump alpha  
- pre new tag  
- Update localization.tw.lua (#1365)  
- Update localization.es.lua (#1366)  
- Update localization.fr.lua (#1367)  
- bump vanilla toc  
- Update koKR (#1364)  
- Update localization.ru.lua (#1363)  
- Missed one spot for keep option  
- Add option (on by default) to always keep nameplate cd timer icons until ability is recast  
- Revert "Add DBM-Test to required dependancies to avoid errors"  
- Add DBM-Test to required dependancies to avoid errors  
- Voice pack tweaks  
- renames  
- Nerubar Palace Trash Update:  
     - Added frontal alert and nameplate timer for poison breath  
     - Added nameplate timer for Gossemere Weave frontal  
     - Added nameplate timer for stag flip tank throw  
     - Added nameplate timer for dark mending interrupt  
     - Added nameplate timer for Deafening Roar aoe/caster interrupt  
     - Added nameplate timer for Black Cleave frontal  
    Some abilities also support initial timers but some don't cause other tank kept pulling before I had custom logger up to grab initials. I'll try to get more of those next week.  
- prep zone combat scanner for raid trash abilities with following:  
    1. Will now auto unregister zone combat scanner when engaging a raid boss and reregister on combat ending with raid boss (we won't be fighting trash during raid bosses)  
    2. Nerubar palace trash module will now enable the scanner to start collecting debug.  
- Bump alpha  
    Update M+ Affixes module with season 2 Ids  
