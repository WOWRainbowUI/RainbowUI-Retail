# Astral Keys

## [4.44](https://github.com/astralguild/AstralKeys/tree/4.44) (2026-02-11)
[Full Changelog](https://github.com/astralguild/AstralKeys/compare/4.43...4.44) [Previous Releases](https://github.com/astralguild/AstralKeys/releases)

- Up to version 4.44  
- Fix a secretvalue access in GOSSIP\_CLOSED  
    When talking to Lindormi, it's possible we're still combat restricted. Reschedule the keystone refresh until after combat ends.  
