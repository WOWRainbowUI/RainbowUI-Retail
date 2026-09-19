# SimpleQuestPlates

SimpleQuestPlates overlays quest-objective progress on enemy nameplates. The `main` branch is Retail-only: `SimpleQuestPlates.toc` currently targets interface `120007` and requires `RGX-Framework`. Classic support is maintained separately on `classic-fork` and in the `SQP_Classic` repository; do not add Classic interface values or fork-only code to `main`.

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
