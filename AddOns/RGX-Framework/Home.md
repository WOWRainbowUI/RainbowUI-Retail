# RGX-Framework

## Directive

**Make addon building fast, easy, and fun.** Everything in RGX-Framework exists to serve this goal:

- An addon author should be able to spin up a complete addon with options, minimap icon, slash commands, themed UI, nested dropdowns, sound playback, profiles, and event handling **in minutes** â€” not days.
- Every API should work with **one or two lines of code** for the common case.
- Complexity lives inside the framework. The consumer surface stays simple.
- New features are extracted from real addon usage (BLU, ETL, SQP, RND), not designed in isolation.
- Dormant code that causes errors in production is disabled until a safe load path exists.

When adding or changing anything in RGX-Framework, ask: _does this make addon building easier for the next author?_

## What It Is

One `RequiredDeps` entry, everything included. No embedding, no version conflicts, no library chains. A modern alternative to Ace3.

## Quick Start

```toc
## RequiredDeps: RGX-Framework
```

```lua
local addonName, addonTable = ...
local RGX = _G.RGXFramework
assert(RGX, "RGX-Framework is required")

-- Database with profile support
addonTable.db = RGX:NewDatabase("MyAddonDB", { enabled = true, volume = 1.0 })

-- Events
RGX:RegisterEvent("PLAYER_LOGIN", function() print("Hello!") end)

-- Minimap button
local minimap = RGX:GetMinimap()
minimap:CreateButton("MyAddon", { icon = "Interface\\Icons\\inv_misc_questionmark" })

-- Slash command
RGX:RegisterSlashCommand("myaddon", function() print("Options opened") end)

-- Dropdown with nested menus
local Drops = RGX:GetDropdowns()
local dd = Drops:CreateNestedDropdown(parent, {
    label = "Choose Sound",
    items = {
        { text = "Fanfare", value = "fanfare" },
        { text = "Chime",   value = "chime"   },
    },
    onChange = function(value) print("selected:", value) end,
})

-- Options panel
local Options = RGX:GetOptions()
Options:CreatePanel("MyAddon", {
    tabs = {
        { label = "General", create = function(parent)
            Options:Toggle(parent, { label = "Enabled", get = function() return MyAddon.db.enabled end, set = function(v) MyAddon.db.enabled = v end })
        end},
    },
})
```

## Reference Addons

| Addon | What It Proves |
|---|---|
| BLU | Full sound/progression suite â€” profiles, shared media, combat, 15+ event triggers |
| ETL | Traveler's Log handling, minimap, slash commands |
| SQP | Large options panels, UI controls, fonts, nameplate events |
| RND | Small utility addon pattern â€” events, timers, minimap, settings |

Lessons from these addons feed back into RGX-Framework when a pattern is reusable.

## Docs

- [[Architecture]] - Load order, module system, lifecycle, conventions
- [[API Reference]] - Complete public API by module
- [[Fonts]] - Registry, blocked fonts, apply helpers, dropdowns, style objects
- [[Dropdowns]] - CreateNestedDropdown, item schema, auto-width, inline buttons
- [[Theming & Design]] - Design palette, color usage, font styling, templates
- [[Troubleshooting]] - Common issues and fixes
- [[Migration Guide]] - From Ace3, LibSharedMedia, standalone implementations
