#!/usr/bin/env node
// rgx-mcp end-to-end test: use the real MCP server (over the real MCP
// client SDK, real stdio transport -- no reimplementation of the protocol)
// to generate, validate, and audit the actual RGX-Hello reference addon.
//
// This is the concrete answer to "does rgx-mcp actually work": rather than
// synthetic fixtures, it's pointed at a real shipped addon and has to
// produce a correct verdict about it.
//
// Usage: node test/test-rgx-hello.mjs <path-to-RGX-Hello-checkout>

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const SERVER_ENTRY = join(HERE, "..", "src", "server.js");

const helloPath = process.argv[2];
if (!helloPath) {
  console.error("Usage: node test/test-rgx-hello.mjs <path-to-RGX-Hello-checkout>");
  process.exit(1);
}

// RGX-Hello's actual data/core.lua, transcribed to the opts-as-JSON shape
// rgx_validate_addon's own doc comment prescribes (Lua functions become
// {"$lua": "..."}). Keep this in sync by hand with data/core.lua -- there
// is no Lua-to-JSON opts extractor.
const RGX_HELLO_OPTS = {
  dbName: "RGXHelloDB",
  slash: "rgxhello",
  minimap: "Interface\\AddOns\\RGX-Hello\\media\\icon.tga",
  db: { enabled: true, volume: 50 },
  options: {
    General: [
      { toggle: "enabled", label: "Enable Addon" },
      { slider: "volume", label: "Volume", min: 0, max: 100, suffix: "%" },
    ],
  },
  welcome: "loaded -- /rgxhello for options",
  // rgx_validate_addon's doc string: "Lua functions as {\"$lua\":\"function\"}"
  // -- $lua is a fixed sentinel marking "opaque function here", not the
  // actual source (the schema can't validate Lua source as JSON anyway).
  onInit: { $lua: "function" },
};

const RGX_HELLO_GENERATE_SPEC = {
  name: "RGX-Hello",
  dbName: "RGXHelloDB",
  slash: "rgxhello",
  minimap: true,
  db: { enabled: true, volume: 50 },
  toggles: ["enabled"],
  sliders: [{ key: "volume", label: "Volume", min: 0, max: 100, suffix: "%" }],
};

let failures = 0;
function check(label, cond, detail) {
  if (cond) {
    console.log(`  PASS  ${label}`);
  } else {
    failures++;
    console.log(`  FAIL  ${label}${detail ? " -- " + detail : ""}`);
  }
}

const transport = new StdioClientTransport({
  command: process.execPath,
  args: [SERVER_ENTRY],
});
const client = new Client({ name: "rgx-mcp-hello-test", version: "0.1.0" }, { capabilities: {} });
await client.connect(transport);

try {
  console.log("== rgx_generate_addon (RGX-Hello spec) ==");
  const gen = await client.callTool({ name: "rgx_generate_addon", arguments: RGX_HELLO_GENERATE_SPEC });
  const generatedLua = gen.content?.[0]?.text ?? "";
  console.log(generatedLua);
  check("generator produced a RGXAddon call", generatedLua.includes('RGXAddon "RGX-Hello"'));
  check(
    "generator's SavedVariables hint matches what RGX-Hello actually ships (RGXHelloDB, no hyphen)",
    generatedLua.includes("RGXHelloDB") && !generatedLua.includes("RGX-HelloDB")
  );
  check("generator emits the slider's % suffix", generatedLua.includes('suffix = "%"'));

  console.log("\n== rgx_validate_addon (RGX-Hello's real opts) ==");
  const val = await client.callTool({ name: "rgx_validate_addon", arguments: { opts: RGX_HELLO_OPTS } });
  const report = JSON.parse(val.content[0].text);
  console.log(JSON.stringify(report, null, 2));
  check("RGX-Hello's opts validate against the shipped schema", report.valid === true, JSON.stringify(report.errors));
  check("no tier4-only keys used", (report.tier4KeysUsed ?? []).length === 0, JSON.stringify(report.tier4KeysUsed));

  console.log("\n== rgx_audit_lua (RGX-Hello's actual Lua files) ==");
  const audit = await client.callTool({ name: "rgx_audit_lua", arguments: { path: helloPath } });
  const auditReport = JSON.parse(audit.content[0].text);
  console.log(JSON.stringify(auditReport, null, 2));
  check("RGX-Hello's Lua is clean of unsafe patterns", auditReport.clean === true, JSON.stringify(auditReport.findings));
} finally {
  await client.close();
}

console.log(`\n${failures === 0 ? "ALL CHECKS PASSED" : failures + " CHECK(S) FAILED"}`);
process.exit(failures === 0 ? 0 : 1);
