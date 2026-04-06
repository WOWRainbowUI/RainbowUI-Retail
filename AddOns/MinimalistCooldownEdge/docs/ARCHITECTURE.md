# Architecture

## Goals

This addon is structured around a few explicit goals:

1. Discover cooldowns without a global `EnumerateFrames()` pass.
2. Keep category routing explicit and centralized.
3. Separate discovery, scheduling, styling, and UI concerns.
4. Survive Blizzard rewrites of cooldown widget state by re-applying intended values safely.
5. Prefer weak references so transient frames can disappear without manual cleanup.

## High-level model

The addon runtime has four layers:

1. `Core` sets up constants, defaults, saved variables, slash commands, and the options shell.
2. `Adapters` discover known cooldown sources and register them in the registry.
3. `Modules` classify, queue, style, and enforce visual state.
4. `UI` exposes configuration, profile import/export, and one-time alerts.

## Startup sequence

There are two different orders to care about.

### 1. File load order

The `.toc` file controls the order in which files are parsed and modules are registered.

### 2. Module enable order

`AceAddon-3.0` enables submodules in `orderedModules`, which is populated in module creation order. In practice, that means the `.toc` order controls submodule `OnEnable()` order.

That is why this addon uses the following sequence in `MinimalistCooldownEdge.toc`:

1. `Core`
2. Foundation modules
3. Adapters
4. Styling pipeline modules
5. UI files

This order is intentional:

- `TargetRegistry` must exist before anything registers or looks up cooldowns.
- Adapters should enable before `HookBridge` and `Styler` so `Registry:RegisterAdapter()` is complete early.
- `Styler` should set the batch style callback before hook-driven updates begin to queue meaningful work.
- `HookBridge` should enable after adapters exist so `Registry:TryClaim()` can use them immediately.

## Runtime flow

The main cooldown path is:

1. An adapter discovers a cooldown and registers it in `TargetRegistry`, or `HookBridge` sees an unknown cooldown and asks the registry to claim it through adapters.
2. `TargetRegistry` stores the cooldown's category and optional subtype.
3. `BatchProcessor` coalesces repeated updates into a single deferred style pass.
4. `Styler` receives batched frames and delegates to `StyleEngine:ApplyStyle()`.
5. `StyleEngine` applies generic styling rules.
6. `CompactGroupAuraController` can short-circuit generic styling for compact party or raid auras.
7. `DurationColorController` updates text colors over time when duration coloring is active.
8. `HookBridge` re-enforces edge, swipe, and countdown flags if Blizzard changes them after styling.

## Main modules

### Core

`Core/Constants.lua`

- Central definitions for categories, subtypes, style defaults, adapter settings, URLs, import/export settings, and runtime constants.
- Also owns addon-relative asset paths.

`Core/Core.lua`

- Creates the Ace addon object.
- Owns shared helpers like `MCE:IsForbidden()`, font normalization, and chat printing.
- Builds defaults and migrates legacy profile data.
- Registers slash commands and the options tree.
- Exposes public entry points such as `ForceUpdateAll()` and debounced refresh helpers.

### Discovery and routing

`Modules/TargetRegistry.lua`

- The source of truth for tracked cooldowns.
- Stores `cooldown -> { category, subtype }`.
- Maintains weak category indexes.
- Stores adapter registrations and exposes `TryClaim()`, `RebuildCategory()`, and `RebuildAll()`.

`Modules/Classifier.lua`

- Lightweight fallback classifier.
- Handles blacklist checks and last-resort classification when no adapter claims a cooldown.
- Should stay secondary to adapters, not replace them.

### Scheduling and styling

`Modules/BatchProcessor.lua`

- Deduplicates rapid updates and defers actual styling to the next tick.
- Prevents repeated style work when Blizzard touches the same cooldown multiple times in one frame.

`Modules/Styler.lua`

- Orchestrates the pipeline.
- Wires `BatchProcessor` to `StyleEngine`.
- Resets module state during full refreshes.
- Triggers adapter rebuilds and queues registered cooldowns for restyling.

`Modules/StyleEngine.lua`

- The central styling engine.
- Resolves cooldown context from the parent chain.
- Styles countdown text, stack counts, swipe, edge, and charge cooldown behavior.
- Knows about category-specific font sizing and hide-countdown rules.
- Applies generic styling for action bars, nameplates, unit frames, CooldownManager, MiniCC, sArena, TellMeWhen, and the global fallback category.

`Modules/DurationColorController.lua`

- Owns duration-based text recoloring.
- Builds a step color curve from profile thresholds.
- Tracks active cooldowns, caches duration objects, and drives a ticker while tracked cooldowns are visible.
- Resolves duration sources from action APIs, aura APIs, or spell APIs depending on context.

`Modules/CompactGroupAuraController.lua`

- Special-case controller for Blizzard compact party and raid aura frames.
- Reuses Blizzard native cooldown text where possible.
- Applies party and raid specific text, edge, and swipe behavior.
- Takes precedence over generic styling in `StyleEngine:ApplyStyle()`.

### Hooking and enforcement

`Modules/HookBridge.lua`

- Installs `hooksecurefunc()` hooks on the `Cooldown` widget API.
- Observes cooldown lifetime calls:
  - `SetCooldown`
  - `SetCooldownDuration`
  - `SetCooldownFromDurationObject`
  - `SetCooldownFromExpirationTime`
  - `Clear`
- Observes visual mutators:
  - `SetDrawEdge`
  - `SetEdgeScale`
  - `SetSwipeColor`
  - `SetHideCountdownNumbers`
  - `SetDrawSwipe`
- Registers unknown cooldowns lazily, updates duration tracking, queues style work, and re-applies intended state when Blizzard code overwrites it.

### Adapters

`Adapters/DominosAdapter.lua`

- Detects Dominos action bar cooldowns, including bars that reuse Blizzard button names.
- Marks supported Dominos cooldowns as safe despite the generic blacklist, and lets the UI toggle the integration on or off.

`Adapters/ActionBarAdapter.lua`

- Registers Blizzard action buttons plus supported third-party bars outside of dedicated integrations.
- Detects both main cooldowns and charge cooldowns.

`Adapters/NameplateAdapter.lua`

- Uses nameplate events to scan nameplate subtrees for cooldown widgets.

`Adapters/UnitFrameAdapter.lua`

- Scans Blizzard and supported third-party unit frame aura containers.

`Adapters/GroupFrameAdapter.lua`

- Scans compact party and raid member aura containers.
- Supplies `party` and `raid` subtypes for compact aura styling.

`Adapters/CooldownManagerAdapter.lua`

- Detects CooldownManager viewers and stores viewer subtype information.

`Adapters/MiniCCAdapter.lua`

- Detects MiniCC frames and resolves `cc`, `nameplate`, `portrait`, or `overlay` subtypes, preferring MiniCC module metadata when it is exposed on the container frame.

`Adapters/SArenaAdapter.lua`

- Detects sArena_Reloaded class icon, DR, trinket, and racial cooldowns.

`Adapters/TellMeWhenAdapter.lua`

- Detects TellMeWhen icon cooldown and charge cooldown sweep frames.

### UI

`UI/ImportExport.lua`

- Serializes profile data with `AceSerializer-3.0`.
- Optionally compresses with Blizzard compression APIs.
- Base64-encodes payloads and merges imported profiles over defaults.

`UI/Options.lua`

- Builds the AceConfig UI.
- Exposes per-category controls, compact aura controls, duration text colors, help, and profile import/export.
- Uses immediate or debounced refresh paths depending on the setting type.

`UI/Alerts.lua`

- Prints one-time version alerts after profile data is available.

## Category and subtype model

The registry tracks a category for every cooldown and may also track a subtype.

| Category | Subtype |
| --- | --- |
| `actionbar` | none |
| `nameplate` | none |
| `unitframe` | none |
| `compactPartyAura` | `party` or `raid` |
| `cooldownmanager` | `essential`, `utility`, `bufficon`, or fallback `utility_or_essential` |
| `minicc` | `cc`, `nameplate`, `portrait`, or `overlay` |
| `sarena` | `classicon`, `dr`, `trinket`, or `racial` |
| `tellmewhen` | none |
| `global` | none |
| `blacklist` | none |
| `aura_pending` | transient fallback only |

`blacklist` and `aura_pending` are control categories, not normal style targets.

## Shared state and caching

The addon uses weak-key tables stored on the addon namespace:

- `addon.frameState`
- `addon.fontState`

These caches hold derived styling state such as:

- last applied edge or swipe values
- cached cooldown text regions
- resolved parent-chain context
- tracked duration objects
- compact aura metadata

Weak keys are important because many cooldown frames are transient or recycled by Blizzard.

## Important invariants

1. The registry is the only authoritative category store.
2. Adapters should register cooldowns directly; generic code should not invent categories unless it is the fallback classifier path.
3. Styling code must update cached state when it mutates cooldown visuals, otherwise `HookBridge` cannot enforce the intended value.
4. Full rescans should go through `Styler:ForceUpdateAll(true)`, which resets state, asks adapters to rebuild, and re-queues tracked cooldowns.
5. Compact party and raid auras are special-case controlled before generic styling.

## Why the current `.toc` order is the best fit

The current `.toc` is good after the reorder, because it mirrors the runtime dependency graph instead of grouping files only by theme.

Recommended order:

1. Foundation modules
2. Adapters
3. Styling pipeline
4. UI helpers and alerts

That order makes the startup path easier to reason about and reduces the chance of hook-driven work starting before adapters have registered.

## Extending the addon

When adding support for a new cooldown source:

1. Add source-specific constants in `Core/Constants.lua`.
2. Create a new adapter under `Adapters/`.
3. Register the adapter in `OnEnable()` with `TargetRegistry:RegisterAdapter(category, self)`.
4. Implement `Rebuild()` for known frames and `TryClaim()` for hook-discovered frames.
5. If the source needs special visual handling, add a focused controller module instead of bloating `StyleEngine`.
6. Insert the adapter in the `.toc` adapter block before `Styler` and `HookBridge`.
7. Add options only if the source needs a new category or subtype-specific settings.

## Practical debugging checklist

- If a cooldown is never styled, first confirm an adapter or fallback classifier registers it.
- If a cooldown flickers back to Blizzard defaults, inspect `frameState` usage and `HookBridge` enforcement hooks.
- If duration colors do not update, verify the duration source resolves and the ticker has active tracked frames.
- If compact party or raid aura text behaves strangely, check `GroupFrameAdapter` subtype resolution before touching generic style logic.
