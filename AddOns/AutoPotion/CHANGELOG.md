# Auto Potion

## [4.1.1](https://github.com/ollidiemaus/AutoPotion/tree/4.1.1) (2026-11-20)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/4.1.0...4.1.1) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Buff kinds: choose which buff food the macro eats (#182) (#185)  
    * Buff kinds: choose which buff food the macro eats (#182)  
    Under "Include Buff Food" on the AutoFood page, one box per buff kind the  
    flavor's buff food and drinks have (Attack Power, Stamina, Haste, Fishing,  
    ..., Other). Buff food or drink with no ticked kind is never eaten; food  
    with several kinds is eaten while one is ticked. Every kind starts ticked  
    (HAMDB.unwantedBuffKinds is empty), so nothing changes until the player  
    unticks one.  
    Each buff food item records its kinds in a buff tag, filled in from client  
    data: the stat auras of the Well Fed the eating spell triggers (Classic Era  
    to Mists, Forever), the stats the eating spell's description names on  
    Retail, where Well Fed is scripted. A flavor whose buff differs has a buff  
    in its own table; such a table now replaces the restore amounts only when  
    it records some. wago\_check.py reports a BUFF line where an item's tag  
    doesn't match the client.  
    * wago\_check: one triggers() test for the spells eating casts  
    Review follow-ups for #182: the trigger condition was written out twice,  
    the NOTE line of the docstring lost its alignment, and a test comment  
    used "Well Fed" for the food buff.  
    * Buff kinds: Retail feasts are Other only  
    A feast's description names Stamina and the highest secondary or primary  
    stat, so its kinds were Stamina + Other: unticking Other alone still ate  
    it. Feasts now count as Other whatever stats they name, as the ticket's  
    story 6 asks; wago\_check.py knows a Retail feast by its description  
    ("Place a ... for all players to enjoy!"). Retail has no Stamina box left.  
- Skip unusable items: below the required level or short of First Aid (#184)  
    * Skip unusable items: below the required level or short of First Aid (#180)  
    Every macro and the preview now treat an unusable item as if it weren't in  
    the bags: item.getCount() reports 0 when the player is below the item's  
    required level (C\_Item.GetItemInfo), or for a bandage above the player's  
    First Aid rank (new firstAid tag, checked by wago\_check.py against  
    ItemSparse.RequiredSkillRank). PLAYER\_LEVEL\_UP and SKILL\_LINES\_CHANGED  
    (when First Aid changed) request a macro rebuild, held until combat ends.  
    Item data not loaded yet and a skill list the client hasn't sent count as  
    usable; Retail has no First Aid and ignores the tag.  
    The fake client gains a level option and Client:levelUp(), requiredLevel on  
    items, a skills option and Client:raiseSkill() with the skill API Classic  
    Era (globals) and Forever (C\_SkillInfo) offer.  
    * Unusable items: rebuild when item data loads or the effective level changes (#180)  
    Review follow-ups: an item whose required level wasn't in the item cache yet  
    gets its macro rebuilt on GET\_ITEM\_INFO\_RECEIVED, and PLAYER\_LEVEL\_CHANGED  
    (Party Sync and the like) updates the level as PLAYER\_LEVEL\_UP does. The  
    spell name shim moves to ham.getSpellName in Core/Spell.lua, shared by  
    Spell, FoodBuff and Item; skillsChanged becomes refreshFirstAidRank. Adds a  
    mana potion test.  
- Retail: leveling conjured food in AutoFood and AutoDrink (#181) (#183)  
    Conjure Refreshment makes a different item by the mage's level on Retail  
    (Mana Cookie, Brownie, Cupcake, Lollipop, Pie, Strudel, Cake, Pudding,  
    Fritter, Bun), all with the Bun's Refreshment spell: full health and mana.  
    Only the Bun was listed, so a leveling mage's cookies were skipped.  
    They now sit next to the Bun in Retail's food and drink lists. The items  
    already defined with Cata/Mists amounts keep them and get a Retail table  
    with the shares (ADR 0001).  
- Glossary: Unusable item and Buff kind; ADR 0002 buff kinds tagged per item  
- Update zhCN.lua (#179)  