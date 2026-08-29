// BiS gear cards. Each tab (Overall / Raid / Mythic+) is a div.image_block_content
// holding div.bis_item cards: a slot label, the item link (with bonusIDs driving
// tooltip ilvl), and a per-slot drop-source string (IV's signature attribution).
import { load } from "cheerio";
import type { BisGearTab, BisSlot } from "../types.js";

function parseDataWowhead(attr: string): { itemId: number; bonusIDs?: number[] } | null {
  const itemMatch = /item=(\d+)/.exec(attr);
  if (!itemMatch) return null;
  const itemId = parseInt(itemMatch[1], 10);
  const bonusMatch = /bonus=([0-9:]+)/.exec(attr);
  const bonusIDs = bonusMatch ? bonusMatch[1].split(":").map(Number).filter(Boolean) : undefined;
  return { itemId, bonusIDs: bonusIDs?.length ? bonusIDs : undefined };
}

/** Normalize tab labels: strip suffixes/season tags, normalize Mythic+, map raid lists. */
function normalizeTabLabel(raw: string): string {
  let label = raw
    .replace(/\s+/g, " ")
    .replace(/\s+gear\s+best-in-slot.*$/i, "")
    .replace(/\s+best-in-slot.*$/i, "")
    .replace(/\s+gear\s+bis\s+list.*$/i, "")
    .replace(/\s+bis\s+list.*$/i, "")
    .replace(/\s+for\s+season\s+\d+$/i, "")
    .replace(/\s*,?\s*season\s+\d+$/i, "")
    .replace(/\s*,?\s*midnight\s+season\s+\d+$/i, "")
    .replace(/mythic\s*\+/i, "Mythic+")
    .trim();

  const LABEL_MAP: Record<string, string> = {
    overall: "Overall",
    raid: "Raid",
    "mythic+": "Mythic+",
    "mythic+ only": "Mythic+",
    dungeon: "Mythic+",
    "bis list": "Overall",
    bis: "Overall",
  };
  const mapped = LABEL_MAP[label.toLowerCase()];
  if (mapped) label = mapped;

  if (/,\s+.*\band\b/i.test(label) && !/overall|mythic|raid|bis/i.test(label)) label = "Raid";

  const bisRaidMatch = label.match(/^bis\s+raid(?:\s*\(([^)]+)\))?$/i);
  if (bisRaidMatch) label = bisRaidMatch[1] ? `Raid (${bisRaidMatch[1]})` : "Raid";

  return label || raw.trim();
}

export function parseIcyVeinsBisGear(html: string): BisGearTab[] {
  const $ = load(html);
  const tabs: BisGearTab[] = [];
  const processedIds = new Set<string>();

  $("div.image_block").each((_, block) => {
    $(block).find("div.image_block_content").each((idx, area) => {
      const areaId = $(area).attr("id");
      if (!areaId || processedIds.has(areaId)) return;
      processedIds.add(areaId);

      // Attribute selector (not `#id`) so an areaId that isn't a bare CSS
      // identifier — leading digit, ':' etc. — can't throw a selector error.
      const buttonText = $(`[id="${areaId}_button"]`).text().replace(/\s+/g, " ").trim();
      const label = buttonText ? normalizeTabLabel(buttonText) : `Tab ${idx + 1}`;

      const slots: BisSlot[] = [];
      $(area).find("div.bis_item").each((_, item) => {
        const slotText = $(item).find(".bis_item_slot").first().text().replace(/\s+/g, " ").trim();
        if (!slotText) return;

        const itemSpan = $(item)
          .find("> span.spell_icon_span span[data-wowhead]")
          .filter((_, el) => $(el).text().trim().length > 0)
          .first();
        if (itemSpan.length === 0) return;

        const parsed = parseDataWowhead(itemSpan.attr("data-wowhead") || "");
        if (!parsed) return;

        const name = itemSpan.text().trim();
        const source = $(item).find(".bis_item_drop").first().text().replace(/\s+/g, " ").trim();

        const slot: BisSlot = { slot: slotText, item: { itemId: parsed.itemId, name }, source };
        if (parsed.bonusIDs) slot.item.bonusIDs = parsed.bonusIDs;
        slots.push(slot);
      });

      if (slots.length > 0) tabs.push({ label, slots });
    });
  });

  return tabs;
}
