// Trinket ranking. Under the "Trinket Recommendations" section (h2 id="trinkets")
// IV renders a ranking table inside a <details>: each row is a tier cell
// (<strong>S Tier</strong>) followed by a cell of item links for that tier:
//
//   <tr><td><span><strong>S Tier</strong></span></td>
//       <td><ul><li><span data-wowhead="item=NNN&bonus=…">Name</span></li>…</ul></td></tr>
//
// We emit each trinket once, tagged with its tier letter (S/A/B/C/D).
import { load } from "cheerio";
import type { Cheerio, CheerioAPI } from "cheerio";
import type { TrinketRank } from "../types.js";

// The first <table> in the trinkets section (skipping any nested nav/toc tables).
function rankingTable($: CheerioAPI): Cheerio<any> | null {
  const heading = $('[id^="trinkets"]').first();
  if (heading.length === 0) return null;
  const container = heading.closest(".heading_container");
  const start = container.length ? container : heading;

  let node = start.next();
  while (node.length > 0) {
    const tag = (node.prop("tagName") || "").toLowerCase();
    if (tag === "h2" || node.find("h2").length > 0) break; // next section
    const table = node.is("table") ? node : node.find("table").first();
    if (table && table.length) return table;
    node = node.next();
  }
  return null;
}

export function parseIcyVeinsTrinkets(html: string): TrinketRank[] {
  const $ = load(html);
  const table = rankingTable($);
  if (!table) return [];

  const out: TrinketRank[] = [];
  const seen = new Set<number>();

  table.find("tr").each((_, tr) => {
    const cells = $(tr).find("td");
    if (cells.length < 2) return; // header row (uses <th>)
    const tierRaw = $(cells[0]).text().replace(/\s+/g, " ").trim(); // "S Tier"
    const tier = tierRaw.replace(/\btier\b/i, "").trim(); // "S"
    if (!tier || tier.length > 3) return;

    $(cells[1])
      .find('[data-wowhead*="item="]')
      .each((_, el) => {
        const m = ($(el).attr("data-wowhead") || "").match(/item=(\d+)/);
        if (!m) return;
        const id = Number(m[1]);
        if (!id || seen.has(id)) return;
        seen.add(id);
        out.push({ itemId: id, name: $(el).text().trim(), tier });
      });
  });

  return out;
}
