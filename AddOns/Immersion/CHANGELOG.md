# Immersion

## [1.4.35](https://github.com/seblindfors/Immersion/tree/1.4.35) (2024-05-08)
[Full Changelog](https://github.com/seblindfors/Immersion/compare/1.4.34...1.4.35) [Previous Releases](https://github.com/seblindfors/Immersion/releases)

- Update Immersion.toc  
- Merge pull request #34 from brittyazel/master  
    Add combat lockdown conditional check for SetPropagateKeyboardInput(), fixes issue #32  
- Merge branch 'seblindfors:master' into master  
- Merge branch 'seblindfors:master' into master  
- Merge branch 'seblindfors:master' into master  
- Add combat lockdown conditional check for SetPropagateKeyboardInput()  
    In 10.1.5 Blizzard made SetPropagateKeyboardInput() a restricted function not able to be called in combat from insecure code. To work around this limitation we should wrap our calls to this function with an InCombatLockdown() conditional check.  
