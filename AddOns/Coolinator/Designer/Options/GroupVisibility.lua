---@class addonTableCoolinator
local addonTable = select(2, ...)

local visibilityCriteria = {
  {title = addonTable.Locales.COMBAT},
  {key = "in-combat", label = addonTable.Locales.IN_COMBAT},
  {key = "out-of-combat", label = addonTable.Locales.OUT_OF_COMBAT},

  {title = addonTable.Locales.MOUNT},
  {key = "on-mount", label = addonTable.Locales.ON_MOUNT},
  {key = "off-mount", label = addonTable.Locales.OFF_MOUNT},
  {key = "skyriding", label = addonTable.Locales.SKYRIDING_ZONE},

  {title = addonTable.Locales.LOCATION},
  {key = "loc-rested", label = addonTable.Locales.RESTED},
  {key = "loc-world", label = addonTable.Locales.WORLD},
  {key = "loc-dungeon", label = addonTable.Locales.DUNGEON},
  {key = "loc-raid", label = addonTable.Locales.RAID},
  {key = "loc-pvp", label = addonTable.Locales.PVP},
  {key = "loc-delve", label = addonTable.Locales.DELVE},

  {title = addonTable.Locales.TARGET},
  {key = "has-target", label = addonTable.Locales.HAS_TARGET},
  {key = "no-target", label = addonTable.Locales.NO_TARGET},
  {key = "has-target-attack", label = addonTable.Locales.HAS_TARGET_ATTACK},
  {key = "no-target-attack", label = addonTable.Locales.NO_TARGET_ATTACK},
  {key = "has-target-assist", label = addonTable.Locales.HAS_TARGET_ASSIST},
  {key = "no-target-assist", label = addonTable.Locales.NO_TARGET_ASSIST},
}

local actions = {
  {key = "show", label = addonTable.Locales.SHOW},
  {key = "hide", label = addonTable.Locales.HIDE},
  {key = "fade", label = addonTable.Locales.FADE},
}

local function IsUsingDefaultVisibility(details)
  if #details.visibility > 2 then
    return false
  end

  for index, state in ipairs(details.visibility) do
    if state.conditions[1] == "on-mount" then
      if index ~= 1 or #state.conditions ~= 2 or state.conditions[2] ~= "out-of-combat" or state.action == "show" then
        return false
      end
    elseif state.conditions[1] == "out-of-combat" then
      if index == 1 and #details.visibility == 2 or #state.conditions ~= 1 or state.action == "show" then
        return false
      end
    else
      return false
    end
  end

  return true
end

local function GetDefaultOptions(parent)
  local container = CreateFrame("Frame", nil, parent)
  container:SetPoint("LEFT")
  container:SetPoint("RIGHT")
  container:SetHeight(300)

  local Refresh

  local allFrames = {}

  local hideOutOfCombat = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.HIDE_OUT_OF_COMBAT, 28,
    function(state)
      local visibility = container.details.visibility
      if state then
        if #visibility == 0 or visibility[#visibility].conditions[1] ~= "out-of-combat" then
          table.insert(visibility, {
            conditions = {"out-of-combat"},
            action = "hide",
          })
        else
          visibility[#visibility].action = "hide"
        end
      else
        if visibility[#visibility].conditions[1] == "out-of-combat" and visibility[#visibility].action == "hide" then
          table.remove(visibility, #visibility)
        end
      end
      addonTable.Designer.Options.Announce()
      Refresh()
    end
  )
  hideOutOfCombat:SetPoint("TOP")
  table.insert(allFrames, hideOutOfCombat)
  local hideWhenMounted = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.HIDE_WHEN_MOUNTED, 28,
    function(state)
      local visibility = container.details.visibility
      if state then
        if #visibility == 0 or visibility[1].conditions[1] ~= "on-mount" then
          table.insert(container.details.visibility, 1, {
            conditions = {"on-mount", "out-of-combat"},
            action = "hide",
          })
        else
          visibility[1].action = "hide"
        end
      else
        if visibility[1].conditions[1] == "on-mount" and visibility[1].action == "hide" then
          table.remove(visibility, 1)
        end
      end
      addonTable.Designer.Options.Announce()
      Refresh()
    end
  )
  hideWhenMounted:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, hideWhenMounted)

  local fadeOutOfCombat = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.FADE_OUT_OF_COMBAT, 28,
    function(state)
      local visibility = container.details.visibility
      if state then
        if #visibility == 0 or visibility[#visibility].conditions[1] ~= "out-of-combat" then
          table.insert(visibility, {
            conditions = {"out-of-combat"},
            action = "fade",
          })
        else
          visibility[#visibility].action = "fade"
        end
      else
        if visibility[#visibility].conditions[1] == "out-of-combat" and visibility[#visibility].action == "fade" then
          table.remove(visibility, #visibility)
        end
      end
      addonTable.Designer.Options.Announce()
      Refresh()
    end
  )
  fadeOutOfCombat:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, -30)
  table.insert(allFrames, fadeOutOfCombat)
  local fadeWhenMounted = addonTable.CustomiseDialog.Components.GetCheckbox(container, addonTable.Locales.FADE_WHEN_MOUNTED, 28,
    function(state)
      local visibility = container.details.visibility
      if state then
        if #visibility == 0 or visibility[1].conditions[1] ~= "on-mount" then
          table.insert(container.details.visibility, 1, {
            conditions = {"on-mount", "out-of-combat"},
            action = "fade",
          })
        else
          visibility[1].action = "fade"
        end
      else
        if visibility[1].conditions[1] == "on-mount" and visibility[1].action == "fade" then
          table.remove(visibility, 1)
        end
      end
      addonTable.Designer.Options.Announce()
      Refresh()
    end
  )
  fadeWhenMounted:SetPoint("TOP", allFrames[#allFrames], "BOTTOM")
  table.insert(allFrames, fadeWhenMounted)

  Refresh = function()
    hideOutOfCombat:SetValue(false)
    fadeOutOfCombat:SetValue(false)
    hideWhenMounted:SetValue(false)
    fadeWhenMounted:SetValue(false)
    for _, state in ipairs(container.details.visibility) do
      if state.conditions[1] == "out-of-combat" then
        hideOutOfCombat:SetValue(state.action == "hide")
        fadeOutOfCombat:SetValue(state.action == "fade")
      elseif state.conditions[1] == "on-mount" then
        hideWhenMounted:SetValue(state.action == "hide")
        fadeWhenMounted:SetValue(state.action == "fade")
      end
    end
  end

  function container:SetValue(details)
    container.details = details
    Refresh()
  end

  return container
end

local function GetCustomOptions(parent)
  local container = CreateFrame("Frame", nil, parent)

  local ScrollBox = CreateFrame("Frame", nil, container, "WowScrollBox")
  ScrollBox:SetPoint("TOPLEFT")
  ScrollBox:SetPoint("BOTTOMRIGHT", 0, 50)
  local ScrollBar = CreateFrame("EventFrame", nil, container, "MinimalScrollBar")
  ScrollBar:SetPoint("TOPRIGHT", -10, 0)
  ScrollBar:SetPoint("BOTTOMRIGHT", -10, 50)
  local ScrollChild = CreateFrame("Frame", nil, ScrollBox)
  ScrollChild.scrollable = true
  ScrollUtil.InitScrollBoxWithScrollBar(ScrollBox, ScrollBar, CreateScrollBoxLinearView())
  ScrollUtil.AddManagedScrollBarVisibilityBehavior(ScrollBox, ScrollBar)
  ScrollBox:SetPanExtent(100)

  local Refresh

  local holderPool = CreateFramePool("Frame", ScrollChild, nil, nil, false, function(frame)
    frame:SetHeight(60)

    frame.removeEntryButton = CreateFrame("Button", nil, frame)
    frame.removeEntryButton:SetSize(30, 30)
    frame.removeEntryButton:SetNormalAtlas("128-RedButton-Delete")
    frame.removeEntryButton:SetPushedAtlas("128-RedButton-Delete-Pressed")
    frame.removeEntryButton:SetHighlightAtlas("128-RedButton-Delete-Highlight")
    frame.removeEntryButton:SetPoint("RIGHT", 5, 18)
    frame.removeEntryButton:SetScript("OnClick", function()
      local visibility = container.details.visibility
      table.remove(visibility, frame.index)
      addonTable.Designer.Options.Announce()
      Refresh()
    end)

    frame.shiftUp = CreateFrame("Button", nil, frame)
    frame.shiftUp:SetSize(16, 20)
    frame.shiftUp:SetNormalAtlas("bag-arrow")
    frame.shiftUp:GetNormalTexture():SetRotation(- math.pi / 2)
    frame.shiftUp:GetNormalTexture():SetSize(16, 10)
    frame.shiftUp:SetScript("OnEnter", function()
      frame.shiftUp:GetNormalTexture():SetAlpha(0.5)
    end)
    frame.shiftUp:SetScript("OnLeave", function()
      frame.shiftUp:GetNormalTexture():SetAlpha(1)
    end)
    frame.shiftDown = CreateFrame("Button", nil, frame)
    frame.shiftDown:SetSize(16, 20)
    frame.shiftDown:SetNormalAtlas("bag-arrow")
    frame.shiftDown:GetNormalTexture():SetRotation(math.pi / 2)
    frame.shiftDown:GetNormalTexture():SetSize(16, 10)
    frame.shiftDown:SetScript("OnEnter", function()
      frame.shiftDown:GetNormalTexture():SetAlpha(0.5)
    end)
    frame.shiftDown:SetScript("OnLeave", function()
      frame.shiftDown:GetNormalTexture():SetAlpha(1)
    end)
    frame.shiftUp:SetPoint("TOPLEFT", -20, 5)
    frame.shiftDown:SetPoint("TOPLEFT", -20, -15)

    frame.shiftUp:SetScript("OnClick", function()
      local visibility = container.details.visibility
      local tmp = visibility[frame.index]
      visibility[frame.index] = visibility[frame.index - 1]
      visibility[frame.index - 1] = tmp
      addonTable.Designer.Options.Announce()
      Refresh()
    end)
    frame.shiftDown:SetScript("OnClick", function()
      local visibility = container.details.visibility
      local tmp = visibility[frame.index]
      visibility[frame.index] = visibility[frame.index + 1]
      visibility[frame.index + 1] = tmp
      addonTable.Designer.Options.Announce()
      Refresh()
    end)

    frame.criteriaDropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    frame.criteriaDropdown:SetWidth(210)
    frame.criteriaDropdown:SetDefaultText(addonTable.Locales.SELECT_CRITERIA)
    frame.criteriaDropdown:SetPoint("TOP")
    frame.criteriaDropdown:SetPoint("RIGHT", frame, "CENTER", 20, 0)
    frame.criteriaDropdown:SetupMenu(function(_, rootDescription)
      for _, criteria in ipairs(visibilityCriteria) do
        if criteria.title then
          rootDescription:CreateTitle(NORMAL_FONT_COLOR:WrapTextInColorCode(criteria.title))
        else
          rootDescription:CreateCheckbox(criteria.label, function()
            local state = container.details.visibility[frame.index]
            return state and tIndexOf(state.conditions, criteria.key) ~= nil
          end, function()
            local state = container.details.visibility[frame.index]
            local index = tIndexOf(state.conditions, criteria.key)
            if index then
              table.remove(state.conditions, index)
            else
              table.insert(state.conditions, criteria.key)
            end
            addonTable.Designer.Options.Announce()
          end)
        end
      end
    end)
    local criteriaLabel = frame:CreateFontString(nil, nil, "GameFontHighlight")
    criteriaLabel:SetText(addonTable.Locales.SITUATION)
    criteriaLabel:SetPoint("RIGHT", frame.criteriaDropdown, "LEFT", -10, 0)

    frame.actionDropdown = CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    frame.actionDropdown:SetWidth(150)
    frame.actionDropdown:SetPoint("TOP")
    frame.actionDropdown:SetPoint("RIGHT", -35, 0)
    frame.actionDropdown:SetupMenu(function(_, rootDescription)
      for _, details in ipairs(actions) do
        rootDescription:CreateRadio(details.label,
          function()
            local state = container.details.visibility[frame.index]
            return state and details.key == state.action
          end,
          function()
            local state = container.details.visibility[frame.index]
            state.action = details.key
            addonTable.Designer.Options.Announce()
          end
        )
      end
    end)
    local actionLabel = frame:CreateFontString(nil, nil, "GameFontHighlight")
    actionLabel:SetText(addonTable.Locales.ACTION)
    actionLabel:SetPoint("RIGHT", frame.actionDropdown, "LEFT", -10, 0)

    function frame:SetState(index)
      frame.index = index -- index used cause presets rewrite visibility states breaking table ref
      local visibility = container.details.visibility
      frame.shiftUp:SetShown(index > 1)
      frame.shiftDown:SetShown(index < #visibility)
      frame:Show()
    end
  end)

  local addButton = CreateFrame("Button", nil, container, "UIPanelDynamicResizeButtonTemplate")
  addButton:SetText(addonTable.Locales.ADD)
  DynamicResizeButton_Resize(addButton)
  addButton:SetPoint("BOTTOM", 0, 25)
  addButton:SetPoint("RIGHT", container, "CENTER", -10, 0)
  addButton:SetScript("OnClick", function()
    table.insert(container.details.visibility, {
      conditions = {"in-combat"},
      action = "show",
    })
    addonTable.Designer.Options.Announce()
    Refresh()
  end)

  local resetButton = CreateFrame("Button", nil, container, "UIPanelDynamicResizeButtonTemplate")
  resetButton:SetText(addonTable.Locales.DEFAULT)
  DynamicResizeButton_Resize(resetButton)
  resetButton:SetPoint("BOTTOM", 0, 25)
  resetButton:SetPoint("LEFT", container, "CENTER", 10, 0)
  resetButton:SetScript("OnClick", function()
    container.details.visibility = {}
    addonTable.Designer.Options.Announce()
    Refresh()
  end)

  Refresh = function()
    holderPool:ReleaseAll()

    local visibility = container.details.visibility

    local offsetY = 0
    for index, state in ipairs(visibility) do
      local holder = holderPool:Acquire()
      holder:SetState(index)
      holder:SetPoint("TOP", 0, offsetY)
      holder:SetPoint("LEFT", 30, 0)
      holder:SetPoint("RIGHT", -30, 0)
      offsetY = offsetY - holder:GetHeight()
    end

    ScrollChild:SetHeight(-offsetY)
    ScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  end

  function container:SetValue(details)
    container.details = details
    Refresh()
  end

  return container
end

function addonTable.Designer.Options.GetGroupVisibility(parent)
  local container = CreateFrame("Frame", nil, parent)
  container:SetPoint("LEFT", 0, 0)
  container:SetPoint("RIGHT")
  container:SetHeight(500)

  local defaultContainer = GetDefaultOptions(container)
  local customContainer = GetCustomOptions(container)

  local tabContainers = {
    {name = addonTable.Locales.DEFAULT, container = defaultContainer},
    {name = addonTable.Locales.CUSTOM, container = customContainer},
  }

  local currentTabIndex = 1

  local Tabs = {}
  local lastTab
  for index, setup in ipairs(tabContainers) do
    local tabContainer = setup.container
    tabContainer:SetPoint("TOPLEFT", 2, -45)
    tabContainer:SetPoint("BOTTOMRIGHT")

    local tabButton = addonTable.CustomiseDialog.Components.GetTab(container, setup.name)
    if lastTab then
      tabButton:SetPoint("LEFT", lastTab, "RIGHT", 5, 0)
    else
      tabButton:SetPoint("TOPLEFT", 25, 0)
    end
    lastTab = tabButton
    tabContainer.button = tabButton
    tabButton:SetScript("OnClick", function()
      currentTabIndex = index
      for _, c in ipairs(tabContainers) do
        PanelTemplates_DeselectTab(c.container.button)
        c.container:Hide()
      end
      PanelTemplates_SelectTab(tabButton)
      tabContainer:Show()
      tabContainer:SetValue(container.details)
    end)
    tabContainer:Hide()

    table.insert(Tabs, tabButton)
  end
  container.Tabs = Tabs
  PanelTemplates_SetNumTabs(container, #container.Tabs)

  local wasDefault = true
  function container:SetValue(details)
    if not details then
      container.details = nil
      return
    end
    local oldDetails = container.details
    local usingDefault = IsUsingDefaultVisibility(details)
    container.details = details
    Tabs[1]:SetEnabled(usingDefault)
    Tabs[1]:SetAlpha(usingDefault and 1 or 0.5)
    if container.details ~= oldDetails then
      if usingDefault then
        Tabs[1]:Click()
      else
        Tabs[2]:Click()
        C_Timer.After(0, function()
          Tabs[1]:SetEnabled(usingDefault)
        end)
      end
    else
      PanelTemplates_SelectTab(Tabs[currentTabIndex])
    end
    wasDefault = usingDefault
  end

  return container
end
