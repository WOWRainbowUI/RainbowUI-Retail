# Auto Potion

## [4.0.9](https://github.com/ollidiemaus/AutoPotion/tree/4.0.9) (2026-11-16)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/4.0.8...4.0.9) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Weakest Food/Drink First: optional weakest-first food and drink priority (#174)  
    * Weakest Food/Drink First: optional weakest-first food and drink priority (#173)  
    Two opt-in boxes, both off by default: "Weakest Food First" on the  
    AutoFood page and "Weakest Drink First" on the AutoDrink page make the  
    macro use the item restoring the least health (food) or mana (drink)  
    first, for leveling.  
    Every food and drink item now records what it restores in its tags (hp,  
    mp, hpPct, mpPct or scaled), with a table of its own under a flavor's  
    name where that client differs (Forever's reworked food, Mists' scaled  
    food). ham.weakestFirst ranks a copy of the normal list: conjured items  
    first, weakest first; then the comparable rest by the macro's stat; then  
    what can't be compared (a share in a list of flat amounts, a scaled  
    amount, none) in list order. Ties keep list order, buff food keeps its  
    slot and ham.orderBuffFood still places it. A list is ranked by flat  
    amounts, or by shares where it has none (Retail).  
    wago\_check.py reports a RESTORE line when an item's recorded amounts  
    don't match its flavor's client, with the record it should have. The  
    amounts were filled in from the same client data.  
    * weakestFirst: one amount helper, comparator at file scope  
    From the review: the scaled check was written twice, and each call made a  
    new sort closure.  
- Glossary and ADR for Weakest Food/Drink First  
