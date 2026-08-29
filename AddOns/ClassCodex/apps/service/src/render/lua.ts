// Serialize a JSON value to a deterministic Lua table literal. Leaf tables/arrays
// that fit on one line stay inline (compact); larger nested maps break to lines.
// Object keys are sorted so unchanged data produces byte-identical output; arrays
// keep order. (Ported from the scraper's normalize/to-lua.ts — the service owns
// its own copy so the scraper can be retired.)

type Json = string | number | boolean | null | Json[] | { [k: string]: Json };

const MAX_INLINE = 120; // a table/array shorter than this stays on one line

/** Escape a string for embedding inside a Lua double-quoted literal. */
export function esc(s: string): string {
  return s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n").replace(/\r/g, "\\r");
}

function keyLiteral(k: string): string {
  if (/^\d+$/.test(k)) return `[${k}]`; // numeric key (itemId / encounter id)
  return /^[A-Za-z_]\w*$/.test(k) ? k : `["${esc(k)}"]`;
}

function scalar(value: Json): string | null {
  if (value === null) return "nil";
  if (typeof value === "string") return `"${esc(value)}"`;
  if (typeof value === "number" || typeof value === "boolean") return String(value);
  return null;
}

// One-line form, no newlines — used to decide whether a table fits inline.
function inlineForm(value: Json): string {
  const s = scalar(value);
  if (s !== null) return s;
  if (Array.isArray(value)) {
    return value.length === 0 ? "{}" : `{ ${value.map(inlineForm).join(", ")} }`;
  }
  const obj = value as { [k: string]: Json };
  const keys = Object.keys(obj).sort();
  return keys.length === 0 ? "{}" : `{ ${keys.map((k) => `${keyLiteral(k)} = ${inlineForm(obj[k])}`).join(", ")} }`;
}

export function toLua(value: Json, indent = 0): string {
  const s = scalar(value);
  if (s !== null) return s;
  const inline = inlineForm(value);
  if (inline.length <= MAX_INLINE) return inline;

  const pad = "  ".repeat(indent);
  const pad1 = "  ".repeat(indent + 1);
  if (Array.isArray(value)) {
    return `{\n${value.map((v) => `${pad1}${toLua(v, indent + 1)},`).join("\n")}\n${pad}}`;
  }
  const obj = value as { [k: string]: Json };
  const keys = Object.keys(obj).sort();
  const body = keys.map((k) => `${pad1}${keyLiteral(k)} = ${toLua(obj[k], indent + 1)},`).join("\n");
  return `{\n${body}\n${pad}}`;
}

/** `ClassCodexSource["ugg"] = { … }` — the addon-injectable form. */
export function sourceFileToLua(source: string, file: unknown): string {
  return `ClassCodexSource = ClassCodexSource or {}\nClassCodexSource["${esc(source)}"] = ${toLua(file as Json)}\n`;
}

/** Deterministic JSON: object keys sorted recursively so unchanged data is byte-identical. */
export function sortedJson(value: unknown): string {
  return JSON.stringify(
    value,
    (_k, v) =>
      v && typeof v === "object" && !Array.isArray(v)
        ? Object.fromEntries(Object.keys(v).sort().map((k) => [k, (v as Record<string, unknown>)[k]]))
        : v,
    2,
  );
}
