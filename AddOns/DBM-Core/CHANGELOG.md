# DBM - Core

## [12.0.0](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.0) (2025-10-06)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.2.18...12.0.0) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Update localization.es.lua (#1770)  
- Update localization.br.lua (#1771)  
- Update localization.ru.lua (#1769)  
- Update localization.ru.lua (#1768)  
- prep first midnight compatible tag  
- Midnight Update:  
     - Do not show "icons used" or "Playgorund Mode" in boss mod UIs, since both are useless in midnight  
     - Fixed mod sorting so midnight is at the top of categories  
- Update demo mode to use timeline demo instead of legacy demo in midnight  
- Midnight Update:  
     - Don't load M+ affixes mod in midnight  
     - Added new raid module for midnight with combat detection and stats  
- Prune many more GUI options in midnight  
- Bleep.  
- Midnight Update:  
     - Added option to hide blizzard timeline (off by default)  
     - DBM will now auto enable timeline to make sure DBM (and timeline) function out of box  
     - Fixed issue where player name on certain frames was unknown if the api failed at login by adding redundant name check  
     - Break timers and Custom timers will now avoid errors if users try to send them in middle of boss fight  
     - Additional protections against older DBM modules calling secret functions like CID or GUID in combat  
     - Began work on hiding GUI options for features that are useless in midnight  
     - DBM will now prevent sharing timer text to avoid secret taint  
    Retail:  
     - Fixed regression that caused boss health reporting to stop working on retail due to midnight changes  
     - Deleted range frame options panel, range frame is long dead.  
- Lets just remove references to these.  
- Added Shadowlands and Dragonflight raid links to readme.  
- Add 12.0.0 to other TOC's (derp)  
- don't load dbm namepate code in midnight  
- Preliminary bar support for blizzard timeline. no options hooked up yet  
- Handle GetSpellCooldown restrictions better in midnight  
- relocate utility methods to earlier in file to fix error  
    load game versions before anything else to fix error  
- Prevent midnight incompatible event registration at core level so any legacy mod that loads will automaticlly reject registering problematic apis like CLEU, UNIT\_HEALTH, UNIT\_POWER\_UPDATE, and UNIT\_AURA  
- Few more midnight restriction checks  
    Also fixed a MoP scenario api that was disabled on mop classic by mistake  
- Handle midnight restriction checking better with a cleaner utility function  
    Handle GetAuraDataBySpellName and GetAuraBySpellID becoming protected in a future build by always using UnitAura apis instead (and only out of combat)  
    Added some missed restriction checks  
- add additional localization for slash commands that cannot be used when addon comms are limited  
- Add Devourer DH spec.  
- Add Midnight raid, dungeon and delve instances.  
- Challenge mode ID updates.  
- Test data update.  
- Keystones interface: Default fill out all party members before request  
- Don't run tooltip logic on midnight.  
- Bump TOC to support 12.0.0  
- ignore all CHAT\_MSG\_ events while in instances in midnight alpha  
- better handle getting whispers in an instance (where sender would be a secret)  
- bump alpha, grab new CTL  
- LuaLS midnight checks.  
- fix dum dum  
- more midnight fixes  
- Handle GetRaidClass icon not available post-midnight.  
- prevent infoframe from showing if the infoframe is using events that are restricted in combat in midnight alpha  
- Also block/return on attempting to access UnitAura, UnitDebuff, and UnitBuff in combat in midnight alpha  
- fix lua error in last  
    added a few more missed cases of addon comms  
- Block sending comms and chat messages in instances in midnight alpha client  
    Don't register CLEU in midnight alpha client.  
- bump alpha  
