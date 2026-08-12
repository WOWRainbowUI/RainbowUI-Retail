# Advanced Interface Options

## [2.1.12](https://github.com/Stanzilla/AdvancedInterfaceOptions/tree/2.1.12) (2026-08-07)
[Full Changelog](https://github.com/Stanzilla/AdvancedInterfaceOptions/compare/2.1.11...2.1.12) [Previous Releases](https://github.com/Stanzilla/AdvancedInterfaceOptions/releases)

- Fix game marking addon as incompatible with current game version  
    - Putting a comment above the `## Interface` line invalidates the file  
    - `# WOW_INTERFACE_TARGETS` cannot be on line 1  
- Guard the status text repaint against secret values  
