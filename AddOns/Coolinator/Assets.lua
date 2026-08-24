---@class addonTableCoolinator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

addonTable.Assets.BarBordersSize = {
  width = 1000 / 8,
  height = 125 / 8,
}

addonTable.Assets.BarBackgrounds = {
  ["Cooli: Solid Transparency"] = {file = "Interface/AddOns/Coolinator/Assets/Special/transparent.png", isTransparent = true},
  ["Cooli: Solid White"] = {file = "Interface/AddOns/Coolinator/Assets/Special/white.png"},
  ["Cooli: Fade Bottom"] = {file = "Interface/AddOns/Coolinator/Assets/BarBackgrounds/fade-bottom.png"},
  ["Cooli: Fade Top"] = {file = "Interface/AddOns/Coolinator/Assets/BarBackgrounds/fade-top.png"},
  ["Cooli: Fade Left"] = {file = "Interface/AddOns/Coolinator/Assets/BarBackgrounds/fade-left.png"},
  ["Cooli: Fade Right"] = {file = "Interface/AddOns/Coolinator/Assets/BarBackgrounds/fade-right.png"},
}

addonTable.Assets.BarBordersSliced = {
  ["Cooli: Transparent"] = {file = "Interface/AddOns/Coolinator/Assets/Special/transparent.png", width = 20, height = 20, isTransparent = true, margin = 0.5, extra = 0, modifier = 1},

  ["Cooli: 1px"] = {file = "Interface/AddOns/Coolinator/Assets/BarBorders/1px-square.png", width = 20, height = 20, has4k = false, masked = true, margin = 0.3, extra = 0, modifier = 0.35, DPIScale = 1/2},
  ["Cooli: 7px"] = {file = "Interface/AddOns/Coolinator/Assets/BarBorders/7px-square.png", width = 20, height = 20, has4k = false, masked = true, margin = 0.45, extra = 0, modifier = 0.35, DPIScale = 1/2},

  ["Cooli: Round Medium"] = {file = "Interface/AddOns/Coolinator/Assets/BarBorders/round-slight-square.png", width = 48, height = 48, margin = 0.48, extra = 0, modifier = 0.3, DPIScale = 1/2},

  ["Cooli: Blizzard Midnight"] = {file = "Interface/AddOns/Coolinator/Assets/BarBorders/blizzard-midnight.png", width = 34, height = 34, margin = 0.35, extra = 12, modifier = 0.4},
}

addonTable.Assets.BarMasks = {
  ["Cooli: Solid"] = {file = "Interface/AddOns/Coolinator/Assets/Special/white.png", width = 10, height = 10},
  ["Cooli: 7px"] = {file = "Interface/AddOns/Coolinator/Assets/BarBorders/7px-square-mask.png", width = 20, height = 20},
  ["Cooli: Round Medium"] = {file = "Interface/AddOns/Coolinator/Assets/BarBorders/round-slight-square-mask.png", width = 48, height = 48, margin = 0.48},
}

addonTable.Assets.IconBorders = {
  ["Cooli: 1px"] = {file = "Interface/AddOns/Coolinator/Assets/IconBorders/1px.png", mask = "Interface/AddOns/Coolinator/Assets/IconBorders/1px-mask.png"},
  ["Cooli: 3px"] = {file = "Interface/AddOns/Coolinator/Assets/IconBorders/3px.png", mask = "Interface/AddOns/Coolinator/Assets/IconBorders/1px-mask.png"},
  ["Cooli: CDM Pandemic"] = {file = "Interface/AddOns/Coolinator/Assets/IconBorders/cdm-pandemic.png", mask = "Interface/AddOns/Coolinator/Assets/IconBorders/blizzard-mask.png"},
  ["Cooli: CDM Dispel"] = {file = "Interface/AddOns/Coolinator/Assets/IconBorders/cdm-dispel.png", mask = "Interface/AddOns/Coolinator/Assets/IconBorders/blizzard-mask.png"},
}

addonTable.Assets.IconBorderAnimations = {
  ["Cooli: Pixel"] = {file = "Interface/AddOns/Coolinator/Assets/IconBorderAnimations/1px-dashes.png", width = 61, height = 47, rows = 1, columns = 6, duration = 0.3, loop = true},
  ["Cooli: Marching Ants"] = {file = "Interface/AddOns/Coolinator/Assets/IconBorderAnimations/ants.png", width = 56, height = 56, rows = 6, columns = 5, duration = 1, loop = true},
  ["Cooli: Flash"] = {file = "Interface/AddOns/Coolinator/Assets/IconBorderAnimations/flash.png", width = 40, height = 40, rows = 11, columns = 2, duration = 1.2, loop = false},
  ["Cooli: Static Glow"] = {file = "Interface/AddOns/Coolinator/Assets/IconBorders/new-player-glow.png", width = 76, height = 76, rows = 1, columns = 1, duration = 0, loop = true},
}

function addonTable.Assets.Initialize()
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

  local function IterateLSMSlicedBorder(list, masks)
    for key, entry in pairs(list) do
      LSM:Register("nineslice", key, {
        file = entry.file,
        previewWidth = entry.width,
        previewHeight = entry.height,
        padding = {left = entry.extra / 2, right = entry.extra / 2, top = entry.extra / 2, bottom = entry.extra / 2},
        margins = {left = entry.width * entry.margin, right = entry.width * entry.margin, top = entry.height * entry.margin, bottom = entry.height * entry.margin},
        scaleModifier = entry.modifier,
        mode = Enum.UITextureSliceMode.Stretched,
      })
      local maskKey = masks[key] and key or "Cooli: Solid"
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

  IterateLSMBackground(addonTable.Assets.BarBackgrounds)
  IterateLSMSlicedBorder(addonTable.Assets.BarBordersSliced, addonTable.Assets.BarMasks)
end
