# Platynator

## [349](https://github.com/TheMouseNest/Platynator/tree/349) (2026-03-19)
[Full Changelog](https://github.com/TheMouseNest/Platynator/compare/348...349) [Previous Releases](https://github.com/TheMouseNest/Platynator/releases)

- Remove usage of "IsDesaturated" to convert a curve output to a boolean  
    This is because Blizzard will be blocking this function from  
    manipulating secrets in a hotfix soon-ish.  
    This WILL break  
    - Execute colours  
    - Avoiding GCD issues with some Warlock interrupts  
