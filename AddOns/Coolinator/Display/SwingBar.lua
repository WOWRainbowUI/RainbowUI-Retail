---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Display.SwingBarMixin = CreateFromMixins(addonTable.Display.BaseDurationStatusBarMixin)

function addonTable.Display.SwingBarMixin:OnLoad()
  addonTable.Display.BaseDurationStatusBarMixin.OnLoad(self)
  self:SetScript("OnEvent", self.OnEvent)
end

function addonTable.Display.SwingBarMixin:Enable(details)
  addonTable.CallbackRegistry:RegisterCallback("Update.SwingTimer", function(_, kind)
    if kind == self.swingType then
      self:UpdateForDuration()
    end
  end, self)

  self:RegisterEvent("PLAYER_SWING_RANGE_UPDATE")
end

function addonTable.Display.SwingBarMixin:Disable(details)
  addonTable.CallbackRegistry:UnregisterCallback("Update.SwingTimer", self)
  self:UnregisterAllEvents()
end

function addonTable.Display.SwingBarMixin:Setup(details)
  addonTable.Display.BaseDurationStatusBarMixin.Setup(self, details)

  if details.resource.weapon == "off-hand" then
    self.swingType = Enum.PlayerSwingType.OffHand
  elseif details.resource.weapon == "ranged" then
    self.swingType = Enum.PlayerSwingType.Ranged
  elseif details.resource.weapon == "main-hand" then
    self.swingType = Enum.PlayerSwingType.MainHand
  else
    error("wrong type: " .. tostring(details.resource.weapon))
  end

  self.TextsContainer.Name:SetText(addonTable.Constants.BarSwingResourceMap[details.resource.weapon])

	--C_SwingTimer.EnableRangeCheck(self.swingType, true);

  self:UpdateForDuration()
  self:UpdateForRange()
end

function addonTable.Display.SwingBarMixin:OnEvent()
  self:UpdateForRange()
end

function addonTable.Display.SwingBarMixin:UpdateForDuration()
  local duration = addonTable.Display.GetSwingDuration(self.swingType)
  self.statusBar:SetTimerDuration(duration, nil, Enum.StatusBarTimerDirection.ElapsedTime)

  self.DurationBinding:SetDuration(duration)
  self.DurationBinding:Enable()
  self.DurationBinding:UpdateFontString()
end

function addonTable.Display.SwingBarMixin:UpdateForRange()
  --local inRange = C_SwingTimer.IsTargetWithinSwingRange(self.swingType)
end
