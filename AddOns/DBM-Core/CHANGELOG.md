# DBM - Core

## [12.0.35](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.35) (2026-03-31)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.34...12.0.35) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- Update translation (#2001)  
- Update koKR (#2002)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Upd RU locale (#2003)  
- prep new tag  
- one small pull timer tweak to remove one function from addon userspace and be more consistent  
- tweak some debug colors for clarity  
- hide misleading option  
- prevent skipping of crown cinematic when played manually by using recent kill logic fyrak had  
- Fix tank warnings going off for non tanks when using hardcode on double dragons  
- enable dread breath target warning  
- Tweak audio and text warnings in LFR chimaerus to reflect that there is no soak here  
- Fix brez timer not showing due to being called after "return"  
- change default position to top left instead of dead center  
- Bugfixes and GUi tweaks  
- Add optional off by default Brez timer frame option (#1999)  
    Very Basic Brez timer for retail only. No classic handling so no CLEU stuff. Completely off by default as not to be intrusive new frame that pops up to existing users already using another addon for this, but an option for those that aren't or want to eliminate another addon if they were only using it for this one thing.  
- Update translations (#2000)  
- update pull timer to be completely blocked in ANY combat (per blizzard new restrictions)  
- Update builtin voice pack sounds  
    make March of Quel danas modules public  
- Enable Vorasius hardcoded timers on mythic too, since once again they appeal to be exactly the same as other 3 modes  
- Update localization.ru.lua (#1996)  
- Update koKR (#1995)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Push voice pack sounds update  
- Handle long stage 3s better (where dragons lift off again in stage 3 due to low damage.  
- switch to checkoutV5 to meet node 24 requirement  
- Update commonlocal.ru.lua (#1991)  
- Update koKR (#1992)  
    * Update koKR  
- Fixes  
- rework target messages to try and use a more secret sensitive approach for target messages when using blizz secret target information  
- Make sure frame pixel size perfectly divisable by 14  
    fix arrows  
- make timeline features, when used, respect the globald disables for warnings and sounds  
    Debuglog should now have scroll by page buttons  
- couple tweaks  
- Vaelgor and Ezzorak Update:  
     - Deemphasize grabbling maw to just a generalized text alert, it's so inconsiquential that it's just white noise.  
     - Changed audio on dread breath private aura to be a bit clearer and higher in emphasis  
     - Removed Spammy barrier private aura sound (I thought I already did this, my bad)  
     - Improved Zull Zone private aura sound to be much clearer and more correct.  
     - Also, added heroic hardcode  
- Enable same timers table on heroic VOrasius as normal and LFR, they are the same  
- Preliminary heroic hardcode for chimaerus  
- fix bad self definition  
- fix event registers  
- fix formatting error  
- ugly experiment to fix class color on blizz warnings. by half hardcoding them because why not have yet another blizzard issue to work around.  
- keep this one change though  
- Revert "attempt to fix formaters that may be removing class color from special warning class text"  
- Revert "In fact, eliminate wrapping text in icon textures entirely and use separate objects for icons, further reducing chance of deformating secret text"  
- Revert "tweaks"  
- tweaks  
- Add new common locale strings (#1990)  
    * Update translations  
    * Update translations  
    * Add new common locale strings  
- In fact, eliminate wrapping text in icon textures entirely and use separate objects for icons, further reducing chance of deformating secret text  
- attempt to fix formaters that may be removing class color from special warning class text  
- fix invalid spellid  
- bump alpha  
