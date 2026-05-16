# DBM - Core

## [12.0.48](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.48) (2026-05-14)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.47...12.0.48) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- last 12.0.7 fix, good to go for a tag  
- fix error with font dropdown in 12.0.7  
- Account for fact user can change the cvar value for highlight duration and adjust countdowns to support highlight durations of 10 (as well as original 5). but if highlight duration is set to anything other than 5 or 10, countdowns won't be registered (when using blizz api, hardcoded modules will always have countdown freedom).  
- Fix and finish dynamic color changing on highlight for 12.0.7  
- Finish implimenting boss % on wipe, including support for mods defining specific main bossID to target, or boss modules that specify whatever unit has highest health.  
- Fixes  
- 12.0.7 api updates  
- Update rotmire with new Ids added in latest PTR build  
- simplify logic  
- Fix bug and cleanup guild whisper syncs to not create a pointless extra table  
- fix another debug spam  
- bump alpha  
