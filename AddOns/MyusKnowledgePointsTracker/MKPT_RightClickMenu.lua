local AddonName, MKPT_env, _ = ...

local Utils = MKPT_env.Utils

local RightClickMenu = CreateFrame("Frame", "MKPT_RightClickMenu", UIParent, "UIDropDownMenuTemplate")

local TWW_LOCALIZED_NAME = EXPANSION_NAME10
local MIDNIGHT_LOCALIZED_NAME = EXPANSION_NAME11

local function InitializeRightClickMenu(self, level, menuList)
  local f = MKPT_env.ui
  -- Expansion toggle
  do
    local expansionHeader = UIDropDownMenu_CreateInfo()
    expansionHeader.text = EXPANSION_FILTER_TEXT
    expansionHeader.isTitle = true
    expansionHeader.notCheckable = true
    UIDropDownMenu_AddButton(expansionHeader)

    local midnightOption = UIDropDownMenu_CreateInfo()
    midnightOption.text = MIDNIGHT_LOCALIZED_NAME
    midnightOption.checked = MKPT_env.db.state.expansion == Enum.ExpansionLevel.Midnight
    midnightOption.func = function()
      if not midnightOption.checked then
        MKPT_env.ToggleExpansion()
      end
    end
    UIDropDownMenu_AddButton(midnightOption)

    local twwOption = UIDropDownMenu_CreateInfo()
    twwOption.text = TWW_LOCALIZED_NAME
    twwOption.checked = MKPT_env.db.state.expansion == Enum.ExpansionLevel.WarWithin
    twwOption.func = function()
      if not twwOption.checked then
        MKPT_env.ToggleExpansion()
      end
    end

    UIDropDownMenu_AddButton(twwOption)
  end

  -- Show/Hide filterGroups
  do
    UIDropDownMenu_AddSeparator()

    local showHeader = UIDropDownMenu_CreateInfo()
    showHeader.text = "Show/Hide"
    showHeader.isTitle = true
    showHeader.notCheckable = true
    UIDropDownMenu_AddButton(showHeader)

    local showUniqueTreasure = UIDropDownMenu_CreateInfo()
    showUniqueTreasure.text = Utils.UNIQUE_TREASURE_ICON.." "..Utils.UniqueTextColor("Unique Treasures")
    showUniqueTreasure.checked = MKPT_env.db.config.hideUniqueTreasures == false
    showUniqueTreasure.isNotRadio = true
    showUniqueTreasure.keepShownOnClick = true
    showUniqueTreasure.func = function()
      MKPT_env.db.config.hideUniqueTreasures = not MKPT_env.db.config.hideUniqueTreasures
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showUniqueTreasure)


    local showFirstTime = UIDropDownMenu_CreateInfo()
    showFirstTime.text = Utils.FIRST_GATHER_ICON.." "..Utils.UniqueTextColor("First Time Gather")
    showFirstTime.checked = MKPT_env.db.config.hideFirstTimeGather == false
    showFirstTime.isNotRadio = true
    showFirstTime.keepShownOnClick = true
    showFirstTime.func = function()
      MKPT_env.db.config.hideFirstTimeGather = not MKPT_env.db.config.hideFirstTimeGather
      f:RenderTree()
    end

    UIDropDownMenu_AddButton(showFirstTime)
    local showUniqueBook = UIDropDownMenu_CreateInfo()
    showUniqueBook.text = Utils.UNIQUE_BOOK_ICON.." "..Utils.UniqueTextColor("Unique/Renown Books")
    showUniqueBook.checked = MKPT_env.db.config.hideUniqueBooks == false
    showUniqueBook.isNotRadio = true
    showUniqueBook.keepShownOnClick = true
    showUniqueBook.func = function()
      MKPT_env.db.config.hideUniqueBooks = not MKPT_env.db.config.hideUniqueBooks
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showUniqueBook)

    local showTreatise = UIDropDownMenu_CreateInfo()
    showTreatise.text = Utils.TREATISE_ICON.." "..Utils.WeeklyTextColor("Treatise")
    showTreatise.checked = MKPT_env.db.config.hideTreatise == false
    showTreatise.isNotRadio = true
    showTreatise.keepShownOnClick = true
    showTreatise.func = function()
      MKPT_env.db.config.hideTreatise = not MKPT_env.db.config.hideTreatise
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showTreatise)

    local showWeeklyQuest = UIDropDownMenu_CreateInfo()
    showWeeklyQuest.text = Utils.WEEKLY_QUEST_ICON.." "..Utils.WeeklyTextColor("Weekly Quests")
    showWeeklyQuest.checked = MKPT_env.db.config.hideWeeklyQuests == false
    showWeeklyQuest.isNotRadio = true
    showWeeklyQuest.keepShownOnClick = true
    showWeeklyQuest.func = function()
      MKPT_env.db.config.hideWeeklyQuests = not MKPT_env.db.config.hideWeeklyQuests
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showWeeklyQuest)

    local showWeeklyTreasure = UIDropDownMenu_CreateInfo()
    showWeeklyTreasure.text = Utils.WEEKLY_TREASURE_ICON.." "..Utils.WeeklyTextColor("Weekly Treasures")
    showWeeklyTreasure.checked = MKPT_env.db.config.hideWeeklyTreasures == false
    showWeeklyTreasure.isNotRadio = true
    showWeeklyTreasure.keepShownOnClick = true
    showWeeklyTreasure.func = function()
      MKPT_env.db.config.hideWeeklyTreasures = not MKPT_env.db.config.hideWeeklyTreasures
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showWeeklyTreasure)

    local showCatchUp = UIDropDownMenu_CreateInfo()
    showCatchUp.text = Utils.CATCHUP_ICON.." "..Utils.CatchUpTextColor("Catch-Up")
    showCatchUp.checked = MKPT_env.db.config.hideCatchUp == false
    showCatchUp.isNotRadio = true
    showCatchUp.keepShownOnClick = true
    showCatchUp.func = function()
      MKPT_env.db.config.hideCatchUp = not MKPT_env.db.config.hideCatchUp
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showCatchUp)
  end

  -- Close button
  do
    UIDropDownMenu_AddSeparator()
    local close = UIDropDownMenu_CreateInfo()
    close.text = "Close"
    close.notCheckable = true
    close.checked = nil
    UIDropDownMenu_AddButton(close)
  end
end

function MKPT_env.ShowRightClickMenu()
  UIDropDownMenu_Initialize(RightClickMenu, InitializeRightClickMenu, "MENU")
  ToggleDropDownMenu(1, nil, RightClickMenu, "cursor", 0, 0)
end
