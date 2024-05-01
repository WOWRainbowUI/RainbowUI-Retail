# TankMD

## [v3.0.0](https://github.com/Oppzippy/TankMD/tree/v3.0.0) (2024-05-01)
[Full Changelog](https://github.com/Oppzippy/TankMD/compare/v2.5.3...v3.0.0) [Previous Releases](https://github.com/Oppzippy/TankMD/releases)

- Update interface version  
- Slash command should output user friendly text by default  
    The state of the buttons can be behind /tankmd debug  
- Fix error on classes that don't have a misdirect  
- Add tests for prioritize focus  
- Add tests for ClassTargetSelectors  
- Fix innervate targeting tanks instead of healers  
- Use new tank settings for Evoker as well  
- Fix default value for tankSelectionMethod  
- Rename variables  
    Renames the backing db field for the tank selection method, so this is a  
    breaking change. It was never stabilized in a release, so that's okay.  
- Fix druid and evoker sorting  
- Rename to TargetSelectionFilter  
- Fix unwanted sorting  
    When a chain is wrapped in another chain, the sorting done by the inner  
    chain will be overridden by the outer chain. That was what was  
    intended, but it's not great for usability, so sorting and chaining are  
    now split up.  
- Add option to prioritize focus  
- Add /tankmd command to show selected tanks  
- Fix role fallback failing  
- Fix fallback tankRoleOnly  
- Fix libraries not being loaded on classic  
- Rename tank selection strategies  
- Fix unused buttons not being disabled  
- Add missing TargetSelectionStrategy.MainTank implementation  
- Add tank selection options  
- Add tests, fix reuse of iterators  
- Fix legacy buttons  
- Refactor part 2  
    Replace TargetMatcher with TargetSelector/TargetSelectionStrategy  
    chains. This makes composing selection strategies much simpler.  
- Refactor part 1  
    Use AceAddon and AceEvent for simplicity. Remove unnecessary  
    abstractions from the top down to MisdirectButton.  
    Part 2 will replace the various types of TargetMatchers with functions.  
