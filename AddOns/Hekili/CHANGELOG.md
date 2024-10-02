# Hekili

## [v11.0.2-1.0.19](https://github.com/Hekili/hekili/tree/v11.0.2-1.0.19) (2024-10-02)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.2-1.0.18e...v11.0.2-1.0.19) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Unholy priority update  
- Merge branch 'thewarwithin' of https://github.com/Hekili/hekili into thewarwithin  
- Augmentation Prescience and FB  
- Merge pull request #3874 from johnnylam88/feat/filter-spell-reflection  
    feat: allow limiting the use of Spell Reflection on warriors  
- More Ret LD  
- Enhancement tweaks  
- Another one  
- And again  
- feat: change how M+ interruptible spells are handled  
    Instead of removing the `casting` debuff from the target if the spell  
    doesn't matches the M+ interrupt filter, change the `casting` debuff to  
    signal that the spell is not interruptible. This allows priorities to  
    still react to the spellcast with other abilities besides an interrupt  
    ability.  
- feat: allow limiting the use of Spell Reflection on warriors  
    Create a toggle to limit Spell Reflection to be usable only on  
    reflectable spells from TWW Season 1 dungeons that are targeting the  
    player.  
    Store the database of reflectable spells in `Hekili.Class` for warriors  
    only as it is warrior-specific.  
- Merge pull request #3878 from syrifgit/thewarwithin  
    Aspect of the Eagle is baseline now  
- Merge pull request #3886 from xinni/patch-1  
    Enhancement: Tempest summon Feral Spirit  
- Fix #3858  
- Fix #3887  
- Fix #3882: Shadowmoon Insignia added (though defensive)  
- Fix #3885: registered trinkets will work even if not usable  
- Fix Elysian Decree vs. Sigil of Spite  
- Testfix for #3856  
- Sigil of Spite IDs (Fix #3889)  
- Ret HoL test alpha  
- Enhancement: Tempest summon Feral Spirit  
    Should fix the issue descriped in https://github.com/Hekili/hekili/issues/3871  
- Aspect of the Eagle is baseline now  
