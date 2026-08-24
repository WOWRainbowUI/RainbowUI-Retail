---@class addonTableCoolinator
local addonTable = select(2, ...)

local function GenerateDialog()
  local dialog = CreateFrame("Frame", "CoolinatorDesignerDialog", UIParent)
  dialog:SetToplevel(true)
  dialog:SetPoint("TOP", 0, -135)
  dialog:EnableMouse(true)
  dialog:SetFrameStrata("DIALOG")
  dialog:SetClampedToScreen(true)

  dialog.NineSlice = CreateFrame("Frame", nil, dialog, "NineSlicePanelTemplate")
  NineSliceUtil.ApplyLayoutByName(dialog.NineSlice, "Dialog", dialog.NineSlice:GetFrameLayoutTextureKit())

  local bg = dialog:CreateTexture(nil, "BACKGROUND", nil, -1)
  bg:SetColorTexture(0, 0, 0, 0.8)
  bg:SetPoint("TOPLEFT", 11, -11)
  bg:SetPoint("BOTTOMRIGHT", -11, 11)

  dialog:SetSize(500, 80)

  dialog.text = dialog:CreateFontString(nil, nil, "GameFontHighlightMedium")
  dialog.text:SetPoint("TOP", 0, -20)
  dialog.text:SetPoint("LEFT", 20, 0)
  dialog.text:SetPoint("RIGHT", -20, 0)
  dialog.text:SetJustifyH("CENTER")
  dialog.text:SetText(addonTable.Locales.EDIT_THE_ICONS_AND_BARS_ONSCREEN)

  --addonTable.Skins.AddFrame("Dialog", dialog)
  dialog.exitButton = CreateFrame("Button", nil, dialog, "UIPanelDynamicResizeButtonTemplate")
  dialog.exitButton:SetText(addonTable.Locales.CLOSE_DESIGNER)
  DynamicResizeButton_Resize(dialog.exitButton)
  dialog.exitButton:SetScript("OnClick", function()
    addonTable.CallbackRegistry:TriggerEvent("Designer.Close")
  end)

  dialog.exitButton:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 15)

  dialog:SetMovable(true)
  dialog:RegisterForDrag("LeftButton")
  dialog:SetScript("OnDragStart", function()
    dialog:StartMoving()
  end)
  dialog:SetScript("OnDragStop", function()
    dialog:StopMovingOrSizing()
  end)

  return dialog
end

local isOpen = false
local dialog
function addonTable.Designer.Toggle()
  if isOpen then
    addonTable.CallbackRegistry:TriggerEvent("Designer.Close")
  else
    if addonTable.Designer.GenerateEditable(function()
      addonTable.CallbackRegistry:TriggerEvent("Designer.Open")
    end) then
      addonTable.CallbackRegistry:TriggerEvent("Designer.Open")
    end
  end
end

addonTable.CallbackRegistry:RegisterCallback("Designer.Open", function()
  if not dialog then
    dialog = GenerateDialog()
  end

  isOpen = true
  dialog:Show()
end)

addonTable.CallbackRegistry:RegisterCallback("Designer.Close", function()
  if not dialog then
    dialog = GenerateDialog()
  end

  isOpen = false
  dialog:Hide()
end)
