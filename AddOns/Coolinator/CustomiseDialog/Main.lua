---@class addonTableCoolinator
local addonTable = select(2, ...)

local customisers = {}

local function SetupGeneral(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}
  local infoInset = CreateFrame("Frame", nil, container, "InsetFrameTemplate")
  do
    table.insert(allFrames, infoInset)
    infoInset:SetPoint("TOP")
    infoInset:SetPoint("LEFT", 20, 0)
    infoInset:SetPoint("RIGHT", -20, 0)
    infoInset:SetHeight(75)
    --addonTable.Skins.AddFrame("InsetFrame", infoInset)

    local logo = infoInset:CreateTexture(nil, "ARTWORK")
    logo:SetTexture("Interface\\AddOns\\Coolinator\\Assets\\logo.png")
    logo:SetSize(52, 52)
    logo:SetPoint("LEFT", 8, 0)

    local name = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    name:SetText(addonTable.Locales.COOLINATOR)
    name:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, 0)

    local credit = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    credit:SetText(addonTable.Locales.BY_PLUSMOUSE)
    credit:SetPoint("BOTTOMLEFT", name, "BOTTOMRIGHT", 5, 0)

    local discordButton = CreateFrame("Button", nil, infoInset, "UIPanelDynamicResizeButtonTemplate")
    discordButton:SetText(addonTable.Locales.JOIN_THE_DISCORD)
    DynamicResizeButton_Resize(discordButton)
    discordButton:SetPoint("BOTTOMLEFT", logo, "BOTTOMRIGHT", 8, 0)
    discordButton:SetScript("OnClick", function()
      addonTable.Dialogs.ShowCopy("https://discord.gg/uzJSCNVdNB")
    end)
    --addonTable.Skins.AddFrame("Button", discordButton)
    local discordText = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    discordText:SetPoint("LEFT", discordButton, "RIGHT", 10, 0)
    discordText:SetText(addonTable.Locales.DISCORD_DESCRIPTION)
  end

  do
    local header = addonTable.CustomiseDialog.Components.GetHeader(container, addonTable.Locales.DEVELOPMENT_IS_TIME_CONSUMING)
    header:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
    table.insert(allFrames, header)

    local donateFrame = CreateFrame("Frame", nil, container)
    donateFrame:SetPoint("LEFT")
    donateFrame:SetPoint("RIGHT")
    donateFrame:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
    donateFrame:SetHeight(40)
    local text = donateFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("RIGHT", donateFrame, "CENTER", -50, 0)
    text:SetText(addonTable.Locales.DONATE)
    text:SetJustifyH("RIGHT")

    local button = CreateFrame("Button", nil, donateFrame, "UIPanelDynamicResizeButtonTemplate")
    button:SetText(addonTable.Locales.LINK)
    DynamicResizeButton_Resize(button)
    button:SetPoint("LEFT", donateFrame, "CENTER", -35, 0)
    button:SetScript("OnClick", function()
      addonTable.Dialogs.ShowCopy("https://linktr.ee/plusmouse")
    end)
    --addonTable.Skins.AddFrame("Button", button)
    table.insert(allFrames, donateFrame)
  end

  local profileDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.PROFILES)
  do
    profileDropdown.SetValue = nil

    local clone = false
    local function ValidateAndCreate(profileName)
      if profileName ~= "" and COOLINATOR_CONFIG.Profiles[profileName] == nil then
        local oldSkin = addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)
        addonTable.Config.MakeProfile(profileName, clone)
        profileDropdown.DropDown:GenerateMenu()
        if addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN) ~= oldSkin then
          addonTable.Dialogs.ShowConfirm(addonTable.Locales.RELOAD_REQUIRED, YES, NO, function() ReloadUI() end)
        end
      end
    end
    profileDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, 0)
    profileDropdown.DropDown:SetupMenu(function(menu, rootDescription)
      local profiles = addonTable.Config.GetProfileNames()
      table.sort(profiles, function(a, b) return a:lower() < b:lower() end)
      for _, name in ipairs(profiles) do
        local button = rootDescription:CreateRadio(name ~= "DEFAULT" and name or LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(DEFAULT), function()
          return COOLINATOR_CURRENT_PROFILE == name
        end, function()
          addonTable.CallbackRegistry:TriggerEvent("Designer.Close")
          addonTable.Config.ChangeProfile(name)
        end)
        if name ~= "DEFAULT" and name ~= COOLINATOR_CURRENT_PROFILE then
          button:AddInitializer(function(button, description, menu)
            if InCombatLockdown() then
              return
            end
            local delete = MenuTemplates.AttachAutoHideButton(button, "transmog-icon-remove")
            delete:SetPoint("RIGHT")
            delete:SetSize(18, 18)
            delete.Texture:SetAtlas("transmog-icon-remove")
            delete:SetScript("OnClick", function()
              menu:Close()
              addonTable.Dialogs.ShowConfirm(addonTable.Locales.CONFIRM_DELETE_PROFILE_X:format(name), YES, NO, function()
                addonTable.Config.DeleteProfile(name)
              end)
            end)
            MenuUtil.HookTooltipScripts(delete, function(tooltip)
              GameTooltip_SetTitle(tooltip, DELETE)
            end)
          end)
        end
      end
      rootDescription:CreateButton(NORMAL_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.NEW_PROFILE_CLONE), function()
        clone = true
        addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_PROFILE_NAME, ACCEPT, CANCEL, ValidateAndCreate)
      end)
      rootDescription:CreateButton(NORMAL_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.NEW_PROFILE_BLANK), function()
        clone = false
        addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_PROFILE_NAME, ACCEPT, CANCEL, ValidateAndCreate)
      end)
      rootDescription:SetScrollMode(30 * 20)
    end)
  end
  table.insert(allFrames, profileDropdown)

  local designDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.DESIGN)
  designDropdown:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  designDropdown.DropDown:SetupMenu(function(_, rootDescription)
    local specID = addonTable.Utilities.GetSpecID()
    local designs = GetKeysArray(addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[specID])
    local assignments = addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)
    table.sort(designs)
    for _, name in ipairs(designs) do
      local button = rootDescription:CreateRadio(name ~= "DEFAULT" and name or LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(DEFAULT), function()
        return assignments[specID] == name
      end, function()
        addonTable.CallbackRegistry:TriggerEvent("Designer.Close")
        assignments[specID] = name
        addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
      end)
      if name ~= "DEFAULT" and name ~= assignments[specID] then
        button:AddInitializer(function(button, description, menu)
          if InCombatLockdown() then
            return
          end
          local delete = MenuTemplates.AttachAutoHideButton(button, "transmog-icon-remove")
          delete:SetPoint("RIGHT")
          delete:SetSize(18, 18)
          delete.Texture:SetAtlas("transmog-icon-remove")
          delete:SetScript("OnClick", function()
            menu:Close()
            addonTable.Dialogs.ShowConfirm(addonTable.Locales.CONFIRM_DELETE_DESIGN_X:format(name), YES, NO, function()
              addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[specID][name] = nil
            end)
          end)
          MenuUtil.HookTooltipScripts(delete, function(tooltip)
            GameTooltip_SetTitle(tooltip, DELETE)
          end)
        end)
      end
    end
    rootDescription:CreateButton(NORMAL_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.NEW_DESIGN), function()
      addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_DESIGN_NAME, ACCEPT, CANCEL, function(name)
        if addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[specID][name] == nil then
          addonTable.Core.AutoGenerateLayout(name)
          addonTable.Config.Get(addonTable.Config.Options.DESIGN_ASSIGNMENTS)[specID] = name
          addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
          designDropdown.DropDown:GenerateMenu()
        else
          addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.THAT_DESIGN_NAME_ALREADY_EXISTS)
        end
      end)
    end)
  end)
  table.insert(allFrames, designDropdown)

  do
    local exportButton = CreateFrame("Button", nil, container, "UIPanelDynamicResizeButtonTemplate")
    exportButton:SetPoint("TOPLEFT", allFrames[#allFrames], "BOTTOM", -33, -10)
    exportButton:SetText(addonTable.Locales.EXPORT)
    DynamicResizeButton_Resize(exportButton)
    exportButton:SetScript("OnClick", function()
      addonTable.Dialogs.ShowDualChoice(addonTable.Locales.WHAT_TO_EXPORT, addonTable.Locales.DESIGN, addonTable.Locales.PROFILE,
        function()
          local export = {data = CopyTable(addonTable.Core.GetCurrentDesign())}
          export.addon = "Coolinator"
          export.kind = "design"
          export.specID = addonTable.Utilities.GetSpecID()
          export.version = 1
          addonTable.Dialogs.ShowCopy("COOLI!1!" .. C_EncodingUtil.EncodeBase64(C_EncodingUtil.CompressString(C_EncodingUtil.SerializeCBOR(export))))
        end, function()
          local options = addonTable.Config.DumpCurrentProfile()
          options.addon = "Coolinator"
          options.version = 1
          options.kind = "profile"
          addonTable.Dialogs.ShowCopy("COOLI!1!" .. C_EncodingUtil.EncodeBase64(C_EncodingUtil.CompressString(C_EncodingUtil.SerializeCBOR(options))))
        end
      )
    end)
    --addonTable.Skins.AddFrame("Button", exportButton)

    local importButton = CreateFrame("Button", nil, container, "UIPanelDynamicResizeButtonTemplate")
    importButton:SetPoint("TOPRIGHT", allFrames[#allFrames], "BOTTOM", -45, -10)
    importButton:SetText(addonTable.Locales.IMPORT)
    DynamicResizeButton_Resize(importButton)
    importButton:SetScript("OnClick", function()
      addonTable.CustomiseDialog.ShowImportDialog(function(text)
        local prefix = text:match("^COOLI!1!")
        if not prefix then
          addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_IMPORT)
          return
        end
        local status, decoded = pcall(C_EncodingUtil.DecodeBase64, text:sub(9))
        if not status then
          addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_IMPORT)
          return
        end
        local status, decompressed = pcall(C_EncodingUtil.DecompressString, decoded)
        if not status then
          addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_IMPORT)
          return
        end
        local status, import = pcall(C_EncodingUtil.DeserializeCBOR, decompressed)
        if not status or type(import) ~= "table" or import.addon ~= "Coolinator" then
          addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_IMPORT)
          return
        end
        if import.kind == "design" then
          addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_THE_NEW_DESIGN_NAME, OKAY, CANCEL, function(value)
            local designs = addonTable.Config.Get(addonTable.Config.Options.DESIGNS)[addonTable.Utilities.GetSpecID()]
            if designs[value] or value:match("^_") then
              addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.THAT_DESIGN_NAME_ALREADY_EXISTS)
            else
              addonTable.CustomiseDialog.ImportData(import, value, false)
              designDropdown.DropDown:GenerateMenu()
            end
          end)
        elseif import.kind == "profile" then
          addonTable.Dialogs.ShowDualChoice(addonTable.Locales.OVERWRITE_CURRENT_PROFILE, addonTable.Locales.OVERWRITE, addonTable.Locales.MAKE_NEW,
            function()
              addonTable.CustomiseDialog.ImportData(import, COOLINATOR_CURRENT_PROFILE, true)
              profileDropdown.DropDown:GenerateMenu()
            end,
            function()
              addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_THE_NEW_PROFILE_NAME, OKAY, CANCEL, function(value)
                if COOLINATOR_CONFIG.Profiles[value] == nil then
                  addonTable.CustomiseDialog.ImportData(import, value, false)
                  profileDropdown.DropDown:GenerateMenu()
                else
                  addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.THAT_PROFILE_NAME_ALREADY_EXISTS)
                end
              end)
            end
          )
        end
      end)
    end)
    --addonTable.Skins.AddFrame("Button", importButton)
  end

  return container
end

local function SetupDesigner(parent)
  local container = CreateFrame("Frame", nil, parent)

  local button = CreateFrame("Button", nil, container, "UIPanelDynamicResizeButtonTemplate")
  button:SetText(addonTable.Locales.START)
  DynamicResizeButton_Resize(button)
  button:SetPoint("TOP", container, "TOP", 0, -10)
  button:SetScript("OnClick", function()
    addonTable.Designer.Toggle()
    parent:Hide()
  end)

  return container
end

local function SetupBehaviour(parent)
  local container = CreateFrame("Frame", nil, parent)
  local allFrames = {}

  local compressLayout = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.REMOVE_SPACING_FOR_HIDDEN_ICONS, 28, function(value)
    addonTable.Config.Set(addonTable.Config.Options.COMPRESS_LAYOUT, not addonTable.Config.Get(addonTable.Config.Options.COMPRESS_LAYOUT))
  end)
  compressLayout.option = addonTable.Config.Options.COMPRESS_LAYOUT
  compressLayout:SetPoint("TOP")
  table.insert(allFrames, compressLayout)

  local useBlizzardWidgets = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.USE_BLIZZARD_WIDGETS, 28, function(value)
    addonTable.Config.Set(addonTable.Config.Options.USE_BLIZZARD_WIDGETS, not addonTable.Config.Get(addonTable.Config.Options.USE_BLIZZARD_WIDGETS))
  end)
  useBlizzardWidgets.option = addonTable.Config.Options.USE_BLIZZARD_WIDGETS
  useBlizzardWidgets:SetPoint("TOP", compressLayout, "BOTTOM", 0, -30)
  table.insert(allFrames, useBlizzardWidgets)

  local showKeybindings = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.SHOW_KEYBINDINGS, 28, function(value)
    addonTable.Config.Set(addonTable.Config.Options.SHOW_KEYBINDINGS, not addonTable.Config.Get(addonTable.Config.Options.SHOW_KEYBINDINGS))
  end)
  showKeybindings.option = addonTable.Config.Options.SHOW_KEYBINDINGS
  showKeybindings:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  table.insert(allFrames, showKeybindings)

  local showTooltips = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.SHOW_TOOLTIPS, 28, function(value)
    addonTable.Config.Set(addonTable.Config.Options.SHOW_TOOLTIPS, not addonTable.Config.Get(addonTable.Config.Options.SHOW_TOOLTIPS))
  end)
  showTooltips.option = addonTable.Config.Options.SHOW_TOOLTIPS
  showTooltips:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, showTooltips)

  local showGCDSwipe = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.SHOW_GCD_SWIPE, 28, function(value)
    addonTable.Config.Set(addonTable.Config.Options.SHOW_GCD_SWIPE, not addonTable.Config.Get(addonTable.Config.Options.SHOW_GCD_SWIPE))
  end)
  showGCDSwipe.option = addonTable.Config.Options.SHOW_GCD_SWIPE
  showGCDSwipe:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, showGCDSwipe)

  if C_AddOns.IsAddOnLoaded("Masque") then
    local useMasque = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.USE_MASQUE, 28, function(value)
      addonTable.Config.Set(addonTable.Config.Options.USE_MASQUE, not addonTable.Config.Get(addonTable.Config.Options.USE_MASQUE))
    end)
    useMasque.option = addonTable.Config.Options.USE_MASQUE
    useMasque:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
    table.insert(allFrames, useMasque)
  end

  container:SetScript("OnShow", function()
    for _, f in ipairs(allFrames) do
      if f.SetValue then
        if f.option then
          f:SetValue(addonTable.Config.Get(f.option))
        elseif f.DropDown then
          f:SetValue()
        end
      end
    end
  end)

  return container
end

local function SetupFont(parent)
  local container = CreateFrame("Frame", nil, parent)

  local allFrames = {}

  local fontDropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(container, addonTable.Locales.FONT)
  fontDropdown:SetPoint("TOP")
  table.insert(allFrames, fontDropdown)

  local outlineCheckbox = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.SHOW_OUTLINE, 28, function(value)
    local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
    font.flags.outline = not font.flags.outline
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
  end)
  outlineCheckbox:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, outlineCheckbox)

  local shadowCheckbox = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.SHOW_SHADOW, 28, function(value)
    local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
    font.flags.shadow = not font.flags.shadow
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
  end)
  shadowCheckbox:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, shadowCheckbox)

  local fontSize = addonTable.CustomiseDialog.Components.GetSlider(container, addonTable.Locales.FONT_SIZE, 6, 60, function(val) return ("%dpx"):format(val) end, function(value)
    local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
    local oldSize = font.size
    font.size = value / 12
    if Round(font.size * 100) ~= Round(oldSize * 100) then
      addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
    end
  end)
  fontSize:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, 0)
  table.insert(allFrames, fontSize)

  local fontFixCheckbox = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.ENABLE_IF_LINES_FALLING_OFF_FONT, 28, function(value)
    local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
    font.flags.slug = not font.flags.slug
    addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
  end)
  fontFixCheckbox:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  table.insert(allFrames, fontFixCheckbox)

  local function Update()
    local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
    outlineCheckbox:SetValue(font.flags.outline)
    shadowCheckbox:SetValue(font.flags.shadow)
    fontFixCheckbox:SetValue(not font.flags.slug)
    fontSize:SetValue(font.size * 12)

    for _, f in ipairs(allFrames) do
      if f.DropDown then
        f:SetValue()
      end
    end

    local LibSharedMedia = LibStub("LibSharedMedia-3.0")
    local fonts = CopyTable(LibSharedMedia:List("font"))
    table.sort(fonts)

    fontDropdown.DropDown:SetupMenu(function(_, rootDescription)
      for index, label in ipairs(fonts) do
        local radio = rootDescription:CreateRadio(label,
          function()
            local asset = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT).asset
            return label == asset
          end,
          function()
            local font = addonTable.Config.Get(addonTable.Config.Options.NUMBER_FONT)
            local oldAsset = font.asset
            if label ~= oldAsset then
              font.asset = label
              addonTable.CallbackRegistry:TriggerEvent("RefreshStateChange", {[addonTable.Constants.RefreshReason.Design] = true})
            end
          end
        )
        radio:AddInitializer(function(button, elementDescription, menu)
          button.fontString:SetFontObject(addonTable.Core.GetFontByID(label))
        end)
      end
      rootDescription:SetScrollMode(30 * 20)
    end)
  end

  container:SetScript("OnShow", Update)

  return container
end

local TabSetups = {
  {callback = SetupGeneral, name = addonTable.Locales.GENERAL},
  {callback = SetupDesigner, name = addonTable.Locales.DESIGNER},
  {callback = SetupBehaviour, name = addonTable.Locales.BEHAVIOUR},
  --{callback = addonTable.CustomiseDialog.GetSounds, name = addonTable.Locales.SOUNDS},
  {callback = SetupFont, name = addonTable.Locales.FONT},
}

function addonTable.CustomiseDialog.Toggle()
  if customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)] then
    local frame = customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)]
    frame:SetShown(not frame:IsVisible())
    return
  end

  local frame = addonTable.CustomiseDialog.Components.GetContentFrame(
    "CoolinatorCustomiseDialog" .. addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN),
    600, 600
  )
  customisers[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)] = frame

  local containers = {}
  local lastTab
  local Tabs = {}
  for _, setup in ipairs(TabSetups) do
    local tabContainer = setup.callback(frame)
    tabContainer:SetPoint("TOPLEFT", addonTable.Constants.ButtonFrameOffset, -65)
    tabContainer:SetPoint("BOTTOMRIGHT")

    local tabButton = addonTable.CustomiseDialog.Components.GetTab(frame, setup.name)
    if lastTab then
      tabButton:SetPoint("LEFT", lastTab, "RIGHT", 5, 0)
    else
      tabButton:SetPoint("TOPLEFT", 0 + addonTable.Constants.ButtonFrameOffset + 5, -25)
    end
    lastTab = tabButton
    tabContainer.button = tabButton
    tabButton:SetScript("OnClick", function()
      for _, c in ipairs(containers) do
        PanelTemplates_DeselectTab(c.button)
        c:Hide()
      end
      PanelTemplates_SelectTab(tabButton)
      tabContainer:Show()
    end)
    tabContainer:Hide()

    table.insert(Tabs, tabButton)
    table.insert(containers, tabContainer)
  end
  frame.Tabs = Tabs
  PanelTemplates_SetNumTabs(frame, #frame.Tabs)
  containers[1].button:Click()

  frame:SetScript("OnShow", function()
    local tabsWidth = frame.Tabs[#frame.Tabs]:GetRight() - frame.Tabs[1]:GetLeft()
    frame:SetWidth(math.max(frame:GetWidth(), tabsWidth + 20))

    local shownContainer = FindValueInTableIf(containers, function(c) return c:IsShown() end)
    if shownContainer then
      PanelTemplates_SetTab(frame, tIndexOf(containers, shownContainer))
    end
  end)

  frame:Show()

  --addonTable.Skins.AddFrame("ButtonFrame", frame, {"customise"})
end
