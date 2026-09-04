---@class addonTableCoolinator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

local textureHeight = 20

local function GetLabelsValuesBackgrounds()
  local labels, values = {}, {}
  local assets = LSM:List("statusbar")

  local height = textureHeight
  local width = addonTable.Assets.BarBordersSize.width * height / addonTable.Assets.BarBordersSize.height

  local allKeys = GetKeysArray(addonTable.Assets.BarBackgrounds)
  table.sort(allKeys)
  for _, key in ipairs(allKeys) do
    local details = addonTable.Assets.BarBackgrounds[key]
    local file = LSM:Fetch("statusbar", key)
    local text = "|T".. file .. ":" .. (height - 1) .. ":" .. (width - 1) .. "|t " .. (key:gsub("Cooli: ", ""))
    if details.isTransparent then
      text = addonTable.Locales.NONE
    end

    table.insert(labels, text)
    table.insert(values, key)
  end

  for _, key in ipairs(assets) do
    if not addonTable.Assets.BarBackgrounds[key] then
      local file = LSM:Fetch("statusbar", key)
      local text = "|T".. file .. ":" .. (height - 1) .. ":" .. (width - 1) .. "|t [Custom] " .. key

      table.insert(labels, text)
      table.insert(values, key)
    end
  end

  return labels, values
end

local function GetLabelsValuesBorders()
  local labels, values = {}, {}
  local assets = LSM:List("ninesliceborder")

  local height = textureHeight

  local allKeys = GetKeysArray(addonTable.Assets.BarBordersSliced)
  table.sort(allKeys)
  for _, key in ipairs(allKeys) do
    local details = addonTable.Assets.BarBordersSliced[key]
    local file = LSM:Fetch("nineslice", LSM:Fetch("ninesliceborder", key).nineslice).file
    local text = "|T".. file .. ":" .. (height - 1) .. ":" .. (height - 1) .. "|t " .. (key:gsub("Cooli: ", ""))
    if details.isTransparent then
      text = addonTable.Locales.NONE
    end

    table.insert(labels, text)
    table.insert(values, key)
  end

  for _, key in ipairs(assets) do
    if not addonTable.Assets.BarBordersSliced[key] then
      local file = LSM:Fetch("nineslice", LSM:Fetch("ninesliceborder", key).nineslice).file
      local text = "|T".. file .. ":" .. (height - 1) .. ":" .. (height - 1) .. "|t [Custom] " .. key

      table.insert(labels, text)
      table.insert(values, key)
    end
  end

  return labels, values
end

local presets = {
  label = "",
  kind = "presets",
  getter = function(details)
    return details
  end,
  setter = function() end,
}

local fullBarTextures = {
  label = addonTable.Locales.TEXTURES,
  entries = {
    {
      label = addonTable.Locales.BORDER,
      kind = "dropdown",
      getInitData = function(details)
        return GetLabelsValuesBorders()
      end,
      setter = function(details, value)
        details.border.asset = value
      end,
      getter = function(details)
        return details.border.asset
      end
    },
    {
      label = addonTable.Locales.BORDER_COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.border.color = value
      end,
      getter = function(details)
        return details.border.color
      end,
    },
    {
      label = addonTable.Locales.FOREGROUND,
      kind = "dropdown",
      getInitData = function()
        return GetLabelsValuesBackgrounds()
      end,
      setter = function(details, value)
        details.foreground.asset = value
      end,
      getter = function(details)
        return details.foreground.asset
      end
    },
    {
      label = addonTable.Locales.FOREGROUND_COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.foreground.color = value
      end,
      getter = function(details)
        return details.foreground.color
      end,
    },
    {
      label = addonTable.Locales.BACKGROUND,
      kind = "dropdown",
      getInitData = function()
        return GetLabelsValuesBackgrounds()
      end,
      setter = function(details, value)
        details.background.asset = value
      end,
      getter = function(details)
        return details.background.asset
      end
    },
    {
      label = addonTable.Locales.BACKGROUND_COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.background.color = value
      end,
      getter = function(details)
        return details.background.color
      end,
    },
  }
}
local pipBarTextures = CopyTable(fullBarTextures)
table.insert(pipBarTextures.entries, 3, {
  label = addonTable.Locales.READY_BORDER_COLOR,
  kind = "colorPicker",
  setter = function(details, value)
    details.border.readyColor = value
  end,
  getter = function(details)
    return details.border.readyColor
  end,
})
local runeBarTextures = CopyTable(pipBarTextures)
table.insert(runeBarTextures.entries, 6, {
  label = addonTable.Locales.READY_FOREGROUND_COLOR,
  kind = "colorPicker",
  setter = function(details, value)
    details.foreground.readyColor = value
  end,
  getter = function(details)
    return details.foreground.readyColor
  end,
})
local comboPipBarTextures = CopyTable(pipBarTextures)
table.insert(comboPipBarTextures.entries, 4, {
  label = addonTable.Locales.CHARGED_BORDER_COLOR,
  kind = "colorPicker",
  setter = function(details, value)
    details.border.chargedColor = value
  end,
  getter = function(details)
    return details.border.chargedColor
  end,
})
table.insert(comboPipBarTextures.entries, 7, {
  label = addonTable.Locales.CHARGED_FOREGROUND_COLOR,
  kind = "colorPicker",
  setter = function(details, value)
    details.foreground.chargedColor = value
  end,
  getter = function(details)
    return details.foreground.chargedColor
  end,
})
local barTextureNoForegroundColor = {
  label = addonTable.Locales.TEXTURES,
  entries = {
    {
      label = addonTable.Locales.BORDER,
      kind = "dropdown",
      getInitData = function(details)
        return GetLabelsValuesBorders()
      end,
      setter = function(details, value)
        details.border.asset = value
      end,
      getter = function(details)
        return details.border.asset
      end
    },
    {
      label = addonTable.Locales.BORDER_COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.border.color = value
      end,
      getter = function(details)
        return details.border.color
      end,
    },
    {
      label = addonTable.Locales.FOREGROUND,
      kind = "dropdown",
      getInitData = function()
        return GetLabelsValuesBackgrounds()
      end,
      setter = function(details, value)
        details.foreground.asset = value
      end,
      getter = function(details)
        return details.foreground.asset
      end
    },
    {
      label = addonTable.Locales.BACKGROUND,
      kind = "dropdown",
      getInitData = function()
        return GetLabelsValuesBackgrounds()
      end,
      setter = function(details, value)
        details.background.asset = value
      end,
      getter = function(details)
        return details.background.asset
      end
    },
    {
      label = addonTable.Locales.BACKGROUND_COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.background.color = value
      end,
      getter = function(details)
        return details.background.color
      end,
    },
  }
}
local classBarThresholds = {
  label = addonTable.Locales.THRESHOLDS,
  entries = {
    {
      label = "1",
      kind = "slider",
      min = 0, max = 100,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.thresholdColors[1].limit = value / 100
      end,
      getter = function(details)
        return details.thresholdColors[1].limit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.thresholdColors[1].color = value
      end,
      getter = function(details)
        return details.thresholdColors[1].color
      end,
    },
    {
      label = "2",
      kind = "slider",
      min = 0, max = 100,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.thresholdColors[2].limit = value / 100
      end,
      getter = function(details)
        return details.thresholdColors[2].limit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.thresholdColors[2].color = value
      end,
      getter = function(details)
        return details.thresholdColors[2].color
      end,
    },
    {
      label = "3",
      kind = "slider",
      min = 0, max = 100,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.thresholdColors[3].limit = value / 100
      end,
      getter = function(details)
        return details.thresholdColors[3].limit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.thresholdColors[3].color = value
      end,
      getter = function(details)
        return details.thresholdColors[3].color
      end,
    },
  }
}

local barIcon = {
  label = addonTable.Locales.GENERAL,
  entries = {
    {
      label = addonTable.Locales.SHOW_ICON,
      kind = "checkbox",
      setter = function(details, value)
        details.icon.show = value
      end,
      getter = function(details)
        return details.icon.show
      end,
    },
    {
      label = addonTable.Locales.ICON_POSITION,
      kind = "dropdown",
      getInitData = function(details)
        if details.layout == "horizontal" then
          return {
            addonTable.Locales.LEFT,
            addonTable.Locales.RIGHT,
          }, {
            "left",
            "right"
          }
        else
          return {
            addonTable.Locales.TOP,
            addonTable.Locales.BOTTOM,
          }, {
            "right",
            "left"
          }
        end
      end,
      setter = function(details, value)
        details.icon.position = value
      end,
      getter = function(details)
        return details.icon.position
      end,
    },
  }
}

local valueBarTexts = {
  label = addonTable.Locales.TEXTS,
  entries = {
    {
      label = "",
      kind = "barTexts",
      setter = function() end,
      getter = function(details) return details end,
      texts = {
        value = { default = "3", title = addonTable.Locales.VALUE },
      }
    },
  }
}

local durationNameBarTexts = {
  label = addonTable.Locales.TEXTS,
  entries = {
    {
      label = "",
      kind = "barTexts",
      setter = function() end,
      getter = function(details) return details end,
      texts = {
        duration = { default = "1.9", title = addonTable.Locales.DURATION },
        name = { default = addonTable.Locales.ARCANE_FLURRY, title = addonTable.Locales.NAME },
      }
    },
  }
}

local applicationsBarTexts = {
  label = addonTable.Locales.TEXTS,
  entries = {
    {
      label = "",
      kind = "barTexts",
      setter = function() end,
      getter = function(details) return details end,
      texts = {
        applications = { default = "3", title = addonTable.Locales.APPLICATIONS },
      }
    },
  }
}

local cooldownOptions = {
  label = addonTable.Locales.COOLDOWN,
  entries = {
    {
      label = addonTable.Locales.WHEN_ON_COOLDOWN,
      kind = "dropdown",
      getInitData = function(details)
        return {
          addonTable.Locales.NOTHING,
          addonTable.Locales.DESATURATE,
          addonTable.Locales.HIDE,
        }, {
            "none",
            "desaturate",
            "hide",
          }
      end,
      setter = function(details, value)
        details.whenCooldown = value
      end,
      getter = function(details)
        return details.whenCooldown
      end,
    },
    {
      label = addonTable.Locales.WHEN_READY,
      kind = "dropdown",
      getInitData = function(details)
        return {
          addonTable.Locales.NOTHING,
          addonTable.Locales.DESATURATE,
          addonTable.Locales.HIDE,
          addonTable.Locales.PIXEL_GLOW,
          addonTable.Locales.MARCHING_ANTS_GLOW,
          addonTable.Locales.FLASH_GLOW,
          addonTable.Locales.STATIC_GLOW,
        }, {
          "none",
          "desaturate",
          "hide",
          "glow-pixel",
          "glow-marching-ants",
          "glow-flash",
          "glow-static",
        }
      end,
      setter = function(details, value)
        details.whenReady = value
      end,
      getter = function(details)
        return details.whenReady
      end,
    },
    {
      label = addonTable.Locales.GLOW_COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.glowColor = value
      end,
      getter = function(details)
        return details.glowColor
      end,
    },
    {
      label = addonTable.Locales.REVERSE_GLOW,
      kind = "checkbox",
      setter = function(details, value)
        details.glowReverse = value
      end,
      getter = function(details)
        return details.glowReverse
      end,
    }
  }
}

addonTable.Designer.WidgetConfiguration = {
  ["icon"] = {
    ["*"] = {
      ["*"] = {
        {
          label = addonTable.Locales.GENERAL,
          entries = {
            presets,
            { kind = "spacer" },
            {
              label = addonTable.Locales.SCALE,
              kind = "slider",
              min = 25, max = 400,
              valuePattern = "%d%%",
              setter = function(details, value)
                details.scale = value / 100
              end,
              getter = function(details)
                return details.scale * 100
              end,
            },
            {
              label = addonTable.Locales.TRANSPARENCY,
              kind = "slider",
              min = 0, max = 100,
              formatter = function(value) return value .. "%" end,
              setter = function(details, value)
                details.alpha = 1 - value / 100
              end,
              getter = function(details)
                return (1 - details.alpha) * 100
              end,
            },
            { kind = "spacer" },
            {
              label = addonTable.Locales.STYLE,
              kind = "dropdown",
              getInitData = function()
                local labels = {
                  addonTable.Locales.SQUARE,
                  addonTable.Locales.BLIZZARD,
                }
                local values = {
                  "square",
                  "blizzard"
                }
                return labels, values
              end,
              setter = function(details, value)
                details.style = value
              end,
              getter = function(details)
                return details.style
              end,
            },
            {
              label = addonTable.Locales.REVERSE,
              kind = "checkbox",
              setter = function(details, value)
                details.reverse = value
              end,
              getter = function(details)
                return details.reverse
              end,
            },
            { kind = "spacer" },
            {
              label = addonTable.Locales.SHOW_ICON,
              kind = "checkbox",
              setter = function(details, value)
                details.showIcon = value
              end,
              getter = function(details)
                return details.showIcon
              end,
            },
            {
              label = addonTable.Locales.SHOW_SWIPE,
              kind = "checkbox",
              setter = function(details, value)
                details.showSwipe = value
              end,
              getter = function(details)
                return details.showSwipe
              end,
            },
            {
              label = addonTable.Locales.SWIPE_COLOR,
              kind = "colorPicker",
              setter = function(details, value)
                details.swipeColor = value
              end,
              getter = function(details)
                return details.swipeColor             end,
            },
          }
        },
        {
          label = addonTable.Locales.TEXTS,
          entries = {
            {
              label = "",
              kind = "iconTexts",
              setter = function() end,
              getter = function(details) return details end,
            },
          }
        },
      }
    },
    ["ability"] = {
      ["*"] = {
        {
          label = addonTable.Locales.GENERAL,
          entries = {
            {
              label = addonTable.Locales.RANGE_CHECKING,
              kind = "checkbox",
              setter = function(details, value)
                details.showRange = value
              end,
              getter = function(details)
                return details.showRange
              end,
            }
          }
        },
        cooldownOptions,
      }
    },
    ["item"] = {
      ["*"] = {
        cooldownOptions,
      }
    },
    ["equipment"] = {
      ["*"] = {
        cooldownOptions,
      }
    },
    ["aura"] = {
      ["*"] = {
        {
          label = addonTable.Locales.ACTIVE,
          entries = {
            {
              label = addonTable.Locales.WHEN_ACTIVE,
              kind = "dropdown",
              getInitData = function(details)
                return {
                  addonTable.Locales.NONE,
                  addonTable.Locales.PIXEL_GLOW,
                  addonTable.Locales.MARCHING_ANTS_GLOW,
                  addonTable.Locales.STATIC_GLOW,
                }, {
                  "none",
                  "glow-pixel",
                  "glow-marching-ants",
                  "glow-static",
                }
              end,
              setter = function(details, value)
                details.whenActive = value
              end,
              getter = function(details)
                return details.whenActive
              end,
            },
            {
              label = addonTable.Locales.WHEN_INACTIVE,
              kind = "dropdown",
              getInitData = function(details)
                return {
                  addonTable.Locales.HIDE,
                }, {
                    "hide",
                  }
              end,
              setter = function(details, value)
                details.whenInactive = value
              end,
              getter = function(details)
                return details.whenInactive
              end,
            },
            { kind = "spacer" },
            {
              label = addonTable.Locales.GLOW_COLOR,
              kind = "colorPicker",
              setter = function(details, value)
                details.glowColor = value
              end,
              getter = function(details)
                return details.glowColor
              end,
            },
            {
              label = addonTable.Locales.REVERSE_GLOW,
              kind = "checkbox",
              setter = function(details, value)
                details.glowReverse = value
              end,
              getter = function(details)
                return details.glowReverse
              end,
            },
            { kind = "spacer" },
            {
              label = addonTable.Locales.SHOW_PANDEMIC,
              kind = "checkbox",
              setter = function(details, value)
                details.showPandemic = value
              end,
              getter = function(details)
                return details.showPandemic
              end,
            },
          },
        },
      }
    },
    ["auraMissing"] = {
      ["*"] = {
        {
          label = addonTable.Locales.ACTIVE,
          entries = {
            {
              label = addonTable.Locales.WHEN_ACTIVE,
              kind = "dropdown",
              getInitData = function(details)
                return {
                  addonTable.Locales.HIDE,
                }, {
                  "hide",
                }
              end,
              setter = function(details, value)
                details.whenActive = value
              end,
              getter = function(details)
                return details.whenActive
              end,
            },
            {
              label = addonTable.Locales.WHEN_INACTIVE,
              kind = "dropdown",
              getInitData = function(details)
                return {
                  addonTable.Locales.NONE,
                  addonTable.Locales.PIXEL_GLOW,
                  addonTable.Locales.MARCHING_ANTS_GLOW,
                  addonTable.Locales.STATIC_GLOW,
                }, {
                  "none",
                  "glow-pixel",
                  "glow-marching-ants",
                  "glow-static",
                }
              end,
              setter = function(details, value)
                details.whenInactive = value
              end,
              getter = function(details)
                return details.whenInactive
              end,
            },
            { kind = "spacer" },
            {
              label = addonTable.Locales.GLOW_COLOR,
              kind = "colorPicker",
              setter = function(details, value)
                details.glowColor = value
              end,
              getter = function(details)
                return details.glowColor
              end,
            },
            {
              label = addonTable.Locales.REVERSE_GLOW,
              kind = "checkbox",
              setter = function(details, value)
                details.glowReverse = value
              end,
              getter = function(details)
                return details.glowReverse
              end,
            },
          },
        },
      }
    },
  },
  ["bar"] = {
    ["*"] = {
      ["*"] = {
        {
          label = addonTable.Locales.GENERAL,
          entries = {
            presets,
            { kind = "spacer" },
            {
              label = addonTable.Locales.SCALE,
              kind = "slider",
              min = 25, max = 400,
              valuePattern = "%d%%",
              setter = function(details, value)
                details.scale = value / 100
              end,
              getter = function(details)
                return details.scale * 100
              end,
            },
            {
              label = addonTable.Locales.TRANSPARENCY,
              kind = "slider",
              min = 0, max = 100,
              formatter = function(value) return value .. "%" end,
              setter = function(details, value)
                details.alpha = 1 - value / 100
              end,
              getter = function(details)
                return (1 - details.alpha) * 100
              end,
            },
            { kind = "spacer" },
            {
              label = addonTable.Locales.AUTO_SIZE,
              kind = "checkbox",
              setter = function(details, value)
                details.autoSize = value
              end,
              getter = function(details)
                return details.autoSize
              end,
            },
            {
              label = addonTable.Locales.HEIGHT,
              kind = "slider",
              min = 50, max = 300,
              formatter = function(value) return value .. "%" end,
              setter = function(details, value)
                details.height = value / 100
              end,
              getter = function(details)
                return details.height * 100
              end,
            },
            {
              label = addonTable.Locales.WIDTH,
              kind = "slider",
              min = 10, max = 300,
              formatter = function(value) return value .. "%" end,
              setter = function(details, value)
                details.width = value / 100
              end,
              getter = function(details)
                return details.width * 100
              end,
            },
            {
              label = addonTable.Locales.LAYOUT,
              kind = "dropdown",
              getInitData = function()
                return {
                  addonTable.Locales.VERTICAL,
                  addonTable.Locales.HORIZONTAL,
                }, {
                  "vertical",
                  "horizontal"
                }
              end,
              setter = function(details, value)
                local oldValue = details.layout
                details.layout = value

                if details.texts and oldValue ~= value then
                  if value == "horizontal" then
                    for _, textDetails in pairs(details.texts) do
                      if textDetails.anchor[1] == "TOP" then
                        textDetails.anchor[1] = "RIGHT"
                      elseif textDetails.anchor[1] == "BOTTOM" then
                        textDetails.anchor[1] = "LEFT"
                      end
                      local tmp = textDetails.anchor[2]
                      textDetails.anchor[2] = textDetails.anchor[3]
                      textDetails.anchor[3] = tmp
                    end
                  else
                    for _, textDetails in pairs(details.texts) do
                      if textDetails.anchor[1] == "LEFT" then
                        textDetails.anchor[1] = "BOTTOM"
                      elseif textDetails.anchor[1] == "RIGHT" then
                        textDetails.anchor[1] = "TOP"
                      end
                      local tmp = textDetails.anchor[2]
                      textDetails.anchor[2] = textDetails.anchor[3]
                      textDetails.anchor[3] = tmp
                    end
                  end
                end
              end,
              getter = function(details)
                return details.layout
              end,
            },
          },
        },
      },
    },
    ["aura"] = {
      ["*"] = {
        barIcon,
        fullBarTextures,
        durationNameBarTexts,
      },
    },
    ["ability"] = {
      ["*"] = {
        barIcon,
        fullBarTextures,
        durationNameBarTexts,
      },
    },
    ["abilityCharge"] = {
      ["*"] = {
        fullBarTextures,
        --valueBarTexts,
      }
    },
    ["auraStacks"] = {
      ["*"] = {
        fullBarTextures,
        applicationsBarTexts,
      },
    },
    ["auraStackPip"] = {
      ["*"] = {
        fullBarTextures,
        --valueBarTexts,
      }
    },
    ["class"] = {
      ["icicles"] = {
        fullBarTextures,
        --valueBarTexts,
      },
      ["tip-of-the-spear"] = {
        fullBarTextures,
        --valueBarTexts,
      },
      ["stagger"] = {
        barTextureNoForegroundColor,
        --valueBarTexts,
        {
          label = addonTable.Locales.THRESHOLDS,
          entries = {
            {
              label = addonTable.Locales.SAFE,
              kind = "slider",
              min = 0, max = 400,
              valuePattern = "%d%%",
              setter = function(details, value)
                details.thresholdColors[1].limit = value / 100
              end,
              getter = function(details)
                return details.thresholdColors[1].limit * 100
              end,
            },
            {
              label = addonTable.Locales.SAFE_COLOR,
              kind = "colorPicker",
              setter = function(details, value)
                details.thresholdColors[1].color = value
              end,
              getter = function(details)
                return details.thresholdColors[1].color
              end,
            },
            {
              label = addonTable.Locales.SAFE_COLOR_FADED,
              kind = "colorPicker",
              setter = function(details, value)
                details.thresholdColors[1].fadedColor = value
              end,
              getter = function(details)
                return details.thresholdColors[1].fadedColor
              end,
            },
            {
              label = addonTable.Locales.WARNING,
              kind = "slider",
              min = 0, max = 400,
              valuePattern = "%d%%",
              setter = function(details, value)
                details.thresholdColors[2].limit = value / 100
              end,
              getter = function(details)
                return details.thresholdColors[2].limit * 100
              end,
            },
            {
              label = addonTable.Locales.WARNING_COLOR,
              kind = "colorPicker",
              setter = function(details, value)
                details.thresholdColors[2].color = value
              end,
              getter = function(details)
                return details.thresholdColors[2].color
              end,
            },
            {
              label = addonTable.Locales.WARNING_COLOR_FADED,
              kind = "colorPicker",
              setter = function(details, value)
                details.thresholdColors[2].fadedColor = value
              end,
              getter = function(details)
                return details.thresholdColors[2].fadedColor
              end,
            },
            {
              label = addonTable.Locales.DANGER,
              kind = "slider",
              min = 0, max = 400,
              valuePattern = "%d%%",
              setter = function(details, value)
                details.thresholdColors[3].limit = value / 100
              end,
              getter = function(details)
                return details.thresholdColors[3].limit * 100
              end,
            },
            {
              label = addonTable.Locales.DANGER_COLOR,
              kind = "colorPicker",
              setter = function(details, value)
                details.thresholdColors[3].color = value
              end,
              getter = function(details)
                return details.thresholdColors[3].color
              end,
            },
            {
              label = addonTable.Locales.DANGER_COLOR_FADED,
              kind = "colorPicker",
              setter = function(details, value)
                details.thresholdColors[3].fadedColor = value
              end,
              getter = function(details)
                return details.thresholdColors[3].fadedColor
              end,
            },
          }
        },
      },
      ["rage"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["energy"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["mana"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["maelstrom"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["runic-power"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["pain"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["fury"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["astral-power"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["insanity"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["focus"] = {
        barTextureNoForegroundColor,
        valueBarTexts,
        classBarThresholds,
      },
      ["runes"] = {
        runeBarTextures,
        --valueBarTexts,
      },
      ["holy-power"] = {
        pipBarTextures,
        --valueBarTexts,
      },
      ["combo-points"] = {
        comboPipBarTextures,
        --valueBarTexts,
      },
      ["soul-shards"] = {
        pipBarTextures,
        --valueBarTexts,
      },
      ["essence"] = {
        pipBarTextures,
        --valueBarTexts,
      },
      ["chi"] = {
        pipBarTextures,
        --valueBarTexts,
      },
      ["maelstrom-weapon"] = {
        pipBarTextures,
        --valueBarTexts,
      },
      ["arcane-charges"] = {
        pipBarTextures,
        --valueBarTexts,
      },
    },
    ["cast"] = {
      ["*"] = {
        barIcon,
        barTextureNoForegroundColor,
        durationNameBarTexts,
        {
          label = addonTable.Locales.COLORS,
          entries = {
            {
              label = addonTable.Locales.CASTING,
              kind = "colorPicker",
              setter = function(details, value)
                details.colors.casting = value
              end,
              getter = function(details)
                return details.colors.casting
              end,
            },
            {
              label = addonTable.Locales.CHANNELING,
              kind = "colorPicker",
              setter = function(details, value)
                details.colors.channeling = value
              end,
              getter = function(details)
                return details.colors.channeling
              end,
            },
            {
              label = addonTable.Locales.UNINTERRUPTABLE,
              kind = "colorPicker",
              setter = function(details, value)
                details.colors.uninterruptable = value
              end,
              getter = function(details)
                return details.colors.uninterruptable
              end,
            },
            { kind = "spacer" },
            {
              label = addonTable.Locales.INTERRUPTED,
              kind = "colorPicker",
              setter = function(details, value)
                details.colors.interrupted = value
              end,
              getter = function(details)
                return details.colors.interrupted
              end,
            },
            {
              label = addonTable.Locales.COMPLETED,
              kind = "colorPicker",
              setter = function(details, value)
                details.colors.complete = value
              end,
              getter = function(details)
                return details.colors.complete
              end,
            },
            { kind = "spacer" },
            {
              label = addonTable.Locales.EMPOWERED_STAGE_1,
              kind = "colorPicker",
              setter = function(details, value)
                details.colors.empoweredStage1 = value
              end,
              getter = function(details)
                return details.colors.empoweredStage1
              end,
              hide = true
            },
            {
              label = addonTable.Locales.EMPOWERED_STAGE_2,
              kind = "colorPicker",
              setter = function(details, value)
                details.colors.empoweredStage2 = value
              end,
              getter = function(details)
                return details.colors.empoweredStage2
              end,
              hide = true
            },
            {
              label = addonTable.Locales.EMPOWERED_STAGE_3,
              kind = "colorPicker",
              setter = function(details, value)
                details.colors.empoweredStage3 = value
              end,
              getter = function(details)
                return details.colors.empoweredStage3
              end,
            },
            {
              label = addonTable.Locales.EMPOWERED_STAGE_HOLD,
              kind = "colorPicker",
              setter = function(details, value)
                details.colors.empoweredStageHold = value
              end,
              getter = function(details)
                return details.colors.empoweredStageHold
              end,
              hide = true
            },
          },
        },
      },
    },
  },
  ["group"] = {
    ["*"] = {
      ["*"] = {
        {
          label = addonTable.Locales.GENERAL,
          entries = {
            presets,
            { kind = "spacer" },
            {
              label = addonTable.Locales.SCALE,
              kind = "slider",
              min = 25, max = 400,
              valuePattern = "%d%%",
              setter = function(details, value)
                details.scale = value / 100
              end,
              getter = function(details)
                return details.scale * 100
              end,
            },
            {
              label = addonTable.Locales.GROW_FROM,
              kind = "dropdown",
              getInitData = function(details)
                if details.anchor then
                  return {
                    addonTable.Locales.CENTER,
                    addonTable.Locales.TOP,
                    addonTable.Locales.BOTTOM,
                    addonTable.Locales.LEFT,
                    addonTable.Locales.RIGHT,
                    addonTable.Locales.TOP_LEFT,
                    addonTable.Locales.TOP_RIGHT,
                    addonTable.Locales.BOTTOM_LEFT,
                    addonTable.Locales.BOTTOM_RIGHT,
                  }, {
                    "CENTER",
                    "TOP",
                    "BOTTOM",
                    "LEFT",
                    "RIGHT",
                    "TOPLEFT",
                    "TOPRIGHT",
                    "BOTTOMLEFT",
                    "BOTTOMRIGHT",
                  }
                else
                  return {
                    addonTable.Locales.PARENT,
                  }, {
                    "PARENT"
                  }
                end
              end,
              setter = function(details, value)
                addonTable.CallbackRegistry:TriggerEvent("Designer.Reanchor", details, value)
              end,
              getter = function(details)
                return details.anchor and details.anchor[1] or "PARENT"
              end,
            },
            {
              label = addonTable.Locales.LAYOUT,
              kind = "dropdown",
              getInitData = function()
                return {
                  addonTable.Locales.VERTICAL,
                  addonTable.Locales.HORIZONTAL,
                }, {
                  "vertical",
                  "horizontal"
                }
              end,
              setter = function(details, value)
                if details.layout ~= value then
                  details.alignment = "CENTER"
                end
                details.layout = value
              end,
              getter = function(details)
                return details.layout
              end,
            },
            {
              label = addonTable.Locales.ALIGNMENT,
              kind = "dropdown",
              getInitData = function(details)
                if details.layout == "vertical" then
                  return {
                    addonTable.Locales.LEFT,
                    addonTable.Locales.CENTER,
                    addonTable.Locales.RIGHT,
                  }, {
                    "LEFT",
                    "CENTER",
                    "RIGHT",
                  }
                else
                  return {
                    addonTable.Locales.TOP,
                    addonTable.Locales.CENTER,
                    addonTable.Locales.BOTTOM,
                  }, {
                    "TOP",
                    "CENTER",
                    "BOTTOM",
                  }
                end
              end,
              setter = function(details, value)
                details.alignment = value
              end,
              getter = function(details)
                return details.alignment
              end,
            },
            {
              label = addonTable.Locales.TRANSPARENCY,
              kind = "slider",
              min = 0, max = 100,
              formatter = function(value) return value .. "%" end,
              setter = function(details, value)
                details.alpha = 1 - value / 100
              end,
              getter = function(details)
                return (1 - details.alpha) * 100
              end,
            },
            {
              label = addonTable.Locales.PADDING,
              kind = "slider",
              min = 0, max = 200,
              valuePattern = "%d%%",
              setter = function(details, value)
                details.padding = value / 100
              end,
              getter = function(details)
                return details.padding * 100
              end,
            },
          }
        },
        {
          label = addonTable.Locales.VISIBILITY,
          entries = {
            {
              label = "",
              kind = "groupVisibility",
              setter = function() end,
              getter = function(details) return details end,
            }
          }
        }
      }
    }
  },
  ["spacer"] = {
    ["*"] = {
      ["*"] = {
        {
          label = addonTable.Locales.GENERAL,
          entries = {
            presets,
            { kind = "spacer" },
            {
              label = addonTable.Locales.WIDTH,
              kind = "slider",
              min = 25, max = 800,
              valuePattern = "%d%%",
              setter = function(details, value)
                details.width = value / 100
              end,
              getter = function(details)
                return details.width * 100
              end,
            },
            {
              label = addonTable.Locales.HEIGHT,
              kind = "slider",
              min = 25, max = 800,
              valuePattern = "%d%%",
              setter = function(details, value)
                details.height = value / 100
              end,
              getter = function(details)
                return details.height * 100
              end,
            },
          }
        }
      }
    }
  }
}

addonTable.Designer.IconTextsConfig = {
  ["cooldown"] = {
    {
      label = addonTable.Locales.VISIBLE,
      kind = "checkbox",
      setter = function(details, value)
        details.visible = value
      end,
      getter = function(details)
        return details.visible
      end,
    },
    {
      label = addonTable.Locales.SCALE,
      kind = "slider",
      min = 25, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.scale = value / 100
      end,
      getter = function(details)
        return details.scale * 100
      end,
    },
    {
      label = addonTable.Locales.WIDTH_RESTRICTION,
      kind = "slider",
      min = 10, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.widthLimit = value / 100
      end,
      getter = function(details)
        return details.widthLimit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.color = value
      end,
      getter = function(details)
        return details.color
      end,
    },
    {
      label = addonTable.Locales.SHOW_FRACTIONS,
      kind = "checkbox",
      setter = function(details, value)
        if details.showFractions ~= nil then
          details.showFractions = value
        end
      end,
      getter = function(details)
        return details.showFractions
      end,
    },
  },
  ["count"] = {
    {
      label = addonTable.Locales.VISIBLE,
      kind = "checkbox",
      setter = function(details, value)
        details.visible = value
      end,
      getter = function(details)
        return details.visible
      end,
    },
    {
      label = addonTable.Locales.SCALE,
      kind = "slider",
      min = 25, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.scale = value / 100
      end,
      getter = function(details)
        return details.scale * 100
      end,
    },
    {
      label = addonTable.Locales.WIDTH_RESTRICTION,
      kind = "slider",
      min = 10, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.widthLimit = value / 100
      end,
      getter = function(details)
        return details.widthLimit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.color = value
      end,
      getter = function(details)
        return details.color
      end,
    },
  },
  ["keybinding"] = {
    {
      label = addonTable.Locales.VISIBLE,
      kind = "checkbox",
      setter = function(details, value)
        details.visible = value
      end,
      getter = function(details)
        return details.visible
      end,
    },
    {
      label = addonTable.Locales.SCALE,
      kind = "slider",
      min = 25, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.scale = value / 100
      end,
      getter = function(details)
        return details.scale * 100
      end,
    },
    {
      label = addonTable.Locales.WIDTH_RESTRICTION,
      kind = "slider",
      min = 10, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.widthLimit = value / 100
      end,
      getter = function(details)
        return details.widthLimit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.color = value
      end,
      getter = function(details)
        return details.color
      end,
    },
  }
}

addonTable.Designer.BarTextsConfig = {
  ["name"] = {
    {
      label = addonTable.Locales.VISIBLE,
      kind = "checkbox",
      setter = function(details, value)
        details.visible = value
      end,
      getter = function(details)
        return details.visible
      end,
    },
    {
      label = addonTable.Locales.SCALE,
      kind = "slider",
      min = 25, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.scale = value / 100
      end,
      getter = function(details)
        return details.scale * 100
      end,
    },
    {
      label = addonTable.Locales.WIDTH_RESTRICTION,
      kind = "slider",
      min = 10, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.widthLimit = value / 100
      end,
      getter = function(details)
        return details.widthLimit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.color = value
      end,
      getter = function(details)
        return details.color
      end,
    },
  },
  ["duration"] = {
    {
      label = addonTable.Locales.VISIBLE,
      kind = "checkbox",
      setter = function(details, value)
        details.visible = value
      end,
      getter = function(details)
        return details.visible
      end,
    },
    {
      label = addonTable.Locales.SCALE,
      kind = "slider",
      min = 25, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.scale = value / 100
      end,
      getter = function(details)
        return details.scale * 100
      end,
    },
    {
      label = addonTable.Locales.WIDTH_RESTRICTION,
      kind = "slider",
      min = 10, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.widthLimit = value / 100
      end,
      getter = function(details)
        return details.widthLimit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.color = value
      end,
      getter = function(details)
        return details.color
      end,
    },
    { kind = "spacer" },
    {
      label = addonTable.Locales.DISPLAY,
      kind = "dropdown",
      getInitData = function(details)
        return {
          addonTable.Locales.ELAPSED,
          addonTable.Locales.REMAINING,
          addonTable.Locales.ELAPSED .. " / " .. addonTable.Locales.TOTAL,
          addonTable.Locales.REMAINING .. " / " .. addonTable.Locales.TOTAL,
        }, {1, 2, 3, 4}
      end,
      setter = function(details, value)
        if value == 1 then
          details.display = {"elapsed"}
        elseif value == 2 then
          details.display = {"remaining"}
        elseif value == 3 then
          details.display = {"elapsed", "total"}
        elseif value == 4 then
          details.display = {"remaining", "total"}
        end
      end,
      getter = function(details)
        if #details.display == 2 then
          if details.display[1] == "elapsed" then
            return 3
          elseif details.display[1] == "remaining" then
            return 4
          end
        else
          if details.display[1] == "elapsed" then
            return 1
          elseif details.display[1] == "remaining" then
            return 2
          end
        end
      end,
    },
    {
      label = addonTable.Locales.SHOW_FRACTIONS,
      kind = "checkbox",
      setter = function(details, value)
        details.showFractions = value
      end,
      getter = function(details)
        return details.showFractions
      end,
    },
  },
  ["value"] = {
    {
      label = addonTable.Locales.VISIBLE,
      kind = "checkbox",
      setter = function(details, value)
        details.visible = value
      end,
      getter = function(details)
        return details.visible
      end,
    },
    {
      label = addonTable.Locales.SCALE,
      kind = "slider",
      min = 25, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.scale = value / 100
      end,
      getter = function(details)
        return details.scale * 100
      end,
    },
    {
      label = addonTable.Locales.WIDTH_RESTRICTION,
      kind = "slider",
      min = 10, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.widthLimit = value / 100
      end,
      getter = function(details)
        return details.widthLimit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.color = value
      end,
      getter = function(details)
        return details.color
      end,
    },
    { kind = "spacer" },
    {
      label = addonTable.Locales.USE_PERCENTAGE,
      kind = "checkbox",
      setter = function(details, value)
        details.usePercentage = value
      end,
      getter = function(details)
        return details.usePercentage
      end,
    },
  },
  ["applications"] = {
    {
      label = addonTable.Locales.VISIBLE,
      kind = "checkbox",
      setter = function(details, value)
        details.visible = value
      end,
      getter = function(details)
        return details.visible
      end,
    },
    {
      label = addonTable.Locales.SCALE,
      kind = "slider",
      min = 25, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.scale = value / 100
      end,
      getter = function(details)
        return details.scale * 100
      end,
    },
    {
      label = addonTable.Locales.WIDTH_RESTRICTION,
      kind = "slider",
      min = 10, max = 300,
      valuePattern = "%d%%",
      setter = function(details, value)
        details.widthLimit = value / 100
      end,
      getter = function(details)
        return details.widthLimit * 100
      end,
    },
    {
      label = addonTable.Locales.COLOR,
      kind = "colorPicker",
      setter = function(details, value)
        details.color = value
      end,
      getter = function(details)
        return details.color
      end,
    },
  },
}
