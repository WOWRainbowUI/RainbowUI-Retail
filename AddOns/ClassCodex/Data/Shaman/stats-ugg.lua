ClassCodexUggStats = ClassCodexUggStats or {}
ClassCodexUggStats["SHAMAN"] = {
  ["elemental"] = {
    label = "Elemental Shaman",
    contexts = {
      ["傳奇+"] = {
        { hero = "Farseer", primary = "Intellect", tier = "", pickrate = 0.01988, stats = { { "精通", "致命一擊" }, { "臨機應變" }, { "加速" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Stormbringer", primary = "Intellect", tier = "", pickrate = 0.00897, stats = { { "精通", "致命一擊" }, { "臨機應變" }, { "加速" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
      ["團隊"] = {
        { hero = "Farseer", primary = "Intellect", tier = "", pickrate = 0.00346, stats = { { "精通", "致命一擊" }, { "臨機應變", "加速" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Stormbringer", primary = "Intellect", tier = "", pickrate = 0.02979, stats = { { "精通", "致命一擊" }, { "臨機應變", "加速" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
    },
  },
  ["enhancement"] = {
    label = "Enhancement Shaman",
    contexts = {
      ["傳奇+"] = {
        { hero = "Stormbringer", primary = "Agility", tier = "", pickrate = 0.00914, stats = { { "精通", "加速" }, { "致命一擊", "臨機應變" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Totemic", primary = "Agility", tier = "", pickrate = 0.00388, stats = { { "精通", "加速" }, { "致命一擊", "臨機應變" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
      ["團隊"] = {
        { hero = "Stormbringer", primary = "Agility", tier = "", pickrate = 0.01064, stats = { { "精通", "加速" }, { "致命一擊", "臨機應變" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Totemic", primary = "Agility", tier = "", pickrate = 0.00574, stats = { { "精通", "加速" }, { "致命一擊", "臨機應變" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
    },
  },
  ["restoration"] = {
    label = "Restoration Shaman",
    contexts = {
      ["傳奇+"] = {
        { hero = "Farseer", primary = "Intellect", tier = "", pickrate = 0.00044, stats = { { "臨機應變" }, { "致命一擊", "精通", "加速" } }, minor = { { "Leech" }, { "Speed", "Avoidance" } } },
        { hero = "Totemic", primary = "Intellect", tier = "", pickrate = 0.03749, stats = { { "臨機應變" }, { "致命一擊", "精通", "加速" } }, minor = { { "Leech" }, { "Speed", "Avoidance" } } },
      },
      ["團隊"] = {
        { hero = "Farseer", primary = "Intellect", tier = "", pickrate = 0.00098, stats = { { "臨機應變" }, { "致命一擊", "加速", "精通" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
        { hero = "Totemic", primary = "Intellect", tier = "", pickrate = 0.03375, stats = { { "臨機應變" }, { "致命一擊", "加速", "精通" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
      },
    },
  },
}
