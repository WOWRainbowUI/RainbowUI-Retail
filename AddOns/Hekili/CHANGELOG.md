# Hekili

## [v11.0.5-1.0.12](https://github.com/Hekili/hekili/tree/v11.0.5-1.0.12) (2024-11-09)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.5-1.0.11...v11.0.5-1.0.12) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Remove Discipline Voidweaver debug print  
- Discipline Voidweaver corrections  
- Merge branch 'thewarwithin' of https://github.com/Hekili/hekili into thewarwithin  
- Fix #4074 (stop filtering by range when LRC fails)  
- Merge pull request #4112 from bjth/smooth-out-fdk  
    Smooth out FDK - APL simplification  
- Merge pull request #4162 from dubudevs/thewarwithin  
    fix off-by-one error in imp remaining cast calculation  
- Merge pull request #4170 from syrifgit/syrif-small-fixes  
    Prot Warr - Last Stand Spec Setting  
- Fix #4141 (Living Flame trinket)  
- Fix #4152 (Charge distance)  
- Fix #4153 (Clawing Shadows vs Vampiric Strike)  
- Enhancement Thorim's Invocation  
- Fix #4154 (RWK)  
- Fix #4164 (Enhancement priority adjustment for SB AOE - Lava Lash)  
- Make priority importer more durable ?  
- Fix #4167  
- Fix #4158 (Demonology adjustments)  
- Unholy priority adjustment (variables)  
- Don't Auto-Snapshot if 4 recommendations were made.  
- Fix #4156 (don't reset unloaded spec options)  
- Remove more MFE stuff.  
- Prot Warr - Spec settings that relied on a disabled setting  
    last stand settings were disabled if you decided to use last stand offensively, but that setting is gone and the last stand defensive settings were left permanently disabled  
- Fix #4165 (MFE stack detection)  
- fix off-by-one error in imp remaining cast calculation  
- Merge pull request #4155 from syrifgit/syrif-druid  
    Druid, Rsham, General UI  
- Balance - add the other half of blooming infusion  
- UI - Fix incorrect name of snapshots tab in various places  
    Also guardian druid unused variable commented out (targeted for later revisit)  
- RSham flame shock wrong ID  
- Fix Feral Frenzy Combo Point Forecasting  
- Move interupt even higher  
- Move interupts and AMS higher in the priority  
- Address comment for interrupt. LUA file takes care of mob casting  
- Bump LUA version  
- Update simc to remove nested actions, and update the LUA to import the new SIMC  
- these action list conditions can be strict  
- Bump the version number  
- Fix spelling mistake in Breath soul reaper condition. Re-Run RaidBots Sim Profiles  
- Merge in APL changes.  
- Merge branch 'thewarwithin' into smooth-out-fdk  
    # Conflicts:  
    #	TheWarWithin/DeathKnightFrost.lua  
    #	TheWarWithin/Priorities/DeathKnightFrost.simc  
- Merge branch 'smooth-out-fdk' of https://github.com/bjth/hekili into smooth-out-fdk  
    # Conflicts:  
    #	TheWarWithin/DeathKnightFrost.lua  
- Bump LUA file version  
- Remove Strict Checks as suggested.  
    Ran a dungeon with the new APL, without strict it feels better, than on a Dummy with them on  
- Merge branch 'thewarwithin' into smooth-out-fdk  
- Merge changes to Reaper Priority  
- Commit LUA change to import  
- Changes to Frost DK APL to smooth out gameplay  
    APL changes to get closer to the rotation from: https://www.wowhead.com/guide/classes/death-knight/frost/rotation-cooldowns-pve-dps both for ST and AoE. Changes to align CDs and rotational complexity.  
    Removed 1/2% APL performance gains that make it really jerky in game, as the suggestions change so rapidly.  
