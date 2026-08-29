// The Icy Veins source file. Same shape as every source — it just fills the
// categories IV has and OMITS the rest: IV provides gear (bonusIDs + drop
// source, no ilvl), trinket tier rankings, talents, statPriority, rotation,
// consumables, crafting (embellishments + crafted items), and Omnium Folio rune
// recommendations; it has no gems or statTargets (u.gg only). IV builds carry no
// hero split, so everything is keyed under the `all` hero.
import type { SourceFile } from "../schema/normalized.js";

export const example: SourceFile = {
  meta: { source: "icyveins", schemaVersion: 1, generatedAt: "2026-07-14T09:30:00Z" },
  data: {
    HUNTER: {
      "beast-mastery": {
        links: {
          bis: "https://www.icy-veins.com/wow/beast-mastery-hunter-pve-dps-gear-best-in-slot",
          talents: "https://www.icy-veins.com/wow/beast-mastery-hunter-pve-dps-spec-builds-talents",
          leveling: "https://www.icy-veins.com/wow/beast-mastery-hunter-leveling-guide",
        },

        gear: {
          all: {
            raid: [
              { slot: "Head", itemId: 249988, bonusIDs: [12806], source: "Catalyst or Lightblinded Vanguard" },
              { slot: "Neck", itemId: 268291, bonusIDs: [13786], source: "Rotmire" },
              { slot: "Back", itemId: 239656, bonusIDs: [12214, 13622], source: "Crafted by Tailoring" },
            ],
          },
        },

        talents: {
          all: {
            raid: [{ export: "C0PA-iv-st", label: "Single Target" }],
            mplus: [{ export: "C0PA-iv-mplus", label: "Mythic+" }],
            leveling: [{ export: "C0PA-iv-lvl", label: "Leveling" }], // final leveling build
          },
        },

        trinkets: { all: { all: [{ itemId: 249346, tier: "S" }, { itemId: 249343, tier: "A" }] } },

        statPriority: { all: { raid: { primary: "Agility", secondary: [["mastery"], ["haste", "crit"], ["versatility"]] } } },

        omniumFolio: {
          all: {
            all: [
              { spellId: 1279596, label: "Week 1" },
              { spellId: 1279604, label: "Week 2", note: "group play" },
              { spellId: 1279603, label: "Week 2", note: "solo play" },
            ],
          },
        },

        rotation: {
          all: {
            "single-target": { steps: ["Cast {19574} on cooldown.", "Cast {217200} on cooldown."] },
            aoe: { steps: ["Cast {1264359} on cooldown.", "Cast {19574} on cooldown."] },
          },
        },

        consumables: {
          all: {
            all: { flask: [241322], potions: [241308, 241292], food: [255846], augmentRune: [259085] },
          },
        },

        crafting: { all: { raid: { crafts: [], embellishments: [245876, 240167] } } },
      },

      // second spec, trimmed — the file spans every class/spec
      marksmanship: {
        rotation: { all: { "single-target": { steps: ["Cast {19434} on cooldown."] } } },
      },
    },
  },
};
