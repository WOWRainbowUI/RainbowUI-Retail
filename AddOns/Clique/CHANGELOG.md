# Clique

## [v4.8.0-release](https://github.com/jnwhiteh/Clique/tree/v4.8.0-release) (2026-03-08)
[Full Changelog](https://github.com/jnwhiteh/Clique/compare/v4.7.1-release...v4.8.0-release) [Previous Releases](https://github.com/jnwhiteh/Clique/releases)

- Adjust frame detection logic to account for new 12.0 behaviour  
    In 12.0 Blizzard made changes to the self:IsUnderMouse() method in  
    the restricted environment. This introduced a different codepath  
    that appears to be returning a false-ey value more frequently than  
    in the past.  
    To accommodate for this, we can adapt to use GetMousePosition() to  
    check whether the mouse is within the HitRect of the frame. This  
    could hypothetically cause an issue where a protected child lies  
    outside of the bounds of the frame, but we don't believe that is  
    likely.  
