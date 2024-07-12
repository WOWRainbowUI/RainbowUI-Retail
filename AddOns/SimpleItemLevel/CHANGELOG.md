# Simple Item Level

## [v36](https://github.com/kemayo/wow-simpleitemlevel/tree/v36) (2024-06-10)
[Full Changelog](https://github.com/kemayo/wow-simpleitemlevel/compare/v35.1...v36) [Previous Releases](https://github.com/kemayo/wow-simpleitemlevel/releases)

- Add API for ItemLevelColorized  
    Refs #39  
- Clean up some deprecated wow-api calls  
- Remove a bunch of no-longer-needed classic-compatibility for Settings  
- Document the flyout compatibility returns a bit better for myself  
- Luacheck: ignore 231 local variable is set but never accessed  
    Also, it's weird that ebc901f0 caused it to *start* complaining about  
    that, since it was just as never-accessed before. Presumably it tracks  
    them differently if they're set in a function return versus other sets.  
- Classic compatibility on equipment flyouts  
    It doesn't have a voidstorage return  
- Make sure an item exists in ItemIsUpgrade  
    Fixes #38  
- Apply to all item flyouts, not just the character-frame ones  
    Pandaria Remix item-upgrades finally got to me  
- Start of an API for requesting data  
- Deprecation-wrapper for GetItemStats was erroring, so switch away  
- Remove an accidental global  
- Request equipped item data be cached before inventories get opened  
- Use new data extraction in more places  
- Pull out some overlay data gathering for easier reuse  
- Use Baganator's API (finally) rather than crudely hooking into it  
    You'll probably need to explicitly go add these in Baganator's settings  
    after this change.  
    Refs #35  
