# BuffReminders

## [v4.7.0](https://github.com/zerbiniandrea/BuffReminders/tree/v4.7.0) (2026-03-29)
[Full Changelog](https://github.com/zerbiniandrea/BuffReminders/compare/v4.6.4...v4.7.0) [Previous Releases](https://github.com/zerbiniandrea/BuffReminders/releases)

- fix: 🚑️ guard aura iteration against tainted spellId in restricted contexts  
- feat: 👔 show delve food reminder only for 30s on entry instead of permanently  
- feat: ✨ add dismiss button to hide consumable reminders until next loading screen  
- chore: 🔧 skip minimap in DeepCopyDefault and consolidate stale key cleanups  
- fix: 🐛 hide soulwell reminder when cooldown state is unreliable  
- fix: 🐛 debounce pet evaluation after dismount to prevent false positives  
- fix: 🐛 show real countdown seconds on eating icon instead of <1m  
- perf: ⚡️ micro-optimize hot paths in buff state refresh cycle  
- fix: 🐛 show <1m instead of jumpy seconds for expiring buffs  
- feat: 🌐 add localization system  
