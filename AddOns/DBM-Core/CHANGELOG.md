# <DBM Mod> Delves (TWW)

## [10.2.41](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/10.2.41) (2024-05-16)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/10.2.40...10.2.41) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag for war within alpha delves support and better support for MoP scenarios returning in tomorrow remix  
- RU locale for Delves (#1088)  
- Make sync debug easier to notice since it's higher prio  
- Fix regression with loadmod, handle it a diff way that still fixes scenario starts  
- add 3 new trash abilities to delves  
    Added support for FungalFolley's end boss  
- support start delay for scenario's, since delves are always delayed by 5 seconds.  
- Fix bug that caused scenario mods like delves to re-enter combat due to fact LoadModsOnDemands were firing scenariocheck on all map changes and not just instance map changes. The load type is now scoped better and filtered appropriately  
- case sensitive fix  
- Tweaks  
- Fix 100206 getting flagged by packager  
- Fix rename mapping  
- Fix typo  
- Fixed delve bug where a wipe would end delve with a success  
- Add more zones for the special load conditions of delves to core  
    Split trash abilities into their own common mod since trash abilities are shared between ALL delves so needed a unified trash mod  
    Added earthcrawl mines end boss support  
    Added lava blast to delve trash alerts  
- quiet luacheck  
- template remaining delve mods  
- Remove diagnostic disables  
- More LuaLS annotations for variables storing mods  
- Tests: add /dbm test clear  
- Tests: Make AntiSpam more deterministic  
- Fix comparison function  
    Check to see if it's a number, and not string of "No Raid Module"  
- Delves kr locale initializing (#1087)  
- Tag that as a TWW mod to future proof before it's too late.  
- Add another spell to the spiral weave  
    another delve core fix  
- Fix another delve niche case  
- fix bad option keys  
- Support delves in trivial checks, and special load conditions, and check for wipe  
- Preliminary delve work  
- Fix bad case of stripping `-` from instance names;  
    - Use a special case match of ` - `, to actually detect the space cases we wanted. this means moving away from strsplit as that is a list of deliminators rather than a pattern.  
- Fix GetSpellDescription on alpha  
- Fix UnitName issue in pull timer target  
    Utilise `DBM:GetUnitFullName` instead, for appropriate filtering of friendly targets.  
- change this to debuglevel 3. it spams a TON on retail (since group size changes every time someone joins or leaves raid.  
- Fixed bugs with classic subversion check  
     - It now ACTUALLY checks classic subversion instead of echoing DBM core version check (and only running IF dbm core is out of date)  
     - It no longer runs on retail  
- bump alpha  
