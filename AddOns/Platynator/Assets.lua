---@class addonTablePlatynator
local addonTable = select(2, ...)

addonTable.Assets.RenderMode = {
  Sliced = 1,
  Fixed = 2,
  Stretch = 3,
}

addonTable.Assets.Mode = {
  Special = -1,
  Percent50 = 50, -- Height 63, Width 1000
  Percent75 = 75, -- Height 94, Width 1000
  Percent100 = 100, -- Height 125, Width 1000
  Percent125 = 125, -- Height 157, Width 1000
  Percent150 = 150, -- Height 189, Width 1000
  Percent175 = 175, -- Height 219, Width 1000
  Percent200 = 200, -- Height 250, Width 1000
}

addonTable.Assets.BarBordersSize = {
  width = 1000 / 8,
  height = 125 / 8,
}

local legacyMode = addonTable.Assets.Mode

addonTable.Assets.Highlights = {
  ["Platy: Animated Dashes Short"] = {offset = -1, defaultWidth = 1, preview = "Interface/AddOns/Platynator/Assets/Special/Animations/important-preview.png", horizontal = "Interface/AddOns/Platynator/Assets/Special/Animations/important.png", vertical = "Interface/AddOns/Platynator/Assets/Special/Animations/important-90.png", columns = 1, rows = 11, duration = 0.5, kind = "animatedBorder"},
  ["Platy: Animated Dashes Long"] = {offset = -1, defaultWidth = 1, preview = "Interface/AddOns/Platynator/Assets/Special/Animations/pandemic-preview.png", horizontal = "Interface/AddOns/Platynator/Assets/Special/Animations/pandemic.png", vertical = "Interface/AddOns/Platynator/Assets/Special/Animations/pandemic-90.png", columns = 1, rows = 11, duration = 0.5, kind = "animatedBorder"},
}

addonTable.Assets.PowerBars = {
  ["Platy: Gradient Circle"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/gradient-circle-sprites.png", width = 18, height = 18, inset = 0, has4k = true},
  ["Platy: Gradient Square"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/gradient-square-sprites.png", width = 18, height = 18, inset = 0, has4k = true},
  ["Platy: Soft Circle"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/soft-circle-sprites.png", width = 18, height = 18, inset = 0, has4k = true},
  ["Platy: Soft Square"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/soft-square-sprites.png", width = 18, height = 18, inset = 0, has4k = true},
  ["Platy: Glow Circle"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/glow-circle-sprites.png", width = 55, height = 55, inset = 37, has4k = true},
  ["Platy: Chained Square"] = {file = "Interface/AddOns/Platynator/Assets/%s/Power/chained-square-sprites.png", width = 22, height = 22, inset = 4, has4k = true},
}

addonTable.Assets.Markers = {
  ["normal/cast-icon"] = {file = addonTable.Constants.IsRetail and 236205 or 135753, width = 120, height = 120, tag = "castIcon"},

  ["normal/quest-gradient"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/quest-gradient.png", width = 48, height = 170, has4k = true, tag = "quest"},
  ["normal/quest-boss-blizzard"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-quest-boss.png", width = 164, height = 208, has4k = true, tag = "quest"},
  ["normal/quest-blizzard"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/quest-blizzard.png", width = 97, height = 170, tag = "quest"},

  ["normal/shield-gradient"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/shield-gradient.png", width = 150, height = 155, has4k = true, tag = "cannotInterrupt"},
  ["normal/shield-soft"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/shield-soft.png", width = 160, height = 165, has4k = true, tag = "cannotInterrupt"},
  ["normal/blizzard-shield"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-shield.png", width = 136, height = 165, has4k = true, tag = "cannotInterrupt"},
  ["normal/gw2-shield"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/gw2-shield.png", width = 165, height = 165, has4k = true, tag = "cannotInterrupt"},

  ["special/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/eliterarecombo-blizzard.png", width = 150, height = 155, mode = legacyMode.Special, tag = "elite"},
  ["normal/blizzard-elite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/elite-blizzard.png", width = 150, height = 155},
  ["normal/blizzard-rareelite"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/rareelite-blizzard.png", width = 150, height = 155},

  ["special/blizzard-elite-around"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rareelitecombo.png", width = 183, height = 155, has4k = true, mode = legacyMode.Special, tag = "elite"},
  ["normal/blizzard-elite-around"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-elite.png", width = 183, height = 150, has4k = true},
  ["normal/blizzard-rareelite-around"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rareelite.png", width = 183, height = 150, has4k = true},

  ["special/blizzard-elite-midnight"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-midnight-eliterarecombo.png", width = 150, height = 150, has4k = true, mode = legacyMode.Special, tag = "elite"},
  ["normal/blizzard-elite-midnight"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-midnight-elite.png", width = 150, height = 150, has4k = true},
  ["normal/blizzard-rareelite-midnight"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-midnight-rareelite.png", width = 150, height = 150, has4k = true},

  ["special/blizzard-elite-star"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare-old.png", width = 140, height = 140, has4k = true, tag = "elite"},

  ["special/tidy-star-elite"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/tidy-star-combined.png", width = 140, height = 140, has4k = true, mode = legacyMode.Special, tag = "elite"},
  ["special/tidy-star"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/tidy-star.png", width = 140, height = 140, has4k = true, tag = "elite"},
  ["special/tidy-star-silver"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/tidy-star-silver.png", width = 140, height = 140, has4k = true, tag = "elite"},
  ["special/tidy-star-rare"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/tidy-star.png", width = 140, height = 140, has4k = true, tag = "rare"},
  ["special/tidy-star-silver-rare"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/tidy-star-silver.png", width = 140, height = 140, has4k = true, tag = "rare"},

  ["normal/blizzard-rare"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare.png", width = 162, height = 159, has4k = true, tag = "rare"},
  ["normal/blizzard-rare-old"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare-old.png", width = 140, height = 140, has4k = true, tag = "rare"},
  ["normal/blizzard-rare-silver-star"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-rare-star.png", width = 140, height = 140, has4k = true, tag = "rare"},
  ["normal/blizzard-rare-midnight"] = {file = "Interface/AddOns/Platynator/Assets/%s/Markers/blizzard-midnight-rare.png", width = 162, height = 162, has4k = true, tag = "rare"},

  ["normal/blizzard-raid"] = {file = "Interface/TargetingFrame/UI-RaidTargetingIcons", preview = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1.blp", width = 150, height = 150, tag = "raid"},

  ["normal/blizzard-pvp"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/pvp.png", width = 150, height = 150, tag = "pvp"},

  ["faction-legacy"] = {preview = "Interface/AddOns/Platynator/Assets/Special/Markers/faction-legacy-horde.png", alliance = "Interface/AddOns/Platynator/Assets/Special/Markers/faction-legacy-alliance.png", horde = "Interface/AddOns/Platynator/Assets/Special/Markers/faction-legacy-horde.png", width = 200, height = 200, tag = "faction", text = "Legacy"},
  ["faction-assault"] = {preview = "Interface/AddOns/Platynator/Assets/Special/Markers/faction-assault-horde.png", alliance = "Interface/AddOns/Platynator/Assets/Special/Markers/faction-assault-alliance.png", horde = "Interface/AddOns/Platynator/Assets/Special/Markers/faction-assault-horde.png", width = 200, height = 200, tag = "faction", text = "Assault"},
  ["faction-icon"] = {preview = "Interface/AddOns/Platynator/Assets/%s/Markers/faction-icon-horde.png", alliance = "Interface/AddOns/Platynator/Assets/%s/Markers/faction-icon-alliance.png", horde = "Interface/AddOns/Platynator/Assets/%s/Markers/faction-icon-horde.png", width = 200, height = 200, tag = "faction", text = "Icon", has4k = true},
  ["faction-shield"] = {preview = "Interface/AddOns/Platynator/Assets/%s/Markers/faction-shield-horde.png", alliance = "Interface/AddOns/Platynator/Assets/%s/Markers/faction-shield-alliance.png", horde = "Interface/AddOns/Platynator/Assets/%s/Markers/faction-shield-horde.png", width = 200, height = 200, tag = "faction", text = "Shield", has4k = true},
  ["faction-grey"] = {preview = "Interface/AddOns/Platynator/Assets/%s/Markers/faction-grey-horde.png", alliance = "Interface/AddOns/Platynator/Assets/%s/Markers/faction-grey-alliance.png", horde = "Interface/AddOns/Platynator/Assets/%s/Markers/faction-grey-horde.png", width = 200, height = 200, tag = "faction", text = "Grey", has4k = true},

  ["boss-skull"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/boss-skull.png", width = 150, height = 150, tag = "boss", text = "Skull"},
  ["boss-vignette"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/boss-vignette.png", width = 150, height = 150, tag = "boss", text = "Vignette"},
  ["boss-torghast"] = {file = "Interface/AddOns/Platynator/Assets/Special/Markers/boss-torghast.png", width = 150, height = 150, tag = "boss", text = "Torghast"},
}

addonTable.Assets.SpecialBars = {
}

addonTable.Assets.SpecialEliteMarkers = {
  ["special/blizzard-elite"] = {
    elite = "normal/blizzard-elite",
    rareElite = "normal/blizzard-rareelite",
  },
  ["special/blizzard-elite-around"] = {
    elite = "normal/blizzard-elite-around",
    rareElite = "normal/blizzard-rareelite-around",
  },
  ["special/blizzard-elite-midnight"] = {
    elite = "normal/blizzard-elite-midnight",
    rareElite = "normal/blizzard-rareelite-midnight",
  },
  ["special/tidy-star-elite"] = {
    elite = "special/tidy-star",
    rareElite = "special/tidy-star-silver",
  },
}

function addonTable.Assets.ApplyScale()
  local DPIScale = "DPI144"
  if GetScreenDPIScale() < 1.4 then
    DPIScale = "DPI96"
  end

  local keys = {
    "file",
    "mask",
    "alliance",
    "horde",
    "preview",
  }

  local function ResizeAssets(list)
    for _, entry in pairs(list) do
      if entry.has4k then
        for _, k in ipairs(keys) do
          if type(entry[k]) == "string" then
            entry[k] = entry[k]:format(DPIScale)
          end
        end
      end
      entry.width = entry.width / 8
      entry.height = entry.height / 8
    end
  end

  local function Apply4k(list)
    for _, entry in pairs(list) do
      if entry.has4k then
        for _, k in ipairs(keys) do
          if type(entry[k]) == "string" then
            entry[k] = entry[k]:format(DPIScale)
          end
        end
      end
    end
  end

  Apply4k(addonTable.Assets.PowerBars)
  ResizeAssets(addonTable.Assets.Markers)
end
