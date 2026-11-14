# DBM - Core

## [12.1.23](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.23) (2026-11-13)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.21...12.1.23) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- tweaks  
- rework trash alerts again to try and fix duplicates. all this hacking cause blizzard can't use right events for cast bar casts on bosses in forever  
- Hacky windows font fixes  
- bump alpha  
- prep new tag  
- Possibly fix binary font not working on windows (it was already working on mac)  
    Fix cast alerts not working on bosses in forever due to blizzard using wrong event (seriously, why a success event for channels and cast starts)  
- Scope debug to just forever  
- add some debug code  
- Filter alerts from trivial enemies  
- remove redundant check  
- Another generic trash fix  
- Fix cases where dungeon/raid alerts didn't work in forever due to bad fallback code not actually running non fallback code, which could result in instances that are both dungeons AND events to be treated as non valid  
- Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2277 by improving utilization of speclib in forever as well as trusting UnitRole if set (usually set when using group finder)  
    Also, attempt to auto set role using libspec as well on forever  
- Fixes  
- Support binary encoding for debug log  
