# Auto Potion

## [3.16.4](https://github.com/ollidiemaus/AutoPotion/tree/3.16.4) (2026-10-04)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/3.16.3...3.16.4) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Add optional Soulburn support for Healthstone (Warlock, Retail) (#121)  
    * Add optional Soulburn support for Healthstone (Warlock, Retail)  
    Users requested Soulburn support. Soulburn is off the GCD and must be cast  
    right before the Healthstone to empower it (+30% healing, +20% max health).  
    Adds an opt-in, Warlock-only setting that prepends '/cast [combat] Soulburn'  
    to the AutoPotion macro. The line is only added when the talent is known and  
    a Healthstone is in the bags, and is skipped if it would push a standard  
    macro over 255 characters. It stays outside the castsequence so a missing  
    Soul Shard can never block the sequence. Macro output is unchanged when the  
    option is off.  