# World Quest Tracker

## [v12.0.1.549](https://github.com/Tercioo/World-Quest-Tracker/tree/v12.0.1.549) (2026-02-25)
[Full Changelog](https://github.com/Tercioo/World-Quest-Tracker/compare/v12.0.1.548...v12.0.1.549) 

- Framework update  
- Merge pull request #143 from ptarjan/fix/wow-12-secret-values  
    Fix WoW 12.0 secret value errors in tooltips  
- Fix WoW 12.0 secret value errors in tooltips  
    In WoW 12.0 (Midnight), quest reward APIs can return "secret values"  
    that cannot be used in arithmetic or string operations. This causes  
    errors in MoneyFrame and GameTooltip when hovering over world quests.  
    Changes:  
    - Wrap GameTooltip\_AddQuest in pcall to prevent taint from secret  
      values propagating through the tooltip system  
    - Add issecretvalue guards before comparing quest reward values  
      (XP, money, artifact XP, currency counts, item counts)  
    - Wrap SetTooltipMoney in pcall as a defense-in-depth measure  
    Fixes #142, helps with #141  
    Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>  
