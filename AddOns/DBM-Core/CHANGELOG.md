# DBM - Core

## [11.0.39](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.39) (2024-12-29)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.38...11.0.39) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- restore bar.hasVariance for timer debug, cause it should use thet type of LAST timer and not new timer.  
- Update commonlocal.ru.lua (#1463)  
- Update commonlocal.fr.lua (#1462)  
- Update commonlocal.es.lua (#1461)  
- Update commonlocal.br.lua (#1460)  
- Update koKR (#1458)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Update commonlocal.tw.lua (#1459)  
- Targets: Log mod ID instead of useless "table: 0x..." message  
- Tests: Expose OnUpdate() for the test runner  
- Tests: Support mocking nil globals  
- Tests: Pass spell IDs as numbers to SpellInfo  
    Surprisingly the API is happy to accept it as a string, but it does trigger a DBM debug warning  
- Core: mod.addon can be nil, e.g., for dummy mods  
- Add common Local for knockup  
- fix a regression in ore that broke AI timers on combat start caused by changing delay from 0 to 0.000001  
- Update voice pack sonds  
- small fix  
- Tests: Add basic support for correctly tagging mind controlled units  
- Tests: Filter some Naxx hardmode related events that are extremely spammy  
- Tests: Pulling instance data from Wago now works for era PTR  
- Difficulties: Support SoD Naxxramas hardmode  
- use real timers on orta  
- Update koKR (#1453)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Fix a bug where bar was inappropriately updated sub 10 seconds, when it was already large beforehand in a variance timer  
- remove redundant code from fix. :SetVariance already had that existing code, it just wasn't working on recycled bars (which I also fixed in last push)  
- DBT Updates:  
     - Fix a bug where keep value remained true whena variance timer becomes a non variance timer after the fact  
     - Fix a bug where a restarted variance timer that becomes non variance, would still show variance textures  
- attempt to fix variance timers getting stuck in variance when started with whole number.  
- Update localization.ru.lua (#1452)  
- add the 3 new delve IDs  
- Also add karazhan to vanilla sod difficulties  
- remove 11.0.5 and Add 11.1  
    template undermine raid modules  
    templated the Gobfather world boss  
- Add 11.1 dungeon to affixes module  
    Add 11.1 dungeon and raid to auto logging and trivial checks tables  
    Add 11.1 Raid category ID and load Id to war within raids module  
- Add uncompressed log stripping for releases  
    Works well in DBM-Vanilla; TODO is to add compressed versions and the necessary tags to all old test data  
- SoD: Update list of install checking zones  
- Tests: Add IDs for new SoD raid/dungeons  
- GUI: Handle dungeon names that don't yet exist slightly more gracefully  
- Tests: Mock more return values for UnitAura  
- Tests: Remove real player name and guid from custom mod traces  
- Core: Unregister short term events if Disable() is called  
- Tests: Add mod:TestTrace() for mods to inject custom trace messages into test output  
    Useful to validate custom logic e.g., for info frames  
- Tests: Anonymize names in personalized CHAT\_MSG\_BG events  
    For some reason the event when you enter the Twin Emps room for the first time in AQ40 is a CHAT\_MSG\_BG with a player name as a target  
- Tests: Fix Lua error in report generation on unknown events  
    (This only happens due to other bugs, but still good to be defensive here)  
- Tests: Fix method in Timer:Schedule()  
- Tests: Handle PLAYER\_INFO in different locations than the start of the log  
- Tests: Ignore CHAT\_MSG\_RAID\_WARNING (why is it even logged?)  
- Tests: Fix nil error  
- Tests: Fix off-by-one error in logs that don't contain any boss fights  
- Tests: Add optional field to reference other mods that may be active during the test  
    Useful for trash mods, currently only used to avoid tainting which is only relevant in dev builds  
- Revert "roll back to ubuntu 22.04 to restore svn"  
- Update localization.es.lua (#1446)  
- Update localization.br.lua (#1445)  
- Update localization.fr.lua (#1447)  
- roll back to ubuntu 22.04 to restore svn  
- Fix double portals message  
- Minor LuaLS annotations  
- tweak alpha of variance background so he color bleeds through more  
- Update localization.br.lua (#1442)  
- Fix test mode timers getting stuck if in debugmode  
- Update localization.br.lua (#1441)  
- Update localization.fr.lua (#1440)  
- Update localization.es.lua (#1439)  
- Bump alpha  
