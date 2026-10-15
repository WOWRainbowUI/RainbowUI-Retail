# Auto Potion

## [3.17.2](https://github.com/ollidiemaus/AutoPotion/tree/3.17.2) (2026-10-14)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/3.17.1...3.17.2) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Update for patch 12.1.5 (#135)  
    * Update interface version for patch 12.1.5  
    * Detect class spells without Blizzard's deprecated spellbook functions  
    IsSpellKnown and IsPlayerSpell are deprecated wrappers around C\_SpellBook on  
    Retail, Classic Era, TBC, Mists and Forever and only exist while the  
    loadDeprecationFallbacks CVar is on. Use C\_SpellBook there; Cata and Wrath  
    have no C\_SpellBook version and keep the globals.  
- Show Quality of Life on the information page and reorder the other addons (#134)  
    The "More addons" section now lists Wayscribe, Quality of Life and  
    AutoSetup, in that order.  
    - Media/QoL.tga is Quality of Life's Media/Icon.tga, byte for byte.  
    - Its folder is "QoL" while the title is "Quality of Life", so entries  
      take an optional `folder` for the "Installed" check.  
    - New description string in enUS and deDE.  
- Use the wow-data script in the /update-addon skill  
    The skill now looks up builds, items, spells, tooltips and Blizzard's UI source with wow.py instead of browsing Wowhead and wago.tools. wago\_check.py caches in the wow-data cache by default, so both share downloads.  
