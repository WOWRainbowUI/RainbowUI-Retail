# RGX-Framework Roadmap

## Direction

RGX-Framework is a modern WoW addon framework — an alternative to Ace3. It ships as a single `RequiredDeps` entry so every addon in a suite shares the same initialized instance. No embedding. No version conflicts. One dependency, everything included.

The player-facing experience stays quiet. The author-facing experience should be powerful, predictable, and simple to adopt.

---

## Core Principles

- One shared instance for all consumers — the single-load model beats per-addon embedding past 2 addons
- Modules are siloed by responsibility but designed to work together
- The public API stays simple; complexity lives inside the framework
- Build once in RGX, consume across the entire suite
- No LibStub, no embedding tax, no legacy compat shims

---

## What's Built

| System | Module | Status |
|---|---|---|
| Events, timers, hooks, slash commands | Core | ✅ Done |
| Lifecycle (`OnReady`, `IsReady`) | Core | ✅ Done |
| Output helpers (`Print`, `Warn`, `Error`) | Core | ✅ Done |
| Object composition (`Mixin`) | Core | ✅ Done |
| Font registry + dropdowns + style objects | RGXFonts | ✅ Done |
| Color palette + picker + math | RGXColors | ✅ Done |
| Statusbar texture registry | RGXTextures | ✅ Done |
| Nested dropdowns + auto-width + inline buttons | RGXDropdowns | ✅ Done |
| Slider, toggle, label, options panel builder | RGXUI | ✅ Done |
| Color picker widget | RGXColorPicker | ✅ Done |
| Circular-drag minimap button | RGXMinimap | ✅ Done |
| Pet battle callbacks + level-up detection | RGXPetBattles | ✅ Done |
| Sound/font/texture registry + pack scanner | RGXSharedMedia | ✅ Done |
| Visual building blocks (Design palette) | RGXDesign | ✅ Done |
| Combat event library | RGXCombat | ✅ Done |
| Reputation + renown tracking | RGXReputation | ✅ Done |
| Data broker registry | RGXDataBroker | ✅ Done |

---

## Immediate Priority

### Profile / Database System
**Priority: HIGH — biggest gap vs Ace3**

A profile-aware saved variable system so any addon can do:

```lua
local db = RGX:NewDatabase("MyAddonDB", {
    iconSize = 32,
    showIcon = true,
})

db.iconSize       -- reads active profile, falls back to default
db.iconSize = 48  -- writes to active profile
db.global.foo     -- cross-character storage

db:CreateProfile("Tank")
db:LoadProfile("Tank")
db:DeleteProfile("Tank")
db:ResetProfile()
db:GetProfiles()
db:GetActiveProfile()
db:OnProfileChanged(fn)
```

**Design principles (why this is better than AceDB):**
- Two scopes only: `profile` (per-character) and `global` (cross-character). No realm/class/race/faction scopes — those exist in AceDB to cover every possible case; we cover what 95% of addons need.
- `db.myKey` just works — `__index`/`__newindex` metamethods so the active profile IS the table surface. No `db.profile.myKey` namespace prefix bleeding into every line of consumer code.
- Flat defaults — pass a plain table, not a namespace-structured table mirrored to the scope system.
- Protected `Default` profile — always exists, never deleted, always a safe fallback.
- Missing keys auto-filled from defaults at read time (metamethod, not copy) — adding a new setting to defaults is safe for existing saved variables.

**Base:** BLU's `core/systems/database.lua` — profile CRUD, `MergeDefaults`, protected Default, rename, import/export serialization are all solid. Remove BLU-specific coupling, make it a generic factory, replace `GetDB`/`SetDB` dot-path accessors with metamethods.

---

## Near-Term Roadmap

### SharedMedia Drop-In for All RGX Consumers
**Priority: HIGH**

Currently `RGXSharedMedia` has the scanning logic (KittyRegisterSoundPack hook, DBM registrars, known addon compat, generic global scan). The missing pieces:

1. **Cross-feed to RGXFonts and RGXTextures** — fonts and textures discovered via LibSharedMedia or pack addons should automatically flow into the `RGXFonts` and `RGXTextures` registries. Currently the modules are siloed.

2. **`RGX_MEDIA_UPDATED` message** — after any scan, fire `RGX:SendMessage("RGX_MEDIA_UPDATED", type)`. Consumer addon dropdowns listen and rebuild. A font pack loads late → every RGX font dropdown across every addon refreshes automatically.

3. **BLU's sharedmedia.lua scanning logic belongs here** — KittyPack hook, DBM registrar invocation, known addon compat (Prat-3.0, TradeSkillMaster), generic audio path scanner. When BLU migrates to RGX, it drops its own `sharedmedia.lua` entirely.

**End state:** install any KittyPack, DBM sound pack, LibSharedMedia font/texture pack, or future RGX media pack alongside any RGX addon → all registered media appears in every RGX dropdown across every consumer addon. Zero per-addon wiring.

---

### Pack / Addin System
**Priority: MEDIUM — roadmap, not immediate**

External addon packs that extend RGX-Framework with fonts, style presets, sound collections, or texture sets. Shipped as separate CurseForge addons.

**Pattern:**
```lua
-- In a pack addon's main file:
## OptionalDeps: RGX-Framework

RGX:OnReady(function()
    local Fonts = RGX:GetFonts()
    Fonts:RegisterFontPack("PixelFontPack", {
        ["Press Start 2P"] = { file = "fonts/PressStart2P.ttf", category = "pixel" },
    })
end)
```

**Why it works structurally:** because all RGX consumers share the same `_G.RGXFramework` instance, a pack registering into `RGXFonts` is immediately visible to every addon using `RGXFonts` — BLU, SQP, PB2, RND, anything. The `RGX_MEDIA_UPDATED` message then signals dropdowns to rebuild.

**Compatibility:** existing LibSharedMedia packs (Caith, SharedMedia-Fonts, etc.) already work via `RGXSharedMedia:ImportLibSharedMedia()`. The pack system extends this to RGX-native packs with richer metadata (categories, families, licenses, previews).

**Initial media size:** default bundled assets stay lean — packs are how users expand options, not something every consumer pays for upfront.

---

### Localization Helper
**Priority: MEDIUM**

Simple `RGX:NewLocale(addonName, locale, isDefault)` — far simpler than AceLocale. Enables community addon authors to ship multilingual addons without rolling their own L table system.

---

## Longer-Term Roadmap

### Declarative Options
AceConfig-style but without AceConfig's complexity. A table-driven panel builder where you define structure and get a complete options UI — reduces the most common boilerplate from ~50 manual lines to a declarative table.

### BLU Migration to RGX
BLU currently has its own parallel implementations of: event system, timers, SharedMedia scanning, dropdown helpers, database/profiles. As RGX matures, BLU migrates to consume RGX for each of these. This is a gradual process — BLU is complex and stable; no disruption for its own sake.

Target: BLU drops its own `sharedmedia.lua`, `database.lua`, and event infrastructure in favour of `RGX:GetSharedMedia()`, `RGX:NewDatabase()`, and `RGX:RegisterEvent()`.

### RGX-Mod
The future high-complexity addon in the suite. RGX-Framework should already provide the base systems RGX-Mod will need: trigger/data plumbing, display/media plumbing, reusable editor and option widgets, shared serialization, messaging, and preview behavior. Build the foundation correctly now — RGX-Mod consumes it later.

---

## Non-Goals

- Not a bloated everything-framework — each module stays focused on its responsibility
- Not a replacement for WoW's native APIs — RGX wraps where wrapping adds value, exposes native APIs otherwise
- Not AceComm / AceSerialization — addon-to-addon communication via chat channels is niche; not planned
- Consuming addons should never need to understand RGX internals to benefit from it
