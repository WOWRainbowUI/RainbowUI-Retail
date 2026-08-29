---@class addonTableCoolinator
local addonTable = select(2, ...)

local function GetColor(rgb, a)
  local color = CreateColorFromRGBHexString(rgb)
  return {r = color.r, g = color.g, b = color.b, a = a}
end

local valueBarTexts = {
  value = {
    anchor = {"CENTER", 0, 0},
    scale = 1.1,
    color = GetColor("b3b3b3"),
    visible = true,
    widthLimit = 0.8,
  },
}

local function GetPrimaryClassResource(resource, fgColor, bgColor, t1, t2, t3)
  return {
    kind = "bar",
    resource = {kind = "class", resource = resource},
    width = 2,
    height = 0.65,
    scale = 1.5,
    alpha = 1,
    layout = "horizontal",
    direction = "left",
    foreground = {
      asset = "Cooli: Fade Right",
      color = fgColor,
    },
    background = {
      asset = "Cooli: Solid White",
      color = bgColor,
    },
    border = {
      asset = "Cooli: 1px",
      color = {r = 0, g = 0, b = 0},
    },
    thresholdColors = {
      {limit = 0.7, color = t1 or fgColor},
      {limit = 0.9, color = t2 or fgColor},
      {limit = 1, color = t3 or fgColor},
    },
    texts = valueBarTexts,
  }
end
local iconTexts = {
  keybinding = {
    anchor = {"TOPRIGHT", 18, 18},
    scale = 1.08,
    color = GetColor("b3b3b3"),
    visible = true,
    widthLimit = 0.8,
  },
  count = {
    anchor = {"BOTTOMRIGHT", 18, -18},
    scale = 1,
    color = GetColor("ffffff"),
    visible = true,
    widthLimit = 0.8,
  },
  cooldown = {
    anchor = {},
    scale = 1.40,
    color = GetColor("FFFFFF"),
    visible = true,
    showFractions = false,
    widthLimit = 0.9,
  }
}
local castBarTexts = {
  name = {
    anchor = {"LEFT", 8, 0},
    scale = Round(10/12 * 100) / 100,
    color = GetColor("cfcfcf"),
    visible = true,
    widthLimit = 0.6,
  },
  duration = {
    anchor = {"RIGHT", -8, 0},
    scale = Round(10/12 * 100) / 100,
    color = GetColor("cfcfcf"),
    visible = true,
    showFractions = false,
    widthLimit = 0.4,
    display = {"elapsed", "total"}, -- elapsed/remaining and total, with total being optional
  }
}

local spellBarTexts = {
  name = {
    anchor = {"LEFT", 8, 0},
    scale = Round(10/12 * 100) / 100,
    color = GetColor("cfcfcf"),
    visible = true,
    widthLimit = 0.6,
  },
  duration = {
    anchor = {"RIGHT", -8, 0},
    scale = Round(10/12 * 100) / 100,
    color = GetColor("cfcfcf"),
    visible = true,
    showFractions = false,
    widthLimit = 0.4,
    display = {"remaining"}, -- elapsed/remaining and total, with total being optional
  }
}

local Group = {
  kind = "group",
  layout = "horizontal",
  padding = 0.2,
  alpha = 1,
  scale = 1,
  alignment = "CENTER",
  entries = {},
  visibility = {},
}

local function GetClassPipGroup(resource, limit, ready, fill, empty)
  local pip = {
    kind = "bar",
    resource = {kind = "class", resource = resource},
    width = 0.3,
    height = 0.8,
    scale = 1.5,
    alpha = 1,
    layout = "horizontal",
    foreground = {
      asset = "Cooli: Fade Bottom",
      color = fill,
    },
    background = {
      asset = "Cooli: Solid White",
      color = empty,
    },
    border = {
      asset = "Cooli: 7px",
      color = GetColor("9d9d9d"),
      readyColor = ready,
    },
  }
  local group = CopyTable(Group)
  if limit > 9 then
    pip.width = 0.19
    group.padding = 0
  end
  group.locked = true
  for i = 1, limit do
    table.insert(group.entries, CopyTable(pip))
    group.entries[#group.entries].index = #group.entries
    group.entries[#group.entries].showEmpty = true
  end

  return group
end

local function GetRunePipGroup(resource, limit, ready, fill, readyFill, empty)
  local group = GetClassPipGroup(resource, limit, ready, fill, empty)
  for _, entry in ipairs(group.entries) do
    entry.foreground.readyColor = readyFill
  end

  return group
end

local function GetComboPipGroup(resource, limit, ready, fill, chargedFill, chargedBorder, empty)
  local group = GetClassPipGroup(resource, limit, ready, fill, empty)
  for _, entry in ipairs(group.entries) do
    entry.foreground.chargedColor = chargedFill
    entry.border.chargedColor = chargedBorder
  end

  return group
end

local function GetChargeGroup(fill, empty)
  local pip = {
    kind = "bar",
    resource = {kind = "abilityCharge", spellID = 0},
    width = 0.3,
    height = 0.8,
    scale = 1.5,
    alpha = 1,
    layout = "horizontal",
    foreground = {
      asset = "Cooli: Fade Bottom",
      color = fill,
    },
    background = {
      asset = "Cooli: Solid White",
      color = empty,
    },
    border = {
      asset = "Cooli: 7px",
      color = GetColor("9d9d9d"),
    },
    showEmpty = true,
  }
  local group = CopyTable(Group)
  group.locked = true
  for i = 1, 3 do
    table.insert(group.entries, CopyTable(pip))
    group.entries[#group.entries].index = #group.entries
  end

  return group
end

local function GetAuraStackGroup(fill, empty)
  local pip = {
    kind = "bar",
    resource = {kind = "auraStackPip", spellID = 0},
    width = 0.3,
    height = 0.8,
    scale = 1.5,
    alpha = 1,
    layout = "horizontal",
    foreground = {
      asset = "Cooli: Fade Bottom",
      color = fill,
    },
    background = {
      asset = "Cooli: Solid White",
      color = empty,
    },
    border = {
      asset = "Cooli: 7px",
      color = GetColor("9d9d9d"),
    },
    showEmpty = true
  }
  local group = CopyTable(Group)
  group.locked = true
  for i = 1, 6 do
    table.insert(group.entries, CopyTable(pip))
    group.entries[#group.entries].index = #group.entries
  end

  return group
end

addonTable.Designer.Defaults = {
  Group = Group,
  Stack = {
    kind = "stack",
    scale = 1, alpha = 1,
    entries = {},
  },
  Spacer = {
    kind = "spacer",
    alpha = 1,
    scale = 1, width = 1, height = 1,
  },
  AuraIcon = {
    kind = "icon",
    style = "blizzard",
    resource = {kind = "aura", spellID = 0},
    height = 1, scale = 1, alpha = 1,
    texts = iconTexts,
    showSwipe = true,
    swipeColor = GetColor("000000", 0.8),
    reverse = false,
    showIcon = true,
    whenActive = "none",
    whenInactive = "hide",
    glowColor = GetColor("ffe114"),
    showPandemic = true,
    pandemicColor = GetColor("ff3030"),
  },
  AbilityIcon = {
    kind = "icon",
    style = "blizzard",
    resource = {kind = "ability", spellID = 0},
    height = 1, scale = 1, alpha = 1,
    texts = iconTexts,
    showSwipe = true,
    swipeColor = GetColor("000000", 0.8),
    reverse = false,
    showIcon = true,
    whenCooldown = "desaturate",
    whenReady = "none",
    glowColor = GetColor("ffe114"),
  },
  ItemIcon = {
    kind = "icon",
    style = "blizzard",
    resource = {kind = "item", itemID = 0},
    height = 1, scale = 1, alpha = 1,
    texts = iconTexts,
    showSwipe = true,
    swipeColor = GetColor("000000", 0.8),
    reverse = false,
    showIcon = true,
    whenCooldown = "desaturate",
    whenReady = "none",
    glowColor = GetColor("ffe114"),
  },
  EquipmentIcon = {
    kind = "icon",
    style = "blizzard",
    resource = {kind = "equipment", equipmentSlot = 0},
    height = 1, scale = 1, alpha = 1,
    texts = iconTexts,
    showSwipe = true,
    swipeColor = GetColor("000000", 0.8),
    reverse = false,
    showIcon = true,
    whenCooldown = "desaturate",
    whenReady = "none",
    glowColor = GetColor("ffe114"),
  },
  AuraBar = {
    kind = "bar",
    resource = {kind = "aura", spellID = 0},
    width = 1,
    height = 1,
    scale = 1.5,
    layout = "horizontal",
    direction = "right",
    icon = {show = true, position = "left"},
    alpha = 1,
    foreground = {
      asset = "Cooli: Fade Bottom",
      color = {r = 0, g = 1, b = 0},
    },
    background = {
      asset = "Cooli: Solid White",
      color = GetColor("94ff21", 0.3),
    },
    border = {
      asset = "Cooli: Blizzard Midnight",
      color = {r = 1, g = 1, b = 1},
    },
    texts = spellBarTexts,
  },
  AbilityBar = {
    kind = "bar",
    resource = {kind = "ability", spellID = 0},
    width = 1,
    height = 1,
    scale = 1.5,
    layout = "horizontal",
    direction = "right",
    icon = {show = true, position = "left"},
    alpha = 1,
    foreground = {
      asset = "Cooli: Fade Bottom",
      color = {r = 0, g = 1, b = 0},
    },
    background = {
      asset = "Cooli: Solid White",
      color = GetColor("94ff21", 0.3),
    },
    border = {
      asset = "Cooli: Blizzard Midnight",
      color = {r = 1, g = 1, b = 1},
    },
    texts = spellBarTexts,
  },
  AbilityCharges = GetChargeGroup(GetColor("00ff77"), GetColor("deffb3", 0.3)),
  AuraStackPips = GetAuraStackGroup(GetColor("00ff77"), GetColor("deffb3", 0.3)),
  ClassResource = {
    ["icicles"] = {
      kind = "bar",
      resource = {kind = "class", resource = "icicles"},
      width = 2,
      height = 0.65,
      scale = 1.5,
      alpha = 1,
      layout = "horizontal",
      direction = "left",
      foreground = {
        asset = "Cooli: Fade Right",
        color = {r = 0, g = 0, b = 1},
      },
      background = {
        asset = "Cooli: Solid White",
        color = GetColor("6bcbff", 0.3),
      },
      border = {
        asset = "Cooli: 1px",
        color = {r = 0, g = 0, b = 0},
      },
    },
    ["rage"] = GetPrimaryClassResource("rage", {r = 1, g = 0, b = 0}, GetColor("ff787a", 0.3), GetColor("760002"), GetColor("ff0004"), GetColor("e100ff")),
    ["energy"] = GetPrimaryClassResource("energy", GetColor("ffd21e"), GetColor("7e680f", 0.3)),
    ["mana"] = GetPrimaryClassResource("mana", GetColor("009dff"), GetColor("6ab7ff", 0.3)),
    ["runic-power"] = GetPrimaryClassResource("runic-power", GetColor("009dff"), GetColor("6ab7ff", 0.3)),
    ["fury"] = GetPrimaryClassResource("fury", GetColor("ff6633"), GetColor("ffbe90", 0.3)),
    ["astral-power"] = GetPrimaryClassResource("astral-power", GetColor("7bf8ff"), GetColor("4d9b9f", 0.3), GetColor("7bf8ff"), GetColor("7bf8ff"), GetColor("7bf8ff")),
    ["focus"] = GetPrimaryClassResource("focus", GetColor("d37400"), GetColor("d3a954", 0.3)),
    ["insanity"] = GetPrimaryClassResource("insanity", GetColor("a10099"), GetColor("d38dcd", 0.3)),
    ["tip-of-the-spear"] = GetPrimaryClassResource("tip-of-the-spear", GetColor("2ed31c"), GetColor("89d38c", 0.3)),
    ["maelstrom"] = GetPrimaryClassResource("maelstrom", GetColor("7230ff"), GetColor("3e1a8c", 0.3)),
    ["stagger"] = {
      kind = "bar",
      resource = {kind = "class", resource = "stagger", options = {multiplier = 1.5}},
      width = 2, --0, -- widest of the entries just above or just below in the layout
      height = 0.65,
      scale = 1.5,
      alpha = 1,
      layout = "horizontal",
      direction = "left",
      foreground = {
        asset = "Cooli: Fade Bottom",
        color = {r = 0, g = 1, b = 0},
      },
      background = {
        asset = "Cooli: Solid White",
        color = GetColor("6bcbff", 0.3),
      },
      border = {
        asset = "Platy: Round Thin",
        color = {r = 0, g = 0, b = 0},
      },
      thresholdColors = {
        {limit = 0.6, color = {r = 0, g = 1, b = 0}, fadedColor = {r = 0, g = 0.7, b = 0}},
        {limit = 1, color = {r = 1, g = 1, b = 0}, fadedColor = {r = 0.7, g = 0.7, b = 0}},
        {limit = 2, color = {r = 1, g = 0, b = 0}, fadedColor = {r = 0.7, g = 0, b = 0}},
      }
    },
    ["soul-shards"] = GetClassPipGroup("soul-shards", 6, GetColor("7100b3"), GetColor("e23cff"), GetColor("dfa0ff", .3)),
    ["holy-power"] = GetClassPipGroup("holy-power", 5, GetColor("ba7c00"), GetColor("ffc021"), GetColor("fff899", .3)),
    ["combo-points"] = GetComboPipGroup("combo-points", 7, GetColor("b4006c"), GetColor("ff2f32"), GetColor("55aaff"), GetColor("b4006c"), GetColor("ffaaab", .3)),
    ["runes"] = GetRunePipGroup("runes", 6, GetColor("00479d"), GetColor("376a9e"), GetColor("58a9ff"), GetColor("a7ddff", .3)),
    ["essence"] = GetClassPipGroup("essence", 5, GetColor("00479d"), GetColor("58a9ff"), GetColor("a7ddff", .3)),
    ["chi"] = GetClassPipGroup("chi", 6, GetColor("3b9035"), GetColor("68ff5d"), GetColor("ceffc5", .3)),
    ["maelstrom-weapon"] = GetClassPipGroup("maelstrom-weapon", 10, GetColor("3e1a8c"), GetColor("7230ff"), GetColor("6d6e8c", 0.3)),
    ["arcane-charges"] = GetClassPipGroup("arcane-charges", 4, GetColor("75428d"), GetColor("d478ff"), GetColor("280564", 0.5)),
  },
  CastBar = {
    kind = "bar",
    resource = {kind = "cast"},
    autoSize = true,
    width = 1,
    height = 1,
    scale = 1.5,
    layout = "horizontal",
    direction = "right",
    icon = {show = true, position = "left"},
    alpha = 1,
    hideDelay = 0.5,
    preset = "DEFAULT",
    foreground = {
      asset = "Cooli: Fade Left",
      color = {r = 0, g = 1, b = 0},
    },
    background = {
      asset = "Cooli: Solid White",
      color = GetColor("94ff21", 0.3),
    },
    border = {
      asset = "Cooli: Blizzard Midnight",
      color = {r = 1, g = 1, b = 1},
    },
    texts = castBarTexts,
    colors = {
      casting = GetColor("fcf400"),
      channeling = GetColor("3EC637"),
      interrupted = GetColor("FC36E0"),
      uninterruptable = GetColor("83C0C3"),
      complete = GetColor("a3ff7b"),

      empoweredStage1 = GetColor("313131"),
      empoweredStage2 = GetColor("9a3536"),
      empoweredStage3 = GetColor("9a5628"),
      empoweredStageHold = GetColor("cbc74d"),
    }
  }
}
