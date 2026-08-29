// Canonical keys for the schema. Stable sets are enums; slugs (spec, hero) are
// format-validated and produced by slugify.
import { z } from "zod";

/** `"all"` on the hero or context axis = "not specialized on this dimension". */
export const WILDCARD = "all";

/** WoW class file tokens (uppercase) — the top-level `data` keys. */
export const CLASSES = [
  "DEATHKNIGHT",
  "DEMONHUNTER",
  "DRUID",
  "EVOKER",
  "HUNTER",
  "MAGE",
  "MONK",
  "PALADIN",
  "PRIEST",
  "ROGUE",
  "SHAMAN",
  "WARLOCK",
  "WARRIOR",
] as const;
export const ClassToken = z.enum(CLASSES);
export type ClassToken = z.infer<typeof ClassToken>;

/** Canonical slug: lowercase, hyphen-separated. Used for spec + hero-talent keys. */
export const SLUG_RE = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
export const Slug = z.string().regex(SLUG_RE, "must be a lowercase-hyphen slug");

/**
 * Normalize any source label to the canonical slug — run at ingestion so every
 * source variant maps to the same key: "Dark Ranger" / "DarkRanger" ->
 * "dark-ranger", "Elune's Chosen" -> "elunes-chosen", "San'layn" -> "sanlayn".
 */
export function slugify(raw: string): string {
  return raw
    .replace(/['’]/g, "") // drop apostrophes rather than splitting on them
    .replace(/([a-z0-9])([A-Z])/g, "$1-$2") // split camelCase runs
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/** The one canonical secondary-stat vocabulary — shared by statPriority + statTargets. */
export const STATS = ["crit", "haste", "mastery", "versatility"] as const;
export const Stat = z.enum(STATS);
export type Stat = z.infer<typeof Stat>;

/** Equipment slots — gear entries and enchant keys. */
export const GEAR_SLOTS = [
  "Head",
  "Neck",
  "Shoulders",
  "Back",
  "Chest",
  "Wrist",
  "Hands",
  "Waist",
  "Legs",
  "Feet",
  "Finger 1",
  "Finger 2",
  "Trinket 1",
  "Trinket 2",
  "Main Hand",
  "Off Hand",
] as const;
export const GearSlot = z.enum(GEAR_SLOTS);
export type GearSlot = z.infer<typeof GearSlot>;

/**
 * Content contexts (gear/talents/stats/crafting/enchants/gems/trinkets/consumables).
 * Base keys plus optional finer specificity `mplus:<blizzId>` / `raid:<blizzId>`
 * (canonical Blizzard challenge-map / journal-encounter IDs) that inherit their
 * parent via the resolver.
 */
export const CONTENT_BASE = [
  "mplus",
  "raid",
  "delve",
  "leveling",
  "pvp:2v2",
  "pvp:3v3",
  "pvp:shuffle",
  "pvp:blitz",
  "pvp:rbg",
] as const;
const CONTENT_SPECIFIC_RE = /^(?:mplus|raid):\d+$/;
export function isContentContext(k: string): boolean {
  return (
    k === WILDCARD ||
    (CONTENT_BASE as readonly string[]).includes(k) ||
    CONTENT_SPECIFIC_RE.test(k)
  );
}
export const ContentContext = z.string().refine(isContentContext, "invalid content context");

/** Rotation splits on playstyle, not content — a deliberately separate vocabulary. */
export const PLAYSTYLE = ["single-target", "aoe", "cleave"] as const;
export function isPlaystyleContext(k: string): boolean {
  return k === WILDCARD || (PLAYSTYLE as readonly string[]).includes(k);
}
export const PlaystyleContext = z.string().refine(isPlaystyleContext, "invalid playstyle context");
