# DBM - Dungeons, Delves, & Events

## [r260](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r260) (2026-08-26)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r259...r260) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- add another murder row auto gossip  
- Add 3 missing trash warnings across current season pool  
    Add auto gossip to the den of nalarakk dungeon teleport npcs  
- Aztarec, attempt to alert spells when blizzard misfires a state 3 for them within expected cast window. should hopefully avoid missing interrupt or tank buster warnings due to blizzard bugs  
    Redo ass pics and adulterous with live timer routing as well as feature request of a warning on which one to attack on swaps/engage  
- fix classification. closes https://github.com/DeadlyBossMods/DBM-Dungeons/issues/622  
- more timer error supression  
- Several fixes to Den of nalrakk  
- more weaks to Malefic Wave timer which blizzarad only sends an average for but actually gives it at least a 4 second variance.  
- Kings rest fixes, two of which are same resend bug  
- Ruby Life Pools Fixes:  
     - Work around yet another blizzard bug on Chillworn that can cause false timer starts and break disambiguation.  
     - Fix stage 2 detection on Erkhart again  
    Voidscar Arena  
     - Fix monsterous roar saying knockback instead of aoe  
- Atar of fangs update  
     - Updated Zuljan for mid week hotfixes  
     - Fixed bug on ravi that allowed it to fire false triple shot on you warning if fresh meat occured within 200ms  
     - Fixed missing phase timer options on Writhing Coil  
- wait, why the heck did this get in there.  
- Fixed bug causing winds shortname not to be applyed to midnight even though it's existed since dragonflight.  
    Enable winds alert on midnight just like it was supported in classic as well and move it to common locales vs the stale mod specific localizations.  
