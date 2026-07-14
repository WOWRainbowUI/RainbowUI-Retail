# DBM - Dungeons, Delves, & Events

## [r255](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r255) (2026-07-14)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r254...r255) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- Missed a toc bump for TBC  
- no actual bug fixes really, just try to silence debug from blizzard timeline bugs  
- re-enable all the de-privated auras in 12.1 for midnight dungeons  
    Add new encounter event Ids for 12.1 dungeon pool encounters  
- Add preliminary altar of fangs support  
- Missed one  
- Optimize GetRaidUnitId  
    Replace private aura apis with aura apis  
- Fix bug causing fallback countdowns not to work  
- Fix and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/605  
    Also fix some bugs not reported in ticket with arcanotron where boss can start some extremely erratic timer data that we just need to ignore.  
    also, while at it, restore Runic Mark alert using special warning with the precision of runic mark corrected.  
- Upgrade Reflux Charge, Eclipsing Step, and Brilliant Dispersion from Private auras to full special warning personal objects now that someone other than me (a tank) gave logs for nexus point (tanks don't get targeted by any mechanics)  
    Finally hardcode Nyrsarra  
- tweak ahune gossip. apparently it can be EITHER on retail  
- Add preliminary aztarec skeleton for stats and better debug logging. unfortunately blizzard hasn't actually added TL api to it yet  
