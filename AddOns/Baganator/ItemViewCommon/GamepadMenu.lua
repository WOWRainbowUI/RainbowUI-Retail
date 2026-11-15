---@class addonTableBaganator
local addonTable = select(2, ...)

local menu = CreateFrame("Frame", nil, UIParent)
if addonTable.Constants.IsGamepadInUse then
  menu:Hide()
  menu:SetScript("OnShow", function()
    addonTable.Gamepad.AnnounceShow(menu, true)
  end)
  menu:SetScript("OnHide", function()
    addonTable.Gamepad.AnnounceHide(menu)
  end)
  function menu:SmartNavigationCloseHandler()
    menu:Hide()
    return true
  end
  function menu:EndFocus()
    menu:Hide()
  end
  menu.layoutType = "CharacterCreateDropdown"
  menu:SetFrameStrata("DIALOG")
  menu.background = menu:CreateTexture()
  menu.background:SetAtlas("common-dropdown-bg")
  menu.background:SetTextureSliceMargins(30, 30, 30, 30)
  menu.background:SetPoint("TOPLEFT", -20, 10)
  menu.background:SetPoint("BOTTOMRIGHT", 20, -18)
  menu.layoutType = "MenuProxyTemplate"
  menu.FrameGlow = CreateFrame("Frame", nil, menu, "FrameGlowTemplate")
  menu.FrameGlow:ClearAllPoints()
  menu.FrameGlow:SetPoint("TOPLEFT", -27, 20)
  menu.FrameGlow:SetPoint("BOTTOMRIGHT", 27, -23)
  menu.FrameGlow:SetFrameLevel(menu:GetFrameLevel() + 200)

  menu.buttonsPool = CreateFramePool("Button", menu)
end

local sizingFontString = UIParent:CreateFontString(nil, nil, "GameFontHighlight")

function addonTable.ItemViewCommon.ShowGamepadMenu(parent, anchor, entries)
  if not addonTable.Constants.IsGamepadInUse then
    return
  end

  local max = 0
  for _, e in ipairs(entries) do
    sizingFontString:ClearText()
    sizingFontString:SetText(e.label)
    max = math.max(sizingFontString:GetUnboundedStringWidth(), max)
  end

  menu:SetSize(max + 13, 22 * #entries)

  menu:ClearAllPoints()
  menu:SetPoint(unpack(anchor))

  menu.buttonsPool:ReleaseAll()
  menu:Show()

  for i, e in ipairs(entries) do
    local b = menu.buttonsPool:Acquire()
    b:SetFrameStrata("DIALOG")
    b:SetFrameLevel(menu:GetFrameLevel() + 20)
    b:SetNormalFontObject(GameFontHighlight)
    b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    b:SetText(e.label)
    b:GetFontString():SetJustifyH("CENTER")
    b:SetWidth(max)
    b:SetHeight(22)
    b:SetScript("OnClick", function()
      e.callback()
      menu:Hide()
    end)
    b:SetPoint("TOP", 0, -(i - 1) * 22)
    b:SetPoint("LEFT", 0, 0)
    b:SetPoint("RIGHT", 0, 0)
    b:Show()

    if i == 1 then
      addonTable.Gamepad.SetTargetButton(menu, b)
    end
  end
end

