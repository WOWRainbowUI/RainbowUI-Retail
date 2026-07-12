ClassCodexUggStats = ClassCodexUggStats or {}
ClassCodexUggStats["ROGUE"] = {
  ["assassination"] = {
    label = "Assassination Rogue",
    contexts = {
      ["傳奇+"] = {
        { hero = "Deathstalker", primary = "Agility", tier = "", pickrate = 0.00022, stats = { { "致命一擊" }, { "臨機應變", "加速", "精通" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
        { hero = "Fatebound", primary = "Agility", tier = "", pickrate = 0.00687, stats = { { "致命一擊" }, { "臨機應變", "加速", "精通" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
      },
      ["團隊"] = {
        { hero = "Deathstalker", primary = "Agility", tier = "", pickrate = 0.00035, stats = { { "致命一擊" }, { "臨機應變", "加速", "精通" } }, minor = { { "Leech" }, { "Speed", "Avoidance" } } },
        { hero = "Fatebound", primary = "Agility", tier = "", pickrate = 0.00712, stats = { { "致命一擊" }, { "臨機應變", "加速", "精通" } }, minor = { { "Leech" }, { "Speed", "Avoidance" } } },
      },
    },
  },
  ["outlaw"] = {
    label = "Outlaw Rogue",
    contexts = {
      ["傳奇+"] = {
        { hero = "Fatebound", primary = "Agility", tier = "", pickrate = 0.00049, stats = { { "臨機應變" }, { "致命一擊", "加速", "精通" } }, minor = { { "Leech" }, { "Avoidance", "Speed" } } },
        { hero = "Trickster", primary = "Agility", tier = "", pickrate = 0.00539, stats = { { "臨機應變" }, { "致命一擊", "加速", "精通" } }, minor = { { "Leech" }, { "Avoidance", "Speed" } } },
      },
      ["團隊"] = {
        { hero = "Fatebound", primary = "Agility", tier = "", pickrate = 0.00024, stats = { { "臨機應變" }, { "致命一擊", "加速", "精通" } }, minor = { { "Leech" }, { "Avoidance", "Speed" } } },
        { hero = "Trickster", primary = "Agility", tier = "", pickrate = 0.00537, stats = { { "臨機應變" }, { "致命一擊", "加速", "精通" } }, minor = { { "Leech" }, { "Avoidance", "Speed" } } },
      },
    },
  },
  ["subtlety"] = {
    label = "Subtlety Rogue",
    contexts = {
      ["傳奇+"] = {
        { hero = "Deathstalker", primary = "Agility", tier = "", pickrate = 0.00005, stats = { { "精通", "臨機應變", "致命一擊", "加速" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Trickster", primary = "Agility", tier = "", pickrate = 0.01705, stats = { { "精通", "臨機應變", "致命一擊", "加速" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
      ["團隊"] = {
        { hero = "Deathstalker", primary = "Agility", tier = "", pickrate = 0.00255, stats = { { "精通", "臨機應變", "加速", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Trickster", primary = "Agility", tier = "", pickrate = 0.02252, stats = { { "精通", "臨機應變", "加速", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
    },
  },
}
