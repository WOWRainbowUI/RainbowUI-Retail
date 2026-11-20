---@class addonTableBaganator
local addonTable = select(2, ...)

local generator = {
  customise = "BaganatorCustomiseButtonTemplate",
  bagSlots = "BaganatorToggleBagSlotsButtonTemplate",
  sort = "BaganatorSortButtonTemplate",
  transfer = "BaganatorTransferButtonTemplate",
  allCharacters = "BaganatorAllCharactersButtonTemplate",
  bank = "BaganatorBankButtonTemplate",
  guild = "BaganatorGuildBankButtonTemplate",
  swap = "BaganatorSwapButtonTemplate",
  toggleGrouping = "BaganatorGroupButtonTemplate",
}

addonTable.ItemViewCommon.ButtonsMixin = {}
function addonTable.ItemViewCommon.ButtonsMixin:OnLoad()
  self:ClearButtons()
  self:SetScript("OnEvent", self.OnEvent)
  self:SetScript("OnShow", self.OnShow)
  self:SetScript("OnHide", self.OnHide)

  self.cache = {}
end

function addonTable.ItemViewCommon.ButtonsMixin:ClearButtons(isVisibilityOnly)
  if not isVisibilityOnly then
    self.positions = {
      topLeft = {},
      topRight = {},
    }
  end
  self.visibilityOnly = {}
end

function addonTable.ItemViewCommon.ButtonsMixin:AddButton(positionOrFrame, kind, callback, condition, textCallback)
  if type(positionOrFrame) == "string" then
    table.insert(self.positions[positionOrFrame], {
      kind = kind,
      callback = callback,
      condition = condition or function() return true end,
      text = textCallback,
    })
  else
    table.insert(self.visibilityOnly, positionOrFrame)
  end
end

function addonTable.ItemViewCommon.ButtonsMixin:SetGamepadDown(button)
  self.gamepadDown = button
end

function addonTable.ItemViewCommon.ButtonsMixin:GetButton(kind)
  if not self.cache[kind] then
    self.cache[kind] = CreateFrame("Button", nil, self:GetParent(), generator[kind])
  end

  return self.cache[kind]
end

function addonTable.ItemViewCommon.ButtonsMixin:Arrange()
  for _, button in pairs(self.cache) do
    button:ClearAllPoints()
    button:Hide()
  end

  self.active = {
    topLeft = {},
    topRight = {},
  }

  local buttonSettings = addonTable.Config.Get(addonTable.Config.Options.BUTTONS)
  local prevLeft
  for _, details in ipairs(self.positions.topLeft) do
    local visibility = buttonSettings[details.kind]
    if visibility == "default" then
      visibility = addonTable.Config.Get(addonTable.Config.Options.SHOW_BUTTONS_ON_ALT) and "alt" or "show"
    end
    if details.condition() and (visibility == "show" or visibility == "alt" and IsAltKeyDown()) then
      local button = self:GetButton(details.kind)
      button:Show()
      button:SetFrameLevel(700)
      if details.callback then
        button:SetScript("OnClick", details.callback)
      end
      if details.text then
        button.tooltipText = details.text()
      end
      addonTable.Gamepad.ResetAssociations(button)
      addonTable.Gamepad.OneWayLink(button, "Down", self.gamepadDown)
      if prevLeft then
        button:SetPoint("LEFT", prevLeft, "RIGHT")
        addonTable.Gamepad.LinkButtons(button, "Left", prevLeft)
      else
        addonTable.Gamepad.LinkButtons(button, "Down", self.gamepadDown)
        button:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", addonTable.Constants.ButtonFrameOffset, addonTable.Constants.ButtonFrameOffsetTop)
      end
      table.insert(self.active.topLeft, button)
      prevLeft = button
    end
  end

  local prevRight
  for i = #self.positions.topRight, 1, -1 do
    local details = self.positions.topRight[i]
    local visibility = buttonSettings[details.kind]
    if visibility == "default" then
      visibility = addonTable.Config.Get(addonTable.Config.Options.SHOW_BUTTONS_ON_ALT) and "alt" or "show"
    end
    if details.condition() and (visibility == "show" or visibility == "alt" and IsAltKeyDown()) then
      local button = self:GetButton(details.kind)
      button:Show()
      button:SetFrameLevel(700)
      if details.callback then
        button:SetScript("OnClick", details.callback)
      end
      if details.text then
        button.tooltipText = details.text()
      end
      addonTable.Gamepad.ResetAssociations(button)
      addonTable.Gamepad.OneWayLink(button, "Down", self.gamepadDown)
      if prevRight then
        button:SetPoint("RIGHT", prevRight, "LEFT")
        addonTable.Gamepad.LinkButtons(button, "Right", prevRight)
      elseif addonTable.Constants.IsGamepadInUse or not self:GetParent().CloseButton then
        button:SetPoint("TOPRIGHT", self:GetParent(), "TOPRIGHT", -5, addonTable.Constants.ButtonFrameOffsetTop)
      else
        button:SetPoint("RIGHT", self:GetParent().CloseButton, "LEFT", 0, 0)
      end
      table.insert(self.active.topRight, button)
      prevRight = button
    end
  end
  if prevRight and prevLeft then
    addonTable.Gamepad.LinkButtons(prevLeft, "Right", prevRight)
  end

  local shown = true
  if addonTable.Config.Get(addonTable.Config.Options.SHOW_BUTTONS_ON_ALT) and not IsAltKeyDown() then
    shown = false
  end
  addonTable.CallbackRegistry:TriggerEvent("SetButtonsShown", shown)

  for _, button in ipairs(self.visibilityOnly) do
    button:SetShown(shown)
  end
end

function addonTable.ItemViewCommon.ButtonsMixin:OnEvent()
  self:Arrange()
end

function addonTable.ItemViewCommon.ButtonsMixin:OnShow()
  self:RegisterEvent("MODIFIER_STATE_CHANGED")
  addonTable.CallbackRegistry:RegisterCallback("PropagateAlt", self.Arrange, self)

  addonTable.CallbackRegistry:RegisterCallback("SettingChanged",  function(_, settingName)
    if settingName == addonTable.Config.Options.SHOW_BUTTONS_ON_ALT or settingName:match("^buttons%.") then
      self:Arrange()
    end
  end, self)
end

function addonTable.ItemViewCommon.ButtonsMixin:OnHide()
  self:UnregisterEvent("MODIFIER_STATE_CHANGED")
  addonTable.CallbackRegistry:UnregisterCallback("PropagateAlt", self)
  addonTable.CallbackRegistry:UnregisterCallback("SettingChanged", self)
end
