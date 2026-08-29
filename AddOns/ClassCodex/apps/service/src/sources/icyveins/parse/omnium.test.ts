import { describe, expect, it } from "vitest";
import { parseIcyVeinsOmnium } from "./omnium.js";

// Mirrors IV's real #omnium section on the spec-builds-talents page: a week-by-week
// list, each rune a spell link, with solo/group alternates in some weeks.
const HTML = `
<div class="heading_container"><h2 id="omnium">Omnium Folio</h2></div>
<p>The Omnium Folio is a new system. I recommend the below.</p>
<ul>
  <li>Week 1: <span class="spell_icon_span"><span class="spell" data-wowhead="spell=1279596">Rune of Void-Touched Orbs</span></span></li>
  <li>Week 2: <span class="spell_icon_span"><span class="spell" data-wowhead="spell=1279604">Rune of Void-Tainted Shell</span></span> for group play, or <span class="spell_icon_span"><span class="spell" data-wowhead="spell=1279603">Rune of Self-Mending</span></span> for solo play</li>
</ul>
<div class="heading_container"><h2 id="rotation">Rotation</h2></div>
`;

describe("parseIcyVeinsOmnium", () => {
  it("extracts week-labelled runes with solo/group notes", () => {
    expect(parseIcyVeinsOmnium(HTML)).toEqual([
      { spellId: 1279596, label: "Week 1" },
      { spellId: 1279604, label: "Week 2", note: "group play" },
      { spellId: 1279603, label: "Week 2", note: "solo play" },
    ]);
  });

  // Balance Druid's page renders the section with NO `id="omnium"` heading — just
  // the intro paragraph + the week list. The fallback must still find the runes.
  it("extracts runes when the section has no id=omnium heading", () => {
    const html = `
      <p>The Omnium Folio is a new system introduced in Midnight.</p>
      <p>We recommend the following bonuses:</p>
      <ul>
        <li>Week 1:<span class="spell_icon_span"><span data-wowhead="spell=111" class="spell">Rune of A</span></span></li>
        <li>Week 2:<span class="spell_icon_span"><span data-wowhead="spell=222" class="spell">Rune of B</span></span></li>
      </ul>`;
    expect(parseIcyVeinsOmnium(html)).toEqual([
      { spellId: 111, label: "Week 1" },
      { spellId: 222, label: "Week 2" },
    ]);
  });

  it("returns [] when there is no omnium section", () => {
    expect(parseIcyVeinsOmnium("<p>no omnium here</p>")).toEqual([]);
  });
});
