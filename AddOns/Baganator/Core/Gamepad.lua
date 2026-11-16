local addonTable = select(2, ...)

addonTable.Gamepad.ButtonMapping = {
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
  function addonTable.Gamepad.ResetAssociations(button)
    SmartNavigation_ClearJumpNavigationOverrides(button)
  end
  function addonTable.Gamepad.AnnounceShow(frame, isPopup, shouldFocus)
    C_Timer.After(0, function()
      GamepadMode.FrameControlsManager:FrameShown(frame, isPopup, shouldFocus)
    end)
  end
  function addonTable.Gamepad.AnnounceHide(frame, isPopup)
    GamepadMode.FrameControlsManager:FrameHidden(frame)
  end

  function addonTable.Gamepad.SetTargetButton(frame, target)
    SmartNavigation:SetTargetButtonForFrame(frame, target)
  end
  function addonTable.Gamepad.SetScrollBox(frame, scrollBox)
    SmartNavigation:SetScrollFrameForFrame(frame, scrollBox)
  end
  function addonTable.Gamepad.SelectFirstButton(frame)
    SmartNavigation:SelectFirstButton(frame, true)
  end

  function addonTable.Gamepad.AllowFocus(frame)
    SmartNavigation_MarkFrameFocusable(frame)
  end

  function addonTable.Gamepad.GetBindingsFooter(bindings, parent, offsetX, offsetY)
    local gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(parent);
    for _, b in ipairs(bindings) do
      if b.isBack then
        gamepadFooter:AddStandardBackPrompt(b.label);
      else
        local widget = GamepadSharedUtility.CreatePromptedBinding(b.button, nil, b.label)
        widget:SetVisibilityType(b.visibility == "auto" and PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE or PromptedBindingMixin.VISIBILITY_TYPE.ALWAYS)
        if b.condition then
          widget:AddCondition(b.condition)
        end
        gamepadFooter:AddPromptedBinding(widget);
      end
    end
    function gamepadFooter:Refresh()
      self:RefreshPromptedBindingsActive();
      self:RefreshInputLegend();
    end
    gamepadFooter:SetAnchorOffsets(offsetX or 10, offsetY or 6);
    gamepadFooter:Finalize();

    return gamepadFooter
  end

else
  function addonTable.Gamepad.LinkButtons(button1, direction, button2)
  end
  function addonTable.Gamepad.OneWayLink(button1, direction, button2)
  end
  function addonTable.Gamepad.ResetAssociations(button)
  end
  function addonTable.Gamepad.AnnounceShow(frame)
  end
  function addonTable.Gamepad.AnnounceHide(frame)
  end
  function addonTable.Gamepad.SetTargetButton(frame, target)
  end
  function addonTable.Gamepad.SetScrollBox(frame, scrollBox)
  end
  function addonTable.Gamepad.SelectFirstButton(frame)
  end
  function addonTable.Gamepad.AllowFocus(frame)
  end
end
