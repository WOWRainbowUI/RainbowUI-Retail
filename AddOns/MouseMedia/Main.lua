---@class addonTableMouseMedia
local addonTable = select(2, ...)

addonTable.RenderMode = {
  Sliced = 1,
  Fixed = 2,
  Stretch = 3,
}

addonTable.BarBordersSize = {
  width = 1000 / 8,
  height = 125 / 8,
}

local renderMode = addonTable.RenderMode

local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register(LSM.MediaType.FONT, "Roboto Condensed Bold", "Interface/AddOns/MouseMedia/Assets/Fonts/RobotoCondensed-Bold.ttf", LSM.LOCALE_BIT_western + LSM.LOCALE_BIT_ruRU)
LSM:Register(LSM.MediaType.FONT, "Lato", "Interface/AddOns/MouseMedia/Assets/Fonts/Lato-Regular.ttf")
LSM:Register(LSM.MediaType.FONT, "Poppins SemiBold", "Interface/AddOns/MouseMedia/Assets/Fonts/Poppins-SemiBold.ttf")
LSM:Register(LSM.MediaType.FONT, "Diablo Heavy", "Interface/AddOns/MouseMedia/Assets/Fonts/DiabloHeavy.ttf")
LSM:Register(LSM.MediaType.FONT, "Atkinson Hyperlegible Next", "Interface/AddOns/MouseMedia/Assets/Fonts/AtkinsonHyperlegibleNext-Regular.otf")

addonTable.BarBackgrounds = {
  ["MM: Solid Transparency"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/transparent.png", isTransparent = true},
  ["MM: Solid Black"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/black.png"},
  ["MM: Solid Grey"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/grey.png"},
  ["MM: Solid Grey (Raid)"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/grey-raid.png"},
  ["MM: Solid Grey (Light)"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/light-grey.png"},
  ["MM: Solid White"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/white.png"},

  ["MM: Bevelled"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/bevelled.png", has4k = true},
  ["MM: Bevelled Grey"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/bevelled-grey.png", has4k = true},
  ["MM: Bevelled Edge"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/bevelled-edge.png", has4k = true},
  ["MM: Bevelled Edge (Inverted)"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/bevelled-edge-inverted.png", has4k = true},


  ["MM: Fade Bottom"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/fade-bottom.png", has4k = true},
  ["MM: Fade Top"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/fade-top.png", has4k = true},
  ["MM: Fade Left"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/fade-left.png", has4k = true},
  ["MM: Fade Right"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/fade-right.png", has4k = true},

  ["MM: Glass"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/glass.png", has4k = true},
  ["MM: Glossy"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/glossy.png", has4k = true},

  ["MM: GW2"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBackgrounds/gw2.png"},
  ["MM: Blizzard Cast Bar"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBackgrounds/blizzard-cast-bar.png"},

  ["MM: Absorb Wide"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/blizzard-absorb.png", has4k = true},
  ["MM: Absorb Narrow"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBackgrounds/blizzard-absorb-narrow.png", has4k = true},
}

addonTable.BarBordersSliced = {
  ["MM: Transparent"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/transparent.png", width = 20, height = 20, isTransparent = true, margin = 0.5, extra = 0, modifier = 1},

  ["MM: 7px"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/bold-square.png", width = 20, height = 20, has4k = true, masked = true, margin = 0.45, extra = 0, modifier = 0.35, DPIScale = 1/2},
  ["MM: 4px"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/slight-square.png", width = 20, height = 20, has4k = true, masked = true, margin = 0.3, extra = 0, modifier = 0.35, DPIScale = 1/2},
  ["MM: 2px"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/thin-square.png", width = 20, height = 20, has4k = true, masked = true, margin = 0.2, extra = 0, modifier = 0.35, DPIScale = 1/2},
  ["MM: 1px"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/1px-square.png", width = 20, height = 20, has4k = true, masked = true, margin = 0.3, extra = 0, modifier = 0.35, DPIScale = 1/2},

  ["MM: Round Bold"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/round-square.png", width = 48, height = 48, has4k = true, margin = 0.48, extra = 0, modifier = 0.3, DPIScale = 1/2},
  ["MM: Round Medium"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/round-slight-square.png", width = 48, height = 48, has4k = true, margin = 0.48, extra = 0, modifier = 0.3, DPIScale = 1/2},
  ["MM: Round Thin"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/round-thin-square.png", width = 48, height = 48, has4k = true, margin = 0.48, extra = 0, modifier = 0.3, DPIScale = 1/2},

  ["MM: 3D Box"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/3d-box-square.png", width = 40, height = 40, has4k = true, masked = true, margin = 0.40, extra = 0, modifier = 0.40, DPIScale = 1/2},
  ["MM: Bevelled"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/bevelled-square.png", width = 20, height = 20, has4k = true, masked = true, margin = 0.40, extra = 0, modifier = 0.60, DPIScale = 1/2},

  ["MM: Soft"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/soft-square.png", width = 66, height = 66, has4k = true, margin = 0.33, extra = 9, modifier = 0.25, DPIScale = 4/6},
  ["MM: GW2"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBorders/gw2.png", width = 33, height = 33, masked = false, margin = 0.3, extra = 12, modifier = 1},

  ["MM: Blizzard Health"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/blizzard-health-square.png", width = 48, height = 48, has4k = true, margin = 0.4, extra = 0, modifier = 0.3, DPIScale = 1/2},
  ["MM: Blizzard Midnight"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBorders/blizzard-midnight.png", width = 34, height = 34, margin = 0.35, extra = 9, modifier = 0.40},
  ["MM: Blizzard Midnight Selected"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBorders/blizzard-midnight-selected.png", width = 33, height = 33, margin = 0.4, extra = 12, modifier = 0.35},
  ["MM: Blizzard Cast Bar"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/blizzard-cast-bar-square.png", width = 48, height = 48, has4k = true, margin = 0.40, extra = 0, modifier = 0.35, DPIScale = 1/2},
  ["MM: Blizzard Classic"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/blizzard-classic-square.png", width = 48, height = 48, has4k = true, margin = 0.4, extra = 0, modifier = 0.3, DPIScale = 1/2},
  ["MM: Blizzard Metal"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBorders/blizzard-metal.png", width = 44, height = 44, margin = 0.48, extra = 14, modifier = 0.4},
  ["MM: Blizzard Gray Inset"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/blizzard-grey-inset.png", width = 69, height = 69, margin = 0.35, extra = 13, modifier = 0.4, has4k = true, DPIScale = 0.8},
  ["MM: Blizzard Glow"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBorders/blizzard-glow.png", width = 136, height = 136, margin = 0.5, extra = 33, modifier = 0.4, has4k = false, DPIScale = 0.8},
}

addonTable.BarMasks = {
  ["MM: Solid"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/white.png", width = 10, height = 10},
  ["MM: 7px"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/bold-square-mask.png", width = 20, height = 20, has4k = true},
  ["MM: 4px"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/slight-square-mask.png", width = 20, height = 20, has4k = true},
  ["MM: 2px"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/thin-square-mask.png", width = 20, height = 20, has4k = true},
  --["1px"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/1px-square-mask.png", width = 20, height = 20, has4k = true, margin = 0.3},

  ["MM: Round Bold"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/round-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.48},
  ["MM: Round Medium"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/round-slight-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.48},
  ["MM: Round Thin"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/round-thin-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.48},

  ["MM: 3D Box"] = {file = "Interface/AddOns/Platynator/Assets/%s/MouseMedia/3d-box-square-mask.png", width = 40, height = 40, has4k = true},
  ["MM: Bevelled"] = {file = "Interface/AddOns/Platynator/Assets/%s/MouseMedia/bevelled-square-mask.png", width = 20, height = 20, has4k = true},

  ["MM: Soft"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/soft-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.33},

  ["MM: Blizzard Health"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/blizzard-health-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.49},
  ["MM: Blizzard Midnight"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBorders/blizzard-midnight-mask.png", width = 24, height = 24, margin = 0.49},
  ["MM: Blizzard Classic"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/blizzard-classic-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.35},
  ["MM: Blizzard Cast Bar"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/blizzard-cast-bar-square-mask.png", width = 48, height = 48, has4k = true, margin = 0.35},
  ["MM: Blizzard Gray Inset"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/blizzard-grey-inset-mask.png", width = 52, height = 52, has4k = true, margin = 0.35},
  ["MM: Blizzard Glow"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBorders/blizzard-glow-mask.png", width = 64, height = 64, has4k = false, margin = 0.4},
}

addonTable.Highlights = {
  ["MM: White"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/white.png", width = 10, height = 10, mode = renderMode.Sliced, tag = "white", margin = 0.4, extra = 0, modifier = 1, minSize = 1},

  ["MM: Blizzard Health Bold"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarBorders/blizzard-health-square.png", width = 48, height = 48, has4k = true, masked = true, tag = "blizzard-health", margin = 0.4, extra = 0, minSize = 100, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced},
  ["MM: Soft Glow"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/soft-glow-square.png", width = 59, height = 59, has4k = true, masked = true, tag = "soft", margin = 0.4, extra = 11, modifier = 0.3, DPIScale = 1/2, mode = renderMode.Sliced},
  ["MM: Feathered"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/feathered-square.png", width = 60, height = 60, has4k = true, masked = true, tag = "soft", margin = 0.48, extra = 0, modifier = 0.25, DPIScale = 1/2, mode = renderMode.Sliced},
  ["MM: Feathered Holed"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/feathered-holed-square.png", width = 60, height = 60, has4k = true, masked = true, tag = "soft", margin = 0.48, extra = 0, modifier = 0.25, DPIScale = 1/2, mode = renderMode.Sliced},
  ["MM: Blizzard Midnight Important Cast"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBorders/blizzard-midnight-important-cast.png", width = 79, height = 16, marginX = 0.42, marginY = 0.5, extra = 0, modifier = 1, mode = renderMode.Sliced},
  ["MM: Blizzard Midnight Targeted By Enemy"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarBorders/blizzard-midnight-targetedbyenemy.png", width = 24, height = 24, margin = 0.42, extra = 0, modifier = 1, mode = renderMode.Sliced},

  ["MM: Glow"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/glow-100.png", width = 1563, height = 680, has4k = true, mode = renderMode.Stretch, tag = "glow"},

  ["MM: Striped"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/striped.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "striped"},
  ["MM: Striped Reverse"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/striped-reverse.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "striped-reverse"},

  ["MM: Arrows In"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows-in.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-in"},
  ["MM: Arrows Out"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows-out.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-out"},
  ["MM: Arrows In Close"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows-in-close.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-in-close"},
  ["MM: Arrows Out Close"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows-out-close.png", width = 1000, height = 125, has4k = true, mode = renderMode.Stretch, tag = "arrows-out-close"},

  ["MM: Arrow"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows.png", width = 86, height = 66, has4k = true, margin = 0.5, extra = 0, modifier = 0.29, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["MM: Arrow Out"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows-basic-out.png", width = 86, height = 66, has4k = true, margin = 0.5, extra = 0, modifier = 0.29, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["MM: Arrow Double"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/double-arrows.png", width = 149, height = 69, has4k = true, margin = 0.5, extra = 0, modifier = 0.31, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["MM: Arrow Double Out"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/double-arrows-out.png", width = 149, height = 69, has4k = true, margin = 0.5, extra = 0, modifier = 0.31, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["MM: Arrow Double Down"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/double-arrows-down.png", width = 173, height = 153, has4k = true, mode = renderMode.Fixed, tag = "arrows"},
  ["MM: Arrow Solid"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows-solid.png", width = 97, height = 69, has4k = true, margin = 0.5, extra = 0, modifier = 0.30, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["MM: Arrow Solid Out"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows-solid-out.png", width = 97, height = 69, has4k = true, margin = 0.5, extra = 0, modifier = 0.30, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["MM: Arrow Solid Down"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrow-solid-down.png", width = 207, height = 132, has4k = true, mode = renderMode.Fixed, tag = "arrows"},
  ["MM: Arrow Hi-vis"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/hi-vis-arrows.png", width = 158, height = 50, has4k = true, margin = 0.5, extra = 0, modifier = 0.42, shiftModifierV = 1, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["MM: Arrow Hi-vis Out"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/hi-vis-arrows-out.png", width = 158, height = 50, has4k = true, margin = 0.5, extra = 0, modifier = 0.42, shiftModifierV = 1, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["MM: Arrow Hi-vis Down"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/hi-vis-arrow-down.png", width = 125, height = 185, has4k = true, mode = renderMode.Fixed, tag = "arrows"},
  ["MM: Arrow Blocky"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows-blocky.png", width = 68, height = 50, has4k = true, margin = 0.5, extra = 0, modifier = 0.42, shiftModifierV = 1, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},
  ["MM: Arrow Blocky Out"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/arrows-blocky-out.png", width = 68, height = 50, has4k = true, margin = 0.5, extra = 0, modifier = 0.42, shiftModifierV = 1, DPIScale = 8/10, mode = renderMode.Sliced, tag = "arrows"},

  ["MM: Brackets"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/brackets.png", width = 154, height = 56, has4k = true, margin = 0.45, extra = 0, modifier = 0.3, shiftModifierV = 1, DPIScale = 8/10, mode = renderMode.Sliced},

  ["MM: Blizzard Classic Level"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/Highlights/blizzard-classic-level.png", width = 178, height = 125, has4k = true, mode = renderMode.Fixed, tag = "blizzard-classic-level"},
  ["MM: Blizzard Aggro"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/Highlights/blizzard-aggro.png", width = 1000, height = 240, has4k = true, mode = renderMode.Fixed, tag = "blizzard-aggro"},
}

addonTable.BarSparks = {
  ["MM: Transparency"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/transparent.png", width = 0, height = 0, offset = 0, isTransparent = true},

  ["MM: Glow"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/glow.png", width = 54, height = 125, mask = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/glow-mask.png", offset = 0.25, has4k = true, order = 2},
  ["MM: Streak"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/streak.png", width = 143, height = 125, offset = 0, has4k = true, order = 3, text = "Streak"},
  ["MM: Wave"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/wave.png", mask = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/wave-mask.png", width = 63, height = 125, offset = 0.27, has4k = true, order = 5},
  ["MM: Wave (Half)"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/wave-half.png", mask = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/wave-half-mask.png", width = 63, height = 125, offset = 0.27, has4k = true, order = 5},
  ["MM: Wave (Reverse)"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/wave-reverse.png", mask = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/wave-mask.png", width = 63, height = 125, offset = 0.45, has4k = true, order = 7},
  ["MM: Wave (Reverse, Half)"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/wave-reverse-half.png", mask = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/wave-half-mask.png", width = 63, height = 125, offset = 0.45, has4k = true, order = 7},
  ["MM: Bevelled"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/bevelled.png", width = 28, height = 125, offset = 0, has4k = true, order = 8},
  ["MM: Bevelled (Cornered)"] = {file = "Interface/AddOns/MouseMedia/Assets/%s/BarPosition/bevelled-cornered.png", width = 28, height = 125, offset = 0, has4k = true, order = 8},
  ["MM: GW2"] = {file = "Interface/AddOns/MouseMedia/Assets/Special/BarPosition/gw2.png", width = 137, height = 125, offset = 0.5, order = 10},
}

function addonTable.ApplyScale()
  local DPIScale = "DPI144"
  if GetScreenDPIScale() < 1.4 then
    DPIScale = "DPI96"
  end

  local function IterateLSMBackground(list)
    for key, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
      end
      LSM:Register(LSM.MediaType.STATUSBAR, key, entry.file)
    end
  end

  local function ResizeSlicedAssets(list, scales)
    for key, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
        if DPIScale ~= "DPI144" then
          local scale = scales[key].DPIScale
          entry.width = scale * entry.width
          entry.height = scale * entry.height
          if entry.modifier then
            entry.modifier = entry.modifier / scale
          end
        end
      end
    end
  end

  local function ResizeAssets(list)
    for _, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
        if entry.mask then
          entry.mask = entry.mask:format(DPIScale)
        end
      end
      entry.width = entry.width / 8
      entry.height = entry.height / 8
    end
  end

  local function Apply4k(list)
    for _, entry in pairs(list) do
      if entry.has4k then
        entry.file = entry.file:format(DPIScale)
      end
    end
  end

  local function IterateLSMSlicedBorder(list, masks)
    ResizeSlicedAssets(list, list)
    ResizeSlicedAssets(masks, list)
    for key, entry in pairs(list) do
      local marginX = entry.margin or entry.marginX
      local marginY = entry.margin or entry.marginY
      LSM:Register("nineslice", key, {
        file = entry.file,
        previewWidth = entry.width,
        previewHeight = entry.height,
        padding = {left = entry.extra / 2, right = entry.extra / 2, top = entry.extra / 2, bottom = entry.extra / 2},
        margins = {left = entry.width * marginX, right = entry.width * marginX, top = entry.height * marginY, bottom = entry.height * marginY},
        scaleModifier = entry.modifier,
        mode = Enum.UITextureSliceMode.Stretched,
      })
      local maskKey = masks[key] and key or "MM: Solid"
      local maskData = masks[maskKey]
      local maskMargin = maskData.margin or 0.49
      LSM:Register("ninesliceborder", key, {
        nineslice = key,
        mask = {
          file = maskData.file,
          margins = {left = maskData.width * maskMargin, right = maskData.width * maskMargin, top = maskData.height * maskMargin, bottom = maskData.height * maskMargin},
        },
      })
    end
  end

  local function IterateLSMHighlights(list)
    for key, entry in pairs(list) do
      if entry.mode == renderMode.Sliced then
        ResizeSlicedAssets({entry}, {entry})
        local marginX = entry.margin or entry.marginX
        local marginY = entry.margin or entry.marginY
        LSM:Register("nineslice", key, {
          file = entry.file,
          previewWidth = entry.width,
          previewHeight = entry.height,
          margins = {left = entry.width * marginX, right = entry.width * marginX, top = entry.height * marginY, bottom = entry.height * marginY},
          padding = {left = 0, right = 0, top = 0, bottom = 0},
          scaleModifier = entry.modifier,
          mode = Enum.UITextureSliceMode.Stretched,
        })
      else
        ResizeAssets({entry})
        LSM:Register("platynator/sizedtexture", key, {
          file = entry.file,
          width = entry.width,
          height = entry.height,
        })
      end
    end
  end

  local function IterateBarSparks(list)
    ResizeAssets(list)
    for key, entry in pairs(list) do
      LSM:Register("spark", key, {
        file = entry.file,
        width = entry.width,
        mask = entry.mask,
        offset = entry.offset * entry.width,
      })
    end
  end

  IterateLSMBackground(addonTable.BarBackgrounds)
  IterateLSMSlicedBorder(addonTable.BarBordersSliced, addonTable.BarMasks)
  IterateLSMHighlights(addonTable.Highlights)
  IterateBarSparks(addonTable.BarSparks)
end

addonTable.ApplyScale()
