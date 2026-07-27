---@class addonTablePlatynator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

local auraFormatter = addonTable.Display.Utilities.GetAuraNumericFormatter()

function addonTable.Display.StyleAura(auraFrame, details)
  auraFrame.kind = details.kind

  auraFrame:EnableMouseMotion(details.showTooltips)

  auraFrame.CountFrame.Count:SetFontObject(addonTable.CurrentFont)
  auraFrame.CountFrame.Count:ClearAllPoints()
  addonTable.Display.ApplyAnchor(auraFrame.CountFrame.Count, details.texts.stacks.anchor, addonTable.CurrentFontUsesSmoothing and 1/details.texts.stacks.scale or 1)
  if addonTable.CurrentFontUsesSmoothing then
    auraFrame.CountFrame.Count:SetTextScale(1)
    auraFrame.CountFrame.Count:SetScale(details.texts.stacks.scale)
  else
    auraFrame.CountFrame.Count:SetTextScale(details.texts.stacks.scale)
    auraFrame.CountFrame.Count:SetScale(1)
  end
  local c1 = details.texts.stacks.color
  auraFrame.CountFrame.Count:SetTextColor(c1.r, c1.g, c1.b)
  auraFrame.CountFrame.Count:SetShown(details.texts.stacks.visible);

  auraFrame.Cooldown:SetHideCountdownNumbers(not details.texts.countdown.visible)

  if details.texts.countdown.visible then
    auraFrame.Cooldown.Text:SetFontObject(addonTable.CurrentFont)
    auraFrame.Cooldown.Text:ClearAllPoints()
    addonTable.Display.ApplyAnchor(auraFrame.Cooldown.Text, details.texts.countdown.anchor, addonTable.CurrentFontUsesSmoothing and 1/details.texts.countdown.scale or 1)
    if addonTable.CurrentFontUsesSmoothing then
      auraFrame.Cooldown.Text:SetTextScale(1)
      auraFrame.Cooldown.Text:SetScale(details.texts.countdown.scale)
    else
      auraFrame.Cooldown.Text:SetTextScale(details.texts.countdown.scale)
      auraFrame.Cooldown.Text:SetScale(1)
    end
    local c2 = details.texts.countdown.color
    auraFrame.Cooldown.Text:SetTextColor(c2.r, c2.g, c2.b)
    if addonTable.Constants.IsCooldownFormattingAvailable then
      if details.texts.countdown.showFractions then
        auraFrame.Cooldown:SetCountdownFormatter(auraFormatter)
      else
        auraFrame.Cooldown:SetCountdownFormatter(nil)
        auraFrame.Cooldown:SetCountdownAbbrevThreshold(20)
      end
    end
  end

  if auraFrame.CountFrame.Count.SetSmoothScaling then
    auraFrame.CountFrame.Count:SetSmoothScaling(addonTable.CurrentFontUsesSmoothing)
    auraFrame.Cooldown.Text:SetSmoothScaling(addonTable.CurrentFontUsesSmoothing)
  end

  auraFrame.Cooldown:SetDrawEdge(details.showSwipe)
  auraFrame.Cooldown:SetDrawSwipe(details.showSwipe)

  PixelUtil.SetSize(auraFrame, 20, 20 * details.height)
  PixelUtil.SetSize(auraFrame.Border, 20, 20 * details.height)
  PixelUtil.SetSize(auraFrame.Icon, 20, 20 * details.height)
  local texBase = 0.95 * (1 - details.height) / 2
  auraFrame.Icon:SetTexCoord(0.05, 0.95, 0.05 + texBase, 0.95 - texBase)

  auraFrame.Dispel:SetShown(details.showType)
end

local function GetAurasInitializerModern(container)
  local borderAsset = LSM:Fetch("nineslice", "Platy: 1px")
  local dispelAsset = LSM:Fetch("nineslice", "Platy: 4px")
  return function(frame)
    table.insert(container.frames, frame)
    frame:SetFlattensRenderLayers(true)
    frame:SetSize(20, 20)
    frame.Icon = frame:CreateTexture(nil, "ARTWORK")
    frame.Icon:SetSize(20, 20)
    frame.Icon:SetPoint("CENTER")
    frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.Cooldown:SetDrawBling(false)
    frame.Cooldown:SetHideCountdownNumbers(false)
    frame.Cooldown:SetDrawEdge(true)
    frame.Cooldown:SetReverse(true)
    frame.CountFrame = CreateFrame("Frame", nil, frame)
    frame.CountFrame:SetAllPoints()
    frame.CountFrame:SetFrameLevel(500)
    frame.CountFrame.Count = frame.CountFrame:CreateFontString(nil, nil, "GameFontHighlight")
    frame.CountFrame.Count:SetPoint("BOTTOMRIGHT", 3, -2)

    frame.Border = frame:CreateTexture(nil, "OVERLAY")
    frame.Border:SetAllPoints(true)
    frame.Border:SetScale(borderAsset.scaleModifier)
    frame.Border:SetTexture(borderAsset.file)
    frame.Border:SetTextureSliceMargins(borderAsset.margins.left, borderAsset.margins.top, borderAsset.margins.right, borderAsset.margins.bottom)
    frame.Border:SetVertexColor(0, 0, 0)
    frame.Cooldown.Text = frame.Cooldown:GetCountdownFontString()
    frame.Dispel = CreateFrame("Frame", nil, frame)
    frame.Dispel:SetAllPoints()
    do
      local dispelTexture = frame.Dispel:CreateTexture()
      dispelTexture:SetAllPoints()
      dispelTexture:SetScale(dispelAsset.scaleModifier)
      dispelTexture:SetTexture(dispelAsset.file)
      dispelTexture:SetTextureSliceMargins(dispelAsset.margins.left, dispelAsset.margins.top, dispelAsset.margins.right, dispelAsset.margins.bottom)
      dispelTexture:SetVertexColor(1, 0, 0)
      frame.Dispel.Border = dispelTexture
    end

    frame:SetApplicationCount(frame.CountFrame.Count, {})
    frame:SetIcon(frame.Icon)
    frame:SetDurationCooldown(frame.Cooldown)
    frame:SetAuraBorder(frame.Dispel.Border, {showIcon = false, showWhenHarmful = true, showWhenHelpful = true, style = 1})

    if container.details then
      addonTable.Display.StyleAura(frame, container.details)
    end
  end
end

addonTable.Display.AurasManagerNextMixin = {}

function addonTable.Display.AurasManagerNextMixin:OnLoad()
  self.buffs = CreateFrame("AuraContainer", nil, self, "CustomAuraContainerTemplate")
  self.debuffs = CreateFrame("AuraContainer", nil, self, "CustomAuraContainerTemplate")
  self.crowdControl = CreateFrame("AuraContainer", nil, self, "CustomAuraContainerTemplate")

  self.buffs:SetEnabled(false)
  self.debuffs:SetEnabled(false)
  self.crowdControl:SetEnabled(false)

  self.addedGroups = false

  self.crowdControl.frames = {}

  self.buffs.frames = {}

  self.buffs.candidateIMPORTANTDefault = {}
  self.buffs.candidateIMPORTANTNoEnrage = {
    excludeDispelTypes = {[""] = true},
  }
  self.buffs.candidateENRAGEDefault = {
    includeDispelTypes = {[""] = true},
  }
  self.buffs.candidateSTEALABLEDefault = {
    isStealable = true,
  }
  self.buffs.candidateSTEALABLENoEnrage = {
    isStealable = true,
    excludeDispelTypes = {[""] = true},
  }

  self.debuffs.frames = {}
end

local directionMap = {
  LEFT = "RIGHT",
  CENTER = "CENTER",
  RIGHT = "LEFT",
}

local anchorMap = {
  LEFT = "TOPRIGHT",
  CENTER = "TOPLEFT",
  RIGHT = "TOPLEFT",
}

function addonTable.Display.AurasManagerNextMixin:InitializeWidgets(parent, auraDetails)
  self.buffs:ClearAllPoints()
  self.debuffs:ClearAllPoints()
  self.crowdControl:ClearAllPoints()

  self.buffs.details = auraDetails.buffs
  self.debuffs.details = auraDetails.debuffs
  self.crowdControl.details = auraDetails.crowdControl

  if not self.addedGroups then
    self.addedGroups = true

    self.crowdControl:AddAuraGroup("ALL", "HARMFUL|CROWD_CONTROL", {initializeFrame = GetAurasInitializerModern(self.crowdControl)})
    self.crowdControl:AddAuraGroup("PLAYER_ONLY", "HARMFUL|CROWD_CONTROL|PLAYER", {initializeFrame = GetAurasInitializerModern(self.crowdControl)})

    self.buffs:AddAuraGroup("ALL", "HELPFUL|!PLAYER", {initializeFrame = GetAurasInitializerModern(self.buffs)})
    self.buffs:AddAuraGroup("PLAYER_ASSIST", "HELPFUL|PLAYER", {initializeFrame = GetAurasInitializerModern(self.buffs)})
    self.buffs:AddAuraGroup("IMPORTANT", "HELPFUL|IMPORTANT|!PLAYER", {initializeFrame = GetAurasInitializerModern(self.buffs)})
    self.buffs:AddAuraGroup("ENRAGE", "HELPFUL|!IMPORTANT|!PLAYER", {initializeFrame = GetAurasInitializerModern(self.buffs)})
    self.buffs:AddAuraGroup("STEALABLE", "HELPFUL|!IMPORTANT|!PLAYER", {initializeFrame = GetAurasInitializerModern(self.buffs)})
    self.buffs:AddAuraGroup("DEFENSIVE1", "HELPFUL|BIG_DEFENSIVE|!PLAYER", {initializeFrame = GetAurasInitializerModern(self.buffs)})
    self.buffs:AddAuraGroup("DEFENSIVE2", "HELPFUL|EXTERNAL_DEFENSIVE|!PLAYER", {initializeFrame = GetAurasInitializerModern(self.buffs)})
    self.buffs:AddAuraGroup("DEFENSIVE3", "HELPFUL|RAID_IN_COMBAT|!PLAYER", {initializeFrame = GetAurasInitializerModern(self.buffs)})

    self.debuffs:AddAuraGroup("PLAYER_IMPORTANT", "HARMFUL|IMPORTANT|PLAYER|!CROWD_CONTROL", {initializeFrame = GetAurasInitializerModern(self.debuffs)})
    self.debuffs:AddAuraGroup("ANY_PLAYER_IMPORTANT", "HARMFUL|IMPORTANT|!CROWD_CONTROL", {initializeFrame = GetAurasInitializerModern(self.debuffs)})
    self.debuffs:AddAuraGroup("PLAYER_PERSONAL", "HARMFUL|!IMPORTANT|INCLUDE_NAME_PLATE_ONLY|PLAYER|!CROWD_CONTROL", {initializeFrame = GetAurasInitializerModern(self.debuffs), candidateFilters = {
      nameplateShowPersonal = true,
    }})
    self.debuffs:AddAuraGroup("ANY_PLAYER_PERSONAL", "HARMFUL|!IMPORTANT|INCLUDE_NAME_PLATE_ONLY|!CROWD_CONTROL", {initializeFrame = GetAurasInitializerModern(self.debuffs), candidateFilters = {
      nameplateShowPersonal = true,
    }})
    self.debuffs:AddAuraGroup("ALL_PLAYER", "HARMFUL|PLAYER|!CROWD_CONTROL", {initializeFrame = GetAurasInitializerModern(self.debuffs)})
    self.debuffs:AddAuraGroup("ALL", "HARMFUL|!CROWD_CONTROL", {initializeFrame = GetAurasInitializerModern(self.debuffs)})
  end


  if auraDetails.crowdControl then
    self.crowdControl:SetParent(parent.CrowdControlDisplay)
    self.crowdControl:SetScale(auraDetails.crowdControl.scale)
    self.crowdControl:SetPoint(directionMap[auraDetails.crowdControl.direction])
    self.crowdControl:SetFlowLayoutAnchorPoint(anchorMap[auraDetails.crowdControl.direction])
    local padding = PixelUtil.ConvertPixelsToUIForRegion(20 * auraDetails.crowdControl.padding, self.crowdControl)
    if auraDetails.crowdControl.filters.fromYou then
      self.crowdControl:SetAuraGroupMaxFrameCount("ALL", 0)
      self.crowdControl:SetAuraGroupMaxFrameCount("PLAYER_ONLY", auraDetails.crowdControl.limit)
    else
      self.crowdControl:SetAuraGroupMaxFrameCount("ALL", auraDetails.crowdControl.limit)
      self.crowdControl:SetAuraGroupMaxFrameCount("PLAYER_ONLY", 0)
    end
    self.crowdControl:SetAuraGroupLayout("ALL", {elementSpacingX = padding, elementSpacingY = padding})
    self.crowdControl:SetAuraGroupLayout("PLAYER_ONLY", {elementSpacingX = padding, elementSpacingY = padding})
    if not addonTable.Utilities.IsChangesRestricted() then
      for _, f in ipairs(self.crowdControl.frames) do
        addonTable.Display.StyleAura(f, auraDetails.crowdControl)
      end
    end

    if auraDetails.crowdControl.direction == "LEFT" then
      self.crowdControl:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Left, AnchorUtil.FlowDirection.Up)
    else
      self.crowdControl:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Up)
    end

    self.crowdControl:Show()
  else
    self.crowdControl:Hide()
  end

  if auraDetails.debuffs then
    self.debuffs:SetParent(parent.DebuffDisplay)
    self.debuffs:SetScale(auraDetails.debuffs.scale)
    self.debuffs:SetPoint(directionMap[auraDetails.debuffs.direction])
    self.debuffs:SetFlowLayoutAnchorPoint(anchorMap[auraDetails.debuffs.direction])
    local padding = PixelUtil.ConvertPixelsToUIForRegion(20 * auraDetails.debuffs.padding, self.debuffs)
    local setup = {
      ["PLAYER_IMPORTANT"] = 0,
      ["ANY_PLAYER_IMPORTANT"] = 0,
      ["PLAYER_PERSONAL"] = 0,
      ["ANY_PLAYER_PERSONAL"] = 0,
      ["ALL_PLAYER"] = 0,
      ["ALL"] = 0,
    }
    if auraDetails.debuffs.filters.fromYou then
      if auraDetails.debuffs.filters.important then
        setup.PLAYER_IMPORTANT = auraDetails.debuffs.limit
        setup.PLAYER_PERSONAL = auraDetails.debuffs.limit
      else
        setup.ALL_PLAYER = auraDetails.debuffs.limit
      end
    else
      if auraDetails.debuffs.filters.important then
        setup.ANY_PLAYER_IMPORTANT = auraDetails.debuffs.limit
        setup.ANY_PLAYER_PERSONAL = auraDetails.debuffs.limit
      else
        setup.ALL = auraDetails.debuffs.limit
      end
    end
    for key, count in pairs(setup) do
      self.debuffs:SetAuraGroupMaxFrameCount(key, count)
      self.debuffs:SetAuraGroupLayout(key, {elementSpacingX = padding, elementSpacingY = padding})
    end
    if not addonTable.Utilities.IsChangesRestricted() then
      for _, f in ipairs(self.debuffs.frames) do
        addonTable.Display.StyleAura(f, auraDetails.debuffs)
      end
    end

    if auraDetails.debuffs.direction == "LEFT" then
      self.debuffs:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Left, AnchorUtil.FlowDirection.Up)
    else
      self.debuffs:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Up)
    end

    self.debuffs:Show()
  else
    self.debuffs:Hide()
  end

  if auraDetails.buffs then
    self.buffs:SetParent(parent.BuffDisplay)
    self.buffs:SetScale(auraDetails.buffs.scale)
    self.buffs:SetPoint(directionMap[auraDetails.buffs.direction])
    self.buffs:SetFlowLayoutAnchorPoint(anchorMap[auraDetails.buffs.direction])
    local padding = PixelUtil.ConvertPixelsToUIForRegion(20 * auraDetails.buffs.padding, self.buffs)
    local setup = {
      ["ALL"] = {0, {}},
      ["PLAYER_ASSIST"] = {0, {}},
      ["IMPORTANT"] = {0, {self.buffs.candidateIMPORTANTDefault}},
      ["ENRAGE"] = {0, {self.buffs.candidateENRAGEDefault}},
      ["STEALABLE"] = {0, {self.buffs.candidateSTEALABLEDefault}},
      ["DEFENSIVE1"] = {0, {}},
      ["DEFENSIVE2"] = {0, {}},
      ["DEFENSIVE3"] = {0, {}},
    }
    setup.PLAYER_ASSIST[1] = auraDetails.buffs.limit
    if auraDetails.buffs.filters.defensive then
      setup.DEFENSIVE1[1] = auraDetails.buffs.limit
      setup.DEFENSIVE2[1] = auraDetails.buffs.limit
      setup.DEFENSIVE3[1] = auraDetails.buffs.limit
    elseif auraDetails.buffs.filters.important then
      setup.IMPORTANT[1] = auraDetails.buffs.limit
      if auraDetails.buffs.filters.enrage then
        setup.ENRAGE[1] = auraDetails.buffs.limit
        setup.IMPORTANT[2] = self.buffs.candidateIMPORTANTNoEnrage
        setup.STEALABLE[2] = self.buffs.candidateIMPORTANTNoEnrage
      end
      if auraDetails.buffs.filters.dispelable then
        setup.STEALABLE[1] = auraDetails.buffs.limit
      end
    else
      if auraDetails.buffs.filters.enrage then
        setup.ENRAGE[1] = auraDetails.buffs.limit
        setup.IMPORTANT[2] = self.buffs.candidateIMPORTANTNoEnrage
        setup.STEALABLE[2] = self.buffs.candidateIMPORTANTNoEnrage
      elseif auraDetails.buffs.filters.dispelable then
        setup.STEALABLE[1] = auraDetails.buffs.limit
      else
        setup.ALL[1] = auraDetails.buffs.limit
      end
    end
    for key, info in pairs(setup) do
      self.buffs:SetAuraGroupMaxFrameCount(key, info[1])
      self.buffs:SetAuraGroupCandidateFilters(key, info[2])
      self.buffs:SetAuraGroupLayout(key, {elementSpacingX = padding, elementSpacingY = padding})
    end
    if not addonTable.Utilities.IsChangesRestricted() then
      for _, f in ipairs(self.buffs.frames) do
        addonTable.Display.StyleAura(f, auraDetails.buffs)
      end
    end

    if auraDetails.buffs.direction == "LEFT" then
      self.buffs:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Left, AnchorUtil.FlowDirection.Up)
    else
      self.buffs:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Up)
    end

    self.buffs:Show()
  else
    self.buffs:Hide()
  end
end

function addonTable.Display.AurasManagerNextMixin:SetUnit(unit, parent, auraDetails)
  if not unit then
    self.buffs:SetEnabled(false)
    self.debuffs:SetEnabled(false)
    self.crowdControl:SetEnabled(false)
    return
  end

  self.buffs:SetEnabled(true)
  self.debuffs:SetEnabled(true)
  self.crowdControl:SetEnabled(true)

  self.auraDetails = auraDetails

  self.buffs:SetUnit(unit)
  self.debuffs:SetUnit(unit)
  self.crowdControl:SetUnit(unit)
end
