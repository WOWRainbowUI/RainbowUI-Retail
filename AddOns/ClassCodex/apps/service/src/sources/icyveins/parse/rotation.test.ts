import { describe, expect, it } from "vitest";
import { parseIcyVeinsRotation } from "./rotation.js";

const li = (id: string, text: string) =>
  `<li><span data-wowhead="spell=${id}">${text}</span></li>`;

describe("parseIcyVeinsRotation", () => {
  it("splits Single Target / AoE sections (pass 1)", () => {
    const html = `
      <h3>Single Target Rotation</h3>
      <ol>${li("10", "A")}${li("11", "B")}</ol>
      <h3>AoE Rotation</h3>
      <ol>${li("20", "C")}</ol>`;
    const out = parseIcyVeinsRotation(html);
    expect(out).toEqual([
      { context: "Single Target", steps: ["{10}", "{11}"] },
      { context: "AoE", steps: ["{20}"] },
    ]);
  });

  // Regression for the Blood-DK layout: an h2 guide title (which also contains the
  // word "Rotation") sits above a 1-line intro list, and the real priority is under
  // a dedicated h3 "Rotation". The parser must pick the dedicated section, not the
  // intro list under the guide title (and not the Opener).
  it("prefers a dedicated 'Rotation' heading over the guide title's intro list", () => {
    const html = `
      <div class="heading_container"><h2 id="g">Blood Death Knight Gameplay and Rotation Guide</h2></div>
      <ul>${li("1", "one-line intro")}</ul>
      <div class="heading_container"><h3 id="opener">Opener</h3></div>
      <ol>${li("2", "open a")}${li("3", "open b")}</ol>
      <div class="heading_container"><h3 id="rotation">Rotation</h3></div>
      <ol>${li("10", "X")}${li("11", "Y")}${li("12", "Z")}</ol>
      <div class="heading_container"><h3 id="prep">Preparing for Reaper's Mark</h3></div>
      <div class="heading_container"><h2 id="mech">Class and Spec Mechanics Explained</h2></div>`;
    const out = parseIcyVeinsRotation(html);
    expect(out).toEqual([{ context: "Rotation", steps: ["{10}", "{11}", "{12}"] }]);
  });

  it("still marks a spell link that carries extra params (spell=123&bonus=…)", () => {
    const html = `<h3>Rotation</h3><ol><li><span data-wowhead="spell=999&amp;ilvl=600">Cast</span></li></ol>`;
    expect(parseIcyVeinsRotation(html)).toEqual([{ context: "Rotation", steps: ["{999}"] }]);
  });

  it("returns [] when no classifiable rotation list exists", () => {
    expect(parseIcyVeinsRotation("<h3>Cooldowns</h3><ol><li>no spell</li></ol>")).toEqual([]);
  });
});
