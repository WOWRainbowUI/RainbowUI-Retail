# AGENTS.md

This repo is a World of Warcraft addon written in Lua, with keybindings declared in XML. It adds a guide mode to Mythic Dungeon Tools (MDT) for use during a run, and works almost entirely by hooking into MDT's frames and methods. The entrypoint and file load order are controlled by the TOC.

## Project structure

The addon is flat, every Lua file sits in the repo root and is loaded in TOC order.

- [MDTGuide.toc](MDTGuide.toc): load order and addon metadata.
- [Bindings.lua](Bindings.lua) and [Bindings.xml](Bindings.xml): keybinding names and the actions they run.
- [Data.lua](Data.lua): per dungeon data (start position, zoom scale) and journal instance to dungeon overrides.
- [Util.lua](Util.lua): helpers for pull iteration, rectangle math, sublevels, chat output, and function throttling.
- [Main.lua](Main.lua): the feature set, split into sections by banner comments (toggle mode, zoom, fade/hide, announce, enemy forces, progress, state, events/hooks).
- [Options.lua](Options.lua): Blizzard Settings UI registration and SavedVariables migrations.
- [.types.lua](.types.lua): EmmyLua annotations for MDT's own classes and for Blizzard types that ship none.
- [README.md](README.md): short project description.
- [CHANGELOG.md](CHANGELOG.md) and [CHANGES.md](CHANGES.md): notes and history.

## Dependencies and toolkits

- Mythic Dungeon Tools
  - Hard dependency declared as `## Dependencies: MythicDungeonTools` in the TOC, the addon does nothing without it.
  - Accessed through the global `MDT` table. A local copy usually sits next to this repo at `../MythicDungeonTools`, use it to check frame and method names.
  - Most MDT internals used here are undocumented, so treat its frame layout as something that changes between MDT releases.
- World of Warcraft API
  - Blizzard UI: Settings, CreateFrame, animation groups, GameTooltip, `MaximizeMinimizeButtonFrameTemplate` and `SquareIconButtonTemplate`.
  - Instance and progress data: C_Scenario, C_ScenarioInfo, C_Map, EJ_GetInstanceForMap, C_ChatInfo.
  - SavedVariables: `MDTGuideDB` (account). `MDTGuideActive` and `MDTGuideOptions` are legacy globals that only exist so old profiles can be migrated.
- No embedded libraries and no packager externals, the shipped addon is just these files.

## Feature overview

- Goal: turn the MDT planning window into something usable while running the dungeon, without taking over the screen.
- Guide mode
  - Toggle through the minimize button, a keybind, or `MDTG.ToggleGuideMode()`, and restore MDT's normal layout on exit.
  - Shrink the window, hide the planning controls, and move the pull list into a side panel.
  - Zoom and scroll to the pull that is currently relevant, with optional animated transitions.
  - Fade the window while the mouse is away from it, and hide it during combat.
- Progress tracking
  - Derive the current pull from enemy forces and defeated bosses, and color already pulled enemies.
  - Follow dungeon progress automatically on scenario criteria updates.
  - Offsets let the player correct the tracked pull when the automatic estimate drifts, either for the rest of the run or until the next reset.
- Navigation
  - Buttons and keybinds to view the current, previous, or next pull, and to set the tracked pull to any of them.
- Announce
  - Post the selected pulls, or every pull from the current one onwards, to party or instance chat.

## Coding style and conventions

- Lua + EmmyLua annotations
  - Frequent use of `---@class`, `---@type`, `---@param`, `---@return`, `---@generic`.
  - MDT types belong in [.types.lua](.types.lua). Add a field there instead of casting at the call site.
- Namespacing
  - Each file starts with `local Name = ...` and `local Addon = select(2, ...)`, the public namespace is exposed as `MDTG = Addon`.
  - Functions live directly on the addon table in dot style: `function Addon.MethodName(...)`.
  - [Options.lua](Options.lua) is the exception, it uses `local Self = {}` with method style `function Self:MethodName(...)`.
- State
  - Shared mutable state (frame references, tickers, animation groups) sits in `local` upvalues at the top of [Main.lua](Main.lua).
  - Constants go on the addon table in [Main.lua](Main.lua), dungeon data goes in [Data.lua](Data.lua).
- MDT integration
  - Prefer `hooksecurefunc` over replacing MDT methods. Replace one only when the original has to be wrapped, as `DrawHull` does.
  - All hooks are installed in one place, the `ADDON_LOADED` branch of the event handler in [Main.lua](Main.lua).
  - Guard anything that touches the interface with `Addon.IsActive()` or a `MDT.main_frame` check.
- Formatting
  - 4-space indentation, no trailing semicolons.
  - Sections in [Main.lua](Main.lua) are separated by the dashed banner comments already in the file.

## Releases

- Changelog files
  - [CHANGES.md](CHANGES.md) holds the notes for the *next* release only. The packager ships it verbatim as the release description on every site (`manual-changelog` in [.pkgmeta](.pkgmeta)), so write it for players, not for developers.
  - [CHANGELOG.md](CHANGELOG.md) is the full history and always lags one release behind.
  - Append a bullet to the bottom of CHANGES.md in the same commit as the change itself.
  - In the first commit after a tag, move the CHANGES.md content into CHANGELOG.md as a new `Version <tag>` section at the top, then replace CHANGES.md with the entries for the next release. The tagged commit itself does not touch either file.
- Changelog writing style
  - See "Writing texts for humans" below, it applies here
  - Section format: `Version 2.06`, blank line, `- ` bullets, blank line before the next section. No markdown headings, no trailing periods.
  - Minor versions are zero-padded to two digits (`2.06`, `2.10`), major bumps use `.00` (`2.00`).
  - Imperative mood, capitalized: `Add ...`, `Fix ...`, `Improve ...`, `Update ...`, `Show ...`, `Make ...`, `Allow ...`, `Don't ...`. Older entries use past tense; don't copy that.
  - Order within a section: additions, then changes and improvements, then fixes, then `Internal: ...` bullets for refactors with no visible effect.
  - Describe the visible behavior, not the implementation: "Fix progress tracking in Pit of Saron", not "Add criteria type check in GetNumDefeatedEncounters".
  - Game patch compatibility bumps get their own bullet instead of being folded into another one, even when the release also contains other changes: `Update ToC version for patch 12.0.5`.
- Triggering a release
  - Releases are driven entirely by git tags pushed to `origin`, there is no manual upload step.
  - Tag names must match `^\d[\d\.]*(-(debug|alpha|beta)\d+)?$` (`2.07`, `2.08-beta1`, `3.00-alpha1`), otherwise the deploy jobs don't run.
  - The tag becomes the addon version: [MDTGuide.toc](MDTGuide.toc) carries `## Version: 2.08`, which the packager substitutes. The `#@do-not-package@` block at the end of the TOC keeps local checkouts on `0-dev0`.
  - Release type follows the tag name: `alpha`/`debug` -> alpha, `beta`/`next`/`ptr` -> beta, anything else -> full release. An untagged build is always alpha.
- Cutting a release
  - ALWAYS ask before the final step (push) of a release, even when asked to create a release
  - Check that CHANGES.md covers every user-visible change since the last tag, in the style above.
  - Bump `## Interface:` in [MDTGuide.toc](MDTGuide.toc) if the release targets a new game patch.
  - Commit, tag that commit with the bare version number, and push both: `git push origin master --tags`.
  - Only increase the major version when specifically asked to, usually increase the minor version.
  - Watch the GitLab pipeline; the five deploy jobs publish to CurseForge, WoWInterface, Wago, GitHub and GitLab.
  - In the next commit, roll CHANGES.md into CHANGELOG.md under the tag just pushed.

## Practical guidance for agents

- Respect TOC load order when adding files; [Data.lua](Data.lua) and [Util.lua](Util.lua) load before [Main.lua](Main.lua), and [Options.lua](Options.lua) loads last.
- New settings go into `Options:RegisterGeneralSettings` using the `CreateSlider`, `CreateCheckbox` and `CreateCheckboxSlider` helpers. A new option also needs a default in the `MDTGuideDB` table in [Main.lua](Main.lua) and a step in `Options:Migrate` with a bumped `options.version`.
- New keybinds need matching entries in [Bindings.lua](Bindings.lua) and [Bindings.xml](Bindings.xml), and the XML calls the function through the `MDTG` global.
- Per dungeon quirks belong in [Data.lua](Data.lua): `Addon.dungeons` for start position and zoom scale, `Addon.instances` for journal instances that MDT maps to the wrong dungeon.
- The `--@do-not-package@` blocks are stripped by the packager, use them for anything that should only run in a local checkout.
- Upstream source and release info lives on CurseForge, with source mirror at https://gitlab.com/shrugal/MDTGuide.
- A documentation of the World of Warcraft API can be found at https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

## Writing texts for humans (comments, docs, changelogs)

- **Write complete sentences**, not parts stitched together with "-" or ";". No em dashes and no
  semicolons: a clause worth setting apart is worth its own sentence, and where the aside is a list,
  a colon does the job. En dashes stay in ranges (`4–20 minutes`, `Name A–Z`) — a dash is never a
  stand-in for a missing value ("Not known" says that instead).
- **Focus on what is or what should be done**. Don't explain the reason unless it's relevant for decisions
  the user has to make. Don't mention what potential alternatives have not been realized.
- **Don't list every option**, just the most relevant/common/likely ones.
- **Banned outright**, because they read as filler or as jargon a reader cannot act on: honest(ly),
  genuine(ly), load-bearing, footgun, blast radius, circuit breaker, gate(d), critical(ly), clean(ly),
  precise(ly), robust, seamless(ly), comprehensive(ly), bespoke, delve, nuanced, multifaceted, pivotal,
  leverage. Also banned as sentence frames: "measured rather than assumed", "shown rather than hidden",
  "worth noting", "important to remember", "exactly as designed".
