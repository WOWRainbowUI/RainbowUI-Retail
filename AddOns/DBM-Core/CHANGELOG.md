# DBM - Core

## [11.0.20](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.20) (2024-10-02)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.19...11.0.20) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Update several changed timers on silken court in LFR, normal, and heroic difficuty  
    mythic has changes too but i only got one pubic log that's 30 seconds log (and in that log already had one timer that's 3 sec different). I'll have to wait for more mythic logs to finish fixing that.  
    Closes https://github.com/DeadlyBossMods/DeadlyBossMods/issues/1302 and closes https://github.com/DeadlyBossMods/DeadlyBossMods/issues/1297  
- pre new tag  
- Create localization.br.lua (#1299)  
- Create localization.es.lua (#1298)  
- Update localization.fr.lua (#1296)  
- Update localization.es.lua (#1295)  
- Update localization.ru.lua (#1294)  
- Update localization.ru.lua (#1293)  
- Update localization.ru.lua (#1292)  
- Create localization.fr.lua (#1300)  
- Update DBM-Affixes\_Mainline.toc (#1301)  
- more fixes that were causing this weeks world boss not to work  
- forgot to hit save on this one  
- fix loading and detection of kordac  
- push mythic ansurek mod updates  
- Improve audio for first boss on mythic to clarify group 1 and group 2 soaks via voice packs.  
    in addition, will no longer tell players with debuff from first soak to soak the second.  
- Update koKR (#1290)  
- Core: Delete unused NilWarning code  
    It's impossible* to get the different announce Show() arguments into the type system in a reasonable manner if the variable can be a NilWarning  
    *without a LuaLS plugin which I don't want to write  
- Tests: Fix test generation when you pull while already in combat  
- UI: Show SoD stats as Normal/Heroic/Mythic without player count  
- UI: Add option to anonymize imported tests  
- UI: Minor UX improvements for test import dropdowns  
    Auto-select recently imported tests, auto-select first log that contains an encounter  
- Change frontal text to include both colors AND boss names so they give context to all difficulties  
- Fix delve difficulty check for zekvir  
- bump alpha  
