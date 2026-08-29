// Status routes over a stub provider (no network): coverage/validity per source.
import { describe, expect, it } from "vitest";
import type { SourceFile } from "../schema/index.js";
import { register } from "../sources/index.js";
import { SourceCache } from "../cache.js";
import { createApp } from "./app.js";

const fixture: SourceFile = {
  meta: { source: "icyveins", schemaVersion: 1, generatedAt: "2026-07-28T00:00:00Z" },
  data: {
    MAGE: {
      arcane: {
        gear: { all: { raid: [{ slot: "Head", itemId: 1 }] } },
        trinkets: { all: { all: [{ itemId: 2, tier: "S" }] } },
        links: { bis: "https://iv/bis" },
      },
    },
  },
};

register({ name: "icyveins", async ingest() { return fixture; } });

const app = createApp(new SourceCache(60_000));
const req = (path: string) => app.fetch(new Request(`http://x${path}`));

describe("status routes", () => {
  // Just proves the report flows through the route; coverage semantics are owned
  // by coverage/report.test.ts.
  it("serves a source's coverage report", async () => {
    const res = await req("/retail/status/icyveins");
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body.source).toBe("icyveins");
    expect(body.schemaValid).toBe(true);
    expect(Array.isArray(body.issues)).toBe(true);
  });

  it("404s a source that isn't wired", async () => {
    const res = await req("/retail/status/ugg");
    expect(res.status).toBe(404);
    expect((await res.json()).error).toContain("not wired");
  });

  it("404s an unknown flavor", async () => {
    expect((await req("/classic/status/icyveins")).status).toBe(404);
  });
});
