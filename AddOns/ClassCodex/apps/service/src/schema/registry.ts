// Canonical class -> spec -> its two hero-talent slugs. Derived from live source
// data (u.gg/IV/Blizzard hero labels), not memory. 13 classes, 40 specs.
import { WILDCARD, type ClassToken } from "./enums.js";

export const REGISTRY = {
  DEATHKNIGHT: {
    blood: ["deathbringer", "sanlayn"],
    frost: ["deathbringer", "rider-of-the-apocalypse"],
    unholy: ["rider-of-the-apocalypse", "sanlayn"],
  },
  DEMONHUNTER: {
    havoc: ["aldrachi-reaver", "fel-scarred"],
    vengeance: ["aldrachi-reaver", "annihilator"],
    devourer: ["annihilator", "void-scarred"],
  },
  DRUID: {
    balance: ["elunes-chosen", "keeper-of-the-grove"],
    feral: ["druid-of-the-claw", "wildstalker"],
    guardian: ["druid-of-the-claw", "elunes-chosen"],
    restoration: ["keeper-of-the-grove", "wildstalker"],
  },
  EVOKER: {
    augmentation: ["chronowarden", "scalecommander"],
    devastation: ["flameshaper", "scalecommander"],
    preservation: ["chronowarden", "flameshaper"],
  },
  HUNTER: {
    "beast-mastery": ["dark-ranger", "pack-leader"],
    marksmanship: ["dark-ranger", "sentinel"],
    survival: ["pack-leader", "sentinel"],
  },
  MAGE: {
    arcane: ["spellslinger", "sunfury"],
    fire: ["frostfire", "sunfury"],
    frost: ["frostfire", "spellslinger"],
  },
  MONK: {
    brewmaster: ["master-of-harmony", "shado-pan"],
    mistweaver: ["conduit-of-the-celestials", "master-of-harmony"],
    windwalker: ["conduit-of-the-celestials", "shado-pan"],
  },
  PALADIN: {
    holy: ["herald-of-the-sun", "lightsmith"],
    protection: ["lightsmith", "templar"],
    retribution: ["herald-of-the-sun", "templar"],
  },
  PRIEST: {
    discipline: ["oracle", "voidweaver"],
    holy: ["archon", "oracle"],
    shadow: ["archon", "voidweaver"],
  },
  ROGUE: {
    assassination: ["deathstalker", "fatebound"],
    outlaw: ["fatebound", "trickster"],
    subtlety: ["deathstalker", "trickster"],
  },
  SHAMAN: {
    elemental: ["farseer", "stormbringer"],
    enhancement: ["stormbringer", "totemic"],
    restoration: ["farseer", "totemic"],
  },
  WARLOCK: {
    affliction: ["hellcaller", "soul-harvester"],
    demonology: ["diabolist", "soul-harvester"],
    destruction: ["diabolist", "hellcaller"],
  },
  WARRIOR: {
    arms: ["colossus", "slayer"],
    fury: ["mountain-thane", "slayer"],
    protection: ["colossus", "mountain-thane"],
  },
} as const satisfies Record<ClassToken, Record<string, readonly [string, string]>>;

export function isSpec(cls: ClassToken, spec: string): boolean {
  return Object.prototype.hasOwnProperty.call(REGISTRY[cls], spec);
}

export function heroesForSpec(cls: ClassToken, spec: string): readonly string[] {
  return (REGISTRY[cls] as Record<string, readonly string[]>)[spec] ?? [];
}

export function isHeroForSpec(cls: ClassToken, spec: string, hero: string): boolean {
  return hero === WILDCARD || heroesForSpec(cls, spec).includes(hero);
}

/** All distinct hero-talent slugs across every spec. */
export const HERO_SLUGS: ReadonlySet<string> = new Set(
  Object.values(REGISTRY).flatMap((specs) => Object.values(specs).flat()),
);

export const SPEC_COUNT = Object.values(REGISTRY).reduce((n, specs) => n + Object.keys(specs).length, 0);
