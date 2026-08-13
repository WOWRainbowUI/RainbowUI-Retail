local folderName, Addon = ...

-- Locals for frequently used global frames and functions.
local GameTooltip_AddBlankLineToTooltip  = _G.GameTooltip_AddBlankLineToTooltip
local GameTooltip_AddErrorLine           = _G.GameTooltip_AddErrorLine
local GameTooltip_AddInstructionLine     = _G.GameTooltip_AddInstructionLine
local GameTooltip_AddNormalLine          = _G.GameTooltip_AddNormalLine
local GameTooltip_SetTitle               = _G.GameTooltip_SetTitle


local started = false

local history = {}

local goingBackFlag = false

local lastCategoryChangeTime = GetTime()
local lastCategoryID = nil
local lastCategoryScrollPosition = nil
local lastCategoryCollapseState = {}

local lastAchievementChangeTime = GetTime()
local lastAchievementID = nil
local lastAchievementScrollPosition = nil

-- Retail only. The Achievements, Guild and Statistics tabs each have their own
-- category list and their own selected category, so a stored category is
-- meaningless without the tab it belongs to. Blizzard keeps the same kind of
-- per tab bookkeeping in its local g_categorySelections.
local ACHIEVEMENTS_TAB = 1

local lastTabIndex = nil
local lastCategoryIDPerTab = {}
local lastAchievementIDPerTab = {}

local backButton = nil

-- Blizzard's own back button, added in 12.1.0 (retail only).
local blizzardBackButton = nil
local blizzardBackButtonOriginalOnClick = nil

-- Only true while Blizzard's back button exists, i.e. while there is
-- anything to choose from in the options menu.
local hasOptionsMenu = false

-- The texture we replaced Blizzard's removed Header.LeftDDLInset with.
local leftDDLInset = nil

local BUTTON_TEXTURE_UP       = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up"
local BUTTON_TEXTURE_DOWN     = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down"
local BUTTON_TEXTURE_DISABLED = "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled"


local function IsComparison()
  return AchievementFrame_IsComparison and AchievementFrame_IsComparison() or false
end



-- ####################################################################
-- ### Tooltips
-- ####################################################################

local function BackButtonEnterFunction(button, anchor)
  GameTooltip:SetOwner(button, anchor or "ANCHOR_TOP")
  GameTooltip_SetTitle(GameTooltip, BACK)
  GameTooltip_AddNormalLine(GameTooltip, "Return to the previously viewed achievement or category.")
  if next(history) == nil then
    GameTooltip_AddErrorLine(GameTooltip, "(Nothing to go back to yet.)")
  end
  if hasOptionsMenu then
    GameTooltip_AddBlankLineToTooltip(GameTooltip)
    GameTooltip_AddInstructionLine(GameTooltip, "Right-click for options.")
  end
  GameTooltip:Show()
end


-- Keep an open tooltip up to date while its button changes state.
local function RefreshBackButtonTooltip()
  local owner = GameTooltip:GetOwner()
  if backButton and owner == backButton then
    BackButtonEnterFunction(backButton, "ANCHOR_TOP")
  elseif blizzardBackButton and owner == blizzardBackButton
         and Addon.GetMode() == Addon.MODE_REPLACE_BLIZZARD then
    BackButtonEnterFunction(blizzardBackButton, "ANCHOR_RIGHT")
  end
end



-- ####################################################################
-- ### Back button state
-- ####################################################################

-- Both buttons are always enabled, so that right-clicks still open the options
-- menu while there is nothing to go back to. We only let them appear disabled.
-- This is what UIPanelButton_OnEnable() / UIPanelButton_OnDisable() do.
local UIPANEL_TEXTURE_UP       = "Interface\\Buttons\\UI-Panel-Button-Up"
local UIPANEL_TEXTURE_DISABLED = "Interface\\Buttons\\UI-Panel-Button-Disabled"

local function RefreshBlizzardBackButtonLook()
  if not blizzardBackButton then return end

  local appearsEnabled
  if Addon.GetMode() == Addon.MODE_REPLACE_BLIZZARD then
    -- The button runs on our history now, so it is greyed out by our history.
    appearsEnabled = next(history) ~= nil
  else
    -- Blizzard is in charge, we only mirror whatever it decided.
    appearsEnabled = blizzardBackButton:IsEnabled()
  end

  local texture = appearsEnabled and UIPANEL_TEXTURE_UP or UIPANEL_TEXTURE_DISABLED
  blizzardBackButton.Left:SetTexture(texture)
  blizzardBackButton.Middle:SetTexture(texture)
  blizzardBackButton.Right:SetTexture(texture)
  blizzardBackButton:GetFontString():SetFontObject(appearsEnabled and GameFontNormal or GameFontDisable)
  blizzardBackButton:GetHighlightTexture():SetShown(appearsEnabled)
end


Addon.UpdateBackButtons = function()
  local hasHistory = next(history) ~= nil

  if backButton then
    if hasHistory then
      backButton:SetNormalTexture(BUTTON_TEXTURE_UP)
      backButton:SetPushedTexture(BUTTON_TEXTURE_DOWN)
      backButton:GetHighlightTexture():Show()
    else
      backButton:SetNormalTexture(BUTTON_TEXTURE_DISABLED)
      backButton:SetPushedTexture(BUTTON_TEXTURE_DISABLED)
      backButton:GetHighlightTexture():Hide()
    end
  end

  RefreshBlizzardBackButtonLook()
  RefreshBackButtonTooltip()
end



local function AchievmentsBack()

  if next(history) == nil then
    return
  end

  -- Prevent storing when going back.
  goingBackFlag = true

  local storedState = tremove(history)

  -- Read by index instead of through unpack(), because a nil tab index on
  -- Wrath, Cata and Mists would cut the unpacked list short.
  local storedTabIndex = storedState[10]

  -- Titles and category parent not needed yet. Maybe later for history drop down...
  local _, storedAchievementID, _, storedCategoryID, _, _, storedAchievementsScrollPosition, storedCategoriesScrollPosition, storedCategoryCollapseState = unpack(storedState)

  -- for k, v in pairs(history) do
    -- print("  ", k, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
  -- end


  -- ####################################################################
  -- ### Wrath, Cata
  -- ####################################################################
  if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then

    -- Set category, which is also needed for the right window.
    achievementFunctions.selectedCategory = storedCategoryID

    -- Update the right window.
    if storedCategoryID == "summary" then
      AchievementFrame_ShowSubFrame(AchievementFrameSummary)
    else
      AchievementFrameAchievements_Update()
    end

    if storedAchievementID then
      AchievementFrame_SelectAchievement(storedAchievementID)
    end

    -- Update the left window including collapse states.
    if type(storedCategoryCollapseState) == "table" then
      for j, category in pairs(ACHIEVEMENTUI_CATEGORIES) do
        if storedCategoryCollapseState[category.id] then
          category.collapsed = storedCategoryCollapseState[category.id].collapsed
          category.hidden = storedCategoryCollapseState[category.id].hidden
        end
      end

    end
    AchievementFrameCategories_Update()

    -- Update scroll positions.
    if storedCategoriesScrollPosition ~= nil then
      -- print("Setting storedCategoriesScrollPosition", storedCategoriesScrollPosition)
      AchievementFrameCategoriesContainer.scrollBar:SetValue(storedCategoriesScrollPosition)
    end
    if storedAchievementsScrollPosition ~= nil then
      -- print("Setting storedAchievementsScrollPosition", storedAchievementsScrollPosition)
      AchievementFrameAchievementsContainer.scrollBar:SetValue(storedAchievementsScrollPosition)
    end


  -- ####################################################################
  -- ### Retail
  -- ####################################################################
  else

    -- Each tab has its own category list, so the tab has to be restored first
    -- or the category below would be looked up in the wrong list and silently
    -- not be found.
    if storedTabIndex and storedTabIndex ~= AchievementFrame.selectedTab and not IsComparison() then
      local tab = _G["AchievementFrameTab" .. storedTabIndex]
      -- The guild tab is not always there.
      if tab and tab:IsShown() then
        AchievementFrameTab_OnClick(storedTabIndex)
      end
    end

    -- Left side pane and right window are both updated by this.
    AchievementFrame_UpdateAndSelectCategory(storedCategoryID)

    if storedAchievementID then
      AchievementFrame_SelectAchievement(storedAchievementID)
    end

    if storedCategoriesScrollPosition ~= nil then
      AchievementFrameCategories.ScrollBar:SetScrollPercentage(storedCategoriesScrollPosition)
    end
    if storedAchievementsScrollPosition ~= nil then
      AchievementFrameAchievements.ScrollBar:SetScrollPercentage(storedAchievementsScrollPosition)
    end

  end
  -- ####################################################################
  -- ### End
  -- ####################################################################


  goingBackFlag = false

  Addon.UpdateBackButtons()

end



local function RememberLastState()
  -- Do not remember while going back.
  if goingBackFlag or not lastCategoryID then return end
  -- Do not remember if we have already remembered this change.
  if next(history) and history[#history][1] == GetTime() then return end

  -- Titles and category parent not needed yet. Maybe later for history drop down...
  local lastAchievementTitle, lastCategoryTitle, lastCategoryParentID

  if lastAchievementID then
    _, lastAchievementTitle = GetAchievementInfo(lastAchievementID)
  end

  if lastCategoryID == "summary" then
    lastCategoryTitle, lastCategoryParentID = ACHIEVEMENT_SUMMARY_CATEGORY, -1
  else
    lastCategoryTitle, lastCategoryParentID = GetCategoryInfo(lastCategoryID)
  end

  -- print(GetTime(), "Storing", lastAchievementID, lastAchievementTitle, lastCategoryID, lastCategoryTitle, lastCategoryParentID, lastAchievementScrollPosition, lastCategoryScrollPosition)


  -- Table copy.
  local lastCategoryCollapseStateToInsert = {}
  for k, v in pairs(lastCategoryCollapseState) do
    lastCategoryCollapseStateToInsert[k] = {}
    lastCategoryCollapseStateToInsert[k].collapsed = v.collapsed
    lastCategoryCollapseStateToInsert[k].hidden = v.hidden
  end

  tinsert(history, {GetTime(), lastAchievementID, lastAchievementTitle, lastCategoryID, lastCategoryTitle, lastCategoryParentID, lastAchievementScrollPosition, lastCategoryScrollPosition, lastCategoryCollapseStateToInsert, lastTabIndex})

  -- for k, v in pairs(history) do
    -- print("  ", k, v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
  -- end

  Addon.UpdateBackButtons()
end



-- ####################################################################
-- ### Frame layout (retail 12.1.0 and above)
-- ####################################################################

-- In 12.1.0 Blizzard introduced AchievementFrame.HeaderDetails: a 38 pixel
-- high band above the achievements list holding the new back button, the
-- filter dropdown and the search box. When we hide Blizzard's back button we
-- put the search box and the filter dropdown back where they were before
-- 12.1.0 and give the freed up band back to the achievements list.

local function SetContentTopOffset(offset, summaryOffset)
  AchievementFrameAchievements:ClearAllPoints()
  AchievementFrameAchievements:SetPoint("TOPLEFT", AchievementFrameCategories, "TOPRIGHT", 22, offset)
  AchievementFrameAchievements:SetPoint("BOTTOM", AchievementFrameCategories, "BOTTOM")

  AchievementFrameStats:ClearAllPoints()
  AchievementFrameStats:SetPoint("TOPLEFT", AchievementFrameCategories, "TOPRIGHT", 22, offset)
  AchievementFrameStats:SetPoint("BOTTOM", AchievementFrameCategories, "BOTTOM")

  AchievementFrameSummary:ClearAllPoints()
  AchievementFrameSummary:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 218, summaryOffset)
  AchievementFrameSummary:SetPoint("BOTTOM", AchievementFrameCategories, "BOTTOM")
end


local function ApplyLayout()
  -- Nothing to lay out before SetupBlizzardBackButton() has run.
  if not leftDDLInset then return end

  local headerDetails = AchievementFrame.HeaderDetails
  local filters       = headerDetails.Filters
  local searchBox     = filters.SearchBox
  local filterDropdown = filters.FilterDropdown
  local rightDDLInset = AchievementFrame.Header.RightDDLInset

  -- The comparison view has a layout of its own, which Blizzard sets up in
  -- AchievementFrame_SetComparisonMode(). Do not fight it.
  local comparison = IsComparison()
  local preserveOldLayout = (Addon.GetMode() == Addon.MODE_HIDE_BLIZZARD) and not comparison

  if preserveOldLayout then
    -- The band is empty now, so its background must not show.
    headerDetails.TopTileStreaks:Hide()

    -- Take both widgets out of the HorizontalLayoutFrame, so that the
    -- Filters:Layout() calls in AchievementFrame_HideFilterDropdown() and
    -- AchievementFrame_TryShowFilterDropdown() cannot move them back.
    searchBox.ignoreInLayout = true
    filterDropdown.ignoreInLayout = true

    -- Positions taken from the 12.0.7 version of Blizzard_AchievementUI.xml.
    rightDDLInset:Show()
    searchBox:ClearAllPoints()
    searchBox:SetPoint("TOPLEFT", rightDDLInset, "TOPLEFT", 12, 2)

    filterDropdown:ClearAllPoints()
    filterDropdown:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", 144, 8)
    leftDDLInset:SetShown(filterDropdown:IsShown())

    SetContentTopOffset(0, -19)

  else
    headerDetails.TopTileStreaks:Show()
    leftDDLInset:Hide()

    -- Blizzard only shows the right inset in the comparison view now.
    rightDDLInset:SetShown(comparison)

    searchBox.ignoreInLayout = nil
    filterDropdown.ignoreInLayout = nil
    -- In the comparison view Blizzard anchors the search box by hand,
    -- so laying out would undo that.
    if not comparison then
      filters:Layout()
    end

    SetContentTopOffset(-36, -55)
  end
end


Addon.ApplyMode = function()
  if not started then return end

  local mode = Addon.GetMode()

  if backButton then
    -- Without a Blizzard back button to hand over to (Mists and older), our
    -- button must never hide, because there would be no way to bring it back.
    backButton:SetShown(not blizzardBackButton or mode ~= Addon.MODE_REPLACE_BLIZZARD)
  end

  if blizzardBackButton then
    if mode == Addon.MODE_HIDE_BLIZZARD then
      blizzardBackButton:Hide()
    else
      blizzardBackButton:SetShown(not IsComparison())
      if mode == Addon.MODE_REPLACE_BLIZZARD then
        blizzardBackButton:SetEnabled(true)
      end
      -- Lets Blizzard restore the enabled state it wants for side by side mode
      -- and runs our hook, which puts the look back in sync either way.
      AchievementFrame_RefreshBackButton()
    end
  end

  ApplyLayout()
  Addon.UpdateBackButtons()
end



-- ####################################################################
-- ### Setup
-- ####################################################################

local function SetupBlizzardBackButton()

  blizzardBackButton = AchievementFrame.HeaderDetails.Back
  blizzardBackButtonOriginalOnClick = blizzardBackButton:GetScript("OnClick")
  hasOptionsMenu = true

  -- Blizzard removed Header.LeftDDLInset in 12.1.0, but we need it again when
  -- we put the filter dropdown back to its pre 12.1.0 place.
  leftDDLInset = AchievementFrame.Header:CreateTexture(nil, "BORDER")
  leftDDLInset:SetTexture("Interface\\AchievementFrame\\UI-Achievement-RightDDLInset")
  leftDDLInset:SetSize(128, 32)
  leftDDLInset:SetPoint("TOPLEFT", AchievementFrame.Header, "TOPLEFT", 112, -56)
  leftDDLInset:Hide()

  blizzardBackButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  blizzardBackButton:SetScript("OnClick", function(self, mouseButton, ...)
    local mode = Addon.GetMode()

    if mouseButton == "RightButton" then
      -- Our own button is hidden in replace mode, so this is the only way
      -- back to the options.
      if mode == Addon.MODE_REPLACE_BLIZZARD then
        Addon.OpenOptionsMenu()
      end
      return
    end

    if mode == Addon.MODE_REPLACE_BLIZZARD then
      AchievmentsBack()
      return
    end

    -- Side by side mode: Blizzard goes back one step. Without the flag our
    -- hooks below would record this as a new forward navigation, so instead
    -- we drop the history entry Blizzard just consumed.
    goingBackFlag = true
    if blizzardBackButtonOriginalOnClick then
      blizzardBackButtonOriginalOnClick(self, mouseButton, ...)
    end
    goingBackFlag = false

    tremove(history)
    Addon.UpdateBackButtons()
  end)

  -- In replace mode Blizzard's button is ours, so it gets our tooltip.
  blizzardBackButton:HookScript("OnEnter", function(self)
    if Addon.GetMode() ~= Addon.MODE_REPLACE_BLIZZARD then return end
    BackButtonEnterFunction(self, "ANCHOR_RIGHT")
  end)
  blizzardBackButton:HookScript("OnLeave", function(self)
    if Addon.GetMode() ~= Addon.MODE_REPLACE_BLIZZARD then return end
    GameTooltip:Hide()
  end)

  -- AchievementFrame_RefreshBackButton() and AchievementFrame_SetComparisonMode()
  -- both show the button again, so catch every attempt.
  -- UIPanelButton_OnShow() also resets the textures, so restore our look.
  blizzardBackButton:HookScript("OnShow", function(self)
    if Addon.GetMode() == Addon.MODE_HIDE_BLIZZARD then
      self:Hide()
      return
    end
    RefreshBlizzardBackButtonLook()
  end)

  -- While the button only appears disabled it is still enabled, so
  -- UIPanelButton_OnMouseDown() would give it a pressed look.
  local function SuppressPressedLookWhileAppearingDisabled()
    if Addon.GetMode() ~= Addon.MODE_REPLACE_BLIZZARD then return end
    if next(history) ~= nil then return end
    RefreshBlizzardBackButtonLook()
  end
  blizzardBackButton:HookScript("OnMouseDown", SuppressPressedLookWhileAppearingDisabled)
  blizzardBackButton:HookScript("OnMouseUp", SuppressPressedLookWhileAppearingDisabled)

  hooksecurefunc("AchievementFrame_RefreshBackButton", function()
    if Addon.GetMode() ~= Addon.MODE_REPLACE_BLIZZARD then
      RefreshBlizzardBackButtonLook()
      return
    end
    -- Blizzard hides the button on the statistics tab and disables it from
    -- its own one step history. Ours spans all tabs and has to stay enabled,
    -- because right-clicking it is the only way back to the options.
    blizzardBackButton:SetShown(not IsComparison())
    blizzardBackButton:SetEnabled(true)
    RefreshBlizzardBackButtonLook()
  end)

  hooksecurefunc("AchievementFrame_SetComparisonMode", function()
    ApplyLayout()
  end)

  -- Keep our replacement for Header.LeftDDLInset in sync with the dropdown.
  hooksecurefunc("AchievementFrame_HideFilterDropdown", function()
    leftDDLInset:Hide()
  end)
  hooksecurefunc("AchievementFrame_TryShowFilterDropdown", function()
    if Addon.GetMode() == Addon.MODE_HIDE_BLIZZARD and not IsComparison() then
      leftDDLInset:SetShown(AchievementFrame.HeaderDetails.Filters.FilterDropdown:IsShown())
    end
  end)
end



local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, name)
  if name == "Blizzard_AchievementUI" and not started then

    local buttonParentFrame = nil
    local buttonAnchorFrame = nil

    -- ####################################################################
    -- ### Wrath, Cata
    -- ####################################################################
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then

      hooksecurefunc("AchievementFrameCategories_Update", function()
        if lastCategoryID ~= achievementFunctions.selectedCategory then

          RememberLastState()

          lastCategoryChangeTime = GetTime()
          lastCategoryID = achievementFunctions.selectedCategory
          lastCategoryScrollPosition = AchievementFrameCategoriesContainer.scrollBar:GetValue()

          lastCategoryCollapseState = wipe(lastCategoryCollapseState) or {}
          for j, category in pairs(ACHIEVEMENTUI_CATEGORIES) do
            lastCategoryCollapseState[category.id] = {}
            lastCategoryCollapseState[category.id].collapsed = category.collapsed
            lastCategoryCollapseState[category.id].hidden = category.hidden
          end

          lastAchievementID = nil
        end
      end)

      -- For Wrath and Cata we can use this function for both,
      -- jumping to an achievement and clicking on an achievement.
      hooksecurefunc("AchievementFrameAchievements_Update", function()
        local achievementID = AchievementFrameAchievements.selection
        -- print(GetTime(), "AchievementFrameAchievements_Update", achievementID)

        -- When deselecting an achievement, the button.id is nil, which we are not interested in.
        if achievementID and achievementID ~= lastAchievementID then

          -- Do not remember, when coming from the same category with no achievement selected.
          if lastCategoryID ~= GetAchievementCategory(achievementID) or lastAchievementID then
            RememberLastState()
          end

          lastAchievementChangeTime = GetTime()
          lastAchievementID = achievementID
          lastAchievementScrollPosition = AchievementFrameAchievementsContainer.scrollBar:GetValue()

        end
      end)

      AchievementFrameAchievementsContainer.scrollBar:HookScript("OnValueChanged", function(self, value)
        -- print("achievementScrollBar", value)
        if lastAchievementChangeTime == GetTime() and lastAchievementScrollPosition ~= value then
          -- print(GetTime(), "Overriding lastAchievementScrollPosition", lastAchievementScrollPosition, "with", value)
          lastAchievementScrollPosition = value
        end
      end)

      AchievementFrameCategoriesContainer.scrollBar:HookScript("OnValueChanged", function(self, value)
        -- print("categoryScrollBar", value)
        if (lastCategoryChangeTime == GetTime() or lastAchievementChangeTime == GetTime()) and lastCategoryScrollPosition ~= value then
          -- print(GetTime(), "Overriding lastCategoryScrollPosition", lastCategoryScrollPosition, "with", value)
          lastCategoryScrollPosition = value
        end
      end)

      buttonParentFrame = AchievementFrameHeader
      buttonAnchorFrame = AchievementFrameHeaderPointBorder


    -- ####################################################################
    -- ### Retail
    -- ####################################################################
    else

      lastTabIndex = AchievementFrame.selectedTab or ACHIEVEMENTS_TAB

      -- AchievementFrame_UpdateTabs() is the first thing every tab click does,
      -- and unlike AchievementFrameTab_OnClick it is a real global that is not
      -- swapped out for the comparison view, so it is the one reliable place to
      -- notice a tab change.
      hooksecurefunc("AchievementFrame_UpdateTabs", function(clickedTab)
        if IsComparison() or lastTabIndex == clickedTab then return end

        -- Stores the state of the tab we are leaving.
        RememberLastState()

        lastTabIndex = clickedTab
        lastCategoryChangeTime = GetTime()

        -- A category change follows only when the new tab has no category
        -- selected yet, so fall back to what we last saw selected there.
        lastCategoryID = lastCategoryIDPerTab[clickedTab]
        lastAchievementID = lastAchievementIDPerTab[clickedTab]

        -- Both lists belong to the tab we just left and have not been rebuilt
        -- for the new tab yet. Forgetting them is better than carrying a
        -- position over into a different list, and anything worth scrolling to
        -- gets scrolled to by the category or achievement selection anyway.
        lastCategoryScrollPosition = nil
        lastAchievementScrollPosition = nil
      end)

      hooksecurefunc("AchievementFrameCategories_OnCategoryChanged", function(categoryID)
        -- print(GetTime(), "AchievementFrameCategories_OnCategoryChanged", categoryID)
        if lastCategoryID ~= categoryID then

          RememberLastState()

          lastCategoryChangeTime = GetTime()
          lastCategoryID = categoryID
          lastCategoryScrollPosition = AchievementFrameCategories.ScrollBox.scrollPercentage

          lastAchievementID = nil
        end

        -- Remember per tab, so that returning to a tab restores its category.
        lastCategoryIDPerTab[lastTabIndex] = categoryID
        lastAchievementIDPerTab[lastTabIndex] = nil
      end)

      -- In Retail, we need this function for jumping to an achievement...
      hooksecurefunc("AchievementFrame_SelectAchievement", function(achievementID)
        -- print(GetTime(), "AchievementFrame_SelectAchievement", achievementID)

        if achievementID and achievementID ~= lastAchievementID then

          RememberLastState()

          lastAchievementChangeTime = GetTime()
          lastAchievementID = achievementID
          lastAchievementIDPerTab[lastTabIndex] = achievementID
          lastAchievementScrollPosition = AchievementFrameAchievements.ScrollBox.scrollPercentage

          lastCategoryScrollPosition = AchievementFrameCategories.ScrollBox.scrollPercentage
        end
      end)

      -- ...and this funciton for clicking on an achievement.
      hooksecurefunc(AchievementTemplateMixin, "ProcessClick", function()
        local achievementID = AchievementFrameAchievements_GetSelectedAchievementId()
        -- print("AchievementTemplateMixin.ProcessClick", achievementID, AchievementFrameAchievements.ScrollBox.scrollPercentage)

        -- When deselecting an achievement, GetSelectedAchievementId() returns 0, which we are not interested in.
        if achievementID and achievementID ~= lastAchievementID and achievementID ~= 0 then

          -- Do not remember, when coming from the same category with no achievement selected.
          if lastCategoryID ~= GetAchievementCategory(achievementID) or lastAchievementID then
            RememberLastState()
          end

          lastAchievementChangeTime = GetTime()
          lastAchievementID = achievementID
          lastAchievementIDPerTab[lastTabIndex] = achievementID
          lastAchievementScrollPosition = AchievementFrameAchievements.ScrollBox.scrollPercentage

          lastCategoryScrollPosition = AchievementFrameCategories.ScrollBox.scrollPercentage
        end

      end)


      local achievementScrollBar = AchievementFrameAchievements.ScrollBar
      achievementScrollBar:RegisterCallback(achievementScrollBar.Event.OnScroll, function(_, scrollPercent)
        -- print(GetTime(), "achievementScrollBar", scrollPercent)
        if lastAchievementChangeTime == GetTime() and lastAchievementScrollPosition ~= scrollPercent then
          -- print(GetTime(), "Overriding lastAchievementScrollPosition", lastAchievementScrollPosition, "with", scrollPercent)
          lastAchievementScrollPosition = scrollPercent
        end
      end)

      local categoryScrollBar = AchievementFrameCategories.ScrollBar
      categoryScrollBar:RegisterCallback(categoryScrollBar.Event.OnScroll, function(_, scrollPercent)
        -- print(GetTime(), "categoryScrollBar", scrollPercent)
        if (lastCategoryChangeTime == GetTime() or lastAchievementChangeTime == GetTime()) and lastCategoryScrollPosition ~= scrollPercent then
          -- print(GetTime(), "Overriding lastCategoryScrollPosition", lastCategoryScrollPosition, "with", scrollPercent)
          lastCategoryScrollPosition = scrollPercent
        end
      end)

      buttonParentFrame = AchievementFrame.Header
      buttonAnchorFrame = AchievementFrame.Header.PointBorder

      -- Blizzard added a back button of its own in 12.1.0.
      if AchievementFrame.HeaderDetails and AchievementFrame.HeaderDetails.Back then
        SetupBlizzardBackButton()
      end

      AchievementFrame:HookScript("OnHide", function()
        Addon.CloseOptionsMenu()
      end)
    end
    -- ####################################################################
    -- ### End
    -- ####################################################################


    backButton = CreateFrame("Button", nil, buttonParentFrame)
    backButton:SetNormalTexture(BUTTON_TEXTURE_UP)
    backButton:SetPushedTexture(BUTTON_TEXTURE_DOWN)
    backButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

    -- Register the button to receive both left and right clicks for the dropdown menu.
    backButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- Check if using ElvUI skin (only when ElvUI is loaded)
    local isElvUISkin = false
    if C_AddOns.IsAddOnLoaded("ElvUI") then
      local E = unpack(ElvUI or {})
      if E and E.private and E.private.skins and
         E.private.skins.blizzard and
         E.private.skins.blizzard.enable and
         E.private.skins.blizzard.achievement then
        isElvUISkin = true
      end
    end

    -- Position button based on skin and other addons
    local hasKrowiFilter = C_AddOns.IsAddOnLoaded("Krowi_AchievementFilter")

    if isElvUISkin then
      backButton:SetSize(25, 25)
      if hasKrowiFilter then
        backButton:SetPoint("BOTTOMRIGHT", AchievementFrameCategories, "TOPRIGHT", 0, -1)
      else
        backButton:SetPoint("BOTTOMLEFT", AchievementFrameAchievements, "TOPLEFT", -1, -3)
      end
    else
      backButton:SetSize(29, 29)
      if hasKrowiFilter then
        backButton:SetPoint("BOTTOM", KrowiAF_AchievementFrameBrowsingHistoryPrevAchievementButton, "TOP", 0, -5)
      else
        backButton:SetPoint("LEFT", buttonAnchorFrame, "RIGHT", 10, 1)
      end
    end

    backButton:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "RightButton" then
          if hasOptionsMenu then
            Addon.OpenOptionsMenu()
          end
          return
        end
        AchievmentsBack()
      end)
    backButton:SetScript("OnEnter", function(self)
        BackButtonEnterFunction(self, "ANCHOR_TOP")
      end)
    backButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
      end)


    started = true

    Addon.ApplyMode()

    self:UnregisterEvent("ADDON_LOADED")
  end
end)
