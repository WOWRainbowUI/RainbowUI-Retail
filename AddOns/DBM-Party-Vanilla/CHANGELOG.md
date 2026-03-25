# DBM - Dungeons, Delves, & Events

## [r239](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r239) (2026-03-23)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r238...r239) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- Nullaeus is now compatible with 3 specs, instead of just 1,only like 36 to go  
- limit hardcode to just tank for now since it's only the tank variant specific version of fight  
- add robust fallback  
- deploy mincore revision updates  
- private aura refactor  
- private aura refactor, not compatible with older core!!  
- fix bug stopping darkmoon faire options from loading (they still don't work yet technically, but they should start working eventually when blizzard de-secrets the DMF event buffs)  
- Fix gtfo PA  
- Push hardcoded Nullaeus mod  
- fix sound on tyrannus to only play for tanks  
- make searing rend flagged for all melee instead of just tanks. and change alert from defensive to frontal  
- Change Zaen to use timer trigger instead of private aura trigger for barrel LOS alert.  
    Also fixed tank alert sound firing for all players on same fight.  
    Closes https://github.com/DeadlyBossMods/DeadlyBossMods/issues/1973  
- Spell warnings for The Beast and Lord Valthalak in UBRS (#591)  
    * Spell warnings for The Beast and Lord Valthalak in UBRS  
    * Update to add AI timer  
    * add mod:DisableHardcodedOptions()  
    * update arguments for timers  
- Add RU locale (#590)  
    * Update DBM-Party-Midnight\_Mainline.toc  
    * Create localization.ru.lua  
    * Update DBM-Party-Midnight\_Mainline.toc file  
    ---------  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Add koKR locale (#589)  
    * Update koKR  