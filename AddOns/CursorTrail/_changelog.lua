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
RELEASE 12.0.1.2
Released 2026-03-05

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 12.0.1.2 for Retail WoW
Version 5.5.3.4 for Classic Mists of Pandaria
Version 1.15.8.6 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 2.5.5.4 for Classic Burning Crusade
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated the list of models for TBC.  Previously, TBC was using the same list as Classic WoW, but several of those models did not work in TBC.

=======================================
RELEASE 12.0.1.1
Released 2026-02-10

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 12.0.1.1 for Retail WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Retail WoW 12.0.1.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 5.5.3.3 for Classic Mists of Pandaria
Version 2.5.5.3 for Classic Burning Crusade
Version 1.15.8.5 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.

Known Issues:
- In Classic Burning Crusade, some of the choices in models list do not work properly.  (e.g. "Spots - Flare" and Glow - Electric, Red".)

=======================================
RELEASE 12.0.0.1
Released 2026-01-23

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 12.0.0.1 for Retail WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Retail WoW 12.0.0 (Midnight).

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 5.5.3.2 for Classic Mists of Pandaria
Version 2.5.5.2 for Classic Burning Crusade
Version 1.15.8.4 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.

=======================================
RELEASE 11.2.7.2
Released 2026-01-20

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.2.7.2 for Retail WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
:ATTENTION:
CursorTrail has NOT been updated to work with WoW Midnight.
My computer is too old to run Midnight, so I am attempting to switch to Linux.  New hardware should arrive in 2-3 weeks.  Hopefully, I can get the game running and test CursorTrail on Midnight after that.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 5.5.3.1 for Classic Mists of Pandaria
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Classic MoP 5.5.3.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 2.5.5.1 for Classic Burning Crusade
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Added support for Classic TBC 2.5.5 anniversary release.

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 1.15.8.3 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.

=======================================
RELEASE 11.2.7.1
Released 2025-12-02

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.2.7.1 for Retail WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- Updated for Retail WoW 11.2.7 (The War Within).

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
- Updated for Retail WoW 11.2.0 (The War Within).

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
- Updated for Retail WoW 11.1.7 (The War Within).

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 4.4.2.6 for Classic Cataclysm
Version 1.15.7.2 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
- No changes.

]]

--- End of File ---