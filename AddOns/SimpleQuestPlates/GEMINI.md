# GEMINI.md

Guidance for AI assistants working in this repository.

## Project Overview

SimpleQuestPlates is a WoW addon that displays quest objective progress on enemy nameplates.

## Repository Layout

- `SimpleQuestPlates.toc` - Addon metadata
- `SimpleQuestPlates.xml` - Lua load order
- `data/` - Addon logic and options UI modules
- `locales/` - Translation files
- `images/` - Project visual assets
- `docs/` - Release notes and roadmap
- `.github/workflows/release.yml` - Tag-based packaging and release pipeline

## Development Cycle

1. Implement requested code changes.
2. Keep docs consistent with runtime behavior.
3. Do not change version unless preparing a release.
4. Validate with manual in-game command checks.

## Release Cycle

1. Choose new version (example: `1.9.6`).
2. Update:
   - `SimpleQuestPlates.toc`
   - `data/core.lua`
3. Replace changelog content with a single current-version section in:
   - `docs/CHANGES.md`
4. Commit, tag (`vX.Y.Z`), and push branch + tag.

## Commands to Validate

- `/sqp`
- `/sqp help`
- `/sqp status`
- `/sqp version`
- `/sqp test`

## Notes

- `enUS.lua` is the fallback baseline for localization keys.
- Locale modules cover: `enUS`, `enGB`, `deDE`, `esES`/`esMX`, `frFR`, `itIT`, `koKR`, `ptBR`, `ruRU`, `zhCN`, `zhTW`.
- Compatibility behavior is centralized in `data/compat.lua` and `data/compat_mop.lua`.
