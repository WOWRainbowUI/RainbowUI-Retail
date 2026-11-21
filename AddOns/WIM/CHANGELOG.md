# WIM

## [3.19.8](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.19.8) (2026-11-20)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.19.7...3.19.8) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Fix: Conversation menu was closing before a click could be registered when anchored to trigger points other than the minimap icon (AddonCompartment).  
    - Menu now anchors relative to the requested point, but on the UIParent.  
    - Added a PseudoHide() function to menu which will set the alpha to 0 for a short while before actually hiding. This is useful in cases where you want the menu to hide, but still need the click to be registered.  
- Fix how CHAT\_MSG\_SYSTEM online/offline/no-user events were being handled.  
    Events were being handled in the filter. Separated it out to its own handler. The filter strictly decides whether or not to suppress the message. #320  
- Fix: Alerts for BattleNet users coming online and going offline were getting suppressed.  
    They are now handled the same way as a normal friend coming online / offline. Suppression rules only apply if chat window with user is open. Message is routed to the user's window if currently monitoring an active session. #318  
- Enhance BattleNet integration and improve message formatting in chat history. Stream mode now shows privatized battle tag instead of toon name for better consistency between history and live conversations.  
- Refactor and add addition BattleNet utility functions and show BNet account names in history instead of battle tags. The display of names respects the streaming mode preference.  
- Reorganize utilities into their own files and namespaces.  
- Add Bnet icon to history viewer user list.  
- History now properly outputs message as a player or BNplayer in both the history viewer and the history preview.  
- feat: Implement global shift-click handling for chat edit boxes.  
- Merge pull request #316 from @Mouchoir/fix/shift-click-name-into-chat and right click menu.  
    - Let a Shift-clicked name reach the default chat box untainted  
    - Let right click menu work without blocking. Copy Character Name works!  
- Experiment with setting ACTIVE\_CHAT\_EDIT\_BOX directly on WIM focus and setting it to nil on focus lost. Doing so should avoid taint since nil values can not hold taint.  
- chore: Stop loading source files not currently being utilized. Kept in project for posterity.  
