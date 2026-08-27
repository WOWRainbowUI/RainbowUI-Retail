# DBM - Core

## [12.1.6](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.6) (2026-08-26)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.5...12.1.6) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- another audio tweak  
- Make it possible to have custom audio based on difficulty. Resolves the issue with sentinel auras giving normal/LFR false warnings about dropping pools  
- Work around blizzard bug on sentinels were some spells never fire alerts because completed timers falsely terminate with state 3  
- Add missing GTFO to Nekzal  
- improve several tank alerts to be threat based now that we have 2 weeks of evidence which boss unit id is which  
- fix another tank only alert going off for everyone on explorers  
- fix lost explorers routing issue  
- fix bad spell id on scissor guy  
- just treaing state 3 as finished in stage 3 still left some issues, particularly with waves. so lets pre schedule initially but use state 3 as backup. at very least this should resolve seeing the first waves alert 5 seconds late (and at same time as 2nd wave)  
- and story altar too  
- story mode fixes for ulatek  
- Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2193  
- fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2197  
- function tweak for vashnik  
- Since this blizz bug is common now, and can seemly happen on any fight, lets just create utility functions for it.  
- fixes to coiled altar with fixation and bloom bomb  
    bomb now correctly intercepts ENCOUNER\_WARNING, meanwhile fixation now uses aura since intercept can't be deterministic due to fixation being a secondary affect controled by damage  
- Fix two batchable timers  
- start unending tides berserk timer  
- filter blizzard garbage, tighten other checks  
- Further improve debug log with GUID/CID capturing  
- add logging of warning severity as another tool for disambiguating warning text  
- adjust order of operations to MAYBE address https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2193 which only affects certain users  
- initial ulatek normal routing, but he died so fast didn't get stage 3, rip  
- Push default renames to most bosses. Ulatek still WIP  
- work around blizzard bug where alluring bubble always returns state 3 (and well after cast actually happens)  
    fix my won bug that caused bar colors not to register to timeline when using both timeline and bars  
- Bump alpha  
