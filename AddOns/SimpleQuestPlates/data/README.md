# /data

Runtime Lua modules for the addon.

## Core Runtime

- `core.lua` - Addon bootstrap, defaults, settings migration, and shared utilities
- `compat.lua` - Cross-version API abstraction layer
- `compat_mop.lua` - MoP/Classic-specific compatibility helpers
- `events.lua` - Event registration and dispatch
- `nameplates.lua` - Nameplate lifecycle and frame attachment
- `quest.lua` - Quest objective detection and progress resolution
- `commands.lua` - `/sqp` slash command handling

## Options UI

- `options_core.lua` - Main options panel frame and registration
- `options_tabs.lua` - Tab setup (`Global`, `Kill`, `Loot`, `Percent`, `About`)
- `options_widgets.lua` - Shared widget helpers for controls
- `options_header.lua` - Panel header and title area
- `options_preview.lua` - Live nameplate preview and animation behavior
- `options_general.lua` - Global behavior and toggles
- `options_icon.lua` - Main icon position/scale/style controls
- `options_kill.lua` - Kill objective visuals and settings
- `options_loot.lua` - Loot objective visuals and settings
- `options_percent.lua` - Percent objective visuals and settings
- `options_about.lua` - About panel content

## Notes

- Files in this directory are loaded by `SimpleQuestPlates.xml` in a fixed order.
- Legacy, unreferenced option modules were removed in `v1.9.6`.
