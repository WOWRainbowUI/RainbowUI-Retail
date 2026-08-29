// Rotation, Cooldowns, and Abilities page → ordered priority steps. A step embeds
// spell links as {spellId} markers (the addon renders them as spell name + icon).
// IV layouts vary (ST/AoE split, or one generic list), so we bind each classifiable
// heading to the first spell-bearing list before the next classifiable heading.
import type { Rotation } from "../types.js";

function classifyHeading(text: string): string | null {
  const t = text.toLowerCase();
  if (/opener|tier set|explained|cooldown|mechanic|talent|gear|stat|consumable|macro|weakaura|addon/.test(t)) return null;
  if (/single[-\s]?target/.test(t)) return "Single Target";
  if (/multi[-\s]?target|aoe|cleave/.test(t)) return "AoE";
  if (/rotation|priority/.test(t)) return "Rotation";
  return null;
}

function toStepText(liHtml: string): string {
  // Match spell links even when they carry extra params (spell=123&bonus=…), the
  // same lenient form firstSpellListIn uses to *detect* the list — otherwise a
  // detected list would yield zero markers and the whole step be dropped.
  const withMarkers = liHtml.replace(
    /<span\b[^>]*\bdata-wowhead="spell=(\d+)[^>]*>([\s\S]*?)<\/span>/gi,
    (_m, id) => `{${Number(id)}}`,
  );
  return withMarkers
    .replace(/<[^>]+>/g, "")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&#39;|&rsquo;/g, "'")
    .replace(/\s+/g, " ")
    .trim();
}

function listBodyAt(html: string, start: number): string {
  const tag = html.slice(start).match(/<(ol|ul)\b/i)?.[1]?.toLowerCase();
  if (!tag) return "";
  const re = new RegExp(`<(/?)${tag}\\b`, "gi");
  re.lastIndex = start;
  let depth = 0;
  let m: RegExpExecArray | null;
  while ((m = re.exec(html))) {
    if (m[1] === "/") {
      if (--depth === 0) return html.slice(start, m.index);
    } else depth++;
  }
  return html.slice(start, start + 8000);
}

function stepsFromBody(body: string): string[] {
  const steps: string[] = [];
  for (const li of body.matchAll(/<li\b[^>]*>([\s\S]*?)<\/li>/gi)) {
    const text = toStepText(li[1]);
    if (text && /\{\d+\}/.test(text)) steps.push(text);
  }
  return steps;
}

function firstSpellListIn(html: string, from: number, to: number): string | null {
  const re = /<(ol|ul)\b/gi;
  re.lastIndex = from;
  let m: RegExpExecArray | null;
  while ((m = re.exec(html)) && m.index < to) {
    const body = listBodyAt(html, m.index);
    if (/data-wowhead="spell=/i.test(body)) return body;
  }
  return null;
}

interface Heading {
  pos: number;
  level: number;
  text: string;
  ctx: string | null;
}

// A short heading that *is* a rotation/priority section, vs. a long guide title
// that merely contains the word ("Blood Death Knight Gameplay and Rotation Guide").
function isDedicatedRotation(text: string): boolean {
  return /^(rotation|priority|standard rotation|single[-\s]?target|aoe|multi[-\s]?target|cleave)\b/i.test(text.trim());
}

export function parseIcyVeinsRotation(html: string): Rotation[] {
  const headings: Heading[] = [...html.matchAll(/<(h[234])[^>]*>([\s\S]*?)<\/\1>/gi)].map((m) => {
    const text = m[2].replace(/<[^>]+>/g, "");
    return { pos: m.index ?? 0, level: Number(m[1][1]), text, ctx: classifyHeading(text) };
  });
  const classifiable = headings.filter((h): h is Heading & { ctx: string } => h.ctx !== null);

  const endAt = (i: number) => classifiable[i + 1]?.pos ?? html.length;
  const seen = new Set<string>();
  const out: Rotation[] = [];

  // Pass 1 — explicit Single/Multi-Target sections.
  for (let i = 0; i < classifiable.length; i++) {
    const h = classifiable[i];
    if (h.ctx === "Rotation" || seen.has(h.ctx)) continue;
    const body = firstSpellListIn(html, h.pos, endAt(i));
    if (!body) continue;
    const steps = stepsFromBody(body);
    if (steps.length > 0) {
      out.push({ context: h.ctx, steps });
      seen.add(h.ctx);
    }
  }

  // Pass 2 — generic "Rotation" only when there was no ST/AoE split. Some layouts
  // (e.g. Blood DK) carry both an h2 guide title AND a dedicated h3 "Rotation"
  // whose list is the real priority; prefer the dedicated, deeper heading and bound
  // its list search to that subsection (next same-or-higher heading), so we don't
  // grab the one-line intro under the guide title.
  if (out.length === 0) {
    const candidates = classifiable
      .filter((h) => h.ctx === "Rotation")
      .sort(
        (a, b) =>
          Number(isDedicatedRotation(b.text)) - Number(isDedicatedRotation(a.text)) ||
          b.level - a.level ||
          a.pos - b.pos,
      );
    for (const h of candidates) {
      const end = headings.find((y) => y.pos > h.pos && y.level <= h.level)?.pos ?? html.length;
      const body = firstSpellListIn(html, h.pos, end);
      const steps = body ? stepsFromBody(body) : [];
      if (steps.length > 0) {
        out.push({ context: "Rotation", steps });
        break;
      }
    }

    // Fallback to the original unbounded scan (first Rotation heading → first spell
    // list) so the dedicated-heading heuristic can only ever add coverage, never
    // remove it — e.g. layouts where the real list sits outside the bounded section.
    if (out.length === 0) {
      const idx = classifiable.findIndex((h) => h.ctx === "Rotation");
      if (idx >= 0) {
        const body = firstSpellListIn(html, classifiable[idx].pos, endAt(idx));
        const steps = body ? stepsFromBody(body) : [];
        if (steps.length > 0) out.push({ context: "Rotation", steps });
      }
    }
  }
  return out;
}
