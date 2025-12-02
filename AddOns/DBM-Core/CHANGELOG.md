# DBM - Core

## [12.0.7](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.7) (2025-12-01)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.6...12.0.7) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Pre new DBM Core tag and marking it mandatory for following:  
     - Fixes for wrath Titan compatability  
     - Fixes for Midnight beta compatability  
- Update DBM-Raids-Midnight\_Mainline.toc (#1814)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- update difficulties  
     - Titanforged raids will now be catagorized as heroic 25 man instead of normal 10 man  
     - Titanforged raids will no longer be flagged as trivial encounters (ie it won't treat em as level 60 raids to level 80 players and filter alerts anymore)  
     - Lorewalking dungeons and raids will now get treated differently and will store stats separately from regular dungeons and raids.  
- Update localization.tw.lua (#1813)  
- Update koKR (#1816)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Update localization.ru.lua (#1815)  
- Mini dragon patch 1 (#1818)  
- cleanup unused  
- Preliminary support for hiding bars above a certain value (essential for current way blizzard sends timeline in midnight beta).  
    This option is disabled by default on classic and retail but on by default in midnight beta for raid testing. Feature can both be toggled and time threshold can be set anywhere between 1 minute and 10 minutes  
- fully disable DBM offline  
- Add localization for a future setting  
- add midnight timer testing tool  
- cleanup unused  
- remove 15 bar cap, it breaks bar tracking in midnight with way blizzard queues timers. an actual system for hiding bars beyond x time or x count will be added in near future but this should fix missing bars in midnight testing  
- tbc ptr is broken and returning WOW\_PROJECT\_CLASSIC instead of WOW\_PROJECT\_BURNING\_CRUSADE\_CLASSIC so we have to work around bug for now  
- what a nitpick luacheck. why are you even still around?  
- restrip some things out since they were edit mode only features  
- Fix lua error sending pull timer in midnight  
- wipe respawn data form midnight mods  
- blizzard includes respawn timer in timeline so no need to start our own  
- bump alpha  
