# LOIHLoot

## [11.2.0.1](https://github.com/ahakola/LOIHLoot/tree/11.2.0.1) (2025-08-17)
[Full Changelog](https://github.com/ahakola/LOIHLoot/compare/11.2.0...11.2.0.1) [Previous Releases](https://github.com/ahakola/LOIHLoot/releases)

- Update localization files  
    - Feel free to contribute at https://legacy.curseforge.com/wow/addons/loihloot/localization  
    - PM me after you have finished, so I can get the changes pushed out asap!  
- Return localized subTable name for itemId from API  
- Fast exit if no itemId is provided  
- Merge pull request #3 from Road-block/master  
    Mists Classic Fixes & Query Wishlist for Item API  
- indentation  
- Export :IsItemWishList(itemID) API, closes #2 (if accepted)  
- Mists Classic, link parsing is broken, add a workaround (retail handling unaffected)  
    Switch to using C\_Item.GetItemInfoInstant, no reason to risk uncached items if not using any of the payload fields  
    remove obsolete template from blizzard option panel creation  
    Fix scanning tooltip (not used anywhere atm, but better safe than sorry)  
