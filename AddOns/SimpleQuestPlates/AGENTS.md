# Repository Guidelines

## Project Structure & Module Organization

**SimpleQuestPlates** is a World of Warcraft addon with a modular Lua architecture:
- `data/` - Core addon functionality (17 Lua modules)
- `locales/` - Internationalization files (6 languages)
- `docs/` - Documentation and changelogs
- `images/` - Icons, logos, and UI assets
- Multiple `.toc` files for different WoW versions (Retail, Classic, Cata, MoP, Wrath, Vanilla)

## Build, Test, and Development Commands

```bash
# No build process required - Lua addon loads directly in WoW
# Test in-game with slash commands:
/sqp test          # Test quest detection
/sqp status        # Show current settings
/sqp help          # Display all commands

# Package for distribution (automated via GitHub Actions)
# Releases are triggered by version tags: git tag v1.4.2
```

## Coding Style & Naming Conventions

- **Indentation**: 4 spaces (no tabs)
- **File naming**: `snake_case.lua` for modules, `PascalCase.toc` for WoW files
- **Function naming**: `SQP:PascalCase()` for public methods, `camelCase()` for local functions
- **Variable naming**: `camelCase` for locals, `PascalCase` for globals
- **Linting**: No automated linting - follows WoW Lua conventions

## Testing Guidelines

- **Framework**: In-game testing using WoW client
- **Test commands**: `/sqp test` for quest detection validation
- **Manual testing**: Load addon in different WoW versions (Retail, Classic variants)
- **Coverage**: Test across all supported WoW versions before release

## Commit & Pull Request Guidelines

- **Commit format**: `type: description` (e.g., `ci: Revert release workflow to v1.1.0 version`)
- **Types**: `ci`, `feat`, `fix`, `docs`, `refactor`, `style`
- **PR process**: Direct commits to main branch (single maintainer project)
- **Release process**: Automated via GitHub Actions on version tags
- **Changelog policy**: Keep only the current release notes in both `docs/CHANGELOG.md` and `docs/CHANGES.md` (single-version changelogs). Replace prior version entries on each release.

---

# Repository Tour

## 🎯 What This Repository Does

**SimpleQuestPlates** is a World of Warcraft addon that displays quest progress icons directly on enemy nameplates, helping players track quest objectives at a glance across all WoW versions from Classic to Retail.

**Key responsibilities:**
- Real-time quest objective tracking on nameplates
- Multi-version WoW compatibility (Retail, Classic Era, Cata, MoP, Wrath, Vanilla)
- Comprehensive customization options for display and positioning

---

## 🏗️ Architecture Overview

### System Context
```
WoW Client → SimpleQuestPlates Addon → Nameplate UI Overlay
     ↓              ↓                        ↓
Quest API    →  Quest Detection  →    Icon Display
Nameplate API → Nameplate Tracking → Position Management
```

### Key Components
- **Core System** (`data/core.lua`) - Addon initialization, settings management, and version detection
- **Quest Engine** (`data/quest.lua`) - Quest progress tracking and objective parsing using WoW APIs
- **Nameplate Manager** (`data/nameplates.lua`) - Nameplate detection, icon creation, and visual updates
- **Compatibility Layer** (`data/compat.lua`, `data/compat_mop.lua`) - Cross-version API abstraction
- **Options System** (`data/options_*.lua`) - 5-tab configuration interface with live preview
- **Event Handler** (`data/events.lua`) - WoW event registration and processing

### Data Flow
1. **Event Detection**: WoW fires nameplate and quest events (NAME_PLATE_UNIT_ADDED, QUEST_LOG_UPDATE)
2. **Quest Analysis**: System parses active quests and matches them to visible units via tooltip scanning
3. **Icon Management**: Creates/updates quest progress icons on relevant nameplates with count/percentage
4. **Real-time Updates**: Continuously refreshes as quest progress changes or nameplates appear/disappear

---

## 📁 Project Structure [Partial Directory Tree]

```
SimpleQuestPlates/
├── data/                          # Core addon modules (17 files)
│   ├── core.lua                   # Main initialization and settings
│   ├── quest.lua                  # Quest detection and progress tracking
│   ├── nameplates.lua             # Nameplate management and icon display
│   ├── events.lua                 # WoW event handling
│   ├── commands.lua               # Slash command processing
│   ├── compat.lua                 # Cross-version compatibility
│   ├── compat_mop.lua             # MoP-specific compatibility
│   └── options_*.lua              # Options panel (6 modules)
├── locales/                       # Internationalization
│   ├── enUS.lua                   # English (default)
│   ├── deDE.lua                   # German
│   ├── esES.lua                   # Spanish
│   ├── frFR.lua                   # French
│   ├── ruRU.lua                   # Russian
│   └── zhCN.lua                   # Chinese
├── docs/                          # Documentation
│   ├── CHANGELOG.md               # Version history
│   └── CHANGES.md                 # Release notes
├── images/                        # UI assets
│   ├── icon.tga                   # Addon icon
│   └── logo.png                   # Branding assets
├── .github/workflows/             # CI/CD automation
│   └── release.yml                # Automated packaging and distribution
├── SimpleQuestPlates.xml          # Module loader
├── SimpleQuestPlates.toc          # Retail addon metadata
├── SimpleQuestPlates_Cata.toc     # Cataclysm metadata
├── SimpleQuestPlates_MoP.toc      # Mists of Pandaria metadata
├── SimpleQuestPlates_Vanilla.toc  # Classic Era metadata
└── SimpleQuestPlates_Wrath.toc    # Wrath of the Lich King metadata
```

### Key Files to Know

| File | Purpose | When You'd Touch It |
|------|---------|---------------------|
| `SimpleQuestPlates.xml` | Module loading order | Adding new Lua files |
| `data/core.lua` | Settings and initialization | Changing default settings or addon behavior |
| `data/quest.lua` | Quest detection logic | Fixing quest tracking issues |
| `data/nameplates.lua` | Icon display system | Modifying visual appearance or positioning |
| `data/events.lua` | WoW event handling | Adding new event responses |
| `SimpleQuestPlates.toc` | Retail addon metadata | Version updates, dependencies |
| `locales/enUS.lua` | English text strings | Adding new translatable text |
| `.pkgmeta` | Packaging configuration | Changing distribution settings |
| `docs/CHANGELOG.md` | Current release notes | Keep only one version section |
| `docs/CHANGES.md` | Current release notes (publish source) | Keep only one version section |

---

## 🔧 Technology Stack

### Core Technologies
- **Language:** Lua (WoW API version) - Required for WoW addon development
- **Framework:** World of Warcraft Addon API - Blizzard's official addon interface
- **UI System:** WoW FrameXML - Native WoW UI framework for interface elements
- **Event System:** WoW Event API - Real-time game state notifications

### Key Libraries
- **WoW Compatibility APIs** - Cross-version API abstraction (C_QuestLog, C_TaskQuest, etc.)
- **Nameplate APIs** - NAME_PLATE_UNIT_ADDED/REMOVED events for nameplate tracking
- **Tooltip APIs** - GameTooltip and TooltipData for quest objective parsing
- **SavedVariables** - WoW's built-in settings persistence system

### Development Tools
- **GitHub Actions** - Automated packaging and multi-platform distribution
- **BigWigsMods Packager** - Industry-standard WoW addon packaging tool
- **CurseForge/Wago/WoWInterface** - Addon distribution platforms

---

## 🌐 External Dependencies

### Required Services
- **World of Warcraft Client** - Host environment for addon execution
- **Blizzard Addon API** - Core functionality for quest and nameplate access
- **WoW SavedVariables System** - Settings persistence across game sessions

### Distribution Platforms
- **CurseForge** - Primary addon distribution (Project ID: 1319776)
- **Wago.io** - Alternative distribution (ID: ANz0AwK4)
- **WoWInterface** - Community distribution (ID: 26957)
- **GitHub Releases** - Direct download and source access

### Environment Variables

```bash
# GitHub Actions (CI/CD)
CF_API_KEY=              # CurseForge API key for automated uploads
WOWI_API_TOKEN=          # WoWInterface API token
WAGO_API_TOKEN=          # Wago.io API token
DISCORD_WEBHOOK=         # Discord notifications for releases
GITHUB_OAUTH=            # GitHub token for release creation
```

---

## 🔄 Common Workflows

### Quest Detection Workflow
1. **Event Trigger**: Player accepts quest or nameplate appears (NAME_PLATE_UNIT_ADDED)
2. **Quest Matching**: System scans active quests via C_QuestLog API
3. **Tooltip Analysis**: Parses unit tooltip for quest objective text patterns
4. **Icon Creation**: Creates quest icon overlay on nameplate with progress count
5. **Real-time Updates**: Monitors QUEST_LOG_UPDATE events for progress changes

**Code path:** `events.lua` → `quest.lua:GetQuestProgress()` → `nameplates.lua:UpdateQuestIcon()`

### Settings Management Workflow
1. **Load Defaults**: Core system loads default settings from DEFAULTS table
2. **Merge Saved Data**: Combines with SavedVariables from previous sessions
3. **UI Binding**: Options panel reflects current settings with live preview
4. **Change Handling**: Settings changes trigger immediate nameplate refresh
5. **Persistence**: WoW automatically saves changes to SavedVariables

**Code path:** `core.lua:LoadSettings()` → `options_*.lua` → `core.lua:SetSetting()` → `nameplates.lua:RefreshAllNameplates()`

---

## 📈 Performance & Scale

### Performance Considerations
- **Event Throttling:** Nameplate updates throttled to prevent excessive CPU usage
- **Quest Caching:** Active quest data cached to minimize API calls
- **Tooltip Optimization:** Tooltip scanning limited to quest-relevant units only
- **Memory Management:** Quest plates reused rather than recreated for performance

### Monitoring
- **Debug Mode:** `/sqp debug` enables detailed logging for troubleshooting
- **Test Commands:** `/sqp test` validates quest detection on current nameplates
- **Status Reporting:** `/sqp status` shows current configuration and state

---

## 🚨 Things to Be Careful About

### 🔒 Security Considerations
- **API Limitations:** Respects WoW's addon security model - no file system or network access
- **Saved Variables:** Settings stored in WoW's secure SavedVariables system
- **Event Handling:** All game events processed through Blizzard's secure event system

### ⚠️ Version Compatibility
- **API Changes:** Different WoW versions have varying API availability (C_QuestLog vs GetQuestLogTitle)
- **Nameplate Systems:** Classic uses different nameplate detection than Retail
- **Interface Numbers:** Each WoW version requires specific interface version in .toc files
- **Compatibility Layer:** `compat.lua` and `compat_mop.lua` handle version differences

### 🎯 Quest System Limitations
- **Tooltip Dependency:** Quest detection relies on tooltip text parsing which can be language-dependent
- **API Restrictions:** Some quest data only available when unit is targeted or moused over
- **Performance Impact:** Excessive nameplate scanning can impact game performance in crowded areas

*Updated at: 2025-01-15 UTC*
