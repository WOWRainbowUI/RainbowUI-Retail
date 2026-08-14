#!/usr/bin/env node
// Regenerate the GitHub wiki from docs/ per tools/wiki/manifest.json. docs/ is
// canonical; this emits a flat set of wiki pages (Title-Case names from the
// manifest), a generated _Sidebar, and Home. Cross-page links written as
// [text](SOMEDOC.md) are rewritten to their wiki page names so navigation keeps
// working. Run locally to preview, or by .github/workflows/wiki-sync.yml.
//
// Usage: node tools/wiki/build-wiki.mjs <outDir>
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = join(HERE, "..", "..");
const DOCS = join(REPO, "docs");
const manifest = JSON.parse(readFileSync(join(HERE, "manifest.json"), "utf8"));

const outDir = process.argv[2];
if (!outDir) {
  console.error("Usage: node build-wiki.mjs <outDir>");
  process.exit(1);
}
mkdirSync(outDir, { recursive: true });

// docs filename -> wiki page name, used to rewrite cross-page markdown links.
const docToWiki = {};
for (const s of manifest.sections) for (const p of s.pages) docToWiki[p.doc] = p.wiki;

function rewriteLinks(md) {
  // [text](SOMEDOC.md) / [text](SOMEDOC.md#anchor) -> [text](Wiki-Name#anchor)
  return md.replace(/\]\(([A-Za-z0-9._-]+\.md)(#[^)]*)?\)/g, (m, file, anchor) => {
    const wiki = docToWiki[file];
    return wiki ? `](${wiki}${anchor || ""})` : m;
  });
}

const missing = [];
function emit(docFile, wikiName) {
  const src = join(DOCS, docFile);
  if (!existsSync(src)) {
    missing.push(docFile);
    return;
  }
  const body = rewriteLinks(readFileSync(src, "utf8").replace(/\r\n/g, "\n"));
  writeFileSync(join(outDir, `${wikiName}.md`), body);
}

if (manifest.home) emit(manifest.home, "Home");
for (const s of manifest.sections) for (const p of s.pages) emit(p.doc, p.wiki);

// _Sidebar generated from the manifest section structure.
const sidebar = ["## RGX-Framework", "", "[Home](Home)", ""];
for (const s of manifest.sections) {
  sidebar.push(`### ${s.title}`);
  for (const p of s.pages) sidebar.push(`- [[${p.wiki}]]`);
  sidebar.push("");
}
writeFileSync(join(outDir, "_Sidebar.md"), sidebar.join("\n"));

if (missing.length) {
  console.error("MISSING docs referenced by manifest:\n  " + missing.join("\n  "));
  process.exit(1);
}

const count =
  manifest.sections.reduce((n, s) => n + s.pages.length, 0) + (manifest.home ? 1 : 0) + 1;
console.log(`Generated ${count} wiki page(s) into ${outDir}`);
