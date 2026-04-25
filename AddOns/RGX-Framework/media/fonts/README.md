# Fonts for RGX-Framework

This folder contains bundled open-source fonts packaged with RGX-Framework.
The goal is to ship a curated, popular font pack for addon authors instead of relying on system fonts.

## Included Fonts

### Inter (OFL 1.1)
- **Files:** Inter-Regular.otf, Inter-Bold.otf
- **Source:** https://rsms.me/inter/
- **License:** Open Font License 1.1
- **Type:** Sans-serif

### Crimson Text (OFL 1.1)
- **Files:** CrimsonText-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Crimson+Text
- **License:** Open Font License 1.1
- **Type:** Serif

### Press Start 2P (OFL 1.1)
- **Files:** PressStart2P-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Press+Start+2P
- **License:** Open Font License 1.1
- **Type:** Pixel

### VT323 (OFL 1.1)
- **Files:** VT323-Regular.ttf
- **Source:** https://fonts.google.com/specimen/VT323
- **License:** Open Font License 1.1
- **Type:** Pixel

### IBM Plex Mono (OFL 1.1)
- **Files:** IBMPlexMono-Regular.ttf
- **Source:** https://fonts.google.com/specimen/IBM+Plex+Mono
- **License:** Open Font License 1.1
- **Type:** Monospace

### JetBrains Mono (OFL 1.1)
- **Files:** JetBrainsMono-Regular.ttf, JetBrainsMono-Bold.ttf
- **Source:** https://www.jetbrains.com/lp/mono/
- **License:** Open Font License 1.1
- **Type:** Monospace

### Poppins (OFL 1.1)
- **Files:** Poppins-Regular.ttf, Poppins-Bold.ttf
- **Source:** https://fonts.google.com/specimen/Poppins
- **License:** Open Font License 1.1
- **Type:** Sans-serif

### Montserrat (OFL 1.1)
- **Files:** Montserrat-Regular.ttf, Montserrat-Bold.ttf
- **Source:** https://fonts.google.com/specimen/Montserrat
- **License:** Open Font License 1.1
- **Type:** Sans-serif

### Lato (OFL 1.1)
- **Files:** Lato-Regular.ttf, Lato-Bold.ttf
- **Source:** https://fonts.google.com/specimen/Lato
- **License:** Open Font License 1.1
- **Type:** Sans-serif

### Rajdhani (OFL 1.1)
- **Files:** Rajdhani-Regular.ttf, Rajdhani-Bold.ttf
- **Source:** https://fonts.google.com/specimen/Rajdhani
- **License:** Open Font License 1.1
- **Type:** Sans-serif

### Merriweather (OFL 1.1)
- **Files:** Merriweather-Regular.ttf, Merriweather-Bold.ttf
- **Source:** https://fonts.google.com/specimen/Merriweather
- **License:** Open Font License 1.1
- **Type:** Serif

### Playfair Display (OFL 1.1)
- **Files:** PlayfairDisplay-Regular.ttf, PlayfairDisplay-Bold.ttf
- **Source:** https://fonts.google.com/specimen/Playfair+Display
- **License:** Open Font License 1.1
- **Type:** Serif

### Bebas Neue (OFL 1.1)
- **Files:** BebasNeue-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Bebas+Neue
- **License:** Open Font License 1.1
- **Type:** Display

### Bangers (OFL 1.1)
- **Files:** Bangers-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Bangers
- **License:** Open Font License 1.1
- **Type:** Display

### Creepster (OFL 1.1)
- **Files:** Creepster-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Creepster
- **License:** Open Font License 1.1
- **Type:** Display

### Oswald (OFL 1.1)
- **Files:** Oswald-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Oswald
- **License:** Open Font License 1.1
- **Type:** Display

### Orbitron (OFL 1.1)
- **Files:** Orbitron-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Orbitron
- **License:** Open Font License 1.1
- **Type:** Display

### Audiowide (OFL 1.1)
- **Files:** Audiowide-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Audiowide
- **License:** Open Font License 1.1
- **Type:** Display

### Anton (OFL 1.1)
- **Files:** Anton-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Anton
- **License:** Open Font License 1.1
- **Type:** Display

### Silkscreen (OFL 1.1)
- **Files:** Silkscreen-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Silkscreen
- **License:** Open Font License 1.1
- **Type:** Pixel

### Uncial Antiqua (OFL 1.1)
- **Files:** UncialAntiqua-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Uncial+Antiqua
- **License:** Open Font License 1.1
- **Type:** Fantasy

### Cinzel (OFL 1.1)
- **Files:** Cinzel-Regular.ttf
- **Source:** https://fonts.google.com/specimen/Cinzel
- **License:** Open Font License 1.1
- **Type:** Fantasy

## Adding Fonts

To add more fonts:

1. Download TTF or OTF font files from open source font repositories
2. Copy them to this folder
3. Add entries to `modules/fonts/fonts.lua` in the `Fonts.definitions` table
4. Restart WoW

## Recommended Sources

- **Google Fonts:** https://fonts.google.com/ (filter by OFL or Apache license)
- **GitHub:** Many open source fonts available
- **Font Squirrel:** https://www.fontsquirrel.com/ (filter by "Open Font License")

## License Requirements

All fonts must be licensed under:
- **OFL (Open Font License)** - Free to use, modify, redistribute
- **Apache 2.0** - Free to use commercially
- **MIT** - Free to use
- **Public Domain** - No restrictions

## WoW Default Fonts (Always Available)

These Blizzard fonts are always available without including files:

- `Fonts/FRIZQT__.TTF` - Friz Quadrata (default UI font)
- `Fonts/ARIALN.TTF` - Arial Narrow
- `Fonts/skurri.ttf` - Skurri
- `Fonts/MORPHEUS.ttf` - Morpheus

## Usage

```lua
local Fonts = RGX:GetModule("fonts")

-- Get font path
local path = Fonts:GetPath("Inter-Regular")
myFontString:SetFont(path, 12, "OUTLINE")

-- Quick apply
Fonts:Quick(myFontString, "Inter-Regular", 14, "OUTLINE")
```
