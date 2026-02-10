# DBM - Core

## [12.0.17](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.17) (2026-02-10)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.16...12.0.17) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- add count enabling cvar for 12.0.1  
- If a user toggles off a custom sound file, actually nil sound registration out so sound is removed  
    slightly clarify count sound default changes  
- Fix banishment option key in new midnight optinos so they correctly group  
- cleanup some bad AI code  
- updated midnight apis for soul hunters  
- hard block using deprecated table injection in countdown packs. Use the proper utility function going forward. Old injection sitll supported for classic for now until overwatch and heroes packs are updated.  
    Update soulbinder Naaz to new apis  
- Bring back voice pack and countdown UI panels in midnight  
    Block count packs from registering media if they aren't compatible with midnight.  
    Add api so 3rd party count packs can flag their compatability with midnight  
- Force set string|number since luaLS can't figure shit out  
- LuaLS be dumb so remove a check  
- Make sure new private aura and timeline apis honor users sound channel setting  
- Cleanup the private aura/secret api registration code a bit to reduce redundant code in both core and boss modules  
    remove left over debug prints from special warning objects  
    Temporarily flag the disable generic sounds option until a later hotfix patch  
    Moved nexus King to new apis  
- Update some translations (#1890)  
    Co-authored-by: anon1231823 <anon1231823@users.noreply.github.com>  
- Scheduler Optimization (#1885)  
    * Scheduler Optimization  
- cleanup  
- Fix some tocs  
- add custom sounds and colors to 5 raid bosses and fix some small bugs with api  
- Update plexus for 12.0.1  
- update diagnostics  
- Fix Announce sound dropdowns. Closes #1877  
- trigger new LuaLS check  
- Update localization.ru.lua (#1883)  
    * Update localization.ru.lua  
    * Update localization.ru.lua  
- Update localization.tw.lua (#1882)  
- Update localization.tw.lua (#1881)  
- Update koKR (#1879)  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update localization.kr.lua  
    Fix unclosed string  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    * Update koKR  
    ---------  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Update localization.ru.lua (#1880)  
- Add Portuguese, Spanish, and French translations for DBM GUI (#1878)  
    * Add Portuguese, Spanish, and French translations for DBM GUI  
    * forgot bar icon position  
    ---------  
    Co-authored-by: anon1231823 <anon1231823@users.noreply.github.com>  
- Fix LuaLS type checking errors in DBM-StatusBarTimers (#1884)  
    * Initial plan  
    * Fix Lua type checking errors in DBM-StatusBarTimers  
    Co-authored-by: MysticalOS <1899149+MysticalOS@users.noreply.github.com>  
    * Fix return type mismatch in parseAndApplyVariance  
    Co-authored-by: MysticalOS <1899149+MysticalOS@users.noreply.github.com>  
    * Fix countdown parameter type to accept string|number|nil  
    Co-authored-by: MysticalOS <1899149+MysticalOS@users.noreply.github.com>  
    * Address code review feedback - use 0 fallback for invalid timers  
    Co-authored-by: MysticalOS <1899149+MysticalOS@users.noreply.github.com>  
    * Fix parseTimer to accept optional 'd' prefix for doubled-variance timers  
    Co-authored-by: MysticalOS <1899149+MysticalOS@users.noreply.github.com>  
    ---------  
    Co-authored-by: copilot-swe-agent[bot] <198982749+Copilot@users.noreply.github.com>  
    Co-authored-by: MysticalOS <1899149+MysticalOS@users.noreply.github.com>  
- i don't understand why claude thinks this will fix it but why not  
- try to fix some of conditionals. it'd be 1000x easier if local luaLS didn't live on a completely diff planet from CI LuaLS  
- just nuke the returns. make it so anbigious luals has to just assume everything is right  
- luaLS?  
- more luaLS tweaks  
- Better luaLS param's to clear up some false errors  
- Some code de-duplication in DBT and Timer files  
    Some anti taint protections from bar color api that could occur after blizzard fixes GetColor declassifying the secret (and to be honest we have no reason to get color and set it again anyways)  
- Fix annotations. these are not optional  
- Fix all remaining bugs in timeline based schedule functions for schedule based modding.  
    Initial round of fixes to schedule based dimensius mod, with more work on it soon™  
    non scheduled based mod will also have first flight timer back too, and announce stage changes again.  
- Throttle PlaySoundFile when blizzard api sends multiple events for same warning.  
- Filter special warning sounds on blizzard API, if a module is registering custom sounds with 12.0.1 encounter api  
    Improved testBuild check to include beta builds  
- GUI and core work for custom sound registration on timeline event end  
- Force reset variance/maxqueue timer option to off by default on retail due to blizzard poorly using the api for it (basically setting EVERY bar to a 6 second variance very laziily)  
    Fix lua error that could occur if you reload UI/reconnect in combat, due to UnitGUID being secret for players in your own raid (NANI?!, why are players in your raid having secret guid anyways)  
- Fix coupole bugs in EnableTimelineOptions  
- Fix error with colortype to color conversion  
- Add C\_EncounterEvents  
- Preliminary countdown and bar color option objects for midnight timeline  
- begin preliminary work on a schedule based Dimensius mod that i'll finish up thursday once i analyze some bugs and stream so I can compare debug and logs to vod.  
- Add method to tell DBM core to ignore blizzard api (when a boss mod is hardcoded instead)  
- Fixed a LONG standing bug where unfiltered unit events never actually ever got unregistered  
    Added a specific object for unregistering events to core that are no longer needed.  
- cleanup  
- Relax aura checks somewhat in midnight for harmless buffs like non combat darkmoon faire mods to still be able to function.  
- Add new count media files  
- Move legacy journal icon timers to newer format that matches retails more modern appearance.  
- Add some text strings for translations to get started  
- Update localization.cn.lua (#1876)  
- Don't show JournalIcons frames on non secret bars  
- bump alpha  
