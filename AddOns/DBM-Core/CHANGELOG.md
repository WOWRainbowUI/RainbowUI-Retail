# DBM - Core

## [12.0.50](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.50) (2026-05-17)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.49...12.0.50) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Tighten yell guards to catch more mistakes as well as just better document yell object  
    Prep new tag with force version upgrade due to final deprecation and removal of backwards compat code for mods using old journal formaters.  
- Update translations (#2082)  
- And the legacy regular announce object too  
- Allow spell renaming to work on older Special warning objects too  
- Allow icon override. Closes https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2081  
- Update translations (#2079)  
- Update koKR (#2080)  
- Template new news message  
- small tweak to note text parsing before sending to DBM\_Announce callbacks  
- Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2074  
- Update koKR (#2078)  
- Update localization.tw.lua (#2077)  
- Update language away from "shortnames when available" to "spell renames" where appropriate  
- Update Rename, Reset, and Test buttons to dynamically scale to text width. This corrects issues with buttons being too large or too small for text depending on localization.  
- DBM unlock command now also unlocks private aura anchor previews  
    DBM unlock no longer shows range frame  
- Update translation (#2073)  
    * Update translations  
- Add spell rename only import/export feature (#2076)  
    * Add spell rename only import/export  
- Add sound to legacy warning  
- Move DBM over to C\_EncodingUtil (#2075)  
    * Move DBM profiles over to C\_EncodingUtil in favor of blizzards faster internal features. Backwards compatibility maintained for import only with deprecation message.  
- bump alpha  
