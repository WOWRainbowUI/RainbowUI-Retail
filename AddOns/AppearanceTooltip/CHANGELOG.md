# AppearanceTooltip

## [v60](https://github.com/kemayo/wow-appearancetooltip/tree/v60) (2025-07-24)
[Full Changelog](https://github.com/kemayo/wow-appearancetooltip/compare/v59...v60) [Previous Releases](https://github.com/kemayo/wow-appearancetooltip/releases)

- Don't disable the zoom-on-held config option in classic, as it works  
- Fix double-display of held items when zoomed in  
    Apparently TryOn now causes an issue when called alongside  
    SetItemAppearance, when previously they could coexist.  
    This also removes the 0 second timer from 9fbf73287f as it doesn't seem  
    to be necessary for zoomed out display any more.  
    Fixes #28  
- When previewing a token, make sure a relevant item is shown if one exists  
