# DBM - Core

## [12.1.5](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.5) (2026-08-21)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.4...12.1.5) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Update translations (#2185)  
- Update koKR (#2188)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- prep new tag  
- core function update  
- missed another unused  
- cleanup unused  
- update nekzali heroic to live routing  
- Fix both health not reporting for season 2 raids  
- deal with some quirks on entombed  
    1. boss can resend timers during deaths  
    2. Boss sends duplicate timers every intermission that needed improved filters.  
- Fix aura container not displaying most environmental/GTFO debuffs because they have no duration. So for now duration based filtering is scrapped. This should also hopefully fix important stacks from not showing on fangs  
- Layout fixes  
- altar normal update  
- Enabe wavecaller wrouting on herioc and mythic. world, normal, and heroic confirmed same. mythic probably also same. similar to rotmire, everything same.  
- Fix explorers not using correct in combat registerer  
    Add color option for duration text to aura container  
- never bumped alpha  
- preliminary normal coiled alter hardcoded timers, more later tonight  
- Add normal routing to vashnik as wel as handle better when boss resends duplicate timers  
- Add confirmed normal routing on Sszorak. Drycode extrapolated mythic routing based on blizzards 1, 8/9, 4/5 scaling rules evidenced in other fights from past and fangs from this tier.  
    Give fangs a safety rounding net for submerge variance  
- Enable normal (and lfr by assumption) routing on sentinels, since logs confirm normal is compatible with existing heroic and mythic ptr routing.  
- Rework explorers with multiple TL debug pulls of new evidence collection. disabled heroic and mythic routing for fight until that can be redone too  
- Update localization.ru.lua (#2184)  
- Add option to turn off challenge ui teleports.  
- Normal nekzali routing  
- Add normal mode routing and newly added submerge timer to twin fangs  
