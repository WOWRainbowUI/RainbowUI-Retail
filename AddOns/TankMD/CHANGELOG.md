# TankMD

## [v2.5.2](https://github.com/Oppzippy/TankMD/tree/v2.5.2) (2024-01-17)
[Full Changelog](https://github.com/Oppzippy/TankMD/compare/v2.5.1...v2.5.2) [Previous Releases](https://github.com/Oppzippy/TankMD/releases)

- Update Interface version (#10)  
    Co-authored-by: Oppzippy <Oppzippy@users.noreply.github.com>  
- Run tests before publishing releases  
- Skip linting tests  
    Globals are set in tests to match the WoW lua environment. It's simpler  
    to just disable linting tests for now.  
- Run tests in github actions  
- Fix GetSortedGroupMembers edge cases (GH-9)  
    According to https://warcraft.wiki.gg/wiki/API\_GetRaidRosterInfo, there  
    can be holes between raid1 and raid40, meaning all unit ids are not  
    necesssarily consecutive. This means we should just go over all 40 raid  
    members and skip nils.  
    It is also possible for UnitName to return Unknown sometimes, so those  
    units should be skipped to avoid misdirecting the wrong target in the  
    case that multiple targets are named Unknown.  
    Co-authored-by: Road-block <dridzt.addons@hotmail.com>  
