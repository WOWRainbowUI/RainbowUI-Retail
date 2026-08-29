// Normalized per-source schema, addressed data[CLASS][spec][category][hero][context].
// A source fills only the categories it has. hero/context are wildcard-able ("all").
import { z } from "zod";
import { ClassToken, GearSlot, isContentContext, PlaystyleContext, Stat } from "./enums.js";
import { isHeroForSpec, isSpec } from "./registry.js";

export const SCHEMA_VERSION = 1;
export const SOURCES = ["ugg", "icyveins", "blizzard"] as const;

const ItemId = z.number().int().positive();

/**
 * Build a `[hero][context]` map. Context keys are validated here (content vs
 * playstyle vocabulary); hero keys are validated at the file level against the
 * registry, where the class+spec is known.
 */
function heroContextMap<V extends z.ZodTypeAny>(payload: V, isContextKey: (k: string) => boolean) {
  const contextMap = z.record(z.string(), payload).superRefine((obj, ctx) => {
    for (const key of Object.keys(obj)) {
      if (!isContextKey(key)) {
        ctx.addIssue({ code: z.ZodIssueCode.custom, message: `invalid context key: ${key}` });
      }
    }
  });
  return z.record(z.string(), contextMap);
}

const isPlaystyle = (k: string) => PlaystyleContext.safeParse(k).success;

// --- payloads -------------------------------------------------------------

/** itemId is identity; `bonusIDs` (Icy Veins) and `ilvl` (u.gg) are source-dependent. */
export const GearItem = z
  .object({
    slot: GearSlot,
    itemId: ItemId,
    bonusIDs: z.array(z.number().int()).optional(),
    ilvl: z.number().int().positive().optional(),
    source: z.string().optional(), // drop location / acquisition, editorial (kept — users ask)
  })
  .strict();

export const Enchant = z.object({ id: z.number().int(), spellId: z.number().int().optional() }).strict();

/** enchants payload = one entry per slot; a list allows alternates. */
export const EnchantsBySlot = z.record(z.string(), z.array(Enchant)).superRefine((obj, ctx) => {
  for (const key of Object.keys(obj)) {
    if (!GearSlot.safeParse(key).success) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, message: `invalid slot: ${key}` });
    }
  }
});

/** One socket loadout (a list allows multiple ranked loadouts). */
export const GemLoadout = z.object({ primary: ItemId.optional(), secondary: z.array(ItemId) }).strict();

export const Trinket = z
  .object({
    itemId: ItemId,
    tier: z.string().optional(), // S/A/B/… — source-defined, optional
    pop: z.number().optional(), // popularity %, full precision, optional
  })
  .strict();

export const Crafting = z.object({ crafts: z.array(ItemId), embellishments: z.array(ItemId) }).strict();

/** honor only appears under pvp contexts. Leveling uses this same shape (final build). */
export const TalentBuild = z
  .object({
    export: z.string().min(1),
    label: z.string().optional(),
    pickrate: z.number().optional(),
    honor: z.array(z.number().int()).optional(),
  })
  .strict();

export const StatPriority = z
  .object({
    primary: z.string().optional(), // main stat (Agility/…), not weighed
    secondary: z.array(z.array(Stat)), // ordered tiers of secondary stats
    minor: z.array(z.array(z.string())).optional(), // tertiary (Leech/Avoidance/Speed)
  })
  .strict();

export const StatTargets = z
  .object({
    crit: z.number().optional(),
    haste: z.number().optional(),
    mastery: z.number().optional(),
    versatility: z.number().optional(),
  })
  .strict();

/** Rotation steps keep `{spellId}` tokens — resolved to spell names in-game, locale-independent. */
export const Rotation = z.object({ steps: z.array(z.string()) }).strict();

/** One Omnium Folio rune recommendation (Midnight borrowed-power system). `label`
 * carries the progression step ("Week 1"), `note` an option qualifier ("solo play"). */
export const OmniumRune = z
  .object({
    spellId: z.number().int().positive(),
    label: z.string().optional(),
    note: z.string().optional(),
  })
  .strict();

export const Consumables = z
  .object({
    flask: z.array(ItemId).optional(),
    potions: z.array(ItemId).optional(),
    food: z.array(ItemId).optional(),
    augmentRune: z.array(ItemId).optional(),
  })
  .strict();

/** Per-source guide URLs (from the old sources.lua) — spec-level, outside [hero][context]. */
export const Links = z
  .object({
    bis: z.string().optional(),
    talents: z.string().optional(),
    leveling: z.string().optional(),
  })
  .strict();

// --- spec / class / file --------------------------------------------------

export const SpecData = z
  .object({
    links: Links.optional(),
    gear: heroContextMap(z.array(GearItem), isContentContext).optional(),
    enchants: heroContextMap(EnchantsBySlot, isContentContext).optional(),
    gems: heroContextMap(z.array(GemLoadout), isContentContext).optional(),
    trinkets: heroContextMap(z.array(Trinket), isContentContext).optional(),
    crafting: heroContextMap(Crafting, isContentContext).optional(),
    talents: heroContextMap(z.array(TalentBuild), isContentContext).optional(),
    statPriority: heroContextMap(StatPriority, isContentContext).optional(),
    statTargets: heroContextMap(StatTargets, isContentContext).optional(),
    rotation: heroContextMap(Rotation, isPlaystyle).optional(),
    omniumFolio: heroContextMap(z.array(OmniumRune), isContentContext).optional(),
    consumables: heroContextMap(Consumables, isContentContext).optional(),
  })
  .strict();

const ClassData = z.record(z.string(), SpecData);

export const Meta = z
  .object({
    source: z.enum(SOURCES),
    schemaVersion: z.number().int(),
    generatedAt: z.string(), // ISO datetime — when this build ran (wall-clock)
    // Content fingerprint of `data` (see render/content-hash). Changes iff the data
    // changes, so a committing consumer can keep the old file (and its generatedAt)
    // when the hash matches — the timestamp only advances on a real data change.
    // Optional: emitted by the Icy Veins service source; the scraper's u.gg/Blizzard
    // sources omit it (their `compare` gate already strips per-run timestamps).
    contentHash: z.string().optional(),
  })
  .strict();

export const SourceFile = z
  .object({ meta: Meta, data: z.record(ClassToken, ClassData) })
  .strict()
  // spec + hero keys are validated here against the registry, where class+spec is known.
  .superRefine((file, ctx) => {
    for (const cls of Object.keys(file.data) as ClassToken[]) {
      const specs = file.data[cls] ?? {};
      for (const [spec, specData] of Object.entries(specs)) {
        if (!isSpec(cls, spec)) {
          ctx.addIssue({ code: z.ZodIssueCode.custom, path: ["data", cls, spec], message: `unknown spec '${spec}' for ${cls}` });
          continue;
        }
        for (const [category, byHero] of Object.entries(specData)) {
          if (category === "links" || byHero === null || typeof byHero !== "object") continue;
          for (const hero of Object.keys(byHero)) {
            if (!isHeroForSpec(cls, spec, hero)) {
              ctx.addIssue({ code: z.ZodIssueCode.custom, path: ["data", cls, spec, category, hero], message: `hero '${hero}' invalid for ${cls}/${spec}` });
            }
          }
        }
      }
    }
  });

export type SourceFile = z.infer<typeof SourceFile>;
export type SpecData = z.infer<typeof SpecData>;
export type GearItem = z.infer<typeof GearItem>;
export type TalentBuild = z.infer<typeof TalentBuild>;
