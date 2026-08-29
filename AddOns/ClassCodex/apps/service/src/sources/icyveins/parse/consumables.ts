// "Optimal Consumables" section → categorised item lists. IV is mid-migration
// between a per-heading layout (id="flask"/"potions"/…) and a single flat <ul>
// whose <li>s lead with a category label ("Flasks:", "Combat Potion:"). We read
// both and merge (dedupe by itemId, first hit wins).
import { load } from "cheerio";
import type { Cheerio, CheerioAPI } from "cheerio";
import type { Consumables, ItemRef } from "../types.js";
import { collectItemLinksInSection, itemRefsIn } from "./section.js";

type Category = keyof Consumables;

const SECTIONS: { key: Category; id: string }[] = [
  { key: "flask", id: "flask" },
  { key: "potions", id: "potions" },
  { key: "food", id: "food-buff" },
  { key: "augmentRune", id: "augment-rune" },
];

function categoryFromLabel(label: string): Category | null {
  const l = label.toLowerCase();
  if (/flask/.test(l)) return "flask";
  if (/potion/.test(l)) return "potions";
  if (/food|feast|banquet|meal/.test(l)) return "food";
  if (/augment rune|\brune\b/.test(l)) return "augmentRune";
  return null;
}

// Fallback when a <li> has no category lead label — classify by item name, or
// null (skip) when it isn't recognizable. Food can't be name-detected reliably.
function categoryFromName(name: string): Category | null {
  if (/flask/i.test(name)) return "flask";
  if (/potion/i.test(name)) return "potions";
  if (/\brune\b/i.test(name)) return "augmentRune";
  return null;
}

function leadLabel($: CheerioAPI, $li: Cheerio<any>): string {
  let label = "";
  for (const node of $li.contents().toArray()) {
    if (node.type === "text") {
      label += node.data ?? "";
      continue;
    }
    const $n = $(node);
    if ($n.is('[data-wowhead^="item="]') || $n.find('[data-wowhead^="item="]').length) break;
    label += $n.text();
  }
  return label.replace(/:\s*$/, "").trim();
}

function optimalConsumablesItems($: CheerioAPI): { label: string; links: ItemRef[] }[] {
  const heading = $('[id^="optimal-consumables"]').first();
  if (heading.length === 0) return [];
  const container = heading.closest(".heading_container");
  const start = container.length ? container : heading;

  const out: { label: string; links: ItemRef[] }[] = [];
  let node = start.next();
  while (node.length > 0) {
    const tag = (node.prop("tagName") || "").toLowerCase();
    if (node.attr("id") === "changelog" || tag === "h2" || node.find("h2").length > 0) break;
    node.find("li").each((_, li) => {
      const $li = $(li);
      const links = itemRefsIn($, $li);
      if (links.length) out.push({ label: leadLabel($, $li), links });
    });
    node = node.next();
  }
  return out;
}

export function parseIcyVeinsConsumables(html: string): Consumables | null {
  const $ = load(html);
  const result: Consumables = { flask: [], potions: [], food: [], augmentRune: [] };
  const seen = new Set<number>();
  const add = (cat: Category | null, it: ItemRef) => {
    if (!cat || seen.has(it.itemId)) return;
    seen.add(it.itemId);
    result[cat].push(it);
  };

  for (const { key, id } of SECTIONS) {
    for (const it of collectItemLinksInSection($, id)) add(key, it);
  }

  for (const { label, links } of optimalConsumablesItems($)) {
    const byLabel = categoryFromLabel(label);
    for (const it of links) add(byLabel ?? categoryFromName(it.name), it);
  }

  return Object.values(result).some((l) => l.length > 0) ? result : null;
}
