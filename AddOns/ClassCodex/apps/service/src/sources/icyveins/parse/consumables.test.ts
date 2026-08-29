import { describe, expect, it } from "vitest";
import { parseIcyVeinsConsumables } from "./consumables.js";

const ids = (refs: { itemId: number }[] | undefined) => (refs ?? []).map((r) => r.itemId);

describe("parseIcyVeinsConsumables", () => {
  it("categorises the flat 'Optimal Consumables' list by its <li> lead labels", () => {
    const html = `
      <div class="heading_container"><h2 id="optimal-consumables">Optimal Consumables</h2></div>
      <ul>
        <li>Flask: <span data-wowhead="item=100">Flask of X</span></li>
        <li>Combat Potion: <span data-wowhead="item=200">Potion of Y</span></li>
        <li>Food: <span data-wowhead="item=300">Grand Feast</span></li>
        <li>Augment Rune: <span data-wowhead="item=400">Rune</span></li>
      </ul>
      <div class="heading_container"><h2 id="next">Next</h2></div>`;
    const c = parseIcyVeinsConsumables(html)!;
    expect(ids(c.flask)).toEqual([100]);
    expect(ids(c.potions)).toEqual([200]);
    expect(ids(c.food)).toEqual([300]);
    expect(ids(c.augmentRune)).toEqual([400]);
  });

  it("reads the legacy per-heading layout (id=flask/potions/food-buff)", () => {
    const html = `
      <div class="heading_container"><h3 id="flask">Flasks</h3></div>
      <p><span data-wowhead="item=11">Flask</span></p>
      <div class="heading_container"><h3 id="potions">Potions</h3></div>
      <p><span data-wowhead="item=22">Potion</span></p>
      <div class="heading_container"><h3 id="food-buff">Food</h3></div>
      <p><span data-wowhead="item=33">Feast</span></p>`;
    const c = parseIcyVeinsConsumables(html)!;
    expect(ids(c.flask)).toEqual([11]);
    expect(ids(c.potions)).toEqual([22]);
    expect(ids(c.food)).toEqual([33]);
  });

  it("returns null when no consumables are present", () => {
    expect(parseIcyVeinsConsumables("<p>nothing here</p>")).toBeNull();
  });
});
