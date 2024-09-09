# Hekili

## [v11.0.2-1.0.10](https://github.com/Hekili/hekili/tree/v11.0.2-1.0.10) (2024-09-09)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.2-1.0.9...v11.0.2-1.0.10) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Fix #3691  
- Fix #3692  
- Fix #3685  
- Fix #3693  
- Fix #3689  
- Merge branch 'thewarwithin' of https://github.com/Hekili/hekili into thewarwithin  
- Priority updates from SimC  
- Merge pull request #3683 from syrifgit/thewarwithin  
    Arcane, Ret, Shadow  
- Shadow Crash Opener  
    No reason to have shadowcrash be reliant on a boss condition in precombat opener. In the SIMC apl it is simply "not dungeon slice". Having it show up in the AoE opener is natural and abides by the guides, as well as AoE sims.  
    Fix for: https://github.com/Hekili/hekili/issues/3644  
- Ret Pal: Blessing of Anshe spellID  
    fix for https://github.com/Hekili/hekili/issues/3627  
    Ret was using the spellID for the Holy Version  
- More Arcane Tweaks  
    Fix arcane orb check, remove rune of power (just like blizzard did), add lingering embers, make some talent checks smarter, stop removing arcane soul for no reason, remove some of the mana trickery (it's not all needed at max level)  
