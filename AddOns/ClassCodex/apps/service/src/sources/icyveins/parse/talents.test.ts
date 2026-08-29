import { describe, expect, it } from "vitest";
import { parseIcyVeinsTalents } from "./talents.js";

const build = (title: string, code: string) => `
  <details class="export-string">
    <summary><span class="export-string__title">${title}</span></summary>
    <div class="export-string__body"><span class="export-string__code">${code}</span></div>
  </details>`;

describe("parseIcyVeinsTalents", () => {
  it("extracts export strings and strips spec/hero noise from the label", () => {
    const html = build("Arcane Mage Single Target", "C4DAAAA") + build("Spellslinger AoE", "C4DBBBB");
    const out = parseIcyVeinsTalents(html, { specNames: ["Arcane Mage"], heroes: ["Spellslinger", "Sunfury"] });
    expect(out).toEqual([
      { context: "Raid", buildLabel: "Single Target", exportString: "C4DAAAA" },
      { context: "Mythic+", buildLabel: "AoE", exportString: "C4DBBBB" },
    ]);
  });

  it("drops builds with a non-base64 export string and dedupes repeats", () => {
    const html = build("Bad", "not valid!!") + build("A", "CODE1") + build("B", "CODE1");
    const out = parseIcyVeinsTalents(html);
    expect(out.map((b) => b.exportString)).toEqual(["CODE1"]); // invalid dropped, dup collapsed
  });

  it("forces Leveling context/label in leveling mode", () => {
    const out = parseIcyVeinsTalents(build("Whatever Title", "LVL1"), { leveling: true });
    expect(out).toEqual([{ context: "Leveling", buildLabel: "Leveling", exportString: "LVL1" }]);
  });
});
