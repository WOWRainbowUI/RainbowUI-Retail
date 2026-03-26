local AddonName, MKPT_env, _ = ...

local Utils = MKPT_env.Utils

local Commands = {}

function Commands.toggle(_)
  MKPT_env.ToggleUi()
end

function Commands.lock(_)
  MKPT_env.SetLockUi(true)
end

function Commands.unlock(_)
  MKPT_env.SetLockUi(false)
end

function Commands.show(_)
  if not MKPT_env.charDb.state.show then
    MKPT_env.ToggleUi()
  end
end

function Commands.hide(_)
  if MKPT_env.charDb.state.show then
    MKPT_env.ToggleUi()
  end
end

function Commands.minimap(_)
  MKPT_env.ToggleMinimapIcon()
end

function Commands.compartment(_)
  MKPT_env.ToggleCompartmentIcon()
end

function Commands.scale(scale)
  scale = tonumber(scale or 1.0)
  MKPT_env.SetUiScale(scale)
end

function Commands.config(_)
  if InCombatLockdown() then
    return
  end
  Settings.OpenToCategory(MKPT_env.categoryId)
end

function Commands.autohide(_)
  MKPT_env.ToggleAutoHide()
end

function Commands.help(_)
  print("Available commands:")
  print(Utils.GoldTextColor("/mkpt"), " - Show/Hide the addon HUD")
  print(Utils.GoldTextColor("/mkpt minimap"), " - Show/Hide the minimap Icon")
  print(Utils.GoldTextColor("/mkpt compartment"), " - Show/Hide addon entry inside compartment")
  print(Utils.GoldTextColor("/mkpt scale 1.0"), " - Scales the Ui size, accepts values from 0.5 to 1.5")
  print(Utils.GoldTextColor("/mkpt lock"), " - Locks window movement")
  print(Utils.GoldTextColor("/mkpt unlock"), " - Unlocks window movement")
  print(Utils.GoldTextColor("/mkpt config"), " - Opens configuration menu")
  print(Utils.GoldTextColor("/mkpt autohide"), " - Hides the window when the cursor is not over it")
end

function MKPT_env.InitializeSlashCommand()
  SLASH_MKPT1 = "/mkpt"

  SlashCmdList.MKPT = function(arg)
    arg = arg == "" and "toggle" or arg
    local commandName, commandArgs = strsplit(" ", string.lower(arg))

    local command = Commands[commandName]
    if not command then
      print(Utils.GoldTextColor("/mkpt ") .. Utils.RequirementsNotMetColor(arg), "command not found.")
      command = Commands.help
    end

    command(commandArgs)
  end
end
