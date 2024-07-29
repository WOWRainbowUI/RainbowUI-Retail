local _, addon = ...

-- Constants
local THIRD_WIDTH = 1.25

-------------------------------------------------------------------------
-------------------------------------------------------------------------

function addon:CreateCombatOptions()
  local combatOptions = {
    type = "group",
    childGroups = "tree",
    name = "戰鬥",
    args = {
      instructions = {
        type = "description",
        name = "這些選項可以調整戰鬥設定。",
        fontSize = "medium",
        order = 1,
      },
      header = {
        type = "header",
        name = "",
        order = 10,
      },
      -------------------------------------------------
      stopAutoAttackOnTargetChange = {
        type = "toggle",
        name = STOP_AUTO_ATTACK,
        desc = OPTION_TOOLTIP_STOP_AUTO_ATTACK,
        get = function()
          return C_CVar.GetCVarBool("stopAutoAttackOnTargetChange")
        end,
        set = function(_, value)
          self:SetCVar("stopAutoAttackOnTargetChange", value)
        end,
        width = "full",
        order = 11,
      },
      assistAttack = {
        type = "toggle",
        name = ASSIST_ATTACK,
        desc = OPTION_TOOLTIP_ASSIST_ATTACK,
        get = function()
          return C_CVar.GetCVarBool("assistAttack")
        end,
        set = function(_, value)
          self:SetCVar("assistAttack", value)
        end,
        width = "full",
        order = 12,
      },
      ActionButtonUseKeyDown = {
        type = "toggle",
        name = ACTION_BUTTON_USE_KEY_DOWN,
        desc = OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN,
        get = function()
          return C_CVar.GetCVarBool("ActionButtonUseKeyDown")
        end,
        set = function(_, value)
          self:SetCVar("ActionButtonUseKeyDown", value)
        end,
        width = "full",
        order = 13,
      },
      SpellQueueWindow = {
        type = "range",
        name = LAG_TOLERANCE,
        desc = "決定在「法術結束」開始恢復法術系統之前，可以提前多久，才允許將法術請求發送到伺服器。也就是說，這控制了技能排隊系統的內建延遲。",
        min = 0,
        max = 400,
        step = 1,
        get = function()
          return tonumber(C_CVar.GetCVar("SpellQueueWindow"))
        end,
        set = function(_, value)
          self:SetCVar("SpellQueueWindow", value)
        end,
        width = THIRD_WIDTH,
        order = 14,
      },
    },
  }

  return combatOptions
end
