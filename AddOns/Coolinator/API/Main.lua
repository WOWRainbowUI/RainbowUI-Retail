
---@class addonTableCoolinator
local addonTable = select(2, ...)

function Coolinator.API.ImportString(importText, resultName)
  local prefix = importText:match("^COOLI!1!")
  if not prefix then
    addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_IMPORT)
    return
  end
  local status, decoded = pcall(C_EncodingUtil.DecodeBase64, importText:sub(9))
  if not status then
    addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_IMPORT)
    return
  end
  local status, decompressed = pcall(C_EncodingUtil.DecompressString, decoded)
  if not status then
    addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_IMPORT)
    return
  end
  local status, import = pcall(C_EncodingUtil.DeserializeCBOR, decompressed)
  if not status or type(import) ~= "table" or import.addon ~= "Coolinator" then
    addonTable.Dialogs.ShowAcknowledge(addonTable.Locales.INVALID_IMPORT)
    return
  end

  local result, reason = addonTable.CustomiseDialog.ImportData(import, resultName, true)

  if result then
    addonTable.Utilities.Message(addonTable.Locales.THANKS_FOR_USING_COOLINATOR_DONATE .. " https://linktr.ee/plusmouse")
  else
    error("Invalid Coolinator import")
  end
end
