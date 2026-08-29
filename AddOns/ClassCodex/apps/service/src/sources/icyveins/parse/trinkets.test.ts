import { describe, expect, it } from "vitest";
import { parseIcyVeinsTrinkets } from "./trinkets.js";

// Mirrors IV's real structure: an h2#trinkets section with a ranking table inside
// a <details>, each row a tier cell + a cell of item links.
const HTML = `
<div class="heading_container"><h2 id="trinkets">Trinket Recommendations</h2></div>
<p>Some prose with <span class="spell_icon_span"><span data-wowhead="spell=1">A spell</span></span>.</p>
<details>
  <summary>Click for Trinket Rankings</summary>
  <table>
    <tr><th>Ranking</th><th>Trinket</th></tr>
    <tr>
      <td><span><strong>S Tier</strong></span></td>
      <td><ul>
        <li><span class="spell_icon_span"><span class="q4" data-wowhead="item=249346&amp;bonus=12806">Vaelgor's Final Stare</span></span></li>
        <li><span class="spell_icon_span"><span class="q4" data-wowhead="item=249343&amp;bonus=12806">Gaze of the Alnseer</span></span></li>
      </ul></td>
    </tr>
    <tr>
      <td><span><strong>A Tier</strong></span></td>
      <td><ul>
        <li><span class="spell_icon_span"><span class="q4" data-wowhead="item=249809">Locus-Walker's Ribbon</span></span></li>
      </ul></td>
    </tr>
  </table>
</details>
<div class="heading_container"><h2 id="voidcore">Voidcores</h2></div>
`;

describe("parseIcyVeinsTrinkets", () => {
  it("extracts trinkets tagged with their tier letter", () => {
    const out = parseIcyVeinsTrinkets(HTML);
    expect(out).toEqual([
      { itemId: 249346, name: "Vaelgor's Final Stare", tier: "S" },
      { itemId: 249343, name: "Gaze of the Alnseer", tier: "S" },
      { itemId: 249809, name: "Locus-Walker's Ribbon", tier: "A" },
    ]);
  });

  it("ignores the spell link in the section prose (not a trinket)", () => {
    const out = parseIcyVeinsTrinkets(HTML);
    expect(out.some((t) => t.itemId === 1)).toBe(false);
  });

  it("returns [] when there is no trinkets section", () => {
    expect(parseIcyVeinsTrinkets("<p>no trinkets here</p>")).toEqual([]);
  });
});
