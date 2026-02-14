# DBM - Core

## [12.0.20](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.20) (2026-02-14)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.19...12.0.20) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Update koKR (#1905)  
    * Update koKR  
    ---------  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Prep new release with the new sound options unlocked  
- Optimize DBT (#1899)  
    * --Hash table for O(1) bar ID lookups  
    --Sanitize previous icons only if they have texture  
    * Add LuaLS type annotations for DBTBarFrame journal icon fields (#1900)  
    Co-authored-by: MysticalOS <1899149+MysticalOS@users.noreply.github.com>  
    Co-authored-by: copilot-swe-agent[bot] <198982749+Copilot@users.noreply.github.com>  
    * Try this instead of letting copilot muck it up more  
    * meant this  
    * just scrap bad copilot code and revert back some. even if it means a ton of extra Get global calls  
    * reduce update bar calls  
    * Also reduce update calls when not needed as well  
    ---------  
    Co-authored-by: Copilot <198982749+Copilot@users.noreply.github.com>  
    Co-authored-by: MysticalOS <1899149+MysticalOS@users.noreply.github.com>  
- Alpha fix doesn't work, frame is constantly resetting alpha. So just ignore workaround for now and wait for blizzard fix  
- Create work around for sounds not playing if timeline is hidden by forcing frame to always show but set alpha on it instead  
    Fixed bug where if a user turns a sound off, it doesn't get cleared from sound registration with timeline  
- Respect users cvars and use new apis blizzard added for hiding warnings and timeline  
    Re-Enable countdowns and text custom alert sounds. (caveat, the sounds won't actually play if blizzard timeline is hidden)  
- remove extra threads here too  
- bump alpha  
