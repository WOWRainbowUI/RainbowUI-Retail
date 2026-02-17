# DBM - Core

## [12.0.21](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.21) (2026-02-17)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.20...12.0.21) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- no message  
- Fix  a preview issue and add missing options to "Reset to defaults" (#1917)  
    * Fix icons not showing again after increasing the limit in preview  
    * add missing settings to the Reset to defaults  
- Add missing keystone names for midnight  
- Update text  
- tweak defaults for upscalers to true by default  
- Make settings changes in private auras settings apply instantly to preview.  
    Added checkbox for duration text upscaling.  
- Update koKR (#1915)  
    * Update koKR  
- Update localization.tw.lua (GUI) (#1914)  
- Update localization.tw.lua (Core) (#1913)  
- Upd RU locales (#1912)  
    * Update localization.ru.lua  
- Fix private aura issues (#1916)  
    * Add UpscaleDuration setting in Core  
    * fix frame not rescaling in preview  
    * add ClearAllPoints in a bunch of spots  
    * add function that can be run when user changes a setting to have the preview updated immediately  
- Polish up PA GUI more. just a couple more things missing but it's in a pretty usable state now  
    Also, sorry localizers. More strings and some changed.  
- Some option text clarifications  
- Fix GUI panel rendering  
    increase amount of time to move PA frame  
- fix bad localization lookups  
- Begin GUI work  
- and make global disables for PA only visible on retail  
- Also unhide global disable for countdowns, and make the new objects honor it too  
    Move private auras to a new category in global disable and move sound option there  
    Add a new option to globally disable the PA frame to same spot as above.  
- fix global disable for private aura sounds being missing from midnight UI  
- prune obsolete/fix luals  
- Prep finalized localization strings for PrivateAuras GUI options and move text.  
- more conservative defaults  
- Use built in tank check function  
- better LuaLS param for PAs frame  
- scope private aura stuff to retail only  
- cleanup deprecated code and some boss mods a little  
- just use standardFont for font  
- satisfy LuaLS  
    allow RegisterAllUnits to work in dungeons and only iterate based on actual group size total instead of 40  
- Add Private Aura Anchors (#1910)  
    * Add initial private aura Support  
- Update localization.ru.lua (#1911)  
    * Update localization.ru.lua  
    * Update localization.ru.lua  
- Cosmetic fix for uniformity  
- Fix some slight UI clipping  
- Small fix to options panel  
- Several Sound Updates:  
     - Fixed a bug where if media path was set to none, private aura sounds could still be incorrectly registered  
     - Fixed a bug where if media path was set to none, cast alert sounds could also be incorrectly registered  
     - Fixed a bug where the "Show Example" button on special announce configuration would fail to actually play sound or show screen flash  
     - Changed default emphasis of blizzard "medium" alerts from SA 2 to SA 1 instead  
     - Changed default emphasis of blizzard "critical" alerts from SA 3 to SA 2 instead  
     - Re-enabled sound configuration options on retail to once again show SA 1 and SA 4 since they are in use again for custom alert sounds when users disable voice packs.  
     - Clarified dropdown menus in boss mods to signifiy that if a voice pack is enabled, SA 1-4 actually play voice pack media and not SA 1-4  
- Update localization.cn.lua (#1908)  
- Fix bug still causing regular announce object generic sounds to play over voice pack sounds. When custom sounds are enabled, the generic defaults should be supressed as intended  
- also forgot to bump alpha  
- Remove unused  
