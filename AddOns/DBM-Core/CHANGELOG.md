# DBM - Core

## [12.0.4](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.4) (2025-11-14)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.3...12.0.4) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- add caveat notice to filter  
- squeeze in an additional fitler options  
- Update localization.es.lua (#1805)  
- prep new tag  
- Fix bug where the difficulty wouldn't be shown when joining a group when you're already in a group  
- mop toc bumps for new PTR  
- Variance: timer Update method now handles variant totalTime (#1799)  
- Update localization.es.lua (#1801)  
- Update koKR (#1803)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
- Update localization.ru.lua (#1804)  
- actually at this point this one line is redundant  
- Don't report difficulty on joining delve or follower group  
    Don't report difficulty when joining queued content in general  
    Once again attempt to always report difficulty on joining groups that aren't one of above, but with a better antispam throttle to avoid it being reported twice.  
- final iteration that's best compromise on some of remaining issues.  
- simplify, solving luaLS  
- Make sure message is branded for clarification of source of message  
- improvements to klast  
- Add feature to announce when raid or dungeon difficulty change (while in a group). Raid option on by default and dungeon option off by default.  
    Inspiration for addition is that often. players don't notice the difficulty is set incorrectly when they join a pug group and lose time by zoning into zone before it is set correctly. In addition, they also often don't notice when the difficulty has been changed to correct one either and don't zone in right away. This change is aimed at making those often overlooked chat messages far more prominant with DBMs typical alert style.  
- adjust some message language for TTS on fractillus and soul hunters to be less directive in situations they went against common weak auras  
- Core/Timer: fix count voice when timer is started again before expiring (#1800)  
- bump alpha  
