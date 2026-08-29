// Collect the item links within a section identified by its heading id. IV wraps
// each heading in a div.heading_container; the section body follows as siblings
// up to the next heading. Item links are <span data-wowhead="item=NNN">Name</span>.
import type { Cheerio, CheerioAPI } from "cheerio";
import type { ItemRef } from "../types.js";

/** Every `<span data-wowhead="item=NNN">Name</span>` link within `$el` (in document order). */
export function itemRefsIn($: CheerioAPI, $el: Cheerio<any>): ItemRef[] {
  const out: ItemRef[] = [];
  $el.find('[data-wowhead^="item="]').each((_, el) => {
    const m = ($(el).attr("data-wowhead") || "").match(/item=(\d+)/);
    if (m) out.push({ itemId: Number(m[1]), name: $(el).text().trim() });
  });
  return out;
}

function headingLevel($: CheerioAPI, node: Cheerio<any>): number {
  const tag = (node.prop("tagName") || "").toLowerCase();
  const m = /^h([1-6])$/.exec(tag);
  if (m) return Number(m[1]);
  const inner = node.find("h1,h2,h3,h4,h5,h6").first();
  const im = inner.length ? /^h([1-6])$/.exec((inner.prop("tagName") || "").toLowerCase()) : null;
  return im ? Number(im[1]) : 0;
}

function collectFrom($: CheerioAPI, headingId: string, stopAtAnyHeading: boolean): ItemRef[] {
  const heading = $(`[id^="${headingId}"]`).first();
  if (heading.length === 0) return [];

  const container = heading.closest(".heading_container");
  const start = container.length > 0 ? container : heading;
  const level = headingLevel($, start);

  const out: ItemRef[] = [];
  const seen = new Set<number>();

  let node = start.next();
  while (node.length > 0) {
    const lvl = headingLevel($, node);
    if (lvl > 0) {
      // Shallow walk stops at any heading; deep walk spans subsections and only
      // stops at a heading of the same or higher level (the next section).
      if (stopAtAnyHeading || lvl <= level) break;
    }
    for (const ref of itemRefsIn($, node)) {
      if (!ref.itemId || seen.has(ref.itemId)) continue;
      seen.add(ref.itemId);
      out.push(ref);
    }
    node = node.next();
  }
  return out;
}

/** Item links directly within a section, stopping at the next heading of any level. */
export function collectItemLinksInSection($: CheerioAPI, headingId: string): ItemRef[] {
  return collectFrom($, headingId, true);
}

/** Item links anywhere under a section, spanning sub-headings, to the next same-or-higher heading. */
export function collectItemLinksUnderSection($: CheerioAPI, headingId: string): ItemRef[] {
  return collectFrom($, headingId, false);
}
