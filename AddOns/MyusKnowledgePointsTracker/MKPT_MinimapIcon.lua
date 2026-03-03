local AddonName, MKPT_env, _ = ...

local Utils = MKPT_env.Utils

local minimapIcon = LibStub("LibDBIcon-1.0")

local MKPT_LDB = LibStub("LibDataBroker-1.1"):NewDataObject("MyusKnowledgePointsTracker", {
  type = "data source",
  text = "Myu's Knowledge Points Tracker",
  icon = "Interface\\AddOns\\"..AddonName.."\\Textures\\MKPT_Minimap",
  OnClick = function(_, buttonName)
    if buttonName == "LeftButton" then
      MKPT_env.ToggleUi()
    elseif buttonName == "RightButton" then
      MKPT_env.ShowRightClickMenu()
    end
  end,
  OnTooltipShow = function(tooltip)
    if not tooltip then return end

    tooltip:AddLine(Utils.WhiteTextColor("Myu's Knowledge Points Tracker"))
    tooltip:AddLine("\n")
    tooltip:AddLine(CreateAtlasMarkup("newplayertutorial-icon-mouse-leftbutton")..BINDING_NAME_MOVIE_RECORDING_GUI)
    tooltip:AddLine(CreateAtlasMarkup("newplayertutorial-icon-mouse-rightbutton")..CLICK_BINDING_OPEN_MENU)
  end
})

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
