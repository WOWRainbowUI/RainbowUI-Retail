# DBM - Core

## [12.0.49](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.49) (2026-05-16)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.48...12.0.49) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- Update koKR (#2072)  
    * Update koKR  
- Fix may 12th regression that caused seasonal dungeon lists not to work anymore  
    Tweak rename code to hide buttons completely on spells with no renamable functions (rather than just gray them out)  
- Such a silly nitpick  
- Update localization.ru.lua (#2071)  
- Also, gray out rename and test buttons if specific ability doesn't have renamable features (such as only being a private aura)  
-  - Blizzard hotfixed 1249619 out of game, so use diff spellId for option key on Death's Requiem  
     - Blizzard hotfixed Null Corona and it's no longer a private aura, so comment option.  
     - Added Collapse button to GUI title bar, making it easier to quickly collapse it out of way.  
     - Test buttons for Renames now automatically activate said collapse button so GUI isn't blocking seeing test.  
    T - est will now always show 1 timer and 1 warning if both available (rather than just timer).  
- fix layout some  
- Update localization.ru.lua (#2066)  
- Update translations (#2067)  
    * Update translations  
- Interrupt Spells (#2069)  
    * Interrupt Classic Spells  
- GUI Feature Update: (#2070)  
    * GUI Feature Update:  
     - Added ability to rename abilities in GUI.  
       - GUI will now show abilities rename by default rather than base name.  
       - New Buttons added to add own rename, or set back to defaults. As well as test button to test rename  
       - Renames are global per ability which means one rename affects all warnings/timers with matching spell key  
       - Renames will only work on hardcoded retail modules (or any module on classic. Most current content should be hardcoded on retail with exception of early season and PTRs  
       - External apis RegisterAltSpellName and GetAltSpellName work same as before, and will automatically pull user renames (as well as DBM default renames).  
     - Updated default GUI size from 800x600 to 1000x800 to better accomidate changes. It's not 2010 anymore  
     - Updated GUI to no longer allow it to load or open in combat. This is to avoid potential load or taint issues.  
- add option to auto show and run party keystone check when completing a key  
- Update localization.tw.lua (#2062)  
- Update translation (#2063)  
    * Update translations  
- Several dragons fixups in stage 1 and intermission 1.5  
    kinda said the ONLY module that doesn't have a finished hardcode, is dragons, due to no logs. at least my guild is on it now. Kind of ironic we have mythic hardcode support for midnight falls and crown but not this one. 🤦‍♂️ But maybe a symptom of how good non hardcoded modules are since fallbacks are seemless and still replicate most features.  
- refine restrictions check to be more precise and not broad in some places  
- no message  
