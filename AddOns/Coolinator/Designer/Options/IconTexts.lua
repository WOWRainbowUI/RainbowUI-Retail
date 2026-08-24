---@class addonTableCoolinator
local addonTable = select(2, ...)

function addonTable.Designer.Options.GetIconTextPositioning(rootParent, iconID)
  local container = CreateFrame("Frame", nil, rootParent)
  container:SetPoint("LEFT")
  container:SetPoint("RIGHT")
  container:SetHeight(300)
  local previewInset = CreateFrame("Frame", nil, container, "InsetFrameTemplate")
  previewInset:SetSize(160, 120)
  previewInset:SetPoint("TOP")

  local preview = CreateFrame("Frame", nil, previewInset)

  preview:SetPoint("TOP")

  preview:SetAllPoints()
  preview:SetFlattensRenderLayers(true)
  preview:SetScale(3)

  preview:SetSize(40, 40)

  local wrapper = CreateFrame("Frame", nil, preview)
  wrapper:SetSize(addonTable.Constants.nativeSize - 4, addonTable.Constants.nativeSize - 4)
  wrapper:SetPoint("CENTER")
  wrapper.Icon = wrapper:CreateTexture(nil, "ARTWORK")
  wrapper.Icon:SetTexture(iconID)
  wrapper.Icon:SetPoint("CENTER")
  wrapper.Icon:SetAllPoints()
  wrapper.Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)

  local expectedTexts = {"keybinding", "count", "cooldown"}

  local widgetOptions = {}
  for _, kind in ipairs(expectedTexts) do
    local optionsContainer = CreateFrame("Frame", nil, container)
    optionsContainer:SetPoint("TOP", preview, "BOTTOM", 0, -30)
    optionsContainer:SetPoint("LEFT")
    optionsContainer:SetPoint("RIGHT")
    optionsContainer:SetHeight(10)
    optionsContainer.allFrames = addonTable.Designer.Options.GenerateOptions(optionsContainer, 0, 0, addonTable.Designer.IconTextsConfig[kind])

    widgetOptions[kind] = optionsContainer
  end

  local titleText = container:CreateFontString(nil, nil, "GameFontHighlightLarge")
  titleText:SetPoint("TOP", previewInset, "BOTTOM", 0, -10)
  titleText:SetJustifyH("RIGHT")
  titleText:SetPoint("RIGHT", -40, 0)
  titleText:SetShadowOffset(1, -1)

  local titleMap = {
    cooldown = addonTable.Locales.COOLDOWN,
    count = addonTable.Locales.COUNT,
    keybinding = addonTable.Locales.KEYBINDING,
  }

  local selectedMarker = addonTable.Designer.Options.GetSelectorMarker(CreateFrame("Frame", nil, container), false)
  local hoverMarker = addonTable.Designer.Options.GetSelectorMarker(CreateFrame("Frame", nil, container), true)
  local selection = nil

  local keyboardTrap = CreateFrame("Frame", nil, container)
  keyboardTrap:Hide()

  local function OffsetWidgets(x, y)
    addonTable.Designer.Options.UpdateWidgetPointsBasic(preview, selection, 0.4, x, y)
    addonTable.Designer.Options.Announce()
  end

  keyboardTrap:SetScript("OnKeyDown", function(_, key)
    keyboardTrap:SetPropagateKeyboardInput(false)
    local amount = addonTable.Designer.Options.pixelStep
    if IsShiftKeyDown() then
      amount = amount * 4
    end
    if key == "LEFT" then
      OffsetWidgets(-amount, 0)
    elseif key == "RIGHT" then
      OffsetWidgets(amount, 0)
    elseif key == "UP" then
      OffsetWidgets(0, amount)
    elseif key == "DOWN" then
      OffsetWidgets(0, -amount)
    elseif key == "DELETE" then
      selection.details.visible = false
      addonTable.Designer.Options.Announce()
    else
      keyboardTrap:SetPropagateKeyboardInput(true)
    end
  end)
  keyboardTrap:RegisterEvent("PLAYER_REGEN_ENABLED")
  keyboardTrap:RegisterEvent("PLAYER_REGEN_DISABLED")
  keyboardTrap:SetScript("OnEvent", function(_, event)
    keyboardTrap:SetShown(event == "PLAYER_REGEN_ENABLED" and selection)
  end)

  local function UpdateSelection()
    if selection then
      selectedMarker:Show()
      selectedMarker:SetFrameStrata("HIGH")
      selectedMarker:ClearAllPoints()
      selectedMarker:SetPoint("TOPLEFT", selection, "TOPLEFT", -2, 2)
      selectedMarker:SetPoint("BOTTOMRIGHT", selection, "BOTTOMRIGHT", 2, -2)

      for kind, optionsContainer in pairs(widgetOptions) do
        if kind == selection.kind then
          optionsContainer:Show()
          optionsContainer.details = selection.details
          for _, f in ipairs(optionsContainer.allFrames) do
            if f.getInitData then
              f:Init(f.getInitData(selection.details))
            end
            f:SetValue(f.Getter())
          end
        else
          optionsContainer:Hide()
        end
      end

      titleText:Show()
      titleText:SetText(titleMap[selection.kind])
      keyboardTrap:SetShown(not InCombatLockdown())
    else
      titleText:Hide()
      for _, optionsContainer in pairs(widgetOptions) do
        optionsContainer:Hide()
      end
      selectedMarker:Hide()
      keyboardTrap:Hide()
    end
  end

  local function ToggleSelection(w)
    if selection == w then
      selection = nil
    else
      selection = w
    end
    UpdateSelection()
  end
  local function ForceSelection(w)
    selection = w
    UpdateSelection()
  end

  preview.widgets = {}

  for _, key in ipairs(expectedTexts) do
    local w = CreateFrame("Frame", nil, wrapper)
    w:SetSize(1, 1)
    preview.widgets[key] = w
    w.text = w:CreateFontString(nil, nil, "GameFontNormal")
    w.text:SetWordWrap(false)
    w.kind = key
    w:SetMovable(true)
    w:EnableMouse(true)
    w:RegisterForDrag("LeftButton")
    w:SetScript("OnEnter", function()
      hoverMarker:Show()
      hoverMarker:SetFrameStrata("HIGH")
      hoverMarker:ClearAllPoints()
      hoverMarker:SetPoint("TOPLEFT", w, "TOPLEFT", -2, 2)
      hoverMarker:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 2, -2)
    end)
    w:SetScript("OnLeave", function()
      hoverMarker:Hide()
    end)
    w:SetScript("OnDragStart", function()
      w:StartMoving()
      ForceSelection(w)
    end)
    w:SetScript("OnDragStop", function()
      w:StopMovingOrSizing()
      addonTable.Designer.Options.UpdateWidgetPointsBasic(preview, w, 2)
      ForceSelection(w)
      addonTable.Designer.Options.Announce()
    end)
    w:SetScript("OnMouseUp", function()
      ToggleSelection(w)
    end)
  end

  preview.widgets.cooldown.text:SetText(3)
  preview.widgets.count.text:SetText(2)
  preview.widgets.keybinding.text:SetText("s-2")

  function container:SetValue(details)
    container.details = details.texts
    wrapper.Icon:SetShown(not details.textsOnly)

    local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
    for _, key in ipairs(expectedTexts) do
      local text = preview.widgets[key].text
      local textDetails = details.texts[key]
      if textDetails then
        text:ClearAllPoints()
        text:SetFontObject(addonTable.CurrentNumberFont)
        if font.slug then
          text:SetSmoothScaling(true)
          text:SetTextScale(1)
          text:SetScale(textDetails.scale)
        else
          text:SetSmoothScaling(false)
          text:SetTextScale(textDetails.scale)
          text:SetScale(1)
        end
        text:SetPoint(textDetails.anchor[1] == nil and "CENTER" or textDetails.anchor[1]:match("LEFT") or textDetails.anchor[1]:match("RIGHT") or "CENTER")
        text:SetTextColor(textDetails.color.r, textDetails.color.g, textDetails.color.b)
        if key == "cooldown" then
          if textDetails.showFractions then
            text:SetText("2.9")
          else
            text:SetText("3")
          end
        end
        if textDetails.visible then
          preview.widgets[key]:SetAlpha(1)
        else
          preview.widgets[key]:SetAlpha(0.5)
        end
        local w, h = text:GetSize()
        preview.widgets[key]:SetSize(w * text:GetScale(), h * text:GetScale())
        preview.widgets[key].details = textDetails

        addonTable.Display.ApplyAnchor(preview.widgets[key], {textDetails.anchor[1], textDetails.anchor[2], textDetails.anchor[3]})
      end
    end

    UpdateSelection()
  end

  return container
end
