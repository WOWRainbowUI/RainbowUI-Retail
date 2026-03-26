local AddonName, MKPT_env, _ = ...

function MKPT_env.InitializeSavedVariables()
  local defaults = {
    char = {
      state = {
        expansion = GetExpansionLevel() == Enum.ExpansionLevel.WarWithin and Enum.ExpansionLevel.WarWithin or
        Enum.ExpansionLevel.Midnight,
        show = true,
        firstTimeLoaded = true,
      },
    },
    global = {
      minimap = {
        hide = false,
        showInCompartment = true
      },
      compartment = {
        hide = false,
      },
      config = {
        hideCatchUp = false,
        hideFirstTimeGather = false,
        hideMaxedProfession = true,
        hideTreatise = false,
        hideWeeklyQuests = false,
        hideWeeklyTreasures = false,
        hideUniqueBooks = false,
        hideUniqueTreasures = false,
        hideWhenDone = false,
        minimized = true,
        showAllProfessions = false,
      },
      ui = {
        autohide = false,
        paddingY = 1,
        rowHeight = 20,
        fontSize = 13,
        insets = { left = -3, right = -3, top = -1, bottom = -2 },
        backgroundColor = { r = 0, g = 0, b = 0, a = 0.6 },
        rowBackgroundColor = { r = 0, g = 0, b = 0, a = 0.5 },
        scale = 1.0,
        lockWindow = false,
        hideInCombat = false,
      }
    }
  }

  local db = LibStub("AceDB-3.0"):New("MKPT_Config", defaults)
  MKPT_env.db = db.global
  MKPT_env.charDb = db.char
end
