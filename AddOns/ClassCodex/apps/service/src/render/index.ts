// Render a validated SourceFile into the two shapes consumers ask for over HTTP:
// canonical JSON (byte-stable, key-sorted) and addon-injectable Lua
// (`ClassCodexSource["<source>"] = {…}`). Both derive from the same parsed file,
// so they can never drift.
import type { SourceFile } from "../schema/index.js";
import { sortedJson, sourceFileToLua } from "./lua.js";

export interface Rendered {
  json: string; // canonical JSON string
  lua: string; // ClassCodexSource["<source>"] = {…}
}

export function render(file: SourceFile): Rendered {
  const json = sortedJson(file);
  return { json: json + "\n", lua: sourceFileToLua(file.meta.source, JSON.parse(json)) };
}
