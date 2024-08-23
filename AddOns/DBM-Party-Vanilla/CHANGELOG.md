# DBM - Dungeons, Delves, & Events

## [r143](https://github.com/DeadlyBossMods/DBM-Dungeons/tree/r143) (2024-08-20)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-Dungeons/compare/r142...r143) [Previous Releases](https://github.com/DeadlyBossMods/DBM-Dungeons/releases)

- tweak only one nameplate timer in sacred flame. i need to verify mini bosses can actually be CCed before i waste time moving those timers  
- Move nameplate timers to success/interrupt events in Cinderbrew Meadery to account for stops nerf  
- restructure rookery trash to account for stops nerf.  
- Final pass on Stonevault fixing up all ability CDs with latest data and added some missing stuff  
    also fixed bosses with spell renames and timer updates and again attempt to further accuracy of spell queue speakers  
- Added support for City of Threads trash alerts and nameplate timers  
    this covers about anything I could find that i found useful and not too spammy. added notes about stuff I couldn't find  
- Completed a city of threads boss pass with lots of fixes with latest data  
- Create localization.tw.lua (#242)  
- Further timer data for speaker shadowcrown  
- Actually found a 15.2 on rashanan, so the CD can in fact go lower than 16 even. gotta love ability cds of 15.2-50 due to massive cooldown collision and no spell priority being set. Mod will do it's best...they all will in this zone, but it's gonna get a lot of "bug" reports :\  
- Put a pause on nerzhul code for now  
- Put Anubikkaj spell queue timer correction 2.0 into testing. Same principle as Remnant of Nerzhul used (to great success). none the less, new code only runs in debug mode til it recieves some testing.  
- Fully updated dawnbreaker trash module  
     - Nameplate timers moved from cast start events to success/interrupt events to align with the stops nerfs (since this was one of early mods completed)  
     - Added a few missing alerts and namepalte timers  
- Updated City of Echoes  
     - Anubzekt now has interrupt warning for Silken Restraints  
     - Anubzekt now has improved timers beyond first eye of the storm  
     - Avonoxx now has spell queue timer correction for improved timer accuracy  
     - Kikatal now has support for mythic version of Poison mechanic  
     - Kikatal had bad logic for spell queuing correction that was based off earlier incomplete data sets that now is correct based on fuller picture of data. (translation, improved timer accuracy)  
     - Kikatal killed off adds timer for now, since it feels like it's just unneeded spam.  
     - Added trash module that covers most notable warnings and nameplate CD timers. Once again it puts emphasis on spells on Quazii's spreadsheet  
- Update koKR strings in tocs (#241)  
- Finally pushed reworked Necrotic Wake  
    Almost all trash abilities now have nameplate timers  
    Fixed some situations trash warnings might fire during amarth since they use same spellId  
    Several missing trash warnings were added  
    Surgeon Stitchflesh has improved timers now, making use of nameplate timers for adds  
    Blightbone now has auto timer correction to deal with spell queuing, for greater accuracy  
    Amarth now has auto timer correction to deal with spell queuing, for greater accuracy  
    Amarth will now detect TWW spellId usage for frostbolt volley interrupts and give counts for them as well per add  
    Amarth will additionally again make use of nameplate CD timers on adds for those frostbolt Volleys :D  
- Fix one more toc  
- remove 10.2.7 and 11.0.0 game versions from tocs  
    Tweak audio for Crawth to say 'stop casting" if a spellcaster  
- Test updates (#240)  
- Fully update grim batol with latest data for all bosses  
    also updated all nameplate timers for grim batol to factor in stop nerf.  
- Reviewed and updated TIrna Scithe trash warnings and timers  
    Reviewed and updated all Tirna Scithe bosses as well  
