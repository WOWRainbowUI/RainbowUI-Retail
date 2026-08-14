# rgx-mcp

MCP server for [RGX-Framework](https://github.com/DonnieDice/RGX-Framework) addon development. Lets AI agents (Claude Code, etc.) validate, audit, and generate declarative RGX addons against the framework's frozen **Simplicity Contract**.

**Read-only by design.** This tool inspects and generates — it never edits repos, never commits, never touches the game.

## Dependency direction (hard rule)

```
rgx-mcp            depends on →  RGX-Framework docs + schema (read at runtime)
consumer addons    depend on  →  RGX-Framework
RGX-Framework      depends on →  nothing (and never on rgx-mcp)
```

This tool lives at `tools/rgx-mcp/` **inside the framework repo** and ships inside the packaged addon zip too (since v2.4.0) — anyone who installs RGX-Framework and wants to build their own addon on it already has the MCP server on hand, no separate download. The schema and API reference are read live from the enclosing checkout (one source of truth); set `RGX_FRAMEWORK_PATH` only when running against a different framework tree.

## Tools

| Tool | What it does |
|---|---|
| `rgx_validate_addon` | Validate an RGXAddon opts table (JSON; Lua functions as `{"$lua":"function"}`) against `schemas/rgx-addon.schema.json`; flags contract-frozen `tier4` keys that don't run yet |
| `rgx_audit_lua` | Scan a `.lua` file or addon directory for the unsafe patterns the framework prevents: raw `C_Timer`, manual `OnEvent` frames, `SLASH_` globals, unguarded `SetAttribute`, secret-aura field comparisons, raw hook reassignment. Deterministic |
| `rgx_generate_addon` | Emit a complete contract-congruent addon file using only shipped keys (`RGXAddon "Name" { ... }`) |
| `rgx_get_contract` | Return the schema + shipped-surface reference for agent context |

## Resources

- `rgx://schemas/addon` — the annotated JSON Schema
- `rgx://docs/declarative-api` — the shipped declarative surface reference

## Setup

```bash
npm install
```

Claude Code (`.mcp.json` or `claude mcp add`):

```json
{
  "mcpServers": {
    "rgx": {
      "command": "node",
      "args": ["tools/rgx-mcp/src/server.js"]
    }
  }
}
```

The framework repo ships this in `.mcp.json` already — Claude Code sessions in the repo get the `rgx_*` tools automatically after `npm install` in `tools/rgx-mcp/`.

## Testing

`test/test-rgx-hello.mjs` drives the real server over the real MCP client SDK (stdio transport, no protocol reimplementation) and points it at the actual [RGX-Hello](https://github.com/DonnieDice/RGX-Hello) reference addon: generates a spec matching it, validates its real opts table, and audits its real Lua. This is how the `suffix` schema gap (sliders silently dropped it) and the generator's `dbName` blind spot on hyphenated names were both found and fixed.

```bash
node test/test-rgx-hello.mjs /path/to/RGX-Hello
```

## Status

v0.1.0 — Tier 5 #15 of the framework roadmap. Verified over live stdio JSON-RPC: initialize handshake, `tools/list`, and all three tools exercised end-to-end against a real shipped addon (see Testing above). The audit detectors mirror the manual audits performed on the framework, BLU, and BPU.

## License

MIT
