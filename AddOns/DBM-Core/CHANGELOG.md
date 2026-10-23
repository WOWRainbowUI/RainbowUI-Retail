# DBM - Core

## [12.1.17](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.17) (2026-10-22)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.16...12.1.17) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- Fix Chilling frost personal warning not firing in hardcode due to not waiting long enough for actual blizz event to be sent.  
    while at it, improve blizz event intercept to be more robust by passing severity when it can be used to disambiguate warning colision  
- Hide guild button if not in a guild in the gear check  
- Consumable check now flags shaman and paladin class specific weapon imbues as valid weapon status yes checks  
    Fallback Gear check no longer shows ? on players not running DBM when equiped items return uncached results.  
- fix raid checks tab template on classic flavors  
- more secret protection if pulling boss with frame still open (granted that should happen less often now with last update)  
- Auto close raid checks frame on pull timer or boss pull  
    don't restart consumables check if a check was already in progress at time a ready check is sent and ready check option enabled  
- cleanup 12.1.5 toc checks  
- bump alpha  
