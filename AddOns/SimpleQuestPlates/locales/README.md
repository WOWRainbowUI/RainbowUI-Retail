# /locales

Localization files for SimpleQuestPlates.

## Available Locales

- `enUS.lua` - English baseline/fallback strings
- `enGB.lua` - English (EU) locale module
- `deDE.lua` - German overrides
- `esES.lua` - Spanish overrides (`esES` and `esMX`)
- `frFR.lua` - French overrides
- `itIT.lua` - Italian locale module
- `koKR.lua` - Korean locale module
- `ptBR.lua` - Brazilian Portuguese locale module
- `ruRU.lua` - Russian overrides
- `zhCN.lua` - Simplified Chinese overrides
- `zhTW.lua` - Traditional Chinese locale module

## Guidance

- Add new keys to `enUS.lua` first.
- Other locale files can override translated strings while preserving fallback values.
- Keep key names stable to avoid runtime string lookup issues.
- All locale modules currently include a full key set for runtime safety.
