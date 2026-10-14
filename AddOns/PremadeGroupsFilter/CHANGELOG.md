# Premade Groups Filter

## [7.6.4](https://github.com/0xbs/premade-groups-filter/tree/7.6.4) (2026-10-13)
[Full Changelog](https://github.com/0xbs/premade-groups-filter/compare/7.6.3...7.6.4) [Previous Releases](https://github.com/0xbs/premade-groups-filter/releases)

- Fix raid member iteration and leaver tooltip icon  
    Use correct raid unit tokens for role and group capability checks.  
    Show the leaver icon based on isLeaver instead of isLeader.  
    Refs #408  
- Display group age independently of option "Class Names in Tooltip" (see #410)  
- Add some more safeguards to prevent lua errors while in combat in a raid/dungeon  
