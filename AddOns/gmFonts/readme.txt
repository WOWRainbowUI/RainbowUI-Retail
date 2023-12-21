1010-2023050901
- added ## IconTexture: Interface\AddOns\*\icon.tga
- bump TOC

1000-2022120501
- fixed font GameTooltipHeader to remove the OUTLINE

1000-2022112401
- fonts added: OpenDyslexic

1000-2022110701
- implemented a fonts size delta to modify (-4 , +4) the size of the fonts where not fixed

1000-2022110601
- added X-WoWI-ID and X-Curse-Project-ID keywords to let WowUp manage it
- bump toc 

1000-2022102701
- update to work in the latest ver.10.0.0

900-2020101801
- update libs to the latest

900-2020101401
- bump toc
- first fixes to work with 9.0.x
- update libqtip to the latest
- changed the reference to the fonts name to _G.
- fixed a frame SetBackdrop in PhanxConfig-Dropdown.lua 

830-2020021901
- fixed a dropdown menu after a patch 8.3 change in Event("GLOBAL_MOUSE_DOWN")
Check: https://www.wowinterface.com/forums/showthread.php?t=57827

820-2019062801
- bump toc 

810-2018122201
- bump toc

801-2018071801
- first fix for pre-patch v8.0.1
- added fonts Roboto

730-2017091601
- fonts added: Droid Sans
- fonts added: Noto
- moved fonts descriptions out of the code in a new file: fonts.txt
- added a custom entry in LSM menu "My custom font" to use a custom user font. 
The font file has to be copied in fonts dir before the game is loaded with the name: 
myfont.ttf 

730-2017091201
- update Phanx's PhanxConfig-Dropdown using the official file and fix 

730-2017083101
- bump toc
- hack to fix Phanx's PhanxConfig-Dropdown changing the PlaySound() to use the new 7.3 syntax

720-2017032801
- bump toc

1.0-2016123101
- fonts added: Ubuntu Mono
- fonts added: Droid Sans Mono
- fonts added: AD Mono
- fonts added: Terminus
- fonts added: Ropa Sans
- fonts added: Dosis

1.0-2016112701
- fonts added: Happy Giraffe
- fonts added: Lady Bug

1.0-2016102601
- bump toc

1.0-2016092801
- codename "Claudia"
- removed Calibri Fonts due license problems. Use Carlito as dropin replacement.
- added a some fonts definitions from: https://github.com/Phanx/PhanxFont
- fix a typo in the Laurel definition
- added Lato fonts
- updated PhanxConfig-Dropdown to the latest 

1.0-2016070501
- updated for 7.0
- changed name and references to gmFonts

1.0-2015062401
- bump toc for 6.2

1.0-2015060201
- fonts added: lauren

1.0-2015051801
- fonts added: verdana

1.0-2015043001
- Used phanx widget class to manage the fonts lists: https://github.com/Phanx/PhanxConfig-Dropdown/wiki 
This prevent an off screen widget when there are too many fonts.
- Simplified and removed unused code.

1.0-2015040701
- fonts added: expressway

1.0-2015022501
- bump toc for 6.1

1.0-2015020804
- add a credit line
- fonts added: calibri (to be a drop in replacement for tekticles)
- fonts added: candara

1.0-2015020803
- fix a typo

1.0-2015020802
- removed debug code

1.0-2015020801
- fix a font path adding a .ttf at the end of a font name (even if it worked the same)
- now the addon can set the fonts for the whole UI.

1.0-2014101501
- initial release
- fonts added: Ace Futurism, PT Sans (replaces Myriad), Carlito (replaces Calibri), Ubuntu, Comic Neue