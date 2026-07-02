# Font Sources for RGX-Framework

RGX-Framework now ships a curated bundle of downloaded open-source fonts chosen to give addon authors a stronger default selection across UI, serif, display, fantasy, pixel, and monospace styles.

## Important Limitation

WoW addons cannot safely enumerate a player's operating system font folders, so RGX does not support true "system font" discovery.

The practical replacement is:

- bundled fonts inside `RGX-Framework/media/fonts/`
- companion add-on font packs that register more fonts through `RGXFonts:RegisterFontPack(...)`
- per-addon packaged fonts registered through `RGXFonts:RegisterAddonFont(...)`

## Current Bundled Families

### Sans / UI
- Inter â€” https://rsms.me/inter/
- Ubuntu â€” https://design.ubuntu.com/font
- Liberation Sans â€” https://github.com/liberationfonts/liberation-fonts
- DejaVu Sans â€” https://dejavu-fonts.github.io/
- Lato â€” https://fonts.google.com/specimen/Lato
- Poppins â€” https://fonts.google.com/specimen/Poppins
- Rajdhani â€” https://fonts.google.com/specimen/Rajdhani

### Sans / UI â€” Temporarily Unavailable (corrupted assets)
- ~~Montserrat~~ â€” blocked in `unavailableFonts` pending asset replacement

### Serif
- Crimson Text â€” https://fonts.google.com/specimen/Crimson+Text

### Serif â€” Temporarily Unavailable (corrupted assets)
- ~~Merriweather~~ â€” blocked in `unavailableFonts` pending asset replacement
- ~~Playfair Display~~ â€” blocked in `unavailableFonts` pending asset replacement

### Monospace
- IBM Plex Mono â€” https://fonts.google.com/specimen/IBM+Plex+Mono
- JetBrains Mono â€” https://www.jetbrains.com/lp/mono/

### Display
- Bebas Neue â€” https://fonts.google.com/specimen/Bebas+Neue
- Bangers â€” https://fonts.google.com/specimen/Bangers
- Creepster â€” https://fonts.google.com/specimen/Creepster
- Anton â€” https://fonts.google.com/specimen/Anton

### Display â€” Temporarily Unavailable (corrupted assets)
- ~~Oswald~~ â€” blocked in `unavailableFonts` pending asset replacement
- ~~Orbitron~~ â€” blocked in `unavailableFonts` pending asset replacement
- ~~Audiowide~~ â€” blocked in `unavailableFonts` pending asset replacement

### Pixel
- Press Start 2P â€” https://fonts.google.com/specimen/Press+Start+2P
- Silkscreen â€” https://fonts.google.com/specimen/Silkscreen
- VT323 â€” https://fonts.google.com/specimen/VT323

### Fantasy / Themed
- Uncial Antiqua â€” https://fonts.google.com/specimen/Uncial+Antiqua

### Fantasy / Themed â€” Temporarily Unavailable (corrupted assets)
- ~~Cinzel~~ â€” blocked in `unavailableFonts` pending asset replacement

## Packaging Notes

When adding another font family:

1. Download the font from its official source.
2. Keep only the specific weights/styles RGX plans to expose.
3. Place the files in `media/fonts/`.
4. Register them in `modules/fonts/definitions.lua`.
5. Update `media/fonts/README.md` and this file.

## License Notes

The bundled fonts are limited to permissive redistribution-friendly licenses such as:

- OFL 1.1
- Ubuntu Font License
- Public Domain

## WoW Defaults

RGX still exposes Blizzard's built-in fallback fonts where useful, but the bundled RGX font pack is intended to be the primary source for addon font menus.
