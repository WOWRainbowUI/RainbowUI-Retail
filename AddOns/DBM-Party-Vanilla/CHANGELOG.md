# DBM - Dungeons, Delves, & Events

## [r215](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r215) (2025-10-01)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r214...r215) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- Fix and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/566  
    Fix and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/565  
- Fixed a bug where legion timewalking dungeons didn't show timewalking stats  
- Fortifnication doesn't go on cooldown unless cast finishes. Fixes and closes https://github.com/DeadlyBossMods/DBM-Dungeons/issues/491  
- prep some legion remix notes  
- Add support for 2024+ Greench update. Closes https://github.com/DeadlyBossMods/DBM-Dungeons/issues/347  
- Add hovering menace alerts. Closes https://github.com/DeadlyBossMods/DBM-Dungeons/issues/469  
- Remove timers/alerts message print and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/460 . not much more to do with this boss then that with this log  
- Add support for all 3 archival assault bosses finally (mostly inconsiquential but better than printing "not yet supported" forever and ever)  
- Fix and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/559  
- Fix and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/557  
- fix and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/554  
- Fix and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/558  
- Fix and close https://github.com/DeadlyBossMods/DBM-Dungeons/issues/552  
- rework infinite breath to be clearer to understand for tank. Now the first warning will say "bait" for breath so you know you're in aiming stage.  
    Then it's followed up with a secondary dodge warning when bait has ended to avoid the stun.  
    Everyone else just gets a target count warning  
- Fix following missed conventions in PR #560  
    1. off interrupt warnings will now only show if main interrupt warning isn't shown, and will be throttled if multiple casters within 3 seconds, per off interrupt antispam conventions  
    2. Changed option default sfor dispel for time bomb so DBM isn't giving "bad directions" by default since mechanic requires more thought than just "dispel now!"  
    3. Applied same antispam logic to time bomb so that if dispel warning is enabled, you aren't seeing two target warnings at same time for every cast.  
- Update Tazavesh (#560)  
- Update localization.fr.lua (#562)  
- Update localization.mx.lua (#561)  
- Update localization.de.lua (#563)  
- Update TheDawnbreakerTrash.lua (#564)  
-  - Rework brewfest audio to store temp value in core instead of locally, so that core can restore it on login even if brewfest mod hasn't loaded yet. should fix niche situations where player logs out in brewfest area with audio lowered, then on login immediately departs area before brewfest mod can load and restore audio.  
     - Also fixed it so audio option is ignored if entire module disabled.  
