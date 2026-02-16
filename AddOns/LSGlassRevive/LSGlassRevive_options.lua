-- LSGlassRevive_options.lua
-- One-column, scrollable, more spacing, and LeftDock settings.

local function Clamp(v, a, b)
  v = tonumber(v) or a
  if v < a then return a end
  if v > b then return b end
  return v
end

local function Apply()
  if LSGlassRevive and LSGlassRevive.ApplyNow then
    LSGlassRevive.ApplyNow()
  end
end

local function TooltipOnEnter(self)
  if not self.tooltipText then return end
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetText(self.tooltipText, 1, 1, 1, 1, true)
  GameTooltip:Show()
end

local function TooltipOnLeave()
  GameTooltip:Hide()
end

local function DecimalsFromStep(step)
  step = tonumber(step) or 1
  if step >= 1 then return 0 end
  if step >= 0.1 then return 1 end
  return 2
end

local function FormatValue(v, step, suffix)
  local d = DecimalsFromStep(step)
  suffix = suffix or ""
  v = tonumber(v) or 0
  return string.format("%." .. d .. "f%s", v, suffix)
end

local function CreateSection(parent, text, x, y)
  local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  fs:SetPoint("TOPLEFT", x, y)
  fs:SetText(text)
  return fs
end

local function CreateCheckbox(parent, label, tooltip, get, set, x, y)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetPoint("TOPLEFT", x, y)

  local fs = cb.Text or cb.text
  if fs then fs:SetText(label) end

  cb.tooltipText = tooltip
  cb:SetScript("OnEnter", TooltipOnEnter)
  cb:SetScript("OnLeave", TooltipOnLeave)

  cb:SetChecked(get() and true or false)

  cb:SetScript("OnClick", function()
    set(cb:GetChecked() and true or false)
    Apply()
  end)

  return cb
end

local function CreateSlider(parent, label, tooltip, minV, maxV, step, get, set, x, y, suffix, width)
  local s = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
  s:SetPoint("TOPLEFT", x, y)
  s:SetMinMaxValues(minV, maxV)
  s:SetValueStep(step)
  s:SetObeyStepOnDrag(true)
  s:SetWidth(width or 380)

  local title = s:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  title:SetPoint("BOTTOMLEFT", s, "TOPLEFT", 0, 6)

  local function RefreshTitle()
    title:SetText(label .. " (" .. FormatValue(s:GetValue(), step, suffix) .. ")")
  end

  s.tooltipText = tooltip
  s:SetScript("OnEnter", TooltipOnEnter)
  s:SetScript("OnLeave", TooltipOnLeave)

  s:SetValue(Clamp(get(), minV, maxV))
  RefreshTitle()

  s:SetScript("OnValueChanged", function(_, val)
    val = Clamp(val, minV, maxV)
    set(val)
    RefreshTitle()
    Apply()
  end)

  return s
end

local function CreateDropdown(parent, label, tooltip, items, get, set, x, y)
  local t = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  t:SetPoint("TOPLEFT", x, y)
  t:SetText(label)

  local dd = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
  dd:SetPoint("TOPLEFT", x - 12, y - 18)
  dd.tooltipText = tooltip

  dd:SetScript("OnEnter", TooltipOnEnter)
  dd:SetScript("OnLeave", TooltipOnLeave)

  local function Refresh()
    local v = get()
    UIDropDownMenu_SetText(dd, items[v] or items.auto or "Auto")
  end

  UIDropDownMenu_Initialize(dd, function(_, level)
    for k, txt in pairs(items) do
      local info = UIDropDownMenu_CreateInfo()
      info.text = txt
      info.checked = (get() == k)
      info.func = function()
        set(k)
        Refresh()
        Apply()
      end
      UIDropDownMenu_AddButton(info, level)
    end
  end)

  UIDropDownMenu_SetWidth(dd, 220)
  Refresh()
  return dd
end

local function BuildPanel()
  if _G.LSGlassReviveOptionsPanel then return end

  local panel = CreateFrame("Frame")
  panel.name = "LSGlassRevive"
  _G.LSGlassReviveOptionsPanel = panel

  panel.default = function()
    if LSGlassRevive and LSGlassRevive.ResetDefaults then
      LSGlassRevive.ResetDefaults()
    end
  end

  local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 0, 0)
  scroll:SetPoint("BOTTOMRIGHT", -30, 0)

  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(650, 2600)
  scroll:SetScrollChild(content)

  panel:EnableMouseWheel(true)
  panel:SetScript("OnMouseWheel", function(_, delta)
    local sb = scroll.ScrollBar
    if not sb then return end
    local step = 80
    local minV, maxV = sb:GetMinMaxValues()
    local v = sb:GetValue() - (delta * step)
    if v < minV then v = minV end
    if v > maxV then v = maxV end
    sb:SetValue(v)
  end)

  local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("LSGlassRevive")

  local sub = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  sub:SetText("Chat settings")

  local x = 16
  local y = -70
  local function Space(px) y = y - (px or 18) end

  CreateSection(content, "General", x, y); Space(32)

  CreateCheckbox(content, "Mouseover reveal", "Affiche onglets/boutons au survol.",
    function() return LSGlassReviveDB.mouseover_reveal end,
    function(v) LSGlassReviveDB.mouseover_reveal = v end, x, y); Space(36)

  CreateCheckbox(content, "Affect Tabs", "Masquer/afficher les onglets.",
    function() return LSGlassReviveDB.affect_tabs end,
    function(v) LSGlassReviveDB.affect_tabs = v end, x, y); Space(36)

  CreateCheckbox(content, "Affect ButtonFrame", "Masquer/afficher les boutons du chat (hors dock).",
    function() return LSGlassReviveDB.affect_buttonframe end,
    function(v) LSGlassReviveDB.affect_buttonframe = v end, x, y); Space(36)

  CreateCheckbox(content, "Affect Scrollbar", "Masquer/afficher la scrollbar.",
    function() return LSGlassReviveDB.affect_scrollbar end,
    function(v) LSGlassReviveDB.affect_scrollbar = v end, x, y); Space(50)

  CreateSection(content, "Fade timings", x, y); Space(30)

  CreateSlider(content, "Hide delay", "Délai avant disparition.", 0, 5.0, 0.01,
    function() return LSGlassReviveDB.hide_delay end,
    function(v) LSGlassReviveDB.hide_delay = v end, x, y, " s"); Space(92)

  CreateSlider(content, "Fade-in time", "Durée d'apparition.", 0.02, 5.0, 0.01,
    function() return LSGlassReviveDB.fade_in_time end,
    function(v) LSGlassReviveDB.fade_in_time = v end, x, y, " s"); Space(92)

  CreateSlider(content, "Fade-out time", "Durée de disparition.", 0.02, 5.0, 0.01,
    function() return LSGlassReviveDB.fade_out_time end,
    function(v) LSGlassReviveDB.fade_out_time = v end, x, y, " s"); Space(92)

  CreateSection(content, "Tabs", x, y); Space(30)

  CreateSlider(content, "Tab out delay", "Délai avant disparition des onglets.", 0, 5.0, 0.01,
    function() return LSGlassReviveDB.tab_out_delay end,
    function(v) LSGlassReviveDB.tab_out_delay = v end, x, y, " s"); Space(92)

  CreateSlider(content, "Tab out multiplier", "Multiplie la durée du fade-out des onglets.", 0.1, 5.0, 0.01,
    function() return LSGlassReviveDB.tab_out_mult end,
    function(v) LSGlassReviveDB.tab_out_mult = v end, x, y, " x"); Space(92)

  CreateSlider(content, "Tab in delay", "Délai avant apparition des onglets.", 0, 5.0, 0.01,
    function() return LSGlassReviveDB.tab_in_delay end,
    function(v) LSGlassReviveDB.tab_in_delay = v end, x, y, " s"); Space(92)

  CreateSlider(content, "Tab in multiplier", "Multiplie la durée du fade-in des onglets.", 0.1, 5.0, 0.01,
    function() return LSGlassReviveDB.tab_in_mult end,
    function(v) LSGlassReviveDB.tab_in_mult = v end, x, y, " x"); Space(100)

  CreateSection(content, "Chat text", x, y); Space(30)

  CreateCheckbox(content, "Chat text fading", "Active le fade des messages.",
    function() return LSGlassReviveDB.chat_text_fade end,
    function(v) LSGlassReviveDB.chat_text_fade = v end, x, y); Space(50)

  CreateSlider(content, "Text visible seconds", "Temps visible des messages.", 1, 60, 1,
    function() return LSGlassReviveDB.chat_text_visible_seconds end,
    function(v) LSGlassReviveDB.chat_text_visible_seconds = v end, x, y, " s"); Space(92)

  CreateSlider(content, "Text fade seconds", "Durée du fade des messages.", 0.1, 10, 0.1,
    function() return LSGlassReviveDB.chat_text_fade_seconds end,
    function(v) LSGlassReviveDB.chat_text_fade_seconds = v end, x, y, " s"); Space(110)

  CreateSection(content, "Left dock (buttons column)", x, y); Space(30)

  CreateCheckbox(content, "Enable Left Dock", "Colonne verticale à gauche de l'onglet General (ChatFrame1).",
    function() return LSGlassReviveDB.enable_left_dock end,
    function(v) LSGlassReviveDB.enable_left_dock = v end, x, y); Space(50)

  CreateSlider(content, "Dock spacing", "Espace entre les boutons du dock.", 0, 20, 1,
    function() return LSGlassReviveDB.dock_spacing end,
    function(v) LSGlassReviveDB.dock_spacing = v end, x, y, ""); Space(92)

  CreateSlider(content, "Dock offset X", "Décalage horizontal (positif = plus d'espace entre tab et dock).", 0, 50, 1,
    function() return LSGlassReviveDB.dock_offset_x end,
    function(v) LSGlassReviveDB.dock_offset_x = v end, x, y, ""); Space(92)

  CreateSlider(content, "Dock offset Y", "Décalage vertical du dock.", -50, 50, 1,
    function() return LSGlassReviveDB.dock_offset_y end,
    function(v) LSGlassReviveDB.dock_offset_y = v end, x, y, ""); Space(110)

  CreateSection(content, "Global buttons behavior (Dock items)", x, y); Space(30)

  CreateCheckbox(content, "Affect Dock/Global Buttons", "Active le fade et les modes Auto/Always/Never sur le dock.",
    function() return LSGlassReviveDB.affect_global_buttons end,
    function(v) LSGlassReviveDB.affect_global_buttons = v end, x, y); Space(60)

  local modes = { auto = "Auto (rules)", always = "Always visible", never = "Always hidden" }

  CreateDropdown(content, "Menu button", "Comportement du bouton menu (bulle).", modes,
    function() return LSGlassReviveDB.global_menu_mode end,
    function(v) LSGlassReviveDB.global_menu_mode = v end, x, y); Space(74)

  CreateDropdown(content, "Channels button", "Comportement du bouton Channels.", modes,
    function() return LSGlassReviveDB.global_channel_mode end,
    function(v) LSGlassReviveDB.global_channel_mode = v end, x, y); Space(74)

  CreateDropdown(content, "Social button", "Comportement du bouton Social/QuickJoin.", modes,
    function() return LSGlassReviveDB.global_social_mode end,
    function(v) LSGlassReviveDB.global_social_mode = v end, x, y); Space(110)

  CreateSection(content, "Copy / Options buttons", x, y); Space(30)

  CreateCheckbox(content, "Enable Copy button (C)", "Affiche le bouton C dans le dock (copie de chat).",
    function() return LSGlassReviveDB.enable_copy_button end,
    function(v) LSGlassReviveDB.enable_copy_button = v end, x, y); Space(36)

  CreateCheckbox(content, "Enable Options button (O)", "Affiche le bouton O dans le dock (options).",
    function() return LSGlassReviveDB.enable_options_button end,
    function(v) LSGlassReviveDB.enable_options_button = v end, x, y); Space(50)

  CreateSlider(content, "Copy max lines", "Nombre max de lignes stockées pour la copie.", 50, 2000, 10,
    function() return LSGlassReviveDB.copy_max_lines end,
    function(v) LSGlassReviveDB.copy_max_lines = v end, x, y, ""); Space(92)

  CreateCheckbox(content, "Strip colors in copy", "Retire les codes de couleur/texture dans la copie.",
    function() return LSGlassReviveDB.copy_strip_colors end,
    function(v) LSGlassReviveDB.copy_strip_colors = v end, x, y); Space(36)

  if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    _G.LSGlassReviveOptionsCategoryID = category:GetID()
  else
    InterfaceOptions_AddCategory(panel)
  end
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:SetScript("OnEvent", function()
  if not LSGlassReviveDB then return end
  BuildPanel()
end)

SLASH_LSGLASSREVIVE1 = "/lgr"
SLASH_LSGLASSREVIVE2 = "/lsglassrevive"
SlashCmdList["LSGLASSREVIVE"] = function()
  BuildPanel()

  if Settings and Settings.OpenToCategory and _G.LSGlassReviveOptionsCategoryID then
    Settings.OpenToCategory(_G.LSGlassReviveOptionsCategoryID)
    return
  end

  if InterfaceOptionsFrame_OpenToCategory and _G.LSGlassReviveOptionsPanel then
    InterfaceOptionsFrame_OpenToCategory(_G.LSGlassReviveOptionsPanel)
    InterfaceOptionsFrame_OpenToCategory(_G.LSGlassReviveOptionsPanel)
    return
  end

  print("|cff00ff00LSGlassRevive:|r Options not ready yet. Try /reload.")
end
