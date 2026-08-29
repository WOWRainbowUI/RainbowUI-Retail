// The u.gg source file holds every class/spec. Two shown here — Beast Mastery
// Hunter (both hero talents, a pvp context, a per-boss override, omitted
// categories) and a trimmed Frost Mage — to make the source-level shape clear.
import type { SourceFile } from "../schema/normalized.js";

export const example: SourceFile = {
  meta: { source: "ugg", schemaVersion: 1, generatedAt: "2026-07-14T09:30:00Z" },
  data: {
    HUNTER: {
      "beast-mastery": {
        links: { bis: "https://u.gg/wow/beast-mastery-hunter" },

        gear: {
          all: {
            mplus: [
              { slot: "Head", itemId: 249988, ilvl: 289 },
              { slot: "Neck", itemId: 268291, ilvl: 298 },
              { slot: "Main Hand", itemId: 249279, ilvl: 298 },
            ],
            raid: [
              { slot: "Head", itemId: 249988, ilvl: 285 },
              { slot: "Neck", itemId: 268291, ilvl: 285 },
            ],
            // per-boss override — inherits `raid` for every unlisted slot
            "raid:3009": [{ slot: "Trinket 1", itemId: 249343, ilvl: 285 }],
            "pvp:3v3": [{ slot: "Head", itemId: 249988 }],
          },
        },

        enchants: {
          all: {
            all: {
              Chest: [{ id: 7987, spellId: 1236069 }],
              Legs: [{ id: 8159, spellId: 1243976 }],
              "Main Hand": [{ id: 8039, spellId: 1236095 }],
            },
          },
        },

        gems: { all: { all: [{ primary: 240983, secondary: [240898] }] } },

        trinkets: {
          all: {
            all: [
              { itemId: 193701, tier: "S", pop: 55.4 },
              { itemId: 249343, tier: "S", pop: 31.9 },
            ],
          },
        },

        crafting: { all: { raid: { crafts: [239656, 244584], embellishments: [245876, 240167] } } },

        talents: {
          "pack-leader": {
            mplus: [{ export: "C0PA-pack-mplus", pickrate: 33.3 }],
            "pvp:3v3": [{ export: "C0PA-pack-pvp", honor: [3599, 5444, 3604] }],
          },
          "dark-ranger": {
            raid: [{ export: "C0PA-dr-raid", label: "Single Target" }],
          },
        },

        statPriority: {
          "pack-leader": { mplus: { primary: "Agility", secondary: [["mastery", "crit"], ["haste", "versatility"]] } },
          "dark-ranger": { raid: { primary: "Agility", secondary: [["crit"], ["haste", "mastery"]] } },
        },

        statTargets: {
          all: {
            mplus: { crit: 844, haste: 610, mastery: 1159, versatility: 0 },
            raid: { crit: 554, haste: 748, mastery: 1134, versatility: 93 },
          },
        },
      },
    },
    MAGE: {
      frost: {
        talents: { all: { raid: [{ export: "C4PA-frost-raid", label: "Single Target" }] } },
        statTargets: { all: { raid: { haste: 700, mastery: 400 } } },
      },
    },
  },
};
