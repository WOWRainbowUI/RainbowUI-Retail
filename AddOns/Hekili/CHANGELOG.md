# Hekili

## [v11.0.2-1.0.9](https://github.com/Hekili/hekili/tree/v11.0.2-1.0.9) (2024-09-06)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.2-1.0.8...v11.0.2-1.0.9) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Shadow: Distinguish VB from MB and tweak priority  
- Merge branch 'thewarwithin' of https://github.com/Hekili/hekili into thewarwithin  
- Fix Ravage  
- Merge pull request #3675 from ambonif/patch-5  
    Fix #3641  
- Merge branch 'thewarwithin' into patch-5  
- Merge pull request #3678 from syrifgit/thewarwithin  
    Significant Arcane Fixes  
- Significant Arcane Fixes  
    Added many missing handlers, corrected buff/spell IDs, made up some hacky APL logic and mana trickery, but it now actually replicates the sim rotation reliably for the Sunfury spec.  
    Any previous discussion can be seen on: https://github.com/Hekili/hekili/pull/3669  
- Fix #3641  
    Basically, the issue is that Magis Spark is not actually a buff applied to the player. The code originally references this https://www.wowhead.com/spell=450004/magis-spark.  
    The talent simply modifies the Touch of the Magi debuff. So the changes here take that into account. Applying the three ability debuffs (magis\_spark\_arcane\_barrage, magis\_spark\_arcane\_missles, and magis\_spark\_arcane\_blast) now apply properly when Touch of the Magi is cast, and Arcane Blast is recommended once even while in AOE range.  