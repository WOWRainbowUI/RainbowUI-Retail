# DBM - Core

## [11.0.15](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.15) (2024-09-21)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.14...11.0.15) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- bump version  
- Fix significant bugs in sikran that made almost all the timers to be non functional after first sweep due to failure to retest the mod with test tools after it was refactored to no longer reset counts. All the timer conditionals were coded relying on counts resetting after each sweep, but since they weren't anymore, it resulted in most timers to stop being functional after first sweep. This is quite frankly, an unacceptable failure in my test processes and peoples time and progress shouldn't suffer as a result of it. As such, anyone that requests a refund for last months patreon pledge, will be given one out of my own pocket  
- Fix mask trigger not working correctly on kyveza mythic  
    tweak option defaults for mythic Kyveza  
- Update localization.fr.lua (#1256)  
- Update commonlocal.es.lua (#1257)  
- Update commonlocal.fr.lua (#1258)  
- Update commonlocal.br.lua (#1259)  
- Update localization.es.lua (#1255)  
- Add ulgrax berserk timer  
- bump alpha  
