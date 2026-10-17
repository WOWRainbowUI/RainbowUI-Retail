# DBM - Core

## [12.1.15](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.1.15) (2026-10-16)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.1.14...12.1.15) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- Update koKR (#2255)  
    Update koKR  
- Update translations (#2254)  
    * Update translations  
- Expand gear checks to all game versions, not just retail (#2257)  
    * Expand gear checks to all game versions, not just retail  
- Fix up coiled alter LFR  
- Add true LFR routing to Ulatek, change old LFR routing to story (where it was pulled from)  
- Add experimental less tainty approach to objective tracker based on AI mocks testing all possible methods against blizzard UI code and finding setalpha is only method that might work. Gated behind debug mode for now for testing. Ref https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2198  
- replace profile options with a unique explanation panel explaining where to find the actual profile options when clicking on the current season category. resolves https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2202 (#2253)  
- make it so delves no longer play victory music on win, since win condition in almost always a boss that is already playing a victory song.  
- Fix https://github.com/DeadlyBossMods/DeadlyBossMods/issues/2256 by including mod.id in the timer object so each mod starting one starts one with a different timerID, eliminating cliping going forward. As well as change text on timer for zone based timers such as delves and scenarios  
- Tweak color usage  
- Expand scope of secret based trash/boss alert systems to forever across the board.  
- Most channels have pre cast, so make actual channel alert off by default  
    Most delves have a lot of non elite enemy casts that are useful so allow non elites in delves  
    Also add non elites to dungeons and raids but off by default.  
- delves have rare elites  
- wording tweaks  
- make the trash alerts independant options for delves raid and dungeons.  
    make delves also support using it automatically for bosses that lack hardcodes  
- make forever debug logging as verbose as possible  
- Kithix normal routing  
- Add LFR routing t Kithix  
- Update RU locales (#2252)  
    Update RU locales  
- Guild sync localization (#2175)  
    Guild sync localization  
- Fix stats so both story and lfr show  
- bump alpha  
