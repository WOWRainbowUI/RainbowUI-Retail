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

=======================================
RELEASE 11.0.5.2
Released 2024-10-29

- - - - - - - - - - - - - - - - - - - - - - - - - -
Version 11.0.5.2 for Retail WoW
Version 4.4.1.1 for Classic Cataclysm
Version 1.15.4.4 for Classic WoW
- - - - - - - - - - - - - - - - - - - - - - - - - -
NEW FEATURES:
- Added layer 3.

- Added "Master Scale (%)" for changing the size of all FX on all layers at once.

- Added small icon buttons next to each setting for copying its value to all other layers.

- Added "Copy Layer" and "Paste Layer" to the context menu that appears when right-clicking an empty area of the main window's background.

- When clicking on layer tab names ...
        Left-click              = Selects that layer.  (Normal behavior.)
        Shift + Left-click  = Toggles that layer's enabled state without selecting it.
        Right-click            = Opens the context menu.
        Shift + Right-click = Selects that layer and toggles its enabled state.

- Added new default:
        Ring & Rainbow 2  ...  Retail WoW only.

CHANGES:
- Changed context menu "swap layer" lines into "move layer" lines.

- Added icons to the context menu lines "Enable/Disable Layer", and "Reset Layer".

- Added sounds to context menu items that didn't have one.

- Mouse wheel is now ignored when over an empty area of the main window.  (Prevents accidentally zooming the screen when using the mouse wheel to change values.)

- Updated some defaults:
        Electric B&W Rings
        Evil Eye
        Ring & Electric Trail

- Updated help.

BUG FIXES:
- Fixed problems that occurred while typing the /ct slash command while the main window was disabled by a popup message that required an answer.

- Fixed problems caused by closing the main window with the /ct slash command while all layers were disabled.  (BUG_20241016.1)

- Fixed right-clicking to open the context menu when the mouse is over a checkbox.

- Opening or closing the color picker without making any changes no longer marks the profile as unsaved.

]]

--- End of File ---