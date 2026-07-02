local AddonName, MKPT_env, _ = ...

local Utils = MKPT_env.Utils
local L = MKPT_env.L

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
    midnightOption.checked = MKPT_env.charDb.state.expansion == Enum.ExpansionLevel.Midnight
    midnightOption.func = function()
      if not midnightOption.checked then
        MKPT_env.ToggleExpansion()
      end
    end
    UIDropDownMenu_AddButton(midnightOption)

    local twwOption = UIDropDownMenu_CreateInfo()
    twwOption.text = TWW_LOCALIZED_NAME
    twwOption.checked = MKPT_env.charDb.state.expansion == Enum.ExpansionLevel.WarWithin
    twwOption.func = function()
      if not twwOption.checked then
        MKPT_env.ToggleExpansion()
      end
    end

    UIDropDownMenu_AddButton(twwOption)
  end

  -- Show/Hide filterGroups
  UIDropDownMenu_AddSeparator()
  do
    local showHeader = UIDropDownMenu_CreateInfo()
    showHeader.text = L["Show/Hide"]
    showHeader.isTitle = true
    showHeader.notCheckable = true
    UIDropDownMenu_AddButton(showHeader)

    local showUniqueTreasure = UIDropDownMenu_CreateInfo()
    showUniqueTreasure.text = Utils.UNIQUE_TREASURE_ICON .. " " .. Utils.UniqueTextColor(L["Unique Treasures"])
    showUniqueTreasure.checked = MKPT_env.db.config.hideUniqueTreasures == false
    showUniqueTreasure.isNotRadio = true
    showUniqueTreasure.keepShownOnClick = true
    showUniqueTreasure.func = function()
      MKPT_env.db.config.hideUniqueTreasures = not MKPT_env.db.config.hideUniqueTreasures
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showUniqueTreasure)


    local showFirstTime = UIDropDownMenu_CreateInfo()
    showFirstTime.text = Utils.FIRST_GATHER_ICON .. " " .. Utils.UniqueTextColor(L["First Time Gather"])
    showFirstTime.checked = MKPT_env.db.config.hideFirstTimeGather == false
    showFirstTime.isNotRadio = true
    showFirstTime.keepShownOnClick = true
    showFirstTime.func = function()
      MKPT_env.db.config.hideFirstTimeGather = not MKPT_env.db.config.hideFirstTimeGather
      f:RenderTree()
    end

    UIDropDownMenu_AddButton(showFirstTime)
    local showUniqueBook = UIDropDownMenu_CreateInfo()
    showUniqueBook.text = Utils.UNIQUE_BOOK_ICON .. " " .. Utils.UniqueTextColor(L["Unique/Renown Books"])
    showUniqueBook.checked = MKPT_env.db.config.hideUniqueBooks == false
    showUniqueBook.isNotRadio = true
    showUniqueBook.keepShownOnClick = true
    showUniqueBook.func = function()
      MKPT_env.db.config.hideUniqueBooks = not MKPT_env.db.config.hideUniqueBooks
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showUniqueBook)

    local showTreatise = UIDropDownMenu_CreateInfo()
    showTreatise.text = Utils.TREATISE_ICON .. " " .. Utils.WeeklyTextColor(L["Treatise"])
    showTreatise.checked = MKPT_env.db.config.hideTreatise == false
    showTreatise.isNotRadio = true
    showTreatise.keepShownOnClick = true
    showTreatise.func = function()
      MKPT_env.db.config.hideTreatise = not MKPT_env.db.config.hideTreatise
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showTreatise)

    local showWeeklyQuest = UIDropDownMenu_CreateInfo()
    showWeeklyQuest.text = Utils.WEEKLY_QUEST_ICON .. " " .. Utils.WeeklyTextColor(L["Weekly Quests"])
    showWeeklyQuest.checked = MKPT_env.db.config.hideWeeklyQuests == false
    showWeeklyQuest.isNotRadio = true
    showWeeklyQuest.keepShownOnClick = true
    showWeeklyQuest.func = function()
      MKPT_env.db.config.hideWeeklyQuests = not MKPT_env.db.config.hideWeeklyQuests
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showWeeklyQuest)

    local showWeeklyTreasure = UIDropDownMenu_CreateInfo()
    showWeeklyTreasure.text = Utils.WEEKLY_TREASURE_ICON .. " " .. Utils.WeeklyTextColor(L["Weekly Treasures"])
    showWeeklyTreasure.checked = MKPT_env.db.config.hideWeeklyTreasures == false
    showWeeklyTreasure.isNotRadio = true
    showWeeklyTreasure.keepShownOnClick = true
    showWeeklyTreasure.func = function()
      MKPT_env.db.config.hideWeeklyTreasures = not MKPT_env.db.config.hideWeeklyTreasures
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showWeeklyTreasure)

    local showCatchUp = UIDropDownMenu_CreateInfo()
    showCatchUp.text = Utils.CATCHUP_ICON .. " " .. Utils.CatchUpTextColor(L["Catch-Up"])
    showCatchUp.checked = MKPT_env.db.config.hideCatchUp == false
    showCatchUp.isNotRadio = true
    showCatchUp.keepShownOnClick = true
    showCatchUp.func = function()
      MKPT_env.db.config.hideCatchUp = not MKPT_env.db.config.hideCatchUp
      f:RenderTree()
    end
    UIDropDownMenu_AddButton(showCatchUp)

    if MKPT_env.charDb.state.expansion == Enum.ExpansionLevel.Midnight then
      local showDundun = UIDropDownMenu_CreateInfo()
      showDundun.text = Utils.DUNDUN_ICON .. " " .. Utils.CatchUpTextColor(MKPT_env.MKPT_ShardOfDundun.name)
      showDundun.checked = MKPT_env.db.config.hideDundun == false
      showDundun.isNotRadio = true
      showDundun.keepShownOnClick = true
      showDundun.func = function()
        MKPT_env.db.config.hideDundun = not MKPT_env.db.config.hideDundun
        f:RenderTree()
      end
      UIDropDownMenu_AddButton(showDundun)
    end
  end

  UIDropDownMenu_AddSeparator()
  -- Settings
  do
    local settings = UIDropDownMenu_CreateInfo()
    settings.text = Utils.SETTINGS_ICON .. " " .. L["Settings"]
    settings.func = function()
      Settings.OpenToCategory(MKPT_env.categoryId)
    end
    settings.disabled = InCombatLockdown()
    settings.notCheckable = true
    settings.checked = nil
    UIDropDownMenu_AddButton(settings)
  end

  UIDropDownMenu_AddSeparator()
  -- Close button
  do
    local close = UIDropDownMenu_CreateInfo()
    close.text = L["Close"]
    close.notCheckable = true
    close.checked = nil
    UIDropDownMenu_AddButton(close)
  end
end

function MKPT_env.ShowRightClickMenu()
  UIDropDownMenu_Initialize(RightClickMenu, InitializeRightClickMenu, "MENU")
  ToggleDropDownMenu(1, nil, RightClickMenu, "cursor", 0, 0)
end

function MKPT_env.IsShowingRightClickMenu()
  return UIDROPDOWNMENU_OPEN_MENU ~= nil
end
