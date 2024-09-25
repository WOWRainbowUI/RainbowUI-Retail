# Hekili

## [v11.0.2-1.0.17](https://github.com/Hekili/hekili/tree/v11.0.2-1.0.17) (2024-09-25)
[Full Changelog](https://github.com/Hekili/hekili/compare/v11.0.2-1.0.16c...v11.0.2-1.0.17) [Previous Releases](https://github.com/Hekili/hekili/releases)

- Demo and Destro updates, textures  
- Assassin priority tweak and option  
- Distinguish HoL free/ready  
- WW priority tweak  
- Frost Comet Storm  
- Aug priority work  
- Consuming Fire known ID  
- Merge pull request #3677 from johnnylam88/feat/caption  
    feat: auto-import captions from APL profile  
- Merge pull request #3843 from johnnylam88/fix/monk-instant-vivify  
    fix: properly account for Vivacious Vivification for monk  
- Merge pull request #3844 from johnnylam88/feat/refracting-aggression-module  
    feat: add absorb buff from Refracting Aggression Module  
- Merge pull request #3846 from Spike2D/thewarwithin  
    Trinket Foul fixed, Prot Warrior Mitigation fixed, and Prot Warrior unused setting removed.  
- Add files via upload  
- Add files via upload  
- More fixed to Victory Rush  
- Formatting of Victory Rush Setting  
- Victory Rush added to SimC  
- Victory Rush settings added, SimC updated.  
- Added updated profile  
- Removed last\_stand\_offensively  
- Foul Trinket ID Fixed  
- Fixed Prot Warrior Mitigations  
- feat: add absorb buff from Refracting Aggression Module  
    Add the buff for the absorption shield that procs when you taunt with  
    the Refracting Aggression Module tanking trinket.  
- fix: properly account for Vivacious Vivification for monk  
    The Vivacious Vivification monk class talent makes the next Vivify  
    instant and reduces its cost by 75%. Properly remove the buff when  
    Vivify is cast and add functions for "cast" and "spend" to account for  
    the buff.  
- feat: allow for textures in the caption string  
    Allow for textures in the caption string if the texture ID is enclosed  
    in square brackets, e.g., [461115] will get replaced by the texture for  
    Rapid Fire in the caption string.  
- feat: extract a caption for an action from its comment  
    In the APL profile, when pairing up a comment as the description for the  
    action in the subsequent line, if the comment has the format  
      <Caption> :: <Description>  
    then `<Caption>` is used as the caption for the action, and  
    `<Description>` is used as the description for the action. Otherwise the  
    comment is used unmodified as the description for the action.  
- feat: support multi-line comments in APLs  
    In an APL profile, if a comment line is followed immediately by another  
    comment line, then assume that they are part of the same comment and  
    simply concatentate them together as the subsequent action's  
    description.  
- feat: support a "caption" modifier in the action syntax  
    Support a `caption=...` key-value modifier in the action syntax that  
    works like the `description=...` modifier and allows for annotating an  
    action with a caption.  
