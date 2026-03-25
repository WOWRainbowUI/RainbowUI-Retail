# Minimalist Cooldown Edge

Minimalist Cooldown Edge is a World of Warcraft addon that restyles cooldown text and edge visuals across multiple UI surfaces while keeping the runtime model explicit and predictable.

The addon is built around an adapter-driven registry. Cooldowns are discovered by source-specific adapters, routed into categories and subtypes, then styled through a shared pipeline. Dynamic updates are handled by hooks on Blizzard's `Cooldown` widget API rather than by a global frame scan.

## What it supports

- Action bars, including charge cooldowns and assisted combat actions.
- Nameplate auras.
- Blizzard and third-party unit frames.
- Blizzard compact party and raid aura frames.
- CooldownManager viewers.
- MiniCC overlays.
- sArena_Reloaded cooldown timers.
- TellMeWhen cooldown and charge sweeps.
- A global fallback category for cooldowns that no adapter claims.

## Main features

- Per-category font, text color, edge, swipe, and stack-count styling.
- Optional duration-based text coloring with threshold curves.
- Dedicated styling rules for compact party and raid aura frames.
- Import and export for profile data.
- Embedded Ace3 configuration UI with profile support.
- Optional LibSharedMedia font integration when it is installed.

## Commands

- `/mce`
- `/minice`
- `/minimalistcooldownedge`

All commands toggle the AceConfig options window.

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
  CompactGroupAuraController.lua
  Styler.lua
  HookBridge.lua
Adapters/
  ActionBarAdapter.lua
  NameplateAdapter.lua
  UnitFrameAdapter.lua
  GroupFrameAdapter.lua
  CooldownManagerAdapter.lua
  MiniCCAdapter.lua
  SArenaAdapter.lua
  TellMeWhenAdapter.lua
UI/
  ImportExport.lua
  Options.lua
  Alerts.lua
Assets/
  Fonts/
  Textures/
Locales/
Libs/
docs/
  ARCHITECTURE.md
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

For the full startup sequence, data flow, and extension points, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
