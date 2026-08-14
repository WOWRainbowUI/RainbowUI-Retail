# Myslot

## [v6.0.0](https://github.com/tg123/myslot/tree/v6.0.0) (2026-06-26)
[Full Changelog](https://github.com/tg123/myslot/commits/v6.0.0) 

- Hide unsupported export options cross-version (#119)  
    * Hide unsupported export options cross-version  
    Hide export/import/clear options for features the running client can't use,  
    instead of showing entries that fail or no-op on the wrong client:  
    - Cooldown Manager: gate on C\_AddOns.IsAddOnLoaded("Blizzard\_CooldownViewer").  
      The C\_CooldownViewer namespace (incl. GetLayoutData/SetLayoutData and  
      IsCooldownViewerAvailable) is present on Classic Era, so a namespace check  
      leaks; the Blizzard\_CooldownViewer addon only loads on retail.  
    - Click Cast Bindings: gate on the C\_ClickBindings namespace, which is  
      genuinely absent on Classic.  
    - Pet Action Bar: gate on the player's class (HUNTER/WARLOCK/DEATHKNIGHT/MAGE).  
    Routes the GUI export/ignore menu, clear menu, and options.lua "Remove all"  
    buttons through MySlot:Is*Supported(), and gates the functional export/recover/  
    clear paths. options.lua reflows the clear buttons so hidden entries leave no gap.  
    Also make the in-game macro test use the authoritative macro index from the  
    live list rather than CreateMacro's return (not the macro index on Classic Era),  
    and fix the in-game cooldown test skip-guard to use IsCooldownManagerSupported().  
    Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>  
    * Address PR review: fix clear-button spacing and mage pet gating  
    - options.lua: anchor the "allow clear on import" checkbox at rowy (not  
      rowy - 30); rowy already points to the next free row after the last visible  
      clear button, so subtracting another 30px left a blank row / pushed the  
      checkbox down on retail.  
    - Myslot.lua: mages only get a controllable Water Elemental pet bar on WotLK+  
      (interface >= 30000), so gate MAGE pet support on GetBuildInfo instead of  
      treating it as pet-capable on every client (it never is on Vanilla/TBC).  
    - ci/wow\_stubs.lua: make GetBuildInfo's interface version stub-overridable.  
    - tests: cover the mage build gate (retail supported, 1.x not).  
    Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>  
    ---------  
    Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>  