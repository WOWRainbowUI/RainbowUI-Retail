---@class addonTableBaganator
local addonTable = select(2, ...)

local menu = CreateFrame("Frame", nil, UIParent)
local onActiveRow = false
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
  function menu:StartFocus()
    self.gamepadFooter:ShowAndActivateBindings()
  end
  function menu:EndFocus()
    self.gamepadFooter:HideAndDeactivateBindings()
    menu:Hide()
  end
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

  local bindings = {
    {
      button = GAMEPAD_FACE_BOTTOM, label = ACTION_LABEL_SELECT,
      condition = function()
        return onActiveRow
      end
    },
    {
      isBack = true, label = CLOSE
    }
  }
  menu.gamepadFooter = addonTable.Gamepad.GetBindingsFooter(bindings, menu, -10, -15)

  menu.buttonsPool = CreateFramePool("Button", menu)
  menu.secureButtonsPool = CreateFramePool("Button", menu, "InsecureActionButtonTemplate")
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
  menu.secureButtonsPool:ReleaseAll()
  menu:Show()

  for i, e in ipairs(entries) do
    local b
    if e.macro then
      b = menu.secureButtonsPool:Acquire()
      b:SetAttribute("type", "macro")
      b:RegisterForClicks("AnyUp", "AnyDown")
      b:SetAttribute("macrotext", e.macro)
      if not b.hooked then
        b:HookScript("OnClick", function()
          menu:Hide()
        end)
      end
    else
      b = menu.buttonsPool:Acquire()
      b:SetScript("OnClick", function()
        e.callback()
        menu:Hide()
      end)
    end
    b:SetFrameStrata("DIALOG")
    b:SetFrameLevel(menu:GetFrameLevel() + 20)
    b:SetNormalFontObject(GameFontHighlight)
    b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    b:SetText(e.label)
    b:GetFontString():SetJustifyH("CENTER")
    b:SetWidth(max)
    b:SetHeight(22)
    b:SetPoint("TOP", 0, -(i - 1) * 22)
    b:SetPoint("LEFT", 0, 0)
    b:SetPoint("RIGHT", 0, 0)
    b:SetEnabled(e.enabled ~= false)
    if e.enabled ~= false then
      b:GetFontString():SetTextColor(1, 1, 1)
    else
      b:GetFontString():SetTextColor(0.5, 0.5, 0.5)
    end
    function b:OnSmartNavSelect()
      onActiveRow = b:IsEnabled()
    end
    function b:OnSmartNavDeselect()
      onActiveRow = false
    end
    b:Show()

    if i == 1 then
      addonTable.Gamepad.SetTargetButton(menu, b)
    end
  end
end

