# Details! Damage Meter

## [Details.20250918.13734.165](https://github.com/Tercioo/Details-Damage-Meter/tree/Details.20250918.13734.165) (2025-09-18)
[Full Changelog](https://github.com/Tercioo/Details-Damage-Meter/compare/Details.20250824.13705.165...Details.20250918.13734.165) 

- ChangeLog  
    Changelog:  
    - Fix m+ score when hovering over the player icon.  
    - Framework upgrade fixing issues in GUIs.  
    - Fix Fae Silence for Druids (chris102994).  
    - Fix statusbar clock plugin (Kyrios0).  
    - More polishment on keystone panel.  
    - Updated .toc files for libraries (Hollicsh).  
    - Crowd Control updates for Mists of Pandaria.  
    - Talent share on Mists of Pandaria.  
    - Add missing locales on enUS (K. Gilbert).  
    - Add Details! to Blizzard addon compartment (Wolvereness).  
    API added:  
    Details:GetKeyNameFromAttribute(attribute, subAttribute)  
    get the string to retrieve a value within an actor object.  
    Details:JustSortData(combatObject, attribute, subAttribute)  
    sort a container by the attribute and sub-attribute.  
- General fixes and updates  
- Merge pull request #925 from Kyrios0/fix-status-bar-clock  
    fix(status bar): Improve clock plugin timer and segment handling  
- Merge pull request #951 from chris102994/master  
    fix: add some missing CC for MOP  
- Merge pull request #954 from Wolvereness/main  
    Add Details to Blizzard's Addon Compartment  
- Merge pull request #957 from Hollicsh/master  
    Update the .toc files and some libs  
- Merge pull request #958 from kdashg/local-missing-mplus  
    Add locale entries missing after 7cc2ae753 for enUS.  
- Update for MOP crowdcontrol spells.  
- Add locale entries missing after 7cc2ae753 for enUS.  
    Fixes Lua errors on login/reload like:  
    ```  
    Message: AceLocale-3.0: Details: Missing entry for 'STRING\_NO\_MYTHIC\_PLUS\_ADDON'  
    Time: Fri Aug 29 13:51:32 2025  
    Count: 1  
    Stack:  
    [Interface/AddOns/Details/functions/slash.lua]:1928: in main chunk  
    ```  
- fix: add fae silence for druids  
- Share talent ids in Mists  
- Update the .toc files and some libs  
- Fix dropdown options being behind the scrollbar  
- Framework Update and Polishing in the keystone frame.  
- Add Details to Blizzard's Addon Compartment  
- fix: add some missing CC for MOP  
- Refactor and clean up Clock plugin timer logic  
    Removed redundant comments  
- Improve clock plugin timer and segment handling  
    Refactors the clock plugin to better manage the timer lifecycle:  
    - Ensuring the timer starts on enable and after reset, and only stops when the plugin is disabled.  
    - Updates the display logic to show current combat time during combat and segment duration otherwise handling for different time display types and segment differences.  
    - Updates event registration to use the new DataReset handler.  
