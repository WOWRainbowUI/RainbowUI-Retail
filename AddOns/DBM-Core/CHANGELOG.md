# DBM - Core

## [11.0.8](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.8) (2024-09-12)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.7...11.0.8) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Bump version and prep another tag for Season 1 delve and raid fixes  
- Preliminary warnings for notable trash abilities in Nerubar Palace  
- While at it, massively extend normla mode silken court phase 3 as well  
- massively extend P3 timers on silken court heroic  
- preliminary heroic timer differences for queen ansurek  
- fix two reported issues with first boss  
    tank alert not firing due to never clearing tenderize.  
    soak warning using wrong object type thus having ocmpletely wrong text  
- Update localization.ru.lua (#1229)  
- Update localization.en.lua (#1230)  
- Fix errors with delve tiers 12 and 13 which blizzard decided to return ? and ?? for  
- Nameplate options will now hide options that are meaningless if plater is installed and instead show a button that automatically opens Plater to the boss mod config options. This should add significant clarity that when Plater is in use, it's options are where users should be.  
- Fix nameplate style category using wrong localized header text  
    Further fix niche situation hybrid nameplate/bar timers showing when they're disabled.  
- Fix bug with nameplate rework that caused hybrid timers (ones that are both timer AND nampelate) to not honor the nameplate portion disable.  
- Tests: Round down timewarper setting from UI slider for consistency  
- Tests: Add button to skip to the next phase to playground UI  
- UI: Use class color for player selection and add role info  
- UI: Don't shrink the dropdown menu dynamically  
    Unfortunately dynamic growth is still needed due to the faux scroll frame lazy loading, but the dynamic shrinking was really distracting  
- Ky'veza: Fix Nexus Daggers spell showing up as Unknown  
- Tests: Fix timestamps in UI  
- Tests: Update CLI tools  
    It'll now just create files for every single encounter by default instead of outputting to stdout  
- Tests: Don't export playground tests to saved variables  
- Nerub-ar Palace: Update mythic test data  
    Also rename the wipe tests to remove the number, we aren't gonna add more than one now that the in-game import feature exists  
- Try this for now, using a log that didn't actually push percent threshold  
- Enable another nameplate timer for Null Detonation  
    added plateholder first intermission timer, but it's still not ready for use yet because there is some stuff going on that needs to be assessed first with more data  
- bump alpha  
