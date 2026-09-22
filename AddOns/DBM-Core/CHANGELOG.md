# DBM - Core

## [12.1.10](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.10) (2026-09-19)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.9...12.1.10) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Update localization.it.lua (#2219)  
- Fix RAID\_DOWN\_NR message formatting in CN localization (#2222)  
- Update koKR (#2220)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- prep new tag  
- Some UI options tweaks for forever  
-  - Change client checks to have one true source, so in future they don't need to be replaced in 100s of files, just 1. GameVersions is the source of truth and every other file should access that to get game version rather than having everything performing it's own game version check. This significantly reduces maintenance in future when we need to update or fix game versions  
     - Fixed a few more cases of restriction checks for forever client  
- toc refactors for rest of retail modules  
- refactor tocs to deal with forever better using modern toc features  
- Fix some ultaek stuff  
- more forever fixes  
- Few forever fixes, revert toc change that's not live yet  
- switch from using mainline to standard, since forever is also mainline  
- remove unneeded checks  
- Forever prep, 38 files edited  
- update difficulties with forever data that's available so far  
- Update localization.tw.lua (#2217)  
- Revert "suspend distribution to wago"  
- handle two gore bars starting at once better  
- with kithix confirmed flex mythic, move it to lairs module. lairs will be the module that all flex one boss raids reside  
- small tweak  
- Push Kithix drycode  
- Improve gravebound audio to be more concise on applied, and added audio when removed as well  
- Reduce idle cost for optional DBM-Core features (#2216)  
    * Reduce load-time and hidden-state work across several optional DBM-Core presentation features  
- Fix luaLS  
- prevent coiled altar wipe errata from causing hardcode routing to be confused and disable next pull. this is another boss that likes to resend all timers when wiping.  
- Fix?  
- update test package uploader again  
- Try to fix test packaging  
- support auto generating test zips on PRs  
- switch plague froth to an aura sound, blizzard isn't sending ENCOUNTER\_WARNING for it  
- try to fix sentinels race conditions evidenced in week3 logs  
- Try to fix some more explorers race conditions and failure points.  
- Update Translation (#2215)  
- add a missed rename  
- bump alpha  
