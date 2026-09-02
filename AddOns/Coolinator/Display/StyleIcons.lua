---@class addonTableCoolinator
local addonTable = select(2, ...)

local function SetupText(fontString, details)
  local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
  local text = fontString:GetText()
  fontString:SetText("")
  fontString:SetFontObject(addonTable.CurrentNumberFont)
  if font.flags.slug then
    fontString:SetScale(font.size * details.scale)
    fontString:SetTextScale(1)
    addonTable.Display.ApplyAnchor(fontString, details.anchor, 1/details.scale/font.size)
    fontString:SetWidth(addonTable.Constants.nativeSize * details.widthLimit / details.scale / font.size)
    fontString:SetSmoothScaling(true)
  else
    fontString:SetScale(1)
    fontString:SetTextScale(font.size * details.scale)
    addonTable.Display.ApplyAnchor(fontString, details.anchor, 1)
    fontString:SetWidth(addonTable.Constants.nativeSize * details.widthLimit)
    fontString:SetSmoothScaling(false)
  end
  fontString:SetTextColor(details.color.r, details.color.g, details.color.b)
  local alignment = details.anchor[1] == nil and "CENTER" or details.anchor[1]:match("RIGHT") or details.anchor[1]:match("LEFT") or "CENTER"
  fontString:SetJustifyH(alignment)
  fontString:SetText(text)

  fontString:SetShown(details.visible)
end

local masqueGroup-- Establish a reference to Masque.
addonTable.Utilities.OnAddonLoaded("Masque", function()
  local Masque, _MSQ_Version = LibStub("Masque", true)
  if Masque then
    masqueGroup = Masque:Group("Coolinator", "Icons")
  end
end)

function addonTable.Display.StyleIcon(styleSettings, parent, icon, count, keybinding, maskedTextures, cooldowns)
  local details = parent.details

  if addonTable.State.UsingMasque and parent.Icon == icon and parent.styleSet == "Masque" then
    --masqueGroup:Reskin(icon:GetParent())
    return
  end

  local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
  local styleID = {
    id = styleSettings.id,
    font = font,
    texts = details.texts,
    textsOnly = details.textsOnly,
    showIcon = details.showIcon,
  }
  if parent.styleSet and tCompare(styleID, parent.styleSet, 5) and icon == parent.Icon then
    return
  end
  if icon ~= parent.Icon then
    parent.Icon = icon
  end
  if not parent.border then
    parent.borderWrapper = CreateFrame("Frame", nil, parent)
    parent.borderWrapper:SetAllPoints(parent)
    parent.borderWrapper:SetFrameLevel(parent:GetFrameLevel() + 1)
    parent.border = parent.borderWrapper:CreateTexture()
    parent.border:SetPoint("CENTER")
    parent.Mask = parent:CreateMaskTexture()
  end

  if details.texts then
    for _, c in ipairs(cooldowns) do
      local text = c.widget:GetRegions()
      SetupText(text, details.texts.cooldown)
      c.widget:SetHideCountdownNumbers(not c.text or not details.texts.cooldown.visible)
    end
    if count then
      SetupText(count, details.texts.count)
    end
    if keybinding then
      SetupText(keybinding, details.texts.keybinding)
    end
  end

  parent.Mask:SetAllPoints(icon)

  parent.Icon = icon

  for _, t in ipairs(maskedTextures) do
    if t:GetNumMaskTextures() > 0 then
      for i = t:GetNumMaskTextures(), 1, -1 do
        local m = t:GetMaskTexture(i)
        t:RemoveMaskTexture(m)
      end
    end
  end

  local mask = parent.Mask
  mask:SetBlockingLoadsRequested(true)

  if addonTable.State.UsingMasque then
    parent.styleSet = "Masque"
    parent.GetSize = function()
      return addonTable.Constants.nativeSize - 4, addonTable.Constants.nativeSize - 4
    end
    masqueGroup:AddButton(icon:GetParent(), {
      Icon = icon,
      Normal = parent.border,
      Cooldown = cooldowns[1] and cooldowns[1].widget,
      ChargeCooldown = cooldowns[2] and cooldowns[2].widget,
      Count = count,
      HotKey = keybinding,
    }, #cooldowns == 2 and "Action" or "Aura")
    return
  end

  if styleSettings.id == "square" then
    local asset = addonTable.Assets.IconBorders["Cooli: 1px"]
    mask:SetTexture(asset.mask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetTexelSnappingBias(0)
    parent.border:SetTexture(asset.file)
    parent.border:SetVertexColor(0, 0, 0)
    parent.border:SetTexelSnappingBias(0)
    PixelUtil.SetSize(parent.border, addonTable.Constants.nativeSize - 4, addonTable.Constants.nativeSize - 4)
    for _, c in ipairs(cooldowns) do
      if c.swipe then
        local color = details.swipeColor
        c.widget:SetSwipeColor(color.r, color.g, color.b, color.a)
        c.widget:SetSwipeTexture(asset.mask)
      end
      c.widget:SetReverse(details.reverse)
    end
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    PixelUtil.SetSize(icon, addonTable.Constants.nativeSize - 4, addonTable.Constants.nativeSize - 4)
  else--if styleSettings.id == "blizzard" then
    mask:SetTexture("Interface/AddOns/Coolinator/Assets/IconBorders/blizzard-mask.png", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetTexelSnappingBias(0)
    parent.border:SetTexture("Interface/AddOns/Coolinator/Assets/IconBorders/blizzard.png")
    parent.border:SetVertexColor(0, 0, 0)
    parent.border:SetTexelSnappingBias(0)
    PixelUtil.SetSize(parent.border, 50+5, 50+5)
    for _, c in ipairs(cooldowns) do
      if c.swipe then
        local color = details.swipeColor
        c.widget:SetSwipeColor(color.r, color.g, color.b, color.a)
        c.widget:SetSwipeTexture("Interface/AddOns/Coolinator/Assets/IconBorders/blizzard-mask.png")
      end
      c.widget:SetReverse(details.reverse)
    end
    icon:SetTexCoord(0, 1, 0, 1)
    PixelUtil.SetSize(icon, addonTable.Constants.nativeSize, addonTable.Constants.nativeSize)
  end

  for _, t in ipairs(maskedTextures) do
    t:AddMaskTexture(mask)
  end

  icon:SetShown(details.showIcon)
  parent.border:SetShown(details.showIcon)

  parent.styleSet = CopyTable(styleID)
end
