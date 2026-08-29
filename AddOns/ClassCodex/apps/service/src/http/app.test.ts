// Proves the whole path — provider → validate → render → cache → HTTP — with a
// stub provider, so the scaffold is verifiably "ready to wire a source in" even
// though no real source ships yet.
import { describe, expect, it } from "vitest";
import type { SourceFile } from "../schema/index.js";
import { register } from "../sources/index.js";
import { SourceCache } from "../cache.js";
import { createApp } from "./app.js";

const fixture: SourceFile = {
  meta: { source: "ugg", schemaVersion: 1, generatedAt: "2026-07-22T00:00:00Z" },
  data: { MAGE: { frost: { statTargets: { all: { raid: { haste: 700, mastery: 400 } } } } } },
};

let ingestCalls = 0;
register({
  name: "ugg",
  async ingest() {
    ingestCalls++;
    return fixture;
  },
});

// A source that ingests empty (schema-valid) data — must never be served.
register({
  name: "blizzard",
  async ingest() {
    return { meta: { source: "blizzard", schemaVersion: 1, generatedAt: "2026-07-22T00:00:00Z" }, data: {} };
  },
});

const app = createApp(new SourceCache(60_000));
const req = (path: string, init?: RequestInit) => app.fetch(new Request(`http://x${path}`, init));

describe("service http", () => {
  it("serves /health", async () => {
    expect(await (await req("/health")).json()).toEqual({ status: "ok" });
  });

  it("serves lua for a wired source", async () => {
    const res = await req("/retail/data/ugg.lua");
    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("text/plain");
    const body = await res.text();
    expect(body).toContain('ClassCodexSource["ugg"]');
    expect(body).toContain("statTargets");
  });

  it("serves canonical json", async () => {
    const res = await req("/retail/data/ugg.json");
    expect(res.status).toBe(200);
    const body = JSON.parse(await res.text());
    expect(body.meta.source).toBe("ugg");
    expect(body.data.MAGE.frost.statTargets.all.raid.haste).toBe(700);
  });

  it("caches — a second request does not re-ingest within ttl", async () => {
    const before = ingestCalls;
    await req("/retail/data/ugg.lua");
    await req("/retail/data/ugg.json");
    expect(ingestCalls).toBe(before);
  });

  it("lists available sources in the index", async () => {
    const body = await (await req("/retail/index.json")).json();
    expect(body.flavor).toBe("retail");
    expect(body.sources).toContain("ugg");
  });

  it("404s an unwired source and an unknown flavor", async () => {
    expect((await req("/retail/data/icyveins.lua")).status).toBe(404);
    expect((await req("/classic/data/ugg.lua")).status).toBe(404);
  });

  it("503s a source that ingests empty data — never serves a wipe", async () => {
    expect((await req("/retail/data/blizzard.lua")).status).toBe(503);
  });
});

describe("api key", () => {
  const keyed = createApp(new SourceCache(60_000), { apiKey: "secret" });
  const kreq = (path: string, init?: RequestInit) => keyed.fetch(new Request(`http://x${path}`, init));

  it("leaves /health open", async () => {
    expect((await kreq("/health")).status).toBe(200);
  });

  it("401s /:flavor/* without a key", async () => {
    expect((await kreq("/retail/index.json")).status).toBe(401);
    expect((await kreq("/retail/data/ugg.lua")).status).toBe(401);
  });

  it("accepts the key via X-API-Key or Bearer", async () => {
    expect((await kreq("/retail/index.json", { headers: { "X-API-Key": "secret" } })).status).toBe(200);
    expect((await kreq("/retail/index.json", { headers: { Authorization: "Bearer secret" } })).status).toBe(200);
  });

  it("401s a wrong key", async () => {
    expect((await kreq("/retail/index.json", { headers: { "X-API-Key": "nope" } })).status).toBe(401);
  });
});
