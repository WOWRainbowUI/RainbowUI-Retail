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
- Inter — https://rsms.me/inter/
- Ubuntu — https://design.ubuntu.com/font
- Liberation Sans — https://github.com/liberationfonts/liberation-fonts
- DejaVu Sans — https://dejavu-fonts.github.io/
- Lato — https://fonts.google.com/specimen/Lato
- Poppins — https://fonts.google.com/specimen/Poppins
- Rajdhani — https://fonts.google.com/specimen/Rajdhani

### Sans / UI — Temporarily Unavailable (corrupted assets)
- ~~Montserrat~~ — blocked in `unavailableFonts` pending asset replacement

### Serif
- Crimson Text — https://fonts.google.com/specimen/Crimson+Text

### Serif — Temporarily Unavailable (corrupted assets)
- ~~Merriweather~~ — blocked in `unavailableFonts` pending asset replacement
- ~~Playfair Display~~ — blocked in `unavailableFonts` pending asset replacement

### Monospace
- IBM Plex Mono — https://fonts.google.com/specimen/IBM+Plex+Mono
- JetBrains Mono — https://www.jetbrains.com/lp/mono/

### Display
- Bebas Neue — https://fonts.google.com/specimen/Bebas+Neue
- Bangers — https://fonts.google.com/specimen/Bangers
- Creepster — https://fonts.google.com/specimen/Creepster
- Anton — https://fonts.google.com/specimen/Anton

### Display — Temporarily Unavailable (corrupted assets)
- ~~Oswald~~ — blocked in `unavailableFonts` pending asset replacement
- ~~Orbitron~~ — blocked in `unavailableFonts` pending asset replacement
- ~~Audiowide~~ — blocked in `unavailableFonts` pending asset replacement

### Pixel
- Press Start 2P — https://fonts.google.com/specimen/Press+Start+2P
- Silkscreen — https://fonts.google.com/specimen/Silkscreen
- VT323 — https://fonts.google.com/specimen/VT323

### Fantasy / Themed
- Uncial Antiqua — https://fonts.google.com/specimen/Uncial+Antiqua

### Fantasy / Themed — Temporarily Unavailable (corrupted assets)
- ~~Cinzel~~ — blocked in `unavailableFonts` pending asset replacement

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
