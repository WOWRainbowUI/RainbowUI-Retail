# DBM - Core

## [12.0.19](https://github.com/DeadlyBossMods/DeadlyBossMods/tree/12.0.19) (2026-02-13)
[Full Changelog](https://github.com/DeadlyBossMods/DeadlyBossMods/compare/12.0.18...12.0.19) [Previous Releases](https://github.com/DeadlyBossMods/DeadlyBossMods/releases)

- prep new tag  
- Update localization.ru.lua (#1903)  
- Update translations (#1904)  
    Co-authored-by: anon1231823 <anon1231823@users.noreply.github.com>  
- Yay with fixing errors with more strict LuaLs definitions  
- Push luaLS fix  
- Scope some LuaLS checks for better protection against Copilot Fing things up  
- Add debugmode stuff to timeline events for developers  
    Improve dimmy hardcode to extend support through first platform mythic. non hardcode will now have flight timer for 2nd platform as well  
- Also nil color on blizz timers if color by type is disabled, fully restoring generic bar color fades and styles in that situation too  
- Add some placeholders at least  
- add new GUI text for translation for the Bar colors panel  
- not all timers have event Ids, this work around is still needed too  
- LuaLS can't typecast correctly for optinos returns  
- Fix white bars by force setting ALL event Ids to DBM color.  
- Update koKR (#1898)  
    Co-authored-by: Adam <MysticalOS@users.noreply.github.com>  
    Co-authored-by: Artemis <QartemisT@gmail.com>  
