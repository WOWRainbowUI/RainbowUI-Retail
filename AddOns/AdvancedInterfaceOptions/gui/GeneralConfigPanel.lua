local _, addon = ...

-- Constants
local THIRD_WIDTH = 1.25

-------------------------------------------------------------------------
-------------------------------------------------------------------------

function addon:CreateGeneralOptions()
  local generalOptions = {
    type = "group",
    childGroups = "tree",
    name = "進階遊戲選項",
    args = {
      instructions = {
        type = "description",
        name = "這些選項可以調整軍臨天下改版後被移除的各種遊戲設定。",
        fontSize = "medium",
        order = 1,
      },
      header = {
        type = "header",
        name = "",
        order = 2,
      },
      -------------------------------------------------
      enforceBox = {
        type = "toggle",
        name = "啟動時強制套用設定",
        desc = "登入遊戲或切換角色時重新套用所有設定。\n\n若每次登入時設定沒有被儲存，請勾選此項。",
        get = function()
          return AdvancedInterfaceOptionsSaved.EnforceSettings
        end,
        set = function(_, value)
          AdvancedInterfaceOptionsSaved.EnforceSettings = value
        end,
        width = "full",
        order = 3,
      },
      -------------------------------------------------
      generalHeader = {
        type = "header",
        name = "一般選項",
        order = 10,
      },
      UnitNamePlayerPVPTitle = {
        type = "toggle",
        name = UNIT_NAME_PLAYER_TITLE,
        desc = OPTION_TOOLTIP_UNIT_NAME_PLAYER_TITLE,
        get = function()
          return C_CVar.GetCVarBool("UnitNamePlayerPVPTitle")
        end,
        set = function(_, value)
          self:SetCVar("UnitNamePlayerPVPTitle", value)
        end,
        width = "full",
        order = 11,
      },
      UnitNamePlayerGuild = {
        type = "toggle",
        name = UNIT_NAME_GUILD,
        desc = OPTION_TOOLTIP_UNIT_NAME_GUILD,
        get = function()
          return C_CVar.GetCVarBool("UnitNamePlayerGuild")
        end,
        set = function(_, value)
          self:SetCVar("UnitNamePlayerGuild", value)
        end,
        width = "full",
        order = 12,
      },
      UnitNameGuildTitle = {
        type = "toggle",
        name = UNIT_NAME_GUILD_TITLE,
        desc = OPTION_TOOLTIP_UNIT_NAME_GUILD_TITLE,
        get = function()
          return C_CVar.GetCVarBool("UnitNameGuildTitle")
        end,
        set = function(_, value)
          self:SetCVar("UnitNameGuildTitle", value)
        end,
        width = "full",
        order = 13,
      },
      mapFade = {
        type = "toggle",
        name = MAP_FADE_TEXT,
        desc = OPTION_TOOLTIP_MAP_FADE,
        get = function()
          return C_CVar.GetCVarBool("mapFade")
        end,
        set = function(_, value)
          self:SetCVar("mapFade", value)
        end,
        hidden = function()
          return self.IsClassicEra() or self.IsClassic()
        end,
        width = "full",
        order = 14,
      },
      secureAbilityToggle = {
        type = "toggle",
        name = SECURE_ABILITY_TOGGLE,
        desc = OPTION_TOOLTIP_SECURE_ABILITY_TOGGLE,
        get = function()
          return C_CVar.GetCVarBool("secureAbilityToggle")
        end,
        set = function(_, value)
          self:SetCVar("secureAbilityToggle", value)
        end,
        width = "full",
        order = 15,
      },
      scriptErrors = {
        type = "toggle",
        name = SHOW_LUA_ERRORS,
        desc = OPTION_TOOLTIP_SHOW_LUA_ERRORS,
        get = function()
          return C_CVar.GetCVarBool("scriptErrors")
        end,
        set = function(_, value)
          self:SetCVar("scriptErrors", value)
        end,
        width = "full",
        order = 16,
      },
      noBuffDebuffFilterOnTarget = {
        type = "toggle",
        name = "不要過濾目標的減益",
        desc = "完全不要過濾目標身上的增益或減益效果。",
        get = function()
          return C_CVar.GetCVarBool("noBuffDebuffFilterOnTarget")
        end,
        set = function(_, value)
          self:SetCVar("noBuffDebuffFilterOnTarget", value)
        end,
        width = "full",
        order = 17,
      },
      reverseCleanupBags = {
        type = "toggle",
        name = REVERSE_CLEAN_UP_BAGS_TEXT,
        desc = OPTION_TOOLTIP_REVERSE_CLEAN_UP_BAGS,
        get = function()
          if C_Container and C_Container.GetSortBagsRightToLeft then
            return C_Container.GetSortBagsRightToLeft()
          elseif GetInsertItemsRightToLeft then
            return GetInsertItemsRightToLeft()
          end
        end,
        set = function(_, value)
          -- This is a dirty hack for SetSortBagsRightToLeft not instantly updating the bags
          -- Force a refresh of the UI after a set amount of time to make the checkbox reflect the new value
          C_Timer.After(0.5, function()
            LibStub("AceConfigRegistry-3.0"):NotifyChange("AdvancedInterfaceOptions")
          end)

          if C_Container and C_Container.SetSortBagsRightToLeft then
            C_Container.SetSortBagsRightToLeft(value)
          elseif SetSortBagsRightToLeft then
            SetSortBagsRightToLeft(value)
          end
        end,
        hidden = function()
          return self.IsClassicEra() or self.IsClassic()
        end,
        width = "full",
        order = 18,
      },
      lootLeftmostBag = {
        type = "toggle",
        name = REVERSE_NEW_LOOT_TEXT,
        desc = OPTION_TOOLTIP_REVERSE_NEW_LOOT,
        get = function()
          if C_Container and C_Container.GetInsertItemsLeftToRight then
            return C_Container.GetInsertItemsLeftToRight()
          elseif GetInsertItemsLeftToRight then
            GetInsertItemsLeftToRight()
          end
        end,
        set = function(_, value)
          -- This is a dirty hack for SetInsertItemsLeftToRight not instantly updating the bags
          -- Force a refresh of the UI after a set amount of time to make the checkbox reflect the new value
          C_Timer.After(0.5, function()
            LibStub("AceConfigRegistry-3.0"):NotifyChange("AdvancedInterfaceOptions")
          end)

          if C_Container and C_Container.SetInsertItemsLeftToRight then
            return C_Container.SetInsertItemsLeftToRight(value)
          elseif SetInsertItemsLeftToRight then
            SetInsertItemsLeftToRight(value)
          end
        end,
        hidden = function()
          return self.IsClassicEra() or self.IsClassic()
        end,
        width = "full",
        order = 19,
      },
      enableWoWMouse = {
        type = "toggle",
        name = WOW_MOUSE,
        desc = OPTION_TOOLTIP_WOW_MOUSE,
        get = function()
          -- NOTE: Currently broken, see https://github.com/Stanzilla/AdvancedInterfaceOptions/issues/83
          ---@diagnostic disable-next-line: param-type-mismatch
          return C_CVar.GetCVarBool("enableWoWMouse")
        end,
        set = function(_, value)
          self:SetCVar("enableWoWMouse", value)
        end,
        width = "full",
        order = 20,
      },
      -------------------------------------------------
      cameraHeader = {
        type = "header",
        name = "",
        order = 30,
      },
      trackQuestSorting = {
        type = "select",
        name = "任務排序方式:",
        desc = "選擇任務日誌如何排序任務。",
        values = {
          ["top"] = "上方",
          ["proximity"] = "距離最近",
        },
        sorting = {
          "top",
          "proximity",
        },
        get = function()
          return C_CVar.GetCVar("trackQuestSorting")
        end,
        set = function(_, value)
          self:SetCVar("trackQuestSorting", value)
        end,
        width = THIRD_WIDTH,
        order = 31,
      },
      -------------------------------------------------
      dataHeader = {
        type = "header",
        name = "",
        order = 40,
      },
      backupSettings = {
        type = "execute",
        name = "備份設定",
        func = function()
          StaticPopup_Show("AIO_BACKUP_SETTINGS")
        end,
        width = THIRD_WIDTH,
        order = 41,
      },
      restoreSettings = {
        type = "execute",
        name = "還原設定",
        func = function()
          StaticPopup_Show("AIO_RESTORE_SETTINGS")
        end,
        width = THIRD_WIDTH,
        order = 43,
      },
      resetSettings = {
        type = "execute",
        name = "重置設定",
        func = function()
          StaticPopup_Show("AIO_RESET_EVERYTHING")
        end,
        width = THIRD_WIDTH,
        order = 43,
      },
    },
  }

  return generalOptions
end
