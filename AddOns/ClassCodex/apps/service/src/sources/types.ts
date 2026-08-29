// The one abstraction the whole service hangs off. A source knows *how* to turn
// its upstream (u.gg CDN, Icy Veins HTML, the bnet API…) into a schema-valid
// SourceFile; nothing else in the service knows or cares which source it is.
import type { SourceFile } from "../schema/index.js";
import type { Flavor } from "../config.js";

export interface SourceProvider {
  /** Must be a value in the schema's SOURCES enum (ugg | icyveins | blizzard). */
  readonly name: SourceFile["meta"]["source"];
  /** Fetch + normalize into a SourceFile. Throwing is fine — the cache serves last-good. */
  ingest(flavor: Flavor): Promise<SourceFile>;
}
