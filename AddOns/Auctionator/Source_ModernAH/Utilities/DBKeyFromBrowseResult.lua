local function IsGear(itemID)
  local classType = select(6, C_Item.GetItemInfoInstant(itemID))
  return Auctionator.Utilities.IsEquipment(classType)
end

function Auctionator.Utilities.DBKeyFromItemKey(itemKey, callback)
  if itemKey.battlePetSpeciesID ~= 0 then
    callback({"p:" .. tostring(itemKey.battlePetSpeciesID)})
  elseif IsGear(itemKey.itemID) then
    local basicKey = tostring(itemKey.itemID)
    if Auctionator.Constants.IsForever then
      Auctionator.AH.GetItemKeyInfo(itemKey, function(info)
        local name = info.itemName
        Item:CreateFromItemID(itemKey.itemID):ContinueOnItemLoad(function()
          local baseName = C_Item.GetItemNameByID(itemKey.itemID)
          if name ~= baseName then
            local suffix = name:sub(string.len(baseName.. " ") + 1)
            local index = Auctionator.Utilities.SuffixesToLabel[suffix]
            if english then
              callback({"gr:" .. itemKey.itemID .. ":" .. index, basicKey})
            elseif #Auctionator.Utilities.SuffixesExtraChecks > 0 then
              local seen = false
              for _, bonusID in ipairs(Auctionator.Utilities.SuffixesExtraChecks) do
                local newLink = "item:" .. itemKey.itemID .. string.rep(":", 12) .. "1:" .. bonusID
                local newName = C_Item.GetItemNameByID(newLink)
                if newName == name then
                  local index = Auctionator.Utilities.SuffixBonusIDs[bonusID]
                  callback({"gr:" .. itemKey.itemID .. ":" .. index, basicKey})
                  seen = true
                  break
                end
              end
              if not seen then
                callback({basicKey})
              end
            else
              callback({basicKey})
            end
          else
            callback({basicKey})
          end
        end)
      end)
    elseif itemKey.itemLevel >= Auctionator.Constants.ITEM_LEVEL_THRESHOLD then
      callback({
        "g:" .. itemKey.itemID .. ":" .. itemKey.itemLevel,
        basicKey
      })
    else
      callback({basicKey})
    end
  else
    callback({tostring(itemKey.itemID)})
  end
end

function Auctionator.Utilities.DBKeyFromBrowseResult(result)
  if result.itemKey.battlePetSpeciesID ~= 0 then
    return {"p:" .. tostring(result.itemKey.battlePetSpeciesID)}
  elseif IsGear(result.itemKey.itemID) and result.itemKey.itemLevel >= Auctionator.Constants.ITEM_LEVEL_THRESHOLD then
    return {
      "g:" .. result.itemKey.itemID .. ":" .. result.itemKey.itemLevel,
      tostring(result.itemKey.itemID)
    }
  else
    return {tostring(result.itemKey.itemID)}
  end
end
