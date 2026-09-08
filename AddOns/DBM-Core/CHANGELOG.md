# DBM - Core

## [12.1.9](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.9) (2026-09-08)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.8...12.1.9) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- forgot to push this first  
- Only Load PvP mod for STV/Ashenvale in SoD (#2174)  
- New adds count timer (#2210)  
- Translation update prewarn (#2211)  
- Add safeguards to using keystone teleports in combat. Closes https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2214  
- some 12.1.5 aura sound prep  
    Also add more message clarity of timeless isle module not being useful on retail  
- remove tainted blood absorb alert  
    once again, it'd be a valid alert if blizzard api ACTUALLY had throttling, but since it doesnlt....  
- Spell rename Fixes: (#2212)  
     - Turning off renames now turns them off without requiring uireload  
     - Turning off renames on timers is now honored.  
- small rename  
- Fix a bug where gloom bomb personal alert would not show if you weren't first set of them (blizzard batches them over 2.5 seconds)  
    Fix routing of explorers again with some timer changes  
- Center buttons (#2204)  
- suspend distribution to wago  
- add a falflback workaround for tank spec not readable instantly on reload. Should fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2208  
- add support for mythic explorers  
- mythic tweaks for nymrissa  
- fix it so that does run in midnight.  
- force audio channels to 128 instead of 64 to continue working around bug blizzard introduced in 7.1.5  
- bump alpha  
