# Minimalist Cooldown Edge (MiniCE)

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

Minimalist Cooldown Edge is a World of Warcraft Retail addon that restyles cooldown text and edge visuals across action bars, nameplates, unit frames, and cooldown viewers, so cooldown countdowns stay clean and readable at a glance.

The addon is built around an adapter-driven registry. Cooldowns are discovered by source-specific adapters, routed into categories and subtypes, then styled through a shared pipeline. Dynamic updates are handled by hooks on Blizzard's `Cooldown` widget API rather than by a global frame scan.

## What it supports

- Action bars, including charge cooldowns and assisted combat actions.
- Nameplate auras.
- Blizzard and third-party unit frames.
- CooldownManager viewers.
- Player Aura styling.
- MiniAuras overlays.
- sArena_Reloaded cooldown timers.
- TellMeWhen cooldown and charge sweeps.

Party / Raid Frames are no longer supported. The options menu keeps a retired notice for this category because Blizzard Patch 12.0.5 changed the compact party and raid frame surface MiniCE previously styled.

### Optional integrations

MiniCE detects and styles cooldowns from these addons when they are installed, without requiring them: LibSharedMedia-3.0, Bartender4, Dominos (and Dominos_Cast / Dominos_Config), ElvUI, HealerCC, MiniAuras, sArena_Reloaded, TellMeWhen, ShinyAuras, CooldownManagerCentered, mUI, and BetterBlizzFrames.

BetterBlizzFrames support currently applies to Player Auras only; MiniCE disables Unit Frames styling while BBF is active until a dedicated adapter is available. BetterBlizzPlates is conflict-detected only; MiniCE disables Nameplates styling while BBP is active to prevent possible conflicts.

## Main features

- Per-category font, text color, edge, swipe, and stack-count styling.
- Optional duration-based text coloring with threshold curves.
- Import and export for profile data.
- Embedded Ace3 configuration UI with profile support.
- Optional LibSharedMedia font integration when it is installed.

## Compatibility

Targets WoW Retail, interface `120100` (Patch 12.1).

## Installation

- **CurseForge** (recommended): install and keep up to date via the [MiniCE CurseForge page](https://www.curseforge.com/wow/addons/minice-cooldown-styler).
- **Manual**: download or clone this repository into `Interface/AddOns/MinimalistCooldownEdge` in your WoW installation folder.

## Quick start

- `/mce`
- `/minice`
- `/minimalistcooldownedge`

All three commands toggle the AceConfig options window.

## Project layout

```text
Core/
  Constants.lua
  Core.lua
Modules/
  TargetRegistry.lua
  BatchProcessor.lua
  Classifier.lua
  StyleEngine.lua
  DurationColorController.lua
  Styler.lua
  HookBridge.lua
Adapters/
  DominosAdapter.lua
  ActionBarAdapter.lua
  NameplateAdapter.lua
  UnitFrameAdapter.lua
  CooldownManagerAdapter.lua
  MiniAurasAdapter.lua
  SArenaAdapter.lua
  TellMeWhenAdapter.lua
UI/
  ImportExport.lua
  Options.lua
Assets/
  Fonts/
  Textures/
Locales/
Libs/
```

## Load-order note

The `.toc` file is not cosmetic in this addon. `AceAddon-3.0` enables submodules in registration order, so the file order controls module enable order.

The current layout intentionally loads:

1. Foundation modules first.
2. Adapters second, so they register with the registry early.
3. Styling modules after that.
4. The hook bridge last in the pipeline, after the style callback and adapters exist.

That sequence reduces startup ambiguity and keeps `Registry:TryClaim()` useful as soon as hooks begin firing.

## Development notes

- Shared per-frame caches live in weak-key tables on the addon namespace.
- The registry is the source of truth for category and subtype routing.
- `Styler` is the orchestration layer; `StyleEngine` is the styling layer.
- `HookBridge` keeps Blizzard from silently reverting edge, swipe, or countdown state between style passes.

## Support and community

- **Bug reports and feature requests**: [Discord](https://discord.gg/n4udv5AhFp)
- **Downloads and release notes**: [CurseForge](https://www.curseforge.com/wow/addons/minice-cooldown-styler)
- **Source**: this repository

## License

Licensed under the [Apache License, Version 2.0](LICENSE).
