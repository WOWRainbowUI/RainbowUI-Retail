import { describe, expect, it } from "vitest";
import { example } from "../examples/ugg.example.js";
import { example as icyveinsExample } from "../examples/icyveins.example.js";
import fullExample from "../examples/full.example.json" with { type: "json" };
import { SourceFile } from "./normalized.js";
import { contextChain, resolve } from "./resolve.js";
import { slugify } from "./enums.js";
import { HERO_SLUGS, REGISTRY, SPEC_COUNT } from "./registry.js";

const bm = example.data.HUNTER!["beast-mastery"]!;

describe("SourceFile schema", () => {
  it("accepts the worked example", () => {
    expect(() => SourceFile.parse(example)).not.toThrow();
  });

  it("accepts the Icy Veins source file", () => {
    expect(() => SourceFile.parse(icyveinsExample)).not.toThrow();
  });

  it("accepts the all-fields reference (full.example.json)", () => {
    expect(() => SourceFile.parse(fullExample)).not.toThrow();
  });

  it("rejects a non-slug spec key", () => {
    // format-only: "beastmastery" would pass (slugify is the drift defense at
    // ingestion); an uppercase/spaced key is what the schema rejects.
    const bad = { ...example, data: { HUNTER: { "Beast Mastery": bm } } };
    expect(SourceFile.safeParse(bad).success).toBe(false);
  });

  it("rejects an invalid context key", () => {
    const bad = { ...example, data: { HUNTER: { "beast-mastery": { statTargets: { all: { Mythicplus: {} } } } } } };
    expect(SourceFile.safeParse(bad).success).toBe(false);
  });

  it("rejects an unknown gear slot", () => {
    const bad = { ...example, data: { HUNTER: { "beast-mastery": { gear: { all: { mplus: [{ slot: "Tabard", itemId: 1 }] } } } } } };
    expect(SourceFile.safeParse(bad).success).toBe(false);
  });

  it("rejects a hero that isn't valid for the spec", () => {
    // sentinel is a Marksmanship/Survival hero, not Beast Mastery
    const bad = { ...example, data: { HUNTER: { "beast-mastery": { statTargets: { sentinel: { raid: { crit: 1 } } } } } } };
    expect(SourceFile.safeParse(bad).success).toBe(false);
  });
});

describe("registry", () => {
  it("has 13 classes and 40 specs, two heroes each", () => {
    expect(Object.keys(REGISTRY)).toHaveLength(13);
    expect(SPEC_COUNT).toBe(40);
    for (const specs of Object.values(REGISTRY)) {
      for (const heroes of Object.values(specs)) expect(heroes).toHaveLength(2);
    }
  });

  it("slugify maps every source-label variant to a canonical hero slug", () => {
    const cases: [string, string][] = [
      ["Dark Ranger", "dark-ranger"],
      ["DarkRanger", "dark-ranger"],
      ["PackLeader", "pack-leader"],
      ["Fel-Scarred", "fel-scarred"],
      ["Elune's Chosen", "elunes-chosen"],
      ["San'layn", "sanlayn"],
      ["RiderOfTheApocalypse", "rider-of-the-apocalypse"],
    ];
    for (const [raw, slug] of cases) {
      expect(slugify(raw)).toBe(slug);
      expect(HERO_SLUGS.has(slug)).toBe(true);
    }
  });
});

describe("slugify", () => {
  it("canonicalizes labels", () => {
    expect(slugify("Beast Mastery")).toBe("beast-mastery");
    expect(slugify("Pack Leader")).toBe("pack-leader");
  });
});

describe("contextChain", () => {
  it("walks specific -> parent -> all", () => {
    expect(contextChain("raid:3009")).toEqual(["raid:3009", "raid", "all"]);
    expect(contextChain("mplus")).toEqual(["mplus", "all"]);
    expect(contextChain("all")).toEqual(["all"]);
  });
});

describe("resolve", () => {
  it("inherits the parent for a per-boss context", () => {
    // raid:3009 only overrides Trinket 1; the rest resolves up to `raid`.
    const boss = resolve(bm.gear, "all", "raid:3009");
    expect(boss?.context).toBe("raid:3009");
    const generalGear = resolve(bm.statTargets, "all", "raid:3009");
    expect(generalGear?.context).toBe("raid"); // statTargets has no per-boss entry -> parent
  });

  it("generalizes the hero axis to all", () => {
    // statTargets is hero-agnostic (keyed under "all")
    const hit = resolve(bm.statTargets, "pack-leader", "mplus");
    expect(hit?.hero).toBe("all");
    expect(hit?.value.mastery).toBe(1159);
  });

  it("prefers a hero-specific entry when present", () => {
    const hit = resolve(bm.statPriority, "pack-leader", "mplus");
    expect(hit?.hero).toBe("pack-leader");
  });

  it("returns undefined when nothing matches", () => {
    expect(resolve(bm.rotation, "all", "single-target")).toBeUndefined(); // u.gg has no rotation
  });
});
