# LiteButtonAuras

## [11.1.7-3](https://github.com/xod-wow/LiteButtonAuras/tree/11.1.7-3) (2025-06-28)
[Full Changelog](https://github.com/xod-wow/LiteButtonAuras/compare/11.1.7-2...11.1.7-3) [Previous Releases](https://github.com/xod-wow/LiteButtonAuras/releases)

- Luacheck updates  
- Use PixelUtil to set overlay size more exactly  
- Be more explicit about src and dest unit for checks  
- Fix error with IsModifiedClick('FOCUSCAST')  
- Slightly improve GetMacroUnit and note it's limitations  
- Update .luacheckrc  
- Split the UnitState stuff out of Overlay completely  
- Simply refresh all overlays on ITEM\_DATA\_LOAD\_RESULT  
- Only show taunts on taunt spells, oops  
- GetMacroUnit no unit fallback to defaults  
- Show other taunts again, explicitly captured  
- OO-ify UnitState  
- Dry-code hack for GetActionUnit  
- Update luacheckrc for macrounit stuff  
- Use :gmatch mostly to make luacheck happy  
- Try to avoid s plurals a bit  
- Noodling around with supporting @unit  
