# WIM

## [3.16.0](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.16.0) (2026-02-16)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.15.3...3.16.0) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- update readme  
- clean up classic hooking which shouldn't be needed anymore with the revised intercepts methods.  
- Merge branch 'master' of https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger  
- Add backup keybindings to totally bypass Blizzards Chat Reply/Re-Whisper  
- Additional hook rewrites for interception. There's a balancing act between having things work as they always have vs errors being thrown. With secrets and WIM needing to hide the chat edit box, there's just always going to be something.  
- Cleanup: Remove unused Sockets & Changelog, allowing the removal of ChatThrottleLib which causes tainting issues.  
- Merge pull request #216 from anon1231823/patch-72  
    Update zhTW.lua  
- Merge pull request #217 from anon1231823/patch-73  
    Update koKR.lua  
- Merge pull request #215 from anon1231823/patch-71  
    Update zhCN.lua  
- Fix: port changes to tbc anniversary  
- Update zhCN.lua  
- Update zhTW.lua  
- Update koKR.lua  
- Additional hook cleanup, simplifying even more, reducing more tainting. Also fixed a 17 year old typo =-o  
- fix: modern api reduce taints and overall better interception handling. legacy needs to be reassessed.  
- Update zhCN.lua  
- Update zhTW.lua  
- Update zhCN.lua  
- Update zhTW.lua  
- Update zhCN.lua  
- Record original timestamps for deferred events  
- Fix: refactor when SetTellTarget is called as to not Taint the default UI  
- Merge branch 'master' into feat-deferEvent  
- Fix: Improve how default edit boxes handle switching in and out of chat lock down mode.  
- Fix: When  chat messaging is locked down, do not intercept slash commands  
- New: Chat Events received while on messaging lockdown will now be deferred and processed by WIM when lockdown has been lifted.  
- Fix: When  chat messaging is locked down, do not intercept slash commands  
- update README.md  
