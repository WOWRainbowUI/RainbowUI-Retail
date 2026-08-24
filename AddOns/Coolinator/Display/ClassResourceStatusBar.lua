---@class addonTableCoolinator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

local GetDefaultSize = addonTable.Display.GetDefaultStatusBarSize

addonTable.Display.ClassResourceStatusBar = {}

local function SizeStatusBar(self, width, height)
  local sizing = addonTable.Display.GetSizingForStatusBar(self, width, height)
  self.sizingWidth, self.sizingHeight = sizing.rawWidth, sizing.rawHeight
  self:SetSize(sizing.rawWidth, sizing.rawHeight)
  PixelUtil.SetSize(self.border, sizing.borderWidth * self.lowerScale, sizing.borderHeight * self.lowerScale)
  PixelUtil.SetSize(self.statusBar, sizing.statusWidth * self.lowerScale, sizing.statusHeight * self.lowerScale)
end

local function PadStatusBar(self, horizontal, vertical)
  PixelUtil.SetSize(self, self.sizingWidth + horizontal, self.sizingHeight + vertical)
end

addonTable.Display.ClassResourceStatusBar.stagger = {}

function addonTable.Display.ClassResourceStatusBar.stagger:OnLoad()
  self:SetIgnoringChildrenForBounds(true)
  self.statusBar = CreateFrame("StatusBar", nil, self)
  self.statusBar:SetPoint("CENTER")
  self.statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", "Cooli: Solid Transparency"))
  self.fadedStatusBar = CreateFrame("StatusBar", nil, self)
  self.fadedStatusBar:SetFillStyle(Enum.StatusBarFillStyle.Reverse)

  self.background = self.statusBar:CreateTexture(nil, "BACKGROUND")
  self.background:SetAllPoints(self.statusBar)
  self.borderWrapper = CreateFrame("Frame", nil, self)
  self.borderWrapper:SetAllPoints()
  self.border = self.borderWrapper:CreateTexture(nil, "BORDER")
  self.border:SetPoint("CENTER")
  self.borderMask = self.statusBar:CreateMaskTexture()
  self.borderMask:SetAllPoints(self.statusBar)

  self.GetDefaultSize = GetDefaultSize

  self.text = self.statusBar:CreateFontString()

end

function addonTable.Display.ClassResourceStatusBar.stagger:OnUpdate()
  local maxHealth = UnitHealthMax("player")
  local limit = maxHealth * self.details.resource.options.multiplier
  local current = UnitStagger("player")
  if issecretvalue(current) then
    return
  end
  self.statusBar:SetMinMaxValues(0, limit)
  self.statusBar:SetValue(current)
  self.fadedStatusBar:SetMinMaxValues(0, limit)
  self.fadedStatusBar:SetValue(math.min(current, math.max(0.08 * maxHealth, current * 0.5)))
  self.fadedStatusBar:SetAlphaFromBoolean(C_Spell.GetSpellCooldownDuration(119582, true):IsZero())
  for _, threshold in ipairs(self.details.thresholdColors) do
    if current/maxHealth <= threshold.limit then
      self.statusBar:GetStatusBarTexture():SetVertexColor(threshold.color.r, threshold.color.g, threshold.color.b)
      self.fadedStatusBar:GetStatusBarTexture():SetVertexColor(threshold.fadedColor.r, threshold.fadedColor.g, threshold.fadedColor.b)
      break
    end
  end
end

function addonTable.Display.ClassResourceStatusBar.stagger:Setup(details)
  self:SetScript("OnUpdate", self.OnUpdate)

  self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)

  self.fadedStatusBar:SetScale(1/self.lowerScale * details.scale)
  local backgroundAsset = LSM:Fetch("statusbar", details.foreground.asset, true) or LSM:Fetch("statusbar", "Cooli: Solid White")
  self.fadedStatusBar:SetStatusBarTexture(backgroundAsset)
  self.fadedStatusBar:GetStatusBarTexture():RemoveMaskTexture(self.borderMask)
  self.fadedStatusBar:GetStatusBarTexture():AddMaskTexture(self.borderMask)

  self.fadedStatusBar:ClearAllPoints()
  if details.layout == "vertical" then
    self.fadedStatusBar:SetPoint("TOP", self.statusBar:GetStatusBarTexture(), "TOP")
    self.fadedStatusBar:SetOrientation("VERTICAL")
  else
    self.fadedStatusBar:SetPoint("RIGHT", self.statusBar:GetStatusBarTexture(), "RIGHT")
    self.fadedStatusBar:SetOrientation("HORIZONTAL")
  end

  self.fadedStatusBar:SetFrameLevel(self.statusBar:GetFrameLevel() + 1)
  self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 2)

  self.details = details
end

function addonTable.Display.ClassResourceStatusBar.stagger:ApplySize(width, height)
  local sizing = addonTable.Display.GetSizingForStatusBar(self, width, height)
  self.sizingWidth, self.sizingHeight = sizing.rawWidth, sizing.rawHeight
  PixelUtil.SetSize(self, sizing.rawWidth, sizing.rawHeight)
  PixelUtil.SetSize(self.border, sizing.borderWidth * self.lowerScale, sizing.borderHeight * self.lowerScale)
  PixelUtil.SetSize(self.statusBar, sizing.statusWidth * self.lowerScale, sizing.statusHeight * self.lowerScale)
  PixelUtil.SetSize(self.fadedStatusBar, sizing.statusWidth * self.lowerScale, sizing.statusHeight * self.lowerScale)
end

addonTable.Display.ClassResourceStatusBar.stagger.ApplyPadding = PadStatusBar

local function GenerateBarForAuraResource(spellID, max, label)
  local mixin = {}
  addonTable.Display.ClassResourceStatusBar[label] = mixin

  function mixin:OnLoad()
    self:SetIgnoringChildrenForBounds(true)
    addonTable.Display.GenerateStatusBar(self)
    self.statusBar:SetMinMaxValues(0, max)
  end

  function mixin:OnEvent(eventName, ...)
    if eventName == "UNIT_AURA" then
      self:Import(Enum.StatusBarInterpolation.ExponentialEaseOut)
    end
  end

  function mixin:Setup(details)
    self:RegisterUnitEvent("UNIT_AURA", "player")

    self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)
    self.details = details

    self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 2)

    self:Import(Enum.StatusBarInterpolation.Immediate)
  end

  function mixin:Disable()
    self:UnregisterEvent("UNIT_AURA")
  end

  function mixin:Import(animate)
    local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", spellID)
    local value = auraData and auraData.applications or 0
    self.statusBar:SetValue(value, animate)
  end

  mixin.ApplySize = SizeStatusBar
  mixin.ApplyPadding = PadStatusBar
end

local function GenerateBarForResource(primaryResource, label)
  local textsByKeys = {
    Value = "value",
  }

  addonTable.Display.ClassResourceStatusBar[label] = {}
  local mixin = addonTable.Display.ClassResourceStatusBar[label]

  function mixin:OnLoad()
    self:SetIgnoringChildrenForBounds(true)
    addonTable.Display.GenerateStatusBar(self)
    addonTable.Display.GenerateTexts(self, textsByKeys)
  end

  function mixin:OnEvent(eventName, ...)
    self:Import(Enum.StatusBarInterpolation.ExponentialEaseOut)
  end

  function mixin:Setup(details)
    self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    self:RegisterUnitEvent("UNIT_MAXPOWER", "player")

    self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)
    self.details = details

    self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 2)

    if self.details.thresholdColors then
      self.curve = C_CurveUtil.CreateColorCurve()
      self.curve:SetType(Enum.LuaCurveType.Step)
      for index, entry in ipairs(self.details.thresholdColors) do
        self.curve:AddPoint(self.details.thresholdColors[index - 1] and self.details.thresholdColors[index - 1].limit or 0, CreateColor(entry.color.r, entry.color.g, entry.color.b))
      end
    end

    addonTable.Display.ApplyTexts(self, details, textsByKeys, details.scale)
    self.TextsContainer:SetFrameLevel(self.statusBar:GetFrameLevel() + 4)

    self:Import(Enum.StatusBarInterpolation.Immediate)
  end

  function mixin:Disable()
    self:UnregisterAllEvents()
  end

  function mixin:Import(animate)
    local max = UnitPowerMax("player", primaryResource)
    local current = UnitPower("player", primaryResource)
    if self.details.texts.value.usePercentage then
      self.TextsContainer.Value:SetFormattedText("%d", UnitPowerPercent("player", primaryResource, nil, CurveConstants.ScaleTo100))
      self.statusBar:SetMinMaxValues(0, 100)
    else
      self.TextsContainer.Value:SetText(BreakUpLargeNumbers(current))
    end
    self.statusBar:SetMinMaxValues(0, max)
    self.statusBar:SetValue(current, animate)
    if self.details.thresholdColors then
      local color = UnitPowerPercent("player", primaryResource, nil, self.curve)
      self.statusBar:GetStatusBarTexture():SetVertexColor(color.r, color.g, color.b)
    end
  end

  function mixin:ApplySize(...)
    SizeStatusBar(self, ...)
    addonTable.Display.SizeTextsForBar(self, self.details, textsByKeys, self.details.scale)
  end
  mixin.ApplyPadding = PadStatusBar
end

local function GeneratePipResource(secondaryResource, label, divisor)
  divisor = divisor or 1

  addonTable.Display.ClassResourceStatusBar[label] = {}
  local mixin = addonTable.Display.ClassResourceStatusBar[label]

  function mixin:OnLoad()
    self:SetIgnoringChildrenForBounds(true)
    addonTable.Display.GenerateStatusBar(self)
  end

  function mixin:OnEvent(eventName, ...)
    self:Import()
  end

  function mixin:Setup(details)
    self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    self:RegisterUnitEvent("UNIT_MAXPOWER", "player")

    self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)
    self.details = details
    self.index = details.index
    self.statusBar:SetMinMaxValues(0, divisor)

    self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 2)

    self:Import()
  end

  function mixin:Disable()
    self:UnregisterAllEvents()
  end

  function mixin:Import()
    local max = UnitPowerMax("player", secondaryResource)
    local current = UnitPower("player", secondaryResource, true)

    if max < self.index then
      self:Hide()
      return
    end
    self:Show()

    local value = current/divisor
    self.border:SetVertexColor(self.details.border.color.r, self.details.border.color.g, self.details.border.color.b)
    if value >= self.index then
      self.border:SetVertexColor(self.details.border.readyColor.r, self.details.border.readyColor.g, self.details.border.readyColor.b)
      self.statusBar:SetValue(divisor)
    elseif math.ceil(value) < self.index then
      self:SetShown(self.details.showEmpty)
      self.statusBar:SetValue(0)
    else
      self.statusBar:SetValue(current%divisor, Enum.StatusBarInterpolation.ExponentialEaseOut)
    end
  end

  mixin.ApplySize = SizeStatusBar
  mixin.ApplyPadding = PadStatusBar

  function mixin:ShouldCollapse()
    return true
  end
end

local function GenerateEssenceResource(label)
  local secondaryResource = Enum.PowerType.Essence
  local divisor = 1

  addonTable.Display.ClassResourceStatusBar[label] = {}
  local mixin = addonTable.Display.ClassResourceStatusBar[label]

  function mixin:OnLoad()
    self:SetIgnoringChildrenForBounds(true)
    addonTable.Display.GenerateStatusBar(self)
  end

  function mixin:OnEvent(eventName, ...)
    self:Import()
  end

  function mixin:Setup(details)
    self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    self:RegisterUnitEvent("UNIT_MAXPOWER", "player")

    self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)
    self.details = details
    self.index = details.index
    self.statusBar:SetMinMaxValues(0, 1000)

    self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 2)

    self:Import()
  end

  function mixin:Disable()
    self:UnregisterAllEvents()
  end

  function mixin:Import()
    local max = UnitPowerMax("player", secondaryResource)
    local current = UnitPower("player", secondaryResource)

    if max < self.index then
      self:Hide()
      return
    else
      self:Show()
    end

    self:SetScript("OnUpdate", nil)
    local value = current/divisor
    self.border:SetVertexColor(self.details.border.color.r, self.details.border.color.g, self.details.border.color.b)
    if value >= self.index then
      self.border:SetVertexColor(self.details.border.readyColor.r, self.details.border.readyColor.g, self.details.border.readyColor.b)
      self.statusBar:SetValue(1000)
    elseif value < self.index - 1 then
      self:SetShown(self.details.showEmpty)
      self.statusBar:SetValue(0)
    else
      local partial = UnitPartialPower("player", secondaryResource)
      self.statusBar:SetValue(partial)
      self:SetScript("OnUpdate", function()
        partial = UnitPartialPower("player", secondaryResource)
        if partial < self.statusBar:GetValue() then -- Gone backwards, so we're done
          self.statusBar:SetValue(1000, Enum.StatusBarInterpolation.ExponentialEaseOut)
          self.border:SetVertexColor(self.details.border.readyColor.r, self.details.border.readyColor.g, self.details.border.readyColor.b)
          self:SetScript("OnUpdate", nil)
        elseif partial ~= self.statusBar:GetValue() then
          self.statusBar:SetValue(partial, Enum.StatusBarInterpolation.ExponentialEaseOut)
        end
      end)
    end
  end

  mixin.ApplySize = SizeStatusBar
  mixin.ApplyPadding = PadStatusBar

  function mixin:ShouldCollapse()
    return true
  end
end

local function GenerateRunesResource(label)
  addonTable.Display.ClassResourceStatusBar[label] = {}
  local mixin = addonTable.Display.ClassResourceStatusBar[label]

  function mixin:OnLoad()
    self:SetIgnoringChildrenForBounds(true)
    addonTable.Display.GenerateStatusBar(self)
    self.duration = C_DurationUtil.CreateDuration()
  end

  function mixin:OnEvent(eventName, ...)
    self:Import()
  end

  function mixin:Setup(details)
    self:RegisterEvent("RUNE_POWER_UPDATE")

    self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)
    self.details = details
    self.index = self.details.index

    self.statusBar:SetMinMaxValues(0, 400)

    self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 2)

    self:Import()
  end

  function mixin:Disable()
    self:UnregisterAllEvents()
  end

  function mixin:Import()
    local times = {}
    for i = 1, 6 do
      table.insert(times, {GetRuneCooldown(i)})
    end
    table.sort(times, function(a, b) return a[1] < b[1] end)
    local startTime, duration, isRuneReady = unpack(times[self.index])

    self:SetShown(self.details.showEmpty or startTime ~= 0 or isRuneReady)

    self.border:SetVertexColor(self.details.border.color.r, self.details.border.color.g, self.details.border.color.b)
    self.statusBar:GetStatusBarTexture():SetVertexColor(self.details.foreground.color.r, self.details.foreground.color.g, self.details.foreground.color.b)
    if isRuneReady then
      self.border:SetVertexColor(self.details.border.readyColor.r, self.details.border.readyColor.g, self.details.border.readyColor.b)
      self.statusBar:GetStatusBarTexture():SetVertexColor(self.details.foreground.readyColor.r, self.details.foreground.readyColor.g, self.details.foreground.readyColor.b)
      self.statusBar:SetValue(400)
    elseif  startTime ~= 0 then
      self.duration:SetTimeFromStart(startTime, duration)
      self.statusBar:SetTimerDuration(self.duration)
    else
      self.statusBar:SetValue(0)
    end
  end

  mixin.ApplySize = SizeStatusBar
  mixin.ApplyPadding = PadStatusBar
end

local function GeneratePipAuraResource(spellID, max, label, divisor)
  divisor = divisor or 1

  addonTable.Display.ClassResourceStatusBar[label] = {}
  local mixin = addonTable.Display.ClassResourceStatusBar[label]

  function mixin:OnLoad()
    self:SetIgnoringChildrenForBounds(true)
    addonTable.Display.GenerateStatusBar(self)
  end

  function mixin:OnEvent(eventName, ...)
    self:Import()
  end

  function mixin:Setup(details)
    self:RegisterUnitEvent("UNIT_AURA", "player")

    self.rawWidth, self.rawHeight, self.borderWidth, self.borderHeight, self.lowerScale = addonTable.Display.ApplyStatusBar(details, self.statusBar, self.border, self.borderMask, self.background)
    self.details = details
    self.index = details.index
    self.statusBar:SetMinMaxValues(0, divisor)

    self.borderWrapper:SetFrameLevel(self.statusBar:GetFrameLevel() + 2)

    self:Import()
  end

  function mixin:Disable()
    self:UnregisterAllEvents()
  end

  function mixin:Import()
    local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", spellID)
    local current = auraData and auraData.applications or 0

    if max < self.index then
      self:Hide()
      return
    else
      self:Show()
    end

    local value = current/divisor
    self.border:SetVertexColor(self.details.border.color.r, self.details.border.color.g, self.details.border.color.b)
    if value >= self.index then
      self.border:SetVertexColor(self.details.border.readyColor.r, self.details.border.readyColor.g, self.details.border.readyColor.b)
      self.statusBar:SetValue(divisor)
    elseif math.ceil(value) < self.index then
      self:SetShown(self.details.showEmpty)
      self.statusBar:SetValue(0)
    else
      self.statusBar:SetValue(current%divisor)
    end
  end

  mixin.ApplySize = SizeStatusBar
  mixin.ApplyPadding = PadStatusBar

  function mixin:ShouldCollapse()
    return true
  end
end

GenerateBarForResource(Enum.PowerType.Energy, "energy")
GenerateBarForResource(Enum.PowerType.Mana, "mana")
GenerateBarForResource(Enum.PowerType.Rage, "rage")
GenerateBarForResource(Enum.PowerType.RunicPower, "runic-power")
GenerateBarForResource(Enum.PowerType.Fury, "fury")
GenerateBarForResource(Enum.PowerType.Focus, "focus")
GenerateBarForResource(Enum.PowerType.Insanity, "insanity")
GenerateBarForResource(Enum.PowerType.LunarPower, "astral-power")
GenerateBarForResource(Enum.PowerType.Maelstrom, "maelstrom")
GeneratePipResource(Enum.PowerType.SoulShards, "soul-shards", 10)
GeneratePipResource(Enum.PowerType.HolyPower, "holy-power")
GeneratePipResource(Enum.PowerType.ComboPoints, "combo-points")
GeneratePipResource(Enum.PowerType.Chi, "chi")
GeneratePipResource(Enum.PowerType.ArcaneCharges, "arcane-charges")
GenerateEssenceResource("essence")
GenerateRunesResource("runes")

GenerateBarForAuraResource(205473, 5, "icicles")
GenerateBarForAuraResource(260286, 3, "tip-of-the-spear")
GeneratePipAuraResource(344179, 10, "maelstrom-weapon")
