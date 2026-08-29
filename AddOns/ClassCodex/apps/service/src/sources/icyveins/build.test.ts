import { describe, expect, it } from "vitest";
import { buildSourceFile, emptyParsedSpec } from "./build.js";
import { SPECS } from "./urls.js";

const emptyParsed = (spec: string) => emptyParsedSpec(SPECS.find((s) => s.spec === spec)!);

describe("buildSourceFile", () => {
  it("maps gear tabs, trinket tiers, crafts and rotation into the schema", () => {
    const p = emptyParsed("devourer");
    p.bisGear = [
      { label: "Raid", slots: [
        { slot: "Helm", item: { itemId: 100, name: "Hat", bonusIDs: [1] }, source: "Boss" },
        { slot: "Ring", item: { itemId: 200, name: "Ring A" } },
        { slot: "Ring", item: { itemId: 201, name: "Ring B" } },
      ] },
    ];
    p.trinkets = [
      { itemId: 300, name: "A", tier: "S" },
      { itemId: 301, name: "B", tier: "A" },
    ];
    p.rotation = [{ context: "Single Target", steps: ["Cast {123}."] }];
    p.bisUrl = "https://iv/bis";

    const file = buildSourceFile([p], "2026-07-28T00:00:00Z");
    const dd = file.data.DEMONHUNTER!.devourer!;

    // gear: positional ring slots + bonusIDs + source preserved
    expect(dd.gear!.all.raid).toEqual([
      { slot: "Head", itemId: 100, bonusIDs: [1], source: "Boss" },
      { slot: "Finger 1", itemId: 200 },
      { slot: "Finger 2", itemId: 201 },
    ]);
    // trinkets: tier ranking under all/all
    expect(dd.trinkets!.all.all).toEqual([
      { itemId: 300, tier: "S" },
      { itemId: 301, tier: "A" },
    ]);
    // rotation: playstyle context mapping
    expect(dd.rotation!.all["single-target"]).toEqual({ steps: ["Cast {123}."] });
    expect(dd.links).toEqual({ bis: "https://iv/bis" });
  });

  it("splits crafted items from embellishments (crafts = crafted minus embellishments)", () => {
    const p = emptyParsed("arcane");
    p.embellishments = [{ itemId: 1, name: "Emb" }];
    p.craftedItems = [
      { itemId: 1, name: "Emb" }, // also appears in the crafted section — must not double-count
      { itemId: 2, name: "Boots" },
      { itemId: 3, name: "Cane" },
    ];
    const file = buildSourceFile([p], "2026-07-28T00:00:00Z");
    const craft = file.data.MAGE!.arcane!.crafting!.all.all;
    expect(craft.embellishments).toEqual([1]);
    expect(craft.crafts).toEqual([2, 3]);
  });

  it("splits by the reagent flag: reagents → embellishments, embellished gear → crafts", () => {
    const p = emptyParsed("arcane");
    // IV mixes them: lists embellished gear (100) as an embellishment, and a reagent
    // (200) among the crafted items. The reagent set is the ground truth.
    p.embellishments = [{ itemId: 100, name: "Embellished Cloak" }];
    p.craftedItems = [
      { itemId: 200, name: "Applied Reagent" },
      { itemId: 300, name: "Plain Crafted Gear" },
    ];
    const file = buildSourceFile([p], "2026-07-28T00:00:00Z", new Set([200])); // only 200 is a reagent
    const c = file.data.MAGE!.arcane!.crafting!.all.all;
    expect(c.embellishments).toEqual([200]); // the reagent
    expect([...c.crafts].sort((a, b) => a - b)).toEqual([100, 300]); // embellished gear + plain gear
  });

  it("without the seed, trusts IV's explicit embellishments as-is", () => {
    const p = emptyParsed("arcane");
    p.embellishments = [{ itemId: 1, name: "Emb" }];
    p.craftedItems = [{ itemId: 1, name: "Emb" }, { itemId: 2, name: "Gear" }];
    const c = buildSourceFile([p], "2026-07-28T00:00:00Z").data.MAGE!.arcane!.crafting!.all.all; // no seed
    expect(c.embellishments).toEqual([1]);
    expect(c.crafts).toEqual([2]);
  });

  it("drops non-secondary stats (Intellect) from stat priority", () => {
    const p = emptyParsed("arcane");
    p.statPriority = { stats: [["Intellect"], ["Mastery"], ["Crit. Strike", "Haste"]] };
    const file = buildSourceFile([p], "2026-07-28T00:00:00Z");
    expect(file.data.MAGE!.arcane!.statPriority!.all.all.secondary).toEqual([["mastery"], ["crit", "haste"]]);
  });

  it("maps omnium folio runes under all/all", () => {
    const p = emptyParsed("arcane");
    p.omnium = [
      { spellId: 111, label: "Week 1" },
      { spellId: 222, label: "Week 2", note: "solo play" },
    ];
    const file = buildSourceFile([p], "2026-07-28T00:00:00Z");
    expect(file.data.MAGE!.arcane!.omniumFolio!.all.all).toEqual([
      { spellId: 111, label: "Week 1" },
      { spellId: 222, label: "Week 2", note: "solo play" },
    ]);
  });

  it("resolves gear tab labels to contexts by prefix, incl. season/raid-name suffixes", () => {
    const p = emptyParsed("arcane");
    const slot = { slot: "Helm", item: { itemId: 1, name: "Hat" } };
    p.bisGear = [
      { label: "Overall", slots: [slot] },
      { label: "Mythic+", slots: [slot] },
      { label: "Raid (Manaforge Omega)", slots: [slot] }, // suffix must still map to raid
    ];
    const gear = buildSourceFile([p], "2026-07-28T00:00:00Z").data.MAGE!.arcane!.gear!.all;
    expect(Object.keys(gear).sort()).toEqual(["all", "mplus", "raid"]);
  });

  it("maps talent build contexts and preserves labels", () => {
    const p = emptyParsed("arcane");
    p.talents = [
      { context: "Raid", buildLabel: "Single Target", exportString: "AAAA" },
      { context: "Mythic+", buildLabel: "AoE", exportString: "BBBB" },
      { context: "General", buildLabel: "Generic", exportString: "CCCC" },
    ];
    p.levelingTalents = [{ context: "Leveling", buildLabel: "Leveling", exportString: "DDDD" }];
    const t = buildSourceFile([p], "2026-07-28T00:00:00Z").data.MAGE!.arcane!.talents!.all;
    expect(t.raid).toEqual([{ export: "AAAA", label: "Single Target" }]);
    expect(t.mplus).toEqual([{ export: "BBBB", label: "AoE" }]);
    expect(t.all).toEqual([{ export: "CCCC", label: "Generic" }]); // General → wildcard context
    expect(t.leveling).toEqual([{ export: "DDDD", label: "Leveling" }]);
  });

  it("assigns positional Trinket 1/2 slots (IV doesn't number them)", () => {
    const p = emptyParsed("arcane");
    p.bisGear = [
      { label: "Overall", slots: [
        { slot: "Trinket", item: { itemId: 10, name: "T1" } },
        { slot: "Trinket", item: { itemId: 11, name: "T2" } },
      ] },
    ];
    const gear = buildSourceFile([p], "2026-07-28T00:00:00Z").data.MAGE!.arcane!.gear!.all.all;
    expect(gear.map((g) => g.slot)).toEqual(["Trinket 1", "Trinket 2"]);
  });

  it("omits a spec that produced no data", () => {
    const file = buildSourceFile([emptyParsed("arcane")], "2026-07-28T00:00:00Z");
    expect(file.data.MAGE?.arcane).toBeUndefined();
  });

  it("stamps a content-derived contentHash: stable for identical data, moves when it changes; generatedAt passes through", () => {
    const p = emptyParsed("devourer");
    p.rotation = [{ context: "Single Target", steps: ["Cast {123}."] }];

    const a = buildSourceFile([p], "2026-07-28T00:00:00Z");
    const b = buildSourceFile([p], "2099-01-01T00:00:00Z"); // different build time, same data
    expect(a.meta.contentHash).toBe(b.meta.contentHash); // hash tracks data, not the clock
    expect(a.meta.contentHash).toMatch(/^[0-9a-f]{16}$/);
    expect(a.meta.generatedAt).toBe("2026-07-28T00:00:00Z"); // timestamp is passed through verbatim

    const q = emptyParsed("devourer");
    q.rotation = [{ context: "Single Target", steps: ["Cast {999}."] }];
    expect(buildSourceFile([q], "2026-07-28T00:00:00Z").meta.contentHash).not.toBe(a.meta.contentHash);
  });
});
