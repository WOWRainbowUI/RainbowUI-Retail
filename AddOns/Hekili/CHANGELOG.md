# Hekili

## [v11.0.7-1.0.1](https://github.com/Hekili/hekili/tree/v11.0.7-1.0.1) (2025-02-02)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.7-1.0.0...v11.0.7-1.0.1) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Destroy priority update  
- target.time\_to\_die will reflect add duration remaining  
- Destruction: Add durations to demon summons  
- Enhancement: Skyfury is essential  
- Elemental simc update  
    + Fury of the Storms  
    + Call of the Ancestors  
- Balance simc update with Wrath opener adjustments  
- Unholy APL update (incl. Winning Streak)  
- Assassin: Add experimental option to avoid using big CDs on dying non-boss targets  
- Frost Mage: Coldest Snap resets only work with 3+ actual targets  
    + Add CoC range option  
    + Model Frozen Orb flight behavior  
- Exclude Squall Sailor's Citrine from damage-based target detection  
- Fix potion aura copy error  
- Frost Mage: Adjust remaining\_winters\_chill to return stacks at end of tested ability's cast time.  
- Set default castRemainingThreshold  
- Tweak cast failed projectile event removal.  
- Destro APL update.  
- Merge pull request #4279 from joshjau/demo-warlock  
    demonology: add missing felstorm ability  
- Merge pull request #4283 from bjth/thewarwithin  
    #4264 - Unholy: Primary - Death Coil Auto Pop (Align Runes + RP with Frost  
- Merge pull request #4286 from syrifgit/thewarwithin  
    Chat Commands  
- Merge pull request #4312 from joshjau/warrior-fury-wwrange  
    Simplify Whirlwind range check for Fury Warrior  
- Merge pull request #4316 from doadin/patch-1  
    Fix Typo in Vengeance SIMC file  
- Merge pull request #4289 from syrifgit/syrif-druid  
    Feral, Balance, Disc Priest  
- Update DemonHunterVengeance.simc  
    Update DemonHunterVengeance.lua  
- Switch Whirlwind from usable to readyTime  
    Per Syrif feedback.  
    Changes:  
    - Changes Whirlwind from usable to readyTime for better buff prediction  
    - Fixes talent check in handler for Improved Whirlwind and Meat Cleaver  
    This improves ability recommendations by using readyTime for dynamic checks while maintaining existing functionality.  
- Simplify Whirlwind range check for Fury Warrior  
    Simplifies the Whirlwind range check to directly use the ability's 8-yard range instead of proxying through taunt and heroic throw ranges.  
    Changes:  
    - Adds explicit range = 8 property to Whirlwind ability definition  
    - Removes complex condition using taunt and heroic throw ranges  
    - Directly checks target distance against Whirlwind's 8-yard range  
    - Maintains existing settings.check\_ww\_range toggle functionality  
    This change makes the range check more accurate and maintainable while preserving the optional nature of the range check via settings.  
- Revert "Vengeance rework + 11.1"  
- Vengeance rework + 11.1  
- Fix Dreamstate ID  
- disc TWW season 1 set  
- Skeleton Stuff  
    Fix talent classification  
- Cleaner tooltip  
- Improved Skeleton Generator  
- Smol feral change  
    Makes the APL from SIMC compatible with addon without modifying the APL.  
- Chat Commands  
    Conflicts resolved using newest version of code  
- Merge branch 'thewarwithin' of https://github.com/bjth/hekili into thewarwithin  
- #4264 - Unholy: Primary - Death Coil Auto Pop (Align Runes + RP with Frost)  
    Relates 4264  
    Update Rune and RP logic to align with Frost  
- fix(warlock): add doom spell registration for demonology  
    Adds proper registration for the Doom spell in Demonology Warlock's aura table. This aligns with SIMC priorities and enables proper tracking of the Doom debuff.  
- demonology: add missing felstorm ability  
    add felstorm to abilities table with proper pet checks and talent interactions. fixes priority list errors that were showing up in hekili's warning system.  
- Enhancement enhancement  
- Unholy adjustments for snapshot  
- Work on Frost projectiles.  
- Outlaw updates  
- Merge pull request #4268 from IIeTpoc/thewarwithin  
    lastRoll, rtb\_primary, rtb\_buffs\_longer, normal, shorter adjustments. Enhanced Debugging Statement  
- Merge pull request #4271 from syrifgit/thewarwithin  
    Interrupt Timing Setting  
- Update State.lua  
    Revise use of variable  
- Update Options.lua  
    Revise description  
- Merge pull request #4273 from joshjau/misc  
    feat: Add Viq'Goth (Siege of Boralus) to enemy exclusions  
- feat: Add Viq'Goth (Siege of Boralus) to enemy exclusions  
    Adds Viq'goth (NPC ID 128652) from Siege of Boralus dungeon to the enemy exclusions table. This boss appears in the background during the encounter but is not targetable or damageable, so it should be excluded from target counting to prevent incorrect target calculations around aoe/cleave.  
    Changes:  
    - Added Viq'goth (128652) to enemyExclusions table with value `true` to always exclude  
    - Fixed missing comma after previous entry  
    This change helps prevent the addon from incorrectly counting this untargetable boss when calculating number of targets and related combat metrics.  
- Change slider to time value  
- Interrupt Timing Setting  
    Adds a configurable setting for users to specify how far into the castbar their interrupt will be recommended. Setting to 0 uses the previous addon behaviour as a default.  
- Merge pull request #4259 from syrifgit:thewarwithin  
    Balance, Frost Mage, Lightsmith Paladin, Warlock  
- Update RogueOutlaw.lua  
- Make rtb\_buffs\_normal preciser again  
- Prot Pal: Guardian of the ancient kings  
    Correct SpellID issue, tested in game and works fine. Also corrected the CD length for the PvP version.  
    Fixes https://github.com/Hekili/hekili/issues/4257  
- Merge pull request #3 from IIeTpoc/IIeTpoc-patch-7  
    Roll the Bones and Keep it Rolling calculation adjustment  
- Roll the Bones and Keep it Rolling calculation adjustment  
    Increased the threshold from 0.1 to 0.2 in rtb\_buffs\_longer and rtb\_buffs\_shorter to improve separation between categories.  
    Ensures that the new expiration time for each RtB buff after KiR does not exceed 60 seconds from the current time (query\_time + 60)  
    Enhanced Debugging Statements:  
    Added lastRoll, rollDuration, and rtb\_primary\_remains to the debug output.  
    Tracks key values for understanding Roll the Bones behavior in-game.  
    Buff Status Report:  
    Displays the remaining time and classification (shorter, longer, or normal) for each buff compared to rollDuration.  
    Improved Readability:  
    Organized debug output for better clarity during in-game testing.  
- Update RogueOutlaw.lua  
- Update RogueOutlaw.lua  
- Remove 2nd RtB debugging  
- Roll The Bones calculation changes  
- Conflict resolution  
- Pack string dates  
- Assorted Fixes  
    Affliction Lock  
    - Soul Swap PvP stuff  
    - https://github.com/Hekili/hekili/issues/4150  
    Balance Druid  
    - Spymasters stuff  
    https://github.com/Hekili/hekili/issues/4214  
    Holy/Prot files  
    - Fix holy armaments  
    - https://github.com/Hekili/hekili/issues/4237  
    Frost Mage  
    - Add additional `boss` check for Spymasters  
    https://github.com/Hekili/hekili/issues/4249  
- Merge branch 'thewarwithin' of https://github.com/syrifgit/syrif-hekili into thewarwithin  
- Merge branch 'thewarwithin' of https://github.com/syrifgit/syrif-hekili into thewarwithin  
- Destruction Warlock - Infernal Bolt  
    reset\_precast was using the buff ID in IsActiveSpell, not the actual spell ID.  
- Shifting Power  
    This should be on the cooldowns toggle by default. Turning off your CDs and having shifting power recommended is pretty grief.  
- UI Consistency  
    Improve UI consistency, make a few labels more clear.  
- more review notes  
- implement review notes  
- Destro Lock  
    Cataclysm is a part of the regular rotation now and should not be assigned to interrupt toggle in single target  
- Affliction - Funnel Toggle fixes  
- Merge branch 'thewarwithin' of https://github.com/syrifgit/syrif-hekili into thewarwithin  
- Destruction Warlock  
    Stop funnel toggle from preventing the single target part of the APL  
- Merge branch 'Hekili:thewarwithin' into thewarwithin  
- Target Counting options UI update  
- Marksmanship - black arrow / deathblow  
    apply deathblow / razor fragments when using black arrow, allows addon to correctly predict killshot instead of it being a reaction  
- Marksmanship wailing arrow  
    Wailing arrow improvements. Could use polish regarding wind arrow stacking, but is functional.  
