# DBM - Core

## [12.1.4](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.4) (2026-08-18)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.3...12.1.4) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- Update RU locales (#2181)  
- Update koKR (#2179)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- Add full Ulatek drycode, including aura sounds  
- Add vashnik auras and remove non disambiguatable text warnings  
- Twin fangs aura sounds  
- Forgot to included evidenced logs  
- Add aura sounds to coiled altar  
- Add aura sounds to Nekzali and Sszorak based on log evidence  
- avoid lua error with limit value being saved as a non whole number  
    more aggressively correct sliders that are meant to stay whole numbers  
- Enable aura options for Sentinels and explorers (with some caveat notes that some cannot be CLEU verified, but locked din ones that can be for sure)  
    bump voice pack version to 20 for new raid added audios (more will be added, as all bosses are reviewed on WCL)  
- Fix a bug where moveme button on auras might not show tank icons if spec isn't cached yet  
    fix a bug where preview specifically would set dispel borders on an incorrect strata behind icons  
- Improve debug logging with additional disambiguator  
- Satisfy LuaLS  
- Switch to cooldown swipe template instead for aura container  
- Scope current hardcode to normal and world difficulties on Wavecaller for now  
- Fix option location  
- Allow users to use the blizzard curated isBossOrRoleAura if they want (off by default, since during ptr testing a good half of boss auras at least were not correctly flagged as boss auras, not to mention it's useless for tracking trash auras)  
- make sure debuff auras update on spec change  
- bump alpha  
