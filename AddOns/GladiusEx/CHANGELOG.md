# GladiusEx

## [2.8.2](https://github.com/vendethiel/GladiusEx/tree/2.8.2) (2024-06-13)
[Full Changelog](https://github.com/vendethiel/GladiusEx/compare/2.8.1...2.8.2) [Previous Releases](https://github.com/vendethiel/GladiusEx/releases)

- Updated SpecBuffs & SpecSpells (#95)  
    * Updated SpecBuffs & SpecSpells  
    - Updated the SpecBuffs & SpecList to one that is more correct for Cata (may still have some kinks, but I don't think so)  
    - Changed back to R1 on all spells except those that still have multiple ranks (from talents)  
    - Moved many spells from SpecBuffs to the actual SpecSpells list  
    - Removed Debuffs (because we never search through them anyway)  
    * Revert DR changes  
    Snuck in by mistake.  
- Forwardport GladiusEx-Cata/WotLK DR Tracker Fixes (#94)  
    Had enough trying to get the DRTracker with the new option to working properly so I just ported what actually works instead of trying to make it look fancy.  
    It might still have the issue with DRs having no icon in some scenarios, but I havn't been able to reproduce since I first got it day ~3. No clue if it's related.  
- Added the possibility to detect specs by mana (#93)  
    For example. Holy Paladins are the only Paladin spec with > 50000 mana in Cata (similar logic applies to the other specs in this commit).  
    Included WotLK mana pools as well, but excluded TBC because the pools between hybrid and healer specs are too close.  
- Fixed some interrupt stuff (#96)  
    - Spell Lock uses R2 from WotLK instead of R1  
    - Counterspell is now 7 seconds instead of 8 sec lockout  