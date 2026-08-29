// Crafting surface from the BiS-gear page: embellishments (IV's editorial "Best
// Embellishments" pick) and crafted items ("Best Crafted Items" section). Since
// the page separates the two sections explicitly, crafts = crafted-section links
// minus anything already listed as an embellishment (build.ts does the subtract).
import { load } from "cheerio";
import type { ItemRef } from "../types.js";
import { collectItemLinksInSection, collectItemLinksUnderSection } from "./section.js";

// The "Best Embellishments for {Spec}" section — IV's explicit editorial pick.
export function parseIcyVeinsEmbellishments(html: string): ItemRef[] {
  return collectItemLinksInSection(load(html), "best-embellishments");
}

// Crafted-section heading ids, oldest layout first. IV renames these as it
// migrates pages: "best-crafted-items" → "ideal-gear-to-craft" / "crafted".
const CRAFTED_SECTION_IDS = ["best-crafted-items", "ideal-gear-to-craft", "crafted"];

// Item links under whichever crafted section the page uses, spanning subsections.
export function parseIcyVeinsCraftedItems(html: string): ItemRef[] {
  const $ = load(html);
  for (const id of CRAFTED_SECTION_IDS) {
    const items = collectItemLinksUnderSection($, id);
    if (items.length > 0) return items;
  }
  return [];
}
