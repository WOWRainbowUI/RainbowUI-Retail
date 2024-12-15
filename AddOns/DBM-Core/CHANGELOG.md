# DBM - Core

## [11.0.38](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.38) (2024-12-14)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.37...11.0.38) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- bump core version  
- Update localization.fr.lua (#1436)  
- Update localization.br.lua (#1437)  
- Update localization.es.lua (#1435)  
- Timers: Fix timers with a negative offset, commonly used at combat start (#1438)  
- work around annoying core bug where starting a timer of 0 uses self.timer instead. But that annoying bug has to stay since over a decade worth of mods has assumed that to be valid  
- auto set "keep" on variance timers in debugmode  
- bump alpha  
