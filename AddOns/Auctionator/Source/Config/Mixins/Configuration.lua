AuctionatorConfigFrameMixin = CreateFromMixins(AuctionatorPanelConfigMixin)

function AuctionatorConfigFrameMixin:OnLoad()
  Auctionator.Debug.Message("AuctionatorConfigFrameMixin:OnLoad()")

  self.name = AUCTIONATOR_L_ADDON_OPTIONS
  self:SetParent(SettingsPanel or InterfaceOptionsFrame)

  self:SetupPanel()
end

function AuctionatorConfigFrameMixin:Show()

end

function AuctionatorConfigFrameMixin:Save()
  Auctionator.Debug.Message("AuctionatorConfigFrameMixin:Save()")
end

function AuctionatorConfigFrameMixin:Cancel()
  Auctionator.Debug.Message("AuctionatorConfigFrameMixin:Cancel()")
end
