# Details!: Mythic Plus Extension

## [DMP.20250422.002](https://github.com/Tercioo/Details--Damage-Meter-Mythic-Plus-Extension/tree/DMP.20250422.002) (2025-04-22)
[Full Changelog](https://github.com/Tercioo/Details--Damage-Meter-Mythic-Plus-Extension/compare/DMP.20250413.001...DMP.20250422.002) 

- Fixed out of combat and item level alignment.  
- Fixed loop on runInfo.combatData.groupMembers, was using ipairs instead of pairs.  
- Merge pull request #57 from BlueNightSky/patch-2  
    Update zhTW.lua  
- Update zhTW.lua  
- Fix for timer cancelation.  
- Merge branch 'master' of https://github.com/Tercioo/Details--Damage-Meter-Mythic-Plus-Extension  
- Added average item level in the top left corner of the scoreboard.  
- Merge pull request #56 from linaori/fix-highlight  
    Fix scoreboard highlights  
- Fix scoreboard highlights  
- Stop loop timers before starting a new scoreboard update.  
- Missing declarations in classes and default values for tables.  
- Use dungeon icons in the run selector dropdown.  
- Big dungeon background image desaturation.  
- Merge pull request #55 from linaori/key-icon  
    Question mark -> key icon  
- Question mark -> key icon  
- Merge branch 'master' of https://github.com/Tercioo/Details--Damage-Meter-Mythic-Plus-Extension  
- Added a graveyard, class and time icon into the death log tooltip in the activity bar.  
- Merge pull request #54 from Hollicsh/patch-1  
    Update ruRU.lua  
- Update ruRU.lua  
- Set a fixed size for the death tooltip to avoid eye guessing position.  
- Only show decimals in the elapsed time if the run was 2 seconds near the time limit.  
- Removed hour and minutes from the dropdown run selector as they are irrelevant when the key is older than 7 days.  
- Added what keystone each player has.  
- Merge pull request #53 from linaori/fix-timer-rounding  
    Fix the rounding in the key run time, and show ms after it  
- Fix the rounding in the key run time, and show ms after it  
- Merge pull request #52 from BlueNightSky/patch-1  
    Update zhTW.lua  
- Update zhTW.lua  
- Dropdown update on the framework.  
- Merge pull request #50 from linaori/continue-on-reload  
    Added logic to try and glue together a run after reloading or relogging mid-M+  
- Elaborated the tooltip a bit more  
- Use addon.profile.is\_run\_ongoing instead of addon.IsParsing()  
- Merge pull request #49 from Hollicsh/master  
    Update RU locale  
- Fix markers not resetting OnEnter and OnLeave events  
- Show or Hide an alert when a run has incomplete data due to a reload or relog  
- Added logic to try and glue together a run after reloading or relogging mid-M+  
- Update ruRU.lua  