# BuffReminders

## [v6.2.2](https://github.com/zerbiniandrea/BuffReminders/tree/v6.2.2) (2026-07-16)
[Full Changelog](https://github.com/zerbiniandrea/BuffReminders/compare/v6.2.1...v6.2.2) [Previous Releases](https://github.com/zerbiniandrea/BuffReminders/releases)

- refactor(options): 💄 hoist category-specific sections above shared backbone  
- fix(secret): 🐛 guard aura and unit reads against secret values  
    Fixes a Lua error that could occur while checking buffs in combat, boss encounters, and Mythic+ on the 12.1 PTR, and improves performance when scanning auras in those situations.  
- refactor(state): ♻️ group instance context caches into one table  
- perf(events): ⚡️ cut aura update CPU usage in groups and combat  
- perf(secure): ⚡️ rewire click-to-cast buttons only when actions change  
- perf(loadouts): ⚡️ stop re-reading instance info for loadout reminders  
- perf(display): ⚡️ reduce redundant work when rendering reminder icons  
- perf(state): ⚡️ stop re-counting consumable items on every refresh  
- perf(state): ⚡️ reduce CPU and memory churn in buff state refreshes  
- fix(state): 🐛 harden sticky target memory (wipes, DCs, ready checks)  
