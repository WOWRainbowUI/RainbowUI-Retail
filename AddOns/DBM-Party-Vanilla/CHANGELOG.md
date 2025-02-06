# DBM - Dungeons, Delves, & Events

## [r187](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r187) (2025-02-05)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r186...r187) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- Revert "small tweaks to scanning"  
    This doesn't work: we still need to scan target and mouseover in case we learn the GUID but don't change the target/mouseover.  
    The vb stuff was just unnecessary, the time between learning the GUID and setting the icon is realistically at worst 5 seconds long, more like 3. Further, if you can get that synced that implies someone else is running DBM and found it. They will have already set the icon and you no longer need to.  
    The target/mouseover mix-up is already fixed in another commit  
- KarazhanCrypts/Kharon: Fix SPELL\_AURA\_REMOVED detection for mind control, flags work out in a weird way apparently  
- KarazhanCrypts/Kharon: Use raw icon setting to fix icons  
- KarazhanCrypts/Dark Rider: Set icon on mirror images  
- KarazhanCrypts/Dark Rider: Add 5 min enrage timer  
    Thanks to low DPS pugs I find all the enrage timers! Yay! (I play a healer, I'm not at fault for low dps)  
- KarazhanCrypts/Tests: Add test data for Sairuh  
- KarazhanCrypts/Unkomon: Remove tranqshot warning, allegedly that doesn't work  
- KarazhanCrypts/Opera: Fix pull timer for Trizivast  
- KarazhanCrypts/Kharon: Change voice for Red Death warning (runout -> watchstep)  
- KarazhanCrypts/Apprentice: Add timers for Sairuh  
- small tweaks to scanning  
    phase target now recoverable via sync in case of disconnect/reload  
    corrected Player target changed  
    removed redundant IDs from scan loop  
- Update localization.ru.lua (#399)  
- RP for Mordretha (#397)  
- RP for Mordretha (#396)  
- Update RU locale (#394)  
- timer RP (#395)  
- Tests: Delete test report data, DBM-Offline handles this better  
    DBM-Offline output is at https://github.com/DeadlyBossMods/DBM-Test-Results  
- Tests: Make commit message for multi-commit pushes to test results more readable  