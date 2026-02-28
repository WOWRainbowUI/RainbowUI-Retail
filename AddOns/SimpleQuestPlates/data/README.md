# /data

This directory contains the core Lua source code for the Simple Quest Plates addon.

## Core Files

| File | Description |
|---|---|
| `core.lua` | Main addon initialization, settings management, and global namespace setup. |
| `compat.lua` | Compatibility layer for handling API differences between WoW versions. |
| `compat_mop.lua` | MoP-specific compatibility functions. |
| `events.lua` | Handles all game events, such as `PLAYER_ENTERING_WORLD` and nameplate updates. |
| `nameplates.lua`| Manages the creation, tracking, and updating of quest icons on nameplates. |
| `quest.lua` | Contains the logic for detecting quest objectives and progress for units. |
| `commands.lua` | Implements all `/sqp` slash commands. |

## Options Panel Files

| File | Description |
|---|---|
| `options_core.lua` | Creates the main options panel window. |
| `options_tabs.lua` | Implements the tab system for the options panel. |
| `options_widgets.lua`| Defines custom UI widgets used in the options panel. |
| `options_header.lua`| Creates the header section of the options panel. |
| `options_preview.lua`| Implements the live preview functionality for settings changes. |
| `options_general.lua`| Contains the UI and logic for the "General" settings tab. |
| `options_font.lua` | Contains the UI and logic for the "Font" settings tab. |
| `options_icon.lua` | Contains the UI and logic for the "Icon" settings tab. |
| `options_about.lua` | Contains the UI and logic for the "About" tab. |
| `options_rgx.lua` | Contains the UI and logic for the RGX Mods community tab. |
