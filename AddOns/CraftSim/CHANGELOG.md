# CraftSim

## [20.2.1](https://github.com/derfloh205/CraftSim/tree/20.2.1) (2025-08-29)
[Full Changelog](https://github.com/derfloh205/CraftSim/compare/20.2.0...20.2.1) [Previous Releases](https://github.com/derfloh205/CraftSim/releases)

- chore: Update version to 20.2.1 and add patch notes for recent changes  
- [CraftQueue] Prevent duplicate patron order queueing (#871)  
    * early out if order is already queued  
    * Early outing too early before recipe identifiers were set  