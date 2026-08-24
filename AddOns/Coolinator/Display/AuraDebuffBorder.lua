---@class addonTableCoolinator
local addonTable = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")

addonTable.Display.AuraDebuffBorderMixin = {}
function addonTable.Display.AuraDebuffBorderMixin:OnLoad()
  self.border = self:CreateTexture(nil, "ARTWORK")
  self.border:SetAllPoints()
end

function addonTable.Display.AuraDebuffBorderMixin:Setup(details)
  local spellID = details.resource.spellID

  if not C_Spell.IsSpellHarmful(spellID) or C_Spell.IsSelfBuff(spellID) then
    self:Hide()
    return
  end
  self:Show()

  if details.style == "square" then
    local asset = addonTable.Assets.IconBorders["Cooli: 1px"]
    self.border:SetTexture(asset.file)
    self.border:SetVertexColor(1, 0, 0)
  else
    self.border:SetAtlas("UI-HUD-CoolDownManager-Debuff-Bleed")
    self.border:SetVertexColor(1, 1, 1)
  end
end
