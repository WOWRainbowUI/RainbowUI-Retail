# DBM - Core

## [11.0.33](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.33) (2024-11-27)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.32...11.0.33) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- cleanup and bump version  
- Revert "just delete LuaLS check, it works locally that's what counts"  
- Fix a bug where timers started with a value of 0 for some reason just inherited self.timer instead which underminded many mods like rashanan which need to use table based timer starting. This fixes several bogus timers appearing on boss fights for phases or platforms that should have no timer.  
    Added GTFO for sikran puddles, since to be honest they can be hard to see sometimes.  
- just delete LuaLS check, it works locally that's what counts  
- disable absolutely annoying nitpicks  
- Fix BW syncs not working through chatthrottlelib  
- fix ignores?  
- Update localization.fr.lua (#1391)  
- Also use ChatThrottleLib for bnet sync  
- fix CTL errors  
- update ignores  
- try the decade out of date url instead  
- Switch to ChatThrottleLib for sending all syncs in DBM  
- Remove echowigs option, since maybe that's what's confusing users. that option was mostly added as a favor for RWF but that's long over. DBM should just focus on public BW (default) and color blind friendly options for the raids not using using BW  
- Update localization.es.lua (#1389)  
- Update localization.ru.lua (#1388)  
- clarify option text  
- Update localization.es.lua (#1385)  
- Update localization.fr.lua (#1387)  
- Update localization.br.lua (#1386)  
- Update localization.tw.lua (#1384)  
- Update koKR (#1383)  
- Update localization.ru.lua (#1382)  
- Also don't activate unstable potion if it's already activated  
- Fix a bug causing Globald isable for gossip not to globally disable due to bossmodprototype having a different definition for self than core calls  
- Merge branch 'master' of https://github.com/DeadlyBossMods/DBM-Retail  
- Fix lua errors on br and fr localizations  
- Core: Fix spell ID filtering for direct events on CLEU events without arg tables  
- Tests: Add support for persisting playground mode logs  
- bump alpha and fix a bug where BW syncs could show errors on trial accounts (but to be fair, that bug existed prior to refactor too  
