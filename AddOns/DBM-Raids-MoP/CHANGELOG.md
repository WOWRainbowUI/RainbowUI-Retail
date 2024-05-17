# <DBM Mod> Scenario (MoP)

## [r168](https://github.com/DeadlyBossMods/DBM-MoP/tree/r168) (2024-05-16)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-MoP/compare/r167...r168) [Previous Releases](https://github.com/DeadlyBossMods/DBM-MoP/releases)

- Add .luarc.json and migrate globals check (#44)  
- Update localization.ru.lua (#45)  
- Update all mist of pandaria scenarios to support:  
     - Voice Packs  
     - Color by sound  
     - Smarter modern filters for interrupts  
     - Better antispam/culling of redundancies  
     - Inline Icons in timers  
     - More efficient combat log args tables  
- Bump min core revision because sadly a new dbm core update has to go out to prevent scenario bugs here too that would have been introduced by mapid checking running scenario start too soon after zone changes.  
- Add AutoGossip for Lei Shen Displacement Pad  
- Add AutoGossip for Norushen  
