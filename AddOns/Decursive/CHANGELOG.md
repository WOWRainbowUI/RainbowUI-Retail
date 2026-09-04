# Decursive  -Ace3-

## [2.8.3-25-g9cacdb5](https://github.com/2072/Decursive/tree/9cacdb5de21db22fddf625c6d792215679f0edaa) (2026-09-02)
[Full Changelog](https://github.com/2072/Decursive/compare/2.8.3...9cacdb5de21db22fddf625c6d792215679f0edaa) [Previous Releases](https://github.com/2072/Decursive/releases)

- Add installation corruption guard/alert to Dcr\_12\_1\_Sounds.lua  
    #retailOnly  
- Restore protected affliction sounds on WoW 12.1  
- Move the 12.1 dispel cooldown onto the MUF grid  
- Show dispel cooldowns on 12.1 unit frames  
- Suppress false empty-dispel message on 12.x  
- Restore 12.1 dispel priority workflow  
- 12.1: Fix Decursive macro creation failure because Blizzard removed the global MAX\_ACCOUNT\_MACROS  
    Just use a pcall around CreateMacro...  
    #retailOnly  
- 12.1: UnitClass can return secret values on the `focus` unitID -> wrap and harden these calls and default to WARRIOR when secret  
    #retailOnly  
- ... fix packager tag for skipping all classic version  
- 12.1: Restore charmed unit detection  
    #skipallclassic  
- Configure wrath packaging for Titan Reforged compatibility (thanks to WidgetA)  
    #skipretail #skipclassic #skipmop #skipbcc  
- Merge branch 'agent/add-titan-38002-support' of https://github.com/WidgetA/Decursive  
- 12.1: use transparent color for unset types (The MUFs do not turn on for disabled curing types)  
    #skipclassic #skipmop #skipbcc  
- fix leaked global and use weak cache when converting color tables to colorMixins  
- Reenable on 12.1  
    Basic compatibility: the MUFs should be lit with the correct color. No livelist, no sound alert for now...  
    #skipclassic #skipmop #skipbcc  
- Very basic 12.1 compatibility inspired by @feelsohigh1998 compatibility addon with some improvements (specific color per spell)  
- 12.1: continue to properly disable scanning features (to be used with @feelsohigh1998 compatibility addon)  
    #skipclassic #skipmop #skipbcc  
- Fix WotLK-era spell data for Titan Reforged clients  
    /dcrdiag on a Titan Reforged (3.80.2, TOC 38002) client reported three  
    spells that do not exist there, because the WoW Classic branch of the  
    spell table only knows about Classic Era / BCC:  
     - Cure Disease (2870) was merged into the Shaman's Cure Toxins (526) by  
       patch 3.1, so 526 now also removes a disease.  
     - Remove Greater Curse (412113) is a Season of Discovery spell.  
     - Shadowmeld got a new spell ID (58984) in patch 3.0.2.  
    The two cure related EXPECTED\_DUPLICATES no longer hold either once  
    2870 is gone and 526 is renamed.  
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>  
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
- Add Titan Reforged 38002 compatibility  
