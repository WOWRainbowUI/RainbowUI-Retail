---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Assets.BarBordersSize = {
  width = 1000 / 8,
  height = 125 / 8,
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
