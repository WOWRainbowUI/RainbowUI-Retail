# DBM - Core

## [12.1.13](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.13) (2026-10-12)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.12...12.1.13) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- fix range radar lua errors in forever  
- Add some moer default renames  
- cleanup no longer used  
- Update localization.ru.lua (#2245)  
- Update koKR (#2246)  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- LFR testing showed 43 is too large, and ley spider eggs might be better (41)  
- sizing adjustments  
- safer approach  
- Long overdue overhaul of item lists for all game versions to support more accurate boss distance calculations and pre combat range frame calculations. All ranges heavily verified in game using Era, TBC, MoP, retail, and forever clients for most accurate range calculations  
    Updated the CheckBossDistance api to inteligently use all new data automatically to any mods using it.  
    Added a new universal infoframe type that can be quickly deployed on any boss it makes sense to show boss distance calculations in real time. Deployed it's first use on Sentinels  
- Create diagnostic tools for evaluating range check candidates that can quickly validate or invalidate checks.  
- fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2244  
- Update koKR (#2238)  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- Update RU locales (#2237)  
- blizzard can't count, adjust protovenom timer to be it's true timer (18) not blizzards timer (20)  
- vial of sunwell doesn't work at all as item check range, always returns nil even when cached. use gland instead for 43 range  
- fix audio for protovenom, and give it a clear rename  
    make tank swap warning just say unknown instead of using boss target, since boss always looks at invalid target during explorers tank swap  
- Doubt this will work but we'll see in a PR (#2242)  
- tweak wave caller to not increment count for initial bubble setup  
- fix luaLS?  
- Fix throttle seconds api for 12.1.5  
    Add glow option (off by default) for 12.1.5  
-  - Change tank line warning on nekzali to be a warning for everyone with better audio  
     - Changed spellid used for restless amani to match blizzards, now  that intended spellid has a tooltip.  
     - Shell spin on explorers will now show targets name  
     - 32 second timers will now use tighter disambiguation on explorers to avoid starting wrong ability timer on mythic if you late or early phase push with fish and broke simple ordering based disambiguation.  
     - Shredding shards now has a smart taunt based alert for tank NOT taking shards on explorers  
- Prune DBM-Test and all hooks and sub modules. (#2241)  
- Several Nekzalia fixes  
- manually allow WOW\_PROJECT\_CAMELOT  
- update to WOW\_PROJECT\_CAMELOT usage  
- actually solve it this way  
- luaLS can be so retarted sometimes  
- Improvmeents to Entombed Sentinels  
     - Ui options will now split abilites by boss  
     - Alerts will now only fire for the boss you are near (with exception of orbs that spawn on both sides)  
     - Timers will fade for abilities that don't affect your side  
- Misc Cleanups (#2239)  
- luals  
- update infoframe to have methods for using secrets  
- Unhide couple UI options that still actually work in retail/forever  
- Improve audios and renames on Ulatek a bit more  
- bump alpha  
