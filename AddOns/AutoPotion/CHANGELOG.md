# Auto Potion

## [3.7.3](https://github.com/ollidiemaus/AutoPotion/tree/3.7.3) (2024-10-26)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/3.7.2...3.7.3) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Update AutoPotion.toc  
- Combat checks (#61)  
    * add a stopcasting option  
    * db option  
    * update macroStr  
    * tweak text  
    * additional checks to ensure player is not in combat before EditMacro() is called  
    * reduce wait to 0.5 seconds after player\_regen event | wrap editmacro() in pcall() to suppress LUA warnings  