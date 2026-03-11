# AbilityTimeline

## [v0.21b](https://github.com/Jods-GH/AbilityTimeline/tree/v0.21b) (2026-03-09)
[Full Changelog](https://github.com/Jods-GH/AbilityTimeline/compare/v0.19...v0.21b) [Previous Releases](https://github.com/Jods-GH/AbilityTimeline/releases)

- make sure we are properly listening to custom dbm timers  
- properly cancel bigwigs timers  
- add version as a required for a bug report  
- add dbm callback for lfg/respawn timers  
- make frame handling more resilient  
- make sure we do not use hidden events when calculating offset  
- hide all bw bars when timeline is enabled  
- properly hide bw created timers when fight is over  
- add big wigs text color support  
- make sure custom bw bar icons don't explode  
- make sure we don't add editmode events twice when bw is loaded  
- make sure we also allow editmode events when using bossmod disable  
- make sure time can not be nil  
    closes #50  
- check for event source when adding bw timers  
- add version command  
- make sure we only set color if it is relevant fixes #47  
- use event colors for highlight texts  
- use event text color if available for spellicon  
- add optional tooltips to icon and bigicons  
    closes #46  
- also ignore bliz timers when dbm overrides their timers  
- add dbm timer support  
- properly handle script timers when using bw  
- add big wigs support  
- make sure we apply settings before setitng event info  
    this should hopefully prevent the flashbang mentioned in # 41  
- chore: update encounter data (#39)  
    Co-authored-by: Jodsderechte <39654549+Jodsderechte@users.noreply.github.com>  