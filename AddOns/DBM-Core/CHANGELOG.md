# DBM - Core

## [11.2.10](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.2.10) (2025-08-18)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.2.9...11.2.10) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- make Mythic fractillus public as well  
- Scrap out of date PTR tests so they stop generating false errors.  
- Fix regression in last commit on non mythic hunters.  
    More timer fixes in all difficulties to acount better for variances  
- Mythic Hunters update  
- attempt to fix photon distance filtering with a looser check and diff item ID  
    try a diff way of handling timer variance  
    fixed spammy alert on naaz  
- fix option header  
- Fix lua error  
- Araz update:  
     - Mythic timers updated to live  
     - Added missing timer for astral harvest on all difficulties  
     - Fixed boss health reporting in whispers and wipes  
     - Re-enabled photon blast warning with a distance filter  
     - Enabled Photon blast nameplate timer  
    Bug Fixes:  
     - Fixed bugs on gallywix, lockenstock, and araz that would cause timers to start when they shouldn't due to how core handles starting of timers with a value of 0  
- Fix overscheduling on loomithar  
- prep direct spec request inqueries to 11.2 apis and only use deprecated ones where new ones don't exist  
- Make additional loomithar work public  
- Update tests  
- Fix bug where supernova count didn't reset on pull, cuasing timers and counts to break after first pull.  
- work around blizzard bu where first dark sky is missing from combatlog. (and can't count on blizzard fixing it since soon EVERYTHING will be missing from combat log)  
- Dirty fix to make parser at least finish when anonymizer fails  
    Update dimensius heroic test  
