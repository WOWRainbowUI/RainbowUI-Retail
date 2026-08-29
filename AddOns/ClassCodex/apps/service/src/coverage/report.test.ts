import { describe, expect, it } from "vitest";
import { buildCoverageReport } from "./report.js";

const base = { source: "icyveins", schemaVersion: 1, generatedAt: "2026-07-28T00:00:00Z" } as const;
const issue = (r: ReturnType<typeof buildCoverageReport>, spec: string, category?: string) =>
  r.issues.find((i) => i.spec === spec && i.category === category);

describe("buildCoverageReport", () => {
  it("lists absent specs and missing expected categories as issues", () => {
    const file = {
      meta: base,
      data: { MAGE: { arcane: { gear: { all: { raid: [{ slot: "Head", itemId: 1 }] } }, links: { bis: "x" } } } },
    };
    const r = buildCoverageReport("icyveins", "retail", file);

    expect(r.schemaValid).toBe(true);
    expect(r.specsCovered).toBe(1);
    expect(r.specsTotal).toBe(40);
    // present category → no issue; unpopulated expected category → missing
    expect(issue(r, "MAGE/arcane", "gear")).toBeUndefined();
    expect(issue(r, "MAGE/arcane", "talents")?.kind).toBe("missing");
    // the other 39 specs are absent
    expect(r.issues.filter((i) => i.kind === "absent")).toHaveLength(39);
    expect(r.ok).toBe(false);
  });

  it("a 1-step rotation is present, not judged — no thinness heuristic", () => {
    const rot = (n: number) => ({ all: { all: { steps: Array.from({ length: n }, (_, i) => `s${i}`) } } });
    const file = { meta: base, data: { MAGE: { frost: { rotation: rot(1) } } } };
    const r = buildCoverageReport("icyveins", "retail", file);
    expect(issue(r, "MAGE/frost", "rotation")).toBeUndefined(); // has data → no issue
  });

  it("treats a present-but-empty category as missing", () => {
    const file = { meta: base, data: { MAGE: { fire: { gear: { all: { raid: [] } } } } } };
    const r = buildCoverageReport("icyveins", "retail", file);
    expect(issue(r, "MAGE/fire", "gear")?.kind).toBe("missing");
  });

  it("reports schema-invalid data without throwing", () => {
    const file = { meta: base, data: { MAGE: { notaspec: { gear: { all: { raid: [] } } } } } };
    const r = buildCoverageReport("icyveins", "retail", file);
    expect(r.schemaValid).toBe(false);
    expect(r.schemaErrors.length).toBeGreaterThan(0);
    expect(r.ok).toBe(false);
  });

  it("has no category issues for an unknown source (nothing expected)", () => {
    const file = { meta: { ...base, source: "ugg" }, data: {} };
    const r = buildCoverageReport("mystery", "retail", file);
    expect(r.issues.every((i) => i.kind === "absent")).toBe(true); // only absent specs, no category checks
  });
});
