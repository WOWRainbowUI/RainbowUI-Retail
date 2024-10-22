# Hekili

## [v11.0.2-1.0.21](https://github.com/Hekili/hekili/tree/v11.0.2-1.0.21) (2024-10-21)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.2-1.0.20a...v11.0.2-1.0.21) [Previous Releases](https://github.com/Hekili/hekili/releases)

- 18 priority updates  
- Outlaw debug info  
- Outlaw more fix  
- Outlaw: Testfix for RtB  
- Merge pull request #3986 from syrifgit/TWW-Live---Syrif-Changes  
    Hunter, Mage, Lock, minor fixes  
- Merge pull request #3987 from syrifgit/UI-Changes  
    General UI Changes  
- no rotations or specs here  
    only priorities and specializations  
- Revisions to UI  
    as requested/disussed  
- Revisions  
    Will leave the shadow priest part out for now as it will take longer to fix.  
- spriest  
    bugfix to voidheart update  
- Spriest - Entropic Rift  
    Improve Entropic Rift calculations. Is is inherently linked to voidheart which is a real, trackable buff with an ID. So alias it with entropic rift and use voidheart for all calculations. Removes need for reset\_precast calculating as well.  
    void torrent refreshes the 8 second buff on every tick, and void blast extends it by a second each cast, up to a max of 3 seconds per window.  
- BM - Call of the Wild CDR  
    More accurate modelling, and also the initial tick was incorrect because it summons 2 pets so you are granted a full charge of each.  
- wrong copy paste  
    undo  
- BM - Call of the Wild CDR  
    More accurate modelling, and also the initial tick was incorrect because it summons 2 pets so you are granted a full charge of each.  
- WarlockDestruction.lua  
    funnel toggle logic  
- WarlockAffliction.lua  
    funnel toggle logic  
- WarlockDestruction.simc  
    fix funnel toggle logic  
- WarlockAffliction.simc  
    fix funnel toggle logic  
- MageFrost.lua  
    Shifting power cooldowns toggle by default  
- MageFire.lua  
    shifting power CDs toggle by default  
- HunterSurvival.lua  
    UI consistency  
- HunterMarksmanship.lua  
- HunterMarksmanship.lua  
    UI Consistency  
- HunterBeastMastery.lua  
    Improve UI consistency / sizing  
- UI Changes  
-  General UI  
    - Update target settings UI to better guide the user through making their selections  
    - Separate pet-based detection from nameplate detection  
    - Change wording of many options  
    - Minor tweaks to size / order of options  
    Actual targeting logic has not been modified yet, that will be a future PR.  
    More UI Cleanup. Change "Core" to "Specialization Settings", label is more intuitive especially for English Second Language users. Stop using "normal" width and start using "1.5" width on stuff to create consistency, this is a parameter value you already use elsewhere, may as well stick with it.  
- Merge pull request #3968 from johnnylam88/refactor/expansion-items  
    refactor: move expansion-specific items into their own modules  
- Merge pull request #3972 from johnnylam88/fix/protection-warrior-thunder-blast  
    fix: adjust Thunder Blast for protection warrior  
- Merge pull request #3974 from johnnylam88/fix/sanlayn-vamp-blood  
    fix: treat Vampiric Blood as a cooldown with San'layn Hero Talents  
- Merge pull request #3977 from Yuuseki/thewarwithin  
    fix(assassination): get correct mutilate and ambush energy cost  
- Remember not to forget  
- VDH: CD Resets, Stuff  
- Blood: Model BS->BS stacks; correct BS max stack  
- Make Assassin's combo\_points.deficit account for charged points  
- Marksman fixes (from Syrif's PR)  
- Stormbringer to Stormsurge  
- Updated PvP target dummy list.  
- Merge branch 'thewarwithin' of https://github.com/Hekili/hekili into thewarwithin  
- fix(assassination): fix cheap shot energy calculation  
- fix(assassination): add goremaws\_bite line back in (deleted accidentally)  
- fix(assassination): more energy cost corrections  
- fix(assassination): get correct mutilate and ambush energy cost based on talent  
- Merge pull request #3971 from johnnylam88/fix/kaheti-shadeweavers-emblem  
- fix: treat Vampiric Blood as a cooldown with San'layn Hero Talents  
- fix: correct the buff ID for Kaheti Shadeweaver's Dark Ritual  
    Fixes #3967.  
- fix: adjust Thunder Blast for protection warrior  
    Use the correct texture ID for Thunder Blast on protection warrior, and  
    fix how the Thunder Blast buff is handled when casting both Thunder Clap  
    and Thunder Blast.  
- fix: support Timewalking Wrathstone trinket in TWW  
    Fixes #3956.  
- refactor: load new expansion-specific Items.lua files  
- refactor: split out expansion-specific items from Classes.lua  
    Move expansion-specific trinkets and other items from `Classes.lua` into  
    separate, expansion-specific `Items.lua` files.  
    This is meant to make addtions or updates for Timewalking events easier.  
- Merge pull request #3865 from johnnylam88/fix/slayer-hero-talent  
    fix: manage Marked for Execution debuff from Slayer's Strike  
- Merge branch 'thewarwithin' into fix/slayer-hero-talent  
- Update WarriorFury.lua  
    max/min and debuff fix  
- Update WarriorArms.lua  
    Fix max/min; marked\_for\_execution debuff  
- Balance and Guardian updates  
- Unholy SimC update  
- Frost DK: SimC update, tie BoS RP option to priority  
- Prot Pal update  
- Demo: Fix Soul Strike queue (caused actions to repeat)  
- Holy Pal: Revise Eternal Flame (does not replace WoG)  
- BrM update 3  
- BrM: another update  
- Merge branch 'thewarwithin' of https://github.com/Hekili/hekili into thewarwithin  
- BrM updates  
- Merge pull request #3929 from joshjau/arms-warrior  
    Refactor Arms Warrior APL: Remove raid events, fix typo  
- Merge pull request #3935 from johnnylam88/fix/monk-brewmaster-tier-bonus  
    fix: add buffs from monk brewmaster tier set bonuses  
- fix: adjust Keg Smash cost due to Flow of Battle  
- fix: add buffs from monk brewmaster tier set bonuses  
    Add Flow of Battle buffs from the Monk Brewmaster tier set bonuses. The  
    buffs are named identically to the ones used by SimulationCraft.  
- Update WarriorArms.simc  
- Refactor Fury Warrior APL: Remove raid events, simplify fight conditions  
    Updated heroic leap and variable checks to use in-game observable conditions instead of raid events for better real-world applicability.  
- fix: manage Marked for Execution debuff from Slayer's Strike  
    Modify Arms and Fury warrior modules to manage the Marked for Execution  
    stacking debuff from Slayer's Strike.  
    Marked For Execution is applied by Slayer's Strike and stacks a maximum of  
    three times and is removed only when Execute is cast.  
    With the Imminent Demise talent, consuming Sudden Death applies Imminent  
    Demise and stacks a maximum of three times and is removed by Bladestorm.  
    Use the correct name for the debuff (also used in SimC) as  
    `marked\_for\_execution` and allow it to be tracked via `active\_dot`.  
