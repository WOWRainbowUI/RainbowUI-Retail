ClassCodexUggStats = ClassCodexUggStats or {}
ClassCodexUggStats["MAGE"] = {
  ["arcane"] = {
    label = "Arcane Mage",
    contexts = {
      ["傳奇+"] = {
        { hero = "Spellslinger", primary = "Intellect", tier = "", pickrate = 0.00532, stats = { { "臨機應變" }, { "精通", "加速", "致命一擊" } }, minor = { { "Speed", "Avoidance", "Leech" } } },
        { hero = "Sunfury", primary = "Intellect", tier = "", pickrate = 0.00017, stats = { { "臨機應變" }, { "精通", "加速", "致命一擊" } }, minor = { { "Speed", "Avoidance", "Leech" } } },
      },
      ["團隊"] = {
        { hero = "Spellslinger", primary = "Intellect", tier = "", pickrate = 0.00575, stats = { { "臨機應變" }, { "精通", "加速", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Sunfury", primary = "Intellect", tier = "", pickrate = 0.00012, stats = { { "臨機應變" }, { "精通", "加速", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
    },
  },
  ["fire"] = {
    label = "Fire Mage",
    contexts = {
      ["傳奇+"] = {
        { hero = "Frostfire", primary = "Intellect", tier = "", pickrate = 0.00022, stats = { { "加速" }, { "精通" }, { "臨機應變", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Sunfury", primary = "Intellect", tier = "", pickrate = 0.00515, stats = { { "加速" }, { "精通" }, { "臨機應變", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
      ["團隊"] = {
        { hero = "Frostfire", primary = "Intellect", tier = "", pickrate = 0.00036, stats = { { "加速" }, { "臨機應變", "精通", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Sunfury", primary = "Intellect", tier = "", pickrate = 0.00575, stats = { { "加速" }, { "臨機應變", "精通", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
    },
  },
  ["frost"] = {
    label = "Frost Mage",
    contexts = {
      ["傳奇+"] = {
        { hero = "Frostfire", primary = "Intellect", tier = "", pickrate = 0.00100, stats = { { "致命一擊", "精通" }, { "加速", "臨機應變" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Spellslinger", primary = "Intellect", tier = "", pickrate = 0.06235, stats = { { "致命一擊", "精通" }, { "加速", "臨機應變" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
      ["團隊"] = {
        { hero = "Frostfire", primary = "Intellect", tier = "", pickrate = 0.00054, stats = { { "致命一擊" }, { "精通" }, { "加速", "臨機應變" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Spellslinger", primary = "Intellect", tier = "", pickrate = 0.06139, stats = { { "致命一擊" }, { "精通" }, { "加速", "臨機應變" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
    },
  },
}
