# GladiusEx

## [2.10.1](https://github.com/vendethiel/GladiusEx/tree/2.10.1) (2024-09-08)
[Full Changelog](https://github.com/vendethiel/GladiusEx/compare/2.10...2.10.1) [Previous Releases](https://github.com/vendethiel/GladiusEx/releases)

- Fixes for Classic (#106)  
    * Fixed aura mastery effect dissipation on Classic  
    * Fixed typo  
    * Fix for Classic  
    * Minor rework for UnpackAuraData  
    Made it UnpackAuraData local and optimized it a bit (avoiding unpack call). I'm not sure why we need this function at all, can anyone explain?  
    * Spaces to tabs in interrupts.lua  
    Not sure if it should be spaces or tabs, but at least now the file is internally consistent.  
    * Fixed small mistake in interrupts module  
    * Fixed auras for Classic  