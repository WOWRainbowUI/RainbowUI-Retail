# AbilityTimeline

## [v0.27](https://github.com/Jods-GH/AbilityTimeline/tree/v0.27) (2026-04-02)
[Full Changelog](https://github.com/Jods-GH/AbilityTimeline/compare/V0.26...v0.27) [Previous Releases](https://github.com/Jods-GH/AbilityTimeline/releases)

- add dbm color support  
- fix potential nil error  
    Reduce the amount of debug information logged when a timer is updated.  
- Make sure eventinfo can't be nil when being send by bigwigs  
- make sure bigicon text is drawn above bordere  
    fixes #65  
- adjust bigicon text default offset to prevent overlaps  
    mentions #65  
- make sure pull timer can't cause issues when used during lockdown  
    fixes #66  
