# DBM - Dungeons, Delves, & Events

## [r265](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r265) (2026-10-13)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r264...r265) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- Add all missing 12.1 delve bosses as well  
    And finally, add auto translation of all delve bosses in all languages from wago  
- Add bosses for new labyrynth delve  
- prune test stuff  
- Combat with miner johnson now detectable in forever with newly added encounter ID  
- more attempts to fix first boss and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/638  
    this is last time. if this boss continues to break I'm removing hardcode and letting all blizzard bugs through so users can complain to blizzard for it being a hot mess.  
- Fixed a bug on council of tribes where totems dropped in stage 3 could also fire the soak warning incorrectly with improved disambiguation  
    Fixed Dazar routing failure caused by missing timer for hunting leap  
    Fixed incorrect soundfile on pushback on golden Serpent  
    Fixed "pool on you" sound that could still play on adderal and ass pix even if you weren't targeted  
- Fix toc (#637)  
- use new helper in some modules  
- Update DBM-Party-Vanilla.toc (#636)  
- Translation names forever (#634)  
- cover variance better than blizzard does. Closes https://github.com/DeadlyBossMods/DBM-Dungeons/issues/635  
- exclude coren direbrew from retail. since blizzard didn't give it combat detection that can be used. it can't even have statstical module anymore. sorry mount collectors. blame blizzard  
