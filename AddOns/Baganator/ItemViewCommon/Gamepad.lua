---@class addonTableBaganator
local addonTable = select(2, ...)

local buttonMapping = {
  ["A"] = "PAD1",
  ["B"] = "PAD2",
  ["X"] = "PAD3",
  ["Y"] = "PAD4",
  ["MENU"] = "PADFORWARD",
  ["D-LEFT"] = "PADDLEFT",
  ["D-RIGHT"] = "PADDRIGHT",
  ["D-DOWN"] = "PADDDDOWN",
  ["D-UP"] = "PADDUP",
}
if addonTable.Constants.IsGamepadInUse then
  local directions = {
    ["Left"] = SMART_NAV_INPUT_DIRECTION.LEFT,
    ["Right"] = SMART_NAV_INPUT_DIRECTION.RIGHT,
    ["Up"] = SMART_NAV_INPUT_DIRECTION.UP,
    ["Down"] = SMART_NAV_INPUT_DIRECTION.DOWN,
  }

  function addonTable.Gamepad.LinkButtons(button1, direction, button2)
    SmartNavigation_AddBidirectionalJumpNavigationOverride(button1, directions[direction], button2)
  end
  function addonTable.Gamepad.OneWayLink(button1, direction, button2)
    SmartNavigation_AddJumpNavigationOverride(button1, directions[direction], button2)
  end
  function addonTable.Gamepad.ResetAssociations(button1)
    SmartNavigation_ClearJumpNavigationOverrides(button1)
  end
  function addonTable.Gamepad.AnnounceShow(frame)
    C_Timer.After(0, function()
      GamepadMode.FrameControlsManager:FrameShown(frame)
    end)
  end
  function addonTable.Gamepad.AnnounceHide(frame)
      GamepadMode.FrameControlsManager:FrameHidden(frame)
  end

  function addonTable.Gamepad.SetTargetButton(frame, target)
    SmartNavigation:SetTargetButtonForFrame(frame, target)
  end
  function addonTable.Gamepad.SelectFirstButton(frame)
    SmartNavigation:SelectFirstButton(frame, true)
  end

else
  function addonTable.Gamepad.LinkButtons(button1, direction, button2)
  end
  function addonTable.Gamepad.OneWayLink(button1, direction, button2)
  end
  function addonTable.Gamepad.AnnounceShow(frame)
  end
  function addonTable.Gamepad.AnnounceHide(frame)
  end
  function addonTable.Gamepad.SetTargetButton(frame, target)
  end
  function addonTable.Gamepad.SelectFirstButton(frame)
  end
end
