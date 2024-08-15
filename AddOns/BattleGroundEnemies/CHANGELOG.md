# BattleGroundEnemies

## [11.0.0.0-8-gbccd6aa](https://github.com/BullseiWoWAddons/BattleGroundEnemies/tree/bccd6aa97c014e4e74e4f5cec350b6e7ce5e40a4) (2024-08-14)
[Full Changelog](https://github.com/BullseiWoWAddons/BattleGroundEnemies/compare/11.0.0.0...bccd6aa97c014e4e74e4f5cec350b6e7ce5e40a4) [Previous Releases](https://github.com/BullseiWoWAddons/BattleGroundEnemies/releases)

- update luacheck list  
- GetSpellBookSkillLineInfo changes  
- GetSpellTabInfo got renamed to GetSpellBookSkillLineInfo  
- GetSpellTabInfo is also inside C\_SpellBook  
- fix copypaste mistake, GetNumSpellBookSkillLines and GetSpellBookItemName belongs to C\_SpellBook  
- use C\_AddOns.GetAddOnMetadata instead of GetAddOnMetadata  
- add fix for removal of UnitAura, use C\_UnitAuras.GetAuraDataByIndex  
     instead  
- GetTexCoordsForRoleSmallCircle got removed, add it locally  
