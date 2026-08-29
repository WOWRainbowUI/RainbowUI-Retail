// HTTP surface. Thin: resolve flavor + source, hand off to the cache, return the
// rendered lua/json. Change detection is the consumer's job (it `git diff`s what
// it writes), so there's no ETag/hash here — endpoints just serve fresh data.
//
//   GET /health                         liveness (always open)
//   GET /:flavor/index.json             available sources (discovery)
//   GET /:flavor/data/:source.:ext      ext ∈ { lua, json }
//   GET /:flavor/status/:source         coverage/validity for one source
//
// If an API key is configured, everything under /:flavor/* requires it.
import { Hono } from "hono";
import { isFlavor, type Flavor } from "../config.js";
import { getProvider, listSources } from "../sources/index.js";
import { buildCoverageReport } from "../coverage/report.js";
import type { SourceCache } from "../cache.js";

// Ingest a source through the cache and report its coverage/validity. An ingest
// or schema failure is reported as invalid (ok:false) rather than surfaced as a
// 503 — the status route's job is to describe the data, including when it's broken.
async function statusFor(cache: SourceCache, flavor: Flavor, source: string) {
  const provider = getProvider(source);
  if (!provider) return { source, flavor, ok: false, error: "source not wired" };
  try {
    const entry = await cache.get(provider, flavor);
    return buildCoverageReport(source, flavor, JSON.parse(entry.json));
  } catch (err) {
    return { source, flavor, ok: false, schemaValid: false, schemaErrors: [String(err)] };
  }
}

export function createApp(cache: SourceCache, opts: { apiKey?: string } = {}): Hono {
  const app = new Hono();

  app.get("/health", (c) => c.json({ status: "ok" }));

  if (opts.apiKey) {
    app.use("/:flavor/*", async (c, next) => {
      const provided = c.req.header("X-API-Key") ?? c.req.header("Authorization")?.replace(/^Bearer\s+/i, "");
      if (provided !== opts.apiKey) return c.json({ error: "unauthorized" }, 401);
      await next();
    });
  }

  app.get("/:flavor/index.json", (c) => {
    const flavor = c.req.param("flavor");
    if (!isFlavor(flavor)) return c.json({ error: `unknown flavor: ${flavor}` }, 404);
    return c.json({ flavor, sources: listSources() });
  });

  // Coverage/validity for one source: does its data match the schema, and is every
  // category it's expected to carry present for all 40 canonical specs?
  app.get("/:flavor/status/:source", async (c) => {
    const flavor = c.req.param("flavor");
    if (!isFlavor(flavor)) return c.json({ error: `unknown flavor: ${flavor}` }, 404);
    const source = c.req.param("source");
    if (!getProvider(source)) return c.json({ error: `source not wired: ${source}`, available: listSources() }, 404);
    return c.json(await statusFor(cache, flavor as Flavor, source));
  });

  app.get("/:flavor/data/:file", async (c) => {
    const flavor = c.req.param("flavor");
    if (!isFlavor(flavor)) return c.json({ error: `unknown flavor: ${flavor}` }, 404);

    const file = c.req.param("file");
    const dot = file.lastIndexOf(".");
    const source = dot < 0 ? file : file.slice(0, dot);
    const ext = dot < 0 ? "" : file.slice(dot + 1);
    if (ext !== "lua" && ext !== "json") return c.json({ error: "extension must be .lua or .json" }, 404);

    const provider = getProvider(source);
    if (!provider) return c.json({ error: `source not wired: ${source}`, available: listSources() }, 404);

    let entry;
    try {
      entry = await cache.get(provider, flavor as Flavor);
    } catch (err) {
      return c.json({ error: `ingest failed for ${source}`, detail: String(err) }, 503);
    }

    c.header("Cache-Control", "no-cache");
    c.header("Content-Type", ext === "lua" ? "text/plain; charset=utf-8" : "application/json; charset=utf-8");
    return c.body(ext === "lua" ? entry.lua : entry.json);
  });

  return app;
}
