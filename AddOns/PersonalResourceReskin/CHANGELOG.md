# Personal Resource Display Reskin - Changelog

## [1.0.1] - 2026-11-03
### Fixed
- **Devourer Demon Hunter souls count text went back to the middle of the screen after every reload.** Its position was never saved, and when the souls bar wasn't made yet at login it fell back to the screen centre.
  - Where you drag it is now saved, measured from the souls bar (or from the screen when not attached), and put back after a reload.
  - It looks for the souls bar again for a few seconds after login / reload / spec change, and every time the bar shows.
### Added
- Devour Text options: **Attach to the souls bar** (on: moves with the bar; off: stays where you put it on the screen), **Left / right** and **Up / down** sliders, **Reset position**.
