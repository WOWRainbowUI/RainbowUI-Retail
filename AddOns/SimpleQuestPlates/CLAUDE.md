# CLAUDE.md

Guidance for AI assistants working in this repository.

## Project Overview

SimpleQuestPlates is a WoW addon that overlays quest objective progress on enemy nameplates.

## RGX-Framework Dependency

SQP declares `## RequiredDeps: RGX-Framework` and uses the shared `_G.RGXFramework` instance for events, timers, minimap, slash commands, and design tokens (~75% integrated). Do not add manual event frames, raw `C_Timer`, or raw `SLASH_X` registration — route through `RGX:RegisterEvent`, `RGX:After`/`RGX:Every`, and `RGX:RegisterSlashCommand`. See `../RGX-Framework/CLAUDE.md` for framework rules and roadmap.

Known issue shared with BLU: hand-rolled option sliders do not restore their values on reload. The fix is planned at the framework level (db-bound grid controls, framework roadmap Tier 4) — do not patch sliders locally with new one-off implementations.

## Runtime Structure

- `SimpleQuestPlates.toc` - Addon metadata and loader entry
- `SimpleQuestPlates.xml` - Script load order
- `data/` - Runtime modules (core, quest, nameplates, events, commands, options)
- `locales/` - Localization files (`enUS` baseline + locale overrides)
- `images/` - Icons, logo, and doc assets
- `docs/` - Release notes and roadmap

## Options Tabs

Current tab set:

- Global
- Kill
- Loot
- Percent
- About

## Slash Commands

- `/sqp` or `/sqp options`
- `/sqp help`
- `/sqp on` / `/sqp off`
- `/sqp status`
- `/sqp version`
- `/sqp test`
- `/sqp scale <0.5-2.0>`
- `/sqp offset <x> <y>`
- `/sqp anchor <LEFT|RIGHT>`
- `/sqp reset`
- `/sqp debug`
- `/sqp debug target`
- `/sqp debug nameplates`

## Release Notes Policy

`docs/CHANGES.md` must contain only the current release section.

## Version Management

When bumping versions:

1. Update `SimpleQuestPlates.toc` (`## Version:`).
2. Update `data/core.lua` (`SQP.VERSION`).
3. Update `docs/CHANGES.md` for the new version.
4. Create and push matching git tag (`vX.Y.Z`).

## Testing Expectations

Manual in-game checks:

1. `/sqp help`
2. `/sqp status`
3. `/sqp test`
4. Options panel tab navigation + preview updates
5. Locale fallback behavior (missing translated keys)
