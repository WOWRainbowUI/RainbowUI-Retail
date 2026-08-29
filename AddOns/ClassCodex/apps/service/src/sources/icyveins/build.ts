// Assemble parsed Icy Veins pages into a schema-valid SourceFile. IV is
// hero-agnostic (everything under the `all` hero). Mirrors the categories the
// legacy scraper filled (gear, talents, statPriority, consumables, crafting
// embellishments, rotation, links) and adds two new ones: trinket tier rankings
// and crafted items (crafting.crafts).
import { SCHEMA_VERSION, SourceFile, WILDCARD, type ClassToken } from "../../schema/index.js";
import { contentHash } from "../../render/content-hash.js";
import type {
  BisGearTab,
  Consumables,
  ItemRef,
  OmniumRune,
  Rotation,
  StatPriority,
  TalentBuild,
  TrinketRank,
} from "./types.js";
import type { SpecEntry } from "./urls.js";

export interface ParsedSpec {
  entry: SpecEntry;
  bisGear: BisGearTab[];
  trinkets: TrinketRank[];
  statPriority: StatPriority | null;
  consumables: Consumables | null;
  embellishments: ItemRef[];
  craftedItems: ItemRef[];
  talents: TalentBuild[];
  levelingTalents: TalentBuild[];
  rotation: Rotation[];
  omnium: OmniumRune[];
  bisUrl?: string;
  talentsUrl?: string;
  levelingUrl?: string;
}

/** A spec with no data — the degraded result when a page is missing or a parser throws. */
export function emptyParsedSpec(entry: SpecEntry): ParsedSpec {
  return {
    entry,
    bisGear: [],
    trinkets: [],
    statPriority: null,
    consumables: null,
    embellishments: [],
    craftedItems: [],
    talents: [],
    levelingTalents: [],
    rotation: [],
    omnium: [],
  };
}

// IV slot label → canonical GearSlot. Rings/trinkets aren't numbered on IV, so
// they're assigned positionally within a tab (mapSlot).
const SLOT_MAP: Record<string, string> = {
  Helm: "Head",
  Neck: "Neck",
  Shoulders: "Shoulders",
  Cloak: "Back",
  Chest: "Chest",
  Bracers: "Wrist",
  Hands: "Hands",
  Waist: "Waist",
  Legs: "Legs",
  Feet: "Feet",
  "Main Hand": "Main Hand",
  "Off Hand": "Off Hand",
};
// Map a (normalized) tab label to a gear context. Prefix-based, not exact, so
// season/raid-name suffixes like "Raid (Manaforge Omega)" still resolve to raid
// instead of being silently dropped.
function gearContext(label: string): string | null {
  if (/^overall/i.test(label)) return WILDCARD;
  if (/^mythic\s*\+/i.test(label)) return "mplus";
  if (/^raid/i.test(label)) return "raid";
  return null;
}
const TALENT_CONTEXT: Record<string, string> = {
  Raid: "raid",
  "Mythic+": "mplus",
  Delves: "delve",
  Leveling: "leveling",
  General: WILDCARD,
};
const ROTATION_CONTEXT: Record<string, string> = {
  "Single Target": "single-target",
  AoE: "aoe",
  Rotation: WILDCARD,
};
const STAT_MAP: Record<string, string> = {
  "Crit. Strike": "crit",
  Crit: "crit",
  "Critical Strike": "crit",
  Haste: "haste",
  Mastery: "mastery",
  Versatility: "versatility",
};

function mapSlot(slot: string, seen: { ring: number; trinket: number }): string | null {
  if (slot === "Ring") return `Finger ${++seen.ring}`;
  if (slot === "Trinket") return `Trinket ${++seen.trinket}`;
  return SLOT_MAP[slot] ?? null;
}

function buildSpec(p: ParsedSpec, embellishmentIds: Set<number>): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  const links: Record<string, string> = {};

  // gear
  const gearByContext: Record<string, unknown[]> = {};
  for (const tab of p.bisGear) {
    const context = gearContext(tab.label);
    if (!context) continue;
    const seen = { ring: 0, trinket: 0 };
    const items: unknown[] = [];
    for (const s of tab.slots) {
      const slot = mapSlot(s.slot, seen);
      if (!slot) continue;
      const item: Record<string, unknown> = { slot, itemId: s.item.itemId };
      if (s.item.bonusIDs?.length) item.bonusIDs = s.item.bonusIDs;
      if (s.source) item.source = s.source;
      items.push(item);
    }
    if (items.length) gearByContext[context] = items;
  }
  if (Object.keys(gearByContext).length) out.gear = { [WILDCARD]: gearByContext };

  // trinkets (tier ranking) — content-agnostic, keyed under `all`.
  const trinkets = p.trinkets
    .map((t) => ({ itemId: t.itemId, tier: t.tier }))
    .filter((t) => t.itemId > 0);
  if (trinkets.length) out.trinkets = { [WILDCARD]: { [WILDCARD]: trinkets } };

  // statPriority (secondary stats only)
  const secondary = (p.statPriority?.stats ?? [])
    .map((rank) => rank.map((n) => STAT_MAP[n]).filter(Boolean))
    .filter((rank) => rank.length);
  if (secondary.length) out.statPriority = { [WILDCARD]: { [WILDCARD]: { secondary } } };

  // consumables
  const cons: Record<string, number[]> = {};
  for (const key of ["flask", "potions", "food", "augmentRune"] as const) {
    const ids = (p.consumables?.[key] ?? []).map((i) => i.itemId);
    if (ids.length) cons[key] = ids;
  }
  if (Object.keys(cons).length) out.consumables = { [WILDCARD]: { [WILDCARD]: cons } };

  // crafting — split IV's crafting recommendations into embellishments (apply-able
  // reagents) vs crafts (everything else, incl. inherently-embellished gear). The
  // seed's reagent flag is ground truth, applied to both IV lists, since IV mixes
  // them (lists embellished gear as an embellishment, reagents as crafts). Without
  // the seed, trust IV's explicit "Best Embellishments" list as-is.
  const explicit = [...new Set(p.embellishments.map((e) => e.itemId))];
  const craftedIds = [...new Set(p.craftedItems.map((c) => c.itemId))];
  let embellishments: number[];
  let crafts: number[];
  if (embellishmentIds.size > 0) {
    const candidates = [...new Set([...explicit, ...craftedIds])];
    embellishments = candidates.filter((id) => embellishmentIds.has(id));
    const embSet = new Set(embellishments);
    crafts = candidates.filter((id) => !embSet.has(id));
  } else {
    embellishments = explicit;
    const embSet = new Set(embellishments);
    crafts = craftedIds.filter((id) => !embSet.has(id));
  }
  if (embellishments.length || crafts.length) {
    out.crafting = { [WILDCARD]: { [WILDCARD]: { crafts, embellishments } } };
  }

  // talents (+ leveling)
  const talentsByContext: Record<string, unknown[]> = {};
  for (const t of [...p.talents, ...p.levelingTalents]) {
    const context = TALENT_CONTEXT[t.context] ?? WILDCARD;
    (talentsByContext[context] ??= []).push(
      t.buildLabel ? { export: t.exportString, label: t.buildLabel } : { export: t.exportString },
    );
  }
  if (Object.keys(talentsByContext).length) out.talents = { [WILDCARD]: talentsByContext };

  // rotation (playstyle contexts)
  const rotationByContext: Record<string, unknown> = {};
  for (const r of p.rotation) {
    const ctx = ROTATION_CONTEXT[r.context];
    if (ctx && r.steps.length) rotationByContext[ctx] = { steps: r.steps };
  }
  if (Object.keys(rotationByContext).length) out.rotation = { [WILDCARD]: rotationByContext };

  // omnium folio (rune recommendations) — hero- and content-agnostic
  const omnium = p.omnium.map((r) => {
    const rec: Record<string, unknown> = { spellId: r.spellId };
    if (r.label) rec.label = r.label;
    if (r.note) rec.note = r.note;
    return rec;
  });
  if (omnium.length) out.omniumFolio = { [WILDCARD]: { [WILDCARD]: omnium } };

  // links
  if (p.bisUrl) links.bis = p.bisUrl;
  if (p.talentsUrl) links.talents = p.talentsUrl;
  if (p.levelingUrl) links.leveling = p.levelingUrl;
  if (Object.keys(links).length) out.links = links;

  return out;
}

export function buildSourceFile(
  specs: ParsedSpec[],
  generatedAt: string,
  embellishmentIds: Set<number> = new Set(),
): SourceFile {
  const data: Record<string, Record<string, Record<string, unknown>>> = {};

  for (const p of specs) {
    const specData = buildSpec(p, embellishmentIds);
    if (!Object.keys(specData).length) continue;
    const cls = p.entry.class as ClassToken;
    (data[cls] ??= {})[p.entry.spec] = specData;
  }

  // `generatedAt` stays a real wall-clock time; `contentHash` is the change trigger,
  // derived from `data`. IV is committed directly (no `compare` gate like the
  // u.gg/Blizzard scraper), so a committing consumer diffs on contentHash and keeps
  // the old file + timestamp when it matches — the timestamp only moves on a real
  // data change, instead of churning db_icyveins on every refresh.
  return SourceFile.parse({
    meta: { source: "icyveins", schemaVersion: SCHEMA_VERSION, generatedAt, contentHash: contentHash(data) },
    data,
  });
}
