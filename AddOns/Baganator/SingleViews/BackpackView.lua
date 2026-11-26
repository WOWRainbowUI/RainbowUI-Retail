---@class addonTableBaganator
local addonTable = select(2, ...)

BaganatorSingleViewBackpackViewMixin = CreateFromMixins(BaganatorItemViewCommonBackpackViewMixin)

function BaganatorSingleViewBackpackViewMixin:OnLoad()
  BaganatorItemViewCommonBackpackViewMixin.OnLoad(self)

  if addonTable.Constants.IsGamepadInUse then
    local bindings = {
      {
        button = GAMEPAD_FACE_BOTTOM, label = ACTION_LABEL_SELECT, visibility = "auto",
        condition = function()
          return addonTable.ItemButtonUtil.GetGamepadFocus() ~= nil
        end,
      },
      {
        button = GAMEPAD_FACE_LEFT, label = CONTEXT_ACTION_LABEL_USE, visibility = "auto",
        condition = function()
          return addonTable.ItemButtonUtil.GetGamepadFocus() ~= nil and addonTable.ItemButtonUtil.GetGamepadFocus().frame.BGR.itemLink ~= nil
        end,
      },
      {
        button = GAMEPAD_FACE_TOP, label = CONTEXT_ACTION_LABEL_MORE_ACTIONS, visibility = "auto",
        condition = function()
          return addonTable.ItemButtonUtil.GetGamepadFocus() ~= nil and addonTable.ItemButtonUtil.GetGamepadFocus().frame.BGR.itemLink ~= nil
        end
      },
      {
        isBack = true, label = CLOSE
      }
    }
    self.gamepadFooter = addonTable.Gamepad.GetBindingsFooter(bindings, self)
  end

  self.Container.BagLive:SetPool(self.liveItemButtonPool)
  self.CollapsingBagSectionsPool = addonTable.SingleViews.GetCollapsingBagSectionsPool(self.Container)
  self.CollapsingBags = {}
  self.bagDetailsForComparison = {}

  addonTable.CallbackRegistry:RegisterCallback("SpecialBagToggled", function(_, character)
    self.refreshState[addonTable.Constants.RefreshReason.Layout] = true
    if self:IsVisible() and self.lastCharacter ~= nil then
      self:UpdateForCharacter(self.lastCharacter, self.isLive)
    end
  end)

  addonTable.AddBagTransferActivationCallback(function()
    self.ButtonsManager:Arrange()
  end)
end

function BaganatorSingleViewBackpackViewMixin:AllocateBags(character)
  local newDetails = addonTable.SingleViews.GetCollapsingBagDetails(character, "bags", Syndicator.Constants.AllBagIndexes, Syndicator.Constants.BagSlotsCount)
  if self.bagDetailsForComparison.bags == nil or not tCompare(self.bagDetailsForComparison.bags, newDetails, 15) then
    self.bagDetailsForComparison.bags = CopyTable(newDetails)
    self.CollapsingBags = addonTable.SingleViews.AllocateCollapsingSections(
      character, "bags", Syndicator.Constants.AllBagIndexes,
      newDetails, self.CollapsingBags,
      self.CollapsingBagSectionsPool, self.liveItemButtonPool)
    self.lastBagDetails = newDetails
  end
end

function BaganatorSingleViewBackpackViewMixin:ApplySearch(text)
  if not self:IsVisible() then
    return
  end
  self.searchToApply = false

  if self.isLive then
    self.Container.BagLive:ApplySearch(text)
    for _, bagGroup in ipairs(self.CollapsingBags) do
      bagGroup.live:ApplySearch(text)
    end
  else
    self.Container.BagCached:ApplySearch(text)
    for _, bagGroup in ipairs(self.CollapsingBags) do
      bagGroup.cached:ApplySearch(text)
    end
  end
end

function BaganatorSingleViewBackpackViewMixin:NotifyBagUpdate(updatedBags)
  self.Container.BagLive:MarkBagsPending("bags", updatedBags)
  for _, bagGroup in ipairs(self.CollapsingBags) do
    bagGroup.live:MarkBagsPending("bags", updatedBags)
  end

  -- Update cached views with current items when live or on login
  if self.isLive == nil or self.isLive == true then
    self.Container.BagCached:MarkBagsPending("bags", updatedBags)
    for _, bagGroup in ipairs(self.CollapsingBags) do
      bagGroup.cached:MarkBagsPending("bags", updatedBags)
    end
  end
end

function BaganatorSingleViewBackpackViewMixin:UpdateForCharacter(character, isLive)
  local start = debugprofilestop()
  BaganatorItemViewCommonBackpackViewMixin.UpdateForCharacter(self, character, isLive)

  if self.isLive then
    addonTable.NewItems:ImportNewItems()
  end

  if self.refreshState[addonTable.Constants.RefreshReason.ItemData] then
    self:AllocateBags(character)
  end

  self.Container.BagLive:SetShown(isLive)
  self.Container.BagCached:SetShown(not isLive)

  local searchText = self.SearchWidget.SearchBox:GetText()

  local activeBag, activeBagCollapsibles = nil, {}

  if self.Container.BagLive:IsShown() then
    activeBag = self.Container.BagLive
    for _, layouts in ipairs(self.CollapsingBags) do
      table.insert(activeBagCollapsibles, layouts.live)
    end
  else
    activeBag = self.Container.BagCached
    for _, layouts in ipairs(self.CollapsingBags) do
      table.insert(activeBagCollapsibles, layouts.cached)
    end
  end

  if self.refreshState[addonTable.Constants.RefreshReason.ItemData] or self.refreshState[addonTable.Constants.RefreshReason.ItemWidgets] or self.refreshState[addonTable.Constants.RefreshReason.ItemTextures] or self.refreshState[addonTable.Constants.RefreshReason.Flow] or self.refreshState[addonTable.Constants.RefreshReason.Layout] then
    local bagWidth = addonTable.Config.Get(addonTable.Config.Options.BAG_VIEW_WIDTH)
    local characterData = Syndicator.API.GetCharacter(character) 
    local bagData = characterData and characterData.bags
    activeBag:ShowBags(bagData, character, Syndicator.Constants.AllBagIndexes, self.lastBagDetails.mainIndexesToUse, bagWidth)

    for index, layout in ipairs(activeBagCollapsibles) do
      layout:ShowBags(bagData, character, Syndicator.Constants.AllBagIndexes, self.CollapsingBags[index].indexesToUse, bagWidth)
    end
  end

  if self.searchToApply then
    self:ApplySearch(searchText)
  end

  if self.refreshState[addonTable.Constants.RefreshReason.ItemData] or self.refreshState[addonTable.Constants.RefreshReason.Layout] then
    self.bagHeight = activeBag:GetHeight()
    self.bagHeight = self.bagHeight + addonTable.SingleViews.ArrangeCollapsibles(activeBagCollapsibles, activeBag, self.CollapsingBags)

    for _, layouts in ipairs(self.CollapsingBags) do
      layouts.live:SetShown(isLive and layouts.live:IsShown())
      layouts.cached:SetShown(not isLive and layouts.cached:IsShown())
    end

    activeBag:SetPoint("TOPRIGHT")

    self.Container:SetSize(
      activeBag:GetWidth(),
      self.bagHeight
    )
  end

  if self.SearchWidget:IsShown() then
    self.ButtonsManager:SetGamepadDown(self.SearchWidget.SearchBox)
  else
    self.ButtonsManager:SetGamepadDown(activeBag.buttons[1])
  end

  self:OnFinished()

  if self.refreshState[addonTable.Constants.RefreshReason.Buttons] or self.refreshState[addonTable.Constants.RefreshReason.Layout] then
    self.SearchWidget:LinkDown(activeBag.buttons[1])

    local bottomButtons = {self.CurrencyButton}

    self.ButtonsManager:ClearButtons(true)

    local lastButton = self.CurrencyButton
    lastButton:SetPoint("BOTTOM", self, "BOTTOM", 0, 6)
    lastButton:SetPoint("LEFT", self.Container, -2, 0)
    self.ButtonsManager:AddButton(self.CurrencyButton)

    self.buttonsWidth = lastButton:GetWidth()

    for index, layout in ipairs(activeBagCollapsibles) do
      local button = self.CollapsingBags[index].button
      button:SetParent(self)
      button:SetShown(layout:GetHeight() > 0)
      button:ClearAllPoints()
      if button:IsShown() then
        table.insert(bottomButtons, button)
        self.buttonsWidth = self.buttonsWidth + 5 + button:GetWidth()
        button:SetPoint("LEFT", lastButton, "RIGHT", 5, 0)
        lastButton = button
        self.ButtonsManager:AddButton(button)
      end
    end

    self.buttonsWidth = self.buttonsWidth + addonTable.Utilities.AddButtons(
      lastButton, self, 5, addonTable.API.customRegions["backpack"]["bottom_left"]
    )

    local all = {activeBag}
    tAppendAll(all, activeBagCollapsibles)
    addonTable.SingleViews.ComputeGamepadGrid(all, self.SearchWidget.SearchBox, bottomButtons, function(b)
      self.CurrencyWidget:AddGamepadUp(b)
    end)
    self.CurrencyWidget:AddGamepadLeft(bottomButtons[#bottomButtons])
  end

  -- Necessary extra call as collapsing bag region buttons get updated
  -- out-of-sync with everything else
  self.ButtonsManager:Arrange()

  if self.refreshState[addonTable.Constants.RefreshReason.Layout] then
    self.CurrencyWidget:UpdateCurrencyTextPositions(self.Container:GetWidth() - self.buttonsWidth - 10, self.Container:GetWidth())
  end

  if self.showing then
    C_Timer.After(0, function()
      addonTable.Gamepad.SetTargetButton(self, activeBag.buttons[1])
    end)
    self.showing = false
  end

  addonTable.CallbackRegistry:TriggerEvent("ViewComplete")

  if addonTable.Config.Get(addonTable.Config.Options.DEBUG_TIMERS) then
    addonTable.Utilities.DebugOutput("-- updateforcharacter backpack", debugprofilestop() - start)
  end

  self.refreshState = {}
end

function BaganatorSingleViewBackpackViewMixin:GetSearchMatches()
  local matches = {}
  tAppendAll(matches, self.Container.BagLive.SearchMonitor:GetMatches())
  for _, layouts in ipairs(self.CollapsingBags) do
    tAppendAll(matches, layouts.live.SearchMonitor:GetMatches())
  end
  return matches
end

if table.freeze then
  table.freeze(BaganatorSingleViewBackpackViewMixin)
end
