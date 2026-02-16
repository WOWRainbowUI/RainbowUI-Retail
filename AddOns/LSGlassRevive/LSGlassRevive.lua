-- LSGlassRevive.lua (core) - RETAIL 12.0.1
-- Additions:
--  - LeftDock (vertical buttons column) next to ChatFrame1Tab:
--      Social -> Channels -> Minimize -> Copy -> Options -> Menu
--  - Dock respects global button modes (auto/always/never)
--  - Copy/Options reliably persist + are positioned in dock
--  - Options panel compatibility unchanged (handled in options file)
-- Notes:
--  - Dock repositioning is skipped in combat (safety vs taint)
--  - 12.0+ instances can emit "secret string" values in chat: we guard copy history accordingly.

local ADDON = ...

LSGlassRevive = LSGlassRevive or {}

local defaults = {
  mouseover_reveal = true,

  hide_delay = 0.75,
  fade_in_time = 0.55,
  fade_out_time = 0.90,

  -- organic tabs
  tab_out_delay = 0.10,
  tab_out_mult  = 1.00,
  tab_in_delay  = 0.00,
  tab_in_mult   = 1.00,

  -- chat text (messages) fade
  chat_text_fade = true,
  chat_text_visible_seconds = 5,
  chat_text_fade_seconds = 1.5,

  -- toggles
  affect_tabs = true,
  affect_buttonframe = true,
  affect_scrollbar = true,
  affect_global_buttons = true,

  -- global buttons per-element mode: "auto" | "always" | "never"
  global_menu_mode = "auto",
  global_channel_mode = "auto",
  global_social_mode = "auto",

  -- left dock
  enable_left_dock = true,
  dock_spacing = 4,
  dock_inner_x = 0,     -- recentre les boutons sur la plaque
  dock_inner_y = -2,    -- petit ajustement vertical du premier bouton sur la plaque

  -- backward compat (options file still exposes these)
  dock_offset_x = 0,
  dock_offset_y = 0,

  -- copy / options buttons
  enable_copy_button = true,
  enable_options_button = true,

  copy_max_lines = 400,
  copy_strip_colors = true,
}

local function InitDB()
  if not LSGlassReviveDB then LSGlassReviveDB = {} end
  for k, v in pairs(defaults) do
    if LSGlassReviveDB[k] == nil then
      LSGlassReviveDB[k] = v
    end
  end
end

function LSGlassRevive.ResetDefaults()
  InitDB()
  for k, v in pairs(defaults) do
    LSGlassReviveDB[k] = v
  end
  if LSGlassRevive.ApplyNow then
    LSGlassRevive.ApplyNow()
  end
end

local UI = {}         -- per chat frame (soft hide/show)
local UI_GLOBAL = {}  -- dock/global buttons (never hide(), alpha + click)

local function SafeTime(t, fallback)
  t = tonumber(t)
  if not t or t <= 0 then return fallback end
  return t
end

local function FadeRemove(f)
  if UIFrameFadeRemoveFrame then UIFrameFadeRemoveFrame(f) end
end

local function SetMouse(frame, enable)
  if not frame then return end
  if frame.EnableMouse then frame:EnableMouse(enable and true or false) end
  if frame.SetMouseClickEnabled then frame:SetMouseClickEnabled(enable and true or false) end
end

local function SetGlobalMouse(frame, hoverEnable, clickEnable)
  if not frame then return end
  if frame.EnableMouse then frame:EnableMouse(hoverEnable and true or false) end
  if frame.SetMouseClickEnabled then frame:SetMouseClickEnabled(clickEnable and true or false) end
end

-- ========= MENU DETECTION =========

local function IsAnyMenuOpen()
  for i = 1, 3 do
    local dd = _G["DropDownList" .. i]
    if dd and dd:IsShown() then return true end
  end

  local chatDD = _G.ChatFrameTabDropDown
  if chatDD and chatDD.IsShown and chatDD:IsShown() then return true end

  if Menu and Menu.GetManager then
    local mgr = Menu.GetManager()
    if mgr and mgr.IsAnyMenuOpen and mgr:IsAnyMenuOpen() then return true end
  end

  return false
end

-- ========= ACTIVE WINDOWS FILTER =========

local function IsManagedChatWindow(i, cf)
  if not cf then return false end

  if FCF_IsChatWindowIndexActive then
    return FCF_IsChatWindowIndexActive(i)
  end

  if cf.isTemporary then return false end
  if cf.isDocked ~= nil then
    return cf.isDocked or cf:IsShown()
  end
  return cf:IsShown()
end

-- ========= BASIC HELPERS =========

local function AddUI(cf, f)
  if not cf or not f then return end
  UI[cf] = UI[cf] or {}
  table.insert(UI[cf], f)
end

local function AddGlobal(f)
  if not f then return end
  for _, e in ipairs(UI_GLOBAL) do
    if e == f then return end
  end
  table.insert(UI_GLOBAL, f)
end

local function IsChatActiveForChatFrame(cf)
  if not cf then return false end

  if ChatEdit_GetActiveWindow then
    local active = ChatEdit_GetActiveWindow()
    if active and active.chatFrame == cf then
      return true
    end
  end

  local eb = cf.__LSGlassEditBox
  if eb and eb.HasFocus and eb:HasFocus() then
    return true
  end

  return false
end

local function ApplyChatTextFading()
  for i = 1, NUM_CHAT_WINDOWS do
    local cf = _G["ChatFrame" .. i]
    if cf and IsManagedChatWindow(i, cf) then
      cf:SetFading(LSGlassReviveDB.chat_text_fade)
      cf:SetTimeVisible(LSGlassReviveDB.chat_text_visible_seconds)
      cf:SetFadeDuration(LSGlassReviveDB.chat_text_fade_seconds)
    end
  end
end

-- ========= STRIP ART =========

local function StripFrameTextures(frame)
  if not frame or frame.__LSGlassStripped then return end
  frame.__LSGlassStripped = true

  if frame.GetRegions then
    for i = 1, select("#", frame:GetRegions()) do
      local r = select(i, frame:GetRegions())
      if r and r:GetObjectType() == "Texture" then
        r:SetTexture(nil)
        r:SetAtlas(nil)
        r:SetAlpha(0)
        r:Hide()
      end
    end
  end

  if frame.NineSlice then
    frame.NineSlice:SetAlpha(0)
    frame.NineSlice:Hide()
  end
end

local function StripTabArt(tab)
  if not tab or tab.__LSGlassTabArtStripped then return end
  tab.__LSGlassTabArtStripped = true

  local keys = {
    "Left","Middle","Right",
    "ActiveLeft","ActiveMiddle","ActiveRight",
    "HighlightLeft","HighlightMiddle","HighlightRight",
    "LeftTexture","MiddleTexture","RightTexture",
  }
  for _, k in ipairs(keys) do
    local t = tab[k]
    if t and t.SetAlpha and t.Hide then
      t:SetAlpha(0)
      t:Hide()
    end
  end

  local hl = tab.GetHighlightTexture and tab:GetHighlightTexture()
  if hl and hl.SetAlpha and hl.Hide then
    hl:SetAlpha(0)
    hl:Hide()
  end
end

-- ========= GLOBAL BUTTON MODES =========

local function GetSocialButton()
  return _G.ChatFrameSocialButton or _G.QuickJoinToastButton
end

local function GlobalModeKey(btn)
  if btn == _G.ChatFrameMenuButton then return "global_menu_mode" end
  if btn == _G.ChatFrameChannelButton then return "global_channel_mode" end
  if btn == GetSocialButton() then return "global_social_mode" end
  return nil
end

local function GetGlobalMode(btn)
  local k = GlobalModeKey(btn)
  local v = k and LSGlassReviveDB[k] or "auto"
  if v ~= "auto" and v ~= "always" and v ~= "never" then v = "auto" end
  return v
end

local function HardShowGlobal(btn)
  if not btn then return end
  FadeRemove(btn)
  if btn.Show then btn:Show() end
  if btn.SetAlpha then btn:SetAlpha(1) end
  SetGlobalMouse(btn, true, true)
end

local function HardHideGlobal(btn)
  if not btn then return end
  FadeRemove(btn)
  if btn.Show then btn:Show() end
  if btn.SetAlpha then btn:SetAlpha(0) end
  SetGlobalMouse(btn, true, false) -- keep hover, disable click
end

local function FadeGlobalTo(btn, targetAlpha, duration, clickable)
  if not btn then return end
  duration = SafeTime(duration, 0.2)

  FadeRemove(btn)
  if btn.Show then btn:Show() end

  SetGlobalMouse(btn, true, clickable and true or false)

  local fromA = (btn.GetAlpha and btn:GetAlpha()) or (targetAlpha == 1 and 0 or 1)
  if targetAlpha == 1 then
    UIFrameFadeIn(btn, duration, fromA, 1)
  else
    UIFrameFadeOut(btn, duration, fromA, 0)
  end
end

local function SetGlobalButtonState(btn, wantVisible)
  if not btn then return end

  if not LSGlassReviveDB.affect_global_buttons then
    HardShowGlobal(btn)
    return
  end

  local mode = GetGlobalMode(btn)

  if mode == "always" then
    HardShowGlobal(btn)
    return
  end

  if mode == "never" then
    HardHideGlobal(btn)
    return
  end

  if wantVisible then
    FadeGlobalTo(btn, 1, SafeTime(LSGlassReviveDB.fade_in_time, 0.55), true)
  else
    FadeGlobalTo(btn, 0, SafeTime(LSGlassReviveDB.fade_out_time, 0.90), false)
  end
end

local function IsGlobalHovered()
  for _, btn in ipairs(UI_GLOBAL) do
    if btn and btn.IsMouseOver and btn:IsMouseOver() then
      return true
    end
  end
  return false
end

local function AnyChatWantsGlobalVisible()
  if IsAnyMenuOpen() then return true end
  if IsGlobalHovered() then return true end

  for i = 1, NUM_CHAT_WINDOWS do
    local cf = _G["ChatFrame" .. i]
    if cf and IsManagedChatWindow(i, cf) then
      if cf.__LSGlassMenuLock then return true end
      if cf.__LSGlassDesired == "shown" then return true end
    end
  end

  return false
end

local function ShowGlobalChrome()
  for _, btn in ipairs(UI_GLOBAL) do
    SetGlobalButtonState(btn, true)
  end
end

local function HideGlobalChrome()
  for _, btn in ipairs(UI_GLOBAL) do
    SetGlobalButtonState(btn, false)
  end
end

local function CancelGlobalHideTimer()
  if LSGlassRevive.__GlobalHideTimer then
    LSGlassRevive.__GlobalHideTimer:Cancel()
    LSGlassRevive.__GlobalHideTimer = nil
  end
end

local function ScheduleGlobalHide()
  CancelGlobalHideTimer()
  LSGlassRevive.__GlobalHideTimer = C_Timer.NewTimer(SafeTime(LSGlassReviveDB.hide_delay, 0.75), function()
    if AnyChatWantsGlobalVisible() then return end
    HideGlobalChrome()
  end)
end

local function SyncGlobalDesired()
  if AnyChatWantsGlobalVisible() then
    ShowGlobalChrome()
  else
    HideGlobalChrome()
  end
end

-- ========= REAL HOVER =========

local function IsActuallyHovered(cf)
  if not cf then return false end

  if cf.IsMouseOver and cf:IsMouseOver() then return true end

  local tab = cf.__LSGlassTab
  if tab and tab.IsMouseOver and tab:IsMouseOver() then return true end

  if UI[cf] then
    for _, w in ipairs(UI[cf]) do
      if w and w.IsMouseOver and w:IsMouseOver() then
        return true
      end
    end
  end

  if cf == _G.ChatFrame1 and IsGlobalHovered() then
    return true
  end

  return false
end

local function ShouldHideNow(cf)
  if not cf then return false end
  if cf.__LSGlassMenuLock then return false end
  if IsAnyMenuOpen() then return false end
  if IsActuallyHovered(cf) then return false end
  return true
end

-- ========= SOFT FADE (non-global) =========

local function SoftHide(f)
  if not f then return end
  FadeRemove(f)

  local n0 = f.GetName and f:GetName()
  if n0 and n0:match("^ChatFrame%d+Tab$") then return end

  SetMouse(f, false)

  if not f:IsShown() then
    if f.SetAlpha then f:SetAlpha(0) end
    return
  end

  UIFrameFadeOut(f, SafeTime(LSGlassReviveDB.fade_out_time, 0.90), f:GetAlpha() or 1, 0)
end

local function SoftShow(f)
  if not f then return end
  FadeRemove(f)

  local n0 = f.GetName and f:GetName()
  if n0 and n0:match("^ChatFrame%d+Tab$") then return end

  if not f:IsShown() and f.Show then f:Show() end
  if f.SetShown then f:SetShown(true) end
  SetMouse(f, true)

  UIFrameFadeIn(f, SafeTime(LSGlassReviveDB.fade_in_time, 0.55), f:GetAlpha() or 0, 1)
end

-- ========= TABS (never Hide()) =========

local function CancelTabTimers(tab)
  if not tab then return end
  if tab.__LSGlassFadeTimer then
    tab.__LSGlassFadeTimer:Cancel()
    tab.__LSGlassFadeTimer = nil
  end
  if tab.__LSGlassDelayTimer then
    tab.__LSGlassDelayTimer:Cancel()
    tab.__LSGlassDelayTimer = nil
  end
end

local function HardSetTab(tab, alpha, clickable)
  if not tab then return end
  CancelTabTimers(tab)
  FadeRemove(tab)

  tab.__LSGlassFading = false
  tab.__LSGlassTargetAlpha = alpha

  if tab.Show then tab:Show() end
  if tab.EnableMouse then tab:EnableMouse(true) end
  if tab.SetMouseClickEnabled then tab:SetMouseClickEnabled(clickable and true or false) end
  if tab.SetAlpha then tab:SetAlpha(alpha) end
end

local function FadeTabTo(tab, targetAlpha, duration, clickable)
  if not tab then return end
  duration = SafeTime(duration, 0.2)

  if tab.__LSGlassFading and tab.__LSGlassTargetAlpha == targetAlpha then
    return
  end

  CancelTabTimers(tab)
  FadeRemove(tab)

  tab.__LSGlassTargetAlpha = targetAlpha
  tab.__LSGlassFading = true

  if tab.Show then tab:Show() end
  if tab.EnableMouse then tab:EnableMouse(true) end
  if tab.SetMouseClickEnabled then tab:SetMouseClickEnabled(clickable and true or false) end

  local fromA = (tab.GetAlpha and tab:GetAlpha()) or (targetAlpha == 1 and 0 or 1)

  if targetAlpha == 1 then
    UIFrameFadeIn(tab, duration, fromA, 1)
  else
    UIFrameFadeOut(tab, duration, fromA, 0)
  end

  tab.__LSGlassFadeTimer = C_Timer.NewTimer(duration + 0.05, function()
    if not tab then return end
    FadeRemove(tab)
    tab:SetAlpha(targetAlpha)
    tab.__LSGlassFading = false
  end)
end

local function ForceTabInvisible(tab, cf)
  if not tab then return end

  local delay = SafeTime(LSGlassReviveDB.tab_out_delay, 0.10)
  local mult  = SafeTime(LSGlassReviveDB.tab_out_mult, 1.00)
  local dur   = SafeTime(LSGlassReviveDB.fade_out_time, 0.90) * mult

  if tab.__LSGlassTargetAlpha == 0 then return end

  CancelTabTimers(tab)
  tab.__LSGlassDelayTimer = C_Timer.NewTimer(delay, function()
    tab.__LSGlassDelayTimer = nil
    if not tab then return end
    if cf and not ShouldHideNow(cf) then return end
    FadeTabTo(tab, 0, dur, false)
  end)
end

local function ForceTabVisible(tab)
  if not tab then return end

  local delay = SafeTime(LSGlassReviveDB.tab_in_delay, 0.00)
  local mult  = SafeTime(LSGlassReviveDB.tab_in_mult, 1.00)
  local dur   = SafeTime(LSGlassReviveDB.fade_in_time, 0.55) * mult

  CancelTabTimers(tab)
  tab.__LSGlassDelayTimer = C_Timer.NewTimer(delay, function()
    tab.__LSGlassDelayTimer = nil
    if not tab then return end
    FadeTabTo(tab, 1, dur, true)
  end)
end

-- ========= SECRET VALUE GUARD (12.0+) =========
local canaccessvalue = _G.canaccessvalue
local issecretvalue  = _G.issecretvalue

local function CanAccessValue(v)
  if v == nil then return false end
  if canaccessvalue then
    local ok = canaccessvalue(v)
    if ok == false then return false end
  end
  if issecretvalue and issecretvalue(v) then
    return false
  end
  return true
end

-- ========= COPY/PASTE SUPPORT =========

LSGlassRevive.__History = LSGlassRevive.__History or {}

local function CleanForCopy(s)
  if not s or type(s) ~= "string" then return "" end
  if not CanAccessValue(s) then return "" end

  if LSGlassReviveDB and LSGlassReviveDB.copy_strip_colors then
    -- IMPORTANT: use string.gsub (not s:gsub) to avoid indexing secret string values
    s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    s = string.gsub(s, "|T.-|t", "")
  end
  return s
end

local function HookHistory(cf)
  if not cf or cf.__LSGlassHistoryHooked then return end
  cf.__LSGlassHistoryHooked = true

  LSGlassRevive.__History[cf] = LSGlassRevive.__History[cf] or {}

  hooksecurefunc(cf, "AddMessage", function(self, text)
    if not text or type(text) ~= "string" then return end
    if not CanAccessValue(text) then return end

    local ok, cleaned = pcall(CleanForCopy, text)
    if not ok or not cleaned or cleaned == "" then return end

    local h = LSGlassRevive.__History[self]
    if not h then
      h = {}
      LSGlassRevive.__History[self] = h
    end

    h[#h + 1] = cleaned

    local maxL = (LSGlassReviveDB and tonumber(LSGlassReviveDB.copy_max_lines)) or 400
    while #h > maxL do
      table.remove(h, 1)
    end
  end)
end

local function EnsureCopyFrame()
  if LSGlassRevive.__CopyFrame then return LSGlassRevive.__CopyFrame end

  local f = CreateFrame("Frame", "LSGlassReviveCopyFrame", UIParent, "BackdropTemplate")
  f:SetSize(720, 440)
  f:SetPoint("CENTER")
  f:SetFrameStrata("DIALOG")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:Hide()

  f:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
  })

  local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -14)
  title:SetText("LSGlassRevive - Copy Chat")

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -4, -4)

  local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 16, -42)
  scroll:SetPoint("BOTTOMRIGHT", -34, 16)

  local eb = CreateFrame("EditBox", nil, scroll)
  eb:SetMultiLine(true)
  eb:SetAutoFocus(true)
  eb:SetFontObject(ChatFontNormal)
  eb:SetWidth(660)
  eb:SetScript("OnEscapePressed", function() f:Hide() end)

  scroll:SetScrollChild(eb)
  f.EditBox = eb

  LSGlassRevive.__CopyFrame = f
  return f
end

function LSGlassRevive.OpenCopy(cf)
  local f = EnsureCopyFrame()
  local h = (cf and LSGlassRevive.__History and LSGlassRevive.__History[cf]) or {}
  f.EditBox:SetText(table.concat(h, "\n"))
  f:Show()
  f.EditBox:SetFocus()
  f.EditBox:HighlightText()
end

function LSGlassRevive.OpenOptions()
  if Settings and Settings.OpenToCategory and _G.LSGlassReviveOptionsCategoryID then
    Settings.OpenToCategory(_G.LSGlassReviveOptionsCategoryID)
    return
  end

  if InterfaceOptionsFrame_OpenToCategory and _G.LSGlassReviveOptionsPanel then
    InterfaceOptionsFrame_OpenToCategory(_G.LSGlassReviveOptionsPanel)
    InterfaceOptionsFrame_OpenToCategory(_G.LSGlassReviveOptionsPanel)
    return
  end

  if SlashCmdList and SlashCmdList.LSGLASSREVIVE then
    SlashCmdList.LSGLASSREVIVE()
    return
  end

  print("|cffff0000LSGlassRevive: options not ready (try /reload).|r")
end

-- ========= LEFT DOCK (aligned on Blizzard button strip) =========
-- Goal:
--  - Buttons centered on the remaining dark strip (ChatFrame1ButtonFrame)
--  - Only Social is outside the strip (above), still aligned with the column

local function CreateDockButton(parent, label, tooltip, onClick)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(18, 18)
  b:SetText(label)
  b:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)
  b:SetScript("OnClick", onClick)
  return b
end

local function EnsureDockButtons(parentForButtons)
  -- parentForButtons should be the strip frame (ChatFrame1ButtonFrame)
  if not parentForButtons then return nil, nil end

  if LSGlassRevive.__DockCopy and LSGlassRevive.__DockCopy:GetParent() ~= parentForButtons then
    LSGlassRevive.__DockCopy:SetParent(parentForButtons)
  end
  if LSGlassRevive.__DockOpt and LSGlassRevive.__DockOpt:GetParent() ~= parentForButtons then
    LSGlassRevive.__DockOpt:SetParent(parentForButtons)
  end

  if LSGlassReviveDB.enable_copy_button and not LSGlassRevive.__DockCopy then
    LSGlassRevive.__DockCopy = CreateDockButton(parentForButtons, "C", "Copy chat (Ctrl+C)", function()
      LSGlassRevive.OpenCopy(_G.ChatFrame1)
    end)
    AddGlobal(LSGlassRevive.__DockCopy)
  end

  if LSGlassReviveDB.enable_options_button and not LSGlassRevive.__DockOpt then
    LSGlassRevive.__DockOpt = CreateDockButton(parentForButtons, "O", "Open LSGlassRevive options", function()
      LSGlassRevive.OpenOptions()
    end)
    AddGlobal(LSGlassRevive.__DockOpt)
  end

  local copyBtn = (LSGlassReviveDB.enable_copy_button and LSGlassRevive.__DockCopy) or nil
  local optBtn  = (LSGlassReviveDB.enable_options_button and LSGlassRevive.__DockOpt) or nil

  if copyBtn then copyBtn:Show() end
  if optBtn then optBtn:Show() end

  return copyBtn, optBtn
end

local function ShouldIncludeInDock(btn)
  if not btn then return false end
  local k = GlobalModeKey(btn)
  if k and LSGlassReviveDB and LSGlassReviveDB[k] == "never" then
    return false
  end
  return true
end

local function LayoutLeftDock()
  if not LSGlassReviveDB or not LSGlassReviveDB.enable_left_dock then return end
  if InCombatLockdown and InCombatLockdown() then return end

  local bar = _G.ChatFrame1ButtonFrame or (_G.ChatFrame1 and _G.ChatFrame1.ButtonFrame)
  if not bar then return end

  local spacing = tonumber(LSGlassReviveDB.dock_spacing) or 4

  -- inner offsets (preferred)
  local innerX  = tonumber(LSGlassReviveDB.dock_inner_x) or 0
  local innerY  = tonumber(LSGlassReviveDB.dock_inner_y) or -2

  -- backward compat (options still edit these): treat as extra offset
  innerX = innerX + (tonumber(LSGlassReviveDB.dock_offset_x) or 0)
  innerY = innerY + (tonumber(LSGlassReviveDB.dock_offset_y) or 0)

  local social   = GetSocialButton()
  local channels = _G.ChatFrameChannelButton
  local minimize = _G.ChatFrame1ButtonFrameMinimizeButton
  local menu     = _G.ChatFrameMenuButton

  local copyBtn, optBtn = EnsureDockButtons(bar)

  local function AttachToBar(b)
    if not b then return end
    b:ClearAllPoints()
    if b.SetParent and b:GetParent() ~= bar then
      b:SetParent(bar)
    end
    if b.Show then b:Show() end
    b:SetFrameStrata(bar:GetFrameStrata() or "LOW")
    b:SetFrameLevel((bar:GetFrameLevel() or 1) + 15)
  end

  -- Items that must be ON the strip (texture)
  local inside = {}

  if channels and ShouldIncludeInDock(channels) then table.insert(inside, channels) end
  if minimize then table.insert(inside, minimize) end
  if copyBtn then table.insert(inside, copyBtn) end
  if optBtn then table.insert(inside, optBtn) end
  if menu and ShouldIncludeInDock(menu) then table.insert(inside, menu) end

  local prev = nil
  for i, b in ipairs(inside) do
    AttachToBar(b)
    if i == 1 then
      -- Center on the strip width
      b:SetPoint("TOP", bar, "TOP", innerX, innerY)
    else
      b:SetPoint("TOP", prev, "BOTTOM", 0, -spacing)
    end
    prev = b
  end

  -- Social: OUTSIDE the strip, but aligned with the same column + same spacing
  if social and ShouldIncludeInDock(social) then
    social:ClearAllPoints()
    if social.SetParent and social:GetParent() ~= UIParent then
      social:SetParent(UIParent)
    end
    if inside[1] then
      social:SetPoint("BOTTOM", inside[1], "TOP", 0, spacing)
    else
      social:SetPoint("BOTTOM", bar, "TOP", innerX, spacing)
    end
    social:SetFrameStrata(bar:GetFrameStrata() or "LOW")
    social:SetFrameLevel((bar:GetFrameLevel() or 1) + 25)
  end

  -- Ensure hover/fade system knows these are “global”
  AddGlobal(social)
  AddGlobal(channels)
  AddGlobal(menu)
  AddGlobal(copyBtn)
  AddGlobal(optBtn)
  AddGlobal(minimize)
end

-- ========= CORE SHOW/HIDE =========

local function HideChatChrome(cf)
  if not cf then return end
  if cf.__LSGlassMenuLock or IsAnyMenuOpen() then return end

  if cf.SetBackdropColor then cf:SetBackdropColor(0, 0, 0, 0) end
  if cf.SetBackdropBorderColor then cf:SetBackdropBorderColor(0, 0, 0, 0) end
  StripFrameTextures(cf)

  if UI[cf] then
    for _, f2 in ipairs(UI[cf]) do
      SoftHide(f2)
    end
  end

  if cf.__LSGlassTab then
    if IsChatActiveForChatFrame(cf) then
      ForceTabVisible(cf.__LSGlassTab)   -- on garde l’onglet pendant la saisie
    else
      ForceTabInvisible(cf.__LSGlassTab, cf)
    end
  end

  if not IsChatActiveForChatFrame(cf) then
    local eb = cf.__LSGlassEditBox
    if eb then SoftHide(eb) end
  end
end

local function ShowChatChrome(cf)
  if not cf or not UI[cf] then return end

  for _, f2 in ipairs(UI[cf]) do
    SoftShow(f2)
  end

  if cf.__LSGlassTab then
    ForceTabVisible(cf.__LSGlassTab)
  end

  if IsChatActiveForChatFrame(cf) then
    local eb = cf.__LSGlassEditBox
    if eb then
      if eb.Show then eb:Show() end
      if eb.SetAlpha then eb:SetAlpha(1) end
      FadeRemove(eb)
    end
  end
end

local function CancelHideTimer(cf)
  if cf and cf.__LSGlassHideTimer then
    cf.__LSGlassHideTimer:Cancel()
    cf.__LSGlassHideTimer = nil
  end
end

local function ScheduleHide(cf)
  if not cf then return end
  CancelHideTimer(cf)

  cf.__LSGlassHideTimer = C_Timer.NewTimer(SafeTime(LSGlassReviveDB.hide_delay, 0.75), function()
    if not cf then return end
    if ShouldHideNow(cf) then
      HideChatChrome(cf)
    end
  end)
end

-- ========= UI COLLECTION =========

local function CollectGlobalUI()
  -- global list used for hover + fading (even if dock is enabled)
  AddGlobal(_G.ChatFrameMenuButton)
  AddGlobal(_G.ChatFrameChannelButton)
  AddGlobal(GetSocialButton())

  for _, btn in ipairs(UI_GLOBAL) do
    if btn and btn.Show then btn:Show() end
  end

  for _, btn in ipairs(UI_GLOBAL) do
    if btn and btn.HookScript and not btn.__LSGlassGlobalHoverHooked then
      btn.__LSGlassGlobalHoverHooked = true

      btn:HookScript("OnEnter", function()
        if not LSGlassReviveDB.mouseover_reveal then return end
        CancelGlobalHideTimer()
        ShowGlobalChrome()

        local cf1 = _G.ChatFrame1
        if cf1 then
          CancelHideTimer(cf1)
          ShowChatChrome(cf1)
        end
      end)

      btn:HookScript("OnLeave", function()
        if not LSGlassReviveDB.mouseover_reveal then return end
        ScheduleGlobalHide()

        local cf1 = _G.ChatFrame1
        if cf1 and not cf1.__LSGlassMenuLock then
          ScheduleHide(cf1)
        end
      end)
    end
  end
end

local function CollectUIForChatFrame(cf)
  if not cf then return end
  local name = cf:GetName()

  UI[cf] = {}

  if LSGlassReviveDB.affect_buttonframe then
    AddUI(cf, cf.ButtonFrame)
    AddUI(cf, _G[name .. "ButtonFrame"])
    AddUI(cf, _G[name .. "ButtonFrameUpButton"])
    AddUI(cf, _G[name .. "ButtonFrameDownButton"])
    AddUI(cf, _G[name .. "ButtonFrameBottomButton"])
  end

  if LSGlassReviveDB.affect_scrollbar then
    AddUI(cf, cf.ScrollBar)
    AddUI(cf, _G[name .. "ScrollBar"])
    AddUI(cf, _G[name .. "ScrollToBottomButton"])
  end

  if LSGlassReviveDB.affect_tabs then
    local tab = _G[name .. "Tab"]
    if tab then
      tab:EnableMouse(true)
      AddUI(cf, tab)
      cf.__LSGlassTab = tab

      StripTabArt(tab)

      if not tab.__LSGlassHardHooked then
        tab.__LSGlassHardHooked = true

        hooksecurefunc(tab, "Show", function(t)
          if not t or not cf then return end
          if ShouldHideNow(cf) then
            ForceTabInvisible(t, cf)
          end
        end)

        hooksecurefunc(tab, "SetAlpha", function(t, a)
          if not t or not a or not cf then return end
          if a >= 0.95 and ShouldHideNow(cf) then
            ForceTabInvisible(t, cf)
          end
        end)
      end

      if not tab.__LSGlassMouseDownHooked then
        tab.__LSGlassMouseDownHooked = true
        tab:HookScript("OnMouseDown", function(_, button)
          if button == "RightButton" then
            cf.__LSGlassMenuLock = true
            CancelHideTimer(cf)
            ShowChatChrome(cf)
            ForceTabVisible(tab)
            ShowGlobalChrome()
          end
        end)
      end
    end
  end

  cf.__LSGlassEditBox = cf.editBox or cf.EditBox or _G[name .. "EditBox"]
end

-- ========= HOVER HOOKS =========

local function HookHoverForFrame(cf, hoverFrame)
  if not cf or not hoverFrame then return end
  if hoverFrame.__LSGlassHoverHooked then return end
  hoverFrame.__LSGlassHoverHooked = true

  hoverFrame:HookScript("OnEnter", function()
    if not LSGlassReviveDB.mouseover_reveal then return end
    CancelHideTimer(cf)
    ShowChatChrome(cf)
    SyncGlobalDesired()
  end)

  hoverFrame:HookScript("OnLeave", function()
    if not LSGlassReviveDB.mouseover_reveal then return end
    if cf.__LSGlassMenuLock then return end
    ScheduleHide(cf)
    ScheduleGlobalHide()
  end)
end

local function HookMouseover(cf)
  if cf.__LSGlassHooked then return end
  cf.__LSGlassHooked = true

  HookHoverForFrame(cf, cf)

  if UI[cf] then
    for _, w in ipairs(UI[cf]) do
      if w and w.HookScript then
        HookHoverForFrame(cf, w)
      end
    end
  end
end

-- ========= APPLY =========

local function SetDesiredState(cf, wantVisible)
  if not cf then return end
  local state = wantVisible and "shown" or "hidden"
  if cf.__LSGlassDesired == state then return end
  cf.__LSGlassDesired = state

  if wantVisible then
    ShowChatChrome(cf)
  else
    HideChatChrome(cf)
  end
end

local __Applying = false
local function ApplyAll()
  if __Applying then return end
  __Applying = true

  CollectGlobalUI()

  for i = 1, NUM_CHAT_WINDOWS do
    local cf = _G["ChatFrame" .. i]
    if cf and IsManagedChatWindow(i, cf) then
      CollectUIForChatFrame(cf)
      HookHistory(cf)
      HookMouseover(cf)
      cf.__LSGlassDesired = nil
      SetDesiredState(cf, not ShouldHideNow(cf))
    end
  end

  ApplyChatTextFading()
  LayoutLeftDock()
  SyncGlobalDesired()

  __Applying = false
end

local function Reapply()
  C_Timer.After(0.2, function() ApplyAll() end)
  C_Timer.After(1.0, function() ApplyAll() end)
  C_Timer.After(3.0, function() ApplyAll() end)
end

-- ========= WATCHERS =========

local function StartMenuWatcher()
  if LSGlassRevive.__MenuWatcherStarted then return end
  LSGlassRevive.__MenuWatcherStarted = true

  C_Timer.NewTicker(0.10, function()
    if IsAnyMenuOpen() then return end

    for i = 1, NUM_CHAT_WINDOWS do
      local cf = _G["ChatFrame" .. i]
      if cf and IsManagedChatWindow(i, cf) and cf.__LSGlassMenuLock then
        cf.__LSGlassMenuLock = false
        if ShouldHideNow(cf) then
          ScheduleHide(cf)
        end
      end
    end

    SyncGlobalDesired()
  end)
end

local function StartEditBoxWatcher()
  if LSGlassRevive.__EditWatcherStarted then return end
  LSGlassRevive.__EditWatcherStarted = true

  C_Timer.NewTicker(0.10, function()
    for i = 1, NUM_CHAT_WINDOWS do
      local cf = _G["ChatFrame" .. i]
      if cf and IsManagedChatWindow(i, cf) then
        local eb = cf.__LSGlassEditBox
        if eb and eb.IsShown and eb:IsShown() then
          local active = IsChatActiveForChatFrame(cf)
          local focused = (eb.HasFocus and eb:HasFocus()) or false
          if not active and not focused then
            SoftHide(eb)
          end
        end
      end
    end
  end)
end

local function StartTabWatchdog()
  if LSGlassRevive.__TabWatchdogStarted then return end
  LSGlassRevive.__TabWatchdogStarted = true

  C_Timer.NewTicker(0.10, function()
    if IsAnyMenuOpen() then return end

    for i = 1, NUM_CHAT_WINDOWS do
      local cf = _G["ChatFrame" .. i]
      if cf and IsManagedChatWindow(i, cf) and cf.__LSGlassTab and not cf.__LSGlassMenuLock then
        local tab = cf.__LSGlassTab
        if ShouldHideNow(cf) then
          if tab.__LSGlassTargetAlpha ~= 0 then
            ForceTabInvisible(tab, cf)
          else
            local a = (tab.GetAlpha and tab:GetAlpha()) or 1
            if (not tab.__LSGlassFading) and a > 0.01 then
              HardSetTab(tab, 0, false)
            end
          end
        end
      end
    end
  end)
end

local function StartSyncWatchdog()
  if LSGlassRevive.__SyncWatchdogStarted then return end
  LSGlassRevive.__SyncWatchdogStarted = true

  C_Timer.NewTicker(0.10, function()
    if IsAnyMenuOpen() then return end

    for i = 1, NUM_CHAT_WINDOWS do
      local cf = _G["ChatFrame" .. i]
      if cf and IsManagedChatWindow(i, cf) and not cf.__LSGlassMenuLock then
        SetDesiredState(cf, not ShouldHideNow(cf))
      end
    end

    LayoutLeftDock()
    SyncGlobalDesired()
  end)
end

-- ========= PUBLIC =========

function LSGlassRevive.ApplyNow()
  ApplyAll()
  Reapply()
end

function LSGlassRevive.ResetChatWindows()
  if FCF_ResetChatWindows then
    FCF_ResetChatWindows()
    C_Timer.After(0.1, function()
      ApplyAll()
      Reapply()
    end)
  end
end

-- ========= EVENTS =========

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
f:RegisterEvent("UI_SCALE_CHANGED")

f:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON then
    InitDB()
    return
  end

  if event == "PLAYER_LOGIN"
    or event == "PLAYER_ENTERING_WORLD"
    or event == "EDIT_MODE_LAYOUTS_UPDATED"
    or event == "UI_SCALE_CHANGED"
  then
    InitDB()
    ApplyAll()
    Reapply()
    StartMenuWatcher()
    StartEditBoxWatcher()
    StartTabWatchdog()
    StartSyncWatchdog()
  end
end)

hooksecurefunc("FCF_OpenNewWindow", function() ApplyAll(); Reapply() end)
hooksecurefunc("FCF_ResetChatWindows", function() ApplyAll(); Reapply() end)

-- ========= CHAT EDITBOX HOOKS =========

hooksecurefunc("ChatEdit_ActivateChat", function(eb)
  if not eb then return end
  local cf = eb.chatFrame
  if not cf then return end

  CancelHideTimer(cf)
  -- On ne révèle pas tout : on laisse juste l'editbox (et l'onglet via HideChatChrome modifié)
  HideChatChrome(cf)
  SyncGlobalDesired()

  cf.__LSGlassEditBox = eb

  if eb.Show then eb:Show() end
  if eb.SetAlpha then eb:SetAlpha(1) end
  FadeRemove(eb)
end)

local function RehideAllChatsSoon()
  local function Do()
    for i = 1, NUM_CHAT_WINDOWS do
      local cf = _G["ChatFrame" .. i]
      if cf and IsManagedChatWindow(i, cf) and ShouldHideNow(cf) then
        HideChatChrome(cf)
        ScheduleHide(cf)
      end
    end
    ScheduleGlobalHide()
  end
  C_Timer.After(0, Do)
  C_Timer.After(0.05, Do)
end

hooksecurefunc("ChatEdit_DeactivateChat", function(_) RehideAllChatsSoon() end)
hooksecurefunc("ChatEdit_SendText", function(_) RehideAllChatsSoon() end)

-- ========= SLASH =========

SLASH_LSGLASSAPPLY1 = "/lsglass"
SlashCmdList.LSGLASSAPPLY = function()
  LSGlassRevive.ApplyNow()
  print("|cff00ff00LSGlassRevive: reapplied.|r")
end

SLASH_LSGLASSRESET1 = "/lsglassreset"
SlashCmdList.LSGLASSRESET = function()
  LSGlassRevive.ResetChatWindows()
  print("|cff00ff00LSGlassRevive: chat windows reset + reapplied.|r")
end

SLASH_LSGLASSCOPY1 = "/lsgcopy"
SlashCmdList.LSGLASSCOPY = function()
  LSGlassRevive.OpenCopy(_G.ChatFrame1)
end
