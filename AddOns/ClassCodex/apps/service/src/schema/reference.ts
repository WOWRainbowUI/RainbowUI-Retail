// Source-agnostic reference data (resolved lookups, not owned by any source).
import { z } from "zod";

export const REFERENCE_SCHEMA_VERSION = 1;

export const ReferenceFile = z
  .object({
    meta: z.object({ schemaVersion: z.number().int() }).strict(),
    // itemId (string key in JSON) -> effect spellIds
    embellishmentEffects: z.record(z.string(), z.object({ spellIds: z.array(z.number().int()) }).strict()),
    // u.gg encounter id -> display name, for labelling per-encounter contexts (mplus:<id> / raid:<id>)
    encounters: z
      .object({
        dungeons: z.record(z.string(), z.string()),
        bosses: z.record(z.string(), z.string()),
      })
      .strict()
      .optional(),
    // hero-talent slug -> display name (slugs are lossy; the UI needs the real name)
    heroNames: z.record(z.string(), z.string()).optional(),
  })
  .strict();

export type ReferenceFile = z.infer<typeof ReferenceFile>;
