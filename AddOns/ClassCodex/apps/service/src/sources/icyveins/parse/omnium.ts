// Omnium Folio rune recommendations. The spec-builds-talents page carries an
// <h2 id="omnium">Omnium Folio</h2> section with a week-by-week progression list:
//
//   <ul>
//     <li>Week 1: <span data-wowhead="spell=NNN">Rune of …</span></li>
//     <li>Week 2: <span …>Rune of …</span> for group play, or <span …>Rune of …</span> for solo play</li>
//     …
//   </ul>
//
// Each <li> leads with a progression label (used for every rune in that <li>);
// each rune link becomes a rec, with any trailing text ("for solo play") as note.
import { load } from "cheerio";
import type { Cheerio, CheerioAPI } from "cheerio";
import type { OmniumRune } from "../types.js";

function cleanLabel(s: string): string {
  return s.replace(/\s+/g, " ").replace(/[:\-–]\s*$/, "").trim();
}

function cleanNote(s: string): string {
  return s
    .replace(/\s+/g, " ")
    .replace(/^[\s,]*(?:or\b)?\s*(?:for\b)?\s*/i, "") // drop leading "or", "for", commas
    .replace(/\s*(?:,\s*)?\bor\b\s*$/i, "") // drop trailing connector "or" / ", or"
    .replace(/[.,;\s]+$/, "")
    .trim();
}

// Runes recommended within one <li>: the lead-in text (before the first spell)
// labels them all; text after each spell link becomes that rune's note.
function runesFromLi($: CheerioAPI, $li: Cheerio<any>): OmniumRune[] {
  const runes: OmniumRune[] = [];
  let lead = "";
  let sawSpell = false;

  for (const node of $li.contents().toArray()) {
    if (node.type === "text") {
      const txt = node.data ?? "";
      if (!sawSpell) lead += txt;
      else if (runes.length) runes[runes.length - 1].note = (runes[runes.length - 1].note ?? "") + txt;
      continue;
    }
    const $n = $(node);
    const spell = $n.is('[data-wowhead^="spell="]') ? $n : $n.find('[data-wowhead^="spell="]').first();
    if (spell.length) {
      const m = (spell.attr("data-wowhead") || "").match(/spell=(\d+)/);
      if (m) {
        runes.push({ spellId: Number(m[1]) });
        sawSpell = true;
      }
    } else if (!sawSpell) {
      lead += $n.text();
    }
  }

  const label = cleanLabel(lead);
  for (const r of runes) {
    if (label) r.label = label;
    const note = cleanNote(r.note ?? "");
    if (note) r.note = note;
    else delete r.note;
  }
  return runes;
}

export function parseIcyVeinsOmnium(html: string): OmniumRune[] {
  const $ = load(html);
  const out: OmniumRune[] = [];
  const seen = new Set<string>();
  const add = (rune: OmniumRune) => {
    // dedupe on spell+label+note so a rune isn't double-counted
    const key = `${rune.spellId}|${rune.label ?? ""}|${rune.note ?? ""}`;
    if (seen.has(key)) return;
    seen.add(key);
    out.push(rune);
  };

  // Primary: an `<h2 id="omnium">` heading, then walk siblings to the next section.
  const heading = $('[id^="omnium"]').first();
  if (heading.length > 0) {
    const container = heading.closest(".heading_container");
    const start = container.length ? container : heading;
    let node = start.next();
    while (node.length > 0) {
      const tag = (node.prop("tagName") || "").toLowerCase();
      if (tag === "h2" || node.find("h2").length > 0) break; // next section
      node.find("li").each((_, li) => runesFromLi($, $(li)).forEach(add));
      node = node.next();
    }
  }

  // Fallback: some specs (e.g. Balance Druid) render the Omnium Folio section with
  // no `id="omnium"` heading — the runes are still `<li>Week N: <span spell>…` items.
  // Collect them directly by the week-prefix + spell-link shape (omnium-specific).
  if (out.length === 0) {
    $("li").each((_, li) => {
      const $li = $(li);
      if (!/^\s*week\b/i.test($li.text())) return;
      if ($li.find('[data-wowhead^="spell="]').length === 0) return;
      runesFromLi($, $li).forEach(add);
    });
  }

  return out;
}
