# Auto Potion

## [4.0.7](https://github.com/ollidiemaus/AutoPotion/tree/4.0.7) (2026-11-08)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/4.0.6...4.0.7) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Weakest Potion First: optional reversed potion priority for health and mana potions (#170)  
    Two opt-in boxes, both off by default: "Weakest Potion First" on the main  
    page and "Weakest Mana Potion First" on the AutoManaPotion page turn the  
    potion priority around, for leveling.  
    The flavor lists group potions of the same strength in { } groups;  
    ham.potionPriority flattens them, puts zone-locked items (battleground  
    draughts, Windstone, Forever's zone-locked potions) first and, with the  
    setting on, reverses the strength order while each group keeps its order  
    (expiring before plain, plain mana before rejuvenation). Healthstones and  
    mana gems keep their best-first order. wago\_check reads the groups as  
    part of the list around them.  
    Also adds the Potion priority and Weakest potion first glossary entries.  
- updated docs  
- AutoManaPotion uses the best mana gem before the mana potion (#168) (#169)  
    A mage's best mana gem goes first in a castsequence with the best mana  
    potion, reset on combat and after the gem's cooldown as the client  
    reports it. A gem alone is a plain /use. New "Use mana gems" box on the  
    mana potion page (on by default); the preview shows the gem first.  
    Mana gem lists per flavor, best first; "Mana gem" in the glossary.  