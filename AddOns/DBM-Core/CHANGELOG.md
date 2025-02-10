# DBM - Core

## [11.1.4](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.1.4) (2025-02-08)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.1.3...11.1.4) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Prep new tag  
- Core: Align SoD Naxx difficulties with warcraftlogs (#1526)  
- Fix year in timestamp (#1530)  
- Update localization.br.lua  
- Update localization.br.lua  
- Update localization.br.lua  
- Update localization.br.lua  
- Update localization.es.lua  
- Update localization.es.lua  
- Update localization.fr.lua  
- Update localization.fr.lua  
- Update localization.fr.lua  
- Variance: remove obsolete code  
    This has no place being in Start method. Bar attributes on creation are to be managed in DBT:CreateBar  
- Variance: fix var to non-var getting kept on debug  
    Fix related to this https://github.com/DeadlyBossMods/DeadlyBossMods/blob/master/DBM-Core/modules/objects/Timer.lua#L225-L227  
- Variance: code cleanup (#1525)  
- Tests: Get player names from PLAYER\_INFO as well and explicitly filter to CLEU events for other sources  
- Tests: Get server name from CHAT\_MSG\_RAID\_BOSS\_WHISPER\_SYNC (which always has it)  
- Tests: Set GUID for raid warning messages coming from yourself correctly  
- play voice pack count sound when changing voice pack in dropdown menu  
- bump alpha  
