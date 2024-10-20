# Premade Groups Filter

## [6.5.3](https://github.com/0xbs/premade-groups-filter/tree/6.5.3) (2024-10-19)
[Full Changelog](https://github.com/0xbs/premade-groups-filter/compare/6.4.0...6.5.3) [Previous Releases](https://github.com/0xbs/premade-groups-filter/releases)

- Update README  
- Remove debug code for cancelOldestApp feature  
- Move info frame for cancelOldestApp below hovered group (see #163)  
- Fixes for cancelOldestApp feature (see #163)  
    * Cancel the oldest instead of the latest application  
    * Set opacity from 80% to 30%  
    * Do not cancel on right click  
    * Fix attempt to cancel already canceled groups  
    * Fix nil pointer error  
- Ignore screenshots in package to reduce size  
- Merge pull request #295 from nanjuekaien1/patch-3  
- Update zhCN.lua  
- Update zhCN.lua  
- Merge pull request #294 from Hollicsh/patch-1  
- Micro update RU locale  
    More correctly  
- New option to apply to groups continuously by automatically canceling the oldest application (see #163)  
    Change rolling applications to show cancel suggestion first  
    Add option to enable cancelOldestApp feature  
    Add translations for cancelOldestApp feature  
- Merge pull request #292 from Hollicsh/patch-7  
- Micro update RU locale  