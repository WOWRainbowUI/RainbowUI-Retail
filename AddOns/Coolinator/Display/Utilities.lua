---@class addonTableCoolinator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

function addonTable.Display.GeneratePool(mixin, template, capacity)
  return CreateFramePool("Frame", UIParent, template or "CoolinatorPropagateMouseClicksTemplate", function(_, frame)
    if frame.Disable then
      frame:Disable()
    end
    frame:SetParent(UIParent)
    frame:ClearAllPoints()
    frame:Hide()
  end, false, function(frame)
    Mixin(frame, mixin)
    frame:OnLoad()
  end, capacity)
end

function addonTable.Display.ApplyAnchor(frame, anchor, scale)
  scale = scale or 1
  frame:ClearAllPoints()
  if #anchor == 0 then
    frame:SetPoint("CENTER")
  elseif #anchor == 3 then
    PixelUtil.SetPoint(frame, anchor[1], frame:GetParent(), "CENTER", anchor[2] * scale, anchor[3] * scale)
  elseif #anchor == 2 then
    PixelUtil.SetPoint(frame, "CENTER", frame:GetParent(), "CENTER", anchor[1] * scale, anchor[2] * scale)
  elseif #anchor == 1 then
    frame:SetPoint(anchor[1], frame:GetParent(), "CENTER")
  end
end

do
  local fractional = C_StringUtil.CreateNumericRuleFormatter()
  fractional:SetBreakpoints({
    {
      threshold = 0,
      step = 0.1,
      format = "%.1f",
    },
    {
      threshold = 3,
      step = 1,
      format = "%d",
    },
    {
      threshold = 60,
      format = "%d:%02d",
      components = {
        {
          div = 60,
          rounding = Enum.NumericRuleFormatRounding.Down,
          step = 1,
        },
        {
          mod = 60,
          rounding = Enum.NumericRuleFormatRounding.Down,
          step = 1,
        }
      }
    }
  })

  local basic = C_StringUtil.CreateNumericRuleFormatter()
  basic:SetBreakpoints({
    {
      threshold = 0,
      step = 1,
      format = "%d",
    },
    {
      threshold = 60,
      format = "%d:%02d",
      components = {
        {
          div = 60,
          rounding = Enum.NumericRuleFormatRounding.Down,
          step = 1,
        },
        {
          mod = 60,
          rounding = Enum.NumericRuleFormatRounding.Down,
          step = 1,
        }
      }
    }
  })

  function addonTable.Display.GetDurationFormatter(isFractional)
    return isFractional and fractional or basic
  end
end

function addonTable.Display.GenerateStatusBar(self)
  self:SetScript("OnEvent", self.OnEvent)

  self.statusBar = CreateFrame("StatusBar", nil, self)
  self.statusBar:SetPoint("CENTER")
  self.statusBar:SetStatusBarTexture(LSM:Fetch("statusbar", "Cooli: Solid Transparency"))
  self.statusBar:SetMinMaxValues(0, 5)

  self.background = self.statusBar:CreateTexture(nil, "BACKGROUND")
  self.background:SetAllPoints(self.statusBar)
  self.borderWrapper = CreateFrame("Frame", nil, self)
  self.borderWrapper:SetAllPoints(self.statusBar)
  self.border = self.borderWrapper:CreateTexture(nil, "BORDER")
  self.border:SetPoint("CENTER")
  self.borderMask = self.statusBar:CreateMaskTexture()
  self.borderMask:SetAllPoints()

  self.GetDefaultSize = addonTable.Display.GetDefaultStatusBarSize
end

function addonTable.Display.ApplyStatusBar(details, statusBar, border, borderMask, background)
  local borderDetails = LSM:Fetch("ninesliceborder", details.border.asset, true) or LSM:Fetch("ninesliceborder", "Cooli: 1px")
  assert(borderDetails)
  local borderSliceDetails = LSM:Fetch("nineslice", borderDetails.nineslice)
  assert(borderSliceDetails)
  local foregroundAsset = LSM:Fetch("statusbar", details.foreground.asset, true) or LSM:Fetch("statusbar", "Cooli: Solid White")
  local backgroundAsset = LSM:Fetch("statusbar", details.background.asset, true) or LSM:Fetch("statusbar", "Cooli: Solid White")

  local rawWidth, rawHeight = details.width * addonTable.Assets.BarBordersSize.width, details.height * addonTable.Assets.BarBordersSize.height
  if details.layout == "vertical" then
    local tmp = rawWidth
    rawWidth = rawHeight
    rawHeight = tmp
    statusBar:SetOrientation("VERTICAL")
  else
    statusBar:SetOrientation("HORIZONTAL")
  end
  local borderWidth = rawWidth + (borderSliceDetails.padding.left + borderSliceDetails.padding.right) / 2
  local borderHeight = rawHeight + (borderSliceDetails.padding.top + borderSliceDetails.padding.bottom) / 2

  statusBar:SetStatusBarTexture(foregroundAsset)
  statusBar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
  statusBar:SetScale(borderSliceDetails.scaleModifier * details.scale)
  statusBar:GetStatusBarTexture():SetVertexColor(details.foreground.color.r, details.foreground.color.g, details.foreground.color.b)

  local lowerScale = 1/borderSliceDetails.scaleModifier

  background:SetTexture(backgroundAsset)
  background:SetVertexColor(details.background.color.r, details.background.color.g, details.background.color.b, details.background.color.a)

  border:SetTexture(borderSliceDetails.file)
  border:SetVertexColor(details.border.color.r, details.border.color.g, details.border.color.b, details.border.color.a)
  border:SetTextureSliceMargins(borderSliceDetails.margins.left, borderSliceDetails.margins.top, borderSliceDetails.margins.right, borderSliceDetails.margins.bottom)
  if border:GetParent() ~= statusBar and border:GetParent():GetParent() ~= statusBar then
    border:SetScale(borderSliceDetails.scaleModifier * details.scale)
  end

  statusBar:GetStatusBarTexture():RemoveMaskTexture(borderMask)
  background:RemoveMaskTexture(borderMask)

  local maskDetails = borderDetails.mask
  borderMask:SetBlockingLoadsRequested(true)
  borderMask:SetTexture(maskDetails.file, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  borderMask:SetTextureSliceMargins(maskDetails.margins.left, maskDetails.margins.top, maskDetails.margins.right, maskDetails.margins.bottom)

  statusBar:GetStatusBarTexture():AddMaskTexture(borderMask)
  background:AddMaskTexture(borderMask)

  return rawWidth, rawHeight, borderWidth, borderHeight, lowerScale
end

function addonTable.Display.GetSizingForStatusBar(frame, width, height)
  local rawWidth, rawHeight = frame.rawWidth * frame.details.scale, frame.rawHeight * frame.details.scale
  if frame.details.autoSize then
    if frame.details.layout == "horizontal" and width ~= 0 then
      rawWidth = width or rawWidth
    end
    if frame.details.layout == "vertical" and height ~= 0 then
      rawHeight = height or rawHeight
    end
  end
  local statusWidth, statusHeight = frame.rawWidth, frame.rawHeight
  local borderWidth, borderHeight = frame.borderWidth, frame.borderHeight
  local iconSize = 0
  if frame.details.icon and frame.details.icon.show then
    if frame.details.layout == "vertical" then
      iconSize = frame.rawWidth * frame.details.scale
      local offset = (frame.borderHeight - frame.rawHeight) / 2 + 1 + iconSize
      local new = rawHeight - offset
      if new >= addonTable.Assets.BarBordersSize.width * 0.1 then
        statusHeight = new / frame.details.scale
        borderHeight = borderHeight + (rawHeight - offset - frame.rawHeight * frame.details.scale) / frame.details.scale
      else
        iconSize = 0
      end
    else
      iconSize = frame.rawHeight * frame.details.scale
      local offset = (frame.borderWidth - frame.rawWidth) / 2 + 1 + iconSize
      local new = rawWidth - offset
      if new >= addonTable.Assets.BarBordersSize.width * 0.1 then
        statusWidth = new / frame.details.scale
        borderWidth = borderWidth + (rawWidth - offset - frame.rawWidth * frame.details.scale) / frame.details.scale
      else
        iconSize = 0
      end
    end
  else
    statusWidth, statusHeight = rawWidth / frame.details.scale, rawHeight / frame.details.scale
    borderWidth = borderWidth + (statusWidth - frame.rawWidth)
    borderHeight = borderHeight + (statusHeight - frame.rawHeight)
  end
  return {
    rawWidth = rawWidth, rawHeight = rawHeight,
    statusWidth = statusWidth, statusHeight = statusHeight,
    borderWidth = borderWidth, borderHeight = borderHeight,
    iconSize = iconSize
  }
end

function addonTable.Display.GetDefaultStatusBarSize(self)
  return self.rawWidth * self.details.scale, self.rawHeight * self.details.scale
end

function addonTable.Display.GenerateTexts(self, byKeys)
  self.TextsContainer = CreateFrame("Frame", nil, self)
  self.TextsContainer:SetAllPoints()
  for key in pairs(byKeys) do
    self.TextsContainer[key] = self.TextsContainer:CreateFontString(nil, nil, "NumberFontNormal")
    self.TextsContainer[key]:SetWordWrap(false)
  end
end

function addonTable.Display.ApplyTexts(self, details, byKeys, scaleModifier)
  scaleModifier = scaleModifier or 1

  local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
  local texts = details.texts
  for key, settingsKey in pairs(byKeys) do
    self.TextsContainer[key]:SetFontObject(addonTable.CurrentNumberFont)
    self.TextsContainer[key]:SetShown(texts[settingsKey].visible)
    self.TextsContainer[key]:SetTextColor(texts[settingsKey].color.r, texts[settingsKey].color.g, texts[settingsKey].color.b)
    if font.flags.slug then
      self.TextsContainer[key]:SetScale(texts[settingsKey].scale * scaleModifier)
      self.TextsContainer[key]:SetTextScale(1)
      self.TextsContainer[key]:SetSmoothScaling(true)
    else
      self.TextsContainer[key]:SetScale(1)
      self.TextsContainer[key]:SetTextScale(texts[settingsKey].scale * scaleModifier)
      self.TextsContainer[key]:SetSmoothScaling(false)
    end

    local anchor = texts[settingsKey].anchor[1]
    if anchor == "LEFT" or anchor == "RIGHT" then
      self.TextsContainer[key]:SetJustifyH(anchor)
    else
      self.TextsContainer[key]:SetJustifyH("CENTER")
    end
  end
end

function addonTable.Display.SizeTextsForBar(self, details, byKeys, scaleModifier)
  scaleModifier = scaleModifier or 1

  local texts = details.texts
  local statusWidth = self.sizingWidth / details.scale
  for key, settingsKey in pairs(byKeys) do
    local scale = self.TextsContainer[key]:GetScale()
    PixelUtil.SetPoint(self.TextsContainer[key], texts[settingsKey].anchor[1], self.statusBar, texts[settingsKey].anchor[1], texts[settingsKey].anchor[2]/scale, texts[settingsKey].anchor[3]/scale)
    PixelUtil.SetWidth(self.TextsContainer[key], texts[settingsKey].widthLimit * statusWidth * scaleModifier / scale)
  end
end

do
  local mapping = {
    ["total"] = Enum.DurationTextBindingProperty.TotalDuration,
    ["elapsed"] = Enum.DurationTextBindingProperty.ElapsedDuration,
    ["remaining"] = Enum.DurationTextBindingProperty.RemainingDuration,
  }
  function addonTable.Display.ConvertDurationDisplayToComponent(label)
    return mapping[label]
  end
end

do
  local spellIDToIndex = {}
  local petTotems = {}
  local totemMonitor = CreateFrame("Frame")
  totemMonitor:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
  totemMonitor:RegisterEvent("PLAYER_TOTEM_UPDATE")
  totemMonitor:RegisterEvent("PLAYER_ENTERING_WORLD")

  local class = UnitClassBase("player")
  local queued

  totemMonitor:SetScript("OnEvent", function(_, eventName, ...)
    if eventName == "UNIT_SPELLCAST_SUCCEEDED" then
      local _, _, spellID = ...
      local override = addonTable.Constants.TotemTalentOverrides[spellID]
      if override and C_SpellBook.IsSpellKnown(override.talent) then
        petTotems[spellID] = {start = GetTime(), duration = override.duration, spellID = override.visual}
        C_Timer.After(override.duration, function()
          petTotems[spellID] = nil
          addonTable.CallbackRegistry:TriggerEvent("Update.Totems")
        end)
        addonTable.CallbackRegistry:TriggerEvent("Update.Totems")
      elseif addonTable.Constants.TotemSpells[spellID] then
        queued = spellID
      end
    elseif eventName == "PLAYER_TOTEM_UPDATE" then
      local index = ...
      if GetTotemDuration(index) == nil then
        for spellID, otherIndex in pairs(spellIDToIndex) do
          if index == otherIndex then
            spellIDToIndex[spellID] = nil
            break
          end
        end
      elseif queued then
        spellIDToIndex[queued] = index
      elseif addonTable.Constants.ProcTotems[class] then
        spellIDToIndex[addonTable.Constants.ProcTotems[class]] = index
      end
      addonTable.CallbackRegistry:TriggerEvent("Update.Totems")
    elseif eventName == "PLAYER_ENTERING_WORLD" then
      local tmp = {}
      for i = 1, 4 do
        local spellID = select(7, GetTotemInfo(i))
        if issecretvalue(spellID) then
          return
        elseif spellID then
          tmp[spellID] = i
        end
      end
      spellIDToIndex = tmp
      addonTable.CallbackRegistry:TriggerEvent("Update.Totems")
    end
  end)
  function addonTable.Display.GetTotems()
    return spellIDToIndex
  end
  function addonTable.Display.GetTotemPets()
    return petTotems
  end
end

do
  local index = 0
  local helpful = CreateFrame("AuraContainer", nil, UIParent, "CustomAuraContainerTemplate")
  helpful:SetUnit("player")
  local helpfulPet = CreateFrame("AuraContainer", nil, UIParent, "CustomAuraContainerTemplate")
  helpfulPet:SetUnit("pet")
  local harmful = CreateFrame("AuraContainer", nil, UIParent, "CustomAuraContainerTemplate")
  harmful:SetUnit("target")

  local monitor = CreateFrame("Frame")
  monitor:RegisterUnitEvent("UNIT_FACTION", "player", "target", "pet")
  monitor:RegisterUnitEvent("UNIT_TARGETABLE_CHANGED", "player", "target", "pet")
  monitor:RegisterEvent("PLAYER_TARGET_CHANGED")
  monitor:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
  monitor:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
  monitor:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
  monitor:SetScript("OnEvent", function(_, eventName, data)
    if eventName == "PLAYER_TARGET_CHANGED" then
      harmful:SetEnabled(not UnitCanAssist("player", "target"))
      harmful:UpdateAllAuras()
    elseif eventName == "UNIT_FACTION" or eventName == "UNIT_TARGETABLE_CHANGED" then
      if data == "target" then
        harmful:SetEnabled(not UnitCanAssist("player", "target"))
        harmful:UpdateAllAuras()
      elseif data == "player" then
        helpful:SetEnabled(UnitCanAssist("player", "player"))
        helpful:UpdateAllAuras()
      elseif data == "pet" then
        helpfulPet:SetEnabled(UnitCanAssist("player", "pet"))
        helpfulPet:UpdateAllAuras()
      end
    else
      harmful:UpdateAllAuras()
      helpful:UpdateAllAuras()
      helpfulPet:UpdateAllAuras()
    end
  end)

  function addonTable.Display.GeneratePlayerAuraSlots(selfSettings, targetSettings)
    index = index + 1
    local key = tostring(index)

    return key, helpful:AddAuraSlot(key, "HELPFUL|PLAYER", selfSettings), harmful:AddAuraSlot(key, "HARMFUL|PLAYER", targetSettings), helpfulPet:AddAuraSlot(key, "HELPFUL", selfSettings)
  end

  function addonTable.Display.SetAuraSlotsFilters(key, selfSettings, targetSettings)
    helpful:SetAuraSlotCandidateFilters(key, selfSettings)
    harmful:SetAuraSlotCandidateFilters(key, targetSettings)
  end

  function addonTable.Display.SetAuraSlotsEnabled(key, enabled)
    helpful:SetAuraSlotFilterString(key, enabled and "HELPFUL" or "")
    harmful:SetAuraSlotFilterString(key, enabled and "HARMFUL|PLAYER" or "")
  end
end
