# AGENTS.md — RGX-Framework

One shared WoW addon framework. Runtime is Lua 5.1-era WoW Lua. Developer
tooling is Node.js. The framework is not a player-facing addon; it loads
silently and exposes an API to dependent addons.

This file is the project entry point for every agent. It is written for two
audiences:

- **Installed-addon agents** helping a user with an RGX-based addon.
- **Source-tree agents** maintaining, testing, or releasing the framework.

## The One Rule

**Use the public contract. Extend the existing rails. Make the bug
unrepresentable.**

Do not reach into internals, rebuild WoW plumbing beside the framework, or
invent a second API for a problem the framework already owns.

## Source-Tree Agents: Read This First

If you have the full repository, read
[`docs/MAINTAINER-CONTRACT.md`](docs/MAINTAINER-CONTRACT.md) before changing
code, contracts, CI, references, or release tooling. It contains the
maintainer-only operating contract, ownership rails, build loop, and escalation
rules. It is not shipped in the player package or the public mirror.

Also read every scoped `AGENTS.md` in the subtree you are editing.

## Installed-Addon Agents: Start Here

The installed addon contains the runtime and this file only. It does not
contain `docs/`, `tools/`, `tests/`, `.reference/`, graphs, or maintainer
instructions.

1. Read the public API documentation for the installed framework version.
   Obtain the matching source/docs from the project repository or release page.
2. Use documented public methods and modules. Do not reach into underscore
   fields, private tables, or loader internals.
3. Obtain WoW reference data yourself when you need to verify a Blizzard API:
   - [Ketho/BlizzardInterfaceResources](https://github.com/Ketho/BlizzardInterfaceResources)
   - [Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source)
4. Record the client build, upstream ref, and commit. Confirm dump-derived
   conclusions against the shipped UI source. Never invent an API or assume a
   reference cache is current.

## Project Shape

```text
core/        runtime kernel: registry, events, timers, DB, compat, lifecycle
libraries/   reusable framework libraries (UI, fonts, media, timers, ...)
modules/     WoW-domain adapters (auras, combat, quest, housing, ...)
media/       framework branding assets only
contract/    schema, engines, vectors, API catalog
tools/       source-only CI, MCP, reference, release, and wiki tooling
tests/       source-only diagnostic fixtures
docs/        canonical documentation and history
```

`RGX-Framework.xml` is the runtime load order. `RGX-Framework.toc` owns version,
Interface values, and SavedVariables. A file under `libraries/` or `modules/`
is not active unless the XML manifest loads it.

## Runtime Architecture

One framework instance, shared by every RGX addon:

```lua
local addonName, RGX = ...
_G.RGXFramework = RGX
```

Consumers declare:

```toc
## RequiredDeps: RGX-Framework
```

Modules register through the framework:

```lua
RGX:RegisterModule("example", Example, {
    category = "library", -- or "game"
    global = "RGXExample",
})
```

Never add LibStub, embed RGX inside consumers, or add Ace3 as a framework
runtime dependency.

## Consumer API

Preferred front door:

```lua
local addon = RGXAddon("MyAddon", {
    db = { enabled = true },
    slash = "myaddon",
})
```

`local RGX = assert(_G.RGXFramework, ...)` is the advanced escape hatch, not the
normal authoring path.

Declarative rule: **bare forms assume; advanced forms unlock.** Do not create a
second simple API beside an advanced one. Extend the same key additively.

## Framework-First Rules

Use the framework's existing modules before writing new plumbing:

```lua
-- CORRECT
addon:RegisterEvent("PLAYER_LOGIN", handler)
addon:RegisterUnitEvent("UNIT_AURA", "player", handler)
addon:After(1, callback)
RGX:RegisterSlashCommand("foo", handler, "MYADDON")
RGX:SafeShow(frame)

-- WRONG in normal consumer/module code
local f = CreateFrame("Frame")
f:SetScript("OnEvent", handler)
C_Timer.After(1, callback)
SLASH_FOO1 = "/foo"
```

Also wrong: raw aura event/API plumbing, raw hook reassignment, unguarded
`SetAttribute`, and replacing framework mixins/modules with local copies.

All shared callback dispatch must stay failure-isolated. One consumer callback
must not break unrelated consumers.

## WoW Safety

- Respect combat lockdown, protected frames/attributes, taint, secret/restricted
  values, addon load order, and SavedVariables lifecycle.
- A caught Lua error does not undo taint. `pcall` is not taint safety.
- Verify APIs against the client Interface you are targeting. Do not guess a
  Blizzard signature or infer it from a branch name.
- Prefer secure hooks and framework wrappers over replacing Blizzard functions.
- Verify protected and restricted paths in the real client; headless mocks
  cannot prove taint safety or rendered behavior.

## Reference Data and Freshness

Reference data is development-only and never a runtime or release dependency.

- Primary discovery reference: Ketho client-state dumps (globals, events, enums,
  widget APIs, templates, mixins).
- Confirmation layer: Gethe shipped UI source (generated API docs, FrameXML,
  SharedXML).
- Record client build, upstream ref, and commit for every cited fact.
- In a source checkout, run `node tools/reference/check-freshness.mjs` before
  compatibility changes. If stale, sync the references and rebuild the graph.
- Reference caches, manifests, graphs, and gap reports are source-only. Never
  package them or mirror them publicly.

## Validation

Run the checks that match the change. From the repository root:

```bash
npm --prefix tools/ci ci
npm --prefix tools/ci run lua-check
npm --prefix tools/ci run lua-runtime-check
npm --prefix tools/ci run schema-check
npm --prefix tools/ci run flavor-check
npm --prefix tools/ci run package-check
npm --prefix tools/ci run docs-check
npm --prefix tools/ci run arch-check
```

Additional gates:

- Schema, declarative runtime, generator, validator, audit, or contract changes:
  run `contract-bundle-check` and the RGX-Hello MCP end-to-end test.
- Packaging or release changes: verify the runtime archive inventory, exclusions,
  flavor TOCs, release metadata, and public-mirror tree.
- Documentation-only changes: verify referenced files and commands, run
  `docs-check`, and inspect the diff. Do not fabricate runtime results.

Validation branches:

| Change | Required evidence |
|---|---|
| Docs/instructions | `docs-check`, link/path verification, diff check |
| Runtime/shared boundary | Lua syntax, full runtime harness, architecture, flavor, package |
| Declarative/schema/MCP | Runtime + schema + docs + contract bundle + RGX-Hello E2E |
| Database | Runtime harness plus reload persistence, migration, profile switching, visual restore |
| UI | Geometry, scroll, resize/show/hide, tab/page transitions, callback args, persisted visual state |
| Compatibility/safety | Flavor checks plus real-client combat/protected/taint/secret evidence |
| Packaging/release | Archive inventory, metadata, checksums, distribution verification |

A skipped, failed, or unavailable check is a blocker to that claim, not
permission to bypass it.

## Source Workflow

1. Inspect `git status`, branch, diff, remotes, stashes, and untracked files.
   Preserve concurrent work and never expose credentials.
2. Find the canonical GitLab issue/MR before changing scope. Search open and
   closed items; record acceptance criteria, dependencies, and manual gates.
3. Work on a task branch from the correct base. Make the smallest congruent
   change through existing owners and rails.
4. Update runtime, schema, docs, fixtures, and contract tooling together when
   the change crosses those layers.
5. Run the applicable gates at the exact candidate SHA. Inspect the final diff
   and `git diff --check`.
6. Commit/push only when requested. Use the canonical MR flow and attach
   evidence; do not claim unrun tests, live-client behavior, or deployment.
7. Leave the task open when required manual or external evidence remains.

GitLab is authoritative for development, issues, MRs, and CI. GitHub is the
downstream public distribution. Public GitHub tags are sanitized release trees;
their SHAs intentionally differ from the full-source GitLab tags.

## Package and Public Boundary

The player package contains runtime files plus `AGENTS.md`. It excludes:

- `docs/`, `contract/`, `tools/`, `tests/`, `skills/`
- `.reference/`, manifests, graphs, and reference caches
- internal CI, maintainer contracts, historical changelogs, and internal project docs
- consumer-specific names, internal issue links, and development-only material

The public mirror is generated from `tools/release/public-mirror.json`. Do not
copy internal-only files into the runtime package or add them to the public
allowlist without an explicit ownership and review decision.

## Completion Checklist

- Did I use the public API and existing framework owners?
- Did I keep the bug class unrepresentable rather than patching around it?
- Did I verify the Blizzard API and reference build/ref?
- Did I preserve taint, combat, protected-frame, secret-value, and flavor safety?
- Did I update runtime, schema/contract, docs, and tests together where needed?
- Did I run the applicable gates and inspect the final diff?
- Did I avoid claiming unrun tests, manual validation, or deployment?
- Did I keep internal references, consumer identities, and credentials out of
  the wrong surface?

Ask after every change:

> Did RGX become easier, safer, and more consistent to build with without
> becoming structurally worse to build on?
