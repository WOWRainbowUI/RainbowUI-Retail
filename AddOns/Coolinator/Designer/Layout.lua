---@class addonTableCoolinator
local addonTable = select(2, ...)

local function Announce()
  addonTable.CallbackRegistry:TriggerEvent("Designer.Layout")
end

local function SavePresetAnchor(details)
  if details.kind == "group" and details.anchor and details.preset then
    addonTable.Core.SavePreset(details.preset, details, true)
  end
end

local function CheckChildren(details, checker)
  if checker(details) then
    return true
  elseif details.kind == "group" then
    for _, entry in ipairs(details.entries) do
      if CheckChildren(entry, checker) then
        return true
      end
    end
  end
  return false
end

-- Strip all groups that aren't strictly necessary for layout
local function Degroup(groupDetails)
  for _, entry in ipairs(groupDetails.entries) do
    if entry.kind == "group" then
      Degroup(entry)
    end
  end
  if groupDetails.layout ~= "standalone" then
    local final = {}
    for _, entry in ipairs(groupDetails.entries) do
      if entry.kind == "group" and (
        entry.layout == groupDetails.layout and entry.padding == groupDetails.padding and entry.alignment == groupDetails.alignment
        or #entry.entries == 1
      ) and entry.alpha == 1 and entry.scale == 1
      then
        tAppendAll(final, entry.entries)
      elseif (entry.kind ~= "group" or #entry.entries > 0) then
        table.insert(final, entry)
      end
    end
    groupDetails.entries = final

    if #final == 1 and final[1].kind == "group" then
      local entry = final[1]
      groupDetails.alpha = groupDetails.alpha * entry.alpha
      groupDetails.scale = groupDetails.scale * entry.scale
      groupDetails.layout = entry.layout
      groupDetails.padding = entry.padding
      groupDetails.alignment = entry.alignment
      groupDetails.entries = entry.entries
      groupDetails.preset = entry.preset
      tAppendAll(groupDetails.visibility, entry.visibility)
      if groupDetails.anchor then
        SavePresetAnchor(groupDetails)
      end
    end
  end
end

local function IsSimilarEnough(details1, details2)
  if not details1 or not details2 then
    return false
  end
  if details1.kind ~= details2.kind then
    return false
  end
  if details1.kind == "bar" and details1.resource.kind ~= details2.resource.kind then
    return false
  end
  return true
end

-- Group similar widgets together automatically
local function GroupSimilar(groupDetails)
  if groupDetails.layout == "standalone" then
    for _, entry in ipairs(groupDetails.entries) do
      GroupSimilar(entry)
    end
    return
  end
  local last
  local count = 1
  local index = 1
  local function Apply()
    local entries = {}
    for i = index - count, index - 1 do
      local entry = groupDetails.entries[i]
      table.insert(entries, entry)
    end
    for i = index - 1, index - count, -1 do
      table.remove(groupDetails.entries, i)
    end
    index = index - count
    local new = CopyTable(addonTable.Designer.Defaults.Group)
    new.alignment = groupDetails.alignment
    new.layout = groupDetails.layout
    new.padding = groupDetails.padding
    new.entries = entries
    table.insert(groupDetails.entries, index, new)
  end
  while index <= #groupDetails.entries do
    local details = groupDetails.entries[index]
    if IsSimilarEnough(details, last) and details.kind ~= "group" then
      count = count + 1
    elseif count > 1 then
      Apply()
      count = 1
    else
      count = 1
    end
    index = index + 1
    last = details
  end
  if count > 1 and count ~= #groupDetails.entries then
    Apply()
  end

  if #groupDetails.entries == 1 then
    if groupDetails.entries[1].kind == "group" and (
      groupDetails.entries[1].alignment == groupDetails.alignment or groupDetails.entries[1].layout ~= groupDetails.layout
    ) then
      groupDetails.scale = groupDetails.entries[1].scale * groupDetails.scale
      groupDetails.alpha = groupDetails.entries[1].alpha * groupDetails.alpha
      groupDetails.layout = groupDetails.entries[1].layout
      groupDetails.alignment = groupDetails.entries[1].alignment
      groupDetails.padding = groupDetails.entries[1].padding
      groupDetails.entries = groupDetails.entries[1].entries
      tAppendAll(groupDetails.visibility, groupDetails.entries[1].visibility)
    end
  end

  for _, entry in ipairs(groupDetails.entries) do
    if entry.kind == "group" then
      GroupSimilar(entry)
    end
  end
end

local function AutoGroup(groupDetails)
  Degroup(groupDetails)
  GroupSimilar(groupDetails)
end

local function DeleteRoot(root, shouldUpdate)
  if root.details.layout == "standalone" then
    return
  end
  local parentDetails = root:GetParent().details
  local index = tIndexOf(parentDetails.entries, root.details)
  if not index then
    return
  end

  table.remove(parentDetails.entries, index)
  root.deleted = true
  if #parentDetails.entries == 0 and parentDetails.layout ~= "standalone" then
    DeleteRoot(root:GetParent(), false)
  elseif parentDetails.kind == "stack" and #parentDetails.entries == 1 then
    local superParent = root:GetParent():GetParent().details
    local parentIndex = tIndexOf(superParent.entries, parentDetails)
    superParent.entries[parentIndex] = parentDetails.entries[1]
  end

  local details = root.details
  if shouldUpdate then
    addonTable.CallbackRegistry:TriggerEvent("Designer.Options", {})
  end
end

local function DoesRootOverlapSufficiently(root, group)
  local topExtension = root:GetTop()*root:GetEffectiveScale() - group:GetTop()*group:GetEffectiveScale()
  local bottomExtension = group:GetBottom()*group:GetEffectiveScale() - root:GetBottom()*root:GetEffectiveScale()
  local rightExtension = root:GetRight()*root:GetEffectiveScale() - group:GetRight()*group:GetEffectiveScale()
  local leftExtension = group:GetLeft()*group:GetEffectiveScale() - root:GetLeft()*root:GetEffectiveScale()
  local heightMargin = root:GetHeight()*root:GetEffectiveScale() * 0.4
  local widthMargin = root:GetHeight()*root:GetEffectiveScale() * 0.4
  local isTaller = root:GetHeight()*root:GetEffectiveScale() >= group:GetHeight()*group:GetEffectiveScale() * 0.8
  local isWider = root:GetWidth()*root:GetEffectiveScale() >= group:GetWidth()*group:GetEffectiveScale() * 0.8
  local widthDifference = (root:GetWidth()*root:GetEffectiveScale() - group:GetWidth()*group:GetEffectiveScale()) * 0.6
  local heightDifference = (root:GetHeight()*root:GetEffectiveScale() - group:GetHeight()*group:GetEffectiveScale()) * 0.6
  return (
    (topExtension < heightMargin and bottomExtension < heightMargin) or
    isTaller and (
      (topExtension >= 0 and topExtension < heightMargin and bottomExtension < 0) or
      (bottomExtension >= 0 and bottomExtension < heightMargin and topExtension < 0) or
      topExtension <= heightDifference and bottomExtension <= heightDifference
    )
  ) and (
    (rightExtension < widthMargin and leftExtension < widthMargin) or
    isWider and (
      (rightExtension >= 0 and rightExtension < widthMargin and leftExtension < 0) or
      (leftExtension >=0 and leftExtension < widthMargin and rightExtension < 0) or
      leftExtension <= widthDifference and rightExtension <= widthDifference
    )
  )
end

addonTable.Designer.LayoutManagerMixin = CreateFromMixins(addonTable.Display.BaseLayoutManagerMixin)

local function GetSelectorMarker(frame, isHover)
  local texture = frame:CreateTexture()
  texture:SetTexture("Interface/AddOns/Coolinator/Assets/selection-outline.png")
  texture:SetVertexColor(78/255, 165/255, 252/255, isHover and 0.45 or 0.8)
  texture:SetTextureSliceMargins(45, 45, 45, 45)
  texture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
  texture:SetScale(0.25)
  texture:SetAllPoints()

  return frame
end

local function GetInsertionMarker(frame, atlas)
  local texture = frame:CreateTexture()
  texture:SetAtlas(atlas)
  texture:SetAllPoints()

  return frame
end

local function ImportStyle(new, old)
  assert(new.resource.kind == old.resource.kind)
  for key, val in pairs(old) do
    if key ~= "kind" and key ~= "resource" then
      new[key] = type(val) == "table" and CopyTable(val) or val
    end
  end
end

local function GetButton(frame, asset)
  local button = CreateFrame("Button", nil, frame)
  button:SetNormalTexture("Interface/AddOns/Coolinator/Assets/Buttons/dark-up.png")
  button:SetPushedTexture("Interface/AddOns/Coolinator/Assets/Buttons/dark-down.png")
  button.Icon = button:CreateTexture(nil ,"OVERLAY")
  button.Icon:SetAllPoints()
  button.Icon:SetPoint("CENTER")
  button.Icon:SetTexture(asset)
  button:SetScript("OnMouseDown", function()
    button.Icon:SetPoint("CENTER", -1, -1)
  end)
  button:SetScript("OnMouseUp", function()
    button.Icon:SetPoint("CENTER", 0, 0)
  end)
  button:SetSize(30, 30)
  button:SetFrameLevel(9999)

  return button
end

function addonTable.Designer.LayoutManagerMixin:OnLoad()
  addonTable.Display.BaseLayoutManagerMixin.OnLoad(self)
  self.relativeLayoutMode = false
  self.autoSize = false
  self:SetScript("OnEvent", self.OnEvent)

  self.pools = {
    group = addonTable.Display.GeneratePool(addonTable.Designer.GroupMixin, ""),
    stack = addonTable.Display.GeneratePool(addonTable.Display.StackMixin, ""),
    spacer = addonTable.Display.GeneratePool(addonTable.Designer.SpacerMixin, ""),
    icon = addonTable.Display.GeneratePool(addonTable.Designer.IconMixin, ""),
    bar = addonTable.Display.GeneratePool(addonTable.Designer.BarMixin, ""),
    barIcon = addonTable.Display.GeneratePool(addonTable.Designer.BarWithIconMixin, ""),
  }

  self.selectorPool = CreateFramePool("Frame", UIParent, nil, nil, false, GetSelectorMarker)
  self.hoverMarker = GetSelectorMarker(CreateFrame("Frame", nil, UIParent), true)
  self.hoverMarker:SetFrameLevel(9999)

  self.insertVertical = GetInsertionMarker(CreateFrame("Frame", nil, UIParent), "CDM-horizontal")
  self.insertVertical:SetFrameLevel(9999)
  self.insertHorizontal = GetInsertionMarker(CreateFrame("Frame", nil, UIParent), "CDM-vertical")
  self.insertHorizontal:SetFrameLevel(9999)

  self.auraFrame = addonTable.Designer.GetAuraDialog()
  self.itemFrame = addonTable.Designer.GetItemDialog()
  self.abilityFrame = addonTable.Designer.GetAbilityDialog()
  self.abilityChargesFrame = addonTable.Designer.GetAbilityChargesDialog()
  self.potionFrame = addonTable.Designer.GetPotionEffectDialog()
  self.equipmentFrame = addonTable.Designer.GetEquipmentDialog()
  self.selectParentButton = GetButton(self, "Interface/AddOns/Coolinator/Assets/Buttons/chain.png")
  self.selectParentButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(self.selectParentButton, "ANCHOR_LEFT")
    GameTooltip:SetText(addonTable.Locales.SELECT_GROUP)
  end)
  self.selectParentButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  self.insertButton = {
    GetButton(self, "Interface/AddOns/Coolinator/Assets/Buttons/plus.png"),
    GetButton(self, "Interface/AddOns/Coolinator/Assets/Buttons/plus.png"),
  }
  for _, b in ipairs(self.insertButton) do
    b:SetScript("OnEnter", function()
      GameTooltip:SetOwner(b, "ANCHOR_LEFT")
      GameTooltip:SetText(addonTable.Locales.INSERT)
    end)
    b:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
  end
  self.deleteButton = GetButton(self, "Interface/AddOns/Coolinator/Assets/Buttons/cross.png")
  self.dragButton = GetButton(self, "Interface/AddOns/Coolinator/Assets/Buttons/drag.png")
  self.dragButton:SetSize(40, 40)

  addonTable.CallbackRegistry:RegisterCallback("Designer.Open", function()
    self.open = true
    self:Layout()
  end)
  addonTable.CallbackRegistry:RegisterCallback("Designer.Layout", function()
    if self.open then
      self:Layout()
    end
  end)
  addonTable.CallbackRegistry:RegisterCallback("Designer.Close", function()
    self:Delayout()
    self.selection = {}
    self.open = false
  end)
  addonTable.CallbackRegistry:RegisterCallback("Designer.Options", function(_, new)
    self.selection = new
  end, self)
  addonTable.CallbackRegistry:RegisterCallback("Designer.Reanchor", self.Reanchor, self)

  self.keyboardTrap = CreateFrame("Frame", nil, self)
  self.keyboardTrap:Hide()
  local function OffsetWidgets(x, y)
    local any = false
    for _, details in ipairs(self.selection) do
      local root = self:GetForDetails(details, self.root)
      if root:GetParent().details.layout == "standalone" then
        any = true
        root:AdjustPointsOffset(x / root.details.scale, y / root.details.scale)
        local _, newX, newY = addonTable.Designer.ConvertAnchorToCorner(root.details.anchor[1], root, UIParent)
        root.details.anchor[4] = newX * root.details.scale
        root.details.anchor[5] = newY * root.details.scale
        SavePresetAnchor(root.details)
      end
    end
    if any then
      Announce()
      return true
    end
  end

  self.keyboardTrap:SetScript("OnKeyDown", function(_, key)
    self.keyboardTrap:SetPropagateKeyboardInput(false)
    local amount = 0.5
    if IsShiftKeyDown() then
      amount = amount * 4
    end
    local result
    if key == "LEFT" then
      result = OffsetWidgets(-amount, 0)
    elseif key == "RIGHT" then
      result = OffsetWidgets(amount, 0)
    elseif key == "UP" then
      result = OffsetWidgets(0, amount)
    elseif key == "DOWN" then
      result = OffsetWidgets(0, -amount)
    elseif key == "DELETE" then
      for _, details in ipairs(self.selection) do
        local root = self:GetForDetails(details, self.root)
        if root then
          DeleteRoot(root, false)
        end
      end
      if #self.selection > 0 then
        result = true
        AutoGroup(self.root.details)
        addonTable.CallbackRegistry:TriggerEvent("Designer.Options", {})
        Announce()
      end
    end
    self.keyboardTrap:SetPropagateKeyboardInput(not result)
  end)
  self.keyboardTrap:RegisterEvent("PLAYER_REGEN_ENABLED")
  self.keyboardTrap:RegisterEvent("PLAYER_REGEN_DISABLED")
  self.keyboardTrap:SetScript("OnEvent", function(_, event)
    self.keyboardTrap:SetShown(event == "PLAYER_REGEN_ENABLED" and #self.selection > 0)
  end)

  self.selection = {}
end

function addonTable.Designer.LayoutManagerMixin:GetBar(details)
  local bar
  if details.resource.kind == "aura" or details.resource.kind == "ability" or details.resource.kind == "cast" then
    bar = self.pools.barIcon:Acquire()
  else
    bar = self.pools.bar:Acquire()
  end
  bar:Show()
  bar:Setup(details)
  return bar
end

function addonTable.Designer.LayoutManagerMixin:GetIcon(details)
  local icon = self.pools.icon:Acquire()
  icon:Show()
  icon:Setup(details)
  return icon
end

function addonTable.Designer.LayoutManagerMixin:Delayout()
  self.pending = true
  for _, p in pairs(self.pools) do
    p:ReleaseAll()
  end

  self.insertHorizontal:Hide()
  self.insertVertical:Hide()

  self:SetScript("OnUpdate", nil)
  self:UnregisterAllEvents()
  self.toArrange = {}
  self.pending = false
end

function addonTable.Designer.LayoutManagerMixin:GetDeepestGroupOverlapping(root, currentGroup)
  if currentGroup.details.kind ~= "group" then
    return nil
  end
  for _, g in ipairs(currentGroup.children) do
    if g.details ~= root.details and g.details.kind == "group" and g:Intersects(root) and (DoesRootOverlapSufficiently(root, g) or currentGroup.details.layout == "standalone") then
      local nested = self:GetDeepestGroupOverlapping(root, g)
      if nested and DoesRootOverlapSufficiently(root, nested) then
        return nested
      else
        return g
      end
    end
  end

  return nil
end

function addonTable.Designer.LayoutManagerMixin:GetInsertionPointFromGroup(root, group)
  local startIndex, endIndex
  if group.details.layout == "vertical" then
    for index, child in ipairs(group.children) do
      if root:GetBottom()*root:GetEffectiveScale() <= child:GetTop()*child:GetEffectiveScale() and root:GetTop()*root:GetEffectiveScale() >= child:GetBottom()*child:GetEffectiveScale() and child.details ~= root.details then
        local mod = child:GetTop()*child:GetEffectiveScale()<root:GetTop()*root:GetEffectiveScale() and 1 or 0
        if startIndex == nil then
          startIndex = index + mod
          endIndex = index + mod
        else
          endIndex = index + mod
        end
      end
    end
  else
    for index, child in ipairs(group.children) do
      if root:GetLeft()*root:GetEffectiveScale() <= child:GetRight()*child:GetEffectiveScale() and root:GetRight()*root:GetEffectiveScale() >= child:GetLeft()*child:GetEffectiveScale() and child.details ~= root.details then
        local mod = child:GetRight()*child:GetEffectiveScale()<root:GetRight()*root:GetEffectiveScale() and 1 or 0
        if startIndex == nil then
          startIndex = index + mod
          endIndex = index + mod
        else
          endIndex = index + mod
        end
      end
    end
  end

  if startIndex == nil then
    return nil
  end

  return startIndex + math.floor((endIndex - startIndex) / 2)
end

function addonTable.Designer.LayoutManagerMixin:GetInsertDirection(root, group)
  local startIndex, endIndex
  if group.details.layout == "vertical" then
    for index, child in ipairs(group.children) do
      if root:GetBottom()*root:GetEffectiveScale() <= child:GetTop()*child:GetEffectiveScale() and root:GetTop()*root:GetEffectiveScale() >= child:GetBottom()*child:GetEffectiveScale() and child.details ~= root.details then
        if startIndex == nil then
          startIndex = index
          endIndex = index
        else
          endIndex = index
        end
      end
    end
  else
    for index, child in ipairs(group.children) do
      if root:GetLeft()*root:GetEffectiveScale() <= child:GetRight()*child:GetEffectiveScale() and root:GetRight()*root:GetEffectiveScale() >= child:GetLeft()*child:GetEffectiveScale() and child.details ~= root.details then
        if startIndex == nil then
          startIndex = index
          endIndex = index
        else
          endIndex = index
        end
      end
    end
  end
  if startIndex == nil then
    return nil
  end
  local index = startIndex + math.floor((endIndex - startIndex) / 2)

  local child = group.children[index]

  if child.details.kind ~= root.details.kind and (child.details.kind ~= "group" or child.details.entries[1].kind ~= root.details.kind) then
    index = -1
  end

  local topOverlap = child:GetTop()*child:GetEffectiveScale() - root:GetBottom()*root:GetEffectiveScale()
  local bottomOverlap = root:GetTop()*root:GetEffectiveScale() - child:GetBottom()*child:GetEffectiveScale()
  local rightOverlap = child:GetRight()*child:GetEffectiveScale() - root:GetLeft()*root:GetEffectiveScale()
  local leftOverlap = root:GetRight()*root:GetEffectiveScale() - child:GetLeft()*child:GetEffectiveScale()
  local heightMargin = math.min(root:GetHeight()*root:GetEffectiveScale(), child:GetHeight()*child:GetEffectiveScale()) * 0.4
  local widthMargin = math.min(root:GetHeight()*root:GetEffectiveScale(), child:GetWidth()*child:GetEffectiveScale()) * 0.4

  if topOverlap < heightMargin and rightOverlap > widthMargin and leftOverlap > widthMargin then
    return index, 2, "vertical"
  elseif bottomOverlap < heightMargin and rightOverlap > widthMargin and leftOverlap > widthMargin then
    return index, 1, "vertical"
  elseif rightOverlap < widthMargin and topOverlap > heightMargin and bottomOverlap > heightMargin then
    return index, 2, "horizontal"
  elseif leftOverlap < widthMargin and topOverlap > heightMargin and bottomOverlap > heightMargin then
    return index, 1, "horizontal"
  else
    return nil
  end
end

local wrapper = CreateFrame("Frame", nil, UIParent)

function addonTable.Designer.LayoutManagerMixin:InsertRootAt(root)
  local group = self:GetDeepestGroupOverlapping(root, self.root)
  if not group or IsAltKeyDown() or IsMetaKeyDown() then
    local details = root.details
    wrapper:SetAllPoints(root)
    local point, x, y = addonTable.Designer.ConvertAnchorToCorner("BOTTOM", wrapper, UIParent)
    wrapper:ClearAllPoints()
    local scale = 1
    if details.anchor then
      scale = root:GetEffectiveScale() / self.root:GetEffectiveScale()
      point, x, y = addonTable.Designer.ConvertAnchorToCorner(details.anchor[1], root, UIParent)
    end
    details.anchor = nil
    local new = CopyTable(addonTable.Designer.Defaults.Group)
    table.insert(new.entries, details)
    new.anchor = {point, "UIParent", point, x * scale, y * scale}
    DeleteRoot(root, false)
    table.insert(self.root.details.entries, new)
    AutoGroup(self.root.details)
    Announce()
    return
  end
  if root:GetParent() == group and #group.details.entries == 1 then
    if group.details.anchor then
      local point, _, relativePoint, x, y = root:GetPoint(1)
      group.details.anchor = {point, "UIParent", relativePoint, x * root:GetEffectiveScale() / self.root:GetEffectiveScale(), y * root:GetEffectiveScale() / self.root:GetEffectiveScale()}
      SavePresetAnchor(group.details)
    end
    Announce()
    return
  end
  local insertIndex = self:GetInsertionPointFromGroup(root, group)
  local altIndex, newIndex, layout = self:GetInsertDirection(root, group)
  local groupDetails = group.details
  local rootDetails = root.details
  local rootIndex = tIndexOf(groupDetails.entries, rootDetails)
  DeleteRoot(root, false)
  if layout and layout ~= groupDetails.layout then
    if rootIndex and altIndex >= rootIndex then
      altIndex = altIndex - 1
    end
    local childDetails = groupDetails.entries[altIndex]
    if #groupDetails.entries == 1 then
      groupDetails.layout = layout
      table.insert(groupDetails.entries, newIndex, rootDetails)
    elseif altIndex == -1 then
      local new = CopyTable(addonTable.Designer.Defaults.Group)
      new.layout = layout
      new.entries = {groupDetails}
      table.insert(new.entries, newIndex, rootDetails)
      local groupParentDetails = group:GetParent().details
      if groupParentDetails.layout == "standalone" then
        new.anchor = groupDetails.anchor
        groupDetails.anchor = nil
      end
      groupParentDetails.entries[tIndexOf(groupParentDetails.entries, groupDetails)] = new
    else
      local new = CopyTable(addonTable.Designer.Defaults.Group)
      new.layout = layout
      table.insert(new.entries, childDetails)
      table.insert(new.entries, newIndex, rootDetails)
      groupDetails.entries[altIndex] = new
    end
    AutoGroup(self.root.details)
  elseif insertIndex then
    if rootIndex and rootIndex < insertIndex then
      insertIndex = insertIndex - 1
    end
    table.insert(groupDetails.entries, insertIndex,  rootDetails)
    AutoGroup(self.root.details)
  else
    table.insert(groupDetails.entries, rootIndex,  rootDetails)
    AutoGroup(self.root.details)
  end
  Announce()
end

function addonTable.Designer.LayoutManagerMixin:AddHandlers(root)
  root.deleted = nil
  root:SetFrameLevel(root:GetParent():GetFrameLevel() + 1)
  root:SetAlpha(root.details.alpha or 1)
  root:SetScript("OnEnter", function()
    if root.OnEnter then
      root:OnEnter()
    end
    self.hoverMarker:SetAllPoints(root)
    self.hoverMarker:Show()
  end)
  root:SetScript("OnLeave", function()
    if root.OnLeave then
      root:OnLeave()
    end
    self.hoverMarker:Hide()
  end)
  root.isMoving = nil
  root:SetScript("OnMouseUp", function(_, button)
    if root.isMoving then
      root.isMoving = nil
      return
    end
    if button == "LeftButton" then
      local parentDetails = root:GetParent().details
      if parentDetails.kind == "stack" then
        MenuUtil.CreateContextMenu(root, function(_, rootDescription)
          for _, entry in ipairs(parentDetails.entries) do
            rootDescription:CreateButton(addonTable.Designer.GetLabel(entry), function()
              self:MarkSelected(entry)
            end)
          end
        end)
      else
        self:MarkSelected(root.details)
      end
    elseif button == "RightButton" then
      MenuUtil.CreateContextMenu(root, function(_, rootDescription)
        rootDescription:CreateButton(addonTable.Locales.OPTIONS, function()
          addonTable.CallbackRegistry:TriggerEvent("Designer.Options", {root.details})
        end)
        local parentDetails = root:GetParent() ~= UIParent and root:GetParent().details
        if parentDetails and parentDetails.layout ~= "standalone" then
          local insert = rootDescription:CreateButton(addonTable.Locales.INSERT)
          self:AddEntryToInsert(insert, root.details, function(new)
            table.insert(parentDetails.entries, (tIndexOf(parentDetails.entries, root.details) + 1) or 1, new)
            AutoGroup(self.root.details)
            Announce()
            addonTable.CallbackRegistry:TriggerEvent("Designer.Options", {new})
          end)
        end
        if root.details.kind == "icon" then
          local stack = rootDescription:CreateButton(addonTable.Locales.STACK)
          self:AddEntryToInsert(stack, root.details, function(new)
            self:StackElements(root, new)
          end, true)
        end
      end)
    end
  end)
  root:SetMovable(true)
  if root.details.kind ~= "group" then
    root:RegisterForDrag("LeftButton")
    root:SetScript("OnDragStart", function()
      self:StartMovingRoot(root)
    end)
    root:SetScript("OnDragStop", function()
      self:StopMovingRoot(root)
    end)
  end
  if root.details.kind == "group" or root.details.kind == "stack" then
    for _, entry in ipairs(root.children) do
      self:AddHandlers(entry)
    end
  end
end

function addonTable.Designer.LayoutManagerMixin:StartMovingRoot(root)
  if self.selection[1] ~= root.details or #self.selection > 1 then
    self.selection = {root.details}
    self:UpdateSelection()
  end
  root:SetFrameLevel(5000)
  root.isMoving = true
  root:StartMoving()
  root:SetScript("OnUpdate", function()
    self.insertHorizontal:Hide()
    self.insertVertical:Hide()
    local group = self:GetDeepestGroupOverlapping(root, self.root)
    if not group or IsAltKeyDown() or IsMetaKeyDown() then
      return
    end
    local insertIndex = self:GetInsertionPointFromGroup(root, group)
    local altIndex, newIndex, layout = self:GetInsertDirection(root, group)
    local anchorFrame
    local point = group.children[insertIndex]
    if layout and layout ~= group.details.layout then
      if altIndex == -1 then
        anchorFrame = group
      else
        anchorFrame = group.children[altIndex]
      end
    elseif not point then
      anchorFrame = group
      layout = group.details.layout
    end
    if anchorFrame then
      if layout == "vertical" then
        self.insertVertical:Show()
        self.insertVertical:SetPoint("TOP", anchorFrame, newIndex == 1 and "BOTTOM" or "TOP", 0, 4 - group.details.padding * (addonTable.Constants.nativeSize - 4))
        self.insertVertical:SetSize(anchorFrame:GetWidth(), 8)
      else
        self.insertHorizontal:Show()
        self.insertHorizontal:SetPoint("RIGHT", anchorFrame, newIndex == 1 and "LEFT" or "RIGHT", 4 - group.details.padding * (addonTable.Constants.nativeSize - 4), 0)
        self.insertHorizontal:SetSize(8, anchorFrame:GetHeight())
      end
    elseif point ~= root then
      if group.details.layout == "vertical" then
        self.insertVertical:Show()
        self.insertVertical:SetPoint("TOP", point, "BOTTOM", 0, 4 - group.details.padding * (addonTable.Constants.nativeSize - 4))
        self.insertVertical:SetSize(group:GetWidth(), 8)
      else
        self.insertHorizontal:Show()
        self.insertHorizontal:SetPoint("RIGHT", point, "LEFT", 4 - group.details.padding * (addonTable.Constants.nativeSize - 4), 0)
        self.insertHorizontal:SetSize(8, group:GetHeight())
      end
    end
  end)
end

function addonTable.Designer.LayoutManagerMixin:StopMovingRoot(root)
  if not root.isMoving then
    return
  end
  root.isMoving = nil
  root:StopMovingOrSizing()
  root:SetScript("OnDragStart", nil)
  root:SetScript("OnDragStop", nil) -- Necessary to prevent OnDragStop firing twice (second time is when hiden in relayout)
  root:SetScript("OnUpdate", nil)
  local details = root.details
  if details.kind == "group" then
    details = details.entries[1]
    self:InsertRootAt(root)
    local parent = self:GetForDetails(details, self.root)
    self.selection = {parent and parent:GetParent().details or details}
    self:UpdateSelection()
    addonTable.CallbackRegistry:TriggerEvent("Designer.Options", self.selection)
  else
    self:InsertRootAt(root)
  end
end

function addonTable.Designer.LayoutManagerMixin:StackElements(root, new)
  local parentDetails = root:GetParent().details
  if parentDetails.kind == "stack" then
    table.insert(parentDetails.entries, new)
  else
    local stack = CopyTable(addonTable.Designer.Defaults.Stack)
    table.insert(stack.entries, root.details)
    table.insert(stack.entries, new)

    local index = tIndexOf(parentDetails.entries, root.details)
    parentDetails.entries[index] = stack
    Announce()
    addonTable.CallbackRegistry:TriggerEvent("Designer.Options", {new})
  end
end

function addonTable.Designer.LayoutManagerMixin:AddEntryToInsert(rootDescription, origin, inserter, noGroups)
  local ability = rootDescription:CreateButton(addonTable.Locales.ABILITY)
  ability:CreateButton(addonTable.Locales.ICON, function()
    self.abilityFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.AbilityIcon)
      new.resource.spellID = data
      if origin.kind == "icon" and origin.resource.kind == "ability" then
        ImportStyle(new, origin)
      end
      inserter(new)
    end)
  end)
  ability:CreateButton(addonTable.Locales.BAR, function()
    self.abilityFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.AbilityBar)
      new.resource.spellID = data
      if origin.kind == "bar" and origin.resource.kind == "ability" then
        ImportStyle(new, origin)
      end
      inserter(new)
    end)
  end)
  ability:CreateButton(addonTable.Locales.CHARGES, function()
    self.abilityChargesFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.AbilityCharges)
      for _, entry in ipairs(new.entries) do
        entry.resource.spellID = data
      end
      inserter(new)
    end)
  end)
  local aura = rootDescription:CreateButton(addonTable.Locales.AURA)
  aura:CreateButton(addonTable.Locales.ICON, function()
    self.auraFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.AuraIcon)
      new.resource.spellID = data
      if origin.kind == "icon" and origin.resource.kind == "aura" then
        ImportStyle(new, origin)
      end
      inserter(new)
    end)
  end)
  aura:CreateButton(addonTable.Locales.ICON_WHEN_MISSING, function()
    self.auraFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.AuraMissingIcon)
      new.resource.spellID = data
      if origin.kind == "icon" and origin.resource.kind == "auraMissing" then
        ImportStyle(new, origin)
      end
      inserter(new)
    end, true)
  end)
  aura:CreateButton(addonTable.Locales.BAR, function()
    self.auraFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.AuraBar)
      new.resource.spellID = data
      if origin.kind == "bar" and origin.resource.kind == "aura" then
        ImportStyle(new, origin)
      end
      inserter(new)
    end)
  end)
  aura:CreateButton(addonTable.Locales.STACKS_PIPS, function()
    self.auraFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.AuraStackPips)
      for _, entry in ipairs(new.entries) do
        entry.resource.spellID = data
      end
      inserter(new)
    end, true)
  end)
  aura:CreateButton(addonTable.Locales.POTION_EFFECT, function()
    self.potionFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.AuraIcon)
      new.resource.spellID = data
      if origin.kind == "icon" and origin.resource.kind == "aura" then
        ImportStyle(new, origin)
      end
      inserter(new)
    end)
  end)
  rootDescription:CreateButton(addonTable.Locales.ITEM, function()
    self.itemFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.ItemIcon)
      new.resource.itemID = data
      if origin.kind == "icon" and origin.resource.kind == "item" then
        ImportStyle(new, origin)
      end
      inserter(new)
    end)
  end)
  rootDescription:CreateButton(addonTable.Locales.EQUIPMENT, function()
    self.equipmentFrame:Update(function(data)
      local new = CopyTable(addonTable.Designer.Defaults.EquipmentIcon)
      new.resource.equipmentSlot = data
      if origin.kind == "icon" and origin.resource.kind == "equipment" then
        ImportStyle(new, origin)
      end
      inserter(new)
    end)
  end)
  rootDescription:CreateButton(addonTable.Locales.CAST_BAR, function()
    local new = CopyTable(addonTable.Designer.Defaults.CastBar)
    addonTable.Core.SavePreset(new.preset, new, false)
    addonTable.Core.ApplyPresetToDetails(new)
    inserter(new)
  end)
  rootDescription:CreateButton(addonTable.Locales.SPACER, function()
    local new = CopyTable(addonTable.Designer.Defaults.Spacer)
    inserter(new)
  end)
  if not noGroups then
    local resources = addonTable.Designer.GetAvailableClassResources()
    if #resources > 0 then
      local class = rootDescription:CreateButton(addonTable.Locales.CLASS)
      for _, r in ipairs(resources) do
        if addonTable.Designer.Defaults.ClassResource[r] then
          class:CreateButton(addonTable.Constants.BarClassResourceLabelMap[r], function()
            inserter(CopyTable(addonTable.Designer.Defaults.ClassResource[r]))
          end)
        end
      end
    end
  end
end

function addonTable.Designer.LayoutManagerMixin:MarkSelected(details)
  local index = tIndexOf(self.selection, details)
  if index then
    if IsShiftKeyDown() then
      table.remove(self.selection, index)
    else
      self.selection = {}
    end
    addonTable.CallbackRegistry:TriggerEvent("Designer.Options", self.selection)
  elseif IsShiftKeyDown() then
    local current = self.selection[1]
    if not current or current.kind == details.kind and (
      not details.resource or
      (current.resource.kind == "class" and tCompare(details.resource, current.resource)) or
      (current.resource.kind == "aura" and details.resource.kind == current.resource.kind) or
      (current.resource.kind == "auraMissing" and details.resource.kind == current.resource.kind) or
      (current.resource.kind == "ability" and details.resource.kind == current.resource.kind) or
      (current.resource.kind == "abilityCharge" and details.resource.kind == current.resource.kind) or
      (current.resource.kind == "auraStackPip" and details.resource.kind == current.resource.kind and details.resource.spellID == current.resource.spellID)
    ) then
      table.insert(self.selection, details)
      addonTable.CallbackRegistry:TriggerEvent("Designer.Options", self.selection)
    else
      UIErrorsFrame:AddMessage(addonTable.Locales.INCOMPATIBLE_WIDGET_TYPE, 1.0, 0.1, 0.1, 1.0)
    end
  else
    self.selection = {details}
    addonTable.CallbackRegistry:TriggerEvent("Designer.Options", self.selection)
  end
  self:UpdateSelection()
end

function addonTable.Designer.LayoutManagerMixin:GetForDetails(details, root)
  if root.details == details then
    return root
  elseif root.details.kind == "group" or root.details.kind == "stack" then
    for _, e in ipairs(root.children) do
      local result = self:GetForDetails(details, e)
      if result then
        return result
      end
    end
  end
end

function addonTable.Designer.LayoutManagerMixin:UpdateSelectionJustOne()
  local frame = self:GetForDetails(self.selection[1], self.root)
  if not frame then
    self.selection = {}
    return
  end
  local selector = self.selectorPool:Acquire()
  selector:Show()
  selector:SetFrameLevel(9999)
  selector:SetAllPoints(frame)
  if IsShiftKeyDown() then
    return
  end
  local details = self.selection[1]
  local parentDetails = frame:GetParent() ~= UIParent and frame:GetParent().details
  for index, button in ipairs(self.insertButton) do
    button:ClearAllPoints()
    button:Show()
    button:SetScript("OnClick", function()
      MenuUtil.CreateContextMenu(frame, function(_, rootDescription)
        self:AddEntryToInsert(rootDescription, details, function(new)
          table.insert(parentDetails.entries, tIndexOf(parentDetails.entries, details) + index - 1, new)
          AutoGroup(self.root.details)
          Announce()
        end)
      end)
    end)
  end
  local insertOffset = details.kind == "group" and 8 or 2
  if parentDetails.layout == "vertical" then
    self.insertButton[1]:SetPoint("TOP", frame, "BOTTOM", 0, -insertOffset)
    self.insertButton[2]:SetPoint("BOTTOM", frame, "TOP", 0, insertOffset)
  elseif parentDetails.layout == "horizontal" then
    self.insertButton[1]:SetPoint("RIGHT", frame, "LEFT", -insertOffset, 0)
    self.insertButton[2]:SetPoint("LEFT", frame, "RIGHT", insertOffset, 0)
  end
  if details.kind == "group" then
    self.dragButton:Show()
    self.dragButton:SetPoint("CENTER", frame)
    self.dragButton:SetScript("OnDragStart", function()
      selector:Hide()
      self:StartMovingRoot(frame)
    end)
    self.dragButton:SetScript("OnDragStop", function()
      selector:Show()
      self:StopMovingRoot(frame)
    end)
    self.dragButton:RegisterForDrag("LeftButton")
    if parentDetails.layout == "standalone" then
      -- Shortcut to center horizontally or vertically
      self.dragButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
      self.dragButton:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
          MenuUtil.CreateContextMenu(UIParent, function(_, rootDescription)
            self:GetAlignmentMenu(frame, rootDescription)
          end)
        end
      end)
    else
      self.dragButton:SetScript("OnClick", nil)
    end
  end
  if parentDetails.layout ~= "standalone" then
    self.selectParentButton:Show()
    self.selectParentButton:SetPoint("BOTTOMRIGHT", frame, "TOPLEFT", -3, 3)
    self.selectParentButton:SetScript("OnClick", function()
      self:MarkSelected(parentDetails)
    end)
  end

  self.deleteButton:Show()
  self.deleteButton:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT", 3, 3)
  self.deleteButton:SetScript("OnClick", function()
    DeleteRoot(frame, true)
    AutoGroup(self.root.details)
    addonTable.CallbackRegistry:TriggerEvent("Designer.Options", {})
    Announce()
  end)
  self.deleteButton:SetScript("OnEnter", function()
    frame:SetAlpha(0.5 * frame.details.alpha)
    GameTooltip:SetOwner(self.deleteButton, "ANCHOR_RIGHT")
    GameTooltip:SetText(addonTable.Locales.DELETE)
  end)
  self.deleteButton:SetScript("OnLeave", function()
    if frame.details == details then
      frame:SetAlpha(frame.details.alpha)
    end
    GameTooltip:Hide()
  end)
end

function addonTable.Designer.LayoutManagerMixin:GetAlignmentMenu(frame, rootDescription)
  local details = frame.details

  if (details.anchor[1] == "TOP" or details.anchor[1] == "BOTTOM") and (details.anchor[4] == nil or details.anchor[4] == 0) then
    rootDescription:CreateTitle(GRAY_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.CENTER_HORIZONTAL))
  else
    rootDescription:CreateButton(addonTable.Locales.CENTER_HORIZONTAL, function()
      if details.anchor[1] == "TOPLEFT" or details.anchor[1] == "TOPRIGHT" or details.anchor[1] == "TOP" then
        details.anchor = {"TOP", "UIParent", "TOP", 0, details.anchor[5]}
      elseif details.anchor[1] == "BOTTOMLEFT" or details.anchor[1] == "BOTTOMRIGHT" or details.anchor[1] == "BOTTOM" then
        details.anchor = {"BOTTOM", "UIParent", "BOTTOM", 0, details.anchor[5]}
      else
        local halfFrameHeight = frame:GetHeight() * frame:GetEffectiveScale() / UIParent:GetScale() / 2
        local offsetY = UIParent:GetHeight() / 2 + details.anchor[5] - halfFrameHeight
        details.anchor = {"BOTTOM", "UIParent", "BOTTOM", 0, offsetY}
      end
      SavePresetAnchor(details)
      Announce()
    end)
  end
  if (details.anchor[1] == "LEFT" or details.anchor[1] == "RIGHT") and (details.anchor[5] == nil or details.anchor[5] == 0) then
    rootDescription:CreateTitle(GRAY_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.CENTER_VERTICAL))
  else
    rootDescription:CreateButton(addonTable.Locales.CENTER_VERTICAL, function()
      if details.anchor[1] == "TOPRIGHT" or details.anchor[1] == "BOTTOMRIGHT" or details.anchor[1] == "RIGHT" then
        details.anchor = {"RIGHT", "UIParent", "RIGHT", details.anchor[4] or 0, 0}
      elseif details.anchor[1] == "TOPLEFT" or details.anchor[1] == "BOTTOMLEFT" or details.anchor[1] == "LEFT" then
        details.anchor = {"LEFT", "UIParent", "LEFT", details.anchor[4], 0}
      else
        local halfFrameWidth = frame:GetWidth() * frame:GetEffectiveScale() / UIParent:GetScale() / 2
        local offsetX = UIParent:GetWidth() / 2 + details.anchor[4] - halfFrameWidth
        details.anchor = {"LEFT", "UIParent", "LEFT", offsetX, 0}
      end
      SavePresetAnchor(details)
      Announce()
    end)
  end

  local anchors = {}
  for key, anchor in pairs(addonTable.Config.Get(addonTable.Config.Options.SAVED_ANCHORS)) do
    table.insert(anchors, {label = key, anchor = anchor})
  end
  table.sort(anchors, function(a, b)
    return a.label < b.label
  end)
  table.insert(anchors, 1, {label = BLUE_FONT_COLOR:WrapTextInColorCode(DEFAULT), anchor = {"BOTTOM", "UIParent", "BOTTOM", 0, 200}})

  rootDescription:CreateDivider()

  for _, info in ipairs(anchors) do
    rootDescription:CreateButton(addonTable.Locales.ALIGN_X:format(info.label), function()
      frame.details.anchor = CopyTable(info.anchor)
      SavePresetAnchor(frame.details)
      Announce()
    end)
  end

  rootDescription:CreateDivider()

  rootDescription:CreateButton(addonTable.Locales.SAVE_ANCHOR, function()
    local anchor = CopyTable(frame.details.anchor)
    addonTable.Dialogs.ShowEditBox(addonTable.Locales.CHOOSE_AN_ANCHOR_NAME, OKAY, CANCEL, function(value)
      if value:match("^%s*$") then
        addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_ANCHOR_NAME)
      else
        addonTable.Config.Get(addonTable.Config.Options.SAVED_ANCHORS)[value] = anchor
      end
    end)
  end)
  rootDescription:CreateButton(addonTable.Locales.RESET_SAVED_ANCHORS, function()
    addonTable.Dialogs.ShowConfirm(addonTable.Locales.ARE_YOU_SURE_CLEAR_ANCHORS, YES, NO, function()
        addonTable.Config.Set(addonTable.Config.Options.SAVED_ANCHORS, {})
    end)
  end)
end

function addonTable.Designer.LayoutManagerMixin:HideSelectedButtons()
  for _, frame in ipairs(self.insertButton) do
    frame:Hide()
  end
  self.selectParentButton:Hide()
  self.deleteButton:Hide()
  self.dragButton:Hide()
end

function addonTable.Designer.LayoutManagerMixin:UpdateSelection()
  self.selectorPool:ReleaseAll()
  self:HideSelectedButtons()
  if #self.selection == 1 then
    self:UpdateSelectionJustOne()
  elseif #self.selection > 1 then
    for i = #self.selection, 1, -1 do
      local details = self.selection[i]
      local frame = self:GetForDetails(details, self.root)
      if not frame then
        table.remove(self.selection, i)
      else
        local selector = self.selectorPool:Acquire()
        selector:Show()
        selector:SetFrameLevel(9999)
        selector:SetAllPoints(frame)
      end
    end
  end
  self.keyboardTrap:SetShown(#self.selection > 0 and not InCombatLockdown())
end

function addonTable.Designer.LayoutManagerMixin:Reanchor(details, value)
  assert(details.anchor)
  local frame = self:GetForDetails(details, self.root)
  assert(frame)
  local _, x, y = addonTable.Designer.ConvertAnchorToCorner(value, frame, UIParent)
  details.anchor[1] = value
  details.anchor[3] = value
  details.anchor[4] = x * details.scale
  details.anchor[5] = y * details.scale
end

function addonTable.Designer.LayoutManagerMixin:ShowBlankAddButton()
  local button = self.insertButton[1]
  button:ClearAllPoints()
  button:SetPoint("CENTER", UIParent)
  button:SetScript("OnClick", function()
    MenuUtil.CreateContextMenu(UIParent, function(_, rootDescription)
      self:AddEntryToInsert(rootDescription, {}, function(new)
        local group = CopyTable(addonTable.Designer.Defaults.Group)
        group.anchor = {"CENTER", "UIParent", "CENTER", 0, 0}
        table.insert(group.entries, new)
        table.insert(self.root.details.entries, group)
        Announce()
      end)
    end)
  end)
  button:Show()
end

function addonTable.Designer.LayoutManagerMixin:OnEvent(eventName)
  if eventName == "MODIFIER_STATE_CHANGED" and #self.selection > 0 then
    if not IsShiftKeyDown() then
      self:UpdateSelection()
    else
      self:HideSelectedButtons()
    end
  end
end

function addonTable.Designer.LayoutManagerMixin:Layout()
  self.pending = true

  self.autoSize = false

  self.currentLayout = addonTable.Designer.GetCurrent()

  self:Delayout()

  self:RegisterEvent("MODIFIER_STATE_CHANGED")

  addonTable.Core.ApplyPresets(self.currentLayout)

  local wrapper = self:GetGroup(self.currentLayout)

  wrapper:SetParent(UIParent)
  wrapper:Show()

  self:ArrangeGroup(wrapper, wrapper.details)

  self.root = wrapper

  if self.root.children[1] then
    CoolinatorPrimaryGroupAnchor:SetAllPoints(self.root.children[1])
  end

  self:UpdateSelection()

  self:AddHandlers(wrapper)

  if not self.currentLayout.entries[1] then -- Fallback for everything being deleted
    self:ShowBlankAddButton()
  end

  self.pending = false
end
