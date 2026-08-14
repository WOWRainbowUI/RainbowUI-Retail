#!/usr/bin/env node
// rgx-mcp — MCP server for RGX-Framework addon development.
//
// Read-only by design (Tier 5 of the framework roadmap): validates declarative
// addon tables against the shipped JSON schema, audits Lua source for the
// unsafe patterns the framework exists to prevent, generates contract-congruent
// addon skeletons, and serves the Simplicity Contract as context.
//
// Lives in the framework repo at tools/rgx-mcp/ (excluded from the packaged
// addon zip) so anyone with the framework checkout has the tool. Dependency
// direction (hard rule): the tool reads the framework's docs/schema; the
// addon runtime never references tools/. Override the framework root with
// RGX_FRAMEWORK_PATH if running from elsewhere (default: this checkout).

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import Ajv2020 from "ajv/dist/2020.js";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, resolve, relative } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = fileURLToPath(new URL(".", import.meta.url));
// tools/rgx-mcp/src/ -> the framework repo root is three levels up
const FRAMEWORK = resolve(
  process.env.RGX_FRAMEWORK_PATH ?? join(HERE, "..", "..", "..")
);

function frameworkFile(rel) {
  return readFileSync(join(FRAMEWORK, rel), "utf8");
}

// ── Schema (loaded from the framework checkout — single source of truth) ─────

let schemaCache = null;
function getSchema() {
  if (!schemaCache) {
    schemaCache = JSON.parse(frameworkFile("schemas/rgx-addon.schema.json"));
  }
  return schemaCache;
}

let validatorCache = null;
function getValidator() {
  if (!validatorCache) {
    const ajv = new Ajv2020({ allErrors: true, strict: false });
    validatorCache = ajv.compile(getSchema());
  }
  return validatorCache;
}

// ── Lua audit detectors (deterministic, mirror the framework audits) ─────────

const DETECTORS = [
  {
    id: "raw_c_timer",
    pattern: /C_Timer\.(After|NewTimer|NewTicker)\s*\(/,
    advice:
      "Use RGX:After / RGX:Every instead of raw C_Timer — framework timers are budgeted and diagnosable. (Inside RGX-Framework itself, a guarded `elseif C_Timer` fallback after RGX:After is the one allowed exception.)",
  },
  {
    id: "manual_event_frame",
    pattern: /SetScript\s*\(\s*["']OnEvent["']/,
    advice:
      "Do not hand-roll event frames. Register through RGX:RegisterEvent / RGX:RegisterUnitEvent — dispatch is pcall-wrapped and frame registration is combat-lockdown safe.",
  },
  {
    id: "raw_slash_global",
    pattern: /(^|\s)SLASH_[A-Z0-9_]+\d+\s*=|_G\[\s*["']SLASH_/,
    advice:
      "Use RGX:RegisterSlashCommand (or the `slash` key of RGXAddon) instead of writing SLASH_ globals.",
  },
  {
    id: "setattribute_combat_risk",
    pattern: /:SetAttribute\s*\(/,
    advice:
      "SetAttribute on secure frames taints during combat lockdown, and pcall does NOT prevent taint. Guard with InCombatLockdown() and defer to PLAYER_REGEN_ENABLED (see BPU's SafeSetButtonAttribute pattern).",
  },
  {
    id: "secret_aura_field_risk",
    pattern: /UnitAura\s*\(|GetAuraDataByIndex[\s\S]{0,120}?\.spellId\s*==/,
    advice:
      "Midnight secret auras: comparing aura fields on restricted units taints. Use RGXAuras (HasPlayerAura/GetAura keep comparisons behind an internal pcall boundary).",
  },
  {
    id: "raw_hook_reassignment",
    pattern: /_G\.[A-Za-z_]+\s*=\s*function|_G\[["'][A-Za-z_]+["']\]\s*=\s*function/,
    advice:
      "Reassigning a global function is a raw hook and can taint secure paths. Use hooksecurefunc via RGX:Hook for post-hooks.",
  },
];

function auditLuaSource(source, file) {
  const findings = [];
  const lines = source.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (/^\s*--/.test(line)) continue; // skip comments
    for (const d of DETECTORS) {
      if (d.pattern.test(line)) {
        findings.push({
          file,
          line: i + 1,
          detector: d.id,
          excerpt: line.trim().slice(0, 160),
          advice: d.advice,
        });
      }
    }
  }
  return findings;
}

function* walkLuaFiles(root) {
  const skip = new Set([".git", "graphify-out", "node_modules", "docs"]);
  const stack = [root];
  while (stack.length) {
    const dir = stack.pop();
    for (const name of readdirSync(dir)) {
      if (skip.has(name)) continue;
      const p = join(dir, name);
      const st = statSync(p);
      if (st.isDirectory()) stack.push(p);
      else if (name.endsWith(".lua")) yield p;
    }
  }
}

// ── Addon generation (shipped keys only — contract-congruent) ────────────────

function luaQuote(s) {
  return '"' + String(s).replace(/\\/g, "\\\\").replace(/"/g, '\\"') + '"';
}

// A hyphen (or other non-identifier character) in the addon name is valid
// in the name itself but would produce an odd SavedVariables global if
// concatenated as-is (e.g. "RGX-Hello" -> "RGX-HelloDB"). Strip anything
// that isn't a safe Lua identifier character for the auto-derived default,
// matching the precedent set by RGX-Hello's own hand-written core.lua
// (dbName = "RGXHelloDB").
function defaultDbName(name) {
  return name.replace(/[^A-Za-z0-9_]/g, "") + "DB";
}

function generateAddonLua(spec) {
  const name = spec.name;
  const dbName = spec.dbName || defaultDbName(name);
  const needsExplicitDbName = Boolean(spec.dbName) || /[^A-Za-z0-9_]/.test(name);
  const out = [];
  out.push(`-- ${name}.lua — generated by rgx-mcp against the RGX Simplicity Contract`);
  out.push(`-- TOC needs: ## RequiredDeps: RGX-Framework` +
    (spec.db ? `  and  ## SavedVariables: ${dbName}` : ""));
  out.push(`RGXAddon ${luaQuote(name)} {`);
  if (needsExplicitDbName && spec.db) out.push(`    dbName  = ${luaQuote(dbName)},`);
  out.push(`    slash   = ${luaQuote(spec.slash ?? name.toLowerCase())},`);
  if (spec.minimap) out.push(`    minimap = true,`);
  if (spec.db) {
    const entries = Object.entries(spec.db)
      .map(([k, v]) => `${k} = ${typeof v === "string" ? luaQuote(v) : v}`)
      .join(", ");
    out.push(`    db      = { ${entries} },`);
  }
  const controls = [];
  for (const t of spec.toggles ?? []) {
    controls.push(`            { toggle = ${luaQuote(t)} },`);
  }
  for (const s of spec.sliders ?? []) {
    const parts = [`slider = ${luaQuote(s.key)}`];
    if (s.label) parts.push(`label = ${luaQuote(s.label)}`);
    parts.push(`min = ${s.min ?? 0}`, `max = ${s.max ?? 100}`);
    if (s.suffix) parts.push(`suffix = ${luaQuote(s.suffix)}`);
    controls.push(`            { ${parts.join(", ")} },`);
  }
  if (controls.length) {
    out.push(`    options = {`);
    out.push(`        General = {`);
    out.push(...controls);
    out.push(`        },`);
    out.push(`    },`);
  }
  out.push(`    welcome = ${luaQuote(`loaded — /${spec.slash ?? name.toLowerCase()} for options`)},`);
  out.push(`}`);
  return out.join("\n");
}

// ── Server ────────────────────────────────────────────────────────────────────

const server = new McpServer({ name: "rgx-mcp", version: "0.1.0" });

server.tool(
  "rgx_validate_addon",
  "Validate a declarative RGXAddon opts table (as JSON; Lua functions as {\"$lua\":\"function\"}) against the framework's shipped schema. Reports schema errors and flags tier4-only keys.",
  { opts: z.record(z.any()).describe("The RGXAddon opts table as JSON") },
  async ({ opts }) => {
    const validate = getValidator();
    const valid = validate(opts);
    const tier4Used = ["on", "every"].filter((k) => k in opts);
    if (opts.options && typeof opts.options === "object" && "columns" in opts.options) {
      tier4Used.push("options.columns");
    }
    const report = {
      valid,
      errors: validate.errors ?? [],
      tier4KeysUsed: tier4Used,
      note: tier4Used.length
        ? "tier4 keys are contract-frozen but NOT implemented yet — they validate but will not run on the current framework."
        : undefined,
    };
    return { content: [{ type: "text", text: JSON.stringify(report, null, 2) }] };
  }
);

server.tool(
  "rgx_audit_lua",
  "Audit a Lua file or directory for the unsafe WoW patterns RGX-Framework exists to prevent (raw C_Timer, manual event frames, SLASH_ globals, unguarded SetAttribute, secret-aura comparisons, raw hook reassignment). Deterministic; read-only.",
  { path: z.string().describe("Absolute path to a .lua file or an addon directory") },
  async ({ path }) => {
    const st = statSync(path);
    const findings = [];
    if (st.isDirectory()) {
      for (const f of walkLuaFiles(path)) {
        findings.push(...auditLuaSource(readFileSync(f, "utf8"), relative(path, f)));
      }
    } else {
      findings.push(...auditLuaSource(readFileSync(path, "utf8"), path));
    }
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(
            { findings, total: findings.length, clean: findings.length === 0 },
            null,
            2
          ),
        },
      ],
    };
  }
);

server.tool(
  "rgx_generate_addon",
  "Generate a complete, contract-congruent RGX addon Lua file using ONLY shipped keys (RGXAddon curried form, table-form controls).",
  {
    name: z.string().describe("Addon name, e.g. MyAddon"),
    dbName: z.string().optional()
      .describe("SavedVariables global override. Defaults to `${name}DB` with non-identifier characters stripped (e.g. \"RGX-Hello\" -> \"RGXHelloDB\") -- only pass this to use something else."),
    slash: z.string().optional().describe("Slash command (default: lowercase name)"),
    minimap: z.boolean().optional(),
    db: z.record(z.union([z.string(), z.number(), z.boolean()])).optional()
      .describe("Saved-setting defaults"),
    toggles: z.array(z.string()).optional().describe("db keys to expose as toggles"),
    sliders: z
      .array(z.object({
        key: z.string(),
        label: z.string().optional(),
        min: z.number().optional(),
        max: z.number().optional(),
        suffix: z.string().optional().describe('Appended to the displayed value, e.g. "%"'),
      }))
      .optional(),
  },
  async (spec) => ({
    content: [{ type: "text", text: generateAddonLua(spec) }],
  })
);

server.tool(
  "rgx_get_contract",
  "Return the Simplicity Contract source of truth: the JSON schema plus the shipped-surface reference (DECLARATIVE-API.md).",
  {},
  async () => ({
    content: [
      { type: "text", text: "== schemas/rgx-addon.schema.json ==\n" + JSON.stringify(getSchema(), null, 2) },
      { type: "text", text: "== docs/DECLARATIVE-API.md ==\n" + frameworkFile("docs/DECLARATIVE-API.md") },
    ],
  })
);

server.resource(
  "rgx-schema",
  "rgx://schemas/addon",
  { description: "RGXAddon opts JSON Schema (x-rgx-ships annotated)", mimeType: "application/json" },
  async () => ({
    contents: [
      { uri: "rgx://schemas/addon", mimeType: "application/json", text: JSON.stringify(getSchema(), null, 2) },
    ],
  })
);

server.resource(
  "rgx-declarative-api",
  "rgx://docs/declarative-api",
  { description: "Shipped declarative surface reference", mimeType: "text/markdown" },
  async () => ({
    contents: [
      { uri: "rgx://docs/declarative-api", mimeType: "text/markdown", text: frameworkFile("docs/DECLARATIVE-API.md") },
    ],
  })
);

const transport = new StdioServerTransport();
await server.connect(transport);
