# DBM - Core

## [12.1.1](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.1) (2026-08-10)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.0...12.1.1) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Hardcore Hide SoD raids (#2172)  
- Update koKR (#2173)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- Mini dragon patch 1 (#2170)  
- prep a mandatory DBM update for 12.1  
- toc cleanup  
- Fix gui not live refreshing type 8  
- attempt to class color taunt warnings using secret names  
- Differ some GUI loading to next frame (#2171)  
    Optimizes DBM GUI startup to reduce the chance of hitting World of Warcraft's script execution limit, particularly on Classic Hardcore.  
- Default profile (#2164)  
- Artemis review (#2169)  
- Update RU locale (#2166)  
- Update koKR (#2168)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- restore couple options i forgot to restore before  
- Slider offset (#2167)  
- Remove a few diagnostic lines that don't seem to be throwing errors anymore  
- class color names  
- lets make name off by default since it's complicated on when it can be hidden  
- another small cosmetic fix  
- fixes  
- Add new advanced aura options (#2165)  
- while here, lets make the default sorting of auras less ambigous on what "Default" actually is  
- Fix layout conflict on 12.1 auras panel  
- Improve base editbox sizes  
- Update koKR (#2156)  
- Reset fix Special Warnings (#2161)  
- Adjust Bar Appearance / Name Plate sliders (#2163)  
- Slider editbox centered.  
- Remove unused  
- use appropriate collapse duration for timeline demo  
- Update DBT: (#2160)  
     - UpdateBar now uses barIDIndex[id] directly—no full active-bar scan.  
     - Consolidated UpdateBar timing changes into one deferred refresh path, avoiding the old redundant SetTimer/SetElapsed update sequence.  
     - Avoids repeated timer SetText calls when the displayed value is unchanged; spark resizing occurs only when height changes.  
     - Hidden bars without callbacks now update at 0.25-second intervals, while retaining normal cadence for callback consumers.  
     - Removed barIsAnimating; each bar now selects its own cadence from its local movement/enlarged state.  
- Update RU locale (#2157)  
- Fix strings (#2158)  
- Language update (#2159)  
- language clarification  
- Properly fix frame strata: Collision with NineSlice  
- add potential mitigation and debug for https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2116  
- Fix an occurance where the GUI frame close button can clip behind the frame  
- Fix LuaLS  
- remove old code  
- Remove DDM from MainFramePrototype  
- New slider UX;  
    - Added an "edit box" to the slider UX  
    - Fix up some spacings and sizings across the GUI  
    - CreateSlider now handles option and callback cleaner than previously  
    - Removed some legacy "old dropdown" logic.  
- attempt to revise logger to reduce chance of a line being clipped  
- Allow debug log to timestamp fights even if no module exists for them  
- Fix sizing defect: panel refresh measures the rich text before forcing its reflow, then records that stale height for auto-placement and the bordered area. I'll reorder that measurement so each checkbox is laid out from its final wrapped height.  
- Profile updates to menu refresh (#2153)  
    Improve drop downs to add a delete confirmation for profile deletion as well as refresh them properly after a deletion.  
- Add additional footer notes to profile imports/exports for clarity  
- Update koKR (#2152)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: anon1231823 <67269448+anon1231823@users.noreply.github.com>  
- Profiles Refinements (#2151)  
    ## Pull request overview  
    This follow-up PR refines DBM GUI profile import/export, improving validation and user guidance when importing the wrong profile type, handling legacy payloads, and supporting partial/instance-level imports with clearer localization.  
    **Changes:**  
    - Add new localized strings to explain profile-type mismatches, unsupported versions, partial imports, and instance-vs-boss import choices.  
    - Extend import handling to detect legacy payload types, validate payload versions, and normalize imported mod options before applying them.  
    - Add a new confirmation popup to allow importing an instance profile either fully or “this boss only” from a boss panel, and add payloadVersion to exported mod/instance profiles.  
- sorting test is confusing workspace still so just delete it  
- Misc GUI tweaks;  
    - Fix the sizings on some items  
    - Position some items better  
    - Improved the wording for bar offset  
    - Don't set the text color on color picker (as if you go black, the text is completely unreadable against the bg)  
- correctly resolve LuaLS  
- Export Boss Mod Settings (#2146)  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Update RU localization (#2150)  
- Update koKR (#2149)  
- Stupid LuaLS  
- Stupid LuaLS  
- Update font flags to use a standard fn;  
    - Add support for "Slug" font types  
    - Standardise multi-selection for font types  
- Reset Stats/Config Popup confirmation (#2144)  
- Add fadesoon announce type (#2141)  
- Fix classic tab clear (#2143)  
- revert IconNumToTexture  
- missed font check  
- wrath toc bump  
    remove deprecated file checks for wrath. no longer needed  
- no idea why luaLS got stupid, so just add manual ignores to two files that aren't even in project in first place.  
- Core Modularization update (#2148)  
- Modulize Core Options (#2147)  
    This PR modularizes DBM’s core options/profile handling by moving default options, profile management, and mod-option persistence logic out of DBM-Core.lua into a dedicated CoreOptions.lua module, reducing the size/scope of the main core file.  
- remove small unused  
- use blizzards file verification api on game versions that support it for sounds and fonts  
- Roll back some over enginered changes for unit identinty for party and raid members. the 12.1 restrictions aren't THAT harsh  
- Improve aura tracking with better sort options  
- Fix and close https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2142  
- Actually set the iconButton might be useful.  
- allow GetPlayerAuraBySpellID to be used outside of retail  
- Fix regression in function rename  
- Add LuaLS global  
- Add support for quick teleports on dungeons screen.  
- bump alpha  
