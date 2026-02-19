# DBM - Core

## [12.0.22](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.22) (2026-02-18)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.21...12.0.22) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Flag manaforge private auras with subtype flags for better distinction between targeted spells and GTFO spells  
- Update localization.ru.lua (#1922)  
- Force show timeline any time boss is engaged (but set alpha to 0). this ensures that timeline based sounds function even if user has timeline disabled.  
- Update voicePacksounds  
- Add more specific private aura option strings so that when multiple of same spell (gtfo vs targeted as example) exist, it's possible to distingquish the option text for multiple options.  
- Upd RU locales (#1921)  
    * Update localization.ru.lua  
    * Update localization.ru.lua  
    * Update localization.ru.lua  
- Update koKR (#1920)  
    * Update koKR  
- Update Core and GUI translations (#1919)  
    * Update Core translation strings  
    * Update Translations  
    * Update Core and GUI translations  
    ---------  
    Co-authored-by: anon1231823 <anon1231823@users.noreply.github.com>  
- fix bad object name  
-  - Refactored warning and time api calls so that countdowns and custom sound alerts will be unregistered on combatend and only if DBM registered them in first place. This fixes a possible issue if user used another addon that intended to register custom sounds or countdowns at same time as DBM.  
     - Fixed a bug where event alerts would be registered even if user had globally disabled special announce sounds entirely. Now if global disable is toggled on, it'll be honored as intended.  
- allow scale to go down to 25 instead of 50  
    change default size from 75 to 60 to account for fact I adjusted defaults based on a render scale of 75%  
- Make voice pack sound validation checks more strict  
    Fix invalid voice pack sound on soulbinder  
    bump alpha  
