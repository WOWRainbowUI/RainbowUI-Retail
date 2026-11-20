# Auto Potion

## [4.1.0](https://github.com/ollidiemaus/AutoPotion/tree/4.1.0) (2026-11-17)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/4.0.9...4.1.0) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- AutoManaPotion: mana spells (Evocation, Innervate, Shadowfiend, ...) (#178)  
    * AutoManaPotion: mana spells (#177)  
    The Mana Potion page gets a "Mana Spells" section: every mana spell of the  
    flavor under a header per class plus "Other / Racial", all off. Ticked spells  
    the character knows go first in the AutoManaPotion macro, cast on the player  
    ([@player]), in the flavor's best-restore-first order, before the mana gem,  
    the mana potion and the demonic rune. The first entry's cooldown, with cooldown  
    talents, is the reset timer; Retail Evocation (a charge) gives none. With  
    nothing ticked the macro is what it was.  
    - Mana spells per flavor in Core/Spells/<Flavor>.lua (ham.supportedManaSpells),  
      ranks for Mana Tide Totem, Thunderstorm and Dark Sacrifice, Arcane Torrent as  
      one spell group on Wrath and Cata  
    - Cooldown talents Arcane Flows and Veiled Shadows on Wrath and Cata; of a  
      ranked talent only the highest known rank counts (rankOf)  
    - HAMDB.activatedManaSpells, empty by default, settings version 2  
    - The class spell section builder is shared by both pages  
    - Macros rebuild on LEARNED\_SPELL\_IN\_SKILL\_LINE, so a spell learned later joins  
    - wago\_check.py checks Wrath/Cata cooldown talents against the Talent table  
    - tests/mana\_spell\_test.lua on Retail, Classic Era and Forever  
    * Mana spells: review fixes (#177)  
    One branch on whether a mana spell leads the AutoManaPotion macro, and test  
    names that use the glossary's terms (mana gem, reset timer).  
    * Mana spells: Wrath, Cata and Mists ordered by restore (#177)  
    Within each class the spell that gives the caster the most mana back goes first,  
    from the client's spell effects: Wrath Shadowfiend (about 50%), Dispersion (36%),  
    Hymn of Hope (12%), and Mana Tide Totem (24%) before Thunderstorm (8%); Cata and  
    Mists Dispersion (36%), Shadowfiend (about 24-30%), Mindbender, Hymn of Hope (8%).  
- Glossary: Heal spell and Mana spell  
- AutoManaPotion: optional demonic rune as the last step (#175) (#176)  
    A new "Include Demonic Runes" box on the AutoManaPotion page, off by  
    default and not on Retail. With it ticked the macro uses one demonic  
    rune (Demonic Rune before Dark Rune) after the mana gem and the mana  
    potion. The reset timer is the first entry's cooldown, as before.  
    Closes #175  
- Glossary: Demonic rune  
