# Auto Potion

## [3.16.5](https://github.com/ollidiemaus/AutoPotion/tree/3.16.5) (2026-10-06)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/3.16.4...3.16.5) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Update version to 3.16.5 in AutoPotion.toc  
- Add AutoManaPotion macro and settings page (#127)  
    Maintains an AutoManaPotion macro that uses the mana potion in the bags  
    restoring the most mana. Per-flavor lists (Retail, Classic, TBC, Wrath,  
    Cata, Mists, Forever) were researched on Wowhead and sorted by mana  
    restored on each flavor's own numbers.  
    Adds an AutoManaPotion sub-page to the settings with a priority preview  
    and an "Include Rejuvenation Potions" toggle (health + mana potions).  
    Channeled, side-effect and zone-locked potions are excluded.  
- Skip saved spells that are no longer offered when building the macro (#128)  
    Saved settings can still hold ids for spells we've stopped offering, such as  
    Fortitude of the Bear (a passive since 12.0). Users can't untick them any more  
    and IsSpellKnown returns true for the passive, so it ended up in the macro and  
    blocked potions/healthstones for Hunters with a Tenacity pet. Only use saved  
    ids that are in ham.supportedSpells (groups expanded to their members).  