# Details! Damage Meter

## [Details.20240115.12220.155](https://github.com/Tercioo/Details-Damage-Meter/tree/Details.20240115.12220.155) (2024-01-15)
[Full Changelog](https://github.com/Tercioo/Details-Damage-Meter/compare/Details.20231229.12197.155...Details.20240115.12220.155) 

- Color Picker for 10.2.5; Tagging version as Release  
- Merge pull request #665 from Flamanis/Ignore-Smoldering-Seedling-Healing  
    Ignore healing to the Smoldering Seedling spawned by the trinket.  
- General Updates  
    - Fixed an error while scrolling down target npcs in the breakdown window.  
    - Fixed an error when clicking to open the Death Recap by Details!.  
    - End of Mythic Run panel got updates.  
    - Framework updated: new rounded tooltips.  
- Ignore healing to the Smoldering Seedling spawned by the trinket.  
- Fix  
- General Changes ad Improvements  
    - Added: Details:IsInMythicPlus() return true if the player is on a mythic dungeon run.  
    - CombatObjects now have the key 'is\_challenge' if the combat is a part of a challenge mode or mythic+ run.  
    - Evoker extra bar tooltip's, now also show the uptime of Black Attunement and Prescience applications.  
    - Breakdown Window now show Plater Npc Colors in the target box.  
    - Added event: "COMBAT\_MYTHICPLUS\_OVERALL\_READY", trigger when the overall segment for the mythic+ is ready.  
    - Added event: "COMBAT\_PLAYER\_LEAVING", trigger at the beginning of the leave combat process.  
    - Library updates: Details! Framework and Lib Open Raid.  
- Merge pull request #620 from Flamanis/JudgementWrath  
    Attribute Judgement of Light to the healed on Wrath  
- Merge pull request #663 from Flamanis/Fix-one-segment-battleground-on-era  
    Use correct battleground scores for ERA  
- Update parser.lua  
- Attribute Judgement of Light to the healed on Wrath  
