# CLAUDE.md — tools/rgx-mcp

Agent guidance for this tool. **Read the repo root `CLAUDE.md` first — it is the driving document.**

## What this is

The MCP developer tool for RGX-Framework (framework roadmap **Tier 5 #15**). It validates, audits, and generates declarative RGX addons against the frozen **Simplicity Contract** (`docs/DECLARATIVE-DSL.md`, `dsl` branch) and its machine form (`schemas/rgx-addon.schema.json`). It ships **inside the framework repo** under `tools/` so anyone with the checkout has it, but is excluded from the packaged addon zip via `.pkgmeta` — players never download it.

## Hard rules

- **Read-only first.** Tools inspect and generate text; they never write to repos, never commit, never call the game. Write-capable tools require an explicit roadmap decision.
- **Dependency direction is one-way.** The tool reads the framework's schema/docs at runtime (repo root by default; `RGX_FRAMEWORK_PATH` to override). Never duplicate the schema into `tools/` (one source of truth), and the addon runtime (`core/`, `modules/`, XML, TOC) must never reference `tools/`.
- **Congruence over invention.** Every tool behavior derives from the contract/schema. A new detector or generator feature must correspond to a rule the framework actually enforces. If the contract doesn't cover it, change the contract first (on the framework's `dsl` branch), then the tool.
- **Generated code uses shipped keys only** (`x-rgx-ships: "today"`), in `RGXAddon "Name" { }` form. Never generate tier4 syntax as if it runs.

## Structure

```
src/server.js   — the whole server (McpServer over stdio): 4 tools, 2 resources
package.json    — deps: @modelcontextprotocol/sdk, ajv (2020-12), zod
```

## Conventions

- Plain Node ESM, no build step, no TypeScript — the simplicity ethos applies to the tooling too.
- Detectors are deterministic regex over Lua lines (comments skipped); each carries actionable `advice` naming the RGX replacement.
- Keep the audit detector list in sync with the framework's "make the bug unrepresentable" thesis (raw C_Timer, manual OnEvent frames, SLASH_ globals, unguarded SetAttribute, secret-aura comparisons, raw hook reassignment).
