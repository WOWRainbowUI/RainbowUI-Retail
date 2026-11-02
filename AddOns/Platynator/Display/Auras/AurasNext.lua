---@class addonTablePlatynator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

local auraFormatter, auraPlainFormatter = addonTable.Display.Utilities.GetAuraNumericFormatter()

local function GenerateDispelTexture(frame)
  if frame.DispelBorder then
    return
  end

  local dispelAsset = LSM:Fetch("nineslice", "MM: 4px")
  local dispelTexture = frame:CreateTexture(nil, "OVERLAY", nil, 2)
  dispelTexture:SetAllPoints()
  dispelTexture:SetScale(dispelAsset.scaleModifier)
  dispelTexture:SetTexture(dispelAsset.file)
  dispelTexture:SetTextureSliceMargins(dispelAsset.margins.left, dispelAsset.margins.top, dispelAsset.margins.right, dispelAsset.margins.bottom)
  dispelTexture:SetVertexColor(1, 0, 0)
  dispelTexture:SetRoundLayoutToNearestPixel(true)
  frame.DispelBorder = dispelTexture
end

local function GeneratePandemicAnimation(frame)
  if frame.PandemicAnimation then
    return
  end

  frame.PandemicAnimation = frame:CreateAnimationGroup()
  do
    frame.PandemicTop = frame:CreateTexture(nil, "OVERLAY", nil, 5)
    frame.PandemicTop:SetPoint("TOPLEFT")
    frame.PandemicTop:SetPoint("TOPRIGHT")
    frame.PandemicTop:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic.png")
    frame.PandemicTop:SetRoundLayoutToNearestPixel(true)
    frame.PandemicBottom = frame:CreateTexture(nil, "OVERLAY", nil, 5)
    frame.PandemicBottom:SetPoint("BOTTOMLEFT")
    frame.PandemicBottom:SetPoint("BOTTOMRIGHT")
    frame.PandemicBottom:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic.png")
    frame.PandemicBottom:SetRotation(math.pi)
    frame.PandemicBottom:SetRoundLayoutToNearestPixel(true)
    frame.PandemicLeft = frame:CreateTexture(nil, "OVERLAY", nil, 5)
    frame.PandemicLeft:SetPoint("TOPLEFT")
    frame.PandemicLeft:SetPoint("BOTTOMLEFT")
    frame.PandemicLeft:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic-90.png")
    frame.PandemicLeft:SetRoundLayoutToNearestPixel(true)
    frame.PandemicRight = frame:CreateTexture(nil, "OVERLAY", nil, 5)
    frame.PandemicRight:SetPoint("TOPRIGHT")
    frame.PandemicRight:SetPoint("BOTTOMRIGHT")
    frame.PandemicRight:SetTexture("Interface/AddOns/Platynator/Assets/Special/pandemic-90.png")
    frame.PandemicRight:SetRotation(math.pi)
    frame.PandemicRight:SetRoundLayoutToNearestPixel(true)

    local pandemicDim = 1
    frame.PandemicTop:SetHeight(pandemicDim)
    frame.PandemicBottom:SetHeight(pandemicDim)
    frame.PandemicLeft:SetWidth(pandemicDim)
    frame.PandemicRight:SetWidth(pandemicDim)

    local fb = frame.PandemicAnimation:CreateAnimation("Flipbook")
    fb:SetFlipBookColumns(1)
    fb:SetFlipBookRows(11)
    fb:SetDuration(0.5)
    fb:SetTarget(frame.PandemicTop)
    local fb = frame.PandemicAnimation:CreateAnimation("Flipbook")
    fb:SetFlipBookColumns(1)
    fb:SetFlipBookRows(11)
    fb:SetDuration(0.5)
    fb:SetTarget(frame.PandemicBottom)
    local fb = frame.PandemicAnimation:CreateAnimation("Flipbook")
    fb:SetFlipBookColumns(11)
    fb:SetFlipBookRows(1)
    fb:SetDuration(0.5)
    fb:SetTarget(frame.PandemicLeft)
    local fb = frame.PandemicAnimation:CreateAnimation("Flipbook")
    fb:SetFlipBookColumns(11)
    fb:SetFlipBookRows(1)
    fb:SetDuration(0.5)
    fb:SetTarget(frame.PandemicRight)
    frame.PandemicAnimation:SetLooping("REPEAT")
    frame.PandemicAnimation:Stop()
  end
end

local function StyleAura(auraFrame, details, container, key)
  auraFrame.kind = details.kind

  auraFrame:EnableMouseMotion(details.showTooltips)

  if auraFrame.Applications then
    auraFrame.Applications:SetFontObject(addonTable.CurrentFont)
    auraFrame.Applications:ClearAllPoints()
    addonTable.Display.ApplyAnchor(auraFrame.Applications, details.texts.stacks.anchor, addonTable.CurrentFontUsesSmoothing and 1/details.texts.stacks.scale or 1)
    if addonTable.CurrentFontUsesSmoothing then
      auraFrame.Applications:SetTextScale(1)
      auraFrame.Applications:SetScale(details.texts.stacks.scale)
    else
      auraFrame.Applications:SetTextScale(details.texts.stacks.scale)
      auraFrame.Applications:SetScale(1)
    end
    local c1 = details.texts.stacks.color
    auraFrame.Applications:SetTextColor(c1.r, c1.g, c1.b)
    auraFrame.Applications:SetShown(details.texts.stacks.visible);
    auraFrame.Applications:SetSmoothScaling(addonTable.CurrentFontUsesSmoothing)
  end

  auraFrame.Countdown:SetShown(details.texts.countdown.visible)
  if details.texts.countdown.visible then
    auraFrame.Countdown:SetFontObject(addonTable.CurrentFont)
    auraFrame.Countdown:ClearAllPoints()
    addonTable.Display.ApplyAnchor(auraFrame.Countdown, details.texts.countdown.anchor, addonTable.CurrentFontUsesSmoothing and 1/details.texts.countdown.scale or 1)
    if addonTable.CurrentFontUsesSmoothing then
      auraFrame.Countdown:SetTextScale(1)
      auraFrame.Countdown:SetScale(details.texts.countdown.scale)
    else
      auraFrame.Countdown:SetTextScale(details.texts.countdown.scale)
      auraFrame.Countdown:SetScale(1)
    end
    local c2 = details.texts.countdown.color
    auraFrame.Countdown:SetTextColor(c2.r, c2.g, c2.b)
    auraFrame:ClearDurationText()
    if details.texts.countdown.showFractions then
      auraFrame:SetDurationText(auraFrame.Countdown, {textFormatter = auraFormatter})
    else
      auraFrame:SetDurationText(auraFrame.Countdown, {textFormatter = auraPlainFormatter})
    end
  end

  auraFrame.Countdown:SetSmoothScaling(addonTable.CurrentFontUsesSmoothing)

  auraFrame.Cooldown:SetDrawEdge(details.showSwipe)
  auraFrame.Cooldown:SetDrawSwipe(details.showSwipe)

  local width = 20
  local height = 20 * details.height
  auraFrame:SetSize(width, height)
  auraFrame.Border:SetSize(width, height)
  auraFrame.Icon:SetSize(width, height)
  local texBase = 0.95 * (1 - details.height) / 2
  auraFrame.Icon:SetTexCoord(0.05, 0.95, 0.05 + texBase, 0.95 - texBase)

  auraFrame:ClearPandemicActiveAnimations()
  auraFrame:ClearAuraAssignedAnimations()
  auraFrame:ClearPandemicRegions()
  auraFrame:ClearDispelTypeTextures()
  if details.showType then
    GenerateDispelTexture(auraFrame, details)
    auraFrame.DispelBorder:Show()
    auraFrame:AddDispelTypeTexture(auraFrame.DispelBorder, {showIcon = false, showWhenHarmful = true, showWhenHelpful = true, style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset})
  elseif auraFrame.DispelBorder then
    auraFrame.DispelBorder:Hide()
  end

  if details.pandemic and details.pandemic.show then
    GeneratePandemicAnimation(auraFrame)
    auraFrame.PandemicTop:Show()
    auraFrame.PandemicLeft:Show()
    auraFrame.PandemicRight:Show()
    auraFrame.PandemicBottom:Show()
    local color = details.pandemic.color
    auraFrame.PandemicTop:SetVertexColor(color.r, color.g, color.b, color.a)
    auraFrame.PandemicLeft:SetVertexColor(color.r, color.g, color.b, color.a)
    auraFrame.PandemicRight:SetVertexColor(color.r, color.g, color.b, color.a)
    auraFrame.PandemicBottom:SetVertexColor(color.r, color.g, color.b, color.a)
    auraFrame:AddPandemicRegion(auraFrame.PandemicTop)
    auraFrame:AddPandemicRegion(auraFrame.PandemicLeft)
    auraFrame:AddPandemicRegion(auraFrame.PandemicRight)
    auraFrame:AddPandemicRegion(auraFrame.PandemicBottom)
    auraFrame:AddPandemicActiveAnimation(auraFrame.PandemicAnimation)
  elseif details.purgeable and details.purgeable.show then
    GeneratePandemicAnimation(auraFrame)
    auraFrame.PandemicTop:Show()
    auraFrame.PandemicLeft:Show()
    auraFrame.PandemicRight:Show()
    auraFrame.PandemicBottom:Show()
    local color = details.purgeable.color
    local options = {
      showWhenHarmful = false,
      showWhenHelpful = true,
      stealableFilter = Enum.CustomAuraButtonDispelTypeStealableFilter.Stealable,
      style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
      customDispelColorMap = {
        ["Magic"] = color,
        ["Curse"] = color,
        ["Disease"] = color,
        ["Poison"] = color,
        ["Enrage"] = color,
        ["Bleed"] = color,
      }
    }
    auraFrame:AddDispelTypeTexture(auraFrame.PandemicTop, options)
    auraFrame:AddDispelTypeTexture(auraFrame.PandemicLeft, options)
    auraFrame:AddDispelTypeTexture(auraFrame.PandemicRight, options)
    auraFrame:AddDispelTypeTexture(auraFrame.PandemicBottom, options)
    auraFrame.PandemicTop:SetVertexColor(color.r, color.g, color.b, color.a)
    auraFrame.PandemicLeft:SetVertexColor(color.r, color.g, color.b, color.a)
    auraFrame.PandemicRight:SetVertexColor(color.r, color.g, color.b, color.a)
    auraFrame.PandemicBottom:SetVertexColor(color.r, color.g, color.b, color.a)
    auraFrame:AddAuraAssignedAnimation(auraFrame.PandemicAnimation)
  elseif auraFrame.PandemicAnimation then
    auraFrame.PandemicTop:Hide()
    auraFrame.PandemicLeft:Hide()
    auraFrame.PandemicRight:Hide()
    auraFrame.PandemicBottom:Hide()
    auraFrame.PandemicAnimation:Stop()
  end
end

local function GetAurasInitializerModern(container, key)
  local borderAsset = LSM:Fetch("nineslice", "MM: 1px")
  local kind = container.details.kind
  return function(frame)
    table.insert(container.frames, frame)
    frame:SetFlattensRenderLayers(true)
    frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.Cooldown:SetFrameLevel(frame:GetFrameLevel())
    frame.Cooldown:SetDrawBling(false)
    frame.Cooldown:SetHideCountdownNumbers(true)
    frame.Cooldown:SetDrawEdge(true)
    frame.Cooldown:SetReverse(true)
    frame:SetDurationCooldown(frame.Cooldown)

    frame.Icon = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    frame.Icon:SetPoint("CENTER", frame)
    frame:SetIcon(frame.Icon)

    frame.Countdown = frame:CreateFontString(nil, nil, "GameFontHighlight")
    frame.Countdown:SetDrawLayer("OVERLAY", 6)
    frame.Countdown:SetPoint("CENTER")
    if kind ~= "crowdControl" then
      frame.Applications = frame:CreateFontString(nil, nil, "GameFontHighlight")
      frame.Applications:SetDrawLayer("OVERLAY", 7)
      frame.Applications:SetPoint("BOTTOMRIGHT", 3, -2)
      frame:SetApplicationCount(frame.Applications, {})
    end

    frame.Border = frame:CreateTexture(nil, "OVERLAY", nil, 1)
    frame.Border:SetAllPoints(true)
    frame.Border:SetScale(borderAsset.scaleModifier)
    frame.Border:SetTexture(borderAsset.file)
    frame.Border:SetTextureSliceMargins(borderAsset.margins.left, borderAsset.margins.top, borderAsset.margins.right, borderAsset.margins.bottom)
    frame.Border:SetVertexColor(0, 0, 0)

    frame.key = key

    PixelUtil.SetRoundLayoutToNearestPixelRecursively(frame, true)

    if container.details then
      StyleAura(frame, container.details, container, key)
    end
  end
end

addonTable.Display.AurasManagerNextMixin = {}

function addonTable.Display.AurasManagerNextMixin:OnLoad()
  self.buffs = CreateFrame("AuraContainer", nil, self, "CustomAuraContainerTemplate")
  self.debuffs = CreateFrame("AuraContainer", nil, self, "CustomAuraContainerTemplate")
  self.crowdControl = CreateFrame("AuraContainer", nil, self, "CustomAuraContainerTemplate")

  self.slots = CreateFrame("AuraContainer", nil, self, "CustomAuraContainerTemplate")

  self.buffs:SetEnabled(false)
  self.buffs:SetRoundLayoutToNearestPixel(true)
  self.debuffs:SetEnabled(false)
  self.debuffs:SetRoundLayoutToNearestPixel(true)
  self.crowdControl:SetEnabled(false)
  self.crowdControl:SetRoundLayoutToNearestPixel(true)
  self.slots:SetEnabled(false)
  self.slots:SetRoundLayoutToNearestPixel(true)

  self.initialSetup = true

  self.crowdControl.frames = {}
  self.buffs.frames = {}
  self.debuffs.frames = {}
  self.slots.framesByKey = {}
  self.slots.occupied = 0
  self.slots.available = 0

  addonTable.CallbackRegistry:RegisterCallback("SpecializationChanged", function()
    if not self.initialSetup then
      self:InitializeWidgets(self.parent, self.auraDetails, true)
      if self.unit then
        self:SetUnit(self.unit)
      end
    end
  end, self)
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

local function ProcessSpells(kind)
  local settings
  if kind == "crowdControl" then
    settings = addonTable.Config.Get(addonTable.Config.Options.AURA_FILTERS).crowdControl
  else
    settings = addonTable.Config.Get(addonTable.Config.Options.AURA_FILTERS)[addonTable.Display.Utilities.GetSpecializationID()][kind]
  end

  local include = {}
  local exclude = {}

  for spellID, priority in pairs(settings.include) do
    exclude[spellID] = true
    if not include[priority] then
      include[priority] = {}
    end
    include[priority][spellID] = true
  end

  for spellID in pairs(settings.exclude) do
    exclude[spellID] = true
  end

  return include, exclude
end

local _, class = UnitClass("player")
local Kind = {
  All = 0,
  Friendly = 1,
  Enemy = 2,
}

function addonTable.Display.AurasManagerNextMixin:GetFilters(kind, settings)
  local output = table.create(6)
  local include, exclude = ProcessSpells(kind)
  local includeFilter
  if kind == "buffs" then
    includeFilter = settings.filters.playerFromYou and "HELPFUL|PLAYER" or "HELPFUL"
  elseif kind == "debuffs" then
    includeFilter = settings.filters.fromYou and "HARMFUL|PLAYER" or "HARMFUL"
  elseif kind == "crowdControl" then
    includeFilter = settings.filters.fromYou and "HARMFUL|PLAYER" or "HARMFUL"
  end
  local customKind = kind == "buffs" and Kind.Friendly or Kind.Enemy
  local start, tail, deduplicate = 0, 0, 0
  for i = 1, 2 do
    if include[i] then
      start = start + 1
      table.insert(output, {includeFilter, {includeSpellIDs = include[i]}, customKind})
    end
  end

  local deduplicateAllClasses = addonTable.Config.Get(addonTable.Config.Options.AURA_DEDUPLICATE)
  if kind == "debuffs" and deduplicateAllClasses[class] then
    for _, spellID in ipairs(deduplicateAllClasses[class]) do
      if not exclude[spellID] then
        deduplicate = deduplicate + 1
        exclude[spellID] = true
        table.insert(output, {includeFilter, {includeSpellIDs = {[spellID] = true}}, Kind.Enemy, true})
      end
    end
  end

  if kind == "buffs" then
    local maxDuration = 300
    if settings.filters.showLongDurations then
      maxDuration = nil
    end
    local dispelTypes = nil
    if settings.filters.enrage or settings.filters.magic then
      dispelTypes = {}
      if settings.filters.enrage then
        dispelTypes["Enrage"] = true
      end
      if settings.filters.magic then
        dispelTypes["Magic"] = true
      end
    end

    table.insert(output, {"HELPFUL|PLAYER", {excludeSpellIDs = exclude, maxDuration = maxDuration}, Kind.Friendly})
    if settings.filters.defensive then
      table.insert(output, {"HELPFUL|BIG_DEFENSIVE|!PLAYER", {excludeSpellIDs = exclude, maxDuration = maxDuration}, Kind.All})
      table.insert(output, {"HELPFUL|EXTERNAL_DEFENSIVE|!BIG_DEFENSIVE|!PLAYER", {excludeSpellIDs = exclude, maxDuration = maxDuration}, Kind.All})
      table.insert(output, {"HELPFUL|RAID_IN_COMBAT|!EXTERNAL_DEFENSIVE|!BIG_DEFENSIVE|!PLAYER", {excludeSpellIDs = exclude, maxDuration = maxDuration}, Kind.All})
    elseif settings.filters.important then
      table.insert(output, {"HELPFUL|IMPORTANT|!PLAYER", {excludeSpellIDs = exclude, maxDuration = maxDuration}, Kind.All})
      if dispelTypes then
        table.insert(output, {"HELPFUL|!IMPORTANT|!PLAYER", {
          includeDispelTypes = dispelTypes,
          excludeSpellIDs = exclude,
        }, Kind.Enemy})
      end
      if settings.filters.dispellable then
        table.insert(output, {"HELPFUL|!IMPORTANT|!PLAYER", {excludeSpellIDs = exclude, excludeDispelTypes = dispelTypes, isStealable = true, maxDuration = maxDuration}, Kind.Enemy})
      end
    else
      if settings.filters.dispellable or settings.filters.enrage or settings.filters.magic then
        if dispelTypes then
          table.insert(output, {"HELPFUL|!PLAYER", {excludeSpellIDs = exclude, includeDispelTypes = dispelTypes, maxDuration = maxDuration}, Kind.Enemy})
        end
        if settings.filters.dispellable then
          table.insert(output, {"HELPFUL|!PLAYER", {excludeSpellIDs = exclude, isStealable = true, excludeDispelTypes = dispelTypes, maxDuration = maxDuration}, Kind.Enemy})
        end
      else
        table.insert(output, {"HELPFUL|!PLAYER", {excludeSpellIDs = exclude}, maxDuration = maxDuration})
      end
    end
  elseif kind == "debuffs" then
    local playerFilter = ""
    if settings.filters.fromYou then
      playerFilter = "|PLAYER"
    end
    local nameplateShowAll = nil
    if not settings.filters.includeExtras then
      nameplateShowAll = false
    end
    if settings.filters.important then
      table.insert(output, {"HARMFUL|!CROWD_CONTROL" .. playerFilter, {excludeSpellIDs = exclude, nameplateShowAll = nameplateShowAll, nameplateShowPersonal = true}, Kind.All})
    else
      table.insert(output, {"HARMFUL|!CROWD_CONTROL" .. playerFilter, {excludeSpellIDs = exclude, nameplateShowAll = nameplateShowAll}, Kind.All})
    end
  elseif kind == "crowdControl" then
    if settings.filters.fromYou then
      table.insert(output, {"HARMFUL|CROWD_CONTROL|PLAYER", {excludeSpellIDs = exclude}, Kind.All})
      if settings.filters.includeExtras then
        table.insert(output, {"HARMFUL|!CROWD_CONTROL|PLAYER", {nameplateShowAll = true}, Kind.All})
      end
    else
      table.insert(output, {"HARMFUL|CROWD_CONTROL", {excludeSpellIDs = exclude}, Kind.All})
      if settings.filters.includeExtras then
        table.insert(output, {"HARMFUL|!CROWD_CONTROL", {nameplateShowAll = true}, Kind.All})
      end
    end
  end

  if include[3] then
    table.insert(output, {includeFilter, {includeSpellIDs = include[3]}, customKind})
    tail = tail + 1
  end

  local friendlyCount, enemyCount = 0, 0
  for _, entry in ipairs(output) do
    if entry[3] == Kind.Friendly then
      friendlyCount = friendlyCount + 1
    elseif entry[3] == Kind.Enemy then
      enemyCount = enemyCount + 1
    else
      friendlyCount = friendlyCount + 1
      enemyCount = enemyCount + 1
    end
  end

  return output, math.max(friendlyCount, enemyCount)
end

function addonTable.Display.AurasManagerNextMixin:InitializeWidgets(parent, auraDetails, doNotSize)
  local newFont = addonTable.Core.GetDesignByName(addonTable.Display.Context:GetDefaultEnemyNPCDesign()).font

  local isSameFont = self.lastFont and tCompare(self.lastFont, newFont) or false

  self.lastKind = nil

  self.parent = parent

  self.buffs:ClearAllPoints()
  self.debuffs:ClearAllPoints()
  self.crowdControl:ClearAllPoints()

  self.buffs.details = auraDetails.buffs
  self.debuffs.details = auraDetails.debuffs
  self.crowdControl.details = auraDetails.crowdControl

  self.buffs:Hide()
  self.buffs:SetParent(parent.BuffDisplay)
  self.debuffs:Hide()
  self.debuffs:SetParent(parent.DebuffDisplay)
  self.crowdControl:Hide()
  self.crowdControl:SetParent(parent.CrowdControlDisplay)

  self.buffs:SetEnabled(false)
  self.debuffs:SetEnabled(false)
  self.crowdControl:SetEnabled(false)
  self.slots:SetEnabled(false)

  for kind, details in pairs(auraDetails) do
    local groups, required = self:GetFilters(kind, details)

    self[kind].groupLiveCount = required
    self[kind].friendlyGroups = tFilter(groups, function(g) return g[3] == Kind.All or g[3] == Kind.Friendly end, true)
    self[kind].enemyGroups = tFilter(groups, function(g) return g[3] == Kind.All or g[3] == Kind.Enemy end, true)

    self[kind]:SetScale(details.scale)
    self[kind]:SetPoint(directionMap[details.direction])
    self[kind]:SetFlowLayoutAnchorPoint(anchorMap[details.direction])

    if not self[kind].groupsCount or self[kind].groupsCount < required then
      for i = self[kind].groupsCount and self[kind].groupsCount + 1 or 1, required do
        local key = tostring(i)
        self[kind]:AddAuraGroup(key, "", {initializeFrame = GetAurasInitializerModern(self[kind], key)})
      end
      self[kind].groupsCount = required
    end

    local padding = 20 * details.padding

    for i = 1, self[kind].groupsCount do
      local key = tostring(i)
      self[kind]:SetAuraGroupLayout(key, {elementSpacing = padding, lineSpacing = padding})
      self[kind]:SetAuraGroupEnabled(key, false)
    end

    if not addonTable.Utilities.IsChangesRestricted() and not self.initialSetup and not doNotSize and (not self.auraDetails or not tCompare(details, self.auraDetails[kind] or {}) or not isSameFont) then
      for _, f in ipairs(self[kind].frames) do
        StyleAura(f, details, self[kind], f.key)
      end
    end

    if details.direction == "LEFT" then
      self[kind]:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Left, AnchorUtil.FlowDirection.Up)
    else
      self[kind]:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, AnchorUtil.FlowDirection.Up)
    end

    self[kind]:Show()
  end

  self.auraDetails = CopyTable(auraDetails)
  self.lastFont = CopyTable(newFont)

  self.initialSetup = false
end

local function ApplyGroups(auras, groups, limit)
  for i, group in ipairs(groups) do
    local key = tostring(i)
    auras:SetAuraGroupFilterString(key, group[1])
    auras:SetAuraGroupCandidateFilters(key, group[2])
    auras:SetAuraGroupMaxFrameCount(key, group[4] and 1 or limit)
    auras:SetAuraGroupEnabled(key, true)
  end

  if auras.groupLiveCount > #groups then
    for i = #groups + 1, auras.groupLiveCount do
      auras:SetAuraGroupEnabled(tostring(i), false)
    end
  end
end

function addonTable.Display.AurasManagerNextMixin:ReleaseSlots()
  if addonTable.Utilities.IsChangesRestricted() then
    return
  end

  if self.slots.occupied > 0 then
    for i = 1, self.slots.occupied do
      self.slots:SetAuraGroupEnabled(tostring(i), false)
    end
  end
end

function addonTable.Display.AurasManagerNextMixin:AcquireSlot(height, point, filterString, spellID)
  self.slots.occupied = self.slots.occupied + 1
  local key = tostring(self.slots.occupied)
  if self.slots.available >= self.slots.occupied then
    local frame = self.slots.framesByKey[key]
    if not addonTable.Utilities.IsChangesRestricted() then
      frame.height = height
      frame:SetHeight(height)
    end
    self.slots:SetAuraSlotEnabled(key, true)
    self.slots:SetAuraSlotFilterString(key, filterString)
    self.slots:SetAuraSlotCandidateFilters(key, {
      includeSpellIDs = {[spellID] = true}
    })
    return self.slots.framesByKey[key]
  end

  local frame = self.slots:AddAuraSlot(key, filterString, {initializeFrame = function(auraFrame)
    auraFrame.key = key
    auraFrame.height = height
    auraFrame:SetSize(20, height)
    auraFrame:SetPoint(unpack(point))
    auraFrame:SetCollapsesLayout(true)
    auraFrame:EnableMouseMotion(false)
    auraFrame:SetRoundLayoutToNearestPixel(true)
  end, candidateFilters = { includeSpellIDs = {[spellID] = true} } })

  self.slots.framesByKey[key] = frame

  self.slots.available = self.slots.available + 1

  return frame
end

function addonTable.Display.AurasManagerNextMixin:SetUnit(unit)
  self.unit = unit
  if not unit then
    self.buffs:SetEnabled(false)
    self.debuffs:SetEnabled(false)
    self.crowdControl:SetEnabled(false)
    self.slots:SetEnabled(false)
    return
  end

  if UnitCanAssist("player", unit) then
    if self.lastKind ~= Kind.Friendly then
      if self.debuffs.details then
        ApplyGroups(self.debuffs, self.debuffs.friendlyGroups, self.debuffs.details.limit)
      end
      if self.crowdControl.details then
        ApplyGroups(self.crowdControl, self.crowdControl.friendlyGroups, self.crowdControl.details.limit)
      end
      if self.buffs.details then
        ApplyGroups(self.buffs, self.buffs.friendlyGroups, self.buffs.details.limit)
      end
      self.lastKind = Kind.Friendly
    end
  else
    if self.lastKind ~= Kind.Enemy then
      if self.debuffs.details then
        ApplyGroups(self.debuffs, self.debuffs.enemyGroups, self.debuffs.details.limit)
      end
      if self.crowdControl.details then
        ApplyGroups(self.crowdControl, self.crowdControl.enemyGroups, self.crowdControl.details.limit)
      end
      if self.buffs.details then
        ApplyGroups(self.buffs, self.buffs.enemyGroups, self.buffs.details.limit)
      end
      self.lastKind = Kind.Enemy
    end
  end

  self.buffs:SetUnit(unit)
  self.debuffs:SetUnit(unit)
  self.crowdControl:SetUnit(unit)
  self.slots:SetUnit(unit)

  self.buffs:SetEnabled(self.buffs.details ~= nil and (not UnitTreatAsPlayerForDisplay(unit) or not addonTable.Display.Utilities.IsInRelevantInstance({delve = true})))
  self.debuffs:SetEnabled(self.debuffs.details ~= nil)
  self.crowdControl:SetEnabled(self.crowdControl.details ~= nil)
  self.slots:SetEnabled(self.slots.occupied > 0)
end
