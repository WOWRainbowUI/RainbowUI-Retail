# Details! Damage Meter

## [Details.20260727.15252.172](https://github.com/Tercioo/Details-Damage-Meter/tree/Details.20260727.15252.172) (2026-07-27)
[Full Changelog](https://github.com/Tercioo/Details-Damage-Meter/compare/Details.20260721.15251.172...Details.20260727.15252.172) 

- Update tocs and bump version  
- Merge pull request #1112 from korsal/fix/arena-summary-nil-combatdata  
    Fix arena summary crash when OnArenaStart never ran for the match  
- Fix arena summary crash when OnArenaStart never ran  
    ArenaSummary.OnArenaEnd() indexes arenaData.combatData (setting  
    .teamInfos and iterating .groupMembers), but combatData is only  
    created by OnArenaStart(). The module default is a bare  
    arenaData = {}, so if OnArenaStart never ran for the current match  
    - most commonly a /reload or enabling the addon while already  
    inside the arena - OnArenaEnd errors with:  
      attempt to perform indexed assignment on field 'combatData'  
      (a nil value)  
    Bail out early when combatData is nil: there is nothing to  
    summarize without it.  
