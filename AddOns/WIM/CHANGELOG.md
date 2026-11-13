# WIM

## [3.19.6](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.19.6) (2026-11-12)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.19.5...3.19.6) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Enhance forward slash key detection logic for QWERTY keyboards.  
    - if demand calls for it, an option will have to be added to allow user to select their keyboard type. For example, "/" on a German keyboard is `Shift + 7`. I don't believe using the game's locale to determine the keyboard type.  
    - since on key down is specifically looking for the `/` key, I think this feature handler will just never get called in such an instance.  
- Remove the reload prompt after Edit Mode  
    The prompt was added because WIM's Edit Mode integration caused protected  
    action errors. Their cause is gone: WIM no longer adds anything to the  
    Edit Mode manager. The prompt would now warn of a risk that is not there.  
- Open Edit Mode from the options only the way the client allows  
    ShowUIPanel passes a frame to secure code only when the frame is a managed  
    UI panel. Retail and WoW Forever register the Edit Mode manager as one.  
    Classic Era does not, so there the Edit Mode button of the options showed  
    the manager from addon code and Edit Mode was entered tainted. On such a  
    client the button now opens the game menu, whose own Edit Mode button is  
    secure, and says so.  
    The button also asks the manager whether Edit Mode can be entered, as the  
    game menu and the slash command do, and is disabled when it cannot.  
- Keep WIM's Edit Mode checkboxes out of the game's own list  
    WIM added its three checkboxes to the Edit Mode manager's  
    settingsCheckButtons table, parented them into the manager's containers  
    and called LayoutSettings and Layout itself. Blizzard's LayoutSettings  
    walks that table with pairs, so the game's own code ran tainted by WIM.  
    After a click on Advanced Options or on the expander a tainted account  
    setting was stored, and from then on every checkbox of the manager ran its  
    refresh tainted. Reported on WoW Forever as a blocked TargetUnit() and as  
    "arithmetic on a secret number value (execution tainted by 'WIM')" in  
    CompactUnitFrame; retail and Classic Era run the same code.  
    The checkboxes now sit in a frame WIM owns, docked under the manager (above  
    it when there is no room below). Nothing is written to the manager, no  
    frame is created inside it and none of its layout methods is called.  
- Merge pull request #311 from Gogo1951/update-workflow-actions  
    Update GitHub Actions in release workflow  
- Update GitHub Actions in release workflow  
    Bump actions/checkout from v5 to v7.  
    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>  
- Improved tab UI and expanded options in skin table.  
- Remove debugging output  
