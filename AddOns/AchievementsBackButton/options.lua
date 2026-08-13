local folderName, Addon = ...


-- The three ways our back button can coexist with the back button
-- Blizzard added to the achievements frame in 12.1.0.
Addon.MODE_HIDE_BLIZZARD    = "hideBlizzard"
Addon.MODE_SIDE_BY_SIDE     = "sideBySide"
Addon.MODE_REPLACE_BLIZZARD = "replaceBlizzard"


local CONFIG_DEFAULTS = {
  mode = Addon.MODE_HIDE_BLIZZARD,
}


local addonLoadedFrame = CreateFrame("Frame")
addonLoadedFrame:RegisterEvent("ADDON_LOADED")
addonLoadedFrame:SetScript("OnEvent", function(self, event, arg1)
  if arg1 ~= folderName then return end

  ABB_config = ABB_config or {}

  -- Remove obsolete values from saved variables.
  for k in pairs(ABB_config) do
    if CONFIG_DEFAULTS[k] == nil then
      ABB_config[k] = nil
    end
  end

  -- Fill missing values. Use an explicit nil check so boolean false values from
  -- the saved variables are preserved and not treated as "missing".
  for k, v in pairs(CONFIG_DEFAULTS) do
    if ABB_config[k] == nil then
      ABB_config[k] = v
    end
  end

  -- Guard against a saved mode that no longer exists.
  if ABB_config.mode ~= Addon.MODE_HIDE_BLIZZARD
     and ABB_config.mode ~= Addon.MODE_SIDE_BY_SIDE
     and ABB_config.mode ~= Addon.MODE_REPLACE_BLIZZARD then
    ABB_config.mode = CONFIG_DEFAULTS.mode
  end

  self:UnregisterEvent("ADDON_LOADED")
end)


Addon.GetMode = function()
  return ABB_config and ABB_config.mode or CONFIG_DEFAULTS.mode
end



-- Create a custom tooltip frame that we control
local customTooltip = CreateFrame("GameTooltip", "ABB_CustomTooltip", UIParent, "GameTooltipTemplate")
customTooltip:SetFrameStrata("TOOLTIP")
customTooltip:Hide()

local customTooltipHideTimer = nil

local function ShowCustomTooltip(anchorFrame, title, text)
  if customTooltipHideTimer then
    customTooltipHideTimer:Cancel()
    customTooltipHideTimer = nil
  end

  customTooltip:SetOwner(anchorFrame, "ANCHOR_RIGHT")
  customTooltip:ClearLines()
  GameTooltip_SetTitle(customTooltip, title)
  GameTooltip_AddNormalLine(customTooltip, text)
  customTooltip:Show()
end

-- Hide the tooltip after a delay, so that it closes simultaneously with the
-- menu and does not flicker while the mouse travels from one entry to the next.
local function HideCustomTooltipDelayed(delay)
  if customTooltipHideTimer then
    customTooltipHideTimer:Cancel()
  end
  customTooltipHideTimer = C_Timer.NewTimer(delay or 0.33, function()
    customTooltip:Hide()
    customTooltipHideTimer = nil
  end)
end

-- Hide the tooltip without the delay, for when the menu goes away at once.
local function HideCustomTooltipImmediately()
  if customTooltipHideTimer then
    customTooltipHideTimer:Cancel()
    customTooltipHideTimer = nil
  end
  customTooltip:Hide()
end



local MODE_ENTRIES = {
  {
    mode = Addon.MODE_HIDE_BLIZZARD,
    label = "Hide Blizzard's back button",
    tooltip = "Removes the back button Blizzard added in patch 12.1.0 and moves the search box and filter dropdown back to where they were before, so the achievements list regains the space above it.\n\nOnly this addon's back button remains, which takes you back through your whole browsing history instead of just one step after clicking a link inside a meta achievement.",
  },
  {
    mode = Addon.MODE_SIDE_BY_SIDE,
    label = "Show both back buttons",
    tooltip = "Keeps Blizzard's back button and layout next to this addon's button.\n\nBlizzard's button only takes you back one step after clicking a link inside a meta achievement.",
  },
  {
    mode = Addon.MODE_REPLACE_BLIZZARD,
    label = "Use Blizzard's back button",
    tooltip = "Hides this addon's button and gives Blizzard's back button the full browsing history of this addon, so it takes you all the way back instead of just one step after clicking a link inside a meta achievement.\n\nRight-click Blizzard's button to get back to these options.",
  },
}


Addon.OpenOptionsMenu = function()

  MenuUtil.CreateContextMenu(UIParent, function(button, mainMenu)
    mainMenu:CreateTitle("Achievements Back Button")
    mainMenu:CreateDivider()

    for _, entry in ipairs(MODE_ENTRIES) do
      local radio = mainMenu:CreateRadio(
        entry.label,
        function()
          return Addon.GetMode() == entry.mode
        end,
        function()
          ABB_config.mode = entry.mode
          Addon.ApplyMode()
          return MenuResponse.Refresh
        end
      )
      radio:SetOnEnter(function(frame)
        ShowCustomTooltip(frame, entry.label, entry.tooltip)
      end)
      radio:SetOnLeave(function(frame)
        HideCustomTooltipDelayed(0.33)
      end)
    end

  end)
end


-- Called when the achievements frame closes.
Addon.CloseOptionsMenu = function()
  HideCustomTooltipImmediately()
  if Menu and Menu.GetManager then
    Menu.GetManager():CloseMenus()
  end
end
