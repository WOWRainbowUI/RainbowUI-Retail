# CLAUDE.md

Guidance for AI assistants working in this repository.

## Project Overview

SimpleQuestPlates is a WoW addon that overlays quest objective progress on enemy nameplates.

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
