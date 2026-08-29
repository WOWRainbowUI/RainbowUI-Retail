import { describe, expect, it } from "vitest";
import { parseIcyVeinsStats } from "./stats.js";

describe("parseIcyVeinsStats", () => {
  it("reads the widget: '=' ties stats into one rank, '>' starts a new rank", () => {
    // Mastery = Haste > Crit  → separator-icon 'true' ties, 'false' steps.
    const html = `
      <div class="stat-priority-widget-inner">
        <div class="stat-container mastery"><span class="stat-name">Mastery</span></div>
        <div class="stat-separator"><span class="separator-icon true"></span></div>
        <div class="stat-container haste"><span class="stat-name">Haste</span></div>
        <div class="stat-separator"><span class="separator-icon false"></span></div>
        <div class="stat-container crit"><span class="stat-name">Crit</span></div>
      </div>`;
    expect(parseIcyVeinsStats(html)).toEqual({ stats: [["Mastery", "Haste"], ["Crit"]] });
  });

  it("falls back to prose order (first mention) when there is no widget", () => {
    const html = `
      <div class="heading_container"><h2 id="stat-priority">Stat Priority</h2></div>
      <p>Haste is best, then Mastery, followed by Crit and finally Versatility.</p>`;
    expect(parseIcyVeinsStats(html)).toEqual({
      stats: [["Haste"], ["Mastery"], ["Crit"], ["Versatility"]],
    });
  });

  it("returns null when neither a widget nor a prose section exists", () => {
    expect(parseIcyVeinsStats("<p>no stats</p>")).toBeNull();
  });
});
