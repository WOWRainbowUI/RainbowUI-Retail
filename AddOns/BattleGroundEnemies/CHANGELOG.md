# BattleGroundEnemies

## [11.2.0.6](https://github.com/BullseiWoWAddons/BattleGroundEnemies/tree/11.2.0.6) (2025-08-18)
[Full Changelog](https://github.com/BullseiWoWAddons/BattleGroundEnemies/compare/11.2.0.5...11.2.0.6) [Previous Releases](https://github.com/BullseiWoWAddons/BattleGroundEnemies/releases)

- fix: update version to 11.2.0.6 and add detailed changelog entries for bug fixes  
- fix: remove error in setting custom player count profile to defaults of normal profiles  
- fix: rename variable for clarity in addEnemyAndAllySettings function  
- fix: remove unnecessary enabling and disabling of mainframe in CreateMainFrame function  
- fix: add config nil check in AfterFullAuraUpdate function  
- fix: prevent drag actions during combat lockdown in CreatePlayerButton function  
- fix: add config nil check in UpdateRangeViaLibRangeCheck function  
- fix: remove duplicate counter table on mainframe  
- fix: correct indentation in CreatePlayerButton function  
- refactor: remove unused GetTexCoordsForRoleSmallCircle function  
- fix: remove unnecessary Show/Hide calls in Disable and Enable functions  
- Move Disable func to the bottom, this cause the scroll targeting functionality to not work... Also mainframe's parent is UIParent now  
- feat: add PLAYER\_REGEN\_DISABLED event handling to manage test/edit mode  
