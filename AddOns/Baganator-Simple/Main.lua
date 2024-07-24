local function ConvertTags(tags)
  local res = {}
  for _, tag in ipairs(tags) do
    res[tag] = true
  end
  return res
end

local backdropInfo = {
  bgFile = "Interface/AddOns/Baganator-Simple/Assets/minimalist-backgroundfile",
  edgeFile = "Interface/AddOns/Baganator-Simple/Assets/minimalist-edgefile",
  tile = true,
  tileEdge = true,
  tileSize = 32,
  edgeSize = 6,
}

local frameBackdropInfo = {
  bgFile = "Interface/AddOns/Baganator-Simple/Assets/minimalist-backgroundfile",
  edgeFile = "Interface/AddOns/Baganator-Simple/Assets/minimalist-edgefile",
  tile = true,
  tileEdge = true,
  tileSize = 32,
  edgeSize = 9,
}

--local color = CreateColor(65/255, 137/255, 64/255) -- green
--local color = CreateColor(65/255, 138/255, 180/255) -- blue
local color = CreateColor(0.05, 0.05, 0.05) -- black

local toColor = {
  backdrops = {},
  textures = {},
}

local possibleVisuals = {
  "BotLeftCorner", "BotRightCorner", "BottomBorder", "LeftBorder", "RightBorder",
  "TopRightCorner", "TopLeftCorner", "TopBorder", "TitleBg", "Bg",
  "TopTileStreaks",
}
local function RemoveFrameTextures(frame)
  for _, key in ipairs(possibleVisuals) do
    if frame[key] then
      frame[key]:Hide()
      frame[key]:SetTexture()
    end
  end
  if frame.NineSlice then
    for _, region in ipairs({frame.NineSlice:GetRegions()}) do
      region:Hide()
    end
  end
end

local texCoords = {0.08, 0.92, 0.08, 0.92}
local function ItemButtonQualityHook(frame, quality)
  if frame.bgrSimpleHooked then
    frame.IconBorder:SetTexture("Interface/AddOns/Baganator-Simple/Assets/minimalist-icon-border")
    frame:ClearNormalTexture()
    local c = ITEM_QUALITY_COLORS[quality]
    if c then
      frame.IconBorder:SetVertexColor(c.r, c.g, c.b)
      frame.IconBorder:Show()
    end
  end
end
local function ItemButtonTextureHook(frame)
  if frame.bgrSimpleHooked then
    frame.icon:SetTexCoord(unpack(texCoords))
  end
end

local function StyleButton(button)
  button.Left:Hide()
  button.Right:Hide()
  button.Middle:Hide()
  button:ClearHighlightTexture()

  Mixin(button, BackdropTemplateMixin)
  button:SetBackdrop(backdropInfo)
  local color = CreateColor(Baganator_Simple_Lighten(color.r, color.g, color.b, -0.20))
  button:SetBackdropColor(color.r, color.g, color.b, 0.5)
  button:SetBackdropBorderColor(color.r, color.g, color.b, 1)
  table.insert(toColor.backdrops, {backdrop = button, bgAlpha = 0.5, borderAlpha = 1, lightened = -0.20})
  button:HookScript("OnEnter", function()
    if button:IsEnabled() then
      local r, g, b = Baganator_Simple_Lighten(color.r, color.g, color.b, 0.3)
      button:SetBackdropColor(r, g, b, 0.8)
      button:SetBackdropBorderColor(r, g, b, 1)
    end
  end)
  button:HookScript("OnMouseDown", function()
    if button:IsEnabled() then
      local r, g, b = Baganator_Simple_Lighten(color.r, color.g, color.b, 0.2)
      button:SetBackdropColor(r, g, b, 0.8)
      button:SetBackdropBorderColor(r, g, b, 1)
    end
  end)
  button:HookScript("OnMouseUp", function()
    if button:IsEnabled() and button:IsMouseOver() then
      local r, g, b = Baganator_Simple_Lighten(color.r, color.g, color.b, 0.3)
      button:SetBackdropColor(r, g, b, 0.8)
      button:SetBackdropBorderColor(r, g, b, 1)
    end
  end)
  button:HookScript("OnLeave", function()
    button:SetBackdropColor(color.r, color.g, color.b, 0.5)
    button:SetBackdropBorderColor(color.r, color.g, color.b, 1)
  end)
  button:HookScript("OnDisable", function()
    button:SetBackdropColor(color.r, color.g, color.b, 0.1)
  end)
  button:HookScript("OnEnable", function()
    button:SetBackdropColor(color.r, color.g, color.b, 0.5)
  end)
end

local skinners = {
  ItemButton = function(frame)
    frame.bgrSimpleHooked = true
    frame.darkBg = frame:CreateTexture(nil, "BACKGROUND")
    local r, g, b = Baganator_Simple_Lighten(color.r, color.g, color.b, -0.2)
    frame.darkBg:SetColorTexture(r, g, b, 0.3)
    frame.darkBg:SetPoint("CENTER")
    frame.darkBg:SetSize(36, 36)
    table.insert(toColor.textures, {texture = frame.darkBg, alpha = 0.3, lightened = -0.2})
    if frame.SetItemButtonQuality then
      hooksecurefunc(frame, "SetItemButtonQuality", ItemButtonQualityHook)
    end
    if frame.SetItemButtonTexture then
      hooksecurefunc(frame, "SetItemButtonTexture", ItemButtonTextureHook)
    end
  end,
  IconButton = function(button)
    StyleButton(button)
  end,
  Button = function(button)
    StyleButton(button)
  end,
  ButtonFrame = function(frame, tags)
    RemoveFrameTextures(frame)
    Mixin(frame, BackdropTemplateMixin)
    frame:SetBackdrop(frameBackdropInfo)
    frame:SetBackdropColor(color.r, color.g, color.b, 0.7)
    local r, g, b = Baganator_Simple_Lighten(color.r, color.g, color.b, 0.3)
    frame:SetBackdropBorderColor(r, g, b, 1)
    table.insert(toColor.backdrops, {backdrop = frame, bgAlpha = 0.7, borderAlpha = 1, borderLightened = 0.3})

    if tags.backpack then
      frame.TopButtons[1]:SetPoint("TOPLEFT", 1, -1)
    elseif tags.bank then
      frame.Character.TopButtons[1]:SetPoint("TOPLEFT", 1, -1)
    elseif tags.guild then
      frame.ToggleTabTextButton:SetPoint("TOPLEFT", 1, -1)
    end
  end,
  SearchBox = function(frame)
  end,
  EditBox = function(frame)
  end,
  TabButton = function(frame)
  end,
  TopTabButton = function(frame)
  end,
  SideTabButton = function(frame)
  end,
  TrimScrollBar = function(frame)
  end,
  CheckBox = function(frame)
  end,
  Slider = function(frame)
  end,
  InsetFrame = function(frame)
  end,
  CornerWidget = function(frame, tags)
  end,
  DropDownWithPopout = function(button)
  end,
}

if C_AddOns.IsAddOnLoaded("Masque") or not BAGANATOR_CONFIG["empty_slot_background"] then
  skinners.ItemButton = function() end
else
  hooksecurefunc("SetItemButtonQuality", ItemButtonQualityHook)
  hooksecurefunc("SetItemButtonTexture", ItemButtonTextureHook)
end

local function SkinFrame(details)
  local func = skinners[details.regionType]
  if func then
    func(details.region, details.tags and ConvertTags(details.tags) or {})
  end
end

Baganator.API.Skins.RegisterListener(SkinFrame)

--Baganator.Config.Set(Baganator.Config.Options.EMPTY_SLOT_BACKGROUND, true)

for _, details in ipairs(Baganator.API.Skins.GetAllFrames()) do
  SkinFrame(details)
end
