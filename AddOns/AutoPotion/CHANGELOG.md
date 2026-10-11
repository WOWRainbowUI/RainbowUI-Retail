# Auto Potion

## [3.17.1](https://github.com/ollidiemaus/AutoPotion/tree/3.17.1) (2026-10-10)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/3.17.0...3.17.1) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Fix wrong item IDs, sort lists by amount restored and add a wago.tools item check (#133)  
    * Remove wrong and unavailable item IDs  
    Checked every item against the game client data on wago.tools:  
    - Fleeting Invigorating Healing Potion only exists at quality 3 (244849).  
      The quality 2 and 1 IDs were Severed Threads Commendation, a  
      reputation token the macro would have used up, and a quest item.  
    - Crystal Flake Throat Lozenge doesn't exist in TBC Anniversary.  
    - Fatty Bluefin can only be eaten underwater in Wrath Classic, so the  
      macro would fail on land. It stays in the Cata and Mists lists, where  
      it is normal food.  
    - Winter Veil Candy and Winter Veil Loaf are unused items in WoW Forever.  
    - Drop a second, identical Mingo's Fortune Giblets definition.  
    * Sort potion, food and drink lists so the strongest item is used first  
    Each list section is now sorted by the amount it restores in that  
    flavor's client (from the game data on wago.tools), keeping the existing  
    order between items that restore the same amount. Notable changes:  
    - Retail: Fleeting potions now sit next to the normal potion of the same  
      quality (Silvermoon, Cavedweller's Delight), vendor food is ordered  
      6%/5%/4% per second instead of alphabetically, and Conjured Tea comes  
      before the weaker Conjured Mana Bun in the drink list.  
    - Wrath/Cata/Mists: Crazy Alchemist's Potion heals less than Runic  
      Healing Potion and moves below it.  
    - TBC: Super Rejuvenation Potion heals more than Healing Potion Injector.  
    - Healthstone lists: Lily Root and Crystal Flake Throat Lozenge sit with  
      the healthstones they match; in Forever the plain healthstones heal as  
      much as the talented ones and move above the middle rank.  
    - Cata: conjured food goes Mana Cake, Lollipop, Cupcake, Brownie,  
      Cookie (was alphabetical, so a level 44 Brownie came first).  
    - Wrath: Conjured Mana Strudel before Conjured Mana Pie.  
    - Several Classic to Mists food and water tiers were mixed up.  
    The lower-level fallback at the end of the TBC, Wrath, Cata and Mists  
    food and drink lists is rebuilt from the sorted older lists, with a  
    comment for each copied section. Sections that are deliberately unsorted  
    (Well Fed food) now say "order doesn't matter".  
    * Add a wago.tools item check to the update-addon skill  
    wago\_check.py checks every item in the priority lists against the game  
    client data of each flavor in AutoPotion.toc: the ID exists in that  
    flavor, its name matches (a mismatch means a wrong ID), it is a  
    consumable, its R1/R2/R3 suffix matches its crafting quality, and each  
    list section is sorted by the amount restored. --dump prints the amount  
    of every list entry, to place new items. Downloads are cached.  
    The skill now runs it in the verify step and documents the list  
    sections and the lower-level fallback copies.  
    * Update the README for the food, drink and mana potion macros  
    - Describe the AutoFood and AutoDrink macros (conjured first, optional  
      buff food, lower-level fallback) and their settings, and list all five  
      macros wherever the README named only some of them.  
    - The addon creates its macros itself, so the quick start no longer  
      asks you to create them by hand.  
    - Add TBC Anniversary to the supported versions and name Midnight for  
      Retail.  
    - Mention that every list is sorted strongest first for your game  
      version, that Fleeting potions are used first, and the Silvermoon  
      potions.  