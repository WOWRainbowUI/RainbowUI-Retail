# RGX | Simple Quest Plates! - Development Roadmap

<p align="center">
  <img src="images/logo.png" alt="SQP Icon" width="128" height="128">
</p>

## 🎯 Project Complete

Simple Quest Plates v1.0.0 has been successfully completed and is ready for release!

---

## ✅ Version 1.0.0 Features

### Core Functionality
- Quest progress icons on enemy nameplates
- Kill count display for quest objectives
- Item drop indicators for loot quests
- Full customization options (scale, position, colors, fonts)
- Multi-language support (EN, RU, DE, FR, ES)
- Combat and instance hiding options
- Professional options panel with live preview
- RGX Mods community integration

### Technical Implementation
- Modular architecture with 20+ specialized files
- Event-driven nameplate tracking system
- Efficient quest detection and caching
- Account-wide settings via SavedVariables
- Comprehensive error handling
- Zero external dependencies

---

## 🚀 Future Plans

Future updates will be based on community feedback. Join our Discord to suggest features!


fix chat messages formatting to be like ccu and other addons loading messages with version numbers in chat




### Version 1.1.0 - UI Enhancements
- [x] Move Icon Scale to Icon tab as "Global Scale" (max increased to 3.0)
- [ ] Add more background textures for quest text
  - [ ] Solid backgrounds
  - [ ] Gradient options
  - [ ] Semi-transparent overlays
  - [ ] Custom texture support
- [ ] Custom font dropdown selection
  - [ ] System fonts
  - [ ] Popular WoW fonts (Friz Quadrata, etc.)
  - [ ] User-imported fonts support
  - [ ] Font preview in options

---

### Phase 5: README Enhancements & Integrations 🎨
- [ ] Advanced GitHub Stats
  - [ ] Profile visitor counter badge
  - [ ] Repository traffic insights
  - [ ] Stargazers over time chart
  - [ ] Fork network graph visualization
- [ ] Code Quality Badges
  - [ ] CodeFactor integration
  - [ ] Codacy code quality score
  - [ ] Better Code Hub compliance
  - [ ] LGTM security analysis
- [ ] Documentation Badges
  - [ ] Documentation percentage
  - [ ] Wiki page count
  - [ ] API documentation status
- [ ] Social Media Integration
  - [ ] Twitter/X follow button
  - [ ] Discord member count
  - [ ] YouTube subscriber count (for tutorials)
  - [ ] Twitch stream status
- [ ] Sponsor Recognition
  - [ ] GitHub Sponsors tiers display
  - [ ] Buy Me a Coffee supporters wall
  - [ ] Patreon backers section
  - [ ] Special thanks section
- [ ] Interactive Elements
  - [ ] Live demo GIFs/videos
  - [ ] Interactive configuration builder
  - [ ] Command palette generator
  - [ ] Settings export/import tool

### Phase 6: Documentation & Wiki 📚
- [ ] GitHub Wiki setup
  - [ ] Create comprehensive user guide
  - [ ] Installation instructions with screenshots
  - [ ] Troubleshooting section
  - [ ] FAQ page
  - [ ] API documentation for developers
- [ ] Video tutorials
  - [ ] Installation walkthrough
  - [ ] Configuration guide
  - [ ] Feature showcase
- [ ] Localization guides
  - [ ] How to contribute translations
  - [ ] Translation templates
  - [ ] Locale testing instructions
- [ ] Developer documentation
  - [ ] Code architecture overview
  - [ ] Contributing guidelines
  - [ ] Pull request templates
  - [ ] Code style guide
- [ ] Changelog automation
  - [ ] Auto-generate from commits
  - [ ] Version history page
  - [ ] Migration guides for major versions

### Phase 7: Advanced Features & API Integration 🚀
- [ ] Quest Enhancement Features
  - [ ] World Quest integration (C_TaskQuest API)
  - [ ] Campaign/Story quest special indicators
  - [ ] Daily/Weekly quest differentiation
  - [ ] Quest chain awareness
  - [ ] Prerequisite quest detection
- [ ] Performance Optimizations
  - [ ] Event throttling (0.5-1s update intervals)
  - [ ] Selective nameplate processing (range-based)
  - [ ] Advanced caching system
  - [ ] Performance unit tagging
- [ ] Group & Social Features
  - [ ] Shared quest detection for party members
  - [ ] Group progress synchronization
  - [ ] Quest objective pinging to party
  - [ ] Auto-announce completion options
- [ ] Advanced Visual Features
  - [ ] Dynamic icon scaling by distance
  - [ ] Progress update animations
  - [ ] Multiple quest icon stacking
  - [ ] Quest priority visual indicators
- [ ] Tooltip Enhancements
  - [ ] Detailed quest objectives on hover
  - [ ] Achievement progress integration
  - [ ] Completion percentage estimates
  - [ ] Related achievement tracking
- [ ] Popular Addon Integration
  - [ ] WeakAuras export functionality
  - [ ] ElvUI theme compatibility
  - [ ] Details! efficiency tracking
  - [ ] BigWigs/DBM boss mechanic awareness
- [ ] Smart Features
  - [ ] Optimal quest path suggestions
  - [ ] Time-to-complete predictions
  - [ ] Meta-achievement support
  - [ ] Rare mob special indicators
- [ ] Modern API Updates
  - [ ] C_UnitAuras optimization
  - [ ] Secure template compliance
  - [ ] Runtime localization switching
  - [ ] Enhanced tooltip API usage

### Implementation Notes
1. **WoWInterface Setup**: Requires manual addon submission first, then API token can be generated from account settings
2. **Wago Integration**: Uses BigWigsMods packager which handles Wago uploads automatically with proper API token
3. **Discord Webhooks**: Already implemented, triggered on successful release
4. **Version Syncing**: All platforms will receive updates simultaneously through GitHub Actions
5. **Wiki Access**: Enable GitHub Wiki in repository settings, create initial structure

---

<p align="center">
  <strong>Simple Quest Plates</strong><br>
  Part of the RGX Mods Collection<br>
  <em>Discord: discord.gg/N7kdKAHVVF</em>
</p>