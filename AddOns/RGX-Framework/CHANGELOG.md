# RGX-Framework

## [v1.3.0](https://github.com/DonnieDice/RGX-Framework/tree/v1.3.0) (2026-04-25)
[Full Changelog](https://github.com/DonnieDice/RGX-Framework/compare/v1.0.2...v1.3.0) [Previous Releases](https://github.com/DonnieDice/RGX-Framework/releases)

- Remove version number from README — version is in TOC and CHANGES  
- v1.3.0 — lifecycle hooks, output helpers, Mixin, self-contained timers  
    - RGX:OnReady(fn) / RGX:IsReady() lifecycle system; queued callbacks fire in order after ADDON\_LOADED init  
    - RGX:Print / RGX:Warn / RGX:Error with colored [RGX] prefix  
    - RGX:Mixin(target, ...) object composition utility  
    - Dropdowns ForceWidth migrated from C\_Timer.After to RGX:After — framework fully self-contained  
    - Fonts:Apply hardened with fallback path and size guards  
    - Minimap tooltip supports dynamic getLines callback alongside static lines table  
    - README updated: v1.3.0, new API sections, Ace3 framing as alternative not replacement  
    - ROADMAP rewritten: current module status, profile system design, SharedMedia drop-in plan, pack system, BLU migration path  
- v1.2.0 — RGXDataBroker, options panel banner/onSelect, new modules  
    New modules: RGXDataBroker (drop-in LibDataBroker-1.1 replacement, no  
    LibStub), RGXSharedMedia, RGXDesign, RGXCombat, RGXReputation, RGXMinimap,  
    RGXPetBattles. RGXUI:CreateOptionsPanel gains banner/bannerHeight support  
    (styled frame between header and tabs) and per-tab onSelect callbacks.  
    Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>  
- enhance core: convenience module getters, improved RequireModule, table/string utils  
    - Add RGX:GetFonts/Colors/Textures/Dropdowns/UI/ColorPicker() shortcuts  
    - RequireModule now logs an error when the module is missing (distinct from GetModule)  
    - Remove duplicate RGX:TableCount from utils.lua (already in core.lua)  
    - Add table helpers: TableValues, TableContains, TableMap, TableFilter, TableFind, MergeTable  
    - Add string helpers: Format, StartsWith, EndsWith  
    - Add version helpers: IsRetail, IsClassicEra  
    - Update header doc with full quick-start API reference  
    Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>  
