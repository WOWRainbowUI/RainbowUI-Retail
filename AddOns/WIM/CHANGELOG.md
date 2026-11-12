# WIM

## [3.19.5](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.19.5) (2026-11-11)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.19.4...3.19.5) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Update github workflow to use checkout@v5  
- Key WoW Forever history by ruleset and bring in what was saved by realm name  
    Earlier versions saved a Forever character's history under the hidden realm  
    name the client reports, later ones under the ruleset, and nothing joined  
    the two. The ruleset check also had no RP-PvP and filed it under RP.  
    - The ruleset is read from the game rules as AceDB-3.0 reads it: Hardcore,  
      RP-PvP (the RP and PvP rules together), RP, PvP, else PvE. If the client  
      lacks one of the rules or does not answer, the realm name stays the key  
      and nothing is moved.  
    - At login the character's own history saved under the realm name moves  
      into its ruleset bucket. A conversation held under both is merged by  
      time; one that cannot be decoded stays where it is. An RP-PvP character  
      also takes over what was filed under RP, once.  
    - A realm name is never parsed. Other characters follow when they log in,  
      and history in the old table format follows one login after it is  
      converted.  
    - The debug log records the realm name, the three rules and the ruleset  
      chosen at load.  
- Never save a conversation under an empty name and recover those that were  
    On WoW Forever a character friend is a Battle.net friend without a  
    BattleTag. The client reports that BattleTag as an empty string, and History  
    chose the name with "btag or toonName or from", so the conversation was  
    saved under "". The History Viewer could not name that row: it printed the  
    "damaged beyond repair" notice, selected the row on open and stopped  
    loading, and its delete button raised an error.  
    - A conversation key is never empty. A friend without a BattleTag is saved  
      under the character name. With no name at all the messages go to one  
      "Unknown name" conversation.  
    - A friend for whom the client has a character whisper target gets a  
      character window, as the default chat does. A Battle.net window already  
      open for that friend becomes that window, and the title no longer repeats  
      the character name.  
    - A conversation stored under "" is loaded as "Unknown name", from the  
      archive and from the old table format. It can be read and deleted, and a  
      note button moves its messages to the name the user enters, merged by  
      time when that conversation exists.  
    Strings added to all locales.  
- Open the History Viewer on the current character again  
    The first view of a session is the character you are logged in as, as it  
    was before the recent whispers change. Opening the viewer from a message  
    window still shows that conversation across the realm.  
- Fix: In some cases, a window's title bar showed name and toon name even though they were the same.  
- Fix: logic typo  
- Adjust tab strip positions on modern skins.  
- Update tabstrip on skin change to correct positioning.  
- Fix window fading. It was a bit janky when switching between tabs.  
- Add option to set fade percentage of inactive windows. #4  
- Merge pull request #307 from icey2488/fix/bn-whisper-secret-header  
    Skip whisper intercept when the default edit box has a secret tell target  
- Merge pull request #310 from kastorny/fix/cyrillic-menu-fonts  
    Fix Cyrillic names in the Whispers menu  
- Fix Cyrillic names in the Whispers menu  
- After entering edit mode, display dialog suggesting user reload ui before continuing.  
- Refactor dialog calls to use WIM.utils.dialog for consistency across modules  
- Skip whisper intercept when the default edit box has a secret tell target  
    Battle.net whisper tell targets are secret in 12.x. When WIM moves focus  
    from a default chat edit box holding one, Blizzard's Deactivate ->  
    ResetChatType -> UpdateHeader runs in WIM-tainted execution and errors  
    on the header width arithmetic (ChatFrameEditBox.lua:679). Leave those  
    replies to the default edit box instead of stealing focus.  
    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>  
    Claude-Session: https://claude.ai/code/session\_01UBYw6xhP4jcj238ipw8ThD  
