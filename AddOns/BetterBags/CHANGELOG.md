# BetterBags

## [v0.1.8](https://github.com/Cidan/BetterBags/tree/v0.1.8) (2024-02-24)
[Full Changelog](https://github.com/Cidan/BetterBags/compare/v0.1.7...v0.1.8) [Previous Releases](https://github.com/Cidan/BetterBags/releases)

- Ported sizing code to Classic. (#225)  
- Fixed a bug with normal textures showing up as squares. (#222)  
- Masque Integration Update (#221)  
    * Masque integration is now evented instead of in-line.  
    * Item frame resizing now resizes all properties manually.  
- Fixed a lua error when selling items with bag slots open. (#220)  
- Tutorial Fix  
    * Fixed some tutorials that would not go away/could not be dismissed.  
- Bugfix.0.1.8 2 (#216)  
    * Fixed a bug with pawn integrations setting upgrade status on invalid items.  
    * Overhaul of the debug log frame -- no longer lags and can infinite scroll.  
    * Added a forced refresh all when sorting bags.  
    * Fixed a bug in new item detection that would cause weird issues with new items.  
    * Forcefully check for new items that don't belong as new items.  
- Search Expanded (again!) (#212)  
    * Added optional in-bag search for bank and bag.  
    * Fixed a few bugs around categories not refreshing for bags.  
- Bugfix 0.1.8 (#205)  
    * Fixed a bug when dragging and dropping items with an item level that would cause the item level to appear on other items.  
    * Added currency and money delimiters.  
    * Gems should no longer show an ilevel if they are stacked.  
    * The addon will now display the current version in the context window.  
    * Gear Sets for WotLK have been implemented.  
    * The much loved, and missed, Pawn item level icon has returned for all versions of WoW.  
    * Using items no longer causes frames to skip/the game to lag.  
    * Fixed a bug where the bags would error out if bags changed in any way during combat.  
- feat: create alpha release workflow (#170)  
