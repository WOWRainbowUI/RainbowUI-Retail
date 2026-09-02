# DBM - Core

## [12.1.8](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.8) (2026-09-01)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.6...12.1.8) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Update koKR (#2205)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- Update commonlocal.ru.lua (#2207)  
- prep a new tag fixing and closing https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2206  
- bump alpha  
- prep new tag  
- Add another common L  
- extend stage 3 heroic data for ulatek  
- Fix regression that caused next timers to use ~ incorrectly  
- Ulatek heroic  
- fix potential routing failure on explorers  
- update vashnik routing  
- enable heroic coiled fang hardcode  
- Enable explorers heroic routing  
- Update koKR (#2190)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- Update translation (#2192)  
- Update commonlocal.ru.lua (#2191)  
- Adjust debuglog logging levels to push some required events into lower debuglevels so they are captured by user provided logs. essential for routing certain bosses like Lost Explorers and Uletek  
    Cleaned up and unified secret target messages to be consistent between announce and special announce objects as well as support unit methods and not just guid methods. guid methods best for ENCOUNTER\_WARNING intercepts and unit messages when we already know target unitID (such as boss1target) for tank swaps.  
- De-spam explorers a little  
- Aura icon update fulfulling requests for feature parity to other addons like NST, BW, and raid frame addons:  
     - Added low duration color change option similar to other addons  
     - Added icon zoom option similar to other addons  
     - Added Center layout options  
    TODO, add character name above each icon option as an alternative to player name next to each anchor (pro, can actually hide it with no auras, con, has to appear on EVERY icon).  
- Change option default  
- bump alpha  
