# Hekili

## [v11.2.0-1.0.1e](https://github.com/Hekili/hekili/tree/v11.2.0-1.0.1e) (2025-09-02)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.2.0-1.0.1d...v11.2.0-1.0.1e) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Double Double Jeopardy Jeopardy  
- Merge pull request #5275 from syrifgit:marksmanship-apl  
    Marksmanship APL Sync  
- Tweak call\_action\_list  
- Merge pull request #5278 from syrifgit/global-item-disable-updated  
    Disable All Items Setting (Per-Specialization)  
- Specialization name in description  
- Green  
- Refactor description for disable items option  
- Merge pull request #5274 from syrifgit/Havoc  
    Havoc APL Fix  
- Merge pull request #5272 from syrifgit/sub-rogue  
    Coup De Grace Improvements  
- Merge pull request #5262 from syrifgit/Arcane-Improvements  
    Arcane Intuition Improvements  
- Merge pull request #5254 from syrifgit/frost-mage-flurry  
    Frost Mage Winters Chill Improvements  
- Disable All Items Setting (Per-Specialization)  
    Re-do of https://github.com/Hekili/hekili/pull/4568, incorporating the feedback.  
- Marksmanship APL Sync  
    Standard sync  
    - https://github.com/simulationcraft/simc/commit/6d9880414b176cb158b1c932311e8da98ed50cac  
    - https://github.com/simulationcraft/simc/commit/c1c896575872235b5ca84c89f628260d299ef66f  
    - https://github.com/simulationcraft/simc/commit/8526f4260871e44ac59b08ed6d73a72933f3f29d  
- Devastation priority Engulf / FB ranks  
- Havoc APL Fix  
    I didn't de-prune this line, oops.  
    Fixes https://github.com/Hekili/hekili/issues/5243  
- Adjust formatting and some logic order  
- Protadin priority  
- Outlaw priority (Vanish)  
- Review notes  
- Improve recheck of true\_remains  
- spacing  
- Coup De Grace Improvements  
    - Tie both `coup_de_grace` and `tww3_trickster_4pc` auras to a real aura, `escalating_blade` via generator  
    - Don't bother making a fake aura that the APL will never check, just use the expressions we built (disorient\_stacks / disorienting\_strikes)  
    - Fix edge case introduced by tww3 set where you can apply too many `coup_de_grace` buffs in the local TriggerUnseenBlade() function, leading to 3 being shown in the display queue  
    - `reset_precast`  
      - Properly force the expressions to resync with real data on reset  
      - Add more guardrails for the weird double cast window when checking `prev[1].coup_de_grace`  
    - Then apply all of that to subtlety, making sure to swap spellIDs and handlers where needed  
- Merge pull request #5269 from IIeTpoc/IIeTpoc-KS-CP-Resource\_model  
    Add KS CP to resource model  
- Merge branch 'thewarwithin' into IIeTpoc-KS-CP-Resource\_model  
- Subtlety: Don't waste Symbols  
- Outlaw priority: missing variable  
- Fix Voidbinding CDR debug message  
- Fix Voidbinding aura detection  
- Fix responsiveness when breaking channels  
- Include TickTime for KS  
- Treat Killing Spree as a spell.  
- Update RogueOutlaw.lua  
- Add killing spree combo points to resource model  
- Restore missing RTB variable  
- Restore missing RTB variable  
- reduce intuition flickers  
- Merge pull request #5260 from syrifgit/UI-fix  
    Fix UI for real  
- Guardrails  
- Arcane Mage - Implement Intuition Bad Luck Protection tracker  
- Fix opener pre-cast for Frostfire tree  
- Fix UI for real  
    There was another oopsie in https://github.com/Hekili/hekili/pull/5250/files  
    Fixes https://github.com/Hekili/hekili/issues/5259  
- Fix braces indeed  
- Update MageFrost.lua  
- Frost Mage Winters Chill Improvements  
