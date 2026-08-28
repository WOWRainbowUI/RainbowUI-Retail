# Decursive  -Ace3-

## [2.8.3-11-g237fc73](https://github.com/2072/Decursive/tree/237fc7399d15f6fcdbdab10df54549789ebf3e64) (2026-08-26)
[Full Changelog](https://github.com/2072/Decursive/compare/2.8.3...237fc7399d15f6fcdbdab10df54549789ebf3e64) [Previous Releases](https://github.com/2072/Decursive/releases)

- 12.1: use transparent color for unset types (The MUFs do not turn on for disabled curing types)  
    #skipclassic #skipmop #skipbcc  
- fix leaked global and use weak cache when converting color tables to colorMixins  
- Reenable on 12.1  
    Basic compatibility: the MUFs should be lit with the correct color. No livelist, no sound alert for now...  
    #skipclassic #skipmop #skipbcc  
- Very basic 12.1 compatibility inspired by @feelsohigh1998 compatibility addon with some improvements (specific color per spell)  
- 12.1: continue to properly disable scanning features (to be used with @feelsohigh1998 compatibility addon)  
    #skipclassic #skipmop #skipbcc  
- 12.1 fix Lua error when UnitClass is secret...  
    It defaults to Warrior and will affect things like MUFs order priority and exclusion if classes are used as selectors  
    #skipclassic #skipmop #skipbcc  
- (WIP) 12.1 Disable aura scanning functions  
    Print a debug message each time they are called  
    #skipall  
- add secret command to make Decursive load on 12.1  
    #skipall  
- set max toc to 120100 to prevent version expiration message but still not compatible with 12.1  
    #skipclassic #skipmop #skipbcc  
- Ignore new version announcements if more than 1 digit are present in the first number  
    #skipall  
- ... copyright date update  
    #skipall  
