# BetterBags

## [v0.1.49](https://github.com/Cidan/BetterBags/tree/v0.1.49) (2024-05-30)
[Full Changelog](https://github.com/Cidan/BetterBags/compare/v0.1.48...v0.1.49) [Previous Releases](https://github.com/Cidan/BetterBags/releases)

- Update Erros  
    * Fixed a bug where a refresh while in combat would cause the bags to stop updating.  
    * Undid cataclysm keyring update.  
- Item.upgrade.arrows (#386)  
    * Fixed pawn arrows so they load correctly every time.  
    * Added support for SimpleItemLevels upgrade arrow icons.  
- New Item Options (#385)  
    * A new option has been added that lets all incoming items (such as bank items to the backpack) go to Recent Items.  
    * A new option has been added that will add a new item flash to stacks that receive new items in them.  
    * A new option has been added that will unstack transmoged items from virtual stacks into their own stack.  
    * Added support for the keyring in Cata.  
    * Scrapping items in Remix will now correctly open the bag window and unstack items.  
    * Added item fade when moving or removing items from your bag (scrapping, auction house, mail, etc).  
    * Fixed a few random bugs that may have caused Lua errors.  