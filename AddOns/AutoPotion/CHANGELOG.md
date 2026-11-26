# Auto Potion

## [4.1.3](https://github.com/ollidiemaus/AutoPotion/tree/4.1.3) (2026-11-24)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/4.1.2...4.1.3) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Add mana gem cooldown skip and separate AutoManaGem macro option (#172)  
    * Show mana potion in AutoManaPotion when mana gem is on cooldown  
    * Add option to separate mana gems into an AutoManaGem macro  
    # Conflicts:  
    #	code.lua  
    #	tests/mana\_gem\_test.lua  
    * Address PR #172 review feedback  
    * Address second-round PR #172 review feedback  
    * Fix remaining edge cases for AutoManaGem deletion and rune fallback  
    * Revert rune-over-potion skip and preserve pending AutoManaGem deletion across Reset  