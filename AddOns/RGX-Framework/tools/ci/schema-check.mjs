#!/usr/bin/env node
// CI schema gate: confirm the declarative addon schema is valid JSON and a
// compilable JSON Schema. rgx-mcp validates real addon opts against this file,
// so a malformed schema would silently break every validation downstream.
//
// Usage: node tools/ci/schema-check.mjs <path-to-schema.json>
// Use the same draft-2020-12 build and options rgx-mcp's server uses, so this
// gate compiles the schema exactly the way the real validator does.
import Ajv2020 from "ajv/dist/2020.js";
import { readFileSync } from "node:fs";

const path = process.argv[2];
if (!path) {
  console.error("Usage: node schema-check.mjs <path-to-schema.json>");
  process.exit(1);
}

let schema;
try {
  schema = JSON.parse(readFileSync(path, "utf8"));
} catch (e) {
  console.error(`INVALID JSON  ${path}  ->  ${e.message}`);
  process.exit(1);
}

try {
  const ajv = new Ajv2020({ allErrors: true, strict: false });
  ajv.compile(schema);
  console.log(`SCHEMA OK  ${path}  ($id: ${schema.$id || "none"})`);
} catch (e) {
  console.error(`SCHEMA ERROR  ${path}  ->  ${e.message}`);
  process.exit(1);
}
