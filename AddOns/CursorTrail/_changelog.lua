--[[---------------------------------------------------------------------------
    Addon:  "CursorTrail"
    File:   _changelog.lua
    Desc:   Text to display in the changelog window.
-----------------------------------------------------------------------------]]
----local kAddonFolderName, private = ...
setfenv(1, _G.CursorTrail)  -- Everything after this uses our namespace rather than _G.
kChangelogText =
[[
=======================================
RELEASE 11.2.7.1
Released 2025-12-02

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.2.7.1 for Retail WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Retail WoW 11.2.7.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 5.5.2.2 for Classic Mists of Pandaria
Version 1.15.8.2 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.

=======================================
RELEASE 11.2.5.2
Released 2025-10-31

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.2.5.2 for Retail WoW
Version 5.5.2.1 for Classic Mists of Pandaria
Version 1.15.8.1 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Increased the editbox width in the Save and Rename popup windows.
- Updated for Classic MoP 5.5.2 and Classic WoW 1.15.8.

=======================================
RELEASE 11.2.5.1
Released 2025-10-09

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.2.5.1 for Retail WoW
Version 5.5.1.1 for Classic Mists of Pandaria
Version 1.15.7.5 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Retail WoW 11.2.5 and Classic MoP 5.5.1.
- Fixed error when saving/renaming profiles using the UI.  (UDProfiles.lua 4602)

=======================================
RELEASE 11.2.0.1
Released 2025-08-05

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.2.0.1 for Retail WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Retail WoW 11.2.0.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.2.0.1 for Retail WoW
Version 5.5.0.2 for Classic Mists of Pandaria
Version 1.15.7.4 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Fixed bad use of an internal font (Game120Font) that may have been causing it to appear very faded in other parts of the game and/or other addons.

=======================================
RELEASE 11.1.7.2
Released 2025-07-01

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 5.5.0.1 for Classic Mists of Pandaria
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Classic MoP 5.5.0.
- Fixed offsets for many of the models.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.1.7.2 for Retail WoW
Version 1.15.7.3 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.

=======================================
RELEASE 11.1.7.1
Released 2025-06-17

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.1.7.1 for Retail WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Retail WoW 11.1.7.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 4.4.2.6 for Classic Cataclysm
Version 1.15.7.2 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.
=======================================
RELEASE 11.1.5.1
Released 2025-04-22

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.1.5.1 for Retail WoW
Version 4.4.2.5 for Classic Cataclysm
Version 1.15.7.1 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Retail WoW 11.1.5 and Classic WoW 1.15.7.
- Fixed the "ThinBorderTemplate" error in Retail WoW.
- Added a tooltip for the icon that indicates the selected profile is used for all characters.

=======================================
RELEASE 11.1.0.1
Released 2025-02-26

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.1.0.1 for Retail WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Retail WoW 11.1.0.
- Fixed bug that caused cursor FX to not move while CursorTrail settings were open and the mouse was over the world background.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.1.0.1 for Retail WoW
Version 4.4.2.3 for Classic Cataclysm
Version 1.15.6.4 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Changed the "Electric" default.  ("Fade out when idle" is now on.)
- Minor improvements to error handling.
- Minor changes to help text.

=======================================
RELEASE 11.0.7.3
Released 2025-02-18

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.0.7.3 for Retail WoW
Version 4.4.2.1 for Classic Cataclysm
Version 1.15.6.2 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
NEW FEATURES:
- Added new defaults:
        Ring Dim Mouse Look

- Added slash command:
        /ct combat      (Toggles the 'Show only in combat' setting.  All layers set same as first layer.)

CHANGES:
- Fixed "Show during Mouse Look" so it works properly while the options window is open.

- No longer create a backup named "@Original".  Renamed existing "@Original" backup to "Original" so it can be deleted.

- Removed "New" feature indicators for master scale and layer tabs.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 4.4.2.1 for Classic Cataclysm
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Classic Cataclysm 4.4.2.

=======================================
RELEASE 11.0.7.2
Released 2025-01-29

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.0.7.2 for Retail WoW
Version 4.4.1.4 for Classic Cataclysm
Version 1.15.6.1 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Added new defaults:
        Ring Dark Edges
        Star Dark Edge
        Star Doubled

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 1.15.6.1 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Classic WoW 1.15.6.

=======================================
RELEASE 11.0.7.1
Released 2024-12-17

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.0.7.1 for Retail WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for WoW 11.0.7.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 4.4.1.3 for Classic Cataclysm
Version 1.15.5.2 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.

=======================================
RELEASE 11.0.5.3
Released 2024-11-20

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.0.5.3 for Retail WoW
Version 4.4.1.2 for Classic Cataclysm
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 1.15.5.1 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Classic WoW 1.15.5.

]]

--- End of File ---