# Astral Keys

## [4.42](https://github.com/astralguild/AstralKeys/tree/4.42) (2026-02-03)
[Full Changelog](https://github.com/astralguild/AstralKeys/compare/4.40...4.42) [Previous Releases](https://github.com/astralguild/AstralKeys/releases)

- Up version to 4.42 and do minor refactor  
- Update AstralKeys.toc  
- Merge pull request #139 from seanpeters86/patch-2  
    Fix tooltip Lua error by removing Unit API calls from TooltipDataProcessor hook  
- Fix tooltip Lua error by removing Unit API calls from TooltipDataProcessor hook  
    This PR fixes a recurring Lua error triggered when hovering units in the Friends / world tooltips in modern WoW.  
    Blizzard’s `TooltipDataProcessor` runs in a restricted execution context where Unit* APIs (UnitIsHumanPlayer, UnitExists, UnitIsPlayer, etc.) are no longer permitted. AstralKeys was calling these APIs inside a TooltipDataProcessor.AddTooltipPostCall, causing hard Lua errors when the tooltip was refreshed.  