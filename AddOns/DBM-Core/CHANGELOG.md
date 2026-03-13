# DBM - Core

## [12.0.30](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.30) (2026-03-12)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.29...12.0.30) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- missed one  
- update available media  
- Split addon comms code into a submodule (#1963)  
    * Split addon comms code out of core and into a sub module to further reduce main core file bloat and make another function of addon easy to find and follow.  
- Modulize User Timers (#1960)  
    * Split Pull, Break, and User / Pizza timers into their own sub module and further reduce clutter in DBM-Core  
- Update koKR (#1957)  
    * Update koKR  
- Update translations (#1956)  
    * Update translations  
    * Update translations  
    ---------  
    Co-authored-by: anon1231823 <anon1231823@users.noreply.github.com>  
- remove duplicate callback and fix nameplate using deprecated callback still  
- Update localization.ru.lua (#1955)  
- Slight tweaks  
- Re-enable world buffs in season of discovery. since it's a dead game now, no reason to restrict it. and if users don't want feature it has a toggle.  
- Initial plan  
- Add per-bar-type text X/Y offset sliders to bar configuration (#1954)  
    * Add text offset (X/Y) sliders for small and large bar timers  
- Add font shadow option to statusbar timer labels (#1953)  
    * Add FontShadow option to statusbar timer name/timer labels  
- New bar options (#1949)  
    Add more bar customizing:  
     - You can now edit bar background color and transparency  
     - You can now enable bar border and set color and pixel size  
- Update koKR (#1948)  
    * Update koKR  
- Update localization.ru.lua (#1947)  
    * Update localization.ru.lua  
    * Update localization.ru.lua  
- add new string  
- fix bad copy/paste  
- Update voice pack list.  
    added first two voidspire boss mods with support for blizzard api (hardcode will come later with live logs)  
