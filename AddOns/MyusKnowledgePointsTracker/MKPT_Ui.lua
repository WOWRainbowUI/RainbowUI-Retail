local AddonName, MKPT_env, _ = ...

local Utils = MKPT_env.Utils

local f = CreateFrame("Frame", "MKPT_Frame", UIParent, "BackdropTemplate")
MKPT_env.ui = f

function MKPT_env.CreateUI()
  local db = MKPT_env.db

  if not db then return nil end

  local fontSize = db.ui.fontSize
  local position = db.position or { x = 100, y = -100 }
  local backgroundColor = db.ui.backgroundColor
  local insets = db.ui.insets
  local firstTimeLoaded = db.state.firstTimeLoaded
  local scale = db.ui.scale

  f:SetPoint("TOPLEFT", position.x, position.y)
  f:SetWidth(340)
  f:SetScale(scale)

  f:SetMovable(true)
  f:EnableMouse(true)
  f:SetClampedToScreen(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", function()
    f:StopMovingOrSizing()
    local x, y = f:GetLeft(), f:GetTop() - (GetScreenHeight() / f:GetScale())
    db.position = { x = x, y = y }
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", x, y)
    f:SetUserPlaced(true)
  end)
  f:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
      MKPT_env.ShowRightClickMenu()
    end
  end)
  f:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    insets = insets
  })
  f:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)

  f.tree = CreateFrame("Frame", nil, f, "BackdropTemplate")
  f.tree:SetPoint("TOPLEFT", 0, 0)
  f.tree:SetPoint("TOPRIGHT", 0, 0)
  f.tree:SetScript("OnDragStart", f.StartMoving)
  f.tree:SetScript("OnDragStop", function()
    f:StopMovingOrSizing()
    local x, y = f:GetLeft(), -GetScreenHeight() + f:GetTop()
    db.position = { x = x, y = y }
    f:ClearAllPoints()
    f:SetPoint("TOPLEFT", x, y)
    f:SetUserPlaced(true)
  end)

  f.detailText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  f.detailText:SetPoint("TOP", f.tree, "BOTTOM", 0, -4)
  f.detailText:SetWidth(340)
  f.detailText:SetJustifyH("CENTER")
  f.detailText:SetJustifyV("MIDDLE")
  f.detailText:SetFontHeight(fontSize)

  function f:UpdateDetail(text)
    if not text then
      self.detailText:SetText()
      self.detailText:Hide()
      return
    end
    self.detailText:SetText(text)
    self.detailText:Show()
    self:SetHeight(self.tree:GetHeight() + self.detailText:GetHeight() + 4)
  end

  if firstTimeLoaded then
    f:UpdateDetail(
      "點一下物品來追蹤\n"..
      Utils.WeeklyTextColor("每週").." - "..
      Utils.CatchUpTextColor("追趕").." - "..
      Utils.UniqueTextColor("獨特").." - "..
      Utils.MissingTextColor("缺少")
    )
    db.state.firstTimeLoaded = false
  end

  f:RenderTree()
  f:Hide()
  return f
end

local framePool = CreateFramePool(
  "Button",
  f,
  nil,
  function(pool, b)
    b.profession = nil
    b.item = nil
    b:Hide()
    b:ClearAllPoints()
    b.leftText:SetText()
    b.middleText:SetText()
    b.rightText:SetText()
    b.icon:SetTexture()
    b.middleText:SetText()
    b.glow:Hide()
    b:UnregisterAllEvents()
  end,
  false,
  function(b)
    local buttonHeight = MKPT_env.db.ui.rowHeight
    local fontSize = MKPT_env.db.ui.fontSize
    local backgroundColor = MKPT_env.db.ui.rowBackgroundColor

    b:SetHeight(buttonHeight)
    b:SetWidth(340)
    b:SetPropagateMouseClicks(true)

    b.background = b:CreateTexture(nil, "BACKGROUND")
    b.background:SetAllPoints()
    b.background:SetTexture("Interface/BUTTONS/WHITE8X8")
    b.background:SetVertexColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)

    b.icon = b:CreateTexture(nil, "OVERLAY")
    b.icon:SetPoint("LEFT")
    b.icon:SetSize(buttonHeight, buttonHeight)
    b.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.icon:SetAlpha(1)

    b.leftText = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.leftText:SetHeight(buttonHeight)
    b.leftText:SetPoint("LEFT", b.icon, "RIGHT", 4, 0)
    b.leftText:SetJustifyH("LEFT")
    b.leftText:SetJustifyV("MIDDLE")
    b.leftText:SetFontHeight(fontSize)
    b.leftText:SetShadowColor(0, 0, 0, 1)
    b.leftText:SetShadowOffset(2, -2)

    b.middleText = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.middleText:SetPoint("LEFT", b.leftText, "RIGHT")
    b.middleText:SetHeight(buttonHeight)
    b.middleText:SetJustifyH("CENTER")
    b.middleText:SetJustifyV("MIDDLE")
    b.middleText:SetFontHeight(fontSize)
    b.middleText:SetTextColor(1, 1, 1)
    b.middleText:SetShadowColor(0, 0, 0, 1)
    b.middleText:SetShadowOffset(2, -2)

    b.rightText = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.middleText:SetPoint("RIGHT", b.rightText, "LEFT")
    b.rightText:SetHeight(buttonHeight)
    b.rightText:SetPoint("RIGHT", -4, 0)
    b.rightText:SetJustifyH("RIGHT")
    b.rightText:SetJustifyV("MIDDLE")
    b.rightText:SetFontHeight(fontSize)
    b.rightText:SetShadowColor(0, 0, 0, 1)
    b.rightText:SetShadowOffset(2, -2)

    b.highlight = b:CreateTexture(nil, "HIGHLIGHT")
    b.highlight:SetAtlas("Professions_Recipe_Hover", false)
    b.highlight:SetPoint("TOPLEFT", b.icon, "TOPRIGHT", buttonHeight, 0)
    b.highlight:SetPoint("BOTTOMRIGHT")
    b.highlight:SetAlpha(0.7)

    b.glow = b:CreateTexture(nil, "OVERLAY")
    b.glow:SetAtlas("Professions_Recipe_Active", false)
    b.glow:SetPoint("TOPLEFT", b.icon, "TOPRIGHT", buttonHeight, 0)
    b.glow:SetPoint("BOTTOMRIGHT")
    b.glow:SetAlpha(0.7)
    b.glow:Hide()
  end
)

--- Adds a profession row to the list
---@param profession MKPT_Profession
---@return Frame b - rowFrame
local function AddProfessionButton(profession)
  local b = framePool:Acquire()
  b.profession = profession

  local remaining = profession:CalculateRemainingKps()
  b.leftText:SetText(Utils.WeeklyTextColor("W:"..remaining.weekly)..Utils.CatchUpTextColor(" +"..remaining.catchUp))

  local missing = profession:CalculateSpendableKps()
  b.rightText:SetText(Utils.UniqueTextColor("U:"..remaining.unique).." "..Utils.MissingTextColor(missing))

  local middleText = profession.name
  local skillLevel = profession:GetSkillLevel()
  if skillLevel then
    middleText = middleText.." "..skillLevel.skillLevel.."/"..skillLevel.maxSkillLevel.." +"..skillLevel.bonusSkill
  end

  b.icon:SetTexture(profession.icon)
  b.middleText:SetText(middleText)
  b.middleText:SetJustifyH("CENTER")

  b:SetScript("OnClick", function(self)
    local ui = MKPT_env.ui
    local profession = self.profession
    if not ui or not profession then return end

    profession.expanded = not profession.expanded

    ui:RenderTree()
  end)

  b:Show()
  return b
end

--- Adds a profession trainer row to the list
---@param profession MKPT_Profession
---@return Frame b - rowFrame
local function AddProfessionTrainerButton(profession)
  local b = framePool:Acquire()
  b.profession = profession

  b.leftText:SetText(CreateAtlasMarkup("Crosshair_trainer_32"), 16, 16)

  b.rightText:SetText(CreateAtlasMarkup("Waypoint-MapPin-Untracked"), 16, 16)

  local middleText = profession.name
  local skillLevel = profession:GetSkillLevel()
  if skillLevel then
    middleText = middleText.." "..skillLevel.skillLevel.."/"..skillLevel.maxSkillLevel.." +"..skillLevel.bonusSkill
  end

  b.icon:SetTexture(profession.icon)
  b.middleText:SetText(profession.expansionTrainerName)
  b.middleText:SetJustifyH("CENTER")

  if profession:IsHighlighted() then
    b.glow:Show()
  else
    b.glow:Hide()
  end

  b:SetScript("OnClick", function(self)
    local ui = MKPT_env.ui
    local profession = self.profession
    if not ui or not profession then return end

    profession:ToggleTrack()
    if profession:IsHighlighted() then
      ui:UpdateDetail(profession:GetDescription())
    else
      ui:UpdateDetail()
    end

    ui:RenderTree()
  end)

  b:Show()
  return b
end

--- Adds a kp source row to the list
---@param item MKPT_Item
---@return Frame b - rowFrame
local function AddItemButton(item)
  local b = framePool:Acquire()
  b.item = item
  if item:IsHighlighted() then
    b.glow:Show()
  else
    b.glow:Hide()
  end
  b.icon:SetTexture(item:GetIcon())
  b.leftText:SetText(item:GetCategoryIcon())
  b.leftText:SetJustifyV("MIDDLE")

  local name = item:GetFormattedName()
  if not name then
    -- Listen to ITEM_DATA_LOAD_RESULT event if the name isn't ready and updates the frame
    b:SetScript("OnEvent", function(self, event, ...)
      if not event == "ITEM_DATA_LOAD_RESULT" or not self.item then return end
      local name = self.item:GetFormattedName()
      if name then
        self.middleText:SetText(name)
        self:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
      end
    end)
    b:RegisterEvent("ITEM_DATA_LOAD_RESULT")
  end

  b.middleText:SetText(name)
  b.middleText:SetJustifyH("LEFT")
  b.rightText:SetText("+"..item:GetRemainingKnowledgePoints())

  b:SetScript("OnClick", function(self)
    self.item:ToggleTrack()
    local ui = MKPT_env.ui
    if self.item:IsHighlighted() then
      ui:UpdateDetail(self.item:GetDescription())
    else
      ui:UpdateDetail()
    end
    ui:RenderTree()
  end)

  b:Show()
  return b
end

--- Refreshs the entire UI
function f:RenderTree()
  local paddingY = 1
  local contentHeight = paddingY
  local trackedItem = MKPT_env.MKPT_Item.GetTrackedItem()
  if trackedItem and not trackedItem:IsAvailable() then
    trackedItem:Untrack()
    f:UpdateDetail()
  end

  framePool:ReleaseAll()

  local professions = MKPT_env.GetProfessions()
  local professionCount = 0
  for _, profession in pairs(professions) do
    professionCount = professionCount + 1
    local pb
    if profession:IsLearned() then
      pb = AddProfessionButton(profession)
    else
      pb = AddProfessionTrainerButton(profession)
    end
    pb:SetPoint("TOPLEFT", self.tree, "TOPLEFT", 0, -(contentHeight + paddingY))
    contentHeight = contentHeight + paddingY + pb:GetHeight()
    for _, item in pairs(profession:GetAvailableItems()) do
      if item:Show() then
        local b = AddItemButton(item)
        b:SetPoint("TOPLEFT", self.tree, "TOPLEFT", 0, -(contentHeight + paddingY))
        contentHeight = contentHeight + paddingY + b:GetHeight()
      end
    end
  end
  if professionCount == 0 then
    f:UpdateDetail("沒有專業")
  end
  self.tree:SetHeight(contentHeight)
  self:SetHeight(contentHeight + (self.detailText:GetHeight() <= 1 and 1 or self.detailText:GetHeight() + 4))
end

---Show/Hide the UI
function MKPT_env.ToggleUi()
  if f:IsShown() then
    MKPT_env.db.state.show = false
    f:Hide()
  else
    MKPT_env.db.state.show = true
    f:RenderTree()
    f:Show()
  end
end

---Switch between expansions
function MKPT_env.ToggleExpansion()
  if MKPT_env.db.state.expansion == Enum.ExpansionLevel.WarWithin then
    MKPT_env.db.state.expansion = Enum.ExpansionLevel.Midnight
  else
    MKPT_env.db.state.expansion = Enum.ExpansionLevel.WarWithin
  end

  -- Attempt to load skill level from professions of legacy expansions
  local professions = MKPT_env.GetProfessions()
  for _, profession in pairs(professions) do
    if profession:GetSkillLevel() == nil and profession:IsLearned() then
      C_TradeSkillUI.OpenTradeSkill(profession.skillLine)
      C_TradeSkillUI.CloseTradeSkill()
    end
  end
  f:RenderTree()
  if not f:IsShown() then
    MKPT_env.ToggleUi()
  end
end

---Refresh current tracked item info, updating requirements on description such as renown and item in bags count
function MKPT_env.RefreshTrackedItem()
  local trackedItem = MKPT_env.MKPT_Item.GetTrackedItem()
  if trackedItem then
    if trackedItem:IsAvailable() then
      f:UpdateDetail(trackedItem:GetDescription())
    else
      f:UpdateDetail()
    end
  end
end

function MKPT_env.SetUiScale(scale)
  scale = math.max(0.5, math.min(1.5, scale))
  MKPT_env.db.ui.scale = scale
  f:SetScale(scale)
end