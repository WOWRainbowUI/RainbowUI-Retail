# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SQP (Simple Quest Plates) is a professional World of Warcraft addon that displays quest progress icons on enemy nameplates. As of v1.0.0, it features a streamlined architecture, persistent settings, multi-language support, extensive error handling, and a comprehensive options panel with live preview functionality as part of the RGX Mods collection.

## Project Structure

### Core Files
- **SimpleQuestPlates.toc**: TOC file for retail WoW (The War Within)
- **SimpleQuestPlates.xml**: Main XML loader for all addon files
- **data/core.lua**: Main addon initialization and settings management
- **data/events.lua**: Event handling and registration
- **data/nameplates.lua**: Nameplate tracking and icon creation
- **data/quest.lua**: Quest detection and progress tracking
- **data/commands.lua**: Slash command implementation

### Options Panel
- **data/options_core.lua**: Main options panel creation
- **data/options_tabs.lua**: Tab system implementation
- **data/options_widgets.lua**: Custom UI widgets
- **data/options_header.lua**: Options panel header
- **data/options_preview.lua**: Live preview functionality
- **data/options_general.lua**: General settings tab
- **data/options_font.lua**: Font customization tab
- **data/options_icon.lua**: Icon settings tab
- **data/options_about.lua**: About information tab
- **data/options_rgx.lua**: RGX Mods community tab

### Localization
- **locales/enUS.lua**: English translations
- **locales/deDE.lua**: German translations
- **locales/esES.lua**: Spanish translations
- **locales/frFR.lua**: French translations
- **locales/ruRU.lua**: Russian translations

### Resources
- **images/icon.tga**: Addon icon (128x128)

## Commands

Use `/sqp` followed by various commands for full functionality:

- `/sqp` - Open options panel
- `/sqp help` - Show all available commands
- `/sqp on/off` - Enable/disable addon
- `/sqp test` - Test functionality
- `/sqp status` - Show current settings
- `/sqp scale <0.5-2.0>` - Set icon scale
- `/sqp offset <x> <y>` - Set icon offset
- `/sqp reset` - Reset all settings to defaults

## Settings Architecture

**SavedVariables**: `SQPSettings` automatically managed with fallback defaults

The addon uses an optimized, professional architecture:

1. **Constants Management**: Performance-optimized with cached local constants
2. **Global Namespace**: `SQP` table with proper initialization and namespacing
3. **Settings System**: Complete configuration management with type validation
4. **Event System**: Optimized event handling with combat state tracking
5. **Slash Commands**: Complete `/sqp` interface with comprehensive validation
6. **Error Handling**: Enterprise-grade protection with `pcall` protection
7. **Localization**: Multi-language support with automatic locale detection
8. **Options Panel**: Tab-based interface with live preview
9. **Quest Detection**: Smart priority system (items over kills)
10. **Performance**: Minimal CPU/memory usage with efficient caching

## RGX Mods Standards

This addon follows RGX Mods community standards with Discord integration and professional error handling.

## Key Features

- **Retail-Only Support**: Designed specifically for The War Within
- **Item Priority Display**: Shows item counts before kill counts when both are required
- **Hide Options**: Can hide icons in combat or instances
- **Live Preview**: Real-time preview of appearance changes
- **Color Customization**: Separate colors for kill, item, and progress quests
- **Font Options**: Size, outline style, and outline color customization
- **Icon Tinting**: Optional icon color tinting
- **Settings Validation**: All user inputs are type-checked and validated
- **Error Resilience**: Addon continues functioning even with errors
- **Performance**: Optimized for minimal memory and CPU usage
- **Maintainability**: Clean, modular code structure
- **User Experience**: Consistent RGX Mods branding with professional UI
- **Community Integration**: RealmGX Discord integration throughout

## Development Notes

- Version centralized in `SQP.VERSION` in `core.lua`
- Settings persist automatically via SavedVariables
- Multi-language support with automatic locale detection
- Professional error handling with pcall protection
- Quest progress detection using C_QuestLog and tooltip APIs
- Nameplate tracking via NAME_PLATE_* events
- Combat state tracking via PLAYER_REGEN_* events
- All color options use RGB tables {r, g, b}
- Font outlines use WoW's built-in outline system
- Icons use SetVertexColor for tinting

## Testing Checklist

1. Quest detection (`/sqp test`)
2. Icon positioning and scaling
3. Color customization (all three quest types)
4. Font settings (size, outline, colors)
5. Hide in combat/instance functionality
6. Live preview updates
7. Tab navigation and scrolling
8. Reset buttons functionality
9. Slash commands
10. Localization

## Version Management

When updating the addon version:

1. **Update version in these files:**
   - `SimpleQuestPlates.toc` - Update `## Version:` line
   - `data/core.lua` - Update both the comment header and `SQP.VERSION` variable

2. **Update changelogs:**
   - `CHANGELOG.md` - Add new version entry with all changes since previous version
   - `docs/CHANGES.md` - **IMPORTANT**: This file should ONLY contain the current version changes (gets displayed on push). Remove all previous version entries when updating.

3. **Version format:** Use semantic versioning (e.g., 1.0.1, 1.1.0, 2.0.0)