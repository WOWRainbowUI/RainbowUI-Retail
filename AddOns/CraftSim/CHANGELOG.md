# CraftSim

## [20.0.0](https://github.com/derfloh205/CraftSim/tree/20.0.0) (2025-08-26)
[Full Changelog](https://github.com/derfloh205/CraftSim/compare/19.9.0...20.0.0) [Previous Releases](https://github.com/derfloh205/CraftSim/releases)

- Version up, News Update  
- Optimize recipe optimization lgorithms (#870)  
    - Optimize concentration selection: Replace item-by-item approach with batched  
      processing using frame budgets (40 units per frame). Reduces Update() calls  
      and provides accurate progress tracking for better performance.  
    - Optimize CreateCrumbs algorithm: Replace O(n^2) nested loops with O(n) direct calculation  
    Performance improvements should be significant for large recipe runs  
- consider unique category id being nil  
