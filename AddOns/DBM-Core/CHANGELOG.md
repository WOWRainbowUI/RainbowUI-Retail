# DBM - Core

## [11.1.3](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.1.3) (2025-02-06)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.1.2...11.1.3) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag for impending naxx release for SoD  
- Scrap normal and heroic test for one armed, it was reworked. updated mythic test  
- Update koKR (#1523)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
- Handle linked machines better  
- Fix two lua errors  
- Fix another name mismatch  
- Fix one boss rename  
- Update test data for Undermine  
- Fix regression with new variance options that caused non variance timers to get stuck  
- Fix option default  
- Update localization.ru.lua (#1522)  
- now reset counts on staeg 2 of one armed bandit to match BW change  
- Variance: add behaviours to control timer text  
    - "ZeroAtMaxTimer" will be what was initially envisioned: bar will always assume maxTimer, instead of min, so timer text will be 0 on end of known variance window.  
    - "ZeroAtMinTimerAndNeg" will be the opposite, considering minTimer as the 0 for timer text, and anything afterwards (aka, inside variance window), will be negative timer. Once it reaches maxTimer, timer stops. This  is similar to self.keep, just not running infinitely.  
- Variance: disabled defaults to old behaviour  
- Variance: add variance enable checkbox  
- Variance: add bar alpha slider to GUI  
    Only changed the localizations I knew.  
- DBT: add 5s variance to Dummy bars  
- Remove test reports (#1519)  
- Tests: Make commit message for multi-commit pushes to test results more readable (#1518)  
- Core: Update difficulty detection for latest PTR version (#1521)  
- Variance: reset variance on timer:Update  
    ApplyStyle (and SetVariance) was not running if the updated bar was already enlarged. Might need a refactor to not run the function twice otherwise.  
- Variance: fix delayed timers not applying metavariance (#1516)  
- Cauldron of Carnage Update:  
     - Reworked and updated timers to be more accurate in all difficulties.  
     - Added missing timer for Molten Phlegm  
- Core: Track AnnoyingPopup per zone for selected zones (#1515)  
- bump alpha  
