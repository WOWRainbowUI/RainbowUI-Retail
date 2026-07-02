local AddonName, MKPT_env, _ = ...

local Utils = MKPT_env.Utils
local L = MKPT_env.L

local minimapIcon = LibStub("LibDBIcon-1.0")

local MKPT_LDB = LibStub("LibDataBroker-1.1"):NewDataObject("MyusKnowledgePointsTracker", {
  type = "data source",
  text = L["Myu's Knowledge Points Tracker"],
  icon = "Interface\\AddOns\\" .. AddonName .. "\\Textures\\MKPT_Minimap",
  OnClick = function(_, buttonName)
    if buttonName == "LeftButton" then
      if IsControlKeyDown() then
        MKPT_env.ToggleAutoHide()
      else
        MKPT_env.ToggleUi()
      end
    elseif buttonName == "RightButton" then
      MKPT_env.ShowRightClickMenu()
    end
  end,
  OnTooltipShow = function(tooltip)
    if not tooltip then return end

    local f = MKPT_env.ui
    if f and f:IsShown() and f:GetAlpha() < 0.99 then
      UIFrameFadeIn(f, 0.1, f:GetAlpha(), 1)
      UIFrameFadeIn(f, 0.1, f.hideButton:GetAlpha(), 1)
      UIFrameFadeIn(f, 0.1, f.closeButton:GetAlpha(), 1)
    end

    tooltip:AddLine(Utils.WhiteTextColor(L["Myu's Knowledge Points Tracker"]))
    tooltip:AddLine("\n")
    tooltip:AddLine(CreateAtlasMarkup("newplayertutorial-icon-mouse-leftbutton") .. " - " .. BINDING_NAME_MOVIE_RECORDING_GUI)
    tooltip:AddLine(CreateAtlasMarkup("newplayertutorial-icon-mouse-rightbutton") .. " - " .. CLICK_BINDING_OPEN_MENU)
    tooltip:AddLine(Utils.WhiteTextColor("Ctrl+")..CreateAtlasMarkup("newplayertutorial-icon-mouse-leftbutton") .. " - " .. L["Auto Hide on/off"])
  end,
  OnLeave = function(displayFrame)
    MKPT_env.RefreshAutoHide()
  end
}
)

function MKPT_env.InitializeMinimapIcon()
  local db = MKPT_env.db
  minimapIcon:Register(AddonName, MKPT_LDB, db.minimap)
  if not db.minimap.hide then
    minimapIcon:Show(AddonName)
  end
end

function MKPT_env.ToggleMinimapIcon()
  local db = MKPT_env.db
  db.minimap.hide = not db.minimap.hide

  if db.minimap.hide then
    minimapIcon:Hide(AddonName)
  else
    minimapIcon:Show(AddonName)
  end
end

function MKPT_env.InitializeCompartmentIcon()
  local db = MKPT_env.db
  if db.compartment.hide then
    minimapIcon:RemoveButtonFromCompartment(AddonName)
  else
    minimapIcon:AddButtonToCompartment(AddonName)
  end
end

function MKPT_env.ToggleCompartmentIcon()
  local db = MKPT_env.db
  db.compartment.hide = not db.compartment.hide

  if db.compartment.hide then
    minimapIcon:RemoveButtonFromCompartment(AddonName)
  else
    minimapIcon:AddButtonToCompartment(AddonName)
  end
end
