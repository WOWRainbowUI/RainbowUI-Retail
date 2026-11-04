# DBM - Core

## [12.1.19](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.19) (2026-11-03)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.18...12.1.19) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- bump version  
- Update koKR (#2271)  
    Update koKR  
- GTFO override will now also apply to GTFO style aura sounds  
- tweak CHAT\_MSG debug  
- Fix panel rendering hitch caused by excessive re-validation of dropdown media added in Oct 30th commits  
- fix alignment regression  
- Add ability to set auto release per boss, with Ulatek being only one it's on by default for  
- cleanup objective frame hiding for all game versions, and enable questie hiding in more than just era  
- Allow Announce, Special Announce, and timers more color options (#2270)  
    * Allow Announce, Special Announce, and timers to customize colors (including user inputed one) on a per warning and timer basis  
- Fine, I won't annotate it because of nitpick BS  
- Test button on special announce objects now plays custom media path if one is set  
- Also allow voice pack sound selection in special announce sound override dropdowns  
- Add GTFO override options (#2269)  
    * Add GTFO override options  
- Enable the objective hider for all  
- Fix toc load directive for libspec so it actually loads in forever  
- Fix text alignment on consume frame  
- Finally fix initial interrupt alert firing at wrong time on explorers by working around blizzard bug where tehy send 5 second timer for an instant cast on phase change. now we ignore the 5 second timer and just treat it as an instant cast it is.  
    tweak audio on ulatek  
- bump alpha  
