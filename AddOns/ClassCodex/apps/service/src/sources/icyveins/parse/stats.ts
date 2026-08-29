// Stat priority. IV renders a `.stat-priority-widget-inner` with `.stat-container`
// entries joined by separators (`=` tie / `>` step). Falls back to prose ordering
// (first mention within the priority section) when the widget is absent.
import { load } from "cheerio";
import type { StatPriority } from "../types.js";

const SECONDARY: { key: string; name: string; re: RegExp }[] = [
  { key: "haste", name: "Haste", re: /\bhaste\b/i },
  { key: "mastery", name: "Mastery", re: /\bmastery\b/i },
  { key: "crit", name: "Crit", re: /\bcrit(?:ical strike)?\b/i },
  { key: "versatility", name: "Versatility", re: /\bversatility\b/i },
];

function parseProse(html: string): StatPriority | null {
  const $ = load(html);
  const heading = $('[id$="stat-priority"]').first();
  if (heading.length === 0) return null;
  let text = "";
  const node = heading.parent().length ? heading.parent().nextAll().slice(0, 4) : heading.nextAll().slice(0, 4);
  node.each((_, el) => {
    text += " " + $(el).text();
  });
  const seen = SECONDARY.map((s) => ({ ...s, at: text.search(s.re) }))
    .filter((s) => s.at >= 0)
    .sort((a, b) => a.at - b.at);
  if (seen.length < 2) return null;
  return { stats: seen.map((s) => [s.name]) };
}

export function parseIcyVeinsStats(html: string): StatPriority | null {
  const $ = load(html);
  const widget = $(".stat-priority-widget-inner").first();
  if (widget.length === 0) return parseProse(html);

  const stats: string[][] = [];
  let tieNext = false;

  widget.children().each((_, el) => {
    const node = $(el);
    const cls = node.attr("class") || "";
    if (/\bstat-container\b/.test(cls)) {
      const name = node.find(".stat-name").first().text().trim();
      if (!name) return;
      if (tieNext && stats.length > 0) stats[stats.length - 1].push(name);
      else stats.push([name]);
      tieNext = false;
    } else if (/\bstat-separator\b/.test(cls)) {
      tieNext = (node.find(".separator-icon").attr("class") || "").includes("true");
    }
  });

  if (stats.length === 0) return null;
  return { stats };
}
