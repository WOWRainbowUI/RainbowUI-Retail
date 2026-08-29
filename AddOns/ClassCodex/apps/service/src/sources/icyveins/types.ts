// Intermediate shapes the Icy Veins parsers produce, before build.ts maps them
// into the normalized schema. Kept local to this source — self-contained, so the
// service never has to reach into the scraper package.

export interface ItemRef {
  itemId: number;
  name: string;
}

export interface BisItem {
  itemId: number;
  name: string;
  bonusIDs?: number[];
}

export interface BisSlot {
  slot: string;
  item: BisItem;
  source?: string;
}

export interface BisGearTab {
  label: string;
  slots: BisSlot[];
}

/** A trinket with its S/A/B/… ranking tier from IV's per-spec ranking table. */
export interface TrinketRank {
  itemId: number;
  name: string;
  tier: string;
}

export interface TalentBuild {
  context: string;
  buildLabel: string;
  exportString: string;
}

export interface Consumables {
  flask: ItemRef[];
  potions: ItemRef[];
  food: ItemRef[];
  augmentRune: ItemRef[];
}

export interface StatPriority {
  /** Ordered ranks; tied stats share a rank. e.g. [["Mastery"], ["Crit", "Haste"]]. */
  stats: string[][];
}

export interface Rotation {
  context: string;
  steps: string[];
}

/** An Omnium Folio rune recommendation from the talents page's #omnium section. */
export interface OmniumRune {
  spellId: number;
  label?: string; // progression step, e.g. "Week 1"
  note?: string; // option qualifier, e.g. "solo play"
}
