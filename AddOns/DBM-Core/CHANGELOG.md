# DBM - Core

## [12.0.8](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.8) (2025-12-04)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.7...12.0.8) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- fix bad cvar toggle value  
    Prep new tag  
- Hide unused warning colors in midnight  
- Fix mistake in string editing  
- this way matches retail  
- Fixes to Last:  
     - Fix regression that caused double sounds, vibrations, and flashes for non midnight warnings  
     - Fixed missing spell icons on chat frame text messages on the new midnight alerts  
     - Fixed incorrect font color on the non special midnight alert in chat frame.  
- Update koKR (#1819)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Add C\_StringUtil  
- Midnight Update:  
     - DBM now fully supports Blizzard warning replacement with traditional DBM style warnings.  
     - Timeline and warning hiding now uses cvars and not hacky show = hide now taht events fire even if timeline or alerts are turned off.  
- Better support scripted timers from 3rd parties if they use only spellid and not overrideName  
    Enable timer recover on UI reload  
    adjusted hide time options to go from 30 seconds to 5 minutes instead of 50 seconds to 10 minutes (if you want LONG/infinite duration bars just disable time limit instead)  
- Update timer testing for midnight  
- bump alpha  
