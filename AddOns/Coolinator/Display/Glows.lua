---@class addonTableCoolinator
local addonTable = select(2, ...)

---@type Frame
addonTable.Display.GlowMixin = {}

function addonTable.Display.GlowMixin:OnLoad()
  self.animationGroup = self:CreateAnimationGroup()
  self.animationGroup:SetLooping("REPEAT")

  self.texture = self:CreateTexture()
  self.texture:SetPoint("CENTER")

  self.animation = self.animationGroup:CreateAnimation("FlipBook")
  self.animation:SetTarget(self.texture)

  self.isReverse = false
end

function addonTable.Display.GlowMixin:OnShow()
  if not self.animationGroup:IsPlaying() then
    self.animationGroup:Play(self.isReverse)
  end
end

function addonTable.Display.GlowMixin:SetAsset(assetName, color, reverse)
  local asset = addonTable.Assets.IconBorderAnimations[assetName]
  self.animationGroup:SetLooping(asset.loop and "REPEAT" or "NONE")
  self.texture:SetTexture(asset.file)
  self.texture:SetSnapToPixelGrid(0)
  self.texture:SetVertexColor(color.r, color.g, color.b)
  PixelUtil.SetSize(self.texture, asset.width, asset.height)
  if asset.duration > 0 then
    self.animation:SetTarget(self.texture)
    self.animation:SetFlipBookColumns(asset.columns)
    self.animation:SetFlipBookRows(asset.rows)
    self.animation:SetDuration(asset.duration)
  else
    self.animation:Stop()
    self.animation:SetFlipBookColumns(1)
    self.animation:SetFlipBookRows(1)
    self.animation:SetDuration(0)
  end

  self.isReverse = reverse
  self.animationGroup:Play(reverse)

  if not asset.loop then
    self:SetScript("OnShow", self.OnShow)
  end
end
