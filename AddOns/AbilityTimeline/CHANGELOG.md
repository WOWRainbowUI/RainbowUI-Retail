# AbilityTimeline

## [v0.36](https://github.com/Jods-GH/AbilityTimeline/tree/v0.36) (2026-09-09)
[Full Changelog](https://github.com/Jods-GH/AbilityTimeline/compare/v0.35...v0.36) [Previous Releases](https://github.com/Jods-GH/AbilityTimeline/releases)

- Make sure there is no race condition between stopping glow and removing onupdate  
    clsoes #100  
- make sure glows are properly being disabled  
    mentions #100  
- fix text\_relative\_position being nil for bigicon  
- properly check if glowcolor matches  
- make sure proc glow uses the correct color  
    Also renamen glowType variable and make sure to use remainingTime instead of the threshholdtime  
- make sure role icons get properly moved if they are anchored at relative text positions  
- add options to Modify role and dispellIcon size and anchors aswell as the border size  
- chore: Update toc to newest wow interface version (#107)  