# DBM - Core

## [11.0.32](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.32) (2024-11-23)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.31...11.0.32) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Tests: Update instance data  
- Tests: Fail gracefully when DBM-Test is missing or disabled (#1378)  
- Only use CHALLENGE\_MODE\_* if it exists in the current version (#1377)  
- Core: Correctly handle multiple direct event handlers  
- Core: Add new type of event registration  
    Registers a single event (with spell ID filters) in combat and connects it directly to a function or method.  
    This is experimental and not meant to be used directly in mods, but I have some ideas.  
- Maybe fix unit power  
- bump version for a new classic tag  
- Update localization.es.lua (#1374)  
- Update localization.br.lua (#1373)  
- Fix ZoneCombatScanner for classic (#1375)  
- Update localization.br.lua (#1372)  
    Co-authored-by: Zidras <10605951+Zidras@users.noreply.github.com>  
- Update localization.es.lua (#1370)  
- Update localization.fr.lua (#1371)  
- tweak last to get rid of two locals  
- Run all syncs through wrappers to make it easier to maintain and future proof by now only having one place to update comms in future.  
    This also makes it easier to impliment ChatThrottleLib once a few more things are worked out (like how their priority stuff works because a lot of boss mod syncs need to be sent at highest priority or they're useless)  
- micro adjust one initial timer  
- additional alerts and initial nameplate timers on nerubar trash  
- Update localization.es.lua (#1369)  
- bump alpha  
