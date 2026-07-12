ClassCodexUggStats = ClassCodexUggStats or {}
ClassCodexUggStats["PALADIN"] = {
  ["holy"] = {
    label = "Holy Paladin",
    contexts = {
      ["傳奇+"] = {
        { hero = "Herald of the Sun", primary = "Intellect", tier = "", pickrate = 0.02481, stats = { { "精通", "加速" }, { "臨機應變", "致命一擊" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
        { hero = "Lightsmith", primary = "Intellect", tier = "", pickrate = 0.00066, stats = { { "精通", "加速" }, { "臨機應變", "致命一擊" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
      },
      ["團隊"] = {
        { hero = "Herald of the Sun", primary = "Intellect", tier = "", pickrate = 0.02146, stats = { { "精通", "加速" }, { "臨機應變", "致命一擊" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
        { hero = "Lightsmith", primary = "Intellect", tier = "", pickrate = 0.00066, stats = { { "精通", "加速" }, { "臨機應變", "致命一擊" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
      },
    },
  },
  ["protection"] = {
    label = "Protection Paladin",
    contexts = {
      ["傳奇+"] = {
        { hero = "Lightsmith", primary = "Strength", tier = "", pickrate = 0.00305, stats = { { "臨機應變" }, { "加速", "致命一擊", "精通" } }, minor = { { "Speed", "Leech" }, { "Avoidance" } } },
        { hero = "Templar", primary = "Strength", tier = "", pickrate = 0.01102, stats = { { "臨機應變" }, { "加速", "致命一擊", "精通" } }, minor = { { "Speed", "Leech" }, { "Avoidance" } } },
      },
      ["團隊"] = {
        { hero = "Lightsmith", primary = "Strength", tier = "", pickrate = 0.00278, stats = { { "臨機應變" }, { "加速", "致命一擊", "精通" } }, minor = { { "Speed", "Leech" }, { "Avoidance" } } },
        { hero = "Templar", primary = "Strength", tier = "", pickrate = 0.00963, stats = { { "臨機應變" }, { "加速", "致命一擊", "精通" } }, minor = { { "Speed", "Leech" }, { "Avoidance" } } },
      },
    },
  },
  ["retribution"] = {
    label = "Retribution Paladin",
    contexts = {
      ["傳奇+"] = {
        { hero = "Herald of the Sun", primary = "Strength", tier = "", pickrate = 0.01606, stats = { { "精通", "致命一擊" }, { "加速", "臨機應變" } }, minor = { { "Speed", "Avoidance", "Leech" } } },
        { hero = "Templar", primary = "Strength", tier = "", pickrate = 0.03738, stats = { { "精通", "致命一擊" }, { "加速", "臨機應變" } }, minor = { { "Speed", "Avoidance", "Leech" } } },
      },
      ["團隊"] = {
        { hero = "Herald of the Sun", primary = "Strength", tier = "", pickrate = 0.00490, stats = { { "精通", "致命一擊" }, { "加速", "臨機應變" } }, minor = { { "Speed", "Avoidance", "Leech" } } },
        { hero = "Templar", primary = "Strength", tier = "", pickrate = 0.05789, stats = { { "精通", "致命一擊" }, { "加速", "臨機應變" } }, minor = { { "Speed", "Avoidance", "Leech" } } },
      },
    },
  },
}
