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

local monitor = CreateFrame("Frame", nil, UIParent)
monitor:EnableGamePadStick(true)
local clicker = CreateFrame("Button", "BaganatorGamepadClicker", UIParent, "InsecureActionButtonTemplate")
local focusPanelIndex = nil
local panels = {}

local function UpdateFocus(forceHide)
  if #panels > 0 then
    for index, p in ipairs(panels) do
      if index == focusPanelIndex and not forceHide then
        if not p.GlowFrame then
          p.layoutType = "ButtonFrameTemplateNoPortrait"
          p.GlowFrame = CreateFrame("Frame", nil, p, "FrameGlowTemplate")
        end
        p.GlowFrame:Show()
      elseif p.GlowFrame then
        p.GlowFrame:Hide()
      end
    end
  end
end

local function UpdateEnable(state)
  monitor:SetShown(state)
  clicker:SetShown(state)
  if not state then
    ClearOverrideBindings(clicker)
  else
    SetOverrideBindingClick(clicker, false, "PAD3", clicker:GetName())
  end
end


if addonTable.Constants.IsGamepadInUse then
  monitor:SetScript("OnGamePadStick", function(self, stick, x, y, len)
    if stick ~= "Left" and stick ~= "Movement" then
      print(stick)
      self:SetPropagateKeyboardInput(true)
    else
      self:SetPropagateKeyboardInput(false)
    end
  end)

  monitor:SetScript("OnGamePadButtonDown", function(self, button)
    if button == buttonMapping["B"] then
      panels[focusPanelIndex]:Hide()
    elseif button == buttonMapping["MENU"] then
      addonTable.CallbackRegistry:TriggerEvent("CloseAll")
      self:SetPropagateKeyboardInput(true)
    end
  end)

  monitor:SetScript("OnGamePadButtonUp", function(self, button)
    print("gpb", button)
  end)

  monitor:Hide()

  monitor:RegisterEvent("PLAYER_REGEN_ENABLED")
  monitor:RegisterEvent("PLAYER_REGEN_DISABLED")
  monitor:SetScript("OnEvent", function(_, event)
    UpdateEnable(#panels > 0 and event ~= "PLAYER_REGEN_ENABLED")
    UpdateFocus(true)
  end)
end

function addonTable.ItemViewCommon.SetGamepadTrap(state, panel)
  if not addonTable.Constants.IsGamepadInUse then
    return
  end
  if state then
    if tIndexOf(panels, panel) ~= nil then
      table.remove(panels, tIndexOf(panels, panel))
    end
    table.insert(panels, panel)
    focusPanelIndex = #panels
    UpdateFocus()
  else
    if tIndexOf(panels, panel) ~= nil then
      table.remove(panels, tIndexOf(panels, panel))
    end
  end
  if InCombatLockdown() then
    return
  end
  UpdateEnable(#panels > 0)
end

function addonTable.ItemViewCommon.SetInitialButton(button)
  if not addonTable.Constants.IsGamepadInUse then
    return
  end

  clicker:SetAttribute("type", "click")
  clicker:SetAttribute("clickbutton", button)
end
