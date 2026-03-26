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
  print("可用指令：")
  print(Utils.GoldTextColor("/mkpt"), " - 顯示/隱藏插件介面")
  print(Utils.GoldTextColor("/mkpt minimap"), " - 顯示/隱藏小地圖按鈕")
  print(Utils.GoldTextColor("/mkpt compartment"), " - 顯示/隱藏插件在小地圖選單中的入口")
  print(Utils.GoldTextColor("/mkpt scale 1.0"), " - 調整介面大小，接受 0.5 到 1.5 的數值")
  print(Utils.GoldTextColor("/mkpt lock"), " - 鎖定視窗位置")
  print(Utils.GoldTextColor("/mkpt unlock"), " - 解鎖視窗位置")
  print(Utils.GoldTextColor("/mkpt config"), " - 打開設定選單")
  print(Utils.GoldTextColor("/mkpt autohide"), " - 當滑鼠不在視窗上時自動隱藏")
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
