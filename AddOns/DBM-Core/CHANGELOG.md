# DBM - Core

## [11.0.37](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.37) (2024-12-14)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.36...11.0.37) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- enforce silken court only using encounter start/end to due to reports of false combats in rare cases  
- Update localization.ru.lua (#1432)  
- Update koKR (#1434)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Update localization.tw.lua (#1431)  
- Core: variance callback can also come from start timer arg (#1433)  
- work on object types and localizations  
- fix oops in last  
- improve variance timer callbacks to stay consistent with original behavior, variance timers should return min time in the regular timer arg to lign up with when ability cd window ends. peak variance cd window will use new args  
- Core+DBT: implement variance timers (#1429)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Update localization.ru.lua (#1427)  
- Update koKR (#1426)  
- Update localization.tw.lua (#1425)  
- Update localization.tw.lua (#1424)  
- Update zhCN (#1423)  
- tweaks to last  
- Delay combat bitflag check by 0.1 seconds to ensure no race condition happens where we check for combat in same frame as entering combat, and may return false for it. hopefully fix user report of initial timers not starting when party members pull trash when they're further away.  
- Fix some missing calls that for some reason local luaLS didn't detect last night  
- Small cleanup  
- bump alpha  
