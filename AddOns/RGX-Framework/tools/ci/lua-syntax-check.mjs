#!/usr/bin/env node
// CI Lua syntax gate: parse every .lua file in the repo with luaparse so a
// syntax error can never reach a tag/release. Walks from the repo root, skips
// node_modules/.git, and exits non-zero listing every file that fails.
//
// Usage: node tools/ci/lua-syntax-check.mjs [rootDir]
import luaparse from "luaparse";
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative } from "node:path";

const root = process.argv[2] || join(process.cwd());
const SKIP = new Set(["node_modules", ".git", ".github"]);

function walk(dir, out = []) {
  for (const entry of readdirSync(dir)) {
    if (SKIP.has(entry)) continue;
    const full = join(dir, entry);
    const st = statSync(full);
    if (st.isDirectory()) walk(full, out);
    else if (entry.endsWith(".lua")) out.push(full);
  }
  return out;
}

const files = walk(root);
let failed = 0;
for (const f of files) {
  try {
    // Lua 5.1 is WoW's runtime dialect; parse against it.
    luaparse.parse(readFileSync(f, "utf8"), { luaVersion: "5.1" });
  } catch (e) {
    failed++;
    console.error(`SYNTAX ERROR  ${relative(root, f)}  ->  ${e.message}`);
  }
}

console.log(`Checked ${files.length} Lua file(s), ${failed} with errors.`);
process.exit(failed ? 1 : 0);
