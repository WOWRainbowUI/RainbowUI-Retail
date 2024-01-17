Version 1.26

- Updated for MDT 4.3.1.*

Version 1.25

- Added command to disable map animations
- Removed height setting command
- Fix some hidden UI elements reappearing after closing and reopening MDT

Version 1.24

- Updated for patch 10.2
- Updated for MDT 4.2.0.*
- Fixed trying to scroll to pull when no pull data is available

Version 1.23

- Updated for patch 10.1.5

Version 1.22

- Updated for MDT 4.0.4.*

Version 1.21

- Fix hull drawing when changing maps
- Remove blacklist skipping again as it's no longer necessary

Version 1.20

- Updated ToC version for patch 10.1
- Add MDT version check to prevent breaking it
- Skip blacklisting (hopefully this is temporary)

Version 1.19

- Fix missing guide mode toggle button

Version 1.18

- Add missing start locations for dragonflight S1 dungeons
- Switch to enemy forces mode for dungeons with no known start locations
- Fix not fading some frames when fade is enabled
- Make fading progress smoothly between values
- Add option to hide window completely while in combat
- Remember current route when reloading/relogging or leaving the dungeon
- Ignore mobs summoned during combat in route estimation

Version 1.17

- Fix more errors caused by missing dungeon POIs

Version 1.16

- Fix portal map building for dungeons without portals
- Improve zoom levels for dragonflight season 1 dungeons

Version 1.15

- Fix current instance detection and zooming to current pull

Version 1.14

- Fix top bar button placement
- Scale pull number on the map with zoom level

Version 1.13

- Updated ToC version

Version 1.12

- Updated ToC version for patch 10.0
- Fix GUI bugs from 10.0 changes

Version 1.11

- Updated ToC version for patch 9.2.5

Version 1.10

- Updated ToC version for patch 9.2

Version 1.09

- Updated ToC version for patch 9.1.5

Version 1.08

- Updated ToC version for patch 9.1

Version 1.07

- Reduced size of new top bar logo in guide mode
- Increased minimum visible area when zooming a bit
- Try to get more groups into view when zooming out

Version 1.06

- Added `zoom` command to scale minimum and maximum zoom
- Changed command parameters a bit

Version 1.05

- Added smooth transitions between pulls
- Added option to fade out window when mouse isn't over it
- Speed up route estimation by adding a min-heap for the path queue as well as length and weight limits
- Improved route estimation accuracy by switching weights to a rolling average
- Fixed switching sublevels manually in guide mode

Version 1.04

- Updated toc version for patch 9.0.5
- Added button to zoom to current pull
- Added button to announce selected or selected and following pulls
- Vastly improved route estimation performance by doing a deep search inside enemy groups

Version 1.03

- Keep zoom level between certain min and max values if possible
- Try to get previous and next pulls into the view if possible
- Take dungeon map scale into account when zooming
- Streamlined overall zoom calculation
- Hull drawing fix should work for all dungeons now

Version 1.02

- Made addon work with alternative MDT addons
- Added "/mdtg height" command and restored resizer in guide mode to change window size
- Adjusted zoom behavior a bit
- Fixed hull-line width and distance to enemy groups on the map
- Fixed breaking dev-mode
- Added missing starting locations for route prediction in Shadowlands dungeons

Version 1.01

- Updated TOC version for patch 9.0.2

Version 1

- Added `/mdtg` chat command to toggle route estimation
- Added experimental route estimation based on shortest path through killed enemies, toggle with `/mdtg route`
- Fixed enemy info frame in guide mode
- Fixed problems after MDT renaming

Version 1-beta3

- Updated TOC version for 8.3

Version 1-beta2

- Added coloring current pull cyan
- Properly handle bosses
- Bugfixes and refinements

Version 1-beta1

- Initial release
- Added compact view for MDT
- Added zooming to selected pull
- Added automatically zooming to current/next pull based on enemy forces
- Added coloring dead enemies red
