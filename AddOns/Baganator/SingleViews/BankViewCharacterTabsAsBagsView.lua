---@class addonTableBaganator
local addonTable = select(2, ...)
BaganatorSingleViewBankViewCharacterTabsAsBagsViewMixin = CreateFromMixins(BaganatorItemViewCommonBankViewCharacterTabsAsBagsViewMixin)

function BaganatorSingleViewBankViewCharacterTabsAsBagsViewMixin:OnLoad()
  BaganatorItemViewCommonBankViewCharacterTabsAsBagsViewMixin.OnLoad(self)

  self.unallocatedItemButtonPool = addonTable.ItemViewCommon.GetLiveItemButtonPool(self.Container)
  self.CollapsingBagSectionsPool = addonTable.SingleViews.GetCollapsingBagSectionsPool(self.Container)
  self.CollapsingBankBags = {}
  self.bagDetailsForComparison = {}

  addonTable.CallbackRegistry:RegisterCallback("SpecialBagToggled", function(_, character)
    self.refreshState[addonTable.Constants.RefreshReason.Layout] = true
    if self:IsVisible() and self.lastCharacter ~= nil then
      self:GetParent():UpdateView()
    end
  end)
end

function BaganatorSingleViewBankViewCharacterTabsAsBagsViewMixin:ApplySearch(text)
  if not self:IsVisible() then
    return
  end

  if self.Container.BankLive:IsShown() then
    self.Container.BankLive:ApplySearch(text)
    for _, layouts in ipairs(self.CollapsingBankBags) do
      layouts.live:ApplySearch(text)
    end
  elseif self.Container.BankCached:IsShown() then
    self.Container.BankCached:ApplySearch(text)
    for _, layouts in ipairs(self.CollapsingBankBags) do
      layouts.cached:ApplySearch(text)
    end
  end
end

function BaganatorSingleViewBankViewCharacterTabsAsBagsViewMixin:AllocateBankBags(character)
  -- Copied from SingleViews/BagView.lua
  local newDetails = addonTable.SingleViews.GetCollapsingBagDetails(character, "characterBank", Syndicator.Constants.AllBankIndexes, #Syndicator.Constants.AllBankIndexes, 0)
  if self.bagDetailsForComparison.characterBank == nil or not tCompare(self.bagDetailsForComparison.characterBank, newDetails, 15) then
    self.bagDetailsForComparison.characterBank = CopyTable(newDetails)
    self.CollapsingBankBags = addonTable.SingleViews.AllocateCollapsingSections(
      character, "characterBank", Syndicator.Constants.AllBankIndexes,
      newDetails, self.CollapsingBankBags,
      self.CollapsingBagSectionsPool, self.unallocatedItemButtonPool,
      function() self:GetParent():UpdateView() end
    )
    self.lastBankBagDetails = newDetails
  end
end

function BaganatorSingleViewBankViewCharacterTabsAsBagsViewMixin:GetSearchMatches()
  local matches = {}
  tAppendAll(matches, self.Container.BankLive.SearchMonitor:GetMatches())
  for _, layouts in ipairs(self.CollapsingBankBags) do
    tAppendAll(matches, layouts.live.SearchMonitor:GetMatches())
  end
  return matches
end

function BaganatorSingleViewBankViewCharacterTabsAsBagsViewMixin:NotifyBagUpdate(updatedBags)
  self.Container.BankLive:MarkBagsPending("bank", updatedBags)

  for _, bagGroup in ipairs(self.CollapsingBankBags) do
    bagGroup.live:MarkBagsPending("bank", updatedBags)
  end

  -- Update cached views with current items when bank closed or on login
  if self.isLive == nil or self.isLive == true then
    for _, bagGroup in ipairs(self.CollapsingBankBags) do
      bagGroup.cached:MarkBagsPending("bank", updatedBags)
    end
    self.Container.BankCached:MarkBagsPending("bank", updatedBags)
  end
end

function BaganatorSingleViewBankViewCharacterTabsAsBagsViewMixin:ShowTab(character, isLive)
  BaganatorItemViewCommonBankViewCharacterTabsAsBagsViewMixin.ShowTab(self, character, isLive)

  if self.BankMissingHint:IsShown() then
    for _, details in ipairs(self.CollapsingBankBags) do
      details.button:Hide()
    end
    return
  end

  if self.refreshState[addonTable.Constants.RefreshReason.ItemData] then
    self:AllocateBankBags(character)
  end

  self.Container.BankLive:SetShown(self.isLive)
  self.Container.BankCached:SetShown(not self.isLive)

  for _, layouts in ipairs(self.CollapsingBankBags) do
    layouts.live:SetShown(self.isLive)
    layouts.cached:SetShown(not self.isLive)
  end

  local activeBank, activeBankBagCollapsibles = nil, {}

  if self.Container.BankLive:IsShown() then
    activeBank = self.Container.BankLive
    for _, layouts in ipairs(self.CollapsingBankBags) do
      table.insert(activeBankBagCollapsibles, layouts.live)
    end
  else
    activeBank = self.Container.BankCached
    for _, layouts in ipairs(self.CollapsingBankBags) do
      table.insert(activeBankBagCollapsibles, layouts.cached)
    end
  end

  local bankWidth = addonTable.Config.Get(addonTable.Config.Options.BANK_VIEW_WIDTH)

  local refresh = self.refreshState[addonTable.Constants.RefreshReason.ItemData] or self.refreshState[addonTable.Constants.RefreshReason.ItemWidgets] or self.refreshState[addonTable.Constants.RefreshReason.ItemTextures] or self.refreshState[addonTable.Constants.RefreshReason.Flow] or self.refreshState[addonTable.Constants.RefreshReason.Layout]

  if refresh then
    local characterData = Syndicator.API.GetCharacter(self.lastCharacter)
    local bagData = {}
    for _, tab in ipairs(characterData.bankTabs) do
      table.insert(bagData, tab.slots)
    end

    activeBank:ShowBags(bagData, character, Syndicator.Constants.AllBankIndexes, self.lastBankBagDetails.mainIndexesToUse, bankWidth)

    for index, layout in ipairs(activeBankBagCollapsibles) do
      layout:ShowBags(bagData, character, Syndicator.Constants.AllBankIndexes, self.CollapsingBankBags[index].indexesToUse, bankWidth)
    end
  end

  self.searchToApply = self.searchToApply or refresh
  if self.searchToApply then
    local searchText = self:GetParent().SearchWidget.SearchBox:GetText()
    self:ApplySearch(searchText)
  end

  if self.refreshState[addonTable.Constants.RefreshReason.Layout] then
    self.bankHeight = activeBank:GetHeight()

    -- Copied from SingleViews/BagView.lua
    self.bankHeight = self.bankHeight + addonTable.SingleViews.ArrangeCollapsibles(activeBankBagCollapsibles, activeBank, self.CollapsingBankBags)

    self.buttonsWidth = 0
    local lastButton = nil
    local allButtons = {}
    for index, layout in ipairs(activeBankBagCollapsibles) do
      local button = self.CollapsingBankBags[index].button
      button:SetParent(self)
      button:SetShown(layout:GetHeight() > 0)
      if button:IsShown() then
        self.buttonsWidth = button:GetWidth() + 5
        button:ClearAllPoints()
        if lastButton then
          button:SetPoint("LEFT", lastButton, "RIGHT", 5, 0)
        else
          button:SetPoint("BOTTOM", self, "BOTTOM", 0, 6)
          button:SetPoint("LEFT", self.Container, -2, 0)
        end
        self:GetParent().ButtonsManager:AddButton(button)
        table.insert(allButtons, button)
        lastButton = button
      end
    end

    self:GetParent().SearchWidget:LinkDown(activeBank.buttons[1])
    if lastButton then
      addonTable.Gamepad.LinkButtons(lastButton, "Right", self.DepositReagentsButton)
      self.DepositReagentsButton:SetPoint("LEFT", lastButton, "RIGHT", 5, 0)
    else
      addonTable.Gamepad.ResetAssociations(self.DepositReagentsButton)
      self.DepositReagentsButton:SetPoint("BOTTOM", self, "BOTTOM", 0, 6)
      self.DepositReagentsButton:SetPoint("LEFT", self.Container, -2, 0)
    end
    table.insert(allButtons, self.DepositReagentsButton)

    if self.isLive then
      self.CurrencyWidget:AddGamepadLeft(self.DepositReagentsButton)
    elseif lastButton then
      self.CurrencyWidget:AddGamepadLeft(lastButton)
    end

    if self:GetParent().SearchWidget:IsShown() then
      self:GetParent().ButtonsManager:SetGamepadDown(self:GetParent().SearchWidget.SearchBox)
    else
      self:GetParent().ButtonsManager:SetGamepadDown(activeBank.buttons[1])
    end

    local all = {activeBank}
    tAppendAll(all, activeBankBagCollapsibles)
    addonTable.SingleViews.ComputeGamepadGrid(all,
      self:GetParent().SearchWidget:IsVisible() and self:GetParent().SearchWidget.SearchBox or self:GetParent().ButtonsManager.active.topLeft[1] or self:GetParent().ButtonsManager.active.topRight[1],
      allButtons, function(b)
      self.CurrencyWidget:AddGamepadUp(b)
    end)

    activeBank:ClearAllPoints()
    activeBank:SetPoint("TOPLEFT", 0, 0)
  end

  addonTable.CallbackRegistry:TriggerEvent("ViewComplete")

  self.Container:SetSize(activeBank:GetWidth(), self.bankHeight)

  self:OnFinished()

  if self.refreshState[addonTable.Constants.RefreshReason.Layout] then
    self.CurrencyWidget:UpdateCurrencyTextPositions(self.Container:GetWidth() - self.buttonsWidth - 5, self.Container:GetWidth())
  end

  if self.showing then
    C_Timer.After(0, function()
      addonTable.Gamepad.SetTargetButton(self, activeBank.buttons[1])
    end)
    self.showing = false
  end

  self:GetParent():OnTabFinished()
end

if table.freeze then
  table.freeze(BaganatorSingleViewBankViewCharacterTabsAsBagsViewMixin)
end
