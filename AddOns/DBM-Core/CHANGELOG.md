# DBM - Core

## [12.1.26](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.26) (2026-11-27)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.25...12.1.26) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new update. make it mandatory since it fixes some errors on midnight and forever with AFK health check that could spam non stop lua errors if feature is enabled (it's off by default so it took ages for someone to report this). None the less, it still exposed a major compat issue with restricted client that required mandatory patching  
- Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2289  
- Some ulatek normal fixes. closes https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2275  
- Update localization.ru.lua (#2298)  
- Add support for continous next song music playing for event sounds music modes. (#2302)  
    Addes feature requested by https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2287 .  
- Restore sharing timers when they don't contain secret text. closes https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2301  
-  - Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2299 with stricter checks to prevent that code running when it shouldn't  
     - While at it, loosen restrictions to allow that code to run when it can, restoring afk alerts feature on forever and retail in places it's allowed like questing so it once again acts as death protection it's meant ot be.  
- Core: Add quest turn-in object (#2300)  
    Co-authored-by: Claude Opus 5.5 <noreply@anthropic.com>  
- Update koKR (#2294)  
    * Add koKR locale  
- Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2297 by not loading lib on mainline clients, taking us out of the blame in backtraces for future errors  
- bump alpha  
