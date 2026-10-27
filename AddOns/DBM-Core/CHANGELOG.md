# DBM - Core

## [12.1.18](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.18) (2026-10-26)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.17...12.1.18) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Prep new tag  
- Strip Hudmap out of DBM-Core  
- Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2268 which occurs if user doesn't actually have chosen langauge default voice pack installed  
- always play sound when routing fails  
- Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2266  
- Optimizations and bugfixes (#2265)  
    * Optimizations and bugfixes  
- Update koKR (#2262)  
    * Update koKR  
- Translate consumes (#2261)  
    * Update translations  
- Fix isTanking on Forever  
- Update tocs for 12.1.7 ptr  
- Re-enable libspec in forever, and switch own specRole table to same Ids for lookup compatability  
- Create an elaborate zone based end combat rule to handle niche situations of leaving zone while a boss is engaged, causing endcombat to not fire if you immediately jump into another zone that keeps combat conditions true (such as a delve or M+)  
- delay taunt by another 1.5 sec to avoid stack refreshes for very fast reacting tanks  
- bump alpha  
