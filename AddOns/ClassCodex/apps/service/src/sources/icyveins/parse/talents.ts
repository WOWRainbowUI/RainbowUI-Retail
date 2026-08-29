// Talent builds from the spec-builds-talents page (and the leveling-guide page).
// Both use the same <details class="export-string"> widget: a title + a Blizzard
// export string. Titles carry spec/class/hero noise we strip to a clean label.
import { load } from "cheerio";
import type { TalentBuild } from "../types.js";

const STOP_WORDS = new Set(["the", "of", "and", "a", "to"]);

function expandStripNames(names: readonly string[]): string[] {
  const out = new Set<string>();
  for (const raw of names) {
    const n = raw.trim();
    if (!n) continue;
    const noApos = n.replace(/'/g, "");
    for (const variant of [n, noApos]) {
      out.add(variant);
      for (const word of variant.split(/[\s'-]+/)) {
        if (word.length >= 4 && !STOP_WORDS.has(word.toLowerCase())) out.add(word);
      }
    }
  }
  return [...out].sort((a, b) => b.length - a.length);
}

function classifyContext(rawTitle: string): string {
  if (/level/i.test(rawTitle)) return "Leveling";
  if (/mythic|\bm\+|aoe|dungeon|cleave/i.test(rawTitle)) return "Mythic+";
  if (/delve/i.test(rawTitle)) return "Delves";
  if (/raid|single[\s-]*target/i.test(rawTitle)) return "Raid";
  return "General";
}

function normalizeTalentTitle(rawTitle: string, stripNames: readonly string[]): { context: string; buildLabel: string } {
  const context = classifyContext(rawTitle);

  let label = rawTitle.replace(/\s+/g, " ").trim();
  for (const name of expandStripNames(stripNames)) {
    const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    label = label.replace(new RegExp(`\\b${escaped}\\b`, "gi"), " ");
  }

  label = label
    .replace(/\blevel\s*\d+\b/gi, " ")
    .replace(/\bmidnight\b/gi, " ")
    .replace(/\bbuilds?\b/gi, " ")
    .replace(/\bleveling\b/gi, " Leveling ");

  label = label
    .replace(/\s+/g, " ")
    .replace(/\s*[-/]\s*(?=\()/g, " ")
    .replace(/\s*[-/]\s*$/g, "")
    .replace(/^\s*[-/]\s*/g, "")
    .replace(/\s*[-/]\s*[-/]\s*/g, " / ")
    .replace(/\s+/g, " ")
    .trim();

  if (!label) label = rawTitle.replace(/\s+/g, " ").trim();
  return { context, buildLabel: label };
}

function findHeroHint(rawTitle: string, heroes: readonly string[]): string | null {
  for (const hero of heroes) {
    for (const token of expandStripNames([hero])) {
      const escaped = token.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      if (new RegExp(`\\b${escaped}\\b`, "i").test(rawTitle)) return hero;
    }
  }
  return null;
}

function disambiguateLabels(items: { build: TalentBuild; hero: string | null }[]): void {
  const groups = new Map<string, typeof items>();
  for (const it of items) {
    const arr = groups.get(it.build.buildLabel) ?? [];
    arr.push(it);
    groups.set(it.build.buildLabel, arr);
  }
  for (const [label, group] of groups) {
    if (group.length < 2) continue;
    const usedHero = new Set<string>();
    let counter = 0;
    for (const it of group) {
      if (it.hero && !usedHero.has(it.hero)) {
        usedHero.add(it.hero);
        it.build.buildLabel = `${label} (${it.hero})`;
      } else {
        counter += 1;
        if (counter > 1) it.build.buildLabel = `${label} (${counter})`;
      }
    }
  }
}

export function parseIcyVeinsTalents(
  html: string,
  opts: { specNames?: readonly string[]; heroes?: readonly string[]; leveling?: boolean } = {},
): TalentBuild[] {
  const $ = load(html);
  const specNames = opts.specNames ?? [];
  const heroes = opts.heroes ?? [];
  const items: { build: TalentBuild; hero: string | null }[] = [];
  const seen = new Set<string>();

  $("details.export-string").each((_, el) => {
    const rawTitle = $(el).find(".export-string__title").first().text().replace(/\s+/g, " ").trim();
    const exportString = $(el).find(".export-string__code").first().text().trim();
    if (!exportString) return;
    if (!/^[A-Za-z0-9+/=]+$/.test(exportString)) return;
    if (seen.has(exportString)) return;
    seen.add(exportString);

    const hero = findHeroHint(rawTitle, heroes);
    const stripNames = hero ? [...specNames, hero] : specNames;
    const { context, buildLabel } = normalizeTalentTitle(rawTitle, stripNames);

    const build: TalentBuild = opts.leveling
      ? { context: "Leveling", buildLabel: "Leveling", exportString }
      : { context, buildLabel: buildLabel || "Build", exportString };
    items.push({ build, hero });
  });

  disambiguateLabels(items);
  return items.map((it) => it.build);
}
