// The 40-spec table + Icy Veins URL builders. Ported from the scraper's
// spec-list.ts (kept in sync by hand — this is stable factual data). classSlug /
// specSlug feed IV's URL scheme; role picks the page's role segment.
import type { ClassToken } from "../../schema/index.js";

export interface SpecEntry {
  class: ClassToken;
  spec: string;
  role: "dps" | "tank" | "heal";
  classSlug: string;
  specSlug: string;
  label: string;
}

const BASE = "https://www.icy-veins.com/wow";

// Every page type uses the same role segment: dps | tank | healing.
const ROLE_MAP: Record<string, string> = { dps: "dps", tank: "tank", heal: "healing" };

export function buildBisUrl(e: SpecEntry): string {
  return `${BASE}/${e.specSlug}-${e.classSlug}-pve-${ROLE_MAP[e.role]}-gear-best-in-slot`;
}
export function buildTalentsUrl(e: SpecEntry): string {
  return `${BASE}/${e.specSlug}-${e.classSlug}-pve-${ROLE_MAP[e.role]}-spec-builds-talents`;
}
export function buildStatPriorityUrl(e: SpecEntry): string {
  return `${BASE}/${e.specSlug}-${e.classSlug}-pve-${ROLE_MAP[e.role]}-stat-priority`;
}
export function buildConsumablesUrl(e: SpecEntry): string {
  return `${BASE}/${e.specSlug}-${e.classSlug}-pve-${ROLE_MAP[e.role]}-gems-enchants-consumables`;
}
export function buildLevelingUrl(e: SpecEntry): string {
  return `${BASE}/${e.specSlug}-${e.classSlug}-leveling-guide`;
}
export function buildRotationUrl(e: SpecEntry): string {
  return `${BASE}/${e.specSlug}-${e.classSlug}-pve-${ROLE_MAP[e.role]}-rotation-cooldowns-abilities`;
}

export const SPECS: SpecEntry[] = [
  { class: "DEATHKNIGHT", spec: "blood",  role: "tank", classSlug: "death-knight", specSlug: "blood",  label: "Blood Death Knight" },
  { class: "DEATHKNIGHT", spec: "frost",  role: "dps",  classSlug: "death-knight", specSlug: "frost",  label: "Frost Death Knight" },
  { class: "DEATHKNIGHT", spec: "unholy", role: "dps",  classSlug: "death-knight", specSlug: "unholy", label: "Unholy Death Knight" },

  { class: "DEMONHUNTER", spec: "havoc",     role: "dps",  classSlug: "demon-hunter", specSlug: "havoc",     label: "Havoc Demon Hunter" },
  { class: "DEMONHUNTER", spec: "vengeance", role: "tank", classSlug: "demon-hunter", specSlug: "vengeance", label: "Vengeance Demon Hunter" },
  { class: "DEMONHUNTER", spec: "devourer",  role: "dps",  classSlug: "demon-hunter", specSlug: "devourer",  label: "Devourer Demon Hunter" },

  { class: "DRUID", spec: "balance",     role: "dps",  classSlug: "druid", specSlug: "balance",     label: "Balance Druid" },
  { class: "DRUID", spec: "feral",       role: "dps",  classSlug: "druid", specSlug: "feral",       label: "Feral Druid" },
  { class: "DRUID", spec: "guardian",    role: "tank", classSlug: "druid", specSlug: "guardian",    label: "Guardian Druid" },
  { class: "DRUID", spec: "restoration", role: "heal", classSlug: "druid", specSlug: "restoration", label: "Restoration Druid" },

  { class: "EVOKER", spec: "devastation",  role: "dps",  classSlug: "evoker", specSlug: "devastation",  label: "Devastation Evoker" },
  { class: "EVOKER", spec: "preservation", role: "heal", classSlug: "evoker", specSlug: "preservation", label: "Preservation Evoker" },
  { class: "EVOKER", spec: "augmentation", role: "dps",  classSlug: "evoker", specSlug: "augmentation", label: "Augmentation Evoker" },

  { class: "HUNTER", spec: "beast-mastery", role: "dps", classSlug: "hunter", specSlug: "beast-mastery", label: "Beast Mastery Hunter" },
  { class: "HUNTER", spec: "marksmanship",  role: "dps", classSlug: "hunter", specSlug: "marksmanship",  label: "Marksmanship Hunter" },
  { class: "HUNTER", spec: "survival",      role: "dps", classSlug: "hunter", specSlug: "survival",      label: "Survival Hunter" },

  { class: "MAGE", spec: "arcane", role: "dps", classSlug: "mage", specSlug: "arcane", label: "Arcane Mage" },
  { class: "MAGE", spec: "fire",   role: "dps", classSlug: "mage", specSlug: "fire",   label: "Fire Mage" },
  { class: "MAGE", spec: "frost",  role: "dps", classSlug: "mage", specSlug: "frost",  label: "Frost Mage" },

  { class: "MONK", spec: "brewmaster", role: "tank", classSlug: "monk", specSlug: "brewmaster", label: "Brewmaster Monk" },
  { class: "MONK", spec: "mistweaver", role: "heal", classSlug: "monk", specSlug: "mistweaver", label: "Mistweaver Monk" },
  { class: "MONK", spec: "windwalker", role: "dps",  classSlug: "monk", specSlug: "windwalker", label: "Windwalker Monk" },

  { class: "PALADIN", spec: "holy",        role: "heal", classSlug: "paladin", specSlug: "holy",        label: "Holy Paladin" },
  { class: "PALADIN", spec: "protection",  role: "tank", classSlug: "paladin", specSlug: "protection",  label: "Protection Paladin" },
  { class: "PALADIN", spec: "retribution", role: "dps",  classSlug: "paladin", specSlug: "retribution", label: "Retribution Paladin" },

  { class: "PRIEST", spec: "discipline", role: "heal", classSlug: "priest", specSlug: "discipline", label: "Discipline Priest" },
  { class: "PRIEST", spec: "holy",       role: "heal", classSlug: "priest", specSlug: "holy",       label: "Holy Priest" },
  { class: "PRIEST", spec: "shadow",     role: "dps",  classSlug: "priest", specSlug: "shadow",     label: "Shadow Priest" },

  { class: "ROGUE", spec: "assassination", role: "dps", classSlug: "rogue", specSlug: "assassination", label: "Assassination Rogue" },
  { class: "ROGUE", spec: "outlaw",        role: "dps", classSlug: "rogue", specSlug: "outlaw",        label: "Outlaw Rogue" },
  { class: "ROGUE", spec: "subtlety",      role: "dps", classSlug: "rogue", specSlug: "subtlety",      label: "Subtlety Rogue" },

  { class: "SHAMAN", spec: "elemental",   role: "dps",  classSlug: "shaman", specSlug: "elemental",   label: "Elemental Shaman" },
  { class: "SHAMAN", spec: "enhancement", role: "dps",  classSlug: "shaman", specSlug: "enhancement", label: "Enhancement Shaman" },
  { class: "SHAMAN", spec: "restoration", role: "heal", classSlug: "shaman", specSlug: "restoration", label: "Restoration Shaman" },

  { class: "WARLOCK", spec: "affliction",  role: "dps", classSlug: "warlock", specSlug: "affliction",  label: "Affliction Warlock" },
  { class: "WARLOCK", spec: "demonology",  role: "dps", classSlug: "warlock", specSlug: "demonology",  label: "Demonology Warlock" },
  { class: "WARLOCK", spec: "destruction", role: "dps", classSlug: "warlock", specSlug: "destruction", label: "Destruction Warlock" },

  { class: "WARRIOR", spec: "arms",       role: "dps",  classSlug: "warrior", specSlug: "arms",       label: "Arms Warrior" },
  { class: "WARRIOR", spec: "fury",       role: "dps",  classSlug: "warrior", specSlug: "fury",       label: "Fury Warrior" },
  { class: "WARRIOR", spec: "protection", role: "tank", classSlug: "warrior", specSlug: "protection", label: "Protection Warrior" },
];

/** Canonical hero-talent names per spec — used to strip hero noise from IV build titles. */
export const HERO_TALENTS_BY_SPEC: Record<string, [string, string]> = {
  "DEATHKNIGHT/blood":      ["San'layn", "Deathbringer"],
  "DEATHKNIGHT/frost":      ["Deathbringer", "Rider of the Apocalypse"],
  "DEATHKNIGHT/unholy":     ["San'layn", "Rider of the Apocalypse"],
  "DEMONHUNTER/havoc":      ["Fel-Scarred", "Aldrachi Reaver"],
  "DEMONHUNTER/vengeance":  ["Aldrachi Reaver", "Annihilator"],
  "DEMONHUNTER/devourer":   ["Annihilator", "Void-Scarred"],
  "DRUID/balance":          ["Keeper of the Grove", "Elune's Chosen"],
  "DRUID/feral":            ["Druid of the Claw", "Wildstalker"],
  "DRUID/guardian":         ["Druid of the Claw", "Elune's Chosen"],
  "DRUID/restoration":      ["Keeper of the Grove", "Wildstalker"],
  "EVOKER/devastation":     ["Flameshaper", "Scalecommander"],
  "EVOKER/preservation":    ["Flameshaper", "Chronowarden"],
  "EVOKER/augmentation":    ["Chronowarden", "Scalecommander"],
  "HUNTER/beast-mastery":   ["Pack Leader", "Dark Ranger"],
  "HUNTER/marksmanship":    ["Sentinel", "Dark Ranger"],
  "HUNTER/survival":        ["Pack Leader", "Sentinel"],
  "MAGE/arcane":            ["Spellslinger", "Sunfury"],
  "MAGE/fire":              ["Sunfury", "Frostfire"],
  "MAGE/frost":             ["Frostfire", "Spellslinger"],
  "MONK/brewmaster":        ["Shado-Pan", "Master of Harmony"],
  "MONK/mistweaver":        ["Conduit of the Celestials", "Master of Harmony"],
  "MONK/windwalker":        ["Shado-Pan", "Conduit of the Celestials"],
  "PALADIN/holy":           ["Herald of the Sun", "Lightsmith"],
  "PALADIN/protection":     ["Templar", "Lightsmith"],
  "PALADIN/retribution":    ["Templar", "Herald of the Sun"],
  "PRIEST/discipline":      ["Oracle", "Voidweaver"],
  "PRIEST/holy":            ["Archon", "Oracle"],
  "PRIEST/shadow":          ["Archon", "Voidweaver"],
  "ROGUE/assassination":    ["Fatebound", "Deathstalker"],
  "ROGUE/outlaw":           ["Trickster", "Fatebound"],
  "ROGUE/subtlety":         ["Deathstalker", "Trickster"],
  "SHAMAN/elemental":       ["Farseer", "Stormbringer"],
  "SHAMAN/enhancement":     ["Stormbringer", "Totemic"],
  "SHAMAN/restoration":     ["Farseer", "Totemic"],
  "WARLOCK/affliction":     ["Hellcaller", "Soul Harvester"],
  "WARLOCK/demonology":     ["Diabolist", "Soul Harvester"],
  "WARLOCK/destruction":    ["Diabolist", "Hellcaller"],
  "WARRIOR/arms":           ["Colossus", "Slayer"],
  "WARRIOR/fury":           ["Mountain Thane", "Slayer"],
  "WARRIOR/protection":     ["Mountain Thane", "Colossus"],
};

export function heroesForSpec(e: SpecEntry): readonly string[] {
  return HERO_TALENTS_BY_SPEC[`${e.class}/${e.spec}`] ?? [];
}
