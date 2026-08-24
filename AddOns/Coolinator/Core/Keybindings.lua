---@class addonTableCoolinator
local addonTable = select(2, ...)

local actionButtons = {
  { prefix = "ACTIONBUTTON", count = 12, start = 1},
  { prefix = "MULTIACTIONBAR1BUTTON", count = 12, start = 61},
  { prefix = "MULTIACTIONBAR2BUTTON", count = 12, start = 49},
  { prefix = "MULTIACTIONBAR3BUTTON", count = 12, start = 25},
  { prefix = "MULTIACTIONBAR4BUTTON", count = 12, start = 37},
  { prefix = "MULTIACTIONBAR5BUTTON", count = 12, start = 145},
  { prefix = "MULTIACTIONBAR6BUTTON", count = 12, start = 157},
  { prefix = "MULTIACTIONBAR6BUTTON", count = 12, start = 169},
}
local bonusActionButtons = {
  { prefix = "ACTIONBUTTON", count = 12, start = 73}, -- Bonus bars
  { prefix = "ACTIONBUTTON", count = 12, start = 85}, -- Bonus bars
  { prefix = "ACTIONBUTTON", count = 12, start = 97}, -- Bonus bars
  { prefix = "ACTIONBUTTON", count = 12, start = 109}, -- Bonus bars
  { prefix = "ACTIONBUTTON", count = 12, start = 121},
}

local function GenerateSlots()
  local tbl = CopyTable(actionButtons)
  local _, class = UnitClass("player")
  if class == "WARRIOR" then
    table.insert(tbl, bonusActionButtons[GetShapeshiftForm()])
  elseif class == "DRUID" then
    local form = GetShapeshiftForm()
    if form == 1 then
      table.insert(tbl, 1, bonusActionButtons[3])
    elseif form == 2 then
      table.insert(tbl, 1, bonusActionButtons[1])
    elseif form == 3 then
      table.insert(tbl, bonusActionButtons[2])
    elseif form >= 4 then
      table.insert(tbl, 1, bonusActionButtons[4])
    end
  elseif class == "ROGUE" then
    table.insert(tbl, bonusActionButtons[GetShapeshiftForm()])
  elseif class == "PRIEST" then
    if GetShapeshiftForm() == 1 then
      table.insert(tbl, bonusActionButtons[1])
    end
  end

  return tbl
end

function addonTable.Core.StoreKeyBindings()
  local spellMap = {}
  local itemMap = {}
  local seenBinding = {}
  for _, details in ipairs(GenerateSlots()) do
    for i = 1, details.count do
      local key1 = GetBindingKey(details.prefix .. i)
      if key1 then
        local action = details.start + i - 1
        local actionType, id, subType = GetActionInfo(action)
        if subType == "spell" then
          id = C_Spell.GetBaseSpell(id)
        end
        local text
        if key1:match("^BUTTON") then
          text = addonTable.Locales.MOUSE_BUTTON_X:format(key1:match("^BUTTON(.*)"))
        else
          text = GetBindingText(key1, 1)
        end
        if not seenBinding[text] and actionType then
          if (actionType == "spell" or actionType == "macro" and subType == "spell") and spellMap[id] == nil then
            spellMap[id] = {binding = text, action = action}
          elseif (actionType == "item" or actionType == "macro" and subType == "item") and itemMap[id] == nil then
            itemMap[id] = {binding = text, action = action}
          end
          seenBinding[text] = true
        end
      end
    end
  end

  return {spells = spellMap, items = itemMap}
end
