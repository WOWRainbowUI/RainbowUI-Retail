local enabled = false
local gameMenuFrameHook_OnShow = false
local wasKeybindModeTrigger = false
local quickKeybindModeShortcutFrame = nil

local function isFunction(object)
  if type(object) == "function" then
    return true
  end

  return false
end

local function quickKeybindModeShortcutFrame_OnClick()
  QuickKeybindFrame:Show()
  GameMenuFrame:Hide()
  wasKeybindModeTrigger = true
end

local function quickKeybinddModeAddButton()
  if enabled then
    if isFunction(GameMenuFrame.AddSection) and isFunction(GameMenuFrame.AddButton) then
      GameMenuFrame:AddSection()
      GameMenuFrame:AddButton("Quick Keybind Mode", quickKeybindModeShortcutFrame_OnClick, false, "testdisabled")
    else
      -- Legacy way, will not be needed after The War Within releases (likely pre-patch)
      if not quickKeybindModeShortcutFrame then
        quickKeybindModeShortcutFrame = CreateFrame("Button", "BUIIQuickKeybindModeShortcutMenuButton", GameMenuFrame, "GameMenuButtonTemplate")
        quickKeybindModeShortcutFrame:SetText("Quick Keybind Mode")
        quickKeybindModeShortcutFrame:SetScript("OnClick", quickKeybindModeShortcutFrame_OnClick)
	quickKeybindModeShortcutFrame:SetPoint("TOP", GameMenuButtonContinue, "BOTTOM", 0, -(quickKeybindModeShortcutFrame:GetHeight() / 1.5))
      end

      -- Try and match the look we will have when using AddSection and AddButton
      GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + quickKeybindModeShortcutFrame:GetHeight() * 1.5)
      if not quickKeybindModeShortcutFrame:IsVisible() then
        quickKeybindModeShortcutFrame:Show()
      end
    end
  end
end

local function quickKeybindMode_OnDisable()
  if wasKeybindModeTrigger then
    -- Have to show the GameMenuFrame again otherwise SettingsPanel is shown
    GameMenuFrame:Show()
    wasKeybindModeTrigger = false
  end
end

function BUII_QuickKeybindModeShortcutEnable()
  enabled = true

  if not gameMenuFrameHook_OnShow then
    gameMenuFrameHook_OnShow = true
    GameMenuFrame:HookScript("OnShow", quickKeybinddModeAddButton)
    EventRegistry:RegisterCallback("QuickKeybindFrame.QuickKeybindModeDisabled", quickKeybindMode_OnDisable, "BUII_QuickKeybindMode_OnDisable")
  end
end

function BUII_QuickKeybindModeShortcutDisable()
  enabled = false
end
