# Hekili

## [v11.0.2-1.0.0](https://github.com/Hekili/hekili/tree/v11.0.2-1.0.0) (2024-08-14)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.0-1.0.5...v11.0.2-1.0.0) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Merge pull request #3464 from yurikenus/master  
    Various Changes from HPal Testing  
- Merge pull request #3453 from Wyste/war\_within  
    Warrior 11.0.2 changes  
- Specialization updates.  
- Fix MageFrost GetSpellInfo  
- Fix IsSpellActive  
- TWW Warrior Slayer spec changes  
- Survival priority fix  
- Fix line\_cd  
- Havoc priority tweaks  
- Blood, Frost DK, Vengeance, Balance, Feral 11.0.2 changes  
- Blood: Coagulating Blood  
- 11.0.2  
- Added Consecration Buff for Strength of Conviction  
    Consecration: Strength of Conviction talent gives a buff (188370) which you can lose by walking out of it, so buff.consecration.up won't detect it using the other code handling that.  I added this buff to detect only the you're-standing-in-it-now part as that might want to trigger an early recast for folks.  I confirmed that the spell ID is the same whether you have 1 or 2 points in the talent.  
- Various Changes from HPal Testing  
    - Afterimage: added stack tracking and usage for Afterimage, which is under a separate spell ID 400745.  Spending holy power adds stacks, casting Word of Glory can remove them.  Tested stacking and it caps at 39, and using WoG only removes 20 stacks.  The WoG that triggers spending will also add stacks if HP was spent.  If HP wasn't spent due to Divine Purpose or Shining Righteousness, stacks are not added.  
    - Blessing of Sacrifice: cooldown was increased in 11.0.  
    - Rising Sunlight: this can stack to 4, so if you use Divine Toll *and Wings (in either order), you can have 4 stacks up at once.  
- Warrior 11.0.2 changes  
