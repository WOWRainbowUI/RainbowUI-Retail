# Hekili

## [v11.0.5-1.0.7](https://github.com/Hekili/hekili/tree/v11.0.5-1.0.7) (2024-10-30)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.5-1.0.6b...v11.0.5-1.0.7) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Merge branch 'thewarwithin' of https://github.com/Hekili/hekili into thewarwithin  
- Frost DK SimC update  
- Merge pull request #4115 from johnnylam88/feat/reserve-vanish-charges  
    feat: add slider to reserve Vanish charges for rogues  
- Screenshot on manual snapshots  
- Merge branch 'thewarwithin' of https://github.com/Hekili/hekili into thewarwithin  
- Handle Demonic Healthstones  
- Merge pull request #4122 from syrifgit/syrif-hunter  
    BM - no more multishot in ST  
- BM - no more multishot in ST  
    hasn't been updated on the official APL yet, but this is no longer relevant due to multiple bug fixes  
- Merge pull request #4121 from syrifgit/syrif-rogue  
    Sin rogue - carnage effect  
- Merge pull request #4120 from syrifgit/syrif-mage  
    Arcane mage - Barrage Spam  
- Shadow: Improve Unfurling Darkness CD  
- Merge branch 'thewarwithin' of https://github.com/Hekili/hekili into thewarwithin  
- Arms, Ele, Fury sim updates  
- no reactions here  
- Sin rogue: Better APL support for no-target-swap users  
- Sin rogue  
    old carnage handling for previous iteration of the effect  
- Update MageArcane.simc  
    Replace react with up/down/stack  
- Arcane mage - fix barrage spam due to touch desync  
- Arcane pack string  
- feat: add slider to reserve Vanish charges for rogues  
    Fixes #3855.  
- Merge pull request #4113 from johnnylam88/fix/bonestorm-bone-shield  
    fix: Bone Shield stacks return zero during Bonestorm  
- fix: add correct events and times for Bone Shield gains during Bonestorm  
    Fix an off-by-one error for the correct tick times for adding stacks to  
    the Bone Shield, and also use the correct function `QueueAuraEvent` to  
    queue the tick event.  
- fix: correct 2nd argument to `removeStack`  
    The second argument to `removeStack` should be the number of stacks of  
    the aura to remove, which is contained in `consume`.  
