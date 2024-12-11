# DBM - Core

## [11.0.36](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.36) (2024-12-11)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.34...11.0.36) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Fix another bug where combat voice packs were not playing TTS when available on classic  
- Fix health warnings so they now work for non combat deaths (like drowning)  
    Bump version again  
- bump alpha  
- Fix nightmare grove not being properly detected by missing modules check or trivial difficulty check  
- Fix defaults bugs with infoframe and bar colors where defaults were set to incorrect default values  
- VS code can be dogshit sometimes  
- Some fixes and adjustments to missing module notifications:  
     - Added support for missing mod alert popup for TBC and MoP since TBC classic is returning with fresh and MoP classic is coming after cata.  
     - Added improved scoping for timewalking raids like Black Temple, Ulduar, and firelands to be only ones to show missing module popup on retail  
     - Fixed BRD raid not showing missing module popup  
     - Fixed Naxx not showing missing module popup in vanilla  
     - Fixed Dragonflight raids not showing chat message about missing modules (no popup at this time)  
     - Fixed not getting popup in pretty much any of  max level raids in SoD  
- Renames  
- Update localization.ru.lua (#1414)  
- Update localization.ru.lua (#1415)  
- Update localization.es.lua (#1419)  
- Update localization.fr.lua (#1420)  
- Update localization.br.lua (#1421)  
- Update koKR (#1422)  
- Update localization.br.lua (#1418)  
- Update localization.es.lua (#1416)  
- Update localization.fr.lua (#1417)  
- Fix the 35% health warning  
- hide proc option all together  
- Fix duplicate option  
- Refactor small parts of dbm nameplate code to be more in line with plater.  
    Changed default cast glow behavior from "Proc" to "Button" to work around bug with LibCustomGlow initializing proc the incorrect size on first usage.  
    Fixed a bug where the glow icon size could not be live changed (Ie after initial load)  
- Revert "delay calling glow to second onupdate to attempt to avoid a race condition where glow has no anchor point on icon creation and initially flashes unanchored"  
- delay calling glow to second onupdate to attempt to avoid a race condition where glow has no anchor point on icon creation and initially flashes unanchored  
- fix lua errors in core  
- Fix LuaLS definition for test LibStub support  
- Tests: Updata Rasha'nan test data  
- Tests: Generate compressed test logs in addition to the normal logs, these are ~20x smaller  
    The idea is to then strip the normal logs from release builds. DBM will prefer the uncompressed version if it is present, so dev builds can still hand-edit logs to test out something.  
- Tests: Add support for LibStub libraries in CLI tools  
- Tests: Support Lua versions with LUA\_COMPAT\_VARARG set  
    Looks like Ubuntu Lua 5.1 sets this extremely annoying and stupid compat option  
- Tests: Fix deletion of non-persistent tests on logout  
- Add following Changes that are good for hardcore wow:  
     - AFK health warning will now have 3 second ICD (down from 5)  
     - Added new non afk health warning for 35% or lower health. ON by default on HC (off by default elsehwere)  
     - Added new off by default option to play sound and alert when entering combat (also flashes WoW icon if tabbed out)  
     - Added new off by default option to play sound and alert when leaving combat  
- further tweaks  
- fixes to last  
- Only set "canglow" to true on cast nameplate timers for timers above 0 instead of timers under 4 (cast timers don't work like cooldowns. they should glow for entire cast, and definitely not glow when cast is over)  
    In addition, change failsafe code that cleanups nameplate timers to actually run instead of never running for timers not flagged "keep'. Both of these should have double redundancy to ensure nameplate cast timer glows don't get stuck. not sure if it fixes giant square bug or not but it would fix a bug where the glow would be tracked beyond timer ending.  
- Update koKR (#1410)  
- LuaLS: Minor cleanups (#1411)  
- Update localization.tw.lua (#1408)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Update localization.ru.lua (#1409)  
- disable these two useless diagnositics  
- Add message print when potion is auto used since it continues to confuse players  
- Make luaLS happy with new rules  
- Optimize API usage of HasMapRestrictions check to now using caching instead of always validating if UnitPosition is available. Most notable this can avoid unnesssary cases with hudmap checking UnitPosition hundreds of times needlessly. Now a new function DBM:UpdateMapRestrictions() will run in places we actually expect restrictiosn to change, and HasMapRestrictions will just return that cached value. For most part this doesn't change much for most places except for HudMap usage in classic  
- Add a bunch fo api documentation to hudmap  
- bump alpha  
