local addonName, addon = ...
local spellBarHookSet = false
local stanceBarHookSet = false

local function handleTargetFrameSpellBar_OnUpdate(self, arg1, ...)
  if BUIIDatabase["castbar_on_top"] then
    self:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", 45, 20)
  end
end

local function handleFocusFrameSpellBar_OnUpdate(self, arg1, ...)
  if BUIIDatabase["castbar_on_top"] then
    if FocusFrame.smallSize then
      self:SetPoint("TOPLEFT", FocusFrame, "TOPLEFT", 38, 20)
    else
      self:SetPoint("TOPLEFT", FocusFrame, "TOPLEFT", 45, 20)
    end
  end
end

local function setPlayerClassColor()
  local _, const_class = UnitClass("player");
  local r, g, b = GetClassColor(const_class)
  local playerHealthBar;

  if PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea ~= nil then
    playerHealthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.HealthBar
  else
    playerHealthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar
  end

  if _G["BUIIOptionsPanelHealthClassColor"]:GetChecked() then
    playerHealthBar:SetStatusBarDesaturated(true)
    playerHealthBar:SetStatusBarColor(r, g, b)
    BUIIDatabase["class_color"] = true
  else
    playerHealthBar:SetStatusBarDesaturated(false)
    playerHealthBar:SetStatusBarColor(1, 1, 1)
    BUIIDatabase["class_color"] = false
  end
end

local function setCastBarOnTop(setOnTop)
  if setOnTop then
    if not spellBarHookSet then
      TargetFrameSpellBar:HookScript("OnUpdate", handleTargetFrameSpellBar_OnUpdate)
      FocusFrameSpellBar:HookScript("OnUpdate", handleFocusFrameSpellBar_OnUpdate)
      spellBarHookSet = true
    end
    BUIIDatabase["castbar_on_top"] = true
  else
    BUIIDatabase["castbar_on_top"] = false
  end
end

local function setSaneBagSorting(setSane)
  if setSane then
    C_Container.SetSortBagsRightToLeft(true)
    C_Container.SetInsertItemsLeftToRight(false)
    BUIIDatabase["sane_bag_sort"] = true
  else
    C_Container.SetSortBagsRightToLeft(false)
    C_Container.SetInsertItemsLeftToRight(false)
    BUIIDatabase["sane_bag_sort"] = false
  end
end

local function stanceBar_OnUpdate()
  if BUIICharacterDatabase["hide_stance_bar"] then
    local point, _, relativePoint, xOffset, yOffset = StanceBar:GetPoint()
    if point ~= "TOPLEFT" or
        relativePoint ~= "TOPLEFT" or
        math.ceil(xOffset) ~= math.ceil(0 - (StanceBar:GetWidth() + 100)) or
        yOffset ~= 0 then
      StanceBar:ClearAllPoints()
      StanceBar:SetClampedToScreen(false)
      StanceBar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", math.ceil(0 - (StanceBar:GetWidth() + 100)), 0)
    end
  end
end

local function setHideStanceBar(shouldHide)
  if shouldHide then
    local point, _, relativePoint, xOffset, yOffset = StanceBar:GetPoint()
    BUIICharacterDatabase["stance_bar_position"] = {
      point = point,
      relativeTo = nil,
      relativePoint = relativePoint,
      xOffset = xOffset,
      yOffset = yOffset,
    }

    -- The StanceBar gets tainted if we just hide it (It also can't be hidden in combat)
    -- so we just chuck it outside the screen to hide it
    BUIICharacterDatabase["hide_stance_bar"] = shouldHide
    StanceBar:ClearAllPoints()
    StanceBar:SetClampedToScreen(false)
    StanceBar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", math.ceil(0 - (StanceBar:GetWidth() + 100)), 0)
    if not stanceBarHookSet then
      StanceBar:HookScript("OnUpdate", stanceBar_OnUpdate)
      stanceBarHookSet = true
    end
  else
    BUIICharacterDatabase["hide_stance_bar"] = shouldHide
    StanceBar:ClearAllPoints()
    StanceBar:SetClampedToScreen(true)
    StanceBar:SetPoint(BUIICharacterDatabase["stance_bar_position"]["point"],
      UIParent,
      BUIICharacterDatabase["stance_bar_position"]["relativePoint"],
      BUIICharacterDatabase["stance_bar_position"]["xOffset"],
      BUIICharacterDatabase["stance_bar_position"]["yOffset"]
    )
  end
end

local function showPlayerCastBarIcon(shouldShow)
  if shouldShow then
    local point, relativeTo, relativePoint = PlayerCastingBarFrame.Icon:GetPoint()
    PlayerCastingBarFrame.Icon:SetSize(36, 36) -- 圖示大小
    PlayerCastingBarFrame.Icon:SetPoint(point, relativeTo, relativePoint, -5, -6) -- 圖示位置
    PlayerCastingBarFrame.Icon:Show()
    BUIIDatabase["castbar_icon"] = true
  else
    PlayerCastingBarFrame.Icon:Hide()
    BUIIDatabase["castbar_icon"] = false
  end
end

local function editMode_OnExit()
  if BUIICharacterDatabase["hide_stance_bar"] then
    StanceBar:ClearAllPoints()
    StanceBar:SetClampedToScreen(false)
    StanceBar:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0 - (StanceBar:GetWidth() + 100), 0)
  end
  
	-- 自行加入，修正編輯模式結束施法條圖示會消失
	if BUIIDatabase["castbar_icon"] then
		showPlayerCastBarIcon(true)										
	end
end

local function handleUnitFramePortraitUpdate(self)
  local healthBar = self.HealthBar

  if self.unit == "player" then
    -- If we're in a vehicle we want to color the pet frame instead
    -- as that's where the player will be
    if UnitInVehicle(self.unit) then
      healthBar = PetFrameHealthBar
    else
      if PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea ~= nil then
        healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.HealthBar
      else
        healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBar
      end
    end
  elseif self.unit == "pet" then
    healthBar = PetFrameHealthBar
  elseif self.unit == "target" then
    if TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar ~= nil then
      healthBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBar
    else
      healthBar = TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    end
  elseif self.unit == "focus" then
    if FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBar ~= nil then
      healthBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBar
    else
      healthBar = FocusFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    end
  elseif self.unit == "vehicle" then
    if PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea ~= nil then
      healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarArea.HealthBar
    else
      healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBar
    end
  end

  -- If we've reached this point and healthBar isn't valid bail out
  if not healthBar then
    return
  end

  if UnitIsPlayer(self.unit) and UnitIsConnected(self.unit) and BUIIDatabase["class_color"] then
    local _, const_class = UnitClass(self.unit);
    local r, g, b = GetClassColor(const_class)
    healthBar:SetStatusBarDesaturated(true)
    healthBar:SetStatusBarColor(r, g, b)
  elseif UnitIsPlayer(self.unit) and not UnitIsConnected(self.unit) then
    healthBar:SetStatusBarDesaturated(true)
    healthBar:SetStatusBarColor(1, 1, 1)
  elseif BUIIDatabase["class_color"] then
    healthBar:SetStatusBarDesaturated(true)
    healthBar:SetStatusBarColor(0, 1, 0)
  else
    healthBar:SetStatusBarDesaturated(false)
    healthBar:SetStatusBarColor(1, 1, 1)
  end
end

function BUII_OnLoadHandler(self)
  self:RegisterEvent("ADDON_LOADED")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED") -- 自行加入，修正切換專精後施法條圖示會消失
  EventRegistry:RegisterCallback("EditMode.Exit", editMode_OnExit, "BUII_Improvements_OnExit")

  self.name = "介面增強"
  if InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(self)
  else
    local category, layout = Settings.RegisterCanvasLayoutCategory(self, self.name);
    category.ID = self.name
    Settings.RegisterAddOnCategory(category);
    addon.settingsCategory = category
  end
end

function BUII_OnEventHandler(self, event, arg1, ...)
  if event == "ADDON_LOADED" and arg1 == "BravosUIImprovements" then
    if BUIIDatabase == nil then
      BUIIDatabase = {}
      BUIIDatabase["class_color"] = false
      BUIIDatabase["castbar_timers"] = true
      BUIIDatabase["castbar_icon"] = true
      BUIIDatabase["castbar_on_top"] = false
      BUIIDatabase["sane_bag_sort"] = false
      BUIIDatabase["quick_keybind_shortcut"] = false
      BUIIDatabase["improved_edit_mode"] = false
      BUIIDatabase["tooltip_expansion"] = false
      BUIIDatabase["queue_status_button_position"] = {
        point = "BOTTOMRIGHT",
        relativeTo = nil,
        relativePoint = "BOTTOMRIGHT",
        xOffset = 0,
        yOffset = 0,
      }
    end

    if BUIICharacterDatabase == nil then
      BUIICharacterDatabase = {}
      BUIICharacterDatabase["hide_stance_bar"] = false
      local point, _, relativePoint, xOffset, yOffset = StanceBar:GetPoint()
      BUIICharacterDatabase["stance_bar_position"] = {
        point = point,
        relativeTo = nil,
        relativePoint = relativePoint,
        xOffset = xOffset,
        yOffset = yOffset,
      }
    end

    self:UnregisterEvent("ADDON_LOADED")
  elseif event == "PLAYER_ENTERING_WORLD" then
	if BUIIDatabase["class_color"] then
      _G["BUIIOptionsPanelHealthClassColor"]:SetChecked(true)
      setPlayerClassColor()
    end

    if BUIIDatabase["castbar_timers"] then
      BUII_CastBarTimersEnable()
      _G["BUIIOptionsPanelCastBarTimers"]:SetChecked(true)
    end

    if BUIIDatabase["castbar_icon"] then
      showPlayerCastBarIcon(true)
      _G["BUIIOptionsPanelCastBarIcon"]:SetChecked(true)
    end

    if BUIIDatabase["castbar_on_top"] then
      setCastBarOnTop(true)
      _G["BUIIOptionsPanelCastBarOnTop"]:SetChecked(true)
    end

    if BUIIDatabase["sane_bag_sort"] then
      setSaneBagSorting(true)
      _G["BUIIOptionsPanelSaneCombinedBagSorting"]:SetChecked(true)
    end

    if BUIICharacterDatabase["hide_stance_bar"] then
      setHideStanceBar(true)
      _G["BUIIOptionsPanelHideStanceBar"]:SetChecked(true)
    end

    if BUIIDatabase["improved_edit_mode"] then
      BUII_ImprovedEditModeEnable()
      _G["BUIIOptionsPanelImprovedEditMode"]:SetChecked(true)
    end

    if BUIIDatabase["tooltip_expansion"] then
      BUII_TooltipImprovements_Enabled()
      _G["BUIIOptionsPanelTooltipExpansion"]:SetChecked(true)
    end
  elseif event == "PLAYER_SPECIALIZATION_CHANGED" then -- 自行加入，修正切換專精後施法條圖示會消失
	if BUIIDatabase["castbar_icon"] then
		showPlayerCastBarIcon(true)
	end
  end
end

function BUII_HealthClassColorCheckButton_OnClick(self)
  setPlayerClassColor()
end

function BUII_CastBarTimersCheckButton_OnClick(self)
  if self:GetChecked() then
    BUII_CastBarTimersEnable()
    BUIIDatabase["castbar_timers"] = true
  else
    BUII_CastBarTimersDisable()
    BUIIDatabase["castbar_timers"] = false
  end
end

function BUII_CastBarIconCheckButton_OnClick(self)
  if self:GetChecked() then
    showPlayerCastBarIcon(true)
  else
    showPlayerCastBarIcon(false)
  end
end

function BUII_CastBarOnTopCheckButton_OnClick(self)
  if self:GetChecked() then
    setCastBarOnTop(true)
  else
    setCastBarOnTop(false)
  end
end

function BUII_SaneCombinedBagSortingCheckButton_OnClick(self)
  setSaneBagSorting(self:GetChecked())
end

function BUII_HideStanceBar_OnClick(self)
  setHideStanceBar(self:GetChecked())
end

function BUII_QuickKeybindShortcut_OnClick(self)
  if self:GetChecked() then
    BUII_QuickKeybindModeShortcutEnable()
    BUIIDatabase["quick_keybind_shortcut"] = true
  else
    BUII_QuickKeybindModeShortcutDisable()
    BUIIDatabase["quick_keybind_shortcut"] = false
  end
end

function BUII_ImprovedEditMode_OnClick(self)
  if self:GetChecked() then
    BUII_ImprovedEditModeEnable()
    BUIIDatabase["improved_edit_mode"] = true
  else
    BUII_ImprovedEditModeDisable()
    BUIIDatabase["improved_edit_mode"] = false
  end
end

function BUII_TooltipExpansion_OnClick(self)
  if self:GetChecked() then
    BUII_TooltipImprovements_Enabled()
    BUIIDatabase["tooltip_expansion"] = true
  else
    BUII_TooltipImprovements_Disable()
    BUIIDatabase["tooltip_expansion"] = false
  end
end
