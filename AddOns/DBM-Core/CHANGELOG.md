# DBM - Core

## [12.0.41](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.41) (2026-04-22)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.38...12.0.41) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- restore 12.0.1 backwards compat for one more day  
- restore 12.0.1 for CN region for another day  
- Tagging another update for more SetFont issue resolution for remaining users unable to use DBM due to undocumented 12.0.5 changes  
- Fixes  
- Switch to LSM validation  
- Less aggressive  
- SUPER strict font validation because over strict 12.0.5 changes  
- Put extra strict nil guards against corrupt settings for SetFont  
    remove 12.0.1 toc  
- fix variable name  
- fix one more threat check error  
- fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2034  
- bump alpha  
- missed one setfont, so prepping another new tag  
- bump version, make it mandatory update, even for classic cause these changes are probably going to appear on the two active classic PTRs as well  
- blizzard changed how setfont works, it now no longer accepts nil for font flags and must be "" instead. Should fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2030  
- Missed one isContainer  
- Minor typo (#2029)  
- update debuglog to be more decimal precise for combat time to increase accuracy of data collection.  
- bump protocol version to block bad syncs  
- Fix a bug where non boss HP wipe syncs were sending kill status instead of wipe status.  
- Sound tweak  
- fix option text  
- Mist toc bumps for PTR  
- include devourer demon hunters in spellcaster checks for soundfiles  
- Push most of the mythic crown hardcode  
    fix the rare 2 second breath cast from being included with 12 second alternation rules and add it to other difficulties for good measure  
- apparently i never pushed blizzard bugfix to mythic. push now  
- Adjust default position of Private aura anchor to be less centered (more left and right)  
- Add api support for allowing a single ENCOUNTER\_WARNING through as neeeded  
- Preliminaryy 12.0.5 prep  
- Fix two timers that blizzard sends incorrect data on by auto correcting them in hardcode on crown stage 1 heroic  
- bump alpha  
