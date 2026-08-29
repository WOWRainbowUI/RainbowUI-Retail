// The identity of a source's data: a sha256 over its canonical (key-sorted) JSON.
// It depends ONLY on the data, so identical data always hashes identically — which
// is what makes the rendered output byte-stable across rebuilds. This replaces a
// wall-clock `generatedAt`, which changed on every request and churned the
// committed files (a no-op git diff) even when nothing upstream had moved.
import { createHash } from "node:crypto";
import { sortedJson } from "./lua.js";

// 16 hex chars (64 bits) — ample to detect a change, short enough to eyeball in
// a diff. Consumers treat it as opaque: it changed ⇒ the data changed.
export function contentHash(data: unknown): string {
  return createHash("sha256").update(sortedJson(data)).digest("hex").slice(0, 16);
}
