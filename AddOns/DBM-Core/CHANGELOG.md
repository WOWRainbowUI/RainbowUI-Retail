# DBM - Core

## [12.0.55](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.55) (2026-07-14)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.54...12.0.55) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- do vanilla toc as well  
- Missed a toc bump for TBC  
- silence this message on retail, it no longer matters if it's private or not  
- handle private auras (auras in 12.1) in cleaner way so existing deprivated options in dungeons can be restored immediately and automaticaly work again in 12.1 (so glad I never deleted those, just commented)  
- Twin Fangs Mythic routing  
- improve audio of divine toll for clarity and reduced redundant use of generic "debuffyou" on paladins  
- fix regression causing aura sounds to stop playing due to over aggressive find and replace  
- deal with remaining vanguard variances across 13 mythic pull logs  
- Update koKR (#2126)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- add preliminary explorers hardcode routing that has low confidence due to low image quality.  
- Update vashnik and emtombed for mythic hardcode  
- twin fangs hardcode  
- prep lost explorers hardcode  
- Push hardcoded Coiled altar mod  
- Sentinels hardcode  
- Mini dragon patch 1 (#2121)  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Update RU locale (#2125)  
- more nil checks  
- Optimize/fix infoframe  
- Not that any module uses it anymore, but update checknearby too  
- kind of a silly fix but it should work  
- optimize GetRaidUnitId usage to not scan enemies when it doesn't need to. should also satisfy luaLS on IsTanking guards  
- hide private aura frame on 12.1 for now until 12.1 rewrite is done, to avoid errors during testing.  
- fix one missed rename  
- Rework aura sounds for 12.1 with backwards compat with 12.0  
- make GetRaidUnitId far more capable in vanilla and tbc classic hwere boss unit ids are not available for enemies  
- support GUID with GetIcon  
- more niche late phase paladins drift  
- Fix a regression that caused fallback api to not register audio countdowns when a mod encounters unexpected error and enters fallback mode.  
- Add 'READY' to .luarc.json configuration (#2124)  
- Fix bug that causes large refreshes NOT to get debuglogged if user report logging of timer refreshes were enabled and showed non debug print.  
- Some tweaks to timer behavior on crown to avoid some 0.5 refresh errors due to passing rounded timers to start instead of timerExact like intended.  
    Improved timeline api doc updates for easier understanding for both authors as well as agenic coding/review  
- Fix a few routing niches on paladins with smarter validation using a greater subset of data available now  
- Vashnik hardcode and notes update  
- tweak some audios  
- Scope Plague froth to personal only now that ENCOUNTER\_WARNING personal confirmed  
    Also, add heroic hardcode for Sszorak  
- Minor sszorak fix  
- actually bump alpha this time  
