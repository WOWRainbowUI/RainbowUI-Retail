// Explicit per-source expectation matrix: which categories each source is meant
// to fill for every spec. "Missing" in the status report means "expected here but
// absent" — measured against this, not inferred. Sources genuinely don't all
// carry the same categories (IV has no gems/enchants; u.gg has no rotation), so
// the expectation is declared, not guessed — based on what each provider emits.
import type { SourceFile } from "../schema/index.js";

export type Category =
  | "gear"
  | "enchants"
  | "gems"
  | "trinkets"
  | "crafting"
  | "talents"
  | "statPriority"
  | "statTargets"
  | "rotation"
  | "omniumFolio"
  | "consumables"
  | "links";

type SourceName = SourceFile["meta"]["source"];

// Categories each source is expected to provide per spec. Only listed categories
// are checked; anything else present is a bonus, anything absent is ignored.
// Note: `crafting` here means "has crafting data" — crafts and embellishments are
// independent (a spec can recommend crafted pieces with no embellishment, or vice
// versa), so neither sub-field is individually required.
export const EXPECTED_BY_SOURCE: Record<SourceName, Category[]> = {
  // Editorial: BiS (per-boss attribution), trinket tier ranking, talents,
  // stat priority, consumables, crafting (embellishments + crafted items),
  // rotation, and the per-spec guide links.
  icyveins: [
    "gear",
    "trinkets",
    "talents",
    "statPriority",
    "consumables",
    "crafting",
    "rotation",
    "omniumFolio",
    "links",
  ],
  // Statistical: gear, enchants, gems, trinket popularity, crafted items,
  // stat % targets, and PvP talents.
  ugg: ["gear", "enchants", "gems", "trinkets", "crafting", "statTargets", "talents"],
  // Blizzard armory: PvP talent loadouts only.
  blizzard: ["talents"],
};

export function expectedCategories(source: string): Category[] {
  return EXPECTED_BY_SOURCE[source as SourceName] ?? [];
}
