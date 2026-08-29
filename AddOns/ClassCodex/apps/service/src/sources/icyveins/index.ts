// The Icy Veins source provider. ingest() fans out across all 40 specs (bounded
// concurrency), fetches each spec's pages through the Cloudflare-bypass fetch
// layer, parses them, and assembles a schema-valid SourceFile. A page that fails
// is a per-spec miss (recorded, not fatal); a total gear wipe throws so the cache
// serves last-good / 503s instead of committing an empty file.
import type { SourceFile } from "../../schema/index.js";
import type { Flavor } from "../../config.js";
import type { SourceProvider } from "../types.js";
import { fetchText, mapPool } from "./fetch.js";
import {
  SPECS,
  heroesForSpec,
  buildBisUrl,
  buildTalentsUrl,
  buildStatPriorityUrl,
  buildConsumablesUrl,
  buildLevelingUrl,
  buildRotationUrl,
  type SpecEntry,
} from "./urls.js";
import { parseIcyVeinsBisGear } from "./parse/gear.js";
import { parseIcyVeinsTrinkets } from "./parse/trinkets.js";
import { parseIcyVeinsStats } from "./parse/stats.js";
import { parseIcyVeinsConsumables } from "./parse/consumables.js";
import { parseIcyVeinsEmbellishments, parseIcyVeinsCraftedItems } from "./parse/crafting.js";
import { parseIcyVeinsTalents } from "./parse/talents.js";
import { parseIcyVeinsRotation } from "./parse/rotation.js";
import { parseIcyVeinsOmnium } from "./parse/omnium.js";
import { buildSourceFile, emptyParsedSpec, type ParsedSpec } from "./build.js";
import { loadEmbellishmentIds } from "./embellishments-seed.js";

const CONCURRENCY = Math.max(1, Number(process.env.ICYVEINS_CONCURRENCY) || 4);

async function scrapeSpec(entry: SpecEntry): Promise<ParsedSpec> {
  const [bisHtml, talentsHtml, levelingHtml, statsHtml, consHtml, rotationHtml] = await Promise.all([
    fetchText(buildBisUrl(entry)),
    fetchText(buildTalentsUrl(entry)),
    fetchText(buildLevelingUrl(entry)),
    fetchText(buildStatPriorityUrl(entry)),
    fetchText(buildConsumablesUrl(entry)),
    fetchText(buildRotationUrl(entry)),
  ]);

  const heroes = heroesForSpec(entry);
  const specNames = [entry.label];

  try {
    return {
      entry,
      bisGear: bisHtml ? parseIcyVeinsBisGear(bisHtml) : [],
      trinkets: bisHtml ? parseIcyVeinsTrinkets(bisHtml) : [],
      embellishments: bisHtml ? parseIcyVeinsEmbellishments(bisHtml) : [],
      craftedItems: bisHtml ? parseIcyVeinsCraftedItems(bisHtml) : [],
      statPriority: statsHtml ? parseIcyVeinsStats(statsHtml) : null,
      consumables: consHtml ? parseIcyVeinsConsumables(consHtml) : null,
      talents: talentsHtml ? parseIcyVeinsTalents(talentsHtml, { specNames, heroes }) : [],
      levelingTalents: levelingHtml
        ? parseIcyVeinsTalents(levelingHtml, { specNames, heroes, leveling: true })
        : [],
      rotation: rotationHtml ? parseIcyVeinsRotation(rotationHtml) : [],
      // Omnium Folio lives in a section of the (already-fetched) talents page.
      omnium: talentsHtml ? parseIcyVeinsOmnium(talentsHtml) : [],
      bisUrl: bisHtml ? buildBisUrl(entry) : undefined,
      talentsUrl: talentsHtml ? buildTalentsUrl(entry) : undefined,
      levelingUrl: levelingHtml ? buildLevelingUrl(entry) : undefined,
    };
  } catch (err) {
    // A malformed page must degrade this one spec to empty (a recorded miss), not
    // reject and sink the whole 40-spec ingest — per the fetch layer's contract.
    console.error(`icyveins: parse failed for ${entry.class}/${entry.spec}:`, err);
    return emptyParsedSpec(entry);
  }
}

export class IcyVeinsProvider implements SourceProvider {
  readonly name = "icyveins" as const;

  async ingest(_flavor: Flavor): Promise<SourceFile> {
    const generatedAt = new Date().toISOString();
    const parsed = await mapPool(SPECS, CONCURRENCY, scrapeSpec);

    // No coverage threshold here — whatever ingested is served, and the /status
    // route + per-page fetch logs make any gap visible with its cause. The only
    // hard refusal is the cache's total-empty backstop (a literal data:{} wipe).
    // Commit-safety (don't ship a regression) is the consumer/pipeline's job.
    const withGear = parsed.filter((p) => p.bisGear.length > 0).length;
    console.log(`icyveins ingest: ${withGear}/${parsed.length} specs with gear`);

    return buildSourceFile(parsed, generatedAt, loadEmbellishmentIds());
  }
}
