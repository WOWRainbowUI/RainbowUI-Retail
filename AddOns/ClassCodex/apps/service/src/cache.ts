// A plain short-TTL cache: a built source is reused for `ttlMs`, then the next
// request rebuilds fresh from upstream. Just enough to keep repeated hits (a run
// touching index + .lua + .json, or manual pokes) from re-fetching upstream every
// time. Deliberately NOT a staleness layer: past the TTL you get fresh data, and
// an ingest failure propagates (→ 503) rather than serving a silently-old copy —
// so the daily Action fails loud instead of committing stale data.
import { SourceFile } from "./schema/index.js";
import { render, type Rendered } from "./render/index.js";
import type { SourceProvider } from "./sources/index.js";
import type { Flavor } from "./config.js";

export class SourceCache {
  private fresh = new Map<string, { at: number; entry: Rendered }>();
  private inflight = new Map<string, Promise<Rendered>>();

  constructor(private readonly ttlMs: number) {}

  async get(provider: SourceProvider, flavor: Flavor): Promise<Rendered> {
    const key = `${flavor}:${provider.name}`;
    const hit = this.fresh.get(key);
    if (hit && Date.now() - hit.at < this.ttlMs) return hit.entry;

    let job = this.inflight.get(key);
    if (!job) {
      job = this.build(provider, flavor, key).finally(() => this.inflight.delete(key));
      this.inflight.set(key, job);
    }
    return job;
  }

  private async build(provider: SourceProvider, flavor: Flavor, key: string): Promise<Rendered> {
    const file = SourceFile.parse(await provider.ingest(flavor)); // validate against the contract; throws → 503
    // Backstop against a data wipe: an empty `data: {}` is schema-valid but would
    // overwrite the addon's file with nothing. Refuse to serve it — a 503 tells
    // the consumer (and us) the source is broken, instead of committing a wipe.
    // Per-source "gutted" thresholds (e.g. "no gear across any spec") live in the
    // provider; this only catches the total-empty case.
    if (Object.keys(file.data).length === 0) {
      throw new Error(`${provider.name} ingested empty data (data: {}) — refusing to serve a wipe`);
    }
    const entry = render(file);
    this.fresh.set(key, { at: Date.now(), entry });
    return entry;
  }
}
