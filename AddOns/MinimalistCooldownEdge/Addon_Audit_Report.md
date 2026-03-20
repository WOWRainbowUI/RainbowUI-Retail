# Addon Audit Report

## 1. Executive Summary

- Overall code quality: solid defensive coding for Retail/Midnight protected values and forbidden frames, but the runtime architecture is too centralized in `Styler.lua` and depends on broad hooks instead of narrowly scoped update sources.
- Main risks: global cooldown API interception, expensive refresh invalidation, and full-source rescans. These are the real cost centers; there is no `OnUpdate` loop and no duplicated event-registration problem in the current codebase.
- Top priority: reduce the hook surface in `Styler:SetupHooks()`.
- Top priority: make non-full refreshes truly incremental in `Styler:ForceUpdateAll()`.
- Top priority: reduce full discovery scans in `Classifier:BootstrapSupportedCooldownSources()`.

## 2. Detailed Findings

### Finding 1: Global cooldown API hooks are too broad and include write-back enforcement
- Category: performance / architecture
- Impact: high
- Affected files / functions: `Styler.lua:158-167`, `Styler.lua:260-284`, `Styler.lua:1612-1746`
- Technical explanation: `Styler:SetupHooks()` installs 10 `hooksecurefunc` hooks on the shared cooldown API metatable, so every cooldown in the UI pays the addon's interception cost, even before it is known to belong to a supported category. The enforcement hooks for `SetDrawEdge`, `SetEdgeScale`, `SetSwipeColor`, `SetHideCountdownNumbers`, `SetDrawSwipe`, plus the per-fontstring `SetFont` hook, also call the same setters again to restore cached state. The suppression flags prevent infinite recursion, but they still turn a foreign write into at least one extra addon write.
- Recommended improvement direction: keep duration-capture hooks minimal, move visual enforcement to tracked frames only, and avoid setter write-backs unless a frame is already classified and actively managed.

### Finding 2: The "incremental" refresh path still wipes nearly all runtime caches
- Category: performance / structure
- Impact: high
- Affected files / functions: `Styler.lua:1575-1603`, `Core.lua:117-139`, `Options.lua:78-98`, `Options.lua:154-238`
- Technical explanation: `Styler:ForceUpdateAll()` clears `frameState`, `fontState`, `durationColoredFrames`, `activeDurationFrames`, `durationObjectCache`, and stops the ticker before it decides whether the refresh is full or incremental. That means even `ForceUpdateAll(false)` throws away the state that avoids redundant styling, then restyles every tracked cooldown anyway. In practice, many option changes still trigger a broad restyle even when discovery does not need to run.
- Recommended improvement direction: split refresh into separate layers: discovery invalidation, classification invalidation, and visual restyle. Preserve per-frame state when only fonts/colors/offsets change.

### Finding 3: Full discovery scans are expensive and are triggered from several user actions
- Category: performance / architecture
- Impact: medium
- Affected files / functions: `Classifier.lua:347-467`, `Classifier.lua:865-873`, `Styler.lua:1575-1589`, `Styler.lua:1094-1099`, `ImportExport.lua:249`, `Options.lua:154-238`, `Options.lua:479`, `Options.lua:862`, `Options.lua:886`, `Options.lua:987`
- Technical explanation: full refreshes recurse through large frame trees for action bars, unit frames, nameplates, and CooldownManager, then sweep all globals for `MiniCC_` frames via `pairs(_G)`. This is acceptable at startup, but it is also used after import and several configuration changes. The scan depth is bounded, but the breadth is still large enough to create visible spikes on busy UIs.
- Recommended improvement direction: keep a registry of discovered roots, only rescan affected subsystems, and replace the global `MiniCC_` sweep with targeted registration or a cached root list.

### Finding 4: Aura-driven cooldowns go through multiple deferred update pipelines
- Category: performance / structure
- Impact: medium
- Affected files / functions: `Styler.lua:939-1003`, `Styler.lua:1031-1087`, `Styler.lua:1322-1381`, `Classifier.lua:761-839`
- Technical explanation: aura cooldowns can pass through `HandleCooldownDurationUpdate()`, the dirty-frame batch (`After(0)`), the extra aura refresh (`After(0)`), and the aura-pending retry queue (`After(0.1)`). The same frame can therefore be classified, context-cleared, and styled more than once around a single aura state change. `ProcessPendingAuras()` also calls `ApplyStyle()` directly, bypassing the normal batch coalescing.
- Recommended improvement direction: collapse aura recovery into one queued retry path keyed by frame, and let a single scheduler own classification retries and style application.

### Finding 5: Some hot-path setters still run unconditionally on every style pass
- Category: performance / maintainability
- Impact: medium
- Affected files / functions: `Styler.lua:401-413`, `Styler.lua:437-469`, `Styler.lua:1242-1270`, `Styler.lua:1561-1567`
- Technical explanation: most visual APIs are protected by cached state, but a few are not. `StyleStackCount()` always calls `SetAlpha` and `Show`/`Hide`, and `SetCountdownAbbrevThreshold()` is called on every style pass for both generic cooldowns and compact party auras. On frequently updated cooldowns, those unconditional writes add avoidable work and undermine the otherwise careful change-detection already present elsewhere in the module.
- Recommended improvement direction: store stack-visibility and abbreviation-threshold state in `frameState` and only write when values actually change.

### Finding 6: `Styler`, `Classifier`, and `Options` are oversized and tightly coupled
- Category: architecture / maintainability
- Impact: medium
- Affected files / functions: `Styler.lua:1351-1574`, `Styler.lua:1612-1746`, `Classifier.lua:493-754`, `Options.lua:428-1180`
- Technical explanation: `Styler:ApplyStyle()` mixes classification overrides, assisted-combat rules, compact-party handling, font styling, stack styling, swipe control, and duration-color management in one 224-line function. `Classifier` owns both discovery and ancestry heuristics, and `Options.lua` builds a very large AceConfig tree with hundreds of inline closures. This makes performance work harder because behavior, invalidation, and policy are spread across a few very large functions instead of isolated units.
- Recommended improvement direction: split runtime ownership into smaller units such as discovery, classification, duration-state, and visual-application layers; move category-specific policy into data tables or strategy helpers; reduce closure-heavy option construction by using reusable section builders.

### Finding 7: Duration-object caching still creates avoidable garbage and periodic full sweeps
- Category: memory / performance
- Impact: low
- Affected files / functions: `Styler.lua:38-62`, `Styler.lua:856-880`
- Technical explanation: created duration objects are cached under concatenated string keys (`endTime:duration:modRate`). Every new cooldown start creates a new string key, and `PurgeExpiredDurationObjects()` periodically walks the whole cache while the ticker is active. The cache is bounded in practice by refresh resets and expiration, but it still creates transient string churn in a hot subsystem.
- Recommended improvement direction: use a more direct cache structure, or tie cache lifetime to tracked cooldown frames rather than sweeping a global duration-object pool.

## 3. Priority Ranking

### Critical
- Reduce the global cooldown hook surface and remove write-back enforcement from hot shared setters.
- Make non-full refreshes preserve existing runtime caches instead of restyling everything from scratch.

### Important
- Replace broad full scans with narrower source-specific rediscovery.
- Collapse aura retries and deferred updates into one scheduler.
- Break `Styler` and `Classifier` into smaller runtime responsibilities.

### Optional
- Add state guards for stack visibility and abbreviation threshold writes.
- Replace string-key duration-object caching with a lower-garbage strategy.

## 4. Refactor Roadmap

### Critical
1. Separate duration capture from visual enforcement in `Styler:SetupHooks()`.
2. Refactor `ForceUpdateAll()` into discovery refresh, classification refresh, and visual refresh paths.

### Important
1. Introduce tracked source registries so full tree scans are not the default recovery mechanism.
2. Merge `pendingAuras`, `dirtyFrames`, and aura-refresh retries into one deduplicated queue.
3. Split `ApplyStyle()` into focused helpers for visibility, typography, stacks, swipe/edge, and duration color.
4. Move category-specific behavior into small policy tables instead of branching across `Styler` and `Classifier`.

### Optional
1. Cache `Show`/`Hide`, `SetAlpha`, and `SetCountdownAbbrevThreshold` decisions in `frameState`.
2. Replace the duration-object string cache with a lower-allocation structure.
