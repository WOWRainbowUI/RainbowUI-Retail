# Details! Damage Meter

## [Details.20261124.15450.172](https://github.com/Tercioo/Details-Damage-Meter/tree/Details.20261124.15450.172) (2026-11-24)
[Full Changelog](https://github.com/Tercioo/Details-Damage-Meter/compare/Details.20261109.15410.172...Details.20261124.15450.172) 

- Release 15450  
    New:  
    - New profile option "Keep Size of Grouped Windows": windows grouped together keep their own width and height instead of matching each other. It needs "Save Size and Position" turned on. (Tercio)  
    - "Animate Bars" has moved from General options to the Bars section of the window designer. (Tercio)  
    Fixes:  
    - Windows set to hide "While out of combat" now hide properly after combat, and no longer flash for a moment before hiding. (Tercio)  
    - Fixed a Lua error when clicking to view a damage report (the compare tab). (Tercio)  
    - The breakdown window can no longer be opened in combat, and any open breakdown window closes when combat starts. (Flamanis)  
    - Fixed the tooltip position and the click effect on the class icon of a bar. (Flamanis)  
    - Deaths display: players with no death record are no longer listed, and the time of death shows "??" when the game hides it. (Tercio)  
    - Window 2.0: fixed the text outline setting "None", which the game no longer accepts. (Tercio)  
    - Fixed the "Default" font choice in font lists. (Flamanis)  
    - Window designer: removed the ":" after option names. (Tercio)  
    - Framework updated. (Tercio)  
- Fix automation "While out of combat".  
- Fix discord issue: "Lua Error when clicking to view damage report"  
- Framework update  
- Window 2.0 outline fix  
- Remove font from default font listing since font loading handles nil font  
- Fix tooltip anchor and breakdown being openable in combat.  
- General fixes  
