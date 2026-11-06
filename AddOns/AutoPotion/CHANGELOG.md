# Auto Potion

## [4.0.6](https://github.com/ollidiemaus/AutoPotion/tree/4.0.6) (2026-11-05)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/4.0.5...4.0.6) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- WoW Forever: use Forever's own food, drink, potions, bandages and Windstone (#167)  
    * WoW Forever: use Forever's own food and drink  
    AutoFood and AutoDrink now know Forever's plain food and drink, Ketharas'  
    Hyjal Stew and Restorative Bread. Nutritious food and drinks, and Filet o'  
    Flank, are buff food: they need "Include Buff Food", and that now also covers  
    the older food Forever turned Nutritious. "Only when the buff is missing"  
    orders AutoDrink by the food buff on Forever.  
    Part of #166  
    * WoW Forever: use Windstone, Tessa's Tonic and Forever's potions and bandages  
    Windstone is used first on Zephras Isle and the Darkspear Islands bandages  
    first on Darkspear Islands; elsewhere the macros leave them out. Perishable  
    potions, Tessa's Tonic and Dense Runecloth Bandage join their lists.  
    Part of #166  
    * wago\_check reports restoring items the addon doesn't list  
    --missing lists them for a flavor's client, leaving out  
    scripts/missing\_skip.json, which keeps each exclusion with its reason.  
    Entries a list adds with table.insert now get the ID and name checks too.  
    Part of #166  
    * WoW Forever: use Forever's Major and Greater Healing Potion in their zones  
    They only work in The Hinterlands, Duskwood, Ashenvale and Feralas, so  
    AutoPotion uses them first there and leaves them out elsewhere. The macros  
    update when you cross into or out of one of these zones.  
    Part of #166  