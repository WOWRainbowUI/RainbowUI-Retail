# DBM - Core

## [11.0.26](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/11.0.26) (2024-11-11)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/11.0.25...11.0.26) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- Finish up the now tested wrest improvements  
- some notes  
- Update localization.br.lua (#1359)  
- Update localization.fr.lua (#1358)  
- Update localization.es.lua (#1357)  
- fix bug where reminders disable didn't actually disable reminders for missing mods.  
- Update koKR (#1356)  
- Update localization.ru.lua (#1355)  
- Update localization.tw.lua (#1354)  
- Update commonlocal.tw.lua (#1353)  
- Make this a countdown by default.  
- further robust and clarify  
- Fix ID  
- rework tanks wap code  
- Add auto gossip option for speed potion at entrance of raid  
- upgrade enveloping webs alert to special announce  
- Fix bug causing some timers not to do verbose timer debuging  
    fix alpha not actually saying alpha  
- Improve silken court clarity by showing linked target and clarify warning text to reflect as such too.  
    Voice pack will also only call for immediate break in stage 2, otherwise it won't be directive to break and instead just call out line on you instead.  
- Fix a bug that caused first blades timer in phase 3 to start wrong timer on mythic.  
- Make it so wrest alert only shows special announce if it's actually on your platform in stage 2, otherwise it shows general announce instead  
    Furthermore, timer will now fade if next one is NOT on your platform. which will auto disable countdown on objects as well, making countedown also reliable for knowing if it's on YOURS next.  
- adjust rolling acid timer to sync up to private aura debuffs going out, and not the wave cast  
- optimize to reduce comms somewhat. even though blizz didn't put even tin combat log and is making me use comms for this, doesn't mean I want to degrade server performance any more than nessesary  
- Use syncing for laser cast to make timer even more robust  
- Finally get around to fixing Kordac  
     - Laser personal alerts will now work scanning hidden auras  
     - Combat victory will now work using both yell text and unit spellcast event if either detected.  
     -  Laser AI timer will now display  
- Support "RemoveBleed" as an option default  
- Mocks: Fix GetUnitName() behavior on invalid arg (#1352)  
- remove game version 11.0.2 and add game version 11.0.7  
- scope all retail raids with setzone  
- bump cata tocs  
- add dummy scheduling to show timers and announcements for the crimson rains that don't have a cast event  
