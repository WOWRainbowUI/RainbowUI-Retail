# Auto Potion

## [4.0.3](https://github.com/ollidiemaus/AutoPotion/tree/4.0.3) (2026-10-26)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/4.0.2...4.0.3) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- wago\_check guards the cooldown talent table (#162)  
    Each ham.cooldownTalents entry must be in the newest build's talent tree  
    (TraitDefinition) and have a cooldown aura (341, or 107/219 with misc value 11)  
    of -seconds x 1000; otherwise the run fails and names the talent.  
- Cooldown talents shorten the reset timer (#161)  
    The first entry's reset timer now takes off the seconds of the cooldown  
    talents the player knows, so it follows the spell's real cooldown: a  
    Retail priest with Angel's Mercy gets reset=combat/70 for Desperate  
    Prayer. Each flavor's spell file can list its cooldown talents in  
    ham.cooldownTalents (talent spell id -> spell and seconds); Retail lists  
    Angel's Mercy, Natural Mending, Frequent Donor and Death Defiance, the  
    other flavors none. A talent counts while C\_SpellBook.IsSpellKnown  
    (IsSpellKnown on Wrath and Cata) reports its spell id; talent changes  
    already rebuild the macro through TRAIT\_CONFIG\_UPDATED.  
    The fake client can pick and drop a talent: the spell becomes known or  
    unknown, then SPELLS\_CHANGED and, where the flavor has it,  
    TRAIT\_CONFIG\_UPDATED fire.  
- The first entry sets the reset timer (#160)  
    With the cooldown option on, the AutoPotion macro's reset timer now comes  
    from its first entry only and is worked out on every rebuild: the first  
    spell's base cooldown, else a Healthstone's on-use spell's. Potions, the  
    tinker slot and spells without a base cooldown (Healing Elixir) leave it  
    at reset=combat. The shortest-cooldown value no longer carries over  
    between rebuilds, and the Demonic Healthstone special case and the Spell  
    object's unused cooldown field are gone.  
    The option gets a new label and a tooltip (enUS only; the old string is  
    removed from every locale), and the README describes the new rule. The  
    fake client can hover a settings check box and read its tooltip.  
- Add cast sequence terms to the glossary (first entry, sequence reset, reset timer, cooldown talent)  
