# Hekili

## [v11.0.2-1.0.14](https://github.com/Hekili/hekili/tree/v11.0.2-1.0.14) (2024-09-16)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.2-1.0.13...v11.0.2-1.0.14) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Recheck timing tweak  
- Iterate on Guardian  
- Improve Fury / integer resource rechecking  
- Fix Cold Blood  
- Merge pull request #3784 from johnnylam88/refactor/protwarr-settings  
    refactor: push some addon settings into the priorities instead  
- Elemental priority and expressions update  
- Fire update  
- Marksman prioirty update  
- Roguery updates  
- Shadow Voidwrath Insanity generation  
- Aug and Dev priority updates  
- Balance update  
- Refine Unholy Sanlayn, update priority  
- Havoc update and merge Immo Aura with Cons Flame  
- Frost DK update  
- refactor: push some addon settings into the priorities instead  
    Change some Protection Warrior settings so they are optionally checked  
    within the priorities instead of directly in the abilities' `usable`  
    functions. In particular, don't force the addon to enforce the settings  
    for the following spells so the usage conditions can be set directly in  
    the priorities:  
    - Last Stand  
    - Rallying Cry  
    - Shield Wall  
    Some of these settings made sense in previous expansions but  
    current SimulationCraft profiles already try to take those extra  
    conditions into account.  
    Add new expressions that can be used in action modifiers:  
    - `last\_stand\_damage\_taken`  
    - `last\_stand\_health\_pct`  
    - `rallying\_cry\_damage\_taken`  
    - `rallying\_cry\_health\_pct`  
    - `shield\_wall\_damage\_taken`  
    - `shield\_wall\_health\_pct`  
    Remove the settings that checked for "damage taken *and* health  
    conditionals" as they can be individually checked within the priorities  
    through the exposed expressions.  
    No changes are made in the default protection warrior priority as Last  
    Stand and Shield Wall are both used offensively in the default priority.  
- Fix #3777  
- Fix Blessing of Anshe / HoW  
- Trinkets  
- Merge pull request #3766 from johnnylam88/feat/snapshot-prev-spells  
    feat: display previous spells in snapshot  
- feat: display previous spells in snapshot  
    Show the previous spells (GCD and non-GCD) when saving a snapshot.  
    This implements #3734.  
- Merge pull request #3765 from fwosar/update-interrupt-filter  
    Update interrupt filter for TWW Season 1  
- Update UI  
- Update filter list  
- Merge pull request #3762 from syrifgit/thewarwithin  
    Blessing of Anshe allows Hammer of Wrath to be cast on any target  
- Blessing of Anshe allows Hammer of Wrath to be cast on any target  
    Fixes:  https://github.com/Hekili/hekili/issues/3760  