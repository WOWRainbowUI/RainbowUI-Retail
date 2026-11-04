# MinimalistCooldownEdge: WoW Forever support

Version: `4.7.2`. One source branch and version serve both editions.

## Behavior

Shared styling with the modern Forever widgets. HealerCC and sArena adapters are inactive in Forever. Compression uses the available native namespace.

## Validation status

The implementation is checked against the extracted Forever UI source
`1.60.1.70338` (project `WOW_PROJECT_CAMELOT`, interface `16001`). This is a source
reference, not an in-game test. Static checks and mocked Lua checks do not establish
combat safety, visual correctness, SavedVariables persistence or dependency compatibility.

Forever runtime: **pending, no local Forever client**. Retail runtime: **pending**.
Dependencies: **pending in-game validation**.

In game, `/minimalistcooldownedgeclient` prints the actual client/build and required dependency versions.
Record the tested build, tester, evidence and statuses in `Tools/validation.json`.

## In-game checks

Action bars, cooldown viewers, player/party auras, secrets in combat, charges, export/import and supported optional adapters. Test the isolated worktree version.

For both editions: clean installation, options, `/reload`, relog, full restart,
settings persistence, relevant group/combat content, Lua errors and taint logs.
Use separate client installations and keep existing user profiles; there is no
automatic Retail-to-Forever SavedVariables transfer.

## Packages

Run `py Tools/package.py --output .release` locally to create **QA drafts**:

- `MinimalistCooldownEdge-4.7.2-Retail.zip`
- `MinimalistCooldownEdge-4.7.2-Forever.zip`

The earlier October feedback candidate is `MinimalistCooldownEdge-4.7.0.zip` in the workspace's
`CurseForgeFeedback/packages` directory. Its `BUILD.json` records the outstanding
Retail and Forever runtime checks.

Each archive contains the unchanged addon folder name and edition-specific TOC
metadata. Install a draft only in the intended client's `Interface/AddOns` directory.
`BUILD.json` records the source commit, dirty state, file hashes and QA status.

For a fully validated stable package, use `--release --tag <matching-version-tag>` from a clean,
tagged checkout after recording PASS for static checks, Forever runtime, Retail
runtime and dependencies, plus the actual Forever build and tester. The builder
does not create tags, install addons or upload files. The existing CurseForge
project can host both edition files. The current public Forever build is a Release. Its in-game checks remain as recorded above.

## Sources

- [Forever client constants](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_ProjectConstants/Camelot/ProjectConstants.lua)
- [Forever UI source](https://github.com/Gethe/wow-ui-source/tree/forever)

## Distribution

Public releases use one archive with the declared client interfaces and Forever
interface 16001. Runtime and dependency validation retain their recorded status.

This version also includes the existing Retail stance-button styling option and
static stance cooldown text colors. The original Retail working copy is preserved.

## Current public release

Version `4.7.2` is available as a CurseForge Release for WoW Forever `1.60.1`
(interface `16001`) and the other declared client versions. Release status does not
change the in-game and dependency validation records above.

[Download the verified release](https://edge.forgecdn.net/files/9326/796/MinimalistCooldownEdge-4.7.2-Release.zip)
