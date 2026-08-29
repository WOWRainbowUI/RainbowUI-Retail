// The set of apply-able embellishment REAGENTS (Blizzard crafting DBC:
// `embellishment` AND `reagent`). This is the ground truth for splitting IV's
// mixed crafting recommendations: reagents are true embellishments, while
// inherently-embellished crafted gear (embellishment but not a reagent) is a
// craft. Sourced from the scraper's craftable-items seed (kept fresh by
// `resolve:craftables`); override the path with CRAFTABLE_ITEMS_PATH. Returns an
// empty set if unavailable, in which case the split falls back to trusting IV's
// explicit "Best Embellishments" list as-is.
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

export function loadEmbellishmentIds(): Set<number> {
  const dir = path.dirname(fileURLToPath(import.meta.url));
  const file =
    process.env.CRAFTABLE_ITEMS_PATH ??
    path.resolve(dir, "../../../../../packages/scraper/data/craftable-items.json");
  try {
    const seed = JSON.parse(fs.readFileSync(file, "utf-8")) as Record<
      string,
      { embellishment?: boolean; reagent?: boolean }
    >;
    const out = new Set<number>();
    for (const [id, item] of Object.entries(seed)) if (item.embellishment && item.reagent) out.add(Number(id));
    return out;
  } catch {
    return new Set();
  }
}
