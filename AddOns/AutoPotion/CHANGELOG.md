# Auto Potion

## [3.17.0](https://github.com/ollidiemaus/AutoPotion/tree/3.17.0) (2026-10-07)
[Full Changelog](https://github.com/ollidiemaus/AutoPotion/compare/3.16.5...3.17.0) [Previous Releases](https://github.com/ollidiemaus/AutoPotion/releases)

- Add /update-addon skill for patch updates  
    Claude Code skill that walks through updating the addon for a new WoW  
    patch: interface versions in the TOC, API changes, new consumables and  
    README. Includes check.sh for Lua syntax, undefined list entries and  
    duplicate item IDs.  
- Add AutoPotion's icon and show AutoSetup's and Wayscribe's on the information page (#131)  
    * Show AutoSetup's and Wayscribe's own icons on the information page  
    The "More addons" entries used the game's gear and book icons as  
    placeholders. AutoPotion now ships a copy of each addon's icon in  
    Media, so they show whether or not the addon is installed:  
    - Media/Wayscribe.tga is Wayscribe's Media/Icon.tga (ollidiemaus/wayscribe  
      PR #6), byte for byte.  
    - Media/AutoSetup.tga is the AutoSetup logo scaled to 128x128, in the  
      same format (uncompressed 32-bit TGA).  
    Only the game's own icons are cropped now: the 8% crop hides the border  
    baked into them, and the addon icons have none.  
    * Give AutoPotion its own icon in the AddOns list  
    Media/AutoPotion.tga is the AutoPotion logo scaled to 128x128, in the  
    same format as the other icons in Media (uncompressed 32-bit TGA). The  
    TOC's IconTexture points at it, so the game's AddOns list shows it  
    instead of the default icon.  
- Rework settings: information page, page order and spellbook-style spell list (#129)  
    * Rework settings: information page, page order and spell icons  
    - Add an information page as the AutoPotion root category, which /ap now  
      opens: a short "how it works", the macros, the slash commands and  
      links to AutoSetup and Wayscribe (copyable, since the game can't open  
      URLs).  
    - The healing settings move to an "AutoPotion" page below it, and the  
      pages are now ordered AutoPotion, AutoManaPotion, AutoFood, AutoDrink,  
      AutoBandage.  
    - Spells and items are listed spellbook-style (checkbox, icon, name) in  
      two columns so the names still fit next to the icon.  
    - Register settings with the modern Settings API whenever the client has  
      it: the old InterfaceOptions\_AddCategory identifies categories by  
      name, and the root and the healing page are both called "AutoPotion".  
    - New strings in enUS and deDE.  
    * Show "Installed" for addons that load after AutoPotion  
    The other addons' "Installed" labels were decided once while AutoPotion  
    was loading, so AutoSetup (which loads after it) never showed as  
    installed. Check again every time the information page is shown.  
- update toc to use tag version  
