---@class addonTableCoolinator
local addonTable = select(2, ...)

function addonTable.Designer.Options.GetPresets(parent)
  local dropdown = addonTable.CustomiseDialog.Components.GetBasicDropdown(parent, addonTable.Locales.PRESET)
  local details
  function dropdown:SetValue(d)
    details = d
    dropdown.DropDown:SetupMenu(function(_, rootDescription)
      local presets = GetKeysArray(addonTable.Core.GetApplicablePresets(details) or {})
      if #presets > 0 then
        table.sort(presets)
        for _, p in ipairs(presets) do
          local label = p
          if addonTable.Locales[p] then
            label = BLUE_FONT_COLOR:WrapTextInColorCode(addonTable.Locales[p])
          end
          local button = rootDescription:CreateRadio(label, function() return details.preset == p end, function()
            details.preset = p
            addonTable.Core.ApplyPresetToDetails(details)
            addonTable.Designer.Options.Announce()
          end)
          button:AddInitializer(function(button, description, menu)
            if InCombatLockdown() then
              return
            end
            local delete = MenuTemplates.AttachAutoHideButton(button, "transmog-icon-remove")
            delete:SetPoint("RIGHT")
            delete:SetSize(18, 18)
            delete.Texture:SetAtlas("transmog-icon-remove")
            delete:SetScript("OnClick", function()
              menu:Close()
              addonTable.Dialogs.ShowConfirm(addonTable.Locales.CONFIRM_DELETE_PRESET_X:format(label), YES, NO, function()
                addonTable.Core.DeletePreset(p, details, addonTable.Designer.GetCurrent())
                dropdown.DropDown:GenerateMenu()
              end)
            end)
            MenuUtil.HookTooltipScripts(delete, function(tooltip)
              GameTooltip_SetTitle(tooltip, DELETE)
            end)
          end)
        end
        rootDescription:CreateDivider()
      end
      rootDescription:CreateButton(NORMAL_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.CREATE_PRESET), function()
        addonTable.Dialogs.ShowEditBox(addonTable.Locales.ENTER_PRESET_NAME, OKAY, CANCEL, function(value)
          details.preset = value
          addonTable.Core.SavePreset(value, details.___origin or details, true)
          dropdown.DropDown:GenerateMenu()
        end)
      end)
      rootDescription:CreateButton(addonTable.Locales.DETACH_PRESET, function()
        details.preset = nil
        addonTable.Designer.Options.Announce()
      end)
    end)
  end
  dropdown.DropDown:SetDefaultText(GRAY_FONT_COLOR:WrapTextInColorCode(addonTable.Locales.NONE_SET))

  return dropdown
end
