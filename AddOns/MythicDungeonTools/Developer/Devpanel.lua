local AceGUI = LibStub("AceGUI-3.0")
local MDT = MDT
local db
local tonumber, tinsert, pairs, ipairs = tonumber, table.insert, pairs, ipairs
local UnitName, UnitGUID, UnitCreatureType, UnitHealthMax, UnitLevel = UnitName, UnitGUID, UnitCreatureType, UnitHealthMax, UnitLevel

--[[
  Bind macros:
  1. Add clone
  /run MDT:AddCloneAtCursorPosition()
  2. Add patrol point to clone
  /run MDT:AddPatrolWaypointAtCursorPosition()
  3. Add untargetable unit if needed
  /run MDT:AddNPCFromUnit("mouseover")
]]

function MDT:ToggleDevMode()
  db = MDT:GetDB()
  db.devMode = not db.devMode
  ReloadUI()
end

function MDT:AddNPCFromUnit(unit)
  db = MDT:GetDB()
  local npcId
  local guid = UnitGUID(unit)
  if guid then
    npcId = select(6, strsplit("-", guid))
    npcId = tonumber(npcId)
  end
  local added
  for _, npcData in pairs(MDT.dungeonEnemies[db.currentDungeonIdx]) do
    if npcData.id == npcId then
      added = true; break
    end
  end
  if npcId and not added then
    local npcName = UnitName(unit)
    local npcHealth = UnitHealthMax(unit)
    local npcLevel = UnitLevel(unit)
    local npcCreatureType = UnitCreatureType(unit)
    local npcScale = 1
    local npcCount = 0
    tinsert(MDT.dungeonEnemies[db.currentDungeonIdx], {
      name = npcName,
      health = npcHealth,
      level = npcLevel,
      creatureType = npcCreatureType,
      id = npcId,
      scale = npcScale,
      count = npcCount,
      clones = {},
    })
    return npcId
  end
end

local currentEnemyIdx
local currentCloneGroup
local currentPatrol
local currentBossEnemyIdx = 1
local currentCloneScale
---CreateDevPanel
---Creates the dev panel which contains buttons to add npcs, objects to the map
function MDT:CreateDevPanel(frame)
  db = MDT:GetDB()
  frame.devPanel = AceGUI:Create("TabGroup")
  local devPanel = frame.devPanel
  devPanel.frame:SetFrameStrata("HIGH")
  devPanel.frame:SetFrameLevel(50)

  devPanel:SetTabs(
    {
      { text = "POI/Zoom",  value = "tab1" },
      { text = "Enemy",     value = "tab2" },
      { text = "Manage DB", value = "tab3" },
    }
  )
  devPanel:SetWidth(250)
  devPanel:ClearAllPoints()
  devPanel:SetPoint("TOPRIGHT", frame.topPanel, "TOPLEFT", 0, 0)
  devPanel:SetLayout("Flow")
  devPanel.frame:Hide()

  MDT:FixAceGUIShowHide(devPanel)

  -- function that draws the widgets for the first tab
  local function DrawGroup1(container)
    --mapLink Options
    local option1 = AceGUI:Create("EditBox")
    option1:SetLabel("Target Floor / Bot Index")
    option1:SetText(1)
    local option2 = AceGUI:Create("EditBox")
    option2:SetLabel("Direction 1up -1d 2r -2l")
    option2:SetText(1)
    container:AddChild(option1)
    container:AddChild(option2)

    --door options
    local option3 = AceGUI:Create("EditBox")
    option3:SetLabel("Door Name / Connected Index")
    option3:SetText("")
    local option4 = AceGUI:Create("EditBox")
    option4:SetLabel("Door Descripting")
    option4:SetText("")
    local lockedCheckbox = AceGUI:Create("CheckBox")
    lockedCheckbox:SetLabel("Lockpickable")
    container:AddChild(option3)
    container:AddChild(option4)
    container:AddChild(lockedCheckbox)

    --graveyard options
    local option5 = AceGUI:Create("EditBox")
    option5:SetLabel("Graveyard Description / General Note Text")
    option5:SetText("")
    container:AddChild(option5)

    local buttons = {
      [1] = {
        text = "MapLink",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local links = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local posx, posy = 300, -200
          local t = tonumber(option1:GetText())
          local d = tonumber(option2:GetText())
          local c = tonumber(option3:GetText())
          if t and d then
            tinsert(links,
              {
                x = posx,
                y = posy,
                target = t,
                direction = d,
                connectionIndex = c,
                template = "MapLinkPinTemplate",
                type = "mapLink"
              })
            MDT:POI_UpdateAll()
          end
        end,
      },
      [2] = {
        text = "Door",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local links = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local posx, posy = 300, -200
          local doorNameText = option3:GetText()
          local doorDescriptionText = option4:GetText()
          local lockpickableStatus = lockedCheckbox:GetValue() or nil
          tinsert(links,
            {
              x = posx,
              y = posy,
              template = "MapLinkPinTemplate",
              type = "door",
              doorName = doorNameText,
              doorDescription = doorDescriptionText,
              lockpick = lockpickableStatus
            })
          MDT:POI_UpdateAll()
        end,
      },
      [3] = {
        text = "Graveyard",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local links = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local posx, posy = 300, -200
          local graveyardDescriptionText = option5:GetText()
          tinsert(links,
            {
              x = posx,
              y = posy,
              template = "DeathReleasePinTemplate",
              type = "graveyard",
              graveyardDescription = graveyardDescriptionText
            })
          MDT:POI_UpdateAll()
        end,
      },
      [4] = {
        text = "General Note",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local pois = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local posx, posy = 300, -200
          local noteText = option5:GetText()
          tinsert(pois, { x = posx, y = posy, template = "MapLinkPinTemplate", type = "generalNote", text = noteText })
          MDT:POI_UpdateAll()
        end,
      },
      [5] = {
        text = "Heavy Cannon",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local pois = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local posx, posy = 300, -200
          tinsert(pois, { x = posx, y = posy, template = "MapLinkPinTemplate", type = "heavyCannon" })
          MDT:POI_UpdateAll()
        end,
      },
      [6] = {
        text = "Mechagon Bot",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local pois = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local botType = tonumber(option1:GetText())
          local posx, posy = 400 + (30 * botType), -250
          tinsert(pois, { x = posx, y = posy, template = "MapLinkPinTemplate", type = "mechagonBot", botType = botType })
          MDT:POI_UpdateAll()
        end,
      },
      [7] = {
        text = "Iron Docks Iron Star",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local pois = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local posx, posy = 430, -250
          tinsert(pois,
            { x = posx, y = posy, template = "MapLinkPinTemplate", type = "ironDocksIronStar", starIndex = 1 })
          MDT:POI_UpdateAll()
        end,
      },
      [8] = {
        text = "Text Frame",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local pois = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local posx, posy = 430, -250
          local text = option5:GetText()
          tinsert(pois,
            { x = posx, y = posy, template = "MapLinkPinTemplate", type = "textFrame", text = text })
          MDT:POI_UpdateAll()
        end,
      },
      [9] = {
        text = "Zoom Icon",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local pois = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local posx, posy = 430, -250

          local index = MDTMapPanelFrame:GetScale() - 2 -- this is the threshold after which the button should zoom out
          local value1 = MDTMapPanelFrame:GetScale()
          local value2 = MDTScrollFrame:GetHorizontalScroll() / MDT:GetScale()
          local value3 = MDTScrollFrame:GetVerticalScroll() / MDT:GetScale()
          tinsert(pois,
            {
              x = posx,
              y = posy,
              template = "MapLinkPinTemplate",
              type = "zoom",
              index = index,
              value1 = value1,
              value2 = value2,
              value3 = value3
            })
          MDT:POI_UpdateAll()
        end,
      },
      [10] = {
        text = "World Marker",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local pois = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local posx, posy = 430, -250
          local index = tonumber(option5:GetText())
          tinsert(pois,
            { x = posx, y = posy, template = "MapLinkPinTemplate", type = "worldMarker", index = index })
          MDT:POI_UpdateAll()
        end,
      },
      [11] = {
        text = "Brackenhide Cage",
        func = function()
          if not MDT.mapPOIs[db.currentDungeonIdx] then MDT.mapPOIs[db.currentDungeonIdx] = {} end
          if not MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] then
            MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()] = {}
          end
          local pois = MDT.mapPOIs[db.currentDungeonIdx][MDT:GetCurrentSubLevel()]
          local cageIndex = tonumber(option1:GetText())
          local posx, posy = 400, -250
          tinsert(pois, { x = posx, y = posy, template = "MapLinkPinTemplate", type = "brackenhideCage", cageIndex = cageIndex })
          MDT:POI_UpdateAll()
        end,
      },
      [12] = {
        text = "Export Zoom Settings",
        func = function()
          MDT:ExportCurrentZoomPanSettings()
        end,
      },
      [13] = {
        text = "Export to LUA",
        func = function()
          local export = MDT:ExportLuaTable(MDT.mapPOIs[db.currentDungeonIdx], MDT:GetSchema("pois"))
          MDT:ExportString(export)
        end,
      },
    }
    for buttonIdx, buttonData in ipairs(buttons) do
      local button = AceGUI:Create("Button")
      button:SetText(buttonData.text)
      button:SetCallback("OnClick", buttonData.func)
      container:AddChild(button)
    end
  end

  -- function that draws the widgets for the second tab
  local function DrawGroup2(container)
    local editBoxes = {}
    local countSlider
    local scaleSlider
    local dropdown

    local function updateFields(health, level, creatureType, id, scale, count, idx)
      if idx then
        local data = MDT.dungeonEnemies[db.currentDungeonIdx][idx]
        if not data then return end
        health = data.health
        level = data.level
        creatureType = data.creatureType
        id = data.id
        scale = data.scale
        count = data.count
      end
      editBoxes[1]:SetText(id)
      editBoxes[2]:SetText(health)
      editBoxes[3]:SetText(level)
      editBoxes[4]:SetText(creatureType)
      scaleSlider:SetValue(scale)
      countSlider:SetValue(count)
    end

    local enemyInfoButton = AceGUI:Create("Button")
    enemyInfoButton:SetText("Open Enemy Info")
    enemyInfoButton:SetCallback("OnClick", function()
      local devBlip = MDT:GetCurrentDevmodeBlip()
      if devBlip then MDT:ShowEnemyInfoFrame(devBlip) else print("MDT DevMode: Please select a blip") end
    end)
    container:AddChild(enemyInfoButton)

    local collectedSpellsButton = AceGUI:Create("Button")
    collectedSpellsButton:SetText("Add collected spells")
    collectedSpellsButton:SetCallback("OnClick", function()
      MDT.DataCollection:AddCollectedDataToEnemyTable(db.currentDungeonIdx, false, true)
    end)
    container:AddChild(collectedSpellsButton)

    local collectedCharacteristicsButton = AceGUI:Create("Button")
    collectedCharacteristicsButton:SetText("Add collected characteristics")
    collectedCharacteristicsButton:SetCallback("OnClick", function()
      MDT.DataCollection:AddCollectedDataToEnemyTable(db.currentDungeonIdx, true, false)
    end)
    container:AddChild(collectedCharacteristicsButton)

    local collectedHealthButton = AceGUI:Create("Button")
    collectedHealthButton:SetText("Add collected Health Values")
    collectedHealthButton:SetCallback("OnClick", function()
      if db.newDataCollectionActive then
        MDT:ProcessHealthTrack()
      else
        print("MDT DevMode: Cant process Health Track, reload to enable Data Collection first!")
        MDT:ToggleDataCollection()
      end
    end)
    container:AddChild(collectedHealthButton)

    local cleanSpellDataButton = AceGUI:Create("Button")
    cleanSpellDataButton:SetText("Clean spells")
    cleanSpellDataButton:SetCallback("OnClick", function()
      MDT:CleanEnemyInfoSpells()
    end)
    container:AddChild(cleanSpellDataButton)

    local findCloneIssuesButton = AceGUI:Create("Button")
    findCloneIssuesButton:SetText("Find Clone Issues")
    findCloneIssuesButton:SetCallback("OnClick", function()
      local issues = ""
      for i = 1, 200 do
        local enemies = MDT.dungeonEnemies[i]
        local dungeonIssues
        if enemies then
          for _, enemy in pairs(enemies) do
            local l = #enemy.clones
            local realLength = 0
            for _, _ in pairs(enemy.clones) do
              realLength = realLength + 1
            end
            if l ~= realLength then
              dungeonIssues = dungeonIssues or ("--- "..MDT.dungeonList[i]).."\n"
              dungeonIssues = dungeonIssues..enemy.name.."\n"
            end
          end
          if dungeonIssues then
            issues = issues..dungeonIssues.."\n"
          end
        end
      end
      MDT:ExportString(issues)
    end)
    container:AddChild(findCloneIssuesButton)

    local findMissingLocaleButton = AceGUI:Create("Button")
    findMissingLocaleButton:SetText("Find Missing Localizations")
    findMissingLocaleButton:SetCallback("OnClick", function()
      local issues = ""
      for i = 1, 200 do
        local enemies = MDT.dungeonEnemies[i]
        local dungeonIssues
        if enemies then
          for _, enemy in pairs(enemies) do
            if not MDT.L[enemy.name] then
              dungeonIssues = dungeonIssues or ("--- "..MDT.dungeonList[i]).."\n"
              dungeonIssues = dungeonIssues..("L[\"%s\"] = \"%s\"\n"):format(enemy.name, enemy.name)
            end
          end
          if dungeonIssues then
            issues = issues..dungeonIssues.."\n"
          end
        end
      end
      MDT:ExportString(issues)
    end)
    container:AddChild(findMissingLocaleButton)

    local button3 = AceGUI:Create("Button")
    button3:SetText("Export to LUA")
    button3:SetCallback("OnClick", function()
      MDT:CleanEnemyData(db.currentDungeonIdx)
      local export = MDT:ExportLuaTable(MDT.dungeonEnemies[db.currentDungeonIdx], MDT:GetSchema("enemies"))
      MDT:ExportString(export)
    end)
    container:AddChild(button3)

    local function updateDropdown(npcId, idx)
      if not MDT.dungeonEnemies[db.currentDungeonIdx] then return end
      idx = idx or 1
      local enemies = {}
      for mobIdx, data in ipairs(MDT.dungeonEnemies[db.currentDungeonIdx]) do
        tinsert(enemies, mobIdx, data.name)
        if npcId then
          if data.id == npcId then idx = mobIdx end
        end
      end
      dropdown:SetList(enemies)
      dropdown:SetValue(idx)
      currentEnemyIdx = idx
      updateFields(nil, nil, nil, nil, nil, nil, idx)
    end

    dropdown = AceGUI:Create("Dropdown")
    dropdown:SetCallback("OnValueChanged", function(widget, callbackName, key)
      currentEnemyIdx = key
      updateFields(nil, nil, nil, nil, nil, nil, key)
      local dungeonEnemyBlips = MDT:GetDungeonEnemyBlips()
      for _, v in ipairs(dungeonEnemyBlips) do
        v.devSelected = nil
      end
      MDT:UpdateMap()
    end)

    container:AddChild(dropdown)

    countSlider = AceGUI:Create("Slider")
    countSlider:SetLabel("Count")
    countSlider:SetSliderValues(0, 15, 1)
    countSlider:SetValue(4)
    countSlider:SetCallback("OnMouseUp", function(widget, callbackName, value)
      local count = tonumber(value)
      local npcIdx = tonumber(dropdown:GetValue())

      local data = MDT.dungeonEnemies[db.currentDungeonIdx][npcIdx]
      data["count"] = value
      MDT:UpdateMap()
    end)
    container:AddChild(countSlider)
    local fields = {
      [1] = "id",
      [2] = "health",
      [3] = "level",
      [4] = "creatureType",
    }
    for idx, name in ipairs(fields) do
      editBoxes[idx] = AceGUI:Create("EditBox")
      editBoxes[idx]:SetLabel(name)
      editBoxes[idx]:SetCallback("OnEnterPressed", function(widget, callbackName, text)
        local value = text
        if name ~= "creatureType" then
          value = tonumber(text)
        end
        local npcIdx = dropdown:GetValue()
        local data = MDT.dungeonEnemies[db.currentDungeonIdx][npcIdx]
        data[name] = value
        MDT:UpdateMap()
      end)
      container:AddChild(editBoxes[idx])
    end

    scaleSlider = AceGUI:Create("Slider")
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetSliderValues(0, 5, 0.1)
    scaleSlider:SetValue(1)
    scaleSlider:SetCallback("OnMouseUp", function(widget, callbackName, value)
      local npcIdx = tonumber(dropdown:GetValue())
      local data = MDT.dungeonEnemies[db.currentDungeonIdx][npcIdx]
      data["scale"] = value
      MDT:UpdateMap()
    end)
    container:AddChild(scaleSlider)

    local button1 = AceGUI:Create("Button")
    button1:SetText("Create from Target")
    button1:SetCallback("OnClick", function()
      local npcId = MDT:AddNPCFromUnit("target")
      updateDropdown(npcId)
    end)
    container:AddChild(button1)

    --make boss
    local button2 = AceGUI:Create("Button")
    button2:SetText("Make Boss")
    button2:SetCallback("OnClick", function()
      local currentBlip = MDT:GetCurrentDevmodeBlip()
      if currentBlip then
        --encounterID
        local encounterID, encounterName, description, displayInfo, iconImage = EJ_GetCreatureInfo(1)
        if not encounterID then
          print("MDT: Error - Make sure to open Encounter Journal and navigate to the boss you want to add!")
          return
        end
        for i = 1, 10000 do
          local ixd = EJ_GetCreatureInfo(currentBossEnemyIdx, i)
          if ixd == encounterID then
            encounterID = i
            break
          end
        end
        local data = MDT.dungeonEnemies[db.currentDungeonIdx][currentBlip.enemyIdx]
        data.isBoss = true
        local mapID = C_Map.GetBestMapForUnit("player")
        data.instanceID = mapID and EJ_GetInstanceForMap(mapID) or 0
        data.encounterID = encounterID
        --use this data as follows:
        --if (not EncounterJournal) then LoadAddOn('Blizzard_EncounterJournal') end
        --EncounterJournal_OpenJournal(23,data.instanceID,data.encounterID)
        MDT:UpdateMap()
      end
    end)
    container:AddChild(button2)

    --blips movable toggle
    local blipsMovableCheckbox = AceGUI:Create("CheckBox")
    blipsMovableCheckbox:SetLabel("Blips Movable")
    blipsMovableCheckbox:SetCallback("OnValueChanged", function(widget, callbackName, value)
      db.devModeBlipsMovable = value or nil
    end)
    container:AddChild(blipsMovableCheckbox)

    --blips scrollable toggle
    local blipsScrollableCheckbox = AceGUI:Create("CheckBox")
    blipsScrollableCheckbox:SetLabel("Blips Scrollable")
    blipsScrollableCheckbox:SetCallback("OnValueChanged", function(widget, callbackName, value)
      db.devModeBlipsScrollable = value or nil
    end)
    container:AddChild(blipsScrollableCheckbox)

    --bliptext shown toggle
    local blipTextHiddenCheckbox = AceGUI:Create("CheckBox")
    blipTextHiddenCheckbox:SetLabel("Hide Blip Text")
    blipTextHiddenCheckbox:SetCallback("OnValueChanged", function(widget, callbackName, value)
      db.devModeBlipTextHidden = value or nil
      MDT:UpdateMap()
    end)
    container:AddChild(blipTextHiddenCheckbox)

    --clone options

    --group
    local cloneGroup = AceGUI:Create("EditBox")
    cloneGroup:SetLabel("Group of clone:")
    cloneGroup:SetCallback("OnEnterPressed", function(widget, callbackName, text)
      local value = tonumber(text)
      if value and value > 0 then currentCloneGroup = value else currentCloneGroup = nil end
      local currentBlip = MDT:GetCurrentDevmodeBlip()
      if currentBlip then
        local data = MDT.dungeonEnemies[db.currentDungeonIdx][currentBlip.enemyIdx]
        data.clones[currentBlip.cloneIdx].g = currentCloneGroup
        MDT:UpdateMap()
      end
    end)
    container:AddChild(cloneGroup)

    local cloneGroupMaxButton = AceGUI:Create("Button")
    cloneGroupMaxButton:SetText("New Group")
    cloneGroupMaxButton:SetCallback("OnClick", function(widget, callbackName)
      local maxGroup = 0
      for _, data in pairs(MDT.dungeonEnemies[db.currentDungeonIdx]) do
        for _, clone in pairs(data.clones) do
          maxGroup = (clone.g and (clone.g > maxGroup)) and clone.g or maxGroup
        end
      end
      currentCloneGroup = maxGroup + 1
      cloneGroup:SetText(currentCloneGroup)
    end)
    container:AddChild(cloneGroupMaxButton)

    --patrol
    local patrolCheckbox = AceGUI:Create("CheckBox")
    patrolCheckbox:SetLabel("Patrol")
    patrolCheckbox:SetCallback("OnValueChanged", function(widget, callbackName, value)
      currentPatrol = value or nil
      local currentBlip = MDT:GetCurrentDevmodeBlip()
      if currentBlip then
        local data = MDT.dungeonEnemies[db.currentDungeonIdx][currentBlip.enemyIdx]
        data.clones[currentBlip.cloneIdx].patrol = currentPatrol and (data.clones[currentBlip.cloneIdx].patrol or {}) or
            nil
        if not data.clones[currentBlip.cloneIdx].patrol then
          currentBlip.patrolActive = false
        end
        MDT:UpdateMap()
      end
    end)
    container:AddChild(patrolCheckbox)

    --stealthdetect
    local stealthDetectCheckbox = AceGUI:Create("CheckBox")
    stealthDetectCheckbox:SetLabel("Stealth Detect")
    stealthDetectCheckbox:SetCallback("OnValueChanged", function(widget, callbackName, value)
      local currentBlip = MDT:GetCurrentDevmodeBlip()
      local data = MDT.dungeonEnemies[db.currentDungeonIdx][currentBlip.enemyIdx]
      data.stealthDetect = value or nil
      MDT:UpdateMap()
    end)
    container:AddChild(stealthDetectCheckbox)

    --stealth
    local stealthCheckbox = AceGUI:Create("CheckBox")
    stealthCheckbox:SetLabel("Stealthed")
    stealthCheckbox:SetCallback("OnValueChanged", function(widget, callbackName, value)
      local currentBlip = MDT:GetCurrentDevmodeBlip()
      local data = MDT.dungeonEnemies[db.currentDungeonIdx][currentBlip.enemyIdx]
      data.stealth = value or nil
      MDT:UpdateMap()
    end)
    container:AddChild(stealthCheckbox)

    --neutral
    local neutralCheckbox = AceGUI:Create("CheckBox")
    neutralCheckbox:SetLabel("Neutral")
    neutralCheckbox:SetCallback("OnValueChanged", function(widget, callbackName, value)
      local currentBlip = MDT:GetCurrentDevmodeBlip()
      local data = MDT.dungeonEnemies[db.currentDungeonIdx][currentBlip.enemyIdx]
      data.neutral = value or nil
      MDT:UpdateMap()
    end)
    container:AddChild(neutralCheckbox)

    --sublevel
    local sublevel = AceGUI:Create("EditBox")
    sublevel:SetLabel("Sublevel:")
    sublevel:SetCallback("OnEnterPressed", function(widget, callbackName, text)
      local value = tonumber(text)
      local currentBlip = MDT:GetCurrentDevmodeBlip()
      if currentBlip then
        local data = MDT.dungeonEnemies[db.currentDungeonIdx][currentBlip.enemyIdx]
        data.clones[currentBlip.cloneIdx].sublevel = value
        MDT:UpdateMap()
      end
    end)
    container:AddChild(sublevel)

    --enter clone options into the GUI (red)
    local currentBlip = MDT:GetCurrentDevmodeBlip()
    if currentBlip then
      cloneGroup:SetText(currentBlip.clone.g)
      currentCloneGroup = currentBlip.clone.g
      currentCloneScale = currentBlip.clone.scale
      currentPatrol = currentBlip.patrol and true or nil
      patrolCheckbox:SetValue(currentBlip.clone.patrol)
      stealthDetectCheckbox:SetValue(currentBlip.data.stealthDetect)
      stealthCheckbox:SetValue(currentBlip.data.stealth)
      neutralCheckbox:SetValue(currentBlip.data.neutral)
      sublevel:SetText(currentBlip.clone.sublevel)
    else
      cloneGroup:SetText(currentCloneGroup)
    end
    blipsMovableCheckbox:SetValue(db.devModeBlipsMovable)
    blipsScrollableCheckbox:SetValue(db.devModeBlipsScrollable)
    blipTextHiddenCheckbox:SetValue(db.devModeBlipTextHidden)

    updateDropdown(nil, currentEnemyIdx)
  end

  local function DrawGroup3(container)
    local toggleDevModeButton = AceGUI:Create("Button")
    toggleDevModeButton:SetText("Toggle DevMode")
    toggleDevModeButton:SetCallback("OnClick", function()
      MDT:ToggleDevMode()
    end)
    container:AddChild(toggleDevModeButton)

    local loadOnStartUpCheckbox = AceGUI:Create("CheckBox")
    loadOnStartUpCheckbox:SetLabel("Load MDT on Startup")
    loadOnStartUpCheckbox:SetCallback("OnValueChanged", function(widget, callbackName, value)
      db.loadOnStartUp = value or nil
    end)
    loadOnStartUpCheckbox:SetValue(db.loadOnStartUp)
    container:AddChild(loadOnStartUpCheckbox)

    local loadCacheCheckbox = AceGUI:Create("CheckBox")
    loadCacheCheckbox:SetLabel("Load Cache in devmode")
    loadCacheCheckbox:SetCallback("OnValueChanged", function(widget, callbackName, value)
      db.loadCache = value or nil
      if value then
        ReloadUI()
      end
    end)
    loadCacheCheckbox:SetValue(db.loadCache)
    container:AddChild(loadCacheCheckbox)

    local clearCacheButton = AceGUI:Create("Button")
    clearCacheButton:SetText("Clear Cache + DC")
    clearCacheButton:SetCallback("OnClick", function()
      MDT:ResetDataCache()
      db.dataCollection = {}
      db.dataCollectionCC = {}
    end)
    container:AddChild(clearCacheButton)

    local resetDbButton = AceGUI:Create("Button")
    resetDbButton:SetText("Hard Reset DB")
    resetDbButton:SetCallback("OnClick", function()
      MDT:OpenConfirmationFrame(300, 150, "Reset MDT DB", "Confirm", "Do you want to reset MDT DB?", function()
        MDT:HardReset()
      end, "Cancel", nil)
    end)
    container:AddChild(resetDbButton)

    local vdtDbButton = AceGUI:Create("Button")
    vdtDbButton:SetText("VDT DB")
    vdtDbButton:SetCallback("OnClick", function()
      DevTool:AddData(db)
    end)
    container:AddChild(vdtDbButton)

    local leechButton = AceGUI:Create("Button")
    leechButton:SetText("Leech Data")
    leechButton:SetCallback("OnClick", function()
      MDT:RequestDataCollectionUpdate()
    end)
    container:AddChild(leechButton)
  end

  -- Callback function for OnGroupSelected
  local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if group == "tab1" then
      DrawGroup1(container)
    elseif group == "tab2" then
      DrawGroup2(container)
    elseif group == "tab3" then
      DrawGroup3(container)
    end
  end

  devPanel:SetCallback("OnGroupSelected", SelectGroup)
  devPanel:SelectTab("tab2")

  --hook UpdateMap
  local originalFunc = MDT.UpdateMap
  function MDT:UpdateMap(...)
    originalFunc(...)
    local selectedTab
    for k, v in pairs(devPanel.tabs) do
      if v.selected == true then
        selectedTab = v.value; break
      end
    end
    --currentEnemyIdx
    local currentBlip = MDT:GetCurrentDevmodeBlip()
    if currentBlip then
      currentEnemyIdx = currentBlip.enemyIdx
    end
    devPanel:SelectTab(selectedTab)
    --show patrol
    local dungeonEnemyBlips = MDT:GetDungeonEnemyBlips()
    for _, v in ipairs(dungeonEnemyBlips) do
      v:DisplayPatrol(v.devSelected)
    end
  end
end

---AddCloneAtCursorPosition
---Adds a clone at the cursor position to the dungeon enemy table
---bound to hotkey and used to add new npcs to the map
function MDT:AddCloneAtCursorPosition()
  if not MouseIsOver(MDTScrollFrame) then return end
  if currentEnemyIdx then
    local data = MDT.dungeonEnemies[db.currentDungeonIdx][currentEnemyIdx]
    local cursorx, cursory = MDT:GetCursorPosition()
    local scale = self:GetScale()
    cursorx = cursorx * (1 / scale)
    cursory = cursory * (1 / scale)
    tinsert(data.clones,
      {
        x = cursorx,
        y = cursory,
        sublevel = MDT:GetCurrentSubLevel(),
        g = currentCloneGroup,
        scale = currentCloneScale
      })
    print(string.format("MDT: Created clone %s %d at %d,%d", data.name, #data.clones, cursorx, cursory))
    MDT:UpdateMap()
  end
end

---AddPatrolWaypointAtCursorPosition
---Adds a patrol waypoint to the selected enemy
function MDT:AddPatrolWaypointAtCursorPosition()
  if not MouseIsOver(MDTScrollFrame) then return end
  local currentBlip = MDT:GetCurrentDevmodeBlip()
  if currentBlip then
    local data = MDT.dungeonEnemies[db.currentDungeonIdx][currentBlip.enemyIdx]
    local cloneData = data.clones[currentBlip.cloneIdx]
    cloneData.patrol = cloneData.patrol or {}
    cloneData.patrol[1] = { x = cloneData.x, y = cloneData.y }
    local cursorx, cursory = MDT:GetCursorPosition()
    local scale = MDT:GetScale()
    cursorx = cursorx * (1 / scale)
    cursory = cursory * (1 / scale)
    --snap onto other waypoints
    local patrolBlips = MDT:GetPatrolBlips()
    for idx, waypoint in pairs(patrolBlips) do
      if MouseIsOver(waypoint) then
        cursorx = waypoint.x
        cursory = waypoint.y
      end
    end
    --snap onto blip
    if MouseIsOver(currentBlip) then
      cursorx = currentBlip.clone.x
      cursory = currentBlip.clone.y
    end
    tinsert(cloneData.patrol, { x = cursorx, y = cursory })
    print(string.format("MDT: Created Waypoint %d of %s %d at %d,%d", 1, data.name, #cloneData.patrol, cursorx, cursory))
    MDT:UpdateMap()
  end
end
