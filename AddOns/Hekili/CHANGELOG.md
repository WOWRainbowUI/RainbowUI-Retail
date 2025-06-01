# Hekili

## [v11.1.5-1.0.8](https://github.com/Hekili/hekili/tree/v11.1.5-1.0.8) (2025-06-01)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.1.5-1.0.7...v11.1.5-1.0.8) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Merge pull request #4882 from Krytos/patch-11  
    Updated Protection Warrior  
- Merge pull request #4876 from syrifgit/alter\_time  
    Fix Alter Time  
- Merge pull request #4872 from syrifgit/syrif-mage  
    Fix Burden of Power order of operations  
- Merge pull request #4871 from syrifgit/chat-cmd  
    Fix Chat Command scoping issue  
- Merge pull request #4870 from syrifgit/Rogue-Fixes  
    Sin Rogue Warnings  
- Merge pull request #4853 from syrifgit/survival  
    Improve Lunar Storm Tracking  
- Updated Protection Warrior  
    - Changed Revenge threshold to be settings.reserve\_rage + 20 instead of 40. There is no reason for it to be 40 and it simply means there is no button to press, if you are between 20 and 40 rage with both Shield Slam and Thunder Clap on CD. It might make sense to change execute to 20 as well. Though I understand that the 40 setting is for the max damage of execute.  
- Demo haste fixes and helper expressions  
- Fix recs when mounting, etc.  
- Shadow comment  
- Aether Attunement Counter  
- Fix Alter Time  
- Fix Burden of Power order of operations  
    This was reflecting a change Blizzard made to Burden of Power, however when they reverted the change we did not. It now matches in-game behaviour (The same cast cannot generate/consume Burden/Glorious).  
    Fixes https://github.com/Hekili/hekili/issues/4856  
- Fix Chat Command scoping issue  
    `/hek fix pack` was failing due to undefined ACD, forgot to bring it over from the `Options.lua` chop chop  
- Sin Rogue Warnings  
- Fix Cycle of Life count  
- spacing  
- Add black arrow fix  
- Update HunterSurvival.simc  
- More better solution  
- Better solution  
- not real  
- Enhancement: Missing CL aura  
- Discipline: Premonition tweaks.  
- Tweak FHL.  
- Tweak loss of control auras.  
- Merge pull request #4866 from syrifgit/hpal  
- Merge pull request #4842 from IIeTpoc/IIeTpoc-adjusted\_rtb\_primary\_remains  
    Fix #4839 - make Coup de Grace "known" Fix for #4840 - adjust rtb\_primary\_remains calculation  
- Update PaladinHoly.lua  
- Merge pull request #4852 from johnnylam88/fix/tome-of-lights-devotion  
    fix: improve implementation of Tome of Light's Devotion tanking trinket  
- Merge pull request #4863 from srhinos/thewarwithin  
    Dominos Action Bar Support  
- Hpal Improvements  
- Clean up ReadOneKeybinding  
- Undo single loop change  
- Simplify Bulk Search and Bug Fixes  
- Add Newline  
- Dominos Action Bar Support  
- Merge branch 'Hekili:thewarwithin' into IIeTpoc-adjusted\_rtb\_primary\_remains  
- Update RogueOutlaw.lua  
- Use debuff tracking for Lunar Storm  
    It's very consistent and timely now, due to recent flurry of aura changes/fixes re: unfurling darkness. Unfortunately SIMC uses different syntax, so notes were added to the top of the files.  
- fix: classify Tome of Light's Devotion as a crit-cooldown trinket  
    Reclassify Tome of Light's Devotion tanking trinket as a cooldown  
    trinket that provides critical strike rating, which is how it's used in  
    practice.  
- fix: improve support for Tome of Light's Devotion tanking trinket  
    * Fix cooldown to 90s from 120s.  
    * Rename the `radiance` buff to `radiance_tome` to match  
      SimulationCraft. `radiance` is the buff name for the Darkmoon Deck:  
      Radiance buff in SimulationCraft.  
    * Change the `handler` to correctly rotate the buff for the trinket when  
      its on-use ability is activated. This matches current trinket  
      behavior as of 11.1.5.  
    * Add `radiant_verses` and `resilience_verses` buffs to track the  
      stacking buff gained from being attacked. These names match  
      SimulationCraft.  
- Merge pull request #4848 from syrifgit/syrif-druid  
    Balance APL  
- Merge pull request #4844 from syrifgit/survival  
    Survival APL  
- Merge pull request #4843 from syrifgit/shaman  
    Shaman APLs  
- Merge pull request #4841 from IIeTpoc/patch-8  
    Fix #4839 + Add Unseen Blade (available, CD) and disorienting strikes…  
- Merge pull request #4716 from johnnylam88/feat/setting-dnd-no-movement  
    feat: DK spec setting to prevent Death and Decay while moving  
- Update DruidBalance.lua  
- Balance APL  
- Survival APL  
- Shaman APLs  
- Fix #4840  
    Fix for #4840  
    Now container calculations (rtb\_primary\_remains) are triggered by rtb\_cast.  
    For me after several tests it fixed the issue.  
- Remove wrong comment  
- CdG base GCD is actually 1.2 sec  
    https://www.wowhead.com/spell=441776/coup-de-grace  
- Fix #4839 + Add Unseen Blade (available, CD) and disorienting strikes (DS) to the snapshot  
    Fix #4839 and Add Unseen Blade (available, CD) and disorienting strikes (DS) to the snapshot  
- feat: DK spec setting to prevent Death and Decay while moving  
