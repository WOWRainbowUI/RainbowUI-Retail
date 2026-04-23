# Clique

## [v4.9.5-release](https://github.com/jnwhiteh/Clique/tree/v4.9.5-release) (2026-04-22)
[Full Changelog](https://github.com/jnwhiteh/Clique/compare/v4.9.4-release...v4.9.5-release) [Previous Releases](https://github.com/jnwhiteh/Clique/releases)

- Improve robustness of mouse motion propagation for forbidden frames  
    - Wrap IsForbidden check in pcall to avoid triggering on new forbidden  
    - Thread frame path labels through so failures name the offending frame  
    - Fix queue re-entrancy in leavingCombat by swapping before iterating  
    - Fix mouseMotionSet not being updated for frames processed from queue  
    - Fix configType case typos for TargetFrame-Retail and FocusFrame entries  
    - Remove CenterDefensiveBuff propagation from compact unit frames  
