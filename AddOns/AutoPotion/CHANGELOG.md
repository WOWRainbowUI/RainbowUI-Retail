# Auto Potion

## [4.0.1](https://github.com/ollidiemaus/AutoPotion/tree/4.0.1) (2026-10-23)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/4.0.0...4.0.1) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Update for 12.1.7 (#157)  
    * Update interface version for 12.1.7  
    * Read spell durations from builds whose SpellDuration columns have no names yet in the item check  
    * Remove Lily Root from the AutoPotion macro on WoW Forever (needs Lei of Lilies equipped there)  
- Lint globals and run the checks in CI; store text files with LF  
    ci.yml runs luacheck, check.sh and the test suite on every push to main  
    and on pull requests, so a red push shows up before a release. The  
    .luacheckrc is about globals: a leaked global or a misspelled API name  
    fails it, while unused values and line length stay with review.  
    .gitattributes stores text with LF. The locale files, Locales.xml,  
    embeds.xml and AceLocale's XML were CRLF, which scripted edits turned  
    into whole-file diffs. Only line endings and the trailing whitespace  
    luacheck reported change.  
- Remove Rapid Regeneration from the AutoPotion macro and spell list (Forever)  
    The Troll racial is only a bandage spell now: the AutoBandage macro casts  
    it, the AutoPotion page has no box for it and the AutoPotion macro leaves  
    it out, even when the saved spell list still holds its ID.  
    Closes #156  
- Cast Rapid Regeneration before the bandage on Forever (AutoBandage)  
    The AutoBandage macro casts the Troll racial first and uses the best  
    bandage while it's on cooldown, through a castsequence since neither  
    triggers the global cooldown. A checkbox on the AutoBandage page (Forever  
    only, on by default) turns it off, and the Bandage Priority preview shows  
    the spell first whenever the macro uses it.  
    Closes #155  
- Find the food buff and Relaxed by translated name in the fake client  
    The fake client takes a locale (GetLocale) and translated spell names  
    (spells[id].names), which C\_Spell.GetSpellName and the auras report.  
    New tests show a deDE and a frFR client finding Well Fed, and Retail  
    deDE finding Hearty Well Fed and Relaxed (frFR too).  
    Closes #154  
- Add GLOSSARY.md with the domain language  
- Keep the remembered food buff and Relaxed while auras are hidden (#153)  
    While the client reports auras as hidden (C\_Secrets.ShouldAurasBeSecret: encounters, M+, PvP),  
    the aura lookups find nothing. The buff watches now keep their remembered state and rescan  
    once auras can be read again: on the next player UNIT\_AURA or ADDON\_RESTRICTION\_STATE\_CHANGED.  
    The fake client gets a switch that hides auras (Client:hideAuras / showAuras).  
- Drink buff drinks only while Relaxed is missing (AutoDrink, Retail)  
    "Only when the buff is missing" now orders AutoDrink too: with it on, the  
    buff drinks (Argentleaf, Sanguithorn and Azeroot Tea) go first, ahead of  
    conjured drink, while the player lacks Relaxed, and last while they have  
    it. Relaxed is found by its translated name (spell 1269152). It and the  
    food buff are followed separately: Well Fed doesn't move teas and Relaxed  
    doesn't move food. A change of either rebuilds the macros and redraws the  
    open previews.  
    The food and drink getters share one ordering rule, and the food buff's  
    aura tracking became one watch per buff.  
    Closes #152  
- Count every food buff for "Only when the buff is missing"  
    Besides Well Fed, Retail's Hearty Well Fed counts, found by its translated  
    name (spell 454188). Classic Era to Mists also count the stat food buffs  
    whose name isn't Well Fed (Increased Stamina, Agility, Intellect and Spirit,  
    Mana Regeneration, Blessed Sunfruit, Enlightened, Healthy, Grummlecake,  
    Squirmy Feeling), found by spell ID, since a buff of the same name from  
    another source mustn't count. Forever's Nutritious Food leaves Well Fed,  
    which already matched; a test now says so.  
    The fake client counts C\_UnitAuras.GetPlayerAuraBySpellID calls.  
    Closes #151  
- Eat buff food only while the food buff is missing (AutoFood, Well Fed)  
    A new option under "Include Buff Food" on the Food page, off by default and  
    greyed out while its parent is unticked. With both on, buff food goes first,  
    ahead of conjured food, while the player lacks Well Fed, and last while they  
    have it. The food buff is found by its translated name (spell 19705) and  
    followed through UNIT\_AURA for the player; only a change of it rebuilds the  
    macros and redraws the open previews.  
    The fake client gains player auras, UNIT\_AURA with update info, the  
    C\_UnitAuras and AuraUtil lookups, and disabled buttons.  
    Refs #150  
- Treat Boiled Clams as plain food on Forever  
    Forever's client casts plain Food for them and gives no food buff, so Forever gets  
    its own untagged entry in the plain food list next to Tough Jerky. The other  
    flavors keep them as buff food.  
