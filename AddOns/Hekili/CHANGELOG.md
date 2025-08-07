# Hekili

## [v11.2.0-1.0.0d](https://github.com/Hekili/hekili/tree/v11.2.0-1.0.0d) (2025-08-07)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.2.0-1.0.0c...v11.2.0-1.0.0d) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Merge pull request #5024 from syrifgit/11-2-sin-shiv  
    Assassination Rogue - Shiv  
- Merge pull request #5020 from syrifgit/11-2-shaman-apl  
    11.2 - Enhance APL + Tempest Tracking  
- Merge pull request #5018 from syrifgit/11-2-winters-chill  
    winters chill stuff  
- Merge pull request #5017 from syrifgit/11-2-evoker-apls  
    11.2 Evoker APLs  
- Merge pull request #5016 from syrifgit/11-2-dk-apls  
    11.2 - DK APLs  
- Explicit Resets  
- Elemental gets tempest tracking too  
    Fully implemented just like Enhance. it's actually much more reliable too, I haven't seen it drifting from the WA at all.  
- Assassination Rogue - Shiv  
    Maybe include the entire APL this time.  
    Fixes https://github.com/Hekili/hekili/issues/5019  
- Update ShamanEnhancement.lua  
- natural fade protection  
- 11.2 - Enhance APL + Tempest Tracking  
    I went extremely thorough with the tempest tracker and recreated all the edge-case protections I could find in the weakauras. It's very consistent now, and FINALLY predicts upcoming tempests in line with the WA.  
- winters chill stuff  
    An old fix that was never committed.  
    Fixes https://github.com/Hekili/hekili/issues/4746  
- review notes  
    use `strict=1`, fix trinket dump condition, bump marrowrend higher  
- 11.2 Evoker APLs  
- 11.2 - DK APLs  
    Pretty massive changes here  
