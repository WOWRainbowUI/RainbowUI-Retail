import { describe, expect, it } from "vitest";
import { parseIcyVeinsBisGear } from "./gear.js";

// Minimal version of IV's card-grid layout: an image_block with per-tab
// image_block_content areas, each holding bis_item cards (slot / item link with
// bonusIDs / drop source), and a matching {id}_button carrying the tab label.
const card = (slot: string, itemAttr: string, name: string, drop: string) => `
  <div class="bis_item">
    <span class="bis_item_slot">${slot}</span>
    <span class="spell_icon_span"><span data-wowhead="${itemAttr}">${name}</span></span>
    <span class="bis_item_drop">${drop}</span>
  </div>`;

const HTML = `
<div class="image_block">
  <div class="image_block_content" id="bis_0_0">
    ${card("Head", "item=100&amp;bonus=12:34", "Helm", "Boss X in Raid")}
    ${card("Trinket", "item=200", "Trink", "Vendor")}
  </div>
  <div class="image_block_content" id="bis_0_1">
    ${card("Chest", "item=300", "Robe", "Dungeon")}
  </div>
</div>
<span id="bis_0_0_button">Raid Gear Best-in-Slot</span>
<span id="bis_0_1_button">Mythic + Gear Best-in-Slot</span>`;

describe("parseIcyVeinsBisGear", () => {
  it("parses tabs, slots, bonusIDs and per-slot drop source", () => {
    const tabs = parseIcyVeinsBisGear(HTML);
    expect(tabs.map((t) => t.label)).toEqual(["Raid", "Mythic+"]); // labels normalized

    const raid = tabs[0];
    expect(raid.slots[0]).toEqual({
      slot: "Head",
      item: { itemId: 100, name: "Helm", bonusIDs: [12, 34] },
      source: "Boss X in Raid",
    });
    // no bonus= → no bonusIDs key
    expect(raid.slots[1].item).toEqual({ itemId: 200, name: "Trink" });
    expect(tabs[1].slots[0].item.itemId).toBe(300);
  });

  it("returns [] on markup with no bis_item cards", () => {
    expect(parseIcyVeinsBisGear("<div class='image_block'></div>")).toEqual([]);
  });
});
