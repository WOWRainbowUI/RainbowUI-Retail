# BattleGroundEnemies

## [11.0.2.0](https://github.com/BullseiWoWAddons/BattleGroundEnemies/tree/11.0.2.0) (2024-08-15)
[Full Changelog](https://github.com/BullseiWoWAddons/BattleGroundEnemies/compare/11.0.0.0...11.0.2.0) [Previous Releases](https://github.com/BullseiWoWAddons/BattleGroundEnemies/releases)

- update changelog for 11.0.2.0  
- bumb toc to 11.0.2 (110002)  
- update luacheck list  
- GetSpellBookSkillLineInfo changes  
- GetSpellTabInfo got renamed to GetSpellBookSkillLineInfo  
- GetSpellTabInfo is also inside C\_SpellBook  
- fix copypaste mistake, GetNumSpellBookSkillLines and GetSpellBookItemName belongs to C\_SpellBook  
- use C\_AddOns.GetAddOnMetadata instead of GetAddOnMetadata  
- add fix for removal of UnitAura, use C\_UnitAuras.GetAuraDataByIndex  
     instead  
- GetTexCoordsForRoleSmallCircle got removed, add it locally  
