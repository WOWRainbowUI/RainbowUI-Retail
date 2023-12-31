local _, addonTable = ...

function Baganator.API.GetInventoryInfo(itemLink, sameConnectedRealm, sameFaction)
  local success, key = pcall(Baganator.Utilities.GetItemKey, itemLink)
  if not success then
    error("Bad item link. Try using one generated by a call to GetItemInfo.")
    return
  end

  return Baganator.ItemSummaries:GetTooltipInfo(key, sameConnectedRealm == true, sameFaction == true)
end

-- callback - function(bagID, slotID, itemID, itemLink) returns nil/true/false
--  Returning true indicates this item is junk and should show a junk coin
--  Returning false or nil indicates this item isn't junk and shouldn't show a
--  junk coin
function Baganator.API.RegisterJunkPlugin(label, id, callback)
  if type(label) ~= "string" or type(id) ~= "string" or type(callback) ~= "function" then
    error("Bad junk plugin arguments")
  end

  addonTable.JunkPlugins[id] = {
    label = label,
    callback = callback,
  }
end

function Baganator.API.RequestItemButtonsRefresh()
  Baganator.CallbackRegistry:TriggerEvent("ContentRefreshRequired")
end
