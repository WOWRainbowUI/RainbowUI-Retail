# Hekili

## [v11.0.7-1.0.0](https://github.com/Hekili/hekili/tree/v11.0.7-1.0.0) (2024-12-23)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.5-1.0.20...v11.0.7-1.0.0) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Arcane priority update  
- Handle SEF texture / fixate.  
- Merge pull request #4234 from huchang47/Add\_Potions  
    Add Algari Healing Potion and Cavedweller's Delight  
- Update Classes.lua  
    Fix token  
- Merge pull request #4239 from Apeng7364/thewarwithin  
    MonkWindwalker update black out kick proc stack count  
- Merge pull request #4242 from joshjau/demonology-warlock  
    add power siphon and felstorm conditions to demonology simc  
- Merge pull request #4241 from joshjau/warrior-reflects  
    Spell Reflect Updates - Additional Spells  
- Merge pull request #4250 from joshjau/warrior-fury  
    fury: add storm bolt support during bladestorm  
- Merge remote-tracking branch 'upstream/thewarwithin' into warrior-fury  
- Frost Mage priority update  
- TOC update for 11.0.7  
- fury: add storm bolt support during bladestorm  
    - Added Storm Bolt actions after each Bladestorm cast in priority lists  
    - Added usable check in Lua file to prevent Storm Bolt usage during Bladestorm without Unrelenting Onslaught talent  
- Update ReflectableSpells.lua  
    - Reorganized spells by dungeon/raid  
    - Added missing TWW Season 1 M+ dungeons (Necrotic Wake, Mists of Tirna Scithe, Siege of Boralus)  
    - Added new raid spells for The War Within  
    - Grouped content into clear sections:  
      - Grim Batol  
      - The Dawnbreaker  
      - The Stonevault  
      - City of Threads  
      - Ara-Kara, City of Echoes  
      - The Necrotic Wake (S1)  
      - Mists of Tirna Scithe (S1)  
      - Siege of Boralus (S1)  
      - Raid: The War Within  
      - Test Dummy  
- add power siphon and felstorm conditions to demonology simc  
    ported from simc source (sc\_warlock\_pets.cpp, sc\_warlock\_actions.cpp):  
    power siphon:  
    - prevent core capping before tyrant window  
    - checks for < 3 demonic cores  
    - tyrant cd > 25s  
    - not during demonic power buff  
    felstorm:  
    - add cleave logic for fel sunder builds  
    - requires 2+ targets  
    - checks demonic strength talent/cd  
    - requires fel sunder talent  
    also cleaned up some tyrant timing logic and imp despawn variable tracking  
- Spell Reflect Updates - Additional Spells  
    Added several missing reflectable spells to the database:  
    ## The Necrotic Wake  
    - Added additional ID for Frozen Binds (320788) to Nalthor the Rimebinder  
    - Added Spew Disease (333479) to Zolramus Sorcerer  
    - Added Disease Cloud (333482, 333485) to Zolramus Sorcerer  
    ## City of Threads  
    - Added Silken Tomb (439814) to Izo, the Grand Splicer  
    - Added new spells to Eye of the Queen:  
      - Void Bolt (441772)  
      - Expulsion Beam (451600)  
      - Acid Bolt (448660)  
- Monk: update black out kick proc stack  
- Algari Healing Potion and Cavedweller's Delight of the current version have been added.  
