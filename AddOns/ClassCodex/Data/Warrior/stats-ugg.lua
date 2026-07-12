ClassCodexUggStats = ClassCodexUggStats or {}
ClassCodexUggStats["WARRIOR"] = {
  ["arms"] = {
    label = "Arms Warrior",
    contexts = {
      ["傳奇+"] = {
        { hero = "Colossus", primary = "Strength", tier = "", pickrate = 0.01235, stats = { { "致命一擊" }, { "加速" }, { "精通", "臨機應變" } }, minor = { { "Avoidance", "Speed", "Leech" } } },
        { hero = "Slayer", primary = "Strength", tier = "", pickrate = 0.00238, stats = { { "致命一擊" }, { "加速" }, { "精通", "臨機應變" } }, minor = { { "Avoidance", "Speed", "Leech" } } },
      },
      ["團隊"] = {
        { hero = "Colossus", primary = "Strength", tier = "", pickrate = 0.00172, stats = { { "致命一擊" }, { "加速" }, { "臨機應變", "精通" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Slayer", primary = "Strength", tier = "", pickrate = 0.01218, stats = { { "致命一擊" }, { "加速" }, { "臨機應變", "精通" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
    },
  },
  ["fury"] = {
    label = "Fury Warrior",
    contexts = {
      ["傳奇+"] = {
        { hero = "Mountain Thane", primary = "Strength", tier = "", pickrate = 0.02265, stats = { { "加速", "精通" }, { "臨機應變", "致命一擊" } }, minor = { { "Speed", "Avoidance", "Leech" } } },
        { hero = "Slayer", primary = "Strength", tier = "", pickrate = 0.00604, stats = { { "加速", "精通" }, { "臨機應變", "致命一擊" } }, minor = { { "Speed", "Avoidance", "Leech" } } },
      },
      ["團隊"] = {
        { hero = "Mountain Thane", primary = "Strength", tier = "", pickrate = 0.01062, stats = { { "加速" }, { "精通" }, { "臨機應變", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
        { hero = "Slayer", primary = "Strength", tier = "", pickrate = 0.01957, stats = { { "加速" }, { "精通" }, { "臨機應變", "致命一擊" } }, minor = { { "Avoidance" }, { "Speed", "Leech" } } },
      },
    },
  },
  ["protection"] = {
    label = "Protection Warrior",
    contexts = {
      ["傳奇+"] = {
        { hero = "Colossus", primary = "Strength", tier = "", pickrate = 0.00028, stats = { { "臨機應變" }, { "加速", "致命一擊", "精通" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
        { hero = "Mountain Thane", primary = "Strength", tier = "", pickrate = 0.01722, stats = { { "臨機應變" }, { "加速", "致命一擊", "精通" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
      },
      ["團隊"] = {
        { hero = "Colossus", primary = "Strength", tier = "", pickrate = 0.00056, stats = { { "臨機應變" }, { "加速", "致命一擊", "精通" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
        { hero = "Mountain Thane", primary = "Strength", tier = "", pickrate = 0.01642, stats = { { "臨機應變" }, { "加速", "致命一擊", "精通" } }, minor = { { "Leech" }, { "Speed" }, { "Avoidance" } } },
      },
    },
  },
}
