# SimpleQuestPlates

SimpleQuestPlates overlays quest-objective progress on enemy nameplates. Main ships one merged build for Retail (`120100`) and the WoW Forever beta (`16001`) through `SimpleQuestPlates.toc`; the separate Forever fork stopped taking new versions after its stable 2.1.7-forever release. Classic support stays separate: classic flavors live in the `SQP_Classic` repository (this repo's `classic-fork` branch is retired for new work); do not add Classic interface values to `main`.

## Layout

- `SimpleQuestPlates.toc` loads `SimpleQuestPlates.xml`, which defines localization and runtime load order.
- `locales/` contains the `enUS` baseline and locale overrides.
- `data/` contains core settings, compatibility helpers, quest/nameplate logic, events, commands, previews, widgets, and option sections.
- `media/` contains addon images; `docs/` contains current release notes, per-version changelogs, and roadmap material.

## Development Rules

- Use existing RGX database, event, timer, minimap, slash-command, and UI APIs where those systems are already integrated. Ordinary UI and tooltip frames remain local to the addon.
- Preserve the script order in `SimpleQuestPlates.xml`; localization must load before runtime modules, and core/compatibility modules must load before their consumers.
- Keep Retail behavior on `main`. Port shared fixes deliberately to `classic-fork` rather than merging the branches or assuming API parity.
- Match surrounding Lua style. Keep `SimpleQuestPlates.toc` and `SQP.VERSION` in `data/core.lua` synchronized when changing versions.
- `docs/CHANGES.md` contains only the current release section.

## Testing And Release

- There is no build step or automated test suite. Install the repository as `SimpleQuestPlates` in the Retail AddOns directory with `RGX-Framework`. Run `/reload` and verify `/sqp help`, `/sqp status`, `/sqp test`, quest and nameplate updates, options tabs and preview refreshes, SavedVariables persistence, and locale fallback behavior.
- Stable releases from `main` use `vX.Y.Z` tags. `.github/workflows/release.yml` validates the tag against `SimpleQuestPlates.toc` and packages with BigWigsMods/packager; pushes to `dev` and `alpha` use those release channels. Update the TOC, `SQP.VERSION`, `docs/CHANGES.md`, and the matching `docs/changelogs/<version>.md` before tagging.

## Repository Workflow

- The GitLab project under `rgxmods/warcraft` is authoritative. Normal work belongs on task branches and must merge through GitLab merge requests, never directly to the default branch.
- Shared CI is included from `rgxmods/warcraft/RGX-Framework` at `/.gitlab/ci/addon.yml`; validation must pass before publishing to the GitHub mirror.
- The GitHub `RGXMods` repository is downstream distribution, not development authority.
- Keep GitLab and GitHub release tags identical, and use protected GitLab release tags.
- Preserve any existing working Wago connection and ID exactly. Never create a new Wago connection without explicit user direction.
- Publishing integrations prohibited by the shared validation policy are retired and must not be restored.
- The root `README.md` must remain detailed and project-specific. Narrow distribution edits must not replace or truncate installation, features, compatibility, usage, media, or support content.
- Verify relative README assets. Do not overwrite newer compatibility facts with stale monorepo or history text.

## Building With RGX-Framework

- Contract first: build addon behavior from the declarative `RGXAddon(name, opts)` table using only keys the framework ships today. Read `docs/DECLARATIVE-API.md` in `rgxmods/warcraft/RGX-Framework` before writing code; tier 4 keys are future targets, not runtime features. Use `onInit` and addon-scoped methods only where the shipped declarative surface genuinely cannot express the behavior.
- MCP tool loop: before writing UI, timer, event, aura, or slash code, run the rgx-framework MCP tools in order: `rgx_get_contract` -> `rgx_generate_addon` -> `rgx_validate_addon` -> `rgx_audit_lua`. Compare generated Lua with existing integration, validate the actual opts table, and audit every changed Lua file. Never hand-roll what the framework ships.
- Prefer framework subsystems over raw WoW API: timers and repeating schedules, event registration, slash commands, minimap button, saved-settings database, aura watching, UI controls and dropdowns, colors, fonts, theming, tooltips, and sound.
- Forbidden patterns that fail `rgx_audit_lua`: raw `C_Timer`, manual event frames, `SLASH_` globals, unguarded `SetAttribute`, raw aura plumbing, and raw hook reassignment. Replace them with framework-managed equivalents; migrate existing compatibility paths deliberately instead of silently breaking them.
- Validation: Lua 5.1 (`luac5.1 -p`) and XML (`xmllint`) must pass through the shared CI include before every MR, and the root README stays nonempty and substantive.
- Dependencies: keep `## RequiredDeps: RGX-Framework` and any `## X-RGX-Framework-MinVersion` accurate against the framework version line, and match the TOC SavedVariables names (`SQPSettings` canonical, `SQPForeverSettings` the read-only legacy migration source) with actual code.
- Repo facts: this addon targets Retail only and uses `/sqp` (`/sqp help`, `/sqp status`, `/sqp test`) for options and diagnostics. The TOC owns the `X.Y.Z-beta.N` version and loads `SimpleQuestPlates.xml`; `SQP.VERSION` in `data/core.lua` bumps with the TOC. The interface number named in the introduction above is historical — the TOC is authoritative. Recheck facts in the TOC and README when they change.

## Keeping Interface Versions Current

- Ground truth is the game client's own `.build.info` in the WoW installation root: one pipe-delimited row per installed product; the Product column names the flavor and the Version column gives `major.minor.patch.build`. Read it immediately before changing a TOC or releasing.
- Derive `## Interface:` as `major * 10000 + minor * 100 + patch` (verified: `1.60.1` -> `16001`, `1.15.9` -> `11509`, `2.5.6` -> `20506`, `5.5.4` -> `50504`). A multi-flavor addon carries a comma-separated list.
- Online cross-checks for builds not installed locally: the wago.tools build pages and versions.wowtools.io. Verify a feed is reachable at runtime before trusting it; if it is unreachable, the installed client's `.build.info` is authoritative and an uninstalled flavor's live version is never guessed.
- A stale `## Interface:` value is a bug: fix it in a task-branch MR with green shared validation before any release.
- Release through GitLab MR and green shared validation, then patch-bump through the same discipline and create a protected GitLab release tag matching the TOC version. Verify the identical tag on the downstream `RGXMods/SimpleQuestPlates` mirror before reporting distribution pickup.
