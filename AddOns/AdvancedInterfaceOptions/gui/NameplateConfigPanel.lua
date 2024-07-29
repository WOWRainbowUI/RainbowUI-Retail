local _, addon = ...

-- Constants
local THIRD_WIDTH = 1.25

-------------------------------------------------------------------------
-------------------------------------------------------------------------

function addon:CreateNameplateOptions()
  local nameplateOptions = {
    type = "group",
    childGroups = "tree",
    name = "名條",
    args = {
      instructions = {
        type = "description",
        name = "這些選項可以調整名條/血條設定。",
        fontSize = "medium",
        order = 1,
      },
      header = {
        type = "header",
        name = "",
        order = 10,
      },
      -------------------------------------------------
      nameplateOtherAtBase = {
        type = "toggle",
        name = "名條在腳下",
        desc = "其他名條顯示在腳下，而不是頭頂。 2=腳下, 0=頭頂",
        get = function()
          return C_CVar.GetCVarBool("nameplateOtherAtBase")
        end,
        set = function(_, value)
          self:SetCVar("nameplateOtherAtBase", value)
        end,
        width = "full",
        order = 11,
      },
      ShowClassColorInFriendlyNameplate = {
        type = "toggle",
        name = "友方名條顯示職業顏色",
        desc = "友方名條顯示職業顏色",
        get = function()
          return C_CVar.GetCVarBool("ShowClassColorInFriendlyNameplate")
        end,
        set = function(_, value)
          self:SetCVar("ShowClassColorInFriendlyNameplate", value)
        end,
        width = "full",
        order = 12,
      },
    },
  }

  return nameplateOptions
end
