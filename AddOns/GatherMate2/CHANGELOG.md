# GatherMate2

## [1.52.4](https://github.com/Nevcairiel/GatherMate2/tree/1.52.4) (2026-10-22)
[Full Changelog](https://github.com/Nevcairiel/GatherMate2/compare/1.52.3...1.52.4) [Previous Releases](https://github.com/Nevcairiel/GatherMate2/releases)

- Update TOC  
- Add separate minimap icon alpha setting  
    This adds independent alpha controls for world-map and minimap node icons.  
    Previously, the existing world-map alpha setting was also applied to minimap pins. This made it difficult to reduce the opacity of GatherMate2’s minimap tracking circles without also fading icons on the world map.  
    Changes:  
    - Add a separately saved minimapAlpha preference.  
    - Add distinct “World Map Icon Alpha” and “Minimap Icon Alpha” controls.  
    - Apply minimapAlpha only to minimap pins.  
    - Preserve the existing alpha preference for world-map icons, maintaining backward compatibility.  
    This makes active gathering-node blips easier to distinguish from GatherMate2’s nearby spawn indicators.  
- Updates for Coiled Isle  
    Co-authored-by: Leon <FireAllianceNX@users.noreply.github.com>  
    Co-authored-by: Hendrik Leppkes <h.leppkes@gmail.com>  
- Check for secret target in Collector:SpellStarted  
    Opening a Mislaid Curiosity treasure in a delve throws this on every cast. Even the check for spellcast secret wasn't enough - the target also needed checked. This adds `issecretvalue(target)` to the same early return.  
    ```  
    GatherMate2.lua:527: attempted to index a table that cannot be indexed with secret keys  
    [GatherMate2.lua]:527: in function 'GetIDForNode'  
    [Collector.lua]:222: in function '?'  
    ```  
- Add separate locale for the vanilla names of nodes  
    Blizzard renamed these in some locale (deDE, maybe more) during late  
    vanilla, but classic and forever use the old names, so add an override  
    here to allow both names to be used.  
    Fixes #62  
- More secrets protection  
- Hide options for other gather types on Forever  
- Only load locale files on their matching client  
    Always load english as fallback.  
- Update TOC for future 12.1.5 support, and only loading on mainline clients  
- Only load retail storage mods on Standard client  
- Add WoW Forever support and skip spells missing on the client  
    Add interface 16001 for the WoW Forever client, which shares the Mainline API.  
    Not every client knows every spell, eg. spell 195122 does not exist on Forever,  
    so C\_Spell.GetSpellName returned nil and the spells table was built with a nil  
    key, which raised "table index is nil" at load time. Build the table from a list  
    and skip entries whose spell name failed to resolve.  
