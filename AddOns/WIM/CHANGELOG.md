# WIM

## [3.16.8](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.16.8) (2026-03-25)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.16.7...3.16.8) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Attempt to fix issues working with secrets in regard to intercepting activity in the ChatEditBox. This completely bypasses Blizzards SetLastTellTarget. In prelim tests, this hasn't caused issues, but in real life practice it might. let me know. #250  
- Removed default behaviors from censored message handling. They were not needed. This fixed issues with secret tainting. Also fixed various related formatted bugs that had existed prior such as message formatting and modifiers.  
- Re-enable censored messages. There is a known issue though that it will malfunction if a censored message is received while in chat lock down. WIM is doing everything possible to stay clear of the message, BUT blizzards internal tables become tainted. If you are experiencing problems, it is best to disable message censoring.  
- Cache which chat lines contain secrets.  
- In order to reducing the level of tainting of the default chat frame, I'm moving the scope of hooking/manipulating to the function level of GetActiveWindow. Hopefully this will allow for item linking to continue working without breaking other things.  
- Debugging some reply issues. Reverting solution for universal link inserting.  
- Change: Remove color formatting to name in ignore user dialog. #246  
- fix: When hooking reply tell, don't call originating functions on editBox if editBox belongs to WIM. #248  
