# BetterBags

## [v0.1.66](https://github.com/Cidan/BetterBags/tree/v0.1.66) (2024-06-23)
[Full Changelog](https://github.com/Cidan/BetterBags/compare/v0.1.65...v0.1.66) [Previous Releases](https://github.com/Cidan/BetterBags/releases)

- Fixed an out of bounds error with item rows and column counts in config. (#429)  
    * Fixed a few small lua errors that can appear when configuring bags.  
    * Removed reagents bag items forced into reagent category, this will return as an option later on.  
    * Columns are now much better balanced.  
- Fixed a bug where Recent Items would overlap with the top row.  
- Fixed bag errors when window is resized.  
    Bag view now always shows 12 items across.  
