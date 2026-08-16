# WIM

## [3.17.4](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.17.4) (2026-08-14)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.17.3...3.17.4) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Merge pull request #273 from anon1231823:ginvite-button  
    Guild invite button and Edit Box for sliders  
- remove dead code  
- change show/hide position again  
- remove dead code  
- remove greyout references  
- Hide button if not applicable  
- Change Ignore User to Ignore Player  
- Update translations  
- remove friend toggle  
- grey out ginvite button if you dont have permission to invite  
- grey out if ignored  
- Change buttons  
- Friend button greys out if the person is already friend  
- edit box  
- update ptBR  
- Guild invite button  
- Update where custom fonts are used as well as how fonts are defined in skins. Skin can now contain an object, a path, or a SML reference. #80  
- Fix: Refresh minimap menu after skin is applied #80  
- Fix: If selected skin doesn't exist on VARIABLES\_LOADED, temporarily load the default skin until it is registered. #80  
- Fix lua linting error  
- Added skinning to menu objects. (WIM minimap icon menu, and chat window user lists)  
- Add module event "OnSkinLoaded", fired whenever when WIM is loaded as well as whenever a skin selection is changed.  
- Fix error when updating player location from shortcut bar #271  
