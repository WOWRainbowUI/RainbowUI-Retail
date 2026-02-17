# Clique

## [v4.6.5-release](https://github.com/jnwhiteh/Clique/tree/v4.6.5-release) (2026-02-16)
[Full Changelog](https://github.com/jnwhiteh/Clique/compare/v4.5.3-release...v4.6.5-release) [Previous Releases](https://github.com/jnwhiteh/Clique/releases)

- Update some of the included text files  
- Better .gitattributes for working across Mac (work) and Windows WSL (home)  
- File mode changes  
- Revert "Only convert menu on Blizzard frames"  
- Only convert menu on Blizzard frames  
- Add GamePad binding support  
    Add an enableGamePad setting that controls whether gamepad buttons can  
    be used in click-cast bindings. When enabled, frames receive gamepad  
    input via EnableGamePadButton and the config UI captures gamepad keys  
    for binding assignment. When disabled, gamepad bindings are filtered  
    out of attribute generation and shown as disabled in the browse list.  
- Convert *type2 menu to togglemenu when AnyDown is active  
    The blizzard default "menu" action won't work except on Up clicks,  
    but we can use the togglemenu action. When the down click behaviour  
    is on, we just convert any explicit wildcard entries to togglemenu.  
- Add new downClick and wipe options  
- Ignore CLAUDE.md  
- Add a working CLAUDE.md used for testing, etc.  
- Exclude some files in packaging  
- Make Change Binding button a bit more prominent  
