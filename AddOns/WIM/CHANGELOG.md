# WIM

## [3.19.7](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.19.7) (2026-11-13)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.19.6...3.19.7) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Merge pull request #314 from Mouchoir/fix/send-before-msgbox-hide  
- Send from chat windows before the edit box loses its focus  
    The shared msg\_box OnEnterPressed trigger ran its keep focus step  
    (Hide/Show when keepfocus is off) before the chat and whisper engines  
    sent the message, so on WoW Forever the client blocked the send  
    (ADDON\_ACTION\_BLOCKED UNKNOWN()). Run that step on the next frame.  
    Fixes #313  
